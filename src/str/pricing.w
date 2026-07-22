&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Настройки ценообразованиЯ

Автор: Чернова Светлана Александровна
Дата создания: 11/08/05
Author: Svetlana Chernova
Creation date: 11/08/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentProc as handle no-undo .
define input  parameter v-db-num as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Настройки ценообразования ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

/* Local Variable Definitions ---                                       */
define buffer buf_global-state for ub.global-state  .
define buffer buf_global-state-attr for ub.global-state-attr  .
define variable v-val1 as decimal   no-undo .
define variable v-val2 as decimal   no-undo .
define variable v-prc as decimal   no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-OK B-Cancel B-Help T-main-price-list ~
T-group-buer T-summ-oborot T-group-qnty T-group-summ T-no-base-edizm R-date ~
T-currency T-cass T-pay-type T-cash-pay T-child T-pal-nws ~
FILL-IN-1
&Scoped-Define DISPLAYED-OBJECTS T-main-price-list T-group-buer ~
T-summ-oborot T-group-qnty T-group-summ T-no-base-edizm R-date T-currency ~
T-cass T-pay-type T-cash-pay T-child T-pal-nws FILL-IN-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */

DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 5.5 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-OK AUTO-GO
     LABEL "&Ввод"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE R-date AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Только дата объекта", 0,
"Сменная дата объекта(Смена+№)", 1,
"Дата и время сервера", 2
     SIZE 33 BY 2.25 NO-UNDO.

DEFINE VARIABLE T-cash-pay AS LOGICAL INITIAL no
     LABEL "По типам кассовых платежей"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .83 NO-UNDO.

DEFINE VARIABLE T-cass AS LOGICAL INITIAL no
     LABEL "По кассам"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .83 NO-UNDO.

DEFINE VARIABLE T-child AS LOGICAL INITIAL no
     LABEL "Есть подчиненные типы прайс-листов"
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .83 NO-UNDO.

DEFINE VARIABLE T-currency AS LOGICAL INITIAL no
     LABEL "Валюта"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .83 NO-UNDO.

DEFINE VARIABLE T-date-time-server AS LOGICAL INITIAL no
     LABEL "Дата-время сервера"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .83 NO-UNDO.

DEFINE VARIABLE T-group-buer AS LOGICAL INITIAL no
     LABEL "Группы покупателей"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .83 NO-UNDO.

DEFINE VARIABLE T-group-qnty AS LOGICAL INITIAL no
     LABEL "Количественные группы"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .83 NO-UNDO.

DEFINE VARIABLE T-group-summ AS LOGICAL INITIAL no
     LABEL "Суммовые группы"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .83 NO-UNDO.

DEFINE VARIABLE T-main-price-list AS LOGICAL INITIAL no
     LABEL "Только главные прайс-листы"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .83 NO-UNDO.

DEFINE VARIABLE T-no-base-edizm AS LOGICAL INITIAL no
     LABEL "Не базовая единица"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .83 NO-UNDO.

DEFINE VARIABLE T-pal-nws AS LOGICAL INITIAL no
     LABEL "Цены по новостям ходят только в свои УБД"
     VIEW-AS TOGGLE-BOX
     SIZE 44 BY .83 NO-UNDO.

DEFINE VARIABLE T-pay-type AS LOGICAL INITIAL no
     LABEL "По типам оплат"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .83 NO-UNDO.

DEFINE VARIABLE T-shift-obj AS LOGICAL INITIAL no
     LABEL "Сменная дата-номер объекта"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .83 NO-UNDO.

DEFINE VARIABLE T-summ-oborot AS LOGICAL INITIAL no
     LABEL "Суммарный оборот покупателя"
     VIEW-AS TOGGLE-BOX
     SIZE 30 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-OK AT ROW 1 COL 1
     B-Cancel AT ROW 1 COL 13
     B-Help AT ROW 1 COL 67.5
     T-main-price-list AT ROW 2.25 COL 2
     T-group-buer AT ROW 3 COL 2
     T-summ-oborot AT ROW 3.75 COL 2
     T-group-qnty AT ROW 4.5 COL 2
     T-group-summ AT ROW 5.25 COL 2
     T-no-base-edizm AT ROW 6 COL 2
     R-date AT ROW 6.79 COL 2 NO-LABEL WIDGET-ID 4
     T-date-time-server AT ROW 7.5 COL 40.5
     T-shift-obj AT ROW 8.25 COL 40.5
     T-currency AT ROW 9.08 COL 2
     T-cass AT ROW 9.83 COL 2
     T-pay-type AT ROW 10.58 COL 2
     T-cash-pay AT ROW 11.33 COL 2
     T-child AT ROW 12.08 COL 2 WIDGET-ID 2
     T-pal-nws AT ROW 13 COL 2 WIDGET-ID 8
     SPACE(44.37) SKIP(1.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Глобальные настройки ценообразования"
         DEFAULT-BUTTON B-OK CANCEL-BUTTON B-Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS

&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES

/* SETTINGS FOR TOGGLE-BOX T-date-time-server IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       T-date-time-server:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX T-shift-obj IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       T-shift-obj:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Глобальные настройки ценообразования */
DO:
  run save-proc in this-procedure  no-error .
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Глобальные настройки ценообразования */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-date Dialog-Frame
ON VALUE-CHANGED OF R-date IN FRAME Dialog-Frame
DO:
  assign r-date.
  case r-date :
     when 0 then
      assign
        t-date-time-server  = no
        T-shift-obj = no
        .
     when 1 then
       assign
        t-date-time-server  = no
        T-shift-obj = yes
        .
     when 2 then
       assign
         t-date-time-server  = yes
         T-shift-obj = no
        .
  end case.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-main-price-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-main-price-list Dialog-Frame
ON VALUE-CHANGED OF T-main-price-list IN FRAME Dialog-Frame /* Только главные прайс-листы */
DO:
  ASSIGN t-main-price-list.
  IF t-main-price-list THEN DO:
      ASSIGN
          T-currency          = false
          T-date-time-server  = false
          T-group-buer        = false
          T-group-qnty        = false
          T-group-summ        = false
          /*T-no-base-edizm     = false*/
          T-shift-obj         = false
          T-summ-oborot       = false
          T-pay-type          = false
          T-cash-pay          = false
          T-cass              = false
          T-child             = false
          r-date              = 0
          .

      display
          T-currency T-group-buer T-group-qnty T-group-summ T-no-base-edizm  T-summ-oborot
          T-cass
          T-child
          T-pay-type
          T-cash-pay
          r-date
          WITH FRAME {&FRAME-NAME}.

      DISABLE
          T-currency T-date-time-server T-group-buer T-group-qnty T-group-summ /*T-no-base-edizm*/ T-shift-obj T-summ-oborot
          T-cass
          T-child
          T-pay-type
          T-cash-pay
          r-date
          WITH FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
      ENABLE
          /* T-cass */
          t-child
          T-currency  T-group-buer T-group-qnty T-group-summ T-no-base-edizm  T-summ-oborot
          T-pay-type
          T-cash-pay
          r-date
          with frame {&frame-name} .
  END.

  /* run enable_sp in this-procedure . */
   run enable_sp1 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */


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
  run init-proc in this-procedure .

  if v-db-num = 0 then do:
    apply "VALUE-CHANGED" to T-main-price-list in frame {&frame-name} .
  end.
  else run my-enable in this-procedure  .

  /* TODO что делать с кассами не знаю  */
  T-cass = false .
  disable T-cass with frame {&frame-name} .

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_ui in this-procedure .

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_sp Dialog-Frame
PROCEDURE enable_sp :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DISPLAY T-main-price-list T-group-buer T-summ-oborot T-group-qnty T-group-summ
          T-no-base-edizm R-date T-currency T-cass T-pay-type T-cash-pay T-child
      WITH FRAME Dialog-Frame.
  ENABLE B-OK B-Cancel B-Help
         T-main-price-list
         T-group-buer
         /* T-summ-oborot */
         /* T-group-qnty  */
         /* T-group-summ  */
         T-no-base-edizm
         /* R-date  */
         /* T-currency */
         /* T-cass */
         /* T-pay-type  */
         T-cash-pay
         /* T-child */
         /* t-pal-nws */
      WITH FRAME Dialog-Frame.
  disable
          T-summ-oborot
          T-group-qnty
          T-group-summ
          R-date
          T-currency
          T-cass
          T-pay-type
          T-child
      WITH FRAME Dialog-Frame.


  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}


END PROCEDURE.

PROCEDURE enable_sp1 :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DISPLAY T-main-price-list T-group-buer T-summ-oborot T-group-qnty T-group-summ
          T-no-base-edizm R-date T-currency T-cass T-pay-type T-cash-pay T-child
      WITH FRAME Dialog-Frame.
  ENABLE B-OK B-Cancel B-Help
         T-main-price-list
         T-group-buer
         T-summ-oborot
         T-group-qnty
         T-group-summ
         T-no-base-edizm
          R-date
          T-currency
         /* T-cass */
          T-pay-type
          T-cash-pay
          T-child
          t-pal-nws
      WITH FRAME Dialog-Frame.
  disable
          T-cass
      WITH FRAME Dialog-Frame.


  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}


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
  DISPLAY T-main-price-list T-group-buer T-summ-oborot T-group-qnty T-group-summ
          T-no-base-edizm R-date T-currency T-cass T-pay-type T-cash-pay T-child
          T-pal-nws
      WITH FRAME Dialog-Frame.
  ENABLE B-OK B-Cancel B-Help T-main-price-list T-group-buer T-summ-oborot
         T-group-qnty T-group-summ T-no-base-edizm R-date T-currency T-cass
         T-pay-type T-cash-pay T-child T-pal-nws
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable loc#log as logical   no-undo .
/* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_global-state_lookup':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    loc#log
  }
  if loc#log <> yes then do:
     return error.
  end.

 find first  buf_global-state no-lock no-error .
 if not available buf_global-state then create buf_global-state .
    assign
      T-main-price-list  = logical ( buf_global-state.db-num-chg )
      T-group-buer       = buf_global-state.pl-use-grp-buy
      T-summ-oborot      = buf_global-state.pl-use-oborot-buy
      T-group-qnty       = buf_global-state.pl-use-qnty-group
      T-group-summ       = buf_global-state.pl-use-sum-group
      T-no-base-edizm    = buf_global-state.pl-use-add-code
      T-date-time-server = buf_global-state.pl-use-sys-date-time
      T-shift-obj        = buf_global-state.pl-use-shift-date-num
      T-cass             = buf_global-state.pl-use-cassa
      T-child            = buf_global-state.pl-use-child
      T-currency         = buf_global-state.pl-use-val
      T-pay-type         = buf_global-state.pl-use-pay-type
      T-cash-pay         = buf_global-state.pl-use-cash-pay
    .
    r-date = 0.
    if t-date-time-server = true then r-date = 2.
    if T-shift-obj = true then r-date = 1.

    find first buf_global-state-attr no-lock where
               buf_global-state-attr.gls-id = buf_global-state.gls-id and
               buf_global-state-attr.attr-code = {&attr-pal-nws} no-error .
    if not available buf_global-state-attr then do:
              create buf_global-state-attr.
              assign
                buf_global-state-attr.gls-id  = buf_global-state.gls-id
                buf_global-state-attr.attr-code  = {&attr-pal-nws}
                buf_global-state-attr.attr-value = 'no'
              .
     end.
     assign
      T-pal-nws = logical(buf_global-state-attr.attr-value) no-error
     .
     if error-status :error then T-pal-nws = false .

     /* 111 */



  /* spec start */
  /*
assign
T-currency          = false
T-cass              = false
T-child             = false
T-date-time-server  = false
T-group-buer        = true
T-group-qnty        = false
T-group-summ        = false
T-shift-obj         = false
T-summ-oborot       = false
T-pay-type          = false
T-child             = false
T-cash-pay          = true
T-main-price-list   = false
.
*/


display T-main-price-list
        T-group-buer
        T-summ-oborot
        T-group-qnty
        T-group-summ
        T-no-base-edizm
        T-currency
        T-pay-type
        T-cash-pay
        r-date
        T-pal-nws
        with frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable Dialog-Frame
PROCEDURE my-enable :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DISPLAY T-main-price-list T-group-buer
          T-summ-oborot T-group-qnty T-group-summ
          T-no-base-edizm T-date-time-server
          T-shift-obj T-currency t-cass t-child
          T-pay-type      T-cash-pay
          T-pal-nws
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel b-help
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  B-Cancel:label = "Выход" .

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
define variable loc#log as logical   no-undo .
/* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_global-state_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    loc#log
  }

  if loc#log <> yes then do: return error. end.

  assign  frame {&frame-name}
    T-main-price-list
    T-group-buer
    T-summ-oborot
    T-group-qnty
    T-group-summ
    T-no-base-edizm
    T-date-time-server
    T-shift-obj
    T-currency
    t-cass
    t-child
    T-pay-type
    T-cash-pay
    r-date
    T-pal-nws
   .

     if  T-main-price-list  = true   and
          (T-currency         = true or
          T-date-time-server  = true or
          T-group-buer        = true or
          T-group-qnty        = true or
          T-group-summ        = true or
          T-cass              = true or
          T-child             = true or
          T-shift-obj         = true or
          T-pay-type          = true or
          T-cash-pay          = true or
          T-summ-oborot       = true  )  then do:
            message "Только Главные прайс-листы не могут быть выполнено !!!" view-as alert-box information .
            return error return-value .
     end.



  find current buf_global-state exclusive-lock no-error .
  if available buf_global-state then
  assign
    buf_global-state.pl-use-grp-buy         =  T-group-buer
    buf_global-state.pl-use-oborot-buy      =  T-summ-oborot
    buf_global-state.pl-use-qnty-group      =  T-group-qnty
    buf_global-state.pl-use-sum-group       =  T-group-summ
    buf_global-state.pl-use-add-code        =  T-no-base-edizm
    buf_global-state.pl-use-val             =  T-currency
    buf_global-state.pl-use-cassa           =  T-cass
    buf_global-state.pl-use-child           =  T-child
    buf_global-state.pl-use-cash-pay        =  T-cash-pay
    buf_global-state.pl-use-pay-type        =  T-pay-type
    buf_global-state.db-num-chg             =  integer(T-main-price-list)
  .
  case r-date :
      when 0 then
          assign
        t-date-time-server  = no
        T-shift-obj = no
        .
     when 1 then
          assign
        t-date-time-server  = no
        T-shift-obj = yes
        .
     when 2 then
     assign
        t-date-time-server  = yes
        T-shift-obj = no
        .
  end case.


    buf_global-state.pl-use-sys-date-time   =  T-date-time-server .
    buf_global-state.pl-use-shift-date-num  =  T-shift-obj        .

    find first buf_global-state-attr exclusive-lock where
               buf_global-state-attr.gls-id = buf_global-state.gls-id and
               buf_global-state-attr.attr-code = {&attr-pal-nws} no-error .
    if not available buf_global-state-attr then do:
              create buf_global-state-attr.
              assign
                buf_global-state-attr.gls-id  = buf_global-state.gls-id
                buf_global-state-attr.attr-code  = {&attr-pal-nws}
              .
     end.
      buf_global-state-attr.attr-value = string(T-pal-nws)
      .


    for each  buf_global-state-attr          exclusive-lock where
              buf_global-state-attr.gls-id = buf_global-state.gls-id and
              buf_global-state-attr.attr-code begins {&attr-pal-level-discnt}
              :
              delete buf_global-state-attr.
    end.

    /* Должен сработать тригер и все уйдет в новости */
    if buf_global-state.whole-send-news = 0 then buf_global-state.whole-send-news = 1.
                                            else buf_global-state.whole-send-news = 0.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME