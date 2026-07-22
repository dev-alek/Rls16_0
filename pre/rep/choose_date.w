define temp-table  tt-dateZakaz     no-undo
field id as integer
field dateStart as date
field dateEnd as date
index pi id
    .
DEFINE TEMP-TABLE tt-typeDocChoose NO-UNDO
  field type-code as character
  field typeName  as character.
define temp-table gds-list like ub.goods
  field minZapas as decimal
  field contract as character
  field contract-code as integer
  field price as decimal
  field doc-qnty as decimal
  index pi contract gds-code.
 define temp-table choose-gds-list like ub.goods
  field minZapas as decimal
  field contract as character
  field contract-code as integer
  field price as decimal
  field doc-qnty as decimal
  index pi contract gds-code.
  define temp-table tt-gds-list like ub.goods
  field contract-code as integer
  field price as decimal
  field doc-qnty as decimal
  index pi gds-code.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure sel-date :
  define input  parameter p-date-handle as handle    no-undo .
  define input  parameter p-description as character no-undo .
  do
  on error undo, return error return-value
  :
    if (can-query (p-date-handle, "sensitive")
      and
      p-date-handle :sensitive = true
      )
    or (can-query (p-date-handle, "read-only")
      and
      p-date-handle :read-only = false
      )
    then do:
      if p-date-handle :handle <> focus :handle
      then do:
        apply "entry":u to p-date-handle .
      end.
      define variable v-ok            as logical no-undo .
      define variable v-curr-sv-date as date no-undo .
      assign
        v-curr-sv-date = date(p-date-handle :screen-value) no-error
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
          ,input p-description
          ,input ""
          ,input-output v-curr-sv-date
          ,output v-ok
          ).
        if v-ok = true
        then do:
          assign
            p-date-handle :screen-value = string(v-curr-sv-date) .
          .
        end.
      end.
    end.
  end.
end procedure.
DEFINE INPUT PARAMETER  parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input-output  PARAMETER TABLE FOR tt-dateZakaz.
define buffer buf_dateZakaz for tt-dateZakaz .
DEFINE BUTTON b-date-End
  IMAGE-UP FILE "btn-down-arrow":U
  IMAGE-DOWN FILE "btn-down-arrow":U
  IMAGE-INSENSITIVE FILE "btn-down-arrow":U
  LABEL ""
  SIZE 3 BY .88.
DEFINE BUTTON b-date-Start
  IMAGE-UP FILE "btn-down-arrow":U
  IMAGE-DOWN FILE "btn-down-arrow":U
  IMAGE-INSENSITIVE FILE "btn-down-arrow":U
  LABEL ""
  SIZE 3 BY .88.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
  LABEL "Отмена"
  SIZE 15 BY 1.13
  BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
  LABEL "Ввод"
  SIZE 15 BY 1.13
  BGCOLOR 8 .
DEFINE VARIABLE Date-End   AS DATE FORMAT "99/99/9999":U
  LABEL "по"
  VIEW-AS FILL-IN NATIVE
  SIZE 13 BY 1
  BGCOLOR 15 NO-UNDO.
DEFINE VARIABLE Date-Start AS DATE FORMAT "99/99/9999":U
  LABEL "С"
  VIEW-AS FILL-IN NATIVE
  SIZE 13 BY 1
  BGCOLOR 15 NO-UNDO.
DEFINE RECTANGLE RECT-8
  EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
  SIZE 47 BY 2.5.
DEFINE FRAME Dialog-Frame
  Btn_OK AT ROW 1 COL 1
  Btn_Cancel AT ROW 1 COL 16
  Date-Start AT ROW 3.5 COL 6 COLON-ALIGNED WIDGET-ID 34
  b-date-Start AT ROW 3.5 COL 23 RIGHT-ALIGNED WIDGET-ID 374
  Date-End AT ROW 3.5 COL 42 RIGHT-ALIGNED WIDGET-ID 32
  b-date-End AT ROW 3.5 COL 45 RIGHT-ALIGNED WIDGET-ID 376
  RECT-8 AT ROW 2.75 COL 3 WIDGET-ID 378
  SPACE(1.24) SKIP(0.66)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
  TITLE "Задайте период"
  DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.
ASSIGN
  FRAME Dialog-Frame:SCROLLABLE = FALSE
  FRAME Dialog-Frame:HIDDEN     = TRUE.
ASSIGN
  b-date-End:HIDDEN IN FRAME Dialog-Frame = TRUE.
ASSIGN
  b-date-Start:HIDDEN IN FRAME Dialog-Frame = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
  DO:
    APPLY "END-ERROR":U TO SELF.
  END.
ON CHOOSE OF btn_ok IN FRAME Dialog-Frame
  DO:
  find first tt-dateZakaz no-error .
  if not available (tt-dateZakaz) then do:
    create tt-dateZakaz .
    assign
    tt-dateZakaz.id = 1
    tt-dateZakaz.dateStart = Date-Start
    tt-dateZakaz.dateEnd = Date-End .
  end.
  else do:
    find first tt-dateZakaz no-lock where (Date-Start >= tt-dateZakaz.dateStart and Date-Start <= tt-dateZakaz.dateEnd) or
    (Date-End >= tt-dateZakaz.dateStart and Date-End <= tt-dateZakaz.dateEnd) no-error .
    if available (tt-dateZakaz) then do:
      message "Выбранный интервал пересекается с предыдущим"
      view-as alert-box.
      return no-apply .
    end.
    find last tt-dateZakaz no-error .
    if available (tt-dateZakaz) then do:
      create buf_dateZakaz .
      assign
      buf_dateZakaz.id = tt-dateZakaz.id + 1
      buf_dateZakaz.dateEnd = Date-End
      buf_dateZakaz.dateStart = Date-Start
      .
    end.
  end.
  END.
ON CHOOSE OF b-date-End IN FRAME Dialog-Frame
  DO:
    run sel-date in this-procedure
      (input Date-End :handle
      ,input ""
      ) .
    if date(Date-End:screen-value) < Date-Start then
    do:
      message "Дата начала не может быть больше конечной даты"
        view-as alert-box.
      display Date-End with frame Dialog-Frame .
    end.
    if date(Date-End:screen-value) >= today then
    do:
      message "Дата окончания периода продаж должна быть меньше текущей"
        view-as alert-box.
      display Date-End with frame Dialog-Frame .
    end.
  END.
ON CHOOSE OF b-date-Start IN FRAME Dialog-Frame
  DO:
    run sel-date in this-procedure
      (input Date-Start :handle
      ,input ""
      ) .
    if Date-End < date(Date-Start:screen-value) then
    do:
      message "Дата начала не может быть больше конечной даты"
        view-as alert-box.
      display Date-Start with frame Dialog-Frame .
    end.
    if date(Date-Start:screen-value) >= today then
    do:
      message "Дата начала периода продаж должна быть меньше текущей"
        view-as alert-box.
      display Date-Start with frame Dialog-Frame .
    end.
  END.
ON LEAVE OF Date-End IN FRAME Dialog-Frame
  DO:
    apply "TAB":U to self .
  END.
ON LEAVE OF Date-Start IN FRAME Dialog-Frame
  DO:
    apply "TAB":U to self .
  END.
ON RETURN OF Date-End IN FRAME Dialog-Frame
  DO:
    apply "TAB":U to self .
  END.
ON TAB OF Date-End IN FRAME Dialog-Frame
  DO:
    if string(Date-End) <> Date-End:screen-value then
    do:
      if date(Date-End:screen-value) < Date-Start then
      do:
        message "Дата начала не может быть больше конечной даты"
          view-as alert-box.
        return no-apply .
      end.
      if date(Date-End:screen-value) >= today then
      do:
        message "Дата окончания периода продаж должна быть меньше текущей"
          view-as alert-box.
        display Date-End with frame Dialog-Frame .
        return .
      end.
      assign Date-End .
      display Date-End with frame Dialog-Frame .
    end.
  END.
ON RETURN OF Date-Start IN FRAME Dialog-Frame
  DO:
    apply "TAB":U to self .
  END.
ON TAB OF Date-Start IN FRAME Dialog-Frame
  DO:
    if string(Date-Start) <> Date-Start:screen-value then
    do:
      if Date-End < date(Date-Start:screen-value) then
      do:
        message "Дата начала не может быть больше конечной даты"
          view-as alert-box.
        return no-apply .
      end.
      if date(Date-Start:screen-value) >= today then
      do:
        message "Дата начала периода продаж должна быть меньше текущей"
          view-as alert-box.
        display Date-Start with frame Dialog-Frame .
        return .
      end.
      assign Date-Start .
      display Date-Start with frame Dialog-Frame .
    end.
  END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
  THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of Date-Start in frame Dialog-Frame
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
on delete-character of Date-Start in frame Dialog-Frame
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
on ctrl-d of Date-Start in frame Dialog-Frame
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
on ctrl-b of Date-Start in frame Dialog-Frame
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
on ctrl-e of Date-Start in frame Dialog-Frame
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
on ctrl-f of Date-Start in frame Dialog-Frame
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
  define MENU m-ed-date2
    MENU-ITEM m-ed-date2-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date2-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date2-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date2-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if Date-Start :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      Date-Start :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date2 :HANDLE
      Date-Start :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle2 as handle no-undo .
  assign
    v-label-handle2 = Date-Start :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle2)
  then do:
    if v-label-handle2 :tooltip = ""
    or v-label-handle2 :tooltip = ?
    then do:
      assign
        v-label-handle2 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date2-1 in menu m-ed-date2 DO:
    apply "ctrl-b":U to Date-Start in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date2-2 in menu m-ed-date2 DO:
    apply "ctrl-d":U to Date-Start in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date2-3 in menu m-ed-date2 DO:
    apply "ctrl-e":U to Date-Start in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date2-4 in menu m-ed-date2 DO:
    apply "ctrl-f":U to Date-Start in frame Dialog-Frame .
  END.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of Date-End in frame Dialog-Frame
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
on delete-character of Date-End in frame Dialog-Frame
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
on ctrl-d of Date-End in frame Dialog-Frame
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
on ctrl-b of Date-End in frame Dialog-Frame
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
on ctrl-e of Date-End in frame Dialog-Frame
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
on ctrl-f of Date-End in frame Dialog-Frame
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
  if Date-End :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      Date-End :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date4 :HANDLE
      Date-End :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle4 as handle no-undo .
  assign
    v-label-handle4 = Date-End :side-label-handle in frame Dialog-Frame
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
    apply "ctrl-b":U to Date-End in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-2 in menu m-ed-date4 DO:
    apply "ctrl-d":U to Date-End in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-3 in menu m-ed-date4 DO:
    apply "ctrl-e":U to Date-End in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-4 in menu m-ed-date4 DO:
    apply "ctrl-f":U to Date-End in frame Dialog-Frame .
  END.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY Date-Start Date-End
    WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel RECT-8 Date-Start b-date-Start Date-End b-date-End
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
