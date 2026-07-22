/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры интерфейса, общие для истории платежа всех типов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/01/03
Author: Bakhtadze Natalya
Creation date: 12/01/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

ON CHOOSE OF B-contract-view IN FRAME Dialog-Frame /* Договор */
DO:
define variable g-log as logical no-undo.
 define variable ri as recid no-undo .
  if not avail X_contract then return no-apply.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-contract_lookup':U
    {&cntxt-firm}
    tt-c-fin-doc.host-code
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return .
  ri = recid( X_contract ).
  run str/sh-contr.p ( input parParentProc, input ri) no-error.
  if error-status:error then return no-apply.

END.


ON CHOOSE OF B-payer-view IN FRAME Dialog-Frame /* Плательщик */
DO:
    run ref/showcli.p
    (input parParentProc
    ,input tt-c-fin-doc.payer-type /* p-obj-type */
    ,input tt-c-fin-doc.payer-code /* p-obj-code */
    ).
END.

ON CHOOSE OF B-receiver-view IN FRAME Dialog-Frame /* Получатель */
DO:
     run ref/showcli.p
    (input parParentProc
    ,input tt-c-fin-doc.receiver-type /* p-obj-type */
    ,input tt-c-fin-doc.receiver-code /* p-obj-code */
    ).

END.

ON CHOOSE OF B-tax IN FRAME Dialog-Frame /* Налоги */
DO:
  run ref/fndocti.w (
                  INPUT parParentProc
                  ,input p-curr-host-code
                  ,input p-mode
                  ,input tt-c-fin-doc.host-code
                  ,input tt-c-fin-doc.fin-doc-code
                  ,input tt-c-fin-doc.fin-doc-type
                  ,input tt-c-fin-doc.fin-ext-doc-type
                  ,input tt-c-fin-doc.trn-doc-code
                  ,input tt-c-fin-doc.contract-code
                  ,input tt-c-fin-doc.sum-doc
                  ,input tt-c-fin-doc.curr-code
                  ,input tt-c-fin-doc.base-rate
                  ,input tt-c-fin-doc.base-scale
                  ,input tt-c-fin-doc.exch-rate
                  ,input tt-c-fin-doc.exch-scale
                  ,input tt-c-fin-doc.obj-type
                  ,input tt-c-fin-doc.obj-code
                  ,input-output table tt0-fin-doc-tax
                  ,input 0 /*chip-num в моде показа истории*/
                  ).
END.


PROCEDURE fill-tables :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_c-fin-doc-tax for ub.c-fin-doc-tax.
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.

for each buf_c-fin-doc-tax no-lock where
buf_c-fin-doc-tax.host-code = tt-c-fin-doc.host-code
AND buf_c-fin-doc-tax.fin-doc-code = tt-c-fin-doc.fin-doc-code
AND buf_c-fin-doc-tax.chip-num = tt-c-fin-doc.chip-num
 :
    create tt0-fin-doc-tax.
    buffer-copy buf_c-fin-doc-tax to tt0-fin-doc-tax.
end.

for each buf_c-fin-doc-attr no-lock where
buf_c-fin-doc-attr.host-code = tt-c-fin-doc.host-code
AND buf_c-fin-doc-attr.fin-doc-code = tt-c-fin-doc.fin-doc-code
AND buf_c-fin-doc-attr.chip-num = tt-c-fin-doc.chip-num
:
    create tt0-fin-doc-attr.
    buffer-copy buf_c-fin-doc-attr to tt0-fin-doc-attr.
end.

END PROCEDURE.


PROCEDURE hide-view-currency :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*сначала все похайдим*/
assign
v-rubf = no
v-exchf = no
v-basef = no
v-baseratef = no
v-contractf = no
v-contractratef = no
.

hide
tt-c-fin-doc.exch-rate in frame {&frame-name}
tt-c-fin-doc.exch-scale
tt-c-fin-doc.sum-rubl
tt-c-fin-doc.sum-base
tt-c-fin-doc.base-rate
tt-c-fin-doc.base-scale
tt-c-fin-doc.sum-contr
tt-c-fin-doc.contract-rate
tt-c-fin-doc.contract-scale
in frame {&frame-name} .
if tt-c-fin-doc.curr-code = 0
and v-base-code = 0
and
(tt-c-fin-doc.contract-code = 0
or tt-c-fin-doc.contract-curr = 0)
then do:
    return.
end.
if tt-c-fin-doc.curr-code <> 0 then do:
  if tt-c-fin-doc.curr-code:visible then
  display
  tt-c-fin-doc.exch-rate
  tt-c-fin-doc.exch-scale
  tt-c-fin-doc.sum-rubl
  with frame {&frame-name}.
  assign
  v-rubf = yes
  v-exchf = yes
  .
end.
if v-base-code <> 0 then do:
  if tt-c-fin-doc.curr-code:visible then
  display
  tt-c-fin-doc.base-rate
  tt-c-fin-doc.base-scale
  tt-c-fin-doc.sum-base
  with frame {&frame-name}.
  assign
  v-basef = yes
  v-baseratef = yes
  .
end.
if tt-c-fin-doc.contract-code  <> 0 and
  (tt-c-fin-doc.contract-curr <> 0  )
  then do:
    if tt-c-fin-doc.curr-code:visible then
    display
    tt-c-fin-doc.sum-contr
    tt-c-fin-doc.contract-rate
    tt-c-fin-doc.contract-scale
    with frame {&frame-name}.
  assign
  v-contractf = yes
  v-contractratef = yes
  .
end.
END PROCEDURE.


/* $Workfile$ e n d */