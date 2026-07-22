block-level on error undo, throw.
define input  parameter parparentproc as widget-handle no-undo .
define output parameter p-ok as logical   no-undo .
define output parameter p-mess as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка при включении профайла 42 - импорт клиентов из Oracle Retail".
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
define variable v-last-code as integer no-undo .
define buffer buf_code-range for ub.code-range.
find first buf_code-range no-lock where
        buf_code-range.range-type = 'bcgb':U
      and buf_code-range.db-num > 0 no-error.
if available buf_code-range then do:
  p-mess = substitute("Нельзя включить профайл - существуют диапазоны бар-кодов, привязанные к УБД").
  return ''.
end.
find first buf_code-range no-lock where
        buf_code-range.range-type = 'bcgb':U
      and buf_code-range.db-num < 0 no-error.
if available buf_code-range then do:
  p-mess = substitute("Нельзя включить профайл - существуют диапазоны бар-кодов, непривязанные к БД").
  return ''.
end.
v-last-code = -1.
for each buf_code-range no-lock where
        buf_code-range.range-type = 'bcgb':U
by buf_code-range.first-code:
   if v-last-code >= 0
   and buf_code-range.first-code + 1 < v-last-code  then do:
     p-mess = substitute("Нельзя включить профайл - существуют <ДЫРКИ> в последовательности диапазонов бар-кодов").
     return ''.
   end.
   if buf_code-range.stts <> 'U' then do:
     p-mess = substitute("Нельзя включить профайл - существуют диапазоны бар-кодов со статусом &1", buf_code-range.stts).
     return ''.
   end.
   assign
   v-last-code = buf_code-range.last-code
   .
end.
