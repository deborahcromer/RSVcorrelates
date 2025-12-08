

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

retagged_data = tagged_data_import[c(1:nstudies),] %>%
  rowwise() %>%
  mutate(Tags = add_tags(Tags, sub(",.*$", "", Authors), `Published Year`, `Covidence #`),
         is_nct = is_nct(Tags)) %>%
  #filter(is_nct) %>%
  select(-is_nct)
write.csv(retagged_data, edited_tagged_file, row.names = F)
#all_tags = unique(unlist(c(tagged_data$tag_list)))
