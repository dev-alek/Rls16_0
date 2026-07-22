block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cat-grp.p $
$Archive: bge/cat-grp.p $

Экспорт структуры групп товаров

Автор: Хныкин Павел Андреевич
Дата создания: 04/05/06
Author: Pavel Khnykin
Creation date: 04/05/06

Input:

Output:

*/
define input parameter iRecAmount   as integer      no-undo.
define input parameter sRecCodeList as char         no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cat-grp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/cat-grp.p $":U .
define variable vss-description as character no-undo init "Экспорт структуры групп товаров".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ bge/bge-xml.i  }

&SCOP SubDir dict
&SCOP OutFileName group

&if OPSYS = "UNIX" &then
&SCOP Slash /
&else
&SCOP Slash ~\
&endif

DEF VAR strPutOut       AS CHAR FORMAT "X(255)" NO-UNDO.
DEF VAR strHomeDir      AS CHAR                 NO-UNDO.
DEF VAR strOutFile      AS CHAR                 NO-UNDO.
DEF VAR sLogFile        AS CHAR                 NO-UNDO.

DEF VAR iRepeater       AS INT      INIT 0      NO-UNDO. /* счетчик для цикла */
DEF VAR bLocked         AS LOGICAL  INIT NO     NO-UNDO. /* флаг блокировки */

DEF VAR ErrorLevel      AS INT                  NO-UNDO. /* ошибка - номер */
DEF VAR sObjType        AS CHAR                 NO-UNDO.
DEF VAR iObjCode        AS INT                  NO-UNDO.

define buffer buf_gds-grp for ub.gds-grp.

IF iRecAmount = ? OR sRecCodeList = ?
                  OR (iRecAmount <> 0 AND NUM-ENTRIES(sRecCodeList) = 0) THEN RETURN "ERROR".

run bge/bge-ini.p ("bge", OUTPUT strHomeDir).
IF RETURN-VALUE <> "OK" THEN RETURN "ERROR".
strHomeDir = strHomeDir + "{&Slash}{&SubDir}".

/* удостовериться, что директория $FRG-ACC/{&SubDir} создана */
run bge/dir_cd.p (strHomeDir, "CA").
IF RETURN-VALUE = "ERROR" THEN RETURN "ERROR".

strOutFile = strHomeDir + "{&Slash}{&OutFileName}.".

/* найти исходный файл */
bLocked = (SEARCH (strOutFile + "xml") <> ?).
/* найти файл блокировки */
DO iRepeater = 1 TO 3 WHILE bLocked:
   bLocked = (SEARCH (strOutFile + "lk") <> ?).
   IF bLocked THEN READKEY PAUSE 1.
END.
/* читают/обновляют в БухПриложении - ЗАПИСЬ НЕВОЗМОЖНА */
IF bLocked THEN RETURN "LOCKED".
/* удалить старый файл */
run bge/os_copy.p ("D", strOutFile + "xml", "", OUTPUT ErrorLevel).
IF ErrorLevel > 0 THEN RETURN "ERROR".

/*- в кодировке 1251 писать в файл $FRG-ACC/{&SubDir}/{&OutFileName}.xm1 -*/
OUTPUT STREAM stmXMLOut TO VALUE(strOutFile + "xm1") CONVERT TARGET "1251".

ASSIGN sLogFile = strHomeDir + "{&Slash}" + "Actions.log".

RUN wp-XMLWriteLog(sLogFile, 0, "&Line").
RUN wp-XMLWriteLog(sLogFile, 1, "XML - Вывод ГРУПП ТОВАРОВ").

RUN XMLWriteHeaderCat.

IF iRecAmount = 0 THEN
DO:
    FOR EACH buf_gds-grp NO-LOCK BY buf_gds-grp.node-code:
                RUN XMLWriteGroupsCat(RECID(buf_gds-grp), sLogFile).
    END.
END.
ELSE DO:
        DO iRepeater = 1 TO (NUM-ENTRIES(sRecCodeList) / 2):
          ASSIGN
            sObjType = ENTRY(iRepeater, sRecCodeList)
            iRepeater = iRepeater + 1
            iObjCode = INTEGER(ENTRY(iRepeater, sRecCodeList))
            iRepeater = iRepeater + 1
          .
          RUN XMLWriteGroupsCat(RECID(buf_gds-grp), sLogFile).
        END.
END.

RUN wp-XMLTagClose(1, "body").
RUN wp-XMLTagClose(0, "IBS_Trade_House").

OUTPUT STREAM stmXMLOut CLOSE.

/*- переименовать: .xm1 -> .xml -*/
run bge/os_copy.p ("M", strOutFile + "xm1", strOutFile + "xml", OUTPUT ErrorLevel).
IF ErrorLevel > 0 THEN RETURN "ERROR".
/*- права "a+rw" на файл -*/
IF OPSYS = "UNIX" THEN OS-COMMAND SILENT
 chmod 666 value (strOutFile + "xml") 2>/dev/null.

RETURN "OK".

/*========================================================================*/
PROCEDURE XMLWriteGroupsCat:
    DEF INPUT PARAM riGroupsRecID AS RECID NO-UNDO.
    DEF INPUT PARAM sLogFile     AS CHAR NO-UNDO.

DEF VAR sPut AS CHAR NO-UNDO.
DEF VAR iBarCode LIKE ub.bar-code.b-code NO-UNDO. /* бар-код товара */

DEF BUFFER bufGroups FOR ub.gds-grp.

FIND FIRST bufGroups NO-LOCK WHERE RECID(bufGroups) = riGroupsRecID.

RUN wp-XMLTagOpen(2, "{&OutFileName}","").
RUN wp-XMLTagPut(3, "referenceNo", STRING(bufGroups.node-code), 0).
RUN wp-XMLTagPut(3, "refToUpper", bufGroups.upper-code, 0).
RUN wp-XMLTagPut(3, "name", bufGroups.node-name, 0).
RUN wp-XMLTagClose(2, "{&OutFileName}").

END PROCEDURE.

/*========================================================================*/
PROCEDURE XMLWriteHeaderCat:

PUT STREAM stmXMLOut UNFORMATTED "<?xml version='1.0' encoding='windows-1251'?>".
/*PUT STREAM stmXMLOut UNFORMATTED {&new-line} + '<?xml-stylesheet type="text/xsl" href="{&OutFileName}.xsl"?>'.*/
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

END PROCEDURE.