&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $


Автор: Рукавишников Вадим
Дата создания: 21/04/21
Author: Rukavishnikov Vadim
Creation date: 21/04/21


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-mode as character no-undo.
define input parameter p-parent as character no-undo.
define input-output parameter p-rid as recid init ? no-undo.
define buffer codeupdate for code .

&Scoped-define CODE_PARENT p-parent

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: $":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile: $":U .
define variable vss-archive     as character no-undo init "$Archive: $":U .
define variable vss-description as character no-undo init "Карточка редактирование групп параметров".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/is-num.i}
define variable v-db-num like ub.db.db-num no-undo .
.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-save b-quit B-Help mcode mNAIM 
&Scoped-Define DISPLAYED-OBJECTS mcode mNAIM 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-save AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE mNAIM AS CHARACTER FORMAT "X(4000)":U 
     LABEL "Описание группы" 
     VIEW-AS FILL-IN 
     SIZE 90 BY 1 NO-UNDO.

DEFINE VARIABLE mcode AS character  FORMAT "x(20)":U 
     LABEL "Название группы" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-save AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 36
     mcode AT ROW 2.5 COL 18 COLON-ALIGNED WIDGET-ID 2
     mNAIM AT ROW 5 COL 18 COLON-ALIGNED WIDGET-ID 8
     SKIP(0.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Редактирование группы параметров"
         DEFAULT-BUTTON B-save CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Редактирование ЕМЦ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-save Dialog-Frame
ON CHOOSE OF B-save IN FRAME Dialog-Frame /* Ввод */
DO:
  Assign
  mcode
  mNAIM
      .


    if mcode = "" then do:
      message "Введите название группы ! " view-as  alert-box  error.
      apply "entry"  to mcode .
      return no-apply.
    end.
    if not is-numeral (mcode,
                   "letter,digit"
                   ) 
    then do:
      message "Название группы может содержать латинские буквы и цифры! " view-as  alert-box  error.
      apply "entry"  to mcode .
      return no-apply.
    end.
    if mNAIM = "" then do:
      message "Введите описание ! " view-as  alert-box  error.
      apply "entry"  to mNAIM .
      return no-apply.
    end.
    
    if p-mode = {&add-def} then do:
       define buffer buf-code for ub.code.
      find first buf-code where buf-code.parent eq {&CODE_PARENT}
                            and buf-code.code   eq mcode
      no-lock no-error.
      if available buf-code
      then do:
         message "Такое название группы уже есть ! " view-as  alert-box  error.
         apply "entry"  to mcode .
         return no-apply.
      end.
      create code.
      
    end.
    else do:
       
          find first buf-code where buf-code.parent eq {&CODE_PARENT}
                                and buf-code.code   eq mcode
                                and recid(buf-code) ne p-rid
          no-lock no-error.
          if available buf-code
          then do:
             message "Такое название группы уже есть ! " view-as  alert-box  error.
             apply "entry"  to mcode .
             return no-apply.
          end.
       
    end.
    if p-mode = {&add-def} OR p-mode = {&update}  then
       Assign
          code.code     = mcode
          code.codename = mNAIM
          Code.parent   = {&CODE_PARENT}
          p-rid         = recid(code)
          Code.nwsgbd   = yes
          .
     else p-rid = ? .
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
   if p-mode <> {&add-def} and
      p-mode <> {&update}
   then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-mode"  p-mode
      view-as alert-box ERROR.
      undo, return error.
   end.
   { gbl/curdbnum.i v-db-num }
 
   if v-db-num <> 0 then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-mode - нельзя изменять/добавлять записи группы в УБД"
      view-as alert-box ERROR.
      undo, return error.
   end.

   if p-mode = {&update} then do:
      find first code where
                 recid(code) = p-rid exclusive-lock no-wait no-error.
      if locked code then do:
         message
            vss-workfile vss-revision vss-description skip
            "Группа параметров занята"
         view-as alert-box error .
         undo, return error.
      end.
      if not available code then do:
         message
            vss-workfile vss-revision vss-description skip
            "Не найдена группа параметров"
         view-as alert-box error .
         undo, return error.
      end.
      assign
         mcode = code.code
         mNAIM = Code.CodeName
      .
      
   end.




   run enable_UI in this-procedure .
   if p-mode = {&add-def} then do:
      ENABLE mcode WITH FRAME Dialog-Frame.
      apply "entry" to mcode in FRAME Dialog-Frame.
   end.
  
   WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
session:data-entry-return = no .
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

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
  DISPLAY mcode mNAIM 
      WITH FRAME Dialog-Frame.
  ENABLE B-save b-quit B-Help mNAIM 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  if p-mode = {&add-def}
  then ENABLE  mcode  
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

