document.addEventListener("DOMContentLoaded", async function() {
    const resultsGrid = document.getElementById('search-results');
    if (!resultsGrid) return;

    const indexUrl = 'https://raw.githubusercontent.com/NicholasCorniaOrpheus/accademia-degli-incompresi/main/data/advanced_search_index.json';
    const classCsvUrl = 'https://raw.githubusercontent.com/NicholasCorniaOrpheus/accademia-degli-incompresi/main/data/mappings/yaml_classes2lod.csv';

    try {
        const response = await fetch(indexUrl);
        const searchData = await response.json();

        // Helper: parse class CSV to get class options (first column)
        async function fetchClassOptions() {
            try {
                const res = await fetch(classCsvUrl);
                if (!res.ok) throw new Error(`CSV fetch ${res.status}`);
                const txt = await res.text();
                const lines = txt.split(/\r?\n/).filter(Boolean);
                // Expect header row; get column index of the yaml_class if present
                const header = lines.shift().split(',');
                const firstColName = header[0] ? header[0].trim().toLowerCase() : 'yaml_class';
                const classes = lines.map(line => {
                    const parts = line.split(',');
                    return parts[0] ? parts[0].trim() : null;
                }).filter(Boolean);
                // Deduplicate & sort
                return Array.from(new Set(classes)).sort((a,b) => a.localeCompare(b));
            } catch (err) {
                console.warn("Failed to load class CSV:", err);
                return [];
            }
        }

        const classOptions = await fetchClassOptions();

        // 1. Setup Properties and Date Range
        const propertyKeys = new Set();
        let allYears = [];

        // Recursive extractor that finds integer-like values from any structure
        function extractIntegersFromValue(val, outArray) {
            if (val === null || val === undefined) return;
            if (Array.isArray(val)) {
                val.forEach(v => extractIntegersFromValue(v, outArray));
                return;
            }
            if (typeof val === 'object') {
                // scan object values
                Object.values(val).forEach(v => extractIntegersFromValue(v, outArray));
                return;
            }
            // primitive (string/number/boolean)
            // Try to parse integer
            const s = String(val).trim();
            if (!s) return;
            // find first integer-like token in the string (handles values like "1984-05-01" or "c.1800" or "1800")
            const m = s.match(/(-?\d{3,4})/);
            if (m) {
                const n = parseInt(m[1], 10);
                // accept only plausible year ranges
                if (!Number.isNaN(n) && n >= 100 && n <= 3000) {
                    outArray.push(n);
                }
            }
        }

        searchData.forEach(doc => {
            if (doc.properties && typeof doc.properties === 'object') {
                Object.keys(doc.properties).forEach(k => propertyKeys.add(k));
                // scan every property value for integer-like year values
                Object.values(doc.properties).flat().forEach(val => {
                    extractIntegersFromValue(val, allYears);
                });
            }
        });

        const sortedKeys = Array.from(propertyKeys).sort();
        const minYear = (allYears.length > 0) ? Math.min(...allYears) : 1800;
        const maxYear = (allYears.length > 0) ? Math.max(...allYears) : 1900;

        // 2. Initialise UI
        const minSlider = document.getElementById('time-min');
        const maxSlider = document.getElementById('time-max');
        if (minSlider && maxSlider) {
            [minSlider, maxSlider].forEach(s => { s.min = minYear; s.max = maxYear; });
            minSlider.value = minYear;
            maxSlider.value = maxYear;
            const minDisplay = document.getElementById('date-display-min');
            const maxDisplay = document.getElementById('date-display-max');
            if (minDisplay) minDisplay.innerText = minYear;
            if (maxDisplay) maxDisplay.innerText = maxYear;
        }

        // helper: build the value input (text or class-select) for a given property
        function createValueControlForProperty(prop) {
            if (prop === 'class') {
                const sel = document.createElement('select');
                sel.className = 'filter-query';
                sel.style.padding = '8px';
                // empty option
                const empty = document.createElement('option');
                empty.value = '';
                empty.textContent = '(any)';
                sel.appendChild(empty);
                classOptions.forEach(c => {
                    const opt = document.createElement('option');
                    opt.value = c;
                    opt.textContent = c;
                    sel.appendChild(opt);
                });
                return sel;
            } else {
                const input = document.createElement('input');
                input.type = 'text';
                input.className = 'filter-query';
                input.placeholder = 'Query... (Enter)';
                input.style.flexGrow = '1';
                input.style.padding = '8px';
                return input;
            }
        }

        // 3. Filter Row Logic
        const filterContainer = document.getElementById('filter-rows');
        function addRow() {
            const row = document.createElement('div');
            row.className = 'filter-row';
            row.style = 'display: flex; gap: 10px; margin-bottom: 10px; align-items: center;';

            // property select
            const propSelect = document.createElement('select');
            propSelect.className = 'filter-property';
            propSelect.style.padding = '8px';
            propSelect.innerHTML = sortedKeys.map(k => `<option value="${k}">${k.replace(/_/g, ' ')}</option>`).join('');

            // initial value control depends on selected property
            const initialProp = propSelect.value;
            const valueControl = createValueControlForProperty(initialProp);

            const removeBtn = document.createElement('button');
            removeBtn.className = 'remove-filter';
            removeBtn.style.cursor = 'pointer';
            removeBtn.style.background = 'none';
            removeBtn.style.border = 'none';
            removeBtn.style.fontSize = '20px';
            removeBtn.innerHTML = '&times;';

            row.appendChild(propSelect);
            row.appendChild(valueControl);
            row.appendChild(removeBtn);

            // events
            // when property changes, swap the value control appropriately
            propSelect.addEventListener('change', (e) => {
                const newProp = e.target.value;
                const existingValueControl = row.querySelector('.filter-query');
                const newControl = createValueControlForProperty(newProp);
                // preserve previous string query if switching away from class
                if (existingValueControl && existingValueControl.tagName === 'INPUT' && newControl.tagName === 'INPUT') {
                    newControl.value = existingValueControl.value;
                }
                existingValueControl.replaceWith(newControl);
                // wire Enter handler for new input
                if (newControl.tagName === 'INPUT') {
                    newControl.addEventListener('keydown', ev => { if (ev.key === 'Enter') performSearch(); });
                } else {
                    // select change triggers rebuild
                    newControl.addEventListener('change', () => performSearch());
                }
                // trigger search on property change
                performSearch();
            });

            // Enter on text input triggers
            if (valueControl.tagName === 'INPUT') {
                valueControl.addEventListener('keydown', e => { if(e.key==='Enter') performSearch(); });
            } else {
                valueControl.addEventListener('change', () => performSearch());
            }

            removeBtn.addEventListener('click', () => { row.remove(); performSearch(); });

            filterContainer.appendChild(row);
        }

        // 4. Advanced Search Logic
        function performSearch() {
            const generalEl = document.getElementById('general-search');
            const general = generalEl ? generalEl.value.toLowerCase() : '';
            const minV = parseInt(minSlider.value, 10);
            const maxV = parseInt(maxSlider.value, 10);
            const rows = document.querySelectorAll('.filter-row');

            const results = searchData.filter(doc => {
                // Folder Restriction
                if (!doc.location || !doc.location.startsWith('/entity/')) return false;

                // General Text Search (Search inside the stringified properties)
                const matchesGeneral = !general || JSON.stringify(doc.properties).toLowerCase().includes(general);

                // Date Range Check: doc passes if ANY integer-like year found within range
                let inRange = true;
                // find all integers in this doc's properties
                const docYears = [];
                if (doc.properties) {
                    Object.values(doc.properties).flat().forEach(val => {
                        extractIntegersFromValue(val, docYears);
                    });
                }
                if (docYears.length > 0) {
                    // require at least one year within [minV, maxV]
                    const anyIn = docYears.some(y => y >= minV && y <= maxV);
                    inRange = anyIn;
                } else {
                    // if no year info at all, treat as in-range (or decide to exclude — current approach is permissive)
                    inRange = true;
                }

                // Property Match (AND logic)
                let matchesAll = true;
                rows.forEach(row => {
                    const prop = row.querySelector('.filter-property').value;
                    const control = row.querySelector('.filter-query');
                    let query = '';
                    if (!control) return;
                    if (control.tagName === 'INPUT') {
                        query = control.value.trim().toLowerCase();
                        if (!query) return;
                    } else if (control.tagName === 'SELECT') {
                        query = control.value.trim().toLowerCase();
                        // if empty selection, skip this row
                        if (!query) return;
                    }

                    const vals = doc.properties[prop] || [];
                    const found = vals.some(v => {
                        // If the property values are objects with .label or simple strings
                        if (v === null || v === undefined) return false;
                        if (typeof v === 'object') {
                            // If v has a 'label' field, prefer that
                            const text = v.label || JSON.stringify(v);
                            return String(text).toLowerCase().includes(query);
                        } else {
                            return String(v).toLowerCase().includes(query);
                        }
                    });
                    if (!found) matchesAll = false;
                });

                return matchesGeneral && inRange && matchesAll;
            });
            renderResults(results);
        }

        // 5. Render Grid (Handling Array Values)
        function renderResults(results) {
            resultsGrid.innerHTML = results.map(doc => {
                // Extract first available label and image from arrays
                let title = "Untitled";
                if (doc.properties.label && Array.isArray(doc.properties.label) && doc.properties.label.length > 0) {
                    const first = doc.properties.label[0];
                    title = (typeof first === 'object') ? (first.label || JSON.stringify(first)) : String(first);
                } else if (doc.properties.label) {
                    // fallback if label is not an array
                    const lbl = doc.properties.label;
                    if (typeof lbl === 'string') title = lbl;
                }

                let imgSrc = "../assets/images/placeholder.jpg";
                if (doc.properties.image && Array.isArray(doc.properties.image) && doc.properties.image.length > 0) {
                    const firstImg = doc.properties.image[0];
                    imgSrc = (typeof firstImg === 'object') ? (firstImg.value || firstImg.url || JSON.stringify(firstImg)) : String(firstImg);
                } else if (doc.properties.image && typeof doc.properties.image === 'string') {
                    imgSrc = doc.properties.image;
                }

                // Sanitize/normalize src if it's relative and you need to prefix - kept simple here
                return `
                <a href="..${doc.location}/" class="card-link">
                    <div class="card" style="border: 1px solid var(--md-typeset-table-color); border-radius: 8px; overflow: hidden; height: 100%;">
                        <div style="height: 180px; background: #eee;">
                            <img src="${imgSrc}" style="width:100%; height:100%; object-fit:cover;" loading="lazy" alt="${title}">
                        </div>
                        <div style="padding: 10px; text-align: center;">
                            <strong style="font-family: 'Crimson Pro', serif;">${title}</strong>
                        </div>
                    </div>
                </a>`;
            }).join('') || '<p>No entities found.</p>';
        }

        // Event Listeners
        const addFilterBtn = document.getElementById('add-filter');
        if (addFilterBtn) addFilterBtn.addEventListener('click', addRow);
        const generalInput = document.getElementById('general-search');
        if (generalInput) generalInput.addEventListener('keydown', e => { if(e.key==='Enter') performSearch(); });
        if (minSlider && maxSlider) {
            [minSlider, maxSlider].forEach(s => s.addEventListener('input', () => {
                const minDisplay = document.getElementById('date-display-min');
                const maxDisplay = document.getElementById('date-display-max');
                if (minDisplay) minDisplay.innerText = minSlider.value;
                if (maxDisplay) maxDisplay.innerText = maxSlider.value;
                performSearch();
            }));
        }

        addRow(); // Start with one row
        performSearch(); // Initial load

    } catch (err) {
        console.error("Explore script failed:", err);
    }
});