block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление заказа

Автор: Чернова Светлана Александровна
Дата создания: 06/09/06
Author: Svetlana Chernova
Creation date: 06/09/06

*/


define input  parameter p-doc-code like ub.ord-doc.doc-code no-undo .
define input  parameter parphchip-num      as   integer                      no-undo.
define output parameter parchip-num        as   integer                      no-undo.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Удаление документа матценностей".
{ cmp/vssrevis.i "substitute('&1':u,p-doc-code)"}
{ cmp/trg-def.i }

do
on error undo, return error return-value
:
  define buffer buf_ord-doc for ub.ord-doc .

  define variable l-shift-on      as logical   no-undo .
  define variable varobj-date     as date                      no-undo.
  define variable varshift-date   like ub.shift-obj.shift-date no-undo.
  define variable varshift-num    like ub.shift-obj.shift-num  no-undo.

  find first buf_ord-doc exclusive-lock
    where buf_ord-doc.doc-code = p-doc-code
    no-error .
  if not available buf_ord-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "ЗАКАЗ" p-doc-code skip
      view-as alert-box error .
    undo, return error .
  end.

  { gbl/curobjdt.i buf_ord-doc.cli-type buf_ord-doc.cli-code varobj-date no-error }
  if error-status :error
  or varobj-date = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Нет текущей даты на объекте"  skip
      view-as alert-box error .
    undo, return error .
  end.


  /*создаем копию*/
  if not g#news then do:
    run hstc-ord-doc in this-procedure
      (input recid(buf_ord-doc)
      ,input varobj-date
      ,input g#userid
      ,input parphchip-num
      ,output parchip-num
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при копировании в историю удаляемых заказов" skip
        view-as alert-box error .
      undo, return error.
    end.
  end.


  define variable v-obj-type   as character no-undo .
  define variable v-obj-code   as integer   no-undo .
  define variable v-fact-order as decimal   no-undo .



  assign
    v-obj-type   = buf_ord-doc.cli-type
    v-obj-code   = buf_ord-doc.cli-code
    v-fact-order = buf_ord-doc.fact-order
  .

  delete buf_ord-doc .

end.

procedure hstc-ord-doc :

  define input parameter parrec-ord-doc as   recid                 no-undo.
  define input parameter parobj-date    as   date                    no-undo.
  define input parameter paruserid      as   character               no-undo.
  define input  parameter parphchip-num      as   integer                      no-undo.
  define output parameter parchip-num        as   integer                      no-undo.


  define buffer hstc_ord-doc          for ub.ord-doc.
  define buffer hstc_ord-line         for ub.ord-line.
  define buffer hstc_ord-dtl          for ub.ord-dtl.
  define buffer hstc_c-ord-doc        for ub.c-ord-doc.
  define buffer hstc_c-ord-line       for ub.c-ord-line.

  do
  on error undo, return error return-value
  :

    find first hstc_ord-doc
      where recid (hstc_ord-doc) = parrec-ord-doc
      .
    create hstc_c-ord-doc .
    buffer-copy hstc_ord-doc to hstc_c-ord-doc .
    assign
      hstc_c-ord-doc.chip-num        = (if parphchip-num <> ?
                                       then parphchip-num
                                       else next-value(s-corr-chip, {&db-name_schema}))
      hstc_c-ord-doc.corr-date       = parobj-date
      hstc_c-ord-doc.corr-user-name       = paruserid
    .
    for each hstc_ord-line
      where hstc_ord-line.doc-code = hstc_ord-doc.doc-code
    on error undo, return error
    :
      create hstc_c-ord-line.
      buffer-copy hstc_ord-line to hstc_c-ord-line.
      assign
        hstc_c-ord-line.chip-num = hstc_c-ord-doc.chip-num
      .
    end.
    assign
    parchip-num = hstc_c-ord-doc.chip-num
    .
  end.

end procedure.
