DEFINE BUFFER buf_global-state      FOR ub.global-state .
DEFINE BUFFER buf_global-state-attr FOR ub.global-state-attr .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Глобальные параметры для включения прав".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE tg-action-gbl AS LOGICAL INITIAL no
     LABEL "Глобальная настройка прав"
     VIEW-AS TOGGLE-BOX
     SIZE 59 BY .79 NO-UNDO.
DEFINE VARIABLE tg-action-gds-groups AS LOGICAL INITIAL no
     LABEL "Включить права на работу с группами товаров"
     VIEW-AS TOGGLE-BOX
     SIZE 59 BY .79 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 55
     tg-action-gds-groups AT ROW 4.08 COL 4 WIDGET-ID 4
     tg-action-gbl AT ROW 5.5 COL 4 WIDGET-ID 6
     SPACE(2.24) SKIP(1.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Включение прав на работу"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  assign
    tg-action-gds-groups
    tg-action-gbl
  .
  RUN global-save IN THIS-PROCEDURE .
    if tg-action-gbl then do:
  end.
END.
ON CHOOSE OF b-help IN FRAME Dialog-Frame
OR HELP OF FRAME Dialog-Frame
DO:
  MESSAGE "Help for File: c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\adm\actngdsg.w" VIEW-AS ALERT-BOX INFORMATION.
END.
ON VALUE-CHANGED OF tg-action-gbl IN FRAME Dialog-Frame
DO:
  assign tg-action-gbl.
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
   RUN global-read IN THIS-PROCEDURE .
   RUN enable_UI.
   run ui-enable in this-procedure.
   WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY tg-action-gds-groups tg-action-gbl
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help tg-action-gds-groups tg-action-gbl
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE global-read :
   FIND FIRST buf_global-state
        NO-LOCK
        .
   FIND FIRST buf_global-state-attr
      WHERE buf_global-state-attr.gls-id = buf_global-state.gls-id
         AND buf_global-state-attr.attr-code = "action-gds-groups"
      NO-LOCK
      NO-error
      .
   IF AVAILABLE buf_global-state-attr
   THEN DO:
      assign
         tg-action-gds-groups = LOGICAL(buf_global-state-attr.attr-value)
      .
      RELEASE buf_global-state-attr .
   END.
   FIND FIRST buf_global-state-attr
      WHERE buf_global-state-attr.gls-id = buf_global-state.gls-id
         AND buf_global-state-attr.attr-code = "action-gbl"
      NO-LOCK
      NO-error
      .
   IF AVAILABLE buf_global-state-attr
   THEN DO:
      assign
         tg-action-gbl = LOGICAL(buf_global-state-attr.attr-value)
      .
      RELEASE buf_global-state-attr .
   END.
END PROCEDURE.
PROCEDURE global-save :
   define variable v-on-gbl as logical no-undo.
   FIND FIRST buf_global-state-attr
      WHERE buf_global-state-attr.gls-id = buf_global-state.gls-id
         AND buf_global-state-attr.attr-code = "action-gds-groups"
      EXCLUSIVE-LOCK
      NO-error
      .
   IF NOT AVAILABLE buf_global-state-attr
   THEN DO:
      create buf_global-state-attr.
      assign
         buf_global-state-attr.gls-id = buf_global-state.gls-id
         buf_global-state-attr.attr-code = "action-gds-groups"
      .
   END.
   assign
      buf_global-state-attr.attr-value = STRING(tg-action-gds-groups)
   .
   FIND FIRST buf_global-state-attr
      WHERE buf_global-state-attr.gls-id = buf_global-state.gls-id
         AND buf_global-state-attr.attr-code = "action-gbl"
      EXCLUSIVE-LOCK
      NO-error
      .
   IF NOT AVAILABLE buf_global-state-attr
   THEN DO:
      create buf_global-state-attr.
      assign
         buf_global-state-attr.gls-id = buf_global-state.gls-id
         buf_global-state-attr.attr-code = "action-gbl"
         v-on-gbl = tg-action-gbl
      .
   END.
   ELSE
      v-on-gbl = (not logical(buf_global-state-attr.attr-value)) and tg-action-gbl.
   assign
      buf_global-state-attr.attr-value = STRING(tg-action-gbl)
   .
   if v-on-gbl then
   do:
     for each action-role no-lock
       where action-role.db-num = 0
     :
       run str/callnews.p
         (input 'action-role':U
         ,input (buffer action-role :handle)
         ).
     end.
     for each action-role-attr no-lock
       where action-role-attr.db-num = 0
     :
       run str/callnews.p
         (input 'action-role-attr':U
         ,input (buffer action-role-attr :handle)
         ).
     end.
     for each action-role-item no-lock
       where action-role-item.db-num = 0
     :
       run str/callnews.p
         (input 'action-role-item':U
         ,input (buffer action-role-item :handle)
         ).
     end.
     for each action-role-item-attr no-lock
       where action-role-item-attr.db-num = 0
     :
       run str/callnews.p
         (input 'action-role-item-attr':U
         ,input (buffer action-role-item-attr :handle)
         ).
     end.
   end.
   RELEASE buf_global-state-attr .
   FIND FIRST buf_global-state
        exclusive-LOCK
        .
   if buf_global-state.whole-send-news = 0 then buf_global-state.whole-send-news = 1.
                                            else buf_global-state.whole-send-news = 0.
   RELEASE buf_global-state .
END PROCEDURE.
PROCEDURE ui-enable :
do
with frame Dialog-Frame
on error undo, return error
:
  if g#db-num <> 0 then do:
    assign
      tg-action-gbl:sensitive = false
    .
  end.
end.
END PROCEDURE.
