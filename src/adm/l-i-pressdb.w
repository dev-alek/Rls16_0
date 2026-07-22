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
{ utl/cut-load.i &filename="press_db.log"}
/* Local Variable Definitions ---                                       */

define variable vWrkDir  as character no-undo init "press-db".
define variable vTables  as character no-undo init "tables.txt".
define variable vFileLog as character no-undo.
define variable v-updating  as logical   no-undo init false .
define stream sToFile.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE WINDOW
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME FRAME-A

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-OK f-db-src radio-mode name password ~
f-db-rec log-edit b-quit 
&Scoped-Define DISPLAYED-OBJECTS f-db-src radio-mode f-db-rec log-edit 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w-login AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-OK  NO-FOCUS
     LABEL "&Выполнить":L 
     SIZE 13 BY 1
     BGCOLOR 15 .

DEFINE BUTTON b-quit AUTO-END-KEY  NO-FOCUS
     LABEL "&Закрыть":L 
     SIZE 12.4 BY 1.

DEFINE VARIABLE log-edit AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 74 BY 7.91 NO-UNDO.

DEFINE VARIABLE f-db-rec AS CHARACTER FORMAT "X(256)":U INITIAL "c:~\baza~\etalon~\ub" 
     LABEL "БД приемник" 
     VIEW-AS FILL-IN 
     SIZE 57.4 BY 1 TOOLTIP "Укажите полный путь к БД-приемник. Например: c:\baza\etalon\db" NO-UNDO.

DEFINE VARIABLE f-db-src AS CHARACTER FORMAT "X(256)":U INITIAL "c:~\baza~\ubd~\ub" 
     LABEL "БД источник" 
     VIEW-AS FILL-IN 
     SIZE 57.2 BY 1 TOOLTIP "Укажите полный путь к БД-источник. Например: c:\baza\ubd\db." NO-UNDO.

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

DEFINE VARIABLE radio-mode AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          " - только выгрузка", 1,
" - только загрузка", 2,
" - выгрузка и загрузка", 3
     SIZE 31 BY 2.38 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME FRAME-A
     b-OK AT ROW 7.19 COL 13
     f-db-src AT ROW 1.76 COL 4.6 WIDGET-ID 2
     radio-mode AT ROW 2.91 COL 44 NO-LABEL WIDGET-ID 16
     name AT ROW 3 COL 16.8 COLON-ALIGNED
     password AT ROW 4.29 COL 16.8 COLON-ALIGNED PASSWORD-FIELD 
     password_display AT ROW 4.29 COL 16.8 COLON-ALIGNED PASSWORD-FIELD 
     f-db-rec AT ROW 5.57 COL 3.6 WIDGET-ID 14
     log-edit AT ROW 8.57 COL 4 NO-LABEL WIDGET-ID 12
     b-quit AT ROW 7.19 COL 26
    WITH 1 DOWN NO-BOX OVERLAY 
         SIDE-LABELS THREE-D 
         AT COL 1 ROW 1
         SIZE 79.8 BY 16.14.


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
         TITLE              = "Trade House 16.0"
         COLUMN             = 27
         ROW                = 7.57
         HEIGHT             = 16.95
         WIDTH              = 80.2
         MAX-HEIGHT         = 48.43
         MAX-WIDTH          = 384
         VIRTUAL-HEIGHT     = 48.43
         VIRTUAL-WIDTH      = 384
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
/* SETTINGS FOR FILL-IN f-db-rec IN FRAME FRAME-A
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-db-src IN FRAME FRAME-A
   ALIGN-L                                                              */
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
ON CHOOSE OF b-OK IN FRAME FRAME-A /* Выполнить */
DO:
  define variable vConnect       as character no-undo.
  define variable v-user-entered as logical   no-undo init false .
  define variable vDbSrc         as character no-undo.
  define variable vDbRec         as character no-undo.
  define variable vMess          as character no-undo.

  assign
    f-db-src
    name
    password
    f-db-rec
    radio-mode
  .

  if search(trim(f-db-src) + ".db") = ? then
  do:
    message
     "Не найдена БД источнк."
      view-as alert-box information .
    apply "entry" to f-db-src .
    return no-apply .
  end.
  if search(trim(f-db-rec) + ".db") = ? then
  do:
    message
     "Не найдена БД приемник."
      view-as alert-box information .
    apply "entry" to f-db-rec .
    return no-apply .
  end.

  if name :screen-value = ""
  then do:
    message
      "Введите имя пользователя"
      view-as alert-box information .
    apply "entry" to name .
    return no-apply .
  end.
  
  assign
    vDbSrc = substitute("-db &1 -ld ub -1", trim(f-db-src)) 
    vDbRec = substitute("-db &1 -ld &2 -1 -U sysadm -P sysadm -i" ,trim(f-db-rec), "dst") 
    vConnect = vDbSrc   
               + (if     name ne "" 
                     and name ne ?
                  then " &1 "
                  else " ")
  .
  run gbl/dbconnnodisc.p
    (input vConnect
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

   run gbl/dbconnnodisc.p
    (input vDbRec
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

  assign
    session :data-entry-return = no 
  .

  /* --------------------- Если произошло подключение к базе данных --------------------- */
  if v-user-entered then
  do:
    if radio-mode = 1 then
      vMess = "Выгрузить данные из БД источник?".
    else if radio-mode = 2 then
      vMess = "Загрузить выгруженные данные в БД приемник?".
    else 
      vMess = "Вы уверены, что хотите произвести перенос данных в другую БД для сжатия базы?".

    message
      vMess skip
      view-as alert-box question buttons yes-no update v-ok as logical.
    if v-ok <> true then do:
      return no-apply .
    end.

    disable b-OK b-quit with frame {&frame-name}.
    
    if radio-mode = 1 or radio-mode = 3 then
    do:     
      run utl/pressdbbef.p (
        input vWrkDir,
        input vTables,
        input this-procedure :handle
      ) no-error.
      if error-status :error then do:
         message
           substitute( "Ошибка при выполнении подготовительных процедур!" ) skip
           return-value skip
           error-status :get-message ( error-status :num-messages )
           view-as alert-box error
         .
         disconnect ub.
         disconnect dst.
         enable b-OK b-quit with frame {&frame-name}.
         return no-apply.
      end.
      disconnect ub.
      disconnect dst.

      run utl/pressdbdump.p (
        input search(vWrkDir + "\" + vTables),
        f-db-src,
        input this-procedure :handle
      ) no-error.
      if error-status :error then do:
        message
         substitute( "Ошибка при выполнении выгрузки данных БД!" ) skip
         return-value skip
         error-status :get-message ( error-status :num-messages )
         view-as alert-box error
        .
        enable b-OK b-quit with frame {&frame-name}.
        return no-apply.
      end.
    end.
    else do:
      disconnect ub.
      disconnect dst.
    end.

    if radio-mode = 2 or radio-mode = 3 then
    do:     
      run utl/pressdbload.p (
        input vWrkDir,
        f-db-rec,
        input this-procedure :handle
      ) no-error.
      if error-status :error then do:
        message
          substitute( "Ошибка при выполнении зарузки данных БД!" ) skip
          return-value skip
          error-status :get-message ( error-status :num-messages )
         view-as alert-box error
        .
        enable b-OK b-quit with frame {&frame-name}.
        return no-apply.
      end.

      /* соеденяемся с БД-приемник для пересчета sequence */
      run gbl/dbconnnodisc.p
          (input substitute("-db &1 -ld &2 -1 -U sysadm -P sysadm -i" ,trim(f-db-rec), "ub")
        ,input ? /* v-fltConnect */
        ,input name
        ,input password
        ,input-output v-user-entered
      ) no-error.
      run write-to-log in this-procedure
        ( string(today, '99/99/9999') + " " + string(time, 'HH:MM') + 
          " Восстановливаем Sequences" + {&new-line}
       ,this-procedure
      ).
      run adm/restseqr.p
        ( input "rest-no-msg":U
         ,input "":U
         ,input no
      ) no-error .
      disconnect ub.
      /*
      run write-to-log in this-procedure
      ( string(today, '99/99/9999') + " " + string(time, 'HH:MM') + 
        " Удаление временных файлов." + {&new-line}
      ,this-procedure
      ).

      os-delete value(vWrkDir + "\") recursive.
      if os-error <> 0 then do:
        message
          substitute( "Ошибка при удалении временных файлов!" ) skip
          substitute( "Код ошибки: &1.", os-error )
          view-as alert-box error
        .
        enable b-OK b-quit with frame {&frame-name}.
        return no-apply.
      end.
      */
    end.
    
    if radio-mode = 1 then
      vMess = "Выгрузка данных завершена.".
    else if radio-mode = 2 then
      vMess = "Загрузка данных завершена.".
    else 
      vMess = "Перенос БД завершен.".
      
    run write-to-log in this-procedure
    ( string(today, '99/99/9999') + " " + string(time, 'HH:MM') + 
      " " + vMess + {&new-line}
    ,this-procedure
    ).

    message
      vMess
      view-as alert-box
    .

    enable b-OK b-quit with frame {&frame-name}.
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
        vConnect skip
        view-as alert-box error .
      enable b-OK b-quit with frame {&frame-name}.
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
  DISPLAY f-db-src radio-mode f-db-rec log-edit 
      WITH FRAME FRAME-A IN WINDOW w-login.
  ENABLE b-OK f-db-src radio-mode name password password_display f-db-rec log-edit b-quit 
      WITH FRAME FRAME-A IN WINDOW w-login.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-A}
  VIEW w-login.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

