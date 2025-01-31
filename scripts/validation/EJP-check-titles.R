# task: check that titles make sense

# load libraries ----
library(xlsx)

# load data
xlsx <- read.xlsx("~/ISRIC_Workspace/scratch/diana/EJP-catalog-checks_11.xlsx", sheetIndex = 1)

# check names
names(xlsx)

# # select columns useful for title check
# df <- xlsx[c("check_id", "id", "title", "title_check", "title_notes",
#                "scope", "country", "catalogue_url", "canonical")]

xlsx["diana"] <- lapply(xlsx["canonical"], gsub, pattern = "/main/", replacement = "/diana/")

# save table
write.xlsx(xlsx, file = "~/ISRIC_Workspace/scratch/diana/EJP-catalog-checks_11.xlsx", row.names = FALSE)
