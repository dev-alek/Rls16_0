block-level on error undo, throw.
define input parameter p-os-err-number as integer no-undo .
define output parameter p-os-err-name as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: os-errnm.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/os-errnm.p $":U .
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
CASE p-os-err-number:
  when 0 then do:
    p-os-err-name = '':U.
  end.
  when 1 then do:
    p-os-err-name =  "Вы не имеет соответствующих прав на файл или директорию".
  end.
  when 2 then do:
    p-os-err-name =  "Нет такого файла или директории".
  end.
  when 3 then do:
    p-os-err-name =  "Неверный системный вызов".
  end.
  when 4 then do:
    p-os-err-name = "Ошибка ввода/вывода".
  end.
  when 5 then do:
    p-os-err-name = "Неверный номер файла".
  end.
  when 6 then do:
    p-os-err-name = "Нет свободных процессов".
  end.
  when 7 then do:
    p-os-err-name = "Нет свободной памяти".
  end.
  when 8 then do:
    p-os-err-name = "В доступе отказано".
  end.
  when 9 then do:
    p-os-err-name = "Неверный адрес".
  end.
  when 10 then do:
    p-os-err-name = "Уже есть файл с таким именем".
  end.
  when 11 then do:
    p-os-err-name = "Неверное устройство".
  end.
  when 12 then do:
    p-os-err-name = "Указана не директория (а файл)".
  end.
  when 13 then do:
    p-os-err-name = "Указана директория (а не файл)".
  end.
  when 14 then do:
    p-os-err-name = "Переполнение таблицы файлов".
  end.
  when 15 then do:
    p-os-err-name = "Слишком много открытых файлов".
  end.
  when 16 then do:
    p-os-err-name = "Слишком длинный файл".
  end.
  when 17 then do:
    p-os-err-name = "Нет свободного места на диске".
  end.
  when 18 then do:
    p-os-err-name = "Директория не пуста".
  end.
  when 999 then do:
    p-os-err-name = "Неизвестная ошибка операционной системы".
  end.
  otherwise do:
    p-os-err-name = substitute("Ошибка Операционной системы #&1", OS-ERROR).
  end.
END CASE.
