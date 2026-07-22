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

Отчет о выручке с выбором интервалов времени

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/05/06
Author: Bakhtadze Natalya
Creation date: 04/05/06

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Отчет о выручке с выбором интервалов времени" .
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-page1.i }
{ cmp/operlist.i }
{ gbl/waitfram.i }


/*вид отчета по периоду*/
define variable State-source as Widget-handle.
defINE shared varIABLE cas-shft as logical no-undo init no.

{ rep/r-benttm.i "NEW SHARED" }

define variable     HowBreak        as      logical     no-undo.
define variable     my-SET_val_TYPE as integer no-undo.

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
&Scoped-Define ENABLED-OBJECTS RECT-detail RECT-method RECT-3 RECT-4 RS-by ~
RS-method RS-cass T-time 
&Scoped-Define DISPLAYED-OBJECTS RS-by RS-method RS-cass T-time 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of handles for SmartObjects                              */
DEFINE VARIABLE h_s-time AS HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE VARIABLE Cas-Num AS INTEGER FORMAT ">>9":U INITIAL 0 
     LABEL "N" 
     VIEW-AS FILL-IN 
     SIZE 4.6 BY 1 NO-UNDO.

DEFINE VARIABLE RS-by AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Без разбиения", 0,
"C разбиением по дням", 1,
"C разбиением по кассам", 2,
"С разбиением по товарам", 3
     SIZE 31.8 BY 4.24 NO-UNDO.

DEFINE VARIABLE RS-cass AS CHARACTER INITIAL "all" 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все", "all":U,
"Выборочно", "selective":U
     SIZE 14.8 BY 1.81 NO-UNDO.

DEFINE VARIABLE RS-method AS CHARACTER INITIAL "chk-doc" 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Отчет о продаже", "inkas":U,
"Чеки", "chk-doc":U
     SIZE 25.8 BY 2.1 NO-UNDO.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 36.2 BY 3.48.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 36 BY 2.48.

DEFINE RECTANGLE RECT-detail
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 36.2 BY 6.29.

DEFINE RECTANGLE RECT-method
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 35.8 BY 3.71.

DEFINE VARIABLE T-time AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.6 BY .91 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     RS-by AT ROW 2.71 COL 4.2 NO-LABEL
     RS-method AT ROW 9.33 COL 4 NO-LABEL
     RS-cass AT ROW 13.05 COL 4 NO-LABEL
     Cas-Num AT ROW 13.67 COL 28.6 COLON-ALIGNED
     T-time AT ROW 17.05 COL 4
     "Выборочно по времени" VIEW-AS TEXT
          SIZE 25.2 BY .91 AT ROW 15.95 COL 3.8
          FGCOLOR 4 
     "Кассы" VIEW-AS TEXT
          SIZE 21.4 BY 1 AT ROW 12.05 COL 4
          FGCOLOR 4 
     "Детализация" VIEW-AS TEXT
          SIZE 27.8 BY 1 AT ROW 1.43 COL 4.2
          FGCOLOR 4 
     "Метод формирования" VIEW-AS TEXT
          SIZE 23.8 BY .95 AT ROW 8.24 COL 4
          FGCOLOR 4 
     RECT-detail AT ROW 1.14 COL 2.2
     RECT-method AT ROW 7.91 COL 2
     RECT-3 AT ROW 11.86 COL 2
     RECT-4 AT ROW 15.76 COL 2
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 66.2 BY 17.62.


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
         HEIGHT             = 17.62
         WIDTH              = 66.2.
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
/* SETTINGS FOR FILL-IN Cas-Num IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       Cas-Num:HIDDEN IN FRAME F-Main           = TRUE.

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

&Scoped-define SELF-NAME RS-by
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-by F-Frame-Win
ON VALUE-CHANGED OF RS-by IN FRAME F-Main
DO:
    assign RS-by.
    if RS-by = 3 then assign /* с разбиением по товарам - только для "Чеки", не для "Отчёт о продаже" */
      RS-method:SENSITIVE in frame F-Main = false
      RS-method:SCREEN-VALUE in frame F-Main = "chk-doc":U 
    .
    else assign
      RS-method:SENSITIVE in frame F-Main = true
    .
    assign
    RS-method.
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
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-method
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-method F-Frame-Win
ON VALUE-CHANGED OF RS-method IN FRAME F-Main
DO:
  assign
  rs-method
  RS-BY.
  if rs-method = "inkas":U then do:
    my-request = true.
    Verify-send-check = false  .
    { rep/get-link.i 'State':U}
    Run Select-Objects-proc IN State-source.
  end.
  else do:
    my-request = true.
    Verify-send-check = true  .
    { rep/get-link.i 'State':U}
    Run Select-Objects-proc IN State-source.
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
       /* Position in AB:  ( 3.95 , 40.20 ) */
       /* Size in UIB:  ( 12.05 , 22.40 ) */

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
  DISPLAY RS-by RS-method RS-cass T-time 
      WITH FRAME F-Main.
  ENABLE RECT-detail RECT-method RECT-3 RECT-4 RS-by RS-method RS-cass T-time 
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
    when {&obj-currency} then do:
        enable rs-cass with frame {&frame-name}.
    end.
    when {&all} then do:
        assign cas-num  = 0
        rs-cass = "all":U.
        display rs-cass with frame {&frame-name}.
        disable rs-cass with frame {&frame-name}.
        Hide cas-num in frame {&frame-name}.
    end.
    when {&obj-choice} then do:
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
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
       RUN set-position IN h_s-time ( 1.00 , 40.25 ) NO-ERROR.
  /* Code placed here will execute AFTER standard behavior.    */
    run ini-from-selobj.

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
Run My-var.
run waitfram-show in this-procedure ( "Ждите..." ) .
HowBreak = (Rs-by > 0) .

if RS-method = "inkas" then do:
  case RS-by:
    when 2 then do: /* с разбиением по кассам */
    case my-Set_val_type:
      when {&v-base} then
      run rep/r-beneb4.p (  input my-handle
                      ,input cas-num
                      ,input howbreak
                      ) no-error.
      when {&v-rubl} then
      run rep/r-bener4.p (
                      input my-handle
                      ,input cas-num
                      ,input howbreak
                      ) no-error.
      when {&v-all} then
      run rep/r-bento4.p (
                      input my-handle
                      ,input cas-num
                      ,input howbreak
                      ) no-error.
    END CASE.
    end.
    when 3 then .   /* с разбиением по товарам для inkas не применяется: inkas не содержит информации о товарах */
    otherwise do: /* без разбиения (0), с разбиением по дням (1) */
    case my-Set_val_type:
      when {&v-base} then
      run rep/r-beneb3.p (
                       input my-handle
                      ,input cas-num
                      ,input howbreak
                      ) no-error .
      when {&v-rubl} then
      run rep/r-bener3.p (
                      input my-handle
                      ,input cas-num
                      ,input howbreak
                      ) no-error .
      when {&v-all} then
      run rep/r-bento3.p (  input my-handle
                      ,input cas-num
                      ,input howbreak
                      ) no-error .

    END CASE.
    end.
  end case.
end.
else do: /* chk-doc */
  case RS-by:
    when 2 then do: /* с разбиением по кассам */
      case my-Set_val_type:
        when {&v-base} then
        run rep/r-bennb2.p (
                        input my-handle
                        ,input cas-num
                        ,input howbreak
                        ,input T-time
                        ) no-error.
        when {&v-rubl} then
        run rep/r-bennr2.p (
                        input my-handle
                        ,input cas-num
                        ,input howbreak
                        ,input T-time
                        ) no-error.
        when {&v-all} then
        run rep/r-bnnto2.p (
                        input my-handle
                        ,input cas-num
                        ,input howbreak
                        ,input T-time
                        ) no-error.

      END CASE.
    end.
    when 3 then do: /* с разбиением по товарам (только для chk-doc) */
          run rep/r-beneb5.p (
                        input my-handle
                        ,input cas-num
                        ,input howbreak
                        ) no-error.
    end.
    otherwise do: /* без разбиения (0), с разбиением по дням (1) */
      case my-Set_val_type:
        when {&v-base} then
        run rep/r-bennb1.p (
                        input my-handle
                        ,input cas-num
                        ,input howbreak
                        ,input T-time
                        ) no-error.
        when {&v-rubl} then
        run rep/r-bennr1.p (
                        input my-handle
                        ,input cas-num
                        ,input howbreak
                        ,input T-time
                        ) no-error.
        when {&v-all} then
        run rep/r-bnnto1.p (
                        input my-handle
                        ,input cas-num
                        ,input howbreak
                        ,input T-time
                        ) no-error.

      END CASE.
    end.
  end case. /* RS-by */
end. /* end_of chk-doc */
if error-status:error then do:
  run waitfram-hide in this-procedure .
  return error .
end.
run waitfram-hide in this-procedure .


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

assign
frame {&frame-name} Rs-BY
frame {&frame-name} Rs-Method
frame {&frame-name} Rs-Cass
frame {&frame-name} Cas-num
frame {&frame-name} T-time
.
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
ReportNAme = "Отчет о выручке".
ReportHeader =  "Метод формирования: " +
                            radio-label(string(rs-method), rs-method:radio-buttons) + {&new-line} +
                            "Детализация: " +
                            radio-label(string(rs-by), rs-by:radio-buttons) + {&new-line} +
                            "Кассы: " +
                            radio-label(string(rs-cass), rs-cass:radio-buttons) + {&new-line} +
                            (IF cas-num > 0 then ("Касса N: " + String(cas-num)) else "") +
                            (IF rs-method = "chk-doc":U
                            then  (IF T-time then string({&new-line} + "Выборочно по времени") else "")
                            else "")
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
  CASE p-state:
    WHEN "link-changed" then do:
        run ini-from-selobj.
    end.
  END CASE.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

