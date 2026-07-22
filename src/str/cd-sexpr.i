/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура отслыки  файла параметров на кассу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/25/09
Author: Bakhtadze Natalya
Creation date: 06/25/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE SENDING:
_cash-desk:
FOR EACH ub.cash-desk NO-LOCK WHERE
         ub.cash-desk.db-num = p-db-num AND
         ub.cash-desk.obj-code = p-obj-code AND
         ub.cash-desk.pos-type = p-pos-type AND
        (p-cash-num = ?
        or
        ub.cash-desk.cash-num = p-cash-num)
BREAK
By ub.cash-desk.pos-type :
  /*выполним действия, разнящиеся для разных типов касс -
  разные настройки в progress.ini - разные операции со spool-dir и т.д.*/
  IF FIRST-OF(ub.cash-desk.pos-type) then do:

    { str/cdg-gen.i
    &cd-buffer=ub.cash-desk
    &subject=file
    &data-by=object
    &cdt-ibm-xml=yes
    }
    /*пройдем цикл по всем кассам одного типа*/
    RUN for-cash-cycle in this-procedure no-error.
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
    &subject=file
    &data-by=object
    &cdt-ibm-xml=yes
    &out-title="'Передача файла параметров'"
    &out-title-add="'изменение параметров'"
    &out-title-del="''"
    }
  END.
END. /*FOR EACH cash-desk*/

END PROCEDURE.
/* $Workfile$ e n d */