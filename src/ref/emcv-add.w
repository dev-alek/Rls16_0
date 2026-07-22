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
define buffer b3-code for code .
define input parameter p-parent as character no-undo.
&Scoped-define CODE_PARENT "EMC2"

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
{ gbl/sel-date.i }
define variable v-db-num like ub.db.db-num no-undo .
define variable v-name   as character no-undo .
define variable vDateIsoOld as character no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-save b-quit B-Help mDATA mZNACH 
&Scoped-Define DISPLAYED-OBJECTS mDATA mZNACH 

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

DEFINE VARIABLE mDATA   AS DATE      FORMAT "99/99/9999":U INITIAL ? 
   LABEL "Дата н.а." 
   VIEW-AS FILL-IN 
   SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE mZNACH  AS decimal   FORMAT ">>>>>>>9.99":U INITIAL 0 
   LABEL "Значение" 
   VIEW-AS FILL-IN 
   SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE mDoc    AS CHARACTER FORMAT "X(256)":U 
   LABEL "Номер документа" 
   VIEW-AS FILL-IN 
   SIZE 40 BY 1 NO-UNDO.
     
DEFINE VARIABLE fStatus AS integer   init {&current-status-int}   
   LABEL "Статус" 
   VIEW-AS COMBO-BOX INNER-LINES 2
   LIST-ITEM-PAIRS "Активный",{&current-status-int},
   "Деактивирован",{&deleted-status-int}
   DROP-DOWN-LIST
   SIZE 20 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
   B-save AT ROW 1 COL 1
   b-quit AT ROW 1 COL 11
   B-Help AT ROW 1 COL 36
   mDATA AT ROW 2.5 COL 18 COLON-ALIGNED WIDGET-ID 8
   mZNACH AT ROW 4 COL 18 COLON-ALIGNED WIDGET-ID 12
   fStatus AT ROW 5.5 COL 18 COLON-ALIGNED WIDGET-ID 14     
   /*   mDoc AT ROW 7 COL 18 COLON-ALIGNED WIDGET-ID 16  */
     
     
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
   { gbl/ed_date.i mDATA }
   if v-db-num <> 0 then 
   do:
      message
         vss-workfile vss-revision vss-description skip
         "Неверное значение параметров вызова p-mode - нельзя изменять/добавлять записи <Тип ЕМЦ Код> в УБД"
         view-as alert-box ERROR.
      undo, return error.
   end.
   find first b3-code where
      b3-code.parent  = entry(1,p-parent,{&delim-par})
      and b3-code.code    = entry(2,p-parent,{&delim-par}) no-lock no-error.

   if available b3-code 
      then 
   do:
      FRAME Dialog-Frame:TITLE = "Редактирование ЕМЦ " + b3-code.codename.
      v-name = b3-code.CodeName .
   end.
   if p-mode = {&update} then 
   do:
      find first b3-code where
         recid(b3-code) = p-rid exclusive-lock no-wait no-error.

      if not available b3-code then 
      do:
         message
            vss-workfile vss-revision vss-description skip
            "Не найдена запись <Тип ЕМЦ - Код>"
            view-as alert-box error .
         undo, return error.
      end.
      assign
         mDATA   = date(b3-code.misc1)
         mZNACH  = dec(b3-code.CodeValue)
         mDoc    = b3-code.misc2
         Fstatus = b3-code.status_
         .

      vDateIsoOld = iso-date(mDATA).
   end.

   run enable_UI in this-procedure .
   if p-mode = {&add-def} then 
   do:
      ENABLE mDATA WITH FRAME Dialog-Frame.
      apply "entry" to mDATA in FRAME Dialog-Frame.
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
   DISPLAY mDATA mZNACH fStatus
      WITH FRAME Dialog-Frame.
   ENABLE B-save b-quit B-Help mDATA mZNACH fStatus
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
   define buffer b3-code for code.
   define buffer b2-code for code.

   assign frame {&frame-name}
      mDATA 
      mZNACH
      fStatus
     
      .

   define variable vDateIsoNew   as character no-undo.
   define variable vDateIsoToday as character no-undo.
   
   vDateIsoNew = iso-date(mDATA).

   do on error undo, return error
      on stop undo, return error:
      if mdata eq ?
      then do:
         message "Дата не сожет быть пустой"
         view-as alert-box.
         return error.
      end.
      find first b3-code where
         b3-code.parent = p-parent
         and b3-code.code   = vDateIsoNew
         and if p-rid eq ? then yes else recid(b3-code) ne p-rid
         no-lock no-error.
      if avail b3-code then 
      do:
         message
            "Уже есть такая запись Тип ЕМЦ Дата :" string(mDATA,"99/99/9999")
            view-as alert-box error .
         return error.
      end.
      if fStatus <> {&bef-current-status-int} then 
      do:
/*         if mDATA <= today then do:                           */
/*            find first b3-code where                          */
/*                       b3-code.parent = p-parent              */
/*                   and b3-code.code   > vDateIsoNew           */
/*                   and b3-code.code   <= iso-date(today)      */
/*            no-lock no-error.                                 */
/*            if not avail b3-code                              */
/*            then do:                                          */
/*               message "Данное значение нельзя деактивировать"*/
/*               view-as alert-box.                             */
/*               fStatus = {&bef-current-status-int} .          */
/*               return error .                                 */
/*            end.                                              */
/*         end.                                                 */
      
         find first b2-code where b2-code.parent = p-parent and
            b2-code.status_ = {&bef-current-status-int} and recid(b2-code) <> p-rid and b2-code.codevalue <> "0" no-error .
         if not available (b2-code) then 
         do:
            message "Для типа ЕМЦ - " + string(v-name) + " отсутствуют другие значения." skip
               "При деактивации значения прослеживаемость данного типа ЕМЦ для всех товаров будет отключена"
               view-as alert-box question buttons yes-no update choice as logical .
            case choice:
               when yes then 
                  do:
                     /*удаление атрибута с групп и товаров*/
                     for each ub.gds-grp-obj-attr exclusive-lock where ub.gds-grp-obj-attr.attr-code = {&ggoattr-emrc-type}
                        and ub.gds-grp-obj-attr.attr-value = string(entry(2,p-parent,{&delim-par})):
                        delete ub.gds-grp-obj-attr .
                     end.
                     for each ub.goods-attr exclusive-lock where ub.goods-attr.attr-code = {&attr-emrc-type} and
                     ub.goods-attr.attr-value = string(entry(2,p-parent,{&delim-par})):
                        delete ub.goods-attr .
                     end.
                     fStatus = {&bef-deleted-status-int} .
                  end.
                  otherwise do:
                     fStatus = {&bef-current-status-int} .
                  end.
            end case.
         end.
      end.

      find first b3-code where
         b3-code.parent = p-parent
         and b3-code.code   = vDateIsoOld
         exclusive-lock no-error.
         
      if not avail b3-code then 
      do:
         create b3-code.
      end.
      assign
         b3-code.parent    = p-parent
         b3-code.code      = vDateIsoNew
         b3-code.misc1     = string(mDATA,"99/99/9999")
         b3-code.codevalue = string(mZNACH)
         b3-code.misc2     = mDoc
         b3-code.status_   = fStatus
         b3-code.nwsgbd    = yes
         .
      p-rid = recid(b3-code).
      if mDATA > today
         then 
      do:
         find b3-code where
            b3-code.parent = p-parent
            and b3-code.code   < vDateIsoNew
            and b3-code.status_  = {&bef-current-status-int}
            no-lock no-error.
         if not avail b3-code
            then 
         do:
            if not AMBIGUOUS b3-code
            then do:
               vDateIsoToday = iso-date(today).
               find first b3-code where
                  b3-code.parent = p-parent
                  and b3-code.code   = vDateIsotoday
                  exclusive-lock no-error.
               if not avail b3-code
                  then 
               do:
                  create b3-code.
         
                  assign
                     b3-code.parent    = p-parent
                     b3-code.code      = vDateIsoToday
                     b3-code.misc1     = string(today,"99/99/9999")
                     b3-code.codevalue = "0"
                     b3-code.status_   = fStatus
                     b3-code.nwsgbd    = yes
                  .
               end.
               b3-code.status_   = fStatus.
            end.
         end.
         else do:
            if b3-code.codevalue = "0"
            then do:
               find current b3-code exclusive-lock.
               b3-code.status_   = fStatus.
            end. 
         end.
      end.
   end.

  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

