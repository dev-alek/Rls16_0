&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
define temp-table temp-cd-grp no-undo like cd-grp
field name as character
field lft as integer
field rgt as integer
index pi is primary unique
grp-code
index lft
lft
index rgt
rgt
.

DEFINE BUFFER find_cd-grp FOR ub.cd-grp.
DEFINE BUFFER locked_cash-desk FOR ub.cash-desk.
DEFINE BUFFER X_cd-grp FOR temp-cd-grp.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_fbr-gds-grp FOR ub.fbr-gds-grp.
DEFINE BUFFER X_upper-fbr-gds-grp FOR ub.fbr-gds-grp.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Группы товаров на кассе R-KEEPER

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/18/05
Author: Bakhtadze Natalya
Creation date: 02/18/05

*/

/*------------------------------------------------------------------------*/
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
/*"Г" "Н" - название  вышестоящая группа - передается в виде
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
define variable vss-description as character no-undo init "Группы товаров на кассе R-KEEPER".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/waitfram.i }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/fltfield.i }
{ gbl/prn-lib.i }
{ str/libbcrcn.i      }
{ ref/fbrglib.i }
{ str/r-keepth.i }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
{ gbl/fltopend.i defproc }

define variable filter-label as character no-undo init "Справочник групп блюд на кассе R-KEEPER" .
define variable filter-label0 as character no-undo init "Справочник групп блюд на кассе R-KEEPER" .
define variable filter-point0 as character no-undo init "rkep-grp" .
define variable filter-point as character no-undo init "rkep-grp" .
define variable sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
define variable v-mode as character no-undo .
define variable v-status as character no-undo .
DEFINE VARIABLE v-id as character no-undo .
DEFINE VARIABLE v-fgrp-name as character no-undo .
DEFINE VARIABLE v-tab-order as character no-undo .
DEFINE VARIABLE v-name AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-parent AS LOGICAL NO-UNDO.
define variable v-rid-list as character no-undo .

  define variable i as integer no-undo.
  define variable v-count as integer no-undo.
  define variable v-parent-id as integer no-undo.
  define variable v-parent-right as integer no-undo.
  define variable v-current-left as integer no-undo.
  define variable v-current-lenth as integer no-undo.
  define buffer t_temp-cd-grp for temp-cd-grp.
  define buffer tc_temp-cd-grp for temp-cd-grp.

define buffer pos_cd-grp for ub.cd-grp.


&scop cant-positioning   if error-status:error then do: ~
                          find first pos_cd-grp no-lock where ~
                                  recid(pos_cd-grp) = loc-doc-rec no-error . ~
                            message ~
                            "Невозможно позиционироваться на записи ГРУППЫ БЛЮДА" skip~
                            string(if avail pos_cd-grp~
                                    then  substitute("Идентификатор: &1, название &2" ~
                                                    , pos_cd-grp.grp-code  ~
                                                    , pos_cd-grp.grp-name) ~
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
&Scoped-define BROWSE-NAME BR-rkep-grp

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_cd-grp X_fbr-gds-grp X_upper-fbr-gds-grp

/* Definitions for BROWSE BR-rkep-grp                                   */
&Scoped-define FIELDS-IN-QUERY-BR-rkep-grp mark-string( recid(X_cd-grp), v-rid-list) X_cd-grp.grp-code X_cd-grp.name get-gparent-diff(BUFFER X_fbr-gds-grp) @ v-parent get-gname-diff(BUFFER X_fbr-gds-grp) @ v-name X_fbr-gds-grp.node-name X_cd-grp.upper-grp-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-rkep-grp X_cd-grp.NAME
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-rkep-grp X_cd-grp
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-rkep-grp X_cd-grp
&Scoped-define SELF-NAME BR-rkep-grp
&Scoped-define QUERY-STRING-BR-rkep-grp FOR EACH X_cd-grp NO-LOCK, ~
                                   FIRST X_fbr-gds-grp OUTER-JOIN where                                   X_fbr-gds-grp.obj-type = {&shop}                               AND X_fbr-gds-grp.obj-code = p-curr-obj-code                               AND X_fbr-gds-grp.out-code = X_cd-grp.grp-code, ~
                                   FIRST X_upper-fbr-gds-grp   by lft    INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-rkep-grp OPEN QUERY {&SELF-NAME} FOR EACH X_cd-grp NO-LOCK, ~
                                   FIRST X_fbr-gds-grp OUTER-JOIN where                                   X_fbr-gds-grp.obj-type = {&shop}                               AND X_fbr-gds-grp.obj-code = p-curr-obj-code                               AND X_fbr-gds-grp.out-code = X_cd-grp.grp-code, ~
                                   FIRST X_upper-fbr-gds-grp  by lft    INDEXED-REPOSITION .
&Scoped-define TABLES-IN-QUERY-BR-rkep-grp X_cd-grp X_fbr-gds-grp ~
X_upper-fbr-gds-grp
&Scoped-define FIRST-TABLE-IN-QUERY-BR-rkep-grp X_cd-grp
&Scoped-define SECOND-TABLE-IN-QUERY-BR-rkep-grp X_fbr-gds-grp
&Scoped-define THIRD-TABLE-IN-QUERY-BR-rkep-grp X_upper-fbr-gds-grp


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-rkep-grp}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-link b-chg B-print ~
B-sch B-Help T-batch rs-mode T-group T-name RS-sch sch-name sch-id ~
BR-rkep-grp mark-num v-rkep-grp-name v-grp-name
&Scoped-Define DISPLAYED-OBJECTS T-batch rs-mode T-group T-name RS-sch ~
sch-name sch-id mark-num v-rkep-grp-name v-grp-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fget-rkep-full-grp-name Dialog-Frame
FUNCTION fget-rkep-full-grp-name RETURNS CHARACTER
  ( BUFFER loc-cd-grp FOR ub.cd-grp)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-gname-diff Dialog-Frame
FUNCTION get-gname-diff RETURNS LOGICAL
  ( BUFFER loc-fbr-gds-grp FOR ub.fbr-gds-grp )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-gparent-diff Dialog-Frame
FUNCTION get-gparent-diff RETURNS LOGICAL
  ( BUFFER loc-fbr-gds-grp FOR ub.fbr-gds-grp )  FORWARD.

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

DEFINE BUTTON b-quit AUTO-GO
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

DEFINE VARIABLE v-grp-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Полное назв. группы IBS TH"
      VIEW-AS TEXT
     SIZE 68.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-rkep-grp-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Полн. назв. группы R-KEEPER"
      VIEW-AS TEXT
     SIZE 68.5 BY .67
     FGCOLOR 4  NO-UNDO.

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
          "Код группы", "id",
"Нач.назв.", "name"
     SIZE 28 BY 1 NO-UNDO.

DEFINE VARIABLE T-batch AS LOGICAL INITIAL no
     LABEL "Пакетный режим"
     VIEW-AS TOGGLE-BOX
     SIZE 18.13 BY 1 NO-UNDO.

DEFINE VARIABLE T-group AS LOGICAL INITIAL no
     LABEL "Группа"
     VIEW-AS TOGGLE-BOX
     SIZE 8.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-name AS LOGICAL INITIAL no
     LABEL "Назв."
     VIEW-AS TOGGLE-BOX
     SIZE 11 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-rkep-grp FOR
      X_cd-grp,
      X_fbr-gds-grp,
      X_upper-fbr-gds-grp SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-rkep-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-rkep-grp Dialog-Frame _FREEFORM
  QUERY BR-rkep-grp NO-LOCK DISPLAY
      mark-string( recid(X_cd-grp), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_cd-grp.grp-code COLUMN-LABEL "Код группы"  FORMAT "9999":U
      X_cd-grp.name COLUMN-LABEL "Название группы" FORMAT "X(37)":U
      get-gparent-diff(BUFFER X_fbr-gds-grp) @ v-parent COLUMN-LABEL "Г" FORMAT "+/-"
      get-gname-diff(BUFFER X_fbr-gds-grp) @ v-name COLUMN-LABEL "Н" FORMAT "+/-"
      X_fbr-gds-grp.node-name FORMAT "X(30)":U
      X_cd-grp.upper-grp-code COLUMN-LABEL "Код родителя" FORMAT "9999":U
  ENABLE
      X_cd-grp.NAME
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.25 FIT-LAST-COLUMN.


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
     T-group AT ROW 2 COL 60
     T-name AT ROW 2 COL 75
     RS-sch AT ROW 3 COL 11 NO-LABEL
     sch-name AT ROW 3 COL 55 COLON-ALIGNED NO-LABEL
     sch-id AT ROW 3 COL 55 COLON-ALIGNED NO-LABEL
     BR-rkep-grp AT ROW 4 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     v-rkep-grp-name AT ROW 20 COL 1.5
     v-grp-name AT ROW 21 COL 2.5
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 8.5 BY 1 AT ROW 3 COL 1.5
          FGCOLOR 4
     SPACE(89.24) SKIP(18.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Группы блюд на кассе R-KEEPER"
         DEFAULT-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: find_cd-grp B "?" ? ub cd-grp
      TABLE: locked_cash-desk B "?" ? ub cash-desk
      TABLE: X_cd-grp B "?" ? ub cd-grp
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_fbr-gds-grp B "?" ? ub fbr-gds-grp
      TABLE: X_upper-fbr-gds-grp B "?" ? ub fbr-gds-grp
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-rkep-grp sch-id Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN v-grp-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN v-rkep-grp-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-rkep-grp
/* Query rebuild information for BROWSE BR-rkep-grp
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_cd-grp NO-LOCK,
                            FIRST X_fbr-gds-grp OUTER-JOIN where
                                  X_fbr-gds-grp.obj-type = {&shop}
                              AND X_fbr-gds-grp.obj-code = p-curr-obj-code
                              AND X_fbr-gds-grp.out-code = X_cd-grp.grp-code,
                            FIRST X_upper-fbr-gds-grp

    INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BR-rkep-grp */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Группы блюд на кассе R-KEEPER */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Группы блюд на кассе R-KEEPER */
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
  t-group
  .
  if not t-name
  and not t-group
  then do:
    message
    "Не выбрана ни одна опция для синхронизации" skip
    "(название, вышестоящая группа на кассе)"
    view-as alert-box error .
    return no-apply.
  end.

run str/diallog.w (
              input parparentproc
            , input THIS-PROCEDURE
            , input 'str/rkepsyn2.p':U
            , input (p-curr-obj-type + {&delim-par} +
              string(p-curr-obj-code) + {&delim-par} +
              (if t-batch
              then v-rid-list
              else string(recid(X_cd-grp)))
               ) + {&delim-par} +
              ((if t-name then "name":U else "":U) + {&comma-char} +
              (if t-group then "group":U else "":U)
              )
            , input no
            , input 'Прервать'
            , input 'Синхронизация данных по группам блюд на кассе R-KEEPER и соответствующим группам блюд IBS TH')
             .
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if v-rid-list <> "":U then
  REPOSITION br-rkep-grp to recid integer(entry(1, v-rid-list)) No-ERROR.

  APPLY "VALUE-CHANGED" to br-rkep-grp.
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
DEFINE BUFFER buf_fbr-gds-grp FOR ub.fbr-gds-grp.

if not available X_cd-grp then return no-apply.

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
  'actn_cashdesk-goods-groups_update':U
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
loc-doc-rec = recid(X_cd-grp).
run ref/fbrggrp.w (
      input parparentproc
    , input p-curr-obj-type
    , input p-curr-obj-code
    , input {&buttons-for-admin}
    , input-output varrid-list
).
find first buf_fbr-gds-grp no-lock where
          buf_fbr-gds-grp.obj-type = p-curr-obj-type
       AND buf_fbr-gds-grp.obj-code = p-curr-obj-code
       and buf_fbr-gds-grp.out-code = X_cd-grp.grp-code no-error.
if not available buf_Fbr-gds-grp then do:
  return no-apply.
end.
RUn OpenBR in this-procedure ( input yes, input no, input '':U).
reposition br-rkep-grp to recid loc-doc-rec no-error.
{&cant-positioning}
apply "entry" to br-rkep-grp in frame {&frame-name}.
apply "value-changed" to br-rkep-grp in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable loc#log as logical no-undo .
  if available X_cd-grp then do:
    { gbl/markstrn.i X_cd-grp v-rid-list }
    loc#log = br-rkep-grp:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-rkep-grp:select-next-row ().
        apply "VALUE-CHANGED" to br-rkep-grp in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-rkep-grp in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  if not avail X_cd-grp then return no-apply.
  run proc-b-print in this-procedure  no-error.
  if error-status:error then do:
     return no-apply.
  end.
  APPLY "ENTRY" to br-rkep-grp.
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
  if ( available X_cd-grp) then do:
    if ( v-rid-list = "" ) or b-mark:sensitive = no then
    v-rid-list = string( recid( X_cd-grp) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-rkep-grp
&Scoped-define SELF-NAME BR-rkep-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-rkep-grp Dialog-Frame
ON VALUE-CHANGED OF BR-rkep-grp IN FRAME Dialog-Frame
DO:
    RUN proc-value-changed IN THIS-PROCEDURE (

                                            OUTPUT  v-grp-name
                                          , output  v-rkep-grp-name

                                          ).
 DISPLAY
 v-grp-name
 v-rkep-grp-name
 WITH FRAME {&FRAME-NAME}.

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
          T-group
          T-name
          T-batch
          WITH FRAME {&FRAME-NAME}.
      END.
      OTHERWISE do:
          ASSIGN
          t-group = NO
          t-name = NO
          t-batch = NO    .
          DISPLAY
          t-group
          t-name
          t-batch
          WITH FRAME {&FRAME-NAME}.
          DISABLE
          T-group
          T-name
          t-batch
          b-chg
          WITH FRAME {&FRAME-NAME}.
    END.
  END CASE.
  RUN openbr IN THIS-PROCEDURE ( input YES, input NO, input '':U) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-sch Dialog-Frame
ON VALUE-CHANGED OF RS-sch IN FRAME Dialog-Frame
DO:
  RUN proc-rs-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-id
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-id Dialog-Frame
ON CTRL-J OF sch-id IN FRAME Dialog-Frame
DO:
  run proc-find-id in this-procedure(yes, input frame {&frame-name} sch-id) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-id Dialog-Frame
ON RETURN OF sch-id IN FRAME Dialog-Frame
DO:
  run proc-find-id in this-procedure(no, input frame {&frame-name} sch-id) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-name Dialog-Frame
ON CTRL-J OF sch-name IN FRAME Dialog-Frame
DO:
  run proc-find-name in this-procedure(yes, input frame {&frame-name} sch-name) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-name Dialog-Frame
ON RETURN OF sch-name IN FRAME Dialog-Frame
DO:
  run proc-find-name in this-procedure(no, input frame {&frame-name} sch-name) no-error.
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
  run proc-buttons in this-procedure(t-batch).
  if t-batch = no
  and b-mark:sensitive = no then do:
    assign
    v-rid-list = "":U.
    if avail X_cd-grp then
    GLOG = BR-rkep-grp:refresh().
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-group
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-group Dialog-Frame
ON VALUE-CHANGED OF T-group IN FRAME Dialog-Frame /* Группа */
DO:
  ASSIGN
  t-group
  .
  RUN openbr IN THIS-PROCEDURE ( input YES, input NO, input '':U) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.

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
  RUN openbr IN THIS-PROCEDURE ( input YES, input NO, input '':U) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.

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
{ ref/tabhndmv.i v-tab-order underline-tb }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-quit in frame {&frame-name}." }


 { gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &label-clmn_1   = "v-id"
  &sort-clmn_1    = "X_cd-grp.grp-code"
  &sort-clmn_2    = "X_cd-grp.name"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
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



  v-count = 0.
  i = 0.
  for each cd-grp no-lock where cd-grp.obj-code = p-curr-obj-code and
                                cd-grp.obj-type = p-curr-obj-type    :
    create temp-cd-grp.
    buffer-copy cd-grp to temp-cd-grp
    assign temp-cd-grp.lft = 0
          temp-cd-grp.rgt = 0
    .
    if temp-cd-grp.upper-grp-code = 0 then do :
      i = i + 1.
      temp-cd-grp.lft = i.
      i = i + 1.
      temp-cd-grp.rgt = i.
    end.
    temp-cd-grp.name = fill("   ", temp-cd-grp.key#_one) + temp-cd-grp.grp-name.
    /*message "id " t_temp-cd-grp.grp-code   skip "lft " t_temp-cd-grp.lft  skip "rgt " t_temp-cd-grp.rgt  .*/
  end.


  forever_ :
  repeat :
    v-parent-id = 0.
    for each t_temp-cd-grp,
        first tc_temp-cd-grp no-lock where tc_temp-cd-grp.upper-grp-code = t_temp-cd-grp.grp-code and
                                           tc_temp-cd-grp.lft = 0 and
                                           t_temp-cd-grp.rgt <> 0 by t_temp-cd-grp.rgt :
        assign
          v-parent-id = t_temp-cd-grp.grp-code
          v-parent-right = t_temp-cd-grp.rgt
        .
    end.

    if v-parent-id = 0 then leave forever_.

    v-current-left = v-parent-right.
    v-count = 0.
    for each t_temp-cd-grp no-lock where t_temp-cd-grp.upper-grp-code = v-parent-id :
      v-count = v-count + 1.
    end.

    v-parent-right = v-current-left + v-count * 2.
    v-current-lenth = v-parent-right - v-current-left.

    for each temp-cd-grp exclusive-lock /*where temp-cd-grp.rgt >= v-current-left*/ /*by rgt*/ :
      if temp-cd-grp.rgt >= v-current-left then assign temp-cd-grp.rgt = temp-cd-grp.rgt + v-current-lenth.
    end.

    for each temp-cd-grp exclusive-lock /*where temp-cd-grp.lft > v-current-left*/ /*by lft*/ :
      if temp-cd-grp.lft > v-current-left then assign temp-cd-grp.lft = temp-cd-grp.lft + v-current-lenth.
    end.

    i = v-current-left - 1.

    for each t_temp-cd-grp no-lock where t_temp-cd-grp.upper-grp-code = v-parent-id :
      assign
        i = i + 1
        t_temp-cd-grp.lft = i
        i = i + 1
        t_temp-cd-grp.rgt = i
      .
    end.
  end.

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
 find first X_clients no-lock where
                X_clients.obj-type = p-curr-obj-type
            and X_clients.obj-code = p-curr-obj-code no-error.
    if not available X_clients then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-curr-obj-type и/или p-curr-obj-code"
          view-as alert-box ERROR.
        return.
    end.
  if v-rid-list <> "" then do:
      FIND FIRST find_cd-grp No-LOCK where
                 recid(find_cd-grp) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_cd-grp then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова v-rid-list" v-rid-list
        view-as alert-box error .
        return error.
      end.
      v-doc-rec = integer(entry(1, v-rid-list)).
    end.
  { gbl/curdbnum.i v-db-num }
  if v-db-num <> X_clients.db-num then do:
    message
    "Нельзя работать с группами блюд кассы объекта удаленной БД"
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
                  "Нельзя работать с товарами на кассе"
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
  RUN MyEnable.
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if v-rid-list <> "":U then
  REPOSITION br-rkep-grp to recid integer(entry(1, v-rid-list)) No-ERROR.
  { gbl/mv-clmn.i
    &browse-name = "br-rkep-grp"
    &frame-name = "{&frame-name}"
    &ext-col = 7
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7'"
    &prev-order-column-condition_1 = " true "
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
  DISPLAY T-batch rs-mode T-group T-name RS-sch sch-name sch-id mark-num
          v-rkep-grp-name v-grp-name
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-link b-chg B-print B-sch B-Help T-batch rs-mode
         T-group T-name RS-sch sch-name sch-id BR-rkep-grp mark-num
         v-rkep-grp-name v-grp-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable Dialog-Frame
PROCEDURE Myenable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
v-tab-order = "b-quit,b-mark,b-sel,b-link,b-chg,b-sch,b-print,b-help," +
              "t-batch,rs-mode,t-name,t-group," +
               "rs-sch,sch-id,sch-full_name,br-rkep-grp"
br-rkep-grp:num-locked-columns in frame {&frame-name} = 1
X_cd-grp.name:read-only in browse br-rkep-grp = yes
rs-mode:RADIO-BUTTONS IN FRAME {&FRAME-NAME}
                       = "С привязкой&+" + {&comma-char} +  "+":U + {&comma-char} +
                       "Все&!" + {&comma-char} + {&all} + {&comma-char} +
                        "Без привязки&-" + {&comma-char} + "-":U
rs-mode = p-mode
t-name = logical(entry(1, p-status, {&delim-par}))
t-group = logical(entry(2, p-status, {&delim-par}))
.
rs-sch = "id":U.
DISPLAY
rs-mode
sch-id
mark-num
WITH FRAME {&frame-name}.
run proc-buttons in this-procedure(no).
ENABLE
b-quit
b-sel WHEN lookup("b-sel", bttns) > 0
b-chg
B-sch
B-print
B-Help
rs-mode
rs-sch
BR-rkep-grp
WITH FRAME {&FRAME-NAME}.
VIEW FRAME {&FRAME-NAME}.
RUN proc-rs-sch IN THIS-PROCEDURE.
APPLY "VALUE-CHANGED" TO rs-mode.
APPLY "ENTRY" TO BR-rkep-grp.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Справочник групп блюд на кассе R-KEEPER" + {&space-char}.
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

&scop flt-open-open-query OPEN QUERY br-rkep-grp FOR EACH X_cd-grp

&scop flt-open-dyn_open-query FOR EACH X_cd-grp

&scop flt-open-query-handle QUERY br-rkep-grp:handle

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_cd-grp

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_cd-grp

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
      &where-cond = " X_cd-grp.obj-type = p-curr-obj-type and X_cd-grp.obj-code = p-curr-obj-code and ~
                      X_cd-grp.pos-type = ~{&cd-type-r-keeper~} and X_cd-grp.grp-type = '':U "
      &dyn_where-cond = " substitute('X_cd-grp.obj-type = &1&2&1 and X_cd-grp.obj-code = &3 and ~
                      X_cd-grp.pos-type = &1&4&1 and X_cd-grp.grp-type = &1&1', ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, ~{&cd-type-r-keeper~})"

      &use-ind    = "  "
      &by         = "  "
      &flt-open-open-query-tail = ", FIRST X_fbr-gds-grp outer-join NO-LOCK WHERE X_fbr-gds-grp.obj-type = X_cd-grp.obj-type  ~
                                 AND X_fbr-gds-grp.obj-code = X_cd-grp.obj-code ~
                                AND X_fbr-gds-grp.out-CODE = X_cd-grp.grp-code ~
                               , first X_upper-fbr-gds-grp "

      }

    END.
    WHEN "-":U THEN DO:
      ASSIGN
      filter-point = filter-point0 + v-mode
      filter-label = substitute("&1 Один объект, Без связи с группами IBS TH", filter-label0)
      .
      if p-open-query then do:
         frame {&frame-name}:TITLE = title0 +
                                    substitute(" Без связи с группами IBS TH").
      end.
      { gbl/fltopend.i
      &where-cond = " X_cd-grp.obj-type = p-curr-obj-type and X_cd-grp.obj-code = p-curr-obj-code and ~
                      X_cd-grp.pos-type = ~{&cd-type-r-keeper~} and X_cd-grp.grp-type = '':U "
      &dyn_where-cond = " substitute('X_cd-grp.obj-type = &1&2&1 and X_cd-grp.obj-code = &3 and ~
                      X_cd-grp.pos-type = &1&4&1 and X_cd-grp.grp-type = &1&1', ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, ~{&cd-type-r-keeper~})"

      &use-ind    = "  "
      &by         = "  "
      &flt-open-open-query-tail = ", FIRST X_fbr-gds-grp OUTER-JOIN NO-LOCK WHERE X_fbr-gds-grp.obj-type = X_cd-grp.obj-type ~
                                AND X_fbr-gds-grp.obj-code = X_cd-grp.obj-code ~
                                AND X_fbr-gds-grp.out-CODE = X_cd-grp.grp-code ~
                                  , first X_upper-fbr-gds-grp where not available X_fbr-gds-grp "

      }

    END.
    when "+":U then do:
       ASSIGN
       filter-point = filter-point0 + v-mode
       filter-label = substitute("&1 Один объект, Связанные с группами IBS TH", filter-label0)
       .
       if p-open-query then do:
        frame {&frame-name}:TITLE = title0 +
                                      substitute(" Связанные с группами IBS TH").
       end.

       { gbl/fltopend.i
        &where-cond = " X_cd-grp.obj-type = p-curr-obj-type and X_cd-grp.obj-code = p-curr-obj-code and ~
                        X_cd-grp.pos-type = ~{&cd-type-r-keeper~} and X_cd-grp.grp-type = '':U "
        &dyn_where-cond = " substitute('X_cd-grp.obj-type = &1&2&1 and X_cd-grp.obj-code = &3 and ~
                        X_cd-grp.pos-type = &1&4&1 and X_cd-grp.grp-type = &1&1', ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, ~{&cd-type-r-keeper~})"
        &use-ind    = "  "
        &by         = "  "
        &flt-open-open-query-tail = ", FIRST X_fbr-gds-grp NO-LOCK WHERE X_fbr-gds-grp.obj-type = X_cd-grp.obj-type ~
                                  AND X_fbr-gds-grp.obj-code = X_cd-grp.obj-code ~
                                  AND X_fbr-gds-grp.out-CODE = X_cd-grp.grp-code ~
                                  and (not t-name or X_cd-grp.grp-name <> X_fbr-gds-grp.node-name) ~
                                  , first X_upper-fbr-gds-grp where (not t-group or ~
                                    (X_upper-fbr-gds-grp.node-code = X_fbr-gds-grp.node-code  ~
                                      and not ( ~
                                              (X_upper-fbr-gds-grp.out-code = X_cd-grp.grp-code) ~
                                              AnD ~
                                              (X_upper-fbr-gds-grp.lvl-num = X_cd-grp.key#_one) ~
                                              ) ~
                                      ) ~
                                                                    )"

        }

   END.
END CASE.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-rkep-grp to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-rkep-grp:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-rkep-grp in frame {&frame-name}.
APPLY "ENTRY" TO br-rkep-grp.

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
define variable v-group-name    as      CHARACTER    no-undo.
DEFINE variable v-loc-grp-name  as      CHARACTER    no-undo.
DEFINE variable v-loc-rkep-grp-name  as      CHARACTER    no-undo.
DEFINE variable v-loc-id               as CHARACTER    no-undo.
define variable for-time        as      CHARACTER    no-undo.
DEFINE VARIABLE v-loc-name AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-loc-parent AS LOGICAL NO-UNDO.
DEFINE BUFFER buf_fbr-gds-grp FOR ub.fbr-gds-grp.

DEFINE FRAME cd-grp-list
X_cd-grp.grp-code COLUMN-LABEL "Код группы" FORMAT "9999":U
X_cd-grp.grp-name COLUMN-LABEL "Название группы на кассе R-KEEPER/!       в IBS TH" FORMAT "X(27)":U
v-loc-parent COLUMN-LABEL "Г" FORMAT "+/-"
v-loc-name COLUMN-LABEL "Н" FORMAT "+/-"
v-group-name COLUMN-LABEL "Полн. Название группы на кассе R-KEEPER/!       в IBS TH" FORMAT "X(80)":U
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

FORM with FRAME cd-grp-list  .
run waitfram-show in this-procedure ( input "Ждите...").
v-doc-rec = recid(X_cd-grp).
DO WHILE available X_cd-grp:
  GET prev br-rkep-grp.
END.
GET next br-rkep-grp.
DO WHILE available X_cd-grp:
ASSIGN
v-loc-grp-name = "":U
v-loc-rkep-grp-name = "":U
.

run get-rkep-full-grp-name(
                            input p-curr-obj-code
                           ,INPUT X_cd-grp.grp-code
                           ,OUTPUT v-loc-rkep-grp-name) NO-ERROR.
  Display STREAM PrnLibStream
  X_cd-grp.grp-code
  X_cd-grp.grp-name
  v-loc-rkep-grp-name @ v-group-name
  get-gname-diff(buffer X_fbr-gds-grp) @ v-loc-name
  get-gparent-diff(buffer X_fbr-gds-grp) @ v-loc-parent
  with FRAME cd-grp-list .
  DOWN STREAM PrnLibStream 1
  with FRAME cd-grp-list  .
  IF AVAILABLE X_fbr-gds-grp THEN DO:
      RUN proc-value-changed IN THIS-PROCEDURE(
                                       OUTPUT v-loc-grp-name
                                     , output v-loc-rkep-grp-name
                                                            ) NO-ERROR.
    Display STREAM PrnLibStream
    X_fbr-gds-grp.node-name @ X_cd-grp.grp-name
    v-loc-grp-name @ v-group-name
    with FRAME cd-grp-list .
    DOWN STREAM PrnLibStream 1
    with FRAME cd-grp-list  .
  END.
  ELSE DO:
    DOWN STREAM PrnLibStream 1
    with FRAME cd-grp-list .
  END.

  assign
  accum-count = accum-count + 1
  .
  GET next br-rkep-grp.
END.
UNDERLINE  STREAM PrnLibStream
X_cd-grp.grp-code
X_cd-grp.grp-name
v-group-name
with FRAME cd-grp-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ X_cd-grp.grp-code
accum-count @ X_cd-grp.grp-NAME
with frame cd-grp-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME cd-grp-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-rkep-grp to recid v-doc-rec no-error.
APPLY "entry" to br-rkep-grp.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
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
  tbl = 'cd-grp'
  join-tbl = 'X_cd-grp'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('grp-name', 'Название', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('upper-grp-code', 'Код группы-родителя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                    , INPUT (filter-point + {&delim-par} +
                        filter-label + {&delim-par} +
                        string(yes))
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
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-id AS integer no-undo.

run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_cd-grp.grp-code = &1 "
      , p-id)
    ).
apply "entry":u to sch-id in frame {&frame-name} .

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
define input parameter p-name like ub.cd-grp.grp-name no-undo.

assign
p-name = replace(p-name, {&double-quote}, "":U)
p-name = replace(p-name, {&single-quote}, {&single-quote} + {&single-quote})
p-name = {&double-quote} + p-name + {&double-quote}.

run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_cd-grp.grp-name begins &1 "
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-value-changed Dialog-Frame
PROCEDURE proc-value-changed :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE OUTPUT PARAMETER p-grp-name AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER p-rkep-grp-name AS CHARACTER NO-UNDO.
define variable v-grp-code as integer no-undo .
IF NOT AVAILABLE X_cd-grp THEN DO:
  ASSIGN
  p-grp-name = "":U
  p-rkep-grp-name = "":u
  .
  RETURN.
END.
run get-rkep-full-grp-name(
                            input p-curr-obj-code
                           ,INPUT X_cd-grp.grp-code
                           ,OUTPUT p-rkep-grp-name) NO-ERROR.

IF AVAILABLE X_fbr-gds-grp THEN DO:
  RUN fbrglib-get-full-name IN THIS-PROCEDURE(
                                              input p-curr-obj-type
                                              ,INPUT p-curr-obj-code
                                              ,INPUT X_fbr-gds-grp.node-code
                                              ,OUTPUT p-grp-name) NO-ERROR.


END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fget-rkep-full-grp-name Dialog-Frame
FUNCTION fget-rkep-full-grp-name RETURNS CHARACTER
  ( BUFFER loc-cd-grp FOR ub.cd-grp) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-fgrp-name AS CHARACTER NO-UNDO.
RUN get-rkep-full-grp-name IN THIS-PROCEDURE
    (
        input p-curr-obj-code
        ,INPUT loc-cd-grp.grp-code
        ,OUTPUT v-fgrp-name

     )
    NO-ERROR.
IF ERROR-STATUS:ERROR THEN RETURN "!!!Ошибка".   /* Function return value. */
RETURN v-fgrp-name.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-gname-diff Dialog-Frame
FUNCTION get-gname-diff RETURNS LOGICAL
  ( BUFFER loc-fbr-gds-grp FOR ub.fbr-gds-grp ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  IF AVAILABLE loc-fbr-gds-grp THEN
 RETURN (loc-fbr-gds-grp.node-name <> X_cd-grp.grp-name).   /* Function return value. */
 RETURN NO.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-gparent-diff Dialog-Frame
FUNCTION get-gparent-diff RETURNS LOGICAL
  ( BUFFER loc-fbr-gds-grp FOR ub.fbr-gds-grp ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
DEFINE BUFFER buf_fbr-gds-grp FOR ub.fbr-gds-grp.
IF AVAILABLE loc-fbr-gds-grp  THEN DO:
  RETURN not ((loc-fbr-gds-grp.out-code = X_cd-grp.grp-code)
              and
              (loc-fbr-gds-grp.lvl-num = X_cd-grp.key#_one)).

END.
RETURN YES.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME