## Code to convert a STATA .do label file from NCDB into a well-structured tibble dictionary for use in R analysis
# Adapted from Alex Bokov PhD (github.com/bokov), credit to him
library("tidyverse")
library("here")

# Example folder setting:
datafolder <- "NCDB_PUF_DATA_Jun-18-2018"
dctfile <- here::here(datafolder,"NCDB_PUF_Labels_2015.do") # path to .do file
datfile <- here::here(datafolder,"NCDBPUF_Breast.0.2015.dat.dat") # path to .dat file

#' Do not remap the following variables specified by `r basename(dctfile)` because they are mostly numeric with 
#' only some factor levels, e.g., Age numeric 0-90, 90 = 90+, 999 = unknown
.levels_map_ignore <- c(
  'AGE',
  'DX_LASTCONTACT_DEATH_MONTHS' ,
  'REGIONAL_NODES_EXAMINED',
  'REGIONAL_NODES_POSITIVE',
  'RAD_ELAPSED_RX_DAYS',
  'RAD_NUM_TREAT_VOL' ,
  'RAD_REGIONAL_DOSE_CGY',
  'TUMOR_SIZE'
)

# make data dictionary ---------------------------------------------------------
#' Create the data dictionary
.dctraw <- readr::read_lines(dctfile) %>%
  # blow away the non UTF-8 characters
  gsub('\x93|\x94','"',.) %>% gsub('\x96','-',.)

dct0 <- full_join(
  # variable name mappings
  .dctraw[grep('^label var',.dctraw)] %>% 
    gsub('label var |\t','',.) %>% 
    paste0(collapse='\n') %>% 
    read_delim('"',trim_ws = T,col_names=F) %>% 
    select(1:2) %>% 
    rename(colname=X1, colname_long=X2)
  # variable data types and offests for the FWF NCDB data
  ,.dctraw[grep('^infix ',.dctraw):(grep('[ ]+using ',.dctraw)-1)] %>%
    gsub('(\\s|infix|-)+',' ',.) %>%
    paste0(collapse='\n') %>%
    read_delim(.,' ',trim_ws=T,col_names = F) %>%
    select(1:4) %>% 
    rename(type = X1, colname = X2, start = X3, stop = X4)
);

if(nrow(dct0)!=length(grep('^label var',.dctraw))) {
  stop('Data dictionary mismatch the "make data dictionary" section of dictionary.R')};
#'
# level names ------------------------------------------------------------------
dict <- data.frame(lstart=grep('^label define',.dctraw)
                         ,lstop=grep('^label values',.dctraw)) %>% 
  cbind(.,name=gsub('label define ([A-Z0-9_]+).*','\\1'
                    ,.dctraw[.$lstart]),stringsAsFactors=F) %>% 
  pmap(~ .dctraw[seq(..1+1, ..2-1)] %>% 
    gsub('\t', '', .) %>% # if there is no "\n" read_delim thinks it is a path name instead of a filename
    c(NA, .) %>% 
    paste0(collapse='\n') %>% 
    read_delim('"', col_names = F, trim_ws = T, skip = 1) %>% 
    select(1:2) %>% 
    mutate(X3 = ..3)
  ) %>% {
  tibble(code = map(., "X1") %>% unlist %>% map_dbl(as.numeric), 
         label = map(., "X2") %>% unlist %>% map_chr(as.character),
         varname = map(., "X3") %>% unlist %>% map_chr(as.character))
  } %>% 
  subset(!varname %in% .levels_map_ignore);

 data <- read_fwf(datfile, 
         col_positions = fwf_positions(dct0$start, dct0$stop, dct0$colname), 
         col_types = set_names(recode(dct0$type, str = 'c', int = 'i', long = 'd', float = 'd', byte = 'i'), dct0$colname)
         )
 
factorclean <- function(xx, spec_mapper, var, fromto = c('code', 'label')) {
   if (!is.factor(xx)) xx <- factor(xx)
   
   lvls <- levels(xx)
   
   lookuptable <- subset(spec_mapper, varname == var)[, fromto]  
   
   out <- factor(xx, levels = lookuptable$code)
   
   levels(out) <- lookuptable$label
   
   return(out)
 }
 
 dat1 <- data
 
 for(.ii in unique(dict$varname)){
   dat1[[.ii]] <- factorclean(dat1[[.ii]], spec_mapper = dict, var = .ii)
 }
# save out ---------------------------------------------------------------------
#' ## Save all the processed data to an rdata file 
write_rds(data, path = here::here(datafolder,"data.rdata"))
write_rds(dict, path = here::here(datafolder,"dict.rdata"))


write_rds(dat1, path = here::here(datafolder,"labeled_data.rdata"))
