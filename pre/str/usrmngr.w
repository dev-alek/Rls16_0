define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-db-num      as integer   no-undo .
define input  parameter p-user-id     as character no-undo .
define input  parameter p-menu-code   as integer   no-undo .
DEFINE STREAM s-out.
DEFINE TEMP-TABLE tt-work-place NO-UNDO
    FIELD wp-code AS INTEGER   column-label "№"             FORMAT ">>>>>>>>9"
    FIELD wp-type AS CHARACTER column-label "тип"           FORMAT "x(3)"
    FIELD wp-host AS INTEGER   column-label "фирма"         FORMAT ">>>>9"
    FIELD wp-name AS CHARACTER column-label "наименование"  FORMAT "x(40)"
    FIELD db-num  AS INTEGER   column-label "БД"            FORMAT ">>>>9"
    FIELD context AS CHARACTER column-label "привязка"
    FIELD selected AS logical column-label "*" FORMAT "*/ "
INDEX i-code-type IS PRIMARY UNIQUE
      wp-code
      wp-type
INDEX i-host
      wp-host
INDEX i-sel
      selected
INDEX i-context
      context
.
DEFINE TEMP-TABLE tt-menu-group NO-UNDO
    FIELD menu-group-code        AS INTEGER   column-label "№"             FORMAT ">>>>9"
    FIELD menu-group-id          AS character column-label "ID"
    FIELD menu-group-name        as character column-label "Меню"   FORMAT "x(20)"
    FIELD menu-group-description as character column-label "Описание"   FORMAT "x(20)"
    FIELD sel-color              as integer
    field permit                 as logical
    FIELD selected               AS logical column-label "*" FORMAT "*/ "
INDEX i-code-type IS PRIMARY UNIQUE
      menu-group-code
.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактировать группы меню для пользователя".
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
define variable vss-include-info1 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_twowin_items no-undo
    field itm-key       as integer
    field itmExtKey     as character
    field itmName       as character
    field itmDesc       as character
    field itmSelected   as logical
    field selLeft       as logical
    field selRight      as logical
    index pi is primary unique
        itm-key
    index ie
        itmExtKey
.
define temp-table temp_twowin_itemsSelected no-undo
    field its-key   as integer
    field itm-key   as integer
    field itmExtKey as character
    index pi is primary unique
        its-key
    index im
        itm-key
.
define variable v-twowin1-itm-key    as integer      no-undo.
procedure twowin_clear :
    define buffer buf_temp_twowin_items        for temp_twowin_items.
do
for buf_temp_twowin_items
on error undo, return error
:
    empty temp-table buf_temp_twowin_items.
end.
end procedure.
procedure twowin_add-item :
define input parameter p-ext-key   as character        no-undo.
define input parameter p-item-name as character        no-undo.
define input parameter p-item-desc as character        no-undo.
define input parameter p-selected  as logical          no-undo.
    define buffer buf_temp_twowin_items        for temp_twowin_items.
do
for buf_temp_twowin_items
on error undo, return error
:
    assign
        v-twowin1-itm-key = v-twowin1-itm-key + 1
    .
    create temp_twowin_items.
    assign
        temp_twowin_items.itm-key      = v-twowin1-itm-key
        temp_twowin_items.itmExtKey    = p-ext-key
        temp_twowin_items.itmName      = p-item-name
        temp_twowin_items.itmDesc      = p-item-desc
        temp_twowin_items.itmSelected  = p-selected
        temp_twowin_items.selLeft      = no
        temp_twowin_items.selRight     = no
    .
end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function usrnickf returns character ( input p-user-id as character):
   define variable v-nick      as character    no-undo.
   if p-user-id = ?
   OR p-user-id = "":U
   then do:
      return '':U .
   end.
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-menu-group-name as character no-undo format "x(30)" column-label "Группа меню" .
define variable v-context-name    as character no-undo format "x(40)" column-label "Контекст"    .
define variable v-user-menu-group as logical   no-undo format "*/ "   column-label "*" .
define variable v-ok              as logical   no-undo.
DEFINE BUFFER br_tt-work-place FOR tt-work-place .
DEFINE buffer br_menu-group    FOR menu-group .
DEFINE buffer br_tt-menu-group FOR tt-menu-group .
define buffer buf_user-login   for user-login.
FUNCTION check-user-menu-group RETURNS logical
   ( BUFFER buf_menu-group FOR menu-group )  FORWARD.
FUNCTION get-context-name RETURNS CHARACTER
  (BUFFER buf_user-menu-group FOR user-menu-group )  FORWARD.
FUNCTION get-menu-group-name RETURNS CHARACTER
  ( BUFFER buf_user-menu-group FOR user-menu-group )  FORWARD.
DEFINE BUTTON b-chg-menu
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON b-desel
     LABEL "Снять все"
     SIZE 11 BY 1 TOOLTIP "Снять выделение со всех фирм и объектов".
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON b-sel-all
     LABEL "Выделить все"
     SIZE 14 BY 1 TOOLTIP "Выделить все фирмы и объекты".
DEFINE QUERY BROWSE-menu FOR
      br_tt-menu-group SCROLLING.
DEFINE QUERY BROWSE-WP FOR
      br_tt-work-place SCROLLING.
DEFINE BROWSE BROWSE-menu
  QUERY BROWSE-menu NO-LOCK DISPLAY
      br_tt-menu-group.menu-group-name FORMAT "X(32)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 35.5 BY 16.25 FIT-LAST-COLUMN.
DEFINE BROWSE BROWSE-WP
  QUERY BROWSE-WP DISPLAY
      br_tt-work-place.wp-code
        br_tt-work-place.wp-type
        br_tt-work-place.wp-name
    WITH NO-ROW-MARKERS SEPARATORS SIZE 60 BY 16.17 ROW-HEIGHT-CHARS .83 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 2
     b-mark AT ROW 1 COL 12 WIDGET-ID 8
     b-chg-menu AT ROW 1 COL 12 WIDGET-ID 28
     b-sel-all AT ROW 1 COL 15 WIDGET-ID 26
     b-desel AT ROW 1 COL 29 WIDGET-ID 30
     b-help AT ROW 1 COL 88
     BROWSE-menu AT ROW 2.25 COL 2 WIDGET-ID 400
     BROWSE-WP AT ROW 2.25 COL 38 WIDGET-ID 300
     SPACE(0.37) SKIP(0.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Группы меню для пользователя"
         DEFAULT-BUTTON b-exit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-desel:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       b-mark:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       b-sel-all:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-chg-menu IN FRAME Dialog-Frame
DO:
   IF AVAILABLE br_tt-menu-group
   then do:
      run change-menu-2 in this-procedure .
      RUN refresh-query-wp IN THIS-PROCEDURE.
   end.
END.
ON CHOOSE OF b-desel IN FRAME Dialog-Frame
DO:
   FOR EACH br_tt-menu-group
   ON ERROR UNDO, NEXT
   :
      assign
         br_tt-menu-group.selected = NO
      .
   END.
   run enable_UI in this-procedure .
   run post_enable_UI in this-procedure .
   RUN refresh-query-menu IN THIS-PROCEDURE .
END.
ON CHOOSE OF b-mark IN FRAME Dialog-Frame
DO
:
   DEFINE VARIABLE v-log AS LOGICAL NO-UNDO .
   IF  AVAILABLE br_tt-work-place
   THEN DO
   ON ERROR UNDO, RETURN NO-APPLY
   :
      assign
         br_tt-menu-group.selected = NOT br_tt-menu-group.selected
      .
      v-log = BROWSE-menu:refresh() IN FRAME Dialog-Frame.
      if last-event :function <> "MOUSE-SELECT-DBLCLICK"
      then do:
        v-log = BROWSE-menu:select-next-row ().
        apply "iteration-changed" to BROWSE-menu in frame Dialog-Frame.
      end.
   END.
END.
ON CHOOSE OF b-sel-all IN FRAME Dialog-Frame
DO:
   FOR EACH br_tt-menu-group
   ON ERROR UNDO, NEXT
   :
      assign
         br_tt-menu-group.selected = YES
      .
   END.
   run enable_UI in this-procedure .
   run post_enable_UI in this-procedure .
END.
ON VALUE-CHANGED OF BROWSE-menu IN FRAME Dialog-Frame
DO:
   IF  AVAILABLE br_tt-menu-group
   then do:
      RUN refresh-query-wp IN THIS-PROCEDURE.
   end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BROWSE-menu :handle
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
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame Dialog-Frame anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   define buffer buf_user-obj    for user-obj .
   define buffer buf_user-host   for user-host .
   FIND FIRST buf_user-login
        where buf_user-login.db-num  = p-db-num
          and buf_user-login.user-id = p-user-id
        no-lock
        no-error
        .
   if not available buf_user-login then do:
      message "У пользователя не задан логин."
         skip "Выбор меню невозможен."
      view-as alert-box information.
      return.
   end.
   IF NOT CAN-FIND (FIRST buf_user-obj where buf_user-obj.db-num  = p-db-num
                                         and buf_user-obj.user-id = p-user-id
                    NO-LOCK)
   AND NOT CAN-FIND (FIRST buf_user-host where buf_user-host.db-num  = p-db-num
                                           and buf_user-host.user-id = p-user-id
                    NO-LOCK)
   THEN DO:
      message "У пользователя не заданы ни объекты ни фирмы."
         skip "Выбор меню невозможен."
      view-as alert-box information.
      return.
   END.
   ASSIGN
        FRAME Dialog-Frame:TITLE = SUBSTITUTE ( "Меню пользователя &1 для БД &2"
                                              , usrnickf( p-user-id )
                                              , buf_user-login.db-num
                                              )
   .
   run fill-menu in this-procedure .
   run fill-wp in this-procedure .
   RUN enable_UI.
   run post_enable_UI in this-procedure .
   WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE change-menu-2 :
define buffer buf_tt-work-place    for tt-work-place.
define buffer buf_user-menu-group      for user-menu-group .
define variable v-menu-group-code    as integer      no-undo.
define variable v-ok                 as logical      no-undo.
define variable v-accepted    as logical      no-undo.
define variable v-changed    as logical      no-undo.
define variable v-user-menu-group-code    as integer      no-undo.
if available br_tt-menu-group then
DO
on error undo, return no-apply
   :
if session :set-wait-state( "compiler" ) then.
   run twowin_clear in this-procedure.
   each-wp_:
   FOR EACH   buf_tt-work-place
       break by buf_tt-work-place.context
      :
      IF  p-db-num <> 0
      AND buf_tt-work-place.db-num <> p-db-num
      and buf_tt-work-place.context = 'object':U
      THEN do:
          next each-wp_ .
      end.
         assign
            v-ok = FALSE
         .
define variable vss-include-info10 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chkmngr in g#library2
  (input  br_tt-menu-group.menu-group-id
  ,input  buf_tt-work-place.context
  ,input  buf_tt-work-place.wp-type
  ,input  buf_tt-work-place.wp-code
  ,input  p-db-num
  ,output v-ok
  ) no-error .
      IF NOT v-ok THEN do:
         next each-wp_ .
      end.
      run twowin_add-item in this-procedure
         ( input SUBSTITUTE( "&2 &1", buf_tt-work-place.wp-code, buf_tt-work-place.wp-type  )
         , input SUBSTITUTE( "&1 &2 &3", buf_tt-work-place.wp-code, buf_tt-work-place.wp-type, buf_tt-work-place.wp-name )
         , input SUBSTITUTE( "БД: &1 Фирма: &2", buf_tt-work-place.db-num, buf_tt-work-place.wp-host )
         , input buf_tt-work-place.selected
         ) .
   end.
if session :set-wait-state( "" ) then.
   run gbl/twowin.w
      ( input parparentproc
      , input 1
      , input SUBSTITUTE('Добавление меню "&1" на объектах и фирмах:', br_tt-menu-group.menu-group-name)
      , input "":U
      , input "&Тест"
      , input table temp_twowin_items
      , output table temp_twowin_itemsSelected
      , output v-changed
      , output v-accepted
      ) .
   IF NOT v-accepted THEN DO:
      RETURN.
   END.
if session :set-wait-state( "compiler" ) then.
   post-each-wp_:
   FOR EACH buf_tt-work-place
   :
      IF  p-db-num <> 0
      AND buf_tt-work-place.db-num <> p-db-num
      and buf_tt-work-place.context = 'object':U
      THEN do:
          next post-each-wp_ .
      end.
      find first temp_twowin_itemsSelected
               where temp_twowin_itemsSelected.itmExtKey = SUBSTITUTE( "&2 &1", buf_tt-work-place.wp-code, buf_tt-work-place.wp-type  )
           no-lock
           no-error
           .
      IF available temp_twowin_itemsSelected then do:
         if buf_tt-work-place.selected = TRUE then do:
            next post-each-wp_ .
         end.
         else do:
            find first  buf_user-menu-group
            WHERE (buf_user-menu-group.db-num               = p-db-num
               AND buf_user-menu-group.user-id              = p-user-id
               and buf_user-menu-group.menu-group-code      = br_tt-menu-group.menu-group-code
               AND buf_user-menu-group.menu-group-context   = buf_tt-work-place.context
               AND buf_user-menu-group.menu-group-context   = 'firm':U
               AND buf_user-menu-group.host-code            = buf_tt-work-place.wp-host)
               OR
                  (buf_user-menu-group.db-num              = p-db-num
               AND buf_user-menu-group.user-id              = p-user-id
               and buf_user-menu-group.menu-group-code      = br_tt-menu-group.menu-group-code
               AND buf_user-menu-group.menu-group-context   = buf_tt-work-place.context
               AND buf_user-menu-group.menu-group-context   = 'object':U
               AND buf_user-menu-group.obj-type             = buf_tt-work-place.wp-type
               AND buf_user-menu-group.obj-code             = buf_tt-work-place.wp-code)
            no-lock
            no-error
            .
            IF NOT AVAILABLE buf_user-menu-group THEN DO:
               case buf_tt-work-place.context:
               when 'object':U THEN do:
                  assign
                     v-user-menu-group-code = next-value(s-user-menu-group)
                  .
                  CREATE buf_user-menu-group.
                  assign
                     buf_user-menu-group.db-num               = p-db-num
                     buf_user-menu-group.user-id              = p-user-id
                     buf_user-menu-group.menu-code            = 0
                     buf_user-menu-group.menu-group-code      = br_tt-menu-group.menu-group-code
                     buf_user-menu-group.menu-group-id        = br_tt-menu-group.menu-group-id
                     buf_user-menu-group.menu-group-context   = 'object':U
                     buf_user-menu-group.obj-type             = buf_tt-work-place.wp-type
                     buf_user-menu-group.obj-code             = buf_tt-work-place.wp-code
                     buf_user-menu-group.host-code            = buf_tt-work-place.wp-host
                     buf_user-menu-group.user-menu-group-code = v-user-menu-group-code
                  .
               end.
               when 'firm':U THEN do:
                  assign
                     v-user-menu-group-code = next-value(s-user-menu-group)
                  .
                  CREATE buf_user-menu-group.
                  assign
                     buf_user-menu-group.db-num               = p-db-num
                     buf_user-menu-group.user-id              = p-user-id
                     buf_user-menu-group.menu-code            = 0
                     buf_user-menu-group.menu-group-code      = br_tt-menu-group.menu-group-code
                     buf_user-menu-group.menu-group-id        = br_tt-menu-group.menu-group-id
                     buf_user-menu-group.menu-group-context   = 'firm':U
                     buf_user-menu-group.obj-type             = "":U
                     buf_user-menu-group.obj-code             = 0
                     buf_user-menu-group.host-code            = buf_tt-work-place.wp-host
                     buf_user-menu-group.user-menu-group-code = v-user-menu-group-code
                  .
               end.
               otherwise do:
               end.
               end case.
            END.
         end.
      end.
      else do:
         if buf_tt-work-place.selected = TRUE then do:
            find first  buf_user-menu-group
            WHERE (buf_user-menu-group.db-num               = p-db-num
               AND buf_user-menu-group.user-id              = p-user-id
               and buf_user-menu-group.menu-group-code      = br_tt-menu-group.menu-group-code
               AND buf_user-menu-group.menu-group-context   = buf_tt-work-place.context
               AND buf_user-menu-group.menu-group-context   = 'firm':U
               AND buf_user-menu-group.host-code            = buf_tt-work-place.wp-host)
               OR
                   (buf_user-menu-group.db-num              = p-db-num
               AND buf_user-menu-group.user-id              = p-user-id
               and buf_user-menu-group.menu-group-code      = br_tt-menu-group.menu-group-code
               AND buf_user-menu-group.menu-group-context   = buf_tt-work-place.context
               AND buf_user-menu-group.menu-group-context   = 'object':U
               AND buf_user-menu-group.obj-type             = buf_tt-work-place.wp-type
               AND buf_user-menu-group.obj-code             = buf_tt-work-place.wp-code)
            exclusive-lock
            no-error
            .
            IF AVAILABLE buf_user-menu-group THEN DO:
               DELETE buf_user-menu-group.
            END.
         end.
         else do:
            next post-each-wp_ .
         end.
      end.
   end.
if session :set-wait-state( "" ) then.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE b-exit b-chg-menu b-help BROWSE-menu BROWSE-WP
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  RUN refresh-query-menu.    RUN refresh-query-wp .
END PROCEDURE.
PROCEDURE post_enable_UI :
do
on error undo, return error
:
define variable v-ok    as logical      no-undo.
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
              b-chg-menu
        WITH FRAME Dialog-Frame.
    end.
end.
END PROCEDURE.
PROCEDURE fill-menu :
define buffer buf_menu-group     for menu-group .
do
on error undo, return error
:
   for each  buf_menu-group
       where buf_menu-group.menu-code = 0
       no-lock
       by buf_menu-group.menu-group-name
       :
       IF buf_menu-group.menu-group-id = "all" then do:
          next .
       end.
       create tt-menu-group.
       assign
          tt-menu-group.menu-group-code        = buf_menu-group.menu-group-code
          tt-menu-group.menu-group-id          = buf_menu-group.menu-group-id
          tt-menu-group.menu-group-name        = buf_menu-group.menu-group-name
          tt-menu-group.menu-group-description = buf_menu-group.menu-group-description
       .
   end.
end.
END PROCEDURE.
PROCEDURE fill-wp :
DEFINE BUFFER buf_user-obj  FOR user-obj.
DEFINE BUFFER buf_user-host FOR user-host.
DEFINE BUFFER buf_clients   FOR clients.
define buffer buf_user-menu-group      for user-menu-group .
define buffer del_user-menu-group      for user-menu-group .
define buffer buf_tt-work-place     for tt-work-place .
if available tt-menu-group then
do
on error undo, return error
:
   user-menu_:
   FOR EACH buf_user-obj
         WHERE buf_user-obj.db-num = p-db-num
         AND buf_user-obj.USER-ID  = p-user-id
      NO-LOCK
      :
         FIND FIRST buf_clients
            WHERE buf_clients.obj-code = buf_user-obj.obj-code
               AND buf_clients.obj-type = buf_user-obj.obj-type
            NO-LOCK
            .
         CREATE buf_tt-work-place.
         ASSIGN
            buf_tt-work-place.wp-code = buf_clients.obj-code
            buf_tt-work-place.wp-type = buf_clients.obj-type
            buf_tt-work-place.wp-host = buf_clients.host-code
            buf_tt-work-place.db-num  = buf_clients.db-num
            buf_tt-work-place.context = 'object':U
            buf_tt-work-place.wp-name = buf_clients.obj-name
         .
   end.
   FOR EACH buf_user-host
       WHERE buf_user-host.db-num  = p-db-num
         AND buf_user-host.USER-ID = p-user-id
       NO-LOCK
       :
         FIND FIRST buf_clients
            WHERE buf_clients.obj-code = buf_user-host.host-code
               AND buf_clients.obj-type = 'орг':U
            NO-LOCK
            .
         CREATE buf_tt-work-place.
         ASSIGN
            buf_tt-work-place.wp-code = buf_clients.obj-code
            buf_tt-work-place.wp-type = buf_clients.obj-type
            buf_tt-work-place.wp-host = buf_clients.obj-code
            buf_tt-work-place.db-num  = buf_clients.db-num
            buf_tt-work-place.context = 'firm':U
            buf_tt-work-place.wp-name = buf_clients.obj-name
         .
   end.
end.
END PROCEDURE.
PROCEDURE local-open-query-menu :
define variable v-ok    as logical      no-undo.
do
on error undo, return error return-value
:
   open query BROWSE-menu
        for each  br_tt-menu-group
        no-lock
        indexed-reposition
        .
end.
END PROCEDURE.
PROCEDURE local-open-query-wp :
do
on error undo, return error return-value
:
    open query browse-wp
    for each br_tt-work-place
        where br_tt-work-place.selected = TRUE
        no-lock
    indexed-reposition
    .
end.
END PROCEDURE.
PROCEDURE mark-wp :
define buffer buf_user-menu-group      for user-menu-group .
define buffer buf_tt-work-place     for tt-work-place .
if available br_tt-menu-group then
do
on error undo, return error
:
   user-menu_:
   FOR EACH buf_tt-work-place
      :
      case buf_tt-work-place.context:
      when 'object':U then do:
         IF CAN-FIND ( FIRST buf_user-menu-group
              where buf_user-menu-group.db-num             = p-db-num
                and buf_user-menu-group.user-id            = p-user-id
                and buf_user-menu-group.menu-code          = 0
                and buf_user-menu-group.menu-group-code    = br_tt-menu-group.menu-group-code
                and buf_user-menu-group.obj-code           = buf_tt-work-place.wp-code
                AND buf_user-menu-group.obj-type           = buf_tt-work-place.wp-type
                and buf_user-menu-group.host-code          = buf_tt-work-place.wp-host
                and buf_user-menu-group.menu-group-context = 'object':U
                and buf_user-menu-group.menu-group-id      = br_tt-menu-group.menu-group-id
            NO-LOCK )
            then do:
               ASSIGN
                  buf_tt-work-place.selected = TRUE
               .
            end.
            else do:
               ASSIGN
                  buf_tt-work-place.selected = FALSE
               .
            end.
      end.
      when 'firm':U then do:
         IF CAN-FIND ( FIRST buf_user-menu-group
              where buf_user-menu-group.db-num             = p-db-num
                and buf_user-menu-group.user-id            = p-user-id
                and buf_user-menu-group.menu-code          = 0
                and buf_user-menu-group.menu-group-code    = br_tt-menu-group.menu-group-code
                and buf_user-menu-group.obj-code           = 0
                AND buf_user-menu-group.obj-type           = "":U
                and buf_user-menu-group.host-code          = buf_tt-work-place.wp-host
                and buf_user-menu-group.menu-group-context = 'firm':U
                and buf_user-menu-group.menu-group-id      = br_tt-menu-group.menu-group-id
            NO-LOCK )
            then do:
               ASSIGN
                  buf_tt-work-place.selected = TRUE
               .
            end.
            else do:
               ASSIGN
                  buf_tt-work-place.selected = FALSE
               .
            end.
      end.
      otherwise do:
      end.
      end case.
   end.
end.
END PROCEDURE.
PROCEDURE refresh-query-menu :
  do
  on error undo, return error return-value
  :
    run local-open-query-menu in this-procedure .
  end.
END PROCEDURE.
PROCEDURE refresh-query-wp :
  do
  on error undo, return error return-value
  :
    RUN mark-wp IN THIS-PROCEDURE.
    run local-open-query-wp in this-procedure .
  end.
END PROCEDURE.
FUNCTION check-user-menu-group RETURNS logical
   ( BUFFER buf_menu-group FOR menu-group ) :
   define variable v-return-value as logical no-undo .
   IF AVAILABLE br_tt-work-place THEN DO:
      case br_tt-work-place.wp-type:
      when 'орг':U THEN DO:
         v-return-value =  CAN-FIND( FIRST user-menu-group
                                     WHERE user-menu-group.db-num          = p-db-num
                                       AND user-menu-group.user-id         = p-user-id
                                       AND user-menu-group.menu-group-code = buf_menu-group.menu-group-code
                                       AND user-menu-group.host-code       = br_tt-work-place.wp-code
                                       AND user-menu-group.menu-group-context   = 'firm':U
                                       ).
      END.
      when 'маг':U OR
      WHEN 'скл':U THEN DO:
         v-return-value =  CAN-FIND( FIRST user-menu-group
                                     WHERE user-menu-group.db-num          = p-db-num
                                       AND user-menu-group.user-id         = p-user-id
                                       AND user-menu-group.menu-group-code = buf_menu-group.menu-group-code
                                       AND user-menu-group.obj-code        = br_tt-work-place.wp-code
                                       AND user-menu-group.obj-type        = br_tt-work-place.wp-type
                                       AND user-menu-group.menu-group-context   = 'object':U
                                       ).
      END.
      otherwise do:
         v-return-value =  CAN-FIND( FIRST user-menu-group
                                     WHERE user-menu-group.db-num          = p-db-num
                                       AND user-menu-group.user-id         = p-user-id
                                       AND user-menu-group.menu-group-code = buf_menu-group.menu-group-code
                                       AND user-menu-group.menu-group-context   = 'global':U
                                       ).
      end.
      end case.
   END.
   return v-return-value .
END FUNCTION.
FUNCTION get-context-name RETURNS CHARACTER
  (BUFFER buf_user-menu-group FOR user-menu-group ) :
  define variable v-return-value as character no-undo .
  run procedure-get-context-name in this-procedure
    (input  buf_user-menu-group.menu-group-context
    ,input  buf_user-menu-group.host-code
    ,input  buf_user-menu-group.obj-type
    ,input  buf_user-menu-group.obj-code
    ,output v-return-value
    ) .
  return v-return-value .
END FUNCTION.
FUNCTION get-menu-group-name RETURNS CHARACTER
  ( BUFFER buf_user-menu-group FOR user-menu-group ) :
  define variable v-return-value as character no-undo .
  run procedure-get-menu-group-name in this-procedure
    (input  buf_user-menu-group.menu-code
    ,input  buf_user-menu-group.menu-group-code
    ,input  buf_user-menu-group.menu-group-id
    ,output v-return-value
    ) .
  return v-return-value .
END FUNCTION.
