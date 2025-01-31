# task: content of ejpsoil catalogue at https://catalogue.ejpsoil.eu

# load libraries ----
library(jsonlite)
library(xlsx)
library(dplyr)

# create an empty data frame to store the assessment ----
columns <- c("id",
             #"i",
             #"j",
             #"k",
             #"l", 
             "link_works", "links", "links_notes", "url_fix", "canonical")
# pass this vector length to ncol parameter
# and nrow with 0
checks <- data.frame(matrix(nrow = 0, ncol = length(columns))) 
# assign column names
colnames(checks) <- columns

# valid url function ----
valid_url <- function(url_in,t=2){
  con <- url(url_in)
  check <- suppressWarnings(try(open.connection(con,open="rt",timeout=t),silent=T)[1])
  suppressWarnings(try(close.connection(con),silent=T))
  ifelse(is.null(check),TRUE,FALSE)
}

# the catalog allows the offset of 50 elements, and have in total 577 ----
nmax <- 577
offset_i <- seq(from = 0, to = nmax, by = 50)

for (i in offset_i){
  
  # load JSON catalog from url
  EJP_catalog <- fromJSON(paste0("https://catalogue.ejpsoil.eu/collections/metadata:main/items?offset=", i)) 
  
  # get id
  id <- EJP_catalog$features$id
  
  # get links
  links <- EJP_catalog$features$links
  
  # first row to write the records in the iteration
  j = i + 1
  
  # fill i ----
  #checks[j:(i+length(id)),"i"] <- i
  
  # fill j ----
  #checks[j:(i+length(id)),"j"] <- j
  
  # fill id ----
  checks[j:(i+length(id)),"id"] <- id
  
  # initialize "links_notes"
  checks[j:(i+length(id)), "links_notes"] <- ""
  
  # fill links ----
  # does it have links? (no = NA, yes(works? no = FALSE, yes = TRUE))
  print(paste0("fill links: ", i))
  
  l <- j
  for (k in seq_along(links)){
    
    # fill l ----
    #checks[l,"l"] <- l
    
    # fill k ----
    #checks[l,"k"] <- k
    
    # extract links # k
    links_k <- subset(links[[k]], type != "canonical" & type != "application/json" & type != "metadata")
    
    # fill wih NA if there are no links available
    if (nrow(links_k) == 0){
      checks[l, "links"] <- NA
      checks[l, "link_works"] <- NA
    } else {
      # paste together the links in one vector
      checks[l, "links"] <- paste(links_k$href, collapse = ", ")
      
      # check if link works
      
      # initialize "link_works"
      link_works <- c()
      
      for (m in 1:length(links_k$href)){
        link_m <- links_k$href[m]
        
        cond1 <- grepl("http://*", link_m) | grepl("https://*", link_m)
        cond2 <- sapply(link_m, grepl, pattern="^10.*")
        
        # check links that start with "http://*" or "https://*"
        if (cond1){
          link_works <- c(link_works, sapply(link_m, valid_url))
        }
        
        # check links that start with "^10.*", which are doi's
        if (cond2){
          # add a flag to the incomplete link
          checks[l, "links_notes"] <- paste0(checks[l, "links_notes"], "add \"https://doi.org/\" to doi")
          checks[l, "url_fix"] <- link_m
          
          # fix the link
          link_f <- paste0("https://doi.org/", link_m)
          
          link_works <- c(link_works, sapply(link_f, valid_url)) 
        }
        
        # if the link neither starts with "http://*" or "^10.*"
        if (!cond1 & !cond2){
          link_works <- c(link_works, NA)
          checks[l, "links_notes"] <- paste0(checks[l, "links_notes"], ", check ", link_m)
        }
        
      }
      
      # if all the links work, write just one "TRUE"
      if(length(link_works) == sum(link_works)){
        checks[l, "link_works"] <- "TRUE"
      } else{
        # if at least one of the links doesn't work, write all the TRUE and FALSE
        checks[l, "link_works"] <- paste(as.character(link_works), collapse = ", ")
      }
      
      } # else closes
    
    l <- l + 1
  } # for closes
  
  # fill canonical ----
  # extract github link
  l <- j
  for (k in seq_along(links)){
    canonical_k <- subset(links[[k]], type == "canonical")
    checks[l, "canonical"] <- canonical_k$href
    l <- l + 1
  }
  
}

#test <- subset(checks, !rowSums(is.na(checks)) == ncol(checks))
write.xlsx(checks, file = "~/ISRIC_Workspace/scratch/diana/EJP-links-checks.xlsx")

# end-of-script