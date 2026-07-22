&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Утилита перевыгрузки пакета для Oracle

Автор: Хныкин Павел Андреевич
Дата создания: 11/16/09
Author: Pavel Khnykin
Creation date: 11/16/09

*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc as handle    no-undo .

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Утилита перевыгрузки пакета для Oracle".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }
{ cmp/library.i  }
{ bge/bge-xml.i  }


define temp-table tt-docs no-undo
  field doc-type as character
  field doc-code as character
  field obj-type as character
  field obj-code as integer
  field pck-code as integer
  field is-sel   as logical
index pi as primary unique
  doc-type
  doc-code
index sel
  is-sel
  pck-code
.

define buffer buf_tt-docs for tt-docs.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-docs

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_tt-docs

/* Definitions for BROWSE br-docs                                       */
&Scoped-define FIELDS-IN-QUERY-br-docs display-selected(BUFFER buf_tt-docs) buf_tt-docs.doc-type buf_tt-docs.doc-code buf_tt-docs.pck-code   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-docs   
&Scoped-define SELF-NAME br-docs
&Scoped-define QUERY-STRING-br-docs FOR EACH buf_tt-docs
&Scoped-define OPEN-QUERY-br-docs OPEN QUERY {&SELF-NAME} FOR EACH buf_tt-docs.
&Scoped-define TABLES-IN-QUERY-br-docs buf_tt-docs
&Scoped-define FIRST-TABLE-IN-QUERY-br-docs buf_tt-docs


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-docs}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-mark b-help RECT-1 fi-doc-code ~
fi-pck-code br-docs b-start 
&Scoped-Define DISPLAYED-OBJECTS fi-doc-code fi-pck-code 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD display-selected Dialog-Frame 
FUNCTION display-selected RETURNS CHARACTER
  ( BUFFER loc_tt-docs FOR tt-docs )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit 
     LABEL "Выход" 
     SIZE 10 BY 1.

DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1.

DEFINE BUTTON b-mark 
     LABEL "&*" 
     SIZE 3 BY 1.

DEFINE BUTTON b-start 
     LABEL "Выгрузить" 
     SIZE 10 BY 1.

DEFINE VARIABLE fi-doc-code AS CHARACTER FORMAT "X(256)":U 
     LABEL "Код документа" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE fi-pck-code AS INTEGER FORMAT ">>>>>>>>>9":U INITIAL 0 
     LABEL "Код пакета" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 77.5 BY 11.5.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-docs FOR 
      buf_tt-docs SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-docs Dialog-Frame _FREEFORM
  QUERY br-docs DISPLAY
      display-selected(BUFFER buf_tt-docs) FORMAT "X(1)" COLUMN-LABEL "*"
      buf_tt-docs.doc-type FORMAT "X(10)" COLUMN-LABEL "Тип документа"
      buf_tt-docs.doc-code FORMAT "X(18)" COLUMN-LABEL "Код документа"
      buf_tt-docs.pck-code FORMAT ">>>>>>>>>9" COLUMN-LABEL "Номер пакета"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 76 BY 9.75 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1 WIDGET-ID 2
     b-mark AT ROW 1 COL 11 WIDGET-ID 28
     b-help AT ROW 1 COL 66 WIDGET-ID 30
     fi-doc-code AT ROW 3 COL 15 COLON-ALIGNED WIDGET-ID 18
     fi-pck-code AT ROW 3 COL 49.5 COLON-ALIGNED WIDGET-ID 20
     br-docs AT ROW 4.5 COL 2 WIDGET-ID 200
     b-start AT ROW 14.5 COL 67.5 WIDGET-ID 26
     RECT-1 AT ROW 4.25 COL 1 WIDGET-ID 10
     SPACE(0.24) SKIP(0.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Выгрузить" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-docs fi-pck-code Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-docs
/* Query rebuild information for BROWSE br-docs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_tt-docs.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-docs */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Выгрузить */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
  apply "go":U to frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
  run proc-b-mark in this-procedure no-error .
  if error-status :error = yes
  then do:
    message
      "":U
      return-value skip
      error-status :get-message(1) skip
      error-status :get-message(2) skip
    view-as alert-box error.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-start Dialog-Frame
ON CHOOSE OF b-start IN FRAME Dialog-Frame /* Выгрузить */
DO:
  run proc-b-start in this-procedure no-error .
  if error-status :error = yes
  then do:
    message
      "":U
      return-value skip
      error-status :get-message(1) skip
      error-status :get-message(2) skip
    view-as alert-box error.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-doc-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-doc-code Dialog-Frame
ON LEAVE OF fi-doc-code IN FRAME Dialog-Frame /* Код документа */
DO:
/*  run proc-doc-code in this-procedure no-error .*/
/*  if error-status :error = yes*/
/*  then do:*/
/*    message*/
/*      "":U*/
/*      return-value skip*/
/*      error-status :get-message(1) skip*/
/*      error-status :get-message(2) skip*/
/*    view-as alert-box error.*/
/*    return no-apply.*/
/*  end.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-doc-code Dialog-Frame
ON RETURN OF fi-doc-code IN FRAME Dialog-Frame /* Код документа */
DO:
  run proc-doc-code in this-procedure no-error .
  if error-status :error = yes
  then do:
    message
      "":U
      return-value skip
      error-status :get-message(1) skip
      error-status :get-message(2) skip
    view-as alert-box error.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-pck-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-pck-code Dialog-Frame
ON LEAVE OF fi-pck-code IN FRAME Dialog-Frame /* Код пакета */
DO:
/*  run proc-pck-code in this-procedure no-error .*/
/*  if error-status :error = yes*/
/*  then do:*/
/*    message*/
/*      "":U*/
/*      return-value skip*/
/*      error-status :get-message(1) skip*/
/*      error-status :get-message(2) skip*/
/*    view-as alert-box error.*/
/*    return no-apply.*/
/*  end.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-pck-code Dialog-Frame
ON RETURN OF fi-pck-code IN FRAME Dialog-Frame /* Код пакета */
DO:
  run proc-pck-code in this-procedure no-error .
  if error-status :error = yes
  then do:
    message
      "":U
      return-value skip
      error-status :get-message(1) skip
      error-status :get-message(2) skip
    view-as alert-box error.
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-docs
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  assign
    fi-doc-code = ?
    fi-pck-code = ?
  .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cb-fill_bge-xml_clients Dialog-Frame 
PROCEDURE cb-fill_bge-xml_clients :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.

    define buffer buf_temp_bge-xml_clients      for temp_bge-xml_clients.
do
for buf_temp_bge-xml_clients
on error undo, return error
:
    find first buf_temp_bge-xml_clients
         where buf_temp_bge-xml_clients.obj-type = p-obj-type
           and buf_temp_bge-xml_clients.obj-code = p-obj-code
    no-error.
    if not available buf_temp_bge-xml_clients
    then do:
        create buf_temp_bge-xml_clients.
        assign
            buf_temp_bge-xml_clients.obj-type = p-obj-type
            buf_temp_bge-xml_clients.obj-code = p-obj-code
        .
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cb-fill_bge-xml_dis-card Dialog-Frame 
PROCEDURE cb-fill_bge-xml_dis-card :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input parameter p-d-card as character        no-undo.

    define buffer buf_temp_bge-xml_dis-card     for temp_bge-xml_dis-card.
do
for buf_temp_bge-xml_dis-card
on error undo, return error
:
    find first buf_temp_bge-xml_dis-card
         where buf_temp_bge-xml_dis-card.d-card = p-d-card
    no-error.
    if not available buf_temp_bge-xml_dis-card
    then do:
        create buf_temp_bge-xml_dis-card.
        assign
            buf_temp_bge-xml_dis-card.d-card = p-d-card
        .
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cb-fill_bge-xml_goods Dialog-Frame 
PROCEDURE cb-fill_bge-xml_goods :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input parameter p-gds-code   as integer          no-undo.

do
on error undo, return error
:
    find first temp_bge-xml_goods
         where temp_bge-xml_goods.gds-code = p-gds-code
    no-error.
    if not available temp_bge-xml_goods
    then do:
        create temp_bge-xml_goods.
        assign
            temp_bge-xml_goods.gds-code = p-gds-code
        .
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
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
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
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
  DISPLAY fi-doc-code fi-pck-code 
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-mark b-help RECT-1 fi-doc-code fi-pck-code br-docs b-start 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-temp-del-doc-code Dialog-Frame 
PROCEDURE fill-temp-del-doc-code :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-doc-code   as character    no-undo.

    define buffer buf_temp_del-doc-code     for temp_del-doc-code.

    create buf_temp_del-doc-code.
    assign
        buf_temp_del-doc-code.doc-code = p-doc-code
    .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-temp-doc-code Dialog-Frame 
PROCEDURE fill-temp-doc-code :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-doc-code   as character    no-undo.

    define buffer buf_temp_doc-code     for temp_doc-code.

    create buf_temp_doc-code.
    assign
        buf_temp_doc-code.doc-code = p-doc-code
    .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-temp-ord-doc-code Dialog-Frame 
PROCEDURE fill-temp-ord-doc-code :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-doc-code  as character no-undo .

  define buffer buf_temp_ord-doc-code for temp_ord-doc-code.
do for buf_temp_ord-doc-code
on error undo, return error return-value
:
  find first buf_temp_ord-doc-code
    where buf_temp_ord-doc-code.doc-code = p-doc-code
  no-error .
  if not available buf_temp_ord-doc-code
  then do:
    create buf_temp_ord-doc-code.
    assign
      buf_temp_ord-doc-code.doc-code = p-doc-code
    .
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-temp-pr-doc-num Dialog-Frame 
PROCEDURE fill-temp-pr-doc-num :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input parameter p-doc-num as character    no-undo.

    define buffer buf_temp_pr-doc-num       for temp_pr-doc-num.
do
for buf_temp_pr-doc-num
on error undo, return error
:

    create buf_temp_pr-doc-num.
    assign
        buf_temp_pr-doc-num.doc-num = p-doc-num
    .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-br Dialog-Frame 
PROCEDURE open-br :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error return-value
:
  run waitfram-show in this-procedure ( input "Ждите...":U ).

  open query br-docs
    for each buf_tt-docs no-lock indexed-reposition.

  run waitfram-hide in this-procedure .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-exit Dialog-Frame 
PROCEDURE proc-b-exit :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-mark Dialog-Frame 
PROCEDURE proc-b-mark :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define variable v-log as logical   no-undo .
do
on error undo, return error return-value
:
  if not available buf_tt-docs
  then do:
    return . /* --->>>--- */
  end.

  assign
    buf_tt-docs.is-sel = not buf_tt-docs.is-sel
  .
  v-log = br-docs:refresh() in frame {&frame-name} .

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-start Dialog-Frame 
PROCEDURE proc-b-start :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

define variable v-log           as logical   no-undo .
define variable v-host-code     as integer   no-undo .
define variable v-obj-type      as character no-undo .
define variable v-obj-code      as integer   no-undo .
define variable v-need-checks   as logical   no-undo .
define variable v-xml-file-name as character no-undo .
define variable v-log-file-name as character no-undo .
define variable v-out-dir       as character no-undo .
define variable v-error-message as character no-undo .
do
on error undo, return error return-value
:
  find first buf_tt-docs
    where buf_tt-docs.is-sel = yes
  no-error .
  if not available buf_tt-docs
  then do:
    message
      "Не выбран документ"
    view-as alert-box error.
    return . /* --->>>--- */
  end.

  run waitfram-show in this-procedure ( input "Ждите...":U ).
  run bge-xml-out-dir in this-procedure ( output v-out-dir
                                        , output v-log-file-name
                                        ).
  for each buf_tt-docs
    where buf_tt-docs.is-sel = yes
      and buf_tt-docs.pck-code <> ?
  by buf_tt-docs.pck-code
  :
    { gbl/hostcode.i buf_tt-docs.obj-type buf_tt-docs.obj-code v-host-code }
    run bge/doc-incr.p ( input v-host-code
                       , input today
                       , input today
                       , input buf_tt-docs.obj-type
                       , input buf_tt-docs.obj-code
                       , input yes   /* p-pay-code*/
                       , input yes   /* p-cst*/
                       , input yes   /* p-parts*/
                       , input yes   /* p-chk-pay-code */
                       , input yes   /* p-pay-desk     */
                       , input yes   /* p-pay-desk-cards       */
                       , input yes   /* всегда выгружаем чеки! */
                       , input v-xml-file-name
                       , input v-log-file-name
                       , input this-procedure :handle
                       , input ?
                       , input ?
                       , buf_tt-docs.doc-type
                       , buf_tt-docs.doc-code
                       ) no-error.
    if error-status :error
    then do:
      assign
        v-error-message = substitute( "*** Ошибка экспорта документа &1 с кодом: &2.&3&4&5"
                                    , buf_tt-docs.doc-type
                                    , buf_tt-docs.doc-code
                                    , {&new-line}
                                    , return-value
                                    , trim(error-status :get-message(1))
                                    )
      .
      run wp-XMLWriteLog in this-procedure ( input v-log-file-name
                                            , input 1
                                            , input v-error-message
                                            ).
      message
        v-error-message
      view-as alert-box error.
      return . /* --->>>--- */
    end.
  end.
  run waitfram-hide in this-procedure .
  message
    "Выгрузка завершена!":U
  view-as alert-box information.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-doc-code Dialog-Frame 
PROCEDURE proc-doc-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define buffer buf_trn-doc   for ub.trn-doc.
  define buffer buf_price-doc for ub.price-doc.
  define buffer buf_c-trn-doc for ub.c-trn-doc.
  define buffer buf_ord-doc   for ub.ord-doc.
do
on error undo, return error return-value
:
  empty temp-table buf_tt-docs.

  assign
    fi-pck-code = ?
  .
  display
    fi-pck-code
  with frame {&frame-name}.
  assign
    fi-doc-code
  .
  if fi-doc-code = ""
  then do:
    return . /* --->>>--- */
  end.

  run waitfram-show in this-procedure ( input "Поиск документов...":U ) .

  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = fi-doc-code
  no-error .
  if available buf_trn-doc
  then do:
    create buf_tt-docs.
    assign
      buf_tt-docs.doc-type = {&table_trn-doc}
      buf_tt-docs.doc-code = buf_trn-doc.doc-code
      buf_tt-docs.obj-type = buf_trn-doc.obj-type
      buf_tt-docs.obj-code = buf_trn-doc.obj-code
    .
    run bge/get-oesq.p ( input {&table_trn-doc}
                       , input buf_trn-doc.doc-code
                       , output buf_tt-docs.pck-code
                       ) .
  end.

  find first buf_price-doc no-lock
    where buf_price-doc.doc-num = fi-doc-code
  no-error .
  if available buf_price-doc
  then do:
    create buf_tt-docs.
    assign
      buf_tt-docs.doc-type = {&table_price-doc}
      buf_tt-docs.doc-code = buf_price-doc.doc-num
      buf_tt-docs.obj-type = buf_price-doc.obj-type
      buf_tt-docs.obj-code = buf_price-doc.obj-code
    .
    run bge/get-oesq.p ( input {&table_price-doc}
                       , input buf_price-doc.doc-num
                       , output buf_tt-docs.pck-code
                       ) .
  end.

  find first buf_c-trn-doc no-lock
    where buf_c-trn-doc.doc-code = fi-doc-code
      and buf_c-trn-doc.is-del   = yes
  no-error .
  if available buf_c-trn-doc
  then do:
    create buf_tt-docs.
    assign
      buf_tt-docs.doc-type = {&table_c-trn-doc}
      buf_tt-docs.doc-code = buf_c-trn-doc.doc-code
      buf_tt-docs.obj-type = buf_c-trn-doc.obj-type
      buf_tt-docs.obj-code = buf_c-trn-doc.obj-code
    .
    run bge/get-oesq.p ( input {&table_c-trn-doc}
                       , input buf_c-trn-doc.doc-code
                       , output buf_tt-docs.pck-code
                       ) .
  end.

  find first buf_ord-doc no-lock
    where buf_ord-doc.doc-code = fi-doc-code
  no-error .
  if available buf_ord-doc
  then do:
    create buf_tt-docs.
    assign
      buf_tt-docs.doc-type = {&table_ord-doc}
      buf_tt-docs.doc-code = buf_ord-doc.doc-code
      buf_tt-docs.obj-type = buf_ord-doc.obj-type
      buf_tt-docs.obj-code = buf_ord-doc.obj-code
    .
    run bge/get-oesq.p ( input {&table_ord-doc}
                       , input buf_ord-doc.doc-code
                       , output buf_tt-docs.pck-code
                       ) .
  end.
  run waitfram-hide in this-procedure .
  run open-br in this-procedure .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-pck-code Dialog-Frame 
PROCEDURE proc-pck-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_doc-attr      for ub.doc-attr.
define buffer buf_ord-doc-attr  for ub.ord-doc-attr.

define buffer buf_trn-doc   for ub.trn-doc.
define buffer buf_price-doc for ub.price-doc.
define buffer buf_c-trn-doc for ub.c-trn-doc.
define buffer buf_ord-doc   for ub.ord-doc.

define variable v-doc-code  as character no-undo .

do
on error undo, return error return-value
:
  empty temp-table buf_tt-docs.

  assign
    fi-doc-code = ?
  .
  display
    fi-doc-code
  with frame {&frame-name}.
  assign
    fi-pck-code
  .
  assign
    v-doc-code = string(fi-pck-code)
  .
  if v-doc-code = ""
  then do:
    return . /* --->>>--- */
  end.

  run waitfram-show in this-procedure ( input "Поиск документов...":U ) .

  find first buf_doc-attr no-lock
    where buf_doc-attr.attr-code  = {&trdcattr-ora-exp-seq-num}
      and buf_doc-attr.attr-value = v-doc-code
  no-error.
  if available buf_doc-attr
  then do:
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-attr.doc-code
    no-error .
    if available buf_trn-doc
    then do:
      create buf_tt-docs.
      assign
        buf_tt-docs.doc-type = {&table_trn-doc}
        buf_tt-docs.doc-code = buf_trn-doc.doc-code
        buf_tt-docs.obj-type = buf_trn-doc.obj-type
        buf_tt-docs.obj-code = buf_trn-doc.obj-code
      .
      run bge/get-oesq.p ( input {&table_trn-doc}
                        , input buf_trn-doc.doc-code
                        , output buf_tt-docs.pck-code
                        ) .
    end.
    else do:
      find first buf_price-doc no-lock
        where buf_price-doc.doc-num = buf_doc-attr.doc-code
      no-error .
      if available buf_price-doc
      then do:
        create buf_tt-docs.
        assign
          buf_tt-docs.doc-type = {&table_price-doc}
          buf_tt-docs.doc-code = buf_price-doc.doc-num
          buf_tt-docs.obj-type = buf_price-doc.obj-type
          buf_tt-docs.obj-code = buf_price-doc.obj-code
        .
        run bge/get-oesq.p ( input {&table_price-doc}
                          , input buf_price-doc.doc-num
                          , output buf_tt-docs.pck-code
                          ) .
      end.
      else do:
        find first buf_c-trn-doc no-lock
          where buf_c-trn-doc.doc-code = buf_doc-attr.doc-code
            and buf_c-trn-doc.is-del   = yes
        no-error .
        if available buf_c-trn-doc
        then do:
          create buf_tt-docs.
          assign
            buf_tt-docs.doc-type = {&table_c-trn-doc}
            buf_tt-docs.doc-code = buf_c-trn-doc.doc-code
            buf_tt-docs.obj-type = buf_c-trn-doc.obj-type
            buf_tt-docs.obj-code = buf_c-trn-doc.obj-code
          .
          run bge/get-oesq.p ( input {&table_c-trn-doc}
                            , input buf_c-trn-doc.doc-code
                            , output buf_tt-docs.pck-code
                            ) .

        end.
      end.
    end.
  end.
  else do:
    find first buf_ord-doc-attr no-lock
      where buf_ord-doc-attr.attr-code  = {&orddocattr-ora-exp-seq-num}
        and buf_ord-doc-attr.attr-value = v-doc-code
    no-error .
    if available buf_ord-doc-attr
    then do:
      find first buf_ord-doc no-lock
        where buf_ord-doc.doc-code = buf_ord-doc-attr.doc-code
      no-error .
      if available buf_ord-doc
      then do:
        assign
          buf_tt-docs.doc-type = {&table_ord-doc}
          buf_tt-docs.doc-code = buf_ord-doc.doc-code
        .
        run bge/get-oesq.p ( input {&table_ord-doc}
                           , input buf_ord-doc.doc-code
                           , output buf_tt-docs.pck-code
                           ) .
      end.
    end.
  end.

  run waitfram-hide in this-procedure .
  run open-br in this-procedure .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION display-selected Dialog-Frame 
FUNCTION display-selected RETURNS CHARACTER
  ( BUFFER loc_tt-docs FOR tt-docs ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  RETURN IF loc_tt-docs.is-sel = YES THEN "*" ELSE "".   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

