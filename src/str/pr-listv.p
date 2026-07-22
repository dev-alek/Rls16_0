block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: pr-listv.p $
$Archive: str/pr-listv.p $

Фильтрует методы переоценки

Автор: Комаров Иван Сергеевич
Дата создания: 10/19/10
Author: Ivan Komarov
Creation date: 10/19/10

Автор1: Чернова Светлана Александровна
Дата создания1: 09/13/03

*/

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: pr-listv.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/pr-listv.p $":U .
def var vss-description as character no-undo init " фильтрует методы переоценки   ".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getsect.i def }

define input  parameter i-list   as character no-undo .
define input  parameter init-val as character no-undo .
define output parameter o-list   as character no-undo .

define variable i           as integer   no-undo .
define variable par-pr-list as character no-undo .    /* для чтения параметра конфигурации */

  { gbl/getsect.i run "''" 0 {&attr-overval} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-list} then par-pr-list = thbjattr_thbj-attr.property-value-character .
  end.

 if par-pr-list = ? then par-pr-list = ""   .
 if par-pr-list = ""  then  do:
    o-list = i-list .
    return .
 end.

/* проверка что там в параметре записано */
define variable v-nn as integer   no-undo .
v-nn =  num-entries ( par-pr-list )  .
do i = 1 to v-nn :
   if lookup(caps(entry(i,par-pr-list)) , caps({&pr-calc-methods-inf-list}) + "," + caps({&pr-calc-methods-list})  + "," + caps({&pr-calc-methods-inf-DFP}) ) = 0
     then do:
     if caps(entry(i,par-pr-list)) = "" then
      message "Неправильное значение метода расчета переоценки - есть пробел или лишняя запятая" skip
      "Фильтр игнорируется !" skip
      "Проверьте параметр системы pr-list! " skip
      par-pr-list
      .
     else
      message "Неправильное значение метода расчета переоценки - " entry(i,par-pr-list) skip
      "Фильтр игнорируется !" skip
      "Проверьте параметр системы pr-list! ".
      o-list = i-list .
      return.
      end.
end.


o-list = "" .
define variable v-1 as integer   no-undo .
v-1 = num-entries ( i-list ) .
do i = 1 to v-1 :
   if lookup(caps(entry(i,i-list)) , caps(par-pr-list)) > 0
      or caps(entry(i,i-list)) = caps({&pr-calc-no}) /* этот должен быть в интерфейсе переоценки */
      or caps(entry(i,i-list)) = caps({&pr-calc-fix}) /* этот должен быть в карточках и группах */
      or caps(entry(i,i-list)) = caps(init-val)
      then do:
      assign
        o-list = o-list
         + ( if o-list = "" then "" else "," )
         + entry( i , i-list ) .
      end.
end.
return .