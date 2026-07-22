block-level on error undo, throw.
/*

$Revision: 174449d8c587, 3618, rls $
$Author: ARostovtsev $
$Date: 2023/12/28 12:56:37 $
$Workfile: lib-farh.p $
$Archive: str/lib-farh.p $

Библиотека для работы с финансовыми архивами по финдокументам

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

Создана: 18/12/2003

В случае платежных поручений сумма расходуется со счета payer-code-schet, а приходуется на счет receiver-code-schet.
В случае приходного кассового ордера расход со счета cor-acc, приход на cor-acc1.
В случае расходного кассового ордера расход со счета cor-acc1, приход на cor-acc.

*/
define variable vss-revision    as character no-undo init "$Revision: 174449d8c587, 3618, rls $":U .
define variable vss-author      as character no-undo init "$Author: ARostovtsev $":U .
define variable vss-date        as character no-undo init "$Date: 2023/12/28 12:56:37 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: lib-farh.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/lib-farh.p $":U .
define variable vss-description as character no-undo init "Библиотека для работы с финансовыми архивами".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ trg/factord.i }
{ ref/fd-attr.i  }
{ str/lib-farh.i }
{ str/libfarhp.i }
{&check_libfarhp}
{ str/libfarpo.i }
{&check_libfarpo}
{ str/farh-def.i }

if valid-handle (g#lib-farh)
and g#lib-farh <> this-procedure :handle
and g#lib-farh :get-signature('lib-farh_crfdsclk':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки для работы с финансовыми архивами" skip
    g#lib-farh skip
    g#lib-farh :type skip
    g#lib-farh :file-name skip
    valid-handle(g#lib-farh) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#lib-farh = this-procedure :handle
  .
end.

on delete of this-procedure do:
  assign
    g#lib-farh = ?
  .
end.
define stream str-err.

/*создание записи локирования расчетного счета финдокументом*/
procedure lib-farh_crfdsclk :
define input parameter parhost-code    like ub.fin-doc-schet-lk.host-code    no-undo.
define input parameter parcode-schet   like ub.fin-doc-schet-lk.code-schet   no-undo.
define input parameter paruser-name    like ub.fin-doc-schet-lk.user-name    no-undo.
define input parameter parfin-doc-code like ub.fin-doc-schet-lk.fin-doc-code no-undo.
define input parameter partype-lock    like ub.fin-doc-schet-lk.type-lock    no-undo.
define input parameter pardate-lock    like ub.fin-doc-schet-lk.date-lock    no-undo.
define input parameter partime-lock    like ub.fin-doc-schet-lk.time-lock    no-undo.
define buffer bf_fin-doc-schet-lk for ub.fin-doc-schet-lk.
do on error undo, return error return-value :
find first bf_fin-doc-schet-lk where bf_fin-doc-schet-lk.host-code  = parhost-code  and
                                     bf_fin-doc-schet-lk.code-schet = parcode-schet no-lock no-error.
if not available bf_fin-doc-schet-lk then do:
  create bf_fin-doc-schet-lk.
  assign
    bf_fin-doc-schet-lk.host-code     = parhost-code
    bf_fin-doc-schet-lk.code-schet    = parcode-schet
    bf_fin-doc-schet-lk.user-name     = paruser-name
    bf_fin-doc-schet-lk.fin-doc-code  = parfin-doc-code
    bf_fin-doc-schet-lk.type-lock     = partype-lock
    bf_fin-doc-schet-lk.date-lock     = pardate-lock
    bf_fin-doc-schet-lk.time-lock     = partime-lock    .
end.
end.
end procedure.

/*создание записи локирования корреспондирующего счета финдокументом*/
procedure lib-farh_crfdcrlk :
define input parameter parhost-code         like ub.fin-doc-schet-lk.host-code    no-undo.
define input parameter parfin-code-cor-acc  like ub.fin-code-cor-acc.fin-code     no-undo.
define input parameter paruser-name         like ub.fin-doc-schet-lk.user-name    no-undo.
define input parameter parfin-doc-code      like ub.fin-doc-schet-lk.fin-doc-code no-undo.
define input parameter partype-lock         like ub.fin-doc-schet-lk.type-lock    no-undo.
define input parameter pardate-lock         like ub.fin-doc-schet-lk.date-lock    no-undo.
define input parameter partime-lock         like ub.fin-doc-schet-lk.time-lock    no-undo.
define buffer bf_fin-doc-cor-acc-lk for ub.fin-doc-cor-acc-lk.
do on error undo, return error return-value :
find first bf_fin-doc-cor-acc-lk where bf_fin-doc-cor-acc-lk.host-code = parhost-code        and
                                       bf_fin-doc-cor-acc-lk.fin-code  = parfin-code-cor-acc no-lock no-error.
if not available bf_fin-doc-cor-acc-lk then do:
  create bf_fin-doc-cor-acc-lk.
  assign
    bf_fin-doc-cor-acc-lk.host-code     = parhost-code
    bf_fin-doc-cor-acc-lk.fin-code      = parfin-code-cor-acc
    bf_fin-doc-cor-acc-lk.user-name     = paruser-name
    bf_fin-doc-cor-acc-lk.fin-doc-code  = parfin-doc-code
    bf_fin-doc-cor-acc-lk.type-lock     = partype-lock
    bf_fin-doc-cor-acc-lk.date-lock     = pardate-lock
    bf_fin-doc-cor-acc-lk.time-lock     = partime-lock    .
end.
end.
end procedure.

/*локирование записи расчетного счета финдокументом*/
procedure lib-farh_lkschdoc :
define input parameter parhost-code    like ub.fin-schet.host-code.
define input parameter parcode-schet   like ub.fin-schet.code-schet.
define input parameter paruser-name    as character no-undo .
define input parameter parfin-doc-code like ub.fin-doc.fin-doc-code.
define buffer bf_fin-schet        for ub.fin-schet.
define buffer bf_fin-doc-schet-lk for ub.fin-doc-schet-lk.
do on error undo, return error return-value :
  find first bf_fin-schet where bf_fin-schet.host-code  = parhost-code  and
                                bf_fin-schet.code-schet = parcode-schet no-lock no-error.
  if not available bf_fin-schet then do:
    return error substitute ("Не найден счет с внутренним номером &1 по фирме &2.", parcode-schet, parhost-code).
  end.
  find first bf_fin-doc-schet-lk where bf_fin-doc-schet-lk.host-code  = bf_fin-schet.host-code  and
                                       bf_fin-doc-schet-lk.code-schet = bf_fin-schet.code-schet exclusive-lock no-error.
  if not available bf_fin-doc-schet-lk then do:
    run lib-farh_crfdsclk in this-procedure
      (input bf_fin-schet.host-code,
       input bf_fin-schet.code-schet,
       input paruser-name,
       input parfin-doc-code,
       input "расчет финансовых архивов":u,
       input today,
       input time) no-error.
    if error-status:error then do:
      return error return-value.
    end.
  end.
  find first bf_fin-doc-schet-lk where bf_fin-doc-schet-lk.host-code  = bf_fin-schet.host-code  and
                                       bf_fin-doc-schet-lk.code-schet = bf_fin-schet.code-schet exclusive-lock.
end.
end procedure.

/*локирование записи корреспондирующего счета финдокументом*/
procedure lib-farh_lkcordoc :
define input parameter parhost-code        like ub.fin-schet.host-code.
define input parameter parfin-code-cor-acc like ub.fin-code-cor-acc.fin-code.
define input parameter paruser-name        as character no-undo .
define input parameter pardoc-code         like ub.fin-doc.fin-doc-code.
define buffer bf_fin-doc-cor-acc-lk for ub.fin-doc-cor-acc-lk.
do on error undo, return error return-value :
  find first bf_fin-doc-cor-acc-lk where bf_fin-doc-cor-acc-lk.host-code = parhost-code        and
                                         bf_fin-doc-cor-acc-lk.fin-code  = parfin-code-cor-acc exclusive-lock no-error.
  if not available bf_fin-doc-cor-acc-lk then do:
    run lib-farh_crfdcrlk in this-procedure
      (input parhost-code       ,
       input parfin-code-cor-acc,
       input paruser-name,
       input pardoc-code,
       input "расчет финансовых архивов":u,
       input today,
       input time) no-error.
    if error-status:error then do:
      return error return-value.
    end.
  end.
  find first bf_fin-doc-cor-acc-lk where bf_fin-doc-cor-acc-lk.host-code = parhost-code        and
                                         bf_fin-doc-cor-acc-lk.fin-code  = parfin-code-cor-acc exclusive-lock.

end.
end procedure.

define temp-table tt-sum-con-fin-ob-obj no-undo
field obj-type      like ub.fin-ob.obj-type
field obj-code      like ub.fin-ob.obj-code
field sum-base      like ub.fin-ob.sum-base
field sum-rubl      like ub.fin-ob.sum-rubl
field sum-contract  like ub.fin-ob.sum-contract
field sum-doc       like ub.fin-doc.sum-doc
field sum-vat-base  like ub.fin-ob-tax.sum-vat-line-base
field sum-vat-rubl  like ub.fin-ob-tax.sum-vat-line-rubl
field sum-vat-contr like ub.fin-ob-tax.sum-vat-line-contr
field sum-vat-doc   like ub.fin-doc.sum-doc
field sum-slt-base  like ub.fin-ob-tax.sum-slt-line-base
field sum-slt-rubl  like ub.fin-ob-tax.sum-slt-line-rubl
field sum-slt-contr like ub.fin-ob-tax.sum-slt-line-contr
field sum-slt-doc   like ub.fin-doc.sum-doc
index pi is unique primary obj-type obj-code.

define temp-table tt-sum-con-fin-ob-tax-obj no-undo
field obj-type       like ub.fin-ob.obj-type
field obj-code       like ub.fin-ob.obj-code
field vat-pc         like ub.fin-ob-tax.vat-pc
field slt-pc         like ub.fin-ob-tax.slt-pc
field with-vat       like ub.fin-ob-tax.with-vat
field with-slt       like ub.fin-ob-tax.with-slt
field sum-doc        like ub.fin-ob-tax.sum-line-doc
field sum-rubl       like ub.fin-ob-tax.sum-line-rubl
field sum-base       like ub.fin-ob-tax.sum-line-base
field sum-contr      like ub.fin-ob-tax.sum-line-contr
field sum-vat-base   like ub.fin-ob-tax.sum-vat-line-base
field sum-vat-rubl   like ub.fin-ob-tax.sum-vat-line-rubl
field sum-vat-contr  like ub.fin-ob-tax.sum-vat-line-contr
field sum-vat-doc    like ub.fin-doc.sum-doc
field sum-slt-base   like ub.fin-ob-tax.sum-slt-line-base
field sum-slt-rubl   like ub.fin-ob-tax.sum-slt-line-rubl
field sum-slt-contr  like ub.fin-ob-tax.sum-slt-line-contr
field sum-slt-doc    like ub.fin-doc.sum-doc
index pi is unique primary obj-type obj-code vat-pc slt-pc with-vat with-slt
index nalog vat-pc slt-pc with-vat with-slt.

define temp-table tt-sum-fin-doc-tax no-undo
field vat-pc         like ub.fin-ob-tax.vat-pc
field slt-pc         like ub.fin-ob-tax.slt-pc
field with-vat       like ub.fin-ob-tax.with-vat
field with-slt       like ub.fin-ob-tax.with-slt
field sum-line-doc   like ub.fin-ob-tax.sum-line-doc
field sum-line-rubl  like ub.fin-ob-tax.sum-line-rubl
field sum-line-base  like ub.fin-ob-tax.sum-line-base
field sum-line-contr like ub.fin-ob-tax.sum-line-contr
field sum-vat-base   like ub.fin-ob-tax.sum-vat-line-base
field sum-vat-rubl   like ub.fin-ob-tax.sum-vat-line-rubl
field sum-vat-contr  like ub.fin-ob-tax.sum-vat-line-contr
field sum-vat-doc    like ub.fin-doc.sum-doc
field sum-slt-base   like ub.fin-ob-tax.sum-slt-line-base
field sum-slt-rubl   like ub.fin-ob-tax.sum-slt-line-rubl
field sum-slt-contr  like ub.fin-ob-tax.sum-slt-line-contr
field sum-slt-doc    like ub.fin-doc.sum-doc
index pi is unique primary vat-pc slt-pc with-vat with-slt.

define temp-table tt-sum-fin-ob-tax no-undo
field vat-pc        like ub.fin-ob-tax.vat-pc
field slt-pc        like ub.fin-ob-tax.slt-pc
field with-vat      like ub.fin-ob-tax.with-vat
field with-slt      like ub.fin-ob-tax.with-slt
field sum-vat-base  like ub.fin-ob-tax.sum-vat-line-base
field sum-vat-rubl  like ub.fin-ob-tax.sum-vat-line-rubl
field sum-vat-contr like ub.fin-ob-tax.sum-vat-line-contr
field sum-vat-doc   like ub.fin-doc.sum-doc
field sum-slt-base  like ub.fin-ob-tax.sum-slt-line-base
field sum-slt-rubl  like ub.fin-ob-tax.sum-slt-line-rubl
field sum-slt-contr like ub.fin-ob-tax.sum-slt-line-contr
field sum-slt-doc   like ub.fin-doc.sum-doc
index pi is unique primary vat-pc slt-pc with-vat with-slt.

/*Задание на расчет архивов по финдокументам*/
/*
 какие архивы рассчитываются и какой процедурой
 они должны быть все определены как ходящие по новостям
 в триггере должен быть callnews.p
 в call-nws.i они должнгы маршрутизироватья из УБД в ГБД на случай если главная БД фирмы не 0
 случай когда главная БД не 0 а объект свосем другой УБД - НЕ РАССМАТРИВАЕМ


                                                                                         n w s-tabs . i        call-nws.i  trg
libfarhp_calc-arh-fin-doc-an                    arh-fin-doc-an                             +                      +         +
libfarhp_calc-arh-fin-doc-an-n                  arh-fin-doc-an-nal                         +                      +         +
libfarhp_calc-arh-fin-doc-contr-schet           arh-fin-doc-contr-schet                    +                      +         +
libfarhp_calc-arh-fin-doc-contr-schet-n         arh-fin-doc-contr-schet-nal                +                      +         +
libfarhp_calc-arh-fin-doc-contr-schet-tax       arh-fin-doc-contr-schet-tax                +                      +         +
libfarhp_calc-arh-fin-doc-contr-schet-tax-n     arh-fin-doc-c-schet-tax-nal                +                      +         +
libfarhp_calc-arh-fin-doc-schet                 arh-fin-doc-schet                          +                      +         +
libfarhp_calc-arh-fin-doc-schet-n               arh-fin-doc-schet-nal                      +                      +         +
libfarhp_calc-arh-fin-doc-schet-tax             arh-fin-doc-schet-tax                      +                      +         +
libfarhp_calc-arh-fin-doc-schet-tax-n           arh-fin-doc-schet-tax-nal                  +                      +         +

libfarpo_calc-arh-fin-doc-contr-schet-obj       arh-fin-doc-contr-schet-obj                +                      +         +
libfarpo_calc-arh-fin-doc-contr-schet-n-obj     arh-fin-doc-contr-s-nal-obj                +                      +         +
libfarpo_calc-arh-fin-doc-contr-schet-tax-obj   arh-fin-doc-contr-s-tax-obj                +                      +         +
libfarpo_calc-arh-fin-doc-contr-schet-tax-n-obj arh-fin-doc-c-s-tax-nal-obj                +                      +         +
libfarpo_calc-arh-fin-doc-schet-obj             arh-fin-doc-schet-obj                      +                      +         +
libfarpo_calc-arh-fin-doc-schet-n-obj           arh-fin-doc-schet-nal-obj                  +                      +         +

*/


procedure lib-farh_taskclcd:
define input parameter parhost-code    like ub.fin-doc.host-code    no-undo.
define input parameter parfin-doc-code like ub.fin-doc.fin-doc-code no-undo.
define input parameter pararh-name     as character no-undo .
define input parameter paruser-name    as character no-undo .
define input parameter parmode         as character no-undo .

define buffer bf_contract                for ub.contract.
define buffer bf_fin-doc                 for ub.fin-doc.
define buffer bf_fin-doc-tax             for ub.fin-doc-tax.
define buffer bf_sysconf                 for ub.sysconf.
define variable varrel-dog-code       as   logical               no-undo.
define variable varcurr-dog-code      like ub.currency.curr-code no-undo.
define variable varhave-connect       as   logical               no-undo.
define variable varznaksum-doc        as   decimal               no-undo.
define variable varznaksum-rubl       as   decimal               no-undo.
define variable varznaksum-base       as   decimal               no-undo.
define variable varznaksum-contr      as   decimal               no-undo.
define variable varznaksum-vat-doc    as   decimal               no-undo.
define variable varznaksum-vat-rubl   as   decimal               no-undo.
define variable varznaksum-vat-base   as   decimal               no-undo.
define variable varznaksum-vat-contr  as   decimal               no-undo.
define variable varznaksum-slt-doc    as   decimal               no-undo.
define variable varznaksum-slt-rubl   as   decimal               no-undo.
define variable varznaksum-slt-base   as   decimal               no-undo.
define variable varznaksum-slt-contr  as   decimal               no-undo.
define variable varfin-doc-tax-vat-pc as   decimal               no-undo.
define variable varfin-doc-tax-slt-pc as   decimal               no-undo.
define variable v-curr-db-num         as   integer               no-undo.
define variable v-is-income as logical no-undo .
define variable v-is-expense as logical no-undo .
define variable v-is-cash as logical no-undo .
define variable v-is-cashless as logical no-undo .
define variable v-is-payoff as logical no-undo .
define variable v-recalc as logical no-undo .

do on error undo, return error return-value :
  find first bf_fin-doc where bf_fin-doc.host-code    = parhost-code    and
                              bf_fin-doc.fin-doc-code = parfin-doc-code exclusive-lock no-error.
  if not available bf_fin-doc then do:
    return error substitute ("Не найден платежный документ с внутренним номером &1 по фирме &2.", parfin-doc-code, parhost-code).
  end.
  if bf_fin-doc.contract-code <> 0 then do:
    find first bf_contract where bf_contract.host-code     = bf_fin-doc.host-code     and
                                 bf_contract.contract-code = bf_fin-doc.contract-code no-lock no-error.
    if not available bf_contract then do:
      return error substitute ("По платежному документу с внутренним номером &1 на фирме &2 указан договор с внутренним номером &3, которого нет в базе данных.", bf_fin-doc.fin-doc-code, bf_fin-doc.host-code, bf_fin-doc.contract-code).
    end.
    assign
      varrel-dog-code  = yes
      varcurr-dog-code = bf_contract.curr-code.
  end.
  else do:
    assign
      varrel-dog-code = no.
  end.
  find first bf_sysconf where bf_sysconf.host-code = bf_fin-doc.host-code no-lock.
  if bf_sysconf.fin-calc = {&fin-calc-obj} then do:
    run check-sum-doc  in this-procedure (input bf_fin-doc.host-code, input bf_fin-doc.fin-doc-code, output varhave-connect).
  end.
  if parmode <> "close":u  and
     parmode <> "delete":u and
     parmode <> "recalc":u then do:
    return error substitute ("Неверный параметр вызова расчета финансовых архивов &1. Должен быть close или delete.", parmode).
  end.
  if parmode = "recalc":u  then do:
    v-recalc = yes.
    parmode = "close".
  end.
  if bf_fin-doc.status_ <> {&fin-fact} then do:
    return error substitute ("Платежный документ с номером &1 не находится в статусе &2.", bf_fin-doc.prn-doc-code, {&fin-fact}).
  end.
  run check-attr-doc in this-procedure (input bf_fin-doc.host-code, input bf_fin-doc.fin-doc-code).
  run full-lock in this-procedure (input bf_fin-doc.host-code, input bf_fin-doc.fin-doc-code, input paruser-name).
  run calc-sum  in this-procedure (input parmode,
                                   input bf_fin-doc.host-code,
                                   input bf_fin-doc.fin-doc-code,
                                   output varznaksum-doc      ,
                                   output varznaksum-rubl     ,
                                   output varznaksum-base     ,
                                   output varznaksum-contr    ,
                                   output varznaksum-vat-doc  ,
                                   output varznaksum-vat-rubl ,
                                   output varznaksum-vat-base ,
                                   output varznaksum-vat-contr,
                                   output varznaksum-slt-doc  ,
                                   output varznaksum-slt-rubl ,
                                   output varznaksum-slt-base ,
                                   output varznaksum-slt-contr
                                   ).
  { gbl/curdbnum.i v-curr-db-num }
  assign
  v-is-income = lookup(bf_fin-doc.fin-ext-doc-type, {&fin-ext-doc-income-types}) > 0
  v-is-expense = lookup(bf_fin-doc.fin-ext-doc-type, {&fin-ext-doc-expense-types}) > 0
  v-is-cash = lookup(bf_fin-doc.fin-ext-doc-type, {&fin-ext-doc-cash-types}) > 0
  v-is-cashless = lookup(bf_fin-doc.fin-ext-doc-type, {&fin-ext-doc-cashless-types}) > 0
  v-is-payoff = lookup(bf_fin-doc.fin-ext-doc-type, {&fin-ext-doc-payoff-types}) > 0
  .
  define variable v-obj-db-num as integer init ? no-undo .
  if bf_fin-doc.obj-type <> ''  then do:
    { gbl/objdbnum.i bf_fin-doc.obj-type bf_fin-doc.obj-code v-obj-db-num }
    if bf_fin-doc.shift-flag = integer({&fin-flag-shift})
    and (v-obj-db-num = v-curr-db-num or v-recalc or v-curr-db-num = 0)
    then do:
      /*находим смену и пр*/
    end. /*if bf_fin-doc.shift-flag = integer({&fin-flag-shift})*/
  end. /*if p-obj-type <> '' then do:*/
    /*ППП, РПП (безнал)*/
  if v-obj-db-num = ? then  v-obj-db-num = bf_sysconf.firm-db-num.  /*Фирменные и глобальные архивы считаются только для активных объектов. Иначе пересечение по fact-order. */

    if v-is-cashless then do:
    if pararh-name = "all":u                        or
    lookup ({&table_arh-fin-doc-an}, pararh-name) > 0  and  v-curr-db-num = v-obj-db-num then do:
      if bf_sysconf.firm-db-num = v-curr-db-num then
      run libfarhp_calc-arh-fin-doc-an in g#libfarhp (input parmode,
                                                      input bf_fin-doc.host-code,
                                                      input bf_fin-doc.payer-type,
                                                      input bf_fin-doc.payer-code,
                                                      input bf_fin-doc.receiver-type,
                                                      input bf_fin-doc.receiver-code,
                                                      input bf_fin-doc.payer-code-schet,
                                                      input bf_fin-doc.receiver-code-schet,
                                                      input bf_fin-doc.fin-ext-doc-type,
                                                      input bf_fin-doc.an-uchet-code,
                                                      input bf_fin-doc.cel-nazn-code,
                                                      input bf_fin-doc.cor-acc,
                                                      input {&arh-fin-doc-an-atom},
                                                      input bf_fin-doc.fact-order,
                                                      input bf_fin-doc.fin-doc-code,
                                                      input bf_fin-doc.fact-date,
                                                      input bf_fin-doc.curr-code,
                                                      input bf_sysconf.base-code,
                                                      input varcurr-dog-code,
                                                      input varrel-dog-code,
                                                      input varznaksum-doc      ,
                                                      input varznaksum-rubl     ,
                                                      input varznaksum-base     ,
                                                      input varznaksum-contr    ,
                                                      input varznaksum-vat-doc  ,
                                                      input varznaksum-vat-rubl ,
                                                      input varznaksum-vat-base ,
                                                      input varznaksum-vat-contr,
                                                      input varznaksum-slt-doc  ,
                                                      input varznaksum-slt-rubl ,
                                                      input varznaksum-slt-base ,
                                                      input varznaksum-slt-contr
                                                      ).
      /*Итоговая в разрезе счета по коду аналитического учета*/
      if bf_sysconf.firm-db-num = v-curr-db-num then
      run libfarhp_calc-arh-fin-doc-an in g#libfarhp (input parmode,
                                                      input bf_fin-doc.host-code,
                                                      input bf_fin-doc.payer-type,
                                                      input bf_fin-doc.payer-code,
                                                      input bf_fin-doc.receiver-type,
                                                      input bf_fin-doc.receiver-code,
                                                      input bf_fin-doc.payer-code-schet,
                                                      input bf_fin-doc.receiver-code-schet,
                                                      input bf_fin-doc.fin-ext-doc-type,
                                                      input bf_fin-doc.an-uchet-code,
                                                      input 0,
                                                      input 0,
                                                      input {&arh-fin-doc-an-sum-an-uchet},
                                                      input bf_fin-doc.fact-order,
                                                      input bf_fin-doc.fin-doc-code,
                                                      input bf_fin-doc.fact-date,
                                                      input bf_fin-doc.curr-code,
                                                      input bf_sysconf.base-code,
                                                      input varcurr-dog-code,
                                                      input varrel-dog-code,
                                                      input varznaksum-doc      ,
                                                      input varznaksum-rubl     ,
                                                      input varznaksum-base     ,
                                                      input varznaksum-contr    ,
                                                      input varznaksum-vat-doc  ,
                                                      input varznaksum-vat-rubl ,
                                                      input varznaksum-vat-base ,
                                                      input varznaksum-vat-contr,
                                                      input varznaksum-slt-doc  ,
                                                      input varznaksum-slt-rubl ,
                                                      input varznaksum-slt-base ,
                                                      input varznaksum-slt-contr
                                                      ).
      /*Итоговая в разрезе счета по коду целевого назначения*/
      if bf_sysconf.firm-db-num = v-curr-db-num then
      run libfarhp_calc-arh-fin-doc-an in g#libfarhp (input parmode,
                                                      input bf_fin-doc.host-code,
                                                      input bf_fin-doc.payer-type,
                                                      input bf_fin-doc.payer-code,
                                                      input bf_fin-doc.receiver-type,
                                                      input bf_fin-doc.receiver-code,
                                                      input bf_fin-doc.payer-code-schet,
                                                      input bf_fin-doc.receiver-code-schet,
                                                      input bf_fin-doc.fin-ext-doc-type,
                                                      input 0,
                                                      input bf_fin-doc.cel-nazn-code,
                                                      input 0,
                                                      input {&arh-fin-doc-an-sum-cel-nazn},
                                                      input bf_fin-doc.fact-order,
                                                      input bf_fin-doc.fin-doc-code,
                                                      input bf_fin-doc.fact-date,
                                                      input bf_fin-doc.curr-code,
                                                      input bf_sysconf.base-code,
                                                      input varcurr-dog-code,
                                                      input varrel-dog-code,
                                                      input varznaksum-doc      ,
                                                      input varznaksum-rubl     ,
                                                      input varznaksum-base     ,
                                                      input varznaksum-contr    ,
                                                      input varznaksum-vat-doc  ,
                                                      input varznaksum-vat-rubl ,
                                                      input varznaksum-vat-base ,
                                                      input varznaksum-vat-contr,
                                                      input varznaksum-slt-doc  ,
                                                      input varznaksum-slt-rubl ,
                                                      input varznaksum-slt-base ,
                                                      input varznaksum-slt-contr
                                                      ).
      /*Итоговая в разрезе счета по корреспондирующему счету*/
      if bf_sysconf.firm-db-num = v-curr-db-num then
      run libfarhp_calc-arh-fin-doc-an in g#libfarhp (input parmode,
                                                      input bf_fin-doc.host-code,
                                                      input bf_fin-doc.payer-type,
                                                      input bf_fin-doc.payer-code,
                                                      input bf_fin-doc.receiver-type,
                                                      input bf_fin-doc.receiver-code,
                                                      input bf_fin-doc.payer-code-schet,
                                                      input bf_fin-doc.receiver-code-schet,
                                                      input bf_fin-doc.fin-ext-doc-type,
                                                      input 0,
                                                      input 0,
                                                      input bf_fin-doc.cor-acc,
                                                      input {&arh-fin-doc-an-sum-cor-acc},
                                                      input bf_fin-doc.fact-order,
                                                      input bf_fin-doc.fin-doc-code,
                                                      input bf_fin-doc.fact-date,
                                                      input bf_fin-doc.curr-code,
                                                      input bf_sysconf.base-code,
                                                      input varcurr-dog-code,
                                                      input varrel-dog-code,
                                                      input varznaksum-doc      ,
                                                      input varznaksum-rubl     ,
                                                      input varznaksum-base     ,
                                                      input varznaksum-contr    ,
                                                      input varznaksum-vat-doc  ,
                                                      input varznaksum-vat-rubl ,
                                                      input varznaksum-vat-base ,
                                                      input varznaksum-vat-contr,
                                                      input varznaksum-slt-doc  ,
                                                      input varznaksum-slt-rubl ,
                                                      input varznaksum-slt-base ,
                                                      input varznaksum-slt-contr
                                                      ).
    end. /* if pararh-name = "all":u                        or
           lookup ({&table_arh-fin-doc-an"}, pararh-name) > 0 then do:  */
  end. /*if v-is-cashless then do:*/
    /*РКО, ПКО(нал)*/
    else do:
    if pararh-name = "all":u                        or
    lookup ({&table_arh-fin-doc-an-nal}, pararh-name) > 0 then do:
      if bf_sysconf.firm-db-num = v-curr-db-num and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input (if v-is-income then bf_fin-doc.cor-acc1 else bf_fin-doc.cor-acc ),
                                                        input (if v-is-income then bf_fin-doc.cor-acc  else bf_fin-doc.cor-acc1),
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input bf_fin-doc.an-uchet-code,
                                                        input bf_fin-doc.cel-nazn-code,
                                                        input bf_fin-doc.cor-acc,
                                                        input {&arh-fin-doc-an-nal-atom},
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input bf_fin-doc.curr-code,
                                                        input bf_sysconf.base-code,
                                                        input varcurr-dog-code,
                                                        input varrel-dog-code,
                                                        input varznaksum-doc      ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-contr    ,
                                                        input varznaksum-vat-doc  ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-contr,
                                                        input varznaksum-slt-doc  ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-contr
                                                        ).
      if bf_sysconf.firm-db-num = v-curr-db-num and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input (if v-is-income then bf_fin-doc.cor-acc1 else bf_fin-doc.cor-acc ),
                                                        input (if v-is-income then bf_fin-doc.cor-acc  else bf_fin-doc.cor-acc1),
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input bf_fin-doc.an-uchet-code,
                                                        input bf_fin-doc.cel-nazn-code,
                                                        input bf_fin-doc.cor-acc,
                                                        input {&arh-fin-doc-an-nal-sum-rubl},
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input 0,
                                                        input bf_sysconf.base-code,
                                                        input 0,
                                                        input varrel-dog-code,
                                                        input varznaksum-rubl     ,  /*не учитываем валюту платежа*/
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-rubl
                                                        ).

      /*суммарная без учета валюты платежа*/
      if bf_sysconf.firm-db-num = v-curr-db-num and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input (if v-is-income then bf_fin-doc.cor-acc1 else bf_fin-doc.cor-acc ),
                                                        input (if v-is-income then bf_fin-doc.cor-acc  else bf_fin-doc.cor-acc1),
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input bf_fin-doc.an-uchet-code,
                                                        input bf_fin-doc.cel-nazn-code,
                                                        input bf_fin-doc.cor-acc,
                                                        input {&arh-fin-doc-an-nal-sum-base},
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input bf_sysconf.base-code,
                                                        input bf_sysconf.base-code,
                                                        input bf_sysconf.base-code,
                                                        input varrel-dog-code,
                                                        input varznaksum-base     ,  /*не учитываем валюту платежа*/
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-base
                                                        ).
      /*Суммарная без учета кодов и счетов*/
      if bf_sysconf.firm-db-num = v-curr-db-num and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input 0,
                                                        input 0,
                                                        input 0,
                                                        input {&arh-fin-doc-an-nal-without-schet},
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input 0,
                                                        input bf_sysconf.base-code,
                                                        input varcurr-dog-code,
                                                        input varrel-dog-code,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-contr    ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-contr,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-contr
                                                        ).
      /*Итоговая по коду аналитического учета*/
      if bf_sysconf.firm-db-num = v-curr-db-num  and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input bf_fin-doc.an-uchet-code,
                                                        input 0,
                                                        input 0,
                                                        input {&arh-fin-doc-an-nal-sum-an-uchet},
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input bf_fin-doc.curr-code,
                                                        input bf_sysconf.base-code,
                                                        input varcurr-dog-code,
                                                        input varrel-dog-code,
                                                        input varznaksum-doc      ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-contr    ,
                                                        input varznaksum-vat-doc  ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-contr,
                                                        input varznaksum-slt-doc  ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-contr
                                                       ).
      if bf_sysconf.firm-db-num = v-curr-db-num  and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input bf_fin-doc.an-uchet-code,
                                                        input 0,
                                                        input 0,
                                                        input {&arh-fin-doc-an-nal-sum-rubl-an-uchet},
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input 0,
                                                        input bf_sysconf.base-code,
                                                        input varcurr-dog-code,
                                                        input varrel-dog-code,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-contr    ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-contr,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-contr
                                                       ).

      /*Итоговая по коду целевого назначения*/
      if bf_sysconf.firm-db-num = v-curr-db-num  and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input 0,
                                                        input bf_fin-doc.cel-nazn-code,
                                                        input 0,
                                                        input {&arh-fin-doc-an-nal-sum-cel-nazn},
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input bf_fin-doc.curr-code,
                                                        input bf_sysconf.base-code,
                                                        input varcurr-dog-code,
                                                        input varrel-dog-code,
                                                        input varznaksum-doc      ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-contr    ,
                                                        input varznaksum-vat-doc  ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-contr,
                                                        input varznaksum-slt-doc  ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-contr
                                                        ).
      if bf_sysconf.firm-db-num = v-curr-db-num and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input 0,
                                                        input bf_fin-doc.cel-nazn-code,
                                                        input 0,
                                                        input {&arh-fin-doc-an-nal-sum-rubl-cel-nazn},
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input 0,
                                                        input bf_sysconf.base-code,
                                                        input varcurr-dog-code,
                                                        input varrel-dog-code,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-contr    ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-contr,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-contr
                                                        ).

      /*Итоговая по корреспондирующему счету*/
     if bf_sysconf.firm-db-num = v-curr-db-num and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.cor-acc,
                                                        input {&arh-fin-doc-an-nal-sum-cor-acc},
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input bf_fin-doc.curr-code,
                                                        input bf_sysconf.base-code,
                                                        input varcurr-dog-code,
                                                        input varrel-dog-code,
                                                        input varznaksum-doc      ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-contr    ,
                                                        input varznaksum-vat-doc  ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-contr,
                                                        input varznaksum-slt-doc  ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-contr
                                                        ).
      if bf_sysconf.firm-db-num = v-curr-db-num and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.cor-acc,
                                                        input {&arh-fin-doc-an-nal-sum-rubl-cor-acc},
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input 0,
                                                        input bf_sysconf.base-code,
                                                        input varcurr-dog-code,
                                                        input varrel-dog-code,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-contr    ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-contr,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-contr
                                                        ).

      /*Итоговая по коду аналитического учета без учета валюты платежа*/
      if bf_sysconf.firm-db-num = v-curr-db-num and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input bf_fin-doc.an-uchet-code,
                                                        input 0,
                                                        input 0,
                                                        input {&arh-fin-doc-an-nal-sum-base-an-uchet},
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input bf_sysconf.base-code,
                                                        input bf_sysconf.base-code,
                                                        input bf_sysconf.base-code,
                                                        input varrel-dog-code,
                                                        input varznaksum-base     ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-base
                                                        ).
      /*Итоговая по коду целевого назначения без учета валюты платежа*/
      if bf_sysconf.firm-db-num = v-curr-db-num and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input 0,
                                                        input bf_fin-doc.cel-nazn-code,
                                                        input 0,
                                                        input {&arh-fin-doc-an-nal-sum-base-cel-nazn},
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input bf_sysconf.base-code,
                                                        input bf_sysconf.base-code,
                                                        input bf_sysconf.base-code,
                                                        input varrel-dog-code     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-base
                                                        ).
      /*Итоговая по корреспондирующему счету без учета валюты платежа*/
      if bf_sysconf.firm-db-num = v-curr-db-num and  v-curr-db-num = v-obj-db-num then
      run libfarhp_calc-arh-fin-doc-an-n in g#libfarhp (input parmode,
                                                        input bf_fin-doc.host-code,
                                                        input bf_fin-doc.payer-type,
                                                        input bf_fin-doc.payer-code,
                                                        input bf_fin-doc.receiver-type,
                                                        input bf_fin-doc.receiver-code,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.fin-ext-doc-type,
                                                        input 0,
                                                        input 0,
                                                        input bf_fin-doc.cor-acc,
                                                        input {&arh-fin-doc-an-nal-sum-base-cor-acc},
                                                        input bf_fin-doc.fact-order,
                                                        input bf_fin-doc.fin-doc-code,
                                                        input bf_fin-doc.fact-date,
                                                        input bf_sysconf.base-code,
                                                        input bf_sysconf.base-code,
                                                        input bf_sysconf.base-code,
                                                        input varrel-dog-code,
                                                        input varznaksum-base     ,
                                                        input varznaksum-rubl     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-base     ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-rubl ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-vat-base ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-rubl ,
                                                        input varznaksum-slt-base ,
                                                        input varznaksum-slt-base
                                                        ).
    end. /* if pararh-name = "all":u                        or
            lookup ({&table_arh-fin-doc-an-nal}, pararh-name) > 0 then do:*/
  end. /*else if v-is cashless*/
    if v-is-cashless then do:
    if (pararh-name = "all":u                               or
    lookup ({&table_arh-fin-doc-contr-schet}, pararh-name) > 0) and  v-curr-db-num = v-obj-db-num then do:
      if bf_sysconf.firm-db-num = v-curr-db-num then
      run libfarhp_calc-arh-fin-doc-contr-schet in g#libfarhp (input parmode,
                                                               input bf_fin-doc.host-code,
                                                               input bf_fin-doc.payer-type,
                                                               input bf_fin-doc.payer-code,
                                                               input bf_fin-doc.receiver-type,
                                                               input bf_fin-doc.receiver-code,
                                                               input bf_fin-doc.payer-code-schet,
                                                               input bf_fin-doc.receiver-code-schet,
                                                               input bf_fin-doc.fin-ext-doc-type,
                                                               input {&arh-fin-doc-contr-schet-atom},
                                                               input bf_fin-doc.fact-order,
                                                               input bf_fin-doc.fin-doc-code,
                                                               input bf_fin-doc.fact-date,
                                                               input bf_fin-doc.curr-code,
                                                               input bf_sysconf.base-code,
                                                               input varcurr-dog-code,
                                                               input varrel-dog-code,
                                                               input (if available bf_contract then bf_contract.contract-code else 0),
                                                               input varznaksum-doc      ,
                                                               input varznaksum-rubl     ,
                                                               input varznaksum-base     ,
                                                               input varznaksum-contr    ,
                                                               input varznaksum-vat-doc  ,
                                                               input varznaksum-vat-rubl ,
                                                               input varznaksum-vat-base ,
                                                               input varznaksum-vat-contr,
                                                               input varznaksum-slt-doc  ,
                                                               input varznaksum-slt-rubl ,
                                                               input varznaksum-slt-base ,
                                                               input varznaksum-slt-contr
                                                               ).
    end. /* if pararh-name = "all":u                               or
          lookup ({&table_arh-fin-doc-contr-schet}, pararh-name) > 0  then do:  */
      if bf_sysconf.fin-calc = {&fin-calc-obj} then do:
      if pararh-name = "all":u                               or
      lookup ({&table_arh-fin-doc-contr-schet-obj}, pararh-name) > 0  then do:
        if varhave-connect = no then do:
          run libfarpo_calc-arh-fin-doc-contr-schet-obj in g#libfarpo (input parmode,
                                                                       input bf_fin-doc.host-code,
                                                                       input bf_fin-doc.obj-type,
                                                                       input bf_fin-doc.obj-code,
                                                                       input bf_fin-doc.payer-type,
                                                                       input bf_fin-doc.payer-code,
                                                                       input bf_fin-doc.receiver-type,
                                                                       input bf_fin-doc.receiver-code,
                                                                       input bf_fin-doc.payer-code-schet,
                                                                       input bf_fin-doc.receiver-code-schet,
                                                                       input bf_fin-doc.fin-ext-doc-type,
                                                                       input {&arh-fin-doc-contr-schet-obj-atom},
                                                                       input bf_fin-doc.fact-order,
                                                                       input bf_fin-doc.fin-doc-code,
                                                                       input bf_fin-doc.fact-date,
                                                                       input bf_fin-doc.curr-code,
                                                                       input bf_sysconf.base-code,
                                                                       input varcurr-dog-code,
                                                                       input varrel-dog-code,
                                                                       input (if available bf_contract then bf_contract.contract-code else 0),
                                                                       input varznaksum-doc      ,
                                                                       input varznaksum-rubl     ,
                                                                       input varznaksum-base     ,
                                                                       input varznaksum-contr    ,
                                                                       input varznaksum-vat-doc  ,
                                                                       input varznaksum-vat-rubl ,
                                                                       input varznaksum-vat-base ,
                                                                       input varznaksum-vat-contr,
                                                                       input varznaksum-slt-doc  ,
                                                                       input varznaksum-slt-rubl ,
                                                                       input varznaksum-slt-base ,
                                                                       input varznaksum-slt-contr
                                                                       ).
        end. /*if varhave-connect = no then do:*/
        else do:
          for each tt-sum-con-fin-ob-obj on error undo, return error return-value :
            run libfarpo_calc-arh-fin-doc-contr-schet-obj in g#libfarpo (input parmode,
                                                                         input bf_fin-doc.host-code,
                                                                         input tt-sum-con-fin-ob-obj.obj-type,
                                                                         input tt-sum-con-fin-ob-obj.obj-code,
                                                                         input bf_fin-doc.payer-type,
                                                                         input bf_fin-doc.payer-code,
                                                                         input bf_fin-doc.receiver-type,
                                                                         input bf_fin-doc.receiver-code,
                                                                         input bf_fin-doc.payer-code-schet,
                                                                         input bf_fin-doc.receiver-code-schet,
                                                                         input bf_fin-doc.fin-ext-doc-type,
                                                                         input {&arh-fin-doc-contr-schet-obj-atom},
                                                                         input bf_fin-doc.fact-order,
                                                                         input bf_fin-doc.fin-doc-code,
                                                                         input bf_fin-doc.fact-date,
                                                                         input bf_fin-doc.curr-code,
                                                                         input bf_sysconf.base-code,
                                                                         input varcurr-dog-code,
                                                                         input varrel-dog-code,
                                                                         input (if available bf_contract then bf_contract.contract-code else 0),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-doc       else - tt-sum-con-fin-ob-obj.sum-doc       ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-rubl      else - tt-sum-con-fin-ob-obj.sum-rubl      ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-base      else - tt-sum-con-fin-ob-obj.sum-base      ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-contr     else - tt-sum-con-fin-ob-obj.sum-contr     ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-doc   else - tt-sum-con-fin-ob-obj.sum-vat-doc   ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-rubl  else - tt-sum-con-fin-ob-obj.sum-vat-rubl  ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-base  else - tt-sum-con-fin-ob-obj.sum-vat-base  ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-contr else - tt-sum-con-fin-ob-obj.sum-vat-contr ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-doc   else - tt-sum-con-fin-ob-obj.sum-slt-doc   ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-rubl  else - tt-sum-con-fin-ob-obj.sum-slt-rubl  ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-base  else - tt-sum-con-fin-ob-obj.sum-slt-base  ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-contr else - tt-sum-con-fin-ob-obj.sum-slt-contr )
                                                                         ).
          end. /*for each*/
        end.  /*else if varhave-connect = no then do:*/
      end. /* if pararh-name = "all":u                               or
              lookup ({&table_arh-fin-doc-contr-schet-obj}, pararh-name) > 0  then do: */
    end. /*if bf_sysconf.fin-calc = {&fin-calc-obj} then do:*/
      /*итоговая по договору*/
    if (pararh-name = "all":u                               or
    lookup ({&table_arh-fin-doc-contr-schet}, pararh-name) > 0)  and  v-curr-db-num = v-obj-db-num then do:
      if bf_sysconf.firm-db-num = v-curr-db-num then
      run libfarhp_calc-arh-fin-doc-contr-schet in g#libfarhp (input parmode,
                                                               input bf_fin-doc.host-code,
                                                               input bf_fin-doc.payer-type,
                                                               input bf_fin-doc.payer-code,
                                                               input bf_fin-doc.receiver-type,
                                                               input bf_fin-doc.receiver-code,
                                                               input 0,
                                                               input 0,
                                                               input bf_fin-doc.fin-ext-doc-type,
                                                               input {&arh-fin-doc-contr-schet-sum-contract},
                                                               input bf_fin-doc.fact-order,
                                                               input bf_fin-doc.fin-doc-code,
                                                               input bf_fin-doc.fact-date,
                                                               input 0,
                                                               input bf_sysconf.base-code,
                                                               input varcurr-dog-code,
                                                               input varrel-dog-code,
                                                               input (if available bf_contract then bf_contract.contract-code else 0),
                                                               input varznaksum-rubl     , /*так как опускаем валюту договора и используем р_у_б_л_и */
                                                               input varznaksum-rubl     ,
                                                               input varznaksum-base     ,
                                                               input varznaksum-contr    ,
                                                               input varznaksum-vat-rubl ,
                                                               input varznaksum-vat-rubl ,
                                                               input varznaksum-vat-base ,
                                                               input varznaksum-vat-contr,
                                                               input varznaksum-slt-rubl ,
                                                               input varznaksum-slt-rubl ,
                                                               input varznaksum-slt-base ,
                                                               input varznaksum-slt-contr
                                                               ).
    end. /*  if pararh-name = "all":u                               or
             lookup ({&table_arh-fin-doc-contr-schet}, pararh-name) > 0  then do: */
      if bf_sysconf.fin-calc = {&fin-calc-obj} then do:
      if pararh-name = "all":u                               or
      lookup ({&table_arh-fin-doc-contr-schet-obj}, pararh-name) > 0  then do:
        if varhave-connect = no then do:
          run libfarpo_calc-arh-fin-doc-contr-schet-obj in g#libfarpo (input parmode,
                                                                       input bf_fin-doc.host-code,
                                                                       input bf_fin-doc.obj-type,
                                                                       input bf_fin-doc.obj-code,
                                                                       input bf_fin-doc.payer-type,
                                                                       input bf_fin-doc.payer-code,
                                                                       input bf_fin-doc.receiver-type,
                                                                       input bf_fin-doc.receiver-code,
                                                                       input 0,
                                                                       input 0,
                                                                       input bf_fin-doc.fin-ext-doc-type,
                                                                       input {&arh-fin-doc-contr-schet-obj-sum-contract},
                                                                       input bf_fin-doc.fact-order,
                                                                       input bf_fin-doc.fin-doc-code,
                                                                       input bf_fin-doc.fact-date,
                                                                       input 0,
                                                                       input bf_sysconf.base-code,
                                                                       input varcurr-dog-code,
                                                                       input varrel-dog-code,
                                                                       input (if available bf_contract then bf_contract.contract-code else 0),
                                                                       input varznaksum-rubl     , /*так как опускаем валюту договора и используем р_у_б_л_и*/
                                                                       input varznaksum-rubl     ,
                                                                       input varznaksum-base     ,
                                                                       input varznaksum-contr    ,
                                                                       input varznaksum-vat-rubl ,
                                                                       input varznaksum-vat-rubl ,
                                                                       input varznaksum-vat-base ,
                                                                       input varznaksum-vat-contr,
                                                                       input varznaksum-slt-rubl ,
                                                                       input varznaksum-slt-rubl ,
                                                                       input varznaksum-slt-base ,
                                                                       input varznaksum-slt-contr
                                                                       ).
        end. /*if varhave-connect = no then do:*/
        else do:
          for each tt-sum-con-fin-ob-obj on error undo, return error return-value :
            run libfarpo_calc-arh-fin-doc-contr-schet-obj in g#libfarpo (input parmode,
                                                                         input bf_fin-doc.host-code,
                                                                         input tt-sum-con-fin-ob-obj.obj-type,
                                                                         input tt-sum-con-fin-ob-obj.obj-code,
                                                                         input bf_fin-doc.payer-type,
                                                                         input bf_fin-doc.payer-code,
                                                                         input bf_fin-doc.receiver-type,
                                                                         input bf_fin-doc.receiver-code,
                                                                         input 0,
                                                                         input 0,
                                                                         input bf_fin-doc.fin-ext-doc-type,
                                                                         input {&arh-fin-doc-contr-schet-obj-sum-contract},
                                                                         input bf_fin-doc.fact-order,
                                                                         input bf_fin-doc.fin-doc-code,
                                                                         input bf_fin-doc.fact-date,
                                                                         input 0,
                                                                         input bf_sysconf.base-code,
                                                                         input varcurr-dog-code,
                                                                         input varrel-dog-code,
                                                                         input (if available bf_contract then bf_contract.contract-code else 0),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-rubl      else - tt-sum-con-fin-ob-obj.sum-rubl      ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-rubl      else - tt-sum-con-fin-ob-obj.sum-rubl      ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-base      else - tt-sum-con-fin-ob-obj.sum-base      ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-contr     else - tt-sum-con-fin-ob-obj.sum-contr     ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-rubl  else - tt-sum-con-fin-ob-obj.sum-vat-rubl  ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-rubl  else - tt-sum-con-fin-ob-obj.sum-vat-rubl  ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-base  else - tt-sum-con-fin-ob-obj.sum-vat-base  ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-contr else - tt-sum-con-fin-ob-obj.sum-vat-contr ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-rubl  else - tt-sum-con-fin-ob-obj.sum-slt-rubl  ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-rubl  else - tt-sum-con-fin-ob-obj.sum-slt-rubl  ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-base  else - tt-sum-con-fin-ob-obj.sum-slt-base  ),
                                                                         input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-contr else - tt-sum-con-fin-ob-obj.sum-slt-contr )
                                                                         ).
          end. /*for each tt-sum-con-fin-ob-obj on error undo, return error return-value :*/
        end. /*else if varhave-connect = no then do:*/
      end. /* if pararh-name = "all":u                               or
              lookup ({&table_arh-fin-doc-contr-schet-obj}, pararh-name) > 0  then do:   */
    end. /*if bf_sysconf.fin-calc = {&fin-calc-obj} then do:*/
  end. /*if v-is-cashless then do:*/
    else do:
    if (pararh-name = "all":u                               or
    lookup ({&table_arh-fin-doc-contr-schet-nal}, pararh-name) > 0 ) and  v-curr-db-num = v-obj-db-num  then do:
      if bf_sysconf.firm-db-num = v-curr-db-num then
      run libfarhp_calc-arh-fin-doc-contr-schet-n in g#libfarhp (input parmode,
                                                                 input bf_fin-doc.host-code,
                                                                 input bf_fin-doc.payer-type,
                                                                 input bf_fin-doc.payer-code,
                                                                 input bf_fin-doc.receiver-type,
                                                                 input bf_fin-doc.receiver-code,
                                                                 input (if v-is-income then bf_fin-doc.cor-acc1 else bf_fin-doc.cor-acc ),
                                                                 input (if v-is-income then bf_fin-doc.cor-acc  else bf_fin-doc.cor-acc1),
                                                                 input bf_fin-doc.fin-ext-doc-type,
                                                                 input {&arh-fin-doc-contr-schet-nal-atom},
                                                                 input bf_fin-doc.fact-order,
                                                                 input bf_fin-doc.fin-doc-code,
                                                                 input bf_fin-doc.fact-date,
                                                                 input bf_fin-doc.curr-code,
                                                                 input bf_fin-doc.cashbookid,
                                                                 input bf_sysconf.base-code,
                                                                 input varcurr-dog-code,
                                                                 input varrel-dog-code,
                                                                 input (if available bf_contract then bf_contract.contract-code else 0),
                                                                 input varznaksum-doc      ,
                                                                 input varznaksum-rubl     ,
                                                                 input varznaksum-base     ,
                                                                 input varznaksum-contr    ,
                                                                 input varznaksum-vat-doc  ,
                                                                 input varznaksum-vat-rubl ,
                                                                 input varznaksum-vat-base ,
                                                                 input varznaksum-vat-contr,
                                                                 input varznaksum-slt-doc  ,
                                                                 input varznaksum-slt-rubl ,
                                                                 input varznaksum-slt-base ,
                                                                 input varznaksum-slt-contr
                                                                 ).
    end. /*if pararh-name = "all":u                               or
            lookup ({&table_arh-fin-doc-contr-schet-nal}, pararh-name) > 0  then do:  */
      if bf_sysconf.fin-calc = {&fin-calc-obj} then do:
      if pararh-name = "all":u                               or
      lookup ({&table_arh-fin-doc-contr-s-nal-obj}, pararh-name) > 0  then do:
        if varhave-connect = no then do:
          run libfarpo_calc-arh-fin-doc-contr-schet-n-obj in g#libfarpo (input parmode,
                                                                         input bf_fin-doc.host-code,
                                                                         input bf_fin-doc.obj-type,
                                                                         input bf_fin-doc.obj-code,
                                                                         input bf_fin-doc.payer-type,
                                                                         input bf_fin-doc.payer-code,
                                                                         input bf_fin-doc.receiver-type,
                                                                         input bf_fin-doc.receiver-code,
                                                                         input (if v-is-income then bf_fin-doc.cor-acc1 else bf_fin-doc.cor-acc ),
                                                                         input (if v-is-income then bf_fin-doc.cor-acc  else bf_fin-doc.cor-acc1),
                                                                         input bf_fin-doc.fin-ext-doc-type,
                                                                         input {&arh-fin-doc-contr-s-nal-obj-atom},
                                                                         input bf_fin-doc.fact-order,
                                                                         input bf_fin-doc.fin-doc-code,
                                                                         input bf_fin-doc.fact-date,
                                                                         input bf_fin-doc.curr-code,
                                                                         input bf_sysconf.base-code,
                                                                         input varcurr-dog-code,
                                                                         input varrel-dog-code,
                                                                         input (if available bf_contract then bf_contract.contract-code else 0),
                                                                         input varznaksum-doc      ,
                                                                         input varznaksum-rubl     ,
                                                                         input varznaksum-base     ,
                                                                         input varznaksum-contr    ,
                                                                         input varznaksum-vat-doc  ,
                                                                         input varznaksum-vat-rubl ,
                                                                         input varznaksum-vat-base ,
                                                                         input varznaksum-vat-contr,
                                                                         input varznaksum-slt-doc  ,
                                                                         input varznaksum-slt-rubl ,
                                                                         input varznaksum-slt-base ,
                                                                         input varznaksum-slt-contr
                                                                         ).
        end.
        else do:
          for each tt-sum-con-fin-ob-obj on error undo, return error return-value :
            run libfarpo_calc-arh-fin-doc-contr-schet-n-obj in g#libfarpo (input parmode,
                                                                           input bf_fin-doc.host-code,
                                                                           input tt-sum-con-fin-ob-obj.obj-type,
                                                                           input tt-sum-con-fin-ob-obj.obj-code,
                                                                           input bf_fin-doc.payer-type,
                                                                           input bf_fin-doc.payer-code,
                                                                           input bf_fin-doc.receiver-type,
                                                                           input bf_fin-doc.receiver-code,
                                                                           input (if v-is-income then bf_fin-doc.cor-acc1 else bf_fin-doc.cor-acc ),
                                                                           input (if v-is-income then bf_fin-doc.cor-acc  else bf_fin-doc.cor-acc1),
                                                                           input bf_fin-doc.fin-ext-doc-type,
                                                                           input {&arh-fin-doc-contr-s-nal-obj-atom},
                                                                           input bf_fin-doc.fact-order,
                                                                           input bf_fin-doc.fin-doc-code,
                                                                           input bf_fin-doc.fact-date,
                                                                           input bf_fin-doc.curr-code,
                                                                           input bf_sysconf.base-code,
                                                                           input varcurr-dog-code,
                                                                           input varrel-dog-code,
                                                                           input (if available bf_contract then bf_contract.contract-code else 0),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-doc       else - tt-sum-con-fin-ob-obj.sum-doc       ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-rubl      else - tt-sum-con-fin-ob-obj.sum-rubl      ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-base      else - tt-sum-con-fin-ob-obj.sum-base      ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-contr     else - tt-sum-con-fin-ob-obj.sum-contr     ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-doc   else - tt-sum-con-fin-ob-obj.sum-vat-doc   ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-rubl  else - tt-sum-con-fin-ob-obj.sum-vat-rubl  ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-base  else - tt-sum-con-fin-ob-obj.sum-vat-base  ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-contr else - tt-sum-con-fin-ob-obj.sum-vat-contr ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-doc   else - tt-sum-con-fin-ob-obj.sum-slt-doc   ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-rubl  else - tt-sum-con-fin-ob-obj.sum-slt-rubl  ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-base  else - tt-sum-con-fin-ob-obj.sum-slt-base  ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-contr else - tt-sum-con-fin-ob-obj.sum-slt-contr )
                                                                           ).
          end.
        end. /*else if varhave-connect*/
      end. /*  if pararh-name = "all":u                               or
              lookup ({&table_arh-fin-doc-contr-s-nal-obj}, pararh-name) > 0  then do:     */
    end. /*if bf_sysconf.fin-calc = {&fin-calc-obj} then do:*/
    if (pararh-name = "all":u                       or
    lookup ({&table_arh-fin-doc-contr-schet-nal}, pararh-name) > 0) and  v-curr-db-num = v-obj-db-num then do:
      if bf_sysconf.firm-db-num = v-curr-db-num then
      run libfarhp_calc-arh-fin-doc-contr-schet-n in g#libfarhp (input parmode,
                                                                 input bf_fin-doc.host-code,
                                                                 input bf_fin-doc.payer-type,
                                                                 input bf_fin-doc.payer-code,
                                                                 input bf_fin-doc.receiver-type,
                                                                 input bf_fin-doc.receiver-code,
                                                                 input 0,
                                                                 input 0,
                                                                 input bf_fin-doc.fin-ext-doc-type,
                                                                 input {&arh-fin-doc-contr-schet-nal-sum-contract},
                                                                 input bf_fin-doc.fact-order,
                                                                 input bf_fin-doc.fin-doc-code,
                                                                 input bf_fin-doc.fact-date,
                                                                 input 0,
                                                                 input bf_sysconf.base-code,
                                                                 input varcurr-dog-code,
                                                                 input varrel-dog-code,
                                                                 input (if available bf_contract then bf_contract.contract-code else 0),
                                                                 input varznaksum-rubl     ,
                                                                 input varznaksum-rubl     ,
                                                                 input varznaksum-base     ,
                                                                 input varznaksum-contr    ,
                                                                 input varznaksum-vat-rubl ,
                                                                 input varznaksum-vat-rubl ,
                                                                 input varznaksum-vat-base ,
                                                                 input varznaksum-vat-contr,
                                                                 input varznaksum-slt-rubl ,
                                                                 input varznaksum-slt-rubl ,
                                                                 input varznaksum-slt-base ,
                                                                 input varznaksum-slt-contr
                                                                 ).
    end.
      if bf_sysconf.fin-calc = {&fin-calc-obj} then do:
      if pararh-name = "all":u                               or
      lookup ({&table_arh-fin-doc-contr-s-nal-obj}, pararh-name) > 0  then do:
        if varhave-connect = no then do:
          run libfarpo_calc-arh-fin-doc-contr-schet-n-obj in g#libfarpo (input parmode,
                                                                         input bf_fin-doc.host-code,
                                                                         input bf_fin-doc.obj-type,
                                                                         input bf_fin-doc.obj-code,
                                                                         input bf_fin-doc.payer-type,
                                                                         input bf_fin-doc.payer-code,
                                                                         input bf_fin-doc.receiver-type,
                                                                         input bf_fin-doc.receiver-code,
                                                                         input 0,
                                                                         input 0,
                                                                         input bf_fin-doc.fin-ext-doc-type,
                                                                         input {&arh-fin-doc-contr-s-nal-obj-sum-contract} ,
                                                                         input bf_fin-doc.fact-order,
                                                                         input bf_fin-doc.fin-doc-code,
                                                                         input bf_fin-doc.fact-date,
                                                                         input 0,
                                                                         input bf_sysconf.base-code,
                                                                         input varcurr-dog-code,
                                                                         input varrel-dog-code,
                                                                         input (if available bf_contract then bf_contract.contract-code else 0),
                                                                         input varznaksum-rubl     ,
                                                                         input varznaksum-rubl     ,
                                                                         input varznaksum-base     ,
                                                                         input varznaksum-contr    ,
                                                                         input varznaksum-vat-rubl ,
                                                                         input varznaksum-vat-rubl ,
                                                                         input varznaksum-vat-base ,
                                                                         input varznaksum-vat-contr,
                                                                         input varznaksum-slt-rubl ,
                                                                         input varznaksum-slt-rubl ,
                                                                         input varznaksum-slt-base ,
                                                                         input varznaksum-slt-contr
                                                                         ).
        end. /*if varhave-connect = no then do:*/
        else do:
          for each tt-sum-con-fin-ob-obj on error undo, return error return-value :
            run libfarpo_calc-arh-fin-doc-contr-schet-n-obj in g#libfarpo (input parmode,
                                                                           input bf_fin-doc.host-code,
                                                                           input tt-sum-con-fin-ob-obj.obj-type,
                                                                           input tt-sum-con-fin-ob-obj.obj-code,
                                                                           input bf_fin-doc.payer-type,
                                                                           input bf_fin-doc.payer-code,
                                                                           input bf_fin-doc.receiver-type,
                                                                           input bf_fin-doc.receiver-code,
                                                                           input 0,
                                                                           input 0,
                                                                           input bf_fin-doc.fin-ext-doc-type,
                                                                           input {&arh-fin-doc-contr-s-nal-obj-sum-contract},
                                                                           input bf_fin-doc.fact-order,
                                                                           input bf_fin-doc.fin-doc-code,
                                                                           input bf_fin-doc.fact-date,
                                                                           input 0,
                                                                           input bf_sysconf.base-code,
                                                                           input varcurr-dog-code,
                                                                           input varrel-dog-code,
                                                                           input (if available bf_contract then bf_contract.contract-code else 0),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-rubl      else - tt-sum-con-fin-ob-obj.sum-rubl      ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-rubl      else - tt-sum-con-fin-ob-obj.sum-rubl      ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-base      else - tt-sum-con-fin-ob-obj.sum-base      ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-contr     else - tt-sum-con-fin-ob-obj.sum-contr     ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-rubl  else - tt-sum-con-fin-ob-obj.sum-vat-rubl  ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-rubl  else - tt-sum-con-fin-ob-obj.sum-vat-rubl  ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-base  else - tt-sum-con-fin-ob-obj.sum-vat-base  ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-vat-contr else - tt-sum-con-fin-ob-obj.sum-vat-contr ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-rubl  else - tt-sum-con-fin-ob-obj.sum-slt-rubl  ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-rubl  else - tt-sum-con-fin-ob-obj.sum-slt-rubl  ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-base  else - tt-sum-con-fin-ob-obj.sum-slt-base  ),
                                                                           input (if parmode = "close":u then tt-sum-con-fin-ob-obj.sum-slt-contr else - tt-sum-con-fin-ob-obj.sum-slt-contr )
                                                                           ).
          end.
        end. /*else if varhave-connect = no then do:*/
      end. /*if pararh-name = "all":u                               or
            lookup ({&table_arh-fin-doc-contr-s-nal-obj}, pararh-name) > 0  then do:*/
    end. /*if bf_sysconf.fin-calc = {&fin-calc-obj} then do:*/
  end. /*else if v-is-cashless then do:*/
  if pararh-name = "all":u                                     or
  lookup ({&table_arh-fin-doc-contr-schet-tax}, pararh-name) > 0 or
  lookup ({&table_arh-fin-doc-contr-s-tax-obj}, pararh-name) > 0 or
  lookup ({&table_arh-fin-doc-c-schet-tax-nal}, pararh-name) > 0 or
  lookup ({&table_arh-fin-doc-c-s-tax-nal-obj}, pararh-name) > 0 then do:
    for each tt-sum-fin-doc-tax on error undo, return error return-value :
      delete tt-sum-fin-doc-tax.
    end.
    for each bf_fin-doc-tax where bf_fin-doc-tax.host-code    = bf_fin-doc.host-code    and
                                  bf_fin-doc-tax.fin-doc-code = bf_fin-doc.fin-doc-code
                                  break by bf_fin-doc-tax.host-code by bf_fin-doc-tax.fin-doc-code by round(bf_fin-doc-tax.vat-pc, 0) by round(bf_fin-doc-tax.slt-pc, 0) by bf_fin-doc-tax.with-vat by bf_fin-doc-tax.with-slt
                                  on error undo, return error return-value :
      assign
        varfin-doc-tax-vat-pc = round(bf_fin-doc-tax.vat-pc, 0)
        varfin-doc-tax-slt-pc = round(bf_fin-doc-tax.slt-pc, 0)
      .
      if first-of (bf_fin-doc-tax.with-slt) then do:
        create tt-sum-fin-doc-tax.
        assign
          tt-sum-fin-doc-tax.vat-pc   = varfin-doc-tax-vat-pc
          tt-sum-fin-doc-tax.slt-pc   = varfin-doc-tax-slt-pc
          tt-sum-fin-doc-tax.with-vat = bf_fin-doc-tax.with-vat
          tt-sum-fin-doc-tax.with-slt = bf_fin-doc-tax.with-slt
        .
      end.
      find first tt-sum-fin-doc-tax where tt-sum-fin-doc-tax.vat-pc   = varfin-doc-tax-vat-pc   and
                                          tt-sum-fin-doc-tax.slt-pc   = varfin-doc-tax-slt-pc   and
                                          tt-sum-fin-doc-tax.with-vat = bf_fin-doc-tax.with-vat and
                                          tt-sum-fin-doc-tax.with-slt = bf_fin-doc-tax.with-slt no-error.
      assign
        tt-sum-fin-doc-tax.sum-line-doc   = tt-sum-fin-doc-tax.sum-line-doc   + bf_fin-doc-tax.sum-line-doc
        tt-sum-fin-doc-tax.sum-line-rubl  = tt-sum-fin-doc-tax.sum-line-rubl  + bf_fin-doc-tax.sum-line-rubl
        tt-sum-fin-doc-tax.sum-line-base  = tt-sum-fin-doc-tax.sum-line-base  + bf_fin-doc-tax.sum-line-base
        tt-sum-fin-doc-tax.sum-line-contr = tt-sum-fin-doc-tax.sum-line-contr + bf_fin-doc-tax.sum-line-contr
        tt-sum-fin-doc-tax.sum-vat-rubl   = tt-sum-fin-doc-tax.sum-vat-rubl   + bf_fin-doc-tax.sum-vat-line-rubl
        tt-sum-fin-doc-tax.sum-vat-base   = tt-sum-fin-doc-tax.sum-vat-base   + bf_fin-doc-tax.sum-vat-line-base
        tt-sum-fin-doc-tax.sum-vat-contr  = tt-sum-fin-doc-tax.sum-vat-contr  + bf_fin-doc-tax.sum-vat-line-contr
        tt-sum-fin-doc-tax.sum-vat-doc    = tt-sum-fin-doc-tax.sum-vat-doc    + bf_fin-doc-tax.sum-vat-line-doc
        tt-sum-fin-doc-tax.sum-slt-rubl   = tt-sum-fin-doc-tax.sum-slt-rubl   + bf_fin-doc-tax.sum-slt-line-rubl
        tt-sum-fin-doc-tax.sum-slt-base   = tt-sum-fin-doc-tax.sum-slt-base   + bf_fin-doc-tax.sum-slt-line-base
        tt-sum-fin-doc-tax.sum-slt-contr  = tt-sum-fin-doc-tax.sum-slt-contr  + bf_fin-doc-tax.sum-slt-line-contr
        tt-sum-fin-doc-tax.sum-slt-doc    = tt-sum-fin-doc-tax.sum-slt-doc    + bf_fin-doc-tax.sum-slt-line-doc
      .
      if last-of (bf_fin-doc-tax.with-slt) then do:
        if v-is-cashless then do:
          if pararh-name = "all":u                                     or
          lookup ({&table_arh-fin-doc-contr-schet-tax}, pararh-name) > 0 then do:
          if bf_sysconf.firm-db-num = v-curr-db-num then
          run libfarhp_calc-arh-fin-doc-contr-schet-tax in g#libfarhp (input parmode,
                                                                       input bf_fin-doc.host-code,
                                                                       input bf_fin-doc.payer-type,
                                                                       input bf_fin-doc.payer-code,
                                                                       input bf_fin-doc.receiver-type,
                                                                       input bf_fin-doc.receiver-code,
                                                                       input bf_fin-doc.payer-code-schet,
                                                                       input bf_fin-doc.receiver-code-schet,
                                                                       input bf_fin-doc.fin-ext-doc-type,
                                                                       input {&arh-fin-doc-contr-schet-tax-atom},
                                                                       input bf_fin-doc.fact-order,
                                                                       input bf_fin-doc.fin-doc-code,
                                                                       input bf_fin-doc.fact-date,
                                                                       input bf_fin-doc.curr-code,
                                                                       input bf_sysconf.base-code,
                                                                       input varcurr-dog-code,
                                                                       input varrel-dog-code,
                                                                       input (if available bf_contract then bf_contract.contract-code else 0),
                                                                       input varfin-doc-tax-vat-pc,
                                                                       input varfin-doc-tax-slt-pc,
                                                                       input bf_fin-doc-tax.with-vat,
                                                                       input bf_fin-doc-tax.with-slt,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-doc   else - tt-sum-fin-doc-tax.sum-line-doc      ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl     ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-base  else - tt-sum-fin-doc-tax.sum-line-base     ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-contr else - tt-sum-fin-doc-tax.sum-line-contr    ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-doc    else - tt-sum-fin-doc-tax.sum-vat-doc  ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-base   else - tt-sum-fin-doc-tax.sum-vat-base ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-contr  else - tt-sum-fin-doc-tax.sum-vat-contr) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-doc    else - tt-sum-fin-doc-tax.sum-slt-doc  ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-base   else - tt-sum-fin-doc-tax.sum-slt-base ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-contr  else - tt-sum-fin-doc-tax.sum-slt-contr)
                                                                       ).
          end. /*  if pararh-name = "all":u                                     or
                   lookup ({&table_arh-fin-doc-contr-schet-tax}, pararh-name) > 0 then do:  */
          if bf_sysconf.fin-calc = {&fin-calc-obj} then do:
            if pararh-name = "all":u                                     or
            lookup ({&table_arh-fin-doc-contr-s-tax-obj}, pararh-name) > 0 then do:
            if varhave-connect = no then do:
              run libfarpo_calc-arh-fin-doc-contr-schet-tax-obj in g#libfarpo (input parmode,
                                                                               input bf_fin-doc.host-code,
                                                                               input bf_fin-doc.obj-type,
                                                                               input bf_fin-doc.obj-code,
                                                                               input bf_fin-doc.payer-type,
                                                                               input bf_fin-doc.payer-code,
                                                                               input bf_fin-doc.receiver-type,
                                                                               input bf_fin-doc.receiver-code,
                                                                               input bf_fin-doc.payer-code-schet,
                                                                               input bf_fin-doc.receiver-code-schet,
                                                                               input bf_fin-doc.fin-ext-doc-type,
                                                                               input {&arh-fin-doc-contr-s-tax-obj-atom},
                                                                               input bf_fin-doc.fact-order,
                                                                               input bf_fin-doc.fin-doc-code,
                                                                               input bf_fin-doc.fact-date,
                                                                               input bf_fin-doc.curr-code,
                                                                               input bf_sysconf.base-code,
                                                                               input varcurr-dog-code,
                                                                               input varrel-dog-code,
                                                                               input (if available bf_contract then bf_contract.contract-code else 0),
                                                                               input varfin-doc-tax-vat-pc,
                                                                               input varfin-doc-tax-slt-pc,
                                                                               input bf_fin-doc-tax.with-vat,
                                                                               input bf_fin-doc-tax.with-slt,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-doc   else - tt-sum-fin-doc-tax.sum-line-doc      ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl     ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-base  else - tt-sum-fin-doc-tax.sum-line-base     ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-contr else - tt-sum-fin-doc-tax.sum-line-contr    ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-doc    else - tt-sum-fin-doc-tax.sum-vat-doc  ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-base   else - tt-sum-fin-doc-tax.sum-vat-base ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-contr  else - tt-sum-fin-doc-tax.sum-vat-contr) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-doc    else - tt-sum-fin-doc-tax.sum-slt-doc  ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-base   else - tt-sum-fin-doc-tax.sum-slt-base ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-contr  else - tt-sum-fin-doc-tax.sum-slt-contr)
                                                                               ).
              end. /*if varhave-connect = no then do:*/
            else do:
              for each tt-sum-con-fin-ob-tax-obj where tt-sum-con-fin-ob-tax-obj.vat-pc   = varfin-doc-tax-vat-pc   and
                                                       tt-sum-con-fin-ob-tax-obj.slt-pc   = varfin-doc-tax-slt-pc   and
                                                       tt-sum-con-fin-ob-tax-obj.with-vat = bf_fin-doc-tax.with-vat and
                                                       tt-sum-con-fin-ob-tax-obj.with-slt = bf_fin-doc-tax.with-slt on error undo, return error return-value :
                run libfarpo_calc-arh-fin-doc-contr-schet-tax-obj in g#libfarpo (input parmode,
                                                                                 input bf_fin-doc.host-code,
                                                                                 input tt-sum-con-fin-ob-tax-obj.obj-type,
                                                                                 input tt-sum-con-fin-ob-tax-obj.obj-code,
                                                                                 input bf_fin-doc.payer-type,
                                                                                 input bf_fin-doc.payer-code,
                                                                                 input bf_fin-doc.receiver-type,
                                                                                 input bf_fin-doc.receiver-code,
                                                                                 input bf_fin-doc.payer-code-schet,
                                                                                 input bf_fin-doc.receiver-code-schet,
                                                                                 input bf_fin-doc.fin-ext-doc-type,
                                                                                 input {&arh-fin-doc-contr-s-tax-obj-atom},
                                                                                 input bf_fin-doc.fact-order,
                                                                                 input bf_fin-doc.fin-doc-code,
                                                                                 input bf_fin-doc.fact-date,
                                                                                 input bf_fin-doc.curr-code,
                                                                                 input bf_sysconf.base-code,
                                                                                 input varcurr-dog-code,
                                                                                 input varrel-dog-code,
                                                                                 input (if available bf_contract then bf_contract.contract-code else 0),
                                                                                 input varfin-doc-tax-vat-pc,
                                                                                 input varfin-doc-tax-slt-pc,
                                                                                 input bf_fin-doc-tax.with-vat,
                                                                                 input bf_fin-doc-tax.with-slt,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-doc       else - tt-sum-con-fin-ob-tax-obj.sum-doc      ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-rubl      else - tt-sum-con-fin-ob-tax-obj.sum-rubl     ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-base      else - tt-sum-con-fin-ob-tax-obj.sum-base     ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-contr     else - tt-sum-con-fin-ob-tax-obj.sum-contr    ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-doc   else - tt-sum-con-fin-ob-tax-obj.sum-vat-doc  ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-rubl  else - tt-sum-con-fin-ob-tax-obj.sum-vat-rubl ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-base  else - tt-sum-con-fin-ob-tax-obj.sum-vat-base ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-contr else - tt-sum-con-fin-ob-tax-obj.sum-vat-contr) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-doc   else - tt-sum-con-fin-ob-tax-obj.sum-slt-doc  ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-rubl  else - tt-sum-con-fin-ob-tax-obj.sum-slt-rubl ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-base  else - tt-sum-con-fin-ob-tax-obj.sum-slt-base ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-contr else - tt-sum-con-fin-ob-tax-obj.sum-slt-contr)
                                                                                 ).
                end. /*for each tt-sum-con-fin-ob-tax-obj where tt-sum-con-fin-ob-tax-obj.vat-pc   = varfin-doc-tax-vat-pc   and*/
              end. /*else if varhave-connect = no then do:*/
            end. /*if pararh-name = "all":u                                     or
                   lookup ({&table_arh-fin-doc-contr-s-tax-obj}, pararh-name) > 0 then do:*/
          end.
          /*итоговая по договору*/
          if (pararh-name = "all":u                                     or
          lookup ({&table_arh-fin-doc-contr-schet-tax}, pararh-name) > 0) and  v-curr-db-num = v-obj-db-num then do:
          if bf_sysconf.firm-db-num = v-curr-db-num then
          run libfarhp_calc-arh-fin-doc-contr-schet-tax in g#libfarhp (input parmode,
                                                                       input bf_fin-doc.host-code,
                                                                       input bf_fin-doc.payer-type,
                                                                       input bf_fin-doc.payer-code,
                                                                       input bf_fin-doc.receiver-type,
                                                                       input bf_fin-doc.receiver-code,
                                                                       input 0,
                                                                       input 0,
                                                                       input bf_fin-doc.fin-ext-doc-type,
                                                                       input {&arh-fin-doc-contr-schet-tax-sum-contract},
                                                                       input bf_fin-doc.fact-order,
                                                                       input bf_fin-doc.fin-doc-code,
                                                                       input bf_fin-doc.fact-date,
                                                                       input 0,
                                                                       input bf_sysconf.base-code,
                                                                       input varcurr-dog-code,
                                                                       input varrel-dog-code,
                                                                       input (if available bf_contract then bf_contract.contract-code else 0),
                                                                       input varfin-doc-tax-vat-pc,
                                                                       input varfin-doc-tax-slt-pc,
                                                                       input bf_fin-doc-tax.with-vat,
                                                                       input bf_fin-doc-tax.with-slt,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl  ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl  ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-base  else - tt-sum-fin-doc-tax.sum-line-base  ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-contr else - tt-sum-fin-doc-tax.sum-line-contr ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl   ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl   ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-base   else - tt-sum-fin-doc-tax.sum-vat-base   ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-contr  else - tt-sum-fin-doc-tax.sum-vat-contr  ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl   ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl   ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-base   else - tt-sum-fin-doc-tax.sum-slt-base   ) ,
                                                                       input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-contr  else - tt-sum-fin-doc-tax.sum-slt-contr  )
                                                                       ).
          end. /* if pararh-name = "all":u                                     or
                  lookup ({&table_arh-fin-doc-contr-schet-tax}, pararh-name) > 0 then do:  */
          if bf_sysconf.fin-calc = {&fin-calc-obj} then do:
            if pararh-name = "all":u                                     or
            lookup ({&table_arh-fin-doc-contr-s-tax-obj}, pararh-name) > 0 then do:
            if varhave-connect = no then do:
              run libfarpo_calc-arh-fin-doc-contr-schet-tax-obj in g#libfarpo (input parmode,
                                                                               input bf_fin-doc.host-code,
                                                                               input bf_fin-doc.obj-type,
                                                                               input bf_fin-doc.obj-code,
                                                                               input bf_fin-doc.payer-type,
                                                                               input bf_fin-doc.payer-code,
                                                                               input bf_fin-doc.receiver-type,
                                                                               input bf_fin-doc.receiver-code,
                                                                               input 0,
                                                                               input 0,
                                                                               input bf_fin-doc.fin-ext-doc-type,
                                                                               input {&arh-fin-doc-contr-s-tax-obj-sum-contract},
                                                                               input bf_fin-doc.fact-order,
                                                                               input bf_fin-doc.fin-doc-code,
                                                                               input bf_fin-doc.fact-date,
                                                                               input 0,
                                                                               input bf_sysconf.base-code,
                                                                               input varcurr-dog-code,
                                                                               input varrel-dog-code,
                                                                               input (if available bf_contract then bf_contract.contract-code else 0),
                                                                               input varfin-doc-tax-vat-pc,
                                                                               input varfin-doc-tax-slt-pc,
                                                                               input bf_fin-doc-tax.with-vat,
                                                                               input bf_fin-doc-tax.with-slt,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl  ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl  ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-base  else - tt-sum-fin-doc-tax.sum-line-base  ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-contr else - tt-sum-fin-doc-tax.sum-line-contr ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl   ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl   ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-base   else - tt-sum-fin-doc-tax.sum-vat-base   ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-contr  else - tt-sum-fin-doc-tax.sum-vat-contr  ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl   ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl   ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-base   else - tt-sum-fin-doc-tax.sum-slt-base   ) ,
                                                                               input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-contr  else - tt-sum-fin-doc-tax.sum-slt-contr  )
                                                                               ).
            end.
            else do:
              for each tt-sum-con-fin-ob-tax-obj where tt-sum-con-fin-ob-tax-obj.vat-pc   = varfin-doc-tax-vat-pc   and
                                                       tt-sum-con-fin-ob-tax-obj.slt-pc   = varfin-doc-tax-slt-pc   and
                                                       tt-sum-con-fin-ob-tax-obj.with-vat = bf_fin-doc-tax.with-vat and
                                                       tt-sum-con-fin-ob-tax-obj.with-slt = bf_fin-doc-tax.with-slt on error undo, return error return-value :
                run libfarpo_calc-arh-fin-doc-contr-schet-tax-obj in g#libfarpo (input parmode,
                                                                                 input bf_fin-doc.host-code,
                                                                                 input tt-sum-con-fin-ob-tax-obj.obj-type,
                                                                                 input tt-sum-con-fin-ob-tax-obj.obj-code,
                                                                                 input bf_fin-doc.payer-type,
                                                                                 input bf_fin-doc.payer-code,
                                                                                 input bf_fin-doc.receiver-type,
                                                                                 input bf_fin-doc.receiver-code,
                                                                                 input 0,
                                                                                 input 0,
                                                                                 input bf_fin-doc.fin-ext-doc-type,
                                                                                 input {&arh-fin-doc-contr-s-tax-obj-sum-contract},
                                                                                 input bf_fin-doc.fact-order,
                                                                                 input bf_fin-doc.fin-doc-code,
                                                                                 input bf_fin-doc.fact-date,
                                                                                 input 0,
                                                                                 input bf_sysconf.base-code,
                                                                                 input varcurr-dog-code,
                                                                                 input varrel-dog-code,
                                                                                 input (if available bf_contract then bf_contract.contract-code else 0),
                                                                                 input varfin-doc-tax-vat-pc,
                                                                                 input varfin-doc-tax-slt-pc,
                                                                                 input bf_fin-doc-tax.with-vat,
                                                                                 input bf_fin-doc-tax.with-slt,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-rubl      else - tt-sum-con-fin-ob-tax-obj.sum-rubl     ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-rubl      else - tt-sum-con-fin-ob-tax-obj.sum-rubl     ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-base      else - tt-sum-con-fin-ob-tax-obj.sum-base     ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-contr     else - tt-sum-con-fin-ob-tax-obj.sum-contr    ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-rubl  else - tt-sum-con-fin-ob-tax-obj.sum-vat-rubl ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-rubl  else - tt-sum-con-fin-ob-tax-obj.sum-vat-rubl ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-base  else - tt-sum-con-fin-ob-tax-obj.sum-vat-base ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-contr else - tt-sum-con-fin-ob-tax-obj.sum-vat-contr) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-rubl  else - tt-sum-con-fin-ob-tax-obj.sum-slt-rubl ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-rubl  else - tt-sum-con-fin-ob-tax-obj.sum-slt-rubl ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-base  else - tt-sum-con-fin-ob-tax-obj.sum-slt-base ) ,
                                                                                 input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-contr else - tt-sum-con-fin-ob-tax-obj.sum-slt-contr)
                                                                                 ).
                end. /*for each*/
              end. /*else if carhave-co*/
            end. /* if pararh-name = "all":u                                     or
                    lookup ({&table_arh-fin-doc-contr-s-tax-obj}, pararh-name) > 0 then do:  */
          end. /*if bf_sysconf.fin-calc = {&fin-calc-obj} then do:*/
        end. /**if v-is-cashless*/
        else do:
          if (pararh-name = "all":u                                     or
          lookup ({&table_arh-fin-doc-c-schet-tax-nal}, pararh-name) > 0)  and  v-curr-db-num = v-obj-db-num then do:
          if bf_sysconf.firm-db-num = v-curr-db-num then
          run libfarhp_calc-arh-fin-doc-contr-schet-tax-n in g#libfarhp (input parmode,
                                                                         input bf_fin-doc.host-code,
                                                                         input bf_fin-doc.payer-type,
                                                                         input bf_fin-doc.payer-code,
                                                                         input bf_fin-doc.receiver-type,
                                                                         input bf_fin-doc.receiver-code,
                                                                         input (if v-is-income then bf_fin-doc.cor-acc1 else bf_fin-doc.cor-acc ),
                                                                         input (if v-is-income then bf_fin-doc.cor-acc  else bf_fin-doc.cor-acc1),
                                                                         input bf_fin-doc.fin-ext-doc-type,
                                                                         input {&arh-fin-doc-c-schet-tax-nal-atom},
                                                                         input bf_fin-doc.fact-order,
                                                                         input bf_fin-doc.fin-doc-code,
                                                                         input bf_fin-doc.fact-date,
                                                                         input bf_fin-doc.curr-code,
                                                                         input bf_sysconf.base-code,
                                                                         input varcurr-dog-code,
                                                                         input varrel-dog-code,
                                                                         input (if available bf_contract then bf_contract.contract-code else 0),
                                                                         input varfin-doc-tax-vat-pc,
                                                                         input varfin-doc-tax-slt-pc,
                                                                         input bf_fin-doc-tax.with-vat,
                                                                         input bf_fin-doc-tax.with-slt,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-doc   else - tt-sum-fin-doc-tax.sum-line-doc      ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl     ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-base  else - tt-sum-fin-doc-tax.sum-line-base     ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-contr else - tt-sum-fin-doc-tax.sum-line-contr    ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-doc    else - tt-sum-fin-doc-tax.sum-vat-doc  ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-base   else - tt-sum-fin-doc-tax.sum-vat-base ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-contr  else - tt-sum-fin-doc-tax.sum-vat-contr) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-doc    else - tt-sum-fin-doc-tax.sum-slt-doc  ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-base   else - tt-sum-fin-doc-tax.sum-slt-base ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-contr  else - tt-sum-fin-doc-tax.sum-slt-contr)
                                                                         ).
          end. /*  if pararh-name = "all":u                                     or
                 lookup ({&table_arh-fin-doc-c-schet-tax-nal}, pararh-name) > 0 then do:  */
          if bf_sysconf.fin-calc = {&fin-calc-obj} then do:
            if pararh-name = "all":u                                     or
            lookup ({&table_arh-fin-doc-c-s-tax-nal-obj}, pararh-name) > 0 then do:
            if varhave-connect = no then do:
              run libfarpo_calc-arh-fin-doc-contr-schet-tax-n-obj in g#libfarpo (input parmode,
                                                                                 input bf_fin-doc.host-code,
                                                                                 input bf_fin-doc.obj-type,
                                                                                 input bf_fin-doc.obj-code,
                                                                                 input bf_fin-doc.payer-type,
                                                                                 input bf_fin-doc.payer-code,
                                                                                 input bf_fin-doc.receiver-type,
                                                                                 input bf_fin-doc.receiver-code,
                                                                                 input (if v-is-income then bf_fin-doc.cor-acc1 else bf_fin-doc.cor-acc ),
                                                                                 input (if v-is-income then bf_fin-doc.cor-acc  else bf_fin-doc.cor-acc1),
                                                                                 input bf_fin-doc.fin-ext-doc-type,
                                                                                 input {&arh-fin-doc-c-s-tax-nal-obj-atom},
                                                                                 input bf_fin-doc.fact-order,
                                                                                 input bf_fin-doc.fin-doc-code,
                                                                                 input bf_fin-doc.fact-date,
                                                                                 input bf_fin-doc.curr-code,
                                                                                 input bf_sysconf.base-code,
                                                                                 input varcurr-dog-code,
                                                                                 input varrel-dog-code,
                                                                                 input (if available bf_contract then bf_contract.contract-code else 0),
                                                                                 input varfin-doc-tax-vat-pc,
                                                                                 input varfin-doc-tax-slt-pc,
                                                                                 input bf_fin-doc-tax.with-vat,
                                                                                 input bf_fin-doc-tax.with-slt,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-doc   else - tt-sum-fin-doc-tax.sum-line-doc      ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl     ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-base  else - tt-sum-fin-doc-tax.sum-line-base     ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-contr else - tt-sum-fin-doc-tax.sum-line-contr    ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-doc    else - tt-sum-fin-doc-tax.sum-vat-doc  ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-base   else - tt-sum-fin-doc-tax.sum-vat-base ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-contr  else - tt-sum-fin-doc-tax.sum-vat-contr) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-doc    else - tt-sum-fin-doc-tax.sum-slt-doc  ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-base   else - tt-sum-fin-doc-tax.sum-slt-base ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-contr  else - tt-sum-fin-doc-tax.sum-slt-contr)
                                                                                 ).
              end. /*if varhave-connect*/
            else do:
              for each tt-sum-con-fin-ob-tax-obj where tt-sum-con-fin-ob-tax-obj.vat-pc   = varfin-doc-tax-vat-pc   and
                                                       tt-sum-con-fin-ob-tax-obj.slt-pc   = varfin-doc-tax-slt-pc   and
                                                       tt-sum-con-fin-ob-tax-obj.with-vat = bf_fin-doc-tax.with-vat and
                                                       tt-sum-con-fin-ob-tax-obj.with-slt = bf_fin-doc-tax.with-slt on error undo, return error return-value :
                run libfarpo_calc-arh-fin-doc-contr-schet-tax-n-obj in g#libfarpo (input parmode,
                                                                                   input bf_fin-doc.host-code,
                                                                                   input tt-sum-con-fin-ob-tax-obj.obj-type,
                                                                                   input tt-sum-con-fin-ob-tax-obj.obj-code,
                                                                                   input bf_fin-doc.payer-type,
                                                                                   input bf_fin-doc.payer-code,
                                                                                   input bf_fin-doc.receiver-type,
                                                                                   input bf_fin-doc.receiver-code,
                                                                                   input (if v-is-income then bf_fin-doc.cor-acc1 else bf_fin-doc.cor-acc ),
                                                                                   input (if v-is-income then bf_fin-doc.cor-acc  else bf_fin-doc.cor-acc1),
                                                                                   input bf_fin-doc.fin-ext-doc-type,
                                                                                   input {&arh-fin-doc-c-s-tax-nal-obj-atom},
                                                                                   input bf_fin-doc.fact-order,
                                                                                   input bf_fin-doc.fin-doc-code,
                                                                                   input bf_fin-doc.fact-date,
                                                                                   input bf_fin-doc.curr-code,
                                                                                   input bf_sysconf.base-code,
                                                                                   input varcurr-dog-code,
                                                                                   input varrel-dog-code,
                                                                                   input (if available bf_contract then bf_contract.contract-code else 0),
                                                                                   input varfin-doc-tax-vat-pc,
                                                                                   input varfin-doc-tax-slt-pc,
                                                                                   input bf_fin-doc-tax.with-vat,
                                                                                   input bf_fin-doc-tax.with-slt,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-doc       else - tt-sum-con-fin-ob-tax-obj.sum-doc      ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-rubl      else - tt-sum-con-fin-ob-tax-obj.sum-rubl     ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-base      else - tt-sum-con-fin-ob-tax-obj.sum-base     ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-contr     else - tt-sum-con-fin-ob-tax-obj.sum-contr    ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-doc   else - tt-sum-con-fin-ob-tax-obj.sum-vat-doc  ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-rubl  else - tt-sum-con-fin-ob-tax-obj.sum-vat-rubl ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-base  else - tt-sum-con-fin-ob-tax-obj.sum-vat-base ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-contr else - tt-sum-con-fin-ob-tax-obj.sum-vat-contr) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-doc   else - tt-sum-con-fin-ob-tax-obj.sum-slt-doc  ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-rubl  else - tt-sum-con-fin-ob-tax-obj.sum-slt-rubl ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-base  else - tt-sum-con-fin-ob-tax-obj.sum-slt-base ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-contr else - tt-sum-con-fin-ob-tax-obj.sum-slt-contr)
                                                                                   ).
                end. /*for each*/
              end. /*else if varhave-connect*/
            end. /*  if pararh-name = "all":u                                     or
                  lookup ({&table_arh-fin-doc-c-s-tax-nal-obj}, pararh-name) > 0 then do:  */
          end. /*if bf_sysconf.fin-calc = {&fin-calc-obj} then do:*/
          /*итоговая по договору*/
          if (pararh-name = "all":u                                     or
          lookup ({&table_arh-fin-doc-c-schet-tax-nal}, pararh-name) > 0) and  v-curr-db-num = v-obj-db-num then do:
          if bf_sysconf.firm-db-num = v-curr-db-num then
          run libfarhp_calc-arh-fin-doc-contr-schet-tax-n in g#libfarhp (input parmode,
                                                                         input bf_fin-doc.host-code,
                                                                         input bf_fin-doc.payer-type,
                                                                         input bf_fin-doc.payer-code,
                                                                         input bf_fin-doc.receiver-type,
                                                                         input bf_fin-doc.receiver-code,
                                                                         input 0,
                                                                         input 0,
                                                                         input bf_fin-doc.fin-ext-doc-type,
                                                                          input {&arh-fin-doc-c-schet-tax-nal-sum-contract},
                                                                         input bf_fin-doc.fact-order,
                                                                         input bf_fin-doc.fin-doc-code,
                                                                         input bf_fin-doc.fact-date,
                                                                         input 0,
                                                                         input bf_sysconf.base-code,
                                                                         input varcurr-dog-code,
                                                                         input varrel-dog-code,
                                                                         input (if available bf_contract then bf_contract.contract-code else 0),
                                                                         input varfin-doc-tax-vat-pc,
                                                                         input varfin-doc-tax-slt-pc,
                                                                         input bf_fin-doc-tax.with-vat,
                                                                         input bf_fin-doc-tax.with-slt,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl   ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl   ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-base  else - tt-sum-fin-doc-tax.sum-line-base   ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-contr else - tt-sum-fin-doc-tax.sum-line-contr  ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl    ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl    ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-base   else - tt-sum-fin-doc-tax.sum-vat-base    ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-contr  else - tt-sum-fin-doc-tax.sum-vat-contr   ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl    ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl    ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-base   else - tt-sum-fin-doc-tax.sum-slt-base    ) ,
                                                                         input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-contr  else - tt-sum-fin-doc-tax.sum-slt-contr   )
                                                                         ).
          end.  /*  if pararh-name = "all":u                                     or
                    lookup ({&table_arh-fin-doc-c-schet-tax-nal}, pararh-name) > 0 then do:  */
          if bf_sysconf.fin-calc = {&fin-calc-obj} then do:
            if pararh-name = "all":u                                     or
            lookup ({&table_arh-fin-doc-c-s-tax-nal-obj}, pararh-name) > 0 then do:
            if varhave-connect = no then do:
              run libfarpo_calc-arh-fin-doc-contr-schet-tax-n-obj in g#libfarpo (input parmode,
                                                                                 input bf_fin-doc.host-code,
                                                                                 input bf_fin-doc.obj-type,
                                                                                 input bf_fin-doc.obj-code,
                                                                                 input bf_fin-doc.payer-type,
                                                                                 input bf_fin-doc.payer-code,
                                                                                 input bf_fin-doc.receiver-type,
                                                                                 input bf_fin-doc.receiver-code,
                                                                                 input 0,
                                                                                 input 0,
                                                                                 input bf_fin-doc.fin-ext-doc-type,
                                                                                 input {&arh-fin-doc-c-s-tax-nal-obj-sum-contract},
                                                                                 input bf_fin-doc.fact-order,
                                                                                 input bf_fin-doc.fin-doc-code,
                                                                                 input bf_fin-doc.fact-date,
                                                                                 input 0,
                                                                                 input bf_sysconf.base-code,
                                                                                 input varcurr-dog-code,
                                                                                 input varrel-dog-code,
                                                                                 input (if available bf_contract then bf_contract.contract-code else 0),
                                                                                 input varfin-doc-tax-vat-pc,
                                                                                 input varfin-doc-tax-slt-pc,
                                                                                 input bf_fin-doc-tax.with-vat,
                                                                                 input bf_fin-doc-tax.with-slt,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl  ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl  ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-base  else - tt-sum-fin-doc-tax.sum-line-base  ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-contr else - tt-sum-fin-doc-tax.sum-line-contr ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl   ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl   ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-base   else - tt-sum-fin-doc-tax.sum-vat-base   ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-contr  else - tt-sum-fin-doc-tax.sum-vat-contr  ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl   ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl   ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-base   else - tt-sum-fin-doc-tax.sum-slt-base   ) ,
                                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-contr  else - tt-sum-fin-doc-tax.sum-slt-contr  )
                                                                                 ).
              end. /*if varhave-contract*/
            else do:
              for each tt-sum-con-fin-ob-tax-obj where tt-sum-con-fin-ob-tax-obj.vat-pc   = varfin-doc-tax-vat-pc   and
                                                       tt-sum-con-fin-ob-tax-obj.slt-pc   = varfin-doc-tax-slt-pc   and
                                                       tt-sum-con-fin-ob-tax-obj.with-vat = bf_fin-doc-tax.with-vat and
                                                       tt-sum-con-fin-ob-tax-obj.with-slt = bf_fin-doc-tax.with-slt on error undo, return error return-value :
                run libfarpo_calc-arh-fin-doc-contr-schet-tax-n-obj in g#libfarpo (input parmode,
                                                                                   input bf_fin-doc.host-code,
                                                                                   input tt-sum-con-fin-ob-tax-obj.obj-type,
                                                                                   input tt-sum-con-fin-ob-tax-obj.obj-code,
                                                                                   input bf_fin-doc.payer-type,
                                                                                   input bf_fin-doc.payer-code,
                                                                                   input bf_fin-doc.receiver-type,
                                                                                   input bf_fin-doc.receiver-code,
                                                                                   input 0,
                                                                                   input 0,
                                                                                   input bf_fin-doc.fin-ext-doc-type,
                                                                                   input {&arh-fin-doc-c-s-tax-nal-obj-sum-contract},
                                                                                   input bf_fin-doc.fact-order,
                                                                                   input bf_fin-doc.fin-doc-code,
                                                                                   input bf_fin-doc.fact-date,
                                                                                   input 0,
                                                                                   input bf_sysconf.base-code,
                                                                                   input varcurr-dog-code,
                                                                                   input varrel-dog-code,
                                                                                   input (if available bf_contract then bf_contract.contract-code else 0),
                                                                                   input varfin-doc-tax-vat-pc,
                                                                                   input varfin-doc-tax-slt-pc,
                                                                                   input bf_fin-doc-tax.with-vat,
                                                                                   input bf_fin-doc-tax.with-slt,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-rubl      else - tt-sum-con-fin-ob-tax-obj.sum-rubl     ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-rubl      else - tt-sum-con-fin-ob-tax-obj.sum-rubl     ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-base      else - tt-sum-con-fin-ob-tax-obj.sum-base     ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-contr     else - tt-sum-con-fin-ob-tax-obj.sum-contr    ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-rubl  else - tt-sum-con-fin-ob-tax-obj.sum-vat-rubl ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-rubl  else - tt-sum-con-fin-ob-tax-obj.sum-vat-rubl ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-base  else - tt-sum-con-fin-ob-tax-obj.sum-vat-base ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-vat-contr else - tt-sum-con-fin-ob-tax-obj.sum-vat-contr) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-rubl  else - tt-sum-con-fin-ob-tax-obj.sum-slt-rubl ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-rubl  else - tt-sum-con-fin-ob-tax-obj.sum-slt-rubl ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-base  else - tt-sum-con-fin-ob-tax-obj.sum-slt-base ) ,
                                                                                   input (if parmode = "close":u then tt-sum-con-fin-ob-tax-obj.sum-slt-contr else - tt-sum-con-fin-ob-tax-obj.sum-slt-contr)
                                                                                   ).
                end. /*for each*/
              end. /**else if varhave-con*/
            end. /* if pararh-name = "all":u                                     or
                    lookup ({&table_arh-fin-doc-c-s-tax-nal-obj}, pararh-name) > 0 then do:           */
          end. /*if bf_sysconf.fin-calc = {&fin-calc-obj} then do:*/
        end. /*else if v-cashless*/
      end. /*if last-of (bf_fin-doc-tax.with-slt) then do:*/
    end. /*for each bf_fin-doc-tax where bf_fin-doc-tax.host-code    = bf_fin-doc.host-code    and*/
  end.  /*  if pararh-name = "all":u                                     or
            lookup ({&table_arh-fin-doc-contr-schet-tax}, pararh-name) > 0 or
            lookup ({&table_arh-fin-doc-contr-s-tax-obj}, pararh-name) > 0 or
            lookup ({&table_arh-fin-doc-c-schet-tax-nal}, pararh-name) > 0 or
            lookup ({&table_arh-fin-doc-c-s-tax-nal-obj}, pararh-name) > 0 or  then do:  */
    if v-is-cashless then do:
    if (pararh-name = "all":u                           or
    lookup ({&table_arh-fin-doc-schet}, pararh-name) > 0) and  v-curr-db-num = v-obj-db-num then do:
      if bf_sysconf.firm-db-num = v-curr-db-num then
      run libfarhp_calc-arh-fin-doc-schet in g#libfarhp  (input parmode,
                                                          input bf_fin-doc.host-code,
                                                          input bf_fin-doc.payer-type,
                                                          input bf_fin-doc.payer-code,
                                                          input bf_fin-doc.receiver-type,
                                                          input bf_fin-doc.receiver-code,
                                                          input bf_fin-doc.payer-code-schet,
                                                          input bf_fin-doc.receiver-code-schet,
                                                          input bf_fin-doc.fin-ext-doc-type,
                                                          input {&arh-fin-doc-schet-atom},
                                                          input bf_fin-doc.fact-order,
                                                          input bf_fin-doc.fin-doc-code,
                                                          input bf_fin-doc.fact-date,
                                                          input bf_fin-doc.curr-code,
                                                          input bf_sysconf.base-code,
                                                          input varznaksum-doc ,
                                                          input varznaksum-rubl,
                                                          input varznaksum-base,
                                                          input varznaksum-vat-doc     ,
                                                          input varznaksum-vat-rubl    ,
                                                          input varznaksum-vat-base    ,
                                                          input varznaksum-slt-doc     ,
                                                          input varznaksum-slt-rubl    ,
                                                          input varznaksum-slt-base
                                                          ).
      if bf_sysconf.firm-db-num = v-curr-db-num then
      run libfarhp_calc-arh-fin-doc-schet in g#libfarhp  (input parmode,
                                                          input bf_fin-doc.host-code,
                                                          input (if v-is-income then '' else  bf_fin-doc.payer-type),
                                                          input (if v-is-income then 0 else  bf_fin-doc.payer-code),
                                                          input (if v-is-expense then '' else  bf_fin-doc.receiver-type),
                                                          input (if v-is-expense then 0 else  bf_fin-doc.receiver-code),
                                                          input 0, /*p-payer-code-schet*/
                                                          input 0, /*p-receiver-code-schet*/
                                                          input "", /*p-fin-ext-doc-type*/
                                                          input {&arh-fin-doc-schet-firm},
                                                          input bf_fin-doc.fact-order,
                                                          input bf_fin-doc.fin-doc-code,
                                                          input bf_fin-doc.fact-date,
                                                          input bf_fin-doc.curr-code,
                                                          input bf_sysconf.base-code,
                                                          input varznaksum-doc ,
                                                          input varznaksum-rubl,
                                                          input varznaksum-base,
                                                          input varznaksum-vat-doc     ,
                                                          input varznaksum-vat-rubl    ,
                                                          input varznaksum-vat-base    ,
                                                          input varznaksum-slt-doc     ,
                                                          input varznaksum-slt-rubl    ,
                                                          input varznaksum-slt-base
                                                          ).
      if bf_sysconf.firm-db-num = v-curr-db-num
      and bf_fin-doc.trn-doc-code = ''      then
      run libfarhp_calc-arh-fin-doc-schet in g#libfarhp  (input parmode,
                                                          input bf_fin-doc.host-code,
                                                          input (if v-is-income then '' else  bf_fin-doc.payer-type),
                                                          input (if v-is-income then 0 else  bf_fin-doc.payer-code),
                                                          input (if v-is-expense then '' else  bf_fin-doc.receiver-type),
                                                          input (if v-is-expense then 0 else  bf_fin-doc.receiver-code),
                                                          input 0, /*p-payer-code-schet*/
                                                          input 0, /*p-receiver-code-schet*/
                                                          input "", /*p-fin-ext-doc-type*/
                                                          input {&arh-fin-doc-schet-firm-without-obj},
                                                          input bf_fin-doc.fact-order,
                                                          input bf_fin-doc.fin-doc-code,
                                                          input bf_fin-doc.fact-date,
                                                          input bf_fin-doc.curr-code,
                                                          input bf_sysconf.base-code,
                                                          input varznaksum-doc ,
                                                          input varznaksum-rubl,
                                                          input varznaksum-base,
                                                          input varznaksum-vat-doc     ,
                                                          input varznaksum-vat-rubl    ,
                                                          input varznaksum-vat-base    ,
                                                          input varznaksum-slt-doc     ,
                                                          input varznaksum-slt-rubl    ,
                                                          input varznaksum-slt-base
                                                          ).
    end. /*  if pararh-name = "all":u                           or
              lookup ({&table_arh-fin-doc-schet}, pararh-name) > 0 then do:      */
    if pararh-name = "all":u                           or
    lookup ({&table_arh-fin-doc-schet-obj}, pararh-name) > 0 then do:
      if not (bf_fin-doc.obj-type = ''
             and bf_fin-doc.obj-code = 0) then do:
        run libfarpo_calc-arh-fin-doc-schet-obj in g#libfarpo  (input parmode,
                                                            input bf_fin-doc.host-code,
                                                            input bf_fin-doc.obj-type,
                                                            input bf_fin-doc.obj-code,
                                                            input bf_fin-doc.payer-type,
                                                            input bf_fin-doc.payer-code,
                                                            input bf_fin-doc.receiver-type,
                                                            input bf_fin-doc.receiver-code,
                                                            input bf_fin-doc.payer-code-schet,
                                                            input bf_fin-doc.receiver-code-schet,
                                                            input bf_fin-doc.fin-ext-doc-type,
                                                            input {&arh-fin-doc-schet-obj-atom},
                                                            input bf_fin-doc.fact-order,
                                                            input bf_fin-doc.fin-doc-code,
                                                            input bf_fin-doc.fact-date,
                                                            input ? /*bf_fin-doc.shift-date*/ ,
                                                            input 0 /*bf_fin-doc.shift-num*/ ,
                                                            input bf_fin-doc.curr-code,
                                                            input bf_sysconf.base-code,
                                                            input varznaksum-doc ,
                                                            input varznaksum-rubl,
                                                            input varznaksum-base,
                                                            input varznaksum-vat-doc     ,
                                                            input varznaksum-vat-rubl    ,
                                                            input varznaksum-vat-base    ,
                                                            input varznaksum-slt-doc     ,
                                                            input varznaksum-slt-rubl    ,
                                                            input varznaksum-slt-base
                                                            ).
        if bf_fin-doc.trn-doc-code = bf_fin-doc.obj-type + string(bf_fin-doc.obj-code, "99999") then do:
        run libfarpo_calc-arh-fin-doc-schet-obj in g#libfarpo  (input parmode,
                                                            input bf_fin-doc.host-code,
                                                            input bf_fin-doc.obj-type,
                                                            input bf_fin-doc.obj-code,
                                                            input (if v-is-income then '' else  bf_fin-doc.payer-type),
                                                            input (if v-is-income then 0 else  bf_fin-doc.payer-code),
                                                            input (if v-is-expense then '' else  bf_fin-doc.receiver-type),
                                                            input (if v-is-expense then 0 else  bf_fin-doc.receiver-code),
                                                            input 0 /*p-payer-code-schet*/ ,
                                                            input 0  /*p-receiver-code-schet*/ ,
                                                            input "" /*p-fin-ext-doc-type*/,
                                                            input {&arh-fin-doc-schet-obj-obj},
                                                            input bf_fin-doc.fact-order,
                                                            input bf_fin-doc.fin-doc-code,
                                                            input bf_fin-doc.fact-date,
                                                            input ? /*bf_fin-doc.shift-date*/,
                                                            input 0 /*bf_fin-doc.shift-num*/,
                                                            input bf_fin-doc.curr-code,
                                                            input bf_sysconf.base-code,
                                                            input varznaksum-doc ,
                                                            input varznaksum-rubl,
                                                            input varznaksum-base,
                                                            input varznaksum-vat-doc     ,
                                                            input varznaksum-vat-rubl    ,
                                                            input varznaksum-vat-base    ,
                                                            input varznaksum-slt-doc     ,
                                                            input varznaksum-slt-rubl    ,
                                                            input varznaksum-slt-base
                                                            ).
          if bf_fin-doc.shift-fact-order <> 0
          then do:
           run libfarpo_calc-arh-fin-doc-schet-obj in g#libfarpo  (input parmode,
                                                                  input bf_fin-doc.host-code,
                                                                  input bf_fin-doc.obj-type,
                                                                  input bf_fin-doc.obj-code,
                                                                  input (if v-is-income then '' else  bf_fin-doc.payer-type),
                                                                  input (if v-is-income then 0 else  bf_fin-doc.payer-code),
                                                                  input (if v-is-expense then '' else  bf_fin-doc.receiver-type),
                                                                  input (if v-is-expense then 0 else  bf_fin-doc.receiver-code),
                                                                  input 0 /*p-payer-code-schet*/ ,
                                                                  input 0  /*p-receiver-code-schet*/ ,
                                                                  input "" /*p-fin-ext-doc-type*/,
                                                                  input {&arh-fin-doc-schet-obj-shift-obj},
                                                                  input bf_fin-doc.shift-fact-order,
                                                                  input bf_fin-doc.fin-doc-code,
                                                                  input bf_fin-doc.fact-date,
                                                                  input bf_fin-doc.shift-date,
                                                                  input bf_fin-doc.shift-num,
                                                                  input bf_fin-doc.curr-code,
                                                                  input bf_sysconf.base-code,
                                                                  input varznaksum-doc ,
                                                                  input varznaksum-rubl,
                                                                  input varznaksum-base,
                                                                  input varznaksum-vat-doc     ,
                                                                  input varznaksum-vat-rubl    ,
                                                                  input varznaksum-vat-base    ,
                                                                  input varznaksum-slt-doc     ,
                                                                  input varznaksum-slt-rubl    ,
                                                                  input varznaksum-slt-base
                                                                  ).
         end. /*if bf_fin-doc.shift-fact-order <> 0 then do:*/
         end. /*if bf_fin-doc.trn-doc-code = bf_fin-doc.obj-type + string(bf_fin-doc.obj-code, "99999") then do:*/
       end.  /* if not (bf_fin-doc.obj-type = ''
             and bf_fin-doc.obj-code = 0) then do:       */
     end. /* if pararh-name = "all":u                           or
               lookup ({&table_arh-fin-doc-schet}, pararh-name) > 0 then do: */

  end. /*if v-is-cashless*/
    else do:
    if (pararh-name = "all":u                           or
    lookup ({&table_arh-fin-doc-schet-nal}, pararh-name) > 0 ) and  v-curr-db-num = v-obj-db-num then do:
      if bf_sysconf.firm-db-num = v-curr-db-num then
      run libfarhp_calc-arh-fin-doc-schet-n in g#libfarhp  (input parmode,
                                                            input bf_fin-doc.host-code,
                                                            input bf_fin-doc.payer-type,
                                                            input bf_fin-doc.payer-code,
                                                            input bf_fin-doc.receiver-type,
                                                            input bf_fin-doc.receiver-code,
                                                            input (if v-is-income then bf_fin-doc.cor-acc1 else bf_fin-doc.cor-acc ),
                                                            input (if v-is-income then bf_fin-doc.cor-acc  else bf_fin-doc.cor-acc1),
                                                            input bf_fin-doc.fin-ext-doc-type,
                                                            input {&arh-fin-doc-schet-nal-atom},
                                                            input bf_fin-doc.fact-order,
                                                            input bf_fin-doc.fin-doc-code,
                                                            input bf_fin-doc.fact-date,
                                                            input bf_fin-doc.curr-code,
                                                            input bf_sysconf.base-code,
                                                            input varznaksum-doc  ,
                                                            input varznaksum-rubl ,
                                                            input varznaksum-base ,
                                                            input varznaksum-vat-doc      ,
                                                            input varznaksum-vat-rubl     ,
                                                            input varznaksum-vat-base     ,
                                                            input varznaksum-slt-doc      ,
                                                            input varznaksum-slt-rubl     ,
                                                            input varznaksum-slt-base
                                                            ).

      if bf_sysconf.firm-db-num = v-curr-db-num then
      run libfarhp_calc-arh-fin-doc-schet-n in g#libfarhp  (input parmode,
                                                            input bf_fin-doc.host-code,
                                                            input (if v-is-income then '' else  bf_fin-doc.payer-type),
                                                            input (if v-is-income then 0 else  bf_fin-doc.payer-code),
                                                            input (if v-is-expense then '' else  bf_fin-doc.receiver-type),
                                                            input (if v-is-expense then 0 else  bf_fin-doc.receiver-code),
                                                            input 0,
                                                            input 0,
                                                            input '', /*p-fin-ext-doc-type*/
                                                            input {&arh-fin-doc-schet-nal-firm},
                                                            input bf_fin-doc.fact-order,
                                                            input bf_fin-doc.fin-doc-code,
                                                            input bf_fin-doc.fact-date,
                                                            input bf_fin-doc.curr-code,
                                                            input bf_sysconf.base-code,
                                                            input varznaksum-doc  ,
                                                            input varznaksum-rubl ,
                                                            input varznaksum-base ,
                                                            input varznaksum-vat-doc      ,
                                                            input varznaksum-vat-rubl     ,
                                                            input varznaksum-vat-base     ,
                                                            input varznaksum-slt-doc      ,
                                                            input varznaksum-slt-rubl     ,
                                                            input varznaksum-slt-base
                                                            ).
      if bf_sysconf.firm-db-num = v-curr-db-num
      and bf_fin-doc.trn-doc-code = "" then
      run libfarhp_calc-arh-fin-doc-schet-n in g#libfarhp  (input parmode,
                                                            input bf_fin-doc.host-code,
                                                            input (if v-is-income then '' else  bf_fin-doc.payer-type),
                                                            input (if v-is-income then 0 else  bf_fin-doc.payer-code),
                                                            input (if v-is-expense then '' else  bf_fin-doc.receiver-type),
                                                            input (if v-is-expense then 0 else  bf_fin-doc.receiver-code),
                                                            input 0,
                                                            input 0,
                                                            input '', /*p-fin-ext-doc-type*/
                                                            input {&arh-fin-doc-schet-nal-firm-without-obj},
                                                            input bf_fin-doc.fact-order,
                                                            input bf_fin-doc.fin-doc-code,
                                                            input bf_fin-doc.fact-date,
                                                            input bf_fin-doc.curr-code,
                                                            input bf_sysconf.base-code,
                                                            input varznaksum-doc  ,
                                                            input varznaksum-rubl ,
                                                            input varznaksum-base ,
                                                            input varznaksum-vat-doc      ,
                                                            input varznaksum-vat-rubl     ,
                                                            input varznaksum-vat-base     ,
                                                            input varznaksum-slt-doc      ,
                                                            input varznaksum-slt-rubl     ,
                                                            input varznaksum-slt-base
                                                            ).

    end. /* if pararh-name = "all":u                           or
            lookup ({&table_arh-fin-doc-schet-nal}, pararh-name) > 0 then do:   */
    if not (bf_fin-doc.obj-type = ''
            and bf_fin-doc.obj-code = 0) then do:

      if pararh-name = "all":u                           or
      lookup ({&table_arh-fin-doc-schet-nal-obj}, pararh-name) > 0 then do:
       run libfarpo_calc-arh-fin-doc-schet-n-obj in g#libfarpo  (input parmode,
                                                            input bf_fin-doc.host-code,
                                                            input bf_fin-doc.obj-type,
                                                            input bf_fin-doc.obj-code,
                                                            input bf_fin-doc.payer-type,
                                                            input bf_fin-doc.payer-code,
                                                            input bf_fin-doc.receiver-type,
                                                            input bf_fin-doc.receiver-code,
                                                            input (if v-is-income then bf_fin-doc.cor-acc1 else bf_fin-doc.cor-acc ),
                                                            input (if v-is-income then bf_fin-doc.cor-acc  else bf_fin-doc.cor-acc1),
                                                            input bf_fin-doc.fin-ext-doc-type,
                                                            input {&arh-fin-doc-schet-nal-obj-atom},
                                                            input bf_fin-doc.fact-order,
                                                            input bf_fin-doc.fin-doc-code,
                                                            input bf_fin-doc.fact-date,
                                                            input ? /*bf_fin-doc.shift-date*/ ,
                                                            input 0 /*bf_fin-doc.shift-num*/ ,
                                                            input bf_fin-doc.curr-code,
                                                            input bf_fin-doc.cashbookid,
                                                            input bf_sysconf.base-code,
                                                            input varznaksum-doc  ,
                                                            input varznaksum-rubl ,
                                                            input varznaksum-base ,
                                                            input varznaksum-vat-doc      ,
                                                            input varznaksum-vat-rubl     ,
                                                            input varznaksum-vat-base     ,
                                                            input varznaksum-slt-doc      ,
                                                            input varznaksum-slt-rubl     ,
                                                            input varznaksum-slt-base
                                                            ).
       if bf_fin-doc.trn-doc-code = bf_fin-doc.obj-type + string(bf_fin-doc.obj-code, "99999") then do:
        if v-is-cash then
       run libfarpo_calc-arh-fin-doc-schet-n-obj in g#libfarpo
                                                           (input parmode,
                                                            input bf_fin-doc.host-code,
                                                            input bf_fin-doc.obj-type,
                                                            input bf_fin-doc.obj-code,
                                                            input (if v-is-income then '' else  bf_fin-doc.payer-type),
                                                            input (if v-is-income then 0 else  bf_fin-doc.payer-code),
                                                            input (if v-is-expense then '' else  bf_fin-doc.receiver-type),
                                                            input (if v-is-expense then 0 else  bf_fin-doc.receiver-code),
                                                            input 0,
                                                            input 0,
                                                            input "",
                                                            input {&arh-fin-doc-schet-nal-obj-obj},
                                                            input bf_fin-doc.fact-order,
                                                            input bf_fin-doc.fin-doc-code,
                                                            input bf_fin-doc.fact-date,
                                                            input ? /*bf_fin-doc.shift-date*/ ,
                                                            input 0 /*bf_fin-doc.shift-num*/ ,
                                                            input bf_fin-doc.curr-code,
                                                            input bf_fin-doc.cashbookid,
                                                            input bf_sysconf.base-code,
                                                            input varznaksum-doc  ,
                                                            input varznaksum-rubl ,
                                                            input varznaksum-base ,
                                                            input varznaksum-vat-doc      ,
                                                            input varznaksum-vat-rubl     ,
                                                            input varznaksum-vat-base     ,
                                                            input varznaksum-slt-doc      ,
                                                            input varznaksum-slt-rubl     ,
                                                            input varznaksum-slt-base
                                                            ).
          if bf_fin-doc.shift-fact-order <> 0
          and v-is-cash
          then do:
          run libfarpo_calc-arh-fin-doc-schet-n-obj in g#libfarpo
                                                              (input parmode,
                                                                input bf_fin-doc.host-code,
                                                                input bf_fin-doc.obj-type,
                                                                input bf_fin-doc.obj-code,
                                                                input (if v-is-income then '' else  bf_fin-doc.payer-type),
                                                                input (if v-is-income then 0 else  bf_fin-doc.payer-code),
                                                                input (if v-is-expense then '' else  bf_fin-doc.receiver-type),
                                                                input (if v-is-expense then 0 else  bf_fin-doc.receiver-code),
                                                                input 0,
                                                                input 0,
                                                                input "",
                                                                input {&arh-fin-doc-schet-nal-obj-shift-obj},
                                                                input bf_fin-doc.shift-fact-order,
                                                                input bf_fin-doc.fin-doc-code,
                                                                input bf_fin-doc.fact-date,
                                                                input bf_fin-doc.shift-date,
                                                                input bf_fin-doc.shift-num,
                                                                input bf_fin-doc.curr-code,
                                                                input bf_fin-doc.cashbookid,
                                                                input bf_sysconf.base-code,
                                                                input varznaksum-doc  ,
                                                                input varznaksum-rubl ,
                                                                input varznaksum-base ,
                                                                input varznaksum-vat-doc      ,
                                                                input varznaksum-vat-rubl     ,
                                                                input varznaksum-vat-base     ,
                                                                input varznaksum-slt-doc      ,
                                                                input varznaksum-slt-rubl     ,
                                                                input varznaksum-slt-base
                                                                ).
          end. /*if bf_fin-doc.shift-fact-order <> 0*/
        end. /*if bf_fin-doc.trn-doc-code = bf_fin-doc.obj-type + string(bf_fin-doc.obj-code, "99999") then do:*/
      end. /* if pararh-name = "all":u                           or
             lookup ({&table_arh-fin-doc-schet-nal-obj}, pararh-name) > 0 then do:   */
    end.  /* if not (bf_fin-doc.obj-type = ''
            and bf_fin-doc.obj-code = 0) then do:   */
  end.  /*else /*if v-is-cashless*/*/
  if pararh-name = "all":u                               or
  lookup ({&table_arh-fin-doc-schet-tax}, pararh-name) > 0 or
  lookup ({&table_arh-fin-doc-schet-tax-obj}, pararh-name) > 0 or
  lookup ({&table_arh-fin-doc-schet-tax-nal}, pararh-name) > 0  or
  lookup ({&table_arh-fin-doc-s-tax-nal-obj}, pararh-name) > 0      then do:
    for each tt-sum-fin-doc-tax on error undo, return error return-value :
      delete tt-sum-fin-doc-tax.
    end.
    for each bf_fin-doc-tax where bf_fin-doc-tax.host-code    = bf_fin-doc.host-code    and
                                  bf_fin-doc-tax.fin-doc-code = bf_fin-doc.fin-doc-code
                                  break by bf_fin-doc-tax.host-code by bf_fin-doc-tax.fin-doc-code by round(bf_fin-doc-tax.vat-pc, 0) by round(bf_fin-doc-tax.slt-pc, 0) by bf_fin-doc-tax.with-vat by bf_fin-doc-tax.with-slt
                                  on error undo, return error return-value :
      assign
        varfin-doc-tax-vat-pc = round(bf_fin-doc-tax.vat-pc, 0)
        varfin-doc-tax-slt-pc = round(bf_fin-doc-tax.slt-pc, 0)
      .
      if first-of (bf_fin-doc-tax.with-slt) then do:
        create tt-sum-fin-doc-tax.
        assign
          tt-sum-fin-doc-tax.vat-pc   = varfin-doc-tax-vat-pc
          tt-sum-fin-doc-tax.slt-pc   = varfin-doc-tax-slt-pc
          tt-sum-fin-doc-tax.with-vat = bf_fin-doc-tax.with-vat
          tt-sum-fin-doc-tax.with-slt = bf_fin-doc-tax.with-slt
        .
      end.
      find first tt-sum-fin-doc-tax where tt-sum-fin-doc-tax.vat-pc   = varfin-doc-tax-vat-pc   and
                                          tt-sum-fin-doc-tax.slt-pc   = varfin-doc-tax-slt-pc   and
                                          tt-sum-fin-doc-tax.with-vat = bf_fin-doc-tax.with-vat and
                                          tt-sum-fin-doc-tax.with-slt = bf_fin-doc-tax.with-slt no-error.
      assign
        tt-sum-fin-doc-tax.sum-line-doc   = tt-sum-fin-doc-tax.sum-line-doc   + bf_fin-doc-tax.sum-line-doc
        tt-sum-fin-doc-tax.sum-line-rubl  = tt-sum-fin-doc-tax.sum-line-rubl  + bf_fin-doc-tax.sum-line-rubl
        tt-sum-fin-doc-tax.sum-line-base  = tt-sum-fin-doc-tax.sum-line-base  + bf_fin-doc-tax.sum-line-base
        tt-sum-fin-doc-tax.sum-line-contr = tt-sum-fin-doc-tax.sum-line-contr + bf_fin-doc-tax.sum-line-contr
        tt-sum-fin-doc-tax.sum-vat-rubl   = tt-sum-fin-doc-tax.sum-vat-rubl   + bf_fin-doc-tax.sum-vat-line-rubl
        tt-sum-fin-doc-tax.sum-vat-base   = tt-sum-fin-doc-tax.sum-vat-base   + bf_fin-doc-tax.sum-vat-line-base
        tt-sum-fin-doc-tax.sum-vat-contr  = tt-sum-fin-doc-tax.sum-vat-contr  + bf_fin-doc-tax.sum-vat-line-contr
        tt-sum-fin-doc-tax.sum-vat-doc    = tt-sum-fin-doc-tax.sum-vat-doc    + bf_fin-doc-tax.sum-vat-line-doc
        tt-sum-fin-doc-tax.sum-slt-rubl   = tt-sum-fin-doc-tax.sum-slt-rubl   + bf_fin-doc-tax.sum-slt-line-rubl
        tt-sum-fin-doc-tax.sum-slt-base   = tt-sum-fin-doc-tax.sum-slt-base   + bf_fin-doc-tax.sum-slt-line-base
        tt-sum-fin-doc-tax.sum-slt-contr  = tt-sum-fin-doc-tax.sum-slt-contr  + bf_fin-doc-tax.sum-slt-line-contr
        tt-sum-fin-doc-tax.sum-slt-doc    = tt-sum-fin-doc-tax.sum-slt-doc    + bf_fin-doc-tax.sum-slt-line-doc
      .
      if last-of (bf_fin-doc-tax.with-slt) then do:
        if v-is-cashless then do:
          if (pararh-name = "all":u                               or
          lookup ({&table_arh-fin-doc-schet-tax}, pararh-name) > 0 )   and  v-curr-db-num = v-obj-db-num
          then do:
          if bf_sysconf.firm-db-num = v-curr-db-num then
          run libfarhp_calc-arh-fin-doc-schet-tax in g#libfarhp (input parmode,
                                                                 input bf_fin-doc.host-code,
                                                                 input bf_fin-doc.payer-type,
                                                                 input bf_fin-doc.payer-code,
                                                                 input bf_fin-doc.receiver-type,
                                                                 input bf_fin-doc.receiver-code,
                                                                 input bf_fin-doc.payer-code-schet,
                                                                 input bf_fin-doc.receiver-code-schet,
                                                                 input bf_fin-doc.fin-ext-doc-type,
                                                                 input {&arh-fin-doc-schet-tax-atom},
                                                                 input bf_fin-doc.fact-order,
                                                                 input bf_fin-doc.fin-doc-code,
                                                                 input bf_fin-doc.fact-date,
                                                                 input bf_fin-doc.curr-code,
                                                                 input bf_sysconf.base-code,
                                                                 input varfin-doc-tax-vat-pc,
                                                                 input varfin-doc-tax-slt-pc,
                                                                 input bf_fin-doc-tax.with-vat,
                                                                 input bf_fin-doc-tax.with-slt,
                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-doc   else - tt-sum-fin-doc-tax.sum-line-doc      ) ,
                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl     ) ,
                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-base  else - tt-sum-fin-doc-tax.sum-line-base     ) ,
                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-contr else - tt-sum-fin-doc-tax.sum-line-contr    ) ,
                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-doc    else - tt-sum-fin-doc-tax.sum-vat-doc  ) ,
                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl ) ,
                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-base   else - tt-sum-fin-doc-tax.sum-vat-base ) ,
                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-contr  else - tt-sum-fin-doc-tax.sum-vat-contr) ,
                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-doc    else - tt-sum-fin-doc-tax.sum-slt-doc  ) ,
                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl ) ,
                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-base   else - tt-sum-fin-doc-tax.sum-slt-base ) ,
                                                                 input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-contr  else - tt-sum-fin-doc-tax.sum-slt-contr)
                                                                 ).
          end. /*if pararh-name = "all":u                               or*/
        end. /*if v-is-cashless*/
        else do:
          if (pararh-name = "all":u                               or
          lookup ({&table_arh-fin-doc-schet-tax-nal}, pararh-name) > 0 )   and  v-curr-db-num = v-obj-db-num
          then do:
          if bf_sysconf.firm-db-num = v-curr-db-num then
          run libfarhp_calc-arh-fin-doc-schet-tax-n in g#libfarhp (input parmode,
                                                                   input bf_fin-doc.host-code,
                                                                   input bf_fin-doc.payer-type,
                                                                   input bf_fin-doc.payer-code,
                                                                   input bf_fin-doc.receiver-type,
                                                                   input bf_fin-doc.receiver-code,
                                                                   input (if v-is-income then bf_fin-doc.cor-acc1 else bf_fin-doc.cor-acc ),
                                                                   input (if v-is-income then bf_fin-doc.cor-acc  else bf_fin-doc.cor-acc1),
                                                                   input bf_fin-doc.fin-ext-doc-type,
                                                                   input {&arh-fin-doc-schet-tax-nal-atom},
                                                                   input bf_fin-doc.fact-order,
                                                                   input bf_fin-doc.fin-doc-code,
                                                                   input bf_fin-doc.fact-date,
                                                                   input bf_fin-doc.curr-code,
                                                                   input bf_sysconf.base-code,
                                                                   input varfin-doc-tax-vat-pc,
                                                                   input varfin-doc-tax-slt-pc,
                                                                   input bf_fin-doc-tax.with-vat,
                                                                   input bf_fin-doc-tax.with-slt,
                                                                   input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-doc   else - tt-sum-fin-doc-tax.sum-line-doc      ) ,
                                                                   input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-rubl  else - tt-sum-fin-doc-tax.sum-line-rubl     ) ,
                                                                   input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-base  else - tt-sum-fin-doc-tax.sum-line-base     ) ,
                                                                   input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-line-contr else - tt-sum-fin-doc-tax.sum-line-contr    ) ,
                                                                   input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-doc    else - tt-sum-fin-doc-tax.sum-vat-doc  ) ,
                                                                   input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-rubl   else - tt-sum-fin-doc-tax.sum-vat-rubl ) ,
                                                                   input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-base   else - tt-sum-fin-doc-tax.sum-vat-base ) ,
                                                                   input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-vat-contr  else - tt-sum-fin-doc-tax.sum-vat-contr) ,
                                                                   input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-doc    else - tt-sum-fin-doc-tax.sum-slt-doc  ) ,
                                                                   input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-rubl   else - tt-sum-fin-doc-tax.sum-slt-rubl ) ,
                                                                   input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-base   else - tt-sum-fin-doc-tax.sum-slt-base ) ,
                                                                   input (if parmode = "close":u then tt-sum-fin-doc-tax.sum-slt-contr  else - tt-sum-fin-doc-tax.sum-slt-contr)
                                                                   ).
          end. /*if pararh-name = "all":u                               or*/
        end. /*else if v-is-cashless*/
      end.  /*if last-of (bf_fin-doc-tax.with-slt) then do:*/
    end. /*    for each bf_fin-doc-tax where bf_fin-doc-tax.host-code    = bf_fin-doc.host-code    and*/
  end. /*  if pararh-name = "all":u                               or
            lookup ({&table_arh-fin-doc-schet-tax}, pararh-name) > 0 or
            lookup ({&table_arh-fin-doc-schet-tax-obj}, pararh-name) > 0 or
            lookup ({&table_arh-fin-doc-schet-tax-nal}, pararh-name) > 0  or
            lookup ({&table_arh-fin-doc-s-tax-nal-obj}, pararh-name) > 0 or
            then do:  */
end. /*doe*/
end procedure.
procedure calc-sum:
define input parameter parmode         as   character               no-undo.
define input parameter parhost-code    like ub.fin-doc.host-code    no-undo.
define input parameter parfin-doc-code like ub.fin-doc.fin-doc-code no-undo.
define output parameter varznaksum-doc        as decimal no-undo.
define output parameter varznaksum-rubl       as decimal no-undo.
define output parameter varznaksum-base       as decimal no-undo.
define output parameter varznaksum-contr      as decimal no-undo.
define output parameter varznaksum-vat-doc    as decimal no-undo.
define output parameter varznaksum-vat-rubl   as decimal no-undo.
define output parameter varznaksum-vat-base   as decimal no-undo.
define output parameter varznaksum-vat-contr  as decimal no-undo.
define output parameter varznaksum-slt-doc    as decimal no-undo.
define output parameter varznaksum-slt-rubl   as decimal no-undo.
define output parameter varznaksum-slt-base   as decimal no-undo.
define output parameter varznaksum-slt-contr  as decimal no-undo.
define variable varsum-vat-doc        as   decimal               no-undo.
define variable varsum-vat-rubl       as   decimal               no-undo.
define variable varsum-vat-base       as   decimal               no-undo.
define variable varsum-vat-contr      as   decimal               no-undo.
define variable varsum-slt-doc        as   decimal               no-undo.
define variable varsum-slt-rubl       as   decimal               no-undo.
define variable varsum-slt-base       as   decimal               no-undo.
define variable varsum-slt-contr      as   decimal               no-undo.
define buffer bf_fin-doc     for ub.fin-doc.
define buffer bf_fin-doc-tax for ub.fin-doc-tax.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status :get-message(1), error-status :get-message(2) ):
find first bf_fin-doc where bf_fin-doc.host-code    = parhost-code    and
                            bf_fin-doc.fin-doc-code = parfin-doc-code.
assign
  varsum-vat-doc   = 0
  varsum-vat-rubl  = 0
  varsum-vat-base  = 0
  varsum-vat-contr = 0
  varsum-slt-doc   = 0
  varsum-slt-rubl  = 0
  varsum-slt-base  = 0
  varsum-slt-contr = 0 .
for each bf_fin-doc-tax where bf_fin-doc-tax.host-code    = bf_fin-doc.host-code    and
                              bf_fin-doc-tax.fin-doc-code = bf_fin-doc.fin-doc-code on error undo, return error return-value :
   assign
     varsum-vat-doc   = varsum-vat-doc   + bf_fin-doc-tax.sum-vat-line-doc
     varsum-vat-rubl  = varsum-vat-rubl  + bf_fin-doc-tax.sum-vat-line-rubl
     varsum-vat-base  = varsum-vat-base  + bf_fin-doc-tax.sum-vat-line-base
     varsum-vat-contr = varsum-vat-contr + bf_fin-doc-tax.sum-vat-line-contr
     varsum-slt-doc   = varsum-slt-doc   + bf_fin-doc-tax.sum-slt-line-doc
     varsum-slt-rubl  = varsum-slt-rubl  + bf_fin-doc-tax.sum-slt-line-rubl
     varsum-slt-base  = varsum-slt-base  + bf_fin-doc-tax.sum-slt-line-base
     varsum-slt-contr = varsum-slt-contr + bf_fin-doc-tax.sum-slt-line-contr
  .
end.

assign
  varznaksum-doc       = (if parmode = "close":u then bf_fin-doc.sum-doc   else - bf_fin-doc.sum-doc   )
  varznaksum-rubl      = (if parmode = "close":u then bf_fin-doc.sum-rubl  else - bf_fin-doc.sum-rubl  )
  varznaksum-base      = (if parmode = "close":u then bf_fin-doc.sum-base  else - bf_fin-doc.sum-base  )
  varznaksum-contr     = (if parmode = "close":u then bf_fin-doc.sum-contr else - bf_fin-doc.sum-contr )
  varznaksum-vat-doc   = (if parmode = "close":u then varsum-vat-doc       else - varsum-vat-doc       )
  varznaksum-vat-rubl  = (if parmode = "close":u then varsum-vat-rubl      else - varsum-vat-rubl      )
  varznaksum-vat-base  = (if parmode = "close":u then varsum-vat-base      else - varsum-vat-base      )
  varznaksum-vat-contr = (if parmode = "close":u then varsum-vat-contr     else - varsum-vat-contr     )
  varznaksum-slt-doc   = (if parmode = "close":u then varsum-slt-doc       else - varsum-slt-doc       )
  varznaksum-slt-rubl  = (if parmode = "close":u then varsum-slt-rubl      else - varsum-slt-rubl      )
  varznaksum-slt-base  = (if parmode = "close":u then varsum-slt-base      else - varsum-slt-base      )
  varznaksum-slt-contr = (if parmode = "close":u then varsum-slt-contr     else - varsum-slt-contr     )
.
end.
end procedure.

procedure check-attr-doc:
define input parameter parhost-code    like ub.fin-doc.host-code    no-undo.
define input parameter parfin-doc-code like ub.fin-doc.fin-doc-code no-undo.
define buffer bf-payer_fin-schet         for ub.fin-schet.
define buffer bf-receiver_fin-schet      for ub.fin-schet.
define buffer bf-first_fin-code-cor-acc  for ub.fin-code-cor-acc.
define buffer bf-second_fin-code-cor-acc for ub.fin-code-cor-acc.
define buffer bf_fin-code-an-uchet       for ub.fin-code-an-uchet.
define buffer bf_fin-code-cel-nazn       for ub.fin-code-cel-nazn.
define buffer bf_fin-doc                 for ub.fin-doc.
define buffer bf_sysconf                 for ub.sysconf.
do on error undo, return error return-value :
find first bf_fin-doc where bf_fin-doc.host-code    = parhost-code    and
                            bf_fin-doc.fin-doc-code = parfin-doc-code.
  find first bf_sysconf where bf_sysconf.host-code = bf_fin-doc.host-code no-lock.
  if bf_fin-doc.fin-ext-doc-type = {&FDEDT_income_cashless}  or
     bf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
     then do:
    find first bf-payer_fin-schet where bf-payer_fin-schet.host-code  = bf_fin-doc.host-code        and
                                        bf-payer_fin-schet.code-schet = bf_fin-doc.payer-code-schet no-lock no-error.
    if not available bf-payer_fin-schet then do:
      return error substitute ("Не найден счет плательщика по фирме &1. Внутренний номер счета &2.", bf_fin-doc.host-code, bf_fin-doc.payer-code-schet).
    end.
    find first bf-receiver_fin-schet where bf-receiver_fin-schet.host-code  = bf_fin-doc.host-code           and
                                           bf-receiver_fin-schet.code-schet = bf_fin-doc.receiver-code-schet no-lock no-error.
    if not available bf-receiver_fin-schet then do:
      return error substitute ("Не найден счет получателя по фирме &1. Внутренний номер счета &2.", bf_fin-doc.host-code, bf_fin-doc.receiver-code-schet).
    end.
    if bf-payer_fin-schet.curr-code <> bf-receiver_fin-schet.curr-code then do:
      return error substitute ("Счета плательщика и получателя документа с внутренним номером &1 на фирме &2 имеют разную валюту.", bf_fin-doc.fin-doc-code, bf_fin-doc.host-code).
    end.
  end.
  else do:
    find first bf-first_fin-code-cor-acc where bf-first_fin-code-cor-acc.host-code = bf_fin-doc.host-code and
                                               bf-first_fin-code-cor-acc.fin-code  = bf_fin-doc.cor-acc   no-lock no-error.
    if not available bf-first_fin-code-cor-acc then do:
      if bf_sysconf.is-corr-acc then do:
        return error substitute ("Не найден корреспондирующий счет по фирме &1. Внутренний номер счета &2.", bf_fin-doc.host-code, bf_fin-doc.cor-acc).
      end.
    end.
    find first bf-second_fin-code-cor-acc where bf-second_fin-code-cor-acc.host-code = bf_fin-doc.host-code and
                                                bf-second_fin-code-cor-acc.fin-code  = bf_fin-doc.cor-acc1  no-lock no-error.
    if not available bf-second_fin-code-cor-acc then do:
      /* EXPSD-8392 временная заплатка для удаления док-та переноса остатков. Смоделировать создание такого док-та не удалось */
      if bf_sysconf.is-cassa-acc and not bf_fin-doc.prn-doc-code begins "тех" and program-name(3) <> "trg/finddocdl.p" then do:
        return error substitute ("Не найден корреспондирующий счет по фирме &1. Внутренний номер счета &2.", bf_fin-doc.host-code, bf_fin-doc.cor-acc1).
      end.
    end.
  end.
  find first bf_fin-code-an-uchet where bf_fin-code-an-uchet.host-code = bf_fin-doc.host-code     and
                                        bf_fin-code-an-uchet.fin-code  = bf_fin-doc.an-uchet-code no-lock no-error.
  if not available bf_fin-code-an-uchet then do:
    if bf_sysconf.is-an-uchet then do:
      return error substitute ("Не найден код аналитического учета по фирме &1. Код аналитического учета &2.", bf_fin-doc.host-code, bf_fin-doc.an-uchet-code).
    end.
  end.
  find first bf_fin-code-cel-nazn where bf_fin-code-cel-nazn.host-code = bf_fin-doc.host-code     and
                                        bf_fin-code-cel-nazn.fin-code  = bf_fin-doc.cel-nazn-code no-lock no-error.
  if not available bf_fin-code-cel-nazn then do:
    if bf_sysconf.is-code-cel-nazn then do:
      return error substitute ("Не найден код целевого назначения по фирме &1. Код целевого назначения &2.", bf_fin-doc.host-code, bf_fin-doc.cel-nazn-code).
    end.
  end.
  if not (bf_fin-doc.fin-ext-doc-type = {&FDEDT_income_cash}      or
          bf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cash}     or
          bf_fin-doc.fin-ext-doc-type = {&FDEDT_income_cashless}  or
          bf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless} or
          bf_fin-doc.fin-ext-doc-type = {&FDEDT_income_payoff}    or
          bf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_payoff}   ) then do:
    return error substitute ("Неизвестный расширенный тип &1 платежного документа с номером &2 внутренний номер &3.", bf_fin-doc.fin-ext-doc-type, bf_fin-doc.prn-doc-code, bf_fin-doc.fin-doc-code).
  end.

end.
end procedure.

procedure full-lock:
define input parameter parhost-code    like ub.fin-doc.host-code    no-undo.
define input parameter parfin-doc-code like ub.fin-doc.fin-doc-code no-undo.
define input parameter paruser-name    as   character               no-undo.
define buffer bf_fin-doc     for ub.fin-doc.
do on error undo, return error return-value :
find first bf_fin-doc where bf_fin-doc.host-code    = parhost-code    and
                            bf_fin-doc.fin-doc-code = parfin-doc-code.
  case bf_fin-doc.fin-ext-doc-type :
    when {&FDEDT_income_cash}    or
    when {&FDEDT_expense_cash}   or
    when {&FDEDT_income_payoff}  or
    when {&FDEDT_expense_payoff} then do:
      /*Локируем кореспондирующие счета. Никто более по ним в данный момент не сможет рассчитывать архивы.*/
      run lib-farh_lkcordoc in this-procedure (input bf_fin-doc.host-code,
                                               input bf_fin-doc.cor-acc,
                                               input paruser-name,
                                               input bf_fin-doc.fin-doc-code) no-error.
      if error-status:error then do:
        return error return-value.
      end.
      run lib-farh_lkcordoc in this-procedure (input bf_fin-doc.host-code,
                                               input bf_fin-doc.cor-acc1,
                                               input paruser-name,
                                               input bf_fin-doc.fin-doc-code) no-error.
      if error-status:error then do:
        return error return-value.
      end.
    end.
    when {&FDEDT_income_cashless}  or
    when {&FDEDT_expense_cashless} then do:
      /*Локируем счета. Никто более по ним в данный момент не сможет рассчитывать архивы.*/
      run lib-farh_lkschdoc in this-procedure (input bf_fin-doc.host-code,
                                               input bf_fin-doc.payer-code-schet,
                                               input paruser-name,
                                               input bf_fin-doc.fin-doc-code) no-error.
      if error-status:error then do:
        return error return-value.
      end.
      run lib-farh_lkschdoc in this-procedure (input bf_fin-doc.host-code,
                                               input bf_fin-doc.receiver-code-schet,
                                               input paruser-name,
                                               input bf_fin-doc.fin-doc-code) no-error.
      if error-status:error then do:
        return error return-value.
      end.
    end.
    otherwise do:
      return error substitute ("Неизвестный расширенный тип &1 платежного документа с номером &2 внутренний номер &3.", bf_fin-doc.fin-ext-doc-type, bf_fin-doc.prn-doc-code, bf_fin-doc.fin-doc-code).
    end.
  end case.
end.
end procedure.

procedure check-sum-doc:
define input parameter parhost-code     like ub.fin-doc.host-code    no-undo.
define input parameter parfin-doc-code  like ub.fin-doc.fin-doc-code no-undo.
define output parameter varhave-connect as   logical                 no-undo.
define buffer bf_fin-doc     for ub.fin-doc.
define buffer bf_fin-doc-tax for ub.fin-doc-tax.
define buffer bf_fin-connect for ub.fin-connect.
define buffer bf_clients     for ub.clients.
define buffer bf_fin-ob      for ub.fin-ob.
define buffer bf_fin-ob-tax  for ub.fin-ob-tax.
define variable varsum-vat-rubl-ob    as   decimal               no-undo.
define variable varsum-vat-base-ob    as   decimal               no-undo.
define variable varsum-vat-contr-ob   as   decimal               no-undo.
define variable varsum-vat-doc-ob     as   decimal               no-undo.
define variable varsum-slt-rubl-ob    as   decimal               no-undo.
define variable varsum-slt-base-ob    as   decimal               no-undo.
define variable varsum-slt-contr-ob   as   decimal               no-undo.
define variable varsum-slt-doc-ob     as   decimal               no-undo.
define variable varsum-vat-rubl-tot   as   decimal               no-undo.
define variable varsum-vat-base-tot   as   decimal               no-undo.
define variable varsum-vat-contr-tot  as   decimal               no-undo.
define variable varsum-vat-doc-tot    as   decimal               no-undo.
define variable varsum-slt-rubl-tot   as   decimal               no-undo.
define variable varsum-slt-base-tot   as   decimal               no-undo.
define variable varsum-slt-contr-tot  as   decimal               no-undo.
define variable varsum-slt-doc-tot    as   decimal               no-undo.
define variable varsum-line-doc       as   decimal               no-undo.
define variable varsum-line-rubl      as   decimal               no-undo.
define variable varsum-line-base      as   decimal               no-undo.
define variable varsum-line-contr     as   decimal               no-undo.
define variable varsum-vat-rubl-line  as   decimal               no-undo.
define variable varsum-vat-base-line  as   decimal               no-undo.
define variable varsum-vat-contr-line as   decimal               no-undo.
define variable varsum-vat-doc-line   as   decimal               no-undo.
define variable varsum-slt-rubl-line  as   decimal               no-undo.
define variable varsum-slt-base-line  as   decimal               no-undo.
define variable varsum-slt-contr-line as   decimal               no-undo.
define variable varsum-slt-doc-line   as   decimal               no-undo.
define variable varsum-rubl           as   decimal               no-undo.
define variable varsum-base           as   decimal               no-undo.
define variable varsum-contr          as   decimal               no-undo.
define variable varsum-doc            as   decimal               no-undo.
do on error undo, return error return-value :
find first bf_fin-doc where bf_fin-doc.host-code    = parhost-code    and
                            bf_fin-doc.fin-doc-code = parfin-doc-code.
for each tt-sum-con-fin-ob-obj on error undo, return error return-value :
  delete tt-sum-con-fin-ob-obj.
end.
for each tt-sum-con-fin-ob-tax-obj on error undo, return error return-value :
  delete tt-sum-con-fin-ob-tax-obj.
end.
for each tt-sum-fin-doc-tax on error undo, return error return-value :
  delete tt-sum-fin-doc-tax.
end.
for each tt-sum-fin-ob-tax on error undo, return error return-value :
  delete tt-sum-fin-ob-tax.
end.
find first bf_fin-connect where bf_fin-connect.host-code    = bf_fin-doc.host-code    and
                                bf_fin-connect.fin-doc-code = bf_fin-doc.fin-doc-code no-error.
if not available bf_fin-connect then do:
  if bf_fin-doc.obj-type = "":u and
     bf_fin-doc.obj-code = 0    then do:
    return error substitute ("По фирме &1 ведется финансовый учет по объектам. В платежном документе &2 с внутренним номером &3 не указан объект",
                             bf_fin-doc.host-code,
                             bf_fin-doc.prn-doc-code,
                             bf_fin-doc.fin-doc-code).
  end.
  find first bf_clients where bf_clients.obj-type = bf_fin-doc.obj-type and
                              bf_clients.obj-code = bf_fin-doc.obj-code no-lock no-error.
  if not available bf_clients then do:
    return error substitute ("По фирме &1 ведется финансовый учет по объектам. В платежном документе &2 с внутренним номером &3 указан объект &4 &5 которого нет в справочнике.",
                             bf_fin-doc.host-code,
                             bf_fin-doc.prn-doc-code,
                             bf_fin-doc.fin-doc-code,
                             bf_fin-doc.obj-type,
                             bf_fin-doc.obj-code).
  end.
  assign
    varhave-connect = no.
end.
else do:
  assign
    varhave-connect = yes.
  for each bf_fin-connect where bf_fin-connect.host-code    = bf_fin-doc.host-code    and
                                bf_fin-connect.fin-doc-code = bf_fin-doc.fin-doc-code on error undo, return error return-value :
    find first bf_fin-ob where bf_fin-ob.host-code = bf_fin-connect.host-code   and
                               bf_fin-ob.doc-code  = bf_fin-connect.fin-ob-code no-error.
    if not available bf_fin-ob then do:
      return error substitute ("Финансовый документ по фирме &1 с внутренним номером &2 имеет связь с финансовым обязательством с внутренним номером &3. Но этого финансового обязательства нет в базе данных.",
                               bf_fin-doc.host-code,
                               bf_fin-doc.fin-doc-code,
                               bf_fin-ob.doc-code).
    end.
    if bf_fin-ob.contract-code <> bf_fin-doc.contract-code then do:
      return error substitute ("Финансовый документ по фирме &1 с внутренним номером &2 имеет связь с финансовым обязательством с внутренним номером &3. Внутренний номер договора по финансовому документу &4. Внутренний номер договора по финансовому обязательству &5. Это недопустимо.",
                               bf_fin-doc.host-code,
                               bf_fin-doc.fin-doc-code,
                               bf_fin-ob.doc-code,
                               bf_fin-doc.contract-code,
                               bf_fin-ob.contract-code).
    end.
    assign
      varsum-rubl  = varsum-rubl  + bf_fin-connect.sum-rubl
      varsum-base  = varsum-base  + bf_fin-connect.sum-base
      varsum-contr = varsum-contr + bf_fin-connect.sum-contr
      varsum-doc   = varsum-doc   + bf_fin-connect.sum-doc.
    find first tt-sum-con-fin-ob-obj where tt-sum-con-fin-ob-obj.obj-type = bf_fin-ob.obj-type and
                                           tt-sum-con-fin-ob-obj.obj-code = bf_fin-ob.obj-code no-error.
    if not available tt-sum-con-fin-ob-obj then do:
      create tt-sum-con-fin-ob-obj.
      assign
        tt-sum-con-fin-ob-obj.obj-type = bf_fin-ob.obj-type
        tt-sum-con-fin-ob-obj.obj-code = bf_fin-ob.obj-code
      .
    end.
    assign
      tt-sum-con-fin-ob-obj.sum-base  = tt-sum-con-fin-ob-obj.sum-base  + bf_fin-connect.sum-base
      tt-sum-con-fin-ob-obj.sum-rubl  = tt-sum-con-fin-ob-obj.sum-rubl  + bf_fin-connect.sum-rubl
      tt-sum-con-fin-ob-obj.sum-contr = tt-sum-con-fin-ob-obj.sum-contr + bf_fin-connect.sum-contr
      tt-sum-con-fin-ob-obj.sum-doc   = tt-sum-con-fin-ob-obj.sum-doc   + bf_fin-connect.sum-doc
    .
    for each bf_fin-ob-tax where bf_fin-ob-tax.host-code = bf_fin-ob.host-code and
                                 bf_fin-ob-tax.doc-code  = bf_fin-ob.doc-code  on error undo, return error return-value :
      find first tt-sum-con-fin-ob-tax-obj where tt-sum-con-fin-ob-tax-obj.obj-type = bf_fin-ob.obj-type     and
                                                 tt-sum-con-fin-ob-tax-obj.obj-code = bf_fin-ob.obj-code     and
                                                 tt-sum-con-fin-ob-tax-obj.vat-pc   = bf_fin-ob-tax.vat-pc   and
                                                 tt-sum-con-fin-ob-tax-obj.slt-pc   = bf_fin-ob-tax.slt-pc   and
                                                 tt-sum-con-fin-ob-tax-obj.with-vat = bf_fin-ob-tax.with-vat and
                                                 tt-sum-con-fin-ob-tax-obj.with-slt = bf_fin-ob-tax.with-slt no-error.
      if not available tt-sum-con-fin-ob-tax-obj then do:
        create tt-sum-con-fin-ob-tax-obj.
        assign
          tt-sum-con-fin-ob-tax-obj.obj-type = bf_fin-ob.obj-type
          tt-sum-con-fin-ob-tax-obj.obj-code = bf_fin-ob.obj-code
          tt-sum-con-fin-ob-tax-obj.vat-pc   = bf_fin-ob-tax.vat-pc
          tt-sum-con-fin-ob-tax-obj.slt-pc   = bf_fin-ob-tax.slt-pc
          tt-sum-con-fin-ob-tax-obj.with-vat = bf_fin-ob-tax.with-vat
          tt-sum-con-fin-ob-tax-obj.with-slt = bf_fin-ob-tax.with-slt
        .
      end.
      if bf_fin-ob.sum-rubl = bf_fin-connect.sum-rubl then do:
        assign
          varsum-line-doc       = bf_fin-ob-tax.sum-line-doc
          varsum-line-rubl      = bf_fin-ob-tax.sum-line-rubl
          varsum-line-base      = bf_fin-ob-tax.sum-line-base
          varsum-line-contr     = bf_fin-ob-tax.sum-line-contr
          varsum-vat-rubl-line  = bf_fin-ob-tax.sum-vat-line-rubl
          varsum-vat-base-line  = bf_fin-ob-tax.sum-vat-line-base
          varsum-vat-contr-line = bf_fin-ob-tax.sum-vat-line-contr
          varsum-vat-doc-line   = bf_fin-ob-tax.sum-vat-line-doc
          varsum-slt-rubl-line  = bf_fin-ob-tax.sum-slt-line-rubl
          varsum-slt-base-line  = bf_fin-ob-tax.sum-slt-line-base
          varsum-slt-contr-line = bf_fin-ob-tax.sum-slt-line-contr
          varsum-slt-doc-line   = bf_fin-ob-tax.sum-slt-line-doc
        .
      end.
      else do:
        assign
          varsum-line-doc       = bf_fin-ob-tax.sum-line-doc        * (bf_fin-connect.sum-rubl / bf_fin-ob.sum-rubl)
          varsum-line-rubl      = bf_fin-ob-tax.sum-line-rubl       * (bf_fin-connect.sum-rubl / bf_fin-ob.sum-rubl)
          varsum-line-base      = bf_fin-ob-tax.sum-line-base       * (bf_fin-connect.sum-rubl / bf_fin-ob.sum-rubl)
          varsum-line-contr     = bf_fin-ob-tax.sum-line-contr      * (bf_fin-connect.sum-rubl / bf_fin-ob.sum-rubl)
          varsum-vat-rubl-line  = bf_fin-ob-tax.sum-vat-line-rubl   * (bf_fin-connect.sum-rubl / bf_fin-ob.sum-rubl)
          varsum-vat-base-line  = bf_fin-ob-tax.sum-vat-line-base   * (bf_fin-connect.sum-rubl / bf_fin-ob.sum-rubl)
          varsum-vat-contr-line = bf_fin-ob-tax.sum-vat-line-contr  * (bf_fin-connect.sum-rubl / bf_fin-ob.sum-rubl)
          varsum-vat-doc-line   = bf_fin-ob-tax.sum-vat-line-doc    * (bf_fin-connect.sum-rubl / bf_fin-ob.sum-rubl)
          varsum-slt-rubl-line  = bf_fin-ob-tax.sum-slt-line-rubl   * (bf_fin-connect.sum-rubl / bf_fin-ob.sum-rubl)
          varsum-slt-base-line  = bf_fin-ob-tax.sum-slt-line-base   * (bf_fin-connect.sum-rubl / bf_fin-ob.sum-rubl)
          varsum-slt-contr-line = bf_fin-ob-tax.sum-slt-line-contr  * (bf_fin-connect.sum-rubl / bf_fin-ob.sum-rubl)
          varsum-slt-doc-line   = bf_fin-ob-tax.sum-slt-line-doc    * (bf_fin-connect.sum-rubl / bf_fin-ob.sum-rubl)
        .
      end.
      assign
        tt-sum-con-fin-ob-tax-obj.sum-doc        = tt-sum-con-fin-ob-tax-obj.sum-doc        + varsum-line-doc
        tt-sum-con-fin-ob-tax-obj.sum-rubl       = tt-sum-con-fin-ob-tax-obj.sum-rubl       + varsum-line-rubl
        tt-sum-con-fin-ob-tax-obj.sum-base       = tt-sum-con-fin-ob-tax-obj.sum-base       + varsum-line-base
        tt-sum-con-fin-ob-tax-obj.sum-contr      = tt-sum-con-fin-ob-tax-obj.sum-contr      + varsum-line-contr
        tt-sum-con-fin-ob-tax-obj.sum-vat-rubl   = tt-sum-con-fin-ob-tax-obj.sum-vat-rubl   + varsum-vat-rubl-line
        tt-sum-con-fin-ob-tax-obj.sum-vat-base   = tt-sum-con-fin-ob-tax-obj.sum-vat-base   + varsum-vat-base-line
        tt-sum-con-fin-ob-tax-obj.sum-vat-contr  = tt-sum-con-fin-ob-tax-obj.sum-vat-contr  + varsum-vat-contr-line
        tt-sum-con-fin-ob-tax-obj.sum-vat-doc    = tt-sum-con-fin-ob-tax-obj.sum-vat-doc    + varsum-vat-doc-line
        tt-sum-con-fin-ob-tax-obj.sum-slt-rubl   = tt-sum-con-fin-ob-tax-obj.sum-slt-rubl   + varsum-slt-rubl-line
        tt-sum-con-fin-ob-tax-obj.sum-slt-base   = tt-sum-con-fin-ob-tax-obj.sum-slt-base   + varsum-slt-base-line
        tt-sum-con-fin-ob-tax-obj.sum-slt-contr  = tt-sum-con-fin-ob-tax-obj.sum-slt-contr  + varsum-slt-contr-line
        tt-sum-con-fin-ob-tax-obj.sum-slt-doc    = tt-sum-con-fin-ob-tax-obj.sum-slt-doc    + varsum-slt-doc-line
      .
      assign
        varsum-vat-rubl-ob  = varsum-vat-rubl-ob  + varsum-vat-rubl-line
        varsum-vat-base-ob  = varsum-vat-base-ob  + varsum-vat-base-line
        varsum-vat-contr-ob = varsum-vat-contr-ob + varsum-vat-contr-line
        varsum-vat-doc-ob   = varsum-vat-doc-ob   + varsum-vat-doc-line
        varsum-slt-rubl-ob  = varsum-slt-rubl-ob  + varsum-slt-rubl-line
        varsum-slt-base-ob  = varsum-slt-base-ob  + varsum-slt-base-line
        varsum-slt-contr-ob = varsum-slt-contr-ob + varsum-slt-contr-line
        varsum-slt-doc-ob   = varsum-slt-doc-ob   + varsum-slt-doc-line
      .
      find first tt-sum-fin-ob-tax where tt-sum-fin-ob-tax.vat-pc   = bf_fin-ob-tax.vat-pc   and
                                         tt-sum-fin-ob-tax.slt-pc   = bf_fin-ob-tax.slt-pc   and
                                         tt-sum-fin-ob-tax.with-vat = bf_fin-ob-tax.with-vat and
                                         tt-sum-fin-ob-tax.with-slt = bf_fin-ob-tax.with-slt no-error.
      if not available tt-sum-fin-ob-tax then do:
        create tt-sum-fin-ob-tax.
        assign
          tt-sum-fin-ob-tax.vat-pc   = bf_fin-ob-tax.vat-pc
          tt-sum-fin-ob-tax.slt-pc   = bf_fin-ob-tax.slt-pc
          tt-sum-fin-ob-tax.with-vat = bf_fin-ob-tax.with-vat
          tt-sum-fin-ob-tax.with-slt = bf_fin-ob-tax.with-slt
        .
      end.
      assign
        tt-sum-fin-ob-tax.sum-vat-rubl  = tt-sum-fin-ob-tax.sum-vat-rubl  + varsum-vat-rubl-line
        tt-sum-fin-ob-tax.sum-vat-base  = tt-sum-fin-ob-tax.sum-vat-base  + varsum-vat-base-line
        tt-sum-fin-ob-tax.sum-vat-contr = tt-sum-fin-ob-tax.sum-vat-contr + varsum-vat-contr-line
        tt-sum-fin-ob-tax.sum-vat-doc   = tt-sum-fin-ob-tax.sum-vat-doc   + varsum-vat-doc-line
        tt-sum-fin-ob-tax.sum-slt-rubl  = tt-sum-fin-ob-tax.sum-slt-rubl  + varsum-slt-rubl-line
        tt-sum-fin-ob-tax.sum-slt-base  = tt-sum-fin-ob-tax.sum-slt-base  + varsum-slt-base-line
        tt-sum-fin-ob-tax.sum-slt-contr = tt-sum-fin-ob-tax.sum-slt-contr + varsum-slt-contr-line
        tt-sum-fin-ob-tax.sum-slt-doc   = tt-sum-fin-ob-tax.sum-slt-doc   + varsum-slt-doc-line
      .
    end.
  end.
  for each bf_fin-doc-tax where bf_fin-doc-tax.host-code    = bf_fin-doc.host-code    and
                                bf_fin-doc-tax.fin-doc-code = bf_fin-doc.fin-doc-code on error undo, return error return-value :
    find first tt-sum-fin-doc-tax where tt-sum-fin-doc-tax.vat-pc   = bf_fin-doc-tax.vat-pc   and
                                        tt-sum-fin-doc-tax.slt-pc   = bf_fin-doc-tax.slt-pc   and
                                        tt-sum-fin-doc-tax.with-vat = bf_fin-doc-tax.with-vat and
                                        tt-sum-fin-doc-tax.with-slt = bf_fin-doc-tax.with-slt no-error.
    if not available tt-sum-fin-doc-tax then do:
      create tt-sum-fin-doc-tax.
      assign
        tt-sum-fin-doc-tax.vat-pc   = bf_fin-doc-tax.vat-pc
        tt-sum-fin-doc-tax.slt-pc   = bf_fin-doc-tax.slt-pc
        tt-sum-fin-doc-tax.with-vat = bf_fin-doc-tax.with-vat
        tt-sum-fin-doc-tax.with-slt = bf_fin-doc-tax.with-slt
      .
    end.
    assign
      tt-sum-fin-doc-tax.sum-vat-rubl  = tt-sum-fin-doc-tax.sum-vat-rubl  + bf_fin-doc-tax.sum-vat-line-rubl
      tt-sum-fin-doc-tax.sum-vat-base  = tt-sum-fin-doc-tax.sum-vat-base  + bf_fin-doc-tax.sum-vat-line-base
      tt-sum-fin-doc-tax.sum-vat-contr = tt-sum-fin-doc-tax.sum-vat-contr + bf_fin-doc-tax.sum-vat-line-contr
      tt-sum-fin-doc-tax.sum-vat-doc   = tt-sum-fin-doc-tax.sum-vat-doc   + bf_fin-doc-tax.sum-vat-line-doc
      tt-sum-fin-doc-tax.sum-slt-rubl  = tt-sum-fin-doc-tax.sum-slt-rubl  + bf_fin-doc-tax.sum-slt-line-rubl
      tt-sum-fin-doc-tax.sum-slt-base  = tt-sum-fin-doc-tax.sum-slt-base  + bf_fin-doc-tax.sum-slt-line-base
      tt-sum-fin-doc-tax.sum-slt-contr = tt-sum-fin-doc-tax.sum-slt-contr + bf_fin-doc-tax.sum-slt-line-contr
      tt-sum-fin-doc-tax.sum-slt-doc   = tt-sum-fin-doc-tax.sum-slt-doc   + bf_fin-doc-tax.sum-slt-line-doc
    .
    assign
      varsum-vat-rubl-tot  = varsum-vat-rubl-tot  +  bf_fin-doc-tax.sum-vat-line-rubl
      varsum-vat-base-tot  = varsum-vat-base-tot  +  bf_fin-doc-tax.sum-vat-line-base
      varsum-vat-contr-tot = varsum-vat-contr-tot +  bf_fin-doc-tax.sum-vat-line-contr
      varsum-vat-doc-tot   = varsum-vat-doc-tot   +  bf_fin-doc-tax.sum-vat-line-doc
      varsum-slt-rubl-tot  = varsum-slt-rubl-tot  +  bf_fin-doc-tax.sum-slt-line-rubl
      varsum-slt-base-tot  = varsum-slt-base-tot  +  bf_fin-doc-tax.sum-slt-line-base
      varsum-slt-contr-tot = varsum-slt-contr-tot +  bf_fin-doc-tax.sum-slt-line-contr
      varsum-slt-doc-tot   = varsum-slt-doc-tot   +  bf_fin-doc-tax.sum-slt-line-doc
    .
  end.
end.
for each tt-sum-fin-doc-tax on error undo, return error return-value :
  find first tt-sum-fin-ob-tax where tt-sum-fin-ob-tax.vat-pc   = tt-sum-fin-doc-tax.vat-pc   and
                                     tt-sum-fin-ob-tax.slt-pc   = tt-sum-fin-doc-tax.slt-pc   and
                                     tt-sum-fin-ob-tax.with-vat = tt-sum-fin-doc-tax.with-vat         and
                                     tt-sum-fin-ob-tax.with-slt = tt-sum-fin-doc-tax.with-slt         no-error.
  if not available tt-sum-fin-ob-tax then do:
    return error substitute ("Финансовый документ по фирме &1 номер &2 с внутренним номером &3 имеет строку по налогам НДС &4, НП &5, с НДС &6, с НП &7. Но у финобязательств с которыми он имеет связи такой строки нет. Это недопустимо.",
                             bf_fin-doc.host-code,
                             bf_fin-doc.prn-doc-code,
                             bf_fin-doc.fin-doc-code,
                             tt-sum-fin-doc-tax.vat-pc,
                             tt-sum-fin-doc-tax.slt-pc,
                             tt-sum-fin-doc-tax.with-vat,
                             tt-sum-fin-doc-tax.with-slt).
  end.
end.
for each tt-sum-fin-ob-tax on error undo, return error return-value :
  find first tt-sum-fin-doc-tax where tt-sum-fin-doc-tax.vat-pc   = tt-sum-fin-ob-tax.vat-pc   and
                                      tt-sum-fin-doc-tax.slt-pc   = tt-sum-fin-ob-tax.slt-pc   and
                                      tt-sum-fin-doc-tax.with-vat = tt-sum-fin-ob-tax.with-vat and
                                      tt-sum-fin-doc-tax.with-slt = tt-sum-fin-ob-tax.with-slt no-error.
  if not available tt-sum-fin-ob-tax then do:
    return error substitute ("По финансовым обязательствам с которыми у финанасового документа по фирме &1 номер &2 с внутренним номером &3 есть связь есть строки по налогам НДС &4, НП &5, с НДС &6, с НП &7. Но у финансового документа такой строки нет. Это недопустимо.",
                             bf_fin-doc.host-code,
                             bf_fin-doc.prn-doc-code,
                             bf_fin-doc.fin-doc-code,
                             tt-sum-fin-ob-tax.vat-pc,
                             tt-sum-fin-ob-tax.slt-pc,
                             tt-sum-fin-ob-tax.with-vat,
                             tt-sum-fin-ob-tax.with-slt).
  end.
end.
for each tt-sum-con-fin-ob-tax-obj on error undo, return error return-value :
  find first tt-sum-con-fin-ob-obj where tt-sum-con-fin-ob-obj.obj-type = tt-sum-con-fin-ob-tax-obj.obj-type and
                                         tt-sum-con-fin-ob-obj.obj-code = tt-sum-con-fin-ob-tax-obj.obj-code .
  assign
    tt-sum-con-fin-ob-obj.sum-vat-rubl  = tt-sum-con-fin-ob-obj.sum-vat-rubl  +  tt-sum-con-fin-ob-tax-obj.sum-vat-rubl
    tt-sum-con-fin-ob-obj.sum-vat-base  = tt-sum-con-fin-ob-obj.sum-vat-base  +  tt-sum-con-fin-ob-tax-obj.sum-vat-base
    tt-sum-con-fin-ob-obj.sum-vat-contr = tt-sum-con-fin-ob-obj.sum-vat-contr +  tt-sum-con-fin-ob-tax-obj.sum-vat-contr
    tt-sum-con-fin-ob-obj.sum-vat-doc   = tt-sum-con-fin-ob-obj.sum-vat-doc   +  tt-sum-con-fin-ob-tax-obj.sum-vat-doc
    tt-sum-con-fin-ob-obj.sum-slt-rubl  = tt-sum-con-fin-ob-obj.sum-slt-rubl  +  tt-sum-con-fin-ob-tax-obj.sum-slt-rubl
    tt-sum-con-fin-ob-obj.sum-slt-base  = tt-sum-con-fin-ob-obj.sum-slt-base  +  tt-sum-con-fin-ob-tax-obj.sum-slt-base
    tt-sum-con-fin-ob-obj.sum-slt-contr = tt-sum-con-fin-ob-obj.sum-slt-contr +  tt-sum-con-fin-ob-tax-obj.sum-slt-contr
    tt-sum-con-fin-ob-obj.sum-slt-doc   = tt-sum-con-fin-ob-obj.sum-slt-doc   +  tt-sum-con-fin-ob-tax-obj.sum-slt-doc
  .
end.
end.
end procedure.

procedure lib-farh_finchkdb :
define input parameter p-host-code     like ub.fin-doc.host-code    no-undo.
define input parameter p-fin-doc-code  like ub.fin-doc.fin-doc-code no-undo.
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-fin-ext-doc-type as character no-undo .
define input parameter p-cash-book-place as character no-undo . /*это указатель на Оп кассу*/
define input parameter p-is-auto-obj as logical no-undo .
define output parameter p-ok as logical no-undo .
define output parameter p-mess as character no-undo .

define variable v-curr-db-num as integer no-undo .
define variable v-obj-db-num as integer no-undo .
define variable v-firm as logical no-undo .
define variable v-cash as logical no-undo .
define variable v-obj-place-to-compare as character no-undo .
define variable v-is-auto-obj as logical no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_sysconf for ub.sysconf.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  find first buf_sysconf no-lock where
            buf_sysconf.host-code = p-host-code.
  { gbl/curdbnum.i v-curr-db-num }
  if (p-obj-type = ''
          and
          p-obj-code = 0) then do:
    v-firm = yes.
  end.
  else do:
    v-obj-place-to-compare = p-obj-type + string(p-obj-code, "99999").
  end.
  if lookup(p-fin-ext-doc-type, {&fin-ext-doc-cash-types}) > 0 then do:
    v-cash = yes.
  end.
  case v-firm:
    /*без объекта*/
    when yes then do:
      case v-curr-db-num:
        when buf_sysconf.firm-db-num then do:
          /*без объекта;      на главной БД фирмы*/
          p-mess = "".
      p-ok = yes.
      return.
    end.
        otherwise do:
          /*без объекта;      НЕ на главной БД фирмы*/
          p-mess = substitute ("В платежном документе с внутренним номером &2 (фирма &1) не указан объект&3"+
                              "такие документы могут создаваться/изменяться/удаляться только в главной БД фирмы&3" +
                              "номер текущей БД &4, номер ГЛАВНОЙ БД фирмы &5"
                                ,p-host-code
                                ,p-fin-doc-code
                                ,{&new-line}
                                ,v-curr-db-num
                                ,buf_sysconf.firm-db-num
                                ).
          return.
        end.
      end case. /*case v-curr-db-num:*/
    end. /*when firm then do:*/
    /*с объектом*/
    when no then do:
    find first buf_clients where
              buf_clients.obj-type = p-obj-type
          and buf_clients.obj-code = p-obj-code no-lock no-error.
    if not available buf_clients then do:
      return error substitute ("В платежном документе с внутренним номером &2 (фирма &1) указан объект &3&4, которого нет в справочнике."
                              ,p-host-code
                              ,p-fin-doc-code
                              ,p-obj-type
                              ,p-obj-code).
    end.
      case v-cash:
        /* с объектом;      НЕ НАЛ*/
        when no then do:
          case v-curr-db-num:
            /*с объектом;   не нал;   на главной БД фирмы*/
            when buf_sysconf.firm-db-num then do:
              p-ok = yes.
              return.
            end.
            /*с объектом;   не нал;   НЕ на главной БД фирмы*/
            otherwise do:
              p-mess = substitute ("В Платежном документе с внутренним номером &2 (фирма &1) указан объект &3&4,&5"+
                                  "документы типа &6 могут создаваться/изменяться/удаляться только в главной БД фирмы&5" +
                                  "номер текущей БД &7, номер главной БД фирмы &8"
                                    ,p-host-code
                                    ,p-fin-doc-code
                                    ,p-obj-type
                                    ,p-obj-code
                                    ,{&new-line}
                                    ,p-fin-ext-doc-type
                                    ,v-curr-db-num
                                    ,buf_sysconf.firm-db-num).
              return.
            end.
          end case. /*case v-curr-db-num:*/
        end. /*no-cash*/
        /* с объектом;      НАЛ*/
        when yes then do:
          define variable v-cash-book as integer no-undo .
          { gbl/cashbook.i p-obj-type p-obj-code v-cash-book }
          { gbl/objdbnum.i p-obj-type p-obj-code v-obj-db-num }

          case v-cash-book:
            /* с объектом;   НАЛ;    кассовая книга на объекте*/
            when integer({&cash-book-object}) then do:

              case v-curr-db-num:

                /* с объектом;    НАЛ;        кассовая книга на объекте;    БД объекта*/
                when v-obj-db-num then do:
                  case p-cash-book-place:

                   /* с объектом;    НАЛ;    кассовая книга на объекте;   БД объекта; опкасса ПУСТО*/
                    when '' then do:
                      p-mess = substitute ("В Платежном документе с внутренним номером &2 (фирма &1) указан объект &3&4,&5"+
                                           "документы типа &6 могут создаваться/изменяться/удаляться на БД объекта,&5" +
                                           "если на нем ведется Операционная кассовая книга,&5" +
                                           "но при этом в платеже должна быть правильно указана Операционная касса"
                                ,p-host-code
                                ,p-fin-doc-code
                                ,p-obj-type
                                ,p-obj-code
                                ,{&new-line}
                                ,p-fin-ext-doc-type
                                            ).
          return.
        end.

                    /* с объектом;    НАЛ;    кассовая книга на объекте;   БД объекта; опкасса ОБЪЕКТ*/
                    when v-obj-place-to-compare then do:
                      p-mess = "".
          p-ok = yes.
        end.

                    otherwise do:
                    /* с объектом;    НАЛ;    кассовая книга на объекте;   БД объекта; опкасса ЧТО_ТО НЕПОНЯТНОЕ*/
                      undo, return error substitute ("В Платежном документе с внутренним номером &2 (фирма &1) неверное значение Операционное кассы (&3)&4"
                                            ,p-host-code
                                            ,p-fin-doc-code
                                            ,p-cash-book-place
                                            , {&new-line}
                                            ).
                    end.
                  end. /*when v-obj-db-num then do:*/
                end. /*when v-obj-db-num then do:*/

                /* с объектом;    НАЛ;        кассовая книга на объекте;    главная БД ФИРМЫ*/
                when buf_sysconf.firm-db-num then do:
                  case p-cash-book-place:

                    /* с объектом;    НАЛ;        кассовая книга на объекте;    главная БД ФИРМЫ; ОПКАССА ПУСТО*/
                    when '' then do:
                      /*проверим связи*/
                      if p-is-auto-obj then do:
                        v-is-auto-obj = p-is-auto-obj.
                      end.
      else do:
                        run lib-farh_fautoobj in this-procedure ( input p-host-code
                                                                ,input p-fin-doc-code
                                                                ,output v-is-auto-obj) no-error.

                      end.
                      case v-is-auto-obj:

                        /* с объектом;    НАЛ;        кассовая книга на объекте;    главная БД ФИРМЫ; ОПКАССА ПУСТО*/
                        when yes then do:
                          p-ok = yes.
                        end.

                        otherwise do:
          p-mess = substitute ("В платежном документе с внутренним номером &2 (фирма &1) указан объект &3&4,&5"+
                                              "на БД объекта ведется Операционная кассовая книга&5" +
                                              "такие документы типа &6 могут создаваться/изменяться/удаляться только в БД объекта&5" +
                                              "номер текущей БД &7, ОПЕРАЦИОННАЯ КАССОВАЯ КНИГА ведется в БД &8"
                                ,p-host-code
                                ,p-fin-doc-code
                                ,p-obj-type
                                ,p-obj-code
                                ,{&new-line}
                                ,p-fin-ext-doc-type
                                ,v-curr-db-num
                                                ,v-obj-db-num).
        end.

                      end. /*                      case v-is-auto-obj:*/
                    end. /*when '' then do:*/

                    /* с объектом;    НАЛ;        кассовая книга на объекте;    главная БД ФИРМЫ; ОПКАССА ОБЪЕКТ*/
                    when v-obj-place-to-compare then do:
                      p-mess = substitute ("В платежном документе с внутренним номером &2 (фирма &1) указан объект &3&4,&5"+
                                          "и указана Операционная касса &6,поэтому он может создаваться/изменяться/удаляться ТОЛЬКО&5" +
                                          "в главной БД фирмы и ТОЛЬКО если там ведется Операционная кассовая книга&5" +
                                          "номер текущей БД &7, Операционная кассовая книга ведется в БД &8"
                                            ,p-host-code
                                            ,p-fin-doc-code
                                            ,p-obj-type
                                            ,p-obj-code
                                            ,{&new-line}
                                            ,p-fin-ext-doc-type
                                            ,v-curr-db-num
                                            ,v-obj-db-num).
                    end.

                    /* с объектом;    НАЛ;        кассовая книга на объекте;    главная БД ФИРМЫ; ОПКАССА непонятное*/
                    otherwise do:
                      undo, return error  substitute ("В Платежном документе с внутренним номером &2 (фирма &1) неверное значение Операционное кассы (&3)&4"
                                            ,p-host-code
                                            ,p-fin-doc-code
                                            ,p-cash-book-place
                                            , {&new-line}
                                            ).

                    end.
                  end case. /*case p-cash-book-place then do:*/
                end. /*when v-firm-db-num then do:*/

                otherwise do:
                  /* с объектом;    НАЛ;        кассовая книга на объекте;    НЕ главная БД ФИРМЫ И НЕ ОБЪЕКТ*/
                  p-mess = substitute ("Платежный документ с внутренним номером &2 (фирма &1) не может создаватся/изменяться/удалястья в БД &3"
                                        ,p-host-code
                                        ,p-fin-doc-code
                                        ,v-curr-db-num
                                        ).

                end. /*не obj-db-num  и не firm-db-num*/
              end case. /*case v-curr-db-num:*/
            end. /*when integer({&cash-book-object}) then do:*/

            /* с объектом;   НАЛ;    кассовая книга на БД ФИРМЫ*/
            when integer({&cash-book-firm}) then do:

              case v-curr-db-num:

                /* с объектом;   НАЛ;    кассовая книга на БД ФИРМЫ;  главная БД фирмы*/
                when buf_sysconf.firm-db-num then do:

                  case p-cash-book-place:

                    /* с объектом;   НАЛ;    кассовая книга на БД ФИРМЫ;  главная БД фирмы; ОПКАССА ПУСТО*/
                    when '' then do:
                      p-mess = "".
          p-ok = yes.

        end.
                    /* с объектом;   НАЛ;    кассовая книга на БД ФИРМЫ;  главная БД фирмы; ОПКАССА объект*/
                    when v-obj-place-to-compare then do:
                      p-mess = substitute ("В платежном документе с внутренним номером &2 (фирма &1) указан объект &3&4,&5"+
                                          "и указана Операционная касса &6,однакоу он может создаваться/изменяться/удаляться ТОЛЬКО&5" +
                                          "в главной БД фирмы потому что кассовая книга для &3&4 ведется там&5" +
                                          "номер текущей БД &7, Операционная кассовая книга ведется в БД &8"
                              ,p-host-code
                              ,p-fin-doc-code
                              ,p-obj-type
                              ,p-obj-code
                              ,{&new-line}
                              ,p-fin-ext-doc-type
                              ,v-curr-db-num
                              ,buf_sysconf.firm-db-num).

      end.
                    otherwise do:
                      undo, return error  substitute ("В Платежном документе с внутренним номером &2 (фирма &1) неверное значение Операционное кассы (&3)&4"
                                            ,p-host-code
                                            ,p-fin-doc-code
                                            ,p-cash-book-place
                                            , {&new-line}
                                            ).
                    end.
                  end case.
                end. /*   when v-firm-db-num then do:*/

                /* с объектом;   НАЛ;    кассовая книга на БД ФИРМЫ;  НЕ главная БД фирмы*/
                otherwise do:
                  p-mess = substitute ("Платежный документ с внутренним номером &2 (фирма &1) не может создаваться/изменяться/удаляться&3" +
                                       " не в главной БД фирмы, потому что кассовая книга для объекта ведется в Главной БД фирмы&3" +
                                       "Текущая БД - &4 Главная Бд фирмы - &5"
                                        ,p-host-code
                                        ,p-fin-doc-code
                                        ,{&new-line}
                                        ,v-curr-db-num
                                        ,buf_sysconf.firm-db-num
                                        ).
                end.

              end case. /*case v-curr-db-num:*/

            end. /*when integer({&cash-book-firm}) then do:*/

            /* с объектом;   НАЛ;    НЕПОНЯТНО ГДЕ КАСС КНИГА*/
            otherwise do:
              undo, return error substitute("Неверное значение места ведения кассовой книги (&3) для платежных документов по &1&2"
                                           ,p-obj-type
                                           ,p-obj-code
                                           ,v-cash-book).

      end.
          end case. /*v-cash-book:*/
        end. /*when cash then do:*/
      end case. /*case v-cash*/
    end. /*when no firmthen do:*/
  end case. /*case v-firm*/
end. /*doe*/

end procedure. /* lib-farh_finchkdb */

procedure lib-farh_fautoobj :
define input parameter p-host-code as integer no-undo .
define input parameter p-fin-doc-code as integer no-undo .
define output parameter p-is-auto-obj as logical no-undo .
define buffer buf_fin-connect  for ub.fin-connect.
define buffer buf_fin-ob  for ub.fin-ob.


find first buf_fin-connect no-lock where
        buf_fin-connect.host-code      = p-host-code
    AND buf_fin-connect.fin-doc-code   = p-fin-doc-code no-error.
if available buf_fin-connect then do:
  find first buf_fin-ob no-lock where
            buf_fin-ob.doc-code =  buf_fin-connect.fin-ob-code no-error .
  if available buf_fin-ob and
  not (buf_fin-ob.obj-type = "":U
        and  buf_fin-ob.obj-code  = 0) then do:
    assign
    p-is-auto-obj = yes
    .
  end.
end.

end procedure. /* lib-farh_autoobj */