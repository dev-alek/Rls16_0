/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с МХ по одному МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/13/06
Author: Bakhtadze Natalya
Creation date: 04/13/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table temp-pl-wth no-undo
  field w-p-code        like ub.wth-pobj.w-p-code
  field incass-bank-pl  like ub.wth-pobj.incass-bank-pl
  field incass-other-pl like ub.wth-pobj.incass-other-pl
  field incass-pl       like ub.wth-pobj.incass-pl
  field income-cassa-pl like ub.wth-pobj.income-cassa-pl
  field income-other-pl like ub.wth-pobj.income-other-pl
  field income-pl       like ub.wth-pobj.income-pl
  field incass-cassa-pl like ub.wth-pobj.incass-cassa-pl

  index xpk is primary unique w-p-code
.


/* $Workfile$ e n d */