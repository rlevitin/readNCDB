# readNCDB
Read the NCDB PUF file in R by parsing the stata .do file

Adapted from code Alex Bokov PhD (github.com/bokov).
Currently, the code is quite crude and requires manual intervention based on your local system set up, but I wanted to share in case it is of use to others.

The code parses the .do file to determine how to read the .dat file as a fixed-width file. It also parses the .do file to construct a dictionary structure which used to label the variables as factors.

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

 | value | label|
 |------|----|
 |0 | < 1 yr old including in utero|
 | 1 - 89 | numeric|
 | 90 | 90+ yrs old |
 | 999 | unknown |
 
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

## Packages used
Requires the `R` packages `tidyverse` and `here`
