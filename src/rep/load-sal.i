/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список форм печати отчета о продаже

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/09/05
Author: Bakhtadze Natalya
Creation date: 03/09/05

*/

/*
1 типы документов type-doc      * -это все
2 Статусы документов Status_    * -это все
3 Internal документов           * -это все
4 Flag документов               * -это все

5 Уникальный !!! номер отчета    int ! ! !
6 Номер следования в меню      int
7 Название в меню              char
8 строка в которой указана каким бывает документ    char
9 Вызов программы              char
10 Дополнительные параметры вызова процедуры помимо inkas.inkas-code
11 список syskey ('' и  'IBS' - виден)
12 формат страницы
     'A3port'
     'A3lans'
     'A4port'
     'A4lans' - по умолчанию
     self - своя печать
     EXCEL - вывод в excel

  типы цен   cost  - учетная;
             sale  - документа;
             crsa  - продажная;
   типы валют    rubl
                 base
 Пример  "'cost,sale,rubl,base,scale'"
13 список syskey, для которых НЕ нужно печатать форму
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable is-ptrl  as character no-undo .
define variable is-jwlr  as character no-undo .
define variable ptwounit as logical no-undo init yes .
define variable cas-shft as logical no-undo init no.
define variable conf-attr as character no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
run gbl/conf-rd.p ("is-ptrl", "", "", 0, "", "", "", no, output is-ptrl, output par-type) no-error.
if error-status :error
  or par-type <> "l"
  or is-ptrl  <> "yes"
then do:
  assign is-ptrl = "no".
end.
run gbl/conf-rd.p ("is-jwlr", "", "", 0, "", "", "", no, output is-jwlr, output par-type) no-error.
if error-status :error
  or par-type <> "l"
  or is-jwlr  <> "yes"
then do:
  assign is-jwlr = "no".
end.
{ gbl/cas-shft.i buf_inkas.obj-type buf_inkas.obj-code cas-shft }

{ rep/menu-doc.i 'inkas' "'*'"          "'*'" "'*'"    "'Стандартная форма'"                                "''"   "'str/sjbysale.p'"   "substitute('&1,&2', ptwounit, cas-shft)"   "'------'"    "''"                    "'output'"  "''"             ? }
{ rep/menu-doc.i 'inkas' {&fact}        "'*'" "'*'"    "'Акт по продаже (скидки)'"                          "''"   "'str/saledsca.p'"   "''"                                        "'------'"    "'Basis'"               "'A4port'"  "''"             ? }
{ rep/menu-doc.i 'inkas' {&fact}        "'*'" "'*'"    "'Акт по продаже (скидки) потоварно'"                "''"   "'str/saldsca1.p'"   "''"                                        "'------'"    "'Basis'"               "'self'"    "''"             ? }
{ rep/menu-doc.i 'inkas' "'*'"          "'*'" "'*'"    "'Отчет по зарезерв. партиям по вариантам закупки'"  "''"   "'str/salevzak.p'"   "'print'"                                   "'------'"    "'IBS'"                 "'A4lans'"  "''"             ? }
{ rep/menu-doc.i 'inkas' {&g___new}     "'*'" "'*'"    "'Резервирование партий по вариантам закупки'"       "''"   "'str/salevzak.p'"   "'work'"                                    "'------'"    "'IBS'"                 "'self'"    "''"             ? }
{ rep/menu-doc.i 'inkas' {&fact}        "'*'" "'*'"    "'Экспорт по варианту закупки 2'"                    "''"   "'str/salevzak.p'"   "'export'"                                  "'------'"    "'IBS'"                 "'self'"    "''"            ? }


/* $Workfile$   E n d */