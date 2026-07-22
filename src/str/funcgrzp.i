/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функция возвращает Полное название Грузополучатекл

Автор: Чернова Светлана Александровна
Дата создания: 08/29/08
Author: Svetlana Chernova
Creation date: 08/29/08

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function funcgrzp returns character
( input p-par-code as char  ,
  input p-par-value as char ) .
def buffer buf_clients for ub.clients .
define variable v-type as character no-undo .
define variable v-code as integer   no-undo .
if lookup(p-par-code,{&trdcattr-recipient}) = 0  then return "".
assign
  v-type = substring(p-par-value,1,3)
  v-code = int(substring(p-par-value,4,15) )
.
if error-status :error then return "".


find first buf_clients no-lock where
           buf_clients.obj-type = v-type and
           buf_clients.obj-code = v-code
           no-error .
           if error-status :error then return "" .
return buf_clients.obj-name .
end function.
