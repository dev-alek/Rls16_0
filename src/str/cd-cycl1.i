/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отсылка курсов валют - цикл по всем кассам одного типа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/28/05
Author: Bakhtadze Natalya
Creation date: 09/28/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE   for-cash-cycle:
DEFINE VARIABLE fname-list as character no-undo .
DEFINE VARIABLE out-list as character no-undo .
DEFINE VARIABLE var-file-num as integer no-undo .
DEFINE VARIABLE v-dir-remote as character no-undo .
DEFINE VARIABLE v-dir-remote-tmp as character no-undo .
define variable v-versiond as decimal no-undo .

define buffer for-cash-desk for ub.cash-desk.


 FOR EACH for-cash-desk NO-LOCK WHERE
          for-cash-desk.db-num = g#db-num AND
          for-cash-desk.pos-type = ub.cash-desk.pos-type AND
          for-cash-desk.obj-code = i-obj-code AND
          for-cash-desk.cash-on  = yes
    BREAK
    BY for-cash-desk.db-num
    BY for-cash-desk.obj-code
    BY for-cash-desk.pos-type
    BY for-cash-desk.cash-on
    :
    IF (LOOKUP(ub.cash-desk.pos-type,
              ({&cd-type-NCR-GM} + {&comma-char} +
               {&cd-type-IBM-XML} + {&comma-char} +
               {&cd-type-MAGIA-XML} + {&comma-char} +
               {&cd-type-NCR-AS-R}
               )) > 0
     and for-cash-desk.autonomy = integer({&cd-slave})) then NEXT.


    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Пересылка - касса &1", for-cash-desk.cash-num)
                                                      ).
    /*открываем поток*/
    { str/outc-gen.i
    &cd-buffer=for-cash-desk
    &data-by=object
    &subject=currency
    &out-title="''"
    &cdt-ibm=yes
    &cdt-ibm-xml=yes
    &cdt-omron=yes
    &cdt-omron-new=yes
    &cdt-ipc-servispl=yes
    &cdt-nkt-ibm=yes
    }
    /*сформируем вывод для кассы определенного типа*/
    RUN putc-1( input for-cash-desk.pos-type, input for-cash-desk.version ).
    if not return-value = "error" then do:
      /*закрываем поток*/
      { str/cloc-gen.i
      &cd-buffer=for-cash-desk
      &subject=currency
      &out-title-add="'добавление курсов валют'"
      &out-title-del="'удаление курсов валют'"
      &cdt-ibm=yes
      &cdt-ibm-xml=yes
      &cdt-omron=yes
      &cdt-omron-new=yes
      &cdt-ipc-servispl=yes
      &cdt-nkt-ibm=yes
      }
    end.
  END . /*for each for-cash-desk*/
END PROCEDURE.
/* $Workfile$ e n d */