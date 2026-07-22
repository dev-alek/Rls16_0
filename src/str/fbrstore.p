block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fbrstore.p $
$Archive: str/fbrstore.p $

Создание документа внутреннего перемещения для ингредиентов со склада на кухню ресторана

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:
    parparentproc    as widget-handle   - mainmenu handle
    p-fbr-doc-code   as character       - номер документа производства
    p-store-rest     as logical         - учитывать остатки товара на кухне ( остаток = остаток на кухне + остаток на складе)

Output:

*/

define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-fbrhist-handle as widget-handle    no-undo.
define input parameter p-fbr-doc-code   as character        no-undo.
define input parameter p-store-rest     as logical          no-undo.


define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: fbrstore.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/fbrstore.p $":U .
define variable vss-description as character no-undo initial "Создание документа внутреннего перемещения для ингредиентов со склада на кухню ресторана":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ trg/partslib.i }
{ str/fbrrest.i  }
{ rep/fbrrep.i   }
{ cmp/strcodec.i }
{ str/fbrrsrv.i  }
{ str/doc-code.i }
{ gbl/cur-time.i }
{ cmp/gds-list.i temp_gds-list def }
{ str/trdcalib.i }
/* НЕ ВСТАВЛЯТЬ g e t c n t x t . i  - файл вызывается в автомат режиме*/

    define variable v-store-obj-type    as character      no-undo.
    define variable v-store-obj-code    as integer        no-undo.
    define variable v-trn-doc-code      as character      no-undo.
    define variable v-today             as date           no-undo.
    define variable v-time              as integer        no-undo.
    define variable v-host-code         as integer        no-undo.
    define variable v-base-code         as integer        no-undo.
    define variable v-host-name         as character      no-undo.
    define variable v-down-pay          as integer        no-undo.
    define variable v-store-free-qnty   as decimal        no-undo.
    define variable v-kitchen-free-qnty as decimal        no-undo.
    define variable v-cntxt-db-num as integer no-undo .
    define variable v-cntxt-userid as character no-undo .

    define variable v-sum-base          as decimal        no-undo.
    define variable v-sum-rubl          as decimal        no-undo.
    define variable v-sum-vat-base      as decimal        no-undo.
    define variable v-sum-vat-rubl      as decimal        no-undo.
    define variable v-rb-is-base        as logical        no-undo.

    define buffer buf_fbr-doc           for fbr-doc.
    define buffer buf_fbr-line          for fbr-line.
    define buffer buf_curr-accnt        for curr-accnt.
    define buffer buf_trn-doc           for trn-doc.
    define buffer buf_income_trn-doc    for trn-doc.
    define buffer buf_doc-line          for doc-line.
    define buffer buf_shop              for shop.

do
for buf_fbr-doc
  , buf_fbr-line
  , buf_curr-accnt
  , buf_trn-doc
  , buf_income_trn-doc
  , buf_doc-line
  , buf_shop
on error undo, return error
:
    run get-db-num in parparentproc ( output v-cntxt-db-num).
    run get-userid in parparentproc ( output v-cntxt-userid).
    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = p-fbr-doc-code
    .
    run fbrrest-get-catering-object in this-procedure (
          input buf_fbr-doc.obj-code
        , output v-store-obj-type
        , output v-store-obj-code
    ).
    IF v-store-obj-type = ""
    OR v-store-obj-code = 0
    THEN DO:
        message
             "Невозможно зарезервировать товар:"
        skip "Не задан склад-подсобка для ресторана."
        view-as alert-box error.
        undo, return error .
    END.

    if v-store-obj-type  = buf_fbr-doc.obj-type
    and v-store-obj-code = buf_fbr-doc.obj-code
    then do:        /* Кухня и склад - один и тот же объект */
        undo, return.
    end.
    { gbl/rbisbase.i
        v-rb-is-base
    }
    output to "fbrgoods.log".
        put
            "Товары, которые надо переместить на кухню ("
            buf_fbr-doc.obj-type
            buf_fbr-doc.obj-code
            ") со склада ("
            v-store-obj-type format "X(3)"
            v-store-obj-code
            ")"
            skip(1)
            skip
            "     Артикул    |    Количество   | Не хватает на складе |"
            "     Наименование "
            skip
            "     Артикул    | для перемещения | "
            v-store-obj-type
            v-store-obj-code
            skip
            fill( "-", 160 )  format "X(160)"
        .
    output close.
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
        buf_fbr-doc.obj-code
        buf_fbr-doc.obj-type
        v-host-name
        v-cntxt-db-num
        v-cntxt-userid
        {&percent}
        v-trn-doc-code
        buf_fbr-doc.doc-date
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
        {&wayb}
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
        undo, return error.
    end.
    find first buf_trn-doc exclusive-lock
         where buf_trn-doc.doc-code = v-trn-doc-code
    .
    assign
/*        buf_trn-doc.out-code    = v-trn-doc-code*/
        buf_trn-doc.print-rubl  = ( if v-rb-is-base = yes then no else yes )
        buf_trn-doc.exch-rate   = 1
        buf_trn-doc.exch-scale  = 1
        buf_trn-doc.exch-code   = 0
        buf_trn-doc.exch-date   = v-today
        buf_trn-doc.out-code    = p-fbr-doc-code
        /* agnt boss wrkr */
        /* cst-code discnt-pc discnt-rubl doc-qnty fact-base fact-date fact-num fact-qnty fact-rubl inv-num ord-num out-code ov PS ship-date ship-num SLT-base SLT-rubl tot-calc tot-cli tot-doc tot-fact tot-lines tot-ov tot-rubl tot-sale VAT-base VAT-rubl VAT-type */
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
    run fbrrep-fill-qnty-and-prices in this-procedure (
        input p-fbr-doc-code
    ).
    output to "fbrgoods.log" append.
    put
        skip(1)
    .
    for each temp_fbrrep-goods
    on error undo, return error
    :
        if p-store-rest = yes
        then do:
            run fbrrest-get-free-qnty in this-procedure (
                  input buf_fbr-doc.obj-type
                , input buf_fbr-doc.obj-code
                , input temp_fbrrep-goods.gds-code
                , input yes
                , output v-kitchen-free-qnty
            ).
        end.
        else do:
            assign
                v-kitchen-free-qnty = 0
            .
        end.
        if temp_fbrrep-goods.is-not-office = yes
        and temp_fbrrep-goods.is-waste     = no
        and temp_fbrrep-goods.write-off-qnty - temp_fbrrep-goods.income-qnty - v-kitchen-free-qnty > 0
        then do:
            run fbrrest-get-free-qnty in this-procedure (
                  input v-store-obj-type
                , input v-store-obj-code
                , input temp_fbrrep-goods.gds-code
                , input yes
                , output v-store-free-qnty
            ).
            put
                skip
                temp_fbrrep-goods.artic format "X(17)"
                " " ( temp_fbrrep-goods.write-off-qnty - temp_fbrrep-goods.income-qnty - v-kitchen-free-qnty )    format ">>>,>>>,>>>.999"
                " " ( if v-store-free-qnty - ( temp_fbrrep-goods.write-off-qnty - temp_fbrrep-goods.income-qnty - v-kitchen-free-qnty ) < 0
                    then ( temp_fbrrep-goods.write-off-qnty - temp_fbrrep-goods.income-qnty - v-kitchen-free-qnty ) - v-store-free-qnty
                    else 0 )                                                                format ">>>,>>>,>>>.999"
                "         " temp_fbrrep-goods.gds-name format "X(60)"
            .
        end.
    end.
    output close.
    define variable v-was-gds-moving    as logical        no-undo.
    assign
        v-was-gds-moving = no
    .
    for each temp_fbrrep-goods
    on error undo, return error
    :
        if p-store-rest = yes
        then do:
            run fbrrest-get-free-qnty in this-procedure (
                  input buf_fbr-doc.obj-type
                , input buf_fbr-doc.obj-code
                , input temp_fbrrep-goods.gds-code
                , input yes
                , output v-kitchen-free-qnty
            ).
        end.
        else do:
            assign
                v-kitchen-free-qnty = 0
            .
        end.
        if temp_fbrrep-goods.is-not-office = yes
        and temp_fbrrep-goods.is-waste     = no
        and temp_fbrrep-goods.write-off-qnty - temp_fbrrep-goods.income-qnty - v-kitchen-free-qnty > 0
        then do:
            run create-doc-line in this-procedure (
                  input buf_trn-doc.doc-code
                , input temp_fbrrep-goods.gds-code
                , input temp_fbrrep-goods.write-off-qnty - temp_fbrrep-goods.income-qnty - v-kitchen-free-qnty
                , output v-sum-base
                , output v-sum-rubl
                , output v-sum-vat-base
                , output v-sum-vat-rubl
            ).
            if v-sum-base       = ?
            or v-sum-rubl       = ?
            or v-sum-vat-base   = ?
            or v-sum-vat-rubl   = ?
            or v-sum-base       = 0
            or v-sum-rubl       = 0
            or v-sum-vat-base   = 0
            or v-sum-vat-rubl   = 0
            then do:
                message
                    skip "Не удалось определить учетную цену"
                    skip "товара на объекте."
                    skip (1)
                    skip "Товар: " temp_fbrrep-goods.artic temp_fbrrep-goods.gds-name
                    skip "Объект: " buf_trn-doc.obj-type buf_trn-doc.obj-code
                view-as alert-box error.
                undo, return error .
            end.
            assign
                v-was-gds-moving = yes
            .
        end.
    end.        /* for each temp_fbrrep-goods */
    if v-was-gds-moving = no
    then do:        /* В документе нет строк. Нет необходимости обрабатывать */
        delete buf_trn-doc.
    end.        /* if v-was-gds-moving = no */
    else do:
        run str/trn-stat.p  (
            input parparentproc             /* parparentproc  */
            , input this-procedure
            , input {&close-doc}              /* parmode        */
            , input buf_trn-doc.doc-code      /* pardoc-code    */
            , input no                        /* parcheck-return*/
            , input v-cntxt-db-num                  /* pardb-num      */
            , input no                        /* parin-ov       */
            , input 0                         /* parrsrv-time   */
            , input 0                         /* parload-time   */
            , input ""                        /* parholidays    */
            , input yes                       /* parmessage     */
            , output v-was-gds-moving         /* parchg-inv     */
            , output table temp_gds-list  /* table for gds-list*/
        ) no-error.
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip "Ошибка при закрытии документа внутреннего перемещения."
                skip(1)
                skip "Объект:" buf_trn-doc.obj-type buf_trn-doc.obj-code
                skip "Документ номер:" buf_trn-doc.doc-code
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
        run str/trn-stat.p  (
            input parparentproc             /* parparentproc  */
            , input this-procedure
            , input {&close-doc}              /* parmode        */
            , input buf_trn-doc.doc-code      /* pardoc-code    */
            , input no                        /* parcheck-return*/
            , input v-cntxt-db-num                  /* pardb-num      */
            , input no                        /* parin-ov       */
            , input 0                         /* parrsrv-time   */
            , input 0                         /* parload-time   */
            , input ""                        /* parholidays    */
            , input yes                       /* parmessage     */
            , output v-was-gds-moving         /* parchg-inv     */
            , output table temp_gds-list  /* table for gds-list*/
        ) no-error.
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip "Ошибка при закрытии документа внутреннего перемещения."
                skip(1)
                skip "Объект:" buf_trn-doc.obj-type buf_trn-doc.obj-code
                skip "Документ номер:" buf_trn-doc.doc-code
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
        run str/trn-stat.p  (
            input parparentproc             /* parparentproc  */
            , input this-procedure
            , input {&close-doc}              /* parmode        */
            , input buf_trn-doc.doc-code      /* pardoc-code    */
            , input no                        /* parcheck-return*/
            , input v-cntxt-db-num                  /* pardb-num      */
            , input no                        /* parin-ov       */
            , input 0                         /* parrsrv-time   */
            , input 0                         /* parload-time   */
            , input ""                        /* parholidays    */
            , input yes                       /* parmessage     */
            , output v-was-gds-moving         /* parchg-inv     */
            , output table temp_gds-list  /* table for gds-list*/
        ) no-error.
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip "Ошибка при закрытии документа внутреннего перемещения."
                skip(1)
                skip "Объект:" buf_trn-doc.obj-type buf_trn-doc.obj-code
                skip "Документ номер:" buf_trn-doc.doc-code
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
        assign
            v-trn-doc-code = buf_trn-doc.doc-code
        .
        release buf_trn-doc.
        find first buf_income_trn-doc no-lock
            where buf_income_trn-doc.out-code = v-trn-doc-code
        .
        run str/trn-stat.p  (
            input parparentproc               /* parparentproc  */
            , input this-procedure
            , input {&close-doc}                /* parmode        */
            , input buf_income_trn-doc.doc-code /* pardoc-code    */
            , input no                          /* parcheck-return*/
            , input v-cntxt-db-num                    /* pardb-num      */
            , input no                          /* parin-ov       */
            , input 0                           /* parrsrv-time   */
            , input 0                           /* parload-time   */
            , input ""                          /* parholidays    */
            , input yes                         /* parmessage     */
            , output v-was-gds-moving           /* parchg-inv     */
            , output table temp_gds-list        /* table for gds-list*/
        ) no-error.
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip "Ошибка при закрытии документа внутреннего перемещения."
                skip(1)
                skip "Объект:" buf_income_trn-doc.obj-type buf_income_trn-doc.obj-code
                skip "Документ номер:" buf_income_trn-doc.doc-code
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
    end.        /* if v-was-gds-moving = yes */
end.


/*==========================================================================*/
procedure create-doc-line :
define input parameter p-doc-code       as character    no-undo.
define input parameter p-gds-code       as integer      no-undo.
define input parameter p-qnty           as decimal      no-undo.
define output parameter p-sum-base      as decimal      no-undo .
define output parameter p-sum-rubl      as decimal      no-undo .
define output parameter p-sum-vat-base  as decimal      no-undo .
define output parameter p-sum-vat-rubl  as decimal      no-undo .

    define variable v-required-qnty     as decimal        no-undo.
    define variable v-reserved-qnty     as decimal        no-undo.
    define variable v-today             as date           no-undo.
    define variable v-time              as integer        no-undo.
    define variable v-sum-base          as decimal        no-undo.
    define variable v-sum-rubl          as decimal        no-undo.
    define variable v-vat-base          as decimal        no-undo.
    define variable v-vat-rubl          as decimal        no-undo.
    define variable v-vat-pc            as decimal        no-undo.
    define variable v-host-code         as integer        no-undo.

    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_doc-line      for doc-line.
    define buffer buf_goods         for goods.
    define buffer buf_gds-dtl       for gds-dtl.
    define buffer buf_gds-prt       for gds-prt.
do
for buf_trn-doc
  , buf_doc-line
  , buf_goods
  , buf_gds-dtl
  , buf_gds-prt
on error undo, return error
:
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
    .
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    create buf_doc-line.
    assign
        buf_doc-line.artic         = buf_goods.artic
        buf_doc-line.prod-type     = buf_goods.prod-type
        buf_doc-line.prod-code     = buf_goods.prod-code
        buf_doc-line.obj-type      = buf_trn-doc.obj-type
        buf_doc-line.obj-code      = buf_trn-doc.obj-code
        buf_doc-line.doc-code      = buf_trn-doc.doc-code
        buf_doc-line.prt-ok        = yes
        buf_doc-line.prt-root      = buf_goods.prt-root
        buf_doc-line.status_       = buf_trn-doc.status_
        buf_doc-line.doc-qnty      = 0
        buf_doc-line.cli-base-rate = 1
        v-required-qnty            = round( p-qnty, 3 )
        v-reserved-qnty            = 0
    .
    run fbrrsrv-rsrv-goods in this-procedure (
          input parparentproc
        , input recid( buf_goods )
        , input recid( buf_doc-line )
        , input v-required-qnty
        , input no
        , input 0
        , input no
        , input ""
        , output v-reserved-qnty
    ) no-error.
    if error-status :error
    then do:
        if error-status :get-message(1) <> ""
        or return-value <> "user-interrupt":U
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка резервирования товара."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
            view-as alert-box error.
        end.
        undo, return error return-value.
    end.
    if v-required-qnty <> v-reserved-qnty
    then do:
        message
        "Невозможно зарезервировать товар."
        skip(1)
        skip "Товар:" buf_goods.artic buf_goods.gds-name
        skip "Объект:" buf_trn-doc.obj-type buf_trn-doc.obj-code
        skip "Количество:" v-required-qnty
        skip "Доступно количество:" v-reserved-qnty
        view-as alert-box error.
        undo, return error .
    end.
    run str/fbrcost.p (
          input recid( buf_doc-line )
        , input -1
        , input v-required-qnty
        , output v-sum-base
        , output v-sum-rubl
        , output v-vat-base
        , output v-vat-rubl
        , output v-vat-pc
      ) .
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    { gbl/hostcode.i
        buf_trn-doc.obj-type
        buf_trn-doc.obj-code
        v-host-code
    }
    { gbl/pftxvalg.i
        buf_goods.gds-code
        {&vat-tax-code}
        ?
        v-host-code
        buf_trn-doc.obj-type
        buf_trn-doc.obj-code
        v-vat-pc
    }
    find first buf_gds-prt no-lock
         where buf_gds-prt.upper-code = buf_goods.prt-root
    .
    find first buf_gds-dtl exclusive-lock
         where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
           and buf_gds-dtl.artic     = buf_goods.artic
           and buf_gds-dtl.prod-type = buf_goods.prod-type
           and buf_gds-dtl.prod-code = buf_goods.prod-code
           and buf_gds-dtl.prt-code  = buf_gds-prt.node-code
    .
    assign
        buf_doc-line.doc-qnty   = v-reserved-qnty
        buf_doc-line.fact-qnty  = v-reserved-qnty
        buf_gds-dtl.doc-qnty    = v-reserved-qnty
        buf_gds-dtl.fact-qnty   = v-reserved-qnty
        p-sum-base              = v-sum-base - v-vat-base
        p-sum-rubl              = v-sum-rubl - v-vat-rubl
        p-sum-vat-base          = v-vat-base
        p-sum-vat-rubl          = v-vat-rubl
    .
    assign      /* накладная заполняется как р_ублевая */
        buf_doc-line.price-cli  = v-sum-rubl / v-reserved-qnty
        buf_doc-line.price-base = v-sum-base / v-reserved-qnty
        buf_doc-line.price-rubl = v-sum-rubl / v-reserved-qnty
        buf_doc-line.VAT-pc     = v-vat-pc
    .
end.
end procedure. /* create-doc-line */