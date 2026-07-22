/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение путей из INi и т.д. для различных касс  R-KEEPER

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
              , input {&cd-type-r-keeper}
              , input cash-desk.remote
              , input "send":U /*некий параметр который говорит для чего нам настройки*/
              , output out
              , output out2
              , output in_
              , output spl
              , output sav
              , output v-remote
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
  return error return-value .
end.

&if  "{&subject}" = "dis-card" &then
run adm/shattri.p (
        input "get":U
        ,input  {&shop}
        ,input  {&cd-buffer}.obj-code
        ,input  {&attr-cd-type-r-keeper}
        ,input  {&attr-cd-type-r-keeper_date-format} /*p-param-code*/
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
    v-date-format = v-value-character.
  end.
  else do:
    delete object v-tth.
    return error return-value .
  end.

&endif


/* $Workfile$ e n d */