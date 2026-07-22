block-level on error undo, throw.
/*

$Revision: 794b9cc81728, 98, rls $
$Author: EShklyar $
$Date: Fri Nov 07 16:47:37 2014 +0300 $
$Workfile: exp-malina-man.p $
$Archive: bge/exp-malina-man.p $

Процедура ручного запуска выгрузки данных в Малину

Автор: Кривошеин Александр Николаевич
Дата создания: 02/09/14
Author: Krivoshein Alexander
Creation date: 02/09/14

*/

define input  parameter parparentproc as handle no-undo .

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

run bge/exp-malina.w ( parparentproc
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
