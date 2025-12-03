
import_file = tagged_pharma_data_file
import_file = edited_tagged_file
if(grepl("csv$",import_file)) {
  tagged_data_import = read.csv(import_file) 
} else if (grepl("xlsx$",import_file)) {
  tagged_data_import = read_xlsx(import_file) 
}

tagged_data = tagged_data_import %>%
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
nstudies = sum(nchar(tagged_data$tags)>0)

tagged_data = tagged_data[c(1:nstudies),]

tag_list = NULL
for (r in c(1:nrow(tagged_data))){
  current_tags = tagged_data$tag_list[r][[1]]
  
  for (t in current_tags){
    this_tag_ind = which(names(tag_list)==t) 
    # if this tag isnt already in the list
    #if(length(this_tag_ind)==0){
    #  tag_list[[t]]=tagged_data$study[r]
    #} else {
      tag_list[[t]]=c(tag_list[[t]],tagged_data$covidence[r])
    #}
  }
}


tagged_study_dataframe = tagged_data %>% janitor::clean_names() %>% select(any_of(tag_cols))
ntagged_cols = ncol(tagged_study_dataframe)

for(tag in sort(names(tag_list))) {
  tagged_study_dataframe = cbind(tagged_study_dataframe,str_detect(tagged_study_dataframe$tags, tag))
}
names(tagged_study_dataframe)[c((ntagged_cols+1):ncol(tagged_study_dataframe))] = sort(names(tag_list))
tagged_study_dataframe = tagged_study_dataframe %>% 
  janitor::clean_names() %>%
  mutate(any_adult = adults | older_adults | maternal)

tagged_study_dataframe_for_output = tagged_study_dataframe %>%
  select("study","covidence",any_of(c(starts_with("1"), starts_with("2"), starts_with("3"), starts_with("4"), contains("approved"), contains("nct"))))

write.csv(tagged_study_dataframe_for_output, tagged_data_file_output, row.names=F)

tagged_study_dataframe_by_tag = tagged_study_dataframe %>%
  tidyr::pivot_longer(cols=tolower(names(tag_list)), names_to = "tag") %>%
  filter(value==T) %>% 
  mutate(#tag = factor(tag, tag_list_names),
         tag_type_dummy = !is.na(sapply(tag_list_groups, FUN = match, x=tag)),
         tag_type = NA)

for (r in c(1:nrow(tagged_study_dataframe_by_tag))){
  tagged_study_dataframe_by_tag$tag_type[r] = names(tag_list_groups)[tagged_study_dataframe_by_tag$tag_type_dummy[r,]]
}
tagged_study_dataframe_by_tag = tagged_study_dataframe_by_tag %>%
  select(-c("tag_type_dummy", "value"))

tagged_study_dataframe_grouped = tagged_study_dataframe_by_tag %>%
   tidyr::pivot_wider(names_from = "tag_type", values_from = tag)

write.csv(tagged_study_dataframe_grouped_for_output, tagged_data_file_grouped_output, row.names=F)


ggplot(tagged_study_dataframe_by_tag, aes(y = tag, fill = tag_type)) +
  geom_bar() + 
  theme_bw()


ggplot()
  



