procedure xml-cd-filename :
do
on error undo, return error
:
define input parameter  p-out               as character no-undo .
define output parameter p-xml-file-name     as character    no-undo.    /* возвращается имя без точки без расш.*/
define output parameter p-xml-file-name-path   as character    no-undo.  /* возвращается имя с точкой, без расш. с путем*/
define output parameter p-log-file-name     as character    no-undo.    /* возвращается полное имя с расширением */
define output parameter p-locked            as logical      no-undo.    /* yes если идет выгрузка в этот файл */

define variable v-out as character     no-undo.
define variable loc#log as logical no-undo .
define variable BadFlag as logical no-undo .
define variable fq as integer no-undo .
define variable v-remote as character no-undo .
assign
p-xml-file-name = substring( string( next-value( s-spool, {&db-name_schema}), '99999999999999999999'), 13, 8 )
p-xml-file-name-path = p-out + p-xml-file-name + ".":U
p-log-file-name = p-out + "actions.log"
p-locked = ( search ( p-xml-file-name-path + "lk" ) <> ? )
.
end.
end procedure. /* xml-cd-filename */
