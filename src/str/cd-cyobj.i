/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отсылка объектов БД - цикл по всем кассам одного типа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/04/03
Author: Bakhtadze Natalya
Creation date: 12/04/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE   for-cash-cycle:
define buffer for-cash-desk for ub.cash-desk.
define variable v-first  as logical no-undo .
  FOR EACH for-cash-desk NO-LOCK WHERE
          for-cash-desk.db-num = g#db-num AND
          for-cash-desk.pos-type = ub.cash-desk.pos-type AND
          for-cash-desk.cash-on  = yes
    BREAK
    BY for-cash-desk.db-num
    BY for-cash-desk.pos-type
    BY for-cash-desk.cash-on
    :
    if ub.cash-desk.pos-type <> {&cd-type-IBM-XML} or
    for-cash-desk.autonomy <> integer({&cd-manager})
    or v-first
    then NEXT.
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
    &subject=db-object
    &out-title="'Пересылка данных по объектам БД'"
    &data-by=db
    &cdt-ibm-xml=yes
    }
    /*сформируем вывод для кассы определенного типа*/
    RUN putc-dept( for-cash-desk.pos-type ).
    /*закрываем поток*/
    { str/cloc-gen.i
    &cd-buffer=for-cash-desk
    &subject=db-object
    &out-title-add="'добавление данных по объектам БД'"
    &out-title-del="'удаление данных по объектам БД'"
    &data-by=db
    &cdt-ibm-xml=yes
    }
  END . /*for each for-cash-desk*/
END PROCEDURE.
/* $Workfile$ e n d */