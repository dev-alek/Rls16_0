&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_icnt-doc FOR ub.icnt-doc.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список документов по счетчикам ТРК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/16/07
Author: Bakhtadze Natalya
Creation date: 07/16/07

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER bttns AS character NO-UNDO.
DEFINE INPUT PARAMETER p-list-mode AS character NO-UNDO.
DEFINE INPUT PARAMETER p-status_ AS character NO-UNDO.
DEFINE INPUT PARAMETER p-doc-type AS character NO-UNDO.
define input parameter p-host-code as integer no-undo .
DEFINE INPUT PARAMETER p-obj-type AS character NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rid-list AS character NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список документов по счетчикам ТРК".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }
{ cmp/showinf.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ cmp/library.i  }
{ cmp/mrk-strf.i }
{ gbl/color.i    }
{ str/lib-trn.i }
{ gbl/getcntxt.i DEF }
{ str/shftnamf.i icnt-doc }
{ gbl/fltopend.i defproc }
define variable sort-column-name as character no-undo.
define variable filter-point     as character NO-UNDO INIT "inctdocs".
define variable filter-label     as character NO-UNDO INIT "Список документов по счетчикам ТРК".
define variable filter-point0     as character NO-UNDO INIT "inctdocs".
define variable filter-label0     as character NO-UNDO INIT "Список документов по счетчикам ТРК".
DEFINE VARIABLE v-icnt-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_clients FOR ub.clients.
define buffer buf_sysconf for ub.sysconf.

FUNCTION fine-time RETURN CHARACTER (buffer bf_i-doc for ub.icnt-doc).
   return string(bf_i-doc.fact-time,"hh:mm:ss").
END FUNCTION.
FUNCTION func-delta RETURN DECIMAL (buffer bf_i-doc for ub.icnt-doc).
   return (bf_i-doc.state-el-cnt - bf_i-doc.state-mh-cnt).
END FUNCTION.
define variable varfunc-obj         as character format "x(9)" no-undo.
define variable varshort-doc-date   as character format "x(5)" no-undo.
define variable varshort-shift-date as character format "x(5)" no-undo.
define variable varfine-time        as character format "x(8)" no-undo.
define variable varfunc-delta       like ub.icnt-doc.state-el-cnt no-undo.

&scop label-clmn_0     '*'
&scop label-clmn_1     'Статус'
&scop label-clmn_2     'Документ'
&scop label-clmn_3     'Дата'
&scop label-clmn_4     'Факт'
&scop label-clmn_5     'Время'
&scop label-clmn_6     'Смена'
&scop label-clmn_7     '№'
&scop label-clmn_8     'Объект'
&scop label-clmn_9     'Количество!по счетчику'
&scop label-clmn_10    'Количество!по мернику'
&scop label-clmn_11    'Разница'
&scop label-clmn_12    'Измерения!электронных!счетчиков'

&scop sort-clmn_0      mark-string(recid(X_icnt-doc), v-rid-list)
&scop sort-clmn_1      X_icnt-doc.status_
&scop sort-clmn_2      X_icnt-doc.doc-code
&scop sort-clmn_3      X_icnt-doc.doc-date
&scop sort-clmn_4      X_icnt-doc.fact-date
&scop sort-clmn_5      string(X_icnt-doc.fact-time, 'HH:MM:SS')
&scop sort-clmn_6      X_icnt-doc.shift-date
&scop sort-clmn_7      shift-name (buffer X_icnt-doc)
&scop sort-clmn_8      (X_icnt-doc.obj-type + STRING(X_icnt-doc.obj-code))
&scop sort-clmn_9      X_icnt-doc.state-el-cnt
&scop sort-clmn_10     X_icnt-doc.state-mh-cnt
&scop sort-clmn_11     (X_icnt-doc.state-el-cnt - X_icnt-doc.state-mh-cnt)
&scop sort-clmn_12     X_icnt-doc.meas-el-cnt

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-i-docs

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_icnt-doc

/* Definitions for BROWSE BR-i-docs                                     */
&Scoped-define FIELDS-IN-QUERY-BR-i-docs {&sort-clmn_0} {&sort-clmn_1} {&sort-clmn_2} {&sort-clmn_3} {&sort-clmn_4} {&sort-clmn_5} {&sort-clmn_6} {&sort-clmn_7} {&sort-clmn_8} {&sort-clmn_9} {&sort-clmn_10} {&sort-clmn_11} {&sort-clmn_12}
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-i-docs {&sort-clmn_12}
&Scoped-define SELF-NAME BR-i-docs
&Scoped-define QUERY-STRING-BR-i-docs FOR EACH X_icnt-doc NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-i-docs OPEN QUERY br-i-docs FOR EACH X_icnt-doc NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-i-docs X_icnt-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BR-i-docs X_icnt-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame X_icnt-doc.creid
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame X_icnt-doc.creid
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame X_icnt-doc
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame X_icnt-doc
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH X_icnt-doc SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH X_icnt-doc SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame X_icnt-doc
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame X_icnt-doc


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS X_icnt-doc.creid
&Scoped-define ENABLED-TABLES X_icnt-doc
&Scoped-define FIRST-ENABLED-TABLE X_icnt-doc
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel b-add b-chg b-del b-lkp ~
b-print b-sch B-Help b-close BR-i-docs ED-notes mark-num obj-name boss-name ~
agnt-name wrkr-name
&Scoped-Define DISPLAYED-FIELDS X_icnt-doc.creid
&Scoped-define DISPLAYED-TABLES X_icnt-doc
&Scoped-define FIRST-DISPLAYED-TABLE X_icnt-doc
&Scoped-Define DISPLAYED-OBJECTS ED-notes mark-num obj-name boss-name ~
agnt-name wrkr-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-close
     LABEL "Закрыть"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-print
     LABEL "&Печать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sch
     LABEL "Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE ED-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2.33 NO-UNDO.

DEFINE VARIABLE agnt-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Исп"
      VIEW-AS TEXT
     SIZE 14.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE boss-name AS CHARACTER FORMAT "X(256)":U
     LABEL "М-р"
      VIEW-AS TEXT
     SIZE 14.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE obj-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Объект"
      VIEW-AS TEXT
     SIZE 34 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE wrkr-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Кл-к"
      VIEW-AS TEXT
     SIZE 14.5 BY .67
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-i-docs FOR
      X_icnt-doc SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      X_icnt-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-i-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-i-docs Dialog-Frame _FREEFORM
  QUERY BR-i-docs NO-LOCK DISPLAY
      {&sort-clmn_0}                     COLUMN-LABEL {&label-clmn_0} format "x(2)"
{&sort-clmn_1}                           COLUMN-LABEL {&label-clmn_1} format "x(6)"
{&sort-clmn_2}                           COLUMN-LABEL {&label-clmn_2}
{&sort-clmn_3}                           COLUMN-LABEL {&label-clmn_3}
{&sort-clmn_4}                           column-label {&label-clmn_4}
{&sort-clmn_5}                           column-label {&label-clmn_5}
{&sort-clmn_6}                           COLUMN-LABEL {&label-clmn_6}
{&sort-clmn_7}                           COLUMN-LABEL {&label-clmn_7} format "x(6)"
{&sort-clmn_8}                           COLUMN-LABEL {&label-clmn_8}
{&sort-clmn_9}                           column-label {&label-clmn_9} FORMAT "->>>,>>>,>>>,>>>,>>9.999"
{&sort-clmn_10}                          column-label {&label-clmn_10} FORMAT "->>>,>>>,>>>,>>>,>>9.999"
{&sort-clmn_11}                          column-label {&label-clmn_11} FORMAT "->>>,>>>,>>>,>>>,>>9.999"
{&sort-clmn_12}                          column-label {&label-clmn_12} FORMAT "->>>,>>>,>>>,>>>,>>9.999"
ENABLE
{&sort-clmn_12}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.5 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     b-add AT ROW 1 COL 31
     b-chg AT ROW 1 COL 41
     b-del AT ROW 1 COL 51
     b-lkp AT ROW 1 COL 61
     b-print AT ROW 1 COL 89
     b-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     b-close AT ROW 2 COL 31
     BR-i-docs AT ROW 3 COL 1
     ED-notes AT ROW 21 COL 1 NO-LABEL
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     obj-name AT ROW 19 COL 52
     boss-name AT ROW 20 COL 1
     agnt-name AT ROW 20 COL 25
     wrkr-name AT ROW 20 COL 49
     X_icnt-doc.creid AT ROW 20 COL 71.75
          LABEL "Опер"
           VIEW-AS TEXT
          SIZE 21.5 BY .67
          FGCOLOR 4
     SPACE(0.00) SKIP(2.79)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_icnt-doc B "?" ? ub icnt-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-i-docs b-close Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN agnt-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN boss-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN X_icnt-doc.creid IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN obj-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN wrkr-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-i-docs
/* Query rebuild information for BROWSE BR-i-docs
     _START_FREEFORM
OPEN QUERY br-i-docs FOR EACH X_icnt-doc NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-i-docs */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.X_icnt-doc"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame
DO:
  p-rid-list = v-rid-list.
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


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  run proc-b-add IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  run proc-b-chg IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-close
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-close Dialog-Frame
ON CHOOSE OF b-close IN FRAME Dialog-Frame /* Закрыть */
DO:
  DEFINE VARIABLE v-icnt-rec AS RECID NO-UNDO.
  DEFINE VARIABLE glog AS LOGICAL no-undo.
  IF X_icnt-doc.status_ = {&fact} THEN DO:
      message
      "Данный документ закрыт на факт."
      VIEW-AS ALERT-BOX .
    RETURN NO-APPLY.  
  END.  
  IF NOT AVAILABLE X_icnt-doc THEN RETURN NO-APPLY.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_icnt-doc_fact':U
    {&cntxt-object}
    X_icnt-doc.host-code
    X_icnt-doc.obj-type
    X_icnt-doc.obj-code
    0
    0
    0
    true
    glog
  }
  IF NOT glog THEN RETURN NO-APPLY.
  MESSAGE
  SUBSTITUTE("Вы действительно хотите закрыть документ счетчиков ТРК &1?", X_icnt-doc.doc-code)
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.

  IF NOT glog THEN RETURN NO-APPLY.
  v-icnt-rec = RECID(X_icnt-doc).
  run str/icntdoc2.p ( INPUT RECID(X_icnt-doc)
                 ,INPUT NO /*p-silent*/
                 ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  run Openbr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
  REPOSITION br-i-docs TO RECID v-icnt-rec NO-ERROR.
  APPLY "ENtRY" TO br-i-docs.
  APPLY "value-changed" TO br-i-docs.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO INIT YES.
  IF NOT AVAILABLE X_icnt-doc THEN RETURN NO-APPLY.
  message
  substitute("Удалить документ  счетчиков ТРК № &1?   Вы уверены ?"
             , X_icnt-doc.doc-code)
  view-as alert-box question buttons OK-Cancel update glog.
  IF NOT glog THEN RETURN NO-APPLY.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_icnt-doc_preparation':U
  {&cntxt-object}
  X_icnt-doc.host-code
  X_icnt-doc.obj-type
  X_icnt-doc.obj-code
  0
  0
  0
  true
  glog
}
  v-icnt-rec = RECID(X_icnt-doc).
  glog = br-i-docs:select-next-row().
  if not glog then glog = br-i-docs:select-prev-row().

  run str/icntdoc3.p ( INPUT v-icnt-rec
                 ,INPUT NO /*p-silent*/
                 ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  run Openbr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
  REPOSITION br-i-docs TO RECID v-icnt-rec NO-ERROR.
  APPLY "ENtRY" TO br-i-docs.
  APPLY "value-changed" TO br-i-docs.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  run proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if available X_icnt-doc then do:
    { gbl/markstrn.i X_icnt-doc v-rid-list }
    loc#log = br-i-docs:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-i-docs:select-next-row ().
        apply "VALUE-CHANGED" to br-i-docs in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-i-docs in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-b-print IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_icnt-doc ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_icnt-doc ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-i-docs
&Scoped-define SELF-NAME BR-i-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-i-docs Dialog-Frame
ON RETURN OF BR-i-docs IN FRAME Dialog-Frame
OR MOUSE-SELECT-DBLCLICK OF {&browse-name} IN FRAME {&frame-name} DO:
  apply "choose" to b-lkp in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-i-docs Dialog-Frame
ON VALUE-CHANGED OF BR-i-docs IN FRAME Dialog-Frame
DO:
DEFINE BUFFER buf_clients FOR ub.clients.
    if available X_icnt-doc then do:
    find FIRST buf_clients NO-LOCK where
        buf_clients.obj-type = {&prs}
    and buf_clients.obj-code = X_icnt-doc.boss no-error.
    if available buf_clients  then  DO:
      boss-name = buf_clients.obj-name.
    END.
    else do:
      boss-name = ?.
    END.
    find FIRST buf_clients NO-LOCK where
             buf_clients.obj-type = {&prs}
          and buf_clients.obj-code = X_icnt-doc.agnt no-error.
    if available buf_clients then do:
        agnt-name = buf_clients.obj-name.
     end.
    else do:
        agnt-name = ?.
    END.
    find FIRST buf_clients NO-LOCK where
              buf_clients.obj-type = {&prs}
           and buf_clients.obj-code = X_icnt-doc.wrkr no-error.
    if available buf_clients then do:
        wrkr-name = buf_clients.obj-name.
    end.
    else do:
        wrkr-name = ?.
    END.
    find FIRST buf_clients NO-LOCK where
              buf_clients.obj-type = X_icnt-doc.obj-type
          and buf_clients.obj-code = X_icnt-doc.obj-code no-error.
    if available buf_clients then do:
       obj-name  = buf_clients.obj-name.
    end.
    else do:
        obj-name = ?.
    END.
    ASSIGN ed-notes = X_icnt-doc.PS.
    DISPLAY
    ed-notes
    obj-name
    boss-name
    agnt-name
    wrkr-name
    X_icnt-doc.creid
    with frame {&frame-name}.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ED-notes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ED-notes Dialog-Frame
ON ENTRY OF ED-notes IN FRAME Dialog-Frame
DO:
if not available X_icnt-doc then RETURN NO-APPLY.

assign
v-icnt-rec = recid (X_icnt-doc).
if X_icnt-doc.status_ <> {&fact}
and substring (X_icnt-doc.PS, 1, 1) = "@" THEN DO:
  message
  "Чтобы программа не могла заново переписать Ваше примечание, удалите знак @."
  VIEW-AS ALERT-BOX .
END.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ED-notes Dialog-Frame
ON LEAVE OF ED-notes IN FRAME Dialog-Frame
DO:
define buffer buf_icnt-doc for ub.icnt-doc.
do on stop  undo, return no-apply
   on error undo, return no-apply :
  find first buf_icnt-doc where
       recid (buf_icnt-doc) = v-icnt-rec exclusive .
  buf_icnt-doc.PS = input frame {&frame-name} ed-notes.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ED-notes Dialog-Frame
ON RETURN OF ED-notes IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF ed-notes IN FRAME {&frame-name} DO:
  apply "entry" to {&browse-name} in frame {&frame-name}.
return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/setfltnm.i }
{ gbl/hot-key.i b-print }
{ gbl/hot-key.i b-lkp   }
{ gbl/hot-key.i b-add   }
{ gbl/hot-key.i b-chg   }
{ gbl/hot-key.i b-close }
{ gbl/hot-key.i b-del   }
{ gbl/brwrefre.i " v-icnt-rec = ?. if available X_icnt-doc then v-icnt-rec = recid(X_icnt-doc). ~
               run openbr in this-procedure ( input yes, input no, input '':U) no-error. ~
               REPOSITION br-i-docs to recid v-icnt-rec No-ERROR." }


{ gbl/srt-clmd.i
&browse-name   = "{&browse-name}"
&frame-name    = "{&frame-name}"
&table-name    = "X_icnt-doc"
&ext-col       = 13
&start-column  = 4
&label-clmn_1  = "{&label-clmn_1}"
&sort-clmn_1   = "{&sort-clmn_1}"
&label-clmn_2  = "{&label-clmn_2}"
&sort-clmn_2   = "{&sort-clmn_2}"
&label-clmn_3  = "{&label-clmn_3}"
&sort-clmn_3   = "{&sort-clmn_3}"
&label-clmn_4  = "{&label-clmn_4}"
&sort-clmn_4   = "{&sort-clmn_4}"
&label-clmn_5  = "{&label-clmn_5}"
&sort-clmn_5   = "{&sort-clmn_5}"
&label-clmn_6  = "{&label-clmn_6}"
&sort-clmn_6   = "{&sort-clmn_6}"
&label-clmn_8  = "{&label-clmn_8}"
&sort-clmn_8   = "{&sort-clmn_8}"
&label-clmn_9  = "{&label-clmn_9}"
&sort-clmn_9   = "{&sort-clmn_9}"
&label-clmn_10 = "{&label-clmn_10}"
&sort-clmn_10  = "{&sort-clmn_10}"
&label-clmn_11 = "{&label-clmn_11}"
&sort-clmn_11  = "{&sort-clmn_11}"
&label-clmn_12 = "{&label-clmn_12}"
&sort-clmn_12  = "{&sort-clmn_12}"
&open-query     = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
&open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
&sort-column-name = "sort-column-name"
&re-move-clmn   = "yes"
&mv-brw-default = "yes"
}
{ gbl/mv-clmn.i
&browse-name = "{&browse-name}"
&frame-name  = "{&frame-name}"
&start-column = 4
&ext-col = 13
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
{ gbl/getcntxt.i GET }
  IF lookup(p-list-mode, {&all} + {&delim-par} +
                         {&g___object} + {&delim-par} +
                         {&STATUS} + {&delim-par} +
                         {&company}, {&delim-par} ) = 0 THEN DO:
    MESSAGE
    substitute("Неверное значение параметра p-list-mode=&1", p-list-mode)
    VIEW-AS ALERT-BOX error.
    undo, RETURN ERROR.
  END.
  if p-list-mode = {&g___object}
  or p-list-mode = {&status} then do:
    find first buf_clients no-lock where
              buf_clients.obj-type = p-obj-type
          and buf_clients.obj-code = p-obj-code no-error.
    if not available buf_clients
    or not (buf_clients.obj-type = {&shop})
    then do:
      MESSAGE
      substitute("Неверное значение параметров p-obj-type=&1 и/или p-obj-code= &2"
               , p-obj-type
               , p-obj-code)
      VIEW-AS ALERT-BOX error.
      undo, RETURN ERROR.
    end.
  end.
  if p-list-mode = {&company} then do:
    find first buf_sysconf no-lock where
              buf_sysconf.host-code = p-host-code no-error.
   if not available buf_sysconf then do:
      MESSAGE
      substitute("Неверное значение параметра p-host-codee=&1"
               , p-host-code)
      VIEW-AS ALERT-BOX error.
      undo, RETURN ERROR.
   end.
  end.
  IF LOOKUP(p-doc-type, {&icnt-type} ) = 0 THEN DO:
    MESSAGE
    substitute("Неверное значение параметра p-doc-type=&1", p-doc-type)
    VIEW-AS ALERT-BOX error.
    undo, RETURN ERROR.
  END.
  v-rid-list = p-rid-list.
  run Myenable IN THIS-PROCEDURE.
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY ED-notes mark-num obj-name boss-name agnt-name wrkr-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_icnt-doc THEN
    DISPLAY X_icnt-doc.creid
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel b-add b-chg b-del b-lkp b-print b-sch B-Help
         b-close BR-i-docs ED-notes mark-num obj-name boss-name agnt-name
         wrkr-name X_icnt-doc.creid
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ASSIGN
br-i-docs:NUM-LOCKED-COLUMNS IN FRAME {&frame-name} = 4
{&sort-clmn_12}:READ-ONLY in browse br-i-docs = YES
.
enable
b-quit
b-help
b-print
b-lkp
b-sch
b-sel WHEN lookup("b-sel", bttns) > 0
b-mark WHEN lookup("b-mark", bttns) > 0
b-add WHEN ((p-list-mode = {&g___object}
            OR p-list-mode = {&status})
            AND v-cntxt-db-num = buf_clients.db-num
            AND lookup("b-add", bttns) > 0 AND NOT TRANSACTION)
b-chg WHEN ((p-list-mode = {&g___object}
            OR p-list-mode = {&status})
            AND v-cntxt-db-num = buf_clients.db-num
            AND lookup("b-add", bttns) > 0 AND NOT TRANSACTION)

b-del WHEN ((p-list-mode = {&g___object}
            OR p-list-mode = {&status})
            AND v-cntxt-db-num = buf_clients.db-num
            AND lookup("b-add", bttns) > 0 AND NOT TRANSACTION)
b-close WHEN ((p-list-mode = {&g___object}
            OR (p-list-mode = {&status} AND p-status_ <> {&fact})
              )
            AND v-cntxt-db-num = buf_clients.db-num
            AND lookup("b-add", bttns) > 0 AND NOT TRANSACTION)
br-i-docs
with frame {&frame-name}.

run OpenBr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
apply "entry" to br-i-docs in frame {&frame-name}.
apply "value-changed" to br-i-docs in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable sort-column-phrase as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo .
define buffer buf_clients for ub.clients.

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.
&scop flt-open-debug-file

&scop flt-open-open-query         OPEN QUERY br-i-docs FOR EACH X_icnt-doc

&scop flt-open-dyn_open-query      FOR EACH X_icnt-doc

&scop flt-open-query-handle        QUERY br-i-docs:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened   l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point         filter-point

&scop flt-open-set-filter-name    set-filter-name

&scop flt-open-indexed-reposition INDEXED-REPOSITION

filter-point = filter-point0 + p-list-mode .

if p-doc-type = {&icnt-doc} then do:
  title0 = "ДОКУМЕНТЫ ИНВЕНТАРИЗАЦИИ СЧЕТЧИКОВ ТРК".
end.
if p-doc-type = {&icnt-err} then do:
  title0 = "ДОКУМЕНТЫ ИЗМЕРЕНИЯ ПОГРЕШНОСТИ СЧЕТЧИКОВ ТРК".
end.


CASE p-list-mode:
  when {&all} then do:
    ASSIGN
    frame {&frame-name}:title = substitute("&1: ВСЕ", title0)
    filter-label = SUBSTITUTE("&1"
                              , frame {&frame-name}:title
                              )
    .

    if p-doc-type = {&icnt-doc} then do:
      { gbl/fltopend.i
        &where-cond = " X_icnt-doc.doc-type = p-doc-type "
        &dyn_where-cond = " substitute('X_icnt-doc.doc-type = &1&2&1', ~{&double-quote~}, p-doc-type )"
        &use-ind    = "  "
        &by         = "  " }

    end.
    if p-doc-type = {&icnt-err} then do:
      { gbl/fltopend.i
        &where-cond = " X_icnt-doc.doc-type = p-doc-type "
        &dyn_where-cond = " substitute('X_icnt-doc.doc-type = &1&2&1', ~{&double-quote~}, p-doc-type )"
        &use-ind    = "  "
        &by         = "  " }

    end.
  end.
  when {&company} then do:
    ASSIGN
    frame {&frame-name}:title = substitute("&1: Фирма &2"
                                          , title0
                                          , p-host-code)
    filter-label = SUBSTITUTE("&1"
                              , frame {&frame-name}:title
                              )
    .
    if p-doc-type = {&icnt-doc} then do:
      { gbl/fltopend.i
        &where-cond = " X_icnt-doc.host-code = p-host-code ~
                        and X_icnt-doc.doc-type = p-doc-type "
        &dyn_where-cond = " substitute('X_icnt-doc.host-code = &1 ~
                        and X_icnt-doc.doc-type = &2&3&2 ', p-host-code, ~{&double-quote~}, p-doc-type)"

        &use-ind    = " use-index host-date "
        &by         = "  " }
    end.
    if p-doc-type = {&icnt-err} then do:
      { gbl/fltopend.i
        &where-cond = " X_icnt-doc.host-code = p-host-code ~
                        and X_icnt-doc.doc-type = p-doc-type "
        &dyn_where-cond = " substitute('X_icnt-doc.host-code = &1 ~
                        and X_icnt-doc.doc-type = &2&3&2 ', p-host-code, ~{&double-quote~}, p-doc-type)"
        &use-ind    = " use-index host-date "
        &by         = "  " }

    end.
  end.
  when {&g___object} then do:
    ASSIGN
    frame {&frame-name}:title = substitute("&1: &2&3"
                                          , title0
                                          , p-obj-type
                                          , p-obj-code)
    filter-label = SUBSTITUTE("&1"
                              , frame {&frame-name}:title
                              )
    .
    if p-doc-type = {&icnt-doc} then do:
      { gbl/fltopend.i
        &where-cond = " X_icnt-doc.obj-type = p-obj-type ~
                        and X_icnt-doc.obj-code = p-obj-code ~
                        and X_icnt-doc.doc-type = p-doc-type "
        &dyn_where-cond = " substitute('X_icnt-doc.obj-type = &1&2&1 ~
                        and X_icnt-doc.obj-code = &3 ~
                        and X_icnt-doc.doc-type = &1&4&1 ', ~{&double-quote~}, p-obj-type, p-obj-code, p-doc-type)"

        &use-ind    = "use-index obj-date "
        &by         = "  " }
    end.
    if p-doc-type = {&icnt-err} then do:
      { gbl/fltopend.i
        &where-cond = " X_icnt-doc.obj-type = p-obj-type ~
                        and X_icnt-doc.obj-code = p-obj-code ~
                        and X_icnt-doc.doc-type = p-doc-type  "
        &dyn_where-cond = " substitute('X_icnt-doc.obj-type = &1&2&1 ~
                        and X_icnt-doc.obj-code = &3 ~
                        and X_icnt-doc.doc-type = &1&4&1 ', ~{&double-quote~}, p-obj-type, p-obj-code, p-doc-type)"
        &use-ind    = "use-index obj-date "
        &by         = "  " }
    end.
  end.
  when {&status} then do:
    ASSIGN
    frame {&frame-name}:title = substitute("&1: &2&3 статус &4"
                                          , title0
                                          , p-obj-type
                                          , p-obj-code
                                          , p-status_)
    filter-label = SUBSTITUTE("&1"
                              , frame {&frame-name}:title
                              )
    .
    if p-doc-type = {&icnt-doc} then do:
      { gbl/fltopend.i
        &where-cond = "X_icnt-doc.obj-type = p-obj-type ~
                      AND X_icnt-doc.obj-code = p-obj-code ~
                      AND X_icnt-doc.status_  = p-status_
                      and X_icnt-doc.doc-type = p-doc-type "
        &dyn_where-cond = " substitute(' X_icnt-doc.obj-type = &1&2&1 ~
                      AND X_icnt-doc.obj-code = &3 ~
                      AND X_icnt-doc.status_  = &1&4&1
                      and X_icnt-doc.doc-type = &1&5&1 ', ~{&double-quote~}, p-obj-type, p-obj-code, p-status_, p-doc-type)"

        &use-ind    = "use-index stat-date"
        &by         = "  " }
    end.
    if p-doc-type = {&icnt-err} then do:
      { gbl/fltopend.i
        &where-cond = "X_icnt-doc.obj-type = p-obj-type ~
                      AND X_icnt-doc.obj-code = p-obj-code ~
                      AND X_icnt-doc.status_  = p-status_
                      and X_icnt-doc.doc-type = p-doc-type  "
        &dyn_where-cond = " substitute(' X_icnt-doc.obj-type = &1&2&1 ~
                      AND X_icnt-doc.obj-code = &3 ~
                      AND X_icnt-doc.status_  = &1&4&1
                      and X_icnt-doc.doc-type = &1&5&1 ', ~{&double-quote~}, p-obj-type, p-obj-code, p-status_, p-doc-type)"
        &use-ind    = "use-index stat-date"
        &by         = "  " }

    end.
  end.
END CASE.
APPLY "entry" TO br-i-docs.
if available X_icnt-doc then do:
    APPLY "VALUE-CHANGED":U to {&browse-name}.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
define variable v-icnt-line-rec as recid no-undo .
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
define variable next-prev as character no-undo .
define variable v-host-code as integer no-undo .
{ gbl/hostcode.i p-obj-type p-obj-code v-host-code }
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_icnt-doc_preparation':U
  {&cntxt-object}
  v-host-code
  p-obj-type
  p-obj-code
  0
  0
  0
  true
  glog
}
if not glog then return no-apply.
do on stop undo, return no-apply:
  case p-doc-type:
    when {&icnt-doc} then do:
      run ref/icntdoci.w ( INPUT parparentproc
                      ,INPUT {&add-def}
                      ,INPUT v-cntxt-obj-type
                      ,INPUT v-cntxt-obj-code
                      ,INPUT-output v-icnt-rec
                      ,input-output v-icnt-line-rec
                      ,input this-procedure:handle
                      ,input-output next-prev
                      ) no-error.
    end.
    when {&icnt-err} then do:
      run ref/icntdoce.w ( INPUT parparentproc
                      ,INPUT {&add-def}
                      ,INPUT v-cntxt-obj-type
                      ,INPUT v-cntxt-obj-code
                      ,INPUT-output v-icnt-rec
                      ,input-output v-icnt-line-rec
                      ,input this-procedure:handle
                      ,input-output next-prev
                      ) no-error.

    end.
  end case.
  if error-status:error then undo, return no-apply.
end.
if v-icnt-rec = ? then undo, return error.
run Openbr IN THIS-PROCEDURE ( INPUT yes, INPUT no, INPUT '':U).
REPOSITION br-i-docs TO RECID v-icnt-rec NO-ERROR.
APPLY "ENTRY" to br-i-docs in frame {&frame-name} .
APPLY "value-changed" TO br-i-docs.
message
"Новый документ счетчиков ТРК добавлен в Базу Данных."
VIEW-AS ALERT-BOX.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame
PROCEDURE proc-b-chg :
DEFINE VARIABLE glog AS LOGICAL no-undo.
define variable v-icnt-line-rec as recid no-undo .
define variable next-prev as character no-undo .
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_icnt-doc_preparation':U
  {&cntxt-object}
  X_icnt-doc.host-code
  X_icnt-doc.obj-type
  X_icnt-doc.obj-code
  0
  0
  0
  true
  glog
}
if not glog then return no-apply.

assign v-icnt-rec = recid(X_icnt-doc).
do on stop undo, return no-apply:
  case p-doc-type:
    when {&icnt-doc} then do:
      run ref/icntdoci.w ( INPUT parparentproc
                      ,INPUT {&update}
                      ,INPUT X_icnt-doc.obj-type
                      ,INPUT X_icnt-doc.obj-code
                      ,input-output v-icnt-rec
                      ,input-output v-icnt-line-rec
                      ,input this-procedure:handle
                      ,input-output next-prev
                      ) no-error.
    end.
    when {&icnt-err} then do:
      run ref/icntdoce.w ( INPUT parparentproc
                      ,INPUT {&update}
                      ,INPUT X_icnt-doc.obj-type
                      ,INPUT X_icnt-doc.obj-code
                      ,input-output v-icnt-rec
                      ,input-output v-icnt-line-rec
                      ,input this-procedure:handle
                      ,input-output next-prev
                      ) no-error.
    end.
  end case.
  if error-status:error then undo, return no-apply.
end.
if error-status:error then do:
  UNDO, RETURN ERROR.
end.
apply "entry" to {&browse-name} in frame {&frame-name}.
run Openbr IN THIS-PROCEDURE ( INPUT yes, INPUT no, INPUT '':U).
REPOSITION br-i-docs TO RECID v-icnt-rec NO-ERROR.
APPLY "ENTRY" to br-i-docs.
APPLY "value-changed" TO br-i-docs.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lkp Dialog-Frame
PROCEDURE proc-b-lkp :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
define variable next-prev as character no-undo .
define variable v-icnt-line-rec as recid no-undo .
IF NOT AVAILABLE X_icnt-doc THEN UNDO, RETURN ERROR.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_icnt-doc_lookup':U
  {&cntxt-object}
  X_icnt-doc.host-code
  X_icnt-doc.obj-type
  X_icnt-doc.obj-code
  0
  0
  0
  true
  glog
}
if not glog then
  return no-apply.

if not glog then  undo, RETURN no-apply.
assign
  v-icnt-rec = recid (X_icnt-doc)
  .
do on stop undo, return no-apply:
  case p-doc-type:
    when {&icnt-doc} then do:
      run ref/icntdoci.w ( INPUT parparentproc
                      ,INPUT {&lookup}
                      ,INPUT X_icnt-doc.obj-type
                      ,INPUT X_icnt-doc.obj-code
                      ,input-output v-icnt-rec
                      ,input-output v-icnt-line-rec
                      ,input this-procedure:handle
                      ,input-output next-prev
                      ) no-error .
   end.
   when {&icnt-err} then do:
      run ref/icntdoce.w ( INPUT parparentproc
                      ,INPUT {&lookup}
                      ,INPUT X_icnt-doc.obj-type
                      ,INPUT X_icnt-doc.obj-code
                      ,input-output v-icnt-rec
                      ,input-output v-icnt-line-rec
                      ,input this-procedure:handle
                      ,input-output next-prev
                      ) no-error .
    end.
  end case.
  if error-status:error then return no-apply.
end.
if v-icnt-rec <> ? then reposition br-i-docs to recid v-icnt-rec no-error.
apply "entry" to br-i-docs in frame {&frame-name}.
apply "value-changed" to br-i-docs in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
DEFINE VARIABLE v-icnt-rec AS RECID no-undo.
DEFINE VARIABLE glog AS logical no-undo.
IF NOT AVAILABLE X_icnt-doc THEN RETURN ERROR.
ASSIGN
v-icnt-rec = recid (X_icnt-doc).
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_icnt-doc_print':U
  {&cntxt-object}
  X_icnt-doc.host-code
  X_icnt-doc.obj-type
  X_icnt-doc.obj-code
  0
  0
  0
  true
  glog
}
if not glog then return no-apply.
case  X_icnt-doc.doc-type:
  when {&icnt-doc} then do:
    run rep/r-apump.p ( input parparentproc
                  ,input v-icnt-rec) no-error .
  end.
  when {&icnt-err} then do:
    run rep/r-epump.p ( input parparentproc
                  ,input v-icnt-rec) no-error .
  end.
end case.
apply "entry" to br-i-docs in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
define variable v-ri as recid no-undo .
assign
v-ri = (if avail X_icnt-doc then recid(X_icnt-doc) else ?)
.
assign
tbl = 'icnt-doc'
join-tbl = 'X_icnt-doc'
fld = ""
lab = ""
spr = ""
dim = '0'
.

run fltfield-add in this-procedure('host-code', 'Фирма', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-code', 'Номер документа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', 'Статус', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date', 'Дата_факт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-date', 'Дата_смены', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-num', 'Порядок_смены', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

DO on stop undo, leave:
    run gbl/filter.w ( INPUT parparentproc
                 ,INPUT filter-point + {&delim-par} + filter-label
                 ,INPUT tbl
                 ,INPUT join-tbl
                 ,INPUT fld
                 ,INput lab
                 ,INPUT spr
                 ,INPUT  dim).
    run OpenBr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
    if v-ri <> ? then do:
      reposition br-i-docs to recid v-ri no-error.
    end.
    APPLY "ENTRY" to br-i-docs in frame {&frame-name} .
    APPLY "VALUE-CHANGED" to br-i-docs.
END .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reopen-query Dialog-Frame
PROCEDURE reopen-query :
if available X_icnt-doc then v-icnt-rec = recid(X_icnt-doc).
run OpenBr in THIS-PROCEDURE ( INPUT yes, INPUT no, INPUT '':U).
reposition br-i-docs to recid v-icnt-rec no-error.
apply "entry" to br-i-docs in frame {&frame-name} .
apply "value-changed" to br-i-docs in frame {&frame-name} .

END PROCEDUR.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-icnt-doc Dialog-Frame
PROCEDURE reposition-icnt-doc :
define input  parameter p-direction   as character no-undo .
define output parameter p-icnt-doc-recid as recid no-undo .

  /* перемещение на первую, последнюю, предыдущую, следующую */
  case p-direction :
    when "first":U
    then do:
      get first br-i-docs.
    end.
    when "last":U
    then do:
      get last br-i-docs.
    end.
    when "prev":U
    then do:
      get prev br-i-docs.
      if not available X_icnt-doc then do:
        message
        "Это первый документ списка"
        view-as alert-box.
      end.
    end.
    when "next":U
    then do:
      get next br-i-docs.
      if not available X_icnt-doc then do:
        message
        "Это последний документ списка"
        view-as alert-box.
      end.
    end.
  end case . /* p-direction */
  assign
  p-icnt-doc-recid = recid(X_icnt-doc)
  .
  run reposition-query in this-procedure
    (input p-icnt-doc-recid
    ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-query Dialog-Frame
PROCEDURE reposition-query :
define input parameter p-recid as recid no-undo .

  if p-recid <> ?
  then do:
    reposition br-i-docs to recid p-recid no-error.
  end.

  do with frame {&frame-name}:
    apply "entry":u to browse br-i-docs .
    apply "VALUE-CHANGED":u to browse br-i-docs .
  end. /* do with frame */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
