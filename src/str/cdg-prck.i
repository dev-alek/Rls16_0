/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

получение путей из INi и т.д. для касс pricecheck-servis+
Для различных subject

Автор: Чернова Светлана Александровна
Дата создания: 10/24/06
Author: Svetlana Chernova
Creation date: 10/24/06


*/

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
run str/get-inis.p (
                input {&shop}
              , input {&cd-buffer}.obj-code
              , input {&cd-buffer}.pos-type
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
else do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Директория для выгрузки для &1 для маг&2: &3"
                          , {&cd-buffer}.pos-type
                          , {&cd-buffer}.obj-code
                          , out )).

end.
&endif

/* $Workfile$ e n d */