define input         parameter parparentproc as widget-handle  no-undo .
define input         parameter p-version     as integer          no-undo.
define input-output  parameter p-id          as integer          no-undo.
define output        parameter p-ok          as logical        no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование события на кассе".
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
define variable v-message    as character    no-undo.
define buffer buf_cd-events      for ub.cd-events .
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
DEFINE VARIABLE cb-type AS CHARACTER FORMAT "X(256)":U INITIAL "U"
     LABEL "Тип"
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEM-PAIRS "Запрос пользователя","U",
                     "Реакция системы","S",
                     "Ошибка","E"
     DROP-DOWN-LIST
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE v-level AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "Уровень"
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEM-PAIRS "Низкий",0,
                     "Средний",1,
                     "Высокий",2
     DROP-DOWN-LIST
     SIZE 10.63 BY 1 NO-UNDO.
DEFINE VARIABLE ed-description AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 42.25 BY 4 TOOLTIP "Описание" NO-UNDO.
DEFINE VARIABLE v-event-id AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "Идентификатор"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE v-name AS CHARACTER FORMAT "X(30)":U
     LABEL "Название"
     VIEW-AS FILL-IN
     SIZE 42.13 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1.25 COL 49.25
     v-event-id AT ROW 2.5 COL 15.38 COLON-ALIGNED WIDGET-ID 16
     v-name AT ROW 3.92 COL 15.38 COLON-ALIGNED WIDGET-ID 4
     cb-type AT ROW 5.38 COL 32.38 COLON-ALIGNED WIDGET-ID 10
     v-level AT ROW 5.42 COL 15.38 COLON-ALIGNED WIDGET-ID 18
     ed-description AT ROW 6.88 COL 17.25 NO-LABEL WIDGET-ID 12
     "Описание" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 7 COL 7.5 WIDGET-ID 14
     SPACE(45.87) SKIP(3.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Событие на кассе"
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
   ASSIGN
    v-event-id
    v-name
    v-level
    cb-type
    ed-description
    v-message = "":U
   .
   RUN chk-event IN THIS-PROCEDURE  ( INPUT v-event-id
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
   RUN save-event IN THIS-PROCEDURE ( INPUT v-event-id
                                    , INPUT v-name
                                    , INPUT v-level
                                    , INPUT cb-type
                                    , INPUT ed-description
                                    , OUTPUT p-ok
                                    ) NO-ERROR.
   IF NOT p-ok
   OR ERROR-STATUS:ERROR
   THEN DO:
      IF p-id = 0
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
      .
   END.
END.
ON CHOOSE OF b-help IN FRAME Dialog-Frame
OR HELP OF FRAME Dialog-Frame
DO:
  MESSAGE "Help for File: c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ref\cdevened.w" VIEW-AS ALERT-BOX INFORMATION.
END.
ON LEAVE OF v-event-id IN FRAME Dialog-Frame
DO:
   ASSIGN
      v-event-id
      v-message = "":U
   .
   RUN chk-event IN THIS-PROCEDURE  ( INPUT v-event-id
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
   if p-id <> 0
   THEN DO:
      assign
         v-message = "":U
      .
      RUN init-event in THIS-PROCEDURE ( INPUT p-id
                                       , OUTPUT v-name
                                       , OUTPUT v-level
                                       , OUTPUT cb-type
                                       , OUTPUT ed-description
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
      .
   END.
   ELSE DO:
      define buffer bf_cd-events      for ub.cd-events .
      FIND LAST bf_cd-events
           USE-INDEX PI
           NO-LOCK
           .
      ASSIGN
         v-event-id = bf_cd-events.event-id + 1
      .
      RELEASE bf_cd-events.
   END.
   RUN enable_UI.
   IF p-id <> 0
   THEN DISABLE  v-event-id WITH FRAME Dialog-Frame.
   WAIT-FOR GO OF FRAME Dialog-Frame focus v-name.
END.
RUN disable_UI.
PROCEDURE chk-event :
define input parameter p-e-id      as integer          no-undo.
define output parameter p-message as character        no-undo.
define buffer bf_cd-events      for ub.cd-events .
   IF CAN-FIND (FIRST bf_cd-events
                WHERE bf_cd-events.event-id = p-e-id
                no-lock
                )
   THEN DO:
      ASSIGN
         p-message = "Уже есть запись с таким идентификатором"
      .
   END.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-event-id v-name cb-type v-level ed-description
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help v-event-id v-name cb-type v-level ed-description
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE init-event :
define input parameter p-e-id      as integer          no-undo.
define output parameter p-name   as character        no-undo.
define output parameter p-level  as integer          no-undo.
define output parameter p-type   as character        no-undo.
define output parameter p-desc   as character        no-undo.
define output parameter p-message as character        no-undo.
do
TRANSACTION
on error undo, return error
:
   FIND FIRST buf_cd-events
        WHERE buf_cd-events.event-id = p-e-id
        EXCLUSIVE-LOCK
        NO-ERROR
        .
   IF LOCKED buf_cd-events
   THEN DO:
      ASSIGN
         p-message = "Запись редактируется другим пользователем"
      .
      RETURN .
   END.
   ASSIGN
      p-name  = buf_cd-events.event-name
      p-level = buf_cd-events.event-level
      p-type  = buf_cd-events.event-type
      p-desc  = buf_cd-events.event-description
   .
end.
END PROCEDURE.
PROCEDURE save-event :
define input parameter p-e-id     as integer          no-undo.
define input parameter p-name   as character        no-undo.
define input parameter p-level  as integer          no-undo.
define input parameter p-type   as character        no-undo.
define input parameter p-desc   as character        no-undo.
define output parameter p-ok    as logical          no-undo.
   IF NOT AVAILABLE buf_cd-events
   THEN DO:
      CREATE buf_cd-events.
      ASSIGN
         buf_cd-events.event-id = p-id
      .
   END.
   ASSIGN
      buf_cd-events.event-id          = p-e-id
      buf_cd-events.event-name        = p-name
      buf_cd-events.event-level       = p-level
      buf_cd-events.event-type        = p-type
      buf_cd-events.event-description = p-desc
      p-ok                            = TRUE
   .
END PROCEDURE.
