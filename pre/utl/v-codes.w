define input parameter p-range-type like ub.code-range.range-type no-undo .
define input parameter p-first-code like ub.code-range.first-code no-undo .
define input parameter p-type-code  as   character                no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Коды используемые в диапазонах".
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
define temp-table list-code no-undo
 field gds-name as character column-label "Товар" format "X(40)"
 field b-code   as character column-label "Код" format "X(10)"
 field bc-on    as logical   column-label "Вкл" format "+/-"
 index bc b-code
.
DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-GO DEFAULT
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE f-find-code AS INTEGER FORMAT ">,>>>,>>>,>>9":U INITIAL 0
     LABEL "Найдено"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE QUERY BROWSE-1 FOR
      list-code SCROLLING.
DEFINE BROWSE BROWSE-1
  QUERY BROWSE-1 DISPLAY
      list-code.bc-on
list-code.b-code
list-code.gds-name
    WITH NO-ROW-MARKERS SEPARATORS SIZE 57.25 BY 17.
DEFINE FRAME v-codes
     b-quit AT ROW 1.17 COL 2
     b-help AT ROW 1.17 COL 45.5
     BROWSE-1 AT ROW 2.5 COL 2.13
     f-find-code AT ROW 1.42 COL 21.88 COLON-ALIGNED
     SPACE(22.36) SKIP(17.90)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Коды"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME v-codes:SCROLLABLE       = FALSE
       FRAME v-codes:HIDDEN           = TRUE.
ASSIGN
       f-find-code:HIDDEN IN FRAME v-codes           = TRUE.
ON WINDOW-CLOSE OF FRAME v-codes
DO:
  APPLY "END-ERROR":U TO SELF.
END.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame v-codes
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
on choose of b-help in frame v-codes
do:
  apply "help":u to frame v-codes .
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
                v-frame-width = frame v-codes:width - 0.3
                fh            = frame v-codes:first-child
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
    if frame v-codes :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame v-codes :height-chars)
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
    if frame v-codes :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame v-codes :height-chars)
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
            frame v-codes :height = v-frame-height
          .
          if frame v-codes :scrollable = true
          then do:
            assign
              frame v-codes :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame v-codes :scrollable = true
          then do:
            assign
              frame v-codes :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame v-codes :height = v-frame-height
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
      v-frame-height = frame v-codes :height
      v-frame-virtual-height = frame v-codes :virtual-height
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
      v-field-group-handle = frame v-codes :first-child
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
    do with frame v-codes
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame v-codes :scrollable = true
      then do:
        assign
          frame v-codes :virtual-height = frame v-codes :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame v-codes :height = frame v-codes :height + p-change-value
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
        frame v-codes :height = frame v-codes :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame v-codes :scrollable = true
      then do:
        assign
          frame v-codes :virtual-height = frame v-codes :virtual-height + p-change-value
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
          ,input  string(frame v-codes :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame v-codes :height)
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
    if frame v-codes :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame v-codes :width
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
    if frame v-codes :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame v-codes :width
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
            frame v-codes :width = v-frame-width
          .
          if frame v-codes :scrollable = true
          then do:
            assign
              frame v-codes :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame v-codes :scrollable = true
          then do:
            assign
              frame v-codes :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame v-codes :width = v-frame-width
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
      v-frame-width = frame v-codes :width
      v-frame-virtual-width = frame v-codes :virtual-width
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
      v-field-group-handle = frame v-codes :first-child
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
    do with frame v-codes
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame v-codes :scrollable = true
      then do:
        assign
          frame v-codes :virtual-width = frame v-codes :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame v-codes :width = v-frame-width + p-change-value
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
        frame v-codes :width = frame v-codes :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame v-codes :scrollable = true
      then do:
        assign
          frame v-codes :virtual-width = frame v-codes :virtual-width + p-change-value
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
          ,input  string(frame v-codes :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame v-codes :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame v-codes
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame v-codes :height - v-diasize-resize-button :height
                  - 1
                  - (frame v-codes :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame v-codes :width - v-diasize-resize-button :width
                  - 1
                  - (frame v-codes :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame v-codes
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
      v-row-delta = v-new-row - frame v-codes :height
      v-col-delta = v-new-col - frame v-codes :width
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
            - frame v-codes :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame v-codes :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame v-codes :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame v-codes :height-chars
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
      v-diasize-current-frame-width  = frame v-codes :width
      v-diasize-current-frame-height = frame v-codes :height
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
    do with frame v-codes
    :
      assign
        v-diasize-orig-frame-height = frame v-codes :height
        v-diasize-orig-frame-width  = frame v-codes :width
        v-diasize-browse-handle     = browse BROWSE-1 :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame v-codes :first-child
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME v-codes:PARENT eq ?
THEN FRAME v-codes:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  define buffer buf1_code-range for ub.code-range .
  find first buf1_code-range no-lock
    where buf1_code-range.range-type = p-range-type
      and buf1_code-range.first-code = p-first-code
  .
  assign
    FRAME v-codes:title = substitute( "Коды в диапазоне &1 c &2 по &3", p-type-code, p-first-code, buf1_code-range.last-code )
  .
  RUN enable_UI.
  run fill-tt in this-procedure
    ( input p-range-type
     ,input p-first-code
     ,output f-find-code
    )
  .
  display
    f-find-code
    with frame v-codes
  .
  OPEN QUERY BROWSE-1 FOR EACH list-code BY b-code.
  WAIT-FOR GO OF FRAME v-codes focus browse BROWSE-1.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME v-codes.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE b-quit b-help BROWSE-1
      WITH FRAME v-codes.
  VIEW FRAME v-codes.
  OPEN QUERY BROWSE-1 FOR EACH list-code BY b-code.
END PROCEDURE.
PROCEDURE fill-tt :
define input  parameter p1-range-type like ub.code-range.range-type no-undo .
  define input  parameter p1-first-code like ub.code-range.first-code no-undo .
  define output parameter p-find-code   as   integer                  no-undo .
  do
  on error undo, return error
  :
    define variable v-integer   as integer   no-undo .
    define variable v-ind       as integer   no-undo .
    define variable v-str       as character no-undo .
    define variable v-view-code as integer   no-undo .
    define variable v-find-code as integer   no-undo .
    define frame inf
      v-view-code label "Просмотрено" skip
      v-find-code label "Найдено" skip
      with view-as dialog-box side-labels 1 columns three-d title "Поиск кодов".
    define buffer buf_code-range for ub.code-range .
    define buffer buf_goods for ub.goods .
    define buffer buf_bar-code for ub.bar-code .
    define buffer buf_prod-bc for ub.prod-bc .
    define buffer buf_dis-card for ub.dis-card.
    define buffer buf_dis-rule for ub.dis-rule.
    define buffer buf_dis-time-rule for ub.dis-time-rule.
    define buffer buf_firm  for ub.firm .
    define buffer buf_person  for ub.person .
    define buffer buf_clients for ub.clients.
    define buffer buf_contract for ub.contract .
    define buffer buf_rule-by-call for ub.rule-by-call.
    define buffer buf_sysconf for ub.sysconf.
    define buffer buf_fin-doc for ub.fin-doc.
    find first buf_code-range no-lock
      where buf_code-range.range-type = p1-range-type
        and buf_code-range.first-code = p1-first-code
    .
    assign
      v-view-code = 0
      v-find-code = 0
    .
    view frame inf.
    case buf_code-range.range-type :
      when 'bcgb':U
      then do:
        for each buf_bar-code no-lock
          where buf_bar-code.b-code >= buf_code-range.first-code
            and buf_bar-code.b-code <= buf_code-range.last-code
        on error undo, return error
        :
          find first buf_goods no-lock
            where buf_goods.gds-code = buf_bar-code.gds-code
            no-error
          .
          create list-code .
          assign
            list-code.gds-name = (if available buf_goods then buf_goods.gds-name else "":U)
            list-code.b-code   = string( buf_bar-code.b-code )
            list-code.bc-on    = true
            v-find-code = v-find-code + 1
            v-view-code = v-view-code + 1
          .
          if ( v-view-code modulo 100 ) = 0 then do:
            display
              v-view-code
              v-find-code
              with frame inf.
          end.
        end.
      end.
      when 'scgb':U
      or when 'sclc':U
      or when 'pglc':U
      or when 'ptlc':U
      or when 'sslc':U
      or when 'ssgb':U
      then do:
        for each buf_prod-bc no-lock
        on error undo, return error
        :
          if length( buf_prod-bc.b-str ) < 6 then do:
            find first buf_bar-code no-lock
              where buf_bar-code.b-code = buf_prod-bc.b-code
            .
            if available buf_bar-code then do:
              find first buf_goods no-lock
                where buf_goods.gds-code = buf_bar-code.gds-code
                no-error
              .
            end.
            assign
              v-integer = integer( buf_prod-bc.b-str ) no-error
            .
            assign
              v-str     = buf_prod-bc.b-str
              v-ind     = 6 - length( v-str )
            .
            do while v-ind > 0
            on error undo, return error
            :
              assign
                v-str = "0" + v-str
                v-ind = v-ind - 1
              .
            end.
            if string( v-integer, "999999" ) = v-str
              and v-integer >= buf_code-range.first-code
              and v-integer <= buf_code-range.last-code
            then do:
              create list-code .
              assign
                list-code.gds-name = (if available buf_goods then buf_goods.gds-name else "":U)
                list-code.b-code   = string( buf_prod-bc.b-str )
                list-code.bc-on    = buf_prod-bc.bc-on
                v-find-code = v-find-code + 1
              .
            end.
          end.
          assign
            v-view-code = v-view-code + 1
          .
          if ( v-view-code modulo 100 ) = 0 then do:
            display
              v-view-code
              v-find-code
              with frame inf.
          end.
        end.
      end.
      when 'dcgb':U
      then do:
        for each buf_dis-card no-lock
          where buf_dis-card.card-num >= buf_code-range.first-code
            and buf_dis-card.card-num <= buf_code-range.last-code
        on error undo, return error
        :
          create list-code .
          assign
            list-code.gds-name = buf_dis-card.d-card  + chr(32) + buf_dis-card.cli-type + string(buf_dis-card.cli-code)
            list-code.b-code   = string( buf_dis-card.card-num )
            list-code.bc-on    = true
            v-find-code = v-find-code + 1
            v-view-code = v-view-code + 1
          .
          if ( v-view-code modulo 100 ) = 0 then do:
            display
              v-view-code
              v-find-code
              with frame inf.
          end.
        end.
      end.
      when 'ctgb':U
      then do:
        for each buf_contract no-lock
          where buf_contract.contract-code >= buf_code-range.first-code
            and buf_contract.contract-code <= buf_code-range.last-code
        on error undo, return error
        :
          create list-code .
          assign
            list-code.gds-name = buf_contract.contract-prn-code  + chr(32) + buf_contract.cli-type + string(buf_contract.cli-code)
            list-code.b-code   = string( buf_contract.contract-code )
            list-code.bc-on    = true
            v-find-code = v-find-code + 1
            v-view-code = v-view-code + 1
          .
          if ( v-view-code modulo 100 ) = 0 then do:
            display
              v-view-code
              v-find-code
              with frame inf.
          end.
        end.
      end.
      when 'fmgb':U
      then do:
        for each buf_firm no-lock
          where buf_firm.firm-code >= buf_code-range.first-code
            and buf_firm.firm-code <= buf_code-range.last-code
        on error undo, return error
        :
          find first buf_clients no-lock where
                    buf_clients.obj-type = 'орг':U
                and buf_clients.obj-code = buf_firm.firm-code.
          create list-code .
          assign
            list-code.gds-name = substitute("&1&2 &3"
                                             , buf_clients.obj-type
                                             , buf_clients.obj-code
                                             , buf_clients.obj-name)
            list-code.b-code   = string( buf_firm.firm-code )
            list-code.bc-on    = true
            v-find-code = v-find-code + 1
            v-view-code = v-view-code + 1
          .
          if ( v-view-code modulo 100 ) = 0 then do:
            display
              v-view-code
              v-find-code
              with frame inf.
          end.
        end.
      end.
      when 'pngb':U
      then do:
        for each buf_person no-lock
          where buf_person.psn-code >= buf_code-range.first-code
            and buf_person.psn-code <= buf_code-range.last-code
        on error undo, return error
        :
          find first buf_clients no-lock where
                    buf_clients.obj-type = 'чел':U
                and buf_clients.obj-code = buf_person.psn-code.
          create list-code .
          assign
            list-code.gds-name = substitute("&1&2 &3"
                                             , buf_clients.obj-type
                                             , buf_clients.obj-code
                                             , buf_clients.obj-name)
            list-code.b-code   = string( buf_person.psn-code )
            list-code.bc-on    = true
            v-find-code = v-find-code + 1
            v-view-code = v-view-code + 1
          .
          if ( v-view-code modulo 100 ) = 0 then do:
            display
              v-view-code
              v-find-code
              with frame inf.
          end.
        end.
      end.
      when 'drgb':U then do:
        for each buf_dis-rule no-lock
          where buf_dis-rule.rule-num >= buf_code-range.first-code
            and buf_dis-rule.rule-num <= buf_code-range.last-code
        on error undo, return error
        :
          create list-code .
          assign
            list-code.gds-name = buf_dis-rule.des
            list-code.b-code   = string( buf_dis-rule.rule-num )
            list-code.bc-on    = true
            v-find-code = v-find-code + 1
            v-view-code = v-view-code + 1
          .
          if ( v-view-code modulo 100 ) = 0 then do:
            display
              v-view-code
              v-find-code
              with frame inf.
          end.
        end.
        for each buf_dis-time-rule no-lock
          where buf_dis-time-rule.time-rule-num >= buf_code-range.first-code
            and buf_dis-time-rule.time-rule-num <= buf_code-range.last-code
        on error undo, return error
        :
          create list-code .
          assign
            list-code.gds-name = buf_dis-time-rule.des
            list-code.b-code   = string( buf_dis-time-rule.time-rule-num )
            list-code.bc-on    = true
            v-find-code = v-find-code + 1
            v-view-code = v-view-code + 1
          .
          if ( v-view-code modulo 100 ) = 0 then do:
            display
              v-view-code
              v-find-code
              with frame inf.
          end.
        end.
      end.
      when 'cagb':U
      then do:
        for each buf_rule-by-call no-lock
          where buf_rule-by-call.call#_id >= buf_code-range.first-code
            and buf_rule-by-call.call#_id <= buf_code-range.last-code
        on error undo, return error
        :
          create list-code .
          assign
            list-code.gds-name = buf_rule-by-call.call_id
            list-code.b-code   = string( buf_rule-by-call.call#_id )
            list-code.bc-on    = true
            v-find-code = v-find-code + 1
            v-view-code = v-view-code + 1
          .
          if ( v-view-code modulo 100 ) = 0 then do:
            display
              v-view-code
              v-find-code
              with frame inf.
          end.
        end.
      end.
     when 'fdgb':U
      then do:
        for each buf_sysconf no-lock,
           each buf_fin-doc no-lock where
                buf_fin-doc.host-code = buf_sysconf.host-code
            and buf_fin-doc.fin-doc-code >= buf_code-range.first-code
            and buf_fin-doc.fin-doc-code <= buf_code-range.last-code
        on error undo, return error
        :
          create list-code .
          assign
            list-code.gds-name = substitute("Фирма &1 фин.док-нт &2 (&3)"
                                           ,buf_fin-doc.host-code
                                           ,buf_fin-doc.prn-doc-code
                                           ,buf_fin-doc.fin-doc-code
                                           )
            list-code.b-code   = string( buf_fin-doc.fin-doc-code )
            list-code.bc-on    = true
            v-find-code = v-find-code + 1
            v-view-code = v-view-code + 1
          .
          if ( v-view-code modulo 100 ) = 0 then do:
            display
              v-view-code
              v-find-code
              with frame inf.
          end.
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          substitute( "Нет обработки диапазонов с типом &1", buf_code-range.range-type )
          view-as alert-box error .
        return error .
      end.
    end case.
    assign
      p-find-code = v-find-code
    .
    hide frame inf.
  end.
END PROCEDURE.
