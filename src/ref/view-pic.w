&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v7r11 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME DLGCLOSE
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DLGCLOSE
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр картинки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/10/05
Author: Bakhtadze Natalya
Creation date: 06/10/05

Автор1: Перваков Михаил Сергеевич
Дата создания: 03/08/94

no_app_help.i
*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter PictName as char no-undo .
DEFINE INPUT PARAMETER p-extension AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER bttn AS CHARACTER NO-UNDO.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр картинки".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/img-frm.i }

/* Local Variable Definitions ---                                       */
define variable stat as log no-undo .
define variable v-param-type as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable v-descriptions as character no-undo .
define variable v-extensiond   as character no-undo .
define variable v-extensiont   as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DLGCLOSE

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_Close IMAGE-1 B-update b-help FILL-IN-1
&Scoped-Define DISPLAYED-OBJECTS FILL-IN-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1.

DEFINE BUTTON B-update
     LABEL "&Изменить"
     SIZE 10.5 BY 1.

DEFINE BUTTON Btn_Close AUTO-GO
     LABEL "&Выход ":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл"
      VIEW-AS TEXT
     SIZE 35.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE IMAGE IMAGE-1
     STRETCH-TO-FIT RETAIN-SHAPE
     SIZE 65.8 BY 16.77.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DLGCLOSE
     Btn_Close AT ROW 1 COL 1
     B-update AT ROW 1 COL 29
     b-help AT ROW 1 COL 57 WIDGET-ID 2
     FILL-IN-1 AT ROW 2.27 COL 15.5 COLON-ALIGNED
     IMAGE-1 AT ROW 3.77 COL 1
     SPACE(0.57) SKIP(0.33)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS THREE-D  SCROLLABLE
         BGCOLOR 8
         TITLE BGCOLOR 8 "":L
         DEFAULT-BUTTON Btn_Close.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DLGCLOSE
   FRAME-NAME UNDERLINE                                                 */
ASSIGN
       FRAME DLGCLOSE:SCROLLABLE       = FALSE
       FRAME DLGCLOSE:PRIVATE-DATA     =
                "DLGCLOSE".

ASSIGN
       Btn_Close:PRIVATE-DATA IN FRAME DLGCLOSE     =
                "Btn_Close".

ASSIGN
       IMAGE-1:RESIZABLE IN FRAME DLGCLOSE        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME B-update
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-update DLGCLOSE
ON CHOOSE OF B-update IN FRAME DLGCLOSE /* Изменить */
DO:
  DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
  DEFINE VARIABLE stat-chr AS CHARACTER NO-UNDO.
  DEFINE VARIABLE stat AS logical NO-UNDO.
  assign
  fill-in-1.
  run ref/photo-n.w ( input fill-in-1, input {&update} ) .
  IF RETURN-VALUE = "error" THEN RETURN NO-APPLY.
  assign
  stat-chr = search( return-value  )
  .
  if stat-chr = ? then do:
    return no-apply.
  end.
  fill-in-1 = stat-chr.
  stat = image-1:load-image("cmp/MATRIX-RELOADED.jpg") .
  stat = image-1:load-image( return-value ) .
  DISPLAY
  image-1
  fill-in-1
  WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DLGCLOSE


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    run adm/shattri.p (
        input "get":U
        ,input  ''
        ,input  0
        ,input  {&attr-images}
        ,input  {&attr-images_imgorder} /*p-param-code*/
        ,output v-image-order
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .

    delete object v-tth.
    if error-status:error
    or v-image-order = '':U then
    v-image-order = "jpg,bmp".
    run get-custom-img-order IN THIS-PROCEDURE(OUTPUT v-descriptions, OUTPUT v-extensiond, OUTPUT v-extensiont).

    stat = image-1:load-image( PictName + ".":U + p-extension) .
    FILL-IN-1 = PictName + ".":U + p-extension .
    run enable_UI in this-procedure .
    IF LOOKUP("b-update", bttn) = 0 THEN DO:
        DISABLE
        b-update
        WITH FRAME {&FRAME-NAME}.
    END.

    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DLGCLOSE  _DEFAULT-DISABLE
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
  HIDE FRAME DLGCLOSE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DLGCLOSE  _DEFAULT-ENABLE
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
  DISPLAY FILL-IN-1
      WITH FRAME DLGCLOSE.
  ENABLE Btn_Close IMAGE-1 B-update b-help FILL-IN-1
      WITH FRAME DLGCLOSE.
  {&OPEN-BROWSERS-IN-QUERY-DLGCLOSE}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
