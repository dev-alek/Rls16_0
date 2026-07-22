/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием в новостях ставок налогов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if not available tb-tax-rate then do:
  create tb-tax-rate.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-tax-rate TO wt-tax-rate case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-tax-rate TO tb-tax-rate.
  find buf_tax where buf_tax.tax-code = tb-tax-rate.tax-code no-lock no-error.

  define variable v-host-code as integer   no-undo .

  if available buf_tax
  and buf_tax.to-cashdesk = yes
  then do:
    for each buf_clients no-lock
      where buf_clients.obj-type = {&shop}
        and buf_clients.db-num = g#db-num
    on error undo, return error return-value
    :
      { gbl/hostcode.i
        buf_clients.obj-type
        buf_clients.obj-code
        v-host-code
      }
      run fill-cash-txr in p-imp-handle (
                                           input tb-tax-rate.tax-code
                                          ,input tb-tax-rate.rate-code
                                          ,input tb-tax-rate.status_
                                          ,input v-host-code
                                          ,input buf_clients.obj-type
                                          ,input buf_clients.obj-code
                                          ,input buf_tax.tax-type
                                          ,input ?
                                          ,input tb-tax-rate.rate-code
                                          ,input recid(tb-tax-rate)
                                          ).
    end.
  end.
end.

/* $Workfile$ e n d */