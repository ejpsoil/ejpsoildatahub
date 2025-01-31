We ran these two scripts for automatically finding the missing information. the scripts can check the absence or present of the filtered field in the yml (but it cannot check the quality of the data). The final output prints:

 - n_records:	number of yml files inside the folder
 - description:	yml files with no description
 - license:	yml files with no license
 - time:	yml files with no creation and/or update date
 - publisher:	yml files with no institute, publisher, distributor or pointOfContact
 - no_link:	yml files with no link(s) to the resource
 - broken_link:	yml files with broken link(s)
 - total_issues: sum issues from description to broken_link per folder
