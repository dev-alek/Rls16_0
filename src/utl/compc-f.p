block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: compc-f.p $
$Archive: utl/compc-f.p $

Проверка соответствия полей с- с полями исходных таблиц

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/11/06
Author: Bakhtadze Natalya
Creation date: 04/11/06

*/


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: compc-f.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/compc-f.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }


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
    v-property-value = if loc_field._initial = ? then {&question-mark} else loc_field._initial
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
    v-property-value = if loc_field._decimals = ? then {&question-mark} else string(loc_field._decimals)
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
    v-msg = "Не найдена исходная таблица к таблице" + {&space-char} + buf2_file._file-name
    .
    run write-err in this-procedure (v-msg).
    assign
    v-msg = "Ошибка в таблице" + {&space-char} + buf2_file._file-name
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
      v-msg = "Не найдено поле" + {&space-char} + buf1_field._field-name + {&space-char} +
              "в таблице" + {&space-char} + buf2_file._file-name
      .
      run write-err in this-procedure (v-msg).
      assign
      v-msg = "Ошибка в таблице" + {&space-char} + buf2_file._file-name
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
        v-field-failed = v-field-failed + {&new-line} +
                        "реквизит" + {&space-char} + entry(jj, v-field-result) + {&space-char} +
                        get-property(buffer buf2_field, entry(jj, v-field-result)) + {&space-char} + "должно быть" + {&space-char} +
                        get-property(buffer buf1_field, entry(jj, v-field-result))
        .
      end.
      assign
      v-msg = "Ошибка в поле" + {&space-char} + buf2_field._field-name +
              "в таблице" + {&space-char} + buf2_file._file-name + {&new-line} + v-field-failed
      .
      run write-err in this-procedure (v-msg).
      assign
      v-msg = "Ошибка в таблице" + {&space-char} + buf2_file._file-name +
              {&space-char} + "поле" + {&space-char} + buf2_field._field-name
      .
      run write-log in this-procedure (v-msg).
      next _ffield.
    end. /*not buffer-compare*/
  end. /*for ech buf2_field*/
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


end procedure. /* write-err */


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

end procedure. /* write-log */

procedure set-file-title :
define input parameter p-filename as character no-undo.

define variable v-today as date no-undo.
define variable v-time as integer no-undo.


output stream logstream to value(p-filename) append.
/*run cur-time in this-procedure(output v-today, output v-time).*/
put stream logstream unformatted
"**************************************************" skip
"user:":u g#userid skip
string(today, "99/99/9999") {&space-char} string(time, "hh:mm:ss")
skip.
output stream logstream close.

end procedure.