&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
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

Редактирование атрибутов заказов флористов

Автор: Чернова Светлана Александровна
Дата создания: 09/27/05
Author: Svetlana Chernova
Creation date: 09/27/05



 */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование атрибутов заказов флористов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/trdcalib.i }
{ cmp/showinf.i  }
{ str/attrlist.i }

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-mode as character no-undo.
define input parameter p-doc-code like ub.trn-doc.doc-code no-undo.

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit B-help v-date-cr l-loc-hour ~
l-loc-min v-tel v-face v-deliv-date v-start-hour v-start-min v-end-hour ~
v-end-min v-summa-bef v-Nchk-bef v-date-chk T-dost v-summa-dos v-nac v-kuda ~
v-komu 
&Scoped-Define DISPLAYED-OBJECTS v-date-cr l-loc-hour l-loc-min v-tel ~
v-face v-deliv-date v-start-hour v-start-min v-end-hour v-end-min ~
v-summa-bef v-Nchk-bef v-date-chk T-dost v-summa-dos v-nac v-kuda v-komu 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-1 l-loc-hour l-loc-min 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1.

DEFINE BUTTON B-help DEFAULT 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1.

DEFINE VARIABLE v-kuda AS CHARACTER 
     VIEW-AS EDITOR MAX-CHARS 220 SCROLLBAR-VERTICAL
     SIZE 62 BY 2 NO-UNDO.

DEFINE VARIABLE l-loc-hour AS INTEGER FORMAT "99":U INITIAL 0 
     LABEL "Время выполнения заказа" 
     VIEW-AS FILL-IN 
     SIZE 3 BY 1 TOOLTIP "Стрелка вверх, вниз изменение часа" NO-UNDO.

DEFINE VARIABLE l-loc-min AS INTEGER FORMAT "99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 3 BY 1 TOOLTIP "Стрелка вверх, вниз изменение минут" NO-UNDO.

DEFINE VARIABLE v-date-chk AS DATE FORMAT "99/99/9999":U 
     LABEL "Дата чека предоплаты" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-date-cr AS DATE FORMAT "99/99/9999":U 
     LABEL "Дата выполнения заказа" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-deliv-date AS DATE FORMAT "99/99/9999":U 
     LABEL "Дата доставки" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-end-hour AS INTEGER FORMAT "99":U INITIAL 23 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE v-end-min AS INTEGER FORMAT "99":U INITIAL 59 
     LABEL "" 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE v-face AS CHARACTER FORMAT "X(256)":U 
     LABEL "Контактное лицо" 
     VIEW-AS FILL-IN 
     SIZE 38 BY 1 NO-UNDO.

DEFINE VARIABLE v-komu AS CHARACTER FORMAT "X(256)":U 
     LABEL "Кому" 
     VIEW-AS FILL-IN 
     SIZE 62 BY 1 NO-UNDO.

DEFINE VARIABLE v-nac AS DECIMAL FORMAT "->>,>>9.9<<<<":U INITIAL 0 
     LABEL "Наценка за работу,%" 
     VIEW-AS FILL-IN 
     SIZE 14.6 BY 1 NO-UNDO.

DEFINE VARIABLE v-Nchk-bef AS CHARACTER FORMAT "X(256)":U 
     LABEL "№ чека предоплаты" 
     VIEW-AS FILL-IN 
     SIZE 23 BY 1 NO-UNDO.

DEFINE VARIABLE v-start-hour AS INTEGER FORMAT "99":U INITIAL 0 
     LABEL "Время доставки" 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE v-start-min AS INTEGER FORMAT "99":U INITIAL 0 
     LABEL "" 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE v-summa-bef AS DECIMAL FORMAT "->>>>,>>9.99":U INITIAL 0 
     LABEL "Сумма предоплаты" 
     VIEW-AS FILL-IN 
     SIZE 14.6 BY 1 NO-UNDO.

DEFINE VARIABLE v-summa-dos AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     LABEL "Сумма доставки,(баз.вал.)" 
     VIEW-AS FILL-IN 
     SIZE 14.6 BY 1 NO-UNDO.

DEFINE VARIABLE v-tel AS CHARACTER FORMAT "X(256)":U 
     LABEL "Контактный телефон" 
     VIEW-AS FILL-IN 
     SIZE 38 BY 1 NO-UNDO.

DEFINE VARIABLE T-dost AS LOGICAL INITIAL no 
     LABEL "Доставка" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.2 BY .81 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-help AT ROW 1 COL 81
     v-date-cr AT ROW 3.1 COL 26.2 COLON-ALIGNED
     l-loc-hour AT ROW 4.19 COL 27.6 COLON-ALIGNED
     l-loc-min AT ROW 4.19 COL 32 COLON-ALIGNED NO-LABEL
     v-tel AT ROW 5.24 COL 26 COLON-ALIGNED
     v-face AT ROW 6.24 COL 26 COLON-ALIGNED
     v-deliv-date AT ROW 7.24 COL 26 COLON-ALIGNED WIDGET-ID 2
     v-start-hour AT ROW 8.24 COL 26 COLON-ALIGNED WIDGET-ID 4
     v-start-min AT ROW 8.24 COL 31.8 COLON-ALIGNED WIDGET-ID 6
     v-end-hour AT ROW 8.24 COL 38.6 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     v-end-min AT ROW 8.24 COL 44.4 COLON-ALIGNED WIDGET-ID 10
     v-summa-bef AT ROW 9.24 COL 26 COLON-ALIGNED
     v-Nchk-bef AT ROW 10.24 COL 26 COLON-ALIGNED
     v-date-chk AT ROW 11.24 COL 26 COLON-ALIGNED
     T-dost AT ROW 12.24 COL 28
     v-summa-dos AT ROW 13.24 COL 27.2 COLON-ALIGNED
     v-nac AT ROW 14.24 COL 26 COLON-ALIGNED
     v-kuda AT ROW 15.24 COL 28 NO-LABEL
     v-komu AT ROW 17.52 COL 26 COLON-ALIGNED
     "Адрес доставки:" VIEW-AS TEXT
          SIZE 16.6 BY .67 AT ROW 15.43 COL 10.8
     "-" VIEW-AS TEXT
          SIZE 1 BY .62 AT ROW 8.43 COL 38.8 WIDGET-ID 12
     ":" VIEW-AS TEXT
          SIZE 1.2 BY 1 AT ROW 4.19 COL 32.8
          FGCOLOR 1 
     SPACE(57.37) SKIP(15.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Информация о заказе".


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
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN l-loc-hour IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN l-loc-min IN FRAME Dialog-Frame
   1                                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Информация о заказе */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
 RUN save-proc no-error .
 if error-status :error then return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-loc-hour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour Dialog-Frame
ON CURSOR-DOWN OF l-loc-hour IN FRAME Dialog-Frame /* Время выполнения заказа */
DO:
  assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} -  1.
  if {&SELF-NAME} < 0 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour Dialog-Frame
ON CURSOR-UP OF l-loc-hour IN FRAME Dialog-Frame /* Время выполнения заказа */
DO:
  assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} +  1.
  if {&SELF-NAME} > 24 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour Dialog-Frame
ON LEAVE OF l-loc-hour IN FRAME Dialog-Frame /* Время выполнения заказа */
DO:
    assign frame {&frame-name} {&SELF-NAME} .
   if {&SELF-NAME} > 24 then do:
   message "Часы должны быть   до 24 ! " .
   return no-apply.
   end.
    if {&SELF-NAME} < 0 then do:
   message "Часы должны быть  от 0 до 24 ! " .
   return no-apply.

   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour Dialog-Frame
ON return OF l-loc-hour IN FRAME Dialog-Frame /* Время выполнения заказа */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-loc-min
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min Dialog-Frame
ON CURSOR-DOWN OF l-loc-min IN FRAME Dialog-Frame
DO:
  assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} -  1.
  if {&SELF-NAME} < 0 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min Dialog-Frame
ON CURSOR-UP OF l-loc-min IN FRAME Dialog-Frame
DO:
   assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} +  1.
  if {&SELF-NAME} > 59 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min Dialog-Frame
ON LEAVE OF l-loc-min IN FRAME Dialog-Frame
DO:
   assign frame {&frame-name} {&SELF-NAME} .
   if {&SELF-NAME} > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min Dialog-Frame
ON return OF l-loc-min IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-dost
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-dost Dialog-Frame
ON return OF T-dost IN FRAME Dialog-Frame /* Доставка */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-date-chk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-date-chk Dialog-Frame
ON return OF v-date-chk IN FRAME Dialog-Frame /* Дата чека предоплаты */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-date-cr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-date-cr Dialog-Frame
ON return OF v-date-cr IN FRAME Dialog-Frame /* Дата выполнения заказа */
DO:
  run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-end-hour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-end-hour Dialog-Frame
ON LEAVE OF v-end-hour IN FRAME Dialog-Frame
DO:
  assign frame {&frame-name}
  v-start-hour
  v-start-min
  v-end-hour
  v-end-min
  .
  if v-start-min + (v-start-hour * 60) > v-end-min + (v-end-hour * 60) then do:
     message "Конечное время периода доставки не может быть меньше начального" view-as alert-box.
     v-end-min:screen-value = v-start-min:screen-value.
     v-end-min = v-start-min.
     v-end-hour:screen-value = v-start-hour:screen-value.
     v-end-hour = v-start-hour.
  end.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-end-hour Dialog-Frame
ON VALUE-CHANGED OF v-end-hour IN FRAME Dialog-Frame
DO:
  assign v-end-hour.
  if v-end-hour > 23 then do:
    v-end-hour = 23. 
    v-end-hour:screen-value = "23".
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME v-end-min
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-end-min Dialog-Frame
ON LEAVE OF v-end-min IN FRAME Dialog-Frame
DO:
  assign frame {&frame-name}
  v-start-hour
  v-start-min
  v-end-hour
  v-end-min
  .
  if v-start-min + (v-start-hour * 60) > v-end-min + (v-end-hour * 60) then do:
     message "Конечное время периода доставки не может быть меньше начального" view-as alert-box.
     v-end-min:screen-value = v-start-min:screen-value.
     v-end-min = v-start-min.
     v-end-hour:screen-value = v-start-hour:screen-value.
     v-end-hour = v-start-hour.
  end.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-end-min Dialog-Frame
ON VALUE-CHANGED OF v-end-min IN FRAME Dialog-Frame
DO:
  assign v-end-min.
  if v-end-min > 59 then do:
    v-end-min = 59.
    v-end-min:screen-value = "59".  
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME v-face
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-face Dialog-Frame
ON return OF v-face IN FRAME Dialog-Frame /* Контактное лицо */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-komu
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-komu Dialog-Frame
ON return OF v-komu IN FRAME Dialog-Frame /* Кому */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-kuda
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-kuda Dialog-Frame
ON return OF v-kuda IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-nac
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-nac Dialog-Frame
ON return OF v-nac IN FRAME Dialog-Frame /* Наценка за работу,% */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-Nchk-bef
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-Nchk-bef Dialog-Frame
ON return OF v-Nchk-bef IN FRAME Dialog-Frame /* № чека предоплаты */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-start-hour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-start-hour Dialog-Frame
ON LEAVE OF v-start-hour IN FRAME Dialog-Frame /* Время доставки */
DO:
  assign frame {&frame-name}
  v-start-hour
  v-start-min
  v-end-hour
  v-end-min
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-start-hour Dialog-Frame
ON VALUE-CHANGED OF v-start-hour IN FRAME Dialog-Frame /* Время доставки */
DO:
  assign v-start-hour.
  if v-start-hour > 23 then do:
    v-start-hour = 23.
    v-start-hour:screen-value = "23". 
  end.    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME v-start-min
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-start-min Dialog-Frame
ON LEAVE OF v-start-min IN FRAME Dialog-Frame
DO:
  assign frame {&frame-name}
  v-start-hour
  v-start-min
  v-end-hour
  v-end-min
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-start-min Dialog-Frame
ON VALUE-CHANGED OF v-start-min IN FRAME Dialog-Frame
DO:
  assign v-start-min.
  if v-start-min > 59 then do:
    v-start-min = 59. 
    v-start-min:screen-value = "59".
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME v-summa-bef
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-summa-bef Dialog-Frame
ON return OF v-summa-bef IN FRAME Dialog-Frame /* Сумма предоплаты */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-summa-dos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-summa-dos Dialog-Frame
ON return OF v-summa-dos IN FRAME Dialog-Frame /* Сумма доставки,(баз.вал.) */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-tel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-tel Dialog-Frame
ON return OF v-tel IN FRAME Dialog-Frame /* Контактный телефон */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

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
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK :

   define buffer buf_trn-doc for ub.trn-doc  .
   find first buf_trn-doc no-lock where buf_trn-doc.doc-code = p-doc-code no-error .

   if not available buf_trn-doc then do:
     return error return-value .
   end.

  RUN init_proc.
  if p-mode = {&lookup} then do:
     RUN sel_UI.
     WAIT-FOR GO OF FRAME {&FRAME-NAME} .
  end.
  else do:
      if buf_trn-doc.status_ = {&inquiry} and buf_trn-doc.flag_ = false  then do:
        RUN enable_UI.
        WAIT-FOR GO OF FRAME {&FRAME-NAME} focus v-date-cr.
      end.
      else do:
          if buf_trn-doc.status_ = {&wayb} and buf_trn-doc.flag_ = false  then do:
            RUN nakl_UI.
            WAIT-FOR GO OF FRAME {&FRAME-NAME} focus v-date-cr.
          end.
          else do:
            RUN sel_UI.
            WAIT-FOR GO OF FRAME {&FRAME-NAME} .
          end.
      end.
  end.
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
  DISPLAY v-date-cr l-loc-hour l-loc-min v-tel v-face v-deliv-date v-start-hour 
          v-start-min v-end-hour v-end-min v-summa-bef v-Nchk-bef v-date-chk 
          T-dost v-summa-dos v-nac v-kuda v-komu 
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit B-help v-date-cr l-loc-hour l-loc-min v-tel v-face 
         v-deliv-date v-start-hour v-start-min v-end-hour v-end-min v-summa-bef 
         v-Nchk-bef v-date-chk T-dost v-summa-dos v-nac v-kuda v-komu 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init_proc Dialog-Frame 
PROCEDURE init_proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable p-type   as character no-undo .
define variable p-value  as character no-undo .

{ str/tdat-val.i p-doc-code {&trdcattr-frsrv-date}  p-value p-type }
    v-date-cr = DATE( p-value ) .
{ str/tdat-val.i p-doc-code {&trdcattr-ord_time}    p-value p-type }
    if num-entries(p-value, ":") > 1 then l-loc-hour  = INT(ENTRY ( 1 , p-value , ":" )) no-error .
    if num-entries(p-value, ":") > 1 then  l-loc-min   = INT(ENTRY ( 2 , p-value , ":" )) no-error .
{ str/tdat-val.i p-doc-code {&trdcattr-befpay}      p-value p-type }
    v-summa-bef =  DECIMAL(p-value).
{ str/tdat-val.i p-doc-code {&trdcattr-ord_Nchek}   p-value p-type }
    v-Nchk-bef  = p-value.
{ str/tdat-val.i p-doc-code {&trdcattr-deliv}       p-value p-type }
    v-summa-dos = DECIMAL(p-value) .
{ str/tdat-val.i p-doc-code {&trdcattr-sumwrk}      p-value p-type }
    v-nac       = DECIMAL(p-value) .
{ str/tdat-val.i p-doc-code {&trdcattr-ord_contact} p-value p-type }
    v-face      =  p-value      .
{ str/tdat-val.i p-doc-code {&trdcattr-ord_phone}   p-value p-type }
    v-tel       =  p-value      .
{ str/tdat-val.i p-doc-code {&trdcattr-ord_dl}      p-value p-type }
    T-dost      =  if p-value = "yes" then true else false  .
{ str/tdat-val.i p-doc-code {&trdcattr-dchek}       p-value p-type }
    v-date-chk  = DATE(p-value)  .
{ str/tdat-val.i p-doc-code {&trdcattr-ord_adr}     p-value p-type }
    v-kuda      =     p-value   .
{ str/tdat-val.i p-doc-code {&trdcattr-ord_hwo}     p-value p-type }
    v-komu      =     p-value   .
{ str/tdat-val.i p-doc-code {&trdcattr-delivery-date}     p-value p-type }
    v-deliv-date      =     date(p-value)   .
{ str/tdat-val.i p-doc-code {&trdcattr-delivery-time}     p-value p-type }
 if num-entries(p-value, ":") > 1 then 
    do:
        v-start-hour      =     int(replace(entry(1, entry(1, p-value, "-"), ":")," ",""))   .
        v-start-min       =     int(replace(entry(2, entry(1, p-value, "-"), ":")," ",""))   .
        v-end-hour        =     int(replace(entry(1, entry(2, p-value, "-"), ":")," ",""))  .
        v-end-min         =     int(replace(entry(2, entry(2, p-value, "-"), ":")," ",""))   .
    end.
    
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE nakl_UI Dialog-Frame 
PROCEDURE nakl_UI :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DISPLAY v-date-cr l-loc-hour l-loc-min v-tel v-face v-summa-bef v-Nchk-bef
          v-date-chk T-dost v-summa-dos v-nac v-kuda v-komu
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit B-help v-date-cr l-loc-hour l-loc-min v-tel v-face
         v-nac v-kuda
         v-komu
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE next-focus Dialog-Frame 
PROCEDURE next-focus :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter p-widget-handle as handle no-undo .

  do with frame {&frame-name} :
    if  v-date-cr   :handle = p-widget-handle then do:  if l-loc-hour    :sensitive then do: apply "entry":u to l-loc-hour . return . end. end.
    if  l-loc-hour  :handle = p-widget-handle then do:  if l-loc-min     :sensitive then do: apply "entry":u to l-loc-min  . return . end. end.
    if  l-loc-min   :handle = p-widget-handle then do:  if v-tel         :sensitive then do: apply "entry":u to v-tel      . return . end. end.
    if  v-tel       :handle = p-widget-handle then do:  if v-face        :sensitive then do: apply "entry":u to v-face     . return . end. end.
    if  v-face      :handle = p-widget-handle then do:  if v-deliv-date   :sensitive then do: apply "entry":u to v-deliv-date. return . end.
                                                                                    else do: apply "entry":u to v-nac      . return . end.
                                                                                    end.
if  v-deliv-date :handle = p-widget-handle then do:  if v-start-hour        :sensitive then do: apply "entry":u to v-start-hour     . return . end. end.
if  v-start-hour :handle = p-widget-handle then do:  if v-start-min        :sensitive then do: apply "entry":u to v-start-min     . return . end. end.
if  v-start-min :handle = p-widget-handle then do:  if v-end-hour        :sensitive then do: apply "entry":u to v-end-hour     . return . end. end.
if  v-end-hour :handle = p-widget-handle then do:  if v-end-min        :sensitive then do: apply "entry":u to v-end-min     . return . end. end.
if  v-end-min :handle = p-widget-handle then do:  if v-summa-bef        :sensitive then do: apply "entry":u to v-summa-bef     . return . end. end.
    if  v-summa-bef :handle = p-widget-handle then do:  if v-Nchk-bef    :sensitive then do: apply "entry":u to v-Nchk-bef . return . end. end.
    if  v-Nchk-bef  :handle = p-widget-handle then do:  if v-date-chk    :sensitive then do: apply "entry":u to v-date-chk . return . end. end.
    if  v-date-chk  :handle = p-widget-handle then do:  if T-dost        :sensitive then do: apply "entry":u to T-dost     . return . end. end.
    if  T-dost      :handle = p-widget-handle then do:  if v-summa-dos   :sensitive then do: apply "entry":u to v-summa-dos. return . end. end.
    if  v-summa-dos :handle = p-widget-handle then do:  if v-nac         :sensitive then do: apply "entry":u to v-nac      . return . end. end.
    if  v-nac       :handle = p-widget-handle then do:  if v-kuda        :sensitive then do: apply "entry":u to v-kuda     . return . end. end.
    if  v-kuda      :handle = p-widget-handle then do:  if v-komu        :sensitive then do: apply "entry":u to v-komu     . return . end. end.
    if  v-komu      :handle = p-widget-handle then do:  if b-exit        :sensitive then do: apply "entry":u to b-exit     . return . end. end.

  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-proc Dialog-Frame 
PROCEDURE save-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable p-value  as character no-undo .
assign frame {&frame-name}
  v-date-cr
  l-loc-hour
  l-loc-min
  v-tel
  v-face
  v-summa-bef
  v-Nchk-bef
  v-date-chk
  T-dost
  v-summa-dos
  v-nac
  v-kuda
  v-komu
  v-deliv-date
  v-start-hour
  v-start-min
  v-end-hour
  v-end-min
.

    p-value = string( v-date-cr, "99/99/9999" ) .
{ str/tdat-wrt.i p-doc-code {&trdcattr-frsrv-date}  p-value }
{ str/tdat-oth.i p-doc-code {&trdcattr-frsrv-date}  p-value }
    p-value = string(l-loc-hour, "99") + ":" + string(l-loc-min ,"99") .
{ str/tdat-wrt.i p-doc-code {&trdcattr-ord_time}    p-value }
    p-value = string(v-summa-bef) .
{ str/tdat-wrt.i p-doc-code {&trdcattr-befpay}      p-value }
    p-value = v-Nchk-bef.
{ str/tdat-wrt.i p-doc-code {&trdcattr-ord_Nchek}   p-value }
    p-value = string(v-summa-dos) .
{ str/tdat-wrt.i p-doc-code {&trdcattr-deliv}       p-value }
    p-value = string(v-nac) .
{ str/tdat-wrt.i p-doc-code {&trdcattr-sumwrk}      p-value }
    p-value  = v-face    .
{ str/tdat-wrt.i p-doc-code {&trdcattr-ord_contact} p-value }
    p-value = v-tel     .
{ str/tdat-wrt.i p-doc-code {&trdcattr-ord_phone}   p-value }
    p-value = string(T-dost,"yes/no") .
{ str/tdat-wrt.i p-doc-code {&trdcattr-ord_dl}      p-value }
    p-value  = string(v-date-chk , "99/99/9999" )  .
{ str/tdat-wrt.i p-doc-code {&trdcattr-dchek}       p-value }
    p-value  = v-kuda  .
{ str/tdat-wrt.i p-doc-code {&trdcattr-ord_adr}     p-value }
    p-value  = v-komu  .
{ str/tdat-wrt.i p-doc-code {&trdcattr-ord_hwo}     p-value }
    p-value  = string(v-deliv-date)  .
{ str/tdat-wrt.i p-doc-code {&trdcattr-delivery-date}     p-value }
    p-value  = string(v-start-hour, "99") + ":" + string(v-start-min, "99") + "-" + string(v-end-hour, "99") + ":" + string(v-end-min, "99").
{ str/tdat-wrt.i p-doc-code {&trdcattr-delivery-time}     p-value }

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sel_UI Dialog-Frame 
PROCEDURE sel_UI :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DISPLAY v-date-cr l-loc-hour l-loc-min v-tel v-face v-summa-bef v-Nchk-bef
          v-date-chk T-dost v-summa-dos v-nac v-kuda v-komu v-deliv-date v-start-hour v-start-min v-end-hour v-end-min
      WITH FRAME Dialog-Frame.
      b-exit:label = "Вы&ход" .
  ENABLE b-exit B-help
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

