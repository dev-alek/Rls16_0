/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка наличия в БД включенного ДОП БК равного создаваемому весовому

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

может понадобиться если повторно будем использовать диапазоны
и на всякий пожарный

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer dub-prod-bc{&vssseq} for ub.prod-bc.
FIND FIRST dub-prod-bc{&vssseq} No-LOCK WHERE
            dub-prod-bc{&vssseq}.b-str = {1} AND
            dub-prod-bc{&vssseq}.bc-on = yes No-error.
if avail dub-prod-bc{&vssseq} then do:
&if "{6}" = "silence" &then
   return error  ("Невозможно создать весовой код для товара" + {&space-char} +
                  string({2}) + {&space-char} +
                  string({3}) + {&space-char} +
                  string({4}) + {&new-line} +
                  "Уже имеется в БД товар с включенным дополнительным кодом равным" +
                   {&space-char} +
                   dub-prod-bc{&vssseq}.b-str).
&else
  message
  "Невозможно создать весовой или штучный код для весов для товара" skip
  {2} {3} {4} skip
  "Уже имеется в БД товар с включенным дополнительным кодом равным"
   dub-prod-bc{&vssseq}.b-str
   view-as alert-box ERROR.
   return {5} '':U.
&endif
end.


/* $Workfile$ e n d */