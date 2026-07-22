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

Карточка сезонов ДТ

Автор: Ростовцев Александр
Дата создания: 29/08/23
Author: Rostovtsev Aleksandr
Creation date: 29/08/23


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter iParentProc as widget-handle no-undo.
define input  parameter iCodeTrg    as class ibs.th.ref.code.code_trg no-undo.
define input  parameter iMode       as character     no-undo.
define input  parameter iCode       as handle        no-undo.
define output parameter oIsOk       as logical       no-undo.

&Scoped-define CODE_PARENT "DTSeasons"

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: $":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile: $":U .
define variable vss-archive     as character no-undo init "$Archive: $":U .
define variable vss-description as character no-undo init "Карточка сезонов ДТ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ trg/new-bcod.i }
define variable v-db-num like ub.db.db-num                no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-save b-quit B-Help f-codename ~
b-copy-codename f-misc1 f-misc2 f-misc3 b-misc3 
&Scoped-Define DISPLAYED-OBJECTS f-code f-codename f-misc1 f-misc2 f-misc3 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-copy-codename 
     LABEL "Копир." 
     SIZE 10 BY 1.

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-misc3 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "unit" 
     SIZE 2.8 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-save AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-misc2 AS INTEGER FORMAT ">9":U INITIAL 0 
     LABEL "НДС в ПЦ" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "0" 
     DROP-DOWN-LIST
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE f-code AS CHARACTER FORMAT "X(30)":U INITIAL "генерируется автоматически" 
     LABEL "Код" 
     VIEW-AS FILL-IN 
     SIZE 55 BY 1 NO-UNDO.

DEFINE VARIABLE f-codename AS CHARACTER FORMAT "X(50)":U 
     LABEL "Название в чеке" 
     VIEW-AS FILL-IN 
     SIZE 44 BY 1 NO-UNDO.

DEFINE VARIABLE f-misc1 AS CHARACTER FORMAT "X(50)":U 
     LABEL "Альт.название" 
     VIEW-AS FILL-IN 
     SIZE 44 BY 1 NO-UNDO.

DEFINE VARIABLE f-misc3 AS CHARACTER FORMAT "X(10)":U 
     LABEL "ЕИ в ПЦ" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 TOOLTIP "Выберите из справочника, нажав кнопку справа" NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-save AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 36
     f-code AT ROW 2.52 COL 18 COLON-ALIGNED WIDGET-ID 2
     f-codename AT ROW 3.76 COL 18 COLON-ALIGNED WIDGET-ID 4
     b-copy-codename AT ROW 3.76 COL 64.8 WIDGET-ID 18
     f-misc1 AT ROW 5.05 COL 18 COLON-ALIGNED WIDGET-ID 10
     f-misc2 AT ROW 6.24 COL 18 COLON-ALIGNED WIDGET-ID 20
     f-misc3 AT ROW 7.43 COL 18 COLON-ALIGNED WIDGET-ID 14
     b-misc3 AT ROW 7.43 COL 34.6 WIDGET-ID 12
     SPACE(38.59) SKIP(0.94)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Сезон ДТ"
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

/* SETTINGS FOR FILL-IN f-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       f-misc3:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Сезон ДТ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-copy-codename
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-copy-codename Dialog-Frame
ON CHOOSE OF b-copy-codename IN FRAME Dialog-Frame /* Копир. */
DO:
  run setMisc1 in this-procedure (true).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-misc3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-misc3 Dialog-Frame
ON CHOOSE OF b-misc3 IN FRAME Dialog-Frame /* unit */
DO:
   define buffer units for units.
   define variable vRec as recid no-undo .

   do on error undo, return no-apply:
      run ref/units.w
            (input  iParentProc
            ,input  yes
            ,output vRec
            ).
      if vRec <> ? then do:
         find first units where recid(units) = vRec no-lock no-error.
         if avail units then do:
            display units.unit-name @ f-misc3 WITH FRAME Dialog-Frame.
         end.
      end.
   end.
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


&Scoped-define SELF-NAME f-codename
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-codename Dialog-Frame
ON LEAVE OF f-codename IN FRAME Dialog-Frame /* Название в чеке */
DO:
  run setMisc1 in this-procedure (false).
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
   if iMode <> {&add-def} and
      iMode <> {&update} and
      iMode <> {&add-copy} and
      iMode <> {&lookup}
   then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова iMode"  iMode
      view-as alert-box ERROR.
      undo, return error.
   end.
   { gbl/curdbnum.i v-db-num }
 
   if v-db-num <> 0 and iMode <> {&lookup} then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова iMode - нельзя изменять/добавлять записи <Сезоны ДТ> в УБД"
      view-as alert-box ERROR.
      undo, return error.
   end.

   run getMisc2 in this-procedure.

   frame {&frame-name}:title = frame {&frame-name}:title + " - " + lc(iMode).
   if iMode = {&update} or iMode = {&add-copy} or iMode = {&lookup} then do:

      assign
        f-code     = iCode:buffer-field('code'):buffer-value when iMode = {&update} or iMode = {&lookup}
        f-codename = iCode:buffer-field('codename'):buffer-value
        f-misc1    = iCode:buffer-field('misc1'):buffer-value
        f-misc2    = iCode:buffer-field('misc2'):buffer-value
        f-misc3    = iCode:buffer-field('misc3'):buffer-value
      no-error.
   end.

   if iMode = {&add-def} then do:
      assign
        f-misc2    = 20
        f-misc3    = "лт"
      no-error.
   end.

   run enable_UI in this-procedure.
   if iMode = {&lookup} then do:
     disable
       f-codename
       f-misc1
       f-misc2
       f-misc3
       b-save
     with frame {&frame-name}.  
     b-copy-codename:visible = false.
     b-misc3:visible = false.
   end.
   else do:
     apply "entry" to f-codename in FRAME Dialog-Frame.
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
  DISPLAY f-code f-codename f-misc1 f-misc2 f-misc3 
      WITH FRAME Dialog-Frame.
  ENABLE B-save b-quit B-Help f-codename b-copy-codename f-misc1 f-misc2 
         f-misc3 b-misc3 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getMisc2 Dialog-Frame 
PROCEDURE getMisc2 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
define buffer buf_tax            for ub.tax.
define buffer buf_tax-rate       for ub.tax-rate.
define buffer buf_tax-rate-value for ub.tax-rate-value.

define variable vListRates as character no-undo.

do with frame {&frame-name}:
    f-misc2:delete(1).

    run getListTaxRateValue in g#library
      ("НДС", ?, 0, "", 0, output vListRates).
    f-misc2:list-items = vListRates.
end.

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
   define variable nextCode as integer no-undo.
   define buffer units for units.
   assign frame {&frame-name}
      f-codename
      f-misc1
      f-misc2
      f-misc3
   .
   
   if f-codename = "" then do:
     message "Ошибка при сохранении.~n"
             "Необходимо заполнить поле <Название в чеке>." view-as alert-box.
     apply "ENTRY" to f-codename in frame {&frame-name}.
     return error.
   end.
   do on error undo, return error
   on stop undo, return error:
      if iMode = {&add-def} or iMode = {&add-copy} then do:
         run gen-b-code IN THIS-PROCEDURE (
           input {&gbl-bc-code}
           ,output nextCode
         ) no-error.
         if error-status:error then 
         do:
           undo, return error return-value.
         end.
         assign
            iCode:buffer-field("parent"):buffer-value = {&CODE_PARENT}
            iCode:buffer-field("code"):buffer-value   = string(nextCode)
            iCode:buffer-field("status_"):buffer-value = 0
         .
      end.
      assign
        iCode:buffer-field("codename"):buffer-value = f-codename
        iCode:buffer-field("misc1"):buffer-value    = f-misc1
        iCode:buffer-field("misc2"):buffer-value    = f-misc2
        iCode:buffer-field("misc3"):buffer-value    = f-misc3
        iCode:buffer-field("export_"):buffer-value    = yes
        iCode:buffer-field("nwsgbd"):buffer-value    = yes
      .
   end.
   oIsOk = true.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setMisc1 Dialog-Frame 
PROCEDURE setMisc1 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
define input parameter setForcibly as logical no-undo.

do with frame {&frame-name}:
    if f-codename:screen-value <> "" and 
       (setForcibly or f-misc1:screen-value = "") then 
    do:
      f-misc1:screen-value = substring(f-codename:screen-value,1,22).
    end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

