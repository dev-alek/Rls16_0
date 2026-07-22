define input parameter p-sys-today as date no-undo .
define input-output parameter p-date as date no-undo.
define input parameter p-shift-on as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Окно выбора выбора даты закрытия продажи".
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
DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Закрыть ТЕКУЩЕЙ датой"
     SIZE 27 BY 1.17
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Закрыть ВЫБРАННОЙ датой"
     SIZE 27 BY 1.17
     BGCOLOR 8 .
DEFINE VARIABLE f-sys-today AS DATE FORMAT "99/99/9999":U INITIAL ?
     LABEL "Текущая дата на объекте"
      VIEW-AS TEXT
     SIZE 10 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-date AS DATE FORMAT "99/99/9999":U
     LABEL "Выбрать дату"
     VIEW-AS FILL-IN
     SIZE 14.3 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 76.9 BY 7.67.
DEFINE FRAME Dialog-Frame
     B-help AT ROW 1 COL 61
     Btn_OK AT ROW 11 COL 5
     Btn_Cancel AT ROW 11 COL 44.5
     v-date AT ROW 12.67 COL 16 COLON-ALIGNED
     f-sys-today AT ROW 12.77 COL 65 COLON-ALIGNED WIDGET-ID 2
     "Внимание !!!" VIEW-AS TEXT
          SIZE 13 BY 1 AT ROW 5 COL 25.6
          BGCOLOR 8 FGCOLOR 4
     "В этом случае укажите более позднюю дату закрытия документа продажи" VIEW-AS TEXT
          SIZE 74.9 BY 1 AT ROW 9 COL 2.6
          BGCOLOR 8 FGCOLOR 4
     "Дата отчета не сегодняшняя." VIEW-AS TEXT
          SIZE 28 BY 1 AT ROW 3.67 COL 19.1
          BGCOLOR 8 FGCOLOR 4
     "Документ продажи не закроется, если по любому из товаров документа продажи" VIEW-AS TEXT
          SIZE 74.4 BY 1 AT ROW 6.33 COL 2.5
          BGCOLOR 8 FGCOLOR 4
     "более поздней датой был проведен документ инвентаризации" VIEW-AS TEXT
          SIZE 75 BY 1 AT ROW 7.67 COL 2.3
          BGCOLOR 8 FGCOLOR 4
     RECT-1 AT ROW 3 COL 1.5
     SPACE(0.97) SKIP(3.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Определить дату закрытия"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF Btn_Cancel IN FRAME Dialog-Frame
DO:
    assign
    p-date  = p-sys-today
    .
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
    assign
    v-date
    .
  if v-date < p-date then do:
        message
        "Неверно выбрана дата - дата закрытия документа меньше даты, чеков входящих в документ продажи"
        view-as alert-box ERROR.
        return no-apply.
    end.
    if v-date > p-sys-today then do:
        message
        "Неверно выбрана дата - дата закрытия документа больше даты на объекте"
        view-as alert-box ERROR.
        return no-apply.
    end.
  if p-shift-on then do:
    if v-date <> p-date and v-date <> p-sys-today then do:
      message
      "Неверно выбрана дата - для сменного объекта можно закрыть документ либо текущей датой"
      "либо датой чеков, входящих в документ продажи"
      view-as alert-box error .
      return no-apply.
    end.
  end.
    assign
    p-date = v-date
    .
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
  assign
  v-date = (IF p-sys-today < TODAY THEN p-sys-today ELSE p-date)
  f-sys-today = p-sys-today
  .
  RUN enable_UI.
  if p-shift-on then DISABLE v-date.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-date f-sys-today
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 B-help Btn_OK Btn_Cancel v-date f-sys-today
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
