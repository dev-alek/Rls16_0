block-level on error undo, throw.
/*

$Revision: 2d6430604525, 1301, rls $
$Author: EShklyar $
$Date: Tue Apr 10 12:04:11 2018 +0300 $
$Workfile: bgecont.p $
$Archive: bge/bgecont.p $

Экспорт во Внешнюю Бухгалтерию договоров      list-mode = {&ext-acc-office}     - по объекту    list-mode = {&ext-acc-office-all} - по фирме

Автор: Хныкин Павел Андреевич
Дата создания: 10/09/07
Author: Pavel Khnykin
Creation date: 10/09/07


*/

define input parameter p-date-from      as date       no-undo. /* начало периода экспорта */
define input parameter p-date-to        as date       no-undo. /* конец  периода экспорта */
define input parameter p-range          as integer    no-undo. /* Диапазон: 1 - глобально, 2 - по списку фирм */
define input parameter p-obj-list       as character  no-undo. /* Список фирм для p-range = 2 */
define input parameter p-doc-type-list  as character  no-undo. /* Список типов операций */
define input parameter hedt             as handle     no-undo.
define input parameter hcnt             as handle     no-undo.

define variable vss-revision    as character no-undo init "$Revision: 2d6430604525, 1301, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$date: 18.08.03 18:20 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bgecont.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bgecont.p $":U .
define variable vss-description as character no-undo init "Экспорт во Внешнюю Бухгалтерию договоров".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/temphost.i }
{ bge/bgelib.i   }

do
on error undo, return error
:

&scoped-define version-string "14.0 " + replace( vss-revision + vss-date, "$", " " )
&scoped-define parameters-amount 7

    define variable v-xml-file-name     as character            no-undo. /* имя файла вывода */
    define variable v-log-file-name     as character            no-undo. /* имя log-файла */
    define variable v-list-file-name    as character            no-undo. /* имя log-файла */
    define variable v-xml-file-number   as integer              no-undo.
    define variable v-log-string        as character            no-undo. /* имя log-файла */
    define variable v-oper-num          as integer              no-undo. /* номер операции*/
    define variable v-docs-exists       as logical              no-undo.
    define variable v-obj-counter       as integer              no-undo.
    define variable v-db-num            as integer              no-undo.
    define variable v-cancel            as logical              no-undo.
    define variable v-space-available   as logical              no-undo.
    define variable v-parameter-list    as character            no-undo.

    define variable v-ext-fin-doc-type-list as character extent 4 init
    [
        "с поставщиками",                  {&income},
        "с покупателями",                  {&expense}

    ]                                                           no-undo.

    run init-temphost.
    assign
        v-log-string = " по всем фирмам"
    .
    case p-range:
    when 2      /* Экспорт по списку фирм */
    then do:
        for each temp-host
        :
            delete temp-host.
        end.
        do v-obj-counter = 1 to num-entries ( p-obj-list ) / 2
        :
            create temp-host.
            assign
            temp-host.host-code = integer( entry( v-obj-counter * 2, p-obj-list ) )
            no-error .
            if error-status :error
            then do:
                message
                vss-workfile vss-revision vss-description
                skip "Ошибка чтения списка фирм"
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
        end.
        assign
            v-log-string = " по фирмам: " + p-obj-list
        .
    end.
    end case.
    run bgelib-filename in this-procedure (
          input "contract"
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
        , input substitute( "................с параметрами: Дата с: &1, дата по: &2"
                                , p-date-from
                                , p-date-to
                          )
    ).
    run bgelib-write-log in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: ... &1: &2"
                           ,v-log-string
                           )
    ).
    run bgelib-write-log in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: ... типы документов: &1", p-doc-type-list )
    ).
    assign
        v-parameter-list         =  substitute( "&1,&2,&3,&4,&5,&6,&7,&8,&9"
                                               , {&parameters-amount}
                                               , "docName"          , "Contract":U
                                               , "version"          , replace({&version-string},',','')
                                               , "exportDate"       , string( today,          "99/99/9999" )
                                               , "exportTime"       , string( time,           "HH:MM:SS"   )
                                              )
                                  + substitute( ",&1,&2,&3,&4,&5,&6"
                                               , "baseNum"          , 0
                                               , "dateFrom"         , string( p-date-from,    "99/99/9999" )
                                               , "dateto"           , string( p-date-to,      "99/99/9999" )
                                              )
    .
    run bgelib-write-header in this-procedure (
          input yes
        , input v-xml-file-name
        , input v-list-file-name
        , input 1                                           /* p-file-number   */
        , input no                                          /* p-have-prev     */
        , input ""                                          /* p-prev-filename */
        , input p-obj-list
        , input p-doc-type-list
        , input v-parameter-list
    ).
    object-of-list:
    for each temp-host
    :
        run export-docs-by-host (
              input temp-host.host-code
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
            skip "Ошибка экспорта финансовых документов по фирме"
            skip "Код фирмы:" temp-host.host-code
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
procedure export-docs-by-host :
do
on error undo, return error
:
define input parameter p-host-code              as integer      no-undo.
define input parameter p-xml-file-name          as character    no-undo.
define input parameter p-log-file-name          as character    no-undo.
define input parameter p-list-file-name         as character    no-undo.
define input parameter p-xml-file-number        as integer      no-undo.
define output parameter p-new-xml-file-name     as character    no-undo.
define output parameter p-new-xml-file-number   as integer      no-undo.

define buffer buf_contract for ub.contract.

    assign
        p-new-xml-file-name     = p-xml-file-name
        p-new-xml-file-number   = p-xml-file-number
    .
    run bgelib-write-edt( hEDT, 1, string("Фирма :") + string( p-host-code ) ).

    find first buf_contract no-lock where
          buf_contract.host-code = p-host-code
      AND buf_contract.contract-date >= p-date-from
      AND buf_contract.contract-date <= p-date-to
      AND buf_contract.status_ = {&current-contr}
    no-error .

    if not available buf_contract
    then do:
        run bgelib-write-edt( hEDT, 4, "В заданном диапазоне дат нет договоров").
        return .
    end.


    run bgelib-show-cnt(hCNT).
/*---E----- Границы fact-order для дат dFrom - dto --------*/
    do v-oper-num = 1 to 2 :
        if lookup( v-ext-fin-doc-type-list [v-oper-num * 2], p-doc-type-list ) <> 0 or p-doc-type-list = "" then do:
            run bge/contoper.p (
                  input p-host-code
                , input v-ext-fin-doc-type-list [v-oper-num * 2]
                , input v-ext-fin-doc-type-list [v-oper-num * 2 - 1]
                , input p-date-from
                , input p-date-to
                , input p-obj-list
                , input p-doc-type-list
                , input v-parameter-list
                , input p-xml-file-name
                , input p-log-file-name
                , input p-list-file-name
                , input p-xml-file-number
                , input hEDT
                , input hCNT
                , output p-new-xml-file-name
                , output p-new-xml-file-number
            ) no-error.
            if error-status :error
            then do:
                run bgelib-write-edt( hEDT, 1, string(return-value)).
            end.
            assign
                p-xml-file-name     = p-new-xml-file-name
                p-xml-file-number   = p-new-xml-file-number
            .
        end.
    end.
    run bgelib-show-cnt(hCNT).

end.
end procedure. /* export-docs-by-host */