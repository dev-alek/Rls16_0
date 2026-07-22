/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отсылка промоакций - цикл по всем кассам одного типа

Автор: Шкляр Елена
Дата создания: 09/20/05
Author: Shklyar Elena
Creation date: 09/20/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE   for-cash-cycle:
   DEFINE VARIABLE v-dir-remote     as character no-undo .
   DEFINE VARIABLE v-dir-remote-tmp as character no-undo .
   define buffer for-cash-desk for ub.cash-desk.

   FOR EACH for-cash-desk NO-LOCK WHERE
      for-cash-desk.db-num = g#db-num AND
      for-cash-desk.pos-type = {&cd-type-IBM-XML} AND
      for-cash-desk.obj-code = i-obj-code AND
      for-cash-desk.cash-on  = yes:

/*      IF (LOOKUP(ub.cash-desk.pos-type,{&cd-type-IBM-XML}) > 0        */
/*         and for-cash-desk.autonomy = integer({&cd-slave})) then NEXT.*/



    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Пересылка - касса &1", for-cash-desk.cash-num)
                                                      ).
    /*открываем поток*/
    { str/outc-gen.i
      &cd-buffer=for-cash-desk
      &subject=pay
      &data-by=object
      &out-title="''"
      &cdt-ibm=no
      &cdt-ibm-xml=yes
      &cdt-maria=no
      }
      /*сформируем вывод для кассы определенного типа*/
      RUN putc-16 in this-procedure (buffer for-cash-desk
         ,input for-cash-desk.cash-num
         ,input for-cash-desk.version
         ).

      /*закрываем поток*/
    { str/cloc-gen.i
      &cd-buffer=for-cash-desk
      &subject=pay
      &data-by=object
      &out-title-add="'добавление промоакций '"
      &out-title-del="'удаление промоакций '"
      &cdt-ibm=no
      &cdt-ibm-xml=yes
      &cdt-maria=no
      }

         { str/putc-mes16.i }

END . /*for each for-cash-desk*/
END PROCEDURE.

/* $Workfile$ e n d */