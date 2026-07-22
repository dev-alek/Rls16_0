/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение путей из INi и т.д. для касс OMRON

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/23/03
Author: Bakhtadze Natalya
Creation date: 06/23/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{&subject}" = "currency" &then
  /*найдем код баз вал из параметров системы для кассы omron-new*/
  run adm/shattri.p (
          input "get":U
          ,input  {&shop}
          ,input  {&cd-buffer}.obj-code
          ,input  {&attr-cd-type-omron-new}
          ,input  {&attr-cd-type-omron-new_omrnbase} /*p-param-code*/
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-value-logical
          ,output v-param-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .

  IF not error-status:error then do:
    delete object v-tth.
    base-cass = v-value-integer.
  end.
  else do:
    delete object v-tth.
    return error.
  end.
  right-curs = ( if base-cass = 0 then yes else no ).
  /*найдем список  вал из параметров системы для кассы omron*/
  run adm/shattri.p (
          input "get":U
          ,input  {&shop}
          ,input  {&cd-buffer}.obj-code
          ,input  {&attr-cd-type-omron-new}
          ,input  {&attr-cd-type-omron-new_omrncurl} /*p-param-code*/
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-value-logical
          ,output v-param-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
  IF not error-status:error then do:
    delete object v-tth.
    curr-list = v-value-character.
  end.
  else do:
    delete object v-tth.
    return error.
  end.
&endif
/* $Workfile$ e n d */