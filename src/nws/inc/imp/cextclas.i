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

if not available tb-c-ext-classif then do:
  create tb-c-ext-classif.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-c-ext-classif TO wt-c-ext-classif case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-c-ext-classif TO tb-c-ext-classif.
   if wt-c-ext-classif.classif-subject = "goods" and wt-c-ext-classif.classif-name = "exp-esys-gds-code" then do:

   run fill-c-ext-classif in p-imp-handle (input tb-c-ext-classif.db-num
      ,input tb-c-ext-classif.Key#_One
      ,input tb-c-ext-classif.Key#_Two
      ,input tb-c-ext-classif.CharKey_One
      ,input tb-c-ext-classif.chip-num
      ).
end.
end.
/* $Workfile$ e n d */