block-level on error undo, throw.
define input parameter fld as character no-undo .
define input parameter lab as character no-undo .
define input parameter spr as character no-undo .
define input parameter dim as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fltcreat.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/fltcreat.p $":U .
define variable vss-description as character no-undo init "Утилита для автоматического создания кода процедуры init-flt".
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
define stream ff .
define variable for-file as character no-undo .
define variable v-ind    as integer   no-undo .
define variable for-fld  as character no-undo .
define variable for-lab  as character no-undo .
define variable for-spr  as character no-undo .
run gbl/d-prompt.w (
    'title=':u + "Имя файла" + '\':u
  + 'text1=':u + "Введите имя файла для вывода " + '\':u
  + 'text2=':u + "кода инициализации фильтра" + '\':u
  + 'format=' + 'x(256)':u + '\':u
  + 'type=char\':u
  + 'boxprog=getfile.p\':u
  ,input-output for-file
  ).
if return-value = 'false':u then do:
  return .
end.
if num-entries(fld) <> dim then do:
    message "Неверный входной параметр 1" skip
    "fld=" num-entries(fld) "dim=" dim
    view-as alert-box ERROR.
    return.
end.
if num-entries(spr) <> dim then do:
    message "Неверный входной параметр 3" skip
    "spr=" num-entries(spr) "dim=" dim
    view-as alert-box ERROR.
    return.
end.
if num-entries(lab) <> dim then do:
    message "Неверный входной параметр 2" skip
    "lab=" num-entries(lab) "dim=" dim
    view-as alert-box ERROR.
    return.
end.
output stream ff to value(for-file).
do v-ind = 1 to dim:
  assign
  for-fld = entry(v-ind, fld)
  for-lab = entry(v-ind, lab)
  for-spr = entry(v-ind, spr)
  no-error.
  PUT STREAM ff unformatted
  "run fltfield-add in this-procedure("
  ( chr(39) + for-fld + chr(39))
  ", ":u
  ( chr(39) + for-lab + chr(39))
  ", ":U
  ( chr(39) + for-spr + chr(39))
  ", ":U skip
  "input-output fld, input-output lab, input-output spr, input-output dim)  no-error."
  skip.
end.
output stream ff close.
