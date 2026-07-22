/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отсылка валют-оплат в МАГИЮ - цикл по всем кассам одного типа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/04/03
Author: Bakhtadze Natalya
Creation date: 12/04/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE   for-cash-cycle:
define buffer for-cash-desk for ub.cash-desk.
define buffer buf_shop for ub.shop.
define variable v-first as logical no-undo .
  FOR EACH for-cash-desk NO-LOCK WHERE
          for-cash-desk.db-num = g#db-num AND
          for-cash-desk.pos-type = ub.cash-desk.pos-type AND
          for-cash-desk.cash-on  = yes,
    FIRST buf_shop no-lock where
          buf_shop.obj-code = ub.cash-desk.obj-code
     AND  buf_shop.host-code = v-host-code

    BREAK
    BY for-cash-desk.db-num
    BY for-cash-desk.pos-type
    BY for-cash-desk.cash-on
    :
    if for-cash-desk.pos-type <> {&cd-type-MAGIA-XML}
    OR (LOOKUP(ub.cash-desk.pos-type,
              ({&cd-type-NCR-GM} + {&comma-char} +
               {&cd-type-IBM-XML} + {&comma-char} +
               {&cd-type-MAGIA-XML} + {&comma-char} +
               {&cd-type-NCR-AS-R}
               )) > 0
     and for-cash-desk.autonomy = integer({&cd-slave}))
     or v-first then next.

    assign
    v-first = yes
    .
    /*для виртуальных касс серверо - их много для каждого маг-на пошлется один раз*/
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Пересылка - касса &1", for-cash-desk.cash-num)
                                                      ).
    /*открываем поток*/
    { str/outc-gen.i
    &cd-buffer=for-cash-desk
    &subject=curr-pay
    &out-title="'Пересылка данных по валютам-оплатам'"
    &data-by=db
    &cdt-magia-xml=yes
    }
    /*сформируем вывод для кассы определенного типа*/
    RUN putc-curp( for-cash-desk.cash-num, for-cash-desk.pos-type ).
    /*закрываем поток*/
    { str/cloc-gen.i
    &cd-buffer=for-cash-desk
    &subject=curr-pay
    &out-title-add="'добавление данных по валютам-оплатам'"
    &out-title-del="'удаление данных по валютам-оплатам'"
    &data-by=db
    &cdt-magia-xml=yes
    }
  END . /*for each for-cash-desk*/
END PROCEDURE.
/* $Workfile$ e n d */