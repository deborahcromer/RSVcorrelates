
neut_plot = ggplot(rsv_neuts, aes(x=time, y=norm_neut, colour = paste(Trial,Group)))+
  geom_point()+
  geom_line(aes(linetype = Variant))+
  theme_bw() +
  scale_colour_manual(name = "Trial / Group", values = neut_colours)+
  scale_y_log10()+
  labs(x="Time (days)", y = "Normalised Neuts (ratio of placebo at t=0)", title = "Neutralisation Titre over time") 
  
#+
 # scale_linetype_manual(values = variant_linestyles)

ggsave("./output/plots/01_NormalisedNeuts.pdf", width = w*.7, height = h*.7)

neut_eff_plot = ggplot(filter(rsv_summary_full, ab_variant=="Combined"), aes(x=norm_neut, y=VE, colour=Immunisation, linetype = agegp))+
  geom_point()+
  geom_errorbar(aes(ymin = lowerVE, ymax=upperVE))+
  theme_bw() +
  scale_colour_manual(name = "Immunisation Type", values = immunisation_colours)+
  scale_x_log10()+
  labs(x="Normalised Neuts (ratio of placebo at t=0)", y = "Efficacy", title = "Correlation between Efficay and Neutralisation Titres") +
  scale_linetype(name = "Age-group") + 
  facet_grid(~outcome) +
  coord_cartesian(y=c(-10,100))
  
ggsave("./output/plots/02_NormalisedNeuts_vs_Efficacy.pdf", width = w*1, height = h*.7)
  
