/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры производства

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Required:
    { cmp/str-glbl.i }
    { cmp/library.i  }
    { str/fbrcode.i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
{ gbl/objsrv.i }
&global-define fbrlib-max-calls-in-recursion 50

define temp-table temp_fbrlib_recipe no-undo
    field recipe-code                   as character
    field fbr-doc-code                  as character
    field income-goods-doc-code         as character
    field count-income                  as integer     /* Число строк прихода */
    field qnty-income                   as decimal     /* Сумма по количествам приходуемых товаров */
    field sum-income-sale               as decimal     /* Сумма приходов в продажных ценах */
    field sum-income-cost-base          as decimal     /* Сумма приходов в учетных ценах без НДС */
    field sum-income-cost-rubl          as decimal
    field sum-income-vat-cost-base      as decimal     /* Сумма НДС приходов в учетных ценах  */
    field sum-income-vat-cost-rubl      as decimal
    field write-off-goods-doc-code      as character
    field write-off-office-doc-code     as character
    field count-write-off               as integer     /* Число строк списания */
    field qnty-write-off                as decimal     /* Сумма по количествам списаний товаров */
    field sum-write-off-sale            as decimal     /* Сумма списаний в продажных ценах */
    field sum-write-off-cost-base       as decimal     /* Сумма списаний в учетных ценах без НДС */
    field sum-write-off-cost-rubl       as decimal
    field sum-write-off-vat-cost-base   as decimal     /* Сумма НДС списаний в учетных ценах  */
    field sum-write-off-vat-cost-rubl   as decimal
index pi is primary unique recipe-code
index income income-goods-doc-code
index wogds write-off-goods-doc-code
index wooff write-off-office-doc-code
.
/* Для хранения информации об использовании компонентов разделки */
define temp-table temp_dressing-ingr no-undo
    field recipe-code   as character
    field gds-code      as integer
    field line-qnty     as decimal
    field used-qnty     as decimal
    field recipe-qnty   as decimal

    index pi is primary unique recipe-code gds-code
.
define temp-table temp_recipe-order no-undo     /* все рецепты в порядке, в котором их надо рассчитывать */
    field recipe-code   as character            /* рецепт */
    field order         as integer
    index pi is primary unique order
.
define temp-table temp_recipe-childs-qnty no-undo   /* все рецепты */
    field recipe-code   as character        /* рецепт */
    field childs-qnty   as integer          /* количество потомков */
    field order         as integer          /* порядковый номер рецепта */
    index pi is primary unique recipe-code
.
define temp-table temp_recipe-childs no-undo    /* потомки */
    field recipe-code       as character    /* рецепт родителя */
    field child-code        as integer      /* порядковый номер потомка в ветке родителя */
    field child-recipe-code as character    /* код рецепта */
    index pi is primary unique recipe-code child-code
.
define variable v-fbrlib-recipe-order               as integer  no-undo.        /* после упорядочивания рецептов равна их количеству */

{ gbl/cur-time.i }

/*==========================================================================*/
procedure fbrlib_create-fbr-doc :
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-userid as character no-undo .
define output parameter p-fbr-doc-code as character no-undo .
define output parameter p-recid as recid no-undo .

define variable v-host-code as integer no-undo .
define variable v-base-code as integer no-undo .
define variable v-obj-db-num as integer no-undo .
define variable v-db-num as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-doc-code as character no-undo .
define variable fi-pay-code as integer no-undo .

define buffer buf_fbr-doc for ub.fbr-doc.
define buffer buf_curr-accnt for ub.curr-accnt.

do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo , return error substitute( "&1. stop", vss-workfile )
on endkey undo , return error substitute( "&1. endkey", vss-workfile )
:


{ gbl/hostcode.i p-obj-type p-obj-code v-host-code }
{ gbl/objdbnum.i p-obj-type p-obj-code v-obj-db-num }
{ gbl/curdbnum.i v-db-num }
if v-obj-db-num <> v-db-num then do:
  return error substitute("Запрещено создание документа производства в чужой БД:&1БД &2&3 - &4&1текущая БД - &5"
                          , {&new-line}
                          , p-obj-type
                          , p-obj-code
                          , v-obj-db-num
                          , v-db-num).
end.
run cur-time in this-procedure ( output v-today, output v-time).
{ gbl/curobjdt.i p-obj-type p-obj-code v-today }
{ gbl/basecode.i v-host-code v-base-code }
find last buf_curr-accnt no-lock
    where buf_curr-accnt.curr-code = v-base-code
      and buf_curr-accnt.exch-date <= v-today use-index pi
no-error.
if not available buf_curr-accnt
then do:
  undo, return error substitute("На дату &1 неизвестен курс базовой валюты с кодом &2"
                                  , string(v-today, "99/99/9999")
                                  , v-base-code).
end.
run doc-code in this-procedure (
      input  "main"
    , input  p-obj-type
    , input  p-obj-code
    , input  ?
    , output v-doc-code
) no-error.
if error-status:error
then do:
  undo, return error substitute("Ошибка при генерации номера документа производства&1&2&1&3"
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value ).
end.
run trg/chkdocnm.p (
      input v-doc-code
    , input {&table_fbr-doc}
    , input ?
) no-error.
if error-status:error
then do:
  undo, return error substitute("Ошибка при проверке номера для нового документа производства&1&2&1&3"
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value ).
end.
create buf_fbr-doc.
assign
buf_fbr-doc.doc-code  = v-doc-code
buf_fbr-doc.creid     = p-userid
buf_fbr-doc.doc-date  = v-today
buf_fbr-doc.doc-type  = {&manufacturing}
buf_fbr-doc.host-code = v-host-code
buf_fbr-doc.obj-code  = p-obj-code
buf_fbr-doc.obj-type  = p-obj-type
buf_fbr-doc.PS        = "@"
buf_fbr-doc.status_   = {&g___new}
buf_fbr-doc.user-db-num = v-obj-db-num
buf_fbr-doc.user-name   = p-userid
.
run fbrlib_get-default-pay-code in this-procedure (
      input buf_fbr-doc.obj-type
    , input buf_fbr-doc.obj-code
    , output fi-pay-code
).
buf_fbr-doc.pay-code = fi-pay-code.
p-recid = recid(buf_fbr-doc).
p-fbr-doc-code = buf_fbr-doc.doc-code.

end.

end procedure. /* fbrlib_create-fbr-doc */

/*==========================================================================*/
procedure fbrlib_get-default-pay-code :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define output parameter p-pay-code  as integer          no-undo.

define variable v-host-code as integer no-undo .
define buffer buf_shop          for ub.shop.
define buffer buf_store         for ub.store.
define buffer buf_sysconf       for ub.sysconf.
do
for buf_shop
  , buf_store
  , buf_sysconf
on error undo, return error
:
  case p-obj-type  :
    when {&shop} then do:
        find first buf_shop no-lock
              where buf_shop.obj-code = p-obj-code
        no-error.
        if available buf_shop
        then do:
            assign
                p-pay-code = buf_shop.fbr-pay
            .
        end.
    end.        /* when {&shop} */
    when {&stock} then do:
        find first buf_store no-lock
              where buf_store.obj-code = p-obj-code
        no-error.
        if available buf_store
        then do:
            assign
                p-pay-code = buf_store.fbr-pay
            .
        end.
    end.        /* when {&store} */
  end case.       /* case p-obj-type */
  if p-pay-code = ?
  or p-pay-code = 0
  then do:
      { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
      find first buf_sysconf no-lock
            where buf_sysconf.host-code = v-host-code
      no-error.
      if available buf_sysconf
      then do:
          assign
              p-pay-code = buf_sysconf.fbr-pay
          .
      end.
  end.
  if p-pay-code = ?
  or p-pay-code = 0
  then do:
      { gbl/objdnpay.i
          p-obj-type
          p-obj-code
          p-pay-code
      }
  end.
end.
end procedure. /* fbrlib_get-default-pay-code */

/*==========================================================================*/
procedure fbrlib-fill-and-check-temp_fbrlib_recipe :
do
on error undo, return error
:
define input parameter p-fbr-doc-code as character    no-undo.

    define variable vss-description as character    no-undo init "fbrlib-fill-and-check-temp_fbrlib_recipe: ".
    define variable v-gds-name      as character    no-undo.

    define buffer buf_fbr-doc               for ub.fbr-doc.
    define buffer buf_fbr-line              for ub.fbr-line.
    define buffer buf_temp_fbrlib_recipe    for temp_fbrlib_recipe.
    define buffer buf_out_temp_fbrlib_recipe    for temp_fbrlib_recipe.

    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = p-fbr-doc-code
    .
    for each buf_temp_fbrlib_recipe
    :
        delete buf_temp_fbrlib_recipe.
    end.
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = p-fbr-doc-code
    :
        find first buf_temp_fbrlib_recipe
             where buf_temp_fbrlib_recipe.recipe-code = buf_fbr-line.recipe-code
        no-error.
        if not available buf_temp_fbrlib_recipe
        then do:
            create buf_temp_fbrlib_recipe.
            assign
                buf_temp_fbrlib_recipe.recipe-code = buf_fbr-line.recipe-code
                buf_temp_fbrlib_recipe.fbr-doc-code = buf_fbr-line.doc-code
            .
        end.
    end.
    for each buf_temp_fbrlib_recipe
    :
        assign
            buf_temp_fbrlib_recipe.count-income                = 0
            buf_temp_fbrlib_recipe.qnty-income                 = 0
            buf_temp_fbrlib_recipe.sum-income-sale             = 0
            buf_temp_fbrlib_recipe.sum-income-cost-base        = 0
            buf_temp_fbrlib_recipe.sum-income-cost-rubl        = 0
            buf_temp_fbrlib_recipe.sum-income-vat-cost-base    = 0
            buf_temp_fbrlib_recipe.sum-income-vat-cost-rubl    = 0
            buf_temp_fbrlib_recipe.count-write-off             = 0
            buf_temp_fbrlib_recipe.qnty-write-off              = 0
            buf_temp_fbrlib_recipe.sum-write-off-sale          = 0
            buf_temp_fbrlib_recipe.sum-write-off-cost-base     = 0
            buf_temp_fbrlib_recipe.sum-write-off-cost-rubl     = 0
            buf_temp_fbrlib_recipe.sum-write-off-vat-cost-base = 0
            buf_temp_fbrlib_recipe.sum-write-off-vat-cost-rubl = 0
        .
        for each buf_fbr-line no-lock
           where buf_fbr-line.doc-code     = p-fbr-doc-code
             and buf_fbr-line.trn-type     = {&income}
             and buf_fbr-line.recipe-code  = buf_temp_fbrlib_recipe.recipe-code
        :
            if ( buf_fbr-line.price-base   = ?
                or buf_fbr-line.price-rubl = ?
                or buf_fbr-line.price-base <= 0
                or buf_fbr-line.price-rubl <= 0 )
            and buf_fbr-line.fact-qnty <> 0             /* это может быть при альтернативе */
            and buf_fbr-line.rsrv-qnty <> ?             /* это не отходы */
            and buf_fbr-doc.is-free    = no             /* и не свободный документ */
            then do:
                { gbl/gds-arnm.i
                    buf_fbr-line.artic
                    buf_fbr-line.prod-type
                    buf_fbr-line.prod-code
                    v-gds-name
                no-error }
                if error-status :error
                then do:
                    assign
                        v-gds-name = ""
                    .
                end.
                undo, return error  substitute("&1 В документе пр-ва &2 учетная цена не определена или нулевая!&3Рецепт &4&3Товар: &5 &6"
                                              ,vss-description
                                              ,buf_fbr-doc.doc-code
                                              ,{&new-line}
                                              ,buf_fbr-line.recipe-code
                                              ,buf_fbr-line.artic
                                              ,v-gds-name).

            end.
            assign
                buf_temp_fbrlib_recipe.count-income             = buf_temp_fbrlib_recipe.count-income + 1
                buf_temp_fbrlib_recipe.qnty-income              = buf_temp_fbrlib_recipe.qnty-income
                                                                + buf_fbr-line.fact-qnty
                buf_temp_fbrlib_recipe.sum-income-sale          = buf_temp_fbrlib_recipe.sum-income-sale
                                                                + buf_fbr-line.price-sale * buf_fbr-line.fact-qnty
            .
            if buf_fbr-line.is-waste = no
            then do:
                assign
                    buf_temp_fbrlib_recipe.sum-income-cost-base     = buf_temp_fbrlib_recipe.sum-income-cost-base
                                                                    + buf_fbr-line.price-sum-base
                    buf_temp_fbrlib_recipe.sum-income-cost-rubl     = buf_temp_fbrlib_recipe.sum-income-cost-rubl
                                                                    + buf_fbr-line.price-sum-rubl
                    buf_temp_fbrlib_recipe.sum-income-vat-cost-base = buf_temp_fbrlib_recipe.sum-income-vat-cost-base
                                                                    + buf_fbr-line.price-sum-vat-base
                    buf_temp_fbrlib_recipe.sum-income-vat-cost-rubl = buf_temp_fbrlib_recipe.sum-income-vat-cost-rubl
                                                                    + buf_fbr-line.price-sum-vat-rubl
                .
            end.
        end.        /* for each buf_fbr-line - {&income} */
        for each buf_fbr-line no-lock
           where buf_fbr-line.doc-code     = p-fbr-doc-code
             and buf_fbr-line.trn-type     = {&write-off}
             and buf_fbr-line.recipe-code  = buf_temp_fbrlib_recipe.recipe-code
        :
            if ( buf_fbr-line.price-base   = ?
                or buf_fbr-line.price-rubl = ?
                or buf_fbr-line.price-base <= 0
                or buf_fbr-line.price-rubl <= 0 )
            and buf_fbr-line.fact-qnty <> 0             /* это может быть при альтернативе */
            and buf_fbr-line.rsrv-qnty <> ?             /* это не отходы */
            and buf_fbr-doc.is-free    = no             /* и не свободный документ */
            and buf_fbr-doc.status_    = {&permitted}   /* только при закрытии на факт! */
            then do:
                { gbl/gds-arnm.i
                    buf_fbr-line.artic
                    buf_fbr-line.prod-type
                    buf_fbr-line.prod-code
                    v-gds-name
                no-error }
                if error-status :error
                then do:
                    assign
                        v-gds-name = ""
                    .
                end.
                undo, return error  substitute("&1 В документе пр-ва &2 учетная цена не определена или нулевая!&3Рецепт &4&3Товар: &5 &6"
                                              ,vss-description
                                              ,buf_fbr-doc.doc-code
                                              ,{&new-line}
                                              ,buf_fbr-line.recipe-code
                                              ,buf_fbr-line.artic
                                              ,v-gds-name).
            end.
            assign
                buf_temp_fbrlib_recipe.count-write-off             = buf_temp_fbrlib_recipe.count-write-off + 1
                buf_temp_fbrlib_recipe.qnty-write-off              = buf_temp_fbrlib_recipe.qnty-write-off
                                                                + buf_fbr-line.fact-qnty
                buf_temp_fbrlib_recipe.sum-write-off-sale          = buf_temp_fbrlib_recipe.sum-write-off-sale
                                                                + buf_fbr-line.price-sale * buf_fbr-line.fact-qnty
            .
            if buf_fbr-line.is-waste = no
            then do:
                assign
                    buf_temp_fbrlib_recipe.sum-write-off-cost-base     = buf_temp_fbrlib_recipe.sum-write-off-cost-base
                                                                    + buf_fbr-line.price-sum-base
                    buf_temp_fbrlib_recipe.sum-write-off-cost-rubl     = buf_temp_fbrlib_recipe.sum-write-off-cost-rubl
                                                                    + buf_fbr-line.price-sum-rubl
                    buf_temp_fbrlib_recipe.sum-write-off-vat-cost-base = buf_temp_fbrlib_recipe.sum-write-off-vat-cost-base
                                                                    + buf_fbr-line.price-sum-vat-base
                    buf_temp_fbrlib_recipe.sum-write-off-vat-cost-rubl = buf_temp_fbrlib_recipe.sum-write-off-vat-cost-rubl
                                                                    + buf_fbr-line.price-sum-vat-rubl
                .
            end.
        end.        /* for each buf_fbr-line - {&write-off} */
/*        run fbrlib-check-temp-tables in this-procedure ( input "Расчет учетных цен по документу" ) no-error.*/
        if buf_fbr-doc.status_    = {&permitted}   /* только при закрытии на факт! */
        and ( abs( buf_temp_fbrlib_recipe.sum-write-off-cost-base     - buf_temp_fbrlib_recipe.sum-income-cost-base     ) > 0.01
        or abs( buf_temp_fbrlib_recipe.sum-write-off-cost-rubl     - buf_temp_fbrlib_recipe.sum-income-cost-rubl     ) > 0.01
        or abs( buf_temp_fbrlib_recipe.sum-write-off-vat-cost-base - buf_temp_fbrlib_recipe.sum-income-vat-cost-base ) > 0.01
        or abs( buf_temp_fbrlib_recipe.sum-write-off-vat-cost-rubl - buf_temp_fbrlib_recipe.sum-income-vat-cost-rubl ) > 0.01
            )
        then do:
         undo, return error
            substitute("В документе пр-ва &1 Не совпадают суммы учетных цен для списанного и оприходованного по рецепту товара.&2" +
                        "Рецепт: &3&2&4&4по списанному товару&4по оприходованному товару&2"  +
                        "Сумма в баз.вал.&4&5&4&4&6&2" +
                        "Сумма в &9.&4&7&4&4&8&2"
                       , buf_fbr-doc.doc-code
                       , {&new-line}
                       , buf_temp_fbrlib_recipe.recipe-code
                       , {&tabulation}
                       , buf_temp_fbrlib_recipe.sum-write-off-cost-base
                       , buf_temp_fbrlib_recipe.sum-income-cost-base
                       , buf_temp_fbrlib_recipe.sum-write-off-cost-rubl
                       , buf_temp_fbrlib_recipe.sum-income-cost-rubl
                       , "{&abbr_rub}"
                       )
           +
           substitute("НДС в баз.вал.&1&2&1&1&3&4" +
                      "НДС в &7.&1&5&1&1&6&4"
                     ,  {&tabulation}
                     ,buf_temp_fbrlib_recipe.sum-write-off-vat-cost-base
                     ,buf_temp_fbrlib_recipe.sum-income-vat-cost-base
                     ,{&new-line}
                     ,buf_temp_fbrlib_recipe.sum-write-off-vat-cost-rubl
                     ,buf_temp_fbrlib_recipe.sum-income-vat-cost-rubl
                     ,"{&abbr_rub}"
                     )       .

        end.
    end.        /* for each buf_temp_fbrlib_recipe */
end.
end procedure. /* fill-and-check-temp_fbrlib_recipe */

/*==========================================================================*/
/* Вместо fbr-calc.p */
/* Баланс подсчитывается только по товарам с рецептами, документы без рецептов
    будут рассчитаны отдельно, без баланса цен.                              */
procedure fbrlib-fill-sum-fbr-doc :
do
on error undo, return error
:
define input parameter p-fbr-doc-recid  as recid        no-undo.
define input parameter p-mode           as character    no-undo.    /* предварительный или окончательный расчет */

    define variable vss-description as character init "fbrlib-fill-sum-fbr-doc: "  no-undo.

    define buffer buf_fbr-doc           for ub.fbr-doc.
    define buffer buf_fbr-line          for ub.fbr-line.
    define buffer buf_temp_fbrlib_recipe   for temp_fbrlib_recipe.

    define variable v-in-count          as integer       no-undo.
    define variable v-out-count         as integer       no-undo.

    find first buf_fbr-doc exclusive-lock
         where recid ( buf_fbr-doc ) = p-fbr-doc-recid
    .
    find first buf_temp_fbrlib_recipe no-error.
    if not available buf_temp_fbrlib_recipe
    then do:        /* Суммы по рецептам еще не заполнены. */
        run fbrlib-fill-and-check-temp_fbrlib_recipe in this-procedure (
            input buf_fbr-doc.doc-code
        ) no-error.
        if error-status :error
        then do:
            undo, return error substitute("&1 Ошибка расчета сумм при заполнении шапки документа производства.&2&3&2&4"
                                           , vss-description
                                           , {&new-line}
                                           , error-status:get-message(1)
                                           , return-value ).
        end.
    end.
    assign
        v-in-count                  = 0
        buf_fbr-doc.in-qnty         = 0
        buf_fbr-doc.in-sale         = 0
        buf_fbr-doc.in-base         = 0
        buf_fbr-doc.in-rubl         = 0
        buf_fbr-doc.in-vat-base     = 0
        buf_fbr-doc.in-vat-rubl     = 0
        v-out-count                 = 0
        buf_fbr-doc.out-qnty        = 0
        buf_fbr-doc.out-sale        = 0
        buf_fbr-doc.out-base        = 0
        buf_fbr-doc.out-rubl        = 0
        buf_fbr-doc.out-vat-base    = 0
        buf_fbr-doc.out-vat-rubl    = 0
    .
    for each buf_temp_fbrlib_recipe
    :
        assign
            v-in-count                  = v-in-count                + buf_temp_fbrlib_recipe.count-income
            buf_fbr-doc.in-qnty         = buf_fbr-doc.in-qnty       + buf_temp_fbrlib_recipe.qnty-income
            buf_fbr-doc.in-sale         = buf_fbr-doc.in-sale       + buf_temp_fbrlib_recipe.sum-income-sale
            buf_fbr-doc.in-base         = buf_fbr-doc.in-base       + buf_temp_fbrlib_recipe.sum-income-cost-base
            buf_fbr-doc.in-rubl         = buf_fbr-doc.in-rubl       + buf_temp_fbrlib_recipe.sum-income-cost-rubl
            buf_fbr-doc.in-vat-base     = buf_fbr-doc.in-vat-base   + buf_temp_fbrlib_recipe.sum-income-vat-cost-base
            buf_fbr-doc.in-vat-rubl     = buf_fbr-doc.in-vat-rubl   + buf_temp_fbrlib_recipe.sum-income-vat-cost-rubl
            v-out-count                 = v-out-count               + buf_temp_fbrlib_recipe.count-write-off
            buf_fbr-doc.out-qnty        = buf_fbr-doc.out-qnty      + buf_temp_fbrlib_recipe.qnty-write-off
            buf_fbr-doc.out-sale        = buf_fbr-doc.out-sale      + buf_temp_fbrlib_recipe.sum-write-off-sale
            buf_fbr-doc.out-base        = buf_fbr-doc.out-base      + buf_temp_fbrlib_recipe.sum-write-off-cost-base
            buf_fbr-doc.out-rubl        = buf_fbr-doc.out-rubl      + buf_temp_fbrlib_recipe.sum-write-off-cost-rubl
            buf_fbr-doc.out-vat-base    = buf_fbr-doc.out-vat-base  + buf_temp_fbrlib_recipe.sum-write-off-vat-cost-base
            buf_fbr-doc.out-vat-rubl    = buf_fbr-doc.out-vat-rubl  + buf_temp_fbrlib_recipe.sum-write-off-vat-cost-rubl
        .
    end.
/*
    message
       "v-in-count              "  v-in-count
  skip "buf_fbr-doc.in-qnty     "  buf_fbr-doc.in-qnty
  skip "buf_fbr-doc.in-sale     "  buf_fbr-doc.in-sale
  skip "buf_fbr-doc.in-base     "  buf_fbr-doc.in-base
  skip "buf_fbr-doc.in-rubl     "  buf_fbr-doc.in-rubl
  skip "buf_fbr-doc.in-vat-base "  buf_fbr-doc.in-vat-base
  skip "buf_fbr-doc.in-vat-rubl "  buf_fbr-doc.in-vat-rubl
  skip "v-out-count             "  v-out-count
  skip "buf_fbr-doc.out-qnty    "  buf_fbr-doc.out-qnty
  skip "buf_fbr-doc.out-sale    "  buf_fbr-doc.out-sale
  skip "buf_fbr-doc.out-base    "  buf_fbr-doc.out-base
  skip "buf_fbr-doc.out-rubl    "  buf_fbr-doc.out-rubl
  skip "buf_fbr-doc.out-vat-base"  buf_fbr-doc.out-vat-base
  skip "buf_fbr-doc.out-vat-rubl"  buf_fbr-doc.out-vat-rubl
    view-as alert-box information.
    undo, return error vss-description + "".
*/
    if ( abs (buf_fbr-doc.in-rubl - buf_fbr-doc.out-rubl) <= 0.01
    and   abs (buf_fbr-doc.in-base - buf_fbr-doc.out-base) <= 0.01 )
    or p-mode <> {&fact}
    then do:
        if substring( buf_fbr-doc.PS, 1, 1 ) = "@"
        then do:
            assign
                buf_fbr-doc.PS = "@ Строк полученных товаров : "
                                + string( v-out-count, ">>>,>>9" )
                                + {&new-line} + "Строк исходных товаров : "
                                + string( v-in-count, ">>>,>>9" )
            .
        end.
    end.
    else do:
      undo, return error substitute("В док-те пр-ва &1 не совпадают суммы списанных и оприходованных товаров.&2" +
                                    "Сумма списанных товаров в &3 - &4&2" +
                                    "Сумма оприходованных товаров в &3 - &5&2" +
                                    "Сумма оприходованных товаров в &3 - &6&2" +
                                    "Сумма списанных товаров в баз.вал. - &7&2" +
                                    "Сумма оприходованных товаров в баз.вал. - &8&2"
                                    , buf_fbr-doc.doc-code
                                    , {&new-line}
                                    , "{&abbr_rublyah}"
                                    , round( buf_fbr-doc.out-rubl, 2 )
                                    , round( buf_fbr-doc.in-rubl,  2 )
                                    , round( buf_fbr-doc.in-rubl,  2 )
                                    , round( buf_fbr-doc.out-base, 2 )
                                    , round( buf_fbr-doc.in-base,  2 )).
    end.
end.
end procedure. /* fbrlib-fill-sum-fbr-doc */

/*==========================================================================*/
procedure fbrlib-calc-prices :
do
on error undo, return error
:
define input parameter p-fbr-line-recid as recid        no-undo.
define input parameter p-price-obj-type as character    no-undo.
define input parameter p-price-obj-code as integer      no-undo.
define output parameter p-current-price as decimal      no-undo.

    define variable v-void          as decimal       no-undo.
    define variable v-void-char     as character     no-undo.
    define variable v-gds-code      as integer       no-undo.
    define variable v-b-code        as integer       no-undo.
/*    define variable cur-rt like price-list.road-tax   no-undo.*/
/*    define variable cur-ex like price-list.excise     no-undo.*/
/*    define variable cur-dn like price-list.doc-num    no-undo.*/

    define buffer buf_fbr-doc   for ub.fbr-doc.
    define buffer buf_fbr-line  for ub.fbr-line.
    define buffer buf_gds-prt   for ub.gds-prt.
    define buffer buf_bar-code  for ub.bar-code.

    find first buf_fbr-line no-lock
        where recid( buf_fbr-line ) = p-fbr-line-recid
    .
    { gbl/gds-code.i
        buf_fbr-line.artic
        buf_fbr-line.prod-type
        buf_fbr-line.prod-code
        v-gds-code
    no-error }
    if error-status :error
    then do:
      undo, return error substitute("&1 &2 &3&4Ошибка определения кода товара (артикул &7).&4&5&4&6"
                                      ,vss-workfile
                                      ,vss-revision
                                      ,vss-description
                                      ,{&new-line}
                                      , error-status:get-message(1)
                                      , return-value
                                      , buf_fbr-line.artic
                                      ).
    end.
    { gbl/gdsbcode.i
        v-gds-code
        ?
        v-b-code
    no-error }
    if error-status :error
    then do:
      undo, return error substitute("&1 &2 &3&4Ошибка определения основного бар-кода товара (код товара) &7.&4&5&4&6"
                                      ,vss-workfile
                                      ,vss-revision
                                      ,vss-description
                                      ,{&new-line}
                                      , error-status:get-message(1)
                                      , return-value
                                      , v-gds-code
                                      ).
    end.
    if buf_fbr-line.is-calc = no
    then do:        /* в строке цена из прайс-листа */
        { gbl/bcodeprc.i
            p-price-obj-type
            p-price-obj-code
            v-b-code
            0
            0
            v-void-char
            p-current-price
            v-void
            v-void
            no-error
        }
        if error-status :error
        then do:
          undo, return error substitute("&1 &2 &3&4Ошибка определения продажной цены основного бар-кода товара (код товара) &7.&4&5&4&6"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,{&new-line}
                                          , error-status:get-message(1)
                                          , return-value
                                          , v-gds-code
                                          ).

        end.
    end.        /* if buf_fbr-line.is-calc = no */
    else do:
        assign
            p-current-price = buf_fbr-line.price-sale
        .
    end.
end.
end procedure. /* fbrlib-calc-prices */


/*==========================================================================*/
procedure fbrlib-put-in-order-recipe :
do
on error undo, return error
:
define input parameter p-fbr-doc-doc-code   as character    no-undo.

    define variable v-recipe-counter    as integer          no-undo.
    define variable v-recipe-amount     as integer init 0   no-undo.
    define variable v-child-counter     as integer          no-undo.
    define variable v-is-call-cycle     as logical          no-undo.

    define variable v-str as character     no-undo.

    define buffer buf_in_fbr-line       for ub.fbr-line.
    define buffer buf_dress_fbr-line    for ub.fbr-line.
    define buffer buf_fbr-line          for ub.fbr-line.
    define buffer buf_recipe-gds        for ub.recipe-gds.
    define buffer buf_recipe            for ub.recipe.

    for each temp_recipe-childs-qnty
    :
        delete temp_recipe-childs-qnty.
    end.
    for each temp_recipe-childs
    :
        delete temp_recipe-childs.
    end.
    for each temp_recipe-order
    :
        delete temp_recipe-order.
    end.

    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = p-fbr-doc-doc-code
    on error undo, return error
    :
        find first temp_recipe-childs-qnty
             where temp_recipe-childs-qnty.recipe-code = buf_fbr-line.recipe-code
        no-error.
        if not available temp_recipe-childs-qnty
        then do:
            create temp_recipe-childs-qnty.
            assign
                v-recipe-amount                     = v-recipe-amount + 1
                temp_recipe-childs-qnty.recipe-code = buf_fbr-line.recipe-code
                temp_recipe-childs-qnty.order       = v-recipe-amount
                temp_recipe-childs-qnty.childs-qnty = 0
                v-child-counter                     = 0
            .
        end.
    end.

    for each buf_in_fbr-line no-lock
       where buf_in_fbr-line.doc-code = p-fbr-doc-doc-code
         and buf_in_fbr-line.trn-type = {&write-off}
    on error undo, return error
    :
        for each buf_dress_fbr-line no-lock
           where buf_dress_fbr-line.doc-code    = p-fbr-doc-doc-code
             and buf_dress_fbr-line.trn-type    = {&income}
             and buf_dress_fbr-line.artic       = buf_in_fbr-line.artic
             and buf_dress_fbr-line.prod-type   = buf_in_fbr-line.prod-type
             and buf_dress_fbr-line.prod-code   = buf_in_fbr-line.prod-code
        on error undo, return error
        :
            find first buf_recipe no-lock
                 where buf_recipe.recipe-code = buf_dress_fbr-line.recipe-code
            .
            /* if buf_recipe.recipe-type = {&dressing} */
            if buf_in_fbr-line.is-comp = yes
            then do:
                find last temp_recipe-childs-qnty
                    where temp_recipe-childs-qnty.recipe-code = buf_in_fbr-line.recipe-code
                .
                assign
                    temp_recipe-childs-qnty.childs-qnty = temp_recipe-childs-qnty.childs-qnty + 1
                .
                create temp_recipe-childs.
                assign
                    temp_recipe-childs.recipe-code          = buf_in_fbr-line.recipe-code
                    temp_recipe-childs.child-code           = temp_recipe-childs-qnty.childs-qnty
                    temp_recipe-childs.child-recipe-code    = buf_dress_fbr-line.recipe-code
                .
            end.
            else do:
                /* Все кроме разделки и разукомплектации будет обработано отдельно */
            end.
        end.        /* for each buf_dress_fbr-line  */
    end.        /* for each buf_in_fbr-line для разделки */
    for each buf_in_fbr-line no-lock
       where buf_in_fbr-line.doc-code = p-fbr-doc-doc-code
         and buf_in_fbr-line.trn-type = {&income}
    on error undo, return error
    :
        find first buf_recipe no-lock
             where buf_recipe.recipe-code = buf_in_fbr-line.recipe-code
        no-error.
        /* if buf_recipe.recipe-type = {&dressing} */
        if buf_in_fbr-line.is-comp = no
        then do:
            /* Разделка и разукомплектация обработана отдельно */
        end.
        else do:
            for each buf_recipe-gds no-lock
            where buf_recipe-gds.recipe-code = buf_in_fbr-line.recipe-code
            :
                for each buf_fbr-line no-lock
                where buf_fbr-line.doc-code    = p-fbr-doc-doc-code
                    and buf_fbr-line.trn-type    = {&income}
                    and buf_fbr-line.artic       = buf_recipe-gds.artic
                    and buf_fbr-line.prod-type   = buf_recipe-gds.prod-type
                    and buf_fbr-line.prod-code   = buf_recipe-gds.prod-code
                on error undo, return error
                :
                    find first buf_recipe no-lock
                         where buf_recipe.recipe-code = buf_fbr-line.recipe-code
                    .
                    if buf_recipe.recipe-type = {&dressing}
                    then do:
                        /* Разделка обработана отдельно */
                    end.
                    else do:
                        find last temp_recipe-childs-qnty
                            where temp_recipe-childs-qnty.recipe-code = buf_in_fbr-line.recipe-code
                        .
                        assign
                            temp_recipe-childs-qnty.childs-qnty = temp_recipe-childs-qnty.childs-qnty + 1
                        .
                        create temp_recipe-childs.
                        assign
                            temp_recipe-childs.recipe-code          = buf_in_fbr-line.recipe-code
                            temp_recipe-childs.child-code           = temp_recipe-childs-qnty.childs-qnty
                            temp_recipe-childs.child-recipe-code    = buf_fbr-line.recipe-code
                        .
                    end.
                end.
            end.        /* for each buf_recipe-gds */
        end.
    end.        /* for each buf_in_fbr-line для всего кроме разделки */
/*    run fbrlib-check-temp-tables in this-procedure no-error.*/
    for each temp_recipe-order
    on error undo, return error
    :
        delete temp_recipe-order.
    end.
    assign
        v-fbrlib-recipe-order = 0
    .
    do v-recipe-counter = 1 to v-recipe-amount
    on error undo, return error
    :
        run fbrlib-add-recipe-in-tmp-order in this-procedure (
              input v-recipe-counter
            , input 0
            , output v-is-call-cycle
        ).
        if v-is-call-cycle = yes
        then do:
            message
                    "Достигнут максимальный уровень вложенности рецептов."
                skip(1)
                skip "Невозможно упорядочить рецепты."
                skip(1)
                skip "Необходимо изменить структуру рецептов,"
                skip "используемых при формировании"
                skip "данного документа производства."
            view-as alert-box error
            title "Невозможно рассчитать документ производства".
            for each temp_recipe-childs-qnty
            :
                delete temp_recipe-childs-qnty.
            end.
            for each temp_recipe-childs
            :
                delete temp_recipe-childs.
            end.
            for each temp_recipe-order
            :
                delete temp_recipe-order.
            end.
            for each temp_recipe-order
            on error undo, return error
            :
                delete temp_recipe-order.
            end.
            for each temp_fbrlib_recipe
            on error undo, return error
            :
                delete temp_recipe-order.
            end.
            undo, return error.
        end.
    end.
/*    run writelog in this-procedure ("fbr.log", 0, "Упорядочение рецептов.").*/
/*    run fbrlib-check-temp-tables in this-procedure ( input "Упорядочение рецептов." ) no-error.*/
end.
end procedure. /* fbrlib-put-in-order-recipe */

/*==========================================================================*/
procedure fbrlib-add-recipe-in-tmp-order :
do
on error undo, return error
:
define input parameter p-order              as integer      no-undo.
define input parameter p-call-counter       as integer      no-undo.
define output parameter p-is-call-cycle     as logical      no-undo.

    define variable v-nodes-counter     as integer       no-undo.

    define buffer buf_c_temp_recipe-childs-qnty for temp_recipe-childs-qnty.
    define buffer buf_temp_recipe-childs-qnty   for temp_recipe-childs-qnty.
    define buffer buf_temp_recipe-childs        for temp_recipe-childs     .
    define buffer buf_temp_recipe-order         for temp_recipe-order.

    assign
        p-call-counter = p-call-counter + 1
    .
    if p-call-counter > {&fbrlib-max-calls-in-recursion}
    then do:
        assign
            p-is-call-cycle = yes
        .
    end.        /* p-call-counter > {&fbrlib-max-calls-in-recursion} */
    else do:
        find first buf_temp_recipe-childs-qnty
             where buf_temp_recipe-childs-qnty.order = p-order
        .
        find first buf_temp_recipe-order
             where buf_temp_recipe-order.recipe-code = buf_temp_recipe-childs-qnty.recipe-code
        no-error.
        if not available buf_temp_recipe-order
        then do:
            do v-nodes-counter = 1 to buf_temp_recipe-childs-qnty.childs-qnty
            :
                find first buf_temp_recipe-childs
                     where buf_temp_recipe-childs.recipe-code = buf_temp_recipe-childs-qnty.recipe-code
                       and buf_temp_recipe-childs.child-code  = v-nodes-counter
                .
                find first buf_c_temp_recipe-childs-qnty
                     where buf_c_temp_recipe-childs-qnty.recipe-code = buf_temp_recipe-childs.child-recipe-code
                .
                run fbrlib-add-recipe-in-tmp-order in this-procedure (
                      input buf_c_temp_recipe-childs-qnty.order
                    , input p-call-counter
                    , output p-is-call-cycle
                ).
                if p-is-call-cycle = yes
                then do:
                    return.
                end.
            end.        /* do по всем потомкам текущего рецепта - рекурсия */
            assign
                v-fbrlib-recipe-order = v-fbrlib-recipe-order + 1
            .
            create buf_temp_recipe-order.
            assign
                buf_temp_recipe-order.recipe-code   = buf_temp_recipe-childs-qnty.recipe-code
                buf_temp_recipe-order.order         = v-fbrlib-recipe-order
            .
        end.        /* if not available temp_recipe-order */
    end.        /* NOT ( p-call-counter > {&fbrlib-max-calls-in-recursion} ) */
end.
end procedure. /* fbrlib-add-recipe-in-tmp-order */

/*==========================================================================*/
procedure fbrlib-get-trn-type :
define input parameter p-recipe-code    as character    no-undo.
define input parameter p-goods-recid    as recid        no-undo.
define input parameter p-is-integration as logical      no-undo.    /* Для рецепта комплектации: yes-комплектация. */
define output parameter p-is-comp       as logical      no-undo.
define output parameter p-trn-type      as character    no-undo.

define buffer buf_recipe    for ub.recipe.
define buffer buf_goods     for ub.goods.

do
for buf_recipe
  , buf_goods
on error undo, return error
:
    find first buf_goods no-lock
         where recid( buf_goods ) = p-goods-recid
    .
    find first buf_recipe no-lock
         where buf_recipe.recipe-code = p-recipe-code
    no-error.
    if not available buf_recipe
    then do:        /* Ингредиент есть, а рецепта нет */
        assign
            p-is-comp = no
            p-trn-type = "":U
        .
        undo, return.
    end.
    if  buf_recipe.artic        = buf_goods.artic
    and buf_recipe.prod-type    = buf_goods.prod-type
    and buf_recipe.prod-code    = buf_goods.prod-code
    then do:
        assign
            p-is-comp = yes
        .
    end.
    else do:
        assign
            p-is-comp = no
        .
    end.
    case buf_recipe.recipe-type
    :
        when {&manufacturing}
        then do:
            if p-is-comp = yes
            then do:
                assign
                    p-trn-type = {&income}
                .
            end.
            else do:
                assign
                    p-trn-type = {&write-off}
                .
            end.
        end.
        when {&alternative}
        then do:
            if p-is-comp = yes
            then do:
                assign
                    p-trn-type = {&income}
                .
            end.
            else do:
                assign
                    p-trn-type = {&write-off}
                .
            end.
        end.
        when {&dressing}
        then do:
            if p-is-comp = no
            then do:
                assign
                    p-trn-type = {&income}
                .
            end.
            else do:
                assign
                    p-trn-type = {&write-off}
                .
            end.
        end.
        when {&gathering}
        then do:
            if p-is-integration = ?
            then do:
                message
                    "Выберите тип операции по рецепту комплектации:"
                    skip (2) "YES - комплектация"
                    skip     "NO - разукомплектация"
                view-as alert-box question
                buttons YES-NO
                update p-is-integration.
            end.
            if p-is-integration = yes
            then do:
                if p-is-comp = yes
                then do:
                    assign
                        p-trn-type = {&income}
                    .
                end.
                else do:
                    assign
                        p-trn-type = {&write-off}
                    .
                end.
            end.
            else do:
                if p-is-comp = yes
                then do:
                    assign
                        p-trn-type = {&write-off}
                    .
                end.
                else do:
                    assign
                        p-trn-type = {&income}
                    .
                end.
            end.
        end.
    end case.
end.
end procedure. /* fbrlib-get-trn-type */

procedure fbrlib-get-mark :
define input parameter p-recipe-code    as character    no-undo.
define output parameter p-mark          as logical    no-undo.

define buffer buf_goods-attr     for ub.goods-attr.
define buffer buf_recipe-gds for ub.recipe-gds .

    for each buf_recipe-gds no-lock where buf_recipe-gds.recipe-code = p-recipe-code,
         first buf_goods-attr no-lock where buf_goods-attr.gds-code = buf_recipe-gds.gds-code and
                                            buf_goods-attr.attr-code = {&attr-mark-type}:
         if buf_goods-attr.attr-value <> "" and buf_goods-attr.attr-value <> "not-type" then do:
            p-mark = true .
            return .
         end.                                                  
    end.   


end procedure. /* fbrlib-get-mark */
/*==========================================================================*/
procedure fbrlib-check-temp-tables :
do
on error undo, return error
:
define input parameter p-title  as character    no-undo.

    define variable v-str               as character        no-undo.

    assign
        v-str = v-str + {&new-line} + "temp_recipe-childs-qnty:" + {&new-line}
    .
    for each temp_recipe-childs-qnty
    on error undo, return error
    :
        assign
            v-str   = v-str + string( temp_recipe-childs-qnty.recipe-code )
                    + "   " + string( temp_recipe-childs-qnty.childs-qnty )
                    + "   " + string( temp_recipe-childs-qnty.order )
                    + {&new-line}
        .
    end.
    assign
        v-str = v-str + "temp_recipe-childs:" + {&new-line}
    .
    for each temp_recipe-childs
    on error undo, return error
    :
        assign
            v-str   = v-str + string( temp_recipe-childs.recipe-code )
                    + "   " + string( temp_recipe-childs.child-code )
                    + "   " + string( temp_recipe-childs.child-recipe-code )
                    + {&new-line}
        .
    end.
    assign
        v-str = v-str + {&new-line} + "temp_recipe-order:" + {&new-line}
    .
    for each temp_recipe-order
    on error undo, return error
    :
        assign
            v-str   = v-str + string( temp_recipe-order.recipe-code )
                    + "   " + string( temp_recipe-order.order )
                    + {&new-line}
        .
    end.
    assign
        v-str = v-str + {&new-line} + "temp_fbrlib_recipe:" + {&new-line}
    .
    run writelog in this-procedure ( input "fbr.log", input 0, input p-title ).
    run writelog in this-procedure ( input "fbr.log", input 0, input v-str ).
    for each temp_fbrlib_recipe
    on error undo, return error
    :
        assign
            v-str   = "recipe-code: "                   + string( temp_fbrlib_recipe.recipe-code                 )
                    + "   " + "count-income: "                  + string( temp_fbrlib_recipe.count-income                )
                    + "   " + "qnty-income: "                   + string( temp_fbrlib_recipe.qnty-income                 )
                    + "   " + "sum-income-sale: "               + string( temp_fbrlib_recipe.sum-income-sale             )
                    + "   " + "sum-income-cost-base: "          + string( temp_fbrlib_recipe.sum-income-cost-base        )
                    + "   " + "sum-income-cost-rubl: "          + string( temp_fbrlib_recipe.sum-income-cost-rubl        )
                    + "   " + "sum-income-vat-cost-base: "      + string( temp_fbrlib_recipe.sum-income-vat-cost-base    )
                    + "   " + "sum-income-vat-cost-rubl: "      + string( temp_fbrlib_recipe.sum-income-vat-cost-rubl    )
                    + "   " + "count-write-off: "               + string( temp_fbrlib_recipe.count-write-off             )
                    + "   " + "qnty-write-off: "                + string( temp_fbrlib_recipe.qnty-write-off              )
                    + "   " + "sum-write-off-sale: "            + string( temp_fbrlib_recipe.sum-write-off-sale          )
                    + "   " + "sum-write-off-cost-base: "       + string( temp_fbrlib_recipe.sum-write-off-cost-base     )
                    + "   " + "sum-write-off-cost-rubl: "       + string( temp_fbrlib_recipe.sum-write-off-cost-rubl     )
                    + "   " + "sum-write-off-vat-cost-base: "   + string( temp_fbrlib_recipe.sum-write-off-vat-cost-base )
                    + "   " + "sum-write-off-vat-cost-rubl: "   + string( temp_fbrlib_recipe.sum-write-off-vat-cost-rubl )
                    + {&new-line}
        .
        run writelog in this-procedure ( input "fbr.log", input 0, input v-str ).
    end.

end.
end procedure. /* fbrlib-check-temp-tables */


procedure fbrlib-s-coeff-value :
define input  parameter p-gds-code    as integer        no-undo.
define input  parameter p-date        as date           no-undo.
define input  parameter p-obj-type    as character      no-undo.
define input  parameter p-obj-code    as integer        no-undo.
define output parameter p-coeff-value as decimal        no-undo.

define variable vss-description as character init "fbrlib-s-coeff-value-01: определяет значение сезонного коэффициента" no-undo.

    define variable v-date          as date         no-undo.
    define variable v-host-code     as integer      no-undo.

    define buffer buf_goods       for ub.goods.
    define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.
    define buffer buf_clients     for ub.clients.
    define buffer buf_s-coeff     for ub.s-coeff.
do
for buf_goods
  , buf_fbr-gds-obj
  , buf_clients
  , buf_s-coeff
on error undo, return error return-value
:
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    no-error .
    if not available buf_goods
    then do:
       undo, return error substitute("Ошибка при определении сезонного коэффициента - не найден товар с кодом &1", p-gds-code).
    end.
    find first buf_clients no-lock
         where buf_clients.obj-type = p-obj-type
           and buf_clients.obj-code = p-obj-code
    no-error.
    if not available buf_clients
    then do:
       undo, return error substitute("Ошибка при определении сезонного коэффициента - не найден объект &1&2", p-obj-type, p-obj-code).
    end.
    assign
        v-date = date(month(p-date), day(p-date), Year({&s-coeff-start-date}))
    .
    find first buf_fbr-gds-obj no-lock
         where buf_fbr-gds-obj.gds-code = p-gds-code
           and buf_fbr-gds-obj.obj-type = p-obj-type
           and buf_fbr-gds-obj.obj-code = p-obj-code
    no-error.
    if not available buf_fbr-gds-obj
    or buf_fbr-gds-obj.is-season = no
    then do:
        assign
            p-coeff-value = 0
        .
        return.
    end.
    { gbl/hostcode.i
        p-obj-type
        p-obj-code
        v-host-code
    }
    find last buf_s-coeff no-lock
        where buf_s-coeff.gds-code = p-gds-code
          and buf_s-coeff.host-code = v-host-code
          and buf_s-coeff.obj-type = p-obj-type
          and buf_s-coeff.obj-code = p-obj-code
          and buf_s-coeff.s-date <= v-date
    no-error.
    if available buf_s-coeff
    then do:
        assign
            p-coeff-value = buf_s-coeff.coeff-value
        .
        return.
    end.
    find last buf_s-coeff no-lock
        where buf_s-coeff.gds-code = p-gds-code
          and buf_s-coeff.host-code = v-host-code
          and buf_s-coeff.obj-type = "":U
          and buf_s-coeff.obj-code = 0
          and buf_s-coeff.s-date <= v-date
    no-error.
    if available buf_s-coeff
    then do:
        assign
            p-coeff-value = buf_s-coeff.coeff-value
        .
        return.
    end.
    find last buf_s-coeff no-lock
        where buf_s-coeff.gds-code = p-gds-code
          and buf_s-coeff.host-code = 0
          and buf_s-coeff.obj-type = "":U
          and buf_s-coeff.obj-code = 0
          and buf_s-coeff.s-date <= v-date
    no-error.
    if available buf_s-coeff
    then do:
        assign
            p-coeff-value = buf_s-coeff.coeff-value
        .
    end.
    else do:
        assign
            p-coeff-value = 0
        .
    end.
end.

end procedure. /* fbrlib-s-coeff-value */


/*Создание записи fbr-recipe-gds*/
procedure fbrlib_create-fbr-recipe-gds :
define input parameter p-doc-code         as character      no-undo.
define input parameter p-recipe-code      as character      no-undo.
define input parameter p-prod-type        as character      no-undo.
define input parameter p-prod-code        as integer        no-undo.
define input parameter p-artic            as character      no-undo.
define input parameter p-gds-code         as integer        no-undo.
define input parameter p-is-waste         as logical        no-undo.
define input parameter p-proc-number      as integer        no-undo.
define input parameter p-obj-date         as date           no-undo.
define input parameter p-obj-type         as character      no-undo.
define input parameter p-obj-code         as integer        no-undo.
define input parameter p-calc-method      as decimal        no-undo.
define input parameter p-coeff-waste      as decimal        no-undo.
define input parameter p-orig-qnty        as decimal        no-undo.
define input parameter p-orig-brutto-qnty as decimal        no-undo.

    define variable v-coeff-season  as decimal      no-undo.
    define variable v-void-decimal  as decimal      no-undo.
    define variable v-void-integer  as integer      no-undo.
    define variable v-recipe-type   as character    no-undo.

    define buffer buf_fbr-recipe-gds    for ub.fbr-recipe-gds.
    define buffer buf_goods             for ub.goods.
    define buffer buf_recipe            for ub.recipe.
do
for buf_fbr-recipe-gds
  , buf_recipe
  , buf_goods
on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
    find first buf_fbr-recipe-gds exclusive-lock
         where buf_fbr-recipe-gds.doc-code    = p-doc-code
           and buf_fbr-recipe-gds.recipe-code = p-recipe-code
           and buf_fbr-recipe-gds.prod-type   = p-prod-type
           and buf_fbr-recipe-gds.prod-code   = p-prod-code
           and buf_fbr-recipe-gds.artic       = p-artic
    no-error.
    if not available buf_fbr-recipe-gds
    then do:
        create buf_fbr-recipe-gds.
        assign
            buf_fbr-recipe-gds.doc-code           = p-doc-code
            buf_fbr-recipe-gds.recipe-code        = p-recipe-code
            buf_fbr-recipe-gds.prod-type          = p-prod-type
            buf_fbr-recipe-gds.prod-code          = p-prod-code
            buf_fbr-recipe-gds.artic              = p-artic
            buf_fbr-recipe-gds.gds-code           = p-gds-code
            buf_fbr-recipe-gds.is-waste           = p-is-waste
            buf_fbr-recipe-gds.proc-number        = p-proc-number
            buf_fbr-recipe-gds.recipe-qnty        = p-orig-qnty
            buf_fbr-recipe-gds.recipe-brutto-qnty = p-orig-brutto-qnty
        .
        /*---START--------- вычислить новое брутто с учетом сезонного коэффициента ---------------------*/
        find first buf_goods no-lock
             where buf_goods.prod-type = buf_fbr-recipe-gds.prod-type
               and buf_goods.prod-code = buf_fbr-recipe-gds.prod-code
               and buf_goods.artic     = buf_fbr-recipe-gds.artic
        .
        run fbrlib-s-coeff-value in this-procedure (
              input buf_goods.gds-code
            , input p-obj-date
            , input p-obj-type
            , input p-obj-code
            , output v-coeff-season
        ) no-error.
        if error-status:error
        then do:
            return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
        end.
        assign
            buf_fbr-recipe-gds.qnty         = p-orig-qnty
            buf_fbr-recipe-gds.coeff-value  = v-coeff-season
            buf_fbr-recipe-gds.coeff-waste  = p-coeff-waste
        .
        run fbrlib-get-recipe-type in this-procedure (
              input buf_fbr-recipe-gds.doc-code
            , input buf_fbr-recipe-gds.recipe-code
            , output v-recipe-type
        ).
        if v-recipe-type <> {&manufacturing}
        then do:
            assign
                buf_fbr-recipe-gds.coeff-value  = 0
                buf_fbr-recipe-gds.coeff-waste  = 0
                buf_fbr-recipe-gds.calc-method  = 1
                buf_fbr-recipe-gds.brutto-qnty  = buf_fbr-recipe-gds.qnty
            .
        end.        /* if buf_recipe.recipe-type <> {&manufacturing} */
        else do:
            run fbrlib-calc-brutto in this-procedure (
                  input v-recipe-type
                , input buf_fbr-recipe-gds.qnty
                , input buf_fbr-recipe-gds.coeff-value
                , input buf_fbr-recipe-gds.coeff-waste
                , input 0
                , input 3
                , output v-void-decimal
                , output v-void-decimal
                , output buf_fbr-recipe-gds.brutto-qnty
                , output v-void-integer
            ).
            assign
                buf_fbr-recipe-gds.calc-method  = p-calc-method
            .
            run fbrlib-calc-brutto in this-procedure (
                  input v-recipe-type
                , input buf_fbr-recipe-gds.qnty
                , input buf_fbr-recipe-gds.coeff-value
                , input buf_fbr-recipe-gds.coeff-waste
                , input buf_fbr-recipe-gds.brutto-qnty
                , input buf_fbr-recipe-gds.calc-method
                , output buf_fbr-recipe-gds.qnty
                , output v-void-decimal
                , output v-void-decimal
                , output v-void-integer
            ).
        end.        /* NOT ( if buf_recipe.recipe-type <> {&manufacturing} ) */
        /*---END----------- вычислить новое брутто с учетом сезонного коэффициента ---------------------*/
        /*---START--------- Пересчитать нетто (метод=1) ---------------------*/
        /*---END----------- Пересчитать нетто (метод=1) ---------------------*/
    end.
end.
end procedure. /*fbrlib_create-fbr-recipe-gds*/

/*==========================================================================*/
procedure fbrlib-set-default-recipe :
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-gds-code   as integer      no-undo.

    define variable v-artic             as character    no-undo.
    define variable v-prod-type         as character    no-undo.
    define variable v-prod-code         as character    no-undo.
    define variable v-recipe-code       as character    no-undo.
    define variable v-fbr-gds-obj-recid as recid        no-undo.
    define variable v-recipe-found      as logical      no-undo.

    define buffer buf_recipe        for ub.recipe.
    define buffer buf_other_recipe  for ub.recipe.
    define buffer buf_goods         for ub.goods.
    define buffer buf_fbr-gds-obj   for ub.fbr-gds-obj.
do
for buf_recipe
  , buf_goods
  , buf_fbr-gds-obj
on error undo, return error
:
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    run fbrlib-get-obj-recipe in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-gds-code
        , output v-recipe-code
    ).
    if v-recipe-code <> ""
    then do:
        find first buf_recipe no-lock
            where buf_recipe.recipe-code = v-recipe-code
        no-error.
        if not available buf_recipe
        then do:
            assign
                v-recipe-code = ""
            .
        end.
    end.
    if v-recipe-code = ""
    then do:        /* не назначен рецепт по умолчанию */
        find first buf_fbr-gds-obj exclusive-lock
             where buf_fbr-gds-obj.obj-type = p-obj-type
               and buf_fbr-gds-obj.obj-code = p-obj-code
               and buf_fbr-gds-obj.gds-code = p-gds-code
        no-error.
        if not available buf_fbr-gds-obj
        then do:
            run ref/fgdsobj1.p (
                  input-output v-fbr-gds-obj-recid
                , input {&add-def}
                , input no
                , input p-gds-code
                , input p-obj-type
                , input p-obj-code
                , input 0
                , input ""                                        /* Тип объекта кухни */
                , input 0                                         /* Код объекта кухни */
                , input no                                        /* Отправлять на кассу ресторана */
                , input no                                        /* Является блюдом   */
                , input no                                        /* Модификатор блюда */
                , input no                                        /* Без цены */
                , input no                                        /* Применять сезонный коэффициент */
                , input no                                        /* Является полуфабрикатом */
            ) no-error.
            if error-status:error
            then do:
                message
                        vss-workfile vss-revision vss-description
                    skip "Ошибка изменения атрибутов товара на объекте"
                    skip return-value
                    skip trim(error-status :get-message(1))
                            trim(error-status :get-message(2))
                            trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
            find first buf_fbr-gds-obj exclusive-lock
                 where recid( buf_fbr-gds-obj ) = v-fbr-gds-obj-recid
            .
        end.        /* if not available buf_fbr-gds-obj */
        assign
            v-recipe-found = no
        .
        for first buf_recipe no-lock
            where buf_recipe.obj-type    = p-obj-type
              and buf_recipe.obj-code    = p-obj-code
              and buf_recipe.artic       = buf_goods.artic
              and buf_recipe.prod-type   = buf_goods.prod-type
              and buf_recipe.prod-code   = buf_goods.prod-code
              and buf_recipe.recipe-type = {&manufacturing}
              or (
                  buf_recipe.obj-type    = ""
              and buf_recipe.obj-code    = 0
              and buf_recipe.artic       = buf_goods.artic
              and buf_recipe.prod-type   = buf_goods.prod-type
              and buf_recipe.prod-code   = buf_goods.prod-code
              and buf_recipe.recipe-type = {&manufacturing}
                  )
        :
            assign
                v-recipe-found = yes
                buf_fbr-gds-obj.default-recipe-code = buf_recipe.recipe-code
            .
        end.
        if v-recipe-found = no
        then do:        /* Не найден рецепт производства */
            for first buf_recipe no-lock
                where buf_recipe.obj-type    = p-obj-type
                  and buf_recipe.obj-code    = p-obj-code
                  and buf_recipe.artic       = buf_goods.artic
                  and buf_recipe.prod-type   = buf_goods.prod-type
                  and buf_recipe.prod-code   = buf_goods.prod-code
                  and buf_recipe.recipe-type <> {&alternative}
                  or (
                      buf_recipe.obj-type    = ""
                  and buf_recipe.obj-code    = 0
                  and buf_recipe.artic       = buf_goods.artic
                  and buf_recipe.prod-type   = buf_goods.prod-type
                  and buf_recipe.prod-code   = buf_goods.prod-code
                  and buf_recipe.recipe-type <> {&alternative}
                      )
            :
                assign
                    v-recipe-found = yes
                    buf_fbr-gds-obj.default-recipe-code = buf_recipe.recipe-code
                .
            end.
            if v-recipe-found = no
            then do:        /* Есть только рецепты альтернативы или вообще нет рецептов */
                for first buf_recipe no-lock
                    where buf_recipe.obj-type    = p-obj-type
                      and buf_recipe.obj-code    = p-obj-code
                      and buf_recipe.artic       = buf_goods.artic
                      and buf_recipe.prod-type   = buf_goods.prod-type
                      and buf_recipe.prod-code   = buf_goods.prod-code
                      or (
                          buf_recipe.obj-type    = ""
                      and buf_recipe.obj-code    = 0
                      and buf_recipe.artic       = buf_goods.artic
                      and buf_recipe.prod-type   = buf_goods.prod-type
                      and buf_recipe.prod-code   = buf_goods.prod-code
                          )
                :
                    assign
                        v-recipe-found = yes
                        buf_fbr-gds-obj.default-recipe-code = buf_recipe.recipe-code
                    .
                end.
                if v-recipe-found = no
                then do:
                    assign
                        buf_fbr-gds-obj.default-recipe-code = ""
                    .
                end.
            end.
        end.
    end.        /* if v-recipe-code = "" */
end.
end procedure. /* fbrlib-set-default-recipe */


/*==========================================================================
Процедура получения рецепта по умолчанию для заданного объекта.
Если рецепт по умолчанию не задан, возвращается ""

*/
procedure fbrlib-get-obj-recipe :
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-gds-code       as integer      no-undo.
define output parameter p-recipe-code   as character    no-undo.

    define buffer buf_fbr-gds-obj   for ub.fbr-gds-obj.
do
for buf_fbr-gds-obj
on error undo, return error
:
    find first buf_fbr-gds-obj no-lock
         where buf_fbr-gds-obj.obj-type = p-obj-type
           and buf_fbr-gds-obj.obj-code = p-obj-code
           and buf_fbr-gds-obj.gds-code = p-gds-code
    no-error.
    if available buf_fbr-gds-obj
    then do:
        assign
            p-recipe-code = buf_fbr-gds-obj.default-recipe-code
        .
    end.
    else do:
        assign
            p-recipe-code = ""
        .
    end.
end.
end procedure. /* fbrlib-get-obj-recipe */


/*==========================================================================*/
procedure fbrlib-create-or-update-recipe-gds :
define input parameter p-recipe-code    as character        no-undo.
define input parameter p-gds-code       as integer          no-undo.
define input parameter p-is-waste       as logical          no-undo.
define input parameter p-qnty           as decimal          no-undo.
define input parameter p-proc-number    as integer          no-undo.
define input parameter p-nws-self       as logical          no-undo.

    define variable v-max-proc-num  as integer      no-undo.
    define variable v-recipe-type   as character    no-undo.

    define buffer buf_goods             for ub.goods.
    define buffer buf_recipe-gds        for ub.recipe-gds.
    define buffer buf_recipe            for ub.recipe.
    define buffer buf_proc_recipe-gds   for ub.recipe-gds.
do
for buf_goods
  , buf_recipe-gds
  , buf_recipe
  , buf_proc_recipe-gds
on error undo, return error
:
    find first buf_recipe no-lock
         where buf_recipe.recipe-code = p-recipe-code
    .
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    find first buf_recipe-gds
         where buf_recipe-gds.recipe-code = p-recipe-code
           and buf_recipe-gds.prod-type   = buf_goods.prod-type
           and buf_recipe-gds.prod-code   = buf_goods.prod-code
           and buf_recipe-gds.artic       = buf_goods.artic
    no-error.
    if not available buf_recipe-gds
    then do:
        create buf_recipe-gds.
        assign
            buf_recipe-gds.recipe-code = p-recipe-code
            buf_recipe-gds.gds-code    = p-gds-code
            buf_recipe-gds.prod-type   = buf_goods.prod-type
            buf_recipe-gds.prod-code   = buf_goods.prod-code
            buf_recipe-gds.artic       = buf_goods.artic
        .
        assign
            buf_recipe-gds.is-waste    = no
            buf_recipe-gds.qnty        = 0
            buf_recipe-gds.coeff-waste = 0
            buf_recipe-gds.brutto-qnty = 0
            buf_recipe-gds.proc-number = 0
            buf_recipe-gds.nws-self    = no
        .
    end.
    assign
        buf_recipe-gds.is-waste    = p-is-waste
    .
    run fbrlib-get-recipe-type in this-procedure (
          input "":U
        , input buf_recipe-gds.recipe-code
        , output v-recipe-type
    ).
    if v-recipe-type <> {&manufacturing}
    then do:
        assign
            buf_recipe-gds.calc-method = 1
            buf_recipe-gds.qnty        = p-qnty
            buf_recipe-gds.brutto-qnty = p-qnty
            buf_recipe-gds.coeff-waste = 0
        .
    end.        /* if buf_recipe.recipe-type <> {&manufacturing} */
    else do:
        assign
            buf_recipe-gds.calc-method = 1
            buf_recipe-gds.brutto-qnty = p-qnty
        .
        run fbrlib-calc-brutto in this-procedure (
              input v-recipe-type
            , input 0
            , input 0
            , input buf_recipe-gds.coeff-waste
            , input buf_recipe-gds.brutto-qnty
            , input 1
            , output buf_recipe-gds.qnty
            , output buf_recipe-gds.coeff-waste       /* v-void-decimal */
            , output buf_recipe-gds.brutto-qnty       /* v-void-decimal */
            , output buf_recipe-gds.calc-method       /* v-void-integer */
        ).
    end.        /* NOT ( if buf_recipe.recipe-type <> {&manufacturing} ) */
    assign
        buf_recipe-gds.nws-self    = p-nws-self
    .
    if buf_recipe.recipe-type = {&alternative}
    and buf_recipe-gds.proc-number <> 0
    then do:        /* В рецепте альтернативы назначенный порядок ингредиентов не должен измениться */
        /* do nothing */
    end.
    else do:
        if p-proc-number <> 0
        then do:
            assign
                buf_recipe-gds.proc-number = p-proc-number
            .
        end.
        else do:        /* Если порядковый номер задан =0, то задать следующий по порядку */
            assign
                v-max-proc-num = 0
            .
            for each buf_proc_recipe-gds no-lock
               where buf_proc_recipe-gds.recipe-code = p-recipe-code
            :
                if recid( buf_proc_recipe-gds ) <> recid( buf_recipe-gds )
                then do:
                    assign
                        v-max-proc-num = ( if v-max-proc-num < buf_proc_recipe-gds.proc-number then buf_proc_recipe-gds.proc-number else v-max-proc-num )
                    .
                end.
            end.
            assign
                buf_recipe-gds.proc-number = v-max-proc-num + 1
            .
        end.
    end.
end.
end procedure. /* create-recipe-gds */

PROCEDURE fbrlib-create-or-update-recipe :
/*------------------------------------------------------------------------------
    Создание и изменение рецепта
    Input:
        p-mode               as character - {&add-def} или {&update}
        p-obj-type           as character - объект
        p-obj-code           as integer
        p-recipe-code        as character - код рецепта. Если "", то создается новый
        p-recipe-type        as character - тип рецепта. Обязателен для нового рецепта
        p-gds-code           as integer   - код товара. Обязателен для нового рецепта
        p-name               as integer   - имя рецепта. Для нового рецепта, если "", то будет взято имя товара
        p-design             as character - способ оформления блюда
        p-order              as integer   - порядковый номер при обработке
        p-quality            as character - Показатели качества готовой продукции
        p-ref-num            as character - Номер рецепта по справочнику рецептур
        p-technique          as character - Описание технологии приготовления блюда по рецепту
        p-template           as character - Ссылка на справочник рецептур или технологическую карту
        p-qnty               as decimal   - Количество товара
        p-portion-qnty       as integer   - Количество порций товара
        p-portion-weight     as decimal   - Вес порции для рецепта производства со штучными ингредиентами
    Output:
------------------------------------------------------------------------------*/
define input parameter p-mode               as character    no-undo.
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define input parameter p-recipe-code        as character    no-undo.
define input parameter p-recipe-type        as character    no-undo.
define input parameter p-gds-code           as integer      no-undo.
define input parameter p-name               as character    no-undo.
define input parameter p-design             as character    no-undo.
define input parameter p-order              as integer      no-undo.
define input parameter p-quality            as character    no-undo.
define input parameter p-ref-num            as character    no-undo.
define input parameter p-technique          as character    no-undo.
define input parameter p-template           as character    no-undo.
define input parameter p-qnty               as decimal      no-undo.
define input parameter p-portion-qnty       as integer      no-undo.
define input parameter p-portion-weight     as decimal      no-undo.
define output parameter p-new-recipe-code   as character    no-undo.

    define variable v-host-code         as integer      no-undo.
    define variable v-fbr-gds-obj-recid as recid        no-undo.

    define buffer buf_recipe    for ub.recipe.
    define buffer buf_goods     for ub.goods.
do
for buf_recipe
  , buf_goods
on error undo, return error
:
    if p-mode <> {&add-def}
    and p-mode <> {&update}
    then do:
        message
            skip "Ошибка задания типа операции для создания или измения рецепта."
            skip (1)
            skip "Задан тип операции:" p-mode
        view-as alert-box error.
        undo, return error .
    end.
    if p-recipe-code = ""
    then do:
        { gbl/hostcode.i
            p-obj-type
            p-obj-code
            v-host-code
        }
        find first buf_goods no-lock
             where buf_goods.gds-code = p-gds-code
        .
        create buf_recipe .
        run fbrcode-gen-recipe-code in this-procedure (
              input p-obj-type
            , input p-obj-code
            , output buf_recipe.recipe-code
        ).
        assign
            buf_recipe.artic               = buf_goods.artic
            buf_recipe.prod-type           = buf_goods.prod-type
            buf_recipe.prod-code           = buf_goods.prod-code
            buf_recipe.recipe-type         = p-recipe-type
            buf_recipe.recipe-name         = ( if p-name = "" then buf_goods.gds-name else p-name )
            buf_recipe.gds-code            = p-gds-code
            buf_recipe.host-code           = v-host-code
            buf_recipe.obj-type            = p-obj-type
            buf_recipe.obj-code            = p-obj-code
            buf_recipe.recipe-design       = ""
            buf_recipe.recipe-order        = 0
            buf_recipe.recipe-quality      = ""
            buf_recipe.recipe-ref-num      = ""
            buf_recipe.recipe-technique    = ""
            buf_recipe.recipe-template     = ""
            buf_recipe.qnty                = 1.0
            buf_recipe.portion-qnty        = 1
            buf_recipe.portion-weight      = 0
        .
    end.
    if p-name <> ""
    then do:
        assign
            buf_recipe.recipe-name = p-name
        .
    end.
    assign
        buf_recipe.recipe-design       = p-design
        buf_recipe.recipe-order        = p-order
        buf_recipe.recipe-quality      = p-quality
        buf_recipe.recipe-ref-num      = p-ref-num
        buf_recipe.recipe-technique    = p-technique
        buf_recipe.recipe-template     = p-template
        buf_recipe.qnty                = p-qnty
        buf_recipe.portion-qnty        = p-portion-qnty
        buf_recipe.portion-weight      = p-portion-weight
    .
    assign
        p-new-recipe-code = buf_recipe.recipe-code
    .
    run fbrlib-set-default-recipe in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input buf_goods.gds-code
    ).
end.
END PROCEDURE.      /* fbrlib-create-or-update-recipe */

PROCEDURE fbrlib-delete-fact-fbr-doc :
/*------------------------------------------------------------------------------
  Purpose:     Удаление закрытого до факта документа производства
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter parparentproc-handle as widget-handle no-undo .
define input parameter p-doc-code   as character no-undo.
define input parameter p-chip-num   like ub.c-trn-doc.chip-num no-undo .

    define variable v-shift-on      as logical      no-undo.
    define variable v-shift-date    as date         no-undo.
    define variable v-shift-num     as integer      no-undo.
    define variable v-shift-name    as character    no-undo.
    define variable v-obj-date      as date         no-undo.
    define variable v-chip-num      as integer      no-undo.

    define buffer buf_fbr-doc       for ub.fbr-doc.
    define buffer buf_fbr-line      for ub.fbr-line.
    define buffer buf_c-fbr-doc     for ub.c-fbr-doc.
    define buffer buf_fbr-recipe     for ub.fbr-recipe.
    define buffer buf_fbr-recipe-gds for ub.fbr-recipe-gds.
    
    define buffer buf_marking-lines for ub.marking-lines .
    define buffer buf_marking       for ub.marking .
    define buffer buf_goods         for ub.goods .


do
for buf_fbr-doc
  , buf_fbr-line
  , buf_c-fbr-doc
  , buf_fbr-recipe
  , buf_fbr-recipe-gds
  , buf_goods
  , buf_marking
  , buf_marking-lines
on error undo, return error
:
    { gbl/getcntxt.i def }
    { gbl/getcntxt.i get " " parparentproc-handle }
    if search ("delfbr.err") <> ?
    then do:
        os-delete "delfbr.err".
    end.
  _del-block:
    do transaction
  on error undo _del-block, return error return-value
  on endkey undo _del-block , return error return-value
  on stop undo _del-block , return error return-value
    :
        find first buf_fbr-doc exclusive-lock
             where buf_fbr-doc.doc-code = p-doc-code
        no-error.
        if not available buf_fbr-doc
        then do:
      undo _del-block, return error substitute("&1 &2 &3&4Не найден документ производства &5 для удаления."
                                        ,vss-workfile
                                        ,vss-revision
                                        ,vss-description
                                        ,{&new-line}
                                        , p-doc-code).
        end.
        run fbrlib-delete-fact-trn-doc in this-procedure (
            input parparentproc-handle
           ,input p-doc-code
           ,input {&income}
           ,input p-chip-num
           ,output v-chip-num
        ) no-error.
        if error-status :error
        then do:
            run fbrlib-print-del-error-message in this-procedure .
      undo _del-block, return error.
        end.
        assign
        p-chip-num = (if p-chip-num = ?
                      then v-chip-num
                      else p-chip-num).
        run fbrlib-delete-fact-trn-doc in this-procedure (
            input parparentproc-handle
           ,input p-doc-code
           ,input {&expense}
           ,input p-chip-num
           ,output v-chip-num
        ) no-error.
        if error-status :error
        then do:
            run fbrlib-print-del-error-message in this-procedure .
      undo _del-block, return error.
        end.
        run fbrlib-delete-fact-trn-doc in this-procedure (
            input parparentproc-handle
           ,input p-doc-code
           ,input {&write-off}
           ,input p-chip-num
           ,output v-chip-num
        ) no-error.
        if error-status :error
        then do:
            run fbrlib-print-del-error-message in this-procedure .
      undo _del-block, return error.
        end.
        /*---START--------- Создаем историю удаления f-doc ---------------------*/
        create buf_c-fbr-doc.
        buffer-copy buf_fbr-doc to buf_c-fbr-doc.

        { gbl/curobjdt.i
            buf_fbr-doc.obj-type
            buf_fbr-doc.obj-code
            v-obj-date
        no-error }
        if error-status :error
        or v-obj-date = ?
        then do:
      undo _del-block, return error "Нет текущей даты на объекте документа.".
        end.
        { gbl/objat.i
            buf_fbr-doc.obj-type
            buf_fbr-doc.obj-code
            "'shift-on=request'"
            v-shift-on
        }
        if v-shift-on
        then do:        /* на объекте включены смены */
            { gbl/curshift.i
                buf_fbr-doc.obj-type
                buf_fbr-doc.obj-code
                v-shift-date
                v-shift-num
                v-shift-name
                no-error
            }
            if error-status :error
            then do:
        undo _del-block, return error "Ошибка при поиске текущей смены на объекте".
            end.
        end.
        else do:
            assign
                v-shift-date = ?
                v-shift-num  = ?
                v-shift-name = ?
            .
        end.
        define variable v-today       as date         no-undo.
        define variable v-time        as integer      no-undo.

        run cur-time in this-procedure (
              output v-today
            , output v-time
        ).
        assign
            buf_c-fbr-doc.chip-num         = (if p-chip-num <> ? then p-chip-num else next-value( s-corr-chip, {&db-name_schema}  ))
            buf_c-fbr-doc.corr-user-name   = v-cntxt-userid
            buf_c-fbr-doc.corr-user-db-num = v-cntxt-db-num
            buf_c-fbr-doc.corr-date        = v-today
            buf_c-fbr-doc.corr-time        = v-time
            buf_c-fbr-doc.corr-shift-date  = v-shift-date
            buf_c-fbr-doc.corr-shift-num   = v-shift-num
            buf_c-fbr-doc.corr-shift-name  = v-shift-name
            buf_c-fbr-doc.is-del           = yes
        .
        /*---END----------- Создаем историю удаления f-doc ---------------------*/
        assign
            buf_fbr-doc.is-del = yes
        .
        for each buf_fbr-line exclusive-lock
           where buf_fbr-line.doc-code = p-doc-code
    on error  undo _del-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _del-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _del-block, return error substitute( "&1. endkey", vss-workfile )
        :
            for first buf_goods no-lock where buf_goods.artic      = buf_fbr-line.artic
                                          and buf_goods.prod-type  = buf_fbr-line.prod-type
                                          and buf_goods.prod-code  = buf_fbr-line.prod-code,
            each buf_marking-lines exclusive-lock where buf_marking-lines.gds-code = buf_goods.gds-code
                                                    and buf_marking-lines.obj-type = buf_fbr-doc.obj-type
                                                    and buf_marking-lines.obj-code = buf_fbr-doc.obj-code
                                                    and buf_marking-lines.in-code  = "manufacturing"
                                                    and buf_marking-lines.out-code = buf_fbr-line.doc-code
                                                    and buf_marking-lines.part-code = buf_fbr-line.recipe-code
                                                    and buf_marking-lines.prt-code = 0
            :
              for first buf_marking exclusive-lock where buf_marking.mark begins buf_marking-lines.mark :
                assign
/*  BTS-977                buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB when not buf_fbr-line.is-comp*/
                  buf_marking.sts = objSrv:Env:Marking:Sts:Mark:UsedInProduction:KeyIntDB when buf_fbr-line.is-comp
                .
              end .
              delete buf_marking-lines.
            end .
            delete buf_fbr-line.
        end.
        for each buf_fbr-recipe exclusive-lock
           where buf_fbr-recipe.doc-code = p-doc-code
    on error  undo _del-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _del-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _del-block, return error substitute( "&1. endkey", vss-workfile )
        :
            delete buf_fbr-recipe.
        end.
        for each buf_fbr-recipe-gds exclusive-lock
           where buf_fbr-recipe-gds.doc-code = p-doc-code
    on error  undo _del-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _del-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _del-block, return error substitute( "&1. endkey", vss-workfile )
        :
            delete buf_fbr-recipe-gds.
        end.
        delete buf_fbr-doc.
    end.        /* do transaction */
end.
END PROCEDURE. /* fbrlib-delete-fact-fbr-doc */

PROCEDURE fbrlib-del-trn-doc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter parparentproc        as widget-handle no-undo .
define input parameter p-fbr-doc-doc-code   as character    no-undo.
define input parameter p-trn-doc-type       as character    no-undo.
define input parameter p-phchip-num         like ub.c-trn-doc.chip-num no-undo .
define output parameter p-chip-num           like ub.c-trn-doc.chip-num no-undo .

    define variable v-trn-doc-doc-code  as character     no-undo.

    define buffer buf_trn-doc       for ub.trn-doc.

    { gbl/getcntxt.i def }
    { gbl/getcntxt.i get }
    run fbrcode-trn-doc in this-procedure (
          input {&manufacturing}
        , input p-fbr-doc-doc-code
        , input p-trn-doc-type
        , output v-trn-doc-doc-code
    ).
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = v-trn-doc-doc-code
    no-error.
    if available buf_trn-doc
    then do:
        run str/del-doc.p (
              input parparentproc
            , input buf_trn-doc.doc-code
            , input v-cntxt-db-num
            , input "del-doc.err"
            , input ?
            , input p-fbr-doc-doc-code
            , input v-cntxt-userid
            , input 0
            , input p-phchip-num
            , output p-chip-num
        ) no-error.
        if error-status :error
        then do:
          undo, return error substitute("Не удалось удалить складской документ &1, созданный по документу производства &2.&3&4&3&5"
                                        ,v-trn-doc-doc-code
                                        ,p-fbr-doc-doc-code
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value ).
        end.
    end.
end.
END PROCEDURE. /* fbrlib-del-trn-doc */

PROCEDURE fbrlib-delete-fact-trn-doc :
/*------------------------------------------------------------------------------
  Purpose:     Удаление складского документа по документу производства
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-fbr-doc-code   as character        no-undo.
define input parameter p-doc-type       as character    no-undo.
define input parameter p-ph-chip-num       like ub.c-trn-doc.chip-num no-undo .
define output parameter p-chip-num      like ub.c-trn-doc.chip-num no-undo .

    define variable v-doc-code          as character        no-undo.
    define variable v-ext-doc-type      as character        no-undo.
    define variable v-trn-doc-recid     as recid            no-undo.
    define variable varchip-code        as integer          no-undo.
    define variable varchip-code2       as integer          no-undo.
    define variable v-chip-counter      as integer          no-undo.

    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_pri_trn-doc   for ub.trn-doc.
    define buffer buf_cons_trn-doc  for ub.trn-doc.
do
for buf_trn-doc
  , buf_pri_trn-doc
  , buf_cons_trn-doc
on error undo, return error
:
    { gbl/getcntxt.i def }
    { gbl/getcntxt.i get }
    run fbrcode-trn-doc in this-procedure (
          input {&manufacturing}
        , input p-fbr-doc-code
        , input p-doc-type
        , output v-doc-code
    ).
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = v-doc-code
    no-error.
    if not available buf_trn-doc
    then do:
        if p-doc-type <> {&write-off}
        then do:
            message
                "Не найден документ '" p-doc-type "'"
                "по документу производства " p-fbr-doc-code
            view-as alert-box.
            undo, return error.
        end.
        else do:
            /* Документа списания (на услуги) может не быть, это нормально. */
        end.
    end.        /* if not available buf_trn-doc */
    else do:
/*        output to "d:\___fbr.txt" append.*/
/*            put unformatted*/
/*                substitute( "Номер: &2; Тип: &3; Внутренний: &4; Откуда: &5 &6; Куда: &7 &8&1"*/
/*                            , {&new-line}*/
/*                            , buf_trn-doc.doc-code*/
/*                            , buf_trn-doc.ext-doc-type*/
/*                            , buf_trn-doc.internal*/
/*                            , buf_trn-doc.obj-type*/
/*                            , buf_trn-doc.obj-code*/
/*                            , buf_trn-doc.cli-type*/
/*                            , buf_trn-doc.cli-code*/
/*                          )*/
/*            .*/
/*        output close.*/
        assign
            v-trn-doc-recid = recid( buf_trn-doc )
            v-ext-doc-type  = buf_trn-doc.ext-doc-type
        .
        if v-ext-doc-type = {&TDEDT_Ras_Perem}
        then do:
            find first buf_pri_trn-doc no-lock
                 where buf_pri_trn-doc.out-code     = v-doc-code
                   and buf_pri_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem}
            no-error.
            if available buf_pri_trn-doc
            then do:
                run str/del-doc.p (
                      input parparentproc
                    , input buf_pri_trn-doc.doc-code
                    , input v-cntxt-db-num
                    , input "delfbr.err"
                    , input ?
                    , input p-fbr-doc-code
                    , input v-cntxt-userid
                    , input 0
                    , input (if p-ph-chip-num <> ?
                            then p-ph-chip-num
                            else (if varchip-code <> 0
                                then varchip-code
                                else ?)
                            )
                    , output varchip-code2
                ) no-error.
                if error-status :error
                then do:
                  undo, return error substitute("Ошибка при удалении складского документа &1, созданный по документу производства &2.&3&4&3&5"
                                                ,buf_pri_trn-doc.doc-code
                                                ,p-fbr-doc-code
                                                , {&new-line}
                                                , error-status:get-message(1)
                                                , return-value ).

                end.
            end.        /* if available buf_pri_trn-doc */
        end.
        define buffer buf_out_trn-doc       for ub.trn-doc.
        if p-doc-type = {&income}
        then do:
            assign
                v-chip-counter = 0
            .
            for each buf_out_trn-doc exclusive-lock
               where buf_out_trn-doc.out-code = buf_trn-doc.doc-code
            on error undo, return error
            :
                assign
                    v-chip-counter = v-chip-counter + 1
                .
                if v-chip-counter > 1
                then do:
                    assign
                        varchip-code = varchip-code2
                    .
                end.
                run str/del-doc.p (
                      input parparentproc
                    , input buf_out_trn-doc.doc-code
                    , input v-cntxt-db-num
                    , input "delfbr.err"
                    , input ?
                    , input p-fbr-doc-code
                    , input v-cntxt-userid
                    , input 0
                    , input (if p-ph-chip-num <> ?
                            then p-ph-chip-num
                            else (if varchip-code <> 0
                                then varchip-code
                                else ?)
                            )
                    , output varchip-code2
                ) no-error.
                if error-status :error
                then do:
                  undo, return error substitute("Ошибка при удалении складского документа &1, связанного со складским документов прихода &2, созданный по документу производства &3.&4&5&4&6"
                                                ,buf_out_trn-doc.doc-code
                                                ,buf_trn-doc.doc-code
                                                ,p-fbr-doc-code
                                                , {&new-line}
                                                , error-status:get-message(1)
                                                , return-value ).

                end.
            end.        /* for each buf_out_trn-doc */
        end.
        run str/del-doc.p (
              input parparentproc
            , input buf_trn-doc.doc-code
            , input v-cntxt-db-num
            , input "delfbr.err"
            , input ?
            , input p-fbr-doc-code
            , input v-cntxt-userid
            , input 0
            , input (if p-ph-chip-num <> ?
                     then p-ph-chip-num
                     else (if varchip-code <> 0
                           then varchip-code
                           else ?)
                     )
            , output varchip-code2
        ) no-error.
        if error-status :error
        then do:
            undo, return error substitute("Ошибка при удалении складского документа &1, созданный по документу производства &2.&3&4&3&5"
                                          ,buf_trn-doc.doc-code
                                          ,p-fbr-doc-code
                                          , {&new-line}
                                          , error-status:get-message(1)
                                          , return-value ).

        end.
        if p-doc-type = {&expense}
        or p-doc-type = {&write-off}
        then do:        /* Документ смены типа приобретения */
            assign
                v-chip-counter = 0
            .
            for each buf_cons_trn-doc no-lock
               where buf_cons_trn-doc.out-code      = v-doc-code
                 and buf_cons_trn-doc.ext-doc-type  = {&TDEDT_Chg_Purch_Code}
            :
                assign
                    v-trn-doc-recid = recid( buf_cons_trn-doc )
                    v-chip-counter = v-chip-counter + 1
                .
                assign
                varchip-code = if v-chip-counter = 2
                               then varchip-code2
                               else varchip-code.
                run str/del-doc.p (
                      input parparentproc
                    , input buf_cons_trn-doc.doc-code
                    , input v-cntxt-db-num
                    , input "delfbr.err"
                    , input ?
                    , input ?
                    , input v-cntxt-userid
                    , input 0
                    , input (if p-ph-chip-num <> ?
                             then p-ph-chip-num
                             else ( if v-chip-counter = 1
                                    then ?
                                    else varchip-code )
                             )
                    , output varchip-code2
                ) no-error.
                if error-status :error
                then do:
                    undo, return error substitute("Ошибка при удалении складского документа смены типа приобретения &1, созданный по документу производства &2.&3&4&3&5"
                                                  ,buf_cons_trn-doc.doc-code
                                                  ,p-fbr-doc-code
                                                  , {&new-line}
                                                  , error-status:get-message(1)
                                                  , return-value ).

                end.
                assign
                    p-chip-num = varchip-code2
                .
            end.        /* for each buf_cons_trn-doc no-lock */
        end.        /* p-doc-type = {&expense} or p-doc-type = {&write-off} */
        assign
            p-chip-num = varchip-code2
        .
    end.        /* if NOT( not available buf_trn-doc ) */
end.
END PROCEDURE. /* fbrlib-delete-fact-trn-doc */

PROCEDURE fbrlib-print-del-error-message :
/*------------------------------------------------------------------------------
  Purpose:     Вывести на экран сообщение об ошибке при удалении
                документа производства и распечатать файл с ошибками, заполненный
                при удалении складскиих документов.
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    define variable v-user-action   as character    no-undo.
    define variable v-printed       as logical      no-undo.

    message
        vss-workfile vss-revision vss-description
        skip "Ошибка при удалении документа."
        skip return-value
        skip trim(error-status :get-message(1))
        skip trim(error-status :get-message(2))
        skip trim(error-status :get-message(3))
    view-as alert-box error.
    if search ("delfbr.err") <> ?
    then do:
      run gbl/prnfilen.w
        (input  "Ошибки при удалении документа производства"
        ,input  0
        ,input  "delfbr.err"
        ,input  7
        ,output v-user-action
        ,output v-printed
        ).
    end.
end.
END PROCEDURE. /* fbrlib-print-del-error-message */


/*==========================================================================*/
procedure fbrlib-calc-brutto :
define input parameter p-recipe-type        as character        no-undo.
define input parameter p-netto              as decimal          no-undo.
define input parameter p-coeff-value        as decimal          no-undo.
define input parameter p-coeff-waste        as decimal          no-undo.
define input parameter p-brutto             as decimal          no-undo.
define input parameter p-calc-method        as integer          no-undo.
define output parameter p-new-netto         as decimal          no-undo.
define output parameter p-new-coeff-waste   as decimal          no-undo.
define output parameter p-new-brutto        as decimal          no-undo.
define output parameter p-new-calc-method   as integer          no-undo.
do
on error undo, return error
:
    if p-recipe-type <> {&manufacturing}
    then do:
        assign
            p-new-coeff-waste = 0
            p-new-calc-method = 1
            p-new-netto       = ( if p-calc-method = 1 then p-brutto else p-netto )
            p-new-brutto      = ( if p-calc-method = 1 then p-brutto else p-netto )
        .
    end.        /* if p-recipe-type <> {&manufacturing} */
    else do:
        assign
            p-new-calc-method = p-calc-method
        .
        if p-coeff-waste = 0
        then do:
            assign
                p-coeff-value = 0
            .
        end.
        case p-calc-method
        :
            when 1
            then do:
                assign
                    p-new-netto         = p-brutto * ( 100 - p-coeff-value - p-coeff-waste ) / 100
                    p-new-coeff-waste   = p-coeff-waste
                    p-new-brutto        = p-brutto
                .
            end.        /* when 1 */
            when 2
            then do:
                assign
                    p-new-netto         = p-netto
                    p-new-coeff-waste   = 100 - p-coeff-value - ( 100 * p-netto / p-brutto )
                    p-new-brutto        = p-brutto
                .
            end.        /* when 2 */
            when 3
            then do:
                assign
                    p-new-netto         = p-netto
                    p-new-coeff-waste   = p-coeff-waste
                    p-new-brutto        = 100 * p-netto / ( 100 - p-coeff-value - p-coeff-waste )
                .
            end.        /* when 3 */
            otherwise do:
                define variable v-yesno    as logical      no-undo.
                assign
                    v-yesno = yes
                .
                message
                    "Неверный метод для расчета брутто, нетто и процента потерь."
                    skip "Значение метода должно быть 1, 2 или 3."
                    skip(1)
                    skip "Заданное значение:" p-calc-method
                    skip(1)
                    skip "Установить значение метода расчета 1"
                    skip "(расчет нетто по брутто и проценту потерь)?"
                view-as alert-box warning
                buttons yes-no
                title "Неверное значение метода пересчета в строках документа-производства"
                update v-yesno
                .
                if v-yesno = yes
                then do:
                    assign
                        p-new-calc-method   = 1
                        p-new-netto         = p-brutto * ( 100 - p-coeff-value - p-coeff-waste ) / 100
                        p-new-coeff-waste   = p-coeff-waste
                        p-new-brutto        = p-brutto
                    .
                end.
                else do:
                    message
                            vss-workfile vss-revision vss-description
                        skip(1)
                        skip "Ошибка расчета брутто, нетто и процента потерь."
                        skip return-value
                        skip trim(error-status :get-message(1))
                            trim(error-status :get-message(2))
                            trim(error-status :get-message(3))
                    view-as alert-box error
                    title "Неверное значение метода расчета"
                    .
                    undo, return error .
                end.
            end.        /* otherwise */
        end case.       /* case p-calc-method */
    end.        /* NOT ( if p-recipe-type <> {&manufacturing} ) */
end.
end procedure. /* fbrlib-calc-brutto */

/*==========================================================================*/
procedure fbrlib-check-brutto :
define input parameter p-recipe-type        as character        no-undo.
define input parameter p-netto              as decimal          no-undo.
define input parameter p-coeff-value        as decimal          no-undo.
define input parameter p-coeff-waste        as decimal          no-undo.
define input parameter p-brutto             as decimal          no-undo.
define input parameter p-calc-method        as integer          no-undo.
define output parameter p-error-message     as character        no-undo.
define output parameter p-not-good          as logical          no-undo.
do
on error undo, return error
:
    if p-recipe-type <> {&manufacturing}
    then do:
        if p-netto <> p-brutto
        or p-coeff-waste <> 0
        then do:
            assign
                p-not-good      = yes
                p-error-message = substitute( "Во всех рецептах кроме рецепта производства должно выполняться:&1брутто = нетто и процент потерь = 0.&1&1Тип рецепта: &2&1Брутто: &3&1Нетто: &4&1Процент потерь: &5"
                                        , {&new-line}, p-recipe-type, p-brutto, p-netto, p-coeff-waste )
            .
        end.
    end.        /* if p-recipe-type <> {&manufacturing}  */
    else do:
        if p-coeff-waste = 0
        then do:
            assign
                p-coeff-value = 0
            .
        end.
        case p-calc-method
        :
            when 1
            then do:
                if round( p-netto, 9 ) <> round( p-brutto * ( 100 - p-coeff-value - p-coeff-waste ) / 100, 9 )
                then do:
                    assign
                        p-not-good      = yes
                        p-error-message = substitute( "Ошибка расчета нетто ( &2 ) &1 по брутто ( &3 ) &1 и процентам потерь ( &4, &5 )."
                                                , {&new-line}, p-netto, p-brutto, p-coeff-value, p-coeff-waste )
                    .
                end.
            end.        /* when 1 */
            when 2
            then do:
                if round( p-coeff-waste, 9 ) <> round( 100 - p-coeff-value - ( 100 * p-netto / p-brutto ), 9 )
                then do:
                    assign
                        p-not-good      = yes
                        p-error-message =  substitute( "Ошибка расчета процента потерь ( &2 ) &1 по нетто ( &3 ) &1 брутто ( &4 ) &1 и cезонному проценту ( &5 )."
                                                , {&new-line}, p-coeff-waste, p-netto, p-brutto, p-coeff-value )
                    .
                end.
            end.        /* when 2 */
            when 3
            then do:
                if round( p-brutto, 9 ) <> round( 100 * p-netto / ( 100 - p-coeff-value - p-coeff-waste ), 9 )
                then do:
                    assign
                        p-not-good      = yes
                        p-error-message = substitute( "Ошибка расчета брутто ( &3 ) &1 по нетто ( &2 ) &1 и процентам потерь ( &4, &5 )."
                                                , {&new-line}, p-netto, p-brutto, p-coeff-value, p-coeff-waste )
                    .
                end.
            end.        /* when 3 */
            otherwise do:
                assign
                    p-not-good      = yes
                    p-error-message = substitute( "Ошибка ввода метода расчета ( &1 ).", p-calc-method )
                .
            end.        /* otherwise */
        end case.       /* case p-out-calc-method */
    end.        /* NOT ( if p-recipe-type <> {&manufacturing}  ) */
end.
end procedure. /* fbrlib-check-brutto */

/*==========================================================================
    Проверка соответствия рецепта документа строке документа.
*/
procedure fbrlib-check-fbr-recipe :
define input parameter p-doc-code       as character        no-undo.
define input parameter p-recipe-code    as character        no-undo.
define output parameter p-is-correct    as logical          no-undo.

    define variable v-comp-factor    as decimal      no-undo.

    define buffer buf_fbr-recipe        for ub.fbr-recipe.
    define buffer buf_fbr-recipe-gds    for ub.fbr-recipe-gds.
    define buffer buf_fbr-line          for ub.fbr-line.
do
for buf_fbr-recipe
  , buf_fbr-recipe-gds
  , buf_fbr-line
on error undo, return error
:
    assign
        p-is-correct = yes
    .
    find first buf_fbr-recipe no-lock
         where buf_fbr-recipe.doc-code    = p-doc-code
           and buf_fbr-recipe.recipe-code = p-recipe-code no-error
    .
    if not available buf_fbr-recipe then do:
      undo, return error substitute("Не найден рецепт (fbr-recipe) с кодом &1 для  документа пр-ва &2", p-recipe-code, p-doc-code).
    end.

    if buf_fbr-recipe.recipe-type = {&alternative}
    then do:
        /* рецепт альтернативы документа не обязан соответствовать количествам в документе */
    end.        /* if buf_fbr-recipe.recipe-type = {&alternative} */
    else do:
        find first buf_fbr-line no-lock
             where buf_fbr-line.doc-code    = buf_fbr-recipe.doc-code
               and buf_fbr-line.is-comp     = yes
               and buf_fbr-line.recipe-code = buf_fbr-recipe.recipe-code
               and buf_fbr-line.artic       = buf_fbr-recipe.artic
               and buf_fbr-line.prod-type   = buf_fbr-recipe.prod-type
               and buf_fbr-line.prod-code   = buf_fbr-recipe.prod-code
        .
        assign
            v-comp-factor = buf_fbr-line.fact-qnty / buf_fbr-recipe.qnty
        .
        recipe-line-cycle:
        for each buf_fbr-recipe-gds no-lock
           where buf_fbr-recipe-gds.doc-code    = p-doc-code
             and buf_fbr-recipe-gds.recipe-code = p-recipe-code
        on error undo, return error
        :
            find first buf_fbr-line no-lock
                 where buf_fbr-line.doc-code    = buf_fbr-recipe-gds.doc-code
                   and buf_fbr-line.is-comp     = no
                   and buf_fbr-line.recipe-code = buf_fbr-recipe-gds.recipe-code
                   and buf_fbr-line.artic       = buf_fbr-recipe-gds.artic
                   and buf_fbr-line.prod-type   = buf_fbr-recipe-gds.prod-type
                   and buf_fbr-line.prod-code   = buf_fbr-recipe-gds.prod-code
            .
            if absolute( buf_fbr-line.fact-qnty / buf_fbr-recipe-gds.brutto-qnty - v-comp-factor ) > 0.000000001
            then do:
                assign
                    p-is-correct = no
                .
                leave recipe-line-cycle.
            end.
        end.        /* for each buf_fbr-recipe-gds */
    end.        /* NOT ( if buf_fbr-recipe.recipe-type = {&alternative} ) */
end.
end procedure. /* fbrlib-check-fbr-recipe */

/*==========================================================================*/
procedure fbrlib-get-recipe-type :
define input parameter p-fbr-doc-code   as character        no-undo.
define input parameter p-recipe-code    as character        no-undo.
define output parameter p-recipe-type   as character        no-undo.

    define buffer buf_recipe        for ub.recipe.
    define buffer buf_fbr-recipe    for ub.fbr-recipe.
do
for buf_recipe
  , buf_fbr-recipe
on error undo, return error
:
    if p-fbr-doc-code = ""
    then do:        /* Ищется рецепт, т.к. документ не задан */
        find first buf_recipe no-lock
             where buf_recipe.recipe-code = p-recipe-code
        no-error.
        if available buf_recipe
        then do:
            assign
                p-recipe-type = buf_recipe.recipe-type
            .
        end.
        else do:
            assign
                p-recipe-type = "":U
            .
        end.
    end.        /* if p-fbr-doc-code = "" */
    else do:        /* Задан номер документа, значит ищется рецепт документа */
        find first buf_fbr-recipe no-lock
             where buf_fbr-recipe.doc-code      = p-fbr-doc-code
               and buf_fbr-recipe.recipe-code   = p-recipe-code
        no-error.
        if available buf_fbr-recipe
        then do:
            assign
                p-recipe-type = buf_fbr-recipe.recipe-type
            .
        end.
        else do:
            assign
                p-recipe-type = "":U
            .
        end.
    end.        /* NOT ( if p-fbr-doc-code = "" ) */
end.
end procedure. /* fbrlib-get-recipe-type */


PROCEDURE calc-comp-from-ingr :
/*------------------------------------------------------------------------------
  Purpose:      Пересчитать составной товар при нажатии кнопки Составной.
  Parameters:   <none>
  Notes:        Считаем заданным ингредиент под курсором в нижней таблице.
                Количество можно задать другое, не то, что в строке.
------------------------------------------------------------------------------*/
define input parameter p-fbr-v-fbr-doc-line-recid           as recid        no-undo.
define input parameter p-fact-qnty                          as decimal      no-undo.
define output parameter p-comp-fbr-v-fbr-doc-line-recid     as recid        no-undo.
define output parameter p-comp-qnty                         as decimal      no-undo.

    define variable v-ingr-qnty     as decimal       no-undo.

    define buffer buf_i_fbr-line    for ub.fbr-line.
    define buffer buf_fbr-line      for ub.fbr-line.
    define buffer buf_recipe        for ub.fbr-recipe.
    define buffer buf_recipe-gds    for ub.fbr-recipe-gds.
do
for buf_i_fbr-line
  , buf_fbr-line
  , buf_recipe
  , buf_recipe-gds
on error undo, return error
:
    find first buf_i_fbr-line no-lock
         where recid( buf_i_fbr-line ) = p-fbr-v-fbr-doc-line-recid
    .
    find first buf_recipe no-lock
         where buf_recipe.doc-code      = buf_i_fbr-line.doc-code
           and buf_recipe.recipe-code   = buf_i_fbr-line.recipe-code
    no-error.
    if not available buf_recipe
    then do:
        message
                vss-workfile vss-revision vss-description
            skip "В строке производства не указан рецепт."
            skip "Невозможно рассчитать количество составного товара."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if buf_recipe.recipe-type = {&alternative}
    then do:
        for each buf_fbr-line no-lock
           where buf_fbr-line.doc-code    = buf_i_fbr-line.doc-code
             and buf_fbr-line.trn-type    = buf_i_fbr-line.trn-type
             and buf_fbr-line.recipe-code = buf_i_fbr-line.recipe-code
        on error undo, return error
        :
            find first buf_recipe-gds no-lock
                 where buf_recipe-gds.doc-code    = buf_i_fbr-line.doc-code
                   and buf_recipe-gds.recipe-code = buf_i_fbr-line.recipe-code
                   and buf_recipe-gds.artic       = buf_fbr-line.artic
                   and buf_recipe-gds.prod-type   = buf_fbr-line.prod-type
                   and buf_recipe-gds.prod-code   = buf_fbr-line.prod-code
            .
            assign
                p-comp-qnty         = p-comp-qnty       + ( buf_fbr-line.fact-qnty * buf_recipe-gds.brutto-qnty )
            .
        end.        /* for each buf_fbr-line */
        assign
            p-comp-qnty         = p-comp-qnty       / buf_recipe.qnty
        .
    end.        /* if buf_recipe.recipe-type = {&alternative} */
    else do:
        find first buf_recipe-gds no-lock
             where buf_recipe-gds.doc-code    = buf_i_fbr-line.doc-code
               and buf_recipe-gds.recipe-code = buf_i_fbr-line.recipe-code
               and buf_recipe-gds.artic       = buf_i_fbr-line.artic
               and buf_recipe-gds.prod-type   = buf_i_fbr-line.prod-type
               and buf_recipe-gds.prod-code   = buf_i_fbr-line.prod-code
        .
        assign
            p-comp-qnty = p-fact-qnty / buf_recipe-gds.brutto-qnty * buf_recipe.qnty
        .
    end.        /* if NOT( buf_recipe.recipe-type = {&alternative} ) */
    find first buf_fbr-line no-lock
         where buf_fbr-line.doc-code    = buf_i_fbr-line.doc-code
           and buf_fbr-line.is-comp     = yes
           and buf_fbr-line.recipe-code = buf_i_fbr-line.recipe-code
    .
    assign
        p-comp-fbr-v-fbr-doc-line-recid = recid( buf_fbr-line )
    .
end.
END PROCEDURE. /* calc-comp-from-ingr */


PROCEDURE get-temp_dressing-ingr-used-qnty :
/* Определить используемое количество ингредиента в рецепте разделки*/
define input parameter p-recipe-code    as character    no-undo.
define input parameter p-gds-code       as integer      no-undo.
define output parameter p-line-qnty     as decimal      no-undo.
define output parameter p-used-qnty     as decimal      no-undo.
define output parameter p-recipe-qnty   as decimal      no-undo.

    define buffer buf_temp_dressing-ingr    for temp_dressing-ingr.

do
for buf_temp_dressing-ingr
on error undo, return error
:
    find first buf_temp_dressing-ingr no-lock
         where buf_temp_dressing-ingr.recipe-code = p-recipe-code
           and buf_temp_dressing-ingr.gds-code    = p-gds-code
    no-error.
    if available buf_temp_dressing-ingr
    then do:
        assign
            p-line-qnty     = buf_temp_dressing-ingr.line-qnty
            p-used-qnty     = buf_temp_dressing-ingr.used-qnty
            p-recipe-qnty   = buf_temp_dressing-ingr.recipe-qnty
        .
    end.
    else do:
        assign
            p-line-qnty     = 0
            p-used-qnty     = 0
            p-recipe-qnty   = 0
        .
    end.
end.
END PROCEDURE. /* get-temp_dressing-ingr-used-qnty */

/*==========================================================================*/
PROCEDURE fbrlib_adjust-recipe :
/*------------------------------------------------------------------------------
  Purpose:     Изменить рецепт, привязанный к документу, в соответствии со строками документа
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-fbrhist-handle as handle no-undo .
define input parameter p-doc-code       as character    no-undo.
define input parameter p-recipe-code    as character    no-undo.
define input parameter p-price-sale-obj-type as character no-undo .
define input parameter p-price-sale-obj-code as integer no-undo .


    define variable v-recipe-qnty       as decimal      no-undo.
    define variable v-comp-qnty         as decimal      no-undo.
    define variable v-recipe-gds-qnty   as decimal      no-undo.
    define variable v-ingr-qnty         as decimal      no-undo.
    define variable v-qnty              as decimal      no-undo.
    define variable v-coeff-waste       as decimal      no-undo.
    define variable v-brutto-qnty       as decimal      no-undo.

    define buffer buf_fbr-recipe        for ub.fbr-recipe.
    define buffer buf_fbr-recipe-gds    for ub.fbr-recipe-gds.
    define buffer buf_fbr-line          for ub.fbr-line.
    define buffer buf_el_fbr-recipe-gds for ub.fbr-recipe-gds.

    find first buf_fbr-recipe no-lock
         where buf_fbr-recipe.doc-code      = p-doc-code
           and buf_fbr-recipe.recipe-code   = p-recipe-code
    .
    assign
        v-recipe-qnty = buf_fbr-recipe.qnty
    .
    find first buf_fbr-line no-lock
         where buf_fbr-line.doc-code    = p-doc-code
           and buf_fbr-line.is-comp     = yes
           and buf_fbr-line.recipe-code = p-recipe-code
    .
    assign
        v-comp-qnty = buf_fbr-line.fact-qnty
    .
    if buf_fbr-recipe.recipe-type = {&alternative}
    then do:
        /* Для альтернативы - рецепт править не надо */
    end.        /* if buf_fbr-recipe.recipe-type = {&alternative} */
    else do:
        for each buf_fbr-recipe-gds no-lock
           where buf_fbr-recipe-gds.doc-code    = p-doc-code
             and buf_fbr-recipe-gds.recipe-code = p-recipe-code
        on error undo, return error
        :
            find first buf_fbr-line no-lock
                 where buf_fbr-line.doc-code    = p-doc-code
                   and buf_fbr-line.is-comp     = no
                   and buf_fbr-line.recipe-code = p-recipe-code
                   and buf_fbr-line.artic       = buf_fbr-recipe-gds.artic
                   and buf_fbr-line.prod-type   = buf_fbr-recipe-gds.prod-type
                   and buf_fbr-line.prod-code   = buf_fbr-recipe-gds.prod-code
            .
            if buf_fbr-line.fact-qnty / v-comp-qnty <> buf_fbr-recipe-gds.brutto-qnty / v-recipe-qnty
            then do:
                do transaction
                on error undo, return error
                :
                    find first buf_el_fbr-recipe-gds exclusive-lock
                         where recid( buf_el_fbr-recipe-gds ) = recid( buf_fbr-recipe-gds )
                    .
                    assign
                        buf_el_fbr-recipe-gds.calc-method   = 1
                        buf_el_fbr-recipe-gds.brutto-qnty   = buf_fbr-line.fact-qnty * v-recipe-qnty / v-comp-qnty
                    .
                    run fbrlib-calc-brutto in this-procedure (
                          input buf_fbr-recipe.recipe-type
                        , input 0
                        , input buf_el_fbr-recipe-gds.coeff-value
                        , input buf_el_fbr-recipe-gds.coeff-waste
                        , input buf_el_fbr-recipe-gds.brutto-qnty
                        , input 1
                        , output buf_el_fbr-recipe-gds.qnty
                        , output buf_el_fbr-recipe-gds.coeff-waste
                        , output buf_el_fbr-recipe-gds.brutto-qnty
                        , output buf_el_fbr-recipe-gds.calc-method
                    ).
                end.        /* do transaction */
            end.
        end.        /* for each buf_fbr-recipe-gds */
        run fbrlib_adjust-doc-lines in this-procedure (
              input parparentproc
            , input p-fbrhist-handle
            , input p-doc-code
            , input p-recipe-code
            , input p-price-sale-obj-type
            , input p-price-sale-obj-code
        ).
    end.        /* NOT ( if buf_fbr-recipe.recipe-type = {&alternative} ) */
end.
END PROCEDURE. /* fbrlib_adjust-recipe */


/*==========================================================================*/
PROCEDURE fbrlib_adjust-doc-lines :
/*------------------------------------------------------------------------------
  Purpose:      Приводит строки документа в соответствие с рецептом.
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-fbrhist-handle as handle no-undo .
define input parameter p-doc-code       as character    no-undo.
define input parameter p-recipe-code    as character    no-undo.
define input parameter p-price-sale-obj-type as character no-undo .
define input parameter p-price-sale-obj-code as integer no-undo .

define variable v-comp-qnty         as decimal      no-undo.
define variable v-trn-type          as character    no-undo.
define variable v-ingr-qnty         as decimal      no-undo.
define variable v-recipe-qnty       as decimal      no-undo.
define variable v-fbr-v-fbr-doc-line-recid    as recid        no-undo.

define buffer buf_fbr-recipe        for ub.fbr-recipe.
define buffer buf_fbr-recipe-gds    for ub.fbr-recipe-gds.
define buffer buf_fbr-line          for ub.fbr-line.
define buffer buf_coeff_fbr-line    for ub.fbr-line.
define buffer buf_goods             for ub.goods.
define buffer buf_fbr-doc           for ub.fbr-doc.

do
for buf_fbr-recipe
  , buf_fbr-recipe-gds
  , buf_fbr-line
  , buf_coeff_fbr-line
  , buf_goods
  , buf_fbr-doc
on error undo, return error
:
    find first buf_fbr-line no-lock
         where buf_fbr-line.doc-code      = p-doc-code
           and buf_fbr-line.is-comp       = yes
           and buf_fbr-line.recipe-code   = p-recipe-code
    .
    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code      = p-doc-code
    .

    assign
        v-comp-qnty = buf_fbr-line.fact-qnty
        v-trn-type  = buf_fbr-line.trn-type
    .
    find first buf_fbr-recipe no-lock
         where buf_fbr-recipe.doc-code    = p-doc-code
           and buf_fbr-recipe.recipe-code = p-recipe-code
    .
    assign
    v-recipe-qnty = buf_fbr-recipe.qnty
    .
    do transaction
    on error undo, return error
    :
        for each buf_fbr-recipe-gds no-lock
           where buf_fbr-recipe-gds.doc-code      = p-doc-code
             and buf_fbr-recipe-gds.recipe-code   = p-recipe-code
        on error undo, return error
        :       /* Ищем добавленные в рецепт строки, создаем соответствующие строки в документе */
            find first buf_fbr-line no-lock
                 where buf_fbr-line.doc-code    = buf_fbr-recipe-gds.doc-code
                   and buf_fbr-line.recipe-code = buf_fbr-recipe-gds.recipe-code
                   and buf_fbr-line.prod-type   = buf_fbr-recipe-gds.prod-type
                   and buf_fbr-line.prod-code   = buf_fbr-recipe-gds.prod-code
                   and buf_fbr-line.artic       = buf_fbr-recipe-gds.artic
            no-error.
            if not available buf_fbr-line
            then do:
                find first buf_goods no-lock
                     where buf_goods.artic      = buf_fbr-recipe-gds.artic
                       and buf_goods.prod-type  = buf_fbr-recipe-gds.prod-type
                       and buf_goods.prod-code  = buf_fbr-recipe-gds.prod-code
                .
                run str/fbr-crln.p (
                      input parparentproc
                    , input recid( buf_fbr-doc )                    /* p-fbr-doc-recid  */
                    , input recid( buf_goods )                /* p-goods-recid    */
                    , input buf_fbr-recipe-gds.recipe-code    /* p-recipe-code    */
                    , input v-trn-type                        /* p-trn-type       */
                    , input no                                /* p-is-comp        */
                    , input no                                /* p-is-recursive   */
                    , input buf_fbr-doc.obj-type                    /* p-price-obj-type */
                    , input buf_fbr-doc.obj-code                    /* p-price-obj-code */
                    , output v-fbr-v-fbr-doc-line-recid                 /* p-fbr-v-fbr-doc-line-recid */
                ).
                find first buf_fbr-line no-lock
                     where buf_fbr-line.doc-code    = buf_fbr-recipe-gds.doc-code
                       and buf_fbr-line.recipe-code = buf_fbr-recipe-gds.recipe-code
                       and buf_fbr-line.prod-type   = buf_fbr-recipe-gds.prod-type
                       and buf_fbr-line.prod-code   = buf_fbr-recipe-gds.prod-code
                       and buf_fbr-line.artic       = buf_fbr-recipe-gds.artic
                no-error.
                if not available buf_fbr-line
                then do:
                    undo, return error substitute("Не удалось создать строку документа производства &1 &2&3&4"
                                                   , p-doc-code
                                                   , buf_fbr-recipe-gds.artic
                                                   , buf_fbr-recipe-gds.prod-type
                                                   , buf_fbr-recipe-gds.prod-code).
                end.
            end.
            find first buf_coeff_fbr-line exclusive-lock
                 where recid( buf_coeff_fbr-line ) = recid( buf_fbr-line )
            .
            if buf_coeff_fbr-line.calc-method <> buf_fbr-recipe-gds.calc-method
            or buf_coeff_fbr-line.coeff-value <> buf_fbr-recipe-gds.coeff-value
            or buf_coeff_fbr-line.coeff-waste <> buf_fbr-recipe-gds.coeff-waste
            then do:
                assign
                    buf_coeff_fbr-line.calc-method = buf_fbr-recipe-gds.calc-method
                    buf_coeff_fbr-line.coeff-value = buf_fbr-recipe-gds.coeff-value
                    buf_coeff_fbr-line.coeff-waste = buf_fbr-recipe-gds.coeff-waste
                .
            end.
        end.        /* for each buf_fbr-recipe-gds */
    end.        /* do transaction */
    define variable v-need-goods    as logical       no-undo.
    define variable v-need-goods-list       as character     no-undo.
    define variable v-need-goods-qnty-list  as character     no-undo.
    find first buf_fbr-line no-lock
         where buf_fbr-line.doc-code    = buf_fbr-doc.doc-code
           and buf_fbr-line.is-comp     = yes
           and buf_fbr-line.recipe-code = p-recipe-code
    .
    run str/fbr-qnty.p (
          input parparentproc
        , input p-fbrhist-handle
        , input recid( buf_fbr-doc )
        , input recid( buf_fbr-line )
        , input no
        , input "ingr"
        , input no
        , input p-price-sale-obj-type
        , input p-price-sale-obj-code
        , input no                          /* p-new-algorithm */
        , input no                          /* p-autofbr       */
        , input no                          /* p-have-store    */
        , output v-need-goods
        , output v-need-goods-list
        , output v-need-goods-qnty-list
    ).
end.
END PROCEDURE. /* fbrlib_adjust-doc-lines */

/*==========================================================================*/
procedure fbrlib_check-before-close :
define input parameter p-doc-code as character no-undo .
define variable same-sale as decimal no-undo .
define variable is-waste as logical no-undo .
define variable fix-price as logical no-undo .
define buffer buf_fbr-doc for ub.fbr-doc.
define buffer buf_fbr-line for ub.fbr-line.
define buffer buf_goods for ub.goods.
define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.
do
on error undo, return error
:
  /* проверяем наличие цен продажи по всем строчкам */
  for each buf_fbr-line no-lock
      where buf_fbr-line.doc-code = p-doc-code
    , each buf_goods no-lock
      where buf_goods.artic     = buf_fbr-line.artic
        and buf_goods.prod-type = buf_fbr-line.prod-type
        and buf_goods.prod-code = buf_fbr-line.prod-code
  break by buf_fbr-line.prod-type
        by buf_fbr-line.prod-code
        by buf_fbr-line.artic
  :
    if first-of (buf_fbr-line.artic)
    then do:        /* запоминаем цену очередного товара и отходы */
      assign
      same-sale = buf_fbr-line.price-sale
      is-waste = (buf_fbr-line.rsrv-qnty = ?)
      fix-price = buf_fbr-line.is-calc
      .
    end.
    if same-sale <> buf_fbr-line.price-sale
    then do:        /* проверяем цену каждого товара на совпадение с первой */
        undo, return error substitute("Док-нт пр-ва &1 Артикул: &2 &3&4&4Во всех строках документа с этим товаром должна быть указана одна и та же цена продажи."
                                      ,p-doc-code
                                      ,buf_goods.artic
                                      ,buf_goods.gds-name
                                      ,{&new-line}).
    end.
    if fix-price <> buf_fbr-line.is-calc then do:        /* проверяем цену каждого товара на фиксированность */
        undo, return error substitute("Док-нт пр-ва &1 Артикул: &2 &3&4&4Во всех строках документа с этим товаром цена должна быть фиксирована или нет."
                                      ,p-doc-code
                                      ,buf_goods.artic
                                      ,buf_goods.gds-name
                                      ,{&new-line}).
    end.
    if is-waste <> (buf_fbr-line.rsrv-qnty = ?)
    then do:        /* проверяем на отходы */
      undo, return error substitute("Док-нт пр-ва &1 Артикул: &2 &3&4&4Во всех строках документа этот товар должен быть отходом либо не отходом."
                                      ,p-doc-code
                                      ,buf_goods.artic
                                      ,buf_goods.gds-name
                                      ,{&new-line}).

    end.
    if buf_fbr-line.rsrv-qnty <> ?          /* для отхода цена не требуется */
    and buf_goods.gds-type <> {&gds-office} /* для услуги {&price} не требуется, т.к. прихода быть не может, а для {&write-off} можно без цены */
    and ( buf_fbr-line.price-sale <= 0 or buf_fbr-line.price-sale = ?  )
    and buf_fbr-line.fact-qnty <> 0
    then do:        /* недопустимая цена */
    /*Проверим, что товар не модификатор*/
      if buf_fbr-line.trn-type     = {&income}  then for first buf_fbr-doc where buf_fbr-doc.doc-code =  p-doc-code no-lock:
        if  can-find(first buf_fbr-gds-obj no-lock where
                buf_fbr-gds-obj.gds-code = buf_goods.gds-code
            AND buf_fbr-gds-obj.obj-type = buf_fbr-doc.obj-type
            AND buf_fbr-gds-obj.obj-code = buf_fbr-doc.obj-code
            and buf_fbr-gds-obj.is-null-price  )  then .
                  else undo, return error substitute("Док-нт пр-ва &1 Артикул: &2 &3&4Рецепт &5&4Неправильная (нулевая) цена продажи."
                                      ,p-doc-code
                                      ,buf_goods.artic
                                      ,buf_goods.gds-name
                                      ,{&new-line}
                                      ,buf_fbr-line.recipe-code
                                      ).


      end.
      else undo, return error substitute("Док-нт пр-ва &1 Артикул: &2 &3&4Рецепт &5&4Неправильная (нулевая) цена продажи."
                                      ,p-doc-code
                                      ,buf_goods.artic
                                      ,buf_goods.gds-name
                                      ,{&new-line}
                                      ,buf_fbr-line.recipe-code
                                      ).
    end.

  end.
end.
end procedure. /* fbrlib_check-before-close */
/* $Workfile$ e n d */