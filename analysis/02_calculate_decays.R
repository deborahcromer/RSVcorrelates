decay_values =  rsv_neuts %>%
  filter(time >0 | time==0 &  agegp == "infants" & Drug == "AZ-S") %>%
  group_by(Variant,Trial,Group,agegp, paper_id) %>%
  mutate(decay  = lm(norm_neutL~time)$coefficients[2]) %>%
  select(-c("Agegroup","time","neut","neutL","norm_neut","norm_neutL")) %>%
  distinct()