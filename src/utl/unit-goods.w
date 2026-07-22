&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Откат архивации по чекам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

define input parameter parparentproc as widget-handle no-undo .

/* ***************************  Definitions  ************************** */
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define stream imp-str.
define variable v-list        as character no-undo .
DEFINE VARIABLE v-ok          AS logical   no-undo .
define variable char-gds-code as character no-undo . 
define variable unit-rec      as recid     no-undo .
define variable v-rid         as recid     no-undo .
define variable agnt-list     as character no-undo .
define variable v-host-code as integer no-undo .

define buffer buf_goods    for ub.goods .
define buffer buf_bar-code for ub.bar-code .
define buffer buf_gds-prt  for ub.gds-prt .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OK Btn_Cancel b-help b-unit f-goods ~
b-goods b-goods-contract f-index 
&Scoped-Define DISPLAYED-OBJECTS f-unit f-goods f-index 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-goods 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .88.

DEFINE BUTTON b-goods-contract 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .88 TOOLTIP "Выбор договора".

DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 11 BY 1.

DEFINE BUTTON b-unit 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .88.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
     LABEL "Отмена" 
     SIZE 11 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO 
     LABEL "&Привязать" 
     SIZE 11 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-goods AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 30 BY 4 NO-UNDO.

DEFINE VARIABLE f-index AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     LABEL "Коэффициент" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-unit AS CHARACTER FORMAT "X(256)":U 
     LABEL "Единица измерения" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1
     BGCOLOR 15  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 12
     b-help AT ROW 1 COL 52 WIDGET-ID 2
     f-unit AT ROW 4 COL 24 COLON-ALIGNED WIDGET-ID 4
     b-unit AT ROW 4.08 COL 40.25 WIDGET-ID 60
     f-goods AT ROW 5.25 COL 26 NO-LABEL WIDGET-ID 70
     b-goods AT ROW 5.25 COL 56.5 WIDGET-ID 64
     b-goods-contract AT ROW 6.25 COL 56.5 WIDGET-ID 72
     f-index AT ROW 9.54 COL 24 COLON-ALIGNED WIDGET-ID 14
     "Список товаров:" VIEW-AS TEXT
          SIZE 15.5 BY .67 AT ROW 5.46 COL 9.88 WIDGET-ID 68
     SPACE(38.36) SKIP(7.15)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Привязать ед.изм. к товарам"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-unit IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Привязать ед.изм. к товарам */
DO:
      APPLY "END-ERROR":U TO SELF.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-goods Dialog-Frame
ON CHOOSE OF b-goods IN FRAME Dialog-Frame
DO:
      define variable i as integer no-undo .
      assign f-goods .
      run ref/gds-ref.p (parparentproc, 'b-sel,b-mark', ?, ?, ?, ?, ?, ?, ?, v-cntxt-obj-type, v-cntxt-obj-code, ?, output v-list) no-error.
      if error-status:error or v-list = ? or v-list = "" then 
      do:
         message "Ошибка при выборе товара для добавления в справочник." view-as alert-box.
         return no-apply.
      end.
      v-ok = false.

      repeat i = 1 to num-entries (v-list) :
         for first ub.goods no-lock where recid(ub.goods) =  integer (entry (i, v-list))
            :
         if lookup(string(ub.goods.gds-code),char-gds-code) = 0 then do:               
            f-goods = f-goods + "," + {&new-line} + string(ub.goods.gds-name).
            char-gds-code = char-gds-code + "," + string(ub.goods.gds-code).
         end.
         end.
         f-goods = trim(f-goods, "," + {&new-line}) .
         char-gds-code = trim(char-gds-code,",") .
               
      end.

      display f-goods with frame {&frame-name} .
   end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-goods-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-goods-contract Dialog-Frame
ON CHOOSE OF b-goods-contract IN FRAME Dialog-Frame
DO:
      define variable i as integer no-undo .
      define buffer buf_contract for ub.contract .
      define buffer buf_contract-specif for ub.contract-specif .
      
      assign f-goods .
      
      run str/cont-all.w ( input  parParentProc, 
                           input v-cntxt-host-code-obj, 
                           input "b-sel,b-mark":U, 
                           input {&all}, 
                           input ?, 
                           input ?, 
                           input  ?, 
                           input  ?, 
                           input  "current", 
                           input "all" , 
                           input-output agnt-list   ) no-error .
      if error-status:error or agnt-list = ? or agnt-list = "" then 
      do:
         message "Ошибка при выборе договора для добавления в справочник." view-as alert-box.
         return no-apply.
      end.
      v-ok = false.

      repeat i = 1 to num-entries (agnt-list) :
         for first buf_contract no-lock where recid(buf_contract) = integer (entry (i, agnt-list)):
            for each buf_contract-specif no-lock where buf_contract-specif.host-code = buf_contract.host-code and
                                                       buf_contract-specif.contract-num = buf_contract.contract-code,
               first buf_goods no-lock where buf_goods.gds-code = buf_contract-specif.gds-code:
            if lookup(string(buf_goods.gds-code),char-gds-code) = 0 then do:
            f-goods = f-goods + "," + {&new-line} + string(buf_goods.gds-name).
            char-gds-code = char-gds-code + "," + string(buf_goods.gds-code).
            end .
         end.
         end.
         f-goods = trim(f-goods, "," + {&new-line}) .
         char-gds-code = trim(char-gds-code,",") .
               
      end.

      display f-goods with frame {&frame-name} .
   end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-unit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-unit Dialog-Frame
ON CHOOSE OF b-unit IN FRAME Dialog-Frame
DO:
      assign f-unit .
      run ref/units.w ( input parparentproc
         , input yes
         , output unit-rec ).
      for first ub.units no-lock where recid(ub.units) = unit-rec:
         f-unit:screen-value = ub.units.unit-name .
      end.   
      assign f-unit .   
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Привязать */
DO:
      if f-unit = "" or f-goods = "" or f-index = 0 then 
      do:
         message "Не все данные заполнены"
            view-as alert-box.
         return no-apply .
      end.
  
      run proc-create no-error .
      if error-status:error then 
      do:
         message "Ошибка привязки"
            view-as alert-box.
      end.                      
  
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-index
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-index Dialog-Frame
ON LEAVE OF f-index IN FRAME Dialog-Frame /* Коэффициент */
DO:

      assign f-index .
  
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
   RUN enable_UI.
   WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
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
  DISPLAY f-unit f-goods f-index 
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel b-help b-unit f-goods b-goods b-goods-contract 
         f-index 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-create Dialog-Frame 
PROCEDURE proc-create :
/*------------------------------------------------------------------------------
        Purpose:     
        Parameters:  <none>
        Notes:       
      ------------------------------------------------------------------------------*/
   define variable ii   as integer no-undo .
   define variable v-ok as logical no-undo .

   do ii = 1 to num-entries (char-gds-code) :
      /*идем по списку товаров*/
      for first buf_goods no-lock where buf_goods.gds-code =  integer (entry (ii, char-gds-code)):
         /*ищем ед.измерения*/
         find first buf_bar-code exclusive-lock where buf_bar-code.gds-code = buf_goods.gds-code and
            buf_bar-code.unit-cli = f-unit no-error .
         if available (buf_bar-code) then 
         do:
            message "К товару " + buf_goods.gds-name + " уже привязана единица измерения " + f-unit skip
               "с коэффициентом пересчета " + string(buf_bar-code.cli-base-rate) skip
               "Установить коэффициент " + string(f-index) skip
               view-as alert-box question buttons yes-no update v-ok .
            if v-ok then 
            do:
               buf_bar-code.cli-base-rate = f-index .
            end.   
            end.
            else 
            do:
               for first buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code:
                  run ref/barcode1.p (
                     input {&add-def}
                     ,input no /*p-silent*/
                     ,input 0
                     ,input buf_goods.gds-code
                     ,input buf_bar-code.node-code
                     ,input buf_bar-code.part-code
                     ,input buf_bar-code.in-code
                     ,input f-unit
                     ,input f-index
                     ,output v-rid) no-error.
               end.        
            end.                                                      
         end.
   end.   
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

