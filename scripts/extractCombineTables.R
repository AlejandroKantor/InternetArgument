rm(list=ls())
library(data.table)
library(RMySQL)
library(akmisc)

leftMerge <- function(dt_left, dt_right, v_s_by){ # => data.table
  stopifnot(isColsUniqueIdentifier(dt_right, v_s_by))
  setkeyv(dt_right, v_s_by)
  setkeyv(dt_left, v_s_by)
  dt_merged <- dt_right[dt_left]
  return(dt_merged)
}

con <- dbConnect(MySQL(),
                 user = 'root',
                 password = 'diciembrE2016',
                 host = 'localhost',
                 dbname='fourforums')
v_s_tables <- dbListTables(con)
print(v_s_tables)

v_s_tables_of_interest <- c("post", 
                            "text",
                            "discussion",
                            "discussion_topic",
                            "topic",
                            "mturk_2010_qr_entry",
                            "mturk_2010_qr_task1_average_response",
                            "quote")

stopifnot(all(v_s_tables_of_interest %in% v_s_tables))

l_tables <- list()
for(s_table in v_s_tables_of_interest){
  l_tables[[paste0("dt_",s_table)]] <- data.table(dbReadTable(con, s_table))
}

stopifnot(isColsUniqueIdentifier(l_tables[["dt_text"]], "text_id"))



dt_data <- leftMerge(l_tables[["dt_text"]], l_tables[["dt_post"]], "text_id" )
dt_data <- leftMerge(dt_data, l_tables[["dt_discussion"]], "discussion_id" )
dt_data <- leftMerge(dt_data, l_tables[["dt_discussion_topic"]], "discussion_id" )
dt_data <- leftMerge(dt_data, l_tables[["dt_topic"]], "topic_id" )

dt_freq_topic <- freqTable(dt_data, "topic", b_include_perc = TRUE,b_total_row = TRUE, s_order_by = "descending")

#-------------------------------------------------------------------------------------
# Add Mechanical turk ada

dt_mturk <- leftMerge(l_tables[["dt_mturk_2010_qr_entry"]], 
                                 l_tables[["dt_mturk_2010_qr_task1_average_response"]], 
                                 c("page_id","tab_number"))

dt_post_text_id <- l_tables[["dt_post"]]
dt_post_text_id <- dt_post_text_id[ , c("discussion_id", "post_id" , "text_id")]

dt_mturk <- leftMerge(dt_mturk, 
                      dt_post_text_id, 
                      c("discussion_id", "post_id" ))


isColsUniqueIdentifier(dt_mturk, c("discussion_id", "post_id" ))
isColsUniqueIdentifier(dt_mturk, c("discussion_id", "post_id", "tab_number" ))
isColsUniqueIdentifier(dt_mturk, c("page_id" ,"discussion_id", "post_id" ))

dt_freq_mturk <- freqTable(dt_mturk, c("text_id" ),s_order_by = "descending")

dt_mturk_sample <- dt_mturk[ text_id == 478479]

isColsUniqueIdentifier(dt_mturk, c("text_id", "discussion_id", "post_id"))


isColsUniqueIdentifier(dt_data, c("text_id", "discussion_id", "topic_id"))
isColsUniqueIdentifier(dt_data, c("text_id" ))

intersect(names(dt_data), names(dt_mturk))

#
# dt_data <- leftMerge(dt_data, dt_mturk, c("page_id" ,"discussion_id", "post_id" ))


names(dt_data)

freqTable(dt_data, "topic", b_include_perc = TRUE, s_order_by = "descending")

