block-level on error undo, throw.
/*

$Revision: 9263cff4388a, 1753, rls $
$Author: SMMolotkov $
$Date: Thu Feb 07 16:50:10 2019 +0300 $
$Workfile: inc-wthr.p $
$Archive: str/inc-wthr.p $

Процедура автоматического формирования документов по чекам МЦ


Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/21/05
Author: Bakhtadze Natalya
Creation date: 09/21/05

*/

define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision: 9263cff4388a, 1753, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Feb 07 16:50:10 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: inc-wthr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/inc-wthr.p $":U .
define variable vss-description as character no-undo init "Процедура автоматического формирования документов по чекам МЦ".
{ cmp/vssrevis.i }


define variable parhost-code like ub.sysconf.host-code no-undo .
define variable parobj-type like ub.clients.obj-type no-undo .
define variable parobj-code like ub.clients.obj-code no-undo .
define variable p-auto         as integer no-undo . /*этот параметр указывает на закрытие пачками - например из расписания*/


{ cmp/trg-def.i }

{ str/incwthtt.i "SHARED" "temp-cash-doc" }
{ gbl/gbclcode.i }
{ gbl/cur-time.i } /* 21/I-2019 - cur-time.i убрано из gbclcode.i */


DEFINE VARIABLE v-err-count as integer no-undo .
DEFINE VARIABLE v-all-count as integer no-undo .
define variable v-ok-count as integer no-undo .
DEFINE VARIABLE vardb-num like ub.db.db-num no-undo.
define variable v-view-log as logical no-undo .
define variable v-esm as character no-undo .
define variable v-input-error as logical no-undo .
define variable log-file-name as character no-undo init "inc-wth.log".
define variable v-closed as integer no-undo .

define buffer buf_obj for ub.clients.
define buffer buf_wth-doc for ub.wth-doc.
define buffer auto-wth-doc-lock_batchprocess for ub.batchprocess .
define buffer buf_temp-cre-doc for temp-cre-doc .
define buffer buf_chk-doc for ub.chk-doc.

define temp-table tt-par-dtl  no-undo like ub.wth-par
{ str/ttpardt0.i }
.

define temp-table tt-par-dtl-inv  no-undo like ub.wth-par
{ str/ttpardt0.i inv }
.

&glob display-message  run write-log-and-file in p-log-handle ( ~
          input 1 ~
        , input log-file-name ~
        , input 1 ~
        , input ~{&my-message~} ~
                                      )

&glob display-message-laud  run write-log-and-file in p-log-handle ( ~
          input 1 ~
        , input log-file-name ~
        , input 1 ~
        , input ~{&my-message~} ~
                                      )

&glob display-count-message  run write-counter in p-log-handle (input ~{&my-count-message~})

&glob hide-count-message  run hide-counter in p-log-handle

&glob view-log   if p-auto = 0 then do: ~
                   ~{ str/cdviewlg.i   ~
                    "substitute('!!!В процессе Обработки документов МЦ произошли ошибки!!!')"  ~
                    "'inc-wth.log'" ~}   ~
                    return "error":U. ~
                 end

if num-entries(p-parameter, {&delim-par}) <> 4
then do:
  assign
  v-input-error = yes
  v-esm         = substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 4"
                             , num-entries(p-parameter, {&delim-par})).
  .
end.
else do:
  assign
  parhost-code         = integer(entry(1, p-parameter, {&delim-par}))
  parobj-type          = entry(2, p-parameter, {&delim-par})
  parobj-code          = integer(entry(3, p-parameter, {&delim-par}))
  p-auto               = integer(entry(4, p-parameter, {&delim-par}))
  no-error .
  if error-status:error then do:
    assign
    v-esm = error-status:get-message(1)
    v-input-error = yes
    .
  end.
end.
if v-input-error = yes then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , {&new-line}
                         , v-esm
                         , return-value
                         )).
  assign
  v-view-log = yes.
  {&view-log}.
end.
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-clsfact AS LOGICAL no-undo .
define variable v-tth as handle no-undo .


run adm/shattri.p (
    input "get":U
    ,input  parobj-type
    ,input  parobj-code
    ,input  {&attr-wthdoc}
    ,input  {&attr-wthdoc_clsfact} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-clsfact
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .

delete object v-tth no-error.




FIND FIRST buf_obj No-LOCK WHERE
                buf_obj.obj-type = parobj-type and
                buf_obj.obj-code = parobj-code No-ERROR.
if not avail buf_obj or parobj-type <> {&shop} then do:
    message vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова parobj-type и/или parobj-code" parobj-type parobj-code
    view-as alert-box ERROR.
    return.
end.
vardb-num = buf_obj.db-num.

for each temp-cash-doc:
  delete temp-cash-doc.
end.

/*блокировка ресурса - автоматические док-ты МЦ*/

 { str/lockawth.i }
_chk-doc:
for each  buf_temp-cre-doc NO-LOCK,
    each buf_chk-doc EXCLUSIVE-LOCK where
         buf_chk-doc.obj-type = parobj-type and
         buf_chk-doc.obj-code = parobj-code and
         buf_chk-doc.out-code = ? and
         buf_chk-doc.chk-type = buf_temp-cre-doc.chk-type
         :
  v-all-count = v-all-count + 1.
  if not buf_chk-doc.correct then NEXT _chk-doc.
  if buf_temp-cre-doc.shift-date = ? then do:
    if buf_chk-doc.shift-date <> buf_temp-cre-doc.doc-date then NEXT _chk-doc.
  end.
  else do:
    if NOT (buf_chk-doc.shift-date = buf_temp-cre-doc.shift-date AND
            buf_chk-doc.shift-num = buf_temp-cre-doc.shift-num) then NEXT _chk-doc.
  end.
  if buf_chk-doc.chk-type = integer({&cd-drawer}) then do:
    FIND FIRST temp-cash-doc where
              temp-cash-doc.chk-type = buf_chk-doc.chk-type
          AND temp-cash-doc.pay-desk = buf_chk-doc.pay-desk
          AND temp-cash-doc.cashier = buf_chk-doc.cashier
          and temp-cash-doc.chk-doc-code = buf_chk-doc.doc-code No-ERROR.
  end.
  else do:
    FIND FIRST temp-cash-doc where
              temp-cash-doc.chk-type = buf_chk-doc.chk-type
          AND temp-cash-doc.pay-desk = buf_chk-doc.pay-desk
          AND temp-cash-doc.cashier = buf_chk-doc.cashier  No-ERROR.
  end.
  if not available temp-cash-doc then do:
    run create-new-wth-doc in this-procedure (
                                               input vardb-num
                                              ,input parobj-type
                                              ,input parobj-code
                                              ,input buf_chk-doc.chk-type
                                              ,input buf_chk-doc.pay-desk
                                              ,input buf_chk-doc.cashier
                                              ,input buf_chk-doc.chk-date
                                              ,buffer temp-cash-doc
                                              )no-error .
    if error-status:error then do:
      NEXT _chk-doc.
    end.
  end. /*if not available temp-cash-doc then do:*/
  run str/inc-wth1.p (
                    buffer buf_chk-doc
                  ,input 1 /*добавить чек*/
                  ,input temp-cash-doc.doc-code
                  ,INPUT temp-cash-doc.w-p-code
                  ,input temp-cash-doc.out-w-p-code
                  ,input temp-cash-doc.ext-doc-type
                  ,input temp-cash-doc.chk-type
                  ,input yes /*p-silent*/
                  ) no-error .
  if error-status:error then do:
  &scop my-message substitute("Ошибка при включении чека &1 в документ МЦ &2&3&4&3&5" ~
                              , buf_chk-doc.doc-code ~
                              , temp-cash-doc.doc-code ~
                              , ~{&new-line~} ~
                              , error-status:get-message(1) ~
                              , return-value )
    {&display-message}.
    v-err-count = v-err-count + 1.
    NEXT _chk-doc.
  end.
  else do:
    v-ok-count = v-ok-count + 1.
  end.
  &scop my-message substitute("Формирование автоматических документов МЦ: просмотрено чеков &1&2обработано &3&2"  +  ~
                              "из них успешно &4" ~
                             ,v-all-count  ~
                             ,~{&new-line~}  ~
                             ,v-ok-count + v-err-count ~
                             ,v-ok-count)

  {&display-message}.
END. /*for buf_chk-doc*/
_temp-cash-doc:
for each temp-cash-doc No-LOCK:
  FIND FIRST buf_wth-doc Exclusive-lock WHERE
             buf_wth-doc.doc-code = temp-cash-doc.doc-code No-ERROR.
  if avail buf_wth-doc
  and not can-find(first ub.wth-line where ub.wth-line.doc-code = buf_wth-doc.doc-code) then do:
     delete buf_wth-doc.
     next _temp-cash-doc.
  end.
  if v-clsfact then do:
    do while
    buf_wth-doc.status_ <> {&fact} :
      run str/wth-stts.p (
                   input parparentproc
                  ,BUFFER buf_wth-doc
                  ,INPUT "+":U
                  ,INPUT no /*partalk*/
                  ,INPUT buf_wth-doc.obj-type
                  ,INPUT buf_wth-doc.oBJ-code
                  ,input log-file-name ) NO-ERROR.
      if error-status:error THEN DO:
        v-view-log = yes.
        next _temp-cash-doc.
      END.
      find first buf_wth-doc exclusive-lock where
               buf_wth-doc.doc-code = temp-cash-doc.doc-code .
      if buf_wth-doc.status_ = {&fact} then do:
        v-closed = v-closed + 1.
        next _temp-cash-doc.
      end.
    end.
  end.
end.

&scop my-message  ~
substitute("Просмотрено чеков МЦ:&1&2" +   ~
          "В автодокументы МЦ удалось включить чеков: &3&2"  + ~
          (if v-clsfact then substitute("до статуса &1 удалось закрыть док-тов: &2", ~{&fact~}, v-closed) else '') ~
        , v-all-count                               ~
        , ~{&new-line~}                             ~
        , v-ok-count)                ~

{&display-message-laud}.

/*находит или создает новые документ МЦ для заданного типа чека кассы и кассира и даты*/
/*одновременно создает запись в таблице temp-cash-doc - для удобства*/

procedure create-new-wth-doc :
define input parameter pardb-num like ub.db.db-num no-undo .
define input parameter parobj-type like ub.clients.obj-type no-undo .
define input parameter parobj-code like ub.clients.obj-code no-undo .
define input parameter parchk-type like ub.chk-doc.chk-type no-undo .
define input parameter parpay-desk like ub.chk-doc.pay-desk no-undo .
define input parameter par-cashier like ub.chk-doc.cashier no-undo .
define input parameter p-chk-date  like ub.chk-doc.chk-date no-undo .
define parameter buffer loc-temp-cash-doc for temp-cash-doc.

DEFINE VARIABLE vardoc-rec as recid no-undo.
DEFINE VARIABLE vardoc-code like ub.wth-doc.doc-code no-undo .
define variable v-cashier-psn-code as integer no-undo .
define buffer buf_wth-doc for ub.wth-doc.
define buffer buf_wth-line for ub.wth-line.
define buffer cashier for ub.person.
define buffer cash_wth-place for ub.wth-place.
DEFINE VARIABLE dops as character no-undo .
&scop  wth-receipt-code  string(parchk-type)

  do
  on error undo, return error
  :
    assign dops = {&wth-receipt-name} no-error.
    &scop my-message  substitute("Создание автоматического документа МЦ - &1" + ~
                                 "Касса: &2&1" +  ~
                                 "Кассир: &3&1" + ~
                                 "Тип чека МЦ: &4" ~
                                  , ~{&new-line~} ~
                                  , parpay-desk ~
                                  , par-cashier ~
                                  , dops)
    {&display-message}.
    v-cashier-psn-code = 0.
    assign
    v-cashier-psn-code = gbclcode-is-this-db-role ( input {&role-cashier}, input vardb-num, input par-cashier, input p-chk-date)
    no-error
    .
    if v-cashier-psn-code = 0 then do:
      &scop my-message substitute("!!!ОШИБКА: В справочнике нет кассира &1",  par-cashier)
      v-view-log = yes.
      {&display-message}.
      return error.
    end.

    find first CASH_WTh-PLACE no-lock where
               CASH_wth-place.obj-type = parobj-type AND
               CASH_wth-place.obj-code = parobj-code AND
               cash_wth-place.cash-desk = parpay-desk No-ERROR.

    if not available cash_wth-place then do:
      &scop my-message substitute("!!!ОШИБКА: Не определено МХ для кассы &1",  parpay-desk)
      v-view-log = yes.
      {&display-message}.
      return error.
    end.
    /*найдем шаблон*/
    FIND FIRST temp-cre-doc No-LOCK WHERE
               temp-cre-doc.chk-type = parchk-type No-ERROR.
    if not available temp-cre-doc then return error.
    /*найдем документ МЦ*/
    vardoc-rec = ?.
    _buf_wth-doc:
    FOR EACH buf_wth-doc No-LOCK WHERE
              buf_wth-doc.obj-type = parobj-type AND
              buf_wth-doc.obj-code = parobj-code AND
              buf_wth-doc.auto-fill = yes AND
              buf_wth-doc.status_ = {&wayb} AND
              buf_wth-doc.exter_ = temp-cre-doc.exter_ AND
              buf_wth-doc.inter_ = temp-cre-doc.inter_ AND
              buf_wth-doc.doc-type = temp-cre-doc.doc-type AND
              buf_wth-doc.cli-type = temp-cre-doc.cli-type AND
              buf_wth-doc.cli-code = temp-cre-doc.cli-code AND
              buf_wth-doc.doc-date = temp-cre-doc.doc-date AND
              buf_wth-doc.shift-date = temp-cre-doc.shift-date AND
              buf_wth-doc.shift-num = temp-cre-doc.shift-num:
      FIND FIRST buf_wth-line No-LOCK WHERE
                 buf_wth-line.doc-code = buf_wth-doc.doc-code No-ERROR.
      if temp-cre-doc.chk-type = integer({&cd-drawer}) then do:
        if not avail buf_wth-line then do:
          vardoc-rec = recid(buf_wth-doc).
          LEAVE _buf_wth-doc.
        end.
      end.
      else do:
        if not avail buf_wth-line or
          ((buf_wth-line.out-code = temp-cre-doc.out-w-p-code
            OR
            buf_wth-doc.doc-type = {&inventory})
            AND
          buf_wth-line.w-p-code = cash_wth-place.w-p-code)
          then do:
          vardoc-rec = recid(buf_wth-doc).
          LEAVE _buf_wth-doc.
        end.
      end.
    END. /*for each buf_wth-doc*/
    if vardoc-rec <> ? then do:
      create loc-temp-cash-doc.
      assign
      loc-temp-cash-doc.chk-type = parchk-type
      loc-temp-cash-doc.inter_ =  temp-cre-doc.inter_
      loc-temp-cash-doc.exter_  =  temp-cre-doc.exter_
      loc-temp-cash-doc.doc-type  =  temp-cre-doc.doc-type
      loc-temp-cash-doc.cli-type  =  temp-cre-doc.cli-type
      loc-temp-cash-doc.cli-code  =  temp-cre-doc.cli-code
      loc-temp-cash-doc.out-w-p-code = temp-cre-doc.out-w-p-code
      loc-temp-cash-doc.w-p-code = cash_wth-place.w-p-code
      loc-temp-cash-doc.pay-desk = parpay-desk
      loc-temp-cash-doc.cashier = par-cashier
      loc-temp-cash-doc.doc-code =  buf_wth-doc.doc-code
      loc-temp-cash-doc.shift-date = buf_wth-doc.shift-date
      loc-temp-cash-doc.shift-num = buf_wth-doc.shift-num
      loc-temp-cash-doc.shift-name = buf_wth-doc.shift-name
      loc-temp-cash-doc.doc-date = buf_wth-doc.doc-date
      loc-temp-cash-doc.fact-date = buf_wth-doc.fact-date
      .
      return.
    end.
    else do:
      /*такого как нам нужно документа нет - родим его */
     _cre-block:
      DO ON ERROR undo _cre-block, return error   :
        vardoc-code = '':U.
        CASE temp-cre-doc.doc-type:
          when {&inventory} then do:
            run str/wth-inv1.p (
                              input yes
                            ,input-output vardoc-rec
                            ,input {&add-def}
                            ,input vardoc-code
                            ,input parhost-code
                            ,input parobj-type
                            ,input parobj-code
                            ,input temp-cre-doc.doc-date
                            ,input temp-cre-doc.fact-date
                            ,input temp-cre-doc.shift-date
                            ,input temp-cre-doc.shift-num
                            ,input temp-cre-doc.shift-name
                            ,input v-cashier-psn-code
                            ,input v-cashier-psn-code
                            ,input v-cashier-psn-code
                            ,input v-cashier-psn-code
                            ,input v-cashier-psn-code
                            ,input yes  /*auto-fill*/
                            ,input 0
                            ,input 0
                            ,input '':U /*PS*/
                            ,input {&wayb}
                            ,input no /*parlines-exist*/
                              ) no-error .
          end.
          otherwise do:
            run str/wth-inc1.p (
                              input yes
                            ,input-output vardoc-rec
                            ,input {&add-def}
                            ,input vardoc-code
                            ,input parhost-code
                            ,input parobj-type
                            ,input parobj-code
                            ,input temp-cre-doc.cli-type
                            ,input temp-cre-doc.cli-code
                            ,input temp-cre-doc.doc-date
                            ,input temp-cre-doc.fact-date
                            ,input temp-cre-doc.shift-date
                            ,input temp-cre-doc.shift-num
                            ,input temp-cre-doc.shift-name
                            ,input v-cashier-psn-code
                            ,input v-cashier-psn-code
                            ,input v-cashier-psn-code
                            ,input temp-cre-doc.doc-type
                            ,input yes  /*auto-fill*/
                            ,input temp-cre-doc.exter_
                            ,input temp-cre-doc.inter_
                            ,input '' /*source-ref*/
                            ,input '':U /*source-type*/
                            ,input no
                            ,input 0
                            ,input 0
                            ,input '':U /**/
                            ,input {&wayb}
                            ,input no /*parlines-exist*/
                            ,input temp-cre-doc.ext-doc-type
                              ) no-error .
          end.
        end CASE.
        if error-status:error then do:
&scop my-message  substitute("!!!Ошибка при создании док-та МЦ:&1&2&1&3" ~
                                                    , {&new-line}     ~
                                                    , error-status:get-message(1) ~
                                                    , return-value )
          {&display-message}.
          undo _cre-block, return error ''.
        end.
        FIND FIRST buf_wth-doc No-LOCK WHERE
                    recid(buf_wth-doc) = vardoc-rec No-ERROR.
        if error-status:error then do:
          undo _cre-block, return error return-value.
        end.
        create loc-temp-cash-doc.
        assign
        loc-temp-cash-doc.chk-type = parchk-type
        loc-temp-cash-doc.inter_ =  temp-cre-doc.inter_
        loc-temp-cash-doc.exter_  =  temp-cre-doc.exter_
        loc-temp-cash-doc.doc-type  =  temp-cre-doc.doc-type
        loc-temp-cash-doc.cli-type  =  temp-cre-doc.cli-type
        loc-temp-cash-doc.cli-code  =  temp-cre-doc.cli-code
        loc-temp-cash-doc.out-w-p-code  =  temp-cre-doc.out-w-p-code
        loc-temp-cash-doc.w-p-code  =  cash_wth-place.w-p-code
        loc-temp-cash-doc.pay-desk  =  parpay-desk
        loc-temp-cash-doc.cashier = par-cashier
        loc-temp-cash-doc.doc-code =  buf_wth-doc.doc-code
        loc-temp-cash-doc.shift-date = buf_wth-doc.shift-date
        loc-temp-cash-doc.shift-num = buf_wth-doc.shift-num
        loc-temp-cash-doc.shift-name = buf_wth-doc.shift-name
        loc-temp-cash-doc.doc-date = buf_wth-doc.doc-date
        loc-temp-cash-doc.fact-date = buf_wth-doc.fact-date
        loc-temp-cash-doc.ext-doc-type = buf_wth-doc.ext-doc-type
        .
        if buf_chk-doc.chk-type = integer({&cd-drawer}) then do:
          loc-temp-cash-doc.chk-doc-code = buf_chk-doc.doc-code.
        end.
        return.
      END. /* _cre-block*/
    end.
  end.

end procedure. /* create-new-wth-doc */