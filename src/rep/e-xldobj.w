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

Отчет Итоги по дисконтным картам

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
define variable vss-description as character no-undo init "Отчет Итоги по дисконтным картам" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-page1.i  }
{ cmp/operlist.i }
{ rep/e-xldbj.i "NEW SHARED" }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ cmp/dc-list.i dc-list def "new shared" }
{ gbl/getcntxt.i def }
{ rep/lhstprex.i dc-list-hist }

define variable     cli-str             as char         no-undo.
define variable     obj_recids     as char         no-undo.
define variable     FixGroup            as char         no-undo.
define variable     FixDCard            as char         no-undo.
define variable DcardMode as char no-undo init "ALL".
define variable FIlter-name as char no-undo.

define variable     ii                      as  integer     no-undo.
define variable one-firm as logical no-undo init yes.
define variable     current-gcode   like ub.cli-grp.node-code.
define variable num-objs as integer no-undo.

def buffer cli-obj for ub.clients .
def buffer cli-dcard for ub.clients .
define variable     Line            as char         no-undo.
define variable     TotalSum        like ub.dis-obj.gds-tot-rubl no-undo.
define variable     DiscSum         like ub.dis-obj.gds-dis-rubl no-undo.
define variable     NettoSum        like ub.dis-obj.pay-tot-rubl no-undo.
define variable     MustPay         like ub.dis-obj.pay-tot-rubl no-undo.
define variable     InstantPaySUm   like ub.dis-obj.pay-tot-rubl no-undo.
define variable     CreditSUm       like ub.dis-obj.pay-tot-rubl no-undo.
define variable     PaySum          like ub.dis-obj.pay-tot-rubl no-undo.
define variable     SaldoSUm       like ub.dis-obj.pay-tot-rubl no-undo.
define variable     MustPayStr      as char no-undo.
define variable     PaySumStr          as char no-undo.
define variable     SaldoSUmStr       as char no-undo.
define variable     FOR-D-PCNT AS CHAR no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-dcoveris as character no-undo .

DEFINE FRAME X123
ub.dis-obj.d-card     column-label "N карты"
ub.dis-obj.obj-code   column-label "Маг-н" format "99999"
sj-cards.cli-name  column-label "Клиент" format "X(28)"
FOR-d-pcnt   column-label  "Cкидка" format "x(11)"
TotalSum           column-label "Сумма покупок" format "->>>,>>>,>>9.99"
DiscSum            column-label "Сумма скидок" format "->>,>>>,>>9.99"
NettoSum           column-label "Сумма нетто"  format "->>>,>>>,>>9.99"
InstantPaySum      column-label "Оплачено!на месте"  format "->>>,>>>,>>9.99"
CreditSum          column-label "В кредит "  format "->,>>>,>>9.99"
PaySUmStr          column-label "Сумма оплат!по фирме!(данные офиса)"  format "X(15)" /*итог по карте*/
SaldoSumStr        column-label "Сальдо карты!(данные офиса)"  format "X(15)"  /*итог по карте*/
MustPayStr         column-label "К оплате!по карте!(данные офиса)" format "X(15)" /*итог по карте*/
ub.dis-obj.num-chk column-label "Чеков" format "-99999"
HEADER cur-time-print() AT 5 format "x(35)"
                "Страница " AT 100 PAGE-NUMBER( PrnLibStream )
                    AT 110 FORMAT ">>9" SKIP
            Line format "X(198)" AT 1
with width {&DOS_CW_2} down stream-io use-text .

&scoped-define underline UNDERLINE stream PrnLibStream ~
  ub.dis-obj.d-card ~
  ub.dis-obj.obj-code ~
  sj-cards.cli-name ~
  FOR-d-pcnt ~
  TotalSum ~
  DiscSum ~
  NettoSum ~
  InstantPaySUm ~
  CreditSum ~
  PaySUmStr ~
  SaldoSumStr ~
  MustPayStr ~
  ub.dis-obj.num-chk ~
  With frame X123.
&scoped-define DOWN DOWN stream PrnLibStream ~
  with frame X123.

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
&Scoped-Define ENABLED-OBJECTS RECT-3 RECT-4 RECT-5 SelectClient RS-sort ~
t-legacy TotalOnly t-subsid
&Scoped-Define DISPLAYED-OBJECTS SelectClient RS-sort t-legacy TotalOnly ~
t-subsid

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE RS-sort AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "N карты/Магазин", "shop":U,
"Магазин/N карты", "card":U,
"Магазин/группа/N карты", "group":U,
"Сумма покупок (брутто)", "tot":U,
"Сумма оплат", "sum":U
     SIZE 30.4 BY 3.8 NO-UNDO.

DEFINE VARIABLE SelectClient AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", "all":U,
"Выборочно по группам", "group":U,
"Выборочно по картам", "card":U
     SIZE 30.6 BY 3.53 NO-UNDO.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 46.6 BY 5.43.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 46.4 BY 5.2.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 46.3 BY 3.

DEFINE VARIABLE t-legacy AS LOGICAL INITIAL no
     LABEL "С учетом перевыпуска карт"
     VIEW-AS TOGGLE-BOX
     SIZE 28 BY 1 NO-UNDO.

DEFINE VARIABLE t-subsid AS LOGICAL INITIAL no
     LABEL "С учетом дополн. карт"
     VIEW-AS TOGGLE-BOX
     SIZE 28 BY 1 NO-UNDO.

DEFINE VARIABLE TotalOnly AS LOGICAL INITIAL no
     LABEL "Только итоги"
     VIEW-AS TOGGLE-BOX
     SIZE 15.8 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     SelectClient AT ROW 2.67 COL 3.8 NO-LABEL
     RS-sort AT ROW 8.13 COL 4 NO-LABEL
     t-legacy AT ROW 13 COL 19.5
     TotalOnly AT ROW 13.6 COL 4
     t-subsid AT ROW 14.33 COL 19.5
     "Покупатели" VIEW-AS TEXT
          SIZE 31.1 BY .83 AT ROW 1.5 COL 3.6
          FGCOLOR 4
     "Сортировка" VIEW-AS TEXT
          SIZE 30.1 BY .8 AT ROW 7.17 COL 3.9
          FGCOLOR 4
     "Представление" VIEW-AS TEXT
          SIZE 13.9 BY .93 AT ROW 12.6 COL 4.1
          FGCOLOR 4
     RECT-3 AT ROW 1.2 COL 2
     RECT-4 AT ROW 6.97 COL 2.3
     RECT-5 AT ROW 12.47 COL 2.4
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 49 BY 14.58.


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
         HEIGHT             = 14.77
         WIDTH              = 49.1.
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

&Scoped-define SELF-NAME SelectClient
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SelectClient F-Frame-Win
ON VALUE-CHANGED OF SelectClient IN FRAME F-Main
DO:
DEFINE buffer for-cli-grp for ub.cli-grp.
define variable ii as integer no-undo .
Assign SelectClient.
CASE SelectCLient:
    when "group":U then do:
       run ref/cli-grps.w ( input my-handle
                           ,input "b-sel"
                           ,input-output cli-str ) .
       if cli-str = "" then do:
           assign
           FixGroup = ""
           FIxdcard = ""
           current-gcode = 0
           SelectClient:screen-value = "all":U
           Dcardmode = "ALL":U
           .
       end.
       else do:
          IF num-entries(cli-str) > 1 then do:
          end.
          else do:
             FIND FIRST ub.cli-grp WHERE recid( ub.cli-grp ) = int( cli-str ) NO-LOCK .
             FIND FIRST for-cli-grp No-LOCK WHERE for-cli-grp.upper-code = ub.cli-grp.node-code No-ERROR.
             assign
             FixGroup = ub.cli-grp.node-name
             FIxdcard = ""
             current-gcode = ub.cli-grp.node-code
             Dcardmode = IF AVAIL for-cli-grp then "GROUP-LIST":U else "GROUP":U
             .
          end.
       end.
    end.
    when "all":U then do:
        assign
        FixGroup = ""
        cli-str = ""
        FIxdcard = ""
        current-gcode = 0
        Dcardmode = "ALL":U
        .
    end.
    when "card":U then do:
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
        FixGroup = ""
        cli-str = ""
        current-gcode = 0
        FIxdcard = ""
        DcardMode = "ALL":U
        SelectClient:screen-value = "all":U.
        .
      end. /* if not avail:*/
      else do:
        _dc:
        for each dc-list no-lock:
           ii = ii + 1.
          if ii > 1 then do:
            assign
            FixGroup = ""
            current-gcode = 0
            FixDCard = ""
            Dcardmode = "LIST":U
            .
            leave _dc.
          end.
        end.
        if ii = 1 then do:
          find first dc-list.
          FIND FIRST ub.dis-card WHERE ub.dis-card.d-card = dc-list.d-card NO-LOCK .
          assign
          FixGroup = ""
          cli-str = ""
          current-gcode = 0
          FixDCard = ub.dis-card.d-card
          Dcardmode = "ONE":U
          .
        end.
      end.
    end.
END CASE.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-legacy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-legacy F-Frame-Win
ON VALUE-CHANGED OF t-legacy IN FRAME F-Main /* С учетом перевыпуска карт */
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


&Scoped-define SELF-NAME t-subsid
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-subsid F-Frame-Win
ON VALUE-CHANGED OF t-subsid IN FRAME F-Main /* С учетом дополн. карт */
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cardcycle F-Frame-Win
PROCEDURE cardcycle :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
def buffer bsj-cards for sj-cards.
if t-legacy or t-subsid then do:
  FOR EACH obj-list no-lock ,
      EACH legacy-obj no-lock WHERE
          legacy-obj.obj-type = obj-list.obj-type AND
          legacy-obj.obj-code = obj-list.obj-code,
      FIRST bsj-cards No-LOCK WHERE
            bsj-cards.card-num-chr  = legacy-obj.card-num-chr
         AND bsj-cards.is-sum = yes
      BREAK
      by legacy-obj.obj-type
      by legacy-obj.obj-code
      by legacy-obj.d-card:
    if one-firm and v-curr-r-b = {&r-b-base} then do:
      { rep/e-xldbj2.i  "base" legacy-obj }
    end.
    else do:
      { rep/e-xldbj2.i  "rubl" legacy-obj }
    ENd.
  end.
end.
else do:
 FOR EACH obj-list no-lock ,
    EACH ub.dis-obj no-lock WHERE
         ub.dis-obj.dt-code = 0 AND
         ub.dis-obj.obj-type = obj-list.obj-type AND
         ub.dis-obj.obj-code = obj-list.obj-code,
    FIRST bsj-cards No-LOCK WHERE
          bsj-cards.d-card = ub.dis-obj.d-card
    BREAK by ub.dis-obj.obj-type
          by ub.dis-obj.obj-code
          by ub.dis-obj.d-card:
  if one-firm and v-curr-r-b = {&r-b-base} then do:
    { rep/e-xldbj2.i  "base" ub.dis-obj }
  end.
  else do:
    { rep/e-xldbj2.i  "rubl" ub.dis-obj }
  ENd.
end.

 END.
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
  DISPLAY SelectClient RS-sort t-legacy TotalOnly t-subsid
      WITH FRAME F-Main.
  ENABLE RECT-3 RECT-4 RECT-5 SelectClient RS-sort t-legacy TotalOnly t-subsid
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE groupcycle F-Frame-Win
PROCEDURE groupcycle :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
def buffer bsj-cards for sj-cards.
define variable vnum-chk as integer no-undo.
define variable vPaySum as decimal no-undo.
define variable vMustPay as decimal no-undo.
define variable vSaldoSUm as decimal no-undo.

if t-legacy or t-subsid then do:
  FOR EACH obj-list no-lock ,
      EACH legacy-obj no-lock WHERE
          legacy-obj.obj-type = obj-list.obj-type AND
          legacy-obj.obj-code = obj-list.obj-code,
      FIRST bsj-cards No-LOCK WHERE
            bsj-cards.card-num-chr = legacy-obj.card-num-chr
        ANd bsj-cards.is-sum = yes
      BREAK by legacy-obj.obj-type
            by legacy-obj.obj-code
            by bsj-cards.g-code
            by legacy-obj.d-card:
    if one-firm and v-curr-r-b = {&r-b-base} then do:
      { rep/e-xldbj3.i  "base" legacy-obj }
    end.
    else do:
      { rep/e-xldbj3.i  "rubl" legacy-obj }
    ENd.
  END.
end.
else do:
  FOR EACH obj-list no-lock ,
      EACH ub.dis-obj no-lock WHERE
          ub.dis-obj.dt-code = 0 AND
          ub.dis-obj.obj-type = obj-list.obj-type AND
          ub.dis-obj.obj-code = obj-list.obj-code,
      FIRST bsj-cards No-LOCK WHERE
            bsj-cards.d-card = ub.dis-obj.d-card
      BREAK by ub.dis-obj.obj-type
            by ub.dis-obj.obj-code
            by bsj-cards.g-code
            by ub.dis-obj.d-card:
    if one-firm and v-curr-r-b = {&r-b-base} then do:
      { rep/e-xldbj3.i  "base" ub.dis-obj }
    end.
    else do:
      { rep/e-xldbj3.i  "rubl" ub.dis-obj }
    ENd.
  END.
end.
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

  /* Code placed here will execute AFTER standard behavior.    */
define variable v-conf-type as character no-undo .
  /* Code placed here will execute AFTER standard behavior.    */
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
   t-legacy with
   frame {&frame-name} .
   { gbl/getcntxt.i get " " my-handle  }

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-report F-Frame-Win
PROCEDURE My-report :
define variable current-group like ub.cli-grp.node-name.
define variable host-name like ub.clients.obj-name.
define variable up-current-group like ub.cli-grp.node-name.
define variable jj as integer no-undo.
define variable v-ii as integer no-undo .
define variable v-d-card like ub.dis-card.d-card no-undo .
define variable last-card like ub.dis-card.d-card no-undo .
define variable last-card-d-pcntchr as character no-undo .
define variable accum-must-pay      as decimal no-undo .
define variable accum-saldo         as decimal no-undo .
define variable accum-pay           as decimal no-undo .
define variable accum-tot           as decimal no-undo .
define variable accum-disc          as decimal no-undo .
define variable accum-netto         as decimal no-undo .
define variable accum-instant-pay   as decimal no-undo .
define variable accum-credit-pay    as decimal no-undo .
define variable accum-num-chk       as integer no-undo .

def buffer bsj-cards for sj-cards.
def buffer bsj-groups for sj-groups.
define buffer buf_dis-card for ub.dis-card.
{ gbl/curr-r-b.i
  v-curr-r-b
}
run My-var.
if dis-obj-found then do:
   for each sj-cards:
    delete sj-cards.
   end.
   for each legacy-obj:
    delete legacy-obj.
   end.
   for each sj-groups:
    delete sj-groups.
   end.
    dis-obj-found = no.
   if DcardMode = "GROUP-LIST":U then do:
      FIND FIRST ub.cli-grp where
                  ub.cli-grp.node-code = current-gcode NO-LOCK NO-ERROR.
      up-current-group = ub.cli-grp.node-name.
      RUN treegrp(ub.cli-grp.node-code, buffer cli-grp).
   end.
    run rep/e-xldbj.p (
                    input v-cntxt-host-code-obj
                   ,input DCardMode
                   ,input FixDcard
                   ,input current-gcode
                   ,input cli-str
                   ,input Filter-name
                   ,input TotalOnly
                   ,INPUT t-legacy
                   ,input t-subsid
                   ,input (if one-firm and v-curr-r-b = {&r-b-base}
                          then {&r-b-base}
                          else {&r-b-rubl})
                   ,input (if RS-sort = "group"
                           OR dcardmode = "group":U
                           then "group"
                           else "")
                   ,input (if current-gcode = 0
                          then "ALL"
                          else  (IF DCARDmode = "GROUP"
                                  then "ONE"
                                  else "LIST")
                                )
                   )
                   no-error
                   .
  if error-status:error then do:
    message
    vss-workfile vss-revision vss-description skip
    "Ошибки при сборе информации для отчета" skip
    error-status:get-message(1) skip
    return-value
    view-as alert-box .
    return.
  end.
  if NOT dis-obj-found then do:
    run waitfram-hide in this-procedure .
    message "На выбранных Вами объектах" skip
            "нет итогов по дисконтным картам" skip
            "постоянных клиентов" skip
            "либо объекты принадлежат нетекущей фирме"
    view-as alert-box INFORMATION .
    return.
  end.
  IF t-legacy
  or t-subsid
  THEN DO:
    FOR EACH sj-cards NO-LOCK WHERE
           sj-cards.is-sum = no
    BREAK
    BY sj-cards.card-num-chr
    :
       IF FIRST-OF (sj-cards.card-num-chr) THEN DO:
          ASSIGN
          accum-must-pay      = 0
          accum-saldo         = 0
          accum-pay           = 0
          accum-tot           = 0
          accum-disc          = 0
          accum-netto         = 0
          accum-instant-pay   = 0
          accum-credit-pay    = 0
          accum-num-chk       = 0
          .
       END.
        ASSIGN
        accum-must-pay      = accum-must-pay       +            sj-cards.must-pay
        accum-saldo         = accum-saldo          +            sj-cards.saldo
        accum-pay           = accum-pay            +            sj-cards.pay
        accum-tot           = accum-tot            +            sj-cards.tot
        accum-disc          = accum-disc           +            sj-cards.disc
        accum-netto         = accum-netto          +            sj-cards.netto
        accum-instant-pay   = accum-instant-pay    +            sj-cards.instant-pay
        accum-credit-pay    = accum-credit-pay     +            sj-cards.credit-pay
        accum-num-chk       = accum-num-chk        +            sj-cards.num-chk
        .
       IF last-OF (sj-cards.card-num-chr) THEN DO:
         create bsj-cards.
         buffer-copy sj-cards except
         must-pay
         saldo
         pay
         tot
         disc
         netto
         instant-pay
         credit-pay
         num-chk
         to bsj-cards
         assign
         bsj-cards.d-card           =  sj-cards.last-card
         bsj-cards.is-sum = yes
         bsj-cards.must-pay         = accum-must-pay
         bsj-cards.saldo            = accum-saldo
         bsj-cards.pay              = accum-pay
         bsj-cards.tot              = accum-tot
         bsj-cards.disc             = accum-disc
         bsj-cards.netto            = accum-netto
         bsj-cards.instant-pay      = accum-instant-pay
         bsj-cards.credit-pay       = accum-credit-pay
         bsj-cards.num-chk          = accum-num-chk
         .
         release bsj-cards.
       end. /*IF last-OF (sj-cards.card-num-chr) THEN DO:*/
    END. /*FOR EACH sj-cards NO-LOCK WHERE*/
  END. /*if-legacy or t-subsid*/
  Line = fill( "-", 200 ) .
  FIND FIRST ub.clients NO-LOCK WHERE
            ub.clients.obj-type = {&cmp} AND
           ub.clients.obj-code = v-cntxt-host-code-obj NO-ERROR.
  IF AVAIL ub.clients then
  host-name = ub.clients.obj-name.

   run prn-lib-open-stream  in this-procedure (
                                                input my-handle
                                                ,input {&LS_PS_A4}
                                                ,input yes /*p-is-stream*/
                                                ,input no /*p-append*/
                                                ).

  FORM HEADER
  Line format "X(198)" AT 1 SKIP
  "Продолжение - на следующей странице" AT 30 SKIP
  with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream PrnLibStream FRAME BottomFrame .
  PUT stream PrnLibStream space(40)
  "Итоги по дисконтным картам постоянныx клиентов" skip
  space(20) "По объектам :  " .
  FOR EACH obj-list NO-LOCK
  :
      FIND FIRST cli-obj WHERE
                cli-obj.obj-type = obj-list.obj-type AND
                cli-obj.obj-code = obj-list.obj-code NO-LOCK .
      FIND FIRST ub.db WHERE
                ub.db.db-num = cli-obj.db-num NO-LOCK .
      PUT stream PrnLibStream
          string( trim( string( db.db-name, "x(30)" ) ) + " / " + cli-obj.obj-name )
          format "x(100)"     skip(0)  space(35).
      ACCUMULATE obj-list.obj-code (COUNT).
  END.
  num-objs = ACCUM COUNT obj-list.obj-code.
  PUT stream PrnLibStream "" skip .
  CASE DcardMode:
      when "ALL":U then do:
          PUT stream PrnLibStream space(20) "По ВСЕМ клиентам." format "x(40)" skip(0).
      end.
      when "GROUP":U then do:
          FIND FIRST cli-grp where
                     cli-grp.node-code = current-gcode NO-LOCK NO-ERROR.
          PUT stream PrnLibStream
          space(20) ( "По группе : " + cli-grp.node-name ) format "x(80)" skip(0).
      end.
      when "GROUP-LIST":U then do:
          FIND FIRST cli-grp where
                     cli-grp.node-code = current-gcode NO-LOCK NO-ERROR.
          up-current-group = cli-grp.node-name.
          PUT stream PrnLibStream
          space(20) ( "По группе   : " + cli-grp.node-name ) format "x(80)" skip(0).
          PUT stream PrnLibStream
          space(20) ("Подгруппы :") skip(0).
          FOR EACH bsj-groups WHERE
                   bsj-groups.obj-code = 0:
            PUT stream PrnLibStream
            space(35) bsj-groups.g-name format "X(80)" SKIP.
          END.
      end.
      when "LIST":U then do:
       PUT stream PrnLibStream space(10) string("По сформированному списку карт") format "x(50)" skip.
       for each dc-list no-lock:
          ii = ii + 1.
          PUT stream PrnLibStream unformatted
          string(dc-list.d-card + {&comma-char} + {&space-char}, "X(21)") .
          if ii = 9 then do:
            PUT stream PrnLibStream unformatted skip.
            ii = 0.
          end.
       end.
       PUT stream PrnLibStream unformatted skip.
      end.
      when "ONE":U then do:
          PUT stream PrnLibStream
          space(20) ("По дисконтной карте N " + FixDcard) format "x(80)" skip(0).
      end.
  END CASE.
  if t-legacy then do:
    PUT stream PrnLibStream
    "С учетом перевыпуска карт (указаны номера, % скидки для карт ПОСЛЕДНЕГО ВЫПУСКА," skip
    "остальные суммы и количества по картам включают суммы и количества по картам предыдущих выпусков"
    skip(0).
  end.
  if one-firm and v-curr-r-b = {&r-b-base} then
     PUT stream PrnLibStream space(49) string( "( Все цены указаны в баз.вал. )" ) format "X(40)" Skip(0).
  else do:
      PUT stream PrnLibStream space(49) string( "( Все цены указаны в {&abbr_rub_allshift} )" ) format "X(40)" Skip(0).
  end.
  CASE RS-Sort:
    WHEN "shop":U then do:
      run SHopcycle no-error.
    END.
    WHEN "card":U then do:
      run Cardcycle no-error.
    end.
    when "group":U then do:
      run Groupcycle no-error.
    end.
    when "sum":U then do:
      IF num-objs > 1 then do:
        run SumCycleMulti no-error.
      end.
      else do:
        run SUmCycleSingle no-error.
      end.
    end.
    when "tot":U then do:
      IF num-objs > 1 then do:
        run TotCycleMulti no-error.
      end.
      else do:
        run TotCycleSingle no-error.
      end.
    end.

  END CASE.
  run waitfram-hide in this-procedure .
  PUT stream PrnLibStream " " SKIP.
  HIDE stream PrnLibStream FRAME BottomFrame .
  if Print-List-hist
  and selectclient = 'card' then do:
    run lhistprex-print-dc-list-hist-excel  in this-procedure (input yes, input no, 2).
  end.
  output stream PrnLibStream CLOSE .
  /*
  assign
      g#rep-tblname = ""
      g#rep-tblrid = -131
      g#rep-updflds = "Итоги по дисконтным картам постоянныx клиентов"  .
*/
run prn-lib-prn-file in this-procedure (
                                          input my-handle
                                          ,input 8
                                          ).

end. /*dis-obj-found*/
else
message "На выбранных Вами объектах" skip
        "нет итогов по дисконтным картам" skip
        "постоянных клиентов" skip
        "либо объекты принадлежат нетекущей фирме"
view-as alert-box INFORMATION .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-var F-Frame-Win
PROCEDURE My-var :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-base-code-0 like ub.sysconf.host-code no-undo init ?.
define variable v-base-code like ub.sysconf.host-code no-undo init ?.
assign
frame {&frame-name} TotalOnly
frame {&frame-name} SELECTCLIENT
frame {&frame-name} RS-sort
frame {&frame-name} t-legacy
.
assign
num-objs = 0
one-firm = yes.
FOR EACH obj-list :
    if can-find( FIRST ub.dis-obj WHERE
                       ub.dis-obj.obj-type = obj-list.obj-type AND
                       ub.dis-obj.obj-code = obj-list.obj-code ) then do:
       dis-obj-found = yes.
       num-objs = num-objs + 1.
       FIND FIRST ub.shop No-LOCK WHERE ub.Shop.obj-code = obj-list.obj-code No-ERROR.
       { gbl/basecode.i shop.host-code v-base-code }
       if num-objs = 1 then do:
        assign
        v-base-code-0 = v-base-code
        .
       end.
       if one-firm and NOT (v-base-code-0 = v-base-code) and num-objs > 1 then one-firm = no.
    end.
end.

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
Reportname = "ИТОГИ ПО ДИСКОНТНЫМ КАРТАМ".
ReportHeader = "Покупатели: " +
                radio-label(string(SelectClient), SelectClient:radio-buttons) + {&New-line} +
                "Сортировка: " +
                radio-label(string(rs-sort), rs-sort:radio-buttons) + {&New-line} +
                (if TotalOnly then totalOnly:label else "") + {&new-line} +
                (if T-legacy  then t-legacy:label else "")
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE shopcycle F-Frame-Win
PROCEDURE shopcycle :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
def buffer bsj-cards for sj-cards.
if t-legacy or t-subsid then do:
  FOR EACH obj-list no-lock ,
      EACH legacy-obj no-lock WHERE
           legacy-obj.obj-type = obj-list.obj-type AND
           legacy-obj.obj-code = obj-list.obj-code,
      FIRST bsj-cards No-LOCK WHERE
            bsj-cards.card-num-chr = legacy-obj.card-num-chr
        AND bsj-cards.is-sum = yes
      BREAK
      by legacy-obj.d-card
      by legacy-obj.obj-type
      by legacy-obj.obj-code:
    if one-firm and v-curr-r-b = {&r-b-base} then do:
      { rep/e-xldbj1.i  "base" legacy-obj }
    end.
    else do:
      { rep/e-xldbj1.i  "rubl" legacy-obj }
    end.
  END.
end.
else do:
  FOR EACH obj-list no-lock ,
      EACH ub.dis-obj no-lock WHERE
            ub.dis-obj.dt-code = 0 AND
            ub.dis-obj.obj-type = obj-list.obj-type AND
            ub.dis-obj.obj-code = obj-list.obj-code,
      FIRST bsj-cards No-LOCK WHERE
            bsj-cards.d-card = ub.dis-obj.d-card
      BREAK
      by ub.dis-obj.d-card
      by ub.dis-obj.obj-type
      by ub.dis-obj.obj-code:
    if one-firm and v-curr-r-b = {&r-b-base} then do:
      { rep/e-xldbj1.i  "base" ub.dis-obj }
    end.
    else do:
      { rep/e-xldbj1.i  "rubl" ub.dis-obj }
    end.
  END.
end.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sumcyclemulti F-Frame-Win
PROCEDURE sumcyclemulti :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
def buffer bsj-cards for sj-cards.
if t-legacy or t-subsid then do:
  FOR EACH obj-list no-lock ,
      EACH legacy-obj no-lock WHERE
          legacy-obj.obj-type = obj-list.obj-type AND
          legacy-obj.obj-code = obj-list.obj-code,
      FIRST bsj-cards No-LOCK WHERE
            bsj-cards.card-num-chr = legacy-obj.card-num-chr
        AND bsj-cards.is-sum = yes
      BREAK by bsj-cards.pay
            by legacy-obj.d-card
            by legacy-obj.obj-type
            by legacy-obj.obj-code
            :
    if one-firm and v-curr-r-b = {&r-b-base} then do:
      { rep/e-xldbj1.i  "base" legacy-obj }
    end.
    else do:
      { rep/e-xldbj1.i  "rubl"  legacy-obj }
    ENd.

  END.

end.
else do:
  FOR EACH obj-list no-lock ,
      EACH ub.dis-obj no-lock WHERE
          ub.dis-obj.dt-code = 0 AND
          ub.dis-obj.obj-type = obj-list.obj-type AND
          ub.dis-obj.obj-code = obj-list.obj-code ,
      FIRST bsj-cards No-LOCK WHERE
            bsj-cards.d-card = ub.dis-obj.d-card
      BREAK by bsj-cards.pay
            by ub.dis-obj.d-card
            by ub.dis-obj.obj-type
            by ub.dis-obj.obj-code
            :
    if one-firm and v-curr-r-b = {&r-b-base} then do:
      { rep/e-xldbj1.i  "base" ub.dis-obj }
    end.
    else do:
      { rep/e-xldbj1.i  "rubl" ub.dis-obj }
    ENd.

  END.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sumcyclesingle F-Frame-Win
PROCEDURE sumcyclesingle :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
def buffer bsj-cards for sj-cards.
if t-legacy or t-subsid then do:
  if v-curr-r-b = {&r-b-base} then do:
    FOR EACH obj-list no-lock ,
        EACH legacy-obj no-lock WHERE
            legacy-obj.obj-type = obj-list.obj-type AND
            legacy-obj.obj-code = obj-list.obj-code,
        FIRST bsj-cards No-LOCK WHERE
              bsj-cards.card-num-chr = legacy-obj.card-num-chr
        AND bsj-cards.is-sum = yes
        BREAK by legacy-obj.obj-type
              by legacy-obj.obj-code
              by legacy-obj.pay-tot-base
              by legacy-obj.d-card:
      if one-firm  then  do:
        { rep/e-xldbj4.i  "base" legacy-obj }
      end.
      else do:
        { rep/e-xldbj4.i  "rubl" legacy-obj }
      ENd.
    END.
  end.
  else do:
    FOR EACH obj-list no-lock ,
        EACH legacy-obj no-lock WHERE
            legacy-obj.obj-type = obj-list.obj-type AND
            legacy-obj.obj-code = obj-list.obj-code,
        FIRST bsj-cards No-LOCK WHERE
              bsj-cards.card-num-chr = legacy-obj.card-num-chr
        AND bsj-cards.is-sum = yes
        BREAK by legacy-obj.obj-type
              by legacy-obj.obj-code
              by legacy-obj.pay-tot-rubl
              by legacy-obj.d-card:
      { rep/e-xldbj4.i  "rubl" legacy-obj }
    END.
  end.
end.
else do:
  if v-curr-r-b = {&r-b-base} then do:
    FOR EACH obj-list no-lock ,
        EACH ub.dis-obj no-lock WHERE
            ub.dis-obj.dt-code = 0 AND
            ub.dis-obj.obj-type = obj-list.obj-type AND
            ub.dis-obj.obj-code = obj-list.obj-code,
        FIRST bsj-cards No-LOCK WHERE
              bsj-cards.d-card = ub.dis-obj.d-card
        BREAK by ub.dis-obj.obj-type
              by ub.dis-obj.obj-code
              by ub.dis-obj.pay-tot-base
              by ub.dis-obj.d-card:
      if one-firm  then  do:
        { rep/e-xldbj4.i  "base" ub.dis-obj }
      end.
      else do:
        { rep/e-xldbj4.i  "rubl" ub.dis-obj }
      ENd.
    END.
  end.
  else do:
    FOR EACH obj-list no-lock ,
        EACH ub.dis-obj no-lock WHERE
            ub.dis-obj.dt-code = 0 AND
            ub.dis-obj.obj-type = obj-list.obj-type AND
            ub.dis-obj.obj-code = obj-list.obj-code,
        FIRST bsj-cards No-LOCK WHERE
              bsj-cards.d-card = ub.dis-obj.d-card
        BREAK by ub.dis-obj.obj-type
              by ub.dis-obj.obj-code
              by ub.dis-obj.pay-tot-rubl
              by ub.dis-obj.d-card:
      { rep/e-xldbj4.i  "rubl" ub.dis-obj }
    END.
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE totcyclemulti F-Frame-Win
PROCEDURE totcyclemulti :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
def buffer bsj-cards for sj-cards.
if t-legacy or t-subsid then do:
  FOR EACH obj-list no-lock ,
      EACH legacy-obj no-lock WHERE
          legacy-obj.obj-type = obj-list.obj-type AND
          legacy-obj.obj-code = obj-list.obj-code,
      FIRST bsj-cards No-LOCK WHERE
            bsj-cards.card-num-chr = legacy-obj.card-num-chr
      AND bsj-cards.is-sum = yes
      BREAK by bsj-cards.tot
            by legacy-obj.d-card
            by legacy-obj.obj-type
            by legacy-obj.obj-code
            :
    if one-firm and v-curr-r-b = {&r-b-base} then  do:
      { rep/e-xldbj1.i  "base" legacy-obj }
    end.
    else do:
      { rep/e-xldbj1.i  "rubl" legacy-obj }
    ENd.

  END.
end.
else do:
  FOR EACH obj-list no-lock ,
      EACH ub.dis-obj no-lock WHERE
          ub.dis-obj.dt-code = 0 AND
          ub.dis-obj.obj-type = obj-list.obj-type AND
          ub.dis-obj.obj-code = obj-list.obj-code,
      FIRST bsj-cards No-LOCK WHERE
            bsj-cards.d-card = ub.dis-obj.d-card
      BREAK by bsj-cards.tot
            by ub.dis-obj.d-card
            by ub.dis-obj.obj-type
            by ub.dis-obj.obj-code
            :
    if one-firm and v-curr-r-b = {&r-b-base} then  do:
      { rep/e-xldbj1.i  "base" ub.dis-obj }
    end.
    else do:
      { rep/e-xldbj1.i  "rubl" ub.dis-obj  }
    ENd.

  END.

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE totcyclesingle F-Frame-Win
PROCEDURE totcyclesingle :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
def buffer bsj-cards for sj-cards.
if t-legacy or t-subsid then do:
  if v-curr-r-b = {&r-b-base} then do:
    FOR EACH obj-list no-lock ,
        EACH legacy-obj no-lock WHERE
            legacy-obj.obj-type = obj-list.obj-type AND
            legacy-obj.obj-code = obj-list.obj-code,
        FIRST bsj-cards No-LOCK WHERE
              bsj-cards.card-num-chr = legacy-obj.card-num-chr
        AND bsj-cards.is-sum = yes
        BREAK by legacy-obj.obj-type
              by legacy-obj.obj-code
              by legacy-obj.gds-tot-base
              by legacy-obj.d-card:
      if one-firm then  do:
        { rep/e-xldbj4.i "base" Legacy-obj }
      end.
      else do:
        { rep/e-xldbj4.i  "rubl" legacy-obj }
      ENd.
    END.
  end.
  else do:
    FOR EACH obj-list no-lock ,
        EACH legacy-obj no-lock WHERE
            legacy-obj.obj-type = obj-list.obj-type AND
            legacy-obj.obj-code = obj-list.obj-code,
        FIRST bsj-cards No-LOCK WHERE
              bsj-cards.card-num-chr = legacy-obj.card-num-chr
        AND bsj-cards.is-sum = yes
        BREAK by legacy-obj.obj-type
              by legacy-obj.obj-code
              by legacy-obj.gds-tot-rubl
              by legacy-obj.d-card:
      { rep/e-xldbj4.i  "rubl" legacy-obj }
    END.

  end.
end.
else do:
  if v-curr-r-b = {&r-b-base} then do:
    FOR EACH obj-list no-lock ,
        EACH ub.dis-obj no-lock WHERE
            ub.dis-obj.dt-code = 0 AND
            ub.dis-obj.obj-type = obj-list.obj-type AND
            ub.dis-obj.obj-code = obj-list.obj-code,
        FIRST bsj-cards No-LOCK WHERE
              bsj-cards.d-card = ub.dis-obj.d-card
        BREAK by ub.dis-obj.obj-type
              by ub.dis-obj.obj-code
              by ub.dis-obj.gds-tot-base
              by ub.dis-obj.d-card:
      if one-firm then  do:
        { rep/e-xldbj4.i "base" ub.dis-obj }
      end.
      else do:
        { rep/e-xldbj4.i  "rubl" ub.dis-obj }
      ENd.
    END.
  end.
  else do:
    FOR EACH obj-list no-lock ,
        EACH ub.dis-obj no-lock WHERE
            ub.dis-obj.dt-code = 0 AND
            ub.dis-obj.obj-type = obj-list.obj-type AND
            ub.dis-obj.obj-code = obj-list.obj-code,
        FIRST bsj-cards No-LOCK WHERE
              bsj-cards.d-card = ub.dis-obj.d-card
        BREAK by ub.dis-obj.obj-type
              by ub.dis-obj.obj-code
              by ub.dis-obj.gds-tot-rubl
              by ub.dis-obj.d-card:
      { rep/e-xldbj4.i  "rubl" ub.dis-obj }
    END.

  end.

end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE treegrp F-Frame-Win
PROCEDURE treegrp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
def input parameter c like ub.cli-grp.node-code.
def param buffer b-cli-grp for ub.cli-grp.
def buffer up-cli-grp for ub.cli-grp.
define variable no-nodes as logical initial yes.
FOR EACH b-cli-grp where b-cli-grp.upper-code = c  NO-LOCK:
        no-nodes = no.
        RUN treegrp ( ub.cli-grp.node-code, buffer b-cli-grp ).
END .  /*  for each b-gds-prt  */
if no-nodes then do: /* терминальный узел */
        FIND FIRST up-cli-grp NO-LOCK where up-cli-grp.node-code = c NO-ERROR.
                create sj-groups.
                assign
                sj-groups.g-code = up-cli-grp.node-code
                sj-groups.g-name = up-cli-grp.node-name
                .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME