define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Параметры расчета ретро-бонусов".
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
define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter p-host-code    as integer   no-undo .
define input  parameter p-doc-num      as integer   no-undo .
define input  parameter p-gds-code     as integer   no-undo .
define input-output parameter p-retro-bonus   as character no-undo .
define temp-table tt-bonus no-undo
  field date-from   as  date
  field date-to     as  date
  field pct         as  decimal
  field sum         as  decimal
  field method      as  character
  field vozvrat     as  logical
  index pi is unique primary date-from date-to
.
define variable v-date-from as date      no-undo.
define variable v-date-to   as date      no-undo.
define variable v-pct       as decimal   no-undo.
define variable v-sum       as decimal   no-undo.
define variable v-method    as character no-undo.
define variable v-vozvrat   as logical   no-undo.
define variable tt-create   as logical   no-undo.
define variable v-rowid     as rowid     no-undo.
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 15 BY 1.14.
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 15 BY 1.14.
DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 15 BY 1.14.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE QUERY BROWSE-bonus FOR
      tt-bonus SCROLLING.
DEFINE BROWSE BROWSE-bonus
  QUERY BROWSE-bonus NO-LOCK DISPLAY
      tt-bonus.date-from column-label "С":C10 format "99/99/9999"
      tt-bonus.date-to   column-label "По":C10 format "99/99/9999"
      tt-bonus.pct       column-label "%":C5 format ">>9.99<<"
      tt-bonus.sum       column-label "Сумма":C18 format ">>>>>>>>9.99<<"
      if tt-bonus.method = "vat-yes" then "Приход с НДС" else "Приход без НДС"    column-label "Метод":C23 format "X(15)"
      tt-bonus.vozvrat   column-label "Запрет! возвратов":C   format "yes/no"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 83 BY 7.45 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 16
     BROWSE-bonus AT ROW 2.5 COL 3 WIDGET-ID 200
     b-add AT ROW 10.52 COL 3 WIDGET-ID 4
     b-chg AT ROW 10.52 COL 18 WIDGET-ID 6
     b-del AT ROW 10.52 COL 33 WIDGET-ID 8
     SPACE(40.59) SKIP(0.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры расчета ретро-бонусов"
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
  p-retro-bonus = "".
  for each tt-bonus no-lock :
      p-retro-bonus = p-retro-bonus + string(tt-bonus.date-from) + ","
                                    + string(tt-bonus.date-to)   + ","
                                    + string(tt-bonus.pct)       + ","
                                    + string(tt-bonus.sum)       + ","
                                    + tt-bonus.method            + ","
                                    + string(tt-bonus.vozvrat)   + ";"
      .
  end.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
   run str\cont-bn1.w
      ( input parParentProc,
        input no,
        input table tt-bonus,
        input-output v-date-from,
        input-output v-date-to,
        input-output v-pct,
        input-output v-sum,
        input-output v-method,
        input-output v-vozvrat,
        input-output tt-create  ).
   if tt-create then do :
      create tt-bonus.
      assign
        tt-bonus.date-from = v-date-from
        tt-bonus.date-to   = v-date-to
        tt-bonus.pct       = v-pct
        tt-bonus.sum       = v-sum
        tt-bonus.method    = v-method
        tt-bonus.vozvrat   = v-vozvrat
      .
      v-rowid = rowid(tt-bonus).
      open query BROWSE-bonus for each tt-bonus.
      view BROWSE-bonus.
      reposition BROWSE-bonus to rowid v-rowid.
   end.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
   Get current BROWSE-bonus exclusive-lock.
   if not available tt-bonus then return no-apply.
   assign
     v-date-from = tt-bonus.date-from
     v-date-to   = tt-bonus.date-to
     v-pct       = tt-bonus.pct
     v-sum       = tt-bonus.sum
     v-method    = tt-bonus.method
     v-vozvrat   = tt-bonus.vozvrat
   .
   delete tt-bonus.
   run str\cont-bn1.w
      ( input parParentProc,
        input yes,
        input table tt-bonus,
        input-output v-date-from,
        input-output v-date-to,
        input-output v-pct,
        input-output v-sum,
        input-output v-method,
        input-output v-vozvrat,
        input-output tt-create  ).
   if tt-create then do :
      create tt-bonus.
      assign
        tt-bonus.date-from = v-date-from
        tt-bonus.date-to   = v-date-to
        tt-bonus.pct       = v-pct
        tt-bonus.sum       = v-sum
        tt-bonus.method    = v-method
        tt-bonus.vozvrat   = v-vozvrat
      .
      v-rowid = rowid(tt-bonus).
      open query BROWSE-bonus for each tt-bonus.
      view BROWSE-bonus.
      reposition BROWSE-bonus to rowid v-rowid.
   end.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
   if not available tt-bonus then return no-apply.
   MESSAGE "Вы уверены?"
   VIEW-AS ALERT-BOX QUESTION
   BUTTONS yes-no UPDATE continue-ok AS LOGICAL.
   IF continue-ok
     THEN DO:
      GET CURRENT browse-bonus exclusive-lock.
      DELETE tt-bonus.
      browse-bonus:DELETE-SELECTED-ROWS().
   END.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  for each tt-bonus :
    delete tt-bonus.
  end.
  define variable i as integer no-undo .
  do i = 1 to num-entries(p-retro-bonus, ';') - 1 :
     create tt-bonus.
     assign
        tt-bonus.date-from = date    (entry(1, entry(i, p-retro-bonus, ';')))
        tt-bonus.date-to   = date    (entry(2, entry(i, p-retro-bonus, ';')))
        tt-bonus.pct       = decimal (entry(3, entry(i, p-retro-bonus, ';')))
        tt-bonus.sum       = decimal (entry(4, entry(i, p-retro-bonus, ';')))
        tt-bonus.method    =         (entry(5, entry(i, p-retro-bonus, ';')))
        tt-bonus.vozvrat   = logical (entry(6, entry(i, p-retro-bonus, ';')))
     .
  end.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE b-exit b-quit BROWSE-bonus b-add b-chg b-del
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  open query BROWSE-bonus for each tt-bonus.
  view BROWSE-bonus.
END PROCEDURE.
