# EJPSoilDatahub

The repository contains a series of data inventories which are deliverables of various work packages in the EJP Soil project. This repository aims to bring these inventories together in a single repository, so its content can be used in a catalog search interface, as well as dashboard functionality to visualise aggregations of indicators derived from the metadata records.

The initial format for data submission is CSV, according to a predefined template. Records in the CSV's are converted to [MCF](https://github.com/geopython/pygeometa), an optimal format for content versioning in GIT. The MCF is later transformed to iso19139 which can be ingested by common catalog products, such as [pycsw](https://pycsw.org)

Improvement suggestions on metadata content can be sumitted either as [pull request](https://en.wikipedia.org/wiki/Fork_and_pull_model) or [issue](issues).
