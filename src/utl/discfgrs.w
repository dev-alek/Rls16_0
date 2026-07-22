&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_dis-cfg-rule FOR ub.dis-cfg-rule.
DEFINE BUFFER X_dis-rule FOR ub.dis-rule.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список привязок шаблонов правил скидок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/10/06
Author: Bakhtadze Natalya
Creation date: 12/10/06

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter bttns as character no-undo .
define input-output parameter p-rid-list as character no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список привязок шаблонов правил скидок".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/tblfname.i }
{ gbl/getcntxt.i DEF }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i  }
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-ibs as logical no-undo .
define variable glog as logical no-undo .
define variable v-cd   as character no-undo INIT ?.
define variable v-table-name  as character no-undo INIT ?.
define variable v-templ-rl-root as integer no-undo .
define variable v-time-templ-rl-root as integer no-undo .
DEFINE BUFFER buf_file FOR dictdb._file.
define variable v-rid-list as character no-undo .
&SCOPED-DEFINE dr-link-code STRING(X_dis-cfg-rule.link-prop)

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-dis-cfg-rule

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_dis-cfg-rule X_dis-rule

/* Definitions for BROWSE br-dis-cfg-rule                               */
&Scoped-define FIELDS-IN-QUERY-br-dis-cfg-rule X_dis-cfg-rule.pos-type X_dis-cfg-rule.discnt-role rule-name( INPUT X_dis-cfg-rule.table-name, INPUT X_dis-cfg-rule.self-nonunique, INPUT X_dis-cfg-rule.discnt-role) X_dis-cfg-rule.templ-rl-root X_dis-cfg-rule.time-templ-rl-root X_dis-rule.des logical(X_dis-cfg-rule.has-global) logical(X_dis-cfg-rule.has-host) logical(X_dis-cfg-rule.has-obj) X_dis-cfg-rule.self-nonunique X_dis-cfg-rule.nonunique X_dis-cfg-rule.table-name {&dr-link-name}
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-dis-cfg-rule
&Scoped-define SELF-NAME br-dis-cfg-rule
&Scoped-define QUERY-STRING-br-dis-cfg-rule FOR EACH X_dis-cfg-rule NO-LOCK where X_dis-cfg-rule.table-name > '':U and X_dis-cfg-rule.pos-type > '':U, ~
             first X_dis-rule WHERE X_dis-rule.templ-rl-root  = tt-dis-pos.templ-rl-root NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-dis-cfg-rule OPEN QUERY {&SELF-NAME} FOR EACH X_dis-cfg-rule NO-LOCK where X_dis-cfg-rule.table-name > '':U and X_dis-cfg-rule.pos-type > '':U, ~
             first X_dis-rule WHERE X_dis-rule.templ-rl-root  = tt-dis-pos.templ-rl-root NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-dis-cfg-rule X_dis-cfg-rule X_dis-rule
&Scoped-define FIRST-TABLE-IN-QUERY-br-dis-cfg-rule X_dis-cfg-rule
&Scoped-define SECOND-TABLE-IN-QUERY-br-dis-cfg-rule X_dis-rule


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-copy b-chg b-del ~
b-lkp b-print B-Help Cb-pos-type Cb-table-name b-dis-ruls f-templ-rl-root ~
f-dis-rule-des b-dist-rls f-time-templ-rl-root f-dis-time-rule-des ~
br-dis-cfg-rule mark-num
&Scoped-Define DISPLAYED-OBJECTS Cb-pos-type Cb-table-name f-templ-rl-root ~
f-dis-rule-des f-time-templ-rl-root f-dis-time-rule-des mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD rule-name Dialog-Frame
FUNCTION rule-name RETURNS CHARACTER
  ( INPUT p-subject AS character, INPUT p-self-nonunique AS character, input p-discnt-role AS character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
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

DEFINE BUTTON b-copy
     LABEL "&Копировать"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-dis-ruls
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 5"
     SIZE 4 BY 1.

DEFINE BUTTON b-dist-rls
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 5"
     SIZE 4 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 4 BY 1.

DEFINE BUTTON b-print
     LABEL "&Печать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1.

DEFINE VARIABLE Cb-pos-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 15
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE Cb-table-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 62.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-dis-rule-des AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 83.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-dis-time-rule-des AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 83.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-templ-rl-root AS INTEGER FORMAT ">,>>9":U INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE f-time-templ-rl-root AS INTEGER FORMAT ">,>>9":U INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-dis-cfg-rule FOR
      X_dis-cfg-rule,
      X_dis-rule SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-dis-cfg-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-dis-cfg-rule Dialog-Frame _FREEFORM
  QUERY br-dis-cfg-rule NO-LOCK DISPLAY
      X_dis-cfg-rule.pos-type FORMAT "X(15)":U COLUMN-LABEL "Место использ"
X_dis-cfg-rule.discnt-role  COLUMN-LABEL "Роль скидки" FORMAT "X(255)":U WIDTH 15
rule-name( INPUT X_dis-cfg-rule.table-name, INPUT X_dis-cfg-rule.self-nonunique, INPUT X_dis-cfg-rule.discnt-role) COLUMN-LABEL "Роль скидки" FORMAT "X(255)":U WIDTH 35
X_dis-cfg-rule.templ-rl-root FORMAT ">>>>>>>>9":U COLUMN-LABEL "Код!шаблона"
X_dis-cfg-rule.time-templ-rl-root FORMAT "->>>>>>>>9":U COLUMN-LABEL "Код!шаблона!распис"
X_dis-rule.des FORMAT "X(255)":U WIDTH 45
logical(X_dis-cfg-rule.has-global) FORMAT "+/" COLUMN-LABEL "Глоб"
logical(X_dis-cfg-rule.has-host) FORMAT "+/" COLUMN-LABEL "Фирма"
logical(X_dis-cfg-rule.has-obj) FORMAT "+/" COLUMN-LABEL "Объ"
X_dis-cfg-rule.self-nonunique FORMAT "X(20)" COLUMN-LABEL "Собств.Неуник"
X_dis-cfg-rule.nonunique FORMAT "X(20)" COLUMN-LABEL "Неуник"
X_dis-cfg-rule.table-name FORMAT "X(12)" COLUMN-LABEL "Таблица связи"
{&dr-link-name} FORMAT "X(30)" COLUMN-LABEL "Вид связи"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 21 WIDGET-ID 32
     b-sel AT ROW 1 COL 25 WIDGET-ID 34
     b-add AT ROW 1 COL 35 WIDGET-ID 2
     b-copy AT ROW 1 COL 45 WIDGET-ID 30
     b-chg AT ROW 1 COL 55 WIDGET-ID 4
     b-del AT ROW 1 COL 65 WIDGET-ID 6
     b-lkp AT ROW 1 COL 75 WIDGET-ID 8
     b-print AT ROW 1 COL 92 WIDGET-ID 36
     B-Help AT ROW 1 COL 95
     Cb-pos-type AT ROW 2.07 COL 2.5 NO-LABEL WIDGET-ID 12
     Cb-table-name AT ROW 2.07 COL 19 NO-LABEL WIDGET-ID 14
     b-dis-ruls AT ROW 3 COL 2.5 WIDGET-ID 18
     f-templ-rl-root AT ROW 3 COL 5.5 COLON-ALIGNED NO-LABEL WIDGET-ID 20
     f-dis-rule-des AT ROW 3 COL 15.5 NO-LABEL WIDGET-ID 26
     b-dist-rls AT ROW 4 COL 2.5 WIDGET-ID 24
     f-time-templ-rl-root AT ROW 4 COL 5.5 COLON-ALIGNED NO-LABEL WIDGET-ID 22
     f-dis-time-rule-des AT ROW 4 COL 15.5 NO-LABEL WIDGET-ID 28
     br-dis-cfg-rule AT ROW 5 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(78.50) SKIP(21.09)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Конфигурация тип скидки-POS-расписание"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_dis-cfg-rule B "?" ? ub dis-cfg-rule
      TABLE: X_dis-rule B "?" ? ub dis-rule
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-dis-cfg-rule f-dis-time-rule-des Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR COMBO-BOX Cb-pos-type IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR COMBO-BOX Cb-table-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-dis-rule-des IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       f-dis-rule-des:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN f-dis-time-rule-des IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       f-dis-time-rule-des:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       f-templ-rl-root:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       f-time-templ-rl-root:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-dis-cfg-rule
/* Query rebuild information for BROWSE br-dis-cfg-rule
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_dis-cfg-rule NO-LOCK where X_dis-cfg-rule.table-name > '':U
and X_dis-cfg-rule.pos-type > '':U,
      first X_dis-rule WHERE X_dis-rule.templ-rl-root  = tt-dis-pos.templ-rl-root NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE br-dis-cfg-rule */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Конфигурация тип скидки-POS-расписание */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Конфигурация тип скидки-POS-расписание */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
define variable v-rec as recid no-undo .
  run utl/discfgri.w ( input parparentproc
                      ,INPUT {&add-def}
                      ,INPUT '':U /*p-table-name*/
                      ,INPUT '':U /*pos-type*/
                      ,INPUT 0 /*templ-rl-root*/
                      ,INPUT 0 /*time-templ-rl-root*/
                      ,INPUT '':U /*discnt-role*/
                      ,INPUT '':U /*self-nonunique*/
                      ,output v-rec
                      ) no-error .

  RUN openbr IN THIS-PROCEDURE ( input v-cd
                               ,INPUT v-table-name
                               ,INPUT v-templ-rl-root
                               ,INPUT v-time-templ-rl-root) NO-ERROR.
  reposition br-dis-cfg-rule to recid(v-rec) no-error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
define variable v-rec as recid no-undo .
v-rec = recid(X_dis-cfg-rule).
  if not available X_dis-cfg-rule then return no-apply.
  run utl/discfgri.w ( input parparentproc
                      ,INPUT {&update}
                      ,INPUT X_dis-cfg-rule.table-name
                      ,INPUT X_dis-cfg-rule.pos-type
                      ,INPUT X_dis-cfg-rule.templ-rl-root
                      ,INPUT X_dis-cfg-rule.time-templ-rl-root
                      ,INPUT X_dis-cfg-rule.discnt-role
                      ,INPUT X_dis-cfg-rule.self-nonunique
                      ,output v-rec
                      ) no-error .

  RUN openbr IN THIS-PROCEDURE ( input v-cd
                               ,INPUT v-table-name
                               ,INPUT v-templ-rl-root
                               ,INPUT v-time-templ-rl-root) NO-ERROR.
  reposition br-dis-cfg-rule to recid(v-rec) no-error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-copy Dialog-Frame
ON CHOOSE OF b-copy IN FRAME Dialog-Frame /* Копировать */
DO:
define variable v-rec as recid no-undo .
IF NOT AVAILABLE X_dis-cfg-rule THEN RETURN NO-APPLY.
  run utl/discfgri.w ( input parparentproc
                      ,INPUT {&add-copy}
                       ,INPUT X_dis-cfg-rule.table-name
                       ,INPUT X_dis-cfg-rule.pos-type
                       ,INPUT X_dis-cfg-rule.templ-rl-root
                       ,INPUT X_dis-cfg-rule.time-templ-rl-root
                       ,INPUT X_dis-cfg-rule.discnt-role
                       ,INPUT X_dis-cfg-rule.self-nonunique
                       ,output v-rec
                      ) no-error .

  RUN openbr IN THIS-PROCEDURE ( input v-cd
                               ,INPUT v-table-name
                               ,INPUT v-templ-rl-root
                               ,INPUT v-time-templ-rl-root) NO-ERROR.
  reposition br-dis-cfg-rule to recid(v-rec) no-error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  define variable glog as logical no-undo .
  if not available X_dis-cfg-rule then return no-apply.
  message
  "Вы уверены, что хотите стереть?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then return no-apply.
  run utl/discfgr3.p ( input no
                      ,input recid(X_dis-cfg-rule)) no-error.
  if not error-status:error then do:
    RUN openbr IN THIS-PROCEDURE ( input v-cd
                                ,INPUT v-table-name
                                ,INPUT v-templ-rl-root
                                ,INPUT v-time-templ-rl-root) NO-ERROR.
    reposition br-dis-cfg-rule to row 1 no-error .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dis-ruls
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dis-ruls Dialog-Frame
ON CHOOSE OF b-dis-ruls IN FRAME Dialog-Frame /* Btn 5 */
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-sts AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
if available X_dis-cfg-rule then do:
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = X_dis-cfg-rule.templ-rl-root no-error.
  if available buf_dis-rule then do:
    v-rid-list = string(recid(buf_dis-rule)).
  end.
end.
run ref/dis-ruls.w (
            input parparentproc
          ,input 0 /*p-host-code*/
          ,INPUT "":U /*p-obj-type*/
          ,INPUT 0 /* p-obj-code*/
          ,input "b-sel":U
          ,INPUT "template"
          ,INPUT 0
          ,input ?
          ,input 0
          ,input-output v-sts
          ,input-output v-rid-list ) no-error .
IF v-rid-list <> '':U THEN DO:
  FIND FIRST buf_dis-rule NO-LOCK WHERE recid(buf_dis-rule) = INTEGER(v-rid-list) NO-ERROR.
  IF NOT AVAILABLE buf_dis-rule THEN RETURN NO-APPLY.
  ASSIGN
  f-templ-rl-root = buf_dis-rule.templ-rl-root
  f-dis-rule-des = buf_dis-rule.des
  v-templ-rl-root = f-templ-rl-root
  .
END.
ELSE DO:
  ASSIGN
  f-templ-rl-root = 0
  f-dis-rule-des = '':U
  v-templ-rl-root = 0
  .
END.
DISPLAY
f-dis-rule-des
f-templ-rl-root
WITH FRAME {&FRAME-NAME}.
 RUN openbr IN THIS-PROCEDURE ( input v-cd
                               ,INPUT v-table-name
                               ,INPUT v-templ-rl-root
                               ,INPUT v-time-templ-rl-root) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dist-rls
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dist-rls Dialog-Frame
ON CHOOSE OF b-dist-rls IN FRAME Dialog-Frame /* Btn 5 */
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-sts AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_dis-time-rule FOR ub.dis-rule.
    run ref/dist-rls.w (
                   input parparentproc
                  ,input ""
                  ,input "template"
                  ,input X_dis-rule.templ-rl-root
                  ,input 0
                  ,input ''
                  ,input-output v-sts
                  ,input-output v-rid-list) no-error .
IF v-rid-list <> '':U THEN DO:
  FIND FIRST buf_dis-time-rule NO-LOCK WHERE recid(buf_dis-time-rule) = INTEGER(v-rid-list) NO-ERROR.
  IF NOT AVAILABLE buf_dis-time-rule THEN RETURN NO-APPLY.
  ASSIGN
  f-time-templ-rl-root = buf_dis-time-rule.templ-rl-root
  f-dis-time-rule-des = buf_dis-time-rule.des
  v-time-templ-rl-root = f-time-templ-rl-root
  .
END.
ELSE DO:
  ASSIGN
  f-time-templ-rl-root = 0
  f-dis-time-rule-des = '':U
  v-time-templ-rl-root = 0
  .
END.
DISPLAY
f-dis-time-rule-des
f-time-templ-rl-root
WITH FRAME {&FRAME-NAME}.
 RUN openbr IN THIS-PROCEDURE ( input v-cd
                               ,INPUT v-table-name
                               ,INPUT v-templ-rl-root
                               ,INPUT v-time-templ-rl-root) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
 define variable v-rec as recid no-undo .
  if not available X_dis-cfg-rule then return no-apply.
  run utl/discfgri.w ( input parparentproc
                      ,INPUT {&lookup}
                      ,INPUT X_dis-cfg-rule.table-name
                      ,INPUT X_dis-cfg-rule.pos-type
                      ,INPUT X_dis-cfg-rule.templ-rl-root
                      ,INPUT X_dis-cfg-rule.time-templ-rl-root
                      ,INPUT X_dis-cfg-rule.discnt-role
                      ,INPUT X_dis-cfg-rule.self-nonunique
                      ,output v-rec
                      ) no-error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable glog as logical no-undo .
  if available X_dis-cfg-rule then do:
 { gbl/markstrn.i X_dis-cfg-rule v-rid-list }
  glog = br-dis-cfg-rule:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-dis-cfg-rule:select-next-row ().
      apply "VALUE-CHANGED" to br-dis-cfg-rule in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-dis-cfg-rule in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
  RUN proc-b-print IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if available X_dis-cfg-rule then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_dis-cfg-rule ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Cb-pos-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Cb-pos-type Dialog-Frame
ON VALUE-CHANGED OF Cb-pos-type IN FRAME Dialog-Frame
DO:
  assign
    cb-pos-type
    v-cd = ( if cb-pos-type = "":U then ? else cb-pos-type )
  .
  RUN openbr IN THIS-PROCEDURE ( input v-cd
                               ,INPUT v-table-name
                               ,INPUT v-templ-rl-root
                               ,INPUT v-time-templ-rl-root) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Cb-table-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Cb-table-name Dialog-Frame
ON VALUE-CHANGED OF Cb-table-name IN FRAME Dialog-Frame
DO:
  assign
    cb-table-name
    v-table-name = ( if cb-table-name = "":U then ? else cb-table-name )
  .
  RUN openbr IN THIS-PROCEDURE ( input v-cd
                               ,INPUT v-table-name
                               ,INPUT v-templ-rl-root
                               ,INPUT v-time-templ-rl-root) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-dis-cfg-rule
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }


&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel }



/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  v-rid-list = p-rid-list.
  RUN Myenable IN THIS-PROCEDURE .
  run openbr in this-procedure ( INPUT ?, INPUT ?, INPUT 0, INPUT 0).
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
  DISPLAY Cb-pos-type Cb-table-name f-templ-rl-root f-dis-rule-des
          f-time-templ-rl-root f-dis-time-rule-des mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark b-sel b-add b-copy b-chg b-del b-lkp b-print B-Help
         Cb-pos-type Cb-table-name b-dis-ruls f-templ-rl-root f-dis-rule-des
         b-dist-rls f-time-templ-rl-root f-dis-time-rule-des br-dis-cfg-rule
         mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE ch AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii         AS INTEGER   NO-UNDO.

ch = br-dis-cfg-rule:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
DO ii = 1 TO br-dis-cfg-rule:NUM-COLUMNS IN FRAME {&FRAME-NAME}:
    ASSIGN
    ch:RESIZABLE = YES.
    ch = ch:NEXT-COLUMN.
END.
assign
v-list-items = "Все":U + {&comma-char} + "":U.
DO v-ii = 1 TO NUM-ENTRIES({&cd-type-codes-discnt}):
    ASSIGN
    v-list-items = v-list-items +  {&comma-char} +
                   ENTRY(v-ii, {&cd-type-codes-discnt-full}) + {&comma-char} +
                   ENTRY(v-ii, {&cd-type-codes-discnt}).
END.
assign
cb-pos-type:list-item-pairs in frame {&frame-name} = v-list-items.
assign
cb-table-name:list-item-pairs in frame {&frame-name} =
"Все":U + {&comma-char} + "":U + {&comma-char} +
{&table_dis-gds-rule-full} + {&comma-char} +
{&table_dis-gds-rule} + {&comma-char} +
{&table_dis-thbj-rule-full} + {&comma-char} +
{&table_dis-thbj-rule} + {&comma-char} +
{&table_dis-cp-rule-full} + {&comma-char} +
{&table_dis-cp-rule} + {&comma-char} +
{&table_dis-dc-rule-full} + {&comma-char} +
{&table_dis-dc-rule} + {&comma-char} +
{&table_dis-dct-rule-full} + {&comma-char} +
{&table_dis-dct-rule} + {&comma-char} +
{&table_dis-grp-rule-full} + {&comma-char} +
{&table_dis-grp-rule}
.
DISPLAY mark-num
WITH FRAME {&frame-name}.
ENABLE
b-quit
B-add WHEn (v-cntxt-db-num = 0)
B-copy WHEn (v-cntxt-db-num = 0)
B-chg WHEn (v-cntxt-db-num = 0)
B-del WHEn (v-cntxt-db-num = 0)
B-mark WHEn LOOKUP("b-mark", bttns) > 0
B-sel WHEN LOOKUP("b-sel", bttns) > 0
b-print
B-Help
b-lkp
br-dis-cfg-rule
mark-num
cb-pos-type
cb-table-name
b-dis-ruls
b-dist-rls
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
HIDE
mark-num
IN FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openbr Dialog-Frame
PROCEDURE openbr :
DEFINE INPUT PARAMETER p-pos-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-table-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-templ-rl-root AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-time-templ-rl-root AS integer NO-UNDO.
OPEN QUERY br-dis-cfg-rule
FOR EACH X_dis-cfg-rule NO-LOCK WHERE X_dis-cfg-rule.table-name > '':U and
        (p-pos-type = ? OR X_dis-cfg-rule.pos-type = p-pos-type)
    AND (p-table-name = ? OR X_dis-cfg-rule.table-name = p-table-name)
    AND (p-templ-rl-root = 0 OR X_dis-cfg-rule.templ-rl-root = p-templ-rl-root)
    AND (p-time-templ-rl-root = 0 OR X_dis-cfg-rule.time-templ-rl-root = p-time-templ-rl-root)
    ,
          first X_dis-rule NO-LOCK WHERE
          X_dis-rule.rule-num  = X_dis-cfg-rule.templ-rl-root
          INDEXED-REPOSITION.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
define variable v-doc-rec as recid no-undo .
define variable accum-count as integer.
define variable date_string     as      char    no-undo.
define variable Line            as      char    no-undo.
DEFINE VARIABLE v-rule-name AS CHARACTER no-undo.
DEFINE VARIABLE v-has-global AS logical NO-UNDO.
DEFINE VARIABLE v-has-host AS logical NO-UNDO.
DEFINE VARIABLE v-has-obj AS logical NO-UNDO.
DEFINE VARIABLE v-link-name AS CHARACTER NO-UNDO.

DEFINE FRAME dis-cfg-rule-list
X_dis-cfg-rule.pos-type FORMAT "X(15)":U COLUMN-LABEL "Место использ"
X_dis-cfg-rule.discnt-role  COLUMN-LABEL "Роль скидки" FORMAT "X(20)":U
v-rule-name COLUMN-LABEL "Роль скидки" FORMAT "X(35)":U
X_dis-cfg-rule.templ-rl-root FORMAT ">>>>9":U COLUMN-LABEL "Код!шабл"
X_dis-cfg-rule.time-templ-rl-root FORMAT "->>>>9":U COLUMN-LABEL "Код!шабл!распис"
X_dis-rule.des FORMAT "X(45)":U
v-has-global  FORMAT "+/" COLUMN-LABEL "Глоб"
v-has-host FORMAT "+/" COLUMN-LABEL "Фирма"
v-has-obj FORMAT "+/" COLUMN-LABEL "Объ"
X_dis-cfg-rule.self-nonunique FORMAT "X(18)" COLUMN-LABEL "Собств.Неуник"
X_dis-cfg-rule.nonunique FORMAT "X(20)" COLUMN-LABEL "Неуник"
X_dis-cfg-rule.table-name FORMAT "X(12)" COLUMN-LABEL "Таблица!связи"
v-link-name FORMAT "X(30)" COLUMN-LABEL "Вид связи"
HEADER  date_string AT 5 format "X(35)"
 string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(195)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 195).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(195)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME dis-cfg-rule-list  .
run waitfram-show in this-procedure ("Ждите...").
v-doc-rec = recid(X_dis-cfg-rule).
DO WHILE available X_dis-cfg-rule :
  GET prev br-dis-cfg-rule.
END.
GET next br-dis-cfg-rule.
DO WHILE available X_dis-cfg-rule :
  Display STREAM PrnLibStream
  X_dis-cfg-rule.pos-type
  X_dis-cfg-rule.discnt-role
  rule-name( INPUT X_dis-cfg-rule.table-name, INPUT X_dis-cfg-rule.self-nonunique, INPUT X_dis-cfg-rule.discnt-role) @ v-rule-name
  X_dis-cfg-rule.templ-rl-root
  X_dis-cfg-rule.time-templ-rl-root
  X_dis-rule.des
  logical(X_dis-cfg-rule.has-global) @ v-has-global
  logical(X_dis-cfg-rule.has-host) @ v-has-host
  logical(X_dis-cfg-rule.has-obj) @ v-has-obj
  X_dis-cfg-rule.self-nonunique
  X_dis-cfg-rule.nonunique
  X_dis-cfg-rule.table-name
  {&dr-link-name} @ v-link-name
  with FRAME dis-cfg-rule-list .
  DOWN STREAM PrnLibStream 1
  with FRAME dis-cfg-rule-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-dis-cfg-rule.
END.
UNDERLINE  STREAM PrnLibStream
X_dis-cfg-rule.pos-type
X_dis-cfg-rule.discnt-role
v-rule-name
X_dis-cfg-rule.templ-rl-root
X_dis-cfg-rule.time-templ-rl-root
X_dis-rule.des
v-has-global
v-has-host
v-has-obj
X_dis-cfg-rule.self-nonunique
X_dis-cfg-rule.nonunique
X_dis-cfg-rule.table-name
v-link-name
with FRAME dis-cfg-rule-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ X_dis-cfg-rule.pos-type
accum-count @ X_dis-cfg-rule.templ-rl-root
with frame dis-cfg-rule-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME dis-cfg-rule-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-dis-cfg-rule to recid v-doc-rec no-error.
APPLY "entry" to br-dis-cfg-rule.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION rule-name Dialog-Frame
FUNCTION rule-name RETURNS CHARACTER
  ( INPUT p-subject AS character, INPUT p-self-nonunique AS character, input p-discnt-role AS character ) :
DEFINE VARIABLE v-rule-name AS CHARACTER NO-UNDO.
&SCOPED-DEFINE dis-gds-rule-code p-discnt-role
&SCOPED-DEFINE dis-thbj-rule-code p-discnt-role
&SCOPED-DEFINE dis-cp-rule-code p-discnt-role
&SCOPED-DEFINE dis-dc-rule-code p-discnt-role
&SCOPED-DEFINE dis-dct-rule-code p-discnt-role
&SCOPED-DEFINE dis-ggr-rule-code p-discnt-role
&SCOPED-DEFINE dis-ggr-rule-code p-discnt-role
&SCOPED-DEFINE dis-clgr-rule-code p-discnt-role

CASE p-subject :
  WHEN {&TABLE_dis-gds-rule} THEN DO:
    v-rule-name = {&dis-gds-rule-name}.
  END.
  WHEN {&TABLE_dis-thbj-rule} THEN DO:
    v-rule-name = {&dis-thbj-rule-name}.
  END.
  WHEN {&TABLE_dis-cp-rule} THEN DO:
    v-rule-name = {&dis-cp-rule-name}.
  END.
  WHEN {&TABLE_dis-dc-rule} THEN DO:
    v-rule-name = {&dis-dc-rule-name}.
  END.
  WHEN {&TABLE_dis-dct-rule} THEN DO:
    v-rule-name = {&dis-dct-rule-name}.
  END.
  WHEN {&TABLE_dis-grp-rule} THEN DO:
    if p-self-nonunique = {&table_sum-grp} then do:
      v-rule-name = {&dis-ggr-rule-name}.
    end.
    if p-self-nonunique = {&table_cli-grp} then do:
      v-rule-name = {&dis-clgr-rule-name}.
    end.
  END.
END CASE.
RETURN v-RULE-name.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
