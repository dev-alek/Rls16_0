/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функция обратного нормального распределени

Автор: Чернова Светлана Александровна
Дата создания: 02/27/07
Author: Svetlana Chernova
Creation date: 02/27/07

create: Перваков Михаил Сергеевич
Дата создания: 12/03/02

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure normobr_invers-erf :

  define input  parameter p-x     as decimal   no-undo .
  define output parameter p-value as decimal   no-undo .

  define variable vss-description as character no-undo init "normobr_invers-erf-01: Обратная функция Erf".

  do
  on error undo, return error return-value
  :
    if p-x = ?
    or p-x > 1
    or p-x < -1
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Ошибка задания входных параметров" skip
        "p-x" p-x skip
        view-as alert-box error .
      undo, return error .
    end.

    define variable p-x-power2  as decimal   no-undo .
    define variable p-x-power4  as decimal   no-undo .
    define variable p-x-power8  as decimal   no-undo .
    define variable p-x-power16 as decimal   no-undo .
    assign
      p-x-power2  = p-x * p-x
      p-x-power4  = p-x-power2 * p-x-power2
      p-x-power8  = p-x-power4 * p-x-power4
      p-x-power16 = p-x-power8 * p-x-power8
    .

    /* делаем вычисление с более высокой точностью */
    assign
      p-value = 08862269254.5275790 * p-x
              + 02320136665.3465444 * p-x * p-x-power2
              + 01275561753.0559793 * p-x * p-x-power4
              + 00865521292.4154752 * p-x * p-x-power2 * p-x-power4
              + 00649596177.4538540 * p-x * p-x-power8
              + 00517312819.8461636 * p-x * p-x-power2 * p-x-power8
              + 00428367206.5179733 * p-x * p-x-power4 * p-x-power8
              + 00364659293.0853162 * p-x * p-x-power2 * p-x-power4 * p-x-power8
              + 00316890050.2160544 * p-x * p-x-power16
              + 00279806329.6499521 * p-x * p-x-power2 * p-x-power16
              + 00250222758.4119834 * p-x * p-x-power4 * p-x-power16
              + 00226098633.1889757 * p-x * p-x-power2 * p-x-power4 * p-x-power16
              + 00206067803.7905899 * p-x * p-x-power8 * p-x-power16
    .
    /* производим нормирование значения функции */
    assign
      p-value = p-value / 10000000000
    .
  end.

end procedure. /* normobr_invers-erf */


procedure normobr :

  define input  parameter p-p     as decimal   no-undo .
  define input  parameter p-m     as decimal   no-undo .
  define input  parameter p-sigma as decimal   no-undo .
  define output parameter p-x     as decimal   no-undo .

  define variable vss-description as character no-undo init "normobr-01: Обратная функция нормального распределения".

  do
  on error undo, return error return-value
  :

    if p-p > 1
    or p-p < 0
    or p-p = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Ошибка задания входных параметров" skip
        "Неверные значения парметра p-p  " skip
        "Он не может быть больше нуля и меньше единицы" skip
        "p-p (- уровень постоянного присутствия)              " p-p skip
        "p-m (Темп продаж )                                   " p-m skip
        "p-sigma (среднеквадратичное отклонение Темпа продаж) " p-sigma skip
        view-as alert-box error .
      undo, return error .
    end.

    if p-m = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Ошибка задания входных параметров" skip
        "Не задано значение парметра p-m" skip
        "p-p (- уровень постоянного присутствия)              " p-p skip
        "p-m (Темп продаж )                                   " p-m skip
        "p-sigma (среднеквадратичное отклонение Темпа продаж) " p-sigma skip

        view-as alert-box error .
      undo, return error .
    end.

    if p-sigma = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Ошибка задания входных параметров" skip
        "Не задано значение парметра p-sigma" skip
        "p-p (- уровень постоянного присутствия)              " p-p skip
        "p-m (Темп продаж )                                   " p-m skip
        "p-sigma (среднеквадратичное отклонение Темпа продаж) " p-sigma skip

        view-as alert-box error .
      undo, return error .
    end.


    define variable v-inverse-erf as decimal   no-undo .
    run normobr_invers-erf in this-procedure
      (input  1 - 2 * p-p
      ,output v-inverse-erf
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове функции normobr_invers-erf" skip
        "p-p (- уровень постоянного присутствия)              " p-p skip
        "p-m (Темп продаж )                                   " p-m skip
        "p-sigma (среднеквадратичное отклонение Темпа продаж) " p-sigma skip

        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    assign
      p-x = p-m - 1.4142135623730950488 * p-Sigma * v-inverse-erf
    .
  end.

end procedure. /* normobr */


procedure normobr_test :

  do
  on error undo, return error return-value
  :
    define variable v-test as decimal no-undo .

    /* =НОРМОБР(0,85; 2; 1,528) = 3.58366944 */
    run normobr in this-procedure
      (input .85
      ,input 2
      ,input 1.528
      ,output v-test
      ) .
    message
      "НОРМОБР(0,85; 2; 1,528) = 3.58366944" skip
      "normobr" v-test skip
      view-as alert-box .


    /*  =НОРМОБР(0,75; 8,267; 1,745) = 9.44398569 */
    run normobr in this-procedure
      (input .75
      ,input 8.267
      ,input 1.745
      ,output v-test
      ) .
    message
      "НОРМОБР(0,75; 8,267; 1,745) = 9.44398569" skip
      "normobr" v-test skip
      view-as alert-box .

    run normobr in this-procedure
      (input .5
      ,input 10
      ,input 1.745
      ,output v-test
      ) .
    message
      "НОРМОБР(0,5; 10; 1,745) = 10" skip
      "normobr" v-test skip
      view-as alert-box .

    run normobr in this-procedure
      (input .05
      ,input 10
      ,input 1.745
      ,output v-test
      ) .
    message
      "НОРМОБР(0,05; 10; 1,745) = 7.12973151" skip
      "normobr" v-test skip
      view-as alert-box .


  end.

end procedure. /* normobr_test */


/* $Workfile$ */