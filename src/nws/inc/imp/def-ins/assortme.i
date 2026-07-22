/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

АМ

Автор: Чернова Светлана Александровна
Дата создания: 03/20/07
Author: Svetlana Chernova
Creation date: 03/20/07

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_old_assortment-matrix for ub.assortment-matrix  .
/* $Workfile$ e n d */