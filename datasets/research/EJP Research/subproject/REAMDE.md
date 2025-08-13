# Fetch records from zenodo subcommunities

- So we are aware which record originates from which community
- 

## Process

```
pip3 install -r requirements.txt
python3 zenodo-community-resources.py
crawl-metadata --mode=import-csv --dir=.
crawl-metadata --mode=update --dir=. --resolve=True
```