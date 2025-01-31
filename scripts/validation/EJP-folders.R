# task: fill the folder's column
# content of ejpsoil catalogue at https://catalogue.ejpsoil.eu

# load libraries ----
library(xlsx)

# load data
xlsx <- read.xlsx("~/ISRIC_Workspace/scratch/diana/EJP-catalog-checks_11.xlsx", sheetIndex = 1)

# fill folder ----
for (k in 1:nrow(xlsx)){
  canonical_k <- xlsx$canonical[k]
  xlsx[k, "folder"] <- substr(canonical_k, 62, max(unlist(gregexpr('/', canonical_k)))-1)
}

# save xlsx
write.xlsx(checks, file = "~/ISRIC_Workspace/scratch/diana/EJP-catalog-checks_11.xlsx", row.names = FALSE)

