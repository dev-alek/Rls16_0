/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием в новостях Промоакций

Автор: Шкляр Елена
Дата создания: 19.10.2020

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if not available tb-code then 
do:
   create tb-code.
   assign 
      compare-log = no.
end.
else 
do:
   buffer-compare tb-code TO wt-code case-sensitive save result in compare-log no-error.
end.
if not compare-log then 
do:
   buffer-copy wt-code TO tb-code.
   run fill-code in p-imp-handle (input tb-code.parent
                                 ,input tb-code.code
      ).
end.

/* $Workfile$ e n d */