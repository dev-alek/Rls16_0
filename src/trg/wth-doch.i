/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/18/03
Author: Bakhtadze Natalya
Creation date: 11/18/03

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table tt-wth-doc no-undo like ub.wth-doc.

procedure wth-doch_write-wth-doc-history :
define parameter buffer buf_wth-doc for tt-wth-doc.
define input parameter p-doc-code  like ub.wth-doc.doc-code no-undo .
define input parameter p-host-code like ub.wth-doc.host-code no-undo .
define input parameter p-obj-type  like ub.wth-doc.obj-type no-undo .
define input parameter p-obj-code  like ub.wth-doc.obj-code no-undo .

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-message as character no-undo .
define variable varobj-date as date no-undo .
define variable varshift-date as date no-undo .
define variable varshift-num as integer no-undo .
define variable varshift-name as character no-undo.
define variable l-shift-on as logical no-undo .
define variable v-create-hist as logical no-undo .
define variable v-result as character no-undo .

define buffer buf_c-wth-doc for ub.c-wth-doc.
define buffer buf_c-wth-line for ub.c-wth-line.
define buffer buf_c-wth-dtl for ub.c-wth-dtl.
define buffer prev_c-wth-line for ub.c-wth-line.
define buffer prev_c-wth-dtl for ub.c-wth-dtl.


do
on error undo, return error return-value
:

  run cur-time in this-procedure(output v-date, output v-time).

  { gbl/curobjdt.i
    p-obj-type
    p-obj-code
    varobj-date
    no-error
  }
  if error-status :error
  or varobj-date = ?
  then do:
   v-message = substitute("Нет текущей даты на объекте документа МЦ &1 &2&3&4&5 &6"
                , buf_wth-doc.doc-code
                , p-obj-type
                , p-obj-code
                , {&new-line}
                , error-status:get-message(1)
                , return-value
                ).


    undo, return error v-message.
  end.

  { gbl/objat.i
    p-obj-type
    p-obj-code
    "'shift-on=request'"
    l-shift-on
  }
  if l-shift-on then do:
    /* на объекте включены смены */
    { gbl/curshift.i
      p-obj-type
      p-obj-code
      varshift-date
      varshift-num
      varshift-name
      no-error
    }
    /*
    if error-status :error then do:
      v-message = substitute("!!!Ошибка при поиске текущей смены на объекте документа МЦ &1 &2&3&4&5 &6"
                , buf_wth-doc.doc-code
                , p-obj-type
                , p-obj-code
                , {&new-line}
                , error-status:get-message(1)
                , return-value
                ).
      undo, return error v-message.
    end.
    */
  end.
  else do:
    assign
      varshift-date = ?
      varshift-num  = ?
      varshift-name = ?
    .
  end.

  create buf_c-wth-doc.
  buffer-copy buf_wth-doc to buf_c-wth-doc
  assign
  buf_c-wth-doc.doc-code           = p-doc-code
  buf_c-wth-doc.obj-type           = p-obj-type
  buf_c-wth-doc.obj-code           = p-obj-code
  buf_c-wth-doc.host-code          = p-host-code
  buf_c-wth-doc.chip-num           = next-value (s-corr-chip, {&db-name_schema})
  buf_c-wth-doc.corr-time          = v-time
  buf_c-wth-doc.corr-user-db-num   = g#db-num
  buf_c-wth-doc.corr-user-name     = g#userid
  buf_c-wth-doc.corr-date          = varobj-date  /*здесь дата объекта*/
  buf_c-wth-doc.corr-inkas-code    = "":U /*todo*/
  buf_c-wth-doc.corr-shift-date    = varshift-date
  buf_c-wth-doc.corr-shift-num     = varshift-num
  buf_c-wth-doc.corr-shift-name    = varshift-name
  buf_c-wth-doc.real-corr-date     = v-date
  .

  for each ub.wth-line where
          ub.wth-line.doc-code = buf_wth-doc.doc-code:
    create buf_c-wth-line.
    buffer-copy ub.wth-line to buf_c-wth-line
    assign
    buf_c-wth-line.chip-num           = buf_c-wth-doc.chip-num
    buf_c-wth-line.corr-user-db-num   = buf_c-wth-doc.corr-user-db-num
    .
  end.
  for each ub.wth-dtl where
          ub.wth-dtl.doc-code = buf_wth-doc.doc-code:
    create buf_c-wth-dtl.
    buffer-copy ub.wth-dtl to buf_c-wth-dtl
    assign
    buf_c-wth-dtl.chip-num           = buf_c-wth-doc.chip-num
    buf_c-wth-dtl.corr-user-db-num   = buf_c-wth-doc.corr-user-db-num
    .
  end.
    release buf_c-wth-doc.
end. /*doe*/

end procedure. /* wth-doch_write-wth-doc-history */

/* $Workfile$ e n d */