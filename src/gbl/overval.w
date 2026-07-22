&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Глобальные параметры для переоценок

Автор: Комаров Иван Сергеевич
Дата создания: 10/29/10
Author: Ivan Komarov
Creation date: 10/29/10

Автор1: Чернова Светлана Александровна
Дата создания1: 07/07/08

This .W file was created with the Progress AppBuilder.

*/

define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode     as character no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.shop.obj-code no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-Workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Настройки для переоценок" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/thbjattr.i }

define temp-table x_thbj-attr no-undo like ub.thbj-attr
  field p1 as char
  field d1 as char
  .

define buffer buf_thbj-attr for ub.thbj-attr.
define temp-table temp-thbj-attr        no-undo like ub.thbj-attr.
define temp-table thbjattr_thbj-attr-tt no-undo like ub.thbj-attr.

define variable v-tth           as handle    no-undo .
define variable v-buff-tth      as handle    no-undo .
define variable v-to-create     as logical   no-undo .
define variable v-to-create-trn as logical   no-undo .
define variable str-attr        as character no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
v-buff-tth = buffer thbjattr_thbj-attr-tt:table-handle .
if g#db-num <> 0 then p-mode = {&lookup} .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-quit b-frame-a b-frame-b B-Help 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-frame-a 
     LABEL "Параметры 1" 
     SIZE 15 BY 1.13.

DEFINE BUTTON b-frame-b 
     LABEL "Параметры 2" 
     SIZE 15 BY 1.13.

DEFINE BUTTON B-Help 
     LABEL "&Help" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-attr-pr-abs-d 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-attr-pr-altex 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-attr-pr-clt-q 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-attr-pr-discm 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-attr-pr-dpl-q 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-attr-pr-dscnt 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-attr-pr-equ-dq 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-attr-pr-incpc 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-attr-pr-list 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-attr-pr-notls 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-attr-pr-parex 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-attr-pr-print 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-attr-pr-rdc-q 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-attr-pr-rndbs 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-attr-pr-rndmt 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-attr-pr-sclex 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-attr-pr-sigma 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-corr-pr-list 
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE VARIABLE pr-discm AS CHARACTER FORMAT "X(256)":U INITIAL "cost" 
     VIEW-AS COMBO-BOX INNER-LINES 7
     LIST-ITEMS "","cost","sale","sale-","cost-vat","prod","prod-vat" 
     DROP-DOWN-LIST
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE pr-equ-dq AS INTEGER FORMAT "9":U INITIAL 2 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Не удалять",1,
                     "Запрос на удаление",2,
                     "Удаление без запроса",3
     DROP-DOWN-LIST
     SIZE 24 BY 1 NO-UNDO.

DEFINE VARIABLE pr-rndmt AS CHARACTER FORMAT "X(256)":U INITIAL "pr-round-off" 
     VIEW-AS COMBO-BOX INNER-LINES 7
     LIST-ITEM-PAIRS "9-окончание","pr-round-9end   ",
                     "9-99окончание","pr-round-9-99end",
                     "Без-дробных","pr-round-integer",
                     "Произвольно","pr-round-select ",
                     "Вверх","pr-round-up     ",
                     "Коэффициент","pr-round-coef   ",
                     "Отключено","pr-round-off"
     DROP-DOWN-LIST
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE pr-list AS CHARACTER INITIAL "Товар,Группа,УчетнаяS,Учетная,Учет-рзрвS,Учет-резерв,ПриходнаяS,Приходная,Старая,Новая,Объект,Накладная,Переоценка,ДокФормЦены,Накл-безНДС,Учет-НДСS,Учет-безНДС,Стар-безНДС,Учет+накл,Уч+накл-НДС,Единая,Отсутствует,Откат_цен,Не-считать,Производит,Произв-НДС,ПорогПр-НДС,ПорогПр+НДС,Спецификация" 
     VIEW-AS EDITOR
     SIZE 56 BY 2.5
     FONT 4 NO-UNDO.

DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Начальные значения для ТПЛ" 
      VIEW-AS TEXT 
     SIZE 28 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE pr-incpc AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE pr-rndbs AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE pr-sigma AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 10.88 BY 1 NO-UNDO.

DEFINE VARIABLE v-pr-abs-d AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 79 BY 1 NO-UNDO.

DEFINE VARIABLE v-pr-altex AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 48.75 BY 1 NO-UNDO.

DEFINE VARIABLE v-pr-clt-q AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 77 BY 1 NO-UNDO.

DEFINE VARIABLE v-pr-discm AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 39.38 BY 1 NO-UNDO.

DEFINE VARIABLE v-pr-dpl-q AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 77 BY 1 NO-UNDO.

DEFINE VARIABLE v-pr-dscnt AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 77 BY 1 NO-UNDO.

DEFINE VARIABLE v-pr-equ-dq AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 70 BY 1 NO-UNDO.

DEFINE VARIABLE v-pr-incpc AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 30.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-pr-list AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 32 BY 1
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE v-pr-notls AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 77 BY 1 NO-UNDO.

DEFINE VARIABLE v-pr-parex AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 48 BY 1 NO-UNDO.

DEFINE VARIABLE v-pr-print AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 77 BY 1 NO-UNDO.

DEFINE VARIABLE v-pr-rdc-q AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 77 BY 1 NO-UNDO.

DEFINE VARIABLE v-pr-rndbs AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 30.38 BY 1 NO-UNDO.

DEFINE VARIABLE v-pr-rndmt AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 25.75 BY 1 NO-UNDO.

DEFINE VARIABLE v-pr-sclex AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 49.75 BY 1 NO-UNDO.

DEFINE VARIABLE v-pr-sigma AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 59.5 BY 1 NO-UNDO.

DEFINE IMAGE I-pr-abs-d
     FILENAME "cmp/info.bmp":U
     SIZE 2.5 BY 1.04.

DEFINE IMAGE I-pr-altex
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-clt-q
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-discm
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-dpl-q
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-dscnt
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-equ-dq
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-incpc
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-list
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-notls
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-parex
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-print
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-rdc-q
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-rndbs
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-rndmt
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-sclex
     FILENAME "cmp/info.bmp":U
     SIZE 2.5 BY 1.

DEFINE IMAGE I-pr-sigma
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE VARIABLE pr-abs-d AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.

DEFINE VARIABLE pr-altex AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.13 BY 1 NO-UNDO.

DEFINE VARIABLE pr-clt-q AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.

DEFINE VARIABLE pr-dpl-q AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 1.88 BY 1 NO-UNDO.

DEFINE VARIABLE pr-dscnt AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.

DEFINE VARIABLE pr-notls AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.25 BY 1 NO-UNDO.

DEFINE VARIABLE pr-parex AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.13 BY 1 NO-UNDO.

DEFINE VARIABLE pr-print AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.

DEFINE VARIABLE pr-rdc-q AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.

DEFINE VARIABLE pr-sclex AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.13 BY 1 NO-UNDO.

DEFINE BUTTON B-attr-pr-goods 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-attr-pr-goods0 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-attr-pr-nogds 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-attr-pr-nogds0 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-corr-pr-nogds 
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-corr-pr-nogds0 
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE VARIABLE pr-goods AS CHARACTER FORMAT "X(256)":U INITIAL "1.нет запрета" 
     VIEW-AS COMBO-BOX INNER-LINES 8
     LIST-ITEMS "1.нет запрета","2.на товар","3.на топливо","4.на услугу","5.на товар и услугу","6.на товар и топливо","7.на услугу и топливо","8.запрет на все" 
     DROP-DOWN-LIST
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE pr-goods0 AS CHARACTER FORMAT "X(256)":U INITIAL "1.нет запрета" 
     VIEW-AS COMBO-BOX INNER-LINES 8
     LIST-ITEMS "1.нет запрета","2.на товар","3.на топливо","4.на услугу","5.на товар и услугу","6.на товар и топливо","7.на услугу и топливо","8.запрет на все" 
     DROP-DOWN-LIST
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE pr-nogds AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 46 BY 1
     FONT 2 NO-UNDO.

DEFINE VARIABLE pr-nogds0 AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 46 BY 1
     FONT 2 NO-UNDO.

DEFINE VARIABLE scr-nogrp AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 51.75 BY 2.75
     FONT 2 NO-UNDO.

DEFINE VARIABLE scr-nogrp0 AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 51.75 BY 2.75
     FONT 2 NO-UNDO.

DEFINE VARIABLE v-pr-goods AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 69 BY 1 NO-UNDO.

DEFINE VARIABLE v-pr-goods0 AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 69 BY 1 NO-UNDO.

DEFINE VARIABLE v-pr-nogds AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 47 BY 1 NO-UNDO.

DEFINE VARIABLE v-pr-nogds0 AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 47 BY 1 NO-UNDO.

DEFINE IMAGE I-pr-goods
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-goods0
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-nogds
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-nogds0
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1 WIDGET-ID 244
     B-quit AT ROW 1 COL 11 WIDGET-ID 246
     b-frame-a AT ROW 1 COL 26 WIDGET-ID 248
     b-frame-b AT ROW 1 COL 41 WIDGET-ID 250
     B-Help AT ROW 1 COL 93
     SPACE(0.12) SKIP(20.87)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Настройки для  П Е Р Е О Ц Е Н О К" WIDGET-ID 100.

DEFINE FRAME FRAME-A
     B-attr-pr-notls AT ROW 1.21 COL 2.88 WIDGET-ID 102
     pr-notls AT ROW 1.21 COL 6.25 WIDGET-ID 106
     B-attr-pr-altex AT ROW 2.21 COL 5.5 WIDGET-ID 52
     pr-altex AT ROW 2.21 COL 8.88 WIDGET-ID 46
     B-attr-pr-sclex AT ROW 3.21 COL 5.5 WIDGET-ID 186
     pr-sclex AT ROW 3.21 COL 8.88 WIDGET-ID 190
     B-attr-pr-parex AT ROW 4.21 COL 5.5 WIDGET-ID 110
     pr-parex AT ROW 4.21 COL 8.88 WIDGET-ID 114
     B-attr-pr-clt-q AT ROW 5.21 COL 2.75 WIDGET-ID 54
     pr-clt-q AT ROW 5.21 COL 6.13 WIDGET-ID 58
     B-attr-pr-dpl-q AT ROW 6.21 COL 2.75 WIDGET-ID 62
     pr-dpl-q AT ROW 6.21 COL 6.13 WIDGET-ID 66
     B-attr-pr-rdc-q AT ROW 7.21 COL 2.75 WIDGET-ID 126
     pr-rdc-q AT ROW 7.21 COL 6.13 WIDGET-ID 130
     B-attr-pr-equ-dq AT ROW 8.21 COL 2.75 WIDGET-ID 216
     pr-equ-dq AT ROW 8.21 COL 4 COLON-ALIGNED NO-LABEL WIDGET-ID 274
     B-attr-pr-abs-d AT ROW 10.21 COL 2.75 WIDGET-ID 48
     pr-abs-d AT ROW 10.21 COL 6.13 WIDGET-ID 44
     B-attr-pr-dscnt AT ROW 12 COL 2.75 WIDGET-ID 70
     pr-dscnt AT ROW 12 COL 6.13 WIDGET-ID 74
     B-attr-pr-print AT ROW 13 COL 2.75 WIDGET-ID 118
     pr-print AT ROW 13 COL 6.13 WIDGET-ID 122
     B-attr-pr-list AT ROW 14 COL 2.75 WIDGET-ID 170
     B-corr-pr-list AT ROW 14 COL 38.75 WIDGET-ID 222
     pr-list AT ROW 15 COL 1 NO-LABEL WIDGET-ID 214
     B-attr-pr-rndmt AT ROW 15 COL 59.13 WIDGET-ID 178
     pr-rndmt AT ROW 15 COL 60.13 COLON-ALIGNED NO-LABEL WIDGET-ID 210
     B-attr-pr-rndbs AT ROW 16 COL 59.13 WIDGET-ID 154
     pr-rndbs AT ROW 16 COL 60.13 COLON-ALIGNED NO-LABEL WIDGET-ID 158
     B-attr-pr-incpc AT ROW 17 COL 59.13 WIDGET-ID 144
     pr-incpc AT ROW 17 COL 60.13 COLON-ALIGNED NO-LABEL WIDGET-ID 152
     B-attr-pr-discm AT ROW 17.63 COL 3.25 WIDGET-ID 134
     pr-discm AT ROW 17.63 COL 4.63 COLON-ALIGNED NO-LABEL WIDGET-ID 142
     B-attr-pr-sigma AT ROW 18.63 COL 3.25 WIDGET-ID 162
     pr-sigma AT ROW 18.63 COL 4.63 COLON-ALIGNED NO-LABEL WIDGET-ID 166
     v-pr-notls AT ROW 1.21 COL 8.63 NO-LABEL WIDGET-ID 108
     v-pr-altex AT ROW 2.21 COL 11.25 NO-LABEL WIDGET-ID 18
     v-pr-sclex AT ROW 3.21 COL 11.25 NO-LABEL WIDGET-ID 192
     v-pr-parex AT ROW 4.21 COL 11.25 NO-LABEL WIDGET-ID 116
     v-pr-clt-q AT ROW 5.21 COL 8.5 NO-LABEL WIDGET-ID 60
     v-pr-dpl-q AT ROW 6.21 COL 8.5 NO-LABEL WIDGET-ID 68
     v-pr-rdc-q AT ROW 7.21 COL 8.5 NO-LABEL WIDGET-ID 132
     v-pr-equ-dq AT ROW 8.21 COL 29 COLON-ALIGNED NO-LABEL WIDGET-ID 220
     v-pr-abs-d AT ROW 10.21 COL 8.5 NO-LABEL WIDGET-ID 6
     v-pr-dscnt AT ROW 12 COL 8.5 NO-LABEL WIDGET-ID 76
     v-pr-print AT ROW 13 COL 8.25 NO-LABEL WIDGET-ID 124
     v-pr-list AT ROW 14 COL 6 NO-LABEL WIDGET-ID 176
     FILL-IN-2 AT ROW 14.13 COL 55 COLON-ALIGNED NO-LABEL WIDGET-ID 212
     v-pr-rndmt AT ROW 15 COL 77 NO-LABEL WIDGET-ID 184
     v-pr-rndbs AT ROW 16 COL 72.38 NO-LABEL WIDGET-ID 160
     v-pr-incpc AT ROW 17 COL 72.25 NO-LABEL WIDGET-ID 150
     v-pr-discm AT ROW 17.63 COL 18.13 NO-LABEL WIDGET-ID 140
     v-pr-sigma AT ROW 18.63 COL 18 NO-LABEL WIDGET-ID 168
     I-pr-abs-d AT ROW 10.25 COL 1 WIDGET-ID 10
     I-pr-altex AT ROW 2.21 COL 3.75 WIDGET-ID 34
     I-pr-clt-q AT ROW 5.25 COL 1 WIDGET-ID 56
     I-pr-dpl-q AT ROW 6.25 COL 1 WIDGET-ID 64
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 2
         SIZE 102 BY 20.75 WIDGET-ID 200.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME FRAME-A
     I-pr-dscnt AT ROW 12 COL 1 WIDGET-ID 72
     I-pr-equ-dq AT ROW 8.25 COL 1 WIDGET-ID 272
     I-pr-notls AT ROW 1.21 COL 1.13 WIDGET-ID 104
     I-pr-parex AT ROW 4.21 COL 3.75 WIDGET-ID 112
     I-pr-print AT ROW 13.04 COL 1 WIDGET-ID 120
     I-pr-rdc-q AT ROW 7.25 COL 1 WIDGET-ID 128
     I-pr-discm AT ROW 17.63 COL 1.5 WIDGET-ID 136
     I-pr-incpc AT ROW 17 COL 57 WIDGET-ID 146
     I-pr-rndbs AT ROW 16 COL 57 WIDGET-ID 156
     I-pr-sigma AT ROW 18.63 COL 1.5 WIDGET-ID 164
     I-pr-list AT ROW 14.04 COL 1 WIDGET-ID 172
     I-pr-rndmt AT ROW 15 COL 57 WIDGET-ID 180
     I-pr-sclex AT ROW 3.21 COL 3.75 WIDGET-ID 188
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 2
         SIZE 102 BY 20.75 WIDGET-ID 200.

DEFINE FRAME FRAME-B
     B-attr-pr-goods0 AT ROW 2 COL 3.38 WIDGET-ID 244
     pr-goods0 AT ROW 2 COL 4.63 COLON-ALIGNED NO-LABEL WIDGET-ID 248
     B-attr-pr-nogds0 AT ROW 3.08 COL 3.5 WIDGET-ID 252
     pr-nogds0 AT ROW 3.08 COL 55 NO-LABEL WIDGET-ID 258
     B-corr-pr-nogds0 AT ROW 4.29 COL 2.75 WIDGET-ID 254
     scr-nogrp0 AT ROW 4.29 COL 6 NO-LABEL WIDGET-ID 260
     B-attr-pr-goods AT ROW 7.96 COL 3.38 WIDGET-ID 224
     pr-goods AT ROW 7.96 COL 4.63 COLON-ALIGNED NO-LABEL WIDGET-ID 228
     B-attr-pr-nogds AT ROW 9.21 COL 3.5 WIDGET-ID 232
     pr-nogds AT ROW 9.21 COL 55 NO-LABEL WIDGET-ID 240
     B-corr-pr-nogds AT ROW 10.42 COL 2.75 WIDGET-ID 234
     scr-nogrp AT ROW 10.42 COL 6 NO-LABEL WIDGET-ID 242
     v-pr-goods0 AT ROW 2.04 COL 29.38 COLON-ALIGNED NO-LABEL WIDGET-ID 250
     v-pr-nogds0 AT ROW 3.08 COL 4.5 COLON-ALIGNED NO-LABEL WIDGET-ID 262
     v-pr-goods AT ROW 8 COL 31 NO-LABEL WIDGET-ID 230
     v-pr-nogds AT ROW 9.21 COL 6.5 NO-LABEL WIDGET-ID 238
     "УБД" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 7.25 COL 3.63 WIDGET-ID 270
          FGCOLOR 1 
     "ГБД" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 1.25 COL 4 WIDGET-ID 268
          FGCOLOR 1 
     I-pr-goods AT ROW 7.96 COL 1.63 WIDGET-ID 226
     I-pr-nogds AT ROW 9.21 COL 1.5 WIDGET-ID 236
     I-pr-goods0 AT ROW 2 COL 1.63 WIDGET-ID 246
     I-pr-nogds0 AT ROW 3.08 COL 1.5 WIDGET-ID 256
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 2
         SIZE 102 BY 20.75 WIDGET-ID 300.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* REPARENT FRAME */
ASSIGN FRAME FRAME-A:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME FRAME-B:FRAME = FRAME Dialog-Frame:HANDLE.

/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */

DEFINE VARIABLE XXTABVALXX AS LOGICAL NO-UNDO.

ASSIGN XXTABVALXX = FRAME FRAME-B:MOVE-AFTER-TAB-ITEM (B-Help:HANDLE IN FRAME Dialog-Frame)
       XXTABVALXX = FRAME FRAME-B:MOVE-BEFORE-TAB-ITEM (FRAME FRAME-A:HANDLE)
/* END-ASSIGN-TABS */.

ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FRAME FRAME-A
                                                                        */
/* SETTINGS FOR EDITOR pr-list IN FRAME FRAME-A
   NO-ENABLE                                                            */
ASSIGN 
       pr-list:READ-ONLY IN FRAME FRAME-A        = TRUE.

/* SETTINGS FOR FILL-IN v-pr-abs-d IN FRAME FRAME-A
   ALIGN-L                                                              */
ASSIGN 
       v-pr-abs-d:READ-ONLY IN FRAME FRAME-A        = TRUE.

/* SETTINGS FOR FILL-IN v-pr-altex IN FRAME FRAME-A
   ALIGN-L                                                              */
ASSIGN 
       v-pr-altex:READ-ONLY IN FRAME FRAME-A        = TRUE.

/* SETTINGS FOR FILL-IN v-pr-clt-q IN FRAME FRAME-A
   ALIGN-L                                                              */
ASSIGN 
       v-pr-clt-q:READ-ONLY IN FRAME FRAME-A        = TRUE.

/* SETTINGS FOR FILL-IN v-pr-discm IN FRAME FRAME-A
   ALIGN-L                                                              */
ASSIGN 
       v-pr-discm:READ-ONLY IN FRAME FRAME-A        = TRUE.

/* SETTINGS FOR FILL-IN v-pr-dpl-q IN FRAME FRAME-A
   ALIGN-L                                                              */
ASSIGN 
       v-pr-dpl-q:READ-ONLY IN FRAME FRAME-A        = TRUE.

/* SETTINGS FOR FILL-IN v-pr-dscnt IN FRAME FRAME-A
   ALIGN-L                                                              */
ASSIGN 
       v-pr-dscnt:READ-ONLY IN FRAME FRAME-A        = TRUE.

/* SETTINGS FOR FILL-IN v-pr-incpc IN FRAME FRAME-A
   ALIGN-L                                                              */
ASSIGN 
       v-pr-incpc:READ-ONLY IN FRAME FRAME-A        = TRUE.

/* SETTINGS FOR FILL-IN v-pr-list IN FRAME FRAME-A
   ALIGN-L                                                              */
ASSIGN 
       v-pr-list:READ-ONLY IN FRAME FRAME-A        = TRUE.

/* SETTINGS FOR FILL-IN v-pr-notls IN FRAME FRAME-A
   ALIGN-L                                                              */
ASSIGN 
       v-pr-notls:READ-ONLY IN FRAME FRAME-A        = TRUE.

/* SETTINGS FOR FILL-IN v-pr-parex IN FRAME FRAME-A
   ALIGN-L                                                              */
ASSIGN 
       v-pr-parex:READ-ONLY IN FRAME FRAME-A        = TRUE.

/* SETTINGS FOR FILL-IN v-pr-print IN FRAME FRAME-A
   ALIGN-L                                                              */
ASSIGN 
       v-pr-print:READ-ONLY IN FRAME FRAME-A        = TRUE.

/* SETTINGS FOR FILL-IN v-pr-rdc-q IN FRAME FRAME-A
   ALIGN-L                                                              */
ASSIGN 
       v-pr-rdc-q:READ-ONLY IN FRAME FRAME-A        = TRUE.

/* SETTINGS FOR FILL-IN v-pr-rndbs IN FRAME FRAME-A
   ALIGN-L                                                              */
ASSIGN 
       v-pr-rndbs:READ-ONLY IN FRAME FRAME-A        = TRUE.

/* SETTINGS FOR FILL-IN v-pr-rndmt IN FRAME FRAME-A
   ALIGN-L                                                              */
ASSIGN 
       v-pr-rndmt:READ-ONLY IN FRAME FRAME-A        = TRUE.

/* SETTINGS FOR FILL-IN v-pr-sclex IN FRAME FRAME-A
   ALIGN-L                                                              */
ASSIGN 
       v-pr-sclex:READ-ONLY IN FRAME FRAME-A        = TRUE.

/* SETTINGS FOR FILL-IN v-pr-sigma IN FRAME FRAME-A
   ALIGN-L                                                              */
ASSIGN 
       v-pr-sigma:READ-ONLY IN FRAME FRAME-A        = TRUE.

/* SETTINGS FOR FRAME FRAME-B
                                                                        */
ASSIGN 
       pr-nogds:READ-ONLY IN FRAME FRAME-B        = TRUE.

ASSIGN 
       pr-nogds0:READ-ONLY IN FRAME FRAME-B        = TRUE.

ASSIGN 
       scr-nogrp:READ-ONLY IN FRAME FRAME-B        = TRUE.

ASSIGN 
       scr-nogrp0:READ-ONLY IN FRAME FRAME-B        = TRUE.

/* SETTINGS FOR FILL-IN v-pr-goods IN FRAME FRAME-B
   ALIGN-L                                                              */
ASSIGN 
       v-pr-goods:READ-ONLY IN FRAME FRAME-B        = TRUE.

ASSIGN 
       v-pr-goods0:READ-ONLY IN FRAME FRAME-B        = TRUE.

/* SETTINGS FOR FILL-IN v-pr-nogds IN FRAME FRAME-B
   ALIGN-L                                                              */
ASSIGN 
       v-pr-nogds:READ-ONLY IN FRAME FRAME-B        = TRUE.

ASSIGN 
       v-pr-nogds0:READ-ONLY IN FRAME FRAME-B        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Настройки для  П Е Р Е О Ц Е Н О К */
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Настройки для  П Е Р Е О Ц Е Н О К */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-A
&Scoped-define SELF-NAME B-attr-pr-abs-d
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-pr-abs-d Dialog-Frame
ON CHOOSE OF B-attr-pr-abs-d IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ({&attr-overval},
       trim(substring("{&SELF-NAME}",8,10))
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr-pr-altex
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-pr-altex Dialog-Frame
ON CHOOSE OF B-attr-pr-altex IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ({&attr-overval},
       trim(substring("{&SELF-NAME}",8,10))
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr-pr-clt-q
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-pr-clt-q Dialog-Frame
ON CHOOSE OF B-attr-pr-clt-q IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ({&attr-overval},
        trim (substring("{&SELF-NAME}",8,10))
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr-pr-discm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-pr-discm Dialog-Frame
ON CHOOSE OF B-attr-pr-discm IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ({&attr-overval},
        trim (substring("{&SELF-NAME}",8,10))
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr-pr-dpl-q
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-pr-dpl-q Dialog-Frame
ON CHOOSE OF B-attr-pr-dpl-q IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ({&attr-overval},
        trim (substring("{&SELF-NAME}",8,10))
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr-pr-dscnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-pr-dscnt Dialog-Frame
ON CHOOSE OF B-attr-pr-dscnt IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ({&attr-overval},
        trim (substring("{&SELF-NAME}",8,10))
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr-pr-equ-dq
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-pr-equ-dq Dialog-Frame
ON CHOOSE OF B-attr-pr-equ-dq IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ({&attr-overval},
        trim (substring("{&SELF-NAME}",8,10))
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-B
&Scoped-define SELF-NAME B-attr-pr-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-pr-goods Dialog-Frame
ON CHOOSE OF B-attr-pr-goods IN FRAME FRAME-B
DO:
  run gbl/v-taobj.w
      ({&attr-overval},
        trim (substring("{&SELF-NAME}",8,10))
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr-pr-goods0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-pr-goods0 Dialog-Frame
ON CHOOSE OF B-attr-pr-goods0 IN FRAME FRAME-B
DO:
  run gbl/v-taobj.w
      ({&attr-overval},
        trim (substring("{&SELF-NAME}",8,10))
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-A
&Scoped-define SELF-NAME B-attr-pr-incpc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-pr-incpc Dialog-Frame
ON CHOOSE OF B-attr-pr-incpc IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ({&attr-overval},
        trim (substring("{&SELF-NAME}",8,10))
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr-pr-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-pr-list Dialog-Frame
ON CHOOSE OF B-attr-pr-list IN FRAME FRAME-A
DO:
&Scoped-define FRAME-NAME FRAME-A
  run gbl/v-taobj.w
      ({&attr-overval},
        trim (substring("{&SELF-NAME}",8,10))
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-B
&Scoped-define SELF-NAME B-attr-pr-nogds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-pr-nogds Dialog-Frame
ON CHOOSE OF B-attr-pr-nogds IN FRAME FRAME-B
DO:
  run gbl/v-taobj.w
      ({&attr-overval},
        trim (substring("{&SELF-NAME}",8,10))
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr-pr-nogds0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-pr-nogds0 Dialog-Frame
ON CHOOSE OF B-attr-pr-nogds0 IN FRAME FRAME-B
DO:
  run gbl/v-taobj.w
      ({&attr-overval},
        trim (substring("{&SELF-NAME}",8,10))
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-A
&Scoped-define SELF-NAME B-attr-pr-notls
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-pr-notls Dialog-Frame
ON CHOOSE OF B-attr-pr-notls IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ({&attr-overval},
        trim (substring("{&SELF-NAME}",8,10))
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr-pr-parex
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-pr-parex Dialog-Frame
ON CHOOSE OF B-attr-pr-parex IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ({&attr-overval},
        trim (substring("{&SELF-NAME}",8,10))
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr-pr-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-pr-print Dialog-Frame
ON CHOOSE OF B-attr-pr-print IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ({&attr-overval},
        trim (substring("{&SELF-NAME}",8,10))
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr-pr-rdc-q
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-pr-rdc-q Dialog-Frame
ON CHOOSE OF B-attr-pr-rdc-q IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ({&attr-overval},
        trim (substring("{&SELF-NAME}",8,10))
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr-pr-rndbs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-pr-rndbs Dialog-Frame
ON CHOOSE OF B-attr-pr-rndbs IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ({&attr-overval},
        trim (substring("{&SELF-NAME}",8,10))
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr-pr-rndmt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-pr-rndmt Dialog-Frame
ON CHOOSE OF B-attr-pr-rndmt IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ({&attr-overval},
        trim (substring("{&SELF-NAME}",8,10))
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr-pr-sclex
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-pr-sclex Dialog-Frame
ON CHOOSE OF B-attr-pr-sclex IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ({&attr-overval},
       trim(substring("{&SELF-NAME}",8,10))
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr-pr-sigma
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-pr-sigma Dialog-Frame
ON CHOOSE OF B-attr-pr-sigma IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ({&attr-overval},
        trim (substring("{&SELF-NAME}",8,10))
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-corr-pr-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-corr-pr-list Dialog-Frame
ON CHOOSE OF B-corr-pr-list IN FRAME FRAME-A
DO:
  &Scoped-define FRAME-NAME FRAME-A
  if p-mode <> {&lookup} and p-obj-type <> "" then do :
    run gbl/v-ta-pr.w ( input {&lookup}, INPUT-OUTPUT pr-list ) .
  end.
  else do:
    run gbl/v-ta-pr.w ( input p-mode, INPUT-OUTPUT pr-list ) .
  end.
  DISPLAY pr-list WITH FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-B
&Scoped-define SELF-NAME B-corr-pr-nogds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-corr-pr-nogds Dialog-Frame
ON CHOOSE OF B-corr-pr-nogds IN FRAME FRAME-B
DO:
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
define buffer buf_gds-grp for ub.gds-grp  .
define variable gdsgrp_recids as character no-undo .
define variable ii as integer   no-undo .
define variable nn as integer   no-undo .



assign
  gdsgrp_recids = ""
  nn = num-entries(pr-nogds)
.
repeat ii = 1 to nn :
   find first buf_gds-grp no-lock where
              buf_gds-grp.node-code = integer(entry( ii , pr-nogds )) no-error  .
   if available buf_gds-grp then do:
      gdsgrp_recids = trim(gdsgrp_recids) + string(recid(buf_gds-grp)) + "," .
   end.
end.

run ref/gds-grp.w
  ( input parparentproc
   ,input "b-sel,b-mark"
   ,input v-cntxt-obj-type
   ,input v-cntxt-obj-code
   ,input-output gdsgrp_recids
   ) .

assign
  scr-nogrp = ""
  pr-nogds  = ""
  nn = num-entries(gdsgrp_recids)
.
repeat ii = 1 to nn :
   find first buf_gds-grp no-lock where
              recid(buf_gds-grp) = integer( entry( ii , gdsgrp_recids ))  no-error  .
   if available buf_gds-grp then do:
      assign
        scr-nogrp = scr-nogrp + substitute("&1.&2 &3" , buf_gds-grp.node-code , buf_gds-grp.node-name , {&new-line} )
        pr-nogds  = trim(pr-nogds)  + string(buf_gds-grp.node-code)  +  ","
      .
   end.
end.
assign
  pr-nogds  = trim(pr-nogds, ",")
  scr-nogrp = trim(scr-nogrp)
.

DISPLAY pr-nogds scr-nogrp WITH FRAME FRAME-B .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-corr-pr-nogds0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-corr-pr-nogds0 Dialog-Frame
ON CHOOSE OF B-corr-pr-nogds0 IN FRAME FRAME-B
DO:
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
define buffer buf_gds-grp for ub.gds-grp  .
define variable gdsgrp_recids as character no-undo .
define variable ii as integer   no-undo .
define variable nn as integer   no-undo .



gdsgrp_recids = "".

nn = num-entries(pr-nogds0).
repeat ii = 1 to nn :
   find first buf_gds-grp no-lock where
              buf_gds-grp.node-code = integer(entry( ii , pr-nogds0 )) no-error  .
   if available buf_gds-grp then do:
      gdsgrp_recids = trim(gdsgrp_recids) + string(recid(buf_gds-grp)) + "," .
   end.
end.

run ref/gds-grp.w
  ( input parparentproc
   ,input "b-sel,b-mark"
   ,input v-cntxt-obj-type
   ,input v-cntxt-obj-code
   ,input-output gdsgrp_recids
   ) .

assign
  scr-nogrp0 = ""
  pr-nogds0  = ""
  nn = num-entries(gdsgrp_recids)
.
repeat ii = 1 to nn :
   find first buf_gds-grp no-lock where
              recid(buf_gds-grp) = integer( entry( ii , gdsgrp_recids ))  no-error  .
   if available buf_gds-grp then do:
      assign
        scr-nogrp0 = scr-nogrp0 + substitute("&1.&2 &3" , buf_gds-grp.node-code , buf_gds-grp.node-name , {&new-line} )
        pr-nogds0  = trim(pr-nogds0)  + string(buf_gds-grp.node-code)  +  ","
      .
   end.
end.
assign
  pr-nogds0   = trim(pr-nogds0, ",")
  scr-nogrp0  = trim(scr-nogrp0)
.

DISPLAY pr-nogds0 scr-nogrp0 WITH FRAME FRAME-b .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define SELF-NAME b-frame-a
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-frame-a Dialog-Frame
ON CHOOSE OF b-frame-a IN FRAME Dialog-Frame /* Параметры 1 */
DO:
  HIDE FRAME frame-b.
  VIEW FRAME frame-a.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-frame-b
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-frame-b Dialog-Frame
ON CHOOSE OF b-frame-b IN FRAME Dialog-Frame /* Параметры 2 */
DO:
  HIDE FRAME frame-a.
  VIEW FRAME frame-b.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-A
&Scoped-define SELF-NAME I-pr-abs-d
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-abs-d Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-abs-d IN FRAME FRAME-A
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-altex
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-altex Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-altex IN FRAME FRAME-A
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-clt-q
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-clt-q Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-clt-q IN FRAME FRAME-A
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-discm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-discm Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-discm IN FRAME FRAME-A
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-dpl-q
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-dpl-q Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-dpl-q IN FRAME FRAME-A
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-dscnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-dscnt Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-dscnt IN FRAME FRAME-A
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-equ-dq
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-equ-dq Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-equ-dq IN FRAME FRAME-A
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-B
&Scoped-define SELF-NAME I-pr-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-goods Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-goods IN FRAME FRAME-B
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-goods0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-goods0 Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-goods0 IN FRAME FRAME-B
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-A
&Scoped-define SELF-NAME I-pr-incpc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-incpc Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-incpc IN FRAME FRAME-A
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-list Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-list IN FRAME FRAME-A
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-B
&Scoped-define SELF-NAME I-pr-nogds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-nogds Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-nogds IN FRAME FRAME-B
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-nogds0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-nogds0 Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-nogds0 IN FRAME FRAME-B
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-A
&Scoped-define SELF-NAME I-pr-notls
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-notls Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-notls IN FRAME FRAME-A
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-parex
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-parex Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-parex IN FRAME FRAME-A
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-print Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-print IN FRAME FRAME-A
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-rdc-q
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-rdc-q Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-rdc-q IN FRAME FRAME-A
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-rndbs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-rndbs Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-rndbs IN FRAME FRAME-A
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-rndmt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-rndmt Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-rndmt IN FRAME FRAME-A
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-sclex
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-sclex Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-sclex IN FRAME FRAME-A
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-sigma
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-sigma Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-sigma IN FRAME FRAME-A
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME pr-notls
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL pr-notls Dialog-Frame
ON VALUE-CHANGED OF pr-notls IN FRAME FRAME-A
DO:
  ASSIGN pr-notls.
  IF p-mode <> {&LOOKUP} THEN DO:
   IF NOT pr-notls THEN DO:
      assign
        pr-parex  = pr-notls
        pr-sclex  = pr-notls
        pr-altex  = pr-notls
      .
      DISPLAY  pr-parex pr-sclex pr-altex WITH FRAME {&FRAME-NAME} .
      DISABLE pr-parex pr-sclex pr-altex WITH FRAME {&FRAME-NAME} .
   END.
   ELSE DO:
      ENABLE pr-parex pr-sclex pr-altex WITH FRAME {&FRAME-NAME} .
   END.
 END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME Dialog-Frame
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
if p-obj-type <> "" then
   frame {&frame-name}:title = frame {&frame-name}:title + (if p-obj-type = {&cmp} then " фирма" else " маг") + string(p-obj-code) + " " + p-mode  .

define variable loc#log as logical   no-undo .
/* Проверка прав */
  { gbl/chk-actg.i
    g#db-num
    g#userid
    {&action-head-code-main}
    'actn_global-trn_lookup':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    loc#log
  }
  if loc#log <> yes then do: return error. end.


    run enable_UI in THIS-PROCEDURE.
    run init-proc in THIS-PROCEDURE.
    if p-mode = {&lookup} then do:
      disable B-corr-pr-list
         with  frame frame-a.
      disable
         B-corr-pr-nogds0
         B-corr-pr-nogds
         with  frame frame-b.

    end.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI.

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
  HIDE FRAME FRAME-A.
  HIDE FRAME FRAME-B.
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
  ENABLE B-exit B-quit b-frame-a b-frame-b B-Help 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  DISPLAY pr-notls pr-altex pr-sclex pr-parex pr-clt-q pr-dpl-q pr-rdc-q 
          pr-equ-dq pr-abs-d pr-dscnt pr-print pr-list pr-rndmt pr-rndbs 
          pr-incpc pr-discm pr-sigma v-pr-notls v-pr-altex v-pr-sclex v-pr-parex 
          v-pr-clt-q v-pr-dpl-q v-pr-rdc-q v-pr-equ-dq v-pr-abs-d v-pr-dscnt 
          v-pr-print v-pr-list FILL-IN-2 v-pr-rndmt v-pr-rndbs v-pr-incpc 
          v-pr-discm v-pr-sigma 
      WITH FRAME FRAME-A.
  ENABLE I-pr-abs-d I-pr-altex I-pr-clt-q I-pr-dpl-q I-pr-dscnt I-pr-equ-dq 
         I-pr-notls I-pr-parex I-pr-print I-pr-rdc-q I-pr-discm I-pr-incpc 
         I-pr-rndbs I-pr-sigma I-pr-list I-pr-rndmt I-pr-sclex B-attr-pr-notls 
         pr-notls B-attr-pr-altex pr-altex B-attr-pr-sclex pr-sclex 
         B-attr-pr-parex pr-parex B-attr-pr-clt-q pr-clt-q B-attr-pr-dpl-q 
         pr-dpl-q B-attr-pr-rdc-q pr-rdc-q B-attr-pr-equ-dq pr-equ-dq 
         B-attr-pr-abs-d pr-abs-d B-attr-pr-dscnt pr-dscnt B-attr-pr-print 
         pr-print B-attr-pr-list B-corr-pr-list B-attr-pr-rndmt pr-rndmt 
         B-attr-pr-rndbs pr-rndbs B-attr-pr-incpc pr-incpc B-attr-pr-discm 
         pr-discm B-attr-pr-sigma pr-sigma v-pr-notls v-pr-altex v-pr-sclex 
         v-pr-parex v-pr-clt-q v-pr-dpl-q v-pr-rdc-q v-pr-equ-dq v-pr-abs-d 
         v-pr-dscnt v-pr-print v-pr-list FILL-IN-2 v-pr-rndmt v-pr-rndbs 
         v-pr-incpc v-pr-discm v-pr-sigma 
      WITH FRAME FRAME-A.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-A}
  DISPLAY pr-goods0 pr-nogds0 scr-nogrp0 pr-goods pr-nogds scr-nogrp v-pr-goods0 
          v-pr-nogds0 v-pr-goods v-pr-nogds 
      WITH FRAME FRAME-B.
  ENABLE I-pr-goods I-pr-nogds I-pr-goods0 I-pr-nogds0 B-attr-pr-goods0 
         pr-goods0 B-attr-pr-nogds0 pr-nogds0 B-corr-pr-nogds0 scr-nogrp0 
         B-attr-pr-goods pr-goods B-attr-pr-nogds pr-nogds B-corr-pr-nogds 
         scr-nogrp v-pr-goods0 v-pr-nogds0 v-pr-goods v-pr-nogds 
      WITH FRAME FRAME-B.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-B}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame 
PROCEDURE fill-widgets :
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-param-type      as character no-undo .
define variable v-param-value     as character no-undo .

for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
for each thbjattr_thbj-attr-tt:
  delete thbjattr_thbj-attr-tt.
end.

for each temp-thbj-attr:
  delete temp-thbj-attr.
end.
run adm/shattri.p (
    input "get":U
  , input p-obj-type
  , input p-obj-code
  , input {&attr-overval}
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE thbjattr_thbj-attr-tt
  ) no-error .
if error-status:error then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
if p-obj-code <> 0 and p-obj-type <> "" then do: /* pr-list - Глобальный*/
  find first thbjattr_thbj-attr-tt where thbjattr_thbj-attr-tt.prop-code = {&attr-overval_pr-list}.
  if available thbjattr_thbj-attr-tt then do:
    delete thbjattr_thbj-attr-tt.
  end.
  pr-list = "Параметр pr-list Глобальный".
  display pr-list WITH FRAME FRAME-A.
  disable B-corr-pr-list
      with  frame frame-a.
end.

&scop code-logical ~
  if thbjattr_thbj-attr-tt.prop-code = "~{&p-pole~}" then do: ~
     ~{&p-pole~} = thbjattr_thbj-attr-tt.property-value-logical. ~
     ~{&p-pole~}:private-data IN FRAME ~{&pframe-name} = "recid2=" + string(recid(thbjattr_thbj-attr-tt)). ~
     display ~{&p-pole~} with frame ~{&pframe-name} . ~
  end.
&scop code-character ~
  if thbjattr_thbj-attr-tt.prop-code = "~{&p-pole~}" then do: ~
     ~{&p-pole~} = thbjattr_thbj-attr-tt.property-value-character. ~
     ~{&p-pole~}:private-data IN FRAME ~{&pframe-name} = "recid2=" + string(recid(thbjattr_thbj-attr-tt)). ~
     display ~{&p-pole~} with frame ~{&pframe-name} . ~
  end.
&scop code-decimal ~
  if thbjattr_thbj-attr-tt.prop-code = "~{&p-pole~}" then do: ~
     ~{&p-pole~} = thbjattr_thbj-attr-tt.property-value-decimal. ~
     ~{&p-pole~}:private-data IN FRAME ~{&pframe-name} = "recid2=" + string(recid(thbjattr_thbj-attr-tt)). ~
     display ~{&p-pole~} with frame ~{&pframe-name} . ~
  end.
&scop code-integer ~
  if thbjattr_thbj-attr-tt.prop-code = "~{&p-pole~}" then do: ~
     ~{&p-pole~} = thbjattr_thbj-attr-tt.property-value-integer. ~
     ~{&p-pole~}:private-data IN FRAME ~{&pframe-name} = "recid2=" + string(recid(thbjattr_thbj-attr-tt)). ~
     display ~{&p-pole~} with frame ~{&pframe-name} . ~
  end.


FOR EACH thbjattr_thbj-attr-tt where thbjattr_thbj-attr-tt.obj-type  = p-obj-type :

&scop pframe-name frame-a
&scop p-pole pr-abs-d
{&code-logical}
&scop p-pole pr-altex
{&code-logical}
&scop p-pole pr-clt-q
{&code-logical}
&scop p-pole pr-discm
{&code-character}
&scop p-pole pr-dpl-q
{&code-logical}
&scop p-pole pr-dscnt
{&code-logical}
&scop p-pole pr-equ-dq
{&code-integer}
&scop p-pole pr-incpc
{&code-decimal}
&scop p-pole pr-list
{&code-character}
&scop p-pole pr-notls
{&code-logical}
&scop p-pole pr-parex
{&code-logical}
&scop p-pole pr-print
{&code-logical}
&scop p-pole pr-rdc-q
{&code-logical}
&scop p-pole pr-rndbs
{&code-decimal}
&scop p-pole pr-rndmt
{&code-character}
&scop p-pole pr-sclex
{&code-logical}
&scop p-pole pr-sigma
{&code-decimal}
&scop pframe-name frame-b
&scop p-pole pr-goods
{&code-character}
&scop p-pole pr-nogds
{&code-character}
&scop p-pole pr-goods0
{&code-character}
&scop p-pole pr-nogds0
{&code-character}
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr-tt to temp-thbj-attr.
 /*  message thbjattr_thbj-attr-tt.obj-type  thbjattr_thbj-attr-tt.prop-code view-as alert-box. */
END.

define variable nn as integer   no-undo .
define variable ii as integer   no-undo .

define buffer buf_gds-grp for ub.gds-grp  .

scr-nogrp = "" .
nn = num-entries ( pr-nogds ) .
repeat ii = 1 to nn :
   find first buf_gds-grp no-lock where
              buf_gds-grp.node-code = integer(entry( ii , pr-nogds ))  no-error  .
   if available buf_gds-grp then do:
      scr-nogrp = scr-nogrp + substitute( "&1.&2 &3" , buf_gds-grp.node-code , buf_gds-grp.node-name , {&new-line} ) .
   end.
end.
scr-nogrp  = trim(scr-nogrp) .
&scop pframe-name frame-b
display scr-nogrp with frame {&pframe-name} .
scr-nogrp0 = "" .
nn = num-entries ( pr-nogds0 ) .
repeat ii = 1 to nn :
   find first buf_gds-grp no-lock where
              buf_gds-grp.node-code = integer(entry( ii , pr-nogds0 ))  no-error  .
   if available buf_gds-grp then do:
      scr-nogrp0 = scr-nogrp0 + substitute( "&1.&2 &3" , buf_gds-grp.node-code , buf_gds-grp.node-name , {&new-line} ) .
   end.
end.
scr-nogrp0  = trim(scr-nogrp0) .
&scop pframe-name frame-b
display scr-nogrp0 with frame {&pframe-name} .



define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
define variable v-tooltip-code as character no-undo .

&scop code-1 ~
run thbjattr_tooltip in this-procedure ( ~
   input   ~{&attr-overval~} ~
  ,input  "~{&p-pole~}" ~
  ,output v-tooltip ~
  ,output v-label ~
  ,output v-tooltip-code ~
  ) no-error . ~
v-label =  REPLACE ( v-label , "`" , "," ). ~
v-~{&p-pole~}:screen-value = entry(2,v-label,":") . ~
v-~{&p-pole~} = entry(2,v-label,":") . ~
I-~{&p-pole~}:private-data =  REPLACE ( v-tooltip-code , "`" , "," ).

&scop p-pole pr-abs-d
{&code-1}
&scop p-pole pr-altex
{&code-1}
&scop p-pole pr-clt-q
{&code-1}
&scop p-pole pr-discm
{&code-1}
&scop p-pole pr-dpl-q
{&code-1}
&scop p-pole pr-dscnt
{&code-1}
&scop p-pole pr-equ-dq
{&code-1}
&scop p-pole pr-incpc
{&code-1}
&scop p-pole pr-list
{&code-1}
&scop p-pole pr-notls
{&code-1}
&scop p-pole pr-parex
{&code-1}
&scop p-pole pr-print
{&code-1}
&scop p-pole pr-rdc-q
{&code-1}
&scop p-pole pr-rndbs
{&code-1}
&scop p-pole pr-rndmt
{&code-1}
&scop p-pole pr-sclex
{&code-1}
&scop p-pole pr-sigma
{&code-1}
&scop p-pole pr-goods
{&code-1}
&scop p-pole pr-nogds
{&code-1}
&scop p-pole pr-goods0
{&code-1}
&scop p-pole pr-nogds0
{&code-1}


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame 
PROCEDURE init-proc :
define variable v-i               as integer   no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-type            as character no-undo .
define variable v-value           as character no-undo .
define variable v-found           as decimal   no-undo .
HIDE FRAME frame-b.
VIEW FRAME frame-a.

  if p-mode = {&update} then do:
    find first buf_thbj-attr exclusive-lock where
              buf_thbj-attr.obj-type = p-obj-type
        and   buf_thbj-attr.obj-code = p-obj-code
        and   buf_thbj-attr.upper-prop-code = {&attr-overval}
        and   buf_thbj-attr.prop-code = '':u no-wait no-error.
     if locked buf_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        {&attr-overval} skip
        "Запись Глобальных ПАРАМЕТРОВ  занята"
        view-as alert-box error .
        undo, return error.
      end.
  end.
  else do:
    find first buf_thbj-attr no-lock where
          buf_thbj-attr.obj-type = p-obj-type
    and   buf_thbj-attr.obj-code = p-obj-code
    and   buf_thbj-attr.upper-prop-code = {&attr-overval}
    and   buf_thbj-attr.prop-code = '':u no-error.
  end.
  if not available buf_thbj-attr then do:
    assign
      v-to-create-trn  = true
      .
    message
    substitute ("Внимание!!!&1 Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
                 view-as alert-box warning.
  end.

  run fill-widgets in this-procedure no-error.
  if error-status:error then undo, return error.
  if p-mode <> {&update} then do:
     disable
    pr-abs-d
    pr-altex
    pr-clt-q
    pr-discm
    pr-dpl-q
    pr-dscnt
    pr-equ-dq
    pr-incpc
    pr-list
    pr-notls
    pr-parex
    pr-print
    pr-rdc-q
    pr-rndbs
    pr-rndmt
    pr-sclex
    pr-sigma
  with frame frame-a.
  disable
    pr-goods
    pr-nogds
    pr-goods0
    pr-nogds0
  with frame frame-b.

     B-exit:label in frame {&frame-name} = "Вы&ход"  .
     hide B-quit in frame {&frame-name} .
  END.
  IF p-mode <> {&LOOKUP} THEN DO:
   IF NOT pr-notls THEN DO:
      DISPLAY  pr-parex pr-sclex pr-altex WITH FRAME FRAME-a .
      DISABLE pr-parex pr-sclex pr-altex WITH FRAME FRAME-a .
   END.
 END.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-proc Dialog-Frame 
PROCEDURE save-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-sale-add        as character no-undo .
define variable v-same            as logical   no-undo .
define variable v-param-type      as character no-undo .
define variable v-trf-type like ub.clients.obj-type no-undo .
define variable v-trf-code like ub.clients.obj-code no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
IF p-mode = {&LOOKUP} THEN RETURN .
define variable loc#log           as logical   no-undo .
/* Проверка прав */
  { gbl/chk-actg.i
    g#db-num
    g#userid
    {&action-head-code-main}
    'actn_global-trn_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    loc#log
  }
  if loc#log <> yes then do: return error. end.

ASSIGN
    pr-abs-d FRAME FRAME-a
    pr-altex
    pr-clt-q
    pr-discm
    pr-dpl-q
    pr-dscnt
    pr-equ-dq
    pr-incpc
    pr-list
    pr-notls
    pr-parex
    pr-print
    pr-rdc-q
    pr-rndbs
    pr-rndmt
    pr-sclex
    pr-sigma
    .
ASSIGN
    pr-goods FRAME FRAME-b
    pr-nogds
    pr-goods0
    pr-nogds0
    .

assign
  fh = frame frame-a:first-child
  wh = fh:first-child
  .
do while valid-handle(wh):
  if wh:private-data begins "recid2=" then do:
    find first thbjattr_thbj-attr-tt where
              recid(thbjattr_thbj-attr-tt) = integer(entry(2, wh:private-data, '=')) exclusive-lock.
    assign
      buffer thbjattr_thbj-attr-tt:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value
      thbjattr_thbj-attr-tt.obj-type = p-obj-type
      thbjattr_thbj-attr-tt.obj-code = p-obj-code
    .
  end.
  wh = wh:next-sibling.
end.
assign
  fh = frame frame-b:first-child
  wh = fh:first-child
  .

do while valid-handle(wh):
  if wh:private-data begins "recid2=" then do:
    find first thbjattr_thbj-attr-tt where
              recid(thbjattr_thbj-attr-tt) = integer(entry(2, wh:private-data, '=')).
    assign
      buffer thbjattr_thbj-attr-tt:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value
      thbjattr_thbj-attr-tt.obj-type = p-obj-type
      thbjattr_thbj-attr-tt.obj-code = p-obj-code
    .
  end.
  wh = wh:next-sibling.
end.

v-same = yes.
for each thbjattr_thbj-attr-tt,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type         = thbjattr_thbj-attr-tt.obj-type
      and temp-thbj-attr.obj-code         = thbjattr_thbj-attr-tt.obj-code
      and temp-thbj-attr.upper-prop-code  = thbjattr_thbj-attr-tt.upper-prop-code
      and temp-thbj-attr.prop-code        = thbjattr_thbj-attr-tt.prop-code
      :
   buffer-compare
   thbjattr_thbj-attr-tt
   to temp-thbj-attr
   save result in v-same.
   if not v-same then leave.
end.

v-same = no.
IF v-same  and not v-to-create THEN RETURN.

do TRANSACTION
on error undo, return error return-value
:
  run thbjattr_set-section in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input {&attr-overval}
      , input table thbjattr_thbj-attr-tt
  ) no-error.
  if error-status:error then do:
    message error-status:get-message(1)  skip
    return-value
    view-as alert-box.
    undo, return error.
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

