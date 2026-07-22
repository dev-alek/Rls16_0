block-level on error undo, throw.
/*

$Revision: 1f78fe327cdf, 1091, rls $
$Author: ASMorozov $
$Date: Thu Dec 14 02:13:52 2017 +0300 $
$Workfile: ththgdss.p $
$Archive: cmp/ththgdss.p $

Сохранение по товарам системы TH старой версии

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/19/08
Author: Bakhtadze Natalya
Creation date: 12/19/08

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: 1f78fe327cdf, 1091, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:52 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ththgdss.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/ththgdss.p $":U .
define variable vss-description as character no-undo init "Сохранение по товарам системы TH старой версии".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ ref/extclass.i }
{ gbl/key-rec.i }
{ gbl/getcntxt.i def }
{ gbl/thbj-def.i }
{ gbl/cur-time.i }
{ trg/factord.i }
{ str/tt-tax.i "new shared" tt-tax full }
{ ref/grplibfn.i }
{ cmp/thth150.i }
{ cmp/thth14.i }


define variable p-from-version as character no-undo .

define variable p-copy-option as character no-undo .
define variable p-obj-type as character no-undo .
define variable p-obj-code as integer no-undo .
define variable p-rid-list as character no-undo .
define variable v-src-full-name as character no-undo .
define variable v-upper-code as integer no-undo .
define variable v-level as integer no-undo .
define variable v-counter as integer no-undo .
define variable v-rec as recid no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-ii as integer no-undo .
define variable v-ii-ok as integer no-undo .
define variable log-file-name as character no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-rid as recid no-undo .
define variable dif-nam1 as logical no-undo init yes.
define variable dif-nam2 as logical no-undo init no.
define variable dif-pdbc as logical no-undo init no.
/*настройка - уникальный цифровой артикул + ДОПБК = артикулу*/
define variable unq-artc as logical no-undo init no.
define variable is-prt  as logical no-undo .
define variable is-jwlr as logical no-undo.
define variable is-bttl as logical no-undo.
define variable is-ptrl as logical no-undo.
define variable custvalue      as character no-undo.
define variable artdis as logical no-undo init yes.
define variable v-gds-code as integer no-undo .
define variable v-b-code as integer no-undo .
define variable v-b-code1 as integer no-undo .
define variable v-pbcprid as recid no-undo .
define variable v-is-new as logical no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-fact-order as decimal no-undo .
define variable v-classif-name as character no-undo .
define variable v-cli-classif-name as character no-undo .
define variable v-tax-rate-value as decimal no-undo .

define buffer buf_gds-prt for ub.gds-prt.
define buffer goods_ext-classif for ub.ext-classif.
define buffer clients_ext-classif for ub.ext-classif.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_clients for ub.clients.
define buffer buf_tax-rate for ub.tax-rate.

{ cmp/ththgdst.i " shared "}


&glob display-message  run write-log-and-file in p-log-handle ( ~
          input 1 ~
        , input log-file-name ~
        , input 1 ~
        , input ~{&my-message~} ~
                                      )

&glob display-count-message  run write-counter in p-log-handle (input ~{&my-count-message~})

&glob hide-count-message  run hide-counter in p-log-handle

if num-entries(p-parameter, {&delim-par}) <> 1 then do:
  message
  substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 1"
             ,num-entries(p-parameter, {&delim-par}))
  view-as alert-box error .
  return.
end.
assign
p-from-version = entry(1, p-parameter, {&delim-par})
.
case p-from-version:
  when {&thth150-from-version} then do:
    assign
    v-classif-name = {&extclass_goods_th-th150}
    v-cli-classif-name = {&extclass_clients_th-th150}
    .
  end.
  when {&thth14-from-version} then do:
    assign
    v-classif-name = {&extclass_goods_th-th14}
    v-cli-classif-name = {&extclass_clients_th-th14}
    .
  end.
end case.


log-file-name = substitute("&1.txt", entry(1, entry(num-entries(this-procedure:file-name, {&slash-char}), this-procedure:file-name, {&slash-char}), ".")).


&scop my-message "Заполняем таблицу налогов ..."
{&display-message}.

run cur-time in this-procedure ( output v-today, output v-time).
    run factord-end-day in this-procedure
      (input  v-today
      ,output v-fact-order
      ).

_tax-rate:
for each buf_tax-rate no-lock where
        buf_tax-rate.tax-code = integer({&vat-tax-code})
                                or
        buf_tax-rate.tax-code = integer({&slt-tax-code}):
   { gbl/pftaxval.i
     ?
     buf_tax-rate.tax-code
     buf_tax-rate.rate-code
    ?
    0
    "''"
    0
    v-tax-rate-value
    no-error

    }
  if not error-status:error then do:
    find first temp-tax-rate no-lock where
              temp-tax-rate.tax-code = buf_tax-rate.tax-code
          and temp-tax-rate.tax-rate-value = v-tax-rate-value no-error  .
    if available temp-tax-rate then do:
      assign
      temp-tax-rate.rate-code = buf_tax-rate.rate-code
      .
    end.
  end.
  if temp-tax-rate.rate-code <= 0 then do:
    next _tax-rate.
  end.
  find first tt-tax no-lock where
            tt-tax.tax-code = buf_tax-rate.rate-code no-error.
  if not available tt-tax then do:
    create
    tt-tax.
    assign
    tt-tax.tax-code = buf_tax-rate.tax-code
    tt-tax.tax-name = (if buf_tax-rate.tax-code = integer({&vat-tax-code})
                        then "НДС"
                        else "НП")
    tt-tax.rate-code = buf_tax-rate.rate-code
    tt-tax.rate-name = buf_tax-rate.rate-name
    tt-tax.tax-type = "%"
    tt-tax.rate-value = v-tax-rate-value
    tt-tax.individual = no
    tt-tax.tax-rate-gds-rc = ?
    tt-tax.fact-date = v-today
    tt-tax.fact-order = v-fact-order
    .

    release tt-tax.
  end.
end.

&scop my-message substitute("Сохранение данных по товарам из БД &1 ...", p-from-version)
{&display-message}.

{ gbl/getcntxt.i get }

find first buf_gds-prt no-lock where
         buf_gds-prt.node-name = {&empty-scale} .

_goods:
for each goods-01:
  v-ii = v-ii + 1.
  if v-ii modulo 10 = 0 then do:
    &scop my-count-message substitute("Сохранение данных по товарам из БД &3 ...записей &1 удачно &2", v-ii, v-ii-ok, p-from-version)
    {&display-count-message}.
  end.
  if goods-01.prt-root <> buf_gds-prt.upper-code then do:
    &scop my-message substitute("Не предусмотрено сохранение  товаров со шкалой отличной от &1: товар с кодом &2 в БД &3", {&empty-scale}, goods-01.src-grp-code, p-from-version)
    {&display-message}.
    next _goods.
  end.
  /*проверим название группы*/
  define variable v-full-name as character no-undo .
  define variable v-grp-code as integer no-undo .
  /*найдем нужную группу*/
  v-grp-code = -1.
  run grplib-get-node-from-full-name ( input goods-01.grp-name
                                      ,output v-grp-code) no-error.

 find first buf_gds-grp no-lock where
        buf_gds-grp.node-code = v-grp-code no-error.
  if not available buf_gds-grp
  or can-find(ub.gds-grp no-lock where ub.gds-grp.upper-code = v-grp-code)
  then do:
    &scop my-message substitute("Не удалось найти запись для группы товаров &2, которая в БД &3 имеет код &1 или она нетерминальная" ~
                                 , goods-01.grp-name ~
                                 , goods-01.src-grp-code ~
                                 , p-from-version ~
                                 )
    {&display-message}.
    next _goods.
  end.

  find first clients_ext-classif share-lock where
        clients_ext-classif.classif-subject = {&table_clients}
    and clients_ext-classif.classif-name = v-cli-classif-name
    and clients_ext-classif.db-num = - 1
    and clients_ext-classif.key#_one = goods-01.src-prod-code
    and clients_ext-classif.charkey_one = goods-01.src-prod-type  no-error.
  if not available clients_ext-classif then do:
    &scop my-message substitute("Не удалось найти запись соответствия для клиента-производителя товара &1&2 в БД &3", goods-01.src-prod-type, goods-01.src-prod-code, p-from-version)
    {&display-message}.
    next _goods.
  end.
  if clients_ext-classif.uniq-key-rec = '' then do:
    &scop my-message substitute("Не задано соответствие для клиента-производителя &1&2 в БД &3", goods-01.src-prod-type, goods-01.src-prod-code, p-from-version)
    {&display-message}.
    next _goods.
  end.
  /*найдем клиента в БД v16.0*/
  RUN gen-row-keyr IN THIS-PROCEDURE ( INPUT clients_ext-classif.uniq-key-rec
                                      ,input ?
                                      ,INPUT "ub"
                                      ,INPUT ? /*p-bh-handle*/
                                      ,INPUT NO-LOCK
                                      ,OUTPUT v-rowid
                                      ,OUTPUT v-tbl-name) .
  find first buf_clients no-lock where
            rowid(buf_clients) = v-rowid.
  assign
  goods-01.prod-type = buf_clients.obj-type
  goods-01.prod-code = buf_clients.obj-code
  .

  find first goods_ext-classif share-lock where
            goods_ext-classif.classif-subject  = {&table_goods}
        and  goods_ext-classif.classif-name  = v-classif-name
        and goods_ext-classif.db-num = -1
        and goods_ext-classif.charkey_one = goods-01.src-artic
        and goods_ext-classif.charkey_two = goods-01.src-prod-type
        and goods_ext-classif.key#_two = goods-01.src-prod-code
        and goods_ext-classif.key#_one = goods-01.src-gds-code

        no-error .
  if not available goods_ext-classif then do:
    &scop my-message substitute("Не удалось найти запись соответствия для товара с кодом &1 в БД &2", goods-01.src-gds-code, p-from-version)
    {&display-message}.
    next _goods.
  end.
  if goods_ext-classif.uniq-key-rec <> '' then do:
    &scop my-message substitute("УЖЕ ЗАДАНО задано соответствие для товара  кодом &1 в БД &2", goods-01.src-gds-code, p-from-version)
    {&display-message}.
    next _goods.
  end.
  assign
  goods-01.grp-code = buf_gds-grp.node-code.
  v-rid = ?.
  _tr:
  do transaction on error undo _tr, next _goods:

    run ref/dtaxgdss.p (
                   input yes
                  ,input  goods-01.unit-base
                  ,input goods-01.grp-code
                  ,input ?
                  ,input ?
                  ,input v-cntxt-host-code-obj
                  ,input v-cntxt-obj-type
                  ,input v-cntxt-obj-code
                  ) no-error.
    find first tt-tax where
              tt-tax.tax-code = integer({&vat-tax-code}).
    find first temp-tax-rate where
              temp-tax-rate.tax-code = integer({&vat-tax-code})
          and temp-tax-rate.src-rate-code = goods-01.vat-pc-code no-error.
    if not available temp-tax-rate
    or temp-tax-rate.rate-code = 0 then do:
      &scop my-message  substitute("Невозможно сохранить запись о товаре с кодом &1 из системы &3&2В системе v16.0 нет соответствующей ставки НДС" ~
                            ,goods-01.src-gds-code ~
                            ,~{&new-line~}   ~
                            , p-from-version  ~
                            )
      {&display-message}.
      next _goods.
    end.
    find first tt-tax where
              tt-tax.tax-code = integer({&slt-tax-code}).
    find first temp-tax-rate where
              temp-tax-rate.tax-code = integer({&slt-tax-code})
          and temp-tax-rate.src-rate-code = goods-01.slt-pc-code no-error.
    if not available temp-tax-rate
    or temp-tax-rate.rate-code = 0 then do:
      &scop my-message  substitute("Невозможно сохранить запись о товаре с кодом &1 из системы &3&2В системе v16.0 нет соответствующей ставки НП" ~
                            ,goods-01.src-gds-code ~
                            ,~{&new-line~}   ~
                            , p-from-version  ~
                            )
      {&display-message}.
      next _goods.
    end.
    assign
    tt-tax.rate-code = temp-tax-rate.rate-code
    tt-tax.rate-value = temp-tax-rate.tax-rate-value
    .
    run ref/goods01.p (
                  input parparentproc
                  ,input {&add-def}
                  ,input no /*par-copymode*/
                  ,input 0 /*par-alt-bc-mode*/
                  ,input no /*par-manual*/
                  ,input yes /*par-silence*/
                  ,input no /*import*/
                  ,input no /*par-file*/
                  ,input no /*par-single-record */
                  ,input v-cntxt-host-code-obj
                  ,input v-cntxt-obj-type
                  ,input v-cntxt-obj-code
                  ,input (goods-01.gds-type = {&gds-goods})
                  ,input ? /*par-copy-rec*/
                  ,input 0 /*p-gds-code*/
                  ,input ''  /*p-artic*/
                  ,input goods-01.prod-type
                  ,input goods-01.prod-code
                  ,input buf_gds-prt.node-code
                  ,input goods-01.grp-code
                  ,input goods-01.gds-name
                  ,input ''
                  ,input goods-01.engl-name
                  ,input goods-01.label-name
                  ,input goods-01.chk-name
                  ,input goods-01.alpha1
                  ,input goods-01.unit-base
                  ,input goods-01.unit-cli
                  ,INPUT goods-01.max-rate
                  ,INPUT goods-01.min-rate
                  ,INPUT goods-01.cli-base-rate
                  ,input goods-01.qnty-cart
                  ,input goods-01.ms-base
                  ,input goods-01.wt-base
                  ,input goods-01.ms-cart
                  ,input goods-01.wt-cart
                  ,input goods-01.calc-method
                  ,input goods-01.increase-pc
                  ,input goods-01.negative-rest
                  ,input goods-01.gds-obj-price-base
                  ,input goods-01.gds-obj-price-rubl
                  ,input goods-01.okdp
                  ,input goods-01.destin
                  ,input goods-01.attrib
                  ,input goods-01.user-rule
                  ,input goods-01.sert
                  ,input goods-01.struct
                  ,input goods-01.deadline
                  ,input goods-01.cond-keep-code
                  ,input goods-01.sort
                  ,input 0 /*.proof*/
                  ,input goods-01.normal-wastage
                  ,input goods-01.normal-waste
                  ,input goods-01.tnved
                  ,input goods-01.nationality
                  ,input goods-01.unit-cst
                  ,input goods-01.cst-base-rate
                  ,input goods-01.fbr-grp-code
                  ,input substitute("&6: &1 &2 &3&4 &5"
                                  , goods-01.src-gds-code
                                  , goods-01.src-artic
                                  , goods-01.src-prod-type
                                  , goods-01.src-prod-code
                                  , goods-01.gds-name
                                  , p-from-version
                                  )
                  ,input unq-artc
                  ,input is-jwlr
                  ,input is-bttl
                  ,input is-ptrl
                  ,input custvalue
                  ,input dif-nam1
                  ,input dif-nam2
                  ,input yes /*автоматический артикул*/
                  ,input 0 /*bardis*/
                  ,input-output v-rid
                  ,output v-gds-code
                  ) no-error .

    if error-status:error then do:
      &scop my-message  substitute("Не удалось сохранить запись о товаре с кодом &1 из системы &5 &2&3&2&4" ~
                            ,goods-01.src-gds-code ~
                            ,~{&new-line~} ~
                            , error-status:get-message(1) ~
                            , return-value ~
                            , p-from-version  ~
                            )
      {&display-message}.
      next _goods.
    end.
    find first buf_goods no-lock where
              recid(buf_goods) = v-rid .
    v-b-code = 0.
    for each bar-code-01 where
            bar-code-01.src-gds-code = goods-01.src-gds-code,
        each prod-bc-01 where
            prod-bc-01.src-b-code = bar-code-01.src-b-code:
      if v-b-code <> bar-code-01.src-b-code then do:
        /*все партионные уже отсеяли  шкальные тоже не прорвутся*/
        /*остаются только на ед измерения*/
        { gbl/barcodcr.i
          buf_goods.gds-code
          bar-code-01.node-code
          "'':U"
          "'':U"
          bar-code-01.unit-cli
          bar-code-01.cli-base-rate
          v-is-new
          buf_bar-code
          no-error
        }
        if error-status:error
        or not available buf_bar-code then do:
          &scop my-message substitute("Ошибка при создании баркода на товар, скопированный с товара &3 с кодом &1", goods-01.src-gds-code, p-from-version)
          {&display-message}.
          undo _tr, next _goods.
        end.
        v-b-code = bar-code-01.src-b-code.
        v-b-code1 = buf_bar-code.b-code.
      end.
      if v-b-code1 <> 0 and
      not available buf_bar-code then do:
        find first buf_bar-code where
                buf_bar-code.b-code = v-b-code1.
      end.
      define buffer buf_prod-bc for ub.prod-bc.
      find first buf_prod-bc no-lock where
              buf_prod-bc.b-str = prod-bc-01.b-str no-error.
      if available buf_prod-bc
      and buf_prod-bc.bc-on
      then do:
        /*не добавляем*/
      end.
      else do:
        run trg/prod-bc1.p ( input parparentproc
                            ,input yes /*p-silent*/
                            ,input no /*dif-pdbc*/
                            ,input no /*pbc-veto*/
                            ,input no /*send-ref*/
                            ,input '' /*bc-on-type*/
                            ,input "" /*p-ean-type*/
                            ,buffer buf_goods
                            ,input buf_bar-code.b-code
                            ,input-output prod-bc-01.b-str /*p-b-str*/
                            ,output v-pbcprid
                            ) no-error.
        if error-status:error then do:
          &scop my-message substitute("Ошибка при создании Доп.БК &1 на товар, скопированный с товара &6 с кодом &2&3&4&3&5" ~
                                    , prod-bc-01.b-str ~
                                    , goods-01.src-gds-code ~
                                    , ~{&new-line~} ~
                                    , error-status:get-message(1)  ~
                                    , return-value  ~
                                    , p-from-version ~
                                    )
          {&display-message}.
          undo _tr, next _goods.
        end.
      end.
    end.
    find first buf_goods share-lock where
            recid(buf_goods) = v-rid.
    /*
    define variable v-found as logical no-undo .
    define variable v-found1 as logical no-undo .

    v-found = no.
    v-found1 = no.
    for each buf_bar-code no-lock where
            buf_bar-code.gds-code = buf_goods.gds-code,
        each buf_prod-bc no-lock where
            buf_prod-bc.b-code = buf_bar-code.b-code :
      if buf_prod-bc.bc-on then do:
        v-found1 = yes.
      end.
      v-found = yes.
    end.
    if v-found = yes
    and v-found1 = no
    then do:
      assign
      buf_goods.stts = integer({&deleted-status-int})
      .
    end.
    */
  end.

  run gen-key-rec in this-procedure ( input {&table_goods}
                                    ,input (buffer buf_goods:handle)
                                    ,output v-uniq-key-rec).
  v-rec = recid(goods_ext-classif).
  run ref/extclas1.p (
                        input {&update}
                      ,input yes /*p-silent*/
                      ,input-output v-rec
                      ,input {&table_goods} /*p-classif-subject */
                      ,input v-classif-name
                      ,input -1 /*p-db-num*/
                      ,input goods-01.src-gds-code /*p-Key#_One*/
                      ,input goods-01.src-prod-code
                      ,input goods_ext-classif.key#_three
                      ,input goods-01.src-artic /*p-CharKey_One*/
                      ,input goods-01.src-prod-type
                      ,input goods-01.gds-name + {&delim-par} + goods-01.unit-base /*p-CharKey_Three*/
                      ,input 0 /*p-nonunique*/
                      ,input v-uniq-key-rec /*p-uniq-key-rec*/
                      ) no-error.
  if error-status:error then do:
    &scop my-message substitute('Ошибка при сохранении соответствия по товару &5 с кодом &1:&2&3&2&4' ~
                                  , goods-01.src-gds-code ~
                                  ,~{&new-line~} ~
                                  , error-status:get-message(1) ~
                                  , return-value  ~
                                  , p-from-version ~
                                  )
    {&display-message}.
  end.
  else do:
    v-ii-ok = v-ii-ok + 1.
    /*
    if v-found = no then do:
      &scop my-message substitute("Товар &3 с кодом &1 (товар БД v16.0 с кодом &2) переведен в удал, так как нет НИ ОДНОГО ВКЛЮЧЕННОГО ДопБК" ~
                                  , goods-01.src-gds-code ~
                                  ,buf_goods.gds-code ~
                                  , p-from-version )
      {&display-message}.
    end.
    */
  end.
end. /*_goods*/
{&hide-count-message}.

PROCEDURE proc-settings:
define input-output parameter par-unq-artc as logical no-undo.
define input-output parameter par-dif-nam1 as logical no-undo.
define input-output parameter par-dif-nam2 as logical no-undo.
define input-output parameter par-dif-pdbc as logical no-undo .
define input-output parameter par-custvalue as character no-undo .
define input-output parameter par-is-prt  as logical no-undo .
define input-output parameter par-is-jwlr as logical no-undo .
define input-output parameter par-is-bttl as logical no-undo .
define input-output parameter par-is-ptrl as logical no-undo .


define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .


do
on error undo, return error
:

{ gbl/conf-rd.i
"'is-prt'"
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

par-is-prt = (IF error-status:error or conf-par <> "yes" then no else yes).

{ gbl/conf-rd.i
"'is-jwlr'"
"''"
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
assign
par-is-jwlr = (conf-par = "yes":U) no-error
.

{ gbl/conf-rd.i
"'is-bttl'"
"''"
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
assign
par-is-bttl = (conf-par = "yes":U) no-error
.
{ gbl/conf-rd.i
"'is-ptrl'"
"''"
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
assign
par-is-ptrl = (conf-par = "yes":U) no-error
.




{ gbl/conf-rd.i
 "'is-custm'"
 "''"
 "''"
 0
 "''"
 "''"
 "''"
 no
 par-custvalue
 par-type
 no-error
 }


for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.

run adm/shattri.p (
      input "get":U
    ,input  '':U
    ,input  0
    ,input  {&attr-gds-ref}
    ,input  "":U /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .

IF error-status:error then do:
  delete object v-tth.
  undo, return error
  substitute("Ошибка при получении опций работы со справочником товаров:&1&2 &3"
            , {&new-line}
            , error-status:get-message(1)
            , return-value ).
end.
for each thbjattr_thbj-attr  where
        thbjattr_thbj-attr.obj-type = '':U
    and thbjattr_thbj-attr.obj-code = 0
    and thbjattr_thbj-attr.upper-prop-code = {&attr-gds-ref}
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
  case thbjattr_thbj-attr.prop-code:
    when {&attr-gds-ref_dif-nam1} then do:
      par-dif-nam1 = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-gds-ref_dif-nam2} then do:
      par-dif-nam2 = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-gds-ref_dif-pdbc} then do:
      par-dif-pdbc = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-gds-ref_unq-artc} then do :
      par-unq-artc = thbjattr_thbj-attr.property-value-logical.
    end.
  end case.
end.
end.

END PROCEDURE.