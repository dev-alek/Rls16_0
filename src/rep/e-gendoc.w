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

Общие количества и суммы по товарам списка документов

Автор: Комаров Иван Сергеевич
Дата создания: 12/14/10
Author: Ivan Komarov
Creation date: 12/14/10

Автор1: Бахтадзе Наталья Викторовна
Дата создания1: 04/05/06

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
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Общие количества и суммы по товарам списка документов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/cur-time.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i  }
{ gbl/waitfram.i }

DEFINE SHARED BUFFER t-doc FOR  ub.trn-doc.

{ cmp/doc-list.i  doc-list def "shared" }
define shared buffer temp-trn-doc for doc-list  .
define shared query br-docs for t-doc except  , temp-trn-doc scrolling.

DEFINE SHARED VAR objects as integer no-undo.
DEFINE SHARED VAR FRAME-TITLE as char no-undo.
define variable multi-obj as logical no-undo.
define variable trid as recid no-undo.

def work-table t-cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    .
define temp-table temp-goods no-undo
field gds-code  like ub.goods.gds-code
field artic     like ub.goods.artic
field prod-type like ub.goods.prod-type
field prod-code like ub.goods.prod-code
field gds-name  like ub.goods.gds-name
field cli-type  like ub.clients.obj-type
field cli-code  like ub.clients.obj-code
field unit-base like ub.goods.unit-base
field qnty      like ub.doc-line.fact-qnty
field sum-uch as decimal
field sum-uch-without as decimal
field sum-doc as decimal
field PS like ub.trn-doc.PS
index pi is UNIQUE PRIMARY
cli-type
cli-code
gds-code
index
artic
prod-type
prod-code
.
define buffer cli-obj for ub.clients .
define variable   cli-list      as character  no-undo.
define variable   v-goods-flag  as integer    no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER FRAME

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 button-cli RS-cli E-cli rs-sort
&Scoped-Define DISPLAYED-OBJECTS RS-cli E-cli rs-sort

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON button-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "button-cli"
     SIZE 3 BY .88.

DEFINE VARIABLE E-cli AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 32.63 BY 2.33 NO-UNDO.

DEFINE VARIABLE RS-cli AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", "1",
"Выборочно", "2"
     SIZE 17.25 BY 2.79 NO-UNDO.

DEFINE VARIABLE rs-sort AS LOGICAL INITIAL yes
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по контрагенту", yes,
"по товару", no
     SIZE 24.5 BY 2.5 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 57 BY 4.33.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     button-cli AT ROW 7.46 COL 47.38
     RS-cli AT ROW 7.88 COL 3.25 NO-LABEL
     E-cli AT ROW 8.75 COL 22.25 NO-LABEL
     rs-sort AT ROW 13 COL 2 NO-LABEL WIDGET-ID 2
     "Выбор контрагента" VIEW-AS TEXT
          SIZE 20.25 BY .88 AT ROW 7.38 COL 22.38
          FGCOLOR 4
     "Сортировка:" VIEW-AS TEXT
          SIZE 20.25 BY .88 AT ROW 12 COL 2 WIDGET-ID 8
          FGCOLOR 4
     RECT-1 AT ROW 7.04 COL 1.88
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 59 BY 15.29.


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
         HEIGHT             = 15.29
         WIDTH              = 59.
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
   NOT-VISIBLE FRAME-NAME                                               */
ASSIGN
       E-cli:READ-ONLY IN FRAME F-Main        = TRUE.

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

&Scoped-define SELF-NAME button-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL button-cli F-Frame-Win
ON CHOOSE OF button-cli IN FRAME F-Main /* button-cli */
DO:
    define variable ii as integer no-undo.
    assign
    cli-list = ""
    .
    run ref/cli-all.w ( my-handle
                 , "b-sel,b-mark":U
                 , {&all}
                 , {&all}
                 , {&current}
                 , ?
                 , ",,,,,,NO,,"
                 ,?
                  , output cli-list ) .
    if cli-list <> ""
    then do:
      assign E-cli:screen-value = "" .
      DO ii = 1 to num-entries(cli-list):

      FIND FIRST cli-obj No-LOCK WHERE recid( cli-obj ) = int(ENTRY(ii, cli-list )) .
        FIND FIRST t-cli  WHERE
                  t-cli.obj-type = cli-obj.obj-type AND
                  t-cli.obj-code = cli-obj.obj-code No-ERROR.
        IF not avail t-cli then do:
          create t-cli.
          assign
            t-cli.obj-type = cli-obj.obj-type
            t-cli.obj-code = cli-obj.obj-code
            t-cli.obj-name = cli-obj.obj-name
          .
        END.
      assign
      E-cli:screen-value = E-cli:screen-value + cli-obj.obj-name + {&new-line}.
      end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-cli F-Frame-Win
ON VALUE-CHANGED OF RS-cli IN FRAME F-Main
DO:
  ASSIGN
  RS-CLI.
  CASE rs-cli:
    when "all":U then do:
        FOR EACH t-cli:
          delete t-cli.
        END.
        disable button-cli
        with frame {&frame-name}.
        assign E-cli:screen-value = "".
    END.
    WHEN "selective":U then do:
        enable button-cli
        with frame {&frame-name}.
        APPLY "CHOOSE" to button-cli.
    END.

  END.
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
  DISPLAY RS-cli E-cli rs-sort
      WITH FRAME F-Main.
  ENABLE RECT-1 button-cli RS-cli E-cli rs-sort
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

  /* Code placed here will execute AFTER standard behavior.    */
  Rs-cli:radio-buttons in frame {&frame-name}  = "Все" + {&comma-char} + "all":U + {&comma-char} +
                                                 "Выборочно" + {&comma-char} + "selective":U.
  Rs-cli:screen-value = "all":U.
  apply "VALUE-CHANGED" to rs-cli.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-report F-Frame-Win
PROCEDURE My-report :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{ str/in-vatp.i def }
{ str/out-vatp.i def }
define variable sign          as integer   no-undo .
define variable cur-qnty      as decimal   no-undo .
define variable for-cli-name  as character no-undo .
define variable for-prod-name as character no-undo .
define variable date_string   as character no-undo .
define variable line          as character no-undo .
define variable start         as logical   no-undo init yes.
&scoped-define PLUS-docs 'ie,re,rs,vt,im':U
DEFINE FRAME GdsF
for-cli-name               column-label "Контрагент"              FORMAT "X(28)"
temp-goods.gds-code        column-label "Код товара"              FORMAT ">>>>>>>>9"
temp-goods.artic           column-label "Артикул"                 FORMAT "X(16)"
for-prod-name              column-label "Производитель"           FORMAT "X(25)"
temp-goods.gds-name        column-label "Наименование"            FORMAT "X(25)"
temp-goods.unit-base       column-label "Ед.!изм"                 FORMAT "X(3)"
temp-goods.qnty            column-label "Кол-во"                  FORMAT "->>>,>>>,>>9.999"
temp-goods.sum-uch         column-label "Сумма уч.цен"            FORMAT "->>>,>>>,>>>,>>9.99"
temp-goods.sum-uch-without column-label "Сумма уч.цен!без НДС"    FORMAT "->>>,>>>,>>>,>>9.99"
temp-goods.sum-doc         column-label "Сумма в ценах!документа" FORMAT "->>>,>>>,>>>,>>9.99"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER ( PrnLibStream)
             AT 125 FORMAT ">>9" SKIP
            Line format "X(189)" AT 1
with width {&DOS_CW_2}  down stream-io use-text.

DEFINE FRAME GdsF-tov
temp-goods.gds-name        column-label "Наименование"            FORMAT "X(25)"
temp-goods.gds-code        column-label "Код товара"              FORMAT ">>>>>>>>9"
temp-goods.artic           column-label "Артикул"                 FORMAT "X(16)"
for-prod-name              column-label "Производитель"           FORMAT "X(25)"
for-cli-name               column-label "Контрагент"              FORMAT "X(28)"
temp-goods.unit-base       column-label "Ед.!изм"                 FORMAT "X(3)"
temp-goods.qnty            column-label "Кол-во"                  FORMAT "->>>,>>>,>>9.999"
temp-goods.sum-uch         column-label "Сумма уч.цен"            FORMAT "->>>,>>>,>>>,>>9.99"
temp-goods.sum-uch-without column-label "Сумма уч.цен!без НДС"    FORMAT "->>>,>>>,>>>,>>9.99"
temp-goods.sum-doc         column-label "Сумма в ценах!документа" FORMAT "->>>,>>>,>>>,>>9.99"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER ( PrnLibStream)
             AT 125 FORMAT ">>9" SKIP
            Line format "X(189)" AT 1
with width {&DOS_CW_2}  down stream-io use-text.




run my-var.
run waitfram-show in this-procedure
  (input "Ждите..."
  ).
FIND obj-list No-LOCK NO-ERROR.


IF objects = 2 then multi-obj = no.
else multi-obj = yes.
FOR EACH temp-goods:
  delete temp-goods.
end.


if avail t-doc then
trid = recid(t-doc).

DO WHILE available t-doc :
    GET prev br-docs.
END.
_docs:
DO WHILE available t-doc or start:
  GET next br-docs.
  start = no.
  /*фильтр по объектам*/
  IF NOT CAN-FIND(FIRST obj-list No-LOCK WHERE
                        obj-list.obj-type = t-doc.obj-type AND
                        obj-list.obj-code = t-doc.obj-code) THEN NEXT _docs.
  /*период*/
  CASE X-radio-task:
    when 1 then do:
      if (t-doc.fact-date = ? and
         (t-doc.doc-date < X-date-start OR
         t-doc.doc-date > X-date-end)) 
         or (t-doc.fact-date <> ? and  t-doc.fact-date < X-date-start OR
         t-doc.fact-date > X-date-end) then NEXT _docs.
    end.
    when 2 then do:
      if t-doc.shift-date = ? OR
         t-doc.shift-date < X-date-start OR
         t-doc.shift-date > X-date-end then NEXT _docs.
    end.
    when 3 then do:
      if t-doc.shift-date = ? or t-doc.shift-num = ?
        then NEXT _docs.
      if t-doc.shift-date < X-date-start OR
         t-doc.shift-date > X-date-end then NEXT _docs.
      if t-doc.shift-num < X-shift-start OR
         t-doc.shift-num > X-shift-end
        then NEXT _docs.
    end.
    when 4 then do:
      if t-doc.shift-date = ? or t-doc.shift-num = ?
        then NEXT _docs.
      if t-doc.shift-date < X-date-start OR
         t-doc.shift-date > X-date-end then NEXT _docs.
      if t-doc.shift-num <> X-shift-Alone then NEXT _docs.
    end.
  END CASE.
  /*фильтр по контрагентам*/
  IF RS-CLI = "selective":U AND
     NOT CAN-FIND(first t-cli No-LOCK WHERE
                        t-cli.obj-type = t-doc.cli-type AND
                        t-cli.obj-code = t-doc.cli-code) then NEXT _docs.

  sign = if lookup(t-doc.ext-doc-type, {&Plus-docs}) > 0 then 1 else -1.
  _doc-line:
  FOR EACH ub.doc-line NO-LOCK where
            ub.doc-line.doc-code = t-doc.doc-code:
    /*фильтр по товарам*/
    iF X-SelectGOod = {&g-choice} AND
       NOT CAN-FIND(FIRST gds-list No-LOCK WHERE
                          gds-list.artic = ub.doc-line.artic AND
                          gds-list.prod-type = ub.doc-line.prod-type AND
                          gds-list.prod-code = ub.doc-line.prod-code) then NEXT _doc-line.
    FIND FIRST temp-goods WHERE
               temp-goods.artic     = ub.doc-line.artic AND
               temp-goods.prod-type = ub.doc-line.prod-type AND
               temp-goods.prod-code = ub.doc-line.prod-code AND
               temp-goods.cli-type  = t-doc.cli-type AND
               temp-goods.cli-code  = t-doc.cli-code NO-ERROR.

    IF NOT AVAIL temp-goods then do:
      FIND FIRST ub.goods No-LOCK WHERE
                 ub.goods.artic     = ub.doc-line.artic AND
                 ub.goods.prod-type = ub.doc-line.prod-type AND
                 ub.goods.prod-code = ub.doc-line.prod-code No-ERROR.
      if not avail ub.goods then NEXT _doc-line.
      create temp-goods.
      assign
        temp-goods.artic     = ub.doc-line.artic
        temp-goods.prod-type = ub.doc-line.prod-type
        temp-goods.prod-code = ub.doc-line.prod-code
        temp-goods.cli-type  = t-doc.cli-type
        temp-goods.cli-code  = t-doc.cli-code
        temp-goods.gds-code  = ub.goods.gds-code
        temp-goods.gds-name  = ub.goods.gds-name
        temp-goods.unit-base = ub.goods.unit-base
      .
    end.
    { str/in-vatp.i  calc ub.doc-line. t-doc. }
    { str/out-vatp.i calc ub.doc-line. t-doc. }
    assign
      cur-qnty           = ub.doc-line.fact-qnty * sign
      temp-goods.qnty    = temp-goods.qnty + cur-qnty
      temp-goods.sum-uch = temp-goods.sum-uch + (cur-qnty * price-base-with-tax-loc)
      temp-goods.sum-uch-without = temp-goods.sum-uch-without + cur-qnty * (price-base-without-tax-loc + road-tax-base-loc)
      temp-goods.sum-doc = temp-goods.sum-doc + (cur-qnty * price-base-with-tax-sale )
    .
  END.
END.
if not can-find(first temp-goods No-LOCK) then do:
  message "Не найдено данных,"
          "удовлетворяющих заданным условиям"
  view-as alert-box.
  run waitfram-hide in this-procedure .
  REPOSITION br-docs to recid trid NO-ERROR.
  if error-status:error then trid = ?.
  return.
END.

assign
date_string = cur-time-print()
 LINE = fill("-":U, 189)
 .


run prn-lib-open-stream  in this-procedure (
                                             input my-handle
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


FORM HEADER
Line format "X(189)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2}  PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW STREAM PrnLibStream FRAME BottomFrame .

if rs-sort = yes then do:
  FORM with FRAME GdsF .
end.
else do:
  FORM with FRAME GdsF-tov .
end.


Put Stream PrnLibStream UNFORMATTED
REPORTNAME skip
str1 skip
str2 skip
str3 skip
str-obj
ReportHeader
skip
.

if rs-sort = yes then do :
  FOR EACH temp-goods No-LOCK
    BREAK BY temp-goods.cli-type
          by temp-goods.cli-code
          by temp-goods.gds-code
  :
    IF first-of(temp-goods.cli-code) then do:
      FIND FIRST cli-obj No-LOCK WHERE
                cli-obj.obj-type = temp-goods.cli-type AND
                cli-obj.obj-code = temp-goods.cli-code No-ERROR.
      for-cli-name = (if avail cli-obj then cli-obj.obj-name else (temp-goods.cli-type + string(temp-goods.cli-code))).

    END.
    IF FIRST-of(temp-goods.gds-code) then do:
      FIND FIRST ub.clients No-LOCK WHERE
                ub.clients.obj-type = temp-goods.prod-type AND
                ub.clients.obj-code = temp-goods.prod-code NO-ERROR.
      FIND FIRST ub.goods No-LOCK WHERE
                ub.goods.gds-code = temp-goods.gds-code No-ERROR.
      assign
      FOr-prod-name = (if avail ub.clients then ub.clients.obj-name else (temp-goods.prod-type + string(temp-goods.prod-code)))
      .
    END.

    display stream PrnLibStream
    for-cli-name
    temp-goods.gds-code
    temp-goods.artic
    for-prod-name
    temp-goods.gds-name
    temp-goods.unit-base
    temp-goods.qnty
    temp-goods.sum-uch
    temp-goods.sum-uch-without
    temp-goods.sum-doc
    with frame GdsF
    .
    DOWN STREAM PrnLibStream
    1 with FRAME GdsF .
    ACCUMULATE
    temp-goods.artic (COUNT by temp-goods.cli-code)
    temp-goods.qnty  (TOTAL by temp-goods.cli-code)
    temp-goods.sum-uch (TOTAL by temp-goods.cli-code)
    temp-goods.sum-uch-without (TOTAL  by temp-goods.cli-code)
    temp-goods.sum-doc (TOTAL by temp-goods.cli-code)
    .
    IF LAST-OF(temp-goods.cli-code) then do:
      UNDERLINE stream PrnLibStream
      for-cli-name
      temp-goods.gds-code
      temp-goods.artic
      for-prod-name
      temp-goods.gds-name
      temp-goods.unit-base
      temp-goods.qnty
      temp-goods.sum-uch
      temp-goods.sum-uch-without
      temp-goods.sum-doc
      with frame GdsF
      .
      display stream PrnLibStream
      for-cli-name
      ("ИТОГО " + string(accum count by temp-goods.cli-code temp-goods.artic)) @ temp-goods.artic
      (accum total by temp-goods.cli-code temp-goods.qnty) @ temp-goods.qnty
      (accum total by temp-goods.cli-code temp-goods.sum-uch) @ temp-goods.sum-uch
      (accum total by temp-goods.cli-code temp-goods.sum-uch-without) @ temp-goods.sum-uch-without
      (accum total by temp-goods.cli-code temp-goods.sum-doc) @ temp-goods.sum-doc
      with frame GdsF
      .
      DOWN STREAM PrnLibStream
      2 with FRAME GdsF .
    END.
  END.
  UNDERLINE stream PrnLibStream
  temp-goods.gds-code
  temp-goods.artic
  for-prod-name
  temp-goods.gds-name
  for-cli-name
  temp-goods.qnty
  temp-goods.sum-uch
  temp-goods.sum-uch-without
  temp-goods.sum-doc
  with frame GdsF.

  DISPLAY stream PrnLibStream
  "ИТОГО" @ temp-goods.gds-code
  (accum count temp-goods.artic) @ temp-goods.artic
  accum total temp-goods.qnty @ temp-goods.qnty
  accum total temp-goods.sum-uch @ temp-goods.sum-uch
  accum total temp-goods.sum-uch-without @ temp-goods.sum-uch-without
  accum total temp-goods.sum-doc @ temp-goods.sum-doc
  with frame GdsF.
end.
else do:
  FOR EACH temp-goods No-LOCK
    BREAK
    by temp-goods.gds-name
    by temp-goods.gds-code
  :
    FIND FIRST cli-obj No-LOCK WHERE
              cli-obj.obj-type = temp-goods.cli-type AND
              cli-obj.obj-code = temp-goods.cli-code No-ERROR.
    for-cli-name = (if avail cli-obj then cli-obj.obj-name else (temp-goods.cli-type + string(temp-goods.cli-code))).

    IF FIRST-of(temp-goods.gds-code) then do:
      v-goods-flag = 0.
      FIND FIRST ub.clients No-LOCK WHERE
                 ub.clients.obj-type = temp-goods.prod-type AND
                 ub.clients.obj-code = temp-goods.prod-code NO-ERROR.
      FIND FIRST ub.goods No-LOCK WHERE
                 ub.goods.gds-code = temp-goods.gds-code No-ERROR.
      assign
      for-prod-name = (if avail ub.clients then ub.clients.obj-name else (temp-goods.prod-type + string(temp-goods.prod-code)))
      .
    END.
    v-goods-flag = v-goods-flag + 1.
    display stream PrnLibStream
    for-cli-name
    temp-goods.gds-code
    temp-goods.artic
    for-prod-name
    temp-goods.gds-name
    temp-goods.unit-base
    temp-goods.qnty
    temp-goods.sum-uch
    temp-goods.sum-uch-without
    temp-goods.sum-doc
    with frame GdsF-tov
    .
    DOWN STREAM PrnLibStream
    1 with FRAME GdsF-tov .
    ACCUMULATE
    temp-goods.artic   (COUNT by temp-goods.gds-code)
    temp-goods.qnty    (TOTAL by temp-goods.gds-code)
    temp-goods.sum-uch (TOTAL by temp-goods.gds-code)
    temp-goods.sum-uch-without (TOTAL  by temp-goods.gds-code)
    temp-goods.sum-doc (TOTAL by temp-goods.gds-code)
    .
    IF LAST-OF(temp-goods.gds-code) and v-goods-flag > 1 then do:
      UNDERLINE stream PrnLibStream
      for-cli-name
      temp-goods.gds-code
      temp-goods.artic
      for-prod-name
      temp-goods.gds-name
      temp-goods.unit-base
      temp-goods.qnty
      temp-goods.sum-uch
      temp-goods.sum-uch-without
      temp-goods.sum-doc
      with frame GdsF-tov
      .
      display stream PrnLibStream
      temp-goods.gds-name
      ("ИТОГО " + string(accum count by temp-goods.gds-code temp-goods.artic)) @ temp-goods.artic
      (accum total by temp-goods.gds-code temp-goods.qnty) @ temp-goods.qnty
      (accum total by temp-goods.gds-code temp-goods.sum-uch) @ temp-goods.sum-uch
      (accum total by temp-goods.gds-code temp-goods.sum-uch-without) @ temp-goods.sum-uch-without
      (accum total by temp-goods.gds-code temp-goods.sum-doc) @ temp-goods.sum-doc
      with frame GdsF-tov
      .
      DOWN STREAM PrnLibStream
      2 with FRAME GdsF-tov .
    END.
  END.
  UNDERLINE stream PrnLibStream
  temp-goods.gds-code
  temp-goods.artic
  for-prod-name
  temp-goods.gds-name
  for-cli-name
  temp-goods.qnty
  temp-goods.sum-uch
  temp-goods.sum-uch-without
  temp-goods.sum-doc
  with frame GdsF-tov.

  DISPLAY stream PrnLibStream
  "ИТОГО" @ temp-goods.gds-code
  (accum count temp-goods.artic) @ temp-goods.artic
  accum total temp-goods.qnty    @ temp-goods.qnty
  accum total temp-goods.sum-uch @ temp-goods.sum-uch
  accum total temp-goods.sum-uch-without @ temp-goods.sum-uch-without
  accum total temp-goods.sum-doc @ temp-goods.sum-doc
  with frame GdsF-tov.
end.

HIDE STREAM PrnLibStream FRAME BottomFrame .
output STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input my-handle
                                          ,input 8
                                          ).

REPOSITION br-docs to recid trid NO-ERROR.
if error-status:error then trid = ?.
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
DEFINE VAR StrBuf as char no-undo.
assign  frame {&frame-name} rs-sort.
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

ReportNAme = "Общие количества и суммы по товарам списка документов" + {&new-line} + frame-title.
ReportHeader =
                {&new-line} +
                "Выбор контрагента:" +
               (if Rs-cli = "selective":U
                then ({&new-line} +
                     e-cli:screen-value in frame {&frame-name} )
                else "По всем контрагентам") + {&new-line}
                + "Сортировка:" + (if rs-sort = yes then "По контрагентам" else "По товарам")
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
