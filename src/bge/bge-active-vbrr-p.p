block-level on error undo, throw.
/*
$Revision: da70ce2a1328, 1072, rls $
$Author: SMMolotkov $
$Date: Fri Oct 06 18:35:13 2017 +0300 $
$Workfile: bge-active-vbrr-p.p $
$Archive: bge/bge-active-vbrr-p.p $

Процедура ручного запуска выгрузки информации по пополнениям и активации для с верки с ВБРР

Автор: Шаланин Сергей
Дата создания: 22/04/2016
Author: Shalanin Sergey
Creation date: 22/04/2016

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

    { gbl/getcntxt.i def }
    { gbl/getcntxt.i get }
    assign
        p-curr-host-code  = v-cntxt-host-code-obj
        p-curr-obj-type = v-cntxt-obj-type
        p-curr-obj-code = v-cntxt-obj-code
    .

run bge/bge-active-vbrr.w ( parparentproc
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