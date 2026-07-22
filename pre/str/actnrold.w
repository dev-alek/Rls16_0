define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование группы прав".
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
define input        parameter parparentproc as widget-handle no-undo .
DEFINE INPUT        PARAMETER p-edit-mode   AS LOGICAL       NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-recid       AS RECID         NO-UNDO.
DEFINE VARIABLE v-context           AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-context-name      AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-context-list      AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-context-list-name AS CHARACTER NO-UNDO INITIAL "Без привязки,Фирма,Объект" .
DEFINE VARIABLE v-db-num            AS INTEGER   NO-UNDO.
DEFINE BUFFER buf_sys-ctrl          FOR sys-ctrl.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE c-context AS CHARACTER FORMAT "X(12)":U INITIAL "Без привязки"
     LABEL "Привязка"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Без привязки","Фирма","Объект"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE v-description AS CHARACTER FORMAT "X(256)":U
     LABEL "Описание"
     VIEW-AS FILL-IN
     SIZE 45 BY 1 NO-UNDO.
DEFINE VARIABLE v-name AS CHARACTER FORMAT "X(40)":U
     LABEL "Название"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 50.57
     v-name AT ROW 2.88 COL 11 COLON-ALIGNED WIDGET-ID 2
     v-description AT ROW 4.19 COL 11 COLON-ALIGNED WIDGET-ID 4
     c-context AT ROW 5.54 COL 11 COLON-ALIGNED WIDGET-ID 8
     SPACE(31.60) SKIP(2.56)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
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
      v-name
      v-description
      c-context
   .
   RUN name-to-cntxt IN THIS-PROCEDURE ( INPUT  entry(1, c-context)
                                      , OUTPUT v-context
                                      ) NO-ERROR.
   RUN check-role IN THIS-PROCEDURE ( v-name:SCREEN-VALUE ) NO-ERROR.
   IF p-edit-mode THEN DO:
      RUN update-role IN THIS-PROCEDURE NO-ERROR.
   END.
   ELSE DO:
      RUN create-role IN THIS-PROCEDURE NO-ERROR.
   END.
   IF ERROR-STATUS:ERROR THEN DO:
      MESSAGE RETURN-VALUE SKIP
              ERROR-STATUS:GET-MESSAGE(1)
      VIEW-AS ALERT-BOX.
      UNDO, RETURN NO-APPLY.
   END.
END.
ON VALUE-CHANGED OF c-context IN FRAME Dialog-Frame
DO:
  RUN name-to-cntxt IN THIS-PROCEDURE ( INPUT  entry(1, c-context)
                                      , OUTPUT v-context
                                      ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     MESSAGE RETURN-VALUE SKIP
             ERROR-STATUS:GET-MESSAGE(1)
     VIEW-AS ALERT-BOX.
     UNDO, RETURN NO-APPLY.
  END.
END.
ON LEAVE OF v-name IN FRAME Dialog-Frame
DO:
    apply "VALUE-CHANGED" TO c-context.
    IF ERROR-STATUS:ERROR THEN DO:
       MESSAGE RETURN-VALUE SKIP
               ERROR-STATUS:GET-MESSAGE(1)
       VIEW-AS ALERT-BOX.
       UNDO, RETURN NO-APPLY.
    END.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
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
  v-context-list = 'global':U + ',' + 'firm':U + ',' + 'object':U.
  FIND FIRST buf_sys-ctrl NO-LOCK NO-ERROR.
  IF NOT AVAILABLE buf_sys-ctrl THEN DO:
     RETURN ERROR ERROR-STATUS:GET-MESSAGE(1).
  END.
  ASSIGN
    v-db-num = buf_sys-ctrl.db-num
  .
  RELEASE buf_sys-ctrl.
  IF p-edit-mode THEN DO:
     FIND FIRST action-role WHERE RECID(action-role) = p-recid
                            NO-ERROR
                            NO-WAIT.
     IF LOCKED action-role THEN DO:
        RETURN ERROR "Группа прав сейчас недоступна для правки, попробуйте позже".
     END.
     IF NOT AVAILABLE action-role THEN DO:
        RETURN ERROR SUBSTITUTE("Не найдена группа прав RECID: &1", p-recid ).
     END.
     ASSIGN
        v-name        = action-role.action-role-name
        v-description = action-role.action-role-description
        v-context     = action-role.action-role-context
     .
     RUN cntxt-to-name ( INPUT  v-context
                       , OUTPUT v-context-name
                       ) .
     ASSIGN
        c-context = v-context-name
        FRAME Dialog-Frame:TITLE = "Редактирование группы прав"
     .
  END.
  ELSE DO:
     ASSIGN
        FRAME Dialog-Frame:TITLE = "Создание группы прав"
     .
  END.
  RUN enable_UI.
  IF p-edit-mode THEN DO:
      RUN post_enable_UI.
  END.
  APPLY "ENTRY" TO v-name.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE check-role :
DEFINE INPUT PARAMETER p-name AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_action-role FOR action-role.
IF p-name = "" THEN DO:
   RETURN ERROR "Заполните имя для группы прав" .
END.
IF NOT p-edit-mode THEN DO:
   IF CAN-FIND( FIRST buf_action-role WHERE buf_action-role.db-num              = v-db-num
                                    AND buf_action-role.action-head-code    = 0
                                    AND buf_action-role.action-role-name    = p-name
                                    AND buf_action-role.action-role-context = v-context
                                 NO-LOCK
         ) THEN DO:
   RETURN ERROR "Группа прав с таким именем уже существует".
   END.
END.
else do:
   IF CAN-FIND( FIRST buf_action-role WHERE buf_action-role.db-num              = v-db-num
                                    AND buf_action-role.action-head-code    = 0
                                    AND buf_action-role.action-role-name    = p-name
                                    AND buf_action-role.action-role-context = v-context
                                    AND RECID(buf_action-role) <> RECID(action-role)
                                 NO-LOCK
         ) THEN DO:
   RETURN ERROR "Группа прав с таким именем уже существует".
   END.
end.
END PROCEDURE.
PROCEDURE cntxt-to-name :
DEFINE INPUT  PARAMETER p-context AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER p-name    AS CHARACTER NO-UNDO.
DEFINE VARIABLE         v-i       AS INTEGER   NO-UNDO.
    DO
    ON ERROR UNDO, RETURN ERROR return-value
    :
       v-i = lookup( p-context, v-context-list, ",":U ) .
       IF v-i <= 0
       OR v-i > NUM-ENTRIES( v-context-list-name )
       THEN DO:
           RETURN ERROR "Неизвестный контекст" .
       END.
       p-name = ENTRY( v-i, v-context-list-name ) .
    END.
END PROCEDURE.
PROCEDURE create-role :
    DEFINE VARIABLE v-action-role-code AS INTEGER NO-UNDO.
    DO TRANSACTION
    ON ERROR UNDO, RETURN ERROR RETURN-VALUE
    :
        RUN check-role IN THIS-PROCEDURE ( INPUT v-name ).
        RUN name-to-cntxt IN THIS-PROCEDURE ( INPUT  entry(1, c-context)
                                            , OUTPUT v-context
                                            ).
        ASSIGN
           v-action-role-code = NEXT-VALUE(s-action-role)
        .
        CREATE action-role.
        ASSIGN
           action-role.db-num                   = v-db-num
           action-role.action-head-code         = 0
           action-role.action-role-code         = v-action-role-code
           action-role.action-role-context      = v-context
           action-role.action-role-name         = v-name
           action-role.action-role-description  = v-description
        NO-ERROR.
        IF ERROR-STATUS:ERROR THEN DO:
           UNDO, RETURN ERROR SUBSTITUTE("&1, &2", ERROR-STATUS:GET-MESSAGE(1), RETURN-VALUE).
        END.
        p-recid = RECID(action-role).
    END.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-name v-description c-context
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-exit b-help v-name v-description c-context
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE name-to-cntxt :
DEFINE INPUT  PARAMETER p-name    AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER p-context AS CHARACTER NO-UNDO.
DEFINE VARIABLE         v-i       AS INTEGER   NO-UNDO.
    DO
    ON ERROR UNDO, RETURN ERROR RETURN-VALUE
    :
       v-i = lookup( p-name, v-context-list-name, ",":U ) .
       IF v-i <= 0
       OR v-i > NUM-ENTRIES( v-context-list )
       THEN DO:
           RETURN ERROR "Неизвестный контекст" .
       END.
       p-context = ENTRY( v-i, v-context-list ) .
    END.
END PROCEDURE.
PROCEDURE post_enable_UI :
  DISABLE c-context
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE update-role :
    DEFINE VARIABLE v-action-role-code AS INTEGER NO-UNDO.
    DO TRANSACTION
    ON ERROR UNDO, RETURN ERROR RETURN-VALUE
    :
        RUN check-role IN THIS-PROCEDURE ( INPUT v-name ).
        FIND CURRENT action-role EXCLUSIVE-LOCK .
        ASSIGN
           action-role.action-role-name         = v-name
           action-role.action-role-description  = v-description
        NO-ERROR.
        IF ERROR-STATUS:ERROR THEN DO:
           UNDO, RETURN ERROR SUBSTITUTE("&1, &2", ERROR-STATUS:GET-MESSAGE(1), RETURN-VALUE).
        END.
    END.
END PROCEDURE.
