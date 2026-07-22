block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: trncstsl.p $
$Archive: utl/trncstsl.p $

Выбор документов и простановка кода ГТД

Автор: Чернова Светлана Александровна
Дата создания: 02/26/07
Author: Svetlana Chernova
Creation date: 02/26/07

create: Перваков Михаил Сергеевич
Дата создания: 01/11/01

*/

define input  parameter parparentproc   as   handle               no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: trncstsl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/trncstsl.p $":U .
define variable vss-description as character no-undo init "Выбор документов и простановка кода ГТД ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/strcodec.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define variable lok as logical no-undo .
define variable loc-ref-list as character no-undo .
define variable v-ind        as integer   no-undo .
define variable v-doc-rec    as integer   no-undo .

do
on error undo, return error
:

  run str/all-docs.w
    (input  parparentproc
    ,input v-cntxt-host-code-obj
    ,input v-cntxt-obj-type
    ,input v-cntxt-obj-code
    ,input  {&type}
    ,input  {&fact}
    ,input  {&income}
    ,input  ?
    ,input  false
    ,input  'b-sel,b-mark':U
    ,input  {&TDEDT_Pri_Vnesh}
    ,input  false
    ,input  ?
    ,output loc-ref-list
    ).
  do v-ind = 1 to num-entries(loc-ref-list)
  :
    assign
      v-doc-rec = integer(entry(v-ind, loc-ref-list))
    .
    find trn-doc no-lock
      where recid (trn-doc) = v-doc-rec
      no-error .

    if available trn-doc
    then do:

      define variable v-field-format as character no-undo .
      define variable v-cst-code     as character no-undo .

      run gbl/fldfrmt.p
        (input  'trn-doc':u
        ,input  'cst-code':u
        ,output v-field-format
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове программы fldfrmt.p" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        assign
          v-field-format = "X(22)"
        .
      end.

      assign
        v-cst-code = ub.trn-doc.cst-code
      .

      run gbl/d-prompt.w (
          'title=Задайте код ГТД\'
        + 'text1=Проставить код ГТД во все партии документа?\'
        + 'text2=Документ ' + str-encode(ub.trn-doc.doc-code, "", "=\") + '\'
        + 'format=' + v-field-format + '\'
        + 'type=char\'
        ,input-output v-cst-code
        ).
      if return-value = 'false':u then do:
        return .
      end.

      define buffer buf_trn-doc for ub.trn-doc .

      do transaction
      on error undo, return error
      :
        find first buf_trn-doc exclusive-lock
          where recid(buf_trn-doc) = recid(ub.trn-doc)
          no-error .
        assign
          buf_trn-doc.cst-code = v-cst-code
        .
      end.

      run trg/trncst.p
        (input buf_trn-doc.doc-code
        ).
    end.
  end.
end.