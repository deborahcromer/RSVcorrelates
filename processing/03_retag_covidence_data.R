if(grepl("csv$",tagged_pharma_data_file)) {
  tagged_data_import = read.csv(tagged_pharma_data_file) 
} else if (grepl("xlsx$",tagged_pharma_data_file)) {
  tagged_data_import = read_xlsx(tagged_pharma_data_file) 
}
#%>%
  # janitor::clean_names() %>%
  # mutate(
  #   tags = janitor::make_clean_names(str_replace(tags,"GSK;","a;GSK;"), sep_in = ";", allow_dupes = T),
  #   tags = str_replace_all(str_replace_all(tags,"\\.\\.",";"),"\\.","_"),
  #   tags = str_replace_all(tags,"a_gsk", "gsk"),
  #   #tag_list = str_split(tags, ";"),
  #   covidence = str_replace(covidence,"#","N"))

# count how many studies there are
nstudies = sum(nchar(tagged_data_import$Study)>0)

is_nct = function(tags){
  str_detect(tags,"NCT number") & !str_detect(tags,"No NCT number")
}
write_csv(data.frame(), "added_tags.csv", append=F)
write_csv(data.frame("added_tag"), "added_tags.csv", append=T)


add_tags = function(tags, author="", year="", cov_no=""){
  print(glue("Paper:{cov_no}: {author}, ({year})"))
  #browser()
  # need to fix deussart vax 24 - dont add infant efficacy tag for dieussart 2024
  if ((cov_no == "#279") | (author == "Dieussaert" & year == 2024)){
    tags = paste0(tags,"; 1_infants_efficacy; 2_maternal_active_immunogenicity")
  } else if ((cov_no == "#1157") | (author == "Simões" & year == 2022)) { # dont add maternal efficacy tag for simoes 2024
    tags = paste0(tags,"; 1_infants_passive_immunogenicity; 1_infants_efficacy; 2_maternal_active_immunogenicity")
  }
  else {
    if (str_detect(tags,"infants") | str_detect(tags, "under") | str_detect(tags, "year")){
      if(str_detect(tags,"immunogenicity") & !str_detect(tags,"GSK")) { # not GSV vaccine
        tags = paste0(tags,"; 1_infants_passive_immunogenicity")
      } else if (str_detect(tags,"immunogenicity") & str_detect(tags,"GSK")) { # GSK vaccine
        tags = paste0(tags,"; 1_infants_active_immunogenicity")
      }
      if(str_detect(tags,"efficacy")) {
        tags = paste0(tags,"; 1_infants_efficacy")
      }
    }
    if (str_detect(tags,"maternal")){
      if(str_detect(tags,"immunogenicity")) {
        tags = paste0(tags,"; 2_maternal_active_immunogenicity")
      }
      if(str_detect(tags,"efficacy")) {
        tags = paste0(tags,"; 2_maternal_efficacy")
      }
    }
    if (str_detect(tags,"general adults") |str_detect(tags,"; adults")){
      if(str_detect(tags,"immunogenicity")) {
        if(str_detect(tags, "monoclonal")) {
          tags = paste0(tags,"; 3_general_adults_passive_immunogenicity")
        } else {
          tags = paste0(tags,"; 3_general_adults_active_immunogenicity")
        }
      }
      if(str_detect(tags,"efficacy")) {
        tags = paste0(tags,"; 3_general_adults_efficacy")
      }
    }
    if (str_detect(tags,"older adults")){
      if(str_detect(tags,"immunogenicity")) {
        tags = paste0(tags,"; 4_older_adults_active_immunogenicity")
      }
      if(str_detect(tags,"efficacy")) {
        tags = paste0(tags,"; 4_older_adults_efficacy")
      }
    }
  }
  
  # Now add the product type and manufacturer tag
  product_information_tags = c("monoclonal antibody","live-attenuated","protein subunit","viral vector","combination vaccine","mRNA","virus-like particles","protein based particle/subunit vaccine","recombinant vector vaccine","chimeric vaccine","formalin inactivated vaccine","nucleic acid vaccine","formalin inactivated")
  names(product_information_tags) = product_information_tags
  retired_tags = c("protein based particle/subunit vaccine","recombinant vector vaccine","chimeric vaccine","nucleic acid vaccine")
  names(product_information_tags)[product_information_tags %in% retired_tags] = c("protein subunit", "viral vector", "other", "mRNA")
  product_tag_matches = names(product_information_tags)[str_detect(tags, product_information_tags)]
  #product_tag_matches = product_information_tags[str_detect(tags, product_information_tags)]
  product_tag = if (length(product_tag_matches) > 0) product_tag_matches[which.max(nchar(product_tag_matches))] else NA
  manufacturer_tags = c("Pfizer","Novavax","GSK","AstraZeneca-Sanofi","Moderna","Janssen","Bavarian Nordic","MedImmune","Sanofi","AstraZeneca","Merck","Sanofi/LID/NIAID/NIH","Sanofi/NIAID/NIH","NIH","NIAID/NIH/MedImmune","NIH/NIAID/VRC","NIAID/NIH","NIAID","Pontificia Universidad Católica de Chile","Virtuvax","Virometix","Blue Lake Biotechnology Inc","Intravacc","Lederle Praxis Biologicals","NIH/Wyeth Vaccines","Praxis Biologics","Wyeth-Lederle Vaccine and Pediatrics","IDT Biologika","Mucosis")
  manufacturer_tag_matches = manufacturer_tags[str_detect(tags, manufacturer_tags)]
  manufacturer_tag = if (length(manufacturer_tag_matches) > 0) manufacturer_tag_matches[which.max(nchar(manufacturer_tag_matches))] else NA
  added_tag = glue("{product_tag}:{manufacturer_tag}")
  #print(added_tag)
  
  #write_csv(data.frame(added_tag), "added_tags.csv", append=T)
  #added_tags = c(added_tags, added_tag)
  tags = paste0(tags,"; ",added_tag)
  
  # Now add the RCT / NCT tag
  nct_types = c("No NCT number","NCT number") 
  rct_types = c("Not RCT","Possible RCT","RCT")
  nct_tag = if(grepl(nct_types[1],tags)) nct_types[1] else if(grepl(nct_types[2],tags)) nct_types[2] else "NA"
  rct_tag = if(grepl(rct_types[1],tags)) rct_types[1] else if(grepl(rct_types[2],tags)) rct_types[2] else if(grepl(rct_types[3],tags)) rct_types[3] else "NA"
  added_tag = glue("{nct_tag}:{rct_tag}")
  
  
  # Now add the approval tag
  approval_tags = c("approved","not approved","approval unknown")
  approval_tag_matches = approval_tags[str_detect(tags, approval_tags)]
  approval_tag = if (length(approval_tag_matches) > 0) approval_tag_matches[which.max(nchar(approval_tag_matches))] else NA
  added_tag = glue("{product_tag}:{approval_tag}")
  print(added_tag)
  write_csv(data.frame(added_tag), "added_tags.csv", append=T)
  tags = paste0(tags,"; ",added_tag)
  tags
}

tagged_data = tagged_data_import[c(1:nstudies),] %>%
  rowwise() %>%
  mutate(Tags = add_tags(Tags, sub(",.*$", "", Authors), `Published Year`, `Covidence #`),
         is_nct = is_nct(Tags)) %>%
  #filter(is_nct) %>%
  select(-is_nct)
write.csv(tagged_data, edited_tagged_file, row.names = F)
#all_tags = unique(unlist(c(tagged_data$tag_list)))
