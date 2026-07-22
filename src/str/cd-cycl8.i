/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отсылка групп товаров - цикл по всем кассам одного типа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/16/06
Author: Bakhtadze Natalya
Creation date: 03/16/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE   for-cash-cycle:
DEFINE VARIABLE v-dir-remote as character no-undo .
DEFINE VARIABLE v-dir-remote-tmp as character no-undo .
define variable ss  as character no-undo .
define variable ss0  as character no-undo .
define variable v-temp-kat-file as character no-undo .
define variable v-kat-file as character no-undo .
define variable v-kat-file-save as character no-undo .
define variable v-updated-subject-dis-kat as logical no-undo .
define variable v-next as logical no-undo .
define variable v-cd-subject-code as character no-undo .
define variable v-cd-disc-string as character no-undo .

define buffer for-cash-desk for ub.cash-desk.
define buffer buf_cash-ncr-dis-kat for cash-ncr-dis-kat.


  FOR EACH for-cash-desk NO-LOCK WHERE
          for-cash-desk.pos-type = ub.cash-desk.pos-type AND
          for-cash-desk.db-num = g#db-num AND
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
    if p-subject = '':U then do:
    { str/outc-gen.i
      &cd-buffer=for-cash-desk
      &subject=sum-grp
      &data-by=object
      &out-title="''"
      &cdt-ibm=yes
      &cdt-ibm-xml=yes
      &cdt-ncr-AS-R=yes
      &cdt-maria=yes
      }

    end.
    else do:
    { str/outc-gen.i
      &cd-buffer=for-cash-desk
      &subject=sum-grp
      &data-by=object
      &out-title="''"
      &cdt-infokiosk=yes
      }
    end.
    /*сформируем вывод для кассы определенного типа*/
    RUN putc-8 ( buffer for-cash-desk
                ,input for-cash-desk.cash-num
                ,input for-cash-desk.pos-type ).
    /*закрываем поток*/
    if p-subject = '':u then do:
    { str/cloc-gen.i
      &cd-buffer=for-cash-desk
      &subject=sum-grp
      &data-by=object
      &out-title-add="substitute('&1: добавление', is-bo-name)"
      &out-title-del="substitute('&1: удаление', is-bo-name)"
      &cdt-ibm=yes
      &cdt-ibm-xml=yes
      &cdt-ncr-AS-R=yes
      &cdt-maria=yes
      }

    end.
    else do:
    { str/cloc-gen.i
      &cd-buffer=for-cash-desk
      &subject=sum-grp
      &data-by=object
      &out-title-add="substitute('&1: добавление', is-bo-name)"
      &out-title-del="substitute('&1: удаление', is-bo-name)"
      &cdt-infokiosk=yes
      }
     end.
   END . /*for each for-cash-desk*/
END PROCEDURE.

/* $Workfile$ e n d */