&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER Buf_goods FOR ub.goods.
DEFINE BUFFER Buf_matrix-goods FOR ub.assortment-matrix-goods.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ассортиментная матрица

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

*/

/*

*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input  parameter parParentProc AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-id        like ub.assortment-matrix.asmt-id  no-undo .
define input  parameter p-db-num as integer   no-undo .
define input  parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input  parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input  parameter p-mode  as character no-undo .

define variable bttns   as character no-undo init "b-add".              /* кнопки для нажатия */
if p-mode = "no-button"  then bttns = "" .
define variable p-sts   as integer   no-undo .
define variable p-rid-list                    as character no-undo .
define variable v-gdop-min-stock              as decimal   no-undo .
define variable v-grop-max-stock              as decimal   no-undo .
define variable v-grop-level-always-presence  as decimal   no-undo .
define variable v-grop-min-order              as decimal   no-undo .
define variable v-log as logical   no-undo .
define variable is-shablonLink as logical   no-undo .
define variable is-objLink as logical   no-undo .
define variable is-objLink-id as integer   no-undo .
define variable is-objLink-db as integer   no-undo .
define variable del-option     as character no-undo .

define buffer buf_matrix for ub.assortment-matrix .

/*
define variable v-longchar as longchar no-undo .
define variable v-err-ext as logical   no-undo .
*/

find first buf_matrix no-lock where
           buf_matrix.asmt-id  = p-id     and
           buf_matrix.db-num   = p-db-num no-error .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Ассортиментныая матрица".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/prn-lib.i  }
{ gbl/cur-time.i }
{ cmp/gds-list.i  gds-list def "new shared" }
{ gbl/getcntxt.i def    }
{ gbl/getcntxt.i get    }
{ gbl/fltopend.i defproc }
{ cmp/mrk-strf.i }
{ ref/gds-matl.i }
{ ref/gds-ind1.i }
{ cmp/obj-list.i new }
{ str/asstroth.i }
{ str/ascorrm.i  }
{ gbl/assmatat.i }   /* Библиотека для работы с атрибутами АМ */
{ gbl/thbj-def.i }
{ ref/ass-mat.i &DEF_PROC=YES}    /* Процедуры и функции для работы с АМ (по задаче "Процент отклонения матрицы от шаблона") */


define variable mark-str  as character no-undo.
define variable v-doc-rec as recid no-undo.
define variable filter-point as character no-undo init "Ассортиментная матрица" .
define variable filter-point0 as character no-undo init "Состав_ассортиментной_матрицы" .
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable v-type as character no-undo .
define variable p-mark as character no-undo .
define variable p-shablon as logical   no-undo .
define variable p-indicator-life-gds as character no-undo .
define variable p-obj  as character no-undo .
define variable p-time-upd as character no-undo .
define variable p-time-cr  as character no-undo .
define variable p-status as character no-undo .
define variable gds-rec as recid no-undo .
define variable v-indicator-life-gds like  ub.gds-obj-prop.gdop-igt        column-label "ИЖТ" format "x(25)" no-undo .
define variable v-assort-min         like  ub.gds-obj-prop.gdop-assort-min column-label "AMin" format "*/ " no-undo .
define variable p-assort-min  as logical   no-undo .
define variable p-name as character no-undo .
/*
/*  */
DEFINE VARIABLE v-Character   AS CHARACTER  NO-UNDO .
DEFINE VARIABLE v-Date        AS DATE       NO-UNDO .
DEFINE VARIABLE v-Decimal     AS DECIMAL    NO-UNDO .
DEFINE VARIABLE v-gl-iProc-Otkl  AS INTEGER    NO-UNDO . /*  */
DEFINE VARIABLE v-Logical     AS LOGICAL    NO-UNDO .
DEFINE VARIABLE v-Param-Type  AS CHARACTER  NO-UNDO .
/*  */
*/

define temp-table tt-gds-list no-undo like goods
field nn as integer
index by-nn nn
index by_gds-code gds-code
.
define variable varschartic like price-list.artic initial " " no-undo.
define variable ref-list    as character no-undo.

v-err-ext = false  .
v-longchar = "".
{ ref/clearlm.i }

FUNCTION indicator-life-gds RETURNS CHARACTER
( input p-rec as recid ) :
define buffer buf_matrix-goods for ub.assortment-matrix-goods .
define variable v-gdop-min-stock              as decimal   no-undo .
define variable v-grop-max-stock              as decimal   no-undo .
define variable v-grop-level-always-presence  as decimal   no-undo .
define variable v-grop-min-order              as decimal   no-undo .

find first buf_matrix-goods no-lock where recid (buf_matrix-goods) = p-rec no-error .
if error-status :error then return '' .
{ gbl/gdsobjpr.i
  buf_Matrix-goods.obj-type
  buf_Matrix-goods.obj-code
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
  return v-indicator-life-gds.
end function.

FUNCTION f-shablon RETURNS logical
( input p-rec as recid ) :
/*Если матрица-объект Найти связный шаблон  */
define buffer buf_matrix-goods for ub.assortment-matrix-goods .
define buffer sh_assortment-matrix-goods for ub.assortment-matrix-goods  .

find first buf_matrix-goods no-lock where recid (buf_matrix-goods) = p-rec no-error .

if error-status :error then return no .
  if is-objLink = true  then do:
      find first sh_assortment-matrix-goods no-lock where
                 sh_assortment-matrix-goods.asmt-id = is-objLink-id and
                 sh_assortment-matrix-goods.db-num  = is-objLink-db and
                 sh_assortment-matrix-goods.asmg-status  = 0          and
                 sh_assortment-matrix-goods.gds-code   =  buf_matrix-goods.gds-code no-error .
        if available sh_assortment-matrix-goods then return true .
        else return false .
  end.
  else do:
    return true .
  end.

end function.

FUNCTION assort-min RETURNS logical
( input p-rec as recid ) :
define buffer buf_matrix-goods for ub.assortment-matrix-goods .
define variable v-gdop-min-stock              as decimal   no-undo .
define variable v-grop-max-stock              as decimal   no-undo .
define variable v-grop-level-always-presence  as decimal   no-undo .
define variable v-grop-min-order              as decimal   no-undo .

find first buf_matrix-goods no-lock where recid (buf_matrix-goods) = p-rec no-error .
if error-status :error then return no .
{ gbl/gdsobjpr.i
  buf_Matrix-goods.obj-type
  buf_Matrix-goods.obj-code
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
  return v-assort-min.


end function.


&SCOPED-DEFINE status-code STRING(buf_Matrix-goods.asmg-status)

&scop cop-l1       mark-string(recid( buf_Matrix-goods) , p-rid-list)
&scop dyn_cop-l1   substitute('dynamic-function(&1mark-string&1, recid(buf_Matrix-goods), &1&2&1)', ~{&double-quote~}, p-rid-list)
&scop cop-l2       Buf_goods.artic
&scop cop-l3       Buf_goods.gds-name
&scop cop-l4       Buf_matrix-goods.asmg-who-update
&scop cop-l5       Buf_matrix-goods.asmg-date-update
&scop cop-l6       STRING(buf_Matrix-goods.asmg-time-update,'HH:MM')
&scop cop-l7       Buf_matrix-goods.asmg-db-num-update
&scop cop-l8       Buf_matrix-goods.asmg-date-create
&scop cop-l9       STRING(buf_Matrix-goods.asmg-time-create,'HH:MM')
&scop cop-l10      Buf_matrix-goods.asmg-who-create
&scop cop-l11      Buf_matrix-goods.asmg-db-num-create
&scop cop-l12      {&status-int-name}
&scop cop-l13      indicator-life-gds(recid(buf_Matrix-goods))
&scop dyn_cop-l13  substitute('dynamic-function(&1indicator-life-gds&1, recid(buf_Matrix-goods))', ~{&double-quote~})
&scop cop-l14      assort-min(recid(buf_Matrix-goods))
&scop dyn_cop-l14  substitute('dynamic-function(&1assort-min&1,recid(buf_Matrix-goods))',~{&double-quote~})
&scop cop-l15      Buf_goods.grp-name
&scop cop-l16      f-shablon(recid(buf_Matrix-goods))
&scop dyn_cop-l16  substitute('dynamic-function(&1f-shablon&1,recid(buf_Matrix-goods))',~{&double-quote~})



&scop col-l1       '*'
&scop col-l2       'Артикул! '
&scop col-l3       'Название! '
&scop col-l4       'Кто!изменил'
&scop col-l5       'Дата!изменения'
&scop col-l6       'Время!изм '
&scop col-l7       'БД!изм'
&scop col-l8       'Дата!создания'
&scop col-l9       'Время! '
&scop col-l10      'Кто!создал'
&scop col-l11      'БД!соз'
&scop col-l12      'Статус! '
&scop col-l13      'ИЖТ! '
&scop col-l14      'Acc!Min'
&scop col-l15      'Группа! '
&scop col-l16      ' !Ш'


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

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-am-goods

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES Buf_matrix-goods Buf_goods

/* Definitions for BROWSE BROWSE-am-goods                               */
&Scoped-define FIELDS-IN-QUERY-BROWSE-am-goods mark-string(recid( buf_Matrix-goods) , p-rid-list) @ p-mark Buf_goods.artic STRING ( if Buf_goods.stts <> 0 then substring(Buf_goods.gds-name,1,15) + " <УДАЛЕН>" else Buf_goods.gds-name ) @ p-name Buf_matrix-goods.asmg-date-update STRING (buf_Matrix-goods.asmg-time-update, 'HH:MM' ) Buf_matrix-goods.asmg-db-num-update Buf_matrix-goods.asmg-date-create STRING (buf_Matrix-goods.asmg-time-create, 'HH:MM' ) indicator-life-gds(recid( buf_Matrix-goods) ) @ p-indicator-life-gds assort-min(recid( buf_Matrix-goods) ) @ p-assort-min Buf_matrix-goods.asmg-db-num-create {&status-int-name} @ p-status Buf_goods.grp-name Buf_goods.gds-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-am-goods Buf_matrix-goods.asmg-db-num-update
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-am-goods Buf_matrix-goods
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-am-goods Buf_matrix-goods
&Scoped-define SELF-NAME BROWSE-am-goods
&Scoped-define QUERY-STRING-BROWSE-am-goods FOR EACH Buf_matrix-goods       WHERE Buf_matrix-goods.db-num =  p-db-num         AND Buf_matrix-goods.asmt-id = p-id NO-LOCK, ~
         first Buf_goods NO-LOCK where Buf_matrix-goods.gds-code =  Buf_goods.gds-code
&Scoped-define OPEN-QUERY-BROWSE-am-goods OPEN QUERY {&SELF-NAME} FOR EACH Buf_matrix-goods       WHERE Buf_matrix-goods.db-num =  p-db-num         AND Buf_matrix-goods.asmt-id = p-id NO-LOCK, ~
         first Buf_goods NO-LOCK where Buf_matrix-goods.gds-code =  Buf_goods.gds-code .
&Scoped-define TABLES-IN-QUERY-BROWSE-am-goods Buf_matrix-goods Buf_goods
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-am-goods Buf_matrix-goods
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-am-goods Buf_goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-am-goods}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-mark-all B-mark-del-all ~
B-sel B-add B-lookup B-chg B-del B-copy B-print B-Help B-chg-izt B-grpAcc ~
RS-sts a-n-c sch-artic BROWSE-am-goods ED_asmg-des mark-num FILL-IN-1 ~
FILL-IN-7 v-user-name-create v-user-name-corr v-kol-all v-kol-in-shabl ~
v-raznost v-proc-otkl v-kol-del
&Scoped-Define DISPLAYED-OBJECTS RS-sts a-n-c sch-artic ED_asmg-des ~
mark-num FILL-IN-1 FILL-IN-7 v-user-name-create v-user-name-corr v-kol-all ~
v-kol-in-shabl v-raznost v-proc-otkl v-kol-del

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU menu-del
  MENU-ITEM m_del1   LABEL "удалить - отмеченные"
  MENU-ITEM m_del2   LABEL "удалить - по списку".


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-chg-izt
     LABEL "И&ЖТ"
     SIZE 10 BY 1 TOOLTIP "Изменить ИЖТ по выделенным товарам".

DEFINE BUTTON B-copy
     LABEL "&Копировать из"
     SIZE 14 BY 1 TOOLTIP "Копировать из .... ".

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-grpAcc
     LABEL "По &группам"
     SIZE 14 BY 1 TOOLTIP "Иерархический интерфейс".

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 2.5 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-link-obj
     IMAGE-UP FILE "cmp/link-i.bmp":U
     IMAGE-DOWN FILE "cmp/link-i.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/link-i.bmp":U
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Есть привязанные АссМатрицы".

DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-mark-all
     LABEL "&+"
     SIZE 3 BY 1 TOOLTIP "Отметить все".

DEFINE BUTTON B-mark-del-all
     LABEL "&-"
     SIZE 3 BY 1 TOOLTIP "Снять все отметки".

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 2.5 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sch
     LABEL "f"
     SIZE 2.5 BY .75.

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE ED_asmg-des AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 72 BY 2 NO-UNDO.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Статус:"
      VIEW-AS TEXT
     SIZE 7.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-7 AS CHARACTER FORMAT "X(256)":U INITIAL "Поиск:"
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 2.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sch-artic AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 14 BY 1 TOOLTIP "Поиск по артиклу" NO-UNDO.

DEFINE VARIABLE sch-code AS INTEGER FORMAT ">>>>>>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 10.5 BY 1 TOOLTIP "Поиск по коду" NO-UNDO.

DEFINE VARIABLE sch-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 37.5 BY 1 TOOLTIP "Поиск по началу Наименования" NO-UNDO.

DEFINE VARIABLE v-kol-all AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
     LABEL "Всего в АМ"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Общее количество товаров в матрице(SCU) в статусе ТЕК" NO-UNDO.

DEFINE VARIABLE v-kol-del AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
     LABEL "На вывод"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Количество товаров в матрице(SCU) с ИЖТ на вывод из ассортимента в статусе ТЕК"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-kol-in-shabl AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
     LABEL "в шаблоне"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Общее количество товаров в матрице(SCU) в статусе ТЕК" NO-UNDO.

DEFINE VARIABLE v-proc-otkl AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "% отклонения"
      VIEW-AS TEXT
     SIZE 9 BY .67 TOOLTIP "Общее количество товаров в матрице(SCU) в статусе ТЕК" NO-UNDO.

DEFINE VARIABLE v-raznost AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "разность"
      VIEW-AS TEXT
     SIZE 8.5 BY .67 TOOLTIP "Общее количество товаров в матрице(SCU) в статусе ТЕК" NO-UNDO.

DEFINE VARIABLE v-user-name-corr AS CHARACTER FORMAT "X(256)":U
     LABEL "Изменил"
      VIEW-AS TEXT
     SIZE 20 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-user-name-create AS CHARACTER FORMAT "X(256)":U
     LABEL "Создал"
      VIEW-AS TEXT
     SIZE 20.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE a-n-c AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "А", 1,
"Н", 2,
"К", 3
     SIZE 12 BY 1 TOOLTIP "Поиск товара по Артиклу, Названию , Коду" NO-UNDO.

DEFINE VARIABLE RS-sts AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Текушие-", "1",
"Все-", "2",
"Удаленные3", "3"
     SIZE 31.38 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-am-goods FOR
      Buf_matrix-goods,
      Buf_goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-am-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-am-goods Dialog-Frame _FREEFORM
  QUERY BROWSE-am-goods NO-LOCK DISPLAY
      mark-string(recid( buf_Matrix-goods) , p-rid-list) @ p-mark COLUMN-LABEL "*" FORMAT "x(1)":U
      f-shablon(recid( buf_Matrix-goods)) @ p-shablon COLUMN-LABEL " !Ш" FORMAT "+/-":U
      Buf_goods.artic FORMAT "X(16)":U COLUMN-LABEL {&col-l2}
      STRING ( if Buf_goods.stts <> 0 then substring(Buf_goods.gds-name,1,15) + " <УДАЛЕН>"  else Buf_goods.gds-name ) @ p-name COLUMN-LABEL {&col-l3} FORMAT "X(30)":U
      Buf_matrix-goods.asmg-date-update COLUMN-LABEL "Дата!изменения" FORMAT "99/99/99":U
      STRING (buf_Matrix-goods.asmg-time-update, 'HH:MM' ) FORMAT "x(5)":U  COLUMN-LABEL {&col-l6}
      Buf_matrix-goods.asmg-db-num-update COLUMN-LABEL "БД!изм" FORMAT ">>>>9":U
      Buf_matrix-goods.asmg-date-create COLUMN-LABEL "Дата!создания" FORMAT "99/99/99":U
      STRING (buf_Matrix-goods.asmg-time-create, 'HH:MM' )  FORMAT "x(5)":U COLUMN-LABEL "Время! "
      indicator-life-gds(recid( buf_Matrix-goods) ) @ p-indicator-life-gds COLUMN-LABEL "ИЖТ! " FORMAT "x(15)":U
      assort-min(recid( buf_Matrix-goods) ) @ p-assort-min COLUMN-LABEL "Acc!Min" FORMAT "*/":U
      Buf_matrix-goods.asmg-db-num-create COLUMN-LABEL "БД!соз" FORMAT ">>>>9":U
      {&status-int-name} @ p-status COLUMN-LABEL "Статус! " FORMAT "x(6)":U
      Buf_goods.grp-name COLUMN-LABEL "Группа! " FORMAT "x(45)":U
      Buf_goods.gds-code COLUMN-LABEL "Группа!код "
  ENABLE
      Buf_matrix-goods.asmg-db-num-update
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.5 BY 13.5 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-mark-all AT ROW 1 COL 14 WIDGET-ID 12
     B-mark-del-all AT ROW 1 COL 17 WIDGET-ID 14
     B-sel AT ROW 1 COL 23
     B-add AT ROW 1 COL 33
     B-lookup AT ROW 1 COL 43
     B-chg AT ROW 1 COL 53
     B-del AT ROW 1 COL 63
     B-copy AT ROW 1 COL 73.13
     B-print AT ROW 1 COL 92.38
     B-Help AT ROW 1 COL 95
     B-chg-izt AT ROW 2 COL 63 WIDGET-ID 10
     B-grpAcc AT ROW 2 COL 73.13 WIDGET-ID 8
     b-sch AT ROW 2 COL 95 WIDGET-ID 6
     RS-sts AT ROW 2.17 COL 9.63 NO-LABEL
     a-n-c AT ROW 3 COL 9.5 NO-LABEL
     sch-name AT ROW 3 COL 20.5 COLON-ALIGNED NO-LABEL
     sch-code AT ROW 3 COL 20.5 COLON-ALIGNED NO-LABEL
     sch-artic AT ROW 3 COL 20.5 COLON-ALIGNED NO-LABEL
     B-link-obj AT ROW 3 COL 94.5 WIDGET-ID 16
     BROWSE-am-goods AT ROW 4.25 COL 1
     ED_asmg-des AT ROW 19.75 COL 25.5 NO-LABEL
     mark-num AT ROW 1 COL 18.25 COLON-ALIGNED NO-LABEL
     FILL-IN-1 AT ROW 2.13 COL 1.5 NO-LABEL
     FILL-IN-7 AT ROW 2.96 COL 2.5 NO-LABEL
     v-user-name-create AT ROW 17.75 COL 8.5 COLON-ALIGNED WIDGET-ID 2
     v-user-name-corr AT ROW 17.75 COL 74.5 COLON-ALIGNED WIDGET-ID 4
     v-kol-all AT ROW 18.75 COL 12.5 COLON-ALIGNED WIDGET-ID 18
     v-kol-in-shabl AT ROW 18.75 COL 35 COLON-ALIGNED WIDGET-ID 22
     v-raznost AT ROW 18.75 COL 58 COLON-ALIGNED WIDGET-ID 24
     v-proc-otkl AT ROW 18.75 COL 84.5 COLON-ALIGNED WIDGET-ID 26
     v-kol-del AT ROW 20.25 COL 12.5 COLON-ALIGNED WIDGET-ID 20
     SPACE(73.24) SKIP(0.86)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Ассортиментная матрица".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: Buf_goods B "?" ? ub goods
      TABLE: Buf_matrix-goods B "?" ? ub assortment-matrix-goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-am-goods B-link-obj Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-del:POPUP-MENU IN FRAME Dialog-Frame       = MENU menu-del:HANDLE.

/* SETTINGS FOR BUTTON B-link-obj IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-link-obj:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON b-sch IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       b-sch:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-7 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN sch-code IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       sch-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN sch-name IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       sch-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-am-goods
/* Query rebuild information for BROWSE BROWSE-am-goods
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH Buf_matrix-goods
      WHERE Buf_matrix-goods.db-num =  p-db-num
        AND Buf_matrix-goods.asmt-id = p-id NO-LOCK,
  first Buf_goods NO-LOCK where Buf_matrix-goods.gds-code =  Buf_goods.gds-code .
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "Buf_matrix-goods.db-num = p-db-num
 AND Buf_matrix-goods.asmt-id = p-id"
     _Query            is OPENED
*/  /* BROWSE BROWSE-am-goods */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "NO-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Ассортиментная матрица */
OR ENDKEY OF FRAME Dialog-Frame
OR END-ERROR OF FRAME DIALOG-FRAME    /* ESC */
DO:
  run gbl/markqwa.p
      ( input b-mark:sensitive
      , input p-rid-list ) no-error.
  if error-status:error then return no-apply.
  if buf_matrix.asmt-type <> {&type-assmatr-shablon} then return .

  /* Если шаблон и если есть связанные Объектные матрицы, транслируем туда */
   run translate-to-other ( buf_matrix.asmt-id, buf_matrix.db-num ).
    if v-longchar-asstro <> ""  then do:
    define variable v-ok as logical   no-undo .
    run gbl/d-longchar.w (
            ?,
            'Editor_row=2\':u
          + 'title=При транслировании в Ассортиментные матрицы\':u
          + 'Editor_col=1\':u
          + 'Editor_width=96\':u
          + 'Editor_height=21\':u
          + 'readonly=yes\':u
        ,input-output v-longchar-asstro
        ,output v-ok ) no-error .
        v-longchar-asstro = "" .
        { ref/clearlm.i }
    end.
   return .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME a-n-c
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL a-n-c Dialog-Frame
ON VALUE-CHANGED OF a-n-c IN FRAME Dialog-Frame
DO:
  ASSIGN a-n-c .
  case a-n-c  :
  when 1 then do:
    enable sch-artic with frame {&frame-name} .
    hide sch-name sch-code in frame {&frame-name} .
  end.
  when 2 then do:
    enable sch-name with frame {&frame-name} .
    hide sch-artic sch-code in frame {&frame-name} .

  end.
  when 3  then do:
    enable sch-code with frame {&frame-name} .
    hide sch-name sch-artic in frame {&frame-name} .
  end.

  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  define variable loc#log as logical no-undo.
  define variable loc-doc-rec as recid no-undo .
  DEFINE VARIABLE cError as CHARACTER NO-UNDO INITIAL "".

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

  /* Предварительная проверка допустимого процента отклонения  */
  RUN Cntrl-AM-Add-1 IN THIS-PROCEDURE(
      0,
      OUTPUT cError
      ).
  if cError <> "" THEN DO:
     MESSAGE cError
         VIEW-AS ALERT-BOX INFO BUTTONS OK.
     RETURN NO-APPLY.
  END.

  /*  */
  run proc-add in this-procedure (output loc-doc-rec ) no-error  .
  if error-status:error then DO:
     message
  error-status :get-message(1)
  return-value
  view-as alert-box error
  .
     /*  */
     RETURN NO-APPLY.
  END.

  if loc-doc-rec <> ? THEN DO:
      run openbr in this-procedure .
      reposition {&BROWSE-NAME} to recid loc-doc-rec no-error.
      {&cant-positioning}
     /* При добавлениии пересчитать итоги */
     RUN Calc-itogi in THIS-PROCEDURE.
     /*  */
  END.

  apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
  apply "value-changed" to {&BROWSE-NAME} in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .

if not available {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}} then return no-apply.

if  {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.asmg-status = 1  then do:
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
loc-doc-rec = recid({&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}).

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
      ,input {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.asmt-id
      ,input {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.db-num
      ,input-output loc-doc-rec
    ) no-error
   .
   if loc-doc-rec <> ? THEN DO:
       run openbr in this-procedure .
       reposition {&BROWSE-NAME} to recid loc-doc-rec no-error.
       {&cant-positioning}
   END.

   apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
   apply "value-changed" to {&BROWSE-NAME} in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg-izt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg-izt Dialog-Frame
ON CHOOSE OF B-chg-izt IN FRAME Dialog-Frame /* ИЖТ */
DO:
define variable v-log as logical   no-undo .
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .

if not available buf_matrix-goods then return no-apply.

 /* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_assort-izt_update':U
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
loc-doc-rec = recid(buf_matrix-goods).

if  buf_matrix.asmt-type = {&type-assmatr-shablon} then do:
    message "Корректировать ИЖТ можно  в  АССОРТИМЕНТНОЙ МАТРИЦЕ объекта"
    view-as alert-box information .
    return no-apply.
end.

if  buf_matrix.asmt-status = 1  then do:
    message "Корректировать ИЖТ можно  в  АССОРТИМЕНТНОЙ МАТРИЦЕ в статусе тек."
    view-as alert-box information .
    return no-apply.
end.

run ver-db no-error .
if error-status :error then return no-apply .
loc#log = false .
if num-entries(p-rid-list) > 0 then do:
      message "Корректировать ИЖТ на выделенных записях ?"
      view-as alert-box question
      buttons yes-no update v-logq as logical .
      if v-logq = false then return no-apply .
    end.
    else do:
        if available Buf_matrix-goods  then do:
           loc#log = true .
           p-rid-list = string( recid(Buf_matrix-goods)) .
        end.
        else do:
          message "Не выделено ни одной записи"
          view-as alert-box information .
          return no-apply.
        end.
    end.

  run proc-b-izt in this-procedure ( p-rid-list ) no-error.
  if error-status:error then return no-apply.
  if loc#log = true then p-rid-list = "" .
  if loc-doc-rec <> ? then do:
    run openbr in this-procedure .
    reposition {&browse-name} to recid loc-doc-rec no-error.
    {&cant-positioning}
  end.
  apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
  apply "value-changed" to {&BROWSE-NAME} in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-copy Dialog-Frame
ON CHOOSE OF B-copy IN FRAME Dialog-Frame /* Копировать из */
DO:
  define variable loc#log as logical no-undo.
  define variable loc-doc-rec as recid no-undo .
  DEFINE VARIABLE cError as CHARACTER NO-UNDO INITIAL "".

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
 /* Предварительная проверка допустимого процента отклонения  */
 RUN Cntrl-AM-Add-1 IN THIS-PROCEDURE(
     0,
     OUTPUT cError
     ).
 if cError <> "" THEN DO:
    MESSAGE cError
        VIEW-AS ALERT-BOX INFO BUTTONS OK.
    RETURN NO-APPLY.
 END.

  /* Раньше была транзакция  */
    run proc-copy in this-procedure (output loc-doc-rec ) no-error  .
  if error-status :error then DO:
     message
    error-status :get-message(1)
    return-value .
     RETURN NO-APPLY.
  END.

  if loc-doc-rec <> ? THEN DO:
      run openbr in this-procedure .
      /*reposition {&BROWSE-NAME} to recid loc-doc-rec no-error.
      {&cant-positioning}
      */
  END.

  apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
  apply "value-changed" to {&BROWSE-NAME} in frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
define variable is-many as logical   no-undo .
  if del-option = "":U then do:
     run gbl/pop-up.p ( input self :handle, input yes ) no-error.
     if error-status :error then do:
     return no-apply. end.
  end.
  if del-option = "":U then do:
      return no-apply.
  end.

if del-option = "list":U then do: /*удаляем по списку*/
assign
  p-rid-list = ""
  del-option = ""
.
  run str/gds-list.w (input parparentproc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code ) no-error .
  for each gds-list :
     find first buf_matrix-goods
     where buf_matrix-goods.gds-code = gds-list.gds-code
     and Buf_matrix-goods.db-num = p-db-num
     and Buf_matrix-goods.asmt-id = p-id
     no-error.
     if available buf_matrix-goods then do :
           if p-rid-list = "" then do :
              assign p-rid-list = string( recid(Buf_matrix-goods)) .
           end.
           else do :
              assign p-rid-list = p-rid-list + "," + string( recid(Buf_matrix-goods)) .
           end.
     end.
     else do :
        message
          substitute( "Выбранный товар &1 &2", gds-list.artic, gds-list.gds-name ) skip
          "не входит в данную Ассортиментную матрицу"
        view-as alert-box information.
     end.
  end.
  run ver-db no-error .
  if error-status :error then return no-apply .
  assign is-many = true .
end. /*if del-option = "list":U then do:*/
else do :  /*удаляем отмеченные*/
  assign
    is-many = false
    del-option = ""
  .
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
    assign is-many = true .
  end.
end.
run proc-b-del in this-procedure ( p-rid-list , is-many ) no-error.
if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-grpAcc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-grpAcc Dialog-Frame
ON CHOOSE OF B-grpAcc IN FRAME Dialog-Frame /* По группам */
DO:
/* buf_matrix */
run ver-db no-error .
if error-status :error then return no-apply .

if  buf_matrix.asmt-status = 1  then do:
    message "Корректировать можно  в  АССОРТИМЕНТНОЙ МАТРИЦЕ в статусе тек."
    view-as alert-box information .
    return no-apply.
end.

  define variable ri-list as character no-undo .

  run ref/grp-ass.w (
     input parparentproc,
     input p-db-num,
     input p-id,
     input '',
     input v-cntxt-obj-type,
     input v-cntxt-obj-code,
     input-output ri-list) .
  run openbr in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}} then return no-apply.

assign
loc-doc-rec = recid({&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}).
   run ref/gds-mati.w
    (  input parParentProc
      ,input {&LOOKUP}
      ,input {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.asmt-id
      ,input {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.db-num
      ,input-output loc-doc-rec
      ) no-error   .
   apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if AVAILABLE {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}  then do:
    { gbl/markstrn.i {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}} p-rid-list }
    loc#log = {&BROWSE-NAME}:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = {&BROWSE-NAME}:select-next-row ().
        apply "VALUE-CHANGED" to {&BROWSE-NAME} in frame {&frame-name}.
    end.
    if num-entries( p-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( p-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark-all Dialog-Frame
ON CHOOSE OF B-mark-all IN FRAME Dialog-Frame /* + */
DO:
  define variable loc#log as logical no-undo .

p-rid-list = "" .
IF p-sts = ? THEN DO:
    for each buf_Matrix-goods no-lock where Buf_matrix-goods.db-num = p-db-num  AND Buf_matrix-goods.asmt-id = p-id :
      { gbl/markstrn.i buf_Matrix-goods p-rid-list }
    end.
END.
ELSE DO:
    for each buf_Matrix-goods no-lock where  buf_matrix-goods.db-num = p-db-num  and buf_matrix-goods.asmt-id = p-id and buf_matrix-goods.asmg-status = p-sts :
     { gbl/markstrn.i buf_Matrix-goods p-rid-list }
    end.
end.
  run openbr in this-procedure .
  apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark-del-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark-del-all Dialog-Frame
ON CHOOSE OF B-mark-del-all IN FRAME Dialog-Frame /* - */
DO:
   p-rid-list  = "".
  run openbr in this-procedure .
  apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
  apply "WINDOW-CLOSE" to {&BROWSE-NAME} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
   IF  p-rid-list = "" THEN DO:
      IF AVAILABLE buf_matrix-goods THEN p-rid-list = string(RECID(buf_matrix-goods)).
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-am-goods
&Scoped-define SELF-NAME BROWSE-am-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-am-goods Dialog-Frame
ON ROW-DISPLAY OF BROWSE-am-goods IN FRAME Dialog-Frame
DO:
define buffer sh_assortment-matrix-goods for ub.assortment-matrix-goods  .
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
              p-indicator-life-gds:bgcolor  in browse {&browse-name}   = 14 . /* желтый */
            end.
            when {&ass-izd-del} then do:
              p-indicator-life-gds:bgcolor  in browse {&browse-name}   = 12 .  /* красный */
            end.
            when {&ass-izd-spec} then do:
              p-indicator-life-gds:bgcolor  in browse {&browse-name}   = 8 .  /* серый */
            end.

        end case.
        if buf_goods.stts <> 0 then p-name:fgcolor  in browse {&browse-name}   = 12 .  /* красный */

        /*Если матрица-объект Найти связный шаблон и отметить артикул Синим */
            Buf_goods.artic:fgcolor  in browse {&browse-name}   = ? .
            p-shablon:fgcolor  in browse {&browse-name}         = ?.

            if is-objLink = true  then do:
                if not f-shablon ( recid (buf_matrix-goods )) then do:
                   Buf_goods.artic:fgcolor  in browse {&browse-name}   = 9 .  /* ярко синий */
                   p-name:fgcolor     in browse {&browse-name}   = 9 .  /* ярко синий */
                   p-shablon:fgcolor  in browse {&browse-name}   = 9 .  /* ярко синий */
                end.
            end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-am-goods Dialog-Frame
ON VALUE-CHANGED OF BROWSE-am-goods IN FRAME Dialog-Frame
DO:
    if available buf_matrix-goods then do:
        ed_asmg-des = buf_matrix-goods.asmg-des .
        display ed_asmg-des with frame {&frame-name}.

    { gbl/usrfulnm.i
      buf_matrix-goods.asmg-who-create
      v-user-name-create
    }
    { gbl/usrfulnm.i
      buf_matrix-goods.asmg-who-update
      v-user-name-corr
    }
    end.
    display v-user-name-corr v-user-name-create  with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_del1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_del1 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_del1 /* удалить - отмеченные */
DO:
  assign
    del-option = "mark":U
  .
  APPLY "CHOOSE" TO b-del IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_del2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_del2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_del2 /* удалить - по списку */
DO:
  assign
    del-option = "list":U
  .
  APPLY "CHOOSE" TO b-del IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-sts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-sts Dialog-Frame
ON VALUE-CHANGED OF RS-sts IN FRAME Dialog-Frame
DO:

  run openbr in this-procedure no-error.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-artic
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-artic Dialog-Frame
ON CTRL-J OF sch-artic IN FRAME Dialog-Frame
DO:
  run proc-find-artic in this-procedure ( yes, input frame {&frame-name} sch-artic) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-artic Dialog-Frame
ON RETURN OF sch-artic IN FRAME Dialog-Frame
DO:
  run proc-find-artic in this-procedure ( no , input frame {&frame-name} sch-artic ) no-error.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON CTRL-J OF sch-code IN FRAME Dialog-Frame
DO:
  run proc-find-code in this-procedure ( yes, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON RETURN OF sch-code IN FRAME Dialog-Frame
DO:
  run proc-find-code in this-procedure ( no, input frame {&frame-name} sch-code) no-error.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-name Dialog-Frame
ON CTRL-J OF sch-name IN FRAME Dialog-Frame
DO:
  run proc-find-name in this-procedure ( yes, input frame {&frame-name} sch-name) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-name Dialog-Frame
ON RETURN OF sch-name IN FRAME Dialog-Frame
DO:
  run proc-find-name in this-procedure ( no, input frame {&frame-name} sch-name ) no-error.
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

 /* F5 */
{ gbl/brwrefre.i " assign v-doc-rec = ?. ~
if available Buf_matrix-goods then v-doc-rec = recid(Buf_matrix-goods). ~
run OpenBr. ~
reposition BROWSE-am-goods to recid v-doc-rec no-error. ~
apply 'entry' to BROWSE-am-goods. " }


{ gbl/srt-clmd.i
  &browse-name      = "{&browse-name}"
  &frame-name       = "{&frame-name}"
  &table-name       = buf_Matrix
  &label-clmn_1     =   "{&col-l1}"
  &label-clmn_2     =   "{&col-l2}"
  &label-clmn_3     =   "{&col-l3}"
  &label-clmn_4     =   "{&col-l4}"
  &label-clmn_5     =   "{&col-l5}"
  &label-clmn_6     =   "{&col-l6}"
  &label-clmn_7     =   "{&col-l7}"
  &label-clmn_8     =   "{&col-l8}"
  &label-clmn_9     =   "{&col-l9}"
  &label-clmn_10    =   "{&col-l10}"
  &label-clmn_11    =   "{&col-l11}"
  &label-clmn_12    =   "{&col-l12}"
  &label-clmn_13    =   "{&col-l13}"
  &label-clmn_14    =   "{&col-l14}"
  &label-clmn_15    =   "{&col-l15}"
  &label-clmn_16    =   "{&col-l16}"
  &sort-clmn_1      =   "{&cop-l1}"
  &dyn_sort-clmn_1    =   "{&dyn_cop-l1}"
  &sort-clmn_2    =   "{&cop-l2}"
  &sort-clmn_3    =   "{&cop-l3}"
  &sort-clmn_4    =   "{&cop-l4}"
  &sort-clmn_5    =   "{&cop-l5}"
  &sort-clmn_6    =   "{&cop-l6}"
  &sort-clmn_7    =   "{&cop-l7}"
  &sort-clmn_8    =   "{&cop-l8}"
  &sort-clmn_9    =   "{&cop-l9}"
  &sort-clmn_10   =   "{&cop-l10}"
  &sort-clmn_11   =   "{&cop-l11}"
  &sort-clmn_12   =   "{&cop-l12}"
  &sort-clmn_13   =   "{&cop-l13}"
  &dyn_sort-clmn_13    =   "{&dyn_cop-l13}"
  &sort-clmn_14        =   "{&cop-l14}"
  &dyn_sort-clmn_14    =   "{&dyn_cop-l14}"
  &sort-clmn_15        =   "{&cop-l15}"
  &sort-clmn_16        =   "{&cop-l16}"
  &dyn_sort-clmn_16    =   "{&dyn_cop-l16}"
  &open-query           = "run OpenBr."
  &open-query-otherwise = "run OpenBr."
  &sort-column-name     = "sort-column-name"
  &re-move-clmn   = "no"
  &mv-brw-default = "no"
}

{ gbl/f2.i {&BROWSE-name} goods-recid init-gds-rec parParentProc }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
 /* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_assort-matr-gds_lookup':U
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
 if not v-log then return .


/* Снимаем допустимый процент отклонения из настроек  */
RUN Get-Gl-Set-Proc-Otkl IN THIS-PROCEDURE(
    buf_Matrix.obj-type,
    buf_Matrix.obj-code
    ).


MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/curdbnum.i v-db-num }
  run ini-proc in this-procedure .
  run my_enable in this-procedure .
   hide mark-num in frame {&frame-name} .
  if v-doc-rec <> ? then
  reposition {&browse-name} to recid v-doc-rec no-error.
    { gbl/mv-clmn.i
    &browse-name = "{&browse-name}"
    &frame-name = "{&frame-name}"
    &ext-col = 16
    &start-column = 1
    }


  apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus {&browse-name}.

END.
run disable_ui in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assort-polit Dialog-Frame
PROCEDURE assort-polit :
do
on error undo, return error return-value
:

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-itogi Dialog-Frame
PROCEDURE calc-itogi :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE BUFFER Buf_matrix-goods1 FOR ub.assortment-matrix-goods.
/*  */
DEFINE VARIABLE  v-value as CHARACTER  NO-UNDO INITIAL "".
/*  */
DEFINE VARIABLE  lIsObj       as LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE  v-iAsmt-id   as INTEGER    NO-UNDO INITIAL 0.
DEFINE VARIABLE  v-iDb-num    as INTEGER    NO-UNDO INITIAL 0.
DEFINE VARIABLE  v-type       as CHARACTER  NO-UNDO INITIAL "".
DEFINE VARIABLE  cError       as CHARACTER  NO-UNDO INITIAL "".

ASSIGN
   v-kol-all       = 0
   v-kol-del       = 0
   v-kol-in-shabl  = 0
   v-raznost       = 0
   v-proc-otkl     = 0
   .

/***********************************************
/* Cнимаем параметры по АМ */
RUN Get-Gl-Param-AM-All in THIS-PROCEDURE(
    p-Id,
    p-Db-num
    ).
*********************************************/

/* Параметры снимаем общей процедурой  */
RUN Get-Gl-Param-Proc-Otkl in THIS-PROCEDURE(
    p-Id,
    p-Db-num,
    OUTPUT cError
    ).
if cError <> "" THEN DO:
   MESSAGE
      PROGRAM-NAME(1) ":"  SKIP
      "Ошибок быть не должно !" SKIP
      cError SKIP
      VIEW-AS ALERT-BOX INFO BUTTONS OK.
END.

/* Здесь устанавливаем локальные переменные интерфейса из GL переменных  подсчитанных процедурой  */
ASSIGN
   v-kol-all       = v-gl-iAM-Gds-All
   v-kol-del       = v-gl-iAM-Gds-Vyv
   v-kol-in-shabl  = v-gl-iAM-Sbl-Gds-All
   /* Разность подсчитываем только для объектной матрицы связанной с шаблоном */
   v-raznost       = (IF v-gl-lAM-Is-Obj AND v-gl-lAM-Ref-Shablon
                         THEN (v-gl-iAM-Gds-All  - v-gl-iAM-Sbl-Gds-All)
                         ELSE 0)
   v-proc-otkl     = v-gl-dAM-Proc-Otkl
   .

DISPLAY
   v-kol-all
   v-kol-del
   v-kol-in-shabl
   v-raznost
   v-proc-otkl
   WITH FRAME {&FRAME-NAME}.

/* */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-tt-gds Dialog-Frame
PROCEDURE create-tt-gds :
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-status as integer   no-undo .
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
find first temp-goods where
  temp-goods.gds-code = p-gds-code no-error .
  if not available temp-goods then create temp-goods.
    assign
      temp-goods.gds-code = p-gds-code
      temp-goods.status_ = p-status
      .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE econom-mode Dialog-Frame
PROCEDURE econom-mode :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define output parameter p-is as logical   no-undo .
p-is = true .

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
  DISPLAY RS-sts a-n-c sch-artic ED_asmg-des mark-num FILL-IN-1 FILL-IN-7
          v-user-name-create v-user-name-corr v-kol-all v-kol-in-shabl v-raznost 
          v-proc-otkl v-kol-del 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-mark-all B-mark-del-all B-sel B-add B-lookup B-chg
         B-del B-copy B-print B-Help B-chg-izt B-grpAcc RS-sts a-n-c sch-artic
         BROWSE-am-goods ED_asmg-des mark-num FILL-IN-1 FILL-IN-7
         v-user-name-create v-user-name-corr v-kol-all v-kol-in-shabl v-raznost 
         v-proc-otkl v-kol-del 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ini-proc Dialog-Frame
PROCEDURE ini-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer obj_assortment-matrix for ub.assortment-matrix  .
define buffer sh_assortment-matrix for ub.assortment-matrix  .

  for each temp-goods :
      delete temp-goods.
  end.
  is-shablonLink = false .
  is-objLink = false .

  if buf_matrix.asmt-type <> {&type-assmatr-obj}  then do:

   for each obj_assortment-matrix no-lock where
            obj_assortment-matrix.asmt-status = 0 and
            obj_assortment-matrix.asmt-type = {&type-assmatr-obj} ,
      first ub.assortment-matrix-attr no-lock where
            ub.assortment-matrix-attr.asmt-id    = obj_assortment-matrix.asmt-id and
            ub.assortment-matrix-attr.db-num     = obj_assortment-matrix.db-num and
            ub.assortment-matrix-attr.attr-code  = {&assmatat-RootShablon} and
            ub.assortment-matrix-attr.attr-value = substitute("&1&3&2" , buf_matrix.asmt-id,buf_matrix.db-num,{&delim-par})
            :
            is-shablonLink = true  .
            leave.
   end.
  end.
  else do:
    find first ub.assortment-matrix-attr no-lock where
          ub.assortment-matrix-attr.asmt-id    = buf_matrix.asmt-id and
          ub.assortment-matrix-attr.db-num     = buf_matrix.db-num and
          ub.assortment-matrix-attr.attr-code  = {&assmatat-RootShablon}
     no-error .
     if available ub.assortment-matrix-attr then do:
        find first sh_assortment-matrix no-lock where
                    sh_assortment-matrix.asmt-status = 0 and
                    sh_assortment-matrix.asmt-type   = {&type-assmatr-shablon} and
                    sh_assortment-matrix.asmt-id     = int(entry(1,ub.assortment-matrix-attr.attr-value,{&delim-par})) and
                    sh_assortment-matrix.db-num = int(entry(2,ub.assortment-matrix-attr.attr-value,{&delim-par})) no-error .

        if available sh_assortment-matrix then do:
           assign
            is-objLink = true
            is-objLink-id = sh_assortment-matrix.asmt-id
            is-objLink-db = sh_assortment-matrix.db-num
          .
        end.
     end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-gds-rec Dialog-Frame
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my_enable Dialog-Frame
PROCEDURE my_enable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-db-num like ub.db.db-num no-undo .
{ gbl/curdbnum.i v-db-num }

Buf_matrix-goods.asmg-db-num-update:read-only in browse {&browse-name} = true .
p-indicator-life-gds:resizable in browse {&browse-name} = true .
p-name:resizable  in browse {&browse-name} = true .
p-indicator-life-gds:width in browse {&browse-name} = 8.

ASSIGN
rs-sts:RADIO-BUTTONS IN FRAME {&FRAME-NAME}
              = "Текущие&+" + {&comma-char} +  {&current-status-int} + {&comma-char} +
              "Все&!" + {&comma-char} + {&all} + {&comma-char} +
              "Удаленные&-" + {&comma-char} + {&deleted-status-int}
rs-sts = (IF p-sts = ? THEN {&current-status-int} ELSE string(p-sts))

.

rs-sts = {&current-status-int} .
DISPLAY mark-num
FILL-IN-1
RS-sts
fill-in-7
WITH FRAME Dialog-Frame.

if is-shablonLink then enable B-link-obj with frame {&frame-name} .
else do:
  disable B-link-obj with frame {&frame-name} .
  hide B-link-obj in frame {&frame-name} .
end.


if is-objLink then do:
 p-shablon:visible  in browse {&browse-name} = true   .
end.
else do:
 p-shablon:visible  in browse {&browse-name} = false  .
end.

ENABLE
b-quit
B-mark when transaction = false
B-mark-all when transaction = false
B-mark-del-all when transaction = false
B-sel when LOOKUP("b-sel":U, bttns) > 0
B-add when LOOKUP("b-add":U, bttns) > 0  and transaction = false
B-lookup
B-chg when LOOKUP("b-add":U, bttns) > 0  and transaction = false
B-del when LOOKUP("b-add":U, bttns) > 0   and transaction = false
B-print
B-grpAcc
B-Help
B-copy when LOOKUP("b-add":U, bttns) > 0   and transaction = false
{&browse-name}
mark-num
RS-sts
ed_asmg-des
a-n-c
sch-artic
B-chg-izt when LOOKUP("b-add":U, bttns) > 0  and transaction = false
with FRAME Dialog-Frame.
/*VIEW FRAME Dialog-Frame.*/
if buf_matrix.asmt-type <> {&type-assmatr-obj}  then do:
   hide B-grpAcc in frame {&frame-name} .
end.
ed_asmg-des:READ-ONLY = TRUE.
run openbr in this-procedure no-error.
IF ERROR-STATUS:ERROR  THEN RETURN error.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openBr Dialog-Frame
PROCEDURE openBr :
define variable p-open-query     as logical   no-undo init true .
def var l-query-was-opened as logical no-undo .
define variable doc-rec  as recid     no-undo .
define variable  p-find-next      as logical   no-undo .
define variable  p-find-condition as character no-undo .

ASSIGN  FRAME {&FRAME-NAME}
  rs-sts
    .
ASSIGN
  p-sts = (IF rs-sts = {&all} THEN ? ELSE INTEGER(rs-sts))
  .


def var sort-column-phrase as character no-undo .

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

define variable title0 as character no-undo init "Ассортиментная матрица" .

 title0 = "Ассортиментная матрица " + buf_matrix.asmt-name.

&scop flt-open-open-query OPEN QUERY BROWSE-am-goods FOR EACH Buf_matrix-goods no-lock

&scop flt-open-dyn_open-query  FOR EACH Buf_matrix-goods

&scop flt-open-query-handle query BROWSE-am-goods:handle

&scop flt-open-find-buffer-name Buf_matrix-goods

&scop flt-open-open-query-tail , first Buf_goods NO-LOCK where Buf_matrix-goods.gds-code = Buf_goods.gds-code

&scop flt-open-query-was-opened     l-query-was-opened

&scop flt-open-sort-column-phrase   sort-column-phrase

&scop flt-open-call-point           filter-point

&scop flt-open-set-filter-name      set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-query               p-open-query

&scop flt-open-table-name          buf_matrix-goods

&scop flt-open-search-option       no-lock

&scop flt-open-find-next           p-find-next

&scop flt-open-find-recid          doc-rec

&scop flt-open-find-condition       p-find-condition

&scop flt-open-find-buffer-def      define buffer buf_Matrix-goods for ub.assortment-matrix-goods.

&scop flt-open-debug-file

&scop flt-open-waitfram             true



IF p-sts = ? THEN DO:
    frame {&frame-name}:TITLE = title0  .
  { gbl/fltopend.i
    &where-cond = " Buf_matrix-goods.db-num = p-db-num  AND Buf_matrix-goods.asmt-id = p-id "
    &dyn_where-cond = " substitute(' Buf_matrix-goods.db-num = &1 AND Buf_matrix-goods.asmt-id = &2 ' , p-db-num , p-id  ) "
    &use-ind    = "  "
    &by         = " " }


END.
ELSE DO:
&SCOPED-DEFINE status-code STRING(p-sts)
    frame {&frame-name}:TITLE = title0 + {&space-char} + {&status-int-name}.
      { gbl/fltopend.i
        &where-cond = " buf_matrix-goods.db-num = p-db-num  and buf_matrix-goods.asmt-id = p-id and buf_matrix-goods.asmg-status = p-sts "
        &dyn_where-cond = " substitute(' Buf_matrix-goods.db-num = &1 AND Buf_matrix-goods.asmt-id = &2 and buf_Matrix-goods.asmg-status = &3' , p-db-num , p-id , p-sts ) "
        &use-ind    = "  "
        &by         = " " }

END.



APPLY "VALUE-CHANGED" TO {&BROWSE-NAME} in frame {&frame-name}.
APPLY "ENTRY" TO {&BROWSE-NAME}.
RUN calc-itogi .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add Dialog-Frame
PROCEDURE proc-add :
/* -----------------------------------------------------------
  Purpose: добавление списка товаров
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define output parameter p-doc-rec as recid no-undo .
define variable v-host-code as integer   no-undo .
/*  */
DEFINE VARIABLE dTmp-1 as DECIMAL NO-UNDO INITIAL 0.
DEFINE VARIABLE dTmp-2 as DECIMAL NO-UNDO INITIAL 0.
DEFINE VARIABLE dTmp-3 as DECIMAL NO-UNDO INITIAL 0.
DEFINE VARIABLE iCountGds as INTEGER    NO-UNDO INITIAL 0.
DEFINE VARIABLE cTmp      as CHARACTER  NO-UNDO INITIAL "".
DEFINE VARIABLE iDelta    as INTEGER    NO-UNDO INITIAL 0.
DEFINE VARIABLE cError    as CHARACTER  NO-UNDO INITIAL "".


{ gbl/hostcode.i
 p-curr-obj-type
 p-curr-obj-code
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
 v-longchar = "" .
 v-err-ext = false .

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

 run waitfram-show in this-procedure ( "Добавление товаров в ассортиментную матрицу ... " ) .
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
          v-longchar = v-longchar + return-value  + {&new-line}.
          v-err-ext  = true  .
          next.
       end.
       run create-tt-gds in this-procedure  (tt-gds-list.gds-code, 0 ) .
 end.

run waitfram-hide in this-procedure .

if v-err-ext = true  then do:
define variable v-ok as logical   no-undo .
  run gbl/d-longchar.w (
      ? ,
        'Editor_row=2\':u
      + 'title=При добавлении в Ассортиментные матрицы\':u
      + 'Editor_col=1\':u
      + 'Editor_width=96\':u
      + 'Editor_height=21\':u
      + 'readonly=yes\':u
    ,input-output v-longchar
    ,output v-ok ) no-error .
end.

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
define input  parameter p-recid as character no-undo .
define input  parameter p-model as logical   no-undo .

define variable loc#log as logical no-undo.
define variable v-log as logical   no-undo .
define variable v-sts like ub.assortment-matrix-goods.asmg-status no-undo .
define variable loc-doc-rec as recid no-undo.
define variable i as integer   no-undo .

/*if not available buf_matrix-goods then return error.*/

do
on error undo, return error
on stop undo, return error

:
v-err-ext  = false   .
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
       message return-value
       view-as alert-box information .
       undo, return error.
    end.
    run create-tt-gds in this-procedure  (buf_Matrix-goods.gds-code, 1 ) .
    if return-value <> "" then message  substitute("&1 &2" ,buf_Matrix-goods.gds-code, return-value  ) view-as alert-box information .
  end.
  else do:
      v-longchar = "".
      v-err-ext  = false   .

      repeat i = 1 to num-entries(p-recid) :
      find first buf_Matrix-goods no-lock where
           recid(buf_Matrix-goods) = integer(entry(i,p-recid )) no-error .
        if buf_Matrix-goods.asmg-status = 0 then do:
            { ref/gds-mat2.i
               this-procedure
               entry(i,p-recid)
               v-sts
               false
               no-error }
               if error-status :error then do:
                  v-longchar = v-longchar + return-value  + {&new-line}.
                  v-err-ext  = true  .
               end.
               if not error-status :error then do:
                  run create-tt-gds in this-procedure  (buf_Matrix-goods.gds-code, 1 ) .
                  if return-value <> "" then do:
                      v-longchar = v-longchar + substitute("&1 &2&3" ,buf_Matrix-goods.gds-code, return-value ,{&new-line}) .
                      v-err-ext  = true  .
                  end.
               end.
        end.
      end.
    assign
      p-recid = ""
      p-rid-list = ""
    .
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
    end.

  end.
  run openbr in this-procedure .
  REPOSITION {&browse-name} to recid loc-doc-rec No-error.
  {&cant-positioning}
  if available buf_Matrix-goods then do:
    loc#log = {&browse-name}:select-focused-row( ) IN FRAME {&FRAME-NAME}.
    loc#log = {&BROWSE-NAME}:refresh() .
  end.
  /* Пересчет итогов после удаления */
  RUN calc-itogi IN THIS-PROCEDURE.
  /*  */
  apply "ENTRY" to {&browse-name}.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-izt Dialog-Frame
PROCEDURE proc-b-izt :
define input  parameter p-recid as character no-undo .
  do
  on error undo, return error return-value
  :
  define variable i as integer   no-undo .
  define variable v-old as character no-undo .
  define variable v-new as character no-undo .
     empty temp-table gds-list.
     empty temp-table obj-list.

      repeat i = 1 to num-entries(p-recid) :
        find first buf_Matrix-goods no-lock where
              recid(buf_Matrix-goods) = integer(entry(i,p-recid)) no-error .

        find first buf_goods no-lock where
                   buf_goods.gds-code = buf_Matrix-goods.gds-code.
              create gds-list.
              buffer-copy buf_goods to gds-list.
      end.
  run create_obj-list ( buf_matrix.obj-type , buf_matrix.obj-code ) .
  run ref/graf-igt.w ( output v-old, output v-new ) .
      if not ( v-old = "" and v-new = "" )  then do:
          run ref/chg-igt.p
            ( input v-old, input v-new , input true ) no-error  .
              if error-status :error then
              message
                vss-workfile vss-revision vss-description skip
                error-status :get-message(1) skip
                return-value skip
                ""
                view-as alert-box error
              .
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
  GET prev {&browse-name}.
END.
GET next {&browse-name}.
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
  GET next {&browse-name}.
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
REPOSITION {&browse-name} to recid v-doc-rec no-error.
APPLY "entry" to {&browse-name}.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br Dialog-Frame
PROCEDURE proc-br :
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
define output parameter p-doc-rec as recid no-undo .
define variable  v-rid-list as character no-undo .
define buffer bb_assortment-matrix for assortment-matrix.
define buffer bb_assortment-matrix-goods for ub.assortment-matrix-goods.
define variable v-calc0    as integer   no-undo init 1 .
define variable v-calc     as integer   no-undo init 0 .
define variable v-calc-err as integer   no-undo init 0 .
DEFINE VARIABLE iDelta     as INTEGER   NO-UNDO INITIAL 0.
DEFINE VARIABLE cError     as CHARACTER NO-UNDO INITIAL "".

 v-longchar = "" .
 v-err-ext = false .

run ref/assmatr.w ( input parParentProc , input 'b-sel', p-curr-obj-type , p-curr-obj-code , ? ,  ?, input-output  v-rid-list ).
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
                  no-error
                 }
                if not error-status :error  then do:
                   v-calc = v-calc + 1 .
                   run create-tt-gds in this-procedure  (bb_assortment-matrix-goods.gds-code, 0 ) .
                end.
                else do:
                  v-longchar = v-longchar + return-value  + {&new-line}.
                  v-err-ext  = true  .
                  v-calc-err = v-calc-err + 1 .
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
            ? ,
              'Editor_row=2\':u
            + 'title=При добавлении в Ассортиментные матрицы\':u
            + 'Editor_col=1\':u
            + 'Editor_width=96\':u
            + 'Editor_height=21\':u
            + 'readonly=yes\':u
          ,input-output v-longchar
          ,output v-ok ) no-error .
      end.
   end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-artic Dialog-Frame
PROCEDURE proc-find-artic :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as character no-undo.

define buffer buff_matrix-goods for ub.assortment-matrix-goods.
define variable doc-rec as recid no-undo.
  doc-rec = ? .
  find first  Buff_matrix-goods no-lock where
              Buff_matrix-goods.db-num   = p-db-num
          AND Buff_matrix-goods.asmt-id  = p-id
          and can-find(first  buf_goods no-lock where
                              buf_goods.gds-code =  Buff_matrix-goods.gds-code and
                              buf_goods.artic begins pardoc-code
                              )
          no-error  .

  if available Buff_matrix-goods then
  doc-rec = recid (Buff_matrix-goods) .

  reposition {&browse-name} to recid doc-rec no-error .
  if not error-status :error then do:
     apply "VALUE-CHANGED" to  {&browse-name}  in frame {&frame-name}.
  end.
  else do:
       message " Запись не найдена " view-as alert-box information .
  end.

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
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as INTEGER no-undo.
define buffer buff_matrix-goods for ub.assortment-matrix-goods.
define variable doc-rec as recid no-undo.
  doc-rec = ? .
  find first  Buff_matrix-goods no-lock where
              Buff_matrix-goods.gds-code = pardoc-code
          AND Buff_matrix-goods.db-num   = p-db-num
          AND Buff_matrix-goods.asmt-id  = p-id
          no-error  .

  if available Buff_matrix-goods then
  doc-rec = recid (Buff_matrix-goods) .

  reposition {&browse-name} to recid doc-rec no-error .
  if not error-status :error then do:
     apply "VALUE-CHANGED" to  {&browse-name}  in frame {&frame-name}.
  end.
  else do:
       message " Запись не найдена " view-as alert-box information .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-name Dialog-Frame
PROCEDURE proc-find-name :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter par-name as character no-undo .
define buffer buff_matrix-goods for ub.assortment-matrix-goods.
define buffer buff_goods for ub.goods.

define variable doc-rec as recid no-undo.
  doc-rec = ? .
      for each  buff_matrix-goods no-lock where
                buff_matrix-goods.db-num   = p-db-num and
                buff_matrix-goods.asmt-id  = p-id ,
          first buff_goods no-lock where
                buff_goods.gds-code = buff_matrix-goods.gds-code and
                buff_goods.gds-name begins par-name
                :
                doc-rec = recid (Buff_matrix-goods) .
                leave.
      end.
  /*
  if par-next = true then do:
      for each  buff_matrix-goods no-lock where
                buff_matrix-goods.db-num   = p-db-num and
                buff_matrix-goods.asmt-id  = p-id ,
          first buff_goods no-lock where
                buff_goods.gds-code = buff_matrix-goods.gds-code and
                buff_goods.gds-name begins par-name
                :
                doc-rec = recid (Buff_matrix-goods) .
                leave.
      end.
  end.
  else do:
   find next  buff_goods no-lock where
                  can-find (first buff_matrix-goods no-lock where
                  buff_matrix-goods.gds-code = buff_goods.gds-code and
                  buff_matrix-goods.db-num   = p-db-num and
                  buff_matrix-goods.asmt-id  = p-id ) and
                  buff_goods.gds-name begins par-name
                  no-error .
      if available buff_goods then do:
          find first buff_matrix-goods no-lock where
                    buff_matrix-goods.gds-code = buff_goods.gds-code and
                    buff_matrix-goods.db-num   = p-db-num and
                    buff_matrix-goods.asmt-id  = p-id  no-error .
                    if available buff_matrix-goods then do:
                        doc-rec = recid (Buff_matrix-goods) .
                    end.
          end.
      end.
   */
  reposition {&browse-name} to recid doc-rec no-error .
  if not error-status :error then do:
     apply "VALUE-CHANGED" to  {&browse-name}  in frame {&frame-name}.
  end.
  else do:
       message " Запись не найдена " view-as alert-box information .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-filter-name Dialog-Frame
PROCEDURE set-filter-name :
define input parameter p-filter-name as character no-undo .

  do with frame {&frame-name}:
    if p-filter-name > "" then do:
      assign
        frame {&frame-name}:title
          = frame {&frame-name}:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :TOOLTIP = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :TOOLTIP = ""
      .
    end.
  end. /* do with frame */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ver-db Dialog-Frame
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

