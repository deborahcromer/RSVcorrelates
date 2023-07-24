
neut_plot = ggplot(rsv_neuts, aes(x=time, y=norm_neut, colour = paste(Trial,Group)))+
  geom_point()+
  geom_line(aes(linetype = Variant))+
  theme_bw() +
  scale_colour_manual(values = neut_colours)+
  scale_y_log10()+
  labs(x="Time (days)", y = "normalised neuts") 
  
#+
 # scale_linetype_manual(values = variant_linestyles)

ggsave("./output/plots/01_NormalisedNeuts.pdf", width = w, height = h)

neut_eff_plot = ggplot(filter(rsv_summary_full, Variant.x=="Combined"), aes(x=norm_neut, y=VE, colour=Immunisation, linetype = agegp))+
  geom_point()+
  geom_errorbar(aes(ymin = lowerVE, ymax=upperVE))+
  theme_bw() +
  scale_colour_manual(values = immunisation_colours)+
  scale_x_log10()+
  labs(x="Normalised Neuts", y = "Efficacy") +
  facet_grid(~outcome)
  
ggsave("./output/plots/02_NormalisedNeuts_vs_Efficacy.pdf", width = w, height = h)
  
