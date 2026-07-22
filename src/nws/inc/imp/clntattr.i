/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием в новостях клиентский атрибут ЕНВД

Автор: Рукавишников Вадим
Дата создания: 13/08/21
Author: Rukavishnikov Vadim
Creation date: 13/08/21

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if not available tb-clients-attr then do:
   create tb-clients-attr.
   assign compare-log = no.
end.
else do:
   buffer-compare tb-clients-attr TO wt-clients-attr case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
   buffer-copy wt-clients-attr TO tb-clients-attr.
   if wt-clients-attr.attr-code = "envd" then do:
      for each tax-rate-attr where
               tax-rate-attr.attr-code = wt-clients-attr.attr-code
      no-lock,
          each tax-rate-gds where
               tax-rate-gds.tax-code  = tax-rate-attr.tax-code
           and tax-rate-gds.rate-code = tax-rate-attr.rate-code
           and tax-rate-gds.fact-date <= today 
      no-lock:
         run fill-g-list in p-imp-handle (tax-rate-gds.gds-code,
                                          wt-clients-attr.obj-type,
                                          wt-clients-attr.obj-code).
      end.
   end.
end.

/* $Workfile$ e n d */