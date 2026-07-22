define input  parameter parparentproc  as widget-handle no-undo .
define input  parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input  parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define output parameter p-shift-date like ub.chk-doc.shift-date no-undo.
define output parameter p-shift-num like ub.chk-doc.shift-num no-undo.
define output parameter p-shift-name as character no-undo .
define output parameter p-shift-place-from as int no-undo.
define output parameter p-shift-place-to as int no-undo.
define output parameter p-change-fields as character no-undo.
define output parameter p-can-back-shift as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Запрос на изменение даты и или номера смены" .
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
define variable v-host-code as integer no-undo .
define variable glog as logical no-undo .
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE n-shift-date AS CHARACTER FORMAT "X(256)":U INITIAL "Дата смены (учета):"
      VIEW-AS TEXT
     SIZE 20 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-shift-name AS CHARACTER FORMAT "X(256)":U INITIAL "№ смены"
      VIEW-AS TEXT
     SIZE 14.4 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-shift-num AS CHARACTER FORMAT "X(256)":U INITIAL "Порядок смены"
      VIEW-AS TEXT
     SIZE 14.4 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-shift-reservoir AS CHARACTER FORMAT "X(9)" INITIAL "Резервуар"
      VIEW-AS TEXT
     SIZE 14.4 BY 1
     FGCOLOR 15 NO-UNDO.
DEFINE VARIABLE n-shift-reservoir-from AS CHARACTER FORMAT "X(7)" INITIAL "Сменить"
    VIEW-AS TEXT
    SIZE 9 BY 1
    NO-UNDO.
DEFINE VARIABLE n-shift-reservoir-to AS CHARACTER FORMAT "X(2)" INITIAL "На"
    VIEW-AS TEXT
    SIZE 9 BY 1
    NO-UNDO.
DEFINE VARIABLE shift-date AS DATE FORMAT "99/99/9999":U
     VIEW-AS FILL-IN
     SIZE 12.8 BY 1 NO-UNDO.
DEFINE VARIABLE shift-name AS CHARACTER FORMAT "X(2)":U INITIAL "0"
     VIEW-AS FILL-IN
     SIZE 3.4 BY 1 NO-UNDO.
DEFINE VARIABLE shift-name-i AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3.4 BY 1 NO-UNDO.
DEFINE VARIABLE shift-num AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3.4 BY 1 NO-UNDO.
DEFINE VARIABLE shift-reservoir-from AS CHARACTER FORMAT "X(8)" INITIAL ""
     VIEW-AS COMBO-BOX
     INNER-LINES 5
     LIST-ITEM-PAIRS "def", "1"
     DROP-DOWN-LIST
     SIZE 18 BY 1 NO-UNDO.
DEFINE VARIABLE shift-reservoir-to AS CHARACTER FORMAT "X(8)" INITIAL ""
     VIEW-AS COMBO-BOX
     INNER-LINES 5
     LIST-ITEM-PAIRS "def", "1"
     DROP-DOWN-LIST
     SIZE 18 BY 1 NO-UNDO.
DEFINE IMAGE l-shift-date
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-shift-name
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-shift-num
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-shift-reservoir
    FILENAME "adeicon\lock":U
    SIZE 2.9 BY .93.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-exit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 45
     shift-date AT ROW 2.5 COL 27.5 COLON-ALIGNED NO-LABEL
     shift-name AT ROW 3.93 COL 27.8 COLON-ALIGNED NO-LABEL
     shift-name-i AT ROW 3.93 COL 27.8 COLON-ALIGNED NO-LABEL
     shift-num AT ROW 5.93 COL 27.8 COLON-ALIGNED NO-LABEL
     shift-reservoir-from AT ROW 8.07 COL 27.8 COLON-ALIGNED NO-LABEL
     shift-reservoir-to AT ROW 9.07 COL 27.8 COLON-ALIGNED NO-LABEL
     n-shift-date AT ROW 2.53 COL 6.1 NO-LABEL
     n-shift-name AT ROW 4.07 COL 3.6 COLON-ALIGNED NO-LABEL
     n-shift-num AT ROW 6.07 COL 3.6 COLON-ALIGNED NO-LABEL
     n-shift-reservoir AT ROW 8.07 COL 3.6 COLON-ALIGNED NO-LABEL
     n-shift-reservoir-from AT ROW 8.07 COL 18 COLON-ALIGNED NO-LABEL
     n-shift-reservoir-to AT ROW 9.07 COL 18 COLON-ALIGNED NO-LABEL
     l-shift-num AT ROW 6 COL 2.6
     l-shift-date AT ROW 2.53 COL 2.6
     l-shift-name AT ROW 4 COL 2.6
     l-shift-reservoir AT ROW 8 COL 2.6
     SPACE(42.62) SKIP(2.60)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Изменение списка чеков"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       shift-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
  assign
  p-shift-date = ?
  p-shift-num = 0
  p-shift-name = ''
  p-change-fields = "":U
  .
END.
ON MOUSE-SELECT-CLICK OF l-shift-date IN FRAME Dialog-Frame
DO:
   IF l-shift-date:visible then do:
    assign
    n-shift-date:fgcolor = ?
    l-shift-date:visible = false.
    enable shift-date with frame Dialog-Frame.
    APPLY "ENTRY" TO shift-date.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-shift-name IN FRAME Dialog-Frame
DO:
   IF l-shift-name:visible then do:
    assign
    n-shift-name:fgcolor = ?
    l-shift-name:visible = false.
    enable
    shift-name-i
    with frame Dialog-Frame.
    APPLY "ENTRY" TO shift-name-i.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-shift-num IN FRAME Dialog-Frame
DO:
   IF l-shift-num:visible then do:
    assign
    n-shift-num:fgcolor = ?
    l-shift-num:visible = false.
    enable
    shift-num
    with frame Dialog-Frame.
    APPLY "ENTRY" TO shift-num.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-shift-reservoir IN FRAME Dialog-Frame
DO:
   IF l-shift-reservoir:visible then do:
    assign
    n-shift-reservoir:fgcolor = ?
    l-shift-reservoir:visible = false.
    enable
    shift-reservoir-from shift-reservoir-to
    with frame Dialog-Frame.
    disp n-shift-reservoir-from n-shift-reservoir-to
    with frame Dialog-Frame.
    APPLY "ENTRY" TO shift-reservoir-from.
  end.
END.
ON RIGHT-MOUSE-CLICK OF shift-date IN FRAME Dialog-Frame
DO:
    assign
    n-shift-date:fgcolor = 15
    shift-date = ?
    l-shift-date:visible = true.
    display shift-date with frame Dialog-Frame.
    disable shift-date with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF shift-name IN FRAME Dialog-Frame
DO:
    assign
    n-shift-name:fgcolor = 15
    shift-name = ?
    l-shift-name:visible = true.
    display shift-name with frame Dialog-Frame.
    disable shift-name with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF shift-name-i IN FRAME Dialog-Frame
DO:
    assign
    n-shift-name:fgcolor = 15
    shift-name-i = ?
    l-shift-name:visible = true.
    display shift-name-i with frame Dialog-Frame.
    disable shift-name-i with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF shift-num IN FRAME Dialog-Frame
DO:
    assign
    n-shift-num:fgcolor = 15
    shift-num = ?
    l-shift-num:visible = true.
    display shift-num with frame Dialog-Frame.
    disable shift-num with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF shift-reservoir-from IN FRAME Dialog-Frame
DO:
    assign
    n-shift-reservoir:fgcolor = 15
    shift-reservoir-from = ""
    shift-reservoir-to = ""
    l-shift-reservoir:visible = true
    n-shift-reservoir-from:VISIBLE = false
    n-shift-reservoir-to:VISIBLE = false.
    display shift-reservoir-from shift-reservoir-to with frame Dialog-Frame.
    disable shift-reservoir-from shift-reservoir-to with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF shift-reservoir-to IN FRAME Dialog-Frame
DO:
    apply "RIGHT-MOUSE-CLICK" to shift-reservoir-from.
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of shift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of shift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of shift-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of shift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of shift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of shift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date4
    MENU-ITEM m-ed-date4-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date4-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date4-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date4-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if shift-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      shift-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date4 :HANDLE
      shift-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle4 as handle no-undo .
  assign
    v-label-handle4 = shift-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle4)
  then do:
    if v-label-handle4 :tooltip = ""
    or v-label-handle4 :tooltip = ?
    then do:
      assign
        v-label-handle4 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date4-1 in menu m-ed-date4 DO:
    apply "ctrl-b":U to shift-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-2 in menu m-ed-date4 DO:
    apply "ctrl-d":U to shift-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-3 in menu m-ed-date4 DO:
    apply "ctrl-e":U to shift-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-4 in menu m-ed-date4 DO:
    apply "ctrl-f":U to shift-date in frame Dialog-Frame .
  END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  RUN enable_UI.
  RUN fill-lists (p-curr-obj-type, p-curr-obj-code) .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY shift-date shift-name-i shift-num shift-reservoir-from shift-reservoir-to
          n-shift-date n-shift-name n-shift-num n-shift-reservoir
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-exit B-Help l-shift-num l-shift-date l-shift-name l-shift-reservoir
         n-shift-date n-shift-name n-shift-num n-shift-reservoir n-shift-reservoir-from
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
function get-res-num returns char(res-id as int):
    def buffer buf_place for ub.place.
    find first buf_place no-lock
        where buf_place.pl-code = res-id
        no-error.
    if avail buf_place then
        return buf_place.loc1.
    else
        return "".
end.
PROCEDURE proc-save :
define variable v-message as character no-undo.
define variable loc#log as logical no-undo.
define variable varshift-date as date no-undo .
define variable varshift-num as integer no-undo .
define variable varshift-name as character no-undo.
define variable l-shift-on as logical no-undo .
define variable v-value as character no-undo .
assign
frame Dialog-Frame
shift-date
shift-num
shift-name-i
shift-reservoir-from
shift-reservoir-to
.
if shift-num > 24 then do:
  message
  "Порядок смены не может быть больше" 24
  view-as alert-box error.
  return error.
end.
if shift-name-i > 99 then do:
  message
  "Номер смены не может быть больше" 99
  view-as alert-box error.
  return error.
end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
if l-shift-on then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output varshift-date
  ,output varshift-num
  ,output varshift-name
  ) no-error .
  if error-status:error
  or not (varshift-date = shift-date
         and shift-date:sensitive)
  or not (varshift-num = shift-num
          and shift-num:sensitive) then do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_receipts_change-back-shift':U
    ,input  'object':U
    ,input  v-host-code
    ,input  p-curr-obj-type
    ,input  p-curr-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    if not glog then do:
      undo, return error .
    end.
    p-can-back-shift = yes.
  end.
end.
assign
p-change-fields = '':U
p-change-fields = IF shift-date:SENSITIVE
                                  then (p-change-fields + chr(44) + "shift-date":U)
                                  else p-change-fields
p-change-fields = IF shift-num:SENSITIVE then
                                   (p-change-fields + chr(44) + "shift-num":U)
                                   else p-change-fields
p-change-fields = IF shift-name-i:SENSITIVE
                THEN (p-change-fields + chr(44) + "shift-name":U)
                else p-change-fields
p-change-fields = if shift-reservoir-from:SENSITIVE
                then (p-change-fields + chr(44) + "shift-reservoir-from")
                else p-change-fields
p-change-fields = if shift-reservoir-to:SENSITIVE
                then (p-change-fields + chr(44) + "shift-reservoir-to")
                else p-change-fields
p-shift-date = IF shift-date:SENSITIVE then shift-date else ?
p-shift-num = if shift-num:SENSITIVE then shift-num else 0
p-shift-name = if shift-name-i:SENSITIVE then string(shift-name-i) else ''
p-shift-place-to = if shift-reservoir-to:SENSITIVE then int(shift-reservoir-to) else 0
p-shift-place-from = if shift-reservoir-from:SENSITIVE then int(shift-reservoir-from) else 0
v-message = substitute("ДАТА СМЕНЫ (УЧЕТА)=&1 НОМЕР СМЕНЫ=&2 ПОРЯДОК СМЕНЫ=&3 &4"
                     , (IF shift-date:SENSITIVE
                       then string(shift-date, "99/99/9999")
                       else "")
                     , (IF shift-name-i:SENSITIVE
                       then string(shift-name-i, ">9")
                       else "":U)
                  , (IF shift-num:SENSITIVE
                    then string(shift-num, ">9")
                    else "":U)
                  , ( if shift-reservoir-to:SENSITIVE
                    then "Резеруар (изменить=" + get-res-num(int(shift-reservoir-from)) + " на=" + get-res-num(int(shift-reservoir-to)) + ")"
                    else ""
                    ))
.
message
"Для списка чеков будут проведены следующие изменения" skip
v-message skip(2)
"При проведении изменения будет проводиться проверка на корректность изменений для каждого конкретного чека" skip
"Если изменения нарушают логику чека, то чек изменен не будет" skip(2)
(if  p-can-back-shift = no
 then substitute("ВНИМАНИЕ!!!!&1"  +
                "если сменный режим включен не только на кассах, но и в бэк-офисе,&1" +
                "изменения даты/номера смены можно произвести ТОЛЬКО ПРИ ОТКРЫТОЙ СМЕНЕ&1"  +
                "и дата/номер смены или резервуара чека после изменения должны СОВПАДАТЬ с датой/номером смены в бэк-офисе&1"  +
                "ТАКОЙ ЧЕК ПОПАДЕТ В ОТЧЕТ О ПРОДАЖЕ ТЕКУЩЕЙ СМЕНЫ!&1&1"
                , chr(10))
else '':U)
"Провести изменения даты/смены или резервуара чеков?"
view-as alert-box question buttons YES-NO update loc#log.
if not loc#log  then return error.
END PROCEDURE.
procedure fill-lists:
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define variable v-pl-name as character no-undo .
define variable v-pl-code as character no-undo .
define buffer buf_place for ub.place .
    do with frame Dialog-Frame:
        shift-reservoir-from:DELETE (1).
        shift-reservoir-to  :DELETE (1).
        for each buf_place no-lock
           where buf_place.obj-type = p-obj-type
             and buf_place.obj-code = p-obj-code:
          assign
            v-pl-name = substitute(  "&1 &2",  buf_place.loc1,  replace(buf_place.pl-name, ",", " ")  )
            v-pl-code = substitute(  "&1",     buf_place.pl-code)
          .
          if trim(v-pl-name) = "" then v-pl-name = substitute("&1", buf_place.pl-name) .
          if trim(v-pl-name) = "" then v-pl-name = "N Топливо" .
          if trim(v-pl-code) = "" then v-pl-code = "0" .
          shift-reservoir-from:ADD-LAST(v-pl-name, v-pl-code).
          shift-reservoir-to  :ADD-LAST(v-pl-name, v-pl-code).
        end.
    end.
end procedure.
