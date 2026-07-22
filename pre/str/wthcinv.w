DEFINE BUFFER buf_c-wth-line FOR ub.c-wth-line.
DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_obj FOR ub.clients.
DEFINE BUFFER buf_person1 FOR ub.clients.
DEFINE BUFFER buf_person2 FOR ub.clients.
DEFINE BUFFER buf_person3 FOR ub.clients.
DEFINE BUFFER buf_person4 FOR ub.clients.
DEFINE BUFFER buf_person5 FOR ub.clients.
DEFINE BUFFER buf_wth FOR ub.wealth.
DEFINE BUFFER buf_wth-place FOR ub.wth-place.
DEFINE TEMP-TABLE tt-c-wth-doc NO-UNDO LIKE ub.c-wth-doc.
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-mode AS CHARACTER NO-UNDO.
define input parameter parhost-code like ub.sysconf.host-code no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define input parameter parcli-type like ub.clients.obj-type no-undo.
define input parameter parcli-code like ub.clients.obj-code no-undo.
define input parameter parauto-fill like ub.c-wth-doc.auto-fill no-undo .
define input-output parameter p-doc-rec     as recid no-undo .
define input parameter p-call-prog as handle no-undo .
define input-output parameter p-next-prev as character no-undo .
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "перемещение МЦ: добавление, изменение, просмотр инвентаризации":U.
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
function usrfulnf returns character ( input p-user-id as character):
define variable v-user-name as character no-undo .
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  p-user-id
  ,output v-user-name
  ) no-error .
if error-status:error
or v-user-name = ""
then do:
  return p-user-id.
end.
else do:
  return v-user-name.
end.
end function.
define buffer bf_c-wth-doc for ub.c-wth-doc.
DEFINE VARIABLE f-date     AS DATE NO-UNDO.
DEFINE VARIABLE f-time     AS INT  NO-UNDO.
DEFINE VARIABLE s-date     AS DATE NO-UNDO.
DEFINE VARIABLE s-num      AS INT  NO-UNDO.
DEFINE VARIABLE v_rid      AS CHAR NO-UNDO.
DEFINE VARIABLE l-shift-on AS LOG  NO-UNDO.
DEFINE VARIABLE lock-doc as logical no-undo.
DEFINE VARIABLE var-peresort as logical no-undo.
define buffer auto-wth-doc-lock_batchprocess for ub.batchprocess .
DEFINE BUTTON B-chk
     LABEL "Че&ки"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-next AUTO-GO
     LABEL "&>>"
     SIZE 4 BY 1.
DEFINE BUTTON B-prev AUTO-GO
     LABEL "&<<"
     SIZE 4 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE for-object AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE VARIABLE for-person1 AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE VARIABLE for-person2 AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE VARIABLE for-person3 AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE VARIABLE for-person4 AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE VARIABLE for-person5 AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE QUERY BR-lines FOR
      buf_c-wth-line,
      buf_wth,
      buf_wth-place SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      tt-c-wth-doc SCROLLING.
DEFINE BROWSE BR-lines
  QUERY BR-lines NO-LOCK DISPLAY
      buf_c-wth-line.wth-code FORMAT ">>>>>>>>9":U
buf_wth.wth-name FORMAT "X(20)":U
buf_wth-place.w-p-name FORMAT "X(20)":U
buf_c-wth-line.bef-sum COLUMN-LABEL "Сумма план" FORMAT "->,>>>,>>>,>>9.99":U
buf_c-wth-line.aft-sum COLUMN-LABEL "Сумма факт" FORMAT "->,>>>,>>>,>>9.99":U
buf_c-wth-line.fact-sum COLUMN-LABEL "Расхождение" FORMAT "->,>>>,>>>,>>9.99":U
ENABLE
buf_c-wth-line.fact-sum
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.1 BY 7.8.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-prev AT ROW 1 COL 40
     B-next AT ROW 1 COL 44
     B-Help AT ROW 1 COL 95
     tt-c-wth-doc.obj-type AT ROW 3.33 COL 11 COLON-ALIGNED
          LABEL "Объект"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 6.1 BY 1
     BR-lines AT ROW 5.93 COL 1.1
     B-lookup AT ROW 13.83 COL 11
     B-chk AT ROW 13.83 COL 41
     tt-c-wth-doc.corr-date AT ROW 1 COL 82 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 10 BY .67
          FGCOLOR 12
     tt-c-wth-doc.corr-user-name AT ROW 1.03 COL 65 COLON-ALIGNED
          LABEL "Корр."
           VIEW-AS TEXT
          SIZE 12 BY .67
          FGCOLOR 12
     tt-c-wth-doc.doc-code AT ROW 2.13 COL 7.3 COLON-ALIGNED
          LABEL "Номер"
           VIEW-AS TEXT
          SIZE 16.1 BY .67
          FGCOLOR 4
     tt-c-wth-doc.doc-date AT ROW 2.13 COL 29.8 COLON-ALIGNED
          LABEL "Дата"
           VIEW-AS TEXT
          SIZE 10 BY .67
     tt-c-wth-doc.fact-date AT ROW 2.13 COL 47.6 COLON-ALIGNED
          LABEL "Факт"
           VIEW-AS TEXT
          SIZE 10 BY .67
          FGCOLOR 4
     tt-c-wth-doc.shift-date AT ROW 2.13 COL 67 COLON-ALIGNED
          LABEL "Смена"
           VIEW-AS TEXT
          SIZE 10 BY .67
          FGCOLOR 4
     tt-c-wth-doc.shift-name AT ROW 2.13 COL 82 COLON-ALIGNED
          LABEL "№"
           VIEW-AS TEXT
          SIZE 4 BY .67
          FGCOLOR 4
     tt-c-wth-doc.shift-num AT ROW 2.13 COL 92 COLON-ALIGNED
          LABEL "П."
           VIEW-AS TEXT
          SIZE 4 BY .67
          FGCOLOR 4
     tt-c-wth-doc.obj-code AT ROW 3.33 COL 18.3 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 6.5 BY .67
     for-object AT ROW 3.33 COL 29.8 COLON-ALIGNED NO-LABEL
     tt-c-wth-doc.bef-sum AT ROW 4.7 COL 11.6 COLON-ALIGNED
          LABEL "Сумма план"
           VIEW-AS TEXT
          SIZE 16 BY .67
     tt-c-wth-doc.aft-sum AT ROW 4.7 COL 42.9 COLON-ALIGNED
          LABEL "Сумма факт"
           VIEW-AS TEXT
          SIZE 16 BY .67
     tt-c-wth-doc.fact-sum AT ROW 4.77 COL 74.5 COLON-ALIGNED
          LABEL "Расхождение"
           VIEW-AS TEXT
          SIZE 16 BY .67
     tt-c-wth-doc.operator AT ROW 16 COL 1.8 NO-LABEL
           VIEW-AS TEXT
          SIZE 12.3 BY .67
     for-person1 AT ROW 16 COL 17.1 COLON-ALIGNED NO-LABEL
     tt-c-wth-doc.deliver AT ROW 17.2 COL 1.8 NO-LABEL
           VIEW-AS TEXT
          SIZE 12.3 BY .67
     for-person2 AT ROW 17.2 COL 17.1 COLON-ALIGNED NO-LABEL
     tt-c-wth-doc.receiver AT ROW 18.43 COL 1.8 NO-LABEL
           VIEW-AS TEXT
          SIZE 12.3 BY .67
     for-person3 AT ROW 18.43 COL 17.1 COLON-ALIGNED NO-LABEL
     tt-c-wth-doc.inv-prs4 AT ROW 19.57 COL 1.8 NO-LABEL
           VIEW-AS TEXT
          SIZE 12.3 BY .67
     for-person4 AT ROW 19.57 COL 17.1 COLON-ALIGNED NO-LABEL
     tt-c-wth-doc.inv-prs5 AT ROW 20.8 COL 1.8 NO-LABEL
           VIEW-AS TEXT
          SIZE 12.3 BY .67
     for-person5 AT ROW 20.8 COL 17.1 COLON-ALIGNED NO-LABEL
     "ЧЛЕНЫ ИНВЕНТАРИЗАЦИОННОЙ КОМИССИИ" VIEW-AS TEXT
          SIZE 34.1 BY 1 AT ROW 14.97 COL 19.4
          BGCOLOR 3 FGCOLOR 15
     SPACE(45.76) SKIP(5.90)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Инвентаризационная ведомость движения материальных ценностей: история"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-chk IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE loc-ref-list as character no-undo.
  run str/chk-docs.w (
                 input parparentproc
                ,input '':U
                ,input 'out-code':U
                ,input ?
                ,input parobj-type
                ,input parobj-code
                ,input tt-c-wth-doc.doc-code
                ,input ''
                ,input 0
                ,input ?
                ,input ?
                ,input 0
                ,output loc-ref-list) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame
DO:
define variable v-doc-rec as recid no-undo .
define variable v-line-rec as recid no-undo .
 if not avail buf_c-wth-line then return no-apply.
  ASSIGN
  v-line-rec = RECID( buf_c-wth-line )
  v-doc-rec = recid(bf_c-wth-doc)
  .
  run str/wthcinva.w (input parparentproc,
                  INPUT 'ПРОСМОТР':U,
                  input v-doc-rec,
                  input-output v-LINE-REC
                  ) no-error.
  apply "entry" to br-lines.
END.
ON CHOOSE OF B-next IN FRAME Dialog-Frame
DO:
      run reposition-c-wth-doc in this-procedure  (input 'next':U) no-error .
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-prev IN FRAME Dialog-Frame
DO:
      run reposition-c-wth-doc in this-procedure (input 'prev':U ) no-error .
  if error-status:error then return no-apply.
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
    p-next-prev = "QUIT".
END.
ON LEAVE OF tt-c-wth-doc.deliver IN FRAME Dialog-Frame
DO:
    FIND FIRST buf_person2 NO-LOCK WHERE
            buf_person2.obj-type = 'чел':U AND
            buf_person2.obj-code = INPUT FRAME Dialog-Frame tt-c-wth-doc.deliver NO-ERROR.
  IF AVAIL buf_person2 THEN DO:
    DISPLAY
    buf_person2.obj-name @ for-person2
    WITH FRAME Dialog-Frame.
  END.
END.
ON LEAVE OF tt-c-wth-doc.inv-prs4 IN FRAME Dialog-Frame
DO:
     FIND FIRST buf_person4 NO-LOCK WHERE
            buf_person4.obj-type = 'чел':U AND
            buf_person4.obj-code = INPUT FRAME Dialog-Frame tt-c-wth-doc.inv-prs4 NO-ERROR.
  IF AVAIL buf_person4 THEN DO:
    DISPLAY
    buf_person4.obj-name @ for-person4
    WITH FRAME Dialog-Frame.
  END.
END.
ON LEAVE OF tt-c-wth-doc.inv-prs5 IN FRAME Dialog-Frame
DO:
   FIND FIRST buf_person5 NO-LOCK WHERE
            buf_person5.obj-type = 'чел':U AND
            buf_person5.obj-code = INPUT FRAME Dialog-Frame tt-c-wth-doc.inv-prs5 NO-ERROR.
  IF AVAIL buf_person5 THEN DO:
    DISPLAY
    buf_person5.obj-name @ for-person5
    WITH FRAME Dialog-Frame.
  END.
END.
ON LEAVE OF tt-c-wth-doc.operator IN FRAME Dialog-Frame
DO:
    FIND FIRST buf_person1 NO-LOCK WHERE
            buf_person1.obj-type = 'чел':U AND
            buf_person1.obj-code = INPUT FRAME Dialog-Frame tt-c-wth-doc.operator NO-ERROR.
  IF AVAIL buf_person1 THEN DO:
    DISPLAY
    buf_person1.obj-name @ for-person1
    WITH FRAME Dialog-Frame.
  END.
END.
ON LEAVE OF tt-c-wth-doc.receiver IN FRAME Dialog-Frame
DO:
   FIND FIRST buf_person3 NO-LOCK WHERE
            buf_person3.obj-type = 'чел':U AND
            buf_person3.obj-code = INPUT FRAME Dialog-Frame tt-c-wth-doc.receiver NO-ERROR.
  IF AVAIL buf_person3 THEN DO:
    DISPLAY
    buf_person3.obj-name @ for-person3
    WITH FRAME Dialog-Frame.
  END.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-lines :handle
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
p-next-prev = '':U.
n-p: do while p-next-prev = '':U:
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    if par-mode <> 'ПРОСМОТР':U then do:
        message vss-workfile vss-revision vss-description skip
                    "Неверный параметр вызова par-mode"
        view-as alert-box ERROR.
        return error.
    end.
    if not par-mode = 'ПРОСМОТР':U then
    p-next-prev = "QUIT".
    find first ub.sysconf No-LOCK WHERE
                     ub.sysconf.host-code = parhost-code No-ERROR.
    if not avail ub.sysconf then do:
        message vss-workfile vss-revision vss-description skip
                        "Неверный параметр вызова parhost-code"
            view-as alert-box ERROR.
            return error.
    end.
    find first ub.clients No-LOCK WHERE
                ub.clients.obj-type = parobj-type AND
                ub.clients.obj-code = parobj-code No-ERROR.
    if not avail ub.clients then do:
      message vss-workfile vss-revision vss-description skip
              "Неверный параметр вызова parobj-type/parobj-code"
      view-as alert-box ERROR.
      return error.
    end.
    if parcli-type <> '':U or parcli-code <> 0 then do:
      find first ub.clients No-LOCK WHERE
                  ub.clients.obj-type = parcli-type AND
                  ub.clients.obj-code = parcli-code No-ERROR.
      if not avail ub.clients then do:
        message vss-workfile vss-revision vss-description skip
                "Неверный параметр вызова parcli-type/parcli-code"
        view-as alert-box ERROR.
        return error.
      end.
    end.
    tt-c-wth-doc.obj-type:list-items = 'орг':U + chr(44) +
                                    'чел':U + chr(44) +
                                    'маг':U + chr(44) +
                                    'скл':U + chr(44).
  Run fill-tables no-error.
  if error-status:error then return error.
  RUN Myenable.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-lines as INT EXTENT 18 no-undo.
DEF VAR varmvibr-lines       as INT no-undo.
DEF VAR varmvjbr-lines       as INT no-undo.
DEF VAR varmvkbr-lines       as INT no-undo.
DEF VAR varmvlbr-lines       as INT no-undo.
DEF VAR move-elementbr-lines as INT no-undo.
def var jjbr-lines           as int no-undo.
do varmvibr-lines = 1 to EXTENT(cur-clmn-numbr-lines):
  ASSIGN cur-clmn-numbr-lines[varmvibr-lines] = varmvibr-lines.
END.
RUN start-mv-clmnbr-lines.
PROCEDURE start-mv-clmnbr-lines:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  var-peresort = no  THEN DO:
   DO jjbr-lines = NUM-ENTRIES('1,2,3,4,5,6') TO 1 BY -1:
     RUN re-move-clmnbr-lines ( cur-clmn-numbr-lines[INTEGER(ENTRY (jjbr-lines, '1,2,3,4,5,6'))] , 1).
   END.
       END.
       IF  var-peresort = yes  THEN DO:
   DO jjbr-lines = NUM-ENTRIES('1,2,3,6,4,5') TO 1 BY -1:
     RUN re-move-clmnbr-lines ( cur-clmn-numbr-lines[INTEGER(ENTRY (jjbr-lines, '1,2,3,6,4,5'))] , 1).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-lines do:
  RUN re-move-clmnbr-lines ( 1, 18).
END.
ON ctrl-cursor-left OF BROWSE br-lines do:
  RUN re-move-clmnbr-lines (18, 1).
END.
PROCEDURE re-move-clmnbr-lines:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-lines = 1 TO EXTENT(cur-clmn-numbr-lines):
    if cur-clmn-numbr-lines[varmvibr-lines] = source-column THEN cur-clmn-numbr-lines[varmvibr-lines] = -1.
  END.
  if br-lines:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjbr-lines = source-column - 1 to target-column BY -1:
    DO varmvibr-lines = 1 TO EXTENT(cur-clmn-numbr-lines):
        if cur-clmn-numbr-lines[varmvibr-lines] = varmvjbr-lines THEN DO:
          cur-clmn-numbr-lines[varmvibr-lines] = cur-clmn-numbr-lines[varmvibr-lines] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-lines = source-column + 1 to target-column:
    DO varmvibr-lines = 1 TO EXTENT(cur-clmn-numbr-lines):
      if cur-clmn-numbr-lines[varmvibr-lines] = varmvjbr-lines THEN DO:
        cur-clmn-numbr-lines[varmvibr-lines] = cur-clmn-numbr-lines[varmvibr-lines] - 1.
      END.
    END.
  END.
  DO varmvibr-lines = 1 TO EXTENT(cur-clmn-numbr-lines):
    if cur-clmn-numbr-lines[varmvibr-lines] = -1 THEN cur-clmn-numbr-lines[varmvibr-lines] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-lines:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvibr-lines = 1 TO EXTENT(cur-clmn-numbr-lines):
    if cur-clmn-numbr-lines[varmvibr-lines] = cur-clmn-loc THEN move-elementbr-lines = varmvibr-lines.
  END.
  RUN re-move-clmnbr-lines (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-lines:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-lines = 1 to EXTENT(cur-clmn-numbr-lines):
    RUN re-move-clmnbr-lines (cur-clmn-numbr-lines[varmvlbr-lines], varmvlbr-lines).
  END.
  RUN start-mv-clmnbr-lines.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
end.
RUN disable_UI.
PROCEDURE control-peresort :
DEFINE OUTPUT parameter par-peresort as logical no-undo.
if tt-c-wth-doc.auto-fill = yes and
can-find(first ub.chk-doc No-LOCK WHERE
                   ub.chk-doc.obj-type = tt-c-wth-doc.obj-type AND
                    ub.chk-doc.obj-code = tt-c-wth-doc.obj-code AND
                    ub.chk-doc.out-code = tt-c-wth-doc.doc-code AND
                    ub.chk-doc.chk-type = integer('4':U)) then do:
                    par-peresort = yes.
end.
else par-peresort = no.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-c-wth-doc SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY for-object for-person1 for-person2 for-person3 for-person4 for-person5
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-c-wth-doc THEN
    DISPLAY tt-c-wth-doc.obj-type tt-c-wth-doc.corr-date
          tt-c-wth-doc.corr-user-name tt-c-wth-doc.doc-code
          tt-c-wth-doc.doc-date tt-c-wth-doc.fact-date tt-c-wth-doc.shift-date
          tt-c-wth-doc.shift-name tt-c-wth-doc.shift-num tt-c-wth-doc.obj-code
          tt-c-wth-doc.bef-sum tt-c-wth-doc.aft-sum tt-c-wth-doc.fact-sum
          tt-c-wth-doc.operator tt-c-wth-doc.deliver tt-c-wth-doc.receiver
          tt-c-wth-doc.inv-prs4 tt-c-wth-doc.inv-prs5
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-prev B-next B-Help BR-lines B-lookup B-chk
         tt-c-wth-doc.corr-date tt-c-wth-doc.corr-user-name
         tt-c-wth-doc.doc-date tt-c-wth-doc.fact-date tt-c-wth-doc.shift-date
         tt-c-wth-doc.shift-name tt-c-wth-doc.shift-num tt-c-wth-doc.obj-code
         for-object tt-c-wth-doc.bef-sum tt-c-wth-doc.aft-sum
         tt-c-wth-doc.fact-sum tt-c-wth-doc.operator for-person1
         tt-c-wth-doc.deliver for-person2 tt-c-wth-doc.receiver for-person3
         tt-c-wth-doc.inv-prs4 for-person4 tt-c-wth-doc.inv-prs5 for-person5
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-tables :
for each tt-c-wth-doc:
    delete tt-c-wth-doc.
end.
  if par-mode = 'ПРОСМОТР':U then do:
    FIND FIRST bf_c-wth-doc NO-LOCK WHERE
                recid(bf_c-wth-doc) = p-doc-rec.
  end.
  IF NOT AVAIL bf_c-wth-doc then
  return error.
  if bf_c-wth-doc.status_ = 'факт':U and par-mode <> 'ПРОСМОТР':U then do:
     message "Документ движения МЦ с N" bf_c-wth-doc.doc-code  "имеет статус" bf_c-wth-doc.status_ SKIP
             "Изменения не допускаются"
     view-as alert-box error.
     return error.
    end.
  create tt-c-wth-doc.
  buffer-copy bf_c-wth-doc to tt-c-wth-doc.
    FIND FIRST buf_obj No-LOCK WHERe
                buf_obj.obj-type = tt-c-wth-doc.obj-type AND
                buf_obj.obj-code = tt-c-wth-doc.obj-code No-ERROR.
    if not avail buf_obj then do:
      message "Документ движения МЦ N" bf_c-wth-doc.doc-code  skip
              "Неверный объект" bf_c-wth-doc.obj-type bf_c-wth-doc.obj-code
      view-as alert-box ERROR.
      return error.
    end.
    FIND FIRST buf_clients No-LOCK WHERe
                buf_clients.obj-type = tt-c-wth-doc.cli-type AND
                buf_clients.obj-code = tt-c-wth-doc.cli-code No-ERROR.
   if not avail buf_clients
      or NOT (buf_clients.obj-type = 'орг':U AND buf_clients.obj-code = parhost-code) then do:
      message "Документ движения МЦ N" bf_c-wth-doc.doc-code  skip
              "Неверный контрагент" bf_c-wth-doc.cli-type bf_c-wth-doc.cli-code
      view-as alert-box ERROR.
      return error.
   end.
    FIND FIRST buf_person1 No-LOCK WHERe
                        buf_person1.obj-type = 'чел':U AND
                        buf_person1.obj-code = tt-c-wth-doc.operator No-ERROR.
    FIND FIRST buf_person2 No-LOCK WHERe
                        buf_person2.obj-type = 'чел':U AND
                        buf_person2.obj-code = tt-c-wth-doc.deliver No-ERROR.
    FIND FIRST buf_person3 No-LOCK WHERe
                        buf_person3.obj-type = 'чел':U AND
                        buf_person3.obj-code = tt-c-wth-doc.receiver No-ERROR.
    FIND FIRST buf_person4 No-LOCK WHERe
                        buf_person4.obj-type = 'чел':U AND
                        buf_person4.obj-code = tt-c-wth-doc.inv-prs4 No-ERROR.
    FIND FIRST buf_person5 No-LOCK WHERe
                        buf_person5.obj-type = 'чел':U AND
                        buf_person5.obj-code = tt-c-wth-doc.inv-prs5 No-ERROR.
END PROCEDURE.
PROCEDURE lock-peresort :
DEFINE INPUT PARAMETER par-peresort as logical no-undo.
CASE par-peresort :
    when yes then do:
        HIDE
        tt-c-wth-doc.aft-sum in frame Dialog-Frame
        tt-c-wth-doc.bef-sum in frame Dialog-Frame.
        DISPLAY tt-c-wth-doc.fact-sum
        with frame Dialog-Frame.
    end.
    when no then do:
        DISPLAY
        tt-c-wth-doc.bef-sum
        tt-c-wth-doc.aft-sum when NOT tt-c-wth-doc.status_ = 'накл':U
        with frame Dialog-Frame.
        if tt-c-wth-doc.status_ = 'накл':U then
        HIDE
        tt-c-wth-doc.fact-sum
        in frame Dialog-Frame.
    end.
END CASE.
END PROCEDURE.
PROCEDURE MyEnable :
 buf_c-wth-line.fact-sum:READ-ONLY IN BROWSE BR-lines = YES.
  IF AVAILABLE buf_person1 THEN
    DISPLAY buf_person1.obj-name @ for-person1
      WITH FRAME Dialog-Frame .
  IF AVAILABLE buf_person2 THEN
    DISPLAY buf_person2.obj-name @ for-person2
      WITH FRAME Dialog-Frame .
  IF AVAILABLE buf_person3 THEN
    DISPLAY buf_person3.obj-name @ for-person3
      WITH FRAME Dialog-Frame .
  IF AVAILABLE buf_person4 THEN
    DISPLAY buf_person4.obj-name @ for-person4
      WITH FRAME Dialog-Frame .
  IF AVAILABLE buf_person5 THEN
    DISPLAY buf_person5.obj-name @ for-person5
      WITH FRAME Dialog-Frame .
  IF AVAILABLE buf_obj THEN
    DISPLAY buf_obj.obj-name @ for-object
      WITH FRAME Dialog-Frame .
  IF AVAILABLE tt-c-wth-doc THEN
    DISPLAY
    tt-c-wth-doc.fact-date
    tt-c-wth-doc.doc-code
    tt-c-wth-doc.doc-date
    tt-c-wth-doc.shift-name
    tt-c-wth-doc.shift-num
    tt-c-wth-doc.shift-date
    tt-c-wth-doc.obj-code
    tt-c-wth-doc.obj-type
    tt-c-wth-doc.bef-sum
    tt-c-wth-doc.aft-sum
    tt-c-wth-doc.fact-sum
    tt-c-wth-doc.operator
    tt-c-wth-doc.deliver
    tt-c-wth-doc.receiver
    tt-c-wth-doc.inv-prs4
    tt-c-wth-doc.inv-prs5
    usrfulnf(tt-c-wth-doc.corr-user-name) @ tt-c-wth-doc.corr-user-name
    tt-c-wth-doc.corr-date
    WITH FRAME Dialog-Frame .
    IF par-mode = 'ПРОСМОТР':U  THEN DO:
      assign
      b-quit:label = "&Выход"
      b-quit:col = 1
      .
      ENABLE
      B-Prev
      B-Next
      b-quit
      WITH FRAME Dialog-Frame.
      HIDE
      tt-c-wth-doc.fact-date IN FRAME Dialog-Frame
      .
    END.
    ENABLE
    b-help
    br-lines
    b-lookup
    WITH FRAME Dialog-Frame.
    Hide b-chk
    in frame Dialog-Frame.
    run control-peresort(output var-peresort) no-error.
    run lock-peresort(input var-peresort) no-error.
    OPEN QUERY BR-lines FOR EACH buf_c-wth-line WHERE buf_c-wth-line.doc-code = tt-c-wth-doc.doc-code     and buf_c-wth-line.corr-user-db-num = tt-c-wth-doc.corr-user-db-num     and buf_c-wth-line.chip-num = tt-c-wth-doc.chip-num  NO-LOCK,              EACH buf_wth WHERE buf_wth.wth-code = buf_c-wth-line.wth-code NO-LOCK,              EACH buf_wth-place WHERE buf_wth-place.obj-type = buf_c-wth-line.obj-type AND buf_wth-place.obj-code = buf_c-wth-line.obj-code AND buf_wth-place.w-p-code = buf_c-wth-line.w-p-code  NO-LOCK.
    REPOSITION br-lines TO ROW 1 NO-ERROR.
    APPLY "ENTRY":U TO br-lines IN FRAME Dialog-Frame.
    APPLY "VALUE-CHANGED":U TO br-lines IN FRAME Dialog-Frame.
    ASSIGN
    FRAME Dialog-Frame :TITLE = substitute("Удаленная инвентаризационная ведомость движения материальных ценностей № &1  - &2"
                                            , tt-c-wth-doc.doc-code
                                            , CAPS( par-mode )).
     .
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE reposition-c-wth-doc :
define input parameter p-direction as character no-undo .
define variable v-new-c-wth-doc-recid as recid no-undo .
do
on error undo, return error
:
  if valid-handle(p-call-prog)
  then do:
    run reposition-c-wth-doc in p-call-prog
      (input  p-direction
      ,output v-new-c-wth-doc-recid
      ).
    if v-new-c-wth-doc-recid <> ?
    then do:
      define buffer buf_c-wth-doc for ub.c-wth-doc .
      find first buf_c-wth-doc no-lock
        where recid(buf_c-wth-doc) = v-new-c-wth-doc-recid
        no-error .
      assign
      p-doc-rec = v-new-c-wth-doc-recid
      p-next-prev = '':U
      .
    end.
  end.
  else do:
    message "Список документов МЦ не определен." view-as alert-box INFORMATION .
    return no-apply.
  end.
  END.
END PROCEDURE.
