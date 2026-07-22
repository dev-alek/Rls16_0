block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: 2014/01/27 14:27:46 $
$Workfile: fbrplnst.p $
$Archive: str/fbrplnst.p $

Создание запроса на объекте для план-меню

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:
    p-fbr-pln-doc-code   as character - код план-меню
    p-kitchen-obj-code   as integer   - код объекта кухни
    p-fbr-doc-code       as character - код документа производства
Output:

*/

define  input parameter parparentproc        as widget-handle  no-undo.
define  input parameter p-fbrhist-handle     as widget-handle  no-undo.
define  input parameter p-fbrhist-upper-code as integer        no-undo.
define  input parameter p-fbr-pln-doc-code   as character      no-undo.
define  input parameter p-kitchen-obj-code   as integer        no-undo.
define  input parameter p-fbr-doc-code       as character      no-undo.
define output parameter p-doc-created        as logical        no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: 2014/01/27 14:27:46 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: fbrplnst.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/fbrplnst.p $":U .
define variable vss-description as character no-undo initial "Создание запроса на объекте для план-меню":U .

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ trg/partslib.i }
{ str/fbrrest.i  }
{ rep/fbrrep.i   }
{ str/doc-code.i }
{ gbl/cur-time.i }
{ str/fbrhist.i  }
{ str/trdcalib.i }
{ gbl/getcntxt.i def }

    define variable v-trn-doc-code              as character        no-undo.
    define variable v-free-qnty                 as decimal          no-undo.
    define variable v-need-qnty                 as decimal          no-undo.
    define variable v-store-obj-type            as character        no-undo.
    define variable v-store-obj-code            as integer          no-undo.
    define variable v-host-code                 as integer          no-undo.
    define variable v-host-name                 as character        no-undo.
    define variable v-base-code                 as integer          no-undo.
    define variable v-down-pay                  as integer          no-undo.
    define variable v-today                     as date             no-undo.
    define variable v-vat-pc                    as decimal          no-undo.
    define variable v-slt-pc                    as decimal          no-undo.
    define variable v-prt-root                  as integer          no-undo.
    define variable v-have-goods-for-inquiry    as logical          no-undo.
    define variable v-is-base                   as logical          no-undo .
    define variable v-fbrplnst-history-level    as integer          no-undo.
    define variable v-fbrplnst-hst-upper-code   as integer          no-undo.
    define variable v-upper-code                as integer          no-undo.
    define variable v-db-num                    as integer      no-undo.

    define buffer buf_fbr-pln       for fbr-pln.
    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_curr-accnt    for curr-accnt.
    define buffer buf_doc-line      for doc-line.
    define buffer buf_gds-dtl       for gds-dtl.
    define buffer buf_sysconf       for sysconf.
    define buffer buf_goods         for goods.

do
for buf_fbr-pln
  , buf_trn-doc
  , buf_curr-accnt
  , buf_doc-line
  , buf_gds-dtl
  , buf_sysconf
  , buf_goods
on error undo, return error
:
    { gbl/curdbnum.i
        v-db-num
    }
    { gbl/getcntxt.i get }
    run fbrrest-get-catering-object in this-procedure (
          input p-kitchen-obj-code
        , output v-store-obj-type
        , output v-store-obj-code
    ).
    if v-store-obj-type = {&shop}
    and v-store-obj-code = p-kitchen-obj-code
    then do:        /* Складом для кухни указана сама кухня. Запрос не создается.*/
        undo, return.
    end.
    run fbrrep-fill-qnty-and-prices in this-procedure (
        input p-fbr-doc-code
    ).
    assign
        v-have-goods-for-inquiry = no
    .
    for each temp_fbrrep-goods
    on error undo, return error
    :
        if temp_fbrrep-goods.is-not-office = yes
        and temp_fbrrep-goods.is-waste     = no
        and temp_fbrrep-goods.write-off-qnty > temp_fbrrep-goods.income-qnty
        then do:
            run fbrrest-get-free-qnty in this-procedure (
                  input {&shop}
                , input p-kitchen-obj-code
                , input temp_fbrrep-goods.gds-code
                , input yes
                , output v-free-qnty
            ).
            assign
                v-need-qnty = temp_fbrrep-goods.write-off-qnty - temp_fbrrep-goods.income-qnty - v-free-qnty
            .
            if v-need-qnty > 0
            then do:
                assign
                    v-have-goods-for-inquiry = yes
                .
            end.
        end.
    end.
    if v-have-goods-for-inquiry = no
    then do:
        undo, return.
    end.
    find first buf_fbr-pln no-lock
         where buf_fbr-pln.doc-code = p-fbr-pln-doc-code
    .
    run doc-code in this-procedure (
          input "main"
        , input v-store-obj-type
        , input v-store-obj-code
        , input ""
        , output v-trn-doc-code
    ).
    { gbl/hostcode.i
        v-store-obj-type
        v-store-obj-code
        v-host-code
    }
    find first buf_sysconf no-lock
         where buf_sysconf.host-code = v-host-code
    .
    { gbl/curobjdt.i
        v-store-obj-type
        v-store-obj-code
        v-today
    }
    { gbl/hostname.i
        v-store-obj-type
        v-store-obj-code
        v-host-code
        v-host-name
    }
    { gbl/basecode.i
        v-host-code
        v-base-code
    }
    find last buf_curr-accnt no-lock
        where buf_curr-accnt.curr-code = v-base-code
          and buf_curr-accnt.exch-date <= v-today
    use-index pi no-error.
    if not available buf_curr-accnt
    then do:
        message
            "На дату" v-today "неизвестен курс базовой валюты."
        view-as alert-box error.
        undo, return error.
    end.
    { gbl/objdnpay.i
        v-store-obj-type
        v-store-obj-code
        v-down-pay
    }
    { str/crtrndoc.i
        ?
        ?
        buf_curr-accnt.exch-rate
        buf_curr-accnt.exch-scale
        p-kitchen-obj-code
        {&shop}
        v-host-name
        g#db-num
        g#userid
        {&percent}
        v-trn-doc-code
        buf_fbr-pln.doc-date
        {&expense}
        no
        v-host-code
        yes
        v-store-obj-code
        v-store-obj-type
        no
        v-down-pay
        "' '"
        no
        "{&without-SLT}"
        {&inquiry}
        "{&inc-VAT}"
        {&TDEDT_Ras_Perem}
        {&bef-repayment-code}
        no-error
    }
    if error-status:error
    then do:
        message
            "Ошибка при создании складского документа."
        view-as alert-box error.
        if valid-handle( p-fbrhist-handle )
        then do:
            run fbrhist-write in p-fbrhist-handle (
                  input v-cntxt-userid
                , input v-store-obj-type
                , input v-store-obj-code
                , input {&fbrhist-type-create-doc}
                , input 2
                , input "str/fbrplnst.p"
                , input substitute( "fbr-pln-doc-code:&1,kitchen-obj-code:&2,fbr-doc-code:&3"
                                    , p-fbr-pln-doc-code
                                    , p-kitchen-obj-code
                                    , p-fbr-doc-code
                                )
                , input p-fbr-pln-doc-code
                , input {&plnmenu}
                , input {&g___new}
                , input no
                , input ""
                , input ""
                , input 0
                , input ""
                , input 0
                , input substitute( "Ошибка при создании запроса с номером &1. &2. &3"
                                    , v-trn-doc-code
                                    , return-value
                                    , trim(error-status :get-message(1))
                                    )
                , input yes
            ).
        end.        /* if valid-handle( p-fbrhist-handle ) */
        undo, return error.
    end.
    if valid-handle( p-fbrhist-handle )
    then do:
        run fbrhist-write in p-fbrhist-handle (
              input v-cntxt-userid
            , input v-store-obj-type
            , input v-store-obj-code
            , input {&fbrhist-type-create-doc}
            , input 2
            , input "str/fbrplnst.p"
            , input substitute( "fbr-pln-doc-code:&1,kitchen-obj-code:&2,fbr-doc-code:&3"
                                , p-fbr-pln-doc-code
                                , p-kitchen-obj-code
                                , p-fbr-doc-code
                                )
            , input p-fbr-pln-doc-code
            , input {&plnmenu}
            , input {&g___new}
            , input no
            , input ""
            , input ""
            , input 0
            , input ""
            , input 0
            , input substitute( "Создан запрос с номером &1 на объекте &2 &3."
                                , v-trn-doc-code
                                , v-store-obj-type
                                , v-store-obj-code
                                )
            , input no
        ).
    end.        /* if valid-handle( p-fbrhist-handle ) */
    { gbl/rbisbase.i
        v-is-base
    }
    find first buf_trn-doc exclusive-lock
         where buf_trn-doc.doc-code = v-trn-doc-code
    .
    assign
        buf_trn-doc.print-rubl  = ( if v-is-base = yes then no else yes )
        buf_trn-doc.exch-rate   = 1
        buf_trn-doc.exch-scale  = 1
        buf_trn-doc.exch-code   = 0
    .
    /* Документ внутреннего перемещения с другого объекта: не прописываются кладовщик, менеджер. Устанавливается атрибут fbrauto */
    { str/tdat-wrt.i
        buf_trn-doc.doc-code
        {&trdcattr-fbrauto}
        "'yes':U"
        no-error
    }
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Не удалось записать флаг автопроизводства"
            skip "в атрибут документа"
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box warning.
    end.
    for each temp_fbrrep-goods
    on error undo, return error
    :
        if temp_fbrrep-goods.is-not-office = yes
        and temp_fbrrep-goods.is-waste     = no
        and temp_fbrrep-goods.write-off-qnty > temp_fbrrep-goods.income-qnty
        then do:
            run fbrrest-get-free-qnty in this-procedure (
                  input {&shop}
                , input p-kitchen-obj-code
                , input temp_fbrrep-goods.gds-code
                , input yes
                , output v-free-qnty
            ).
            assign
                v-need-qnty = temp_fbrrep-goods.write-off-qnty - temp_fbrrep-goods.income-qnty - v-free-qnty
            .
            if v-need-qnty > 0
            then do:
                find first buf_goods no-lock
                     where buf_goods.gds-code = temp_fbrrep-goods.gds-code
                .
                if buf_sysconf.cons-vat-pc = ?
                then do:
                    message
                        "У Вас не установлен НДС для консигнационного товара по фирме."
                    view-as alert-box error.
                    undo, return error.
                end.
                { gbl/pftxvalg.i
                    buf_goods.gds-code
                    {&vat-tax-code}
                    ?
                    v-host-code
                    v-store-obj-type
                    v-store-obj-code
                    v-vat-pc
                }
                { str/st-sltpc.i
                    recid(buf_goods)
                    recid(buf_trn-doc)
                    buf_sysconf.cash-pay
                    v-slt-pc
                }
                { str/crdoclin.i
                    v-trn-doc-code
                    temp_fbrrep-goods.artic
                    temp_fbrrep-goods.prod-type
                    temp_fbrrep-goods.prod-code
                    v-store-obj-type
                    v-store-obj-code
                    {&inquiry}
                    {&TDEDT_Ras_Perem}
                    buf_goods.prt-root
                    v-vat-pc
                    v-slt-pc
                    buf_sysconf.cons-vat-pc
                }
                { gbl/termnode.i
                    buf_goods.prt-root
                    v-prt-root
                }
                { str/crgdsdtl.i
                    v-store-obj-code
                    v-store-obj-type
                    v-trn-doc-code
                    temp_fbrrep-goods.artic
                    temp_fbrrep-goods.prod-code
                    temp_fbrrep-goods.prod-type
                    v-prt-root
                    yes
                }
                find first buf_doc-line exclusive-lock
                     where buf_doc-line.doc-code    = v-trn-doc-code
                       and buf_doc-line.artic       = temp_fbrrep-goods.artic
                       and buf_doc-line.prod-type   = temp_fbrrep-goods.prod-type
                       and buf_doc-line.prod-code   = temp_fbrrep-goods.prod-code
                .
                find first buf_gds-dtl exclusive-lock
                     where buf_gds-dtl.doc-code    = v-trn-doc-code
                       and buf_gds-dtl.artic       = temp_fbrrep-goods.artic
                       and buf_gds-dtl.prod-type   = temp_fbrrep-goods.prod-type
                       and buf_gds-dtl.prod-code   = temp_fbrrep-goods.prod-code
                       and buf_gds-dtl.prt-code    = v-prt-root
                .
                { str/set-pr.i
                  recid(buf_gds-dtl)
                  no
                  ?
                  no-error }
                if error-status:error
                then do:
                    message
                        "Ошибка при назначении цены признака."
                        skip return-value
                    view-as alert-box error.
                end.
                assign
                    buf_doc-line.doc-qnty   = v-need-qnty
                    buf_doc-line.fact-qnty  = v-need-qnty
                    buf_gds-dtl.doc-qnty    = v-need-qnty
                    buf_gds-dtl.fact-qnty   = v-need-qnty
                .
                if valid-handle( p-fbrhist-handle )
                then do:
                    run fbrhist-write in p-fbrhist-handle (
                          input v-cntxt-userid
                        , input v-store-obj-type
                        , input v-store-obj-code
                        , input {&fbrhist-type-create-line}
                        , input 2
                        , input "str/fbrplnst.p"
                        , input substitute( "fbr-pln-doc-code:&1,kitchen-obj-code:&2,fbr-doc-code:&3"
                                            , p-fbr-pln-doc-code
                                            , p-kitchen-obj-code
                                            , p-fbr-doc-code
                                            )
                        , input p-fbr-pln-doc-code
                        , input {&plnmenu}
                        , input {&g___new}
                        , input no
                        , input ""
                        , input ""
                        , input temp_fbrrep-goods.gds-code
                        , input {&TDEDT_Ras_Perem}
                        , input v-need-qnty
                        , input substitute( "Создана строка запроса &1 на объекте &2 &3. Артикул: &4. Количество: &5."
                                            , v-trn-doc-code
                                            , v-store-obj-type
                                            , v-store-obj-code
                                            , temp_fbrrep-goods.artic
                                            , v-need-qnty
                                        )
                        , input no
                    ).
                end.        /* if valid-handle( p-fbrhist-handle ) */
            end.        /* if v-need-qnty > 0 */
/*            put*/
/*                skip*/
/*                temp_fbrrep-goods.artic format "X(17)"*/
/*                " " ( temp_fbrrep-goods.write-off-qnty - temp_fbrrep-goods.income-qnty )    format ">>>,>>>,>>>.999"*/
/*                " " ( if v-free-qnty - ( temp_fbrrep-goods.write-off-qnty - temp_fbrrep-goods.income-qnty ) < 0*/
/*                    then ( temp_fbrrep-goods.write-off-qnty - temp_fbrrep-goods.income-qnty ) - v-free-qnty*/
/*                    else 0 )                                                                format ">>>,>>>,>>>.999"*/
/*                "         " temp_fbrrep-goods.gds-name format "X(60)"*/
/*            .*/
        end.
    end.        /* for each temp_fbrrep-goods */
    find first buf_doc-line no-lock
         where buf_doc-line.doc-code    = v-trn-doc-code
    no-error.
    if not available buf_doc-line
    then do:
        delete buf_trn-doc.
        assign
            p-doc-created = yes
        .
        if valid-handle( p-fbrhist-handle )
        then do:
            run fbrhist-write in p-fbrhist-handle (
                  input v-cntxt-userid
                , input v-store-obj-type
                , input v-store-obj-code
                , input {&fbrhist-type-create-line}
                , input 2
                , input "str/fbrplnst.p"
                , input substitute( "fbr-pln-doc-code:&1,kitchen-obj-code:&2,fbr-doc-code:&3"
                                    , p-fbr-pln-doc-code
                                    , p-kitchen-obj-code
                                    , p-fbr-doc-code
                                    )
                , input p-fbr-pln-doc-code
                , input {&plnmenu}
                , input {&g___new}
                , input no
                , input ""
                , input ""
                , input 0
                , input ""
                , input 0
                , input substitute( "В документе нет строк. Запрос &1 удален."
                                    , v-trn-doc-code
                                )
                , input no
            ).
        end.        /* if valid-handle( p-fbrhist-handle ) */
    end.        /* if not available buf_doc-line */
    else do:
        assign
            buf_trn-doc.out-code = p-fbr-doc-code
        .
        run gbl/calc-trn.p (
            input parparentproc
          , input recid( buf_trn-doc )
        ).
        assign
            p-doc-created = yes
        .
    end.        /* if available buf_doc-line */
end.