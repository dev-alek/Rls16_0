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

procedure SENDING:
_cash-desk:
for each ub.cash-desk no-lock where
         ub.cash-desk.db-num = g#db-num and
         ub.cash-desk.obj-code = i-obj-code and
        (ub.cash-desk.cash-on  = yes or mSendAll)
break
by ub.cash-desk.pos-type :
                                       
  
  /*выполним действия, разнящиеся для разных типов касс -
  разные настройки в progress.ini - разные операции со spool-dir и т.д.*/
  if first-of(ub.cash-desk.pos-type) then do:
    /*пройдем цикл по всем кассам одного типа*/
    run for-cash-cycle no-error.
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
  end. /*IF FIRST-OF(ub.cash-desk.pos-type*/
end. /*FOR EACH cash-desk*/

end procedure.
/* $Workfile$ e n d */