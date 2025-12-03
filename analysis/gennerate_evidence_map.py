
from pathlib import Path
import json
from playwright.sync_api import sync_playwright, TimeoutError as PlaywrightTimeout
import ipdb as pdb

"""
import debugpy
debugpy.listen(("127.0.0.1", 5678))             # choose a port
print("Waiting for debugger attach on 5678...")
debugpy.wait_for_client()                       # pause until VS Code attaches
# Optional breakpoint
debugpy.breakpoint()
"""

EPPI_URL = "https://eppimapper.digitalsolutionfoundry.co.za/#/"

COLUMN_ATTR = "Population"
ROW_ATTR = "Product and Approval Details"
SEGMENTING_ATTR = "Clinical Trial Number"

ABOUT_TEXT = "This is an evidence map for the systematic review performed in our paper."

json_file_location = "/Users/deborah/github/Covidence_to_EPPI_Mapper/output/rsv_eppimapper_json_file.json"
logo_file_location = "/Users/deborah/github/RSVcorrelates/raw-data/kirby_logo.png"
download_directory = "/Users/deborah/github/RSVcorrelates/output"
def validate_json_has_attributes(json_path: str):
    """
    Fast sanity check: ensure the three attribute names exist in the uploaded EPPI-Reviewer JSON.
    EPPI-Mapper populates these dropdowns based on what's inside the JSON. [2](https://centreforhomelessnessimpact.github.io/egm/)
    """
    with open(json_path, "r", encoding="utf-8") as f:
        data = f.read()

    # Very lightweight string presence check (robust enough for EPPI exports)
    missing = []
    for label in [COLUMN_ATTR, ROW_ATTR, SEGMENTING_ATTR]:
        if label not in data:
            missing.append(label)
    if missing:
        raise ValueError(f"JSON is missing these attributes: {', '.join(missing)}")

def run_eppi_mapper(file_loc: str, logo_file_location: str, headless: bool = True, download_dir: str = "Downloads"):
    validate_json_has_attributes(file_loc)  # fail fast if something's off
    
    dl_dir = Path(download_dir)
    dl_dir.mkdir(parents=True, exist_ok=True)

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=headless)
        context = browser.new_context(accept_downloads=True)
        page = context.new_page()

        def click_button(name: str):
            page.locator(f"button:has-text('{name}'):not([disabled])").first.click()


        def field_container_for(page, label_text: str):
            """
            Find the Vuetify field container (.v-input / .v-select) belonging to a label
            whose visible text matches `label_text` ("Column Attribute", etc.).
            """
            label = page.locator("label.v-label").filter(has_text=label_text).first
            # nearest ancestor that is a Vuetify input container
            container = label.locator("xpath=ancestor::*[contains(@class,'v-input')][1]")
            return container
        
        def open_vuetify_select(page, label_text: str):
            """
            Open the dropdown for the field with the given label.
            Prefer clicking the caret; fall back to clicking the selection chip.
            Return the menu locator (.v-menu__content or .v-overlay__content).
            """
            container = field_container_for(page, label_text)
        
            # Try caret icon
            try:
                container.locator(".v-input__append-inner .v-input__icon").first.click()
            except Exception:
                # Fallback: click the selections chip
                container.locator(".v-select__selections").first.click()
        
            # Menu container differs across Vuetify versions
            menu = page.locator(".v-menu__content, .v-overlay__content").first
            #menu.wait_for()
            pdb.set_trace()
            return menu
        
        def list_menu_options(menu):
            """
            Return the list of visible option texts inside the currently open Vuetify menu.
            """
            titles = menu.locator(".v-list-item__title")
            items  = menu.locator(".v-list-item")
            opts = []
            pdb.set_trace()
            if titles.count() > 0:
                for i in range(titles.count()):
                    txt = titles.nth(i).inner_text().strip()
                    if txt:
                        opts.append(txt)
                return opts
        
            if items.count() > 0:
                for i in range(items.count()):
                    txt = items.nth(i).inner_text().strip()
                    if txt:
                        opts.append(txt)
                return opts
            # Fallback: use container text lines
            text_blob = menu.inner_text()
            for line in text_blob.splitlines():
                line = line.strip()
                if line:
                    opts.append(line)
            return opts
        
        def choose_option(menu, option_text: str):
            """
            Click an option by text. Try common Vuetify targets first; fallback to text match.
            """
            try:
                menu.locator(".v-list-item__title").filter(has_text=option_text).first.click()
                return
            except Exception:
                pass
            try:
                menu.locator(".v-list-item").filter(has_text=option_text).first.click()
                return
            except Exception:
                pass
            menu.get_by_text(option_text, exact=True).click()
        
        def select_attribute(page, label_text: str, preferred_text: str, excluded=None, allow_fallback=False):
            """
            Open menu for the given label, enumerate options, select `preferred_text` if present,
            otherwise (if `allow_fallback` True) choose the first option not in `excluded`,
            else raise a friendly error listing available options.
            """
            excluded = set(excluded or [])
            menu = open_vuetify_select(page, label_text)
            opts = list_menu_options(menu)
        
            # Remove excluded values (e.g., Column and Row not allowed for Segmenting)
            filtered = [o for o in opts if o not in excluded]
        
            if preferred_text in filtered:
                choose_option(menu, preferred_text)
                return preferred_text
        
            if allow_fallback and filtered:
                fallback = filtered[0]
                choose_option(menu, fallback)
                print(f"ℹ️ {label_text}: '{preferred_text}' not available, chose '{fallback}' from {filtered}")
                return fallback
        
            raise RuntimeError(
                f"{label_text}: preferred '{preferred_text}' not available.\n"
                f"Visible options: {opts}\n"
                f"Excluded: {sorted(excluded)}"
            )



        def upload_input_by_index(index: int, file_path: str):
            inputs = page.locator("input[type='file']")
            count = inputs.count()
            if count <= index:
                raise RuntimeError(f"File input {index} not found; found {count} inputs.")
            inputs.nth(index).set_input_files(file_path)

        try:
            # 0) Visit EPPI-Mapper wizard
            page.goto(EPPI_URL, wait_until="domcontentloaded")
            page.wait_for_load_state("networkidle")  # SPA wizard flow, ensure UI ready [1](https://www.youtube.com/watch?v=hAdXi0tiNa4)

            # 1) Upload your JSON (first file input)
            upload_input_by_index(0, file_loc)
            #pdb.set_trace()
            # 2) Continue
            click_button("Continue")
            
            
            # 3) COLUMN
            chosen_col = select_attribute(page, "Column Attribute", preferred_text=COLUMN_ATTR)

            # 4) ROW (options may depend on Column)
            page.wait_for_timeout(200)
            chosen_row = select_attribute(page, "Row Attribute", preferred_text=ROW_ATTR)

            # 5) SEGMENTING (must not be equal to Column or Row; options depend on both)
            page.wait_for_timeout(200)
            chosen_seg = select_attribute(
                page,
                "Segmenting Attribute",
                preferred_text=SEGMENTING_ATTR,
                excluded={chosen_col, chosen_row},
                allow_fallback=True  # choose the first available that isn't excluded if preferred missing
                )
            
            # 6) Continue
            click_button("Continue")

            # 7) Add All Children (bubble codes for the chosen segment)
            page.get_by_role("button", name="Add All Children", exact=True).click()  # documented option [2](https://centreforhomelessnessimpact.github.io/egm/)

            # 8) Continue
            click_button("Continue")

            # 9) Enter About text
            try:
                page.get_by_label("About").fill(ABOUT_TEXT)
            except Exception:
                # Fallback if About is a rich text <div contenteditable>
                page.locator("[contenteditable='true']").first.fill(ABOUT_TEXT)

            # 10) Continue
            click_button("Continue")

            # 11) Continue
            click_button("Continue")

            # 12) Upload logo (second file input)
            upload_input_by_index(1, logo_file_location)

            # 13) Continue
            click_button("Continue")

            # 14) Download (standalone HTML map)
            with page.expect_download() as dl_info:
                click_button("Download")  # outputs HTML file as per EPPI-Mapper docs [2](https://centreforhomelessnessimpact.github.io/egm/)
            download = dl_info.value
            target = dl_dir / download.suggested_filename
            download.save_as(str(target))
            print(f"✅ Downloaded: {target}")

        except Exception as e:
            print(f"❌ Automation failed: {e}")
            try:
                page.screenshot(path=str(dl_dir / "failure.png"))
                print(f"Saved screenshot: {dl_dir / 'failure.png'}")
            except Exception:
                pass
            raise
        finally:
            context.close()
            browser.close()

if __name__ == "__main__":
    # Replace with your actual paths
    run_eppi_mapper(
        file_loc=json_file_location,
        logo_file_location=logo_file_location,
        headless=False,
        download_dir=download_directory
    )
