/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение путей из INi и т.д. для различных касс IBM

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/23/03
Author: Bakhtadze Natalya
Creation date: 06/23/03

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

run str/get-inis.p (
                input {&shop}
              , input {&cd-buffer}.obj-code
              , input {&cd-buffer}.pos-type
              , input cash-desk.remote
              , input "send":U /*некий параметр который говорит для чего нам настройки*/
              , output out /*куда выгружаем*/
              , output out2
              , output in_  /*откуда загружаем*/
              , output spl  /*традиционно*/
              , output sav  /*традиционно*/
              , output v-remote /*файлы Addin.exe*/
              )  no-error .

if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                          , {&cd-buffer}.pos-type
                          , {&cd-buffer}.obj-code
                          , {&new-line}
                          , error-status:get-message(1)
                          , return-value )).
  assign
  v-view-log = yes.
  return error.
end.



&if "{&subject}" = "pay" &then
  /*
  run adm/shattri.p (
        input "get":U
        ,input  {&shop}
        ,input  {&cd-buffer}.obj-code
        ,input  {&attr-cd-type-maria}
        ,input  {&attr-cd-type-maria_mariapayg} /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
  IF not error-status:error then do:
    mariapayg = v-value-character.
    delete object v-tth.
  end.
  else do:
    delete object v-tth.
    return error return-value .
  end.
  */
  run adm/shattri.p (
        input "get":U
        ,input  {&shop}
        ,input  {&cd-buffer}.obj-code
        ,input  {&attr-cd-type-maria}
        ,input  {&attr-cd-type-maria_mariapayp} /*p-param-code*/
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
    mariapayp = v-value-character.
  end.
  else do:
    delete object v-tth.
    return error return-value .
  end.
&endif

&if  "{&subject}" = "tax" or  "{&subject}" = "good" &then

/*список соответсвтия ставок налогов категоряи налогов на кссе для св-мфе = 1*/
run adm/shattri.p (
        input "get":U
        ,input  {&shop}
        ,input  {&cd-buffer}.obj-code
        ,input  {&attr-cd-type-maria}
        ,input  {&attr-cd-type-maria_cdtaxlst} /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
IF not error-status:error then do:
 cdtaxlst = v-value-character.
 delete object v-tth.
end.
else do:
  delete object v-tth.
  return error return-value .
end.
&endif

&if "{&subject}" = "sum-grp" or "{&subject}" = "pay" or "{&subject}" = "dis-card" or "{&subject}" = "good" or "{&subject}" = "gds-obj-attr" or "{&subject}" = "tot-discnt" &then
run adm/shattri.p (
        input "get":U
        ,input  {&shop}
        ,input  {&cd-buffer}.obj-code
        ,input  {&attr-cd-type-maria}
        ,input  {&attr-cd-type-maria_dr-list} /*p-param-code*/
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
  dr-list = v-value-character.
end.
else do:
  delete object v-tth.
  return error return-value .
end.
&ENDIF

&if "{&subject}" = "sum-grp" &THEN
run adm/shattri.p (
        input "get":U
        ,input  {&shop}
        ,input  {&cd-buffer}.obj-code
        ,input  {&attr-cd-type-maria}
        ,input  {&attr-cd-type-maria_drgrouprank} /*p-param-code*/
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
  drgrouprank = v-value-character.
end.
else do:
  delete object v-tth.
  return error return-value .
end.
&endif

&if "{&subject}" = "good" &THEN
run adm/shattri.p (
        input "get":U
        ,input  {&shop}
        ,input  {&cd-buffer}.obj-code
        ,input  {&attr-cd-type-maria}
        ,input  {&attr-cd-type-maria_drgdsrank} /*p-param-code*/
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
  drgdsrank = v-value-character.
end.
else do:
  delete object v-tth.
  return error return-value .
end.
&endif





/* $Workfile$ e n d */