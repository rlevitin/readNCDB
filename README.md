# readNCDB
Read the NCDB PUF data file in R by parsing the stata .do file

Adapted from code [Alex Bokov PhD](https://github.com/bokov/kc_ncdb)

Currently, the code is quite crude and requires some manual intervention outlined below to direct it to the correct files, tell it what to save and indicate which levels to not map. I wanted to share in case it is of use to others.

The code parses the `.do` file to determine the fixed-width limits for each variable in the `.dat` file. It also parses the `.do` file to construct a dataframe dictionary which is used to label the variables as factors.

## Use instructions
Download the readNCDB.R file into your project directory 
```[shell]
git clone https://github.com/rlevitin/readNCDB.git
cd readNCDB
```
Edit the readNCDB.R file.
- `datafolder`: Name of the NCDB_PUF_DATA folder?
- `datfile`: Name of the .dat file with the raw data
- `dctfile`: Name of the .do file with the stata reading instructions.

In some cases there are variables that are numeric until a threshold, and then they behave as factors. Include these variables in `.levels_map_ignore`. 

- For example, [`Age`](http://ncdbpuf.facs.org/content/age-diagnosis) is defined as:

    | value  | label                         |
    | ------ | ----------------------------- |
    | 0      | < 1 yr old including in utero |
    | 1 - 89 | numeric                       |
    | 90     | 90+ yrs old                   |
    | 999    | unknown                       |
 
If you do not include `Age` in the `.levels_map_ignore`, the column will be converted to a factor and only 0, 90, 999 will be labeled, with everything else converted to "NA"

You can save the raw data file and the dictionary itself, the labeled_data, or all 3.

```[R]
datafolder <- "NCDB_PUF_DATA_Jun-18-2018"
dctfile <- here::here(datafolder,"NCDB_PUF_Labels_2015.do") # path to .do file
datfile <- here::here(datafolder,"NCDBPUF_Breast.0.2015.dat.dat") # path to .dat file

write_rds(data, path = here::here(datafolder,"data.rdata"))
write_rds(dict, path = here::here(datafolder,"dict.rdata"))
write_rds(dat1, path = here::here(datafolder,"labeled_data.rdata"))
```

## NCDB Data Dictionaries
- [Main NCDB Data Dictionary](http://ncdbpuf.facs.org/) (note -- in my experience, for some reason this website frequently has the connection time out)
- [CS_SITESPECIFIC_CODEs](http://web2.facs.org/cstage0205/schemalist.html)

## Packages used
Requires the `R` packages `tidyverse` and `here`
