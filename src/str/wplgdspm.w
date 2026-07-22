&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_goods FOR ub.goods.
DEFINE BUFFER X_pl-gds-pump FOR ub.pl-gds-pump.
DEFINE BUFFER X_pl-pump-nozzle FOR ub.pl-pump-nozzle.
DEFINE BUFFER X_place FOR ub.place.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Товар из резервуара на ТРК

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/15/07
Author: Dmitry Ukhanov
Creation date: 08/15/07


*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define input parameter parbutton   as   character           no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Товар из резервуара на ТРК".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ str/nzpl-spl.i }
{ trg/cplgdspm.i }
{ gbl/getcntxt.i def }

define variable varlog as logical no-undo.
define variable gds-rec as recid no-undo .
define variable v-doc-rec as recid no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME b-plgdspm

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_pl-gds-pump X_goods X_place ~
X_pl-pump-nozzle

/* Definitions for BROWSE b-plgdspm                                     */
&Scoped-define FIELDS-IN-QUERY-b-plgdspm X_pl-gds-pump.pump-code X_pl-pump-nozzle.nozzle-code X_goods.artic X_goods.gds-code X_goods.gds-name X_place.loc1 X_pl-gds-pump.status_ X_place.pl-code X_place.pl-name X_goods.prod-code X_goods.prod-type
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-plgdspm
&Scoped-define SELF-NAME b-plgdspm
&Scoped-define QUERY-STRING-b-plgdspm FOR EACH X_pl-gds-pump       WHERE X_pl-gds-pump.obj-type = parobj-type  AND X_pl-gds-pump.obj-code = parobj-code NO-LOCK, ~
             EACH X_goods WHERE X_goods.gds-code = X_pl-gds-pump.gds-code NO-LOCK, ~
             EACH X_place WHERE X_place.pl-code = X_pl-gds-pump.pl-code NO-LOCK, ~
             EACH X_pl-pump-nozzle WHERE X_pl-pump-nozzle.obj-type = X_pl-gds-pump.obj-type   AND X_pl-pump-nozzle.obj-code = X_pl-gds-pump.obj-code   AND X_pl-pump-nozzle.pl-code = X_pl-gds-pump.pl-code   AND X_pl-pump-nozzle.pump-code = X_pl-gds-pump.pump-code OUTER-JOIN NO-LOCK     BY X_pl-gds-pump.obj-type      BY X_pl-gds-pump.obj-code       BY X_pl-pump-nozzle.pump-code        BY X_pl-pump-nozzle.nozzle-code
&Scoped-define OPEN-QUERY-b-plgdspm OPEN QUERY {&SELF-NAME} FOR EACH X_pl-gds-pump       WHERE X_pl-gds-pump.obj-type = parobj-type  AND X_pl-gds-pump.obj-code = parobj-code NO-LOCK, ~
             EACH X_goods WHERE X_goods.gds-code = X_pl-gds-pump.gds-code NO-LOCK, ~
             EACH X_place WHERE X_place.pl-code = X_pl-gds-pump.pl-code NO-LOCK, ~
             EACH X_pl-pump-nozzle WHERE X_pl-pump-nozzle.obj-type = X_pl-gds-pump.obj-type   AND X_pl-pump-nozzle.obj-code = X_pl-gds-pump.obj-code   AND X_pl-pump-nozzle.pl-code = X_pl-gds-pump.pl-code   AND X_pl-pump-nozzle.pump-code = X_pl-gds-pump.pump-code OUTER-JOIN NO-LOCK     BY X_pl-gds-pump.obj-type      BY X_pl-gds-pump.obj-code       BY X_pl-pump-nozzle.pump-code        BY X_pl-pump-nozzle.nozzle-code.
&Scoped-define TABLES-IN-QUERY-b-plgdspm X_pl-gds-pump X_goods X_place ~
X_pl-pump-nozzle
&Scoped-define FIRST-TABLE-IN-QUERY-b-plgdspm X_pl-gds-pump
&Scoped-define SECOND-TABLE-IN-QUERY-b-plgdspm X_goods
&Scoped-define THIRD-TABLE-IN-QUERY-b-plgdspm X_place
&Scoped-define FOURTH-TABLE-IN-QUERY-b-plgdspm X_pl-pump-nozzle


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-b-plgdspm}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-cur b-block B-hist b-help b-plgdspm

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-block
     LABEL "&Блок-вать"
     SIZE 10 BY 1 TOOLTIP "Установить статут <Блокированный>".

DEFINE BUTTON b-cur
     LABEL "&Текущий"
     SIZE 10 BY 1 TOOLTIP "Установить статут <Текущий>".

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b-plgdspm FOR
      X_pl-gds-pump,
      X_goods,
      X_place,
      X_pl-pump-nozzle SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b-plgdspm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-plgdspm Dialog-Frame _FREEFORM
  QUERY b-plgdspm NO-LOCK DISPLAY
      X_pl-gds-pump.pump-code FORMAT ">9":U
X_pl-pump-nozzle.nozzle-code FORMAT ">9":U
X_goods.artic FORMAT "X(16)":U
X_goods.gds-code FORMAT "9999999999":U
X_goods.gds-name FORMAT "X(10)":U
X_place.loc1 COLUMN-LABEL "Резервуар" FORMAT "X(8)":U
X_pl-gds-pump.status_ FORMAT "X(8)":U
X_place.pl-code COLUMN-LABEL "Код резервуара" FORMAT "999999999":U
X_place.pl-name COLUMN-LABEL "Название резервуара"
X_goods.prod-code FORMAT ">>>>>>>>9":U
X_goods.prod-type COLUMN-LABEL "товара" FORMAT "X(3)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.43.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 2
     b-cur AT ROW 1 COL 12
     b-block AT ROW 1 COL 22
     B-hist AT ROW 1 COL 92
     b-help AT ROW 1 COL 95
     b-plgdspm AT ROW 2.43 COL 1
     SPACE(0.29) SKIP(0.26)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Товар из резервуара на ТРК"
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_goods B "?" ? ub goods
      TABLE: X_pl-gds-pump B "?" ? ub pl-gds-pump
      TABLE: X_pl-pump-nozzle B "?" ? ub pl-pump-nozzle
      TABLE: X_place B "?" ? ub place
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB b-plgdspm b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-plgdspm
/* Query rebuild information for BROWSE b-plgdspm
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_pl-gds-pump
      WHERE X_pl-gds-pump.obj-type = parobj-type
 AND X_pl-gds-pump.obj-code = parobj-code NO-LOCK,
      EACH X_goods WHERE X_goods.gds-code = X_pl-gds-pump.gds-code NO-LOCK,
      EACH X_place WHERE X_place.pl-code = X_pl-gds-pump.pl-code NO-LOCK,
      EACH X_pl-pump-nozzle WHERE X_pl-pump-nozzle.obj-type = X_pl-gds-pump.obj-type
  AND X_pl-pump-nozzle.obj-code = X_pl-gds-pump.obj-code
  AND X_pl-pump-nozzle.pl-code = X_pl-gds-pump.pl-code
  AND X_pl-pump-nozzle.pump-code = X_pl-gds-pump.pump-code OUTER-JOIN NO-LOCK
    BY X_pl-gds-pump.obj-type
     BY X_pl-gds-pump.obj-code
      BY X_pl-pump-nozzle.pump-code
       BY X_pl-pump-nozzle.nozzle-code.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ",,, OUTER"
     _OrdList          = "ub.pl-gds-pump.obj-type|yes,ub.pl-gds-pump.obj-code|yes,ub.pl-pump-nozzle.pump-code|yes,ub.pl-pump-nozzle.nozzle-code|yes"
     _Where[1]         = "pl-gds-pump.obj-type = parobj-type
 AND pl-gds-pump.obj-code = parobj-code"
     _JoinCode[2]      = "goods.gds-code = pl-gds-pump.gds-code"
     _JoinCode[3]      = "place.pl-code = pl-gds-pump.pl-code"
     _JoinCode[4]      = "pl-pump-nozzle.obj-type = pl-gds-pump.obj-type
  AND pl-pump-nozzle.obj-code = pl-gds-pump.obj-code
  AND pl-pump-nozzle.pl-code = pl-gds-pump.pl-code
  AND pl-pump-nozzle.pump-code = pl-gds-pump.pump-code"
     _Query            is OPENED
*/  /* BROWSE b-plgdspm */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Товар из резервуара на ТРК */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-block
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-block Dialog-Frame
ON CHOOSE OF b-block IN FRAME Dialog-Frame /* Блок-вать */
DO:
  if available X_pl-gds-pump then do:
    run local-stts in this-procedure
      ( input {&blocked-status}
      ).
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cur
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cur Dialog-Frame
ON CHOOSE OF b-cur IN FRAME Dialog-Frame /* Текущий */
DO:
  if available X_pl-gds-pump then do:
    run local-stts in this-procedure
      ( input {&current-status}
      ).
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
     DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
   IF AVAILABLE X_pl-gds-pump  THEN DO:

        run ref/cplchist.w (
                       INPUT parParentProc
                     , input parobj-type
                     , input parobj-code
                     , input "":U /*bttns  */
                     , input "subject":U /*p-mode*/
                     , input X_pl-gds-pump.obj-type
                     , input X_pl-gds-pump.obj-code
                     , input X_pl-gds-pump.pl-code
                     , input X_pl-gds-pump.gds-code /*p-gds-code*/
                     , input X_pl-gds-pump.pump-code /*p-pump-code*/
                     , input 0 /*p-nozzle-code*/
                     , input {&table_pl-gds-pump} /*p-subject*/
                     , input-output v-rid-list
                     ) no-error .

   END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-plgdspm
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
{ gbl/f2.i b-plgdspm " " " " parparentproc }
{ gbl/brwrepos.i
&line-num=5
}
{ gbl/brwrefre.i
" if available X_pl-gds-pump then v-doc-rec = recid(X_pl-gds-pump). ~{&OPEN-QUERY-b-plgdspm~} ~
  reposition b-plgdspm to recid v-doc-rec no-error. apply 'ENTRY' to b-plgdspm. "
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  RUN enable_UI.

  if v-cntxt-db-num <> v-cntxt-db-num-obj then do:
    assign
      b-block :sensitive in frame {&frame-name} = no
      b-cur :sensitive in frame {&frame-name} = no
    .
  end.


  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

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
  ENABLE b-exit b-cur b-block B-hist b-help b-plgdspm
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-stts Dialog-Frame
PROCEDURE local-stts :
define input  parameter p-stts as character no-undo .

  define variable varrecid as recid no-undo.
  define variable v-host-code as integer   no-undo .
  define buffer buf_pl-gds-pump for ub.pl-gds-pump.

  do transaction
  on error undo, retry
  :
    if retry then do:
      message
        vss-workfile vss-revision vss-description skip(1)
        substitute( "Ошибка при приcвоении статуса <&1>!", p-stts ) skip
        return-value skip
        error-status :get-message(1)
        view-as alert-box error.
      undo, return error .
    end.

    find first buf_pl-gds-pump exclusive-lock where
             recid(buf_pl-gds-pump) = recid(X_pl-gds-pump).

    if buf_pl-gds-pump.status_ = p-stts then do:
      message
        substitute( "Запись уже имеет статус <&1>.", p-stts )
        view-as alert-box information
      .
      undo, return error .
    end.
    { gbl/hostcode.i
      parobj-type
      parobj-code
      v-host-code
    }
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_plgdspm-sts_work':U
      {&cntxt-object}
      v-host-code
      parobj-type
      parobj-code
      0
      0
      0
      true
      varlog
    }
    if not varlog then do:
      undo, return error .
    end.
    assign
      buf_pl-gds-pump.status_ = p-stts
    .
    if p-stts = {&current-status} then do:
      run cplgdspm in this-procedure
        ( input buf_pl-gds-pump.obj-type
         ,input buf_pl-gds-pump.obj-code
         ,input buf_pl-gds-pump.pl-code
         ,input buf_pl-gds-pump.gds-code
         ,input buf_pl-gds-pump.pump-code
         ,input p-stts
        ).
    end.
  end.
  assign
    varrecid = recid(X_pl-gds-pump)
  .
  {&OPEN-QUERY-b-plgdspm}
  reposition {&browse-name} to recid varrecid.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
