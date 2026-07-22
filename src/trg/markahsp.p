block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Пометить складской архив по поставщикам, как требующий перерасчета с определенной даты

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 07/01/02

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
define variable vss-description as character no-undo init "Пометить складской архив по поставщикам, как требующий перерасчета с определенной даты".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/clntattr.i }


do
on error undo, return error return-value
:
  define buffer calc-supp-arh-lock_batchprocess for ub.batchprocess .

  run gbl/lock-prc.p
    (input {&lock-prc-calc-supp-arh}
    ,input p-obj-code
    ,input 0
    ,input 0
    ,input p-obj-type
    ,input ""
    ,input ""
    ,input "Объект,,, ,,,Расчет складского архива по поставщикам"
    ,input true
    ,buffer calc-supp-arh-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "В данный момент рассчитывается складской архив по поставщикам" skip
      "Невозможно пометить складской архив по поставщикам, как требующий перерасчета" skip
      view-as alert-box error .
    undo, return error .
  end.

  /* проверяем, возможно складской архив по поставщикам уже требуют перерасчета */
  define variable v-ahsp-recalc      as character no-undo .
  define variable v-attr-type        as character no-undo .
  define variable v-ahsp-recalc-date as date      no-undo .

  assign
    v-ahsp-recalc-date = ?
  .
  run clntattr-value in this-procedure
    (input  p-obj-type               /* p-obj-type */
    ,input  p-obj-code               /* p-obj-code */
    ,input  {&attr-ahsp-recalc-date} /* p-code     */
    ,output v-ahsp-recalc            /* p-value    */
    ,output v-attr-type              /* p-type     */
    ) .
  if v-ahsp-recalc <> ""
  then do:
    assign
      v-ahsp-recalc-date = date(v-ahsp-recalc)
    .
  end.

  if  v-ahsp-recalc-date <> ?
  and v-ahsp-recalc-date < p-fact-date
  then do:
    /* складской архив по поставщикам уже помечен, как требующие перерасчета */
    return . /* --->>>--- */
  end.

  define variable v-create-chip-num as integer   no-undo .

  run utl/arhiscr.p
    (input  p-obj-type                    /* p-obj-type              */
    ,input  p-obj-code                    /* p-obj-code              */
    ,input  {&btpr-type-ahsp}             /* p-archive-type          */
    ,input  {&archive-history-set-recalc} /* p-action-type           */
    ,input  ""                            /* p-file-name             */
    ,input  ""                            /* p-file-md5              */
    ,input  0                             /* p-file-invalid-chip-num */
    ,input  {&table_trn-doc}              /* p-source-type           */
    ,input  p-doc-code                    /* p-source-ref            */
    ,input  p-fact-date                   /* p-source-date           */
    ,output v-create-chip-num             /* p-create-chip-num       */
    ) .

  /* устанавливаем признак того, что требуется перерасчет складского архива по поставщикам */
  run clntattr-write in this-procedure
    (input p-obj-type                          /* p-obj-type */
    ,input p-obj-code                          /* p-obj-code */
    ,input {&attr-ahsp-recalc-date}            /* p-code     */
    ,input string(p-fact-date, '99/99/9999':U) /* p-value    */
    ) .

end.