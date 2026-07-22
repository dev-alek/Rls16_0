/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отсылка на кассы списка товаров - специфический код

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/02/05
Author: Bakhtadze Natalya
Creation date: 12/02/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if not g#news
and not g#auto
and not (valid-handle(parparentproc)
and entry(2, parparentproc:file-name, {&slash-char}) = "automain.w")
then do:
  define variable v-chk-act-host-code as integer   no-undo .
  { gbl/hostcode.i
    {&shop}
    abs(i-obj-code)
    v-chk-act-host-code
  }
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_cashdesk-goods_add-def':U
    {&cntxt-object}
    v-chk-act-host-code
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

/*PROCEDURE term-prt.*/
/*заполняет таблицу cash-gds сканируя бар-коды и ДОПБК*/
{ str/term-prt.i gds-list }

assign
cr = 0
crgd = 0
cr-txr = 0
cr-ncr-dis-kat = 0
.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Подготовка данных")
                                          ).
assign
  v-count = 0
.
_gds-list:
FOR EACH gds-list by order-num:
    assign
      v-count = v-count + 1
    .
    {&NEW-GOOD}
    run get-prt-and-unit in this-procedure (
                                            input gds-list.prt-root
                                            ,input gds-list.unit-base
                                            ,output l-empty-scale
                                            ) .                                            .
    FIND FIRST ub.gds-obj WHERE
               ub.gds-obj.obj-type = {&shop} AND
               ub.gds-obj.obj-code = i-obj-code AND
               ub.gds-obj.artic = gds-list.artic AND
               ub.gds-obj.prod-type = gds-list.prod-type AND
               ub.gds-obj.prod-code = gds-list.prod-code nO-LOCK NO-ERROR.
    if g#news and not avail gds-obj then NEXT.

    /* #2789 пункт 3.4 */
   /* if available ub.gds-obj then do :
      if check-ban-sales-via-cd(ub.gds-obj.gds-code) then do:
      if g#news then action = 'D':U. else next .
      end.
    end.
*/
    /*if v-is-restaurant then do:*/
      find first buf_fbr-gds-obj no-lock where
                 buf_fbr-gds-obj.obj-type = {&shop}
             AND buf_fbr-gds-obj.obj-code = i-obj-code
             AND buf_fbr-gds-obj.gds-code = gds-list.gds-code no-error .
      /*if     available buf_fbr-gds-obj
           and not gds-list.to-del and not buf_fbr-gds-obj.is-cd then NEXT.
    end.*/

    if not g#news then do:
      if v-count modulo 10 = 0 then do:

        run show-counter in p-log-handle .
        run write-counter in p-log-handle (substitute("Обработано: &1. Подготовка данных - товар &2 &3&4"
                                           , v-count
                                           , gds-list.artic
                                           , gds-list.prod-type
                                           , gds-list.prod-code)) no-error.
      end.
    end.
&scop buffer-name ub.gds-obj
&scop find-option no
&scop gds-code-field gds-list.gds-code
{&get-gds-obj-fields}

    RUN term-prt( ub.gds-prt.prt-root, ?) no-error.
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("!!!Ошибка при обработке товара &1 &2&3"
                              , gds-list.artic
                              , gds-list.prod-type
                              , gds-list.prod-code
                              )
                                ).
      assign
      v-view-log = yes
      .
      if g#news then return error.
    end.
    if return-value = "NEXT":U then NEXT _gds-list.
    ACCUMULATE gds-list.artic (COUNT).
    if cdpcknum = 0 then cdpcknum = 1. /* иначе ошибка деления на ноль */
    if NOT alllstcs AND ( (accum count gds-list.artic)  modulo cdpcknum)  = 0 then do:
      run get-stop-state in p-log-handle (output v-stop).
      if v-stop then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("!!!Процедура пересылки остановлена пользователем"
                                )
                                  ).
        leave _gds-list.
      end.
      else do:
        /*пошлем те cash-gds, которые успели сделать*/
        assign
        error-status:error = no.
        if cr > 0 then
        RUN SENDING no-error.
        {&sending-error}.
        /*вернемся к первому и начнем писать в таблицу с головы*/
        assign
        start-paket = yes
        start-paket-txr = yes
        cr = 0
        crgd = 0
        cr-txr = 0
        cr-ncr-dis-kat = 0
        .
      end.
    end. /* (accum count gds-list.artic)  modulo cdpcknum)  = 0 */
  /*сотрем те записи которые предназначены только для данного магазина -
  у них qnty  = 1 смотри bt_gds.p */
  if gds-list.qnty = - 1 and (callpoint = "R":U or callpoint = "N":U) then DELETE gds-list.
END . /*for each gds-list*/
/*пошлем те cash-gds, которые успели сделать но еще не послали*/
assign error-status:error = no.
if cr > 0 and not v-stop then
RUN SENDING no-error.
{&sending-error}.

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