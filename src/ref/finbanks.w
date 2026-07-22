&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER find_fin-bank FOR ub.fin-bank.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_fin-bank FOR ub.fin-bank.
DEFINE BUFFER X_sysconf FOR ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список банков

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/15/03
Author: Bakhtadze Natalya
Creation date: 10/15/03

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.

define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/

define input parameter p-mode  as char   no-undo .
define input parameter p-host-code like ub.fin-bank.host-code no-undo.

define input-output parameter p-status_ like ub.fin-bank.status_ no-undo .
/*банки в выборке*/
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список банков":U.
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/flt-def.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/fltfield.i }
{ gbl/prn-lib.i  }
{ cmp/operlist.i }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
{ gbl/fltopend.i defproc }
define variable filter-point as character no-undo init "Список банков" .
define variable filter-point0 as character no-undo init "Список банков" .
define variable filter-label as character no-undo init "finbanks" .
define variable filter-label0 as character no-undo init "finbanks" .
define variable v-rid-list as character no-undo .
define variable sort-column-name as character no-undo .
define variable print-option as character no-undo.
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
define variable v-doc-rec as recid no-undo .

/*вспомогат*/
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".

define buffer X_curr_sysconf for ub.sysconf.
define buffer pos_fin-bank for ub.fin-bank.

&scop cant-positioning   if error-status:error then do: ~
                          find first pos_fin-bank no-lock where ~
                                  recid(pos_fin-bank) = loc-doc-rec no-error . ~
                            message ~
                            "Невозможно позиционироваться на записи БАНК" skip~
                            string(if avail pos_fin-bank ~
                                    then  substitute("Код фирмы: &1, вн. код банка &2" ~
                                                    , pos_fin-bank.host-code  ~
                                                    , pos_fin-bank.code-bank) ~
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
&Scoped-define BROWSE-NAME BR-bank

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_fin-bank

/* Definitions for BROWSE BR-bank                                       */
&Scoped-define FIELDS-IN-QUERY-BR-bank ~
mark-string(recid(X_fin-bank), v-rid-list) X_fin-bank.host-code ~
X_fin-bank.code-bank X_fin-bank.bank-name X_fin-bank.bik X_fin-bank.status_
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-bank X_fin-bank.bik
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-bank X_fin-bank
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-bank X_fin-bank
&Scoped-define QUERY-STRING-BR-bank FOR EACH X_fin-bank NO-LOCK
&Scoped-define OPEN-QUERY-BR-bank OPEN QUERY BR-bank FOR EACH X_fin-bank NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-bank X_fin-bank
&Scoped-define FIRST-TABLE-IN-QUERY-BR-bank X_fin-bank


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-add B-lookup B-chg ~
B-del b-collect B-print B-hist B-sch B-Help B-schet B-copy RS-status_ ~
BR-bank ED-notes sch-code sch-BIK sch-name mark-num
&Scoped-Define DISPLAYED-OBJECTS RS-status_ ED-notes sch-code sch-BIK ~
sch-name mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-print
       MENU-ITEM m_one          LABEL "Один"
       MENU-ITEM m_list         LABEL "Список"        .


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-collect
     LABEL "Инкасс."
     SIZE 10 BY 1 TOOLTIP "Счет для инкассации".

DEFINE BUTTON B-copy
     LABEL "&Копия"
     SIZE 10 BY 1 TOOLTIP "Скопировать в другие фирмы".

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
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

DEFINE BUTTON B-schet
     LABEL "&Счета"
     SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE ED-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sch-BIK AS CHARACTER FORMAT "X(9)":U
     LABEL "БИК"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-code AS INTEGER FORMAT ">>>>>>9":U INITIAL 0
     LABEL "коду"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-name AS CHARACTER FORMAT "X(35)":U
     LABEL "нач.назван"
     VIEW-AS FILL-IN
     SIZE 41.88 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE RS-status_ AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 33.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-bank FOR
      X_fin-bank SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-bank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-bank Dialog-Frame _STRUCTURED
  QUERY BR-bank DISPLAY
      mark-string(recid(X_fin-bank), v-rid-list) FORMAT "X(1)":U
            WIDTH 1
      X_fin-bank.host-code COLUMN-LABEL "Код!фирмы" FORMAT ">>>>>9999999999":U
      X_fin-bank.code-bank COLUMN-LABEL "Код!банка" FORMAT "999999999":U
      X_fin-bank.bank-name COLUMN-LABEL "Наименование банка" FORMAT "X(60)":U
      X_fin-bank.bik FORMAT "X(9)":U
      X_fin-bank.status_ FORMAT "X(8)":U
  ENABLE
      X_fin-bank.bik
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 14.38.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     B-add AT ROW 1 COL 31
     B-lookup AT ROW 1 COL 41
     B-chg AT ROW 1 COL 51
     B-del AT ROW 1 COL 61
     b-collect AT ROW 1 COL 71 WIDGET-ID 2
     B-print AT ROW 1 COL 86
     B-hist AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     B-schet AT ROW 2 COL 51
     B-copy AT ROW 2 COL 61
     RS-status_ AT ROW 3 COL 1.5 NO-LABEL
     BR-bank AT ROW 4.21 COL 1.38
     ED-notes AT ROW 18.67 COL 1 NO-LABEL
     sch-code AT ROW 20.79 COL 34 COLON-ALIGNED
     sch-BIK AT ROW 20.83 COL 14.88 COLON-ALIGNED
     sch-name AT ROW 20.83 COL 54 COLON-ALIGNED
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 9.25 BY 1 AT ROW 20.79 COL 1.5
          FGCOLOR 4
     SPACE(88.49) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список банков"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: find_fin-bank B "?" NO-UNDO ub fin-bank
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_fin-bank B "?" ? ub fin-bank
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-bank RS-status_ Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-print:HANDLE.

ASSIGN
       BR-bank:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-bank
/* Query rebuild information for BROWSE BR-bank
     _TblList          = "ub.X_fin-bank"
     _FldNameList[1]   > "_<CALC>"
"mark-string(recid(X_fin-bank), v-rid-list)" ? "X(1)" ? ? ? ? ? ? ? no ? no no "1" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.X_fin-bank.host-code
"X_fin-bank.host-code" "Код!фирмы" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > Temp-Tables.X_fin-bank.code-bank
"X_fin-bank.code-bank" "Код!банка" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > Temp-Tables.X_fin-bank.bank-name
"X_fin-bank.bank-name" "Наименование банка" "X(60)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > Temp-Tables.X_fin-bank.bik
"X_fin-bank.bik" ? ? "character" ? ? ? ? ? ? yes ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   = Temp-Tables.X_fin-bank.status_
     _Query            is NOT OPENED
*/  /* BROWSE BR-bank */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Список банков */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-bank-accounts_add-def':U
  {&cntxt-firm}
  p-curr-host-code
  '':U
  0
  0
  0
  0
  true
  loc#log
}

if not loc#log then return no-apply.
run ref/finbanki.w
              (
                 input parParentProc
                ,input p-curr-host-code /*p-host-code*/
                ,input {&add-def}
                ,input p-curr-host-code
                ,input 0 /*p-code-bank*/
                ,input-output loc-doc-rec
                            )
.
if loc-doc-rec <> ? then do:
  RUn OpenBR in this-procedure ( input yes, input no, Input "").
  reposition br-bank to recid loc-doc-rec no-error.
  {&cant-positioning}
end.
apply "entry" to br-bank in frame {&frame-name}.
apply "value-changed" to br-bank in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .

if not available X_fin-bank then return no-apply.

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-bank-accounts_update':U
  {&cntxt-firm}
  p-curr-host-code
  '':U
  0
  0
  0
  0
  true
  loc#log
}
if not loc#log then return no-apply.
assign
loc-doc-rec = recid(X_fin-bank).
run ref/finbanki.w
              (
                 input parParentProc
                ,input p-curr-host-code
                ,input {&update}
                ,input X_fin-bank.host-code
                ,input X_fin-bank.code-bank
                ,input-output loc-doc-rec
                            )
.
if loc-doc-rec <> ? then do:
  RUn OpenBR in this-procedure ( input yes, input no, input "").
  reposition br-bank to recid loc-doc-rec no-error.
  {&cant-positioning}
end.
apply "entry" to br-bank in frame {&frame-name}.
apply "value-changed" to br-bank in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-collect
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-collect Dialog-Frame
ON CHOOSE OF b-collect IN FRAME Dialog-Frame /* Инкасс. */
DO:
  IF AVAILABLE X_fin-bank
  THEN DO:
     run ref/bankcola.w ( INPUT parparentproc
                        , INPUT X_fin-bank.host-code
                        , INPUT X_fin-bank.code-bank
                        ) NO-ERROR.
     IF ERROR-STATUS:ERROR
     THEN DO:
         message
            vss-workfile vss-revision vss-description skip
            "Ошибка при создании счета для инкассации" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
         return no-apply.
     END.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-copy Dialog-Frame
ON CHOOSE OF B-copy IN FRAME Dialog-Frame /* Копия */
DO:
  run proc-copy in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  run proc-b-del in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
define variable loc-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo.
  if NOT available X_fin-bank then do:
    message
    "Неправильно выбран банк."
    view-as alert-box ERROR.
    return no-apply.
  end.
  loc-doc-rec = recid (X_fin-bank).
  .
  run ref/fincbnks.w
                (
                 input parParentProc
                ,input p-curr-host-code
                ,input "":U /*bttns*/
                ,input "one":U
                ,input X_fin-bank.host-code
                ,input X_fin-bank.code-bank
                ,input-output v-rid-list
                              )



  .
  reposition br-bank to recid loc-doc-rec no-error.
  apply "entry" to br-bank in frame {&frame-name}.
  apply "value-changed" to br-bank in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
define variable loc-doc-rec as recid no-undo .
  if NOT available X_fin-bank then do:
    message
    "Неправильно выбран банк."
    view-as alert-box ERROR.
    return no-apply.
  end.
  loc-doc-rec = recid (X_fin-bank).
  .
  run ref/finbanki.w
                (
                 input parParentProc
                ,input p-curr-host-code
                ,input {&lookup}
                ,input X_fin-bank.host-code
                ,input X_fin-bank.code-bank
                ,input-output loc-doc-rec
                              )
  .
  reposition br-bank to recid loc-doc-rec no-error.
  apply "entry" to br-bank in frame {&frame-name}.
  apply "value-changed" to br-bank in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable loc#log as logical no-undo .
  if available X_fin-bank then do:
    { gbl/markstrn.i X_fin-bank v-rid-list }
    loc#log = br-bank:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-bank:select-next-row ().
        apply "VALUE-CHANGED" to br-bank in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-bank in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  if not avail X_fin-bank then return no-apply.
  if print-option = '':U then do:
        run gbl/pop-up.p (self:handle, no) no-error.
  end.
  if print-option = '':U then return no-apply.
  run proc-b-print in this-procedure (input print-option) no-error.
  if error-status:error then do:
    print-option = '':U.
    return no-apply.
  end.
  APPLY "ENTRY" to br-bank.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
    run gbl/markqwa.p (
                 input b-mark:sensitive
               , input v-rid-list) no-error.
  if error-status:error then return no-apply.

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


&Scoped-define SELF-NAME B-schet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-schet Dialog-Frame
ON CHOOSE OF B-schet IN FRAME Dialog-Frame /* Счета */
DO:
define variable v-rid-list as character no-undo.
define variable v-status_ like ub.fin-schet.status_ no-undo init {&all}.
if not available X_fin-bank then return no-apply.
  run ref/finschts.w (
                                INPUT      parParentProc
                                ,p-curr-host-code
                                ,"b-add"
                                ,"bank":U /*p-mode*/
                                ,input "":U /* p-cli-type */
                                ,input 0 /*p-cli-code */
                                ,input ? /* p-curr-code */
                                ,input X_fin-bank.host-code
                                ,input X_fin-bank.code-bank
                                ,input-output v-status_
                                ,input-output v-rid-list
                                ) no-error.
if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if ( available X_fin-bank ) then do:
    if ( v-rid-list = "" ) or b-mark:sensitive = no then
    v-rid-list = string( recid( X_fin-bank ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-bank
&Scoped-define SELF-NAME BR-bank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-bank Dialog-Frame
ON RETURN OF BR-bank IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF Br-bank IN FRAME Dialog-Frame
DO:
  run proc-br-bank no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-bank Dialog-Frame
ON VALUE-CHANGED OF BR-bank IN FRAME Dialog-Frame
DO:
     DEFINE VARIABLE dops as character no-undo .
  dops = if available X_fin-bank then X_fin-bank.ps else '':U.
  ED-notes:screen-value = dops.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ED-notes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ED-notes Dialog-Frame
ON LEAVE OF ED-notes IN FRAME Dialog-Frame
DO:
  define buffer ps_fin-bank for ub.fin-bank.
  if not available X_fin-bank then return no-apply.
   DO on stop undo, return no-apply:
      FIND PS_fin-bank where
           recid (ps_fin-bank) = recid(X_fin-bank) exclusive.
      if ps_fin-bank.PS <> input frame {&frame-name} ed-notes then
      assign
      ps_fin-bank.PS = input frame {&frame-name} ed-notes
      .
   END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_list Dialog-Frame
ON CHOOSE OF MENU-ITEM m_list /* Список */
DO:
   assign
  print-option = 'LIST':U.
  APPLY "CHOOSE" to b-print  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_one
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_one Dialog-Frame
ON CHOOSE OF MENU-ITEM m_one /* Один */
DO:
   assign
  print-option = 'ONE':U.
  APPLY "CHOOSE" to b-print  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-status_
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-status_ Dialog-Frame
ON VALUE-CHANGED OF RS-status_ IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-status_
  p-status_ = rs-status_
  .
  RUN openbr IN THIS-PROCEDURE ( input YES, input NO, input "":U) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-BIK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-BIK Dialog-Frame
ON CTRL-J OF sch-BIK IN FRAME Dialog-Frame /* БИК */
DO:
  run proc-find-bik in this-procedure(yes, input frame {&frame-name} sch-bik) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-BIK Dialog-Frame
ON RETURN OF sch-BIK IN FRAME Dialog-Frame /* БИК */
DO:
  run proc-find-bik in this-procedure(no, input frame {&frame-name} sch-bik) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON CTRL-J OF sch-code IN FRAME Dialog-Frame /* коду */
DO:
  run proc-find-code in this-procedure(yes, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON RETURN OF sch-code IN FRAME Dialog-Frame /* коду */
DO:
  run proc-find-code in this-procedure(no, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-name Dialog-Frame
ON CTRL-J OF sch-name IN FRAME Dialog-Frame /* нач.назван */
DO:
  run proc-find-name in this-procedure(yes, input frame {&frame-name} sch-name) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-name Dialog-Frame
ON RETURN OF sch-name IN FRAME Dialog-Frame /* нач.назван */
DO:
  run proc-find-name in this-procedure(no, input frame {&frame-name} sch-name) no-error.
  if error-status:error then return no-apply.
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

{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_fin-bank.bank-name"
  &sort-clmn_2    = "X_fin-bank.bik"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input '')."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '')."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/brwrefre.i "v-doc-rec = recid(X_fin-bank). run OpenBr in this-procedure ( input yes, input no, input '':U). reposition br-bank to recid v-doc-rec no-error. v-doc-rec = ?. " }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

 if p-mode <> {&all} and p-mode <> {&company} then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return.
 end.
find first X_curr_sysconf no-lock where
                X_curr_sysconf.host-code = p-curr-host-code no-error.
if not available X_curr_sysconf then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверное значение параметра вызова p-curr-host-code"
  p-curr-host-code
  view-as alert-box ERROR.
  return.
end.
 if p-mode = {&company} then do:
  find first X_clients no-lock where
                X_clients.obj-type = {&cmp}
            and X_clients.obj-code = p-host-code no-error.
    if not available X_clients then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-host-code"
        p-mode p-host-code
        view-as alert-box ERROR.
        return.
    end.
    find first X_sysconf no-lock where
                    X_sysconf.host-code = p-host-code no-error.
    if not available X_sysconf then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова p-host-code"
      p-host-code
      view-as alert-box ERROR.
      return.
    end.
  end.
  v-rid-list = p-rid-list.
  if v-rid-list <> "" then do:
      FIND FIRST find_fin-bank No-LOCK where
                 recid(find_fin-bank) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_fin-bank then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова v-rid-list" v-rid-list
        view-as alert-box error .
        return error.
      end.
      v-doc-rec = integer(entry(1, v-rid-list)).
    end.
  { gbl/curdbnum.i v-db-num }
  RUN MyEnable.
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if v-rid-list <> "":U then
  REPOSITION br-bank to recid integer(entry(1, v-rid-list)) No-ERROR.
  { gbl/mv-clmn.i
    &browse-name = "br-bank"
    &frame-name = "{&frame-name}"
    &ext-col = 6
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6'"
    &prev-order-column-condition_1 = " p-mode = {&all} "
    &prev-order-column_2 = "'1,3,4,5,6,2'"
    &prev-order-column-condition_2 = " p-mode = {&company} "
    }

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
  DISPLAY RS-status_ ED-notes sch-code sch-BIK sch-name mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-add B-lookup B-chg B-del b-collect B-print
         B-hist B-sch B-Help B-schet B-copy RS-status_ BR-bank ED-notes
         sch-code sch-BIK sch-name mark-num
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

ASSIGN
b-print:MENU-MOUSE in frame {&frame-name} = 1
br-bank:num-locked-columns = 1
X_fin-bank.bik:read-only in browse br-bank = yes
rs-status_:RADIO-BUTTONS IN FRAME {&FRAME-NAME}
                       = "Текущие&+" + {&comma-char} +  {&current-status} + {&comma-char} +
                       "Все&!" + {&comma-char} + {&all} + {&comma-char} +
                        "Удаленные&-" + {&comma-char} + {&deleted-status}
rs-status_ = p-status_
.
  DISPLAY
  ED-notes
  sch-code
  sch-BIK
  sch-name
  mark-num
  WITH FRAME Dialog-Frame.
  ENABLE
  b-quit
  B-mark when lookup("b-mark":U, bttns) > 0
  b-sel when lookup("b-sel":U, bttns) > 0
  B-add when (p-mode = {&company}
             AND X_sysconf.firm-db-num = v-db-num
             AND lookup("b-add":U, bttns) > 0 and not transaction
              )
   b-copy when    (p-mode = {&company}
             AND X_sysconf.firm-db-num = v-db-num
             AND lookup("b-copy":U, bttns) > 0  and not transaction
              )
  B-lookup

  B-chg when (p-mode = {&company}
              AND X_sysconf.firm-db-num = v-db-num
              AND lookup("b-add":U, bttns) > 0  and not transaction
              )
  B-del when (p-mode = {&company}
              AND X_sysconf.firm-db-num = v-db-num
              AND lookup("b-add":U, bttns) > 0  and not transaction
              )
  b-collect
  B-sch
  B-print
  B-schet
  B-Help
  b-hist
  BR-bank
  ED-notes
  sch-code
  sch-BIK
  sch-name
  mark-num
  RS-status_
  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.

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
title0 = "Список банков" + {&space-char}.
run waitfram-show in this-procedure ("Ждите...").
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

&scop flt-open-open-query OPEN QUERY br-bank FOR EACH X_fin-bank

&scop flt-open-dyn_open-query FOR EACH X_fin-bank

&scop flt-open-query-handle QUERY br-bank:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_fin-bank

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_fin-bank

&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .


  CASE p-mode :
    WHEN {&all}        THEN DO:
     assign
     filter-point = filter-point0 + p-mode
     filter-label = substitute("&1", filter-label0)
     .
     if p-open-query then do:
       assign
       frame {&frame-name}:TITLE = title0 +
                                  {&space-char}  + (if p-status_ = {&all} then "":U else p-status_)
       .
     end.
     IF p-status_ = {&all} THEN DO:
         { gbl/fltopend.i
            &where-cond = " TRUE "
            &use-ind    = "  "
            &by         = "  " }

     END.
     ELSE DO:
       { gbl/fltopend.i
       &where-cond = " X_fin-bank.status_ = p-status_ "
       &dyn_where-cond = " substitute('X_fin-bank.status_ = &1&2&1', ~{&double-quote~}, p-status_) "
       &use-ind    = "  "
       &by         = "  " }

     END.
    END.
    WHEN {&company} THEN DO:
      ASSIGN
      filter-point = filter-point0 + p-mode
      filter-label = substitute("&1 Одна фирма", filter-label0)
      .
      if p-open-query then do:
        assign
        frame {&frame-name}:TITLE = title0 +
                                      substitute(" Фирма: (&1) &2",
                                      p-curr-host-code, X_clients.obj-name) +
                                      {&space-char}  + (if p-status_ = {&all} then "":U else p-status_)
                                      .
      end.
      IF p-status_ = {&all}  THEN DO:
           { gbl/fltopend.i
             &where-cond = " ~
               X_fin-bank.host-code  = p-curr-host-code    ~
                           "
             &dyn_where-cond = " substitute(' X_fin-bank.host-code  = &1', p-curr-host-code )"

             &use-ind    = "  "
             &by         = "  " }

       END.
       ELSE DO:
           { gbl/fltopend.i
          &where-cond = " ~
            X_fin-bank.host-code  = p-curr-host-code  ~
            AND X_fin-bank.status_ = p-status_ "
          &dyn_where-cond = " substitute( 'X_fin-bank.host-code  = &1  ~
            AND X_fin-bank.status_ = &2&3&2', p-curr-host-code, ~{&double-quote~}, p-status_ )"

          &use-ind    = "  "
          &by         = "  " }

       END.
    END.
END CASE.
IF p-status_ <> {&all}  THEN DO:
    ASSIGN
    frame {&frame-name}:TITLE = (frame {&frame-name}:TITLE + {&space-char}  + p-status_).

END.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-bank to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-bank:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-bank in frame {&frame-name}.
APPLY "ENTRY" TO br-bank.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable loc#log as logical no-undo.
define variable v-status_ like ub.fin-bank.status_ no-undo .
define variable loc-doc-rec as recid no-undo .
if not available X_fin-bank then return error.

do
on error undo, return error
on stop undo, return error

:

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-bank-accounts_deletion':U
  {&cntxt-firm}
  p-curr-host-code
  '':U
  0
  0
  0
  0
  true
  loc#log
}
if not loc#log then return error.
  assign
  v-status_ = "":U
  loc-doc-rec = recid(X_fin-bank)
  .
  run ref/finbank2.p (
                  input recid(X_fin-bank)
                  ,input-output v-status_
                 ) no-error .
  if error-status:error then undo, return error.
  if v-status_ <> p-status_ then do:
    RUn OpenBR in this-procedure ( input yes, input no, input no).
    reposition br-bank to recid loc-doc-rec no-error.
    {&cant-positioning}
  end.
  else do:
    display
    X_fin-bank.status_
    with browse br-bank.
  end.
end.

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
DEFINE INPUT PARAMETER loc-option as character no-undo.
if loc-option = '':U then return error.
CASE loc-option:
when 'ONE':U then do:
  run proc-print-one in this-procedure .
end.
when 'LIST':U then do:
  run proc-print-list no-error.
end.
end case.
loc-option = ''.
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
  tbl = 'fin-bank'
  join-tbl = 'X_fin-bank'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('code-bank', 'Код банка', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', 'Код фирмы', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('bank-name', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('bank-city', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cl-bank', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('bik', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('addres', 'Адрес юридический', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('addres1', 'Адрес почтовый', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cor-acc', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('e-mail', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fax', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('inn', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('kpp', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('licenz', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('okato', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('okonx', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('okpo', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('otdel', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('phone', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('PS', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('short-name', 'Краткое название', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                   , INPUT (filter-point + {&delim-par} + filter-label)
                   , INPUT tbl
                   , INPUT join-tbl
                   , INPUT fld
                   , INPUT lab
                   , INPUT spr
                   , INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-bank Dialog-Frame
PROCEDURE proc-br-bank :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  { ref/brwsretr.i }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-copy Dialog-Frame
PROCEDURE proc-copy :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable p-fin-code as integer no-undo .
define variable p-out-host-code like ub.sysconf.host-code no-undo.
define variable firm-rid-list as char no-undo.
define variable p-ok as logical no-undo .
define variable ii as integer no-undo .
define variable Jj as integer no-undo .
define variable kk as integer no-undo .
define variable p-ret as logical no-undo .
define variable glog as logical no-undo.
define variable v-out-host-code like ub.sysconf.host-code no-undo .
define variable v-recid-schet as recid no-undo.
define variable v-recid-bank as recid no-undo.
define variable v-new-rid-list as character no-undo .
define variable v-final-rid-list as character no-undo .
define variable v-stay-doc-rec as recid no-undo.
define buffer buf_sysconf  for ub.sysconf.
define buffer buf_fin-bank for ub.fin-bank.
define buffer buf2_fin-bank for ub.fin-bank.

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-bank-accounts_add-copy':U
  {&cntxt-firm}
  p-host-code
  '':U
  0
  0
  0
  0
  true
  glog
}
if not glog then  return .
assign
v-stay-doc-rec = recid(X_fin-bank)
.
if num-entries(v-rid-list) = 0 then do:
  message
  "Не отмечены записи для копирования !!!"
  view-as alert-box error.
  return error.
end.
run adm/sconfs.w (
               input parparentproc
             , input "b-mark,b-sel":U
             , input no
             , input p-curr-host-code
             , output v-out-host-code
             , input-output firm-rid-list) .
if num-entries(firm-rid-list) = 0 then do:
 message "Не выбрана фирмы для копирования !!!" .
 return error.
end.


message
"Вы отметили " num-entries(firm-rid-list) " фирмы. " skip
"Скопировать выбранные банки в эти фирмы ?"
view-as alert-box question
buttons yes-no
update p-ok.

kk = 0.
if p-ok = false then return.
_ii:
repeat ii = 1 to num-entries(firm-rid-list) :
  find first buf_sysconf no-lock where
            recid(buf_sysconf) = integer(entry(ii, firm-rid-list)) no-error .
  if not available buf_sysconf then next _ii.
  if buf_sysconf.host-code = p-host-code then do:
    message
    "Нельзя скопировать банки в свою собственную фирму" buf_sysconf.host-code
    view-as alert-box error .
    next _ii.
  end.
  /* список recid справочника */
   /*проверим что sysconf той же базы*/
  if buf_sysconf.firm-db-num <> X_sysconf.firm-db-num then do:
    message
    "Нельзя скопировать банки на фирму" buf_sysconf.host-code  skip
    "Текущая БД " v-db-num "Главная БД данной фирмы" buf_sysconf.firm-db-num
    view-as alert-box error .
    next _ii.
  end.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-bank-accounts_add-copy':U
    {&cntxt-firm}
    buf_sysconf.host-code
    '':U
    0
    0
    0
    0
    false
    glog
  }

  if not glog then do:
    message
    "Нельзя скопировать банки на фирму" buf_sysconf.host-code  skip
    "У Вас нет прав на добавление банков и банковских счетов в фирме" buf_sysconf.host-code
    view-as alert-box error .
    next _ii.
  end.
  _rr:
  repeat jj = 1 to num-entries(v-rid-list) :
    for each buf_fin-bank where
          recid(buf_fin-bank) =  integer(entry(jj, v-rid-list)):
      if buf_fin-bank.status_ = {&deleted-status} then do:
        message
        "Нельзя скопировать банк" buf_fin-bank.code-bank "на фирму" buf_sysconf.host-code  skip
        "Банк имеет статус" {&deleted-status} "в фирме" p-host-code
        view-as alert-box error .
        assign
        v-new-rid-list = v-new-rid-list + (if v-new-rid-list = "":U then "":U else {&comma-char}) + entry(jj, v-rid-list)
        .
        next _rr.
      end.
      /* найдем есть ли такой банк для счета в фирме куда копируем*/
      find first buf2_fin-bank no-lock where
                buf2_fin-bank.host-code = buf_sysconf.host-code
            AND buf2_fin-bank.bik = buf_fin-bank.bik
            AND buf2_fin-bank.cor-acc = buf_fin-bank.cor-acc no-error .
      if not available buf2_fin-bank then do:
        assign
        v-recid-bank = ?.
        /*скопируем банк*/
        run ref/finbank1.p (
        input-output v-recid-bank
        ,input {&add-def}
        ,input no
        ,input "bik" /*p-verify*/
        ,input "":U
        ,input buf_sysconf.host-code
        ,input 0
        ,input buf_fin-bank.addres
		,input buf_fin-bank.bank-city
        ,input buf_fin-bank.addres1
        ,input buf_fin-bank.bank-name
        ,input buf_fin-bank.bik
        ,input buf_fin-bank.cor-acc
        ,input buf_fin-bank.e-mail
        ,input buf_fin-bank.fax
        ,input buf_fin-bank.inn
        ,input buf_fin-bank.kpp
        ,input buf_fin-bank.licenz
        ,input buf_fin-bank.okato
        ,input buf_fin-bank.okonx
        ,input buf_fin-bank.okpo
        ,input buf_fin-bank.otdel
        ,input buf_fin-bank.phone
        ,input (substitute("@Копирование с фирмы &1@ &2", p-host-code, buf_fin-bank.PS))
        ,input buf_fin-bank.rkc
        ,input buf_fin-bank.short-name
        ,input buf_fin-bank.cl-bank
        )
        no-error.
        if error-status:error then do:
          assign
          v-new-rid-list = v-new-rid-list + (if v-new-rid-list = "":U then "":U else {&comma-char}) + entry(jj, v-rid-list)
          .
          next _rr.
        end.
        find first buf2_fin-bank no-lock where
                  recid(buf2_fin-bank) = v-recid-bank no-error.
        if available buf2_fin-bank then do:
          assign
          kk = kk + 1
          .
        end.
      end.
    end. /*for each fin-bank*/
  end. /*repeat jj*/
  assign
  v-final-rid-list = cross-list(v-rid-list, v-new-rid-list, {&comma-char})
  .
end. /*repeat ii*/
v-rid-list = v-final-rid-list.
run OpenBr in this-procedure ( input yes, input no, input '':U).
reposition br-bank to recid v-stay-doc-rec no-error.
message
"Скопировано " kk  "записей" view-as alert-box .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-bik Dialog-Frame
PROCEDURE proc-find-bik :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-bik like ub.fin-bank.bik no-undo.
display
"0":U @ sch-code
"":U @ sch-name
with frame {&frame-name}.
assign
p-bik = replace(p-bik, {&double-quote}, "":U)
p-bik = replace(p-bik, {&single-quote}, {&single-quote} + {&single-quote})
p-bik = {&double-quote} + p-bik + {&double-quote}.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_fin-bank.bik   begins &1 "
      , p-bik)
    ).
apply "entry":u to sch-bik in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-code Dialog-Frame
PROCEDURE proc-find-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-code-bank like ub.fin-bank.code-bank no-undo.
define variable v-code-bank as character no-undo.
display
"":U @ sch-BIK
"":U @ sch-name
with frame {&frame-name}.
assign
v-code-bank = string(p-code-bank).
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_fin-bank.code-bank = &1 "
      , v-code-bank)
    ).
apply "entry":u to sch-code in frame {&frame-name} .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-name Dialog-Frame
PROCEDURE proc-find-name :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-name as character no-undo.
display
"0":U @ sch-code
"":U @ sch-bik
with frame {&frame-name}.
assign
p-name = replace(p-name, {&double-quote}, {&double-quote} + {&double-quote})
p-name = replace(p-name, {&single-quote}, {&single-quote} + {&single-quote})
p-name = {&double-quote} + p-name + {&double-quote}.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_fin-bank.bank-name begins &1 "
      , p-name)
    ).
apply "entry":u to sch-name in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-print-list Dialog-Frame
PROCEDURE proc-print-list :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-doc-rec as recid no-undo .
define variable accum-count as integer.
define variable date_string     as      char    no-undo.
define variable Line            as      char    no-undo.

DEFINE FRAME fin-bank-list
X_fin-bank.host-code COLUMN-LABEL "Код!фирмы"  format ">>>>>>>>>>9"
X_fin-bank.code-bank COLUMN-LABEL "Код банка"  format ">>>>>>>>>>9"
X_fin-bank.bank-name format "X(160)"
X_fin-bank.status_
X_fin-bank.BIK
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

FORM with FRAME fin-bank-list  .
run waitfram-show in this-procedure ("Ждите...").
v-doc-rec = recid(X_fin-bank).
DO WHILE available X_fin-bank :
  GET prev br-bank.
END.
GET next br-bank.
DO WHILE available X_fin-bank :
  Display STREAM PrnLibStream
  X_fin-bank.host-code
  X_fin-bank.code-bank
  X_fin-bank.bank-name
  X_fin-bank.status_
  X_fin-bank.BIK
  with FRAME fin-bank-list .
  DOWN STREAM PrnLibStream 1
  with FRAME fin-bank-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-bank.
END.
UNDERLINE  STREAM PrnLibStream
X_fin-bank.host-code
X_fin-bank.code-bank
X_fin-bank.bank-name
X_fin-bank.status_
X_fin-bank.BIK
with FRAME fin-bank-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ X_fin-bank.host-code
accum-count @ X_fin-bank.code-bank
with frame fin-bank-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME fin-bank-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-bank to recid v-doc-rec no-error.
APPLY "entry" to br-bank.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-print-one Dialog-Frame
PROCEDURE proc-print-one :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if not available X_fin-bank then return error.
run ref/finbankp.p (
                 INPUT parParentProc
                 ,input X_fin-bank.host-code
                 ,input X_fin-bank.code-bank
              ) no-error.
if error-status:error then do:
  return error.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
