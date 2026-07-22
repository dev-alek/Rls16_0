/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Таблица для процедуры дробления партий

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-parts-qnty no-undo
  field qnty      like ub.parts.qnty
  field fact-qnty like ub.parts.fact-qnty
  field cli-qnty  like ub.parts.cli-qnty
  field pl-code   like ub.parts.pl-code
  field parts-part-code like ub.parts.part-code
  field parts-recid as recid
.
/* $Workfile$ */