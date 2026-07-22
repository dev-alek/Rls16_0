&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER find_cd-clu FOR ub.cd-clu.
DEFINE BUFFER locked_cash-desk FOR ub.cash-desk.
DEFINE BUFFER X_cd-clu FOR ub.cd-clu.
DEFINE BUFFER X_cli-obj FOR ub.clients.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_staff FOR ub.staff.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Клиенты на кассе R-KEEPER

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/21/05
Author: Bakhtadze Natalya
Creation date: 02/21/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/

DEFINE INPUT PARAMETER p-mode  AS CHARACTER NO-UNDO.
/*{&all} "+" "-"*/
DEFINE INPUT PARAMETER p-status  AS CHARACTER NO-UNDO.
/*тип рассинхронизации по времени*/
/*"Д" "Н" - должность название- передается в виде
"yes" + {&delim-par} + "yes" "*/

DEFINE INPUT PARAMETER p-curr-obj-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-curr-obj-code LIKE ub.clients.obj-code NO-UNDO.
define input-output param p-rid-list    as  char no-undo .




/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Клиенты на кассе R-KEEPER".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/fltfield.i }
{ gbl/prn-lib.i }
{ str/libbcrcn.i      }
{ str/r-keepth.i }
{ gbl/getcntxt.i def }
{ ref/fbrglib.i }
{ cmp/mrk-strf.i }
{ gbl/fltopend.i defproc }

define variable filter-label as character no-undo init "Справочник персонала на кассе R-KEEPER" .
define variable filter-label0 as character no-undo init "Справочник персонала на кассе R-KEEPER" .
define variable filter-point0 as character no-undo init "rkep-cli" .
define variable filter-point as character no-undo init "rkep-cli" .
define variable sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
define variable v-mode as character no-undo .
define variable v-status as character no-undo .
DEFINE VARIABLE v-id as character no-undo .
DEFINE VARIABLE v-tab-order as character no-undo .
DEFINE VARIABLE v-name AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-role AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-rid-list AS character NO-UNDO.
DEFINE VARIABLE v-rkep-cli-role-list AS CHARACTER NO-UNDO INIT 'B,M,K,W'.
DEFINE VARIABLE v-th-role-list AS CHARACTER NO-UNDO .
ASSIGN
v-th-role-list = ",," + {&role-cashier} + {&comma-char} + {&role-seller}.

define buffer pos_cd-clu for ub.cd-clu.

&scop cant-positioning   if error-status:error then do: ~
                          find first pos_cd-clu no-lock where ~
                                  recid(pos_cd-clu) = loc-doc-rec no-error . ~
                            message ~
                            "Невозможно позиционироваться на записи ПЕРСОНАЛА" skip~
                            string(if avail pos_cd-clu ~
                                    then  substitute("Идентификатор: &1, название &2" ~
                                                    , pos_cd-clu.clu-code  ~
                                                    , pos_cd-clu.charkey_one) ~
                                    else "":U) skip ~
                            "Запись была добавлена (или изменена или удалена) -" skip ~
                            "и теперь не попадает в текущую выборку" ~
                            view-as alert-box WARNING. ~
                          end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-rkep-cli

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_cd-clu X_staff X_clients

/* Definitions for BROWSE BR-rkep-cli                                   */
&Scoped-define FIELDS-IN-QUERY-BR-rkep-cli mark-string( recid(X_cd-clu), v-rid-list) X_cd-clu.clu-code X_cd-clu.clu-type X_cd-clu.charkey_one get-crole-diff(BUFFER X_staff) @ v-role get-cname-diff(BUFFER X_clients) @ v-name X_cd-clu.cli-code X_clients.obj-name X_staff.staff-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-rkep-cli X_cd-clu.charkey_one
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-rkep-cli X_cd-clu
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-rkep-cli X_cd-clu
&Scoped-define SELF-NAME BR-rkep-cli
&Scoped-define QUERY-STRING-BR-rkep-cli FOR EACH X_cd-clu NO-LOCK, ~
            FIRST X_staff OUTER-JOIN NO-LOCK where X_staff.psn-code = X_cd-clu.cli-code         AND  X_staff.role = entry(lookup(X_cd-clu.clu-type, ~
       v-rkep-cli-role-list), ~
       v-th-role-list)         and X_staff.db-num = v-db-num         and X_staff.date-end = {&end-of-age}, ~
           FIRST X_clients OUTER-JOIN NO-LOCK WHERE X_clients.obj-type = {&prs}         AND X_clients.obj-code = X_staff.psn-code      INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-rkep-cli OPEN QUERY {&SELF-NAME} FOR EACH X_cd-clu NO-LOCK, ~
            FIRST X_staff OUTER-JOIN NO-LOCK where X_staff.psn-code = X_cd-clu.cli-code         AND  X_staff.role = entry(lookup(X_cd-clu.clu-type, ~
       v-rkep-cli-role-list), ~
       v-th-role-list)         and X_staff.db-num = v-db-num         and X_staff.date-end = {&end-of-age}, ~
           FIRST X_clients OUTER-JOIN NO-LOCK WHERE X_clients.obj-type = {&prs}         AND X_clients.obj-code = X_staff.psn-code      INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-rkep-cli X_cd-clu X_staff X_clients
&Scoped-define FIRST-TABLE-IN-QUERY-BR-rkep-cli X_cd-clu
&Scoped-define SECOND-TABLE-IN-QUERY-BR-rkep-cli X_staff
&Scoped-define THIRD-TABLE-IN-QUERY-BR-rkep-cli X_clients


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-rkep-cli}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-link b-chg B-print ~
B-sch B-Help T-batch rs-mode T-role T-name RS-sch sch-name sch-id ~
BR-rkep-cli mark-num
&Scoped-Define DISPLAYED-OBJECTS T-batch rs-mode T-role T-name RS-sch ~
sch-name sch-id mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cname-diff Dialog-Frame
FUNCTION get-cname-diff RETURNS LOGICAL
  ( BUFFER loc-clients FOR ub.clients )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-crole-diff Dialog-Frame
FUNCTION get-crole-diff RETURNS LOGICAL
  ( BUFFER loc-staff FOR ub.staff )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-chg
     LABEL "С&инхрон."
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-link
     LABEL "&Связать"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sch-id AS INTEGER FORMAT "->>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-name AS CHARACTER FORMAT "X(35)":U
     VIEW-AS FILL-IN
     SIZE 41.38 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE rs-mode AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 33.5 BY 1 NO-UNDO.

DEFINE VARIABLE RS-sch AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Идентиф-р", "id",
"Нач.имени", "name"
     SIZE 28 BY 1 NO-UNDO.

DEFINE VARIABLE T-batch AS LOGICAL INITIAL no
     LABEL "Пакетный режим"
     VIEW-AS TOGGLE-BOX
     SIZE 18.13 BY 1 NO-UNDO.

DEFINE VARIABLE T-name AS LOGICAL INITIAL no
     LABEL "Назв."
     VIEW-AS TOGGLE-BOX
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE T-role AS LOGICAL INITIAL no
     LABEL "Должность"
     VIEW-AS TOGGLE-BOX
     SIZE 12 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-rkep-cli FOR
      X_cd-clu,
      X_staff,
      X_clients SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-rkep-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-rkep-cli Dialog-Frame _FREEFORM
  QUERY BR-rkep-cli NO-LOCK DISPLAY
      mark-string( recid(X_cd-clu), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
X_cd-clu.clu-code  COLUMN-LABEL "Идентиф-р"  FORMAT "9999":U
X_cd-clu.clu-type COLUMN-LABEL "Должность" FORMAT "X(4)":U
X_cd-clu.charkey_one COLUMN-LABEL "Имя на кассе R-KEEPER" FORMAT "X(30)":U
get-crole-diff(BUFFER X_staff) @ v-role COLUMN-LABEL "Д" FORMAT "+/-"
get-cname-diff(BUFFER X_clients) @ v-name COLUMN-LABEL "Н" FORMAT "+/-"
X_cd-clu.cli-code COLUMN-LABEL "Код в IBS TH" FORMAT ">>>>>>>>9":U
X_clients.obj-name COLUMN-LABEL "Имя в IBS TH" FORMAT "X(30)":U
X_staff.staff-code COLUMN-LABEL "Код персонала!в IBS TH" FORMAT ">>>>9"
ENABLE X_cd-clu.charkey_one
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 17.75 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     B-link AT ROW 1 COL 41
     b-chg AT ROW 1 COL 51
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     T-batch AT ROW 2 COL 1
     rs-mode AT ROW 2 COL 20 NO-LABEL
     T-role AT ROW 2 COL 60
     T-name AT ROW 2 COL 75
     RS-sch AT ROW 3 COL 11 NO-LABEL
     sch-name AT ROW 3 COL 55 COLON-ALIGNED NO-LABEL
     sch-id AT ROW 3 COL 55 COLON-ALIGNED NO-LABEL
     BR-rkep-cli AT ROW 4 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 8.5 BY 1 AT ROW 3 COL 1.5
          FGCOLOR 4
     SPACE(89.24) SKIP(18.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Персонал на кассе R-KEEPER"
         DEFAULT-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: find_cd-clu B "?" ? ub cd-clu
      TABLE: locked_cash-desk B "?" ? ub cash-desk
      TABLE: X_cd-clu B "?" ? ub cd-clu
      TABLE: X_cli-obj B "?" ? ub clients
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_staff B "?" ? ub staff
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-rkep-cli sch-id Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-rkep-cli
/* Query rebuild information for BROWSE BR-rkep-cli
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_cd-clu NO-LOCK,
     FIRST X_staff OUTER-JOIN NO-LOCK where X_staff.psn-code = X_cd-clu.cli-code
        AND  X_staff.role = entry(lookup(X_cd-clu.clu-type, v-rkep-cli-role-list), v-th-role-list)
        and X_staff.db-num = v-db-num
        and X_staff.date-end = {&end-of-age},
    FIRST X_clients OUTER-JOIN NO-LOCK WHERE X_clients.obj-type = {&prs}
        AND X_clients.obj-code = X_staff.psn-code
     INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BR-rkep-cli */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Персонал на кассе R-KEEPER */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Персонал на кассе R-KEEPER */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Синхрон. */
DO:
  assign
  t-name
  t-role
  .
  if not t-name
  and not t-role
  then do:
    message
    "Не выбрана ни одна опция для синхронизации" skip
    "(название, должность)"
    view-as alert-box error .
    return no-apply.
  end.

run str/diallog.w (
              input parparentproc
            , input THIS-PROCEDURE
            , input 'str/rkepsyn3.p':U
            , input (p-curr-obj-type + {&delim-par} +
              string(p-curr-obj-code) + {&delim-par} +
              (if t-batch
              then v-rid-list
              else string(recid(X_cd-clu)))
               ) + {&delim-par} +
              ((if t-name then "name":U else "":U) + {&comma-char} +
              (if t-role then "role":U else "":U)
              )
            , input no
            , input 'Прервать'
            , input 'Синхронизация данных по персоналу на кассе R-KEEPER и соответствующих данных в IBS TH')
             .
  RUn OpenBR ( input yes, input no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if v-rid-list <> "":U then
  REPOSITION br-rkep-cli to recid integer(entry(1, v-rid-list)) No-ERROR.

  APPLY "VALUE-CHANGED" to br-rkep-cli.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-link
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-link Dialog-Frame
ON CHOOSE OF B-link IN FRAME Dialog-Frame /* Связать */
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
define variable varrid-list as character no-undo .
define variable choice AS integer no-undo .

if not available X_cd-clu then return no-apply.

define variable v-host-code as integer   no-undo .
{ gbl/hostcode.i
  p-curr-obj-type
  p-curr-obj-code
  v-host-code
}
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_cashdesk-cashiers_update':U
  {&cntxt-object}
  v-host-code
  p-curr-obj-type
  p-curr-obj-code
  0
  0
  0
  true
  loc#log
}
if not loc#log then return no-apply.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_cashdesk-sellers_update':U
  {&cntxt-object}
  v-host-code
  p-curr-obj-type
  p-curr-obj-code
  0
  0
  0
  true
  loc#log
}
if not loc#log then return no-apply.
loc-doc-rec = recid(X_cd-clu).
IF X_cd-clu.clu-type = "B":U
OR X_cd-clu.clu-type = "M":U THEN DO:
  run gbl/d-askw.w ( input "Выбор должности для связывания записи",
                      input ( "Вы хотите связать данную запись с должностью"
                                ),
                      input "|",
                      input "Кассира|Официанта(продавца)|Отказ от связывания",
                      input "||",
                      input 1,
                      input 3,
                      output choice).

  if choice = 4 then return.
END.
ELSE DO:
  IF X_cd-clu.clu-type = "W" THEN choice = 2.
  IF X_cd-clu.clu-type = "K" THEN choice = 1.

END.
run ref/staffs.w (
                  input parparentproc
                , input "b-sel,b-mark"
                , input (if choice = 2 then {&role-seller} else {&role-cashier})
                , input v-db-num
                , input 0
                , output varrid-list ) .
if varrid-list = "" then undo, return no-apply.
run proc-b-link in this-procedure ( INPUT recid(X_cd-clu), input integer(varrid-list)) no-error.
if error-status:error then return no-apply.
RUn OpenBR in this-procedure (input  yes, input no, input '':U).
reposition br-rkep-cli to recid loc-doc-rec no-error.
{&cant-positioning}
apply "entry" to br-rkep-cli in frame {&frame-name}.
apply "value-changed" to br-rkep-cli in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable loc#log as logical no-undo .
  if available X_cd-clu then do:
    { gbl/markstrn.i X_cd-clu v-rid-list }
    loc#log = br-rkep-cli:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-rkep-cli:select-next-row ().
        apply "VALUE-CHANGED" to br-rkep-cli in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-rkep-cli in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  if not avail X_cd-clu then return no-apply.
  run proc-b-print in this-procedure  no-error.
  if error-status:error then do:
     return no-apply.
  end.
  APPLY "ENTRY" to br-rkep-cli.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if ( available X_cd-clu ) then do:
    if ( v-rid-list = "" ) or b-mark:sensitive = no then
    v-rid-list = string( recid( X_cd-clu ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-mode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-mode Dialog-Frame
ON VALUE-CHANGED OF rs-mode IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-mode
  v-mode = rs-mode
  .
  CASE rs-mode:
      WHEN "+":U THEN DO:
          ENABLE
          b-chg
          T-role
          T-name
          T-batch
          WITH FRAME {&FRAME-NAME}.
      END.
      OTHERWISE do:
          ASSIGN
          t-role = NO
          t-name = NO
          t-batch = NO    .
          DISPLAY
          t-role
          t-name
          t-batch
          WITH FRAME {&FRAME-NAME}.
          DISABLE
          T-role
          T-name
          t-batch
          b-chg
          WITH FRAME {&FRAME-NAME}.
    END.
  END CASE.
  run openbr IN THIS-PROCEDURE (input  YES, input  NO, input  '':U) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-sch Dialog-Frame
ON VALUE-CHANGED OF RS-sch IN FRAME Dialog-Frame
DO:
  run proc-rs-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-id
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-id Dialog-Frame
ON CTRL-J OF sch-id IN FRAME Dialog-Frame
DO:
  run proc-find-id in this-procedure (input yes, input frame {&frame-name} sch-id) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-id Dialog-Frame
ON RETURN OF sch-id IN FRAME Dialog-Frame
DO:
  run proc-find-id in this-procedure (input no, input frame {&frame-name} sch-id) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-name Dialog-Frame
ON CTRL-J OF sch-name IN FRAME Dialog-Frame
DO:
  run proc-find-name in this-procedure (input  yes, input frame {&frame-name} sch-name) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-name Dialog-Frame
ON RETURN OF sch-name IN FRAME Dialog-Frame
DO:
  run proc-find-name in this-procedure (input no, input frame {&frame-name} sch-name) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-batch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-batch Dialog-Frame
ON VALUE-CHANGED OF T-batch IN FRAME Dialog-Frame /* Пакетный режим */
DO:
define variable GLOG as logical no-undo .
  assign
  t-batch.
  run proc-buttons in this-procedure (input t-batch).
  if t-batch = no
  and b-mark:sensitive = no then do:
    assign
    v-rid-list = "":U.
    if avail X_cd-clu then
    GLOG = BR-rkep-cli:refresh().
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-name Dialog-Frame
ON VALUE-CHANGED OF T-name IN FRAME Dialog-Frame /* Назв. */
DO:
  ASSIGN
  t-name
  .
  run openbr IN THIS-PROCEDURE ( input YES, input  NO, input '':U) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-role
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-role Dialog-Frame
ON VALUE-CHANGED OF T-role IN FRAME Dialog-Frame /* Должность */
DO:
  ASSIGN
  t-role
  .
  case t-role :
      WHEN YES THEN DISABLE b-chg WITH FRAME {&FRAME-NAME}.
      WHEN no THEN enable b-chg WITH FRAME {&FRAME-NAME}.
  END CASE.
  RUN openbr IN THIS-PROCEDURE ( input  YES, input NO, input '':U) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-rkep-cli
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/setfltnm.i }
{ ref/tabhndmv.i v-tab-order underline-tb }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-quit in frame {&frame-name}." }


 { gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &label-clmn_1   = "v-id"
  &sort-clmn_1    = "X_cd-clu.clu-code"
  &sort-clmn_2    = "X_cd-clu.charkey_one"
  &open-query     = "run OpenBr in this-procedure (input  yes, input no, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }
  v-rid-list = p-rid-list.
  if p-mode <> {&all} and p-mode <> "+":U
      AND p-mode <> "-":U then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return.
 end.
 find first X_cli-obj no-lock where
                X_cli-obj.obj-type = p-curr-obj-type
            and X_cli-obj.obj-code = p-curr-obj-code no-error.
    if not available X_cli-obj then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-curr-obj-type и/или p-curr-obj-code"
          view-as alert-box ERROR.
        return.
    end.
  if v-rid-list <> "" then do:
      FIND FIRST find_cd-clu No-LOCK where
                 recid(find_cd-clu) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_cd-clu then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова v-rid-list" v-rid-list
        view-as alert-box error .
        return error.
      end.
      v-doc-rec = integer(entry(1, v-rid-list)).
    end.
  { gbl/curdbnum.i v-db-num }
  if v-db-num <> X_cli-obj.db-num then do:
    message
    "Нельзя работать с персоналом объекта удаленной БД"
    view-as alert-box error .
    undo, return error .
  end.

  do transaction
  on error undo main-block, return error
  :
    FIND FIRST LOCKED_cash-desk EXCLUSIVE-LOCK WHERE
              LOCKED_cash-desk.obj-code = p-curr-obj-code
          AND LOCKED_cash-desk.db-num = v-db-num
          AND LOCKED_cash-desk.pos-type = {&cd-type-r-keeper}
          NO-WAIT NO-ERROR.
    IF NOT AVAILABLE locked_cash-desk AND NOT LOCKED locked_cash-desk THEN DO:
        MESSAGE
        SUBSTITUTE("На &1&2 не определена касса типа &3&4" +
                  "Нельзя работать с персоналом "
                  , p-curr-obj-type
                  , p-curr-obj-code
                  , {&cd-type-r-keeper}
                  , {&new-line}
                  )
      VIEW-AS ALERT-BOX ERROR.
      UNDO main-block, RETURN ERROR.
    END.
    IF LOCKED locked_cash-desk THEN DO:
        MESSAGE
        SUBSTITUTE("На &1&2 в настоящее время занята запись кассы типа &3&4" +
                  "Нельзя работать с товарами на кассе"
                  , p-curr-obj-type
                  , p-curr-obj-code
                  , {&cd-type-r-keeper}
                  , {&NEW-LINE})
      VIEW-AS ALERT-BOX ERROR.
      UNDO main-block, RETURN ERROR.
    END.
  end.
  RUN MyEnable in this-procedure .
  RUn OpenBR in this-procedure ( input yes, input  no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if v-rid-list <> "":U then
  REPOSITION br-rkep-cli to recid integer(entry(1, v-rid-list)) No-ERROR.
  { gbl/mv-clmn.i
    &browse-name = "br-rkep-cli"
    &frame-name = "{&frame-name}"
    &ext-col = 9
    &start-column = 2
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9'"
    &prev-order-column-condition_1 = " true "
    }

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .

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
  DISPLAY T-batch rs-mode T-role T-name RS-sch sch-name sch-id mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-link b-chg B-print B-sch B-Help T-batch rs-mode
         T-role T-name RS-sch sch-name sch-id BR-rkep-cli mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
v-tab-order = "b-quit,b-mark,b-sel,b-link,b-chg,b-sch,b-print,b-help," +
              "t-batch,rs-mode,t-role,t-name," +
               "rs-sch,sch-id,sch-full_name,br-rkep-cli"
br-rkep-cli:num-locked-columns in frame {&frame-name} = 1
X_cd-clu.charkey_one:read-only in browse br-rkep-cli = yes
rs-mode:RADIO-BUTTONS IN FRAME {&FRAME-NAME}
                       = "С привязкой&+" + {&comma-char} +  "+":U + {&comma-char} +
                       "Все&!" + {&comma-char} + {&all} + {&comma-char} +
                        "Без привязки&-" + {&comma-char} + "-":U
rs-mode = p-mode
t-name = logical(entry(1, p-status, {&delim-par}))
t-role = logical(entry(2, p-status, {&delim-par}))
.
rs-sch = "id":U.
DISPLAY
rs-mode
sch-id
mark-num
WITH FRAME {&frame-name}.
run proc-buttons in this-procedure ( input no).
ENABLE
b-quit
b-sel WHEN lookup("b-sel", bttns) > 0
b-chg
B-sch
B-print
B-Help
rs-mode
rs-sch
BR-rkep-cli
WITH FRAME {&FRAME-NAME}.
VIEW FRAME {&FRAME-NAME}.
RUN proc-rs-sch IN THIS-PROCEDURE.
APPLY "VALUE-CHANGED" TO rs-mode.
APPLY "ENTRY" TO BR-rkep-cli.
IF t-role THEN APPLY "VALUE-CHANGED" TO t-role.
IF t-name THEN APPLY "VALUE-CHANGED" TO t-name.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Справочник персонала на кассе R-KEEPER" + {&space-char}.
run waitfram-show in this-procedure ( input "Ждите...").
define variable sort-column-phrase as character no-undo .

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

&scop flt-open-open-query OPEN QUERY br-rkep-cli FOR EACH X_cd-clu

&scop flt-open-dyn_open-query FOR EACH X_cd-clu

&scop flt-open-query-handle  QUERY br-rkep-cli:handle

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_cd-clu

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_cd-clu

&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .


  CASE v-mode :

    WHEN {&all}        THEN DO:
     assign
     filter-point = filter-point0 + v-mode
     filter-label = substitute("&1 Один объект", filter-label0)
     .
      if p-open-query then do:
        frame {&frame-name}:TITLE = title0.
      end.
    { gbl/fltopend.i
      &where-cond = " X_cd-clu.obj-type = p-curr-obj-type and X_cd-clu.obj-code = p-curr-obj-code and X_cd-clu.pos-type = {&cd-type-r-keeper} "
      &dyn_where-cond = " substitute('X_cd-clu.obj-type = &1&2&1 and X_cd-clu.obj-code = &3 and X_cd-clu.pos-type = &1&4&1 ' ~
                             , ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, {&cd-type-r-keeper})"
      &use-ind    = "  "
      &by         = "  "
      &flt-open-open-query-tail = ", FIRST X_staff outer-join NO-LOCK WHERE X_staff.psn-code = X_cd-clu.cli-code ~
                                        /*and X_staff.role = entry(lookup(X_cd-clu.clu-type, v-rkep-cli-role-list), v-th-role-list)*/ ~
                                        and X_staff.db-num = v-db-num ~
                                        and X_staff.date-end = {&end-of-age}, ~
                                  first X_clients outer-join no-lock where X_clients.obj-type = ~{&prs~} AND ~
                                       X_clients.obj-code  = X_staff.psn-code "
      &flt-open-dyn_open-query-tail = " substitute(', FIRST X_staff outer-join NO-LOCK WHERE X_staff.psn-code = X_cd-clu.cli-code ~
                                        /*and X_staff.role = entry(lookup(X_cd-clu.clu-type, &1&2&1), &1&3&1)*/ ~
                                        and X_staff.db-num = &4 ~
                                        and X_staff.date-end = &5, ~
                                  first X_clients outer-join no-lock where X_clients.obj-type = &1&6&1 AND ~
                                       X_clients.obj-code  = X_staff.psn-code ', ~{&double-quote~}, v-rkep-cli-role-list, v-th-role-list, v-db-num, {&end-of-age}, ~{&prs~})"

        }

    END.
    WHEN "-":U THEN DO:
      ASSIGN
      filter-point = filter-point0 + v-mode
      filter-label = substitute("&1 Один объект, Без связи с персоналом в IBS TH", filter-label0)
      .
      if p-open-query then do:
        frame {&frame-name}:TITLE = title0 +
                                      substitute(" Без связи с персоналом в IBS TH").
      end.
      { gbl/fltopend.i
        &where-cond = " X_cd-clu.obj-type = p-curr-obj-type and X_cd-clu.obj-code = p-curr-obj-code ~
                      and X_cd-clu.pos-type = {&cd-type-r-keeper}
                      and (X_cd-clu.cli-code = 0 OR X_cd-clu.cli-code = ?)"
                      "
        &dyn_where-cond = " substitute('X_cd-clu.obj-type = &1&2&1 and X_cd-clu.obj-code = &3 ~
                      and X_cd-clu.pos-type = &1&4&1
                      and (X_cd-clu.cli-code = 0 OR X_cd-clu.cli-code = ?)', ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, {&cd-type-r-keeper})"

        &use-ind    = "  "
        &by         = "  "
        &flt-open-open-query-tail = ", FIRST X_staff  ~
                                    , first X_clients OUTER-JOIN "
       }

       END.
     when "+":U then do:
       ASSIGN
       filter-point = filter-point0 + v-mode
       filter-label = substitute("&1 Один объект, Связанные с персоналом в IBS TH", filter-label0)
       .
       if p-open-query then do:
          frame {&frame-name}:TITLE = title0 +
                                        substitute(" Связанные с персоналом в IBS TH").
       end.
       { gbl/fltopend.i
        &where-cond = " X_cd-clu.obj-type = p-curr-obj-type and X_cd-clu.obj-code = p-curr-obj-code and X_cd-clu.pos-type = {&cd-type-r-keeper} "
        &dyn_where-cond = " substitute('X_cd-clu.obj-type = &1&2&1 and X_cd-clu.obj-code = &3 and X_cd-clu.pos-type = &1&4&1 ' ~
                             , ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, {&cd-type-r-keeper})"
        &use-ind    = "  "
        &by         = "  "
        &flt-open-open-query-tail = ", FIRST X_staff outer-join NO-LOCK WHERE X_staff.psn-code = X_cd-clu.cli-code ~
                                              /*and X_staff.role = entry(lookup(X_cd-clu.charkey_one, v-rkep-cli-role-list), v-th-role-list)*/ ~
                                              and X_staff.db-num = v-db-num ~
                                              and X_staff.date-end = {&end-of-age}, ~
                                        first X_clients outer-join no-lock where X_clients.obj-type = ~{&prs~} AND ~
                                              X_clients.obj-code  = X_staff.psn-code "
        &flt-open-dyn_open-query-tail = " substitute(' , FIRST X_staff outer-join NO-LOCK WHERE X_staff.psn-code = X_cd-clu.cli-code ~
                                              /*and X_staff.role = entry(lookup(X_cd-clu.charkey_one, &1&2&1), &1&3&1)*/ ~
                                              and X_staff.db-num = &4 ~
                                              and X_staff.date-end = &5, ~
                                        first X_clients outer-join no-lock where X_clients.obj-type = &1&6&1 AND ~
                                              X_clients.obj-code  = X_staff.psn-code ', ~{&double-quote~}, v-rkep-cli-role-list, v-th-role-list, v-db-num, {&end-of-age}, ~{&prs~})"


        }
   END.
END CASE.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-rkep-cli to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-rkep-cli:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-rkep-CLI in frame {&frame-name}.
APPLY "ENTRY" TO br-rkep-CLI.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-link Dialog-Frame
PROCEDURE proc-b-link :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-recid  AS RECID no-undo.
DEFINE INPUT PARAMETER p-clients-recid as recid no-undo.

DEFINE VARIABLE loclog AS LOGICAL NO-UNDO.
define variable v-doc-num as character no-undo .

DEFINE BUFFER buf_cd-clu FOR ub.cd-clu.
DEFINE BUFFER buf_staff FOR ub.staff.
do
on error undo, return error
:

  FIND FIRST buf_cd-clu EXCLUSIVE-LOCK WHERE
            RECID(buf_cd-clu) = p-recid.
  IF buf_cd-clu.obj-code <> 0
  and buf_cd-clu.obj-code <> ?  THEN DO:
    MESSAGE
    SUBSTITUTE("Запись персонала с идентификатором &1 уже привязан к записи персонала в IBS TH c кодом &2&3" +
                "заменить привязку?"
                , buf_cd-clu.clu-code
                , buf_cd-clu.cli-code
                , {&NEW-LINE}
                )
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE loclog.
      IF NOT loclog THEN RETURN ERROR.
  END.

  find first buf_staff no-lock where
          recid(buf_staff) = p-clients-recid  .
  ASSIGN
  buf_cd-clu.cli-code = buf_staff.psn-code
  .
END. /*doe*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-doc-rec as recid no-undo .
define variable accum-count as integer.
define variable date_string     as      CHARACTER    no-undo.
define variable Line            as      CHARACTER    no-undo.
DEFINE variable v-loc-id               as CHARACTER    no-undo.
DEFINE VARIABLE v-loc-name AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-loc-role AS LOGICAL NO-UNDO.
DEFINE BUFFER buf_fbr-gds-grp FOR ub.fbr-gds-grp.

DEFINE FRAME cd-clu-list
X_cd-clu.clu-code COLUMN-LABEL "Идентиф-р" FORMAT "9999":U
X_cd-clu.charkey_one COLUMN-LABEL "Имя на кассе R-KEEPER/!       в IBS TH" FORMAT "X(27)":U
v-loc-role COLUMN-LABEL "Д" FORMAT "+/-"
v-loc-name COLUMN-LABEL "Н" FORMAT "+/-"
X_staff.staff-code COLUMN-LABEL "Код персонала!в IBS TH" FORMAT ">>>>9"
HEADER  date_string AT 5 format "X(35)"
 string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(195)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 195).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parparentProc
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

FORM with FRAME cd-clu-list  .
run waitfram-show in this-procedure ( input "Ждите...").
v-doc-rec = recid(X_cd-clu).
DO WHILE available X_cd-clu :
  GET prev br-rkep-cli.
END.
GET next br-rkep-cli.
DO WHILE available X_cd-clu :
  Display STREAM PrnLibStream
  X_cd-clu.clu-code
  X_cd-clu.charkey_one
  get-cname-diff(buffer X_clients) @ v-loc-name
  get-crole-diff(buffer X_staff) @ v-loc-role
  with FRAME cd-clu-list .
  DOWN STREAM PrnLibStream 1
  with FRAME cd-clu-list  .
  IF AVAILABLE X_staff  THEN do:
    Display STREAM PrnLibStream
    X_staff.staff-code
    with FRAME cd-clu-list .
    Display STREAM PrnLibStream
    X_clients.obj-name @ X_cd-clu.charkey_one
    with FRAME cd-clu-list .
    DOWN STREAM PrnLibStream 1
    with FRAME cd-clu-list  .
  END.
  ELSE DO:
    DOWN STREAM PrnLibStream 1
    with FRAME cd-clu-list .
  END.

  assign
  accum-count = accum-count + 1
  .
  GET next br-rkep-cli.
END.
UNDERLINE  STREAM PrnLibStream
X_cd-clu.clu-code
X_cd-clu.charkey_one
X_staff.staff-code
with FRAME cd-clu-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ v-loc-id
accum-count @ X_cd-clu.charkey_one
with frame cd-clu-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME cd-clu-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-rkep-cli to recid v-doc-rec no-error.
APPLY "entry" to br-rkep-cli.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parparentproc
                                          ,input 8
                                          ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
  tbl = 'cd-clu'
  join-tbl = 'X_cd-clu'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('charkey_one', 'Имя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('clu-type', 'Должность', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('to-send', 'Статус', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
               , INPUT (filter-point +  {&delim-par} +
                        filter-label + {&delim-par} +
                        string(yes))
               , INPUT tbl
               , INPUT join-tbl
               , INPUT fld
               , INPUT lab
               , INPUT spr
               , INPUT dim ).
  RUN OpenBr ( input yes, input no, input '':U).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-buttons Dialog-Frame
PROCEDURE proc-buttons :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-is-batch as logical no-undo.

CASE p-is-batch:
    when yes then do:
        ENABLE
        B-mark
        with frame {&frame-name}.
        disable
        b-link
        with frame {&frame-name}.
    end.
    when no then do:
        ENABLE
        B-mark when lookup("b-mark":U, bttns) > 0
        B-link
        with frame {&frame-name}.
        DISABLE
        b-mark when lookup("b-mark":U, bttns) = 0
        with frame {&frame-name}.
    end.
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-id Dialog-Frame
PROCEDURE proc-find-id :
define input parameter p-next as logical no-undo.
define input parameter p-id AS integer no-undo.

run OpenBr in this-procedure (
     input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_cd-clu.clu-code = &1 "
      , p-id)
    ).
apply "entry":u to sch-id in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-name Dialog-Frame
PROCEDURE proc-find-name :
define input parameter p-next as logical no-undo.
define input parameter p-name like ub.cd-clu.charkey_one no-undo.

assign
p-name = replace(p-name, {&double-quote}, "":U)
p-name = replace(p-name, {&single-quote}, {&single-quote} + {&single-quote})
p-name = {&double-quote} + p-name + {&double-quote}.

run OpenBr in this-procedure (
     input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_cd-clu.charkey_one begins &1 "
      , p-name)
    ).
apply "entry":u to sch-name in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-rs-sch Dialog-Frame
PROCEDURE proc-rs-sch :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
case input frame {&frame-name} rs-sch :
    when "id" then do:
      enable
      sch-id
      with frame {&frame-name}.
      display
      sch-id
      with frame {&frame-name}.
      hide
      sch-name
      in frame {&frame-name}.
      apply "entry" to sch-id in frame {&frame-name}.
    end.
    when "name" then do:
      enable
      sch-name
      with frame {&frame-name}.
      display
      sch-name
      with frame {&frame-name}.
      hide
      sch-id
      in frame {&frame-name}.
      apply "entry" to sch-name in frame {&frame-name}.
    end.

  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cname-diff Dialog-Frame
FUNCTION get-cname-diff RETURNS LOGICAL
  ( BUFFER loc-clients FOR ub.clients ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
 IF AVAILABLE loc-clients THEN
 RETURN (loc-clients.obj-name <> X_cd-clu.charkey_one).   /* Function return value. */
 RETURN NO.



END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-crole-diff Dialog-Frame
FUNCTION get-crole-diff RETURNS LOGICAL
  ( BUFFER loc-staff FOR ub.staff ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
IF NOT AVAILABLE loc-staff THEN RETURN YES.
RETURN NO.
/* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
