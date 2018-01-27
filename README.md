
<a id="devex-badge" rel="Exploration" href="https://github.com/BCDevExchange/assets/blob/master/README.md"><img alt="Being designed and built, but in the lab. May change, disappear, or be buggy." style="border-width:0" src="https://assets.bcdevexchange.org/images/badges/exploration.svg" title="Being designed and built, but in the lab. May change, disappear, or be buggy." /></a> [![Travis-CI Build Status](https://travis-ci.org/bcgov/canwqdata.svg?branch=master)](https://travis-ci.org/bcgov/canwqdata)

canwqdata
=========

An R 📦 to download open water quality data from Environment and Climate Change Canada's [National Long-term Water Quality Monitoring Data](http://donnees.ec.gc.ca/data/substances/monitor/national-long-term-water-quality-monitoring-data/).

### Features

This package is designed to get Canadian Water Quality Monitoring data into R quickly and easily. You can get data from a single monitoring station, multiple stations, or from an entire basin.

### Installation

``` r
remotes::install_github("bcgov/canwqdata")
```

### Usage

First load the package:

``` r
library(canwqdata)
```

The first thing you will probably want to do is get a list of the available sites and associated metadata:

``` r
sites <- wq_sites()

sites
#> # A tibble: 214 x 16
#>    SITE_NO SITE_NAME SITE_NOM_FR SITE_TYPE SITE_DESC SITE_DESC_FR LATITUDE
#>    <chr>   <chr>     <chr>       <chr>     <chr>     <chr>           <dbl>
#>  1 72      BEAUHARN… CANAL DE B… RIVER/RI… <NA>      <NA>             45.2
#>  2 75      ST.LAWRE… FLEUVE SAI… RIVER/RI… <NA>      <NA>             45.9
#>  3 78      ST.LAWRE… FLEUVE SAI… RIVER/RI… <NA>      <NA>             45.4
#>  4 00BR01… SAINT JO… RIVIÈRE SA… RIVER/RI… <NA>      <NA>             47.4
#>  5 00BR01… AROOSTOO… RIVIÈRE AR… RIVER/RI… <NA>      <NA>             46.8
#>  6 00BR01… TOBIQUE … RIVIÈRE TO… RIVER/RI… <NA>      <NA>             46.8
#>  7 00BR01… BIG PRES… RUISSEAU B… RIVER/RI… <NA>      <NA>             46.4
#>  8 00BR01… SAINT JO… RIVIÈRE SA… RIVER/RI… <NA>      <NA>             46.0
#>  9 00BR01… NASHWAAK… RIVIÈRE NA… RIVER/RI… <NA>      <NA>             46.0
#> 10 00BR01… SAINT JO… RIVIÈRE SA… RIVER/RI… <NA>      <NA>             45.6
#> # ... with 204 more rows, and 9 more variables: LONGITUDE <dbl>,
#> #   DATUM <chr>, PROV_TERR <chr>, PEARSEDA <chr>, PEARSEDA_FR <chr>,
#> #   OCEANDA <chr>, OCEANDA_FR <chr>, DATA_URL <chr>, DATA_URL_FR <chr>
```

Then get some data from a particular station:

`AL07AA0015` is a site in Alberta called *Athabasca River above Athabasca Falls*

``` r
athabasca_falls <- dl_sites("AL07AA0015")

athabasca_falls
#> # A tibble: 7,931 x 11
#>    SITE_NO  DATE_TIME_HEURE     FLAG_MARQUEUR VALUE_VALEUR SDL_LDE MDL_LDM
#>    <chr>    <dttm>              <chr>                <dbl>   <dbl>   <dbl>
#>  1 AL07AA0… 2000-01-11 13:05:00 <NA>             93.2           NA      NA
#>  2 AL07AA0… 2000-01-11 13:05:00 <                 0.0200        NA      NA
#>  3 AL07AA0… 2000-01-11 13:05:00 <                 0.00500       NA      NA
#>  4 AL07AA0… 2000-01-11 13:05:00 <                 0.000100      NA      NA
#>  5 AL07AA0… 2000-01-11 13:05:00 <NA>              0.0650        NA      NA
#>  6 AL07AA0… 2000-01-11 13:05:00 <                 0.500         NA      NA
#>  7 AL07AA0… 2000-01-11 13:05:00 <                 0.00200       NA      NA
#>  8 AL07AA0… 2000-01-11 13:05:00 <                 0.00100       NA      NA
#>  9 AL07AA0… 2000-01-11 13:05:00 <NA>             29.0           NA      NA
#> 10 AL07AA0… 2000-01-11 13:05:00 <NA>              0.451         NA      NA
#> # ... with 7,921 more rows, and 5 more variables: VMV_CODE <int>,
#> #   UNIT_UNITE <chr>, VARIABLE <chr>, VARIABLE_FR <chr>,
#> #   STATUS_STATUT <chr>
```

We can also get data from more than one station:

``` r
dl_sites(c("YT09FC0002", "00BR01AG0008"))
#> # A tibble: 2,092 x 11
#>    SITE_NO  DATE_TIME_HEURE     FLAG_MARQUEUR VALUE_VALEUR SDL_LDE MDL_LDM
#>    <chr>    <dttm>              <chr>                <dbl>   <dbl>   <dbl>
#>  1 YT09FC0… 2007-08-27 16:35:00 <NA>              83.9     0.500        NA
#>  2 YT09FC0… 2007-08-27 16:35:00 <NA>              74.6     0.200        NA
#>  3 YT09FC0… 2007-08-27 16:35:00 <NA>               0.132   0.00100      NA
#>  4 YT09FC0… 2007-08-27 16:35:00 <NA>               0.790   0.0100       NA
#>  5 YT09FC0… 2007-08-27 16:35:00 <NA>              61.5     0.0500       NA
#>  6 YT09FC0… 2007-08-27 16:35:00 <NA>               0.0120  0.00100      NA
#>  7 YT09FC0… 2007-08-27 16:35:00 <NA>               0.00500 0.00100      NA
#>  8 YT09FC0… 2007-08-27 16:35:00 <NA>               6.00    0.500        NA
#>  9 YT09FC0… 2007-08-27 16:35:00 <NA>               0.00900 0.00100      NA
#> 10 YT09FC0… 2007-08-27 16:35:00 <NA>              30.6     0.100        NA
#> # ... with 2,082 more rows, and 5 more variables: VMV_CODE <int>,
#> #   UNIT_UNITE <chr>, VARIABLE <chr>, VARIABLE_FR <chr>,
#> #   STATUS_STATUT <chr>
```

Or an entire basin:

The basins are in the `PEARSEDA` column of the data.frame returned by `wq_sites()`:

``` r
basins <- sort(unique(sites$PEARSEDA))
basins
#>  [1] "ARCTIC COAST-ISLANDS"      "ASSINIBOINE-RED"          
#>  [3] "CHURCHILL"                 "COLUMBIA"                 
#>  [5] "FRASER-LOWER MAINLAND"     "GREAT LAKES"              
#>  [7] "KEEWATIN-SOUTHERN BAFFIN"  "LOWER MACKENZIE"          
#>  [9] "LOWER SASKATCHEWAN-NELSON" "MARITIME COASTAL"         
#> [11] "MISSOURI"                  "NEWFOUNDLAND-LABRADOR"    
#> [13] "NORTH SASKATCHEWAN"        "NORTH SHORE-GASPÉ"        
#> [15] "OKANAGAN-SIMILKAMEEN"      "OTTAWA"                   
#> [17] "PACIFIC COASTAL"           "PEACE-ATHABASCA"          
#> [19] "SAINT JOHN-ST. CROIX"      "SOUTH SASKATCHEWAN"       
#> [21] "ST. LAWRENCE"              "WINNIPEG"                 
#> [23] "YUKON"

fraser <- dl_basin("FRASER-LOWER MAINLAND")
```

Do some quick summary stats of the fraser dataset:

``` r
library(dplyr)

fraser %>% 
  group_by(SITE_NO) %>% 
  summarise(first_date = min(DATE_TIME_HEURE), 
            latest_date = max(DATE_TIME_HEURE), 
            n_params = length(unique(VARIABLE)), 
            total_samples = n())
#> # A tibble: 13 x 5
#>    SITE_NO  first_date          latest_date         n_params total_samples
#>    <chr>    <dttm>              <dttm>                 <int>         <int>
#>  1 BC08KA0… 2000-01-12 07:45:00 2017-12-05 13:54:00      108         22937
#>  2 BC08KE0… 2000-01-05 00:00:00 2017-12-05 09:30:00       76         21155
#>  3 BC08KH0… 2006-05-11 13:07:00 2017-12-07 10:50:00      142         16784
#>  4 BC08LC0… 2011-02-24 09:45:00 2017-12-11 13:38:00       68          9542
#>  5 BC08LE0… 2000-01-04 10:00:00 2017-12-06 11:00:00      112         20956
#>  6 BC08LF0… 2000-01-05 12:00:00 2014-12-15 10:20:00       89         18410
#>  7 BC08LG0… 2003-06-24 10:45:00 2017-12-18 10:40:00       71          8995
#>  8 BC08MB0… 2004-11-15 12:00:00 2017-12-06 09:30:00      105         19058
#>  9 BC08MC0… 2000-04-18 16:30:00 2017-12-06 14:57:00      107         20153
#> 10 BC08MF0… 2000-01-04 14:10:00 2017-12-06 08:20:00      128         20374
#> 11 BC08MH0… 2000-01-07 12:16:00 2017-12-05 12:30:00      115         30018
#> 12 BC08MH0… 2004-03-03 14:40:00 2017-12-06 08:20:00      135         23014
#> 13 BC08MH0… 2008-09-02 16:25:00 2017-12-06 13:55:00      107         11235
```

We can also look at metadata that helps us understand what is in the different columns.

`wq_params()` returns a list of water quality parameters (variables), and related data - units, methods, codes, etc:

``` r
params <- wq_params()
glimpse(params)
#> Observations: 1,155
#> Variables: 12
#> $ VMV_CODE         <int> 77, 78, 79, 80, 157, 160, 201, 202, 210, 211,...
#> $ VARIABLE_CODE    <int> 635, 365, 4541, 414, 864, 1073, 837, 837, 762...
#> $ VARIABLE         <chr> "NITROGEN TOTAL", "ALKALINITY TOTAL HCO3", "C...
#> $ VARIABLE_FR      <chr> "AZOTE TOTAL", "ALCALINITÉ TOTALE HCO3", "CHL...
#> $ VARIABLE_TYPE    <chr> "NITROGEN", "PHYSICAL", "CHLOROPHYLL", "CHLOR...
#> $ VARIABLE_TYPE_FR <chr> "AZOTE", "PHYSIQUE", "CHLOROPHYLLE", "CHLOROP...
#> $ UNIT_UNITÉ       <chr> "MG/L", "MG/L", "UG/L", "UG/L", "NTU", "MG/L"...
#> $ UNIT_NAME        <chr> "MILLIGRAMS PER LITRE", "MILLIGRAMS PER LITRE...
#> $ UNITÉ_NOM        <chr> "MILLIGRAMMES PAR LITRE", "MILLIGRAMMES PAR L...
#> $ METHOD_CODE      <int> 23, 30, 35, 41, 188, 189, 8, 9, 15, 16, 617, ...
#> $ METHOD_TITLE     <chr> "TOTAL NITROGEN MEASUREMENT BY PERSULFATE OXI...
#> $ MÉTHODE_TITRE    <chr> "AZOTE TOTAL PAR LA MÉTHODE D'OXYDATION AU PE...

# wq_param_desc shows the column headings ((in all other tables) and what they mean
wq_param_desc() %>% 
  glimpse()
#> Observations: 39
#> Variables: 5
#> $ COL_TITLE_TITRE    <chr> "COL_DESCRIPTION", "COL_DESCRIPTION_FR", "C...
#> $ COL_TITLE_FULL     <chr> "COLUMN HEADER DESCRIPTION", "COLUMN HEADER...
#> $ COL_TITRE_COMPLET  <chr> "DESCRIPTION DE L'EN-TÊTE DE COLONNE", "DES...
#> $ COL_DESCRIPTION    <chr> "COLUMN HEADER DESCRIPTION", "COLUMN HEADER...
#> $ COL_DESCRIPTION_FR <chr> "DESCRIPTION DE L'EN-TÊTE DE COLONNE", "DES...
```

Let's look at Total Nitrogen in the Fraser basin:

``` r
fraser_n_total <- fraser %>% filter(VARIABLE == "NITROGEN TOTAL")
```

Now lets do some plotting - plot Total Nitrogen over time at all the sites, (plot it on a log scale so that they all fit)

``` r
library(ggplot2)

ggplot(fraser_n_total, aes(x = DATE_TIME_HEURE, y = VALUE_VALEUR)) + 
  geom_point(size = 0.4, alpha = 0.4, colour = "purple") + 
  facet_wrap(~ SITE_NO) + 
  scale_y_log10()
```

![](tools/readme/unnamed-chunk-10-1.png)

It's also possible to download data from an entire province:

``` r
bc_sites <- sites %>% 
  filter(PROV_TERR == "BC") %>% 
  pull(SITE_NO)

all_bc_data <- dl_sites(bc_sites)

glimpse(all_bc_data)
#> Observations: 817,921
#> Variables: 11
#> $ SITE_NO         <chr> "BC07FD0005", "BC07FD0005", "BC07FD0005", "BC0...
#> $ DATE_TIME_HEURE <dttm> 2000-02-01 11:21:00, 2000-02-01 11:21:00, 200...
#> $ FLAG_MARQUEUR   <chr> NA, NA, NA, "<", "<", NA, NA, NA, "<", "<", NA...
#> $ VALUE_VALEUR    <dbl> 0.0550, 0.0002, 0.0351, 0.0500, 0.0001, 28.200...
#> $ SDL_LDE         <dbl> 0.0020, 0.0001, 0.0002, 0.0500, 0.0001, 0.1000...
#> $ MDL_LDM         <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA...
#> $ VMV_CODE        <int> 100216, 100250, 100217, 100218, 100219, 1143, ...
#> $ UNIT_UNITE      <chr> "MG/L", "MG/L", "MG/L", "UG/L", "MG/L", "MG/L"...
#> $ VARIABLE        <chr> "ALUMINUM TOTAL", "ARSENIC TOTAL", "BARIUM TOT...
#> $ VARIABLE_FR     <chr> "ALUMINIUM TOTAL", "ARSENIC TOTAL", "BARYUM TO...
#> $ STATUS_STATUT   <chr> "P", "P", "P", "P", "P", "P", "P", "P", "P", "...
```

### Project Status

Under development, but ready for use and testing.

### Getting Help or Reporting an Issue

To report bugs/issues/feature requests, please file an [issue](https://github.com/bcgov/canwqdata/issues/).

### How to Contribute

If you would like to contribute to the package, please see our [CONTRIBUTING](CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

### License

    Copyright 2018 Province of British Columbia

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at 

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

This repository is maintained by [Environmental Reporting BC](http://www2.gov.bc.ca/gov/content?id=FF80E0B985F245CEA62808414D78C41B). Click [here](https://github.com/bcgov/EnvReportBC-RepoList) for a complete list of our repositories on GitHub.
