&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS F-Frame-Win 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет по покупкам постоянных клиентов (с дисконтными картами)

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Отчет по покупкам постоянных клиентов (с дисконтными картами)" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ cmp/operlist.i }
{ cmp/breakstr.i }
{ cmp/getdpcnt.i }
{ gbl/waitfram.i }
{ cmp/dc-list.i dc-list def "new shared" }
{ ref/grplibfn.i }
{ rep/e-xldcd-old.i "NEW SHARED" }
define variable parparentproc as widget-handle no-undo .
{ gbl/getcntxt.i def }
{ rep/lhstprex.i dc-list-hist  "'дисконтных карт'" }
{ rep/lhstprex.i gds-list-hist "'товаров'" }

define variable State-source as Widget-handle no-undo.
define variable NotInc          as  log     no-undo.

define variable StrBuf              as char         no-undo.
define variable rec-list as char no-undo .
define variable Line            as char         no-undo.
define variable FixDCard            as char         no-undo.
define variable FixProdAttr         as char         no-undo.

define variable sym1            as char   init ":"      no-undo.
define variable sym2            as char   init ":"      no-undo.

define variable ii                      as  integer     no-undo.
define variable only-one-card-per-cli as integer no-undo.
define variable only-one-card-per-leg as integer no-undo.
define variable i as integer no-undo.
define variable namebuf1     as      char    no-undo.
define variable namebuf2     as      char    no-undo.
/*название + признак*/
define variable for-name as char no-undo.
define variable DcardMode as char no-undo init "ALL".
define variable FIlter-name as char no-undo.
define variable where-phrase as char no-undo.
define variable SelectProducer as char no-undo.
define variable v-curr-r-b as character no-undo .
define variable v-dcoveris as character no-undo .

define buffer cli-obj for clients .
define buffer cli-dcard for clients .
define buffer cli-prod  for clients .

define variable for-netto as decimal no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER FRAME

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-2 RECT-3 RECT-client selectcard ~
TotalOnly T-zeros T-legacy T-subsid T-imp T-time up-levelt
&Scoped-Define DISPLAYED-OBJECTS selectcard UpLevel TotalOnly T-zeros ~
T-legacy T-subsid T-imp T-time up-levelt

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of handles for SmartObjects                              */
DEFINE VARIABLE h_s-time AS HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE VARIABLE up-levelt AS CHARACTER FORMAT "X(256)":U INITIAL "с превышением суммы"
      VIEW-AS TEXT
     SIZE 29.6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE UpLevel AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14.6 BY 1 NO-UNDO.

DEFINE VARIABLE selectcard AS CHARACTER INITIAL "ALL"
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", "All":U,
"Выборочно по картам", "Selective":U
     SIZE 29 BY 2.7 NO-UNDO.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 32.4 BY 6.5.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 32.4 BY 2.4.

DEFINE RECTANGLE RECT-client
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 32.4 BY 6.93.

DEFINE VARIABLE T-imp AS LOGICAL INITIAL no
     LABEL "С учетом мпорта из ВС"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .87 NO-UNDO.

DEFINE VARIABLE T-legacy AS LOGICAL INITIAL no
     LABEL "С учетом перевыпуска карт"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .87 NO-UNDO.

DEFINE VARIABLE T-subsid AS LOGICAL INITIAL no
     LABEL "С учетом дополн.  карт"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .87 NO-UNDO.

DEFINE VARIABLE T-time AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.6 BY .93 NO-UNDO.

DEFINE VARIABLE T-zeros AS LOGICAL INITIAL no
     LABEL "Нулевые обороты"
     VIEW-AS TOGGLE-BOX
     SIZE 18.5 BY .87 NO-UNDO.

DEFINE VARIABLE TotalOnly AS LOGICAL INITIAL no
     LABEL "Только итоги"
     VIEW-AS TOGGLE-BOX
     SIZE 16.8 BY .87 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     selectcard AT ROW 2.3 COL 3 NO-LABEL
     UpLevel AT ROW 6.7 COL 3 NO-LABEL
     TotalOnly AT ROW 9.53 COL 2
     T-zeros AT ROW 10.5 COL 2
     T-legacy AT ROW 11.5 COL 2
     T-subsid AT ROW 12.5 COL 2
     T-imp AT ROW 13.5 COL 2
     T-time AT ROW 16 COL 3.3
     up-levelt AT ROW 5.33 COL 2.6 NO-LABEL
     "Покупатели:" VIEW-AS TEXT
          SIZE 28 BY .97 AT ROW 1.33 COL 3
          FGCOLOR 4
     "Представление:" VIEW-AS TEXT
          SIZE 26.9 BY .83 AT ROW 8.5 COL 2.9
          FGCOLOR 4
     "Выборочно по времени" VIEW-AS TEXT
          SIZE 22 BY .93 AT ROW 15 COL 2.9
          FGCOLOR 4
     RECT-2 AT ROW 8.15 COL 1.5
     RECT-3 AT ROW 14.8 COL 1.5
     RECT-client AT ROW 1.13 COL 1.5
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 58.13 BY 16.3.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,Browse,DB-Fields,Smart,Query
   Container Links:
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW F-Frame-Win ASSIGN
         HEIGHT             = 16.4
         WIDTH              = 58.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB F-Frame-Win
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW F-Frame-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE                                                          */
/* SETTINGS FOR FILL-IN up-levelt IN FRAME F-Main
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN UpLevel IN FRAME F-Main
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = ""
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME selectcard
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL selectcard F-Frame-Win
ON VALUE-CHANGED OF selectcard IN FRAME F-Main
DO:
  assign selectcard.
  CASE selectcard:
    when "selective":U then do:
      run str/dc-list.w (my-handle, v-cntxt-host-code-obj, v-cntxt-obj-type, v-cntxt-obj-code).
      assign
      FixDCard = ""
      DcardMode = "LIST":U
      .
      find first dc-list no-lock no-error .
      if not available dc-list then do:
        message
        "В списке карт нет ни одной карты"
        view-as alert-box WARNING.
        assign
        selectcard = "all":U
        DcardMode  = "ALL":U
        .
    end. /* if not avail:*/
  end.  /*selective*/
  when "all":U then do:
      assign
      FixDCard = ""
      DcardMode = "ALL":U
      .
  end.
 END CASE.
 display selectcard with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-imp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-imp F-Frame-Win
ON VALUE-CHANGED OF T-imp IN FRAME F-Main /* С учетом мпорта из ВС */
DO:
  assign T-imp.
  display
    T-imp
    with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-legacy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-legacy F-Frame-Win
ON VALUE-CHANGED OF T-legacy IN FRAME F-Main /* С учетом перевыпуска карт */
DO:
  if v-dcoveris = "yes" then
   assign T-legacy .
   else do:
    assign t-legacy = no.
    display
    t-legacy
    with frame {&frame-name} .

   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-subsid
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-subsid F-Frame-Win
ON VALUE-CHANGED OF T-subsid IN FRAME F-Main /* С учетом дополн.  карт */
DO:
  if v-dcoveris = "yes" then
   assign T-subsid .
   else do:
    assign t-subsid = no.
    display
    t-subsid
    with frame {&frame-name} .

   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-zeros
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-zeros F-Frame-Win
ON VALUE-CHANGED OF T-zeros IN FRAME F-Main /* Нулевые обороты */
DO:
    assign TotalOnly .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME TotalOnly
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL TotalOnly F-Frame-Win
ON VALUE-CHANGED OF TotalOnly IN FRAME F-Main /* Только итоги */
DO:
    assign TotalOnly .
    if TotalOnly then do:
        ENABLE UpLevel with frame {&frame-name} .
        apply "entry" to UpLevel in frame {&frame-name} .
    end.
    else do:
        UpLevel = 0 .
        DISPLAY UpLevel with frame {&frame-name} .
        DISABLE UpLevel with frame {&frame-name} .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
   /* Now enable the interface  if in test mode - otherwise this happens when
      the object is explicitly initialized from its container. */
   RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects F-Frame-Win  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/
  DEFINE VARIABLE adm-current-page  AS INTEGER NO-UNDO.

  RUN get-attribute IN THIS-PROCEDURE ('Current-Page':U).
  ASSIGN adm-current-page = INTEGER(RETURN-VALUE).

  CASE adm-current-page:

    WHEN 0 THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'rep/s-time.w':U ,
             INPUT  FRAME F-Main:HANDLE ,
             INPUT  '':U ,
             OUTPUT h_s-time ).
       /* Position in AB:  ( 1.80 , 36.50 ) */
       /* Size in UIB:  ( 12.00 , 22.00 ) */

       /* Adjust the tab order of the smart objects. */
    END. /* Page 0 */

  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available F-Frame-Win  _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI F-Frame-Win  _DEFAULT-DISABLE
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
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI F-Frame-Win  _DEFAULT-ENABLE
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
  DISPLAY selectcard UpLevel TotalOnly T-zeros T-legacy T-subsid T-imp T-time
          up-levelt
      WITH FRAME F-Main.
  ENABLE RECT-2 RECT-3 RECT-client selectcard TotalOnly T-zeros T-legacy
         T-subsid T-imp T-time up-levelt
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize F-Frame-Win
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
  RUN set-position IN h_s-time ( 1.96 , 34.88 ) NO-ERROR.
  { gbl/curr-r-b.i
    v-curr-r-b
  }
  Up-Levelt  = Up-Levelt +
  ( if v-curr-r-b = {&r-b-base} then " (вал.)" else " ({&abbr_rub}.)" ) .
  DIsplay Up-levelt
  WITH frame {&frame-name}.
  define variable v-conf-type as character no-undo .
  { gbl/conf-rd.i
  "'dcoveris'"
  0
  "''":U
  0
  "''":U
  "''":U
  "''":U
  NO
  v-dcoveris
  v-conf-type
  NO-ERROR
  }
  IF ERROR-STATUS:ERROR OR
    v-conf-type <> {&type-log} THEN
    v-dcoveris = "no".
   if v-dcoveris <> "yes" then disable
   t-legacy
   t-subsid
   with
   frame {&frame-name} .
  /* Code placed here will execute AFTER standard behavior.    */
  parparentproc = my-handle.
  { gbl/getcntxt.i get }

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-report F-Frame-Win
PROCEDURE My-report :
define variable num-g# as integer no-undo.
DEFINE VARIABLE for-d-pcnt as character no-undo .
DEFINE VARIABLE loc-d-pcnt like ub.dis-card.d-pcnt no-undo .
define variable v-header-base-curr as character no-undo .
define variable accum-counter as integer no-undo .
define variable accum-qnty     as decimal no-undo .
define variable accum-sum      as decimal no-undo .
define variable accum-discount as decimal no-undo .
define variable accum-netto    as decimal no-undo .
define variable accum-counter-cli  as integer no-undo .
define variable accum-qnty-cli     as decimal no-undo .
define variable accum-sum-cli      as decimal no-undo .
define variable accum-discount-cli as decimal no-undo .
define variable accum-netto-cli    as decimal no-undo .
define variable accum-counter-leg  as integer no-undo .
define variable accum-qnty-leg     as decimal no-undo .
define variable accum-sum-leg      as decimal no-undo .
define variable accum-discount-leg as decimal no-undo .
define variable accum-netto-leg    as decimal no-undo .
define variable accum-counter-crd  as integer no-undo .
define variable accum-qnty-crd     as decimal no-undo .
define variable accum-sum-crd      as decimal no-undo .
define variable accum-discount-crd as decimal no-undo .
define variable accum-netto-crd    as decimal no-undo .
define variable v-d-card           like ub.dis-card.d-card no-undo .
define variable v-ii as integer no-undo .
define variable stream-pos as integer no-undo .
define variable v-root-card like ub.dis-card.d-card no-undo .
define variable v-cli-code like ub.dis-card.cli-code no-undo .
define variable v-cli-type like ub.dis-card.cli-type no-undo .
define variable v-cli-type-code as character no-undo .
define variable v-cli-name  like ub.clients.obj-name no-undo .
define variable v-show-d-card like ub.dis-card.d-card no-undo .
define variable ii as integer no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define buffer buf_dis-card for ub.dis-card.
define buffer buf_currency for ub.currency.
{ gbl/basecode.i v-cntxt-host-code-obj v-base-code }
find first buf_currency where
      buf_currency.curr-code = v-base-code.


assign
v-header-base-curr = string( "( Все цены указаны в " +
                            (if v-curr-r-b = {&r-b-base}
                            then caps( trim( buf_currency.curr-abbr ) )
                            else  "{&abbr_rub_allshift}") + " )" )
.



DEFINE FRAME X123
sym1 column-label ":!:" format "X(1)"
dcards.date_ column-label "Дата!покупки" format "99/99/9999"
dcards.artic column-label "Артикул! " format "X(16)"
dcards.b-code column-label "Баркод!" format ">>>>>>>>>>>>9"
goods.gds-name format "X(25)"
cli-prod.obj-name column-label "Производитель!(поставщик)" format "X(38)"
dcards.sale-price column-label "Цена!отпускная" format ">,>>>,>>9.99"
dcards.qnty column-label "Количество  ! " format "->>>>>>9.<<<"
dcards.sum column-label "Получено! " format "->>,>>>,>>>,>>9.99"
dcards.discount column-label "Скидка! " format "->>,>>>,>>9.99"
for-netto column-label "Сумма!нетто" format "->>>,>>>,>>9.99"
sym2 column-label ":!:" format "X(1)"
HEADER
cur-time-print() AT 5 format "x(35)"
v-header-base-curr  format "X(40)" AT 50
"Страница " AT 100 PAGE-NUMBER( PrnLibStream ) AT 110 FORMAT ">>>>9" SKIP
Line format "X(184)" AT 1
with width {&DOS_CW_2} down stream-io use-text .


assign
frame {&frame-name} selectcard
frame {&frame-name} TotalOnly
frame {&frame-name} UpLevel
frame {&frame-name} T-time
frame {&frame-name} T-Zeros
.
CASE X-selectgood:
  when {&g-prod} then do:
    For each g#cli no-lock:
        num-g# = num-g# + 1.
        if num-g#= 1 then
        FixProdAttr = g#cli.obj-type + string( g#cli.obj-code ) .
        if num-g# > 1 then leave.
    end.
  end.
  when {&g-grp} then do:
    For each tmp#grp no-lock:
        num-g# = num-g# + 1.
        if num-g# = 1 then
        FixProdAttr = string( tmp#grp.node-code ) .
        if num-g# > 1 then leave.
    end.
  end.
  when {&g-choice} or when {&g-one} then do:
    For each gds-list no-lock:
        num-g# = num-g# + 1.
        if num-g# = 1 then
        FixProdAttr = string( gds-list.gds-code ) .
        if num-g# > 1 then leave.
    end.
  end.
END CASE.
run My-var.
if num-g# = 1 then.
else
FIXprodAttr = "".
run waitfram-show in this-procedure ( "Подождите ..." ) .
CASE DcardMode:
    when "ALL":U then do:
        run rep/e-xldcd.p (
                            input "ALL":U
                           ,input ""
                           ,input X-SelectGood
                           ,input FixProdAttr
                           ,input TotalOnly
                           ,input X-date-Start
                           ,input X-date-End
                           ,input T-time
                           ,input T-zeros
                           ,input T-legacy
                           ,input t-subsid
                           ,input ( if X-SelectGood = {&g-all} then "TRUE" else (IF num-g# > 1 then "LIST" else "ONE"))
                           ,input T-imp
                           )
                .
    end.
    when "ONE":U then do:
        run rep/e-xldcd.p (
                            input "ONE":U
                           ,input Fixdcard
                           ,input X-SelectGood
                           ,input FixProdAttr
                           ,input TotalOnly
                           ,input X-date-Start
                           ,input X-date-End
                           ,input T-time
                           ,input T-zeros
                           ,input T-legacy
                           ,input t-subsid
                           ,input ( if X-SelectGood = {&g-all} then "TRUE" else (IF num-g# > 1 then "LIST" else "ONE"))
                           ,input T-imp
                           )
                .
    end.
    when "LIST":U then do:
        run rep/e-xldcd.p (
                            input "LIST":U
                           ,input ""
                           ,input X-SelectGood
                           ,input FixProdAttr
                           ,input TotalOnly
                           ,input X-date-Start
                           ,input X-date-End
                           ,input T-time
                           ,input T-zeros
                           ,input T-legacy
                           ,input t-subsid
                           ,input ( if X-SelectGood = {&g-all} then "TRUE" else (IF num-g# > 1 then "LIST" else "ONE"))
                           ,input T-imp
                           )
                .
    end.
end.

run waitfram-hide in this-procedure .
if can-find( first dcards ) then do:
  run prn-lib-open-stream  in this-procedure (
                                              input my-handle
                                              ,input {&LS_PS_A4}
                                              ,input yes /*p-is-stream*/
                                              ,input no /*p-append*/
                                              ).
  Line = fill( "-", 200 ) .
  FORM HEADER
  Line format "X(184)" AT 1 SKIP
  "Продолжение - на следующей странице" AT 30 SKIP
  with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream PrnLibStream FRAME BottomFrame .

  PUT stream PrnLibStream
  space(40)
  "Отчет по продажам постоянным клиентам" skip
  space(40) str1 format "X(60)" skip
  space(20) ( if NotInc then "( сформирован НЕ ПО ВСЕМ ЧЕКАМ )" else " " ) format "x(40)" skip
  space(20) "По объектам :  " .

  FOR EACH obj-list :
      FIND FIRST cli-obj WHERE cli-obj.obj-type = obj-list.obj-type AND
                                cli-obj.obj-code = obj-list.obj-code NO-LOCK .
      FIND FIRST db WHERE db.db-num = cli-obj.db-num NO-LOCK .
      PUT stream PrnLibStream
      string( trim( string( db.db-name, "x(30)" ) ) + " / " + cli-obj.obj-name )
      format "x(100)"     skip space(35) .
  END. /*FOR EACH obj-list :*/
  PUT stream PrnLibStream "" skip .
  CASE DcardMode:
    when "ALL":U then do:
      PUT stream PrnLibStream space(20) "По ВСЕМ картам." format "x(40)" skip.
    end.
    when "ONE":U then do:
      FIND FIRST cli-dcard WHERE cli-dcard.obj-type = dis-card.cli-type AND
                                cli-dcard.obj-code = dis-card.cli-code NO-LOCK .
      PUT stream PrnLibStream
      space(20) substitute("По карте &1 держатель - &2", dis-card.d-card, cli-dcard.obj-name ) format "x(80)" skip.
    end.
    when "LIST":U then do:
      PUT stream PrnLibStream space(10) string("По сформированному списку карт") format "x(50)" skip.
      ii = 0.
      for each dc-list no-lock:
        ii = ii + 1.
      end.
      PUT stream PrnLibStream unformatted substitute("В списке &1 карт", ii) skip.
    end.
  END CASE.
  if X-SelectGood = {&g-all} then do:
    PUT stream PrnLibStream
    space(20) "По ВСЕМ производителям ( поставщикам )." format "x(40)" skip(1) .
  end.
  else do:
    CASE X-selectgood:
      when {&g-prod} then do:
        PUT stream PrnLibStream
        space(20)  "По производителям: " format "x(80)" skip(0) .
        for each g#cli:
            PUT stream PrnLibStream
            space(20) g#cli.obj-name format "x(80)" skip(0) .
        end.
      end.
      when {&g-grp} then do:
        PUT stream PrnLibStream
        space(20)  "По группам товаров: " format "x(80)" skip(0) .
        for each tmp#grp:
            PUT stream PrnLibStream
            space(20) tmp#grp.grp-name format "x(80)" skip(0) .
        end.
      end.
      when {&g-choice} then do:
        PUT stream PrnLibStream space(10)  "По сформированному списку товаров " format "x(50)" .
        ii = 0.
        for each gds-list:
          ii = ii + 1.
        end.
        PUT stream PrnLibStream unformatted substitute("В списке &1 товаров", ii) skip.
      end.
      when {&g-one} then do:
        find first gds-list.
        PUT stream PrnLibStream
        space(20)  "По товару: " format "x(10)"
        gds-list.artic {&space-char} gds-list.prod-type gds-list.prod-code {&space-char} gds-list.gds-name
        skip(0) .
      end.
    END CASE.
    PUT stream PrnLibStream SKIP(0).
  end. /* else от if X-SelectGood = {&g-all} then do:*/
  IF T-time then do:
    PUT stream PrnLibStream UNFORMATTED
    "Выборочно по времени: ".
    FOR EACH times No-LOCK :
      PUT stream PrnLibStream UNFORMATTED
      times
      {&space-char}
      .
    END.
    PUT stream PrnLibStream UNFORMATTED
    SKIP (1).
  end.
  if t-legacy
  or t-subsid
  then do:
      PUT stream PrnLibStream UNFORMATTED
    (if t-legacy
      then "С учетом перевыпуска карт (приведены номера карт ПОСЛЕДНЕГО ВЫПУСКА)"
      else '':U)
    (if t-subsid
      then "С учетом дополнительных карт (приведены номера ОСНОВНЫХ карт)"
      else '':U)
    SKIP (1).
  end.
  FOR EACH dcards where (UpLevel = 0 or dcards.sum >= UpLevel) ,
      FIRST  dis-card NO-LOCK WHERE dis-card.d-card = dcards.d-card
  BREAK
  BY dcards.cli-type-code
  BY dcards.card-num-chr
  BY dcards.d-card
  BY dcards.date_ :
    if (not t-legacy and not t-subsid)
    or first-of (dcards.cli-type-code) then do:
      find first cli-dcard no-lock where
                cli-dcard.obj-type = dis-card.cli-type
            and cli-dcard.obj-code = dis-card.cli-code no-error .
      if available cli-dcard then do:
        assign
        v-cli-name = cli-dcard.obj-name
        v-cli-type-code = dis-card.cli-type + string(dis-card.cli-code)
        .
      end.
      else do:
        assign
        v-cli-name = dis-card.cli-type + string(dis-card.cli-code)
        v-cli-type-code = dis-card.cli-type + string(dis-card.cli-code)
        .
      end.
    end.
    if first-of (dcards.cli-type-code) then do:
      assign
      accum-counter-cli  = 0
      accum-qnty-cli     = 0
      accum-sum-cli      = 0
      accum-discount-cli = 0
      accum-netto-cli    = 0
      only-one-card-per-cli = 0
      .
    end.
    if first-of( dcards.card-num-chr) then do:
      assign
      accum-counter-leg  = 0
      accum-qnty-leg     = 0
      accum-sum-leg      = 0
      accum-discount-leg = 0
      accum-netto-leg    = 0
      only-one-card-per-leg = 0
      .
    end.
    if first-of( dcards.d-card) then do:
      assign
      accum-counter-crd  = 0
      accum-qnty-crd     = 0
      accum-sum-crd      = 0
      accum-discount-crd = 0
      accum-netto-crd    = 0
      .
    end.
    assign
    accum-counter         = accum-counter      + dcards.counter
    accum-qnty            = accum-qnty         + dcards.qnty
    accum-sum             = accum-sum          + dcards.sum
    accum-discount        = accum-discount     + dcards.discount
    accum-netto           = accum-netto        + dcards.sum - dcards.discount
    accum-counter-cli     = accum-counter-cli  + dcards.counter
    accum-qnty-cli        = accum-qnty-cli     + dcards.qnty
    accum-sum-cli         = accum-sum-cli      + dcards.sum
    accum-discount-cli    = accum-discount-cli + dcards.discount
    accum-netto-cli       = accum-netto-cli    + dcards.sum - dcards.discount
    accum-counter-leg     = accum-counter-leg  + dcards.counter
    accum-qnty-leg        = accum-qnty-leg     + dcards.qnty
    accum-sum-leg         = accum-sum-leg      + dcards.sum
    accum-discount-leg    = accum-discount-leg + dcards.discount
    accum-netto-leg       = accum-netto-leg    + dcards.sum - dcards.discount
    accum-counter-crd     = accum-counter-crd  + dcards.counter
    accum-qnty-crd        = accum-qnty-crd     + dcards.qnty
    accum-sum-crd         = accum-sum-crd      + dcards.sum
    accum-discount-crd    = accum-discount-crd + dcards.discount
    accum-netto-crd       = accum-netto-crd    + dcards.sum - dcards.discount
    .
    /*начало legacy 1-я строчка*/
    if t-legacy
    or t-subsid
    then do:
      if only-one-card-per-leg = 0 then only-one-card-per-leg = 1.
      else only-one-card-per-leg = 2.
      if first-of( dcards.card-num-chr ) then do:
        assign
        v-show-d-card = dcards.card-num-chr.
        /* **************************************************************************
        message "first" dcards.card-num-chr dcards.d-card view-as alert-box .
        /*нам только надо напечатать какие карыт входят в цепочку - начиная с 1-oй*/
        if first( dcards.card-num-chr )
        then
        DOWN stream PrnLibStream 1 with frame X123 .
        assign
        v-ii = 1.
        if t-legacy and not t-subsid
        then do:
          for each buf_dis-card no-lock where
                  buf_dis-card.first-card = dcards.first-card
          by buf_dis-card.overissue-num descending:
            if v-ii = 1 then do:
              put stream PrnLibStream unformatted "~{":U buf_dis-card.d-card  " <----" {&space-char} .
              assign
              stream-pos = 1 + length(buf_dis-card.d-card) + 7
              v-root-card = buf_dis-card.FIRST-card
              .
            end.
            else do:
              put stream PrnLibStream unformatted buf_dis-card.d-card {&space-char} .
              assign
              stream-pos = length(buf_dis-card.d-card) + 1.
            end.
            assign
            v-ii = v-ii + 1.
            if stream-pos > {&DOS_CW_2} - 20 then do:
              put stream PrnLibStream unformatted  skip .
            end.
          end. /*for each buf_legacy*/
          put stream PrnLibStream unformatted  "~}" skip .
        end. /*if t-legacy and not t-subsid*/
        if not t-legacy and t-subsid
        then do:
          for each buf_dis-card no-lock where
                  buf_dis-card.main-card = dcards.main-card
          by buf_dis-card.overissue-num descending:
            if v-ii = 1 then do:
              put stream PrnLibStream unformatted "~{":U buf_dis-card.d-card  " <----" {&space-char} .
              assign
              stream-pos = 1 + length(buf_dis-card.d-card) + 7
              v-root-card = buf_dis-card.main-card
              .
            end.
            else do:
              put stream PrnLibStream unformatted buf_dis-card.d-card {&space-char} .
              assign
              stream-pos = length(buf_dis-card.d-card) + 1.
            end.
            assign
            v-ii = v-ii + 1.
            if stream-pos > {&DOS_CW_2} - 20 then do:
              put stream PrnLibStream unformatted  skip .
            end.
          end. /*for each buf_legacy*/
          put stream PrnLibStream unformatted  "~}" skip .
        end. /*if not t-legacy and t-subsid*/
        if t-legacy and t-subsid
        then do:

          for each buf_dis-card no-lock where
                  buf_dis-card.first-main-card = dcards.first-main-card
          by buf_dis-card.overissue-num descending:

            if v-ii = 1 then do:
              put stream PrnLibStream unformatted "~{":U buf_dis-card.d-card  " <----" {&space-char} .
              assign
              stream-pos = 1 + length(buf_dis-card.d-card) + 7
              v-root-card = buf_dis-card.first-main-card
              .
            end.
            else do:
              put stream PrnLibStream unformatted buf_dis-card.d-card {&space-char} .
              assign
              stream-pos = length(buf_dis-card.d-card) + 1.
            end.
            assign
            v-ii = v-ii + 1.
            if stream-pos > {&DOS_CW_2} - 20 then do:
              put stream PrnLibStream unformatted  skip .
            end.
          end. /*for each buf_legacy*/
          put stream PrnLibStream unformatted  "~}" skip .
        end. /*if t-legacy and t-subsid*/
        ********************************************************************** */
      end.  /*if first-of( dcards.card-num-chr ) then do:*/
    end. /*if t-legacy or t-subsid*/
    /*конец legacy 1-я строчка*/
    if first-of( dcards.d-card ) then do:
      if first( dcards.d-card ) then do:
        DOWN
        stream PrnLibStream 1
        with frame X123 .
      end.
      only-one-card-per-cli = only-one-card-per-cli + 1.
      FOR-D-PCNT = GET-D-PCNT(buffer dis-card
                              ,input v-cntxt-host-code-obj
                              ,input v-cntxt-obj-type
                              ,input v-cntxt-obj-code
                              ,input {&ddctr-def-pcnt}
                              ,output loc-d-pcnt).
      PUT stream PrnLibStream space(10)
      substitute ("№ карты : &1 &2 / &3 (&4) / Процент скидки : &5"
                  , (if t-legacy or t-subsid then ("~{" + v-show-d-card + "~}") else "":U)
                  ,  trim( dcards.d-card )
                  ,  trim(v-cli-name)
                  ,  (if t-legacy or t-subsid then dcards.cli-type-code else v-cli-type-code)
                  ,  for-d-pcnt )
      format "x(100)" SKIP.
      UNDERLINE stream PrnLibStream
      dcards.date_
      dcards.artic
      cli-prod.obj-name
      goods.gds-name
      dcards.b-code
      dcards.sale-price
      dcards.qnty
      dcards.sum
      dcards.discount
      for-netto
      with frame X123 .
      if NOT TotalOnly then do:
        if dcards.b-code <> 0 then do:
          FIND FIRST cli-prod WHERE cli-prod.obj-type = dcards.prod-type AND
                      cli-prod.obj-code = dcards.prod-code NO-LOCK .
          FIND FIRST goods WHERE goods.artic = dcards.artic AND
                      goods.prod-type = dcards.prod-type AND
                      goods.prod-code = dcards.prod-code NO-LOCK.
          FIND FIRST gds-prt WHERE gds-prt.node-code = dcards.node-code No-LOCK NO-ERROR.
          IF AVAIL gds-prt AND NOT gds-prt.node-name = {&empty-scale}
          then
          for-name = string(goods.gds-name, "X(25)") + "\" + gds-prt.node-name.
          else for-name = goods.gds-name.
          namebuf1 = breakstr(for-name, 25, input-output namebuf1, input-output namebuf2).
          DISPLAY stream PrnLibStream
          sym1
          dcards.date_
          dcards.artic
          dcards.b-code
          cli-prod.obj-name
          namebuf1 @ goods.gds-name
          dcards.sale-price
          dcards.qnty
          dcards.sum
          dcards.discount
          (dcards.sum - dcards.discount) @ for-netto
          sym2
          with frame X123 .
          DOWN stream PrnLibStream 1 with frame X123 .
          if namebuf2 <> "" then do:
            DISPLAY stream PrnLibStream
            sym1
            namebuf2 @ goods.gds-name
            sym2 with frame X123 .
            DOWN stream PrnLibStream 1 with frame X123 .
          end.
        end. /*if dcards.b-code <> 0 then do:*/
        else do:
          if dcards.artic > "" then
          DISPLAY stream PrnLibStream
          sym1
          dcards.date_
          dcards.artic
          dcards.sum
          (dcards.sum - dcards.discount) @ for-netto
          sym2
          with frame X123 .
          DOWN stream PrnLibStream 1 with frame X123 .
        end.
      end. /*if NOT TotalOnly then do:*/
    end. /*if first-of( dcards.d-card ) then do:*/
    else do:
      if NOT TotalOnly then do:
        if dcards.b-code <> 0 then do:
          FIND FIRST cli-prod WHERE cli-prod.obj-type = dcards.prod-type AND
                                  cli-prod.obj-code = dcards.prod-code NO-LOCK .
          FIND FIRST goods WHERE goods.artic = dcards.artic AND
                      goods.prod-type = dcards.prod-type AND
                      goods.prod-code = dcards.prod-code NO-LOCK.
          FIND FIRST gds-prt WHERE gds-prt.node-code = dcards.node-code No-LOCK NO-ERROR.
          IF AVAIL gds-prt AND NOT gds-prt.node-name = {&empty-scale}
          then
          for-name = string(goods.gds-name, "X(25)") + "\" + gds-prt.node-name.
          else for-name = goods.gds-name.
          namebuf1 = breakstr(for-name, 25, input-output namebuf1, input-output namebuf2).
          DISPLAY stream PrnLibStream
          sym1
          dcards.date_
          dcards.artic
          dcards.b-code
          cli-prod.obj-name
          namebuf1 @ goods.gds-name
          dcards.sale-price
          dcards.qnty
          dcards.sum
          dcards.discount
          (dcards.sum - dcards.discount) @ for-netto
          sym2
          with frame X123 .
          DOWN stream PrnLibStream 1 with frame X123 .
          if namebuf2 <> "" then do:
            DISPLAY stream PrnLibStream
            sym1
            namebuf2 @ goods.gds-name
            sym2
            with frame X123 .
            DOWN stream PrnLibStream 1 with frame X123 .
        end.
      end. /*if dcards.b-code <> 0 then do:*/
      else do:
        if dcards.artic > "" then
        DISPLAY stream PrnLibStream
        sym1
        dcards.date_
        dcards.artic
        dcards.sum
        (dcards.sum - dcards.discount) @ for-netto
        sym2
        with frame X123 .
        DOWN stream PrnLibStream 1 with frame X123 .
      end.
    end. /*if NOT TotalOnly then do:*/
  end.
  if last-of( dcards.d-card ) then do:
    if NOT TotalOnly
    then
    UNDERLINE stream PrnLibStream
    dcards.date_
    dcards.artic
    dcards.b-code
    cli-prod.obj-name
    goods.gds-name
    dcards.sale-price
    dcards.qnty
    dcards.sum
    dcards.discount
    for-netto
    with frame X123 .
    DISPLAY stream PrnLibStream
    sym1
    "Итого" @ dcards.date_
    "по карте" @ dcards.artic
    ("чеков: " + string( accum-counter-crd ) )@ cli-prod.obj-name
    dcards.d-card @ goods.gds-name
    ACCUM-sum-crd @ dcards.sum
    ACCUM-discount-crd  @ dcards.discount
    ACCUM-netto-crd @ for-netto
    sym2
    with frame X123.
    if not TotalOnly then
    DISPLAY stream PrnLibStream
    ( ACCUM-qnty-crd ) @ dcards.qnty
    with frame X123.
    UNDERLINE stream PrnLibStream
    dcards.date_
    dcards.artic
    dcards.b-code
    cli-prod.obj-name
    goods.gds-name
    dcards.sale-price
    dcards.qnty
    dcards.sum
    dcards.discount
    for-netto
    with frame X123 .
  end.
  if t-legacy or t-subsid then do:
    if last-of(dcards.card-num-chr) then do:
    end.
    if last-of(dcards.card-num-chr) and only-one-card-per-leg = 2 then do:
      if NOT TotalOnly
      then
      UNDERLINE stream PrnLibStream
      dcards.date_
      dcards.artic
      dcards.b-code
      cli-prod.obj-name
      goods.gds-name
      dcards.sale-price
      dcards.qnty
      dcards.sum
      dcards.discount
      for-netto
      with frame X123 .
      DISPLAY stream PrnLibStream
      sym1
      "Итого" @ dcards.date_
      substitute("~{&1~}", substring(v-show-d-card, 1, 14)) @  dcards.artic
      ("чеков: " + string( ACCUM-counter-leg ))
        @ cli-prod.obj-name
      (trim( v-cli-name ) + " (" +
      (if t-legacy or t-subsid then dcards.cli-type-code else v-cli-type-code) + " )" ) @ goods.gds-name
      ACCUM-sum-leg  @ dcards.sum
      ACCUM-discount-leg @ dcards.discount
      ACCUM-netto-leg @ for-netto
      sym2
      with frame X123 .
      if not TotalOnly then
      DISPLAY stream PrnLibStream
      ( ACCUM-qnty-leg) @ dcards.qnty
      with frame X123.
      UNDERLINE stream PrnLibStream
      dcards.date_
      dcards.artic
      dcards.b-code
      cli-prod.obj-name
      goods.gds-name
      dcards.sale-price
      dcards.qnty
      dcards.sum
      dcards.discount
      for-netto
      with frame X123 .
    end.
  end.
  if last-of(dcards.cli-type-code ) and only-one-card-per-cli > 1 then do:
    if NOT TotalOnly
    then
    UNDERLINE stream PrnLibStream
    dcards.date_
    dcards.artic
    dcards.b-code
    cli-prod.obj-name
    goods.gds-name
    dcards.sale-price
    dcards.qnty
    dcards.sum
    dcards.discount
    for-netto
    with frame X123 .
    DISPLAY stream PrnLibStream
    sym1
    "Итого" @ dcards.date_
    "по клиенту"  @  dcards.artic
    ("чеков: " + string( ACCUM-counter-cli ))
      @ cli-prod.obj-name
    (trim( v-cli-name ) + " (" +
    (if t-legacy or t-subsid then dcards.cli-type-code else v-cli-type-code) + " )" ) @ goods.gds-name
    ACCUM-sum-cli  @ dcards.sum
    ACCUM-discount-cli @ dcards.discount
    ACCUM-netto-cli @ for-netto
    sym2
    with frame X123 .
    if not TotalOnly then
    DISPLAY stream PrnLibStream
    ( ACCUM-qnty-cli) @ dcards.qnty
    with frame X123.
    UNDERLINE stream PrnLibStream
    dcards.date_
    dcards.artic
    dcards.b-code
    cli-prod.obj-name
    goods.gds-name
    dcards.sale-price
    dcards.qnty
    dcards.sum
    dcards.discount
    for-netto
    with frame X123 .
   end.
   if last( dcards.d-card ) AND FixDCard = "" then do:
      DISPLAY stream PrnLibStream
      sym1
      "Итого" @ dcards.date_
      "по ВСЕМ" @ dcards.artic
      ("чеков: " + string(ACCUM-counter)) @ cli-prod.obj-name
      ACCUM-sum @ dcards.sum
      ACCUM-discount @ dcards.discount
      ACCUM-netto @ for-netto
      sym2
      with frame X123 .
      if not TotalOnly then
      Display stream PrnLibStream
      ( ACCUM-qnty) @ dcards.qnty
      with frame X123.
      UNDERLINE stream PrnLibStream
      dcards.date_
      dcards.artic
      dcards.b-code
      cli-prod.obj-name
      goods.gds-name
      dcards.sale-price
      dcards.qnty
      dcards.sum
      dcards.discount
      for-netto
      with frame X123 .
    end.
  END.
  HIDE stream PrnLibStream FRAME BottomFrame .
  if x-SelectGood = {&g-choice}
  and Print-List-hist
  then do:
    run lhistprex-print-gds-list-hist-excel  in this-procedure (input yes, input no, 2).
  end.
  if Print-List-hist
  and selectcard = 'selective' then do:
    run lhistprex-print-dc-list-hist-excel  in this-procedure (input yes, input no, 2).
  end.
  output stream PrnLibStream CLOSE .
  /*
  assign
  g#rep-tblname = ""
  g#rep-tblrid = -131
  g#rep-updflds = "Отчет по продажам постоянным клиентам|" + str1 .
*/
run prn-lib-prn-file in this-procedure (
                                          input my-handle
                                          ,input 8
                                          ).

end.
else
message
"На выбранных Вами объектах" skip
"не было продаж постоянным клиентам" skip
"в течение заданного Вами периода времени."
view-as alert-box INFORMATION .
FOR EACH dcards :
    delete dcards .
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-Var F-Frame-Win
PROCEDURE My-Var :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
frame {&frame-name} selectcard
frame {&frame-name} TotalOnly
frame {&frame-name} UpLevel
frame {&frame-name} T-time
frame {&frame-name} T-legacy
frame {&frame-name} T-subsid

.
Assign
 STR-obj-type = ''
 STR-obj-code = ''
 STR-obj-name = ''
 STR-obj      = ''.

For each obj-list no-lock:
 Assign
 STR-obj-type = STR-obj-type + obj-list.obj-type + ','
 STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
 STR-obj-name = STR-obj-name + obj-list.obj-name + ','
 STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ',' .
End.
Reportname = "ОТЧЕТ ПО ПОКУПКАМ ПОСТОЯННЫХ КЛИЕНТОВ".
ReportHeader = "Покупатели: " +
                           radio-label(string(selectcard), selectcard:radio-buttons) + {&New-line} +
               (if TotalOnly then totalOnly:label else "") + {&new-line} +
               (If Uplevel > 0
                then string((UpLevel:label + " " + string(Uplevel)) )
                else "") +
                (IF T-time then string({&new-line} + "Выборочно по времени") else "") +
                (IF T-legacy then string({&new-line} + "С учетом перевыпуска карт") else "") +
                (IF T-subsid then string({&new-line} + "С учетом дополнительных карт") else "")
                 .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records F-Frame-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this SmartObject, and there are no
     tables specified in any contained Browse, Query, or Frame. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed F-Frame-Win
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME