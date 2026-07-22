block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: corfd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/corfd.p $":U .
define variable vss-description as character no-undo init "Исправление даты-факт для незакрытого документа".
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
define variable  p-doc-code as character no-undo .
run gbl/d-prompt.w (
    'title=Корректировка факт-даты\'
        + 'text1=':U + "Введите номер документа" + '\':u
        + 'format=' + "X(20)" + '\':u
        + 'type=C\':u
  + 'fillin_width=20\'
  + 'fillin_height=1\'
  , input-output p-doc-code).
define buffer buf_trn-doc for ub.trn-doc  .
find first buf_trn-doc exclusive-lock where
           buf_trn-doc.doc-code = p-doc-code  no-error .
if not available buf_trn-doc then do:
   message
   "Не найден документ с номером" p-doc-code
   view-as alert-box information .
   return .
end.
if buf_trn-doc.status_ = 'факт':U  then do:
   message
   "Документ с номером" p-doc-code "закрыт на ФАКТ"
   view-as alert-box information .
   return .
end.
assign
  buf_trn-doc.fact-date = ?
  buf_trn-doc.fact-num = 0
  buf_trn-doc.fact-order = 0
.
message "Все"
   view-as alert-box information .
   return .
