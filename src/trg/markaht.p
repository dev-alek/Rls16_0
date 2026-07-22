block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ѕометить складской архив по типам приобретени€, как требующий перерасчета с определенной даты

јвтор: „ернова —ветлана јлександровна
ƒата создани€: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

јвтор1: ѕерваков ћихаил —ергеевич
ƒата создани€: 07/01/02

*/

define input  parameter p-obj-type  as character no-undo .
define input  parameter p-obj-code  as integer   no-undo .
define input  parameter p-fact-date as date      no-undo .
define input  parameter p-doc-code  as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "ѕометить складской архив по типам приобретени€, как требующий перерасчета с определенной даты".
{ cmp/vssrevis.i "substitute('&1|&2|&3',p-obj-type,p-obj-code,p-fact-date)" }
{ cmp/trg-def.i  }
{ gbl/clntattr.i }

do
on error undo, return error return-value
:
  define buffer calc-aht-lock_batchprocess for ub.batchprocess .

  run gbl/lock-prc.p
    (input {&lock-prc-calc-aht}
    ,input p-obj-code
    ,input 0
    ,input 0
    ,input p-obj-type
    ,input ""
    ,input ""
    ,input "ќбъект,,, ,,,–асчет складского архива по типам приобретени€"
    ,input true
    ,buffer calc-aht-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "¬ данный момент рассчитываетс€ складской архив по типам приобретени€" skip
      "Ќевозможно произвести пометить складской архив по типам приобретени€, как требующий перерасчета" skip
      view-as alert-box error .
    undo, return error .
  end.

  /* провер€ем, возможно складской архив по типам приобретени€ уже требуют перерасчета */
  define variable v-aht-recalc      as character no-undo .
  define variable v-attr-type       as character no-undo .
  define variable v-aht-recalc-date as date      no-undo .

  assign
    v-aht-recalc-date = ?
  .
  run clntattr-value in this-procedure
    (input  p-obj-type                 /* p-obj-type */
    ,input  p-obj-code                 /* p-obj-code */
    ,input  {&attr-aht-recalc-date}    /* p-code     */
    ,output v-aht-recalc               /* p-value    */
    ,output v-attr-type                /* p-type     */
    ) .
  if v-aht-recalc <> ""
  then do:
    assign
      v-aht-recalc-date = date(v-aht-recalc)
    .
  end.

  if  v-aht-recalc-date <> ?
  and v-aht-recalc-date < p-fact-date
  then do:
    /* складской архив по типам приобретени€ уже помечен, как требующие перерасчета */
    return . /* --->>>--- */
  end.

  define variable v-create-chip-num as integer   no-undo .

  run utl/arhiscr.p
    (input  p-obj-type                    /* p-obj-type              */
    ,input  p-obj-code                    /* p-obj-code              */
    ,input  {&btpr-type-aht}              /* p-archive-type          */
    ,input  {&archive-history-set-recalc} /* p-action-type           */
    ,input  ""                            /* p-file-name             */
    ,input  ""                            /* p-file-md5              */
    ,input  0                             /* p-file-invalid-chip-num */
    ,input  {&table_trn-doc}              /* p-source-type           */
    ,input  p-doc-code                    /* p-source-ref            */
    ,input  p-fact-date                   /* p-source-date           */
    ,output v-create-chip-num             /* p-create-chip-num       */
    ) .

  /* устанавливаем признак того, что требуетс€ перерасчет складского архива по типам приобретени€ */
  run clntattr-write in this-procedure
    (input p-obj-type                          /* p-obj-type */
    ,input p-obj-code                          /* p-obj-code */
    ,input {&attr-aht-recalc-date}             /* p-code     */
    ,input string(p-fact-date, '99/99/9999':U) /* p-value    */
    ) .

end.