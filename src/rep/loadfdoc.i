/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список форм печати

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/14/10
Author: Bakhtadze Natalya
Creation date: 04/14/10

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
/*
1 типы документов type-doc      * -это все
2 Статусы документов Status_    * -это все

3 Уникальный !!! номер отчета    int ! ! !
4 Номер следования в меню      int
5 Название в меню              char
6 строка в которой указана каким бывает документ    char
7 Вызов программы              char
8 Дополнительные параметры вызова процедуры помимо recid(trn-doc)
9 список syskey ('' и  'IBS' - виден)
10 формат страницы
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
11 список syskey, для которых НЕ нужно печатать форму
*/


{ rep/menufdoc.i {&income-cash}           {&fin-fact_fin-permitted_fin-new}               "'форма N КО-1'"                              "'doc,rubl,base'"   "'rep/findocpr.p'"   "''"                        "'-'"  "''"                 "'HTML'"  "''"                                  ? }

{ rep/menufdoc.i {&expense-cash}          {&fin-fact_fin-permitted_fin-new}               "'Заявка на оплату'"                          "'doc,rubl,base'"   "'rep/prn-zay.p'"   "'plat,yes'"                 "'-'"  "''"                 "'A4port'"  "''"                                  ? }
{ rep/menufdoc.i {&expense-cash}          {&fin-fact_fin-permitted_fin-new}               "'форма N КО-2'"                              "'doc,rubl,base'"   "'rep/findocpr.p'"   "''"                        "'-'"  "''"                 "'HTML'"  "''"                                  ? }
{ rep/menufdoc.i {&expense-cash}          {&fin-fact_fin-permitted_fin-new}               "'препроводительная ведомость'"               "'doc,rubl,base'"   "'rep/findocpr2.p'"   "''"                        "'-'"  "''"                 "'HTML'"  "''"                                  ? }

{ rep/menufdoc.i {&income-cashless}       {&fin-fact_fin-bank_fin-permitted_fin-new}      "'форма N 0401060'"                           "'doc,rubl,base'"   "'rep/findocpr.p'"   "''"                        "'-'"  "''"                 "'A4port'"  "''"                                  ? }

{ rep/menufdoc.i {&expense-cashless}      {&fin-fact_fin-bank_fin-permitted_fin-new}      "'форма N 0401060'"                           "'doc,rubl,base'"   "'rep/findocpr.p'"   "''"                        "'-'"  "''"                 "'A4port'"  "''"                                  ? }
{ rep/menufdoc.i {&expense-cashless}      {&fin-fact_fin-bank_fin-permitted_fin-new}      "'Заявка на оплату'"                          "'doc,rubl,base'"   "'rep/prn-zay.p'"   "'plat,yes'"                 "'-'"  "''"                 "'A4port'"  "''"                                  ? }

{ rep/menufdoc.i {&income-payoff}         {&fin-fact_fin-permitted_fin-new}               "'форма АПЗ'"                                 "'doc,rubl,base'"   "'rep/findocpr.p'"   "''"                        "'-'"  "''"                 "'A4port'"  "''"                                  ? }

{ rep/menufdoc.i {&expense-payoff}        {&fin-fact_fin-permitted_fin-new}               "'форма АПЗ'"                                 "'doc,rubl,base'"   "'rep/findocpr.p'"   "''"                        "'-'"  "''"                 "'A4port'"  "''"                                  ? }
{ rep/menufdoc.i {&expense-payoff}        {&fin-fact_fin-permitted_fin-new}               "'Заявка на оплату'"                          "'doc,rubl,base'"   "'rep/prn-zay.p'"   "'plat,yes'"                 "'-'"  "''"                 "'A4port'"  "''"                                  ? }










/* $Workfile$   E n d */