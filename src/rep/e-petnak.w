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

Расход нефтепродуктов по документам

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

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Расход нефтепродуктов по документам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/cur-time.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ cmp/operlist.i }
{ rep/rep-bt.i }
{ gbl/waitfram.i }


&global-define  no-benefits    "Не было расхода топлива на выбранных объектах ~
в течение заданного Вами периода времени."
DEFINE {1} SHARED VARIABLE loc#log as LOGICAL NO-UNDO.
DEFINE {1} SHARED VARIABLE loc#db-num as integer NO-UNDO.
DEFINE {1} SHARED VARIABLE loc#host-code as integer NO-UNDO.
DEFINE {1} SHARED VARIABLE loc#store-code as integer NO-UNDO.
def SHARED var shft as logical no-undo init no.
define variable HowBreak as logical no-undo.
define variable sale-price-type as character.
define variable for-netto as decimal no-undo.
define var ii as integer no-undo.
define variable Line                as      char    no-undo.
define variable date_string     as      char    no-undo.
define variable v-header-base-curr as character no-undo .
define variable v-curr-r-b as character no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}
if v-curr-r-b = {&r-b-base} then do:
  assign
  v-header-base-curr = string( "( Б.Вал. - " + caps( base-type ) + " )" )
  .
end.


def temp-table tops no-undo
    Field gds-code like ub.goods.gds-code
    field gds-name like ub.goods.gds-name
    field qnty as decimal format "->>>,>>>,>>9.999"
    field tot-r-b as decimal
    field discnt-r-b as decimal
    field pl-code like ub.place.pl-code
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field doc-code like ub.trn-doc.doc-code
    field doc-type like ub.trn-doc.doc-type FORMAT "X(12)"
    field sale-date as date
    field shift-num as integer
    field shift-name as character
    INDEX pi IS PRIMARY
    obj-type
    obj-code
    gds-code
    doc-code
    pl-code
    sale-date
    shift-num
    .

DEFINE FRAME TopsF
tops.sale-date column-label "Дата " format "99.99.99"
tops.shift-name column-label "Смена" format "X(2)"
tops.gds-code column-label "Код топлива" forMAT ">>>>>>>>>9"
tops.gds-name column-label "Топливо" format "X(25)"
tops.qnty column-label "Кол-во"
tops.tot-r-b column-label "Сумма брутто" format "->>>,>>>,>>9.99"
tops.discnt-r-b column-label "Сумма скидок" format "->>>,>>>,>>9.99"
for-netto column-label "Сумма нетто" format "->>>,>>>,>>9.99"
tops.pl-code column-label "Танк"
tops.doc-code column-label "Док-нт"
tops.doc-type column-label "Тип док."
HEADER  date_string format "X(35)" AT 5
v-header-base-curr        format "X(20)" AT 42
"Страница " AT 65 PAGE-NUMBER( PrnLibStream )  AT 75 FORMAT ">>9" SKIP
Line format "X(82)" AT 1
with width {&DOS_CW_2} down stream-io use-text .

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
&Scoped-Define ENABLED-OBJECTS RS-By
&Scoped-Define DISPLAYED-OBJECTS RS-By

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE RS-By AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Без разбиения по бакам и документам", 0,
"C разбиением по бакам и документам", 1
     SIZE 38.5 BY 1.79 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     RS-By AT ROW 2.79 COL 1 NO-LABEL
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 38.63 BY 11.88.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,Browse,DB-Fields,Smart,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW F-Frame-Win ASSIGN
         HEIGHT             = 11.92
         WIDTH              = 38.75.
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




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
   /* Now enable the interface  if in test mode - otherwise this happens when
      the object is explicitly initialized from its container. */
   RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

/*
assign
loc#db-num = g#db-num
loc#host-code = g#host-code
loc#store-code = store-code
.
*/

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
  DISPLAY RS-By
      WITH FRAME F-Main.
  ENABLE RS-By
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
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
assign
FRAME {&frame-name} RS-BY
.
run My-var.
assign
date_string = cur-time-print()
Line = fill( "-", 140 ).

run waitfram-show in this-procedure ( {&MyWaitMess} ) .
IF RS-By > 0 then HowBreak = YES.
ELSE HowBreak = No.

if v-curr-r-b = {&r-b-base} then do:
  sale-price-type = base-type.
end.
else do:
  sale-price-type = "{&abbr_rubley}".
end.

FOR EACH tops:
    delete tops.
END.

/*форма запроса*/
RUN petnaklq(input X-Radio-Task,
             input shft,
             input X-date-start,
             input X-date-end,
             input X-shift-start,
             input X-shift-end,
             input HowBreak) .

RUN Print-no-break.
if return-value = "error" then return.
/*
assign
g#rep-tblname = ""
g#rep-tblrid = -101
g#rep-updflds = string( "Расход нефтепродуктов по документам|" + str1) .
*/
run prn-lib-prn-file in this-procedure (
                                          input my-handle
                                          ,input 8
                                          ).


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
assign frame {&frame-name}
RS-by.
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
ReportNAme = "Расход нефтепродуктов по документам".
ReportHeader =  radio-label(string(RS-by), RS-by:radio-buttons) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE petnaklq F-Frame-Win
PROCEDURE petnaklq :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*процедура построения временной таблицы tops*/
DEFINE INPUT PARAMETER period-type as integer no-undo.
DEFINE INPUT PARAMETER shft as logical no-undo.
DEFINE INPUT PARAMETER X-date-start as date no-undo.
DEFINE INPUT PARAMETER X-date-end as date no-undo.
DEFINE INPUT PARAMETER X-shift-start as integer no-undo.
DEFINE INPUT PARAMETER X-shift-end as integer no-undo.
DEFINE INPUT PARAMETER HOWBREAK as logical No-undo.

define variable dt like ub.trn-doc.doc-type no-undo.
FOR EACH obj-list NO-LOCK :
    ACCUMULATE obj-list.obj-code ( COUNT ) .
        CASE (Period-Type > 1 and shft):
            WHEN yes then do:
                    FOR EACH ub.trn-doc WHERE ub.trn-doc.obj-type = obj-list.obj-type AND
                                                                ub.trn-doc.obj-code = obj-list.obj-code AND
                                                                ub.trn-doc.internal = no AND
                                                                  ub.trn-doc.status_ = {&fact} AND
                                                                   (
                                                                   ub.trn-doc.shift-date >= X-date-start AND
                                                                   ub.trn-doc.shift-date <= X-date-end)
                                                                  NO-LOCK use-index shift:
                           IF Period-Type = 3 AND
                                ((trn-doc.shift-date = x-date-start AND trn-doc.shift-num < x-shift-start) OR
                                 (trn-doc.shift-date = x-date-end AND  trn-doc.shift-num > x-shift-end) ) THEN NEXT.
                           IF Period-type = 4 AND
                                 trn-doc.shift-num <> X-Shift-Alone then NEXT.

                            IF NOT (trn-doc.doc-type = {&expense} OR
                                         trn-doc.doc-type = {&write-off}) THEN  NEXT.

                            if trn-doc.ext-doc-type =  {&TDEDT_Ras_Vnesh_Kass} or
                            trn-doc.office
                            then NEXT.
                            if trn-doc.ext-doc-type =  {&TDEDT_Ras_Vnesh_VP} then dt = {&TDEDT_Ras_Vnesh_VP-full}.
                            else dt = "".
                           { rep/e-petnkq.i 1 }
                    END. /*FOR EACH trn-doc*/
            END.
            WHEN no then do:
                    ACCUMULATE obj-list.obj-code ( COUNT ) .
                    FOR EACH trn-doc WHERE trn-doc.obj-type = obj-list.obj-type AND
                                                                trn-doc.obj-code = obj-list.obj-code AND
                                                                trn-doc.internal = no AND
                                                                trn-doc.status_ = {&fact} AND
                                                                trn-doc.fact-date >= x-date-start AND
                                                                trn-doc.fact-date <= x-date-end
                                                                NO-LOCK:
                        IF NOT (trn-doc.doc-type = {&expense} OR
                                     trn-doc.doc-type = {&write-off}) THEN  NEXT.
                         if trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass} OR
                         trn-doc.office
                         then NEXT.
                         if trn-doc.ext-doc-type =  {&TDEDT_Ras_Vnesh_VP} then dt = {&TDEDT_Ras_Vnesh_VP-full}.
                         else dt = "".
                         { rep/e-petnkq.i 1 }
                    END. /*FOR EACH trn-doc*/
            END.
        END CASE.
END. /*FOR each obj-list*/


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Print-no-break F-Frame-Win
PROCEDURE Print-no-break :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable    acc-qnty-gds  as decimal no-undo.
define variable    acc-tot-r-b-gds  as decimal no-undo.
define variable    acc-discnt-r-b-gds  as decimal no-undo.
define variable    acc-netto-r-b-gds  as decimal no-undo.
define variable    acc-qnty-obj  as decimal no-undo.
define variable    acc-tot-r-b-obj  as decimal no-undo.
define variable    acc-discnt-r-b-obj  as decimal no-undo.
define variable    acc-netto-r-b-obj  as decimal no-undo.
define variable    acc-qnty  as decimal no-undo.
define variable    acc-tot-r-b  as decimal no-undo.
define variable    acc-discnt-r-b  as decimal no-undo.
define variable    acc-netto-r-b  as decimal no-undo.

/*процедура печати отчета*/
if NOT can-find(first tops) then do:
    message {&no-benefits}
    view-as alert-box.
    run waitfram-hide in this-procedure .
    return "error".
end.

run prn-lib-open-stream  in this-procedure (
                                             input my-handle
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

FORM HEADER
    Line format "X(136)" AT 1 SKIP
    "Продолжение - на следующей странице" AT 30 SKIP
        with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW stream PrnLibStream FRAME BottomFrame .

PUT stream PrnLibStream
space(5) string( "РАСХОД НЕФТЕПРОДУКТОВ ПО ДОКУМЕНТАМ " + str1) format "X(140)"
SKIP(0)
Radio-Label(string(frame {&frame-name} Rs-by), Rs-by:radio-buttons) format "X(40)" skip(0)
.
FOR EACH obj-list No-LOCK :
    FIND FIRST ub.clients No-LOCK WHERE ub.clients.obj-type = obj-list.obj-type AND
                                                                     ub.clients.obj-code = obj-list.obj-code No-ERROR.
    PUT STREAM PrnLibStream
    clients.obj-name
    skip(0)
    .
END.
PUT stream PrnLibStream skip(1).
FOR EACH tops No-LOCK break BY tops.obj-type
                                                    BY tops.obj-code
                                                    BY tops.gds-code
                                                    BY tops.sale-date
                                                    By tops.shift-num
                                                    BY tops.pl-code:
    IF HowBReak AND FIRST-OF(tops.obj-code) then do:
        FIND FIRST clients No-LOCK WHERE clients.obj-type = tops.obj-type AND
                                         clients.obj-code = tops.obj-code No-ERROR.
               assign
               acc-qnty-obj = 0
               acc-tot-r-b-obj = 0
               acc-discnt-r-b-obj = 0
               acc-netto-r-b-obj = 0
                .
                DISPLAY STREAM PrnLibStream
                clients.obj-name @ tops.gds-name
                WITH FRAME TopsF.
                UNDERLINE STREAM PrnLibStream
                tops.sale-date
                tops.shift-name
                tops.gds-code
                tops.gds-name
                tops.doc-code
                tops.doc-type
                tops.pl-code
                tops.qnty
                tops.tot-r-b
                tops.discnt-r-b
                for-netto
                WITH FRAME TopsF.
            END. /*HowBReak AND FIRST-OF(tops.obj-code) */
            IF FIRST-of(tops.gds-code) then
            assign
            acc-qnty-gds = 0
            acc-tot-r-b-gds = 0
            acc-discnt-r-b-gds = 0
            acc-netto-r-b-gds = 0
            .
            IF HowBreak then do:
                DISPLAY STREAM PrnLibStream
                tops.sale-date
                tops.shift-name
                tops.gds-code
                tops.gds-name
                tops.doc-code
                tops.doc-type
                tops.pl-code
                tops.qnty
                tops.tot-r-b
                tops.discnt-r-b
                (tops.tot-r-b - tops.discnt-r-b) @ for-netto
                WITH FRAME TopsF.
                DOWN STREAM PrnLibStream 1 with frame TopsF.
            end.
            else do:
                DISPLAY STREAM PrnLibStream
                tops.sale-date
                tops.shift-name
                tops.gds-code
                tops.gds-name
                tops.qnty
                tops.tot-r-b
                tops.discnt-r-b
                (tops.tot-r-b - tops.discnt-r-b) @ for-netto
                WITH FRAME Topsf.
                DOWN STREAM PrnLibStream 1 with frame Topsf.
            end.
            assign
            acc-qnty-gds = acc-qnty-gds + tops.qnty
            acc-tot-r-b-gds = acc-tot-r-b-gds + tops.tot-r-b
            acc-discnt-r-b-gds = acc-discnt-r-b-gds + tops.discnt-r-b
            acc-netto-r-b-gds = acc-netto-r-b-gds + (tops.tot-r-b - tops.discnt-r-b)
            acc-qnty-obj = acc-qnty-obj + tops.qnty
            acc-tot-r-b-obj = acc-tot-r-b-obj + tops.tot-r-b
            acc-discnt-r-b-obj = acc-discnt-r-b-obj + tops.discnt-r-b
            acc-netto-r-b-obj = acc-netto-r-b-obj + (tops.tot-r-b - tops.discnt-r-b)
            acc-qnty = acc-qnty + tops.qnty
            acc-tot-r-b = acc-tot-r-b + tops.tot-r-b
            acc-discnt-r-b = acc-discnt-r-b + tops.discnt-r-b
            acc-netto-r-b = acc-netto-r-b + (tops.tot-r-b - tops.discnt-r-b)
            .

            IF LAST-OF(tops.gds-code) then do:
                if HowBreak then do:
                    UNDERLINE STREAM PrnLibStream
                    tops.sale-date
                    tops.shift-name
                    tops.gds-code
                    tops.gds-name
                    tops.doc-code
                    tops.doc-type
                    tops.pl-code
                    tops.qnty
                    tops.tot-r-b
                    tops.discnt-r-b
                    for-netto
                    WITH FRAME TopsF.
                    DISPLAY STREAM PrnLibStream
                    "Итого по товару" @ tops.sale-date
                    tops.gds-code
                    tops.gds-name
                    acc-qnty-gds @ tops.qnty
                    acc-tot-r-b-gds @ tops.tot-r-b
                    acc-discnt-r-b-gds @ tops.discnt-r-b
                    acc-netto-r-b-gds @ for-netto
                    WITH FRAME TopsF.
                    DOWN STREAM PrnLibStream 1 with frame TopsF.
                    UNDERLINE STREAM PrnLibStream
                    tops.sale-date
                    tops.shift-name
                    tops.gds-code
                    tops.gds-name
                    tops.doc-code
                    tops.doc-type
                    tops.pl-code
                    tops.qnty
                    tops.tot-r-b
                    tops.discnt-r-b
                    for-netto
                    WITH FRAME TopsF.
                end.
                else do:
                    UNDERLINE STREAM PrnLibStream
                    tops.sale-date
                    tops.shift-name
                    tops.gds-code
                    tops.gds-name
                    tops.qnty
                    tops.tot-r-b
                    tops.discnt-r-b
                    for-netto
                    WITH FRAME Topsf.
                    DISPLAY STREAM PrnLibStream
                    "Итого по товару" @ tops.sale-date
                    tops.gds-code
                    tops.gds-name
                    acc-qnty-gds @ tops.qnty
                    acc-tot-r-b-gds @ tops.tot-r-b
                    acc-discnt-r-b-gds @ tops.discnt-r-b
                    acc-netto-r-b-gds @ for-netto
                    WITH FRAME Topsf.
                    DOWN STREAM PrnLibStream 1 with frame Topsf.
                    UNDERLINE STREAM PrnLibStream
                    tops.sale-date
                    tops.shift-name
                    tops.gds-code
                    tops.gds-name
                    tops.qnty
                    tops.tot-r-b
                    tops.discnt-r-b
                    for-netto
                    WITH FRAME Topsf.
                end.
            END.
            IF HOWBREAK AND LAST-OF(tops.obj-code) then do:
                UNDERLINE STREAM PrnLibStream
                tops.sale-date
                tops.shift-name
                tops.gds-code
                tops.gds-name
                tops.doc-code
                tops.doc-type
                tops.pl-code
                tops.qnty
                tops.tot-r-b
                tops.discnt-r-b
                for-netto
                WITH FRAME TopsF.
                DISPLAY STREAM PrnLibStream
                "Итого по объекту" @ tops.sale-date
                acc-qnty-obj @ tops.qnty
                acc-tot-r-b-obj @ tops.tot-r-b
                acc-discnt-r-b-obj @ tops.discnt-r-b
                acc-netto-r-b-obj @ for-netto
                WITH FRAME TopsF.
                DOWN STREAM PrnLibStream 1 with frame TopsF.
                UNDERLINE STREAM PrnLibStream
                tops.sale-date
                tops.shift-name
                tops.gds-code
                tops.gds-name
                tops.doc-code
                tops.doc-type
                tops.pl-code
                tops.qnty
                tops.tot-r-b
                tops.discnt-r-b
                for-netto
                WITH FRAME TopsF.
            end.
        END.
        DISPLAY STREAM PrnLibStream
        "ИТОГO" @ tops.sale-date
        acc-qnty @ tops.qnty
        acc-tot-r-b @ tops.tot-r-b
        acc-discnt-r-b @ tops.discnt-r-b
        acc-netto-r-b @ for-netto
        WITH FRAME Topsf.
        DOWN STREAM PrnLibStream 1 with frame TopsF.
        output stream PrnLibStream CLOSE.
        run waitfram-hide in this-procedure .

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