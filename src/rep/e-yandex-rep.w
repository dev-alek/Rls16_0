&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI ADM2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
{adecomm/appserv.i}
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS fFrameWin 
/*------------------------------------------------------------------------

  File: 

  Description: from cntnrfrm.w - ADM2 SmartFrame Template

  Input Parameters:
      <none>

  Output Parameters:
      <none>

 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */
define variable vss-revision    as character no-undo init "$Revision: ":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сверка по транзакциям Яндекс".
{ cmp/vssrevis.i  }
{ cmp/str-glbl.i  }
{ cmp/r-page1.i   }
{ gbl/usr-flt.i }
/*{ rep/lhstprex.i dc-list-hist  "'дисконтных карт'" }*/
/*{ rep/lhstprex.i gds-list-hist "'товаров'" }        */

{ cmp/dc-list.i dc-list def "new shared" }
{ ref/grplibfn.i }

CREATE WIDGET-POOL.
{ gbl/key-rec.i   }

DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.

ASSIGN parParentProc =  my-handle .

{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable v_os-file         as char             no-undo.
define var rid-list as char no-undo.

define buffer buf_cash-pay for ub.cash-pay .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartFrame
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER FRAME

&Scoped-define ADM-SUPPORTED-LINKS Data-Target,Data-Source,Page-Target,Update-Source,Update-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fMain

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-cd-pay b-file v-rep-type   
&Scoped-Define DISPLAYED-OBJECTS v-cp-name v-cp-code b-cd-pay b-file v-rep-type v-file

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cd-pay DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     size 2.5 by 1.08.
     
DEFINE BUTTON b-file DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     size 2.5 by 1.08.
   

DEFINE VARIABLE v-cp-name as character   FORMAT "X(50)":U
     VIEW-AS fill-in
     SIZE 25 BY 1 no-undo  .

DEFINE VARIABLE v-cp-code as integer format ">>>>>9"
     VIEW-AS fill-in
     SIZE 6 BY 1 no-undo label "Тип кассового платежа"  .

DEFINE VARIABLE v-rep-type AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET
     RADIO-BUTTONS
          "Юр. лица", 1,
          "Физ. лица", 2
     SIZE 20 BY 2 no-undo label "Тип сверки" .
     
DEFINE VARIABLE v-file as character  FORMAT "X(256)":U
     VIEW-AS fill-in
     SIZE 60 BY 1 no-undo  .     

DEFINE VARIABLE v-RRN as character  FORMAT "X(25)":U
     VIEW-AS fill-in
     SIZE 30 BY 1 no-undo  .
     

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fMain
     v-cp-code AT ROW 1 COL 4 WIDGET-ID 2
     v-cp-name AT ROW 1 COL 35 WIDGET-ID 2 no-label
     b-cd-pay at row 1 col 65
     v-rep-type at row 2.5 col 4
     "Файл транзакций для сверки:" view-as text at row 5 col 4 
     v-file at row 6 col 4 no-label 
     b-file at row 6 col 65
     "RRN для сверки:" view-as text at row 8 col 4
     v-RRN at row 7.9 col 21 no-label
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 70 BY 16.42 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartFrame
   Allow: Basic,Browse,DB-Fields,Query,Smart
   Container Links: Data-Target,Data-Source,Page-Target,Update-Source,Update-Target
   Other Settings: PERSISTENT-ONLY APPSERVER
 */

/* This procedure should always be RUN PERSISTENT.  Report the error,  */
/* then cleanup and return.                                            */
IF NOT THIS-PROCEDURE:PERSISTENT THEN DO:
  MESSAGE "{&FILE-NAME} should only be RUN PERSISTENT.":U
          VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
END.

&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW fFrameWin ASSIGN
         HEIGHT             = 16.42
         WIDTH              = 64.13.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "SmartFrameCues" fFrameWin _INLINE
/* Actions: adecomm/_so-cue.w ? adecomm/_so-cued.p ? adecomm/_so-cuew.p */
/* SmartFrame,ab,49268
Destroy on next read */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB fFrameWin 
/* ************************* Included-Libraries *********************** */
{ src/adm/method/viewer.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW fFrameWin
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME fMain
   NOT-VISIBLE FRAME-NAME                                               */
ASSIGN 
          FRAME FMain:SCROLLABLE       = FALSE
       FRAME FMain:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fMain
/* Query rebuild information for FRAME fMain
     _Options          = ""
     _Query            is NOT OPENED
*/  /* FRAME fMain */
&ANALYZE-RESUME

 

/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME v-rep-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-rep-type Fmain
ON VALUE-CHANGED OF v-rep-type IN FRAME FMain
DO:
  assign v-rep-type .
END.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME v-RRN
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-RRN Fmain
ON VALUE-CHANGED OF v-RRN IN FRAME FMain
DO:
  assign v-RRN .
END.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-file s-object
ON CHOOSE OF b-file IN FRAME FMain
DO:

    DEF VAR ll_commit AS LOG NO-UNDO INIT NO.

    SYSTEM-DIALOG GET-FILE v_os-file
      TITLE "Выберите файл для импорта"
      FILTERS "EXCEL файл (*.xlsx)" "*.xlsx",
      "EXCEL файл (*.xls)" "*.xls",
      "Все файлы (*.*)"        "*.*"
      MUST-EXIST
      USE-FILENAME
      update ll_commit
      default-extension "xlsx"
      .
    IF ll_commit <> YES THEN 
    do:
      RETURN NO-APPLY.
    end.
    IF v_os-file = PROGRAM-NAME( 1 ) THEN 
    DO:
      BELL.
      MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
      RETURN NO-APPLY.
    END.
    ASSIGN 
      v-file = ( IF SEARCH( v_os-file ) = ? THEN v_os-file ELSE SEARCH( v_os-file ) ).
    display v-file with frame {&frame-name}.
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME b-cd-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cd-pay s-object
ON CHOOSE OF b-cd-pay IN FRAME FMain
DO:
  run ref/cashpays.w (
                   input my-handle
                  ,input "b-sel":U
                  ,input {&all}
                  ,input v-cntxt-host-code-obj
                  ,input v-cntxt-obj-type
                  ,input v-cntxt-obj-code
                  ,output rid-list) no-error.
  if rid-list = "" then return no-apply.
  find first buf_cash-pay no-lock where recid(buf_cash-pay) = integer(rid-list) .
  assign
    v-cp-code = buf_cash-pay.cdpay-code
    v-cp-name = buf_cash-pay.obj-name
  .
  display v-cp-code v-cp-name with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    
    
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK fFrameWin 


/* ***************************  Main Block  *************************** */

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
   /* Now enable the interface  if in test mode - otherwise this happens when
      the object is explicitly initialized from its container. */
 RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects fFrameWin  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI fFrameWin  _DEFAULT-DISABLE
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
  HIDE FRAME fMain.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI fFrameWin  _DEFAULT-ENABLE
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
  DISPLAY v-cp-name v-cp-code b-cd-pay v-rep-type v-file b-file v-RRN 
      WITH FRAME fMain.
  ENABLE  b-cd-pay b-file v-rep-type v-RRN 
      WITH FRAME fMain.
  {&OPEN-BROWSERS-IN-QUERY-fMain}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
PROCEDURE my-report :
   find first ub.cash-pay no-lock where recid(ub.cash-pay) = integer(rid-list) no-error .
   if not available ub.cash-pay
   then do :
     message "Выберите тип платежа." view-as alert-box .
     return .
   end .
   if search(v-file) = ? or trim(v-file) = ""
   then do :
     message "Выберите файл транзакций для сверки." view-as alert-box .
     return .
   end .
   
   v-RRN = trim(v-RRN) .
   if v-RRN > ""
   then do :
     int64(v-RRN) no-error .
     if error-status:error
     then do :
       message "Неверный формат RRN!" view-as alert-box .
       return .
     end .
   end .
     
   run rep/r-yandex-rep.p
    (
      input parParentProc,
      input rid-list,
      input v-rep-type,
      input v-file,
      input v-RRN
    ) .
END PROCEDURE.
    
PROCEDURE My-var :
    
    assign
    ReportHeader = "Сверка по транзакциям Яндекс".
    
end procedure.