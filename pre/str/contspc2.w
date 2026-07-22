define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Установка полей (проценты отклонения, бонус, НДС, ретро-бонус) для всех товаров спецификации".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define input  parameter parParentProc  as widget-handle no-undo.
define output parameter p-prc          as decimal   no-undo.
define output parameter p-prc-2        as decimal   no-undo.
define output parameter p-bonus        as decimal   no-undo.
define output parameter p-vat-pc       as decimal   no-undo.
define output parameter p-vat-type     as character no-undo.
define output parameter p-retro-bonus  as character no-undo.
define output parameter p-change-fields  as character no-undo.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE v-method AS CHARACTER FORMAT "X(256)":U
     LABEL "Метод расчета"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Приход с НДС","vat-yes",
                     "Приход без НДС","vat-no"
     DROP-DOWN-LIST
     SIZE 22 BY 1 NO-UNDO.
DEFINE VARIABLE vat-type AS CHARACTER FORMAT "x(8)"
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEMS "1","2"
     DROP-DOWN-LIST
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-bonus AS DECIMAL FORMAT "->>9.99":U INITIAL 0
     LABEL "Бонус от цены товара %"
     VIEW-AS FILL-IN
     SIZE 13.2 BY 1 TOOLTIP "Процент к продажной цене" NO-UNDO.
DEFINE VARIABLE FILL-prc AS DECIMAL FORMAT "->>9.99":U INITIAL 0
     LABEL "Допустимый % отклонения цены от спецификации в большую сторону"
     VIEW-AS FILL-IN
     SIZE 13.2 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-prc-2 AS DECIMAL FORMAT "->>9.99":U INITIAL 0
     LABEL "Допустимый % отклонения цены от спецификации в меньшую сторону"
     VIEW-AS FILL-IN
     SIZE 13.2 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-VAT-pc AS DECIMAL FORMAT ">9.9":U INITIAL 0
     LABEL "НДС"
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.
DEFINE VARIABLE v-date-from AS DATE FORMAT "99/99/9999":U initial TODAY
     LABEL "Период с"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE v-date-to AS DATE FORMAT "99/99/9999":U initial TODAY
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
DEFINE IMAGE l-bonus
     FILENAME "adeicon\lock":U
     SIZE 3 BY .95.
DEFINE IMAGE l-prc
     FILENAME "adeicon\lock":U
     SIZE 3 BY .95.
DEFINE IMAGE l-prc-2
     FILENAME "adeicon\lock":U
     SIZE 3 BY .95.
DEFINE IMAGE l-retro-bonus
     FILENAME "adeicon\lock":U
     SIZE 3 BY .95.
DEFINE IMAGE l-vat
     FILENAME "adeicon\lock":U
     SIZE 3 BY .95.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 85.4 BY 3.33.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 85.4 BY 1.95.
DEFINE VARIABLE v-vozvrat AS LOGICAL INITIAL no
     LABEL "Не считать бонусы при наличии возвратов"
     VIEW-AS TOGGLE-BOX
     SIZE 48 BY .81 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1 WIDGET-ID 2
     b-quit AT ROW 1 COL 11 WIDGET-ID 4
     FILL-prc AT ROW 2.33 COL 8 WIDGET-ID 10
     FILL-prc-2 AT ROW 3.62 COL 8 WIDGET-ID 8
     FILL-bonus AT ROW 4.86 COL 48 WIDGET-ID 6
     vat-type AT ROW 6.29 COL 22 COLON-ALIGNED NO-LABEL WIDGET-ID 16
     FILL-VAT-pc AT ROW 6.33 COL 12.4 COLON-ALIGNED WIDGET-ID 12
     v-date-from AT ROW 8.29 COL 19 COLON-ALIGNED WIDGET-ID 20
     v-date-to AT ROW 8.29 COL 38 COLON-ALIGNED WIDGET-ID 22
     v-pct AT ROW 10.14 COL 10.6 COLON-ALIGNED WIDGET-ID 26
     v-sum AT ROW 10.14 COL 33.6 COLON-ALIGNED WIDGET-ID 28
     v-method AT ROW 10.14 COL 65 COLON-ALIGNED WIDGET-ID 24
     v-vozvrat AT ROW 11.81 COL 9.8 WIDGET-ID 30
     "%" VIEW-AS TEXT
          SIZE 1.8 BY .67 AT ROW 6.48 COL 21.8 WIDGET-ID 14
     RECT-1 AT ROW 9.67 COL 8.6 WIDGET-ID 18
     RECT-2 AT ROW 7.81 COL 8.6 WIDGET-ID 32
     l-prc AT ROW 2.43 COL 2.6 WIDGET-ID 34
     l-prc-2 AT ROW 3.67 COL 2.6 WIDGET-ID 36
     l-bonus AT ROW 4.91 COL 2.6 WIDGET-ID 38
     l-vat AT ROW 6.33 COL 2.6 WIDGET-ID 40
     l-retro-bonus AT ROW 8.29 COL 2.6 WIDGET-ID 42
     SPACE(89.19) SKIP(3.85)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры для всех товаров спецификации" WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  assign FILL-prc FILL-prc-2 vat-type FILL-vat-pc FILL-bonus v-date-from v-date-to v-pct v-sum v-method v-vozvrat .
  if l-retro-bonus:visible = false THen do :
  if v-date-to < v-date-from then do :
     message "Неверно введены даты!" view-as alert-box.
     return no-apply.
  end.
  if v-method:screen-value = ? then do :
     message "Выберите метод расчета ретро-бонуса!" view-as alert-box.
     return  no-apply.
  end.
  if v-pct = 0 and v-sum = 0 then do :
     MESSAGE "Процент и сумма ретро-бонуса нулевые. Всё равно продолжить?"
     VIEW-AS ALERT-BOX QUESTION
     BUTTONS yes-no UPDATE continue-ok AS LOGICAL.
     IF not continue-ok then return no-apply.
  end.
  end.
  assign
    p-change-fields = '':U
    p-change-fields = IF FILL-prc:sensitive
                                  then (p-change-fields + chr(44) + "prc":U)
                                  else p-change-fields
    p-change-fields = IF FILL-prc-2:sensitive
                                  then (p-change-fields + chr(44) + "prc-2":U)
                                  else p-change-fields
    p-change-fields = IF FILL-bonus:sensitive
                                  then (p-change-fields + chr(44) + "bonus":U)
                                  else p-change-fields
    p-change-fields = IF FILL-vat-pc:sensitive
                                  then (p-change-fields + chr(44) + "vat-pc":U)
                                  else p-change-fields
    p-change-fields = IF v-pct:sensitive
                                  then (p-change-fields + chr(44) + "retro-bonus":U)
                                  else p-change-fields
    p-prc   = FILL-prc
    p-prc-2   = FILL-prc-2
    p-vat-type = vat-type
    p-vat-pc = FILL-vat-pc
    p-bonus = FILL-bonus
    p-retro-bonus = string(v-date-from) + "," +
                    string(v-date-to)   + "," +
                    string(v-pct)       + "," +
                    string(v-sum)       + "," +
                    string(v-method)    + "," +
                    string(v-vozvrat)   + ";"
  .
END.
ON MOUSE-SELECT-CLICK OF l-bonus IN FRAME Dialog-Frame
DO:
   IF l-bonus:visible then do:
    assign
    l-bonus:visible = false.
    enable FILL-bonus with frame Dialog-Frame.
    APPLY "ENTRY" TO FILL-bonus.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-prc IN FRAME Dialog-Frame
DO:
   IF l-prc:visible then do:
    assign
    l-prc:visible = false.
    enable FILL-prc with frame Dialog-Frame.
    APPLY "ENTRY" TO FILL-prc.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-prc-2 IN FRAME Dialog-Frame
DO:
   IF l-prc-2:visible then do:
    assign
    l-prc-2:visible = false.
    enable FILL-prc-2 with frame Dialog-Frame.
    APPLY "ENTRY" TO FILL-prc-2.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-retro-bonus IN FRAME Dialog-Frame
DO:
  IF l-retro-bonus:visible then do:
    define variable glog as logical no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-bonus_work':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output gLog
    )  .
end.
    if NOT gLog then do:
      return.
    end.
    assign
    l-retro-bonus:visible = false.
    enable v-date-from v-date-to v-pct v-sum v-method v-vozvrat with frame Dialog-Frame.
    APPLY "ENTRY" TO v-date-from.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-vat IN FRAME Dialog-Frame
DO:
   IF l-vat:visible then do:
    assign
    l-vat:visible = false.
    enable vat-type FILL-vat-pc with frame Dialog-Frame.
    APPLY "ENTRY" TO FILL-vat-pc.
  end.
END.
ON RIGHT-MOUSE-CLICK OF FILL-bonus IN FRAME Dialog-Frame
DO:
    assign
    FILL-bonus = 0.00
    l-bonus:visible = true.
    display FILL-bonus with frame Dialog-Frame.
    disable FILL-bonus with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF FILL-prc IN FRAME Dialog-Frame
DO:
    assign
    FILL-prc = 0.00
    l-prc:visible = true.
    display FILL-prc with frame Dialog-Frame.
    disable FILL-prc with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF FILL-prc-2 IN FRAME Dialog-Frame
DO:
    assign
    FILL-prc-2 = 0.00
    l-prc-2:visible = true.
    display FILL-prc-2 with frame Dialog-Frame.
    disable FILL-prc-2 with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF FILL-vat-pc IN FRAME Dialog-Frame
DO:
    assign
    FILL-vat-pc = 0.00
    vat-type = ?
    l-vat:visible = true.
    display FILL-vat-pc vat-type with frame Dialog-Frame.
    disable FILL-vat-pc vat-type with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF v-pct IN FRAME Dialog-Frame
DO:
    assign
    v-date-from = TODAY
    v-date-to   = TODAY
    v-pct = 0.00
    v-sum = 0.00
    v-method = ?
    v-vozvrat = no
    l-retro-bonus:visible = true.
    display v-date-from v-date-to v-pct v-sum v-method v-vozvrat with frame Dialog-Frame.
    disable v-date-from v-date-to v-pct v-sum v-method v-vozvrat with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF v-sum IN FRAME Dialog-Frame
DO:
    assign
    v-date-from = TODAY
    v-date-to   = TODAY
    v-pct = 0.00
    v-sum = 0.00
    v-method = ?
    v-vozvrat = no
    l-retro-bonus:visible = true.
    display v-date-from v-date-to v-pct v-sum v-method v-vozvrat with frame Dialog-Frame.
    disable v-date-from v-date-to v-pct v-sum v-method v-vozvrat with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF v-method IN FRAME Dialog-Frame
DO:
    assign
    v-date-from = TODAY
    v-date-to   = TODAY
    v-pct = 0.00
    v-sum = 0.00
    v-method = ?
    v-vozvrat = no
    l-retro-bonus:visible = true.
    display v-date-from v-date-to v-pct v-sum v-method v-vozvrat with frame Dialog-Frame.
    disable v-date-from v-date-to v-pct v-sum v-method v-vozvrat with frame Dialog-Frame.
END.
ON VALUE-CHANGED OF vat-type IN FRAME Dialog-Frame
DO:
  assign vat-type .
  if vat-type = 'без':U then do:
    assign FILL-vat-pc = 0 .
    DISABLE FILL-VAT-pc WITH FRAME Dialog-Frame.
    display FILL-vat-pc WITH FRAME Dialog-Frame.
  end.
  else do:
    ENABLE FILL-VAT-pc WITH FRAME Dialog-Frame.
    display FILL-vat-pc WITH FRAME Dialog-Frame.
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define MENU m-ed-date4
    MENU-ITEM m-ed-date4-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date4-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date4-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date4-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if v-date-from :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      v-date-from :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date4 :HANDLE
      v-date-from :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle4 as handle no-undo .
  assign
    v-label-handle4 = v-date-from :side-label-handle in frame Dialog-Frame
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
    apply "ctrl-b":U to v-date-from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-2 in menu m-ed-date4 DO:
    apply "ctrl-d":U to v-date-from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-3 in menu m-ed-date4 DO:
    apply "ctrl-e":U to v-date-from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-4 in menu m-ed-date4 DO:
    apply "ctrl-f":U to v-date-from in frame Dialog-Frame .
  END.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define MENU m-ed-date6
    MENU-ITEM m-ed-date6-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date6-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date6-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date6-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if v-date-to :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      v-date-to :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date6 :HANDLE
      v-date-to :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle6 as handle no-undo .
  assign
    v-label-handle6 = v-date-to :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle6)
  then do:
    if v-label-handle6 :tooltip = ""
    or v-label-handle6 :tooltip = ?
    then do:
      assign
        v-label-handle6 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date6-1 in menu m-ed-date6 DO:
    apply "ctrl-b":U to v-date-to in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date6-2 in menu m-ed-date6 DO:
    apply "ctrl-d":U to v-date-to in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date6-3 in menu m-ed-date6 DO:
    apply "ctrl-e":U to v-date-to in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date6-4 in menu m-ed-date6 DO:
    apply "ctrl-f":U to v-date-to in frame Dialog-Frame .
  END.
  VAT-type:LIST-ITEMS  in frame Dialog-Frame =  'нет':U + "," + 'в т. ч.':U + "," + 'без':U .
  RUN enable_UI.
  if vat-type = 'без':U then  DISABLE FILL-VAT-pc WITH FRAME Dialog-Frame.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY FILL-prc FILL-prc-2 FILL-bonus vat-type FILL-VAT-pc v-date-from
          v-date-to v-pct v-sum v-method v-vozvrat
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit RECT-1 RECT-2 l-prc l-prc-2 l-bonus l-vat l-retro-bonus
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
