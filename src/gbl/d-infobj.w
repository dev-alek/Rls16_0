&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Информация об объекте интерфейса

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

АвторFirst: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER h-widget AS HANDLE NO-UNDO .

{ cmp/str-glbl.i }
{ cmp/showinf.i  }

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Информация об объекте интерфейса".
{ cmp/vssrevis.i }

def var v-attrib-name as character no-undo .

define temp-table widget-attributes no-undo
  field attrib-name      as character format "x(40)"  label "Атрибут"
  field attrib-value     as character format "x(40)"  label "Значение"
  field attrib-type      as character format "x(1)"   label "T"
  field attrib-can-query as logical   format "+/-"    label "R"
  field attrib-can-set   as logical   format "+/-"    label "W"
  field attrib-order     as integer

  index xpk is primary unique attrib-name
  index xie attrib-order
.

define variable v-total-num as integer   no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME b-widget-value

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES widget-attributes

/* Definitions for BROWSE b-widget-value                                */
&Scoped-define FIELDS-IN-QUERY-b-widget-value attrib-name attrib-type attrib-can-query attrib-can-set attrib-value
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-widget-value
&Scoped-define SELF-NAME b-widget-value
&Scoped-define OPEN-QUERY-b-widget-value /* OPEN QUERY {&SELF-NAME} FOR EACH widget-attributes . */ run init-widget-attributes .
&Scoped-define TABLES-IN-QUERY-b-widget-value widget-attributes
&Scoped-define FIRST-TABLE-IN-QUERY-b-widget-value widget-attributes


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-b-widget-value}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-help b-widget-value

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 FONT 0.

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 FONT 0.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b-widget-value FOR
      widget-attributes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b-widget-value
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-widget-value Dialog-Frame _FREEFORM
  QUERY b-widget-value DISPLAY
      attrib-name
      attrib-type
      attrib-can-query
      attrib-can-set
      attrib-value
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 82.5 BY 16.25
         BGCOLOR 15  ROW-HEIGHT-CHARS .76.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-help AT ROW 1 COL 11
     b-widget-value AT ROW 2.21 COL 1
     SPACE(0.12) SKIP(0.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Interface Object Information".


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
   FRAME-NAME                                                           */
/* BROWSE-TAB b-widget-value b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-widget-value:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-widget-value
/* Query rebuild information for BROWSE b-widget-value
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH widget-attributes . */
run init-widget-attributes .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b-widget-value */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Interface Object Information */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-widget-value
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

if not valid-handle (h-widget) then do:
  message
    "Передан указатель на несуществующий объект" skip
    "h-widget" h-widget skip
    view-as alert-box .
  undo, return error .
end.

run init-widget-attributes .

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-attrib-by-list Dialog-Frame 
PROCEDURE create-attrib-by-list :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-attrib-list as character no-undo .

  define variable v-ind                     as integer   no-undo .
  define variable v-num-entries-attrib-list as integer   no-undo .

  assign
    v-num-entries-attrib-list = num-entries(p-attrib-list)
  .

  do v-ind = 1 to v-num-entries-attrib-list
  :
    def var v-attr-name as character no-undo .
    assign
      v-attr-name = entry(v-ind, p-attrib-list)
    .
    find first widget-attributes
      where widget-attributes.attrib-name = v-attr-name
      no-error .
    if not available widget-attributes then do:
      assign
        v-total-num = v-total-num + 1
      .

      create widget-attributes .
      assign
        widget-attributes.attrib-name  = v-attr-name
        widget-attributes.attrib-order = v-total-num
      .
      run gbl/prgsattr.p
        (input  widget-attributes.attrib-name /* p-attribute-name */
        ,output widget-attributes.attrib-type /* p-attribute-type */
        ) .
    end.

    if can-query(h-widget, v-attr-name) then do:
      assign
        widget-attributes.attrib-can-query = true
      .
      if widget-attributes.attrib-type <> "" then do:
        run get-widget-value
          (input  h-widget                       /* p-widget-handle */
          ,input  widget-attributes.attrib-name  /* p-attrib-name   */
          ,output widget-attributes.attrib-value /* p-attrib-value  */
          ) no-error .
      end.
    end.

    if can-set(h-widget, v-attr-name) then do:
      assign
        widget-attributes.attrib-can-set = true
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  ENABLE b-exit b-help b-widget-value 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-widget-value Dialog-Frame 
PROCEDURE get-widget-value :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-widget-handle as handle no-undo .
  define input  parameter p-attrib-name   as character no-undo .
  define output parameter p-attrib-value  as character no-undo .


  do
  on stop undo, return error
  :
    run cmp/widgattr.p
      (input  p-widget-handle
      ,output p-attrib-value
      )
      p-attrib-name
      .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-widget-attributes Dialog-Frame 
PROCEDURE init-widget-attributes :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  define variable v-sel-attr as character no-undo .

  if available widget-attributes then do:
    assign
      v-sel-attr = widget-attributes.attrib-name
    .
  end.
  else do:
    assign
      v-sel-attr = ""
    .
  end.

  for each widget-attributes
  on error undo, return error
  :
    delete widget-attributes .
  end.
  assign
    v-total-num = 0
  .

/*  assign*/
/*    v-attrib-list = "HANDLE,TYPE,DBNAME,TABLE,NAME,DATA-TYPE,FORMAT,LABEL,LABELS,FRAME-NAME,WIDTH-CHARS,HEIGHT-CHARS,MODIFIED,HANDLE,SENSITIVE,VISIBLE,COLUMN,ROW,PRIVATE-DATA"*/
/*  .*/

  run create-attrib-by-list in this-procedure
    (input list-query-attrs(h-widget)
    ) .

  run create-attrib-by-list in this-procedure
    (input list-set-attrs(h-widget)
    ) .

  open query {&browse-name} for each widget-attributes by attrib-name .

  if v-sel-attr <> "" then do:
    define buffer buf_widget-attributes for widget-attributes .
    find first buf_widget-attributes no-lock
      where buf_widget-attributes.attrib-name = v-sel-attr
      no-error .
    if available buf_widget-attributes then do:
      if available buf_widget-attributes then do:
        reposition {&browse-name} to rowid rowid(buf_widget-attributes) .
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

