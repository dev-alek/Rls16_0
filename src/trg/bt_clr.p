block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Очистка записей BatchProcess

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 06/21/00

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Очистка записей BatchProcess".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }

do
on error undo, return error return-value
:

  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.

  run cur-time in this-procedure
    (output v-today
    ,output v-time
    ).

  define variable l-wasprocessing as logical no-undo init false .

  define buffer buf_batchprocess for batchprocess .

  for each batchprocess no-lock
    where batchprocess.bp_status = {&btpr-deleted}
  on error undo, return error return-value
  :
    if batchprocess.bp_sysdate <= v-today - 10
    and (batchprocess.bp_execsysdate = ?
        or
        batchprocess.bp_execsysdate <= v-today - 10
        )
    then do:
      do
      transaction
      on error undo, next
      :
        find first buf_batchprocess exclusive-lock
          where rowid(buf_batchprocess) = rowid(batchprocess)
          no-error no-wait .
        if available buf_batchprocess
        then do:
          delete buf_batchprocess.
          assign
            l-wasprocessing = true
          .
        end.
      end.
    end.
  end.

  if l-wasprocessing
  then do:
    return "true":u .
  end.
  else do:
    return "":u .
  end.

end.