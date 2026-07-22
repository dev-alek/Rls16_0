/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список печатных форм план-меню

Автор: Демин Алексей Сергеевич
Дата создания: 09/09/05
Author: Alexey Demin
Creation date: 09/09/05

1 типы документов type-doc      * -это все
2 Статусы документов Status_    * -это все
3 Internal документов           * -это все
4 Flag документов               * -это все

5 Уникальный !!! номер отчета    int ! ! !
6 Номер следования в меню      int
7 Название в меню              char
8 строка в которой указана каким бывает документ    char
9 Вызов программы              char
10 Дополнительные параметры вызова процедуры помимо recid(trn-doc)
11 syskey ('' и  'IBS' - виден)
12 формат страницы
     'A3port'
     'A3lans'
     'A4port'
     'A4lans' - по умолчанию
     self - своя печать
     EXCEL - вывод в excel

  типы цен   cost  - учетна
             sale  - документа
             crsa  - продажна
   типы валют    rubl
                 base
 Пример  "'cost,sale,rubl,base,scale'"
13 список syskey, для которых НЕ нужно печатать форму

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

{ rep/menu-doc.i {&plnmenu} "{&fact_permitted}"     "'*'" "'*'"   "'Требование в кладовую'"                     "'cost,sale,rubl,base'"     "'rep/op-3.p'"          "''"   "'------'"       "''"        "'A4port'"      "''" ? }
/*-ПЛАН-МЕНЮ-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
{ rep/menu-doc.i {&plnmenu} "'*'"                   "'*'" "'*'"   "'План-меню'"                                 "'cost,sale,rubl,base'"     "'rep/r-respln.p'"      "''"   "'------'"       "''"        "'A4port'"      "''" ? }
{ rep/menu-doc.i {&plnmenu} {&fact}                 "'*'" "'*'"   "'МЕНЮ'"                                      "'cost,sale,rubl,base'"     "'rep/r-resmn.p'"       "''"   "'------'"       "''"        "'A4port'"      "''" ? }
{ rep/menu-doc.i {&plnmenu} {&fact}                 "'*'" "'*'"   "'Калькуляционные карточки по план-меню'"     "'cost,sale,rubl,base'"     "'rep/r-res2.p'"        "''"   "'------'"       "''"        "'A4port'"      "''" ? }
{ rep/menu-doc.i {&plnmenu} {&fact_permitted}       "'*'" "'*'"   "'Технологические карты по план-меню'"        "'cost,sale,rubl,base'"     "'rep/r-restk.p'"       "''"   "'------'"       "''"        "''"            "''" ? }
{ rep/menu-doc.i {&plnmenu} {&permitted}            "'*'" "'*'"   "'Нехватка продуктов'"                        "'cost,sale,rubl,base'"     "'rep/r-res3.p'"        "''"   "'------'"       "''"        "'A4port'"      "''" ? }
/*-СЧЕТ-ЗАКАЗ----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
{ rep/menu-doc.i {&billord} {&fact}                 "'*'" "'*'"   "'Калькуляционные карточки по счет-заказу'"   "'cost,sale,rubl,base'"     "'rep/r-res2.p'"        "''"   "'------'"       "''"        "'A4port'"      "''" ? }
{ rep/menu-doc.i {&billord} {&permitted}            "'*'" "'*'"   "'Нехватка продуктов'"                        "'cost,sale,rubl,base'"     "'rep/r-res3.p'"        "''"   "'------'"       "''"        "'A4port'"      "''" ? }

/* $Workfile$ e n d */