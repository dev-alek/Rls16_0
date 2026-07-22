block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sttoper.p $
$Archive: bge/sttoper.p $

Экспорт товарных остатков по типам приобретения на дату.

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:

Output:

*/
define input parameter p-obj-type               as character        no-undo.
define input parameter p-obj-code               as integer          no-undo.
define input parameter p-date-to                as date             no-undo.
define input parameter p-fact-order-to          as integer          no-undo.
define input parameter p-obj-list               as character        no-undo.
define input parameter p-parameter-list         as character        no-undo.
define input parameter p-xml-file-name          as character        no-undo.
define input parameter p-log-file-name          as character        no-undo.
define input parameter p-list-file-name         as character        no-undo.
define input parameter p-xml-file-number        as integer          no-undo.
define input parameter hedt                     as handle           no-undo.
define input parameter hcnt                     as handle           no-undo.
define output parameter p-last-xml-file-name    as character        no-undo.
define output parameter p-last-xml-file-number  as integer          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sttoper.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/sttoper.p $":U .
define variable vss-description as character no-undo init "Экспорт товарных остатков по типам приобретения на дату.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ bge/bgelib.i   }

    define variable v-goods-counter     as integer      no-undo.
    define variable v-host-code         as integer      no-undo.
    define variable v-base-code         as integer      no-undo.
    define variable v-base-code-okv     as integer      no-undo.
    define variable v-need-new-file     as logical      no-undo.
    define variable v-prev-filename     as character    no-undo.
    define variable v-void-string       as character    no-undo.
    define variable v-hcnt-is-active    as logical      no-undo.
    define variable v-is-goods          as logical      no-undo.
    define variable v-r-b-is-base       as logical      no-undo.
    define variable v-today             as date         no-undo.
    define variable v-time              as integer      no-undo.


    define buffer buf_gds-obj   for ub.gds-obj.
    define buffer buf_stk-line  for ub.stk-line.

do
for buf_gds-obj
  , buf_stk-line
on error undo, return error
:
    process events.
    assign
        p-last-xml-file-name    = p-xml-file-name
        p-last-xml-file-number  = p-xml-file-number
    .
    output stream stmxmlout to value( p-xml-file-name + {&bgelib-temp-extension} ) convert target "1251" append.

    { gbl/working.i }
    run bgelib-write-cnt( input hCNT, input "" ).

    { gbl/hostcode.i
        p-obj-type
        p-obj-code
        v-host-code
    }
    { gbl/basecode.i
        v-host-code
        v-base-code
    }
    run get-base-code-okv in this-procedure (
          input v-base-code
        , output v-base-code-okv
    ).
    run bgelib-tag-open( input 1, input "store", input "" ).
    run bgelib-tag-put( input 2, input "storeCode"      , input p-obj-type + string( p-obj-code )   , input 0 ).
    run bgelib-tag-put( input 2, input "hostcode"       , input string( v-host-code )               , input 0 ).
    run bgelib-tag-put( input 2, input "valutCode"      , input string( v-base-code )               , input 0 ).
    run bgelib-tag-put( input 2, input "valutCodeOKV"   , input string( v-base-code-okv )               , input 0 ).
    run bgelib-tag-close( input 1, input "store" ).

    { gbl/rbisbase.i
        v-r-b-is-base
    }
    goods-on-object:
    for each buf_gds-obj no-lock
       where buf_gds-obj.obj-type = p-obj-type
         and buf_gds-obj.obj-code = p-obj-code
    break by buf_gds-obj.artic
          by buf_gds-obj.prod-type
          by buf_gds-obj.prod-code
    :
        run cur-time in this-procedure (
              output v-today
            , output v-time
        ).
        if first-of( buf_gds-obj.prod-code )
        then do:
            { gbl/gdsat.i
                buf_gds-obj.artic
                buf_gds-obj.prod-type
                buf_gds-obj.prod-code
                'gds-goods=request':u
                v-is-goods
            }
            if v-is-goods = no
            then do:        /* услуги не выгружать */
                next goods-on-object.
            end.
            if v-need-new-file = yes
            then do:
                output stream stmxmlout close.
                assign
                    v-prev-filename = p-xml-file-name
                .
                run bgelib-filename in this-procedure (
                      input "std"
                    , output p-xml-file-name
                    , output v-void-string
                    , output v-void-string
                ).
                run bgelib-write-footer in this-procedure (
                      input no
                    , input v-prev-filename
                    , input p-list-file-name
                    , input yes
                    , input p-xml-file-name + "xml":U
                ).
                run bgelib-write-log in this-procedure (
                      input p-log-file-name
                    , input 1
                    , input substitute( "Данные выгружены в файл &1"
                                            , replace( p-xml-file-name, "/", "\" ) + "xml"
                                    )
                ).
                assign
                    p-last-xml-file-number   = p-xml-file-number + 1
                    p-last-xml-file-name     = p-xml-file-name
                .
                run bgelib-write-header in this-procedure (
                      input no
                    , input p-last-xml-file-name
                    , input p-list-file-name
                    , input p-last-xml-file-number
                    , input yes
                    , input v-prev-filename + "xml":U
                    , input p-obj-list
                    , input ""
                    , input p-parameter-list
                ).
                output stream stmxmlout to value( p-xml-file-name + {&bgelib-temp-extension} ) convert target "1251" append.
                assign
                    v-need-new-file = no
                .
            end.        /* if v-need-new-file = yes */
            run write-result in this-procedure (
                  input p-obj-type
                , input p-obj-code
                , input buf_gds-obj.gds-code
                , input buf_gds-obj.free-qnty
                , input {&aht-repayment}
                , input p-fact-order-to
                , input v-r-b-is-base
            ) no-error.
            if error-status :error
            then do:
                run bgelib-write-log in this-procedure (
                      input p-log-file-name
                    , input 1
                    , input substitute( "*** Ошибка выгрузки по типу приобретения &1. Объект &2 &3. Код товара &4. &5. &6"
                                            , "repayment":U
                                            , p-obj-type
                                            , p-obj-code
                                            , buf_gds-obj.gds-code
                                            , return-value
                                            , trim(error-status :get-message(1))
                                    )
                ).
            end.
            run write-result in this-procedure (
                  input p-obj-type
                , input p-obj-code
                , input buf_gds-obj.gds-code
                , input buf_gds-obj.free-qnty
                , input {&aht-cons_acc}
                , input p-fact-order-to
                , input v-r-b-is-base
            ) no-error.
            if error-status :error
            then do:
                run bgelib-write-log in this-procedure (
                      input p-log-file-name
                    , input 1
                    , input substitute( "*** Ошибка выгрузки по типу приобретения &1. Объект &2 &3. Код товара &4. &5. &6"
                                            , "cons_acc":U
                                            , p-obj-type
                                            , p-obj-code
                                            , buf_gds-obj.gds-code
                                            , return-value
                                            , trim(error-status :get-message(1))
                                    )
                ).
            end.
            run write-result in this-procedure (
                  input p-obj-type
                , input p-obj-code
                , input buf_gds-obj.gds-code
                , input buf_gds-obj.free-qnty
                , input {&aht-resp_stor}
                , input p-fact-order-to
                , input v-r-b-is-base
            ) no-error.
            if error-status :error
            then do:
                run bgelib-write-log in this-procedure (
                      input p-log-file-name
                    , input 1
                    , input substitute( "*** Ошибка выгрузки по типу приобретения &1. Объект &2 &3. Код товара &4. &5. &6"
                                            , "resp_stor":U
                                            , p-obj-type
                                            , p-obj-code
                                            , buf_gds-obj.gds-code
                                            , return-value
                                            , trim(error-status :get-message(1))
                                    )
                ).
            end.
            run write-result in this-procedure (
                  input p-obj-type
                , input p-obj-code
                , input buf_gds-obj.gds-code
                , input buf_gds-obj.free-qnty
                , input {&aht-old_cons}
                , input p-fact-order-to
                , input v-r-b-is-base
            ) no-error.
            if error-status :error
            then do:
                run bgelib-write-log in this-procedure (
                      input p-log-file-name
                    , input 1
                    , input substitute( "*** Ошибка выгрузки по типу приобретения &1. Объект &2 &3. Код товара &4. &5. &6"
                                            , "old_cons":U
                                            , p-obj-type
                                            , p-obj-code
                                            , buf_gds-obj.gds-code
                                            , return-value
                                            , trim(error-status :get-message(1))
                                    )
                ).
            end.
            run write-result in this-procedure (
                  input p-obj-type
                , input p-obj-code
                , input buf_gds-obj.gds-code
                , input buf_gds-obj.free-qnty
                , input {&aht-service}
                , input p-fact-order-to
                , input v-r-b-is-base
            ) no-error.
            if error-status :error
            then do:
                run bgelib-write-log in this-procedure (
                      input p-log-file-name
                    , input 1
                    , input substitute( "*** Ошибка выгрузки по типу приобретения &1. Объект &2 &3. Код товара &4. &5. &6"
                                            , "service":U
                                            , p-obj-type
                                            , p-obj-code
                                            , buf_gds-obj.gds-code
                                            , return-value
                                            , trim(error-status :get-message(1))
                                    )
                ).
            end.
            if v-hcnt-is-active = no
            then do:
                run bgelib-show-cnt in this-procedure (
                    input hcnt
                ).
                assign
                    v-hcnt-is-active = yes
                .
                run bgelib-write-cnt(
                      input hcnt
                    , input substitute( "Объект: &1&2 Товаров: &3", p-obj-type, p-obj-code, 1 )
                ).
                process events.
            end.
            assign
                v-goods-counter = v-goods-counter + 1
            .
            if v-goods-counter modulo 100 = 0
            then do:
                run bgelib-write-cnt(
                      input hcnt
                    , input substitute( "Объект: &1&2 Товаров: &3", p-obj-type, p-obj-code, v-goods-counter )
                ).
                process events.
            end.
            run bgelib-check-file-size in this-procedure (
                  input p-xml-file-name + {&bgelib-temp-extension}
                , output v-need-new-file
            ).
        end.        /* if first-of( buf_gds-obj.prod-code ) */
    end.        /* for each buf_gds-obj no-lock */
    /*    { rep/repfrm.i off}*/
    run bgelib-write-cnt(
          input hcnt
        , input substitute( "Объект: &1&2 Товаров: &3", p-obj-type, p-obj-code, v-goods-counter )
    ).
    output stream stmxmlout close.
    { gbl/stopwork.i }
end.



/*==========================================================================*/
procedure write-result :

define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-gds-code       as integer          no-undo.
define input parameter p-free-qnty      as decimal          no-undo.
define input parameter p-sum-type       as character        no-undo.
define input parameter p-fact-order     as integer          no-undo.
define input parameter p-r-b-is-base    as logical          no-undo.

    define variable v-gds-code          as integer      no-undo.
    define variable v-gds-name          as character    no-undo.
    define variable v-not-output-result as logical      no-undo.
    define variable v-sum-types         as character    no-undo.
    define variable v-main-tags         as character    no-undo.
    define variable v-main-tag          as character    no-undo.

    define buffer buf_goods             for ub.goods.
    define buffer buf_aht-stk-line      for ub.aht-stk-line.
    define buffer buf_benf_aht-stk-line for ub.aht-stk-line.
do
for buf_goods
  , buf_aht-stk-line
on error undo, return error
:
    find last buf_aht-stk-line no-lock
        where buf_aht-stk-line.obj-type  = p-obj-type
          and buf_aht-stk-line.obj-code  = p-obj-code
          and buf_aht-stk-line.gds-code  = p-gds-code
          and buf_aht-stk-line.sum-type  = p-sum-type
          and buf_aht-stk-line.fact-order <= p-fact-order
    use-index category
    no-error.
    if p-sum-type = {&aht-cons_acc}
    then do:
        find last buf_benf_aht-stk-line no-lock
            where buf_benf_aht-stk-line.obj-type  = p-obj-type
              and buf_benf_aht-stk-line.obj-code  = p-obj-code
              and buf_benf_aht-stk-line.gds-code  = p-gds-code
              and buf_benf_aht-stk-line.sum-type  = {&aht-cons_benf}
              and buf_benf_aht-stk-line.fact-order <= p-fact-order
        use-index category
        no-error.
    end.        /* if p-sum-type = {&aht-cons_acc} */
    assign
        v-not-output-result = no
    .
    if ( not available buf_aht-stk-line )
    or (    buf_aht-stk-line.fact-qnty              = 0
        and buf_aht-stk-line.cost-sum-rubl          = 0
        and buf_aht-stk-line.cost-VAT-rubl          = 0
        and buf_aht-stk-line.cost-SLT-rubl          = 0
        and buf_aht-stk-line.cost-road-tax-rubl     = 0
        and buf_aht-stk-line.cost-transport-rubl    = 0
        and buf_aht-stk-line.cost-other-rubl        = 0
        and buf_aht-stk-line.cost-excise-rubl       = 0
        and buf_aht-stk-line.cost-sum-base          = 0
        and buf_aht-stk-line.cost-VAT-base          = 0
        and buf_aht-stk-line.cost-SLT-base          = 0
        and buf_aht-stk-line.cost-road-tax-base     = 0
        and buf_aht-stk-line.cost-transport-base    = 0
        and buf_aht-stk-line.cost-other-base        = 0
        and buf_aht-stk-line.cost-excise-base       = 0 )
    then do:
        assign
            v-not-output-result = yes
        .
        if p-r-b-is-base = yes
        then do:
            if ( not available buf_aht-stk-line )
            or (    buf_aht-stk-line.crsa-sum-base       = 0
                and buf_aht-stk-line.crsa-VAT-base       = 0
                and buf_aht-stk-line.crsa-SLT-base       = 0
                and buf_aht-stk-line.crsa-road-tax-base  = 0
                and buf_aht-stk-line.crsa-transport-base = 0
                and buf_aht-stk-line.crsa-other-base     = 0
                and buf_aht-stk-line.crsa-excise-base    = 0 )
            then do:
                assign
                    v-not-output-result = yes
                .
            end.
            else do:
                assign
                    v-not-output-result = no
                .
            end.
        end.        /* if p-r-b-is-base = yes */
        else do:
            if ( not available buf_aht-stk-line )
            or (    buf_aht-stk-line.crsa-sum-rubl       = 0
                and buf_aht-stk-line.crsa-VAT-rubl       = 0
                and buf_aht-stk-line.crsa-SLT-rubl       = 0
                and buf_aht-stk-line.crsa-road-tax-rubl  = 0
                and buf_aht-stk-line.crsa-transport-rubl = 0
                and buf_aht-stk-line.crsa-other-rubl     = 0
                and buf_aht-stk-line.crsa-excise-rubl    = 0 )
            then do:
                assign
                    v-not-output-result = yes
                .
            end.
            else do:
                assign
                    v-not-output-result = no
                .
            end.
        end.        /* NOT ( if p-r-b-is-base = yes ) */
    end.
    if p-sum-type = {&aht-cons_acc}
    then do:
        if available buf_benf_aht-stk-line
        and (
            buf_benf_aht-stk-line.crsa-sum-rubl          <> 0
            or buf_benf_aht-stk-line.crsa-VAT-rubl       <> 0
            or buf_benf_aht-stk-line.crsa-SLT-rubl       <> 0
            or buf_benf_aht-stk-line.crsa-road-tax-rubl  <> 0
            or buf_benf_aht-stk-line.crsa-transport-rubl <> 0
            or buf_benf_aht-stk-line.crsa-other-rubl     <> 0
            or buf_benf_aht-stk-line.crsa-excise-rubl    <> 0 )
        then do:
            assign
                v-not-output-result = no
            .
        end.
    end.
    if v-not-output-result = yes
    then do:
        undo, return .
    end.
    find first buf_goods no-lock
         where buf_goods.gds-code     = p-gds-code
    no-error.
    if available buf_goods
    then do:
        assign
            v-gds-name              = buf_goods.gds-name
        .
    end.        /* available buf_goods */
    else do:
        assign
            v-gds-name              = ""
        .
    end.        /* not ( available buf_goods ) */
    assign
        v-sum-types = {&aht-repayment}
                        + ",":U + {&aht-cons_acc}
                        + ",":U + {&aht-cons_benf}
                        + ",":U + {&aht-resp_stor}
                        + ",":U + {&aht-old_cons}
                        + ",":U + {&aht-service}
    .
    assign
        v-main-tags = "storeGoodsRepayment"
                        + ",":U + "storeGoodsCons_acc":U
                        + ",":U + "storeGoodsCons_benf":U
                        + ",":U + "storeGoodsResp_stor":U
                        + ",":U + "storeGoodsOld_cons":U
                        + ",":U + "storeGoodsService":U
    .
    assign
        v-main-tag = entry( lookup( p-sum-type, v-sum-types ), v-main-tags )
    no-error.
    if error-status :error
    or v-main-tag = ?
    or v-main-tag = ""
    then do:
        undo, return error substitute( "Ошибка задания sum-type для архива по типам приобретения. Задано значение &1.", p-sum-type ).
    end.
    run bgelib-tag-open( input 1, input v-main-tag , input "" ).
    run bgelib-tag-put( input 2, input "storeCode"      , input p-obj-type + string( p-obj-code ) , input 0 ).
    run bgelib-tag-put( input 2, input "goodsCode"      , input string( p-gds-code              ) , input 0 ).
    run bgelib-tag-put( input 2, input "goodsArtic"     , input string( buf_goods.artic         ) , input 0 ).
    run bgelib-tag-put( input 2, input "goodsProdType"  , input string( buf_goods.prod-type     ) , input 0 ).
    run bgelib-tag-put( input 2, input "goodsProdCode"  , input string( buf_goods.prod-code     ) , input 0 ).
    run bgelib-tag-put( input 2, input "goodsName"      , input string( v-gds-name              ) , input 0 ).
    run bgelib-tag-put( input 2, input "goodsFreeQntyDate"  , input string( v-today, "99.99.9999"   ) , input 0 ).
    run bgelib-tag-put( input 2, input "goodsFreeQntyTime"  , input string( v-time , "hh:mm:ss"     ) , input 0 ).
    run bgelib-tag-put( input 2, input "goodsFreeQnty"      , input string( p-free-qnty             ) , input 0 ).
    if available buf_aht-stk-line
    then do:
        run bgelib-tag-put( input 2, input "goodsQnty"             , input string( buf_aht-stk-line.fact-qnty           ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostSumr"         , input string( buf_aht-stk-line.cost-sum-rubl       ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostVatr"         , input string( buf_aht-stk-line.cost-VAT-rubl       ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostSltr"         , input string( buf_aht-stk-line.cost-SLT-rubl       ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostRoadtaxr"     , input string( buf_aht-stk-line.cost-road-tax-rubl  ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostTransportr"   , input string( buf_aht-stk-line.cost-transport-rubl ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostOtherr"       , input string( buf_aht-stk-line.cost-other-rubl     ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostExciser"      , input string( buf_aht-stk-line.cost-excise-rubl    ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostSumb"         , input string( buf_aht-stk-line.cost-sum-base       ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostVatb"         , input string( buf_aht-stk-line.cost-VAT-base       ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostSltb"         , input string( buf_aht-stk-line.cost-SLT-base       ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostRoadtaxb"     , input string( buf_aht-stk-line.cost-road-tax-base  ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostTransportb"   , input string( buf_aht-stk-line.cost-transport-base ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostOtherb"       , input string( buf_aht-stk-line.cost-other-base     ), input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostExciseb"      , input string( buf_aht-stk-line.cost-excise-base    ), input 2 ).
    end.
    if available buf_aht-stk-line
    then do:
        if p-r-b-is-base = yes
        then do:
            if p-sum-type = {&aht-cons_acc}
            then do:
                run bgelib-tag-put( input 2, input "goodsConsSaleSumb"         , input string( buf_aht-stk-line.crsa-sum-base        ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsConsSaleVatb"         , input string( buf_aht-stk-line.crsa-VAT-base        ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsConsSaleSltb"         , input string( buf_aht-stk-line.crsa-SLT-base        ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsConsSaleRoadtaxb"     , input string( buf_aht-stk-line.crsa-road-tax-base   ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsConsSaleTransportb"   , input string( buf_aht-stk-line.crsa-transport-base  ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsConsSaleOtherb"       , input string( buf_aht-stk-line.crsa-other-base      ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsConsSaleExciseb"      , input string( buf_aht-stk-line.crsa-excise-base     ) , input 2 ).
                if available buf_benf_aht-stk-line
                then do:
                    run bgelib-tag-put( input 2, input "goodsBenfSaleSumb"         , input string( buf_benf_aht-stk-line.crsa-sum-base        ) , input 2 ).
                    run bgelib-tag-put( input 2, input "goodsBenfSaleVatb"         , input string( buf_benf_aht-stk-line.crsa-VAT-base        ) , input 2 ).
                    run bgelib-tag-put( input 2, input "goodsBenfSaleSltb"         , input string( buf_benf_aht-stk-line.crsa-SLT-base        ) , input 2 ).
                    run bgelib-tag-put( input 2, input "goodsBenfSaleRoadtaxb"     , input string( buf_benf_aht-stk-line.crsa-road-tax-base   ) , input 2 ).
                    run bgelib-tag-put( input 2, input "goodsBenfSaleTransportb"   , input string( buf_benf_aht-stk-line.crsa-transport-base  ) , input 2 ).
                    run bgelib-tag-put( input 2, input "goodsBenfSaleOtherb"       , input string( buf_benf_aht-stk-line.crsa-other-base      ) , input 2 ).
                    run bgelib-tag-put( input 2, input "goodsBenfSaleExciseb"      , input string( buf_benf_aht-stk-line.crsa-excise-base     ) , input 2 ).
                end.
                run bgelib-tag-put( input 2, input "goodsSaleSumb"         , input string( buf_aht-stk-line.crsa-sum-base        + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-sum-base       else 0 ) ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleVatb"         , input string( buf_aht-stk-line.crsa-VAT-base        + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-VAT-base       else 0 ) ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleSltb"         , input string( buf_aht-stk-line.crsa-SLT-base        + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-SLT-base       else 0 ) ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleRoadtaxb"     , input string( buf_aht-stk-line.crsa-road-tax-base   + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-road-tax-base  else 0 ) ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleTransportb"   , input string( buf_aht-stk-line.crsa-transport-base  + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-transport-base else 0 ) ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleOtherb"       , input string( buf_aht-stk-line.crsa-other-base      + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-other-base     else 0 ) ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleExciseb"      , input string( buf_aht-stk-line.crsa-excise-base     + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-excise-base    else 0 ) ) , input 2 ).
            end.        /* if p-sum-type = {&aht-cons_acc} */
            else do:
                run bgelib-tag-put( input 2, input "goodsSaleSumb"         , input string( buf_aht-stk-line.crsa-sum-base        ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleVatb"         , input string( buf_aht-stk-line.crsa-VAT-base        ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleSltb"         , input string( buf_aht-stk-line.crsa-SLT-base        ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleRoadtaxb"     , input string( buf_aht-stk-line.crsa-road-tax-base   ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleTransportb"   , input string( buf_aht-stk-line.crsa-transport-base  ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleOtherb"       , input string( buf_aht-stk-line.crsa-other-base      ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleExciseb"      , input string( buf_aht-stk-line.crsa-excise-base     ) , input 2 ).
            end.
        end.        /* if v-r-b-is-base = yes */
        else do:
            if p-sum-type = {&aht-cons_acc}
            then do:
                run bgelib-tag-put( input 2, input "goodsConsSaleSumr"         , input string( buf_aht-stk-line.crsa-sum-rubl        ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsConsSaleVatr"         , input string( buf_aht-stk-line.crsa-VAT-rubl        ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsConsSaleSltr"         , input string( buf_aht-stk-line.crsa-SLT-rubl        ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsConsSaleRoadtaxr"     , input string( buf_aht-stk-line.crsa-road-tax-rubl   ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsConsSaleTransportr"   , input string( buf_aht-stk-line.crsa-transport-rubl  ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsConsSaleOtherr"       , input string( buf_aht-stk-line.crsa-other-rubl      ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsConsSaleExciser"      , input string( buf_aht-stk-line.crsa-excise-rubl     ) , input 2 ).
                if available buf_benf_aht-stk-line
                then do:
                    run bgelib-tag-put( input 2, input "goodsBenfSaleBenfSumr"         , input string( buf_benf_aht-stk-line.crsa-sum-rubl        ) , input 2 ).
                    run bgelib-tag-put( input 2, input "goodsBenfSaleBenfVatr"         , input string( buf_benf_aht-stk-line.crsa-VAT-rubl        ) , input 2 ).
                    run bgelib-tag-put( input 2, input "goodsBenfSaleBenfSltr"         , input string( buf_benf_aht-stk-line.crsa-SLT-rubl        ) , input 2 ).
                    run bgelib-tag-put( input 2, input "goodsBenfSaleBenfRoadtaxr"     , input string( buf_benf_aht-stk-line.crsa-road-tax-rubl   ) , input 2 ).
                    run bgelib-tag-put( input 2, input "goodsBenfSaleBenfTransportr"   , input string( buf_benf_aht-stk-line.crsa-transport-rubl  ) , input 2 ).
                    run bgelib-tag-put( input 2, input "goodsBenfSaleBenfOtherr"       , input string( buf_benf_aht-stk-line.crsa-other-rubl      ) , input 2 ).
                    run bgelib-tag-put( input 2, input "goodsBenfSaleBenfExciser"      , input string( buf_benf_aht-stk-line.crsa-excise-rubl     ) , input 2 ).
                end.
                run bgelib-tag-put( input 2, input "goodsSaleSumr"         , input string( buf_aht-stk-line.crsa-sum-rubl        + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-sum-rubl       else 0 ) ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleVatr"         , input string( buf_aht-stk-line.crsa-VAT-rubl        + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-VAT-rubl       else 0 ) ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleSltr"         , input string( buf_aht-stk-line.crsa-SLT-rubl        + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-SLT-rubl       else 0 ) ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleRoadtaxr"     , input string( buf_aht-stk-line.crsa-road-tax-rubl   + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-road-tax-rubl  else 0 ) ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleTransportr"   , input string( buf_aht-stk-line.crsa-transport-rubl  + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-transport-rubl else 0 ) ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleOtherr"       , input string( buf_aht-stk-line.crsa-other-rubl      + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-other-rubl     else 0 ) ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleExciser"      , input string( buf_aht-stk-line.crsa-excise-rubl     + ( if available buf_benf_aht-stk-line then buf_benf_aht-stk-line.crsa-excise-rubl    else 0 ) ) , input 2 ).
            end.        /* if p-sum-type = {&aht-cons_acc} */
            else do:
                run bgelib-tag-put( input 2, input "goodsSaleSumr"         , input string( buf_aht-stk-line.crsa-sum-rubl        ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleVatr"         , input string( buf_aht-stk-line.crsa-VAT-rubl        ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleSltr"         , input string( buf_aht-stk-line.crsa-SLT-rubl        ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleRoadtaxr"     , input string( buf_aht-stk-line.crsa-road-tax-rubl   ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleTransportr"   , input string( buf_aht-stk-line.crsa-transport-rubl  ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleOtherr"       , input string( buf_aht-stk-line.crsa-other-rubl      ) , input 2 ).
                run bgelib-tag-put( input 2, input "goodsSaleExciser"      , input string( buf_aht-stk-line.crsa-excise-rubl     ) , input 2 ).
            end.
        end.        /* NOT ( if v-r-b-is-base = yes ) */
    end.
    run bgelib-tag-close( input 1, input v-main-tag ).
end.
end procedure. /* eval-sum-and-write-result */




/*==========================================================================*/
procedure get-base-code-okv :
define input parameter p-base-code          as integer          no-undo.
define output parameter p-base-code-okv     as integer          no-undo.

    define buffer buf_currency      for ub.currency.
do
for buf_currency
on error undo, return error
:
    find first buf_currency no-lock
         where buf_currency.curr-code = p-base-code
    .
    assign
        p-base-code-okv = buf_currency.okv-code
    .
end.
end procedure. /* get-valutCode */