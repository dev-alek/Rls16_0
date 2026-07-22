/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отсылка скидок на итог на кассы - процедура отсылки

јвтор: Ѕахтадзе Ќаталь€ ¬икторовна
ƒата создани€: 04/13/06
Author: Bakhtadze Natalya
Creation date: 04/13/06

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
    /*выполним действи€, разн€щиес€ дл€ разных типов касс -
    разные настройки в progress.ini - разные операции со spool-dir и т.д.*/
  IF FIRST-OF(ub.cash-desk.pos-type) then do:
    { str/cdg-gen.i
      &cd-buffer=ub.cash-desk
      &subject=tot-discnt
      &data-by=object
      &cdt-ibm=yes
      &cdt-ibm-xml=yes
      &cdt-ncr-as-r=yes
      &cdt-maria=yes
      }

    /*пройдем цикл по всем кассам одного типа*/
    RUN for-cash-cycle no-error.

  END. /*IF FIRST-OF(ub.cash-desk.pos-type*/

    /*выполним действи€, разн€щиес€ дл€ разных типов касс - подчистки, сообщени€ и т.д.*/

  IF LAST-OF(ub.cash-desk.pos-type) then do:
    { str/cds-gen.i
      &cd-buffer=ub.cash-desk
      &subject=tot-discnt
      &data-by=object
      &cdt-ibm=yes
      &cdt-ibm-xml=yes
      &cdt-ncr-as-r=yes
      &cdt-maria=yes
      &out-title="'ѕередача скидки на итог и/или правил скидок'"
      &out-title-add="'добавление скидки на итог и/или правил скидок'"
      &out-title-del="'удаление скидки на итог и/или правил скидок'"
      }
  END.
END. /*FOR EACH cash-desk*/

END PROCEDURE.
/* $Workfile$ e n d */