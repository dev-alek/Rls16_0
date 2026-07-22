DEFINE TEMP-TABLE alt-code NO-UNDO LIKE ub.bar-code
       field price-sale like ub.price-list.price-sale
       field d-pcnt like ub.price-list.d-pcnt
       field dtl-name as char
       field rid as recid
       field doc-num like ub.price-doc.doc-num
       .
define input     parameter parparentproc  as widget-handle no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter mode       as character             no-undo.
define input parameter g-code     like ub.goods.gds-code  no-undo.
define input parameter base-bc    like ub.bar-code.b-code no-undo.
define output parameter rec-list  as character             no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список неосновных кодов".
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
define buffer base-bar-code for ub.bar-code.
define variable mark as char  no-undo.
define variable rid  as recid no-undo.
define variable glog as logical no-undo .
FUNCTION stts-string RETURNS CHARACTER ( p-stts_ as integer):
define variable dops as character no-undo.
assign dops = entry (lookup (string(p-stts_), '99,1,2,3,4,9,51,79':U), 'Удаление,Создание,Изменение,Коррекция,Восстановление,Смена_кода,Смена_артик,Выключ.':U) no-error.
RETURN dops.
END FUNCTION.
FUNCTION get-cr-db-num RETURNS INTEGER
  ( input p-b-code AS INTEGER, INPUT p-cr-db-num AS INTEGER)  FORWARD.
FUNCTION get-mark RETURNS CHARACTER
  (local-rid as recid)  FORWARD.
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 15 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 7.5 BY 1.
DEFINE BUTTON b-prod
     LABEL "Д&оп. коды"
     SIZE 15 BY 1.
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 15 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 15 BY 1
     BGCOLOR 8 .
DEFINE QUERY br-cds FOR
      alt-code SCROLLING.
DEFINE BROWSE br-cds
  QUERY br-cds DISPLAY
      get-mark (alt-code.rid) @ mark format "x(1)"  column-label "*"
      alt-code.b-code                               column-label "Код"
      alt-code.cli-base-rate                        column-label "Коэф"
      alt-code.d-pcnt                               column-label "Скидка"
      alt-code.price-sale                           column-label "Цена"
      alt-code.unit-cli                             column-label "Изм"
      alt-code.dtl-name              format "x(34)" column-label "Привязка"
      alt-code.doc-num                              column-label "Переоценка"
      stts-string(alt-code.stts_) COLUMN-LABEL "Статус" FORMAT "X(10)"
      get-cr-db-num(alt-code.b-code, alt-code.cr-db-num) FORMAT ">>>>9" column-label "Создан (БД)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.88 BY 14.13.
DEFINE FRAME d-alt-cds
     b-quit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 16
     b-mark AT ROW 1 COL 31
     b-add AT ROW 1 COL 38.5
     b-prod AT ROW 1 COL 53.5
     b-help AT ROW 1 COL 95
     br-cds AT ROW 2.37 COL 1.1
     SPACE(0.50) SKIP(0.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список неосновных кодов:    "
         DEFAULT-BUTTON b-quit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME d-alt-cds:SCROLLABLE       = FALSE.
ON WINDOW-CLOSE OF FRAME d-alt-cds
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME d-alt-cds
DO:
define variable v-prt-rec as recid no-undo .
case mode:
  when "code-all"
  then do:
    run ref/bc-form.w
      (input  parparentproc
      ,input  'ДОБАВЛЕНИЕ':U
      ,input  base-bc
      ,input-output rid
      ).
  end.
  when "scl-gds-all"
  then do:
    define variable v-sel-node-code as integer   no-undo .
    run str/prt-ref.w
      (input  parparentproc
      ,input  ub.goods.gds-code
      ,input  'ПРОСМОТР':U
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  ""
      ,input  ""
      ,output v-sel-node-code
      ) .
  end.
  when "par-gds-all"
  then do:
    define variable v-chk-act-host-code as integer   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-chk-act-host-code
  )  .
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_cost':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    if NOT glog then
      return no-apply .
    run str/parts-l.w
      (INPUT parparentproc
      ,input p-obj-type
      ,input p-obj-code
      ,input goods.gds-code
      ,input ""
      ,input 'ПРОСМОТР':U
      ,input 'остатки':U
      ,input 'текущий':U
      ,input 'справочник':U
      ,output v-prt-rec
      ) .
  end.
  otherwise do:
    message
      "Для данного режима добавление не работает."
      view-as alert-box.
    return no-apply.
  end.
end case.
run UI-on.
END.
ON CHOOSE OF b-mark IN FRAME d-alt-cds
DO:
if not available alt-code then  return no-apply.
define variable v-num-entry3 as integer no-undo .
assign
  v-num-entry3 = lookup(string( alt-code.rid ), rec-list ).
if v-num-entry3 > 0 then do:
  assign
    entry(v-num-entry3, rec-list) = "":U
    rec-list = replace( rec-list, chr(44) + chr(44), chr(44)) .
  REC-LIST = TRIM(REC-LIST, chr(44)).
end.
else do:
  assign
  rec-list = rec-list + ( if rec-list = "":U then "":U else chr(44) ) + string( alt-code.rid) .
end.
br-cds :refresh ().
if last-event :function <> "mouse-select-dblclick" then
  br-cds :select-next-row ().
apply "entry" to br-cds in frame d-alt-cds.
END.
ON CHOOSE OF b-prod IN FRAME d-alt-cds
DO:
def var rid-list as char no-undo.
def var drc-list as char no-undo init ''.
def var rid-nums as int  no-undo.
if not available alt-code then
  return no-apply.
do rid-nums = 1 to num-entries(rec-list, chr(44) ) :
    if not entry( rid-nums, rec-list, chr(44) ) begins "dk" then
    drc-list = drc-list + ( if drc-list = "":U then "":U else chr(44) ) + entry( rid-nums, rec-list, chr(44) ) .
end.
rec-list = drc-list .
run ref/prod-cds.w (parparentproc, p-obj-type, p-obj-code,
                "code-all", goods.gds-code, alt-code.b-code, output rid-list).
if mode = "all-no-part-dk" then do:
    do rid-nums = 1 to num-entries(rid-list, chr(44) ) :
        rec-list = rec-list + ( if rec-list = "":U then "":U else chr(44) ) + "dk" + entry( rid-nums, rid-list, chr(44) ) .
    end.
end.
apply "entry" to br-cds in frame d-alt-cds.
END.
ON CHOOSE OF b-quit IN FRAME d-alt-cds
DO:
  rec-list = ''.
END.
ON CHOOSE OF b-sel IN FRAME d-alt-cds
DO:
if rec-list = "" and
   available alt-code then
  rec-list = string (alt-code.rid).
END.
ON MOUSE-SELECT-DBLCLICK OF br-cds IN FRAME d-alt-cds
DO:
apply "choose" to b-mark in frame d-alt-cds.
END.
ON RETURN OF br-cds IN FRAME d-alt-cds
DO:
apply "choose" to b-mark in frame d-alt-cds.
END.
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame d-alt-cds anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame d-alt-cds. END.
  return no-apply.
end.
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame d-alt-cds anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame d-alt-cds. END.
  return no-apply.
end.
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame d-alt-cds anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame d-alt-cds. END.
  return no-apply.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-alt-cds:PARENT eq ?
THEN FRAME d-alt-cds:PARENT = ACTIVE-WINDOW.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-alt-cds
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
on choose of b-help in frame d-alt-cds
do:
  apply "help":u to frame d-alt-cds .
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-alt-cds:width - 0.3
                fh            = frame d-alt-cds:first-child
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame d-alt-cds :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame d-alt-cds :height-chars)
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
    if frame d-alt-cds :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame d-alt-cds :height-chars)
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
            frame d-alt-cds :height = v-frame-height
          .
          if frame d-alt-cds :scrollable = true
          then do:
            assign
              frame d-alt-cds :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-alt-cds :scrollable = true
          then do:
            assign
              frame d-alt-cds :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame d-alt-cds :height = v-frame-height
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
      v-frame-height = frame d-alt-cds :height
      v-frame-virtual-height = frame d-alt-cds :virtual-height
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
      v-field-group-handle = frame d-alt-cds :first-child
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
    do with frame d-alt-cds
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame d-alt-cds :scrollable = true
      then do:
        assign
          frame d-alt-cds :virtual-height = frame d-alt-cds :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-alt-cds :height = frame d-alt-cds :height + p-change-value
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
        frame d-alt-cds :height = frame d-alt-cds :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame d-alt-cds :scrollable = true
      then do:
        assign
          frame d-alt-cds :virtual-height = frame d-alt-cds :virtual-height + p-change-value
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
          ,input  string(frame d-alt-cds :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame d-alt-cds :height)
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
    if frame d-alt-cds :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame d-alt-cds :width
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
    if frame d-alt-cds :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame d-alt-cds :width
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
            frame d-alt-cds :width = v-frame-width
          .
          if frame d-alt-cds :scrollable = true
          then do:
            assign
              frame d-alt-cds :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-alt-cds :scrollable = true
          then do:
            assign
              frame d-alt-cds :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame d-alt-cds :width = v-frame-width
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
      v-frame-width = frame d-alt-cds :width
      v-frame-virtual-width = frame d-alt-cds :virtual-width
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
      v-field-group-handle = frame d-alt-cds :first-child
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
    do with frame d-alt-cds
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame d-alt-cds :scrollable = true
      then do:
        assign
          frame d-alt-cds :virtual-width = frame d-alt-cds :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame d-alt-cds :width = v-frame-width + p-change-value
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
        frame d-alt-cds :width = frame d-alt-cds :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame d-alt-cds :scrollable = true
      then do:
        assign
          frame d-alt-cds :virtual-width = frame d-alt-cds :virtual-width + p-change-value
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
          ,input  string(frame d-alt-cds :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame d-alt-cds :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame d-alt-cds
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame d-alt-cds :height - v-diasize-resize-button :height
                  - 1
                  - (frame d-alt-cds :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame d-alt-cds :width - v-diasize-resize-button :width
                  - 1
                  - (frame d-alt-cds :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame d-alt-cds
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
      v-row-delta = v-new-row - frame d-alt-cds :height
      v-col-delta = v-new-col - frame d-alt-cds :width
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
            - frame d-alt-cds :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame d-alt-cds :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame d-alt-cds :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame d-alt-cds :height-chars
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
      v-diasize-current-frame-width  = frame d-alt-cds :width
      v-diasize-current-frame-height = frame d-alt-cds :height
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
    do with frame d-alt-cds
    :
      assign
        v-diasize-orig-frame-height = frame d-alt-cds :height
        v-diasize-orig-frame-width  = frame d-alt-cds :width
        v-diasize-browse-handle     = browse br-cds :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame d-alt-cds :first-child
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  find base-bar-code no-lock where
       base-bar-code.b-code = base-bc.
  find goods no-lock where
       goods.gds-code = g-code.
  RUN UI-on.
  WAIT-FOR GO OF FRAME d-alt-cds.
END.
RUN disable_UI.
PROCEDURE cre-alt :
def var pr-rec   as   recid                  no-undo.
def var pr-c-b-r like ub.bar-code.cli-base-rate no-undo.
find ub.gds-prt no-lock where
     ub.gds-prt.node-code = ub.bar-code.node-code.
if not ub.gds-prt.root and
   not ub.gds-prt.is-term then
  return.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  ub.bar-code.b-code
  ,input  0
  ,input  0
  ,output pr-rec
  ,output pr-c-b-r
  )  .
create alt-code.
buffer-copy ub.bar-code to alt-code
  assign
    alt-code.rid  = recid (bar-code)
    .
if ub.gds-prt.upper-code = ub.goods.prt-root then
  if ub.bar-code.in-code = "" then
    alt-code.dtl-name = "".
  else
    if ub.bar-code.part-code = "" then
      alt-code.dtl-name = ub.bar-code.in-code.
    else
      alt-code.dtl-name = ub.bar-code.in-code + " (" + ub.bar-code.part-code + ")".
else
  alt-code.dtl-name = ub.gds-prt.f-name.
find  ub.price-list no-lock where
      recid (ub.price-list) = pr-rec no-error.
if available ub.price-list and
   ub.price-list.b-code = ub.bar-code.b-code then
  assign
    alt-code.price-sale = ub.price-list.price-sale
    alt-code.d-pcnt     = ub.price-list.d-pcnt
    alt-code.doc-num    = ub.price-list.doc-num
    .
else
  if lookup (mode, "code-current,scl-gds-current,par-gds-current") > 0 then
    delete alt-code.
  else
    if available ub.price-list then
      assign
        alt-code.price-sale = ub.price-list.price-sale * ub.bar-code.cli-base-rate
        alt-code.d-pcnt     = 0
        alt-code.doc-num    = "-"
        .
    else
      assign
        alt-code.price-sale = ?
        alt-code.d-pcnt     = ?
        alt-code.doc-num    = ?
        .
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME d-alt-cds.
END PROCEDURE.
PROCEDURE UI-on :
ENABLE b-quit b-sel b-mark b-help b-prod br-cds WITH FRAME d-alt-cds.
for each alt-code:
  delete alt-code.
end.
case mode:
  when "all-no-part" or when "all-no-part-dk" then do:
    frame d-alt-cds :title = "Все имеющиеся основные и неосновные бар-коды:   " +
                                 "Основной код: " + string (base-bc, ">>>>>>>>9")
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = base-bar-code.gds-code:
      if ub.bar-code.in-code   = base-bar-code.in-code and
      ub.bar-code.part-code = base-bar-code.part-code then do:
        run cre-alt.
      end.
    end.
  end.
  when "code-current" then do:
    frame d-alt-cds :title = "Имеющиеся неосновные цены:   " +
                                 "Основной код: " + string (base-bc, ">>>>>>>>9")
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = base-bar-code.gds-code and
             ub.bar-code.node-code = base-bar-code.node-code and
             ub.bar-code.in-code   = base-bar-code.in-code and
             ub.bar-code.part-code = base-bar-code.part-code and
             ub.bar-code.unit-cli <> ub.goods.unit-base:
      run cre-alt.
    end.
  end.
  when "scl-gds-current" then do:
    frame d-alt-cds :title = "Имеющиеся неосновные цены по признакам:   " +
                                 "Товар: " + ub.goods.artic + "  " + ub.goods.gds-name
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = base-bar-code.gds-code and
             ub.bar-code.in-code   = "" and
             ub.bar-code.unit-cli <> ub.goods.unit-base:
      run cre-alt.
    end.
  end.
  when "par-gds-current" then do:
    frame d-alt-cds :title = "Имеющиеся неосновные цены по партиям:   " +
                                 "Товар: " + ub.goods.artic + "  " + ub.goods.gds-name
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = base-bar-code.gds-code and
             ub.bar-code.in-code  <> "" and
             ub.bar-code.unit-cli <> ub.goods.unit-base:
      run cre-alt.
    end.
  end.
  when "code-all" then do:
    frame d-alt-cds :title = "Все неосновные коды:   " +
                                 "Основной код: " + string (base-bc, ">>>>>>>>9")
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = base-bar-code.gds-code and
             ub.bar-code.node-code = base-bar-code.node-code and
             ub.bar-code.in-code   = base-bar-code.in-code and
             ub.bar-code.part-code = base-bar-code.part-code and
             ub.bar-code.unit-cli <> ub.goods.unit-base:
      run cre-alt.
    end.
    ENABLE b-add WITH FRAME d-alt-cds.
  end.
  when "scl-gds-all" then do:
    frame d-alt-cds :title = "Все неосновные коды по признакам:   " +
                                 "Товар: " + ub.goods.artic + "  " + ub.goods.gds-name
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = base-bar-code.gds-code and
             ub.bar-code.in-code   = "" and
             ub.bar-code.unit-cli <> ub.goods.unit-base:
      run cre-alt.
    end.
    ENABLE b-add WITH FRAME d-alt-cds.
  end.
  when "par-gds-all" then do:
    frame d-alt-cds :title = "Все неосновные коды по партиям:   " +
                                 "Товар: " + ub.goods.artic + "  " + ub.goods.gds-name
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = base-bar-code.gds-code and
             ub.bar-code.in-code  <> "" and
             ub.bar-code.unit-cli <> ub.goods.unit-base:
      run cre-alt.
    end.
    ENABLE b-add WITH FRAME d-alt-cds.
  end.
end case.
frame d-alt-cds :title = frame d-alt-cds :title +
                             "      Текущий объект: " + string (p-obj-type, "x(3)") +
                             " " + string (p-obj-code, ">>>>9").
open query br-cds
  for each alt-code no-lock.
END PROCEDURE.
FUNCTION get-cr-db-num RETURNS INTEGER
  ( input p-b-code AS INTEGER, INPUT p-cr-db-num AS INTEGER) :
  DEFINE BUFFER buf_code-range FOR ub.code-range.
  IF p-cr-db-num <> ? THEN
  RETURN p-cr-db-num.
  FIND FIRST buf_code-range NO-LOCK WHERE
            buf_code-range.first-code <= p-b-code
       AND  buf_code-range.last-code >= p-b-code NO-ERROR.
  IF AVAILABLE buf_code-range THEN RETURN buf_code-range.db-num.
  RETURN ?.
END FUNCTION.
FUNCTION get-mark RETURNS CHARACTER
  (local-rid as recid) :
if lookup (string (local-rid), rec-list) > 0 then
  return "*".
else
  return "".
END FUNCTION.
