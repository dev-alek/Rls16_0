/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Заполнение временной таблицы отчета

Автор: Хныкин Павел Андреевич
Дата создания: 01/19/06
Author: Pavel Khnykin
Creation date: 01/19/06

{1} - таблица товаров

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/* разбираем товары по объектам */
for each obj-list no-lock,
    each {1} no-lock,
    first ub.gds-obj no-lock
      where ub.gds-obj.obj-type  = obj-list.obj-type
        and ub.gds-obj.obj-code  = obj-list.obj-code
        and ub.gds-obj.artic     = {1}.artic
        and ub.gds-obj.prod-type = {1}.prod-type
        and ub.gds-obj.prod-code = {1}.prod-code
    break by obj-list.obj-code
          by obj-list.obj-type
:
  assign
    counter = counter + 1
  .
  if v-obj-code <> obj-list.obj-code then do:

    assign
      v-obj-code = obj-list.obj-code
    .
    run waitfram-show in this-procedure ( "Расчет по объекту " + obj-list.obj-name + " (" + string( obj-list.obj-code ) + ")" ).
  end.
  /* определяем текущую дату на объекте и получаем табличку свободных партий*/
  { gbl/curobjdt.i obj-list.obj-type obj-list.obj-code vardate}
  if ( x-Date-Alone >= vardate) then do:
    run partslib-init-temp-parts in this-procedure(
                                               input obj-list.obj-type,
                                               input obj-list.obj-code,
                                               input {1}.artic,
                                               input {1}.prod-type,
                                               input {1}.prod-code
                                                  ).
  end. /* vardate >= x-Date-Alone */
  else do:
    run factord in this-procedure
      (input  x-Date-Alone            /* p-fact-date            */
      ,input  1                       /* p-fact-time            */
      ,input  1                       /* p-fact-num             */
      ,input  ?                       /* p-shift-date           */
      ,input  0                       /* p-shift-num            */
      ,input  false                   /* p-shift-on             */
      ,output v-end-fact-order        /* p-fact-order           */
      ,output v-shift-end-fact-order  /* p-shift-end-fact-order */
      ,output v-day-end-fact-order      /* p-day-end-fact-order   */
      ) no-error .
    if error-status:error then do:
      message error-status :get-message(1) view-as alert-box error .
      return error.
    end.
    run partslib-init-temp-parts-by-factord in this-procedure(
                                                          input obj-list.obj-type,
                                                          input obj-list.obj-code,
                                                          input {1}.artic,
                                                          input {1}.prod-type,
                                                          input {1}.prod-code,
                                                          input v-day-end-fact-order,
                                                          input false
                                                          ) no-error .
    if error-status :error then do:
      message error-status :get-message(1) view-as alert-box error .
    end.
  end. /* vardate < x-Date-Alone */
  /* заполняем нашу табличку  */
  for each temp-parts no-lock :

    run alc-lib_mark-name in this-procedure
      (
          input temp-parts.mark-db-num
        , input temp-parts.mark-code
        , output v-alc-mark-code

      ) no-error .

    create temp-str.
    assign
      temp-str.artic      = temp-parts.artic
      temp-str.part-code  = temp-parts.part-code
      temp-str.obj-code   = obj-list.obj-code
      temp-str.obj-type   = obj-list.obj-type
      temp-str.gds-name   = {1}.gds-name
      temp-str.fact-qnty  = temp-parts.fact-qnty
      temp-str.ms-base    = {1}.ms-base
      temp-str.out-date   = temp-parts.alc-bottling-date
      temp-str.mark-code  = v-alc-mark-code
      temp-str.prod-code  = temp-parts.prod-code
      temp-str.prod-type  = temp-parts.prod-type
      temp-str.in-code    = temp-parts.in-code
      temp-str.out-code   = temp-parts.out-code
      temp-str.fact-date  = temp-parts.fact-date
    no-error.
    if obj-list.obj-type = {&stock} then do:
      assign
        temp-str.list-doc   = ""
        temp-str.list-date  = ""
      .
    end.
    else do: /* если объект не склад, то ищем все внутренние перемещения или внешний приход этой партии*/
      run find-docs in this-procedure ( output v-list-doc , output v-list-date , output v-ext-type).
      if v-list-doc = "" then do:
      assign
        temp-str.list-doc   = ""
        temp-str.list-date  = ""
        temp-str.in-code    = temp-parts.in-code
        temp-str.fact-date  = temp-parts.fact-date
      .
      end.
      else do:
        assign
          temp-str.list-doc   = v-list-doc
          temp-str.list-date  = v-list-date
          temp-str.ext-type   = v-ext-type
        .
      end.
    end.
  end. /* for each temp-parts */
end.
run waitfram-hide in this-procedure.
/* $Workfile$ e n d */