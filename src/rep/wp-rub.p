block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wp-rub.p $
$Archive: rep/wp-rub.p $

Сумма прописью в  р у б л я х

Автор: Булгаков Андрей Николаевич
Дата создания: 09/13/05
Author: Andrew Bulgakoff
Creation date: 09/13/05

*/

DEFINE  INPUT PARAMETER p-InSum  AS DECIMAL   NO-UNDO.
DEFINE OUTPUT PARAMETER p-OutSum AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER p-abbr   AS CHARACTER NO-UNDO.

&SCOP f-l Word-Sum,Total-Word,RedLine,Roubles,Copecks

DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INITIAL "$Revision: aea5316774be, 0, rls $":U.
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INITIAL "$Author: expertek $":U.
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INITIAL "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INITIAL "$Workfile: wp-rub.p $":U.
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INITIAL "$Archive: rep/wp-rub.p $":U.
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INITIAL "сумма прописью в  р у б л я х":U.

{ cmp/vssrevis.i        }
{ gbl/std-func.i {&f-l} }

ASSIGN p-OutSum = Total-Word( p-InSum, Roubles( p-InSum ), Copecks( p-InSum ) )
       p-abbr   = " {&abbr_rub}.".
