block-level on error undo, throw.
/*

$Revision: 278fa297b56f, 1047, rls $
$Author: SMMolotkov $
$Date: Fri Oct 06 18:31:46 2017 +0300 $
$Workfile: p-exp-ATD.p $
$Archive: bge/p-exp-ATD.p $

Выгрузка СТ в SAP (Сургутнефтегаз)

Автор: Шаланин Сергей
Дата создания: 11/08/2016
Author: Shalanin Sergey
Creation date: 11/08/2016

*/

/* ***************************  Definitions  ************************** */
define input parameter parParentProc as widget-handle no-undo.

define variable vss-revision    as character no-undo init "$ $":U.
define variable vss-author      as character no-undo init "$ $":U.
define variable vss-date        as character no-undo init "$ $":U.
define variable vss-workfile    as character no-undo init "$ $":U.
define variable vss-archive     as character no-undo init "$ $":U.
define variable vss-description as character no-undo init "".

/* ****************************  Includes  **************************** */
{cmp/vssrevis.i}
{cmp/str-glbl.i}

/* ***************************  Main Block  *************************** */


DEFINE VARIABLE p-curr-host-code like ub.sysconf.host-code NO-UNDO.
DEFINE VARIABLE p-curr-obj-type  like ub.clients.obj-type NO-UNDO.
DEFINE VARIABLE p-curr-obj-code  like ub.clients.obj-code NO-UNDO.
DEFINE VARIABLE p-mode           AS CHARACTER NO-UNDO.
DEFINE VARIABLE p-db-num-char    AS CHARACTER NO-UNDO.
DEFINE VARIABLE p-task-type      AS CHARACTER NO-UNDO.
DEFINE VARIABLE p-task-num       AS INTEGER NO-UNDO.
DEFINE VARIABLE p-action         AS CHARACTER NO-UNDO.
DEFINE VARIABLE p-cancel         AS LOGICAL NO-UNDO.
DEFINE VARIABLE p-params         AS CHARACTER NO-UNDO.


run bge/e-exp-ATD.w( parparentproc
              , p-curr-host-code
              , p-curr-obj-type
              , p-curr-obj-code
              , 'run'
              , p-db-num-char
              , p-task-type
              , p-task-num 
              , p-action
              , OUTPUT p-cancel
              , OUTPUT p-params ) .