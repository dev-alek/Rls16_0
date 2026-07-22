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

Ведомость клиента за период времени

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/24/07
Author: Bakhtadze Natalya
Creation date: 07/24/07

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
define variable vss-description as character no-undo init "Ведомость клиента за период времени" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ cus/e-elvd2d.i "NEW SHARED" }
define variable parparentproc as widget-handle no-undo .
{ gbl/getcntxt.i def }
{ ref/dc-prop.i }
{ gbl/waitfram.i }

define temp-table temp-obj no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
field obj-name like ub.clients.obj-name
index pi
is unique primary
obj-type
obj-code.
define temp-table temp-goods no-undo
field gds-code like ub.goods.gds-code
field gds-name like ub.goods.gds-name
index pi
is unique primary
gds-code
.

define variable State-source as Widget-handle no-undo.
define variable StrBuf              as character         no-undo.
define variable Line            as character         no-undo.

define variable ii                      as  integer     no-undo.
define variable i as integer no-undo.
define variable namebuf1     as      character    no-undo.
define variable namebuf2     as      character    no-undo.
define variable v-curr-r-b as character no-undo .
DEFINE BUFFER buf_clients FOR ub.clients.

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
&Scoped-Define ENABLED-OBJECTS RECT-client B-cli f-cli-type-code f-cli-name
&Scoped-Define DISPLAYED-OBJECTS f-cli-type-code f-cli-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Button 1"
     SIZE 3 BY 1.

DEFINE VARIABLE f-cli-name AS CHARACTER FORMAT "X(105)":U
      VIEW-AS TEXT
     SIZE 55 BY .67 NO-UNDO.

DEFINE VARIABLE f-cli-type-code AS CHARACTER FORMAT "X(12)":U
      VIEW-AS TEXT
     SIZE 13 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-client
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 57 BY 6.93.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     B-cli AT ROW 1.27 COL 13.5
     f-cli-type-code AT ROW 1.27 COL 17 COLON-ALIGNED NO-LABEL
     f-cli-name AT ROW 2.33 COL 2.5 NO-LABEL
     "Клиент:" VIEW-AS TEXT
          SIZE 9 BY .97 AT ROW 1.33 COL 3
          FGCOLOR 4
     RECT-client AT ROW 1.13 COL 1.5
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 58.13 BY 15.21.


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
         HEIGHT             = 15.27
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
/* SETTINGS FOR FILL-IN f-cli-name IN FRAME F-Main
   ALIGN-L                                                              */
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

&Scoped-define SELF-NAME B-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cli F-Frame-Win
ON CHOOSE OF B-cli IN FRAME F-Main /* Button 1 */
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
run ref/cli-all.w (
                  INPUT parparentproc
                , INPUT "b-sel"
                , INPUT {&cmp}
                , INPUT {&all}
                , INPUT {&current}
                , INPUT ?
                , INPUT ",,,,,,NO,,"
                , INPUT ""
                , output v-rid-list ) NO-ERROR.
  IF v-rid-list = '':U THEN RETURN NO-APPLY.
  FIND FIRST buf_clients NO-LOCK WHERE
            recid(buf_clients) = integer(ENTRY(1, v-rid-list)) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  ASSIGN
  f-cli-type-code = buf_clients.obj-type + STRING(buf_clients.obj-code)
  f-cli-name = buf_clients.obj-name
  .
  display
  f-cli-type-code
  f-cli-name
  with frame {&frame-name} .
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
   run dispatch IN THIS-PROCEDURE ('initialize':U).
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
  DISPLAY f-cli-type-code f-cli-name
      WITH FRAME F-Main.
  ENABLE RECT-client B-cli f-cli-type-code f-cli-name
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
  run dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
  { gbl/curr-r-b.i
    v-curr-r-b
  }
  /* Code placed here will execute AFTER standard behavior.    */
  parparentproc = my-handle.
  { gbl/getcntxt.i get }

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-report F-Frame-Win
PROCEDURE My-report :
define variable v-header-base-curr as character no-undo .
define variable accum-sum-cli      as decimal no-undo .
define variable v-d-card           like ub.dis-card.d-card no-undo .
define variable v-ii as integer no-undo .
define variable stream-pos as integer no-undo .
define variable v-root-card like ub.dis-card.d-card no-undo .
define variable ii as integer no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
DEFINE VARIABLE v-date-time AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-obj-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-gds-name AS CHARACTER NO-UNDO.
define variable v-value as character no-undo .
define variable v-type as character no-undo .
define variable v-found as logical no-undo .
define variable v-account as character no-undo format "X(26)".
define variable v-car-name as character no-undo format "X(14)".
define variable v-car-number as character no-undo format "X(16)".
define variable accum-sum-netto as decimal no-undo .
define buffer buf_dis-card for ub.dis-card.
define buffer buf_currency for ub.currency.
define buffer buf_obj for ub.clients.
define buffer buf_goods for ub.goods.
define buffer buf_temp-obj  for temp-obj.
define buffer buf_temp-goods for temp-goods.
define buffer buf_Dis-card-property for ub.dis-card-property.
define buffer card_dcards for dcards.
define buffer pet_dcards for dcards.
IF NOT AVAILABLE buf_clients THEN do:
  MESSAGE
  "Не выбран клиент"
   VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN ERROR.
END.
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
v-date-time COLUMN-LABEL "Время" FORMAT "X(14)"
V-OBJ-NAME COLUMN-LABEL "АЗС" FORMAT "X(30)"
dcards.pump COLUMN-LABEL "ТРК" FORMAT ">>9"
v-gds-name COLUMN-LABEL "НП" FORMAT "X(15)"
dcards.doc-qnty COLUMN-LABEL "Кол-во" FORMAT "->>>,>>>,>>9.999"
dcards.price-real COLUMN-LABEL "Цена" FORMAT ">>>,>>>,>>9.99"
dcards.SUM-netto COLUMN-LABEL "Сумма" FORMAT "->>,>>>,>>>,>>>,>>>,>>9.99"
HEADER
cur-time-print() AT 5 format "x(35)"
v-header-base-curr  format "X(40)" AT 50
"Страница " AT 100 PAGE-NUMBER( PrnLibStream ) AT 110 FORMAT ">>>>9" SKIP
Line format "X(134)" AT 1
with width {&A4_CW0} down stream-io use-text .

run My-var IN THIS-PROCEDURE.

assign
sheetf.Excel-Column-Lable =
"Время" + {&comma-char} +
"АЗС"  + {&comma-char} +
"ТРК"  + {&comma-char} +
"НП"  + {&comma-char} +
"Кол-во" + {&comma-char} +
"Цена" + {&comma-char} +
"Сумма"
sheetf.sizes =
"14" + {&comma-char} +
"30"  + {&comma-char} +
"4"  + {&comma-char} +
"15"  + {&comma-char} +
"16"  + {&comma-char} +
"16"  + {&comma-char} +
"16"
str3 = " "
.

run waitfram-show in this-procedure ( input "Подождите ..." ) .

run cus/e-elvd2q.p (
             input X-date-Start
            ,input X-date-End
            ,input buf_clients.obj-type
            ,input buf_clients.obj-code
            )
      .
for each temp-obj:
  delete temp-obj.
end.
for each temp-goods:
  delete temp-goods.
end.
run waitfram-hide in this-procedure .
if can-find( first dcards ) then do:
  run rep/extitle.p ( input 1).
  run prn-lib-open-stream  in this-procedure (
                                                input my-handle
                                              ,input {&CS_PS}
                                              ,input yes /*p-is-stream*/
                                              ,input no /*p-append*/
                                              ).
  Line = fill( "-", {&A4_CW0} - 2) .
  FORM HEADER
  Line format "X(134)" AT 1 SKIP
  "Продолжение - на следующей странице" AT 30 SKIP
  with FRAME BottomFrame width {&A4_CW0} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream PrnLibStream FRAME BottomFrame .

  PUT stream PrnLibStream
  space(40)
  "Ведомость клиента" skip
  space(40) str1 format "X({&A4_CW0})" skip(0).
  PUT stream PrnLibStream "" skip .
  PUT stream PrnLibStream space(20) f-cli-name format "x(105)" skip.
  form with frame X123.
  FOR EACH dcards WHERE
      dcards.d-card > '':U
      AND
      dcards.chk-date > 01/01/1990
  break
  by dcards.d-card
  by dcards.chk-date
  by dcards.chk-time
  by dcards.gds-code
  by dcards.obj-type
  by dcards.obj-code:

    if first-of (dcards.d-card) then do:
      assign
        v-account = string(substitute("Счет № &1", dcards.d-card), "X(26)")
      .
      for each buf_Dis-card-property no-lock where
                buf_dis-card-property.dtm-code = {&dc-prop_dc-petrol}
            and buf_dis-card-property.d-card = dcards.d-card
      break
      by buf_dis-card-property.d-card
      by buf_dis-card-property.dt-code
      by buf_dis-card-property.sum-id :
        if first-of( buf_dis-card-property.sum-id ) then do:
          assign
            v-car-name = ""
            v-car-number = ""
          .
        end.

        if buf_dis-card-property.node-code = {&dc_prop_dc-petrol_car-brand} then do:
          assign
          v-car-name = buf_dis-card-property.property-value-character.
        end.
        if buf_dis-card-property.node-code = {&dc_prop_dc-petrol_car-reg-number} then do:
          assign
          v-car-number = buf_dis-card-property.property-value-character.
        end.
        if last-of( buf_dis-card-property.sum-id ) then do:
          display stream PrnLibstream
          v-car-name @ v-date-time
          v-car-number  @ dcards.doc-qnty
          v-account @  dcards.SUM-netto
          with frame X123 .
          down 1 stream prnlibstream
          with frame X123.
          v-found = yes.
          {&PutExcel}
          v-car-name {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          v-car-number {&tabulation}
          {&tabulation}
          v-account
          skip.
        end.
      end. /*      for each buf_Dis-card-prop no-lock where*/
    end. /*if first-of*/
    find first buf_temp-obj no-lock where
              buf_temp-obj.obj-type = dcards.obj-type
          and buf_temp-obj.obj-code = dcards.obj-code no-error.
    if not available buf_temp-obj then do:
      find first buf_obj no-lock where
                buf_obj.obj-type = dcards.obj-type
            and buf_obj.obj-code = dcards.obj-code no-error.
    if available buf_obj then do:
        create buf_temp-obj.
        assign
        buf_temp-obj.obj-type = buf_obj.obj-type
        buf_temp-obj.obj-code = buf_obj.obj-code
        buf_temp-obj.obj-name = buf_obj.obj-name
        .
    end.
    else do:
        create buf_temp-obj.
        assign
        buf_temp-obj.obj-type = dcards.obj-type
        buf_temp-obj.obj-code = dcards.obj-code
        buf_temp-obj.obj-name = substitute("&1&2", dcards.obj-type, dcards.obj-code)
        .
    end.
    end.
    find first buf_temp-goods no-lock where
              buf_temp-goods.gds-code = dcards.gds-code no-error.
    if not available buf_temp-goods then do:
      find first buf_goods no-lock where
                buf_goods.gds-code = dcards.gds-code no-error.
    if available buf_goods then do:
        create buf_temp-goods.
        assign
        buf_temp-goods.gds-code = buf_goods.gds-code
        buf_temp-goods.gds-name = buf_goods.gds-name
        .
    end.
    else do:
        create buf_temp-goods.
        assign
        buf_temp-goods.gds-code = dcards.gds-code
        buf_temp-goods.gds-name = substitute("Неизвестный товар с кодом &1", dcards.gds-code)
        .
    end.
    end.
    display stream PrnLibstream
    substitute("&1 &2"
              ,string(dcards.chk-date, "99.99.99")
              ,string(dcards.chk-time, "HH:MM")) @ v-date-time
    buf_temp-obj.obj-name @ V-OBJ-NAME
    dcards.pump
    buf_temp-goods.gds-name @ v-gds-name
    dcards.doc-qnty
    dcards.price-real
    dcards.SUM-netto
    with frame X123 .
    down 1 stream prnlibstream
    with frame X123.
    {&PutExcel}
    substitute("&1 &2"
              ,string(dcards.chk-date, "99.99.99")
              ,string(dcards.chk-time, "HH:MM")) {&tabulation}
    buf_temp-obj.obj-name {&tabulation}
    dcards.pump {&tabulation}
    buf_temp-goods.gds-name {&tabulation}
    dcards.doc-qnty {&tabulation}
    dcards.price-real {&tabulation}
    dcards.SUM-netto
    skip.
    if last-of(dcards.d-card) then do:
      find first card_dcards where
                card_dcards.d-card = dcards.d-card
            and card_dcards.chk-date = 01/01/1990
            and card_dcards.chk-time = 0
            and card_dcards.obj-type = '':U
            and card_dcards.obj-code = 0
            and card_dcards.gds-code = 0
            and card_dcards.pump = 0
            no-error.
      display stream PrnLibstream
      "ИТОГО:" @ v-gds-name
      (if available card_dcards
      then card_dcards.doc-qnty
      else 0) @ dcards.doc-qnty
      (if available card_dcards
      then card_dcards.sum-netto
      else 0) @ dcards.sum-netto
      with frame X123 .
      down 1 stream prnlibstream
      with frame X123.
      {&PutExcel}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      "ИТОГО" {&tabulation}
      (if available card_dcards
      then card_dcards.doc-qnty
      else 0)  {&tabulation}
      {&tabulation}
      (if available card_dcards
      then card_dcards.sum-netto
      else 0)
      skip.
      if available card_dcards then do:
        assign
        accum-sum-netto = accum-sum-netto + card_dcards.sum-netto.
      end.
    end. /*if last ofcard*/
  end.
  down 1 stream prnlibstream
  with frame X123.
  Put stream Prnlibstream unformatted
  "Отчет по видам топлива" at 50 skip.
  {&PutExcel}
  "Итого" {&tabulation}
  {&tabulation}
  {&tabulation}
  "по видам топлива" skip skip.
  UNDERLINE stream PrnLibStream
  v-gds-name
  dcards.doc-qnty
  dcards.price-real
  dcards.SUM-netto
  with frame X123 .
  display stream PrnLibstream
  "НП" @ v-gds-name
  "Кол-во" @ dcards.doc-qnty
  "Цена" @ dcards.price-real
  "Сумма" @ dcards.SUM-netto
  with frame X123 .
  down 1 stream prnlibstream
  with frame X123.
  {&PutExcel}
  {&tabulation}
  {&tabulation}
  {&tabulation}
  "НП" {&tabulation}
  "Кол-во" {&tabulation}
  "Цена" {&tabulation}
  "Сумма"
  skip.

  for each pet_dcards no-lock where
          pet_dcards.cli-type = buf_clients.obj-type
      and pet_dcards.cli-code = buf_clients.obj-code
      and pet_dcards.d-card = '':U
  by pet_dcards.gds-code
  by pet_dcards.price-real:
    find first buf_temp-goods no-lock where
              buf_temp-goods.gds-code = pet_dcards.gds-code .
    display stream PrnLibstream
    buf_temp-goods.gds-name @ v-gds-name
    pet_dcards.doc-qnty @ dcards.doc-qnty
    pet_dcards.price-real @ dcards.price-real
    pet_dcards.sum-netto @ dcards.SUM-netto
    with frame X123.
    down 1 stream prnlibstream
    with frame X123.
    {&PutExcel}
    {&tabulation}
    {&tabulation}
    {&tabulation}
    buf_temp-goods.gds-name {&tabulation}
    pet_dcards.doc-qnty {&tabulation}
    pet_dcards.price-real {&tabulation}
    pet_dcards.sum-netto
    skip.

  end.
  UNDERLINE stream PrnLibStream
  v-gds-name
  dcards.doc-qnty
  dcards.price-real
  dcards.SUM-netto
  with frame X123 .

  DISPLAY stream PrnLibStream
  "Отпущено за период" @ v-gds-name
  accum-sum-netto @ dcards.sum-netto
  with frame X123.
  {&PutExcel}
  "ИТОГО"  {&tabulation}
  {&tabulation}
  {&tabulation}
  "Отпущено за период" {&tabulation}
  {&tabulation}
  {&tabulation}
  accum-sum-netto
  skip.
  HIDE stream PrnLibStream FRAME BottomFrame .
  output stream PrnLibStream CLOSE .
  {&CloseExcel}
  run prn-lib-prn-file in this-procedure (
                                            input my-handle
                                            ,input 0
                                            ).

end.
else
message
"Не было продаж клиенту" skip
"в течение заданного Вами периода времени."
view-as alert-box INFORMATION .
FOR EACH dcards :
  delete dcards .
END.
FOR EACH temp-obj :
  delete temp-obj .
END.
FOR EACH temp-goods :
  delete temp-goods .
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-Var F-Frame-Win
PROCEDURE My-Var :
assign
frame {&frame-name} f-cli-type-code
f-cli-name
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
Reportname = "Ведомость клиента".
ReportHeader = substitute("Клиент: &1 &2"
                           , f-cli-type-code
                          , f-cli-name).
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