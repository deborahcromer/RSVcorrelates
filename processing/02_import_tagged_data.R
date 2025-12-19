if(grepl("csv$",tagged_pharma_data_file)) {
  basic_tagged_data_import = read.csv(tagged_pharma_data_file, fileEncoding = "UTF-8") 
} else if (grepl("xlsx$",tagged_pharma_data_file)) {
  basic_tagged_data_import = read_xlsx(tagged_pharma_data_file) 
}

if(grepl("csv$",tagged_pharma_extra_data_file)) {
  extra_tagged_data_import = read.csv(tagged_pharma_extra_data_file, fileEncoding = "UTF-8") 
} else if (grepl("xlsx$",tagged_pharma_extra_data_file_name)) {
  extra_tagged_data_import = read_xlsx(tagged_pharma_extra_data_file) 
}

tagged_data_import = bind_rows(basic_tagged_data_import, extra_tagged_data_import)