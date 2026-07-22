block-level on error undo, throw.
/*

$Revision: 2d6430604525, 1301, rls $
$Author: EShklyar $
$Date: Tue Apr 10 12:04:11 2018 +0300 $
$Workfile: bgefdoc.p $
$Archive: bge/bgefdoc.p $

Экспорт во Внешнюю Бухгалтерию финансовых документов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06


                list-mode = {&ext-acc-office}     - по объекту
                list-mode = {&ext-acc-office-all} - по фирме
evg+
*/

define input parameter p-date-from      as date       no-undo. /* начало периода экспорта */
define input parameter p-date-to        as date       no-undo. /* конец  периода экспорта */
define input parameter p-range          as integer    no-undo.
define input parameter p-mode           as character  no-undo. /*может быть shd - по распис и пусто */
define input parameter p-host-code      as integer    no-undo .

/*
из bge.p
Диапазон: 1 - глобально, 2 - по списку фирм
если запускаете
из bge-shd.p
1 - Выгружаются все объекты  БД
2- все объекты БД но фирме
3- по списку объектов
*/

define input parameter p-obj-list       as character  no-undo. /* Список фирм для p-range = 2 */
define input parameter p-db-num         as integer    no-undo. /*номер БД*/
define input parameter p-doc-type-list  as character  no-undo. /* Список типов операций */
define input parameter hedt             as handle     no-undo.
define input parameter hcnt             as handle     no-undo.

define variable vss-revision    as character no-undo init "$Revision: 2d6430604525, 1301, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$date: 18.08.03 18:20 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bgefdoc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bgefdoc.p $":U .
define variable vss-description as character no-undo init "Экспорт во Внешнюю Бухгалтерию документов и суммарного расхода по чекам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i  }
{ gbl/temphost.i }
{ bge/bgelib.i   }
{ trg/factord.i }

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
    define variable v-fact-order-from   like ub.stk-tot.fact-order no-undo.
    define variable v-fact-order-to     like ub.stk-tot.fact-order no-undo.
    define variable v-docs-exists       as logical              no-undo.
    define variable v-obj-counter       as integer              no-undo.
    define variable v-db-num            as integer              no-undo.
    define variable v-cancel            as logical              no-undo.
    define variable v-space-available   as logical              no-undo.
    define variable v-parameter-list    as character            no-undo.

    define variable v-obj-type as character no-undo .
    define variable v-obj-code as integer   no-undo .
    define variable v-host-code as integer   no-undo .
    define variable v-host-str  as character no-undo init "" .


    define variable v-ext-fin-doc-type-list as character extent 12 init
    [
        "приходный кассовый ордер",                  {&FDEDT_Income_Cash},
        "расходный кассовый ордер",                  {&FDEDT_Expense_Cash},
        "приходное платежное поручение",             {&FDEDT_Income_Cashless},
        "расходное платежное поручение",             {&FDEDT_Expense_Cashless},
        "приходный АПЗ",                             {&FDEDT_Income_Payoff},
        "расходный АПЗ",                             {&FDEDT_Expense_Payoff}

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
        if p-mode = "shd":U then do:
          create temp-host.
          assign
          temp-host.host-code = p-host-code
          no-error .
              assign
                  v-log-string = " по фирме: " + p-obj-list
              .

        end.
        else do:
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
              assign
                  v-log-string = " по фирмам: " + p-obj-list
              .

          end.
        end.
    end.
    when 3      /* Экспорт по списку объектов --> фирм */
    then do:
        for each temp-host
        :
            delete temp-host.
        end.
        do v-obj-counter = 1 to num-entries ( p-obj-list ) / 2
        :

        v-obj-type = entry( (v-obj-counter * 2 ) - 1 , p-obj-list )     .
        v-obj-code = integer( entry( v-obj-counter * 2, p-obj-list ) )  .

        { gbl/hostcode.i
          v-obj-type
          v-obj-code
          v-host-code }

        if not can-find ( first temp-host where temp-host.host-code = v-host-code) then do:
            v-host-str = v-host-str + "," + string(v-host-code).
            create temp-host.
            assign
            temp-host.host-code = v-host-code
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
        end.
        assign
            v-log-string = " по фирмам объектов: " + v-host-str
        .
    end.

    end case.
    run bgelib-filename in this-procedure (
          input "fin-doc"
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
                                               , "docName"          , "finDocument":U
                                               , "version"          , replace({&version-string},',','')
                                               , "exportDate"       , string( today,          "99/99/9999" )
                                               , "exportTime"       , string( time,           "HH:MM:SS"   )
                                              )
                                  + substitute( ",&1,&2,&3,&4,&5,&6"
                                               , "baseNum"          , p-db-num
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

define buffer buf_fin-doc for ub.fin-doc.

    assign
        p-new-xml-file-name     = p-xml-file-name
        p-new-xml-file-number   = p-xml-file-number
    .
    run bgelib-write-edt( hEDT, 1, string("Фирма :") + string( p-host-code ) ).

    run day-begin-fact-order in this-procedure (
                                                  input  p-date-from
                                                  ,output v-fact-order-from
                                                  ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка определения границ fact-order для поиска"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.

    run factord-end-day  in this-procedure (
                                                  input  p-date-to
                                                  ,output v-fact-order-to
                                                  ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка определения границ fact-order для поиска"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.

    find first buf_fin-doc no-lock where
              buf_fin-doc.host-code = p-host-code
      AND buf_fin-doc.fact-order >= v-fact-order-from
      AND buf_fin-doc.fact-order <= v-fact-order-to
      AND buf_fin-doc.status_ = {&fact} no-error .

    if not available buf_fin-doc
    then do:
        run bgelib-write-edt( hEDT, 4, "В заданном диапазоне дат нет закрытых документов").
        return .
    end.


    run bgelib-show-cnt(hCNT).
/*---E----- Границы fact-order для дат dFrom - dto --------*/
    do v-oper-num = 1 to 6
    :
        if lookup( v-ext-fin-doc-type-list [v-oper-num * 2], p-doc-type-list ) <> 0
        or p-doc-type-list = ""
        then do:
            run bge/fdocoper.p (
                  input p-host-code
                , input v-ext-fin-doc-type-list [v-oper-num * 2]
                , input v-ext-fin-doc-type-list [v-oper-num * 2 - 1]
                , input v-fact-order-from
                , input v-fact-order-to
                , input p-doc-type-list
                , input p-obj-list
                , input p-db-num
                , input p-range
                , input p-mode
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