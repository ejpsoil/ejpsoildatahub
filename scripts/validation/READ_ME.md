We ran these scripts for automatically finding the missing information. The scripts can check the absence or present of the filtered field in the yml (but it cannot check the quality of the data). The final output after running (1) `EJP-catalogue-cleaning.R` and (2) `EJP-print-issues.R` is a list of word documents (.docx) listing the missing information per record, and a CSV table with a summary with the following columns:

 - n_records:	number of yml files inside the folder
 - description:	yml files with no description
 - license:	yml files with no license
 - time:	yml files with no creation and/or update date
 - publisher:	yml files with no institute, publisher, distributor or pointOfContact
 - no_link:	yml files with no link(s) to the resource
 - broken_link:	yml files with broken link(s)
 - total_issues: sum issues from description to broken_link per folder

Other scripts perform specific checks when necessary during the catalog cleaning process.