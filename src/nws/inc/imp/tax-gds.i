/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием в новостях налогов на товар

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if not available tb-tax-rate-gds then do:
  create tb-tax-rate-gds.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-tax-rate-gds TO wt-tax-rate-gds case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-tax-rate-gds TO tb-tax-rate-gds.
  if num-entries(tb-tax-rate-gds.corr-user-name, {&delim-par}) > 1
  and entry(2, tb-tax-rate-gds.corr-user-name, {&delim-par}) = {&hn-source-upgrade} then do:
  end.
  else do:
    find buf_goods where buf_goods.gds-code = tb-tax-rate-gds.gds-code
                  no-lock no-error.
    if available buf_goods then do:
      run fill-gds-list in p-imp-handle ( buffer buf_goods).
    end.
  end.
end.

/* $Workfile$ e n d */