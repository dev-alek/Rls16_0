define input parameter p-parent-handle as handle    no-undo.
DEFINE INPUT PARAMETER p-run-file-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-parameters AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-title AS CHARACTER NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
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
define stream sinp .
define variable v-running     as logical   no-undo .
define variable v-stop-run  as logical   no-undo .
define variable v-pause-run as logical   no-undo .
define variable v-run-time-start  as decimal   no-undo .
define variable v-run-time-finish as decimal   no-undo .
define variable v-run-ind      as integer   no-undo .
define variable v-need-run-ind as integer   no-undo .
define variable v-error-ind        as integer   no-undo .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-pause
     LABEL "&Пауза"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.
DEFINE BUTTON b-run DEFAULT
     LABEL "_ &Выполнить"
     SIZE 13 BY 1.
DEFINE BUTTON i-exit
     IMAGE-UP FILE "cmp/i-run.bmp":U
     IMAGE-DOWN FILE "cmp/i-run.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/i-rund.bmp":U
     LABEL ""
     SIZE 2.5 BY .75.
DEFINE VARIABLE log-edit AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL LARGE
     SIZE 76.13 BY 10.79 NO-UNDO.
DEFINE VARIABLE fi-error AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "Ошибок"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE fi-finish-time AS CHARACTER FORMAT "X(256)":U
     LABEL "Завершение"
      VIEW-AS TEXT
     SIZE 30.25 BY .67 NO-UNDO.
DEFINE VARIABLE fi-need-run AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "Осталось"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE fi-run AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "Выполнено"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE fi-start-time AS CHARACTER FORMAT "X(256)":U
     LABEL "Начало"
      VIEW-AS TEXT
     SIZE 30.25 BY .67 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-run AT ROW 1 COL 1
     b-quit AT ROW 1 COL 14
     b-pause AT ROW 1 COL 24
     B-Help AT ROW 1 COL 69.5
     i-exit AT ROW 1.13 COL 1.5 WIDGET-ID 4
     log-edit AT ROW 5.5 COL 2.5 NO-LABEL
     fi-run AT ROW 2.29 COL 19 COLON-ALIGNED
     fi-start-time AT ROW 2.29 COL 45.13 COLON-ALIGNED
     fi-finish-time AT ROW 3.29 COL 45.13 COLON-ALIGNED
     fi-need-run AT ROW 3.33 COL 19 COLON-ALIGNED
     fi-error AT ROW 4.33 COL 19 COLON-ALIGNED
     SPACE(45.49) SKIP(11.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       log-edit:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-pause IN FRAME Dialog-Frame
DO:
  run pause-run in this-procedure .
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
  run stop-run in this-procedure .
END.
ON CHOOSE OF b-run IN FRAME Dialog-Frame
DO:
  run start-run in this-procedure .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  ASSIGN
  FRAME Dialog-Frame:TITLE = p-title.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE callback-check-stop-run :
  define output parameter p-stop-run  as logical   no-undo .
  define output parameter p-pause-run as logical   no-undo .
  assign
    p-stop-run  = v-stop-run
    p-pause-run = v-pause-run
  .
  assign
    v-stop-run  = false
    v-pause-run = false
  .
END PROCEDURE.
PROCEDURE callback-display-run :
  define input  parameter  p-run-ind      as integer   no-undo .
  define input  parameter  p-need-run-ind as integer   no-undo .
  define input  parameter  p-error-ind        as integer   no-undo .
  assign
    v-run-ind      = p-run-ind
    v-need-run-ind = p-need-run-ind
    v-error-ind        = p-error-ind
  .
  define variable v-curr-time as decimal   no-undo .
  assign
    v-curr-time = integer(today) + time / 86400.0
  .
  if v-run-ind > 0
  and v-run-ind modulo 10 = 0
  then do:
    assign
      v-run-time-finish = (v-curr-time - v-run-time-start)
                            / v-run-ind
                            * v-need-run-ind
                            + v-curr-time
    .
  end.
  if  v-run-ind > 0
  and v-run-time-finish > v-run-time-start
  then do:
    define variable v-start-time-string as character no-undo .
    define variable v-finish-time-string as character no-undo .
    define variable v-ref-date        as date      no-undo .
    define variable v-start-date-ind  as integer   no-undo .
    define variable v-finish-date-ind as integer   no-undo .
    assign
      v-ref-date        = today
      v-start-date-ind  = integer(truncate(v-run-time-start, 0))
      v-finish-date-ind = integer(truncate(v-run-time-finish, 0))
    .
    assign
      v-start-time-string   = string(v-ref-date + v-start-date-ind - integer(v-ref-date), '99/99/9999':U)
                            + "  ":U
                            + string(integer(truncate((v-run-time-start - truncate(v-run-time-start, 0)) * 86400, 0)), 'HH:MM':U)
      v-finish-time-string  = string(v-ref-date + v-finish-date-ind - integer(v-ref-date), '99/99/9999':U)
                            + "  ":U
                            + string(integer(truncate((v-run-time-finish - truncate(v-run-time-finish, 0)) * 86400, 0)), 'HH:MM':U)
    .
  end.
  else do:
    assign
    v-ref-date        = today
    v-start-date-ind  = integer(truncate(v-run-time-start, 0))
    v-start-time-string   = string(v-ref-date + v-start-date-ind - integer(v-ref-date), '99/99/9999':U)
                            + "  ":U
                            + string(integer(truncate((v-run-time-start - truncate(v-run-time-start, 0)) * 86400, 0)), 'HH:MM':U)
    .
  end.
  display
    v-run-ind        @ fi-run
    v-need-run-ind   @ fi-need-run
    v-error-ind          @ fi-error
    v-start-time-string  @ fi-start-time
    v-finish-time-string @ fi-finish-time
    with frame Dialog-Frame .
END PROCEDURE.
PROCEDURE callback-set-start-run-time :
  assign
    v-run-time-start = integer(today) + time / 86400.0
  .
END PROCEDURE.
PROCEDURE callback-write-to-log :
  define input parameter p-msg-str as character no-undo .
  define variable lok as logical   no-undo .
  do with frame Dialog-Frame
  on error undo, return error
  :
    assign
      lok = log-edit :move-to-eof( )
      lok = log-edit :insert-string( p-msg-str )
      lok = log-edit :move-to-eof( )
    .
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY log-edit fi-run fi-start-time fi-finish-time fi-need-run fi-error
      WITH FRAME Dialog-Frame.
  ENABLE b-run b-quit b-pause B-Help i-exit log-edit fi-run fi-start-time
         fi-finish-time fi-need-run fi-error
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE pause-run :
 assign
    v-pause-run = true
  .
END PROCEDURE.
PROCEDURE start-run :
  assign
    v-running     = true
    v-stop-run  = false
    v-pause-run = false
  .
  run value(p-run-file-name) in p-parent-handle
    (input this-procedure :handle
     ,INPUT p-parameters
    ) .
  assign
    v-running = false
  .
END PROCEDURE.
PROCEDURE stop-run :
  if v-running = true
  then do:
    assign
      v-stop-run = true
    .
  end.
  else do:
    apply 'close':u to this-procedure .
  end.
END PROCEDURE.
