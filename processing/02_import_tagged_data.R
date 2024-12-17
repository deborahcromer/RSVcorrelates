tagged_data = read.csv(tagged_data_file) %>%
  janitor::clean_names() %>%
  mutate(tag_list = str_split(tags, "; "),
         covidence = str_replace(covidence,"#","N"))

# count how many studies there are
nstudies = sum(nchar(tagged_data$study)>0)

tagged_data = tagged_data[c(1:nstudies),]

tag_list = NULL
for (r in c(1:nrow(tagged_data))){
  current_tags = tagged_data$tag_list[r][[1]]
  #Only look at tags for studies with an NCT number
  if ("NCT number" %in% current_tags) {
    for (t in current_tags){
      this_tag_ind = which(names(tag_list)==t) 
      # if this tag isnt already in the list
      #if(length(this_tag_ind)==0){
      #  tag_list[[t]]=tagged_data$study[r]
      #} else {
        tag_list[[t]]=c(tag_list[[t]],tagged_data$covidence[r])
      #}
    }
  }
}

library(RColorBrewer)
myCol = brewer.pal(6, "Pastel2")
names(myCol) = c("adults","older adults","infants/children","maternal","immunogenicity","efficacy/effectiveness")

use_tags = c("adults","older adults","infants/children")

VennDiagram::venn.diagram(tag_list[use_tags], filename = glue("{shared_rsv_folder}/Venn_adults_children.png"),
                          disable.logging = TRUE,
                          #output=FALSE,
                          # Output features
                          imagetype="png" ,
                          height = 1000 , 
                          width = 1000 , 
                          resolution = 600,
                          compression = "lzw",
                          
                          #Title
                          main = "All Studies\n(excl maternal)",
                          main.cex = .6,
                          main.fontface = "bold",
                          main.fontfamily = "sans",
                        
                          # Circles
                          lwd = 2,
                          lty = 'blank',
                          fill = myCol[use_tags],
                          
                          # Numbers
                          cex = .5,
                          fontface = "bold",
                          fontfamily = "sans",
                          
                          # Set names
                          cat.cex = 0.6,
                          cat.fontface = "bold",
                          cat.default.pos = "outer",
                          cat.pos = c(180, -10, 10),
                          cat.dist = c(.05, .05, .05),
                          cat.fontfamily = "sans",
                          rotation = 1, 
                          margin = 0)

use_tags = c("adults","maternal","infants/children")
VennDiagram::venn.diagram(tag_list[use_tags], filename = glue("{shared_rsv_folder}/Venn_maternal_children.png"),
                          disable.logging = TRUE,
                         # Output features
                          imagetype="png" ,
                          height = 1000 , 
                          width = 1000 , 
                          resolution = 600,
                          compression = "lzw",
                          
                         #Title
                         main = "Studies\n(excl Older Adults)",
                         main.cex = .6,
                         main.fontface = "bold",
                         main.fontfamily = "sans",
                         
                          # Circles
                          lwd = 2,
                          lty = 'blank',
                          fill = myCol[use_tags],
                          
                          # Numbers
                          cex = .5,
                          fontface = "bold",
                          fontfamily = "sans",
                          
                          # Set names
                          cat.cex = 0.6,
                          cat.fontface = "bold",
                          cat.default.pos = "outer",
                          cat.pos = c(180, 0, 200),
                          cat.dist = c(.02, .02, 0.02),
                          cat.fontfamily = "sans",
                          rotation = 1, 
                          margin = 0)

# Only consider child tags
child_studies = unique(c(tag_list[["infants/children"]]))
child_tag_list = NULL
for(t in names(tag_list)){
  child_tag_list[[t]] = tag_list[[t]][tag_list[[t]] %in% child_studies]
}

use_tags = c("efficacy/effectiveness","immunogenicity","maternal")
VennDiagram::venn.diagram(child_tag_list[use_tags], filename = glue("{shared_rsv_folder}/Venn_children_eff_imm.png"),
                          disable.logging = TRUE,
                          
                          # Output features
                          imagetype="png" ,
                          height = 1000 , 
                          width = 1000 , 
                          resolution = 600,
                          compression = "lzw",
                          
                          #Title
                          main = "Child studies",
                          main.cex = .6,
                          main.fontface = "bold",
                          main.fontfamily = "sans",
                          
                          # Circles
                          lwd = 2,
                          lty = 'blank',
                          fill = myCol[use_tags],
                          
                          # Numbers
                          cex = .5,
                          fontface = "bold",
                          fontfamily = "sans",
                          
                          # Set names
                          cat.cex = 0.5,
                          cat.fontface = "bold",
                          cat.default.pos = "outer",
                          cat.pos = c(0, 155, 0),
                          cat.dist = c(.05, 0.02, -.22),
                          cat.fontfamily = "sans",
                          rotation = 1, 
                          margin =0)

# Only consider adult tags
adult_studies = unique(c(tag_list[["maternal"]],tag_list[["older adults"]],tag_list[["adults"]]))
adult_tag_list = NULL
for(t in names(tag_list)){
  adult_tag_list[[t]] = tag_list[[t]][tag_list[[t]] %in% adult_studies]
}
use_tags = c("efficacy/effectiveness","immunogenicity","older adults")

VennDiagram::venn.diagram(adult_tag_list[use_tags], filename = glue("{shared_rsv_folder}/Venn_adults_eff_imm.png"),
                          disable.logging = TRUE,
                          main = "Adult studies",
                          main.cex = .6,
                          main.fontface = "bold",
                          main.fontfamily = "sans",
                          # Output features
                          imagetype="png" ,
                          height = 1000 , 
                          width = 1000 , 
                          resolution = 600,
                          compression = "lzw",
                          
                          # Circles
                          lwd = 2,
                          lty = 'blank',
                          fill = myCol[use_tags],
                          
                          # Numbers
                          cex = .5,
                          fontface = "bold",
                          fontfamily = "sans",
                          
                          # Set names
                          cat.cex = 0.5,
                          cat.fontface = "bold",
                          cat.default.pos = "outer",
                          cat.pos = c(-10, 140, 180),
                          cat.dist = c(.05, 0.05, .05),
                          cat.fontfamily = "sans",
                          rotation = 1, 
                          margin = .1)




