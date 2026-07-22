&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dlg-grp


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_goods FOR goods.
DEFINE BUFFER buf_Matrix-goods FOR assortment-matrix-goods.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dlg-grp
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Управление ассортиментной матрицей в разрезе групп

Автор: Чернова Светлана Александровна
Дата создания: 10/08/08
Author: Svetlana Chernova
Creation date: 10/08/08

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */


define input parameter parparentproc        as handle           no-undo.
define input parameter p-db-num             as integer   no-undo .
define input parameter p-id                 as integer   no-undo .
define input parameter p-button-list        as character        no-undo. /* список включенных кнопок */
define input parameter p-current-obj-type   as character        no-undo.
define input parameter p-current-obj-code   as integer          no-undo.
define input-output parameter p-recid-list  as character        no-undo.

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Управление деревом групп".
{ cmp/vssrevis.i      }
{ cmp/trg-def.i       }
{ cmp/showinf.i       }
{ ref/grplib.i        }
{ cmp/library.i       }
{ ref/gds-matl.i      }
{ gbl/cur-time.i      }
{ cmp/r-pril.i new    }
{ gbl/waitfram.i      }
{ gbl/usr-flt.i       }
{ ref/grp-attr.i      }
{ gbl/prn-lib.i       }
{ gbl/getcntxt.i def  }
{ cmp/gds-list.i gds-list def "new shared" }
{ gbl/fltopend.i defproc }
{ cmp/mrk-strf.i }
{ ref/gds-matl.i }
{ str/ascorrm.i  }
{ gbl/assmatat.i }   /* Библиотека для работы с атрибутами АМ */
{ gbl/thbj-def.i }
{ ref/ass-mat.i &DEF_PROC=YES}    /* Процедуры и функции для работы с АМ (по задаче "Процент отклонения матрицы от шаблона") */

/*
cli-type    - Ограничение по группе
min-marg    - ограничения по нижним
max-marg    - количество в группе
*/

define temp-table temp_cons no-undo
    field node-code     as integer
    field upper-code    as integer
    field full-name     as character
    field min-marg      as character
    field max-marg      as character
    field cli-type      as character
index pi is unique node-code
index uc upper-code
.


define buffer buf_matrix for ub.assortment-matrix .

find first buf_matrix no-lock where
           buf_matrix.asmt-id  = p-id     and
           buf_matrix.db-num   = p-db-num no-error .


&SCOPED-DEFINE status-code STRING(buf_Matrix-goods.asmg-status)


if p-button-list <> {&buttons-for-move}
then do:
    define new shared temp-table tt-goods no-undo like goods.
    define new shared temp-table tt-clients no-undo like clients.
end.

define variable v-root-code                 as integer          no-undo.
define variable v-found-grp-num             as integer  init 0  no-undo.
define variable v-full-search-string        as character        no-undo.
define variable v-full-search-next          as logical  init no no-undo.
define variable v-full-search-start-code    as integer          no-undo.
define variable v-cli-name                  as character        no-undo.
define variable print-option as character no-undo.
define variable gds-grp-row as integer init 1 no-undo.  /* текущая запись gds-grp для перерисовки дерева */
define variable v-from-b-gds as logical no-undo .
define variable v-old-recid-list as character no-undo .
define variable v-old-recid as recid no-undo .

define variable v-current-arm-code          as character    no-undo.
define variable v-current-store-type        as character    no-undo.
define variable v-current-store-code        as integer      no-undo.
define variable v-current-host-code         as integer      no-undo.

define variable is-flora     as character no-undo .   /* для чтения параметра конфигурации */
define variable par-type     as character no-undo.    /* тип параметра конфигурации */
define variable v-obj-host-code as integer   no-undo . /* для чтения параметра конфигурации */

define variable p-sts   as integer   no-undo .
define variable p-rid-list                    as character no-undo .
define variable v-gdop-min-stock              as decimal   no-undo .
define variable v-grop-max-stock              as decimal   no-undo .
define variable v-grop-level-always-presence  as decimal   no-undo .
define variable v-grop-min-order              as decimal   no-undo .
define variable v-log as logical   no-undo .

define variable mark-str  as character no-undo.
define variable v-doc-rec as recid no-undo.
define variable filter-point as character no-undo init "Ассортиментная матрица" .
define variable filter-point0 as character no-undo init "Состав_ассортиментной_матрицы" .
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable v-type as character no-undo .
define variable p-mark as character no-undo .
define variable p-obj  as character no-undo .
define variable p-time-upd as character no-undo .
define variable p-time-cr  as character no-undo .
define variable p-status as character no-undo .
define variable gds-rec as recid no-undo .
define variable v-indicator-life-gds like  ub.gds-obj-prop.gdop-igt        column-label "ИЖТ" format "x(25)" no-undo .
define variable v-assort-min         like  ub.gds-obj-prop.gdop-assort-min column-label "AMin" format "*/ " no-undo .
define variable p-name as character no-undo .

v-err-ext = false  .
v-longchar = "" .
{ ref/clearlm.i }

define temp-table tt-gds-list no-undo like goods
field nn as integer
index by-nn nn
index by_gds-code gds-code
.
define variable varschartic like price-list.artic initial " " no-undo.
define variable ref-list    as character no-undo.
define buffer pos_assortment-matrix for ub.assortment-matrix.

&scop cant-positioning   if error-status:error then do: ~
                          find first pos_assortment-matrix no-lock where ~
                                  recid(pos_assortment-matrix) = loc-doc-rec no-error . ~
                            message ~
                            "Невозможно позиционироваться на записи AM" skip~
                            string(if avail pos_assortment-matrix ~
                                    then  substitute("Вн код AM: &1" ~
                                                    , pos_assortment-matrix.asmt-id) ~
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
&Scoped-define FRAME-NAME Dlg-grp
&Scoped-define BROWSE-NAME br-list

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp_grplib_grp buf_Matrix-goods buf_goods

/* Definitions for BROWSE br-list                                       */
&Scoped-define FIELDS-IN-QUERY-br-list temp_grplib_grp.name temp_grplib_grp.cli-type temp_grplib_grp.min-marg temp_grplib_grp.max-marg
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-list temp_grplib_grp.cli-type
&Scoped-define ENABLED-TABLES-IN-QUERY-br-list temp_grplib_grp
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-list temp_grplib_grp
&Scoped-define SELF-NAME br-list
&Scoped-define QUERY-STRING-br-list FOR EACH temp_grplib_grp NO-LOCK by temp_grplib_grp.sort-name
&Scoped-define OPEN-QUERY-br-list OPEN QUERY {&SELF-NAME} FOR EACH temp_grplib_grp NO-LOCK by temp_grplib_grp.sort-name.
&Scoped-define TABLES-IN-QUERY-br-list temp_grplib_grp
&Scoped-define FIRST-TABLE-IN-QUERY-br-list temp_grplib_grp


/* Definitions for BROWSE BROWSE-am-goods                               */
&Scoped-define FIELDS-IN-QUERY-BROWSE-am-goods mark-string(recid( buf_Matrix-goods) , p-rid-list) @ p-mark Buf_goods.artic STRING ( if Buf_goods.stts <> 0 then substring(Buf_goods.gds-name,1,15) + " <УДАЛЕН>" else Buf_goods.gds-name ) @ p-name Buf_matrix-goods.asmg-date-update STRING (buf_Matrix-goods.asmg-time-update, 'HH:MM' ) Buf_matrix-goods.asmg-db-num-update Buf_matrix-goods.asmg-date-create STRING (buf_Matrix-goods.asmg-time-create, 'HH:MM' ) v-indicator-life-gds v-assort-min Buf_matrix-goods.asmg-db-num-create {&status-int-name} @ p-status Buf_goods.grp-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-am-goods Buf_matrix-goods.asmg-db-num-update
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-am-goods Buf_matrix-goods
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-am-goods Buf_matrix-goods
&Scoped-define SELF-NAME BROWSE-am-goods
&Scoped-define QUERY-STRING-BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = {&all} or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK, ~
             FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-am-goods OPEN QUERY {&SELF-NAME} FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = {&all} or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK, ~
             FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-am-goods buf_Matrix-goods buf_goods
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-am-goods buf_Matrix-goods
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-am-goods buf_goods


/* Definitions for DIALOG-BOX Dlg-grp                                   */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dlg-grp ~
    ~{&OPEN-QUERY-br-list}~
    ~{&OPEN-QUERY-BROWSE-am-goods}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-mark b-verify b-recalc B-print ~
b-help b-expand b-expand-all fi-search b-find-by-full-name ~
b-find-by-substring b-search br-list B-add B-lookup B-chg B-del B-copy ~
RS-sts BROWSE-am-goods FILL-IN-1
&Scoped-Define DISPLAYED-OBJECTS fi-search RS-sts FILL-IN-1

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

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-copy
     LABEL "&Копировать из"
     SIZE 14 BY 1 TOOLTIP "Копировать из .... ".

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 10 BY 1 TOOLTIP "Выход"
     BGCOLOR 8 .

DEFINE BUTTON b-expand
     LABEL ">>"
     SIZE 3.5 BY 1.13.

DEFINE BUTTON b-expand-all
     LABEL ">>-->>"
     SIZE 7.5 BY 1.13.

DEFINE BUTTON b-find-by-full-name
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Продолжить до полного имени (CTRL-D)"
     BGCOLOR 8 .

DEFINE BUTTON b-find-by-substring
     LABEL "?"
     SIZE 3 BY 1 TOOLTIP "Найти подстроку во всех группах (CTRL-S)"
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 3 BY 1 TOOLTIP "Помощь"
     BGCOLOR 8 .

DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 2.5 BY 1.

DEFINE BUTTON b-recalc
     LABEL "Пе&ресчитать"
     SIZE 13.5 BY 1 TOOLTIP "Пересчитать количество товара по всем уровням"
     BGCOLOR 8 .

DEFINE BUTTON b-search
     LABEL "Поиск"
     SIZE 10 BY 1.04
     BGCOLOR 8 .

DEFINE BUTTON b-verify
     LABEL "Проверить"
     SIZE 13.5 BY 1 TOOLTIP "Проверить ограниечения по уровням групп"
     BGCOLOR 8 .

DEFINE VARIABLE fi-search AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 69.75 BY 1
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Статус:"
      VIEW-AS TEXT
     SIZE 7.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE RS-sts AS CHARACTER INITIAL "0"
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "Item 1", "0",
"Item 2", "1",
"Item 3", "2"
     SIZE 33.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-list FOR
      temp_grplib_grp SCROLLING.

DEFINE QUERY BROWSE-am-goods FOR
      buf_Matrix-goods,
      buf_goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-list Dlg-grp _FREEFORM
  QUERY br-list DISPLAY
      temp_grplib_grp.name          format "X(63)"       COLUMN-label "Наименование группы! "
      temp_grplib_grp.cli-type                           COLUMN-label "Ограничение!по группе"
      temp_grplib_grp.min-marg                           COLUMN-label "По нижним!уровням"
      temp_grplib_grp.max-marg                           COLUMN-label "Кол-во в группе!без ИЖТ на вывод"
      ENABLE
      temp_grplib_grp.cli-type
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 8.38.

DEFINE BROWSE BROWSE-am-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-am-goods Dlg-grp _FREEFORM
  QUERY BROWSE-am-goods NO-LOCK DISPLAY
      mark-string(recid( buf_Matrix-goods) , p-rid-list) @ p-mark COLUMN-LABEL "*" FORMAT "x(1)":U
      Buf_goods.artic FORMAT "X(16)":U
      STRING ( if Buf_goods.stts <> 0 then substring(Buf_goods.gds-name,1,15) + " <УДАЛЕН>"  else Buf_goods.gds-name ) @ p-name COLUMN-LABEL "Название" FORMAT "X(30)":U
      Buf_matrix-goods.asmg-date-update COLUMN-LABEL "Дата!изменения" FORMAT "99/99/99":U
      STRING (buf_Matrix-goods.asmg-time-update, 'HH:MM' ) FORMAT "x(5)":U
      Buf_matrix-goods.asmg-db-num-update COLUMN-LABEL "БД!изм" FORMAT ">>>>9":U
      Buf_matrix-goods.asmg-date-create COLUMN-LABEL "Дата!создания" FORMAT "99/99/99":U
       STRING (buf_Matrix-goods.asmg-time-create, 'HH:MM' )  FORMAT "x(5)":U
      v-indicator-life-gds
      v-assort-min COLUMN-LABEL "Acc!Min" FORMAT "*/":U
      Buf_matrix-goods.asmg-db-num-create COLUMN-LABEL "БД!соз" FORMAT ">>>>9":U
      {&status-int-name} @ p-status COLUMN-LABEL "Статус" FORMAT "x(6)":U
      Buf_goods.grp-name COLUMN-LABEL "Группа! " FORMAT "x(45)":U
  ENABLE
      Buf_matrix-goods.asmg-db-num-update
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 97 BY 8.25 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dlg-grp
     b-exit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 11
     b-verify AT ROW 1 COL 66 WIDGET-ID 22
     b-recalc AT ROW 1 COL 79.88 WIDGET-ID 14
     B-print AT ROW 1 COL 94 WIDGET-ID 12
     b-help AT ROW 1 COL 96.5
     b-expand AT ROW 2.08 COL 1.63
     b-expand-all AT ROW 2.08 COL 5.13
     fi-search AT ROW 2.08 COL 13.38 NO-LABEL
     b-find-by-full-name AT ROW 2.08 COL 83.38
     b-find-by-substring AT ROW 2.08 COL 86.38
     b-search AT ROW 2.08 COL 89.38
     br-list AT ROW 3.38 COL 1.88
     B-add AT ROW 12.5 COL 2 WIDGET-ID 2
     B-lookup AT ROW 12.5 COL 12 WIDGET-ID 10
     B-chg AT ROW 12.5 COL 22 WIDGET-ID 4
     B-del AT ROW 12.5 COL 32 WIDGET-ID 8
     B-copy AT ROW 12.5 COL 42.13 WIDGET-ID 6
     RS-sts AT ROW 12.5 COL 65.5 NO-LABEL WIDGET-ID 18
     BROWSE-am-goods AT ROW 13.58 COL 2 WIDGET-ID 100
     FILL-IN-1 AT ROW 12.5 COL 57.5 NO-LABEL WIDGET-ID 16
     SPACE(35.00) SKIP(8.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Ассортиментная Матрица по группам товаров".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_goods B "?" ? ub goods
      TABLE: buf_Matrix-goods B "?" ? ub assortment-matrix-goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dlg-grp
   FRAME-NAME                                                           */
/* BROWSE-TAB br-list b-search Dlg-grp */
/* BROWSE-TAB BROWSE-am-goods RS-sts Dlg-grp */
ASSIGN
       FRAME Dlg-grp:SCROLLABLE       = FALSE
       FRAME Dlg-grp:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN fi-search IN FRAME Dlg-grp
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME Dlg-grp
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-list
/* Query rebuild information for BROWSE br-list
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp_grplib_grp NO-LOCK by temp_grplib_grp.sort-name.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-list */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-am-goods
/* Query rebuild information for BROWSE BROWSE-am-goods
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_Matrix-goods
      WHERE buf_Matrix-goods.asmt-id = p-id and
            buf_Matrix-goods.db-num  = p-db-num and
            (RS-sts = {&all} or buf_matrix-goods.asmg-status = int(RS-sts))
            NO-LOCK,
      FIRST buf_goods OF buf_Matrix-goods
      WHERE temp_grplib_grp.level = 0 OR
       ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _TblOptList       = ", FIRST"
     _Where[1]         = "buf_Matrix-goods.asmt-id = p-id and
buf_Matrix-goods.db-num  = p-db-num
"
     _Where[2]         = "temp_grplib_grp.level = 0 OR ( buf_goods.grp-name begins temp_grplib_grp.full-name )"
     _Query            is OPENED
*/  /* BROWSE BROWSE-am-goods */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dlg-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dlg-grp Dlg-grp
ON ENDKEY OF FRAME Dlg-grp /* Ассортиментная Матрица по группам товаров */
DO:
    run gbl/markqwa.p (
                           input b-mark:visible
                          , input p-recid-list) no-error.
    if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dlg-grp Dlg-grp
ON WINDOW-CLOSE OF FRAME Dlg-grp /* Ассортиментная Матрица по группам товаров */
DO:
  apply "end-error":U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dlg-grp
ON CHOOSE OF B-add IN FRAME Dlg-grp /* Добавить */
DO:
  define variable loc#log as logical no-undo.
  define variable loc-doc-rec as recid no-undo .

if  buf_matrix.asmt-status = 1  then do:
    message "Добавлять можно  в  АССОРТИМЕНТНУЮ МАТРИЦУ в статусе тек."
    view-as alert-box information .
    return no-apply.
end.
run ver-db no-error .
if error-status :error then return no-apply .

/* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_assort-matr-gds_add-def':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-log
  }
 if not v-log then return no-apply .
  run save-attr in this-procedure .
  run proc-add in this-procedure (output loc-doc-rec ) no-error  .
  if error-status :error then DO:
     message
  error-status :get-message(1)
  return-value
  view-as alert-box error
  .
     RETURN NO-APPLY.
  END.

  if loc-doc-rec <> ? THEN DO:
    {&OPEN-QUERY-BROWSE-am-goods}
  END.
  run recalc-add.
  run recalc-marg-ass.
  apply "entry" to BROWSE-am-goods in frame {&frame-name}.
  apply "value-changed" to BROWSE-am-goods in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dlg-grp
ON CHOOSE OF B-chg IN FRAME Dlg-grp /* Изменить */
DO:
   define variable loc#log as logical no-undo.
   define variable loc-doc-rec as recid no-undo .

if not available Buf_matrix-goods then return no-apply.

if  Buf_matrix-goods.asmg-status = 1  then do:
    message "Корректировать можно только запись в статусе  ТЕК."
    view-as alert-box information .
    return no-apply.
end.

run ver-db no-error .
if error-status :error then return no-apply .

if  buf_matrix.asmt-status = 1  then do:
    message "Корректировать можно  в  АССОРТИМЕНТНОЙ МАТРИЦЕ в статусе тек."
    view-as alert-box information .
    return no-apply.
end.

assign
loc-doc-rec = recid(Buf_matrix-goods).

 /* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_assort-matr-gds_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-log
  }
 if not v-log then return no-apply .

   run ref/gds-mati.w
    (  input parParentProc
      ,input {&update}
      ,input Buf_matrix-goods.asmt-id
      ,input Buf_matrix-goods.db-num
      ,input-output loc-doc-rec
    ) no-error
   .
   if loc-doc-rec <> ? THEN DO:

       {&OPEN-QUERY-BROWSE-am-goods}
       reposition BROWSE-am-goods to recid loc-doc-rec no-error.
       {&cant-positioning}
   END.

   apply "entry" to BROWSE-am-goods in frame {&frame-name}.
   apply "value-changed" to BROWSE-am-goods in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-copy Dlg-grp
ON CHOOSE OF B-copy IN FRAME Dlg-grp /* Копировать из */
DO:

define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .

if  buf_matrix.asmt-status = 1  then do:
    message "Добавлять можно в АССОРТИМЕНТНУЮ МАТРИЦУ в статусе тек."
    view-as alert-box information .
    return no-apply.
end.
run ver-db no-error .
if error-status :error then return no-apply .

/* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_assort-matr-gds_add-def':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-log
  }
 if not v-log then return no-apply .

 run save-alla in this-procedure  .

  do transaction :
    run proc-copy in this-procedure (output loc-doc-rec ) no-error  .
     if error-status :error then DO:
        message
    error-status :get-message(1)
    return-value .
        RETURN NO-APPLY.
     END.
   end.
  {&OPEN-QUERY-br-list}
  if loc-doc-rec <> ? THEN DO:
       {&OPEN-QUERY-BROWSE-am-goods}
  END.

  apply "entry" to BROWSE-am-goods in frame {&frame-name}.
  apply "value-changed" to BROWSE-am-goods in frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dlg-grp
ON CHOOSE OF B-del IN FRAME Dlg-grp /* Удалить */
DO:
run save-attr in this-procedure .
define variable is-many as logical   no-undo .
is-many = false .
if  buf_matrix.asmt-status = 1  then do:
    message "Корректировать и удалять можно  в  АССОРТИМЕНТНОЙ МАТРИЦЕ в статусе тек."
    view-as alert-box information .
    return no-apply.
end.
run ver-db no-error .
if error-status :error then return no-apply .

if num-entries(p-rid-list) > 0 then do:
   message "Удалять выделенные записи ?"
   view-as alert-box question
   Buttons yes-no update v-logq as log.
   if v-logq = false then return .
   is-many = true .
end.
  run proc-b-del in this-procedure ( p-rid-list , is-many ) no-error.
  if error-status:error then return no-apply.
  run recalc-add.
  run recalc-marg-ass.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dlg-grp
ON CHOOSE OF b-exit IN FRAME Dlg-grp /* Выход */
DO:

define variable  v-str as character no-undo .
define variable v-i as integer   no-undo .

for each temp_grplib_grp :
    find first temp_cons where temp_cons.node-code = temp_grplib_grp.node-code no-error .
        if available temp_cons then do:
        if temp_cons.max-marg <>  temp_grplib_grp.max-marg then do:
        assign
            temp_cons.full-name  = temp_grplib_grp.full-name
            temp_cons.node-code  = temp_grplib_grp.node-code
            temp_cons.upper-code = temp_grplib_grp.upper-code
            temp_cons.min-marg   = temp_grplib_grp.min-marg
            temp_cons.max-marg   = temp_grplib_grp.max-marg
            temp_cons.cli-type   = temp_grplib_grp.cli-type
        .
        end.
        end.
end.


v-str = "".
v-i =0.
for each temp_cons where int(temp_cons.cli-type) < int(temp_cons.min-marg)
 and int(temp_cons.cli-type) <> ?
 and temp_cons.cli-type <> ""
 and int(temp_cons.min-marg) <> ?
:
  v-i = v-i + 1.
  v-str = v-str + trim(temp_cons.full-name) + ": ограничение-" + temp_cons.cli-type + ", должно быть >= " + temp_cons.min-marg + "." + {&new-line} .
end.

for each temp_cons where int(temp_cons.cli-type) < int(temp_cons.max-marg)
 and int(temp_cons.cli-type) <> ?
 and temp_cons.cli-type <> ""
 and int(temp_cons.max-marg) <> ?
:
  v-i = v-i + 1.
  v-str = v-str + trim(temp_cons.full-name) + ": ограничение-" + temp_cons.cli-type + ", а товара в группе-" + temp_cons.max-marg + "." + {&new-line} .
end.

if v-i <> 0 then do:
    message substitute("Внимание ! Ограничения по Матрице  &1 назначены некорректно !!!", buf_matrix.asmt-name ) view-as alert-box error .
    run gbl/notes.w ({&lookup},input-output v-str) .
    return no-apply .
end.

find first temp_grplib_grp no-error .
    define variable v-gds-grp-recid     as recid             no-undo.
    run get-current-recid in this-procedure (
          input temp_grplib_grp.node-code
        , output v-gds-grp-recid
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не найдена группа для восстановления"
          skip "предыдущего состояния справочника групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    run gbl/markqwa.p (
            input b-mark:visible
          , input p-recid-list) no-error.
    if error-status:error then return no-apply.
    assign
        gds-grp-row  = v-gds-grp-recid
        p-recid-list = ""
    .
    assign
    v-uf-List_ = (if gds-grp-row = ? then {&question-mark} else string(gds-grp-row))
    .
    run uf-set in this-procedure(
        input  {&uf-gds-grp-p}
        ,input  g#userid
        ,input v-uf-List_
        ,input v-uf-Naim
        ,input v-uf-print-graft
        ,input v-uf-sort-gr
        ,input v-uf-type-price
        ,input v-uf-type-val
    )  no-error .

/* Если корректировали Ограничения */
if temp_grplib_grp.cli-type:read-only in browse br-list = false then do:
    run save-alla in this-procedure  .
  end.
  apply "WINDOW-CLOSE" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-expand
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-expand Dlg-grp
ON CHOOSE OF b-expand IN FRAME Dlg-grp /* >> */
DO:
    if temp_grplib_grp.node-code = v-root-code
    then do:
        run collapse-all-on-first-level in this-procedure no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка операции с деревом групп."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
                trim(error-status :get-message(4))
                trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
    if temp_grplib_grp.mark <> {&closed-noterminal-grp-mark}
    and temp_grplib_grp.mark <> {&opened-noterminal-grp-mark}
    then do:
        return no-apply.
    end.

    run expand-or-collapse-item in this-procedure no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка операции с деревом групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    {&OPEN-QUERY-BROWSE-am-goods}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-expand-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-expand-all Dlg-grp
ON CHOOSE OF b-expand-all IN FRAME Dlg-grp /* >>-->> */
DO:
    { gbl/working.i }
    run expand-all-from-current in this-procedure (
        input temp_grplib_grp.node-code
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка при раскрытии дерева групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        { gbl/stopwork.i }
        undo, return no-apply .
    end.
    { gbl/stopwork.i }
    {&OPEN-QUERY-BROWSE-am-goods}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-find-by-full-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-find-by-full-name Dlg-grp
ON CHOOSE OF b-find-by-full-name IN FRAME Dlg-grp /* + */
DO:
    define variable v-new-name as character no-undo.

    run grplib-expand-name in this-procedure (
          input fi-search :screen-value
        , output v-new-name
    ) no-error.
    if error-status :error
    then do:
        message return-value.
        undo, return no-apply.
    end.
    if v-new-name = ""
    then do:
        message
            "Не найдена группа с полным именем, начинающимся на"
            skip "'" + fi-search :screen-value + "'"
        view-as alert-box information.
        assign
            v-new-name = fi-search :screen-value
        .
    end.
    assign
        fi-search :screen-value  = right-trim( v-new-name, {&delim-grp} )
        fi-search :cursor-offset = length( v-new-name ) + 1
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-find-by-full-name Dlg-grp
ON LEAVE OF b-find-by-full-name IN FRAME Dlg-grp /* + */
DO:
    assign
        v-found-grp-num  = 0
        b-search :label = "Поиск"
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-find-by-substring
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-find-by-substring Dlg-grp
ON CHOOSE OF b-find-by-substring IN FRAME Dlg-grp /* ? */
DO:
    define variable v-new-name      as character    no-undo.
    define variable v-new-code      as integer      no-undo.
    define variable v-err-message   as character    no-undo.

    if v-full-search-next = no
    then do:
        assign
            v-full-search-string     = fi-search :screen-value
            v-full-search-next       = yes
            v-full-search-start-code = 0
        .
    end.
    run grplib-analyze-grp-name in this-procedure (
          input v-full-search-string
        , input -1
        , output v-err-message
    ).
    if v-err-message = "":U
    then do:
        { gbl/working.i }
        run grplib-find-by-substring in this-procedure (
            input v-full-search-start-code
            , input v-full-search-string
            , output v-new-code
            , output v-new-name
        ) no-error.
        if error-status :error
        then do:
            { gbl/stopwork.i }
            message return-value.
            undo, return no-apply.
        end.
        { gbl/stopwork.i }
        if v-new-code = 0
        then do:
            message
                skip "Не найдена строка '" v-full-search-string "' в имени группы."
            view-as alert-box information
            title "Поиск завершен".
            assign
                v-new-name               = fi-search :screen-value
                v-full-search-string     = ""
                v-full-search-next       = no
                v-full-search-start-code = 0
            .
        end.
        else do:
            assign
                v-full-search-start-code = v-new-code
            .
        end.
        assign
            fi-search :screen-value  = right-trim( v-new-name, {&delim-grp} )
            fi-search :cursor-offset = length( v-new-name ) + 1
        .
    end.        /* if v-err-message = "":U */
    else do:
        message
            v-err-message
            skip(1)
            "Поиск в названиях групп производится по подстроке,"
            skip "введённой в поле названия группы."
        view-as alert-box information.
    end.        /* if v-err-message <> "":U */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-find-by-substring Dlg-grp
ON LEAVE OF b-find-by-substring IN FRAME Dlg-grp /* ? */
DO:
    assign
        v-found-grp-num  = 0
        b-search :label = "Поиск"
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dlg-grp
ON CHOOSE OF B-lookup IN FRAME Dlg-grp /* Просмотр */
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available Buf_matrix-goods then return no-apply.

assign
loc-doc-rec = recid(Buf_matrix-goods).


   run ref/gds-mati.w
    (  input parParentProc
      ,input {&LOOKUP}
      ,input Buf_matrix-goods.asmt-id
      ,input Buf_matrix-goods.db-num
      ,input-output loc-doc-rec
      ) no-error   .
   apply "entry" to BROWSE-am-goods in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dlg-grp
ON CHOOSE OF b-mark IN FRAME Dlg-grp /* * */
DO:
/* */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dlg-grp
ON CHOOSE OF B-print IN FRAME Dlg-grp /* Печать */
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-recalc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-recalc Dlg-grp
ON CHOOSE OF b-recalc IN FRAME Dlg-grp /* Пересчитать */
DO:
define VARIABLE v-old-grp as integer   no-undo .
define VARIABLE v-new-grp as integer   no-undo .
define VARIABLE v-ok1      as logical    no-undo .
message "Запустить утилиту пересчета ассортимента по каждой группе ? Это займет время."
 view-as alert-box question
       BUTTONS yes-no
      update v-ok as logical.
  if not v-ok then return .
   run utl/uassmgrp.p ( v-old-grp, v-new-grp, p-id , p-db-num, output v-ok1 ) no-error.
   if error-status :error then message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     ""
     view-as alert-box error
   .
run recalc-marg-ass.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-search
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-search Dlg-grp
ON CHOOSE OF b-search IN FRAME Dlg-grp /* Поиск */
DO:
    define variable v-found    as logical      no-undo.

    run find-grp-in-browse in this-procedure (
          input fi-search :screen-value
        , output v-found
    ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка поиска группы в списке."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply.
    end.
    if v-found = no
    then do:
        message
          skip "Группа не найдена."
        view-as alert-box information.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-search Dlg-grp
ON LEAVE OF b-search IN FRAME Dlg-grp /* Поиск */
DO:
    assign
        v-found-grp-num  = 0
        b-search :label = "Поиск"
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-verify
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-verify Dlg-grp
ON CHOOSE OF b-verify IN FRAME Dlg-grp /* Проверить */
DO:

message "Запутить утилиту проверки проставленных ограничений по всем уровням ? "
 view-as alert-box question
       BUTTONS yes-no
      update v-ok as logical.
  if not v-ok then return .

/* 4444 */
define variable v-str as character no-undo .
define variable v-i as integer   no-undo .

v-str = "" .
v-i   = 0  .

for each temp_grplib_grp :
    find first temp_cons where temp_cons.node-code = temp_grplib_grp.node-code no-error .
        if not available temp_cons then create temp_cons.
        assign
            temp_cons.full-name  = temp_grplib_grp.full-name
            temp_cons.node-code  = temp_grplib_grp.node-code
            temp_cons.upper-code = temp_grplib_grp.upper-code
            temp_cons.min-marg   = temp_grplib_grp.min-marg
            temp_cons.max-marg   = temp_grplib_grp.max-marg
            temp_cons.cli-type   = temp_grplib_grp.cli-type
        .
end.


  for each temp_cons where
          int(temp_cons.cli-type) < int(temp_cons.min-marg)
      and int(temp_cons.cli-type) <> ?
      and temp_cons.cli-type <> ""
      and int(temp_cons.min-marg) <> ?
      :
        v-i = v-i + 1.
        v-str = v-str + trim(temp_cons.full-name) + ": ограничение-" + temp_cons.cli-type + " должно быть >= " + temp_cons.min-marg + {&new-line} .
  end.

for each temp_cons where
        int(temp_cons.cli-type) < int(temp_cons.max-marg)
    and int(temp_cons.cli-type) <> ?
    and temp_cons.cli-type <> ""
    and int(temp_cons.max-marg) <> ?
    :
  v-i = v-i + 1.
  v-str = v-str + trim(temp_cons.full-name) + ": ограничение-" + temp_cons.cli-type + ", а товара в группе - " + temp_cons.max-marg + "." + {&new-line} .
end.


   if v-i > 0 then
   run gbl/notes.w ({&lookup},input-output v-str) .
   else message "Все ОК!" view-as alert-box information .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-list
&Scoped-define SELF-NAME br-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON + OF br-list IN FRAME Dlg-grp
DO:
    if temp_grplib_grp.mark = {&closed-noterminal-grp-mark}
    then do:
        run expand-item in this-procedure ( input temp_grplib_grp.node-code, input yes ) no-error .
        if error-status :error
        then do:
            message
              vss-workfile vss-revision vss-description
              skip "Не удалось раскрыть подуровни группы."
              skip return-value
              skip trim(error-status :get-message(1))
                   trim(error-status :get-message(2))
                   trim(error-status :get-message(3))
                   trim(error-status :get-message(4))
                   trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.

END.

/*-------------------------------------------------------*/
on leave of temp_grplib_grp.cli-type in browse br-list do :
  define variable i as integer   no-undo .
  i = int (int (temp_grplib_grp.cli-type:screen-value in browse br-list ))  no-error .
  if error-status :error then return no-apply .
  if i < 0 then return no-apply .
  if i = 0 and lookup(temp_grplib_grp.cli-type:screen-value in browse br-list , "+,-,*" ) > 0 then return no-apply .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_assort-matr-grp_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-log
  }
 if not v-log then do:
    temp_grplib_grp.cli-type:read-only in browse br-list = true .
    return no-apply .
 end.

   define variable loc#log as logical   no-undo .
    temp_grplib_grp.cli-type = temp_grplib_grp.cli-type:screen-value in browse {&browse-name} .

    if temp_grplib_grp.cli-type <> ? and
       temp_grplib_grp.cli-type <> ""  and
       int(temp_grplib_grp.min-marg) <> 0 and
           temp_grplib_grp.min-marg  <> ? and
           temp_grplib_grp.min-marg  <> "" and
       int(temp_grplib_grp.cli-type) < int(temp_grplib_grp.min-marg) then do:
         message substitute(" Ограничение должно быть не меньше ограничения по нижним уровням &1" ,temp_grplib_grp.min-marg ) .
         return no-apply.
       end.

      find first temp_cons where temp_cons.node-code = temp_grplib_grp.node-code no-error .
      assign
          temp_cons.cli-type  = temp_grplib_grp.cli-type
          temp_cons.full-name  = temp_grplib_grp.full-name
      .
    loc#log = BR-list:select-focused-row( ) IN FRAME {&FRAME-NAME}.
    loc#log = BR-list:refresh() .

/* Запись ограничения */
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
find first buf_gds-grp-obj-attr exclusive-lock where
            buf_gds-grp-obj-attr.attr-code = {&ggoattr-LimAssMat} and
            buf_gds-grp-obj-attr.obj-type  = string(p-id) and
            buf_gds-grp-obj-attr.obj-code  = p-db-num and
            buf_gds-grp-obj-attr.host-code = 0 and
            buf_gds-grp-obj-attr.node-code = temp_grplib_grp.node-code no-error .
if not available buf_gds-grp-obj-attr then do:
    create buf_gds-grp-obj-attr.
          assign
            buf_gds-grp-obj-attr.attr-code = {&ggoattr-LimAssMat}
            buf_gds-grp-obj-attr.obj-type  = string(p-id)
            buf_gds-grp-obj-attr.obj-code  = p-db-num
            buf_gds-grp-obj-attr.host-code = 0
            buf_gds-grp-obj-attr.node-code = temp_grplib_grp.node-code
            .
 end.
 assign
    buf_gds-grp-obj-attr.attr-value = temp_grplib_grp.cli-type
    .
run recalc-lim.

end.

on return of temp_grplib_grp.cli-type in browse br-list do :
  define variable loc#log as logical   no-undo .
  define variable i as integer   no-undo .
  i = int (int (temp_grplib_grp.cli-type:screen-value in browse br-list))  no-error .
  if error-status :error then return no-apply .
  if i < 0 then return no-apply .
  if i = 0 and lookup(temp_grplib_grp.cli-type:screen-value in browse br-list , "+,-,*" ) > 0 then return no-apply .
    temp_grplib_grp.cli-type = temp_grplib_grp.cli-type:screen-value in browse {&browse-name} .
    if temp_grplib_grp.cli-type <> ? and
       temp_grplib_grp.cli-type <> ""  and
       int(temp_grplib_grp.min-marg) <> 0 and
           temp_grplib_grp.min-marg  <> ? and
           temp_grplib_grp.min-marg  <> "" and
       int(temp_grplib_grp.cli-type) < int(temp_grplib_grp.min-marg) then do:
         message substitute(" Ограничение должно быть не меньше ограничения по нижним уровням &1" ,temp_grplib_grp.min-marg ) .
         return no-apply.
       end.

      find first temp_cons where temp_cons.node-code = temp_grplib_grp.node-code no-error .
      assign
          temp_cons.cli-type  = temp_grplib_grp.cli-type
          temp_cons.full-name  = temp_grplib_grp.full-name
      .
/* Запись ограничения */
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
find first buf_gds-grp-obj-attr exclusive-lock where
            buf_gds-grp-obj-attr.attr-code = {&ggoattr-LimAssMat} and
            buf_gds-grp-obj-attr.obj-type  = string(p-id) and
            buf_gds-grp-obj-attr.obj-code  = p-db-num and
            buf_gds-grp-obj-attr.host-code = 0 and
            buf_gds-grp-obj-attr.node-code = temp_grplib_grp.node-code no-error .
if not available buf_gds-grp-obj-attr then do:
    create buf_gds-grp-obj-attr.
          assign
            buf_gds-grp-obj-attr.attr-code = {&ggoattr-LimAssMat}
            buf_gds-grp-obj-attr.obj-type  = string(p-id)
            buf_gds-grp-obj-attr.obj-code  = p-db-num
            buf_gds-grp-obj-attr.host-code = 0
            buf_gds-grp-obj-attr.node-code = temp_grplib_grp.node-code
            .
 end.
 assign
    buf_gds-grp-obj-attr.attr-value = temp_grplib_grp.cli-type
    .
  run recalc-lim.
    loc#log = BR-list:refresh() IN FRAME {&FRAME-NAME}.
    loc#log = BR-list:select-next-row( ) .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON - OF br-list IN FRAME Dlg-grp
DO:
    if temp_grplib_grp.mark = {&opened-noterminal-grp-mark}
    then do:
        run collapse-item in this-procedure ( input temp_grplib_grp.node-code, input yes ) no-error .
        if error-status :error
        then do:
            message
              vss-workfile vss-revision vss-description
              skip "Не удалось закрыть подуровни группы."
              skip return-value
              skip trim(error-status :get-message(1))
                   trim(error-status :get-message(2))
                   trim(error-status :get-message(3))
                   trim(error-status :get-message(4))
                   trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON END OF br-list IN FRAME Dlg-grp
DO:
    define variable v-row-amount     as integer           no-undo.
    run get-row-amount in this-procedure ( output v-row-amount ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка при подсчете строк списка групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    reposition br-list to row v-row-amount.
    {&OPEN-QUERY-BROWSE-am-goods}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON HOME OF br-list IN FRAME Dlg-grp
DO:
    reposition br-list to row 1.
    {&OPEN-QUERY-BROWSE-am-goods}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON MOUSE-SELECT-DBLCLICK OF br-list IN FRAME Dlg-grp
DO:
 if temp_grplib_grp.mark <> {&closed-noterminal-grp-mark}
    and temp_grplib_grp.mark <> {&opened-noterminal-grp-mark}
    then do:
        return no-apply.
    end.
    run expand-or-collapse-item in this-procedure no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка операции с деревом групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
{&OPEN-QUERY-BROWSE-am-goods}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON RETURN OF br-list IN FRAME Dlg-grp
DO:
    if temp_grplib_grp.mark <> {&closed-noterminal-grp-mark}
    and temp_grplib_grp.mark <> {&opened-noterminal-grp-mark}
    then do:
        return no-apply.
    end.

    run expand-or-collapse-item in this-procedure no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка операции с деревом групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON ROW-DISPLAY OF br-list IN FRAME Dlg-grp
DO:
  if int(temp_grplib_grp.cli-type) < int(temp_grplib_grp.min-marg)
      and int(temp_grplib_grp.cli-type) <> ?
      and temp_grplib_grp.cli-type <> ""
      and int(temp_grplib_grp.min-marg) <> ?
  then do:
    temp_grplib_grp.cli-type:bgcolor in browse  br-list = 12 /* red */ .
  end.
  else do:
    temp_grplib_grp.cli-type:bgcolor in browse  br-list = ? .
  end.
  if int(temp_grplib_grp.cli-type) < int(temp_grplib_grp.max-marg)
      and int(temp_grplib_grp.cli-type) <> ?
      and temp_grplib_grp.cli-type <> ""
      and int(temp_grplib_grp.max-marg) <> ?
  then do:
    temp_grplib_grp.max-marg:bgcolor in browse  br-list = 11 /* blue */ .
  end.
  else do:
    temp_grplib_grp.max-marg:bgcolor in browse  br-list = ? .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON VALUE-CHANGED OF br-list IN FRAME Dlg-grp
DO:
   {&OPEN-QUERY-BROWSE-am-goods}

    if temp_grplib_grp.level <> 0
    then do:
        assign
            fi-search :screen-value = right-trim( temp_grplib_grp.full-name, {&delim-grp} )
        .
    end.
    if error-status :error
    then do:
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-am-goods
&Scoped-define SELF-NAME BROWSE-am-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-am-goods Dlg-grp
ON ROW-DISPLAY OF BROWSE-am-goods IN FRAME Dlg-grp
DO:
      if available buf_matrix-goods then do:
      { gbl/gdsobjpr.i
        buf_matrix.obj-type
        buf_matrix.obj-code
        ?
        ?
        ?
        buf_Matrix-goods.gds-code
        v-assort-min
        v-indicator-life-gds
        v-gdop-min-stock
        v-grop-max-stock
        v-grop-level-always-presence
        v-grop-min-order
       }
        case v-indicator-life-gds :
            when {&ass-izd-new} then do:
              v-indicator-life-gds:bgcolor  in browse BROWSE-am-goods   = 14 . /* желтый */
            end.
            when {&ass-izd-del} then do:
              v-indicator-life-gds:bgcolor  in browse BROWSE-am-goods   = 12 .  /* красный */
            end.
            when {&ass-izd-spec} then do:
              v-indicator-life-gds:bgcolor  in browse BROWSE-am-goods   = 8 .  /* серый */
            end.

        end case.
        if buf_goods.stts <> 0 then p-name:fgcolor  in browse BROWSE-am-goods   = 12 .  /* красный */
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-search
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-search Dlg-grp
ON CTRL-D OF fi-search IN FRAME Dlg-grp
DO:
    define variable v-new-name as character no-undo.

    run grplib-expand-name in this-procedure (
        input fi-search :screen-value
        , output v-new-name
    ) no-error.
    if error-status :error
    then do:
        message return-value.
        undo, return no-apply.
    end.
    if v-new-name = ""
    then do:
        message
            "Не найдена группа с полным именем, начинающимся на"
            skip "'" + fi-search :screen-value + "'"
        view-as alert-box information.
        assign
            v-new-name = fi-search :screen-value
        .
    end.
    assign
        fi-search :screen-value  = right-trim( v-new-name, {&delim-grp} )
        fi-search :cursor-offset = length( v-new-name ) + 1
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-search Dlg-grp
ON CTRL-S OF fi-search IN FRAME Dlg-grp
DO:
    define variable v-new-name as character no-undo.
    define variable v-new-code as integer   no-undo.

    if v-full-search-next = no
    then do:
        assign
            v-full-search-string     = fi-search :screen-value
            v-full-search-next       = yes
            v-full-search-start-code = 0
        .
    end.
    { gbl/working.i }
    run grplib-find-by-substring in this-procedure (
                          input v-full-search-start-code
                        , input v-full-search-string
                        , output v-new-code
                        , output v-new-name
    ) no-error.
    if error-status :error
    then do:
        { gbl/stopwork.i }
        message return-value.
        undo, return no-apply.
    end.
    { gbl/stopwork.i }
    if v-new-code = 0
    then do:
        message
            skip "Не найдена строка '" v-full-search-string "' в имени группы."
        view-as alert-box information
        title "Поиск завершен".
        assign
            v-new-name               = fi-search :screen-value
            v-full-search-string     = ""
            v-full-search-next       = no
            v-full-search-start-code = 0
        .
    end.
    else do:
        assign
            v-full-search-start-code = v-new-code
        .
    end.
    assign
        fi-search :screen-value  = right-trim( v-new-name, {&delim-grp} )
        fi-search :cursor-offset = length( v-new-name ) + 1
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-search Dlg-grp
ON LEAVE OF fi-search IN FRAME Dlg-grp
DO:
    if fi-search :screen-value <> v-full-search-string
    then do:
        assign
            v-full-search-string     = ""
            v-full-search-next       = no
            v-full-search-start-code = 0
        .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-search Dlg-grp
ON RETURN OF fi-search IN FRAME Dlg-grp
DO:
    define variable v-found    as logical      no-undo.

    if fi-search :screen-value = ""
    or fi-search :screen-value = ?
    then do:        /* Ничего не делать, если строка поиска пуста. */
        return no-apply.
    end.
    run find-grp-in-browse in this-procedure (
          input fi-search :screen-value
        , output v-found
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка поиска группы."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-found = no
    then do:
        message
          skip "Группа не найдена."
        view-as alert-box information.
    end.
    apply "ENTRY" to b-search in frame {&frame-name}.
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-sts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-sts Dlg-grp
ON VALUE-CHANGED OF RS-sts IN FRAME Dlg-grp
DO:
  assign rs-sts.
  {&OPEN-QUERY-BROWSE-am-goods}
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-list
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dlg-grp


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i &disable_diasize=true }

{ gbl/diasize.i &browse-name=br-list }

run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse BROWSE-am-goods:handle
  ) .
run diasize_init in this-procedure .

{ gbl/f2.i {&BROWSE-name} goods-recid init-gds-rec parParentProc }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

Buf_matrix-goods.asmg-db-num-update:read-only in browse BROWSE-am-goods = true .
v-indicator-life-gds:resizable in browse BROWSE-am-goods = true .
p-name:resizable  in browse BROWSE-am-goods = true .
v-indicator-life-gds:width in browse BROWSE-am-goods = 8 .
{ gbl/getcntxt.i get }
ASSIGN
rs-sts:RADIO-BUTTONS IN FRAME {&FRAME-NAME}
    = "Текущие&+" + {&comma-char} +  {&current-status-int} + {&comma-char} +
      "Все&!" + {&comma-char} + {&all} + {&comma-char} +
      "Удаленные&-" + {&comma-char} + {&deleted-status-int}
.
rs-sts = {&current-status-int} .

display RS-sts WITH FRAME Dlg-grp.
enable  RS-sts WITH FRAME Dlg-grp.

run ver-db1 in this-procedure .
run ver-attr in this-procedure .

frame {&frame-name}:TITLE = frame {&frame-name}:TITLE + " " + buf_matrix.asmt-name .

    if p-current-obj-code = 0
    then do:
       assign
       v-current-store-type = v-cntxt-obj-type
       v-current-store-code = v-cntxt-obj-code
       v-current-host-code = v-cntxt-host-code-obj
       .
    end.
    else do:
        assign
            v-current-store-type = p-current-obj-type
            v-current-store-code = p-current-obj-code
        .
        { gbl/hostcode.i
            v-current-store-type
            v-current-store-code
            v-current-host-code
        }
    end.
    run grplib-get-parameters in this-procedure (
          input v-current-store-type
        , input v-current-store-code
    ) no-error.
    if error-status :error
    then do:
        message
            "Ошибка чтения параметров для списка групп товаров."
            skip (1)
            "Для параметров списка будут приняты значения по умолчанию."
        view-as alert-box warning.
    end.
    run UI-on-0 in this-procedure no-error .
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка при загрузке дерева групп."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
                trim(error-status :get-message(4))
                trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    {&OPEN-QUERY-BROWSE-am-goods}
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-grp Dlg-grp
PROCEDURE add-grp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  input p-node-code - код группы для добавления подгруппы.
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.

    define variable v-gds-grp-recid     as recid    no-undo.
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    define variable v-have-goods        as logical  no-undo.
    define variable v-have-rights       as logical       no-undo.

    define buffer buf_gds-grp           for gds-grp.
    define buffer buf_temp_grplib_grp   for temp_grplib_grp.

    run check-rights-for-change-grp in this-procedure (
        input  p-node-code
        ,output v-have-rights
    ) no-error.
    if error-status :error
    or v-have-rights = no
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Нет прав на изменение справочника групп товаров."
          skip "Удаление группы невозможно."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    run grplib-have-goods in this-procedure (
          input p-node-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        undo, return error "add-grp: Ошибка определения наличия товаров в группе." + {&new-line} + return-value.
    end.
    if v-have-goods = yes
    then do:
        message "В данной группе есть товары. Добавить в нее подгруппу,"
                "включающую эти товары ?"
        view-as alert-box question
        buttons OK-Cancel
        update v-yesno as logical.
        if v-yesno = no
        then do:
            apply "entry" to br-list in frame {&frame-name}.
            return no-apply.
        end.
    end.
    find first buf_temp_grplib_grp
         where buf_temp_grplib_grp.node-code = p-node-code
    no-error .
    if not available buf_temp_grplib_grp
    then do:
        undo, return error "add-grp: Не найдена группа в browse.".
    end.
    if buf_temp_grplib_grp.mark = {&closed-noterminal-grp-mark}
    then do:
        run expand-item in this-procedure ( input p-node-code, input no ) no-error.
        if error-status :error
        then do:
            undo, return error "add-grp: Не удается раскрыть группу.".
        end.
    end.
    run ref/g-grp-f.w (
          input parparentproc
        , input v-current-store-type
        , input v-current-store-code
        , input {&add-def}
        , input p-node-code
        , input-output v-gds-grp-recid
    ) no-error .
    if v-gds-grp-recid = ?
    then do:
        apply "entry" to br-list in frame {&frame-name}.
        return no-apply.
    end.
    find first buf_gds-grp
         where recid ( buf_gds-grp ) =  v-gds-grp-recid
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "add-grp: Ошибка добавления группы.".
    end.
    run create-new-line in this-procedure (
          input buf_gds-grp.node-code
        , input buf_gds-grp.upper-code
        , input buf_temp_grplib_grp.level + 1
        , input buf_gds-grp.is-term
        , input buf_gds-grp.node-name
        , input buf_gds-grp.increase-pc
        , input buf_gds-grp.calc-method
        , input buf_temp_grplib_grp.full-name
        , input buf_temp_grplib_grp.sort-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "add-grp: Ошибка добавления строки в список групп.".
    end.
    if buf_temp_grplib_grp.level > 0
    then do:
        assign
            buf_temp_grplib_grp.mark = {&opened-noterminal-grp-mark}
            buf_temp_grplib_grp.name = substring( buf_temp_grplib_grp.name, 1, buf_temp_grplib_grp.level * {&tab-size} )
                                + {&opened-noterminal-grp-mark}
                                + substring( buf_temp_grplib_grp.name, buf_temp_grplib_grp.level * {&tab-size} + 2 )
        .
    end.
    {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
    br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
    reposition br-list to row v-repositioned-row.
    {&OPEN-QUERY-BROWSE-am-goods}
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE bind-to-scales Dlg-grp
PROCEDURE bind-to-scales :
/*------------------------------------------------------------------------------
  Purpose:     Привязать группу товаров к весам
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.

    define variable v-is-terminal   as logical           no-undo.

    run grplib-is-terminal (  input p-node-code
                            , output v-is-terminal
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка при определении типа группы (терм/корн)"
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.

    if v-is-terminal = no
    then do:
        message
            "Требуется выбрать самую подробную группу товаров,"
            skip "в которой НЕТ других групп."
        view-as alert-box information .
        apply "entry" to br-list in frame {&frame-name}.
        return no-apply.
    end.
    run ref/scal-grp.w (
          input parparentproc
        , input 'b-add'
        , input v-current-store-type
        , input v-current-store-code
        , input ({&table_db} + {&comma-char} + {&table_gds-grp})
        , input g#db-num
        , input 0
        , input p-node-code
    ) no-error .
    if error-status :error
    then do:
        undo, return error return-value.
    end.
end.
END PROCEDURE. /* bind-to-scales */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-down-lim Dlg-grp
PROCEDURE calc-down-lim :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-node-code as integer   no-undo .
define output parameter kk as integer   no-undo .
define variable kk2 as integer   no-undo .

define buffer d_temp_grplib_grp for temp_cons  .
define buffer curr_temp_grplib_grp for temp_cons  .
define variable v-is-terminal as logical   no-undo .
  do
  on error undo, return error return-value
  :

    find first curr_temp_grplib_grp where curr_temp_grplib_grp.node-code =  p-node-code no-error .
    kk = 0 .
    for each d_temp_grplib_grp where
             d_temp_grplib_grp.upper-code = p-node-code :

           if not ( d_temp_grplib_grp.cli-type =  ?  or  trim(d_temp_grplib_grp.cli-type) = "" )
           then do:
                  kk = kk +  int(d_temp_grplib_grp.cli-type).
           end.
           else do:
              run grplib-is-terminal in this-procedure (
                  input d_temp_grplib_grp.node-code
                , output v-is-terminal ) .
                if v-is-terminal = true then kk = ? .
                else do:
                   run calc-down-lim (input d_temp_grplib_grp.node-code , output kk2) .
                   kk = kk + kk2.
                end.
           end.
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-rights-for-change-grp Dlg-grp
PROCEDURE check-rights-for-change-grp :
/*------------------------------------------------------------------------------
  Purpose:     Проверка прав
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input  parameter p-node-code     as integer      no-undo.
define output parameter p-have-rights   as logical      no-undo.

    define variable v-enable-change-grp as logical       no-undo.

    if g#db-num <> 0
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Операция определена только в ГБД."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        assign
            p-have-rights = no
        .
    end.
    else do:
        { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_reference_groups-edit':U
            {&cntxt-firm}
            v-cntxt-host-code-obj
            '':U
            0
            0
            p-node-code
            0
            no
            p-have-rights
        }
    end.
end.
END PROCEDURE. /* check-rights-for-change-grp */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE collapse-all-on-first-level Dlg-grp
PROCEDURE collapse-all-on-first-level :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    define buffer buf_gds-grp       for gds-grp.
    define buffer buf_temp_grplib_grp       for temp_grplib_grp.
    for each buf_temp_grplib_grp no-lock
       where buf_temp_grplib_grp.upper-code = v-root-code
    :
        run collapse-item in this-procedure (
              input buf_temp_grplib_grp.node-code
            , input no
        ) no-error .
        if error-status :error
        then do:
            undo, return error "Не удалось закрыть подуровни группы "
                                + {&new-line} + "'" + buf_temp_grplib_grp.full-name + "'"
                                + {&new-line} + return-value.
        end.
    end.
    {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
end.
END PROCEDURE. /* collapse-all-on-first-level */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE collapse-item Dlg-grp
PROCEDURE collapse-item :
/*------------------------------------------------------------------------------
  Purpose:     Свернуть поддерево выбранной группы
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define input parameter p-refresh    as logical      no-undo.

    define variable v-focused-row       as integer              no-undo.
    define variable v-repositioned-row  as integer              no-undo.

    define buffer buf_del_temp_grplib_grp   for temp_grplib_grp.
    define buffer buf_temp_grplib_grp       for temp_grplib_grp.

    find first buf_temp_grplib_grp
         where buf_temp_grplib_grp.node-code = p-node-code
    no-error.
    if error-status :error
    then do:
        undo, return error "collapse-item: Неверно передан код группы. Нет группы с кодом " + string( p-node-code ).
    end.

    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .

    for each buf_del_temp_grplib_grp
       where buf_del_temp_grplib_grp.full-name begins buf_temp_grplib_grp.full-name
         and buf_del_temp_grplib_grp.full-name <> buf_temp_grplib_grp.full-name
         and buf_del_temp_grplib_grp.level     <> buf_temp_grplib_grp.level
    :
        delete buf_del_temp_grplib_grp.
    end.
    assign
        buf_temp_grplib_grp.mark = {&closed-noterminal-grp-mark}
        buf_temp_grplib_grp.name = replace( buf_temp_grplib_grp.name
                                        , {&opened-noterminal-grp-mark}
                                        , {&closed-noterminal-grp-mark}
                                        )
    .
    if p-refresh = yes
    then do:
        {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
        br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
        reposition br-list to row v-repositioned-row.
        {&OPEN-QUERY-BROWSE-am-goods}
    end.
end.
END PROCEDURE. /* collapse-item */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-new-line Dlg-grp
PROCEDURE create-new-line :
/*------------------------------------------------------------------------------
  Purpose:     Создание линии в строке browse без перерисовки
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code      as integer      no-undo.
define input parameter p-upper-code     as integer      no-undo.
define input parameter p-level          as integer      no-undo.
define input parameter p-is-terminal    as logical      no-undo.
define input parameter p-node-name      as character    no-undo.
define input parameter p-increase-pc    as decimal      no-undo.
define input parameter p-calc-method    as character    no-undo.
define input parameter p-full-name      as character    no-undo.
define input parameter p-sort-name      as character    no-undo.

define variable v-margins-range     as integer           no-undo.
define variable v-margins-exists    as logical           no-undo.
define variable v-increase-range    as integer           no-undo.
define variable v-increase-exists   as logical           no-undo.
define variable v-min-marg          as decimal           no-undo.
define variable v-max-marg          as decimal           no-undo.
define variable v-increase-pc       as decimal           no-undo.
define variable v-round-method      as character         no-undo .
define variable v-base              as decimal           no-undo .
define variable v-rmethod-range     as integer           no-undo.
define variable v-rmethod-exists    as logical           no-undo.

define variable  v-cli-type          as character no-undo .
define variable  v-cli-code          as integer no-undo .
define variable  v-income-cli-range  as integer no-undo .
define variable  v-income-cli-exists as logical no-undo .


define buffer buf_temp_grplib_grp       for temp_grplib_grp.

    create buf_temp_grplib_grp.
    assign
        buf_temp_grplib_grp.node-code   = p-node-code
        buf_temp_grplib_grp.upper-code  = p-upper-code
        buf_temp_grplib_grp.level       = p-level
        buf_temp_grplib_grp.full-name   = p-full-name + (if p-full-name <> "" then {&delim-grp}         else "") + p-node-name
        buf_temp_grplib_grp.sort-name   = p-sort-name + (if p-full-name <> "" then {&grplib-separator}  else "") + p-node-name
        buf_temp_grplib_grp.calc-method = p-calc-method
        buf_temp_grplib_grp.increase-pc = p-increase-pc
      .

    find first temp_cons where temp_cons.node-code = p-node-code no-error .
    if available temp_cons then do:
        assign
          buf_temp_grplib_grp.min-marg = temp_cons.min-marg
          buf_temp_grplib_grp.max-marg = temp_cons.max-marg
          buf_temp_grplib_grp.cli-type = temp_cons.cli-type
        .
    end.

    run get-first-char in this-procedure (
          input p-node-code
        , input p-is-terminal
        , input no
        , output buf_temp_grplib_grp.mark
    ) no-error.
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления первого символа для отображения группы." .
    end.
    assign
        buf_temp_grplib_grp.name = fill( " ", {&tab-size} * p-level )
                                        + buf_temp_grplib_grp.mark
                                        + " "
                                        + p-node-name
    .
end.
END PROCEDURE. /* create-new-line */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-grp Dlg-grp
PROCEDURE delete-grp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define input parameter p-refresh    as logical      no-undo.

    define variable v-gds-grp-recid     as recid    no-undo.
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    define variable v-upper-code        as integer  no-undo.
    define variable v-answer            as logical  no-undo.
    define variable v-is-terminal       as logical  no-undo.
    define variable v-have-goods        as logical  no-undo.
    define variable v-counter           as integer  no-undo.
    define variable v-have-rights       as logical  no-undo.

    define buffer buf_gds-grp           for gds-grp.
    define buffer buf_same_gds-grp      for gds-grp.                      /* для проверки совпадения имен */
    define buffer buf_temp_grplib_grp   for temp_grplib_grp.

    run check-rights-for-change-grp in this-procedure (
        input p-node-code
        ,output v-have-rights
    ) no-error.
    if error-status :error
    or v-have-rights = no
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Нет прав на изменение справочника групп товаров."
          skip "Удаление группы невозможно."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    /*---START--------- Нельзя удалить корневую группу ---------------------*/
    if p-node-code = v-root-code
    then do:
        message
            "Нельзя удалить корневую группу."
        view-as alert-box.
        undo, return.
    end.
    /*---END----------- Нельзя удалить корневую группу ---------------------*/
    find first buf_temp_grplib_grp
         where buf_temp_grplib_grp.node-code = p-node-code
    no-error .
    if error-status :error
    then do:
        undo, return error "Неверно выбрана группа." .
    end.
    /*---START--------- Нельзя удалить последнюю группу первого уровня ---------------------*/
    if buf_temp_grplib_grp.upper-code = v-root-code
    then do:
        assign
            v-counter = v-counter + 1
        .
        count-first-level-grp:
        for each buf_gds-grp no-lock
           where buf_gds-grp.upper-code = v-root-code
        :
            assign
                v-counter = v-counter + 1
            .
            if v-counter > 1
            then do:
                leave count-first-level-grp.
            end.
            else do:
                message
                    "Нельзя удалить последнюю группу первого уровня."
                view-as alert-box.
                return error.
            end.
        end.
    end.
    /*---END----------- Нельзя удалить последнюю группу первого уровня ---------------------*/
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if error-status :error
    then do:
        undo, return error "change-grp: Нет группы БД, соответствующей значению в списке.".
    end.
    assign
        v-upper-code    = buf_gds-grp.upper-code
        v-answer        = no
    .
    run grplib-is-terminal in this-procedure ( input p-node-code, output v-is-terminal ) no-error.
    if error-status :error
    then do:
        undo, return error return-value.
    end.

    if v-is-terminal = no
    then do:
    /* проверяем, не имеет ли одна из подгрупп такое же название, как и соседняя к удаляемой */
        for each buf_gds-grp
        where buf_gds-grp.upper-code = v-upper-code
          and buf_gds-grp.node-code <> p-node-code
        :
            find first buf_same_gds-grp no-lock
                where buf_same_gds-grp.upper-code  = p-node-code
                and buf_same_gds-grp.node-name   = buf_gds-grp.node-name
            no-error.
            if available buf_same_gds-grp
            then do:
                message
                    "Одна из подгрупп удаляемой группы имеет название:" buf_gds-grp.node-name "-" skip
                    "такое же, как одна из соседних к удаляемой групп." skip
                    "После удаления получились бы 2 группы на одном уровне, имеющие одинаковые названия, что запрещено."
                view-as alert-box error.
                return no-apply.
            end.
        end.
        message "Текущая группа будет удалена."
            skip "Ее подгруппы будут перенесены в вышестоящую группу."
            skip (1) "Слить группу с вышестоящей?"
        view-as alert-box question buttons yes-no update v-answer.
    end.
    if v-is-terminal = yes
    then do:
        run grplib-have-goods in this-procedure (
              input p-node-code
            , output v-have-goods
        ) no-error .
        if error-status :error
        then do:
            undo, return error "delete-grp: Ошибка определения наличия товаров в группе." + {&new-line} + return-value.
        end.
        if v-have-goods = yes
        then do:
            find first buf_gds-grp no-lock
                 where buf_gds-grp.upper-code = v-upper-code
                   and buf_gds-grp.node-code <> p-node-code
            no-error .
            if available buf_gds-grp
            then do:
                message "В одной группе не могут быть одновременно подгруппы и товары."
                    skip "Эта группа не может быть слита с вышестоящей."
                view-as alert-box error.
                apply "entry" to br-list in frame {&frame-name}.
                return no-apply.
            end.
            message "Текущая группа будет удалена."
                skip "Товары будут перенесены в вышестоящую группу."
                skip (1) "Слить группу с вышестоящей?"
            view-as alert-box question buttons yes-no update v-answer.
        end.
        else do:
            message "Удалить группу ? Вы уверены ?"
            view-as alert-box question buttons yes-no update v-answer.
        end.
    end.
    if not v-answer
    then do:
        apply "entry" to br-list in frame {&frame-name}.
        return no-apply.
    end.
    delete-from-base:
    do
    ON ERROR UNDO delete-from-base, return no-apply
    ON stop UNDO delete-from-base, return no-apply:
        find first buf_gds-grp exclusive-lock
             where buf_gds-grp.node-code = p-node-code
        no-error.
        if error-status :error
        then do:
            undo, return error "change-grp: Нет группы БД, соответствующей значению в списке.".
        end.
        delete buf_gds-grp.
    end.
    if p-refresh = yes
    then do:
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "delete-grp: Не найдена группа в БД".
        end.
        assign
            p-recid-list = string( recid( buf_gds-grp ) )
            gds-grp-row  = recid( buf_gds-grp )
        .
/*        run expand-item in this-procedure ( input buf_gds-grp.node-code, input yes ) no-error.*/
/*        if error-status :error*/
/*        then do:*/
/*            undo, return error "delete-grp: Не удается раскрыть группу.".*/
/*        end.*/
        run UI-on in this-procedure no-error .
        if error-status :error
        then do:
            undo, return error "delete-grp: Ошибка при загрузке дерева групп.".
        end.
    end.
end.
END PROCEDURE. /* delete-grp */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dlg-grp  _DEFAULT-DISABLE
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
  HIDE FRAME Dlg-grp.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dlg-grp  _DEFAULT-ENABLE
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
  DISPLAY fi-search RS-sts FILL-IN-1
      WITH FRAME Dlg-grp.
  ENABLE b-exit b-mark b-verify b-recalc B-print b-help b-expand b-expand-all
         fi-search b-find-by-full-name b-find-by-substring b-search br-list
         B-add B-lookup B-chg B-del B-copy RS-sts BROWSE-am-goods FILL-IN-1
      WITH FRAME Dlg-grp.
  VIEW FRAME Dlg-grp.
  {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE expand-all-from-current Dlg-grp
PROCEDURE expand-all-from-current :
/*------------------------------------------------------------------------------
  Purpose:     Раскрыть всю ветку дерева, начиная с текущей группы
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.

    define variable v-full-name         as character    no-undo.
    define variable v-focused-row       as integer      no-undo.
    define variable v-repositioned-row  as integer      no-undo.
    define variable v-grp-counter       as integer      no-undo.

    define buffer buf_temp_grplib_grp       for temp_grplib_grp.
    assign
        v-grplib-no-warning-grp-amount = no
    .
    run expand-item in this-procedure (
          input p-node-code
        , input no
    ) no-error .
    if error-status :error
    then do:
        undo, return error "expand-all-from-current: Не удалось раскрыть подуровни группы.".
    end.
    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    run grplib-get-full-name in this-procedure (
          input p-node-code
        , output v-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "expand-all-from-current: Ошибка вычисления полного имени группы".
    end.
    assign      /* Загрузить первую порцию групп ( {&grplib-grp-amount-for-warning} ) */
        v-grplib-grp-amount-for-load = 1
    .
    load-grp-list:
    for each buf_temp_grplib_grp
       where buf_temp_grplib_grp.full-name begins v-full-name
    :
        assign
            v-grp-counter = v-grp-counter + 1
        .
        run expand-item in this-procedure (
              input buf_temp_grplib_grp.node-code
            , input no
        ) no-error .
        if error-status :error
        then do:
            undo, return error "expand-all-from-current: Не удалось раскрыть подуровни группы.".
        end.
        if v-grp-counter > {&grplib-grp-amount-for-warning}
        and v-grplib-grp-amount-for-load <> 0
        then do:
            define variable v-choice    as integer      no-undo.
            run gbl/d-askw.w (
                  input "Большой список групп"
                , input substitute( "В список добавлено более &2 групп&1&1Вы можете добавить следующие &2 групп,&1заполнить весь список&1или остановить создание списка.", {&new-line}, {&grplib-grp-amount-for-warning} )
                , input "|^":U
                , input substitute( "Следующие &1|Заполнить все|Прервать", {&grplib-grp-amount-for-warning} )
                , input substitute( "Загрузить список следующих &1 групп|Загрузить список всех групп|Не загружать список полностью", {&grplib-grp-amount-for-warning} )
                , input 1
                , input 3
                , output v-choice
            ).
            case v-choice
            :
                when 1
                then do:
                    assign
                        v-grplib-grp-amount-for-load    = 1
                        v-grp-counter                   = 0

                    .
                end.        /* when 1 */
                when 2
                then do:
                    assign
                        v-grplib-grp-amount-for-load    = 0
                    .
                end.        /* when 2 */
                otherwise do:
                    leave load-grp-list.
                end.        /* otherwise */
            end case.       /* case v-choice */
        end.
    end.
    {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
    br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
    reposition br-list to row v-repositioned-row.
    {&OPEN-QUERY-BROWSE-am-goods}

end.
END PROCEDURE. /* expand-all-from-current */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE expand-item Dlg-grp
PROCEDURE expand-item :
/*------------------------------------------------------------------------------
  Purpose:     Раскрыть подуровни выбранной группы (должна быть не терминальной!)
  Parameters:   p-node-code - код узла для раскрытия.
                p-refresh   - надо ли обновлять browse после раскрытия узла
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define input parameter p-refresh    as logical      no-undo.

    define variable v-focused-row       as integer              no-undo.
    define variable v-repositioned-row  as integer              no-undo.

    define buffer buf_gds-grp           for gds-grp.
    define buffer buf_temp_grplib_grp   for temp_grplib_grp.
    { gbl/working.i }
    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    find first buf_temp_grplib_grp
         where buf_temp_grplib_grp.node-code = p-node-code
    no-error .
    if not available buf_temp_grplib_grp
    then do:
        undo, return error "expand-item: Неверно задан код группы.".
    end.

    if buf_temp_grplib_grp.mark <> {&closed-noterminal-grp-mark}
    then do:
        /* Не закрытая группа, открыть невозможно. */
    end.
    else do:
        for each buf_gds-grp no-lock
           where buf_gds-grp.upper-code = p-node-code
        on error undo, return error
        :
            run create-new-line in this-procedure (
                  input buf_gds-grp.node-code
                , input buf_gds-grp.upper-code
                , input buf_temp_grplib_grp.level + 1
                , input buf_gds-grp.is-term
                , input buf_gds-grp.node-name
                , input buf_gds-grp.increase-pc
                , input buf_gds-grp.calc-method
                , input buf_temp_grplib_grp.full-name
                , input buf_temp_grplib_grp.sort-name
            ) no-error .
            if error-status :error
            then do:
                message
                vss-workfile vss-revision vss-description
                skip "expand-item: Ошибка добавления строки в список групп."
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                    trim(error-status :get-message(4))
                    trim(error-status :get-message(5))
                view-as alert-box error.
                { gbl/stopwork.i }
                undo, return error .
            end.
        end.        /* for each buf_gds-grp */
        assign
            buf_temp_grplib_grp.mark = {&opened-noterminal-grp-mark}
            buf_temp_grplib_grp.name = replace( buf_temp_grplib_grp.name
                                            , {&closed-noterminal-grp-mark}
                                            , {&opened-noterminal-grp-mark}
                                            )
        .
        if p-refresh = yes
        then do:
            {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
            if v-focused-row > br-list :height - 2
            then do:
                assign
                    v-focused-row       = br-list :height - 2
                .
            end.
            br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
            reposition br-list to row v-repositioned-row.
            {&OPEN-QUERY-BROWSE-am-goods}
        end.
    end.
    { gbl/stopwork.i }
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE expand-or-collapse-item Dlg-grp
PROCEDURE expand-or-collapse-item :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    case temp_grplib_grp.mark
    :
    when {&closed-noterminal-grp-mark}
    then do:
        run expand-item in this-procedure ( input temp_grplib_grp.node-code, input yes ) no-error .
        if error-status :error
        then do:
            undo, return error "Не удалось раскрыть подуровни группы.".
        end.
    end.
    when {&opened-noterminal-grp-mark}
    then do:
        run collapse-item in this-procedure ( input temp_grplib_grp.node-code, input yes ) no-error .
        if error-status :error
        then do:
            undo, return error "Не удалось закрыть подуровни группы.".
        end.
    end.
    end case.
end.
END PROCEDURE. /* expand-or-collapse-item */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE expand-tree-for-grp Dlg-grp
PROCEDURE expand-tree-for-grp :
/*------------------------------------------------------------------------------
  Purpose:     Раскрыть дерево групп для заданного узла
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code              as integer          no-undo.
define output parameter p-focused-row           as integer          no-undo.
define output parameter p-reposition-row        as integer          no-undo.
define output parameter p-reposition-to-recid   as logical init no  no-undo.

define variable v-full-name     as character    no-undo.
define variable v-found         as logical      no-undo.

define buffer buf_temp_grplib_grp       for temp_grplib_grp.

    run grplib-get-full-name in this-procedure ( input p-node-code, output v-full-name ) no-error .
    if error-status :error
    then do:
        /* Не нашли полного имени - встаем на первую группу. */
    end.
    else do:
        run grplib-find-grp-by-full-name in this-procedure (
              input right-trim( v-full-name, {&delim-grp} )
            , input yes
            , output v-found
        ) no-error .
        if v-found = no
        then do:
            /* Не нашли по полному имени - встаем на первую группу. */
        end.
        else do:
            process-initial-grp:
            for each temp_grplib_found-grp
            break by temp_grplib_found-grp.level
            on error undo, leave process-initial-grp :
                if last ( temp_grplib_found-grp.level )
                then do:
                    assign
                        p-focused-row       = integer( br-list :height in frame {&frame-name} / 2 ) + 1
                    .
                    find first buf_temp_grplib_grp
                         where buf_temp_grplib_grp.node-code = temp_grplib_found-grp.node-code
                    no-error .
                    if error-status :error
                    then do:
                        leave process-initial-grp.
                    end.
                    assign
                        p-reposition-row = recid( buf_temp_grplib_grp )
                        p-reposition-to-recid = yes
                    .
                    leave process-initial-grp.
                end.
                else do:
                    run expand-item in this-procedure ( input temp_grplib_found-grp.node-code, input no ) no-error .
                    if error-status :error
                    then do:
                        leave process-initial-grp.
                    end.
                    find first buf_temp_grplib_grp
                            where buf_temp_grplib_grp.node-code = temp_grplib_found-grp.node-code
                    no-error .
                    if error-status :error
                    then do:
                        leave process-initial-grp.
                    end.
                    assign
                        p-reposition-row = recid( buf_temp_grplib_grp )
                        p-reposition-to-recid = yes
                    .
                end.
            end.
        end.
    end.
end.
END PROCEDURE. /* expand-tree-for-grp */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-db Dlg-grp
PROCEDURE fill-db :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter parnode-code like ub.gds-grp.node-code no-undo .
define input parameter parupper-code like ub.gds-grp.node-code no-undo .
  run ref/dtaxgrpu.p (input parnode-code,
                 input parupper-code,
                 input yes,
                 input v-current-host-code,
                 v-current-store-type,
                 v-current-store-code) no-error.
end.
END PROCEDURE. /* fill-db */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-marg Dlg-grp
PROCEDURE fill-marg :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.

    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    define variable v-margins-range     as integer  no-undo.
    define variable v-margins-exists    as logical  no-undo.
    define variable v-increase-range     as integer  no-undo.
    define variable v-increase-exists    as logical  no-undo.
    define variable v-min-marg          as decimal  no-undo.
    define variable v-max-marg          as decimal  no-undo.
    define variable v-increase-pc          as decimal  no-undo.
    define variable v-round-method      as character   no-undo .
    define variable v-base              as decimal     no-undo .
    define variable v-rmethod-range     as integer     no-undo.
    define variable v-rmethod-exists    as logical     no-undo.
    define variable v-cli-type           as character no-undo .
    define variable v-cli-code           as integer no-undo .
    define variable v-income-cli-range   as integer no-undo .
    define variable v-income-cli-exists  as logical no-undo .


    define buffer buf_gds-grp           for ub.gds-grp.
    define buffer buf_temp_grplib_grp   for temp_grplib_grp.

    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    run ref/pr-marg.w (
          input parparentproc
        , input p-node-code
    ) no-error.
    if error-status :error
    then do:
        undo, return error "fill-marg: Ошибка при установке диапазона торговых наценок." + {&new-line} + return-value.
    end.
    find first buf_temp_grplib_grp
         where buf_temp_grplib_grp.node-code = p-node-code
    no-error .
    if error-status :error
    then do:
        undo, return error "fill-marg: Неверно задан код группы.".
    end.
    {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
    br-list :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame {&FRAME-NAME}.
    reposition br-list to row v-repositioned-row.
    {&OPEN-QUERY-BROWSE-am-goods}
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-output-parameters-on-exit Dlg-grp
PROCEDURE fill-output-parameters-on-exit :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.

    define variable v-selected      as logical  init no  no-undo.
    define variable v-is-terminal    as logical           no-undo.

    define buffer buf_gds-grp           for gds-grp.
    define buffer buf_temp_grplib_grp   for temp_grplib_grp.

    run grplib-is-terminal in this-procedure ( input p-node-code, output v-is-terminal ) no-error.
    if error-status :error
    then do:
        undo, return error "fill-output-parameters-on-exit: Не удается определить, корневая группа или терминальная." + {&new-line} + return-value.
    end.
    if lookup ( {&g#term}, p-button-list ) <> 0 and v-is-terminal = no
    then do:
            message "Требуется выбрать группу товаров, в которой нет других групп.".
            apply "entry" to br-list in frame {&frame-name}.
            undo, return "no-term".
    end.
    assign
        p-recid-list = ""
    .
    for each buf_temp_grplib_grp
       where buf_temp_grplib_grp.sel = {&selection-char}
    :
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = buf_temp_grplib_grp.node-code
        no-error .
        if error-status :error
        then do:
            undo, return error "fill-output-parameters-on-exit: Не найдена запись выбранной группы '"
                                + "'" + buf_temp_grplib_grp.full-name + "'".
        end.
        assign
            p-recid-list = p-recid-list + ( if p-recid-list = "" then "" else "," ) + string( recid( buf_gds-grp ) )
            v-selected = yes
        .
    end.
    if v-selected = no
    then do:
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = p-node-code
        no-error .
        if not available buf_gds-grp
        then do:
            find first buf_temp_grplib_grp
                 where buf_temp_grplib_grp.node-code = p-node-code
            no-error .
            if not available buf_temp_grplib_grp
            then do:
                undo, return error "fill-output-parameters-on-exit: Неверно выбрана группа с кодом "
                                    + string( p-node-code ).
            end.
            undo, return error "fill-output-parameters-on-exit: Не найдена запись выбранной группы '"
                            + buf_temp_grplib_grp.full-name + "'".
        end.
        assign
            p-recid-list = string( recid( buf_gds-grp ) )
        .
    end.
    assign
        gds-grp-row  = integer( entry( 1, p-recid-list ) )
    .

assign
v-uf-List_ = (if gds-grp-row = ? then {&question-mark} else string(gds-grp-row))
.
run uf-set in this-procedure(
    input  {&uf-gds-grp-p}
    ,input  g#userid
    ,input v-uf-List_
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
)  no-error .

end.
END PROCEDURE. /* fill-output-parameters-on-exit */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tt Dlg-grp
PROCEDURE fill-tt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter parnode-code like ub.gds-grp.node-code no-undo .
define input parameter parupper-code like ub.gds-grp.node-code no-undo .

run ref/dtaxgrps.p (parnode-code,
               parupper-code,
               v-current-host-code,
               v-current-store-type,
               v-current-store-code) no-error.
end.
END PROCEDURE. /* fill-tt */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-grp-in-browse Dlg-grp
PROCEDURE find-grp-in-browse :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-search-grp-full-name   as character        no-undo.
define output parameter p-found                 as logical          no-undo.

    define variable v-focused-row       as integer      no-undo.
    define variable v-repositioned-row  as integer      no-undo.
    define variable v-counter           as integer      no-undo.
    define variable v-level             as integer      no-undo.

    define buffer buf_temp_grplib_grp       for temp_grplib_grp.
    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    assign
    v-level = num-entries( right-trim(p-search-grp-full-name, {&delim-grp} ) , {&delim-grp})
    .
    if v-found-grp-num  <> 0       /* группу уже нашли, temp-table уже заполнен. Берем следующую из темр-table.*/
    then do:
        assign
            v-counter = 0
        .
        find first temp_grplib_found-grp
             where temp_grplib_found-grp.level = v-level
        no-error .
        if not available temp_grplib_found-grp
        then do:
            undo, return error "Не найдено ни одной группы уровня " + string( v-level ).
        end.
        do v-counter = 1 to v-found-grp-num
        :
            find next temp_grplib_found-grp
                where temp_grplib_found-grp.level = v-level
            no-error .
            if not available temp_grplib_found-grp
            then do:
                undo, return error "Не найдена следующая группа уровня " + string( v-level ).
            end.
        end.
        find first buf_temp_grplib_grp
                where buf_temp_grplib_grp.node-code = temp_grplib_found-grp.node-code
        no-error .
        if not available buf_temp_grplib_grp
        then do:
            undo, return error "Найденной группы нет в списке групп".
        end.
        {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
        br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
        reposition br-list to recid recid( buf_temp_grplib_grp ).
        {&OPEN-QUERY-BROWSE-am-goods}
    end.        /* v-found-grp-num  <> 0 */
    else do:        /* Первый поиск */
        run grplib-find-grp-by-full-name (
              input fi-search :screen-value in frame {&frame-name}
            , input yes
            , output p-found
        ).
        if p-found = yes
        then do:
            found-group:
            for each temp_grplib_found-grp no-lock
            by temp_grplib_found-grp.level
        /*       where temp_grplib_found-grp. =*/
            :
                if temp_grplib_found-grp.level = v-level
                then do:
                    leave.
                end.
                run expand-item in this-procedure (
                      input temp_grplib_found-grp.node-code
                    , input no
                ).
            end.
            find first temp_grplib_found-grp
                 where temp_grplib_found-grp.level = v-level
            no-error .
            if not available temp_grplib_found-grp
            then do:
                undo, return error "Нет последней найденной группы для уровня " + string( v-level ).
            end.
            find first buf_temp_grplib_grp
                 where buf_temp_grplib_grp.node-code = temp_grplib_found-grp.node-code
            no-error .
            if not available buf_temp_grplib_grp
            then do:
                undo, return error "Найденной группы нет в списке групп".
            end.
            {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
            br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
            reposition br-list to recid recid( buf_temp_grplib_grp ).
            {&OPEN-QUERY-BROWSE-am-goods}
        end.        /* p-found = yes */
    end.        /* v-found-grp-num  = 0, т.е. первый поиск */
    find next temp_grplib_found-grp     /* Можно ли искать дальше? Если можно, увеличиваем счетчик поиска */
        where temp_grplib_found-grp.level = v-level
    no-error .
    if available temp_grplib_found-grp
    then do:
        assign
            v-found-grp-num  = v-found-grp-num + 1
            b-search :label = "Далее"
        .
    end.
    else do:
        assign
            v-found-grp-num  = 0
            b-search :label = "Поиск"
        .
    end.
end.
END PROCEDURE. /* find-grp-in-browse */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-current-recid Dlg-grp
PROCEDURE get-current-recid :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define output parameter p-gds-grp-recid as recid   no-undo.

    define buffer buf_gds-grp       for gds-grp.

    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error .
    if not available buf_gds-grp
    then do:
        undo, return error "get-current-recid: Не найдена группа." .
    end.
    assign
        p-gds-grp-recid = recid( buf_gds-grp )
    .
end.
END PROCEDURE. /* get-current-recid */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-first-char Dlg-grp
PROCEDURE get-first-char :
/*------------------------------------------------------------------------------
  Purpose:     Определение первого символа в названии: '+', '-', ' '.
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code      as integer      no-undo.
define input parameter p-terminal       as logical      no-undo.
define input parameter p-calc-terminal  as logical      no-undo.
define output parameter p-prefix        as character    no-undo.

define variable v-name          as character    no-undo.
define variable v-is-terminal   as logical      no-undo.
define variable v-have-goods    as logical      no-undo.

define buffer buf_gds-grp               for gds-grp.
define buffer buf_temp_grplib_grp       for temp_grplib_grp.

if p-calc-terminal = yes
then do:
    run grplib-is-terminal in this-procedure (
          input p-node-code
        , output v-is-terminal
    ) no-error .
    if error-status :error
    then do:
        undo, return error "get-first-char: Ошибка при определении типа группы (терм/корн).".
    end.
end.        /* if p-calc-terminal = yes */
else do:
    assign
        v-is-terminal = p-terminal
    .
end.        /* NOT ( if p-calc-terminal = yes ) */
if v-is-terminal = yes
then do:                    /* Терминальная группа */
    run grplib-have-goods in this-procedure (
          input p-node-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        undo, return error "get-first-char: Ошибка определения наличия товаров в группе." + {&new-line} + return-value.
    end.
    if v-have-goods = yes
    then do:
        assign
            p-prefix = {&terminal-with-goods-grp-mark}
        .
    end.
    else do:
        assign
            p-prefix = {&terminal-no-goods-grp-mark}
        .
    end.
end.        /* not available buf_gds-grp */
else do:
    find first buf_temp_grplib_grp no-lock
         where buf_temp_grplib_grp.upper-code = p-node-code
    no-error.
    if available buf_temp_grplib_grp
    then do:                /* группа в списке раскрыта */
        assign
            p-prefix = {&opened-noterminal-grp-mark}
        .
    end.
    else do:
        assign
            p-prefix = {&closed-noterminal-grp-mark}
        .
    end.
end.        /* available buf_gds-grp */
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-row-amount Dlg-grp
PROCEDURE get-row-amount :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define output parameter p-row-amount as integer      no-undo.

    define buffer buf_temp_grplib_grp       for temp_grplib_grp.

    for each buf_temp_grplib_grp
    :
        assign
            p-row-amount = p-row-amount + 1
        .
    end.
end.
END PROCEDURE. /* get-row-amount */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-tt Dlg-grp
PROCEDURE init-tt :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 define buffer buf_gds-grp-obj-attr  for ub.gds-grp-obj-attr  .

    for each temp_grplib_grp :
        find first buf_gds-grp-obj-attr no-lock  where
                   buf_gds-grp-obj-attr.attr-code = {&ggoattr-LimAssMat} and
                   buf_gds-grp-obj-attr.obj-type  = string(buf_matrix.asmt-id) and
                   buf_gds-grp-obj-attr.obj-code  = buf_matrix.db-num and
                   buf_gds-grp-obj-attr.host-code = 0 and
                   buf_gds-grp-obj-attr.node-code = temp_grplib_grp.node-code no-error .
        if not available buf_gds-grp-obj-attr then temp_grplib_grp.cli-type  = "".
        else temp_grplib_grp.cli-type = buf_gds-grp-obj-attr.attr-value .
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE move-item Dlg-grp
PROCEDURE move-item :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.   /* Группа, которую перемещаем */
define input parameter p-upper-code as integer      no-undo.   /* Группа, к которой присоединяем */

    define variable v-node-full-name    as character    no-undo.
    define variable v-upper-full-name   as character    no-undo.
    define variable v-focused-row       as integer      no-undo.
    define variable v-repositioned-row  as integer      no-undo.
    define variable v-have-goods        as logical      no-undo.

    define buffer buf_gds-grp           for gds-grp.
    define buffer buf_upper_gds-grp     for gds-grp.
    define buffer buf_temp_grplib_grp   for temp_grplib_grp.

    { gbl/working.i }

    run grplib-have-goods in this-procedure (
          input p-upper-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка определения наличия товаров в группе." + {&new-line} + return-value.
    end.
    if v-have-goods = yes
    then do:
            message
                "В эту группу переместить нельзя, т.к. в одной группе"
                skip "не могут быть одновременно подгруппы и товары.".
            apply "entry" to br-list in frame {&frame-name}.
            return no-apply.
    end.
    run grplib-get-full-name in this-procedure (
            input p-node-code
            , output v-node-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка вычисления полного имени перемещаемой группы".
    end.
    run grplib-get-full-name in this-procedure (
            input p-upper-code
            , output v-upper-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка вычисления полного имени группы".
    end.
    if v-upper-full-name begins v-node-full-name
    then do:
        message
        "Группу нельзя переместить в ее собственную подгруппу."
        view-as alert-box.
        undo, return.
    end.

    do transaction
    on error undo, return error "move-item: Ошибка перемещения группы.".
        find first buf_gds-grp exclusive-lock
            where buf_gds-grp.node-code = p-node-code
        no-error .
        if not available buf_gds-grp
        then do:
            undo, return error "move-item: Не найдена группа для перемещения.".
        end.
        assign
            buf_gds-grp.upper-code = p-upper-code
        .
    end.
    assign
        p-recid-list = string( recid( buf_gds-grp ) )
        gds-grp-row  = recid( buf_gds-grp )
    .
    run UI-on in this-procedure no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка при загрузке дерева групп." + {&new-line} + return-value.
    end.
end.
END PROCEDURE. /* move-item */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-browse Dlg-grp
PROCEDURE print-browse :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable Line as character no-undo.
define variable v-vat-pc as decimal no-undo .
define variable v-slt-pc as decimal no-undo .
define variable date_string as character no-undo.
define buffer buf_temp_grplib_grp for temp_grplib_grp.
define buffer buf_tax-rate-gds-grp for ub.tax-rate-gds-grp.

DEFINE FRAME brFrame
buf_temp_grplib_grp.name          format "X(71)"      column-label " Наименование группы"
buf_temp_grplib_grp.calc-method   format "X(11)"      column-label " Исходная"
buf_temp_grplib_grp.increase-pc   format "->>>>9.99"  column-label " Наценка"
buf_temp_grplib_grp.min-marg      format "X(10)"  column-label " Мин.Нац."
buf_temp_grplib_grp.max-marg      format "X(10)"  column-label " Макс.Нац."
buf_temp_grplib_grp.round-method  format "X(22)"  column-label "Метод округл"
v-vat-pc                          format "99.99"  column-label "НДС"
v-slt-pc                          format "99.99"  column-label "НП"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 85 PAGE-NUMBER(PrnLibStream) AT 95 FORMAT ">>9" SKIP
Line format "X(150)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 150).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
      input parparentproc
    , input {&LS_PS_A4}
    , input yes /*p-is-stream*/
    , input no /*p-append*/
).
PUT  STREAM PrnLibStream
    SPACE(25) ( frame {&frame-name}:title )
    format "x(90)" SKIP(1)
.
FORM HEADER
Line format "X(150)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .


FORM with FRAME BrFrame  .
run waitfram-show in this-procedure ("Ждите...").

FOR EACH buf_temp_grplib_grp :
  FIND LAST buf_tax-rate-gds-grp No-LOCK WHERE
            buf_tax-rate-gds-grp.node-code = buf_temp_grplib_grp.node-code AND
            buf_tax-rate-gds-grp.tax-code = integer({&vat-tax-code}) AND
            /*
            freeze
            ub.tax-rate-gds-grp.host-code = parhopst-code AND
            ub.tax-rate-gds-grp.obj-type = parobj-type AND
            ub.tax-rate-gds-grp.obj-code = parobj-code AND

            */
            buf_tax-rate-gds-grp.host-code = 0 AND
            buf_tax-rate-gds-grp.obj-type = "" AND
            buf_tax-rate-gds-grp.obj-code = 0 NO-ERROR.
  if avail buf_tax-rate-gds-grp then do:
     { gbl/pftaxval.i ? buf_tax-rate-gds-grp.tax-code buf_tax-rate-gds-grp.rate-code ? v-current-host-code v-current-store-type v-current-store-code v-vat-pc no-error }
  end.
  FIND LAST buf_tax-rate-gds-grp No-LOCK WHERE
            buf_tax-rate-gds-grp.node-code = buf_temp_grplib_grp.node-code AND
            buf_tax-rate-gds-grp.tax-code = integer({&slt-tax-code}) AND
            /*
            freeze
            ub.tax-rate-gds-grp.host-code = parhopst-code AND
            ub.tax-rate-gds-grp.obj-type = parobj-type AND
            ub.tax-rate-gds-grp.obj-code = parobj-code AND

            */
            buf_tax-rate-gds-grp.host-code = 0 AND
            buf_tax-rate-gds-grp.obj-type = "" AND
            buf_tax-rate-gds-grp.obj-code = 0 NO-ERROR.
  if avail buf_tax-rate-gds-grp then do:
     { gbl/pftaxval.i ? buf_tax-rate-gds-grp.tax-code buf_tax-rate-gds-grp.rate-code ? v-current-host-code v-current-store-type v-current-store-code v-slt-pc no-error }
  end.
  DISPLAY stream PrnLibStream
  buf_temp_grplib_grp.name
  buf_temp_grplib_grp.calc-method
  buf_temp_grplib_grp.increase-pc
  buf_temp_grplib_grp.min-marg
  buf_temp_grplib_grp.max-marg
  buf_temp_grplib_grp.round-method
  v-vat-pc
  v-slt-pc
  with frame BrFrame.
  down stream PrnLibStream
  with frame BrFrame.
END. /*for each*/
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME BrFrame.
output  STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure .

run prn-lib-prn-file in this-procedure (
      input parparentproc
    , input 8
).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add Dlg-grp
PROCEDURE proc-add :
/* -----------------------------------------------------------
  Purpose: добавление списка товаров
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define output parameter p-doc-rec as recid no-undo .
define variable v-host-code as integer   no-undo .
/*  */
DEFINE VARIABLE cError as CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE iDelta as INTEGER   NO-UNDO INITIAL 0.

{ gbl/hostcode.i
 p-current-obj-type
 p-current-obj-code
 v-host-code
}

for each tt-gds-list :
   delete tt-gds-list.
end.

run str/chsgdsls.w
(   parParentProc ,
    input "gds-matr" ,
    input "Ассортиментная матрица " + buf_matrix.asmt-name  , ? , ? ,
    input v-host-code,
    input-output varschartic,
    output ref-list,
    output table tt-gds-list,
    false )
     no-error .
     if error-status :error then do:
     message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error
        .

     end.

/*  */
/* Параметры снимаем общей процедурой  */
RUN Get-Gl-Param-Proc-Otkl in THIS-PROCEDURE(
    p-Id,
    p-Db-num,
    OUTPUT cError
    ).
if cError <> "" THEN DO:
   RETURN ERROR cError.
END.


/* Подсчет дельты от выбранных товаров  */
 { ref/ass-mat.i
      &DEF_CALC_DELTA_BUF=YES
      &BUF_LIST=tt-gds-list
      &VAR_ASMT-ID=buf_matrix.Asmt-id
      &VAR_DB-NUM=buf_matrix.db-num
      &VAR_DELTA=iDelta
 }    

 /* Проверка допустимого % отклонения   */
 RUN Cntrl-AM-Add-1 IN THIS-PROCEDURE(
     iDelta,
     OUTPUT cError
     ).
 if cError <> "" THEN DO:
    RETURN ERROR cError.
 END.


 run waitfram-show in this-procedure  ("Добавление товаров в ассортиментную матрицу ... " ) .
 for each tt-gds-list:
     { ref/gds-mat1.i
         this-procedure
         p-doc-rec
         {&add-def}
         buf_matrix.asmt-id
         buf_matrix.db-num
         tt-gds-list.gds-code
         "''"
        no-error }

        if error-status :error then do:
            message return-value view-as alert-box information .
            run waitfram-hide in this-procedure .
            return.
        end.
 end.

run waitfram-hide in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dlg-grp
PROCEDURE proc-b-del :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter p-recid as character no-undo .
define input  parameter p-model as logical   no-undo .

define variable loc#log as logical no-undo.
define variable v-log as logical   no-undo .
define variable v-sts like ub.assortment-matrix-goods.asmg-status no-undo .
define variable loc-doc-rec as recid no-undo.
define variable i as integer   no-undo .

if not available buf_matrix-goods then return error.

do
on error undo, return error
on stop undo, return error

:

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_assort-matr-gds_deletion':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-log
  }
 if not v-log then return no-apply .
   assign
    v-sts = ?
    loc-doc-rec = RECID(buf_Matrix-goods)
    .
  if p-model = false then do:
  { ref/gds-mat2.i
    this-procedure
    recid(buf_Matrix-goods)
    v-sts
    true
    no-error }
    if error-status:error then do:
       message return-value view-as alert-box information .
       undo, return error.
    end.
  end.
  else do:
      v-err-ext = false  .
      v-longchar = "".
      repeat i = 1 to num-entries(p-recid) :
      find first buf_Matrix-goods no-lock where
           recid(buf_Matrix-goods) = integer(entry(i,p-recid )) no-error .
        if buf_Matrix-goods.asmg-status = 0 then do:
            { ref/gds-mat2.i
              this-procedure
              entry(i,p-recid)
              v-sts
              false
              no-error
              }
              if error-status :error then do:
                 v-err-ext = true .
                 v-longchar = v-longchar  + return-value + {&new-line} .
              end.
        end.
      end.

    p-recid = "" .
    p-rid-list = "" .

    if v-err-ext = true  then do:
    define variable v-ok as logical   no-undo .
      run gbl/d-longchar.w (
            ?,
            'Editor_row=2\':u
          + 'title=При корректировке в Ассортиментные матрицы\':u
          + 'Editor_col=1\':u
          + 'Editor_width=96\':u
          + 'Editor_height=21\':u
          + 'readonly=yes\':u
        ,input-output v-longchar
        ,output v-ok ) no-error .
        v-longchar = "" .
        { ref/clearlm.i }

    end.

  end.

  {&OPEN-QUERY-BROWSE-am-goods}
  REPOSITION BROWSE-am-goods to recid loc-doc-rec No-error.
  {&cant-positioning}
  if available buf_Matrix-goods then do:
    loc#log = BROWSE-am-goods:select-focused-row( ) IN FRAME {&FRAME-NAME}.
    loc#log = BROWSE-am-goods:refresh() .
  end.
  apply "ENTRY" to BROWSE-am-goods.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dlg-grp
PROCEDURE proc-b-print :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

define variable v-doc-rec as recid no-undo .
define variable accum-count as integer.
define variable date_string     as      character    no-undo.
define variable Line            as      character    no-undo.
define variable v-time-cr as character no-undo .
define variable v-time-up as character no-undo .
define variable v-st      as character no-undo .

DEFINE FRAME buf_Matrix-list
      Buf_goods.artic FORMAT "X(16)":U
      Buf_goods.gds-name FORMAT "X(30)":U
      Buf_matrix-goods.asmg-who-update COLUMN-LABEL "Кто!изменил" FORMAT "X(8)":U
      Buf_matrix-goods.asmg-date-update COLUMN-LABEL "Дата!изменения" FORMAT "99/99/99":U
      p-time-upd COLUMN-LABEL "Время" FORMAT "x(5)":U
      Buf_matrix-goods.asmg-db-num-update COLUMN-LABEL "БД!изм" FORMAT ">>>>9":U
      Buf_matrix-goods.asmg-date-create COLUMN-LABEL "Дата!создания" FORMAT "99/99/99":U
      p-time-cr COLUMN-LABEL "Время" FORMAT "x(5)":U
      Buf_matrix-goods.asmg-who-create COLUMN-LABEL "Кто!создал" FORMAT "X(8)":U
      Buf_matrix-goods.asmg-db-num-create COLUMN-LABEL "БД!соз" FORMAT ">>>>9":U
      p-status COLUMN-LABEL "Статус" FORMAT "x(6)":U
      v-indicator-life-gds COLUMN-LABEL "ИЖТ" FORMAT "x(20)":U
      v-assort-min         column-label "AMin" format "*/ "

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

FORM with FRAME buf_Matrix-list  .
run waitfram-show in this-procedure ("Ждите...").
v-doc-rec = recid(buf_Matrix-goods).
DO WHILE available buf_Matrix-goods :
  GET prev BROWSE-am-goods.
END.
GET next BROWSE-am-goods.
DO WHILE available buf_Matrix-goods :
  { gbl/gdsobjpr.i
    buf_matrix.obj-type
    buf_matrix.obj-code
    ?
    ?
    ?
    buf_Matrix-goods.gds-code
    v-assort-min
    v-indicator-life-gds
    v-gdop-min-stock
    v-grop-max-stock
    v-grop-level-always-presence
    v-grop-min-order
 }
  Display STREAM PrnLibStream
    STRING (buf_Matrix-goods.asmg-time-create,'HH:MM') @ p-time-cr
    STRING (buf_Matrix-goods.asmg-time-update,'HH:MM') @ p-time-upd
           {&status-int-name} @ p-status
            Buf_goods.artic
            Buf_goods.gds-name
            Buf_matrix-goods.asmg-who-update
            Buf_matrix-goods.asmg-date-update
            Buf_matrix-goods.asmg-db-num-update
            Buf_matrix-goods.asmg-date-create
            Buf_matrix-goods.asmg-who-create
            Buf_matrix-goods.asmg-db-num-create
            v-indicator-life-gds
            v-assort-min
 with FRAME buf_Matrix-list .
  DOWN STREAM PrnLibStream 1
  with FRAME buf_Matrix-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next BROWSE-am-goods.
END.
UNDERLINE  STREAM PrnLibStream
    p-time-cr
    p-time-upd
    p-status
    Buf_goods.artic
    Buf_goods.gds-name
    Buf_matrix-goods.asmg-who-update
    Buf_matrix-goods.asmg-date-update
    Buf_matrix-goods.asmg-db-num-update
    Buf_matrix-goods.asmg-date-create
    Buf_matrix-goods.asmg-who-create
    Buf_matrix-goods.asmg-db-num-create
    v-indicator-life-gds
    v-assort-min
with FRAME buf_Matrix-list .

DISPLAY STREAM PrnLibStream
"ИТОГО"     @ Buf_goods.artic
accum-count @ Buf_goods.gds-name
with frame buf_Matrix-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME buf_Matrix-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION BROWSE-am-goods to recid v-doc-rec no-error.
APPLY "entry" to BROWSE-am-goods.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-copy Dlg-grp
PROCEDURE proc-copy :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-doc-rec as recid no-undo .
define variable  v-rid-list as character no-undo .
define buffer bb_assortment-matrix for assortment-matrix.
define buffer bb_assortment-matrix-goods for assortment-matrix-goods.
define variable v-calc0    as integer   no-undo init 1 .
define variable v-calc     as integer   no-undo init 0 .
define variable v-calc-err as integer   no-undo init 0 .
/*  */
DEFINE VARIABLE cError as CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE iDelta as INTEGER   NO-UNDO INITIAL 0.
/*  */

/* Параметры снимаем общей процедурой  */
RUN Get-Gl-Param-Proc-Otkl in THIS-PROCEDURE(
    p-Id,
    p-Db-num,
    OUTPUT cError
    ).
if cError <> "" THEN DO:
   RETURN ERROR cError.
END.

run ref/assmatr.w ( input parParentProc , input 'b-sel', p-current-obj-type , p-current-obj-code , ? ,  ?, input-output  v-rid-list ).

if v-rid-list <> "" then do:
   find first bb_assortment-matrix no-lock where recid(bb_assortment-matrix) = int(v-rid-list) no-error .
   if available bb_assortment-matrix then do:
      /* Подсчет дельты от выбранных товаров  */
      RUN Get-Delta-Gds-2-Matrix in THIS-PROCEDURE(
          BUFFER bb_assortment-matrix,
          BUFFER buf_matrix,
          OUTPUT iDelta
          ).
      /* Проверка допустимого % отклонения   */
      RUN Cntrl-AM-Add-1 IN THIS-PROCEDURE(
          iDelta,
          OUTPUT cError
          ).
      IF cError <> "" THEN DO:
         RETURN ERROR cError.
      END.
      /*  */
      for each  bb_assortment-matrix-goods no-lock where
                bb_assortment-matrix-goods.asmg-status  = 0 and
                bb_assortment-matrix-goods.db-num = bb_assortment-matrix.db-num and
                bb_assortment-matrix-goods.asmt-id = bb_assortment-matrix.asmt-id :
            run waitfram-show in this-procedure  ("Копирование из ассортиментной матрицы " + bb_assortment-matrix.asmt-name + " " + string(v-calc0) ) .
                { ref/gds-mat1.i
                    this-procedure
                    p-doc-rec
                    {&add-def}
                    buf_matrix.asmt-id
                    buf_matrix.db-num
                    bb_assortment-matrix-goods.gds-code
                    bb_assortment-matrix-goods.asmg-des
                    no-error }
                    if error-status :error then do:
                       v-calc-err = v-calc-err + 1 .
                       v-err-ext  = true .
                       v-longchar = v-longchar + return-value  + {&new-line} .
                    end.
                    else  do:
                      v-calc = v-calc + 1 .
                    end.
                  v-calc0 = v-calc0 + 1 .
      end.
      run waitfram-hide in this-procedure .
      message
      "Скопировано" v-calc "товаров" skip
      "Ошибок"      v-calc-err       skip
      view-as alert-box information .
      if v-err-ext = true  then do:
      define variable v-ok as logical   no-undo .
        run gbl/d-longchar.w (
              ?,
              'Editor_row=2\':u
            + 'title=При добавлении в Ассортиментные матрицы\':u
            + 'Editor_col=1\':u
            + 'Editor_width=96\':u
            + 'Editor_height=21\':u
            + 'readonly=yes\':u
          ,input-output v-longchar
          ,output v-ok ) no-error .
           v-longchar = "" .
          { ref/clearlm.i }

      end.
   end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE recalc-lim Dlg-grp
PROCEDURE recalc-lim :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer loc_temp_grplib_grp for temp_grplib_grp  .
define variable v-recid as recid no-undo .

v-recid = recid (temp_grplib_grp) .
for each temp_cons  :
  run calc-down-lim ( input temp_cons.node-code , output temp_cons.min-marg). /* Ограничения по ниж уровням*/
  find first loc_temp_grplib_grp where
             loc_temp_grplib_grp.node-code = temp_cons.node-code no-error .
      if available loc_temp_grplib_grp then loc_temp_grplib_grp.min-marg  = temp_cons.min-marg .
end.

find first temp_grplib_grp where recid (temp_grplib_grp)  = v-recid no-error .

{&OPEN-QUERY-br-list}
reposition BR-list to recid v-recid no-error.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE recalc-marg-ass Dlg-grp
PROCEDURE recalc-marg-ass :
define variable v-qntyAssgrp as integer  no-undo .
define variable ll as integer   no-undo .
define buffer buf_assortment-matrix-goods for ub.assortment-matrix-goods  .
define buffer buf2_goods for ub.goods  .
define buffer loc_temp_grplib_grp for  temp_grplib_grp .
define buffer buf1_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
define variable v-recid as recid no-undo .
v-recid = recid (temp_grplib_grp) .

    for each loc_temp_grplib_grp :
      run calc-down-lim   (
          input loc_temp_grplib_grp.node-code ,
          output loc_temp_grplib_grp.min-marg). /* Ограничения по ниж уровням*/

        v-qntyAssgrp = 0.
        find first buf1_gds-grp-obj-attr no-lock where
                   buf1_gds-grp-obj-attr.attr-code = {&ggoattr-QntyAssMat} and
                   buf1_gds-grp-obj-attr.obj-type  = string(p-id) and
                   buf1_gds-grp-obj-attr.obj-code  = p-db-num and
                   buf1_gds-grp-obj-attr.host-code = 0 and
                   buf1_gds-grp-obj-attr.node-code = loc_temp_grplib_grp.node-code
        no-error .
        if available buf1_gds-grp-obj-attr then v-qntyAssgrp = int(buf1_gds-grp-obj-attr.attr-value) .
        assign
          loc_temp_grplib_grp.max-marg = string(v-qntyAssgrp) /* Количество товара в группе */
        .
    end.
run init-tt.

find first temp_grplib_grp where recid(temp_grplib_grp)  = v-recid no-error .

{&OPEN-QUERY-br-list}
reposition BR-list to recid v-recid no-error.
{&OPEN-QUERY-BROWSE-am-goods}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-alla Dlg-grp
PROCEDURE save-alla :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr .
if temp_grplib_grp.cli-type:read-only in browse br-list = false then do:

  for each temp_cons :
        find first buf_gds-grp-obj-attr exclusive-lock where
                   buf_gds-grp-obj-attr.attr-code = {&ggoattr-LimAssMat} and
                   buf_gds-grp-obj-attr.obj-type  = string(buf_matrix.asmt-id) and
                   buf_gds-grp-obj-attr.obj-code  = buf_matrix.db-num and
                   buf_gds-grp-obj-attr.host-code = 0 and
                   buf_gds-grp-obj-attr.node-code = temp_cons.node-code no-error .
        if not available buf_gds-grp-obj-attr then create buf_gds-grp-obj-attr.
        assign
            buf_gds-grp-obj-attr.attr-code = {&ggoattr-LimAssMat}
            buf_gds-grp-obj-attr.obj-type  = string(buf_matrix.asmt-id)
            buf_gds-grp-obj-attr.obj-code  = buf_matrix.db-num
            buf_gds-grp-obj-attr.host-code = 0
            buf_gds-grp-obj-attr.node-code  = temp_cons.node-code
            buf_gds-grp-obj-attr.attr-value = temp_cons.cli-type
        .
  end.

  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-attr Dlg-grp
PROCEDURE save-attr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

define buffer buf_gds-grp-obj-attr  for ub.gds-grp-obj-attr  .
if temp_grplib_grp.cli-type:read-only in browse br-list = false then do:
    if available  temp_grplib_grp then do:
        find first buf_gds-grp-obj-attr exclusive-lock where
                   buf_gds-grp-obj-attr.attr-code = {&ggoattr-LimAssMat} and
                   buf_gds-grp-obj-attr.obj-type  = string(buf_matrix.asmt-id) and
                   buf_gds-grp-obj-attr.obj-code  = buf_matrix.db-num and
                   buf_gds-grp-obj-attr.host-code = 0 and
                   buf_gds-grp-obj-attr.node-code = temp_grplib_grp.node-code no-error .
        if not available buf_gds-grp-obj-attr then create buf_gds-grp-obj-attr.
        assign
            buf_gds-grp-obj-attr.attr-code = {&ggoattr-LimAssMat}
            buf_gds-grp-obj-attr.obj-type  = string(buf_matrix.asmt-id)
            buf_gds-grp-obj-attr.obj-code  = buf_matrix.db-num
            buf_gds-grp-obj-attr.host-code = 0
            buf_gds-grp-obj-attr.node-code = temp_grplib_grp.node-code
            buf_gds-grp-obj-attr.attr-value = temp_grplib_grp.cli-type
        .
     end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-and-move-item Dlg-grp
PROCEDURE select-and-move-item :
/*------------------------------------------------------------------------------
  Purpose:     Перемещение группы
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.

    define variable v-upper-code        as integer           no-undo.
    define variable v-upper-recid-list  as character         no-undo.
    define variable v-yesno             as logical           no-undo.
    define variable v-node-full-name    as character         no-undo.
    define variable v-upper-full-name   as character         no-undo.

    define buffer buf_gds-grp       for gds-grp.

    if p-node-code = v-root-code
    then do:
        message
        "Корневую группу переместить невозможно."
        view-as alert-box warning.
        undo, return .
    end.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error .
    if error-status :error
    then do:
        undo, return error "select-and-move-item: Группа не найдена в базе данных.".
    end.
    assign
        v-upper-recid-list = string( recid( buf_gds-grp ) )
    .
    run ref/gds-grp.w (
          input parparentproc
        , input {&buttons-for-move}
        , input p-current-obj-type
        , input p-current-obj-code
        , input-output v-upper-recid-list
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора группы для перемещения."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    find first buf_gds-grp no-lock
         where recid( buf_gds-grp ) = integer( entry( 1, v-upper-recid-list ) )
    no-error .
    if error-status :error
    then do:
        undo, return error "Группа не найдена.".
    end.
    run grplib-get-full-name in this-procedure (  input p-node-code
                                                , output v-node-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "Ошибка вычисления полного имени перемещаемой группы.".
    end.
    run grplib-get-full-name in this-procedure (  input buf_gds-grp.node-code
                                                , output v-upper-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "Ошибка вычисления полного имени новой группы".
    end.

    message
        "Переместить группу"
        skip "    '" + v-node-full-name + "'"
        skip "в группу"
        skip "    '" + v-upper-full-name + "'"
    view-as alert-box question
    buttons yes-no
    title "Перемещение группы"
    update v-yesno.
    if v-yesno = no
    then do:
        /* Отказ от перемещения группы */
    end.
    else do:
        run move-item in this-procedure ( input p-node-code
                                        , input buf_gds-grp.node-code
        ) no-error.
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка перемещения группы."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
                trim(error-status :get-message(4))
                trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
end.
END PROCEDURE. /* select-and-move-item */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UI-on Dlg-grp
PROCEDURE UI-on :
/*------------------------------------------------------------------------------
  Purpose:     Заполнение temp_grplib_grp и инициализация при старте программы
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define variable v-reposition-row        as integer          no-undo.
define variable v-focused-row           as integer          no-undo.
define variable v-reposition-to-recid   as logical init no  no-undo.
define variable v-enable-change-grp     as logical          no-undo.
define variable v-margins-range         as integer          no-undo.
define variable v-margins-exists        as logical          no-undo.
define variable v-increase-range         as integer          no-undo.
define variable v-increase-exists        as logical          no-undo.
define variable v-min-marg              as decimal          no-undo.
define variable v-max-marg              as decimal          no-undo.
define variable v-increase-pc              as decimal          no-undo.
define variable v-have-goods            as logical          no-undo.
define variable v-round-method      as character   no-undo .
define variable v-base                  as decimal no-undo .
define variable v-rmethod-range     as integer     no-undo.
define variable v-rmethod-exists    as logical     no-undo.
define variable v-cli-type          as character no-undo .
define variable v-cli-code          as integer     no-undo.
define variable v-income-cli-range    as integer  no-undo.
define variable v-income-cli-exists   as logical  no-undo.
define variable v-dop                   as character no-undo .
define variable v-full-name             as character    no-undo.
define variable v-sort-name             as character    no-undo.


define buffer buf_gds-grp           for gds-grp.
define buffer buf_temp_grplib_grp   for temp_grplib_grp.

{ gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reference_groups-edit':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    no
    v-enable-change-grp
}
run grplib-get-root-code in this-procedure ( output v-root-code ) no-error.
if error-status :error
then do:
    undo, return error "Не найден корневой узел." + {&new-line} + return-value.
end.
if v-from-b-gds then do:
/*ВНИМАНИЕ!!!!*/
/*здесб обрабаотна ситуация когда пользователь зашел по кнопке ТОВАРЫ в справочник товаров*/
/*если он там переключался в другие группы товаров, то это происходило через справочник групп товаров и все настройки уже сменились*/
/*мы их получим через uf-get и на выходе из справочника ТОВАРОВ постараемся встать в ту группу товаров, в которой он там стоял*/
  run uf-get in this-procedure(
      input  {&uf-gds-grp-p}
      ,input  g#userid
      ,output v-uf-List_
      ,output v-uf-Naim
      ,output v-uf-print-graft
      ,output v-uf-sort-gr
      ,output v-uf-type-price
      ,output v-uf-type-val
  )  no-error .
  if not error-status:error then
  assign
  v-dop = string((if v-uf-List_ =  {&question-mark} then ? else integer(v-uf-LIst_)))
  .
  /*если пользователь никуда не переключался по группам товаров в справочнике товаров нам не надо переоткрывать броуз - стоим на месте*/
  if v-dop = v-old-recid-list then do:
    assign
    gds-grp-row = v-old-recid
    .
  end.
  else do:
    assign
    gds-grp-row = (if v-uf-List_ =  {&question-mark} then ? else integer(v-uf-LIst_))
    .
  end.
  assign
      p-recid-list = string( gds-grp-row )
  .
  assign
  v-from-b-gds = no
  v-old-recid-list = "":U.


end.
else do:
  run uf-get in this-procedure(
      input  {&uf-gds-grp-p}
      ,input  g#userid
      ,output v-uf-List_
      ,output v-uf-Naim
      ,output v-uf-print-graft
      ,output v-uf-sort-gr
      ,output v-uf-type-price
      ,output v-uf-type-val
  )  no-error .
  if not error-status:error then
  assign
  gds-grp-row = (if v-uf-List_ =  {&question-mark} then ? else integer(v-uf-LIst_))
  .
  assign
      p-recid-list = string( gds-grp-row )
  .
end.
find first buf_gds-grp no-lock
     where buf_gds-grp.node-code = v-root-code
no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не найдена запись корневого узла."
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return error .
end.
if buf_gds-grp.is-term = yes
then do:
    run grplib-have-goods in this-procedure (
          input buf_gds-grp.node-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка определения наличия товаров в группе." + {&new-line} + return-value.
    end.
end.
for each buf_temp_grplib_grp
:
    delete buf_temp_grplib_grp.
end.
create buf_temp_grplib_grp.
assign
    buf_temp_grplib_grp.node-code   = buf_gds-grp.node-code
    buf_temp_grplib_grp.upper-code  = buf_gds-grp.upper-code
    buf_temp_grplib_grp.level       = 0
    buf_temp_grplib_grp.mark        = ( if v-have-goods = yes then {&terminal-with-goods-grp-mark} else {&terminal-no-goods-grp-mark} )
    buf_temp_grplib_grp.full-name   = {&delim-par}            /* Символ chr(1) - первый для сортировки */
    buf_temp_grplib_grp.sort-name   = {&delim-par}            /* Символ chr(1) - первый для сортировки */
    buf_temp_grplib_grp.name        = buf_gds-grp.node-name
    buf_temp_grplib_grp.increase-pc = buf_gds-grp.increase-pc
    buf_temp_grplib_grp.calc-method = buf_gds-grp.calc-method
.
for each buf_gds-grp no-lock
   where buf_gds-grp.upper-code = v-root-code
:
    run grplib-get-full-name in this-procedure (
          input buf_gds-grp.node-code
        , output v-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления полного имени группы." .
    end.
    run grplib-get-sort-name in this-procedure (
          input buf_gds-grp.node-code
        , output v-sort-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления полного имени группы." .
    end.
    run create-new-line in this-procedure (
          input buf_gds-grp.node-code
        , input buf_gds-grp.upper-code
        , input 1
        , input buf_gds-grp.is-term
        , input buf_gds-grp.node-name
        , input buf_gds-grp.increase-pc
        , input buf_gds-grp.calc-method
        , input "":U
        , input "":U
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "UI-on: Ошибка добавления строки в список групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
end.
if  p-recid-list <> "" and p-recid-list <> ?
then do:        /* Раскрыть ветку группы с recid-ом из списка */
    assign
        v-reposition-row = 1
        v-focused-row    = 1
    .
    find first buf_gds-grp no-lock
         where recid( buf_gds-grp ) = integer( entry( num-entries( p-recid-list ), p-recid-list ) )
    no-error .
    if not available buf_gds-grp
    then do:
        /* Не найдена группа, выбранная в прошлый раз. */
    end.
    else do:
        run expand-tree-for-grp in this-procedure (
            input buf_gds-grp.node-code
            , output v-focused-row
            , output v-reposition-row
            , output v-reposition-to-recid
        ) no-error .
        if error-status :error
        then do:
            undo, return error "UI-on: Не удалось раскрыть дерево групп." + {&new-line} + return-value.
        end.
    end.
end.
run enable_UI.
hide
        b-mark      in frame {&frame-name}
     .
case p-button-list
:
when {&buttons-for-move}
then do:
    disable
        b-exit    with frame {&frame-name}
    .
end.
when {&buttons-for-admin}
then do:
end.
when {&buttons-sel-scales}
then do:
end.
when {&buttons-sel-term} or when {&button-sel-only}
then do:
end.
when {&buttons-sel-mark}
then do:
    view
        b-mark in frame {&frame-name}
    .
end.
end case.
if v-current-store-code = 0
or transaction
then do:
end.

br-list :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame {&FRAME-NAME}.

run recalc-marg-ass.

if v-reposition-to-recid = no
then do:
    reposition br-list to row v-reposition-row.
end.
else do:
    reposition br-list to recid v-reposition-row.
end.
{&OPEN-QUERY-BROWSE-am-goods}

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UI-on-0 Dlg-grp
PROCEDURE UI-on-0 :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
do
on error undo, return error
:
define variable v-reposition-row        as integer          no-undo.
define variable v-focused-row           as integer          no-undo.
define variable v-reposition-to-recid   as logical init no  no-undo.
define variable v-enable-change-grp     as logical          no-undo.
define variable v-margins-range         as integer          no-undo.
define variable v-margins-exists        as logical          no-undo.
define variable v-increase-range         as integer          no-undo.
define variable v-increase-exists        as logical          no-undo.
define variable v-min-marg              as decimal          no-undo.
define variable v-max-marg              as decimal          no-undo.
define variable v-increase-pc              as decimal          no-undo.
define variable v-have-goods            as logical          no-undo.
define variable v-round-method      as character   no-undo .
define variable v-base                  as decimal no-undo .
define variable v-rmethod-range     as integer     no-undo.
define variable v-rmethod-exists    as logical     no-undo.
define variable v-cli-type          as character no-undo .
define variable v-cli-code          as integer     no-undo.
define variable v-income-cli-range    as integer  no-undo.
define variable v-income-cli-exists   as logical  no-undo.
define variable v-dop                   as character no-undo .
define variable v-full-name             as character    no-undo.
define variable v-sort-name             as character    no-undo.


define buffer buf_gds-grp           for gds-grp.
define buffer buf_temp_grplib_grp   for temp_grplib_grp.

{ gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reference_groups-edit':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    no
    v-enable-change-grp
}
run grplib-get-root-code in this-procedure ( output v-root-code ) no-error.
if error-status :error
then do:
    undo, return error "Не найден корневой узел." + {&new-line} + return-value.
end.
if v-from-b-gds then do:
/*ВНИМАНИЕ!!!!*/
/*здесб обрабаотна ситуация когда пользователь зашел по кнопке ТОВАРЫ в справочник товаров*/
/*если он там переключался в другие группы товаров, то это происходило через справочник групп товаров и все настройки уже сменились*/
/*мы их получим через uf-get и на выходе из справочника ТОВАРОВ постараемся встать в ту группу товаров, в которой он там стоял*/
  run uf-get in this-procedure(
      input  {&uf-gds-grp-p}
      ,input  g#userid
      ,output v-uf-List_
      ,output v-uf-Naim
      ,output v-uf-print-graft
      ,output v-uf-sort-gr
      ,output v-uf-type-price
      ,output v-uf-type-val
  )  no-error .
  if not error-status:error then
  assign
  v-dop = string((if v-uf-List_ =  {&question-mark} then ? else integer(v-uf-LIst_)))
  .
  /*если пользователь никуда не переключался по группам товаров в справочнике товаров нам не надо переоткрывать броуз - стоим на месте*/
  if v-dop = v-old-recid-list then do:
    assign
    gds-grp-row = v-old-recid
    .
  end.
  else do:
    assign
    gds-grp-row = (if v-uf-List_ =  {&question-mark} then ? else integer(v-uf-LIst_))
    .
  end.
  assign
      p-recid-list = string( gds-grp-row )
  .
  assign
  v-from-b-gds = no
  v-old-recid-list = "":U.


end.
else do:
  run uf-get in this-procedure(
      input  {&uf-gds-grp-p}
      ,input  g#userid
      ,output v-uf-List_
      ,output v-uf-Naim
      ,output v-uf-print-graft
      ,output v-uf-sort-gr
      ,output v-uf-type-price
      ,output v-uf-type-val
  )  no-error .
  if not error-status:error then
  assign
  gds-grp-row = (if v-uf-List_ =  {&question-mark} then ? else integer(v-uf-LIst_))
  .
  assign
      p-recid-list = string( gds-grp-row )
  .
end.

find first buf_gds-grp no-lock
     where buf_gds-grp.node-code = v-root-code
no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не найдена запись корневого узла."
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return error .
end.
if buf_gds-grp.is-term = yes
then do:
    run grplib-have-goods in this-procedure (
          input buf_gds-grp.node-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка определения наличия товаров в группе." + {&new-line} + return-value.
    end.
end.
for each buf_temp_grplib_grp
:
    delete buf_temp_grplib_grp.
end.
create buf_temp_grplib_grp.
assign
    buf_temp_grplib_grp.node-code   = buf_gds-grp.node-code
    buf_temp_grplib_grp.upper-code  = buf_gds-grp.upper-code
    buf_temp_grplib_grp.level       = 0
    buf_temp_grplib_grp.mark        = ( if v-have-goods = yes then {&terminal-with-goods-grp-mark} else {&terminal-no-goods-grp-mark} )
    buf_temp_grplib_grp.full-name   = {&delim-par}            /* Символ chr(1) - первый для сортировки */
    buf_temp_grplib_grp.sort-name   = {&delim-par}            /* Символ chr(1) - первый для сортировки */
    buf_temp_grplib_grp.name        = buf_gds-grp.node-name
    buf_temp_grplib_grp.increase-pc = buf_gds-grp.increase-pc
    buf_temp_grplib_grp.calc-method = buf_gds-grp.calc-method
.
for each buf_gds-grp no-lock
   where buf_gds-grp.upper-code = v-root-code
:
    run grplib-get-full-name in this-procedure (
          input buf_gds-grp.node-code
        , output v-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления полного имени группы." .
    end.
    run grplib-get-sort-name in this-procedure (
          input buf_gds-grp.node-code
        , output v-sort-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления полного имени группы." .
    end.
    run create-new-line in this-procedure (
          input buf_gds-grp.node-code
        , input buf_gds-grp.upper-code
        , input 1
        , input buf_gds-grp.is-term
        , input buf_gds-grp.node-name
        , input buf_gds-grp.increase-pc
        , input buf_gds-grp.calc-method
        , input "":U
        , input "":U
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "UI-on: Ошибка добавления строки в список групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
end.


    assign
        v-reposition-row = 1
        v-focused-row    = 1
    .
    for each buf_gds-grp no-lock
         /*where recid( buf_gds-grp ) = integer( entry( num-entries( p-recid-list ), p-recid-list ) ) */
         :
        run expand-tree-for-grp in this-procedure (
            input buf_gds-grp.node-code
            , output v-focused-row
            , output v-reposition-row
            , output v-reposition-to-recid
        ) no-error .
        if error-status :error
        then do:
            undo, return error "UI-on: Не удалось раскрыть дерево групп." + {&new-line} + return-value.
        end.
    end.


run enable_UI.
hide
        b-mark      in frame {&frame-name}
     .
case p-button-list
:
when {&buttons-for-move}
then do:
    disable
        b-exit    with frame {&frame-name}
    .
end.
when {&buttons-for-admin}
then do:
end.
when {&buttons-sel-scales}
then do:
end.
when {&buttons-sel-term} or when {&button-sel-only}
then do:
end.
when {&buttons-sel-mark}
then do:
    view
        b-mark in frame {&frame-name}
    .
end.
end case.
if v-current-store-code = 0
or transaction
then do:
end.

br-list :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame {&FRAME-NAME}.

run recalc-marg-ass.

if v-reposition-to-recid = no
then do:
    reposition br-list to row v-reposition-row.
end.
else do:
    reposition br-list to recid v-reposition-row.
end.
{&OPEN-QUERY-BROWSE-am-goods}

end.

for each temp_grplib_grp :
    find first temp_cons where temp_cons.node-code = temp_grplib_grp.node-code no-error .
        if not available temp_cons then create temp_cons.
        assign
            temp_cons.full-name  = temp_grplib_grp.full-name
            temp_cons.node-code  = temp_grplib_grp.node-code
            temp_cons.upper-code = temp_grplib_grp.upper-code
            temp_cons.min-marg   = temp_grplib_grp.min-marg
            temp_cons.max-marg   = temp_grplib_grp.max-marg
            temp_cons.cli-type   = temp_grplib_grp.cli-type
        .
end.

run recalc-lim in this-procedure .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ver-attr Dlg-grp
PROCEDURE ver-attr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer buf1_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
define VARIABLE v-old-grp as integer   no-undo .
define VARIABLE v-new-grp as integer   no-undo .
define VARIABLE v-ok      as logical    no-undo .
find first buf1_gds-grp-obj-attr no-lock where
           buf1_gds-grp-obj-attr.attr-code = {&ggoattr-QntyAssMat} and
           buf1_gds-grp-obj-attr.obj-type  = string(p-id) and
           buf1_gds-grp-obj-attr.obj-code  = p-db-num and
           buf1_gds-grp-obj-attr.host-code = 0 no-error .
if not available buf1_gds-grp-obj-attr then do:
   run utl/uassmgrp.p ( v-old-grp, v-new-grp, p-id , p-db-num, output v-ok ) no-error.
   if error-status :error then message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     ""
     view-as alert-box error
   .
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ver-db Dlg-grp
PROCEDURE ver-db :
if v-cntxt-db-num <> 0 then do:
    if  buf_matrix.asmt-type = {&type-assmatr-shablon}  then do:
        if v-cntxt-db-num <> buf_matrix.asmt-db-num-create then do:
          message
            "Нельзя редактировать ШАБЛОН Ассортиментная матрица созданный в чужой УБД"
            view-as alert-box error.
            return  error.
        end.
    end.
    else do:
        define variable obj-db-num as integer   no-undo .
          { gbl/objdbnum.i
          buf_matrix.obj-type
          buf_matrix.obj-code
          obj-db-num
          }

        if v-cntxt-db-num <> 0 and  v-cntxt-db-num <> obj-db-num  then do:
          message
            "Нельзя редактировать запись Ассортиментная матрица чужой УБД"
            view-as alert-box error.
            return  error.
        end.
    end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ver-db1 Dlg-grp
PROCEDURE ver-db1 :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 /* Проверка прав */   /* "actn_fin-contract_grp_mod" для спецификации */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_assort-matr-grp_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-log
  }
 if not v-log then temp_grplib_grp.cli-type:read-only in browse br-list = true .


if v-cntxt-db-num <> 0 then do:
    if  buf_matrix.asmt-type = {&type-assmatr-shablon}  then do:
        if v-cntxt-db-num <> buf_matrix.asmt-db-num-create then do:
           temp_grplib_grp.cli-type:read-only in browse br-list = true .
        end.
    end.
    else do:
        define variable obj-db-num as integer   no-undo .
          { gbl/objdbnum.i
            buf_matrix.obj-type
            buf_matrix.obj-code
            obj-db-num
          }
        if v-cntxt-db-num <> 0 and  v-cntxt-db-num <> obj-db-num  then do:
           temp_grplib_grp.cli-type:read-only in browse br-list = true .
        end.
    end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-gds-rec Dlg-grp
PROCEDURE init-gds-rec :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
if available buf_goods then do:
   gds-rec = recid (buf_goods) .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE recalc-add W-Win
PROCEDURE recalc-add :
define variable v-qntyAssgrp as integer  no-undo .
define buffer buf2_goods for ub.goods  .
define buffer loc_temp_grplib_grp for temp_cons  .
define buffer buf1_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
define variable v-recid as recid no-undo .
v-recid = recid (temp_grplib_grp) .
    for each loc_temp_grplib_grp :
        v-qntyAssgrp = 0.
        find first buf1_gds-grp-obj-attr no-lock where
                   buf1_gds-grp-obj-attr.attr-code = {&ggoattr-QntyAssMat} and
                   buf1_gds-grp-obj-attr.obj-type  = string(p-id) and
                   buf1_gds-grp-obj-attr.obj-code  = p-db-num and
                   buf1_gds-grp-obj-attr.host-code = 0 and
                   buf1_gds-grp-obj-attr.node-code = loc_temp_grplib_grp.node-code
        no-error .
        if available buf1_gds-grp-obj-attr then v-qntyAssgrp = int(buf1_gds-grp-obj-attr.attr-value) .
        assign
          loc_temp_grplib_grp.max-marg = string(v-qntyAssgrp) /* Количество товара в группе */
        .
    end.
find first temp_grplib_grp where recid(temp_grplib_grp)  = v-recid no-error .
{&OPEN-QUERY-br-list}
reposition BR-list to recid v-recid no-error.
{&OPEN-QUERY-BROWSE-am-goods}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME