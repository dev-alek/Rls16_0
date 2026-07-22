/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отсылка групп товаров на кассы - процедура отсылки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/16/06
Author: Bakhtadze Natalya
Creation date: 03/16/06

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
      if lookup(p-subject, "group-BO,units,grp-prt,country") > 0
      and ub.cash-desk.pos-type <> {&cd-type-infokiosk} then NEXT.
      if p-subject = '':u then do:
      { str/cdg-gen.i
        &cd-buffer=ub.cash-desk
        &subject=sum-grp
        &cdt-ibm=yes
        &cdt-ibm-xml=yes
        &cdt-ncr-AS-R=yes
        &cdt-maria=yes
        }
      end.
      else do:
      { str/cdg-gen.i
        &cd-buffer=ub.cash-desk
        &subject=sum-grp
        &cdt-infokiosk=yes
        }

       end.
      /*пройдем цикл по всем кассам одного типа*/
      RUN for-cash-cycle in this-procedure no-error.

    END. /*IF FIRST-OF(ub.cash-desk.pos-type*/

    /*выполним действия, разнящиеся для разных типов касс - подчистки, сообщения и т.д.*/

    IF LAST-OF(ub.cash-desk.pos-type) then do:
      if p-subject = '':U then do:
      { str/cds-gen.i
        &cd-buffer=ub.cash-desk
        &subject=sum-grp
        &cdt-ibm=yes
        &cdt-ibm-xml=yes
        &cdt-ncr-AS-R=yes
        &cdt-maria=yes
        &out-title="substitute('Передача: &1', is-bo-name)"
        &out-title-add="substitute('&1: добавление', is-bo-name)"
        &out-title-del="substitute('&1: удаление', is-bo-name)"
        }
      end.
      else do:
      { str/cds-gen.i
        &cd-buffer=ub.cash-desk
        &subject=sum-grp
        &cdt-infokiosk=yes
        &out-title="substitute('Передача: &1', is-bo-name)"
        &out-title-add="substitute('&1: добавление', is-bo-name)"
        &out-title-del="substitute('&1: удаление', is-bo-name)"
        }

      end.
    END.
END. /*FOR EACH cash-desk*/

END PROCEDURE.
/* $Workfile$ e n d */