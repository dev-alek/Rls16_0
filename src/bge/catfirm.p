block-level on error undo, throw.
/*

$Revision: 2d6430604525, 1301, rls $
$Author: EShklyar $
$Date: Tue Apr 10 12:04:11 2018 +0300 $
$Workfile: catfirm.p $
$Archive: bge/catfirm.p $

Экспорт контрагентов

Автор: Хныкин Павел Андреевич
Дата создания: 04/05/06
Author: Pavel Khnykin
Creation date: 04/05/06

Параметры.
    p-mode          - режим экспорта (список):
                        "list"     - экспорт товаров с кодами из временной таблицы temp_bgelib_clients
    p-host-code     - код текущей фирмы
    temp_bgelib_clients - список клиентов для режима "list"
*/

define variable vss-revision    as character no-undo init "$Revision: 2d6430604525, 1301, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$date: 12.08.03 16:43 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: catfirm.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/catfirm.p $":U .
define variable vss-description as character no-undo init "Экспорт контрагентов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i  }
{ gbl/temphost.i }
{ bge/bgelib.i   }

define input parameter p-mode           as character    no-undo.
define input parameter p-host-code      as integer      no-undo.
define input parameter table for temp_bgelib_clients .

&scoped-define version-string "15.0 " + replace( vss-revision + vss-date, "$", " " )
&scoped-define parameters-amount 5

    define variable v-counter           as integer       no-undo.
    define variable v-xml-file-name     as character     no-undo.
    define variable v-log-file-name     as character     no-undo.
    define variable v-list-file-name    as character     no-undo.
    define variable v-xml-file-number   as integer       no-undo.
    define variable v-cancel            as logical       no-undo.
    define variable v-parameter-list    as character     no-undo.

    define buffer buf_clients       for ub.clients.
do
for buf_clients
on error undo, return error
:
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
          input "cli"
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
        , input substitute( "Начало выгрузки справочника контрагентов в файл &1"
                                , replace( v-xml-file-name, "/", "\" ) + {&bgelib-temp-extension}
                          )
    ).
    assign
        v-parameter-list         =  substitute( "&1,&2,&3,&4,&5,&6,&7,&8,&9"
                                               , {&parameters-amount}
                                               , "docName"          , "clients":U
                                               , "version"          , replace({&version-string},',','')
                                               , "exportDate"       , string( today,          "99/99/9999" )
                                               , "exportTime"       , string( time,           "HH:MM:SS"   )
                                              )
                                  + substitute( ",&1,&2"
                                               , "needAllClients"   , v-bgelib-bgeclall
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

    IF lookup( "list":U, p-mode ) = 0
    THEN DO:
        run init-temphost.
        if v-bgelib-bgeclall = no
        and p-host-code <> 0
        then do:        /* экспортировать объекты только заданной фирмы */
            for each temp-obj
            where temp-obj.host-code = p-host-code
            :
                find first buf_clients
                     where buf_clients.obj-type = temp-obj.obj-type
                       and buf_clients.obj-code = temp-obj.obj-code
                no-error.
                if not available buf_clients
                then do:
                    run bgelib-write-log in this-procedure (
                          input v-log-file-name
                        , input 1
                        , input substitute( "*** ERR *** Не найден клиент &1 &2"
                                                , temp-obj.obj-type
                                                , string( temp-obj.obj-code )  )
                    ).
                    undo, next.
                end.
                run write-client in this-procedure (
                      input buf_clients.obj-type
                    , input buf_clients.obj-code
                    , input v-parameter-list
                    , input v-xml-file-name
                    , input v-log-file-name
                    , input v-list-file-name
                    , input v-xml-file-number
                    , output v-xml-file-name
                    , output v-xml-file-number
                ).
            end.
        end.        /* v-bgelib-bgeclall = no */
        else do:        /* экспортировать все объекты */
            for each temp-obj
            :
                find first buf_clients
                     where buf_clients.obj-type = temp-obj.obj-type
                       and buf_clients.obj-code = temp-obj.obj-code
                no-error.
                if error-status :error
                then do:
                    run bgelib-write-log(
                          input v-log-file-name
                        , input 1
                        , input substitute( "*** ERR *** Не найден клиент: &1 &2"
                                                , temp-obj.obj-type
                                                , string( temp-obj.obj-code )  )
                    ).
                    undo, next.
                end.
                run write-client in this-procedure (
                      input buf_clients.obj-type
                    , input buf_clients.obj-code
                    , input v-parameter-list
                    , input v-xml-file-name
                    , input v-log-file-name
                    , input v-list-file-name
                    , input v-xml-file-number
                    , output v-xml-file-name
                    , output v-xml-file-number
                ).
            end.
        end.        /* not ( v-bgelib-bgeclall = no ) */
        for each buf_clients no-lock
           where buf_clients.obj-type <> {&shop}
             and buf_clients.obj-type <> {&stock}
        on error undo, return error
        :
            run write-client in this-procedure (
                  input buf_clients.obj-type
                , input buf_clients.obj-code
                , input v-parameter-list
                , input v-xml-file-name
                , input v-log-file-name
                , input v-list-file-name
                , input v-xml-file-number
                , output v-xml-file-name
                , output v-xml-file-number
            ).
        end.
    END.
    ELSE DO:
        for each temp_bgelib_clients
        on error undo, return error
        :
            find first buf_clients no-lock
                 where buf_clients.obj-type = temp_bgelib_clients.obj-type
                   and buf_clients.obj-code = temp_bgelib_clients.obj-code
            no-error.
            if not available buf_clients
            then do:
                run bgelib-write-log in this-procedure (
                      input v-log-file-name
                    , input 1
                    , input substitute( "*** ERR *** Не найден клиент из списка: &1 &2"
                                            , temp_bgelib_clients.obj-type
                                            , temp_bgelib_clients.obj-code )
                ).
                undo, next.
            end.        /* if not available buf_clients  */
            else do:
                run write-client in this-procedure (
                      input buf_clients.obj-type
                    , input buf_clients.obj-code
                    , input v-parameter-list
                    , input v-xml-file-name
                    , input v-log-file-name
                    , input v-list-file-name
                    , input v-xml-file-number
                    , output v-xml-file-name
                    , output v-xml-file-number
                ).
            end.        /* NOT ( if not available buf_clients  ) */
        end.        /* for each temp_bge-xml_goods */
    END.
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

/*========================================================================*/
procedure write-client:
do
on error undo, return error
:
define input parameter p-obj-type               as character        no-undo.
define input parameter p-obj-code               as integer          no-undo.
define input parameter p-parameter-list         as character    no-undo.
define input parameter p-xml-file-name          as character    no-undo.
define input parameter p-log-file-name          as character    no-undo.
define input parameter p-list-file-name         as character    no-undo.
define input parameter p-xml-file-number        as integer      no-undo.
define output parameter p-last-xml-file-name    as character    no-undo.
define output parameter p-last-xml-file-number  as integer      no-undo.

    define variable v-out-string    as character    no-undo.
    define variable v-need-new-file as logical      no-undo.
    define variable v-void-string   as character      no-undo.
    define variable v-prev-filename as character      no-undo.

    define buffer buf_clients   for ub.clients.
    define buffer buf_person    for ub.person.
    define buffer buf_firm      for ub.firm.

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
              input "cli"
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
    find first buf_clients no-lock
         where buf_clients.obj-type = p-obj-type
           and buf_clients.obj-code = p-obj-code
    .
    run bgelib-tag-open in this-procedure ( input 0, "cli", "").
    run bgelib-tag-put in this-procedure ( input 1, input "clientID"   , input buf_clients.obj-type + string(buf_clients.obj-code), input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "name"       , input buf_clients.obj-name                               , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "orgtype"    , input buf_clients.obj-type                               , input 0 ).

    if buf_clients.stts <> 0
    then do:
        run bgelib-tag-put in this-procedure ( input 1, input "status", input string(buf_clients.stts), input 0 ).
    end.

    run bgelib-tag-put in this-procedure ( input 1, input "isBuyCons" , input string( buf_clients.buy-cons), 3).
    run bgelib-tag-put in this-procedure ( input 1, input "isBuyGoods", input string( buf_clients.buy-gds ), 3).
    run bgelib-tag-put in this-procedure ( input 1, input "isBuyServ" , input string( buf_clients.buy-serv), 3).
    run bgelib-tag-put in this-procedure ( input 1, input "isProd"    , input string( buf_clients.is-prod ), 3).
    run bgelib-tag-put in this-procedure ( input 1, input "isSupCons" , input string( buf_clients.sup-cons), 3).
    run bgelib-tag-put in this-procedure ( input 1, input "isSupGoods", input string( buf_clients.sup-gds ), 3).
    run bgelib-tag-put in this-procedure ( input 1, input "isSupServ" , input string( buf_clients.sup-serv), 3).
    run bgelib-tag-put in this-procedure ( input 1, input "comment"   , input buf_clients.PS, input 0 ).
    run bgelib-tag-close in this-procedure ( input 0, input "cli" ).

    if buf_clients.obj-type = {&cmp}
    then do:
        find first buf_firm no-lock
            where buf_firm.firm-code = buf_clients.obj-code
        no-error.
        if available buf_firm
        then do:
            run bgelib-tag-open in this-procedure ( input 0, "cliFirm", "").
            run bgelib-tag-put in this-procedure ( input 1, input "clientID", input buf_clients.obj-type + string(buf_clients.obj-code), input 0 ).
            run bgelib-tag-put(input 1, input "ename", input buf_firm.engl-name, input 0 ).
            assign
                v-out-string = ( if buf_firm.ind = 0
                                or buf_firm.ind = ?
                                then ""
                                else string( buf_firm.ind ) )
                                + ( if buf_firm.ind = 0
                                    or buf_firm.ind = ?
                                    or buf_firm.city=""
                                    then ""
                                    else ", " )
                                + buf_firm.city
            .
            assign
                v-out-string = v-out-string
                                + ( if v-out-string = ""
                                    or buf_firm.addres1 = ""
                                    or buf_firm.addres1 = ?
                                    then ""
                                    else ", " )
                                + buf_firm.addres1
            .
            assign
                v-out-string = v-out-string
                                + ( if v-out-string = ""
                                    or buf_firm.addres2 = ""
                                    or buf_firm.addres2 = ?
                                    then ""
                                    else ", " )
                                + buf_firm.addres2
            .
            run bgelib-tag-put in this-procedure ( input 1, input "regAddr" , input v-out-string          , input 0).
            run bgelib-tag-put in this-procedure (
                input 1
                , input "postAddr"
                , input buf_firm.post-addr1
                        + ( if buf_firm.post-addr1 = ""
                            or buf_firm.post-addr1 = ?
                            or buf_firm.post-addr2 = ""
                            or buf_firm.post-addr2 = ?
                            then ""
                            else ", " )
                        + buf_firm.post-addr2
                , input 0
            ).
            run bgelib-tag-put in this-procedure (
                input 1
                , input "phones"
                , input buf_firm.phone
                        + ( if buf_firm.phone = ""
                            or buf_firm.phone = ?
                            or buf_firm.fax = ""
                            or buf_firm.fax = ?
                            then ""
                            else ", " )
                        + buf_firm.fax
                        + ( if buf_firm.phone = ""
                            or buf_firm.phone = ?
                            or buf_firm.fax = ""
                            or buf_firm.fax = ?
                            then ""
                            else "(f)" )
                , input 0
            ).
            run bgelib-tag-put in this-procedure ( input 1, input "inn"  , input buf_firm.inn  , input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "okonh", input buf_firm.okonh, input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "okpo" , input buf_firm.okpo , input 0 ).
            run bgelib-tag-close in this-procedure ( input 0, "cliFirm" ).

            define buffer buf_sysconf       for ub.sysconf.
            define buffer buf_fin-schet     for ub.fin-schet.
            define buffer buf_fin-bank      for ub.fin-bank.

            for each buf_sysconf no-lock
            on error undo, return error
            :
                for each buf_fin-schet no-lock
                   where buf_fin-schet.host-code = buf_sysconf.host-code
                     and buf_fin-schet.cli-type  = buf_clients.obj-type
                     and buf_fin-schet.cli-code  = buf_clients.obj-code
                on error undo, return error
                :
                    if buf_fin-schet.status_  <> {&deleted-status}
                    then do:
                        run bgelib-tag-open in this-procedure ( input 0, "cliFirmBank", "").
                        run bgelib-tag-put in this-procedure ( input 1, input "clientID"    , input buf_clients.obj-type + string(buf_clients.obj-code), input 0 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "hostFirmCode"  , input string( buf_fin-schet.host-code ) , input 0 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "accountNumber" , input string( buf_fin-schet.r-schet )   , input 0 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "bAccountNumber", input string( buf_fin-schet.c-schet )   , input 0 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "currCode"      , input string( buf_fin-schet.curr-code ) , input 0 ).
                        find first buf_fin-bank no-lock
                             where buf_fin-bank.host-code = p-host-code
                               and buf_fin-bank.code-bank = buf_fin-schet.code-bank
                        no-error.
                        if available buf_fin-bank
                        then do:
                            run bgelib-tag-put in this-procedure ( input 1, input "bankCode"      , input string( buf_fin-schet.code-bank ) , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "bankName"      , input string( buf_fin-bank.bank-name )  , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "Address1"      , input string( entry(1, buf_fin-bank.addres, {&delim-par}))    , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "Address2"      , input string( buf_fin-bank.addres1 )    , input 0 ).
                        end.
                        run bgelib-tag-close in this-procedure ( input 0, "cliFirmBank" ).
                    end.
                end.        /* for each buf_fin-schet */
            end.        /* for each buf_sysconf */
        end.        /* if available buf_firm */
    end.        /* if buf_clients.obj-type = {&cmp} */
    if buf_clients.obj-type = {&prs}
    then do:
        find first buf_person no-lock
            where buf_person.psn-code = buf_clients.obj-code
        no-error.
        if available buf_person
        and buf_person.inn <> ""
        and buf_person.inn <> ?
        then do:
            run bgelib-tag-open in this-procedure ( input 0, "cliPerson", "" ).
            run bgelib-tag-put in this-procedure ( input 1, input "inn", input buf_person.inn, input 0 ).
            run bgelib-tag-close in this-procedure ( input 0, "cliPerson" ).
        end.
    end.        /* if buf_clients.obj-type = {&prs} */
    output stream stmxmlout close.
end.
end procedure.