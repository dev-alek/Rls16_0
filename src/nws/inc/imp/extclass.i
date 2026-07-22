/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием в новостях товары соответствия

Автор: Шкляр Елена
Дата создания: 19.10.2020

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if not available tb-ext-classif then do:
  create tb-ext-classif.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-ext-classif TO wt-ext-classif case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-ext-classif TO tb-ext-classif.
   if wt-ext-classif.classif-subject = "goods" and wt-ext-classif.classif-name = "exp-esys-gds-code" then do:
   run fill-ext-classif in p-imp-handle (input tb-ext-classif.db-num
      ,input tb-ext-classif.Key#_One
      ,input tb-ext-classif.Key#_Two
      ,input tb-ext-classif.CharKey_One
      ).
   end.   
end.
/*end.*/
/* $Workfile$ e n d */