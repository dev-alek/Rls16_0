&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w-login
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-login
/*

$Revision: 1f78fe327cdf, 1091, rls $
$Author: ASMorozov $
$Date: Thu Dec 14 02:13:52 2017 +0300 $
$Workfile: l-i-cash.w $
$Archive: adm/l-i-cash.w $

Окно входа в модуль Касса IBS Trade House

Автор: Белоусов Илья Александрович
Дата создания: 07/07/08
Author: Ilia Belousov
Creation date: 07/07/08

*/

/* ***************************  Definitions  ************************** */

define variable vss-revision    as character no-undo init "$Revision: 1f78fe327cdf, 1091, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:52 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: l-i-cash.w $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/l-i-cash.w $":U .
define variable vss-description as character no-undo init "Окно входа в модуль Касса IBS Trade House".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ adm/auto-def.i new }
{ gbl/eventlib.i }

define variable v-updating      as logical   no-undo init false .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE WINDOW
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME FRAME-A

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-OK IMAGE-1 b-quit name password FILL-IN-1 ~
FILL-IN-2
&Scoped-Define DISPLAYED-OBJECTS FILL-IN-1 FILL-IN-2

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w-login AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-OK AUTO-GO  NO-FOCUS
     LABEL "&Ввод":L
     SIZE 10 BY 1
     BGCOLOR 15 .

DEFINE BUTTON b-quit AUTO-END-KEY  NO-FOCUS
     LABEL "&Отмена":L
     SIZE 10 BY 1.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Имя:"
      VIEW-AS TEXT
     SIZE 5 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Пароль:"
      VIEW-AS TEXT
     SIZE 7.5 BY .67 NO-UNDO.

DEFINE VARIABLE name AS CHARACTER FORMAT "X(12)":U
     VIEW-AS FILL-IN
     SIZE 13.5 BY 1 NO-UNDO.

DEFINE VARIABLE password AS CHARACTER FORMAT "X(16)":U
     VIEW-AS FILL-IN
     SIZE 13.5 BY 1 NO-UNDO.

DEFINE VARIABLE password_display AS CHARACTER FORMAT "X(16)":U 
     LABEL "Пароль" 
     VIEW-AS FILL-IN 
     SIZE 20 BY 1 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "cmp/cashdesk.bmp":U
     STRETCH-TO-FIT RETAIN-SHAPE
     SIZE 13 BY 4.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME FRAME-A
     b-OK AT ROW 9.04 COL 5.75
     b-quit AT ROW 9.04 COL 15.75
     name AT ROW 5.79 COL 10.88 COLON-ALIGNED NO-LABEL
     password AT ROW 7 COL 10.88 COLON-ALIGNED NO-LABEL PASSWORD-FIELD
     password_display AT ROW 7 COL 10.88 COLON-ALIGNED  PASSWORD-FIELD 
     FILL-IN-1 AT ROW 5.96 COL 4.88 NO-LABEL
     FILL-IN-2 AT ROW 7.21 COL 4.88 NO-LABEL
     IMAGE-1 AT ROW 1.25 COL 9.5
    WITH 1 DOWN NO-BOX OVERLAY
         SIDE-LABELS THREE-D
         AT COL 1 ROW 1
         SIZE 29.88 BY 10.38.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: WINDOW
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW w-login ASSIGN
         HIDDEN             = YES
         TITLE              = "Касса TH 16.0"
         COLUMN             = 27
         ROW                = 7.58
         HEIGHT             = 10.38
         WIDTH              = 30
         MAX-HEIGHT         = 24.21
         MAX-WIDTH          = 100
         VIRTUAL-HEIGHT     = 24.21
         VIRTUAL-WIDTH      = 100
         RESIZE             = no
         SCROLL-BARS        = yes
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR FRAME FRAME-A
   FRAME-NAME UNDERLINE                                                 */
/* SETTINGS FOR BUTTON b-OK IN FRAME FRAME-A
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON b-quit IN FRAME FRAME-A
   NO-DISPLAY                                                           */
/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME FRAME-A
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-2 IN FRAME FRAME-A
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN name IN FRAME FRAME-A
   NO-DISPLAY                                                           */
/* SETTINGS FOR FILL-IN password IN FRAME FRAME-A
   NO-DISPLAY                                                           */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-login)
THEN w-login:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

/* ************************  Control Triggers  ************************ */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL password_display w-login
ON VALUE-CHANGED OF password_display IN FRAME FRAME-A DO:
    IF NOT v-updating THEN DO:
        ASSIGN password:SCREEN-VALUE = password_display:SCREEN-VALUE.
    END.
END.
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL password_display w-login
ON ANY-KEY OF password_display IN FRAME FRAME-A DO:
    IF LASTKEY = KEY-CODE("CTRL-V") THEN DO:
           ASSIGN 
           v-updating = TRUE
           password:SCREEN-VALUE = System.Windows.Forms.Clipboard:GetText()
           password_display:SCREEN-VALUE = System.Windows.Forms.Clipboard:GetText()
           v-updating = FALSE.
           System.Windows.Forms.Clipboard:Clear().
           RETURN NO-APPLY.
    END.
END.
&ANALYZE-RESUME





&Scoped-define SELF-NAME b-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-OK w-login
ON CHOOSE OF b-OK IN FRAME FRAME-A /* Ввод */
DO:
  if name :screen-value = ""
  then do:
    message
      "Введите имя пользователя"
      view-as alert-box information .
    apply "entry" to name .
    return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-login


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i &disable-button=yes }

on "ENTRY" of b-ok do:
  if lastkey = keycode ("RETURN") then do:
    apply "CHOOSE" to b-ok in frame {&frame-name}.
  end.
end.

on window-close of {&window-name} do:
  apply "end-error" to frame {&frame-name}.
end.

ASSIGN
  CURRENT-WINDOW             = {&WINDOW-NAME}
  SESSION:SYSTEM-ALERT-BOXES = (CURRENT-WINDOW:MESSAGE-AREA = NO)
  session:three-d = yes
.

PAUSE 0 BEFORE-HIDE.

if session:date-format <> "dmy":U
  or session:numeric-decimal-point <> ".":U
  or session:numeric-separator <> ",":U
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Неправильные установки сессии progress!" skip
    "Формат даты должен быть - " "'dmy'":U skip
    "Десятичный разделитель - " "'.'":U skip
    "Разделитель тысяч - " "','":U skip
    view-as alert-box error .
  quit.
end.

IMAGE-1 :load-image("cmp/cashdesk.bmp") .

enable
  name password password_display b-ok b-quit
  with frame {&frame-name} in window {&window-name} .
assign
  session :data-entry-return = yes
.

run gbl/font-chk.p no-error .
if error-status :error
then do:
  message
    "Неправильные установки системных шрифтов" skip
    "Обратитесь к администратору" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box information .
end.

do1:
do
on error  undo, leave
on endkey undo, leave
on stop   undo, leave
:
   run enable_ui in this-procedure .

   WAIT-FOR GO OF frame {&FRAME-NAME} focus name.

   assign
      name
      password
   .
   /*
   { gbl/eventlib-event-log.i
     2
      0
     '':U
     0
     '':U
     0
     '':U
     '':U
     0.0
     '':U
     0.0
     TODAY
     1
     TIME
     '':U
     0
     '':U
     0
     '':U
     '':U
     0.0
     ?
     '':U
     0
     '':U
     0.0
     name
   }
   */

   run adm/autoinit.p ( input name
                      , input password
                      ) no-error.

   if error-status :error then do:
      message
         "Ошибка инициализации переменных для системы автоматического запуска" skip
         return-value
         view-as alert-box error.
      leave do1.
   end.

   run adm/autoconn.p no-error.
   if error-status:error then do:
      message
         return-value
         view-as alert-box error.
      /*
      { gbl/eventlib-event-log.i
         1
            0
         '':U
         0
         '':U
         0
         '':U
         '':U
         0.0
         '':U
         0.0
         TODAY
         3
         TIME
         '':U
         0
         0
         '':U
         '':U
         0.0
         ?
         '':U
         0
         '':U
         0.0
         name
      }
      */

      leave do1.
   end.

   { gbl/eventlib-event-log.i
     1
     0
     '':U
     0
     '':U
     0
     '':U
     '':U
     0.0
     '':U
     0.0
     TODAY
     2
     TIME
     '':U
     0
     '':U
     0
     '':U
     '':U
     0.0
     ?
     '':U
     0
     '':U
     0.0
     name
   }


   RUN disable_UI.
   run gbl/cashmain.p ( input name
                      , input password
                      ) .
end. /* do1 */
/*
{ gbl/eventlib-event-log.i
   0
   v-cntxt-db-num
   '':U
   p-cash-num
   {&md}
   '':U
   '':U
   '*':U
   '':U
   '':U
   '':U
   TODAY
   91
   TIME
   U':U
   0
   v-cntxt-obj-type
   v-cntxt-obj-code
   '':U
   {&cd-type-ibs-th}
   0
   ?
   '':U
   0
   '':U
   0
   name
   NO-ERROR
}
*/

assign
  session :data-entry-return = no
.

run gbl/dbdiscon.p no-error.
quit. /* иначе будет после выхода из системы вылетать редактор */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ARM-users w-login
PROCEDURE ARM-users :
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w-login  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Delete the WINDOW we created */
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-login)
  THEN DELETE WIDGET w-login.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w-login  _DEFAULT-ENABLE
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
  DISPLAY FILL-IN-1 FILL-IN-2
      WITH FRAME FRAME-A IN WINDOW w-login.
  ENABLE b-OK IMAGE-1 b-quit name password password_display FILL-IN-1 FILL-IN-2
      WITH FRAME FRAME-A IN WINDOW w-login.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-A}
  VIEW w-login.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
