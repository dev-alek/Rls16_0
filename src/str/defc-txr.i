/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение временной таблицы по ставкам налогов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

чтобы можно было больше не обращаясь к базе выводить на любую кассу

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table cash-txr no-undo
  field tax-code    like ub.tax.tax-code
  field rate-code   like ub.tax-rate.rate-code
  field host-code   like ub.sysconf.host-code
  field obj-type    like ub.clients.obj-type
  field obj-code    like ub.clients.obj-code
  field tax-type    like ub.tax.tax-type
  field status_     like ub.tax-rate-value.status_
  field rate-value  as decimal
  field rc          as recid
  field crf         as integer
  /* для связи с таблицей cash-gds в случае индивидуальных налогов */
  field news-action as logical
  /* при разборке новостей если запись удаляется то ставится yes */
  index pi is unique primary tax-code host-code obj-type obj-code status_ rc
  index crf-i /* is unique */ crf host-code obj-type obj-code rc
.

/* todo bakhtadze ???? */
/* $Workfile$ e n d */