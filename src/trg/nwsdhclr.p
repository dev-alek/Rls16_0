block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Очистить старую историю документов, пришедших по новостям

Автор: Перваков Михаил Сергеевич
Дата создания: 05/26/03
Author: Mikhail Pervakov
Creation date: 05/26/03

*/

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Очистить старую историю документов, пришедших по новостям".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }


do
on error undo, return error return-value
:
  define buffer buf_nws-doc-hist for ub.nws-doc-hist .

  define variable v-today as date      no-undo .
  define variable v-time  as integer   no-undo .

  run cur-time in this-procedure
    (output v-today
    ,output v-time
    ) .

  /* удаляем */
  for each buf_nws-doc-hist
    where buf_nws-doc-hist.db-num = g#db-num
      and buf_nws-doc-hist.fact-date < v-today - 31
  on error undo, return error return-value
  :
    delete buf_nws-doc-hist .
  end.
end.