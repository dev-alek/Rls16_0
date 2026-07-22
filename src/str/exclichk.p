block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: exclichk.p $
$Archive: str/exclichk.p $

Исключение чека из незакрытой продажи

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/02/05
Author: Bakhtadze Natalya
Creation date: 10/02/05

*/

define input parameter parparentproc as widget-handle no-undo .
define parameter buffer X_chk-doc for ub.chk-doc.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exclichk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/exclichk.p $":U .
define variable vss-description as character no-undo init "Исключение чека из незакрытой продажи".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/waitfram.i }

&glob display-message  run waitfram-show in this-procedure (~{&MY-MESSAGE~} )

&glob display-message-laud  MESSAGE ~{&MY-MESSAGE~}

&glob display-count-message run waitfram-show in this-procedure (input ~{&MY-count-MESSAGE~} )

&glob hide-count-message  run waitfram-hide in this-procedure

/*кол-во чеков в документе*/
define variable chk-amount as integer.

define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-discnt for ub.chk-discnt.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_chk-doc-attr for ub.chk-doc-attr.
define buffer buf_c-chk-doc for ub.c-chk-doc.
define buffer buf_c-chk-gds for ub.c-chk-gds.
define buffer buf_c-chk-pay for ub.c-chk-pay.
define buffer buf_c-chk-discnt for ub.c-chk-discnt.
define buffer buf_c-chk-doc-attr for ub.c-chk-doc-attr.
define buffer buf_trn-doc for ub.trn-doc.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

  FIND FIRST buf_trn-doc WHERE buf_trn-doc.doc-code = X_chk-doc.out-code NO-LOCK NO-ERROR.
  if not avail buf_trn-doc then do:
      message
      substitute("Ошибка! Чек &1 привязан к отсутствующему документу инвентаризации!", X_chk-doc.doc-code)
      view-as alert-box ERROR.
      return error.
  end.

  FIND FIRST buf_trn-doc exclusive-lock WHERE
           buf_trn-doc.doc-code = X_chk-doc.out-code no-wait NO-ERROR.
  if not avail buf_trn-doc then do:
      message
      substitute("Не найдена или не занята накладная &1!", X_chk-doc.out-code)  view-as alert-box ERROR.
      return error.
  end.
  if not (buf_trn-doc.status_ = {&wayb}
         and
         buf_trn-doc.flag_ = no) then do:
    message
    substitute("Исключение чека из документа инвентаризации возможно только если документ находится в статусе &1&2!"
              , {&wayb}
              , string(yes,"+/")
              )  view-as alert-box ERROR.
    return error.
  end.
  run waitfram-show in this-procedure ( substitute("Освобождаю чек &1...", X_chk-doc.doc-code)).
  FOR EACH buf_chk-gds where buf_chk-gds.doc-code = X_chk-doc.doc-code
  on error undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
      assign
      buf_chk-gds.out-code = ?
      buf_chk-gds.line-type = entry(1, buf_chk-gds.line-type, {&delim-par})
      buf_chk-gds.is-error = no
     .
  END.
  FOR EACH buf_chk-discnt where buf_chk-discnt.doc-code = X_chk-doc.doc-code
  on error undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
      buf_chk-discnt.out-code = ?.
  END.
  FOR EACH buf_chk-doc-attr where buf_chk-doc-attr.doc-code = X_chk-doc.doc-code
  on error undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
      buf_chk-doc-attr.out-code = ?.
  END.
  /*история*/
  for each buf_c-chk-doc where
          buf_c-chk-doc.doc-code = X_chk-doc.doc-code
  on error undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
          :
    assign
    buf_c-chk-doc.out-code = ?
    .
  end.
  for each buf_c-chk-gds where
          buf_c-chk-gds.doc-code = X_chk-doc.doc-code
  on error undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
          :
    assign
    buf_c-chk-gds.out-code = ?
    .
  end.
  for each buf_c-chk-discnt where
          buf_c-chk-discnt.doc-code = X_chk-doc.doc-code
  on error undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
          :
    assign
    buf_c-chk-discnt.out-code = ?
    .
  end.
  for each buf_c-chk-pay where
          buf_c-chk-pay.doc-code = X_chk-doc.doc-code
  on error undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
          :
    assign
    buf_c-chk-pay.out-code = ?
    .
  end.
  for each buf_c-chk-doc-attr where
          buf_c-chk-doc-attr.doc-code = X_chk-doc.doc-code
  on error undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
          :
    assign
    buf_c-chk-doc-attr.out-code = ?
    .
  end.
  X_chk-doc.out-code = ? .
  run waitfram-hide in this-procedure .
end.