/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

товаров на кассу из переоценки - специфический код

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*PROCEDURE term-prt.*/
/*заполняет таблицу cash-gds сканируя бар-коды и ДОПБК*/
{ str/term-prt.i ub.goods}
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Подготовка данных")
                                          ).
assign
  v-count = 0
.
assign
cr = 0
crgd = 0
cr-txr = 0
cr-ncr-dis-kat = 0
.
_price-list:
FOR EACH ub.price-list NO-LOCK WHERE
         ub.price-list.doc-num = p-doc.doc-num use-index doc-gds :
    /*в переоценке не может не быть корня товара*/
    if NOT ub.price-list.main-price then NEXT _Price-list.

    assign
      v-count = v-count + 1
    .
    FIND FIRST ub.goods WHERE
               ub.goods.prod-type = ub.price-list.prod-type AND
               ub.goods.prod-code = ub.price-list.prod-code AND
               ub.goods.artic     = ub.price-list.artic NO-LOCK .
               
    /* #2789 пункт 3.4 */
    if check-ban-sales-via-cd(ub.goods.gds-code) then next.
               
    if v-count modulo 10 = 0 then do:
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Обработано: &1. Подготовка данных - товар &2 &3&4"
                                          , v-count
                                          , goods.artic
                                          , goods.prod-type
                                          , goods.prod-code)) no-error.
    end.
    {&NEW-GOOD}
    run get-prt-and-unit in this-procedure (
                                            input ub.goods.prt-root
                                            ,input ub.goods.unit-base
                                            ,output l-empty-scale
                                            ) .                                            .
    if v-is-restaurant then do:
      find first buf_fbr-gds-obj no-lock where
                 buf_fbr-gds-obj.obj-type = {&shop}
             AND buf_fbr-gds-obj.obj-code = i-obj-code
             AND buf_fbr-gds-obj.gds-code = ub.goods.gds-code no-error .
      if     available buf_fbr-gds-obj
         and not buf_fbr-gds-obj.is-cd 
      then 
         NEXT _price-list.
    end.
    FIND FIRST ub.gds-obj WHERE
               ub.gds-obj.obj-type = {&shop} AND
               ub.gds-obj.obj-code = i-obj-code AND
               ub.gds-obj.artic = goods.artic AND
               ub.gds-obj.prod-type = goods.prod-type AND
               ub.gds-obj.prod-code = goods.prod-code nO-LOCK NO-ERROR.
&scop buffer-name ub.gds-obj
&scop find-option no
&scop gds-code-field ub.goods.gds-code
     {&get-gds-obj-fields}

    /*заполним все товары главной ценой */
    RUN term-prt( ub.gds-prt.prt-root, ?) no-error.
    if error-status:error then do:
      return "error":U.
    end.
    ACCUMULATE ub.goods.artic (COUNT).
    if NOT alllstcs AND ( (accum count ub.goods.artic)  modulo cdpcknum)  = 0 then do:
        /*пошлем те cash-gds, которые успели сделать*/
        if cr > 0 then
        RUN SENDING no-error.
        /*вернемся к первому и начнем писать в таблицу с головы*/
        assign
        start-paket = yes
        start-paket-txr = yes
        cr = 0
        crgd = 0
        cr-txr = 0
        cr-ncr-dis-kat = 0
        .
    end. /* (accum count goods.artic)  modulo cdpcknum)  = 0 */
END . /*for each gds-list*/

/*пошлем те cash-gds, которые успели сделать но еще не послали*/
if cr > 0 then
RUN SENDING no-error.

/*нужно ли стирать temp-table?*/
FOR EACH cash-gds :
    delete cash-gds.
END.

/* $Workfile$ e n d */