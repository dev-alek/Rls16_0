/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет о движении материальных ценностей: общая часть расчетов

Автор: Гридчина Полина Дмитриевна
Дата создания: 09/13/06
Author: Polina Gridchina
Creation date: 09/13/06

*/

if first-of( bf_wth-line.wth-code )
then do:
  assign
    fact-order_from = bf_wth-doc.fact-order
  .
  find first tt_line where
             tt_line.obj-type   = bf_object.obj-type    and
             tt_line.obj-code   = bf_object.obj-code    and
             tt_line.shift-date = bf_wth-doc.shift-date and
             tt_line.shift-num  = bf_wth-doc.shift-num  no-error .
  if not available tt_line
  then do:
    run create-tt_line in this-procedure
      (  input bf_object.obj-type
      ,  input bf_object.obj-code
      ,  input bf_object.obj-name
      ,  input bf_clients.obj-type
      ,  input bf_clients.obj-code
      ,  input bf_clients.obj-name
      ,  input bf_wth-doc.shift-date
      ,  input bf_wth-doc.shift-num
      , output r-rec-line
      ) no-error .
    if error-status :error or
       r-rec-line = ?
    then do:
      undo, return error return-value .
    end.
    find first tt_line where
        recid( tt_line ) = r-rec-line .
  end. /* if not available tt_line */
end. /* if first-of( bf_wth-line.wth-code ) */

if bf_wth-doc.cli-type = bf_sysconf.sale-type and
   bf_wth-doc.cli-code = bf_sysconf.sale-code and
 ( bf_wth-doc.doc-type = {&income}            or
   bf_wth-doc.doc-type = {&expense}         ) and
   bf_wth-doc.inter_   = no
then do:
  find first tt_line where
             tt_line.obj-type   = bf_object.obj-type    and
             tt_line.obj-code   = bf_object.obj-code    and
             tt_line.shift-date = bf_wth-doc.shift-date and
             tt_line.shift-num  = bf_wth-doc.shift-num  no-error .
  if not available tt_line
  then do:
    run create-tt_line in this-procedure
      (  input bf_object.obj-type
      ,  input bf_object.obj-code
      ,  input bf_object.obj-name
      ,  input bf_clients.obj-type
      ,  input bf_clients.obj-code
      ,  input bf_clients.obj-name
      ,  input bf_wth-doc.shift-date
      ,  input bf_wth-doc.shift-num
      , output r-rec-line
      ) no-error .
    if error-status :error or
       r-rec-line = ?
    then do:
      undo, return error return-value .
    end.
    find first tt_line where
        recid( tt_line ) = r-rec-line .
  end. /* if not available tt_line */
  case bf_wth-doc.doc-type :
    when {&income}
    then do:
      assign
        tt_line.cash-sum = tt_line.cash-sum + bf_wth-line.fact-sum
      .
    end.
    when {&expense}
    then do:
      assign
        tt_line.cash-sum = tt_line.cash-sum - bf_wth-line.fact-sum
      .
    end.
  end case. /* bf_wth-doc.doc-type */
end.

if last-of( bf_wth-line.wth-code )
then do:
  assign
    fact-order_till = bf_wth-doc.fact-order
  .
  find first tt_line where
             tt_line.obj-type   = bf_object.obj-type    and
             tt_line.obj-code   = bf_object.obj-code    and
             tt_line.shift-date = bf_wth-doc.shift-date and
             tt_line.shift-num  = bf_wth-doc.shift-num  no-error .
  if not available tt_line
  then do:
    run create-tt_line in this-procedure
      (  input bf_object.obj-type
      ,  input bf_object.obj-code
      ,  input bf_object.obj-name
      ,  input bf_clients.obj-type
      ,  input bf_clients.obj-code
      ,  input bf_clients.obj-name
      ,  input bf_wth-doc.shift-date
      ,  input bf_wth-doc.shift-num
      , output r-rec-line
      ) no-error .
    if error-status :error or
       r-rec-line = ?
    then do:
      undo, return error return-value .
    end.
    find first tt_line where
        recid( tt_line ) = r-rec-line .
  end. /* if not available tt_line */
  assign
    fact-order_from = 0.00
    fact-order_till = 0.00
  .
end. /* if last-of( bf_wth-line.wth-code ) */

/* $Workfile$   E n d */