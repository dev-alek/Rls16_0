/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

тригера интерфейса в заказах

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 11/15/01 5:06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&if "{1}" ="trg"   &then
ON CHOOSE OF r-{2} IN FRAME Dialog-Frame /* r-button */
DO:
   run proc-r-{2} in this-procedure .
END.

ON LEAVE OF {2} IN FRAME Dialog-Frame /* Код */
DO:
run leave-proc-{2} in this-procedure .
END.

procedure leave-proc-{2} :
 do
 on error undo, return error return-value
 :

  Assign frame {&frame-name} {2} .
  def buffer {2}-clients for ub.clients.
  if {2} <> ? OR {2} <> 0 THEN DO:
    find first {2}-clients WHERE {2}-clients.obj-type = {&prs}  AND {2} = {2}-clients.obj-code  No-LOCK No-ERROR.
    if error-status :error then error-status :error = false .
    if avail {2}-clients Then DO:
          {2}-name = {2}-clients.obj-name .
          {2}-name:screen-value  = {2}-clients.obj-name .
          Display  {2} {2}-name with frame {&frame-name}.
          Enable {2} {2}-name b-producer B-Alt-post with frame {&frame-name}.
        End.
        Else DO:
          Assign
          {2}-name:screen-value = ""
          {2}:screen-value = ?
          .
          /* Message "Неправильно задан код "  {2}:label in frame {&frame-name}. */
          apply "entry" to {2} in frame {&frame-name}.

        End.
    End.
end.
end procedure.


ON  RETURN OF {2} IN FRAME Dialog-Frame /* Код */
DO:
    if {2} = ? then run proc-r-{2} in this-procedure .
    run apply-focus-next-entry in this-procedure  (input  {2}:handle ) .
    return no-apply .
END.

ON MOUSE-SELECT-DBLCLICK OF {2} IN FRAME {&frame-name}
DO:
  apply "choose" to r-{2} in frame {&frame-name}.
  apply "entry" to {2} in frame {&frame-name}.
    return no-apply .
end.

Procedure proc-r-{2} :
 do
 on error undo, return error return-value
 :

  define variable rid-list    as  char no-undo . /* список recid'ов выбранных клиентов */
  def buffer {2}#clients for ub.clients.
    run ref/cli-all.w
    ( input parParentProc,
      input "b-sel",
      input {&prs},
      input ?,
      input ?,
      input ref-rec ,
      input ",,,,,,NO"   ,
      input "lock-cli-type",
      output  rid-list
      ) .
    Assign
      rep-rec2 = integer(rid-list)
      ref-rec = integer(rid-list)
      no-error.
    find first {2}#clients WHERE recid({2}#clients) = rep-rec2 No-LOCK No-ERROR.
    if avail {2}#clients then
        Assign
            {2} = {2}#clients.obj-code
            {2}-name = {2}#clients.obj-name .
    Enable  {2} {2}-name with frame {&frame-name} .
    Display {2} {2}-name with frame {&frame-name} .
end.
end procedure.

&else
/* MSD */
ON MOUSE-SELECT-DBLCLICK OF {2} IN FRAME {&frame-name}
DO:
  apply "entry" to {2} in frame {&frame-name}.
  apply "entry" to {3} in frame {&frame-name}.
   return no-apply .
end.

&endif
/* $Workfile$ e n d */