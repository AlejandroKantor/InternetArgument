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

getSharedCols <- function(dt_left, dt_right){
  return(intersect(names(dt_left),names(dt_right)))
}


#--------------------------------------------------------------------------------

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
                            "mturk_2010_p123_post",
                            "mturk_2010_p123_entry",
                            "mturk_2010_p123_average_response",
                            "quote")

stopifnot(all(v_s_tables_of_interest %in% v_s_tables))

l_tables <- list()
for(s_table in v_s_tables_of_interest){
  l_tables[[paste0("dt_",s_table)]] <- data.table(dbReadTable(con, s_table))
}
#disconnect from DB
lapply( dbListConnections( dbDriver( drv = "MySQL")), dbDisconnect)

#--------------------------------------------------------------------------------
dt_text <- l_tables[["dt_text"]]
dt_quote <- l_tables[["dt_quote"]]

dt_quote <- leftMerge(dt_quote, dt_text, "text_id")

dt_post <- l_tables[["dt_post"]]
dt_post <- leftMerge(dt_post, dt_text, "text_id")

# change names of text_id and text
setnames(dt_post, c("text_id","text"), c("text_response_id", "full_response_post"))
setnames(dt_quote, c("text_id","text"), c("text_quote_id", "quote"))

v_s_dis_post_id <- c("discussion_id" , "post_id" ) 

dt_quote <- leftMerge(dt_quote, dt_post, v_s_dis_post_id)
names(dt_quote)

#------------------------------------------------------------------------------------------------------
dt_mturk <- leftMerge(l_tables[["dt_mturk_2010_qr_entry"]],
                      l_tables[["dt_mturk_2010_qr_task1_average_response"]],
                      c("page_id","tab_number"))

v_s_id <- getSharedCols(dt_quote, dt_mturk)
isColsUniqueIdentifier(dt_quote, v_s_id)

# remove cases which have ambigious IDs  
dt_mturk[ , count_id := .N, by = v_s_id]
i_nrow <- nrow(dt_mturk)
dt_mturk <- dt_mturk[ count_id == 1]
i_observations_lost <- i_nrow - nrow(dt_mturk)
dt_mturk[ , count_id := NULL]
# 40 cases removed

dt_quote <- leftMerge(dt_quote, dt_mturk, v_s_id)
#------------------------------------------------------------------------------------------------------
#topic 
dt_topic <- leftMerge( l_tables[["dt_discussion_topic"]], l_tables[["dt_topic"]], "topic_id" )

setnames(dt_quote, "topic", "topic_mturk")
dt_quote <- leftMerge(dt_quote, dt_topic, "discussion_id")

#------------------------------------------------------------------------------------------------------

# having problems with multibyte 
# dt_quote[ , response:= substr(full_response_post, text_offset + 1, 
#                               ifelse(!is.na(response_text_end), 
#                                      response_text_end  - text_offset,
#                                      1000000L))]

v_s_order <- c("post_id", 
               "quote_index", 
               "response_text_end", 
               "presented_quote", 
               "presented_response", 
               "term", 
               "topic_id",
               "topic", 
               "topic_mturk",
               "text_response_id", 
               "full_response_post", 
               "author_id", 
               "creation_date", 
               "parent_post_id", 
               "parent_missing", 
               "text_quote_id", 
               "quote", 
               "parent_quote_index", 
               "text_offset", 
               "source_discussion_id", 
               "source_post_id", 
               "source_start", 
               "source_end", 
               "truncated", 
               "altered",
               "page_id", 
               "tab_number", 
               "num_annots", 
               "disagree_agree", 
               "disagree_agree_unsure", 
               "attacking_respectful", 
               "attacking_respectful_unsure", 
               "emotion_fact", 
               "emotion_fact_unsure", 
               "nasty_nice", 
               "nasty_nice_unsure", 
               "sarcasm_yes", 
               "sarcasm_no", 
               "sarcasm_unsure", 
               "discussion_id"
)

setcolorder(dt_quote, v_s_order)

# write.csv(dt_quote, file="./data/output/quoteResponseMTurk.csv" ,row.names = FALSE)
save(dt_quote, file="./data/output/quoteResponseMTurk.RData" )

dt_agg <- dt_quote[ ,.(count = .N, 
             count_wth_mturk = sum(!is.na(sarcasm_yes)),
             mean_sarcasm_yes = mean(sarcasm_yes,na.rm = TRUE)), by = .(topic)]
dt_total <- dt_quote[ ,.(topic = "TOTAL",
                         count = .N, 
                         count_wth_mturk = sum(!is.na(sarcasm_yes)),
                         mean_sarcasm_yes = mean(sarcasm_yes,na.rm = TRUE))]
dt_agg <- rbindlist(l=list(dt_agg, dt_total))
write.csv(dt_agg, "./data/output/summaryCounts.csv",row.names = FALSE)
