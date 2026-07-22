block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-wthdoc.p $
$Archive: rep/r-wthdoc.p $

Печать документа движения материальных ценностей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/09/05
Author: Bakhtadze Natalya
Creation date: 09/09/05

Author:  Булгаков А.Н.
Created: 30/07/2001.

*/

/* ***************************  Definitions  ************************** */

define input parameter parparentproc as widget-handle no-undo .

/* VSS Variables Definitions */
DEF VAR vss-revision    AS CHAR NO-UNDO INIT "$Revision: aea5316774be, 0, rls $":U.
DEF VAR vss-author      AS CHAR NO-UNDO INIT "$Author: expertek $":U.
DEF VAR vss-date        AS CHAR NO-UNDO INIT "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
DEF VAR vss-workfile    AS CHAR NO-UNDO INIT "$Workfile: r-wthdoc.p $":U.
DEF VAR vss-archive     AS CHAR NO-UNDO INIT "$Archive: rep/r-wthdoc.p $":U.
DEF VAR vss-description AS CHAR NO-UNDO INIT "печать документа движения материальных ценностей":U.

/* Shared Variables & Preprocessors Definitions */
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

/* Buffers Definitions */
DEF SHARED BUFFER w-doc   FOR ub.wth-doc.
DEF        BUFFER buf-cli FOR ub.clients.

/* ***************************  Main Block  *************************** */
Main-Block:
DO ON ERROR   UNDO Main-Block, LEAVE Main-Block
   ON END-KEY UNDO Main-Block, LEAVE Main-Block
   ON STOP    UNDO Main-Block, LEAVE Main-Block :
  IF NOT AVAIL w-doc THEN DO:
    MESSAGE "Документ перемещения МЦ не найден!" VIEW-AS ALERT-BOX ERROR.
    UNDO Main-Block, LEAVE Main-Block.
  END.

  CASE w-doc.doc-type :
    WHEN {&income}    OR
    WHEN {&expense}   OR
    WHEN {&write-off} THEN DO: run rep/r-w-doc.p ( input parparentproc, INPUT RECID( w-doc ) ). END.
    WHEN {&inventory} THEN DO: run rep/r-w-inv.p ( input parparentproc, INPUT RECID( w-doc ) ). END.
    OTHERWISE              DO:
      MESSAGE "Неизвестный тип документа: ~"" + w-doc.doc-type + "~"!" VIEW-AS ALERT-BOX ERROR.
      UNDO Main-Block, LEAVE Main-Block.
    END.
  END CASE.
END.