/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием в новостях значений ставок налогов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if not available tb-tax-rate-value then do:
  create tb-tax-rate-value.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-tax-rate-value TO wt-tax-rate-value case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-tax-rate-value TO tb-tax-rate-value.

  find buf_tax where buf_tax.tax-code = tb-tax-rate-value.tax-code no-lock no-error.
  if available buf_tax and
     buf_tax.to-cashdesk = yes AND
     tb-tax-rate-value.fact-date <= today
    then do:
    run fill-cash-txr in p-imp-handle (
                                         input buf_tax.tax-code
                                        ,input tb-tax-rate-value.rate-code
                                        ,input ?
                                        ,input tb-tax-rate-value.host-code
                                        ,input tb-tax-rate-value.obj-type
                                        ,input tb-tax-rate-value.obj-code
                                        ,input buf_tax.tax-type
                                        ,input tb-tax-rate-value.rate-value
                                        ,input integer( tb-tax-rate-value.fact-date)
                                        ,input recid(tb-tax-rate-value)
                                        ).


  end.
end.
/* $Workfile$ e n d */