block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: bge-kass.p $
$Archive: bge/bge-kass.p $

Экспорт во Внешнюю Бухгалтерию суммарного расхода по чекам

Автор: Хныкин Павел Андреевич
Дата создания: 09/09/05
Author: Pavel Khnykin
Creation date: 09/09/05

Input:

Output:

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter dFrom                as date             no-undo.
define input parameter dTo                  as date             no-undo.
define input parameter hEDT                 as handle           no-undo.
define input parameter hCNT                 as handle           no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bge-kass.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bge-kass.p $":U .
define variable vss-description as character no-undo init "Экспорт во Внешнюю Бухгалтерию суммарного расхода по чекам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/temphost.i }
{ bge/bge-xml.i  }
{ gbl/getcntxt.i def }

&if OPSYS = "UNIX" &then
&SCOP Slash /
&else
&SCOP Slash ~\
&endif

&SCOP SubDir exp-acc
&SCOP OutFileName kass

DEF VAR gen-mode   AS CHAR NO-UNDO.

DEF VAR sHomeDir   AS CHAR                 NO-UNDO.
DEF VAR sOutFile   AS CHAR                 NO-UNDO. /* имя файла вывода */
DEF VAR sLogFile   AS CHAR                 NO-UNDO. /* имя LOG-файла */
DEF VAR bLocked    AS LOGICAL  INIT NO     NO-UNDO. /* флаг блокировки */
DEF VAR iRep       AS INTEGER  INIT 0      NO-UNDO. /* счетчик для цикла */
DEF VAR ErrorLevel AS INTEGER              NO-UNDO. /* номер ошибки */
DEF VAR iOperNum   AS INTEGER              NO-UNDO. /* номер операции*/
DEF VAR dTemp      AS DATE                 NO-UNDO. /* дата для суммирования продаж товара */
define variable v-success    as logical      no-undo.

{ gbl/getcntxt.i get " " p-mainmenu-handle }
/* Права на экспорт документов*/
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
    v-success
    }
IF v-success = no THEN RETURN ERROR.

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
RUN wp-XMLWriteLog(sLogFile, 1, "XML - Вывод ДОКУМЕНТОВ").
RUN XMLWriteHeaderCat.
OUTPUT STREAM stmXMLOut CLOSE.

RUN init-temphost.

RUN wp-XMLShowCNT(hCNT).

FOR EACH temp-obj
   WHERE temp-obj.host-code = v-cntxt-host-code-obj
:
/* Экспорт с касс */
  IF temp-obj.obj-type = {&shop}
  THEN DO:
    RUN wp-XMLWriteEDT( hEDT, 10, "*** " + STRING(temp-obj.obj-type) + " " + STRING(temp-obj.obj-code) + " ***").
    PROCESS EVENTS.
    DO dTemp = dFrom TO dTo:
        run bge/doc-kass.p (INPUT temp-obj.obj-type,
                        INPUT temp-obj.obj-code,
                        INPUT dTemp,
                        INPUT sOutFile,
                        INPUT sLogFile,
                        INPUT hEDT,
                        INPUT hCNT).
    END.
  END.
END.

RUN wp-XMLHideCNT(hCNT).

/*MESSAGE "Здесь должны послать дальше" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.*/

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


/*========================================================================*/
PROCEDURE XMLWriteHeaderCat:

PUT STREAM stmXMLOut UNFORMATTED "<?xml version='1.0' encoding='windows-1251'?>".
/*PUT STREAM stmXMLOut UNFORMATTED {&new-line} + '<?xml-stylesheet type="text/xsl" href="{&OutFileName}.xsl"?>'.*/
PUT STREAM stmXMLOut UNFORMATTED {&new-line} +
                  '<IBS_Trade_House>'.
RUN wp-XMLTagOpen(1, "header","").
RUN wp-XMLTagOpen(2, "delivery","").
RUN wp-XMLTagOpen(3, "message","").
RUN wp-XMLTagPut(4, "messageID","", 0).
RUN wp-XMLTagPut(4, "sent","", 0).
RUN wp-XMLTagClose(3, "message").
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

END PROCEDURE.