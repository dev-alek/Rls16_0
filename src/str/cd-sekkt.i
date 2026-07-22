/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура отсылки схемы интеграции ККТ

Автор: Шкляр Елена
Дата создания: 12/05/05
Author: Shklyar Elena
Creation date: 12/05/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE SENDING:
_cash-desk:
FOR EACH ub.cash-desk NO-LOCK WHERE
         ub.cash-desk.db-num = g#db-num AND
         ub.cash-desk.obj-code = i-obj-code AND
        ub.cash-desk.cash-on
BREAK
By ub.cash-desk.pos-type :
                                       
            if p-value = "0" then 
            do:
               put stream str-log unformatted 
                  today " " string(time,"HH:MM:SS")  " Изменена схема интеграции ККТ на 0 - с ожиданием ответа для кассы "  string(ub.cash-desk.cash-num) skip .
            end.
            else 
            do:
               put stream str-log unformatted 
                  today " " string(time,"HH:MM:SS")  " Изменена схема интеграции ККТ на 1 - без ожидания ответа для кассы "  string(ub.cash-desk.cash-num)   skip .
            end. 

  /*выполним действия, разнящиеся для разных типов касс -
  разные настройки в progress.ini - разные операции со spool-dir и т.д.*/
  IF FIRST-OF(ub.cash-desk.pos-type) then do:

    { str/cdg-gen.i
    &cd-buffer=ub.cash-desk
    &subject=gas-station
    &data-by=object
    &cdt-ibm=yes
    &cdt-ibm-xml=yes
    }
    /*пройдем цикл по всем кассам одного типа*/
    RUN for-cash-cycle no-error.
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("&1 &2", error-status:get-message(1), return-value)
                                              ).
      assign
      v-view-log = yes
      .
    end.
  END. /*IF FIRST-OF(ub.cash-desk.pos-type*/

  /*выполним действия, разнящиеся для разных типов касс - подчистки, сообщения и т.д.*/
  IF LAST-OF(ub.cash-desk.pos-type) then do:
    { str/cds-gen.i
    &cd-buffer=ub.cash-desk
    &subject=gas-station
    &data-by=object
    &cdt-ibm=yes
    &cdt-ibm-xml=yes
    &out-title="'Передача схемы интеграции ККТ'"
    &out-title-add="'изменение схемы интеграции ККТ'"
    &out-title-del="'удаление схемы интеграции ККТ'"
    }
  END.
END. /*FOR EACH cash-desk*/

END PROCEDURE.
/* $Workfile$ e n d */