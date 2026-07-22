define input parameter p-doc-code   as character    no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "История производства".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
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
define variable v-fbrhist-sort-type         as integer              no-undo.
define variable v-fbrhist-doc-code          as character            no-undo.
define variable v-fbrhist-date-from         as date                 no-undo.
define variable v-fbrhist-date-to           as date                 no-undo.
define variable v-fbrhist-level             as integer              no-undo.
define variable v-fbrhist-userid            as character            no-undo.
define variable v-fbrhist-cur-recid         as integer              no-undo.
define variable v-fbrhist-focused-row       as integer              no-undo.
define variable v-fbrhist-columns-amount    as integer              no-undo.
define variable v-fbrhist-column-handles    as handle   extent 20   no-undo.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "В&ыход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON bt-del
     LABEL "О&чистить"
     SIZE 10 BY 1.
DEFINE BUTTON bt-sort
     LABEL "Группировка"
     SIZE 15 BY 1.
DEFINE VARIABLE ed-comment AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 52 BY 2.75
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE ed-parameters AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 44 BY 2.75
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-sort-string AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 42 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY BROWSE-1 FOR
      fbr-history SCROLLING.
DEFINE BROWSE BROWSE-1
  QUERY BROWSE-1 NO-LOCK DISPLAY
      fbr-history.hst-code COLUMN-LABEL "КодЗаписи" FORMAT "999999999":U
            WIDTH 10
      fbr-history.hst-upper-code COLUMN-LABEL "КодРод" FORMAT "999999999":U
            WIDTH 10
      fbr-history.hst-level COLUMN-LABEL "Дет" FORMAT "ZZ9":U
      fbr-history.sys-date FORMAT "99/99/9999":U
      fbr-history.hst-type COLUMN-LABEL "Событие" FORMAT "X(8)":U
            WIDTH 9
      fbr-history.obj-type COLUMN-LABEL "Тип" FORMAT "X(3)":U WIDTH 4
      fbr-history.obj-code COLUMN-LABEL "кодОб" FORMAT "99999":U
      fbr-history.doc-code FORMAT "X(14)":U
      fbr-history.doc-type COLUMN-LABEL "ТипДок" FORMAT "X(6)":U
      fbr-history.status_ FORMAT "X(8)":U
      fbr-history.recipe-type COLUMN-LABEL "ТипРец" FORMAT "X(16)":U
      fbr-history.recipe-code COLUMN-LABEL "НомРец" FORMAT "X(8)":U
      fbr-history.gds-code COLUMN-LABEL "КодТов" FORMAT "999999999":U
      fbr-history.trn-type COLUMN-LABEL "Спи" FORMAT "X(3)":U
      fbr-history.qnty FORMAT "->>,>>>,>>9.<<<":U
      fbr-history.PS FORMAT "X(50)":U
      fbr-history.user-name COLUMN-LABEL "Пользователь" FORMAT "X(12)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.5 BY 17.75 ROW-HEIGHT-CHARS .58 EXPANDABLE.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.25 COL 2
     bt-del AT ROW 1.25 COL 12
     bt-sort AT ROW 1.25 COL 29.5
     fi-sort-string AT ROW 1.25 COL 43 COLON-ALIGNED NO-LABEL
     b-help AT ROW 1.25 COL 88.5
     BROWSE-1 AT ROW 2.5 COL 2
     ed-parameters AT ROW 20.5 COL 2 NO-LABEL
     ed-comment AT ROW 20.5 COL 46.5 NO-LABEL
     SPACE(0.62) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История производства"
         DEFAULT-BUTTON b-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       ed-comment:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       ed-parameters:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
    run set-param in this-procedure (
          input v-fbrhist-sort-type
        , input v-fbrhist-doc-code
        , input v-fbrhist-date-from
        , input v-fbrhist-date-to
        , input v-fbrhist-level
        , input v-fbrhist-userid
        , input ( if available fbr-history then integer( recid( fbr-history ) ) else 0 )
        , input browse-1 :focused-row in frame Dialog-Frame
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка записи параметров списка истории производства"
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
    end.
END.
ON ROW-DISPLAY OF BROWSE-1 IN FRAME Dialog-Frame
DO:
    define variable v-counter    as integer      no-undo.
    if available fbr-history
    then do:
        if fbr-history.is-error = yes
        then do:
            do v-counter = 1 to v-fbrhist-columns-amount
            :
                assign
                    v-fbrhist-column-handles [ v-counter ] :fgcolor = 4
                .
            end.
        end.
        else do:
            if fbr-history.hst-type         = 'запуск':U
            or fbr-history.hst-type         = 'выход':U
            or fbr-history.hst-upper-code   = 0
            then do:
                do v-counter = 1 to v-fbrhist-columns-amount
                :
                    assign
                        v-fbrhist-column-handles [ v-counter ] :fgcolor = 1
                    .
                end.
            end.
        end.
    end.
END.
ON VALUE-CHANGED OF BROWSE-1 IN FRAME Dialog-Frame
DO:
    run refresh-editors in this-procedure.
END.
ON CHOOSE OF bt-del IN FRAME Dialog-Frame
DO:
    define variable v-date-to-clear as date         no-undo.
    define variable v-clear-level   as integer      no-undo.
    define variable v-ok            as logical      no-undo.
    run str/fbrhistd.w (
          output v-date-to-clear
        , output v-clear-level
        , output v-ok
    ) no-error.
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка задания параметров очистки истории."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-ok = yes
    then do:
        message
                 "Очистка истории."
            skip (1)
            skip "Дата, до которой история будет очищена:" v-date-to-clear
            skip "Уровень детализации очистки:" v-clear-level
            skip (1)
            skip "Очистить историю?"
        view-as alert-box information
        buttons yes-no
        title "Очистка истории"
        update v-ok.
        if v-ok = yes
        then do:
            run clear-history in this-procedure (
                  input v-date-to-clear
                , input v-clear-level
            ) no-error.
            if error-status :error
            then do:
                message
                    vss-workfile vss-revision vss-description
                    skip "Ошибка при очистке истории."
                    skip return-value
                    skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return no-apply .
            end.
            run local-open-query in this-procedure.
        end.
    end.
END.
ON CHOOSE OF bt-sort IN FRAME Dialog-Frame
DO:
    define variable v-sort-type     as integer      no-undo.
    define variable v-doc-code      as character    no-undo.
    define variable v-date-from     as date         no-undo.
    define variable v-date-to       as date         no-undo.
    define variable v-level         as integer      no-undo.
    define variable v-userid        as character    no-undo.
    define variable v-ok            as logical      no-undo.
    if available fbr-history
    then do:
        assign
            v-sort-type  = v-fbrhist-sort-type
            v-doc-code   = fbr-history.doc-code
            v-date-from  = v-fbrhist-date-from
            v-date-to    = v-fbrhist-date-to
            v-level      = v-fbrhist-level
            v-userid     = fbr-history.user-name
        .
    end.
    else do:
        assign
            v-sort-type  = v-fbrhist-sort-type
            v-doc-code   = v-fbrhist-doc-code
            v-date-from  = v-fbrhist-date-from
            v-date-to    = v-fbrhist-date-to
            v-level      = v-fbrhist-level
            v-userid     = v-fbrhist-userid
        .
    end.
    run str/fbrhists.w (
          input v-sort-type
        , input v-doc-code
        , input v-date-from
        , input v-date-to
        , input v-level
        , input v-userid
        , output v-fbrhist-sort-type
        , output v-fbrhist-doc-code
        , output v-fbrhist-date-from
        , output v-fbrhist-date-to
        , output v-fbrhist-level
        , output v-fbrhist-userid
        , output v-ok
    ) no-error.
    if error-status :error
    then do:
        message
                vss-workfile vss-revision vss-description
            skip "Ошибка изменения правил группировки."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-ok = yes
    and ( v-fbrhist-sort-type <> v-sort-type
        or v-fbrhist-doc-code  <> v-doc-code
        or v-fbrhist-date-from <> v-date-from
        or v-fbrhist-date-to   <> v-date-to
        or v-fbrhist-level     <> v-level
        or v-fbrhist-userid    <> v-userid )
    then do:
        run local-open-query in this-procedure.
        run assign-fi-sort-string in this-procedure.
    end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    run get-param in this-procedure.
    RUN enable_UI.
    run fill-column-handles in this-procedure.
    run assign-fi-sort-string in this-procedure.
    if v-fbrhist-cur-recid <> 0
    then do:
        browse-1 :set-repositioned-row( v-fbrhist-focused-row, "ALWAYS" ) in frame Dialog-Frame.
        reposition browse-1 to recid( v-fbrhist-cur-recid ) no-error.
    end.
    run refresh-editors in this-procedure.
    WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE assign-fi-sort-string :
do
on error undo, return error
:
    case v-fbrhist-sort-type
    :
        when 1
        then do:
            assign
                fi-sort-string = "Все" + ( if v-fbrhist-level <> 0 then " до уровня " + string( v-fbrhist-level ) else "" )
            .
        end.
        when 2
        then do:
            assign
                fi-sort-string = ( if v-fbrhist-doc-code <> "" then "По документу " + v-fbrhist-doc-code else "" )
            .
        end.
        when 3
        then do:
            assign
                fi-sort-string = "Даты"
                            + ( if v-fbrhist-date-from <> ? then " с ":U + string( v-fbrhist-date-from, "99.99.99" ) else "" )
                            + ( if v-fbrhist-date-to   <> ? then " по ":U + string( v-fbrhist-date-to, "99.99.99" )  else "" )
                            + ( if v-fbrhist-level <> 0 then " до уровня ":U + string( v-fbrhist-level ) else "" )
            .
        end.
        when 4
        then do:
            assign
                fi-sort-string = ( if v-fbrhist-userid   <> "" then "Пользователь " + v-fbrhist-userid else "" )
            .
        end.
    end case.
    display
        fi-sort-string
    with frame Dialog-Frame .
end.
END PROCEDURE.
PROCEDURE clear-history :
define input parameter p-date-to-clear  as date         no-undo.
define input parameter p-clear-level    as integer      no-undo.
    define buffer buf_fbr-history       for fbr-history.
do
for buf_fbr-history
on error undo, return error
:
    for each buf_fbr-history exclusive-lock
       where buf_fbr-history.sys-date  <= p-date-to-clear
         and buf_fbr-history.hst-level >= p-clear-level
    on error undo, return error
    :
        delete buf_fbr-history.
    end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fi-sort-string ed-parameters ed-comment
      WITH FRAME Dialog-Frame.
  ENABLE b-exit bt-del bt-sort b-help BROWSE-1 ed-parameters ed-comment
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  run local-open-query in this-procedure .
END PROCEDURE.
PROCEDURE fill-column-handles :
    define variable v-column-handle as handle   no-undo .
    define variable v-counter       as integer  no-undo.
do
on error undo, return error
:
        assign
            v-counter                               = 1
            v-fbrhist-column-handles [ v-counter ]  = BROWSE-1 :first-column in frame Dialog-Frame
        .
        do while
        valid-handle( v-fbrhist-column-handles [ v-counter ] :next-column )
        and v-counter < extent( v-fbrhist-column-handles )
        :
            assign
                v-fbrhist-column-handles [ v-counter + 1 ] = v-fbrhist-column-handles [ v-counter ] :next-column
            .
            assign
                v-counter = v-counter + 1
            .
        end.
        assign
            v-fbrhist-columns-amount = v-counter
        .
end.
END PROCEDURE.
PROCEDURE get-param :
    define variable v-num-entries    as integer      no-undo.
    define buffer buf_usr-flt       for ubflt.usr-flt.
do
for buf_usr-flt
on error undo, return error
:
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name  = g#userid
           and buf_usr-flt.call-point = 'история_производства'
    no-error.
    if available buf_usr-flt
    then do:
        assign
            v-num-entries = num-entries( buf_usr-flt.List_ )
        .
        if v-num-entries >= 1
        then do:
            assign
                v-fbrhist-sort-type = integer( entry( 1, buf_usr-flt.List_ ) )
            no-error.
            if error-status :error
            then do:
                assign
                    v-fbrhist-sort-type = 1
                .
            end.
            if v-num-entries >= 2
            then do:
                assign
                    v-fbrhist-doc-code = entry( 2, buf_usr-flt.List_ )
                no-error.
                if error-status :error
                then do:
                    assign
                        v-fbrhist-doc-code = "":U
                    .
                end.
                if v-num-entries >= 3
                then do:
                    assign
                        v-fbrhist-date-from = date( entry( 3, buf_usr-flt.List_ ) )
                    no-error.
                    if error-status :error
                    then do:
                        assign
                            v-fbrhist-date-from = ?
                        .
                    end.
                    if v-num-entries >= 4
                    then do:
                        assign
                            v-fbrhist-date-to = date( entry( 4, buf_usr-flt.List_ ) )
                        no-error.
                        if error-status :error
                        then do:
                            assign
                                v-fbrhist-date-to = ?
                            .
                        end.
                        if v-num-entries >= 5
                        then do:
                            assign
                                v-fbrhist-level = integer( entry( 5, buf_usr-flt.List_ ) )
                            no-error.
                            if error-status :error
                            then do:
                                assign
                                    v-fbrhist-level = 1
                                .
                            end.
                            if v-num-entries >= 6
                            then do:
                                assign
                                    v-fbrhist-userid    = entry( 6, buf_usr-flt.List_ )
                                no-error.
                                if error-status :error
                                then do:
                                    assign
                                        v-fbrhist-userid    = "":U
                                    .
                                end.
                                if v-num-entries >= 7
                                then do:
                                    assign
                                        v-fbrhist-cur-recid = integer( entry( 7, buf_usr-flt.List_ ) )
                                    no-error.
                                    if error-status :error
                                    then do:
                                        assign
                                            v-fbrhist-cur-recid = 0
                                        .
                                    end.
                                    if v-num-entries >= 8
                                    then do:
                                        assign
                                            v-fbrhist-focused-row = integer( entry( 8, buf_usr-flt.List_ ) )
                                        no-error.
                                        if error-status :error
                                        then do:
                                            assign
                                                v-fbrhist-focused-row = 0
                                            .
                                        end.
                                    end.
                                end.
                             end.
                        end.
                    end.
                end.
            end.
        end.
    end.
end.
END PROCEDURE.
PROCEDURE local-open-query :
    define variable v-date-from         as date         no-undo.
    define variable v-date-to           as date         no-undo.
    define variable v-hst-level-from    as integer      no-undo.
    define variable v-hst-level-to      as integer      no-undo.
    define variable v-doc-code-from     as character    no-undo.
    define variable v-doc-code-to       as character    no-undo.
    define variable v-userid-from       as character    no-undo.
    define variable v-userid-to         as character    no-undo.
do
on error undo, return error
:
    assign
        v-date-from        = 01/01/0001
        v-date-to          = 12/31/9999
        v-hst-level-from   = -32000
        v-hst-level-to     = 32000
        v-doc-code-from    = '':U
        v-doc-code-to      = 'z':U
        v-userid-from      = '':U
        v-userid-to        = 'z':U
    .
    case v-fbrhist-sort-type
    :
        when 1
        then do:
            if v-fbrhist-level <> 0
            then do:
                assign
                    v-hst-level-to = v-fbrhist-level
                .
            end.
        end.
        when 2
        then do:
            if v-fbrhist-doc-code <> ""
            then do:
                assign
                    v-doc-code-from = v-fbrhist-doc-code
                    v-doc-code-to   = v-fbrhist-doc-code
                .
            end.
        end.
        when 3
        then do:
            if v-fbrhist-date-from <> ?
            then do:
                assign
                    v-date-from = v-fbrhist-date-from
                .
            end.
            if v-fbrhist-date-to <> ?
            then do:
                assign
                    v-date-to = v-fbrhist-date-to
                .
            end.
            if v-fbrhist-level <> 0
            then do:
                assign
                    v-hst-level-to = v-fbrhist-level
                .
            end.
        end.
        when 4
        then do:
            if v-fbrhist-userid <> ?
            then do:
                assign
                    v-userid-from = v-fbrhist-userid
                    v-userid-to   = v-fbrhist-userid
                .
            end.
        end.
    end case.
    if v-fbrhist-sort-type = 2
    then do:
    end.
    else do:
        open query BROWSE-1
            for each fbr-history no-lock
               where fbr-history.sys-date  >= v-date-from
                 and fbr-history.sys-date  <= v-date-to
                 and fbr-history.hst-level >= v-hst-level-from
                 and fbr-history.hst-level <= v-hst-level-to
                 and fbr-history.doc-code  >= v-doc-code-from
                 and fbr-history.doc-code  <= v-doc-code-to
                 and fbr-history.user-name >= v-userid-from
                 and fbr-history.user-name <= v-userid-to
            by fbr-history.sys-date descending
            by fbr-history.sys-time-int descending
        indexed-reposition .
    end.
end.
END PROCEDURE.
PROCEDURE refresh-editors :
do
on error undo, return error
:
    assign
        ed-comment      = fbr-history.PS
        ed-parameters   = substitute( "Вызов: &1. Параметры: &2"
                                        , fbr-history.procedure-name
                                        , fbr-history.procedure-parameters
                                      )
    .
    display
        ed-comment
        ed-parameters
    with frame Dialog-Frame .
end.
END PROCEDURE.
PROCEDURE set-param :
define input parameter p-fbrhist-sort-type    as integer      no-undo.
define input parameter p-fbrhist-doc-code     as character    no-undo.
define input parameter p-fbrhist-date-from    as date         no-undo.
define input parameter p-fbrhist-date-to      as date         no-undo.
define input parameter p-fbrhist-level        as integer      no-undo.
define input parameter p-fbrhist-userid       as character    no-undo.
define input parameter p-fbrhist-cur-recid    as integer      no-undo.
define input parameter p-fbrhist-focused-row  as integer      no-undo.
    define buffer buf_usr-flt       for ubflt.usr-flt.
do
for buf_usr-flt
on error undo, return error
:
    find first buf_usr-flt exclusive-lock
         where buf_usr-flt.user-name  = g#userid
           and buf_usr-flt.call-point = 'история_производства'
    no-error.
    if not available buf_usr-flt
    then do:
        create buf_usr-flt.
        assign
            buf_usr-flt.user-name  = g#userid
            buf_usr-flt.call-point = 'история_производства'
        .
    end.
    assign
        buf_usr-flt.List_ =   string( p-fbrhist-sort-type   )
                    + ",":U + string( p-fbrhist-doc-code    )
                    + ",":U + string( p-fbrhist-date-from, "99/99/9999" )
                    + ",":U + string( p-fbrhist-date-to, "99/99/9999"   )
                    + ",":U + string( p-fbrhist-level       )
                    + ",":U + string( p-fbrhist-userid      )
                    + ",":U + string( p-fbrhist-cur-recid   )
                    + ",":U + string( p-fbrhist-focused-row )
    .
end.
END PROCEDURE.
