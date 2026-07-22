&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w-login
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-login 
/*

$Revision: d3f7ea4aa09e, 3307, rls $
$Author: DRuban $
$Date: 2023/05/19 13:37:07 $
$Workfile: l-i-auto.w $
$Archive: adm/l-i-auto.w $

Запуск и отслеживание автозаданий

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/02
Author: Dmitry Ukhanov
Creation date: 03/22/02

*/

/* ***************************  Definitions  ************************** */

def var vss-revision    as character no-undo init "$Revision: d3f7ea4aa09e, 3307, rls $":U .
def var vss-author      as character no-undo init "$Author: DRuban $":U .
def var vss-date        as character no-undo init "$Date: 2023/05/19 13:37:07 $":U .
def var vss-workfile    as character no-undo init "$Workfile: l-i-auto.w $":U .
def var vss-archive     as character no-undo init "$Archive: adm/l-i-auto.w $":U .
def var vss-description as character no-undo init "Запуск и отслеживание автозаданий".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ adm/auto-def.i new }

define variable v-mode-hidden        as logical   no-undo .
define variable v-no-message         as logical   no-undo .
define variable v-preconnection      as logical   no-undo .
define variable v-connection         as logical   no-undo .
define variable v-param              as character no-undo .
define variable ind                  as integer   no-undo .
define variable v-num-entries        as integer   no-undo .
define variable v-db-info            as character no-undo .
define variable v-db-num             as integer   no-undo .
define variable v-updating          as logical   no-undo init false .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE WINDOW
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME FRAME-A

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS name password b-OK b-quit 
&Scoped-Define DISPLAYED-OBJECTS name password 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w-login AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-OK AUTO-GO DEFAULT 
     LABEL "&Ввод":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT 
     LABEL "&Отмена":L 
     SIZE 10 BY 1.

DEFINE VARIABLE name AS CHARACTER FORMAT "X(12)":U 
     LABEL "Логин" 
     VIEW-AS FILL-IN 
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE password AS CHARACTER FORMAT "X(16)":U 
     LABEL "Пароль" 
     VIEW-AS FILL-IN 
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE password_display AS CHARACTER FORMAT "X(16)":U 
     LABEL "Пароль" 
     VIEW-AS FILL-IN 
     SIZE 20 BY 1 NO-UNDO.


DEFINE IMAGE IMAGE-1
     FILENAME "cmp/ith.bmp":U
     SIZE 40 BY 8.88.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME FRAME-A
     name AT ROW 4.96 COL 10 COLON-ALIGNED
     password AT ROW 6.17 COL 10 COLON-ALIGNED BLANK 
     password_display AT ROW 6.17 COL 10 COLON-ALIGNED  PASSWORD-FIELD 
     b-OK AT ROW 8 COL 11.75
     b-quit AT ROW 8 COL 21.88
     IMAGE-1 AT ROW 1.08 COL 1.13
    WITH 1 DOWN NO-BOX OVERLAY 
         SIDE-LABELS THREE-D 
         AT COL 1 ROW 1
         SIZE 40.13 BY 8.96.


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
         TITLE              = "TH САЗП"
         COLUMN             = 27
         ROW                = 7.58
         HEIGHT             = 9.13
         WIDTH              = 40.25
         MAX-HEIGHT         = 35.63
         MAX-WIDTH          = 160
         VIRTUAL-HEIGHT     = 35.63
         VIRTUAL-WIDTH      = 160
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
ASSIGN 
       FRAME FRAME-A:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-OK IN FRAME FRAME-A
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON b-quit IN FRAME FRAME-A
   NO-DISPLAY                                                           */
/* SETTINGS FOR IMAGE IMAGE-1 IN FRAME FRAME-A
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-login)
THEN w-login:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

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



/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME FRAME-A
/* Query rebuild information for FRAME FRAME-A
     _Query            is NOT OPENED
*/  /* FRAME FRAME-A */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-OK w-login
ON CHOOSE OF b-OK IN FRAME FRAME-A /* Ввод */
DO:
  if name :screen-value = "" then do:
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

{ cmp/showinf.i }


on "ENTRY" of b-ok do:
  if lastkey = keycode ("RETURN") then apply "CHOOSE" to b-ok in frame {&frame-name}.
end.

on window-close of {&window-name} do:
  apply "end-error" to frame {&frame-name}.
end.

ASSIGN CURRENT-WINDOW             = {&WINDOW-NAME}
    SESSION:SYSTEM-ALERT-BOXES = (CURRENT-WINDOW:MESSAGE-AREA = NO).
    session:three-d = yes.
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

assign
  v-preconnection = false
  name            = "":U
  password        = "":U
  v-mode-hidden   = false
  v-no-message    = false
.

if SESSION:PARAMETER <> "":U
  and SESSION:PARAMETER <> ?
then do:
  assign
    v-num-entries = num-entries( SESSION:PARAMETER, ";":U )
  .
  do ind = 1 to v-num-entries :
    assign
      v-param = entry( ind, SESSION:PARAMETER, ";":U )
    .
    if num-entries( v-param, ":":U ) = 2 then do:
      if v-param begins "U:" then do:
        assign
          name = entry( 2, v-param, ":":U )
        .
      end.
      if v-param begins "P:" then do:
        assign
          password = entry( 2, v-param, ":":U )
        .
      end.
    end.
    else do:
      if v-param begins "H" then do: /* запуск невидимых окон */
        assign
          v-mode-hidden = true
        .
      end.
      if v-param begins "NM" then do: /* не выдавать сообщений */
        assign
          v-no-message = true
        .
      end.
    end.
  end.
  if name <> "":U
    and password <> "":U
  then do:
    run adm/autoinit.p
      ( input name
       ,input password
      ) no-error.
    run adm/autoconn.p no-error.
    if error-status :error then do:
      assign
        password = "":U
      .
    end.
    else do:
      assign
        v-preconnection = TRUE
      .
    end.
    run gbl/dbdiscon.p no-error.
  end.
end.

if v-preconnection = FALSE then do:
  run enable_UI.
end.

assign
  session :data-entry-return = yes
.

run gbl/font-chk.p no-error .
if error-status :error
  and v-no-message = false
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Неправильные установки системных шрифтов" skip
    "Обратитесь к администратору" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box information .
end.

do1:
do
on error  undo, leave do1
on endkey undo, leave do1
on stop   undo, leave do1
:
  if v-preconnection = FALSE then do:
    WAIT-FOR GO OF frame {&FRAME-NAME} focus name.
  end.
  assign
    name
    password
    v-connection = FALSE
  .
  run adm/autoinit.p
    ( input name
    , input password
    ) no-error.
  if error-status :error then do:
    if v-no-message = false then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка инициализации переменных для системы автоматического запуска" skip
        return-value
        view-as alert-box error.
    end.
    leave do1.
  end.
  run adm/autoconn.p no-error.
  if error-status:error then do:
    if v-no-message = false then do:
      message
        vss-workfile vss-revision vss-description skip
        return-value
        view-as alert-box error.
    end.
    leave do1.
  end.
  run adm/db-info.p ( output v-db-num, output v-db-info ) no-error.
  if error-status :error then do:
    if v-no-message = false then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute("Ошибка при считывании информации о текущей БД.") skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    leave do1.
  end.

  v-connection = TRUE.
  run gbl/dbdiscon.p no-error.
end.  /* do1:  on endkey ... */
assign
  session :data-entry-return = no
.
RUN disable_UI.

/* --------------------- Если произошло подключение к базе данных --------------------- */
if v-connection
  and not error-status:error
then do:
  do2:
  do
  on error  undo, leave do2
  on endkey undo, leave do2
  on stop   undo, leave do2
  :
    run adm/auto-st.w
      ( input v-db-info
      , input v-mode-hidden
      , input v-no-message
      ) no-error.
  end.
end.
run gbl/dbdiscon.p no-error.
quit. /* иначе будет после выхода из системы вылетать редактор */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

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
  DISPLAY name password password_display
      WITH FRAME FRAME-A IN WINDOW w-login.
  ENABLE name password password_display b-OK b-quit 
      WITH FRAME FRAME-A IN WINDOW w-login.
  VIEW FRAME FRAME-A IN WINDOW w-login.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-A}
  VIEW w-login.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

