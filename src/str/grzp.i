/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

тригера интерфейса в заказах

Автор: Чернова Светлана Александровна
Дата создания: 08/29/08
Author: Svetlana Chernova
Creation date: 08/29/08


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

ON CHOOSE OF r-{1} IN FRAME Dialog-Frame /* r-button */
DO:
   run proc-r-{1} in this-procedure .
END.

ON LEAVE OF {1} IN FRAME Dialog-Frame /* Код */
DO:
   run leave-proc-{1} in this-procedure .
END.

procedure leave-proc-{1} :
 do
 on error undo, return error return-value
 :
define buffer {1}-clients for ub.clients.
  Assign frame {&frame-name} {1}  {1}-type .

  if {1}-type = "" then do:
     find {1}-clients no-lock where  {1}-clients.obj-code = {1} no-error.
     if not error-status :error  then
     assign
       {1}-type  =  {1}-clients.obj-type
       {1}-name  =  {1}-clients.obj-name
     .
     Display  {1} {1}-type {1}-name with frame {&frame-name}.
  end.
  else do:
     find first  {1}-clients no-lock where  {1}-clients.obj-code = {1}  and {1}-clients.obj-type  = {1}-type no-error.
     if available {1}-clients then
     assign
       {1}-type  =  {1}-clients.obj-type
       {1}-name  =  {1}-clients.obj-name
     .
     else run proc-r-{1} .
     Display  {1} {1}-type {1}-name with frame {&frame-name}.
  end.

end.
end procedure.


ON  RETURN OF {1} IN FRAME Dialog-Frame /* Код */
DO:
    if {1} = ?  then run proc-r-{1} in this-procedure .
    apply "entry" to {1}-type in frame {&frame-name}.
    return no-apply .
END.

ON MOUSE-SELECT-DBLCLICK OF {1} IN FRAME {&frame-name}
DO:
  apply "choose" to r-{1} in frame {&frame-name}.
  apply "entry" to {1} in frame {&frame-name}.
  return no-apply .
end.

Procedure proc-r-{1} :
 do
 on error undo, return error return-value
 :

  define variable rid-list    as  char no-undo . /* список recid'ов выбранных клиентов */
  define buffer {1}#clients for ub.clients.
    run ref/cli-all.w
    ( input parParentProc,
      input "b-sel",
      input {&all},
      input ?,
      input ?,
      input {2} ,
      input ",,,,,,NO"   ,
      input "",
      output  rid-list
      ) .
    Assign
      rep-rec2 = integer(rid-list)
      ref-rec = integer(rid-list)
      no-error.
    find first {1}#clients where recid({1}#clients) = rep-rec2 no-lock no-error.
    if available {1}#clients then
        Assign
            {1}      = {1}#clients.obj-code
            {1}-name = {1}#clients.obj-name
            {1}-type = {1}#clients.obj-type
             .
    Display {1} {1}-type {1}-name with frame {&frame-name} .
end.
end procedure.

/* $Workfile$ e n d */