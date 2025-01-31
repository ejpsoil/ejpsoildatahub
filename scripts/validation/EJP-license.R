# task: content of ejpsoil catalogue at https://catalogue.ejpsoil.eu

# load libraries ----
library(jsonlite)
library(xlsx)
library(dplyr)

# create an empty data frame to store the assessment ----
columns <- c("license", "canonical")
# pass this vector length to ncol parameter
# and nrow with 0
checks <- data.frame(matrix(nrow = 0, ncol = length(columns))) 
# assign column names
colnames(checks) <- columns

# the catalog allows the offset of 50 elements, and have in total 577 ----
nmax <- 577
offset_i <- seq(from = 0, to = nmax, by = 50)

for (i in offset_i){
  
  # load JSON catalog from url
  EJP_catalog <- fromJSON(paste0("https://catalogue.ejpsoil.eu/collections/metadata:main/items?offset=", i))
  
  # get links
  links <- EJP_catalog$features$links
  
  # get license
  license <- EJP_catalog$features$properties$license # vector
  
  # first row to write the records in the iteration
  j = i + 1
  
  # fill "license" ----
  if (is.null(license)){
    checks[j:(i+length(license)), "license"] <- NA
  } else {
    checks[j:(i+length(license)), "license"] <- license
  }
  
  # fill canonical ----
  # extract github link
  l <- j
  for (k in seq_along(links)){
    canonical_k <- subset(links[[k]], type == "canonical")
    checks[l, "canonical"] <- canonical_k$href
    l <- l + 1
  }
  
}

# count uniques
uniq_licenses <- checks %>% 
  group_by(license) %>% 
  summarise(count = n())

write.xlsx(uniq_licenses, file = "~/ISRIC_Workspace/scratch/diana/licenses.xlsx",
           sheetName = "unique")

write.xlsx(checks, file = "~/ISRIC_Workspace/scratch/diana/licenses.xlsx", 
           sheetName = "all", append = TRUE)
