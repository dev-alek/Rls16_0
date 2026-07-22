block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exp-chk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/exp-chk.p $":U .
define variable vss-description as character no-undo init "Экспорт одного чека".
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
define stream docs.
define stream gdss.
define stream pays.
define stream discnts.
define stream attrs.
DEFINE VARIABLE v-doc-code like ub.chk-doc.doc-code no-undo .
DEFINE VARIABLE loc#log as logical no-undo .
do while true:
  run gbl/d-prompt.w (
    'title=':u + "Введите номер чека" + '\':u
  + 'text1=':u + "Номер чека" + '\':u
  + 'format=' + "X(20)" + '\':u
  + 'type=' + 'C':U + '\':u
  + 'fillin_row=2\':u
  + 'fillin_col=4\':u
  + 'fillin_width=20\':u
  + 'fillin_height=1\':u
  + 'max-chars=70\':u
  + 'readonly=no' + '\':u
  , input-output v-doc-code
  ).
  if return-value = 'false':u then return.
  find first ub.chk-doc no-lock where ub.chk-doc.doc-code = v-doc-code no-error .
  if avail ub.chk-doc then LEAVE.
  else do:
    message
    "Нет чека с номером" v-doc-code skip
    "Ввести другой номер?"
    view-as alert-box question button YES-NO update loc#log.
    if not loc#log then return.
  end.
end.
output stream docs to value(v-doc-code + ".doc").
output stream gdss to value(v-doc-code + ".gds").
output stream pays to value(v-doc-code + ".pay").
output stream discnts to value(v-doc-code + ".discnt").
output stream attrs to value(v-doc-code + ".attrs").
for each ub.chk-doc no-lock where
         ub.chk-doc.doc-code = v-doc-code:
  export stream docs chk-doc.
  for each ub.chk-gds no-lock where
           ub.chk-gds.doc-code = chk-doc.doc-code:
    export stream gdss chk-gds.
  end.
  for each ub.chk-pay no-lock where
           ub.chk-pay.doc-code = chk-doc.doc-code:
    export stream pays chk-pay.
  end.
  for each ub.chk-discnt no-lock where
           ub.chk-discnt.doc-code = chk-doc.doc-code:
    export stream discnts chk-discnt.
  end.
  for each ub.chk-doc-attr no-lock where
           ub.chk-doc-attr.doc-code = chk-doc.doc-code:
    export stream attrs chk-doc-attr.
  end.
end.
output stream docs close.
output stream gdss close.
output stream pays close.
output stream discnts close.
output stream attrs close.
message
"Содержимое чека экспортировано в файлы" string(v-doc-code + ".*":U)
view-as alert-box .
