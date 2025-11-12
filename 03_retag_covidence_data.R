tagged_data_import = read.csv(tagged_pharma_data_file) #%>%
  # janitor::clean_names() %>%
  # mutate(
  #   tags = janitor::make_clean_names(str_replace(tags,"GSK;","a;GSK;"), sep_in = ";", allow_dupes = T),
  #   tags = str_replace_all(str_replace_all(tags,"\\.\\.",";"),"\\.","_"),
  #   tags = str_replace_all(tags,"a_gsk", "gsk"),
  #   #tag_list = str_split(tags, ";"),
  #   covidence = str_replace(covidence,"#","N"))

# count how many studies there are
nstudies = sum(nchar(tagged_data_import$Study)>0)

tagged_data = tagged_data_import[c(1:nstudies),] %>%
  rowwise() %>%
  mutate(Tags = add_tags(Tags),
         is_nct = is_nct(Tags))
%>%
  filter(is_nct)
all_tags = unique(unlist(c(tagged_data$tag_list)))

is_nct = function(tags){
  str_detect(tags,"NCT number") & !str_detect(tags,"No NCT number")
}
add_tags = function(tags){
  #browser()
  if (str_detect(tags,"infants")){
    if(str_detect(tags,"immunogenicity")) {
      tags = paste0(tags,";1_infants_immunogenicity")
    }
    if(str_detect(tags,"efficacy")) {
      tags = paste0(tags,";1_infants_efficacy")
    }
  }
  if (str_detect(tags,"maternal")){
    if(str_detect(tags,"immunogenicity")) {
      tags = paste0(tags,";2_maternal_immunogenicity")
    }
  }
  if (str_detect(tags,"general adults")){
    if(str_detect(tags,"immunogenicity")) {
      tags = paste0(tags,";3_general_adults_immunogenicity")
    }
    if(str_detect(tags,"efficacy")) {
      tags = paste0(tags,";3_general_adults_efficacy")
    }
  }
  if (str_detect(tags,"older adults")){
    if(str_detect(tags,"immunogenicity")) {
      tags = paste0(tags,";4_older_adults_immunogenicity")
    }
    if(str_detect(tags,"efficacy")) {
      tags = paste0(tags,";4_older_adults_efficacy")
    }
  }
  tags
}
