&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v7r11 GUI
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

Задание условий выборки клиентов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

Author: Черных
Created: 28/03/97 -  5:03 pm

*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
{ ref/t-l-b.i }
define input parameter ParParentProc as handle NO-UNDO.
DEFINE input-output parameter IOP-SupGds  AS LOGICAL NO-UNDO.
DEFINE input-output parameter IOP-SupCons AS LOGICAL NO-UNDO.
DEFINE input-output parameter IOP-SupServ AS LOGICAL NO-UNDO.
DEFINE input-output parameter IOP-BuyGds  AS LOGICAL NO-UNDO.
DEFINE input-output parameter IOP-BuyCons AS LOGICAL NO-UNDO.
DEFINE input-output parameter IOP-BuyServ AS LOGICAL NO-UNDO.
DEFINE input-output parameter IOP-WLim-kr AS LOGICAL NO-UNDO.
DEFINE input-output parameter IOP-GRP     AS LOGICAL NO-UNDO.
DEFINE input-output parameter IOP-TURN    AS LOGICAL NO-UNDO.
DEFINE input-output parameter p-sum-1     as character no-undo .
DEFINE input-output parameter p-sum-2     as character no-undo .
DEFINE input-output parameter p-gr-name   as character no-undo .
define input-output parameter p-grp-buyer-id     as integer   no-undo .
define input-output parameter p-grp-buyer-db-num as integer   no-undo .

define input-output parameter table for temp-list-buyer .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Задание условий выборки клиентов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
/* Local Variable Definitions ---                                       */

define variable log-res            as logical no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DLGOKCAN

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OK RECT-9 RECT-21 Btn_Cancel b-help ~
SupGds SupCons SupServ BuyGds BuyCons BuyServ WLim-kr T-oborot T-grp ~
v-sum-1 v-sum-2 v-grp-buyer
&Scoped-Define DISPLAYED-OBJECTS SupGds SupCons SupServ BuyGds BuyCons ~
BuyServ WLim-kr T-oborot T-grp v-sum-1 v-sum-2 v-grp-buyer

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "&Помощь":L
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "&Ввод ":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE v-grp-buyer AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 39 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE v-sum-1 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 17.5 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE v-sum-2 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE RECTANGLE RECT-21
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 70 BY 5.5.

DEFINE RECTANGLE RECT-23
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 70 BY 2.77.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 70 BY 2.7
     BGCOLOR 8 FGCOLOR 0 .

DEFINE VARIABLE BuyCons AS LOGICAL INITIAL yes
     LABEL "Товары - на консигнацию"
     VIEW-AS TOGGLE-BOX
     SIZE 26.5 BY 1 NO-UNDO.

DEFINE VARIABLE BuyGds AS LOGICAL INITIAL yes
     LABEL "Товары - выкуп"
     VIEW-AS TOGGLE-BOX
     SIZE 17.9 BY 1 NO-UNDO.

DEFINE VARIABLE BuyServ AS LOGICAL INITIAL yes
     LABEL "Услуги"
     VIEW-AS TOGGLE-BOX
     SIZE 10 BY 1
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE SupCons AS LOGICAL INITIAL yes
     LABEL "Товары - на консигнацию"
     VIEW-AS TOGGLE-BOX
     SIZE 24.5 BY .8 NO-UNDO.

DEFINE VARIABLE SupGds AS LOGICAL INITIAL yes
     LABEL "Товары - выкуп"
     VIEW-AS TOGGLE-BOX
     SIZE 16.5 BY .8 NO-UNDO.

DEFINE VARIABLE SupServ AS LOGICAL INITIAL yes
     LABEL "Услуги"
     VIEW-AS TOGGLE-BOX
     SIZE 9.6 BY .8 NO-UNDO.

DEFINE VARIABLE T-grp AS LOGICAL INITIAL no
     LABEL "По группе покупателей"
     VIEW-AS TOGGLE-BOX
     SIZE 25 BY .67 NO-UNDO.

DEFINE VARIABLE T-oborot AS LOGICAL INITIAL no
     LABEL "По обороту покупателя"
     VIEW-AS TOGGLE-BOX
     SIZE 25 BY .67 NO-UNDO.

DEFINE VARIABLE WLim-kr AS LOGICAL INITIAL no
     LABEL "Ненулевой лимит кредита"
     VIEW-AS TOGGLE-BOX
     SIZE 26.5 BY 1
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DLGOKCAN
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 61
     SupGds AT ROW 4.7 COL 4.8
     SupCons AT ROW 4.7 COL 22.5
     SupServ AT ROW 4.7 COL 49.3
     BuyGds AT ROW 7.77 COL 5
     BuyCons AT ROW 8.93 COL 5
     BuyServ AT ROW 10.07 COL 5
     WLim-kr AT ROW 10.07 COL 35.8
     T-oborot AT ROW 13 COL 5
     T-grp AT ROW 14.27 COL 5
     v-sum-1 AT ROW 13 COL 28.5 COLON-ALIGNED NO-LABEL
     v-sum-2 AT ROW 13 COL 47 COLON-ALIGNED NO-LABEL
     v-grp-buyer AT ROW 14.27 COL 29 COLON-ALIGNED NO-LABEL
     "Поставщики :" VIEW-AS TEXT
          SIZE 12.8 BY 1 AT ROW 3.77 COL 27.4
          BGCOLOR 8 FGCOLOR 4
     "Условия объединяются по ~"Или~"" VIEW-AS TEXT
          SIZE 32.3 BY 1 AT ROW 2.27 COL 20.4
          FGCOLOR 1
     "Покупатели :" VIEW-AS TEXT
          SIZE 13.5 BY 1 AT ROW 6.27 COL 27.4
          BGCOLOR 8 FGCOLOR 4
     "Условия объединяются по ~"И~"" VIEW-AS TEXT
          SIZE 30 BY .67 AT ROW 11.77 COL 21.9
          FGCOLOR 1
     RECT-9 AT ROW 3.27 COL 1
     RECT-21 AT ROW 6 COL 1
     RECT-23 AT ROW 12.77 COL 1
     SPACE(0.74) SKIP(3.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE BGCOLOR 8 FGCOLOR 1 "Фильтры":L
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DLGOKCAN
   FRAME-NAME UNDERLINE                                                 */
ASSIGN
       FRAME DLGOKCAN:SCROLLABLE       = FALSE
       FRAME DLGOKCAN:PRIVATE-DATA     =
                "DLGCLOSE".

/* SETTINGS FOR RECTANGLE RECT-23 IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
ASSIGN
       SupServ:HIDDEN IN FRAME DLGOKCAN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Btn_Cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Cancel DLGOKCAN
ON CHOOSE OF Btn_Cancel IN FRAME DLGOKCAN /* Отмена */
DO:
    return "NO" .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK DLGOKCAN
ON CHOOSE OF Btn_OK IN FRAME DLGOKCAN /* Ввод  */
DO:
    if IOP-WLim-kr <> ? then
        do:
            assign WLim-kr .
            IOP-WLim-kr = WLim-kr .
        end.

    if IOP-SupGds <> ? then
        do:
            assign SupGds .
            IOP-SupGds = SupGds .
        end.
    if IOP-SupCons <> ? then
        do:
            assign SupCons .
            IOP-SupCons = SupCons .
        end.
    /*
    if IOP-SupServ <> ? then
        do:
            assign SupServ .
            IOP-SupServ = SupServ .
        end.*/
    if IOP-BuyGds <> ? then
        do:
            assign BuyGds .
            IOP-BuyGds = BuyGds .
        end.
    if IOP-BuyCons <> ? then
        do:
            assign BuyCons .
            IOP-BuyCons = BuyCons .
        end.
    if IOP-BuyServ <> ? then
        do:
            assign BuyServ .
            IOP-BuyServ = BuyServ .
        end.
    assign
      frame {&frame-name} t-grp  T-oborot
      IOP-GRP   =  t-grp
      IOP-TURN  =  T-oborot
      p-sum-1   =  v-sum-1
      p-sum-2   =  v-sum-2
      p-gr-name =  v-grp-buyer
    .
    Run remake-tt.
    return "OK" .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BuyCons
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BuyCons DLGOKCAN
ON VALUE-CHANGED OF BuyCons IN FRAME DLGOKCAN /* Товары - на консигнацию */
DO:
    assign BuyCons .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BuyGds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BuyGds DLGOKCAN
ON VALUE-CHANGED OF BuyGds IN FRAME DLGOKCAN /* Товары - выкуп */
DO:
    assign BuyGds .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BuyServ
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BuyServ DLGOKCAN
ON VALUE-CHANGED OF BuyServ IN FRAME DLGOKCAN /* Услуги */
DO:
    assign BuyServ .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SupCons
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SupCons DLGOKCAN
ON VALUE-CHANGED OF SupCons IN FRAME DLGOKCAN /* Товары - на консигнацию */
DO:
    assign SupCons .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SupGds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SupGds DLGOKCAN
ON VALUE-CHANGED OF SupGds IN FRAME DLGOKCAN /* Товары - выкуп */
DO:
    assign SupGds .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SupServ
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SupServ DLGOKCAN
ON VALUE-CHANGED OF SupServ IN FRAME DLGOKCAN /* Услуги */
DO:
    assign SupServ .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-grp DLGOKCAN
ON VALUE-CHANGED OF T-grp IN FRAME DLGOKCAN /* По группе покупателей */
DO:

define variable p-recids as character no-undo .
define buffer buf_buyer-group for ub.buyer-group  .

p-grp-buyer-id     = ? .
p-grp-buyer-db-num = ? .

  ASSIGN t-grp .
  v-grp-buyer = "" .
  if t-grp = true then do:
      run ref/gr-bupr.w ( ParParentProc, "b-sel" , input-output p-recids ) .

      find first buf_buyer-group no-lock where recid (buf_buyer-group) = integer(p-recids) no-error .
      if error-status :error then do:
        t-grp = false .
        DISPLAY v-grp-buyer t-grp with FRAME {&FRAME-NAME}.
        return no-apply.
      end.

      v-grp-buyer        = buf_buyer-group.name .
      p-grp-buyer-id     = buf_buyer-group.bgr-id .
      p-grp-buyer-db-num = buf_buyer-group.bgr-db-num .
  end.
  DISPLAY v-grp-buyer  t-grp  with FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-oborot
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-oborot DLGOKCAN
ON VALUE-CHANGED OF T-oborot IN FRAME DLGOKCAN /* По обороту покупателя */
DO:
define variable vs-sum-1 as decimal   no-undo .
define variable vs-sum-2 as decimal   no-undo .

  ASSIGN t-oborot.
  v-sum-1 = "" .
  v-sum-2 = "" .
  IF t-oborot = false  THEN do:
     for each temp-list-buyer : delete temp-list-buyer. end.
  end.

  IF t-oborot = true  THEN
  run str/two-sum.w (
      input ('sums-calc'),
      input-OUTPUT vs-sum-1 ,
      input-OUTPUT vs-sum-2,
      OUTPUT TABLE temp-list-buyer ).


IF t-oborot THEN do:
   v-sum-1 = "c " + string( vs-sum-1 ) .
if vs-sum-2 <> ? then  v-sum-2 = "по " + string( vs-sum-2 ) .
                  else v-sum-2 = " ..."  .
end.
else do:
  v-sum-1 = "" .
  v-sum-2 = "" .
end.

DISPLAY  v-sum-1
        v-sum-2 with FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME WLim-kr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL WLim-kr DLGOKCAN
ON VALUE-CHANGED OF WLim-kr IN FRAME DLGOKCAN /* Ненулевой лимит кредита */
DO:
    assign    WLim-kr .
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
    assign
        SupGds = IOP-SupGds
        SupCons = ( if IOP-SupCons <> ? then IOP-SupCons else FALSE )
        SupServ = ( if IOP-SupServ <> ? then IOP-SupServ else FALSE )
        BuyGds = IOP-BuyGds
        BuyCons = ( if IOP-BuyCons <> ? then IOP-BuyCons else FALSE )
        BuyServ = ( if IOP-BuyServ <> ? then IOP-BuyServ else FALSE )
        WLim-kr = ( if IOP-WLim-kr <> ? then IOP-WLim-kr else FALSE )
        T-grp   = ( if IOP-GRP <> ? then IOP-GRP else FALSE )
        T-oborot   = ( if  IOP-TURN  <> ? then  IOP-TURN  else FALSE )
        .

if T-oborot = true then do:
                  assign
                    v-sum-1 =  p-sum-1
                    v-sum-2 =  p-sum-2
                  .
    display v-sum-1  v-sum-2  with frame {&frame-name} .
end.

if T-grp = true then do:
                  assign
                    v-grp-buyer =  p-gr-name
                  .
    display v-grp-buyer  with frame {&frame-name} .
end.


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
  DISPLAY SupGds SupCons BuyGds BuyCons BuyServ WLim-kr T-oborot T-grp
          v-sum-1 v-sum-2 v-grp-buyer
      WITH FRAME DLGOKCAN.
  ENABLE Btn_OK RECT-9 RECT-21 Btn_Cancel b-help SupGds SupCons BuyGds
         BuyCons BuyServ WLim-kr T-oborot T-grp v-sum-1 v-sum-2 v-grp-buyer
      WITH FRAME DLGOKCAN.
  {&OPEN-BROWSERS-IN-QUERY-DLGOKCAN}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE remake-tt DLGOKCAN
PROCEDURE remake-tt :
define buffer buf_buyer-in-buyer-group for ub.buyer-in-buyer-group  .


if iop-turn = true and iop-grp = true then do:
    for each temp-list-buyer :
        find first buf_buyer-in-buyer-group no-lock where
                  buf_buyer-in-buyer-group.stts       = 0      and
                  buf_buyer-in-buyer-group.bbg-obj-type = temp-list-buyer.obj-type and
                  buf_buyer-in-buyer-group.bbg-obj-code = temp-list-buyer.obj-code and
                  buf_buyer-in-buyer-group.bgr-id       = p-grp-buyer-id      and
                  buf_buyer-in-buyer-group.bgr-db-num   = p-grp-buyer-db-num
                  no-error .
        if not available buf_buyer-in-buyer-group then delete temp-list-buyer .
    end.
end.

if iop-turn = false and iop-grp = true then do:
    for each temp-list-buyer : delete temp-list-buyer. end.
    for each  buf_buyer-in-buyer-group no-lock where
              buf_buyer-in-buyer-group.stts       = 0      and
              buf_buyer-in-buyer-group.bgr-id     = p-grp-buyer-id      and
              buf_buyer-in-buyer-group.bgr-db-num = p-grp-buyer-db-num  :
        create temp-list-buyer .
          assign
            temp-list-buyer.obj-type = buf_buyer-in-buyer-group.bbg-obj-type
            temp-list-buyer.obj-code = buf_buyer-in-buyer-group.bbg-obj-code
          .
    end.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
