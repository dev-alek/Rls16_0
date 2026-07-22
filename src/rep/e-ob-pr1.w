&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME DLGOKCAN
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DLGOKCAN
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Задание колонок в отчете

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

def var vss-revision    as character no-undo init "$Revision$":u .
def var vss-author      as character no-undo init "$Author$":u .
def var vss-date        as character no-undo init "$Date$":u .
def var vss-workfile    as character no-undo init "$Workfile$":u .
def var vss-archive     as character no-undo init "$Archive$":u .
def var vss-description as character no-undo init "Задание колонок в отчете" .
{ cmp/vssrevis.i }

/* Local Variable Definitions ---                                       */

  { cmp/str-glbl.i }
  { cmp/showinf.i }
{ cmp/r-pril.i }
{ cmp/r-page1.i }
{ gbl/getcntxt.i def }

  DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
  ASSIGN parParentProc =  my-handle .

{ gbl/getcntxt.i get }

def var Log-Res1     as  log            no-undo.
def var Log-Res2     as  log            no-undo.
define variable ii as integer   no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DLGOKCAN

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-quit B-exit b-help RECT-10 RECT-11 ~
RECT-7 RECT-8 RECT-9 InExtQnty InExtCostSum RetPostQnty RetPostCostSum ~
OutExtQnty OutExtCostSum OutExtSaleSum OutExtDiscntSum OutExtDiscntPC ~
RetOutQnty RetOutCostSum RetOutSaleSum RetOutDiscntSum RetOutDiscntPC ~
BenQnty BenCostSum BenSaleSum DiscntSum PC-DiscntSum SpiQnty SpiCostSum ~
SpiSaleSum Effect UpFact Zen-posr
&Scoped-Define DISPLAYED-OBJECTS InExtQnty InExtCostSum RetPostQnty ~
RetPostCostSum OutExtQnty OutExtCostSum OutExtSaleSum OutExtDiscntSum ~
OutExtDiscntPC RetOutQnty RetOutCostSum RetOutSaleSum RetOutDiscntSum ~
RetOutDiscntPC BenQnty BenCostSum BenSaleSum DiscntSum PC-DiscntSum SpiQnty ~
SpiCostSum SpiSaleSum Effect UpFact Zen-posr

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "&Помощь":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-exit
     LABEL "&Сохранить":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 35.5 BY 1.25.

DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 37.38 BY 1.25.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 73.5 BY 2.5
     BGCOLOR 8 FGCOLOR 0 .

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 73.5 BY 3.75.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 73.5 BY 1.54.

DEFINE VARIABLE BenCostSum AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3.5 BY .75 NO-UNDO.

DEFINE VARIABLE BenQnty AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .75 NO-UNDO.

DEFINE VARIABLE BenSaleSum AS LOGICAL INITIAL no
     LABEL "(-скидки)"
     VIEW-AS TOGGLE-BOX
     SIZE 11.25 BY .75 NO-UNDO.

DEFINE VARIABLE DiscntSum AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .75 NO-UNDO.

DEFINE VARIABLE Effect AS LOGICAL INITIAL no
     LABEL "Эффективность":L
     VIEW-AS TOGGLE-BOX
     SIZE 16 BY .75 NO-UNDO.

DEFINE VARIABLE InExtCostSum AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 4.5 BY .75 NO-UNDO.

DEFINE VARIABLE InExtQnty AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .75 NO-UNDO.

DEFINE VARIABLE OutExtCostSum AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 4.5 BY .75 NO-UNDO.

DEFINE VARIABLE OutExtDiscntPC AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3.5 BY .75 NO-UNDO.

DEFINE VARIABLE OutExtDiscntSum AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 3.5 BY .75 NO-UNDO.

DEFINE VARIABLE OutExtQnty AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .75 NO-UNDO.

DEFINE VARIABLE OutExtSaleSum AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 4.5 BY .75 NO-UNDO.

DEFINE VARIABLE PC-DiscntSum AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3.5 BY .75 NO-UNDO.

DEFINE VARIABLE RetOutCostSum AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 5 BY .75 NO-UNDO.

DEFINE VARIABLE RetOutDiscntPC AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3.5 BY .75 NO-UNDO.

DEFINE VARIABLE RetOutDiscntSum AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .75 NO-UNDO.

DEFINE VARIABLE RetOutQnty AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 4.5 BY .75 NO-UNDO.

DEFINE VARIABLE RetOutSaleSum AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 4.5 BY .75 NO-UNDO.

DEFINE VARIABLE RetPostCostSum AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 5 BY .75 NO-UNDO.

DEFINE VARIABLE RetPostQnty AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .75 NO-UNDO.

DEFINE VARIABLE SpiCostSum AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 4.5 BY .75 NO-UNDO.

DEFINE VARIABLE SpiQnty AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 4.5 BY .75 NO-UNDO.

DEFINE VARIABLE SpiSaleSum AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 4.5 BY .75 NO-UNDO.

DEFINE VARIABLE UpFact AS LOGICAL INITIAL no
     LABEL "% факт. наценки":L
     VIEW-AS TOGGLE-BOX
     SIZE 18 BY .75 NO-UNDO.

DEFINE VARIABLE Zen-posr AS LOGICAL INITIAL no
     LABEL "Использ. цен посред. вместо учет.":L
     VIEW-AS TOGGLE-BOX
     SIZE 34.88 BY .75 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DLGOKCAN
     B-quit AT ROW 1 COL 1
     B-exit AT ROW 1 COL 11
     b-help AT ROW 1 COL 61
     InExtQnty AT ROW 4.96 COL 25.5
     InExtCostSum AT ROW 4.96 COL 36
     RetPostQnty AT ROW 6.21 COL 25.5
     RetPostCostSum AT ROW 6.21 COL 36
     OutExtQnty AT ROW 7.46 COL 25.5
     OutExtCostSum AT ROW 7.46 COL 36
     OutExtSaleSum AT ROW 7.46 COL 47.5
     OutExtDiscntSum AT ROW 7.46 COL 59.5
     OutExtDiscntPC AT ROW 7.46 COL 70
     RetOutQnty AT ROW 8.71 COL 25.5
     RetOutCostSum AT ROW 8.71 COL 36
     RetOutSaleSum AT ROW 8.71 COL 47.5
     RetOutDiscntSum AT ROW 8.71 COL 59.5
     RetOutDiscntPC AT ROW 8.71 COL 70
     BenQnty AT ROW 9.96 COL 25.5
     BenCostSum AT ROW 9.96 COL 36
     BenSaleSum AT ROW 9.96 COL 47.5
     DiscntSum AT ROW 9.96 COL 59.5
     PC-DiscntSum AT ROW 9.96 COL 70
     SpiQnty AT ROW 11.33 COL 25.38
     SpiCostSum AT ROW 11.33 COL 35.88
     SpiSaleSum AT ROW 11.33 COL 47.38
     Effect AT ROW 13 COL 2.88
     UpFact AT ROW 13 COL 19.13
     Zen-posr AT ROW 13 COL 40
     "Списание" VIEW-AS TEXT
          SIZE 9.5 BY .75 AT ROW 11.33 COL 3.88
          FGCOLOR 4
     "Кол-во" VIEW-AS TEXT
          SIZE 6.5 BY .75 AT ROW 2.71 COL 23.5
          FGCOLOR 0
     "~"Расход~" - ~"Возврат~"" VIEW-AS TEXT
          SIZE 20.25 BY .75 AT ROW 9.96 COL 4
          BGCOLOR 8 FGCOLOR 4
     "Возврат внешний" VIEW-AS TEXT
          SIZE 15.5 BY .75 AT ROW 8.71 COL 4
          FGCOLOR 4
     "Расход внешний" VIEW-AS TEXT
          SIZE 14.5 BY .75 AT ROW 7.46 COL 4
          FGCOLOR 4
     "Процент" VIEW-AS TEXT
          SIZE 8.5 BY .75 AT ROW 2.71 COL 67.5
     "Возврат поставщику" VIEW-AS TEXT
          SIZE 18 BY .75 AT ROW 6.21 COL 4
          FGCOLOR 4
     "Приход внешний" VIEW-AS TEXT
          SIZE 15 BY .75 AT ROW 4.96 COL 4
          FGCOLOR 4
     "скидок" VIEW-AS TEXT
          SIZE 7.5 BY .75 AT ROW 3.71 COL 57.5
     "скидок" VIEW-AS TEXT
          SIZE 7 BY .75 AT ROW 3.71 COL 68
     "прод. цен" VIEW-AS TEXT
          SIZE 9.75 BY .75 AT ROW 3.71 COL 45
     "учет. цен" VIEW-AS TEXT
          SIZE 9.5 BY .75 AT ROW 3.71 COL 33
     "Сумма" VIEW-AS TEXT
          SIZE 6.5 BY .75 AT ROW 2.71 COL 57.5
          FGCOLOR 0
     "Сумма" VIEW-AS TEXT
          SIZE 6 BY .75 AT ROW 2.71 COL 46
          FGCOLOR 0
     "Сумма" VIEW-AS TEXT
          SIZE 6.5 BY .75 AT ROW 2.71 COL 34
          FGCOLOR 0
     RECT-10 AT ROW 12.75 COL 1.88
     RECT-11 AT ROW 12.75 COL 38
     RECT-7 AT ROW 4.71 COL 2
     RECT-8 AT ROW 7.21 COL 2
     RECT-9 AT ROW 10.96 COL 2
     SPACE(0.99) SKIP(1.70)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE BGCOLOR 8 FGCOLOR 0 "Параметры по типам документов":L
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DLGOKCAN
   FRAME-NAME UNDERLINE                                                 */
ASSIGN
       FRAME DLGOKCAN:SCROLLABLE       = FALSE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME B-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-quit DLGOKCAN
ON CHOOSE OF B-quit IN FRAME DLGOKCAN /* Отмена */
DO:
    return "NO" .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit DLGOKCAN
ON CHOOSE OF B-exit IN FRAME DLGOKCAN /* Сохранить */
DO:
    do ii = 1 to 25 :  Assign  use-column[ii] = no . end.

    if InExtQnty:screen-value = "yes" then       assign  use-column[1] = TRUE    .
    if InExtCostSum:screen-value = "yes" then    assign  use-column[2] = TRUE    .
    if RetPostQnty:screen-value = "yes" then     assign  use-column[3] = TRUE    .
    if RetPostCostSum:screen-value = "yes" then  assign  use-column[4] = TRUE    .
    if OutExtQnty:screen-value = "yes" then      assign  use-column[5] = TRUE    .
    if OutExtCostSum:screen-value = "yes" then   assign  use-column[6] = TRUE    .
    if OutExtSaleSum:screen-value = "yes" then   assign  use-column[7] = TRUE    .
    if OutExtDiscntSum:screen-value = "yes" then assign  use-column[8] = TRUE    .
    if OutExtDiscntPC:screen-value = "yes" then  assign  use-column[9] = TRUE    .
    if RetOutQnty:screen-value = "yes" then      assign  use-column[10] = TRUE   .
    if RetOutCostSum:screen-value = "yes" then   assign  use-column[11] = TRUE   .
    if RetOutSaleSum:screen-value = "yes" then   assign  use-column[12] = TRUE   .
    if RetOutDiscntSum:screen-value = "yes" then assign  use-column[13] = TRUE   .
    if RetOutDiscntPC:screen-value = "yes" then  assign  use-column[14] = TRUE   .
    if BenQnty:screen-value = "yes" then         assign  use-column[15] = TRUE   .
    if BenCostSum:screen-value = "yes" then      assign  use-column[16] = TRUE   .
    if BenSaleSum:screen-value = "yes" then      assign  use-column[17] = TRUE   .
    if DiscntSum:screen-value = "yes" then       assign  use-column[18] = TRUE   .
    if PC-DiscntSum:screen-value = "yes" then    assign  use-column[19] = TRUE   .
    if SpiQnty:screen-value = "yes" then         assign  use-column[20] = TRUE   .
    if SpiCostSum:screen-value = "yes" then      assign  use-column[21] = TRUE   .
    if SpiSaleSum:screen-value = "yes" then      assign  use-column[22] = TRUE   .
    if Effect:screen-value = "yes" then          assign  use-column[23] = TRUE   .
    if UpFact:screen-value = "yes" then          assign  use-column[24] = TRUE   .
    if Zen-posr:screen-value = "yes" then        assign  use-column[25] = TRUE   .

   find first ubflt.usr-flt share-lock  where ubflt.usr-flt.user-name  = v-cntxt-userid and ubflt.usr-flt.call-point = "e-ob-prd":U no-error .
   if NOT avail ubflt.usr-flt then  create ubflt.usr-flt.
   define variable l-ind as integer   no-undo .
   Assign
     ubflt.usr-flt.user-name = v-cntxt-userid
     ubflt.usr-flt.call-point   = "e-ob-prd":U
     ubflt.usr-flt.list_ = ""
   .
   repeat l-ind = 1 to 25 :
     if   use-column[ l-ind ] =  true then ubflt.usr-flt.list_ = ubflt.usr-flt.list_  + string( l-ind ) + "," .
   End.
   apply "go" to frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DLGOKCAN


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/*
if ( CallPoint begins "r-arcbrw" ) OR ( CallPoint begins "objcycle/rub" ) then
    O_BenSaleSum = FALSE .
*/

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    if session:set-wait-state("COMPILER") then.
    assign
        InExtQnty = use-column[1]
        InExtCostSum = use-column[2]
        RetPostQnty = use-column[3]
        RetPostCostSum = use-column[4]
        OutExtQnty = use-column[5]
        OutExtCostSum = use-column[6]
        OutExtSaleSum = use-column[7]
        OutExtDiscntSum = use-column[8]
        OutExtDiscntPC = use-column[9]
        RetOutQnty = use-column[10]
        RetOutCostSum = use-column[11]
        RetOutSaleSum = use-column[12]
        RetOutDiscntSum = use-column[13]
        RetOutDiscntPC= use-column[14]
        BenQnty = use-column[15]
        BenCostSum = use-column[16]
        BenSaleSum = use-column[17]
        DiscntSum = use-column[18]
        PC-DiscntSum = use-column[19]
        SpiQnty = use-column[20]
        SpiCostSum = use-column[21]
        SpiSaleSum = use-column[22]
        Effect = use-column[23]
        UpFact = use-column[24]
        Zen-posr = use-column[25]
    .
    RUN enable_UI.

    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_document-reports-cost_print':U
      {&cntxt-firm}
      v-cntxt-host-code-obj
      '':U
      0
      0
      0
      0
      false
      Log-Res1
    }

    if not Log-Res1 then DISABLE InExtCostSum OutExtCostSum  RetOutCostSum  SpiCostSum  RetPostCostSum  BenCostSum Effect UpFact WITH FRAME {&FRAME-NAME}.

    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_document-reports-sale_print':U
      {&cntxt-firm}
      v-cntxt-host-code-obj
      '':U
      0
      0
      0
      0
      false
      Log-Res2
    }
    if not Log-Res2 then
        DISABLE InExtQnty OutExtQnty OutExtSaleSum OutExtDiscntSum  RetOutQnty RetOutSaleSum RetOutDiscntSum SpiQnty
           SpiSaleSum RetPostQnty DiscntSum  OutExtDiscntPC RetOutDiscntPC PC-DiscntSum BenQnty BenSaleSum WITH FRAME {&FRAME-NAME} .
    if not ( Log-Res1 OR Log-Res2 ) then do:
      message   "У Вас недостаточно прав для" skip
                "выполнения данного действия." skip
                "Обратитесь к администратору" skip
                "системы." view-as alert-box error.
      LEAVE MAIN-BLOCK .
    end.

    find first sysconf where sysconf.avrg-price = yes no-lock no-error .
    if available sysconf then ENABLE  Zen-posr WITH FRAME {&FRAME-NAME} .
    else do:
      assign
        Zen-posr = no
        use-column[25] = no
      .
      DISABLE Zen-posr WITH FRAME {&FRAME-NAME} .
      DISPLAY Zen-posr WITH FRAME {&FRAME-NAME} .
    end.

    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DLGOKCAN  _DEFAULT-DISABLE
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
  HIDE FRAME DLGOKCAN.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DLGOKCAN  _DEFAULT-ENABLE
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
  DISPLAY InExtQnty InExtCostSum RetPostQnty RetPostCostSum OutExtQnty
          OutExtCostSum OutExtSaleSum OutExtDiscntSum OutExtDiscntPC RetOutQnty
          RetOutCostSum RetOutSaleSum RetOutDiscntSum RetOutDiscntPC BenQnty
          BenCostSum BenSaleSum DiscntSum PC-DiscntSum SpiQnty SpiCostSum
          SpiSaleSum Effect UpFact Zen-posr
      WITH FRAME DLGOKCAN.
  ENABLE B-quit B-exit b-help RECT-10 RECT-11 RECT-7 RECT-8 RECT-9
         InExtQnty InExtCostSum RetPostQnty RetPostCostSum OutExtQnty
         OutExtCostSum OutExtSaleSum OutExtDiscntSum OutExtDiscntPC RetOutQnty
         RetOutCostSum RetOutSaleSum RetOutDiscntSum RetOutDiscntPC BenQnty
         BenCostSum BenSaleSum DiscntSum PC-DiscntSum SpiQnty SpiCostSum
         SpiSaleSum Effect UpFact Zen-posr
      WITH FRAME DLGOKCAN.
  {&OPEN-BROWSERS-IN-QUERY-DLGOKCAN}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME