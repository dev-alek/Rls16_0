define input         parameter parparentproc as widget-handle  no-undo .
define INPUT-OUTPUT  parameter p-id          as integer        no-undo .
define input-OUTPUT  parameter p-video-id    as character      no-undo .
define input-OUTPUT  parameter p-system-id   as character      no-undo .
define output        parameter p-ok          as logical        no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование связки события на кассе с СВ".
DEFINE BUFFER buf_cd-events FOR ub.cd-events .
DEFINE BUFFER  buf_cd-video-link FOR ub.cd-video-link .
DEFINE VARIABLE v-message AS CHARACTER NO-UNDO.
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
DEFINE BUTTON b-add AUTO-GO
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
DEFINE BUTTON b-select-event
     LABEL "Button 1"
     SIZE 3 BY 1 TOOLTIP "Выбор события на кассе из справочника".
DEFINE VARIABLE cb-system AS CHARACTER FORMAT "X(256)":U
     LABEL "Система"
     VIEW-AS COMBO-BOX INNER-LINES 2
     LIST-ITEMS "Призма","Интеллект"
     DROP-DOWN-LIST
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE v-event-id AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "Событие на кассе"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE v-video-id AS CHARACTER FORMAT "X(256)":U
     LABEL "Событие в СВ"
     VIEW-AS FILL-IN
     SIZE 46 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-add AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 52.88
     cb-system AT ROW 2.75 COL 14.88 COLON-ALIGNED WIDGET-ID 4
     v-event-id AT ROW 2.75 COL 49.75 COLON-ALIGNED WIDGET-ID 6
     b-select-event AT ROW 2.75 COL 59.88 WIDGET-ID 8
     v-video-id AT ROW 4.08 COL 14.88 COLON-ALIGNED WIDGET-ID 2
     SPACE(2.24) SKIP(0.79)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Связь события на кассе с СВ"
         DEFAULT-BUTTON b-add CANCEL-BUTTON b-quit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
   ASSIGN
    v-video-id
    v-event-id
    cb-system
    v-message = "":U
   .
   RUN chk-link IN THIS-PROCEDURE  (  INPUT  cb-system
                                    , INPUT  v-event-id
                                    , INPUT  v-video-id
                                    , OUTPUT v-message
                                    ) .
   IF v-message <> "":U
   THEN DO:
      message
         v-message
         skip
      view-as alert-box information.
      RETURN NO-APPLY .
   END.
   RUN save-link IN THIS-PROCEDURE (  INPUT  cb-system
                                    , INPUT  v-event-id
                                    , INPUT  v-video-id
                                    , OUTPUT p-ok
                                    ) NO-ERROR.
   IF NOT p-ok
   OR ERROR-STATUS:ERROR
   THEN DO:
      IF p-id = 0 AND p-video-id = "" AND p-system-id = ""
      THEN DO:
         message
            "Ошибка создания записи"
            skip RETURN-VALUE
            skip ERROR-STATUS:get-message(1)
         view-as alert-box information.
      END.
      ELSE DO:
         message
            "Ошибка изменения записи"
            skip RETURN-VALUE
            skip ERROR-STATUS:get-message(1)
         view-as alert-box information.
      END.
   END.
   ELSE DO:
      ASSIGN
         p-id = v-event-id
         p-video-id = v-video-id
         p-system-id = cb-system
          .
     END.
END.
ON CHOOSE OF b-help IN FRAME Dialog-Frame
OR HELP OF FRAME Dialog-Frame
DO:
  MESSAGE "Help for File: c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ref\cdvided.w" VIEW-AS ALERT-BOX INFORMATION.
END.
ON CHOOSE OF b-select-event IN FRAME Dialog-Frame
DO:
   define variable v-rid as CHARACTER no-undo .
   run ref/cd-event.w ( INPUT parparentproc
                      , INPUT "b-sel":U
                      , INPUT-OUTPUT v-rid
                      , OUTPUT p-ok
                      ) .
    IF p-ok THEN DO:
    FIND FIRST buf_cd-events WHERE RECID(buf_cd-events) = integer(v-rid)
        NO-ERROR
        .
    ASSIGN
    v-event-id = (buf_cd-events.event-id)
    .
    DISPLAY v-event-id WITH FRAME dialog-frame.
END.
END.
ON VALUE-CHANGED OF cb-system IN FRAME Dialog-Frame
DO:
ASSIGN
    cb-system
.
END.
ON LEAVE OF v-event-id IN FRAME Dialog-Frame
DO:
   ASSIGN
    v-event-id
   .
END.
ON LEAVE OF v-video-id IN FRAME Dialog-Frame
DO:
   ASSIGN
    v-video-id
   .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
   if p-id <> 0 AND  p-video-id NE "" AND  p-system-id NE ""
   THEN DO:
      assign
         v-message = "":U
      .
      RUN init-link  in THIS-PROCEDURE ( INPUT  p-system-id
                                       , INPUT p-id
                                       , INPUT p-video-id
                                       , OUTPUT v-message
                                       ) .
      IF v-message <> "":U
      THEN DO:
         message
            v-message
            skip
         view-as alert-box information.
         RETURN.
      END.
      ASSIGN
         v-event-id = p-id
         v-video-id = p-video-id
         p-system-id = p-system-id
      .
   END.
   ELSE DO:
    END.
   RUN enable_UI.
   WAIT-FOR GO OF FRAME Dialog-Frame focus cb-system.
END.
RUN disable_UI.
PROCEDURE chk-link :
define input parameter p-s-id      as CHARACTER           no-undo.
define input parameter p-e-id      as integer        no-undo.
define input parameter p-v-id      as CHARACTER       no-undo.
define output parameter p-message  as character        no-undo.
define buffer buf_cd-video-link for ub.cd-video-link .
   IF CAN-FIND (FIRST buf_cd-video-link
                WHERE buf_cd-video-link.video-id = p-s-id
                AND buf_cd-video-link.event-id = p-e-id
                AND buf_cd-video-link.video-event-id = p-v-id
                no-lock
                )
   THEN DO:
      ASSIGN
         p-message = "Уже есть такая связка"
      .
   END.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY cb-system v-event-id v-video-id
      WITH FRAME Dialog-Frame.
  ENABLE b-add b-quit b-help cb-system v-event-id b-select-event v-video-id
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE init-link :
define input parameter p-s-id      as CHARACTER           no-undo.
define input parameter p-e-id      as integer        no-undo.
define input parameter p-v-id      as CHARACTER       no-undo.
define output parameter p-message  as character        no-undo.
do
TRANSACTION
on error undo, return error
:
   FIND FIRST buf_cd-video-link
        WHERE buf_cd-video-link.event-id = p-e-id
        AND buf_cd-video-link.video-id = p-s-id
        AND buf_cd-video-link.video-event-id = p-v-id
        EXCLUSIVE-LOCK
        NO-ERROR
        .
   IF LOCKED buf_cd-video-link
   THEN DO:
      ASSIGN
         p-message = "Запись редактируется другим пользователем"
      .
      RETURN .
   END.
   ASSIGN
      cb-system  = buf_cd-video-link.video-id
      v-event-id = buf_cd-video-link.event-id
      v-video-id = buf_cd-video-link.video-event-id
   .
end.
END PROCEDURE.
PROCEDURE save-link :
define INPUT  parameter p-s-id  as CHARACTER      no-undo.
define INPUT  parameter p-e-id  as integer        no-undo.
define INPUT  parameter p-v-id  as CHARACTER      no-undo.
define output parameter p-ok    as logical        no-undo.
   IF NOT AVAILABLE buf_cd-video-link
   THEN DO:
      CREATE buf_cd-video-link.
      ASSIGN
          buf_cd-video-link.video-id       = p-s-id
          buf_cd-video-link.event-id       = p-e-id
          buf_cd-video-link.video-event-id = p-v-id
          .
   END.
   ASSIGN
          buf_cd-video-link.video-id       = p-s-id
          buf_cd-video-link.event-id       = p-e-id
          buf_cd-video-link.video-event-id = p-v-id
          p-ok                             = TRUE
   .
   END PROCEDURE.
