block-level on error undo, throw.
/*

$Revision: 2d6430604525, 1301, rls $
$Author: EShklyar $
$Date: Tue Apr 10 12:04:11 2018 +0300 $
$Workfile: bgeprc.p $
$Archive: bge/bgeprc.p $

Экспорт цен товаров.

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:
    p-shedule        as logical    - yes для выгрузки по расписанию
    p-mode           as character  - "list":U для выгрузки цен по списку кодов товаров из temp_bgelib_goods
    table for temp_bgelib_goods    - список кодов товаров для выгрузки (только при p-mode = "list":U)
    p-host-code      as integer    - код текущей фирмы
    p-range          as integer    - диапазон: 1 - глобально, 2 - по тек. фирме, 3 - список объектов
    p-obj-list       as character  - список объектов для p-range = 3

Output:

*/

define variable vss-revision    as character no-undo init "$Revision: 2d6430604525, 1301, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Apr 10 12:04:11 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bgeprc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bgeprc.p $":U .
define variable vss-description as character no-undo init "Экспорт цен товаров.".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ str/lib-trn.i     }
{ gbl/temphost.i    }
{ bge/bgelib.i      }
{ str/get-pr.i def  }
{ gbl/getcntxt.i def }

&scoped-define version-string "14.0 " + replace( vss-revision + vss-date, "$", " " )
&scoped-define parameters-amount 4

define input parameter parparentproc    as handle           no-undo.
define input parameter p-shedule        as logical          no-undo.
define input parameter p-mode           as character        no-undo.
define input parameter table for temp_bgelib_goods .
define input parameter p-host-code      as integer          no-undo.
define input parameter p-range          as integer          no-undo.
define input parameter p-obj-list       as character        no-undo.
define input parameter p-edt-handle     as handle           no-undo.
define input parameter p-cnt-handle     as handle           no-undo.

    define variable v-have-rights       as logical          no-undo.
    define variable v-log-string        as character        no-undo.
    define variable v-obj-counter       as integer          no-undo.
    define variable v-xml-file-name     as character        no-undo.
    define variable v-log-file-name     as character        no-undo.
    define variable v-list-file-name    as character        no-undo.
    define variable v-xml-file-number   as integer          no-undo.
    define variable v-cancel            as logical          no-undo.
    define variable v-parameter-list    as character        no-undo.
do
on error undo, return error
:
    process events.
    /* Права на экспорт справочников*/
    if p-shedule = no
    then do:
        { gbl/getcntxt.i get }
        { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_references_export':U
        {&cntxt-global}
        0
        '':U
        0
        0
        0
        0
        yes
        v-have-rights
        }
        if not v-have-rights
        then do:
            undo, return error.
        end.
    end.
    run bgelib-read-config in this-procedure no-error.
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка чтения параметров экспорта."
        skip "Для экспорта данных будут приняты параметры по умолчанию."
        skip return-value
        skip trim(error-status :get-message(1))
             trim(error-status :get-message(2))
             trim(error-status :get-message(3))
        view-as alert-box error.
    end.
    run init-temphost.
    assign
        v-log-string = ", по всем фирмам"
    .
    case p-range:
    when 2      /* Экспорт по текущей фирме */
    then do:
        for each temp-obj
        where temp-obj.host-code <> p-host-code
        :
            delete temp-obj.
        end.
        assign
            v-log-string = ", по фирме (код фирмы " + string( p-host-code ) + ")"
        .
    end.
    when 3      /* Экспорт по списку объектов */
    then do:
        for each temp-obj
        :
            delete temp-obj.
        end.
        do v-obj-counter = 1 to num-entries ( p-obj-list ) / 2
        :
            create temp-obj.
            assign
                temp-obj.obj-type = entry( v-obj-counter * 2 - 1, p-obj-list )
                temp-obj.obj-code = integer( entry( v-obj-counter * 2, p-obj-list ) )
            no-error .
            if error-status :error
            then do:
                message
                vss-workfile vss-revision vss-description
                skip "Ошибка чтения списка объектов"
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
            { gbl/hostcode.i temp-obj.obj-type temp-obj.obj-code temp-obj.host-code no-error }
            if error-status :error
            then do:
                message
                vss-workfile vss-revision vss-description
                skip "Не найдена фирма для объекта" temp-obj.obj-type temp-obj.obj-code
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
        end.
        assign
            v-log-string = ", по объектам: " + p-obj-list
        .
    end.
    end case.
    run bgelib-filename in this-procedure (
          input "prc"
        , output v-xml-file-name
        , output v-log-file-name
        , output v-list-file-name
    ).
    run gbl/waitfrsp.w (
          input substring( v-xml-file-name, 1, 1 )
        , input {&bgelib_minimum-free-mbytes}
        , output v-cancel
    ) .
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    run bgelib-write-log in this-procedure (
          input v-log-file-name
        , input 1
        , input "&DLine"
    ).
    run bgelib-write-log in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Начало выгрузки в файл &1"
                                , replace( v-xml-file-name, "/", "\" ) + {&bgelib-temp-extension}
                          )
    ).
    run bgelib-write-log in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: ... список объектов: &1", p-obj-list )
    ).
    assign
        v-parameter-list         =  substitute( "&1,&2,&3,&4,&5,&6,&7,&8,&9"
                                               , {&parameters-amount}
                                               , "docName"          , "prices":U
                                               , "version"          , replace({&version-string},',','')
                                               , "exportDate"       , string( today,          "99/99/9999" )
                                               , "exportTime"       , string( time,           "HH:MM:SS"   )
                                              )
    .
    run bgelib-write-header in this-procedure (
          input yes
        , input v-xml-file-name
        , input v-list-file-name
        , input 1                                           /* p-file-number   */
        , input no                                          /* p-have-prev     */
        , input "":U                                          /* p-prev-filename */
        , input p-obj-list
        , input "":U
        , input v-parameter-list
    ).
    object-of-list:
    for each temp-obj
    :
        run export-prices-by-object in this-procedure (
              input temp-obj.host-code
            , input temp-obj.obj-type
            , input temp-obj.obj-code
            , input v-xml-file-name
            , input v-log-file-name
            , input v-list-file-name
            , input v-xml-file-number
            , output v-xml-file-name
            , output v-xml-file-number
        ) no-error.
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка экспорта цен товаров по объекту"
            skip "Тип объекта:" temp-obj.obj-type
            skip "Код объекта:" temp-obj.obj-code
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
            view-as alert-box error.
            next object-of-list.
        end.
    end.
    run bgelib-write-footer in this-procedure (
          input yes
        , input v-xml-file-name
        , input v-list-file-name
        , input no
        , input ""
    ).
    run bgelib-write-log in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Данные выгружены в файл &1"
                                , replace( v-xml-file-name, "/", "\" ) + "xml"
                          )
    ).
    run bgelib-write-log in this-procedure (
          input v-log-file-name
        , input 1
        , input "&DLine"
    ).
end.



/*==========================================================================*/
procedure export-prices-by-object :
define input parameter p-host-code              as integer      no-undo.
define input parameter p-obj-type               as character    no-undo.
define input parameter p-obj-code               as integer      no-undo.
define input parameter p-xml-file-name          as character    no-undo.
define input parameter p-log-file-name          as character    no-undo.
define input parameter p-list-file-name         as character    no-undo.
define input parameter p-xml-file-number        as integer      no-undo.
define output parameter p-new-xml-file-name     as character    no-undo.
define output parameter p-new-xml-file-number   as integer      no-undo.

    define variable v-cnt-is-active    as logical      no-undo.
    define variable v-goods-counter    as integer      no-undo.

    define buffer buf_goods     for ub.goods.
do
on error undo, return error
:
    assign
        p-new-xml-file-name     = p-xml-file-name
        p-new-xml-file-number   = p-xml-file-number
    .
    run bgelib-write-edt(
          input p-edt-handle
        , input 1
        , input string( p-obj-type ) + " " + string( p-obj-code )
    ).
    output stream stmxmlout to value( p-xml-file-name + {&bgelib-temp-extension} ) convert target "1251" append.
    export-goods-on-object:
    for each buf_goods no-lock
    on error undo, return error
    :
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
                  input v-log-file-name
                , input 1
                , input substitute( "*** ERR *** Не удалось определить цену продажи на объекте &1 &2 для товара с кодом &3"
                                    , p-obj-type
                                    , p-obj-code
                                    , buf_goods.gds-code )
            ).
            undo export-goods-on-object, next export-goods-on-object.
        end.
        if gp-price-sale <> ?
        then do:
            run bgelib-tag-open in this-procedure ( input 0, input "prc", input "" ).
            run bgelib-tag-put in this-procedure ( input 1, input "objType"  , input string( p-obj-type )           , input 1 ).
            run bgelib-tag-put in this-procedure ( input 1, input "objCode"  , input string( p-obj-code )           , input 1 ).
            run bgelib-tag-put in this-procedure ( input 1, input "goodsID"  , input string( buf_goods.gds-code )   , input 1 ).
/*            run bgelib-tag-put in this-procedure ( input 1, input "barcode"  , input string( gp-b-code )            , input 1 ).*/
            run bgelib-tag-put in this-procedure ( input 1, input "docID"    , input string( gp-doc-num )           , input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "price"    , input string( gp-price-sale )        , input 1 ).
            run bgelib-tag-put in this-procedure ( input 1, input "roadTax"  , input string( gp-road-tax   )        , input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "excise"   , input string( gp-excise     )        , input 2 ).
            run bgelib-tag-close in this-procedure ( input 0, input "prc" ).
        end.
        if v-cnt-is-active = no
        then do:
            run bgelib-show-cnt in this-procedure (
                input p-cnt-handle
            ).
            assign
                v-cnt-is-active = yes
            .
            run bgelib-write-cnt(
                  input p-cnt-handle
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
                  input p-cnt-handle
                , input substitute( "Объект: &1&2 Товаров: &3", p-obj-type, p-obj-code, v-goods-counter )
            ).
            process events.
        end.
    end.        /* for each buf_goods */
    output stream stmxmlout close.
    run bgelib-hide-cnt in this-procedure (
        input p-cnt-handle
    ).
end.
end procedure. /* export-prices-by-object */