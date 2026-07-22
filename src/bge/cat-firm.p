block-level on error undo, throw.
/*

$Revision: c89b59c2f62e, 135, rls $
$Author: EShklyar $
$Date: Mon Feb 16 20:48:25 2015 +0400 $
$Workfile: cat-firm.p $
$Archive: bge/cat-firm.p $

Экспорт контрагентов

Автор: Хныкин Павел Андреевич
Дата создания: 04/05/06
Author: Pavel Khnykin
Creation date: 04/05/06

Параметры.
    p-mode          - режим экспорта (список):
                        "list"     - экспорт товаров с кодами из временной таблицы temp_bge-xml_clients
    p-host-code     - код текущей фирмы
    temp_bge-xml_clients - список клиентов для режима "list"
*/

define variable vss-revision    as character no-undo init "$Revision: c89b59c2f62e, 135, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Mon Feb 16 20:48:25 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cat-firm.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/cat-firm.p $":U .
define variable vss-description as character no-undo init "Экспорт контрагентов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ gbl/temphost.i }
{ bge/bge-xml.i  }

define input parameter p-mode           as character    no-undo.
define input parameter p-host-code      as integer      no-undo.
define input parameter table for temp_bge-xml_clients .
define input parameter p-file-name      as character    no-undo.

&SCOP SubDir       dict
&SCOP OutFileName  firm

&if OPSYS = "UNIX" &then
&SCOP Slash /
&else
&SCOP Slash ~\
&endif

    define variable strPutOut       AS CHAR FORMAT "X(255)" NO-UNDO.
    define variable strHomeDir      AS CHAR                 NO-UNDO.
    define variable strOutFile      AS CHAR                 NO-UNDO.
    define variable sLogFile        AS CHAR                 NO-UNDO.

    define variable iRepeater       AS INT  INIT 0          NO-UNDO. /* счетчик для цикла */
    define variable bolLKfile       AS LOG  INIT NO         NO-UNDO. /* флаг блокировки */

    define variable ErrorLevel      AS INT                  NO-UNDO. /* ошибка - номер */
    define variable sObjType        AS CHAR                 NO-UNDO.
    define variable iObjCode        AS INT                  NO-UNDO.

    define buffer buf_clients       for ub.clients.
do
for buf_clients
on error undo, return error
:
    run bge-xml-read-config in this-procedure ( input ?
                                              , input ?
    ) no-error.
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
    run bge/bge-ini.p ("bge", OUTPUT strHomeDir).
    IF RETURN-VALUE <> "OK" THEN RETURN "ERROR".
    strHomeDir = strHomeDir + "{&Slash}{&SubDir}".

    /* удостовериться, что директория $FRG-ACC/{&SubDir} создана */
    run bge/dir_cd.p (strHomeDir, "CA").
    IF RETURN-VALUE = "ERROR" THEN RETURN "ERROR".

    strOutFile = strHomeDir + "{&Slash}" + "{&OutFileName}" + p-file-name + ".".

    /* найти исходный файл */
    bolLKfile = (SEARCH (strOutFile + "xml") <> ?).
    /* найти файл блокировки */
    DO iRepeater = 1 TO 3 WHILE bolLKfile:
    bolLKfile = (SEARCH (strOutFile + "lk") <> ?).
    IF bolLKfile THEN READKEY PAUSE 1.
    END.
    /* читают/обновляют в БухПриложении - ЗАПИСЬ НЕВОЗМОЖНА */
    IF bolLKfile THEN RETURN "LOCKED".
    /* удалить старый файл */
    run bge/os_copy.p ("D", strOutFile + "xml", "", OUTPUT ErrorLevel).
    IF ErrorLevel > 0 THEN RETURN "ERROR".

    /*- в кодировке 1251 писать в файл $FRG-ACC/{&SubDir}/{&OutFileName}.xm1 -*/
    OUTPUT STREAM stmXMLOut TO VALUE(strOutFile + "xm1") CONVERT TARGET "1251".

    ASSIGN sLogFile = strHomeDir + "{&Slash}" + "Actions.log".
    run wp-XMLWriteLog in this-procedure ( input sLogFile, input 0, input "&Line" ).
    run wp-XMLWriteLog in this-procedure ( input sLogFile, input 1, input "XML - Вывод КОНТРАГЕНТОВ" ).

    run write-header in this-procedure.

    IF lookup( "list":U, p-mode ) = 0
    THEN DO:
        run init-temphost.
        if v-bge-xml-bgeclall = no
        and p-host-code <> 0
        then do:        /* экспортировать объекты только заданной фирмы */
            for each temp-obj
            where temp-obj.host-code = p-host-code
            :
                find first buf_clients
                     where buf_clients.obj-type = temp-obj.obj-type
                       and buf_clients.obj-code = temp-obj.obj-code
                no-error.
                if error-status :error
                then do:
                    run wp-xmlwritelog(slogfile, 1, "*** ERROR *** Не найден клиент " + temp-obj.obj-type + " " + string(temp-obj.obj-code) ).
                    undo, next.
                end.
                run write-client in this-procedure (
                      input buf_clients.obj-type
                    , input buf_clients.obj-code
                ).
            end.
        end.        /* v-bge-xml-bgeclall = no */
        else do:        /* экспортировать все объекты */
            for each temp-obj
            :
                find first buf_clients
                     where buf_clients.obj-type = temp-obj.obj-type
                       and buf_clients.obj-code = temp-obj.obj-code
                no-error.
                if error-status :error
                then do:
                    run wp-xmlwritelog(slogfile, 1, "*** ERROR *** Не найден клиент " + temp-obj.obj-type + " " + string(temp-obj.obj-code) ).
                    undo, next.
                end.
                run write-client in this-procedure (
                      input buf_clients.obj-type
                    , input buf_clients.obj-code
                ).
            end.
        end.        /* NOT ( v-bge-xml-bgeclall = no ) */
        for each buf_clients no-lock
           where buf_clients.obj-type <> {&shop}
             and buf_clients.obj-type <> {&stock}
        on error undo, return error
        :
            run write-client in this-procedure (
                  input buf_clients.obj-type
                , input buf_clients.obj-code
            ).
        end.
    END.
    ELSE DO:
        for each temp_bge-xml_clients
        on error undo, return error
        :
            run write-client in this-procedure (
                  input temp_bge-xml_clients.obj-type
                , input temp_bge-xml_clients.obj-code
            ).
        end.        /* for each temp_bge-xml_goods */
    END.

    run wp-XMLTagClose(1, "body").
    run wp-XMLTagClose(0, "IBS_Trade_House").

    output stream stmXMLOut close.

    /*- переименовать: .xm1 -> .xml -*/
    run bge/os_copy.p ("M", strOutFile + "xm1", strOutFile + "xml", OUTPUT ErrorLevel).
    IF ErrorLevel > 0 THEN RETURN "ERROR".
    /*- права "a+rw" на файл -*/
    IF OPSYS = "UNIX" THEN OS-COMMAND SILENT
    chmod 666 value (strOutFile + "xml") 2>/dev/null.

    return "OK".

end.

/*========================================================================*/
procedure write-client:
do
on error undo, return error
:
  define input parameter p-obj-type   as character        no-undo.
  define input parameter p-obj-code   as integer          no-undo.

define variable v-out-string    as character    no-undo.
define variable v-self-host     as logical      no-undo.

define buffer buf_clients       for ub.clients.
define buffer buf_person        for ub.person.
define buffer buf_firm          for ub.firm.
define buffer buf_sysconf       for ub.sysconf.
define buffer buf_fin-schet     for ub.fin-schet.
define buffer buf_fin-bank      for ub.fin-bank.
define buffer buf_place-io      for ub.place-io.
define buffer buf_point-io      for ub.point-io.

find first buf_clients no-lock
     where buf_clients.obj-type = p-obj-type
       and buf_clients.obj-code = p-obj-code
no-error .
if not available buf_clients
then do:
  return . /* --->>>--- */
end.
assign
    v-self-host = yes
.
if p-obj-type = {&cmp}
then do:
    find first buf_sysconf no-lock
         where buf_sysconf.host-code = p-obj-code
    no-error.
    if available buf_sysconf
    then do:
        assign
            v-self-host = yes
        .
    end.
end.
run wp-XMLTagOpen in this-procedure ( input 2, "{&OutFileName}","").
run wp-XMLTagPut in this-procedure ( input 3, input "referenceNo", input buf_clients.obj-type + string(buf_clients.obj-code), input 0 ).
run wp-XMLTagPut in this-procedure ( input 3, input "name"       , input buf_clients.obj-name                               , input 0 ).
run wp-XMLTagPut in this-procedure ( input 3, input "orgtype"    , input buf_clients.obj-type                               , input 0 ).
run wp-XMLTagPut in this-procedure ( input 3, input "selfHost"   , input string( v-self-host )                              , input 3 ).

if buf_clients.stts <> 0
then do:
    run wp-XMLTagPut in this-procedure ( input 3, input "status", input string(buf_clients.stts), input 0 ).
end.

run wp-XMLTagPut in this-procedure ( input 3, input "isBuyCons" , input string( buf_clients.buy-cons), 3).
run wp-XMLTagPut in this-procedure ( input 3, input "isBuyGoods", input string( buf_clients.buy-gds ), 3).
run wp-XMLTagPut in this-procedure ( input 3, input "isBuyServ" , input string( buf_clients.buy-serv), 3).
run wp-XMLTagPut in this-procedure ( input 3, input "isProd"    , input string( buf_clients.is-prod ), 3).
run wp-XMLTagPut in this-procedure ( input 3, input "isSupCons" , input string( buf_clients.sup-cons), 3).
run wp-XMLTagPut in this-procedure ( input 3, input "isSupGoods", input string( buf_clients.sup-gds ), 3).
run wp-XMLTagPut in this-procedure ( input 3, input "isSupServ" , input string( buf_clients.sup-serv), 3).

run wp-XMLTagPut in this-procedure ( input 3, input "comment", input buf_clients.PS, input 0 ).

if buf_clients.obj-type = {&cmp}
then do:
    find first buf_firm no-lock
         where buf_firm.firm-code = buf_clients.obj-code
    no-error.
    if available buf_firm
    then do:
        run wp-XMLTagPut(3, "ename", buf_firm.engl-name, 0).
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
        run wp-XMLTagPut in this-procedure ( input 3, input "regAddr" , input v-out-string          , input 0).
        run wp-XMLTagPut in this-procedure (
              input 3
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
        run wp-XMLTagPut in this-procedure (
              input 3
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
        run wp-XMLTagPut in this-procedure ( input 3, input "inn"  , input buf_firm.inn  , input 0 ).
        run wp-XMLTagPut in this-procedure ( input 3, input "kpp"           , input buf_firm.kpp        , input 0 ).
        run wp-XMLTagPut in this-procedure ( input 3, input "okonh", input buf_firm.okonh, input 0 ).
        run wp-XMLTagPut in this-procedure ( input 3, input "okpo" , input buf_firm.okpo , input 0 ).
        run wp-XMLTagPut in this-procedure ( input 3, input "director"      , input buf_firm.director   , input 0 ).
        run wp-XMLTagPut in this-procedure ( input 3, input "contactPsn"    , input buf_firm.contact-psn, input 0 ).
        run wp-XMLTagPut in this-procedure ( input 3, input "email"         , input buf_firm.e-mail     , input 0 ).
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
                    run wp-XMLTagOpen in this-procedure ( input 3, input "BankInfo", input "" ).
                    run wp-XMLTagPut in this-procedure ( input 4, input "hostFirmCode"  , input string( buf_fin-schet.host-code ) , input 0 ).
                    run wp-XMLTagPut in this-procedure ( input 4, input "accountNumber" , input string( buf_fin-schet.r-schet )   , input 0 ).
                    run wp-XMLTagPut in this-procedure ( input 4, input "bAccountNumber", input string( buf_fin-schet.c-schet )   , input 0 ).
                    run wp-XMLTagPut in this-procedure ( input 4, input "currCode"      , input string( buf_fin-schet.curr-code ) , input 0 ).
                    find first buf_fin-bank no-lock
                        where buf_fin-bank.host-code = p-host-code
                        and buf_fin-bank.code-bank = buf_fin-schet.code-bank
                    no-error.
                    if available buf_fin-bank
                    then do:
                        run wp-XMLTagPut in this-procedure ( input 4, input "bankCode"      , input string( buf_fin-schet.code-bank ) , input 0 ).
                        run wp-XMLTagPut in this-procedure ( input 4, input "bankName"      , input string( buf_fin-bank.bank-name )  , input 0 ).
                        run wp-XMLTagPut in this-procedure ( input 4, input "Address1"      , input string( entry(1, buf_fin-bank.addres, {&delim-par}))    , input 0 ).
                        run wp-XMLTagPut in this-procedure ( input 4, input "Address2"      , input string( buf_fin-bank.addres1 )    , input 0 ).
                    end.
                    run wp-XMLTagClose in this-procedure ( input 3, input "BankInfo" ).
                end.
            end.        /* for each buf_fin-schet */
        end.        /* for each buf_sysconf */

    end.
end.
if buf_clients.obj-type = {&prs}
then do:
    find first buf_person no-lock
         where buf_person.psn-code = buf_clients.obj-code
    no-error.
    if available buf_person
    then do:
        run wp-XMLTagPut in this-procedure ( input 3, input "inn", input buf_person.inn, input 0 ).
        run wp-XMLTagPut in this-procedure ( input 3, input "kpp"   , input buf_person.kpp      , input 0 ).
        run wp-XMLTagPut in this-procedure ( input 3, input "email" , input buf_person.e-mail   , input 0 ).
    end.
end.

        for each buf_place-io no-lock
           where buf_place-io.obj-type  = buf_clients.obj-type
             and buf_place-io.obj-code  = buf_clients.obj-code
        on error undo, return error
        :
          run wp-XMLTagOpen in this-procedure ( input 3, input "Place-io-Info", input "" ).
          run wp-XMLTagPut in this-procedure ( input 4, input "place-io-code"  , input string( buf_place-io.place-io-code ) , input 0 ).
          run wp-XMLTagPut in this-procedure ( input 4, input "place-io-name"  , input string( buf_place-io.place-io-name ) , input 0 ).
          run wp-XMLTagPut in this-procedure ( input 4, input "place-io-type"  , input string( buf_place-io.place-io-type ) , input 0 ).
          run wp-XMLTagPut in this-procedure ( input 4, input "PS"  , input string( buf_place-io.PS ) , input 0 ).
          run wp-XMLTagPut in this-procedure ( input 4, input "status_"  , input string( buf_place-io.status_ ) , input 0 ).
          run wp-XMLTagClose in this-procedure ( input 3, input "Place-io-Info" ).
        end.        /* for each buf_place-io */


        for each buf_point-io no-lock
           where buf_point-io.cli-type  = buf_clients.obj-type
             and buf_point-io.cli-code  = buf_clients.obj-code
        on error undo, return error
        :
          run wp-XMLTagOpen in this-procedure ( input 3, input "point-io-Info", input "" ).
          run wp-XMLTagPut in this-procedure ( input 4, input "point-code"  , input string( buf_point-io.point-code ) , input 0 ).
          run wp-XMLTagPut in this-procedure ( input 4, input "db-num"  , input string( buf_point-io.db-num ) , input 0 ).
          run wp-XMLTagPut in this-procedure ( input 4, input "point-name"  , input string( buf_point-io.point-name ) , input 0 ).
          run wp-XMLTagPut in this-procedure ( input 4, input "point-type"  , input string( buf_point-io.point-type ) , input 0 ).
          run wp-XMLTagPut in this-procedure ( input 4, input "PS"  , input string( buf_point-io.PS ) , input 0 ).
          run wp-XMLTagPut in this-procedure ( input 4, input "status_"  , input string( buf_point-io.status_ ) , input 0 ).
          run wp-XMLTagPut in this-procedure ( input 4, input "is-default"  , input string( buf_point-io.is-default ) , input 0 ).
          run wp-XMLTagPut in this-procedure ( input 4, input "address"  , input string( buf_point-io.address ) , input 0 ).
          run wp-XMLTagPut in this-procedure ( input 4, input "dist"  , input string( buf_point-io.dist ) , input 0 ).
          run wp-XMLTagClose in this-procedure ( input 3, input "point-io-Info" ).
        end.        /* for each buf_point-io */

run wp-XMLTagClose in this-procedure ( input 2, input "{&OutFileName}" ).

end.
end procedure.

/*========================================================================*/
procedure write-header:
do
on error undo, return error
:
put stream stmXMLOut unformatted
    "<?xml version='1.0' encoding='windows-1251'?>"
.
put stream stmXMLOut unformatted
    {&new-line} + '<IBS_Trade_House>'
.
run wp-XMLTagOpen in this-procedure  ( input 1, input "header"      , input "").
run wp-XMLTagOpen in this-procedure  ( input 2, input "delivery"    , input "").
run wp-XMLTagOpen in this-procedure  ( input 3, input "to"          , input "").
run wp-XMLTagClose in this-procedure ( input 3, input "to" ).
run wp-XMLTagOpen in this-procedure  ( input 3, input "from"        , input "").
run wp-XMLTagClose in this-procedure ( input 3, input "from" ).
run wp-XMLTagClose in this-procedure ( input 2, input "delivery" ).
run wp-XMLTagOpen in this-procedure  ( input 2, input "manifest"    , input "").
run wp-XMLTagOpen in this-procedure  ( input 3, input "document"    , input "").
run wp-XMLTagPut in this-procedure   ( input 4, input "name"        , input "{&OutFileName}", input 0).
run wp-XMLTagPut in this-procedure   ( input 4, input "description" , input ""              , input 0).
run wp-XMLTagClose in this-procedure ( input 3, input "document" ).
run wp-XMLTagClose in this-procedure ( input 2, input "manifest" ).
run wp-XMLTagClose in this-procedure ( input 1, input "header" ).
run wp-XMLTagOpen in this-procedure  ( input 1, input "body"        , input "").
end.
end procedure.