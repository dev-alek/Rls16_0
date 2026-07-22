/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ѕиблиотека изменени€ размеров окна

јвтор: ѕерваков ћихаил —ергеевич
ƒата создани€: 04/04/05
Author: Mikhail Pervakov
Creation date: 04/04/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ Ѕиблиотека изменени€ размеров окна".

&if defined(diasize_resizable_object) = 0 &then
  &scoped-define diasize_resizable_object browse {&browse-name}
&endif

&if defined(br-hndl) = 0 &then
  &scoped-define br-hndl {&diasize_resizable_object} :handle
&endif

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
    if frame {&frame-name} :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame {&frame-name} :height-chars)
      .
      if p-change-value <= 0
      then do:
        /* не позвол€ем увеличить размер окна больше максимального значени€ */
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.

  if p-change-value < 0
  then do:
    if frame {&frame-name} :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame {&frame-name} :height-chars)
      .
      if p-change-value >= 0
      then do:
        /* не позвол€ем уменьшить размер окна меньше минимального значени€ */
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
            frame {&frame-name} :height = v-frame-height
          .
          if frame {&frame-name} :scrollable = true
          then do:
            assign
              frame {&frame-name} :virtual-height = v-frame-virtual-height
            .
          end.
&if defined(diasize_window) > 0 &then
          assign
            {&diasize_window} :height = v-window-height
            {&diasize_window} :virtual-height = v-window-virtual-height
          .
&endif
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
&if defined(diasize_window) > 0 &then
          assign
            {&diasize_window} :virtual-height = v-window-virtual-height
            {&diasize_window} :height = v-window-height
          .
&endif
          if frame {&frame-name} :scrollable = true
          then do:
            assign
              frame {&frame-name} :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame {&frame-name} :height = v-frame-height
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
      v-frame-height = frame {&frame-name} :height
      v-frame-virtual-height = frame {&frame-name} :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
&if defined(diasize_window) > 0 &then
    assign
      v-window-height = {&diasize_window} :height
      v-window-virtual-height = {&diasize_window} :virtual-height
    .
&endif

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
      v-field-group-handle = frame {&frame-name} :first-child
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
            /* здесь ничего не делаем, так как у этого объекта будет мен€тьс€ высота */
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


    do with frame {&frame-name}
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.

    if p-change-value > 0
    then do:
&if defined(diasize_window) > 0 &then
      assign
        {&diasize_window} :virtual-height = {&diasize_window} :virtual-height + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        {&diasize_window} :height = {&diasize_window} :height + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
&endif
      if frame {&frame-name} :scrollable = true
      then do:
        assign
          frame {&frame-name} :virtual-height = frame {&frame-name} :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame {&frame-name} :height = frame {&frame-name} :height + p-change-value
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
        frame {&frame-name} :height = frame {&frame-name} :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.

      if frame {&frame-name} :scrollable = true
      then do:
        assign
          frame {&frame-name} :virtual-height = frame {&frame-name} :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
&if defined(diasize_window) > 0 &then
      assign
        {&diasize_window} :height = {&diasize_window} :height + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        {&diasize_window} :virtual-height = {&diasize_window} :virtual-height + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
&endif
    end.

    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.

    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo . /* текуща€ Ѕƒ            */
        define variable v-cntxt-userid        as character no-undo . /* текущий пользователь  */

        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame {&frame-name} :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.

  assign
    v-diasize-change-size = false
  .

end procedure. /* diasize_change-height */


procedure diasize_set-height :

  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .

  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame {&frame-name} :height)
      ,input  p-move-resize
      ) .
  end.

end procedure. /* diasize_set-width */


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
    if frame {&frame-name} :width + p-change-value >
        session :width-chars
    then do:
      /* контроль максимально возможного размера окна */
      assign
        p-change-value = session :width-chars - frame {&frame-name} :width
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
    if frame {&frame-name} :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame {&frame-name} :width
      .
      if p-change-value >= 0
      then do:
        /* не позвол€ем уменьшить размер окна меньше минимального значени€ */
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
            frame {&frame-name} :width = v-frame-width
          .
          if frame {&frame-name} :scrollable = true
          then do:
            assign
              frame {&frame-name} :virtual-width = v-frame-virtual-width
            .
          end.
&if defined(diasize_window) > 0 &then
          assign
            {&diasize_window} :width = v-window-width
            {&diasize_window} :virtual-width = v-window-virtual-width
          .
&endif
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
&if defined(diasize_window) > 0 &then
          assign
            {&diasize_window} :virtual-width = v-window-virtual-width
            {&diasize_window} :width = v-window-width
          .
&endif
          if frame {&frame-name} :scrollable = true
          then do:
            assign
              frame {&frame-name} :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame {&frame-name} :width = v-frame-width
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
      v-frame-width = frame {&frame-name} :width
      v-frame-virtual-width = frame {&frame-name} :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
&if defined(diasize_window) > 0 &then
    assign
      v-window-width = {&diasize_window} :width
      v-window-virtual-width = {&diasize_window} :virtual-width
    .
&endif

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
      v-field-group-handle = frame {&frame-name} :first-child
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
            /* здесь ничего не делаем, так как у этого объекта будет мен€тьс€ ширина */
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

    do with frame {&frame-name}
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end. /* do with frame */

    if p-change-value > 0
    then do:
&if defined(diasize_window) > 0 &then
      assign
        {&diasize_window} :virtual-width = {&diasize_window} :virtual-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        {&diasize_window} :width = {&diasize_window} :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
&endif
      if frame {&frame-name} :scrollable = true
      then do:
        assign
          frame {&frame-name} :virtual-width = frame {&frame-name} :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame {&frame-name} :width = v-frame-width + p-change-value
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
        frame {&frame-name} :width = frame {&frame-name} :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame {&frame-name} :scrollable = true
      then do:
        assign
          frame {&frame-name} :virtual-width = frame {&frame-name} :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
&if defined(diasize_window) > 0 &then
      assign
        {&diasize_window} :width = {&diasize_window} :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        {&diasize_window} :virtual-width = {&diasize_window} :virtual-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
&endif
    end.

    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.

    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo . /* текуща€ Ѕƒ            */
        define variable v-cntxt-userid        as character no-undo . /* текущий пользователь  */

        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame {&frame-name} :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.

  assign
    v-diasize-change-size = false
  .

end procedure. /* change-width */


procedure diasize_set-width :

  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .

  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame {&frame-name} :width)
      ,input  p-move-resize
      ) .
  end.

end procedure. /* diasize_set-width */


procedure diasize_position-resize-button :

  do with frame {&frame-name}
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame {&frame-name} :height - v-diasize-resize-button :height
                  - 1
                  - (frame {&frame-name} :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame {&frame-name} :width - v-diasize-resize-button :width
                  - 1
                  - (frame {&frame-name} :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end. /* do with frame */

end procedure. /* diasize_position-resize-button */

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

on alt-enter of frame {&frame-name}
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
      v-row-delta = v-new-row - frame {&frame-name} :height
      v-col-delta = v-new-col - frame {&frame-name} :width
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

end procedure. /* diasize_end-move */


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
            - frame {&frame-name} :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame {&frame-name} :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame {&frame-name} :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame {&frame-name} :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.

end procedure. /* diasize_maximize */


procedure diasize_restore-orig-size :

  do
  on error undo, return error return-value
  :
    /* запомнить размер окна на момент вызова процедуры */
    assign
      v-diasize-current-frame-width  = frame {&frame-name} :width
      v-diasize-current-frame-height = frame {&frame-name} :height
    .

    /* вернуть первоначальный размер окна */
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.

end procedure. /* diasize_restore-orig-size */


procedure diasize_restore-current-size :

  do
  on error undo, return error return-value
  :
    /* восстановить размер окна до вызова функции */
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.

end procedure. /* diasize_restore-current-size */


procedure diasize_set-browse-handle :

  define input  parameter p-browse-handle as handle   no-undo .


  define buffer buf_temp-browse-handle for temp-browse-handle .

  do
  on error undo, return error return-value
  :
    /* изменить указатель на браузер */
    assign
      v-diasize-browse-handle = p-browse-handle
    .

    /* очистить список дополнительных браузеров */
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.

end procedure. /* diasize_set-browse-handle */


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

end procedure. /* diasize_add_browse */


procedure diasize_init :

  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .

  do
  on error undo, return error return-value
  :
    do with frame {&frame-name}
    :
      assign
        v-diasize-orig-frame-height = frame {&frame-name} :height
        v-diasize-orig-frame-width  = frame {&frame-name} :width
        v-diasize-browse-handle     = {&br-hndl}
      .

      create button v-diasize-resize-button
      assign
        parent        = frame {&frame-name} :first-child
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

        define variable v-cntxt-db-num        as integer   no-undo . /* текуща€ Ѕƒ            */
        define variable v-cntxt-userid        as character no-undo . /* текущий пользователь  */

        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .

        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  {&user-window-maximize}
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
          ,input  {&user-window-size-store}
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.

      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .

      if v-diasize-wndstore = true
      then do:
        /* пытаемс€ считать сохранЄнные значени€       */
        /* если они есть, то устававливаем размер окна */
        /* в соответствии с сохранЄнными значени€ми    */
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
    end. /* do with frame */
  end.
end procedure. /* diasize_init */


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

end procedure. /* diasize_need-full-display */

/*==========================================================================*/
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
   end. /* do on error */
end procedure. /* get-context */



/* $Workfile$ e n d */