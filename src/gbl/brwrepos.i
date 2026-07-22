/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Для установки строки в середине браузера после переоткрывания запроса

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

Параметры:
{&browse-name} имя браузера
{&line-num}    номер строки - обычно следует указывать количество строк браузера
                              деленное пополам.
               Если в браузере 10 строк, то надо задать &line-num=5

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

do:
  {&browse-name} :SET-REPOSITIONED-ROW({&line-num}, "CONDITIONAL") .
end.
/* $Workfile$ e n d */