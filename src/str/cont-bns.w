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

Параметры расчета ретро-бонусов (договоры -> спецификации -> изменить ...)

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
define variable vss-description as character no-undo init "Параметры расчета ретро-бонусов".
{ cmp/vssrevis.i }

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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-bonus

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES contract-specif-attr tt-bonus

/* Definitions for BROWSE BROWSE-bonus                                  */
&Scoped-define FIELDS-IN-QUERY-BROWSE-bonus tt-bonus.date-from tt-bonus.date-to tt-bonus.pct tt-bonus.sum tt-bonus.method tt-bonus.vozvrat
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-bonus
&Scoped-define TABLES-IN-QUERY-BROWSE-bonus tt-bonus
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-bonus tt-bonus


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-bonus}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit BROWSE-bonus ~
b-add b-chg b-del
&Scoped-Define DISPLAYED-OBJECTS

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
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


/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-bonus FOR
      tt-bonus SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-bonus
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-bonus Dialog-Frame _STRUCTURED
  QUERY BROWSE-bonus NO-LOCK DISPLAY
      tt-bonus.date-from column-label "С":C10 format "99/99/9999"
      tt-bonus.date-to   column-label "По":C10 format "99/99/9999"
      tt-bonus.pct       column-label "%":C5 format ">>9.99<<"
      tt-bonus.sum       column-label "Сумма":C18 format ">>>>>>>>9.99<<"
      if tt-bonus.method = "vat-yes" then "Приход с НДС" else "Приход без НДС"    column-label "Метод":C23 format "X(15)"
      tt-bonus.vozvrat   column-label "Запрет! возвратов":C   format "yes/no"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 83 BY 7.45 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

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
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-bonus Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-bonus
/* Query rebuild information for BROWSE BROWSE-bonus
     _TblList          = "ub.contract-specif-attr"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   = ub.contract-specif-attr.attr-value
     _Query            is OPENED
*/  /* BROWSE BROWSE-bonus */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры расчета ретро-бонусов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define BROWSE-NAME BROWSE-bonus
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

  ENABLE b-exit b-quit BROWSE-bonus b-add b-chg b-del
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

  open query BROWSE-bonus for each tt-bonus.
  view BROWSE-bonus.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME