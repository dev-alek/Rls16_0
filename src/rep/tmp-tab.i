/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная табличка. Используется в r-outret.p, outp-tbl.p, r-schet1.p

Автор: Хныкин Павел Андреевич
Дата создания: 12/09/05
Author: Pavel Khnykin
Creation date: 12/09/05

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE temp-table temp-nalog no-undo
  field   slt-prc          as  decimal
  field   vat-prc          as  decimal
  field   slt-sum          as  decimal
  field   vat-sum          as  decimal
  field   from-sum         as  decimal
  INDEX pi  IS PRIMARY   vat-prc slt-prc
.
/* $Workfile$   E n d */