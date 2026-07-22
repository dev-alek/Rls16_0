/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица для бар-кодов

Автор: Чернова Светлана Александровна
Дата создания: 12/22/06
Author: Svetlana Chernova
Creation date: 12/22/06

create: Суслов Алексей Юрьевич

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table tt-bar-code-ne no-undo
field nm            as integer      /* 0 - есть только в документе, -1 - есть только в заводимой информации, >0 - есть везде выводим выбирая нужный порядок,                                          */
field mark          as character    /* d - есть только в документе, f - есть только в заводимой информации,  "" - если количества равны "<>" - если не равны, ? - бар-код партии или складского места */
field b-c           as integer
field scn-qnty-doc  as decimal
field scn-qnty-file as decimal
field mem-qnty      as decimal
field bef-qnty      as decimal
field artic         like ub.goods.artic
field prod-type     like ub.goods.prod-type
field prod-code     like ub.goods.prod-code
field gds-name      like ub.goods.gds-name
field node-name     like ub.gds-prt.node-name
field part-code     like ub.bar-code.part-code
field in-code       like ub.bar-code.in-code
index pi is primary nm
index b-c is unique b-c.

/* $Workfile$ e n d */