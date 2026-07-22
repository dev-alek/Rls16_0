/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Кусок печати  отчета по покупателям товаров (выкуп)

Автор: Демин Алексей Сергеевич
Дата создания: 03/24/06
Author: Alexey Demin
Creation date: 03/24/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

  for each buy-data by {&by-if} :
    assign
      is-name = yes
      Counter1 = 0
    .
    for each buy-data-dt
      where buy-data-dt.obj-type = buy-data.obj-type
        and buy-data-dt.obj-code = buy-data.obj-code
      :
      display stream PrnLibStream
            sym1 string( buy-data.obj-code ) when (is-name = yes) @ cliregcode
            sym2 buy-data.name               when (is-name = yes) @ cliregname
            sym3 string( string( month(buy-data-dt.cur-date1) ) + "/" + string( year((buy-data-dt.cur-date1)) ) ) @ m-y
            sym4 buy-data-dt.sum-zak         when whatshow:screen-value <> "Только продажные" @ sum-zak
            sym5 buy-data-dt.sum-prod        when whatshow:screen-value <> "Только учетные"   @ sum-prod
/*            sym4 (buy-data-dt.sum-prod + buy-data-dt.sum-skid)  when whatshow:screen-value <> "Только учетные"   @ sum-prod*/
            sym6 buy-data-dt.sum-skid        when whatshow:screen-value <> "Только учетные"   @ sum-skid
            sym7 buy-data-dt.EffValue        when whatshow:screen-value = {&all}              @ effvalue
         /*   sym8  */   with frame firm-salerpt .
         down stream PrnLibStream 1 with frame firm-salerpt .
      if is-name = yes then assign is-name = no .
      assign Counter1 = Counter1 + 1 .
    end.
    if onemonth = no and Counter1 > 1 then do:
      underline stream PrnLibStream cliregname sum-zak sum-prod sum-skid effvalue with frame firm-salerpt .
      display stream PrnLibStream
        sym1 "ИТОГО" @ cliregname
        buy-data.sum-zak  when whatshow:screen-value <> "Только продажные"  @ sum-zak
        buy-data.sum-prod when whatshow:screen-value <> "Только учетные"    @ sum-prod
        buy-data.sum-skid when whatshow:screen-value <> "Только учетные"    @ sum-skid
        buy-data.EffValue when whatshow:screen-value = {&all}               @ effvalue
        sym4     with frame firm-salerpt .
      down stream PrnLibStream 1 with frame firm-salerpt .
      underline stream PrnLibStream cliregname sum-zak sum-prod sum-skid effvalue with frame firm-salerpt .
      down stream PrnLibStream 2 with frame firm-salerpt .
    end.
    else underline stream PrnLibStream cliregname sum-zak sum-prod sum-skid effvalue with frame firm-salerpt .
  end.

  assign  all-EffValue = all-Sum-prod - all-Sum-zak - all-Sum-skid .
  display stream PrnLibStream
    sym1 "ВСЕГО" @ cliregname
    sym4 all-Sum-zak  when whatshow:screen-value <> "Только продажные" @ sum-zak
    sym5 all-Sum-prod when whatshow:screen-value <> "Только учетные"   @ sum-prod
    sym6 all-Sum-skid when whatshow:screen-value <> "Только учетные"   @ sum-skid
    sym7 all-EffValue when whatshow:screen-value = {&all}              @ effvalue
  /*  sym8  */   with frame firm-salerpt .
  down stream PrnLibStream 1 with frame firm-salerpt .

/* $Workfile$ e n d */