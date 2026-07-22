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
define input parameter parparentproc as widget-handle no-undo.
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
define button B-Help 
   label "Помо&щь" 
   size 10 by 1
   bgcolor 8 .

define button b-quit auto-end-key 
   label "&Отмена" 
   size 10 by 1
   bgcolor 8 .

define button B-save auto-go 
   label "&Ввод" 
   size 10 by 1
   bgcolor 8 .
define variable mParentCode   as character       format "x(40)":U 
   label "Функция" 
   view-as combo-box
   list-item-pairs "1","1"
   size 42 by 1 no-undo.


define variable mCode   as character       format "x(20)":U 
   label "Доп. Значение" 
   view-as fill-in 
   size 21 by 1 no-undo.

define variable mZNACH  as character    format "x(3)":U
   label "Степень защиты" 
   view-as combo-box 
   list-item-pairs "MGR","MGR",
   "REG","REG"
    
   size 20 by 1 no-undo.

define variable mDecript  as character    format "x(40)":U
   label "Наименование"
   view-as fill-in
   size 20 by 1 no-undo.

/*DEFINE VARIABLE mPosType  AS character    FORMAT "x(20)":U init "IBM-XML,Autotank"*/
/*   LABEL "Типы касс"                                                              */
/*   VIEW-AS COMBO-BOX INNER-LINES 15                                               */
/*   LIST-ITEM-PAIRS "IBM-XML" , "IBM-XML",                                         */
/*                   "Autotank", "Autotank",                                        */
/*                   "Все"     , ""                                                 */
/*   SIZE 20 BY 1 NO-UNDO.                                                          */
     
define variable fStatus as integer   init {&current-status-int}   
   label "Статус" 
   view-as combo-box inner-lines 2
   list-item-pairs "Обязательный",{&current-status-int},
   "Необязательный",{&deleted-status-int}
   drop-down-list
   size 20 by 1 no-undo.


/* ************************  Frame Definitions  *********************** */

define frame Dialog-Frame
   B-save at row 1 col 1
   b-quit at row 1 col 11
   B-Help at row 1 col 36
   mParentCode at row 2.5 col 18 colon-aligned widget-id 8
   mCode at row 4 col 18 colon-aligned widget-id 10
   mZNACH at row 5.5 col 18 colon-aligned widget-id 12
   mDecript at row 7 col 18 colon-aligned widget-id 14
/*   mPosType AT ROW 7 COL 18 COLON-ALIGNED WIDGET-ID 12*/
   fStatus at row 8.5 col 18 colon-aligned widget-id 16     
   /*   mDoc AT ROW 7 COL 18 COLON-ALIGNED WIDGET-ID 16  */
     
     
   with view-as dialog-box keep-tab-order 
   side-labels no-underline three-d  scrollable 
   title "Редактирование параметра"
   default-button B-save cancel-button b-quit.


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
assign 
   frame Dialog-Frame:SCROLLABLE = false
   frame Dialog-Frame:HIDDEN     = true.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
on window-close of frame Dialog-Frame /* Редактирование ЕМЦ */
   do:
      apply "END-ERROR":U to self.
   end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-save Dialog-Frame
on choose of B-save in frame Dialog-Frame /* Ввод */
   do:
      run proc-save in this-procedure no-error.
      if error-status:error then return no-apply.
   end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
if valid-handle(active-window) and frame {&FRAME-NAME}:PARENT eq ?
   then frame {&FRAME-NAME}:PARENT = active-window.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
   on end-key undo MAIN-BLOCK, leave MAIN-BLOCK:
   if p-mode <> {&add-def} and
      p-mode <> {&update}
      then 
   do:
      message
         vss-workfile vss-revision vss-description skip
         "Неверное значение параметров вызова p-mode"  p-mode
         view-as alert-box error.
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
         frame Dialog-Frame:TITLE = "Редактирование параметра " + b3-code.codename.
         v-name = b3-code.CodeName .
      end.
   end.
   mParentCode = entry(num-entries (p-parent,{&delim-par}),p-parent,{&delim-par}).
   define variable v-list-items as character no-undo.
   define buffer code-func for ub.code.
   for each code-func where code-func.parent eq "CashFunKey" no-lock by code-func.CodeName:
      v-list-items = v-list-items + {&comma-char} + code-func.codename + " (" + code-func.Code + ")" + {&comma-char} + code-func.code .
   end.
   mParentCode:LIST-ITEM-PAIRS  in frame {&frame-name} = trim(v-list-items,{&comma-char}) .
   
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
      enable mCode with frame Dialog-Frame.
      apply "entry" to mCode in frame Dialog-Frame.
   end.
  
   wait-for go of frame {&FRAME-NAME}.
end.
session:data-entry-return = no .
run disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
procedure disable_UI :
   /*------------------------------------------------------------------------------
     Purpose:     DISABLE the User Interface
     Parameters:  <none>
     Notes:       Here we clean-up the user-interface by deleting
                  dynamic widgets we have created and/or hide 
                  frames.  This procedure is usually called when
                  we are ready to "clean-up" after running.
   ------------------------------------------------------------------------------*/
   /* Hide all frames. */
   hide frame Dialog-Frame.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
procedure enable_UI :
   /*------------------------------------------------------------------------------
     Purpose:     ENABLE the User Interface
     Parameters:  <none>
     Notes:       Here we display/view/enable the widgets in the
                  user-interface.  In addition, OPEN all queries
                  associated with each FRAME and BROWSE.
                  These statements here are based on the "Other 
                  Settings" section of the widget Property Sheets.
   ------------------------------------------------------------------------------*/
   display mCode mZNACH fStatus mDecript mParentCode 
/*   mDop*/
/*      mPosType*/
      with frame Dialog-Frame.
   enable B-save b-quit B-Help mCode mZNACH fStatus mDecript 
/*   mPosType*/
      with frame Dialog-Frame.
   view frame Dialog-Frame.
   if mParentCode eq  ""
   then enable mParentCode
      with frame Dialog-Frame.
   
   {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
procedure proc-save :
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
   if mZNACH eq ""
      or mZNACH eq ""
   then do:
      message "Введите степень защиты ! " view-as  alert-box  error.
      apply "entry"  to mZNACH .
      return ERROR.
   end.
   do on error undo, return error
      on stop undo, return error:
      entry(num-entries (p-parent,{&delim-par}),p-parent,{&delim-par}) = mParentCode.
      if    mParentCode eq ?
         or mParentCode eq ""
      then do:
         message "Заполните функцию"
         view-as alert-box.
         apply "entry"  to mParentCode .
         return error.
      end.
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

  
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

