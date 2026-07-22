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

Журнал продаж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/01/06
Author: Bakhtadze Natalya
Creation date: 01/01/06

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
define variable vss-description as character no-undo init "Журнал продаж" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i  }
{ cmp/operlist.i }
{ gbl/waitfram.i }


{ rep/e-sj-df.i "NEW SHARED" }

{ rep/e-sjall.i "NEW SHARED" }
{ rep/par-actu.i }
{ rep/par-actu.i proc }

DEFINE VARiable    ii         AS    INTEGER         no-undo.
DEFINE VARiable   sale-list   as character no-undo .
define variable v-frame-width as integer no-undo .
define variable v-curr-r-b as character no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}
define variable parparentproc as widget-handle no-undo .
{ gbl/getcntxt.i def }

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
&Scoped-Define ENABLED-OBJECTS RECT-5 RECT-7 RECT-6 RECT-4 RECT-3 ~
RECT-detail RS-by BySalers RS-seller-cashier RS-saleman ByPrice RS-cass
&Scoped-Define DISPLAYED-OBJECTS RS-by Tot_Groups Tot_Producers RS-sort ~
BySalers RS-seller-cashier Only_Tot RS-saleman ByPrice RS-cass

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE Cas-Num AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "N"
     VIEW-AS FILL-IN
     SIZE 4.5 BY 1 NO-UNDO.

DEFINE VARIABLE RS-by AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Без товаров", 0,
"Без классификации", 1,
"Группы товаров/Производитель", 2,
"Производитель/Группы товаров", 3
     SIZE 31.75 BY 3.13 NO-UNDO.

DEFINE VARIABLE RS-cass AS CHARACTER INITIAL "all"
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", "all":U,
"Выборочно", "selective":U
     SIZE 14.75 BY 1.79 NO-UNDO.

DEFINE VARIABLE RS-saleman AS CHARACTER INITIAL "all"
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", "all":U,
"Выборочно", "selective":U
     SIZE 14.75 BY 1.79 NO-UNDO.

DEFINE VARIABLE RS-seller-cashier AS CHARACTER INITIAL "Seller"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Продавцы", "Seller",
"Кассиры", "Cashier"
     SIZE 31.5 BY 1 NO-UNDO.

DEFINE VARIABLE RS-sort AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по коду", "barcode":U,
"по артикулу", "Article":U
     SIZE 16.13 BY 1.63 NO-UNDO.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35.5 BY 3.46.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35.5 BY 3.46.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35.38 BY 11.21.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 33.88 BY 7.17.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 23.38 BY 1.63.

DEFINE RECTANGLE RECT-detail
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35.38 BY 7.58.

DEFINE VARIABLE ByPrice AS LOGICAL INITIAL no
     LABEL "По скидке"
     VIEW-AS TOGGLE-BOX
     SIZE 18.88 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE BySalers AS LOGICAL INITIAL no
     LABEL "По продавцам/По кассирам"
     VIEW-AS TOGGLE-BOX
     SIZE 32.38 BY 1 NO-UNDO.

DEFINE VARIABLE Only_Tot AS LOGICAL INITIAL no
     LABEL "Только итоги"
     VIEW-AS TOGGLE-BOX
     SIZE 18.88 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE T-twounit AS LOGICAL INITIAL no
     LABEL "В двух ед. изм."
     VIEW-AS TOGGLE-BOX
     SIZE 19.63 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE Tot_Groups AS LOGICAL INITIAL no
     LABEL "По группам"
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE Tot_Producers AS LOGICAL INITIAL no
     LABEL "По производителям"
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     RS-by AT ROW 2.71 COL 4.25 NO-LABEL
     Tot_Groups AT ROW 4.71 COL 40.38
     Tot_Producers AT ROW 6.04 COL 40.25
     RS-sort AT ROW 6.88 COL 4.25 NO-LABEL
     BySalers AT ROW 7.33 COL 40.13
     RS-seller-cashier AT ROW 8.5 COL 40 NO-LABEL
     Only_Tot AT ROW 10 COL 40.13
     RS-saleman AT ROW 10.08 COL 4.25 NO-LABEL
     ByPrice AT ROW 11.25 COL 40.13
     T-twounit AT ROW 13 COL 39.88
     RS-cass AT ROW 13.58 COL 4 NO-LABEL
     Cas-Num AT ROW 14.21 COL 28.5 COLON-ALIGNED
     "Сортировка" VIEW-AS TEXT
          SIZE 26.88 BY .92 AT ROW 5.88 COL 4.13
          FGCOLOR 4
     "Кассы" VIEW-AS TEXT
          SIZE 21.38 BY 1 AT ROW 12.58 COL 4
          FGCOLOR 4
     "Продавцы/Кассиры" VIEW-AS TEXT
          SIZE 21.38 BY 1 AT ROW 9.08 COL 4.25
          FGCOLOR 4
     "Детализация" VIEW-AS TEXT
          SIZE 19.25 BY .83 AT ROW 1.42 COL 40
          FGCOLOR 4
     "Итоги" VIEW-AS TEXT
          SIZE 7.88 BY 1 AT ROW 3.29 COL 45.75
          FGCOLOR 4
     "Классификация" VIEW-AS TEXT
          SIZE 27.88 BY 1 AT ROW 1.42 COL 4.25
          FGCOLOR 4
     RECT-5 AT ROW 1.21 COL 38.63
     RECT-7 AT ROW 12.71 COL 38.63
     RECT-6 AT ROW 2.83 COL 39.63
     RECT-4 AT ROW 8.88 COL 2.25
     RECT-3 AT ROW 12.38 COL 2.25
     RECT-detail AT ROW 1.13 COL 2.25
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 73 BY 15.13.


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
         HEIGHT             = 15.13
         WIDTH              = 73.
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
/* SETTINGS FOR FILL-IN Cas-Num IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       Cas-Num:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR TOGGLE-BOX Only_Tot IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR RADIO-SET RS-sort IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX T-twounit IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       T-twounit:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR TOGGLE-BOX Tot_Groups IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX Tot_Producers IN FRAME F-Main
   NO-ENABLE                                                            */
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

&Scoped-define SELF-NAME RS-by
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-by F-Frame-Win
ON VALUE-CHANGED OF RS-by IN FRAME F-Main
DO:
    if lookup( Rs-by:screen-value,
                    "3,1" ) > 0 then
    enable RS-sort with frame {&frame-name}.
    else disable RS-Sort with frame {&frame-name}.

    if lookup( Rs-By:screen-value, "1,0" ) > 0 then do:
        assign
        Tot_Groups = FALSE
        Tot_Producers = FALSE
        ONly_tot = FALSE .
        display Tot_Groups Tot_Producers ONly_tot WITH frame {&frame-name}.
        disable Tot_Groups Tot_Producers ONly_tot WITH frame {&frame-name}.
   end.
   else
   enable Tot_Groups Tot_Producers ONly_tot WITH frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-cass
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-cass F-Frame-Win
ON VALUE-CHANGED OF RS-cass IN FRAME F-Main
DO:
assign RS-Cass.
if RS-cass = "all":U then do:
    assign cas-num = 0.
    display cas-num with frame {&frame-name}.
    disable cas-num with frame {&frame-name}.
    HIDE cas-num in frame {&frame-name}.
end.
else do:
   enable cas-num with frame {&frame-name}.
   display cas-num with frame {&frame-name}.
   apply "entry" to Cas-Num in frame {&frame-name}.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-saleman
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-saleman F-Frame-Win
ON VALUE-CHANGED OF RS-saleman IN FRAME F-Main
DO:
define variable v-seller-code as integer no-undo .
define buffer buf_staff for ub.staff.

assign RS-Saleman .
if RS-Saleman = "selective":U then do:
  sale-list = "" .
  if rs-seller-cashier = "seller" then do:
    run ref/staffs.w (
                   input my-handle
                  ,input "b-sel,b-mark"
                  ,input {&role-seller}
                  ,input (if v-cntxt-db-num = 0 then ? else v-cntxt-db-num)
                  ,input 0
                  ,output sale-list ) .
  end.
  else do:
    run ref/staffs.w (
                    input my-handle
                   ,input "b-sel,b-mark"
                   ,input {&role-cashier}
                   ,input (if v-cntxt-db-num = 0 then ? else v-cntxt-db-num)
                   ,input 0
                   ,output sale-list ) .
  end.
  if sale-list = "" then do:
    assign
    BySalers = FALSE
    sale-list = ""
    Rs-Saleman = "all":U .
    DISPLAY BySalers RS-Saleman with frame {&frame-name} .
  end.
  else do:
    for each sj-salesman:
      delete sj-salesman.
    end.
    assign
    BySalers = TRUE
    .
    DISPLAY BySalers with frame {&frame-name} .
    DO ii = 1 to num-entries( sale-list ) :
      FIND FIRST buf_staff WHERE
            recid( buf_staff ) = integer( entry( ii, sale-list ) ) NO-LOCK .
      create sj-salesman.
      assign
      sj-salesman.seller =   buf_staff.staff-code
      sj-salesman.psn-code = buf_staff.psn-code
      sj-salesman.sal-chr = string(buf_staff.staff-code) + {&delim-par} + string(buf_staff.psn-code)
      .
      release sj-salesman.
    END .
  end.
end.
else do:
  assign
  sale-list = ""
  saleman-num = 0.
  for each sj-salesman:
    delete sj-salesman.
  end.
  DISPLAY BySalers with frame {&frame-name} .
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-seller-cashier
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-seller-cashier F-Frame-Win
ON VALUE-CHANGED OF RS-seller-cashier IN FRAME F-Main
DO:
  ASSIGN
  RS-seller-cashier.
  CASE RS-saleman:
    when "selective" then do:
      assign
      Rs-Saleman = "all":U
      .
      DISPLAY
      RS-Saleman
      with frame {&frame-name} .
    end.
    when "all" then do:
    end.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
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
  DISPLAY RS-by Tot_Groups Tot_Producers RS-sort BySalers RS-seller-cashier
          Only_Tot RS-saleman ByPrice RS-cass
      WITH FRAME F-Main.
  ENABLE RECT-5 RECT-7 RECT-6 RECT-4 RECT-3 RECT-detail RS-by BySalers
         RS-seller-cashier RS-saleman ByPrice RS-cass
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ini-from-selobj F-Frame-Win
PROCEDURE ini-from-selobj :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable num-obj-list as integer no-undo.
CASE X-SelectObject :
    when "текущий" then do:
        enable rs-cass with frame {&frame-name}.
    end.
    when "все" then do:
        assign cas-num  = 0
        rs-cass = "all":U.
        display rs-cass with frame {&frame-name}.
        disable rs-cass with frame {&frame-name}.
        Hide cas-num in frame {&frame-name}.
    end.
    when "выборочно" then do:
        for each obj-list no-lock:
            num-obj-list = num-obj-list + 1.
            if num-obj-list > 1 then leave.
        end.
        if num-obj-list > 1 then do:
        assign cas-num  = 0
        rs-cass = "all":U.
        display rs-cass cas-num with frame {&frame-name}.
        disable rs-cass with frame {&frame-name}.
        Hide cas-num in frame {&frame-name}.
    end.
end.
END CASE.

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
 parparentproc = my-handle.
 { gbl/getcntxt.i get }
  run dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
    run ini-from-selobj in this-procedure .
    run next_enable in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MainProc F-Frame-Win
PROCEDURE MainProc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
run rep/e-sj1.p ( input my-handle, output v-frame-width) no-error.
if error-status:error then return error.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MainProc-t F-Frame-Win
PROCEDURE MainProc-t :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
run rep/e-sj2.p ( input my-handle, output v-frame-width) no-error.
if error-status:error then return error.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MainProc_d F-Frame-Win
PROCEDURE MainProc_d :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 run rep/e-sj3.p ( input my-handle, output v-frame-width) no-error.
 if error-status:error then return error.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MainProc_D-t F-Frame-Win
PROCEDURE MainProc_D-t :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
run rep/e-sj4.p ( input my-handle, output v-frame-width) no-error.
if error-status:error then return error.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Main_Circle F-Frame-Win
PROCEDURE Main_Circle :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
date_string = cur-time-print() .
if cashdesc-num = {&MaxCashNum} then
cash_string = "КАССЫ            :  В С Е.".
else
cash_string = "КАССА            :  " + string(cashdesc-num, ">>>>>9") + ".".
assign
cash_string = cash_string + fill(" ", 31) + "Итоги по группам        :  " +
                       (if grouptot_flag then "ДА." else "НЕТ.")
sale_string = string("Продавцы: " + rs-saleman-str + " "  + saleman-str , "x(57)" )  +
"Итоги по производителям :  " + ( if prodtot_flag then "ДА." else "НЕТ." ).

run waitfram-show in this-procedure ( input "Подождите ..." ).


run rep/e-sj-cr.p (
                input this-procedure
                ,input v-curr-r-b
                ,input X-date-start
                ,input X-date-end
                ,input X-shift-start
                ,input X-shift-end
                ,input X-shift-Alone
                ,input X-selectGood
                ,input X-Radio-Task
                ,input rs-seller-cashier
                ,input BySalers
                ,input t-twounit
                ,input ", обработано чеков :"
                ,input (X-Radio-Task > 1)
                ,input (if cashdesc-num = {&MaxCashNum}
                       then -1
                       else cashdesc-num)
                )
            .
run waitfram-hide in this-procedure .

Line = fill("-", 250).

if v-curr-r-b = {&r-b-base} then do:
  if my-Set_Val_Type = {&v-all} or t-twounit then do:
    run prn-lib-open-stream  in this-procedure (
                                                input my-handle
                                                ,input {&LS_PS_A4}
                                                ,input yes /*p-is-stream*/
                                                ,input no /*p-append*/
                                                ).
  end.
  else do:
    run prn-lib-open-stream  in this-procedure (
                                                input my-handle
                                                ,input {&CS_PS}
                                                ,input yes /*p-is-stream*/
                                                ,input no /*p-append*/
                                                ).
  end.
end.
else do:
  if  t-twounit then do:
      run prn-lib-open-stream  in this-procedure (
                                                  input my-handle
                                                  ,input {&LS_PS_A4}
                                                  ,input yes /*p-is-stream*/
                                                  ,input no /*p-append*/
                                                  ).
  end.
  else do:
    run prn-lib-open-stream  in this-procedure (
                                                input my-handle
                                                ,input {&CS_PS}
                                                ,input yes /*p-is-stream*/
                                                ,input no /*p-append*/
                                                ).
  end.
end.

run value(if t-twounit then "MainProc-t" else "MainProc").

output STREAM PrnLibStream CLOSE.

OneLinePrinted = False .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Main_Circle_d F-Frame-Win
PROCEDURE Main_Circle_d :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

date_string = cur-time-print() .
if cashdesc-num = {&MaxCashNum} then
cash_string = "КАССЫ            :  В С Е.".
else
cash_string = "КАССА            :  " + string(cashdesc-num, ">>>>>9") + ".".
assign
cash_string = cash_string + fill(" ", 31) + "Итоги по группам        :  " +
              (if grouptot_flag then "ДА." else "НЕТ.")
sale_string = string("Продавцы: " + rs-saleman-str + " "  + saleman-str , "x(57)" ) +
"Итоги по производителям :  " + ( if prodtot_flag then "ДА." else "НЕТ." ).

run waitfram-show in this-procedure (  input "Подождите ..." ).
run rep/e-sj-crd.p (
                input this-procedure
                ,input v-curr-r-b
                ,input X-date-start
                ,input X-date-end
                ,input X-shift-start
                ,input X-shift-end
                ,input X-shift-Alone
                ,input X-selectGood
                ,input X-Radio-Task
                ,input rs-seller-cashier
                ,input BySalers
                ,input t-twounit
                ,input ", обработано чеков :"
                ,input (X-Radio-Task > 1)
                ,input (if cashdesc-num = {&MaxCashNum}
                       then -1
                       else cashdesc-num)
                )
    .
run waitfram-hide in this-procedure .

Line = fill("-", 250).

run prn-lib-open-stream  in this-procedure (
                                             input my-handle
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


run value(if t-twounit then "MainProc_D-t" else "MainProc_D").


output STREAM PrnLibStream CLOSE.

OneLinePrinted = False .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-report F-Frame-Win
PROCEDURE My-report :
Run My-var in this-procedure .

FOR EACH sj-goods :
    delete sj-goods .
END .
FOR EACH sj-adv :
    delete sj-adv .
END .
FOR EACH sj-tots :
    delete sj-tots .
END .
FOR EACH sj-grp :
    delete sj-grp .
END .


if ByPrice then run Main_Circle_d in this-procedure .
else
run Main_Circle in this-procedure .
/*
assign
g#rep-tblname = ""
g#rep-tblrid = -116
g#rep-updflds = "Журнал продаж|" + str1.
*/
if v-frame-width <= {&A4_LS} then do:
  run prn-lib-prn-file in this-procedure ( input my-handle, input (if v-frame-width <= {&A4_CW0} then 0 else 8)) .
end.
else do:
  run prn-lib-prn-file in this-procedure ( input my-handle, input (if v-frame-width <= {&DOS_CW_2} then 9 else 20)) .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-var F-Frame-Win
PROCEDURE My-var :
assign
frame {&frame-name} Rs-Sort
frame {&frame-name} Rs-By
frame {&frame-name} Rs-Cass
frame {&frame-name} Cas-num
frame {&frame-name} Rs-Saleman
frame {&frame-name} ByPrice
frame {&frame-name} BySalers
frame {&frame-name} Only_Tot
frame {&frame-name} Tot_Groups
frame {&frame-name} Tot_Producers
frame {&frame-name} T-twounit
frame {&frame-name} RS-seller-cashier
.
assign
cashdesc-num = if RS-Cass:screen-value = "all":U
               then {&MaxCashNum} else integer(Cas-Num:screen-value)
prodtot_flag = ( if ( Tot_Producers:screen-value = "yes" AND
                      Tot_Producers:sensitive = yes ) then TRUE else FALSE )
grouptot_flag = ( if ( Tot_Groups:screen-value = "yes" AND
                       Tot_Groups:sensitive = yes ) then TRUE else FALSE )
.
assign
ShBySAlers = BySAlers
Shrs-seller-cashier = rs-seller-cashier
SHRs-BY = RS-BY
SHt-twounit = t-twounit
SHRS-SOrt = RS-SOrt
SHOnly_tot = Only_Tot
.
if RS-Saleman = "all":U then
saleman-num = {&MaxSalemanNum} .
else do:
  assign
  saleman-num = - 1.
  saleman-str
  .
  for each sj-salesman:
    if saleman-num >= 0 then do:
      saleman-num = -1 .
      leave.
    end.
    assign
    saleman-num = sj-salesman.seller
    saleman-str = saleman-str + (if saleman-str = '':u then '':U else {&comma-char}) + string(sj-salesman.seller)
    .
  end.
end.

assign
my-Set_val_TYPE = if x-SET_val_TYPE = 0 then {&v-base} else x-SET_val_TYPE.
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
assign
/* ReportNAme = "Журнал продаж" */
Rs-sort-str =  radio-label(string(rs-sort), rs-sort:radio-buttons)
Rs-by-str =   radio-label(string(rs-by), rs-by:radio-buttons)
Rs-cass-str = radio-label(string(rs-cass), rs-cass:radio-buttons)
cas-num-str =   (IF cas-num > 0 then ("Касса N: " + String(cas-num)) else "")
rs-saleman-str = radio-label(string(rs-saleman), rs-saleman:radio-buttons)
saleman-str =   (IF saleman-num > 0 and saleman-num < {&MaxSalemanNum}
                 then ((if rs-seller-cashier = "seller"
                        then "Продавец N: "
                        else "Кассир   N: ") + String(saleman-num))

                 else "")
ReportHeader =  "Классификация: " + rs-by-str + {&new-line} +
                (if Rs-sort:sensitive in frame {&frame-name}
                 then
                 ("Сортировка: " + Rs-sort-str)
                 else ""
                 ) + {&new-line} +
                  "Кассы: " + rs-cass-str  + {&new-line} +
                cas-num-str + {&new-line} +
                (if rs-seller-cashier = "seller"
                 then "Продавцы: "
                 else "Кассиры") +
                 rs-saleman-str + {&new-line} +
                saleman-str + {&new-line} +
                (if Only_tot
                 then ("Только итоги"  + {&new-line})
                 else "") +
                 (if ByPrice OR BySalers OR Tot_Groups OR Tot_Producers
                 then ("Итоги: " +
                       (if ByPrice then (Byprice:label + " ") else "") +
                       (if BySalers
                        then ((IF rs-seller-cashier = "seller"
                              THEN ENTRY(1, BySalers:label, {&slash-char})
                              ELSE ENTRY(2, BySalers:label, {&slash-char}))
                                         + " ")
                        else "") +
                       (if Tot_groups then (Tot_Groups:label + " ") else "") +
                       (if Tot_Producers then (Tot_Producers:label + " ") else "")
                      )
                 else ""
                ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE NExt_enable F-Frame-Win
PROCEDURE NExt_enable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if LOOKUP({&twounit}, call-point) > 0 then do:
    assign
    t-twounit = yes.
    DISPLAY
    t-twounit with frame {&frame-name}.
    ENABLE
    t-twounit with frame {&frame-name}.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE report-to-ach F-Frame-Win
PROCEDURE report-to-ach :
/* -----------------------------------------------------------
  Purpose: Для выгрузки параметров в ACTUETE
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :
 DEFINE INPUT-OUTPUT  PARAMETER TABLE FOR param-to-export .

  for each  param-to-export : delete  param-to-export. end.
 { rep/par-std.i }

{ rep/par-actu.i run-proc
 "'rs-sort'                           "
 "''                                  "
 "'character'                         "
 "Rs-Sort:screen-value in frame {&frame-name} "
 "'сортировка'"
 }

{ rep/par-actu.i run-proc
 "'rs-by'                           "
 "''                                  "
 "'character'                         "
 "lc( radio-label(string(rs-by), rs-by:radio-buttons in frame {&frame-name}))"
 "'классификация'"
 }
{ rep/par-actu.i run-proc
 "'rs-saleman'                           "
 "''                                  "
 "'character'                         "
 "Rs-Saleman:screen-value in frame {&frame-name} "
 "'выбор прадовцов'"
 }

{ rep/par-actu.i run-proc
 "'rs-cass'                           "
 "''                                  "
 "'character'                         "
 "Rs-cass:screen-value in frame {&frame-name} "
 "'выбор касс'"
 }
{ rep/par-actu.i run-proc
 "'cas-num'                           "
 "''                                  "
 "'integer'                           "
 "cas-num:screen-value in frame {&frame-name} "
 "'номер кассы'"
 }
{ rep/par-actu.i run-proc
 "'tot_groups'                           "
 "''                             "
 "'logical'                      "
 "string(Tot_Groups,'yes/no')            "
 "Tot_Groups:label in frame {&frame-name}"
 }

{ rep/par-actu.i run-proc
 "'tot_producers'                           "
 "''                             "
 "'logical'                      "
 "string(Tot_Producers,'yes/no')            "
 "Tot_Producers:label in frame {&frame-name}"
 }

{ rep/par-actu.i run-proc
 "'by_salers'                           "
 "''                             "
 "'logical'                      "
 "string(BySalers,'yes/no')            "
 "BySalers:label in frame {&frame-name}"
 }

{ rep/par-actu.i run-proc
 "'only_tot'                           "
 "''                             "
 "'logical'                      "
 "string(Only_Tot,'yes/no')            "
 "Only_Tot:label in frame {&frame-name}"
 }


{ rep/par-actu.i run-proc
 "'by_price'                           "
 "''                             "
 "'logical'                      "
 "string(ByPrice,'yes/no')            "
 "ByPrice:label in frame {&frame-name}"
 }

{ rep/par-actu.i run-proc
 "'t-twounit'                           "
 "''                             "
 "'logical'                      "
 "string(T-twounit,'yes/no')            "
 "T-twounit:label in frame {&frame-name}"
 }

  end.  /* do */

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
  CASE p-state:
    WHEN "link-changed" then do:
        run ini-from-selobj in this-procedure .
    end.
  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME