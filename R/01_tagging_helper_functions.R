is_nct = function(tags){
  str_detect(tags,"NCT number") & !str_detect(tags,"No NCT number")
}
write_csv(data.frame(), "added_tags.csv", append=F)
write_csv(data.frame("added_tag"), "added_tags.csv", append=T)


add_tags = function(tags, author="", year="", cov_no=""){
  print(glue("Paper:{cov_no}: {author}, ({year})"))
  #browser()
  # need to fix Dieussaert vax 24 - dont add infant efficacy tag for dieussart 2024
  if (!anyNA(c(cov_no, author, year)) && (cov_no == "#279" || (author == "Dieussaert" && as.character(year) == "2024"))){
    tags = paste0(tags,"; 1_infants_efficacy; 2_maternal_active_immunogenicity; pop_infants_children; pop_maternal")
  } else if ((author == "Munjal") || 
             (startsWith(author, "Sim") && as.character(year) == "2022") ||
             (author == "Banooni" && as.character(year) == "2025") ||
             (startsWith(author, "Sim") && as.character(year) == "2025")){
                                                   # dont add maternal efficacy tag for simoes 2022/2025, Banooni and Munjal
    print(glue("No maternal eff"))
    tags = paste0(tags,"; 1_infants_passive_immunogenicity; 1_infants_efficacy; 2_maternal_active_immunogenicity; pop_infants_children; pop_maternal")
  } else {
    if (str_detect(tags,"infants") | str_detect(tags, "under") | str_detect(tags, "year")){
      tags = paste0(tags,"; pop_infants_children")
      if(str_detect(tags,"immunogenicity") && str_detect(tags,"inf_child_passively_acquired")) { # not GSV vaccine
        tags = paste0(tags,"; 1_infants_passive_immunogenicity")
      } else if (str_detect(tags,"immunogenicity") && str_detect(tags,"inf_child_actively_acquired")) { # GSK vaccine
        tags = paste0(tags,"; 1_infants_active_immunogenicity")
      } 
      if(str_detect(tags,"efficacy")) {
        tags = paste0(tags,"; 1_infants_efficacy")
      }
    }
    if (str_detect(tags,"maternal")){
      tags = paste0(tags,"; pop_maternal")
      if(str_detect(tags,"immunogenicity")) {
        tags = paste0(tags,"; 2_maternal_active_immunogenicity")
      }
      if(str_detect(tags,"efficacy")) {
        tags = paste0(tags,"; 2_maternal_efficacy")
      }
    }
    if (str_detect(tags,"general adults") |str_detect(tags,"; adults")){
      tags = paste0(tags,"; pop_general")
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
      tags = paste0(tags,"; pop_older")
      if(str_detect(tags,"immunogenicity")) {
        tags = paste0(tags,"; 4_older_adults_active_immunogenicity")
      }
      if(str_detect(tags,"efficacy")) {
        tags = paste0(tags,"; 4_older_adults_efficacy")
      }
    }
  }
  if(!is.na(year) && (year < 2013)){
    year_tag = "pre_2013"
  } else {
    year_tag = "post_2013"
  }
  tags = paste0(tags,"; ",year_tag)
  
  if(str_detect(tags,"active_immunogenicity")) {
    tags = paste0(tags,"; active_immunogenicity")
  }
  if(str_detect(tags,"passive_immunogenicity")) {
    tags = paste0(tags,"; passive_immunogenicity")
  }
  if(str_detect(tags,"efficacy")) {
    tags = paste0(tags,"; efficacy")
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
  added_tag = glue("{nct_tag}:{year_tag}")
  tags = paste0(tags,"; ",added_tag)
  
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