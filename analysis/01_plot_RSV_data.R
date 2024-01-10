
neut_plot = ggplot(rsv_neuts, aes(x=time, y=norm_neut, group = paste0(Variant,Trial,Group,Agegroup), colour = paste(Trial,Group)))+
  geom_point(aes(shape = Immunisation))+
  geom_line(aes(linetype = agegp))+
  theme_bw() +
  scale_colour_manual(name = "Trial / Group", values = neut_colours)+
  scale_y_log10()+
  scale_linetype_manual(name = "Age-group", values = age_linestyles) + 
  labs(x="Time (days)", y = "Normalised Neuts (ratio of placebo at t=0)", title = "Neutralisation Titre over time") 

ggsave("./output/plots/01_NormalisedNeuts.pdf", width = w, height = h)

neut_eff_plot = ggplot(filter(rsv_summary_full, ab_variant=="Combined", !is.na(outcome)), aes(x=norm_neut, y=VE, colour=Immunisation, linetype = agegp))+
  geom_point()+
  geom_errorbar(aes(ymin = lowerVE, ymax=upperVE))+
  theme_bw() +
  scale_colour_manual(name = "Immunisation Type", values = immunisation_colours)+
  scale_x_log10()+
  labs(x="Normalised Neuts (ratio of placebo at t=0)", y = "Efficacy", title = "Correlation between Efficay and Neutralisation Titres") +
  scale_linetype_manual(name = "Age-group", values = age_linestyles) + 
  facet_wrap(~outcome, drop=T) +
  coord_cartesian(y=c(-10,100))
  
ggsave("./output/plots/02_NormalisedNeuts_vs_Efficacy.pdf", width = w, height = h)
  
