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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable v-info as character no-undo .
define stream sinp .
define stream sout .
DEFINE BUTTON b-about
     LABEL "О программе"
     SIZE 14.5 BY 1.
DEFINE BUTTON b-cur-dir
     LABEL "Cur Dir"
     SIZE 10 BY 1.
DEFINE BUTTON b-cur-line
     LABEL "Cur Ln"
     SIZE 8 BY 1.
DEFINE BUTTON b-debug-file
     LABEL "Dbg File"
     SIZE 11 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-export
     LABEL "Экспорт"
     SIZE 10 BY 1.
DEFINE BUTTON b-propath
     LABEL "Propath"
     SIZE 10 BY 1.
DEFINE BUTTON b-refresh
     LABEL "Обновить"
     SIZE 10 BY 1.
DEFINE BUTTON b-terminate
     LABEL "Завершить"
     SIZE 12 BY 1.
DEFINE VARIABLE fi-info AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 92.13 BY .67 NO-UNDO.
DEFINE VARIABLE t-self-view AS LOGICAL INITIAL no
     LABEL "Показывать процесс ~"сам~""
     VIEW-AS TOGGLE-BOX
     SIZE 27.5 BY .83 NO-UNDO.
DEFINE QUERY BROWSE-1 FOR
      temp-prwninfo SCROLLING.
DEFINE QUERY BROWSE-2 FOR
      temp-prwnprocinfo SCROLLING.
DEFINE BROWSE BROWSE-1
  QUERY BROWSE-1 DISPLAY
      temp-prwninfo.proc-id
      temp-prwninfo.progress-self
      temp-prwninfo.progress-version
      temp-prwninfo.trans-active
      temp-prwninfo.widget-num
      temp-prwninfo.message-text format "X(256)" width 100
      temp-prwninfo.proc-line
      temp-prwninfo.proc-name
      temp-prwninfo.module-file-name
      temp-prwninfo.max-widget-num
      temp-prwninfo.progress-inifile
      temp-prwninfo.progress-curdir
      temp-prwninfo.progress-propath
    WITH NO-ROW-MARKERS SEPARATORS SIZE 126 BY 7.75.
DEFINE BROWSE BROWSE-2
  QUERY BROWSE-2 DISPLAY
      temp-prwnprocinfo.proc-level
      temp-prwnprocinfo.h-proc
      temp-prwnprocinfo.proc-name
      temp-prwnprocinfo.proc-line
      temp-prwnprocinfo.r-code-name
      temp-prwnprocinfo.sub-procedure
      temp-prwnprocinfo.subproc-num
    WITH NO-ROW-MARKERS SEPARATORS SIZE 126 BY 16.46.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-refresh AT ROW 1 COL 11
     b-propath AT ROW 1 COL 21
     b-cur-dir AT ROW 1 COL 31
     b-debug-file AT ROW 1 COL 41
     b-cur-line AT ROW 1 COL 52
     b-export AT ROW 1 COL 60
     b-terminate AT ROW 1 COL 70
     b-about AT ROW 1 COL 82
     t-self-view AT ROW 3.25 COL 2.5 WIDGET-ID 2
     BROWSE-1 AT ROW 4.25 COL 1
     BROWSE-2 AT ROW 12.29 COL 1
     fi-info AT ROW 2.38 COL 1.13 NO-LABEL
     SPACE(33.98) SKIP(25.86)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Сессии Progress"
         DEFAULT-BUTTON b-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       BROWSE-1:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 3.
ASSIGN
       BROWSE-2:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-about IN FRAME Dialog-Frame
DO:
  message
    "ProwinShow 1.0" skip
    "Программа просмотра процессов Progress" skip
    "Автор Михаил Перваков" skip
    "Москва, 2003-2006" skip
    "" skip
    "E-mail: kogosy@mail.ru" skip
    view-as alert-box information .
END.
ON CHOOSE OF b-cur-dir IN FRAME Dialog-Frame
DO:
define variable vss-include-info0 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  define variable v-current-directory as character no-undo .
  if available temp-prwninfo
  then do:
    if temp-prwninfo.progress-curdir = ""
    then do:
      run get-current-directory in this-procedure
        (input  temp-prwninfo.proc-id
        ,output v-current-directory
        ) .
      assign
        temp-prwninfo.progress-curdir = v-current-directory
      .
      display temp-prwninfo.progress-curdir with browse browse-1 .
    end.
    message
      "Сессия Progress 4GL" skip
      "Идентификатор процесса" temp-prwninfo.proc-id skip
      "Текущая рабочая директория" skip
      temp-prwninfo.progress-curdir skip
      view-as alert-box information .
  end.
END.
ON CHOOSE OF b-cur-line IN FRAME Dialog-Frame
DO:
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run generate-debug-file in this-procedure
    (input 'cur-line':u
    ).
END.
ON CHOOSE OF b-debug-file IN FRAME Dialog-Frame
DO:
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run generate-debug-file in this-procedure
    (input 'debug-file':u
    ).
END.
ON CHOOSE OF b-export IN FRAME Dialog-Frame
DO:
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run export-info in this-procedure .
END.
ON CHOOSE OF b-propath IN FRAME Dialog-Frame
DO:
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run show-propath in this-procedure .
END.
ON CHOOSE OF b-refresh IN FRAME Dialog-Frame
DO:
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run local-open-query .
END.
ON CHOOSE OF b-terminate IN FRAME Dialog-Frame
DO:
  run terminate-process in this-procedure .
END.
ON DEFAULT-ACTION OF BROWSE-1 IN FRAME Dialog-Frame
DO:
  run show-propath in this-procedure .
END.
ON VALUE-CHANGED OF BROWSE-1 IN FRAME Dialog-Frame
DO:
  run local-open-query-prwnprocinfo in this-procedure .
END.
ON DEFAULT-ACTION OF BROWSE-2 IN FRAME Dialog-Frame
DO:
  run generate-debug-file in this-procedure
    (input 'cur-line':u
    ).
END.
ON VALUE-CHANGED OF t-self-view IN FRAME Dialog-Frame
DO:
  run local-open-query .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable v-ok as logical   no-undo .
assign
  v-ok = BROWSE-1 :set-repositioned-row(5, 'CONDITIONAL':u)
  v-ok = browse-2 :set-repositioned-row(5, 'CONDITIONAL':u)
.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
:
  RUN enable_UI.
  assign
  temp-prwninfo.progress-version:resizable in browse browse-1 = yes
  temp-prwninfo.message-text:resizable     in browse browse-1 = yes
  .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY t-self-view fi-info
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-refresh b-propath b-cur-dir b-debug-file b-cur-line b-export
         b-terminate b-about t-self-view BROWSE-1 BROWSE-2 fi-info
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  run local-open-query in this-procedure .    run local-open-query-prwnprocinfo in this-procedure .
END PROCEDURE.
PROCEDURE export-info :
  define variable v-command-line as character no-undo .
  define variable v-num          as integer   no-undo .
  define variable v-info-type    as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/d-askw.w
      (input "Вопрос"
      ,input "Произвести сбор отладочной информации "
      + "и вывод информации в текстовый файл." + chr(10)
      + "В любом из режимов не будет производится сбор личной информации." + chr(10)
      + "По завершении экспорта в текстовый файл его можно будет просмотреть, "
      + "при необходимости удалить лишнюю информацию, "
      + "отправить в службу поддержки для определения причины ошибки"
      ,input '|^':u
      ,input "Краткая"
      + '|':u + "Подробная"
      + '|':u + "Отказ"
      ,input "Собрать минимальное количество информации"
          + "|":u + "Собрать максимально подробную информацию "
                  + "(запущенные сервисы, программы, установленные программы, "
                  + "установленные обновления, сообщения об ошибках из журнала)"
          + "|":u
      ,input 1
      ,input 3
      ,output v-num
      ).
    case v-num
    :
      when 1
      then do:
        assign
          v-info-type = 'common':u
        .
      end.
      when 2
      then do:
        assign
          v-info-type = 'detail':u
        .
      end.
      when 3
      then do:
        return .
      end.
    end case .
    define variable v-error-log-file-name as character no-undo .
    run gbl/_tmpfile.p
      (input "pwn"
      ,input ".txt"
      ,output v-error-log-file-name
      ).
    output stream sout to value(v-error-log-file-name) .
    define buffer buf_temp-prwninfo for temp-prwninfo .
    define buffer buf_temp-prwnprocinfo for temp-prwnprocinfo .
    put stream sout unformatted 'ProwinShow 1.0':u + chr(10) .
    put stream sout unformatted v-info + chr(10) .
    if  available temp-prwninfo
    and temp-prwninfo.message-text <> ''
    then do:
      put stream sout unformatted chr(10) .
      put stream sout unformatted chr(10) .
      put stream sout unformatted fill('#':u, 80) + chr(10).
      put stream sout unformatted substitute("Идентификатор процесса (PID) : &1&2"
                                            ,temp-prwninfo.proc-id
                                            ,chr(10)
                                            ).
      put stream sout unformatted substitute('Сообщение                    : &1&2':u
                                            ,temp-prwninfo.message-text
                                            ,chr(10)
                                            ) .
      put stream sout unformatted substitute('Процедура                    : &1&2':u
                                            ,temp-prwninfo.proc-name
                                            ,chr(10)
                                            ) .
      put stream sout unformatted substitute('Номер строки                 : &1&2':u
                                            ,temp-prwninfo.proc-line
                                            ,chr(10)
                                            ) .
      put stream sout unformatted substitute('Файл                         : &1&2':u
                                            ,temp-prwninfo.r-code-name
                                            ,chr(10)
                                            ) .
    end.
    put stream sout unformatted chr(10) .
    for each buf_temp-prwninfo
    on error undo, return error return-value
    :
      put stream sout unformatted chr(10) .
      put stream sout unformatted chr(10) .
      put stream sout unformatted fill('#':u, 80) + chr(10).
      put stream sout unformatted substitute("Идентификатор процесса (PID)            : &1&2"
                                            ,buf_temp-prwninfo.proc-id
                                            ,chr(10)
                                            ).
      put stream sout unformatted substitute("Версия Progress                         : &1&2"
                                            ,buf_temp-prwninfo.progress-version
                                            ,chr(10)
                                            ).
      put stream sout unformatted substitute("Текущий процесс ProwinShow              : &1&2"
                                            ,string(buf_temp-prwninfo.progress-self, "да/нет")
                                            ,chr(10)
                                            ).
      put stream sout unformatted substitute("Исполняемый файл                        : &1&2"
                                            ,buf_temp-prwninfo.module-file-name
                                            ,chr(10)
                                            ).
      define variable v-index                as integer   no-undo .
      define variable v-num-entries-propath as integer   no-undo .
      assign
        v-num-entries-propath = num-entries(buf_temp-prwninfo.progress-propath)
      .
      put stream sout unformatted substitute("Путь поиска файлов Progress (PROPATH)   : &1&2"
                                            ,entry(1, buf_temp-prwninfo.progress-propath)
                                            ,chr(10)
                                            ).
      do v-index = 2 to v-num-entries-propath
      :
        put stream sout unformatted substitute("                                          &1&2"
                                              ,entry(v-index, buf_temp-prwninfo.progress-propath)
                                              ,chr(10)
                                              ).
      end.
      put stream sout unformatted substitute("Файл конфигурации Progress (*.ini файл) : &1&2"
                                            ,buf_temp-prwninfo.progress-inifile
                                            ,chr(10)
                                            ).
      put stream sout unformatted substitute("Рабочая папка                           : &1&2"
                                            ,buf_temp-prwninfo.progress-curdir
                                            ,chr(10)
                                            ).
      put stream sout unformatted substitute("Транзакция активна                      : &1&2"
                                            ,string(buf_temp-prwninfo.trans-active, "да/нет")
                                            ,chr(10)
                                            ).
      put stream sout unformatted substitute("Указатель окна                          : &1&2"
                                            ,buf_temp-prwninfo.message-handle
                                            ,chr(10)
                                            ).
      put stream sout unformatted substitute("Сообщение                               : &1&2"
                                            ,buf_temp-prwninfo.message-text
                                            ,chr(10)
                                            ).
      put stream sout unformatted substitute("Имя процедуры                           : &1&2"
                                            ,buf_temp-prwninfo.proc-name
                                            ,chr(10)
                                            ).
      put stream sout unformatted substitute("Номер строки                            : &1&2"
                                            ,buf_temp-prwninfo.proc-line
                                            ,chr(10)
                                            ).
      put stream sout unformatted substitute("Исполняемый файл                        : &1&2"
                                            ,buf_temp-prwninfo.r-code-name
                                            ,chr(10)
                                            ).
      put stream sout unformatted substitute("Строка подключения к БД                 : &1&2"
                                            ,buf_temp-prwninfo.db-connect-string
                                            ,chr(10)
                                            ).
      put stream sout unformatted substitute("Количество интерфейсных элементов       : &1&2"
                                            ,buf_temp-prwninfo.widget-num
                                            ,chr(10)
                                            ).
      put stream sout unformatted chr(10) .
      put stream sout unformatted "Стек вызова процедур" + chr(10).
      put stream sout unformatted "Порядок Имя процедуры                          Номер строки   Исполняемый файл" + chr(10).
      put stream sout unformatted fill('-':u, 80) + chr(10).
      for each buf_temp-prwnprocinfo
        where buf_temp-prwnprocinfo.proc-id = buf_temp-prwninfo.proc-id
      on error undo, return error return-value
      :
        put stream sout unformatted substitute(' &1 &2 &3       &4&5':u
                                              ,string(buf_temp-prwnprocinfo.proc-level, '>>,>>9':u)
                                              ,string(buf_temp-prwnprocinfo.proc-name, 'x(40)':u)
                                              ,string(buf_temp-prwnprocinfo.proc-line, '>>,>>9':u)
                                              ,string(buf_temp-prwnprocinfo.r-code-name, 'x(40)':u)
                                              ,chr(10)
                                              ).
      end.
      put stream sout unformatted fill('-':u, 80) + chr(10).
    end.
    put stream sout unformatted chr(10).
    put stream sout unformatted fill('#':u, 80) + chr(10).
    put stream sout unformatted substitute("Информация о компьютере и процессах Progress. Дата &1. Время &2.", string(today, '99/99/9999':u), string(time, 'HH:MM:SS':u)) + chr(10) .
    output stream sout close .
    define variable v-compinfo-filename as character no-undo .
    assign
      v-compinfo-filename = search('exe/compinfo.bat':u)
    .
    if  v-compinfo-filename = ""
    and v-compinfo-filename = ?
    then do:
      message
        "Не найден файл определения информации о компьютере" 'exe/compinfo.bat':u skip
        "Сбор информации об ошибке будет продолжен" skip
        view-as alert-box information  .
    end.
    else do:
      define variable v-full-path        as character no-undo .
      define variable v-path             as character no-undo .
      define variable v-file-name        as character no-undo .
      define variable v-file-name-no-ext as character no-undo .
      define variable v-file-name-ext    as character no-undo .
      run gbl/filename.p
        (input  v-compinfo-filename
        ,output v-full-path
        ,output v-path
        ,output v-file-name
        ,output v-file-name-no-ext
        ,output v-file-name-ext
        ) .
      assign
        v-command-line =  substitute("&1 &2 &3 &4"
                                    ,v-compinfo-filename
                                    ,v-path
                                    ,v-error-log-file-name
                                    ,v-info-type
                                    )
      .
      os-command value(v-command-line).
    end.
    define variable v-procinfo-filename as character no-undo .
    assign
      v-procinfo-filename = search('exe/procinfo.bat':u)
    .
    if  v-procinfo-filename = ""
    and v-procinfo-filename = ?
    then do:
      message
        "Не найден файл определения информации о процессе" 'exe/procinfo.bat':u skip
        "Сбор информации об ошибке будет продолжен" skip
        view-as alert-box information  .
    end.
    else do:
      run gbl/filename.p
        (input  v-procinfo-filename
        ,output v-full-path
        ,output v-path
        ,output v-file-name
        ,output v-file-name-no-ext
        ,output v-file-name-ext
        ) .
      for each buf_temp-prwninfo
      on error undo, return error return-value
      :
        assign
          v-command-line =  substitute("&1 &2 &3 &4"
                                      ,v-procinfo-filename
                                      ,v-path
                                      ,buf_temp-prwninfo.proc-id
                                      ,v-error-log-file-name
                                      )
        .
        os-command value(v-command-line).
      end.
    end.
    output stream sout to value(v-error-log-file-name) append .
    put stream sout unformatted fill('#':u, 80) + chr(10) .
    put stream sout unformatted '>>> EOF <<<':u + chr(10) .
    output stream sout close .
    os-command no-wait value ('start notepad ' + v-error-log-file-name).
  end.
END PROCEDURE.
PROCEDURE generate-debug-file :
  define input  parameter p-show-type as character no-undo .
  define variable v-current-directory as character no-undo .
  if  available temp-prwninfo
  and available temp-prwnprocinfo
  then do:
    find first temp-dbg-file-header
      where temp-dbg-file-header.proc-id     = temp-prwninfo.proc-id
        and temp-dbg-file-header.r-code-name = temp-prwnprocinfo.r-code-name
      no-error .
    if not available temp-dbg-file-header
    then do:
      if temp-prwninfo.progress-curdir = ""
      then do:
        run get-current-directory in this-procedure
          (input  temp-prwninfo.proc-id
          ,output v-current-directory
          ) .
        assign
          temp-prwninfo.progress-curdir = v-current-directory
        .
        display temp-prwninfo.progress-curdir with browse browse-1 .
      end.
      define variable v-connect-string as character no-undo .
      assign
        v-connect-string = temp-prwninfo.db-connect-string
      .
      run gbl/getinist.p
        (input  temp-prwninfo.progress-inifile
        ,input  "rep-sets"
        ,input  "conpar"
        ,output v-connect-string
        ) .
      define variable v-new-connect-string as character no-undo .
      if v-connect-string = ?
      then do:
        assign
          v-new-connect-string = ""
        .
      end.
      else do:
        if index(v-connect-string, '&1':u) > 0
        then do:
          assign
            v-new-connect-string = substitute(v-connect-string, '-U sysadm -P &1':u)
          .
        end.
        else do:
          assign
            v-new-connect-string = v-connect-string + ' -U sysadm -P &1':u
          .
        end.
      end.
      run gbl/d-prompt.w
        ( 'title=':u + "Параметры подключения к базе данных" + '\':u
        + 'text1=':u + "Отредактируйте строку подключения к базе данных" + '\':u
        + 'text2=':u + "или нажмите Отмену, чтобы не подключаться к базе" + '\':u
        + 'format=X(128)\':u
        + 'fillin_width=60\':u
        + 'type=char\':u
        ,input-output v-new-connect-string
        ).
      if return-value = 'false':u
      then do:
        assign
          v-connect-string = ""
        .
      end.
      else do:
        assign
          v-connect-string = v-new-connect-string
        .
      end.
      if index(v-connect-string, "&1") > 0
      then do:
        define variable v-sysadm-passwd as character no-undo .
        run gbl/d-prompt.w
          ( 'title=':u + "Введите пароль sysadm для базы данных" + '\':u
          + 'text1=':u + "Введите пароль sysadm для базы данных" + '\':u
          + 'text1=':u + "или нажмите Отмену, чтобы не подключаться к базе" + '\':u
          + 'format=X(12)\':u
          + 'type=char\':u
          + 'blank=yes\':u
          ,input-output v-sysadm-passwd
          ).
        if return-value = 'false':u
        then do:
          assign
            v-connect-string = ""
          .
        end.
        else do:
          assign
            v-connect-string = substitute(v-connect-string, v-sysadm-passwd)
          .
        end.
      end.
      assign
        temp-prwninfo.db-connect-string = v-connect-string
      .
      define variable v-dbg-file       as character no-undo .
      run gbl/comp_dbg.p
        (input  temp-prwninfo.module-file-name
        ,input  temp-prwninfo.progress-curdir
        ,input  temp-prwninfo.progress-inifile
        ,input  temp-prwninfo.progress-propath
        ,input  temp-prwnprocinfo.r-code-name
        ,input  temp-prwnprocinfo.proc-line
        ,input  temp-prwninfo.db-connect-string
        ,output v-dbg-file
        ) .
      if search(v-dbg-file) = ""
      or search(v-dbg-file) = ?
      then do:
        message
          "Ошибка создания *.dbg файла" skip
          view-as alert-box error .
        undo, return error return-value  .
      end.
      define variable v-file-num as integer   no-undo .
      find last temp-dbg-file-header
        use-index x-file-num
        no-error .
      if available temp-dbg-file-header
      then do:
        assign
          v-file-num = temp-dbg-file-header.file-num + 1
        .
      end.
      else do:
        assign
          v-file-num = 1
        .
      end.
      create temp-dbg-file-header .
      assign
        temp-dbg-file-header.proc-id     = temp-prwninfo.proc-id
        temp-dbg-file-header.r-code-name = temp-prwnprocinfo.r-code-name
        temp-dbg-file-header.file-num    = v-file-num
      .
      define variable v-line-text as character no-undo .
      define variable v-line-num as integer   no-undo .
      assign
        v-line-num = 0
      .
      input stream sinp from value(v-dbg-file) .
      repeat
      :
        assign
          v-line-text = ""
        .
        import stream sinp unformatted
          v-line-text
          .
        assign
          v-line-num = v-line-num + 1
        .
        create temp-dbg-file .
        assign
          temp-dbg-file.file-num  = v-file-num
          temp-dbg-file.line-num  = v-line-num
          temp-dbg-file.line-text = v-line-text
        .
      end.
      input stream sinp close .
      os-delete value(v-dbg-file) .
    end.
    find first temp-dbg-file-header
      where temp-dbg-file-header.proc-id     = temp-prwninfo.proc-id
        and temp-dbg-file-header.r-code-name = temp-prwnprocinfo.r-code-name
      no-error .
    if available temp-dbg-file-header
    then do:
      case p-show-type :
        when 'cur-line':u
        then do:
          define variable v-program-text as character no-undo .
          assign
            v-program-text = ""
          .
          for each temp-dbg-file
            where temp-dbg-file.file-num = temp-dbg-file-header.file-num
              and temp-dbg-file.line-num >= temp-prwnprocinfo.proc-line - 10
              and temp-dbg-file.line-num <= temp-prwnprocinfo.proc-line + 10
          :
            assign
              v-program-text = v-program-text
                              + (if temp-dbg-file.line-num = temp-prwnprocinfo.proc-line
                                then "##>"
                                else "   "
                                )
                              + temp-dbg-file.line-text
                              + chr(10)
            .
          end.
          run gbl/d-prompt.w
            (input 'title=Текущая выполняемая строка\'
              + 'type=editor\'
              + 'fillin_width=96\'
              + 'fillin_height=17\'
              + 'readonly=yes\'
            , input-output v-program-text
            ).
        end.
        when 'debug-file':u
        then do:
          for each temp-show-file
          :
            delete temp-show-file .
          end.
          for each temp-dbg-file
            where temp-dbg-file.file-num = temp-dbg-file-header.file-num
          :
            create temp-show-file .
            assign
              temp-show-file.line-num  = temp-dbg-file.line-num
              temp-show-file.line-text = temp-dbg-file.line-text
            .
          end.
          run gbl/show_dbg.w
            (input table temp-show-file
            ,input  temp-prwnprocinfo.proc-line
            ) .
        end.
        otherwise do:
          message
            "Внутренняя ошибка" skip
            "Неизвестное значение переменной p-show-type" skip
            "p-show-type" p-show-type skip
            view-as alert-box error .
        end.
      end case .
    end.
    else do:
      message
        "Ошибка при создании *.dbg файла"
        view-as alert-box error .
    end.
  end.
END PROCEDURE.
PROCEDURE get-current-directory :
  define input  parameter p-process-id        as integer   no-undo .
  define output parameter p-current-directory as character no-undo .
  define variable v-getcurdr-filename as character no-undo .
  define variable v-output-filename   as character no-undo .
  define variable v-command-line      as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-getcurdr-filename = search("exe/getcurdr.bat")
    .
    if  v-getcurdr-filename = ""
    and v-getcurdr-filename = ?
    then do:
      message
        "Не найден файл программы определения текущей директории" skip
        "exe/getcurdr.bat" skip
        view-as alert-box information  .
    end.
    else do:
      define variable v-full-path        as character no-undo .
      define variable v-path             as character no-undo .
      define variable v-file-name        as character no-undo .
      define variable v-file-name-no-ext as character no-undo .
      define variable v-file-name-ext    as character no-undo .
      run gbl/filename.p
        (input  v-getcurdr-filename
        ,output v-full-path
        ,output v-path
        ,output v-file-name
        ,output v-file-name-no-ext
        ,output v-file-name-ext
        ) .
      run gbl/_tmpfile.p
        (input  "err"
        ,input  ".txt"
        ,output v-output-filename
        ).
      output stream sout to value(v-output-filename).
      put stream sout unformatted "ERROR" skip .
      output stream sout close .
      assign
        file-info :file-name = v-output-filename
        v-output-filename = file-info :full-pathname
      .
      assign
        v-command-line = substitute("&1 &2 &3 &4"
          ,v-getcurdr-filename
          ,v-path
          ,p-process-id
          ,v-output-filename
          )
      .
      os-command value(v-command-line).
      assign
        p-current-directory = ""
      .
      input stream sout from value(v-output-filename) .
      repeat :
        import stream sout unformatted p-current-directory .
      end.
      input stream sout close .
      os-delete value(v-output-filename) .
      if p-current-directory = "ERROR"
      then do:
        message
          "Ошибка при определении текущей директории программы" skip
          view-as alert-box error .
        assign
          p-current-directory = ""
        .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE local-open-query :
  assign
    v-info = substitute("Информация о сессиях Progress. Дата &1. Время &2.", string(today, '99/99/9999':u), string(time, 'HH:MM:SS':u))
  .
  do with frame Dialog-Frame:
    assign
      fi-info :screen-value = v-info
    .
    assign
      t-self-view
    .
  end.
  run gbl/prwninfo.p
    (output table temp-prwninfo
    ,output table temp-prwnprocinfo
    ) .
  if t-self-view = true then do:
    OPEN QUERY BROWSE-1 FOR EACH temp-prwninfo .
  end.
  else do:
    OPEN QUERY BROWSE-1 FOR EACH temp-prwninfo where temp-prwninfo.progress-self = false .
  end.
  define variable v-rowid as rowid no-undo .
  define buffer buf_temp-prwninfo for temp-prwninfo .
  find first buf_temp-prwninfo
    where buf_temp-prwninfo.message-text <> ""
    no-error .
  if available buf_temp-prwninfo
  then do:
    assign
      v-rowid = rowid(buf_temp-prwninfo)
    .
    reposition BROWSE-1 to rowid v-rowid .
  end.
  run local-open-query-prwnprocinfo in this-procedure .
  do with frame Dialog-Frame:
    apply 'entry':u to browse BROWSE-1 .
  end.
END PROCEDURE.
PROCEDURE local-open-query-prwnprocinfo :
  if available temp-prwninfo
  then do:
    open query browse-2 for each temp-prwnprocinfo
      where temp-prwnprocinfo.proc-id = temp-prwninfo.proc-id
      by temp-prwnprocinfo.proc-level descending .
  end.
  else do:
    open query browse-2 for each temp-prwnprocinfo where false .
  end.
END PROCEDURE.
PROCEDURE show-propath :
  if available temp-prwninfo
  then do:
    message
      "Сессия Progress 4GL" skip
      "Номер процесса" temp-prwninfo.proc-id skip
      "Версия Progress" temp-prwninfo.progress-version skip
      "Транзакция" (if temp-prwninfo.trans-active then "АКТИВНА" else "не активна") skip
      "Ini файл" skip
      temp-prwninfo.progress-inifile skip
      "Propath" skip
      temp-prwninfo.progress-propath skip
      view-as alert-box information .
  end.
END PROCEDURE.
PROCEDURE terminate-process :
  if available temp-prwninfo
  then do:
    define variable v-ok as logical   no-undo .
    message
      substitute("Процесс с номером &1 будет завершен."
                ,temp-prwninfo.proc-id
                ) skip
      "Продолжить?" skip
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok <> true
    then do:
      return .
    end.
    run gbl/termprc.p
      (input temp-prwninfo.proc-id
      ) .
    run local-open-query .
  end.
END PROCEDURE.
