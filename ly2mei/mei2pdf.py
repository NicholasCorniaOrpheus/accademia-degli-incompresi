import verovio
from pathlib import Path
import os
import cairosvg
from pypdf import PdfReader, PdfWriter
import io


def convert_mei_to_pdf(mei_file_path: str):
    # 1. Initialize and configure the Verovio v6.3 Toolkit
    tk = verovio.toolkit()
    tk.setOptions(
        {
            # "notationType": "mensural",
            "breaks": "encoded",
            "pageWidth": 2100,  # A4 dimensions in tenths of mm
            "pageHeight": 2970,
            "adjustPageHeight": False,  # Ensures a uniform canvas across all pages
        }
    )

    # Load your MEI document
    tk.loadFile(mei_file_path)
    page_count = tk.getPageCount()

    # 2. Modern pypdf v6.x Writer initialization
    writer = PdfWriter()

    print(f"Processing {page_count} pages with Verovio v6.3 & pypdf v6.16.2...")

    for page_num in range(1, page_count + 1):
        # Render vector SVG string via Verovio
        svg_string = tk.renderToSVG(page_num)

        # Compile SVG to PDF binaries using cairosvg
        pdf_bytes = cairosvg.svg2pdf(bytestring=svg_string.encode("utf-8"))

        # Read the bytes object into pypdf using PdfReader
        reader = PdfReader(io.BytesIO(pdf_bytes))

        # Append the extracted page into the final document stack
        writer.add_page(reader.pages[0])

    # 3. Export to a clean, cohesive PDF file
    output_filename = Path(mei_file_path).with_suffix(".pdf")
    with open(output_filename, "wb") as f_out:
        writer.write(f_out)

    writer.close()
    print(f"Successfully generated unique PDF: {output_filename}")


### CODE ###

# Convert all MEI files to PDF in subdirectories of root_dir

root_dir = "./data"

for mei_file in Path(root_dir).rglob("*.mei"):
    print(f"Converting {mei_file} to PDF...")
    convert_mei_to_pdf(str(mei_file))
