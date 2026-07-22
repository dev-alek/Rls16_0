&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Диалог задания пароля пользовател

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 01/11/07

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc  as widget-handle no-undo .
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-user-id      as character no-undo .
define input  parameter p-user-login   as character no-undo .
define input  parameter p-user-Name    as character no-undo .
define input  parameter p-user-adm     as logical   no-undo .

define input  parameter p-LastPassVis  as logical   no-undo .
if p-user-adm eq yes
   then
   p-LastPassVis = no.
define input  parameter p-old-password as character no-undo .
define input  parameter p-login        as logical   no-undo .
define input  parameter i-CheckAdm     as logical   no-undo .

define output parameter p-password     as character no-undo initial ? .
define output parameter ochgpdwnextcon as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Диалог задания пароля пользователя".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
/*{ utl/setpwd.i}*/
{ cmp/trg-def.i }
{ adm/userpro.i}

define variable v-param-type      as character no-undo .
define variable v-value-character AS character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as INTEGER   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-noanshftstaff   as logical   no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help fi-new-password ~
fi-new-password-2 chgpwdextcon fi-db fi-userid fi-username 
&Scoped-Define DISPLAYED-OBJECTS fi-new-password fi-new-password-2 ~
chgpwdextcon fi-db fi-userid fi-username 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO 
   LABEL "&Ввод" 
   SIZE 10 BY 1
   BGCOLOR 8 .

DEFINE BUTTON b-help 
   LABEL "Помо&щь" 
   SIZE 10 BY 1
   BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
   LABEL "&Отмена" 
   SIZE 10 BY 1
   BGCOLOR 8 .

DEFINE VARIABLE fi-db             AS CHARACTER FORMAT "X(256)":U 
   LABEL "БД" 
   VIEW-AS TEXT 
   SIZE 40.6 BY .67
   FGCOLOR 4 NO-UNDO.

DEFINE VARIABLE fi-new-password   AS CHARACTER FORMAT "X(16)":U 
   LABEL "Новый пароль" 
   VIEW-AS FILL-IN 
   SIZE 20.6 BY 1 NO-UNDO.

DEFINE VARIABLE fi-new-password-2 AS CHARACTER FORMAT "X(16)":U 
   LABEL "Подтверждение пароля" 
   VIEW-AS FILL-IN 
   SIZE 20.6 BY 1 NO-UNDO.

DEFINE VARIABLE fi-old-password   AS CHARACTER FORMAT "X(16)":U 
   LABEL "Старый пароль" 
   VIEW-AS FILL-IN 
   SIZE 20.6 BY 1 NO-UNDO.

DEFINE VARIABLE fi-userid         AS CHARACTER FORMAT "X(256)":U 
   LABEL "Идентификатор" 
   VIEW-AS TEXT 
   SIZE 40.6 BY .67
   FGCOLOR 4 NO-UNDO.

DEFINE VARIABLE fi-username       AS CHARACTER FORMAT "X(256)":U 
   LABEL "Пользователь" 
   VIEW-AS TEXT 
   SIZE 40.6 BY .67
   FGCOLOR 4 NO-UNDO.

DEFINE VARIABLE chgpwdextcon      AS LOGICAL   INITIAL yes 
   LABEL "Сменить пароль при следующем входе в систему" 
   VIEW-AS TOGGLE-BOX
   SIZE 55.6 BY .81.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
   b-exit AT ROW 1 COL 1
   b-quit AT ROW 1 COL 11
   b-help AT ROW 1 COL 61
   fi-old-password AT ROW 7.76 COL 22.6 COLON-ALIGNED WIDGET-ID 6 PASSWORD-FIELD 
   fi-new-password AT ROW 9.24 COL 22.6 COLON-ALIGNED WIDGET-ID 8 PASSWORD-FIELD 
   fi-new-password-2 AT ROW 10.52 COL 2.6 WIDGET-ID 10 PASSWORD-FIELD 
   chgpwdextcon AT ROW 11.76 COL 3 WIDGET-ID 14
   fi-db AT ROW 3.24 COL 22.6 COLON-ALIGNED WIDGET-ID 12
   fi-userid AT ROW 4.76 COL 22.6 COLON-ALIGNED WIDGET-ID 2
   fi-username AT ROW 6.24 COL 22.6 COLON-ALIGNED WIDGET-ID 4
   SPACE(7.79) SKIP(6.50)
   WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
   SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
   TITLE "Изменение пароля"
   DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
   FRAME Dialog-Frame:SCROLLABLE = FALSE
   FRAME Dialog-Frame:HIDDEN     = TRUE.

/* SETTINGS FOR FILL-IN fi-new-password-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-old-password IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
   fi-old-password:HIDDEN IN FRAME Dialog-Frame = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Изменение пароля */
   DO:

      run change-password in this-procedure no-error .
      if error-status :error
         then 
      do:
         ASSIGN
            p-password     = ?
            ochgpdwnextcon = ?
            .
         return no-apply .
      end.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Изменение пароля */
   DO:
      APPLY "END-ERROR":U TO SELF.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
   DO:
      assign
         p-password     = ?
         ochgpdwnextcon = ?
        
         .
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

   assign
      fi-db       = STRING(p-db-num)
      fi-userid   = p-user-login
      fi-username = p-user-name
      .
  

   if p-LastPassVis ne no
      then 
   do:
      chgpwdextcon = no.
      assign
         fi-old-password :visible   = true
         fi-old-password :sensitive = true
         
         .
   end.

   RUN enable_UI.

   run display-data in this-procedure .

   if p-LastPassVis eq no
      then 
   do:
      
      apply 'entry':U to fi-old-password .
   end.
   else 
   do:
      chgpwdextcon    :visible   = false.
      apply 'entry':U to fi-new-password .
   end.

   WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE change-password Dialog-Frame 
PROCEDURE change-password :
   /* -----------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   -------------------------------------------------------------*/
   define variable v-encode-value as character no-undo .

   /*  define buffer buf_user-login for ub.user-login . */

   do
      on error undo, return error return-value
      :
     
      if p-LastPassVis ne no
         then 
      do:
         /* проверяем старое значение пароля */
         do with frame {&frame-name}
            :
            assign
               fi-old-password
               .
         end.
         if fi-old-password = '':U
            or fi-old-password = ?
            then 
         do:
            message
               "Необходимо ввести старое значение пароля"
               view-as alert-box information .
            apply 'entry':U to fi-old-password .
            undo, return error return-value .
         end.

         run adm/pswd-enc.p
            (input  encode(fi-old-password)
            ,output v-encode-value
            ).
         assign
            v-encode-value = encode(v-encode-value)
            .

         if p-old-password <> v-encode-value
            then 
         do:
            message
               "Неправильное введено значение старого пароля" skip
               /*          p-old-password skip
                         v-encode-value skip
               */
               view-as alert-box error .
            apply 'entry':U to fi-old-password .
            undo, return error return-value .
         end.
      end.

      do with frame {&frame-name}
         :
         assign
            fi-new-password
            fi-new-password-2
            .
      end.
      /*                      */
      /*    if p-user-adm eq ?*/
      /*    then              */
      /*                      */
       
      if fi-new-password = '':U
         or fi-new-password = ?
         then 
      do:
         message
            "Необходимо ввести новое значение пароля"
            view-as alert-box information .
         apply 'entry':U to fi-new-password .
         undo, return error return-value .
      end.
      define variable vText as character no-undo.
      vText = CheckLastPWD(p-db-num,p-user-id,fi-new-password,i-CheckAdm).
      if vText ne ""
         then 
      do:
         message
            vText
            view-as alert-box information .
         apply 'entry':U to fi-new-password .
         undo, return error return-value .
      end.
    
      if fi-new-password-2 = '':U
         or fi-new-password-2 = ?
         then 
      do:
         message
            "Необходимо ввести значение пароля для проверки"
            view-as alert-box information .
         apply 'entry':U to fi-new-password-2 .
         undo, return error return-value .
      end.

      if fi-new-password <> fi-new-password-2
         then 
      do:
         message
            "Не совпадают значение нового пароля и значение пароля для проверки"
            view-as alert-box error .
         apply 'entry':U to fi-new-password .
         undo, return error return-value .
      end.

      run adm/pswd-enc.p
         (input  encode(fi-new-password)
         ,output v-encode-value
         ).
      assign
         chgpwdextcon
         p-password     = encode(v-encode-value)
         ochgpdwnextcon = chgpwdextcon
         .
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-data Dialog-Frame 
PROCEDURE display-data :
   /* -----------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   -------------------------------------------------------------*/

   define buffer buf_db for ub.db .
   /*
   define buffer buf_user-account for ub.user-account .
   */

   do
      with frame {&frame-name}
      on error undo, return error return-value
      :
      display
         fi-userid
         fi-username
         with frame {&frame-name} .
   end.
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
   DISPLAY fi-new-password fi-new-password-2 chgpwdextcon fi-db fi-userid 
      fi-username 
      WITH FRAME Dialog-Frame.
   ENABLE b-exit b-quit b-help fi-new-password fi-new-password-2 chgpwdextcon 
      fi-db fi-userid fi-username 
      WITH FRAME Dialog-Frame.
   VIEW FRAME Dialog-Frame.
   {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

