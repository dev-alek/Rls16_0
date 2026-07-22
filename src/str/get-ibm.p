block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Программа разбора чеков с касс IBM, NKT-IBM

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/13/05
Author: Bakhtadze Natalya
Creation date: 10/13/05

На объекте:

 читает поочередно полученные спул-файлы

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
DEFINE INPUT PARAMETER file_ as character no-undo.
define input-output parameter p-view-log as logical no-undo .

DEFINE VARIABLE vss-revision    as character no-undo init "$Revision$":u .
DEFINE VARIABLE vss-author      as character no-undo init "$Author$":u .
DEFINE VARIABLE vss-date        as character no-undo init "$Date$":u .
DEFINE VARIABLE vss-workfile    as character no-undo init "$Workfile$":u .
DEFINE VARIABLE vss-archive     as character no-undo init "$Archive$":u .
DEFINE VARIABLE vss-description as character no-undo init "Программа приема чеков с касс IBM" .
{ cmp/vssrevis.i }

{ str/get-chk.i }
/*общие для кассовой части и чековой*/

{ str/get-chkc.i def }
/*только чековая часть*/
{ cmp/bitoper.i }

DEFINE VARIABLE n-entry                    as   char no-undo extent 20.
DEFINE VARIABLE kriv2                      as   logical no-undo.
DEFINE VARIABLE accept-types               as   character no-undo .
define variable v-flag-salesman            as   logical   no-undo .
define variable v-flag-card                as   logical   no-undo .
define variable v-end-of-check             as   logical no-undo init yes.
define variable v-is-petrol-check          as logical no-undo .

assign
shop-type = p-obj-type
shop-code = p-obj-code
dflt-cd = p-pos-type
.
{ str/get-chkc.i run }
get-chkc_context.pos-type = p-pos-type.

RUN get-ibm-c(file_) no-error .
if error-status:error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Ошибка при обработке файла &1: &2"
                            , file_
                            , return-value
                          )
                                          ).
  assign
  p-view-log = yes
  .
  undo, return "error":U.
end.

PROCEDURE get-ibm-c.
def input parameter filename as char no-undo.


run get-ibm-parameters in this-procedure no-error.
if error-status:error then do:
  assign
  p-view-log = yes
  .
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!При обработке файла &1 произошла ошибка при получении значений настроечных параметров: &2"
                          , filename
                          , return-value
                        )
                                        ).
  undo, return "error":U.
end.
run gbl/filename.p (
                input filename
               ,output v-full-path
               ,output v-path
               ,output v-file-name
               ,output v-file-name-no-ext
               ,output v-file-name-ext
               ) no-error .
if error-status:error then do:
  assign
  p-view-log = yes
  .
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!При обработке файла &1 произошла ошибка при получении полного пути файлу: &2"
                          , filename
                          , return-value
                        )
                                  ).
  return "error":U.
end.
error-status:error = FALSE.

input stream ChkStream from value( filename ).
_repeat:
REPEAT :
_line:
DO TRANSACTION:
  ss = '':U.
  import stream ChkStream unformatted ss.
  assign
  var-file-line-num = var-file-line-num + 1
  .
  if var-file-line-num modulo 100 = 0 then do:
    run show-counter in p-log-handle .
    run write-counter in p-log-handle (substitute("Файл &1: прочитано строк &2", filename, var-file-line-num)).
  end.
  if ss = "" or ss = ? then do:
      n-entry[1] = "".
      leave _line.
  end.
  repeat:
      ss = REPLACE(ss, "  ", " ").
      if INDEX(ss, "  ") = 0 then leave.
  end.
  DO ii = 1 to num-entries(ss, " "):
      if SUBSTR(ss,1,2) = "03" AND INDEX(entry(5, ss, " "), "E") > 0 and ii >= 3 then do:
          assign
          n-entry[3] = "0"
          n-entry[ii + 1] = entry(ii, ss, " ")
          kriv2 = yes
          .
      end.
      else
      assign
      kriv2 = no
      n-entry[ii] = entry(ii, ss, " ")
      .
  END.
  DO ii = (num-entries(ss, " ") + 1 + if kriv2 then 1 else 0) to 20:
      assign
      n-entry[ii] = "".
  END.
  kriv2 = no.
  assign
  ii = num-entries(ss, " ")    .
END.

DO TRANSACTION :
  CASE n-entry[1]:
    when '' then do:
      /*надо уладить все дела со принятыми чеками!!!*/
      run proc-end in this-procedure no-error .
    end.
    when '00' then  do:  /* Заголовок чека любого типа */
      /*если мы здесь то начинается новый чек надо уладить все дела со старыми!!!*/
      run proc-end in this-procedure no-error .
      run proc-00 in this-procedure no-error .
    end. /*when 00*/
    when "03" then do: /* Оплата чека  или строка чека типа 2,3,4 */
      CASE gbl-type:
        when "1" or when "6" or when "8" then do:
          run proc-03 in this-procedure(input exist) no-error .
        end.
        when "2" or when "3" or when "4" or when "5" then do:
          run proc-03 in this-procedure(input mc-exist) no-error .
        end.
        otherwise do:
          /* ошибка */
        end.
      END CASE.
    end.
    when "01" then  do:  /* Строка чека тип 1,6,7,14,15,16,17*/
      CASE gbl-type:
        when "1"
        or
        when "6"
        or
        when "8"
        or
        when "14"
        or
        when "15"
        or
        when "16"
        or
        when "17" then do:
          run proc-01-gds in this-procedure no-error .
        end.
        otherwise do:
          /* ошибка */
          error-status:error = no.
        end.
      END CASE.
    end.
    when "02" then do: /* Итоговые скидки - могут быть только в чеке типа 1,6 */
      run proc-02-gds in this-procedure no-error .
    end.
    when "04" then do: /* Продажи по группе  могут быть только в чеке типа 1,6 но у нас надо запретить*/
      run proc-04-gds in this-procedure no-error .
    end.
    when "05" then do:
      if gbl-type = "11" then do:
        run proc-01-gds in this-procedure no-error .
      end.
    end.
    when "07" then do:
    end.
    when "08"  then do: /*продавец*/
      run proc-08 in this-procedure .
    end.
    when "09"  then do:  /*клиент-карта*/
      run proc-09 in this-procedure .
    end.
    when "10" then do: /*скидки*/
      run proc-10 in this-procedure .
    end.
    when '16' then  do:  /* бонусы */
      run proc-16 in this-procedure no-error .
    end. /*when 16*/
    otherwise do:
      run proc-end in this-procedure no-error .
    end.
    END CASE .
  END.
END .
DO TRANSACTION:
  run proc-end in this-procedure no-error .
END.
assign
tot-d-pcnt = 0
error-status:error = false.
input stream ChkStream close.
END PROCEDURE.

PROCEDURE get-ibm-parameters:
define variable ii as integer no-undo .
define buffer buf_tt-sum-grp for tt-sum-grp.
if get-chkc_context.shift-on
and not get-chkc_context.cas-shft then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Внимание! На объекте &1&2 требуется использование смен, а настройка СМЕНЫ НА КАССЕ выключена - это недопустимо."
                         , get-chkc_context.obj-type
                         , get-chkc_context.obj-code
                          )).
  assign
  p-view-log = yes
  .
  undo, return "error":U.
end.
get-chkc_context.ibmgroup          = ibmgroup.
if get-chkc_context.t-shft > 0 and get-chkc_context.shift-on = yes then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Внимание! На объекте &1&2 требуется использование смен,&3" +
                          "а настройка СМЕЩЕННЫЕ СМЕНЫ НА КАССЕ&3" +
                          "(АРМ Администратор - Справочники - Магазины - Параметры - время начала пересменки)&3" +
                          "включена - это недопустимо."
                         , get-chkc_context.obj-type
                         , get-chkc_context.obj-code
                         , {&new-line}
                          )).
  assign
  p-view-log = yes
  .
  undo, return "error":U.
end.
if get-chkc_context.is-wth = yes then do:
  accept-types =  "1,2,3,4,5,6,7,13":U.
end.
else do:
  accept-types =  "1,6,13":U.
end.
if logical(get-chkc_context.is-cdinv) then accept-types = accept-types + ",11":U.

if get-chkc_context.is-ptrl
and get-chkc_context.ptrl-check then
assign
accept-types = accept-types + ",14,15,16,17":U.
if get-chkc_context.annu-check then
accept-types = accept-types + ",8":U.
if get-chkc_context.z-check then
accept-types = accept-types + ",12":U.
if get-chkc_context.ibmgroup then do:
  for each buf_tt-sum-grp:
    delete buf_tt-sum-grp.
  end.
  do ii = 1 to num-entries(specgrp, ';'):
    create buf_tt-sum-grp.
    assign
    buf_tt-sum-grp.grp-code = integer(entry(1, entry(ii, specgrp, ';'), '-':U))
    buf_tt-sum-grp.code-2 = integer(entry(2, entry(ii, specgrp, ';'), '-':U))
    buf_tt-sum-grp.gtype = integer(entry(3, entry(ii, specgrp, ';'), '-':U))
    no-error
    .
    if error-status:error then do:
      delete buf_tt-sum-grp.
    end.
  end.
end.
END PROCEDURE.



procedure proc-00 :
define variable v-pay-desk as integer no-undo .
define variable v-no-shift as logical no-undo .

  do
  on error undo, return error
  :
    assign
    gbl-type = trim(n-entry[10])
    .
    /*перепишем в переменные общие для всех  обрабатываемых нами типов чеков данные!!!!*/
    if can-do(accept-types,  gbl-type ) then do:
      assign
      v-is-petrol-check = no
      chk-date_ = 01/01/1990
      chk-time_ = 0
      shift-date_ = chk-date_
      shift-num_ = 0
      shift-name_ = '':U
      shop-code = 0
      shop-type = "":U
      sales-man_ = 0
      v-flag-salesman  = no
      v-flag-card = no
      cashier_ = 0
      pay-desk_ = 0
      z-num_ = 0
      cash-rate_ = 0
      d-card_ = "":U
      d-mask_ = "":U
      cli-type_ = "":U
      cli-code_ = 0
      tot-d-pcnt = 0
      doc-num_ = "":U
      v-end-of-check = no
      .
      if get-chkc_context.cas-shft = yes
      and n-entry[(if ii> 15 then 14 else 13)] = "0000000000" then do:
        assign
        shift-date_ = 01/01/1990
        .
        assign
        v-pay-desk = int( trim( n-entry[5] ) )
        v-no-shift = yes
        no-error .
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Неверный формат спула файла &1: строка &2:&3не установлен режим сменной работы на кассе &4"
                                , file_
                                , var-file-line-num
                                , {&new-line}
                                , v-pay-desk
                              )
                                            ).
        assign
        p-view-log = yes
        .
      end.
      assign
      chk-date_  =   date(
                                    int( substr( n-ENTRY[2], 3, 2 ) ) ,
                                    int( substr( n-ENTRY[2], 1, 2 ) ),
                                    int( substr( n-ENTRY[2], 5, 4 ) )
                                    )
      chk-time_ =  int( substr( n-entry[3], 1, 2 ) ) * 3600 + int( substr( n-entry[3], 3, 2 ) ) * 60  +
                    int( substr(n-entry[3], 5, 2) )
      shift-date_ = if cas-shft
                    then (if v-no-shift then shift-date_ else date(substr(n-entry[(if ii> 15 then 14 else 13)], 3 ) ))
                    else chk-date_
      shop-code = ( if get-chkc_context.hnum
                    then int( trim(  n-entry[4] ) )
                    else p-obj-code )
      shop-type = ( if get-chkc_context.hnum then {&shop} else p-obj-type )
      chk-num_ = int( trim( n-entry[8] ) )
      sales-man_ = int( trim( n-entry[6] ) )
      cashier_ = int( trim( n-entry[7] ) )
      pay-desk_ = int( trim( n-entry[5] ) )
      z-num_ =  int(trim(n-entry[11]))
      cash-rate_ = dec(trim(n-entry[12]))
      d-card_ = if integer(ibmspool) < 6
                then ( if trim( n-entry[9] ) = "0"
                       then "":U
                       else trim( n-entry[9])
                      )
                else "":U
      cli-code_ = (if integer(ibmspool) < 6
                  then 0
                  else integer(trim( n-entry[9] ))
                  )
      cli-type_  = (if integer(ibmspool) < 6
                   then "":U
                   else (if cli-code_ <= 999999999
                         then {&prs}
                         else {&cmp})
                   )
      /*tot-d-pcnt в спуле идет с минусом*/
      tot-d-pcnt = dec( trim( n-entry[(if ii> 15 then 16 else 15)] ) )
      shift-name_ = if cas-shft
                   then string(integer(substr(n-entry[(if ii> 15 then 14 else 13)], 1, 2 ) ))
                   else '':U
      shift-open-time_ = if cas-shft and can-do("13":U,  gbl-type)
                         then (integer(substr(n-entry[(if ii> 15 then 13 else 12)], 9, 2 ) ) * 3600 +
                               integer(substr(n-entry[(if ii> 15 then 13 else 12)], 11, 2 ) ) * 60
                              )
                         else 0
      doc-num_ = if ii> 15 then trim( n-entry[13] ) else '':U
      shift-num_ = integer(shift-name_)
      shift-num_ = if get-chkc_context.shift-on then 0 else shift-num_
      no-error
      .
      if error-status:error then do:
        {&error-in-file-format}
      end.
    end. /*если 1,2,3,4,5,6,7,3,17*/
    else do:
      /*какие-то неизвестные нам виды чеков*/
      assign
      exist = yes
      mc-exist = yes
      . /* Предпологаем что уже есть в базе */
      return.
    end.
    if can-do("13":U,  gbl-type) then do:
      /*закрыть смену на кассе*/
      run proc-13 in this-procedure no-error .
    end.
    if get-chkc_context.is-wth and can-do("2,3,4,5,7":U ,  gbl-type) then do:
      /*инициируем переменные для приема чеков-МЦ*/
      assign
      mc-for-chk-type = ""
      mc-exist = yes /* Предполагаем что уже есть в базе */
      .

      FIND  ub.chk-doc where
            ub.chk-doc.obj-type = shop-type and
            ub.chk-doc.obj-code = shop-code and
            ub.chk-doc.chk-date = chk-date_ and
            ub.chk-doc.pay-desk = pay-desk_ and
            ub.chk-doc.chk-time = chk-time_ and
            ub.chk-doc.chk-num  = chk-num_ and
            ub.chk-doc.sales-man = sales-man_ NO-ERROR NO-WAIT.
      IF NOT AVAIL ub.chk-doc AND NOT LOCKED ub.chk-doc  AND NOT AMBIGUOUS ub.chk-doc then do:
        /*установить смены на кассе*/
        assign
        mc-exist = no
        cr = 0
        lll = lll + 1 .
        CREATE ub.chk-doc.
        assign
        ub.chk-doc.chk-type = 0
        lng = 0
        lnp = 0
        var-discnt-id = 0
        ub.chk-doc.office = ?
        ub.chk-doc.correct = yes
        ub.chk-doc.obj-code = shop-code
        ub.chk-doc.obj-type = shop-type
        ub.chk-doc.doc-code = (if get-chkc_context.db-num = 0
                              then string(next-value(s-chk, {&db-name_schema}))
                              else string( shop-code ) + {&slash-char} + string( next-value( s-chk, {&db-name_schema} ) ))
        ub.chk-doc.chk-num = chk-num_
        ub.chk-doc.chk-date = chk-date_
        ub.chk-doc.chk-time = chk-time_
        ub.chk-doc.sales-man = sales-man_
        ub.chk-doc.pay-desk = pay-desk_
        ub.chk-doc.cashier = cashier_
        ub.chk-doc.discnt = 0
        ub.chk-doc.src-shift-date = shift-date_
        ub.chk-doc.src-shift-name = shift-name_
        ub.chk-doc.shift-name = shift-name_
        ub.chk-doc.shift-num = (if not get-chkc_context.shift-on then shift-num_ else chk-doc.shift-num)
        ub.chk-doc.z-number = z-num_
        ub.chk-doc.chk-type = int(gbl-type)
        ub.chk-doc.cash-rate = cash-rate_
        ub.chk-doc.cash-scale = 1
        ub.chk-doc.doc-num = doc-num_
        ub.chk-doc.tot-doc = 0
        ub.chk-doc.netto = 0
        ub.chk-doc.discnt = 0
        ub.chk-doc.d-pcnt = 0
        ub.chk-doc.src-d-pcnt = 0
        ub.chk-doc.doc-qnty = 0
        ub.chk-doc.src-tot-doc = 0
        ub.chk-doc.src-d-mask = ''
        ub.chk-doc.d-mask = ''
        ub.chk-doc.d-card = ''
        ub.chk-doc.src-d-card = ''
        ub.chk-doc.src-cli-type = ?
        ub.chk-doc.src-cli-code = ?
        ub.chk-doc.cli-type = ?
        ub.chk-doc.cli-code = ?
        ub.chk-doc.doc-num2 = ?
        ub.chk-doc.out-2-code = ?
        no-error
        .
        if error-status:error then do:
          assign
          ub.chk-doc.correct = no
          .
        end.
        mc-prev-code = ub.chk-doc.doc-code.
      end. /* not(can-find) */
      else
      mc-curr-chk-type = 0 .
    end.
    if can-do( "1,6,8,11,12,13,14,15,16,17" , gbl-type ) then do:
      /*инициируем переменные для приема товарных чеков*/
      assign
      for-chk-type = ""
      exist = yes  /* Предполагаем что уже есть в базе */
      .
      FIND  ub.chk-doc where
            ub.chk-doc.obj-type = shop-type and
            ub.chk-doc.obj-code = shop-code and
            ub.chk-doc.chk-date = chk-date_ and
            ub.chk-doc.pay-desk = pay-desk_ and
            ub.chk-doc.chk-time = chk-time_ and
            ub.chk-doc.chk-num = chk-num_ and
            ub.chk-doc.sales-man = sales-man_ NO-ERROR NO-WAIT.
      IF NOT AVAIL ub.chk-doc AND NOT LOCKED ub.chk-doc  AND NOT AMBIGUOUS ub.chk-doc then do:
        /*установить смены на кассе*/
        assign
        exist = no
        cr = 0
        lll = lll + 1 .
        create ub.chk-doc.
        assign
        ub.chk-doc.office = ?
        lng = 0
        lnp = 0
        sub-d = 0
        var-discnt-id = 0
        lng-sub-d = 0
        netto-for-sub-d = 0
        ub.chk-doc.obj-code = shop-code
        ub.chk-doc.obj-type = shop-type
        ub.chk-doc.doc-code = (if get-chkc_context.db-num = 0
                            then string(next-value(s-chk, {&db-name_schema}))
                            else string( shop-code ) + {&slash-char} + string( next-value( s-chk, {&db-name_schema} ) ))
        ub.chk-doc.chk-num = chk-num_
        ub.chk-doc.chk-date = chk-date_
        ub.chk-doc.chk-time = chk-time_
        ub.chk-doc.sales-man = sales-man_
        ub.chk-doc.pay-desk = pay-desk_
        ub.chk-doc.cashier = cashier_
        ub.chk-doc.discnt = 0
        ub.chk-doc.src-d-card =  d-card_
        ub.chk-doc.src-d-pcnt = - tot-d-pcnt
        ub.chk-doc.src-shift-date = shift-date_
        ub.chk-doc.src-shift-name = shift-name_
        ub.chk-doc.shift-name = shift-name_
        ub.chk-doc.shift-num = (if not get-chkc_context.shift-on then shift-num_ else ub.chk-doc.shift-num)
        ub.chk-doc.cash-rate = cash-rate_
        ub.chk-doc.cash-scale = 1
        ub.chk-doc.z-number = z-num_
        ub.chk-doc.doc-num = doc-num_
        ub.chk-doc.chk-type = integer(gbl-type)
        v-is-petrol-check = lookup(string(ub.chk-doc.chk-type) , {&petrol-receipt-codes}) > 0
        ub.chk-doc.correct = yes
        no-error
        .
        if error-status:error then do:
          ub.chk-doc.correct = no.
        end.
        prev-code = ub.chk-doc.doc-code.
        if gbl-type = "12" then do: /*временная затычка пока карпов не сделает запись*/
          define variable v-curr-abbr as character no-undo .
          { gbl/exchrate.i get-chkc_context.base-code ub.chk-doc.chk-date bank-rate_ bank-scale_ v-curr-abbr }
          create ub.chk-pay.
          assign
          lnp = lnp + 1
          ub.chk-pay.doc-code = ub.chk-doc.doc-code
          ub.chk-pay.line-num = lnp
          ub.chk-pay.chk-date = ub.chk-doc.chk-date
          ub.chk-pay.obj-code = shop-code
          ub.chk-pay.obj-type = shop-type
          ub.chk-pay.tot-rubl = 0
          ub.chk-pay.tot-sum = 0
          ub.chk-pay.tot-base = 0
          ub.chk-pay.pay-code = 0
          ub.chk-pay.curr-code = 0
          ub.chk-pay.time-oper = time-oper_
          ub.chk-pay.cash-rate = ub.chk-doc.cash-rate
          ub.chk-pay.bank-rate = 1
          ub.chk-pay.bank-scale = 1
          ub.chk-pay.pass-pay =  0
          ub.chk-pay.pay-card = '':U
          ub.chk-pay.line-type = "":U
          ub.chk-pay.line-sign = yes
          ub.chk-pay.is-error = no
          .
        end. /*if gbl-type = "12" then do:*/
      end. /* not(can-find) */
      else
    end. /*товарные чеки*/
  end.

end procedure. /* proc-00 */


procedure proc-01-gds :
DEFINE VARIABLE no-add-price as logical no-undo .
define buffer buf_cd-plu for ub.cd-plu.

  do
  on error undo, return error
  :
    if not exist then do:
      if v-end-of-check then do:
        if available ub.chk-doc then do:
          assign
          ub.chk-doc.correct = no
          for-chk-type = for-chk-type + {&summa-err} + {&comma-char}
          .
        end.
        {&error-in-file-format}
      end.
      assign
      nozzle_ = 0
      place_ = 0


      .
      if ub.chk-doc.chk-type = Integer({&rcpt-inventory}) then do:
         assign
         bc-buf = trim( n-entry[2] )
         curr-string-qnty = dec( n-entry[3] )
         price-from-check = 0
         sum-from-check = 0
         t-c-d = 0
          time-oper_ =  if integer(ibmspool) >= 4
                        then (
                              int( substr( n-entry[9], 1, 2 ) ) * 3600 + int( substr( n-entry[9], 3, 2 ) ) * 60  +
                              int( substr(n-entry[9], 5, 2) )
                              )
                        else ub.chk-doc.chk-time
         pass-gds_ =  0
         pump_ = 0
         road-tax_ = 0
         no-add-price = no
         no-error
         .
      end.
      else do:
        assign
        curr-string-qnty = dec( n-entry[4] )
        bc-buf = trim( n-entry[2] )
        price-from-check = dec( n-entry[3] )
        sum-from-check = dec( n-entry[7] )
        t-c-d = - dec ( n-entry[5])
        time-oper_ =  if integer(ibmspool) >= 4
                      then (
                            int( substr( n-entry[9], 1, 2 ) ) * 3600 + int( substr( n-entry[9], 3, 2 ) ) * 60  +
                            int( substr(n-entry[9], 5, 2) )
                            )
                      else ub.chk-doc.chk-time
        pass-gds_ =  (if integer(ibmspool) >= 4 and integer(n-entry[8]) > 1
                      then 1
                      else 0
                      )
        pump_ = int(n-entry[6] )
        road-tax_ = (if ii > 8 and integer(ibmspool) <= 3 then dec(n-entry[9]) else 0 )
        /*составной товар не добавлять к сумме продажи*/
        no-add-price = if ii /*NUM-ENTRIES(s, " " )*/  > 7 and BinMask(int(n-entry[8]), "1") = yes
                      then yes
                      else no
        nozzle_ = if integer(ibmspool) >= 6
                  then integer(n-entry[10])
                  else 0
        place_ = if integer(ibmspool) >= 6
                  then integer(n-entry[11])
                  else 0
        no-error
        .
      end.
      if error-status:error then do:
        {&error-in-file-format}
      end.
      CREATE ub.chk-gds.
      assign
      lng = lng + 1
      ub.chk-gds.doc-code = ub.chk-doc.doc-code
      ub.chk-gds.line-num = lng
      ub.chk-gds.grp-code = 0
      ub.chk-gds.chk-date = ub.chk-doc.chk-date
      ub.chk-gds.b-code = 0
      ub.chk-gds.src-code = bc-buf
      ub.chk-gds.src-price = price-from-check
      ub.chk-gds.src-sum   = sum-from-check
      ub.chk-gds.src-qnty = curr-string-qnty
      ub.chk-gds.doc-qnty = 0
      ub.chk-gds.price-service = (if no-add-price
                               then price-from-check
                               else 0)
      ub.chk-gds.time-oper = time-oper_
      ub.chk-gds.src-discnt = if integer(ibmspool) < 6 and curr-string-qnty <> 0
                           then  (t-c-d / curr-string-qnty)
                           else 0
      ub.chk-gds.pass-gds = pass-gds_
      ub.chk-gds.is-error = no
      ub.chk-gds.doc-qnty = 0
      ub.chk-gds.pump = pump_
      ub.chk-gds.nozzle = nozzle_
      ub.chk-gds.loc1 = (if place_ = 0 then '':U else string(place_))
      ub.chk-gds.road-tax = road-tax_
      ub.chk-gds.sales-man = sales-man_
      ub.chk-doc.sales-man = (if not v-flag-salesman
                          and
                          (
                          ub.chk-doc.sales-man = 0
                          or ub.chk-doc.sales-man = sales-man_
                          or sales-man_ = 0
                          )
                          then sales-man_
                          else 0)
      ub.chk-doc.sales-man = (if ub.chk-doc.sales-man = ? then 0 else ub.chk-doc.sales-man)
      v-flag-salesman   = (if not v-flag-salesman
                          and (sales-man_ <> 0 and sales-man_ <> ub.chk-doc.sales-man)
                          then yes
                          else v-flag-salesman)
      ub.chk-gds.src-d-card = (if d-card_ <> "":U then d-card_ else ?)
      ub.chk-gds.src-cli-type = (if cli-type_ = "":u then ? else cli-type_)
      ub.chk-gds.src-cli-code = (if cli-code_ = 0 then ? else cli-code_)
      ub.chk-gds.src-d-card = (if d-mask_ <> "":U then d-mask_ else ?)
      ub.chk-gds.d-card = (if d-mask_ <> "":U
                       and (d-card_ = "":U or trim(d-card_)  = string(0))
                       then d-mask_
                       else (if d-card_ <> "":U
                             then d-card_
                             else ub.chk-gds.d-card)
                       )
      ub.chk-gds.line-sign = (if ub.chk-doc.chk-type = integer({&rcpt-sale})
                          then (chk-gds.src-qnty >= 0)
                          else (chk-gds.src-qnty <= 0)
                          )
      ub.chk-gds.line-type = "":U
      ub.chk-gds.write-off-code = (if ub.chk-doc.chk-type = integer({&rcpt-tech-refuell})
                                then  integer({&wro-r-tech-refuell})
                                else 0)
      netto-for-sub-d = netto-for-sub-d + (if v-is-petrol-check then 0
                                           else (chk-gds.src-price - ub.chk-gds.src-discnt) * ub.chk-gds.src-qnty)
      .
      if ub.chk-gds.src-discnt <> 0
      and integer(ibmspool) < 6
      then do:
        create ub.chk-discnt.
        assign
        ub.chk-discnt.doc-code = ub.chk-doc.doc-code
        ub.chk-discnt.record-type = 0
        ub.chk-discnt.discnt-id = (var-discnt-id + 1)
        ub.chk-discnt.line-num = ub.chk-gds.line-num
        ub.chk-discnt.time-oper = ub.chk-doc.chk-time
        ub.chk-discnt.line-type = integer({&discnt-gds})
        ub.chk-discnt.line-sign =  (chk-gds.src-qnty >= 0 ) NE (chk-gds.src-discnt > 0 )
        ub.chk-discnt.pass-discnt = integer({&discnt-p-auto})
        ub.chk-discnt.value-type = integer({&discnt-v-unknown})
        ub.chk-discnt.discnt-type = integer({&discnt-t-unknown})
        ub.chk-discnt.src-d-card = ub.chk-gds.src-d-card
        ub.chk-discnt.d-card = ub.chk-gds.d-card
        ub.chk-discnt.discnt-value-abs = t-c-d
        ub.chk-discnt.object-qnty = ub.chk-gds.src-qnty
        ub.chk-discnt.object-sum = ub.chk-gds.src-sum
        ub.chk-discnt.discnt-value-pcnt = if ub.chk-gds.src-sum <> 0 then
                                        ub.chk-gds.src-discnt * curr-string-qnty / ub.chk-gds.src-sum * 100
                                        else 0
        ub.chk-discnt.object-line-num = ub.chk-gds.line-num
        ub.chk-discnt.pay-desk = ub.chk-doc.pay-desk
        ub.chk-discnt.obj-code = ub.chk-doc.obj-code
        ub.chk-discnt.obj-type = ub.chk-doc.obj-type
        ub.chk-discnt.chk-date = ub.chk-doc.chk-date
        ub.chk-discnt.chk-time = ub.chk-doc.chk-time
        var-discnt-id = var-discnt-id + 1
        .
       end.
    end. /* if not exist */
  end.

end procedure. /* proc-01 */


procedure proc-02-gds :
DEFINE VARIABLE var-sub-d as decimal no-undo .
  do
  on error undo, return error
  :
    if exist then return.
    assign
    var-sub-d =  - dec( n-entry[2] )  /* "+" - т.к. скидка  идет со знаком "-" */
    lng-sub-d = lng
    no-error
    .
    if error-status:error then dO:
      {&error-in-file-format}
    end.
    if var-sub-d = 0 then return.
    create ub.chk-discnt.
    assign
    ub.chk-discnt.doc-code = ub.chk-doc.doc-code
    ub.chk-discnt.record-type = 0
    ub.chk-discnt.discnt-id = (var-discnt-id + 1)
    ub.chk-discnt.line-num = ub.chk-gds.line-num
    ub.chk-discnt.time-oper = ub.chk-doc.chk-time
    ub.chk-discnt.line-type = integer({&discnt-sub-total})
    ub.chk-discnt.line-sign = yes
    ub.chk-discnt.pass-discnt = integer({&discnt-p-auto})
    ub.chk-discnt.value-type = integer({&discnt-v-abs})
    ub.chk-discnt.discnt-type = if ub.chk-doc.src-d-card <> ""
                              then integer({&discnt-t-d-card})
                              else integer({&discnt-t-sum})
    ub.chk-discnt.src-d-card = ub.chk-doc.src-d-card
    ub.chk-discnt.discnt-value-abs = var-sub-d
    ub.chk-discnt.discnt-value-pcnt = if netto-for-sub-d = 0
                                    then 0
                                    else var-sub-d * 100 / netto-for-sub-d
    ub.chk-discnt.object-line-num = 0
    ub.chk-discnt.object-sum = netto-for-sub-d
    ub.chk-discnt.pay-desk = ub.chk-doc.pay-desk
    ub.chk-discnt.obj-code = ub.chk-doc.obj-code
    ub.chk-discnt.obj-type = ub.chk-doc.obj-type
    ub.chk-discnt.chk-date = ub.chk-doc.chk-date
    ub.chk-discnt.chk-time = ub.chk-doc.chk-time
    var-discnt-id = var-discnt-id + 1
    sub-d = sub-d + var-sub-d
    netto-for-sub-d = netto-for-sub-d - sub-d
    .
    release ub.chk-discnt.
  end. /*doe*/

end procedure. /* proc-02 */

procedure proc-04-gds :
define buffer buf_tt-sum-grp for tt-sum-grp.

  do
  on error undo, return error return-value
  :
    if ( NOT exist ) AND ( dec( n-entry[4] ) <> 0 ) then /* ненулевое кол-во */ do:
      assign
      curr-string-qnty = dec( n-entry[4] )
      bc-buf = trim( n-entry[2] )
      price-from-check = dec( n-entry[3] )
      t-c-d = - dec( n-entry[5] ) /* "-" т.к. скидка идет со знаком "-" */
      sum-from-check = dec(n-entry[6])
      time-oper_ =  if integer(ibmspool) >= 4
                    then (
                          int( substr( n-entry[9], 1, 2 ) ) * 3600 + int( substr( n-entry[9], 3, 2 ) ) * 60  +
                          int( substr(n-entry[9], 5, 2) )
                          )
                    else ub.chk-doc.chk-time
      pass-gds_ =  (if integer(ibmspool) >= 4 and integer(n-entry[8]) > 1
                    then 1
                    else 0
                    )
      no-error
      .
      if error-status:error then do:
        {&error-in-file-format}
      end.
      if curr-string-qnty <> 0 then /* ненулевое кол-во */ do:
        if get-chkc_context.ibmgroup and  can-find(first tt-sum-grp) then do:
          find first buf_tt-sum-grp no-lock where
                  buf_tt-sum-grp.grp-code = integer(bc-buf)
          no-error .
          if not available buf_tt-sum-grp then do:
            assign
            bc-buf = {&delim-par} + bc-buf.
          end.
          else do:
            assign
            bc-buf = string(buf_tt-sum-grp.code-2) + {&delim-par} + bc-buf.
          end.
          CREATE ub.chk-gds.
          assign
          lng = lng + 1
          ub.chk-gds.doc-code = ub.chk-doc.doc-code
          ub.chk-gds.line-num = lng
          ub.chk-gds.chk-date = ub.chk-doc.chk-date
          ub.chk-gds.src-code = bc-buf
          ub.chk-gds.doc-qnty = 0
          ub.chk-gds.src-discnt = t-c-d
          ub.chk-gds.src-qnty = sum-from-check
          ub.chk-gds.src-price = 1
          ub.chk-gds.src-sum = sum-from-check
          ub.chk-gds.time-oper =  time-oper
          ub.chk-gds.pass-gds = pass-gds_
          ub.chk-gds.sum-base = ub.chk-gds.src-qnty * ub.chk-gds.src-price
          ub.chk-gds.line-sign = (if ub.chk-doc.chk-type = integer({&rcpt-sale})
                              then (chk-gds.src-qnty >= 0)
                              else (chk-gds.src-qnty <= 0)
                              )
          ub.chk-gds.line-type = "":U
          .
          if available buf_tt-sum-grp and buf_tt-sum-grp.gtype = 24
          and integer(ibmspool) < 6
          then do:
            assign
            ub.chk-doc.src-d-card = entry(1, ub.chk-doc.doc-num, {&delim-par} ).
          end.
        end.
        else do:
          CREATE ub.chk-gds.
          assign
          lng = lng + 1
          ub.chk-gds.doc-code = ub.chk-doc.doc-code
          ub.chk-gds.line-num = lng
          ub.chk-gds.grp-code = integer(bc-buf)
          ub.chk-gds.chk-date = ub.chk-doc.chk-date
          ub.chk-gds.b-code = 0
          ub.chk-gds.price-base = price-from-check
          ub.chk-gds.doc-qnty = curr-string-qnty
          ub.chk-gds.src-discnt = t-c-d
          ub.chk-gds.src-qnty = curr-string-qnty
          ub.chk-gds.src-price = price-from-check
          ub.chk-gds.src-sum = sum-from-check
          ub.chk-gds.time-oper =  time-oper
          ub.chk-gds.pass-gds = pass-gds_
          ub.chk-gds.sum-base = ub.chk-gds.doc-qnty * ub.chk-gds.price-base
          ub.chk-gds.line-sign = (if ub.chk-doc.chk-type = integer({&rcpt-sale})
                              then (chk-gds.src-qnty >= 0)
                              else (chk-gds.src-qnty <= 0)
                              )
          ub.chk-gds.line-type = "grp":U
          .

        end.
      end.
    end. /* if not exist */
  end.

end procedure. /* proc-04 */

procedure proc-13 :

do
on error undo, return error
:
    /*чек закрытия смены на кассе слава богу состоит из одной строки!!!!*/
  if get-chkc_context.cas-shft then do:
    /*на кассах есть смены*/
    if current-pay-desk <> pay-desk_
    or NOT (current-cas-shift-name =  shift-name_
        AND current-cas-shift-date = shift-date_)
    OR not avail buf_shift-cash then do:
      { str/libchkvl_get-cash-shift.i
      "buffer get-chkc_context:handle"
      buf_shift-cash
      pay-desk_
      shift-date_
      shift-name_
      z-num_
      chk-date_
      chk-time_
      shift-open-time_
      no-error
      }
      if available buf_shift-cash then do:
        assign
        current-pay-desk = buf_shift-cash.cash-num
        current-cas-shift-name = buf_shift-cash.shift-name
        current-cas-shift-date = buf_shift-cash.shift-date
        .
      end.
      else do:
        current-pay-desk = -1.
      end.
    end.
  end. /*if cas-shft*/
end.

end procedure. /* proc-13 */

procedure proc-08 :
/*регистрация продавца в чеке*/

  do
  on error undo, return error
  :
    assign
    sales-man_ = integer(n-entry[2])
    no-error .
    if error-status:error then do:
      {&error-in-file-format}
    end.
    assign
    ub.chk-doc.sales-man = (if ub.chk-doc.sales-man = sales-man_
                          or (not v-flag-salesman
                            and
                            (ub.chk-doc.sales-man = 0 or ub.chk-doc.sales-man = ?)
                            )
                        then sales-man_
                        else 0)
    v-flag-salesman   = (if not v-flag-salesman  and sales-man_ <> 0
                        then yes
                        else v-flag-salesman)
    .
  end.

end procedure. /* proc-08 */


procedure proc-09 :
/*регистрация клиента-карты*/
define variable v-dopi as integer no-undo .
define variable src-d-card_ as character no-undo .
  do
  on error undo, return error
  :
    if not exist and available ub.chk-doc then do:
      assign
      cli-code_ = 0
      cli-type_ =  "":U
      d-card_ = "":U
      d-mask_ = "":U
      src-d-card_ = '':U
      .
      assign
      src-d-card_ = n-entry[3]
      d-card_ = n-entry[5]
      cli-code_ = integer(n-entry[2])
      d-mask_ = n-entry[4]
      cli-type_ = (if cli-code_ > 999999999 then {&cmp} else {&prs})
      no-error .
      if error-status:error then do:
        {&error-in-file-format}
      end.
      assign
      v-dopi = integer(ub.chk-doc.src-d-card)
      no-error .
      assign
      ub.chk-doc.src-d-card       = (if /*d-card_ = "":U or d-card_ = '0':U
                                or*/  ub.chk-doc.src-d-card = d-card_
                                then ub.chk-doc.src-d-card
                                else (if true /*(not v-flag-card
                                          and (ub.chk-doc.src-d-card = ? or ub.chk-doc.src-d-card = "":U or v-dopi = cli-code_ )
                                          )
                                      or (
                                           ((d-mask_ <> '0':U)
                                           and
                                           (ub.chk-doc.src-d-card = src-d-card_))
                                           or
                                           ((d-mask_ = '0')
                                           and
                                           ub.chk-doc.src-d-card = d-card_)
                                         )*/
                                      then (if d-mask_ <> '0':U then src-d-card_ else d-card_)
                                      else "-0":U
                                      )
                                )
      ub.chk-doc.src-cli-type   = (if cli-type_ = "":U
                                or ub.chk-doc.src-cli-type = cli-type_
                                then ub.chk-doc.src-cli-type
                                else (if true
                                      /*(not v-flag-card
                                      and (ub.chk-doc.src-cli-type = ? or ub.chk-doc.src-cli-type = "":U or v-dopi = cli-code_ )
                                      )
                                      or  ub.chk-doc.src-cli-type = cli-type_*/
                                      then cli-type_
                                      else ?)
                              )
      ub.chk-doc.src-cli-code   = (if cli-code_ = 0
                                or ub.chk-doc.src-cli-code = cli-code_
                                then ub.chk-doc.src-cli-code
                                else (if true
                                      /*(not v-flag-card
                                      and (ub.chk-doc.src-cli-code = ? or ub.chk-doc.src-cli-code = 0 or v-dopi = cli-code_ )
                                      )
                                      or ub.chk-doc.src-cli-code =  cli-code_*/
                                      then cli-code_
                                      else ?)
                              )
      ub.chk-doc.src-d-mask   = (if d-mask_ = "":U
                                or ub.chk-doc.src-d-mask = d-mask_
                                then ub.chk-doc.src-d-mask
                                else (if true
                                      /*(not v-flag-card
                                      and (ub.chk-doc.src-d-mask = ? or ub.chk-doc.src-d-mask = "":U )
                                      )
                                      or  ub.chk-doc.src-d-mask = d-mask_*/
                                      then d-mask_
                                      else ?)
                              )
      ub.chk-doc.d-card = if d-mask_ <> "":U
                      and trim(n-entry[5]) = string(0)
                      then d-mask_
                      else (if ub.chk-doc.d-card <> "":U then ub.chk-doc.d-card else d-card_)
      /*v-flag-card         = (if not v-flag-card  and d-card_ <> "":U
                          then yes
                          else v-flag-card)*/
      .
    end.
  end.

end procedure. /* proc-09 */


procedure proc-10 :
/*регистрация скидок*/
define variable lnd-spl as integer no-undo .
define variable disc-sum_ as decimal no-undo .
define variable disc-pcnt_ as decimal no-undo .
define variable disc-reason_ as integer no-undo .
define variable disc-vtype_ as integer no-undo .
define variable disc-type_ as integer no-undo .
define variable disc-mode_ as character no-undo .
define variable disc-kat_   as integer no-undo .
define variable v-dop-vtype_ as integer no-undo .
define variable src-sum_ as decimal no-undo .

  do
  on error undo, return error
  :

    if not exist then do:
      assign
      disc-sum_ = - decimal(n-entry[6])
      disc-pcnt_ = - decimal(n-entry[8])
      disc-reason_ = 0
      disc-type_ = integer(substring(n-entry[3], 3, 2))
      v-dop-vtype_ = integer(substring(n-entry[3], 1, 2))
      disc-vtype_  = if v-dop-vtype_ = 1
                     then integer({&discnt-v-pcnt})
                     else (if v-dop-vtype_ = 2
                           then integer({&discnt-v-abs})
                           else  (if v-dop-vtype_ = 3
                                  then integer({&discnt-v-fp})
                                  else integer({&discnt-v-unknown})
                                 )
                          )
      disc-kat_    =  integer(n-entry[7])
      src-sum_ = decimal(n-entry[5])
      no-error
      .
      if error-status:error then do:
        {&error-in-file-format}
      end.
      create ub.chk-discnt.
      assign
      ub.chk-discnt.doc-code = ub.chk-doc.doc-code
      ub.chk-discnt.record-type = 0
      ub.chk-discnt.discnt-id = (var-discnt-id + 1)
      ub.chk-discnt.line-num = ub.chk-gds.line-num
      ub.chk-discnt.time-oper = ub.chk-gds.time-oper
      ub.chk-discnt.line-type = integer({&discnt-gds})
      ub.chk-discnt.line-sign =  (chk-gds.src-qnty >= 0 ) NE (chk-gds.src-discnt > 0 )
      ub.chk-discnt.pass-discnt = integer({&discnt-p-auto})
      ub.chk-discnt.value-type = if disc-vtype_ = 0
                              then integer({&discnt-v-unknown})
                              else disc-vtype_
      ub.chk-discnt.src-d-card = ub.chk-gds.src-d-card
      ub.chk-discnt.d-card = ub.chk-gds.d-card
      ub.chk-discnt.discnt-value-abs = (if disc-sum_ <> 0 then disc-sum_ else (disc-pcnt_ * src-sum_  / 100))
      ub.chk-discnt.discnt-value-pcnt = disc-pcnt_
      ub.chk-discnt.kateg = disc-kat_
      ub.chk-gds.src-discnt  = ub.chk-gds.src-discnt + (if disc-sum_ <> 0
                                                  then disc-sum_
                                                  else (disc-pcnt_ * src-sum_  / 100)) / ub.chk-gds.src-qnty
      netto-for-sub-d = netto-for-sub-d - (chk-gds.src-discnt  * ub.chk-gds.src-qnty)
      ub.chk-discnt.object-line-num = ub.chk-gds.line-num
      ub.chk-discnt.pay-desk = ub.chk-doc.pay-desk
      ub.chk-discnt.obj-code = ub.chk-doc.obj-code
      ub.chk-discnt.obj-type = ub.chk-doc.obj-type
      ub.chk-discnt.chk-date = ub.chk-doc.chk-date
      ub.chk-discnt.chk-time = ub.chk-doc.chk-time
      ub.chk-discnt.object-qnty = ub.chk-gds.src-qnty
      ub.chk-discnt.object-sum = src-sum_
      var-discnt-id = var-discnt-id + 1
      .
      assign
      ub.chk-discnt.discnt-type = if disc-type_ > 0
                               then convert-discount(disc-reason_, disc-type_, ub.chk-discnt.line-type)
                               else integer({&discnt-t-unknown})
      .
    end. /*if exist*/
  end.
end procedure. /* proc-10 */

procedure proc-16 :
/*регистрация бонусов*/
/*
mappinde бонусов
тип объекта выполнившего начисление                                                     pass-discnt
идентификатор транзакции предоставленный внешней системой                               discnt-id
номер карты                                                                             src-d-card
код валюты бонуса                                                                       kateg
количество единицы бонуcов/компенсации                                                  discnt-value-abs
номер бонусной схемы                                                                    discnt-type
вид бонуса - привяза к товару, к чеку, не определено                                    line-type
номер строки продажи для которой выполнено начисление                                   object-line-num
код товара есди бонус привязан к товару                                                 -
*/

define variable  bonus-accounter_  as integer no-undo .
define variable  bonus-trans-id_   as integer no-undo .
define variable  bonus-src-d-card_ as character no-undo .
define variable  bonus-curr-code_  as integer no-undo .
define variable  bonus-sum_        as decimal no-undo .
define variable  bonus-schema_     as integer no-undo .
define variable  bonus-line-type-chr_ as character no-undo .
define variable  bonus-object-line-num_ as integer no-undo .
define variable  bonus-src-code_   as decimal no-undo .
define variable  bonus-src-code-chr as character no-undo .
define buffer buf_chk-gds for ub.chk-gds.



  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :

    if not exist then do:
      assign
      bonus-accounter_ = integer(n-entry[2])
      bonus-trans-id_ = integer(n-entry[3])
      bonus-src-d-card_ = n-entry[4]
      bonus-curr-code_ = integer(n-entry[5])
      bonus-sum_ = decimal(n-entry[6])
      bonus-schema_ = integer(n-entry[7])
      bonus-line-type-chr_ = n-entry[8]
      bonus-object-line-num_ = integer(n-entry[9])
      bonus-src-code-chr = n-entry[10]
      bonus-src-code_ = decimal(n-entry[10])
      no-error
      .
      if error-status:error then do:
        {&error-in-file-format}
      end.
      create ub.chk-discnt.
      assign
      ub.chk-discnt.doc-code = ub.chk-doc.doc-code
      ub.chk-discnt.record-type = 4
      ub.chk-discnt.line-num = ub.chk-gds.line-num
      ub.chk-discnt.discnt-id = (if bonus-trans-id_ = 0 then ub.chk-discnt.line-num else bonus-trans-id_)
      ub.chk-discnt.time-oper = ub.chk-gds.time-oper
      ub.chk-discnt.line-type = (if bonus-line-type-chr_ = 'I'
                              then integer({&discnt-gds})
                              else (if bonus-line-type-chr_ = 'T'
                                    then integer({&discnt-sub-total})
                                    else integer({&discnt-unknown})
                                   )
                              )
      ub.chk-discnt.pass-discnt = bonus-accounter_
      ub.chk-discnt.value-type = integer({&discnt-v-bonus})
      ub.chk-discnt.src-d-card = bonus-src-d-card_
      ub.chk-discnt.d-card = bonus-src-d-card_
      ub.chk-discnt.discnt-value-abs = bonus-sum_
      ub.chk-discnt.discnt-value-pcnt = (if ub.chk-discnt.line-type = integer({&discnt-gds})
                                      then bonus-src-code_
                                      else 0)
      ub.chk-discnt.discnt-type = bonus-schema_
      ub.chk-discnt.kateg = (if bonus-curr-code_ > 0
                          then bonus-curr-code_
                          else (if bonus-curr-code_ = kassa-rub-code
                                then 0
                                else -1 )
                          )
      ub.chk-discnt.object-line-num = (if bonus-object-line-num_ <> 0
                                    then bonus-object-line-num_
                                    else ub.chk-gds.line-num)
      ub.chk-discnt.pay-desk = ub.chk-doc.pay-desk
      ub.chk-discnt.obj-code = ub.chk-doc.obj-code
      ub.chk-discnt.obj-type = ub.chk-doc.obj-type
      ub.chk-discnt.chk-date = ub.chk-doc.chk-date
      ub.chk-discnt.chk-time = ub.chk-doc.chk-time
      .

      if ub.chk-discnt.line-type = integer({&discnt-gds}) then do:
        if available ub.chk-gds
        and (bonus-src-code-chr = ub.chk-gds.src-code
            or bonus-object-line-num_  = ub.chk-gds.line-num ) then do:
        end.
        else do:
          for each buf_chk-gds no-lock where
                  buf_Chk-gds.doc-code = ub.chk-doc.doc-code:
            if buf_chk-gds.src-code = bonus-src-code-chr then do:
              ub.chk-discnt.object-line-num = buf_chk-gds.line-num.
              leave.
            end.
          end.
        end.
      end.
      if ub.chk-discnt.line-type = integer({&discnt-sub-total})
      and available ub.chk-gds
      and ub.chk-discnt.object-line-num = ub.chk-gds.line-num then do:
        assign
        ub.chk-discnt.object-sum = netto-for-sub-d
        ub.chk-discnt.discnt-value-pcnt = (if netto-for-sub-d <> 0
                                       and (chk-discnt.kateg = - 1
                                       or ub.chk-discnt.kateg <> - 1
                                       and (
                                            (chk-discnt.kateg = 0
                                            and get-chkc_context.r-b = {&r-b-rubl}
                                            )
                                            or
                                            (chk-discnt.kateg = get-chkc_context.base-code
                                            and get-chkc_context.r-b = {&r-b-base})
                                           ))
                                       then bonus-sum_ / ub.chk-gds.src-sum * 100
                                       else ub.chk-discnt.discnt-value-pcnt)
        .
      end.
    end. /*if exist*/
  end.
end procedure. /* proc-10 */


procedure proc-end :

  do
  on error undo, return error
  :
     /*ппроверка всего что только что приняли*/
     get-chkc_context.ll = lll.
    { str/libchkvl_getcheck.i
      "buffer get-chkc_context:handle"
      ~{&add-def~}
      ''
      yes
      yes
      ?
      lng-sub-d
      sub-d
      var-discnt-id
      prev-code
      no-error
     }
      { str/libchkvl_getwcheck.i
      "buffer get-chkc_context:handle"
      ~{&add-def~}
      ''
      yes
      yes
      ?
      mc-prev-code
      no-error
      }
      .
     assign
     prev-code = "":U
     mc-prev-code = "":U
     p-view-log = (p-view-log or get-chkc_context.view-log)
     lll = get-chkc_context.ll
     .
  end.

end procedure. /* proc-end */

{ str/getibm03.i }