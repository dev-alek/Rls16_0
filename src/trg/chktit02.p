block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка корректности шапки чека МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/19/06
Author: Bakhtadze Natalya
Creation date: 01/19/06

*/

/*
Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

/*если идет создание чека в интерефейче то надо поставить yes - для уже имеющегося чека поставить no*/
define input parameter p-exit-on-error as logical no-undo .
define input parameter p-doc-code like ub.chk-doc.doc-code no-undo .
/*0 товарны 1 -МЦ*/
define input parameter p-doc-type as integer no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.chk-doc.obj-type no-undo .
define input parameter p-obj-code like ub.chk-doc.obj-code no-undo .
define input parameter p-chk-date like ub.chk-doc.chk-date no-undo .
define input parameter p-chk-time like ub.chk-doc.chk-time no-undo .
define input parameter p-shift-date like ub.chk-doc.shift-date no-undo .
define input parameter p-shift-num like ub.chk-doc.shift-num no-undo .
define input parameter p-shift-name like ub.chk-doc.shift-name no-undo .
define input parameter p-pay-desk like ub.chk-doc.pay-desk no-undo .
define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
define input-output    parameter p-cash-rate like ub.chk-doc.cash-rate no-undo .
define input parameter p-cashier like ub.chk-doc.cashier no-undo .
define input parameter p-sales-man like ub.chk-doc.sales-man no-undo .
define input parameter p-d-card like ub.chk-doc.d-card no-undo .
define input parameter p-z-number like ub.chk-doc.z-number no-undo .
define input parameter p-PS like ub.chk-doc.PS no-undo .
define input parameter p-lines-exist as logical no-undo .
/*если мы находимя в par-mode = "spool":U тогда надо правильно задать и эти параметры */
/*если мы в ручном создании чека или его редактировании то эти параметры будут инициированы процедурой c h k t i t 0 9.p*/
/*r-b- rubl или base */
define input parameter r-b as character no-undo .
/*использовать смены на кассе для данного объекта*/
define input parameter cas-shft as logical no-undo .
/*использовать смены на объекте*/
define input parameter l-shift-on as logical no-undo .
/*смещение смен*/
define input parameter t-shft as integer no-undo .
/*использовать вирт смены на кассе для данного объекта*/
define input parameter v-shft as integer no-undo .
/*курсы из спула*/
define input parameter cas-curs as logical no-undo .
/*настройка - откуда брать номер магазина при чтении чеков из спула - из спула- yes или
по умолчанию номер магазина в котором принимается почта*/
define input parameter hnum as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка корректности шапки чека МЦ".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/gbclcode.i }
{ gbl/cur-time.i } /* 21/I-2019 - cur-time.i убрано из gbclcode.i */

DEFINE VARIABLE var-chk-type as character no-undo .
DEFINE VARIABLE var-entry as character no-undo .
DEFINE VARIABLE vardb-num like ub.clients.db-num no-undo .
DEFINE VARIABLE v-shift-date as date no-undo.
DEFINE VARIABLE v-shift-num as integer no-undo.
DEFINE VARIABLE v-shift-name as character no-undo.
DEFINE VARIABLE varbase-code like ub.sysconf.base-code no-undo .

define buffer cashier for ub.person.
define buffer sales-man for ub.person.
define buffer buf_cash-desk for ub.cash-desk.
define buffer buf_clients for ub.clients.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_dis-card-type for ub.dis-card-type.


&scop do-exit if p-exit-on-error then do: return error var-entry. end.

do
on error undo, return error return-value
:

  FIND FIRST ub.sysconf No-LOCK WHERE
            ub.sysconf.host-code = p-host-code No-ERROR.
  IF NOT AVAIL ub.sysconf THEN DO:
    undo, return error substitute("Не найдена фирма &1!", p-host-code).
  END.
  varbase-code = ub.sysconf.base-code.

  FIND FIRST buf_clients No-LOCK WHERE
            buf_clients.obj-type = p-obj-type AND
            buf_clients.obj-code = p-obj-code NO-ERROR.
  IF NOT AVAIL buf_clients THEN DO:
    undo, return error substitute("Не найден объект &1&2!", p-obj-type, p-obj-code).
  END.
  vardb-num = buf_clients.db-num.


  if cas-shft or l-shift-on then do:
      if ABS(p-SHIFT-date - p-CHK-date) > 1 then do:
         undo, return error substitute("Чек &1 - ошибочный.&2" +
                                       "Несоответствуют друг другу дата чека &3 и дата начала смены &4!"
                                      , p-doc-code
                                      , {&new-line}
                                      , p-chk-date
                                      ,p-shift-date
                                      ).
      end.
      if p-shift-num = 0 then do:
        undo, return error substitute("Чек &1 - ошибочный.&2" +
                                      "Номер смены не может равняться 0!"
                                      , p-doc-code
                                      , {&new-line}).

      end.
      if l-shift-on then do:
        run curshift in this-procedure no-error.
        if error-status:error then.
        else do:
          if p-shift-date <> v-shift-date OR
            p-shift-num <> v-shift-num then do:
          undo, return error substitute("Чек &1 - ошибочный.&2" +
                                        "Несоответствуют друг другу дата/номер смены чека &3/&4&2" +
                                         "и дата/номер смены на объекте &5/&6!"
                                        ,p-doc-code
                                        ,{&new-line}
                                        ,p-shift-date
                                        ,p-shift-name
                                        ,v-shift-date
                                        ,v-shift-num
                                        ).
          end.
        end.
      if v-shft >= 0 then do:
        FOR EACH ub.shift-cash No-LOCK WHERE
                ub.shift-cash.obj-type = p-obj-type AND
                ub.shift-cash.obj-code = p-obj-code AND
                ub.shift-cash.cash-num = p-pay-desk AND
                (ub.shift-cash.shift-date = p-shift-date OR
                ub.shift-cash.shift-date = p-shift-date - 1) AND
                ub.shift-cash.shift-num = p-shift-num:
          if ub.shift-cash.sale-date = p-shift-date then LEAVE.
        END.
        if not avail ub.shift-cash then do:
         undo, return error substitute("Чек &1 - ошибочный.&2" +
                                       "На кассе &3 &4&5&2" +
                                       "не  было смены c пор. N &2 за &7"
                                       ,p-doc-code
                                       ,{&new-line}
                                       ,p-pay-desk
                                       ,p-obj-type
                                       ,p-obj-code
                                       ,p-shift-num
                                       ,string(p-shift-date, "99/99/9999")).

        END.
      end.
  end.
  ELSE DO:
    if (p-chk-date - p-shift-date) > 1
    then do:
      undo, return error substitute("Чек &1 - ошибочный.&2" +
                                    "Не соответствуют друг другу дата чека &3 и дата начала смены &4!"
                                  , p-doc-code
                                  , {&new-line}
                                  , p-chk-date
                                  ,p-shift-date
                                  ).
    end.
  END.

  if not cas-curs then do:
    if varbase-code = 0 or r-b = "rubl":U then
    assign
    p-cash-rate = 1
    .
    else do:
      FIND FIRST ub.curr-shop No-LOCK WHERE
                  ub.curr-shop.obj-type = p-obj-type AND
                  ub.curr-shop.obj-code = p-obj-code AND
                  ub.curr-shop.curr-code = varbase-code AND
              ( ( ub.curr-shop.exch-date = p-chk-date AND
                  ub.curr-shop.exch-time <= p-chk-time ) OR
                ub.curr-shop.exch-date < p-chk-date ) NO-ERROR .
      if  not available ub.curr-shop then do:
        undo, return error
        substitute("Чек &1 - ошибочный.&2" +
                   "Нет магазинного курса базовой валюты на дату и время чека-&2&3 &4!"
                  , p-doc-code
                  , {&new-line}
                  ,string(p-chk-date, "99/99/9999")
                  ,string(p-chk-time, "hh:mm")).
      end.
      p-cash-rate = ub.curr-shop.exch-rate / ub.curr-shop.exch-scale.
    end.
  end.
  else do:
    if p-cash-rate = 0 then do:
      undo, return error
      substitute("Чек &1 - ошибочный.&2" +
                 "Неверный курс базовой валюты базовой валюты на дату и время чека-&2&3 &4 = &5!"
                , p-doc-code
                , {&new-line}
                ,string(p-chk-date, "99/99/9999")
                ,string(p-chk-time, "hh:mm")
                ,p-cash-rate
                ).
    end.
  end.
  if gbclcode-is-this-db-role ( input {&role-cashier}, input vardb-num, input p-cashier, input p-chk-date) = 0 then do:
     undo, return error substitute(
                              "!!!Чек МЦ &1 - ошибочный. &2 Нет сведений о кассире &3 на &4"
                              , p-doc-code
                              , {&new-line}
                              , p-cashier
                              , string(p-chk-date, "99/99/9999")
                            ).
  end.
  if p-doc-type = 0 then do:
    if gbclcode-is-this-db-role( input {&role-seller}, input vardb-num, input p-sales-man, input p-chk-date) = 0 then do:
     undo, return error substitute(
                              "!!!Чек МЦ &1 - ошибочный. &2 Нет сведений о продавце &3 на &4"
                              , p-doc-code
                              , {&new-line}
                              , p-sales-man
                              , string(p-chk-date, "99/99/9999")
                            ).
    end.
  end.
  find first ub.sys-ctrl No-LOCK.
  FIND FIRST buf_cash-desk where
            buf_cash-desk.db-num = ub.sys-ctrl.db-num AND
            buf_cash-desk.obj-code = p-obj-code AND
            buf_cash-desk.cash-num = p-pay-desk no-error.
  if not available buf_cash-desk then dO:
    undo, return error substitute("!!!Чек &1 - ошибочный. &2 Нет сведений о кассе &3 с типом &4"
                              , p-doc-code
                              , {&new-line}
                              , p-pay-desk
                              , p-pos-type
                            ).
  end.

  end. /*if p-doc-type = 0 then do:*/
 return var-chk-type.

end. /*doe*/

procedure curshift :
   do
  on error undo, return error return-value
  :
    { gbl/curshift.i p-obj-type p-obj-code v-shift-date v-shift-num v-shift-name no-error }
    if error-status:error then do:
      undo, return error substitute("&1 &2 &3&4Не удалось определить дату и время текущей смены&4&5&4&6"
                                   ,vss-workfile
                                   ,vss-revision
                                   ,vss-description
                                   , error-status:get-message(1)
                                   , return-value ).
    end.
  end.
end procedure. /* curshift */