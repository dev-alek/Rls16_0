/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определения для стандартной формы отчетов

Автор: Чернова Светлана Александровна
Дата создания: 28/09/2001
Author: Svetlana Chernova
Creation date: 28/09/2001

можно переопределить имена временных таблиц списков с помощью использования &glob определений
например

&glob  g#cli_name tabl1
&glob  gds-list_name tabl2
&glob  g#grp_name tabl3
&glob  g#customer_name tabl4

ЕСЛИ ВСАТВЛЯТЬ В ФАЙЛЫ CMP ТО ВТОРОЙ ПАРАМЕТР ВЫЗОВА ДОЛЖЕН = cmp!!!!!!!!!!!!

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define {1} shared variable gdsgrp_recids      as character no-undo.
define {1} shared variable fin-schet-recid    as character no-undo.
define {1} shared variable v-d-report-handle  as handle    no-undo .

&if defined(g#customer_name) &then
define {1} shared temp-table {&g#customer_name} no-undo
&else
define {1} shared temp-table g#customer no-undo
&endif
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.

&if defined(g#cli_name) &then
define {1} shared temp-table {&g#cli_name} no-undo
&else
define {1} shared temp-table g#cli no-undo
&endif
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.

&if defined(tmp#grp_name) &then
define {1} shared temp-table {&tmp#grp_name} no-undo
&else
define {1} shared temp-table tmp#grp no-undo
&endif
    field node-code like ub.gds-grp.node-code
    field grp-name like ub.gds-grp.node-name
    field lvl-num  like ub.gds-grp.lvl-num
    field is-term  like ub.gds-grp.is-term
    index pi is unique primary grp-name node-code
    index i-node-code    node-code
    index level-num   lvl-num  grp-name
    index is-term is-term  grp-name
    .

&if defined(gds-list_name) &then
{ cmp/gds-list.i {&gds-list_name} def "{1} shared" }
&else
{ cmp/gds-list.i gds-list def "{1} shared" }
&endif

{ cmp/obj-list.i {1}}

/* Для начальных значений списка объектов */
define {1} shared temp-table X-init_obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary obj-type obj-code.


define variable p1 like ub.gds-obj.prod-type no-undo.
define variable p2 like ub.gds-obj.prod-code no-undo.
define variable p3 like ub.gds-obj.artic     no-undo.
&if "{1}" = "" &then
{ cmp/r-page0.i  " "  "{2} " }
&else
{ cmp/r-page0.i  "{1}"  "{2} " }
&endif
{ cmp/library.i }
&if "{2}" <> "cmp" &then
define variable var-report-r-b as character no-undo .
{ gbl/curr-r-b.i var-report-r-b }
&endif
/* $Workfile$ e n d */