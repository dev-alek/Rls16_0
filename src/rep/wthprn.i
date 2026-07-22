/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список форм печати

Автор: Демин Алексей Сергеевич
Дата создания: 03/20/06
Author: Alexey Demin
Creation date: 03/20/06

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
/*
1 Типы документов type-doc      * -это все
2 Статусы документов Status_    * -это все
3 exter_ + "," + inter_         * -это все
4 ext-doc-type документов       * -это все

5 Название в меню              char
6 Строка в которой указана каким бывает документ    char
7 Вызов программы              char
8 Дополнительные параметры вызова процедуры помимо recid(trn-doc)
9 Строка дополнительных опций, доступных при выборе в форме
10 Список syskey ('' и  'IBS' - виден)
11 Формат страницы
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
12 Список syskey, для которых НЕ нужно печатать форму
13 Дополнительное условие
*/

/*- Приходы, расходы, возвраты, списания ----------------------------------------------------------------------------------------------------------------------------------*/
{ rep/menu-doc.i {&expense_income_return_write-off}                                             "'*'"       "'*'"   "'*'"                                    "'Движение материальных ценностей'"      "'cost,sale,rubl,base'"   "'rep/r-w-doc.p'"   "''"                       "'------'" "''"    "'A4port'"  "''"             ? }
{ rep/menu-doc.i {&expense_income}                     {&fact_permitted_wayb_manufactured}      "'*'"       "'{&bef-WDEDT_Exp_Ext},{&bef-WDEDT_Put_Cli}'"    "'Счет-фактура'"                         "'cost,sale,rubl,base'"   "'rep/wthfct.p'"    "'no,all,no-round,no'"        "'--+---'" "''"    "''"        "''"             ? }
{ rep/menu-doc.i {&expense_income}                     {&fact_permitted_wayb_manufactured}      "'*'"       "'{&bef-WDEDT_Exp_Ext},{&bef-WDEDT_Put_Cli}'"    "'Счет-фактура обратная'"                "'cost,sale,rubl,base'"   "'rep/wthfct.p'"    "'no,all,no-round,yes'"        "'--+---'" "''"    "''"        "''"             ? }
{ rep/menu-doc.i {&expense_income}                     {&fact_permitted_wayb_manufactured}      "'*'"       "'{&bef-WDEDT_Exp_Ext},{&bef-WDEDT_Put_Cli}'"    "'Торг-12'"                              "'cost,sale,rubl,base'"   "'rep/wthtrg12.p'"  "'no,all,no-round,no'"        "'--+---'" "''"    "''"        "''"             ? }
{ rep/menu-doc.i {&expense_income}                     {&fact_permitted_wayb_manufactured}      "'*'"       "'{&bef-WDEDT_Exp_Ext},{&bef-WDEDT_Put_Cli}'"    "'Торг-12 обратная'"                     "'cost,sale,rubl,base'"   "'rep/wthtrg12.p'"  "'no,all,no-round,yes'"        "'--+---'" "''"    "''"        "''"             ? }
{ rep/menu-doc.i {&expense_income}                     {&fact_permitted_wayb_manufactured}      "'*'"       "'{&bef-WDEDT_Exp_Ext},{&bef-WDEDT_Put_Cli}'"    "'Форма НН-2-ДО'"                        "'cost,sale,rubl,base'"   "'rep/wth-nn2.p'"   "''"                       "'------'" "''"    "'A4port'"  "''"             ? }
{ rep/menu-doc.i {&exchange}                           {&fact_permitted_wayb_manufactured}      "'*'"       "'*'"                                            "'Форма НН-3-ДО'"                        "''"                      "'rep/wth-exch.p'"  "''"                       "'------'" "''"    "'A4port'"  "''"             ? }
{ rep/menu-doc.i {&expense_income_return_write-off}    {&fact_permitted}                        "'no,no'"   "'*'"                                            "'Форма M-11'"                           "'cost,sale,rubl,base'"   "'rep/r-wthm11.p'"  "''"                       "'------'" "''"    "'A4port'"  "''"             ? }
/*{ rep/menu-doc.i {&expense}                            {&fact_permitted}                        "'*'"       "'{&bef-WDEDT_Exp_Ext}'"                         "'Препроводительная ведомость'"          "'cost,sale,rubl,base'"   "'rep/vedwth.p'"    "''"                       "'------'" "''"    "''"        "''"             ? }*/
{ rep/menu-doc.i {&write-off}                          {&fact_permitted_wayb_manufactured}      "'*'"       "'*'"                                            "'Форма НН-9-ДО'"                        "'cost,sale,rubl,base'"   "'rep/wth-nn9.p'"   "''"                       "'------'" "''"    "'A4port'"  "''"             ? }
/*{ rep/menu-doc.i {&write-off}                          {&fact_permitted}    "'*'"   "'{&bef-WDEDT_Dst_free},{&bef-WDEDT_Dst_free}'"  "'Форма НН-9-ДО'"                        "'cost,sale,rubl,base'"   "'rep/wth-nn9.p'"   "''"                       "'------'" "''"    "'A4port'"  "''"             ? }*/
/*- Инвентаризация --------------------------------------------------------------------------------------------------------------------------------------------------------*/
{ rep/menu-doc.i {&inventory}                           "'*'"               "'*'"   "'*'"                                            "'Документ инвентаризации материальных ценностей'"  "'cost,sale,rubl,base'"   "'rep/r-w-inv.p'"   "''"                       "'------'" "''"    "'A4port'"  "''"             ? }

/* $Workfile$   E n d */