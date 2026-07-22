&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE BUFFER locked_icnt-doc FOR ub.icnt-doc.
DEFINE BUFFER locked_icnt-line FOR ub.icnt-line.
DEFINE TEMP-TABLE tt-icnt-doc NO-UNDO LIKE ub.icnt-doc.
DEFINE TEMP-TABLE tt-icnt-line NO-UNDO LIKE ub.icnt-line.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма редактирования документа измерения погрешности счетчиков ТРК

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/22/07
Author: Dmitry Ukhanov
Creation date: 08/22/07

Автор1: Бахтадзе Наталья Викторовна
Дата создания1: 11/11/05
Author1: Bakhtadze Natalya
Creation date1: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS character NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type AS character NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-recid AS recid NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-icnt-line-rec AS recid NO-UNDO.
define input parameter p-call-prog as handle no-undo .
define input-output parameter p-next-prev as CHARACTER no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма редактирования документа измерения погрешности счетчиков ТРК".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ str/lib-trn.i      }
{ gbl/getcntxt.i DEF  }
{ str/icntline.i }


define variable v-delta-line like ub.icnt-line.state-el-cnt  no-undo.
DEFINE VARIABLE new-opened AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-mode AS CHARACTER NO-UNDO.
define variable v-host-code as integer no-undo .
define variable v-ptrlcheck as character no-undo .
define variable v-ref-rec  as recid no-undo .

DEFINE VARIABLE wrkr AS INTEGER NO-UNDO.
DEFINE VARIABLE agnt AS INTEGER NO-UNDO.
DEFINE VARIABLE boss AS INTEGER NO-UNDO.


define variable gds-rec as recid no-undo .
DEFINE BUFFER cli-buf FOR ub.clients .


&scop label-clmn_1-br-dtl   'ТРК'
&scop sort-clmn_1-br-dtl    tt-icnt-line.pump-code
&scop label-clmn_2-br-dtl   'Пис!то!лет'
&scop sort-clmn_2-br-dtl    tt-icnt-line.nozzle-code
&scop label-clmn_3-br-dtl   'Артикул'
&scop sort-clmn_3-br-dtl    buf_goods.artic
&scop label-clmn_4-br-dtl   'Кол-во!по!счетчику'
&scop sort-clmn_4-br-dtl    tt-icnt-line.state-el-cnt
&scop label-clmn_5-br-dtl   'Кол-во!по!мернику'
&scop sort-clmn_5-br-dtl    tt-icnt-line.state-mh-cnt
&scop label-clmn_6-br-dtl   'Разница'
&scop sort-clmn_6-br-dtl    (tt-icnt-line.state-el-cnt - tt-icnt-line.state-mh-cnt)
/*
&scop label-clmn_7-br-dtl   'Измерение!электронного!счетчика'
&scop sort-clmn_7-br-dtl    tt-icnt-line.meas-el-cnt
*/
&scop label-clmn_8-br-dtl   'Название товара'
&scop sort-clmn_8-br-dtl    buf_goods.gds-name
&scop label-clmn_9-br-dtl   'Резервуар'
&scop sort-clmn_9-br-dtl    tt-icnt-line.pl-code


&scop my-OPEN-QUERY-br-line OPEN QUERY br-line                                          ~
   FOR EACH tt-icnt-line WHERE tt-icnt-line.doc-code = tt-icnt-doc.doc-code NO-LOCK, ~
             FIRST buf_goods OUTER-JOIN NO-LOCK WHERE buf_goods.gds-code  = tt-icnt-line.gds-code

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-line

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-icnt-line buf_goods tt-icnt-doc ~
buf_clients

/* Definitions for BROWSE br-line                                       */
&Scoped-define FIELDS-IN-QUERY-br-line {&sort-clmn_1-br-dtl} {&sort-clmn_2-br-dtl} {&sort-clmn_3-br-dtl} {&sort-clmn_4-br-dtl} {&sort-clmn_5-br-dtl} {&sort-clmn_6-br-dtl} @ v-delta-line {&sort-clmn_8-br-dtl} {&sort-clmn_9-br-dtl}
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-line {&sort-clmn_5-br-dtl}
&Scoped-define SELF-NAME br-line
&Scoped-define QUERY-STRING-br-line FOR EACH tt-icnt-line NO-LOCK WHERE     tt-icnt-line.doc-code = tt-icnt-doc.doc-code , ~
                    FIRST buf_goods OUTER-JOIN WHERE             buf_goods.gds-code        = tt-icnt-line.gds-code NO-LOCK
&Scoped-define OPEN-QUERY-br-line OPEN QUERY {&SELF-NAME} FOR EACH tt-icnt-line NO-LOCK WHERE     tt-icnt-line.doc-code = tt-icnt-doc.doc-code , ~
                    FIRST buf_goods OUTER-JOIN WHERE             buf_goods.gds-code        = tt-icnt-line.gds-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-line tt-icnt-line buf_goods
&Scoped-define FIRST-TABLE-IN-QUERY-br-line tt-icnt-line
&Scoped-define SECOND-TABLE-IN-QUERY-br-line buf_goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-icnt-doc.doc-date ~
tt-icnt-doc.fact-date tt-icnt-doc.shift-date tt-icnt-doc.shift-num ~
tt-icnt-doc.shift-name tt-icnt-doc.wrkr tt-icnt-doc.agnt tt-icnt-doc.boss ~
tt-icnt-doc.obj-code tt-icnt-doc.obj-type buf_clients.obj-name ~
tt-icnt-doc.state-el-cnt tt-icnt-doc.state-mh-cnt
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-icnt-doc.doc-date ~
tt-icnt-doc.fact-date tt-icnt-doc.shift-date tt-icnt-doc.shift-num ~
tt-icnt-doc.shift-name tt-icnt-doc.wrkr tt-icnt-doc.agnt tt-icnt-doc.boss ~
tt-icnt-doc.obj-code tt-icnt-doc.obj-type buf_clients.obj-name ~
tt-icnt-doc.state-el-cnt tt-icnt-doc.state-mh-cnt
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-icnt-doc buf_clients
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-icnt-doc
&Scoped-define SECOND-ENABLED-TABLE-IN-QUERY-Dialog-Frame buf_clients
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-line}
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-icnt-doc buf_clients
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-icnt-doc
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame buf_clients


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-icnt-doc.doc-date tt-icnt-doc.fact-date ~
tt-icnt-doc.shift-date tt-icnt-doc.shift-num tt-icnt-doc.shift-name ~
tt-icnt-doc.wrkr tt-icnt-doc.agnt tt-icnt-doc.boss tt-icnt-doc.obj-code ~
tt-icnt-doc.obj-type buf_clients.obj-name tt-icnt-doc.state-el-cnt ~
tt-icnt-doc.state-mh-cnt
&Scoped-define ENABLED-TABLES tt-icnt-doc buf_clients
&Scoped-define FIRST-ENABLED-TABLE tt-icnt-doc
&Scoped-define SECOND-ENABLED-TABLE buf_clients
&Scoped-Define ENABLED-OBJECTS B-exit b-quit b-prev b-next b-chk B-notes ~
B-hist B-Help r-wrkr r-agnt r-boss B-add b-del br-line wrkr-name agnt-name ~
boss-name v-delta
&Scoped-Define DISPLAYED-FIELDS tt-icnt-doc.doc-date tt-icnt-doc.fact-date ~
tt-icnt-doc.shift-date tt-icnt-doc.shift-num tt-icnt-doc.shift-name ~
tt-icnt-doc.wrkr tt-icnt-doc.agnt tt-icnt-doc.boss tt-icnt-doc.obj-code ~
tt-icnt-doc.obj-type buf_clients.obj-name tt-icnt-doc.state-el-cnt ~
tt-icnt-doc.state-mh-cnt
&Scoped-define DISPLAYED-TABLES tt-icnt-doc buf_clients
&Scoped-define FIRST-DISPLAYED-TABLE tt-icnt-doc
&Scoped-define SECOND-DISPLAYED-TABLE buf_clients
&Scoped-Define DISPLAYED-OBJECTS wrkr-name agnt-name boss-name v-delta

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chk
     LABEL "&Чеки"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.

DEFINE BUTTON b-next AUTO-GO
     LABEL "&>>"
     SIZE 4 BY 1.

DEFINE BUTTON B-notes
     LABEL "При&мечания"
     SIZE 10 BY 1.

DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<"
     SIZE 4 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON r-agnt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .88.

DEFINE BUTTON r-boss
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .88.

DEFINE BUTTON r-wrkr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .88.

DEFINE VARIABLE agnt-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE boss-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-delta AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "Разница"
      VIEW-AS TEXT
     SIZE 19 BY .67 NO-UNDO.

DEFINE VARIABLE wrkr-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-line FOR
      tt-icnt-line,
      buf_goods SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      tt-icnt-doc,
      buf_clients SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-line
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-line Dialog-Frame _FREEFORM
  QUERY br-line NO-LOCK DISPLAY
      {&sort-clmn_1-br-dtl}                 COLUMN-LABEL {&label-clmn_1-br-dtl}
{&sort-clmn_2-br-dtl}                 COLUMN-LABEL {&label-clmn_2-br-dtl}
{&sort-clmn_3-br-dtl}                 COLUMN-LABEL {&label-clmn_3-br-dtl}
{&sort-clmn_4-br-dtl}                 COLUMN-LABEL {&label-clmn_4-br-dtl}
{&sort-clmn_5-br-dtl}                 COLUMN-LABEL {&label-clmn_5-br-dtl}
{&sort-clmn_6-br-dtl}  @ v-delta-line COLUMN-LABEL {&label-clmn_6-br-dtl} format "->>>,>>>,>>9.999"
{&sort-clmn_8-br-dtl}                 COLUMN-LABEL {&label-clmn_8-br-dtl}
{&sort-clmn_9-br-dtl}                 COLUMN-LABEL {&label-clmn_9-br-dtl}
ENABLE
{&sort-clmn_5-br-dtl}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 14 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-prev AT ROW 1 COL 24
     b-next AT ROW 1 COL 28
     b-chk AT ROW 1 COL 58 WIDGET-ID 2
     B-notes AT ROW 1 COL 68
     B-hist AT ROW 1 COL 78
     B-Help AT ROW 1 COL 88
     tt-icnt-doc.doc-date AT ROW 3 COL 20 COLON-ALIGNED
          LABEL "Дата" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-icnt-doc.fact-date AT ROW 3 COL 39 COLON-ALIGNED
          LABEL "Факт" FORMAT "99/99/99"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-icnt-doc.shift-date AT ROW 3 COL 58 COLON-ALIGNED
          LABEL "Смена" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-icnt-doc.shift-num AT ROW 3 COL 72 COLON-ALIGNED
          LABEL "П" FORMAT ">9"
          VIEW-AS FILL-IN
          SIZE 3 BY 1
     tt-icnt-doc.shift-name AT ROW 3 COL 82 COLON-ALIGNED
          LABEL "№"
          VIEW-AS FILL-IN
          SIZE 3 BY 1
     tt-icnt-doc.wrkr AT ROW 4 COL 5 COLON-ALIGNED
          LABEL "К&л-к" FORMAT "999999999"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     r-wrkr AT ROW 4 COL 33.13
     tt-icnt-doc.agnt AT ROW 5 COL 5 COLON-ALIGNED
          LABEL "И&сп" FORMAT "999999999"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     r-agnt AT ROW 5.33 COL 33
     tt-icnt-doc.boss AT ROW 6 COL 5 COLON-ALIGNED
          LABEL "&М-р" FORMAT "999999999"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     r-boss AT ROW 6.33 COL 33
     B-add AT ROW 7 COL 41
     b-del AT ROW 7 COL 51
     br-line AT ROW 8 COL 1
     tt-icnt-doc.obj-code AT ROW 2 COL 16 COLON-ALIGNED
          LABEL "Объект" FORMAT "99999"
           VIEW-AS TEXT
          SIZE 7 BY .67
     tt-icnt-doc.obj-type AT ROW 2 COL 23.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4 BY .67
     buf_clients.obj-name AT ROW 2 COL 33 COLON-ALIGNED NO-LABEL FORMAT "X(40)"
           VIEW-AS TEXT
          SIZE 40 BY .67
          FGCOLOR 4
     wrkr-name AT ROW 4 COL 16 COLON-ALIGNED NO-LABEL
     tt-icnt-doc.state-el-cnt AT ROW 4 COL 75 COLON-ALIGNED
          LABEL "Кол-во по счетчику"
           VIEW-AS TEXT
          SIZE 19 BY .67
     agnt-name AT ROW 5 COL 16 COLON-ALIGNED NO-LABEL
     tt-icnt-doc.state-mh-cnt AT ROW 5 COL 75 COLON-ALIGNED
          LABEL "Кол-во по мернику"
           VIEW-AS TEXT
          SIZE 19 BY .67
     boss-name AT ROW 6 COL 16 COLON-ALIGNED NO-LABEL
     v-delta AT ROW 6 COL 75 COLON-ALIGNED
     SPACE(3.89) SKIP(15.59)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_clients B "?" ? ub clients
      TABLE: buf_goods B "?" ? ub goods
      TABLE: locked_icnt-doc B "?" ? ub icnt-doc
      TABLE: locked_icnt-line B "?" ? ub icnt-line
      TABLE: tt-icnt-doc T "?" NO-UNDO ub icnt-doc
      TABLE: tt-icnt-line T "?" NO-UNDO ub icnt-line
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-line b-del Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-icnt-doc.agnt IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-icnt-doc.boss IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-icnt-doc.doc-date IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-icnt-doc.fact-date IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-icnt-doc.obj-code IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN buf_clients.obj-name IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-icnt-doc.obj-type IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-icnt-doc.shift-date IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-icnt-doc.shift-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-icnt-doc.shift-num IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-icnt-doc.state-el-cnt IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-icnt-doc.state-mh-cnt IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-icnt-doc.wrkr IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-line
/* Query rebuild information for BROWSE br-line
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-icnt-line NO-LOCK WHERE
    tt-icnt-line.doc-code = tt-icnt-doc.doc-code ,
             FIRST buf_goods OUTER-JOIN WHERE
            buf_goods.gds-code        = tt-icnt-line.gds-code NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-line */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-icnt-doc ,Temp-Tables.buf_clients "
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON END-ERROR OF FRAME Dialog-Frame
OR STOP OF FRAME {&frame-name} DO:
  apply "choose" to b-quit in frame {&frame-name}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-icnt-doc.agnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-icnt-doc.agnt Dialog-Frame
ON LEAVE OF tt-icnt-doc.agnt IN FRAME Dialog-Frame /* Исп */
DO:
  if input frame {&frame-name} tt-icnt-doc.agnt <> tt-icnt-doc.agnt then do:
     run local-psn-chk in this-procedure ( input "agnt"
                                          ,input "leave").
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-icnt-doc.agnt Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF tt-icnt-doc.agnt IN FRAME Dialog-Frame /* Исп */
OR RETURN OF tt-icnt-doc.agnt IN FRAME {&frame-name} DO:
  run local-psn-chk in this-procedure ( input "agnt"
                                       ,input "ret-mouse").
  apply "entry" to tt-icnt-doc.agnt in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
   { gbl/stdbtn.i }
   run get-pump-from-chk-doc IN THIS-PROCEDURE NO-ERROR.
   IF ERROR-STATUS:ERROR THEN DO:
     message
     "Ошибка при добавлении строки из чека техпролива" skip
     error-status:get-message(1) skip
     return-value view-as alert-box  error.
     return no-apply.
   END.
   run OpenBr IN THIS-PROCEDURE NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chk Dialog-Frame
ON CHOOSE OF b-chk IN FRAME Dialog-Frame /* Чеки */
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
run str/chk-docs.w (
                 input parparentproc
                ,INPUT  '':U
                ,INPUT {&icnt-err}
                ,INPUT ?
                ,INPUT tt-icnt-doc.obj-type
                ,INPUT tt-icnt-doc.obj-code
                ,INPUT tt-icnt-doc.doc-code
                ,INPUT '':U
                ,input 0
                ,INPUT tt-icnt-doc.doc-date
                ,INPUT ?
                ,input 0
                ,output v-rid-list) no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
{ gbl/stdbtn.i }
  if p-mode = {&lookup} then.
  else do:
    if p-mode = {&update}  OR
    p-mode = {&add-def} then do:
    if not can-find (first tt-icnt-line where tt-icnt-line.doc-code = tt-icnt-doc.doc-code no-lock) then do:
      glog = yes.
      message
      "В документе нет строк, поэтому он удаляется."
      view-as alert-box
      question buttons OK-Cancel update glog.
      if glog then do:
        if p-mode = {&update} then do:
          delete LOCKED_icnt-doc.
          assign p-recid = ?.
          return.
        end.
        else do:
          assign p-recid = ?.
          return.
        end.
      end.
      else return no-apply.
    end.
    run proc-save IN THIS-PROCEDURE NO-ERROR.
    IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  end.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-next Dialog-Frame
ON CHOOSE OF b-next IN FRAME Dialog-Frame /* >> */
DO:
  { gbl/stdbtn.i }
  run reposition-icnt-doc in this-procedure
  (input 'next':U
  ).


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-notes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-notes Dialog-Frame
ON CHOOSE OF B-notes IN FRAME Dialog-Frame /* Примечания */
DO:
DEFINE VARIABLE v-notes AS CHARACTER NO-UNDO.
v-notes = tt-icnt-doc.PS.
run gbl/notes.w ( input p-mode, input-output v-notes ).
if tt-icnt-doc.PS <> v-notes then do:
   tt-icnt-doc.PS = v-notes.
end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prev Dialog-Frame
ON CHOOSE OF b-prev IN FRAME Dialog-Frame /* << */
DO:
  { gbl/stdbtn.i }
  run reposition-icnt-doc in this-procedure
  (input 'prev':U
  ).


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
  { gbl/stdbtn.i }
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  define variable v-ii as integer no-undo .
  define buffer buf_chk-doc for ub.chk-doc.
  case p-mode:
    when {&add-def} then do:
      MESSAGE
      "Выйти не сохранив все сделанные изменения?"
       VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
       IF NOT glog THEN RETURN NO-APPLY.
      do v-ii = 1 to num-entries(v-ptrlcheck):
        find first buf_chk-doc where
                 buf_chk-doc.doc-code = entry(v-ii, v-ptrlcheck) exclusive-lock.
        assign
        buf_chk-doc.out-2-code = ?
        .
      end.
      if available locked_icnt-doc then
       delete locked_icnt-doc.
       p-recid = ?.
    end.
    WHEN {&UPDATE} THEN DO:
      MESSAGE
      "Выйти не сохранив все сделанные изменения?"
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
      IF NOT glog THEN RETURN NO-APPLY.
      do v-ii = 1 to num-entries(v-ptrlcheck):
        find first buf_chk-doc where
                 buf_chk-doc.doc-code = entry(v-ii, v-ptrlcheck) exclusive-lock.
        if buf_chk-doc.out-2-code = '':U then do:
          assign
          buf_chk-doc.out-2-code = ?
          .
        end.
      end.
    END.
  END CASE.
  p-next-prev = "quit".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-icnt-doc.boss
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-icnt-doc.boss Dialog-Frame
ON LEAVE OF tt-icnt-doc.boss IN FRAME Dialog-Frame /* М-р */
DO:
    if input frame {&frame-name} tt-icnt-doc.boss <> tt-icnt-doc.boss then do:
    run local-psn-chk in this-procedure ( input "boss", input "leave").
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-icnt-doc.boss Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF tt-icnt-doc.boss IN FRAME Dialog-Frame /* М-р */
OR RETURN OF tt-icnt-doc.boss IN FRAME {&frame-name} DO:
  run local-psn-chk in this-procedure ( input "boss", input "ret-mouse").
  apply "entry" to tt-icnt-doc.boss in frame {&frame-name}.
  return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-agnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-agnt Dialog-Frame
ON CHOOSE OF r-agnt IN FRAME Dialog-Frame /* r-acc */
DO:
  run local-psn-chk in this-procedure ( input "agnt", input "button").
  apply "entry" to tt-icnt-doc.agnt in FRAME {&FRAME-NAME}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-boss
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-boss Dialog-Frame
ON CHOOSE OF r-boss IN FRAME Dialog-Frame /* r-acc */
DO:
  run local-psn-chk in this-procedure ( input "boss", input "button").
  apply "entry" to tt-icnt-doc.boss in FRAME {&FRAME-NAME}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-wrkr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-wrkr Dialog-Frame
ON CHOOSE OF r-wrkr IN FRAME Dialog-Frame /* r-acc */
DO:
  run local-psn-chk in this-procedure ( input "wrkr", input "button").
  apply "entry" to tt-icnt-doc.wrkr in FRAME {&FRAME-NAME}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-icnt-doc.wrkr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-icnt-doc.wrkr Dialog-Frame
ON LEAVE OF tt-icnt-doc.wrkr IN FRAME Dialog-Frame /* Кл-к */
DO:
    if input frame {&frame-name} tt-icnt-doc.wrkr <> tt-icnt-doc.wrkr then do:
    run local-psn-chk in this-procedure ( input "wrkr", input "leave").
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-icnt-doc.wrkr Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF tt-icnt-doc.wrkr IN FRAME Dialog-Frame /* Кл-к */
OR RETURN OF tt-icnt-doc.wrkr IN FRAME {&frame-name} DO:
  run local-psn-chk in this-procedure ( input "wrkr", input "ret-mouse").
  apply "entry" to tt-icnt-doc.wrkr in frame {&frame-name}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-line
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

ON value-changed OF br-line do:
 { gbl/stdbtn.i }
end.

ON RETURN OF tt-icnt-line.state-mh-cnt IN BROWSE br-line,
            tt-icnt-line.state-el-cnt IN BROWSE br-line do:
  APPLY "LEAVE" to self.
end.



ON LEAVE OF tt-icnt-line.state-mh-cnt IN BROWSE br-line DO:
define buffer buf_tt-icnt-line for tt-icnt-line.
if tt-icnt-line.state-mh-cnt <> DECIMAL(tt-icnt-line.state-mh-cnt:SCREEN-VALUE IN BROWSE br-line) then do transaction:
   find first buf_tt-icnt-line exclusive-lock where
              recid(buf_tt-icnt-line) = recid(tt-icnt-line).
   ASSIGN
   buf_tt-icnt-line.state-mh-cnt = DECIMAL(tt-icnt-line.state-mh-cnt:SCREEN-VALUE IN BROWSE br-line).
   display
   {&sort-clmn_6-br-dtl} @ v-delta-line
   with  browse br-line.
   run recalc-icnt in this-procedure .
end.
run display-value in this-procedure .
END.

ON LEAVE OF tt-icnt-line.state-el-cnt IN BROWSE br-line DO:
define buffer buf_tt-icnt-line for tt-icnt-line.
if tt-icnt-line.state-el-cnt <> DECIMAL(tt-icnt-line.state-el-cnt:SCREEN-VALUE IN BROWSE br-line) then do transaction:
  find first buf_tt-icnt-line  exclusive-lock where
          recid(buf_tt-icnt-line) = recid(tt-icnt-line).
  ASSIGN
  buf_tt-icnt-line.state-el-cnt = DECIMAL(tt-icnt-line.state-el-cnt:SCREEN-VALUE IN BROWSE br-line).
  display
  {&sort-clmn_6-br-dtl} @ v-delta-line
  with  browse br-line.
  run recalc-icnt in this-procedure .
end.
run display-value in this-procedure .
END.


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

{ gbl/srt-clmn.i
&browse-name = "br-line"
&frame-name  = {&frame-name}
&table-name = "tt-icnt-line"
&ext-col = 9
&start-column  = 4
&label-clmn_1  = "{&label-clmn_1-br-dtl}"
&sort-clmn_1   = "{&sort-clmn_1-br-dtl}"
&label-clmn_2  = "{&label-clmn_2-br-dtl}"
&sort-clmn_2   = "{&sort-clmn_2-br-dtl}"
&label-clmn_3  = "{&label-clmn_3-br-dtl}"
&sort-clmn_3   = "{&sort-clmn_3-br-dtl}"
&label-clmn_4  = "{&label-clmn_4-br-dtl}"
&sort-clmn_4   = "{&sort-clmn_4-br-dtl}"
&label-clmn_5  = "{&label-clmn_5-br-dtl}"
&sort-clmn_5   = "{&sort-clmn_5-br-dtl}"
&label-clmn_6  = "{&label-clmn_6-br-dtl}"
&sort-clmn_6   = "{&sort-clmn_6-br-dtl}"
&label-clmn_8  = "{&label-clmn_8-br-dtl}"
&sort-clmn_8   = "{&sort-clmn_8-br-dtl}"
&label-clmn_9  = "{&label-clmn_9-br-dtl}"
&sort-clmn_9   = "{&sort-clmn_9-br-dtl}"
&open-query           = "{&my-OPEN-QUERY-br-line} BY ~{&sort-clmn_~{&clmn_num~}~} ."
&open-query-otherwise = "run Openbr in this-procedure ."
&re-move-clmn         = "yes"
&mv-brw-default       = "yes" }


{ gbl/f2.i br-line goods-recid get-gds-rec  parparentproc }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
p-next-prev = '':U.
v-mode = p-mode.
n-p:
do while p-next-prev = '':U :

  MAIN-BLOCK:
  DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
     ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
     { gbl/getcntxt.i GET}
     if LOOKUP(p-mode, ({&update}  + {&delim-par} + {&add-def} + {&delim-par} + {&lookup}), {&delim-par} ) = 0 then do:
          message
          vss-workfile vss-revision vss-description skip
          substitute("Неверный параметр вызова p-mode=&1", p-mode)
          view-as alert-box ERROR.
          undo, return error.
      end.
      if p-obj-type <> {&shop} then DO:
          message
          vss-workfile vss-revision vss-description skip
          substitute("Неверный параметр вызова p-obj-type=&1", p-obj-type)
          view-as alert-box ERROR.
          undo, return error.
      end.
      FIND FIRST buf_clients NO-LOCK WHERE
                buf_Clients.obj-type = p-obj-type
           AND buf_clients.obj-code = p-obj-code NO-ERROR.
      IF NOT AVAILABLE buf_clients THEN DO:
        MESSAGE
        substitute("Неверное значение параметров p-obj-type = &1 и/или p-obj-code=&2"
                  , p-obj-type
                  , p-obj-code)
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
      END.
      { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
      if not p-mode = {&lookup} THEN DO:
         p-next-prev = '':U.
        IF buf_clients.db-num <> v-cntxt-db-num THEN DO:
            MESSAGE
            substitute("Неверное значение параметров p-obj-type = &1 и/или p-obj-code=&2&3" +
                      "Добавление и изменение документа счетчиков ТРК возможно только в БД объекта&3" +
                      "БД для &1&2 - &4, текущая БД - &5"
                      , p-obj-type
                      , p-obj-code
                      , {&NEW-LINE}
                      , buf_clients.db-num
                      , v-cntxt-db-num)
            VIEW-AS ALERT-BOX ERROR.
            UNDO, RETURN ERROR.

        END.
      END.
      if p-mode <> {&lookup} then do:
        p-next-prev = "quit".
      end.
      run fill-tables in this-procedure no-error.
      if error-status:error then return error.
      RUN Myenable IN THIS-PROCEDURE.
      IF new-opened THEN DO:
        { gbl/mv-clmn.i
         &ext-col      = 9
         &frame-name   = "{&frame-name}"
         &browse-name  = "br-line"
         &table-name   = "tt-icnt-line"
         &start-column = 4
        }
        new-opened = no.
      END.
      WAIT-FOR GO OF FRAME {&FRAME-NAME}.
    END.
END. /*n-p: */
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-value Dialog-Frame
PROCEDURE display-value :
display
tt-icnt-doc.state-el-cnt
tt-icnt-doc.state-mh-cnt
(tt-icnt-doc.state-el-cnt - tt-icnt-doc.state-mh-cnt) @ v-delta
/*tt-icnt-doc.meas-el-cnt*/
with frame {&frame-name}.

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
  DISPLAY wrkr-name agnt-name boss-name v-delta
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buf_clients THEN
    DISPLAY buf_clients.obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-icnt-doc THEN
    DISPLAY tt-icnt-doc.doc-date tt-icnt-doc.fact-date tt-icnt-doc.shift-date
          tt-icnt-doc.shift-num tt-icnt-doc.shift-name tt-icnt-doc.wrkr
          tt-icnt-doc.agnt tt-icnt-doc.boss tt-icnt-doc.obj-code
          tt-icnt-doc.obj-type tt-icnt-doc.state-el-cnt tt-icnt-doc.state-mh-cnt
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-prev b-next b-chk B-notes B-hist B-Help
         tt-icnt-doc.doc-date tt-icnt-doc.fact-date tt-icnt-doc.shift-date
         tt-icnt-doc.shift-num tt-icnt-doc.shift-name tt-icnt-doc.wrkr r-wrkr
         tt-icnt-doc.agnt r-agnt tt-icnt-doc.boss r-boss B-add b-del br-line
         tt-icnt-doc.obj-code tt-icnt-doc.obj-type buf_clients.obj-name
         wrkr-name tt-icnt-doc.state-el-cnt agnt-name tt-icnt-doc.state-mh-cnt
         boss-name v-delta
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame
PROCEDURE fill-tables :
define variable v-today as date      no-undo.

FOR EACH tt-icnt-line:
    DELETE tt-icnt-line.
END.
FOR EACH tt-icnt-doc:
    DELETE tt-icnt-doc.
END.
IF p-mode = {&add-def} then do:
    tr:
    do transaction on error undo tr, return error return-value
                   on stop  undo tr, return error return-value
                   on quit  undo tr, return error return-value :
       run waitfram-show in this-procedure ( INPUT "Создаем документ." ).
       create tt-icnt-doc.
       { gbl/curobjdt.i p-obj-type p-obj-code v-today }
       assign
       tt-icnt-doc.ext-doc-type = {&TDEICNT_err-meas}
       tt-icnt-doc.doc-type  = {&icnt-err}
       tt-icnt-doc.host-code = v-host-code
       tt-icnt-doc.obj-type  = p-obj-type
       tt-icnt-doc.obj-code  = p-obj-code
       tt-icnt-doc.status_   = {&g___new}
       tt-icnt-doc.flag_     = no
       tt-icnt-doc.creid     = v-cntxt-userid
       tt-icnt-doc.PS        = "@"
       tt-icnt-doc.doc-date  = v-today
       .
       run waitfram-hide in this-procedure .
   end. /*transaction*/
   run get-pump-from-chk-doc IN THIS-PROCEDURE NO-ERROR.
   IF ERROR-STATUS:ERROR  THEN undo, RETURN ERROR.
END.
ELSE DO:
  if p-mode = {&lookup} then do:
    FIND FIRST locked_icnt-doc NO-LOCK WHERE
                recid(locked_icnt-doc) = p-recid.
  end.
  ELSE do:
    DO TRANSACTION
      ON ERROR UNDO, RETURN ERROR:
      FIND FIRST locked_icnt-doc EXCLUSIVE-LOCK WHERE
                 recid(locked_icnt-doc) = p-recid.
    END.
  END.
  IF NOT AVAIL locked_icnt-doc THEN return error.
  if locked_icnt-doc.status_ = {&fact} and p-mode <> {&lookup} then do:
     message
     substitute("Документ счетчиков ТРК &1 закрыт до статуса &2&3Изменения не допускаются"
                ,locked_icnt-doc.doc-code
                ,LOCKED_icnt-doc.STATUS_
                , {&NEW-LINE}
                )
     view-as alert-box error.
     return error.
  end.
  CREATE tt-icnt-doc.
  BUFFER-COPY LOCKED_icnt-doc TO tt-icnt-doc.
  FOR EACH LOCKED_icnt-line NO-LOCK WHERE
          LOCKED_icnt-line.doc-code = LOCKED_icnt-doc.doc-code:
     CREATE tt-icnt-line.
     BUFFER-COPY LOCKED_icnt-line TO tt-icnt-line.
  END.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-gds-rec Dialog-Frame
PROCEDURE get-gds-rec :
IF AVAILABLE buf_goods then
gds-rec = recid(buf_goods).
ELSE BELL.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-pump-from-chk-doc Dialog-Frame
PROCEDURE get-pump-from-chk-doc :
define buffer buf_tt-icnt-line for tt-icnt-line.
define variable varcur-pump as logical no-undo.
define variable varnum      as integer no-undo.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
define variable v-loc-ptrlcheck as character no-undo .
define buffer buf_chk-doc for ub.chk-doc.
/*Заполняем временную таблицу для считывания данных из чека*/
ASSIGN
v-rid-list = "":U.
run str/chk-docs.w (
                 input parparentproc
                ,INPUT  'b-sel,b-mark':U
                ,INPUT "to-" + {&icnt-err}
                ,INPUT ?
                ,INPUT tt-icnt-doc.obj-type
                ,INPUT tt-icnt-doc.obj-code
                ,INPUT tt-icnt-doc.doc-code
                ,INPUT '':U
                ,input 0
                ,INPUT tt-icnt-doc.doc-date
                ,INPUT ?
                ,input 0
                ,output v-rid-list) no-error.
 IF v-rid-list = "":U  THEN DO:
   RETURN error.
 END.
_ii:
DO v-ii = 1 TO NUM-ENTRIES(v-rid-list)
on error undo _ii, next _ii
:
  FIND FIRST buf_chk-doc no-LOCK WHERE
         RECID(buf_chk-doc) = INTEGER(ENTRY(v-ii, v-rid-list)) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
  END.
  v-loc-ptrlcheck = v-ptrlcheck.
  run add-icnt-line-err IN THIS-PROCEDURE (
                                             input p-mode
                                            ,input buf_chk-doc.doc-code
                                            ,input tt-icnt-doc.doc-code
                                            ,INPuT tt-icnt-doc.doc-date
                                            ,INPUT tt-icnt-doc.obj-type
                                            ,INPUT tt-icnt-doc.obj-code
                                            ,input-output v-loc-ptrlcheck
                                            ,BUFFER buf_tt-icnt-line) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     MESSAGE
     "Ошибка при добавлении строки в документ" SKIP
     ERROR-STATUS:GET-MESSAGE(1) SKIP
     RETURN-VALUE SKIP
     VIEW-AS ALERT-BOX ERROR.
     UNDO _ii, next _ii.
  END.
  v-ptrlcheck = v-loc-ptrlcheck.
END.
do transaction on error undo, return error :
  RUN recalc-icnt IN THIS-PROCEDURE NO-ERROR.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-psn-chk Dialog-Frame
PROCEDURE local-psn-chk :
define input parameter p-man    as character no-undo.
define input parameter p-action as character no-undo.
DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
if p-man = "wrkr" and p-action = "ret-mouse" then do:
   { str/psn-chk.i wrkr ret-mouse tt-icnt-doc v-ref-rec }
end.
if p-man = "wrkr" and p-action = "button" then do:
   { str/psn-chk.i wrkr button tt-icnt-doc v-ref-rec }
end.
if p-man = "wrkr" and p-action = "leave" then do:
   { str/psn-chk.i wrkr leave tt-icnt-doc v-ref-rec }
end.
if p-man = "agnt" and p-action = "ret-mouse" then do:
   { str/psn-chk.i agnt ret-mouse tt-icnt-doc v-ref-rec }
end.
if p-man = "agnt" and p-action = "button" then do:
   { str/psn-chk.i agnt button tt-icnt-doc v-ref-rec }
end.
if p-man = "agnt" and p-action = "leave" then do:
   { str/psn-chk.i agnt leave tt-icnt-doc v-ref-rec }
end.
if p-man = "boss" and p-action = "ret-mouse" then do:
   { str/psn-chk.i boss ret-mouse tt-icnt-doc v-ref-rec }
end.
if p-man = "boss" and p-action = "button" then do:
   { str/psn-chk.i boss button tt-icnt-doc v-ref-rec }
end.
if p-man = "boss" and p-action = "leave" then do:
   { str/psn-chk.i boss leave tt-icnt-doc v-ref-rec }
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
ASSIGN
br-line:NUM-LOCKED-COLUMNS IN FRAME {&frame-name} = 3
frame {&frame-name}:title = substitute("(&1) :   ДОКУМЕНТ ИЗМЕРЕНИЯ ПОГРЕШНОСТИ СЧЕТЧИКОВ ТРК - &2 № &3 - &4"
                                       , substring (buf_clients.obj-name, 1, 35)
                                       , tt-icnt-doc.STATUS_
                                       , tt-icnt-doc.doc-code
                                       , p-mode).
disable
all with frame {&frame-name}.
enable
b-exit WHEN p-mode <> {&LOOKUP}
b-quit
b-help
br-line
b-hist
b-notes
b-chk
b-next WHEN p-mode = {&LOOKUP}
b-prev WHEN p-mode = {&LOOKUP}
tt-icnt-doc.wrkr WHEN (p-mode <> {&LOOKUP} AND tt-icnt-doc.STATUS_ = {&g___NEW})
tt-icnt-doc.agnt WHEN (p-mode <> {&LOOKUP} AND tt-icnt-doc.STATUS_ = {&g___NEW})
tt-icnt-doc.boss WHEN (p-mode <> {&LOOKUP} AND tt-icnt-doc.STATUS_ = {&g___NEW})
r-wrkr WHEN (p-mode <> {&LOOKUP} AND tt-icnt-doc.STATUS_ = {&g___NEW})
r-agnt WHEN (p-mode <> {&LOOKUP} AND tt-icnt-doc.STATUS_ = {&g___NEW})
r-boss WHEN (p-mode <> {&LOOKUP} AND tt-icnt-doc.STATUS_ = {&g___NEW})
/*b-add WHEN (p-mode <> {&LOOKUP} AND tt-icnt-doc.STATUS_ = {&g___NEW})*/
WITH frame {&frame-name}.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_icnt-doc_upd-el-cnt':U
  {&cntxt-object}
  buf_clients.host-code
  buf_clients.obj-type
  buf_clients.obj-code
  0
  0
  0
  false
  glog
}

/*if not glog then do:                                                      */
/*    ASSIGN {&sort-clmn_4-br-dtl}:READ-ONLY in browse {&browse-name} = YES.*/
/*end.                                                                      */
if p-mode = {&lookup} then do:
   ASSIGN
   {&sort-clmn_5-br-dtl}:READ-ONLY in browse {&browse-name} = YES
   .
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  .
  hide b-exit in frame {&frame-name} .
end.
DISPLAY
tt-icnt-doc.obj-code
tt-icnt-doc.obj-type
tt-icnt-doc.fact-date
tt-icnt-doc.doc-date
tt-icnt-doc.shift-date
tt-icnt-doc.shift-num
tt-icnt-doc.shift-name
with frame {&frame-name}.
HIDE
b-add b-del IN FRAME {&FRAME-NAME}.
run display-value in this-procedure .
{ str/psn-chk.i wrkr on tt-icnt-doc v-ref-rec }
{ str/psn-chk.i agnt on tt-icnt-doc v-ref-rec }
{ str/psn-chk.i boss ON tt-icnt-doc v-ref-rec }
RUN Openbr IN THIS-PROCEDURE .
if p-mode = {&lookup} then do:
if p-icnt-line-rec <> ? then reposition {&browse-name} to recid p-icnt-line-rec no-error.
  apply "entry" to {&browse-name} in frame {&frame-name}.
end.
if p-mode = {&update} then do:
  apply "entry" to {&browse-name} in frame {&frame-name}.
end.
if num-results("br-line") > 0 then do:
   if br-line:refresh() then.
end.
hide
b-hist
in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
{&my-OPEN-QUERY-br-line}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
define variable v-recid as recid no-undo .
if p-mode = {&lookup} then return .
assign
frame {&frame-name}
tt-icnt-doc.wrkr
tt-icnt-doc.agnt
tt-icnt-doc.boss.
if p-mode = {&update} then do:
  v-recid = recid(locked_icnt-doc).
end.
run str/icntdoc1.p (
                 INPUT p-mode
                ,input no /*p-silent*/
                ,input-output v-recid
                ,INPUT tt-icnt-doc.doc-code
                ,input tt-icnt-doc.obj-type
                ,input tt-icnt-doc.obj-code
                ,input tt-icnt-doc.host-code
                ,input {&icnt-err}
                ,input {&TDEICNT_err-meas}
                ,INPUT tt-icnt-doc.wrkr
                ,INPUT tt-icnt-doc.agnt
                ,INPUT tt-icnt-doc.boss
                ,INPUT tt-icnt-doc.doc-date
                ,input tt-icnt-doc.meas-el-cnt
                ,input tt-icnt-doc.state-el-cnt
                ,input tt-icnt-doc.state-mh-cnt
                ,input tt-icnt-doc.PS
                ,input tt-icnt-doc.creid
                ,input v-ptrlcheck
                ,input table tt-icnt-line
                 ) NO-ERROR.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.
p-recid = v-recid.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE recalc-icnt Dialog-Frame
PROCEDURE recalc-icnt :
DEFINE VARIABLE v-meas-el-cnt AS DECIMAL NO-UNDO.
DEFINE VARIABLE v-state-el-cnt AS DECIMAL NO-UNDO.
DEFINE VARIABLE v-state-mh-cnt AS DECIMAL NO-UNDO.
define buffer buf_tt-icnt-line for tt-icnt-line.
for each buf_tt-icnt-line where buf_tt-icnt-line.doc-code = tt-icnt-doc.doc-code:
  ASSIGN
  v-meas-el-cnt = v-meas-el-cnt + buf_tt-icnt-line.meas-el-cnt
  v-state-el-cnt = v-state-el-cnt + buf_tt-icnt-line.state-el-cnt
  v-state-mh-cnt = v-state-mh-cnt + buf_tt-icnt-line.state-mh-cnt
  .
end.
assign
tt-icnt-doc.meas-el-cnt  = v-meas-el-cnt
tt-icnt-doc.state-el-cnt = v-state-el-cnt
tt-icnt-doc.state-mh-cnt = v-state-mh-cnt
.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-icnt-doc Dialog-Frame
PROCEDURE reposition-icnt-doc :
define input parameter p-direction as character no-undo .
define variable v-new-icnt-doc-recid as recid no-undo .


do
on error undo, return error
:


  /*
  Возможные значения v-direction
  first,last,prev,next
  */

  if valid-handle(p-call-prog)
  then do:
    run reposition-icnt-doc in p-call-prog
      (input  p-direction
      ,output v-new-icnt-doc-recid
      ).

    if v-new-icnt-doc-recid <> ?
    then do:
      define buffer buf_icnt-doc for ub.icnt-doc .
      find first buf_icnt-doc no-lock
        where recid(buf_icnt-doc) = v-new-icnt-doc-recid
        no-error .
      assign
      p-recid = v-new-icnt-doc-recid
      p-next-prev = '':U
      .
    end.
  end.
  else do:
    message "Список документов не определен." view-as alert-box INFORMATION .
    return no-apply.
  end.
  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME