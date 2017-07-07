

dt_mturk_2010_p123_post <- l_tables[["dt_mturk_2010_p123_post"]]
dt_mturk_2010_p123_entry <- l_tables[["dt_mturk_2010_p123_entry"]]
dt_mturk_2010_p123_average_response <- l_tables[["dt_mturk_2010_p123_average_response"]]
v_s_1 <- getSharedCols(dt_mturk_2010_p123_post, dt_mturk_2010_p123_entry)
isColsUniqueIdentifier(dt_mturk_2010_p123_post, v_s_1)
isColsUniqueIdentifier(dt_mturk_2010_p123_entry, v_s_1)

v_s_2 <- getSharedCols(l_tables[["dt_mturk_2010_p123_average_response"]], l_tables[["dt_mturk_2010_p123_entry"]])

isColsUniqueIdentifier(dt_mturk_2010_p123_entry, v_s_2)
isColsUniqueIdentifier(dt_mturk_2010_p123_average_response, v_s_2)


nrow(dt_mturk_2010_p123_entry)
nrow(dt_mturk_2010_p123_average_response)
dt_1 <- merge(dt_mturk_2010_p123_entry,dt_mturk_2010_p123_average_response, by = v_s_2, all = TRUE)

nrow(dt_1)


dt_mturk_2010_p123 <- leftMerge(dt_mturk_2010_p123_entry,
                                dt_mturk_2010_p123_average_response, 
                                v_s_by =  c("page_id", "tab_number" ))

#TODO merge dt_mturk_2010_p123_post with dt_mturk_2010_p123 twice
# once for context and the other for response

dt_mturk_2010_p123_post[ , context_triple_index := triple_index]
dt_mturk_2010_p123_post[ , response_triple_index := triple_index]


getSharedCols(dt_mturk_2010_p123, dt_mturk_2010_p123_post)

isColsUniqueIdentifier(dt_mturk_2010_p123_post, c("p123_triple_id", "context_triple_index"))

names(dt_mturk_2010_p123_post)

isColsUniqueIdentifier(dt_mturk_2010_p123, "p123_triple_id",)



getSharedCols(l_tables[["dt_post"]], dt_mturk_2010_p123)
getSharedCols(l_tables[["dt_post"]], dt_mturk_2010_p123_post)



dt_mturk_2010_p123[ , count_id := .N, by = "p123_triple_id"]
i_nrow <- nrow(dt_mturk_2010_p123)
dt_2 <- dt_mturk_2010_p123[ count_id > 1]
View(dt_mturk_2010_p123_post)
