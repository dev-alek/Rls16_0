block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fbr-trn.p $
$Archive: str/fbr-trn.p $

Создание, заполнение и резервирование шапки ПН или НС

Автор: Хныкин Павел Андреевич
Дата создания: 02/17/09
Author: Pavel Khnykin
Creation date: 02/17/09

trn-doc - тот документ, который заполняется сейчас, в этой процедуре.
При заполнении НС он может заполняться либо из документа производства,
либо из другой НС, если она есть. Есть она в том случае, если мы сейчас заполняем НС услуг,
а раньше, для других строчек, для товаров, или наоборот.
Что будет первым, неизвестно.

*/

define input parameter p-doc-type           as character                no-undo.  /* тип накладной */
define input parameter p-fbr-doc-doc-code   as character                no-undo.
define input parameter p-gds-code           as integer                  no-undo.
define output parameter p-trn-doc-doc-code  as character                no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: fbr-trn.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/fbr-trn.p $":U .
define variable vss-description as character no-undo init "Создание, заполнение и резервирование шапки ПН или НС".

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ str/lib-trn.i  }
{ str/doc-code.i }
{ str/trdcalib.i }
{ str/fbrattr.i  }

define variable v-main-trn-doc-code like trn-doc.doc-code   no-undo.    /* номер заполняемой НС или ПН */
define variable v-trio-trn-doc-code like trn-doc.out-code   no-undo.    /* номер НС для копирования */
define variable v-today             as date                 no-undo.
define variable v-ext-doc-type      as character            no-undo.
define variable v-host-code         as integer              no-undo.
define variable v-host-name         as character            no-undo.
define variable v-pay-code          as integer              no-undo.
define variable v-base-code         as integer              no-undo.
define variable v-rb-is-base        as logical      no-undo.
define variable v-db-num            as integer      no-undo.
define variable v-operator-code     as integer          no-undo.

define buffer buf_out_trn-doc   for trn-doc.                         /* НС для копирования */
define buffer buf_trn-doc       for trn-doc.
define buffer buf_fbr-doc       for fbr-doc.
define buffer buf_goods         for goods.

rsrv:
do
for buf_out_trn-doc
  , buf_trn-doc
  , buf_fbr-doc
  , buf_goods
on error undo rsrv, return error
:
    { gbl/curdbnum.i
        v-db-num
    }
    { gbl/rbisbase.i
        v-rb-is-base
    }
    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = p-fbr-doc-doc-code
    .
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    /* вычисление номера заполняемой НС (v-main-trn-doc-code) и номера парной НС для товаров или услуг (v-trio-trn-doc-code)
        любой из них может и не быть
        при заполнении ПН v-trio-trn-doc-code не важен
    */
    if p-doc-type = {&income}
    then do:        /* вычисление номера ПН - с "=" */
        run doc-code in this-procedure (
              input "pair"
            , input buf_fbr-doc.obj-type
            , input buf_fbr-doc.obj-code
            , input buf_fbr-doc.doc-code
            , output v-main-trn-doc-code
        ) no-error.
        if error-status:error
        then do:
            undo, return error substitute ( "Ошибка при генерации номера документа прихода (pair). &1. &2. &3.", return-value, trim( error-status :get-message( 1 ) ), trim( error-status :get-message( 2 ) ) ).
        end.
    end.
    else do:
        if buf_goods.gds-type = {&gds-office}
        then do:        /* вычисление номера НС для услуг - с "*". v-trio-trn-doc-code - номер накладной списания для товаров */
            run doc-code in this-procedure (
                  input  "trio-m"
                , input  buf_fbr-doc.obj-type
                , input  buf_fbr-doc.obj-code
                , input  buf_fbr-doc.doc-code
                , output v-main-trn-doc-code
            ) no-error.
            if error-status:error
            then do:
                undo, return error substitute ( "Ошибка при генерации номера документа для услуг (trio). &1. &2. &3.", return-value, trim( error-status :get-message( 1 ) ), trim( error-status :get-message( 2 ) ) ).
            end.
            assign
                v-trio-trn-doc-code = buf_fbr-doc.doc-code
            .
        end.
        else do:        /* номер накладной списания для товаров совпадает с номером документа производства. v-trio-trn-doc-code - номер накладной списания для услуг */
            assign
                v-main-trn-doc-code = buf_fbr-doc.doc-code
            .
            run doc-code in this-procedure (
                  input  "trio-m":U
                , input  buf_fbr-doc.obj-type
                , input  buf_fbr-doc.obj-code
                , input  buf_fbr-doc.doc-code
                , output v-trio-trn-doc-code
            ) no-error.
            if error-status:error
            then do:
                undo, return error substitute ( "Ошибка при генерации номера документа (trio). &1. &2. &3.", return-value, trim( error-status :get-message( 1 ) ), trim( error-status :get-message( 2 ) ) ).
            end.
        end.
    end.
    find first buf_trn-doc          /* заполняемая НС или ПН */
         where buf_trn-doc.doc-code = v-main-trn-doc-code
    no-error.
    find first buf_out_trn-doc          /* парная НС - товары или услуги */
         where buf_out_trn-doc.doc-code = v-trio-trn-doc-code
    no-error.
    if not available buf_trn-doc
    then do:
        { gbl/curobjdt.i
            buf_fbr-doc.obj-type
            buf_fbr-doc.obj-code
            v-today
        }
        { gbl/hostname.i
            buf_fbr-doc.obj-type
            buf_fbr-doc.obj-code
            v-host-code
            v-host-name
        }
        { gbl/basecode.i
            v-host-code
            v-base-code
        }
        find last curr-accnt no-lock
            where curr-accnt.curr-code = v-base-code
              and curr-accnt.exch-date <= v-today
        use-index pi no-error.
        if not available curr-accnt
        then do:
            message
                "На дату" v-today "неизвестен курс базовой валюты."
            view-as alert-box error.
            { gbl/stopwork.i }
            undo rsrv, return error.
        end.
        case p-doc-type:
            when {&income}
            then do:
                assign
                    v-ext-doc-type = {&TDEDT_Pri_Prvo}
                .
            end.
            when {&write-off}
            then do:
                assign
                    v-ext-doc-type = {&TDEDT_Spi_Prvo}
                .
            end.
        end case.
        assign
            v-pay-code = buf_fbr-doc.pay-code
        .
        if v-pay-code = ?
        or v-pay-code = 0
        then do:
            { gbl/objdnpay.i
                buf_fbr-doc.obj-type
                buf_fbr-doc.obj-code
                v-pay-code
            }
        end.
        { str/crtrndoc.i
            ?
            ?
            "(if available buf_out_trn-doc then buf_out_trn-doc.base-rate  else curr-accnt.exch-rate)"
            "(if available buf_out_trn-doc then buf_out_trn-doc.base-scale else curr-accnt.exch-scale)"
            v-host-code
            {&cmp}
            v-host-name
            g#db-num
            g#userid
            {&manufactured}
            v-main-trn-doc-code
            buf_fbr-doc.doc-date
            p-doc-type
            no
            buf_fbr-doc.host-code
            yes
            buf_fbr-doc.obj-code
            buf_fbr-doc.obj-type
            "(buf_goods.gds-type = {&gds-office})"
            "(if available buf_out_trn-doc then buf_out_trn-doc.pay-code else v-pay-code)"
            "' '"
            no
            "{&without-SLT}"
            {&manufactured}
            "{&inc-VAT}"
            v-ext-doc-type
            {&bef-repayment-code}
            no-error
        }
        if error-status:error
        then do:
            message
                "Ошибка при создании складского документа."
            view-as alert-box error.
            { gbl/stopwork.i }
            undo rsrv, return error.
        end.
        find first buf_trn-doc exclusive-lock
             where buf_trn-doc.doc-code = v-main-trn-doc-code
        .
        assign
            buf_trn-doc.out-code    = buf_fbr-doc.doc-code
            buf_trn-doc.print-rubl  = ( if v-rb-is-base = yes then no else yes )
            buf_trn-doc.exch-rate   = 1
            buf_trn-doc.exch-scale  = 1
            buf_trn-doc.exch-code   = 0
            /* agnt boss wrkr */
            /* cst-code discnt-pc discnt-rubl doc-qnty fact-base fact-date fact-num fact-qnty fact-rubl inv-num ord-num out-code ov PS ship-date ship-num SLT-base SLT-rubl tot-calc tot-cli tot-doc tot-fact tot-lines tot-ov tot-rubl tot-sale VAT-base VAT-rubl VAT-type */
        .
        run get-fbroperator in this-procedure (
              input p-fbr-doc-doc-code
            , output buf_trn-doc.agnt
            , output buf_trn-doc.boss
            , output buf_trn-doc.wrkr
        ).
        if available buf_out_trn-doc
        then do:
            assign
                buf_trn-doc.exch-date  = buf_out_trn-doc.exch-date
            .
        end.
        else do:
            assign
                buf_trn-doc.exch-date  = v-today
            .
        end.
    end.
    assign
        p-trn-doc-doc-code = buf_trn-doc.doc-code
    .
end.


/*==========================================================================*/
procedure get-fbroperator :
define input parameter p-fbr-doc-code   as character        no-undo.
define output parameter p-agnt          as integer          no-undo.
define output parameter p-boss          as integer          no-undo.
define output parameter p-wrkr          as integer          no-undo.

    define variable v-agntbosswrkr      as character    no-undo.
    define variable v-operator-code     as integer      no-undo.
    define variable v-operator-string   as integer      no-undo.

    define buffer buf_clients       for clients.
do
for buf_clients
on error undo, return error
:
    assign
        v-operator-code = 0
    .
    run fbrattr-value in this-procedure (
        input {&fbrattr-type-fbr-doc}
        , input p-fbr-doc-code
        , input {&trdcattr-fbroperator}
        , output v-operator-string
    ) no-error.
    if not error-status :error
    then do:
        assign
            v-operator-code = integer( v-operator-string )
        no-error.
        if error-status :error
        then do:
            assign
                v-operator-code = 0
            .
        end.
        else do:
            find first buf_clients no-lock
                where buf_clients.obj-type = {&prs}
                and buf_clients.obj-code = v-operator-code
            no-error.
            if not available buf_clients
            then do:
                assign
                    v-operator-code = 0
                .
            end.
        end.
    end.
    if v-operator-code > 0
    then do:
        assign
            p-agnt = v-operator-code
            p-boss = v-operator-code
            p-wrkr = v-operator-code
        .
    end.
end.
end procedure. /* get-fbroperator */