/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отсылка скидки на итог

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE   for-cash-cycle:
DEFINE VARIABLE v-dir-remote as character no-undo .
DEFINE VARIABLE v-dir-remote-tmp as character no-undo .
define variable v-plu as character no-undo .
define variable ss  as character no-undo .
define variable ss0  as character no-undo .
define variable v-temp-kat-file as character no-undo .
define variable v-kat-file as character no-undo .
define variable v-updated-subject-dis-kat as logical no-undo .
define variable v-kat-file-save as character no-undo .
define variable v-next as logical no-undo .
define variable v-cd-subject-code as character no-undo .
define variable v-cd-disc-string as character no-undo .

define buffer for-cash-desk for ub.cash-desk.
define buffer buf_cash-ncr-dis-kat for cash-ncr-dis-kat.


  FOR EACH for-cash-desk NO-LOCK WHERE
          for-cash-desk.db-num = g#db-num AND
          for-cash-desk.pos-type = ub.cash-desk.pos-type AND
          for-cash-desk.obj-code = i-obj-code AND
          for-cash-desk.cash-on  = yes:

    IF (LOOKUP(ub.cash-desk.pos-type,
              ({&cd-type-NCR-GM} + {&comma-char} +
               {&cd-type-IBM-XML} + {&comma-char} +
               {&cd-type-MAGIA-XML} + {&comma-char} +
               {&cd-type-NCR-AS-R}
                 )) > 0
     and for-cash-desk.autonomy = integer({&cd-slave})) then NEXT.

   if LOOKUP(ub.cash-desk.pos-type,
            {&cd-type-maria}
               ) > 0
    and for-cash-desk.autonomy = integer({&cd-manager}) then next.


    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Пересылка - касса &1", for-cash-desk.cash-num)
                                                      ).

    /*открываем поток*/
    { str/outc-gen.i
      &cd-buffer=for-cash-desk
      &subject=tot-discnt
      &data-by=object
      &out-title="''"
      &cdt-ibm=yes
      &cdt-ibm-xml=yes
      &cdt-ncr-as-r=yes
      &cdt-maria=yes
      }
    /*сформируем вывод для кассы определенного типа*/
    if p-what-send = 'all':U
    or p-what-send = 'tot-discnt':U then do:
      RUN putc-9 in this-procedure
                  (  buffer for-cash-desk
                    ,input for-cash-desk.cash-num
                    ,input for-cash-desk.pos-type ).
      RUN putctodr in this-procedure
                  (  buffer for-cash-desk
                    ,input for-cash-desk.cash-num
                    ,input for-cash-desk.pos-type ).
    end.
    if p-what-send = 'all':U
    or p-what-send = 'gds':U then do:
      RUN putcgddr in this-procedure
                  (  buffer for-cash-desk
                    ,input for-cash-desk.cash-num
                    ,input for-cash-desk.pos-type ).
    end.
    if p-what-send = 'all':U
    or p-what-send = 'group':U then do:
      RUN putcgrdr in this-procedure
                  (  buffer for-cash-desk
                    ,input for-cash-desk.cash-num
                    ,input for-cash-desk.pos-type ).
    end.
    if p-what-send = 'all':U
    or p-what-send = 'payment':U then do:
      RUN putcpmdr in this-procedure
                  (  buffer for-cash-desk
                    ,input for-cash-desk.cash-num
                    ,input for-cash-desk.pos-type ).
    end.
    if p-what-send = 'all':U
    or p-what-send = 'client':U then do:
      RUN putccldr in this-procedure
                  (  buffer for-cash-desk
                    ,input for-cash-desk.cash-num
                    ,input for-cash-desk.pos-type ).
    end.

    /*закрываем поток*/
    { str/cloc-gen.i
      &cd-buffer=for-cash-desk
      &subject=tot-discnt
      &data-by=object
      &out-title-add="'добавление скидки на итог и/или правил скидок'"
      &out-title-del="'удаление скидки на итог и/или правил скидок'"
      &cdt-ibm=yes
      &cdt-ibm-xml=yes
      &cdt-ncr-as-r=yes
      &cdt-maria=yes
      }
   END . /*for each for-cash-desk*/
END PROCEDURE.
/* $Workfile$ e n d */