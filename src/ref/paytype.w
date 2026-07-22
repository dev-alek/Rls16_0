&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-pay-type


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER X_pay-type FOR ub.pay-type.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-pay-type
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник видов платежей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 20/04/95
Author: Bakhtadze Natalya
Creation date: 20/04/95

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter  parparentproc as widget-handle no-undo .
define input parameter  bttns         as character   no-undo .
define output parameter p-rid-list    as character no-undo   .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник видов платежей".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ cmp/mrk-strf.i }

/* Local Variable Definitions ---                                       */

define variable log-res as log no-undo.
define variable rr as recid no-undo.
define variable v_type as char no-undo.
define variable v-is-deploy as logical no-undo .
define variable v-rid-list as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-pay-type
&Scoped-define BROWSE-NAME br-paytype

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_pay-type

/* Definitions for BROWSE br-paytype                                    */
&Scoped-define FIELDS-IN-QUERY-br-paytype mark-string(recid(X_pay-type), v-rid-list) X_pay-type.obj-code X_pay-type.obj-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-paytype
&Scoped-define SELF-NAME br-paytype
&Scoped-define QUERY-STRING-br-paytype FOR EACH X_pay-type NO-LOCK     BY X_pay-type.obj-name
&Scoped-define OPEN-QUERY-br-paytype OPEN QUERY {&SELF-NAME} FOR EACH X_pay-type NO-LOCK     BY X_pay-type.obj-name.
&Scoped-define TABLES-IN-QUERY-br-paytype X_pay-type
&Scoped-define FIRST-TABLE-IN-QUERY-br-paytype X_pay-type


/* Definitions for DIALOG-BOX d-pay-type                                */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-pay-type ~
    ~{&OPEN-QUERY-br-paytype}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-mark b-sel b-add b-upd b-doc ~
b-print b-hist b-help br-paytype

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1.

DEFINE BUTTON b-doc
     LABEL "Доку&менты"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.

DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 3 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-upd
     LABEL "&Изменить":L
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-paytype FOR
      X_pay-type SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-paytype
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-paytype d-pay-type _FREEFORM
  QUERY br-paytype NO-LOCK DISPLAY
      mark-string(recid(X_pay-type), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_pay-type.obj-code FORMAT "99999":U
      X_pay-type.obj-name FORMAT "X(40)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 51 BY 13.77.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-pay-type
     b-exit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 14
     b-add AT ROW 1 COL 24
     b-upd AT ROW 1 COL 34
     b-doc AT ROW 1 COL 44
     b-print AT ROW 1 COL 65
     b-hist AT ROW 1 COL 68
     b-help AT ROW 1 COL 71
     br-paytype AT ROW 4 COL 3
     SPACE(26.39) SKIP(0.79)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "ВИДЫ  ОПЛАТЫ":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: X_pay-type B "NEW SHARED" ? ub pay-type
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-pay-type
   FRAME-NAME                                                           */
/* BROWSE-TAB br-paytype b-help d-pay-type */
ASSIGN
       FRAME d-pay-type:SCROLLABLE       = FALSE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-paytype
/* Query rebuild information for BROWSE br-paytype
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_pay-type NO-LOCK
    BY X_pay-type.obj-name.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _OrdList          = "ub.pay-type.obj-name|yes"
     _Query            is OPENED
*/  /* BROWSE br-paytype */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-pay-type
/* Query rebuild information for DIALOG-BOX d-pay-type
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-pay-type */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-pay-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-pay-type d-pay-type
ON GO OF FRAME d-pay-type /* ВИДЫ  ОПЛАТЫ */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-pay-type
ON CHOOSE OF b-add IN FRAME d-pay-type /* Добавить */
DO:
define variable glog as logical no-undo .
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_payments_update':U
{&cntxt-global}
0
'':U
0
0
0
0
true
glog
}
if NOT glog then  return no-apply .

run ref/paytypei.w
              (  input parparentproc
                , input {&add-def}
                , input-output rr ).
if rr <> ? then do:
  {&open-query-br-paytype}
  reposition br-paytype to recid rr.
  log-res  = br-paytype:select-focused-row( ).
  apply "ENTRY":U to br-paytype.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-doc d-pay-type
ON CHOOSE OF b-doc IN FRAME d-pay-type /* Документы */
DO:
DEFINE VARIABLE loc-ref-list as character no-undo.
define variable v-input-output as character no-undo .
define variable v-list-mode as character no-undo .

  if available X_pay-type THEN do:
    v-list-mode = "ОПЛАТА".
    run str/all-docs.w
    ( input  parparentproc
    ,input  ?
    ,input  ?
    ,input  ?
    ,input  v-list-mode
    ,input  ?
    ,input  ?
    ,input  ?
    ,input  ?
    ,input  "":U
    ,input  ?
    ,input  false
    ,input  recid( X_pay-type )
    ,output loc-ref-list
    ).

    apply "entry" to br-paytype.
    disp X_pay-type.obj-name with browse br-paytype.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist d-pay-type
ON CHOOSE OF b-hist IN FRAME d-pay-type /* История */
DO:
define variable v-rid-list as character no-undo .
  if available X_pay-type THEN  do:
      run ref/cpaytyps.w
              ( Input Parparentproc
              , Input '':U /*Bttns*/
              , Input 'One':U
              , Input X_pay-type.Obj-code
              , Input-output V-rid-list
              ) No-error.

  end.
  apply "entry" to br-paytype.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark d-pay-type
ON CHOOSE OF b-mark IN FRAME d-pay-type /* * */
DO:
 define variable g-log as logical no-undo.
 if available X_pay-type then do:
        { gbl/markstrn.i X_pay-type v-rid-list }

        g-log = {&browse-name}:refresh() .
        if last-event:function <> "mouse-select-dblclick" then do:
            g-log = {&browse-name}:select-next-row ().
            apply "value-changed" to {&browse-name} in frame {&frame-name}.
        end.

    end.
    apply "entry" to {&browse-name} in frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print d-pay-type
ON CHOOSE OF b-print IN FRAME d-pay-type /* Печать */
DO:
    define variable sym1 as char init ":"   no-undo.
    define variable sym2 as char init ":"   no-undo.
    define variable sym3 as char init ":"   no-undo.

    define variable Line                    as char         no-undo.

    define variable ii      as integer   no-undo.
    define variable StartRecid      as integer   no-undo.

    DEFINE FRAME List
    sym1 column-label ":" format "x(1)"
    X_pay-type.obj-code column-label "Код оплаты" format ">>>>>>>>>9"
    sym2 column-label ":" format "x(1)"
    X_pay-type.obj-name column-label "Наименование" format "x(80)"
    sym3 column-label ":" format "x(1)"
    HEADER
    cur-time-print() AT 5 format "X(35)"
    string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>9") )
    AT 66 format "X(15)" SKIP
    Line format "x(97)" AT 1
    with width {&A4_CW} down use-text stream-io no-box .

    if num-results( "br-paytype" ) = 0 then do:
      message
      "Список  П У С Т !"
      skip
      view-as alert-box information .
      return no-apply .
    end.

    if session:set-wait-state( "compiler" ) then .
    Line = fill( "-" , 100 ) .
/*
    Это из-за того, что в QUERY br-paytype используется index reposition и,
    как следствие, не работает GET first br-paytype  ( ошибка 3157 )
*/
    StartRecid = recid( X_pay-type ) .
    DO WHILE available X_pay-type :
        GET prev br-paytype NO-LOCK .
    END.
    GET next br-paytype NO-LOCK .
    ii = 1 .

    run prn-lib-open-stream  in this-procedure (
                                                 input parParentProc
                                                ,input {&CS_PS}
                                                ,input yes /*p-is-stream*/
                                                ,input no /*p-append*/
                                                ).

    FORM HEADER
                Line format "X(130)" SKIP
                "Продолжение - на следующей странице" AT 30 SKIP
                with FRAME CliBottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS no-box.
    VIEW stream PrnLibStream FRAME CliBottomFrame .
    PUT stream PrnLibStream space(30)
    "С П И С О К   В И Д О В   О П Л А Т Ы" format "X(100)" SKIP(2) .
    FORM with frame List .
    DO WHILE available X_pay-type :
        DISPLAY stream PrnLibStream
                        sym1 X_pay-type.obj-code sym2 X_pay-type.obj-name sym3 with frame List .
        DOWN stream PrnLibStream 1 with frame List .
        ii =  ii + 1 .
        if ( ( ii modulo 10 ) = 0 ) AND ( ii >= 10 ) then
        run waitfram-show in this-procedure ( "Просмотрено строк : " + string( ii ) ) .
        GET next br-paytype .
    END.
    run waitfram-hide in this-procedure .
    PUT stream PrnLibStream Line format "X(97)" SKIP.
    HIDE stream PrnLibStream FRAME CliBottomFrame .
    output stream PrnLibStream close .
    run prn-lib-prn-file in this-procedure (
                                              input parParentProc
                                              ,input 0
                                              ).
    reposition br-paytype to recid StartRecid .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-pay-type
ON CHOOSE OF b-sel IN FRAME d-pay-type /* Выбор  */
DO:
    if ( available X_pay-type )
    AND ( v-rid-list = "" or b-mark:sensitive = no ) then
    v-rid-list = string( recid( X_pay-type ) ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-upd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-upd d-pay-type
ON CHOOSE OF b-upd IN FRAME d-pay-type /* Изменить */
DO:
define variable glog as logical no-undo .
  if not available X_pay-type THEN  return no-apply.
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_payments_update':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  glog
  }
  if NOT glog then  return no-apply .
  rr = recid( X_pay-type ).
  run ref/paytypei.w
                  ( input parparentproc
                  , input {&update}
                  , input-output rr
                  ).
  disp X_pay-type.obj-name with browse br-paytype.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-paytype
&Scoped-define SELF-NAME br-paytype
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-paytype d-pay-type
ON DEFAULT-ACTION OF br-paytype IN FRAME d-pay-type
DO:
  case yes:
      when  b-sel:sensitive THEN apply "CHOOSE":U to b-sel.
      when  b-upd:sensitive THEN apply "CHOOSE":U to b-upd.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-paytype d-pay-type
ON INSERT-MODE OF br-paytype IN FRAME d-pay-type
DO:
  if b-mark:sensitive in frame {&frame-name} then
     APPLY "CHOOSE" to b-mark.
  else do:
      if b-sel:sensitive in frame {&frame-name} then
      APPLY "CHOOSE" to b-sel.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-paytype d-pay-type
ON RETURN OF br-paytype IN FRAME d-pay-type
DO:
  apply "DEFAULT-ACTION":U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-pay-type


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if lookup('s-deploy', bttns) > 0 then do:
    assign
    v-is-deploy = yes.
  end.
  { gbl/getcntxt.i get }
  run enable_UI in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus {&browse-name}.
END.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-pay-type  _DEFAULT-DISABLE
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
  HIDE FRAME d-pay-type.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-pay-type
PROCEDURE enable_UI :
/* --------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
   -------------------------------------------------------------------- */
  ENABLE
      br-paytype
      b-exit
      b-sel WHEN can-do( bttns, "b-sel" )
      b-mark WHEN can-do( bttns, "b-mark" )
      b-add WHEN can-do( bttns, "b-add" ) AND v-cntxt-db-num = 0
      b-upd WHEN can-do( bttns, "b-upd" ) AND v-cntxt-db-num = 0
      b-doc WHEN can-do( bttns, "b-doc" ) and not v-is-deploy
      b-print when not v-is-deploy
      b-hist when not v-is-deploy
      b-help
      WITH FRAME {&frame-name}.
  {&OPEN-BROWSERS-IN-QUERY-d-pay-type}
  if available X_pay-type
  then log-res  = br-paytype:select-focused-row( ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME