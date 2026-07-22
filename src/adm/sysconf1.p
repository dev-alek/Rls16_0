block-level on error undo, throw.
/*

$Revision: 7d2fe421d6dd, 1113, rls $
$Author: SMMolotkov $
$Date: Thu Dec 14 02:13:53 2017 +0300 $
$Workfile: sysconf1.p $
$Archive: adm/sysconf1.p $

Сохранение изменений СВОЕЙ фирмы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/20/04
Author: Bakhtadze Natalya
Creation date: 01/20/04

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input-output     parameter p-rec as recid no-undo.
define input parameter  p-mode                as character no-undo .
define input parameter  p-silent              as logical no-undo .
define input parameter  p-is-deploy           as logical no-undo .
define input parameter  p-host-code           like ub.sysconf.host-code        no-undo .
define input parameter  p-grp-code            like ub.clients.grp-code         no-undo .
define input parameter  p-obj-name            like ub.clients.obj-name         no-undo .
define input parameter  p-avrg-price          like ub.sysconf.avrg-price       no-undo .
define input parameter  p-artic-disable       like ub.sysconf.artic-disable    no-undo .
define input parameter  p-base-code           like ub.sysconf.base-code        no-undo .
define input parameter  p-branch              like ub.sysconf.branch           no-undo .
define input parameter  p-cash-pay            like ub.sysconf.cash-pay         no-undo .
define input parameter  p-cashier             like ub.sysconf.cashier          no-undo .
define input parameter  p-cons-vat-pc         like ub.sysconf.cons-vat-pc      no-undo .
define input parameter  p-credit-pay          like ub.sysconf.credit-pay       no-undo .
define input parameter  p-firm-db-num         like ub.sysconf.firm-db-num      no-undo .
define input parameter  p-head-position       like ub.sysconf.head-position    no-undo .
define input parameter  p-KOPF                like ub.sysconf.KOPF             no-undo .
define input parameter  p-negative-rest       like ub.sysconf.negative-rest    no-undo .
define input parameter  p-ord-prt             like ub.sysconf.ord-prt          no-undo .
define input parameter  p-osn-base            like ub.sysconf.osn-base         no-undo .
define input parameter  p-property            like ub.sysconf.property         no-undo .
define input parameter  p-purch-code          like ub.sysconf.purch-code       no-undo .
define input parameter  p-ret-credit-pay      like ub.sysconf.ret-credit-pay   no-undo .
define input parameter  p-sale-type           like ub.sysconf.sale-type        no-undo .
define input parameter  p-sale-code           like ub.sysconf.sale-code        no-undo .
define input parameter  p-snr-accnt           like ub.sysconf.snr-accnt        no-undo .
define input parameter  p-SOEI                like ub.sysconf.SOEI             no-undo .
define input parameter  p-transport-cli-type  like ub.sysconf.transport-cli-type no-undo .
define input parameter  p-transport-cli-code  like ub.sysconf.transport-cli-code no-undo .
define input parameter  p-transport-host      like ub.sysconf.transport-host   no-undo .
define input parameter  p-transport-contract  like ub.sysconf.transport-contract no-undo .
define input parameter  p-transport-uslov     like ub.sysconf.transport-uslov  no-undo .
define input parameter  p-transport-value     like ub.sysconf.transport-value  no-undo .
define input parameter  p-main-obj-type       like ub.firm.main-obj-type       no-undo .
define input parameter  p-main-obj-code       like ub.firm.main-obj-code       no-undo .
define input parameter  p-als-gds             as   logical                     no-undo .
define input parameter  p-egrip-date          as date                          no-undo.
define input parameter  p-egrip-num           as character                     no-undo.
define input parameter  p-gen-s-f-office      like ub.sysconf.gen-s-f-office   no-undo .


define variable vss-revision    as character no-undo init "$Revision: 7d2fe421d6dd, 1113, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:53 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sysconf1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/sysconf1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений СВОЕЙ ФИРМЫ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/clntattr.i }

define variable v-db-num like ub.db.db-num no-undo .
define variable conf-par     as character no-undo .
define variable par-type     as character no-undo .
define variable v-is-hold    as logical   no-undo .
define variable v-is-fin     as logical   no-undo .
define variable v-is-credit  as logical no-undo .
define variable vartpsi      as character no-undo .
define variable vartpsi-type as character no-undo .
define variable vardeleted   as logical   no-undo.
define variable glog         as logical no-undo .

define buffer buf_sysconf for ub.sysconf.
define buffer buf_clients for ub.clients.
define buffer buf_pay-type for ub.pay-type .
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_currency for ub.currency.
define buffer posr_sysconf for ub.sysconf.
define buffer main_sysconf for ub.sysconf.
define buffer main_clients for ub.clients.
define buffer main_firm  for ub.firm.


if p-mode <> {&add-def}
AND p-mode <> {&update} then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.
if p-mode = {&update}
and p-is-deploy = yes then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-is-deploy" p-is-deploy
  view-as alert-box error .
  return error '':u.
end.

{ gbl/curdbnum.i v-db-num }

if v-db-num <> 0
then do:
  run err-mess in this-procedure ( input substitute("Нельзя изменять запись СВОЕЙ ФИРМЫ в УБД: Номер текущей БД &1", v-db-num ) ).
  undo, return error "":U.
end.

if not can-find (ub.currency where
                ub.currency.curr-code = p-base-code no-lock) then do:
  run err-mess in this-procedure ( input substitute("Не найдена базовая валюта: код валюты &1", p-base-code ) ).
  undo, return error "base-code":U.
end.

if p-obj-name = "":U then do:
  run err-mess in this-procedure ( input "Имя СВОЕЙ ФИРМЫ НЕ МОЖЕТ БЫТЬ ПУСТЫМ" ).
  undo, return error "obj-name":U.
end.

if p-mode = {&add-def} then do:
  if can-find (ub.sysconf where
              ub.sysconf.host = p-host-code no-lock) then do:
    run err-mess in this-procedure ( input substitute("Уже есть СВОЯ ФИРМА с кодом &1", p-host-code) ).
    undo, return error "host-code":U.
  end.
  if not p-is-deploy
  and
  can-find (first ub.clients no-lock where
                  ub.clients.obj-code = p-host-code
              and ub.clients.obj-type = {&cmp}) then do:
    run err-mess in this-procedure ( input substitute("Уже есть КОНТРАГЕНТ-организация с кодом &1", p-host-code) ).
    undo, return error "host-code":U.
  end.
end.
else do:
  if not can-find (ub.clients where
                  ub.clients.obj-code = p-host-code
              and ub.clients.obj-type = {&cmp} no-lock)
  or
  p-host-code = 0 then do:
    if p-host-code = 0 then do:
      run err-mess in this-procedure ( input "Код СВОЕЙ ФИРМЫ не может быть равен 0" ).
    end.
    else do:
      run err-mess in this-procedure ( input substitute("Не найден КОНТРАГЕНТ для СВОЕЙ ФИРМЫ с кодом &1", p-host-code) ).
    end.
    undo, return error "host-code":U.
  end.
  if not can-find (ub.firm where
                  ub.firm.firm-code = p-host-code no-lock) then do:
    run err-mess in this-procedure ( input substitute("Не найдена ФИРМА для СВОЕЙ ФИРМЫ с кодом &1", p-host-code) ).
    undo, return error "host-code":U.
  end.
end.

if not p-is-deploy then do:
  if p-credit-pay <> 0 then do:
    { gbl/conf-rd.i
    "'iscredit'"
    0
    "''"
    0
    "''"
    "''"
    "''"
    no
    conf-par
    par-type
    no-error
    }
    if not error-status:error then
    assign
    v-is-credit = (conf-par = "yes")
    .
    if v-is-credit then do:
    find first buf_cash-pay no-lock where
              buf_cash-pay.cdpay-code = p-credit-pay no-error.
    if not available buf_cash-pay then do:
      run err-mess in this-procedure  ( input substitute("Не определен тип платежа в кредит на кассе - код &1", p-credit-pay ) ).
      undo, return error "credit-pay":U.
    end.
    if buf_cash-pay.is-credit = no then do:
      run err-mess in this-procedure ( input substitute("Тип платежа в кредит на кассе - код &1 НЕ задан как платеж <В кредит>", p-credit-pay ) ).
      undo, return error "credit-pay":U.
    end.
    if not can-find (ub.pay-type where
                    ub.pay-type.obj-code = p-ret-credit-pay no-lock) then do:
      run err-mess in this-procedure ( input substitute("Не найден тип оплаты долгов кредита с кодом &1", p-ret-credit-pay ) ).
      undo, return error "ret-credit-pay":U.
    end.
  end.
  end.
end.
if not can-find (ub.clients where
                ub.clients.obj-code = p-sale-code
            and ub.clients.obj-type = p-sale-type no-lock) then do:
  run err-mess in this-procedure ( input substitute("Не найден контрагент РЕАЛИЗАЦИЯ: тип &1 код&2", p-sale-type, p-sale-code) ).
  undo, return error "sale-code":U.
end.
if p-sale-type <> {&cmp} then do:
  run err-mess in this-procedure ( input substitute("Неверный тип контрагента РЕАЛИЗАЦИЯ: тип &1 код&2", p-sale-type, p-sale-code) ).
  undo, return error "sale-type":U.
end.

/* есть ли межфирменные архивы */
{ gbl/conf-rd.i
"'holding'"
0
"''"
0
"''"
"''"
 "''"
 no
 conf-par
 par-type
 no-error
 }
if not error-status:error then
assign
v-is-hold = (conf-par = "yes")
.

if v-is-hold and p-mode = {&update} then do:
  run check-main-obj in this-procedure no-error .
  if error-status:error then do:
    undo, return error return-value.
  end.
end.

/* есть ли арм взаиморасчетов */
{ gbl/conf-rd.i
"'is-fin'"
0
"''"
0
"''"
"''"
"''"
no
conf-par
par-type
no-error }
assign
v-is-fin = (conf-par = "yes")
.
if p-avrg-price = yes then do:
  find first posr_sysconf no-lock where
            posr_sysconf.avrg-price = yes
         and (p-mode = {&add-def}
          or posr_sysconf.host-code <> p-host-code) no-error .
  if available posr_sysconf then do:
     if p-silent then do:
        run err-mess in this-procedure  ( input substitute("ПОСРЕДНИКОМ ДЛЯ ОТЧЕТОВ уже является другая фирма &1", posr_sysconf.host-code ) ).
        undo, return error "":U.
     end.
     else do:
       message
       substitute("ПОСРЕДНИКОМ ДЛЯ ОТЧЕТОВ УЖЕ является другая фирма &1&2" +
                  "Вы уверены, что хотите сделать ПОСРЕДНИКОМ ДЛЯ ОТЧЕТОВ данную фирму &3?"
                  , posr_sysconf.host-code
                  , {&new-line}
                  , p-host-code
                  )
       view-as alert-box question update glog.
       if not glog then do:
          undo, return error 'avrg-price'.
       end.
       else do:
         find current posr_sysconf exclusive-lock.
       end.
     end.
  end.
end.

_main:
do for
main_sysconf,
main_clients,
main_firm
on error undo, return error return-value
on stop undo, return error return-value
:
  if p-mode = {&add-def} then do:
    run gbl/conf-rd.p ( input "host-num"
                       ,input ""
                       ,input ""
                       ,input 0
                       ,input ""
                       ,input ""
                       ,input ""
                       ,input yes
                       ,output conf-par
                       ,output par-type) no-error.
    if error-status:error then undo, return error.
    if par-type <> "i" then do:
      run err-mess in this-procedure ( input substitute("Неправильный тип параметра host-num &1 (должно быть integer)", par-type)).
      undo, return error "":U.
    end.
    if integer (conf-par) <> 0 then do:
      /* ограничение числа фирм включено */
      for each buf_sysconf no-lock:
        accumulate buf_sysconf.host-code (count).
      end.
      if (accum count buf_sysconf.host-code) >= integer (conf-par) then do:
        run err-mess in this-procedure ( input substitute("Создание новой фирмы запрещено. Превышено допустимое число фирм", conf-par)).
        undo, return error "":U.
      end.
    end.
    if p-is-deploy then do:
      /* в строке 147 наличие записи в clients проверяется только для NOT p-is-deploy;
         чтобы была возможность в импорте из 1с входить сюда с заранее созданным клиентом - приводим
         логику этого блока в соответствие со строкой 147 */
      FIND FIRST main_clients where
                main_clients.obj-type = {&cmp}
            AND main_clients.obj-code = p-host-code No-ERROR.
      if not available main_clients then do:
        create main_clients.
      end.
      find first main_firm where
                main_firm.firm-code = p-host-code no-error .
      if not available main_firm then do:
        run err-mess in this-procedure ( input substitute("Не найдена запись ФИРМА для записи СВОЯ ФИРМА с кодом &1", p-host-code)).
        undo, return error "":U.
      end.
    end.
    create main_sysconf.
    if not p-is-deploy then do:
      create main_clients.
      create main_firm.
    end.
    assign
    main_sysconf.firm-db-num = 0
    main_sysconf.ord-prt = yes
    main_sysconf.host-code = p-host-code
    main_sysconf.base-code = p-base-code
    p-rec = recid(main_sysconf)
    .
    assign
      main_clients.obj-code = p-host-code
      main_clients.obj-type = {&cmp}
      main_clients.obj-name = p-obj-name
      main_clients.stts     = 0
      main_clients.db-num   = ?
      main_clients.grp-code = p-grp-code
      main_firm.firm-code   = p-host-code
    .
  end.
  else do:
    find first main_sysconf where
               recid(main_sysconf) = p-rec no-error .
    if not available main_sysconf then do:
      run err-mess in this-procedure ( input substitute("Не найдена запись СВОЯ ФИРМА - p-rec &1", p-rec)).
      undo, return error "":U.
    end.
    FIND FIRST main_clients where
              main_clients.obj-type = {&cmp}
          AND main_clients.obj-code = p-host-code No-ERROR.
    if not available main_clients then do:
      run err-mess in this-procedure ( input substitute("Не найдена запись КЛИЕНТ для записи СВОЯ ФИРМА с кодом &1", p-host-code)).
      undo, return error "":U.
    end.
    find first main_firm where
              main_firm.firm-code = p-host-code no-error .
    if not available main_firm then do:
      run err-mess in this-procedure ( input substitute("Не найдена запись ФИРМА для записи СВОЯ ФИРМА с кодом &1", p-host-code)).
      undo, return error '':u.
    end.
    if main_sysconf.host-code <> p-host-code
    or main_sysconf.base-code <> p-base-code
    then do:
      run err-mess in this-procedure ( input substitute("Для уже имеющейся СВОЕЙ ФИРМЫ &1 нельзя изменить код и валюту", p-host-code)).
      undo, return error '':u.
    end.
  end.
  if available posr_sysconf
  and p-avrg-price then do:
    posr_sysconf.avrg-price = no.
  end.
  assign
  main_clients.obj-name         =  p-obj-name
  main_sysconf.artic-disable    =  p-artic-disable
  main_sysconf.avrg-price       =  p-avrg-price
  main_sysconf.gen-s-f-office   =  p-gen-s-f-office
  main_sysconf.base-code        =  p-base-code
  main_sysconf.branch           =  p-branch
  main_sysconf.cash-pay         =  p-cash-pay
  main_sysconf.cashier          =  p-cashier
  main_sysconf.cons-vat-pc      =  p-cons-vat-pc
  main_sysconf.credit-pay       =  p-credit-pay
  main_sysconf.head-position    =  p-head-position
  main_sysconf.KOPF             =  p-KOPF
  main_sysconf.negative-rest    =  p-negative-rest
  main_sysconf.osn-base         =  p-osn-base
  main_sysconf.property         =  p-property
  main_sysconf.purch-code       =  p-purch-code
  main_sysconf.ret-credit-pay   =  p-ret-credit-pay
  main_sysconf.sale-type        =  p-sale-type
  main_sysconf.sale-code        =  p-sale-code
  main_sysconf.snr-accnt        =  p-snr-accnt
  main_sysconf.SOEI             =  p-SOEI
  main_sysconf.transport-cli-type =  p-transport-cli-type
  main_sysconf.transport-cli-code =  p-transport-cli-code
  main_sysconf.transport-host   =  p-transport-host
  main_sysconf.transport-contract =  p-transport-contract
  main_sysconf.transport-uslov  =  p-transport-uslov
  main_sysconf.transport-value  =  p-transport-value
  main_firm.main-obj-type       =  p-main-obj-type
  main_firm.main-obj-code       =  p-main-obj-code
  p-rec = recid(main_sysconf)
  .
  release main_sysconf no-error.
  if error-status:error then do:
     run err-mess in this-procedure ( input substitute("Ошибка при сохранении записи СВОЯ ФИРМА &1: &2", p-host-code, ERROR-STATUS:GET-message(1))).
    undo, return error "":U.
  end.
  release main_clients no-error.
  if error-status:error then do:
    run err-mess in this-procedure ( input substitute("Ошибка при сохранении записи КЛИЕНТ для СВОЕЙ ФИРМЫ &1: &2", p-host-code, ERROR-STATUS:GET-message(1))).
    undo, return error "":U.
  end.
  release main_firm no-error.
  if error-status:error then do:
      run err-mess in this-procedure ( input substitute("Ошибка при сохранении записи ФИРМА для СВОЕЙ ФИРМЫ &1: &2", p-host-code, ERROR-STATUS:GET-message(1))).
      undo, return error "":U.
    end.
    { gbl/conf-rd.i
      "'tpsi'"
      0
      "''"
      0
      "''"
      "''"
      "''"
      no
      vartpsi
      vartpsi-type
      no-error
    }
    if ( not error-status :error ) and
      vartpsi = "yes"             and
      p-als-gds = yes             then do:
      run clntattr-write in this-procedure (
                                            input {&cmp}
                                            ,input p-host-code
                                            ,input {&attr-als-gds}
                                            ,input "yes":u).
  end.
  else do:
    run clntattr-delete in this-procedure (
                                          input  {&cmp}
                                          ,input  p-host-code
                                          ,input  {&attr-als-gds}
                                          ,output vardeleted
     ).
  end.
  if p-egrip-date = ?
  then do:
    run clntattr-delete in this-procedure (
                                            input  {&cmp}
                                            ,input  p-host-code
                                            ,input  {&attr-egrip-date}
                                            ,output vardeleted
     ).
  end.
  else do:
    run clntattr-write in this-procedure (
                                          input {&cmp}
                                          ,input p-host-code
                                          ,input {&attr-egrip-date}
                                          ,input string( p-egrip-date ) ).
  end.
  if p-egrip-num = "":U
  or p-egrip-num = ?
  then do:
    run clntattr-delete in this-procedure (
                                            input  {&cmp}
                                            ,input  p-host-code
                                            ,input  {&attr-egrip-num}
                                            ,output vardeleted
     ).
  end.
  else do:
    run clntattr-write in this-procedure (
                                            input {&cmp}
                                            ,input p-host-code
                                            ,input {&attr-egrip-num}
                                            ,input p-egrip-num ).
  end.

  find first main_sysconf where
            recid(main_sysconf) = p-rec .
end. /*doe*/

PROCEDURE check-main-obj :
define buffer buf_shop  for ub.shop.
define buffer buf_store for ub.store.
if p-main-obj-code = 0
and p-main-obj-type = "":U then return.
find first buf_clients no-lock where
           buf_clients.obj-type = p-main-obj-type
       and buf_clients.obj-code = p-main-obj-code no-error .
if not available buf_clients then do:
  run err-mess in this-procedure ( input substitute("Не найден контрагент ГЛАВНЫЙ ОБЪЕКТ ФИРМЫ для межфирменного перемещения: тип &1 код&2", p-main-obj-type, p-main-obj-code) ).
  undo, return error "main-obj-code":U.
end.
if buf_clients.obj-type <> {&shop}
AND buf_clients.obj-type <> {&stock} then do:
  run err-mess in this-procedure ( input substitute("ГЛАВНЫЙ ОБЪЕКТ ФИРМЫ для межфирменного перемещения: тип &1 код &2, а может быть только типа &3 или &4", p-main-obj-type, p-main-obj-code, {&shop}, {&stock}) ).
  undo, return error "main-obj-type":U.
end.
if p-main-obj-type = {&shop} then do:
  find first buf_shop where
            buf_shop.obj-code = p-main-obj-code no-lock.
  if buf_shop.host-code <> p-host-code then do:
    run err-mess in this-procedure ( input substitute("Магазин &1, выбранный как ГЛАВНЫЙ ОБЪЕКТ межфирменного перемещения, не принадлежит фирме &2", p-main-obj-code, p-host-code ) ).
    return error.
  end.
end.
if buf_clients.obj-type = {&stock} then do:
  find first buf_store where
            buf_store.obj-code = p-main-obj-code no-lock.
  if buf_store.host-code <> p-host-code then do:
    run err-mess in this-procedure ( input substitute("Склад &1, выбранный как ГЛАВНЫЙ ОБЪЕКТ межфирменного перемещения, не принадлежит фирме &2", p-main-obj-code, p-host-code ) ).
    return error "main-obj-code":U.
  end.
end.
END PROCEDURE.


PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  message
  p-mess
  view-as alert-box error .
END PROCEDURE.