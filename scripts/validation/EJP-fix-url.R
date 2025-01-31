# modify url's

# load libraries ----
library(xlsx)

# load file
xlsx <- read.xlsx("~/ISRIC_Workspace/scratch/diana/EJP-catalog-checks_9.xlsx", sheetIndex = 1)
df_fix <- subset(xlsx, xlsx$prov_url_works == "character")

for (i in 1:nrow(df_fix)){
  
  yml_path <- substr(df_fix[i, "canonical"], 62, nchar(df_fix[i, "canonical"]))
  git_path <- paste0("~/git/ejpsoildatahub/datasets/", yml_path)
  
  filename = git_path
  
  # read yaml, modify and write to file
  yaml = readLines(filename)
  url_fix <- df_fix[i, "url_fix"]
  print(grep(paste0("url: ", url_fix), yaml))
  yaml = gsub(paste0("url: ", url_fix), paste0("url: https://doi.org/", url_fix), yaml)
  
  write.table(yaml, git_path, quote = FALSE, row.names = FALSE, col.names = FALSE)
  
}

# fix ext_url

for (i in 1:nrow(df_fix)){
  
  yml_path <- substr(df_fix[i, "canonical"], 62, nchar(df_fix[i, "canonical"]))
  git_path <- paste0("~/git/ejpsoildatahub/datasets/", yml_path)
  
  filename = git_path
  
  # read yaml, modify and write to file
  yaml = readLines(filename)
  urls_fix <- df_fix[i, "prov_url"]
  urls_fix <- unlist(strsplit(urls_fix, ","))
  
  for (j in seq_along(urls_fix)){
    url_j <- urls_fix[j]
    print(grep(paste0("url: ", url_j), yaml))
    yaml = gsub(paste0("url: ", url_j), paste0("url: https://orcid.org/", url_j), yaml)
  }
  
  write.table(yaml, git_path, quote = FALSE, row.names = FALSE, col.names = FALSE)
}
