# NEXUS WASTE — Smart Waste Management Analytics

A complete R/Shiny dashboard for analyzing urban waste collection, recovery and service efficiency.

## Features
- Dark modern command-center UI/UX
- Overview KPI dashboard
- Date, zone, waste-type and collection-method filters
- Waste flow trend
- Waste composition
- Zone recovery performance
- Collection status
- Vehicle utilization
- Collection-time analysis
- Collection-method performance
- Satisfaction analysis
- Recycling/recovery analytics
- Smart operational insights
- Searchable Data Explorer
- Bundled synthetic dataset with 1,800 collection records
- R + Shiny only; no Python, React or external API

## Requirements
R 4.6.1 recommended.
Packages: shiny, ggplot2, dplyr, DT, scales, lubridate.

## Run on Windows / VS Code

```powershell
& "C:\Program Files\R\R-4.6.1\bin\x64\Rscript.exe" requirements.R
& "C:\Program Files\R\R-4.6.1\bin\x64\Rscript.exe" run_app.R
```

Open:
http://127.0.0.1:8080

If 8080 is already in use:

```powershell
& "C:\Program Files\R\R-4.6.1\bin\x64\Rscript.exe" -e "shiny::runApp('.', host='127.0.0.1', port=8081, launch.browser=TRUE)"
```

## Structure
- app.R
- run_app.R
- requirements.R
- README.md
- .gitignore
- data/waste_data.csv
- www/styles.css

The dataset is synthetic and intended for academic/demo use.
