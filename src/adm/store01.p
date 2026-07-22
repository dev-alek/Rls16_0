block-level on error undo, throw.
/*

$Revision: 9b43ebeef021, 979, rls $
$Author: AAShepel $
$Date: Mon Jun 19 10:51:53 2017 +0300 $
$Workfile: store01.p $
$Archive: adm/store01.p $

Сохранение изменений в карточке склада


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

define input-output parameter p-rec as recid no-undo.
define input parameter        p-mode                as character no-undo .
define input parameter        p-obj-code            like ub.store.obj-code                 no-undo .
define input parameter        p-db-num              like ub.clients.db-num                no-undo .
define input parameter        p-host-code           like ub.store.host-code                no-undo .
define input parameter        p-grp-code            like ub.clients.grp-code              no-undo .
define input parameter        p-obj-name            like ub.clients.obj-name              no-undo .
define input parameter        p-PS                  like ub.clients.PS                    no-undo .
define input parameter        p-active              like ub.store.active                  no-undo .
define input parameter        p-addres1             like ub.store.addres1                  no-undo .
define input parameter        p-addres2             like ub.store.addres2                  no-undo .
/*  define input parameter        p-chk-pay             like ub.store.chk-pay                  no-undo .*/
define input parameter        p-doc-prt             like ub.store.doc-prt                  no-undo .
define input parameter        p-down-pay            like ub.store.down-pay                 no-undo .
/*define input parameter        p-p.dst-price         like ub.store.p.dst-price              no-undo .*/
define input parameter        p-fax                 like ub.store.fax                      no-undo .
define input parameter        p-holidays            like ub.store.holidays                 no-undo .
define input parameter        p-in-ov               like ub.store.in-ov                    no-undo .
define input parameter        p-in-pay              like ub.store.in-pay                   no-undo .
define input parameter        p-in-perm             like ub.store.in-perm                  no-undo .
define input parameter        p-inout-price         like ub.store.inout-price              no-undo .
define input parameter        p-inv-pay             like ub.store.inv-pay                  no-undo .
define input parameter        p-load-time           like ub.store.load-time                no-undo .
define input parameter        p-no-eq               like ub.store.no-eq                    no-undo .
define input parameter        p-out-line-discnt     like ub.store.out-line-discnt          no-undo .
define input parameter        p-out-pay             like ub.store.out-pay                  no-undo .
define input parameter        p-out-rate            like ub.store.out-rate                 no-undo .
define input parameter        p-phone               like ub.store.phone                    no-undo .
define input parameter        p-price-calc          like ub.store.price-calc               no-undo .
define input parameter        p-ret-pay             like ub.store.ret-pay                  no-undo .
define input parameter        p-ret-sup-pay         like ub.store.ret-sup-pay              no-undo .
define input parameter        p-fbr-pay             like ub.store.fbr-pay                  no-undo .
define input parameter        p-rsrv-time           like ub.store.rsrv-time                no-undo .
define input parameter        p-shift-on            like ub.store.shift-on                 no-undo .
define input parameter        p-store-boss          like ub.store.store-boss               no-undo .
define input parameter        p-store-man           like ub.store.store-man                no-undo .
define input parameter        p-unit-cli-perm       like ub.store.unit-cli-perm            no-undo .
define input parameter        p-work-hours          like ub.store.work-hours               no-undo .
define input parameter        p-purch-code          as   integer                           no-undo .
define input parameter        p-envd                as   logical                           no-undo .
define input parameter        p-pharm               as   logical                           no-undo .
define input parameter        p-KPP                 as   character                         no-undo .

define variable vss-revision    as character no-undo init "$Revision: 9b43ebeef021, 979, rls $":U .
define variable vss-author      as character no-undo init "$Author: AAShepel $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jun 19 10:51:53 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: store01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/store01.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке склада".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/clntattr.i }

define variable v-db-num like ub.db.db-num no-undo .
define variable v-curr-r-b as character no-undo .
define variable par-type as character no-undo .
define variable v-envd      as character no-undo.
define variable v-pharm      as character no-undo.
define variable v-delete    as logical no-undo.
define variable v-kpp       as character no-undo.


define buffer buf_sysconf for ub.sysconf.
define buffer buf_clients for ub.clients.
define buffer buf_pay-type for ub.pay-type .
define buffer buf_dis-card-type for ub.dis-card-type.

if p-mode <> {&add-def}
AND p-mode <> {&update} then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.

{ gbl/curdbnum.i v-db-num }

if v-db-num <> 0
then do:
  run err-mess in this-procedure (substitute("Нельзя изменять запись СКЛАДА в УБД: Номер текущей БД &1 ", v-db-num ) ).
  undo, return error "":U.
end.

run chk-code in this-procedure (p-obj-code, p-mode) no-error .
if error-status:error then do:
  undo, return error "obj-code":U.
end.

if p-obj-name = "":U then do:
  run err-mess in this-procedure (substitute("Введите название склада &1 ", p-obj-code ) ).
  undo, return error "obj-name":U.
end.

if not can-find( ub.db where
                   ub.db.db-num = p-db-num )
then do:
  run err-mess in this-procedure (substitute("Неверный номер БД. Нет БД с номером &1 ", p-db-num ) ).
  undo, return error "db-num":U.
end.

find first buf_sysconf no-lock where
            buf_sysconf.host-code = p-host-code no-error .
if not available buf_sysconf then do:
  run err-mess in this-procedure (substitute("Не найдена фирма с кодом &1 для склада &2", p-host-code, p-obj-code ) ).
  undo, return error "":U.
end.

if buf_sysconf.firm-db-num <> 0
AND p-db-num <> buf_sysconf.firm-db-num
then do:
  run err-mess in this-procedure (substitute("Главная БД фирмы &1 не совпадает с БД, к которой относится склад &2: главная БД фирмы - &3, а склад относится к БД &4", p-host-code, p-obj-code, buf_sysconf.firm-db-num, p-db-num ) ).
  undo, return error "db-num":U.
end.

/*
if p-chk-pay <> 0 then do:
  FIND first buf_pay-type no-lock where
            buf_pay-type.obj-code = p-chk-pay NO-error .
  if not available buf_pay-type then do:
    run err-mess in tp (substitute("Неверный код оплаты реализации (продажи) для склада &1: &2", p-obj-code, p-chk-pay) ).
    undo, return error "chk-pay":U.
  end.
end.

*/

if p-down-pay <> 0 then do:
  FIND first buf_pay-type no-lock where
            buf_pay-type.obj-code = p-down-pay NO-error .
  if not available buf_pay-type then do:
    run err-mess in this-procedure (substitute("Неверный код оплаты списания для склада &1: &2", p-obj-code, p-down-pay) ).
    undo, return error "down-pay":U.
  end.
end.

if p-in-pay <> 0 then do:
  FIND first buf_pay-type no-lock where
            buf_pay-type.obj-code = p-in-pay NO-error .
  if not available buf_pay-type then do:
    run err-mess in this-procedure (substitute("Неверный код оплаты прихода для склада &1: &2", p-obj-code, p-in-pay) ).
    undo, return error "in-pay":U.
  end.
end.

if p-inv-pay <> 0 then do:
  FIND first buf_pay-type no-lock where
            buf_pay-type.obj-code  = p-inv-pay NO-error .
  if not available buf_pay-type then do:
    run err-mess in this-procedure (substitute("Неверный код оплаты инвентаризации для склада &1: &2", p-obj-code, p-inv-pay) ).
    undo, return error "inv-pay":U.
  end.
end.

if p-out-pay <> 0 then do:
  FIND first buf_pay-type no-lock where
            buf_pay-type.obj-code = p-out-pay NO-error .
  if not available buf_pay-type then do:
    run err-mess in this-procedure (substitute("Неверный код оплаты расхода для склада &1: &2", p-obj-code, p-out-pay) ).
    undo, return error "out-pay":U.
  end.
end.

if p-ret-pay <> 0 then do:
  FIND first buf_pay-type no-lock where
            buf_pay-type.obj-code = p-ret-pay NO-error .
  if not available buf_pay-type then do:
    run err-mess in this-procedure (substitute("Неверный код оплаты возврата от покупателя для склада &1: &2", p-obj-code, p-ret-pay) ).
    undo, return error "ret-pay":U.
  end.
end.

if p-ret-sup-pay <> 0 then do:
  FIND first buf_pay-type no-lock where
            buf_pay-type.obj-code = p-ret-sup-pay NO-error .
  if not available buf_pay-type then do:
    run err-mess in this-procedure (substitute("Неверный код оплаты возврата поставщику для склада &1: &2", p-obj-code, p-ret-sup-pay) ).
    undo, return error "ret-sup-pay":U.
  end.
end.

if p-fbr-pay <> 0 then do:
  FIND first buf_pay-type no-lock where
            buf_pay-type.obj-code = p-fbr-pay NO-error .
  if not available buf_pay-type then do:
    run err-mess in this-procedure (substitute("Неверный код оплаты производства для склада &1: &2", p-obj-code, p-fbr-pay) ).
    undo, return error "fbr-pay":U.
  end.
end.


_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = {&add-def} then do:
    create ub.store.
    create ub.clients.
    assign
    ub.clients.obj-code = p-obj-code
    ub.clients.obj-type = {&stock}
    ub.clients.db-num   = p-db-num
    ub.clients.grp-code = p-grp-code
    ub.clients.host-code = p-host-code
    ub.store.obj-code = p-obj-code
    ub.store.host-code   = p-host-code
    p-rec = recid(ub.clients)
    .
  end.
  else do:
    FIND FIRST ub.clients where
              recid(ub.clients) = p-rec No-ERROR.
    if not available ub.clients then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись КЛИЕНТ для записи СКЛАДА - p-rec" p-rec
      view-as alert-box error .
      undo, return error '':u.
    end.
    find first ub.store where
              ub.store.obj-code = p-obj-code no-error .
    if not available ub.store then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись СКЛАД с кодом" p-obj-code
      view-as alert-box error .
      undo, return error '':u.
    end.
    if ub.store.obj-code <> p-obj-code
    or ub.store.host-code <> p-host-code
    or ub.clients.db-num    <> p-db-num
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющегося СКЛАДА нельзя изменить номер склада, номер БД и код фирмы" skip
      view-as alert-box ERROR.
      undo, return error '':U.
    end.
  end.
  assign
  ub.clients.obj-name         =  p-obj-name
  ub.clients.PS               =  p-PS
  ub.store.active              =  p-active
  ub.store.addres1             =  p-addres1
  ub.store.addres2             =  p-addres2
  /*ub.store.chk-pay             =  p-chk-pay*/
  ub.store.doc-prt             =  p-doc-prt
  ub.store.down-pay            =  p-down-pay
  /*ub.store.dst-price       =  p-p.dst-price*/
  ub.store.fax                 =  p-fax
  ub.store.holidays            =  p-holidays
  ub.store.in-ov               =  p-in-ov
  ub.store.in-pay              =  p-in-pay
  ub.store.in-perm             =  p-in-perm
  ub.store.inout-price         =  p-inout-price
  ub.store.inv-pay             =  p-inv-pay
  ub.store.load-time           =  p-load-time
  ub.store.no-eq               =  p-no-eq
  ub.store.out-line-discnt     =  p-out-line-discnt
  ub.store.out-pay             =  p-out-pay
  ub.store.out-rate            =  p-out-rate
  ub.store.phone               =  p-phone
  ub.store.price-calc          =  p-price-calc
  ub.store.ret-pay             =  p-ret-pay
  ub.store.ret-sup-pay         =  p-ret-sup-pay
  ub.store.fbr-pay             =  p-fbr-pay
  ub.store.rsrv-time           =  p-rsrv-time
  ub.store.shift-on            =  p-shift-on
  ub.store.store-boss          =  p-store-boss
  ub.store.store-man           =  p-store-man
  ub.store.unit-cli-perm       =  p-unit-cli-perm
  ub.store.work-hours          =  p-work-hours
  ub.store.purch-code          =  p-purch-code
  p-rec = recid(ub.clients )
  .
 release ub.clients no-error.
 if error-status:error then do:
    run err-mess in this-procedure (substitute("Ошибка при сохранении записи КЛИЕНТ для склада &1:&2&3&2&4"
                          , p-obj-code
                          , {&new-line}
                          , ERROR-STATUS:GET-message(1)
                          , return-value
                          )).
    undo, return error "":U.
 end.
 p-obj-code = ub.store.obj-code.
 release ub.store no-error.
 if error-status:error then do:
     run err-mess in this-procedure ( substitute("Ошибка при сохранении записи СКЛАД &1:&2&3&2&4"
                             , p-obj-code
                             , {&new-line}
                             , ERROR-STATUS:GET-message(1)
                             , return-value
                             )).
    undo, return error "":U.
 end.
  run clntattr-value in this-procedure
    (input {&stock},
    input  p-obj-code,
    input  {&attr-pharm},
    output v-pharm,
    output par-type).
  if v-pharm = "yes":u then do:
     if p-pharm = no then do:
       run clntattr-delete in this-procedure
       (input {&stock},
        input  p-obj-code,
        input  {&attr-pharm},
        output v-delete).
     end.
  end.
  else do:
    if p-pharm = yes then do:
      run clntattr-write in this-procedure
       (input  {&stock},
        input  p-obj-code,
        input  {&attr-pharm},
        input  "yes":u).
    end.
  end.

    /* Для КПП */

 run clntattr-value in this-procedure
      (input {&stock},
      input  p-obj-code,
      input  {&attr-kpp},
      output v-kpp,
      output par-type).

  if v-kpp <> "":u and v-kpp <> ? then do:
    if p-kpp = "" or p-kpp = ? then do:
      run clntattr-delete in this-procedure
       (input {&stock},
        input  p-obj-code,
        input  {&attr-kpp},
        output v-delete).
    end.
    else do:
      if p-kpp <> "" and p-kpp <> ? then do:
       run clntattr-write in this-procedure
       (input  {&stock},
        input  p-obj-code,
        input  {&attr-kpp},
        input  p-kpp).
    end.
    end.
  end.
    else do:
    if p-kpp <> "" and p-kpp <> ? then do:
      run clntattr-write in this-procedure
       (input  {&stock},
        input  p-obj-code,
        input  {&attr-kpp},
        input  p-kpp).
    end.
  end.

  run clntattr-value in this-procedure
    (input {&stock},
    input  p-obj-code,
    input  {&attr-envd},
    output v-envd,
    output par-type).
  if v-envd = "yes":u then do:
     if p-envd = no then do:
       run clntattr-delete in this-procedure
       (input {&stock},
        input  p-obj-code,
        input  {&attr-envd},
        output v-delete).
     end.
  end.
  else do:
    if p-envd = yes then do:
      run clntattr-write in this-procedure
       (input  {&stock},
        input  p-obj-code,
        input  {&attr-envd},
        input  "yes":u).
    end.
  end.
end. /*doe*/





PROCEDURE chk-code :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input parameter p-obj-code like ub.store.obj-code no-undo .
define input parameter p-mode     as character no-undo .
/*настройка - откуда брать номер склада при чтении чеков из спула - из спула- yes или
по умолчанию номер склада в котором принимается почта*/
define variable  conf-par as character no-undo.                  /* для чтения параметра конфигурации */
define variable  par-type as character no-undo.
define variable  dopi as integer no-undo.
if p-obj-code = 0 then do:
  run err-mess in this-procedure ("Код склада должен быть больше 0 " ).
  return error.
end.
if  p-mode = {&add-def}
and can-find( ub.store where ub.store.obj-code = p-obj-code ) then   do:
  run err-mess in this-procedure (substitute("Склад с кодом &1 уже есть, измените код", p-obj-code ) ).
  return error.
end.
return.
END PROCEDURE.

PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  message
  p-mess
  view-as alert-box error .
END PROCEDURE.