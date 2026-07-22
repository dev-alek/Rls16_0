&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
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

Справочник сертификатов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/27/05
Author: Bakhtadze Natalya
Creation date: 09/27/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter p-mode as character no-undo .
define input parameter i-point as char no-undo.
define input parameter i-b-code like ub.bar-code.b-code no-undo.
define input parameter i-type as char no-undo.
define input parameter i-code as integer no-undo.
define input parameter i-sert-code as character no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник сертификатов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/operlist.i }
{ cmp/r-pril.i new }
{ cmp/breakstr.i }
{ gbl/waitfram.i }
{ gbl/prn-lib.i }


define new shared buffer b-sert for ub.sert.
define new shared buffer b-sert-join for ub.sert-join.
define new shared buffer b-clients for ub.clients.
define new shared buffer b-goods for ub.goods.
define new shared buffer b-bar-code for ub.bar-code.
DEFINE VAR cli-name like ub.clients.obj-name no-undo.
DEFINE VAR gds-name like ub.goods.gds-name no-undo.
define variable rec as recid no-undo.
define variable sort-column-name as character no-undo .
define variable i-days as integer no-undo.
define variable s-point as char no-undo.
define variable s-b-code like ub.bar-code.b-code no-undo.
define variable s-type as char no-undo.
define variable s-code as integer no-undo.
define stream prnlibstream.
DEFINE variable for-cli-name as character no-undo.
DEFINE variable for-status as character no-undo.
DEFINE variable for-artic as character no-undo.
DEFINE variable for-gds-name as character no-undo.
define variable v-doc-rec as recid no-undo .
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
DEFINE VARIABLE hist-option AS CHARACTER NO-UNDO.

DEFINE FRAME SErtF
b-sert.cli-type COLUMN-LABEL " Тип"
b-sert.cli-code COLUMN-LABEL " Код" format "9999999999"
for-cli-name COLUMN-LABEL "Контрагент" FORMAT "X(30)"
b-sert.sert-code format "x(20)" COLUMN-LABEL  "Код сертификата"
b-sert.first-date
b-sert.last-date
for-status COLUMN-LABEL "Статус" FORMAT "X(7)"
b-sert.PS
for-artic COLUMN-LABEL "Артикул" FORMAT "X(16)"
for-gds-name COLUMN-LABEL "Наименование" FORMAT "X(25)"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(prnlibstream) AT 125 FORMAT ">>9" SKIP
Line format "X(198)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

&SCOPED-DEFINE r-b-sort-all 1
&SCOPED-DEFINE r-b-sort-cli 2
&SCOPED-DEFINE r-b-sort-b-code 3
&SCOPED-DEFINE r-b-sort-true 4
&SCOPED-DEFINE r-b-sort-over 5
&SCOPED-DEFINE r-b-sort-day-off 6

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-docs

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES b-sert-join b-sert

/* Definitions for BROWSE br-docs                                       */
&Scoped-define FIELDS-IN-QUERY-br-docs b-sert.cli-type b-sert.cli-code get-cli-name (buffer b-sert) b-sert.sert-code b-sert.first-date b-sert.last-date get-status (buffer b-sert) b-sert.PS get-gds-artic (buffer b-sert-join) get-gds-name (buffer b-sert-join)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-docs
&Scoped-define SELF-NAME br-docs
&Scoped-define QUERY-STRING-br-docs FOR EACH b-sert-join WHERE             b-sert-join.b-code = i-b-code NO-LOCK, ~
           each b-sert WHERE b-sert.SERT-CODE = B-SERT-JOIN.SERT-CODE no-lock     BY b-sert.last-date DESCENDING
&Scoped-define OPEN-QUERY-br-docs OPEN QUERY {&SELF-NAME} FOR EACH b-sert-join WHERE             b-sert-join.b-code = i-b-code NO-LOCK, ~
           each b-sert WHERE b-sert.SERT-CODE = B-SERT-JOIN.SERT-CODE no-lock     BY b-sert.last-date DESCENDING.
&Scoped-define TABLES-IN-QUERY-br-docs b-sert-join b-sert
&Scoped-define FIRST-TABLE-IN-QUERY-br-docs b-sert-join
&Scoped-define SECOND-TABLE-IN-QUERY-br-docs b-sert


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-docs}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-cli b-del B-print v-b-code B-hist ~
B-Help v-days v-code v-type r-b-sort br-docs
&Scoped-Define DISPLAYED-OBJECTS v-b-code v-artic v-gds-name v-days v-code ~
v-type r-b-sort

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cli-name Dialog-Frame
FUNCTION get-cli-name RETURNS CHARACTER
  (buffer loc-cli-gds for b-sert )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-gds-artic Dialog-Frame
FUNCTION get-gds-artic RETURNS CHARACTER
  (buffer loc-gds for b-sert-join )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-gds-name Dialog-Frame
FUNCTION get-gds-name RETURNS CHARACTER
  (buffer l-gds for b-sert-join )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-status Dialog-Frame
FUNCTION get-status RETURNS CHARACTER
  (buffer buf-sert for b-sert )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-hist
       MENU-ITEM m-all          LABEL "Все сертификаты"
       MENU-ITEM m-one          LABEL "Один сертификат".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cli
     LABEL "&Подключить"
     SIZE 11 BY 1 TOOLTIP "Поключение сертификатов для товара".

DEFINE BUTTON b-del
     LABEL "&Отключить"
     SIZE 10 BY 1 TOOLTIP "Отключение выбранного сертификата для товара".

DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1.

DEFINE VARIABLE v-artic AS CHARACTER FORMAT "X(16)"
     LABEL "Артикул"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE v-b-code AS INTEGER FORMAT "->>>>>>>>9" INITIAL 0
     LABEL "Бар-код"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE v-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17.88 BY 1 NO-UNDO.

DEFINE VARIABLE v-days AS INTEGER FORMAT ">>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE v-gds-name AS CHARACTER FORMAT "X(40)"
     LABEL "Название товара"
     VIEW-AS FILL-IN
     SIZE 56.63 BY 1
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE v-type AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 5.75 BY 1 NO-UNDO.

DEFINE VARIABLE r-b-sort AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 1,
"Контрагент", 2,
"Код товара", 3,
"Действ.", 4,
"Просроч.", 5,
"Истекающ.", 6
     SIZE 63.75 BY .96 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-docs FOR
      b-sert-join,
      b-sert SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-docs Dialog-Frame _FREEFORM
  QUERY br-docs NO-LOCK DISPLAY
      b-sert.cli-type COLUMN-LABEL " Тип"
      b-sert.cli-code COLUMN-LABEL " Код" format "9999999999"
      get-cli-name (buffer b-sert) COLUMN-LABEL "Контрагент" FORMAT "X(30)"
      b-sert.sert-code format "x(35)" COLUMN-LABEL  "Код сертификата"
      b-sert.first-date
      b-sert.last-date
      get-status (buffer b-sert) COLUMN-LABEL "Статус" FORMAT "X(7)"
      b-sert.PS
      get-gds-artic (buffer b-sert-join) COLUMN-LABEL "Артикул" FORMAT "X(16)"
      get-gds-name (buffer b-sert-join) COLUMN-LABEL "Наименование" FORMAT "X(25)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 18.5 ROW-HEIGHT-CHARS .75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-cli AT ROW 1 COL 11
     b-del AT ROW 1 COL 22.13
     B-print AT ROW 1 COL 32.13
     v-b-code AT ROW 1 COL 59.5 COLON-ALIGNED
     B-hist AT ROW 1 COL 78
     B-Help AT ROW 1 COL 88
     v-artic AT ROW 2.13 COL 8.25 COLON-ALIGNED
     v-gds-name AT ROW 2.13 COL 39.88 COLON-ALIGNED
     v-days AT ROW 3.25 COL 70.5 COLON-ALIGNED NO-LABEL
     v-code AT ROW 3.25 COL 72.5 COLON-ALIGNED NO-LABEL
     v-type AT ROW 3.25 COL 90.63 COLON-ALIGNED NO-LABEL
     r-b-sort AT ROW 3.29 COL 8 NO-LABEL
     br-docs AT ROW 4.75 COL 1.5
     "Фильтр:" VIEW-AS TEXT
          SIZE 7 BY 1 AT ROW 3.25 COL 1
     SPACE(90.74) SKIP(19.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Сертификаты для товара"
         CANCEL-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-docs r-b-sort Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-hist:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-hist:HANDLE.

/* SETTINGS FOR FILL-IN v-artic IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-gds-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-docs
/* Query rebuild information for BROWSE br-docs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH b-sert-join WHERE
            b-sert-join.b-code = i-b-code NO-LOCK,
    each b-sert WHERE b-sert.SERT-CODE = B-SERT-JOIN.SERT-CODE no-lock
    BY b-sert.last-date DESCENDING.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _OrdList          = "ub.b-sert.last-date|no"
     _Where[2]         = "b-sert-join.b-code = i-b-code"
     _Query            is OPENED
*/  /* BROWSE br-docs */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Сертификаты для товара */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cli Dialog-Frame
ON CHOOSE OF b-cli IN FRAME Dialog-Frame /* Подключить */
DO:
  run ref/cli-sert.w ( input parparentproc
                     , input p-curr-obj-type
                     , input p-curr-obj-code
                     , input "all":U
                     , input ?
                     , input ?
                     , input i-b-code).
  run Openbr in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Отключить */
DO:
  define variable ri as recid no-undo.
  define variable rr as recid no-undo.

  if not available b-sert-join THEN return no-apply.
  message "Отсоединить сертификат " b-sert.sert-code " от товара?"
                   view-as alert-box  warning buttons  yes-no set OK as log .
  if OK   then do:
      ri = recid( b-sert-join ).
      get prev br-docs .
      if available b-sert-join
          then   rr = recid( b-sert-join ).
          else do:
              get next br-docs.
              get next br-docs.
              rr = recid( b-sert-join ).
          end.
      find b-sert-join where recid( b-sert-join ) = ri.
      delete b-sert-join.
      run Openbr in this-procedure .
      reposition br-docs to recid rr no-error.
      apply "ENTRY":U to br-docs.
      apply "VALUE-CHANGED":U to br-docs.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  IF NOT AVAILABLE b-sert-join THEN RETURN.
  if hist-option = '':U then do:
        run gbl/pop-up.p ( input self:handle, input no) no-error.
  end.
  if hist-option = '':U then return no-apply.


  run ref/c-serts.w (
                INPut parParentProc
               ,INPUT '':U /* bttns  */
               ,INPUT 'subject' /*p-mode*/
               ,INPUT (IF hist-option = 'all' THEN '':U ELSE b-sert-join.cli-type)
               ,INPUT (IF hist-option = 'all' THEN 0 ELSE b-sert-join.cli-code)
               ,INPUT (IF hist-option = 'all' THEN '':U ELSE b-sert-join.sert-code)
               ,INPUT b-sert-join.b-code
               ,INPUT {&table_sert-join}
               ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  APPLY "entry" TO br-docs.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
define variable loc#log as logical no-undo .
if i-point = {&all} then do:
      message "Вы хотите напечатать весь список сертифицированных товаров" skip
      "Эта процедура может занять долгое время! Продолжать?" view-as alert-box
      WARNING buttons YES-NO update loc#log.
      if NOT loc#log then return no-apply.
end.
v-doc-rec = recid( b-sert-join ).
DO WHILE available b-sert-join :
      GET prev br-docs.
END.
run Print-List in this-procedure .
reposition br-docs to recid v-doc-rec no-error.
apply "entry" to br-docs in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-docs
&Scoped-define SELF-NAME br-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-docs Dialog-Frame
ON VALUE-CHANGED OF br-docs IN FRAME Dialog-Frame
DO:
        find ub.bar-code where ub.bar-code.b-code = b-sert-join.b-code no-lock no-error.
        if available ub.bar-code then do:
            find ub.goods where ub.goods.gds-code = ub.bar-code.gds-code no-lock.
            assign
                v-gds-name = ub.goods.gds-name
                v-artic = ub.goods.artic
                v-b-code = b-sert-join.b-code.
        end.
        else if i-b-code <> ? then do:
            find ub.bar-code where ub.bar-code.b-code = i-b-code no-lock no-error.
            if available ub.bar-code then do:
                find ub.goods where goods.gds-code = ub.bar-code.gds-code no-lock.
                assign
                    v-gds-name = goods.gds-name
                    v-artic = goods.artic
                    v-b-code = i-b-code.
             end.
         end.
         disp v-gds-name v-artic v-b-code with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-all Dialog-Frame
ON CHOOSE OF MENU-ITEM m-all /* Все сертификаты */
DO:

  assign
  hist-option = 'all'.
  APPLY "CHOOSE" to b-hist  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-one
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-one Dialog-Frame
ON CHOOSE OF MENU-ITEM m-one /* Один сертификат */
DO:
  assign
  hist-option = 'one'.
  APPLY "CHOOSE" to b-hist  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-b-sort
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-b-sort Dialog-Frame
ON VALUE-CHANGED OF r-b-sort IN FRAME Dialog-Frame
DO:

  assign r-b-sort.
    case r-b-sort:
    when {&r-b-sort-cli} then do:
        disable v-b-code v-days with frame {&frame-name}.
        hide v-b-code v-days .
        if i-point = "cli":U then do:
            message "Сортировка итак по одному клиенту" view-as alert-box warning.
            r-b-sort = {&r-b-sort-all}.
            disp r-b-sort with frame {&frame-name}.
            apply "VALUE-CHANGED":U to r-b-sort.
            return no-apply.
        end.
        view v-code v-type.
        enable v-code v-type with frame {&frame-name}.
        apply "entry" to v-code.
        return no-apply.
    end.
    when {&r-b-sort-b-code} then do:
        disable v-type v-code v-days with frame {&frame-name}.
        hide v-type v-code v-days .
        if i-point = "gds:U" then do:
            message "Сортировка итак по одному товару" view-as alert-box warning.
            r-b-sort = {&r-b-sort-all}.
            disp r-b-sort with frame {&frame-name}.
            apply "VALUE-CHANGED":U to r-b-sort.
        end.
        else do:
            enable v-b-code with frame {&frame-name}.
            apply "entry" to v-b-code.
            return no-apply.
        end.
    end.
    when {&r-b-sort-over} then do:
        disable v-type v-code v-b-code v-days with frame {&frame-name}.
        hide v-type v-code v-b-code.
        if i-point = "over":U then do:
            message "Сортировка итак по просроченным" view-as alert-box warning.
            r-b-sort = {&r-b-sort-all}.
            disp r-b-sort with frame {&frame-name}.
            apply "VALUE-CHANGED":U to r-b-sort.
        end.
        i-point = "over":U.
        RUN OpenBr in this-procedure .
    end.
    when {&r-b-sort-true} then do:
        disable v-type v-code v-b-code v-days with frame {&frame-name}.
        hide v-type v-code v-b-code.
        if i-point = "true":U then do:
            message "Сортировка итак по действующим" view-as alert-box warning.
            r-b-sort = {&r-b-sort-all}.
            disp r-b-sort with frame {&frame-name}.
            apply "VALUE-CHANGED":U to r-b-sort.
        end.
        i-point = "true":U.
        RUN OpenBr in this-procedure .
    end.
    when {&r-b-sort-day-off} then do:
        disable v-type v-code v-b-code with frame {&frame-name}.
        hide v-type v-code v-b-code .
        enable v-days with frame {&frame-name}.
        apply "entry" to v-days.
        return no-apply.
    end.
    otherwise do:
        disable v-code v-type v-b-code v-days with frame {&frame-name}.
        hide v-code v-type v-b-code v-days .
        i-point = "all":U.
        run Openbr in this-procedure .
     end.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-b-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-b-code Dialog-Frame
ON RETURN OF v-b-code IN FRAME Dialog-Frame /* Бар-код */
DO:
def buffer buf-b-code for ub.bar-code.
  assign
      v-b-code
      i-b-code = v-b-code
      i-point = "gds":U.
  find first buf-b-code where
             buf-b-code.b-code =  i-b-code no-lock no-error.
  if available buf-b-code then do:
      find first ub.goods where
                 ub.goods.gds-code = buf-b-code.gds-code no-lock.
      FIND FIRST ub.gds-prt WHERE
                 ub.gds-prt.upper-code = goods.prt-root NO-LOCK .
      find FIRST ub.bar-code where
                 ub.bar-code.gds-code = ub.goods.gds-code AND
                 ub.bar-code.node-code = ub.gds-prt.node-code AND
                 ub.bar-code.part-code = "" AND
                 ub.bar-code.in-code = "" AND
                 ub.bar-code.unit-cli = ub.goods.unit-base no-lock.
      i-b-code = ub.bar-code.b-code.
      run Openbr in this-procedure .
  end.
  else
    message "Нет такого товара" view-as alert-box warning.
  i-point = "ALL":U.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-code Dialog-Frame
ON RETURN OF v-code IN FRAME Dialog-Frame
DO:
  assign v-code .
  if v-code <> 0 then do:
        apply "ENTRY" to v-type.
        apply "VALUE-CHANGED":U to br-docs.
  end.
  else do:
            r-b-sort = {&r-b-sort-all}.
            disp r-b-sort with frame {&frame-name}.
            apply "VALUE-CHANGED":U to r-b-sort.
            return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-days
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-days Dialog-Frame
ON RETURN OF v-days IN FRAME Dialog-Frame
DO:
   assign
      v-days
      i-days = v-days
      i-point = "day-off":U.
      run Openbr in this-procedure .
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-type Dialog-Frame
ON RETURN OF v-type IN FRAME Dialog-Frame
DO:
  assign
  v-code v-type
  i-code = v-code
  i-type = v-type
  i-point = "cli":U.
  if can-find(first ub.clients where
                    ub.clients.obj-type = v-type and ub.clients.obj-code = v-code) then  dO:
      run Openbr in this-procedure .
  end.
  else do:
    message "Нет такого контрагента" view-as alert-box warning.
  i-point = "all":U.
  end.
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
{ gbl/brwrepos.i
&line-num=5 }
{ gbl/brwrefre.i "v-doc-rec = recid(b-sert). run openbr in this-procedure. reposition br-docs to recid(v-doc-rec). v-doc-rec = ? . " }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if i-point = "all":U then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр i-point при вызове процедуры"
    view-as alert-box ERROR
    .
    return.
  end.
  Run MyENable in this-procedure no-error.
  if error-status:error then return no-apply.
  RUN Openbr in this-procedure .
  { gbl/mv-clmn.i
  &ext-col = 21
  &frame-name = "{&frame-name}"
  &browse-name = "br-docs"
  &start-column = "{&num-locked-columns-br-list} + 1"
  &prev-order-column_1 = "'9,10,1,2,3,4,5,6,7,8'"
  &prev-order-column-condition_2 = " s-point = 'sert':U "
  &prev-order-column_2 = "'9,10,1,2,3,4,5,6,7,8'"
  &prev-order-column-condition_3 = " s-point = 'gds':U "
  &prev-order-column_3 = "'4,5,6,7,8,9,10,1,2,3'"
  &prev-order-column-condition_4 = " S-POINT = 'gds-cli':U "
  &prev-order-column_4 = "'1,2,3,4,5,6,7,8,9,10'"
  &prev-order-column-condition_5 = " S-POINT = 'true':U "
  &prev-order-column_5 = "'1,2,3,4,5,6,7,8,9,10'"
  &prev-order-column-condition_6 = " s-point = 'over':U "
  &prev-order-column_6 = "'1,2,3,4,5,6,7,8,9,10'"
  &prev-order-column-condition_1 = " s-point = 'day-off':U "
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
  DISPLAY v-b-code v-artic v-gds-name v-days v-code v-type r-b-sort
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-cli b-del B-print v-b-code B-hist B-Help v-days v-code v-type
         r-b-sort br-docs
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
define variable loc#log as logical no-undo.
define variable disablevar as integer no-undo.
b-hist:MENU-MOUSE in frame {&frame-name} = 1.
assign
s-point = i-point
s-b-code = i-b-code
s-type = i-type
s-code = i-code
i-point = "all":U
.


  DISPLAY
  v-b-code
  v-artic
  v-gds-name
  WITH FRAME Dialog-Frame.
  ENABLE
  b-exit
  b-print
  B-Help
  b-hist
 /* v-b-code */
  br-docs
  r-b-sort
  WITH FRAME Dialog-Frame.
  CASE S-point:
    when "sert":U then do:
      frame {&frame-name}:title = " Товары  сертификата " + i-sert-code.
      disablevar = {&r-b-sort-cli}.
    end.
    when "gds":U then do:
      FIND FIRST ub.goods No-LOCK WHERE
                 ub.goods.gds-code = i-b-code No-ERROR.
      if not avail goods then do:
        message
        vss-workfile vss-revision vss-description skip
        "Не найден товар  с  бар-кодом " i-b-code
        view-as alert-box error.
        return error .
      end.
      frame {&frame-name}:title = "Сертификаты для товара " + goods.artic + {&space-char} +
                                  string(ub.goods.gds-name, "X(25)").
      disablevar = {&r-b-sort-b-code}.
    end.
    when "cli":U then do:
      frame {&frame-name}:title = "Товары сертифицированные фирмой " + i-type + string(i-code).
      disablevar = {&r-b-sort-cli}.
    end.
    when "gds-cli":U then do:
      FIND FIRST goods No-LOCK WHERE
                 goods.gds-code = i-b-code No-ERROR.
      if not avail goods then do:
        message
        vss-workfile vss-revision vss-description skip
        "Не найден товар с бар-кодом " i-b-code
        view-as alert-box error.
        return error .
      end.
      disablevar = {&r-b-sort-cli}.
      assign
      loc#log = r-b-sort:disable(radio-label(string(disablevar), r-b-sort:radio-buttons)).
      disablevar = {&r-b-sort-b-code}.
    end.
    when "true":U then do:
      frame {&frame-name}:title = "Товары по действующим сертификатам".
      disablevar = {&r-b-sort-true}.
    end.
    when "over":U then do:
      frame {&frame-name}:title = "Товары по просроченным серфтификатам".
      disablevar = {&r-b-sort-over}.
    end.
    when "day-off":U then do:
      frame {&frame-name}:title = "Товары по истекающим серфтификатам".
      disablevar = {&r-b-sort-day-off}.
    end.
  END CASE.
  assign
  loc#log = r-b-sort:disable(radio-label(string(disablevar), r-b-sort:radio-buttons)) no-error.

  ENABLE
  b-del when (p-mode = {&update} or p-mode = {&add-def})
  b-cli when (p-mode = {&update} or p-mode = {&add-def}) and s-point = "gds"
  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
run cur-time in this-procedure ( output v-today, output v-time).
case i-point:
    when "all":u then do:
        CASE s-point:
          when "sert":U then
            open query br-docs
            for each b-sert-join WHERE
                     b-sert-join.sert-code = i-sert-code AND
                     b-sert-join.cli-type = i-type AND
                     b-sert-join.cli-code = i-code NO-LOCK,
                FIRST b-sert WHERE
                     b-sert.cli-type = b-sert-join.cli-type AND
                     b-sert.cli-code = b-sert-join.cli-code AND
                     b-sert.sErt-code = b-sert-join.sert-code NO-LOCK
            BY b-sert.last-date DESCENDING.
          when "gds":U then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.b-code = s-b-code or s-b-code = ?) NO-LOCK,
                FIRST b-sert WHERE
                     b-sert.cli-type = b-sert-join.cli-type AND
                     b-sert.cli-code = b-sert-join.cli-code AND
                     b-sert.sErt-code = b-sert-join.sert-code NO-LOCK
            BY b-sert.last-date DESCENDING.
         when "gds-cli":U then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.b-code = s-b-code  or s-b-code = ?) AND
                     (b-sert-join.cli-type = s-type or s-type = ? ) and
                     (b-sert-join.cli-code = s-code or s-code = ?) NO-LOCK,
                FIRST b-sert WHERE
                     b-sert.cli-type = b-sert-join.cli-type AND
                     b-sert.cli-code = b-sert-join.cli-code AND
                     b-sert.sErt-code = b-sert-join.sert-code NO-LOCK
            BY b-sert.last-date DESCENDING.
         when "cli" then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.cli-type = s-type  or s-type = ? )  and
                     (b-sert-join.cli-code = s-code  or s-code = ?) NO-LOCK,
                FIRST b-sert WHERE
                     b-sert.cli-type = b-sert-join.cli-type AND
                     b-sert.cli-code = b-sert-join.cli-code AND
                     b-sert.sErt-code = b-sert-join.sert-code NO-LOCK
            BY b-sert.last-date DESCENDING.
       END CASE.
    end.
    when "gds":u then do:
        CASE s-point:
          WHeN "sert":u then
            open query br-docs
            for each b-sert-join WHERE
                     b-sert-join.b-code = i-b-code AND
                     b-sert-join.sert-code = i-sert-code AND
                     b-sert-join.cli-type = i-type AND
                     b-sert-join.cli-code = i-code NO-LOCK,
                FIRST b-sert WHERE
                     b-sert.cli-type = b-sert-join.cli-type AND
                     b-sert.cli-code = b-sert-join.cli-code AND
                     b-sert.sErt-code = b-sert-join.sert-code NO-LOCK
            BY b-sert.last-date DESCENDING.
          WHEN "GDS":U THEN RETURN.
          WHEN "GDS-CLI":u THEN RETURN.
          WHeN "CLI":u then
            open query br-docs
            for each b-sert-join WHERE
                     b-sert-join.b-code = i-b-code AND
                     (b-sert-join.cli-type = s-type  or s-type = ? ) and
                     (b-sert-join.cli-code = s-code  or s-code = ?) NO-LOCK,
                FIRST b-sert WHERE
                     b-sert.cli-type = b-sert-join.cli-type AND
                     b-sert.cli-code = b-sert-join.cli-code AND
                     b-sert.sErt-code = b-sert-join.sert-code NO-LOCK
            BY b-sert.last-date DESCENDING.
        END CASE.
    end.
    when "gds-cli":u then do:
        CASE s-point:
          WHEN "sert":U THEN
            open query br-docs
            for each b-sert-join WHERE
                     b-sert-join.sert-code = i-sert-code  AND
                     b-sert-join.b-code = i-b-code AND
                     b-sert-join.cli-type = i-type and
                     b-sert-join.cli-code = i-code NO-LOCK,
                FIRST b-sert WHERE
                     b-sert.cli-type = b-sert-join.cli-type AND
                     b-sert.cli-code = b-sert-join.cli-code AND
                     b-sert.sErt-code = b-sert-join.sert-code NO-LOCK
            BY b-sert.last-date DESCENDING.
          WHEN "GDS-CLI":u THEN RETURN.
          WHeN "GDS":u then RETURN.
       END CASE.
    end.
    WHEN "cli":U then do:
        CASE s-point:
          when "sert":U then
            open query br-docs
            for each b-sert-join WHERE
                     b-sert-join.sert-code = i-sert-code AND
                     b-sert-join.cli-type = i-type and
                     b-sert-join.cli-code = i-code NO-LOCK,
                FIRST b-sert WHERE
                      b-sert.cli-type = b-sert-join.cli-type AND
                      b-sert.cli-code = b-sert-join.cli-code AND
                      b-sert.sert-code = b-sert-join.sert-code NO-LOCK
            BY b-sert.last-date DESCENDING.
          when "cli":U then RETURN.
          WHEN "cli-gds":U then RETURN.
          when "gds":U then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.b-code = s-b-code  or s-b-code = ?) AND
                     b-sert-join.cli-type = i-type and
                     b-sert-join.cli-code = i-code NO-LOCK,
                FIRST b-sert WHERE
                      b-sert.cli-type = b-sert-join.cli-type AND
                      b-sert.cli-code = b-sert-join.cli-code AND
                      b-sert.sert-code = b-sert-join.sert-code NO-LOCK
            BY b-sert.last-date DESCENDING.
        end case.
    END.
    WHEN "over":U then  do:
        case s-point:
          when "sert":U then do:
            open query br-docs
            for each b-sert-join WHERE
                     b-sert-join.sert-code = i-sert-code AND
                     b-sert-join.cli-type = i-type and
                     b-sert-join.cli-code = i-code NO-LOCK,
                first b-sert where
                      b-sert.cli-type = b-sert-join.cli-type AND
                      b-sert.cli-code = b-sert-join.cli-code AND
                      b-sert.sert-code = b-sert-join.sert-code and
                      B-SERT.LAST-DATE < v-TODAY NO-LOCK
            BY b-sert.last-date DESCENDING.
          end.
          when "gds":U then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.b-code = s-b-code or s-b-code = ?) NO-LOCK,
                first b-sert where
                      b-sert.cli-type = b-sert-join.cli-type AND
                      b-sert.cli-code = b-sert-join.cli-code AND
                      b-sert.sert-code = b-sert-join.sert-code and
                      B-SERT.LAST-DATE < v-TODAY NO-LOCK
            BY b-sert.last-date DESCENDING.
          when "gds-cli":U then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.cli-type = s-type  or s-type = ? ) and
                     (b-sert-join.cli-code = s-code  or s-code = ?) and
                     (b-sert-join.b-code = s-b-code  or s-b-code = ?) NO-LOCK,
                first b-sert where
                      b-sert.cli-type = b-sert-join.cli-type AND
                      b-sert.cli-code = b-sert-join.cli-code AND
                      b-sert.sert-code = b-sert-join.sert-code and
                      B-SERT.LAST-DATE < v-TODAY NO-LOCK
            BY b-sert.last-date DESCENDING.
          when "cli" then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.cli-type = s-type  or s-type = ? ) and
                     (b-sert-join.cli-code = s-code  or s-code = ?) NO-LOCK,
                first b-sert where
                      b-sert.cli-type = b-sert-join.cli-type AND
                      b-sert.cli-code = b-sert-join.cli-code AND
                      b-sert.sert-code = b-sert-join.sert-code and
                      B-SERT.LAST-DATE < v-TODAY NO-LOCK
            BY b-sert.last-date DESCENDING.
        END CASE.
    end.
    WHEN "true":U then do:
        case s-point:
          when "sert":U then
            open query br-docs
            for each b-sert-join WHERE
                     b-sert-join.sert-code = i-sert-code AND
                     b-sert-join.cli-type = i-type and
                     b-sert-join.cli-code = i-code NO-LOCK,
            first b-sert where
                  b-sert.cli-type = b-sert-join.cli-type AND
                  b-sert.cli-code = b-sert-join.cli-code AND
                  b-sert.sert-code = b-sert-join.sert-code and
                  B-SERT.LAST-DATE >= v-TODAY NO-LOCK
            BY b-sert.last-date DESCENDING.
          when "gds":U then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.b-code = s-b-code  or s-b-code = ?) NO-LOCK,
            first b-sert where
                  b-sert.cli-type = b-sert-join.cli-type AND
                  b-sert.cli-code = b-sert-join.cli-code AND
                  b-sert.sert-code = b-sert-join.sert-code and
                  B-SERT.LAST-DATE >= v-TODAY NO-LOCK
            BY b-sert.last-date DESCENDING.
          when "gds-cli":U then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.cli-type = s-type  or s-type = ? ) and
                     (b-sert-join.cli-code = s-code  or s-code = ?) and
                     (b-sert-join.b-code = s-b-code or s-b-code = ?) NO-LOCK,
            first b-sert where
                  b-sert.cli-type = b-sert-join.cli-type AND
                  b-sert.cli-code = b-sert-join.cli-code AND
                  b-sert.sert-code = b-sert-join.sert-code and
                  B-SERT.LAST-DATE >= v-TODAY NO-LOCK
            BY b-sert.last-date DESCENDING.
          when "cli":U then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.cli-type = s-type  or s-type = ? ) and
                     (b-sert-join.cli-code = s-code  or s-code = ?) NO-LOCK,
            first b-sert where
                  b-sert.cli-type = b-sert-join.cli-type AND
                  b-sert.cli-code = b-sert-join.cli-code AND
                  b-sert.sert-code = b-sert-join.sert-code and
                  B-SERT.LAST-DATE >= v-TODAY NO-LOCK
            BY b-sert.last-date DESCENDING.
        END case.
    end.
    WHEN "day-off":U then do:
        CASE s-point:
          when "sert":U then
            open query br-docs
            for each b-sert-join WHERE
                     b-sert-join.sert-code = i-sert-code AND
                     b-sert-join.cli-type = i-type and
                     b-sert-join.cli-code = i-code NO-LOCK,
            first b-sert where
                  b-sert.cli-type = b-sert-join.cli-type AND
                  b-sert.cli-code = b-sert-join.cli-code AND
                  b-sert.sert-code = b-sert-join.sert-code and
                  (B-SERT.LAST-DATE > v-TODAY AND (B-SERT.LAST-DATE - v-TODAY) <= i-days) NO-LOCK
            BY b-sert.last-date DESCENDING.
          when "gds":U then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.b-code = s-b-code  or s-b-code = ?) NO-LOCK,
            first b-sert where
                  b-sert.cli-type = b-sert-join.cli-type AND
                  b-sert.cli-code = b-sert-join.cli-code AND
                  b-sert.sert-code = b-sert-join.sert-code and
                  (B-SERT.LAST-DATE > v-TODAY AND (B-SERT.LAST-DATE - v-TODAY) <= i-days) NO-LOCK
            BY b-sert.last-date DESCENDING.
          when "gds-cli":U then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.cli-type = s-type  or s-type = ? ) and
                     (b-sert-join.cli-code = s-code  or s-code = ?) and
                     (b-sert-join.b-code = s-b-code  or s-b-code = ?) NO-LOCK,
            first b-sert where
                  b-sert.cli-type = b-sert-join.cli-type AND
                  b-sert.cli-code = b-sert-join.cli-code AND
                  b-sert.sert-code = b-sert-join.sert-code and
                  (B-SERT.LAST-DATE > v-TODAY AND (B-SERT.LAST-DATE - v-TODAY) <= i-days) NO-LOCK
            BY b-sert.last-date DESCENDING.
          when "cli":U then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.cli-type = s-type  or s-type = ? ) and
                     (b-sert-join.cli-code = s-code  or s-code = ?) NO-LOCK,
            first b-sert where
                  b-sert.cli-type = b-sert-join.cli-type AND
                  b-sert.cli-code = b-sert-join.cli-code AND
                  b-sert.sert-code = b-sert-join.sert-code and
                  (B-SERT.LAST-DATE > v-TODAY AND (B-SERT.LAST-DATE - v-TODAY) <= i-days) NO-LOCK
            BY b-sert.last-date DESCENDING.
       END CASE.
    END.
end case.
APPLY "VALUE-CHANGED" TO BR-docs in frame {&frame-name}.
APPLY "ENTRY" TO BR-docs in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Print-List Dialog-Frame
PROCEDURE Print-List :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable accum-count as integer no-undo.
define variable for-ps1 as char no-undo.
define variable for-ps2 as char no-undo.

Line = fill("-", 198).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).
PUT  STREAM prnlibstream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(177)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM prnlibstream FRAME BottomFrame .
FORM with FRAME StreamF  .
run waitfram-show in this-procedure ( input "Ждите...").
GET next br-docs.
accum-count = 0 .
DO WHILE available b-sert-join :
    Assign
    for-cli-name = get-cli-name(buffer b-sert)
    for-status = get-status(buffer b-sert)
    for-artic = get-gds-artic(buffer b-sert-join)
    for-gds-name = get-gds-name(buffer b-sert-join)
    for-ps1 = breakstr(b-sert.PS, 18, input-output for-ps1, input-output for-ps2).
    .
    DISPLAY stream prnlibstream
    b-sert.cli-type
    b-sert.cli-code
    for-cli-name
    b-sert.sert-code
    b-sert.first-date
    b-sert.last-date
    for-status
    for-ps1 @ b-sert.PS
    for-artic
    for-gds-name
    with frame SertF.
    DOWN STREAM prnlibstream 1 with FRAME SertF  .
    if for-ps2 <> "" then do:
        DISPLAY stream prnlibstream
        for-ps2 @ b-sert.PS
        with frame SertF.
        DOWN STREAM prnlibstream 1 with FRAME SertF  .

    end.
    assign
    accum-count = accum-count + 1
    .
    GET next br-docs.
END.
UNDERLINE stream prnlibstream
b-sert.cli-type
b-sert.cli-code
for-cli-name
b-sert.sert-code
b-sert.first-date
b-sert.last-date
for-status
b-sert.PS
for-artic
for-gds-name
with frame SertF.
DOWN STREAM prnlibstream 1 with FRAME SertF  .
DISPLAY stream prnlibstream
"Всего" @ for-cli-name
string(accum-count) + " записей" @ b-sert.sert-code
with frame SertF.
DOWN STREAM prnlibstream 1 with FRAME SertF  .
UNDERLINE stream prnlibstream
b-sert.cli-type
b-sert.cli-code
for-cli-name
b-sert.sert-code
b-sert.first-date
b-sert.last-date
for-status
b-sert.PS
for-artic
for-gds-name
with frame SertF.
DOWN stream prnlibstream 1 with FRAME SertF.
HIDE  STREAM prnlibstream FRAME BottomFrame .
HIDE  STREAM prnlibstream FRAME SertF.
output  STREAM prnlibstream CLOSE.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cli-name Dialog-Frame
FUNCTION get-cli-name RETURNS CHARACTER
  (buffer loc-cli-gds for b-sert ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
    define variable dop like ub.clients.obj-name.
    FIND FIRST ub.clients NO-LOCK WHERE ub.clients.obj-type = loc-cli-gds.cli-type AND
                                     ub.clients.obj-code = loc-cli-gds.cli-code
    No-ERROR.
    IF avail clients then dop = ub.clients.obj-name.
    ELSE dop = "".
  RETURN dop.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-gds-artic Dialog-Frame
FUNCTION get-gds-artic RETURNS CHARACTER
  (buffer loc-gds for b-sert-join ) :
  define buffer ga-goods for ub.goods.
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

    define variable dop like ub.goods.gds-name.
    FIND FIRST ub.bar-code NO-LOCK WHERE ub.bar-code.b-code = loc-gds.b-code
    No-ERROR.
    IF avail ub.bar-code then do:
       find first ga-goods where ga-goods.gds-code = bar-code.gds-code no-lock.
        dop = ga-goods.artic.
    end.
    ELSE dop = "".
  RETURN dop.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-gds-name Dialog-Frame
FUNCTION get-gds-name RETURNS CHARACTER
  (buffer l-gds for b-sert-join ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

    define variable dop like ub.goods.gds-name.
    FIND FIRST ub.bar-code NO-LOCK WHERE ub.bar-code.b-code = l-gds.b-code
    No-ERROR.
    IF avail ub.bar-code then do:
        find ub.goods where ub.goods.gds-code = ub.bar-code.gds-code no-lock no-error.
        dop = ub.goods.gds-name.
    end.
    ELSE dop = "".
  RETURN dop.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-status Dialog-Frame
FUNCTION get-status RETURNS CHARACTER
  (buffer buf-sert for b-sert ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
    define variable stt as char .
    run cur-time in this-procedure ( output v-today, output v-time).
    if buf-sert.first-date > v-today then stt = "Будущие".
    else do:
        if buf-sert.last-date > v-today then stt = "Действ".
        else
            stt =  "Просроч".
    end.
  RETURN stt.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME