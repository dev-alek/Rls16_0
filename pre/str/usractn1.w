DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-user-id     AS CHARACTER     NO-UNDO.
DEFINE INPUT PARAMETER p-db-num      AS integer       NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type      AS CHARACTER        NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code      AS integer       NO-UNDO.
DEFINE TEMP-TABLE tt-work-place NO-UNDO
    FIELD wp-code AS INTEGER   column-label "№"             FORMAT ">>>>9"
    FIELD wp-type AS CHARACTER column-label "тип"           FORMAT "x(3)"
    FIELD wp-host AS INTEGER   column-label "фирма"         FORMAT ">>>>9"
    FIELD wp-name AS CHARACTER column-label "наименование"  FORMAT "x(40)"
    FIELD context AS CHARACTER column-label "привязка"
    FIELD db-num  AS INTEGER   column-label "БД"            FORMAT ">>>>9"
INDEX i-code-type IS PRIMARY UNIQUE
      wp-code
      wp-type
INDEX i-host
      wp-host
index i-context
      context
.
define temp-table temp_filter-fields no-undo
    field action-role-code as integer
    field record-on        as logical
    index pi is primary unique
        action-role-code
.
define temp-table temp_filter-fields-item no-undo
    field action-item-code as integer
    field record-on        as logical
    index pi is primary unique
        action-item-code
.
define buffer br_tt-work-place            for tt-work-place.
define buffer br_user-login-action-role   for user-login-action-role.
define buffer buf_user-login-action-role  for user-login-action-role.
define buffer br_action-role             for action-role.
define buffer br_action-role-item        for action-role-item.
define buffer br_action-item             for action-item.
define buffer br_temp_filter-fields-item for temp_filter-fields-item .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование привязки группы прав к пользователю из списка объектов или фирм".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function usrnickf returns character ( input p-user-id as character):
   define variable v-nick      as character    no-undo.
   if p-user-id = ?
   OR p-user-id = "":U
   then do:
      return '':U .
   end.
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrnick in g#library
  (input  p-user-id
  ,output v-nick
  ) no-error .
   if error-status :error
   then do:
      return p-user-id.
   end.
   else do:
      return v-nick.
   end.
end function.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define variable v-context  as character no-undo format "x(8)" column-label "Привязка".
define variable v-state    as character no-undo format "x(3)" column-label "Вкл" .
DEFINE VARIABLE g#log      AS LOGICAL   NO-UNDO.
define variable v-flt-role    as character    no-undo.
define variable v-flt-item    as character    no-undo.
define variable v-on-gbl    as logical      no-undo.
FUNCTION get-item-state RETURNS CHARACTER
  ( BUFFER buf_action-item FOR action-item )  FORWARD.
FUNCTION get-role-context RETURNS CHARACTER
  ( BUFFER buf_user-login-action-role FOR user-login-action-role )  FORWARD.
DEFINE BUTTON b-add
     LABEL "Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-del
     LABEL "Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-filter
     LABEL "ФПоиск"
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE item-EDITOR AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 47.5 BY 1.58 TOOLTIP "Описание права" NO-UNDO.
DEFINE VARIABLE role-EDITOR AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 49.5 BY 1.5 TOOLTIP "Описание группы" NO-UNDO.
DEFINE VARIABLE v-filter AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 44.5 BY 1 NO-UNDO.
DEFINE VARIABLE tb-filter AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .83 NO-UNDO.
DEFINE VARIABLE tg-detail AS LOGICAL INITIAL yes
     LABEL "Детализировать по группам"
     VIEW-AS TOGGLE-BOX
     SIZE 27.5 BY .75 NO-UNDO.
DEFINE QUERY browse-action-item FOR
      buf_user-login-action-role,
      br_action-role-item,
      br_temp_filter-fields-item,
      br_action-item SCROLLING.
DEFINE QUERY browse-br_user-login-action-role FOR
      br_user-login-action-role,
      br_action-role,
      temp_filter-fields SCROLLING.
DEFINE BROWSE browse-action-item
  QUERY browse-action-item DISPLAY
         br_action-item.action-item-name
         br_action-item.action-item-id
    WITH NO-ROW-MARKERS SEPARATORS SIZE 47.5 BY 15.5.
DEFINE BROWSE browse-br_user-login-action-role
  QUERY browse-br_user-login-action-role DISPLAY
      get-role-context(BUFFER br_user-login-action-role) @ v-context column-label "Привязка"
      br_action-role.action-role-name                                column-label "Название группы прав"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 49.5 BY 15.5.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-add AT ROW 1 COL 11 WIDGET-ID 6
     b-del AT ROW 1 COL 21 WIDGET-ID 8
     b-help AT ROW 1 COL 89.5
     tg-detail AT ROW 1.08 COL 31.5 WIDGET-ID 14
     b-filter AT ROW 2 COL 1 WIDGET-ID 16
     v-filter AT ROW 2 COL 9 COLON-ALIGNED NO-LABEL WIDGET-ID 18 NO-TAB-STOP
     tb-filter AT ROW 2 COL 57 WIDGET-ID 20
     browse-br_user-login-action-role AT ROW 3.25 COL 1.5 WIDGET-ID 200
     browse-action-item AT ROW 3.25 COL 51.75 WIDGET-ID 300
     role-EDITOR AT ROW 19 COL 1.5 NO-LABEL WIDGET-ID 22
     item-EDITOR AT ROW 19 COL 52 NO-LABEL WIDGET-ID 24
     SPACE(0.00) SKIP(0.08)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Права пользователя"
         DEFAULT-BUTTON b-exit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       item-EDITOR:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       role-EDITOR:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-filter:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
   IF available br_tt-work-place THEN do:
      RUN add-action-roles in this-procedure no-error.
      IF ERROR-STATUS:ERROR THEN DO:
         MESSAGE RETURN-VALUE SKIP
                  ERROR-STATUS:GET-MESSAGE(1)
         VIEW-AS ALERT-BOX.
         UNDO, RETURN NO-APPLY.
      END.
      run assign-filter-mark in this-procedure (
            input v-flt-role
         , input v-flt-item
      ).
      run refresh-action-role in this-procedure .
      run post_enable_UI IN THIS-PROCEDURE.
   end.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
   IF AVAILABLE br_action-role THEN DO:
      MESSAGE SUBSTITUTE( "Отключить группу прав (&1) для пользователя &2?"
                        , br_action-role.action-role-name
                        , usrnickf( p-user-id )
                        )
      VIEW-AS ALERT-BOX
      BUTTONS YES-NO
      UPDATE v-yes AS LOGICAL
      .
      IF v-yes THEN DO:
         RUN delete-user-role.
      END.
      run refresh-action-role in this-procedure .
      run post_enable_UI IN THIS-PROCEDURE.
   END.
END.
ON CHOOSE OF b-filter IN FRAME Dialog-Frame
DO:
   define variable v-ok    as logical      no-undo.
      run adm/actnrolf.w (
          input-output v-flt-role
        , input-output v-flt-item
        , output v-ok
    ) no-error.
   if error-status :error
   then do:
      message
               vss-workfile vss-revision vss-description
         skip(1)
         skip "Ошибка изменения фильтра."
         skip return-value
         skip trim( error-status :get-message( 1 ) )
               trim( error-status :get-message( 2 ) )
               trim( error-status :get-message( 3 ) )
      view-as alert-box error.
      undo, return no-apply.
   end.
   IF NOT v-ok then do:
      RETURN NO-APPLY.
   end.
   IF v-flt-role <> "":U THEN DO:
      IF v-flt-item <> "":U THEN DO:
      assign
         v-filter = SUBSTITUTE("В группе: &1, в правах: &2", v-flt-role, v-flt-item)
      .
      END.
      else do:
      assign
         v-filter = SUBSTITUTE("В группе: &1", v-flt-role)
      .
      end.
   end.
   else do:
      IF v-flt-item <> "":U THEN DO:
      assign
         v-filter = SUBSTITUTE("В правах: &1", v-flt-item)
      .
      END.
      else do:
      assign
         v-filter = "":U
      .
      end.
   end.
   if v-filter = "":U
   then do:
      assign
            tb-filter               = no
            tb-filter :sensitive    = no
      .
      assign
            v-filter :bgcolor   = GREY_COLOR
            b-filter :bgcolor = GREY_COLOR
      .
   end.
   else do:
      assign
            tb-filter = yes
            tb-filter :sensitive    = yes
      .
      assign
            v-filter :bgcolor = RED_COLOR
            b-filter :bgcolor = RED_COLOR
      .
   end.
   display
      v-filter
      tb-filter
   with frame Dialog-Frame.
if session :set-wait-state( "compiler" ) then.
   run assign-filter-mark in this-procedure (
         input v-flt-role
      , input v-flt-item
   ).
   RUN enable_UI.
   RUN post_enable_UI IN THIS-PROCEDURE.
if session :set-wait-state( "" ) then.
END.
ON VALUE-CHANGED OF browse-action-item IN FRAME Dialog-Frame
DO:
   if available br_action-item then do:
    assign
        item-editor = br_action-item.action-item-description
    .
    display
      item-editor
    with frame Dialog-Frame.
  end.
END.
ON VALUE-CHANGED OF browse-br_user-login-action-role IN FRAME Dialog-Frame
DO:
  run refresh-action-item in this-procedure .
  if available br_action-role then do:
      assign
          role-editor = br_action-role.action-role-description
      .
      display
         role-editor
      with frame Dialog-Frame.
    end.
END.
ON VALUE-CHANGED OF tb-filter IN FRAME Dialog-Frame
DO:
    assign
        tb-filter
    .
    if tb-filter = yes
    then do:
        assign
            v-filter :bgcolor = RED_COLOR
            b-filter :bgcolor = RED_COLOR
        .
         run assign-filter-mark in this-procedure (
               input v-flt-role
            , input v-flt-item
         ).
    end.
    else do:
        assign
            v-filter :bgcolor = GREY_COLOR
            b-filter :bgcolor = GREY_COLOR
        .
         run assign-filter-mark in this-procedure (
               input "":U
             , input "":U
         ).
    end.
   RUN enable_UI.
   RUN post_enable_UI IN THIS-PROCEDURE.
END.
ON VALUE-CHANGED OF tg-detail IN FRAME Dialog-Frame
DO:
  IF LOGICAL(tg-detail:screen-value) then do:
      assign
         browse-br_user-login-action-role:hidden = FALSE
      .
      ENABLE
         browse-br_user-login-action-role
         b-del
      WITH FRAME Dialog-Frame.
  end.
  else do:
      assign
         browse-br_user-login-action-role:hidden = TRUE
      .
      disable
        browse-br_user-login-action-role
        b-del
      WITH FRAME Dialog-Frame.
  end.
   run assign-filter-mark in this-procedure (
         input v-flt-role
      , input v-flt-item
   ).
  RUN refresh-action-role IN THIS-PROCEDURE .
  run post_enable_UI IN THIS-PROCEDURE.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse browse-action-item :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run actn-gbl in g#library2
    ( output v-on-gbl
    ) no-error .
end.
  RUN fill-wp IN THIS-PROCEDURE.
  FIND FIRST br_tt-work-place no-lock.
       ASSIGN
        FRAME Dialog-Frame:TITLE = SUBSTITUTE ( "Права пользователя &1 для &2"
                                              , usrnickf( p-user-id )
                                              , IF p-obj-type = 'орг':U
                                                THEN Substitute("фирмы &1", p-obj-code)
                                                ELSE Substitute(" &1 &2", p-obj-type, p-obj-code)
                                              )
     .
    run assign-filter-mark in this-procedure (
          input v-flt-role
        , input v-flt-item
    ).
  RUN enable_UI.
  RUN post_enable_UI IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE add-action-roles :
  define variable v-action-role-code     as integer   no-undo .
  define variable current-role           as integer   no-undo .
  define variable v-rid-list             as character no-undo .
  define variable v-context              as character no-undo .
  define variable v-obj-code             as integer   no-undo .
  define variable v-obj-type             as character no-undo .
  define variable v-host-code            as integer   no-undo .
  define variable v-user-select          as logical   no-undo .
   do
   on error undo, return error return-value
   :
      ASSIGN
         v-context = br_tt-work-place.context
      .
      run str/actnrole.w ( input parparentproc
                        , input  'b-sel,b-mark':U
                        , input-output v-context
                        , output v-action-role-code
                        , INPUT-OUTPUT v-rid-list
                        , input p-db-num
                        ) .
      IF v-context <> br_tt-work-place.context THEN DO:
         message
            "Выбранное право не соответствует типу объекта"
            skip
         view-as alert-box information.
         RETURN.
      END.
      IF v-rid-list <> "" THEN
      DO current-role = 1 TO NUM-ENTRIES(v-rid-list) :
         case v-context :
            WHEN 'firm':U THEN DO:
               RUN add-one-action-role ( INPUT ENTRY(current-role, v-rid-list)
                                       , INPUT 0
                                       , INPUT '':U
                                       , INPUT br_tt-work-place.wp-code
                                       ).
            END.
            WHEN 'object':U THEN DO:
               RUN add-one-action-role ( INPUT ENTRY(current-role, v-rid-list)
                                       , INPUT br_tt-work-place.wp-code
                                       , INPUT br_tt-work-place.wp-type
                                       , INPUT 0
                                       ).
            END.
            OTHERWISE DO:
               RUN add-one-action-role ( INPUT ENTRY(current-role, v-rid-list)
                                       , INPUT 0
                                       , INPUT '':U
                                       , INPUT 0
                                       ).
            END.
         END.
      END.
   end.
END PROCEDURE.
PROCEDURE add-one-action-role :
DEFINE INPUT PARAMETER p-rid AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code      AS INTEGER   NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type      AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-host-code     AS INTEGER   NO-UNDO.
DEFINE BUFFER buf_action-role            FOR action-role.
DEFINE BUFFER buf_user-login-action-role FOR user-login-action-role.
   do
   on error undo, return error return-value
   :
      FIND FIRST buf_action-role WHERE RECID(buf_action-role) = INTEGER(p-rid)
                                 NO-LOCK.
      IF NOT CAN-FIND( FIRST buf_user-login-action-role
                       WHERE buf_user-login-action-role.db-num           = p-db-num
                         AND buf_user-login-action-role.action-head-code = 0
                         AND buf_user-login-action-role.action-role-code = buf_action-role.action-role-code
                         AND buf_user-login-action-role.action-role-context  = buf_action-role.action-role-context
                         AND buf_user-login-action-role.user-id          = p-user-id
                         AND buf_user-login-action-role.host-code            = p-host-code
                         AND buf_user-login-action-role.obj-type             = p-obj-type
                         AND buf_user-login-action-role.obj-code             = p-obj-code
                     )
      THEN DO:
         create buf_user-login-action-role .
         assign
           buf_user-login-action-role.db-num               = p-db-num
           buf_user-login-action-role.action-head-code     = 0
           buf_user-login-action-role.user-login-role-code = NEXT-VALUE(s-user-login-action-role)
           buf_user-login-action-role.user-id              = p-user-id
           buf_user-login-action-role.action-role-code     = buf_action-role.action-role-code
           buf_user-login-action-role.action-role-context  = buf_action-role.action-role-context
           buf_user-login-action-role.host-code            = p-host-code
           buf_user-login-action-role.obj-type             = p-obj-type
           buf_user-login-action-role.obj-code             = p-obj-code
           buf_user-login-action-role.gds-grp-code         = ?
           buf_user-login-action-role.gds-code             = ?
           buf_user-login-action-role.cli-grp-code         = ?
         .
      END.
    END.
END PROCEDURE.
PROCEDURE assign-filter-mark :
define input parameter p-name-filter    as character        no-undo.
define input parameter p-name2-filter   as character        no-undo.
define buffer buf_action-role          for action-role .
define buffer buf_action-role-item     for action-role-item .
define buffer buf_action-item          for action-item .
define buffer buf_temp_filter-fields   for temp_filter-fields .
define buffer buf_user-login-action-role     for user-login-action-role .
do
on error undo, return error
:
   IF available br_tt-work-place THEN DO:
      FOR EACH buf_user-login-action-role WHERE buf_user-login-action-role.db-num           = p-db-num
                                          AND buf_user-login-action-role.action-head-code    = 0
                                          AND buf_user-login-action-role.user-id             = p-user-id
                                          AND buf_user-login-action-role.action-role-context = br_tt-work-place.context
                                          AND (
                                             (br_tt-work-place.context = 'global':U)
                                             OR
                                             (br_tt-work-place.context = 'firm':U
                                                AND
                                                buf_user-login-action-role.host-code = br_tt-work-place.wp-code
                                             )
                                             OR
                                             (br_tt-work-place.context = 'object':U
                                                AND
                                                buf_user-login-action-role.obj-code = br_tt-work-place.wp-code
                                                AND
                                                buf_user-login-action-role.obj-type = br_tt-work-place.wp-type
                                             )
                                             )
            no-lock,
            FIRST buf_action-role        WHERE buf_action-role.db-num                      = (if v-on-gbl then 0 else p-db-num)
                                          AND buf_action-role.action-head-code            = 0
                                          AND buf_action-role.action-role-code            = buf_user-login-action-role.action-role-code
                                          and buf_action-role.action-role-context         = br_tt-work-place.context
                                       NO-LOCK
                                       :
        find first buf_temp_filter-fields
             where buf_temp_filter-fields.action-role-code = buf_action-role.action-role-code
        no-error.
        if not available buf_temp_filter-fields
        then do:
            create buf_temp_filter-fields.
            assign
                buf_temp_filter-fields.action-role-code = buf_action-role.action-role-code
                buf_temp_filter-fields.record-on = no
            .
        end.
        if ( p-name-filter = "":U AND p-name2-filter = "":U)
        or (( p-name-filter <> "":U )
        and index(buf_action-role.action-role-name , p-name-filter ) <> 0 )
        or (( p-name-filter <> "":U )
        and index(buf_action-role.action-role-description , p-name-filter ) <> 0 )
        then do:
            assign
                buf_temp_filter-fields.record-on = yes
            .
        end.
        else do:
            assign
                buf_temp_filter-fields.record-on = no
            .
            search-in-item:
            for each buf_action-role-item
                where buf_action-role-item.db-num           = buf_action-role.db-num
                  and buf_action-role-item.action-head-code = buf_action-role.action-head-code
                  and buf_action-role-item.action-role-code = buf_action-role.action-role-code
                no-lock,
                first buf_action-item
                where buf_action-item.action-head-code = buf_action-role.action-head-code
                  and buf_action-item.action-item-code = buf_action-role-item.action-item-code
            :
                if ( p-name2-filter = "":U AND p-name-filter = "":U)
                OR index( buf_action-item.action-item-name, p-name2-filter ) <> 0
                or index( buf_action-item.action-item-description, p-name2-filter ) <> 0
                then do:
                    assign
                        buf_temp_filter-fields.record-on = yes
                    .
                    leave search-in-item.
                end.
            end.
        end.
    end.
    end.
end.
END PROCEDURE.
PROCEDURE delete-user-role :
   define buffer buf_user-login-action-role     for user-login-action-role.
   DO
   TRANSACTION
   ON ERROR UNDO, RETURN
   :
      FIND FIRST buf_user-login-action-role
           WHERE RECID(buf_user-login-action-role) = RECID(br_user-login-action-role)
           EXCLUSIVE-LOCK
           .
      DELETE buf_user-login-action-role.
   END.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY tg-detail v-filter tb-filter role-EDITOR item-EDITOR
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-add b-del b-help tg-detail b-filter v-filter tb-filter
         browse-br_user-login-action-role browse-action-item role-EDITOR
         item-EDITOR
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  RUN refresh-action-item .    RUN refresh-action-role IN THIS-PROCEDURE .
END PROCEDURE.
PROCEDURE fill-wp :
DEFINE BUFFER buf_user-obj  FOR user-obj.
DEFINE BUFFER buf_user-host FOR user-host.
DEFINE BUFFER buf_clients   FOR clients.
do
on error undo, return error
:
   IF p-obj-type = 'орг':U THEN DO:
      FOR FIRST buf_user-host
          WHERE buf_user-host.db-num  = p-db-num
            AND buf_user-host.USER-ID = p-user-id
            AND buf_user-host.host-code = p-obj-code
         NO-LOCK
         :
         FIND FIRST buf_clients
               WHERE buf_clients.obj-code = buf_user-host.host-code
               AND buf_clients.obj-type = 'орг':U
               NO-LOCK
            .
         CREATE br_tt-work-place.
         ASSIGN
            br_tt-work-place.wp-code = buf_clients.obj-code
            br_tt-work-place.wp-type = buf_clients.obj-type
            br_tt-work-place.wp-host = buf_clients.obj-code
            br_tt-work-place.db-num  = buf_clients.db-num
            br_tt-work-place.context = 'firm':U
            br_tt-work-place.wp-name = buf_clients.obj-name
         .
      END.
   end.
   else do:
      FOR FIRST buf_user-obj
         WHERE buf_user-obj.db-num = p-db-num
         AND buf_user-obj.USER-ID  = p-user-id
         AND buf_user-obj.obj-type = p-obj-type
         AND buf_user-obj.obj-code = p-obj-code
         NO-LOCK
         :
         FIND FIRST buf_clients
            WHERE buf_clients.obj-code = buf_user-obj.obj-code
               AND buf_clients.obj-type = buf_user-obj.obj-type
            NO-LOCK
            .
         IF  buf_clients.db-num <> p-db-num
         and p-db-num <> 0
         then do:
            next.
         end.
         CREATE br_tt-work-place.
         ASSIGN
            br_tt-work-place.wp-code = buf_clients.obj-code
            br_tt-work-place.wp-type = buf_clients.obj-type
            br_tt-work-place.wp-host = buf_clients.host-code
            br_tt-work-place.db-num  = buf_clients.db-num
            br_tt-work-place.context = 'object':U
            br_tt-work-place.wp-name = buf_clients.obj-name
         .
      END.
   END.
end.
END PROCEDURE.
PROCEDURE filter-for-item :
define input parameter p-name-filter    as character        no-undo.
define buffer buf_action-role-item        for action-role-item .
define buffer buf_temp_filter-fields-item for temp_filter-fields-item .
define buffer buf_action-item             for action-item .
define buffer buf_user-login-action-role  for user-login-action-role .
do
on error undo, return error
:
   IF AVAILABLE br_user-login-action-role then do:
      IF LOGICAL(tg-detail:screen-value in FRAME Dialog-Frame) then do:
         FOR EACH buf_action-role-item
               WHERE buf_action-role-item.db-num = p-db-num
                  AND buf_action-role-item.action-head-code   = 0
                  AND buf_action-role-item.action-role-code   = br_user-login-action-role.action-role-code
               NO-LOCK,
               first buf_action-item
               where buf_action-item.action-head-code     = 0
                  AND buf_action-item.action-item-code    = buf_action-role-item.action-item-code
               no-lock
         :
            find first buf_temp_filter-fields-item
                  where buf_temp_filter-fields-item.action-item-code = buf_action-item.action-item-code
            no-error.
            if not available buf_temp_filter-fields-item
            then do:
                  create buf_temp_filter-fields-item.
                  assign
                     buf_temp_filter-fields-item.action-item-code = buf_action-item.action-item-code
                     buf_temp_filter-fields-item.record-on = no
                  .
            end.
            if ( p-name-filter = "":U )
            or index( buf_action-item.action-item-name, p-name-filter ) <> 0
            or index( buf_action-item.action-item-description, p-name-filter ) <> 0
            then do:
               assign
                  buf_temp_filter-fields-item.record-on = yes
               .
            end.
            else do:
               assign
                  buf_temp_filter-fields-item.record-on = no
               .
            end.
         end.
      end.
      else do:
         FOR EACH  buf_user-login-action-role
             WHERE buf_user-login-action-role.db-num             = p-db-num
              AND  buf_user-login-action-role.action-head-code   = 0
              AND  buf_user-login-action-role.user-id            = p-user-id
             no-lock
             ,
             EACH buf_action-role-item
               WHERE buf_action-role-item.db-num = p-db-num
                  AND buf_action-role-item.action-head-code   = 0
                  AND buf_action-role-item.action-role-code   = buf_user-login-action-role.action-role-code
               NO-LOCK,
               first buf_action-item
               where buf_action-item.action-head-code    = 0
                  AND buf_action-item.action-item-code    = buf_action-role-item.action-item-code
               no-lock
         :
            find first buf_temp_filter-fields-item
                  where buf_temp_filter-fields-item.action-item-code = buf_action-item.action-item-code
            no-error.
            if not available buf_temp_filter-fields-item
            then do:
                  create buf_temp_filter-fields-item.
                  assign
                     buf_temp_filter-fields-item.action-item-code = buf_action-item.action-item-code
                     buf_temp_filter-fields-item.record-on = no
                  .
            end.
            if ( p-name-filter = "":U )
            or index( buf_action-item.action-item-name, p-name-filter ) <> 0
            or index( buf_action-item.action-item-description, p-name-filter ) <> 0
            then do:
               assign
                  buf_temp_filter-fields-item.record-on = yes
               .
            end.
            else do:
               assign
                  buf_temp_filter-fields-item.record-on = no
               .
            end.
         end.
      end.
   end.
end.
END PROCEDURE.
PROCEDURE post_enable_UI :
   define buffer buf_tt-work-place     for tt-work-place.
   define variable v-ok    as logical      no-undo.
do
on error undo, return error
:
   IF p-db-num <> v-cntxt-db-num and v-cntxt-db-num <> 0 THEN DO:
      DISABLE
            b-add
            b-del
      WITH FRAME Dialog-Frame.
   END.
   ELSE DO:
      IF AVAILABLE br_action-role THEN DO:
          ENABLE
                b-add
                b-del
          WITH FRAME Dialog-Frame.
      END.
      ELSE DO:
          ENABLE
                b-add
          WITH FRAME Dialog-Frame.
          DISABLE
                b-del
          WITH FRAME Dialog-Frame.
      END.
   END.
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_users-update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  FALSE
    ,output v-ok
    )  .
end.
    if v-ok = FALSE
    then do:
        disable
            b-add
            b-del
        WITH FRAME Dialog-Frame.
    end.
end.
END PROCEDURE.
PROCEDURE procedure-get-item-state :
  define input  parameter p-action-item-code       as integer   no-undo .
  define output parameter p-state as character no-undo .
  define buffer buf_action-role-item for ub.action-role-item .
  do
  on error undo, return error return-value
  :
    if available br_user-login-action-role
    then do:
      find first buf_action-role-item no-lock
        where buf_action-role-item.db-num              = br_user-login-action-role.db-num
          and buf_action-role-item.action-head-code    = br_user-login-action-role.action-head-code
          and buf_action-role-item.action-role-code    = br_user-login-action-role.action-role-code
          and buf_action-role-item.action-item-code    = p-action-item-code
        no-error .
      if available buf_action-role-item
      then do:
        assign
          p-state = '*':U
        .
      end.
      else do:
        assign
          p-state = '':U
        .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE procedure-get-role-context :
  define input  parameter p-action-context as character no-undo .
  define output parameter p-action-name    as character no-undo .
  do
  on error undo, return error return-value
  :
    case p-action-context
    :
      when 'global':U
      then do:
        assign
          p-action-name = "Без привязки"
        .
      end.
      when 'firm':U
      then do:
        assign
          p-action-name = "Фирма"
        .
      end.
      when 'object':U
      then do:
        assign
          p-action-name = "Объект"
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Незвестное значение контекста" skip
          "p-action-context" p-action-context skip
          view-as alert-box error .
      end.
    end case .
  end.
END PROCEDURE.
PROCEDURE query-action-item :
  do
  on error undo, return error return-value
  :
    if available br_user-login-action-role
    then do:
      if tb-filter = yes then do:
         run filter-for-item IN THIS-PROCEDURE
                        ( input v-flt-item
                        ) .
      end.
      else do:
         run filter-for-item IN THIS-PROCEDURE
                        ( input ""
                        ) .
      end.
      IF LOGICAL(tg-detail:screen-value in FRAME Dialog-Frame) then do:
         open query browse-action-item
            FOR EACH buf_user-login-action-role
                WHERE RECID(buf_user-login-action-role) = RECID(br_user-login-action-role)
                  NO-LOCK
                  ,
                  EACH  br_action-role-item
                  WHERE br_action-role-item.db-num = p-db-num
                     AND br_action-role-item.action-head-code   = 0
                     AND br_action-role-item.action-role-code   = buf_user-login-action-role.action-role-code
                  NO-LOCK,
                  FIRST br_temp_filter-fields-item
                  WHERE br_temp_filter-fields-item.action-item-code = br_action-role-item.action-item-code
                    and br_temp_filter-fields-item.record-on = YES
                  NO-LOCK
                  ,
                  first br_action-item
                  where br_action-item.action-head-code    = 0
                     AND br_action-item.action-item-code    = br_action-role-item.action-item-code
                     AND br_action-item.action-item-context = br_tt-work-place.context
                  no-lock
                  indexed-reposition .
      end.
      else do:
         open query browse-action-item
            FOR EACH buf_user-login-action-role
                  WHERE buf_user-login-action-role.db-num             = p-db-num
                  AND buf_user-login-action-role.action-head-code     = 0
                  AND buf_user-login-action-role.user-id              = p-user-id
                  AND (
                           (
                           buf_user-login-action-role.action-role-context  = br_tt-work-place.context
                           AND
                           buf_user-login-action-role.action-role-context = 'global':U
                           AND
                           buf_user-login-action-role.host-code = 0
                           AND
                           buf_user-login-action-role.obj-code  = 0
                           AND
                           buf_user-login-action-role.obj-type  = "":U
                           )
                        OR
                           (
                           buf_user-login-action-role.action-role-context  = br_tt-work-place.context
                           AND
                           buf_user-login-action-role.action-role-context = 'firm':U
                           AND
                           buf_user-login-action-role.host-code = br_tt-work-place.wp-code
                           AND
                           buf_user-login-action-role.obj-code  = 0
                           AND
                           buf_user-login-action-role.obj-type  = "":U
                           )
                        OR
                           (
                           buf_user-login-action-role.action-role-context  = br_tt-work-place.context
                           AND
                           buf_user-login-action-role.action-role-context = 'object':U
                           AND
                           buf_user-login-action-role.obj-code = br_tt-work-place.wp-code
                           AND
                           buf_user-login-action-role.obj-type = br_tt-work-place.wp-type
                           )
                        )
                  no-lock
                  ,
                  EACH  br_action-role-item
                  WHERE br_action-role-item.db-num = p-db-num
                     AND br_action-role-item.action-head-code   = 0
                     AND br_action-role-item.action-role-code   = buf_user-login-action-role.action-role-code
                  NO-LOCK
                  ,
                  FIRST br_temp_filter-fields-item
                  WHERE br_temp_filter-fields-item.action-item-code = br_action-role-item.action-item-code
                    and br_temp_filter-fields-item.record-on = YES
                  NO-LOCK
                  ,
                  first br_action-item
                  where br_action-item.action-head-code    = 0
                     AND br_action-item.action-item-code    = br_action-role-item.action-item-code
                     AND br_action-item.action-item-context = br_tt-work-place.context
                  no-lock
                  indexed-reposition .
      end.
    end.
    else do:
      open query browse-action-item
           FOR EACH buf_user-login-action-role
               WHERE buf_user-login-action-role.db-num           = p-db-num
                 AND buf_user-login-action-role.action-head-code = 0
                 AND buf_user-login-action-role.user-id          = p-user-id
                 AND buf_user-login-action-role.action-role-context = "":U
               NO-LOCK
               ,
               FIRST br_action-role-item
               WHERE br_action-role-item.db-num = p-db-num
                 AND br_action-role-item.action-head-code            = 0
                 AND br_action-role-item.action-role-code            = buf_user-login-action-role.action-role-code
               NO-LOCK
               ,
               FIRST br_temp_filter-fields-item
               WHERE br_temp_filter-fields-item.action-item-code = br_action-role-item.action-item-code
                 and br_temp_filter-fields-item.record-on = YES
               NO-LOCK
               ,
               first br_action-item
               where br_action-item.action-head-code    = 0
                 AND br_action-item.action-item-code    = br_action-role-item.action-item-code
               no-lock
        indexed-reposition .
    end.
  if available br_action-item then do:
    assign
        item-editor = br_action-item.action-item-description
    .
    display
      item-editor
    with frame Dialog-Frame.
  end.
  end.
END PROCEDURE.
PROCEDURE query-action-role :
  DO
  ON ERROR UNDO, RETURN ERROR RETURN-VALUE
  :
    IF available br_tt-work-place THEN DO:
      OPEN QUERY browse-br_user-login-action-role
            FOR EACH br_user-login-action-role WHERE br_user-login-action-role.db-num           = p-db-num
                                              AND br_user-login-action-role.action-head-code    = 0
                                              AND br_user-login-action-role.user-id             = p-user-id
                                              AND br_user-login-action-role.action-role-context = br_tt-work-place.context
                                              AND (
                                                   (br_tt-work-place.context = 'global':U)
                                                  OR
                                                   (br_tt-work-place.context = 'firm':U
                                                    AND
                                                    br_user-login-action-role.host-code = br_tt-work-place.wp-code
                                                   )
                                                  OR
                                                   (br_tt-work-place.context = 'object':U
                                                    AND
                                                    br_user-login-action-role.obj-code = br_tt-work-place.wp-code
                                                    AND
                                                    br_user-login-action-role.obj-type = br_tt-work-place.wp-type
                                                   )
                                                  )
                no-lock,
                FIRST br_action-role        WHERE br_action-role.db-num                      = (if v-on-gbl then 0 else p-db-num)
                                              AND br_action-role.action-head-code            = 0
                                              AND br_action-role.action-role-code            = br_user-login-action-role.action-role-code
                                              and br_action-role.action-role-context         = br_tt-work-place.context
                                            NO-LOCK,
                first temp_filter-fields
                where temp_filter-fields.action-role-code = br_action-role.action-role-code
                  AND temp_filter-fields.record-on = YES
                no-lock
      INDEXED-REPOSITION .
    END.
    if available br_action-role then do:
      assign
          role-editor = br_action-role.action-role-description
      .
      display
         role-editor
      with frame Dialog-Frame.
    end.
  END.
END PROCEDURE.
PROCEDURE refresh-action-item :
  do
  on error undo, return error return-value
  :
    run query-action-item in this-procedure .
  end.
END PROCEDURE.
PROCEDURE refresh-action-role :
  do
  on error undo, return error return-value
  :
    run query-action-role in this-procedure .
    run refresh-action-item in this-procedure .
  end.
END PROCEDURE.
FUNCTION get-item-state RETURNS CHARACTER
  ( BUFFER buf_action-item FOR action-item ) :
  define variable v-return-value as character no-undo .
  run procedure-get-item-state in this-procedure
    (input  buf_action-item.action-item-code
    ,output v-return-value
    ) .
  return v-return-value .
END FUNCTION.
FUNCTION get-role-context RETURNS CHARACTER
  ( BUFFER buf_user-login-action-role FOR user-login-action-role ) :
  define variable v-return-value as character no-undo .
  run procedure-get-role-context in this-procedure
    (input  buf_user-login-action-role.action-role-context
    ,output v-return-value
    ) .
  return v-return-value .
END FUNCTION.
