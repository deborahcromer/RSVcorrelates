current_wd = getwd()
on.exit(setwd(current_wd), add = TRUE) 

attribute_hierarchy_file_name = glue("{current_wd}/{attribute_hierarchy_file}")
covidence_output_file_name = glue("{current_wd}/{edited_tagged_file}")
output_json_file_name = "rsv_eppimapper_json_file.json"
tryCatch (
  {
    setwd("../Covidence_to_EPPI_Mapper")
    source("./setup.R")
    source("./covidence_to_eppi_mapper_conversion.R")
  },
  error = function(e) {
    print("ERROR")
    message("❌ Error: ", conditionMessage(e))
  },
  finally = {
    message("ℹ️ Cleanup: restoring working directory.")
    setwd(current_wd)  # optional here; on.exit already handles it
  }
)
