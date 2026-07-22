/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение путей из INi и т.д. для касс IPC-servis+

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/23/03
Author: Bakhtadze Natalya
Creation date: 06/23/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{&subject}" = "good" &then
/*найдем коды дополнительных валют для кассы IPC*/
run adm/shattri.p (
        input "get":U
        ,input  {&shop}
        ,input  {&cd-buffer}.obj-code
        ,input  {&attr-cd-type-ipc-servispl}
        ,input  {&attr-cd-type-ipc-servispl_ipcsdobc} /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
  IF not error-status:error
  then dob-curr = v-value-character.
  else do:
    return error substitute("Ошибки при проверке параметра КОДЫ ДОПОЛН ВАЛЮТ ДЛЯ КАССЫ &1 для &2&3"
                              , {&cd-type-ipc-servispl}
                              , {&shop}
                              , abs(i-obj-code)).

  end.
  if index(dob-curr, ";":U) > 0  and can-do(entry(2,dob-curr,";"),string(i-obj-code)) then do:
    FIND LAST ub.curr-shop WHERE ub.curr-shop.obj-code = i-obj-code
                            and ub.curr-shop.obj-type = {&shop}
                            and ub.curr-shop.curr-code = int(entry(1,dob-curr,";"))
                            use-index pi NO-ERROR.
    if available ub.curr-shop then curr_cass = ub.curr-shop.exch-rate / curr-shop.exch-scale.
    else do:
      if not g#news then do:
        return error
        substitute("Не найден курс дополнительной валюты &1 в &2&3", entry(1,dob-curr,";"), {&shop}, i-obj-code).
      end.
    end.
  end.
&endif
&if "{&subject}" = "currency" &then
  /*найдем коды дополнительных валют для кассы IPC*/
  run adm/shattri.p (
          input "get":U
          ,input  {&shop}
          ,input  {&cd-buffer}.obj-code
          ,input  {&attr-cd-type-ipc-servispl}
          ,input  {&attr-cd-type-ipc-servispl_ipcsdobc} /*p-param-code*/
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
    dob-curr = v-value-character.
  end.
  else do:
    delete object v-tth.
    return error substitute("Ошибки при проверке параметра КОДЫ ДОПОЛН ВАЛЮТ ДЛЯ КАССЫ &1 для &2&3"
                                            , {&cd-type-ipc-servispl}
                                            , {&shop}
                                            , abs(i-obj-code)).
  end.
  dob-curr = entry(1,dob-curr,";").
  FIND FIRST ub.currency WHERE
            ub.currency.curr-code = int(dob-curr) NO-ERROR.
  if not available ub.currency then do:
    return error substitute( "!!!В БД отсутствует валюта с кодом &1 - неверное значение настроечного параметра ipcsdobc"
                            , int(dob-curr)
                           ).
  end.
  FIND LAST t-cs WHERE
            t-cs.obj-code = i-obj-code AND
            t-cs.obj-type = p-obj-type AND
            t-cs.curr-code = int(dob-curr)
            use-index pi NO-ERROR.
  if not available t-cs then do:
    return error   substitute( "!!!В БД отсутствует магазинный курс для валюты &1 по &2&3"
                            ,int(dob-curr)
                            , p-obj-type
                            , i-obj-code
                          ).
  end.
&endif

/* $Workfile$ e n d */