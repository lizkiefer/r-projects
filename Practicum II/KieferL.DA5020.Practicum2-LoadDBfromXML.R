#
# Extracting and Loading the XML Data into the Database
#
# Author: Liz Kiefer
# Date: Spring 2025
# Status:  Finished

library(RSQLite)
library(XML)
xml_url <- "http://s3.us-east-2.amazonaws.com/artificium.us/datasets/HospitalBeds.xml"  

xmlObj <- xmlParse(xml_url)
hospitalList <- xpathApply(xmlObj, "//data/hospital")

# Set up temporary data frames to later load into the database
facilities <- data.frame(
  imsid = character(),
  name = character(),
  ttl_licensed = numeric(),
  ttl_census = numeric(),
  ttl_staffed = numeric(),
  stringsAsFactors = FALSE
  )

bed_facts <- data.frame(
  imsid = character(),
  catid = numeric(),
  licensed = numeric(),
  census = numeric(),
  staffed = numeric(),
  stringsAsFactors = FALSE
)

bed_categories <- data.frame(
  catid = numeric(),
  category = character(),
  descr = character(),
  stringsAsFactors = FALSE
)

cat_id <- 1

for (i in 1:length(hospitalList)) {
  imsID <- xmlAttrs(hospitalList[[i]])[["ims-org-id"]]
  name <- xmlValue(hospitalList[[i]][["name"]])
  
  beds <- xpathApply(hospitalList[[i]], "./beds/bed")
  
  ttl_licensed_beds <- 0
  ttl_census <- 0
  ttl_staffed <- 0
  
  # Loop through bed objects for the hospital
  for (j in 1:length(beds)) {
    bed <- beds[[j]]
    
    bed_type <- xmlAttrs(bed)[["type"]]
    
    # Skip any bed entries with an invalid type
    if (bed_type == "" || bed_type == "NA") {
      next
    }
    
    # Add bed counts to the sums for the hospital
    licensed_beds <- as.numeric(xmlValue(bed[["ttl-licensed"]]))
    ttl_licensed_beds <- ttl_licensed_beds + licensed_beds
    
    staff <- as.numeric(xmlValue(bed[["ttl-staffed"]]))
    ttl_staffed <- staff + ttl_staffed
    
    census <- as.numeric(xmlValue(bed[["ttl-census"]]))
    ttl_census <- census + ttl_census
    
    # Locate the category for the bed type
    current_cat_id <- -1
    if (nrow(bed_categories) > 0) {
      for (k in 1:nrow(bed_categories)) {
        if (bed_categories$category[k] == bed_type) {
          # Found matching type based on category name
          current_cat_id <- bed_categories$catid[k]
        }
      }
    }
    
    if (current_cat_id == -1) {
      # Category not found, so create and insert a new one
      desc <- xmlAttrs(bed)[["desc"]]
      bed_categories[nrow(bed_categories) + 1, ] <- c(cat_id, bed_type, desc)
      current_cat_id <- cat_id
      cat_id <- cat_id + 1
    }
    
    # Insert new row for bed type and hospital
    bed_facts[nrow(bed_facts) + 1, ] <- c(imsID, current_cat_id, licensed_beds, census, staff)
  }
  
  # Insert new row for hospital
  facilities[nrow(facilities) + 1, ] <- c(imsID, name, ttl_licensed_beds, ttl_census, ttl_staffed)
}

# Write all data
conn <- dbConnect(SQLite(), "hospital-beds.sqlitedb")
dbWriteTable(conn, "FACILITY", facilities, append = TRUE, row.names = FALSE)
dbWriteTable(conn, "BED_CATEGORIES", bed_categories, append = TRUE, row.names = FALSE)
dbWriteTable(conn, "BED_FACTS", bed_facts, append = TRUE, row.names = FALSE)

dbDisconnect(conn)
