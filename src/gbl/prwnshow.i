/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение временных таблиц, описывающих процесс

Автор: Перваков Михаил Сергеевич
Дата создания: 08/11/03
Author: Mikhail Pervakov
Creation date: 08/11/03

*/

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

/* $Workfile$ e n d */