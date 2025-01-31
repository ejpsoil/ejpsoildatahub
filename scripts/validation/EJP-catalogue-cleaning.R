# task: content of ejpsoil catalogue at https://catalogue.ejpsoil.eu

# load libraries ----
library(jsonlite)
library(xlsx)
library(stringr)
library(dplyr)

# create an empty data frame to store the assessment ----
# created vector with 5 characters
columns <- c("check_id", "id",
             "title", "title_check", #"title_notes",
             "keywords", "scope", "country", "concept", "folder",
             "description", "license", 
             "time", "created", "updated",
             "providers", "publisher", "prov_url", "prov_url_works", "email",
             "ext_id", "ext_id_works", "ext_id_notes",
             "links", "link_works", "links_notes", "url_fix",
             "catalogue_url", "canonical") 
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

# urls <-   c("https://www.dov.vlaanderen.be/bodemverkenner", ... )
# sapply(urls,valid_url)

# loop catalog ----

# the catalog allows the offset of 50 elements, and have in total 577 ----
nmax <- 577
offset_i <- seq(from = 0, to = nmax, by = 50)

for (i in offset_i){
  
  # load JSON catalog from url
  EJP_catalog <- fromJSON(paste0("https://catalogue.ejpsoil.eu/collections/metadata:main/items?offset=", i)) 
  # get id
  id <- EJP_catalog$features$id
  # get title
  title <- EJP_catalog$features$properties$title # vector 
  # get keywords
  keywords <-  EJP_catalog$features$properties$keywords # list
  # get themes
  themes <- EJP_catalog$features$properties$themes
  # get description
  description <- EJP_catalog$features$properties$description # vector # does it have description? (no = 0, yes = 1) does the description makes sense? (no = 2)
  # get time
  time <- EJP_catalog$features$time
  # get created
  created <- EJP_catalog$features$properties$created
  # get updated
  updated <- EJP_catalog$features$properties$updated
  # get providers
  providers <-  EJP_catalog$features$properties$providers # df list # does it have providers? (no = 0, yes = 1) what info about providers is significant? email? url?
  # get external id's
  ext_id <- EJP_catalog$features$properties$externalIds # df list, "value" # does it have ext_id? does it work?
  # get links
  links <- EJP_catalog$features$links # df list, "href", # does it have href link? (no = 0, yes = 1) does it work?
  # get license
  license <- EJP_catalog$features$properties$license # vector
  
  # fill checks table
  
  # first row to write the records in the iteration
  j = i + 1
  
  # fill "check_id"
  print(paste0("fill id: ", i))
  checks[j:(i+length(id)),"check_id"] <- j:(i+length(id))
  
  # fill id ----
  checks[j:(i+length(id)),"id"] <- id
  
  # fill "title" ----
  print(paste0("fill title: ", i))
  checks[j:(i+length(title)), "title"] <- title
  
  # fill "title_check"
  checks[j:(i+length(title)), "title_check"] <- ifelse(is.na(checks$title[j:(i+length(title))]), 0, 1) # does it have a title? (no = 0, yes = 1)
  
  # fill "license" ----
  if (is.null(license)){
    checks[j:(i+length(license)), "license"] <- NA
  } else {
    checks[j:(i+length(license)), "license"] <- license
  }
  
  # fill "keywords" ----
  print(paste0("fill keywords: ", i))
  # does it have keywords? which?
  l <- j
  for (k in seq_along(keywords)){
    checks[l, "keywords"] <- paste(keywords[[k]], collapse = ",")
    l <- l + 1
  }
  
  # fill canonical ----
  # extract github link
  l <- j
  for (k in seq_along(links)){
    canonical_k <- subset(links[[k]], type == "canonical")
    checks[l, "canonical"] <- canonical_k$href
    l <- l + 1
  }
  
  # fill folder ----
  l <- j
  for (k in seq_along(links)){
    canonical_k <- subset(links[[k]], type == "canonical")$href
    checks[l, "folder"] <- substr(canonical_k, 62, max(unlist(gregexpr('/', canonical_k)))-1)
    l <- l + 1
  }
  
  # fill scope ----
  print(paste0("fill scope: ", i))
  l <- j
  for (k in seq_along(themes)){
    scope_k <- themes[[k]]$concepts[[1]][1]
    concept_k <- themes[[k]]$concepts[[2]][1]
    checks[l, "scope"] <- scope_k
    checks[l, "concept"] <- concept_k
    
    
    # fill country
    if (scope_k == "National"){
      str_country <- substr(checks[l, "canonical"], 62, nchar(checks[l, "canonical"]))
      slash_loc <- unlist(gregexpr('/', str_country))
      checks[l, "country"] <- substr(str_country, slash_loc[1]+1, slash_loc[2]-1)
    }
     
    l <- l + 1
  }
  
  # fill "description" ----
  print(paste0("fill description: ", i))
  checks[j:(i+length(description)), "description"] <- ifelse(is.na(description), 0, 1) # does it have a description? (no = 0, yes = 1)
  
  
  # fill providers ----
  print(paste0("fill providers: ", i))
  
  # fill publisher
  l <- j
  for (k in seq_along(providers)){
    distributor_k <- subset(providers[[k]]$name, unlist(providers[[k]]$roles) == 'publisher' |
                              unlist(providers[[k]]["roles"]) == 'distributor' |
                                       unlist(providers[[k]]["roles"]) == 'pointOfContact')
    if("" %in% distributor_k){
      distributor_k <- subset(distributor_k, distributor_k != "")
      
      if (length(distributor_k) == 0){
        distributor_k <- NA
      }
    }
    
    checks[l, "publisher"] <-  paste(distributor_k, collapse = ",")
    l <- l + 1
  }
  
  # fill "providers"
  # does it have providers? ('Unknown' = 0, yes = 1)
  l <- j
  for (k in seq_along(providers)){
    providers_k <- providers[[k]]$name
    
    # if("" %in% providers_k){
    #   providers_k <- which(providers_k != "")
    # }
    
    if (any(providers_k == "Unknown") | any(is.na(providers_k))){
      checks[l, "providers"] <- 0
    } else {
      checks[l, "providers"] <- 1
    }
    l <- l + 1
  }
  
  # fill "providers_url" and "prov_url_works"
  l <- j
  for (k in seq_along(providers)){
    providers_k <- providers[[k]]$contactInfo$url$url
    
    providers_k <- subset(providers_k, !is.na(providers_k))
    
    if(length(providers_k) == 0){
      checks[l, "prov_url"] <- NA
    } else{
      checks[l, "prov_url"] <- paste(providers_k, collapse = ",")
      
      if (any(grepl("http://", providers_k) | grepl("https://", providers_k))){
        
        link_works_k <- sapply(providers_k,valid_url)
        
        if(length(link_works_k) == sum(link_works_k)){
          checks[l, "prov_url_works"] <- "TRUE"
        } else{
          checks[l, "prov_url_works"] <- paste(as.character(link_works_k), collapse = ",")
        }
      } else {
        checks[l, "prov_url_works"] <- "character"
      }
    }
    l <- l + 1
  }
  
  # fill email
  # extract the email
  l <- j
  for (k in seq_along(providers)){
    email_k <- providers[[k]]$contactInfo$email
    email_k <- subset(email_k, !is.na(email_k))
    
    if(nrow(email_k) == 0){
      checks[l, "email"] <- NA
    } else {
      checks[l, "email"] <- paste(as.character(email_k), collapse = ",")
    }
    l <- l + 1
  }
  
  # fill "time" ----
  print(paste0("fill time: ", i))
  # check the temporal extent
  l <- j
  for (k in seq_along(time)){
    
    if(is.list(time)){
      checks[l, "time"] <- paste(time[[k]], collapse = ",")
    } else {
      checks[l, "time"] <- paste(time[l], collapse = ",")
    }
    l <- l + 1
  }
  
  # fill created
  l <- j
  for (k in seq_along(created)){
    checks[l, "created"] <- created[k]
    l <- l + 1
  }
  
  # fill updated
  l <- j
  for (k in seq_along(updated)){
    checks[l, "updated"] <- updated[k]
    l <- l + 1
  }
  
  # fill external id ----
  print(paste0("fill external id: ", i))
  
  # does it have ext_id? (no = NA, yes(works? no = FALSE, yes = TRUE))
  l <- j
  for (k in seq_along(ext_id)){
    ext_id_k <- ext_id[[k]]
    # fill "ext_id_works" and "ext_id"
    if (is.null(ext_id_k)){
      checks[l, "ext_id_works"] <- NA
      checks[l, "ext_id"] <- NA
    } else {
      checks[l, "ext_id"] <- ext_id_k
      if (grepl("^http://", ext_id_k) | grepl("^https://", ext_id_k)){
        checks[l, "ext_id_works"] <- as.character(sapply(ext_id_k,valid_url))
      } else {
        checks[l, "ext_id_works"] <- "character"
      }
    }
    l <- l + 1
  }
  
  # fill links ----
  # does it have links? (no = NA, yes(works? no = FALSE, yes = TRUE))
  print(paste0("fill links: ", i))
  
  l <- j
  for (k in seq_along(links)){
    
    # extract links # k
    links_k <- subset(links[[k]], type != "canonical" & type != "application/json" & type != "metadata")
    
    # fill wih NA if there are no links available
    if (nrow(links_k) == 0){
      checks[l, "links"] <- NA
      checks[l, "link_works"] <- NA
    } else {
      # paste together the links in one vector
      checks[l, "links"] <- paste(links_k$href, collapse = ",")
      
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
          checks[l, "links_notes"] <- paste0(!is.na(checks[l, "links_notes"]), "add \"https://doi.org/\" to doi")
          checks[l, "url_fix"] <- link_m
          
          # fix the link
          link_f <- paste0("https://doi.org/", link_m)
          
          link_works <- c(link_works, sapply(link_f, valid_url)) 
        }
        
        # if the link neither starts with "http://*" or "^10.*"
        if (!cond1 & !cond2){
          link_works <- c(link_works, NA)
          checks[l, "links_notes"] <- paste0(!is.na(checks[l, "links_notes"]), ", check ", link_m)
        }
        
      }
      
      # if all the links work, write just one "TRUE"
      if(length(link_works) == sum(link_works)){
        checks[l, "link_works"] <- "TRUE"
      } else{
        # if at least one of the links doesn't work, write all the TRUE and FALSE
        checks[l, "link_works"] <- paste(as.character(link_works), collapse = ",")
      }
      
    } # else closes
    
    l <- l + 1
  } # for closes
  
  # fill catalogue url ----
  # make up url to catalog
  
  l <- j
  for (k in seq_along(links)){
    catlinkl <- "https://catalogue.ejpsoil.eu/collections/metadata:main/items/"
    catlinkl_k <- paste0(catlinkl, URLencode(id[k], reserved = TRUE, repeated = TRUE))
    checks[l, "catalogue_url"] <- catlinkl_k
    #print(catlinkl_k)
    l <- l + 1
  }
}

#test <- subset(checks, !rowSums(is.na(checks)) == ncol(checks))

# join "title_notes"
previous_xlsx <- read.xlsx("~/ISRIC_Workspace/scratch/diana/EJP-catalog-checks_11.xlsx", sheetIndex = 1)
# delete empty "title_notes"
#drop <- c("title_notes")
#checks <- checks[,!(names(checks) %in% drop)]
#test <- subset(checks, !is.na(check_id))
 
checks_plus_notes <- left_join(checks, previous_xlsx[c("id", "title_notes")], by = join_by("id"))
checks_plus_notes <- subset(checks_plus_notes, !duplicated(checks_plus_notes))
checks_plus_notes <- checks_plus_notes %>% relocate(title_notes, .after = title_check)

# create a new column with link pointing to "diana" branch
checks_plus_notes["diana"] <- lapply(checks_plus_notes["canonical"], gsub, pattern = "/main/", replacement = "/diana/")

# save xlsx
write.xlsx(checks_plus_notes, file = "~/ISRIC_Workspace/scratch/diana/EJP-catalog-checks_15.xlsx", row.names = FALSE)

