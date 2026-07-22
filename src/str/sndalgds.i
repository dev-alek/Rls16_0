/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отсылка на кассы списка товаров в наличии- специфический код

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/02/05
Author: Bakhtadze Natalya
Creation date: 12/02/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if not g#news
and not g#auto
then do:
  define variable v-host-code{&vssseq} as integer   no-undo .
  { gbl/hostcode.i
    {&shop}
    abs(i-obj-code)
    v-host-code{&vssseq}
  }
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_cashdesk-goods_add-def':U
    {&cntxt-object}
    v-host-code{&vssseq}
    {&shop}
    abs(i-obj-code)
    0
    0
    0
    true
    g#log
  }
  if NOT g#log then
      return .
end.

/*PROCEDURE tree-prt.*/
/*заполняет таблицу cash-gds сканируя бар-коды и ДОПБК*/
{ str/term-prt.i ub.goods}

assign
cr = 0
cr-txr = 0
crgd = 0
cr-ncr-dis-kat = 0
.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Подготовка данных")
                                          ).

assign
v-count = 0.
_gds-obj:
FOR EACH ub.gds-obj No-LOCK where
         ub.gds-obj.obj-type = {&shop} and
        ub.gds-obj.obj-code = i-obj-code and
        ub.gds-obj.fact-qnty > 0 :
            
    /* #2789 пункт 3.4 */
    if check-ban-sales-via-cd(ub.gds-obj.gds-code) then next.
            
    assign
    v-count = 0.
    if v-is-restaurant then do:
      find first buf_fbr-gds-obj no-lock where
                 buf_fbr-gds-obj.obj-type = {&shop}
             AND buf_fbr-gds-obj.obj-code = i-obj-code
             AND buf_fbr-gds-obj.gds-code = ub.gds-obj.gds-code no-error .
      if     available buf_fbr-gds-obj
         and not buf_fbr-gds-obj.is-cd 
      then 
         NEXT _gds-obj.
    end.
  {&NEW-GOOD}
    FIND FIRST ub.goods NO-LOCK where
               ub.goods.artic = ub.gds-obj.artic AND
              ub.goods.prod-type = ub.gds-obj.prod-type AND
              ub.goods.prod-code = ub.gds-obj.prod-code No-ERROR.
    if not g#news then do:
      if v-count modulo 10 = 0 then do:
        run show-counter in p-log-handle .
        run write-counter in p-log-handle (substitute("Обработано: &1. Подготовка данных - товар &2 &3&4"
                                           , v-count
                                            , ub.goods.artic
                                            , ub.goods.prod-type
                                            , ub.goods.prod-code)) no-error.
      end.
    end.
    run get-prt-and-unit in this-procedure (
                                             input ub.goods.prt-root
                                            ,input ub.goods.unit-base
                                            ,output l-empty-scale
                                            ) .                                            .
&scop buffer-name ub.gds-obj
&scop find-option no
&scop gds-code-field ub.goods.gds-code
     {&get-gds-obj-fields}

  RUN term-prt( ub.gds-prt.prt-root, ?).
END . /*for each ub.gds-obj*/
/*пошлем те cash-gds, которые успели сделать но еще не послали*/
if cr > 0 then
RUN SENDING no-error.

/*нужно ли стирать temp-table?*/
FOR EACH cash-gds :
    delete cash-gds.
END.

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Отправлены товары на кассы &1&2", {&shop}, i-obj-code)
                                          ).

/* $Workfile$ e n d */