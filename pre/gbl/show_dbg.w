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
define input  parameter table for temp-show-file .
define input  parameter p-line-num as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр файла".
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-goto
     LABEL "&Перейти"
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-search
     LABEL "По&иск"
     SIZE 10 BY 1.
DEFINE QUERY BROWSE-3 FOR
      temp-show-file SCROLLING.
DEFINE BROWSE BROWSE-3
  QUERY BROWSE-3 DISPLAY
      temp-show-file.line-text
    WITH NO-ROW-MARKERS SEPARATORS SIZE 126 BY 28 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-goto AT ROW 1 COL 11
     b-search AT ROW 1 COL 21
     b-help AT ROW 1 COL 31
     BROWSE-3 AT ROW 2.25 COL 1.5
     SPACE(0.24) SKIP(0.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Просмотр файла"
         DEFAULT-BUTTON b-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-goto IN FRAME Dialog-Frame
DO:
  define variable v-max-line      as integer   no-undo .
  define variable v-max-line-char as character no-undo .
  define buffer buf_temp-show-file for temp-show-file .
  find last buf_temp-show-file
    use-index xpk
    no-error .
  if available buf_temp-show-file
  then do:
    assign
      v-max-line = buf_temp-show-file.line-num
    .
  end.
  else do:
    message
      "В файле нет ни одной строки" skip
      "Нельзя произвести переход по номеру строки" skip
      view-as alert-box error .
    return no-apply .
  end.
  assign
    v-max-line-char = string(v-max-line)
  .
  run gbl/d-prompt.w (
      'title=':u + "Введите номер строки" + '\':u
    + 'text1=':u + "Введите номер строки" + '\':u
    + 'text2=':u + substitute("от 1 до &1", v-max-line) + '\':u
    + 'format=>>>>>>9\':u
    + 'type=int\':u
    ,input-output v-max-line-char
    ).
  if return-value = 'false':u
  then do:
    return no-apply .
  end.
  assign
    v-max-line = integer(v-max-line-char)
  .
  find first buf_temp-show-file
    where buf_temp-show-file.line-num = v-max-line
    no-error .
  if available buf_temp-show-file
  then do:
    reposition BROWSE-3 to rowid rowid(buf_temp-show-file) .
  end.
  else do:
    message
      "В файле отсутствует строка с номером" v-max-line skip
      view-as alert-box error .
    undo, return no-apply .
  end.
END.
ON CHOOSE OF b-search IN FRAME Dialog-Frame
DO:
  define variable v-search-string as character no-undo .
  define variable v-ok            as logical   no-undo .
  run gbl/d-prompt.w (
      'title=':u + "Введите строку поиска" + '\':u
    + 'text1=':u + "Введите строку поиска" + '\':u
    + 'format=x(255)\':u
    + 'type=char\':u
    + 'fillin_width=60\':u
    ,input-output v-search-string
    ).
  if return-value = 'false':u
  then do:
    return no-apply .
  end.
  define buffer buf_temp-show-file for temp-show-file .
  define variable v-start-search-num as integer   no-undo .
  define variable v-last-search-num  as integer   no-undo .
  define variable v-can-wrap         as logical   no-undo .
  define variable v-find-str         as logical   no-undo .
  assign
    v-start-search-num = temp-show-file.line-num
    v-can-wrap         = true
    v-find-str         = false
  .
  assign
    v-last-search-num = temp-show-file.line-num
  .
  search_block :
  do while true
  :
    find first buf_temp-show-file
      where buf_temp-show-file.line-num = v-last-search-num
      no-error .
    if not available buf_temp-show-file
    then do:
      if  v-start-search-num > 1
      and v-can-wrap = true
      then do:
        message
          "Строка не найдена" skip
          "Строка поиска" v-search-string  skip
          "Продолжить поиск с начала файла?" skip
          view-as alert-box question buttons yes-no update v-ok
          .
        if v-ok = true
        then do:
          assign
            v-can-wrap = false
          .
          find first buf_temp-show-file
            use-index xpk
            no-error .
        end.
        else do:
          leave search_block .
        end.
      end.
      else do:
        leave search_block .
      end.
    end.
    if buf_temp-show-file.line-text matches '*':u + v-search-string + '*':u
    then do:
      assign
        v-find-str = true
      .
      reposition BROWSE-3 to rowid rowid(buf_temp-show-file) .
      leave search_block .
    end.
    assign
      v-last-search-num = v-last-search-num + 1
    .
  end.
  if v-find-str <> true
  then do:
    message
      "Строка поиска на найдена" skip
      "Строка поиска" v-search-string skip
      view-as alert-box error .
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  BROWSE-3 :SET-REPOSITIONED-ROW(10, "CONDITIONAL") .
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  define buffer buf_temp-show-file for temp-show-file .
  find first buf_temp-show-file
    where buf_temp-show-file.line-num = p-line-num
    no-error .
  if available buf_temp-show-file
  then do:
    reposition BROWSE-3 to rowid rowid(buf_temp-show-file) .
  end.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE b-exit b-goto b-search b-help BROWSE-3
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-3 FOR EACH temp-show-file by temp-show-file.line-num   indexed-reposition .
END PROCEDURE.
