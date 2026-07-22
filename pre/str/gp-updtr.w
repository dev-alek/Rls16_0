define input  parameter  ParParentProc as handle no-undo .
define input  parameter  P-Parent as handle no-undo .
define input-output parameter  p-value     as character no-undo .
define input-output parameter  p-full-name as character no-undo .
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
define variable v-mode as character no-undo .
define variable ref-rec   as recid no-undo .
define variable rep-rec2 as recid no-undo .
v-mode = 'ИЗМЕНЕНИЕ':U .
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-clear
     LABEL "&Очистить"
     SIZE 10 BY 1 TOOLTIP "Очистить значение"
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 6 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-OK AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON r-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-cli"
     SIZE 3 BY 1.
DEFINE VARIABLE cli AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Грузополучатель"
     VIEW-AS FILL-IN
     SIZE 10.5 BY 1 NO-UNDO.
DEFINE VARIABLE cli-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 42.5 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE cli-type AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-OK AT ROW 1 COL 1
     B-Cancel AT ROW 1 COL 11
     B-clear AT ROW 1 COL 21 WIDGET-ID 10
     B-Help AT ROW 1 COL 74
     cli AT ROW 3.75 COL 17 COLON-ALIGNED WIDGET-ID 2
     cli-type AT ROW 3.75 COL 28 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     r-cli AT ROW 3.75 COL 34.25 WIDGET-ID 6
     cli-name AT ROW 3.92 COL 35.5 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     SPACE(0.37) SKIP(4.48)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON B-OK CANCEL-BUTTON B-Cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-clear IN FRAME Dialog-Frame
DO:
  if v-mode = 'ПРОСМОТР':U then return.
  assign
    cli = 0
    cli-type = ""
  .
    p-value      = "" .
    p-full-name  = "" .
    cli-name     = "" .
    display  cli  cli-type cli-name  with frame Dialog-Frame .
END.
ON CHOOSE OF B-Help IN FRAME Dialog-Frame
OR HELP OF FRAME Dialog-Frame
DO:
END.
ON CHOOSE OF B-OK IN FRAME Dialog-Frame
DO:
define buffer buf_clients for ub.clients  .
  if v-mode = 'ПРОСМОТР':U then return.
  assign
    cli
    cli-type
  .
   find first buf_clients no-lock where
        buf_clients.obj-code = cli and
        buf_clients.obj-type = cli-type no-error .
        if not available buf_clients and  not(
           cli = 0 and cli-type = "" )
        then do:
           message "Не верно введен Грузополучатель!" view-as alert-box error .
           return no-apply.
        end.
    if cli = 0 and cli-type = "" then do:
        p-value      = "" .
        p-full-name  = "" .
    end.
    else do:
      p-value      = trim(cli-type) + string(cli)  .
      p-full-name  = buf_clients.obj-name          .
    end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON CHOOSE OF r-cli IN FRAME Dialog-Frame
DO:
   run proc-r-cli in this-procedure .
END.
ON LEAVE OF cli IN FRAME Dialog-Frame
DO:
   run leave-proc-cli in this-procedure .
END.
procedure leave-proc-cli :
 do
 on error undo, return error return-value
 :
define buffer cli-clients for ub.clients.
  Assign frame Dialog-Frame cli  cli-type .
  if cli-type = "" then do:
     find cli-clients no-lock where  cli-clients.obj-code = cli no-error.
     if not error-status :error  then
     assign
       cli-type  =  cli-clients.obj-type
       cli-name  =  cli-clients.obj-name
     .
     Display  cli cli-type cli-name with frame Dialog-Frame.
  end.
  else do:
     find first  cli-clients no-lock where  cli-clients.obj-code = cli  and cli-clients.obj-type  = cli-type no-error.
     if available cli-clients then
     assign
       cli-type  =  cli-clients.obj-type
       cli-name  =  cli-clients.obj-name
     .
     else run proc-r-cli .
     Display  cli cli-type cli-name with frame Dialog-Frame.
  end.
end.
end procedure.
ON  RETURN OF cli IN FRAME Dialog-Frame
DO:
    if cli = ?  then run proc-r-cli in this-procedure .
    apply "entry" to cli-type in frame Dialog-Frame.
    return no-apply .
END.
ON MOUSE-SELECT-DBLCLICK OF cli IN FRAME Dialog-Frame
DO:
  apply "choose" to r-cli in frame Dialog-Frame.
  apply "entry" to cli in frame Dialog-Frame.
  return no-apply .
end.
Procedure proc-r-cli :
 do
 on error undo, return error return-value
 :
  define variable rid-list    as  char no-undo .
  define buffer cli#clients for ub.clients.
    run ref/cli-all.w
    ( input parParentProc,
      input "b-sel",
      input 'все':U,
      input ?,
      input ?,
      input ref-rec ,
      input ",,,,,,NO"   ,
      input "",
      output  rid-list
      ) .
    Assign
      rep-rec2 = integer(rid-list)
      ref-rec = integer(rid-list)
      no-error.
    find first cli#clients where recid(cli#clients) = rep-rec2 no-lock no-error.
    if available cli#clients then
        Assign
            cli      = cli#clients.obj-code
            cli-name = cli#clients.obj-name
            cli-type = cli#clients.obj-type
             .
    Display cli cli-type cli-name with frame Dialog-Frame .
end.
end procedure.
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
  frame Dialog-Frame:title = "Определение грузополучателя" .
  assign
    cli = integer(substring(p-value,4,10))
    cli-type = substring(p-value,1,3)
    no-error .
  if error-status :error then do:
      assign
        cli = 0
        cli-type = ""
        .
   end.
   else do:
    apply "LEAVE"  to cli  in frame Dialog-Frame .
   end.
  RUN enable_UI.
  if v-mode <> 'ИЗМЕНЕНИЕ':U then do:
     disable cli cli-type r-cli cli-name  b-clear  with frame Dialog-Frame.
     B-ok:label = "Вы&ход"  .
     hide B-cancel in frame Dialog-Frame .
  END.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY cli cli-type cli-name
      WITH FRAME Dialog-Frame.
  ENABLE B-OK B-Cancel B-clear B-Help cli cli-type r-cli cli-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
