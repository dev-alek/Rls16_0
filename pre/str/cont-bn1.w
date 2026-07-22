define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Параметры расчета ретро-бонусов (редактирование)".
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
define temp-table tt-dates no-undo
  field date-from as date
  field date-to   as date
  field pct         as  decimal
  field sum         as  decimal
  field method      as  character
  field vozvrat     as  logical
  index pi is primary unique date-from date-to
.
define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter p-change       as logical       no-undo.
define input  parameter table for tt-dates.
define input-output parameter p-date-from as date      no-undo.
define input-output parameter p-date-to   as date      no-undo.
define input-output parameter p-pct       as decimal   no-undo.
define input-output parameter p-sum       as decimal   no-undo.
define input-output parameter p-method    as character no-undo.
define input-output parameter p-vozvrat   as logical   no-undo.
define input-output parameter tt-create   as logical   no-undo.
define variable date-from as date      no-undo.
define variable date-to   as date      no-undo.
define variable pct       as decimal   no-undo.
define variable sum       as decimal   no-undo.
define variable method    as character no-undo.
define variable vozvrat   as logical   no-undo.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Сохранить"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отменить"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE VARIABLE v-method AS CHARACTER FORMAT "X(256)":U
     LABEL "Метод расчета"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Приход с НДС","vat-yes",
                     "Приход без НДС","vat-no"
     DROP-DOWN-LIST
     SIZE 22 BY 1 NO-UNDO.
DEFINE VARIABLE v-date-from AS DATE FORMAT "99/99/9999":U INITIAL TODAY
     LABEL "Период с"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE v-date-to AS DATE FORMAT "99/99/9999":U INITIAL TODAY
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE v-pct AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "%"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE v-sum AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Сумма"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 82.2 BY 3.33.
DEFINE VARIABLE v-vozvrat AS LOGICAL INITIAL no
     LABEL "Не считать бонусы при наличии возвратов"
     VIEW-AS TOGGLE-BOX
     SIZE 48 BY .81 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 16
     v-date-from AT ROW 2.71 COL 13.8 COLON-ALIGNED WIDGET-ID 2
     v-date-to AT ROW 2.71 COL 32.8 COLON-ALIGNED WIDGET-ID 4
     v-pct AT ROW 4.57 COL 3.8 COLON-ALIGNED WIDGET-ID 6
     v-sum AT ROW 4.57 COL 26.8 COLON-ALIGNED WIDGET-ID 8
     v-method AT ROW 4.57 COL 58.2 COLON-ALIGNED WIDGET-ID 12
     v-vozvrat AT ROW 6.24 COL 3 WIDGET-ID 16
     RECT-1 AT ROW 4.1 COL 1.8 WIDGET-ID 14
     SPACE(0.99) SKIP(0.27)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Редактирование ретро-бонуса"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  assign v-date-from v-date-to v-pct v-sum v-method v-vozvrat .
  if v-date-to < v-date-from then do :
     message "Неверно введены даты!" view-as alert-box.
     return no-apply.
  end.
  if v-method:screen-value = ? then do :
     message "Выберите метод расчета!" view-as alert-box.
     return  no-apply.
  end.
  if v-pct = 0 and v-sum = 0 then do :
     MESSAGE "Процент и сумма нулевые. Всё равно добавить строку?"
     VIEW-AS ALERT-BOX QUESTION
     BUTTONS yes-no UPDATE continue-ok AS LOGICAL.
     IF not continue-ok then return no-apply.
  end.
  for each tt-dates no-lock :
     if (v-date-from <= tt-dates.date-to   and v-date-from >= tt-dates.date-from) or
        (v-date-to   <= tt-dates.date-to   and v-date-to   >= tt-dates.date-from) or
        (v-date-from <= tt-dates.date-from and v-date-to   >= tt-dates.date-to  ) then do :
              message "Периоды не должны пересекаться!" view-as alert-box.
              return  no-apply.
     end.
  end.
  tt-create = true.
  assign
    p-date-from = v-date-from
    p-date-to   = v-date-to
    p-pct       = v-pct
    p-sum       = v-sum
    p-method    = v-method
    p-vozvrat   = v-vozvrat
  .
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
if p-change then do :
  tt-create = true.
  assign
    p-date-from = date-from
    p-date-to   = date-to
    p-pct       = pct
    p-sum       = sum
    p-method    = method
    p-vozvrat   = vozvrat
  .
end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of v-date-from in frame Dialog-Frame
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
on delete-character of v-date-from in frame Dialog-Frame
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
on ctrl-d of v-date-from in frame Dialog-Frame
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
on ctrl-b of v-date-from in frame Dialog-Frame
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
on ctrl-e of v-date-from in frame Dialog-Frame
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
on ctrl-f of v-date-from in frame Dialog-Frame
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
  define MENU m-ed-date1
    MENU-ITEM m-ed-date1-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date1-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date1-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date1-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if v-date-from :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      v-date-from :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date1 :HANDLE
      v-date-from :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle1 as handle no-undo .
  assign
    v-label-handle1 = v-date-from :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle1)
  then do:
    if v-label-handle1 :tooltip = ""
    or v-label-handle1 :tooltip = ?
    then do:
      assign
        v-label-handle1 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date1-1 in menu m-ed-date1 DO:
    apply "ctrl-b":U to v-date-from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date1-2 in menu m-ed-date1 DO:
    apply "ctrl-d":U to v-date-from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date1-3 in menu m-ed-date1 DO:
    apply "ctrl-e":U to v-date-from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date1-4 in menu m-ed-date1 DO:
    apply "ctrl-f":U to v-date-from in frame Dialog-Frame .
  END.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of v-date-to in frame Dialog-Frame
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
on delete-character of v-date-to in frame Dialog-Frame
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
on ctrl-d of v-date-to in frame Dialog-Frame
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
on ctrl-b of v-date-to in frame Dialog-Frame
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
on ctrl-e of v-date-to in frame Dialog-Frame
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
on ctrl-f of v-date-to in frame Dialog-Frame
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
  define MENU m-ed-date3
    MENU-ITEM m-ed-date3-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date3-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date3-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date3-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if v-date-to :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      v-date-to :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date3 :HANDLE
      v-date-to :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle3 as handle no-undo .
  assign
    v-label-handle3 = v-date-to :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle3)
  then do:
    if v-label-handle3 :tooltip = ""
    or v-label-handle3 :tooltip = ?
    then do:
      assign
        v-label-handle3 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date3-1 in menu m-ed-date3 DO:
    apply "ctrl-b":U to v-date-to in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date3-2 in menu m-ed-date3 DO:
    apply "ctrl-d":U to v-date-to in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date3-3 in menu m-ed-date3 DO:
    apply "ctrl-e":U to v-date-to in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date3-4 in menu m-ed-date3 DO:
    apply "ctrl-f":U to v-date-to in frame Dialog-Frame .
  END.
  tt-create = false.
  assign date-from = p-date-from
         date-to   = p-date-to
         pct       = p-pct
         sum       = p-sum
         method    = p-method
         vozvrat   = p-vozvrat
  .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-date-from v-date-to v-pct v-sum v-method v-vozvrat
      WITH FRAME Dialog-Frame.
  ENABLE b-exit RECT-1 b-quit v-date-from v-date-to v-pct v-sum v-method
         v-vozvrat
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  if p-change then
    assign
      v-date-from:screen-value = string(p-date-from)
      v-date-to:screen-value   = string(p-date-to  )
      v-pct:screen-value       = string(p-pct)
      v-sum:screen-value       = string(p-sum)
      v-method:screen-value    = string(p-method)
      v-vozvrat:screen-value   = string(p-vozvrat)
    .
END PROCEDURE.
