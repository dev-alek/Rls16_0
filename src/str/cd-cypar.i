/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отсылка параметров на кассы - цикл по всем кассам одного типа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/05/05
Author: Bakhtadze Natalya
Creation date: 12/05/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE   for-cash-cycle:
DEFINE VARIABLE fname-list as character no-undo .
DEFINE VARIABLE out-list as character no-undo .
DEFINE VARIABLE var-file-num as integer no-undo .
DEFINE VARIABLE v-dir-remote as character no-undo .
DEFINE VARIABLE v-dir-remote-tmp as character no-undo .
define variable v-plu as character no-undo .
define variable ss  as character no-undo .
define variable ss0  as character no-undo .
define variable v-temp-kat-file as character no-undo .
define variable v-kat-file as character no-undo .
define variable v-kat-file-save as character no-undo .
define variable v-updated-subject-dis-kat as logical no-undo .
define variable v-next as logical no-undo .
define variable v-cd-subject-code as character no-undo .
define variable v-cd-disc-string as character no-undo .
define variable v-versiond as decimal no-undo .


define buffer for-cash-desk for ub.cash-desk.
define buffer buf_cd-plu for ub.cd-plu.
define buffer buf_cash-ncr-dis-kat for cash-ncr-dis-kat.

FOR EACH for-cash-desk NO-LOCK WHERE
        for-cash-desk.db-num = p-db-num AND
        for-cash-desk.pos-type = p-pos-type AND
        for-cash-desk.obj-code = p-obj-code AND
        for-cash-desk.cash-on  = yes AND
        (p-cash-num = ? or
        for-cash-desk.cash-num = p-cash-num)
    BREAK
    BY for-cash-desk.db-num
    BY for-cash-desk.obj-code
    BY for-cash-desk.pos-type
    BY for-cash-desk.cash-on
    :
  if LOOKUP(ub.cash-desk.pos-type,
            ({&cd-type-NCR-GM} + {&comma-char} +
             {&cd-type-IBM-XML} + {&comma-char} +
             {&cd-type-MAGIA-XML} + {&comma-char} +
             {&cd-type-NCR-AS-R}
               )) > 0
  and for-cash-desk.autonomy = integer({&cd-slave}) then NEXT.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Пересылка - касса &1", for-cash-desk.cash-num
                        )
                                        ).
  { str/outc-gen.i
  &cd-buffer=for-cash-desk
  &subject=parameters
  &out-title="'Пересылка параметров'"
  &data-by=object
  &cdt-ncr-gm=yes
  &cdt-ncr-AS-R=yes
  &cdt-maria=yes
  &cdt-IBM-XML=yes
  }
  /*сформируем вывод для кассы определенного типа*/
  RUN putc-par in this-procedure
               ( buffer for-cash-desk
                ,input for-cash-desk.pos-type
                ,input for-cash-desk.version
                ,input for-cash-desk.cash-os
                ,input for-cash-desk.cash-num
                ).
  { str/cloc-gen.i
  &cd-buffer=for-cash-desk
  &subject=parameters
  &out-title-add="'добавление/изменение параметров'"
  &out-title-del="'удаление параметров'"
  &data-by=object
  &cdt-ncr-gm=yes
  &cdt-ncr-AS-R=yes
  &cdt-maria=yes
  &cdt-IBM-XML=yes
  }
END . /*for each for-cash-desk*/
END PROCEDURE.

/* $Workfile$ e n d */