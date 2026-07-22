/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Всяческие процедуры при закрытии продажи
{1} = integerface - из интерфейса продажи

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/10/05
Author: Bakhtadze Natalya
Creation date: 03/10/05

{1} = integerface - из интерфейса продажи

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE INV-CHK:
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter v-curr-r-b   as character no-undo .
define parameter buffer buf_inkas   for ub.inkas.
define parameter buffer buf_trn-doc for ub.trn-doc.
define input parameter r-or-v as character no-undo .
define input parameter r-office as character no-undo .
define input parameter rdoc-line as recid no-undo .

/*переменные введенные вместо аккумулятов*/
define variable accum-inkas-pay-tot-r-b as decimal no-undo.
define variable accum-inkas-pay-desk-tot-r-b as decimal no-undo.
define variable l-inv-on as logical no-undo .
define variable v-in-inv as logical no-undo .
define variable v-inkas-qnty-r as decimal no-undo .
define variable v-inkas-qnty-v as decimal no-undo .

define buffer buf_doc-line for ub.doc-line.
define buffer buf_goods    for ub.goods.
define buffer buf_inkas-pay for ub.inkas-pay.
define buffer buf_inkas-pay-desk for ub.inkas-pay-desk.
define buffer buf_sale-doc for ub.sale-doc.

if buf_trn-doc.status_ = {&inquiry} then do:
  /*проверим что ?*/
end.
else do:
  &scop my-message "Проверка товаров продажи на присутствие в незакрытой инвентаризации..."
  {&display-message}.

  /*проверка на инвентаризацию и еще кое-что*/
  _buf_sale-doc:
  for each buf_sale-doc where
          buf_sale-doc.inkas-code = p-inkas-code
      and buf_sale-doc.order > 0
    on error undo _buf_sale-doc, next _buf_sale-doc:

    /*списание по возврату резервируется в процессе закрытия на факт*/
    if buf_sale-doc.in-inkas = yes
    and buf_sale-doc.dir = 1 then do:
       assign
       v-inkas-qnty-r = v-inkas-qnty-r + buf_sale-doc.fact-qnty.
    end.
    if buf_sale-doc.in-inkas = yes
    and buf_sale-doc.dir = -1 then do:
       assign
       v-inkas-qnty-v = v-inkas-qnty-v + buf_sale-doc.fact-qnty.
    end.

    if buf_sale-doc.doc-kind = {&sale-add-return-write-off} then next _buf_sale-doc.
    if r-or-v <> ?
    and (buf_sale-doc.doc-kind <> r-or-v
         or
         buf_sale-doc.chr-office <> r-office
          ) then NEXT _buf_sale-doc.
    _buf_doc-line:
    FOR EACH buf_doc-line WHERE
            buf_doc-line.doc-code = buf_sale-doc.doc-code
        AND (rdoc-line = ? or recid(buf_doc-line) = rdoc-line) NO-LOCK :
      { gbl/gdsobjat.i
        buf_doc-line.obj-type
        buf_doc-line.obj-code
        buf_doc-line.artic
        buf_doc-line.prod-type
        buf_doc-line.prod-code
        "'inv-on=request'"
        l-inv-on
          no-error }
      if error-status :error then do:
        undo, return error substitute("&1 &2 &3 Ошибка получения признака товара на объекте:&4&5 &6"
                                      ,vss-workfile
                                      ,vss-revision
                                      ,vss-description
                                      , {&new-line}
                                      , error-status:error
                                      , return-value
                                        ).
      end.
      if l-inv-on then do:
        FIND FIRST buf_goods WHERE
                  buf_doc-line.prod-type = buf_goods.prod-type
              and buf_doc-line.prod-code = buf_goods.prod-code
              and buf_doc-line.artic = buf_goods.artic NO-LOCK .
        run waitfram-hide in this-procedure .
  &scop my-message  substitute("Артикул :&1 &2- товар в инвентаризации.&3&3" + ~
                  (if p-auto = 0 then "Резервирование и/или закрытие отчета невозможно" else "":U) ~
                                  ,buf_doc-line.artic                          ~
                                  ,buf_goods.gds-name                          ~
                                  , ~{&new-line}~)
        {&display-message-laud}.
        if p-auto = 0 then do:
          undo, return error.
        end.
        else do:
          assign
          v-in-inv = yes
          .
        end.
      end.
    END. /*FOR EACH buf_doc-line WHERE*/
  end. /*for each buf_sale-doc*/
  if v-in-inv then do:
        undo,  return error substitute("Имеются товары в инвентаризации.&2&2Закрытие отчета невозможно."
                                , {&new-line}).
  end.

  run waitfram-hide in this-procedure .
end.

&scop my-message "Сравнение сумм по товарам и выручке......"
{&display-message}.

assign
accum-inkas-pay-tot-r-b = 0
.
FOR EACH buf_inkas-pay WHERE
         buf_inkas-pay.inkas-code = buf_inkas.inkas-code NO-LOCK
:
  accum-inkas-pay-tot-r-b = accum-inkas-pay-tot-r-b + (if v-curr-r-b = {&r-b-base}
                                                       then buf_inkas-pay.tot-base
                                                       else buf_inkas-pay.tot-rubl)
                                                       .
  accum-inkas-pay-desk-tot-r-b = 0.
  FOR EACH buf_inkas-pay-desk WHERE
           buf_inkas-pay-desk.inkas-code = buf_inkas.inkas-code AND
           buf_inkas-pay-desk.pay-code   = buf_inkas-pay.pay-code AND
           buf_inkas-pay-desk.curr-code  = buf_inkas-pay.curr-code NO-LOCK
  :
      accum-inkas-pay-desk-tot-r-b = accum-inkas-pay-desk-tot-r-b +
                                     (if v-curr-r-b = {&r-b-base}
                                      then buf_inkas-pay-desk.tot-base
                                      else buf_inkas-pay-desk.tot-rubl).
  END .
  if (v-curr-r-b = {&r-b-base} and abs( buf_inkas-pay.tot-base -  accum-inkas-pay-desk-tot-r-b ) > 0.015)
  OR (v-curr-r-b = {&r-b-rubl} and abs( buf_inkas-pay.tot-rubl -  accum-inkas-pay-desk-tot-r-b ) > 0.015)
  then do:
    run waitfram-hide in this-procedure .
    undo, return error substitute("&1 Ошибка оплат по чекам&2По оплатам &3&2По оплатам по кассе &4"
                            , vss-description
                            , {&new-line}
                            , (if v-curr-r-b = {&r-b-base} then buf_inkas-pay.tot-base else buf_inkas-pay.tot-rubl )
                            , accum-inkas-pay-desk-tot-r-b).

  end.
END .
if abs( buf_inkas.netto -  accum-inkas-pay-tot-r-b ) > 0.015 then do:
  run waitfram-hide in this-procedure .
  undo, return error substitute("&1 Ошибка оплат по чекам&2По отчету &3&2По оплатам &4"
                          , vss-description
                          , {&new-line}
                          , buf_inkas.netto
                          , accum-inkas-pay-tot-r-b).
end.

if buf_inkas.qnty <> v-inkas-qnty-r - v-inkas-qnty-v then do:
  run waitfram-hide in this-procedure .
  undo, return error substitute("&1 Несоответствие накладных и документа продажи&2" +
                           "Количество товара в продаже &3&2"  +
                           "Количество товара в расходной накладной &4&2" +
                           "Количество товара в возвратной накладной &5&2"
                           ,vss-description
                           , {&new-line}
                           , buf_inkas.qnty
                           , v-inkas-qnty-r
                           , v-inkas-qnty-v).
end.
run waitfram-hide in this-procedure .
END PROCEDURE.



PROCEDURE neg-rests:
/*откуда вызывается! не из триггера по кнопке ли ЗАКРЫТЬ*/
define input parameter from-close as logical.
define input parameter p-status_ like ub.inkas.status_ no-undo .
/*процедура проверки можно ли закрыть продажу - не ушли ли в минус товары
по которым не разрешены отрицательные остатки */
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter p-mode       as character no-undo .
define input parameter p-is-catering as logical no-undo .
define input parameter p-is-tpsi-obj  as logical no-undo .
define input parameter p-neg-tpsi-weight as logical no-undo .
define input parameter p-neg-tpsi-qnty as decimal no-undo .
define input parameter p-neg-tpsi-oper as logical no-undo .


&scop my-message "Проверка возможности появления недопустимых отрицательных остатков..."
{&display-message}.

if not p-mode = {&lookup} then do:
  run str/dtlrests.p (
                 input p-inkas-code
                ,input from-close
                ,input "all":U
                ,input no /*p-all-goods*/
                ,input p-is-catering
                ,input p-is-tpsi-obj
                ,input p-neg-tpsi-weight
                ,input p-neg-tpsi-qnty
                ,input p-neg-tpsi-oper
                ).

/*на этом месте появляется таблица dtl-rests в которой записи могут быть не уникальны по
    artic prod-type pro-code - это пользователя может смутить
но ничего не поделаешь!*/
/*если не из закрытия продажи*/
  if not from-close then do:
    for each dtl-rests :
      if p-status_ <> {&fact}
      and p-mode = {&update}
      and p-is-tpsi-obj
      and dtl-rests.is-neg-tpsi-oper then do:
        find first dtl-rests-mark where
                  dtl-rests-mark.artic = dtl-rests.artic
              and dtl-rests-mark.prod-type = dtl-rests.prod-type
              and dtl-rests-mark.prod-code = dtl-rests.prod-code no-error .
        if not available dtl-rests-mark then do:
          create dtl-rests-mark.
          buffer-copy dtl-rests to dtl-rests-mark.
          release dtl-rests-mark.
        end.
      end.
      if dtl-rests.OK then delete dtl-rests.
    end.
  end.
end. /*if status факт*/
run waitfram-hide in this-procedure .
END PROCEDURE.


PROCEDURE b-res-proc:
define parameter buffer buf_inkas for ub.inkas.
define parameter buffer buf_trn-doc for ub.trn-doc.
define parameter buffer buf_ret-doc for ub.trn-doc.
define input parameter p-auto-fbr as logical no-undo .
define input parameter auto-close as logical no-undo . /*в интерфейсе cehck-box не в интерфейсе из натсроек объекта*/
define input parameter p-rsrv-prop-goods as logical no-undo . /*резервировать чужой товар на своем объекте - только при закрытии*/
define input parameter p-rest-dish as logical no-undo .
define input parameter p-fbr-income-doc-code like ub.trn-doc.doc-code no-undo .
define input parameter p-is-tpsi-obj as logical no-undo .
define input parameter p-rest-tpsi as logical no-undo .

define buffer locked_trn-doc for ub.trn-doc.
define buffer locked_inkas for ub.inkas.
define buffer buf_sale-doc for ub.sale-doc.

define variable glog as logical no-undo .

do
on error undo, return error return-value
:

  if buf_trn-doc.status_ = {&inquiry} then return.

  &if "{1}" = "interface" &then
  if not from-menu then
  &endif
  assign
  rdoc-line = ?
  rgds-dtl = ?
  r-or-v = (if r-or-v = {&sale-add-return-write-off} then r-or-v else ?)
  r-office = ?
  r-qnty = ?
  r-b-code = ?
  r-pl-code = ?
  r-doc-prts-qnty = ?
  .
  from-menu = no.
  assign
  num_resv = 0
  num_resv_res = 0
  num_rec = 0
  num_rec_res = 0
  .

  &if "{1}" = "interface" &then
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_sale_fact':U
      {&cntxt-object}
      buf_inkas.host-code
      buf_inkas.obj-type
      buf_inkas.obj-code
      0
      0
      0
      true
      glog
    }
    if NOT glog then undo, return error.
  &endif
  if NOT can-find( first ub.chk-doc No-LOCK where ub.chk-doc.out-code = buf_inkas.inkas-code ) then do:
    undo, return error substitute("&1 Отчет о продаже пуст. Резервирование невозможно.", vss-description).
  end.
  FIND FIRST locked_trn-doc WHERE
          locked_trn-doc.doc-code = buf_inkas.inkas-code NO-LOCK .
  glog = no.
  RUN Inv-chk in this-procedure  (input buf_Inkas.inkas-code
                                , input v-curr-r-b
                                , buffer buf_inkas
                                , buffer buf_trn-doc
                                , input r-or-v
                                , input r-office
                                , input rdoc-line) no-error .
  IF error-status:error  then do:
  &if "{1}" = "interface" &then
    message
    substitute("&1 Были ошибки при проверке документов на возможность резервирования:&2&3&2&4"
                , vss-description
                , {&new-line}
                , error-status:get-message(1)
                , return-value)
    view-as alert-box error .
    undo, return "error".
  &else
      undo, return error substitute("&1 Были ошибки при проверке документов на возможность резервирования:&2&3&2&4"
                              , vss-description
                              , {&new-line}
                              , error-status:get-message(1)
                              , return-value).
  &Endif
  end.
  BadTrans = FALSE .
  FIND FIRST locked_inkas WHERE recid( locked_inkas ) = recid( buf_Inkas ) .
  FIND FIRST locked_trn-doc WHERE
            locked_trn-doc.doc-code = buf_inkas.inkas-code .
&if "{1}" = "interface" &then
  assign
  locked_inkas.is-auto-rsrv = no
  .
&else
  assign
  locked_inkas.is-auto-rsrv = (p-auto >= 2)
  .
&endif


  RUN RESERV in this-procedure (
             buffer locked_inkas
            ,buffer locked_trn-doc
            ,input p-auto-fbr
            ,input p-rsrv-prop-goods
            ,input p-rest-dish
            ,input p-fbr-income-doc-code
            ,input p-is-tpsi-obj
            ,input p-rest-tpsi) no-error.
  IF error-status:error  then do:
  &if "{1}" = "interface" &then
    message
    substitute("&1 Были ошибки при резервировании:&2&3 &4"
                , vss-description
                , {&new-line}
                , error-status:get-message(1)
                , return-value)
    view-as alert-box error .
    if p-is-tpsi-obj then run UI-on in this-procedure .
    return "error".
  &else
      undo, return error substitute("&1 Были ошибки при резервировании:&2&3 &4"
                              , vss-description
                              , {&new-line}
                              , error-status:get-message(1)
                              , return-value).

  &endif
  end.
  &if "{1}" = "interface" &then
    if p-is-tpsi-obj then run UI-on in this-procedure .
  &endif
  IF num_resv = 0  then do:
    if NOT auto-close
    and not p-auto-fbr
    then do:
      &if "{1}" = "interface" &then
      message
      "Не найдено товара для резервирования."
      view-as alert-box INFORMATION .
      &Else
        undo, return substitute("&1 Не найдено товара для резервирования." , vss-description).
      &Endif
    end.
  end.
  &if "{1}" = "interface" &then
    p-next-prev = ?.
    run UI-on in this-procedure .
    if rgds-dtl <> ? then do:
      if r-or-v = {&TDEDT_Ras_Vnesh_KASS}
      and r-office = {&gds-goods}
      then
      reposition br-out to recid rgds-dtl no-error.
      else
      reposition br-ret to recid rgds-dtl no-error.
    end.
  &endif
  if p-auto-fbr then do:
    assign
    error-status:error = no
    .
  end.
end. /*doe*/
END PROCEDURE. /*b-res-proc*/


PROCEDURE b-unres-proc:
define parameter buffer buf_inkas for ub.inkas.
define parameter buffer buf_trn-doc for ub.trn-doc.
define parameter buffer buf_ret-doc for ub.trn-doc.
define input parameter p-is-tpsi-obj  as logical no-undo .
define input parameter p-from-compense as logical no-undo .

define variable glog as logical no-undo .
define buffer locked_inkas for ub.inkas.
define buffer locked_trn-doc for ub.trn-doc.

if buf_trn-doc.status_ = {&inquiry} then return.

&if "{1}" = "interface" &then
if not from-menu then
&else
if not p-from-compense then
&endif
assign
rdoc-line = ?
rgds-dtl = ?
r-or-v = ?
r-office = ?
r-qnty = ?
.
assign
num_resv = 0
num_resv_res = 0
num_rec = 0
num_rec_res = 0
.
&if "{1}" = "interface" &then
from-menu = no.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_sale_fact':U
  {&cntxt-object}
  buf_inkas.host-code
  buf_inkas.obj-type
  buf_inkas.obj-code
  0
  0
  0
  true
  glog
}
if NOT glog then undo, return error.
&endif

if NOT can-find( first ub.chk-doc No-LOCK where ub.chk-doc.out-code = buf_inkas.inkas-code ) then do:
  undo, return error substitute("&1 Отчет о продаже пуст. Снять резервы невозможно.", vss-description).
end.

FIND FIRST locked_trn-doc WHERE
         locked_trn-doc.doc-code = buf_trn-doc.doc-code NO-LOCK .
glog = no.

RUN Inv-chk  in this-procedure (  input buf_Inkas.inkas-code
              , input v-curr-r-b
              , buffer buf_inkas
              , buffer buf_trn-doc
              , input r-or-v
              , input r-office
              , input rdoc-line) no-error .
IF error-status:error  then do:
&if "{1}" = "interface" &then
 {&hide-count-message}.
  message
  substitute("&1 Были ошибки при проверке документов на возможность разрезервирования:&2&3&2&4"
              , vss-description
              , {&new-line}
              , error-status:get-message(1)
              , return-value)
  view-as alert-box error .
  undo, return "error".
&else
    undo, return error substitute("&1 Были ошибки при проверке документов на возможность разрезервирования:&2&3&2&4"
                            , vss-description
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value).
&Endif
end.




BadTrans = FALSE .
FIND FIRST locked_inkas WHERE recid( locked_inkas ) = recid( buf_Inkas ) .
FIND FIRST locked_trn-doc WHERE
           locked_trn-doc.doc-code = buf_inkas.inkas-code .
RUN UNRESERV in this-procedure (input p-is-tpsi-obj
                              , buffer locked_inkas
                              ) no-error .


IF error-status:error  then do:
&if "{1}" = "interface" &then
 {&hide-count-message}.
  message
  substitute("&1 Были ошибки при снятии резервов:&2&3 &4"
              , vss-description
              , {&new-line}
              , error-status:get-message(1)
              , return-value)
  view-as alert-box error .
  undo, return error.
&else
    undo, return error substitute("&1 Были ошибки при снятии резервов:&2&3 &4"
                            , vss-description
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value).

&endif
end.
IF num_resv = 0
and not p-from-compense
then do:
  &if "{1}" = "interface" &then
  message
  "Не найдено товара для снятия резервов."
  view-as alert-box INFORMATION .
  &Else
    undo, return error substitute("&1 Не найдено товара для снятия резервов." , vss-description).
  &Endif
end.
&if "{1}" = "interface" &then
  p-next-prev = ?.
  run UI-on in this-procedure .
  if rgds-dtl <> ? then reposition br-out to recid rgds-dtl no-error.
  if error-status:error then
  reposition br-ret to recid rgds-dtl no-error.
&Endif
END PROCEDURE. /*b-unres-proc*/

PROCEDURE RESERV:
define parameter buffer buf_inkas for ub.inkas.
define parameter buffer buf_trn-doc for ub.trn-doc.
define input parameter p-auto-fbr as logical no-undo .
define input parameter p-rsrv-prop-goods as logical no-undo . /*резервировать чужой товар на своем объекте - только при закрытии*/
define input parameter p-rest-dish as logical no-undo .
define input parameter p-fbr-income-doc-code like ub.trn-doc.doc-code no-undo .
define input parameter p-is-tpsi-obj  as logical no-undo .
define input parameter p-rest-tpsi as logical no-undo .

DEFINE VARIABLE vat-value like ub.doc-line.vat-pc no-undo .
DEFINE VARIABLE slt-value like ub.doc-line.slt-pc no-undo .
define variable v-is-dish as character no-undo .
define variable v-is-modificator as character no-undo .
define variable v-run-tpsi-line as logical no-undo .
define variable v-run-tpsi as logical no-undo .
define buffer buf_sale-doc for ub.sale-doc.
define buffer dop_trn-doc for ub.trn-doc.

define variable v-user-action  as character no-undo .
define variable v-printed      as logical   no-undo .
define variable v-old-num_rec as integer no-undo .
define variable v-attr-value              as character no-undo .
define variable v-type                   as character no-undo .

if buf_trn-doc.status_ = {&inquiry} then return.

assign
num_rec = 0
num_rec_res = 0
num_resv = 0
num_resv_res = 0
num_rec_other = 0
num_rec_other_res = 0
r-artic =      "":U
r-prod-type = "":U
r-prod-code = 0
r-prt-code = 0
.
for each tt0-info:
  delete tt0-info.
end.
_buf_sale-doc:
for each buf_sale-doc where
       buf_sale-doc.inkas-code = buf_inkas.inkas-code
   and buf_sale-doc.order > 0
by buf_sale-doc.order
on error undo _buf_sale-doc, next _buf_sale-doc:
  if r-or-v <> ?
  and  (buf_sale-doc.doc-kind <> r-or-v
       or
       buf_sale-doc.chr-office <> r-office
       )
  then NEXT _buf_sale-doc.
  if not (buf_sale-doc.doc-kind = {&TDEDT_ras_Vnesh_kass}
         and
         buf_sale-doc.chr-office = {&gds-goods}) then do:
    find first buf_trn-doc exclusive-lock where buf_trn-doc.doc-code = buf_sale-doc.doc-code.
  end.
  if buf_sale-doc.doc-kind = {&sale-add-return-write-off}
  and r-or-v <> {&sale-add-return-write-off} then next _buf_sale-doc.
&scop sale-doc-kind  buf_sale-doc.doc-kind
&scop my-message substitute("Резервирование товаров. &1", ~{&sale-doc-name~})
{&display-message}.
  _doc-line:
  FOR EACH ub.doc-line EXCLUSIVE-LOCK WHERE
            ub.doc-line.doc-code = buf_trn-doc.doc-code,
      FIRST ub.goods WHERE
                ub.goods.artic = ub.doc-line.artic AND
                ub.goods.prod-type = ub.doc-line.prod-type AND
                ub.goods.prod-code = ub.doc-line.prod-code NO-LOCK
   on error undo _doc-line, next _doc-line :
    IF ub.doc-line.fact-qnty = ub.doc-line.doc-qnty then NEXT _doc-line.
    if buf_sale-doc.doc-kind = {&TDEDT_Vozvrat_Vnesh_Kass}
    then do :
      find first ub.doc-fbr-gds no-lock where ub.doc-fbr-gds.out-code = replace(ub.doc-line.doc-code, "=", "-")
                                          and ub.doc-fbr-gds.gds-code = ub.goods.gds-code
                                          no-error.
      if available ub.doc-fbr-gds and ub.doc-fbr-gds.fact-qnty < 0
      then do :
        if ub.doc-line.doc-qnty = abs(ub.doc-fbr-gds.fact-qnty) then NEXT _doc-line.
      end.                                     
    end.                                      
    IF NOT (rdoc-line = ?) then do:
      if  NOT recid(ub.doc-line) = rdoc-line THEN NEXT _doc-line.
      assign
      r-artic = ub.doc-line.artic
      r-prod-type = ub.doc-line.prod-type
      r-prod-code = ub.doc-line.prod-code
      .
    end.
    { gbl/pftxvalg.i ub.goods.gds-code {&vat-tax-code} buf_inkas.shift-date buf_inkas.host-code buf_inkas.obj-type buf_inkas.obj-code vat-value no-error}
    find first dop_trn-doc no-lock where
              dop_trn-doc.doc-code  = buf_sale-doc.doc-code.
    { str/st-sltpc.i
      recid(ub.goods)
      recid(dop_trn-doc)
      buf_sale-doc.pay-code
      slt-value
    }
    assign
    doc-line.VAT-pc = vat-value
    doc-line.slt-pc = slt-value
    .
    IF CAN-FIND(FIRST ub.doc-pl No-LOCK WHERE
                      ub.doc-pl.out-code = ub.doc-line.doc-code AND
                      ub.doc-pl.gds-code = ub.goods.gds-code)
    then do:
        FIND FIRST ub.gds-prt NO-LOCK WHERE
                    ub.gds-prt.upper-code = ub.goods.prt-root NO-ERROR.
        cashplace = yes.
    end.
    else cashplace = no.
    IF NOT cashplace then do:
        IF CAN-FIND(FIRST ub.doc-prts No-LOCK WHERE
                          ub.doc-prts.out-code = ub.doc-line.doc-code AND
                          ub.doc-prts.gds-code = ub.goods.gds-code)
        then do:
            FIND FIRST ub.gds-prt NO-LOCK WHERE
                        ub.gds-prt.upper-code = ub.goods.prt-root NO-ERROR.
            cashparts = yes.
        end.
        else cashparts = no.
    end.
    else cashparts = no.
    FIND FIRST ub.units WHERE
                ub.units.unit-name = ub.goods.unit-base NO-LOCK .
    if can-find(first ub.tax-units where
                      ub.tax-units.tax-code = btltaxcd AND
                      LOOKUP(ub.tax-units.type, units.type) > 0) then  do:
        assign
        bottle = yes.
    end.
    else do:
        bottle = no.
    end.
    IF CAN-FIND(FIRST ub.doc-fbr-gds No-LOCK WHERE
                      ub.doc-fbr-gds.out-code = ub.doc-line.doc-code AND
                      ub.doc-fbr-gds.gds-code = ub.goods.gds-code)
    then do:
      { gbl/fgdsobjt.i ub.doc-line.obj-type ub.doc-line.obj-code ub.goods.gds-code "'is-dish=request,is-modificator=request'" v-is-dish }
      /*v-is-dish должно быть '10' или '01'  */
      if not error-status:error
      then assign
      cashfbr = lookup('1':U, v-is-dish) > 0
      no-error .
    end.
    else cashfbr = no.
    rsrv-title = substitute("Резервирование. &1. Строк ", {&sale-doc-name}).
    if buf_sale-doc.dir = 1 then do:
      assign
        v-old-num_rec = num_rec.
      run RSRV-line in this-procedure (
                    input 1,
                    input p-auto-fbr,
                    input p-rsrv-prop-goods,
                    input auto-fbr,
                    input p-rest-dish,
                    input p-fbr-income-doc-code,
                    input p-is-tpsi-obj,
                    input p-rest-tpsi,
                    input yes, /*резерв*/
                    input ub.goods.gds-code,
                    input (if available ub.gds-prt then ub.gds-prt.node-code else ?),
                    output v-run-tpsi-line,
                    buffer ub.doc-line,
                    buffer buf_trn-doc,
                    buffer buf_sale-doc
                    ) no-error.
      if ub.doc-line.fact-qnty <> ub.doc-line.doc-qnty and v-log-handle <> ?
          and v-old-num_rec <> num_rec /*посл. условие что позиция подлежит резервированию*/
      then do:
        run write-log-and-file in v-log-handle (
                            input 1
                          , input log-file-name
                          , input 1
                          , input substitute("Ошибка при резервировании товара артикул &1: требуемое кол-во &2 зарезервировано &3"
                                        ,ub.doc-line.artic
                                        ,ub.doc-line.fact-qnty
                                        ,ub.doc-line.doc-qnty
                                        )
                          ).
      end.
    end.
    else do:
      RUN gds-attr-value (
                          INPUT ub.goods.gds-code,
                          INPUT {&attr-mark-type},
                          OUTPUT v-attr-value,
                          OUTPUT v-type
                          ).
      if v-attr-value > ""
      and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_trn-doc.obj-type, buf_trn-doc.obj-code):GetIsMarkingForType(v-attr-value) 
      then do :
        next _doc-line .
      end .
      run RSRV-line in this-procedure (
                    input -1,
                    input no,
                    input no /*p-rsrv-prop-goods*/,
                    input auto-fbr,
                    input p-rest-dish,
                    input p-fbr-income-doc-code,
                    input p-is-tpsi-obj,
                    input p-rest-tpsi,
                    input yes, /*резерв*/
                    input ub.goods.gds-code,
                    input (if available ub.gds-prt then ub.gds-prt.node-code else ?),
                    output v-run-tpsi-line,
                    buffer ub.doc-line,
                    buffer buf_trn-doc,
                    buffer buf_sale-doc
                    ) no-error.
    end.
    if error-status:error then do:
      if rdoc-line <> ? then do:
        run waitfram-hide in this-procedure .
        return error substitute("Ошибка при резервировании товаров:&1&2 &3"
                              , {&new-line}
                              , error-status:get-message(1)
                              , return-value ).
      end.
      else next _doc-line.
    end.
    assign
    doc-line.price-base = cost-base
    doc-line.price-rubl = cost-rubl .
    if buf_sale-doc.doc-kind = {&TDEDT_ras_Vnesh_kass}
    then do:
      assign
      v-run-tpsi = v-run-tpsi or v-run-tpsi-line.
    end.
  END. /*FOR EACH doc-line EXCLUSIVE-LOCK WHERE*/
  if buf_sale-doc.doc-kind = {&TDEDT_ras_Vnesh_kass} then do:
    run waitfram-hide in this-procedure .
    if not p-rsrv-prop-goods /*при закрытии не резервируем на чужих объектах!!!*/
    and (p-is-tpsi-obj and v-run-tpsi)  then do:

  &scop my-message "Ждите... Идет резервирование ЧУЖИХ товаров."
  {&display-message}.

      run str/tpsirsrv.p (
                      input parparentproc
                      ,input p-parent-handle
                      ,input p-log-handle
                      ,input p-auto
                      ,INPUT V-CURR-R-B
                      ,input buf_inkas.inkas-code
                      ,input buf_trn-doc.host-code
                      ,input buf_trn-doc.obj-type
                      ,input buf_trn-doc.obj-code
                      ,input r-artic
                      ,input r-prod-type
                      ,input r-prod-code
                      ,input r-prt-code
                      ,input yes
                      /*title окна резервирования*/
                      ,input "Резервирование ЧУЖИХ товаров. Расход. Строк " /*p-title*/
                      /*это продолжение счетчика начатого в salersrv.i*/
                      ,input-output num_rec_res
                      /*это счетчик попыток резервирования только ЧУЖИХ ТОВАРОВ*/
                      ,output num_rec_other
                      /*это счетчик УДАЧНЫХ попыток резервирования только ЧУЖИХ ТОВАРОВ*/
                      ,output num_rec_other_res
                      /*здесь только документ расхода продажи  - ведь возварт мы обратно не возвращаем*/
                      ,buffer buf_trn-doc
                    ) no-error .
      if error-status:error then do:
        if p-rsrv-prop-goods
        or rdoc-line <> ? then do:
          run waitfram-hide in this-procedure .
          return error substitute("Ошибка при резервировании ЧУЖИХ товаров:&1&2 &3"
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value ).
        end.
        else do:
        end.
        run waitfram-hide in this-procedure .
      end.
    end. /*if not p-rsrv-prop-goods
    and  then do:*/
  end. /*если расход*/
  assign
  num_resv = num_resv + num_rec
  num_resv_res = num_resv_res + num_rec_res
  num_rec = 0
  num_rec_res = 0
  .
END. /*DO v-doc-ii = 1 to num-entries(v-doc-code-list):*/
/*  непонятно
if num_resv = 0 then do:
&scop my-message "Не найдено товаров для резервирования"
{&display-message-laud}.
end.
*/
if num_resv = num_resv_res and num_resv > 0 then do:
  if NOT auto-close and r-qnty = ? and not p-auto-fbr then do:
&scop my-message "Резервирование прошло успешно"
{&display-message-laud}.
  end.
end.
else do:
  if auto-fbr then do:
  end.
  if  num_resv > 0 then do:
&scop my-message substitute("Из &1 позиций, подлежащих резервированию, успешно зарезервировано &2 (не зарезервировано &3)" ~
                        , num_resv                                                              ~
                        , num_resv_res ~
                        , num_resv - num_resv_res)
{&display-message-laud}.
    if search (log-file-name) <> ? and not (auto-close or p-auto-fbr or g#auto) then do:
      run gbl/prnfilen.w (
            input "Список не зарезервированных товаров":U
          , input 8
          , input search (log-file-name)
          , input 7
          , output v-user-action
          , output v-printed
      ).
      os-delete value(log-file-name) .
    end.
	if search ("alc-rsrv.log") <> ? and not (auto-close or p-auto-fbr or g#auto)  then do:
	    run gbl/prnfilen.w (
	          input "Замечания по резервированию алкоголя":U
	        , input 8
	        , input search ("alc-rsrv.log")
	        , input 7
	        , output v-user-action
	        , output v-printed
	    ).
	    os-delete value("alc-rsrv.log") .
	end.
  end.
  if num_resv > 0
  and (auto-close or p-auto-fbr) then return error "Не все товары, подлежащие резервированию, зарезервированы".
end.
END PROCEDURE.


PROCEDURE button-close:
define parameter buffer buf_trn-doc for ub.trn-doc.
define parameter buffer buf_ret-doc for ub.trn-doc.
define input parameter p-is-tpsi-obj as logical no-undo .
define input parameter auto-fbr as logical no-undo .
define input parameter p-neg-tpsi-weight as logical no-undo .
define input parameter p-neg-tpsi-qnty as decimal no-undo .
define input parameter p-neg-tpsi-oper as logical no-undo .
define output parameter b-close-enabled as logical no-undo .
define variable v-is-dish as character no-undo .
define variable v-doc-ii as integer no-undo .
define variable v-curr-doc-code like ub.trn-doc.doc-code no-undo .
define variable v-attr-value              as character no-undo .
define variable v-type                   as character no-undo .
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_goods for ub.goods.
define buffer buf_doc-line for ub.doc-line.
define buffer dop_trn-doc for ub.trn-doc.
define buffer buf_sale-doc for ub.sale-doc.
define buffer buf_units for ub.units.

if buf_trn-doc.status_ = {&inquiry} then do:
  &scop my-message "Проверка отсутствия зарезервированного товара..."
  {&display-message}.

end.
else do:
  &scop my-message "Проверка количества зарезервированного товара..."
  {&display-message}.
  if auto-fbr then do:
    _buf_sale-doc:
    for each buf_sale-doc where
            buf_sale-doc.inkas-code = buf_trn-doc.doc-code
        and buf_sale-doc.order > 0
    by buf_sale-doc.order:
      if buf_sale-doc.doc-kind = {&tdEDT_ras_vnesh_kass}
      or buf_sale-doc.doc-kind = {&tdEDT_vozvrat_vnesh_kass} then do:
        for each buf_gds-dtl no-lock where
                  buf_gds-dtl.doc-code = buf_sale-doc.doc-code
            AND buf_gds-dtl.doc-qnty <> buf_gds-dtl.fact-qnty,
          first buf_goods no-lock where
                buf_goods.artic = buf_gds-dtl.artic
            AND buf_goods.prod-type = buf_gds-dtl.prod-type
            AND buf_goods.prod-code = buf_gds-dtl.prod-code:
          if is-gas(buf_goods.gds-code) then next.
          RUN gds-attr-value (
                              INPUT buf_goods.gds-code,
                              INPUT {&attr-mark-type},
                              OUTPUT v-attr-value,
                              OUTPUT v-type
                              ).
          if v-attr-value > ""
          and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_trn-doc.obj-type, buf_trn-doc.obj-code):GetIsMarkingForType(v-attr-value) 
          then do :
            next .
          end .
          { gbl/fgdsobjt.i buf_gds-dtl.obj-type buf_gds-dtl.obj-code buf_goods.gds-code "'is-dish=request,is-modificator=request'" v-is-dish no-error }
          if error-status:error or lookup('1':U, v-is-dish) = 0 then do:
            assign
            b-close-enabled = no
            .
            run waitfram-hide in this-procedure .
            return.
          end.
        end.
      end. /*расход или возврат*/
      else do:
        if buf_sale-doc.doc-kind = {&sale-add-return-write-off} then do:
          NEXT _buf_sale-doc.
        end.
        if buf_sale-doc.doc-kind = {&sale-add-tech-refuell} then do:
          find first buf_gds-dtl NO-LOCK where
                          buf_gds-dtl.doc-code = buf_sale-doc.doc-code
                      AND buf_gds-dtl.doc-qnty <> buf_gds-dtl.fact-qnty USE-INDEX pi no-error .
          if available buf_gds-dtl
          then do:
            find first buf_goods no-lock where
                  buf_goods.artic = buf_gds-dtl.artic
              AND buf_goods.prod-type = buf_gds-dtl.prod-type
              AND buf_goods.prod-code = buf_gds-dtl.prod-code .
            RUN gds-attr-value (
                                INPUT buf_goods.gds-code,
                                INPUT {&attr-mark-type},
                                OUTPUT v-attr-value,
                                OUTPUT v-type
                                ).
            if v-attr-value > ""
            and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_trn-doc.obj-type, buf_trn-doc.obj-code):GetIsMarkingForType(v-attr-value) 
            then do :
              
            end .
            else
            if not is-gas(buf_goods.gds-code)
            then do :
              assign
              b-close-enabled = no
              .
              run waitfram-hide in this-procedure .
              return.
            end.
          end.
        end.
      end.
    end. /*for each buf_sale-doc */
  end. /*if auto-fbr then do:*/
  else do:
    _buf_sale-doc2:
    for each buf_sale-doc where
           buf_sale-doc.inkas-code = buf_trn-doc.doc-code
       and buf_sale-doc.order > 0
    by buf_sale-doc.order:
      if buf_sale-doc.doc-kind = {&sale-add-return-write-off} then do:
        next _buf_sale-doc2.
      end.
      /*случай расходная накладная и ТПСИ*/
      if buf_sale-doc.doc-code = buf_trn-doc.doc-code
      and p-is-tpsi-obj
      then do:
        _tt:
        for each buf_Doc-line no-lock where
                buf_doc-line.doc-code = buf_trn-doc.doc-code:
          find first tt0-doc-line no-lock where
                tt0-doc-line.artic     = buf_doc-line.artic
            AND tt0-doc-line.prod-type = buf_doc-line.prod-type
            AND tt0-doc-line.prod-code = buf_doc-line.prod-code no-error .
            /*флаг оператора*/
          if p-neg-tpsi-oper
          and available tt0-doc-line
          and not (tt0-doc-line.obj-type = buf_doc-line.obj-type
              and tt0-doc-line.obj-code = buf_doc-line.obj-code)
          and can-find(first dtl-rests-mark where
                            dtl-rests-mark.artic = buf_doc-line.artic
                        and dtl-rests-mark.prod-type = buf_doc-line.prod-type
                        and dtl-rests-mark.prod-code = buf_doc-line.prod-code) then do:
            next  _tt.
          END.
          if  buf_doc-line.fact-qnty <= buf_doc-line.doc-qnty + (if available tt0-doc-line
                                                                then (tt0-doc-line.doc-qnty +  p-neg-tpsi-qnty)
                                                                else 0)
                                                                then do:
            next  _tt.

          end.
          if p-neg-tpsi-weight then do:
            find first buf_goods no-lock where
                    buf_goods.artic = buf_doc-line.artic
                AND buf_goods.prod-type = buf_doc-line.prod-type
                AND buf_goods.prod-code = buf_doc-line.prod-code .
            find first buf_units no-lock where
                        buf_units.unit-name = buf_goods.unit-base.
            if lookup({&weight}, buf_units.type) > 0 then do:
              next _tt.
            end.
          end. /*         if p-neg-tpsi-weight then do:*/
          /*
          if  buf_doc-line.fact-qnty < buf_doc-line.doc-qnty + (if available tt0-doc-line
          */
          b-close-enabled = no.
          run waitfram-hide in this-procedure .
          return.
        end. /*должны пробежать по всем товарам и сравнить количества по заререзвированным у нас и на объектах ТПСИ*/
      end. /*TPSI*/
      /*обычная ситуация*/
      else do:
        _gds-dtl:
        for each buf_gds-dtl NO-LOCK where
                    buf_gds-dtl.doc-code = buf_sale-doc.doc-code
                AND buf_gds-dtl.doc-qnty <> buf_gds-dtl.fact-qnty USE-INDEX pi :
          find first goods no-lock where goods.artic = buf_gds-dtl.artic
                                     and goods.prod-type = buf_gds-dtl.prod-type
                                     and goods.prod-code = buf_gds-dtl.prod-code
                                     .
          RUN gds-attr-value (
                              INPUT goods.gds-code,
                              INPUT {&attr-mark-type},
                              OUTPUT v-attr-value,
                              OUTPUT v-type
                              ).
          if v-attr-value > ""
          and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_trn-doc.obj-type, buf_trn-doc.obj-code):GetIsMarkingForType(v-attr-value) 
          then do :
            next _gds-dtl .
          end .
          if buf_sale-doc.doc-kind = {&tdEDT_vozvrat_vnesh_kass} 
          then do :
            find first doc-fbr-gds no-lock where doc-fbr-gds.out-code = replace(buf_gds-dtl.doc-code, "=", "-")
                                             and doc-fbr-gds.gds-code = goods.gds-code
                                             no-error .
          end.
          if buf_sale-doc.doc-kind = {&tdEDT_ras_vnesh_kass} 
          then do :
            find first doc-fbr-gds no-lock where doc-fbr-gds.out-code = buf_gds-dtl.doc-code
                                             and doc-fbr-gds.gds-code = goods.gds-code
                                             no-error .
          end.
          if available doc-fbr-gds
          then do :
            next. /* Для производства проверки в резервировании */
          end.
          assign
          b-close-enabled = no
          .
          run waitfram-hide in this-procedure .
          return.
        end.
      end.
    END. /*do v-doc-ii*/
  end. /*no auto-fbr*/
end.
assign
b-close-enabled = yes.
run waitfram-hide in this-procedure .
END. /*button-close*/