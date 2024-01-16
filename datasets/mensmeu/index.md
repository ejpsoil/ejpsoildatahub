# Mensmeu

* quoted from <https://esdac.jrc.ec.europa.eu/projects/inspire-and-soil-data> *

The INSPIRE Directive was published in the official Journal on the 25th April 2007 and entered into force on the 15th May 2007. All details can be found on https://inspire.ec.europa.eu/. It requires EU countries to make, for various environmental themes, their data available to the public. The INSPIRE Geoportal is the central European access point to the data provided by EU Member States under the INSPIRE Directive. Data are organized per environmental theme. For soil, all datasets are found here. 

From experience, it is known that this overview is not complete and many more soil datasets in the EU exist. Also, it is not indicated which datasets are authoritative. For instance, if one looks for soil type data in country X, it is not possible to find out from the Geoportal which datasets should be used.

In an attempt to find more relevant, useful and usable soil datasets in EU countries, and in collaboration with DG ENV, a small study was conducted, with title "Collection of Meta-Data on Digital Soil Data in Europe; development of database on Digital Soil Resources of Europe”.

The objectives and the results of this study are published here. The package consists of a short report and its associated [database](index.csv).

These results have not been thoroughly quality checked, and it is expected that newer versions of the metadata database will be made available later. The readers/users of the data are encouraged to report any errors or possible updates as [issues in this repository](https://github.com/ejpsoil/ejpsoildatahub/issues).

The report and database should be referered to as:

"MENSMEU (Metadata of national soil maps of the European Union), Deliverable of a study commissioned by the European Commission, with title "Collection of Meta-Data on Digital Soil Data in Europe; development of database on Digital Soil Resources of Europe”, October 2019. Data available from ESDAC: https://esdac.jrc.ec.europa.eu/projects/inspire-and-soil-data (contact: ec-esdac@ec.europa.eu)"

## Mensmeu and ejpsoil

EJPSoil asked JRC to use the mensmeu results as a startingpoint to build up a catalogue on European soil datasets. This request has been confirmed. You are looking at the results of the effort.

## Run crawler

crawl-metadata --mode=import-csv --dir=. --sep=";" --cluster=Country
crawl-metadata --mode=update dir=. --resolve=true