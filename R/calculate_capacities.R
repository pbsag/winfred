# Highway link calculator
library(dplyr)
library(foreign)
library(readr)
library(tidyr)
library(hcmr)

# === Data input =========
# command line arguments
args <- commandArgs(trailingOnly = TRUE)
link_file <- args[1]      # se data file for scenario year
output_file <- args[2]   # output file

# read link table coming out of area type model.
links <- read.dbf(link_file, as.is = TRUE)

  
links <- links %>%
  # restructure link variables for hcm_calculate
  transmute(
    A, B,
    # map area types into hcmr definitions
    ATYPE,
    at = ifelse(ATYPE <= 2, "Urban",
                ifelse(ATYPE <= 4, "Suburban", "Rural")),
    # map facility types into hcmr definitions
    FACTYPE,
    ft = ifelse(
      # expressways
      FACTYPE <= 2, "Freeway",
      ifelse(
        # major and principal arterials
        FACTYPE <= 4, "PrArterial",
        ifelse(
          # minor arterials
          FACTYPE == 5, "MinArterial",
          ifelse(
            # collectors
            FACTYPE <= 7, "Collector",
            ifelse(
              # local roads
              FACTYPE == 8, "Local",
              ifelse(
                # high-speed ramps
                FACTYPE == 9, "Freeway",
                ifelse(
                  # low-speed ramps
                  FACTYPE == 10, "MLHighway",
                  "CC")
                )
              )
            )
          )
        )
      ),
    ft = ifelse(
      # rural arterials should be highways
      at == "Rural" & ft %in% c("PrArterial", "MinArterial"),
      # which type depends on number of lanes
      ifelse(LANES == 1, "TLHighway", "MLHighway"),
      ft
    ),
    med = "Restrictive",
    terrain = "rolling",
    lanes = LANES,
    sl = POST_SPD,
    
    # get freeflow speed and capacity
    ffspeed = hcm_calculate(ft = ft, at = at, sl = sl, terrain = terrain,
                            lanes = lanes, LOS = "E", speed = TRUE),
    capd    = hcm_calculate(ft = ft, at = at, sl = sl, terrain = terrain,
                            lanes = lanes, LOS = "D", speed = FALSE),
    cape    = hcm_calculate(ft = ft, at = at, sl = sl, terrain = terrain,
                            lanes = lanes, LOS = "E", speed = FALSE)
  ) %>%

  transmute(
    A, B,
    # defaults for facility connectors
    ffspeed = ifelse(FACTYPE == 11, 25, ifelse(FACTYPE == 12, 55, ffspeed)),
    capd    = ifelse(FACTYPE == 11, 10000, ifelse(FACTYPE == 12, 100000, capd)),
    cape    = ifelse(FACTYPE == 11, 10000, ifelse(FACTYPE == 12, 100000, cape)),
    # VDOT requested hard-coded ramp capacities to replace HCM-methodology
    # 1500 vphpl reached as compromise between HCM base value of 1800
    # and other VDOT models where 1000 is used.
    cape = ifelse(FACTYPE == 9, 1500 * lanes,
      ifelse(FACTYPE == 10, 1300 * lanes, cape))
  )

write.dbf(links, output_file)
