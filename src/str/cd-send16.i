/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отсылка промоакций на кассы - процедура отсылки

Автор: Шкляр Елена
Дата создания: 02/19/06
Author: Shklyar Elena
Creation date: 02/19/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE SENDING:
DEFINE VARIABLE fq as integer no-undo .
define variable glog as logical no-undo .
FOR EACH ub.cash-desk NO-LOCK WHERE
         ub.cash-desk.db-num = g#db-num
     AND ub.cash-desk.obj-code = i-obj-code
     and ub.cash-desk.pos-type = {&cd-type-IBM-XML}
     AND ub.cash-desk.cash-on
BREAK
By ub.cash-desk.pos-type :
    /*выполним действия, разнящиеся для разных типов касс -
    разные настройки в progress.ini - разные операции со spool-dir и т.д.*/
  IF FIRST-OF(ub.cash-desk.pos-type) then do:
    { str/cdg-gen.i
      &cd-buffer=ub.cash-desk
      &subject=pay
      &data-by=object
      &cdt-ibm=no
      &cdt-ibm-xml=yes
      &cdt-maria=no

      }
    /*пройдем цикл по всем кассам одного типа*/
    RUN for-cash-cycle no-error.

  END. /*IF FIRST-OF(ub.cash-desk.pos-type*/

  /*выполним действия, разнящиеся для разных типов касс - подчистки, сообщения и т.д.*/

  IF LAST-OF(ub.cash-desk.pos-type) then do:
    { str/cds-gen.i
      &cd-buffer=ub.cash-desk
      &subject=pay
      &data-by=object
      &cdt-ibm=no
      &cdt-ibm-xml=yes
      &cdt-maria=no
      &out-title="'Передача промоакций '"
      &out-title-add="'добавление промоакций '"
      &out-title-del="'удаление промоакций '"
      }
  END.
END. /*FOR EACH cash-desk*/

END PROCEDURE.

/* $Workfile$ e n d */