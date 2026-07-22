&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*
         ! ! !  В Н И М А Н И Е  ! ! !
   не забудь: после исправления файла в UIB

   САМОЕ ГЛАВНОЕ - подставить new shared в DEFINE QUERY br-docs !!!!!!!
*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История сезонов и коллекций

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 10/31/03 1:51

*/
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "История сезонов и коллекций".
{ cmp/vssrevis.i }

define input parameter  parparentproc  as widget-handle no-undo.
define input parameter  par-sea-code   like ub.season.sea-code no-undo .
define input parameter  par-db-num     like ub.season.db-num no-undo .


/* Local Variable Definitions ---                                       */

{ cmp/trg-def.i }
{ cmp/showinf.i  }
{ gbl/flt-def.i }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ gbl/usrfulnf.i }
&Scoped-Define main-file ub.c-season

&scop col-l14 'Дата изменения'
&scop col-l16 'Время изменения '
&scop col-l17 'Изменение с БД №'
&scop col-l18 'Изменил'

&scop cop-l14 buf_c-season.corr-date
&scop cop-l16 string(buf_c-season.corr-time,'hh:mm:ss')
&scop cop-l17 buf_c-season.corr-user-db-num
&scop cop-l18 buf_c-season.corr-user-name
define variable del-type as character no-undo.
define variable deleted as logical no-undo init no.
DEFINE VARIABLE change-type as character init "" no-undo .


DEFINE NEW SHARED BUFFER buf_c-season FOR ub.c-season .

define temp-table temp-changes no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
index pi is unique primary
f_name.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-changes

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-changes buf_c-season ub.c-season

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE BR-docs                                       */
&Scoped-define FIELDS-IN-QUERY-BR-docs buf_c-season.chip-num buf_c-season.sea-name date-func(buf_c-season.sea-month-1) date-func(buf_c-season.sea-month-2) {&cop-l14} {&cop-l16} {&cop-l17} {&cop-l18} buf_c-season.sea-code buf_c-season.stts buf_c-season.List_
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-docs {&cop-l14}
&Scoped-define SELF-NAME BR-docs
&Scoped-define QUERY-STRING-BR-docs FOR EACH buf_c-season no-lock
&Scoped-define OPEN-QUERY-BR-docs OPEN QUERY {&SELF-NAME} FOR EACH buf_c-season no-lock.
&Scoped-define TABLES-IN-QUERY-BR-docs buf_c-season
&Scoped-define FIRST-TABLE-IN-QUERY-BR-docs buf_c-season


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-docs}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH ub.c-season SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH ub.c-season SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame ub.c-season
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame ub.c-season


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-Cancel B-Help BR-docs BR-changes mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD date-func d-type-tmp
FUNCTION date-func RETURNS DATE
( input date-int as int)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.

DEFINE QUERY BR-docs FOR
      buf_c-season SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      ub.c-season SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(25)"
      temp-changes.v_old COLUMn-LABEL "Было" format "X(35)"
      temp-changes.v_new COLUMn-LABEL "Стало" format "X(35)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 90.75 BY 11.5.

DEFINE BROWSE BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-docs Dialog-Frame _FREEFORM
  QUERY BR-docs DISPLAY
      buf_c-season.chip-num  format ">>>>>>>>>>9"
     buf_c-season.sea-name    format "x(40)"
     date-func(buf_c-season.sea-month-1) COLUMN-LABEL "с" FORMAT "99/99/99":U
     date-func(buf_c-season.sea-month-2) COLUMN-LABEL "по" FORMAT "99/99/99":U
     {&cop-l14}   COLUMN-LABEL {&col-l14}
     {&cop-l16}   COLUMN-LABEL {&col-l16}
     {&cop-l17}   COLUMN-LABEL {&col-l17} format ">>>>9"
     {&cop-l18}   COLUMN-LABEL {&col-l18}
     usrfulnf(buf_c-season.corr-user-name)  COLUMN-LABEL "кто менял! ФИО"
     buf_c-season.sea-code COLUMN-LABEL "Код"  format ">>>>>>>>>>>>>9"
     buf_c-season.stts        format ">"
     buf_c-season.List_
     enable {&cop-l14}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 90 BY 8.92.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-Cancel AT ROW 1 COL 1
     B-Help AT ROW 1 COL 81.5
     BR-docs AT ROW 2.21 COL 1.25
     BR-changes AT ROW 12 COL 1
     mark-num AT ROW 1 COL 14.88 NO-LABEL
     SPACE(70.87) SKIP(21.59)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История изменений сезонов/коллекций"
         CANCEL-BUTTON B-Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BR-docs B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes BR-docs Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       BR-docs:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 2.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-changes
/* Query rebuild information for BROWSE BR-changes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-changes */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-docs
/* Query rebuild information for BROWSE BR-docs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_c-season no-lock.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-docs */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.c-season"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История изменений сезонов/коллекций */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-docs
&Scoped-define SELF-NAME BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON VALUE-CHANGED OF BR-docs IN FRAME Dialog-Frame
DO:
if available buf_c-season then do:
   run proc-view-changes in this-procedure no-error.
END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-changes
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

{&cop-l14}:read-only in browse br-docs = true .

/* Нaзвание таблицы */
define variable p-file-label as character no-undo .


  run my-enable_ui in this-procedure .
  run openbr in this-procedure .
  hide mark-num in frame {&frame-name} .
  apply "VALUE-CHANGED" to br-docs in frame {&frame-name}.
  wait-for go of frame {&frame-name}.
END.
run disable_UI in this-procedure .

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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel B-Help BR-docs BR-changes mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable_UI Dialog-Frame
PROCEDURE my-enable_UI :
DISPLAY   mark-num
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel
         B-Help
         BR-docs
         BR-changes
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
OPEN QUERY BR-docs FOR EACH buf_c-season where
           buf_c-season.sea-code = par-sea-code and
           buf_c-season.db-num   = par-db-num
           no-lock.

APPLY "VALUE-CHANGED" TO br-docs in frame {&frame-name}.
APPLY "ENTRY" TO br-docs.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame
PROCEDURE proc-view-changes :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer new_c-season for ub.c-season.
define buffer current_season for ub.season.
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
for each temp-changes:
    delete temp-changes.
END.
if not available buf_c-season then do:
  Open QUery br-changes for each temp-changes.
  return.
end.

find first new_c-season no-lock where
           new_c-season.sea-code  = buf_c-season.sea-code
       and new_c-season.db-num    = buf_c-season.db-num
       AND new_c-season.chip-num  > buf_c-season.chip-num no-error.

if not available new_c-season then do:
    find first current_season no-lock where
               current_season.sea-code  = buf_c-season.sea-code and
               current_season.db-num    = buf_c-season.db-num no-error.
         if not available current_season then do:
         return error.
    end.
    buffer-compare current_season to buf_c-season
    save result in v-chg-fields.
end.
else do:
    buffer-compare new_c-season except chip-num corr-date corr-user-name corr-user-db-num to buf_c-season
    save result in v-chg-fields.
end.
&scop  disp-field ~
  when "~{&field-name~}":U then do: ~
    create temp-changes. ~
    assign ~
    temp-changes.f_name = "~{&field-name~}":U ~
    temp-changes.l_name = ~{&field-label~} ~
    temp-changes.v_old = string(buf_c-season.~{&field-name~}) ~
    temp-changes.v_new = (if available new_c-season  ~
                             then string(new_c-season.~{&field-name~})  ~
                             else string(current_season.~{&field-name~})) ~
    . ~
  end. ~


define variable v-nn as integer   no-undo .
v-nn = num-entries(v-chg-fields).
do ii = 1 to v-nn :
CASE entry(ii, v-chg-fields):

&scop field-name  List_
&scop field-label "Список"
{&disp-field}

&scop field-name  sea-code
&scop field-label "Код сезона"
{&disp-field}

&scop field-name  db-num
&scop field-label "БД"
{&disp-field}


&scop field-name  sea-month-1
&scop field-label "Месяц с"
{&disp-field}

&scop field-name  sea-month-2
&scop field-label "Месяц по"
{&disp-field}

&scop field-name  sea-name
&scop field-label "Наименование сезона/коллекции"
{&disp-field}

&scop field-name  stts
&scop field-label  "Статус (0-текущий)"
{&disp-field}

END CASE.
end.
Open QUery br-changes for each temp-changes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION date-func d-type-tmp
FUNCTION date-func RETURNS DATE
( input date-int as int) :
 define variable date-res as date no-undo.
   if  date-int <= 12 then return error.
   assign date-res = date (date-int) no-error.
 RETURN date-res.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME