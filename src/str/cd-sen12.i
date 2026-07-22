/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отсылка категорий и ставок налогов на кассы - процедура отсылки

јвтор: Ѕахтадзе Ќаталь€ ¬икторовна
ƒата создани€: 02/15/06
Author: Bakhtadze Natalya
Creation date: 02/15/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE SENDING:
DEFINE VARIABLE fq as integer no-undo .
define variable glog as logical no-undo .

FOR EACH
    ub.cash-desk NO-LOCK WHERE
    ub.cash-desk.obj-code = i-obj-code AND
    ub.cash-desk.db-num = g#db-num AND
    ub.cash-desk.cash-on
BREAK
By ub.cash-desk.pos-type :
    /*выполним действи€, разн€щиес€ дл€ разных типов касс -
    разные настройки в progress.ini - разные операции со spool-dir и т.д.*/
  IF FIRST-OF(ub.cash-desk.pos-type) then do:
    { str/cdg-gen.i
    &cd-buffer=ub.cash-desk
    &subject=tax
    &data-by=object
    &cdt-ibm=yes
    &cdt-ibm-xml=yes
    &cdt-maria=yes
    }
    /*пройдем цикл по всем кассам одного типа*/
    RUN for-cash-cycle no-error.
  END. /*IF FIRST-OF(ub.cash-desk.pos-type*/

    /*выполним действи€, разн€щиес€ дл€ разных типов касс - подчистки, сообщени€ и т.д.*/

  IF LAST-OF(ub.cash-desk.pos-type) then do:
    { str/cds-gen.i
    &cd-buffer=ub.cash-desk
    &subject=tax
    &data-by=object
    &cdt-ibm=yes
    &cdt-ibm-xml=yes
    &cdt-maria=yes
    &out-title="'ѕередача категорий и ставок налогов'"
    &out-title-add="'добавление категорий и ставок налогов'"
    &out-title-del="'удаление категорий и ставок налогов'"
    }

  END.
END. /*FOR EACH cash-desk*/

END PROCEDURE.
/* $Workfile$ e n d */