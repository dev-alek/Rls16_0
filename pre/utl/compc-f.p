block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: compc-f.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/compc-f.p $":U .
define variable vss-description as character no-undo init "".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable loc#log as logical no-undo .
define variable v-msg as character no-undo .
define variable v-silence as logical no-undo init yes.
define variable v-log-file as character no-undo .
define variable v-err-file as character no-undo .
define variable v-field-result as character no-undo .
define variable v-field-failed as character no-undo .
define variable jj as integer no-undo .
define buffer buf1_file for _file.
define buffer buf2_file for _file.
define buffer buf1_field for _field.
define buffer buf2_field for _field.
define stream logstream.
function get-property returns character  ( buffer loc_field for _field, input p-property-name as character ) :
define variable v-property-value as character no-undo .
case p-property-name:
  when "_data-type" then do:
    assign
    v-property-value = loc_field._data-type
    .
  end.
  when "_dtype" then do:
    assign
    v-property-value = string(loc_field._dtype)
    .
  end.
  when "_initial" then do:
    assign
    v-property-value = if loc_field._initial = ? then chr(63) else loc_field._initial
    .
  end.
  when "_label" then do:
    assign
    v-property-value = loc_field._label
    .
  end.
  when "_mandatory" then do:
    assign
    v-property-value = if loc_field._mandatory then "yes" else "no"
    .
  end.
  when "_decimals" then do:
    assign
    v-property-value = if loc_field._decimals = ? then chr(63) else string(loc_field._decimals)
    .
  end.
  when "_desc" then do:
    assign
    v-property-value = loc_field._desc
    .
  end.
end case.
return v-property-value.
end function.
message
"Вы действительно хотите сравнить структуры таблиц,"
"в которых хранятся документы и удаленные документы"
view-as alert-box question buttons yes-no update loc#log.
if not loc#log then do:
  return.
end.
message
"Сооьщать о каждой обнаруженной ошибке или выводить результаты сравнения только в log и err"
"в которых хранятся документы и удаленные документы"
view-as alert-box question buttons yes-no update loc#log.
if not loc#log then do:
  assign
  v-silence = no
  .
end.
assign
v-log-file = "compc-f.log"
v-err-file = "compc-f.err"
.
run set-file-title in this-procedure (v-log-file).
run set-file-title in this-procedure (v-err-file).
for each buf2_file no-lock where
         buf2_file._file-name begins "c-":u:
  find first buf1_file no-lock where
             buf1_file._file-name = substr(buf2_file._file-name, 3) no-error .
  if not available buf1_file then do:
    assign
    v-msg = "Не найдена исходная таблица к таблице" + chr(32) + buf2_file._file-name
    .
    run write-err in this-procedure (v-msg).
    assign
    v-msg = "Ошибка в таблице" + chr(32) + buf2_file._file-name
    .
    run write-log in this-procedure (v-msg).
    next.
  end.
  _ffield:
  for each buf1_field no-lock where
           buf1_field._file-recid = recid(buf1_file):
    find first buf2_field no-lock where
               buf2_field._file-recid = recid(buf2_file)
          and buf2_field._field-name = buf1_field._field-name no-error .
    if not available buf2_field then do:
      assign
      v-msg = "Не найдено поле" + chr(32) + buf1_field._field-name + chr(32) +
              "в таблице" + chr(32) + buf2_file._file-name
      .
      run write-err in this-procedure (v-msg).
      assign
      v-msg = "Ошибка в таблице" + chr(32) + buf2_file._file-name
      .
      run write-log in this-procedure (v-msg).
      next _ffield.
    end.
    assign
    v-field-result = "":u
    .
    buffer-compare buf1_field using
    _data-type _dtype _mandatory _decimals
    to buf2_field
    save result in v-field-result no-error .
    if v-field-result <> "":u then do:
      do jj = 1 to num-entries(v-field-result):
        assign
        v-field-failed = v-field-failed + chr(10) +
                        "реквизит" + chr(32) + entry(jj, v-field-result) + chr(32) +
                        get-property(buffer buf2_field, entry(jj, v-field-result)) + chr(32) + "должно быть" + chr(32) +
                        get-property(buffer buf1_field, entry(jj, v-field-result))
        .
      end.
      assign
      v-msg = "Ошибка в поле" + chr(32) + buf2_field._field-name +
              "в таблице" + chr(32) + buf2_file._file-name + chr(10) + v-field-failed
      .
      run write-err in this-procedure (v-msg).
      assign
      v-msg = "Ошибка в таблице" + chr(32) + buf2_file._file-name +
              chr(32) + "поле" + chr(32) + buf2_field._field-name
      .
      run write-log in this-procedure (v-msg).
      next _ffield.
    end.
  end.
end.
procedure write-err :
define input parameter p-msg as character no-undo .
  do
  on error undo, return error
  :
    if not v-silence then do:
      message
      p-msg
      view-as alert-box error .
    end.
    if v-err-file <> "":u then do:
      output stream logstream to value(v-err-file) append.
      put stream logstream unformatted
      p-msg skip.
      output stream logstream close.
    end.
  end.
end procedure.
procedure write-log :
define input parameter p-msg as character no-undo .
  do
  on error undo, return error
  :
    if not v-silence then do:
      message
      p-msg
      view-as alert-box error .
    end.
    if v-log-file <> "":u then do:
      output stream logstream to value(v-log-file) append.
      put stream logstream unformatted
      p-msg skip.
      output stream logstream close.
    end.
  end.
end procedure.
procedure set-file-title :
define input parameter p-filename as character no-undo.
define variable v-today as date no-undo.
define variable v-time as integer no-undo.
output stream logstream to value(p-filename) append.
put stream logstream unformatted
"**************************************************" skip
"user:":u g#userid skip
string(today, "99/99/9999") chr(32) string(time, "hh:mm:ss")
skip.
output stream logstream close.
end procedure.
