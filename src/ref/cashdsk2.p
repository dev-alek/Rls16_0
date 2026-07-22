block-level on error undo, throw.
/*

$Revision: 79dbeab10a26, 2672, rls $
$Author: Ostroukhov $
$Date: Вт ноя 17 10:53:20 2020 +0300 $
$Workfile: cashdsk2.p $
$Archive: ref/cashdsk2.p $

Изменение статуса вкл/выкл кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/16/04
Author: Bakhtadze Natalya
Creation date: 03/16/04

*/

/*
Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter par-recid as recid no-undo.
define input-output parameter par-cash-on like ub.cash-desk.cash-on no-undo .


define variable vss-revision    as character no-undo init "$Revision: 79dbeab10a26, 2672, rls $":U .
define variable vss-author      as character no-undo init "$Author: Ostroukhov $":U .
define variable vss-date        as character no-undo init "$Date: Вт ноя 17 10:53:20 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cashdsk2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cashdsk2.p $":U .
define variable vss-description as character no-undo init "Изменение статуса вкл/выкл кассы".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/cur-time.i }
{ str/defc-obj.i " NEW SHARED " }
{ gbl/getcntxt.i def }

DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE choice as logical no-undo .
DEFINE VARIABLE varold-cash-on like ub.cash-desk.cash-on no-undo .
/*использовать смены на объекте*/
define variable l-shift-on as logical no-undo.
define variable v-shift-date as date no-undo.
define variable v-shift-num as integer no-undo.
define variable v-shift-name as character no-undo.
define variable v-result as integer no-undo .


DEFINE BUFFER bf_cash-desk for ub.cash-desk.
DEFINE BUFFER buf_cash-desk for ub.cash-desk.
define buffer bfcdm_cash-desk for ub.cash-desk.
define buffer buf_shift-cash for ub.shift-cash.

_main:
do
on error undo, return error
:
  { gbl/getcntxt.i get }


FIND FIRST bf_cash-desk WHERE
           recid(bf_cash-desk) = par-recid.
varold-cash-on = bf_cash-desk.cash-on.
if par-cash-on = ? then do:
  CASE bf_cash-desk.cash-on:
    when yes then do:
      assign
      par-cash-on = no.
    end.
    when no then do:
      assign
      par-cash-on = yes.
    end.
  END CASE.
end.

/*найдем параметр - использовать смены глобально на объекте или нет*/
{ gbl/objat.i
  {&shop}
  bf_cash-desk.obj-code
  "'shift-on=request'"
  l-shift-on
}
CASE par-cash-on:
 when yes then do:
/*собираемся включать        */
    run proc-b-on in this-procedure ( buffer bf_cash-desk
                                     ,output v-result
                                     ) no-error.
    if error-status:error then do:
      undo _main, return error return-value.
    end.
    if v-result = 1
    and return-value <> '':U
    then do:
       message
       return-value
       view-as alert-box .
    end.

    run proc-on-off in this-procedure (input-output par-cash-on) no-error.
    if error-status:error then do:
      undo _main, return error return-value.
    end.

 end.
 when no then do: /*собираемся выключать - надо проверить закрыта ли смена на объекте*/
    run proc-b-off in this-procedure (buffer bf_cash-desk) no-error.
    if error-status:error then do:
      undo _main, return error return-value .
    end.
    if l-shift-on then do:
        FIND FIRST buf_shift-cash WHERE
                  buf_shift-cash.obj-type = {&shop}
              AND buf_shift-cash.obj-code = bf_cash-desk.obj-code
              AND buf_shift-cash.cash-num = bf_cash-desk.cash-num
              AND buf_shift-cash.shift-date = v-shift-date
              AND buf_shift-cash.z-status = '' No-ERROR.
        if avail buf_shift-cash then do:
            if buf_shift-cash.status_ = {&sht-closed} then.
            else delete buf_shift-cash.
        end.
    end.
    run proc-on-off in this-procedure (input-output par-cash-on) no-error.
    if error-status:error then do:
      undo _main, return error return-value .
    end.
 end. /*выключение кассы*/
 END CASE.
end.

procedure proc-on-off:
define input-output parameter par-cash-on like ub.cash-desk.cash-on no-undo .

  do
  on error undo, return error
  :
    assign
    bf_cash-desk.cash-on = par-cash-on.
    if bf_cash-desk.pos-type = {&cd-type-ibm-xml}
    and bf_cash-desk.autonomy <> integer({&cd-self})
    then do:
      for each cash-obj:
        delete cash-obj.
      end.
      find first cash-obj where
              cash-obj.km-objtype = (if buf_cash-desk.autonomy = integer({&cd-manager}) then 2 else 3)
          AND cash-obj.km-objcode = bf_cash-desk.cash-num no-error .
      if not available cash-obj then do:
        create cash-obj.
        assign
        cash-obj.km-objcode = bf_cash-desk.cash-num
        cash-obj.km-objtype = (if bf_cash-desk.autonomy = integer({&cd-manager}) then 2 else 3)
        cash-obj.km-objname = (if bf_cash-desk.autonomy = integer({&cd-manager})
                               then "КМ"
                               else ("касса" + string(bf_cash-desk.cash-num))
                               )
        cash-obj.on-addr    = (if bf_cash-desk.autonomy = integer({&cd-manager})
                              then bf_cash-desk.addr-path
                              else (entry(1, bf_cash-desk.addr-path, {&delim-par})
                                    + "://":U
                                    + entry(2, bf_cash-desk.addr-path, {&delim-par})
                                  )
                              )
        cash-obj.off-addr   = (if bf_cash-desk.autonomy = integer({&cd-manager})
                              then bf_cash-desk.addr-path
                              else (entry(1, bf_cash-desk.addr-path, {&delim-par})
                                    + "://":U
                                    + entry(2, bf_cash-desk.addr-path, {&delim-par})
                                  )
                              )
        cash-obj.shop-nums  = if bf_cash-desk.autonomy = integer({&cd-slave})
                              then  string(bf_cash-desk.obj-code)
                              else "":U
        cash-obj.obj-lock   = if bf_cash-desk.cash-on then 0 else 1
        .
        if bf_cash-desk.autonomy = integer({&cd-manager}) then do:
          for each bfcdm_cash-desk no-lock where
                  bfcdm_cash-desk.db-num = bf_cash-desk.db-num
            AND  bfcdm_cash-desk.pos-type = {&cd-type-ibm-xml}
            AND  bfcdm_cash-desk.autonomy = integer({&cd-manager})
            AND  bfcdm_cash-desk.cash-on = yes
            :
            assign
            cash-obj.shop-nums = cash-obj.shop-nums
                                  + (if cash-obj.shop-nums = "":u then "":U else {&comma-char})
                                  + string(bfcdm_cash-desk.obj-code)
            .
          end.
        end.
        if can-find(first ub.cash-desk no-lock where
                         ub.cash-desk.db-num = bf_cash-desk.db-num
                     and ub.cash-desk.obj-code = bf_cash-desk.obj-code
                     and ub.cash-desk.pos-type = {&cd-type-ibm-xml}) then
        run str/diallog.w (
                      input parparentproc
                    , input this-procedure
                    , 'str/send-obj.p':U
                    , input (string(bf_cash-desk.db-num) + {&delim-par} +
                            string(bf_cash-desk.obj-code) + {&delim-par} +
                            "R":U )
                    , no
                    , ''
                    , substitute('Отправка информации по объектам БД на кассовый менеджер &1', {&cd-type-ibm-xml})).
      end.
    end. /*если IBm-XML*/
    release bf_cash-desk no-error .
    if error-status:error then do:
      message
      "Ошибка при сохранении записи КАССА" skip
      error-status:get-message(1) skip
      return-value
      view-as alert-box error .
      undo , return error .
    end.

    par-cash-on = ?.

  end.

end procedure. /* proc-on-off */



PROCEDURE proc-b-off :
DEFINE PARAMETER BUFFER t-cash-desk for ub.cash-desk.
define variable glog as logical no-undo .
define variable v-shift-date as date no-undo.
define variable v-shift-num as integer no-undo.

if l-shift-on then do:
   { gbl/curshift.i {&shop} t-cash-desk.obj-code v-shift-date v-shift-num v-shift-name no-error}
   if error-status:error and v-shift-num = 0 then return.
   /*смена выключена все нормально*/
   /*если смена включена то*/
  /*проверим права*/
  define variable v-chk-act-host-code as integer   no-undo .
  { gbl/hostcode.i
    {&shop}
    bf_cash-desk.obj-code
    v-chk-act-host-code
  }
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_shift_super':U
    {&cntxt-object}
    v-chk-act-host-code
    {&shop}
    bf_cash-desk.obj-code
    0
    0
    0
    false
    glog
  }


  if not glog then do:
      /*права недостаточны*/
      return error  ( substitute("Включена смена на магазине &1&2Выключить кассу невозможно"
                                ,t-cash-desk.obj-code
                                , {&new-line})).
  end.
  /*права достаточны*/
  /*
  не будем принимать почту поскольку здесь мы в transaction - что недопустимо при приеме почты
  /*прием почты*/

  run str/diallog.w (  parparentproc
                , this-procedure
                , 'str/get-chkf.p':U
                , ({&shop} + {&delim-par} + string(t-cash-desk.obj-code) + {&delim-par} + string(0))
                , no
                , '':U
                , 'Прием чеков с касс') no-error .
  if error-status:error then do:
      /*ошибка игнорируется*/
  end.
  else do:
    glog = no.
    message
    substitute("Касса N &1 отвечает на запросы&2" +
               "Вы уверены, что вы хотите выключить кассу?"
               ,t-cash-desk.cash-num
               ,{&new-line})
    view-as alert-box QUESTION buttons YES-NO update glog.
    if not glog then return error.
  end.
 */
end. /*l-shift-on*/

END PROCEDURE.


PROCEDURE proc-b-on :
DEFINE PARAMETER BUFFER t-cash-desk for ub.cash-desk.
define output parameter p-result as integer no-undo .
define variable vrecid as recid no-undo.
define variable predmet as char.
define variable hr as recid.
DEFINE VARIABLE hour AS INTEGER.
DEFINE VARIABLE minute AS INTEGER.
DEFINE VARIABLE sec AS INTEGER.
DEFINE VARIABLE timeleft AS INTEGER.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-shift-date as date no-undo.
define variable v-shift-num as integer no-undo.
define variable varshift-name     as character no-undo.
define variable varshift-name-num as character no-undo.

define buffer buf_c-cash-desk for ub.c-cash-desk.
/*включение кассы */
if l-shift-on then do:
  { gbl/curshift.i {&shop} t-cash-desk.obj-code v-shift-date v-shift-num v-shift-name no-error}
  if not error-status:error and v-shift-num > 0 then do:
    /*смена на объекте включена должны создать запись об открытии смены!*/
    FIND FIRST buf_shift-cash NO-LOCK WHERE
              buf_shift-cash.obj-type = {&shop}
          AND buf_shift-cash.obj-code = t-cash-desk.obj-code
          AND buf_shift-cash.cash-num = t-cash-desk.cash-num
          AND buf_shift-cash.shift-date = v-shift-date
          AND buf_shift-cash.shift-num = v-shift-num No-ERROR.
    if not avail buf_shift-cash then do:
        run cur-time in this-procedure ( output v-today, output v-time).
        run str/shftccr.p (input {&shop}
                      ,input t-cash-desk.obj-code
                      ,input t-cash-desk.cash-num
                      ,input v-shift-date
                      ,input v-shift-num
                      ,input string(v-shift-num)
                      ,input v-shift-name
                      ,input v-time
                      ,input 0
                      ,input {&cash-desk-on}
                      ,output vrecid
                      ) no-error.
        if error-status:error then return error
        ("Не удалось создать запись открытия смены на кассе " + string(t-cash-desk.cash-num)).
    end.
    else do:
      /*смена на кассе есть и она закрыта - это повторное включение касс, выключненной
      в течение смены на объекте*/
      if buf_shift-cash.status_ = {&sht-closed} then.
      else do:
         p-result = 1.
      end.
    end.
  end.
end.
FOR EACH buf_c-cash-desk no-lock where
        buf_c-cash-desk.db-num = t-cash-desk.db-num
    AND buf_c-cash-desk.obj-code = t-cash-desk.obj-code
    AND buf_c-cash-desk.pos-type = t-cash-desk.pos-type
    AND buf_c-cash-desk.cash-num = t-cash-desk.cash-num
BY buf_c-cash-desk.chip-num descending:
  if buf_c-cash-desk.cash-on
  AND
  buf_c-cash-desk.cash-on <> t-cash-desk.cash-on
  and not (t-cash-desk.pos-type = {&cd-type-ibs-th}
           or
           t-cash-desk.pos-type = {&cd-type-ibs-th-mob}
          )
  then do:
    run cur-time in this-procedure(output v-today, output v-time).
    if v-today > buf_c-cash-desk.corr-date then do:
        message
        substitute("ВНИМАНИЕ! Касса &1 магазина  &2&3" +
                   "была выключена &4 дней!&3" +
                   "Перешлите на кассы все сделанные за это время изменения!"
                    ,t-cash-desk.cash-num
                    ,t-cash-desk.obj-code
                    ,{&new-line}
                    ,string(v-today - buf_c-cash-desk.corr-date))
       view-as alert-box WARNING.
    end.
    else do:
      timeleft = v-time - buf_c-cash-desk.corr-time.
      sec = timeleft MOD 60.
      timeleft = (timeleft - sec) / 60.
      minute = timeleft MOD 60.
      hour = (timeleft - minute) / 60.
      message
      substitute("ВНИМАНИЕ! Касса &1 магазина  &2&3" +
                 "была выключена в течении &4 часов &5 минут &6 секунд!&3" +
                 "Перешлите на кассы все сделанные за это время изменения!"
                  ,t-cash-desk.cash-num
                  ,t-cash-desk.obj-code
                  ,{&new-line}
                 ,hour
                 ,minute
                 ,sec)
      view-as alert-box WARNING.
    end.
    LEAVE.
  end.
END.
if p-result = 1 then do:
  return substitute("ВНИМАНИЕ! Попытка повторно открыть смену на кассе "  +
                              string(t-cash-desk.cash-num)).

end.
END PROCEDURE.