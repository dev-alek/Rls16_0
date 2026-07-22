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
{ cmp/trg-def.i new }
/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
define variable v-updating      as logical   no-undo init false .
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE WINDOW
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME FRAME-A

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-OK f-ub name b-quit password f-date ~
log-edit 
&Scoped-Define DISPLAYED-OBJECTS f-ub f-date log-edit 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w-login AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-OK  NO-FOCUS
     LABEL "&Очистить":L 
     SIZE 13 BY 1
     BGCOLOR 15 .

DEFINE BUTTON b-quit AUTO-END-KEY  NO-FOCUS
     LABEL "&Закрыть":L 
     SIZE 12.4 BY 1.

DEFINE VARIABLE log-edit AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 69 BY 5.24 NO-UNDO.

DEFINE VARIABLE f-date AS DATE FORMAT "99/99/9999":U 
     LABEL "Дата" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 TOOLTIP "Дата актуальности документов" NO-UNDO.

DEFINE VARIABLE f-ub AS CHARACTER FORMAT "X(256)":U INITIAL "-db ub -ld ub -H ... -S ..." 
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

DEFINE VARIABLE password_display AS CHARACTER FORMAT "X(16)":U 
     LABEL "Пароль" 
     VIEW-AS FILL-IN 
     SIZE 20 BY 1 NO-UNDO.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME FRAME-A
     b-OK AT ROW 7.19 COL 12
     f-ub AT ROW 2 COL 10 COLON-ALIGNED WIDGET-ID 2
     name AT ROW 3.24 COL 10 COLON-ALIGNED
     b-quit AT ROW 7.19 COL 25
     password AT ROW 4.52 COL 10 COLON-ALIGNED PASSWORD-FIELD 
     password_display AT ROW 4.52 COL 10 COLON-ALIGNED PASSWORD-FIELD 
     f-date AT ROW 5.81 COL 10 COLON-ALIGNED WIDGET-ID 10
     log-edit AT ROW 8.62 COL 3 NO-LABEL WIDGET-ID 12
    WITH 1 DOWN NO-BOX OVERLAY 
         SIDE-LABELS THREE-D 
         AT COL 1 ROW 1
         SIZE 72.6 BY 13.57.


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
         ROW                = 7.57
         HEIGHT             = 13.57
         WIDTH              = 73
         MAX-HEIGHT         = 35.62
         MAX-WIDTH          = 160
         VIRTUAL-HEIGHT     = 35.62
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
ASSIGN 
       log-edit:READ-ONLY IN FRAME FRAME-A        = TRUE.

/* SETTINGS FOR FILL-IN name IN FRAME FRAME-A
   NO-DISPLAY                                                           */
/* SETTINGS FOR FILL-IN password IN FRAME FRAME-A
   NO-DISPLAY                                                           */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-login)
THEN w-login:HIDDEN = no.

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

/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-OK w-login
ON CHOOSE OF b-OK IN FRAME FRAME-A /* Очистить */
DO:
  define variable v-cConnect     as CHAR no-undo.
  define variable v-user-entered as logical   no-undo init false .

  assign
    f-ub
    name
    password
    f-date.

  if name :screen-value = ""
  then do:
    message
      "Введите имя пользователя"
      view-as alert-box information .
    apply "entry" to name .
    return no-apply .
  end.
  if f-date = ? then
  do:
    message "Необходимо ввести дату актуальности документов" view-as alert-box.
    apply "entry":U to f-date in frame {&frame-name}.
    return no-apply.  
  end.
  
  assign
    v-cConnect = f-ub  
               + (if     name ne "" 
                     and name ne ?
                  then " &1 "
                  else " ")
               
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
     return no-apply.
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
 
  assign
    session :data-entry-return = no 
  .

  /* --------------------- Если произошло подключение к базе данных --------------------- */
  if v-user-entered then
  do:
    message
      'Вы уверены, что хотите произвести чистку базы данных до' string(f-date,"99/99/9999") '?' skip
      view-as alert-box question buttons yes-no update v-ok as logical.
    if v-ok <> true then do:
      return no-apply .
    end.

    run utl/clean_db.p
      ( input f-date
       ,input this-procedure :handle
      ) no-error.
    if error-status :error then do:
       message
       substitute( "Ошибка при работе утилит!" ) skip
       return-value skip
       error-status :get-message ( error-status :num-messages )
       view-as alert-box error
     .
    end.
  end.
  else do:
    if error-status :error then 
    do:
      message
        "Ошибка при подключении к БД" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      disconnect ub no-error .
    end.
    else
    do:
      message
        "Ошибка при подключении к базе данных" skip
        "Обратитесь к администратору" skip
        "Строка подключения к БД:" skip
        v-cConnect skip
        view-as alert-box error .
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-login 


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i &disable-button=yes }

on "ENTRY" of b-ok do:
  if lastkey = keycode ("RETURN") then do:
    apply "CHOOSE" to b-ok in frame {&frame-name}.
  end.
end.

on window-close of {&window-name} do:
  apply "end-error" to frame {&frame-name}.
end.


MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
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

  run enable_UI in this-procedure .

  WAIT-FOR GO OF frame {&FRAME-NAME} focus name.
END.
RUN disable_UI in this-procedure.
quit.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE callback-write-to-log w-login 
PROCEDURE callback-write-to-log :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  define input parameter p-msg-str as character no-undo .

  define variable lok as logical   no-undo .

  do with frame {&frame-name}
  on error undo, return error return-value
  :
    assign
      lok = log-edit :move-to-eof( )
      lok = log-edit :insert-string( p-msg-str )
      lok = log-edit :move-to-eof( )
    .
  end. /* do with frame */

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
  DISPLAY f-ub f-date log-edit 
      WITH FRAME FRAME-A IN WINDOW w-login.
  ENABLE b-OK f-ub name b-quit  password_display f-date log-edit 
      WITH FRAME FRAME-A IN WINDOW w-login.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-A}
  VIEW w-login.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

