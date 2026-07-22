block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: bge-stk.p $
$Archive: bge/bge-stk.p $

Экспорт во Внешнюю Бухгалтерию товарных остатков

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:
    p-host-code     - код фирмы (если не по расписанию)
    p-date-from     - начало периода экспорта
    p-date-to       - конец  периода экспорта
    p-export-supp   - разбить остатки по поставщикам
    p-shedule       - выгрузка по расписанию
    p-db-num        - БД выгрузки (если по расписанию)
    p-obj-list      - список объектов (если по расписанию)
    hedt            - handle поля лога     (editor)
    hcnt            - handle поля счетчика (fill-in)
*/

define input parameter parparentproc    as handle           no-undo.
define input parameter p-host-code      as integer      no-undo.
define input parameter p-date-from      as date         no-undo.
define input parameter p-date-to        as date         no-undo.
define input parameter p-export-supp    as logical      no-undo.
define input parameter p-shedule        as logical      no-undo.
define input parameter p-db-num         as integer      no-undo.
define input parameter p-obj-list       as character    no-undo.
define input parameter hedt             as handle       no-undo.
define input parameter hcnt           as handle  no-undo.

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: bge-stk.p $":U .
def var vss-archive     as character no-undo init "$Archive: bge/bge-stk.p $":U .
def var vss-description as character no-undo init "Экспорт во Внешнюю Бухгалтерию товарных остатков".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/temphost.i }
{ bge/bge-xml.i  }
{ cmp/library.i  }
{ gbl/getcntxt.i def }

&if OPSYS = "UNIX" &then
&SCOP Slash /
&else
&SCOP Slash ~\
&endif

&SCOP SubDir exp-acc
&SCOP OutFileName stk

define variable sHomeDir            as character            no-undo.
define variable sOutFile            as character            no-undo. /* имя файла вывода */
define variable sLogFile            as character            no-undo. /* имя LOG-файла */
define variable bLocked             as logical    init no   no-undo. /* флаг блокировки */
define variable iRep                as integer    init 0    no-undo. /* счетчик для цикла */
define variable ErrorLevel          as integer              no-undo. /* номер ошибки */
define variable v-oper-num          as integer              no-undo. /* номер операции*/
define variable dTemp               as date                 no-undo. /* дата для суммирования продаж товара */

define variable v-fact-order-from   like ub.stk-tot.fact-order no-undo.
define variable v-fact-order-to     like ub.stk-tot.fact-order no-undo.
define variable v-docs-exists       as logical              no-undo.
define variable v-yesno             as logical              no-undo.
define variable v-obj-counter       as integer              no-undo.
define variable v-archive-ok        as logical              no-undo.
define variable v-comment           as character            no-undo.

do
on error undo, return error
:
/* Права на экспорт документов*/
if p-shedule = no
then do:
    { gbl/getcntxt.i get }
    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_documents_export':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    yes
    v-yesno
    }
    if not v-yesno then return error.
end.

run bge/bge-ini.p ("bge", OUTPUT sHomeDir).
IF RETURN-VALUE <> "OK" THEN RETURN "ERROR".
sHomeDir = sHomeDir + "{&Slash}{&SubDir}".

/* удостовериться, что директория $FRG-ACC/{&SubDir} создана */
run bge/dir_cd.p (sHomeDir, "CA").
IF RETURN-VALUE = "ERROR" THEN RETURN "ERROR".

sOutFile = sHomeDir + "{&Slash}{&OutFileName}.".

/* найти исходный файл */
bLocked = (SEARCH (sOutFile + "xml") <> ?).
/* найти файл блокировки */
DO iRep = 1 TO 3 WHILE bLocked:
   bLocked = (SEARCH (sOutFile + "lk") <> ?).
   IF bLocked THEN READKEY PAUSE 1.
END.
/* читают/обновляют в БухПриложении - ЗАПИСЬ НЕВОЗМОЖНА */
IF bLocked THEN RETURN "LOCKED".
/* удалить старый файл */
run bge/os_copy.p ("D", sOutFile + "xml", "", OUTPUT ErrorLevel).
IF ErrorLevel > 0 THEN RETURN "ERROR".

ASSIGN sLogFile = sHomeDir + "{&Slash}" + "Actions.log".

/*Шапка XML*/
OUTPUT STREAM stmXMLOut TO VALUE(sOutFile + "xm1") CONVERT TARGET "1251" APPEND.
RUN wp-XMLWriteLog(sLogFile, 0, "&DLine").
RUN wp-XMLWriteLog(sLogFile, 1, "XML - Вывод ОСТАТКОВ и ОБОРОТОВ").
RUN XMLWriteHeaderCat.
OUTPUT STREAM stmXMLOut CLOSE.

/* Экспорт из архивов */
if p-shedule = no
then do:
    run init-temphost.
    for each temp-obj
    :
        if temp-obj.host-code <> p-host-code
        then do:
            delete temp-obj.
        end.
    end.
end.        /* if p-shedule = no */
else do:
    do v-obj-counter = 1 to num-entries ( p-obj-list ) / 2
    :
        create temp-obj.
        assign
            temp-obj.obj-type = entry( v-obj-counter * 2 - 1, p-obj-list )
            temp-obj.obj-code = integer( entry( v-obj-counter * 2, p-obj-list ) )
        .
    end.        /* do v-obj-counter = 1 to num-entries ( p-obj-list ) / 2 */
end.        /* NOT ( if p-shedule = no ) */
object-of-firm:
for each temp-obj
on error undo, return error substitute( "Ошибка выгрузки остатков по объекту &1 &2", temp-obj.obj-type, temp-obj.obj-code )
:

    run wp-XMLWriteEDT( hEDT, 1, string(temp-obj.obj-type) + " " + string(temp-obj.obj-code) ).
/*---S-------- Расчет архивов на объекте ------------------*/
    run wp-XMLWriteEDT( hEDT, 4,  "Расчет архивов").
    process events.
    if parparentproc = ?
    then do:
        run bge/bge-ahzs.p (
              input temp-obj.obj-type
            , input temp-obj.obj-code
            , input yes
            , input no
            , input no
            , input p-date-from
            , input p-date-to
            , output v-archive-ok
            , output v-comment
        ) no-error.
    end.
    else do:
        run bge/bge-ahz.p (
              input parparentproc
            , input temp-obj.obj-type
            , input temp-obj.obj-code
            , input yes
            , input no
            , input no
            , input p-date-from
            , input p-date-to
            , output v-archive-ok
            , output v-comment
        ) no-error.
    end.
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка проверки архивов на объекте."
        skip "Тип объекта:" temp-obj.obj-type
        skip "Код объекта:" temp-obj.obj-code
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-archive-ok = no
    then do:
        run wp-XMLWriteLog in this-procedure (
              input sLogFile
            , input 1
            , input substitute( "*** Остатки по объекту &1 &2 в интервале дат &3 - &4 не будут выгружены. Архивы по объекту в заданном интервале дат не целостные. &5."
                                    , temp-obj.obj-type
                                    , temp-obj.obj-code
                                    , p-date-from
                                    , p-date-to
                                    , v-comment       )
        ).
        undo object-of-firm, next object-of-firm.
    end.
    process events.
/*---E-------- Расчет архивов на объекте ------------------*/
/*---S----- Границы fact-order для дат dFrom - dTo --------*/
    run rep/get-fo.p (
                    input  temp-obj.obj-type
                  , input  temp-obj.obj-code
                  , input  p-date-from
                  , input  p-date-to
                  , output v-fact-order-from
                  , output v-fact-order-to
                  , output v-docs-exists
                 ).
    if v-docs-exists = no
    then do:
        run wp-XMLWriteEDT( hEDT, 4, "В заданном диапазоне дат нет закрытых документов").
        undo object-of-firm, next object-of-firm.
    end.

    run wp-XMLShowCNT(hCNT).
/*                                                            message*/
/*                                                            string(v-fact-order-from) + " - " + string(v-fact-order-to)*/
/*                                                            view-as alert-box.*/
/*---E----- Границы fact-order для дат dFrom - dTo --------*/
    if p-export-supp = no
    then do:
        run bge/stk-oper.p (
                        input temp-obj.obj-type
                        , input temp-obj.obj-code
                        , input p-date-from
                        , input p-date-to
                        , input v-fact-order-from
                        , input v-fact-order-to
                        , input sOutFile
                        , input sLogFile
                        , input hEDT
                        , input hCNT
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip "Ошибка при выгрузке товарных остатков."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            run wp-XMLWriteEDT( hEDT, 1, string(return-value)).
        end.
    end.        /* if p-export-supp = no */
    else do:
        run wp-XMLWriteEDT( hEDT, 4,  "Расчет архивов по поставщикам.").
        process events.
        if parparentproc = ?
        then do:
            run bge/bge-ahzs.p (
                  input temp-obj.obj-type
                , input temp-obj.obj-code
                , input no
                , input yes
                , input no
                , input p-date-from
                , input p-date-to
                , output v-archive-ok
                , output v-comment
            ) no-error.
        end.
        else do:
            run bge/bge-ahz.p (
                  input parparentproc
                , input temp-obj.obj-type
                , input temp-obj.obj-code
                , input no
                , input yes
                , input no
                , input p-date-from
                , input p-date-to
                , output v-archive-ok
                , output v-comment
            ) no-error.
        end.
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка проверки архивов по поставщикам на объекте."
            skip "Тип объекта:" temp-obj.obj-type
            skip "Код объекта:" temp-obj.obj-code
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
        run bge/stk-opsp.p (
                          input temp-obj.obj-type
                        , input temp-obj.obj-code
                        , input p-date-from
                        , input p-date-to
                        , input v-fact-order-from
                        , input v-fact-order-to
                        , input sOutFile
                        , input sLogFile
                        , input hEDT
                        , input hCNT
        ) no-error.
        if error-status :error
        then do:
            message
                "Ошибка при выгрузке остатков по поставщикам."
            view-as alert-box.
            run wp-XMLWriteEDT( hEDT, 1, string(return-value)).
        end.
    end.        /* if p-export-supp <> no */
    run wp-XMLHideCNT(hCNT).
end.

/* Закрыть тэги шапки*/
OUTPUT STREAM stmXMLOut TO VALUE(sOutFile + "xm1") CONVERT TARGET "1251" APPEND.
RUN wp-XMLTagClose(1, "body").
RUN wp-XMLTagClose(0, "IBS_Trade_House").
OUTPUT STREAM stmXMLOut CLOSE.
/*- переименовать: .xm1 -> .xml -*/
run bge/os_copy.p ("M", sOutFile + "xm1", sOutFile + "xml", OUTPUT ErrorLevel).
IF ErrorLevel > 0 THEN RETURN "ERROR".
/*- права "a+rw" на файл -*/
IF OPSYS = "UNIX" THEN OS-COMMAND SILENT
 chmod 666 value (sOutFile + "xml") 2>/dev/null.
RETURN.

end.

/*========================================================================*/
PROCEDURE XMLWriteHeaderCat:
do
on error undo, return error
:
PUT STREAM stmXMLOut UNFORMATTED "<?xml version='1.0' encoding='windows-1251'?>".
/*PUT STREAM stmXMLOut UNFORMATTED {&new-line} + "<?xml-stylesheet type='text/xsl' href='{&OutFileName}.xsl'?>".*/
PUT STREAM stmXMLOut UNFORMATTED {&new-line} +
                  '<IBS_Trade_House>'.
RUN wp-XMLTagOpen(1, "header","").
RUN wp-XMLTagOpen(2, "delivery","").
/*RUN wp-XMLTagOpen(3, "message","").*/
/*RUN wp-XMLTagPut(4, "messageID","", 0).*/
/*RUN wp-XMLTagPut(4, "sent","", 0).*/
/*RUN wp-XMLTagClose(3, "message").*/
RUN wp-XMLTagOpen(3, "to","").
RUN wp-XMLTagClose(3, "to").
RUN wp-XMLTagOpen(3, "from","").
RUN wp-XMLTagClose(3, "from").
RUN wp-XMLTagClose(2, "delivery").
RUN wp-XMLTagOpen(2, "manifest","").
RUN wp-XMLTagOpen(3, "document","").
RUN wp-XMLTagPut(4, "name","{&OutFileName}", 0).
RUN wp-XMLTagPut(4, "description","", 0).
RUN wp-XMLTagClose(3, "document").
RUN wp-XMLTagClose(2, "manifest").
RUN wp-XMLTagClose(1, "header").
RUN wp-XMLTagOpen(1, "body","").

end.
END PROCEDURE.