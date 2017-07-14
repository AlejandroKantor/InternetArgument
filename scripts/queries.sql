-CREATE TABLE fourforums.temp_mturk_posts
SELECT topic , disagree_agree , attacking_respectful , emotion_fact , nasty_nice , sarcasm_yes ,
quote_text.text AS quote,
/*SUBSTR (
fourforums.text.text,
text_offset+1,
IF(response_text_end IS NOT null ,
response_text_end - text_offset , LENGTH( fourforums.text.text ))
) AS response
*/
SUBSTR(text.text,1,2) AS response
FROM fourforums.mturk_2010_qr_entry 
NATURAL JOIN
fourforums.mturk_2010_qr_task1_average_response
NATURAL JOIN fourforums.post
NATURAL JOIN fourforums.text
JOIN fourforums.quote as tb_quote
USING( discussion_id , post_id ,
quote_index )
JOIN fourforums.text AS quote_text
ON tb_quote.text_id=quote_text.text_id 
ORDER BY sarcasm_yes DESC;

select count(*)
from fourforums.temp_mturk_posts

