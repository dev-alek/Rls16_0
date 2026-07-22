/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отсылка дис карт - процедура отсылки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/28/05
Author: Bakhtadze Natalya
Creation date: 09/28/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE SENDING:
DEFINE VARIABLE fq as integer no-undo .
define variable glog as logical no-undo .

if can-find(first cash-desk No-LOCK WHERE
                  cash-desk.db-num = g#db-num and
                  cash-desk.obj-code = i-obj-code AND
                  cash-desk.cash-on = yes AND
                  cash-desk.pos-type = {&cd-type-MAGIA-XML}) then do:
  find first buf_dis-thbj-rule no-lock where
            buf_dis-thbj-rule.obj-type = ''
         and buf_dis-thbj-rule.obj-code = 0
         and buf_dis-thbj-rule.pos-type = {&cd-type-MAGIA-XML}
         and buf_dis-thbj-rule.discnt-role = {&dthbjr-kateg-codes} no-error .
  if available buf_dis-thbj-rule then do:
    v-magia-kat-codes-rule = buf_dis-thbj-rule.rule-num.
    run create-dis-rule in this-procedure ( input buf_dis-thbj-rule.rule-num, yes) no-error .
  end.
end.

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
    &subject=dis-card
    &cdt-ibm=yes
    &cdt-omron-new=yes
    &cdt-ipc-servispl=yes
    &cdt-ncr-gm=yes
    &cdt-magia-xml=yes
    &cdt-ibm-xml=yes
    &cdt-ncr-as-r=yes
    &cdt-r-keeper=yes
    &cdt-nkt-ibm=yes
    &out-title="'Пересылка дисконтных карт'"
    &out-title-add="'добавление дисконтных карт'"
    &out-title-del="'удаление дисконтных карт'"
    }
    /*пройдем цикл по всем кассам одного типа*/
    RUN for-cash-cycle no-error.
  END. /*IF FIRST-OF(ub.cash-desk.pos-type*/

    /*выполним действия, разнящиеся для разных типов касс - подчистки, сообщения и т.д.*/

  IF LAST-OF(ub.cash-desk.pos-type) then do:
    { str/cds-gen.i
    &cd-buffer=ub.cash-desk
    &subject=dis-card
    &cdt-ibm=yes
    &cdt-omron-new=yes
    &cdt-ipc-servispl=yes
    &cdt-ncr-gm=yes
    &cdt-magia-xml=yes
    &cdt-ibm-xml=yes
    &cdt-ncr-as-r=yes
    &cdt-r-keeper=yes
    &cdt-nkt-ibm=yes
    &out-title="'Пересылка дисконтных карт'"
    &out-title-add="'добавление дисконтных карт'"
    &out-title-del="'удаление дисконтных карт'"
    }
  END.
END. /*FOR EACH cash-desk*/

END PROCEDURE.
/* $Workfile$ e n d */