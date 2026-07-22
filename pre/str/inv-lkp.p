block-level on error undo, throw.
define input  parameter parparentproc as handle    no-undo.
define input  parameter p-doc-code    as character no-undo .
define input  parameter p-artic       as character no-undo .
define input  parameter p-prod-type   as character no-undo .
define input  parameter p-prod-code   as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: inv-lkp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/inv-lkp.p $":U .
define variable vss-description as character no-undo init "Просмотр строки инвентаризации".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer buf_doc-line for ub.doc-line .
define buffer buf_goods    for ub.goods .
define buffer buf_units    for ub.units .
define buffer buf_gds-prt  for ub.gds-prt .
define buffer buf_trn-doc  for ub.trn-doc .
define variable varprt-rec as recid no-undo.
do
on error undo, return error return-value
:
  find first buf_doc-line no-lock
    where buf_doc-line.doc-code  = p-doc-code
      and buf_doc-line.artic     = p-artic
      and buf_doc-line.prod-type = p-prod-type
      and buf_doc-line.prod-code = p-prod-code
    no-error .
  if not available buf_doc-line
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при задании входных параметров" skip
      "Не найдена строка документа" skip
      "Документ" p-doc-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = buf_doc-line.doc-code
    .
  find buf_goods no-lock
    where buf_goods.artic     = buf_doc-line.artic
      and buf_goods.prod-type = buf_doc-line.prod-type
      and buf_goods.prod-code = buf_doc-line.prod-code
    .
  find first buf_units no-lock
    where buf_units.unit-name = buf_goods.unit-base
    .
  find buf_gds-prt no-lock
    where buf_gds-prt.upper-code = buf_goods.prt-root
    .
  if lookup('2ед':U, buf_units.type) > 0
  then do:
    run str/parts-l.w
      (input  parparentproc
      ,input  buf_trn-doc.obj-type
      ,input  buf_trn-doc.obj-code
      ,input  buf_goods.gds-code
      ,input  buf_doc-line.doc-code
      ,input  'ПРОСМОТР':U
      ,input  'документ':U
      ,input  'текущий':U
      ,input  'документ':U
      ,output varprt-rec
      ) .
  end.
  else do:
    if buf_gds-prt.node-name = '_Пустая шкала':U
    then do:
      run str/inv-prt.w
        (input  parparentproc
        ,input  recid(buf_trn-doc)
        ,input  recid(buf_doc-line)
        ,input  recid(buf_goods)
        ,input  'ПРОСМОТР':U
        ,input  recid(buf_gds-prt)
        ,input  'корн':U
        ).
    end.
    else do:
      run str/inv-p.p
        (input  parparentproc
        ,input  recid(buf_trn-doc)
        ,input  recid(buf_doc-line)
        ,input  recid(buf_goods)
        ,input  'ПРОСМОТР':U
        ).
    end.
  end.
end.
