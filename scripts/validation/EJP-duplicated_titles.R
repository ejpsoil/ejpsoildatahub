# some titles seem to be duplicated
# lets find out which ones

# load libraries ----
library(xlsx)

# load data
xlsx <- read.xlsx("~/ISRIC_Workspace/scratch/diana/EJP-catalog-checks_14.xlsx", sheetIndex = 1)

# find duplicated titles
dupl_titles <- subset(xlsx$title, duplicated(xlsx$title))

# find the uniques
dupl_titles <- unique(dupl_titles)

# find all records with duplicate titles
df_dup_titles <- subset(xlsx, xlsx$title %in% dupl_titles)

# export xlsx
write.xlsx(df_dup_titles, file = "~/ISRIC_Workspace/scratch/diana/EJP-dupl_titles_13.xlsx", row.names = FALSE)
