rsv_data = read_xlsx(path="./raw-data/RSV Data.xlsx", sheet = "Sheet1", range = "A1:M1000") %>%
  as.data.table() %>%
  filter(!is.na(Trial)) %>%
  select(-c(normalisedNab)) 

rsv_neuts = rsv_data %>%
  filter(!is.na(NabVal)) %>%
  data.table::dcast(Trial+Group+Type+Drug+TimeRelTo+Variant+Time~Treatment, value.var = c("NabVal")) %>%
  right_join(filter(rsv_data[,c("Trial","Group","Type","Drug","Time","TimeRelTo","Variant","Treatment","NabVal")],Time==0, !is.na(NabVal), Treatment=="placebo"), 
        by = c("Trial","Group","Type","Drug","TimeRelTo","Variant"),by.y = c("Trial","Group","Type","Drug","TimeRelTo","Variant") ) %>%
  mutate(time = Time.x,
         neut = drug,
         neutL = log10(neut),
         norm_neut = drug/NabVal, 
         norm_neutL = log10(norm_neut)
         ) %>%
  select(-c(Treatment, placebo, NabVal, drug, Time.y, Time.x))

rsv_summary_data =  read_xlsx(path="./raw-data/RSV Data.xlsx", sheet = "Sheet2", range = "A1:K1000") %>%
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
                             by=c("Immunisation", "agegp"))