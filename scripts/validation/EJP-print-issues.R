# task: generate per country a list with the issues per item
# content of ejpsoil catalogue at https://catalogue.ejpsoil.eu

# rm(list=setdiff(ls(), "xlsx"))

# load libraries ----
library(xlsx)
library(officer)

# load data
xlsx <- read.xlsx("~/ISRIC_Workspace/scratch/diana/EJP-catalog-checks_15.xlsx", sheetIndex = 1)

# extract country-concept
countries <- sort(subset(unique(xlsx$country), !is.na(unique(xlsx$country))))
cc <- unique(ifelse(is.na(xlsx$country), xlsx$concept, xlsx$country))
cc_concept <- subset(cc, !(cc %in% countries))
cc <- c(countries, cc_concept)

# create a empty data frame to store the records count per folder
# Define column names
col_names <- c("Folder", "n_records",
               "description",
               "license",
               "providers",
               "time",
               "distributor",
               "publisher",
               "no_link",
               "broken_link",
               "tot_issues")

# Convert the matrix to a data frame with column names
df <- data.frame(matrix(nrow = 0, ncol = length(col_names))) 
colnames(df) <- col_names

# counter for the df count rows 
t <- 1

for (k in seq_along(cc)){
  
  # print country name
  #cat("\n")
  #cat("***", "\n", sep = "")
  cat(cc[k], "\n")
  
  # create word document
  report_file <- paste0("~/ISRIC_Workspace/scratch/diana/EJP_reports/report_EJP_", cc[k], ".docx")
  docx <- read_docx()
  
  # add heading 1
  docx <- body_add_par(docx, cc[k], style = "heading 1")
  
  if (cc[k] %in% countries){
    # subset data
    data_k <- subset(xlsx, country == cc[k])
  } else {
    # subset data
    data_k <- subset(xlsx, concept == cc[k])
  }
  
  # find unique folders
  folders <- unique(data_k$folder)
  
  for (j in seq_along(folders)){
    
    cat(folders[j], "\n")
    
    # subset data per folder
    data_j <- subset(data_k, folder == folders[j])
    
    # fill the count table
    df[t, "Folder"] <- folders[j]
    df[t, "n_records"] <- nrow(data_j)
    
    # initialize counters in 0
    df[t, c("description",
            "license",
            "providers",
            "time",
            "distributor",
            "publisher",
            "no_link",
            "broken_link",
            "tot_issues")] <- 0
    
    # no description ----
    description_k <- subset(data_j, description == 0, select = check_id)
    
    if (nrow(description_k) > 0){
      df[t, "description"] <- df[t, "description"] + nrow(description_k)
    }
    
    # no license ----
    license_k <- subset(data_j, is.na(license), select = check_id)
    
    if (nrow(license_k) > 0){
      df[t, "license"] <- df[t, "license"] + nrow(license_k)
    }
    
    # unknown or no providers ----
    providers_k <- subset(data_j, providers == 0, select = check_id)
    
    if (nrow(providers_k) > 0){
      df[t, "providers"] <- df[t, "providers"] + nrow(providers_k)
    }
    
    # unknown time ---
    time_k <- subset(data_j, (time == "NA" | is.na(time)) &
                       (created == "NA" | is.na(created)), select = check_id)
    
    if (nrow(time_k) > 0){
      df[t, "time"] <- df[t, "time"] + nrow(time_k)
    }
    
    # no institute publisher, distributor or pointOfContact ----
    publisher_k <- subset(data_j, publisher == "" | is.na(publisher), select = check_id)
    
    if (nrow(publisher_k) > 0){
      df[t, "publisher"] <- df[t, "publisher"] + nrow(publisher_k)
    }
    
    # does it not have an email or url?
    url_k <- subset(data_j, is.na(prov_url) & is.na(email) & is.na(ext_id) & is.na(links), select = check_id)
    
    if (nrow(url_k) > 0){
      df[t, "no_link"] <- df[t, "no_link"] + nrow(url_k)
    }
    
    # does it have links or url's that doesn't work?
    prov_url_works_k <- subset(data_j, !is.na(prov_url_works) & prov_url_works != "TRUE", select = check_id)
    ext_id_works_k <- subset(data_j, !is.na(ext_id_works) & ext_id_works != "TRUE" & ext_id_works != "character", select = check_id)
    link_works_k <- subset(data_j, !is.na(link_works) & link_works != "TRUE", select = check_id)
    
    if ((nrow(prov_url_works_k) + nrow(ext_id_works_k) + nrow(link_works_k)) > 0){
      df[t, "broken_link"] <- df[t, "broken_link"] + nrow(prov_url_works_k) + nrow(ext_id_works_k) + nrow(link_works_k)
    }
    
    # total issues
    df[t, "tot_issues"] <- sum(df[t, c("description",
                                       "license",
                                       "providers",
                                       "time",
                                       "distributor",
                                       "publisher",
                                       "no_link",
                                       "broken_link")])
    
    # put together the id's with issues
    id_issues <- sort(unique(c(description_k$check_id,
                               license_k$check_id,
                               providers_k$check_id,
                               time_k$check_id, 
                               publisher_k$check_id,
                               url_k$check_id,
                               prov_url_works_k$check_id,
                               ext_id_works_k$check_id,
                               link_works_k$check_id)))
    if (length(id_issues) > 0){
      # add heading 2
      docx <- body_add_par(docx, folders[j], style = "heading 2")
      
      for (i in id_issues){
        
        # sink
        #cat("\n")
        #cat("---", "\n", sep = "")
        #cat("Title:", "\n")
        #cat(data_j[data_j$check_id == i, "title"], "\n")
        #cat("\n")
        docx <- body_add_par(docx, data_j[data_j$check_id == i, "title"][1], style = "heading 3")
        
        
        #cat("Missing information:", "\n")
        docx <- body_add_par(docx, "Missing information:", style =  "Normal")
        
        if (i %in% description_k$check_id){
          #cat(" - Description", "\n")
          docx <- body_add_par(docx, " - Description", style = "Normal")
        }
        
        if (i %in% license_k$check_id){
          #cat(" - License", "\n")
          docx <- body_add_par(docx, " - License", style = "Normal")
        }
        
        if (i %in% providers_k$check_id){
          #cat(" - Providers", "\n")
          docx <- body_add_par(docx, " - Providers", style = "Normal")
        }
        
        if (i %in% time_k$check_id){
          #cat(" - Time extent (creation time)", "\n")
          docx <- body_add_par(docx, " - Time extent (creation time)", style = "Normal")
        }
        
        if (i %in% publisher_k$check_id){
          #cat(" - Publisher, distributor or pointOfContact", "\n")
          docx <- body_add_par(docx, " - Publisher, distributor or pointOfContact", style = "Normal")
        }
        
        if (i %in% url_k$check_id){
          #cat(" - Either provider url, email, external id or any other type of external link", "\n")
          docx <- body_add_par(docx,
                               " - Either provider url, email, external id or any other type of external link",
                               style = "Normal")
        }
        
        if (i %in% prov_url_works_k$check_id |
            i %in% ext_id_works_k$check_id |
            i %in% link_works_k$check_id){
          #cat(" - Broken link(s):", "\n")
          docx <- body_add_par(docx, " - Broken link(s):", style = "Normal")
          
          # prov url's that doesn't work ----
          
          if (i %in% prov_url_works_k$check_id){
            #cat("   - Providers url(s):", "\n")
            docx <- body_add_par(docx, "   - Providers url(s):", style = "Normal")
            prov_url_test <- unlist(strsplit(data_j[data_j$check_id == i, "prov_url_works"], ","))
            prov_url_i <- unlist(strsplit(data_j[data_j$check_id == i, "prov_url"], ","))
            prov_url_i <- subset(prov_url_i, prov_url_test == "FALSE")
            
            for (m in seq_along(prov_url_i)){
              #cat(prov_url_i[j], "\n", sep = "")
              url_j <- fpar(hyperlink_ftext(href = gsub("&", "&amp;", prov_url_i[m]), 
                                            text = gsub("&", "&amp;", prov_url_i[m]),
                                            prop = fp_text(color = "blue")))
              
              docx <- body_add_fpar(docx, url_j)
            }
          }
          
          # external id's that doesn't work ----
          
          if (i %in% ext_id_works_k$check_id){
            #cat("   - External id link(s):", "\n")
            docx <- body_add_par(docx, "   - External id link(s):", style = "Normal")
            ext_id_test <- unlist(strsplit(data_j[data_j$check_id == i, "ext_id_works"], ","))
            ext_id_i <- unlist(strsplit(data_j[data_j$check_id == i, "ext_id"], ","))
            ext_id_i <- subset(ext_id_i, ext_id_test == "FALSE")
            
            for (m in seq_along(ext_id_i)){
              #cat(ext_id_i[j], "\n")
              url_j <- fpar(hyperlink_ftext(href = gsub("&", "&amp;", ext_id_i[m]), 
                                            text = gsub("&", "&amp;", ext_id_i[m]),
                                            prop = fp_text(color = "blue")))
              
              docx <- body_add_fpar(docx, url_j)
            }
          }
          
          # links that doesn't work ----
          
          if (i %in% link_works_k$check_id){
            #cat("   - Link(s):", "\n")
            links_test <- unlist(strsplit(data_j[data_j$check_id == i, "link_works"], ","))
            links_i <- unlist(strsplit(data_j[data_j$check_id == i, "links"], ","))
            links_i <- subset(links_i, links_test == "FALSE")
            
            for (m in seq_along(links_i)){
              #cat(links_i[j], "\n", sep = "")
              url_j <- fpar(hyperlink_ftext(href = gsub("&", "&amp;", links_i[m]),
                                            text = gsub("&", "&amp;", links_i[m]),
                                            prop = fp_text(color = "blue")))
              
              docx <- body_add_fpar(docx, url_j)
            }
          }
        }
        
        docx <- body_add_par(docx, "", style = "Normal")
        docx <- body_add_par(docx, "Links to catalogue.ejpsoil.eu and YAML in GitHub: ", style = "Normal")
        # cat("\n")
        # cat("Catalogue: ", "\n")
        docx <- body_add_par(docx, "Catalogue url: ", style = "Normal")
        # cat(data_j[data_j$check_id == i, "catalogue_url"], "\n", sep = "")
        caturl <- fpar(hyperlink_ftext(href = gsub("&", "&amp;", data_j[data_j$check_id == i, "catalogue_url"]),
                                       text = gsub("&", "&amp;", data_j[data_j$check_id == i, "catalogue_url"]),
                                       prop = fp_text(color = "blue")))
        
        docx <- body_add_fpar(docx, caturl)
        # cat("YAML in GitHub: ", "\n")
        docx <- body_add_par(docx, "YAML in GitHub: ", style = "Normal")
        # cat(data_j[data_j$check_id == i, "canonical"], "\n", sep = "")
        href <- gsub("&", "&amp;", data_j[data_j$check_id == i, "canonical"])
        href <- gsub(" ", "%20", href)
        canurl <- fpar(hyperlink_ftext(href = href,
                                       text = gsub("&", "&amp;", data_j[data_j$check_id == i, "canonical"]),
                                       prop = fp_text(color = "blue")))
        docx <- body_add_fpar(docx, canurl)
      }
      # write report if length(id_issues) > 0
      print(docx, target = report_file)
      print(report_file)
      
    } # ends: if (length(id_issues) > 0)
    t <- t+1
  }
}

write.csv(df, file = "~/ISRIC_Workspace/scratch/diana/EJP_reports/issues_per_folder.csv")
# end-of-script