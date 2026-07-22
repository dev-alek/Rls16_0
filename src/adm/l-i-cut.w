&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w-login
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-login 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 03/02/20 - 10:54 am

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
{cmp\str-glbl.i }
/* Local Variable Definitions ---                                       */
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
&Scoped-Define ENABLED-OBJECTS b-OK f-ub name password b-quit f-dst 
&Scoped-Define DISPLAYED-OBJECTS f-ub f-dst 

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

DEFINE VARIABLE f-dst AS CHARACTER FORMAT "X(1000)":U INITIAL "-db c:\baza\16_etalon\ub -ld dst -1 -U sysadm -P sysadm -i " 
     LABEL "DST" 
     VIEW-AS FILL-IN 
     SIZE 59 BY 1 NO-UNDO.

DEFINE VARIABLE f-ub AS CHARACTER FORMAT "X(256)":U INITIAL "-db c:\baza\16_TBD\ub -ld ub -1" 
     LABEL "UB" 
     VIEW-AS FILL-IN 
     SIZE 59 BY 1 NO-UNDO.

DEFINE VARIABLE name AS CHARACTER FORMAT "X(12)":U INITIAL "адм" 
     LABEL "Логин" 
     VIEW-AS FILL-IN 
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE password AS CHARACTER FORMAT "X(16)":U INITIAL "адм" 
     LABEL "Пароль" 
     VIEW-AS FILL-IN 
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE password_display AS CHARACTER FORMAT "X(16)":U INITIAL "адм" 
     LABEL "Пароль" 
     VIEW-AS FILL-IN 
     SIZE 20 BY 1 NO-UNDO.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME FRAME-A
     b-OK AT ROW 7 COL 12
     f-ub AT ROW 2 COL 10 COLON-ALIGNED WIDGET-ID 2
     name AT ROW 3.25 COL 10 COLON-ALIGNED
     password AT ROW 4.5 COL 10 COLON-ALIGNED PASSWORD-FIELD 
     password_display AT ROW 4.5 COL 10 COLON-ALIGNED PASSWORD-FIELD 
     b-quit AT ROW 7 COL 22.5
     f-dst AT ROW 5.75 COL 10 COLON-ALIGNED WIDGET-ID 6
    WITH 1 DOWN NO-BOX OVERLAY 
         SIDE-LABELS THREE-D 
         AT COL 1 ROW 1
         SIZE 72.63 BY 7.58.


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
         TITLE              = "Trade House 15.0"
         COLUMN             = 27
         ROW                = 7.58
         HEIGHT             = 7.75
         WIDTH              = 72.63
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
    "Неправильные установки сессии progress!" skip
    "Формат даты должен быть - " "'dmy'":U skip
    "Десятичный разделитель - " "'.'":U skip
    "Разделитель тысяч - " "','":U skip
    view-as alert-box error .
  quit.
end.



enable
  name password_display b-ok b-quit
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
  if lookup( '.', propath) > 0
  then do:
    /* если в пути присутствует текущая директория, */
    /* то определяем её абсолютный путь */
    /* и заменяем символ точка в Propath на абсолютный путь текущей директории */
    /* это делается для того, чтобы в случае когда изменитcя текущая директория */
    /* *.r коды, которые там находились продолжали бы выполняться */

    define variable v-home-directory as character no-undo .
    define variable v-ind as integer   no-undo .
    define variable v-num-entries-propath as integer   no-undo .
    define variable v-old-propath         as character no-undo .
    define variable v-new-propath         as character no-undo .
    define variable v-path-item           as character no-undo .

    assign
      file-info :file-name = '.'
      v-home-directory = file-info :full-pathname
    .

    assign
      v-old-propath = propath
      v-new-propath = ''
    .
    assign
      v-num-entries-propath = num-entries(v-old-propath)
    .

    do v-ind = 1 to v-num-entries-propath
    :
      assign
        v-path-item = entry(v-ind, v-old-propath)
      .
      if v-path-item = '.'
      then do:
        assign
          v-path-item = v-home-directory
        .
      end.
      assign
        v-new-propath = v-new-propath
                      + (if v-new-propath <> '' then ',' else '')
                      + v-path-item
      .
    end.

    assign
      propath = v-new-propath
    .
  end.

  run enable_ui in this-procedure .

  WAIT-FOR GO OF frame {&FRAME-NAME} focus name.
  assign
    f-ub
    name
    password 
    f-dst .
  def vAR  v-cConnect AS CHAR NO-UNDO.
  DEF VAR v-try-connect AS logical no-undo.
  
  define variable v-user-entered      as logical   no-undo init false .
  assign
    v-cConnect = f-ub  
               + (if     name ne "" 
                     and name ne ?
                  then " &1 "
                  else " ")
               
    v-try-connect = true
  .
  run gbl/dbconnnodisc.p
    (input v-cConnect
    ,input ? /* v-fltConnect */
    ,input name
    ,input password
    ,input-output v-user-entered
    ) no-error.
  if error-status:error
  then do:
     message return-value view-as alert-box.
     quit.
  end.
   
  if userid('{&db-name_schema}':U) = '':U
  then do:
    message
      "Ошибка при подключении к базе данных" skip
      "Неизвестный пользователь" skip
      view-as alert-box error .
    disconnect ub no-error .
    quit.
  end.
   run gbl/dbconnnodisc.p
    (input f-dst
    ,input ? /* v-fltConnect */
    ,input name
    ,input password
    ,input-output v-user-entered
    ) no-error.
  if error-status:error
  then do:
     message return-value view-as alert-box.
    disconnect ub no-error .
     quit.
  end.
  
  if userid('dst':U) = '':U
  then do:
    message
      "Ошибка при подключении к базе данных" skip
      "Неизвестный пользователь" skip
      view-as alert-box error .
    disconnect ub no-error .
    quit.
  end.

end.
assign
  session :data-entry-return = no
.
RUN disable_UI.

/* --------------------- Если произошло подключение к базе данных --------------------- */
if v-user-entered
then
DO2:
do
:
  RUN UTL\CUT-LOAD.W  no-error.
   
  
end.
else do:
  if v-try-connect = true
  then do:
     if error-status :error then do:
        message
           "Ошибка при подключении к БД" skip
           error-status :get-message(1) skip
           return-value skip
           view-as alert-box error .
        disconnect ub no-error .
        quit.
     end.
     ELSE DO:
        message
           "Ошибка при подключении к базе данных" skip
           "Обратитесь к администратору" skip
           "Строка подключения к БД:" skip
           v-cConnect skip
           view-as alert-box error .
     end.
  end.
end.
disconnect ub no-error .
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
  DISPLAY f-ub f-dst 
      WITH FRAME FRAME-A IN WINDOW w-login.
  ENABLE b-OK f-ub name password_display b-quit f-dst 
      WITH FRAME FRAME-A IN WINDOW w-login.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-A}
  VIEW w-login.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

