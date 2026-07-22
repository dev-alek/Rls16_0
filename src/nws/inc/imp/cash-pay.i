/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием в новостях ставок налогов

Автор: Рубан Дмитрий Андреевич
Дата создания: 19.10.2020

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if not available tb-cash-pay then do:
  create tb-cash-pay.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-cash-pay TO wt-cash-pay case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-cash-pay TO tb-cash-pay.
  run fill-cash-pay in p-imp-handle (input tb-cash-pay.cdpay-code
                                    ,input tb-cash-pay.curr-code
                                     ).
end.

/* $Workfile$ e n d */