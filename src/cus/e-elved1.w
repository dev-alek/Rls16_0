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

Сводная ведомость по клиентам

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
define variable vss-description as character no-undo init "Сводная ведомость по клиентам" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ cmp/operlist.i }
{ cmp/breakstr.i }
{ gbl/waitfram.i }
{ cmp/cli-list.i cli-list def "new shared" }
{ cus/e-elvd1d.i "NEW SHARED" }
define variable parparentproc as widget-handle no-undo .
{ gbl/getcntxt.i def }
{ rep/lhstprex.i cli-list-hist  "'клиентов'" }
{ ref/extclass.i }

define variable State-source as Widget-handle no-undo.

define variable StrBuf              as character         no-undo.
define variable Line            as character         no-undo.

define variable sym1            as character   init ":"      no-undo.
define variable sym2            as character   init ":"      no-undo.
define variable sym3            as character   init ":"      no-undo.

define variable ii                      as  integer     no-undo.
define variable i as integer no-undo.
define variable namebuf1     as      character    no-undo.
define variable namebuf2     as      character    no-undo.
define variable cliMode as character no-undo init "ALL".
define variable v-curr-r-b as character no-undo .

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
&Scoped-Define ENABLED-OBJECTS RECT-client selectcli t-zero
&Scoped-Define DISPLAYED-OBJECTS selectcli t-zero

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE selectcli AS CHARACTER INITIAL "ALL"
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", "All":U,
"Выборочно по клиентам", "LIST":U
     SIZE 29 BY 2.71 NO-UNDO.

DEFINE RECTANGLE RECT-client
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 32.38 BY 6.92.

DEFINE VARIABLE t-zero AS LOGICAL INITIAL no
     LABEL "Выводить нулевые обороты"
     VIEW-AS TOGGLE-BOX
     SIZE 28 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     selectcli AT ROW 2.29 COL 3 NO-LABEL
     t-zero AT ROW 6 COL 3.5
     "Покупатели:" VIEW-AS TEXT
          SIZE 28 BY .96 AT ROW 1.33 COL 3
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
         HEIGHT             = 15.25
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

&Scoped-define SELF-NAME selectcli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL selectcli F-Frame-Win
ON VALUE-CHANGED OF selectcli IN FRAME F-Main
DO:
  assign selectcli.
  CASE selectcli:
    when "LIST":U then do:
      run str/cli-list.w ( input my-handle
                      ,input v-cntxt-host-code-obj
                      ,input v-cntxt-obj-type
                      ,input v-cntxt-obj-code).
      assign
      cliMode = "LIST":U
      .
      find first cli-list no-lock no-error .
      if not available cli-list then do:
        message
        "В списке клиентов нет ни одного клиента"
        view-as alert-box WARNING.
        assign
        selectcli = "all":U
        cliMode  = "ALL":U
        .
      end. /* if not avail:*/
    end.  /*selective*/
    when "all":U then do:
      assign
      cliMode = "ALL":U
      .
    end.
 END CASE.
 display selectcli with frame {&frame-name}.
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
  DISPLAY selectcli t-zero
      WITH FRAME F-Main.
  ENABLE RECT-client selectcli t-zero
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
define buffer buf_dis-card for ub.dis-card.
define buffer buf_ext-classif for ub.ext-classif.
define buffer buf_clients for ub.clients.

DEFINE FRAME X123
sym1 column-label ":!:" format "X(1)"
dcards.cli-name column-label "Наименование организации" format "X(105)"
sym2 column-label ":!:" format "X(1)"
dcards.sum column-label "Реализация, {&abbr_rub}" format "->,>>>,>>>,>>9.99"
sym3 column-label ":!:" format "X(1)"
HEADER
cur-time-print() AT 5 format "x(35)"
"Страница " AT 100 PAGE-NUMBER( PrnLibStream ) AT 110 FORMAT ">>>>9" SKIP
Line format "X(134)" AT 1
with width {&A4_CW0} down stream-io use-text .
assign
sheetf.Excel-Column-Lable =
"Наименование организации" + {&comma-char} +
"Реализация {&abbr_rub}"
sheetf.sizes =
"105" + {&comma-char} +
"16"
str3 = " "
.

assign
frame {&frame-name} selectcli
.
run My-var IN THIS-PROCEDURE.
run waitfram-show in this-procedure ( "Подождите ..." ) .

CASE cliMode:
  when "ALL":U then do:
      run cus/e-elvd1q.p (
                      input "ALL":U
                    ,input X-date-Start
                    ,input X-date-End
                    )
              .
  end.
  when "LIST":U then do:
      run cus/e-elvd1q.p (
                      input "LIST":U
                      ,input X-date-Start
                      ,input X-date-End
                      )
              .
  end.
end.

run waitfram-hide in this-procedure .
if can-find( first dcards ) then do:
    run rep/extitle.p ( input 1 ).
    run prn-lib-open-stream  in this-procedure (
                                                 input my-handle
                                                ,input {&CS_PS}
                                                ,input yes /*p-is-stream*/
                                                ,input no /*p-append*/
                                                ).
    Line = fill( "-", 134 ) .
    FORM HEADER
    Line format "X(134)" AT 1 SKIP
    "Продолжение - на следующей странице" AT 30 SKIP
    with FRAME BottomFrame width {&A4_CW0} PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW stream PrnLibStream FRAME BottomFrame .

    PUT stream PrnLibStream
    space(40)
    "Сводный баланс" skip
    space(40) str1 format "X(110)" skip(0).
    PUT stream PrnLibStream "" skip .
    CASE cliMode:
      when "ALL":U then do:
        PUT stream PrnLibStream space(20) "По ВСЕМ клиентам." format "x(40)" skip.
      end.
      when "LIST" then do:
       PUT stream PrnLibStream space(10) string("По сформированному списку клиентов") format "x(50)" .
       ii = 0.
       for each cli-list no-lock:
          ii = ii + 1.
       end.
       PUT stream PrnLibStream unformatted substitute("В списке &1 кл.", ii) skip.
     end.
    END CASE.
    form with frame X123.
    _clients:
    FOR EACH buf_clients no-lock
    by buf_clients.obj-name:
      if climode = "LIST" then do:
        find first cli-list no-lock where
                  cli-list.obj-type = buf_clients.obj-type
              and cli-list.obj-code = buf_clients.obj-code no-error .
        if not available cli-list then next _clients.
      end.
      find first dcards no-lock where
          dcards.cli-type = buf_clients.obj-type
      and dcards.cli-code = buf_clients.obj-code no-error .
      if available dcards then do:
        assign
        accum-sum-cli      = accum-sum-cli + dcards.sum
        .
        DISPLAY stream PrnLibStream
        sym1
        dcards.cli-name
        sym2
        dcards.sum
        sym3
        with frame X123.
        down 1 stream prnlibstream
        with frame X123.
        {&PutExcel}
        dcards.cli-name {&tabulation}
        dcards.sum
        skip.
      end.
      else do:
        IF t-zero THEN DO:
          /* 03/14/12 Modified by Samkov */
          if not can-find( first buf_dis-card no-lock
                             where buf_dis-card.cli-type = buf_clients.obj-type
                               and buf_dis-card.cli-code = buf_clients.obj-code )
          then
            next _clients.
          /* 03/14/12 Samkov E n d of changes */
          DISPLAY stream PrnLibStream
          sym1
          buf_clients.obj-name @ dcards.cli-name
          sym2
          0.0 @ dcards.sum
          sym3
          with frame X123.
          down 1 stream prnlibstream
          with frame X123.
          {&PutExcel}
          buf_clients.obj-name {&tabulation}
          0.0
          skip.
        END.
      end.
    end.
    UNDERLINE stream PrnLibStream
    dcards.cli-name
    dcards.sum
    with frame X123 .
    DISPLAY stream PrnLibStream
    sym1
    "ИТОГО" @ dcards.cli-name
    sym2
    accum-sum-cli  @ dcards.sum
    sym3
    with frame X123.
    {&PutExcel}
    "ИТОГО" {&tabulation}
    accum-sum-cli
    skip.

    HIDE stream PrnLibStream FRAME BottomFrame .
    if Print-List-hist
    and selectcli = 'LIST' then do:
      run lhistprex-print-cli-list-hist-excel  in this-procedure (input yes, input yes, 2).
    end.
    output stream PrnLibStream CLOSE .
     {&CloseExcel}
   run prn-lib-prn-file in this-procedure (
                                          input my-handle
                                          ,input 0
                                          ).

end.
else
message
"На выбранных Вами объектах" skip
"не было продаж постоянным клиентам" skip
"в течение заданного Вами периода времени."
view-as alert-box INFORMATION .
FOR EACH dcards :
    delete dcards .
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-Var F-Frame-Win
PROCEDURE My-Var :
assign
frame {&frame-name} selectcli
t-zero
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
Reportname = "Сводная ведомость по клиентам".
ReportHeader = SUBSTITUTE("&1", IF t-zero = NO THEN "Нулевые обороты не выводятся" ELSE '':U) + {&NEW-LINE} +
    "Клиенты: " +
                           radio-label(string(selectcli), selectcli:radio-buttons) + {&New-line}

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