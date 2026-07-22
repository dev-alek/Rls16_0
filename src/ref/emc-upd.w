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

Карточка Код ОКЕИ код ККТ

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
define input-output parameter p-rid as recid init ? no-undo.
define buffer codeupdate for code .
/*&Scoped-define CODE_PARENT "EMC"*/

&Scoped-define BEF_CODE_PARENT EMC
&Scoped-define CODE_PARENT "{&BEF_CODE_PARENT}"

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: $":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile: $":U .
define variable vss-archive     as character no-undo init "$Archive: $":U .
define variable vss-description as character no-undo init "Карточка Код ОКЕИ код ККТ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
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
&Scoped-Define ENABLED-OBJECTS B-save b-quit B-Help mOKEI mNAIM 
&Scoped-Define DISPLAYED-OBJECTS mOKEI mNAIM 

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

DEFINE VARIABLE mNAIM AS CHARACTER FORMAT "X(256)":U 
     LABEL "Наименование" 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1 NO-UNDO.

DEFINE VARIABLE mOKEI AS INTEGER FORMAT ">>>>>999":U INITIAL 0 
     LABEL "Код" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-save AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 36
     mOKEI AT ROW 2.5 COL 18 COLON-ALIGNED WIDGET-ID 2
     mNAIM AT ROW 5 COL 18 COLON-ALIGNED WIDGET-ID 8
     SPACE(18.24) SKIP(0.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Редактирование ЕМЦ"
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
  mOKEI
  mNAIM
      .


    
    if mNAIM = "" then do:
      message "Введите Наименование ! " view-as  alert-box  error.
      apply "entry"  to mNAIM .
      return no-apply.
    end.

    if p-mode = {&add-def} then do:
      create code.

    end.
    if p-mode = {&add-def} OR p-mode = {&update}  then
       Assign
          code.code = string(mOKEI)
          code.codename = mNAIM
          p-rid = recid(code)
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
      "Неверное значение параметров вызова p-mode - нельзя изменять/добавлять записи <Тип ЕМЦ Код> в УБД"
      view-as alert-box ERROR.
      undo, return error.
   end.

   if p-mode = {&update} then do:
      find first code where
                 recid(code) = p-rid exclusive-lock no-wait no-error.
      if locked code then do:
         message
            vss-workfile vss-revision vss-description skip
            "Запись <Тип ЕМЦ - Код> занята"
         view-as alert-box error .
         undo, return error.
      end.
      if not available code then do:
         message
            vss-workfile vss-revision vss-description skip
            "Не найдена запись <Тип ЕМЦ - Код>"
         view-as alert-box error .
         undo, return error.
      end.
      assign
         mOKEI = int(code.code)
         mNAIM = Code.CodeName
      .
      
   end.




   run enable_UI in this-procedure .
   if p-mode = {&add-def} then do:
      ENABLE mOKEI WITH FRAME Dialog-Frame.
      apply "entry" to mOKEI in FRAME Dialog-Frame.
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
  DISPLAY mOKEI mNAIM 
      WITH FRAME Dialog-Frame.
  ENABLE B-save b-quit B-Help mNAIM 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  if p-mode = {&add-def}
  then ENABLE  mOKEI  
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
   define buffer units for units.
   
   assign frame {&frame-name}
      mOKEI
      mNAIM
     
      .

   do on error undo, return error
   on stop undo, return error:
      if p-mode = {&add-def} then do:
         find first code where
                    code.parent = {&CODE_PARENT}
                and code.code   = string(mOKEI)
         no-lock no-error.
         if avail code then do:
            message
               "Уже есть такая запись Тип ЕМЦ Код :" mOKEI
            view-as alert-box error .
            return error.
         end.
         create code.
         assign
            code.parent = {&CODE_PARENT}
            code.code   = string(mOKEI, fill("9", max(length(string(mOKEI)), 3)))
            code.codename   = string(mNAIM, fill("9", max(length(string(mNAIM)), 3)))
            code.nwsgbd = yes
         .
      end.
     

   end.
   p-rid = recid(code).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

