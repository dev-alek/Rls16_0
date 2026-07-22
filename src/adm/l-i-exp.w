&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w-login
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-login 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Окно входа в САЭ

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 04/12/06
Author: Victor Guntner
Creation date: 04/12/06

Input:

Output:

*/
/* ***************************  Definitions  ************************** */

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Окно входа в САЭ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ adm/auto-def.i new }

define variable v-preconnection as logical   no-undo .
define variable v-connection    as logical   no-undo .
define variable v-param         as character no-undo .
define variable v-param-name    as character no-undo .
define variable v-param-value   as character no-undo .
define variable ind             as integer   no-undo .
define variable v-num-entries   as integer   no-undo .
define variable v-par-val       as character no-undo .
define variable v-par-type      as character no-undo .
define variable v-mode          as character no-undo .
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
&Scoped-Define ENABLED-OBJECTS IMAGE-1 name password b-quit b-OK 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w-login AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-OK AUTO-GO 
     LABEL "&Ввод":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
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
     password_display AT ROW 6.17 COL 10 COLON-ALIGNED PASSWORD-FIELD 
     b-quit AT ROW 8 COL 21.88
     b-OK AT ROW 8.04 COL 11.75
     IMAGE-1 AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX OVERLAY 
         SIDE-LABELS THREE-D 
         AT COL 1 ROW 1
         SIZE 40 BY 8.96.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: WINDOW
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U and not session:batch-mode THEN
  CREATE WINDOW w-login ASSIGN
         HIDDEN             = YES
         TITLE              = "TH САЭ"
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
/* SETTINGS FOR BUTTON b-OK IN FRAME FRAME-A
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON b-quit IN FRAME FRAME-A
   NO-DISPLAY                                                           */
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

if valid-handle({&window-name}) then
do:
on window-close of {&window-name} do:
  apply "end-error" to frame {&frame-name}.
end.

ASSIGN CURRENT-WINDOW             = {&WINDOW-NAME}
    SESSION:SYSTEM-ALERT-BOXES = (CURRENT-WINDOW:MESSAGE-AREA = NO).
    session:three-d = yes.
end.
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
  v-preconnection = FALSE
  name            = "":U
  password        = "":U
.

if SESSION:PARAMETER <> "":U
  and SESSION:PARAMETER <> ?
then do:
  assign
    v-num-entries = num-entries( SESSION:PARAMETER, ",":U )
  .
  do ind = 1 to v-num-entries :
    assign
      v-param = entry( ind, SESSION:PARAMETER, ",":U )
    .
    if num-entries( v-param, ":":U ) > 1 then do:
      assign
        v-param-name  = entry( 1, v-param, ":":U )
        v-param-value = substring( v-param, length( v-param-name ) + 2 )
      .
      case v-param-name :
        when "U":U then do:
          assign
            name = v-param-value
          .
        end.
        when "P":U then do:
          assign
            password = v-param-value
          .
        end.
        when "M":U then do:
          assign
            v-mode = replace( v-param-value, {&delim-par}, ",":U )
          .
        end.
        when "A":U then .
        otherwise do:
          message
            substitute("Неизвестный параметр сессии СПН: &1", v-param) skip
            substitute("Параметр игнорируется.") skip
            view-as alert-box information .
        end.
      end case.
    end.
    else do:
      message
        substitute("Неизвестный параметр сессии СПН: &1", v-param) skip
        substitute("Параметр игнорируется.") skip
        view-as alert-box information .
    end.
  end.
  if name <> "":U
    and password <> "":U
  then do:
    run adm/autoinit.p ( input name
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
if error-status :error then do:
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
on error  undo, leave
on endkey undo, leave
on stop   undo, leave
:
  if v-preconnection = FALSE then do:
    WAIT-FOR GO OF frame {&FRAME-NAME} focus name.
  end.
  assign
    name
    password
    v-connection = FALSE
  .
  run adm/autoinit.p ( input name
                  ,input password
                 ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка инициализации переменных для системы автоматического запуска" skip
      return-value
      view-as alert-box error.
    leave do1.
  end.

  run adm/autoconn.p no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      return-value
      view-as alert-box error.
    leave do1.
  end.
  
  run gbl/conf-rd.p ("is-bge":U, "":U, "":U, 0, "":U, "":U, "":U, yes, output v-par-val, output v-par-type) no-error.
  if error-status:error
     or v-par-type <> "L":U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка чтения конфигурационного параметра is-bge!"
      view-as alert-box error.
    leave do1.
  end.
  if v-par-val <> "yes" then do:
    message
      vss-workfile vss-revision vss-description skip
      "В вашей системе запрещено работать с системой автоматического экспорта!" skip
      "(конфигурационный параметр is-bge)"
      view-as alert-box error.
    leave do1.
  end.
  assign
    v-connection = TRUE
  .

  run gbl/dbdiscon.p no-error.
end.  /* do1:  on endkey ... */
assign
  session :data-entry-return = no
.
RUN disable_UI.

/* --------------------- Если произошло подключение к базе данных --------------------- */
if v-connection
  and not error-status:error then do:
  assign
    log-file-name = "ext-exp.log"
  .
  run adm/automain.w
    ( input {&btpr-type-autoexp}
     ,input v-mode
    ) no-error.
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
  ENABLE IMAGE-1 name password password_display b-quit b-OK 
      WITH FRAME FRAME-A IN WINDOW w-login.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-A}
  VIEW w-login.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

