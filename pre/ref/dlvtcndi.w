DEFINE BUFFER locked_condition-keeping FOR ub.condition-keeping.
DEFINE BUFFER locked_delivery-type FOR ub.delivery-type.
DEFINE BUFFER locked_deliv-type-cond-keep FOR ub.deliv-type-cond-keep.
DEFINE TEMP-TABLE tt-condition-keeping NO-UNDO LIKE ub.condition-keeping.
DEFINE TEMP-TABLE tt-delivery-type NO-UNDO LIKE ub.delivery-type.
DEFINE TEMP-TABLE tt-deliv-type-cond-keep NO-UNDO LIKE ub.deliv-type-cond-keep.
DEFINE BUFFER X_curr_clients FOR ub.clients.
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo.
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo.
define input parameter p-mode as character no-undo.
DEFINE INPUT PARAMETER p-deliv-type-code LIKE ub.deliv-type-cond-keep.deliv-type-code NO-UNDO.
DEFINE INPUT PARAMETER p-cond-keep-code LIKE ub.deliv-type-cond-keep.cond-keep-code NO-UNDO.
define input-output parameter p-doc-rec as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка редактирования ВОЗМОЖНОСТИ ДОСТАВКИ ПО УСЛОВИЯМ ХРАНЕНИЯ".
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
define variable v-tab-order as character no-undo.
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable v-last-code like ub.deliv-type-cond-keep.deliv-type-code no-undo.
DEFINE BUTTON b-cond-keep
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-deliv-type
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Hist
     LABEL "Ис&тория"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE F-cond-keep-name AS CHARACTER FORMAT "X(50)"
     LABEL "Название условий хранения"
     VIEW-AS FILL-IN
     SIZE 63 BY 1 NO-UNDO.
DEFINE VARIABLE F-deliv-type-name AS CHARACTER FORMAT "X(50)"
     LABEL "Название типа доставки"
     VIEW-AS FILL-IN
     SIZE 63 BY 1.
DEFINE QUERY Dialog-Frame FOR
      tt-deliv-type-cond-keep,
      tt-condition-keeping SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Hist AT ROW 1 COL 51
     B-Help AT ROW 1 COL 61
     tt-deliv-type-cond-keep.deliv-type-code AT ROW 3 COL 34 COLON-ALIGNED
          LABEL "Внутр.код типа доставки"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     B-deliv-type AT ROW 3 COL 47.5
     F-deliv-type-name AT ROW 4.25 COL 34 COLON-ALIGNED
     tt-deliv-type-cond-keep.cond-keep-code AT ROW 5.5 COL 34 COLON-ALIGNED
          LABEL "Вн.код условий хранения"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     b-cond-keep AT ROW 5.5 COL 47.5
     F-cond-keep-name AT ROW 6.75 COL 34 COLON-ALIGNED
     tt-deliv-type-cond-keep.des AT ROW 10 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 3.75
     "Описание" VIEW-AS TEXT
          SIZE 16 BY 1 AT ROW 8.75 COL 1.5
     SPACE(81.74) SKIP(4.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Возможности доставки по условиям хранения"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       F-cond-keep-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       F-deliv-type-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-cond-keep IN FRAME Dialog-Frame
DO:
   define variable v-rid-list as character no-undo.
   define variable v-sts as integer no-undo.
define variable vss-include-info0 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
if available locked_condition-keeping then
assign
v-rid-list = string(recid(locked_condition-keeping))
v-sts = locked_condition-keeping.sts
.
run ref/cndkeeps.w (input parParentProc
              , p-curr-obj-type
              , p-curr-obj-code
              , "b-sel":U
              , 'все':U
              , input-output v-sts
              , input-output v-rid-list ) no-error .
if v-rid-list <> "":U then do:
    FIND FIRST locked_condition-keeping WHERE
        recid( locked_condition-keeping ) = integer(entry(1, v-rid-list)) NO-LOCK .
    assign
    tt-deliv-type-cond-keep.cond-keep-code = locked_condition-keeping.cond-keep-code
    f-cond-keep-name = locked_condition-keeping.cond-keep-name
.
    display
    tt-deliv-type-cond-keep.cond-keep-code
    f-cond-keep-name
    with frame Dialog-Frame .
end.
END.
ON CHOOSE OF B-deliv-type IN FRAME Dialog-Frame
DO:
  define variable v-rid-list as character no-undo.
  define variable v-sts as integer no-undo .
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
if available locked_delivery-type then
assign
v-rid-list = string(recid(locked_delivery-type))
v-sts   = locked_delivery-type.sts
.
run ref/dlvtypes.w (input parParentProc
              , p-curr-obj-type
              , p-curr-obj-code
              , "b-sel":U
              , 'все':U
              , input-output v-sts
              , input-output v-rid-list ) no-error .
if v-rid-list <> "":U then do:
    FIND FIRST locked_delivery-type WHERE
        recid( locked_delivery-type ) = integer(entry(1, v-rid-list)) NO-LOCK .
    assign
    tt-deliv-type-cond-keep.deliv-type-code = locked_delivery-type.deliv-type-code
    f-deliv-type-name = locked_delivery-type.deliv-type-name
.
    display
    tt-deliv-type-cond-keep.deliv-type-code
    f-deliv-type-name
    with frame Dialog-Frame .
end.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
    run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-Hist IN FRAME Dialog-Frame
DO:
  define variable v-rid-list as character no-undo.
    run ref/dlvctcns.w
                (
                 input parParentProc
                ,INPUT p-curr-obj-type
                ,INPUT p-curr-obj-code
                ,input "":U
                ,input "one":U
                ,input locked_deliv-type-cond-keep.deliv-type-code
                ,input locked_deliv-type-cond-keep.cond-keep-code
                ,input-output v-rid-list
                              )
 .
END.
ON LEAVE OF tt-deliv-type-cond-keep.cond-keep-code IN FRAME Dialog-Frame
DO:
 assign
tt-deliv-type-cond-keep.cond-keep-code.
FIND FIRST locked_condition-keeping WHERE
         locked_condition-keeping.cond-keep-code  = tt-deliv-type-cond-keep.cond-keep-code
 NO-LOCK NO-error.
if not available locked_condition-keeping then do:
  assign
  tt-deliv-type-cond-keep.cond-keep-code = ?
  f-cond-keep-name = "":U
  .
    display
    tt-deliv-type-cond-keep.cond-keep-code
    f-cond-keep-name
    with frame Dialog-Frame.
    .
end.
else do:
    assign
    f-cond-keep-name = locked_condition-keeping.cond-keep-name
    .
    display
    tt-deliv-type-cond-keep.cond-keep-code
    f-cond-keep-name
    with frame Dialog-Frame.
    .
end.
END.
ON LEAVE OF tt-deliv-type-cond-keep.deliv-type-code IN FRAME Dialog-Frame
DO:
  assign
tt-deliv-type-cond-keep.deliv-type-code.
FIND FIRST locked_delivery-type WHERE
         locked_delivery-type.deliv-type-code  = tt-deliv-type-cond-keep.deliv-type-code
 NO-LOCK NO-error.
if not available locked_delivery-type then do:
  assign
  tt-deliv-type-cond-keep.deliv-type-code = ?
  f-deliv-type-name = "":U
  .
    display
    tt-deliv-type-cond-keep.deliv-type-code
    f-deliv-type-name
    with frame Dialog-Frame.
    .
end.
else do:
    assign
    f-deliv-type-name = locked_delivery-type.deliv-type-name
    .
    display
    tt-deliv-type-cond-keep.deliv-type-code
    f-deliv-type-name
    with frame Dialog-Frame.
    .
end.
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  if self:type = "TOGGLE-BOX" then
  self:BGCOLOR = ?.
  assign
  ii = lookup(self:name, v-tab-order).
  assign
  ii = ii + 1
  v-next-widget-name = entry(ii, v-tab-order)
  no-error .
  if error-status:error then do:
    assign
    ii = 1
    v-next-widget-name = entry( ii, v-tab-order)
    .
  end.
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
        APPLY "TAB" to hh.
        return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
end.
END.
ON BACK-TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  assign
  ii = lookup(self:name, v-tab-order).
  .
  assign
  ii = (if ii = 1
        then  num-entries(v-tab-order)
        else ii - 1
        )
  v-next-widget-name = entry(ii, v-tab-order)
  .
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
      APPLY "BACK-TAB" to hh.
      return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
  end.
END.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON RETURN ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
  if v-tab-order <> '' then do:
    assign
    ii = lookup(self:name, v-tab-order).
    if ii = num-entries(v-tab-order) then do:
        APPLY 'CHOOSE' TO b-exit in frame Dialog-Frame.
        return no-apply.
    end.
    if self:type <> "BUTTON" and
      self:type <> "EDITOR"  then do:
      run proc-move-forward in this-procedure .
      return no-apply.
    end.
    if self:type = "BUTTON" then do:
      APPLY "CHOOSE" to self.
    end.
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame Dialog-Frame:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
          APPLY "ENTRY" to hh.
          return no-apply.
        end.
        else do:
          APPLY "TAB" to hh.
          return no-apply.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
END.
procedure proc-move-forward :
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
do
on error undo, return error
:
  if v-tab-order <> '' then do:
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = lookup(self:name, v-tab-order).
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame Dialog-Frame:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
          APPLY "ENTRY" to hh.
          return.
        end.
        else do:
          assign
          ii = ii + 1
          v-next-widget-name = entry(ii, v-tab-order)
          no-error .
          if error-status:error then do:
            assign
            ii = 1
            v-next-widget-name = entry( ii, v-tab-order)
            .
          end.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
end.
end procedure.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 if p-mode  <> 'ДОБАВЛЕНИЕ':U
 and p-mode <> 'ИЗМЕНЕНИЕ':U
 and p-mode <> 'ПРОСМОТР':U
 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
 end.
   find first X_curr_clients no-lock where
            X_curr_clients.obj-type = p-curr-obj-type
       AND X_curr_clients.obj-code = p-curr-obj-code no-error.
  if not available X_curr_clients then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-curr-obj-type p-curr-obj-code"
    p-curr-obj-type p-curr-obj-code
    view-as alert-box ERROR.
    return error .
  end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
IF v-db-num <> 0
AND (p-mode = 'ДОБАВЛЕНИЕ':U
     OR p-mode = 'ИЗМЕНЕНИЕ':U ) THEN DO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-mode" p-mode skip
    "Нельзя редактировать запись ТИП ДОСТАВКИ ОТ СУБЪЕКТОВ в УБД"
    view-as alert-box ERROR.
    return error .
END.
  for each tt-delivery-type:
    delete tt-delivery-type.
  end.
  for each tt-condition-keeping:
    delete tt-condition-keeping.
  end.
  for each tt-deliv-type-cond-keep:
    delete tt-deliv-type-cond-keep.
  end.
IF p-deliv-type-code <> 0  OR p-mode <> 'ДОБАВЛЕНИЕ':U THEN DO:
    IF p-mode = 'ДОБАВЛЕНИЕ':U OR p-mode = 'ИЗМЕНЕНИЕ':U  THEN DO:
      FIND FIRST LOCKED_delivery-type EXCLUSIVE-LOCK WHERE
                LOCKED_delivery-type.deliv-type-code = p-deliv-type-code NO-ERROR.
    END.
    IF p-mode = 'ПРОСМОТР':U THEN DO:
        FIND FIRST LOCKED_delivery-type no-lock WHERE
                        LOCKED_delivery-type.deliv-type-code = p-deliv-type-code NO-ERROR.
   END.
   IF (p-mode = 'ДОБАВЛЕНИЕ':U
    OR p-mode = 'ИЗМЕНЕНИЕ':U )
    AND NOT AVAILABLE LOCKED_delivery-type  THEN DO:
        IF LOCKED(LOCKED_delivery-type) THEN DO:
            message
            vss-workfile vss-revision vss-description skip
             "Запись ТИП ДОСТАВКИ занята"
            view-as alert-box error .
            undo, return error.
        END.
   END.
    ELSE DO:
      IF NOT AVAILABLE LOCKED_delivery-type THEN DO:
            message
                vss-workfile vss-revision vss-description skip
                "Неверное значение параметра вызова p-deliv-type-code" p-deliv-type-code skip
                view-as alert-box ERROR.
                return error .
        END.
    END.
    CREATE tt-delivery-type.
    BUFFER-COPY LOCKED_delivery-type TO tt-delivery-type.
END.
IF p-cond-keep-code <> 0
OR p-mode <> 'ДОБАВЛЕНИЕ':U THEN DO:
    IF p-mode = 'ДОБАВЛЕНИЕ':U OR p-mode = 'ИЗМЕНЕНИЕ':U  THEN DO:
       FIND FIRST LOCKED_condition-keeping EXCLUSIVE-LOCK WHERE
                LOCKED_condition-keeping.cond-keep-code = p-cond-keep-code NO-ERROR.
    END.
    IF p-mode = 'ПРОСМОТР':U  THEN DO:
        FIND FIRST LOCKED_condition-keeping NO-LOCK WHERE
                LOCKED_condition-keeping.cond-keep-code = p-cond-keep-code NO-ERROR.
    END.
    IF (p-mode = 'ДОБАВЛЕНИЕ':U
    OR p-mode = 'ИЗМЕНЕНИЕ':U )
    AND NOT AVAILABLE LOCKED_condition-keeping  THEN DO:
        IF LOCKED(LOCKED_condition-keeping) THEN DO:
            message
            vss-workfile vss-revision vss-description skip
             "Запись УСЛОВИЯ ХРАНЕНИЯ занята"
            view-as alert-box error .
            undo, return error.
        END.
    END.
    ELSE DO:
        IF NOT AVAILABLE LOCKED_condition-keeping  THEN DO:
            message
            vss-workfile vss-revision vss-description skip
            "Неверное значение параметра вызова p-cond-keep-code" p-cond-keep-code skip
            view-as alert-box ERROR.
            return error .
        END.
    END.
    CREATE tt-condition-keeping.
    BUFFER-COPY LOCKED_condition-keeping TO tt-condition-keeping.
END.
if p-mode = 'ИЗМЕНЕНИЕ':U
  or p-mode = 'ПРОСМОТР':U then do:
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      find first locked_deliv-type-cond-keep EXclusive-lock where
                   recid(locked_deliv-type-cond-keep) = p-doc-rec no-wait no-error.
      if locked locked_deliv-type-cond-keep then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ВОЗМОЖНОСТЬ ДОСТАВКИ ПО УСЛОВИЯМ ХРАНЕНИЯ занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_deliv-type-cond-keep no-lock where
                       recid(locked_deliv-type-cond-keep) = p-doc-rec no-error .
      if not avail locked_deliv-type-cond-keep then do:
        find first locked_deliv-type-cond-keep no-lock where
                   locked_deliv-type-cond-keep.deliv-type-code = p-deliv-type-code no-error .
      end.
    end.
    if not available locked_deliv-type-cond-keep then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ВОЗМОЖНОСТЬ ДОСТАВКИ ПО УСЛОВИЯМ ХРАНЕНИЯ"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-deliv-type-cond-keep.
    buffer-copy locked_deliv-type-cond-keep to tt-deliv-type-cond-keep.
   end.
   else do:
     create tt-deliv-type-cond-keep.
     assign
     tt-deliv-type-cond-keep.deliv-type-code = (IF p-mode = 'ДОБАВЛЕНИЕ':U AND p-deliv-type-code <> 0
                                                 THEN p-deliv-type-code
                                                 ELSE tt-deliv-type-cond-keep.deliv-type-code)
     tt-deliv-type-cond-keep.cond-keep-code = (IF p-mode = 'ДОБАВЛЕНИЕ':U AND p-cond-keep-code <> 0
                                                 THEN p-cond-keep-code
                                                 ELSE tt-deliv-type-cond-keep.deliv-type-code)
         .
   end.
  RUN Myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-deliv-type-cond-keep SHARE-LOCK,       EACH tt-condition-keeping WHERE TRUE  SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY F-deliv-type-name F-cond-keep-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-deliv-type-cond-keep THEN
    DISPLAY tt-deliv-type-cond-keep.deliv-type-code
          tt-deliv-type-cond-keep.cond-keep-code tt-deliv-type-cond-keep.des
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Hist B-Help tt-deliv-type-cond-keep.deliv-type-code
         B-deliv-type tt-deliv-type-cond-keep.cond-keep-code b-cond-keep
         tt-deliv-type-cond-keep.des
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyENable :
case p-mode:
  when 'ДОБАВЛЕНИЕ':U then do:
    display
    (IF tt-deliv-type-cond-keep.deliv-type-code <> 0
     THEN tt-deliv-type-cond-keep.deliv-type-code
     ELSE ?) @ tt-deliv-type-cond-keep.deliv-type-code
    (IF tt-deliv-type-cond-keep.cond-keep-code <> 0
     THEN tt-deliv-type-cond-keep.cond-keep-code
     ELSE ?) @ tt-deliv-type-cond-keep.cond-keep-code
    (if available locked_delivery-type
    then  locked_delivery-type.deliv-type-name
    else "":U ) @ f-deliv-type-name
    (if available locked_condition-keeping
    then  locked_condition-keeping.cond-keep-name
    else "":U ) @ f-cond-keep-name
    WITH FRAME Dialog-Frame.
  end.
  otherwise do:
    IF AVAILABLE tt-deliv-type-cond-keep THEN
    DISPLAY
    tt-deliv-type-cond-keep.deliv-type-code
    tt-deliv-type-cond-keep.cond-keep-code
    locked_delivery-type.deliv-type-name @ f-deliv-type-name
    locked_condition-keeping.cond-keep-name @ f-cond-keep-name
    tt-deliv-type-cond-keep.des
    WITH FRAME Dialog-Frame.
  end.
END CASE.
if p-mode = 'ПРОСМОТР':U then do:
assign
b-quit:label = "&Выход"
.
hide
b-exit in frame Dialog-Frame.
end.
ENABLE
B-exit when p-mode <> 'ПРОСМОТР':U
b-quit
B-Hist when p-mode <> 'ДОБАВЛЕНИЕ':U
B-Help
tt-deliv-type-cond-keep.deliv-type-code when (p-mode = 'ДОБАВЛЕНИЕ':U and p-deliv-type-code = 0)
tt-deliv-type-cond-keep.cond-keep-code when (p-mode = 'ДОБАВЛЕНИЕ':U and p-cond-keep-code = 0)
tt-deliv-type-cond-keep.des when p-mode <> 'ПРОСМОТР':U
b-deliv-type when (p-mode = 'ДОБАВЛЕНИЕ':U and p-deliv-type-code = 0)
b-cond-keep when (p-mode = 'ДОБАВЛЕНИЕ':U and p-cond-keep-code = 0)
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE Proc-save :
if p-mode = 'ПРОСМОТР':U then do:
    return error.
end.
if not available tt-deliv-type-cond-keep then do:
    create tt-deliv-type-cond-keep.
end.
assign
frame Dialog-Frame
tt-deliv-type-cond-keep.deliv-type-code
tt-deliv-type-cond-keep.cond-keep-code
tt-deliv-type-cond-keep.des = tt-deliv-type-cond-keep.des:SCREEN-VALUE
.
 run ref/dlvtcnd1.p (
input-output p-doc-rec
,input p-mode
,input tt-deliv-type-cond-keep.deliv-type-code
,input tt-deliv-type-cond-keep.cond-keep-code
,input tt-deliv-type-cond-keep.des
)
no-error.
if error-status:error then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      undo ,
      return error.
    end.
    hh = hh:next-sibling.
  end.
end.
  undo, return error.
end.
END PROCEDURE.
