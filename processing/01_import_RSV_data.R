rsv_data = read_xlsx(path=RSV_data_file, sheet = antibody_sheet, range = antibody_range) %>%
  as.data.table() %>%
  filter(!is.na(Trial)) %>%
  select(-c(normalisedNab)) 

rsv_neuts = rsv_data %>%
  filter(!is.na(NabVal)) %>%
  data.table::dcast(paper_id+Trial+Immunisation+Agegroup+Group+Type+Drug+TimeRelTo+Variant+Time~Treatment, value.var = c("NabVal")) %>%
  right_join(filter(rsv_data[,c("paper_id","Trial","Group","Immunisation","Agegroup","Type","Drug","Time","TimeRelTo","Variant","Treatment","NabVal")],Time==0, !is.na(NabVal), Treatment=="placebo"), 
        by = c("paper_id","Trial","Immunisation","Agegroup","Group","Type","Drug","TimeRelTo","Variant")) %>%
  mutate(time = Time.x,
         neut = drug,
         neutL = log10(neut),
         norm_neut = drug/NabVal, 
         norm_neutL = log10(norm_neut),
         agegp = factor(Agegroup, levels = age_levels)) %>%
  select(-c(Treatment, placebo, NabVal, drug, Time.y, Time.x))

rsv_summary_data =  read_xlsx(path=RSV_data_file, sheet = ab_eff_sheet, range = ab_eff_range) %>%
  as.data.table() %>%
  filter(!is.na(Immunisation)) %>%
  mutate(
    neut = PeakAb,
    neutL = log10(neut),
    norm_neut = PeakAb/PlaceboAb, 
    norm_neutL = log10(norm_neut),
    outcome = factor(EfficacyType, levels = outcome_levels),
    agegp = factor(Agegroup, levels = age_levels)
  ) %>%
  select(-c(PeakAb, PlaceboAb, EfficacyType, Agegroup))

rsv_summary_neuts = rsv_summary_data %>%
  filter(!is.na(neut)) %>%
  select(-c("VE","lowerVE", "upperVE","outcome","Duration")) 

rsv_summary_eff = rsv_summary_data %>%
  filter(!is.na(VE)) %>%
  select(-c("neut", "neutL", "norm_neut", "norm_neutL"))

rsv_summary_full = full_join(rsv_summary_neuts, rsv_summary_eff,
                             by=c("Immunisation", "agegp"),
                             relationship = "many-to-many") %>%
  rename(ab_variant = Variant.x,
         ab_study = Study.x,
         eff_variant = Variant.y,
         eff_study = Study.y)