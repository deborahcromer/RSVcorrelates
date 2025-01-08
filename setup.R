library(iaputils)
library(readxl)
library(dplyr)
library(data.table)
library(stringr)
library(ggplot2)
library(ggpubr)
library(glue)


# get the username
username = str_extract(getwd(),"Users/[A-Za-z0-9. _]+/") %>%
  str_sub(nchar("Users/")+1, nchar(.)-1)

RSV_data_file = "./raw-data/RSV Data 2024.xlsx"
shared_rsv_folder = glue("~/../{username}/Library/CloudStorage/OneDrive-SharedLibraries-UNSW/Vaccine Abs and Efficacy - Documents/28_RSV")
tagged_data_file = glue("{shared_rsv_folder}/List of included vax_mAb studies.csv")
tagged_pharma_data_file = "./raw-data/rsv_studies_tagged_with_pharma_csv_20250108125559.csv"
tagged_data_file_output = glue("{shared_rsv_folder}/Editied List of included vax_mAb studies.csv")

tag_cols = c("study","covidence","authors","journal","published_year","doi","accession_number","title","tags")


tag_list_names = c( "nct_number","immunogenicity","efficacy_effectiveness", "adults", "older_adults", "maternal", "infants_children",
                    "vaccine", "immunoprophylaxis", "monoclonal_antibody" , "live_attenuated_chimeric_vaccine", "protein_based_particle_subunit_vaccine", 
                    "recombinant_vector_vaccine",
                    "pfizer", "novavax" , "gsk", "astra_zeneca_sanofi", "sanofi", "janssen_pharmaceuticals", "bavarian_nordic", "med_immune",
                    "sanofi_lid_niaid_nih", "sanofi_niaid_nih",  "niaid_nih_med_immune", "nih_niaid_vrc",  "niaid_nih", "niaid", 
                    "pontificia_universidad_catolica_de_chile", "virtuvax", "virometix", "blue_lake_biotechnology_inc")                                                                     
                    
antibody_sheet = "Antibodies"
antibody_range = "A1:P1000"
ab_eff_sheet = "ab_eff"
ab_eff_range = "A1:M1000"

neut_colours = c("Pfizer Elderly RSVA/B" = "lightgreen",
                 "Pfizer infants RSVA/B" = "seagreen",
                 "Pfizer infants combined" = "darkgreen",         
                 "Pfizer maternal combined" = "darkblue",
                 "AzSanofi infants Phase2b" = "purple",
                 "AzSanofi infants MELODY" = "mediumpurple1",
                 "J&J elderly JJ" = "magenta",
                 "Novavax infants" = "gold1",
                 "Novavax mothers" = "gold3",
                 "Novavax women" = "goldenrod3",
                 "Novavax elderly" = "orange4",
                 "Moderna elderly" = "tomato",
                 "BavarianNordic low dose (only)" = "pink",
                 "BavarianNordic low dose (+later dose)" = "pink2",
                 "BavarianNordic high dose (only)" = "pink3",
                 "BavarianNordic high dose (+later dose)" = "pink4" 
                   )

immunisation_colours = c("Ad26.RSV.preF"="magenta",
                         "Pfizer"="green4",
                         "AzSanofi" = "purple",
                         "Novavax" = "goldenrod",
                         "GSK" = "cyan",
                         "Moderna" = "tomato",
                         "Bavarian Nordic" = "pink" )

variant_linestyles = c("combined A/B" = "-",
                      "RSVA" = "--",
                      "RSVB"=".")
manufacturer_shapes = c(20:25,13)
names(manufacturer_shapes) = c("AzSanofi","J&J","Moderna","Novavax","Pfizer","BavarianNordic")

w = 8
h=6
lw = 1.5
ps = 4

outcome_levels = c("Symptomatic","Moderate","Severe")
age_levels = c("infants", "elderly","maternal")

age_linestyles = c("solid","dashed","dotted")
names(age_linestyles) = age_levels

rsv_plot_theme = theme_bw() + 
  theme(text = element_text(size=18), 
        legend.title = element_text(size=14),
        legend.text = element_text(size=10),
        legend.key.size = unit(12, units = "pt"),
        legend.spacing = unit(2,units="pt"),
        strip.background = element_rect(fill="white", colour="white"),
        strip.text = element_text(face="bold"),
        strip.placement = "outside")
