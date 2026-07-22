block-level on error undo, throw.
define input  parameter parparentproc as widget-handle no-undo.
define input  parameter p-doc-code    as character no-undo .
define input  parameter p-gds-code    as integer   no-undo .
define input  parameter p-node-code   as integer   no-undo .
define input  parameter p-mode        as character no-undo .
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: prt-edit.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/prt-edit.p $":U .
define variable vss-description as character no-undo initial "Вызов редактирования признака в расходной накладной".
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
    assign
      p-vss-parameters = substitute('&1|&2|&3|&4|&5':u,parparentproc,p-doc-code,p-gds-code,p-node-code,p-mode)
    .
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define buffer buf_gds-prt  for ub.gds-prt .
define buffer buf_goods    for ub.goods .
define buffer buf_doc-line for ub.doc-line .
do
on error undo, return error return-value
:
  find first buf_gds-prt no-lock
    where buf_gds-prt.node-code = p-node-code
    no-error .
  if not available buf_gds-prt
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  define new shared buffer t-doc for trn-doc .
  find first t-doc exclusive-lock
    where t-doc.doc-code = p-doc-code
    .
  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
    .
  find first buf_doc-line no-lock
    where buf_doc-line.doc-code  = p-doc-code
      and buf_doc-line.artic     = buf_goods.artic
      and buf_doc-line.prod-type = buf_goods.prod-type
      and buf_doc-line.prod-code = buf_goods.prod-code
    .
  run str/out-prt.w
    (input parparentproc
    ,input recid(t-doc)
    ,input recid(buf_doc-line)
    ,input recid(buf_goods)
    ,input p-mode
    ,input recid(buf_gds-prt)
    ,input 'терм':U
    ) no-error.
end.
