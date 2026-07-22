&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME DLGOKCAN
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DLGOKCAN
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отсутствие фото товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/05/06
Author: Bakhtadze Natalya
Creation date: 04/05/06

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define INPUT parameter PictName as char no-undo .
define INPUT parameter p-mode as char no-undo .

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отсутствие фото товара".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/r-pril.i NEW }
{ gbl/img-frm.i }

define variable v-descriptions as character no-undo .
define variable v-extensiond   as character no-undo .
define variable v-extensiont   as character no-undo .
DEFINE VARIABLE v-old-file     AS CHARACTER NO-UNDO.
define variable v-param-type as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME DLGOKCAN

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit IMAGE-new B-quit b-help B-file ~
F-image-name
&Scoped-Define DISPLAYED-OBJECTS F-image-name file-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-file
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "no"
     SIZE 3 BY 1.

DEFINE BUTTON b-help
     LABEL "&Помощь":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.

DEFINE VARIABLE F-image-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 78 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE file-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 77 BY .67 NO-UNDO.

DEFINE IMAGE IMAGE-new
     STRETCH-TO-FIT RETAIN-SHAPE
     SIZE 28.5 BY 7.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DLGOKCAN
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 41.5
     B-file AT ROW 7 COL 80.5
     F-image-name AT ROW 4 COL 3 NO-LABEL
     file-name AT ROW 7 COL 2 NO-LABEL
     "и соотв. расширением (.bmp, .jpg и т.д.) - кнопка ОТМЕНА" VIEW-AS TEXT
          SIZE 72.5 BY 1 AT ROW 5 COL 6
     "ИЛИ" VIEW-AS TEXT
          SIZE 5.5 BY 1 AT ROW 6 COL 3
          FGCOLOR 4
     "Если Вы сейчас вводите изображение, Вам следует сохранить его в файле с именем" VIEW-AS TEXT
          SIZE 82.5 BY 1 AT ROW 3 COL 3.5
     "выбрать уже имеющийся у Вас файл изображения для копирования - кнопка ENTER" VIEW-AS TEXT
          SIZE 76 BY 1 AT ROW 6 COL 8.5
     IMAGE-new AT ROW 8.75 COL 2.5
     SPACE(54.99) SKIP(0.41)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS THREE-D  SCROLLABLE
         BGCOLOR 8
         TITLE BGCOLOR 8 FGCOLOR 1 "":L
         DEFAULT-BUTTON B-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DLGOKCAN
   UNDERLINE                                                            */
ASSIGN
       FRAME DLGOKCAN:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN F-image-name IN FRAME DLGOKCAN
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN file-name IN FRAME DLGOKCAN
   NO-ENABLE ALIGN-L                                                    */
ASSIGN
       file-name:READ-ONLY IN FRAME DLGOKCAN        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit DLGOKCAN
ON CHOOSE OF B-exit IN FRAME DLGOKCAN /* Ввод */
DO:
  DEFINE VARIABLE err-status AS INTEGER NO-UNDO.
  DEFINE VARIABLE err-name AS character NO-UNDO.
  define variable v-full-path        as character no-undo .
  define variable v-path             as character no-undo .
  define variable v-file-name        as character no-undo .
  define variable v-file-name-no-ext as character no-undo .
  define variable v-file-name-ext    as character no-undo .
  define variable v-file-directory   as character no-undo .
  define variable vo-full-path        as character no-undo .
  define variable vo-path             as character no-undo .
  define variable vo-file-name        as character no-undo .
  define variable vo-file-name-no-ext as character no-undo .
  define variable vo-file-name-ext    as character no-undo .
  define variable vo-file-directory   as character no-undo .
  assign
  file-name.
  if file-name = '':U then do:
    message
    "Не задан файл"
    view-as alert-box error .
    return no-apply.
  end.

run gbl/filename.p (
                    input  FILE-NAME
                    ,output v-full-path
                    ,output v-path
                    ,output v-file-name
                    ,output v-file-name-no-ext
                    ,output v-file-name-ext
                    ) no-error .
if error-status:error then do:
  message
  substitute("Отсутствует или не найден файл &1", file-name)
  view-as alert-box error .
  return no-apply.
end.
IF p-mode = {&UPDATE} THEN DO:
    run gbl/filename.p (
                        input  v-old-file
                        ,output vo-full-path
                        ,output vo-path
                        ,output vo-file-name
                        ,output vo-file-name-no-ext
                        ,output vo-file-name-ext
                        ) no-error .
    IF ERROR-STATUS:ERROR THEN DO:

        RETURN NO-APPLY.
    END.
      IF v-full-path <> vo-full-path THEN DO:
          OS-DELETE VALUE(vo-full-path).
          err-status = OS-ERROR.
          IF err-status <> 0 THEN DO:
            run gbl/os-errnm.p (INPUT err-status, OUTPUT err-name).
            MESSAGE substitute("Ошибка при удалении старого файла изображения &1:&2&3"
                                , vo-full-path
                               , {&NEW-LINE}
                                , err-name) VIEW-AS ALERT-BOX.
            RETURN NO-APPLY.
          END.

      END.
  END.
  if p-mode = {&add-def} then do:
    OS-COPY VALUE(FILE-NAME) VALUE(Pictname + "." + v-file-name-ext).
  end.
  if p-mode = {&update} then do:
    OS-COPY VALUE(FILE-NAME) VALUE(vo-path + {&slash-char} + vo-file-name-no-ext + "." + v-file-name-ext ).
  end.
    err-status = OS-ERROR.
  IF err-status <> 0 THEN DO:
    run gbl/os-errnm.p (INPUT err-status, OUTPUT err-name).
  END.
  if p-mode = {&add-def} then do:
    RETURN (Pictname + ("." + v-file-name-ext) ).
  end.
  if p-mode = {&update} then do:
    RETURN (vo-path + {&slash-char} + vo-file-name-no-ext + "." + v-file-name-ext ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-file DLGOKCAN
ON CHOOSE OF B-file IN FRAME DLGOKCAN /* no */
DO:

DEFINE VARIABLE v_os-file   AS CHAR NO-UNDO INIT "".
DEFINE VARIABLE ll_commit AS LOG    NO-UNDO INIT NO.
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-file-directory   as character no-undo .
define variable v-choose           as LOGICAL   no-undo .
define variable stat               as LOGICAL   no-undo .
ASSIGN
FILE-NAME
v_os-file = FILE-NAME
.

run gbl/d-file.p (
 input-output v_os-file
,input-output v-file-directory
,input        v-descriptions
,input        v-extensiond
,input        {&delim-par}
,input        v-extensiont
,input        YES
,input        NO
,input        yes
,input        "Введите имя файла изображения"
,output       v-choose
).

IF v-choose <> YES THEN do:
       RETURN NO-APPLY.
end.
ASSIGN
file-name = ( IF SEARCH( v_os-file ) = ? THEN v_os-file ELSE SEARCH( v_os-file ) )
.
run gbl/filename.p (
                    input  v_os-file
                    ,output v-full-path
                    ,output v-path
                    ,output v-file-name
                    ,output v-file-name-no-ext
                    ,output v-file-name-ext
                    ) no-error .
if error-status:error  = ? then do:
  return no-apply.
end.

assign
file-name = v-full-path.
DISPLAY
file-name WITH FRAME {&FRAME-NAME}.
stat = image-new:load-image( FILE-NAME) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-quit DLGOKCAN
ON CHOOSE OF B-quit IN FRAME DLGOKCAN /* Отмена */
DO:
  RETURN "error".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME file-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL file-name DLGOKCAN
ON LEAVE OF file-name IN FRAME DLGOKCAN
DO:
    ASSIGN file-name.
    IF SEARCH( file-name ) <> ? AND SEARCH( file-name ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = file-name.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN file-name = FILE-INFO:FULL-PATHNAME.
        DISP file-name WITH FRAME {&FRAME-NAME}.
    END.
    APPLY "TAB":U TO file-name IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DLGOKCAN


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

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
  RUN get-custom-img-order IN THIS-PROCEDURE(OUTPUT v-descriptions, OUTPUT v-extensiond, OUTPUT v-extensiont).
  RUN Myenable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DLGOKCAN  _DEFAULT-DISABLE
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
  HIDE FRAME DLGOKCAN.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DLGOKCAN  _DEFAULT-ENABLE
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
  DISPLAY F-image-name file-name
      WITH FRAME DLGOKCAN.
  ENABLE B-exit IMAGE-new B-quit b-help B-file F-image-name
      WITH FRAME DLGOKCAN.
  {&OPEN-BROWSERS-IN-QUERY-DLGOKCAN}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable DLGOKCAN
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable stat AS LOGICAL NO-UNDO.
IF p-mode = {&add-def} THEN DO:
    F-image-name = PictName  + ".???".
END.
IF p-mode = {&UPDATE} THEN DO:
    v-old-file = PictName.
    F-image-name = PictName.
    stat = image-new:load-image( PictName)  IN FRAME {&FRAME-NAME}.
    DISPLAY image-new
    WITH FRAME {&FRAME-NAME}.
END.
DISPLAY
F-image-name
file-name
WITH FRAME {&frame-name}.
ENABLE
B-exit
image-new
B-quit
b-help
B-file
F-image-name
WITH FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME