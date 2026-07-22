block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chck-rv.p $
$Archive: str/chck-rv.p $

Процедура 1. резервирования / снятия резервов по всем документам, мешающим инвентаризации
          2. снятия резервов по всем документам, имеющим просроченную дату резервировани
          3. удаления запросов по сроку

Автор: Чернова Светлана Александровна
Дата создания: 12/27/06
Author: Svetlana Chernova
Creation date: 12/27/06

Create: Суслов Алексей Юрьевич


*/

define input parameter parparentproc as handle    no-undo.
define input parameter rv-mode       as character no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chck-rv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chck-rv.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/waitfram.i }
{ gbl/getcntxt.i get }

define variable cut-date        as date               no-undo.
define variable inv-code        like trn-doc.doc-code no-undo.       /* номер выбранной инвентаризации */
define variable loc-ref-list    as character          no-undo.
define variable v-today         as date               no-undo.
define variable v-log           as logical            no-undo.
define variable v-doc-rec       as recid              no-undo.

define frame d
cut-date label "Удалить запросы до даты"
with three-d side-labels.

if rv-mode = "инв-снять" or
   rv-mode = "инв-рез" then do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_inventory_reserves':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    v-log
  }

  if not v-log then
    return error.
  v-log = yes.
  message "Выберите инвентаризацию для резервирования / снятия резервов."
          "Продолжать ?"
          view-as alert-box question buttons OK-Cancel update v-log.
  if not v-log then return.
  run str/all-docs.w (
  input parparentproc,
  input v-cntxt-host-code-obj,
  input v-cntxt-obj-type,
  input v-cntxt-obj-code,
  input {&type},
  input "",
  input {&inventory},
  input ?,
  input no,
  "b-sel":U,
  input {&TDEDT_Inv},
  input no,
  input ?,
  output loc-ref-list).
  assign
    v-doc-rec = integer(ENTRY (1, loc-ref-list)).
  find trn-doc where recid (trn-doc) = v-doc-rec no-lock no-error.
  if not available trn-doc then do:
    message "Документ не выбран."
            view-as alert-box error.
    return error.
  end.
  if ( v-cntxt-db-num-obj <> v-cntxt-db-num ) and ( v-cntxt-db-num-obj <> 0 )
  then do:
    message "Работа с резервами возможна только на активной стороне."
            view-as alert-box error.
    return error.
  end.
end.

case rv-mode:
  when {&period} then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_period_reserves':U
      {&cntxt-object}
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      0
      0
      0
      true
      v-log
    }
    if not v-log then
      return error.
    v-log = yes.
    message "Снятие резервов на текущую дату для" v-cntxt-obj-type v-cntxt-obj-code
            "Продолжать ?"
            view-as alert-box question buttons OK-Cancel update v-log.
    if not v-log then return.
    if ( v-cntxt-db-num-obj <> v-cntxt-db-num ) and ( v-cntxt-db-num-obj <> 0 ) then do:
      message "Работа с резервами возможна только на активной стороне."
              view-as alert-box error.
      return error.
    end.

    run waitfram-show in this-procedure
      (input "Идет ревизия резервов. Ждите..."
      ).
    /* снятие резерва по истечении времени счета */
    { gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code v-today }
    for each trn-doc where trn-doc.doc-type = {&expense}
                       and trn-doc.status_ = {&wayb}
                       and trn-doc.obj-type = v-cntxt-obj-type
                       and trn-doc.obj-code = v-cntxt-obj-code
                       and trn-doc.fact-date < v-today:
      run str/unrv-out.p (parparentproc, trn-doc.doc-code) no-error.
      if error-status:error then next.
      accumulate trn-doc.doc-code (count).
      run waitfram-show in this-procedure
        (input "СЧЕТ № " + trn-doc.doc-code + " -> ЗАПРОС.  Всего : " +
                      string ((accum count trn-doc.doc-code))
        ).
    end.
    run waitfram-hide in this-procedure .
    message "Ревизия резервов закончена. Отменено счетов :" (accum count trn-doc.doc-code).
  end.
  when {&inquiry} then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_period_inquires':U
      {&cntxt-object}
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      0
      0
      0
      true
      v-log
    }
    if not v-log then
      return error.
    v-log = yes.
    message "Удаление расходных запросов для" v-cntxt-obj-type v-cntxt-obj-code skip
            "Продолжать ?"
            view-as alert-box question buttons OK-Cancel update v-log.
    if not v-log then return.
    { gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code v-today }
    cut-date = v-today.
    update cut-date with frame d.
    assign cut-date.
    hide frame d.
    run waitfram-show in this-procedure
      (input "Удаление запросов по сроку. Ждите..."
      ).
    for each trn-doc where trn-doc.doc-type = {&expense}
                       and trn-doc.status_ = {&inquiry}
                       and trn-doc.obj-type = v-cntxt-obj-type
                       and trn-doc.obj-code = v-cntxt-obj-code
                       and trn-doc.fact-date < cut-date:
      accumulate trn-doc.doc-code (count).
      run waitfram-show in this-procedure
        (input "ЗАПРОС № " + trn-doc.doc-code + " Удален.  Всего : " +
                      string ((accum count trn-doc.doc-code))).
      delete trn-doc.
    end.
    run waitfram-hide in this-procedure .
    message "Удалено запросов :" (accum count trn-doc.doc-code).
  end.
  when "инв-снять" then do:
    if not (trn-doc.status_ = {&wayb} and
       trn-doc.flag_ or
       trn-doc.status_ = {&permitted} and
       not trn-doc.flag_) then do:
      message "Документ инвентаризации имеет не тот статус."
              view-as alert-box error.
      return error.
    end.
    v-log = no.
    message "Сформировать заново список документов, мешающих включению инвентаризации ?"
            view-as alert-box question buttons Yes-No update v-log.
    if v-log then
      run str/inv-lst.p (
                      input parparentproc
                    , input v-cntxt-host-code-obj
                    , input v-cntxt-obj-type
                    , input v-cntxt-obj-code
                    , input trn-doc.doc-code).
    run waitfram-show in this-procedure
      (input "Снятие резервов по инвентаризации. Ждите..."
      ).
    inv-code = trn-doc.doc-code.
    for each trn-doc where trn-doc.inv-num = inv-code:
      run str/unrv-out.p (parparentproc, trn-doc.doc-code) no-error.
      if error-status:error then next.
      trn-doc.flag_ = yes.                  /* чтоб отличались от прочих запросов */
      accumulate trn-doc.doc-code (count).
      run waitfram-show in this-procedure
        (input "СЧЕТ № " + trn-doc.doc-code + " -> ЗАПРОС.  Всего : " +
                      string ((accum count trn-doc.doc-code))
        ).
    end.
    run waitfram-hide in this-procedure .
    message "Снятие резервов по инвентаризации закончено." skip (2)
            "Отменено счетов :" (accum count trn-doc.doc-code).
  end.
  when "инв-рез" then do:
    if trn-doc.status_ = {&permitted} and
       trn-doc.flag_ then do:
      message "Документ инвентаризации включен. Резервирование невозможно."
              view-as alert-box error.
      return error.
    end.
    run waitfram-show in this-procedure
      (input "Резервирование по инвентаризации. Ждите..."
      ).
    inv-code = trn-doc.doc-code.
    for each trn-doc where trn-doc.inv-num = inv-code:
      run str/rv-out.p (
          parparentproc,
          this-procedure ,
          trn-doc.doc-code,
          no ,
          true
          ) no-error.
      if error-status:error then next.
      accumulate trn-doc.doc-code (count).
      run waitfram-show in this-procedure
        (input "ЗАПРОС № " + trn-doc.doc-code + " -> СЧЕТ.  Всего : " +
                      string ((accum count trn-doc.doc-code))).
    end.
    run waitfram-hide in this-procedure .
    message "Создано счетов на основании запросов :" (accum count trn-doc.doc-code)
            view-as alert-box.
  end.
end.