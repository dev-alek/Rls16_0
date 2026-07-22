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

&if "{&subject}" = "good" or "{&subject}" = "currency" &then
  if action = "U" then do:
    run str/get-inis.p (
                    input {&shop}
                  , input {&cd-buffer}.obj-code
                  , input {&cd-type-omron}
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
      return error.
    end.
    assign
    fname = substring( string( next-value( s-spool, {&db-name_schema} ), '99999999999999999999'), 13, 8 ).
  end.
&endif
&if "{&subject}" = "currency" &then
  /*найдем код баз вал из параметров системы для кассы omron*/
  run adm/shattri.p (
          input "get":U
          ,input  {&shop}
          ,input  {&cd-buffer}.obj-code
          ,input  {&attr-cd-type-omron}
          ,input  {&attr-cd-type-omron_omrbase} /*p-param-code*/
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-value-logical
          ,output v-param-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .

  IF not error-status:error then do:
    base-cass = v-value-integer.
    delete object v-tth.
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
          ,input  {&attr-cd-type-omron}
          ,input  {&attr-cd-type-omron_omrcurl} /*p-param-code*/
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
    curr-list = v-value-character .
  end.
  else do:
    delete object v-tth.
    return error.
  end.
&endif


/* $Workfile$ e n d */