&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_units FOR ub.units.
DEFINE TEMP-TABLE tt-units NO-UNDO LIKE ub.units.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка единицы измерени

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/16/03
Author: Bakhtadze Natalya
Creation date: 10/16/03


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-mode as character no-undo.
define input parameter p-unit-name like ub.units.unit-name no-undo.
define input-output parameter p-rid as recid init ? no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "карточка единицы измерения".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
&scop unit-type-code tt-units.type
define variable v-db-num like ub.db.db-num no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-units

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-units.long-name ~
tt-units.unit-name tt-units.OKEI
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-units.long-name ~
tt-units.unit-name tt-units.OKEI
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-units
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-units
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-units SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-units SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-units
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-units


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-units.long-name tt-units.unit-name ~
tt-units.OKEI
&Scoped-define ENABLED-TABLES tt-units
&Scoped-define FIRST-ENABLED-TABLE tt-units
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-hist B-Help UnitType ~
UnitType-2
&Scoped-Define DISPLAYED-FIELDS tt-units.long-name tt-units.unit-name ~
tt-units.OKEI
&Scoped-define DISPLAYED-TABLES tt-units
&Scoped-define FIRST-DISPLAYED-TABLE tt-units
&Scoped-Define DISPLAYED-OBJECTS UnitType UnitType-2

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE UnitType AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип"
     VIEW-AS COMBO-BOX INNER-LINES 1
     DROP-DOWN-LIST
     SIZE 25.75 BY 1 NO-UNDO.

DEFINE VARIABLE UnitType-2 AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип2"
     VIEW-AS COMBO-BOX INNER-LINES 1
     DROP-DOWN-LIST
     SIZE 25.75 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-units SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-hist AT ROW 1 COL 41
     B-Help AT ROW 1 COL 54.88
     tt-units.long-name AT ROW 2.42 COL 20 COLON-ALIGNED
          LABEL "Полное наименование"
          VIEW-AS FILL-IN
          SIZE 41 BY 1
     tt-units.unit-name AT ROW 3.75 COL 20 COLON-ALIGNED
          LABEL "Аббревиатура"
          VIEW-AS FILL-IN
          SIZE 8 BY 1
     UnitType AT ROW 3.75 COL 35.25 COLON-ALIGNED
     tt-units.OKEI AT ROW 5.33 COL 20 COLON-ALIGNED
          LABEL "ОКЕИ" format "9999"
          VIEW-AS FILL-IN 
          SIZE 5.5 BY 1
     UnitType-2 AT ROW 5.33 COL 35.25 COLON-ALIGNED
     SPACE(6.12) SKIP(1.17)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Единица измерения"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_units B "?" ? ub units
      TABLE: tt-units T "?" NO-UNDO ub units
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-units.long-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-units.OKEI IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-units.unit-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-units"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Единица измерения */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-undo.

      run ref/c-units.w (
                     INPUT parparentproc
                    ,INPUT '':U /*bttns*/
                    ,INPUT 'one':U
                    ,INPUT tt-units.unit-name
                    ,INPUT-OUTPUT v-rid-list) NO-ERROR.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME UnitType
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL UnitType Dialog-Frame
ON VALUE-CHANGED OF UnitType IN FRAME Dialog-Frame /* Тип */
DO:
    RUn RereadUnittype2(UnitType:screen-value).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
 if p-mode  <> {&add-def}
 and p-mode <> {&update}
 and p-mode <> {&lookup}
 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
 end.
 { gbl/curdbnum.i v-db-num }
 if p-mode <> {&lookup} then do:
    if v-db-num <> 0
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-mode - нельзя изменять/добавлять записи ЕД.ИЗМ в УБД"
      view-as alert-box ERROR.
      undo, return error.
    end.
  end.
  for each tt-units:
        delete tt-units.
    end.
  if p-mode = {&update}
  or p-mode = {&lookup} then do:
    if p-mode = {&update} then do:
      find first locked_units EXclusive-lock where
                   recid(locked_units) = p-rid no-wait no-error.
      if locked locked_units then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ЕД.ИЗМ. занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_units no-lock where
                       recid(locked_units) = p-rid no-error .
      if not avail locked_units then do:
        find first locked_units where
                  locKed_units.unit-name = p-unit-name no-error .
      end.
    end.
    if not available locked_units then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ЕД.ИЗМ."
      view-as alert-box error .
      undo, return error.
    end.
    create tt-units.
    buffer-copy locked_units to tt-units.
  end.
  else do:
    create tt-units.
  end.
  RUN MYenable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
session:data-entry-return = no .
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY UnitType UnitType-2
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-units THEN
    DISPLAY tt-units.long-name tt-units.unit-name tt-units.OKEI
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-hist B-Help tt-units.long-name tt-units.unit-name
         UnitType tt-units.OKEI UnitType-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
session:data-entry-return = yes .
UnitType:list-items in frame {&frame-name}
                                         = {&pieces-full} + {&comma-char} +
                      {&divisional-full} + {&comma-char} +
                      {&weight-full} + {&comma-char} +
                      {&serial-full} + {&comma-char} +
                      {&petrolium-full} + {&comma-char} +
                      {&bottle-full}
                      .
UnitType:INNER-LINES = num-entries (Unittype:list-items) .
UnitType:screen-value = entry (1, {&unit-types}) .
UnitType-2:INNER-LINES = num-entries ({&unit-types-toplivo} + {&comma-char} + {&twounit} + {&comma-char} + {&altunit}) .
UnitType-2:list-items = {&unit-types-toplivo} + {&comma-char} + {&twounit-full} + {&comma-char} + {&altunit-full}.

 DISPLAY
 UnitType
 UnitType-2
 WITH FRAME Dialog-Frame.
IF AVAILABLE tt-units THEN
    DISPLAY tt-units.long-name tt-units.unit-name tt-units.OKEI
      WITH FRAME Dialog-Frame.
  if p-mode = {&lookup} then do:
    assign
    b-exit:label = "&Выход".
  end.
  ENABLE
  B-exit when p-mode <> {&lookup}
  b-quit
  B-Help
  b-hist WHEN p-mode <> {&add-def}
  tt-units.long-name when p-mode <> {&lookup}
  tt-units.unit-name when p-mode = {&add-def}
  UnitType when p-mode <> {&lookup}
  UnitType-2 when p-mode = {&update} and num-entries(tt-units.type) > 1
  tt-units.OKEI
  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  IF p-mode = {&update} then do:
      RUn RereadUnittype2({&unit-type-name}).
      FRAME {&frame-name}:title = "Изменение единицы измерения".
      DISPLAY
      tt-units.long-name
      tt-units.OKEI
      tt-units.unit-name
      WITH frame {&frame-name}.
      UnitType:screen-value = {&unit-type-name} .
      if num-entries(tt-units.type) > 1 then
      UnitType-2:screen-value = entry (lookup (ENTRY(2, tt-units.type), {&unit-type-list}), {&unit-types}).
  end.
  else RUn RereadUnittype2(entry (1, {&unit-types})).
  if p-mode = {&lookup} then do:
    hide
    b-exit in frame {&frame-name} .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

assign
frame {&frame-name}
tt-units.long-name
tt-units.unit-name
UNITTYPE
UNITTYPE-2
tt-units.type = substring (UnitType, 1, 3) +
                    (IF UnitType-2:sensitive AND trim(Unittype-2) <> ""
                    then ({&comma-char} + substring (UnitType-2, 1, 3))
                    else "")
tt-units.OKEI
.
run ref/units01.p (
 input-output p-rid
,input p-mode
,input tt-units.OKEI
,input tt-units.long-name
,input tt-units.type
,input tt-units.unit-name
) no-error.

if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RereadUnittype2 Dialog-Frame
PROCEDURE RereadUnittype2 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER unittype1 as char no-undo.
    CASE unittype1:
      WHEN {&petrolium-full} then do:
          unittype-2:list-items in frame {&frame-name} = {&unit-types-toplivo}.
          enable
          UnitType-2
          WITH FRAME {&frame-name} .
          UnitType-2:screen-value = ENTRY(1, unittype-2:list-items).
      end.
      WHEN {&divisional-full} then do:
          unittype-2:list-items = {&comma-char} + {&twounit-full}.
          enable
          UnitType-2
          WITH FRAME {&frame-name}.
          UnitType-2:screen-value = ENTRY(1, unittype-2:list-items).
      end.
      WHEN {&twounit-full} then do:
          unittype-2:list-items = {&divisional-full}.
          enable
          UnitType-2
          WITH FRAME {&frame-name}.
          UnitType-2:screen-value = ENTRY(1, unittype-2:list-items).
      end.
      WHEN {&pieces-full} then do:
          unittype-2:list-items = {&comma-char} + {&altunit-full}.
          enable
          UnitType-2
          WITH FRAME {&frame-name}.
          UnitType-2:screen-value = ENTRY(1, unittype-2:list-items).
      end.
      WHEN {&bottle-full} then do:
          unittype-2:list-items = {&pieces-full}.
          enable
          UnitType-2
          WITH FRAME {&frame-name}.
          UnitType-2:screen-value = ENTRY(1, unittype-2:list-items).
      end.
      otherwise do:
          UnitType-2:screen-value = ENTRY(1, unittype-2:list-items).
          disable
          UnitType-2
          WITH FRAME {&frame-name}.
      end.
    END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME