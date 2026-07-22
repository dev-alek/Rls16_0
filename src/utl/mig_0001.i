/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

инклюд для mig_*.p модификации УБД в ГБД

Автор: Чернова Светлана Александровна
Дата создания: 12/08/08
Author: Svetlana Chernova
Creation date: 12/08/08

*/

define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character no-undo .
define input parameter p-db-num         as integer   no-undo .
define input parameter p-cli-code       as integer   no-undo .
define input parameter log-file-name   as character  no-undo .


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ cmp/library.i  }

/* $Workfile$ e n d */