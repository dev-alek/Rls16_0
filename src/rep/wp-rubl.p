block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wp-rubl.p $
$Archive: rep/wp-rubl.p $

Сумма с разбивкой на   р у б л и   и   к о п е й к и

Автор: Булгаков Андрей Николаевич
Дата создания: 09/13/05
Author: Andrew Bulgakoff
Creation date: 09/13/05

*/

DEFINE  INPUT PARAMETER p-InSum  AS DECIMAL   NO-UNDO.
DEFINE OUTPUT PARAMETER p-OutSum AS CHARACTER NO-UNDO.

&SCOP f-l Roubles,Copecks

DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INITIAL "$Revision: aea5316774be, 0, rls $":U.
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INITIAL "$Author: expertek $":U.
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INITIAL "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INITIAL "$Workfile: wp-rubl.p $":U.
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INITIAL "$Archive: rep/wp-rubl.p $":U.
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INITIAL "Сумма с разбивкой на  р у б л и  и  к о п е й к и":U.

{ cmp/vssrevis.i        }
{ gbl/std-func.i {&f-l} }

DEFINE VARIABLE Word AS CHARACTER NO-UNDO.

ASSIGN Word     = STRING( ABS( p-InSum ), "999999999999999999999999999999.99":U ).
ASSIGN p-OutSum = ( IF p-InSum < 0 THEN "- " ELSE "":U ) + STRING( TRUNCATE( p-InSum, 0 ) ) + " ":U +
                  Roubles( p-InSum ) + " ":U + SUBSTRING( Word, LENGTH( Word ) - 1 ) + " ":U + Copecks( p-InSum ).