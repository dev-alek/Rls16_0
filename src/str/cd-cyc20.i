/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отсылка типов дис карт - цикл по всем кассам одного типа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/04/03
Author: Bakhtadze Natalya
Creation date: 12/04/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE   for-cash-cycle:
DEFINE VARIABLE v-dir-remote as character no-undo .
DEFINE VARIABLE v-dir-remote-tmp as character no-undo .
define variable v-version-dec as decimal no-undo .

define buffer for-cash-desk for ub.cash-desk.
_for-cash-desk:
  FOR EACH for-cash-desk NO-LOCK WHERE
          for-cash-desk.db-num = g#db-num AND
          for-cash-desk.obj-code = ub.cash-desk.obj-code AND
          for-cash-desk.pos-type = ub.cash-desk.pos-type AND
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
    &subject=dis-card-mask
    &out-title="'Пересылка данных по типам-маскам карт'"
    &data-by=object
    &cdt-ibm=yes
    &cdt-ibm-xml=yes
    }
    /*сформируем вывод для кассы определенного типа*/
    assign
    v-version-dec = decimal(for-cash-desk.version) no-error .
    if v-version-dec < 4.4
    and for-cash-desk.pos-type = {&cd-type-ibm} then do:
      run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Для пересылки на кассу типа &1 версия ПО кассы должна быть > 4.4, а у кассы &2 - версия ПО &3"
                          , for-cash-desk.pos-type
                          , for-cash-desk.cash-num
                          , for-cash-desk.version
                          )
                                                    ).
      assign
      v-view-log = yes.
      next _for-cash-desk.
    end.

    RUN putc-dis-card-mask ( buffer for-cash-desk
                            ,input for-cash-desk.pos-type
                            ,input for-cash-desk.version ).
    /*закрываем поток*/
    { str/cloc-gen.i
    &cd-buffer=for-cash-desk
    &subject=depart
    &out-title-add="'добавление данных по типам-маскам карт'"
    &out-title-del="'удаление данных по типам-маскам карт'"
    &data-by=object
    &cdt-ibm=yes
    &cdt-ibm-xml=yes
    }
  END . /*for each for-cash-desk*/
END PROCEDURE.
/* $Workfile$ e n d */