/*

$Revision: 0c1a62f6cd43, 1415, test $
$Author: EShklyar $
$Date: Fri Jun 29 17:59:55 2018 +0300 $
$Workfile: cd-cycl6.i $
$Archive: str/cd-cycl6.i $

отсылка ксссиров - цикл по всем кассам одного типа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: cd-cycl6.i $ $Revision: 0c1a62f6cd43, 1415, test $".

PROCEDURE   for-cash-cycle:
DEFINE VARIABLE v-dir-remote as character no-undo .
DEFINE VARIABLE v-dir-remote-tmp as character no-undo .
define buffer for-cash-desk for ub.cash-desk.
define buffer buf_cash-desk-attr for ub.cash-desk-attr .

  FOR EACH for-cash-desk NO-LOCK WHERE
            for-cash-desk.db-num = g#db-num AND
            for-cash-desk.pos-type = ub.cash-desk.pos-type AND
            for-cash-desk.obj-code = i-obj-code AND
            for-cash-desk.cash-on  = yes:


    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Пересылка - касса &1", for-cash-desk.cash-num)
                                                      ).
    IF (LOOKUP(ub.cash-desk.pos-type,
              ({&cd-type-NCR-GM} + {&comma-char} +
               {&cd-type-IBM-XML} + {&comma-char} +
               {&cd-type-MAGIA-XML} + {&comma-char} +
               {&cd-type-NCR-AS-R} + {&comma-char} +
               {&cd-type-Autotank}
               )) > 0
     and for-cash-desk.autonomy = integer({&cd-slave})) then NEXT.

    /*открываем поток*/
    { str/outc-gen.i
      &cd-buffer=for-cash-desk
      &subject=cashier
      &data-by=object
      &out-title="''"
      &cdt-ibm=yes
      &cdt-ibm-xml=yes
      }
    /*сформируем вывод для кассы определенного типа*/
    RUN putc-6( for-cash-desk.pos-type ).
    /*закрываем поток*/
    { str/cloc-gen.i
      &cd-buffer=for-cash-desk
      &subject=cashier
      &data-by=object
      &out-title-add="'добавление кассиров'"
      &out-title-del="'удаление кассиров'"
      &cdt-ibm=yes
      &cdt-ibm-xml=yes
      }
  END . /*for each for-cash-desk*/
END PROCEDURE.

/* $Workfile: cd-cycl6.i $ e n d */