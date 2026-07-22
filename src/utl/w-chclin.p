block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: w-chclin.p $
$Archive: utl/w-chclin.p $

Изменить названия контрагентов в документах матценностей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

*/

DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INITIAL "$Revision: aea5316774be, 0, rls $":U.
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INITIAL "$Author: expertek $":U.
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INITIAL "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INITIAL "$Workfile: w-chclin.p $":U.
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INITIAL "$Archive: utl/w-chclin.p $":U.
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INITIAL "Изменить названия контрагентов в документах матценностей":U.

{ cmp/vssrevis.i }
{ gbl/waitfram.i }

DEFINE VARIABLE l_continue AS LOGICAL NO-UNDO.
DEFINE VARIABLE j_viewed   AS INTEGER NO-UNDO.
DEFINE VARIABLE j_changed  AS INTEGER NO-UNDO.

DEFINE BUFFER buf_w-doc FOR ub.wth-doc.

ON WRITE OF ub.wth-doc OVERRIDE DO: END.

ASSIGN l_continue = NO.

MESSAGE "Изменение названий контрагентов в документах матценностей." SKIP
        "Продолжить?"
VIEW-AS ALERT-BOX QUESTION BUTTONS OK-CANCEL UPDATE l_continue.
IF l_continue <> YES THEN DO: RETURN. END.

RUN WaitFram-Show IN THIS-PROCEDURE ( INPUT "Идет переименование контрагентов в документах. ЖДИТЕ...").
{&SetCursorWait}

Main-Loop:
FOR EACH buf_w-doc NO-LOCK :
  PROCESS EVENTS.

  ASSIGN j_viewed = j_viewed + 1.
  FIND ub.clients NO-LOCK WHERE
       ub.clients.obj-type = buf_w-doc.cli-type AND
       ub.clients.obj-code = buf_w-doc.cli-code NO-ERROR.
  IF NOT AVAILABLE ub.clients THEN DO: NEXT. END.

  IF buf_w-doc.cli-name <> ub.clients.obj-name THEN DO:
    DO TRANSACTION ON ERROR UNDO, NEXT Main-Loop :
      FIND ub.wth-doc EXCLUSIVE-LOCK WHERE RECID( ub.wth-doc ) = RECID( buf_w-doc ).
      ASSIGN ub.wth-doc.cli-name = ub.clients.obj-name.
      ASSIGN j_changed = j_changed + 1.
    END. /* TRANSACTION */
  END. /* cli-name */
END. /* FOR EACH buf_w-doc */

{&SetCursorNo}
RUN WaitFram-Hide IN THIS-PROCEDURE.

MESSAGE "Обработано документов:" j_viewed  SKIP
        "Исправлено документов:" j_changed SKIP
VIEW-AS ALERT-BOX INFORMATION.
