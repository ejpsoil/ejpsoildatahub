###
# author: paul van genuchten - ISRIC - World Soil Information
# goal: script will fetch from a list of zenodo communities, the dataset metadata
# license: MIT
###

import csv
import requests
import json

# Input and output CSV filenames
INPUT_FILE = "projects.csv"
OUTPUT_FILE = "index.csv"

def main():
    # Read URLs from links.csv
    with open(INPUT_FILE, newline='', encoding='utf-8') as csvfile:
        reader = csv.reader(csvfile)
        projects = [{'p':row[2],'a':row[4]} for row in reader if row]  # First column only, skip empty rows
    results = []

    for pr in projects[1:]:
        if pr.get('a') not in [None,'']:
            next = f"https://zenodo.org/api/records?communities={pr.get('a').strip()}&size=25&type=dataset&sort=newest"
            while next not in [None,'']:
                try:
                    print(next)
                    response = requests.get(next, timeout=30)
                    response.raise_for_status()

                    data = response.json()

                    # Get the 'identifier' property, None if missing
                    for r in data.get('hits',{}).get('hits',[]):
                        identifier = r.get("doi", None)
                        title = r.get("title", None)
                        results.append({"project": pr.get('p'), "identifier": identifier, "title": title})
                    next = data.get('links',{}).get('next')  
                except requests.RequestException as e:
                    print(f"Request failed for {next}: {e}")
                except json.JSONDecodeError:
                    print(f"Invalid JSON for {next}")

    # Write results to identifiers.csv
    with open(OUTPUT_FILE, mode='w', newline='', encoding='utf-8') as csvfile:
        fieldnames = ["project", "identifier", "title"]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

        writer.writeheader()
        for row in results:
            writer.writerow(row)

    print(f"Done! Extracted identifiers saved to {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
