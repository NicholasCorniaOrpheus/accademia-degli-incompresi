from kblight.entity import import_md, assets
from kblight.statement import statements, inverse_properties
from kblight import utilities

import yaml, os
from pathlib import Path
import re
from typing import Any, List, Dict

### DIRECTORIES AND CONFIGURATION FILES

credentials = utilities.json2dict("./config/credentials.json")

source_dir = "./accademia-degli-incompresi/entity"

assets_dir = "./accademia-degli-incompresi/assets"

yaml_dir = "./yaml"

base_url = "https://nicholascorniaorpheus.github.io/accademia-degli-incompresi/entity/"

properties_mapping_path = "./mappings/yaml_properties2lod.csv"

inverse_properties_mapping_path = "./mappings/yaml_inverse_properties.csv"

date_properties_path = "./mappings/date_properties.csv"

class_mapping_path = "./mappings/yaml_classes2lod.csv"

### CUSTOM FUNCTIONS


def extract_year(date_str: str) -> int:
    """Extracts the integer year from various string formats.

    Handles: yyyy, yyyy-mm-dd, dd-mm-yyyy, yyyy-mm, mm-yyyy,
             ~yyyy, c. yyyy, and ranges like 1543-1574 (returns min).
    """
    if not date_str or not isinstance(date_str, str):
        raise ValueError("Input must be a non-empty string")

    # Find all sequences of exactly 4 digits anywhere in the string
    years = [int(y) for y in re.findall(r"\d{4}", date_str)]

    if years:
        return min(years)

    raise ValueError(f"Could not extract a valid 4-digit year from: '{date_str}'")


# Made with Copilot
def extract_property_path_values_iterative(
    entity: Any, property_path: str, separator: str = "/"
) -> List[Any]:
    """
    Iterative version of extract_property_path_values:
    - Traverses keys from left to right.
    - If a dict yields a list for a key, its items are expanded and processing continues on each item.
    - If a list is encountered at the current level, each element is tried for the same key.
    - When keys are exhausted, if a final value is a list its elements are returned individually.
    - Missing keys are ignored (no exception).
    """
    if not property_path:
        raise ValueError("property_path must be a non-empty string")

    keys = property_path.split(separator)
    # start with the initial node as the only "current" candidate
    current_nodes: List[Any] = [entity]

    for key in keys:
        next_nodes: List[Any] = []
        for node in current_nodes:
            if isinstance(node, dict):
                if key in node:
                    val = node[key]
                    # If the value is a list, expand it so subsequent keys apply to each element
                    if isinstance(val, list):
                        next_nodes.extend(val)
                    else:
                        next_nodes.append(val)
            elif isinstance(node, list):
                # If current node itself is a list, try the key on each item
                for item in node:
                    if isinstance(item, dict) and key in item:
                        val = item[key]
                        if isinstance(val, list):
                            next_nodes.extend(val)
                        else:
                            next_nodes.append(val)
                    # if item is not a dict or key missing, skip it
            # primitives / other types: cannot follow a key, skip
        # move to next level
        current_nodes = next_nodes
        if not current_nodes:
            # nothing found for this key path -> return empty list early
            return []

    # After processing all keys, collect final values: if some final nodes are lists,
    # flatten them (user expects individual elements when final target is a list).
    results: List[Any] = []
    for v in current_nodes:
        if isinstance(v, list):
            results.extend(v)
        else:
            results.append(v)
    return results


# Made with Copilot
def append_statement_to_entity(
    entity: Dict[str, Any],
    property_path: str,
    property_value: Any,
    separator: str = "/",
) -> Dict[str, Any]:
    """
    Append property_value to entity at property_path (e.g. "a/b/c"), creating
    intermediate dicts/lists as needed. Avoids duplicates by equality.

    Behavior changes from previous version:
    - If the final key is missing and property_value is NOT a list, store the scalar
      directly (e.g., "value": 1560).
    - If property_value is a list (multiple values) or the final target already
      contains multiple values (a list), preserve list semantics.
    - If final value exists and is a different scalar, convert to a list [existing, new].
    """
    if not property_path:
        raise ValueError("property_path must be a non-empty string")

    keys = property_path.split(separator)
    current: Any = entity
    parent: Any = None
    parent_key: Any = None

    # Walk all but the last key, creating structure as needed
    for key in keys[:-1]:
        parent = current
        parent_key = key

        if isinstance(current, dict):
            if key not in current or current[key] is None:
                current[key] = {}
            child = current[key]

            if isinstance(child, list):
                if not child or not isinstance(child[-1], dict):
                    child.append({})
                current = child[-1]
            else:
                if not isinstance(child, dict):
                    # Replace primitive with dict to continue traversal
                    current[key] = {}
                    current = current[key]
                else:
                    current = child

        elif isinstance(current, list):
            if not current or not isinstance(current[-1], dict):
                current.append({})
            current = current[-1]

        else:
            # current is primitive: replace in parent with dict to continue
            if isinstance(parent, dict):
                parent[parent_key] = {}
                current = parent[parent_key]
            elif isinstance(parent, list):
                parent[-1] = {}
                current = parent[-1]
            else:
                # unlikely: top-level primitive, create new dict (best-effort)
                current = {}

    final_key = keys[-1]

    def _contains_equal(lst: List[Any], val: Any) -> bool:
        for item in lst:
            if item == val:
                return True
        return False

    # Helper to merge list-valued property_value into existing list avoiding duplicates
    def _extend_list_unique(target_list: List[Any], values: List[Any]) -> None:
        for v in values:
            if not _contains_equal(target_list, v):
                target_list.append(v)

    # Handle final placement
    if isinstance(current, dict):
        if final_key not in current or current[final_key] is None:
            # Key missing: if property_value is list, store list; else store scalar
            if isinstance(property_value, list):
                # copy to avoid aliasing
                current[final_key] = list(property_value)
            else:
                current[final_key] = property_value
        else:
            existing = current[final_key]
            if isinstance(existing, list):
                # existing is list: append new values avoiding duplicates
                if isinstance(property_value, list):
                    _extend_list_unique(existing, property_value)
                else:
                    if not _contains_equal(existing, property_value):
                        existing.append(property_value)
            else:
                # existing is scalar
                if existing == property_value:
                    # duplicate scalar: nothing to do
                    pass
                else:
                    # we now have multiple values -> convert to list
                    if isinstance(property_value, list):
                        # merge existing scalar + unique items from property_value
                        new_list = [existing]
                        for v in property_value:
                            if v != existing and not _contains_equal(new_list, v):
                                new_list.append(v)
                        current[final_key] = new_list
                    else:
                        current[final_key] = [existing, property_value]

    elif isinstance(current, list):
        # Path ended on a list: append values to the list (avoid duplicates)
        if isinstance(property_value, list):
            _extend_list_unique(current, property_value)
        else:
            if not _contains_equal(current, property_value):
                current.append(property_value)

    else:
        # current is primitive: attach back to parent appropriately
        if isinstance(parent, dict):
            # parent[parent_key] should be current
            if parent_key in parent and parent[parent_key] == current:
                if current == property_value:
                    parent[parent_key] = current
                else:
                    # different scalar -> convert to list
                    if isinstance(property_value, list):
                        new_list = [current]
                        _extend_list_unique(new_list, property_value)
                        parent[parent_key] = new_list
                    else:
                        parent[parent_key] = [current, property_value]
            else:
                parent[parent_key] = (
                    property_value
                    if not isinstance(property_value, list)
                    else list(property_value)
                )
        elif isinstance(parent, list):
            if parent and parent[-1] == current:
                if current == property_value:
                    parent[-1] = current
                else:
                    if isinstance(property_value, list):
                        new_list = [current]
                        _extend_list_unique(new_list, property_value)
                        parent[-1] = new_list
                    else:
                        parent[-1] = [current, property_value]
            else:
                # fallback: append property_value
                parent.append(
                    property_value
                    if not isinstance(property_value, list)
                    else list(property_value)
                )
        else:
            # no parent: return a minimal structure
            return {
                final_key: property_value
                if not isinstance(property_value, list)
                else list(property_value)
            }

    return entity


def retrieve_inception_date(
    yaml_dir: str | Path = yaml_dir,
    class_filter: list = ["Book", "NotatedMusic"],
    inception_key: str = "statements/inception/value",
    publication_date_key: str = "statements/has_version/publication_date",
):
    counter = 0
    # Go through all entities in YAML directory
    yaml_dir = Path(yaml_dir)
    for file in yaml_dir.iterdir():
        if file.name.endswith((".yaml", ".yml")):
            changed = False
            try:
                # Step A: Read the file content cleanly
                entity = utilities.yaml2dict(file)

                if not entity:
                    continue

                # Check if entity class is in class_filter
                if any(
                    entity["metadata"]["class"] in class_value
                    for class_value in class_filter
                ):
                    # print(f"Current entity {entity["metadata"]["id"]} belogns to class filter:")
                    # get publication dates
                    publication_dates = extract_property_path_values_iterative(
                        entity=entity, property_path=publication_date_key
                    )
                    # print(f"Publication dates: {publication_dates}")
                    # convert dates into integer years
                    if len(publication_dates) > 0:
                        publication_years = []
                        for date in publication_dates:
                            if isinstance(date, int):
                                publication_years.append(date)
                            else:
                                year = extract_year(date)
                                if year is not None:
                                    publication_years.append(year)

                        # print(f"Publication years: {publication_years}")
                        earliest_date = min(publication_years)
                        # append earliest publication date to inception, if property is empty
                        inceptions = extract_property_path_values_iterative(
                            entity=entity, property_path=inception_key
                        )

                        # print(f"Inceptions: {inceptions}")
                        if len(inceptions) > 0:
                            inception_years = []
                            for date in inceptions:
                                if isinstance(date, int):
                                    inception_years.append(date)
                                else:
                                    year = extract_year(date)
                                    if year is not None:
                                        inception_years.append(year)

                            if min(inception_years) > earliest_date:
                                # generate new statement for inception
                                entity = append_statement_to_entity(
                                    entity=entity,
                                    property_path=inception_key,
                                    property_value=str(earliest_date),
                                )
                                changed = True
                            else:
                                # do nothing
                                pass

                        else:  # no inceptions
                            entity = append_statement_to_entity(
                                entity=entity,
                                property_path=inception_key,
                                property_value=earliest_date,
                            )
                            changed = True

                        if changed is True:
                            # save entity to YAML file
                            # print(f"Added new inception date for {entity["metadata"]["id"]}.")
                            counter += 1
                            utilities.dict2yaml(entity, file)

            except Exception as e:
                print(f"Error processing modifications on {file.name}: {e}")

    print(f"Added {counter} inception dates to entities.")


### CODE

print("Generating UUID-labels mapping....")
uuid_mapping_index = import_md.generate_label_uuid_mapping(yaml_dir=yaml_dir)

print("Generating URI-labels mapping....")
uri_mapping_index = import_md.generate_label_uri_mapping(
    base_url=base_url, yaml_dir=yaml_dir
)

print("Extracting metadata from Markdown notes, updating existing ones...")
import_md.extract_metadata(
    source_dir=source_dir,
    yaml_dir=yaml_dir,
    update_existing=True,
    mapping_index=uuid_mapping_index,
)

# print("Populate inverse properties according to mapping...")
# populate_inverse_properties(
#     yaml_dir=yaml_dir,
#     inverse_properties_mapping_path=inverse_properties_mapping_path,
#     mapping_index=uuid_mapping_index,
# )

print("Organize statements according to category...")
statements.organize_statements(
    yaml_dir=yaml_dir, properties_mapping_path=properties_mapping_path
)

print("Retrieve inception date for books and notated music...")
retrieve_inception_date(
    yaml_dir=yaml_dir,
    class_filter=["Book,NotatedMusic"],
    inception_key="statements/inception/value",
    publication_date_key="statements/has_version/publication_date",
)

print("Subsititute wikilinks with URIs")
import_md.substitute_wikilinks(
    base_url=base_url, mapping_index=uri_mapping_index, yaml_dir=yaml_dir
)

print("Add labels to internal URIs...")
statements.add_labels_to_statements(
    base_url=base_url,
    yaml_dir=yaml_dir,
    mapping_index=uri_mapping_index,
)

print("Extract assets files and IIIF manifest...")
assets.extract_assets_from_local_paths(
    yaml_dir=yaml_dir,
    vault_path="./accademia-degli-incompresi",
    vault_base_url=credentials["kblight"]["vault_url"],
)

print("Add default images if absent...")
assets.add_default_image(yaml_dir=yaml_dir, class_mapping_path=class_mapping_path)
