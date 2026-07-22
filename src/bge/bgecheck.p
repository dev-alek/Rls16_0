block-level on error undo, throw.
/*

$Revision: 684ed89e110d, 160, rls $
$Author: EShklyar $
$Date: Mon Mar 23 18:05:33 2015 +0400 $
$Workfile: bgecheck.p $
$Archive: bge/bgecheck.p $

Экспорт чеков

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:

Output:

*/
define input parameter p-mainmenu-handle    as handle           no-undo.

define variable vss-revision    as character no-undo init "$Revision: 684ed89e110d, 160, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Mon Mar 23 18:05:33 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bgecheck.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bgecheck.p $":U .
define variable vss-description as character no-undo init "Экспорт чеков".
{ cmp/vssrevis.i        }
{ cmp/trg-def.i         }
{ gbl/temphost.i        }
{ bge/bge-xml.i         }
{ gbl/getcntxt.i def    }
{ str/lib-trn.i         }

&scoped-define version-string "12.2 " + replace( vss-revision + vss-date, "$", " " )

DEFINE TEMP-TABLE tt-cash-pay NO-UNDO
       FIELD pay-code  LIKE ub.cash-pay.cdpay-code
       FIELD curr-code LIKE ub.cash-pay.curr-code
       INDEX pu AS PRIMARY UNIQUE
             pay-code
             curr-code
.


do
on error undo, return error
:
    define variable v-xml-file-name     as character    no-undo.
    define variable v-log-file-name     as character    no-undo.
    define variable v-locked            as logical      no-undo.
    define variable v-date-from         as date         no-undo.
    define variable v-date-to           as date         no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-pay-type-list     as character    no-undo.
    define variable v-gds-type          as character    no-undo. /* тип товара all/fuel/other */
    define variable v-obj-counter       as integer      no-undo.
    define variable v-range             as integer      no-undo.
    define variable v-void-logical      as logical      no-undo.
    define variable v-void-character    as character    no-undo.
    define variable v-cancel            as logical      no-undo.
    define variable v-host-code         as integer      no-undo.

    DEFINE VARIABLE v-pay-type-counter  AS INTEGER      NO-UNDO.
    DEFINE VARIABLE v-need-pay-type     AS LOGICAL      NO-UNDO.

    DEFINE BUFFER   buf_cash-pay        FOR ub.cash-pay.

    { gbl/getcntxt.i get " " p-mainmenu-handle }

    run bge/bge-dper-gds.w (
          input p-mainmenu-handle
        , input 6
        , input ""
        , output v-date-from
        , output v-date-to
        , output v-range
        , output v-host-code
        , output v-obj-list
        , OUTPUT v-pay-type-list
        , OUTPUT v-gds-type
        , output v-void-character
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-cancel
    ).
    if v-cancel = yes
    then do:
        undo, return.
    end.


    IF v-pay-type-list <> "" THEN
    DO v-pay-type-counter = 1 TO NUM-ENTRIES( v-pay-type-list ):
       FIND FIRST buf_cash-pay
            WHERE RECID(buf_cash-pay) = INTEGER(ENTRY( v-pay-type-counter, v-pay-type-list ))
            NO-LOCK
            NO-ERROR.
       IF NOT AVAILABLE buf_cash-pay
       OR CAN-FIND(FIRST tt-cash-pay WHERE tt-cash-pay.pay-code  = buf_cash-pay.cdpay-code
                                       AND tt-cash-pay.curr-code = buf_cash-pay.curr-code
                                     NO-LOCK )
       THEN NEXT.

       CREATE tt-cash-pay.
       ASSIGN
          tt-cash-pay.pay-code  = buf_cash-pay.cdpay-code
          tt-cash-pay.curr-code = buf_cash-pay.curr-code
       .

       RELEASE tt-cash-pay.
       RELEASE buf_cash-pay.
    END.

    IF CAN-FIND(FIRST tt-cash-pay NO-LOCK) THEN ASSIGN
        v-need-pay-type = TRUE
    .


    { gbl/working.i }
    case v-range:
    when 1
    then do:
        run init-temphost.
    end.
    when 2      /* Экспорт по текущей фирме */
    then do:
        run init-temphost.
        for each temp-obj
           where temp-obj.host-code <> v-host-code /*v-cntxt-host-code-obj*/
        :
            delete temp-obj.
        end.
    end.
    when 3      /* Экспорт по списку объектов */
    then do:
        for each temp-obj
        :
            delete temp-obj.
        end.
        do v-obj-counter = 1 to num-entries ( v-obj-list ) / 2
        :
            create temp-obj.
            assign
                temp-obj.obj-type = entry( v-obj-counter * 2 - 1, v-obj-list )
                temp-obj.obj-code = integer( entry( v-obj-counter * 2, v-obj-list ) )
            no-error .
            if error-status :error
            then do:
                run wp-XMLWriteLog in this-procedure (
                    input v-log-file-name
                    , input 1
                    , input substitute( "*** Ошибка чтения списка объектов. &1. &2. &3. &4."
                                        , return-value
                                        , trim(error-status :get-message(1))
                                        , trim(error-status :get-message(2))
                                        , trim(error-status :get-message(3))
                                    )
                ).
                undo, return error .
            end.
            { gbl/hostcode.i
                temp-obj.obj-type
                temp-obj.obj-code
                temp-obj.host-code
            no-error }
            if error-status :error
            then do:
                run wp-XMLWriteLog in this-procedure (
                    input v-log-file-name
                    , input 1
                    , input substitute( "*** Не найдена фирма для объекта &1 &2. &3. &4. &5. &6."
                                        , temp-obj.obj-type
                                        , temp-obj.obj-code
                                        , return-value
                                        , trim(error-status :get-message(1))
                                        , trim(error-status :get-message(2))
                                        , trim(error-status :get-message(3))
                                    )
                ).
                undo, return error .
            end.
        end.
    end.
    end case.
    assign
        v-bge-xml-bgeflold = "new":U
    .
    run xml-bge-filename in this-procedure (
          input "d":U
        , input "":U
        , input no
        , output v-xml-file-name
        , output v-log-file-name
        , output v-locked
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input "&DLine"
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Начало выгрузки чеков в файл &1"
                                , replace( v-xml-file-name, "/", "\" ) + "xm1"
                          )
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: Дата с: &1, дата по: &2"
                                , v-date-from
                                , v-date-to
                          )
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: ... список объектов: &1", v-obj-list )
    ).
    if v-locked = yes
    then do:
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 1
            , input "*** Ошибка выгрузки: Файл выгрузки заблокирован другим процессом."
        ).
        undo, return error .
    end.
    run bge-xml-write-header in this-procedure (
          input v-xml-file-name
        , input "check"
        , input {&version-string}
        , input 0
        , input v-date-from
        , input 0
        , input v-date-to
        , input 0
        , input v-obj-list
        , input "":U
        , input no
        , input no
        , input no
        , input no
        , input no
        , input no
        , input no
        , input no
    ) no-error.
    if error-status :error
    then do:
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 1
            , input substitute( "*** Ошибка записи шапки файла. Процедура: &1 (v.&2 &3). &4. &5"
                                , vss-workfile
                                , vss-revision
                                , vss-description
                                , return-value
                                , trim( error-status :get-message( 1 ) )
                                )
        ).
        undo, return error.
    end.
    for each temp-obj no-lock
    on error undo, return error
    :
        run export-checks-by-object in this-procedure (
              input temp-obj.obj-type
            , input temp-obj.obj-code
            , input v-xml-file-name
            , input v-log-file-name
            , input v-date-from
            , input v-date-to
            , input v-pay-type-list
            , INPUT v-need-pay-type
        ) no-error.
        if error-status :error
        then do:
            run wp-XMLWriteLog in this-procedure (
                  input v-log-file-name
                , input 1
                , input substitute( "*** Ошибка выгрузки чеков по объекту &1 &2. &3. &4. &5."
                                    , temp-obj.obj-type
                                    , temp-obj.obj-code
                                    , return-value
                                    , trim(error-status :get-message(1))
                                    , trim(error-status :get-message(2))
                                    , trim(error-status :get-message(3))
                                  )
            ).
        end.
        

        /*НАДО УБЕДИТЬСЯ ЧТО ВСЕ РАЗМАЗАНО!!*/
        run rep/rpychk0.p (input "r-shftc2"
                        ,input temp-obj.obj-type
                        ,input temp-obj.obj-code
                        ,input ?                    /*p-date-from*/
                        ,input ?                    /*p-date-to*/
                        ,input v-date-from         /*p-shift-date-from*/
                        ,input v-date-to           /*p-shift-date-to*/
                        ,input 1                    /*p-shift-num-start*/
                        ,input 99                   /*p-shift-num-end*/
                        ,input ?                    /*p-inkas-code*/
                        ) no-error.

        if error-status:error then
        do:
             message error-status:get-message(1) view-as alert-box.
        end.        
        
    end.        /* for each temp-obj */
    run xml-bge-write-footer in this-procedure (
        input v-xml-file-name
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Данные выгружены в файл &1"
                                , replace( v-xml-file-name, "/", "\" ) + "xml"
                          )
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input "&DLine"
    ).
    { gbl/stopwork.i }
end.

/*==========================================================================*/
procedure export-checks-by-object :
do
on error undo, return error
:
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-log-file-name as character    no-undo.
define input parameter p-date-from      as date         no-undo.
define input parameter p-date-to        as date         no-undo.
define input parameter p-pay-type-list  as character    no-undo.
define input parameter p-need-pay-type  as logical      no-undo.


    define variable v-gds-code      as integer      no-undo.
    define variable v-artic         as character    no-undo.
    define variable v-prod-type     as character    no-undo.
    define variable v-prod-code     as integer      no-undo.
    define variable v-gds-name      as character    no-undo.
    define variable v-pay-name      as character    no-undo.
    define variable v-curr-abbr     as character    no-undo.
    define variable conf-attr     as character      no-undo.
    define variable conf-par      as character      no-undo.
    define variable par-type      as character      no-undo.
    define variable dflt-cd         as character    no-undo.
    define variable v-finded-pay-type   as logical no-undo.

    define variable v-host-code     as integer      no-undo.
    define variable v-d-card        as character    no-undo.
    define variable v-par-type      as character    no-undo.

    define variable v-param-type      as character  no-undo .
    define variable v-value-character as character  no-undo .
    define variable v-value-date      as date       no-undo .
    define variable v-value-decimal   as decimal    no-undo .
    define variable v-value-integer   as integer    no-undo .
    define variable v-value-logical   as logical    no-undo .
    define variable v-tth             as handle      no-undo .

    define variable v-trim-zero       as logical   no-undo .

    define variable v-is-petrol     as logical      no-undo.
    define variable v-is-pieces     as logical      no-undo.
    define variable v-is-found      as logical      no-undo.

    define variable v-cpline        as integer      no-undo.
    define variable v-pay-code      as integer      no-undo.
    define variable v-eff-doc-qnty  as decimal      no-undo.
    define variable v-pay-card      as character    no-undo.
    define variable v-price-base    as decimal      no-undo.
    define variable v-tot-r-b       as decimal      no-undo.
    define variable v-discnt        as decimal      no-undo.

    define buffer buf_chk-doc       for ub.chk-doc.
    define buffer buf_chk-gds       for ub.chk-gds.
    define buffer buf_bar-code      for ub.bar-code.
    define buffer buf_goods         for ub.goods.
    define buffer buf_chk-pay       for ub.chk-pay.
    define buffer buf_cash-pay      for ub.cash-pay.
    define buffer buf_currency      for ub.currency.
    define buffer buf_chk-gds-pay   for ub.chk-gds-pay.
    
    { gbl/hostcode.i
        p-obj-type
        p-obj-code
        v-host-code
    }
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  {&attr-bge-export}
                      , input  {&attr-bge-export_bgedcard}
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-trim-zero
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-trim-zero = no
      .
    end.
    delete object v-tth.

    /*сначала определим маркетерный ли этой объект*/
    /*считаем dflt-cd*/
    { gbl/dflt-cd.i p-obj-type p-obj-code dflt-cd }

    output stream stmxmlout to value( p-xml-file-name + "xm1" ) convert target "1251" append.
    for each buf_chk-doc no-lock
       where buf_chk-doc.obj-type = p-obj-type
         and buf_chk-doc.obj-code = p-obj-code
         and buf_chk-doc.chk-date >= p-date-from
         and buf_chk-doc.chk-date <= p-date-to
         on error undo, return error
    :
        if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next.

        IF p-need-pay-type THEN
        _search-pay-type:
        DO:
          ASSIGN
             v-finded-pay-type = FALSE
          .
          FOR EACH buf_chk-pay WHERE buf_chk-pay.doc-code = buf_chk-doc.doc-code
                             NO-LOCK
                             :
            IF CAN-FIND(FIRST tt-cash-pay WHERE tt-cash-pay.pay-code  = buf_chk-pay.pay-code
                                            AND tt-cash-pay.curr-code = buf_chk-pay.curr-code
                                          NO-LOCK )
            THEN DO:
                 ASSIGN
                    v-finded-pay-type = TRUE
                 .
                 LEAVE _search-pay-type.
            END.
          END.
        END.
        IF      p-need-pay-type
        AND NOT v-finded-pay-type THEN NEXT.

        /* проверим тип товара */
        if not v-gds-type = "all" then do:
            assign v-is-found = false .
            /*переберем переберем товары по чеку*/
            for each buf_chk-gds no-lock
            where buf_chk-gds.doc-code = buf_chk-doc.doc-code :
                /*найдем код товара по баркоду*/
                find first buf_bar-code no-lock
                where buf_bar-code.b-code = buf_chk-gds.b-code
                no-error.
                if available buf_bar-code then do:
                    /*найдем товар по коду*/
                    find first buf_goods no-lock
                    where buf_goods.gds-code = buf_bar-code.gds-code
                    no-error.
                    if available buf_goods then do:
                        /*это топливо?*/
                        { str/is-petrl.i buf_goods.artic buf_goods.prod-type buf_goods.prod-code v-is-petrol v-is-pieces no-error }
                        if not error-status :error then do:
                            assign v-is-found = true .
                        end.
                    end.
                end.
            end. /*for each buf_chk-gds*/
            /*если все данные получили без ошибок*/
            if v-is-found then do:
                /*если фильтр по топливу, а товар не топливо, то чек пропускаем*/
                if v-gds-type = "fuel" and not v-is-petrol then next.
                /*если фильтр по НЕ топливу, а товар топливо, то чек пропускаем*/
                if v-gds-type = "other" and v-is-petrol then next.
            end.
        end. /*if not v-gds-type = "all"*/

        assign
            v-d-card = buf_chk-doc.d-card
        .
        if v-trim-zero = yes
        then do:
            assign
                v-d-card = left-trim( v-d-card, "0":U )
            .
        end.
        run wp-xmltagopen in this-procedure ( input 2, input "checkHead", input "" ).
        run wp-xmltagput in this-procedure ( input 3, input "ID"        , input string( buf_chk-doc.doc-code    ), input 0 ).
        run wp-xmltagput in this-procedure ( input 3, input "objType"   , input string( buf_chk-doc.obj-type    ), input 0 ).
        run wp-xmltagput in this-procedure ( input 3, input "objCode"   , input string( buf_chk-doc.obj-code    ), input 0 ).
        run wp-xmltagput in this-procedure ( input 3, input "date"      , input string( buf_chk-doc.chk-date, "99/99/9999" ), input 0 ).
        run wp-xmltagput in this-procedure ( input 3, input "time"      , input string( buf_chk-doc.chk-time, "HH:MM:SS" ), input 0 ).
        run wp-xmltagput in this-procedure ( input 3, input "checkNum"  , input string( buf_chk-doc.chk-num     ), input 0 ).
        run wp-xmltagput in this-procedure ( input 3, input "deskNum"   , input string( buf_chk-doc.pay-desk    ), input 0 ).
        run wp-xmltagput in this-procedure ( input 3, input "cardNum"   , input string( v-d-card                ), input 0 ).
        run wp-xmltagclose in this-procedure ( input 2, input "checkHead").
        for each buf_chk-gds no-lock
           where buf_chk-gds.doc-code = buf_chk-doc.doc-code
        on error undo, return error
        :
            find first buf_bar-code no-lock
                 where buf_bar-code.b-code = buf_chk-gds.b-code
            no-error.
            if available buf_bar-code
            then do:
                find first buf_goods no-lock
                     where buf_goods.gds-code = buf_bar-code.gds-code
                .
                if available buf_goods
                then do:
                    assign
                        v-gds-code  = buf_goods.gds-code
                        v-artic     = buf_goods.artic
                        v-prod-type = buf_goods.prod-type
                        v-prod-code = buf_goods.prod-code
                        v-gds-name  = buf_goods.gds-name
                    .
                end.
                else do:
                    run wp-XMLWriteLog in this-procedure (
                          input p-log-file-name
                        , input 1
                        , input substitute( "*** Не найден товар для бар-кода по чеку &1. Объект &2 &3. Бар-код &4. Код товара &5."
                                            , buf_chk-gds.doc-code
                                            , temp-obj.obj-type
                                            , temp-obj.obj-code
                                            , buf_chk-gds.b-code
                                            , buf_bar-code.gds-code
                                           )
                    ).
                end.
            end.
            else do:
                run wp-XMLWriteLog in this-procedure (
                      input p-log-file-name
                    , input 1
                    , input substitute( "*** Не найден бар-код для чека &1. Объект &2 &3. Бар-код &4."
                                        , buf_chk-gds.doc-code
                                        , temp-obj.obj-type
                                        , temp-obj.obj-code
                                        , buf_chk-gds.b-code
                                       )
                ).
            end.
            run wp-xmltagopen in this-procedure ( input 2, input "checkBody", input "" ).
            run wp-xmltagput in this-procedure ( input 3, input "ID"        , input string( buf_chk-gds.doc-code    ), input 0 ).
            run wp-xmltagput in this-procedure ( input 3, input "bcode"     , input string( buf_chk-gds.b-code      ), input 0 ).
            run wp-xmltagput in this-procedure ( input 3, input "gdsCode"   , input string( v-gds-code              ), input 0 ).
            run wp-xmltagput in this-procedure ( input 3, input "artic"     , input string( v-artic                 ), input 0 ).
            run wp-xmltagput in this-procedure ( input 3, input "prodType"  , input string( v-prod-type             ), input 0 ).
            run wp-xmltagput in this-procedure ( input 3, input "prodCode"  , input string( v-prod-code             ), input 0 ).
            run wp-xmltagput in this-procedure ( input 3, input "gdsName"   , input string( v-gds-name              ), input 0 ).
            run wp-xmltagput in this-procedure ( input 3, input "price"     , input string( buf_chk-gds.price-base  ), input 0 ).
            run wp-xmltagput in this-procedure ( input 3, input "qnty"      , input string( buf_chk-gds.doc-qnty    ), input 0 ).
            run wp-xmltagput in this-procedure ( input 3, input "discnt"    , input string( buf_chk-gds.discnt      ), input 0 ).
            for each buf_chk-gds-pay no-lock
                 where buf_chk-gds-pay.doc-code = buf_chk-gds.doc-code and
                 buf_chk-gds-pay.line-num = buf_chk-gds.line-num:
              
                    assign
                        v-cpline = buf_chk-gds-pay.cpline-num
                        v-pay-code = buf_chk-gds-pay.pay-code
                        v-eff-doc-qnty = buf_chk-gds-pay.eff-doc-qnty
                        v-pay-card = buf_chk-gds-pay.pay-card
                        v-price-base = buf_chk-gds-pay.price-base
                        v-tot-r-b = buf_chk-gds-pay.tot-r-b
                        v-discnt = buf_chk-gds-pay.discnt 
                    .
                 
                run wp-xmltagopen in this-procedure ( input 3, input "checkBodyPay", input "" ).
                  run wp-xmltagput in this-procedure ( input 4, input "cpLine"       , input string( v-cpline             ), input 0 ).
                  run wp-xmltagput in this-procedure ( input 4, input "payCode"      , input string( v-pay-code           ), input 0 ).
                  run wp-xmltagput in this-procedure ( input 4, input "totrb"        , input string( v-tot-r-b            ), input 0 ).
                  run wp-xmltagput in this-procedure ( input 4, input "pricebase"    , input string( v-price-base         ), input 0 ).
                  run wp-xmltagput in this-procedure ( input 4, input "numpaycard"   , input string( v-pay-card           ), input 0 ).
                  run wp-xmltagput in this-procedure ( input 4, input "discnt"       , input string( v-discnt             ), input 0 ).
                  run wp-xmltagput in this-procedure ( input 4, input "effdocqnty"   , input string( v-eff-doc-qnty       ), input 0 ).
                run wp-xmltagclose in this-procedure ( input 3, input "checkBodyPay" ).
            end.            
            run wp-xmltagclose in this-procedure ( input 2, input "checkBody" ).
        end.        /* for each buf_chk-gds */
        for each buf_chk-pay no-lock
           where buf_chk-pay.doc-code = buf_chk-doc.doc-code
        on error undo, return error
        :
            find first buf_cash-pay no-lock
                 where buf_cash-pay.cdpay-code  = buf_chk-pay.pay-code
                   AND buf_cash-pay.curr-code   = buf_chk-pay.curr-code
            no-error.
            if available buf_cash-pay
            then do:
                assign
                v-pay-name = buf_cash-pay.obj-name
                .
                find first buf_currency no-lock
                     where buf_currency.curr-code = buf_chk-pay.curr-code
                .
                if available buf_currency
                then do:
                    assign
                        v-curr-abbr  = buf_currency.curr-abbr
                    .
                end.
                else do:
                    run wp-XMLWriteLog in this-procedure (
                          input p-log-file-name
                        , input 1
                        , input substitute( "*** Не найдена валюта для платежа по чеку &1. Объект &2 &3. Платеж &4. Код валюты &5."
                                            , buf_chk-pay.doc-code
                                            , temp-obj.obj-type
                                            , temp-obj.obj-code
                                            , buf_chk-pay.pay-code
                                            , buf_chk-pay.curr-code
                                           )
                    ).
                end.
            end.
            else do:
                run wp-XMLWriteLog in this-procedure (
                      input p-log-file-name
                    , input 1
                    , input substitute( "*** Не найден платеж для чека &1. Объект &2 &3. Платеж &4. Код валюты &5"
                                        , buf_chk-pay.doc-code
                                        , temp-obj.obj-type
                                        , temp-obj.obj-code
                                        , buf_chk-pay.pay-code
                                        , buf_chk-pay.curr-code
                                       )
                ).
            end.



            run wp-xmltagopen in this-procedure ( input 2, input "checkPays", input "" ).
            run wp-xmltagput in this-procedure ( input 3, input "ID"        , input string( buf_chk-pay.doc-code    ), input 0 ).
            run wp-xmltagput in this-procedure ( input 3, input "payCode"   , input string( buf_chk-pay.pay-code    ), input 0 ).
            run wp-xmltagput in this-procedure ( input 3, input "currCode"  , input string( buf_chk-pay.curr-code   ), input 0 ).
            run wp-xmltagput in this-procedure ( input 3, input "payName"   , input string( v-pay-name              ), input 0 ).
            run wp-xmltagput in this-procedure ( input 3, input "currAbbr"  , input string( v-curr-abbr             ), input 0 ).
            run wp-xmltagput in this-procedure ( input 3, input "totSum"    , input string( buf_chk-pay.tot-sum     ), input 0 ).
            run wp-xmltagput in this-procedure ( input 3, input "totBase"   , input string( buf_chk-pay.tot-base    ), input 0 ).
            run wp-xmltagput in this-procedure ( input 3, input "totRubl"   , input string( buf_chk-pay.tot-rubl    ), input 0 ).
            run wp-xmltagput in this-procedure ( input 3, input "payCard"   , input string( buf_chk-pay.pay-card    ), input 0 ).
            run wp-xmltagput in this-procedure ( input 3, input "cashRate"  , input string( buf_chk-pay.cash-rate   ), input 0 ).
            run wp-xmltagclose in this-procedure ( input 2, input "checkPays" ).
      end. /*for each buf_chk-pay*/

    end.        /* for each buf_chk-doc */
    output stream stmxmlout close.
end.
end procedure. /* export-checks-by-object */