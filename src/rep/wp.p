block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wp.p $
$Archive: rep/wp.p $

Сумма прописью в базовой валюте

Автор: Булгаков Андрей Николаевич
Дата создания: 09/13/05
Author: Andrew Bulgakoff
Creation date: 09/13/05

*/

DEFINE  INPUT PARAMETER p-parent-proc AS WIDGET-HANDLE NO-UNDO.
DEFINE  INPUT PARAMETER p-InSum       AS DECIMAL       NO-UNDO.
DEFINE OUTPUT PARAMETER p-OutSum      AS CHARACTER     NO-UNDO.
DEFINE OUTPUT PARAMETER p-abbr        AS CHARACTER     NO-UNDO.

&SCOP f-l Word-Sum,Total-Word,RedLine

DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INITIAL "$Revision: aea5316774be, 0, rls $":U.
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INITIAL "$Author: expertek $":U.
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INITIAL "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INITIAL "$Workfile: wp.p $":U.
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INITIAL "$Archive: rep/wp.p $":U.
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INITIAL "сумма прописью в базовой валюте":U.

{ cmp/vssrevis.i        }
{ gbl/std-func.i {&f-l} }
{ cmp/library.i         }
{ gbl/getcntxt.i   def  }

DEFINE VARIABLE parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE p-part        AS CHARACTER     NO-UNDO.

DEFINE BUFFER bf_sysconf  FOR ub.sysconf.
DEFINE BUFFER bf_currency FOR ub.currency.

DO ON ERROR UNDO, RETURN ERROR :
  ASSIGN parparentproc = p-parent-proc.
  { gbl/getcntxt.i get }

  FIND FIRST bf_sysconf  NO-LOCK WHERE bf_sysconf.host-code  = v-cntxt-host-code-obj.
  FIND FIRST bf_currency NO-LOCK WHERE bf_currency.curr-code = bf_sysconf.base-code.
  ASSIGN p-abbr = bf_currency.curr-abbr
         p-part = bf_currency.part-abbr.

  ASSIGN p-OutSum = Total-Word( p-InSum, p-abbr, p-part ).
END.
