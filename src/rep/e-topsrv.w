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

Продажи топлива и сервисного элемента

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
define variable vss-description as character no-undo init "Продажи топлива и сервисного элемента".
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


&global-define  no-benefits    "Не было продаж на выбранных объектах ~
в течение заданного Вами периода времени."
DEFINE {1} SHARED VARIABLE loc#log as LOGICAL NO-UNDO.
DEFINE {1} SHARED VARIABLE loc#db-num as integer NO-UNDO.
DEFINE {1} SHARED VARIABLE loc#host-code as integer NO-UNDO.
DEFINE {1} SHARED VARIABLE loc#store-code as integer NO-UNDO.
def SHARED var cas-shft as logical no-undo init no.
define variable sym1 as char init ":"   no-undo.
define variable sym2 as char init ":"   no-undo.
define variable sym3 as char init ":"   no-undo.
define variable sym4 as char init ":"   no-undo.
define variable sym5 as char init ":"   no-undo.
define variable sym6 as char init ":"   no-undo.
define variable sym7 as char init ":"   no-undo.
define variable sym8 as char init ":"   no-undo.
define variable     NotInc          as  log     no-undo.

define variable Line                as      char    no-undo.
define variable date_string     as      char    no-undo.
define var for-tot-r-b as decimal no-undo.
define var for-diff as decimal no-undo.
define var for-diff-q as decimal no-undo.
define var for-main as char no-undo.
define variable found as logical init yes no-undo.
define variable     DatePrinted     as      logical     no-undo.
def buffer b-inkas for ub.inkas .
def buffer b-inkas-pay for ub.inkas-pay .

define variable sale-price-type as character.
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


def temp-table benefits no-undo
    Field b-code like ub.bar-code.b-code
    field gds-name like ub.goods.gds-name
    field artic like ub.goods.artic
    field prod-type like ub.goods.prod-type
    field prod-code like ub.goods.prod-code
    field main_ as logical
    field qnty as decimal format "->>>,>>>,>>9.999"
    field tot-r-b like    ub.chk-pay.tot-base
    field tot-r-b-brutto like    ub.chk-pay.tot-base
    field price like ub.chk-gds.price-base
    field price-uchet like ub.chk-gds.price-base
    field out-code like ub.inkas.inkas-code
    field unit-base like ub.goods.unit-base
    INDEX pi IS PRIMARY     b-code main_  out-code price ASCENDING
    INDEX p1 b-code ASCENDING
    .
define buffer for-ben for benefits.
def buffer benBuffer for benefits.

DEFINE FRAME Benefit-Base
sym1 column-label ":"format "X(1)"
benefits.b-code column-label "Код!топлива" format ">>>>>>9"
benefits.gds-name column-label "Название топлива" format "X(30)"
benefits.qnty column-label "Кол-во"
for-tot-r-b column-label "Сумма"  format "->,>>>,>>>,>>>,>>9.99"
sym6 column-label ":" format "X(1)"
for-ben.b-code column-label "Код СЭ" format ">>>>>>9"
for-ben.gds-name column-label "Название СЭ" format "X(30)"
for-ben.qnty column-label "Кол-во СЭ"
for-ben.tot-r-b column-label  "Сумма по СЭ"  format "->,>>>,>>>,>>>,>>9.99"
for-diff-q column-label "Разница!по кол-ву"
for-diff column-label "Разница!по сумме"
benefits.tot-r-b column-label "Нетто сумма"  format "->,>>>,>>>,>>>,>>9.99"
sym7 column-label ":" format "X(1)"
HEADER  date_string AT 5 format "X(35)"
v-header-base-curr        format "X(20)" AT 42
"Страница " AT 65 PAGE-NUMBER( PrnLibStream )  AT 75 FORMAT ">>9" SKIP
Line format "X(107)" AT 1
with width {&DOS_CW_2} down stream-io use-text .



DEFINE FRAME Benefit-uchet
sym1 column-label ":"format "X(1)"
benefits.b-code column-label "Код!топлива" format ">>>>>>9"
benefits.gds-name column-label "Название топлива" format "X(30)"
benefits.unit-base column-label "Ед.изм."
benefits.qnty column-label "Кол-во"
benefits.price-uchet column-label "Учетная цена" format "->,>>>,>>>,>>9.99"
benefits.price column-label "Розничная цена" format "->,>>>,>>>,>>9.99"
sym6 column-label ":" format "X(1)"
benefits.tot-r-b column-label "Сумма  по учет.цене" format "->,>>>,>>>,>>>,>>9.99"
benefits.tot-r-b-brutto column-label "Сумма  по розн.цене" format "->,>>>,>>>,>>>,>>9.99"
for-ben.b-code column-label "Код основн.!товара"
for-main column-label "Тип!товара"
sym7 column-label ":" format "X(1)"
HEADER  date_string AT 5 format "X(35)"
v-header-base-curr        format "X(20)" AT 42
"Страница " AT 65 PAGE-NUMBER( PrnLibStream )  AT 75 FORMAT ">>9" SKIP
Line format "X(107)" AT 1
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
&Scoped-Define ENABLED-OBJECTS RECT-11 RECT-12 RS-method RS-cass cas-num
&Scoped-Define DISPLAYED-OBJECTS RS-method RS-cass cas-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE cas-num AS INTEGER FORMAT ">>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14.25 BY .96 NO-UNDO.

DEFINE VARIABLE RS-cass AS CHARACTER INITIAL "1"
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", "1",
"Выборочно", "2"
     SIZE 26.38 BY 2.13 NO-UNDO.

DEFINE VARIABLE RS-method AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Без разбивки по ценам", "no-break":U,
"С разбивкой по ценам", "break":U
     SIZE 25.88 BY 2.21 NO-UNDO.

DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 30.38 BY 3.42.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 30.63 BY 5.67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     RS-method AT ROW 2.42 COL 3.88 NO-LABEL
     RS-cass AT ROW 6.54 COL 3.5 NO-LABEL
     cas-num AT ROW 9.08 COL 4.5 COLON-ALIGNED NO-LABEL
     "Кассы:" VIEW-AS TEXT
          SIZE 26.63 BY .96 AT ROW 5.17 COL 3.75
          FGCOLOR 4
     RECT-11 AT ROW 1.5 COL 2.25
     RECT-12 AT ROW 5.08 COL 2
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 42 BY 11.88.


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
         WIDTH              = 36.38.
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

&Scoped-define SELF-NAME RS-cass
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-cass F-Frame-Win
ON VALUE-CHANGED OF RS-cass IN FRAME F-Main
DO:
assign RS-Cass.
  if RS-cass = {&all} then do:
    assign cas-num = 0.
    disable cas-num with frame {&frame-name}.
    hide cas-num in frame {&frame-name}.

  end.
  else do:
    assign rs-method = "no-break":U.
    enable cas-num with frame {&frame-name}.
    display cas-num rs-method with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-method
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-method F-Frame-Win
ON VALUE-CHANGED OF RS-method IN FRAME F-Main
DO:
   assign rs-method .
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
  DISPLAY RS-method RS-cass cas-num
      WITH FRAME F-Main.
  ENABLE RECT-11 RECT-12 RS-method RS-cass cas-num
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Ini-from-selobj F-Frame-Win
PROCEDURE Ini-from-selobj :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER myp-state as character no-undo.
    CASE myp-state:
        WHEN {&all} then do:
                assign
                RS-CASS = "Все".
                Display RS-CASS with frame {&frame-name}.
                DISABLE RS-CASS with frame {&frame-name}.
        END.
        WHEN "Текущий" then do:
                ENABLE RS-CASS with frame {&frame-name}.
        END.
        WHEN "Выборочно" then do:
                assign
                RS-CASS = "Все".
                Display RS-CASS with frame {&frame-name}.
                DISABLE RS-CASS with frame {&frame-name}.
        END.
    END CASE.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-apply-layout F-Frame-Win
PROCEDURE local-apply-layout :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */
ASSIGN
RS-cass:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =  "все" + {&comma-char} + {&all} + {&comma-char} +
                                 "Выборочно" + {&comma-char} + {&obj-currency}.
  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'apply-layout':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

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
    apply "value-changed" to rs-method in frame {&frame-name}.
    apply "value-changed" to rs-cass in frame {&frame-name}.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-Report F-Frame-Win
PROCEDURE My-Report :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
ASSIGN
frame {&frame-name} cas-num
frame {&frame-name} RS-cass
frame {&frame-name} RS-method
.
run My-var.
assign
date_string = cur-time-print()
Line = fill( "-", 140 )
.

run no-benq(output found).

run no-benqi(output NotInc).

if not found then do:
    run waitfram-hide in this-procedure .
    message {&no-benefits} view-as alert-box information .
    return.
end.

run waitfram-show in this-procedure ( {&MyWaitMess} ) .

if v-curr-r-b = {&r-b-base} then do:
  sale-price-type = base-type.
end.
else do:
  sale-price-type = "{&abbr_rubley}".
end.

run top-sq.

IF RS-method = "no-break":U then RUN Print-no-break.
else RUN Print-break.
/*
assign
g#rep-tblname = ""
g#rep-tblrid = -101
g#rep-updflds = string( "Продажи топлива и сервисного элемента|" +
                        str1 ) .
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
ASSIGN
frame {&frame-name} RS-Method
frame {&frame-name} RS-Cass
frame {&frame-name} Cas-Num
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
ReportNAme = "Продажи топлива и сервисного элемента".
ReportHeader =  radio-label(string(Rs-Method), RS-Method:radio-buttons) + {&new-line} +
                            "Кассы: " +
                            radio-label(string(Rs-cass), RS-cass:radio-buttons) + {&new-line} +
                            (IF Rs-cass = "Выборочно" then ("Касса N:" + string(cas-num)) else "") .





END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Print-Break F-Frame-Win
PROCEDURE Print-Break :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable found as logical init no no-undo.

run waitfram-hide in this-procedure .
run prn-lib-open-stream  in this-procedure (
                                             input my-handle
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


FORM HEADER
Line format "X(107)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame1 width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW stream PrnLibStream FRAME BottomFrame1 .

FIND FIRST ub.clients No-LOCK WHERE
             ub.clients.obj-type = v-cntxt-obj-type
         AND ub.clients.obj-code = v-cntxt-obj-code No-ERROR.

PUT stream PrnLibStream space(5)  "ОТЧЕТ  ПО  ПРОДАЖАМ ТОПЛИВА И СЕРВИСНОМУ ЭЛЕМЕНТУ С РАЗБИВКОЙ ПО ЦЕНЕ" skip(1).
PUT stream PrnLibStream UNFORMATTED str4 skip(0).
PUT stream PrnLibStream str1 format "X(120)" SKIP(1)
space(5) (
IF NotInc then
"( сформирован по ВСЕМ ЧЕКАМ " + (IF cas-num = 0 then "ВСЕХ КАСС" ELSE
("КАССЫ " + string(cas-num))) + " , вошедшим в отчеты о продажах )"
else
"( сформирован по ВСЕМ ЧЕКАМ " + (IF cas-num = 0 then "ВСЕХ КАСС" ELSE
("КАССЫ " + string(cas-num) ) ) + ")"
 )
format "x(80)" skip
.
            FORM with frame Benefit-Uchet .
FOR EACH benefits NO-LOCK BREAk BY benefits.b-code  BY benefits.out-code:
        IF FIRST-OF(benefits.out-code) then do:
            FIND FIRST ub.doc-line No-LOCK WHERE
                                ub.doc-line.artic = benefits.artic AND
                                ub.doc-line.prod-type = benefits.prod-type AND
                                ub.doc-line.prod-code = benefits.prod-code AND
                                ub.doc-line.doc-code = benefits.out-code NO-ERROR.
            IF AVAIL doc-line then
            for-tot-r-b = if v-curr-r-b = {&r-b-base}
                          then  ub.doc-line.price-base
                          else ub.doc-line.price-rubl.
            else for-tot-r-b = 0.
            found = no.
            if NOT benefits.main_ then do:
                FIND first ub.recipe-gds where ub.recipe-gds.recipe-code = ub.recipe.recipe-code No-LOCK NO-ERROR.
                IF not avail ub.recipe-gds then found = no.
                else do:
                    FIND FIRST for-ben No-LOCK WHERE for-ben.artic = ub.recipe-gds.artic AND
                                                                              for-ben.prod-type = ub.recipe-gds.prod-type AND
                                                                              for-ben.prod-code = ub.recipe-gds.prod-code No-ERROR.
                    IF not avail for-ben then found = no.
                    else do:
                        FIND FIRST recipe where ub.recipe-gds.recipe-code = ub.recipe.recipe-code No-LOCK.
                        IF AVAIL recipe then do:
                            FIND FIRST for-ben No-LOCK where for-ben.artic = ub.recipe.artic AND
                                                                                      for-ben.prod-type = ub.recipe.prod-type AND
                                                                                      for-ben.prod-code = ub.recipe.prod-code NO-ERROR.
                            IF AVAIL for-ben then found = yes.
                            else found = no.
                        end.
                        else found = no.
                    end.
                end.
            end.
        end.

        DISPLAY stream PrnLibStream
        benefits.b-code
        benefits.gds-name
        benefits.unit-base
        benefits.qnty
        benefits.price-uchet * benefits.qnty  @ benefits.tot-r-b
        benefits.tot-r-b-brutto
        if found then for-ben.b-code else benefits.b-code @ for-ben.b-code
        if benefits.main_ then 'осн' else "доп" @ for-main
        sym1
        sym6
        sym7
        with frame Benefit-Uchet .
         DOWN stream PrnLibStream 1 with frame Benefit-Uchet .
END.
        HIDE stream PrnLibStream FRAME BottomFrame1.

            PUT stream PrnLibStream Line format "X(140)" SKIP(1) .

        if ( line-counter( PrnLibStream ) + 9 ) > page-size( PrnLibStream ) then  page .
        PUT stream PrnLibStream space(10) "Директор _______________" format "X(30)"
                                "Старший продавец ______________" format "X(30)" SKIP(2)
                            space(10) "Бухгалтер ______________" format "X(30)"
                                "Кассир ________________________" format "X(30)" SKIP .
        output stream PrnLibStream CLOSE.

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
define variable found as logical init no no-undo.

run waitfram-hide in this-procedure .
run prn-lib-open-stream  in this-procedure (
                                             input my-handle
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


FORM HEADER
Line format "X(107)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW stream PrnLibStream FRAME BottomFrame .

FIND FIRST ub.clients No-LOCK WHERE
        ub.clients.obj-type = v-cntxt-obj-type
    AND ub.clients.obj-code = v-cntxt-obj-code No-ERROR.

PUT stream PrnLibStream space(5)  "ОТЧЕТ  ПО  ПРОДАЖАМ ТОПЛИВА И СЕРВИСНОМУ ЭЛЕМЕНТУ" skip(1).
PUT stream PrnLibStream UNFORMATTED str4 skip(0).
PUT stream PrnLibStream UNFORMATTED str1
space(5) (
IF NotInc then
"( сформирован по ВСЕМ ЧЕКАМ " + (IF cas-num = 0 then "ВСЕХ КАСС" ELSE
("КАССЫ " + string(cas-num))) + " , вошедшим в отчеты о продажах )"
else
"( сформирован по ВСЕМ ЧЕКАМ " + (IF cas-num = 0 then "ВСЕХ КАСС" ELSE
("КАССЫ " + string(cas-num) ) ) + ")"
 )
format "x(80)" skip
.
            FORM with frame Benefit-Base .
FOR EACH benefits NO-LOCK WHERE benefits.main_ BREAk BY benefits.b-code  :
        ACCUMULATE
        benefits.qnty (total BY benefits.b-code)
        benefits.tot-r-b (total BY benefits.b-code)
        benefits.tot-r-b-brutto (total BY benefits.b-code).


        FIND FIRST ub.recipe No-LOCK where ub.recipe.artic = benefits.artic AND
                                                                 ub.recipe.prod-type = benefits.prod-type AND
                                                                 ub.recipe.prod-code = benefits.prod-code NO-ERROR.
        IF not avail ub.recipe then do:
            found = no.
        end.
        else do:
            FIND first ub.recipe-gds where ub.recipe-gds.recipe-code = ub.recipe.recipe-code No-LOCK NO-ERROR.
            IF not avail recipe-gds then found = no.
            else do:
                FIND FIRST for-ben No-LOCK WHERE for-ben.artic = ub.recipe-gds.artic AND
                                                                              for-ben.prod-type = ub.recipe-gds.prod-type AND
                                                                              for-ben.prod-code = ub.recipe-gds.prod-code No-ERROR.
                IF not avail for-ben then found = no.
                else found = yes.
            end.
        end.
        if found then
        ACCUMULATE
        for-ben.qnty (TOTAL)
        for-ben.tot-r-b (TOTAL).
        ACCUMULATE
        (benefits.tot-r-b-brutto - benefits.tot-r-b - (IF found then for-ben.tot-r-b else 0 )) (TOTAL)
        (benefits.qnty - (IF found then for-ben.qnty else 0)) (TOTAL).


        DISPLAY stream PrnLibStream
                        benefits.b-code
                        benefits.gds-name
                        benefits.qnty
                        benefits.tot-r-b-brutto @ for-tot-r-b
                        for-ben.b-code when found
                        for-ben.gds-name when found
                        for-ben.qnty  when found
                        for-ben.tot-r-b when found
                        IF found then (benefits.qnty - for-ben.qnty) else benefits.qnty
                        @ for-diff-q
                        (IF found then (benefits.tot-r-b-brutto - benefits.tot-r-b - for-ben.tot-r-b) else
                        (benefits.tot-r-b-brutto - benefits.tot-r-b))
                        @ for-diff
                        benefits.tot-r-b
                        sym1
                        sym6
                        sym7
                        with frame Benefit-Base .
                        DOWN stream PrnLibStream 1 with frame Benefit-Base .
        IF LAST(benefits.b-code) then do:
            UNDERLINE stream PrnLibStream
                        benefits.b-code
                        benefits.gds-name
                        benefits.qnty
                        for-tot-r-b
                        for-ben.b-code
                        for-ben.gds-name
                        for-ben.qnty
                        for-ben.tot-r-b
                        for-diff-q
                        for-diff
                        benefits.tot-r-b
                        sym1
                        sym6
                        sym7
                        with frame Benefit-Base .
             DISPLAY stream PrnLibStream
                        " " @ benefits.b-code
                        "ИТОГО" @ benefits.gds-name
                        ACCUM TOTAL benefits.qnty @ benefits.qnty
                        ACCUM TOTAL benefits.tot-r-b-brutto @ for-tot-r-b
                        " " @ for-ben.b-code
                        " " @ for-ben.gds-name
                        ACCUM TOTAL for-ben.qnty @ for-ben.qnty
                        ACCUM TOTAL for-ben.tot-r-b @ for-ben.tot-r-b
                        ACCUM TOTAL
                        (benefits.qnty - (IF found then for-ben.qnty else 0))
                        @ for-diff-q
                        ACCUM TOTAL
                        (benefits.tot-r-b-brutto - benefits.tot-r-b - (IF found then for-ben.tot-r-b else 0 ))
                        @ for-diff
                        ACCUM TOTAL benefits.tot-r-b @ benefits.tot-r-b
                        sym1
                        sym6
                        sym7
                        with frame Benefit-Base .
                        DOWN stream PrnLibStream 1 with frame Benefit-Base .
            UNDERLINE stream PrnLibStream
                        benefits.b-code
                        benefits.gds-name
                        benefits.qnty
                        for-tot-r-b
                        for-ben.b-code
                        for-ben.gds-name
                        for-ben.qnty
                        for-ben.tot-r-b
                        for-diff-q
                        for-diff
                        benefits.tot-r-b
                        sym1
                        sym6
                        sym7
                        with frame Benefit-Base .
                    end.
END.
        HIDE stream PrnLibStream FRAME BottomFrame.

            PUT stream PrnLibStream Line format "X(140)" SKIP(1) .

        if ( line-counter( PrnLibStream ) + 9 ) > page-size( PrnLibStream ) then  page .
        PUT stream PrnLibStream space(10) "Директор _______________" format "X(30)"
                                "Старший продавец ______________" format "X(30)" SKIP(2)
                            space(10) "Бухгалтер ______________" format "X(30)"
                                "Кассир ________________________" format "X(30)" SKIP .
        output stream PrnLibStream CLOSE.




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
    WHEN "link-changed":U then do:
        run ini-from-selobj(X-Selectobject).
    end.
  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE top-sq F-Frame-Win
PROCEDURE top-sq :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define var b-sum as decimal no-undo.
define var b-sum-brutto as decimal no-undo.
define var b-qnty as decimal no-undo.
define variable me as logical init no no-undo.

if RS-method = "break":U then me = yes.
else me = no.

FOR EACH obj-list WHERE obj-list.obj-type = {&shop} NO-LOCK :
  ACCUMULATE obj-list.obj-code ( COUNT ) .

  CASE (X-Radio-Task > 1):
    WHEN YES THEN DO:
      _chk-doc:
      FOR EACH ub.chk-doc WHERE
              ub.chk-doc.obj-type = obj-list.obj-type AND
              ub.chk-doc.obj-code = obj-list.obj-code AND
                (
                ub.chk-doc.shift-date >= X-date-start AND
                ub.chk-doc.shift-date <= X-date-end)
                AND
              (IF cas-num > 0 then ub.chk-doc.pay-desk = cas-num else TRUE)
              NO-LOCK use-index shift,
              EACH ub.chk-gds NO-LOCK WHERE ub.chk-doc.doc-code = ub.chk-gds.doc-code AND ub.chk-gds.pump > 0
        BREAK
        BY ub.chk-doc.doc-code
        BY ub.chk-gds.b-code:
        if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc.
        IF NOT ub.chk-doc.office = {&gds-goods}  then NEXT.
        IF X-Radio-Task = 3 AND
        ((chk-doc.shift-date = X-date-start AND ub.chk-doc.shift-num < X-shift-Start) OR
          (chk-doc.shift-date = X-date-end AND  ub.chk-doc.shift-num > X-shift-End) ) THEN NEXT.
        IF X-Radio-Task = 4 AND
        (ub.chk-doc.shift-num <> X-shift-Alone ) THEN NEXT.

        { rep/e-topsrq.i }
      end. /*for each chk-doc*/
    END.
    WHEN NO THEN DO:
      _chk-doc2:
      FOR EACH ub.chk-doc WHERE
              ub.chk-doc.obj-type = obj-list.obj-type AND
              ub.chk-doc.obj-code = obj-list.obj-code AND
              ub.chk-doc.chk-date >= X-date-start AND
              ub.chk-doc.chk-date <= X-date-end AND
              (IF cas-num > 0 then ub.chk-doc.pay-desk = cas-num else TRUE)
              NO-LOCK,
          EACH ub.chk-gds NO-LOCK WHERE
              ub.chk-doc.doc-code = ub.chk-gds.doc-code AND ub.chk-gds.pump > 0
       BREAK
       BY ub.chk-doc.doc-code
       BY ub.chk-gds.b-code:
         if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc2.
         { rep/e-topsrq.i }
       end. /*for each chk-doc*/
     END. /*WHEN NO*/
   END CASE.
END. /*obj-list*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME