/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отсылка продавцов - цикл по всем кассам одного типа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE   for-cash-cycle:
DEFINE VARIABLE fname-list as character no-undo .
DEFINE VARIABLE out-list as character no-undo .
DEFINE VARIABLE var-file-num as integer no-undo .
DEFINE VARIABLE v-dir-remote as character no-undo .
DEFINE VARIABLE v-dir-remote-tmp as character no-undo .
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
    &subject=seller
    &data-by=object
    &out-title="''"
    &cdt-ibm=yes
    &cdt-ibm-xml=yes
    &cdt-ipc-servispl=yes
    }
    /*сформируем вывод для кассы определенного типа*/
    RUN putc-3( for-cash-desk.pos-type ).
    /*закрываем поток*/
    { str/cloc-gen.i
    &cd-buffer=for-cash-desk
    &data-by=object
    &subject=seller
    &out-title-add="'добавление продавцов'"
    &out-title-del="'удаление продавцов'"
    &cdt-ibm=yes
    &cdt-ibm-xml=yes
    &cdt-ipc-servispl=yes
    }
  END . /*for each for-cash-desk*/
END PROCEDURE.
/* $Workfile$ e n d */