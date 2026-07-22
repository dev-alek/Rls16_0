block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: arhiscr.p $
$Archive: utl/arhiscr.p $

Создание истории по сохранению архива

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 02/19/04

*/

define input  parameter p-obj-type              as character no-undo .
define input  parameter p-obj-code              as integer   no-undo .
define input  parameter p-archive-type          as character no-undo .
define input  parameter p-action-type           as character no-undo .
define input  parameter p-file-name             as character no-undo .
define input  parameter p-file-md5              as character no-undo .
define input  parameter p-file-invalid-chip-num as integer   no-undo .
define input  parameter p-source-type           as character no-undo .
define input  parameter p-source-ref            as character no-undo .
define input  parameter p-source-date           as date      no-undo .
define output parameter p-create-chip-num       as integer   no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: arhiscr.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/arhiscr.p $":U .
define variable vss-description as character no-undo initial "Создание истории по сохранению архива".
{ cmp/vssrevis.i "substitute('&1|&2':u,substitute('&1|&2|&3|&4|&5':u,p-obj-type,p-obj-code,p-archive-type,p-action-type,p-file-name),substitute('&1|&2|&3|&4|&5':u,p-file-md5,p-file-invalid-chip-num,p-source-type,p-source-ref,p-source-date))" }
{ cmp/trg-def.i  }
{ gbl/clntattr.i }
{ gbl/arhisatr.i }

define buffer buf_archive-history for ub.archive-history .

do
on error undo, return error return-value
:
  define variable v-chip-num as integer   no-undo .

  find last buf_archive-history exclusive-lock
    where buf_archive-history.obj-type     = p-obj-type
      and buf_archive-history.obj-code     = p-obj-code
      and buf_archive-history.archive-type = p-archive-type
    use-index pi
    no-error .
  if available buf_archive-history
  then do:
    assign
      v-chip-num = buf_archive-history.chip-num + 1
    .
  end.
  else do:
    assign
      v-chip-num = 1
    .
  end.

  if  p-file-name <> ""
  and p-file-name <> ?
  then do:
    /* может быть только один файл с указанным имененм */
    /* который можно будет затем загружать */
    for each buf_archive-history exclusive-lock
      where buf_archive-history.obj-type     = p-obj-type
        and buf_archive-history.obj-code     = p-obj-code
        and buf_archive-history.archive-type = p-archive-type
        and buf_archive-history.file-valid   = true
        and buf_archive-history.file-name    = p-file-name
    on error undo, return error return-value
    :
      assign
        buf_archive-history.file-valid            = false
        buf_archive-history.file-invalid-chip-num = v-chip-num
      .
    end.
  end.

  assign
    p-create-chip-num = v-chip-num
  .

  create buf_archive-history .
  assign
    buf_archive-history.obj-type     = p-obj-type
    buf_archive-history.obj-code     = p-obj-code
    buf_archive-history.archive-type = p-archive-type
    buf_archive-history.chip-num     = v-chip-num
    buf_archive-history.action-type  = p-action-type
  .

  define variable v-attr-name-calc        as character no-undo .
  define variable v-attr-name-del         as character no-undo .
  define variable v-attr-name-rest        as character no-undo .
  define variable v-attr-name-start-date  as character no-undo .
  define variable v-attr-name-detail-date as character no-undo .
  define variable v-attr-name-recalc-date as character no-undo .

  define variable v-attr-value as character no-undo .
  define variable v-attr-type  as character no-undo .

  define variable v-arh-calc        as logical   no-undo .
  define variable v-arh-del         as logical   no-undo .
  define variable v-arh-disable     as logical   no-undo .
  define variable v-arh-rest        as logical   no-undo .
  define variable v-arh-start-date  as date      no-undo .
  define variable v-arh-detail-date as date      no-undo .
  define variable v-arh-recalc-date as date      no-undo .

  run get-attr-name in this-procedure
    (input  p-archive-type          /* p-archive-type          */
    ,output v-attr-name-calc        /* p-attr-name-calc        */
    ,output v-attr-name-del         /* p-attr-name-del         */
    ,output v-attr-name-rest        /* p-attr-name-rest        */
    ,output v-attr-name-start-date  /* p-attr-name-start-date  */
    ,output v-attr-name-detail-date /* p-attr-name-detail-date */
    ,output v-attr-name-recalc-date /* p-attr-name-recalc-date */
    ) .

  run clntattr-value in this-procedure
    (input  p-obj-type       /* p-obj-type */
    ,input  p-obj-code       /* p-obj-code */
    ,input  v-attr-name-calc /* p-code     */
    ,output v-attr-value     /* p-value    */
    ,output v-attr-type      /* p-type     */
    ) .
  assign
    v-arh-calc = (lookup(v-attr-value, 'yes,true') > 0)
  .

  run clntattr-value in this-procedure
    (input  p-obj-type      /* p-obj-type */
    ,input  p-obj-code      /* p-obj-code */
    ,input  v-attr-name-del /* p-code     */
    ,output v-attr-value    /* p-value    */
    ,output v-attr-type     /* p-type     */
    ) .
  assign
    v-arh-del = (lookup(v-attr-value, 'yes,true') > 0)
  .

  run clntattr-value in this-procedure
    (input  p-obj-type       /* p-obj-type */
    ,input  p-obj-code       /* p-obj-code */
    ,input  v-attr-name-rest /* p-code     */
    ,output v-attr-value     /* p-value    */
    ,output v-attr-type      /* p-type     */
    ) .
  assign
    v-arh-rest = (lookup(v-attr-value, 'yes,true') > 0)
  .

  run clntattr-value in this-procedure
    (input  p-obj-type             /* p-obj-type */
    ,input  p-obj-code             /* p-obj-code */
    ,input  v-attr-name-start-date /* p-code     */
    ,output v-attr-value           /* p-value    */
    ,output v-attr-type            /* p-type     */
    ) .
  assign
    v-arh-start-date = date(v-attr-value)
  .

  run clntattr-value in this-procedure
    (input  p-obj-type              /* p-obj-type */
    ,input  p-obj-code              /* p-obj-code */
    ,input  v-attr-name-detail-date /* p-code     */
    ,output v-attr-value            /* p-value    */
    ,output v-attr-type             /* p-type     */
    ) .
  assign
    v-arh-detail-date = date(v-attr-value)
  .

  run clntattr-value in this-procedure
    (input  p-obj-type              /* p-obj-type */
    ,input  p-obj-code              /* p-obj-code */
    ,input  v-attr-name-recalc-date /* p-code     */
    ,output v-attr-value            /* p-value    */
    ,output v-attr-type             /* p-type     */
    ) .
  assign
    v-arh-recalc-date = date(v-attr-value)
  .

  run arhisatr_encode-attr in this-procedure
    (input  v-arh-calc
    ,input  v-arh-del
    ,input  v-arh-disable
    ,input  v-arh-rest
    ,output buf_archive-history.archive-calc
    ,output buf_archive-history.archive-del
    ,output buf_archive-history.ps
    ) .

  assign
    buf_archive-history.archive-start-date  = v-arh-start-date
    buf_archive-history.archive-detail-date = v-arh-detail-date
    buf_archive-history.archive-recalc-date = v-arh-recalc-date
  .

  { gbl/curdburt.i
    buf_archive-history.corr-user-db-num
    buf_archive-history.corr-user-name
    buf_archive-history.corr-date
    buf_archive-history.corr-time-str
    buf_archive-history.corr-time
  }

  if  p-file-name <> ""
  and p-file-name <> ?
  then do:
    assign
      buf_archive-history.file-name  = p-file-name
      buf_archive-history.file-md5   = p-file-md5
      buf_archive-history.file-valid = true
    .
  end.

  assign
    buf_archive-history.file-invalid-chip-num = p-file-invalid-chip-num
    buf_archive-history.source-type           = p-source-type
    buf_archive-history.source-ref            = p-source-ref
    buf_archive-history.source-date           = p-source-date
  .
end.


procedure get-attr-name :

  define input  parameter p-archive-type          as character no-undo .
  define output parameter p-attr-name-calc        as character no-undo .
  define output parameter p-attr-name-del         as character no-undo .
  define output parameter p-attr-name-rest        as character no-undo .
  define output parameter p-attr-name-start-date  as character no-undo .
  define output parameter p-attr-name-detail-date as character no-undo .
  define output parameter p-attr-name-recalc-date as character no-undo .

  do
  on error undo, return error return-value
  :
    case p-archive-type
    :
      when {&btpr-type-arh}
      then do:
        assign
          p-attr-name-calc        = {&attr-arh-calc}
          p-attr-name-del         = {&attr-arh-del}
          p-attr-name-rest        = {&attr-arh-rest}
          p-attr-name-start-date  = {&attr-arh-start-date}
          p-attr-name-detail-date = {&attr-arh-detail-date}
          p-attr-name-recalc-date = {&attr-arh-recalc-date}
        .
      end.
      when {&btpr-type-ahsp}
      then do:
        assign
          p-attr-name-calc        = {&attr-ahsp-calc}
          p-attr-name-del         = {&attr-ahsp-del}
          p-attr-name-rest        = {&attr-ahsp-rest}
          p-attr-name-start-date  = {&attr-ahsp-start-date}
          p-attr-name-detail-date = {&attr-ahsp-detail-date}
          p-attr-name-recalc-date = {&attr-ahsp-recalc-date}
        .
      end.
      when {&btpr-type-aht}
      then do:
        assign
          p-attr-name-calc        = {&attr-aht-calc}
          p-attr-name-del         = {&attr-aht-del}
          p-attr-name-rest        = {&attr-aht-rest}
          p-attr-name-start-date  = {&attr-aht-start-date}
          p-attr-name-detail-date = {&attr-aht-detail-date}
          p-attr-name-recalc-date = {&attr-aht-recalc-date}
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестное значение параметра тип архива" skip
          "Тип архива" p-archive-type skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .
  end.

end procedure. /* get-attr-name */
