block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: trncstcp.p $
$Archive: utl/trncstcp.p $

Копирование кода ГТД в партии приходной накладной из любой другой накладной

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
define variable vss-workfile    as character no-undo init "$Workfile: trncstcp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/trncstcp.p $":U .
define variable vss-description as character no-undo init "Выбор документов и простановка кода ГТД ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/strcodec.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define buffer buf_trn-doc for ub.trn-doc .

define variable v-update-ind as integer no-undo .
define variable v-skip-ind   as integer no-undo .

define variable lok as logical no-undo .
define variable loc-ref-list as character no-undo .
define variable v-doc-rec    as integer   no-undo .

do
on error undo, return error
:
  assign
    lok = false
  .
  message
    "Программа обновления ГТД в приходном документе на основании расходного документа" skip
    "Сначала необходимо выбрать приходный документ." skip
    "Затем расходный." skip
    "ВНИМАНИЕ! Информация о ГТД в других базах данных не будет изменена." skip
    "Продолжить?"
    view-as alert-box question buttons yes-no update lok .
  if lok <> true then do:
    return .
  end.

  run str/all-docs.w
    (input parparentproc
    ,input v-cntxt-host-code-obj
    ,input v-cntxt-obj-type
    ,input v-cntxt-obj-code
    ,input {&type}
    ,input {&fact}
    ,input {&income}
    ,input ?
    ,input false
    ,input "b-sel":U
    ,input {&TDEDT_Pri_Vnesh}
    ,input no
    ,input ?
    ,output loc-ref-list
    ).
  assign
    v-doc-rec = integer(entry(1, loc-ref-list))
  .
  find trn-doc no-lock
    where recid (trn-doc) = v-doc-rec
    no-error .

  if not available trn-doc then do:
    return . /* --->>>--- */
  end.

  run str/all-docs.w
    (input parparentproc
    ,input ?
    ,input ?
    ,input ?
    ,input {&work}
    ,input ?
    ,input ?
    ,input ?
    ,input ?
    ,input "b-sel":U
    ,input ?
    ,input no
    ,input ?
    ,output loc-ref-list
    ).
  assign
    v-doc-rec = integer(entry(1, loc-ref-list))
  .
  find buf_trn-doc no-lock
    where recid (buf_trn-doc) = v-doc-rec
    no-error .

  if not available buf_trn-doc then do:
    return . /* --->>>--- */
  end.

  assign
    lok = false
  .
  message
    "Вы выбрали следующие документы" skip
    "Приходный" ub.trn-doc.doc-code skip
    "Расходный" buf_trn-doc.doc-code skip
    "Будем скопирована информация о ГТД" skip
    ub.trn-doc.doc-code "<---" buf_trn-doc.doc-code skip
    "Продолжить?"
    view-as alert-box question buttons yes-no update lok .
  if lok <> true then do:
    return .
  end.

  run copy-doc-cst in this-procedure
    (input ub.trn-doc.doc-code
    ,input buf_trn-doc.doc-code
    ).

  message
    "Информация о ГТД скопирована" skip
    "Приходный документ" ub.trn-doc.doc-code skip
    "Обновлено партий" v-update-ind skip
    "Не обновлено партий" v-skip-ind skip
    view-as alert-box information .
end.


procedure copy-doc-cst :

  do
  on error undo, return error
  :
    define input parameter p-input-doc-code   like ub.trn-doc.doc-code no-undo .
    define input parameter p-expense-doc-code like ub.trn-doc.doc-code no-undo .

    define buffer buf_trn-doc     for ub.trn-doc .
    define buffer expense_trn-doc for ub.trn-doc .
    define buffer buf_parts       for ub.parts .
    define buffer expense_parts   for ub.parts .

    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-input-doc-code
      .
    find first expense_trn-doc no-lock
      where expense_trn-doc.doc-code = p-expense-doc-code
      .

    for each buf_parts exclusive-lock
      where buf_parts.out-code = p-input-doc-code
    on error undo, return error
    :
      find first expense_parts no-lock
        where expense_parts.out-code  = p-expense-doc-code
          and expense_parts.obj-type  = expense_trn-doc.obj-type
          and expense_parts.obj-code  = expense_trn-doc.obj-code
          and expense_parts.artic     = buf_parts.artic
          and expense_parts.prod-type = buf_parts.prod-type
          and expense_parts.prod-code = buf_parts.prod-code
          and expense_parts.part-code = buf_parts.part-code
          and expense_parts.cst-code  <> ""
        no-error .
      if available expense_parts then do:
        assign
          v-update-ind = v-update-ind + 1
        .
        run trg/partcst.p
          (input expense_parts.cst-code /* p-cst-code  */
          ,input buf_parts.in-code      /* p-in-code   */
          ,input buf_parts.artic        /* p-artic     */
          ,input buf_parts.prod-type    /* p-prod-type */
          ,input buf_parts.prod-code    /* p-prod-code */
          ,input buf_parts.part-code    /* p-part-code */
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры partcst.p" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
      else do:
        assign
          v-skip-ind = v-skip-ind + 1
        .
      end.
    end.
  end.

end procedure. /* copy-doc-cst */