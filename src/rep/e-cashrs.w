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

Статистика по кассирам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/05/06
Author: Bakhtadze Natalya
Creation date: 04/05/06

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
define variable vss-description as character no-undo init "Статистика по кассирам" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/cur-time.i }
{ cmp/r-page1.i  }
{ gbl/prn-lib.i  }
{ cmp/r-pril.i new }
{ cmp/operlist.i }
{ gbl/waitfram.i }
{ gbl/gbclcode.i }
{ gbl/getcntxt.i def }

define temp-table tt-cshr no-undo
field cashier as integer
field psn-code as integer
index pi is unique primary
cashier
psn-code
index ipsn psn-code.

define variable State-source as Widget-Handle.
define variable cash-recids as char no-undo .
define variable cash-nums as char no-undo .
define variable rec-list as char no-undo .
define variable str-buf as char no-undo .

define variable FineDate      as log no-undo .
define variable stat      as log no-undo .
define variable cas-shft as logical no-undo.
define variable cas-num as integer no-undo.
define variable found as logical no-undo.
&global-define  no-benefits    "Не было никакой выручки на выбранных объектах ~
в течение заданного Вами периода времени."

define variable ii as integer no-undo .
define variable obj-amount as integer no-undo .

define buffer cli-obj  for ub.clients .
define buffer b-chk-gds  for ub.chk-gds .

define temp-table cash-stat no-undo
field   obj-attr as char
field   b-code like ub.chk-gds.b-code
field   grp-code like ub.chk-gds.grp-code
field   cashier   like ub.chk-doc.cashier
field   psn-code  like ub.chk-doc.cashier-psn-code
field   qnty        as  decimal
field   sum        as  decimal
field   count        as  integer
field   out   as log
field   ret   as log
index   p1  is primary  b-code obj-attr
index   p2              grp-code obj-attr
index   p3
cashier                ascending
psn-code               ascending
obj-attr               ascending
b-code                 descending
grp-code               ascending
    .

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
&Scoped-Define ENABLED-OBJECTS RECT-totals RECT-cashiers RECT-checks ~
WithCashiers SelectCashiers WithGoods ByOperations WithoutObjects
&Scoped-Define DISPLAYED-OBJECTS WithCashiers SelectCashiers WithGoods ~
ByOperations WithoutObjects

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE ByOperations AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Продажи", 1,
"Возвраты", -1,
"Продажи + возвраты", 0
     SIZE 21.38 BY 3
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE SelectCashiers AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "все", "1",
"Выборочно", "2"
     SIZE 21 BY 1
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE WithCashiers AS LOGICAL INITIAL yes
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Детально", yes,
"Суммарно", no
     SIZE 13.5 BY 2
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE WithGoods AS LOGICAL INITIAL yes
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Потоварно", yes,
"Только итоги", no
     SIZE 15.75 BY 1.71
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE WithoutObjects AS LOGICAL INITIAL yes
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Суммарно", yes,
"Пообъектно", no
     SIZE 14.5 BY 1.71
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE RECTANGLE RECT-cashiers
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 36.5 BY 5.21.

DEFINE RECTANGLE RECT-checks
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 36.5 BY 5.92.

DEFINE RECTANGLE RECT-totals
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 17.75 BY 11.29.

DEFINE VARIABLE ByGoods AS LOGICAL INITIAL yes
     LABEL "Товарные"
     VIEW-AS TOGGLE-BOX
     SIZE 12.13 BY .92
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE BySums AS LOGICAL INITIAL no
     LABEL "Суммовые"
     VIEW-AS TOGGLE-BOX
     SIZE 12.5 BY .92
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     WithCashiers AT ROW 3.79 COL 40 NO-LABEL
     SelectCashiers AT ROW 3.88 COL 5.38 NO-LABEL
     WithGoods AT ROW 7.17 COL 40 NO-LABEL
     ByOperations AT ROW 8.54 COL 2.88 NO-LABEL
     ByGoods AT ROW 8.63 COL 25.13
     BySums AT ROW 9.88 COL 25.25
     WithoutObjects AT ROW 10.29 COL 40 NO-LABEL
     "По объектам :" VIEW-AS TEXT
          SIZE 14.25 BY .92 AT ROW 9.08 COL 39.88
          BGCOLOR 8 FGCOLOR 4
     "Просмотреть операции ( чеки ):" VIEW-AS TEXT
          SIZE 30.25 BY .92 AT ROW 7.17 COL 4
          BGCOLOR 8 FGCOLOR 4
     "По товарам :" VIEW-AS TEXT
          SIZE 13.5 BY .92 AT ROW 6.04 COL 39.88
          BGCOLOR 8 FGCOLOR 4
     "Кассиры :" VIEW-AS TEXT
          SIZE 10.25 BY .92 AT ROW 2.54 COL 5
          BGCOLOR 8 FGCOLOR 4
     "По кассирам :" VIEW-AS TEXT
          SIZE 13.63 BY .92 AT ROW 2.75 COL 39.88
          BGCOLOR 8 FGCOLOR 4
     "Итоги :" VIEW-AS TEXT
          SIZE 8.13 BY .92 AT ROW 1.58 COL 42.25
          BGCOLOR 8 FGCOLOR 4
     RECT-totals AT ROW 1.13 COL 39.13
     RECT-cashiers AT ROW 1.17 COL 1.75
     RECT-checks AT ROW 6.5 COL 1.63
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 56.88 BY 11.83.


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
         HEIGHT             = 11.88
         WIDTH              = 56.88.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB F-Frame-Win
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _run-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW F-Frame-Win
  VISIBLE,,run-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE                                                          */
/* SETTINGS FOR TOGGLE-BOX ByGoods IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       ByGoods:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR TOGGLE-BOX BySums IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       BySums:HIDDEN IN FRAME F-Main           = TRUE.

/* _run-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = ""
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME ByOperations
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ByOperations F-Frame-Win
ON VALUE-CHANGED OF ByOperations IN FRAME F-Main
DO:
    assign ByOperations .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SelectCashiers
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SelectCashiers F-Frame-Win
ON VALUE-CHANGED OF SelectCashiers IN FRAME F-Main
DO:
define buffer buf_staff for ub.staff.
  for each tt-cshr:
   delete tt-cshr.
  end.
  assign SelectCashiers .
  if SelectCashiers = {&all} then do:
    create tt-cshr.
    assign
    tt-cshr.psn-code = - 1
    tt-cshr.cashier = 0
    .
  end.
  else do:
    cash-recids = "" .
    run ref/staffs.w ( input my-handle
                , input "b-sel,b-mark"
                , input {&role-cashier}
                , input (if v-cntxt-db-num = 0 then ? else v-cntxt-db-num)
                , input 0
                , output cash-recids ) .
    if cash-recids = "" then do:
       SelectCashiers = {&all} .
       DISPLAY
       SelectCashiers
       with frame {&frame-name} .
    end.
    else do:
      DO ii = 1 to num-entries( cash-recids ) :
         FIND FIRST buf_staff no-lock WHERE
                      recid( buf_staff ) = integer( entry( ii, cash-recids ) ) .
         find first tt-cshr where
                    tt-cshr.cashier = buf_staff.staff-code
               and  tt-cshr.psn-code = buf_staff.psn-code no-error.
         if not available tt-cshr then do:
            create tt-cshr.
            assign
            tt-cshr.cashier  = buf_staff.staff-code
            tt-cshr.psn-code = buf_staff.psn-code
            .
            release tt-cshr.
            create tt-cshr.
            assign
            tt-cshr.cashier = buf_staff.staff-code
            tt-cshr.psn-code = 0
            .
            release tt-cshr.
         end.
      END .
    end.
  end. /*выьборочно*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME WithCashiers
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL WithCashiers F-Frame-Win
ON VALUE-CHANGED OF WithCashiers IN FRAME F-Main
DO:
    assign WithCashiers .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME WithGoods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL WithGoods F-Frame-Win
ON VALUE-CHANGED OF WithGoods IN FRAME F-Main
DO:
    assign WithGoods .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
{ gbl/getcntxt.i get " " my-handle }
&IF DEFINED(UIB_IS_runNING) <> 0 &THEN
   /* Now enable the interface  if in test mode - otherwise this happens when
      the object is explicitly initialized from its container. */
   run dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

{ rep/e-nobenq.i }

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
  DISPLAY WithCashiers SelectCashiers WithGoods ByOperations WithoutObjects
      WITH FRAME F-Main.
  ENABLE RECT-totals RECT-cashiers RECT-checks WithCashiers SelectCashiers
         WithGoods ByOperations WithoutObjects
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-apply-layout F-Frame-Win
PROCEDURE local-apply-layout :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/
ASSIGN
SelectCashiers:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =  "все" + {&comma-char} + {&all} + {&comma-char} +
                                 "Выборочно" + {&comma-char} + {&obj-currency}.
  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  run dispatch IN THIS-PROCEDURE ( INPUT 'apply-layout':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-Report F-Frame-Win
PROCEDURE My-Report :
define variable acc-qnty-g as decimal no-undo .
define variable acc-sum-g as decimal no-undo .
define variable acc-count-g as integer no-undo .
define variable acc-qnty-b as decimal no-undo .
define variable acc-sum-b as decimal no-undo .
define variable acc-count-b as integer no-undo .
run My-var in this-procedure  .
FOR EACH cash-stat :
  delete cash-stat .
END .
run no-benq in this-procedure ( output found).
if not found then do:
  run waitfram-hide in this-procedure .
  message {&no-benefits} view-as alert-box information .
  return.
end.
FOR EACH obj-list :
  _chk-doc:
  FOR EACH ub.chk-doc WHERE
          ub.chk-doc.obj-type = obj-list.obj-type
    AND  ub.chk-doc.obj-code = obj-list.obj-code
    AND  ub.chk-doc.chk-date >= X-date-start
    AND  ub.chk-doc.chk-date <= X-date-end NO-LOCK :
    if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc.
    if NOT can-do( {&gds-goods_gds-office_amount}, ub.chk-doc.office )  then NEXT _chk-doc.
    if SelectCashiers <> {&all} then do:
      find first tt-cshr no-lock where
                tt-cshr.cashier = ub.chk-doc.cashier
           and  tt-cshr.psn-code = (if ub.chk-doc.cashier-psn-code = ?
                                    then 0
                                    else ub.chk-doc.cashier-psn-code)
                no-error.
       if not available tt-cshr then next _Chk-doc.
    end.
    else do:

    end.
    if chk-doc.netto < 0 then  do:
      if ( ByOperations <> 1 )
      AND can-find( first ub.chk-gds where
                          ub.chk-gds.doc-code = ub.chk-doc.doc-code
                      AND ub.chk-gds.doc-qnty > 0 ) then do:
        str-buf = ub.chk-doc.obj-type + {&space-char} + string( ub.chk-doc.obj-code ) .
        _chk-gds:
        FOR EACH ub.chk-gds WHERE
                  ub.chk-gds.doc-code = ub.chk-doc.doc-code
              AND ub.chk-gds.doc-qnty > 0 NO-LOCK :
          if NOT ( ByGoods AND BySums ) then  do:
            if ByGoods AND ( ub.chk-gds.b-code = 0 ) then NEXT _chk-gds.
            if BySums AND ( ub.chk-gds.grp-code = 0 ) then NEXT _chk-gds.
          end.
          if ub.chk-gds.write-off-code <> ?
          and ub.chk-gds.write-off-code <> 0 then NEXT.
          if ub.chk-gds.grp-code = 0 then do:
            FIND FIRST cash-stat WHERE
                  cash-stat.b-code = ub.chk-gds.b-code
              AND cash-stat.obj-attr = str-buf
              AND cash-stat.cashier = ub.chk-doc.cashier
              AND cash-stat.psn-code = (if ub.chk-doc.cashier-psn-code = ?
                                        then 0
                                        else ub.chk-doc.cashier-psn-code)
              AND cash-stat.ret = TRUE NO-ERROR .
          end.
          else do:
            FIND FIRST cash-stat WHERE
                      cash-stat.grp-code = ub.chk-gds.grp-code
                    AND cash-stat.obj-attr = str-buf
                    AND cash-stat.cashier = ub.chk-doc.cashier
                    AND cash-stat.psn-code = (if ub.chk-doc.cashier-psn-code = ?
                                              then 0
                                              else ub.chk-doc.cashier-psn-code)
                    AND cash-stat.ret = TRUE NO-ERROR .
          end.
          if NOT available cash-stat then do:
            CREATE cash-stat.
            assign
            cash-stat.obj-attr = str-buf
            cash-stat.b-code = ub.chk-gds.b-code
            cash-stat.grp-code = ub.chk-gds.grp-code
            cash-stat.cashier = ub.chk-doc.cashier
            cash-stat.psn-code = (if ub.chk-doc.cashier-psn-code = ?
                                  then 0
                                  else ub.chk-doc.cashier-psn-code)
            cash-stat.out = FALSE
            cash-stat.ret = TRUE
            .
          end.
          assign
          cash-stat.count = cash-stat.count + 1
          cash-stat.qnty = cash-stat.qnty + ub.chk-gds.doc-qnty
          cash-stat.sum = cash-stat.sum + ( ub.chk-gds.price-base - ub.chk-gds.discnt ) * ub.chk-gds.doc-qnty
          .
        END . /*      FOR EACH chk-gds WHERE*/
      end.
    end. /*if chk-doc.netto < 0 then  do:*/
    else do: /* Продажи */
      if ( ByOperations >= 0 )
      AND can-find( first ub.chk-gds where
                           ub.chk-gds.doc-code = ub.chk-doc.doc-code
                       AND ub.chk-gds.doc-qnty < 0 ) then do:
        str-buf = ub.chk-doc.obj-type + {&space-char} + string( ub.chk-doc.obj-code ) .
        _chk-gds2:
        FOR EACH ub.chk-gds WHERE
                ub.chk-gds.doc-code = ub.chk-doc.doc-code
            AND ub.chk-gds.doc-qnty < 0 NO-LOCK :
          if NOT ( ByGoods AND BySums ) then do:
            if ByGoods AND ( ub.chk-gds.b-code = 0 )  then NEXT _chk-gds2.
            if BySums AND ( ub.chk-gds.grp-code = 0 )  then NEXT _chk-gds2.
          end.
          if ub.chk-gds.grp-code = 0 then do:
            FIND FIRST cash-stat WHERE
                      cash-stat.b-code = ub.chk-gds.b-code
                AND cash-stat.obj-attr = str-buf
                AND cash-stat.cashier = ub.chk-doc.cashier
                AND cash-stat.psn-code = (if ub.chk-doc.cashier-psn-code = ?
                                          then 0
                                          else ub.chk-doc.cashier-psn-code)
                AND cash-stat.out = TRUE NO-ERROR .
          end.
          else do:
            FIND FIRST cash-stat WHERE
                      cash-stat.grp-code = ub.chk-gds.grp-code
                  AND cash-stat.obj-attr = str-buf
                  AND cash-stat.cashier = ub.chk-doc.cashier
                  AND cash-stat.psn-code = (if ub.chk-doc.cashier-psn-code = ?
                                            then 0
                                            else ub.chk-doc.cashier-psn-code)
                  AND cash-stat.out = TRUE NO-ERROR .
          end.
          if NOT available cash-stat then do:
            CREATE cash-stat.
            assign
            cash-stat.obj-attr = str-buf
            cash-stat.b-code = ub.chk-gds.b-code
            cash-stat.grp-code = ub.chk-gds.grp-code
            cash-stat.cashier = ub.chk-doc.cashier
            cash-stat.psn-code = (if ub.chk-doc.cashier-psn-code = ?
                                  then 0
                                  else ub.chk-doc.cashier-psn-code)
            cash-stat.out = TRUE
            cash-stat.ret = FALSE
            .
          end.
          assign
          cash-stat.count = cash-stat.count + 1
          cash-stat.qnty = cash-stat.qnty + ub.chk-gds.doc-qnty
          cash-stat.sum = cash-stat.sum + ( ub.chk-gds.price-base - ub.chk-gds.discnt ) * ub.chk-gds.doc-qnty
          .
        END . /*FOR EACH chk-gds WHERE*/
      end.
    end. /*do: /* Продажи */*/
  END .
  assign
  obj-amount = obj-amount + 1.
END . /*ACCUMULATE obj-list.obj-code ( COUNT ) .*/
if WithoutObjects then do:
  if obj-amount > 1 then do:
    if BySums then do:
      FOR EACH cash-stat WHERE
              cash-stat.b-code = 0 /* суммовые */
      BREAK
      BY cash-stat.out
      BY cash-stat.cashier
      BY cash-stat.psn-code
      BY cash-stat.grp-code :
        if first-of (cash-stat.grp-code) then do:
          assign
          acc-qnty-g = 0
          acc-sum-g = 0
          acc-count-g = 0
          .
        end.
        assign
        acc-qnty-g = acc-qnty-g + cash-stat.qnty
        acc-sum-g = acc-sum-g + cash-stat.sum
        acc-count-g = acc-count-g + 1
        .
        if last-of( cash-stat.grp-code ) then do:
          assign
          cash-stat.obj-attr = ""
          cash-stat.count = acc-count-g
          cash-stat.sum = acc-sum-g
          cash-stat.qnty = acc-qnty-g
          .
        end.
        else delete cash-stat .
      END . /*for each cash-stat*/
    end. /*if BySums then do:*/
    if ByGoods then do:
      FOR EACH cash-stat WHERE
              cash-stat.grp-code = 0 /* товарные */
      BREAK
      BY cash-stat.out
      BY cash-stat.cashier
      BY cash-stat.psn-code
      BY cash-stat.b-code :
        if first-of(cash-stat.b-code) then do:
          assign
          acc-qnty-b = 0
          acc-sum-b= 0
          acc-count-b = 0
          .
        end.
        assign
        acc-qnty-b = acc-qnty-b + cash-stat.qnty
        acc-sum-b = acc-sum-b + cash-stat.sum
        acc-count-b = acc-count-b + 1
        .
        if last-of( cash-stat.b-code ) then do:
          assign
          cash-stat.obj-attr = ""
          cash-stat.count = acc-count-b
          cash-stat.sum = acc-sum-b
          cash-stat.qnty = acc-qnty-b
          .
        end.
        else delete cash-stat .
      END . /*FOR EACH cash-stat WHERE */
    end. /*if ByGoods then do:*/
  end. /*if obj-amount > 1 then do:*/
end. /*if WithoutObjects then do:*/
if ByOperations = 0 then do:
  if BySums then do:
    FOR EACH cash-stat WHERE
           cash-stat.b-code = 0 /* суммовые */
    BREAK
    BY cash-stat.obj-attr
    BY cash-stat.cashier
    BY cash-stat.psn-code
    BY cash-stat.grp-code :
      if first-of (cash-stat.grp-code) then do:
        assign
        acc-qnty-g = 0
        acc-sum-g = 0
        acc-count-g = 0
        .
      end.
      assign
      acc-qnty-g = acc-qnty-g + cash-stat.qnty
      acc-sum-g = acc-sum-g + cash-stat.sum
      acc-count-g = acc-count-g + 1
      .
      if last-of( cash-stat.grp-code ) then do:
        assign
        cash-stat.out = TRUE
        cash-stat.ret = TRUE
        cash-stat.count = acc-qnty-g
        cash-stat.sum = acc-sum-g
        cash-stat.qnty = acc-count-g
        .
      end.
      else delete cash-stat .
    END . /*FOR EACH cash-stat WHERE */
  end. /*if BySums then do:*/
  if ByGoods then do:
      FOR EACH cash-stat WHERE
             cash-stat.grp-code = 0 /* товарные */
      BREAK
      BY cash-stat.obj-attr
      BY cash-stat.cashier
      BY cash-stat.b-code :
        if first-of(cash-stat.b-code) then do:
          assign
          acc-qnty-b = 0
          acc-sum-b= 0
          acc-count-b = 0
          .
        end.
        assign
        acc-qnty-b = acc-qnty-b + cash-stat.qnty
        acc-sum-b = acc-sum-b + cash-stat.sum
        acc-count-b = acc-count-b + 1
        .
        if last-of( cash-stat.b-code ) then do:
          assign
          cash-stat.out = TRUE
          cash-stat.ret = TRUE
          cash-stat.count = acc-count-b
          cash-stat.sum = acc-sum-b
          cash-stat.qnty = acc-qnty-b
          .
        end.
        else delete cash-stat .
      END . /*FOR EACH cash-stat WHERE */
     end. /*if ByGoods then do:*/
 end. /*if byoperationr*/
 if NOT WithCashiers then do:
   if BySums then do:
      FOR EACH cash-stat WHERE
             cash-stat.b-code = 0 /* суммовые */
      BREAK
      BY cash-stat.obj-attr
      BY cash-stat.out
      BY cash-stat.grp-code :
        if first-of (cash-stat.grp-code) then do:
          assign
          acc-qnty-g = 0
          acc-sum-g = 0
          acc-count-g = 0
          .
        end.
        assign
        acc-qnty-g = acc-qnty-g + cash-stat.qnty
        acc-sum-g = acc-sum-g + cash-stat.sum
        acc-count-g = acc-count-g + 1
        .
        if last-of( cash-stat.grp-code ) then do:
          assign
          cash-stat.cashier = 0
          cash-stat.count = acc-qnty-g
          cash-stat.sum = acc-sum-g
          cash-stat.qnty = acc-count-g
          .
        end.
        else delete cash-stat .
     END . /*FOR EACH cash-stat WHERE */
   end. /*if BySums then do:*/
   if ByGoods then do:
      FOR EACH cash-stat WHERE
           cash-stat.grp-code = 0 /* товарные */
      BREAK
      BY cash-stat.obj-attr
      BY cash-stat.out
      BY cash-stat.b-code :
        if first-of(cash-stat.b-code) then do:
          assign
          acc-qnty-b = 0
          acc-sum-b= 0
          acc-count-b = 0
          .
        end.
        assign
        acc-qnty-b = acc-qnty-b + cash-stat.qnty
        acc-sum-b = acc-sum-b + cash-stat.sum
        acc-count-b = acc-count-b + 1
        .
        if last-of( cash-stat.b-code ) then do:
          assign
          cash-stat.cashier = 0
          cash-stat.count = acc-count-b
          cash-stat.sum = acc-sum-b
          cash-stat.qnty = acc-qnty-b
          .
        end.
       else delete cash-stat .
     end. /*FOR EACH cash-stat WHERE */
   END . /*if ByGoods then do:*/
end. /*if NOT WithCashiers then do:*/
if can-find( first cash-stat ) then do:
  run PrintProc in this-procedure .
end.
else
message
"Отчет по отмененным/аннулированым строкам чеков" skip
"ПУСТ при выбранных Вами параметрах."
view-as alert-box INFORMATION .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-var F-Frame-Win
PROCEDURE My-var :
 assign
 FRAME {&frame-name} SelectCashiers
 FRAME {&frame-name} ByGoods
 FRAME {&frame-name} BySums
 FRAME {&frame-name} ByOperations
 FRAME {&frame-name} WithoutObjects
 FRAME {&frame-name} WithCashiers
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
ReportNAme = "Статистика по кассирам".
ReportHeader =
               "Кассиры : " +
               radio-label(string(SelectCashiers), SelectCashiers:radio-buttons) + {&new-line} +
               "Операции : " + (if ByOperations = 0
                                then "Продажи + возвраты"
                                else if ByOperations = 1
                                     then "Продажи"
                                     else "Возвраты" ) + ", " +
               (if ByGoods then "Товарные" else "" ) +
               (if BySums then " Суммовые" else "" ) + {&new-line} +
               "Итоги по объектам : " +
               radio-label(string(WithoutObjects), WithoutObjects:radio-buttons) + {&new-line} +
               "Итоги по кассирам : " +
               radio-label(string(WithCashiers), WithCashiers:radio-buttons) + {&new-line} +
               "Итоги по товарам  : " +
              radio-label(string(WithGoods), WithGoods:radio-buttons)
               .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrintProc F-Frame-Win
PROCEDURE PrintProc :
define variable sym1 as char init ":"   no-undo.
define variable sym2 as char init ":"   no-undo.
define variable sym3 as char init ":"   no-undo.
define variable sym4 as char init ":"   no-undo.
define variable sym5 as char init ":"   no-undo.
define variable sym6 as char init ":"   no-undo.
define variable sym7 as char init ":"   no-undo.
define variable sym8 as char init ":"   no-undo.
define variable sym9 as char init ":"   no-undo.
define variable acc-qnty-0 as decimal no-undo .
define variable acc-sum-0 as decimal no-undo .
define variable acc-count-0 as integer no-undo .
define variable acc-qnty-o as decimal no-undo .
define variable acc-sum-o as decimal no-undo .
define variable acc-count-o as integer no-undo .
define variable acc-qnty-p as decimal no-undo .
define variable acc-sum-p as decimal no-undo .
define variable acc-count-p as integer no-undo .


define variable Line as char no-undo.
define variable CashierName as char no-undo.
define variable G-Artic as char no-undo.
define variable v-header-base-curr as character no-undo .
define variable v-curr-r-b as character no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}
if v-curr-r-b = {&r-b-base} then do:
  assign
  v-header-base-curr =  "( Баз.Вал. ) "
  .
end.


DEFINE FRAME F1
sym1 column-label ":!:" format "X(1)"
cash-stat.cashier column-label "Код!кассира" format ">>>>>9"
cash-stat.psn-code column-label "Код!чел" format ">>>>>>>>9"
CashierName column-label "Имя !кассира" format "x(25)"
cash-stat.obj-attr column-label "Объект!(тип код)" format "X(10)"
sym3 column-label ":!:" format "X(1)"
cash-stat.b-code column-label "Код товара /!   группы" format ">>>>>>>>>>>>9"
sym9 column-label ":!:" format "X(1)"
G-Artic column-label "Артикул!товара" format "X(16)"
sym4 column-label ":!:" format "X(1)"
cash-stat.qnty column-label "Кол-во товаров! " format "->>>,>>>,>>9.<<<"
sym5 column-label ":!:" format "X(1)"
cash-stat.sum column-label "Сумма в Б.Вал.! " format "->>>,>>>,>>>,>>9.99"
sym6 column-label ":!:" format "X(1)"
cash-stat.count column-label "Всего!строк" format "->>>>>>>>>9"
sym7 column-label ":!:" format "X(1)"
HEADER
cur-time-print() AT 5 format "X(35)"
v-header-base-curr        format "X(20)" AT 42
"Страница " AT 100 PAGE-NUMBER( PrnLibStream ) AT 115 format ">>9" SKIP
Line format "X(136)" AT 1
with width {&A4_CW} down stream-io use-text .


Line = fill( "-", 170 ).
run prn-lib-open-stream  in this-procedure (
                                             input my-handle
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


FORM HEADER
Line format "X(136)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW stream PrnLibStream FRAME BottomFrame .


PUT stream PrnLibStream space(20)
( "Статистика по кассирам " + str1) format "X(100)" skip(2)
space(10) "По объектам : " format "X(14)" .

FOR EACH obj-list :
  FIND FIRST cli-obj WHERE
           cli-obj.obj-type = obj-list.obj-type
       AND cli-obj.obj-code = obj-list.obj-code NO-LOCK .
  PUT stream PrnLibStream
  string( obj-list.obj-type + " " + string( obj-list.obj-code ) +
      " (" + trim( cli-obj.obj-name ) + ")" ) format "x(90)" skip space(24) .
END.
PUT stream PrnLibStream " " skip .

PUT stream PrnLibStream unformatted
ReportHeader skip(0)
.
FOR EACH cash-stat use-index p3
BREAK
BY cash-stat.cashier
BY cash-stat.psn-code
BY cash-stat.obj-attr
BY cash-stat.out
BY cash-stat.b-code
BY cash-stat.grp-code with FRAME F1 :
  if first-of( cash-stat.obj-attr) then do:
    assign
    acc-qnty-o = 0
    acc-sum-o = 0
    acc-count-o = 0
    .
  end.
  if first-of( cash-stat.psn-code) then do:
    assign
    acc-qnty-p = 0
    acc-sum-p = 0
    acc-count-p = 0
    .
  end.
  assign
  acc-qnty-o = acc-qnty-o + cash-stat.qnty
  acc-sum-o  = acc-sum-o + cash-stat.sum
  acc-count-o  = acc-count-o + cash-stat.count
  acc-qnty-p = acc-qnty-p + cash-stat.qnty
  acc-sum-p  = acc-sum-p + cash-stat.sum
  acc-count-p  = acc-count-p + cash-stat.count
  acc-qnty-0 = acc-qnty-0 + cash-stat.qnty
  acc-sum-0 = acc-sum-0 + cash-stat.sum
  acc-count-0  = acc-count-0 + cash-stat.count
  .
  if WithGoods
  AND ( first-of( cash-stat.b-code ) )
  AND ( cash-stat.b-code <> 0 ) then do:
    FIND FIRST ub.bar-code WHERE
              ub.bar-code.b-code = cash-stat.b-code NO-LOCK .
  end.
  if cash-stat.cashier = 0 then do:
    cashiername = "Все кассиры".
  end.
  if first-of( cash-stat.psn-code ) then do:
    if cash-stat.cashier <> 0 then do:
      if cash-stat.psn-code <> 0 then do:
        FIND FIRST ub.clients no-lock WHERE
                  ub.clients.obj-type = {&prs}
              AND ub.clients.obj-code = cash-stat.psn-code  .
        FIND FIRST ub.person no-lock WHERE
                 ub.person.psn-code = ub.clients.obj-code.
        cashiername = substitute("&1 &2", ub.clients.obj-name , ub.person.name1 ).
      end.
      else do:
        cashiername = substitute("КАССИР &1" , cash-stat.cashier).
      end.
    end. /*if cash-stat.cashier <> 0 then do:*/
    if WithGoods then do:
      DISPLAY stream PrnLibStream
      sym1
      cash-stat.cashier WHEN cash-stat.cashier <> 0
      cash-stat.psn-code WHEN cash-stat.cashier <> 0
      CashierName
      (if first-of( cash-stat.obj-attr ) and cash-stat.obj-attr <> ""
        then cash-stat.obj-attr
        else " " )   @ cash-stat.obj-attr
      sym3
      (if cash-stat.b-code = 0
        then cash-stat.grp-code
        else cash-stat.b-code )
      @ cash-stat.b-code
      sym9
      (if cash-stat.b-code = 0 then " " else string(bar-code.gds-code) ) @ G-Artic
      sym4
      cash-stat.qnty
      sym5
      cash-stat.sum
      sym6
      cash-stat.count
      sym7 .
    end. /*if WithGoods then do:*/
  end.  /*if first-of( cash-stat.psn-code ) then do:*/
  else do:
    if WithGoods then do:
      DISPLAY stream PrnLibStream
      sym1
      cash-stat.cashier WHEN cash-stat.cashier <> 0
      cash-stat.psn-code WHEN cash-stat.cashier <> 0
      " " @ CashierName
      (if first-of( cash-stat.obj-attr ) and cash-stat.obj-attr <> ""
      then cash-stat.obj-attr
      else " " )  @ cash-stat.obj-attr
      sym3
      (if cash-stat.b-code = 0
      then cash-stat.grp-code
      else cash-stat.b-code )  @ cash-stat.b-code
      sym9
      (if cash-stat.b-code = 0 then " " else string(bar-code.gds-code)) @ G-Artic
      sym4
      cash-stat.qnty
      sym5
      cash-stat.sum
      sym6
      cash-stat.count
      sym7 .
    end. /*if WithGoods then do:*/
  end.
  if last-of( cash-stat.obj-attr ) and cash-stat.obj-attr <> "" then do:
    if WithGoods then do:
      UNDERLINE stream PrnLibStream
      cash-stat.cashier
      CashierName
      cash-stat.obj-attr
      cash-stat.b-code
      cash-stat.qnty
      cash-stat.sum
      cash-stat.count .
      DISPLAY stream PrnLibStream
      sym1
      "Итого по объекту" @ CashierName
      cash-stat.obj-attr
      acc-qnty-o @ cash-stat.qnty
      acc-sum-o @ cash-stat.sum
      acc-count-o @ cash-stat.count
      sym7 .
    end.
    UNDERLINE stream PrnLibStream
    cash-stat.cashier
    CashierName
    cash-stat.obj-attr
    cash-stat.b-code
    cash-stat.qnty
    cash-stat.sum
    cash-stat.count .
  end.
  if last-of( cash-stat.psn-code )
  and cash-stat.cashier <> 0 then do:
    if WithGoods then do:
      UNDERLINE stream PrnLibStream
      cash-stat.cashier
      CashierName
      cash-stat.obj-attr
      cash-stat.b-code
      cash-stat.qnty
      cash-stat.sum
      cash-stat.count
      .
    end.
    DISPLAY stream PrnLibStream
      sym1
    ( substitute("Итого по кассиру &1", cash-stat.cashier, cash-stat.psn-code) ) @ CashierName
    " " @ cash-stat.obj-attr
    acc-qnty-p @ cash-stat.qnty
    acc-sum-p @ cash-stat.sum
    acc-count-p  @ cash-stat.count
    sym7 .
    UNDERLINE stream PrnLibStream
    cash-stat.cashier
    CashierName
    cash-stat.obj-attr
    cash-stat.b-code
    cash-stat.qnty
    cash-stat.sum
    cash-stat.count .
  end.
  if last( cash-stat.grp-code ) then do:
    UNDERLINE stream PrnLibStream
    cash-stat.cashier
    CashierName
    cash-stat.obj-attr
    cash-stat.b-code
    cash-stat.qnty
    cash-stat.sum
    cash-stat.count .
    DISPLAY stream PrnLibStream
    sym1 "ИТОГО" @ CashierName
    acc-qnty-0 @ cash-stat.qnty
    acc-sum-0 @ cash-stat.sum
    acc-count-0 @ cash-stat.count
    sym7 .
  end. /*if last( cash-stat.grp-code ) then do:*/
END . /*FOR EACH cash-stat use-index p3*/
HIDE stream PrnLibStream FRAME BottomFrame .
PUT stream PrnLibStream Line format "X(136)" skip.
output stream PrnLibStream CLOSE .

run prn-lib-prn-file in this-procedure (
                                          input my-handle
                                          ,input 0
                                          ).

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