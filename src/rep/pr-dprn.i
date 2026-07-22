/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список печатных форм для переоценки

Автор: Демин Алексей Сергеевич
Дата создания: 03/23/06
Author: Alexey Demin
Creation date: 03/23/06

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

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
*/
/*-РАСХОДЫ-----------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*1-29 */
define variable is-ptrl  as character no-undo.
define variable par-type as character no-undo.
run gbl/conf-rd.p ("is-ptrl", "", "", 0, "", "", "", no, output is-ptrl, output par-type) no-error.
if error-status :error or par-type <> "l" or is-ptrl <> "yes" then do: assign is-ptrl = "no". end.
{ rep/menu-doc.i "'*'"   {&act-overvalue}                               "'*'" "'*'" "'Акт переоценки'"                                              "'cost,sale,rubl,base'" "'rep/r-pr-akt.p'"    "'akt'"             "'------'" "''" "'HTML'" "''" ?                 }
{ rep/menu-doc.i "'*'"   {&act-overvalue}                               "'*'" "'*'" "'Акт переоценки с фото товара'"                                  "'cost,sale,rubl,base'" "'rep/r-pr-akt-foto.p'"    "'akt'"             "'------'" "''" "'HTML'" "''" ?                 }
{ rep/menu-doc.i "'*'"   {&act-overvalue}                               "'*'" "'*'" "'Акт переоценки ТАП-1-ДО'"                                     "'crsa'"                "'rep/r-tap1.p'"   "''"                "'------'" "''" "'A4lans'" "''" ?                 }
{ rep/menu-doc.i "'*'" "'{&bef-g___new},{&bef-order},{&bef-permitted}'" "'*'" "'*'" "'Приказ на переоценку'"                                        "'cost,sale,rubl,base'" "'rep/r-prikaz.p'"    "'prik'"            "'------'" "''" "'HTML'" "''" ?                 }
{ rep/menu-doc.i "'*'"   {&act-overvalue}                               "'*'" "'*'" "'Акт переоценки топлива (весовой учет)'"                       "'cost,sale,rubl,base'" "'rep/r-act-kg.p'" "'act'"             "'------'" "''" "'A4port'" "''" "is-ptrl = 'yes'" }
{ rep/menu-doc.i "'*'" "'{&bef-g___new},{&bef-order},{&bef-permitted}'" "'*'" "'*'" "'Приказ на переоценку топлива (весовой учет)'"                 "'cost,sale,rubl,base'" "'rep/r-act-kg.p'" "'ord'"             "'------'" "''" "'A4port'" "''" "is-ptrl = 'yes'" }
{ rep/menu-doc.i "'*'" "'*'"                                            "'*'" "'*'" "'Протокол согласования цен'"                                   "'cost,sale,rubl,base'" "'rep/r-aktp.p'"   "''"                "'------'" "''" "'A4port'" "''" ?                 }
{ rep/menu-doc.i "'*'" "'*'"                                            "'*'" "'*'" "'Отчет по неосновным кодам'"                                   "'cost,sale,rubl,base'" "'rep/r-aktn.p'"   "''"                "'------'" "''" "'A4port'" "''" ?                 }
{ rep/menu-doc.i "'*'" "'*'"                                            "'*'" "'*'" "'Ценники (этикетки)'"                                          "'cost,sale,rubl,base'" "'rep/tick-doc.p'" "'price'"           "'------'" "''" "'self'"   "''" ?                 }
{ rep/menu-doc.i "'*'" "'*'"                                            "'*'" "'*'" "'Калькуляционные карточки (печатать только после переоценки)'" "'cost,sale,rubl,base'" "'rep/op-1.p'"     "'yes,yes,1,no,no'" "'------'" "''" "'A4port'" "''" ?                 }
{ rep/menu-doc.i "'*'"   {&act-overvalue}                               "'*'" "'*'" "'Акт о переоценке товаров'"                                    "'cost,sale,rubl,base'" "'rep/r-ord.p'"    "'akt'"             "'------'" "'yukos,ibs,Rosneft*'" "'A4lans'" "''" ?                 }

/* $Workfile$   E n d */