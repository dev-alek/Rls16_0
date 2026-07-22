&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
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

Реализация по видам топлива

Автор: Белоусов Илья Александрович
Дата создания: 09/26/07
Author: Ilia Belousov
Creation date: 09/26/07

Input:

Output:
*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define input parameter p-date-begin as date no-undo.
define input parameter p-time-begin as integer no-undo.
define input parameter p-date-end as date no-undo.
define input parameter p-time-end as integer no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Реализация по видам топлива".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ trg/factord.i    }

define variable v-time-begin  as integer      no-undo.
define variable v-time-end    as integer      no-undo.

DEFINE TEMP-TABLE tt-gds-sale NO-UNDO
   field gds-code           like ub.goods.gds-code
   field gds-name           like ub.goods.gds-name
   field sale-qnty-mass     like ub.rvs-line.state-measure-qnty
   field sale-qnty-value    like ub.rvs-line.state-measure-qnty
   field density            as decimal
   field rvs-count          as integer
index pu as primary unique
      gds-code
 .

define buffer buf_tt-gds-sale    for tt-gds-sale.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-5

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_tt-gds-sale

/* Definitions for BROWSE BROWSE-5                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-5 buf_tt-gds-sale.gds-name buf_tt-gds-sale.sale-qnty-value buf_tt-gds-sale.sale-qnty-mass
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-5
&Scoped-define SELF-NAME BROWSE-5
&Scoped-define QUERY-STRING-BROWSE-5 FOR EACH buf_tt-gds-sale
&Scoped-define OPEN-QUERY-BROWSE-5 OPEN QUERY {&SELF-NAME} FOR EACH buf_tt-gds-sale.
&Scoped-define TABLES-IN-QUERY-BROWSE-5 buf_tt-gds-sale
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-5 buf_tt-gds-sale


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-5}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-qiut b-help v-date-begin v-date-end ~
v-hour-begin v-minute-begin v-hour-end v-minute-end BROWSE-5
&Scoped-Define DISPLAYED-OBJECTS v-date-begin v-date-end v-hour-begin ~
v-minute-begin v-hour-end v-minute-end

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-qiut AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE v-date-begin AS DATE FORMAT "99/99/99":U
     LABEL "Дата начала"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE v-date-end AS DATE FORMAT "99/99/99":U
     LABEL "Дата окончания"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE v-hour-begin AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Время"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE v-hour-end AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "время"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE v-minute-begin AS INTEGER FORMAT "99":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE v-minute-end AS INTEGER FORMAT "99":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-5 FOR
      buf_tt-gds-sale SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-5 Dialog-Frame _FREEFORM
  QUERY BROWSE-5 DISPLAY
      buf_tt-gds-sale.gds-name        COLUMN-LABEL "Топливо"
buf_tt-gds-sale.sale-qnty-value COLUMN-LABEL "Литры"
buf_tt-gds-sale.sale-qnty-mass  COLUMN-LABEL "Килограммы"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 79.5 BY 8.75 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-qiut AT ROW 1 COL 1
     b-help AT ROW 1 COL 71
     v-date-begin AT ROW 2.25 COL 13 COLON-ALIGNED
     v-date-end AT ROW 2.25 COL 44.5 COLON-ALIGNED
     v-hour-begin AT ROW 3.5 COL 13 COLON-ALIGNED
     v-minute-begin AT ROW 3.5 COL 18.5 COLON-ALIGNED
     v-hour-end AT ROW 3.5 COL 44.5 COLON-ALIGNED
     v-minute-end AT ROW 3.5 COL 50 COLON-ALIGNED
     BROWSE-5 AT ROW 5 COL 1.5
     SPACE(0.74) SKIP(0.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Реализация по видам топлива"
         CANCEL-BUTTON b-qiut.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BROWSE-5 v-minute-end Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-5
/* Query rebuild information for BROWSE BROWSE-5
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_tt-gds-sale.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-5 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Реализация по видам топлива */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&Scoped-define SELF-NAME v-date-begin
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-date-begin Dialog-Frame
ON LEAVE OF v-date-begin IN FRAME Dialog-Frame /* Дата начала */
DO:
    ASSIGN
          v-date-begin
    .
    run mandatory-begin-end in this-procedure .
    run fill-sale in this-procedure .
    run enable_UI in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-date-end
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-date-end Dialog-Frame
ON LEAVE OF v-date-end IN FRAME Dialog-Frame /* Дата окончания */
DO:
   ASSIGN
         v-date-begin
         v-date-end
   .
   run mandatory-begin-end in this-procedure .
   run fill-sale in this-procedure .
   run enable_UI in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-hour-begin
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-hour-begin Dialog-Frame
ON LEAVE OF v-hour-begin IN FRAME Dialog-Frame /* Время */
DO:
   ASSIGN
      v-hour-begin
   .
   RUN mandatory-24 IN THIS-PROCEDURE
         (INPUT-OUTPUT v-hour-begin ) .

   run mandatory-begin-end in this-procedure .

   assign
      v-time-begin = v-hour-begin * 60 * 60 + v-minute-begin * 60
   .
   run fill-sale in this-procedure .
   run enable_UI in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-hour-end
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-hour-end Dialog-Frame
ON LEAVE OF v-hour-end IN FRAME Dialog-Frame /* время */
DO:
   ASSIGN
      v-hour-end
   .
   RUN mandatory-24 IN THIS-PROCEDURE
      (INPUT-OUTPUT v-hour-end ) .

   run mandatory-begin-end in this-procedure .

   assign
      v-time-end = v-hour-end * 60 * 60 + v-minute-end * 60
   .
   run fill-sale in this-procedure .
   run enable_UI in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-minute-begin
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-minute-begin Dialog-Frame
ON LEAVE OF v-minute-begin IN FRAME Dialog-Frame
DO:
   ASSIGN
      v-minute-begin
   .
   run MANDATORY-60 IN THIS-PROCEDURE
         (INPUT-OUTPUT v-minute-begin ) .

   run mandatory-begin-end in this-procedure .

   assign
      v-time-begin = v-hour-begin * 60 * 60 + v-minute-begin * 60
   .
   run fill-sale in this-procedure .
   run enable_UI in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-minute-end
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-minute-end Dialog-Frame
ON LEAVE OF v-minute-end IN FRAME Dialog-Frame
DO:
   ASSIGN
   v-minute-end
   .
   run MANDATORY-60 IN THIS-PROCEDURE
      (INPUT-OUTPUT v-minute-end ) .

   run mandatory-begin-end in this-procedure .

   assign
      v-time-end = v-hour-end * 60 * 60 + v-minute-end * 60
   .
   run fill-sale in this-procedure .
   run enable_UI in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-5
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

   run reset-date in this-procedure .
   IF v-date-begin > v-date-end THEN DO:
      assign
         v-date-end = v-date-begin
      .
   END.

   IF v-date-begin = v-date-end
   AND v-hour-begin > v-hour-end
   THEN DO:
      assign
            v-hour-end = v-hour-begin
      .
   END.
   IF v-date-begin = v-date-end
   AND v-hour-begin = v-hour-end
   AND v-minute-begin > v-minute-end
   THEN DO:
      assign
         v-minute-end = v-minute-begin
      .
   END.

   run fill-sale in this-procedure .

   run enable_UI.
   WAIT-FOR GO OF FRAME {&FRAME-NAME}.

END.
run disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

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
  DISPLAY v-date-begin v-date-end v-hour-begin v-minute-begin v-hour-end
          v-minute-end
      WITH FRAME Dialog-Frame.
  ENABLE b-qiut b-help v-date-begin v-date-end v-hour-begin v-minute-begin
         v-hour-end v-minute-end BROWSE-5
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-sale Dialog-Frame
PROCEDURE fill-sale :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

do
on error undo, return error
:
define buffer buf_chk-doc     for ub.chk-doc.
define buffer buf_chk-gds     for ub.chk-gds.
define buffer buf_pl-gds      for ub.pl-gds.
define buffer buf_tt-gds-sale for tt-gds-sale.
define buffer buf_bar-code    for ub.bar-code.
define buffer buf_goods       for ub.goods.
define buffer buf_rvs-doc     for rvs-doc.
define buffer buf_rvs-line-pump     for rvs-line-pump.
define buffer buf_rvs-line    for rvs-line .
define buffer buf_doc-line    for doc-line .
define buffer buf_inkas       for inkas .
define buffer buf_shift-obj      for shift-obj.

define variable v-shift-num    as integer      no-undo.
define variable v-shift-date    as date      no-undo.
define variable v-delta-time    as integer      no-undo.
define variable v-delta-time-2  as integer      no-undo.
define variable v-rvs-code    as character    no-undo.
define variable v-density    as decimal      no-undo.
define variable v-fact-order-start    as decimal      no-undo.
define variable v-fact-order-end      as decimal      no-undo.

define variable v-close    as logical      no-undo.

   assign
      v-close        = FALSE
      v-shift-num    = 0
      v-shift-date   = ?
   .
   empty temp-table buf_tt-gds-sale.



   FIND FIRST buf_shift-obj
      where buf_shift-obj.obj-type = p-obj-type
         and buf_shift-obj.obj-code =  p-obj-code
         and buf_shift-obj.status_ = {&sht-current}
      no-lock
      no-error.
   IF AVAILABLE buf_shift-obj THEN DO:
      IF (buf_shift-obj.open-date < v-date-begin)
      OR (buf_shift-obj.open-date = v-date-begin
      AND buf_shift-obj.open-time <= v-time-begin)
      THEN DO:
         assign
            v-close = FALSE
         .
      end.
      else do:
         assign
            v-close = TRUE
         .
      end.
   END.

   IF v-close THEN DO:
      _chk:
      for each buf_chk-doc
         where  buf_chk-doc.obj-type   = p-obj-type
            and buf_chk-doc.obj-code  = p-obj-code
            and ((    buf_chk-doc.chk-date =  v-date-begin
                  and buf_chk-doc.chk-time >= v-time-begin)
                or
                 (buf_chk-doc.chk-date > v-date-begin)
                )
            and ((buf_chk-doc.chk-date = v-date-end
                  and buf_chk-doc.chk-time <= v-time-end)
                  or (buf_chk-doc.chk-date <  v-date-end))
            and (buf_chk-doc.chk-type = INTEGER({&rcpt-sale})
             OR buf_chk-doc.chk-type  = INTEGER({&rcpt-return}))
         and buf_chk-doc.out-code <> ?
         no-lock
         ,
        first buf_inkas
        where buf_inkas.inkas-code = buf_chk-doc.out-code
          and buf_inkas.status_    = {&fact}
         no-lock,
         each buf_chk-gds
         where buf_chk-gds.doc-code = buf_chk-doc.doc-code
         no-lock

         :

            FIND FIRST buf_bar-code
               WHERE buf_bar-code.b-code = buf_chk-gds.b-code
               NO-LOCK
               .

            FIND first buf_pl-gds
               where buf_pl-gds.gds-code = buf_bar-code.gds-code
                  and buf_pl-gds.obj-type = p-obj-type
                  and buf_pl-gds.obj-code = p-obj-code
               no-lock
               no-error
               .
            IF not available buf_pl-gds THEN DO:
               next _chk.
            END.

            FIND first buf_goods
               where buf_goods.gds-code = buf_bar-code.gds-code
               no-lock
               .
            /*
            find first buf_doc-line
                 where buf_doc-line.doc-code  = buf_chk-doc.out-code
                   and buf_doc-line.artic     = buf_goods.artic
                   and buf_doc-line.prod-type = buf_goods.prod-type
                   and buf_doc-line.prod-code = buf_goods.prod-code
                 no-lock
                 no-error
                 .
            assign
               v-density = ( if available buf_doc-line then buf_doc-line.doc-density else 0 )
            .
            */

         find first buf_tt-gds-sale
               where buf_tt-gds-sale.gds-code = buf_pl-gds.gds-code
               no-error.

         if not available buf_tt-gds-sale then do:
            find first buf_goods
                  where buf_goods.gds-code = buf_pl-gds.gds-code
                  no-lock
                  .

            create buf_tt-gds-sale.
            assign
               buf_tt-gds-sale.gds-code = buf_goods.gds-code
               buf_tt-gds-sale.gds-name = buf_goods.gds-name
            .
         end.
         assign
            buf_tt-gds-sale.sale-qnty-value = buf_tt-gds-sale.sale-qnty-value + buf_chk-gds.doc-qnty
            buf_tt-gds-sale.sale-qnty-mass  = buf_tt-gds-sale.sale-qnty-mass  + buf_chk-gds.doc-qnty * buf_chk-gds.density
         .
      end. /* each buf_chk-doc */
   END. /* v-close */
   ELSE DO:
      /* находим сверку ближайшую ко времени старта прогноза */
      FOR each buf_rvs-doc
         where buf_rvs-doc.obj-type = p-obj-type
         and buf_rvs-doc.obj-code   = p-obj-code
         and buf_rvs-doc.shift-date = v-shift-date
         and buf_rvs-doc.shift-num  = v-shift-num
         and buf_rvs-doc.status_    = {&fact}
         and buf_rvs-doc.rvs-type   = {&rvs-control}
         no-lock
         :
         IF v-date-begin = buf_rvs-doc.fact-date
         then do:
            IF v-delta-time > ABS(buf_rvs-doc.fact-time - v-time-begin)
            then do:
               assign
                  v-delta-time = ABS(buf_rvs-doc.fact-time - v-time-begin)
                  /*
                  v-meas-date-pred = buf_rvs-doc.fact-date
                  v-meas-time-pred = buf_rvs-doc.fact-time
                  */
                  v-rvs-code  = buf_rvs-doc.rvs-code
                  v-fact-order-start = buf_rvs-doc.fact-order
               .
            end.
         end.
         else do:
            assign
            v-delta-time-2 = IF v-date-begin > buf_rvs-doc.fact-date
                           then ABS(buf_rvs-doc.fact-time - ((v-date-begin - buf_rvs-doc.fact-date) * 86400 - buf_rvs-doc.fact-time + v-time-begin))
                           else ABS(buf_rvs-doc.fact-time - ((buf_rvs-doc.fact-date - v-date-begin) * 86400 - v-time-begin + buf_rvs-doc.fact-time))
            .
            IF v-delta-time > v-delta-time-2
            then do:
               assign
                  v-delta-time = v-delta-time-2
                  v-rvs-code  = buf_rvs-doc.rvs-code
               .
            end.
         end.
      end.
      IF v-delta-time = 9999999 then do:
         message
            "В смене, заданной для прогноза, нет контрольных сверок"
            skip
         view-as alert-box information.
         return .
      end.
      IF v-delta-time > 1800 then do:
         message
            "В смене, заданной для прогноза, контрольная сверка"
            "отстоит по времени от точки начала прогноза более чем на 30 минут"
            skip
         view-as alert-box information.
      end.


      _buf_rvs-line-pump:
      for EACH buf_rvs-line-pump
         WHERE buf_rvs-line-pump.rvs-code = v-rvs-code
         NO-LOCK
         :

         find first buf_tt-gds-sale
               where buf_tt-gds-sale.gds-code = buf_rvs-line-pump.gds-code
               no-error.

         if not available buf_tt-gds-sale then do:
            find first buf_goods
                  where buf_goods.gds-code = buf_rvs-line-pump.gds-code
                  no-lock
                  .

            create buf_tt-gds-sale.
            assign
               buf_tt-gds-sale.gds-code = buf_goods.gds-code
               buf_tt-gds-sale.gds-name = buf_goods.gds-name
            .
         end.
            /*
         run str/avrgdens.p
            (  input p-obj-type
            ,  input p-obj-code
            ,  input v-shift-date
            ,  input v-shift-num
            ,  input buf_goods.gds-code
            ,  input ?
            ,  input no
            , output v-density
            ) no-error .
            */
         assign
            buf_tt-gds-sale.sale-qnty-value = buf_tt-gds-sale.sale-qnty-value - IF buf_rvs-line-pump.meas-am-qnty <> ? THEN buf_rvs-line-pump.meas-am-qnty ELSE 0
            buf_tt-gds-sale.sale-qnty-mass  = buf_tt-gds-sale.sale-qnty-mass  - IF buf_rvs-line-pump.meas-am-qnty <> ? THEN buf_rvs-line-pump.meas-am-qnty ELSE 0
         .
      END. /* each buf_rvs-doc */

      assign
         v-delta-time = 9999999
      .
      /* находим сверку ближайшую ко времени окончания прогноза */
      FOR each buf_rvs-doc
         where buf_rvs-doc.obj-type = p-obj-type
         and buf_rvs-doc.obj-code   = p-obj-code
         and buf_rvs-doc.shift-date = v-shift-date
         and buf_rvs-doc.shift-num  = v-shift-num
         and buf_rvs-doc.status_    = {&fact}
         and (buf_rvs-doc.rvs-type  = {&rvs-control}
               OR
               buf_rvs-doc.rvs-type   = {&rvs-shift})
         no-lock
         :
         IF v-date-end = buf_rvs-doc.fact-date
         then do:
            IF v-delta-time > ABS(buf_rvs-doc.fact-time - v-time-end)
            then do:
               assign
                  v-delta-time = ABS(buf_rvs-doc.fact-time - v-time-end)
                  /*
                  v-meas-date-pred = buf_rvs-doc.fact-date
                  v-meas-time-pred = buf_rvs-doc.fact-time
                  */
                  v-rvs-code  = buf_rvs-doc.rvs-code
                  v-fact-order-end = buf_rvs-doc.fact-order
               .
            end.
         end.
         else do:
            assign
            v-delta-time-2 = IF v-date-end > buf_rvs-doc.fact-date
                           then ABS(buf_rvs-doc.fact-time - ((v-date-end - buf_rvs-doc.fact-date) * 86400 - buf_rvs-doc.fact-time + v-time-end))
                           else ABS(buf_rvs-doc.fact-time - ((buf_rvs-doc.fact-date - v-date-end) * 86400 - v-time-end + buf_rvs-doc.fact-time))
            .
            IF v-delta-time > v-delta-time-2
            then do:
               assign
                  v-delta-time = v-delta-time-2
                  /*
                  v-meas-date-pred = buf_rvs-doc.fact-date
                  v-meas-time-pred = buf_rvs-doc.fact-time
                  */
                  v-rvs-code  = buf_rvs-doc.rvs-code
               .
            end.
         end.
      end.
      IF v-delta-time = 9999999 then do:
         message
            "В смене, заданной для прогноза, нет контрольных сверок"
            skip
         view-as alert-box information.
         return.
      end.
      IF v-delta-time > 1800 then do:
         message
            "В смене, заданной для прогноза, контрольная сверка"
            "отстоит по времени от точки окончания прогноза более чем на 30 минут"
            skip
         view-as alert-box information.
      end.

      _buf_rvs-line-pump:
      for EACH buf_rvs-line-pump
         WHERE buf_rvs-line-pump.rvs-code = v-rvs-code
         NO-LOCK
         :

         find first buf_tt-gds-sale
               where buf_tt-gds-sale.gds-code = buf_rvs-line-pump.gds-code
               no-error.

         if not available buf_tt-gds-sale then do:
            find first buf_goods
                  where buf_goods.gds-code = buf_rvs-line-pump.gds-code
                  no-lock
                  .

            create buf_tt-gds-sale.
            assign
               buf_tt-gds-sale.gds-code = buf_goods.gds-code
               buf_tt-gds-sale.gds-name = buf_goods.gds-name
            .
         end.
         /*
         run str/avrgdens.p
            (  input p-obj-type
            ,  input p-obj-code
            ,  input v-shift-date
            ,  input v-shift-num
            ,  input buf_goods.gds-code
            ,  input ?
            ,  input no
            , output v-density
            ) no-error .
         */
         assign
            buf_tt-gds-sale.sale-qnty-value = buf_tt-gds-sale.sale-qnty-value + IF buf_rvs-line-pump.meas-am-qnty <> ? THEN buf_rvs-line-pump.meas-am-qnty ELSE 0
            buf_tt-gds-sale.sale-qnty-mass  = buf_tt-gds-sale.sale-qnty-mass  + (IF buf_rvs-line-pump.meas-am-qnty <> ? THEN buf_rvs-line-pump.meas-am-qnty ELSE 0) /* * v-density */
         .
      END. /* each buf_rvs-doc */
      FOR each buf_rvs-doc
            where buf_rvs-doc.obj-type = p-obj-type
            and buf_rvs-doc.obj-code   = p-obj-code
            and buf_rvs-doc.shift-date = v-shift-date
            and buf_rvs-doc.shift-num  = v-shift-num
            and buf_rvs-doc.status_    = {&fact}
            and (buf_rvs-doc.rvs-type  = {&rvs-control}
                  OR
                  buf_rvs-doc.rvs-type   = {&rvs-shift})
            and buf_rvs-doc.fact-order >= v-fact-order-start
            and buf_rvs-doc.fact-order <= v-fact-order-end
            no-lock
            ,
            each  buf_rvs-line
            where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
            no-lock
            ,
            first buf_tt-gds-sale
            where buf_tt-gds-sale.gds-code = buf_rvs-line.gds-code
            :

            assign
               buf_tt-gds-sale.density = buf_tt-gds-sale.density + buf_rvs-line.density
               buf_tt-gds-sale.rvs-count = buf_tt-gds-sale.rvs-count + 1
            .
      end.
      FOR EACH buf_tt-gds-sale
          :
            assign
               buf_tt-gds-sale.density = buf_tt-gds-sale.density / buf_tt-gds-sale.rvs-count
               buf_tt-gds-sale.sale-qnty-mass = buf_tt-gds-sale.sale-qnty-mass * buf_tt-gds-sale.density
            .
      end.
   END.
end.
END PROCEDURE. /* fill-sale */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mandatory-24 Dialog-Frame
PROCEDURE mandatory-24 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT-OUTPUT PARAMETER p-time AS INTEGER NO-UNDO .
DO
ON error undo, RETURN:
   IF p-time > 23 THEN DO:
       ASSIGN
           p-time = 23
       .
       RETURN .
   END.
   IF p-time < 0 THEN DO:
       ASSIGN
           p-time = 0
       .
       RETURN .
   END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mandatory-60 Dialog-Frame
PROCEDURE mandatory-60 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT-OUTPUT PARAMETER p-time AS INTEGER NO-UNDO .
DO
ON error undo, RETURN:
   IF p-time > 59 THEN DO:
       ASSIGN
           p-time = 59
       .
       RETURN .
   END.
   IF p-time < 0 THEN DO:
       ASSIGN
           p-time = 0
       .
       RETURN .
   END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mandatory-begin-end Dialog-Frame
PROCEDURE mandatory-begin-end :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
   IF v-date-begin > v-date-end THEN DO:
      message
         "Дата окончания не может быть меньше даты начала."
         skip
      view-as alert-box information.
      assign
            v-date-end = v-date-begin
      .
   END.

   IF v-date-begin = v-date-end
   AND v-hour-begin > v-hour-end
   THEN DO:
      message
         "Время окончания не может быть меньше даты начала."
         skip
      view-as alert-box information.
      assign
            v-hour-end = v-hour-begin
      .
   END.

   IF v-date-begin = v-date-end
   AND v-hour-begin = v-hour-end
   AND v-minute-begin > v-minute-end
   THEN DO:
   message
      "Время окончания не может быть меньше даты начала."
      skip
   view-as alert-box information.
   assign
      v-minute-end = v-minute-begin
   .
   END.

end.
END PROCEDURE. /* mandatory-begin-end */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reset-date Dialog-Frame
PROCEDURE reset-date :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
  define variable v-sec    as integer      no-undo.
  assign
     v-date-begin     = p-date-begin
     v-date-end       = p-date-end
     v-time-begin     = p-time-begin
     v-time-end       = p-time-end
     v-sec            = p-time-begin MOD 60
     v-minute-begin   = ((p-time-begin - v-sec) / 60) mod 60
     v-hour-begin     = (((p-time-begin - v-sec) / 60) - v-minute-begin) / 60
  .
  assign
     v-sec            = p-time-end MOD 60
     v-minute-end     = ((p-time-end - v-sec) / 60) mod 60
     v-hour-end       = (((p-time-end - v-sec) / 60) - v-minute-end) / 60
  .
end.
END PROCEDURE. /* reset-date */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME