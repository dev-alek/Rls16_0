block-level on error undo, throw.
/*

$Revision: d47a2bcb93e4, 623, rls $
$Author: PGridchina $
$Date: Wed May 11 17:10:50 2016 +0400 $
$Workfile: stdoper.p $
$Archive: bge/stdoper.p $

Экспорт товарных остатков на дату.

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
define input parameter p-parts                  as character        no-undo.
define input parameter p-xml-file-name          as character        no-undo.
define input parameter p-log-file-name          as character        no-undo.
define input parameter p-list-file-name         as character        no-undo.
define input parameter p-xml-file-number        as integer          no-undo.
define input parameter hedt                     as handle           no-undo.
define input parameter hcnt                     as handle           no-undo.
define output parameter p-last-xml-file-name    as character        no-undo.
define output parameter p-last-xml-file-number  as integer          no-undo.

define variable vss-revision    as character no-undo init "$Revision: d47a2bcb93e4, 623, rls $":U .
define variable vss-author      as character no-undo init "$Author: PGridchina $":U .
define variable vss-date        as character no-undo init "$Date: Wed May 11 17:10:50 2016 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: stdoper.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/stdoper.p $":U .
define variable vss-description as character no-undo init "Экспорт товарных остатков на дату.".
{ cmp/vssrevis.i    }
{ str/lib-trn.i     }
{ cmp/trg-def.i     }
{ bge/bgelib.i      }
{ str/get-pr.i def  }
{ ref/gds-attr.i }
{ gbl/thbjattr.i }
{ cmp/str-glbl.i }
{ ref/extclass.i }


define variable v-prod as character no-undo.
define variable v-value-character     as character     no-undo .
define variable v-value-decimal       as decimal       no-undo .
define variable v-value-integer       as integer       no-undo .
define variable v-value-logical       as logical       no-undo .
define variable v-value-type          as character     no-undo .
define variable v-value-date          as date          no-undo .
define variable v-ext-sys             as integer       no-undo .
define variable v-inn as character no-undo.
define variable v-kpp as character no-undo.
define variable v-naim as character no-undo.
define variable v-PartsAlcAttrBottingDate like parts.alc-bottling-date no-undo.
define variable v-PartsAlcAttrAlcType like ub.alc-type.alc-type-code no-undo.
define variable v-PartsAlcAttrAlcCode as char no-undo.
define variable v-PartsAlcAttrRefA like parts.alc-ref-ab-path no-undo.
define variable v-PartsAlcAttrRefB like parts.alc-ref-ab-path no-undo.
define variable v-PartsAlcAttrProd as char no-undo.
define variable v-PartsAlcAttrQu like parts.alc-quality-certif-path no-undo.
define variable v-PartsAlcAttrCertifPath like parts.alc-certif-path no-undo.
define variable v-PartsAlcAttrImpCode like parts.alc-imp-code no-undo.
define variable v-PartsAlcAttrImpType like parts.alc-imp-type no-undo.
DEFINE VARIABLE v-par-val             AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-par-type            AS CHARACTER NO-UNDO.

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
    define buffer buf_clients   for ub.clients.
    define buffer buf_country   for ub.country.
    define buffer buf_ext-classif for ub.ext-classif.
    define buffer buf_alc-type-gds    for ub.alc-type-gds .
    define buffer buf_alc-type        for ub.alc-type .

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
    run bgelib-tag-put( input 2, input "valutCodeOKV"   , input string( v-base-code-okv )           , input 0 ).
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
           /* find first buf_goods no-lock where buf_goods.artic = buf_gds-obj.artic
                                       and buf_goods.prod-type = buf_gds-obj.prod-type
                                       and buf_goods.prod-code = buf_gds-obj.prod-code no-error.*/
        /* Проверим на принадлежность группе */
        /*if p-gds-grp-list <> "" and p-gds-grp-list <> ? then do:
            if not available(buf_goods) then next. /* чтобы проверка группы не падала если так будет */
            if not can-find(first temp-gds-grp where buf_goods.grp-name begins temp-gds-grp.full-name) then next.
        end.*/
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
                , input buf_gds-obj.artic
                , input buf_gds-obj.prod-type
                , input buf_gds-obj.prod-code
                , input buf_gds-obj.free-qnty
                , input p-fact-order-to
                , input v-r-b-is-base
            ) .
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
define input parameter p-artic          as character        no-undo.
define input parameter p-prod-type      as character        no-undo.
define input parameter p-prod-code      as integer          no-undo.
define input parameter p-free-qnty         as decimal          no-undo.
define input parameter p-fact-order     as integer          no-undo.
define input parameter p-r-b-is-base    as logical          no-undo.

    define variable v-gds-code          as integer      no-undo.
    define variable v-gds-name          as character    no-undo.
    define variable v-GoodsGrpCode as character no-undo. /* Код группы */
    define variable v-GoodsPackQnty as character no-undo. /* Количество в упаковке */
    define variable v-GoodsUnitBase as character no-undo. /* Ед.измерения */
    define variable v-GoodsPS as character no-undo. /* Примечание из карточки товара */
    define variable v-GoodsCountryName as character no-undo. /* Название страны */
    define variable v-GoodsEnglName as character no-undo. /* Название товара на английском языке */
    define variable v-GoodsProdName as character no-undo. /* Наименование производителя */
    define variable v-GoodsWeight as character no-undo. /* Вес штуки */
    define variable v-GoodsWidth as character no-undo. /* Ширина (атрибуты) */
    define variable v-GoodsLength as character no-undo. /* Длина */
    define variable v-GoodsHeight as character no-undo. /* Высота */
    define variable v-type as character no-undo.
    define variable v-value as character no-undo.
    define variable v-not-output-result as logical      no-undo.
    define variable v-in-code as character no-undo.
    define variable v-parts-code as character no-undo.
    define variable v-fact-qnty as decimal no-undo.
    define variable v-supp-type as character no-undo.
    define variable v-supp-code as integer no-undo.
    define VARIABLE v-price-cli as decimal no-undo.
    define variable v-cst-code as character no-undo.
    define VARIABLE v-gds-attr-value as character no-undo.
    define VARIABLE v-gds-attr-type as character no-undo.
    define VARIABLE v-alc-bottling-date like ub.parts.alc-bottling-date no-undo.
    define VARIABLE v-alc-ref-ab-path like ub.parts.alc-ref-ab-path no-undo.
    define VARIABLE v-alc-quality-certif-path like ub.parts.alc-quality-certif-path no-undo.
    define VARIABLE v-alc-certif-path like ub.parts.alc-certif-path no-undo.
    define VARIABLE v-alc-imp-code like ub.parts.alc-imp-code no-undo.
    define VARIABLE v-alc-imp-type like ub.parts.alc-imp-type no-undo.
    
    define buffer buf_goods             for ub.goods.
    define buffer buf_crsa_stk-line     for ub.stk-line.
    define buffer buf_cost_stk-line     for ub.stk-line.
    define buffer buf_reserv_parts      for ub.parts. 
 
do
for buf_goods
  , buf_crsa_stk-line
  , buf_cost_stk-line
  , buf_reserv_parts
on error undo, return error
:
    find last buf_cost_stk-line no-lock
        where buf_cost_stk-line.obj-type  = p-obj-type
          and buf_cost_stk-line.obj-code  = p-obj-code
          and buf_cost_stk-line.artic     = p-artic
          and buf_cost_stk-line.prod-type = p-prod-type
          and buf_cost_stk-line.prod-code = p-prod-code
          and buf_cost_stk-line.sum-type  = {&arh-cost}
          and buf_cost_stk-line.cat-id    = {&root-cat-id}
          and buf_cost_stk-line.fact-order <= p-fact-order
    use-index category
    no-error.
    find last buf_crsa_stk-line no-lock
        where buf_crsa_stk-line.obj-type  = p-obj-type
          and buf_crsa_stk-line.obj-code  = p-obj-code
          and buf_crsa_stk-line.artic     = p-artic
          and buf_crsa_stk-line.prod-type = p-prod-type
          and buf_crsa_stk-line.prod-code = p-prod-code
          and buf_crsa_stk-line.sum-type  = {&arh-crsa}
          and buf_crsa_stk-line.cat-id    = {&root-cat-id}
          and buf_crsa_stk-line.fact-order <= p-fact-order
    use-index category
    no-error.
    assign
        v-not-output-result = no
    .
    if ( not available buf_cost_stk-line )
    or (    buf_cost_stk-line.fact-qnty      = 0
        and buf_cost_stk-line.sum-rubl       = 0
        and buf_cost_stk-line.VAT-rubl       = 0
        and buf_cost_stk-line.SLT-rubl       = 0
        and buf_cost_stk-line.road-tax-rubl  = 0
        and buf_cost_stk-line.transport-rubl = 0
        and buf_cost_stk-line.other-rubl     = 0
        and buf_cost_stk-line.excise-rubl    = 0
        and buf_cost_stk-line.sum-base       = 0
        and buf_cost_stk-line.VAT-base       = 0
        and buf_cost_stk-line.SLT-base       = 0
        and buf_cost_stk-line.road-tax-base  = 0
        and buf_cost_stk-line.transport-base = 0
        and buf_cost_stk-line.other-base     = 0
        and buf_cost_stk-line.excise-base    = 0 )
    then do:
        assign
            v-not-output-result = yes
        .
        if p-r-b-is-base = yes
        then do:
            if ( not available buf_crsa_stk-line )
            or (    buf_crsa_stk-line.sum-base       = 0
                and buf_crsa_stk-line.VAT-base       = 0
                and buf_crsa_stk-line.SLT-base       = 0
                and buf_crsa_stk-line.road-tax-base  = 0
                and buf_crsa_stk-line.transport-base = 0
                and buf_crsa_stk-line.other-base     = 0
                and buf_crsa_stk-line.excise-base    = 0 )
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
            if ( not available buf_crsa_stk-line )
            or (    buf_crsa_stk-line.sum-rubl       = 0
                and buf_crsa_stk-line.VAT-rubl       = 0
                and buf_crsa_stk-line.SLT-rubl       = 0
                and buf_crsa_stk-line.road-tax-rubl  = 0
                and buf_crsa_stk-line.transport-rubl = 0
                and buf_crsa_stk-line.other-rubl     = 0
                and buf_crsa_stk-line.excise-rubl    = 0 )
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
    end. /* if ( not available buf_cost_stk-line )*/
    if v-not-output-result = yes
    then do:
        undo, return .
    end.
    find first buf_goods no-lock
         where buf_goods.artic     = p-artic
           and buf_goods.prod-type = p-prod-type
           and buf_goods.prod-code = p-prod-code
    no-error.
    if available buf_goods
    then do:
        /* Получим нужное из goods */
        assign
            v-gds-name              = buf_goods.gds-name
            v-gds-code              = buf_goods.gds-code
        v-GoodsGrpCode = string(buf_goods.grp-code)
        v-GoodsPackQnty = string(buf_goods.qnty-cart)
        v-GoodsUnitBase = buf_goods.unit-base
        v-GoodsPS = buf_goods.PS
        v-GoodsEnglName = buf_goods.engl-name
        v-GoodsWeight = string(buf_goods.wt-base).
        
        /* Название страны */
        find first buf_country where buf_country.alpha1 = buf_goods.alpha1 no-lock no-error.
        if available(buf_country) then v-GoodsCountryName = buf_country.long-name.
        else v-GoodsCountryName = "".
        
        /* Имя производителя */
        find first buf_clients where buf_clients.obj-code = buf_goods.prod-code
                                 and buf_clients.obj-type = buf_goods.prod-type no-lock no-error.
        if available(buf_clients) then v-GoodsProdName = buf_clients.obj-name.
        else v-GoodsProdName = "".

        /* Получим нужные атрибуты товара */
        run gds-attr-value in this-procedure (input buf_goods.gds-code,
                                              input {&attr-width-of},
                                              output v-GoodsWidth,
                                              output v-type) no-error.
                                              
        run gds-attr-value in this-procedure (input buf_goods.gds-code,
                                              input {&attr-length-of},
                                              output v-GoodsLength,
                                              output v-type) no-error.
                                              
        run gds-attr-value in this-procedure (input buf_goods.gds-code,
                                              input {&attr-height-of},
                                              output v-GoodsHeight,
                                              output v-type) no-error.
    end. /* if available buf_goods */
    else do:
        assign
            v-gds-name              = ""
            v-gds-code              = 0
        .
    end.        /* not ( available buf_goods ) */
    { str/get-pr.i
        " "
        p-obj-type
        p-obj-code
        buf_goods.gds-code
        ?
        " "
    }
    if error-status :error
    then do:
        run bgelib-write-log in this-procedure (
              input p-log-file-name
            , input 1
            , input substitute( "*** ERR *** Не удалось определить цену продажи на объекте &1 &2 для товара с кодом &3"
                                , p-obj-type
                                , p-obj-code
                                , buf_goods.gds-code )
        ).
    end. /*if error-status :error*/
    run bgelib-tag-open( input 1, input "storeGoods", input "" ).
    run bgelib-tag-put( input 2, input "storeCode"      , input p-obj-type + string( p-obj-code ) , input 0 ).
    run bgelib-tag-put( input 2, input "goodsCode"      , input string( v-gds-code              ) , input 0 ).
    run bgelib-tag-put( input 2, input "goodsArtic"     , input string( p-artic                 ) , input 0 ).
    run bgelib-tag-put( input 2, input "goodsProdType"  , input string( p-prod-type             ) , input 0 ).
    run bgelib-tag-put( input 2, input "goodsProdCode"  , input string( p-prod-code             ) , input 0 ).
    run bgelib-tag-put( input 2, input "goodsName"      , input string( v-gds-name              ) , input 0 ).
    run bgelib-tag-put( input 2, input "goodsPrice"     , input string( gp-price-sale           ) , input 0 ).
    run bgelib-tag-put( input 2, input "goodsFreeQntyDate"  , input string( v-today, "99.99.9999"   ) , input 0 ).
    run bgelib-tag-put( input 2, input "goodsFreeQntyTime"  , input string( v-time , "hh:mm:ss"     ) , input 0 ).
    run bgelib-tag-put( input 2, input "goodsFreeQnty"      , input string( p-free-qnty             ) , input 0 ).
    run bgelib-tag-put( input 2, input "GoodsGrpCode", input v-GoodsGrpCode, input 0).
    run bgelib-tag-put( input 2, input "GoodsPackQnty", input v-GoodsPackQnty, input 0).
    run bgelib-tag-put( input 2, input "GoodsUnitBase", input v-GoodsUnitBase, input 0).
    run bgelib-tag-put( input 2, input "GoodsPS", input v-GoodsPS, input 0).
    run bgelib-tag-put( input 2, input "GoodsCountryName", input v-GoodsCountryName, input 0).
    run bgelib-tag-put( input 2, input "GoodsEnglName", input v-GoodsEnglName, input 0).
    run bgelib-tag-put( input 2, input "GoodsProdName", input v-GoodsProdName, input 0).
    run bgelib-tag-put( input 2, input "GoodsWeight", input v-GoodsWeight, input 0).
    run bgelib-tag-put( input 2, input "GoodsWidth", input v-GoodsWidth, input 0).
    run bgelib-tag-put( input 2, input "GoodsLength", input v-GoodsLength, input 0).
    run bgelib-tag-put( input 2, input "GoodsHeight", input v-GoodsHeight, input 0).
    if available buf_cost_stk-line
    then do:
        run bgelib-tag-put( input 2, input "goodsQnty"             , input string( buf_cost_stk-line.fact-qnty       ) , input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostSumr"         , input string( buf_cost_stk-line.sum-rubl        ) , input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostVatr"         , input string( buf_cost_stk-line.VAT-rubl        ) , input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostSltr"         , input string( buf_cost_stk-line.SLT-rubl        ) , input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostRoadtaxr"     , input string( buf_cost_stk-line.road-tax-rubl   ) , input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostTransportr"   , input string( buf_cost_stk-line.transport-rubl  ) , input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostOtherr"       , input string( buf_cost_stk-line.other-rubl      ) , input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostExciser"      , input string( buf_cost_stk-line.excise-rubl     ) , input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostSumb"         , input string( buf_cost_stk-line.sum-base        ) , input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostVatb"         , input string( buf_cost_stk-line.VAT-base        ) , input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostSltb"         , input string( buf_cost_stk-line.SLT-base        ) , input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostRoadtaxb"     , input string( buf_cost_stk-line.road-tax-base   ) , input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostTransportb"   , input string( buf_cost_stk-line.transport-base  ) , input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostOtherb"       , input string( buf_cost_stk-line.other-base      ) , input 2 ).
        run bgelib-tag-put( input 2, input "goodsCostExciseb"      , input string( buf_cost_stk-line.excise-base     ) , input 2 ).
    end. /*if available buf_cost_stk-line*/
    if available buf_crsa_stk-line
    then do:
        if p-r-b-is-base = yes
        then do:
            run bgelib-tag-put( input 2, input "goodsSaleSumb"         , input string( buf_crsa_stk-line.sum-base        ) , input 2 ).
            run bgelib-tag-put( input 2, input "goodsSaleVatb"         , input string( buf_crsa_stk-line.VAT-base        ) , input 2 ).
            run bgelib-tag-put( input 2, input "goodsSaleSltb"         , input string( buf_crsa_stk-line.SLT-base        ) , input 2 ).
            run bgelib-tag-put( input 2, input "goodsSaleRoadtaxb"     , input string( buf_crsa_stk-line.road-tax-base   ) , input 2 ).
            run bgelib-tag-put( input 2, input "goodsSaleTransportb"   , input string( buf_crsa_stk-line.transport-base  ) , input 2 ).
            run bgelib-tag-put( input 2, input "goodsSaleOtherb"       , input string( buf_crsa_stk-line.other-base      ) , input 2 ).
            run bgelib-tag-put( input 2, input "goodsSaleExciseb"      , input string( buf_crsa_stk-line.excise-base     ) , input 2 ).
        end.        /* if v-r-b-is-base = yes */
        else do:
            run bgelib-tag-put( input 2, input "goodsSaleSumr"         , input string( buf_crsa_stk-line.sum-rubl        ) , input 2 ).
            run bgelib-tag-put( input 2, input "goodsSaleVatr"         , input string( buf_crsa_stk-line.VAT-rubl        ) , input 2 ).
            run bgelib-tag-put( input 2, input "goodsSaleSltr"         , input string( buf_crsa_stk-line.SLT-rubl        ) , input 2 ).
            run bgelib-tag-put( input 2, input "goodsSaleRoadtaxr"     , input string( buf_crsa_stk-line.road-tax-rubl   ) , input 2 ).
            run bgelib-tag-put( input 2, input "goodsSaleTransportr"   , input string( buf_crsa_stk-line.transport-rubl  ) , input 2 ).
            run bgelib-tag-put( input 2, input "goodsSaleOtherr"       , input string( buf_crsa_stk-line.other-rubl      ) , input 2 ).
            run bgelib-tag-put( input 2, input "goodsSaleExciser"      , input string( buf_crsa_stk-line.excise-rubl     ) , input 2 ).
        end.        /* NOT ( if v-r-b-is-base = yes ) */
    end. /*if available buf_crsa_stk-line*/

        if p-parts = "yes" then do:
          for each buf_reserv_parts where buf_reserv_parts.artic = p-artic
                                  and buf_reserv_parts.prod-code = p-prod-code
                                  and buf_reserv_parts.prod-type = p-prod-type
                                  and buf_reserv_parts.obj-code = p-obj-code
                                  and buf_reserv_parts.obj-type = p-obj-type
                                  and buf_reserv_parts.out-code = {&free-code}:
                assign
                v-in-code = buf_reserv_parts.in-code
                v-parts-code = buf_reserv_parts.part-code
                v-fact-qnty = buf_reserv_parts.fact-qnty
                v-supp-type = buf_reserv_parts.supp-type
                v-supp-code = buf_reserv_parts.supp-code
                v-cst-code = buf_reserv_parts.cst-code
                v-price-cli = buf_reserv_parts.price-cli.
    
                run bgelib-tag-open( input 2, input "storeParts", input "" ).
               
                    run bgelib-tag-put( input 3, input "Partsincode"           , input string( v-in-code ) , input 1 ).
                    run bgelib-tag-put( input 3, input "Partspartcode"         , input string( v-parts-code ) , input 1 ).
                    run bgelib-tag-put( input 3, input "PartspartGTD"          , input string( v-cst-code ) , input 1 ).
                    run bgelib-tag-put( input 3, input "Partsfactqnty"         , input string( v-fact-qnty ) , input 1 ).
                    run bgelib-tag-put( input 3, input "Partssupptype"         , input string( v-supp-type ) , input 1 ).
                    run bgelib-tag-put( input 3, input "Partssuppcode"         , input string( v-supp-code ) , input 1 ).
                    run bgelib-tag-put( input 3, input "Partspricecli"         , input string( v-price-cli ) , input 1 ).
                    
                   RUN gds-attr-value (
                        INPUT v-gds-code,
                        INPUT {&attr-alcohol-prod},
                        OUTPUT v-gds-attr-value,
                        OUTPUT v-gds-attr-type
                        ).

                    if v-gds-attr-value = "yes" then do:
                       assign                           
                            v-PartsAlcAttrRefA        = "":U
                            v-PartsAlcAttrRefB        = "":U
                            v-PartsAlcAttrAlcCode     = "":U 
                            v-PartsAlcAttrAlcType     = "":U 
                            v-PartsAlcAttrQu          = "":U
                            v-PartsAlcAttrCertifPath  = "":U
                            v-PartsAlcAttrImpCode     = 0
                            v-PartsAlcAttrImpType     = "":U 
                            v-prod = "":U
                            v-inn = "":U
                            v-kpp = "":U
                            v-naim = "":U 
                            v-PartsAlcAttrProd =  "":U
                            .  
                         run adm/shattri.p (
                            input "get":U
                            ,input '':U
                            ,input 0
                            ,input {&attr-egais-host}
                            ,input {&attr-egais-host_egais-exsys}
                            ,output v-value-character
                            ,output v-value-date
                            ,output v-value-decimal
                            ,output v-value-integer
                            ,output v-value-logical
                            ,output v-value-type
                            ,input-output TABLE thbjattr_thbj-attr
                            ) no-error .
                        assign 
                            v-ext-sys = v-value-integer . 
                                  assign
                                  v-alc-bottling-date = buf_reserv_parts.alc-bottling-date
                                  v-PartsAlcAttrRefA = entry(1,buf_reserv_parts.alc-ref-ab-path, ",")
                                  v-PartsAlcAttrRefB = entry(2,buf_reserv_parts.alc-ref-ab-path, ",")     when num-entries (buf_reserv_parts.alc-ref-ab-path) > 1
                                  v-PartsAlcAttrAlcCode = entry(3,buf_reserv_parts.alc-ref-ab-path,",")   when num-entries (buf_reserv_parts.alc-ref-ab-path) > 2
                                  v-PartsAlcAttrAlcType     = entry(4,buf_reserv_parts.alc-ref-ab-path,",")  when num-entries (buf_reserv_parts.alc-ref-ab-path) > 3
                                  v-alc-quality-certif-path = buf_reserv_parts.alc-quality-certif-path
                                  v-alc-certif-path = buf_reserv_parts.alc-certif-path
                                  v-alc-imp-code = buf_reserv_parts.alc-imp-code
                                  v-alc-imp-type = buf_reserv_parts.alc-imp-type.     
                            if not v-PartsAlcAttrAlcType > '' then  for first buf_alc-type-gds where buf_alc-type-gds.gds-code = buf_goods.gds-code no-lock,
                                      first buf_alc-type where buf_alc-type.alc-type-inner-code = buf_alc-type-gds.alc-type-inner-code no-lock:
                                       v-PartsAlcAttrAlcType =  buf_alc-type.alc-type-code.                                                   
                            end.          
                            find first buf_ext-classif no-lock where buf_ext-classif.classif-subject = {&table_goods}
                            and buf_ext-classif.classif-name = {&extclass_goods_esys}
                            and buf_ext-classif.db-num = 0
                            and buf_ext-classif.key#_one = v-gds-code
                            and buf_ext-classif.key#_two = v-ext-sys
                            no-error.

                            if available buf_ext-classif then 
                            do: 
                                
                                v-prod = entry (1, buf_ext-classif.CharKey_Two, chr(4)).
                                v-inn = entry(4, v-prod, chr(5)) + "/" no-error.
                                v-kpp = entry(2, v-prod, chr(5)) + "/" no-error.
                                v-naim =   entry(3, v-prod, chr(5)) no-error. 
                                v-PartsAlcAttrProd =   v-naim   + v-inn  + v-kpp .
                            end.  
                       
                        run bgelib-tag-open( input 3, input "storePartsAlcAttr", input "" ).
                        run bgelib-tag-put( input 4, input "PartsAlcAttrBottingDate"          , input string( v-alc-bottling-date ) , input 1 ).
                        run bgelib-tag-put( input 4, input "PartsAlcAttrAlcType"          , input string( v-PartsAlcAttrAlcType ) , input 1 ).
                        run bgelib-tag-put( input 4, input "PartsAlcAttrAlcCode"          , input string(v-PartsAlcAttrAlcCode ) , input 1 ).
                        run bgelib-tag-put( input 4, input "PartsAlcAttrRefA"          , input string(v-PartsAlcAttrRefA ) , input 1 ).
                        run bgelib-tag-put( input 4, input "PartsAlcAttrRefB"          , input string( v-PartsAlcAttrRefB  ) , input 1 ).
                        run bgelib-tag-put( input 4, input "PartsAlcAttrProd"          , input string( v-PartsAlcAttrProd ) , input 1 ).
                        run bgelib-tag-put( input 4, input "PartsAlcAttrQualityCertify"       , input string( v-alc-quality-certif-path ) , input 1 ).
                        run bgelib-tag-put( input 4, input "PartsAlcAttrCertifPath"           , input string( v-alc-certif-path ) , input 1 ).
                        run bgelib-tag-put( input 4, input "PartsAlcAttrImpCode"              , input string( v-alc-imp-code ) , input 1 ).
                        run bgelib-tag-put( input 4, input "PartsAlcAttrImpType"              , input string( v-alc-imp-type ) , input 1 ).
                        run bgelib-tag-close( input 3, input "storePartsAlcAttr").
                    end.
                run bgelib-tag-close( input 2, input "storeParts" ).
          end. /*for each buf_reserv_parts where buf_reserv_parts.artic = p-artic*/
        end. /*if p-parts = "yes" then do:*/

    run bgelib-tag-close( input 1, input "storeGoods" ).

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
