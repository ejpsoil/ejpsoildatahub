# EJP Soil, Deliverable 6.1; Stocktaking on soil quality indicators and associated decision support tools, including ICT tools

The data in this table has been collected as part of the EJP Soil project. A report of the activity is available as [Deliverable 2.2](https://ejpsoil.eu/fileadmin/projects/ejpsoil/WP2/Deliverable_2.2_Stocktaking_on_soil_quality_indicators_and_associated_decision_support_tools__including_ICT_tools.pdf) of the EJP Soil project.

## Run crawler

crawl-metadata --mode=import-csv --dir=. --sep=";" --cluster=Country
crawl-metadata --mode=update dir=. --resolve=true