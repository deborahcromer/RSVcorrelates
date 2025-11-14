current_wd = getwd()

attribute_hierarchy_file_name = glue("{current_wd}/{attribute_hierarchy_file}")
covidence_output_file_name = glue("{current_wd}/{edited_tagged_file}")
output_json_file_name = "rsv_eppimapper_json_file.json"

setwd("../Covidence_to_EPPI_Mapper")
source("./setup.R")
source("./covidence_to_eppi_mapper_conversion.R")
setwd(current_wd)

