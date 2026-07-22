&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER find_cd-plu FOR ub.cd-plu.
DEFINE BUFFER locked_cash-desk FOR ub.cash-desk.
DEFINE BUFFER X_cd-doc-line FOR ub.cd-doc-line.
DEFINE BUFFER X_cd-plu FOR ub.cd-plu.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_goods FOR ub.goods.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник блюд на кассе R-KEEPER

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/07/05
Author: Bakhtadze Natalya
Creation date: 02/07/05

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
/*"Н" "Ц" "Г" "М"- название цена группа модификатор - передается в виде
"yes" + {&delim-par} + "yes" + {&delim-par} + {&delim-par} + "yes"*/

DEFINE INPUT PARAMETER p-curr-obj-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-curr-obj-code LIKE ub.clients.obj-code NO-UNDO.
define input-output param p-rid-list    as  char no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник блюд на кассе R-KEEPER".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
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
define variable filter-label0 as character no-undo init "Справочник блюд на кассе R-KEEPER" .
define variable filter-label as character no-undo init "Справочник блюд на кассе R-KEEPER" .
define variable filter-point0 as character no-undo init "rkep-gds" .
define variable filter-point as character no-undo init "rkep-gds" .
define variable sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
define variable v-mode as character no-undo .
define variable v-status as character no-undo .
DEFINE VARIABLE v-id as character no-undo .
DEFINE VARIABLE v-tab-order as character no-undo .
define variable v-rid-list as character no-undo .
define variable gds-rec as recid no-undo .
define buffer pos_cd-plu for ub.cd-plu.


&scop cant-positioning   if error-status:error then do: ~
                          find first pos_cd-plu no-lock where ~
                                  recid(pos_cd-plu) = loc-doc-rec no-error . ~
                            message ~
                            "Невозможно позиционироваться на записи БЛЮДА" skip~
                            string(if avail pos_cd-plu ~
                                    then  substitute("Идентификатор: &1, код меню &2" ~
                                                    , pos_cd-plu.plu-code  ~
                                                    , pos_cd-plu.key#_one) ~
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
&Scoped-define BROWSE-NAME BR-rkep-gds

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_cd-plu X_cd-doc-line

/* Definitions for BROWSE BR-rkep-gds                                   */
&Scoped-define FIELDS-IN-QUERY-BR-rkep-gds mark-string(RECID( X_cd-plu), v-rid-list) X_cd-plu.key#_one X_cd-plu.charkey_two X_cd-plu.plu-code X_cd-plu.charkey_one X_cd-doc-line.deckey_one get-group-name(buffer X_cd-plu) X_cd-plu.b-code X_cd-plu.logkey_one X_cd-plu.logkey_two X_cd-plu.logkey_three X_cd-plu.logkey_four
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-rkep-gds X_cd-plu.key#_one
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-rkep-gds X_cd-plu
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-rkep-gds X_cd-plu
&Scoped-define SELF-NAME BR-rkep-gds
&Scoped-define QUERY-STRING-BR-rkep-gds FOR EACH X_cd-plu NO-LOCK, ~
             first X_cd-doc-line OF X_cd-plu OUTER-JOIN NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-rkep-gds OPEN QUERY {&SELF-NAME} FOR EACH X_cd-plu NO-LOCK, ~
             first X_cd-doc-line OF X_cd-plu OUTER-JOIN NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-rkep-gds X_cd-plu X_cd-doc-line
&Scoped-define FIRST-TABLE-IN-QUERY-BR-rkep-gds X_cd-plu
&Scoped-define SECOND-TABLE-IN-QUERY-BR-rkep-gds X_cd-doc-line


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-rkep-gds}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-link B-update B-print ~
B-sch B-Help T-batch rs-mode T-name T-price T-group T-modificator RS-sch ~
sch-code-chr sch-id sch-full_name sch-gds-code BR-rkep-gds v-is-modificator ~
v-is-null-price mark-num v-gds-name v-rkep-grp-name v-grp-name ~
v-price-sale-chr v-price-date v-price-time-chr
&Scoped-Define DISPLAYED-OBJECTS T-batch rs-mode T-name T-price T-group ~
T-modificator RS-sch sch-code-chr sch-id sch-full_name sch-gds-code ~
v-is-modificator v-is-null-price mark-num v-gds-name v-rkep-grp-name ~
v-grp-name v-price-sale-chr v-price-date v-price-time-chr

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-group-name Dialog-Frame
FUNCTION get-group-name RETURNS CHARACTER
  ( BUFFER loc-cd-plu FOR ub.cd-plu )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
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

DEFINE BUTTON B-update
     LABEL "С&инхрон."
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sch-code-chr AS INTEGER FORMAT ">>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-full_name AS CHARACTER FORMAT "X(35)":U
     VIEW-AS FILL-IN
     SIZE 41.38 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-gds-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 10 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-id AS INTEGER FORMAT "->>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE v-gds-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Назв. в TH(на чеке)"
      VIEW-AS TEXT
     SIZE 32.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-grp-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Полное назв. группы IBS TH"
      VIEW-AS TEXT
     SIZE 68.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-price-date AS DATE FORMAT "99/99/9999":U
     LABEL "От"
      VIEW-AS TEXT
     SIZE 12 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-price-sale-chr AS CHARACTER FORMAT "X(256)":U
     LABEL "Цена в IBS TH"
      VIEW-AS TEXT
     SIZE 19.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-price-time-chr AS CHARACTER FORMAT "X(5)":U
      VIEW-AS TEXT
     SIZE 6 BY .67
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
          "Код меню", "code-chr",
"Идентиф-р", "id",
"Бар-код", "gds-code",
"Нач.назв.", "full_name"
     SIZE 41.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-batch AS LOGICAL INITIAL no
     LABEL "Пакетный режим"
     VIEW-AS TOGGLE-BOX
     SIZE 18.13 BY 1 NO-UNDO.

DEFINE VARIABLE T-group AS LOGICAL INITIAL no
     LABEL "Группа"
     VIEW-AS TOGGLE-BOX
     SIZE 8.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-modificator AS LOGICAL INITIAL no
     LABEL "Модиф.,0 цена"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE T-name AS LOGICAL INITIAL no
     LABEL "Назв."
     VIEW-AS TOGGLE-BOX
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE T-price AS LOGICAL INITIAL no
     LABEL "Цена"
     VIEW-AS TOGGLE-BOX
     SIZE 7.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-is-modificator AS LOGICAL INITIAL no
     LABEL "Модификатор"
     VIEW-AS TOGGLE-BOX
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-is-null-price AS LOGICAL INITIAL no
     LABEL "Нулевая цена"
     VIEW-AS TOGGLE-BOX
     SIZE 16 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-rkep-gds FOR
      X_cd-plu,
      X_cd-doc-line SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-rkep-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-rkep-gds Dialog-Frame _FREEFORM
  QUERY BR-rkep-gds NO-LOCK DISPLAY
      mark-string(RECID( X_cd-plu), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_cd-plu.key#_one COLUMN-LABEL "Код меню" FORMAT "9999":U
      X_cd-plu.charkey_two COLUMN-LABEL "М" FORMAT "X(1)":U
      X_cd-plu.plu-code COLUMN-LABEL "Идентиф-р" FORMAT "9999":U
      X_cd-plu.charkey_one COLUMN-LABEL "Название блюда!на кассе R-KEEPER" FORMAT "X(25)":U
      X_cd-doc-line.deckey_one COLUMN-LABEL "Цена" FORMAT ">,>>>,>>9.999":U
      get-group-name(buffer X_cd-plu) COLUMN-LABEL "Группа меню" FORMAT "X(20)":U
            WIDTH 22
      X_cd-plu.b-code COLUMN-LABEL "Бар-код!в IBS TH" FORMAT "999999999":U
      X_cd-plu.logkey_one COLUMN-LABEL "Н" FORMAT "X(1)"
      X_cd-plu.logkey_two COLUMN-LABEL "Ц" FORMAT "X(1)"
      X_cd-plu.logkey_three COLUMN-LABEL "Г" FORMAT "X(1)"
      X_cd-plu.logkey_four COLUMN-LABEL "М" FORMAT "X(1)"
  ENABLE
      X_cd-plu.key#_one
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 13.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     B-link AT ROW 1 COL 41
     B-update AT ROW 1 COL 51
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     T-batch AT ROW 2 COL 1
     rs-mode AT ROW 2 COL 20 NO-LABEL
     T-name AT ROW 2 COL 60
     T-price AT ROW 2 COL 68
     T-group AT ROW 2 COL 75
     T-modificator AT ROW 2 COL 84
     RS-sch AT ROW 3 COL 11 NO-LABEL
     sch-code-chr AT ROW 3 COL 55 COLON-ALIGNED NO-LABEL
     sch-id AT ROW 3 COL 55 COLON-ALIGNED NO-LABEL
     sch-full_name AT ROW 3 COL 55 COLON-ALIGNED NO-LABEL
     sch-gds-code AT ROW 3 COL 55 COLON-ALIGNED NO-LABEL
     BR-rkep-gds AT ROW 4.5 COL 1
     v-is-modificator AT ROW 21 COL 1.5
     v-is-null-price AT ROW 21 COL 16.5
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     v-gds-name AT ROW 18 COL 22 COLON-ALIGNED
     v-rkep-grp-name AT ROW 19 COL 1.5
     v-grp-name AT ROW 20 COL 2.5
     v-price-sale-chr AT ROW 21 COL 52 COLON-ALIGNED
     v-price-date AT ROW 21 COL 77 COLON-ALIGNED
     v-price-time-chr AT ROW 21 COL 90 COLON-ALIGNED NO-LABEL
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 8.5 BY 1 AT ROW 3 COL 1.5
          FGCOLOR 4
     SPACE(89.24) SKIP(18.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "товары на кассе R-KEEPER"
         DEFAULT-BUTTON b-quit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: find_cd-plu B "?" ? ub cd-plu
      TABLE: locked_cash-desk B "?" ? ub cash-desk
      TABLE: X_cd-doc-line B "?" ? ub cd-doc-line
      TABLE: X_cd-plu B "?" ? ub cd-plu
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_goods B "?" ? ub goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-rkep-gds sch-gds-code Dialog-Frame */
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

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-rkep-gds
/* Query rebuild information for BROWSE BR-rkep-gds
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_cd-plu NO-LOCK,
      first X_cd-doc-line OF X_cd-plu OUTER-JOIN NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _TblOptList       = ",, OUTER"
     _Query            is OPENED
*/  /* BROWSE BR-rkep-gds */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON ENDKEY OF FRAME Dialog-Frame /* товары на кассе R-KEEPER */
DO:
      run gbl/markqwa.p (
                           input b-mark:sensitive
                          , input v-rid-list) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* товары на кассе R-KEEPER */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* товары на кассе R-KEEPER */
DO:
  APPLY "END-ERROR":U TO SELF.
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
define variable main-code like ub.bar-code.b-code no-undo .
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.


if not available X_cd-plu then return no-apply.

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
  'actn_cashdesk-goods_add-def':U
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
loc-doc-rec = recid(X_cd-plu).
run ref/gds-ref.p ( parparentproc
               ,"b-add,b-sel"
              ,?
              ,?
              ,?
              ,?
              ,?
              ,?
              ,?
              ,p-curr-obj-type
              ,p-curr-obj-code
              ,?
             , output varrid-list ).
if varrid-list = "" then undo, return no-apply.
find first buf_goods no-lock where
          recid(buf_goods) = integer(varrid-list) no-error.
if error-status:error then do:
  return no-apply.
end.
{ gbl/gdsbcode.i buf_goods.gds-code ? main-code no-error }
if error-status:error then return no-apply.
run ref/alt-cds.w (input parparentproc
              ,input p-curr-obj-type
              ,input p-curr-obj-code
              ,input "all-no-part"
              ,buf_goods.gds-code
              ,main-code
              ,output varrid-list).
if varrid-list = "" then undo, return no-apply.
run proc-b-link in this-procedure (INPUT recid(X_cd-plu), input varrid-list) no-error.
if error-status:error then return no-apply.
RUn OpenBR in this-procedure ( input yes, input no, input '':U).
reposition br-rkep-gds to recid loc-doc-rec no-error.
{&cant-positioning}
apply "entry" to br-rkep-gds in frame {&frame-name}.
apply "value-changed" to br-rkep-gds in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable loc#log as logical no-undo .
  if available X_cd-plu then do:
    { gbl/markstrn.i X_cd-plu v-rid-list }
    loc#log = br-rkep-gds:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-rkep-gds:select-next-row ().
        apply "VALUE-CHANGED" to br-rkep-gds in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-rkep-gds in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  if not avail X_cd-plu then return no-apply.
  run proc-b-print in this-procedure  no-error.
  if error-status:error then do:
     return no-apply.
  end.
  APPLY "ENTRY" to br-rkep-gds.
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
  if ( available X_cd-plu ) then do:
    if ( v-rid-list = "" ) or b-mark:sensitive = no then
    v-rid-list = string( recid( X_cd-plu ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-update
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-update Dialog-Frame
ON CHOOSE OF B-update IN FRAME Dialog-Frame /* Синхрон. */
DO:
  assign
  t-name
  t-price
  t-group
  t-modificator
  .
  if not t-name
  and not t-price
  and not t-group
  and not t-modificator
  then do:
    message
    "Не выбрана ни одна опция для синхронизации" skip
    "(название, цена, группа на кассе, модификатор и 0-цена)"
    view-as alert-box error .
    return no-apply.
  end.

run str/diallog.w (
              input parparentproc
            , input THIS-PROCEDURE
            , input 'str/rkepsyn1.p':U
            , input (p-curr-obj-type + {&delim-par} +
              string(p-curr-obj-code) + {&delim-par} +
              (if t-batch
              then v-rid-list
              else string(recid(X_cd-plu)))
               ) + {&delim-par} +
              ((if t-name then "name":U else "":U) + {&comma-char} +
              (if t-price then "price":U else "":U) + {&comma-char} +
              (if t-group then "group":U else "":U) + {&comma-char} +
              (if t-modificator then "modificator":U else "":U))
            , input no
            , input 'Прервать'
            , input 'Синхронизация данных по блюдам/товарам на кассе R-KEEPER и соответствующим товаров IBS TH')
             .
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if v-rid-list <> "":U then
  REPOSITION br-rkep-gds to recid integer(entry(1, v-rid-list)) No-ERROR.

  APPLY "VALUE-CHANGED" to br-rkep-gds.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-rkep-gds
&Scoped-define SELF-NAME BR-rkep-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-rkep-gds Dialog-Frame
ON VALUE-CHANGED OF BR-rkep-gds IN FRAME Dialog-Frame
DO:
  RUN proc-value-changed IN THIS-PROCEDURE (OUTPUT v-gds-name
                                          , OUTPUT v-price-sale-chr
                                          , OUTPUT v-grp-name
                                          , output v-rkep-grp-name
                                          , output v-is-modificator
                                          , output v-is-null-price
                                          , OUTPUT v-price-date
                                          , OUTPUT v-price-time-chr
                                          ).
 DISPLAY
 v-gds-name
 v-price-sale-chr
 v-is-modificator
 v-is-null-price
 v-grp-name
 v-rkep-grp-name
 v-price-date
 v-price-time-chr
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
          b-update
          T-group
          T-name
          T-price
          t-modificator
          T-batch
          WITH FRAME {&FRAME-NAME}.
      END.
      OTHERWISE do:
          ASSIGN
          t-group = NO
          t-name = NO
          t-price = NO
          t-batch = NO    .
          DISPLAY
          t-group
          t-modificator
          t-name
          t-price
          t-batch
          WITH FRAME {&FRAME-NAME}.
          DISABLE
          T-group
          t-modificator
          T-name
          T-price
          t-batch
          b-update
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


&Scoped-define SELF-NAME sch-code-chr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code-chr Dialog-Frame
ON CTRL-J OF sch-code-chr IN FRAME Dialog-Frame
DO:
  run proc-find-code-chr in this-procedure(yes, input frame {&frame-name} sch-code-chr) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code-chr Dialog-Frame
ON RETURN OF sch-code-chr IN FRAME Dialog-Frame
DO:
  run proc-find-code-chr in this-procedure(no, input frame {&frame-name} sch-code-chr) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-full_name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-full_name Dialog-Frame
ON CTRL-J OF sch-full_name IN FRAME Dialog-Frame
DO:
  run proc-find-full_name in this-procedure(yes, input frame {&frame-name} sch-full_name) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-full_name Dialog-Frame
ON RETURN OF sch-full_name IN FRAME Dialog-Frame
DO:
  run proc-find-full_name in this-procedure(no, input frame {&frame-name} sch-full_name) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-gds-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-gds-code Dialog-Frame
ON CTRL-J OF sch-gds-code IN FRAME Dialog-Frame
DO:
  run proc-find-gds-code in this-procedure(yes, input frame {&frame-name} sch-gds-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-gds-code Dialog-Frame
ON RETURN OF sch-gds-code IN FRAME Dialog-Frame
DO:
  run proc-find-gds-code in this-procedure(no, input frame {&frame-name} sch-gds-code) no-error.
  if error-status:error then return no-apply.
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
    if avail X_cd-plu then
    GLOG = BR-rkep-gds:refresh().
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


&Scoped-define SELF-NAME T-modificator
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-modificator Dialog-Frame
ON VALUE-CHANGED OF T-modificator IN FRAME Dialog-Frame /* Модиф.,0 цена */
DO:
  ASSIGN
  t-modificator
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


&Scoped-define SELF-NAME T-price
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-price Dialog-Frame
ON VALUE-CHANGED OF T-price IN FRAME Dialog-Frame /* Цена */
DO:
    ASSIGN
  t-price
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
{ gbl/f2.i br-rkep-gds goods-recid get-gds-recid parparentproc }
{ ref/tabhndmv.i v-tab-order underline-tb }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-quit in frame {&frame-name}." }

{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_cd-plu.b-code"
  &label-clmn_2   = "v-id"
  &sort-clmn_2    = "X_cd-plu.plu-code"
  &sort-clmn_3    = "X_cd-plu.charkey_one"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

{ gbl/brwrepos.i
  &line-num=5
}

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
      FIND FIRST find_cd-plu No-LOCK where
                 recid(find_cd-plu) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_cd-plu then do:
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
    "Нельзя работать с товарами кассы объекта удаленной БД"
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
  REPOSITION br-rkep-gds to recid integer(entry(1, v-rid-list)) No-ERROR.
  { gbl/mv-clmn.i
    &browse-name = "br-rkep-gds"
    &frame-name = "{&frame-name}"
    &ext-col = 12
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10,11,12'"
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
  DISPLAY T-batch rs-mode T-name T-price T-group T-modificator RS-sch
          sch-code-chr sch-id sch-full_name sch-gds-code v-is-modificator
          v-is-null-price mark-num v-gds-name v-rkep-grp-name v-grp-name
          v-price-sale-chr v-price-date v-price-time-chr
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-link B-update B-print B-sch B-Help T-batch
         rs-mode T-name T-price T-group T-modificator RS-sch sch-code-chr
         sch-id sch-full_name sch-gds-code BR-rkep-gds v-is-modificator
         v-is-null-price mark-num v-gds-name v-rkep-grp-name v-grp-name
         v-price-sale-chr v-price-date v-price-time-chr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-gds-recid Dialog-Frame
PROCEDURE get-gds-recid :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
IF NOT AVAILABLE X_goods THEN DO:
    gds-rec = ?.
    RETURN.
END.
gds-rec = RECID(X_goods).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable Dialog-Frame
PROCEDURE Myenable :
assign
v-tab-order = "b-quit,b-mark,b-sel,b-link,b-update,b-sch,b-print,b-help," +
              "t-batch,rs-mode,t-name,t-price,t-group,t-modificator," +
               "rs-sch,sch-code-chr,sch-id,sch-gds-code,sch-full_name,br-rkep-gds"
br-rkep-gds:num-locked-columns in frame {&frame-name} = 1
X_cd-plu.key#_one:read-only in browse br-rkep-gds = yes
rs-mode:RADIO-BUTTONS IN FRAME {&FRAME-NAME}
                       = "С привязкой&+" + {&comma-char} +  "+":U + {&comma-char} +
                       "Все&!" + {&comma-char} + {&all} + {&comma-char} +
                        "Без привязки&-" + {&comma-char} + "-":U
rs-mode = p-mode
t-name = logical(entry(1, p-status, {&delim-par}))
t-price = logical(entry(2, p-status, {&delim-par}))
t-group = logical(entry(3, p-status, {&delim-par}))
t-modificator = logical(entry(4, p-status, {&delim-par}))
.
rs-sch = "id":U.
DISPLAY
rs-mode
sch-code-chr
sch-gds-code
sch-id
sch-full_name
mark-num
WITH FRAME {&frame-name}.
run proc-buttons in this-procedure(no).
ENABLE
b-quit
b-sel WHEN lookup("b-sel", bttns) > 0
b-update
B-sch
B-print
B-Help
b-update
rs-mode
BR-rkep-gds
rs-sch
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
APPLY "VALUE-CHANGED" TO rs-mode.
APPLY "ENTRY" TO BR-rkep-gds.
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
title0 = "Справочник блюд на кассе R-KEEPER" + {&space-char}.
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

&scop flt-open-open-query OPEN QUERY br-rkep-gds FOR EACH X_cd-plu

&scop flt-open-dyn_open-query FOR EACH X_cd-plu

&scop flt-open-query-handle QUERY br-rkep-gds:handle

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_cd-plu

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_cd-plu


&scop flt-open-open-query-tail ,  LAST X_cd-doc-line OUTER-JOIN NO-LOCK WHERE ~
X_cd-doc-line.obj-type = X_cd-plu.obj-type and X_cd-doc-line.obj-code = X_cd-plu.obj-code and X_cd-doc-line.pos-type = X_cd-plu.pos-type ~
and X_cd-doc-line.doc-type = ~{&overvalue~} and X_cd-doc-line.plu-type = X_cd-plu.plu-type and X_cd-doc-line.plu-code = X_cd-plu.plu-code

&scop flt-open-dyn_open-query-tail substitute(',  LAST X_cd-doc-line OUTER-JOIN NO-LOCK WHERE ~
X_cd-doc-line.obj-type = X_cd-plu.obj-type and X_cd-doc-line.obj-code = X_cd-plu.obj-code and X_cd-doc-line.pos-type = X_cd-plu.pos-type ~
and X_cd-doc-line.doc-type = &1&2&1 and X_cd-doc-line.plu-type = X_cd-plu.plu-type and X_cd-doc-line.plu-code = X_cd-plu.plu-code', ~{&double-quote~}, ~{&overvalue~})



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
      &where-cond = " X_cd-plu.obj-type = p-curr-obj-type and X_cd-plu.obj-code = p-curr-obj-code and X_cd-plu.pos-type = ~{&cd-type-r-keeper~} "
      &dyn_where-cond = " substitute('X_cd-plu.obj-type = &1&2&1 and X_cd-plu.obj-code = &3 and X_cd-plu.pos-type = &1&4&1 and X_cd-plu.plu-type = &1&1 ' ~
                        , ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, ~{&cd-type-r-keeper~})"
      &use-ind    = "  "
      &by         = "  "
      }

    END.
    WHEN "-":U THEN DO:
       ASSIGN
       filter-point = filter-point0 + v-mode
       filter-label = substitute("&1 Один объект, Без связи с товарами IBS TH", filter-label0)
       .
       if p-open-query then do:
        frame {&frame-name}:TITLE = title0 +
                                      substitute(" Без связи с товарами IBS TH").
       end.

      { gbl/fltopend.i
        &where-cond = " X_cd-plu.obj-type = p-curr-obj-type and X_cd-plu.obj-code = p-curr-obj-code and X_cd-plu.pos-type = ~{&cd-type-r-keeper~} and X_cd-plu.plu-type = '':U ~
                       and X_cd-plu.gds-code = 0 ~
                      "
        &dyn_where-cond = " substitute('X_cd-plu.obj-type = &1&2&1 and X_cd-plu.obj-code = &3 and X_cd-plu.pos-type = &1&4&1 and X_cd-plu.plu-type = &1&1 ~
                       and X_cd-plu.gds-code = 0 ', ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, ~{&cd-type-r-keeper~})"

        &use-ind    = "  "
        &by         = "  "
        }

       END.
    when "+":U then do:
       ASSIGN
       filter-point = filter-point0 + v-mode
       filter-label = substitute("&1 Один объект, Связанные с товарами IBS TH", filter-label0)
       .
       if p-open-query then do:
         frame {&frame-name}:TITLE = title0 +
                                    substitute(" Связанные с товарами IBS TH").
       end.
       { gbl/fltopend.i
        &where-cond = " X_cd-plu.obj-type = p-curr-obj-type and X_cd-plu.obj-code = p-curr-obj-code and X_cd-plu.pos-type = ~{&cd-type-r-keeper~} and X_cd-plu.plu-type = '':U ~
                        and X_cd-plu.gds-code  <> 0 ~
       and (not t-name or X_cd-plu.logkey_one = yes) ~
       and (not t-price or X_cd-plu.logkey_two = yes) ~
       and (not t-group or X_cd-plu.logkey_three = yes) ~
       and (not t-modificator or X_cd-plu.logkey_four = yes) ~
              "
        &dyn_where-cond = " substitute('X_cd-plu.obj-type = &1&2&1 and X_cd-plu.obj-code = &3 and X_cd-plu.pos-type = &1&4&1 and X_cd-plu.plu-type = &1&1 ~
                        and X_cd-plu.gds-code  <> 0 ~
       and (not &5 or X_cd-plu.logkey_one = yes) ~
       and (not &6 or X_cd-plu.logkey_two = yes) ~
       and (not &7 or X_cd-plu.logkey_three = yes) ~
       and (not &8 or X_cd-plu.logkey_four = yes) ', ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, ~{&cd-type-r-keeper~}, t-name, t-price, t-group, t-modificator) "

        &use-ind    = "  "
        &by         = "  " }
    END.
END CASE.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-rkep-gds to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-rkep-gds:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-rkep-gds in frame {&frame-name}.
APPLY "ENTRY" TO br-rkep-gds.
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
DEFINE INPUT PARAMETER p-b-code-recid as recid no-undo.

DEFINE VARIABLE loclog AS LOGICAL NO-UNDO.
define variable v-doc-num as character no-undo .
define variable v-grp-name as character no-undo .
define variable v-grp-code as integer no-undo .
define variable v-gds-name as character no-undo .
define variable v-price-sale as decimal no-undo .
define variable v-is-modificator as logical no-undo .
define variable v-is-null-price as logical no-undo .

define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
DEFINE BUFFER buf_cd-plu FOR ub.cd-plu.

do
on error undo, return error
:

  FIND FIRST buf_cd-plu EXCLUSIVE-LOCK WHERE
            RECID(buf_cd-plu) = p-recid.
  find first buf_bar-code no-lock where
            recid(buf_bar-code) = p-b-code-recid  .
  IF buf_cd-plu.b-code <> 0 THEN DO:
      MESSAGE
    SUBSTITUTE("Блюдо с кодом меню &1 и идентификатором &2 уже привязано к товару в IBS TH c бар-кодом &3&4" +
                "заменить привязку?"
                , buf_cd-plu.key#_one
                , buf_cd-plu.plu-code
                , buf_cd-plu.b-code
                , {&NEW-LINE})
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE loclog.
      IF NOT loclog THEN RETURN ERROR.
  END.

  ASSIGN
  buf_cd-plu.b-code = buf_bar-code.b-code
  buf_cd-plu.gds-code = buf_bar-code.gds-code
  buf_cd-plu.logkey_one = (v-gds-name <> buf_cd-plu.charkey_one)
  buf_cd-plu.logkey_two = (v-price-sale <> X_cd-doc-line.deckey_one)
  buf_cd-plu.logkey_three = ( v-grp-code <> buf_cd-plu.key#_two)
  .

  assign
  v-price-sale = get-rkgTH-price(p-curr-obj-type, p-curr-obj-code, buf_cd-plu.gds-code, output v-doc-num)
  v-gds-name   = get-rkgTH-name(p-curr-obj-type, p-curr-obj-code, buf_cd-plu.gds-code, buffer buf_goods)
  v-grp-code   = get-rkgTH-group(p-curr-obj-type, p-curr-obj-code, buf_cd-plu.gds-code, output v-grp-name)
  v-is-modificator = get-rkgTH-modificator(p-curr-obj-type, p-curr-obj-code, buf_cd-plu.gds-code, output v-is-null-price)
  .
end. /*doe*/

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
define variable for-time        as      CHARACTER    no-undo.
define variable for-time-price  as      CHARACTER    no-undo.
define variable v-group-name    as      CHARACTER    no-undo.
DEFINE variable v-loc-gds-name  as      CHARACTER    no-undo.
DEFINE variable v-loc-grp-name  as      CHARACTER    no-undo.
DEFINE variable v-loc-rkep-grp-name  as      CHARACTER    no-undo.
define variable v-loc-is-modificator as logical no-undo .
define variable v-loc-is-null-price   as logical no-undo .
DEFINE variable v-loc-price-sale-chr  as      CHARACTER    no-undo.
DEFINE variable v-loc-price-date  as    DATE         no-undo.
DEFINE variable v-loc-price-time-chr as CHARACTER    no-undo.
DEFINE variable v-loc-id               as CHARACTER    no-undo.

DEFINE FRAME cd-plu-list
X_cd-plu.key#_one COLUMN-LABEL "Код меню" FORMAT "9999":U
X_cd-plu.charkey_two COLUMN-LABEL "М" FORMAT "X(1)":U
X_cd-plu.plu-code COLUMN-LABEL "Идентиф-р" FORMAT "9999":U
X_cd-plu.charkey_one COLUMN-LABEL "Название блюда!на кассе R-KEEPER" FORMAT "X(30)":U
X_cd-doc-line.deckey_one FORMAT ">,>>>,>>9.999":U
v-group-name FORMAT "X(50)":U
X_cd-plu.b-code COLUMN-LABEL "Бар-код!в IBS TH" FORMAT "999999999":U
X_cd-plu.logkey_one COLUMN-LABEL "Н" FORMAT "+/"
X_cd-plu.logkey_two COLUMN-LABEL "Ц" FORMAT "+/"
X_cd-plu.logkey_three COLUMN-LABEL "Г" FORMAT "+/"
X_cd-plu.logkey_four COLUMN-LABEL "М" FORMAT "+/"
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

FORM with FRAME cd-plu-list  .
run waitfram-show in this-procedure ("Ждите...").
v-doc-rec = recid(X_cd-plu).
DO WHILE available X_cd-plu :
  GET prev br-rkep-gds.
END.
GET next br-rkep-gds.
DO WHILE available X_cd-plu :
ASSIGN
v-loc-gds-name = "":U
v-loc-price-sale-chr = "":U
v-loc-grp-name = "":U
v-loc-price-date = ?
v-loc-price-time-chr = "":U
v-loc-rkep-grp-name = "":U
.

run get-rkep-full-grp-name(
                            input p-curr-obj-code
                           ,INPUT X_cd-plu.key#_two
                           ,OUTPUT v-loc-rkep-grp-name) NO-ERROR.
  Display STREAM PrnLibStream
  X_cd-plu.key#_one
  X_cd-plu.charkey_two
  X_cd-plu.plu-code
  X_cd-plu.charkey_one
  X_cd-doc-line.deckey_one
  v-loc-rkep-grp-name @ v-group-name
  X_cd-plu.b-code
  X_cd-plu.logkey_one
  X_cd-plu.logkey_two
  X_cd-plu.logkey_three
  X_cd-plu.logkey_four
  with FRAME cd-plu-list .
  DOWN STREAM PrnLibStream 1
  with FRAME cd-plu-list  .

  IF X_cd-plu.gds-code <> 0 THEN DO:
      RUN proc-value-changed IN THIS-PROCEDURE(
                                       OUTPUT v-loc-gds-name
                                     , OUTPUT v-loc-price-sale-chr
                                     , OUTPUT v-loc-grp-name
                                     , output v-loc-rkep-grp-name
                                     , output v-loc-is-modificator
                                     , output v-loc-is-null-price
                                     , OUTPUT v-loc-price-date
                                     , OUTPUT v-loc-price-time-chr) NO-ERROR.
    Display STREAM PrnLibStream
    v-loc-gds-name @ X_cd-plu.charkey_one
    v-loc-price-sale-chr @ X_cd-doc-line.deckey_one
    v-loc-grp-name @ v-group-name
    with FRAME cd-plu-list .
    DOWN STREAM PrnLibStream 1
    with FRAME cd-plu-list  .
  END.
  ELSE DO:
    DOWN STREAM PrnLibStream 1
    with FRAME cd-plu-list .
  END.

  assign
  accum-count = accum-count + 1
  .
  GET next br-rkep-gds.
END.
UNDERLINE  STREAM PrnLibStream
X_cd-plu.key#_one
X_cd-plu.charkey_two
X_cd-plu.plu-code
X_cd-plu.charkey_one
X_cd-doc-line.deckey_one
v-group-name
X_cd-plu.b-code
X_cd-plu.logkey_one
X_cd-plu.logkey_two
X_cd-plu.logkey_three
X_cd-plu.logkey_four
with FRAME cd-plu-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ X_cd-plu.key#_one
accum-count @ X_cd-plu.plu-code
with frame cd-plu-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME cd-plu-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-rkep-gds to recid v-doc-rec no-error.
APPLY "entry" to br-rkep-gds.
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
  tbl = 'cd-plu'
  join-tbl = 'X_cd-plu'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('key#_one', 'Код меню', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('charkey_one', 'Название блюда', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('gds-code', 'Бар-код IBS TH', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('charkey_two', 'Тип блюда', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('key#_two', 'Код группы меню', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('logkey_one', 'Изменилось название', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('logkey_two', 'Изменилась цена', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('logkey_three', 'Изменилась группа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
/*
run fltfield-add in this-procedure('imp-date', 'Дата импорта', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('imp-time', 'Время импорта', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('imp-user', 'Оператор', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', 'Статус', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
*/

Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
               , INPUT (filter-point + {&delim-par} +
                        filter-label  + {&delim-par} +
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-code-chr Dialog-Frame
PROCEDURE proc-find-code-chr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-code-chr as integer no-undo.

run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_cd-plu.key#_one = &1 "
      , p-code-chr)
    ).
apply "entry":u to sch-code-chr in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-full_name Dialog-Frame
PROCEDURE proc-find-full_name :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-full_name as character no-undo.

assign
p-full_name = replace(p-full_name, {&double-quote}, "":U)
p-full_name = replace(p-full_name, {&single-quote}, {&single-quote} + {&single-quote})
p-full_name = {&double-quote} + p-full_name + {&double-quote}.

run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_cd-plu.charkey_one begins &1 "
      , p-full_name)
    ).
apply "entry":u to sch-full_name in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-gds-code Dialog-Frame
PROCEDURE proc-find-gds-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-b-code like ub.cd-plu.b-code no-undo.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_cd-plu.b-code = &1 "
      , p-b-code)
    ).
apply "entry":u to sch-gds-code in frame {&frame-name} .

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
define input parameter p-id AS INTEGER no-undo.

run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_cd-plu.plu-code = &1 "
      , p-id)
    ).
apply "entry":u to sch-id in frame {&frame-name} .
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
    when "code-chr" then do:
      enable
      sch-code-chr
      with frame {&frame-name}.
      display
      sch-code-chr
      with frame {&frame-name}.
      hide
      sch-gds-code
      sch-id
      sch-full_name
      in frame {&frame-name}.
      apply "entry" to sch-code-chr in frame {&frame-name}.
    end.
    when "id" then do:
      enable
      sch-id
      with frame {&frame-name}.
      display
      sch-id
      with frame {&frame-name}.
      hide
      sch-gds-code
      sch-code-chr
      sch-full_name
      in frame {&frame-name}.
      apply "entry" to sch-id in frame {&frame-name}.
    end.
    when "gds-code" then do:
      enable
      sch-gds-code
      with frame {&frame-name}.
      display
      sch-gds-code
      with frame {&frame-name}.
      hide
      sch-id
      sch-code-chr
      sch-full_name
      in frame {&frame-name}.
      apply "entry" to sch-gds-code in frame {&frame-name}.
    end.
    when "full_name" then do:
      enable
      sch-full_name
      with frame {&frame-name}.
      display
      sch-full_name
      with frame {&frame-name}.
      hide
      sch-id
      sch-code-chr
      sch-gds-code
      in frame {&frame-name}.
      apply "entry" to sch-full_name in frame {&frame-name}.
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
DEFINE OUTPUT PARAMETER p-gds-name AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER p-price-sale-chr AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER p-grp-name AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER p-rkep-grp-name AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER p-is-modificator AS logical NO-UNDO.
DEFINE OUTPUT PARAMETER p-is-null-price AS logical NO-UNDO.
DEFINE OUTPUT PARAMETER p-price-date AS date NO-UNDO.
DEFINE OUTPUT PARAMETER p-price-time-chr AS CHARACTER NO-UNDO.
define variable v-price-sale as decimal   no-undo .
define variable v-grp-code as integer no-undo .
define variable v-doc-num as character no-undo .

DEFINE BUFFER buf_price-doc FOR ub.price-doc.

IF NOT AVAILABLE X_cd-plu THEN DO:
  ASSIGN
  p-gds-name = "":U
  p-price-sale-chr = "":U
  p-is-modificator = NO
  p-is-null-price = NO
  p-rkep-grp-name = "":u
  p-price-time-chr = "":U
  .
  RELEASE X_goods.
  RETURN.
END.
run get-rkep-full-grp-name(
                            input p-curr-obj-code
                           ,INPUT X_cd-plu.key#_two
                           ,OUTPUT p-rkep-grp-name) NO-ERROR.

IF X_cd-plu.b-code <> 0 THEN DO:
   assign
   p-gds-name = get-rkgTH-name(p-curr-obj-type, p-curr-obj-code, X_cd-plu.b-code, buffer X_goods).
   assign
   v-price-sale = get-rkgTH-price(p-curr-obj-type, p-curr-obj-code, X_cd-plu.b-code, output v-doc-num)
   .
   ASSIGN
   p-price-sale-chr = if v-price-sale <> ? then STRING(v-price-sale, ">>>,>>>,>>9.99") else {&question-mark}.
   FIND FIRST buf_price-doc NO-LOCK WHERE
             buf_price-doc.doc-num = v-doc-num NO-ERROR.
   IF AVAILABLE buf_price-doc THEN DO:
       ASSIGN
       p-price-date = buf_price-doc.fact-date
       p-price-time-chr = string(buf_price-doc.fact-time, "HH:MM":U)
       .

   END.
   assign
   v-grp-code = get-rkgTH-group(p-curr-obj-type, p-curr-obj-code, X_cd-plu.b-code, output p-grp-name).
   p-is-modificator = get-rkgTH-modificator(p-curr-obj-type, p-curr-obj-code, X_cd-plu.b-code, output p-is-null-price).
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-group-name Dialog-Frame
FUNCTION get-group-name RETURNS CHARACTER
  ( BUFFER loc-cd-plu FOR ub.cd-plu ) :
define buffer buf_cd-grp for ub.cd-grp.
IF loc-cd-plu.charkey_two = "M" THEN RETURN "":U.
find first buf_cd-grp exclusive-lock where
          buf_cd-grp.obj-type = loc-cd-plu.obj-type
      and buf_cd-grp.obj-code = loc-cd-plu.obj-code
      and buf_cd-grp.pos-type = loc-cd-plu.pos-type
      and buf_cd-grp.grp-type = '':U
      and buf_cd-grp.grp-code = loc-cd-plu.key#_two no-error.
RETURN (IF available buf_cd-grp
             THEN buf_cd-grp.grp-name
             ELSE "!!!Неизвестная группа меню").

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME