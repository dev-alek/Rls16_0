block-level on error undo, throw.
/*

$Revision: 8c1a0fd433e1, 1120, rls $
$Author: SMMolotkov $
$Date: Thu Dec 14 02:13:53 2017 +0300 $
$Workfile: shop01.p $
$Archive: adm/shop01.p $

Сохранение изменений в карточке магазина

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
define input parameter        p-obj-code            like ub.shop.obj-code                 no-undo .
define input parameter        p-db-num              like ub.clients.db-num                no-undo .
define input parameter        p-host-code           like ub.shop.host-code                no-undo .
define input parameter        p-grp-code            like ub.clients.grp-code              no-undo .
define input parameter        p-obj-name            like ub.clients.obj-name              no-undo .
define input parameter        p-PS                  like ub.clients.PS                    no-undo .
define input parameter        p-acct                like ub.shop.acct                     no-undo .
define input parameter        p-addres1             like ub.shop.addres1                  no-undo .
define input parameter        p-addres2             like ub.shop.addres2                  no-undo .
define input parameter        p-all-prt             like ub.shop.all-prt                  no-undo .
define input parameter        p-buy-goods           like ub.shop.buy-goods                no-undo .
define input parameter        p-cd-bc-alt           like ub.shop.cd-bc-alt                no-undo .
define input parameter        p-cd-bc-base          like ub.shop.cd-bc-base               no-undo .
define input parameter        p-cd-loc-alt          like ub.shop.cd-loc-alt               no-undo .
define input parameter        p-cd-loc-base         like ub.shop.cd-loc-base              no-undo .
define input parameter        p-cd-parts-all        like ub.shop.cd-parts-all             no-undo .
define input parameter        p-cd-parts-not-blank  like ub.shop.cd-parts-not-blank       no-undo .
define input parameter        p-cd-parts-ser        like ub.shop.cd-parts-ser             no-undo .
define input parameter        p-cd-pb-alt           like ub.shop.cd-pb-alt                no-undo .
define input parameter        p-cd-pb-base          like ub.shop.cd-pb-base               no-undo .
define input parameter        p-cd-sc-base          like ub.shop.cd-sc-base               no-undo .
define input parameter        p-chk-pay             like ub.shop.chk-pay                  no-undo .
define input parameter        p-day-only            like ub.shop.day-only                 no-undo .
define input parameter        p-director            like ub.shop.director                 no-undo .
define input parameter        p-discaloc            like ub.shop.discaloc                 no-undo .
define input parameter        p-doc-prt             like ub.shop.doc-prt                  no-undo .
define input parameter        p-down-pay            like ub.shop.down-pay                 no-undo .
/*define input parameter        p-p.dst-price         like ub.shop.p.dst-price              no-undo .*/
define input parameter        p-fax                 like ub.shop.fax                      no-undo .
define input parameter        p-goods-man           like ub.shop.goods-man                no-undo .
/*define input parameter        p-p.holidays          like ub.shop.p.holidays               no-undo .*/
define input parameter        p-in-ov               like ub.shop.in-ov                    no-undo .
define input parameter        p-in-pay              like ub.shop.in-pay                   no-undo .
define input parameter        p-in-perm             like ub.shop.in-perm                  no-undo .
define input parameter        p-inout-price         like ub.shop.inout-price              no-undo .
define input parameter        p-inv-pay             like ub.shop.inv-pay                  no-undo .
define input parameter        p-is-catering         like ub.shop.is-catering              no-undo .
define input parameter        p-is-kitchen          like ub.shop.is-kitchen               no-undo .
define input parameter        p-is-kitchen-store    like ub.shop.is-kitchen-store         no-undo .
define input parameter        p-kitchen-store-code  like ub.shop.kitchen-store-code       no-undo .
define input parameter        p-kitchen-store-type  like ub.shop.kitchen-store-type       no-undo .
/*define input parameter        p-load-time           like ub.shop.load-time                no-undo .*/
define input parameter        p-no-eq               like ub.shop.no-eq                    no-undo .
/*define input parameter        p-no-short-code       like ub.shop.no-short-code            no-undo .*/
define input parameter        p-out-line-discnt     like ub.shop.out-line-discnt          no-undo .
define input parameter        p-out-pay             like ub.shop.out-pay                  no-undo .
define input parameter        p-out-rate            like ub.shop.out-rate                 no-undo .
define input parameter        p-phone               like ub.shop.phone                    no-undo .
define input parameter        p-pr-cash             like ub.shop.pr-cash                  no-undo .
define input parameter        p-price-calc          like ub.shop.price-calc               no-undo .
define input parameter        p-ret-pay             like ub.shop.ret-pay                  no-undo .
define input parameter        p-ret-sup-pay         like ub.shop.ret-sup-pay              no-undo .
define input parameter        p-fbr-pay             like ub.shop.fbr-pay                  no-undo .
define input parameter        p-rsrv-time           like ub.shop.rsrv-time                no-undo .
define input parameter        p-shift-on            like ub.shop.shift-on                 no-undo .
define input parameter        p-store-boss          like ub.shop.store-boss               no-undo .
define input parameter        p-store-man           like ub.shop.store-man                no-undo .
define input parameter        p-sub-store-on        like ub.shop.sub-store-on             no-undo .
define input parameter        p-sub-store-code      like ub.shop.sub-store-code           no-undo .
define input parameter        p-sub-store-type      like ub.shop.sub-store-type           no-undo .
define input parameter        p-unit-cli-perm       like ub.shop.unit-cli-perm            no-undo .
define input parameter        p-with-serv           like ub.shop.with-serv                no-undo .
define input parameter        p-work-hours          like ub.shop.work-hours               no-undo .
define input parameter        p-purch-code          as   integer                          no-undo .
define input parameter        p-envd                as   logical                          no-undo . 
define input parameter        p-pharm               as   logical                          no-undo .
define input parameter        p-KPP                 as   character                        no-undo .

define variable vss-revision    as character no-undo init "$Revision: 8c1a0fd433e1, 1120, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:53 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: shop01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/shop01.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке магазина".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/clntattr.i }

define variable v-db-num like ub.db.db-num no-undo .
define variable v-curr-r-b as character no-undo .
define variable par-type as character no-undo .
define variable var-deleted as logical no-undo .
define variable v-envd      as character no-undo.
define variable v-kpp       as character no-undo.
define variable v-pharm     as character no-undo.
define variable v-delete    as logical no-undo.
define variable v-pay-type-list as character no-undo . /* список проверенных pay-type.obj-code */
define variable v-pay-type-str  as character no-undo . /* проверяемое pay-type.obj-code */
define buffer buf_sysconf for ub.sysconf.
define buffer buf_clients for ub.clients.
define buffer buf_pay-type for ub.pay-type .
define buffer buf_other_shop for ub.shop.
define buffer buf_cash-desk for ub.cash-desk.
define buffer buf_dis-card-type for ub.dis-card-type.

if p-mode <> {&add-def}
AND p-mode <> {&update} then do:
  undo, return error
    substitute('&5&1 &2 &3&4Неверный параметр p-mode [&6]':u,
               vss-workfile, vss-revision, vss-description, {&new-line}, {&delim-par}, p-mode).
end.

{ gbl/curdbnum.i v-db-num }
if v-db-num <> 0
then do:
  undo, return error 
    substitute("&2Нельзя изменять запись МАГАЗИНА в УБД: Номер текущей БД &1 ", v-db-num, {&delim-par}).
end.

run chk-code in this-procedure (p-obj-code, p-mode) no-error .
if error-status:error then
  undo, return error substitute("&1&3&2":U, "obj-code":U, return-value, {&delim-par}) .

if p-obj-name = "":U then
  undo, return error substitute("&1&3Введите название магазина &2", "obj-name":U, p-obj-code, {&delim-par}) .

if not can-find ( ub.db where ub.db.db-num = p-db-num ) then
  undo, return error substitute("&1&3Неверный номер БД. Нет БД с номером &2", "db-num":U, p-db-num, {&delim-par}) .

find first buf_sysconf no-lock where buf_sysconf.host-code = p-host-code no-error .
if not available buf_sysconf then
  undo, return error substitute("&3Не найдена фирма с кодом &1 для магазина &2", p-host-code, p-obj-code, {&delim-par}) .

if buf_sysconf.firm-db-num <> 0
AND p-db-num <> buf_sysconf.firm-db-num
then do:
  undo, return error substitute(
    "&1&6Главная БД фирмы &2 не совпадает с БД, к которой относится магазин &3: главная БД фирмы - &4, а магазин относится к БД &5",
    "db-num":U, p-host-code, p-obj-code, buf_sysconf.firm-db-num, p-db-num, {&delim-par}
  ) .
end.

IF p-sub-store-on = yes then do:
  find first buf_clients no-lock
    where buf_clients.obj-type = p-sub-store-type
      and buf_clients.obj-code = p-sub-store-code  no-error.
  if not available buf_clients then
    undo, return error substitute("&1&5Не найден объект &2&3, выбранный в качестве склада-подсобки для магазина &4",
      "sub-store-code":U, p-sub-store-type, p-sub-store-code, p-obj-code, {&delim-par}) . 
  if buf_clients.db-num <> p-db-num then
    undo, return error substitute("&1&5Нельзя в качестве склада-подсобки указать объект другой БД: магазин &2 принадлежит БД &3, а склад-подсобка БД &4",
      "sub-store-code":U, p-obj-code, buf_clients.db-num, p-db-num, {&delim-par}) . 
end.

IF p-is-kitchen then do:
  if p-kitchen-store-type <> {&shop} then
    undo, return error substitute(
      "&1&5В качестве СКЛАДА КУХНИ для магазина (кухни) &2 указан объект с типом &3. Допустимо указывать объект только с типом &4",
      "kitchen-store-type":U, p-obj-code, p-kitchen-store-type, {&shop}, {&delim-par}) .
  find first buf_clients no-lock
    where buf_clients.obj-type = p-kitchen-store-type
      and buf_clients.obj-code = p-kitchen-store-code
    no-error.
  if not available buf_clients then
    undo, return error substitute("&1&5Не найден объект &2&3, выбранный в качестве СКЛАДА для магазина (кухни) &4",
      "kitchen-store-code":U, p-kitchen-store-type, p-kitchen-store-code, p-obj-code, {&delim-par}) .
  if buf_clients.db-num <> p-db-num then
    undo, return error substitute("&1&5Нельзя в качестве СКЛАДА КУХНИ указать объект другой БД: магазин (кухня) &2 принадлежит БД &3, а СКЛАД - БД &4",
      "kitchen-store-code":U, p-obj-code, buf_clients.db-num, p-db-num, {&delim-par}) .
  find first buf_other_shop no-lock
       where buf_other_shop.obj-code = buf_clients.obj-code no-error .
  if not available buf_other_shop then
    undo, return error substitute("&1&4Не найден магазин &2, указанный в качестве СКЛАДА КУХНИ для магазина (кухни) &3",
      "kitchen-store-code":U, buf_clients.obj-type, p-obj-code, {&delim-par}) . 
  if buf_other_shop.host-code <> p-host-code then
    undo, return error substitute("&1&5Нельзя в качестве СКЛАДА КУХНИ указать объект другой ФИРМЫ: магазин(кухня) &2 принадлежит фирме &3, а СКЛАД - фирме &4",
      "kitchen-store-code":U, p-obj-code, p-host-code, buf_other_shop.host-code, {&delim-par}) . 
end. /* end_of p-is-kitchen */

if (p-is-kitchen or p-is-kitchen-store) and not p-is-catering then do:
    find first buf_cash-desk no-lock
         where buf_cash-desk.obj-code = p-obj-code no-error .
    if available buf_cash-desk and
                buf_cash-desk.cash-on then do:
      undo, return error substitute(
        "&1&6Магазин не можeт иметь признак КУХНЯ и/или СКЛАД КУХНИ и не быть РЕСТОРАНОМ, если у него есть ВКЛЮЧЕННЫЕ КАССЫ: магазин &2, касса: БД&3 тип кассы &4 номер кассы &5",
        "kitchen-store-code":U, p-obj-code, buf_cash-desk.db-num, buf_cash-desk.pos-type, buf_cash-desk.cash-num, {&delim-par}) . 
    end.
end.


/* ----- проверки по pay-type ----- */
/* собираем в pay-type-list все pay-type, которые ещё не проверяли, чтобы не искать по ним pay-type повторно */
v-pay-type-list = "":U .
if p-chk-pay <> 0 then do:
  v-pay-type-str = string(p-chk-pay) .
  if not can-find (first buf_pay-type where buf_pay-type.obj-code = p-chk-pay) then
    undo, return error substitute("&1&4Неверный код оплаты реализации (продажи) для магазина &2: код оплаты &3",
                                  "chk-pay":U, p-obj-code, v-pay-type-str, {&delim-par}) .
  v-pay-type-list = v-pay-type-str .
end.

if p-down-pay <> 0 then do:
  v-pay-type-str = string(p-down-pay) .
  if not can-do (v-pay-type-list, v-pay-type-str) then do:
    if not can-find (first buf_pay-type where buf_pay-type.obj-code = p-down-pay) then
    undo, return error substitute("&1&4Неверный код оплаты списания для магазина &2: код оплаты &3",
                                  "down-pay":U, p-obj-code, v-pay-type-str, {&delim-par}) .
    v-pay-type-list = substitute("&1,&2", v-pay-type-list, v-pay-type-str) .
  end.
end.

if p-in-pay <> 0 then do:
  v-pay-type-str = string(p-in-pay) .
  if not can-do (v-pay-type-list, v-pay-type-str) then do:
    if not can-find (first buf_pay-type where buf_pay-type.obj-code = p-in-pay) then
    undo, return error substitute("&1&4Неверный код оплаты прихода для магазина &2: код оплаты &3",
                                  "in-pay":U, p-obj-code, v-pay-type-str, {&delim-par}) .
    v-pay-type-list = substitute("&1,&2", v-pay-type-list, v-pay-type-str) .
  end.
end.

if p-inv-pay <> 0 then do:
  v-pay-type-str = string(p-inv-pay) .
  if not can-do (v-pay-type-list, v-pay-type-str) then do:
    if not can-find (first buf_pay-type where buf_pay-type.obj-code = p-inv-pay) then
    undo, return error substitute("&1&4Неверный код оплаты инвентаризации для магазина &2: код оплаты &3",
                                  "inv-pay":U, p-obj-code, p-inv-pay, {&delim-par}) .
    v-pay-type-list = substitute("&1,&2", v-pay-type-list, v-pay-type-str) .
  end.
end.

if p-out-pay <> 0 then do:
  v-pay-type-str = string(p-out-pay) .
  if not can-do (v-pay-type-list, v-pay-type-str) then do:
    if not can-find (first buf_pay-type where buf_pay-type.obj-code = p-out-pay) then
    undo, return error substitute("&1&4Неверный код оплаты расхода для магазина &2: код оплаты &3",
                                   "out-pay":U, p-obj-code, p-out-pay, {&delim-par}) . 
    v-pay-type-list = substitute("&1,&2", v-pay-type-list, v-pay-type-str) .
  end.
end.

if p-ret-pay <> 0 then do:
  v-pay-type-str = string(p-ret-pay) .
  if not can-do (v-pay-type-list, v-pay-type-str) then do:
    if not can-find (first buf_pay-type where buf_pay-type.obj-code = p-ret-pay) then
    undo, return error substitute("&1&4Неверный код оплаты возврата от покупателя для магазина &2: код оплаты &3",
                                  "ret-pay":U, p-obj-code, p-ret-pay, {&delim-par}) .
    v-pay-type-list = substitute("&1,&2", v-pay-type-list, v-pay-type-str) .
  end.
end.

if p-ret-sup-pay <> 0 then do:
  v-pay-type-str = string(p-ret-sup-pay) .
  if not can-do (v-pay-type-list, v-pay-type-str) then do:
    if not can-find (first buf_pay-type where buf_pay-type.obj-code = p-ret-sup-pay) then
    undo, return error substitute("&1&4Неверный код оплаты возврата поставщику для магазина &2: код оплаты &3",
                                  "ret-sup-pay":U, p-obj-code, p-ret-sup-pay, {&delim-par}) .
    v-pay-type-list = substitute("&1,&2", v-pay-type-list, v-pay-type-str) .
  end.
end.

if p-fbr-pay <> 0 then do:
  v-pay-type-str = string(p-fbr-pay) .
  if not can-do (v-pay-type-list, v-pay-type-str) then do:
    if not can-find (first buf_pay-type where buf_pay-type.obj-code = p-fbr-pay) then
    undo, return error substitute("&1&4Неверный код оплаты производства для магазина &2: код оплаты &3",
                                  "fbr-pay":U, p-obj-code, p-fbr-pay, {&delim-par}) .
  end.
end.
/* ----- end_of проверки по pay-type ----- */


_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = {&add-def} then do:
    create ub.shop.
    create ub.clients.
    assign
    ub.clients.obj-code = p-obj-code
    ub.clients.obj-type = {&shop}
    ub.clients.db-num   = p-db-num
    ub.clients.grp-code = p-grp-code
    ub.clients.host-code = p-host-code
    ub.shop.obj-code = p-obj-code
    ub.shop.host-code   = p-host-code
    p-rec = recid(ub.clients).
  end.
  else do:
    FIND FIRST ub.clients where
              recid(ub.clients) = p-rec No-ERROR.
    if not available ub.clients then
      undo, return error substitute('&5&1 &2 &3&4Не найдена запись КЛИЕНТ для записи МАГАЗИН - p-rec [&6]':u,
                                     vss-workfile, vss-revision, vss-description, {&new-line}, {&delim-par}, p-rec).
    find first ub.shop where
              ub.shop.obj-code = p-obj-code no-error .
    if not available ub.shop then
      undo, return error substitute('&5&1 &2 &3&4Не найдена запись МАГАЗИН с кодом [&6]':u,
                                     vss-workfile, vss-revision, vss-description, {&new-line}, {&delim-par}, p-obj-code).
    if ub.shop.obj-code <> p-obj-code
    or ub.shop.host-code <> p-host-code
    or ub.clients.db-num    <> p-db-num
    then
      undo, return error substitute('&5&1 &2 &3&4Для уже имеющегося МАГАЗИНА нельзя изменить номер магазина, номер БД и код фирмы':u,
                                     vss-workfile, vss-revision, vss-description, {&new-line}, {&delim-par}).
  end.
  assign
  ub.clients.obj-name         =  p-obj-name
  ub.clients.PS               =  p-PS
  ub.shop.acct                =  p-acct
  ub.shop.addres1             =  p-addres1
  ub.shop.addres2             =  p-addres2
  ub.shop.all-prt             =  p-all-prt
  ub.shop.buy-goods           =  p-buy-goods
  ub.shop.cd-bc-alt           =  p-cd-bc-alt
  ub.shop.cd-bc-base          =  p-cd-bc-base
  ub.shop.cd-loc-alt          =  p-cd-loc-alt
  ub.shop.cd-loc-base         =  p-cd-loc-base
  ub.shop.cd-parts-all        =  p-cd-parts-all
  ub.shop.cd-parts-not-blank  =  p-cd-parts-not-blank
  ub.shop.cd-parts-ser        =  p-cd-parts-ser
  ub.shop.cd-pb-alt           =  p-cd-pb-alt
  ub.shop.cd-pb-base          =  p-cd-pb-base
  ub.shop.cd-sc-base          =  p-cd-sc-base
  ub.shop.chk-pay             =  p-chk-pay
  ub.shop.day-only            =  p-day-only
  ub.shop.director            =  p-director
  ub.shop.discaloc            =  p-discaloc
  ub.shop.doc-prt             =  p-doc-prt
  ub.shop.down-pay            =  p-down-pay
  /*ub.shop.dst-price       =  p-p.dst-price*/
  ub.shop.fax                 =  p-fax
  ub.shop.goods-man           =  p-goods-man
  /*ub.shop.holidays        =  p-p.holidays */
  ub.shop.in-ov               =  p-in-ov
  ub.shop.in-pay              =  p-in-pay
  ub.shop.in-perm             =  p-in-perm
  ub.shop.inout-price         =  p-inout-price
  ub.shop.inv-pay             =  p-inv-pay
  ub.shop.is-catering         =  p-is-catering
  ub.shop.is-kitchen          =  p-is-kitchen
  ub.shop.is-kitchen-store    =  p-is-kitchen-store
  ub.shop.kitchen-store-code  =  if p-is-kitchen
                                  then p-kitchen-store-code
                                  else 0
  ub.shop.kitchen-store-type  =  if p-is-kitchen
                                  then p-kitchen-store-type
                                  else "":U
  /*ub.shop.load-time       =  p-load-time*/
  ub.shop.no-eq               =  p-no-eq
  /*ub.shop.no-short-code   =  p-no-short-code*/
  ub.shop.out-line-discnt     =  p-out-line-discnt
  ub.shop.out-pay             =  p-out-pay
  ub.shop.out-rate            =  p-out-rate
  ub.shop.phone               =  p-phone
  ub.shop.pr-cash             =  p-pr-cash
  ub.shop.price-calc          =  p-price-calc
  ub.shop.ret-pay             =  p-ret-pay
  ub.shop.ret-sup-pay         =  p-ret-sup-pay
  ub.shop.fbr-pay             =  p-fbr-pay
  ub.shop.rsrv-time           =  p-rsrv-time
  ub.shop.shift-on            =  p-shift-on
  ub.shop.store-boss          =  p-store-boss
  ub.shop.store-man           =  p-store-man
  ub.shop.sub-store-on        =  p-sub-store-on
  ub.shop.sub-store-code      =  if p-sub-store-on
                                  then p-sub-store-code
                                  else 0
  ub.shop.sub-store-type      =  if p-sub-store-on
                                  then p-sub-store-type
                                  else "":U
  ub.shop.unit-cli-perm       =  p-unit-cli-perm
  ub.shop.with-serv           =  p-with-serv
  ub.shop.work-hours          =  p-work-hours
  ub.shop.purch-code          =  p-purch-code
  p-rec = recid(ub.clients )
  .
 release ub.clients no-error.
 if error-status:error then do:
    undo, return error substitute(
      "&5Ошибка при сохранении записи КЛИЕНТ для МАГАЗИНА &1:&2&3&2&4"
    , p-obj-code
    , {&new-line}
    , ERROR-STATUS:GET-message(1)
    , return-value
    , {&delim-par}
    ) .
 end.
 p-obj-code = ub.shop.obj-code.
 release ub.shop no-error.
 if error-status:error then do:
    undo, return error substitute(
      "&5Ошибка при сохранении записи МАГАЗИН &1:&2&3&2&4"
    , p-obj-code
    , {&new-line}
    , ERROR-STATUS:GET-message(1)
    , return-value
    , {&delim-par}
    ) .
 end.

 run clntattr-value in this-procedure
      (input {&shop},
      input  p-obj-code,
      input  {&attr-pharm},
      output v-pharm,
      output par-type).
  if v-pharm = "yes":u then do:
    if p-pharm = no then do:
      run clntattr-delete in this-procedure
       (input {&shop},
        input  p-obj-code,
        input  {&attr-pharm},
        output v-delete).
    end.
  end.
  else do:
    if p-pharm = yes then do:
      run clntattr-write in this-procedure
       (input  {&shop},
        input  p-obj-code,
        input  {&attr-pharm},
        input  "yes":u).
    end.
  end.

    /* Для КПП */

 run clntattr-value in this-procedure
      (input {&shop},
      input  p-obj-code,
      input  {&attr-kpp},
      output v-kpp,
      output par-type).

  if v-kpp <> "":u and v-kpp <> ? then do:
    if p-kpp = "" or p-kpp = ? then do:
      run clntattr-delete in this-procedure
       (input {&shop},
        input  p-obj-code,
        input  {&attr-kpp},
        output v-delete).
    end.
    else do:
      if p-kpp <> "" and p-kpp <> ? then do:
       run clntattr-write in this-procedure
       (input  {&shop},
        input  p-obj-code,
        input  {&attr-kpp},
        input  p-kpp).
    end.
    end.
  end.
    else do:
    if p-kpp <> "" and p-kpp <> ? then do:
      run clntattr-write in this-procedure
       (input  {&shop},
        input  p-obj-code,
        input  {&attr-kpp},
        input  p-kpp).
    end.
  end.

    /* Для ЕНВД */
 run clntattr-value in this-procedure
      (input {&shop},
      input  p-obj-code,
      input  {&attr-envd},
      output v-envd,
      output par-type).
  if v-envd = "yes":u then do:
    if p-envd = no then do:
      run clntattr-delete in this-procedure
       (input {&shop},
        input  p-obj-code,
        input  {&attr-envd},
        output v-delete).
    end.
  end.
  else do:
    if p-envd = yes then do:
      run clntattr-write in this-procedure
       (input  {&shop},
        input  p-obj-code,
        input  {&attr-envd},
        input  "yes":u).
    end.
  end.
  
  
 if p-mode = {&add-def} then do:
    run trg/curr-shc.p (p-obj-code) no-error .
    if error-status:error then
      undo, return error substitute("&3Ошибка при создании записи курса базовой валюты при создании МАГАЗИНА &1: &2",
                                    p-obj-code, ERROR-STATUS:GET-message(1), {&delim-par}) .
 end.
 
end. /*doe*/


PROCEDURE chk-code :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input parameter p-obj-code like ub.shop.obj-code no-undo .
define input parameter p-mode     as character no-undo .
define variable hnum as logical no-undo init no.
/*настройка - откуда брать номер магазина при чтении чеков из спула - из спула- yes или
по умолчанию номер магазина в котором принимается почта*/
define variable  par-type as character no-undo.
define variable  dopi as integer no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .

if p-obj-code = 0 then
  return error "Код магазина должен быть больше 0 ".

if  p-mode = {&add-def}
and can-find( ub.shop where ub.shop.obj-code = p-obj-code ) then
  return error substitute("Магазин с кодом &1 уже есть, измените код", p-obj-code ).

if p-obj-code > 999 and  p-mode = {&add-def}  then do:
  run adm/shattri.p (
      input "get":U
      ,input  {&cmp}
      ,input  p-host-code
      ,input  {&attr-get-chk}
      ,input  {&attr-get-chk_hnum} /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output par-type
      ,INPUT-OUTPUT TABLE-handle v-tth
      ) no-error .
  if valid-handle(v-tth) then do:
    delete object v-tth.
  end.
  IF not error-status:error then do:
    assign
    hnum = v-value-logical.
  end.
  if hnum then do:
    return error substitute(
      "Вы не можете присвоить магазину номер > 999 (&1)&3" +
      "пока настроечный параметр <НОМЕР МАГАЗИНА ПРИ ЧТЕНИИ ДАННЫХ С КАССЫ БРАТЬ ИЗ СПУЛА>&3" +
      "для фирмы &2 равен ДА; измените код"
    , p-obj-code
    , p-host-code
    , {&new-line}
    ) .
  end.
end.
return.
END PROCEDURE.
