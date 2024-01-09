library(iaputils)
library(readxl)
library(dplyr)
library(data.table)
library(ggplot2)

neut_colours = c("Pfizer Elderly E" = "lightgreen",
                 "Pfizer infants B" = "seagreen",
                 "Pfizer infants D" = "darkgreen",         
                 "Pfizer maternal A" = "darkblue",
                 "AzSanofi infants Phase2b" = "purple",
                 "AzSanofi infants MELODY" = "mediumpurple1",
                 "J&J elderly JJ" = "magenta",
                 "Novavax infants" = "goldenrod1",
                 "Novavax mothers" = "goldenrod3",
                 "Novavax elderly" = "goldenrod4")

immunisation_colours = c("Ad26.RSV.preF"="magenta",
                         "Pfizer"="green4",
                         "Az-S" = "purple",
                         "Novavax" = "goldenrod",
                         "GSK" = "cyan",
                         "Moderna" = "tomato",
                         "Bavarian Nordic" = "pink" )

variant_linestyles = c("combined A/B" = "-",
                      "RSVA" = "--",
                      "RSVB"=".")

w = 8
h=6

outcome_levels = c("Symptomatic","Moderate","Severe")
age_levels = c("Infant", "Elderly")