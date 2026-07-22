/*

$Revision: $
$Author: $
$Date$
$Workfile: $
$Archive: $

Описание файла

Автор: Комаров Иван Сергеевич
Дата создания: 06/15/11
Author: Ivan Komarov
Creation date: 06/15/11

*/

&if "{1}" = "def" &then

define temp-table temp-err no-undo  LIKE ub.rep-line
  field str as character
  field gds-code as integer
index pi is primary unique  gds-code
.

&endif

procedure view-exept-gds :
define input  parameter p-str as character no-undo .

define variable loc-ok as logical   no-undo .
  do
  on error undo, return error return-value
  :
  message p-str
           view-as alert-box question
           buttons yes-no
           update loc-ok
            .
if loc-ok then
    run gbl/tt-view.w
    ( input table  temp-err ).
  end.
end procedure. /* view-exept-gds */

/*--------*/
procedure creat-tt :
  do
  on error undo, return error return-value
  :
    define input  parameter p-gds-code as integer   no-undo .
    define input  parameter p-str as character no-undo .
    find first temp-err where
               temp-err.gds-code = p-gds-code no-error .
               if available temp-err then return .

    if p-str  <> "" then do:
       create temp-err.
       assign
         temp-err.gds-code = p-gds-code
         temp-err.str = p-str
     .
    end.
  end.
end procedure. /* creat-tt */

/* $Workfile$ e n d */