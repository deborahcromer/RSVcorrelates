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