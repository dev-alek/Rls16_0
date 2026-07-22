/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение Значений переменных с первой закладки D_REPORT

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 03/11/04 11:32
для вызова в своей процедуре еще нужен инклюд
rvarpage.i


*/

procedure get-var-from-1-report-page :
 do
 on error undo, return error return-value
 :
define output parameter p-customer as integer no-undo .     /* выбор из блока ВЫБОР КОНТРАГЕНТА       */
define output parameter p-schet    as integer no-undo .     /* выбор из блока ВЫБОР банковского СЧЕТА */
define output parameter p-curr-code as integer no-undo .    /* выбор валюты  из блока ВЫБОР банковского СЧЕТА */
define output parameter p-period    as character no-undo .  /* выбор относительного периода времени */
define output parameter p-keep-spis  as character no-undo . /* выбор хранимого списка */

define variable v-res as character no-undo .
{ rep/get-link.i 'State':U }

 run get-attribute in state-source  ( {&keep-spis} ).
  v-res = return-value .
  if v-res = ? or v-res = "" then p-keep-spis = ? .
                             else p-keep-spis = return-value .


 run get-attribute in state-source  ( {&radio-period} ).
  v-res = return-value .
  if v-res = ? or v-res = "" then p-period = ? .
                             else p-period = return-value .

 run get-attribute in state-source  ( {&radio-customer} ).
  v-res = return-value .
  if v-res = ? or v-res = "" then p-customer = ? .
                             else p-customer = integer (return-value) .

 run get-attribute in state-source  ( {&radio-schet} ).
  v-res = return-value .
  if v-res = ? or v-res = "" then p-schet = ? .
                             else p-schet = integer (return-value) .

 run get-attribute in state-source  ( {&ex-curr-code} ).
  v-res = return-value .
  if v-res = ? or v-res = "" then p-curr-code = ? .
                             else p-curr-code = integer (return-value) .
 end. /* do */
end procedure. /* get-var-from-first-report-page */
/* $Workfile$ e n d */