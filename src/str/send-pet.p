/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отсылка на кассу конфигурации ТРК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/05/05
Author: Bakhtadze Natalya
Creation date: 12/05/05

*/
block-level on error undo, throw.

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает
define input parameter p-obj-type as character no-undo .
define input parameter i-obj-code like ub.cash-desk.obj-code no-undo .
DEFINE INPUT PARAMETER action as char no-undo.
*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отсылка на кассу параметров".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }

define variable p-obj-type as character no-undo .
define variable i-obj-code like ub.cash-desk.obj-code no-undo .
define variable action     as character no-undo init 'U':U.

define variable p-batch as logical no-undo .
define variable p-other    as character no-undo .

{ gbl/getcntxt.i get }
{ cmp/gds-list.i gds-list def " NEW shared " " " NO-HIST }
&SCOPED-DEFINE called send-codes-only

define variable is-petrolium as logical no-undo .
define variable is-pieces as logical no-undo .
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
define variable dop-int as integer no-undo .
define buffer buf_place for ub.place.
define buffer buf_pl-gds for ub.pl-gds.
define buffer buf_goods for ub.goods.


define variable v-is-err-stat as logical no-undo .
define variable v-err-mess1   as character no-undo .
assign
p-obj-type = entry(1, p-parameter, {&delim-par})
i-obj-code = integer(entry(2, p-parameter, {&delim-par}))
action     = entry(3, p-parameter, {&delim-par})
no-error
.
v-is-err-stat = error-status:error.
v-err-mess1 = error-status:get-message(1).

/* 19/II-2018 Проблема:
  переменная log-file-name определяется где-то внутри str/sendgood.i;
  там же, внутри str/sendgood.i, выполняется чтение из conf-rd, по значению i-obj-code.
  Поэтому обработку ошибок чтения i-obj-code пришлость отделить от самого чтения.
*/
{ str/sendgood.i }

if v-is-err-stat then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3"
                         , p-parameter
                         , {&new-line}
                         , v-err-mess1
                         )).
  v-view-log = yes.
  undo, return error .
end .

{ str/defc-pl.i }

/*PROCEDURE putc-pet*/
/*разнящийся вывод для разных типов касс*/
{ str/putc-pet.i }


/*PROCEDURE for-cash-cycle*/
/*пройдем цикл по всем кассам одного типа*/
{ str/cd-cypet.i }

/*PROCEDURE SENDING.*/
{ str/cd-sepet.i }

/*PROCEDURE term-prt.*/
/*заполняет таблицу cash-gds сканируя бар-коды и ДОПБК*/
{ str/term-prt.i gds-list }


run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Пересылка конфигурации АЗС на кассы &1&2", p-obj-type, i-obj-code)


                                                                                 ).
/*отберем товары и складские места*/
for each cash-place:
  delete cash-place.
end.
_buf_place:
for each buf_place no-lock where
        buf_place.obj-type = p-obj-type
    AND buf_place.obj-code = i-obj-code
    and buf_place.status_  <> {&deleted-status},
    first buf_pl-gds no-lock where
          buf_pl-gds.obj-type = p-obj-type
      AND buf_pl-gds.obj-code = i-obj-code
      and buf_pl-gds.pl-code = buf_place.pl-code
      and buf_pl-gds.status_ = {&current-status},
    first buf_goods no-lock where buf_goods.gds-code = buf_pl-gds.gds-code and buf_goods.stts = integer({&current-status-int}) :
  assign
  dop-int = integer(buf_place.loc1)
  no-error .
  if error-status:error
  or buf_place.loc1 = '':U
  or dop-int > 999
  then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("!!!Ошибка при пересылке конфигурации АЗС:&1" +
                           "для резервуара с кодом скл места &2&1" +
                           "не задан или неверно задан порядкой код резервуара (коорд1) = &3"
                            , {&new-line}
                            , buf_place.pl-code
                            , Buf_place.loc1 )).
    v-view-log = yes.
    next _buf_place.
  end.
  /*проверим что товар топливный*/
  { str/is-petrl.i
    buf_goods.artic
    buf_goods.prod-type
    buf_goods.prod-code
    is-petrolium
    is-pieces
    no-error }
  if not (is-petrolium and not is-pieces) then NEXT.
  /*создадим gds-list*/
  { cmp/gds-list.i gds-list assign " " buf_goods }
  /*создадим таблицу по place*/
  find first cash-place no-lock where
            cash-place.loc1 = buf_place.loc1 no-error .
  if not available cash-place then do:
    create cash-place.
    buffer-copy buf_place to cash-place.
  end.
  else do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("!!!Ошибка при пересылке конфигурации АЗС:&1" +
                           "на &2&3 имеется два резервуара (складских места) - &4 и &5 &1" +
                           "c одним и тем же порядковым номером = &6 (коорд1)&1"
                            , {&new-line}
                            , buf_place.obj-type
                            , buf_place.obj-code
                            , cash-place.pl-code
                            , buf_place.pl-code
                            , Buf_place.loc1 )).
    v-view-log = yes.
  end.
end.
/*содадим коды для товаров - они нужны при привязке*/
_gds-list:
FOR EACH gds-list :
    assign
      v-count = v-count + 1
    .
    {&NEW-GOOD}
    run get-prt-and-unit in this-procedure (
                                            input gds-list.prt-root
                                            ,input gds-list.unit-base
                                            ,output l-empty-scale
                                            ) .
    FIND FIRST ub.gds-obj WHERE
               ub.gds-obj.obj-type = {&shop} AND
               ub.gds-obj.obj-code = i-obj-code AND
               ub.gds-obj.artic = gds-list.artic AND
               ub.gds-obj.prod-type = gds-list.prod-type AND
               ub.gds-obj.prod-code = gds-list.prod-code nO-LOCK NO-ERROR.
    if g#news and not avail gds-obj then NEXT.
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
    ACCUMULATE gds-list.artic (COUNT).
    delete gds-list.
END . /*for each gds-list*/

RUN SENDING no-error.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки при отсылке конфигурации АЗС на кассы &1&2"
                         , p-obj-type, i-obj-code
                        )
                                        ).

  assign
  v-view-log = yes
  .
end.
if v-view-log then return error .

  finally :
    run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("&1", {&new-line})
    ).
    define variable v-save-file-name as character no-undo .
    v-save-file-name = substitute("&1send-cd.log", ibs.th.gbl.gbl-inipar:logDir) .
    OS-APPEND value(log-file-name) value(v-save-file-name).
    OS-DELETE value(log-file-name).
  end finally .
