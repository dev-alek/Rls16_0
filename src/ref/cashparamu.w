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
define input parameter p-parent as character no-undo.
define input-output parameter p-rid as recid init ? no-undo.
define buffer b3-code for code .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: $":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile: $":U .
define variable vss-archive     as character no-undo init "$Archive: $":U .
define variable vss-description as character no-undo init "редактирование параметров".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/sel-date.i }
{ gbl/is-num.i }
define variable v-db-num like ub.db.db-num no-undo .
define variable v-name   as character no-undo .
define variable vDateIsoOld as character no-undo.
define variable mViewDop as logical no-undo.
mViewDop = num-entries (p-parent,{&DELIM-PAR}) eq 2.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-save b-quit B-Help mCode mZNACH mDop
&Scoped-Define DISPLAYED-OBJECTS mCode mZNACH mDop

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
DEFINE VARIABLE mParentCode   AS character       FORMAT "x(20)":U 
   LABEL "Группа" 
   VIEW-AS FILL-IN 
   SIZE 20 BY 1 NO-UNDO.


DEFINE VARIABLE mCode   AS character       FORMAT "x(20)":U 
   LABEL "Название параметра" 
   VIEW-AS FILL-IN 
   SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE mZNACH  AS character    FORMAT "x(40)":U
   LABEL "Значение" 
   VIEW-AS FILL-IN 
   SIZE 40 BY 1 NO-UNDO.

DEFINE VARIABLE mDecript  AS character    FORMAT "x(4000)":U
   LABEL "Описание параметра"
   VIEW-AS FILL-IN
   SIZE 80 BY 1 NO-UNDO.

/*DEFINE VARIABLE mPosType  AS character    FORMAT "x(20)":U init "IBM-XML,Autotank"*/
/*   LABEL "Типы касс"                                                              */
/*   VIEW-AS COMBO-BOX INNER-LINES 15                                               */
/*   LIST-ITEM-PAIRS "IBM-XML" , "IBM-XML",                                         */
/*                   "Autotank", "Autotank",                                        */
/*                   "Все"     , ""                                                 */
/*   SIZE 20 BY 1 NO-UNDO.                                                          */
     
DEFINE VARIABLE fStatus AS integer   init {&current-status-int}   
   LABEL "Статус" 
   VIEW-AS COMBO-BOX INNER-LINES 2
   LIST-ITEM-PAIRS "Обязательный",{&current-status-int},
   "Необязательный",{&deleted-status-int}
   DROP-DOWN-LIST
   SIZE 20 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
   B-save AT ROW 1 COL 1
   b-quit AT ROW 1 COL 11
   B-Help AT ROW 1 COL 36
   mParentCode AT ROW 2.5 COL 25 COLON-ALIGNED WIDGET-ID 8
   mCode AT ROW 4 COL 25 COLON-ALIGNED WIDGET-ID 10
   mZNACH AT ROW 5.5 COL 25 COLON-ALIGNED WIDGET-ID 12
   mDecript AT ROW 7 COL 25 COLON-ALIGNED WIDGET-ID 14
/*   mPosType AT ROW 7 COL 20 COLON-ALIGNED WIDGET-ID 12*/
   fStatus AT ROW 8.5 COL 20 COLON-ALIGNED WIDGET-ID 16     
   /*   mDoc AT ROW 7 COL 20 COLON-ALIGNED WIDGET-ID 16  */
     
     
   WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
   SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
   TITLE "Редактирование параметра"
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
   FRAME Dialog-Frame:SCROLLABLE = FALSE
   FRAME Dialog-Frame:HIDDEN     = TRUE.

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
      run proc-save in this-procedure no-error.
      if error-status:error then return no-apply.
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
      then 
   do:
      message
         vss-workfile vss-revision vss-description skip
         "Неверное значение параметров вызова p-mode"  p-mode
         view-as alert-box ERROR.
      undo, return error.
   end.
   { gbl/curdbnum.i v-db-num }

   define variable vparentpar as character no-undo.
   define variable vcodepar   as character no-undo.
   assign
      vparentpar = p-parent
      vcodepar   = entry(num-entries (vparentpar,{&delim-par}),vparentpar,{&delim-par})
      entry(num-entries (vparentpar,{&delim-par}),vparentpar,{&delim-par}) = ""
      vparentpar = trim(vparentpar,{&delim-par})
   no-error.
   if not error-status:error
   then do:
      find first b3-code where
         b3-code.parent  = vparentpar
         and b3-code.code    = vcodepar no-lock no-error.
   
      if available b3-code 
         then 
      do:
         FRAME Dialog-Frame:TITLE = "Редактирование параметра " + b3-code.code + "(" + b3-code.codename + ")".
         v-name = b3-code.CodeName .
      end.
   end.
   mParentCode = entry(num-entries (p-parent,{&delim-par}),p-parent,{&delim-par}).
   if p-mode = {&update} then 
   do:
      find first b3-code where
         recid(b3-code) = p-rid exclusive-lock no-wait no-error.

      if not available b3-code then 
      do:
         message
            vss-workfile vss-revision vss-description skip
            "Не найдена запись параметра"
            view-as alert-box error .
         undo, return error.
      end.
      assign
         
         mCode    = b3-code.code
         mZNACH   = b3-code.CodeValue
         mDecript     = b3-code.CodeName
         Fstatus  = b3-code.status_
/*         mPosType = b3-code.misc5*/
         .

   end.
   run enable_UI in this-procedure .
   
   if p-mode = {&add-def} then 
   do:
      ENABLE mCode WITH FRAME Dialog-Frame.
      apply "entry" to mCode in FRAME Dialog-Frame.
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
   DISPLAY mCode mZNACH fStatus mDecript mParentCode 
/*   mDop*/
/*      mPosType*/
      WITH FRAME Dialog-Frame.
   ENABLE B-save b-quit B-Help mCode mZNACH fStatus mDecript 
/*   mPosType*/
      WITH FRAME Dialog-Frame.
   VIEW FRAME Dialog-Frame.
   if mParentCode eq  ""
   then ENABLE mParentCode
      WITH FRAME Dialog-Frame.
   
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
   define buffer b3-code for code.
   define buffer b2-code for code.

   assign frame {&frame-name}
      mParentCode
      mCode 
      mZNACH
      mDecript
      fStatus
/*      mPosType*/
      .
    if mcode = "" 
    then do:
      message "Введите Название параметра ! " view-as  alert-box  error.
      apply "entry"  to mcode .
      return ERROR.
    end.
    if not is-numeral (mcode,
                   "letter,digit"
                   ) 
    then do:
      message "Название параметра может содержать латинские буквы и цифры! " view-as  alert-box  error.
      apply "entry"  to mcode .
      return ERROR.
    end.
   do on error undo, return error
      on stop undo, return error:
      entry(num-entries (p-parent,{&delim-par}),p-parent,{&delim-par}) = mParentCode.   
      if mCode eq ?
      then do:
         message "Код не может быть пустой"
         view-as alert-box.
         return error.
      end.
      find first b3-code where
         b3-code.parent = p-parent
         and b3-code.code   = mcode
         and if p-rid eq ? then yes else recid(b3-code) ne p-rid
         no-lock no-error.
      if avail b3-code then 
      do:
         message
            "Уже есть такаой параметр :" mCode
            view-as alert-box error .
         return error.
      end.

      find first b3-code where
         recid(b3-code) eq p-rid
         exclusive-lock no-error.
         
      if not avail b3-code then 
      do:
         create b3-code.
      end.
      
      assign
         b3-code.parent    = p-parent
         b3-code.code      = mcode
         b3-code.codevalue = mZNACH
         b3-code.CodeName  = mDecript
         b3-code.status_   = fStatus
         b3-code.nwsgbd    = yes
/*         b3-code.misc5     = mPosType*/
         .
      p-rid = recid(b3-code).
      
   end.

  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

