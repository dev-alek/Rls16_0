define input parameter parmode as character no-undo.
define input-output parameter parnum-tank as CHARACTER no-undo.
define input parameter partype-AC  as integer   no-undo .
define input parameter parsec-qnty  as decimal   no-undo .
define input parameter par-neck  as integer   no-undo .
define input parameter parsec-num as integer no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Измерение по резервуару".
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
define buffer buf_auto-tank for auto-tank.
define variable jj        as integer   no-undo .
define variable v-section as character no-undo  .
define temp-table tt-section no-undo
    field dif     as integer
    field volume1 as decimal
    index pi dif
    .
define button b-cancel auto-end-key
    label "&Отмена"
    size 10 by 1
    bgcolor 8 .
define button b-help
     label "Помо&щь"
     size 10 by 1
     bgcolor 8 .
define button b-save auto-go
    label "&Ввод"
    size 10 by 1
    bgcolor 8 .
define variable ellipse-depth      as decimal format ">>,>>9.999"
    label "Толщина стенки горловины, мм"
    view-as fill-in
    size 15 by 1 no-undo.
define variable ellipse-max        as decimal format ">>,>>9.999"
    label "Диаметр горловины большой оси эллипса, мм"
    view-as fill-in
    size 15 by 1 no-undo.
define variable ellipse-min        as decimal format ">>,>>9.999"
    label "Диаметр горловины малой оси эллипса, мм"
    view-as fill-in
    size 15 by 1 no-undo.
define variable F-dop-volume       as decimal   format ">>,>>9.999":U initial 0
    label "Доп.объем трубопровода нижнего налива,л"
    view-as fill-in
    size 15 by 1 no-undo.
define variable square-depth       as decimal format ">>,>>9.999"
    label "Толщина стенки горловины, мм"
    view-as fill-in
    size 15 by 1 no-undo.
define variable square-lenght      as decimal format ">>,>>9.999"
    label "Длина горловины, мм"
    view-as fill-in
    size 15 by 1 no-undo.
define variable square-width       as decimal format ">>,>>9.999"
    label "Ширина горловины, мм"
    view-as fill-in
    size 15 by 1 no-undo.
define variable varsec-diam-in     as decimal format ">>,>>9.999"
    label "Внутренний диаметр горловины, мм"
    view-as fill-in
    size 15 by 1 no-undo.
define variable varsec-diam-out    as decimal format ">>,>>9.999"
    label "Внешний диаметр горловины, мм"
    view-as fill-in
    size 15 by 1 no-undo.
define variable varsec-diam-depth  as decimal format ">>,>>9.999"
    label "Толщина стенки горловины, мм"
    view-as fill-in
    size 15 by 1 no-undo.
define variable varsec-diam-lenght as decimal format ">>,>>9.999"
    label "Длина внешней окружности горловины, мм"
    view-as fill-in
    size 15 by 1 no-undo.
define variable varsec-num         as integer   format ">,>>>,>>9" initial 0
    label "Номер секции"
    view-as fill-in
    size 15 by 1 no-undo.
define variable varsec-qnty        as decimal   format ">>>,>>>,>>9.999" initial 0
    label "Вместимость, л"
    view-as fill-in
    size 15 by 1 no-undo.
define query BROWSE-2 for
    tt-section scrolling.
define browse BROWSE-2
    query BROWSE-2 display
    tt-section.dif column-label "Отклонение,см" format "->9.9":U width 15
    tt-section.volume1 column-label "Объем!для указанного!отклонения от планки,л" format "->>,>>9.99":U
  ENABLE
      tt-section.volume1
    WITH NO-ROW-MARKERS SEPARATORS SIZE 58 BY 7.75 FIT-LAST-COLUMN.
define frame Dialog-Frame
    b-save at row 1 col 1 widget-id 2
    b-cancel at row 1 col 11 widget-id 4
    b-help at row 1 col 21 widget-id 6
    varsec-num at row 2.25 col 42.5 colon-aligned widget-id 8
    varsec-qnty at row 3.5 col 42.5 colon-aligned widget-id 10
    F-dop-volume at row 4.75 col 42.5 colon-aligned widget-id 18
    BROWSE-2 at row 6 col 1.5 widget-id 100
    varsec-diam-in at row 6 col 42.5 colon-aligned widget-id 16
    varsec-diam-out at row 7.25 col 42.5 colon-aligned widget-id 38
    varsec-diam-depth at row 8.5 col 42.5 colon-aligned widget-id 40
    varsec-diam-lenght at row 9.75 col 42.5 colon-aligned widget-id 42
    square-lenght at row 6 col 42.5 colon-aligned widget-id 26
    ellipse-max at row 6 col 42.5 colon-aligned widget-id 32
    square-width at row 7.25 col 42.5 colon-aligned widget-id 28
    ellipse-min at row 7.25 col 42.5 colon-aligned widget-id 34
    square-depth at row 8.5 col 42.5 colon-aligned widget-id 30
    ellipse-depth at row 8.5 col 42.5 colon-aligned widget-id 36
    space(1.12) skip(4.87)
    with view-as dialog-box keep-tab-order
         side-labels no-underline three-d  scrollable
         title "Данные по секции"
         default-button b-save cancel-button b-cancel.
assign
       frame Dialog-Frame:SCROLLABLE       = false
       frame Dialog-Frame:HIDDEN           = true.
on window-close of frame Dialog-Frame
do:
        apply "END-ERROR":U to self.
    end.
on choose of b-save in frame Dialog-Frame
do:
        define variable ii as integer no-undo .
        define buffer tt-section for tt-section.
        if input frame Dialog-Frame varsec-num <= 0 then
        do:
            message "Номер секции указан неверно." view-as alert-box error.
            return no-apply.
        end.
   if ((par-neck = 0 and partype-AC = 1) or
      (par-neck = 0 and partype-AC = 2) or
      (par-neck = 1 and
      input frame Dialog-Frame square-depth <> '' and
      input frame Dialog-Frame square-lenght <> '' and
      input frame Dialog-Frame square-width <> '') or
      (par-neck = 2 and
      input frame Dialog-Frame ellipse-min <> '' and
      input frame Dialog-Frame ellipse-max <> '' and
      input frame Dialog-Frame ellipse-depth <> '') or
      (par-neck = 3 and
      input frame Dialog-Frame varsec-diam-depth <> '' and
      input frame Dialog-Frame varsec-diam-in <> '' and
      input frame Dialog-Frame varsec-diam-lenght <> '' and
      input frame Dialog-Frame varsec-diam-out <> '')) and
      (parmode = 'ДОБАВЛЕНИЕ':U or parmode = 'ИЗМЕНЕНИЕ':U) then
   do:
      if par-neck = 2 then
      do:
        parnum-tank = string(input frame Dialog-Frame F-dop-volume) + chr(4) +
          STRING(input frame Dialog-Frame ellipse-depth) + chr(4) +
          STRING(input frame Dialog-Frame ellipse-min) + chr(4) +
          STRING(input frame Dialog-Frame ellipse-max).
      end.
      if par-neck = 1 then
      do:
        parnum-tank = string(input frame Dialog-Frame F-dop-volume) + chr(4) +
          STRING(input frame Dialog-Frame square-depth) + chr(4) +
          STRING(input frame Dialog-Frame square-lenght) + chr(4) +
          STRING(input frame Dialog-Frame square-width).
      end.
      if par-neck = 3 then
      do:
        parnum-tank = string(input frame Dialog-Frame F-dop-volume) + chr(4) +
          STRING(input frame Dialog-Frame varsec-diam-in) + chr(4) +
          STRING(input frame Dialog-Frame varsec-diam-out) + chr(4) +
          STRING(input frame Dialog-Frame varsec-diam-lenght) + chr(4) +
          STRING(input frame Dialog-Frame varsec-diam-depth) .
      end.
      if par-neck = 0 then
      do:
        parnum-tank = string(input frame Dialog-Frame F-dop-volume).
        if partype-AC = 1 then
        do:
          do ii = -10 to 10:
            for each tt-section where tt-section.dif = ii:
              parnum-tank = parnum-tank + chr(4) +
                string(ii) + chr(6) + string(tt-section.volume1) .
            end.
          end.
        end.
      end.
    end.
    else
    do :
      message "Введите данные!" view-as alert-box.
      return no-apply.
    end.
  end.
on value-changed of BROWSE-2 in frame Dialog-Frame
do:
   if available (tt-section) then do:
   end.
end.
on ENTER of BROWSE-2 in frame Dialog-Frame
anywhere
do:
end.
on leave of ellipse-depth in frame Dialog-Frame
do:
  assign ellipse-depth .
end.
on leave of ellipse-max in frame Dialog-Frame
do:
  assign ellipse-max .
end.
on leave of ellipse-min in frame Dialog-Frame
do:
  assign ellipse-min .
end.
on leave of F-dop-volume in frame Dialog-Frame
do:
  assign f-dop-volume .
end.
on leave of square-depth in frame Dialog-Frame
do:
 assign square-depth .
end.
on leave of square-lenght in frame Dialog-Frame
do:
  assign square-lenght .
end.
on leave of square-width in frame Dialog-Frame
do:
  assign square-width .
end.
on leave of varsec-diam-in in frame Dialog-Frame
do:
           if string(varsec-diam-in) <> varsec-diam-in:screen-value then
        do:
            assign varsec-diam-out .
        end.
        if varsec-diam-in > varsec-diam-out then
        do:
            message "Внутренний диаметр грловины должен быть меньше внешнего"
                view-as alert-box.
            return no-apply .
        end.
end.
on leave of varsec-diam-out in frame Dialog-Frame
do:
           if string(varsec-diam-out) <> varsec-diam-out:screen-value then
        do:
            assign varsec-diam-out .
        end.
        if varsec-diam-in > varsec-diam-out then
        do:
            message "Внутренний диаметр грловины должен быть меньше внешнего"
                view-as alert-box.
            return no-apply .
        end.
end.
on leave of varsec-diam-depth in frame Dialog-Frame
do:
  assign varsec-diam-depth .
end.
on leave of varsec-diam-lenght in frame Dialog-Frame
do:
  assign varsec-diam-lenght .
end.
on leave of varsec-num in frame Dialog-Frame
do:
  assign varsec-num .
end.
on leave of varsec-qnty in frame Dialog-Frame
do:
  assign varsec-qnty .
end.
if valid-handle(active-window) and frame Dialog-Frame:PARENT eq ?
    then frame Dialog-Frame:PARENT = active-window.
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
        v-diasize-browse-handle     = browse BROWSE-2 :handle
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
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
    on end-key undo MAIN-BLOCK, leave MAIN-BLOCK:
    define variable ii as integer no-undo .
  varsec-qnty = parsec-qnty.
  varsec-num = parsec-num.
  if par-neck = 2 then
  do:
      F-dop-volume = decimal(entry(1, parnum-tank, chr(4)) ) no-error.
      ellipse-depth = decimal (entry(2, parnum-tank, chr(4))) no-error.
      ellipse-max = decimal (entry(3, parnum-tank, chr(4))) no-error.
      ellipse-min = decimal (entry(4, parnum-tank, chr(4))) no-error.
  end.
  if par-neck = 1 then
  do:
      F-dop-volume = decimal(entry(1, parnum-tank, chr(4)) ) no-error.
      square-depth = decimal (entry(2, parnum-tank, chr(4))) no-error.
      square-lenght = decimal (entry(3, parnum-tank, chr(4))) no-error.
      square-width = decimal (entry(4, parnum-tank, chr(4))) no-error.
  end.
  if par-neck = 3 then
  do:
      F-dop-volume = decimal(entry(1, parnum-tank, chr(4)) ) no-error.
      varsec-diam-in = decimal (entry(2, parnum-tank, chr(4))) no-error.
      varsec-diam-out = decimal (entry(3, parnum-tank, chr(4))) no-error.
      varsec-diam-lenght = decimal (entry(4, parnum-tank, chr(4))) no-error.
      varsec-diam-depth = decimal (entry(5, parnum-tank, chr(4))) no-error.
  end.
  if par-neck = 0 then
  do:
      empty temp-table tt-section.
      F-dop-volume = decimal(entry(1, parnum-tank, chr(4)) ) no-error.
      if partype-AC = 1 then do:
      do ii = 2 to num-entries (parnum-tank,chr(4)):
          v-section = entry(ii, parnum-tank, chr(4)) .
          create tt-section .
          assign
              tt-section.dif     = integer(entry (1,v-section,chr(6))) no-error .
              tt-section.volume1 = decimal(entry (2,v-section,chr(6))) no-error .
              .
      end.
      if v-section = "" then do:
         do ii = -10 to 10:
            if ii = 0 then next .
            create tt-section .
            assign
               tt-section.dif = ii
               .
      end.
      end.
      end.
  end.
  run local-enable_UI.
  wait-for go of frame Dialog-Frame.
end.
run disable_UI.
procedure disable_UI :
  hide frame Dialog-Frame.
end procedure.
procedure enable_UI :
    display varsec-num varsec-qnty F-dop-volume
        with frame Dialog-Frame.
    enable b-cancel b-help F-dop-volume BROWSE-2
        with frame Dialog-Frame.
    view frame Dialog-Frame.
end procedure.
procedure local-enable_UI :
    run enable_ui.
  if parmode = 'ДОБАВЛЕНИЕ':U or
     parmode = 'ИЗМЕНЕНИЕ':U then do:
     case par-neck:
         when 2 then do:
            enable
            ellipse-depth
            ellipse-max
            ellipse-min
            with frame Dialog-Frame .
            display
            ellipse-depth
            ellipse-max
            ellipse-min
            with frame Dialog-Frame .
            hide
            square-depth
            square-lenght
            square-width
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            BROWSE-2
            in frame Dialog-Frame .
         end.
         when 1 then do:
            enable
            square-depth
            square-lenght
            square-width
            with frame Dialog-Frame .
            display
            square-depth
            square-lenght
            square-width
            with frame Dialog-Frame .
            hide
            ellipse-depth
            ellipse-max
            ellipse-min
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            BROWSE-2
            in frame Dialog-Frame .
         end.
         when 3 then do:
            enable
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            with frame Dialog-Frame .
            display
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            with frame Dialog-Frame .
            hide
            ellipse-depth
            ellipse-max
            ellipse-min
            square-depth
            square-lenght
            square-width
            BROWSE-2
            in frame Dialog-Frame .
         end.
         when 0 then do:
         if partype-AC = 1 then do:
            enable
            BROWSE-2
            with frame Dialog-Frame .
            OPEN QUERY BROWSE-2 FOR EACH tt-section INDEXED-REPOSITION.
         end.
         else do:
            hide
            BROWSE-2
            in frame Dialog-Frame .
         end.
            hide
            ellipse-depth
            ellipse-max
            ellipse-min
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            square-depth
            square-lenght
            square-width
            in frame Dialog-Frame .
         end.
     end case .
     enable b-save with frame Dialog-Frame.
     if partype-AC = 2 then do:
         hide
             F-dop-volume
             ellipse-depth
             ellipse-max
             ellipse-min
             varsec-diam-in
             varsec-diam-out
             varsec-diam-depth
             varsec-diam-lenght
             square-depth
             square-lenght
             square-width
             BROWSE-2
             in frame Dialog-Frame .
end.
     else enable F-dop-volume with frame Dialog-Frame .
  end.
  else do:
     case par-neck:
         when 2 then do:
            disable
            ellipse-depth
            ellipse-max
            ellipse-min
            with frame Dialog-Frame .
            display
            ellipse-depth
            ellipse-max
            ellipse-min
            with frame Dialog-Frame .
            hide
            square-depth
            square-lenght
            square-width
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            BROWSE-2
            in frame Dialog-Frame .
         end.
         when 1 then do:
            disable
            square-depth
            square-lenght
            square-width
            with frame Dialog-Frame .
            display
            square-depth
            square-lenght
            square-width
            with frame Dialog-Frame .
            hide
            ellipse-depth
            ellipse-max
            ellipse-min
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            BROWSE-2
            in frame Dialog-Frame .
         end.
         when 3 then do:
            disable
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            with frame Dialog-Frame .
            display
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            with frame Dialog-Frame .
            hide
            ellipse-depth
            ellipse-max
            ellipse-min
            square-depth
            square-lenght
            square-width
            BROWSE-2
            in frame Dialog-Frame .
         end.
         when 0 then do:
         if partype-AC = 1 then do:
            display
            BROWSE-2
            with frame Dialog-Frame .
            OPEN QUERY BROWSE-2 FOR EACH tt-section INDEXED-REPOSITION.
         end.
         else do:
            hide
            BROWSE-2
            in frame Dialog-Frame .
         end.
            hide
            ellipse-depth
            ellipse-max
            ellipse-min
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            square-depth
            square-lenght
            square-width
            in frame Dialog-Frame .
         end.
     end case .
     if partype-AC = 2 then hide F-dop-volume in frame Dialog-Frame .
     else disable F-dop-volume with frame Dialog-Frame .
  end .
  disable varsec-num varsec-qnty with frame Dialog-Frame.
end procedure.
