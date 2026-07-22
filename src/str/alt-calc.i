/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с переоценкой

Автор: Чернова Светлана Александровна
Дата создания: 09/15/05
Author: Svetlana Chernova
Creation date: 09/15/05

Атрибуты переоценки
{&full-price-sale} - полное не округленное значение поля price-list.price-sale
                      рассчитано для автоматических переоценок , нужен для проверки интервала наценки.
                      иначе процент наценки рассчитывается не точно.
*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&if "{1}" = "func" &then

FUNCTION fnc-base-price RETURN decimal (local-bc      as integer,
                                        local-doc-num as char).
define buffer base-price        for ub.price-list.   /* цена за основной едизм, устанавливаемая в этой же переоценке */
define variable local-main-code like ub.bar-code.b-code no-undo.
define variable local-base-code like ub.bar-code.b-code no-undo.

  /* ищем в этой же переоценке цену такого же кода, но с основным едизмом */
  run prc-base-code (input local-bc, output local-base-code).
  find base-price no-lock where
       base-price.doc-num = local-doc-num and
       base-price.b-code  = local-base-code and
       base-price.price-type = "" no-error.
  if not available base-price then do:
    /* ищем в этой же переоценке главную цену такого товара */
    run prc-main-code (input local-bc, output local-main-code).
    find  base-price no-lock where
          base-price.doc-num = local-doc-num and
          base-price.b-code  = local-main-code and
          base-price.price-type = "" no-error.
  end.
  if available base-price then
    return (base-price.price-sale).
  else
    return (?).
END FUNCTION.


procedure prc-main-code:
define input  parameter local-bc        like ub.bar-code.b-code no-undo.
define output parameter local-main-code like ub.bar-code.b-code no-undo.
define buffer local-bar-code        for ub.bar-code.
define buffer local-goods           for ub.goods.
define buffer main-code             for ub.bar-code.     /* код главный */
define buffer main-prt              for ub.gds-prt.      /* корень основного едизма */
  local-main-code = ?.
  find local-bar-code no-lock where
       local-bar-code.b-code = local-bc no-error.
  if not available local-bar-code then
    return.
  find local-goods no-lock where
       local-goods.gds-code = local-bar-code.gds-code.
  find first  main-prt no-lock where
              main-prt.upper-code = local-goods.prt-root.
  find  main-code no-lock where
        main-code.gds-code  = local-bar-code.gds-code and
        main-code.in-code   = "" and
        main-code.part-code = "" and
        main-code.unit-cli  = local-goods.unit-base and
        main-code.node-code = main-prt.node-code.
  local-main-code = main-code.b-code.
end procedure.

procedure prc-base-code:
define input  parameter local-bc        like ub.bar-code.b-code no-undo.
define output parameter local-base-code like ub.bar-code.b-code no-undo.
define buffer local-bar-code for ub.bar-code.
define buffer local-goods    for ub.goods.
define buffer base-code      for ub.bar-code.     /* код основного едизма */
  local-base-code = ?.
  find local-bar-code no-lock where
       local-bar-code.b-code = local-bc no-error.
  if not available local-bar-code then
    return.
  find local-goods no-lock where
       local-goods.gds-code = local-bar-code.gds-code.
  find base-code no-lock where
       base-code.gds-code  = local-bar-code.gds-code and
       base-code.node-code = local-bar-code.node-code and
       base-code.in-code   = local-bar-code.in-code and
       base-code.part-code = local-bar-code.part-code and
       base-code.unit-cli  = local-goods.unit-base.
  local-base-code = base-code.b-code.
end procedure.

&endif
&if "{1}" = "pr-altex" &then

for each  buf-price-list where
          buf-price-list.doc-num    = {2} and  /* номер старой переоценки */
          buf-price-list.artic      = buf-goods.artic and
          buf-price-list.prod-type  = buf-goods.prod-type and
          buf-price-list.prod-code  = buf-goods.prod-code and
          buf-price-list.main-price = no,
    first buf-bar-code no-lock where
          buf-bar-code.b-code   = buf-price-list.b-code and
          buf-bar-code.unit-cli <> buf-goods.unit-base:
  /* найдена неосновная цена */
  run cre-pr-list (input  buf-bar-code.b-code,
                   input  {3},                  /* номер заполняемой переоценки */
                   output new-rec) no-error.
  if error-status:error then do:
    message
      "Ошибка cre-pr-list." skip
      "Код:" buf-bar-code.b-code
      view-as alert-box.
    next.
  end.
end.

&endif
&if "{1}" = "pr-parex" &then
define buffer buf_parts for ub.parts  .
    for each  buf_parts no-lock where
          buf_parts.out-code    = {&free-code} and
          buf_parts.obj-type   = v-cntxt-obj-type and
          buf_parts.obj-code   = v-cntxt-obj-code and
          buf_parts.rsrv-free   = true  and
          buf_parts.status_     = false and
          buf_parts.artic       = buf-goods.artic and
          buf_parts.prod-type   = buf-goods.prod-type and
          buf_parts.prod-code   = buf-goods.prod-code ,
        first buf-bar-code no-lock where
              buf-bar-code.gds-code  = buf-goods.gds-code and
              buf-bar-code.unit-cli  = buf-goods.unit-base and
              buf-bar-code.in-code   = buf_parts.in-code and
              buf-bar-code.part-code = buf_parts.part-code
          :
  run cre-pr-list (input  buf-bar-code.b-code,
                   input  {3},  /* номер заполняемой переоценки */
                   output new-rec) no-error.
  if error-status:error then do:
    message
      "Ошибка cre-pr-list." skip
      "Код:" buf-bar-code.b-code
      view-as alert-box.
    next.
  end.
end.

&endif
&if "{1}" = "pr-sclex" &then
  &scoped-define seq {&sequence}
  define buffer buf_alt-calc_price-doc{&seq} for ub.price-doc .

  find first buf_alt-calc_price-doc{&seq} no-lock
    where buf_alt-calc_price-doc{&seq}.doc-num = {2}
    .
  define variable v-ok as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_overvalue_properties':U
    {&cntxt-object}
    buf_alt-calc_price-doc{&seq}.host-code
    buf_alt-calc_price-doc{&seq}.obj-type
    buf_alt-calc_price-doc{&seq}.obj-code
    0
    0
    0
    false
    v-ok
  }

  if v-ok then do:

for each  buf-price-list where
          buf-price-list.doc-num    = {2} and  /* номер старой переоценки */
          buf-price-list.artic      = buf-goods.artic and
          buf-price-list.prod-type  = buf-goods.prod-type and
          buf-price-list.prod-code  = buf-goods.prod-code and
          buf-price-list.main-price = no,
    first buf-bar-code no-lock where
          buf-bar-code.b-code   = buf-price-list.b-code and
          buf-bar-code.in-code = "" and
          buf-bar-code.unit-cli = buf-goods.unit-base:
  run cre-pr-list (input  buf-bar-code.b-code,
                   input  {3},                  /* номер заполняемой переоценки */
                   output new-rec) no-error.
  if error-status:error then do:
    message
      "Ошибка cre-pr-list." skip
      "Код:" buf-bar-code.b-code
      view-as alert-box.
    next.
  end.
end.
end.
&endif
&if "{1}" = "proc" &then
&if "{4}" <> "no-prcreate-new-price-doc" &then
{ str/prcreate.i }
&endif

/* Переменные с секции параметров ПЕРЕОЦЕНКА*/
define variable par-pr-incpc as character no-undo.    /* Начальное значение поля Наценка */
define variable par-pr-rndmt as character no-undo.    /* Начальное значение поля Метод округления */
define variable par-pr-rndbs as character no-undo.    /* Начальное значение поля База округления */
define variable par-pr-clt-q as character no-undo.    /* Запрос при замене цены при добавлении */
define variable par-pr-dpl-q as character no-undo.    /* Запрос при добавлении строки как в другом приказе */
define variable par-pr-rdc-q as character no-undo.    /* Запрос при уменьшении текущей цены */
define variable par-pr-abs-d as character no-undo.    /* Удалять строки, товаров по которым нет в наличии */
define variable par-pr-altex as character no-undo.    /* Добавлять имеющиеся неосновные цены */
define variable par-pr-parex as character no-undo.    /* Добавлять имеющиеся цены партий */
define variable par-pr-sclex as character no-undo.    /* Добавлять имеющиеся цены признаков */
define variable par-pr-notls as character no-undo.    /* сохранять все цены спец осн */
define variable par-pr-equ-dq as integer  no-undo.    /* Действие над товаром, цена на который не изменилась */
define variable par-pr-discm as character no-undo .
define variable par-pr-dscnt as character no-undo .
define variable par-pr-print as character no-undo .
define variable par-pr-sigma as character no-undo .
define variable par-pr-goods as character no-undo. /* Ограничение на виды товаров в ДНЦ */
define variable par-pr-nogds as character no-undo. /* Исключения из запретов в ДНЦ на УБД */
define variable par-alcohol  as character no-undo. /* Разрешена работа с атрибутами алкогольной продукции */
define variable par-gen-mrgn-ie as character no-undo .
define variable par-gen-mrgn-iv as character no-undo .
define variable par-gen-mrgn-im as character no-undo .
define variable par-pr-nakl-ie  as logical   no-undo .   /* Цена переоценки в ПН */
define variable par-pr-nakl-iv  as logical   no-undo .   /* Цена переоценки в внутПН */
define variable par-pr-nakl-im  as logical   no-undo .   /* Цена переоценки в првоПН */
define variable par-pr-nogds-long as longchar no-undo .

define temp-table tmp-proof-price no-undo
  field node-code like ub.gds-grp.node-code
  field proof as decimal
  field price as decimal
index pi node-code proof descending .

{ gbl/thbj-def.i }
{ str/cont-ms-def.i }
{ gbl/ggoattr.i }
/*--------------------------------------------------------------------------------------------------*/
{ ref/grplibfn.i }

procedure  chec-par : /* Проверка и инициализация переменных с параметрами */
define output parameter l-par as logical no-undo .
define input parameter l-host like ub.clients.obj-code no-undo .
define input parameter l-type like ub.clients.obj-type no-undo .
define input parameter l-code like ub.clients.obj-code no-undo .

define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .


 { gbl/conf-rd.i "'alcohol'"  l-host l-type l-code "''" "''" "''" no   par-alcohol    par-type no-error}.
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input l-type
  ,input l-code
  ,input {&attr-overval}
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .

for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-clt-q} then par-pr-clt-q = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-dpl-q} then par-pr-dpl-q = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-rdc-q} then par-pr-rdc-q = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-equ-dq} then par-pr-equ-dq = thbjattr_thbj-attr.property-value-integer .
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-abs-d} then par-pr-abs-d = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-altex} then par-pr-altex = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-parex} then par-pr-parex = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-sclex} then par-pr-sclex = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-discm} then par-pr-discm =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-dscnt} then par-pr-dscnt  = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-print} then par-pr-print  = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-sigma} then par-pr-sigma  = string ( thbjattr_thbj-attr.property-value-decimal) .
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-incpc} then par-pr-incpc  = string ( thbjattr_thbj-attr.property-value-decimal) .
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-rndmt} then par-pr-rndmt  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-rndbs} then par-pr-rndbs  = string ( thbjattr_thbj-attr.property-value-decimal) .
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-notls} then par-pr-notls = string ( thbjattr_thbj-attr.property-value-logical) .

    if v-cntxt-db-num = 0 then do:
      if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-nogds0} then par-pr-nogds =  thbjattr_thbj-attr.property-value-character.
      if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-goods0} then par-pr-goods =  thbjattr_thbj-attr.property-value-character.
    end.
    else do:
      if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-nogds} then par-pr-nogds =  thbjattr_thbj-attr.property-value-character.
      if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-goods} then par-pr-goods =  thbjattr_thbj-attr.property-value-character.
    end.
end.

/* Получим из ТПЛ автопереоценок нужные переменные */

{ gbl/gtplmrgn.i
    ?
    l-type
    l-code
    par-gen-mrgn-ie
    par-gen-mrgn-iv
    par-gen-mrgn-im
   no-error }
   IF error-status :error THEN message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     "gbl/gtplmrgn.i"
     view-as alert-box error
   .

{ gbl/gtplpnakl.i
    ?
    l-type
    l-code
    par-pr-nakl-ie
    par-pr-nakl-iv
    par-pr-nakl-im
   no-error }
   define variable ii as integer   no-undo .
   define variable nn as integer   no-undo .
   define variable v-fullname as character no-undo .

   nn = num-entries ( par-pr-nogds ).
   par-pr-nogds-long = "".
   if par-pr-nogds <> "0" and par-pr-nogds <> ""  then do:
      repeat ii = 1 to nn :
        run grplib-get-full-name  ( input integer(entry(ii,par-pr-nogds)) , output v-fullname ) .
        par-pr-nogds-long = par-pr-nogds-long + v-fullname + {&delim-par} .
      end.
      par-pr-nogds-long = trim (par-pr-nogds-long,{&delim-par}) .
   end.

l-par = true .
end procedure.

PROCEDURE cre-pr-list:
/* ---------------------------------------------------------------------------------------------------------------------------------
   Создает новую запись ub.price-list (если такой нет) по заданному bar-code
   если главная цена, разворачивает неосновные и спец, если есть настройки
   ничего не рассчитывает
------------------------------------------------------------------------------------------------------------------------------------- */
define input  parameter bc      like ub.price-list.b-code no-undo.
define input  parameter new-num like ub.price-doc.doc-num no-undo.
define output parameter new-rec as recid             no-undo.

define buffer buf-price-list for ub.price-list.
define buffer buf-price-doc  for ub.price-doc.


define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer buf-gds-prt    for ub.gds-prt.
define buffer root-gds-prt   for ub.gds-prt.
define variable cur-pr like ub.price-list.price-sale no-undo.
define variable cur-rt like ub.price-list.road-tax   no-undo.
define variable cur-ex like ub.price-list.excise     no-undo.
define variable cur-dn like ub.price-list.doc-num    no-undo.

define variable local_vat-pc like ub.price-list.vat-pc    no-undo.
define variable local_slt-pc like ub.price-list.slt-pc    no-undo.

define variable cur-rt-base as decimal no-undo .
define variable cur-rt-rubl as decimal no-undo .

define variable p-hostcode as int no-undo .
define variable v-line-num as integer no-undo .

define variable v-skip-del-gds as logical no-undo initial no .

cre-pr:
do on error undo cre-pr, return error:
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.

  run check-use-bar-code ( buf-bar-code.b-code ) no-error .
  if error-status :error then do:
    message
      return-value skip
      "Ошибка !"
      view-as alert-box error
    .
    undo cre-pr, return.
  end.

  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find first root-gds-prt no-lock where
            root-gds-prt.upper-code = buf-goods.prt-root.
  if root-gds-prt.node-name <> {&empty-scale} and
    buf-bar-code.in-code <> "" then do:
    message
      "Не допускается создавать спец. цены на партии для товаров с непустой шкалой!" skip (2)
      "Артикул:" buf-goods.artic "Код:" buf-goods.gds-code buf-goods.gds-name
      view-as alert-box error.
    undo cre-pr, return.         /* ошибку не возвращаем */
  end.
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
  &if "{4}" = "p-auto" &then
    v-skip-del-gds = {4} .
  &endif     
  if buf-goods.stts <> 0 and not v-skip-del-gds then do:
    message
      "Не допускается создавать цены на удаленные товары!" skip (2)
      "Артикул:" buf-goods.artic "Код:" buf-goods.gds-code buf-goods.gds-name
      view-as alert-box error.
    undo cre-pr, return.         /* запись не видна в справочнике - ошибку не возвращаем */
  end.
  
  find  buf-price-doc where
        buf-price-doc.doc-num = new-num.

define variable v-ret as logical no-undo .
   run ver-modificator-price-is-null (
          input    buf-goods.artic        ,
          input    buf-goods.prod-type    ,
          input    buf-goods.prod-code    ,
          input    buf-price-doc.obj-type   ,
          input    buf-price-doc.obj-code   ,
          output   v-ret ).
      if v-ret = false then dO:
          message
            "Не допускается создавать цены на модификаторы с нулевой ценой !" skip (2)
            "Артикул:" buf-goods.artic "Код:" buf-goods.gds-code buf-goods.gds-name
            view-as alert-box error.
          undo cre-pr, return.         /* запись не видна в справочнике - ошибку не возвращаем */
        end.


/* НДС */
{ gbl/hostcode.i    buf-price-doc.obj-type
                buf-price-doc.obj-code
                p-hostcode
                no-error }

{ gbl/pftxvalg.i    buf-goods.gds-code
                {&vat-tax-code}
                ?
                p-hostcode
                buf-price-doc.obj-type
                buf-price-doc.obj-code
                local_vat-pc
                no-error }
/* slt */
{ gbl/pftxvalg.i    buf-goods.gds-code
                {&slt-tax-code}
                ?
                p-hostcode
                buf-price-doc.obj-type
                buf-price-doc.obj-code
                local_slt-pc
                no-error }

/* находим номер старой переоценки */
{ gbl/bcodeprc.i
  buf-price-doc.obj-type
  buf-price-doc.obj-code
  bc
  0
  0
  cur-dn
  cur-pr
  cur-rt
  cur-ex
  no-error }

/* проверим */

  /* проверяем, нет ли такой строки в ЭТОМ ЖЕ документе */
  find first buf-price-list where
            buf-price-list.b-code  = buf-bar-code.b-code and
            buf-price-list.doc-num = new-num  and
            buf-price-list.price-type = ""    no-error .
  if not available buf-price-list then do:
    run calc-price-line-num (input  new-num , output v-line-num) .
    create buf-price-list.
    assign
      buf-price-list.line-num  = v-line-num
      buf-price-list.b-code    = buf-bar-code.b-code
      buf-price-list.doc-num   = buf-price-doc.doc-num
      buf-price-list.prod-type = buf-goods.prod-type
      buf-price-list.prod-code = buf-goods.prod-code
      buf-price-list.artic     = buf-goods.artic
      buf-price-list.obj-type  = buf-price-doc.obj-type
      buf-price-list.obj-code  = buf-price-doc.obj-code
      buf-price-list.vat-pc    = local_vat-pc
      buf-price-list.slt-pc    = local_slt-pc
      buf-price-list.price-prev = cur-pr
      .

    if  buf-gds-prt.upper-code = buf-goods.prt-root and
        buf-bar-code.in-code   = "" and
        buf-bar-code.part-code = "" and
        buf-bar-code.unit-cli  = buf-goods.unit-base then do:
      buf-price-list.main-price = yes.
      /* если цена главная и есть настройки, разворачиваем спеццены */
      if cur-pr <> ? then do:
        /* был этот товар в более ранней переоценке */
        run exp-prt (input buf-goods.gds-code,
                    input cur-dn,
                    input new-num,
                    output new-rec) no-error.
        if error-status :error then do:
          message
            "Ошибка вызова процедуры разворота специальных и неосновных цен."
            view-as alert-box error.
          undo cre-pr, return error.
        end.
      end.
    end.
    else do:
      if buf-bar-code.unit-cli <> buf-goods.unit-base then do:
        /* неосновная цена - нужно для скидки задать нач значение ?, тогда
           она проинициируется из старой переоценки */
        buf-price-list.d-pcnt = ?.
      end.
      buf-price-list.main-price = no.
    end.
  end.

end.
new-rec = recid (buf-price-list).

END PROCEDURE.


procedure calc-price-line-num :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

define input parameter p-doc-num as character no-undo .
define output parameter p-num  as integer no-undo .
define variable v-fact as integer no-undo .
define buffer buf_1_price-list for ub.price-list .
p-num = 1 .
find last  buf_1_price-list no-lock where
           buf_1_price-list.doc-num = p-doc-num use-index line-num no-error .
           if available buf_1_price-list then
                assign
                  v-fact = buf_1_price-list.line-num
                .

v-fact = v-fact + 1.
if v-fact <> ? then if p-num < v-fact then p-num = v-fact .

 end. /* do */
end procedure. /* calc-price-line-num */


PROCEDURE del-pr-list:
/* ---------------------------------------------------------------------------------------------------------------------------------
   Удаляет запись ub.price-list по заданному ub.bar-code
------------------------------------------------------------------------------------------------------------------------------------ */
define input parameter bc    like ub.bar-code.b-code   no-undo.
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter round-method as character         no-undo. /* способ округления */
define input parameter round-base   as decimal      no-undo. /* база для округления / коэффициент */

define buffer buf-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define variable l-ov-on as logical no-undo .

del-pr:
do on error undo del-pr, return error:
  find first  buf-price-list no-lock where
              buf-price-list.doc-num    = d-num and
              buf-price-list.b-code     = bc and
              buf-price-list.price-type = "" no-error.
  if not available buf-price-list then
    undo del-pr, return error.

  find  buf-goods no-lock where
        buf-goods.prod-type = buf-price-list.prod-type and
        buf-goods.prod-code = buf-price-list.prod-code and
        buf-goods.artic     = buf-price-list.artic.
  if buf-price-list.main-price then do:
    /* корневая цена - давим вместе с дополнительными и специальными */
    for each  buf-price-list exclusive-lock where
              buf-price-list.doc-num   = d-num and
              buf-price-list.artic     = buf-goods.artic and
              buf-price-list.prod-type = buf-goods.prod-type and
              buf-price-list.prod-code = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code = buf-price-list.b-code
    on error undo del-pr, return error:
    /* сbросим ov */
      { gbl/gdsobjat.i
        ub.buf-price-list.obj-type
        ub.buf-price-list.obj-code
        ub.buf-price-list.artic
        ub.buf-price-list.prod-type
        ub.buf-price-list.prod-code
        "'ov-on=request:exclusive'"
        l-ov-on
        no-error
      }
      if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка получения признака товара на объекте" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
          /*  return error . */
      end.
      if l-ov-on then do:
        { gbl/gdsobjat.i
          ub.buf-price-list.obj-type
          ub.buf-price-list.obj-code
          ub.buf-price-list.artic
          ub.buf-price-list.prod-type
          ub.buf-price-list.prod-code
          "'ov-on=false'"
          l-ov-on
          no-error
        }
        if error-status :error then do:

        end.

       end.
      delete buf-price-list.
    end.
  end.
  else do:
    /* неосновные цены могут быть удалены только с главной, но не по одной */
    find  buf-bar-code no-lock where
          buf-bar-code.b-code = buf-price-list.b-code.
    if buf-bar-code.unit-cli <> buf-goods.unit-base then do:
      /* данная процедура удаления не используется в   p r - a l t . w    , поэтому там неосновная цена
        удаляется без проблем */
      message
        "Нельзя удалить неосновную цену." skip
        "Неосновная цена (скидка) не может быть неопределенной." skip
        "Код:" bc skip
        "Переоценка:" d-num
        view-as alert-box error.
      undo del-pr, return error.
    end.
    find current buf-price-list exclusive-lock no-error .
    delete buf-price-list.
    /* пересчитываем неосновные цены, основная цена для которых была удалена */
    run calc-base-upd (input buf-bar-code.b-code,
                      input d-num,
                      input round-method,
                      input round-base) no-error.
    if error-status :error then
      undo del-pr, return error.
  end.
end.
END PROCEDURE.

PROCEDURE calc-base-upd:
/* ---------------------------------------------------------------------------------------------------------------------------------
   Пересчитывает все неосновные по одному основному
------------------------------------------------------------------------------------------------------------------------------------ */
define input parameter bc    like ub.bar-code.b-code   no-undo.
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter round-method as character         no-undo. /* способ округления */
define input parameter round-base   as decimal      no-undo. /* база для округления / коэффициент */

define buffer alt-bar-code   for ub.bar-code.
define buffer alt-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.

calc-base:
do on error undo calc-base, return error:

  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.

  for each  alt-bar-code no-lock where
            alt-bar-code.gds-code  = buf-bar-code.gds-code and
            alt-bar-code.node-code = buf-bar-code.node-code and
            alt-bar-code.part-code = buf-bar-code.part-code and
            alt-bar-code.in-code   = buf-bar-code.in-code and
            alt-bar-code.unit-cli <> buf-goods.unit-base,
      each  alt-price-list where
            alt-price-list.doc-num    = d-num and
            alt-price-list.b-code     = alt-bar-code.b-code and
            alt-price-list.price-type = ""
      on error undo calc-base, return error:
    /* неосновная цена */
    run calc-pr-alt (input d-num,
                    input alt-bar-code.b-code,
                    input round-method,
                    input round-base) no-error.
    if error-status:error then
      undo calc-base, return error.
  end.

end.
END PROCEDURE.

PROCEDURE calc-pr-alt:
/* ---------------------------------------------------------------------------------------------------------------------------------
   вычисление цены заданного неосновного кода с округлением
------------------------------------------------------------------------------------------------------------------------------------ */
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter bc    like ub.bar-code.b-code   no-undo.
define input parameter r-method as character             no-undo.
define input parameter r-base   as decimal              no-undo.

define buffer buf-price-doc  for ub.price-doc.
define buffer buf-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer old-price-list for ub.price-list.
define variable pr-rec   as   recid                  no-undo.
define variable pr-c-b-r like ub.bar-code.cli-base-rate no-undo.

pr-alt:
do on error undo pr-alt, return error:

  if r-method = ? or
     r-base = ? then do:
    /* не заданы они при вызове из p r - s t a t . p - если есть для неопределенной
       основной хоть одна зависимая неосновная - будет откачено */
    message
      "Нельзя удалить основную цену." skip
      "Не задан способ округления для расчета зависящих от нее неосновных цен." skip
      "Код:" bc skip
      "Переоценка:" d-num
      view-as alert-box error.
    undo pr-alt, return error.
  end.

  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-price-list where
        buf-price-list.doc-num = buf-price-doc.doc-num and
        buf-price-list.b-code  = bc.

  if buf-price-list.d-pcnt = ? then do:
    /* скидка не задана - пытаемся проинициировать ее из предыдущей переоценки */
    { gbl/bcodepls.i
      buf-price-doc.obj-type
      buf-price-doc.obj-code
      bc
      0
      0
      pr-rec
      pr-c-b-r }
    find old-price-list no-lock where
        recid (old-price-list) = pr-rec no-error.
    if available old-price-list and
      old-price-list.b-code = bc then
      /* нашли цену именно на этот неосновной код */
      buf-price-list.d-pcnt = old-price-list.d-pcnt.
    else
      /* цены на этот код не было, она добавляется в переоценку первый раз,
         значит инициируем скидку 0 */
      buf-price-list.d-pcnt = 0.
  end.

  /* вычисляем неосновную цену */
   if buf-price-list.d-pcnt = ? then do:
      assign
        buf-price-list.price-sale =   if available old-price-list then old-price-list.price-sale else 0
        buf-price-list.calc-method =  {&pr-calc-fix} + {&pr-calc-base}
        .
  end.
  else do:
      assign
        buf-price-list.price-sale =   fnc-base-price (buf-bar-code.b-code, buf-price-list.doc-num) *
                                      buf-bar-code.cli-base-rate *
                                      (1 - buf-price-list.d-pcnt / 100)
        buf-price-list.calc-method =  {&pr-calc-base}
        .

          { str/pr-99.i
            buf-price-list.price-sale
            r-method
            r-base
          }
  end.

end.
END PROCEDURE.

PROCEDURE calc-pr-discnt:
/* ---------------------------------------------------------------------------------------------------------------------------------
   вычисление скидки от цены заданного неосновного кода
------------------------------------------------------------------------------------------------------------------------------------ */
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter bc    like ub.bar-code.b-code   no-undo.

define buffer buf-price-doc  for ub.price-doc.
define buffer buf-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer old-price-list for ub.price-list.
define variable pr-rec   as   recid                  no-undo.
define variable pr-c-b-r like ub.bar-code.cli-base-rate no-undo.

pr-discnt:
do on error undo pr-discnt, return error:
  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-price-list where
        buf-price-list.doc-num = buf-price-doc.doc-num and
        buf-price-list.b-code  = bc.
  buf-price-list.d-pcnt = (1 -
                           buf-price-list.price-sale /
                           fnc-base-price (buf-bar-code.b-code, buf-price-list.doc-num) /
                           buf-bar-code.cli-base-rate) *
                           100
                           .
end.
END PROCEDURE.

PROCEDURE calc-pr-sub :
/* ---------------------------------------------------------------------------------------------------------------------------------
   если главная цена, считает также все неосновные и спеццены по товару
   если основная - считает только для нее все неосновные
------------------------------------------------------------------------------------------------------------------------------------- */
define  input  parameter bc             like ub.price-list.b-code no-undo.
define  input  parameter d-num          like ub.price-doc.doc-num no-undo.
define  input  parameter calc-method  as character    no-undo. /* способ расчета цены - исходная цена */
define  input  parameter increase-pc  as decimal      no-undo. /* процент наценки (с минусом - скидки)*/
define  input  parameter round-method as character    no-undo. /* способ округления */
define  input  parameter round-base   as decimal      no-undo. /* база для округления / коэффициент */
define  output parameter calc-rec     as recid        no-undo. /* recid последней пересчитанной основной цены */

define  buffer buf-price-list for ub.price-list.
define  buffer buf-bar-code   for ub.bar-code.
define  buffer buf-goods      for ub.goods.
define  buffer buf-gds-prt    for ub.gds-prt.
define  buffer buf-gds-grp    for ub.gds-grp.
define  buffer buf-price-doc  for ub.price-doc.

calc-sub:
do on error undo calc-sub, return error:

  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
  find  buf-price-list where
        buf-price-list.doc-num    = d-num and
        buf-price-list.b-code     = bc and
        buf-price-list.price-type = "".
  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.
  calc-rec = recid (buf-price-list).
  if buf-price-list.main-price then do:
    /* считаем все спецены для товара */
    for each  buf-price-list where
              buf-price-list.doc-num    = buf-price-doc.doc-num and
              buf-price-list.main-price = no and
              buf-price-list.artic      = buf-goods.artic and
              buf-price-list.prod-type  = buf-goods.prod-type and
              buf-price-list.prod-code  = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code   = buf-price-list.b-code and
              buf-bar-code.unit-cli = buf-goods.unit-base
        on error undo calc-sub, return error:
      /* основная спеццена */
      run calc-pr-list (input  buf-bar-code.b-code,
                        input  buf-price-list.doc-num,
                        input  calc-method,
                        input  increase-pc,
                        input  round-method,
                        input  round-base,
                        input ? ,
                        input ? ,
                        input ? ,
                        input ? ,
                        output calc-rec) no-error.
      if error-status :error then
        undo calc-sub, return error.
      /* отмечаем, что нужно переоткрыть весь browse, потому что пересчитывалась
          не только главная цена,
          а также для reposition */
      calc-rec = recid (buf-price-list).
    end.
    /* считаем все неосновные цены для товара, в т.ч. для которых нет основных */
    for each  buf-price-list where
              buf-price-list.doc-num    = buf-price-doc.doc-num and
              buf-price-list.main-price = no and
              buf-price-list.artic      = buf-goods.artic and
              buf-price-list.prod-type  = buf-goods.prod-type and
              buf-price-list.prod-code  = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code    = buf-price-list.b-code and
              buf-bar-code.unit-cli <> buf-goods.unit-base
        on error undo calc-sub, return error:
      /* неосновная цена */
      run calc-pr-alt (input buf-price-doc.doc-num,
                      input buf-bar-code.b-code,
                      input round-method,
                      input round-base) no-error.
      if error-status :error then
        undo calc-sub, return error.
    end.
  end.
  else do:
    /* нужно считать неосновные для 1 кода - менялась основная неглавная цена */
    run calc-base-upd (input buf-bar-code.b-code,
                      input buf-price-doc.doc-num,
                      input round-method,
                      input round-base) no-error.
    if error-status :error then
      undo calc-sub, return error.
  end.

end.
END PROCEDURE.


procedure ver-pr-nogds :

/* Обработка параметра Исключение из запрета . Проверяю , что товар входит в помеченные группы */
define input  parameter p-gds-code      as integer   no-undo .
define input  parameter p-par-pr-nogds  as character no-undo .
define output parameter p-not           as logical   no-undo .
define output parameter p-str           as character no-undo .

define buffer buf_goods for ub.goods  .
define variable nn as integer   no-undo .
define variable ii as integer   no-undo .
define variable v-namegrp as character no-undo .
  do
  on error undo, return error return-value
  :
  if p-par-pr-nogds = "1" then do:
     assign
      p-not = true
      p-str = ""
     .
     return .
  end.
  assign
    p-not = false
    p-str = ""
  .
  find first buf_goods no-lock where
             buf_goods.gds-code = p-gds-code no-error .

  nn = num-entries(par-pr-nogds-long,{&delim-par}) .
  repeat ii = 1 to nn:
     v-namegrp = entry(ii , par-pr-nogds-long , {&delim-par} ) no-error .
     if buf_goods.grp-name  begins v-namegrp  then do:
        assign
          p-not = true
          p-str = substitute ( "Товар &1 &2 &3  может быть включен в ДНЦ из-за исключения запрета по группе : &4"  , buf_goods.artic, buf_goods.gds-name , buf_goods.grp-name , v-namegrp )
        .
        leave .
     end.
  end.
  end.
end procedure. /* ver-pr-nogds */

&endif
&if "{1}" = "pr-list" &then

PROCEDURE calc-pr-list :
/* ---------------------------------------------------------------------------------------------------------------------------------
   Считает запись ub.price-list по заданному ub.bar-code
------------------------------------------------------------------------------------------------------------------------------------- */
define input  parameter bc          like ub.price-list.b-code   no-undo .
define input  parameter d-num       like ub.price-doc.doc-num   no-undo .
define input  parameter calc-method             as character    no-undo . /* способ расчета цены - исходная цена */
define input  parameter increase-pc             as decimal      no-undo . /* процент наценки (с минусом - скидки)*/
define input  parameter round-method            as character    no-undo . /* способ округления */
define input  parameter round-base              as decimal      no-undo . /* база для округления / коэффициент */
define input  parameter p-doc-price-rubl        as decimal      no-undo . /* когда документ не создан */
define input  parameter p-doc-price-base        as decimal      no-undo . /* когда документ не создан */
define input  parameter p-doc-price-rubl-novat  as decimal      no-undo . /* когда документ не создан */
define input  parameter p-doc-price-base-novat  as decimal      no-undo . /* когда документ не создан */
define output parameter calc-rec                as recid        no-undo . /* recid последней пересчитанной основной цены */

define buffer buf-price-list for ub.price-list.
define buffer buf-price-doc  for ub.price-doc.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer buf-gds-prt    for ub.gds-prt.
define buffer buf-gds-grp    for ub.gds-grp.
define buffer buf_contract   for ub.contract .
define buffer buf_contract-specif for ub.contract-specif .

define variable cur-pr like ub.price-list.price-sale no-undo .
define variable cur-rt like ub.price-list.road-tax   no-undo .
define variable cur-ex like ub.price-list.excise     no-undo .
define variable cur-dn like ub.price-list.doc-num    no-undo .
define variable loc-ret        as logical            no-undo .
define variable old-price-sale as decimal            no-undo .
define variable v-bonus        as decimal            no-undo .

assign
  loc-ret = true
.
calc-pr:
do on error undo calc-pr, return error:

  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
  find  buf-price-list where
        buf-price-list.doc-num    = d-num and
        buf-price-list.b-code     = bc and
        buf-price-list.price-type = "".
  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.

  g#log = yes. /* для всех последующих message */
  /* Определим наценку на товар */
  define variable loc-increase-pc      like  ub.goods.increase-pc no-undo .
  define variable loc-grp-increase-pc  like  ub.goods.increase-pc no-undo .
  { gbl/gdsoincr.i
  buf-goods.gds-code
  buf-price-list.obj-type
  buf-price-list.obj-code
  loc-increase-pc no-error
  }
  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
     "Ошибка метода поиска наценки товара на объекте" skip
     error-status :get-message(1) .
  end.

define variable p-prc-min        as decimal   no-undo .
define variable p-prc-max        as decimal   no-undo .
define variable p-round-method   as character no-undo .
define variable p-base           as decimal   no-undo .
define variable p-value-margin   as integer   no-undo .
define variable p-type-margin    as logical   no-undo .
define variable p-value-increase as integer   no-undo .
define variable p-type-increase  as logical   no-undo .
define variable p-value-rmethod  as integer   no-undo .
define variable p-type-rmethod   as logical   no-undo .


run gds-attr-margin-value
(
  input   buf-goods.gds-code ,
  input   buf-price-list.obj-type  ,
  input   buf-price-list.obj-code  ,
  output  p-prc-min  ,
  output  p-prc-max  ,
  output  loc-grp-increase-pc,
  output  p-round-method   ,
  output  p-base           ,
  output  p-value-margin    ,
  output  p-type-margin     ,
  output  p-value-increase    ,
  output  p-type-increase   ,
  output  p-value-rmethod    ,
  output  p-type-rmethod
  ) no-error .

  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
     "Ошибка процедуры поиска наценки по группе товара на объекте" skip
     error-status :get-message(1) skip
     return-value .
  end.
  define variable g-g as logical no-undo .
  g-g = false .
  case calc-method:
    when {&pr-calc-goods} then do:
      /* нужно посчитать цену способом из ub.goods */
      case buf-goods.calc-method:
        when {&pr-calc-grp} then do:
          /* нужно посчитать цену способом из gds-grp */
          find buf-gds-grp no-lock where
              buf-gds-grp.node-code = buf-goods.grp-code.
          case buf-gds-grp.calc-method:
            { str/pr-calc.i loc-grp-increase-pc buf-price-doc buf-price-list buf-goods buf-bar-code {2} }
          end case.
           /* Округление по группе */
           assign
            round-method = p-round-method
            round-base   = p-base
            g-g = true
           .
        end.
        { str/pr-calc.i loc-increase-pc buf-price-doc buf-price-list buf-goods buf-bar-code {2} }
      end case.
         if g-g = false then do:
              /* Округление по товару */
              define variable loc-rez as character no-undo .
              define variable t-type  as character no-undo .

              run gdsoattr-value (input {&attr-round-method-o},
                                  input buf-goods.gds-code,
                                  input buf-price-list.obj-type,
                                  input buf-price-list.obj-code,
                                  output loc-rez ,
                                  output t-type)  no-error  .
              if error-status :error then message
                    vss-workfile vss-revision vss-description skip
                    error-status :get-message(1) skip
                    "gdsoattr-value"
                    view-as alert-box error .


              case NUM-ENTRIES (loc-rez," ") :
                  when 0 then do:
                  end.
                  when 1 then do:
                    round-method = loc-rez .
                    round-base   = 0 .
                  end.
                  when 2 then do:
                    round-method = entry(1 , loc-rez, " " ).
                    round-base   = decimal(entry(2 , loc-rez, " " )) .
                  end.
                  otherwise do:
                    round-method = entry(1 , loc-rez, " " ).
                    round-base   = decimal(entry(NUM-ENTRIES (loc-rez," ") , loc-rez, " " )) .
                  end.
              end case.
         end.
    end.
    { str/pr-calc.i increase-pc buf-price-doc buf-price-list buf-goods buf-bar-code {2} }
  end case.

&if "{2}"  = "in-pr"  &then
  run create-price-list-attr
  ( {&full-price-sale} ,
     tt-price-sale      ,
     buf-price-list.b-code ,
     buf-price-list.doc-num ,
     buf-price-list.price-type  ).
&endif
/* если не румынское топливо, а  стеклопосуда то берем среднеучетную по пол св св */
run main-road-tax
  ( input buf-price-list.obj-type ,
    input buf-price-list.obj-code ,
    input buf-price-list.artic    ,
    input buf-price-list.prod-type,
    input buf-price-list.prod-code,
    input-output cur-rt-base,
    input-output cur-rt-rubl )
    .
    if var-pr-r-b = "rubl" then do:
        if ( cur-rt-rubl <> ? )   then
          assign
            buf-price-list.road-tax  = cur-rt-rubl
            .
            else
                assign
                  buf-price-list.road-tax  = 0
                  .
   end.
   else do:
        if ( cur-rt-base <> ? )   then
          assign
            buf-price-list.road-tax  = cur-rt-base
            .
            else
                assign
                  buf-price-list.road-tax  = 0
                  .

   end.
  { str/pr-99.i
    buf-price-list.price-sale
    round-method
    round-base
  }

  calc-rec = recid (buf-price-list).


  run calc-pr-sub (input  buf-bar-code.b-code,
                   input  buf-price-list.doc-num,
                   input  calc-method,
                   input  increase-pc,
                   input  round-method,
                   input  round-base,
                   output calc-rec) no-error.
  if error-status :error then
    undo calc-pr, return error.
    old-price-sale = buf-price-list.price-sale .

   if line-mode = "calc":u then do:
        run calc-sigma (input buf-price-list.b-code,
                        input-output buf-price-list.price-sale,
                        input buf-price-doc.host-code,
                        input buf-price-doc.obj-code,
                        input buf-price-doc.obj-type,
                        output loc-ret).

        if loc-ret = false then
          message "Цена товара :" SKIP
          "артикул :" buf-price-list.artic buf-price-list.prod-type buf-price-list.prod-code skip
          "бар-код :" buf-price-list.b-code skip
            "не изменилась из-за заданного максимально допустимого отклонения! " skip
            " Рассчитанная цена "  old-price-sale skip
            " Действующая цена "   buf-price-list.price-sale
            view-as alert-box .
   end.
end.
END PROCEDURE.

procedure calc-sigma :
 do
 on error undo, return error return-value
 :
define input parameter l-bcode like ub.price-list.b-code no-undo .
define input-output parameter new-price as decimal no-undo .
define input parameter l-host as integer no-undo .
define input parameter l-code as integer no-undo .
define input parameter l-type as character no-undo .
define output parameter p-ret as logical no-undo .

define variable conf-par     as character no-undo.    /* для чтения параметра конфигурации */
define variable par-type     as character no-undo.    /* тип параметра конфигурации        */
define variable i-sigma as decimal no-undo .

define variable cur-pr like ub.price-list.price-sale no-undo.
define variable cur-rt like ub.price-list.road-tax   no-undo.
define variable cur-ex like ub.price-list.excise     no-undo.
define variable cur-dn like ub.price-list.doc-num    no-undo.
define variable old-price as decimal no-undo .

define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .


p-ret = true  . /* менять */

if par-pr-sigma <> ? and par-pr-sigma <> "" and par-pr-sigma <> "0" then do:
/* ищем предыдущий прайс-лист для этого объекта */
{ gbl/bcodeprc.i
  l-type
  l-code
  l-bcode
  0
  0
  cur-dn
  cur-pr
  cur-rt
  cur-ex }

old-price = cur-pr .
if old-price =  new-price then do:
   p-ret = true .
   return.
end.
   i-sigma = decimal(par-pr-sigma) .
   if ( 100 * ABSOLUTE( old-price - new-price ) / old-price ) <= i-sigma then do:
       assign
         p-ret = false
         new-price = old-price
       .
       end.
   else p-ret = true .
  end.
 end. /* do */
end procedure. /* calc-sigma */




&endif

&if "{1}" = "proc-ver" &then

{ str/prl-vat.i }
{ gbl/tax-name.i }

Procedure compare_road-tax :
  define input-output parameter new-road-tax as decimal no-undo .
  define input parameter p-b-code like ub.bar-code.b-code no-undo.
  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer   no-undo .
  define input parameter p-mess     as logical   no-undo .

  define variable v-log      as logical   no-undo .
  define variable p-cur-dn   as character no-undo .
  define variable p-cur-pr   as decimal   no-undo .
  define variable p-cur-rt   as decimal   no-undo .
  define variable p-cur-ex   as decimal   no-undo .
  define variable v-name-tax as character no-undo .


      { gbl/bcodeprc.i
        p-obj-type
        p-obj-code
        p-b-code
        0
        0
        p-cur-dn
        p-cur-pr
        p-cur-rt
        p-cur-ex }
if p-cur-dn <> ? Then DO :
   new-road-tax = p-cur-rt .
End.
end procedure.
&endif
&if "{1}" = "main-road-tax" &then
{ str/lib-trn.i }
procedure main-road-tax :
define input parameter p-obj-type  like ub.gds-obj.obj-type  no-undo .
define input parameter p-obj-code  like ub.gds-obj.obj-code  no-undo .
define input parameter p-artic     like ub.gds-obj.artic     no-undo .
define input parameter p-prod-type like ub.gds-obj.prod-type no-undo .
define input parameter p-prod-code like ub.gds-obj.prod-code no-undo .
define input-output parameter p-road-tax-base as decimal no-undo .
define input-output parameter p-road-tax-rubl as decimal no-undo .
define variable v-doc-code as character no-undo .

define buffer     buff-goods    for ub.goods      .
define buffer     buf_gds-obj   for ub.gds-obj .
define buffer     buf_parts     for ub.parts   .


define buffer b-td_trn-doc for ub.trn-doc  .
define buffer b-dl_doc-line for ub.doc-line .

define variable is-petrolium              as logical no-undo .
define variable is-pieces                 as logical no-undo .
define variable is-hold-td                as logical no-undo .
define variable v-rec                     as recid   no-undo .
define variable t-ret                     as logical no-undo .
define variable v-total-avrg-base         as decimal no-undo .
define variable v-total-avrg-rubl         as decimal no-undo .
define variable v-total-avrg-qnty         as decimal no-undo .
define variable v-total-road-tax-base     as decimal no-undo .
define variable v-total-road-tax-rubl     as decimal no-undo .
define variable v-all-total-road-tax-base as decimal no-undo .
define variable v-all-total-road-tax-rubl as decimal no-undo .

assign
  p-road-tax-base = ?
  p-road-tax-rubl = ?
  .

  Find first buff-goods no-lock where
        buff-goods.artic     = p-artic and
        buff-goods.prod-type = p-prod-type and
        buff-goods.prod-code = p-prod-code
        no-error .

/* Проверочка наличия Третьего налога */

      If avail buff-goods Then DO:
           v-rec = recid (buff-goods).
           t-ret =  session:SET-WAIT-STATE("GENERAL") .
          { str/is-petrl.i
            p-artic
            p-prod-type
            p-prod-code
            is-petrolium
            is-pieces
             }
           t-ret =  session:set-wait-state("") .
           if not ( hvrdtax( v-rec ) = true and  is-petrolium = false  )   then  do:
                assign
                  p-road-tax-base = ?
                  p-road-tax-rubl = ?
                  .
                return.
           end.
      end.
      assign
          v-total-avrg-qnty = 0
          v-total-road-tax-base =  0
          v-total-road-tax-rubl =  0
          v-all-total-road-tax-base =  0
          v-all-total-road-tax-rubl =  0
          .

      /*
        возвращается средняя учетная цена положительных партий свободной зоны по объекту
        не учитываются партии зарезервированные за незакрытыми документами
      */

      for each buf_parts no-lock
        where buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
          and buf_parts.status_   = no
          and buf_parts.out-code  = {&free-code}  /* только партии свободной зоны */
          and buf_parts.qnty      > 0             /* только положительные партии  */
      on error undo, return error
      :
         v-total-avrg-qnty = v-total-avrg-qnty + buf_parts.fact-qnty.
         { str/in-vatp.i calc-parts buf_parts. buf_td. g }

        assign
          v-all-total-road-tax-base =  v-all-total-road-tax-base + (road-tax-base-loc * buf_parts.fact-qnty)
          v-all-total-road-tax-rubl =  v-all-total-road-tax-rubl + (road-tax-rubl-loc * buf_parts.fact-qnty)
         .

      end.
          if v-total-avrg-qnty > 0 then  do :
              assign
                  p-road-tax-base =  v-all-total-road-tax-base  / v-total-avrg-qnty
                  p-road-tax-rubl =  v-all-total-road-tax-rubl  / v-total-avrg-qnty
                  .
           end.

            if v-total-avrg-qnty <= 0 then do :
              find first buf_gds-obj no-lock
                where buf_gds-obj.obj-type  = p-obj-type
                  and buf_gds-obj.obj-code  = p-obj-code
                  and buf_gds-obj.artic     = p-artic
                  and buf_gds-obj.prod-type = p-prod-type
                  and buf_gds-obj.prod-code = p-prod-code
                no-error .
                    if available buf_gds-obj then do :
                      /* состав последнего прихода */
                      if buf_gds-obj.in-code <> "" then
                           v-doc-code = buf_gds-obj.in-code.
                      else do:
                        if available ub.price-doc then  v-doc-code = ub.price-doc.out-code.
                      end.

                      /* Для межфирменного перемещения не учитываем road-tax */
                      { gbl/hold-doc.i
                        v-doc-code
                        is-hold-td
                      }
                      if is-hold-td = true then do:
                        assign
                            p-road-tax-rubl = 0
                            p-road-tax-base = 0
                            .
                      end.
                      else do:
                          find b-td_trn-doc  where b-td_trn-doc.doc-code   = v-doc-code no-lock no-error .
                          find b-dl_doc-line where b-dl_doc-line.doc-code  = b-td_trn-doc.doc-code
                                          and b-dl_doc-line.artic     = p-artic
                                          and b-dl_doc-line.prod-type = p-prod-type
                                          and b-dl_doc-line.prod-code = p-prod-code no-lock no-error.
                                if available b-dl_doc-line then do :
                                  { str/in-vatp.i calc b-dl_doc-line. b-td_trn-doc. g}
                                    assign
                                        p-road-tax-rubl =  road-tax-rubl-loc
                                        p-road-tax-base =  road-tax-base-loc
                                        .
                                end.
                      end.
                     end.
            end.
end procedure. /* main-road-tax */

&endif
&if "{1}" = "ver-pr-equ-dq" &then

PROCEDURE VER-PR-EQU-DQ :
/*
ДЛЯ АВТОПЕРЕОЦЕНОК
При закрытии переоценки удалять строки главных цен,
     цена по которым не изменилась,
     если для них нет специальных и неосновных;
     Удалять специальные и неосновные, цены которых равны главной
*/

define input parameter  l-doc-num    like ub.price-list.doc-num    no-undo .
define input parameter  l-num       as integer no-undo .
define input parameter  l-b-code    as integer   no-undo .


define variable  l-doc-num2    like ub.price-list.doc-num    no-undo .
define buffer l-price-list  for ub.price-list .
define buffer pp_price-list for ub.price-list .
define buffer p2_price-list for ub.price-list .
define buffer main_price-list for ub.price-list .
define buffer alt_price-list  for ub.price-list .
define buffer buf1-bar-code for ub.bar-code .
define buffer buf2-bar-code for ub.bar-code .
define variable v-num as integer init 0 no-undo .
define variable bbb as logical no-undo .

define variable  l-price-sale like ub.price-list.price-sale no-undo .
define variable  l-road-tax   like ub.price-list.road-tax   no-undo .
define variable  l-excise     like ub.price-list.excise     no-undo .
define variable  l-ok         as logical no-undo .
define variable  check-par    as logical no-undo .

for each l-price-list where l-price-list.doc-num = l-doc-num     and
                            l-price-list.main-price = true
                            exclusive-lock  :
  find first ub.goods where ub.goods.artic    = l-price-list.artic and
                        ub.goods.prod-type = l-price-list.prod-type and
                        ub.goods.prod-code = l-price-list.prod-code no-lock   .
      check-par = false .
     /* ?????? */
      if l-num = 2 then do:
        find first buf2-bar-code where buf2-bar-code.b-code = l-b-code no-lock no-error .
        if ub.goods.gds-code <> buf2-bar-code.gds-code then next.
      end.

   /* ищем предыдущую цену товара по текущему объекту */
  { gbl/bcodeprc.i
    l-price-list.obj-type
    l-price-list.obj-code
    l-price-list.b-code
    0
    0
    l-doc-num2
    l-price-sale
    l-road-tax
    l-excise
  no-error }

      if l-doc-num2 <> ? then do :
        if l-price-sale = l-price-list.price-sale
        then do:
          if par-pr-equ-dq >= 2 then do: /* удаление с запросом или без */
            /* если есть признаки и ли неосн цены с другой ценой то не удаляем */
            check-par = false .
               for each pp_price-list no-lock where pp_price-list.doc-num = l-doc-num   and
                  pp_price-list.artic       =  l-price-list.artic      and
                  pp_price-list.prod-type   =  l-price-list.prod-type  and
                  pp_price-list.prod-code   =  l-price-list.prod-code  and
                  pp_price-list.main-price  =  no  :
                    check-par = true  .
                    leave.
                end.

            if  check-par = true then NEXT .
            if par-pr-equ-dq = 2 then do:
              if  ( v-num <= 2  and check-par = false ) then
              run gbl/d-askw.w
                (input "Удалить строку?" /* Заголовок окна */
                ,input      "Предыдущая цена РАВНА цене по закрываемому документу " + {&new-line}
                            + " Объект "  + l-price-list.obj-type + " " + String(l-price-list.obj-code) + {&new-line}
                            + " Артикул " + l-price-list.artic    + " " +  ub.goods.gds-name + {&new-line}
                            + " Бар-код " + string(l-price-list.b-code)
                            + " Цена по предыдущему документу № " + l-doc-num + " "
                            + string(l-price-sale) + {&new-line}
                            + string(l-price-list.price-sale)
                            + " Удалить строку? "
                ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                ,input "Да|Нет|Да для всех^confirm|Нет для всех^confirm" /* список названий кнопок  */
                ,input "Удалить строку|" /* список описаний кнопок */
                    + "Не удалять строку|"
                    + "Удалять у всех товаров, цена на которые не изменилась|"
                    + "Не удалять у всех товаров, цена на которые не изменилась"
                ,input 1 /* значение возвращаемое при нажатии enter */
                ,input 2 /* значение возвращаемое при нажатии escape */
                ,output v-num /* выбор пользователя */
                ).
              end.
              else do:
                v-num = 3 .
              end.

                if v-num = 1 then do:
                  run del-pr-list (input l-price-list.b-code,
                                  input l-price-list.doc-num,
                                  input ?,
                                  input ?) no-error.
                                  if error-status :error then do:
                                          message  vss-workfile vss-revision vss-description skip
                                          "Ошибка при удаление строки переоценки "
                                          l-price-list.b-code skip
                                          error-status :get-message(1) .
                                          return error.
                                  end.

                end.
                if v-num = 3  then do:
                   run del-pr-list (input l-price-list.b-code,
                                    input l-price-list.doc-num,
                                    input ?,
                                    input ?)
                                    no-error.
                end.

          end.
        end.
       end.
end.


  /* если есть признаки с одинаковой ценой то удаляем */
  /* удаление признаков с ценой как у товара  Если есть параметр то молча удаляем */
  if par-pr-equ-dq >= 2 then do:
     for each main_price-list no-lock where
              main_price-list.doc-num         = l-doc-num   and
              main_price-list.main-price      = true ,
        first ub.goods where ub.goods.artic   = main_price-list.artic and
                        ub.goods.prod-type = main_price-list.prod-type and
                        ub.goods.prod-code = main_price-list.prod-code no-lock   :

             if l-num = 2 then do:
                find first buf2-bar-code where buf2-bar-code.b-code = l-b-code no-lock no-error .
                if ub.goods.gds-code <> buf2-bar-code.gds-code then next.
             end.

            /* в этойже переоценке есть равные цены основной */
                for each pp_price-list no-lock where
                  pp_price-list.doc-num         = main_price-list.doc-num    and
                  pp_price-list.artic           = main_price-list.artic      and
                  pp_price-list.prod-type       = main_price-list.prod-type  and
                  pp_price-list.prod-code       = main_price-list.prod-code  and
                  pp_price-list.main-price      = no and
                  pp_price-list.price-sale      = main_price-list.price-sale  ,
                    first buf1-bar-code no-lock where
                      buf1-bar-code.b-code    = pp_price-list.b-code and
                      buf1-bar-code.unit-cli  = ub.goods.unit-base break by buf1-bar-code.b-code :

                          if first-of( buf1-bar-code.b-code ) then do:
                          bbb = false.
                                /* есть ли неосновные цены */

                                   for each alt_price-list where
                                          pp_price-list.doc-num         = alt_price-list.doc-num    and
                                          pp_price-list.artic           = alt_price-list.artic      and
                                          pp_price-list.prod-type       = alt_price-list.prod-type  and
                                          pp_price-list.prod-code       = alt_price-list.prod-code  and
                                          pp_price-list.main-price      = no  no-lock :
                                        /* пропускаем основной код признака */
                                        if pp_price-list.b-code   =  fnc-base-code (alt_price-list.b-code) and
                                          alt_price-list.b-code = pp_price-list.b-code then next.

                                          if fnc-base-code (alt_price-list.b-code) = pp_price-list.b-code
                                          then do:
                                                bbb = true .
                                                leave.
                                           end.

                                   end.
                                    if bbb = false then do:
                                        run del-pr-list ( input pp_price-list.b-code  ,
                                                          input pp_price-list.doc-num ,
                                                          input ? ,
                                                          input ? ) no-error.
                                        if error-status :error then do:
                                          message  vss-workfile vss-revision vss-description skip
                                          " Нельзя удалить " pp_price-list.b-code skip
                                          error-status :get-message(1) .
                                          end.
                                    end.
                          end.
                end.
     end. /* for each */
 end. /* if eq */
end procedure.


&endif

&if "{1}" = "func-befor" &then /* Процент Новой к Учетной  */

define variable var-pr-r-b as character no-undo .
{ gbl/curr-r-b.i  var-pr-r-b }

function fnc-cost-pc return decimal (buffer local-price-list for ub.price-list).
define variable f-cost     as decimal no-undo . /* для вывода в список учетной к новой  */
define variable f-cost-pc  as decimal no-undo . /* для вывода в список % новой к старой цене  */

find first ub.goods where ub.goods.artic = local-price-list.artic and
                       ub.goods.prod-type = local-price-list.prod-type and
                       ub.goods.prod-code = local-price-list.prod-code no-lock  no-error .

find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code and
     ub.gds-obj.obj-type = local-price-list.obj-type and
     ub.gds-obj.obj-code = local-price-list.obj-code no-error.
if  available ub.gds-obj then
  if ub.goods.gds-type = {&gds-goods} then
    assign
      f-cost = ( if var-pr-r-b = "rubl" then ub.gds-obj.avrg-rubl else ub.gds-obj.avrg-base)
      .
    else  f-cost = ?.
else f-cost = ?.

 f-cost-pc = (round(local-price-list.price-sale / f-cost , 2) - 1) * 100.
  if f-cost-pc > 9999 then
    f-cost-pc = ?. /* чтоб влезало в формат */
  return (f-cost-pc).
end function.

/* Процент Новой к Приходной  */
function fnc-pr-pc return decimal (buffer local-price-list for ub.price-list).

define variable f-pr     as decimal no-undo . /* для вывода в список учетной к новой  */
define variable f-pr-pc  as decimal no-undo. /* для вывода в список % новой к старой цене  */


find first ub.goods where ub.goods.artic = local-price-list.artic and
                       ub.goods.prod-type = local-price-list.prod-type and
                       ub.goods.prod-code = local-price-list.prod-code no-lock  no-error .

find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code and
     ub.gds-obj.obj-type = local-price-list.obj-type and
     ub.gds-obj.obj-code = local-price-list.obj-code  no-error .
if  available ub.gds-obj then do:
  if ub.goods.gds-type = {&gds-goods} then
    assign
      f-pr = (if var-pr-r-b = "rubl" then ub.gds-obj.last-rubl else ub.gds-obj.last-base)
      .
    else f-pr = ?.
end.
else f-pr = ?.
  f-pr-pc = ( local-price-list.price-sale / f-pr - 1 ) * 100.
  if f-pr-pc > 9999 then
    f-pr-pc = ?. /* чтоб влезало в формат */
  return (f-pr-pc).
end function.

/*  Учетной  */
function fnc-cost return decimal (buffer local-price-list for ub.price-list).
define variable f-cost   as decimal no-undo . /* для вывода в список учетной к новой  */
find first ub.goods where
           ub.goods.artic = local-price-list.artic and
           ub.goods.prod-type = local-price-list.prod-type and
           ub.goods.prod-code = local-price-list.prod-code no-lock
           no-error .

find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code and
     ub.gds-obj.obj-type = local-price-list.obj-type and
     ub.gds-obj.obj-code = local-price-list.obj-code no-error.
if  available ub.gds-obj then
  if ub.goods.gds-type = {&gds-goods} then
    assign
      f-cost = if var-pr-r-b = "rubl" then ub.gds-obj.avrg-rubl else ub.gds-obj.avrg-base
      .
    else  f-cost = ?.
else f-cost = ?.
  return ( f-cost ).
end function.


/*  Приходная  */
function fnc-pr return decimal (buffer local-price-list for ub.price-list).
define variable f-pr   as decimal no-undo . /* для вывода в список учетной к новой  */
find first ub.goods where ub.goods.artic = local-price-list.artic and
                       ub.goods.prod-type = local-price-list.prod-type and
                       ub.goods.prod-code = local-price-list.prod-code no-lock  no-error .

find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code and
     ub.gds-obj.obj-type = local-price-list.obj-type and
     ub.gds-obj.obj-code = local-price-list.obj-code no-error.
if  available ub.gds-obj then
  if ub.goods.gds-type = {&gds-goods} then
    assign
      f-pr = if var-pr-r-b = "rubl" then ub.gds-obj.last-rubl  else ub.gds-obj.last-base
      .
    else  f-pr = ?.
else f-pr = ?.
   return ( f-pr ).
end function.
&endif

&if "{1}" = "ver-pr-discn" &then
{ str/specattr.i }

procedure ver-pr-discn :

define input parameter   p-mode as character no-undo .
define input parameter   p-doc like ub.price-doc.doc-num no-undo.
define input parameter   trn-doc-code like ub.trn-doc.doc-code no-undo .
define output parameter  p-err as logical no-undo .

{ str/in-vatp.i def }

define buffer buf_bar-code for ub.bar-code  .
define buffer b_price-doc  for ub.price-doc .
define buffer b_price-list for ub.price-list .
define buffer b_trn-doc    for ub.trn-doc .
define buffer b_doc-line   for ub.doc-line .
define buffer bl_goods           for ub.goods .
define buffer bl_gds-grp         for ub.gds-grp .

define variable t-prc            as decimal   no-undo .
define variable p-prc-min        as decimal   no-undo .
define variable p-prc-max        as decimal   no-undo .
define variable p-increase-pc    as decimal   no-undo .
define variable p-round-method   as character no-undo .
define variable p-base           as decimal   no-undo .
define variable v-koff           as decimal   no-undo .
define variable p-node-code      as integer   no-undo .      /* код группы   */
define variable p-host-code      as integer   no-undo .      /* код фирмы    */
define variable p-obj-type       as character no-undo .      /* тип объекта  */
define variable p-obj-code       as integer   no-undo .      /* код объекта  */
define variable p-value-margin   as integer   no-undo .      /* область действия */
define variable p-type-margin    as logical   no-undo .
define variable p-value-increase as integer   no-undo .      /* область действия */
define variable p-type-increase  as logical   no-undo .
define variable p-value-rmethod  as integer   no-undo .
define variable p-type-rmethod   as logical   no-undo .


define variable l_price           as decimal   no-undo .
define variable l_pricewithvat    as decimal   no-undo .
define variable l_pricewithoutvat as decimal   no-undo .
define variable l_prod-vat        as decimal   no-undo .
define variable pr-discm          as character no-undo .
define variable pr-gen-margin     as character no-undo .
p-err = false .

define variable cost-base     as decimal  no-undo .
define variable cost-rubl     as decimal  no-undo .
define variable v-price-base  as decimal  no-undo .
define variable v-price-rubl  as decimal  no-undo .
define variable cur-rt-base   as decimal  no-undo .
define variable cur-rt-rubl   as decimal  no-undo .

define variable f-cost as decimal no-undo .
define variable s-cost as decimal no-undo .
define variable f-qnty as decimal no-undo .
define variable s-qnty as decimal no-undo .

define variable p-attr-code    like UB.price-list-attr.attr-code  no-undo .
define variable p-b-code       like ub.price-list-attr.b-code     no-undo .
define variable p-doc-num      like ub.price-list-attr.doc-num    no-undo .
define variable p-price-type   like ub.price-list-attr.price-type no-undo .
define variable p-attr-value   like ub.price-list-attr.attr-value no-undo .
define variable v-bonus as decimal   no-undo .
define variable l_price0 as decimal   no-undo .

define buffer   buf_contract-specif for ub.contract-specif  .

find first b_price-doc where b_price-doc.doc-num    = p-doc no-lock  no-error .
assign
    p-host-code  = b_price-doc.host-code
    p-obj-type   = b_price-doc.obj-type
    p-obj-code   = b_price-doc.obj-code
.

define variable v-ok as logical   no-undo .

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_overvalue_discount':U
  {&cntxt-object}
  p-host-code
  p-obj-type
  p-obj-code
  0
  0
  0
  false
  v-ok
}

if v-ok = true then return .

pr-discm      = par-pr-discm .

if trim(pr-discm) = "" then return .
if pr-discm = 'sale-' then pr-discm = 'sale' .

for each  b_price-list where b_price-list.doc-num    = p-doc no-lock :
    find first bl_goods   where b_price-list.artic     = bl_goods.artic     and
                                b_price-list.prod-code = bl_goods.prod-code and
                                b_price-list.prod-type = bl_goods.prod-type no-lock no-error .
    if error-status :error then return error.
    find first buf_bar-code no-lock where
               buf_bar-code.b-code  = b_price-list.b-code
               no-error .
    if available buf_bar-code then v-koff = buf_bar-code.cli-base-rate .
    else v-koff = 1.
    if v-koff = ? or v-koff = 0 then v-koff = 1.


    assign
    p-node-code  = bl_goods.grp-code
    .
    run gds-attr-margin-value
    (
      input   bl_goods.gds-code,
      input   p-obj-type ,
      input   p-obj-code ,
      output  p-prc-min  ,
      output  p-prc-max  ,
      output  p-increase-pc,
      output  p-round-method,
      output  p-base        ,
      output  p-value-margin    ,
      output  p-type-margin     ,
      output  p-value-increase   ,
      output  p-type-increase   ,
      output  p-value-rmethod   ,
      output  p-type-rmethod
      ) no-error .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "123"
        view-as alert-box error
      .
    if p-type-margin = false  then next.
 if  trn-doc-code = ? or trn-doc-code = "" then do: /*  это созданные вручную переоценки */
        if b_price-list.main-price = true then do :
          case  pr-discm :
              when "prod":u then do:
                 { gbl/proprice.i
                   b_price-list.b-code
                   p-obj-type
                   p-obj-code
                   l_pricewithoutvat
                   l_price
                   l_prod-vat
                   v-str
                   v-str
                   }

                  t-prc  =  (b_price-list.price-sale  / l_price - 1) * 100  .
              end.
              when "prod-vat":u then do:
                 { gbl/proprice.i
                   b_price-list.b-code
                   p-obj-type
                   p-obj-code
                   l_price
                   l_pricewithvat
                   l_prod-vat
                   v-str
                   v-str
                   }

                  t-prc  =  (b_price-list.price-sale  / l_price - 1) * 100  .
              end.


              when "cost-vat":u then do:
                  run str/gdsnovat.p ({&pr-calc-cost-novat},
                          b_price-list.obj-type,
                          b_price-list.obj-code,
                          p-host-code,
                          b_price-list.artic,
                          b_price-list.prod-type,
                          b_price-list.prod-code,
                          0 ,
                          ? ,
                          ? ,
                          ? ,
                          output cost-base   ,
                          output cost-rubl   ,
                          output v-price-base  ,
                          output v-price-rubl  ,
                          output cur-rt-base ,
                          output cur-rt-rubl ).
                          l_price =  if var-pr-r-b = "rubl" then v-price-rubl else v-price-base .
                          t-prc = (b_price-list.price-sale / l_price - 1) * 100.

              end.
            when "cost":u       then do:
              t-prc =  fnc-cost-pc (buffer b_price-list) .
            end.
            when "sale":u then do:
              t-prc =  fnc-pr-pc   (buffer b_price-list) .
            end.
          end case.
        end.
        else do:
           /* НЕОСНОВНЫЕ КОДЫ И ПРИЗНАКИ */


          case  pr-discm :
              when "prod":u then do:
                 { gbl/proprice.i
                   b_price-list.b-code
                   p-obj-type
                   p-obj-code
                   l_pricewithoutvat
                   l_price
                   l_prod-vat
                   v-str
                   v-str
                   }
              end.
              when "prod-vat":u then do:
                 { gbl/proprice.i
                   b_price-list.b-code
                   p-obj-type
                   p-obj-code
                   l_price
                   l_pricewithvat
                   l_prod-vat
                   v-str
                   v-str
                   }
            end.
            when "cost":u
            or when "cost-vat":u
            then do:
              l_price =  fnc-cost (buffer b_price-list) .
            end.
            when "sale":u then do:
              l_price =  fnc-pr   (buffer b_price-list) .
            end.
          end case.

          t-prc = (b_price-list.price-sale / (l_price * v-koff) - 1) * 100.
        end.
end.
else do:  /* trn-doc-code <> ? and  trn-doc-code <> "" */
    find first b_trn-doc where b_trn-doc.doc-code = trn-doc-code no-lock no-error .
    if available b_trn-doc then do:
     find first b_doc-line where
        b_doc-line.doc-code  = b_trn-doc.doc-code and
        b_doc-line.artic     = bl_goods.artic     and
        b_doc-line.prod-code = bl_goods.prod-code and
        b_doc-line.prod-type = bl_goods.prod-type no-lock no-error .
     end.
     else do:
       return error return-value + "Не найден документ с номером " + trn-doc-code.
     end.
/*
    find first buf_contract-specif no-lock where
               buf_contract-specif.contract-num = b_trn-doc.contract-code and
               buf_contract-specif.host-code    = b_trn-doc.host-code and
               buf_contract-specif.gds-code     = bl_goods.gds-code
               no-error .
*/
    {str/cont-slave-inc.i
         &FIND_FIRST = YES
         &BUFFER_SPECIF = buf_contract-specif
         &P_HOST_CODE = b_trn-doc.host-code
         &P_CONTRACT_NUM = b_trn-doc.contract-code
         &P_GDS_CODE = bl_goods.gds-code
         &NO_LOCK=YES
         &NO_ERROR=YES
    }

    if available buf_contract-specif then do:
        run read-bonus (
            input  buf_contract-specif.contract-num  ,
            input  buf_contract-specif.host-code     ,
            input  buf_contract-specif.gds-code      ,
            output v-bonus  ) .
    end.
    else do:
        v-bonus  = 0 .
    end.

      if b_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then   pr-gen-margin = par-gen-mrgn-ie.
      if b_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} then   pr-gen-margin = par-gen-mrgn-iv.
      if b_trn-doc.ext-doc-type = {&TDEDT_Pri_Prvo}  then   pr-gen-margin = par-gen-mrgn-im.

      pr-gen-margin = lc(pr-gen-margin).

      if available b_doc-line then do:
      case  pr-discm :
        when "cost":u then do:
                f-qnty = 0.
                find ub.gds-obj no-lock where
                    ub.gds-obj.gds-code = bl_goods.gds-code and
                    ub.gds-obj.obj-type = b_trn-doc.obj-type and
                    ub.gds-obj.obj-code = b_trn-doc.obj-code no-error.
                if  available ub.gds-obj then
                  if bl_goods.gds-type = {&gds-goods} then do:
                          if var-pr-r-b = "rubl" then
                              assign
                                f-cost = if  ub.gds-obj.avrg-rubl = ? then 0 else ub.gds-obj.avrg-rubl
                                f-qnty = ub.gds-obj.avrg-qnty
                                .
                          else
                              assign
                                f-cost = if  ub.gds-obj.avrg-base = ? then 0 else ub.gds-obj.avrg-base
                                f-qnty = ub.gds-obj.avrg-qnty
                                .
                      end.
                    else  f-cost = ?.
                else f-cost = ?.

           if pr-gen-margin = {&typeprice_before-margin} then do:
           { str/in-vatp.i calc b_doc-line. b_trn-doc. }
             if var-pr-r-b = "rubl" then
                 s-cost = price-rubl-with-tax-loc.
               else
                 s-cost = price-base-with-tax-loc.

             s-qnty = b_doc-line.fact-qnty .
           end.
           else do:
             assign
              s-cost = 0
              s-qnty = 0
             .
           end.
           l_price  =  (f-cost * f-qnty + s-cost * s-qnty ) / (f-qnty + s-qnty)  .

        end.
        when "cost-vat":u then do:
             run str/gdsnovat.p ({&pr-calc-cost-wbill-novat},
                     b_trn-doc.obj-type,
                     b_trn-doc.obj-code,
                     b_trn-doc.host-code,
                     b_doc-line.artic,
                     b_doc-line.prod-type,
                     b_doc-line.prod-code,
                     0 ,
                     b_doc-line.doc-code,
                     ?,
                     ?,
                     output cost-base   ,
                     output cost-rubl   ,
                     output v-price-base  ,
                     output v-price-rubl  ,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
                     if var-pr-r-b = "rubl"
                        then l_price = v-price-rubl.
                        else l_price = v-price-base.


        end.
        when "sale":u then do:
              l_price = ( if var-pr-r-b = "rubl"
                             then b_doc-line.price-rubl
                             else b_doc-line.price-base ).
        end.
        when "prod":u then do:
            { gbl/proprice.i
              b_price-list.b-code
              p-obj-type
              p-obj-code
              l_pricewithoutvat
              l_price
              l_prod-vat
              v-str
              v-str
              }
        end.
        when "prod-vat":u then do:
            { gbl/proprice.i
              b_price-list.b-code
              p-obj-type
              p-obj-code
              l_price
              l_pricewithvat
              l_prod-vat
              v-str
              v-str
              }
        end.
      end case.

       run view-price-list-attr (
            input   {&full-price-sale}   ,
            input   b_price-list.b-code       ,
            input   b_price-list.doc-num      ,
            input   b_price-list.price-type   ,
            output  p-attr-value   ).


           if not ( p-attr-value = ? or p-attr-value = "")  then
                   tt-price-sale = decimal(p-attr-value).
              else  tt-price-sale = b_price-list.price-sale .

        if v-bonus <> ? and v-bonus <> 0 then do:
            l_price0 = l_price .
            l_price = l_price + ( l_price * v-bonus / 100 ) .
        end.
        t-prc = ( (tt-price-sale / v-koff)   / l_price - 1) * 100 .
   end.
end.

/*
message pr-discm skip
        p-prc-max  skip
        p-prc-min       skip
        "trn-doc-code = " trn-doc-code skip
        b_price-list.artic
        skip
        skip
        "переоценка =        " b_price-list.price-sale skip
        "переоценка полная   " tt-price-sale skip
        "- база сравнения    " l_price      skip
        "- бонус             "  v-bonus      skip
        "- база без бонуса   " l_price0  skip
        " получился процент% " t-prc
        .
  */

  if  p-prc-max <> ? then do:
    if  t-prc <> ? and ( p-prc-max < t-prc  or p-prc-min > t-prc)
    then do:
      message (if b_price-list.main-price = true then "По товару :"
          else "По признаку"  )
          b_price-list.artic
          b_price-list.prod-type
          b_price-list.prod-code skip
          "бар-код: " b_price-list.b-code skip
                          skip
               fnc-pr  (buffer b_price-list)
          skip
        "Процент торговой наценки вышел за интервал возможных значений !!! " skip
        "Процент не менее :" p-prc-min "%" skip
        "Процент не более :" p-prc-max "%" skip
        "Процент фактический :" t-prc  "%"  skip
        "переоценка " b_price-list.doc-num
            view-as alert-box error .
              p-err = true .
              undo , return error .
    end.
    else do:
       if  t-prc = ? then  do:
          if pr-discm = "sale"  then do:
          end.
          else do:
            message (if b_price-list.main-price = true then "По товару :"
            else "По признаку"  )
            b_price-list.artic
            b_price-list.prod-type
            b_price-list.prod-code skip
            "бар-код: " b_price-list.b-code skip
            fnc-pr  (buffer b_price-list) skip
            "Нет базовой цены для расчета процента наценки !" skip
            "Процент торговой наценки вышел за интервал возможных значений !!! " skip
            "Процент не менее :" p-prc-min "%" skip
            "Процент не более :" p-prc-max "%" skip
            "Процент фактический :" t-prc  "%"  skip
            "переоценка " b_price-list.doc-num

            view-as alert-box error .
            p-err = true .
            undo , return error .
        end.
       end.
    end.
  end.
end.
end procedure.
&endif

&if "{1}" = "ver-modificator-price-is-null" &then


procedure ver-modificator-price-is-null :
 do
 on error undo, return error return-value
 :
define input parameter p-artic     like ub.goods.artic no-undo.
define input parameter p-prod-type like ub.goods.prod-type no-undo.
define input parameter p-prod-code like ub.goods.prod-code no-undo.
define input parameter p-obj-type  like ub.clients.obj-type no-undo.
define input parameter p-obj-code  like ub.clients.obj-code no-undo.
define output parameter p-ret as logical no-undo .

/* если p-ret = нет , то товар в переоценку включать не надо */

define variable v-gds-code  like ub.goods.gds-code no-undo .

define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.

{ gbl/gds-code.i
  p-artic
  p-prod-type
  p-prod-code
  v-gds-code
  }

p-ret = true .
find first buf_fbr-gds-obj no-lock where
            buf_fbr-gds-obj.gds-code = v-gds-code and
            buf_fbr-gds-obj.obj-code = p-obj-code and
            buf_fbr-gds-obj.obj-type = p-obj-type use-index pi no-error .
 if available buf_fbr-gds-obj then
              if buf_fbr-gds-obj.is-modificator = true and
                 buf_fbr-gds-obj.is-null-price = true
                 then  p-ret = false .
 end. /* do */
end procedure. /* ver-modificator-price-is-null */

&endif
&if "{1}" = "exp-prt" &then
procedure exp-prt :
  /* ------------------------------------------------------------------------------------------------------------------------
    разворачивание спеццен по главной цене, если есть настройки
    ------------------------------------------------------------------------------------------------------------------------*/
  define input  parameter  g-code  like ub.goods.gds-code    no-undo.
  define input  parameter  old-num like ub.price-doc.doc-num no-undo.
  define input  parameter  new-num like ub.price-doc.doc-num no-undo.
  define output parameter  new-rec as recid               no-undo.

  do
  on error undo, return error return-value
  :

  define buffer buf-bar-code   for ub.bar-code.
  define buffer buf-goods      for ub.goods.
  define buffer buf-price-list for ub.price-list.

  find buf-goods no-lock where
      buf-goods.gds-code = g-code.

  /* Добавлять имеющиеся неосновные цены */
  if par-pr-altex = "yes" and
     par-pr-notls = "yes" then do:
    { str/alt-calc.i pr-altex old-num new-num }
  end.

  /* Добавлять имеющиеся цены признаков */
  if par-pr-sclex = "yes" and
    par-pr-notls = "yes" then do:
    { str/alt-calc.i pr-sclex old-num new-num }
  end.

  end.

end procedure. /* exp-prt */

&endif


&if "{1}" = "check-alc-min-price" &then
procedure check-alc-min-price :
 do
 on error undo, return error return-value
 :
  define input parameter   p-doc        like ub.price-doc.doc-num no-undo.
  define output parameter  p-err        as logical no-undo .

  define variable v-alcohol-prod  as logical   no-undo.
  define variable v-alc-min-price as character no-undo.
  define variable v-type          as character no-undo.
  define variable i               as integer   no-undo.
  define variable proof-price     as character no-undo.
  define variable v-base-code     as integer   no-undo.
  define variable v-curr-r-b      as character no-undo.
  define variable v-price-sale    as decimal   no-undo.
  define variable v-abbr          as character no-undo.

  define buffer buf_goods       for ub.goods .
  define buffer buf_gds-obj     for ub.gds-obj .
  define buffer buf_gds-grp-obj for ub.gds-grp-obj .
  define buffer b_price-doc     for ub.price-doc .
  define buffer b_price-list    for ub.price-list .
  define buffer buf_currency    for ub.currency .

  find first b_price-doc no-lock
       where b_price-doc.doc-num = p-doc no-error .
  { gbl/basecode.i b_price-doc.host-code v-base-code }

  find first buf_currency no-lock
       where buf_currency.curr-code = v-base-code no-error .
  if available buf_currency then do:
    assign v-abbr = buf_currency.curr-abbr .
  end.

  for each b_price-list no-lock
     where b_price-list.doc-num = p-doc :

    find first buf_goods no-lock
         where buf_goods.artic     = b_price-list.artic
           and buf_goods.prod-code = b_price-list.prod-code
           and buf_goods.prod-type = b_price-list.prod-type
           no-error .
    if error-status :error then return error.

    find first buf_gds-obj no-lock
         where buf_gds-obj.gds-code = buf_goods.gds-code
           and buf_gds-obj.obj-code = b_price-doc.obj-code
           and buf_gds-obj.obj-type = b_price-doc.obj-type
    no-error.

    /* Является ли товар алкогольной продукцией */
    { gbl/gdsat.i
      buf_goods.artic
      buf_goods.prod-type
      buf_goods.prod-code
      "'alcohol-prod=request':u"
      v-alcohol-prod
    }

    if v-alcohol-prod
    and buf_goods.ms-base > 0
    and buf_goods.proof > decimal({&alc-check-price}) /*мин. % содержания спирта, выше которого проверяется по закону*/
    then do:
        run ggoattr-value (
           input   buf_goods.grp-code
          ,input   b_price-doc.host-code
          ,input   b_price-doc.obj-type
          ,input   b_price-doc.obj-code
          ,input   {&ggoattr-alc-min-price}
          ,output  v-alc-min-price
          ,output  v-type ) no-error .

        if v-alc-min-price <> "" then do:
          if not can-find (first tmp-proof-price
          where tmp-proof-price.node-code = buf_goods.grp-code /*buf_gds-grp-obj.node-code*/
          )
          then do:
              do i = 1 to num-entries(v-alc-min-price, ";":u ) :
                  assign proof-price = entry(i, v-alc-min-price, ";":u).
                  create tmp-proof-price.
                  assign
                      tmp-proof-price.node-code = buf_goods.grp-code /*buf_gds-grp-obj.node-code*/
                      tmp-proof-price.proof = decimal(entry(1, proof-price))
                      tmp-proof-price.price = decimal(entry(2, proof-price))
                      .

              end.
          end.
          find first tmp-proof-price no-lock
              where tmp-proof-price.node-code = buf_goods.grp-code
                and tmp-proof-price.proof     < buf_goods.proof
              no-error.
          if available tmp-proof-price then do:
              if b_price-list.price-sale / buf_goods.ms-base < tmp-proof-price.price / 0.5  then do:
                p-err = true.
                return error
                substitute ("Для товара &1 - &9,&7объемом = &2л и с содержанием спирта = &3%, &7новая продажная цена = &4&8. &7Алкоголь крепостью свыше &5% должен иметь цену не менее &6&8 за 0,5л"
                    , string(buf_goods.artic) + " "
                    + string(buf_goods.prod-type) + " "
                    + string(buf_goods.prod-code)
                    , string(buf_goods.ms-base, ">9.999")
                    , buf_goods.proof
                    , b_price-list.price-sale
                    , tmp-proof-price.proof
                    , tmp-proof-price.price
                    , {&new-line}
                    , v-abbr
                    , buf_goods.gds-name
                    )
                .
              end.
          end.
          else do:
            p-err = true.
            return error
              substitute ("Для товара &1 - &5 &4 установлено содержание спирта = &2%, &4 В параметрах группы не найдены цены &3!!!"
                , string(buf_goods.artic) + " "
                + string(buf_goods.prod-type) + " "
                + string(buf_goods.prod-code)
                , buf_goods.proof
                , v-alc-min-price
                , {&new-line}
                , buf_goods.gds-name
                )
            .
          end.
        end.
    end.
  end.
end. /* do */
end procedure. /* check-alc-min-price */

&endif

/* $Workfile$ e n d */