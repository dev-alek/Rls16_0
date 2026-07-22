/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отсылка подразделений на кассы - процедура отсылки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/04/03
Author: Bakhtadze Natalya
Creation date: 12/04/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE SENDING:
DEFINE VARIABLE fq as integer no-undo .


FOR EACH ub.cash-desk NO-LOCK WHERE
        ub.cash-desk.db-num = g#db-num AND
        ub.cash-desk.cash-on = yes
BREAK
By ub.cash-desk.db-num
By ub.cash-desk.pos-type
By ub.cash-desk.autonomy:
    /*выполним действия, разнящиеся для разных типов касс -
    разные настройки в progress.ini - разные операции со spool-dir и т.д.*/
  if ub.cash-desk.pos-type <> {&cd-type-IBM-XML} then NEXT.

  IF FIRST-OF(ub.cash-desk.pos-type) then do:
    { str/cdg-gen.i
    &cd-buffer=ub.cash-desk
    &subject=db-object
    &data-by=db
    &cdt-ibm-xml=yes
    }
    /*пройдем цикл по всем кассам одного типа*/
    RUN for-cash-cycle no-error.

  END. /*IF FIRST-OF(ub.cash-desk.pos-type*/

    /*выполним действия, разнящиеся для разных типов касс - подчистки, сообщения и т.д.*/
  IF LAST-OF(ub.cash-desk.pos-type) then do:
    { str/cds-gen.i
    &cd-buffer=ub.cash-desk
    &subject=db-object
    &data-by=db
    &cdt-ibm-xml=yes
    &out-title="'Передача данных по объектам БД'"
    &out-title-add="'добавление данных по объектам БД'"
    &out-title-del="'удаление данных по объектам БД'"
    }

  END.
END. /*FOR EACH cash-desk*/

END PROCEDURE.
/* $Workfile$ e n d */