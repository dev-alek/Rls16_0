/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список форм документов производства

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

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
{ rep/menu-doc.i {&manufacturing} "'*'"                                     "'*'" "'*'"     "'Акт производства готовой продукции'"                              "'cost,sale,rubl,base'" "'rep/r-fbr.p'"    "''"             "'------'"       "''" "'self'"    "''" ? }
if varhave-dressing then do:
  { rep/menu-doc.i {&manufacturing} "'*'"                                   "'*'" "'*'"     "'Акт о разделке мяса-сырья на полуфабрикаты'"                      "'cost,sale,rubl,base'" "'rep/op-23.p'"    "''"             "'------'"       "''" "'A4lans'"  "''" ? }
end.
{ rep/menu-doc.i {&manufacturing} {&fact_permitted}                         "'*'" "'*'"     "'Калькуляционные карты в текущих продажных ценах'"    "'cost,sale,rubl,base'" "'rep/op-1.p'"     "'1,no,no,no'"   "'+-----'"       "''" "'A4port'"  "''" ? }
{ rep/menu-doc.i {&manufacturing} {&fact_permitted}                         "'*'" "'*'"     "'Калькуляционные карты в ценах документа'"                         "'cost,sale,rubl,base'" "'rep/op-1.p'"     "'1,no,no,yes'"  "'+-----'"       "''" "'A4port'"  "''" ? }
{ rep/menu-doc.i {&manufacturing} {&fact}                                   "'*'" "'*'"     "'Акт отклонения'"                                                  "'cost,sale,rubl,base'" "'rep/op-del.p'"   "''"             "'------'"       "''" "'A4lans'"  "''" ? }
{ rep/menu-doc.i {&manufacturing} {&fact_permitted}                         "'*'" "'*'"     "'Акт производства промежуточных ингредиентов'"                     "'cost,sale,rubl,base'" "'rep/fbr-actp.p'" "''"             "'------'"       "''" "'A4lans'"  "''" ? }
{ rep/menu-doc.i {&manufacturing} {&fact}                                   "'*'" "'*'"     "'Калькуляционная карточка '"                                       "'cost,sale,rubl,base'" "'rep/ccard.p'"    "''"             "'------'"       "''" "'A4port'"  "''" ? }