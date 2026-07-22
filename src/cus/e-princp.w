&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS F-Frame-Win
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет по сумме кассовых услуг, оказанных принципиалу - форма

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/06/03
Author: Bakhtadze Natalya
Creation date: 06/06/03

------------------------------------------------------------------------*/
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
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет по сумме кассовых услуг, оказанных принципиалу - форма".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/showinf.i }
{ cmp/r-page1.i }
define variable parparentproc as widget-handle no-undo .
{ gbl/getcntxt.i def }
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-host-name like ub.clients.obj-name no-undo .

&scop check-principial    FIND FIRST buf_gds-prt No-LOCK WHERE ~
              buf_gds-prt.upper-code = gds-list.prt-root.  ~
    if not buf_gds-prt.node-name = {&empty-scale} then do:  ~
      message ~
      "Принципал не может быть отождествлен со шкальным товаром" ~
      "Товар-" gds-list.artic gds-list.prod-type gds-list.prod-code skip ~
      gds-list.gds-name ~
      view-as alert-box ERROR. ~
      v-to-del = yes. ~
    end. ~
    if not v-to-del then do: ~
      find first buf_units No-LOCK WHERE ~
                buf_units.unit-name = gds-list.unit-base . ~
      if lookup({&serial}, buf_units.type ) > 0 then do: ~
        message ~
        "Принципал не может быть отождествлен с серийным товаром" ~
        "Товар-" gds-list.artic gds-list.prod-type gds-list.prod-code skip ~
        gds-list.gds-name ~
        view-as alert-box ERROR. ~
        v-to-del = yes. ~
      end. ~
    end.

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
&Scoped-Define ENABLED-OBJECTS RECT-SLT T-SLT-sum
&Scoped-Define DISPLAYED-OBJECTS T-SLT-sum

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE f-slt-pc AS DECIMAL FORMAT ">9.99":U INITIAL 5
     VIEW-AS FILL-IN
     SIZE 17.88 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-SLT
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 25.63 BY 4.46.

DEFINE VARIABLE T-SLT-sum AS LOGICAL INITIAL no
     LABEL "в том числе НсП"
     VIEW-AS TOGGLE-BOX
     SIZE 18.13 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     T-SLT-sum AT ROW 3.29 COL 4.38
     f-slt-pc AT ROW 4.75 COL 4 NO-LABEL
     RECT-SLT AT ROW 2.33 COL 2
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 77.88 BY 17.13.


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
         HEIGHT             = 17.13
         WIDTH              = 77.88.
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
/* SETTINGS FOR FILL-IN f-slt-pc IN FRAME F-Main
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN
       f-slt-pc:HIDDEN IN FRAME F-Main           = TRUE.

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

&Scoped-define SELF-NAME T-SLT-sum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-SLT-sum F-Frame-Win
ON VALUE-CHANGED OF T-SLT-sum IN FRAME F-Main /* в том числе НсП */
DO:
  assign
  T-SLT-sum.
  CASE T-SLT-sum:
    when no then do:
      disable
      f-slt-pc
      with frame {&frame-name} .
      hide
        f-slt-pc
        in frame {&frame-name}.
    end.
    when yes then do:
      view
      f-slt-pc in frame {&frame-name}.
      display
            5 @ f-slt-pc
            with frame {&frame-name} .
      enable
      f-slt-pc
      with frame {&frame-name} .
    end.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
parparentproc = my-handle.
{ gbl/getcntxt.i get }
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
  DISPLAY T-SLT-sum
      WITH FRAME F-Main.
  ENABLE RECT-SLT T-SLT-sum
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
DEFINE VARIABLE v-report-header as character no-undo .
DEFINE VARIABLE v-frame-width as integer no-undo .
DEFINE VARIABLE v-to-del as logical no-undo .
define buffer buf_gds-prt for ub.gds-prt.
define buffer buf_units for ub.units .
find first gds-list no-error .
if NOT avail gds-list then do:
    message "Не выбран принципиал"
    view-as alert-box ERROR.
    return.
end.

CASE x-SelectGood:
  when 5 then do:
    assign
    v-to-del = no
    .
    {&check-principial}
    if v-to-del then do:
      return.
    end.
    assign
    ReportHeader = "":U
    ReportName = v-host-name
    str1 =  "Акт выполненных работ по агентскому договору" + {&space-char} +
            (if available gds-list
              then ("(принципиал" + {&space-char} + gds-list.gds-name + ")":U)
              else "( принципиал не определен) ")
    str2 =    "За период с" + {&space-char} + string(X-date-start, "99/99/9999") + {&space-char}  +
              "по" + {&space-char} + string(X-date-end, "99/99/9999")

    str3 = "":U
    v-report-header = ReportName + {&new-line} +
                      str1 + {&new-line} +
                      str2 + {&new-line} +
                      str4
                      .
    run cus/r-princp.p (
                   input my-handle
                  ,input v-cntxt-host-code-obj
                  ,input gds-list.gds-code
                  ,input T-SLT-sum
                  ,input f-slt-pc
                  ,input v-report-header
                  ,output v-frame-width
                  ).

  end.
  when 4 then do:
    for each gds-list:
      assign
      v-to-del = no
      .
      {&check-principial}
      if v-to-del then do:
        message
        "Пропускаю товар"
        view-as alert-box .
        delete gds-list.
      end.
    end.
    if not can-find(first gds-list) then do:
      message "Не выбран принципиал"
      view-as alert-box ERROR.
      return.
    end.
    { gbl/hostname.i v-cntxt-obj-type v-cntxt-obj-code v-host-code v-host-name }
    assign
    ReportHeader = "":U
    ReportName = v-host-name
    str1 =  "Акт выполненных работ по агентскому договору"
    str2 =    "За период с" + {&space-char} + string(X-date-start, "99/99/9999") + {&space-char}  +
              "по" + {&space-char} + string(X-date-end, "99/99/9999")
    str3 = "":U
    v-report-header = ReportName + {&new-line} +
                      str1 + {&new-line} +
                      str2 + {&new-line} +
                      str4
                      .
    run cus/r-princl.p (
                   input my-handle
                  ,input v-cntxt-host-code-obj
                  ,input T-SLT-sum
                  ,input f-slt-pc
                  ,input v-report-header
                  ,output v-frame-width
                  ).
  end.
END CASE.


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
Assign
frame {&frame-name} T-SLT-sum
frame {&frame-name} f-slt-pc
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
Reportname = "Отчет по сумме кассовых услуг, оказанных агентом" + {&space-char} + "принципиалу".
ReportHeader =
                (if available gds-list
                  then gds-list.gds-name
                  else "( принципиал не определен) ") +
                {&New-line} +
                (if T-SLT-sum
                                then ("(в том числе с НсП" + {&space-char} +  string(f-slt-pc, ">9.99%") + ")")
                                else "":U)
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