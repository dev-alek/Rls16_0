/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры перевода из даты в разницу дней до текущей даты и обратно

Автор: Перваков Михаил Сергеевич
Дата создания: 06/15/04
Author: Mikhail Pervakov
Creation date: 06/15/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure godendo-date-to-offset :

  define input  parameter p-today  as date      no-undo .
  define input  parameter p-date   as date      no-undo .
  define output parameter p-offset as integer   no-undo .

  do
  on error undo, return error return-value
  :

    if p-date  = ?
    or p-today = ?
    then do:
      assign
        p-offset = ?
      .
    end.
    else do:
      assign
        p-offset = p-date - p-today + 1
      .
    end.
  end.

end procedure. /* godendo-date-to-offset */


procedure godendo-offset-to-date :

  define input  parameter p-today  as date      no-undo .
  define input  parameter p-offset as integer   no-undo .
  define output parameter p-date   as date      no-undo .

  do
  on error undo, return error return-value
  :
    if p-today  = ?
    or p-offset = ?
    then do:
      assign
        p-date = ?
      .
    end.
    else do:
      assign
        p-date = p-offset + p-today - 1
      .
    end.
  end.

end procedure. /* godendo-offset-to-date */

/* $Workfile$ e n d */