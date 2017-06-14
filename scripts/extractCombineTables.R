rm(list=ls())
library(data.table)
library(RMySQL)
library(akmisc)
con <- dbConnect(MySQL(),
                 user = 'root',
                 password = 'diciembrE2016',
                 host = 'localhost',
                 dbname='fourforums')
v_s_tables <- dbListTables(con)
print(v_s_tables)

v_s_tables_of_interest <- c("post", "text","discussion","discussion_topic","topic")

stopifnot(all(v_s_tables_of_interest %in% v_s_tables))

l_tables <- list()
for(s_table in v_s_tables_of_interest){
  l_tables[[paste0("dt_",s_table)]] <- data.table(dbReadTable(con, s_table))
}

stopifnot(isColsUniqueIdentifier(l_tables[["dt_text"]], "text_id"))


leftMerge <- function(dt_left, dt_right, v_s_by){ # => data.table
  stopifnot(isColsUniqueIdentifier(dt_right, v_s_by))
  setkeyv(dt_right, v_s_by)
  setkeyv(dt_left, v_s_by)
  dt_merged <- dt_right[dt_left]
  return(dt_merged)
}

dt_data <- leftMerge(l_tables[["dt_text"]], l_tables[["dt_post"]], "text_id" )

dt_data <- leftMerge(dt_data, l_tables[["dt_discussion"]], "discussion_id" )

dt_data <- leftMerge(dt_data, l_tables[["dt_discussion_topic"]], "discussion_id" )

dt_data <- leftMerge(dt_data, l_tables[["dt_topic"]], "topic_id" )

names(dt_data)

freqTable(dt_data, "topic", b_include_perc = TRUE, s_order_by = "descending")
