define input  parameter h_focus-widget      as handle    no-undo .
define input  parameter h_current-procedure as handle    no-undo .
define output parameter p-action            as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Информационное окно".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define temp-table action-table no-undo
  field action-group        as character  format "x(10)"   label "Group"
  field action-num          as character  format "x(3)"    label "N"
  field action-name         as character  format "x(15)"   label "Name"
  field action-description  as character  format "x(30)"   label "Description"
  field action-external     as logical    format "ext/int" label "Ext"
  field action-close-dialog as logical
  field action-procedure    as character  format "x(30)"   label "Procedure"
  index xpk is primary unique action-num
.
define variable v-proc-name as character no-undo .
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sel
     LABEL "В&ыполнить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE cb-category AS CHARACTER FORMAT "X(256)":U
     LABEL "Category"
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.
DEFINE QUERY BROWSE-1 FOR
      action-table SCROLLING.
DEFINE BROWSE BROWSE-1
  QUERY BROWSE-1 DISPLAY
      action-group
      action-num
      action-name
      action-description
      action-external
      action-procedure
    WITH NO-ROW-MARKERS SEPARATORS SIZE 83.13 BY 15.08.
DEFINE FRAME Dialog-Frame
     cb-category AT ROW 1.08 COL 54.38 COLON-ALIGNED
     b-exit AT ROW 1.13 COL 1.75
     b-sel AT ROW 1.17 COL 13.63
     b-help AT ROW 1.21 COL 25.5
     BROWSE-1 AT ROW 2.42 COL 1.75
     SPACE(1.36) SKIP(0.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Information  Dialog"
         DEFAULT-BUTTON b-sel CANCEL-BUTTON b-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       BROWSE-1:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 2.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-sel IN FRAME Dialog-Frame
DO:
  run perform-action in this-procedure .
END.
ON DEFAULT-ACTION OF BROWSE-1 IN FRAME Dialog-Frame
DO:
  run perform-action in this-procedure .
END.
ON VALUE-CHANGED OF cb-category IN FRAME Dialog-Frame
DO:
  run open-query in this-procedure .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BROWSE-1 :handle
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
  define variable l-permit as logical no-undo .
  if connected("ub") = true
  then do:
    run gbl/authoriz_main.p
      (input "Run information dialog"
      ,output l-permit
      ).
  end.
  else do:
    assign
      l-permit = true
    .
  end.
  if l-permit <> true
  then do:
    undo main-block, leave main-block .
  end.
  run make-temp-table in this-procedure .
  run update-cb-category in this-procedure .
  RUN enable_UI.
  apply "entry" to browse BROWSE-1 .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE action-break-point :
  define variable lok as logical no-undo .
  run get-proc-name in this-procedure
    (input "Установить точку останова"
    ,output lok
    ).
  if lok
  then do:
    debugger:set-break(v-proc-name).
  end.
END PROCEDURE.
PROCEDURE action-check-seq :
  run adm/restseqr.p
    ( input "check":U
     ,input "":U
     ,input no
    ) no-error .
  if error-status :error then do:
    return error return-value .
  end.
END PROCEDURE.
PROCEDURE action-check-syntax :
  define variable lok             as logical   no-undo .
  define variable h-proc-handle   as handle    no-undo .
  run get-proc-name in this-procedure
    (input "Run procedure"
    ,output lok
    ).
  if lok
  then do:
    do
    on error undo, return no-apply
    :
      compile value (v-proc-name) .
      if compiler :error
      then do:
      end.
      else do:
        message
          "Syntax is correct"
          view-as alert-box information .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE action-clear-library :
  define variable lok as logical no-undo .
  message
    "Очистка библиотечных процедур" skip
    "Продолжить?" skip
    view-as alert-box question buttons yes-no update lok .
  if lok = true
  then do:
    run gbl/clearlib.p .
  end.
END PROCEDURE.
PROCEDURE action-cmdstring :
  define variable v-cmd-str as character no-undo .
  define variable v-exefile as character no-undo .
  define variable v-inifile as character no-undo .
  run gbl/getcmdln.p
    (output v-cmd-str
    ) .
  run gbl/d-prompt.w
    (input  'title=':u + "Командная строка запуска системы" + '\':u
    + 'text1=':u + "Командная строка запуска системы" + '\':u
    + 'format=x(256)\':u
    + 'fillin_width=80\':u
    + 'type=char\':u
    ,input-output v-cmd-str
    ).
  if return-value = 'false':u
  then do:
    return .
  end.
  run gbl/getexini.p
    (output v-exefile
    ,output v-inifile
    ).
  run gbl/d-prompt.w
    (input  'title=':u + "Путь к исполняемому файлу progress" + '\':u
    + 'text1=':u + "Путь к исполняемому файлу progress" + '\':u
    + 'format=x(256)\':u
    + 'fillin_width=80\':u
    + 'type=char\':u
    ,input-output v-exefile
    ).
  if return-value = 'false':u
  then do:
    return .
  end.
  run gbl/d-prompt.w
    (input  'title=':u + "Путь к *.ini файлу" + '\':u
    + 'text1=':u + "Путь к *.ini файлу" + '\':u
    + 'format=x(256)\':u
    + 'fillin_width=80\':u
    + 'type=char\':u
    ,input-output v-inifile
    ).
  if return-value = 'false':u
  then do:
    return .
  end.
END PROCEDURE.
PROCEDURE action-conpar :
  define variable cConnect as character no-undo .
  GET-KEY-VALUE SECTION "REP-SETS" KEY "ConPar" VALUE cConnect.
  run gbl/d-prompt.w
    (input  'title=':u + "Параметры подключения к базе данных" + '\':u
    + 'text1=':u + "Параметры подключения к базе данных" + '\':u
    + 'text2=':u + "Задается в *.ini файле: секция ConPar, параметр REP-SETS" + '\':u
    + 'format=x(256)\':u
    + 'type=edit\':u
    + 'fillin_width=70\':u
    + 'fillin_height=6\':u
    + 'max-chars=256\':u
    + 'readonly=yes\':u
    ,input-output cConnect
    ).
  assign
    cConnect = dbparam('ub':U)
  .
  run gbl/d-prompt.w
    (input  'title=':u + "Параметры подключения к базе данных" + '\':u
    + 'text1=':u + "Параметры подключения, возвращаемые Progress" + '\':u
    + 'type=edit\':u
    + 'fillin_width=70\':u
    + 'fillin_height=6\':u
    + 'max-chars=256\':u
    + 'readonly=yes\':u
    ,input-output cConnect
    ).
END PROCEDURE.
PROCEDURE action-obj-info :
  if valid-handle (h_focus-widget) then do:
    run gbl/d-infobj.w
      (input h_focus-widget
      ) .
  end.
  else do:
    message
      "There is no object in focus"
      view-as alert-box .
  end.
END PROCEDURE.
PROCEDURE action-rest-seq :
  define variable lok as logical   no-undo .
  message
    "Восстановить значения счетчиков на основании информации," skip
    "содержащейся в первичных ключах БД." skip
    "Продолжить?" skip
    view-as alert-box question buttons yes-no update lok .
  if lok <> true
  then do:
    return .
  end.
  run adm/restseqr.p
    ( input "rest":U
     ,input "":U
     ,input no
    ) no-error .
  if error-status :error then do:
    return error return-value .
  end.
END PROCEDURE.
PROCEDURE action-run-procedure :
  define variable v-parparentproc as handle no-undo .
  if lookup(h_current-procedure :file-name
            ,'gbl/mainmenu.w'
            ) > 0
  then do:
    assign
      v-parparentproc = h_current-procedure
    .
  end.
  else do:
    assign
      v-parparentproc = ?
    .
  end.
  run gbl/d-runpro.w
    (input v-parparentproc
    ) .
END PROCEDURE.
PROCEDURE action-search-procedure :
  define variable v-canonic-proc-name as character no-undo .
  run gbl/d-prompt.w
    (input 'title=Search procedure\'
    + 'text1=Enter procedure name\'
    + 'format=x(40)\'
    + 'type=char\'
    + 'boxprog=getfile.p\'
    ,input-output v-proc-name
    ).
  do
  on error undo, return no-apply
  on stop undo, return no-apply
  :
    if return-value <> "false":u
    then do:
      assign
        v-canonic-proc-name = entry(1, v-proc-name, '.')
      .
      define variable v-proc-name-p as character no-undo .
      define variable v-proc-name-w as character no-undo .
      define variable v-proc-name-i as character no-undo .
      define variable v-proc-name-r as character no-undo .
      assign
        v-proc-name-p = search(v-canonic-proc-name + '.p')
        v-proc-name-w = search(v-canonic-proc-name + '.w')
        v-proc-name-i = search(v-canonic-proc-name + '.i')
        v-proc-name-r = search(v-canonic-proc-name + '.r')
      .
      message
        "P-code:" chr(9) v-proc-name-p skip
        "W-code:" chr(9) v-proc-name-w skip
        "I-code:" chr(9) v-proc-name-i skip
        "R-code:" chr(9) v-proc-name-r skip
        view-as alert-box information title "Search: " + v-canonic-proc-name.
    end.
  end.
END PROCEDURE.
PROCEDURE action-show-context :
  define variable v-parparentproc as handle no-undo .
  if lookup(h_current-procedure :file-name
            ,'gbl/mainmenu.w'
            ) > 0
  then do:
    assign
      v-parparentproc = h_current-procedure
    .
  end.
  else do:
    assign
      v-parparentproc = ?
    .
  end.
  run gbl/show-gbl.p
    (input v-parparentproc
    ) .
END PROCEDURE.
PROCEDURE action-show-lock :
  do
  on error undo, return error return-value
  on stop  undo, return error return-value
  :
    run gbl/d-lock.w .
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY cb-category
      WITH FRAME Dialog-Frame.
  ENABLE cb-category b-exit b-sel b-help BROWSE-1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  run open-query in this-procedure .
END PROCEDURE.
PROCEDURE get-proc-name :
  define input parameter  p-title as character no-undo .
  define output parameter p-ok    as logical   no-undo .
  define variable v-new-proc-name    as character no-undo .
  define variable v-search-proc-name as character no-undo .
  define variable v-use-prog         as logical   no-undo .
  assign
    p-ok            = false
    v-new-proc-name = v-proc-name
  .
  run gbl/d-prompt.w
    (input  'title=':U + p-title + '\':U
    + 'text1=':U + "Введите имя программы" + '\':U
    + 'format=x(40)\':U
    + 'type=char\':U
    + 'boxprog=getfile.p\':U
    ,input-output v-new-proc-name
    ).
  if return-value <> 'false':U
  then do:
    assign
      v-proc-name = v-new-proc-name
    .
    search_block:
    do
    :
      define variable v-index-sub-dir       as integer   no-undo .
      define variable v-sub-dir-list        as character no-undo .
      define variable v-num-entries-sub-dir as integer   no-undo .
      define variable v-sub-dir-item        as character no-undo .
      define variable v-index-suffix        as integer   no-undo .
      define variable v-suffix-list         as character no-undo .
      define variable v-num-entries-suffix  as integer   no-undo .
      define variable v-suffix-item         as character no-undo .
      assign
        v-sub-dir-list        = ',adm/,arc/,bge/,cmp/,cus/,exe/,gbl/,nws/,osn/,rcs/,ref/,rep/,str/,trg/,utl/':U
        v-num-entries-sub-dir = num-entries(v-sub-dir-list)
        v-suffix-list         = ',.p,.w':U
        v-num-entries-suffix  = num-entries(v-suffix-list)
      .
      do v-index-sub-dir = 1 to v-num-entries-sub-dir
      :
        assign
          v-sub-dir-item = entry(v-index-sub-dir, v-sub-dir-list)
        .
        do v-index-suffix = 1 to v-num-entries-suffix
        :
          assign
            v-suffix-item = entry(v-index-suffix, v-suffix-list)
          .
          assign
            v-search-proc-name = search(v-sub-dir-item + v-proc-name + v-suffix-item)
          .
          if v-search-proc-name <> ?
          then do:
            message
              p-title skip
              substitute("Найдена процедура &1", v-search-proc-name) skip
              "Использовать её?" skip
              view-as alert-box question buttons yes-no update v-use-prog .
            if v-use-prog = true
            then do:
              assign
                v-proc-name = v-sub-dir-item + v-proc-name + v-suffix-item
                p-ok        = true
              .
              leave search_block .
            end.
          end.
        end.
      end.
    end.
    if p-ok <> true
    then do:
      message
        p-title skip
        "Процедура не найдена" skip
        "Имя процедуры" v-proc-name skip
        "Продолжить?" skip
        view-as alert-box warning buttons yes-no update p-ok .
    end.
  end.
END PROCEDURE.
PROCEDURE make-temp-table :
  do
  on error undo, return error
  :
    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "10"
      action-table.action-name         = "Pr Editor"
      action-table.action-description  = "Launch Procedure Editor"
      action-table.action-external     = false
      action-table.action-close-dialog = true
      action-table.action-procedure    = "run,_edit.p"
    .
    create action-table .
    assign
      action-table.action-group        = "Procedure"
      action-table.action-num          = "11"
      action-table.action-name         = "Run Proc."
      action-table.action-description  = "Run procedure"
      action-table.action-external     = false
      action-table.action-close-dialog = false
      action-table.action-procedure    = "action-run-procedure"
    .
    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "12"
      action-table.action-name         = "Check Sum"
      action-table.action-description  = "Check system integrity"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "gbl/chksum.p"
    .
    create action-table .
    assign
      action-table.action-group        = "Procedure"
      action-table.action-num          = "13"
      action-table.action-name         = "Trace log"
      action-table.action-description  = "Trace program execution"
      action-table.action-external     = false
      action-table.action-close-dialog = true
      action-table.action-procedure    = "runpersistent,logger.w"
    .
    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "14"
      action-table.action-name         = "Proc. Info"
      action-table.action-description  = "Display Procedure Stack Information"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "gbl/prwnshow.p"
    .
    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "15"
      action-table.action-name         = "Object Info"
      action-table.action-description  = "Display interface object information"
      action-table.action-external     = false
      action-table.action-close-dialog = false
      action-table.action-procedure    = "action-obj-info"
    .
    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "16"
      action-table.action-name         = "Conn. DB"
      action-table.action-description  = "Connected Database Information"
      action-table.action-external     = false
      action-table.action-close-dialog = true
      action-table.action-procedure    = "run,protools/_dblist.w"
    .
    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "17"
      action-table.action-name         = "Messages"
      action-table.action-description  = "Display recent system error messages"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "prohelp/_rcntmsg.p"
    .
    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "18"
      action-table.action-name         = "Propath"
      action-table.action-description  = "Propath View/Edit"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "protools/_propath.p"
    .
    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "19"
      action-table.action-name         = "Session"
      action-table.action-description  = "Session Parameters"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "protools/_session.p"
    .
    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "20"
      action-table.action-name         = "Pro Tools"
      action-table.action-description  = "Star Protools"
      action-table.action-external     = false
      action-table.action-close-dialog = true
      action-table.action-procedure    = "run,protools/_protool.p"
    .
    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "21"
      action-table.action-name         = "Con.Par."
      action-table.action-description  = "Connection Parameters"
      action-table.action-external     = false
      action-table.action-close-dialog = false
      action-table.action-procedure    = "action-conpar"
    .
    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "22"
      action-table.action-name         = "Cmd. String"
      action-table.action-description  = "Progress Command String"
      action-table.action-external     = false
      action-table.action-close-dialog = false
      action-table.action-procedure    = "action-cmdstring"
    .
    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "23"
      action-table.action-name         = "Context Vars"
      action-table.action-description  = "Show context variables"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "action-show-context"
    .
    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "24"
      action-table.action-name         = "Show locks"
      action-table.action-description  = "Show locks"
      action-table.action-external     = false
      action-table.action-close-dialog = false
      action-table.action-procedure    = "action-show-lock"
    .
    create action-table .
    assign
      action-table.action-group        = "Debug"
      action-table.action-num          = "41"
      action-table.action-name         = "Debugger"
      action-table.action-description  = "Launch and Initialise Debugger"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "gbl/inidebug.p"
    .
    create action-table .
    assign
      action-table.action-group        = "Debug"
      action-table.action-num          = "42"
      action-table.action-name         = "Break Point"
      action-table.action-description  = "Set Break Point"
      action-table.action-external     = false
      action-table.action-close-dialog = false
      action-table.action-procedure    = "action-break-point"
    .
    create action-table .
    assign
      action-table.action-group        = "Data"
      action-table.action-num          = "50"
      action-table.action-name         = "ERWin df"
      action-table.action-description  = "Generate df for ERWin synchronisation"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/df_erwin.p"
    .
    create action-table .
    assign
      action-table.action-group        = "Data"
      action-table.action-num          = "51"
      action-table.action-name         = "Make price.df"
      action-table.action-description  = "Generate price.df for denomination"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/df_price.p"
    .
    create action-table .
    assign
      action-table.action-group        = "Data"
      action-table.action-num          = "52"
      action-table.action-name         = "DF Description"
      action-table.action-description  = "Generate DF descriptions for translation"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/dfdescr.p"
    .
    create action-table .
    assign
      action-table.action-group        = "Data"
      action-table.action-num          = "53"
      action-table.action-name         = "Inactive Idx"
      action-table.action-description  = "Check Inactive Indexes"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/idxinact.p"
    .
    create action-table .
    assign
      action-table.action-group        = "Data"
      action-table.action-num          = "54"
      action-table.action-name         = "DF Duplicate"
      action-table.action-description  = "Generate DF duplicate"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/dfdupl.p"
    .
    create action-table .
    assign
      action-table.action-group        = "Data"
      action-table.action-num          = "55"
      action-table.action-name         = "Check Seq."
      action-table.action-description  = "Check sequence values"
      action-table.action-external     = false
      action-table.action-close-dialog = false
      action-table.action-procedure    = "action-check-seq"
    .
    create action-table .
    assign
      action-table.action-group        = "Data"
      action-table.action-num          = "56"
      action-table.action-name         = "Rest. Seq."
      action-table.action-description  = "Restore sequence values"
      action-table.action-external     = false
      action-table.action-close-dialog = false
      action-table.action-procedure    = "action-rest-seq"
    .
    create action-table .
    assign
      action-table.action-group        = "Data"
      action-table.action-num          = "57"
      action-table.action-name         = "Check DB schema"
      action-table.action-description  = "Check database schema"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/chkdd.p"
    .
    create action-table .
    assign
      action-table.action-group        = "Data"
      action-table.action-num          = "58"
      action-table.action-name         = "Check c-"
      action-table.action-description  = "Check table where deleted documents stored"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/compc-f.p"
    .
    create action-table .
    assign
      action-table.action-group        = "Data"
      action-table.action-num          = "59"
      action-table.action-name         = "DF Descr. Format"
      action-table.action-description  = "Create database description and format df file"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/dfdscfrm.p"
    .
    create action-table .
    assign
      action-table.action-group        = "Data"
      action-table.action-num          = "61"
      action-table.action-name         = "Gen. Include"
      action-table.action-description  = "Generate include files for news and database utilities"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/gen-main.p"
    .
    create action-table .
    assign
      action-table.action-group        = "Data"
      action-table.action-num          = "62"
      action-table.action-name         = "Gen. Include"
      action-table.action-description  = "Generate include files for cutting utilities"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/gencutld.p"
    .
    create action-table .
    assign
      action-table.action-group        = "Procedure"
      action-table.action-num          = "63"
      action-table.action-name         = "Check Syntax"
      action-table.action-description  = "Check Syntax of procedure"
      action-table.action-external     = false
      action-table.action-close-dialog = false
      action-table.action-procedure    = "action-check-syntax"
    .
    create action-table .
    assign
      action-table.action-group        = "Procedure"
      action-table.action-num          = "64"
      action-table.action-name         = "Search Proc."
      action-table.action-description  = "Search procedure"
      action-table.action-external     = false
      action-table.action-close-dialog = false
      action-table.action-procedure    = "action-search-procedure"
    .
    create action-table .
    assign
      action-table.action-group        = "Procedure"
      action-table.action-num          = "65"
      action-table.action-name         = "Upd ub.exe"
      action-table.action-description  = "Обновление болванки"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/ubexeupd.p"
    .
    create action-table .
    assign
      action-table.action-group        = "Procedure"
      action-table.action-num          = "66"
      action-table.action-name         = "ObjReg"
      action-table.action-description  = "Загруженные объекты"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/objreg.w"
    .
    create action-table .
    assign
      action-table.action-group        = "Procedure"
      action-table.action-num          = "67"
      action-table.action-name         = "GenDF"
      action-table.action-description  = "Генерация DF-файла"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/gendffile.w"
    .
    create action-table .
    assign
      action-table.action-group        = "Procedure"
      action-table.action-num          = "68"
      action-table.action-name         = "Clear Library"
      action-table.action-description  = "Clear library"
      action-table.action-external     = false
      action-table.action-close-dialog = false
      action-table.action-procedure    = "action-clear-library"
    .
    create action-table .
    assign
      action-table.action-group        = "Procedure"
      action-table.action-num          = "69"
      action-table.action-name         = "R-Code inf"
      action-table.action-description  = "Display R-Code information"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "gbl/rcodeinf.p"
    .
  end.
END PROCEDURE.
PROCEDURE open-query :
  do with frame Dialog-Frame:
    open query BROWSE-1 for each action-table
      where (cb-category :screen-value = "ALL")
        or (action-table.action-group = cb-category :screen-value)
        .
  end.
END PROCEDURE.
PROCEDURE perform-action :
  do
  on error undo, return no-apply
  on stop undo, return no-apply
  :
    if available action-table
    then do:
      if action-table.action-close-dialog = true
      then do:
        ASSIGN
          p-action = action-table.action-procedure
        .
        apply "go" to frame Dialog-Frame .
      end.
      else do:
        if action-table.action-external = true
        then do:
          run value(action-table.action-procedure) .
        end.
        else do:
          run value(action-table.action-procedure) in this-procedure .
        end.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE update-cb-category :
  define buffer buf_action-table for action-table .
  do with frame Dialog-Frame:
    define variable v-ok as logical   no-undo .
    assign
      cb-category :list-items = "ALL"
    .
    for each buf_action-table
      break by buf_action-table.action-group
    :
      if first-of(buf_action-table.action-group)
      then do:
        assign
          v-ok = cb-category :add-last(buf_action-table.action-group)
        .
      end.
    end.
    assign
      cb-category :screen-value = "ALL"
    .
  end.
END PROCEDURE.
