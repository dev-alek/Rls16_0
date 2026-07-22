block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: exp-ini.p $
$Archive: rcs/exp-ini.p $

Начальная выгрузка данных для RCS

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 04/12/06
Author: Victor Guntner
Creation date: 04/12/06

Input:

Output:

*/

define input parameter p-fi as handle       no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exp-ini.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rcs/exp-ini.p $":U .
define variable vss-description as character no-undo init "Начальная выгрузка данных для RCS".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/temphost.i }
{ rcs/exp-ini.i  }

do
on error undo, return error
:

    run export-goods in this-procedure no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка выгрузки товарного ряда."
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    run export-costs in this-procedure no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка выгрузки приходных цен."
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    run export-prices in this-procedure no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка выгрузки продажных цен."
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
end.

/*==========================================================================*/
procedure export-goods :
do
on error undo, return error
:
    define variable v-count     as integer           no-undo.

    define buffer buf_goods     for goods.
    define buffer buf_bar-code  for bar-code.
    define buffer buf_prod-bc   for prod-bc.

    output stream out-stream to {&bcodes-filename}.

    for each buf_goods no-lock
    :
        for each buf_bar-code no-lock
           where buf_bar-code.gds-code   = buf_goods.gds-code
        :
            export stream out-stream delimiter ","
                buf_goods.artic
                buf_goods.prod-type
                buf_goods.prod-code
                buf_bar-code.b-code
                {&main-barcode}
            .
        end.
        for each buf_prod-bc no-lock
           where buf_prod-bc.b-code   = buf_goods.gds-code
        :
            export stream out-stream delimiter ","
                buf_goods.artic
                buf_goods.prod-type
                buf_goods.prod-code
                buf_prod-bc.b-str
                {&alt-barcode}
            .
        end.
        assign
            v-count = v-count + 1
        .
        if v-count modulo 100 = 0
        then do:
            assign
                p-fi :screen-value = "Обработано товаров: " + string( v-count )
            .
        end.
    end.
    output stream out-stream close.
end.
end procedure. /* export-goods */

/*==========================================================================*/
procedure export-costs :
do
on error undo, return error
:
    define variable v-temp-gds-count     as integer init 0          no-undo.
    define variable v-filled-gds-count   as integer                 no-undo.

    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_doc-line      for doc-line.
    define buffer buf_gds-obj       for gds-obj.

    output stream out-stream to {&goods-filename}.

    RUN init-temphost.
    object-of-base:
    for each temp-obj
    :
        for each temp_gds-costs
        :
            delete temp_gds-costs.
        end.
        assign
            v-filled-gds-count  = 0
            v-temp-gds-count    = 0
        .
        for each buf_gds-obj
           where buf_gds-obj.obj-type = temp-obj.obj-type
             and buf_gds-obj.obj-code = temp-obj.obj-code
        break by buf_gds-obj.artic
              by buf_gds-obj.prod-type
              by buf_gds-obj.prod-code
        :
            if first-of( buf_gds-obj.prod-code )
            then do:
                create temp_gds-costs.
                assign
                    temp_gds-costs.artic        = buf_gds-obj.artic
                    temp_gds-costs.prod-type    = buf_gds-obj.prod-type
                    temp_gds-costs.prod-code    = buf_gds-obj.prod-code
                    temp_gds-costs.empty        = yes
                .
                assign
                    v-temp-gds-count    = v-temp-gds-count + 1
                .
                if v-temp-gds-count modulo 100 = 0
                then do:
                    assign
                        p-fi :screen-value = temp-obj.obj-type + string( temp-obj.obj-code ) + ". Прочитано товаров: " + string( v-temp-gds-count )
                    .
                end.
            end.
        end.
        for each buf_trn-doc no-lock
           where buf_trn-doc.obj-type   = temp-obj.obj-type
             and buf_trn-doc.obj-code   = temp-obj.obj-code
             and buf_trn-doc.internal   = no
             and buf_trn-doc.doc-type   = {&income}
             and buf_trn-doc.status_    = {&fact}
        by doc-date
        :
            for each buf_doc-line no-lock
               where buf_doc-line.doc-code  = buf_trn-doc.doc-code
            :
                find first temp_gds-costs
                     where temp_gds-costs.artic     = buf_doc-line.artic
                       and temp_gds-costs.prod-type = buf_doc-line.prod-type
                       and temp_gds-costs.prod-code = buf_doc-line.prod-code
                       and temp_gds-costs.empty     = yes
                no-error.
                if available temp_gds-costs
                then do:
                    assign
                        temp_gds-costs.cost     = buf_doc-line.price-rubl
                        temp_gds-costs.empty    = no
                        v-filled-gds-count      = v-filled-gds-count + 1
                    .
                    if v-filled-gds-count modulo 100 = 0
                    then do:
                        assign
                            p-fi :screen-value = temp-obj.obj-type + string( temp-obj.obj-code ) + ". Заполнено товаров: " + string( v-filled-gds-count ) + " из " + string( v-temp-gds-count )
                        .
                    end.
                    if v-filled-gds-count   = v-temp-gds-count
                    then do:
                        assign
                            p-fi :screen-value = temp-obj.obj-type + string( temp-obj.obj-code ) + ". Вывод товаров: " + string( v-filled-gds-count ) + " из " + string( v-temp-gds-count )
                        .
                        run export-temp-gds-costs in this-procedure (
                              input temp-obj.host-code
                            , input temp-obj.obj-type
                            , input temp-obj.obj-code
                        ) no-error.
                        if error-status :error
                        then do:
                            undo, return error "export-costs: Ошибка записи товаров с приходными ценами." + {&new-line} + return-value.
                        end.
                        next object-of-base.
                    end.
                end.
            end.        /* for each buf_doc-line */
        end.        /* for each buf_trn-doc */
        assign
            p-fi :screen-value = temp-obj.obj-type + string( temp-obj.obj-code ) + ". Вывод товаров: " + string( v-filled-gds-count ) + " из " + string( v-temp-gds-count )
        .
        run export-temp-gds-costs in this-procedure (
              input temp-obj.host-code
            , input temp-obj.obj-type
            , input temp-obj.obj-code
        ) no-error.
        if error-status :error
        then do:
            undo, return error "export-costs: Ошибка записи товаров с приходными ценами." + {&new-line} + return-value.
        end.
    end.        /* for each temp-obj */
    output stream out-stream close.
end.
end procedure. /* export-costs */

/*==========================================================================*/
procedure export-temp-gds-costs :
do
on error undo, return error
:
define input parameter p-host-code as integer      no-undo.
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.

    for each temp_gds-costs
       where temp_gds-costs.empty = no
    :
        export stream out-stream delimiter ","
            p-host-code
            p-obj-type
            p-obj-code
            temp_gds-costs.artic
            temp_gds-costs.prod-type
            temp_gds-costs.prod-code
            temp_gds-costs.cost
        .
    end.
end.
end procedure. /* export-temp-gds-costs */


/*==========================================================================*/
procedure export-prices :
do
on error undo, return error
:
    define variable v-temp-gds-count     as integer     no-undo.

    define buffer buf_goods             for goods.
    define buffer buf_gds-prt           for gds-prt.
    define buffer buf_price-list        for price-list.
    define buffer buf_root_price-list   for price-list.

    output stream out-stream to {&prices-filename}.

    RUN init-temphost.
    object-of-base:
    for each temp-obj
    :
        assign
            v-temp-gds-count = 0
        .
        for each temp_gds-prices
        :
            delete temp_gds-prices.
        end.
        for each buf_price-list no-lock
           where buf_price-list.obj-type = temp-obj.obj-type
             and buf_price-list.obj-code = temp-obj.obj-code
        break by artic
              by prod-type
              by prod-code
        :
            if first-of( prod-code )
            then do:
                find first buf_goods no-lock
                     where buf_goods.artic      = buf_price-list.artic
                       and buf_goods.prod-type  = buf_price-list.prod-type
                       and buf_goods.prod-code  = buf_price-list.prod-code
                no-error .
                if not available buf_goods
                then do:
                    undo, return error "export-prices: Не удалось найти в базе данных товар для строки прайс-листа."
                                    + {&new-line} + "Артикул товара: " + string( buf_price-list.artic )
                                    + {&new-line} + "Производитель : " + string( buf_price-list.prod-type )
                                    + {&new-line} + "                " + string( buf_price-list.prod-code )
                    .
                end.
                find first buf_gds-prt no-lock
                     where buf_gds-prt.upper-code = buf_goods.prt-root
                no-error .
                if not available buf_gds-prt
                then do:
                    undo, return error "export-prices: В карточке товара неверно задан код шкалы."
                                    + {&new-line} + "Артикул товара: " + string( buf_price-list.artic )
                                    + {&new-line} + "Производитель : " + string( buf_price-list.prod-type )
                                    + {&new-line} + "                " + string( buf_price-list.prod-code )
                    .
                end.
                find last buf_root_price-list no-lock
                    where buf_root_price-list.obj-type  = buf_price-list.obj-type
                      and buf_root_price-list.obj-code  = buf_price-list.obj-code
                      and buf_root_price-list.b-code    = buf_goods.gds-code
                      and buf_root_price-list.price-type = "":U
                use-index fact-close
                no-error.
                if not available buf_root_price-list
                then do:
                    undo, return error "export-prices: Не заданы цены для корня шкалы товара."
                                    + {&new-line} + "Артикул товара: " + string( buf_price-list.artic )
                                    + {&new-line} + "Производитель : " + string( buf_price-list.prod-type )
                                    + {&new-line} + "                " + string( buf_price-list.prod-code )
                    .
                end.
                else do:
                    create temp_gds-prices.
                    assign
                        temp_gds-prices.artic       = buf_price-list.artic
                        temp_gds-prices.prod-type   = buf_price-list.prod-type
                        temp_gds-prices.prod-code   = buf_price-list.prod-code
                        temp_gds-prices.price       = buf_root_price-list.price-sale
                        v-temp-gds-count            = v-temp-gds-count + 1
                    .
                    if v-temp-gds-count modulo 100 = 0
                    then do:
                        assign
                            p-fi :screen-value = temp-obj.obj-type + string( temp-obj.obj-code ) + ". Прочитано цен: " + string( v-temp-gds-count )
                        .
                    end.
                end.
            end.
        end.
        assign
            p-fi :screen-value = temp-obj.obj-type + string( temp-obj.obj-code ) + ". Вывод цен: " + string( v-temp-gds-count )
        .
        run export-temp-gds-prices in this-procedure (
              input temp-obj.host-code
            , input temp-obj.obj-type
            , input temp-obj.obj-code
        ) no-error.
        if error-status :error
        then do:
            undo, return error "export-costs: Ошибка записи товаров с продажными ценами." + {&new-line} + return-value.
        end.
    end.        /* for each temp-obj */
    output stream out-stream close.
end.
end procedure. /* export-costs */

/*==========================================================================*/
procedure export-temp-gds-prices :
do
on error undo, return error
:
define input parameter p-host-code as integer      no-undo.
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.

    for each temp_gds-prices
    :
        export stream out-stream delimiter ","
            p-host-code
            p-obj-type
            p-obj-code
            temp_gds-prices.artic
            temp_gds-prices.prod-type
            temp_gds-prices.prod-code
            temp_gds-prices.price
        .
    end.
end.
end procedure. /* export-temp-gds-costs */