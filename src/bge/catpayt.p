block-level on error undo, throw.
/*

$Revision: 2d6430604525, 1301, rls $
$Author: EShklyar $
$Date: Tue Apr 10 12:04:11 2018 +0300 $
$Workfile: catpayt.p $
$Archive: bge/catpayt.p $

Выгрузка справочника видов оплат

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:

Output:

*/
define input parameter p-host-code          as integer      no-undo.
define input parameter p-rec-amount         as integer      no-undo.
define input parameter p-rec-code-list      as character    no-undo.

define variable vss-revision    as character no-undo init "$Revision: 2d6430604525, 1301, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Apr 10 12:04:11 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: catpayt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/catpayt.p $":U .
define variable vss-description as character no-undo init "Выгрузка справочника видов оплат".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ bge/bgelib.i   }

&scoped-define version-string "12.3 " + replace( vss-revision + vss-date, "$", " " )
&scoped-define parameters-amount 4

do
on error undo, return error
:
    define variable v-counter           as integer       no-undo.
    define variable v-xml-file-name     as character     no-undo.
    define variable v-log-file-name     as character     no-undo.
    define variable v-list-file-name    as character     no-undo.
    define variable v-xml-file-number   as integer       no-undo.
    define variable v-cancel            as logical       no-undo.
    define variable v-parameter-list    as character     no-undo.

    define buffer buf_pay-type      for ub.pay-type.

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
    run bgelib-filename in this-procedure (
          input "ptp"
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
        , input substitute( "Начало выгрузки справочника видов оплат в файл &1"
                                , replace( v-xml-file-name, "/", "\" ) + {&bgelib-temp-extension}
                          )
    ).
    if p-rec-amount = ?
    or p-rec-code-list = ?
    or ( p-rec-amount <> 0
        and num-entries( p-rec-code-list ) = 0 )
    then do:
        run bgelib-write-log in this-procedure (
              input v-log-file-name
            , input 1
            , input "Неверно заданы входные параметры."
        ).
        undo, return error.
    end.
    assign
        v-parameter-list         =  substitute( "&1,&2,&3,&4,&5,&6,&7,&8,&9"
                                               , {&parameters-amount}
                                               , "docName"          , "payType":U
                                               , "version"          , replace({&version-string},',','')
                                               , "exportDate"       , string( today,          "99/99/9999" )
                                               , "exportTime"       , string( time,           "HH:MM:SS"   )
                                              )
        v-xml-file-number       =   1
    .
    run bgelib-write-header in this-procedure (
          input yes
        , input v-xml-file-name
        , input v-list-file-name
        , input v-xml-file-number                           /* p-file-number   */
        , input no                                          /* p-have-prev     */
        , input ""                                          /* p-prev-filename */
        , input ""
        , input ""
        , input v-parameter-list
    ).
    for each buf_pay-type no-lock
    :
        run write-body in this-procedure (
              input buf_pay-type.obj-code
            , input v-parameter-list
            , input v-xml-file-name
            , input v-log-file-name
            , input v-list-file-name
            , input v-xml-file-number
            , output v-xml-file-name
            , output v-xml-file-number
        ) no-error.
        if error-status :error
        then do:
            run bgelib-write-log in this-procedure (
                  input v-log-file-name
                , input 1
                , input substitute(  "*** ERR: *** Ошибка выгрузки вида оплаты с кодом &1. &2. &3.", buf_pay-type.obj-code, trim(error-status :get-message(1)), trim(error-status :get-message(2)) )
            ).
        end.
    end.        /* for each buf_dis-card */
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
procedure write-body :
do
on error undo, return error
:
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-parameter-list         as character    no-undo.
define input parameter p-xml-file-name          as character    no-undo.
define input parameter p-log-file-name          as character    no-undo.
define input parameter p-list-file-name         as character    no-undo.
define input parameter p-xml-file-number        as integer      no-undo.
define output parameter p-last-xml-file-name    as character    no-undo.
define output parameter p-last-xml-file-number  as integer      no-undo.

    define variable v-need-new-file as logical      no-undo.
    define variable v-void-string   as character      no-undo.
    define variable v-prev-filename as character      no-undo.

    define buffer buf_pay-type      for ub.pay-type.

    assign
        p-last-xml-file-name   = p-xml-file-name
        p-last-xml-file-number = p-xml-file-number
    .
    run bgelib-check-file-size in this-procedure (
          input p-xml-file-name + {&bgelib-temp-extension}
        , output v-need-new-file
    ).
    if v-need-new-file = yes
    then do:
        assign
            v-prev-filename = p-xml-file-name
        .
        run bgelib-filename in this-procedure (
              input "ptp"
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
            , input ""
            , input ""
            , input p-parameter-list
        ).
        assign
            v-need-new-file = no
        .
    end.        /* if v-need-new-file = yes */
    output stream stmxmlout to value( p-xml-file-name + {&bgelib-temp-extension} ) convert target "1251" append.
    find first buf_pay-type no-lock
         where buf_pay-type.obj-code = p-obj-code
    .
run bgelib-tag-open in this-procedure ( input 1, input "ptp", input "").
run bgelib-tag-put in this-procedure ( input 2, "payTypeID"      , input string( buf_pay-type.obj-code ), input 0 ).
run bgelib-tag-put in this-procedure ( input 2, "name"           , input string( buf_pay-type.obj-name ), input 0 ).
run bgelib-tag-close in this-procedure ( input 1, input "ptp" ).
    output stream stmxmlout close.
end.
end procedure. /* write-body */