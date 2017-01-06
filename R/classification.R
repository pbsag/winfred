library(dplyr)
library(tidyr)
library(foreign)
library(readr)

# === Helper Functions =====
#' Some lookup values lie outside of the range defined by the census data. For
#' these, we use either the minimum or maximum value of the range as
#' appropriate. This function makes doing that easy.
fix_range <- function(x, class){
  ifelse(x < min(class$avg), min(class$avg),  # use the minimum if below range
         ifelse(x > max(class$avg), max(class$avg), # maximum if above range.
         x))
}


# === Data input =========
# command line arguments
args <- commandArgs(trailingOnly = TRUE)
se_file <- args[1]      # se data file for scenario year
lookup_dir <- args[2]   # directory where lookup files can be found
outputfile <- args[3]   # output file

# read lookup tables to get the household seed from CTPP and the marginal
# classification functions.

hhseed <- read.dbf(file.path(lookup_dir, "hh_seed.dbf"), as.is = TRUE) %>%
  tbl_df() %>%
  mutate_each(funs(as.numeric(.))) %>%
  mutate(share = ifelse(share == 0, 0.0001, share)) # don't allow zero target values

class_size <- read.dbf(file.path(lookup_dir, "hh_size_lookup.dbf")) %>% tbl_df()
names(class_size) <- tolower(names(class_size))
class_work <- read.dbf(file.path(lookup_dir, "hh_worker_lookup.dbf")) %>% tbl_df()
names(class_work) <- tolower(names(class_work))
class_veh <- read.dbf(file.path(lookup_dir, "hh_vehicle_lookup.dbf")) %>% tbl_df()
names(class_veh) <- tolower(names(class_veh))


# read land use and extract se information for year
year <- 15
taz <- read.dbf(se_file) %>% tbl_df()


# == Compute initial margin targets for IPF =============

households <- taz %>%
  
  # calculate average household size, workers, and vehicles in a zone
  transmute(
    Z,
    hh = HH,
    size = POP / hh,
    work = WORK/ hh,
    veh =  VEH / hh
  )  %>%
  
  # only attempt to IPF if there are households in the zone
  filter(hh > 0) %>%
  
  # match classification tables on two decimal places
  mutate_each(funs(round(., digits = 2)), size:veh) %>%
  
  # if the lookup value is outside the range of the data, set to min or max
  mutate(
    size = fix_range(size, class_size),
    work = fix_range(work, class_work),
    veh = fix_range(veh, class_veh)
  ) %>%

  # join marginal classification tables
  left_join(class_size, by = c("size" = "avg")) %>%
  left_join(class_work, by = c("work" = "avg")) %>%
  left_join(class_veh,  by = c("veh"  = "avg")) %>%
  
  # reshape into "long" format for easy arithmetic
  gather(persons, p_share, persons_1:persons_4) %>%
  gather(workers, w_share, workers_0:workers_3) %>%
  gather(vehicles, v_share, vehicles_0:vehicles_3) %>%
  mutate_each(funs(as.numeric(gsub("[^0-9]", "", .))), c(persons, workers, vehicles))

# == Iterative Proportional Fitting =============
# fill the joint distribution table based on a seed table from the CTPP,
# ensuring through iterations that the mariginals are effectively unaffected.

# list of marginal targets to iterate over
marginals <- c("p_share", "w_share", "v_share")
maxiterations <- 50

# append initial seed matrix to zonal data frame
households <- households %>%
  mutate_each_(funs(ifelse(. == 0, 0.001, .)), marginals) %>%  # don't allow zero marginals
  left_join(hhseed)

households <- households %>%
  mutate(share = ifelse(is.na(share)==T,0,share))

# vector to store convergence information
gap <- vector("list", length(marginals))
names(gap) <- marginals

for(i in 1:maxiterations){  # principal IPF loop
  
  for(m in marginals){  # loop over marginals
    
    # adjust matrix cells
    households <- households %>%
      
      # calculate marginal sum *within each zone*
      group_by_("Z", m) %>%
      mutate_("margin" = m) %>%
      mutate(
        previous = share,
        share = (share / sum(share)) * margin,
        gap = share - previous   # measure change in share to check convergence
      )
    
    # calculate maximum change in cell
    gap[[m]] <- abs(max(households$gap))
    
    #print(unlist(gap))
    
  }
  
  # show to debug convergence criteria
  # print(unlist(gap))
  
  # check to see whether convergence is reached for all marginals
  if(all(unlist(gap) < 0.01)){
    break
  }
  
}
  
# == Determine number of households in each category ========
classified_households <- ungroup(households) %>%
  mutate(number = share * hh) %>%
  mutate(
    nwrk_class = paste("p", persons, "v", vehicles, sep = ""),
    work_class = paste("w", workers, "v", vehicles, sep = "")
  )  %>%
  select(Z, number, nwrk_class, work_class)
  
work_hh <- classified_households %>%
  group_by(Z, work_class) %>%
  summarise(number = round(sum(number), 2)) %>%
  spread(work_class, number, fill = 0)
  
nwrk_hh <- classified_households %>%
  group_by(Z, nwrk_class) %>%
  summarise(number = round(sum(number), 2)) %>%
  spread(nwrk_class, number, fill = 0)

# join back to taz layer for export
taz_export <- taz %>%
  left_join(work_hh, by = "Z") %>%
  left_join(nwrk_hh, by = "Z") %>%
  arrange(Z)
  
write.dbf(as.data.frame(taz_export), outputfile)
