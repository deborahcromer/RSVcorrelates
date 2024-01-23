decay_values =  rsv_neuts %>%
  filter(time >0 | (time==0 &  agegp == "infants" & Drug != "AZ-S")) %>%
  group_by(Variant,Trial,Group,agegp, paper_id) %>%
  mutate(decay  = lm(norm_neutL~time)$coefficients[2]) %>%
  select(-c("Agegroup","time","neut","neutL","norm_neut","norm_neutL")) %>%
  distinct()

decay_plot = ggplot(decay_values, aes(x=agegp, y = decay, colour = paste(Trial,Group))) +
  geom_point(size = ps) + 
  stat_compare_means(comparisons = list(c(1,2),c(2,3),c(1,3))) +
  scale_colour_manual(name = "Trial / Group", values = neut_colours) + 
  labs(x="Cohort", y = "Decay Rate of Normalised Neuts", title = "Neutralising Antibody Decay") +
  rsv_plot_theme
  
ggsave("./output/plots/21_NeutDecay.pdf", width = w*1.1, height = h)
