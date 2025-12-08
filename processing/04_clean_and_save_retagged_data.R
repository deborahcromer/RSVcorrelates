
retagged_data_cleaned = retagged_data %>%
  janitor::clean_names() %>%
  rowwise() %>%
  mutate(
    tags = janitor::make_clean_names(str_replace(tags,"GSK;","a;GSK;"), sep_in = ";", allow_dupes = T),
    tags = str_replace_all(str_replace_all(tags,"\\.\\.",";"),"\\.","_"),
    tags = str_replace_all(tags,"a_gsk", "gsk"),
    tag_list = str_split(tags, ";"),
    covidence = pick(starts_with("covidence")),  # the first existing among covidence, covidence_number
    covidence = str_replace(covidence,"#","N"))

# count how many studies there are
tag_list = NULL
for (r in c(1:nrow(retagged_data_cleaned))){
  current_tags = retagged_data_cleaned$tag_list[r][[1]]
  
  for (t in current_tags){
    this_tag_ind = which(names(tag_list)==t) 
    # if this tag isnt already in the list
    #if(length(this_tag_ind)==0){
    #  tag_list[[t]]=retagged_data_cleaned$study[r]
    #} else {
      tag_list[[t]]=c(tag_list[[t]],retagged_data_cleaned$covidence[r])
    #}
  }
}


# tagged_study_dataframe = retagged_data_cleaned %>% 
#   janitor::clean_names() %>% 
#   select(any_of(tag_cols))
ntagged_cols = ncol(retagged_data_cleaned)


for(tag in sort(names(tag_list))) {
  if(str_detect(tag,"2000")){
    print(glue("Timeframe: {tag}"))
  }
  retagged_data_cleaned = cbind(retagged_data_cleaned,(str_detect(retagged_data_cleaned$tags, paste0(";",tag)) | startsWith(retagged_data_cleaned$tags, tag)))
}
names(retagged_data_cleaned)[c((ntagged_cols+1):ncol(retagged_data_cleaned))] = sort(names(tag_list))
retagged_data_cleaned = retagged_data_cleaned %>% 
  #janitor::clean_names() %>%
  mutate(any_adult = if_any(c(any_of(c("adults", "older_adults", "maternal"))), ~ . == TRUE))

tagged_study_dataframe_for_output = retagged_data_cleaned %>%
  select("study","covidence","passive_immunogenicity","active_immunogenicity","efficacy", "nct_number","no_nct_number",any_of(c(starts_with("1"), starts_with("2"), starts_with("3"), starts_with("4"), contains("approved"), contains("2000"))))

write.csv(tagged_study_dataframe_for_output, tagged_data_file_output_split_by_tag, row.names=F)

do_grouped_tagging = F
if (do_grouped_tagging){
  retagged_data_cleaned_by_tag = retagged_data_cleaned %>%
    tidyr::pivot_longer(cols=tolower(names(tag_list)), names_to = "tag") %>%
    filter(value==T) %>% 
    mutate(#tag = factor(tag, tag_list_names),
           tag_type_dummy = !is.na(sapply(tag_list_groups, FUN = match, x=tag)),
           tag_type = NA)
  
  for (r in c(1:nrow(retagged_data_cleaned_by_tag))){
    retagged_data_cleaned_by_tag$tag_type[r] = names(tag_list_groups)[retagged_data_cleaned$tag_type_dummy[r,]]
  }
  retagged_data_cleaned = retagged_data_cleaned %>%
    select(-c("tag_type_dummy", "value"))
  
  retagged_data_grouped = retagged_data_cleaned %>%
     tidyr::pivot_wider(names_from = "tag_type", values_from = tag)
  
  write.csv(retagged_data_grouped_for_output, tagged_data_file_grouped_output, row.names=F)
  
  
  ggplot(retagged_data_cleaned, aes(y = tag, fill = tag_type)) +
    geom_bar() + 
    theme_bw()
  
  
  ggplot()
}    
  
  
  
