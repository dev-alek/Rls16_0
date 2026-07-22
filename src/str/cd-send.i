/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отсылка товаров на кассы - процедура отсылки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/06/06
Author: Bakhtadze Natalya
Creation date: 01/06/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE SENDING:
DEFINE VARIABLE fq as integer no-undo .
define variable glog as logical no-undo .
define variable vdr-26 as integer no-undo .
define variable vc-obj-type like ub.clients.obj-type no-undo .
define variable vc-obj-code like ub.clients.obj-code no-undo .
define variable vc-host-code like ub.sysconf.host-code no-undo .
define variable vc-region as character no-undo .

_cash-desk:
FOR EACH ub.cash-desk NO-LOCK WHERE
         ub.cash-desk.db-num = g#db-num AND
         ub.cash-desk.obj-code = i-obj-code AND
        ub.cash-desk.cash-on
BREAK
By ub.cash-desk.pos-type :
  /*выполним действия, разнящиеся для разных типов касс -
  разные настройки в progress.ini - разные операции со spool-dir и т.д.*/
  IF FIRST-OF(ub.cash-desk.pos-type) then do:
    &if "{&called}" = "send-gds" &then
    if lookup({&cd-type-infokiosk} + '-only', p-other) > 0
    and ub.cash-desk.pos-type <> {&cd-type-infokiosk} then do:
      next _cash-desk.
    end.
    if lookup({&cd-type-pricecheck-Servispl} , p-other) > 0
    and ub.cash-desk.pos-type <> {&cd-type-pricecheck-Servispl} then do:
      next _cash-desk.
    end.
    &endif

    { str/cdg-gen.i
    &cd-buffer=ub.cash-desk
    &subject=good
    &data-by=object
    &cdt-ibm=yes
    &cdt-ibm-xml=yes
    &cdt-magia-xml=yes
    &cdt-omron-new=yes
    &cdt-ipc-servispl=yes
    &cdt-ncr-gm=yes
    &cdt-ncr-as-r=yes
    &cdt-infokiosk=yes
    &cdt-pricecheck-Servispl=yes
    &cdt-maria=yes
    &cdt-autotank=yes
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
    &if "{&called}" = "send-gds" &then
    if lookup({&cd-type-infokiosk} + '-only', p-other) > 0
    and ub.cash-desk.pos-type <> {&cd-type-infokiosk} then do:
      next _cash-desk.
    end.
    if lookup({&cd-type-pricecheck-Servispl} , p-other ) > 0
    and ub.cash-desk.pos-type <> {&cd-type-pricecheck-Servispl} then do:
      next _cash-desk.
    end.
    &endif
    { str/cds-gen.i
    &cd-buffer=ub.cash-desk
    &subject=good
    &data-by=object
    &cdt-ibm=yes
    &cdt-ibm-xml=yes
    &cdt-magia-xml=yes
    &cdt-omron-new=yes
    &cdt-ipc-servispl=yes
    &cdt-ncr-gm=yes
    &cdt-ncr-as-r=yes
    &cdt-infokiosk=yes
    &cdt-pricecheck-Servispl=yes
    &cdt-maria=yes
    &cdt-autotank=yes
    &out-title="'Передача товаров'"
    &out-title-add="'добавление товаров'"
    &out-title-del="'удаление товаров'"
    }
  END.
END. /*FOR EACH cash-desk*/

END PROCEDURE.
/* $Workfile$ e n d */