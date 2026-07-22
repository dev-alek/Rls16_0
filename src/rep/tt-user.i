define temp-table tt-user-account no-undo
field user-id_  as character LABEL "ID"  
field user_name as character LABEL "Имя пользователя"  
field db-num    as integer   LABEL "БД "  
field flg       as logical   LABEL "*" format "*/"
field flg2      as logical
index pi db-num user-id_
.
 
define temp-table tt-objects  no-undo 
field name_ as character
field table_ as character
field flg    as logical  LABEL "*" format "*/"
field flg2   as int
.


define temp-table tt-user-account2 no-undo
field user-id_  as character LABEL "ID"  
field user_name as character LABEL "Имя пользователя"  
field db-num    as integer   LABEL "БД "  
field flg       as logical   LABEL "*" format "*/"
field flg2      as logical
index pi db-num user-id_
.

define temp-table tt-objects2  no-undo 
field name_ as character
field table_ as character
field flg    as logical  LABEL "*" format "*/"
field flg2   as int
.

