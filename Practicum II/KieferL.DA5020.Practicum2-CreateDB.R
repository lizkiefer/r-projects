#
# Creating a Relational Analytics Database
#
# Author: Liz Kiefer
# Date: Spring 2025
# Status: Finished


# Check if each package is installed, and install it if necessary
required_packages <- c("DBI", "RSQLite")
for (pkg in required_packages) {
  if (!pkg %in% installed.packages()[, "Package"]) {
    install.packages(pkg, repos = "https://cloud.r-project.org/")
  }
}

library(RSQLite)
db_Conn <- "hospital-beds.sqlitedb"


if (file.exists(db_Conn)) {
  file.remove(db_Conn)
}

conn <- dbConnect(RSQLite::SQLite(), db_Conn)

# Clear existing tables
dbExecute(conn, " drop table if exists BED_FACTS")
dbExecute(conn, " drop table if exists FACILITY")
dbExecute(conn, " drop table if exists BED_CATEGORIES")

# Bed_Facts Table 
dbExecute(conn, "
CREATE TABLE if not exists BED_FACTS (
  IMSID TEXT,
  CATID INTEGER,
  LICENSED INTEGER,
  CENSUS INTEGER,
  STAFFED INTEGER,
  PRIMARY KEY (IMSID, CATID),
  FOREIGN KEY (IMSID) REFERENCES FACILITY(IMSID),
  FOREIGN KEY (CATID) REFERENCES BED_CATEGORIES(CATID)
)
")


# Facility Table 
dbExecute(conn, "
CREATE TABLE if not exists FACILITY (
  IMSID TEXT PRIMARY KEY,
  NAME TEXT,
  TTL_LICENSED INTEGER,
  TTL_CENSUS INTEGER,
  TTL_STAFFED INTEGER
)
")


# Bed_Categories Table 
dbExecute(conn, "
CREATE TABLE if not exists BED_CATEGORIES (
  CATID INTEGER PRIMARY KEY,
  CATEGORY TEXT UNIQUE,
  DESCR TEXT
)
")

dbDisconnect(conn)
