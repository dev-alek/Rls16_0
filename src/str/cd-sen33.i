/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отсылка групп блюд на кассы - процедура отсылки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE SENDING:
DEFINE VARIABLE fq as integer no-undo .
define variable glog as logical no-undo .

FOR EACH ub.cash-desk NO-LOCK WHERE
        ub.cash-desk.db-num = g#db-num AND
         ub.cash-desk.obj-code = i-obj-code AND
        ub.cash-desk.cash-on
BREAK
By ub.cash-desk.pos-type :
    /*выполним действия, разнящиеся для разных типов касс -
    разные настройки в progress.ini - разные операции со spool-dir и т.д.*/
  IF FIRST-OF(ub.cash-desk.pos-type) then do:
    { str/cdg-gen.i
    &cd-buffer=ub.cash-desk
    &subject=fbr-gds-grp
    &data-by=object
    &out-title="''"
    &cdt-magia-xml=yes
    }
    /*пройдем цикл по всем кассам одного типа*/
    RUN for-cash-cycle no-error.

  END. /*IF FIRST-OF(ub.cash-desk.pos-type*/

    /*выполним действия, разнящиеся для разных типов касс - подчистки, сообщения и т.д.*/

  IF LAST-OF(ub.cash-desk.pos-type) then do:
    { str/cds-gen.i
    &cd-buffer=ub.cash-desk
    &subject=seller
    &data-by=object
    &out-title="''"
    &cdt-magia-xml=yes
    &out-title="'Передача групп блюд по объекту'"
    &out-title-add="'добавление групп блюд по объекту'"
    &out-title-del="'удаление групп блюд по объекту'"
    }
  END.
END. /*FOR EACH cash-desk*/

END PROCEDURE.
/* $Workfile$ e n d */