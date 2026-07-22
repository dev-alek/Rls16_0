block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fbr2sale.p $
$Archive: str/fbr2sale.p $

Создание документа внутреннего перемещения для блюд с кухни в ресторан

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:
    parparentproc    as widget-handle - handle вызывающей процедуры
    p-kitchen-type   as character
    p-kitchen-code   as integer       - объект кухня.
    p-res-type       as character
    p-res-code       as integer       - объект ресторан
    p-income-trn-doc-code   as character     - код приходной накладной, из которой надо резервировать партии
    p-sale-doc-code  as character     - код документа продажи

Output:

*/

define input parameter parparentproc        as widget-handle    no-undo.
define input parameter p-fbrhist-handle     as widget-handle    no-undo.
define input parameter p-kitchen-type       as character        no-undo.
define input parameter p-kitchen-code       as integer          no-undo.
define input parameter p-res-type           as character        no-undo.
define input parameter p-res-code           as integer          no-undo.
define input parameter p-income-trn-doc-code as character       no-undo.
define input parameter p-sale-doc-code      as character        no-undo.
define input parameter p-kitchen-rest       as logical          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fbr2sale.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/fbr2sale.p $":U .
define variable vss-description as character no-undo init "Создание документа внутреннего перемещения для блюд с кухни в ресторан".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/doc-code.i }
{ gbl/cur-time.i }
{ cmp/gds-list.i temp_gds-list def }
{ cmp/strcodec.i }
{ str/fbrrsrv.i  }
{ trg/partslib.i }
{ str/fbrrest.i  }
{ str/trdcalib.i }
/*НЕ МЕНЯТЬ НА g e t c n t x t . i def!!!! процедра вызывается в автомате а g e t c n t x t . i get там не работает!!!*/
define variable v-cntxt-db-num as integer no-undo .
define variable v-cntxt-userid as character no-undo .

    define variable v-trn-doc-code          as character    no-undo.
    define variable v-trn-doc-wrkr          as integer      no-undo.
    define variable v-trn-doc-boss          as integer      no-undo.
    define variable v-trn-doc-agnt          as integer      no-undo.
    define variable v-today                 as date         no-undo.
    define variable v-time                  as integer      no-undo.
    define variable v-host-code             as integer      no-undo.
    define variable v-base-code             as integer      no-undo.
    define variable v-host-name             as character    no-undo.
    define variable v-down-pay              as integer      no-undo.

    define variable v-sum-base              as decimal      no-undo.
    define variable v-sum-rubl              as decimal      no-undo.
    define variable v-sum-vat-base          as decimal      no-undo.
    define variable v-sum-vat-rubl          as decimal      no-undo.
    define variable v-goods-is-not-office   as logical      no-undo.
    define variable v-restaurant-free-qnty  as decimal      no-undo.
    define variable v-need-qnty             as decimal      no-undo.
    define variable v-rb-is-base            as logical      no-undo.

    define buffer buf_goods             for goods.
    define buffer buf_doc-fbr-gds       for doc-fbr-gds.
    define buffer buf_curr-accnt        for curr-accnt.
    define buffer buf_trn-doc           for trn-doc.
    define buffer buf_sale_trn-doc      for trn-doc.
    define buffer buf_income_trn-doc    for trn-doc.
    define buffer buf_sale-doc          for ub.sale-doc.
do
for buf_goods
  , buf_doc-fbr-gds
  , buf_curr-accnt
  , buf_trn-doc
  , buf_sale_trn-doc
  , buf_income_trn-doc
  , buf_sale-doc
on error undo, return error
:
                /*НЕ ПЕРЕДЕЛЫВАТЬ НА g e t c n t x t .i get процедура вызывается в автомате!!!!*/
    run get-db-num in parparentproc ( output v-cntxt-db-num).
    run get-userid in parparentproc ( output v-cntxt-userid).

    if p-kitchen-type = p-res-type
    and p-kitchen-code = p-res-code
    then do:        /* нет смысла генерить ВП на свой объект */
        undo, return .
    end.
    { gbl/rbisbase.i
        v-rb-is-base
    }
    run doc-code in this-procedure (
          input "main"
        , input p-kitchen-type
        , input p-kitchen-code
        , input ""
        , output v-trn-doc-code
    ).
    { gbl/hostcode.i
        p-kitchen-type
        p-kitchen-code
        v-host-code
    }
    { gbl/curobjdt.i
        p-kitchen-type
        p-kitchen-code
        v-today
    }
    { gbl/hostname.i
        p-kitchen-type
        p-kitchen-code
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
        p-kitchen-type
        p-kitchen-code
        v-down-pay
    }
    { str/crtrndoc.i
        ?
        ?
        buf_curr-accnt.exch-rate
        buf_curr-accnt.exch-scale
        p-res-code
        p-res-type
        v-host-name
        v-cntxt-db-num
        v-cntxt-userid
        {&percent}
        v-trn-doc-code
        v-today
        {&expense}
        no
        v-host-code
        yes
        p-kitchen-code
        p-kitchen-type
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
        buf_trn-doc.out-code    = p-sale-doc-code
        /* cst-code discnt-pc discnt-rubl doc-qnty fact-base fact-date fact-num fact-qnty fact-rubl inv-num ord-num out-code ov PS ship-date ship-num SLT-base SLT-rubl tot-calc tot-cli tot-doc tot-fact tot-lines tot-ov tot-rubl tot-sale VAT-base VAT-rubl VAT-type */
    .
    find first buf_sale_trn-doc no-lock
         where buf_sale_trn-doc.doc-code = p-sale-doc-code
    no-error.
    if available buf_sale_trn-doc
    then do:
        assign
            buf_trn-doc.agnt        = buf_sale_trn-doc.agnt
            buf_trn-doc.boss        = buf_sale_trn-doc.boss
            buf_trn-doc.wrkr        = buf_sale_trn-doc.wrkr
        .
    end.
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
    define variable v-need-moving    as logical      no-undo.
    assign
        v-need-moving = no
    .
    create-lines:
    for each buf_sale-doc where
             buf_sale-doc.inkas-code = p-sale-doc-code
         and buf_sale-doc.fbrsale = yes,
        each buf_doc-fbr-gds no-lock
       where buf_doc-fbr-gds.obj-type     = p-res-type
         and buf_doc-fbr-gds.obj-code     = p-res-code
         and buf_doc-fbr-gds.fbr-obj-type = p-kitchen-type
         and buf_doc-fbr-gds.fbr-obj-code = p-kitchen-code
         and buf_doc-fbr-gds.out-code     = buf_sale-doc.doc-code
    on error undo, return error
    :
        if p-kitchen-rest = yes
        then do:
            run fbrrest-get-free-qnty in this-procedure (
                  input p-res-type
                , input p-res-code
                , input buf_doc-fbr-gds.gds-code
                , input no
                , output v-restaurant-free-qnty
            ).
        end.
        else do:
            assign
                v-restaurant-free-qnty  = 0
            .
        end.
        assign
            v-need-qnty = buf_doc-fbr-gds.fact-qnty - v-restaurant-free-qnty
        .
        if v-need-qnty <= 0
        then do:
            undo create-lines, next create-lines.
        end.
        find first buf_goods no-lock
             where buf_goods.gds-code = buf_doc-fbr-gds.gds-code
        .
        { gbl/gdsat.i
            buf_goods.artic
            buf_goods.prod-type
            buf_goods.prod-code
            'gds-goods=request':u
            v-goods-is-not-office
        }
        if v-goods-is-not-office = yes
        then do:
            run create-doc-line in this-procedure (
                  input buf_trn-doc.doc-code
                , input buf_doc-fbr-gds.gds-code
                , input v-need-qnty
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
         /*   or v-sum-vat-base   = 0
            or v-sum-vat-rubl   = 0   */
            then do:
                message
                    skip "Не удалось определить учетную цену"
                    skip "товара на объекте."
                    skip (1)
                    skip "Товар: " buf_goods.artic buf_goods.gds-name
                    skip "Объект (кухня): " buf_trn-doc.obj-type buf_trn-doc.obj-code
                    skip "Сумма в руб"    v-sum-rubl
                    skip "Сумма НДС"       v-sum-vat-rubl
                view-as alert-box error.
                undo, return error .
            end.
            assign
                v-need-moving = yes
            .
        end.
    end.        /* for each buf_doc-fbr-gds */
    if v-need-moving = no
    then do:        /* Нет строк документа. Можно удалить */
        delete buf_trn-doc.
    end.        /* if v-need-moving = no */
    else do:
        define variable v-was-gds-moving    as logical        no-undo.
        run str/trn-stat.p  (
              input parparentproc             /* parparentproc  */
            , input this-procedure
            , input {&close-doc}              /* parmode        */
            , input buf_trn-doc.doc-code      /* pardoc-code    */
            , input no                        /* parcheck-return*/
            , input v-cntxt-db-num            /* pardb-num      */
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
            , input v-cntxt-db-num            /* pardb-num      */
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
            , input v-cntxt-db-num            /* pardb-num      */
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
            v-trn-doc-boss = buf_trn-doc.boss
            v-trn-doc-agnt = buf_trn-doc.agnt
            v-trn-doc-wrkr = buf_trn-doc.wrkr
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
            , input v-cntxt-db-num              /* pardb-num      */
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
        find first buf_income_trn-doc exclusive-lock
             where buf_income_trn-doc.out-code = v-trn-doc-code
        .
        assign
            buf_income_trn-doc.boss = v-trn-doc-boss
            buf_income_trn-doc.agnt = v-trn-doc-agnt
            buf_income_trn-doc.wrkr = v-trn-doc-wrkr
        .
    end.        /* if v-need-moving <> no */
end.


/*==========================================================================*/
procedure create-doc-line :
do
on error undo, return error
:
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
        , input yes
        , input p-income-trn-doc-code
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

/* 20.07.05. Суслов. Не нашел работы с данной процедурой. А вызов set-pr.i стал другой.
procedure rsrv-good :
do
on error undo, return error
:
define input  parameter p-goods-recid       as recid                    no-undo.
define input  parameter p-trn-doc-doc-code  as character                no-undo.
define input  parameter p-doc-line-recid    as recid                    no-undo.
define input  parameter p-required-qnty     like doc-line.doc-qnty      no-undo.
define output parameter p-rsrv-qnty         like doc-line.doc-qnty      no-undo.

    define variable v-r-b-is-base       as logical      no-undo.
    define variable v-cost-base         as decimal      no-undo.
    define variable v-cost-rubl         as decimal      no-undo.
    define variable v-parts-parameter   as character    no-undo.
    define variable v-parts-found       as logical      no-undo.

    define buffer buf_goods         for goods.
    define buffer buf_gds-prt       for gds-prt.
    define buffer buf_gds-dtl       for gds-dtl.
    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_doc-line      for doc-line.
    define buffer buf_parts         for parts.

    { gbl/rbisbase.i
        v-r-b-is-base
    }
    find first buf_goods no-lock
         where recid( buf_goods ) = p-goods-recid
    .
    find first buf_gds-prt no-lock
         where buf_gds-prt.upper-code = buf_goods.prt-root
    .
    find first buf_trn-doc exclusive-lock
         where buf_trn-doc.doc-code = p-trn-doc-doc-code
    .
    find first buf_doc-line no-lock
         where recid( buf_doc-line ) = p-doc-line-recid
    .
    assign
        buf_trn-doc.print-rubl = ( if v-r-b-is-base = yes then no else yes )
    .
    { str/crgdsdtl.i
        buf_trn-doc.obj-code
        buf_trn-doc.obj-type
        buf_trn-doc.doc-code
        buf_goods.artic
        buf_goods.prod-code
        buf_goods.prod-type
        buf_gds-prt.node-code
        yes
    no-error }
    if error-status:error
    then do:
        message
            "Ошибка при создании признака."
            skip return-value
        view-as alert-box error.
    end.
    find first buf_gds-dtl exclusive-lock
         where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
           and buf_gds-dtl.artic     = buf_goods.artic
           and buf_gds-dtl.prod-type = buf_goods.prod-type
           and buf_gds-dtl.prod-code = buf_goods.prod-code
           and buf_gds-dtl.prt-code  = buf_gds-prt.node-code
    .
    { str/set-pr.i
        recid(buf_gds-dtl)
    no-error }
    if error-status:error
    then do:
        message
            "Ошибка при назначении цены признака."
            skip return-value
        view-as alert-box error.
    end.
    if v-r-b-is-base = yes
    then do:
        assign
            buf_gds-dtl.price-rubl = buf_gds-dtl.price-base * buf_trn-doc.base-rate / buf_trn-doc.base-scale
            buf_gds-dtl.price-base = buf_gds-dtl.price-base
        .
    end.
    else do:
        assign
            buf_gds-dtl.price-rubl = buf_gds-dtl.price-rubl
            buf_gds-dtl.price-base = buf_gds-dtl.price-rubl / buf_trn-doc.base-rate * buf_trn-doc.base-scale
        .
    end.
    assign
        buf_trn-doc.status_ = {&wayb}
        buf_trn-doc.flag_   = no
    .
    assign
        buf_gds-dtl.ov  = yes
        v-cost-base     = buf_doc-line.price-base
        v-cost-rubl     = buf_doc-line.price-rubl
        p-rsrv-qnty     = round( p-required-qnty, 3 )
    .
    assign
        v-parts-found = no
    .
    for each buf_parts no-lock
       where buf_parts.obj-type  = buf_doc-line.obj-type
         and buf_parts.obj-code  = buf_doc-line.obj-code
         and buf_parts.prod-type = buf_doc-line.prod-type
         and buf_parts.prod-code = buf_doc-line.prod-code
         and buf_parts.artic     = buf_doc-line.artic
         and buf_parts.in-code   = p-income-trn-doc-code
         and buf_parts.out-code  = p-income-trn-doc-code
    on error undo, return error return-value
    :
        assign
            v-parts-found     = yes
            v-parts-parameter = {&rsrv-dtl_action_reserv}
                        + "," + {&rsrv-dtl_no-message}
                        + "," + {&rsrv-dtl_rsrv-single-part}
                        + "," + {&rsrv-dtl_rsrv-in-code}   + "=":u + str-encode ( buf_parts.in-code  ,  "", ",=":u )
                        + "," + {&rsrv-dtl_rsrv-part-code} + "=":u + str-encode ( buf_parts.part-code,  "", ",=":u )
        .
        run trg/rsrv-dtl.p (
              input parparentproc
            , input v-parts-parameter
            , buffer buf_gds-dtl
            , input-output p-rsrv-qnty
            , input-output v-cost-base
            , input-output v-cost-rubl
            , input -1
        ) no-error.
        if error-status:error
        then do:
            undo, return error return-value.
        end.
        if v-cost-base <= 0
        or v-cost-rubl <= 0
        then do:
            message
                "Неправильные цены резервирования:"
                skip "{&abbr_rubli_allshift}:   " v-cost-rubl
                skip "БАЗ.ВАЛ.:" v-cost-base
                skip "Артикул:" buf_doc-line.artic
            view-as alert-box error.
            undo, return error.
        end.
    end.
    if v-parts-found = no
    then do:
        assign
            p-rsrv-qnty = 0
        .
    end.
end.
end procedure.
*/