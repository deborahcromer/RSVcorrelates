
neut_plot = ggplot(rsv_neuts, aes(x=time, y=norm_neut, group = paste0(Variant,Trial,Group,Agegroup, paper_id), colour = paste(Trial,Group),fill = paste(Trial,Group)))+
  geom_point(aes(shape = Immunisation), size = ps)+
  geom_line(aes(linetype = agegp), linewidth = lw)+
  theme_bw() +
  scale_colour_manual(name = "Trial / Group", values = neut_colours)+
  scale_fill_manual(name = "Trial / Group", values = neut_colours)+
  scale_y_log10()+
  scale_linetype_manual(name = "Age-group", values = age_linestyles) + 
  scale_shape_manual(values = manufacturer_shapes) +
  labs(x="Time (days)", y = "Normalised Neuts (ratio of placebo at t=0)", title = "Neutralisation Titre over time") +
  rsv_plot_theme
ggsave("./output/plots/01_NormalisedNeuts.pdf", width = w, height = h)


neut_plot_facet = neut_plot +
  facet_wrap(~factor(ifelse(agegp=="infants", "Infants","Adults"), levels = c("Infants", "Adults")))
ggsave("./output/plots/01a_NormalisedNeuts_Facetted.pdf", width = w*1.5, height = h)


neut_eff_plot = ggplot(filter(rsv_summary_full, ab_variant=="Combined", !is.na(outcome)), aes(x=norm_neut, y=VE, colour=Immunisation, linetype = agegp))+
  geom_point(size = ps)+
  geom_errorbar(aes(ymin = lowerVE, ymax=upperVE),linewidth = lw)+
  theme_bw() +
  scale_colour_manual(name = "Immunisation Type", values = immunisation_colours)+
  scale_x_log10()+
  labs(x="Normalised Neuts (ratio of placebo at t=0)", y = "Efficacy", title = "Correlation between Efficay and Neutralisation Titres") +
  scale_linetype_manual(name = "Age-group", values = age_linestyles) + 
  facet_wrap(~outcome, drop=T) +
  coord_cartesian(y=c(-10,100)) +
  rsv_plot_theme
ggsave("./output/plots/02_NormalisedNeuts_vs_Efficacy.pdf", width = w*1.3, height = h)

neut_eff_plot_restricted = neut_eff_plot +
  coord_cartesian(xlim = c(1,15))
ggsave("./output/plots/02a_NormalisedNeuts_vs_Efficacy_Restricted.pdf", width = w*1.3, height = h)


neut_eff_plot_facet = neut_eff_plot +
  facet_grid(factor(ifelse(agegp=="infants", "Infants","Adults"), levels = c("Infants", "Adults"))~outcome, switch = "y")
ggsave("./output/plots/02b_NormalisedNeuts_vs_Efficacy_Facetted.pdf", width = w*1.3, height = h*1.2)

neut_eff_plot_facet_restricted = neut_eff_plot_facet +
  coord_cartesian(xlim = c(1,15))
ggsave("./output/plots/02c_NormalisedNeuts_vs_Efficacy_Facetted_Restricted.pdf", width = w*1.3, height = h*1.2)

