&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Параметры расчета ретро-бонусов (редактирование)

Автор: Сливенко Сергей Андреевич
Дата создания: 09/14/11
Author: Sergey Slivenko
Creation date: 09/14/11

*/


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Параметры расчета ретро-бонусов (редактирование)".
{ cmp/vssrevis.i }



/* Parameters Definitions ---                                           */
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


/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit RECT-1 b-quit v-date-from v-date-to ~
v-pct v-sum v-method v-vozvrat
&Scoped-Define DISPLAYED-OBJECTS v-date-from v-date-to v-pct v-sum v-method ~
v-vozvrat

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
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


/* ************************  Frame Definitions  *********************** */

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


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Редактирование ретро-бонуса */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  assign v-date-from v-date-to v-pct v-sum v-method v-vozvrat .
  /*if not p-change then tt-create = true. else tt-create = false.*/

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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/ed_date.i v-date-from }
  { gbl/ed_date.i v-date-to }
  tt-create = false.
  assign date-from = p-date-from
         date-to   = p-date-to
         pct       = p-pct
         sum       = p-sum
         method    = p-method
         vozvrat   = p-vozvrat
  .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/

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
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME