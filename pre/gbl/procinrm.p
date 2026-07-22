block-level on error undo, throw.
define temp-table temp-prwninfo no-undo
  field proc-id           as integer   format ">>>>>9"     label "Процесс"
  field progress-version  as character format "X(9)"       label "Версия"
  field progress-self     as logical   format "+/-"        label "Сам"
  field module-file-name  as character format "x(40)"      label "Исполняемый файл"
  field progress-propath  as character format "x(40)"      label "Путь поиска файлов (PROPATH)"
  field progress-inifile  as character format "x(40)"      label "Ini файл"
  field progress-curdir   as character format "x(40)"      label "Рабочая директория"
  field trans-active      as logical   format "+/-"        label "Транз."
  field cmd-line          as character format "x(160)"     label "Командная строка"
  field message-handle    as integer   format ">>>>>>>>9"  label "Указатель окна"
  field message-text      as character format "x(40)"      label "Сообщение"
  field proc-name         as character format "x(40)"      label "Имя программы"
  field proc-line         as integer   format "->>>>>>>>9" label "Строка"
  field r-code-name       as character format "x(40)"      label "Модуль"
  field db-connect-string as character format "x(40)"      label "Строка подключения"
  field widget-percent    as decimal   format ">>9.99%"    label "WdgUsed"
  field widget-num        as integer   format ">>>>>>>>9"  label "WidgNum"
  field max-widget-num    as integer   format ">>>>>>>>9"  label "Max widget num"
  index xpk is primary unique proc-id
  index is-self progress-self
.
define temp-table temp-prwnprocinfo no-undo
  field proc-id       as integer   format ">>>9"        label "Процесс"
  field proc-level    as integer   format ">>>9"        label "Уровень"
  field h-proc        as integer   format ">>>>>>>>>>>" label "Ук.программы"
  field proc-name     as character format "x(40)"       label "Имя программы"
  field proc-line     as integer   format "->>>>>>>>9"  label "Строка"
  field r-code-name   as character format "x(40)"       label "Модуль"
  field sub-procedure as logical
  field subproc-num   as integer   format ">>>>>9"
  index xpk is primary unique proc-id proc-level
.
define temp-table temp-procinfo no-undo
  field proc-level    as integer   format ">>>9"         label "Уровень"
  field h-proc        as integer   format ">>>>>>>>>>>"  label "Ук.программы"
  field proc-name     as character format "x(40)"        label "Имя программы"
  field proc-line     as integer   format "->>>>>>>>9"   label "Строка"
  field r-code-name   as character format "x(40)"        label "Модуль"
  field sub-procedure as logical
  field subproc-num   as integer   format ">>>>>9"
  index xpk is primary unique proc-level
.
define temp-table temp-window no-undo
   field window-handle       as integer   label "Handle"
   field window-visible      as logical   label "Visible"
   field window-text         as character label "Text"     format "x(20)"
   field window-class-atom   as integer   label "Class Atom"
   field window-class-name   as character label "Class Name"
   field window-message      as logical
   field window-message-text as character label "Message"  format "x(60)"
   field window-process-id   as integer   label "Process"
   field window-thread-id    as integer   label "Thread"
.
define temp-table temp-progress-version-info no-undo
   field progress-version as character
   field procedure-handle as character
   field pgc              as character
   field pdb-task         as character
   field savename         as character
   field the-display      as character
   field wic-max-id       as character
   index xpk is primary unique progress-version
.
define temp-table temp-dbg-file-header no-undo
  field proc-id     as integer   format ">>>9"  label "Процесс"
  field r-code-name as character format "x(40)" label "Модуль"
  field file-num    as integer   format ">>>9"  label "Номер файла"
  index xpk is primary unique proc-id r-code-name
  index x-file-num file-num
.
define temp-table temp-dbg-file no-undo
  field file-num  as integer   format ">>>9"    label "Номер файла"
  field line-num  as integer   format ">>>9"    label "Номер строки"
  field line-text as character format "x(200)" label "Строка"
  index xpk is primary unique file-num line-num
.
define temp-table temp-show-file no-undo
  field line-num  as integer   format ">>>9"    label "Номер строки"
  field line-text as character format "x(200)" label "Строка"
  index xpk is primary unique line-num
.
define input  parameter p-progress-version       as character no-undo .
define input  parameter p-first-procedure-handle as character no-undo .
define input  parameter p-pgc-handle             as character no-undo .
define input  parameter p-pdb-task-handle        as character no-undo .
define input  parameter p-savename-handle        as character no-undo .
define input  parameter p-the-display-handle     as character no-undo .
define input  parameter p-wic-max-id-handle      as character no-undo .
define input  parameter p-process-id             as integer   no-undo .
define output parameter p-progress-propath       as character no-undo .
define output parameter p-trans-active           as logical   no-undo .
define output parameter p-ini-file               as character no-undo .
define output parameter p-widget-num             as integer   no-undo .
define output parameter p-max-widget-num         as integer   no-undo .
define output parameter table for temp-procinfo .
function hex-to-int returns integer (
  input p-hex-code  as character  ).
  define variable v-int-code as integer   no-undo .
  define variable v-ind      as integer   no-undo .
  define variable v-digit    as integer   no-undo .
  define variable v-letter   as character no-undo .
  do v-ind = 1 to length(p-hex-code)
  :
    assign
      v-letter = caps(substring(p-hex-code, v-ind, 1))
    .
    assign
      v-digit = index('123456789ABCDEF':u, v-letter)
    .
    assign
      v-int-code = v-int-code * 16 + v-digit
    .
  end.
  return v-int-code .
end function .
do
on error undo, return error return-value
:
  define variable hProcess as integer   no-undo .
  if p-process-id = 0 then do:
    run GetCurrentProcessID (output p-process-id) .
  end.
  run process-open in this-procedure
    (input  p-process-id
    ,output hprocess
    ) .
  if hprocess = 0
  then do:
    return .
  end.
  define variable i-version-after-10_2B as logical no-undo init false .
  define variable i-offset-proc-name    as integer no-undo .
  define variable i-offset-dir-entry    as integer no-undo init 4 .
  define variable i-offset-proc-handle  as integer no-undo init 28 .
  define variable i-offset-subproc-num  as integer no-undo init 64 .
  define variable i-offset-dir-entry2   as integer no-undo init 76 .
  define variable i-offset-r-code-name  as integer no-undo init 52 .
  define variable i-offset-line-num     as integer no-undo init 8 .
  define variable v-curr-procedure as integer   no-undo .
  if p-progress-version begins "8."
    or p-progress-version begins "9."
  then do:
    assign
      i-offset-proc-name = 41
    .
  end.
  else do:
    assign
      i-offset-proc-name = 44
    .
  end.
  if integer( entry( 1, p-progress-version, ".":U ) ) > 10
    or ( integer( entry( 1, p-progress-version, ".":U ) ) = 10
         and integer( substring( entry( 2, p-progress-version, ".":U ), 1, 1 ) ) >= 2
         and caps( substring( entry( 2, p-progress-version, ".":U ), 2 ) ) >= "B":U
       )
  then do:
    assign
      i-version-after-10_2B = true
    .
  end.
  assign
    v-curr-procedure = hex-to-int(p-first-procedure-handle)
  .
  if v-curr-procedure = 0
  then do:
    return .
  end.
  define variable v-proc-level as integer   no-undo .
  assign
    v-proc-level = 0
  .
  repeat :
    assign
      v-proc-level = v-proc-level + 1
    .
    run read-long in this-procedure
      (input  hProcess
      ,input  v-curr-procedure
      ,output v-curr-procedure
      ) .
    if v-curr-procedure = 0
    then do:
      leave .
    end.
    if i-version-after-10_2B = true
      and v-proc-level = 1
    then do:
      if caps(substring(entry(2, p-progress-version, ".":U ), 2)) = 'B07' then do:
          run read-long in this-procedure
            (input  hProcess
            ,input  v-curr-procedure + hex-to-int("0x7c")
            ,output v-curr-procedure
            ) .
          if v-curr-procedure = 0
          then do:
            leave .
          end.
      end.
      else do:
          run read-long in this-procedure
            (input  hProcess
            ,input  v-curr-procedure + hex-to-int("0x74")
            ,output v-curr-procedure
            ) .
          if v-curr-procedure = 0
          then do:
            leave .
          end.
      end.
    end.
    define variable v-proc-name as character no-undo .
    run read-string in this-procedure
      (input  hProcess
      ,input  v-curr-procedure + i-offset-proc-name
      ,output v-proc-name
      ) .
    define variable v-proc-handle as integer no-undo .
    run read-long in this-procedure
      (input  hProcess
      ,input  v-curr-procedure + i-offset-proc-handle
      ,output v-proc-handle
      ) .
    define variable v-proc-line as integer no-undo .
    run read-long in this-procedure
      (input  hProcess
      ,input  v-curr-procedure + i-offset-line-num
      ,output v-proc-line
      ) .
    define variable v-dir-entry as integer no-undo .
    run read-long in this-procedure
      (input  hProcess
      ,input  v-curr-procedure + i-offset-dir-entry
      ,output v-dir-entry
      ) .
    define variable v-subproc-num as integer no-undo .
    run read-long in this-procedure
      (input  hProcess
      ,input  v-dir-entry + i-offset-subproc-num
      ,output v-subproc-num
      ) .
    define variable v-dir-entry2 as integer no-undo .
    run read-long in this-procedure
      (input  hProcess
      ,input  v-dir-entry + i-offset-dir-entry2
      ,output v-dir-entry2
      ) .
    define variable v-sub-procedure as logical   no-undo .
    assign
      v-sub-procedure = (v-dir-entry2 <> v-dir-entry)
    .
    define variable v-r-code-name-addr as integer no-undo .
    run read-long in this-procedure
      (input  hProcess
      ,input  v-dir-entry2 + i-offset-r-code-name
      ,output v-r-code-name-addr
      ) .
    define variable v-r-code-name as character no-undo .
    run read-string in this-procedure
      (input  hProcess
      ,input  v-r-code-name-addr
      ,output v-r-code-name
      ) .
    create temp-procinfo .
    assign
      temp-procinfo.proc-level    = v-proc-level
      temp-procinfo.h-proc        = v-proc-handle
      temp-procinfo.proc-name     = v-proc-name
      temp-procinfo.proc-line     = v-proc-line
      temp-procinfo.r-code-name   = v-r-code-name
      temp-procinfo.sub-procedure = v-sub-procedure
      temp-procinfo.subproc-num   = v-subproc-num
    .
  end.
  define variable v-pgc as integer   no-undo .
  assign
    v-pgc = hex-to-int(p-pgc-handle)
  .
  if v-pgc <> 0
  then do:
    run read-long in this-procedure
      (input  hProcess
      ,input  v-pgc
      ,output v-pgc
      ) .
    define variable v-propath-addr as integer   no-undo .
    run read-long in this-procedure
      (input  hProcess
      ,input  v-pgc + 12
      ,output v-propath-addr
      ) .
    run read-string in this-procedure
      (input  hProcess
      ,input  v-propath-addr
      ,output p-progress-propath
      ) .
  end.
  define variable v-savename-addr as integer   no-undo .
  assign
    v-savename-addr = hex-to-int(p-savename-handle)
  .
  if v-savename-addr <> 0
  then do:
    define variable v-ini-file-addr as integer   no-undo .
    run read-long in this-procedure
      (input  hProcess
      ,input  v-savename-addr
      ,output v-ini-file-addr
      ) .
    if v-ini-file-addr <> 0
    then do:
      run read-string in this-procedure
        (input  hProcess
        ,input  v-ini-file-addr
        ,output p-ini-file
        ) .
    end.
  end.
  define variable v-wic-max-id-addr as integer   no-undo .
  assign
    v-wic-max-id-addr = hex-to-int(p-wic-max-id-handle)
  .
  if v-wic-max-id-addr <> 0
  then do:
    define variable v-wic-max-id-num as integer   no-undo .
    run read-long in this-procedure
      (input  hProcess
      ,input  v-wic-max-id-addr
      ,output v-wic-max-id-num
      ) .
    assign
      p-max-widget-num = v-wic-max-id-num
    .
    define variable v-the-display-addr as integer   no-undo .
    assign
      v-the-display-addr = hex-to-int(p-the-display-handle)
    .
    if v-the-display-addr <> 0
    then do:
      define variable v-widget-num as integer   no-undo .
      run read-long in this-procedure
        (input  hProcess
        ,input  v-the-display-addr
        ,output v-the-display-addr
        ) .
      define variable v-display-vector-addr as integer   no-undo .
      run read-long in this-procedure
        (input  hProcess
        ,input  v-the-display-addr + hex-to-int("0xd70")
        ,output v-display-vector-addr
        ) .
      assign
        v-widget-num = 0
      .
      define variable v-widget-index as integer   no-undo .
      define variable v-widget-value as integer   no-undo .
      do v-widget-index = 10 to v-wic-max-id-num - 1
      :
        run read-long in this-procedure
          (input  hProcess
          ,input  v-display-vector-addr + v-widget-index * 4
          ,output v-widget-value
          ) .
        if v-widget-value <> 0
        then do:
          assign
            v-widget-num = v-widget-num + 1
          .
        end.
      end.
      assign
        p-widget-num = v-widget-num
      .
    end.
  end.
  define variable v-pdb-task as integer   no-undo .
  assign
    v-pdb-task     = hex-to-int(p-pdb-task-handle)
    p-trans-active = false
  .
  if v-pdb-task <> 0 then do:
    run read-long in this-procedure
      (input  hProcess
      ,input  v-pdb-task
      ,output v-pdb-task
      ) .
    if i-version-after-10_2B = true then do:
      run read-long in this-procedure
        (input  hProcess
        ,input  v-pdb-task + hex-to-int("0x144")
        ,output v-pdb-task
        ) .
    end.
    assign
      p-trans-active = (v-pdb-task <> 0)
    .
  end.
  run process-close
    (input hProcess
    ) .
  return .
end.
procedure process-open :
  define input  parameter p-process-id     as integer   no-undo .
  define output parameter p-process-handle as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run OpenProcess
      (input 1024 + 16
      ,input 0
      ,input p-process-id
      ,output p-process-handle
      ).
  end.
end procedure.
procedure process-close :
  define input  parameter p-process-handle  as integer   no-undo .
  define variable v-retval     as integer   no-undo.
  do
  on error undo, return error return-value
  :
    run CloseHandle
      (input  p-process-handle
      ,output v-retval
      ).
  end.
end procedure.
procedure read-long :
  define input  parameter p-proc-handle  as integer   no-undo .
  define input  parameter p-long-address as integer   no-undo .
  define output parameter p-long-value   as integer   no-undo .
  define variable m-Buffer     as memptr no-undo .
  define variable m-bytes-read as memptr no-undo .
  define variable v-retval     as integer   no-undo.
  do
  on error undo, return error return-value
  :
    assign
      set-size(m-Buffer) = 4
      set-size(m-bytes-read) = 4
    .
    run ReadProcessMemory
      (input p-proc-handle
      ,input p-long-address
      ,input get-pointer-value(m-Buffer)
      ,input get-size(m-Buffer)
      ,input get-pointer-value(m-bytes-read)
      ,output v-retval
      ) .
    assign
      p-long-value = get-long(m-Buffer, 1)
    .
    assign
      set-size(m-Buffer) = 0
      set-size(m-bytes-read) = 0
    .
  end.
end procedure.
procedure read-string :
  define input  parameter p-proc-handle    as integer   no-undo .
  define input  parameter p-long-address   as integer   no-undo .
  define output parameter p-string-value   as character no-undo .
  define variable m-Buffer     as memptr no-undo .
  define variable m-bytes-read as memptr no-undo .
  define variable v-retval     as integer   no-undo.
  define variable v-max-string-size as integer   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      set-size(m-Buffer) = 1000
      set-size(m-bytes-read) = 4
    .
    run ReadProcessMemory
      (input p-proc-handle
      ,input p-long-address
      ,input get-pointer-value(m-Buffer)
      ,input get-size(m-Buffer)
      ,input get-pointer-value(m-bytes-read)
      ,output v-retval
      ) .
    assign
      put-byte(m-Buffer, get-size(m-Buffer)) = 0
    .
    assign
      p-string-value = get-string(m-Buffer, 1)
    .
    assign
      set-size(m-Buffer) = 0
      set-size(m-bytes-read) = 0
    .
  end.
end procedure.
PROCEDURE GetCurrentProcessId EXTERNAL "kernel32.dll" :
  DEFINE RETURN PARAMETER RetVal          AS LONG.
END PROCEDURE.
PROCEDURE CloseHandle EXTERNAL "kernel32.dll" :
  DEFINE INPUT  PARAMETER hObject AS LONG.
  DEFINE RETURN PARAMETER RetVal  AS LONG.
END PROCEDURE.
PROCEDURE OpenProcess EXTERNAL "kernel32.dll" :
  DEFINE INPUT  PARAMETER dwDesiredAccess AS LONG.
  DEFINE INPUT  PARAMETER bInheritHandle  AS LONG.
  DEFINE INPUT  PARAMETER dwProcessId     AS LONG.
  DEFINE RETURN PARAMETER hProcess        AS LONG.
END PROCEDURE.
PROCEDURE ReadProcessMemory EXTERNAL "kernel32.dll" :
  DEFINE INPUT  PARAMETER hProcess            AS LONG.
  DEFINE INPUT  PARAMETER lpBaseAddress       AS LONG.
  DEFINE INPUT  PARAMETER lpBuffer            AS LONG.
  DEFINE INPUT  PARAMETER nSize               AS LONG.
  DEFINE INPUT  PARAMETER lpNumberOfBytesRead AS LONG.
  DEFINE RETURN PARAMETER RetVal  AS LONG.
END PROCEDURE.
