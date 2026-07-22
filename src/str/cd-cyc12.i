/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отсылка категорий и ставок налогов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/15/06
Author: Bakhtadze Natalya
Creation date: 02/15/06


*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE   for-cash-cycle:
DEFINE VARIABLE v-dir-remote as character no-undo .
DEFINE VARIABLE v-dir-remote-tmp as character no-undo .
define buffer for-cash-desk for ub.cash-desk.

FOR EACH for-cash-desk NO-LOCK WHERE
        for-cash-desk.db-num = g#db-num AND
        for-cash-desk.pos-type = ub.cash-desk.pos-type AND
        for-cash-desk.obj-code = i-obj-code AND
        for-cash-desk.cash-on  = yes:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Пересылка - касса &1", for-cash-desk.cash-num
                        )
                                        ).
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
  and for-cash-desk.autonomy = integer({&cd-manager}) then do:
    assign
    v-cd-list-update = for-cash-desk.addr-path
    v-cd-list-delete = for-cash-desk.addr-path
    .
    NEXT.
  end.
  /*открываем поток*/
    { str/outc-gen.i
    &cd-buffer=for-cash-desk
    &subject=tax
    &data-by=object
    &out-title="''"
    &cdt-ibm=yes
    &cdt-ibm-xml=yes
    &cdt-magia-XML=yes
    &cdt-maria=yes
    }

  /*сформируем вывод для кассы определенного типа*/
  FOR EACH cash-txn NO-LOCK:
      RUN putc-12 in this-procedure ( buffer for-cash-desk
                  ,input for-cash-desk.pos-type
                  ,input for-cash-desk.cash-os ).
  end.
  run putc-15 in this-procedure (
                                  input for-cash-desk.pos-type
                                 ,input for-cash-desk.cash-os).
  /*закрываем поток*/
  { str/cloc-gen.i
  &cd-buffer=for-cash-desk
  &subject=tax
  &data-by=object
  &out-title-add="'добавление категорий и ставок налогов'"
  &out-title-del="'удаление категорий и ставок налогов'"
  &cdt-ibm=yes
  &cdt-ibm-xml=yes
  &cdt-magia-XML=yes
  &cdt-maria=yes
  }
END . /*for each for-cash-desk*/
END PROCEDURE.
/* $Workfile$ e n d */