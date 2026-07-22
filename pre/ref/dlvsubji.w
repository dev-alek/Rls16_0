DEFINE BUFFER locked_delivery-subject FOR ub.delivery-subject.
DEFINE TEMP-TABLE tt-delivery-subject NO-UNDO LIKE ub.delivery-subject.
DEFINE BUFFER X_curr_clients FOR ub.clients.
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo.
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo.
define input parameter p-mode as character no-undo.
DEFINE INPUT PARAMETER p-deliv-subj-code LIKE ub.delivery-subject.deliv-subj-code NO-UNDO.
define input-output parameter p-doc-rec as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка редактирования СУБЪЕКТА ДОСТАВКИ".
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
define variable v-last-code like ub.delivery-subject.deliv-subj-code no-undo.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Hist
     LABEL "Ис&тория"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-region
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY 1.
DEFINE VARIABLE f-reg-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 61.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-delivery-subject SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     tt-delivery-subject.deliv-subj-code AT ROW 3 COL 34 COLON-ALIGNED
          LABEL "Внутр.код субъекта доставки"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-delivery-subject.deliv-subj-name AT ROW 4.27 COL 34 COLON-ALIGNED
          LABEL "Название субъекта доставки"
          VIEW-AS FILL-IN
          SIZE 63 BY 1
     tt-delivery-subject.reg-code AT ROW 6.33 COL 34 COLON-ALIGNED WIDGET-ID 4
          LABEL "Регион"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     b-region AT ROW 6.33 COL 40 WIDGET-ID 2
     f-reg-name AT ROW 7.4 COL 34 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     tt-delivery-subject.des AT ROW 10 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 3.77
     "Описание" VIEW-AS TEXT
          SIZE 16 BY 1 AT ROW 8.77 COL 1.5
     SPACE(81.74) SKIP(4.47)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Субъект доставки"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
    run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-Hist IN FRAME Dialog-Frame
DO:
  define variable v-rid-list as character no-undo.
    run ref/dlvcsubs.w
                (
                 input parParentProc
                ,INPUT p-curr-obj-type
                ,INPUT p-curr-obj-code
                ,input "":U
                ,input "one":U
                ,input locked_delivery-subject.deliv-subj-code
                ,input-output v-rid-list
                              )
 .
END.
ON CHOOSE OF b-region IN FRAME Dialog-Frame
DO:
  define buffer buf_regions for ub.regions.
  define variable v-reg-code like ub.regions.reg-code no-undo .
  run ref/regions.w ( input  parParentProc
                    , input  'выбор':U
                    , output v-reg-code
                    ).
  if v-reg-code <> ? then do :
    find first buf_regions no-lock
      where buf_regions.reg-code = v-reg-code
    no-error .
    if not available buf_regions then do:
      message
        "Неверный код региона " v-reg-code
      view-as alert-box error.
      return no-apply.
    end.
    else do:
      assign
        tt-delivery-subject.reg-code = buf_regions.reg-code
      .
      display
      tt-delivery-subject.reg-code
      buf_regions.reg-name @ f-reg-name
      with frame Dialog-Frame.
    end.
  end.
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
IF v-db-num <> 0
AND (p-mode = 'ДОБАВЛЕНИЕ':U
     OR p-mode = 'ИЗМЕНЕНИЕ':U ) THEN DO:
      message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-mode" p-mode skip
    "Нельзя редактировать запись СУБЪЕКТА ДОСТАВКИ в УБД"
    view-as alert-box ERROR.
    return error .
END.
  for each tt-delivery-subject:
    delete tt-delivery-subject.
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U
  or p-mode = 'ПРОСМОТР':U then do:
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      find first locked_delivery-subject EXclusive-lock where
                   recid(locked_delivery-subject) = p-doc-rec no-wait no-error.
      if locked locked_delivery-subject then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись СУБЪЕКТА ДОСТАВКИ занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_delivery-subject no-lock where
                       recid(locked_delivery-subject) = p-doc-rec no-error .
      if not avail locked_delivery-subject then do:
        find first locked_delivery-subject no-lock where
                   locked_delivery-subject.deliv-subj-code = p-deliv-subj-code no-error .
      end.
    end.
    if not available locked_delivery-subject then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись СУБЪЕКТА ДОСТАВКИ"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-delivery-subject.
    buffer-copy locked_delivery-subject to tt-delivery-subject.
   end.
   else do:
          create tt-delivery-subject.
          assign
         tt-delivery-subject.deliv-subj-code = v-last-code + 1
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
  OPEN QUERY Dialog-Frame FOR EACH tt-delivery-subject SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY f-reg-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-delivery-subject THEN
    DISPLAY tt-delivery-subject.deliv-subj-code
          tt-delivery-subject.deliv-subj-name tt-delivery-subject.reg-code
          tt-delivery-subject.des
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Hist B-Help tt-delivery-subject.deliv-subj-code
         tt-delivery-subject.deliv-subj-name tt-delivery-subject.reg-code
         b-region tt-delivery-subject.des
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyENable :
DEFINE BUFFER buf_regions FOR ub.regions.
IF tt-delivery-subject.reg-code > 0  THEN DO:
  find first buf_regions no-lock
      where buf_regions.reg-code = tt-delivery-subject.reg-code
    no-error .
  if not available buf_regions then do:
    message
    SUBSTITUTE("Неверный код региона &1", tt-delivery-subject.reg-code)
    view-as alert-box error.
   end.
END.
case p-mode:
  when 'ДОБАВЛЕНИЕ':U then do:
    display
    ? @ tt-delivery-subject.deliv-subj-code
    WITH FRAME Dialog-Frame.
  end.
  otherwise do:
    IF AVAILABLE tt-delivery-subject THEN
    DISPLAY
    tt-delivery-subject.deliv-subj-code
    tt-delivery-subject.deliv-subj-name
    tt-delivery-subject.des
    (IF AVAILABLE buf_regions
     THEN buf_regions.reg-name
     ELSE '')   @ f-reg-name
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
b-region when p-mode <> 'ПРОСМОТР':U
B-Help
tt-delivery-subject.deliv-subj-name when p-mode <> 'ПРОСМОТР':U
tt-delivery-subject.des when p-mode <> 'ПРОСМОТР':U
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE Proc-save :
if p-mode = 'ПРОСМОТР':U then do:
    return error.
end.
if not available tt-delivery-subject then do:
    create tt-delivery-subject.
end.
assign
tt-delivery-subject.deliv-subj-code frame Dialog-Frame
tt-delivery-subject.deliv-subj-name
tt-delivery-subject.des = tt-delivery-subject.des:SCREEN-VALUE
.
 run ref/dlvsubj1.p (
input-output p-doc-rec
,input p-mode
,input tt-delivery-subject.deliv-subj-code
,input tt-delivery-subject.deliv-subj-name
,input tt-delivery-subject.reg-code
,input tt-delivery-subject.des
)
no-error.
if error-status:error then do:
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
