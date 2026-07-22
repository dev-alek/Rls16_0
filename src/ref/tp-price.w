&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt_price-list-type-cash-pay NO-UNDO LIKE ub.price-list-type-cash-pay.
DEFINE TEMP-TABLE tt_price-list-type-cassa NO-UNDO LIKE ub.price-list-type-cassa.
DEFINE TEMP-TABLE tt_price-list-type-gds-grp NO-UNDO LIKE ub.price-list-type-gds-grp.
DEFINE TEMP-TABLE tt_price-list-type-pay-type NO-UNDO LIKE ub.price-list-type-pay-type.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка типа прайс-листа

Автор: Чернова Светлана Александровна
Дата создания: 11/10/05
Author: Svetlana Chernova
Creation date: 11/10/05


loc_only-gbd  - Это галка АВТОПЕРЕОЦЕНКИ
*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input  parameter parparentproc as handle no-undo .
define input  parameter p-main-price as logical   no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter p-recid as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка типа прайс-листа".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ ref/typl-ad.i  }
{ cmp/operlist.i }
{ ref/xobjgrp.i  }
{ gbl/waitfram.i }
{ gbl/getsect.i def}
/* Local Variable Definitions --- */

define variable v-x-button-1  as decimal   no-undo .
define variable v-x-button-2  as decimal   no-undo .
define variable v-x-button-3  as decimal   no-undo .
define variable v-y-button-1  as decimal   no-undo .
define variable v-y-button-2  as decimal   no-undo .
define variable v-y-button-3  as decimal   no-undo .
define variable l-x-button-1  as decimal   no-undo .
define variable l-x-button-2  as decimal   no-undo .
define variable l-x-button-3  as decimal   no-undo .
define variable l-y-button-1  as decimal   no-undo .
define variable l-y-button-2  as decimal   no-undo .
define variable l-y-button-3  as decimal   no-undo .
define variable v-nn as integer   no-undo .
define variable v-t-recid as character no-undo .

&Scoped-define assign-0 loc_name loc_priority ~
loc_create-price-doc loc_fix-cource-crc-base loc_send-cassa ~
loc_fix-cource-crc-doc loc_calc-method loc_calc-increase-pc loc_calc-round-base ~
loc_calc-round-method loc_ban-discnt loc_work-date loc_only-gbd loc_curr-code ~
loc_under-hand-corr loc_under-type-list loc_plt-main-id loc_plt-main-db-num

define variable loc_under-round-method AS CHARACTER NO-UNDO.
define variable loc_under-perc as decimal   no-undo .

define variable   loc_ie-gen-marg   as character no-undo .
define variable   loc_ie-gen-marg-parts   as character no-undo .
define variable   loc_ie-objfirst   as integer   no-undo .
define variable   loc_ie-objsecond  as integer   no-undo .
define variable   loc_ie-pr-nakl    as logical   no-undo .
define variable   loc_iv-gen-marg   as character no-undo .
define variable   loc_iv-gen-marg-parts   as character no-undo .
define variable   loc_iv-objfirst   as integer   no-undo .
define variable   loc_iv-objsecond  as integer   no-undo .
define variable   loc_iv-pr-nakl    as logical   no-undo .
define variable   loc_im-gen-marg   as character no-undo .
define variable   loc_im-gen-marg-parts   as character no-undo .
define variable   loc_im-objfirst   as integer   no-undo .
define variable   loc_im-objsecond  as integer   no-undo .
define variable   loc_im-pr-nakl    as logical   no-undo .

define temp-table temp-avto-price no-undo
field nn as integer
field ext-doc-type as character format "x(18)"
field gen-marg   as character format "x(15)"
field gen-marg-parts   as character format "x(15)"
field objfirst   as integer
field objsecond  as integer
field pr-nakl    as logical
index pi nn ext-doc-type.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-tt

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-avto-price ub.price-list-type

/* Definitions for BROWSE BR-tt                                         */
&Scoped-define FIELDS-IN-QUERY-BR-tt temp-avto-price.ext-doc-type temp-avto-price.gen-marg temp-avto-price.gen-marg-parts if temp-avto-price.objfirst = 1 then "по группе объектов" else "по тек. объекту" if temp-avto-price.objsecond = 1 then "по группе объектов" else "по тек. объекту" string(temp-avto-price.pr-nakl,"да/нет")
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-tt
&Scoped-define SELF-NAME BR-tt
&Scoped-define QUERY-STRING-BR-tt FOR EACH temp-avto-price
&Scoped-define OPEN-QUERY-BR-tt OPEN QUERY {&SELF-NAME} FOR EACH temp-avto-price.
&Scoped-define TABLES-IN-QUERY-BR-tt temp-avto-price
&Scoped-define FIRST-TABLE-IN-QUERY-BR-tt temp-avto-price


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH ub.price-list-type SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH ub.price-list-type SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame ub.price-list-type
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame ub.price-list-type


/* Definitions for FRAME page-2                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-page-2 ~
    ~{&OPEN-QUERY-BR-tt}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-save B-Cancel B-Help RECT-1 loc_priority ~
loc_name r-cur loc_under-type-list BUTTON-1 loc_fix-cource-crc-base ~
loc_work-date loc_fix-cource-crc-doc l-ban-discnt b-ban-discnt ~
loc_calc-method loc_calc-increase-pc loc_only-gbd loc_calc-round-method ~
loc_calc-round-base BUTTON-2 BUTTON-3 loc_plt-db-num loc_plt-id ~
loc_curr-code loc_abbr-doc work-date-FILL-IN loc_ban-discnt f-ban-discnt ~
create-price-doc-FILL-IN use-cassa-FILL-IN
&Scoped-Define DISPLAYED-OBJECTS loc_priority loc_name loc_under-type-list ~
loc_fix-cource-crc-base loc_work-date loc_fix-cource-crc-doc l-ban-discnt ~
loc_calc-method loc_create-price-doc loc_calc-increase-pc loc_send-cassa ~
loc_only-gbd loc_calc-round-method loc_calc-round-base loc_plt-db-num ~
loc_plt-id v-max loc_curr-code loc_abbr-doc work-date-FILL-IN ~
loc_ban-discnt f-ban-discnt create-price-doc-FILL-IN use-cassa-FILL-IN ~
label-button-1 label-button-2 label-button-3

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,assign-1,assign-2,assign-3                      */
&Scoped-define List-1 v-1 loc_have-rs-qnty-group r-qnty-grp ~
loc_have-rs-sum-group r-qnty-sgr loc_have-rs-turn-group r-have-tog ~
loc_qgr-id loc_qgr-db-num loc_qg_name loc_sgr-id loc_sgr-db-num loc_sg_name ~
loc_have-tog-db-num loc_have-tog_name loc_have-tog-id
&Scoped-define List-2 loc_use-obj r-gop v-2 loc_rs-buyer r-gop-2 r-qnty-tog ~
loc_obj-turnover r-gop-calc loc_use-cassa v-spis-kass r-use-obj-fill-in ~
loc_gop-id loc_gop-db-num loc_gop_name-name r-FILL-IN loc_bgr-id ~
loc_bgr-db-num loc_bgr_name loc_tog-db-num loc_tog-id r-obj-fill-in ~
loc_gop-id-for-calc-turnover loc_gop-db-num-for-calc-turnover ~
loc_gop_name-tnv loc_use-cassa_FILL-IN loc_tog_name
&Scoped-define List-3 v-3 loc_use-gds-group loc_use-pay-type v-spis-group ~
v-spis-type-pay loc_use-cash-pay v-spis-use-cash-pay F-ogran
&Scoped-define assign-1 loc_have-rs-qnty-group loc_have-rs-sum-group ~
loc_have-rs-turn-group loc_qgr-id loc_qgr-db-num loc_sgr-id loc_sgr-db-num ~
loc_have-tog-db-num loc_have-tog-id
&Scoped-define assign-2 loc_use-obj loc_rs-buyer loc_obj-turnover ~
loc_use-cassa loc_gop-id loc_gop-db-num loc_bgr-id loc_bgr-db-num ~
loc_tog-db-num loc_tog-id loc_gop-id-for-calc-turnover ~
loc_gop-db-num-for-calc-turnover
&Scoped-define assign-3 loc_use-gds-group loc_use-pay-type loc_use-cash-pay

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-ban-discnt
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Просмотр скидки".

DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-save AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON BUTTON-1
     IMAGE-UP FILE "adeicon\ts-down":U
     IMAGE-DOWN FILE "adeicon\ts-up":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up":U NO-FOCUS
     LABEL "Расширение"
     SIZE 14.5 BY 1.13
     FONT 4.

DEFINE BUTTON BUTTON-2
     IMAGE-UP FILE "adeicon\ts-down":U
     IMAGE-DOWN FILE "adeicon\ts-up":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up":U NO-FOCUS
     LABEL "Butt"
     SIZE 14.5 BY 1.13.

DEFINE BUTTON BUTTON-3
     IMAGE-UP FILE "adeicon\ts-down":U
     IMAGE-DOWN FILE "adeicon\ts-up":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up":U NO-FOCUS
     LABEL "Butt"
     SIZE 14.25 BY 1.13.

DEFINE BUTTON r-ban-discnt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Выбор из списка ШАБЛОНОВ СКИДКИ".

DEFINE BUTTON r-cur
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88 TOOLTIP "Выбор из списка".

DEFINE BUTTON r-rod-price-type
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Выбор из списка".

DEFINE VARIABLE loc_calc-method AS CHARACTER FORMAT "X(256)":U
     LABEL "Расчет цены по умолчанию"
     VIEW-AS COMBO-BOX INNER-LINES 19
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 16 BY 1 TOOLTIP "Метод расчета цены" NO-UNDO.

DEFINE VARIABLE loc_calc-round-method AS CHARACTER FORMAT "X(256)":U
     LABEL "Метод округления по умолчанию"
     VIEW-AS COMBO-BOX INNER-LINES 7
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE create-price-doc-FILL-IN AS CHARACTER FORMAT "X(256)" INITIAL "Формировать переоценки:"
      VIEW-AS TEXT
     SIZE 23.5 BY .67.

DEFINE VARIABLE f-ban-discnt AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 44.88 BY .67 NO-UNDO.

DEFINE VARIABLE label-button-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Привязка"
      VIEW-AS TEXT
     SIZE 7.5 BY .58
     FONT 4 NO-UNDO.

DEFINE VARIABLE label-button-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Распространение"
      VIEW-AS TEXT
     SIZE 11.75 BY .58
     FONT 4 NO-UNDO.

DEFINE VARIABLE label-button-3 AS CHARACTER FORMAT "X(256)":U INITIAL "Ограничения"
      VIEW-AS TEXT
     SIZE 9.13 BY .58
     FONT 4 NO-UNDO.

DEFINE VARIABLE loc_abbr-doc AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 4.13 BY .67 TOOLTIP "Валюта платежа"
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE loc_ban-discnt AS INTEGER FORMAT ">>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 4.38 BY .67 NO-UNDO.

DEFINE VARIABLE loc_calc-increase-pc AS DECIMAL FORMAT "->>,>>9.99" INITIAL 0
     LABEL "% наценки по умолчанию"
     VIEW-AS FILL-IN
     SIZE 11 BY 1.

DEFINE VARIABLE loc_calc-round-base AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE loc_curr-code AS INTEGER FORMAT ">>9" INITIAL 0
     LABEL "Валюта"
      VIEW-AS TEXT
     SIZE 4 BY .67 NO-UNDO.

DEFINE VARIABLE loc_name LIKE ub.price-list-type.name
     LABEL "Тип прайс-листа"
     VIEW-AS FILL-IN
     SIZE 61.88 BY .92
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE loc_plt-db-num AS INTEGER FORMAT ">>>>9" INITIAL 0
     LABEL "БД"
      VIEW-AS TEXT
     SIZE 5.63 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE loc_plt-id LIKE ub.price-list-type.plt-id
     LABEL "Код"
      VIEW-AS TEXT
     SIZE 10 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE loc_plt-main-db-num AS INTEGER FORMAT ">>>>9" INITIAL 0
      VIEW-AS TEXT
     SIZE 3 BY .75 TOOLTIP "БД"
     FGCOLOR 4 .

DEFINE VARIABLE loc_plt-main-id AS INTEGER FORMAT ">>>>>>>" INITIAL 0
     LABEL "->Родительский ПЛ"
      VIEW-AS TEXT
     SIZE 6.25 BY .67 TOOLTIP "Родительский тип прайс-листа"
     FGCOLOR 4 .

DEFINE VARIABLE loc_priority AS INTEGER FORMAT ">>>>>>9" INITIAL 0
     LABEL "Приоритет"
     VIEW-AS FILL-IN
     SIZE 9 BY .92.

DEFINE VARIABLE loc_rod-pt-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 38.75 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE use-cassa-FILL-IN AS CHARACTER FORMAT "X(256)" INITIAL "Отправлять на кассы:"
      VIEW-AS TEXT
     SIZE 20.5 BY .67.

DEFINE VARIABLE v-max AS INTEGER FORMAT "->>>>9":U INITIAL 0
     LABEL "сейчас MAX приоритет"
      VIEW-AS TEXT
     SIZE 9 BY .54 TOOLTIP "MAX приоритет на текущий момент в этой БД"
     FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE work-date-FILL-IN AS CHARACTER FORMAT "X(256)" INITIAL "Признак работы на объекте по:"
      VIEW-AS TEXT
     SIZE 30 BY .67
     FGCOLOR 1 .

DEFINE VARIABLE loc_create-price-doc AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "да", 1,
"нет", 2
     SIZE 10.5 BY .67 NO-UNDO.

DEFINE VARIABLE loc_send-cassa AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "да", 1,
"нет", 2
     SIZE 10.5 BY .67 NO-UNDO.

DEFINE VARIABLE loc_work-date AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "дате на объекте", 1,
"сменной дате и № смены", 2,
"дате и времени сервера", 3
     SIZE 24.88 BY 2.25 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 98.5 BY 11.29
     BGCOLOR 15 .

DEFINE VARIABLE l-ban-discnt AS LOGICAL INITIAL no
     LABEL "Шаблон скидки"
     VIEW-AS TOGGLE-BOX
     SIZE 16 BY .83 TOOLTIP "Есть ли привязка к правилам скидки" NO-UNDO.

DEFINE VARIABLE loc_fix-cource-crc-base AS LOGICAL INITIAL no
     LABEL "Фиксированный курс базовой валюты"
     VIEW-AS TOGGLE-BOX
     SIZE 36.5 BY .83 NO-UNDO.

DEFINE VARIABLE loc_fix-cource-crc-doc AS LOGICAL INITIAL no
     LABEL "Фиксированный курс валюты прайс-листа"
     VIEW-AS TOGGLE-BOX
     SIZE 40 BY .83 NO-UNDO.

DEFINE VARIABLE loc_only-gbd AS LOGICAL INITIAL no
     LABEL "Для автопереоценок"
     VIEW-AS TOGGLE-BOX
     SIZE 28.25 BY .83 TOOLTIP "Используется для создания переоценок по ПН. На 1 объекте может быть только 1 такой тип "
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc_under-hand-corr AS LOGICAL INITIAL no
     LABEL "Подчиненный прайс-лист подлежит ручной коррекции"
     VIEW-AS TOGGLE-BOX
     SIZE 51.5 BY .71 NO-UNDO.

DEFINE VARIABLE loc_under-type-list AS LOGICAL INITIAL no
     LABEL "Пoдчиненный ПЛ"
     VIEW-AS TOGGLE-BOX
     SIZE 16.63 BY .67 TOOLTIP "Пoдчиненный прайс-лист" NO-UNDO.

DEFINE BUTTON b-have-tog
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Просмотр состава".

DEFINE BUTTON b-qnty-grp
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Просмотр состава".

DEFINE BUTTON b-qnty-sgr
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Просмотр состава".

DEFINE BUTTON r-have-tog
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Выбор из списка".

DEFINE BUTTON r-qnty-grp
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Выбор из списка".

DEFINE BUTTON r-qnty-sgr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Выбор из списка".

DEFINE VARIABLE loc_have-tog-db-num AS INTEGER FORMAT ">>>>9" INITIAL 0
      VIEW-AS TEXT
     SIZE 2.5 BY .67 TOOLTIP "БД" NO-UNDO.

DEFINE VARIABLE loc_have-tog-id AS INTEGER FORMAT ">>>>>>>" INITIAL 0
      VIEW-AS TEXT
     SIZE 6.25 BY .67 NO-UNDO.

DEFINE VARIABLE loc_have-tog_name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 39.63 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE loc_qgr-db-num AS INTEGER FORMAT ">>>>9" INITIAL 0
      VIEW-AS TEXT
     SIZE 2.5 BY .83 TOOLTIP "БД" NO-UNDO.

DEFINE VARIABLE loc_qgr-id AS INTEGER FORMAT ">>>>>>>" INITIAL 0
      VIEW-AS TEXT
     SIZE 6.25 BY .83 NO-UNDO.

DEFINE VARIABLE loc_qg_name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 39.75 BY .83
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE loc_sgr-db-num AS INTEGER FORMAT ">>>>9" INITIAL 0
      VIEW-AS TEXT
     SIZE 2.5 BY .83 TOOLTIP "БД" NO-UNDO.

DEFINE VARIABLE loc_sgr-id LIKE ub.price-list-type.qgr-id
      VIEW-AS TEXT
     SIZE 6.25 BY .83 NO-UNDO.

DEFINE VARIABLE loc_sg_name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 39.63 BY .83
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE v-1 AS CHARACTER FORMAT "X(256)":U
     LABEL "first"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE loc_have-rs-qnty-group AS LOGICAL INITIAL no
     LABEL "Есть связь с количественной группой"
     VIEW-AS TOGGLE-BOX
     SIZE 38.88 BY .83 NO-UNDO.

DEFINE VARIABLE loc_have-rs-sum-group AS LOGICAL INITIAL no
     LABEL "Есть связь с суммовой группой"
     VIEW-AS TOGGLE-BOX
     SIZE 36.75 BY .83 NO-UNDO.

DEFINE VARIABLE loc_have-rs-turn-group AS LOGICAL INITIAL no
     LABEL "Есть связь с группой по оборотам"
     VIEW-AS TOGGLE-BOX
     SIZE 36 BY .83 NO-UNDO.

DEFINE BUTTON B-chga
     LABEL "Изменить"
     SIZE 9.5 BY 1 TOOLTIP "Изменить  настройки по типу документа".

DEFINE BUTTON b-gop
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY .88 TOOLTIP "Просмотр состава".

DEFINE BUTTON b-gop-2
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Просмотр состава".

DEFINE BUTTON b-gop-calc
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Просмотр состава".

DEFINE BUTTON b-qnty-tog
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Просмотр состава".

DEFINE BUTTON r-gop
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88 TOOLTIP "Выбор из списка".

DEFINE BUTTON r-gop-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Выбор из списка".

DEFINE BUTTON r-gop-calc
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Выбор из списка".

DEFINE BUTTON r-qnty-tog
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Выбор из списка".

DEFINE VARIABLE v-spis-kass AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 36.5 BY 4
     tooltip "Список разрешенных к работе касс"
     FONT 0 NO-UNDO.

DEFINE VARIABLE f-ie-3 AS CHARACTER FORMAT "X(256)":U INITIAL "Тип автопереоценки:"
      VIEW-AS TEXT
     SIZE 19.5 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE loc_bgr-db-num AS INTEGER FORMAT ">>>>9" INITIAL 0
      VIEW-AS TEXT
     SIZE 2.5 BY .67 TOOLTIP "БД" NO-UNDO.

DEFINE VARIABLE loc_bgr-id AS INTEGER FORMAT ">>>>>>>" INITIAL 0
     LABEL "Группа покупателей"
      VIEW-AS TEXT
     SIZE 6.25 BY .67 NO-UNDO.

DEFINE VARIABLE loc_bgr_name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 39.63 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE loc_gop-db-num AS INTEGER FORMAT ">>>>9" INITIAL 0
      VIEW-AS TEXT
     SIZE 2.5 BY .88 TOOLTIP "БД" NO-UNDO.

DEFINE VARIABLE loc_gop-db-num-for-calc-turnover AS INTEGER FORMAT ">>>>9" INITIAL 0
      VIEW-AS TEXT
     SIZE 2.5 BY .83 TOOLTIP "БД" NO-UNDO.

DEFINE VARIABLE loc_gop-id LIKE ub.price-list-type.qgr-id
      VIEW-AS TEXT
     SIZE 6.25 BY .88 NO-UNDO.

DEFINE VARIABLE loc_gop-id-for-calc-turnover LIKE ub.price-list-type.qgr-id
      VIEW-AS TEXT
     SIZE 6.25 BY .83 NO-UNDO.

DEFINE VARIABLE loc_gop_name-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 37.25 BY .88
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE loc_gop_name-tnv AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 37.25 BY .83
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE loc_tog-db-num AS INTEGER FORMAT ">>>>9" INITIAL 0
      VIEW-AS TEXT
     SIZE 2.5 BY .67 TOOLTIP "БД" NO-UNDO.

DEFINE VARIABLE loc_tog-id LIKE ub.price-list-type.qgr-id
     LABEL "Группа оборотов  ."
      VIEW-AS TEXT
     SIZE 6.25 BY .67 NO-UNDO.

DEFINE VARIABLE loc_tog_name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 39.63 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE loc_use-cassa_FILL-IN AS CHARACTER FORMAT "X(256)":U INITIAL "Распространение по кассам:"
      VIEW-AS TEXT
     SIZE 27 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE r-FILL-IN AS CHARACTER FORMAT "X(256)":U INITIAL "Распространение по покупателям"
      VIEW-AS TEXT
     SIZE 30.5 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE r-obj-fill-in AS CHARACTER FORMAT "X(256)":U INITIAL "Объекты для расчета оборота:"
      VIEW-AS TEXT
     SIZE 28.38 BY .83 TOOLTIP "Объекты для расчета совокупного оборота" NO-UNDO.

DEFINE VARIABLE r-use-obj-fill-in AS CHARACTER FORMAT "X(256)":U INITIAL "Распространение по объектам:"
      VIEW-AS TEXT
     SIZE 28 BY .88 TOOLTIP "Распространение по объектам"
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE v-2 AS CHARACTER FORMAT "X(256)":U
     LABEL "second"
     VIEW-AS FILL-IN
     SIZE 1.5 BY 1 NO-UNDO.

DEFINE VARIABLE loc_obj-turnover AS LOGICAL
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", no,
"Группа", yes
     SIZE 14.5 BY .83 NO-UNDO.

DEFINE VARIABLE loc_rs-buyer AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 0,
"Группа", 1,
"Оборот", 2
     SIZE 23 BY .58 TOOLTIP "Распространение по покупателям" NO-UNDO.

DEFINE VARIABLE loc_use-cassa AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "не отправлять", 1,
"на все", 2,
"выборочно", 3
     SIZE 37 BY .71 TOOLTIP "Распространение по кассам" NO-UNDO.

DEFINE VARIABLE loc_use-obj AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 1,
"Группа", 2
     SIZE 14.5 BY .88 NO-UNDO.

DEFINE VARIABLE v-spis-group AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 55 BY 3.54
     tooltip "Список разрешенных к работе групп"
     NO-UNDO.

DEFINE VARIABLE v-spis-type-pay AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 32.5 BY 3.54
     tooltip "Список разрешенных к работе типов"
     NO-UNDO.

DEFINE VARIABLE v-spis-use-cash-pay AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 33.13 BY 2.63
     tooltip "Список разрешенных к работе типов"
     NO-UNDO.

DEFINE VARIABLE F-ogran AS CHARACTER FORMAT "X(256)":U INITIAL "Есть ограничение:"
      VIEW-AS TEXT
     SIZE 17.5 BY .67 NO-UNDO.

DEFINE VARIABLE v-3 AS CHARACTER FORMAT "X(256)":U
     LABEL "tree"
     VIEW-AS FILL-IN
     SIZE 2.5 BY 1 NO-UNDO.

DEFINE VARIABLE loc_use-cash-pay AS LOGICAL INITIAL no
     LABEL "по типам кассовых платежей"
     VIEW-AS TOGGLE-BOX
     SIZE 28.63 BY .83 TOOLTIP "Есть ограничения по типам кассовых платежей" NO-UNDO.

DEFINE VARIABLE loc_use-gds-group AS LOGICAL INITIAL no
     LABEL "по группам товаров"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY .83 TOOLTIP "Есть ограничения по группам товаров" NO-UNDO.

DEFINE VARIABLE loc_use-pay-type AS LOGICAL INITIAL no
     LABEL "по типам платежа"
     VIEW-AS TOGGLE-BOX
     SIZE 18.75 BY .83 TOOLTIP "Есть ограничения по типам платежа" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-tt FOR
      temp-avto-price SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      ub.price-list-type SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-tt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-tt Dialog-Frame _FREEFORM
  QUERY BR-tt DISPLAY
      temp-avto-price.ext-doc-type COLUMN-LABEL " ! !Тип прихода"     format "x(17)"
 temp-avto-price.gen-marg     COLUMN-LABEL "!Тип!автопереоценки"  format "x(14)"
 temp-avto-price.gen-marg-parts     COLUMN-LABEL "!Автопереоценка!по партиям"  format "x(14)"
 if temp-avto-price.objfirst = 1 then "по группе объектов"  else "по тек. объекту"     COLUMN-LABEL "Автопереоценка!на новый товар!остаток 0 " format "x(18)"
 if temp-avto-price.objsecond   = 1 then "по группе объектов"  else "по тек. объекту"  COLUMN-LABEL "Автопереоценка!на НЕ новый!товар "        format "x(18)"
 string(temp-avto-price.pr-nakl,"да/нет")      COLUMN-LABEL "Задавать!продажную цену!в док.прихода"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 95.63 BY 5.75 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-save AT ROW 1 COL 1
     B-Cancel AT ROW 1 COL 11
     B-Help AT ROW 1 COL 90
     loc_priority AT ROW 2 COL 89.5 COLON-ALIGNED
     loc_name AT ROW 2.04 COL 16.13 COLON-ALIGNED HELP
          ""
          LABEL "Тип прайс-листа" FORMAT "X(80)"
          FGCOLOR 1
     r-cur AT ROW 3.13 COL 13.63
     loc_under-type-list AT ROW 3.96 COL 1.75
     BUTTON-1 AT ROW 11.04 COL 1.88
     r-rod-price-type AT ROW 3.96 COL 44.38
     loc_under-hand-corr AT ROW 4.75 COL 1.75
     loc_fix-cource-crc-base AT ROW 5.46 COL 1.75
     loc_work-date AT ROW 5.75 COL 74.88 NO-LABEL
     loc_fix-cource-crc-doc AT ROW 6.29 COL 1.75
     l-ban-discnt AT ROW 7.04 COL 1.75 WIDGET-ID 10
     r-ban-discnt AT ROW 7.04 COL 22.63 WIDGET-ID 4
     b-ban-discnt AT ROW 7.04 COL 25.25 WIDGET-ID 6
     loc_calc-method AT ROW 8 COL 81 COLON-ALIGNED
     loc_create-price-doc AT ROW 8.04 COL 25.5 NO-LABEL
     loc_calc-increase-pc AT ROW 9 COL 81 COLON-ALIGNED
     loc_send-cassa AT ROW 9.04 COL 25.5 NO-LABEL
     loc_only-gbd AT ROW 10 COL 2.13
     loc_calc-round-method AT ROW 10 COL 81 COLON-ALIGNED
     loc_calc-round-base AT ROW 11 COL 81 COLON-ALIGNED NO-LABEL
     BUTTON-2 AT ROW 11.04 COL 16.13
     BUTTON-3 AT ROW 11.04 COL 30.38
     loc_plt-db-num AT ROW 1 COL 66.13 COLON-ALIGNED
     loc_plt-id AT ROW 1 COL 77.13 COLON-ALIGNED HELP
          ""
          LABEL "Код" FORMAT ">>>>>>>"
          FGCOLOR 1
     v-max AT ROW 3.04 COL 89.5 COLON-ALIGNED
     loc_curr-code AT ROW 3.21 COL 7.63 COLON-ALIGNED
     loc_abbr-doc AT ROW 3.21 COL 14.88 COLON-ALIGNED NO-LABEL
     loc_plt-main-id AT ROW 3.96 COL 35.5 COLON-ALIGNED
     loc_plt-main-db-num AT ROW 3.96 COL 45.88 COLON-ALIGNED NO-LABEL
     loc_rod-pt-name AT ROW 3.96 COL 48 COLON-ALIGNED NO-LABEL
     work-date-FILL-IN AT ROW 5 COL 70.13 NO-LABEL
     loc_ban-discnt AT ROW 7.13 COL 15.63 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     f-ban-discnt AT ROW 7.13 COL 26.63 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     create-price-doc-FILL-IN AT ROW 8.04 COL 1.5 NO-LABEL
     use-cassa-FILL-IN AT ROW 9.04 COL 2.38 COLON-ALIGNED NO-LABEL
     label-button-1 AT ROW 11.25 COL 3 NO-LABEL
     label-button-2 AT ROW 11.25 COL 15.25 COLON-ALIGNED NO-LABEL
     label-button-3 AT ROW 11.25 COL 29.88 COLON-ALIGNED NO-LABEL
     RECT-1 AT ROW 11.96 COL 1.5
     SPACE(0.50) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS THREE-D  SCROLLABLE
         TITLE "<insert dialog title>".

DEFINE FRAME page-2
     loc_use-obj AT ROW 1.08 COL 29.88 NO-LABEL
     r-gop AT ROW 1.08 COL 51.38
     b-gop AT ROW 1.08 COL 54 WIDGET-ID 6
     v-2 AT ROW 2.08 COL 92.5 COLON-ALIGNED
     BR-tt AT ROW 2.25 COL 1.38 WIDGET-ID 100
     loc_rs-buyer AT ROW 2.67 COL 32.25 NO-LABEL
     r-gop-2 AT ROW 3.33 COL 27.75
     b-gop-2 AT ROW 3.38 COL 30.38 WIDGET-ID 2
     r-qnty-tog AT ROW 4.25 COL 27.75
     b-qnty-tog AT ROW 4.29 COL 30.38 WIDGET-ID 4
     loc_obj-turnover AT ROW 5.29 COL 30.13 NO-LABEL
     r-gop-calc AT ROW 5.29 COL 51.5
     b-gop-calc AT ROW 5.29 COL 54.13 WIDGET-ID 8
     loc_use-cassa AT ROW 6.75 COL 28.25 NO-LABEL
     v-spis-kass AT ROW 7.5 COL 1.38 NO-LABEL
     B-chga AT ROW 8 COL 87.5 WIDGET-ID 10
     r-use-obj-fill-in AT ROW 1.08 COL 1 NO-LABEL
     loc_gop-id AT ROW 1.08 COL 43.38 COLON-ALIGNED HELP
          "" NO-LABEL FORMAT ">>>>>>>"
     loc_gop-db-num AT ROW 1.08 COL 54.88 COLON-ALIGNED NO-LABEL
     loc_gop_name-name AT ROW 1.08 COL 57.75 COLON-ALIGNED NO-LABEL
     f-ie-3 AT ROW 2.42 COL 1.88 NO-LABEL
     r-FILL-IN AT ROW 2.58 COL 1.13 NO-LABEL
     loc_bgr-id AT ROW 3.42 COL 19.25 COLON-ALIGNED
     loc_bgr-db-num AT ROW 3.5 COL 31.38 COLON-ALIGNED NO-LABEL
     loc_bgr_name AT ROW 3.5 COL 34.5 COLON-ALIGNED NO-LABEL
     loc_tog-db-num AT ROW 4.25 COL 31.38 COLON-ALIGNED NO-LABEL
     loc_tog-id AT ROW 4.29 COL 19.25 COLON-ALIGNED HELP
          ""
          LABEL "Группа оборотов  ." FORMAT ">>>>>>>"
     r-obj-fill-in AT ROW 5.29 COL 1 NO-LABEL
     loc_gop-id-for-calc-turnover AT ROW 5.29 COL 43.5 COLON-ALIGNED HELP
          "" NO-LABEL FORMAT ">>>>>>"
     loc_gop-db-num-for-calc-turnover AT ROW 5.29 COL 55 COLON-ALIGNED NO-LABEL
     loc_gop_name-tnv AT ROW 5.29 COL 57.88 COLON-ALIGNED NO-LABEL
     loc_use-cassa_FILL-IN AT ROW 6.75 COL 1 NO-LABEL
     loc_tog_name AT ROW 4.25 COL 34.5 COLON-ALIGNED NO-LABEL
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 3 ROW 12.21
         SIZE 96.5 BY 10.79.

DEFINE FRAME page-1
     v-1 AT ROW 1 COL 81.5 COLON-ALIGNED
     loc_have-rs-qnty-group AT ROW 3.5 COL 1.5
     r-qnty-grp AT ROW 3.5 COL 46.75
     b-qnty-grp AT ROW 3.5 COL 49.75 WIDGET-ID 4
     loc_have-rs-sum-group AT ROW 4.88 COL 1.25
     r-qnty-sgr AT ROW 4.88 COL 46.5
     b-qnty-sgr AT ROW 4.88 COL 49.5 WIDGET-ID 6
     loc_have-rs-turn-group AT ROW 6.25 COL 1.5
     r-have-tog AT ROW 6.25 COL 46.5
     b-have-tog AT ROW 6.25 COL 49.5 WIDGET-ID 2
     loc_qgr-id AT ROW 3.5 COL 38.25 COLON-ALIGNED NO-LABEL
     loc_qgr-db-num AT ROW 3.5 COL 51.13 COLON-ALIGNED NO-LABEL
     loc_qg_name AT ROW 3.5 COL 54.25 COLON-ALIGNED NO-LABEL
     loc_sgr-id AT ROW 4.88 COL 38 COLON-ALIGNED HELP
          "" NO-LABEL FORMAT ">>>>>>>"
     loc_sgr-db-num AT ROW 4.88 COL 50.88 COLON-ALIGNED NO-LABEL
     loc_sg_name AT ROW 4.88 COL 54.13 COLON-ALIGNED NO-LABEL
     loc_have-tog-db-num AT ROW 6.25 COL 50.88 COLON-ALIGNED NO-LABEL
     loc_have-tog_name AT ROW 6.25 COL 54.13 COLON-ALIGNED NO-LABEL
     loc_have-tog-id AT ROW 6.29 COL 38 COLON-ALIGNED NO-LABEL
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 3 ROW 12.17
         SIZE 96.5 BY 6.58.

DEFINE FRAME page-3
     v-3 AT ROW 1.25 COL 92.5 COLON-ALIGNED
     loc_use-gds-group AT ROW 2 COL 1.5
     loc_use-pay-type AT ROW 2.25 COL 63.63
     v-spis-group AT ROW 2.92 COL 1.5 NO-LABEL
     v-spis-type-pay AT ROW 2.96 COL 63.5 NO-LABEL
     loc_use-cash-pay AT ROW 8.04 COL 63
     v-spis-use-cash-pay AT ROW 8.75 COL 63 NO-LABEL
     F-ogran AT ROW 1.25 COL 1 NO-LABEL
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 3 ROW 12.21
         SIZE 96.5 BY 10.79.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt_price-list-type-cash-pay T "?" NO-UNDO ub price-list-type-cash-pay
      TABLE: tt_price-list-type-cassa T "?" NO-UNDO ub price-list-type-cassa
      TABLE: tt_price-list-type-gds-grp T "?" NO-UNDO ub price-list-type-gds-grp
      TABLE: tt_price-list-type-pay-type T "?" NO-UNDO ub price-list-type-pay-type
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* REPARENT FRAME */
ASSIGN FRAME page-1:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME page-2:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME page-3:FRAME = FRAME Dialog-Frame:HANDLE.

/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   NOT-VISIBLE FRAME-NAME UNDERLINE                                     */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       BUTTON-1:AUTO-RESIZE IN FRAME Dialog-Frame      = TRUE.

ASSIGN
       BUTTON-2:AUTO-RESIZE IN FRAME Dialog-Frame      = TRUE.

ASSIGN
       BUTTON-3:AUTO-RESIZE IN FRAME Dialog-Frame      = TRUE.

/* SETTINGS FOR FILL-IN create-price-doc-FILL-IN IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN label-button-1 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
ASSIGN
       label-button-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN label-button-2 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       label-button-2:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN label-button-3 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       label-button-3:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       loc_ban-discnt:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR RADIO-SET loc_create-price-doc IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN loc_name IN FRAME Dialog-Frame
   LIKE = ub.price-list-type.name EXP-LABEL EXP-FORMAT EXP-HELP EXP-SIZE */
/* SETTINGS FOR FILL-IN loc_plt-id IN FRAME Dialog-Frame
   LIKE = ub.price-list-type.plt-id EXP-LABEL EXP-FORMAT EXP-HELP EXP-SIZE */
/* SETTINGS FOR FILL-IN loc_plt-main-db-num IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN loc_plt-main-id IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN loc_rod-pt-name IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR RADIO-SET loc_send-cassa IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX loc_under-hand-corr IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR BUTTON r-ban-discnt IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON r-rod-price-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-max IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       v-max:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN work-date-FILL-IN IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FRAME page-1
                                                                        */
/* SETTINGS FOR TOGGLE-BOX loc_have-rs-qnty-group IN FRAME page-1
   1 4                                                                  */
/* SETTINGS FOR TOGGLE-BOX loc_have-rs-sum-group IN FRAME page-1
   1 4                                                                  */
/* SETTINGS FOR TOGGLE-BOX loc_have-rs-turn-group IN FRAME page-1
   1 4                                                                  */
/* SETTINGS FOR FILL-IN loc_have-tog-db-num IN FRAME page-1
   1 4                                                                  */
/* SETTINGS FOR FILL-IN loc_have-tog-id IN FRAME page-1
   1 4                                                                  */
/* SETTINGS FOR FILL-IN loc_have-tog_name IN FRAME page-1
   1                                                                    */
/* SETTINGS FOR FILL-IN loc_qgr-db-num IN FRAME page-1
   1 4                                                                  */
/* SETTINGS FOR FILL-IN loc_qgr-id IN FRAME page-1
   1 4                                                                  */
/* SETTINGS FOR FILL-IN loc_qg_name IN FRAME page-1
   1                                                                    */
/* SETTINGS FOR FILL-IN loc_sgr-db-num IN FRAME page-1
   1 4                                                                  */
/* SETTINGS FOR FILL-IN loc_sgr-id IN FRAME page-1
   1 4 LIKE = ub.price-list-type.qgr-id EXP-LABEL EXP-FORMAT EXP-HELP EXP-SIZE */
/* SETTINGS FOR FILL-IN loc_sg_name IN FRAME page-1
   1                                                                    */
/* SETTINGS FOR BUTTON r-have-tog IN FRAME page-1
   1                                                                    */
/* SETTINGS FOR BUTTON r-qnty-grp IN FRAME page-1
   1                                                                    */
/* SETTINGS FOR BUTTON r-qnty-sgr IN FRAME page-1
   1                                                                    */
/* SETTINGS FOR FILL-IN v-1 IN FRAME page-1
   1                                                                    */
/* SETTINGS FOR FRAME page-2
   NOT-VISIBLE                                                          */
/* BROWSE-TAB BR-tt v-2 page-2 */
/* SETTINGS FOR FILL-IN f-ie-3 IN FRAME page-2
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN loc_bgr-db-num IN FRAME page-2
   NO-DISPLAY NO-ENABLE 2 5                                             */
/* SETTINGS FOR FILL-IN loc_bgr-id IN FRAME page-2
   NO-DISPLAY NO-ENABLE 2 5                                             */
/* SETTINGS FOR FILL-IN loc_bgr_name IN FRAME page-2
   NO-DISPLAY NO-ENABLE 2                                               */
/* SETTINGS FOR FILL-IN loc_gop-db-num IN FRAME page-2
   NO-ENABLE 2 5                                                        */
/* SETTINGS FOR FILL-IN loc_gop-db-num-for-calc-turnover IN FRAME page-2
   NO-ENABLE 2 5                                                        */
/* SETTINGS FOR FILL-IN loc_gop-id IN FRAME page-2
   NO-DISPLAY NO-ENABLE 2 5 LIKE = ub.price-list-type.qgr-id EXP-LABEL EXP-FORMAT EXP-HELP EXP-SIZE */
/* SETTINGS FOR FILL-IN loc_gop-id-for-calc-turnover IN FRAME page-2
   NO-DISPLAY NO-ENABLE 2 5 LIKE = ub.price-list-type.qgr-id EXP-LABEL EXP-FORMAT EXP-HELP EXP-SIZE */
/* SETTINGS FOR FILL-IN loc_gop_name-name IN FRAME page-2
   NO-DISPLAY NO-ENABLE 2                                               */
/* SETTINGS FOR FILL-IN loc_gop_name-tnv IN FRAME page-2
   NO-DISPLAY NO-ENABLE 2                                               */
/* SETTINGS FOR RADIO-SET loc_obj-turnover IN FRAME page-2
   NO-DISPLAY NO-ENABLE 2 5                                             */
/* SETTINGS FOR RADIO-SET loc_rs-buyer IN FRAME page-2
   NO-DISPLAY NO-ENABLE 2 5                                             */
/* SETTINGS FOR FILL-IN loc_tog-db-num IN FRAME page-2
   2 5                                                                  */
/* SETTINGS FOR FILL-IN loc_tog-id IN FRAME page-2
   NO-DISPLAY NO-ENABLE 2 5 LIKE = ub.price-list-type.qgr-id EXP-LABEL EXP-FORMAT EXP-HELP EXP-SIZE */
/* SETTINGS FOR FILL-IN loc_tog_name IN FRAME page-2
   NO-DISPLAY NO-ENABLE 2                                               */
/* SETTINGS FOR RADIO-SET loc_use-cassa IN FRAME page-2
   NO-DISPLAY NO-ENABLE 2 5                                             */
/* SETTINGS FOR FILL-IN loc_use-cassa_FILL-IN IN FRAME page-2
   NO-DISPLAY NO-ENABLE ALIGN-L 2                                       */
/* SETTINGS FOR RADIO-SET loc_use-obj IN FRAME page-2
   NO-DISPLAY NO-ENABLE 2 5                                             */
/* SETTINGS FOR FILL-IN r-FILL-IN IN FRAME page-2
   NO-DISPLAY NO-ENABLE ALIGN-L 2                                       */
/* SETTINGS FOR BUTTON r-gop IN FRAME page-2
   NO-ENABLE 2                                                          */
/* SETTINGS FOR BUTTON r-gop-2 IN FRAME page-2
   NO-ENABLE 2                                                          */
/* SETTINGS FOR BUTTON r-gop-calc IN FRAME page-2
   NO-ENABLE 2                                                          */
/* SETTINGS FOR FILL-IN r-obj-fill-in IN FRAME page-2
   ALIGN-L 2                                                            */
/* SETTINGS FOR BUTTON r-qnty-tog IN FRAME page-2
   2                                                                    */
/* SETTINGS FOR FILL-IN r-use-obj-fill-in IN FRAME page-2
   ALIGN-L 2                                                            */
/* SETTINGS FOR FILL-IN v-2 IN FRAME page-2
   NO-DISPLAY NO-ENABLE 2                                               */
ASSIGN
       v-2:HIDDEN IN FRAME page-2           = TRUE.

/* SETTINGS FOR EDITOR v-spis-kass IN FRAME page-2
   NO-DISPLAY NO-ENABLE 2                                               */
ASSIGN
       v-spis-kass:READ-ONLY IN FRAME page-2        = TRUE.

/* SETTINGS FOR FRAME page-3
   NOT-VISIBLE                                                          */
/* SETTINGS FOR FILL-IN F-ogran IN FRAME page-3
   NO-DISPLAY NO-ENABLE ALIGN-L 3                                       */
/* SETTINGS FOR TOGGLE-BOX loc_use-cash-pay IN FRAME page-3
   NO-DISPLAY NO-ENABLE 3 6                                             */
/* SETTINGS FOR TOGGLE-BOX loc_use-gds-group IN FRAME page-3
   NO-DISPLAY NO-ENABLE 3 6                                             */
/* SETTINGS FOR TOGGLE-BOX loc_use-pay-type IN FRAME page-3
   NO-DISPLAY NO-ENABLE 3 6                                             */
/* SETTINGS FOR FILL-IN v-3 IN FRAME page-3
   3                                                                    */
/* SETTINGS FOR EDITOR v-spis-group IN FRAME page-3
   NO-DISPLAY NO-ENABLE 3                                               */
ASSIGN
       v-spis-group:READ-ONLY IN FRAME page-3        = TRUE.

/* SETTINGS FOR EDITOR v-spis-type-pay IN FRAME page-3
   NO-DISPLAY NO-ENABLE 3                                               */
ASSIGN
       v-spis-type-pay:READ-ONLY IN FRAME page-3        = TRUE.

/* SETTINGS FOR EDITOR v-spis-use-cash-pay IN FRAME page-3
   NO-DISPLAY NO-ENABLE 3                                               */
ASSIGN
       v-spis-use-cash-pay:READ-ONLY IN FRAME page-3        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-tt
/* Query rebuild information for BROWSE BR-tt
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-avto-price.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-tt */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.price-list-type"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME page-1
/* Query rebuild information for FRAME page-1
     _Query            is NOT OPENED
*/  /* FRAME page-1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME page-2
/* Query rebuild information for FRAME page-2
     _Query            is NOT OPENED
*/  /* FRAME page-2 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME page-3
/* Query rebuild information for FRAME page-3
     _Query            is NOT OPENED
*/  /* FRAME page-3 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
    /*APPLY "GO":U TO  FRAME page-1 .
    APPLY "GO":U TO  FRAME page-2 .
    APPLY "GO":U TO  FRAME page-3 .*/
    RUN save-proc no-error .
    /* g t p l o b j   TODO */
    if error-status :error then do:
       case return-value :
          when "page-1" then do: APPLY "CHOOSE":U TO BUTTON-1 . return no-apply. end.
          when "page-2" then do: APPLY "CHOOSE":U TO BUTTON-2 . return no-apply. end.
          when "page-3" then do: APPLY "CHOOSE":U TO BUTTON-3 . return no-apply. end.
          otherwise do: return no-apply . end.
       end case.
    end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME page-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL page-1 Dialog-Frame
ON GO OF FRAME page-1
DO:
  MESSAGE "go page-1" VIEW-AS ALERT-BOX.
  ASSIGN FRAME PAGE-1 {&assign-1} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME page-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL page-2 Dialog-Frame
ON GO OF FRAME page-2
DO:
  MESSAGE "go page-2" VIEW-AS ALERT-BOX.
  ASSIGN FRAME PAGE-2 {&assign-2} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME page-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL page-3 Dialog-Frame
ON GO OF FRAME page-3
DO:
  MESSAGE "go page-3" VIEW-AS ALERT-BOX.
  ASSIGN FRAME PAGE-3 {&assign-3} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-ban-discnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-ban-discnt Dialog-Frame
ON CHOOSE OF b-ban-discnt IN FRAME Dialog-Frame
DO:
/*
define buffer buf_dis-rule for ub.dis-rule  .
find first buf_dis-rule no-lock where
            buf_dis-rule.templ-rl-root =  loc_ban-discnt
            no-error .
if error-status :error then return .
run ref/show-dr.p (parparentproc , loc_ban-discnt) no-error .
*/

define variable v-sts as integer no-undo init -1.
define variable v-rid-list as character no-undo .
run ref/dis-ruls.w (
                     input  parParentProc
                    ,input  v-cntxt-host-code-obj
                    ,input  v-cntxt-obj-type
                    ,input  v-cntxt-obj-code
                    ,input  "":U
                    ,input  "upper-rule-num":U
                    ,input  loc_ban-discnt
                    ,input -1
                    ,input 0
                    ,input-output v-sts
                    ,input-output v-rid-list ) no-error .



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME page-2
&Scoped-define SELF-NAME B-chga
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chga Dialog-Frame
ON CHOOSE OF B-chga IN FRAME page-2 /* Изменить */
DO:
if not available temp-avto-price then return .

case temp-avto-price.nn :
    when 1 then do:
    run ref/chavtp.w
        ( input-output  loc_ie-gen-marg
        , input-output  loc_ie-gen-marg-parts
        , input-output  loc_ie-objfirst
        , input-output  loc_ie-objsecond
        , input-output  loc_ie-pr-nakl
        , 'ie') .
    end.
    when 2 then do:
    run ref/chavtp.w
        ( input-output  loc_iv-gen-marg
        , input-output  loc_iv-gen-marg-parts
        , input-output  loc_iv-objfirst
        , input-output  loc_iv-objsecond
        , input-output  loc_iv-pr-nakl
        , 'iv') .
    end.
    when 3 then do:
    run ref/chavtp.w
        ( input-output  loc_im-gen-marg
        , input-output  loc_im-gen-marg-parts
        , input-output  loc_im-objfirst
        , input-output  loc_im-objsecond
        , input-output  loc_im-pr-nakl
        , 'im' ) .
    end.
end case.

run make-tt (
   loc_ie-gen-marg
  ,loc_ie-gen-marg-parts
  ,loc_ie-objfirst
  ,loc_ie-objsecond
  ,loc_ie-pr-nakl
  ,loc_iv-gen-marg
  ,loc_iv-gen-marg-parts
  ,loc_iv-objfirst
  ,loc_iv-objsecond
  ,loc_iv-pr-nakl
  ,loc_im-gen-marg
  ,loc_im-gen-marg-parts
  ,loc_im-objfirst
  ,loc_im-objsecond
  ,loc_im-pr-nakl
  ).

{&OPEN-QUERY-BR-tt}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-gop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-gop Dialog-Frame
ON CHOOSE OF b-gop IN FRAME page-2
DO:
 find first ub.grp-obj-price where
            ub.grp-obj-price.gop-db-num = loc_gop-db-num and
            ub.grp-obj-price.gop-id     = loc_gop-id
            no-lock no-error .
 if error-status :error then return .
 v-t-recid  = string(recid ( ub.grp-obj-price ))  .
 run ref/gr-objpr.w ( input parparentproc , input "" , input-output v-t-recid ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-gop-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-gop-2 Dialog-Frame
ON CHOOSE OF b-gop-2 IN FRAME page-2
DO:

  find first ub.buyer-group where
            ub.buyer-group.bgr-db-num = loc_bgr-db-num and
            ub.buyer-group.bgr-id     = loc_bgr-id
            no-lock no-error .
 if error-status :error then return .
 v-t-recid  = string(recid ( ub.buyer-group ))  .
 run ref/gr-bupr.w (input  parparentproc , "", input-output v-t-recid ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-gop-calc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-gop-calc Dialog-Frame
ON CHOOSE OF b-gop-calc IN FRAME page-2
DO:
 find first ub.grp-obj-price where
            ub.grp-obj-price.gop-db-num = loc_gop-db-num-for-calc-turnover and
            ub.grp-obj-price.gop-id     = loc_gop-id-for-calc-turnover
            no-lock no-error .
 if error-status :error then return .
 v-t-recid  = string(recid ( ub.grp-obj-price ))  .
 run ref/gr-objpr.w ( input parparentproc , input "" , input-output v-t-recid ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME page-1
&Scoped-define SELF-NAME b-have-tog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-have-tog Dialog-Frame
ON CHOOSE OF b-have-tog IN FRAME page-1
DO:

 find first ub.turnover-group where
            ub.turnover-group.tog-db-num = loc_have-tog-db-num   and
            ub.turnover-group.tog-id     = loc_have-tog-id
            no-lock no-error .
 if error-status :error then return .
 v-t-recid  = string(recid ( ub.turnover-group ))  .
 run ref/gr-obupr.w (input  parparentproc ,"" , input-output v-t-recid ).


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-qnty-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-qnty-grp Dialog-Frame
ON CHOOSE OF b-qnty-grp IN FRAME page-1
DO:
 find first ub.qnty-group where
            ub.qnty-group.qgr-db-num = loc_qgr-db-num  and
            ub.qnty-group.qgr-id     = loc_qgr-id
            no-lock no-error .
 if error-status :error then return .
 v-t-recid  = string(recid ( ub.qnty-group ))  .
 run ref/gr-qupr.w (input  parparentproc ,"" ,  input-output v-t-recid ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-qnty-sgr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-qnty-sgr Dialog-Frame
ON CHOOSE OF b-qnty-sgr IN FRAME page-1
DO:
 find first ub.sum-group where
            ub.sum-group.sgr-db-num = loc_sgr-db-num   and
            ub.sum-group.sgr-id     = loc_sgr-id
            no-lock no-error .
 if error-status :error then return .
 v-t-recid  = string(recid ( ub.sum-group ))  .
run ref/gr-supr.w (input  parparentproc , "" ,  input-output v-t-recid ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME page-2
&Scoped-define SELF-NAME b-qnty-tog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-qnty-tog Dialog-Frame
ON CHOOSE OF b-qnty-tog IN FRAME page-2
DO:
 find first ub.turnover-group where
            ub.turnover-group.tog-db-num = loc_tog-db-num  and
            ub.turnover-group.tog-id     = loc_tog-id
            no-lock no-error .
 if error-status :error then return .
 v-t-recid  = string(recid ( ub.turnover-group ))  .
 run ref/gr-obupr.w (input  parparentproc ,"" , input-output v-t-recid ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define SELF-NAME BUTTON-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-1 Dialog-Frame
ON CHOOSE OF BUTTON-1 IN FRAME Dialog-Frame /* Расширение */
DO:
  button-1:LOAD-IMAGE-Up("adeicon\ts-up":U)        in frame {&frame-name} .
  button-2:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame {&frame-name} .
  button-3:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame {&frame-name} .
  label-button-1:fgcolor in frame {&frame-name}  = 1   .
  label-button-2:fgcolor in frame {&frame-name}  = ?   .
  label-button-3:fgcolor in frame {&frame-name}  = ?   .
  VIEW FRAME page-1.
  HIDE v-2 IN FRAME page-2 .
  HIDE {&list-2} IN FRAME page-2 .
  HIDE v-3 IN FRAME page-3 .
  HIDE {&list-3} IN FRAME page-3 .
  HIDE FRAME page-2.
  HIDE FRAME page-3.
  DISPLAY {&list-1} WITH FRAME page-1 .
  RUN my_enable.
  APPLY "ENTRY":U TO v-1 IN FRAME page-1 .
  HIDE v-1 IN FRAME  PAGE-1.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-2 Dialog-Frame
ON CHOOSE OF BUTTON-2 IN FRAME Dialog-Frame /* Butt */
DO:
  ASSIGN FRAME page-1 {&assign-1}.
  ASSIGN FRAME page-3 {&assign-3}.
  button-2:LOAD-IMAGE-Up("adeicon\ts-up":U)      in frame {&frame-name} .
  button-1:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame {&frame-name} .
  button-3:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame {&frame-name} .
  label-button-2:fgcolor = 1   .
  label-button-1:fgcolor = ?   .
  label-button-3:fgcolor = ?   .

  HIDE {&list-1} IN FRAME page-1 .
  HIDE {&list-3} IN FRAME page-3 .
  HIDE FRAME page-1.
  HIDE FRAME page-3.

  VIEW FRAME page-2.
  DISPLAY {&list-2} WITH FRAME page-2.
  ENABLE {&list-2} WITH FRAME page-2.
  RUN my_enable .
  if p-mode = {&add-def} then do:
    run mode_add-init.
  end.
  APPLY  "ENTRY":U TO v-2 IN FRAME page-2 .
  HIDE v-2 IN FRAME  PAGE-2.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-3 Dialog-Frame
ON CHOOSE OF BUTTON-3 IN FRAME Dialog-Frame /* Butt */
DO:
ASSIGN FRAME page-1 {&assign-1}.
ASSIGN FRAME page-2 {&assign-2} no-error .

  button-3:LOAD-IMAGE-Up("adeicon\ts-up":U)        in frame {&frame-name} .
  button-2:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame {&frame-name} .
  button-1:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame {&frame-name} .
  label-button-3:fgcolor = 1   .
  label-button-2:fgcolor = ?   .
  label-button-1:fgcolor = ?   .

  HIDE {&list-1} IN FRAME page-1 .
  HIDE {&list-2} IN FRAME page-2 .
  HIDE FRAME page-1.
  HIDE FRAME page-2.

  VIEW FRAME page-3.
  DISPLAY {&list-3} WITH FRAME page-3.
  ENABLE {&list-3} WITH FRAME page-3.
  RUN my_enable.
  APPLY  "ENTRY":U TO v-3 IN FRAME page-3 .
  HIDE v-3 IN FRAME  PAGE-3.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-ban-discnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-ban-discnt Dialog-Frame
ON VALUE-CHANGED OF l-ban-discnt IN FRAME Dialog-Frame /* Шаблон скидки */
DO:
  assign l-ban-discnt.
  run tog-band .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_calc-round-method
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_calc-round-method Dialog-Frame
ON VALUE-CHANGED OF loc_calc-round-method IN FRAME Dialog-Frame /* Метод округления по умолчанию */
DO:
  if lookup( input frame {&frame-name} loc_calc-round-method, {&pr-rounds-need-coef} ) > 0 then do:
     enable loc_calc-round-base with frame {&frame-name}.
  end.
  ELSE hide loc_calc-round-base in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_curr-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_curr-code Dialog-Frame
ON LEAVE OF loc_curr-code IN FRAME Dialog-Frame /* Валюта */
DO:
  assign loc_curr-code .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME page-1
&Scoped-define SELF-NAME loc_have-rs-qnty-group
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_have-rs-qnty-group Dialog-Frame
ON VALUE-CHANGED OF loc_have-rs-qnty-group IN FRAME page-1 /* Есть связь с количественной группой */
DO:
  ASSIGN  loc_have-rs-qnty-group.
  IF loc_have-rs-qnty-group = TRUE THEN DO:
      assign
        loc_have-rs-sum-group  = false
        loc_have-rs-turn-group = false
        loc_have-rs-qnty-group = true
      .
      display loc_have-rs-sum-group when loc_have-rs-sum-group:visible
              loc_have-rs-turn-group  when     loc_have-rs-turn-group:visible
              loc_have-rs-qnty-group  when     loc_have-rs-qnty-group:visible
              WITH FRAME  {&FRAME-NAME}  .


      APPLY "CHOOSE":U TO r-qnty-grp.
      ENABLE r-qnty-grp WITH FRAME  {&FRAME-NAME}  .
  END.
  ELSE DO:
      ASSIGN loc_qgr-id = 0
             loc_qgr-db-num = 0
             loc_qg_name = ""
          .
      DISABLE r-qnty-grp WITH FRAME {&FRAME-NAME} .
      IF loc_have-rs-qnty-group:VISIBLE  THEN
          DISPLAY
             loc_qgr-id
             loc_qgr-db-num
             loc_qg_name
          WITH FRAME {&FRAME-NAME} .
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_have-rs-sum-group
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_have-rs-sum-group Dialog-Frame
ON VALUE-CHANGED OF loc_have-rs-sum-group IN FRAME page-1 /* Есть связь с суммовой группой */
DO:
    ASSIGN  loc_have-rs-sum-group.
  IF loc_have-rs-sum-group = TRUE THEN DO:
      assign
        loc_have-rs-sum-group  = true
        loc_have-rs-turn-group = false
        loc_have-rs-qnty-group = false
      .
      display loc_have-rs-sum-group when loc_have-rs-sum-group:visible
              loc_have-rs-turn-group  when     loc_have-rs-turn-group:visible
              loc_have-rs-qnty-group  when     loc_have-rs-qnty-group:visible
              WITH FRAME  {&FRAME-NAME}  .

      APPLY "CHOOSE":U TO r-qnty-sgr.
      ENABLE r-qnty-sgr WITH FRAME {&FRAME-NAME} .
  END.
  ELSE DO:
      ASSIGN loc_sgr-id = 0
             loc_sgr-db-num = 0
             loc_sg_name = ""
          .
      DISABLE r-qnty-sgr WITH FRAME {&FRAME-NAME} .
      IF loc_have-rs-sum-group:VISIBLE  THEN
          DISPLAY
             loc_sgr-id
             loc_sgr-db-num
             loc_sg_name
          WITH FRAME {&FRAME-NAME} .

  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_have-rs-turn-group
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_have-rs-turn-group Dialog-Frame
ON VALUE-CHANGED OF loc_have-rs-turn-group IN FRAME page-1 /* Есть связь с группой по оборотам */
DO:
    ASSIGN  loc_have-rs-turn-group.
  IF loc_have-rs-turn-group = TRUE THEN DO:
      assign
        loc_have-rs-sum-group  = false
        loc_have-rs-qnty-group = false
      .
      display loc_have-rs-sum-group   when loc_have-rs-sum-group:visible
              loc_have-rs-turn-group  when loc_have-rs-turn-group:visible
              loc_have-rs-qnty-group  when loc_have-rs-qnty-group:visible
              WITH FRAME  {&FRAME-NAME}  .

      APPLY "CHOOSE":U TO r-have-tog.
      ENABLE r-have-tog WITH FRAME {&FRAME-NAME} .
  END.
  ELSE DO:
      ASSIGN loc_have-tog-id = 0
             loc_have-tog-db-num = 0
             loc_have-tog_name = ""
          .
      DISABLE r-qnty-sgr WITH FRAME {&FRAME-NAME} .
      IF loc_have-rs-sum-group:VISIBLE  THEN
          DISPLAY
             loc_have-tog-id
             loc_have-tog-db-num
             loc_have-tog_name
          WITH FRAME {&FRAME-NAME} .

  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define SELF-NAME loc_name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_name Dialog-Frame
ON LEAVE OF loc_name IN FRAME Dialog-Frame /* Тип прайс-листа */
DO:
  ASSIGN loc_name .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME page-2
&Scoped-define SELF-NAME loc_obj-turnover
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_obj-turnover Dialog-Frame
ON VALUE-CHANGED OF loc_obj-turnover IN FRAME page-2
DO:
  ASSIGN  loc_obj-turnover  .
  case  loc_obj-turnover  :
    when yes then do:
      if loc_obj-turnover:visible then
      enable r-gop-calc with frame {&frame-name} .
      apply "choose" to r-gop-calc .
    end.

    when no then do:
      disable r-gop-calc with frame {&frame-name} .
    end.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define SELF-NAME loc_only-gbd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_only-gbd Dialog-Frame
ON VALUE-CHANGED OF loc_only-gbd IN FRAME Dialog-Frame /* Для автопереоценок */
DO:
  ASSIGN loc_only-gbd.
  run runav.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME page-2
&Scoped-define SELF-NAME loc_rs-buyer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_rs-buyer Dialog-Frame
ON VALUE-CHANGED OF loc_rs-buyer IN FRAME page-2
DO:
  ASSIGN loc_rs-buyer .
  case loc_rs-buyer :
  when 0 then do:
     assign
      loc_bgr-id = 0
      loc_bgr-db-num = 0
      loc_bgr_name = ""
     .
     disable r-gop-2 with frame {&frame-name} .
     assign
      loc_tog-id = 0
      loc_tog-db-num = 0
      loc_tog_name = ""
     .
     disable r-qnty-tog  loc_obj-turnover  r-gop-calc with frame {&frame-name} .
     if loc_tog-id:visible   then display
     loc_tog-id
     loc_tog-db-num
     loc_tog_name
     with frame {&frame-name} .
     if loc_bgr-id:visible   then display
     loc_bgr-id
     loc_bgr-db-num
     loc_bgr_name
     with frame {&frame-name} .


  end.
  when 1 then do:  /* группа */
     APPLY "CHOOSE":U TO r-gop-2.
     enable r-gop-2 with frame {&frame-name} .
     assign
      loc_tog-id = 0
      loc_tog-db-num = 0
      loc_tog_name = ""
     .
     disable r-qnty-tog loc_obj-turnover  r-gop-calc with frame {&frame-name} .
     if loc_tog-id:visible   then display
     loc_tog-id
     loc_tog-db-num
     loc_tog_name
     with frame {&frame-name} .

  end.
  when 2 then do:  /* оборот */
     APPLY "CHOOSE":U TO r-qnty-tog.
     enable r-qnty-tog with frame {&frame-name} .
     assign
      loc_bgr-id = 0
      loc_bgr-db-num = 0
      loc_bgr_name = ""
     .
     disable r-gop-2 with frame {&frame-name} .
     if loc_bgr-id:visible   then display
     loc_bgr-id
     loc_bgr-db-num
     loc_bgr_name
     with frame {&frame-name} .

     enable loc_obj-turnover  with frame {&frame-name} .
  end.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define SELF-NAME loc_under-type-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_under-type-list Dialog-Frame
ON VALUE-CHANGED OF loc_under-type-list IN FRAME Dialog-Frame /* Пoдчиненный ПЛ */
DO:
  assign  loc_under-type-list.

  if loc_under-type-list = true then do:
      apply "choose":u to r-rod-price-type in frame {&frame-name} .
      enable r-rod-price-type
             loc_under-hand-corr
             with frame {&frame-name} .

      display
          loc_plt-main-id
          loc_plt-main-db-num
          loc_rod-pt-name
      with frame {&frame-name} .
  end.
  else do:
      assign loc_plt-main-id = 0
             loc_plt-main-db-num = 0
             loc_rod-pt-name = ""
             loc_under-hand-corr = no
      .
      hide r-rod-price-type
           loc_under-hand-corr
           loc_plt-main-id
           loc_plt-main-db-num
           loc_rod-pt-name
           in frame {&frame-name} .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME page-3
&Scoped-define SELF-NAME loc_use-cash-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_use-cash-pay Dialog-Frame
ON VALUE-CHANGED OF loc_use-cash-pay IN FRAME page-3 /* по типам кассовых платежей */
DO:

define variable p-rid-list   as character no-undo .
define variable ii           as integer   no-undo .
define variable v-name       as character no-undo .
define buffer   buf_cash-pay for ub.cash-pay  .

for each TT_price-list-type-cash-pay : delete TT_price-list-type-cash-pay . end.
v-spis-use-cash-pay = "".

  ASSIGN loc_use-cash-pay.
  IF loc_use-cash-pay = true  THEN DO:
      DISPLAY v-spis-use-cash-pay WITH FRAME {&FRAME-NAME}.
      ENABLE v-spis-use-cash-pay WITH FRAME {&FRAME-NAME}.
      run ref/cashpays.w (
           input parparentproc
          ,input "b-sel,b-mark"
          ,input {&all}
          ,input v-cntxt-host-code-obj
          ,input v-cntxt-obj-type
          ,input v-cntxt-obj-code
          ,output p-rid-list ) .

          if p-rid-list = "" or p-rid-list = ? then do:
             loc_use-cash-pay = false .
             display loc_use-cash-pay with frame {&frame-name} .
             return.
          end.

          v-nn = num-entries(p-rid-list) .
          repeat ii = 1 to  v-nn :
            find first buf_cash-pay no-lock where  recid(buf_cash-pay) = integer (entry( ii , p-rid-list )) no-error .
            if available buf_cash-pay then do:
               create TT_price-list-type-cash-pay.
               assign
                 TT_price-list-type-cash-pay.cdpay-code    = buf_cash-pay.cdpay-code
                 TT_price-list-type-cash-pay.curr-code     = buf_cash-pay.curr-code
                 TT_price-list-type-cash-pay.plt-db-num    = -1
                 TT_price-list-type-cash-pay.plt-id        = -1
                 v-spis-use-cash-pay = v-spis-use-cash-pay + buf_cash-pay.obj-name  + {&NEW-LINE}
               .
            end.
          end.
          DISPLAY v-spis-use-cash-pay WITH FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
      HIDE v-spis-use-cash-pay IN FRAME {&FRAME-NAME}.
  END.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME page-2
&Scoped-define SELF-NAME loc_use-cassa
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_use-cassa Dialog-Frame
ON VALUE-CHANGED OF loc_use-cassa IN FRAME page-2
DO:
define variable p-rid-list as character no-undo .
define variable ii         as integer   no-undo .
define buffer   buf_cash-desk for ub.cash-desk  .

for each TT_price-list-type-cassa : delete TT_price-list-type-cassa . end.
v-spis-kass = "".

  ASSIGN loc_use-cassa.
  IF loc_use-cassa = 3 THEN DO:
      DISPLAY v-spis-kass WITH FRAME {&FRAME-NAME}.
      ENABLE v-spis-kass WITH FRAME {&FRAME-NAME}.
      run ref/cashlist.w (
          parparentproc
          ,"b-sel,b-mark"
          ,{&all}
          , v-cntxt-db-num
          ,v-cntxt-host-code-obj
          ,v-cntxt-obj-type
          ,v-cntxt-obj-code
          ,?
          ,OUTPUT p-rid-list ) .

          if p-rid-list = "" or p-rid-list = ? then do:
             loc_use-cassa = 1.
             display loc_use-cassa with frame {&frame-name} .
             return.
          end.
          v-nn = num-entries(p-rid-list).
          repeat ii = 1 to  v-nn :
            find first buf_cash-desk no-lock where  recid(buf_cash-desk) = integer (entry( ii , p-rid-list )) no-error .
            if available buf_cash-desk then do:
               create TT_price-list-type-cassa.
               assign
                 TT_price-list-type-cassa.cash-num     = buf_cash-desk.cash-num
                 TT_price-list-type-cassa.db-num       = buf_cash-desk.db-num
                 TT_price-list-type-cassa.obj-code     = buf_cash-desk.obj-code
                 TT_price-list-type-cassa.plt-db-num   = -1
                 TT_price-list-type-cassa.plt-id       = -1
                 TT_price-list-type-cassa.pos-type     = buf_cash-desk.pos-type
               .

               v-spis-kass = v-spis-kass +
               "БД:"  + string(buf_cash-desk.db-num) +
               " маг" + string(buf_cash-desk.obj-code) +
               " №"   + string (buf_cash-desk.cash-num) +
               " "    +  buf_cash-desk.pos-type
                + {&NEW-LINE} .
            end.
          end.
          DISPLAY v-spis-kass WITH FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
      HIDE v-spis-kass IN FRAME {&FRAME-NAME}.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME page-3
&Scoped-define SELF-NAME loc_use-gds-group
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_use-gds-group Dialog-Frame
ON VALUE-CHANGED OF loc_use-gds-group IN FRAME page-3 /* по группам товаров */
DO:

define variable p-rid-list  as character no-undo .
define variable ii          as integer   no-undo .
define variable v-name      as character no-undo .
define buffer   buf_gds-grp for ub.gds-grp  .

for each TT_price-list-type-gds-grp : delete TT_price-list-type-gds-grp . end.
v-spis-group = "".

  ASSIGN loc_use-gds-group.
  IF loc_use-gds-group = true  THEN DO:
      DISPLAY v-spis-group WITH FRAME {&FRAME-NAME}.
      ENABLE v-spis-group WITH FRAME {&FRAME-NAME}.
      run ref/gds-grp.w (
          parparentproc
          ,"b-sel,b-mark"
          ,v-cntxt-obj-type
          ,v-cntxt-obj-code
          ,input-output p-rid-list ) .

          if p-rid-list = "" or p-rid-list = ? then do:
             loc_use-gds-group = false .
             display loc_use-gds-group with frame {&frame-name} .
             return.
          end.
          v-nn = num-entries(p-rid-list) .
          repeat ii = 1 to  v-nn :
            find first buf_gds-grp no-lock where  recid(buf_gds-grp) = integer (entry( ii , p-rid-list )) no-error .
            if available buf_gds-grp then do:
               create TT_price-list-type-gds-grp.
               assign
                 TT_price-list-type-gds-grp.node-code    = buf_gds-grp.node-code
                 TT_price-list-type-gds-grp.plt-db-num   = -1
                 TT_price-list-type-gds-grp.plt-id       = -1
               .

               { gbl/grpgdsnm.i buf_gds-grp.node-code v-name}
               v-spis-group = v-spis-group + v-name + {&NEW-LINE} .
            end.
          end.
          DISPLAY v-spis-group WITH FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
      HIDE v-spis-group IN FRAME {&FRAME-NAME}.
  END.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME page-2
&Scoped-define SELF-NAME loc_use-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_use-obj Dialog-Frame
ON VALUE-CHANGED OF loc_use-obj IN FRAME page-2
DO:
  define variable g#log as logical no-undo .
  ASSIGN loc_use-obj .
  if loc_use-obj = 1 then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_documents_all':U
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      g#log
    }
    if not g#log then do:
      if error-status :error then do:
        loc_use-obj = 2.
        display loc_use-obj with frame {&frame-name}.
        return.
      end.
    end.
  end.
  case loc_use-obj :
    when 1 then do:
    disable r-gop with frame {&frame-name} .
    end.
    when 2 then do:
      if loc_use-obj:visible then
      enable r-gop with frame {&frame-name} .
      apply "choose":u to r-gop in frame {&frame-name} .
    end.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME page-3
&Scoped-define SELF-NAME loc_use-pay-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_use-pay-type Dialog-Frame
ON VALUE-CHANGED OF loc_use-pay-type IN FRAME page-3 /* по типам платежа */
DO:

define variable p-rid-list   as character no-undo .
define variable ii           as integer   no-undo .
define variable v-name       as character no-undo .
define buffer   buf_pay-type for ub.pay-type  .

for each TT_price-list-type-pay-type : delete TT_price-list-type-pay-type . end.
v-spis-type-pay = "" .

  ASSIGN loc_use-pay-type .

  IF loc_use-pay-type = true  THEN DO:
      DISPLAY v-spis-type-pay WITH FRAME {&FRAME-NAME}.
      ENABLE  v-spis-type-pay WITH FRAME {&FRAME-NAME}.
      run ref/paytype.w (
            parparentproc
          , "b-sel,b-mark"
          , output p-rid-list ) .
          if p-rid-list = "" or p-rid-list = ? then do:
             loc_use-pay-type = false .
             display loc_use-pay-type with frame {&frame-name} .
             return.
          end.
          v-nn = num-entries(p-rid-list) .
          repeat ii = 1 to v-nn :
            find first buf_pay-type no-lock where  recid(buf_pay-type) = integer (entry( ii , p-rid-list )) no-error .
            if available buf_pay-type then do:
               create TT_price-list-type-pay-type.
               assign
                 TT_price-list-type-pay-type.pay-code     = buf_pay-type.obj-code
                 TT_price-list-type-pay-type.plt-db-num   = -1
                 TT_price-list-type-pay-type.plt-id       = -1
               .
                 v-spis-type-pay = v-spis-type-pay + buf_pay-type.obj-name + {&NEW-LINE} .
            end.
          end.
          DISPLAY v-spis-type-pay WITH FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
      HIDE v-spis-type-pay IN FRAME {&FRAME-NAME}.
  END.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define SELF-NAME r-ban-discnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-ban-discnt Dialog-Frame
ON CHOOSE OF r-ban-discnt IN FRAME Dialog-Frame
DO:

define variable v-sts as integer no-undo init 0.
define variable v-rid-list as character no-undo .

define buffer buf_dis-rule for ub.dis-rule.

    run ref/dis-ruls.w
      ( input parparentproc
      , input v-cntxt-host-code-obj
      , input v-cntxt-obj-type
      , input v-cntxt-obj-code
      , input "b-sel"
      , input ("template-value-type=" +  {&discnt-v-pdf-abs} + {&comma-char} + {&discnt-v-pdf-pcnt} + {&comma-char} + {&discnt-v-pdf-FP}  )
      , input 0 /*p-uppre-rule-num*/
      , input ? /*p-time-templ-rlr-oot*/
      , input 0 /*b-code*/
      , input-output v-sts
      , input-output v-rid-list)
      no-error .

find first buf_dis-rule no-lock where
     recid (buf_dis-rule) = integer (v-rid-list)
     no-error.

    if error-status :error  then do:
     assign
      loc_ban-discnt = 0
      f-ban-discnt   = ""
      l-ban-discnt   = false
      .
    end.
    else do:
      assign
        loc_ban-discnt = buf_dis-rule.templ-rl-root
        f-ban-discnt   = buf_dis-rule.des
        l-ban-discnt   = true
        .
    end.

    display
      loc_ban-discnt
      f-ban-discnt
      l-ban-discnt
      with frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-cur
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-cur Dialog-Frame
ON CHOOSE OF r-cur IN FRAME Dialog-Frame
DO:

define variable ref-rec        as recid     no-undo .
define variable loc_exch-rate  as decimal   no-undo .
define variable loc_exch-scale as decimal   no-undo .

run ref/currency.w (input  parparentproc , "b-sel", input-output ref-rec ).
if ref-rec = ? then return no-apply.
find ub.currency where recid ( ub.currency ) = ref-rec no-lock.
  assign
    loc_curr-code  = ub.currency.curr-code
    loc_abbr-doc   = ub.currency.curr-abbr
  .

{ gbl/exchrate.i
  loc_curr-code
  TODAY
  loc_exch-rate
  loc_exch-scale
  loc_abbr-doc }

display
  loc_curr-code
  loc_abbr-doc
  with frame {&frame-name} .
assign frame {&frame-name}
  loc_curr-code
  loc_abbr-doc

.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME page-2
&Scoped-define SELF-NAME r-gop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-gop Dialog-Frame
ON CHOOSE OF r-gop IN FRAME page-2
DO:
define variable ref-rec   as recid     no-undo .
define variable s-ref-rec as character no-undo .

run ref/gr-objpr.w ( input parparentproc , input "b-sel" , input-output s-ref-rec ) .
ref-rec = int(s-ref-rec).

if ref-rec = ? or ref-rec = 0 then return no-apply.

find ub.grp-obj-price where recid ( ub.grp-obj-price ) = ref-rec no-lock no-error .
if error-status :error then do:
  return no-apply .
end.

assign
  loc_gop_name-name = ub.grp-obj-price.name
  loc_gop-db-num    = ub.grp-obj-price.gop-db-num
  loc_gop-id        = ub.grp-obj-price.gop-id
.

display
 loc_gop_name-name
 loc_gop-db-num
 loc_gop-id
 with frame {&frame-name} .
run vis-bin.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-gop-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-gop-2 Dialog-Frame
ON CHOOSE OF r-gop-2 IN FRAME page-2
DO:

define variable ref-rec   as recid     no-undo .
define variable s-ref-rec as character no-undo .

run ref/gr-bupr.w (input  parparentproc , "b-sel", input-output s-ref-rec ).
ref-rec = int(s-ref-rec) .
if ref-rec = ? or ref-rec = 0  then return no-apply.
find ub.buyer-group where recid ( ub.buyer-group ) = ref-rec no-lock no-error .
if error-status :error then do:
  return no-apply .
end.

assign
  loc_bgr_name   = ub.buyer-group.name
  loc_bgr-db-num = ub.buyer-group.bgr-db-num
  loc_bgr-id     = ub.buyer-group.bgr-id
.

display
 loc_bgr_name
 loc_bgr-db-num
 loc_bgr-id
 with frame {&frame-name}
 .
run vis-bin.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-gop-calc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-gop-calc Dialog-Frame
ON CHOOSE OF r-gop-calc IN FRAME page-2
DO:

define variable ref-rec   as recid     no-undo .
define variable s-ref-rec as character no-undo .

run ref/gr-objpr.w (input  parparentproc , "b-sel" , input-output s-ref-rec ).
ref-rec = int (s-ref-rec).
if ref-rec = ? then return no-apply.

FIND ub.grp-obj-price where recid ( ub.grp-obj-price ) = ref-rec no-lock no-error .
if error-status :error then  do:
return no-apply .
end.

assign
  loc_gop_name-tnv                 = ub.grp-obj-price.name
  loc_gop-db-num-for-calc-turnover = ub.grp-obj-price.gop-db-num
  loc_gop-id-for-calc-turnover     = ub.grp-obj-price.gop-id
.

display
 loc_gop_name-tnv
 loc_gop-db-num-for-calc-turnover
 loc_gop-id-for-calc-turnover
 with frame {&frame-name} .
run vis-bin.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME page-1
&Scoped-define SELF-NAME r-have-tog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-have-tog Dialog-Frame
ON CHOOSE OF r-have-tog IN FRAME page-1
DO:

define variable ref-rec   as recid     no-undo .
define variable s-ref-rec as character no-undo .

run ref/gr-obupr.w (input  parparentproc ,"b-sel" , input-output s-ref-rec ).
ref-rec = int(s-ref-rec).

if ref-rec = ?  or ref-rec = 0  then return no-apply.
find ub.turnover-group where recid ( ub.turnover-group ) = ref-rec no-lock no-error .
if error-status :error then do:
   return no-apply .
end.

assign
  loc_have-tog_name    = ub.turnover-group.name
  loc_have-tog-db-num  = ub.turnover-group.tog-db-num
  loc_have-tog-id      = ub.turnover-group.tog-id
.

display
 loc_have-tog_name
 loc_have-tog-db-num
 loc_have-tog-id
 with frame {&frame-name} .
run vis-bin.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-qnty-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-qnty-grp Dialog-Frame
ON CHOOSE OF r-qnty-grp IN FRAME page-1
DO:
define variable v-t     as character no-undo .
define variable ref-rec as recid     no-undo .

run ref/gr-qupr.w (input  parparentproc ,"b-sel" ,  input-output v-t  ).
ref-rec = int (v-t) .
if ref-rec = ? or ref-rec = 0  then do:
   return no-apply.
end.
find ub.qnty-group where recid ( ub.qnty-group ) = ref-rec no-lock no-error .
if not available ub.qnty-group then return no-apply.
assign
  loc_qg_name    = ub.qnty-group.name
  loc_qgr-db-num = ub.qnty-group.qgr-db-num
  loc_qgr-id     = ub.qnty-group.qgr-id
.

display
 loc_qg_name
 loc_qgr-db-num
 loc_qgr-id
 with frame {&frame-name} .
 run vis-bin.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-qnty-sgr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-qnty-sgr Dialog-Frame
ON CHOOSE OF r-qnty-sgr IN FRAME page-1
DO:

define variable ref-rec   as recid     no-undo .
define variable s-ref-rec as character no-undo .

run ref/gr-supr.w (input  parparentproc , "b-sel" ,  input-output s-ref-rec ).
ref-rec = int(s-ref-rec) .
if ref-rec = ? or ref-rec = 0  then return no-apply.
find ub.sum-group where recid ( ub.sum-group ) = ref-rec no-lock no-error .
if error-status :error then do:
return no-apply .
end.

assign
  loc_sg_name    = ub.sum-group.name
  loc_sgr-db-num = ub.sum-group.sgr-db-num
  loc_sgr-id     = ub.sum-group.sgr-id
.

display
 loc_sg_name
 loc_sgr-db-num
 loc_sgr-id
 with frame {&frame-name} .
run vis-bin.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME page-2
&Scoped-define SELF-NAME r-qnty-tog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-qnty-tog Dialog-Frame
ON CHOOSE OF r-qnty-tog IN FRAME page-2
DO:

define variable ref-rec   as recid     no-undo .
define variable s-ref-rec as character no-undo .

run ref/gr-obupr.w (input  parparentproc ,"b-sel" , input-output s-ref-rec ).
ref-rec = int(s-ref-rec) .

if ref-rec = ?  or ref-rec = 0  then return no-apply.
find ub.turnover-group where recid ( ub.turnover-group ) = ref-rec no-lock no-error .
if error-status :error then do:
return no-apply .
end.
assign
  loc_tog_name   = ub.turnover-group.name
  loc_tog-db-num = ub.turnover-group.tog-db-num
  loc_tog-id     = ub.turnover-group.tog-id
.
display
 loc_tog_name
 loc_tog-db-num
 loc_tog-id
 with frame {&frame-name} .
run vis-bin.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define SELF-NAME r-rod-price-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-rod-price-type Dialog-Frame
ON CHOOSE OF r-rod-price-type IN FRAME Dialog-Frame
DO:

define variable ref-rec   as recid     no-undo .
define variable v-ref-rec as character no-undo .

define buffer buff_price-list-type for ub.price-list-type  .
run ref/typepric.w ( input  parparentproc , "b-sel" ,  input-output v-ref-rec ) .
 ref-rec = integer (v-ref-rec) .

if ref-rec = ?  or ref-rec = 0  then return no-apply.
FIND buff_price-list-type where recid ( buff_price-list-type ) = ref-rec no-lock no-error .
if error-status :error then do:
return no-apply .
end.


/* ПОДЧИНЕННЫЕ ПЛ */
define buffer parent_price-list-type for ub.price-list-type  .

if p-main-price = true  then do:
    /* тип родительского должен быть главным  */
    find first parent_price-list-type  no-lock where
               parent_price-list-type.plt-id     = buff_price-list-type.plt-id  and
               parent_price-list-type.plt-db-num = buff_price-list-type.plt-db-num no-error .
    if not available parent_price-list-type then do:
       message  "Родительский прайс-лист не найден !" view-as alert-box information .
       return no-apply .
    end.
    if parent_price-list-type.stts <> integer({&pdf-new}) then do:
       message  "Родительский прайс-лист удален !" view-as alert-box information  .
       return no-apply .
    end.
    if parent_price-list-type.main = false  then do:
     message  "Родительский прайс-лист должен быть ГЛАВНЫМ !" view-as alert-box information  .
     return no-apply .
     end.
    if parent_price-list-type.under-type-list <> 0  then do:
     message  "Родительский прайс-лист не должен быть подчиненным !" view-as alert-box information  .
     return no-apply .
     end.

end.

if p-main-price = false   then do:
    /* тип родительского должен быть не главным  */
    find first parent_price-list-type  no-lock where
               parent_price-list-type.plt-id     = buff_price-list-type.plt-id  and
               parent_price-list-type.plt-db-num = buff_price-list-type.plt-db-num no-error .
    if not available parent_price-list-type then  do:
       message "Родительский прайс-лист не найден !" view-as alert-box information .
       return no-apply .
    end.
    if parent_price-list-type.stts <> integer({&pdf-new}) then do:
       message  "Родительский прайс-лист удален !"  view-as alert-box information .
       return no-apply .
    end.
/*    if parent_price-list-type.main = true   then do:*/
/*       message  "Родительский прайс-лист не должен быть главным !" view-as alert-box information .*/
/*       return no-apply .*/
/*    end.*/
    if parent_price-list-type.under-type-list <> 0  then do:
     message  "Родительский прайс-лист не должен быть подчиненным !" view-as alert-box information  .
     return no-apply .
     end.
end.

assign
  loc_rod-pt-name     = buff_price-list-type.name
  loc_plt-main-db-num = buff_price-list-type.plt-db-num
  loc_plt-main-id     = buff_price-list-type.plt-id
  loc_priority        = buff_price-list-type.priority
.

display
 loc_rod-pt-name
 loc_plt-main-db-num
 loc_plt-main-id
 loc_priority WHEN loc_priority <> 0
 with frame {&frame-name} .

run enable1 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-tt
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
define variable g#log as logical   no-undo .
if p-mode = {&lookup} then do:
   if p-main-price then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_global-tpl-mpl_lookup':U
        {&cntxt-global}
        v-cntxt-host-code-obj
        v-cntxt-obj-type
        v-cntxt-obj-code
        0
        0
        0
        true
        g#log
      }
   end.
   else do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_tpl-mpl_lookup':U
        {&cntxt-global}
        v-cntxt-host-code-obj
        v-cntxt-obj-type
        v-cntxt-obj-code
        0
        0
        0
        true
        g#log
      }
   end.
end.
else do:
   if p-main-price then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_global-tpl-mpl_update':U
        {&cntxt-global}
        v-cntxt-host-code-obj
        v-cntxt-obj-type
        v-cntxt-obj-code
        0
        0
        0
        true
        g#log
      }
   end.
   else do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_tpl-mpl_update':U
        {&cntxt-global}
        v-cntxt-host-code-obj
        v-cntxt-obj-type
        v-cntxt-obj-code
        0
        0
        0
        true
        g#log
      }
   end.

end.
if not g#log then return .

  ASSIGN
      frame {&frame-name}:TITLE = "Описание типа прайс-листа  -- " + caps(p-mode)
      label-button-1 = "Привязка"
      label-button-2 = "Распространение"
      label-button-3 = "Ограничения"
      v-spis-kass:READ-ONLY = TRUE
      .
  if p-main-price  then do:
      frame {&frame-name}:TITLE = "Описание ГЛАВНОГО типа прайс-листа  -- " + caps(p-mode) .
  end.

  SELECT MAX( ub.price-list-type.priority ) INTO v-max FROM ub.price-list-type WHERE ub.price-list-type.stts = integer({&pdf-new}).
  display v-max with frame {&frame-name} .
  loc_calc-method:list-items in frame {&frame-name}  = {&pr-calc-methods-inf-DFP}.
    define variable p-list as character no-undo .
    run str/pr-listv.p
        (input {&pr-calc-methods-inf-DFP}  ,
        input {&pr-calc-fix},
        output p-list
        ) .
    loc_calc-method:list-items in frame {&frame-name}  = p-list .

  loc_calc-round-method:list-items in frame {&frame-name} = {&pr-rounds} .

  /* loc_work-date:RADIO-BUTTONS in frame {&frame-name}  =  mpl-date-obj mpl-date-shift mpl-date-sys */

define variable par-pr-incpc  as decimal   no-undo .
define variable par-pr-rndmt  as character no-undo .
define variable par-pr-rndbs  as decimal   no-undo .
 if p-mode = {&add-def} then do:
  { gbl/getsect.i run v-cntxt-obj-type v-cntxt-obj-code {&attr-overval} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-incpc} then par-pr-incpc = thbjattr_thbj-attr.property-value-decimal .
      if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-rndmt} then par-pr-rndmt = thbjattr_thbj-attr.property-value-character .
      if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-rndbs} then par-pr-rndbs = thbjattr_thbj-attr.property-value-decimal .
  end.

  assign
    loc_calc-increase-pc  = par-pr-incpc
    loc_calc-round-base   = par-pr-rndbs
  .
  case par-pr-rndmt:
    when "pr-round-9end" then
      loc_calc-round-method = {&pr-round-9end}.
    when "pr-round-9-99end" then
      loc_calc-round-method = {&pr-round-9-99end}.
    when "pr-round-integer" then
      loc_calc-round-method = {&pr-round-integer}.
    when "pr-round-select" then
      loc_calc-round-method = {&pr-round-select}.
    when "pr-round-up" then
      loc_calc-round-method = {&pr-round-up}.
    when "pr-round-coef" then
      loc_calc-round-method = {&pr-round-coef}.
    when "pr-round-off" then
      loc_calc-round-method = {&pr-round-off}.
    otherwise
      loc_calc-round-method = {&pr-round-off}.
  end case.
  if loc_calc-round-method = "" then do:
    loc_calc-round-method = {&pr-round-off}.
  end.
  if loc_calc-method = "" or loc_calc-method = ?  then do:
     loc_calc-method = {&pr-calc-no}.
  end.
  if lookup( input frame {&frame-name} loc_calc-round-method, {&pr-rounds-need-coef} ) > 0 then do:
    enable loc_calc-round-base with frame {&frame-name}.
  end.
  else
    hide loc_calc-round-base in frame {&frame-name}.

  if p-main-price = true
     then do:
         assign
            loc_create-price-doc = 1
            loc_send-cassa = 1
         .
         run avtoinit
             ( input   loc_plt-id
              ,input   loc_plt-db-num
              ,output  loc_ie-gen-marg
              ,output  loc_ie-gen-marg-parts
              ,output  loc_ie-objfirst
              ,output  loc_ie-objsecond
              ,output  loc_ie-pr-nakl
              ,output  loc_iv-gen-marg
              ,output  loc_iv-gen-marg-parts
              ,output  loc_iv-objfirst
              ,output  loc_iv-objsecond
              ,output  loc_iv-pr-nakl
              ,output  loc_im-gen-marg
              ,output  loc_im-gen-marg-parts
              ,output  loc_im-objfirst
              ,output  loc_im-objsecond
              ,output  loc_im-pr-nakl   ) .
         end.
      else do:
         assign
            loc_create-price-doc = 2
            loc_send-cassa = 2
         .
      end.
end.

  if p-mode <> {&add-def} then do:
     find ub.price-list-type no-lock where recid(ub.price-list-type) =  p-recid no-error .
     if error-status :error then return .
     if p-main-price = false  then do:
          run init-spis-kass.
          run init-spis-gds-grp.
     end.
     run init-spis-pay-type.
     run init-spis-cash-pay.
     run init-proc .
  end.

  run enable1 .
  if p-mode <> {&add-def} then do:
    if ub.price-list-type.stts = integer({&pdf-delete}) then do:
      frame {&frame-name}:TITLE = trim (frame {&frame-name}:TITLE) + " -- УДАЛЕН !!!"    .
    end.
  end.

  APPLY "CHOOSE":U TO BUTTON-1 .
  assign
    v-x-button-1 = BUTTON-1:row
    v-x-button-2 = BUTTON-2:row
    v-x-button-3 = BUTTON-3:row
    v-y-button-1 = BUTTON-1:column
    v-y-button-2 = BUTTON-2:column
    v-y-button-3 = BUTTON-3:column
    l-x-button-1 = label-BUTTON-1:row
    l-x-button-2 = label-BUTTON-2:row
    l-x-button-3 = label-BUTTON-3:row
    l-y-button-1 = label-BUTTON-1:column
    l-y-button-2 = label-BUTTON-2:column
    l-y-button-3 = label-BUTTON-3:column
  .

   define buffer ch0_price-list-type for ub.price-list-type  . /* ребенок  */
   define variable str-inf as character no-undo .
   str-inf = "".

   find first ch0_price-list-type no-lock where
        ch0_price-list-type.stts            = integer({&pdf-new}) and
        ch0_price-list-type.under-type-list = 1 and
        ch0_price-list-type.plt-main-id     = loc_plt-id and
        ch0_price-list-type.plt-main-db-num = loc_plt-db-num  no-error .
        if available ch0_price-list-type then
           str-inf = "  -- << РОДИТЕЛЬСКИЙ >> -- "  .
    frame {&frame-name}:TITLE = "Описание типа прайс-листа  "  + str-inf  + caps(p-mode).

    if p-main-price  then do:
        frame {&frame-name}:TITLE = "Описание ГЛАВНОГО типа прайс-листа  -- " + str-inf  + caps(p-mode) .
    end.

    if p-mode <> {&add-def} then do:
      if ub.price-list-type.stts = integer({&pdf-delete})  then do:
        frame {&frame-name}:TITLE = trim (frame {&frame-name}:TITLE) + " -- УДАЛЕН !!!"    .
      end.
    end.

  run vis-bin.

  if p-main-price = true   then do:
  hide v-max in frame  {&frame-name} .
  hide b-gop-2 b-qnty-tog b-gop-calc in frame page-2.
  enable b-gop with frame page-2 .
  assign
    v-x-button-3 = v-x-button-2
    v-x-button-2 = v-x-button-1
    v-y-button-3 = v-y-button-2
    v-y-button-2 = v-y-button-1
    l-x-button-3 = l-x-button-2
    l-x-button-2 = l-x-button-1
    l-y-button-3 = l-y-button-2
    l-y-button-2 = l-y-button-1
    BUTTON-2:row                  = v-x-button-2
    BUTTON-3:row                  = v-x-button-3
    BUTTON-2:column               = v-y-button-2
    BUTTON-3:column               = v-y-button-3
    label-BUTTON-2:row            = l-x-button-2
    label-BUTTON-3:row            = l-x-button-3
    label-BUTTON-2:column         = l-y-button-2
    label-BUTTON-3:column         = l-y-button-3

  .

    APPLY "CHOOSE":U TO BUTTON-2 .
    run runav in this-procedure .

  end.
  else do:
    hide loc_only-gbd  in frame {&frame-name} .
    hide br-tt B-chga  In FRAME  page-2 .
    /*
    hide loc_ie-gen-marg loc_ie-objfirst loc_ie-objsecond loc_ie-pr-nakl f-ie f-ie-3 f-ie-1 f-ie-2  In FRAME  page-2 .
    hide loc_iv-gen-marg loc_iv-objfirst loc_iv-objsecond loc_iv-pr-nakl f-iv f-iv-3 f-iv-1 f-iv-2  In FRAME  page-2 .
    hide loc_im-gen-marg loc_im-objfirst loc_im-objsecond loc_im-pr-nakl f-im f-im-3 f-im-1 f-im-2  In FRAME  page-2 .
    */
  end.
  if p-mode = {&add-def} then do:
    run mode_add-init.
  end.

  WAIT-FOR GO OF FRAME {&FRAME-NAME} /* FOCUS button-1 */ .
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE all-mode Dialog-Frame
PROCEDURE all-mode :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

define buffer buf_global-state for ub.global-state  .
define variable g-log as logical   no-undo .

    find last buf_global-state no-lock  no-error .
    if error-status :error then do:
       message "Не заданы глобальные настройки ценообразования !!!" view-as alert-box error .
       return error return-value .
    end.


    /* Нет ценообразования в других валютах */
    if buf_global-state.pl-use-val = false then do:
       hide
       r-cur in frame {&frame-name}
       loc_fix-cource-crc-doc  in frame {&frame-name} .
    end.

    /* Нет ценообразования по количественным группам */
    if buf_global-state.pl-use-qnty-group = false then do:
       hide
       loc_have-rs-qnty-group in frame page-1
       loc_qgr-id             in frame page-1
       loc_qgr-db-num         in frame page-1
       r-qnty-grp             in frame page-1
       loc_qg_name            in frame page-1  .
    end.

    /* Нет ценообразования по суммовым группам */
    if buf_global-state.pl-use-sum-group = false then do:
       hide
       loc_have-rs-sum-group
           loc_sgr-id
           loc_sgr-db-num
           r-qnty-sgr
           loc_sg_name
       in frame page-1 .
    end.

    /* Нет ценообразования по группам покупателям  */
    if buf_global-state.pl-use-grp-buy  = false then do:
       hide
       loc_bgr-id in frame page-2
       loc_bgr-db-num
       r-gop-2
       loc_bgr_name in frame page-2
       .
       /* вычеркнем только группу = 2  */
       g-log = loc_rs-buyer:disable ( radio-label(string(1), loc_rs-buyer:radio-buttons) ).

    end.

    /* Нет ценообразования по суммарному обороту  */
    if buf_global-state.pl-use-oborot-buy  = false then do:
       hide
        loc_tog-id
        loc_tog-db-num
        r-qnty-tog
        loc_tog_name
        r-obj-fill-in
        loc_obj-turnover
        loc_gop-id-for-calc-turnover
        loc_gop-db-num-for-calc-turnover
        r-gop-calc
        loc_obj-turnover
        in frame page-2 .

       hide
        loc_have-tog-id
        loc_have-tog-db-num
        r-have-tog
        loc_have-tog_name
        loc_have-rs-turn-group
        in frame page-1 .

       /* только оборот */
        g-log = loc_rs-buyer:disable(radio-label("2", loc_rs-buyer:radio-buttons)).

    end.
    /* Нет по группам покупателей и нет по оборотам покупателей */

    if buf_global-state.pl-use-oborot-buy  = false and buf_global-state.pl-use-grp-buy  = false then do:
       hide r-FILL-IN loc_rs-buyer in frame page-2 .
    end.
    /* Нет ценообразования по дате сервера  */
    if buf_global-state.pl-use-sys-date-time  = false then do:
       /* только итем */
       g-log = loc_work-date:disable(radio-label("3", loc_work-date:radio-buttons)).
    end.

    /* Нет ценообразования по сменам  */
    if buf_global-state.pl-use-shift-date-num  = false then do:
        /* только итем */
       g-log = loc_work-date:disable(radio-label("2", loc_work-date:radio-buttons)).
    end.


    /* Нет ценообразования по кассам  */
    if buf_global-state.pl-use-cassa  = false then do:
       hide
       loc_use-cassa
       loc_use-cassa_fill-in
       v-spis-kass
       in frame page-2 .
    end.

    /* Нет ценообразования c ограничением по типу платежа  */
    if buf_global-state.pl-use-pay-type  = false then do:
       hide
       loc_use-pay-type in frame page-3
       v-spis-type-pay
       in frame page-3 .
    end.

    /* Нет ценообразования c ограничением по типу кассового платежа  */
    if buf_global-state.pl-use-cash-pay  = false then do:
       hide
       loc_use-cash-pay in frame page-3
       v-spis-use-cash-pay
       in frame page-3 .
    end.

   /* Нет подчиненных листов */

    if buf_global-state.pl-use-child  = false then do:
       hide
          loc_under-type-list
          loc_plt-main-id
          loc_plt-main-db-num
          r-rod-price-type
          loc_rod-pt-name
          loc_under-hand-corr
       in frame {&frame-name} .
    end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE avtoinit Dialog-Frame
PROCEDURE avtoinit :
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .

define output parameter p-ie-gen-marg  as character no-undo .
define output parameter p-ie-gen-marg-parts  as character no-undo .
define output parameter p-ie-objfirst  as integer   no-undo .
define output parameter p-ie-objsecond as integer   no-undo .
define output parameter p-ie-pr-nakl   as logical   no-undo .

define output parameter p-iv-gen-marg  as character no-undo .
define output parameter p-iv-gen-marg-parts  as character no-undo .
define output parameter p-iv-objfirst  as integer   no-undo .
define output parameter p-iv-objsecond as integer   no-undo .
define output parameter p-iv-pr-nakl   as logical   no-undo .

define output parameter p-im-gen-marg  as character no-undo .
define output parameter p-im-gen-marg-parts  as character no-undo .
define output parameter p-im-objfirst  as integer   no-undo .
define output parameter p-im-objsecond as integer   no-undo .
define output parameter p-im-pr-nakl   as logical   no-undo .



define buffer buf_price-list-type-attr for ub.price-list-type-attr  .
assign
p-ie-gen-marg  = {&typeprice_no-margin}
p-ie-gen-marg-parts  = {&typeprice_no-margin}
p-ie-objfirst  = 0
p-ie-objsecond = 1
p-ie-pr-nakl   = false

p-iv-gen-marg  = {&typeprice_no-margin}
p-iv-gen-marg-parts  = {&typeprice_no-margin}
p-iv-objfirst  = 0
p-iv-objsecond = 1
p-iv-pr-nakl   =  false

p-im-gen-marg  = {&typeprice_no-margin}
p-im-gen-marg-parts  = {&typeprice_no-margin}
p-im-objfirst  = 0
p-im-objsecond = 1
p-im-pr-nakl   = false
 .


for each  buf_price-list-type-attr no-lock where
          buf_price-list-type-attr.plt-id     = p-plt-id and
          buf_price-list-type-attr.plt-db-num = p-plt-db-num  :

  if buf_price-list-type-attr.attr-code = {&typeprice_ie-gen-marg}  then p-ie-gen-marg   = buf_price-list-type-attr.attr-value.
  if buf_price-list-type-attr.attr-code = {&typeprice_ie-gen-marg-parts}  then p-ie-gen-marg-parts   = buf_price-list-type-attr.attr-value.
  if buf_price-list-type-attr.attr-code = {&typeprice_ie-objfirst}  then p-ie-objfirst   = int(buf_price-list-type-attr.attr-value).
  if buf_price-list-type-attr.attr-code = {&typeprice_ie-objsecond} then p-ie-objsecond = int(buf_price-list-type-attr.attr-value).
  if buf_price-list-type-attr.attr-code = {&typeprice_ie-pr-nakl}   then p-ie-pr-nakl   = if buf_price-list-type-attr.attr-value = 'yes' then true  else false .

  if buf_price-list-type-attr.attr-code = {&typeprice_iv-gen-marg}  then p-iv-gen-marg   = buf_price-list-type-attr.attr-value.
  if buf_price-list-type-attr.attr-code = {&typeprice_iv-gen-marg-parts}  then p-iv-gen-marg-parts   = buf_price-list-type-attr.attr-value.
  if buf_price-list-type-attr.attr-code = {&typeprice_iv-objfirst}  then p-iv-objfirst   = int(buf_price-list-type-attr.attr-value).
  if buf_price-list-type-attr.attr-code = {&typeprice_iv-objsecond} then p-iv-objsecond = int(buf_price-list-type-attr.attr-value).
  if buf_price-list-type-attr.attr-code = {&typeprice_iv-pr-nakl}   then p-iv-pr-nakl   = if buf_price-list-type-attr.attr-value = 'yes' then true  else false .

  if buf_price-list-type-attr.attr-code = {&typeprice_im-gen-marg}  then p-im-gen-marg   = buf_price-list-type-attr.attr-value.
  if buf_price-list-type-attr.attr-code = {&typeprice_im-gen-marg-parts}  then p-im-gen-marg-parts   = buf_price-list-type-attr.attr-value.
  if buf_price-list-type-attr.attr-code = {&typeprice_im-objfirst}  then p-im-objfirst   = int(buf_price-list-type-attr.attr-value).
  if buf_price-list-type-attr.attr-code = {&typeprice_im-objsecond} then p-im-objsecond = int(buf_price-list-type-attr.attr-value).
  if buf_price-list-type-attr.attr-code = {&typeprice_im-pr-nakl}   then p-im-pr-nakl   = if buf_price-list-type-attr.attr-value = 'yes' then true  else false .
end.


run make-tt (
   p-ie-gen-marg
  ,p-ie-gen-marg-parts
  ,p-ie-objfirst
  ,p-ie-objsecond
  ,p-ie-pr-nakl
  ,p-iv-gen-marg
  ,p-iv-gen-marg-parts
  ,p-iv-objfirst
  ,p-iv-objsecond
  ,p-iv-pr-nakl
  ,p-im-gen-marg
  ,p-im-gen-marg-parts
  ,p-im-objfirst
  ,p-im-objsecond
  ,p-im-pr-nakl
  ).



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE avtoper Dialog-Frame
PROCEDURE avtoper :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
display br-tt B-chga  with frame  page-2 .
enable
  br-tt
  B-chga  when  p-mode <> {&lookup}
  with frame  page-2 .
hide loc_gop-id-for-calc-turnover in frame  page-2 .

/*

DISPLAY loc_ie-gen-marg  f-ie f-ie-3   WITH FRAME page-2 .
DISPLAY loc_iv-gen-marg  f-iv f-iv-3   WITH FRAME page-2 .
DISPLAY loc_im-gen-marg  f-im f-im-3   WITH FRAME page-2 .


run avts.

 case loc_ie-gen-marg :
 when {&typeprice_no-margin} then do:
    disable
      loc_ie-objsecond  f-ie-2   loc_ie-pr-nakl
      with frame page-2.
    hide
      loc_ie-objsecond  f-ie-2  loc_ie-pr-nakl
      in frame page-2.
    display
      loc_ie-objfirst   f-ie-1
      with frame page-2.

 end.
 when {&typeprice_After-margin} then do:
    disable
      loc_ie-pr-nakl
      with frame page-2.
    hide
      loc_ie-pr-nakl
      in frame page-2.
    display
      loc_ie-objsecond  f-ie-2   loc_ie-objfirst   f-ie-1
      with frame page-2.
 end.
 when {&typeprice_Before-margin} then do:
    display
      loc_ie-pr-nakl loc_ie-objsecond  f-ie-2  loc_ie-objfirst   f-ie-1
      with frame page-2.
 end.
 otherwise do:

 end.
 end case.



 case loc_iv-gen-marg :
 when {&typeprice_no-margin} then do:
    disable
      loc_iv-objsecond  f-iv-2   loc_iv-pr-nakl
      with frame page-2.
    hide
      loc_iv-objsecond  f-iv-2  loc_iv-pr-nakl
      in frame page-2.
    display
      loc_iv-objfirst   f-iv-1
      with frame page-2.

 end.
 when {&typeprice_After-margin} then do:
    disable
      loc_iv-pr-nakl
      with frame page-2.
    hide
      loc_iv-pr-nakl
      in frame page-2.
    display
      loc_iv-objsecond  f-iv-2   loc_iv-objfirst   f-iv-1
      with frame page-2.
 end.
 when {&typeprice_Before-margin} then do:
    display
      loc_iv-pr-nakl loc_iv-objsecond  f-iv-2  loc_iv-objfirst   f-iv-1
      with frame page-2.
 end.
 otherwise do:

 end.
 end case.



 case loc_im-gen-marg :
 when {&typeprice_no-margin} then do:
    disable
      loc_im-objsecond  f-im-2   loc_im-pr-nakl
      with frame page-2.
    hide
      loc_im-objsecond  f-im-2  loc_im-pr-nakl
      in frame page-2.
    display
      loc_im-objfirst   f-im-1
      with frame page-2.

 end.
 when {&typeprice_After-margin} then do:
    disable
      loc_im-pr-nakl
      with frame page-2.
    hide
      loc_im-pr-nakl
      in frame page-2.
    display
      loc_im-objsecond  f-im-2   loc_im-objfirst   f-im-1
      with frame page-2.
 end.
 when {&typeprice_Before-margin} then do:
    display
      loc_im-pr-nakl loc_im-objsecond  f-im-2  loc_im-objfirst   f-im-1
      with frame page-2.
 end.
 otherwise do:

 end.
 end case.


if p-mode <> {&lookup} then do:
    ENABLE
      loc_iv-gen-marg
      loc_iv-objfirst    when loc_iv-objfirst:visible
      loc_iv-objsecond   when loc_iv-objsecond:visible
      loc_iv-pr-nakl     when loc_iv-pr-nakl:visible
    WITH FRAME page-2 .
    ENABLE
      loc_ie-gen-marg
      loc_ie-objfirst    when loc_ie-objfirst:visible
      loc_ie-objsecond   when loc_ie-objsecond:visible
      loc_ie-pr-nakl     when loc_ie-pr-nakl:visible
    WITH FRAME page-2 .
    ENABLE
      loc_im-gen-marg
      loc_im-objfirst    when loc_im-objfirst:visible
      loc_im-objsecond   when loc_im-objsecond:visible
      loc_im-pr-nakl     when loc_im-pr-nakl:visible
    WITH FRAME page-2 .
end.
*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE avtosave Dialog-Frame
PROCEDURE avtosave :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .

define input parameter p-ie-gen-marg  as character no-undo .
define input parameter p-ie-gen-marg-parts  as character no-undo .
define input parameter p-ie-objfirst  as integer   no-undo .
define input parameter p-ie-objsecond as integer   no-undo .
define input parameter p-ie-pr-nakl   as logical   no-undo .

define input parameter p-iv-gen-marg  as character no-undo .
define input parameter p-iv-gen-marg-parts  as character no-undo .
define input parameter p-iv-objfirst  as integer   no-undo .
define input parameter p-iv-objsecond as integer   no-undo .
define input parameter p-iv-pr-nakl   as logical   no-undo .

define input parameter p-im-gen-marg  as character no-undo .
define input parameter p-im-gen-marg-parts  as character no-undo .
define input parameter p-im-objfirst  as integer   no-undo .
define input parameter p-im-objsecond as integer   no-undo .
define input parameter p-im-pr-nakl   as logical   no-undo .
/*
message 'p-ie-gen-marg  '   p-ie-gen-marg   skip
        'p-ie-gen-marg-parts  '   p-ie-gen-marg-parts   skip
        'p-ie-objfirst  '   p-ie-objfirst   skip
        'p-ie-objsecond '   p-ie-objsecond  skip
        'p-ie-pr-nakl   '   p-ie-pr-nakl    skip
                                            skip
        'p-iv-gen-marg  '   p-iv-gen-marg   skip
        'p-iv-gen-marg-parts  '   p-iv-gen-marg-parts   skip
        'p-iv-objfirst  '   p-iv-objfirst   skip
        'p-iv-objsecond '   p-iv-objsecond  skip
        'p-iv-pr-nakl   '   p-iv-pr-nakl    skip
                                            skip
        'p-im-gen-marg  '   p-im-gen-marg   skip
        'p-im-gen-marg-parts  '   p-im-gen-marg-parts   skip
        'p-im-objfirst  '   p-im-objfirst   skip
        'p-im-objsecond '   p-im-objsecond  skip
        'p-im-pr-nakl   '   p-im-pr-nakl    skip.

  */
define buffer buf_price-list-type-attr for ub.price-list-type-attr  .

find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num and
           buf_price-list-type-attr.attr-code  = {&typeprice_ie-gen-marg}  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = {&typeprice_ie-gen-marg}
        buf_price-list-type-attr.attr-value = p-ie-gen-marg
        .

find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num and
           buf_price-list-type-attr.attr-code  = {&typeprice_ie-gen-marg-parts}  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = {&typeprice_ie-gen-marg-parts}
        buf_price-list-type-attr.attr-value = p-ie-gen-marg-parts
        .

find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num and
           buf_price-list-type-attr.attr-code  = {&typeprice_ie-objfirst}  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = {&typeprice_ie-objfirst}
        buf_price-list-type-attr.attr-value = string( p-ie-objfirst)
        .
find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num and
           buf_price-list-type-attr.attr-code  = {&typeprice_ie-objsecond}  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = {&typeprice_ie-objsecond}
        buf_price-list-type-attr.attr-value = string(p-ie-objsecond)
        .

find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num  and
           buf_price-list-type-attr.attr-code  = {&typeprice_ie-pr-nakl}  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = {&typeprice_ie-pr-nakl}
        buf_price-list-type-attr.attr-value = string(p-ie-pr-nakl,"yes/no")
        .

find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num and
           buf_price-list-type-attr.attr-code  = {&typeprice_iv-gen-marg}  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = {&typeprice_iv-gen-marg}
        buf_price-list-type-attr.attr-value = p-iv-gen-marg
        .
find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num and
           buf_price-list-type-attr.attr-code  = {&typeprice_iv-gen-marg-parts}  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = {&typeprice_iv-gen-marg-parts}
        buf_price-list-type-attr.attr-value = p-iv-gen-marg-parts
        .


find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num and
           buf_price-list-type-attr.attr-code  = {&typeprice_iv-objfirst}  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = {&typeprice_iv-objfirst}
        buf_price-list-type-attr.attr-value = string( p-iv-objfirst)
        .
find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num and
           buf_price-list-type-attr.attr-code  = {&typeprice_iv-objsecond}  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = {&typeprice_iv-objsecond}
        buf_price-list-type-attr.attr-value = string(p-iv-objsecond)
        .

find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num  and
           buf_price-list-type-attr.attr-code  = {&typeprice_iv-pr-nakl}  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = {&typeprice_iv-pr-nakl}
        buf_price-list-type-attr.attr-value = string(p-iv-pr-nakl,"yes/no")
        .


find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num and
           buf_price-list-type-attr.attr-code  = {&typeprice_im-gen-marg}  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = {&typeprice_im-gen-marg}
        buf_price-list-type-attr.attr-value = p-im-gen-marg
        .
find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num and
           buf_price-list-type-attr.attr-code  = {&typeprice_im-gen-marg-parts}  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = {&typeprice_im-gen-marg-parts}
        buf_price-list-type-attr.attr-value = p-im-gen-marg-parts
        .


find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num and
           buf_price-list-type-attr.attr-code  = {&typeprice_im-objfirst}  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = {&typeprice_im-objfirst}
        buf_price-list-type-attr.attr-value = string( p-im-objfirst)
        .
find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num and
           buf_price-list-type-attr.attr-code  = {&typeprice_im-objsecond}  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = {&typeprice_im-objsecond}
        buf_price-list-type-attr.attr-value = string(p-im-objsecond)
        .

find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num  and
           buf_price-list-type-attr.attr-code  = {&typeprice_im-pr-nakl}  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = {&typeprice_im-pr-nakl}
        buf_price-list-type-attr.attr-value = string(p-im-pr-nakl,"yes/no")
        .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE avts Dialog-Frame
PROCEDURE avts :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
/*
  if loc_ie-gen-marg:visible in frame page-2 then assign frame page-2 loc_ie-gen-marg  no-error .
  if loc_iv-gen-marg:visible  then assign frame page-2 loc_iv-gen-marg  no-error .
  if loc_im-gen-marg:visible  then assign frame page-2 loc_im-gen-marg  no-error .

  if loc_ie-objfirst:visible  then assign frame page-2 loc_ie-objfirst  no-error .
  if loc_iv-objfirst:visible  then assign frame page-2 loc_iv-objfirst  no-error .
  if loc_im-objfirst:visible  then assign frame page-2 loc_im-objfirst  no-error .

  if loc_ie-objsecond:visible then assign frame page-2 loc_ie-objsecond no-error .
  if loc_iv-objsecond:visible then assign frame page-2 loc_iv-objsecond no-error .
  if loc_im-objsecond:visible then assign frame page-2 loc_im-objsecond no-error .

  if loc_ie-pr-nakl:visible   then assign frame page-2 loc_ie-pr-nakl   no-error .
  if loc_iv-pr-nakl:visible   then assign frame page-2 loc_iv-pr-nakl   no-error .
  if loc_im-pr-nakl:visible   then assign frame page-2 loc_im-pr-nakl   no-error .
  */
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
  HIDE FRAME page-1.
  HIDE FRAME page-2.
  HIDE FRAME page-3.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable1 Dialog-Frame
PROCEDURE enable1 :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable g#log as logical no-undo.
  {&OPEN-QUERY-Dialog-Frame}
  {&OPEN-QUERY-BR-tt}
  GET FIRST Dialog-Frame.
  DISPLAY loc_name loc_priority loc_create-price-doc loc_fix-cource-crc-base
          loc_send-cassa loc_fix-cource-crc-doc loc_calc-method
          loc_calc-increase-pc loc_calc-round-method
          loc_calc-round-base
          loc_work-date
          loc_only-gbd loc_plt-db-num loc_plt-id create-price-doc-FILL-IN
          loc_curr-code loc_abbr-doc use-cassa-FILL-IN work-date-FILL-IN
          label-button-1 label-button-2 label-button-3
          loc_under-type-list
      WITH FRAME Dialog-Frame.
  ENABLE B-save RECT-1 B-Cancel B-Help loc_name loc_priority
          r-cur loc_fix-cource-crc-base
         loc_fix-cource-crc-doc loc_calc-method loc_calc-increase-pc
         loc_calc-round-method
         loc_work-date loc_only-gbd BUTTON-2
         BUTTON-3 BUTTON-1 loc_plt-db-num loc_plt-id create-price-doc-FILL-IN
         loc_curr-code  use-cassa-FILL-IN work-date-FILL-IN
         label-button-1 label-button-2 label-button-3
         loc_under-type-list

      WITH FRAME Dialog-Frame.

  if p-mode = {&add-def} then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_documents_all':U
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      false
      g#log
    }
    if g#log then do:
      loc_use-obj = 1.
      disable r-gop with frame page-2 .
    end.
    else do:
      loc_use-obj = 2.
      enable r-gop with frame page-2 .
    end.
  end.
  if p-main-price = false   then do:
      enable
       loc_send-cassa when p-mode = {&add-def}
       l-ban-discnt   when p-mode = {&add-def}
       r-ban-discnt   when p-mode = {&add-def}
       b-ban-discnt
       with frame {&frame-name}.
      display
       loc_ban-discnt
       f-ban-discnt
       with frame {&frame-name}.
  end.
  run tog-band .
  if loc_under-type-list then do:
      display  loc_plt-main-id loc_plt-main-db-num loc_rod-pt-name loc_under-hand-corr  WITH FRAME Dialog-Frame.
      enable   loc_under-hand-corr with frame {&frame-name}.
      HIDE v-3 IN FRAME page-3 .
      HIDE {&list-3} IN FRAME page-3 .
      HIDE v-1 IN FRAME page-1 .
      HIDE {&list-1} IN FRAME page-1 .
      hide frame page-1  frame page-3  .
      hide  button-1 label-button-1 in frame {&frame-name} .
      hide  button-3 label-button-3
            loc_fix-cource-crc-base
            loc_fix-cource-crc-doc
            loc_ban-discnt
            loc_only-gbd
            loc_calc-method
      in frame {&frame-name} .
      loc_calc-increase-pc:label = "% наценки от родителя" .
      loc_calc-round-method:label = "Метод округления"     .
      APPLY "CHOOSE":U TO BUTTON-2 .
      disable  loc_under-type-list  with frame {&frame-name}.
  end.


  if lookup( loc_calc-round-method, {&pr-rounds-need-coef} ) > 0 then do:
    enable loc_calc-round-base with frame {&frame-name}.
  end.
  else
    hide loc_calc-round-base in frame {&frame-name}.

  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  DISPLAY v-1 loc_have-rs-qnty-group loc_have-rs-sum-group loc_qgr-id
            loc_qgr-db-num loc_qg_name loc_sgr-id loc_sgr-db-num loc_sg_name
            loc_have-tog-id
            loc_have-tog-db-num
            r-have-tog
            loc_have-tog_name
            loc_have-rs-turn-group
      WITH FRAME page-1.
  ENABLE v-1 loc_have-rs-qnty-group r-qnty-grp loc_have-rs-sum-group r-qnty-sgr
         loc_qgr-id loc_qgr-db-num loc_qg_name loc_sgr-id loc_sgr-db-num
         loc_sg_name  loc_have-rs-turn-group
      WITH FRAME page-1.
  {&OPEN-BROWSERS-IN-QUERY-page-1}
  run vis-bin .
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
  DISPLAY loc_priority loc_name loc_under-type-list loc_fix-cource-crc-base
          loc_work-date loc_fix-cource-crc-doc l-ban-discnt loc_calc-method
          loc_create-price-doc loc_calc-increase-pc loc_send-cassa loc_only-gbd
          loc_calc-round-method loc_calc-round-base loc_plt-db-num loc_plt-id
          v-max loc_curr-code loc_abbr-doc work-date-FILL-IN loc_ban-discnt
          f-ban-discnt create-price-doc-FILL-IN use-cassa-FILL-IN label-button-1
          label-button-2 label-button-3
      WITH FRAME Dialog-Frame.
  ENABLE B-save B-Cancel B-Help RECT-1 loc_priority loc_name r-cur
         loc_under-type-list BUTTON-1 loc_fix-cource-crc-base loc_work-date
         loc_fix-cource-crc-doc l-ban-discnt b-ban-discnt loc_calc-method
         loc_calc-increase-pc loc_only-gbd loc_calc-round-method
         loc_calc-round-base BUTTON-2 BUTTON-3 loc_plt-db-num loc_plt-id
         loc_curr-code loc_abbr-doc work-date-FILL-IN loc_ban-discnt
         f-ban-discnt create-price-doc-FILL-IN use-cassa-FILL-IN
      WITH FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  DISPLAY v-1 loc_have-rs-qnty-group loc_have-rs-sum-group
          loc_have-rs-turn-group loc_qgr-id loc_qgr-db-num loc_qg_name
          loc_sgr-id loc_sgr-db-num loc_sg_name loc_have-tog-db-num
          loc_have-tog_name loc_have-tog-id
      WITH FRAME page-1.
  ENABLE v-1 loc_have-rs-qnty-group r-qnty-grp b-qnty-grp loc_have-rs-sum-group
         r-qnty-sgr b-qnty-sgr loc_have-rs-turn-group r-have-tog b-have-tog
         loc_qgr-id loc_qgr-db-num loc_qg_name loc_sgr-id loc_sgr-db-num
         loc_sg_name loc_have-tog-db-num loc_have-tog_name loc_have-tog-id
      WITH FRAME page-1.
  {&OPEN-BROWSERS-IN-QUERY-page-1}
  DISPLAY r-use-obj-fill-in loc_gop-db-num f-ie-3 loc_tog-db-num r-obj-fill-in
          loc_gop-db-num-for-calc-turnover
      WITH FRAME page-2.
  ENABLE b-gop BR-tt b-gop-2 r-qnty-tog b-qnty-tog b-gop-calc B-chga
         r-use-obj-fill-in f-ie-3 loc_tog-db-num r-obj-fill-in
      WITH FRAME page-2.
  {&OPEN-BROWSERS-IN-QUERY-page-2}
  DISPLAY v-3
      WITH FRAME page-3.
  ENABLE v-3
      WITH FRAME page-3.
  {&OPEN-BROWSERS-IN-QUERY-page-3}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
      loc_abbr-doc                          =    ""
      loc_ban-discnt                        =    ub.price-list-type.ban-discnt
      loc_bgr_name                          =    ""
      loc_calc-round-method                 =    ub.price-list-type.calc-round-method
      loc_calc-round-base                   =    ub.price-list-type.calc-round-base
      loc_calc-increase-pc                  =    ub.price-list-type.calc-increase-pc
      loc_calc-method                       =    ub.price-list-type.calc-method
      loc_create-price-doc                  =    ub.price-list-type.create-price-doc
      loc_fix-cource-crc-base               =    ub.price-list-type.fix-cource-crc-base
      loc_fix-cource-crc-doc                =    ub.price-list-type.fix-cource-crc-doc
      loc_gop_name-name                     =    ""
      loc_gop_name-tnv                      =    ""
      loc_have-rs-qnty-group                =    logical(ub.price-list-type.have-rs-qnty-group)
      loc_have-rs-sum-group                 =    ub.price-list-type.have-rs-sum-group
      loc_only-gbd                          =    logical(ub.price-list-type.only-gbd)
      loc_plt-main-db-num                   =    ub.price-list-type.plt-main-db-num
      loc_plt-main-id                       =    ub.price-list-type.plt-main-id
      loc_priority                          =    ub.price-list-type.priority
      loc_qg_name                           =    ""
      loc_rod-pt-name                       =    ""
      loc_rs-buyer                          =    ub.price-list-type.rs-buyer
      loc_send-cassa                        =    ub.price-list-type.send-cassa
      loc_sg_name                           =    ""
      loc_tog_name                          =    ""
      loc_under-hand-corr                   =    logical(ub.price-list-type.under-hand-corr)
      loc_under-round-method                =    ub.price-list-type.under-round-method
      loc_under-perc                        =    ub.price-list-type.under-perc
      loc_under-type-list                   =    logical(ub.price-list-type.under-type-list)
      loc_use-cassa                         =    ub.price-list-type.use-cassa
      loc_use-gds-group                     =    logical(ub.price-list-type.use-gds-group)
      loc_use-obj                           =    ub.price-list-type.use-obj
      loc_work-date                         =    ub.price-list-type.work-date
      loc_bgr-db-num                        =    ub.price-list-type.bgr-db-num
      loc_bgr-id                            =    ub.price-list-type.bgr-id
      loc_curr-code                         =    ub.price-list-type.curr-code
      loc_gop-db-num                        =    ub.price-list-type.gop-db-num
      loc_gop-db-num-for-calc-turnover      =    ub.price-list-type.gop-db-num-for-calc-turnover
      loc_gop-id                            =    ub.price-list-type.gop-id
      loc_gop-id-for-calc-turnover          =    ub.price-list-type.gop-id-for-calc-turnover
      loc_name                              =    ub.price-list-type.name
      loc_plt-db-num                        =    ub.price-list-type.plt-db-num
      loc_plt-id                            =    ub.price-list-type.plt-id
      loc_qgr-db-num                        =    ub.price-list-type.qgr-db-num
      loc_qgr-id                            =    ub.price-list-type.qgr-id
      loc_sgr-db-num                        =    ub.price-list-type.sgr-db-num
      loc_sgr-id                            =    ub.price-list-type.sgr-id
      loc_tog-db-num                        =    ub.price-list-type.tog-db-num
      loc_tog-id                            =    ub.price-list-type.tog-id
      loc_obj-turnover                      =    ub.price-list-type.obj-turnover
   /* loc_ttg-summa                      =    ub.price-list-type.ttg-summa*/
      loc_have-rs-turn-group                =   logical( ub.price-list-type.have-rs-turn-group)
      loc_have-tog-db-num                   =   ub.price-list-type.have-tog-db-num
      loc_have-tog-id                       =   ub.price-list-type.have-tog-id
      loc_use-cash-pay                      =   logical(ub.price-list-type.use-cash-pay )
      loc_use-pay-type                      =   logical(ub.price-list-type.use-pay-type )

      .

/* СКИДКИ */
define buffer buf_dis-rule for ub.dis-rule  .
  if loc_ban-discnt > 0 then do:
    assign
      l-ban-discnt = true
    .
    find first buf_dis-rule no-lock where
               buf_dis-rule.templ-rl-root =  loc_ban-discnt
               no-error .

  if available buf_dis-rule then do:
      assign
        f-ban-discnt   = buf_dis-rule.des
      .
      end.
      else do:
        l-ban-discnt = false .
      end.
  end.
  else do:
    assign
      l-ban-discnt = false
    .
  end.
run  tog-band.

define variable loc_exch-rate  as decimal   no-undo .
define variable loc_exch-scale as decimal   no-undo .

{ gbl/exchrate.i
  loc_curr-code
  TODAY
  loc_exch-rate
  loc_exch-scale
  loc_abbr-doc }


find ub.qnty-group no-lock where
     ub.qnty-group.qgr-id     = loc_qgr-id     and
     ub.qnty-group.qgr-db-num = loc_qgr-db-num no-error .
if available ub.qnty-group then  loc_qg_name    = ub.qnty-group.name  .

find ub.buyer-group no-lock where
     ub.buyer-group.bgr-db-num = loc_bgr-db-num  and
     ub.buyer-group.bgr-id     = loc_bgr-id      no-error .
if available ub.buyer-group then  loc_bgr_name   = ub.buyer-group.name  .

find ub.grp-obj-price no-lock where
     ub.grp-obj-price.gop-db-num  = loc_gop-db-num     and
     ub.grp-obj-price.gop-id      = loc_gop-id         no-error .
if available ub.grp-obj-price then loc_gop_name-name = ub.grp-obj-price.name  .

find ub.grp-obj-price no-lock where
     ub.grp-obj-price.gop-db-num  = loc_gop-db-num-for-calc-turnover     and
     ub.grp-obj-price.gop-id      = loc_gop-id-for-calc-turnover         no-error .
if available ub.grp-obj-price then loc_gop_name-tnv = ub.grp-obj-price.name  .


find ub.price-list-type no-lock where
     ub.price-list-type.plt-db-num =  loc_plt-main-db-num  and
     ub.price-list-type.plt-id     =  loc_plt-main-id      no-error .
if available ub.price-list-type then loc_rod-pt-name     = ub.price-list-type.name  .

find ub.sum-group no-lock where
     ub.sum-group.sgr-db-num = loc_sgr-db-num and
     ub.sum-group.sgr-id     = loc_sgr-id     no-error .
if available ub.sum-group then loc_sg_name    = ub.sum-group.name  .

find ub.turnover-group no-lock where
     ub.turnover-group.tog-db-num = loc_tog-db-num and
     ub.turnover-group.tog-id     = loc_tog-id     no-error .
if available ub.turnover-group then loc_tog_name    = ub.turnover-group.name  .

find ub.turnover-group no-lock where
     ub.turnover-group.tog-db-num = loc_have-tog-db-num and
     ub.turnover-group.tog-id     = loc_have-tog-id     no-error .
if available ub.turnover-group then loc_have-tog_name    = ub.turnover-group.name  .
         run avtoinit
             ( input   loc_plt-id
              ,input   loc_plt-db-num
              ,output  loc_ie-gen-marg
              ,output  loc_ie-gen-marg-parts
              ,output  loc_ie-objfirst
              ,output  loc_ie-objsecond
              ,output  loc_ie-pr-nakl
              ,output  loc_iv-gen-marg
              ,output  loc_iv-gen-marg-parts
              ,output  loc_iv-objfirst
              ,output  loc_iv-objsecond
              ,output  loc_iv-pr-nakl
              ,output  loc_im-gen-marg
              ,output  loc_im-gen-marg-parts
              ,output  loc_im-objfirst
              ,output  loc_im-objsecond
              ,output  loc_im-pr-nakl   ) .

run runav.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-spis-cash-pay Dialog-Frame
PROCEDURE init-spis-cash-pay :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer buf_price-list-type-cash-pay for ub.price-list-type-cash-pay  .
define buffer buf_cash-pay for ub.cash-pay  .
define variable v-name as character no-undo .

for each TT_price-list-type-cash-pay : delete TT_price-list-type-cash-pay . end.
v-spis-use-cash-pay = "".

   for each buf_price-list-type-cash-pay no-lock where
            buf_price-list-type-cash-pay.stts       = 0 and
            buf_price-list-type-cash-pay.plt-id     = ub.price-list-type.plt-id and
            buf_price-list-type-cash-pay.plt-db-num = ub.price-list-type.plt-db-num
            :
            create TT_price-list-type-cash-pay.
            BUFFER-COPY buf_price-list-type-cash-pay TO TT_price-list-type-cash-pay.
            find first buf_cash-pay no-lock   where
                 buf_cash-pay.cdpay-code  = TT_price-list-type-cash-pay.cdpay-code  and
                 buf_cash-pay.curr-code   = TT_price-list-type-cash-pay.curr-code
                 no-error .
            if available  buf_cash-pay then .
            v-spis-use-cash-pay  = v-spis-use-cash-pay +  buf_cash-pay.obj-name + v-name + {&NEW-LINE} .
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-spis-gds-grp Dialog-Frame
PROCEDURE init-spis-gds-grp :
do
on error undo, return error return-value
  :
define buffer buf_price-list-type-gds-grp for ub.price-list-type-gds-grp  .
define variable v-name as character no-undo .

for each TT_price-list-type-gds-grp : delete TT_price-list-type-gds-grp . end.
v-spis-group = "".

    for each buf_price-list-type-gds-grp no-lock where
            buf_price-list-type-gds-grp.stts       = 0 and
            buf_price-list-type-gds-grp.plt-id     = ub.price-list-type.plt-id and
            buf_price-list-type-gds-grp.plt-db-num = ub.price-list-type.plt-db-num
            :
            create TT_price-list-type-gds-grp.
            BUFFER-COPY buf_price-list-type-gds-grp TO TT_price-list-type-gds-grp.
            { gbl/grpgdsnm.i buf_price-list-type-gds-grp.node-code v-name}
             v-spis-group = v-spis-group + v-name + {&NEW-LINE} .
    end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-spis-kass Dialog-Frame
PROCEDURE init-spis-kass :
do
on error undo, return error return-value
  :
define buffer buf_price-list-type-cassa for ub.price-list-type-cassa  .
for each TT_price-list-type-cassa : delete TT_price-list-type-cassa . end.
v-spis-kass = "".

    for each buf_price-list-type-cassa no-lock where
            buf_price-list-type-cassa.stts       = 0  and
            buf_price-list-type-cassa.plt-id     = ub.price-list-type.plt-id and
            buf_price-list-type-cassa.plt-db-num = ub.price-list-type.plt-db-num
            :
            create TT_price-list-type-cassa.
            BUFFER-COPY buf_price-list-type-cassa TO TT_price-list-type-cassa.
              v-spis-kass = v-spis-kass +
              "БД:"  + string ( buf_price-list-type-cassa.db-num   ) +
              " маг" + string ( buf_price-list-type-cassa.obj-code ) +
              " №"   + string ( buf_price-list-type-cassa.cash-num ) +
              " "    +  buf_price-list-type-cassa.pos-type
              + {&NEW-LINE} .
    end.

end.
end procedure. /* init-spis-kass */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-spis-pay-type Dialog-Frame
PROCEDURE init-spis-pay-type :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer buf_price-list-type-pay-type for ub.price-list-type-pay-type  .
define buffer buf_pay-type for ub.pay-type  .
define variable v-name as character no-undo .

for each TT_price-list-type-pay-type : delete TT_price-list-type-pay-type . end.
v-spis-type-pay = "".

   for each buf_price-list-type-pay-type no-lock where
            buf_price-list-type-pay-type.stts       = 0 and
            buf_price-list-type-pay-type.plt-id     = ub.price-list-type.plt-id and
            buf_price-list-type-pay-type.plt-db-num = ub.price-list-type.plt-db-num
            :
            create TT_price-list-type-pay-type.
            BUFFER-COPY buf_price-list-type-pay-type TO TT_price-list-type-pay-type.
            find first buf_pay-type no-lock   where  buf_pay-type.obj-code  = TT_price-list-type-pay-type.pay-code no-error .
            if available  buf_pay-type then .
            v-spis-type-pay = v-spis-type-pay + buf_pay-type.obj-name + {&NEW-LINE} .
    end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-tt Dialog-Frame
PROCEDURE make-tt :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input parameter p-ie-gen-marg  as character no-undo .
define input parameter p-ie-gen-marg-parts  as character no-undo .
define input parameter p-ie-objfirst  as integer   no-undo .
define input parameter p-ie-objsecond as integer   no-undo .
define input parameter p-ie-pr-nakl   as logical   no-undo .

define input parameter p-iv-gen-marg  as character no-undo .
define input parameter p-iv-gen-marg-parts  as character no-undo .
define input parameter p-iv-objfirst  as integer   no-undo .
define input parameter p-iv-objsecond as integer   no-undo .
define input parameter p-iv-pr-nakl   as logical   no-undo .

define input parameter p-im-gen-marg  as character no-undo .
define input parameter p-im-gen-marg-parts  as character no-undo .
define input parameter p-im-objfirst  as integer   no-undo .
define input parameter p-im-objsecond as integer   no-undo .
define input parameter p-im-pr-nakl   as logical   no-undo .

empty temp-table temp-avto-price .

create temp-avto-price.
assign
  temp-avto-price.nn             =  1
  temp-avto-price.ext-doc-type   =  "Приход внешний"
  temp-avto-price.gen-marg       =  p-ie-gen-marg
  temp-avto-price.gen-marg-parts =  p-ie-gen-marg-parts
  temp-avto-price.objfirst       =  p-ie-objfirst
  temp-avto-price.objsecond      =  p-ie-objsecond
  temp-avto-price.pr-nakl        =  p-ie-pr-nakl
.

create temp-avto-price.
assign
  temp-avto-price.nn             =  2
  temp-avto-price.ext-doc-type   =  "Внутр.перемещение"
  temp-avto-price.gen-marg       =  p-iv-gen-marg
  temp-avto-price.gen-marg-parts =  p-iv-gen-marg-parts
  temp-avto-price.objfirst       =  p-iv-objfirst
  temp-avto-price.objsecond      =  p-iv-objsecond
  temp-avto-price.pr-nakl        =  p-iv-pr-nakl
.

create temp-avto-price.
assign
  temp-avto-price.nn             =  3
  temp-avto-price.ext-doc-type   =  "Производство"
  temp-avto-price.gen-marg       =  p-im-gen-marg
  temp-avto-price.gen-marg-parts =  p-im-gen-marg-parts
  temp-avto-price.objfirst       =  p-im-objfirst
  temp-avto-price.objsecond      =  p-im-objsecond
  temp-avto-price.pr-nakl        =  p-im-pr-nakl
.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mode_add-init Dialog-Frame
PROCEDURE mode_add-init :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
disable r-rod-price-type    with frame {&frame-name}  .
disable loc_under-hand-corr with frame {&frame-name}  .
hide    r-rod-price-type
        loc_under-hand-corr
        loc_plt-main-id
        in frame {&frame-name}  .

disable r-qnty-grp          with frame page-1  .
disable r-qnty-sgr          with frame page-1  .

if loc_use-obj = 1 then do:
  disable r-gop with frame page-2 .
end.
else do:
  enable r-gop with frame page-2 .
end.

disable loc_obj-turnover    with frame page-2 .
disable r-gop-calc          with frame page-2 .
disable r-gop-2             with frame page-2 .
disable r-qnty-tog          with frame page-2 .

define variable loc_exch-rate  as decimal   no-undo .
define variable loc_exch-scale as decimal   no-undo .

if loc_curr-code:modified = false  then do:
  { gbl/r-b-curr.i v-cntxt-host-code-obj loc_curr-code }
end.

{ gbl/exchrate.i
  loc_curr-code
  today
  loc_exch-rate
  loc_exch-scale
  loc_abbr-doc }
  display loc_curr-code
          loc_abbr-doc
          with frame Dialog-Frame .
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
define variable g-log as logical   no-undo .
  if p-mode = {&add-def} or  p-mode = {&lookup} then do:
     run all-mode.
  end.
  if p-mode = {&lookup} then do:
     run my_lookup in this-procedure .
  end.

  if p-mode <> {&add-def} then do:
  find ub.price-list-type no-lock where recid(ub.price-list-type) =  p-recid no-error .
    /* не изменяется после добавления */
      disable
        r-cur
        loc_work-date
        loc_fix-cource-crc-doc
        with frame {&frame-name}
        .
      disable
        loc_under-type-list
        r-rod-price-type
        loc_under-hand-corr          WHEN loc_under-type-list = false
        with frame {&frame-name}
        .
       if  loc_under-type-list = false then do:
            hide
              loc_plt-main-id
              r-rod-price-type
              loc_under-hand-corr
              in frame {&frame-name}
              .
       end.
       else do:
         HIDE v-3 IN FRAME page-3 .
         HIDE {&list-3} IN FRAME page-3 .
         HIDE v-1 IN FRAME page-1 .
         HIDE {&list-1} IN FRAME page-1 .
         hide frame page-1  frame page-3  .
         hide  button-1 label-button-1 in frame {&frame-name} .
         hide  button-3 label-button-3
               loc_fix-cource-crc-base
               loc_fix-cource-crc-doc
               loc_ban-discnt
               loc_only-gbd
               loc_calc-method
         in frame {&frame-name} .
         loc_calc-increase-pc:label = "% наценки от родителя" .
         loc_calc-round-method:label = "Метод округления"     .
         APPLY "CHOOSE":U TO BUTTON-2 .
       end.

      disable
        loc_have-rs-qnty-group
        r-qnty-grp
        loc_have-rs-sum-group
        r-qnty-sgr
        loc_have-rs-turn-group
        r-have-tog
        with frame page-1
      .
      /*
      disable
        r-gop
        loc_rs-buyer
        loc_use-obj
        with frame page-2
        .
        */
    if ub.price-list-type.rs-buyer = 2 then do: /*оборот */
       disable r-gop-2 with frame page-2 .
    end.
    if ub.price-list-type.rs-buyer = 1 then do: /* группа  */
       disable r-qnty-tog   loc_obj-turnover  r-gop-calc with frame page-2 .
    end.
    if ub.price-list-type.rs-buyer = 0 then do: /* все */
       disable r-gop-2 r-qnty-tog   loc_obj-turnover  r-gop-calc with frame page-2.
    end.
    if ub.price-list-type.use-obj = 1 then do: /* все */
       disable r-gop with frame page-2.
    end.
    if ub.price-list-type.obj-turnover = false   then do:
       disable r-gop-calc with frame page-2 .
    end.

    run all-mode.

    /* Недоступны если тип  главный */
  end.

  if ( p-mode <> {&add-def} and ub.price-list-type.main = true ) or ( p-mode = {&add-def} and  p-main-price = true ) THEN DO:

      HIDE v-1 IN FRAME page-1
          {&list-1} IN FRAME page-1
          .
      HIDE    v-2 IN FRAME page-2
          loc_bgr_name
          loc_bgr-db-num
          loc_bgr-id
          loc_tog-id
          loc_gop_name-tnv
          loc_gop-db-num-for-calc-turnover
          loc_obj-turnover
          loc_rs-buyer
          loc_tog_name
          loc_tog-db-num
          loc_use-cassa
          loc_use-cassa_FILL-IN
          r-FILL-IN
          r-obj-fill-in
          r-gop-2
          r-gop-calc
          r-qnty-tog
          v-spis-kass

          .
       HIDE   v-3 IN FRAME page-3
       {&list-3}
       IN FRAME page-3
       .
       HIDE
          loc_fix-cource-crc-doc   in frame {&frame-name}
          loc_fix-cource-crc-base  in frame {&frame-name}
          r-cur
          loc_priority
          button-1
          label-button-1
          button-2
          label-button-2
          button-3
          label-button-3
          RECT-1
          loc_under-type-list
          in frame {&frame-name} .

          g-log = loc_work-date:disable(radio-label("3", loc_work-date:radio-buttons)).
          g-log = loc_work-date:disable(radio-label("2", loc_work-date:radio-buttons)).
  END.
  run vis-bin .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my_lookup Dialog-Frame
PROCEDURE my_lookup :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  disable  {&assign-1}  WITH FRAME page-1.
  disable  {&assign-2} {&list-2} WITH FRAME page-2.
  disable  {&assign-3}  WITH FRAME page-3.
  disable  {&assign-0}  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  if p-main-price = true  then  VIEW FRAME page-2.
  hide B-save in frame {&frame-name} .
  B-Cancel:label in frame {&frame-name}  = "Выход" .
  B-Cancel:column in frame {&frame-name}  = 1 .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE noavtoper Dialog-Frame
PROCEDURE noavtoper :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
hide br-tt
in frame page-2
b-chga
in frame page-2
.
/*
hide loc_ie-gen-marg in frame page-2 f-ie f-ie-3 loc_ie-objsecond f-ie-2 loc_ie-pr-nakl loc_ie-objfirst  f-ie-1  in frame page-2  .
hide loc_iv-gen-marg in frame page-2 f-iv f-iv-3 loc_iv-objsecond f-iv-2 loc_iv-pr-nakl loc_iv-objfirst  f-iv-1  in frame page-2  .
hide loc_im-gen-marg in frame page-2 f-im f-im-3 loc_im-objsecond f-im-2 loc_im-pr-nakl loc_im-objfirst  f-im-1  in frame page-2  .
*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE runav Dialog-Frame
PROCEDURE runav :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  IF  loc_only-gbd
  THEN RUN avtoper .
  ELSE RUN noavtoper .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-proc Dialog-Frame
PROCEDURE save-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_cash-pay for ub.cash-pay  .

assign frame page-1 {&assign-1} no-error .
if error-status :error then do:
   return error "page-1":U .
end.
if (loc_have-rs-sum-group   and loc_have-rs-turn-group )
                            or
   (loc_have-rs-qnty-group  and loc_have-rs-sum-group  )
                            or
   (loc_have-rs-qnty-group  and loc_have-rs-turn-group ) then do:
   message "Неверно задана привязка " view-as alert-box error .
   return error "Выбрать одну привязку!".
   end.

ASSIGN FRAME PAGE-2 {&assign-2} no-error .
if error-status :error then do:
   return error "page-2":U .
end.

ASSIGN FRAME PAGE-3 {&assign-3} no-error .
if error-status :error then do:
   return error "page-3":U .
end.

ASSIGN frame {&frame-name} {&assign-0}.

define buffer ch_price-list-type for ub.price-list-type  . /* ребенок  */
define buffer pr_price-list-type for ub.price-list-type  . /* родитель */
find first pr_price-list-type no-lock where
           pr_price-list-type.stts            = integer({&pdf-new}) and
           pr_price-list-type.plt-main-id     = loc_plt-id     and
           pr_price-list-type.plt-main-db-num = loc_plt-db-num no-error .

  define variable v-is-mmr as character no-undo .
  define variable par-type as character no-undo .
  define variable v-cntxt-valid           as logical   no-undo .
  define variable v-cntxt-menu-code       as integer   no-undo .
  define variable v-cntxt-menu-group-code as integer   no-undo .
  define variable v-cntxt-level           as character no-undo .
  define variable v-cntxt-host-code-obj   as integer   no-undo .
  define variable v-cntxt-obj-type        as character no-undo .
  define variable v-cntxt-obj-code        as integer   no-undo .
  define variable g#log                   as logical   no-undo .

  if p-mode = {&update} and loc_use-obj = 1 then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_documents_all':U
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      false
      g#log
    }
    if not g#log then do:
        message "Функция назначения цен на все объекты для данного пользователя запрещена !  Выберите группу объектов ценообразования . "
        view-as alert-box information .
        return error .
    end.
  end.


    { gbl/conf-rd.i
      "'is-mmr':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      no
      v-is-mmr
      par-type
      no-error
    }
    if  error-status :error then v-is-mmr = 'no' .
    if loc_use-obj = 1 /* все */  and v-is-mmr = 'yes' /* разрешен МИНИМАРКЕТ */  then do:
      run gbl/cntxtget.p (
           INPUT  v-cntxt-db-num
         , INPUT  v-cntxt-userid
         , OUTPUT v-cntxt-valid
         , OUTPUT v-cntxt-menu-code
         , OUTPUT v-cntxt-menu-group-code
         , OUTPUT v-cntxt-level
         , OUTPUT v-cntxt-host-code-obj
         , OUTPUT v-cntxt-obj-type
         , OUTPUT v-cntxt-obj-code
      ).
      if v-cntxt-menu-group-code = 5 /*текущий АРМ - МИНИМАРКЕТ*/ then do :
        message "Функция назначения цен на все объекты в Минимаркете запрещена !  Выберите группу объектов ценообразования . "
        view-as alert-box information .
        return error .
      end.
    end.


/* ГПЛ */
if p-main-price = true and loc_only-gbd = true
then do:

    if loc_use-obj = 1 /* все */   then do:
        message "Главный прайс-лист не может быть по всем объектам ценообразования !" view-as alert-box information .
        return error .
    end.
define variable vv-obj-db-num as integer   no-undo .
define variable s-vv as character no-undo .
define variable i as integer   no-undo .

run metod-gop-obj in this-procedure ( v-cntxt-db-num , loc_gop-id , loc_gop-db-num) .
/*

объекты разных баз данных  ЗАКРЫТО

s-vv = "" .
  for each x_obj-group :
          { gbl/objdbnum.i
            x_obj-group.obj-type
            x_obj-group.obj-code
            vv-obj-db-num
            }
      s-vv = s-vv + string(vv-obj-db-num) + "," .
  end.


  s-vv = trim(s-vv,",") .
  repeat i = 1 to num-entries(s-vv):
     if vv-obj-db-num <> int(entry(i,s-vv)) then do:

        message
          "В главном прайс-листе не могут быть объекты разных баз данных ! "
          view-as alert-box error .
          return error .

     end.
  end.
  */

/*Проверка для ГПЛ пересечения по объектам  если для автопереоценок*/


define variable locs-plt-id     as integer   no-undo .
define variable locs-plt-db-num as integer   no-undo .
define variable v-err           as logical   no-undo .
define variable v-n             as character no-undo .

define buffer old1_price-list-type for ub.price-list-type  .
define variable v-col-tp as integer   no-undo .
define variable v-ii-o   as integer   no-undo .
v-err = false .
v-ii-o = 0    .
for each x_obj-group where

:
v-ii-o = v-ii-o + 1   .
 { gbl/gtplobjq.i
  x_obj-group.obj-type
  x_obj-group.obj-code
  locs-plt-id
  locs-plt-db-num
  v-col-tp
  no-error }
  if error-status :error then do:
     v-err = true .
     leave .
  end.

  if v-col-tp > 0 and not (
      locs-plt-id     = loc_plt-id      and
      locs-plt-db-num = loc_plt-db-num
      ) then do:
     find first old1_price-list-type no-lock where
                old1_price-list-type.plt-id     = locs-plt-id and
                old1_price-list-type.plt-db-num = locs-plt-db-num
     no-error .
     if error-status :error then do:
       v-n = ''.
     end.
     else do:
       v-n = old1_price-list-type.name .
     end.

     message substitute ( "Для объекта &1 &2 уже есть ГТПЛ для автопереоценок &3(&4) &5" , x_obj-group.obj-code , x_obj-group.obj-type , locs-plt-id , locs-plt-db-num , v-n ) view-as alert-box error  .
     v-err = true .
     leave .
  end.
end.

if v-ii-o = 0  then do:
   message "В выбранной группе нет ни одного объекта !"  view-as alert-box information .
   return error .
end.
  if error-status :error or v-err = true  then return error .
  run avts.



end.
/* Скидки */
if p-main-price = true  then do:
   if loc_send-cassa = 2 or loc_create-price-doc = 2 then do:
      message substitute ( "По главному типу прайс-листов должны создаваться переоценки и цены уходить на кассу" ) view-as alert-box error  .
      return error.
   end.
end.
else do:
   if loc_send-cassa = 1  and loc_ban-discnt = 0   then do:
      message substitute ( "На кассу по неглавному ТПЛ можно отправлять только СКИДКИ!  (установите номер шаблона скидки или поле <<ОТПРАВЛЯТЬ НА КАССЫ>> установите нет)  " ) view-as alert-box error  .
      return error.
   end.
   if loc_send-cassa = 2  and loc_ban-discnt > 0   then do:
      message substitute ( "Если установлено правило скидки, то его надо отправлять на кассы ! " ) view-as alert-box error  .
      return error.
   end.
end.



/*  ребенок  */
if p-main-price = true and loc_under-type-list = true then do:
   if loc_use-obj = 1 /* все */   then do:
      message "Подчиненный прайс-лист по ГПЛ не может быть по всем объектам ценообразования !" view-as alert-box information .
      return error .
   end.
   else do:
      /* остальные дети и родитель */
      if can-find ( first ch_price-list-type no-lock where
                    ch_price-list-type.stts            = integer({&pdf-new}) and
                    ch_price-list-type.plt-main-id     = loc_plt-main-id and
                    ch_price-list-type.plt-main-db-num = loc_plt-main-db-num and
                    ch_price-list-type.gop-id          = loc_gop-id and
                    ch_price-list-type.gop-db-num      = loc_gop-db-num and
                not (ch_price-list-type.plt-id         = loc_plt-id and
                     ch_price-list-type.plt-db-num     = loc_plt-db-num )
                    )
                    then do:
                      message substitute ( "Уже есть прайс-лист с группой объектов № &1 БД &2" , loc_gop-id , loc_gop-db-num ) view-as alert-box information .
                      return error.
                    end.
   end.
end.
/* родитель */
if p-main-price = true and loc_under-type-list = false
   and can-find ( first ch_price-list-type no-lock where
                  ch_price-list-type.stts            = integer({&pdf-new}) and
                  ch_price-list-type.plt-main-id     = loc_plt-id and
                  ch_price-list-type.plt-main-db-num = loc_plt-db-num and
                not ( ch_price-list-type.plt-id      = loc_plt-id and
                      ch_price-list-type.plt-db-num  = loc_plt-db-num )
                  )
   then do:
      if loc_use-obj = 1 /* все */   then do:
          message "Родительский прайс-лист по ГПЛ не может быть по всем объектам ценообразования !" view-as alert-box information .
          return error .
      end.
      else do:
            if can-find ( first ch_price-list-type no-lock where
                    ch_price-list-type.stts            = integer({&pdf-new}) and
                    ch_price-list-type.plt-main-id     = loc_plt-id and
                    ch_price-list-type.plt-main-db-num = loc_plt-db-num and
                    ch_price-list-type.gop-id          = loc_gop-id and
                    ch_price-list-type.gop-db-num      = loc_gop-db-num and
                not (ch_price-list-type.plt-id     = loc_plt-id and
                     ch_price-list-type.plt-db-num = loc_plt-db-num )
                    ) then do:
                    message "Нельзя менять ГТПЛ, у которого есть подчиненные ТПЛ" view-as alert-box information .
/*                    substitute("Уже есть прайс-лист с группой объектов № &1 БД &2" , loc_gop-id , loc_gop-db-num)*/
                    return error.
                    end.
      end.
end.


/* не ГПЛ  */
/* ребенок */
if p-main-price = false and loc_under-type-list = true then do:
  if loc_use-obj = 1 and loc_rs-buyer = 0 then do:
     message "В сочетании параметров <все объекты> и <все группы покупателей> нельзя создавать подчиненый прайс-лист, так как нет вариантов отличия "  view-as alert-box information .
     return error.
  end.
end.
/* родитель */
if p-main-price = false and loc_under-type-list = false
   and can-find ( first ch_price-list-type no-lock where
                  ch_price-list-type.stts            = integer({&pdf-new}) and
                  ch_price-list-type.plt-main-id     = loc_plt-id and
                  ch_price-list-type.plt-main-db-num = loc_plt-db-num and
            not (ch_price-list-type.plt-id     = loc_plt-id and
                  ch_price-list-type.plt-db-num = loc_plt-db-num )
                  )
then do:
  if loc_use-obj = 1 and loc_rs-buyer = 0 then do:
     message "В сочетании параметров <все объекты> и <все группы покупателей> нельзя создавать подчиненый прайс-лист, так как нет вариантов отличия "   view-as alert-box information .
     return error.
  end.
end.


/*  ребенок  */
if p-main-price = false  and loc_under-type-list = true then do:
  /* остальные дети и родитель */
  find first ch_price-list-type no-lock where
                ch_price-list-type.stts            = integer({&pdf-new}) and
                ch_price-list-type.plt-main-id     = loc_plt-main-id and
                ch_price-list-type.plt-main-db-num = loc_plt-main-db-num and
                ch_price-list-type.gop-id          = loc_gop-id and
                ch_price-list-type.gop-db-num      = loc_gop-db-num  and
                ch_price-list-type.bgr-id          = loc_bgr-id and
                ch_price-list-type.bgr-db-num      = loc_bgr-db-num  and
                ch_price-list-type.tog-id          = loc_tog-id and
                ch_price-list-type.tog-db-num      = loc_tog-db-num  and
                not (ch_price-list-type.plt-id     = loc_plt-id and
                     ch_price-list-type.plt-db-num = loc_plt-db-num )
                 no-error .
                if available ch_price-list-type then do:

                    message "Уже есть прайс-лист № " ch_price-list-type.plt-id "/" ch_price-list-type.plt-db-num skip
                    "с таким же набором параметров :"  skip
                    'Родительский прайс-лист:' loc_plt-main-id "/" loc_plt-main-db-num skip
                    'группа объектов    :' loc_gop-id "/"  loc_gop-db-num skip
                    'группа покупателей :' loc_bgr-id "/"  loc_bgr-db-num skip
                    'группа оборотов    :' loc_tog-id "/"  loc_tog-db-num
                    view-as alert-box information .

                    return error.
                end.
end.

/* родитель */
if p-main-price = false and loc_under-type-list = false
   and can-find ( first ch_price-list-type no-lock where
                  ch_price-list-type.stts            = integer({&pdf-new}) and
                  ch_price-list-type.plt-main-id     = loc_plt-id and
                  ch_price-list-type.plt-main-db-num = loc_plt-db-num )
then do:
  if can-find ( first ch_price-list-type no-lock where
                ch_price-list-type.stts            = integer({&pdf-new}) and
                ch_price-list-type.plt-main-id     = loc_plt-id and
                ch_price-list-type.plt-main-db-num = loc_plt-db-num and
                ch_price-list-type.gop-id          = loc_gop-id and
                ch_price-list-type.gop-db-num      = loc_gop-db-num  and
                ch_price-list-type.bgr-id          = loc_bgr-id and
                ch_price-list-type.bgr-db-num      = loc_bgr-db-num  and
                ch_price-list-type.tog-id          = loc_tog-id and
                ch_price-list-type.tog-db-num      = loc_tog-db-num and
                not (ch_price-list-type.plt-id     = loc_plt-id and
                     ch_price-list-type.plt-db-num = loc_plt-db-num )

                ) then do:
                    message "Уже есть прайс-лист с таким же набором параметров" view-as alert-box information .
                    return error.
                end.
end.

run avtosave in this-procedure
  (  loc_plt-id
  ,  loc_plt-db-num
  ,  loc_ie-gen-marg
  ,  loc_ie-gen-marg-parts
  ,  loc_ie-objfirst
  ,  loc_ie-objsecond
  ,  loc_ie-pr-nakl
  ,  loc_iv-gen-marg
  ,  loc_iv-gen-marg-parts
  ,  loc_iv-objfirst
  ,  loc_iv-objsecond
  ,  loc_iv-pr-nakl
  ,  loc_im-gen-marg
  ,  loc_im-gen-marg-parts
  ,  loc_im-objfirst
  ,  loc_im-objsecond
  ,  loc_im-pr-nakl   ) .

define buffer buf2_price-list-type   for ub.price-list-type  .
define buffer buf2_price-doc-forming for ub.price-doc-forming  .

if p-mode <> {&lookup} then do:
/* Если ребенок , спустим ему родительские настройки */
if loc_under-type-list = true and available pr_price-list-type then do:

    assign
        loc_calc-method         = pr_price-list-type.calc-method
        loc_create-price-doc    = pr_price-list-type.create-price-doc
        loc_fix-cource-crc-base = pr_price-list-type.fix-cource-crc-base
        loc_fix-cource-crc-doc  = pr_price-list-type.fix-cource-crc-doc
        loc_have-rs-qnty-group  = logical(pr_price-list-type.have-rs-qnty-group)
        loc_have-rs-sum-group   = pr_price-list-type.have-rs-sum-group
        loc_only-gbd            = logical(pr_price-list-type.only-gbd)
        loc_priority            = pr_price-list-type.priority
        loc_send-cassa          = pr_price-list-type.send-cassa
        loc_use-cassa           = pr_price-list-type.use-cassa
        loc_work-date           = pr_price-list-type.work-date
        loc_curr-code           = pr_price-list-type.curr-code
        loc_qgr-db-num          = pr_price-list-type.qgr-db-num
        loc_qgr-id              = pr_price-list-type.qgr-id
        loc_sgr-db-num          = pr_price-list-type.sgr-db-num
        loc_sgr-id              = pr_price-list-type.sgr-id
        loc_have-rs-turn-group  = logical(pr_price-list-type.have-rs-turn-group)
        loc_have-tog-db-num     = pr_price-list-type.have-tog-db-num
        loc_have-tog-id         = pr_price-list-type.have-tog-id
        loc_use-cash-pay        = logical(pr_price-list-type.use-cash-pay)
        loc_use-pay-type        = logical(pr_price-list-type.use-pay-type)
        .
end.
        /* Изменение группы покупателей */
        if  p-mode = {&update} and loc_priority > 0 and p-main-price = false  then do:
            if can-find ( first buf2_price-list-type no-lock where
                  buf2_price-list-type.main = false  and
                  buf2_price-list-type.stts = integer({&pdf-new})      and
                  buf2_price-list-type.plt-db-num = loc_plt-db-num and
                  buf2_price-list-type.plt-id     = loc_plt-id  and
                  not (
                      buf2_price-list-type.bgr-id     = loc_bgr-id and
                      buf2_price-list-type.bgr-db-num = loc_bgr-db-num ))
                  then do:
                      find first buf2_price-doc-forming no-lock where
                            buf2_price-doc-forming.plt-db-num = loc_plt-db-num and
                            buf2_price-doc-forming.plt-id     = loc_plt-id     and
                            buf2_price-doc-forming.stts       = integer({&pdf-fact})
                            no-error .
                            /* есть закрытые прайс-листы */
                            if available buf2_price-doc-forming then do:
                              message "Изменилась группа покупателей в  ТИПе ПРАЙС-ЛИСТА !" skip
                              "ДА - изменить группу покупателей у действующих цен "      skip
                              "НЕТ - изменить группу покупателей только у новых цен "           skip
                              view-as alert-box question
                              buttons yes-no
                              update v-ok_bgr as logical.
                            end.
                  end.

        end.
       /* изменение приоритета ТПЛ */
        if  p-mode = {&update} and loc_priority > 0 and p-main-price = false  then do:
            if can-find ( first buf2_price-list-type no-lock where
                  buf2_price-list-type.priority <> loc_priority and
                  buf2_price-list-type.main = false  and
                  buf2_price-list-type.stts = integer({&pdf-new})      and
                  buf2_price-list-type.plt-db-num = loc_plt-db-num and
                  buf2_price-list-type.plt-id     = loc_plt-id )
                  then do:
                      find first buf2_price-doc-forming no-lock where
                            buf2_price-doc-forming.plt-db-num = loc_plt-db-num and
                            buf2_price-doc-forming.plt-id     = loc_plt-id     and
                            buf2_price-doc-forming.stts       = integer({&pdf-fact})
                            no-error .
                            /* есть закрытые прайс-листы */
                            if available buf2_price-doc-forming then do:
                              message "Изменился приоритет  ТИПА ПРАЙС-ЛИСТА !" skip
                              "ДА - изменить приоритет у действующих цен "      skip
                              "НЕТ - изменить приоритет у новых цен "           skip
                              view-as alert-box question
                              buttons yes-no
                              update v-ok as logical.
                            end.
                  end.
        end.
/* Проверка валюты типов кассовых платежей и видов оплат */
if loc_use-cash-pay then do:
 for each TT_price-list-type-cash-pay :
      if TT_price-list-type-cash-pay.curr-code <> loc_curr-code then do:
         find first buf_cash-pay no-lock where
                    buf_cash-pay.curr-code  = TT_price-list-type-cash-pay.curr-code and
                    buf_cash-pay.cdpay-code = TT_price-list-type-cash-pay.cdpay-code no-error .
         if error-status :error then do:
            message error-status :get-message(1) .
            return error return-value .
         end.
         message 'Платеж' buf_cash-pay.obj-name
         "Не соответствует валюте прайс-листа"
         view-as alert-box error .
         return error return-value .
      end.
 end.
end.
/* Проверка выбора объектов */
if loc_use-obj = 1 then do:
   message "Прайс-лист задан по ВСЕМ объектам ценообразования !" skip
     "Вы уверены ?"
     view-as alert-box question
     buttons yes-no
     title "Внимание !!!"
     update vv as log
    .
    if vv = false then return error return-value .
end.
else do:
 find first ub.grp-obj-price where
            ub.grp-obj-price.gop-db-num = loc_gop-db-num and
            ub.grp-obj-price.gop-id     = loc_gop-id
            no-lock no-error .
  if not available  ub.grp-obj-price  then do:
     message "Группа объектов не найдена "  view-as alert-box information .
     return error.
  end.
  if ub.grp-obj-price.stts = 1  then do:
        message "Группа объектов удалена" view-as alert-box error .
        return error  .
  end.
end.

/* связь с количественной группой */
if loc_have-rs-qnty-group then do:
 find first ub.qnty-group where
            ub.qnty-group.qgr-db-num = loc_qgr-db-num  and
            ub.qnty-group.qgr-id     = loc_qgr-id
            no-lock no-error .
    if error-status :error then do:
        message "Не найдена количественная группа" view-as alert-box error .
        return error  .
    end.
    if ub.qnty-group.stts = 1 then do:
        message "Количественная группа удалена" view-as alert-box error .
        return error  .
    end.
end.
else do:
   assign
    loc_qgr-id      = 0
    loc_qgr-db-num  = 0
   .
end.

/* связь с суммовой группой */
if loc_have-rs-sum-group then do:
 find first ub.sum-group where
            ub.sum-group.sgr-db-num = loc_sgr-db-num  and
            ub.sum-group.sgr-id     = loc_sgr-id
            no-lock no-error .
    if error-status :error then do:
        message "Не найдена суммовая группа" view-as alert-box error .
        return error  .
    end.
    if ub.sum-group.stts = 1 then do:
        message "Суммовая группа удалена" view-as alert-box error .
        return error  .
    end.
end.
else do:
   assign
    loc_sgr-id      = 0
    loc_sgr-db-num  = 0
   .
end.

/* связь с оборотной группой */
if loc_have-rs-turn-group then do:
 find first ub.turnover-group where
            ub.turnover-group.tog-db-num = loc_have-tog-db-num   and
            ub.turnover-group.tog-id     = loc_have-tog-id
            no-lock no-error .
    if error-status :error then do:
        message "Не найдена суммовая группа" view-as alert-box error .
        return error  .
    end.
    if ub.turnover-group.stts = 1 then do:
        message "Суммовая группа удалена" view-as alert-box error .
        return error  .
    end.
end.
else do:
   assign
    loc_have-tog-id      = 0
    loc_have-tog-db-num  = 0
   .
end.



 run type-price-list-add (
            ( if p-mode = {&add-def} then  v-cntxt-db-num                        else loc_plt-db-num )
          , ( if p-mode = {&add-def} then  next-value (s-plt, {&db-name_schema}) else loc_plt-id   )
          , loc_name
          , loc_ban-discnt
          , loc_calc-round-method
          , loc_calc-round-base
          , loc_calc-increase-pc
          , loc_calc-method
          , loc_create-price-doc
          , loc_fix-cource-crc-base
          , loc_fix-cource-crc-doc
          , integer (loc_have-rs-qnty-group)
          , loc_have-rs-sum-group
          , p-main-price
          , integer (loc_only-gbd)
          , loc_plt-main-db-num
          , loc_plt-main-id
          , loc_priority
          , loc_rs-buyer
          , loc_send-cassa
          , integer (loc_under-hand-corr)
          , loc_under-round-method
          , loc_under-perc
          , integer (loc_under-type-list)
          , loc_use-cassa
          , integer (loc_use-gds-group)
          , loc_use-obj
          , loc_work-date
          , loc_bgr-db-num
          , loc_bgr-id
          , loc_curr-code
          , loc_gop-db-num
          , loc_gop-db-num-for-calc-turnover
          , loc_gop-id
          , loc_gop-id-for-calc-turnover
          , loc_qgr-db-num
          , loc_qgr-id
          , loc_sgr-db-num
          , loc_sgr-id
          , loc_tog-db-num
          , loc_tog-id
          , loc_obj-turnover
          , 0
          , v-cntxt-userid
          , v-cntxt-db-num
          , integer (loc_have-rs-turn-group)
          , loc_have-tog-db-num
          , loc_have-tog-id
          , integer (loc_use-cash-pay )
          , integer (loc_use-pay-type )

          , output  p-recid

          , input table TT_price-list-type-cassa
          , input table TT_price-list-type-gds-grp
          , input table TT_price-list-type-pay-type
          , input table TT_price-list-type-cash-pay
          ) no-error .
          if error-status :error then do:
              message
                error-status :get-message(1) skip
                return-value skip
                "Ошибка ввода"
                view-as alert-box error
              .
              return error.
          end.


        if v-ok or v-ok_bgr then do:
        if not transaction then do:
            run waitfram-show in this-procedure ("Изменение действующих цен...") .
            for each ub.price-all exclusive-lock where
                ub.price-all.plt-db-num = loc_plt-db-num and
                ub.price-all.plt-id     = loc_plt-id
                :
                if ub.price-all.plt-priority <> loc_priority   and v-ok     then ub.price-all.plt-priority = loc_priority   .
                if ub.price-all.bgr-id       <> loc_bgr-id     and v-ok_bgr then ub.price-all.bgr-id       = loc_bgr-id     .
                if ub.price-all.bgr-db-num   <> loc_bgr-db-num and v-ok_bgr then ub.price-all.bgr-db-num   = loc_bgr-db-num .
            end.
            run waitfram-hide in this-procedure  .
            end.
            else do:
               message "Нельзя выполнить массовое обновление в одной транзакции. Воспользуйтесь утилитой смены значений ТПЛ !" view-as alert-box information .
            end.
        end.
 end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tog-band Dialog-Frame
PROCEDURE tog-band :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  if l-ban-discnt = true then do:
     display
     loc_ban-discnt
     r-ban-discnt
     f-ban-discnt
     b-ban-discnt
     l-ban-discnt
     with frame {&frame-name} .

  end.
  else do:
    loc_ban-discnt = 0 .
     display
     loc_ban-discnt
     r-ban-discnt
     f-ban-discnt
     b-ban-discnt
     l-ban-discnt
     with frame {&frame-name} .

  hide
     loc_ban-discnt
     r-ban-discnt
     f-ban-discnt
     b-ban-discnt
     in frame {&frame-name} .

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE vis-bin Dialog-Frame
PROCEDURE vis-bin :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

if loc_have-tog-id               = 0  then hide b-have-tog in frame page-1 loc_have-tog-db-num                . else do: enable   b-have-tog with frame page-1 . display loc_have-tog-db-num              with frame page-1 . end.
if loc_qgr-id                    = 0  then hide b-qnty-grp in frame page-1 loc_qgr-db-num                     . else do: enable   b-qnty-grp with frame page-1 . display loc_qgr-db-num                   with frame page-1 . end.
if loc_sgr-id                    = 0  then hide b-qnty-sgr in frame page-1 loc_sgr-db-num                     . else do: enable   b-qnty-sgr with frame page-1 . display loc_sgr-db-num                   with frame page-1 . end.
if loc_gop-id                    = 0  then hide b-gop      in frame page-2 loc_gop-db-num                     . else do: enable   b-gop      with frame page-2 . display loc_gop-db-num                   with frame page-2 . end.
if loc_bgr-id                    = 0  then hide b-gop-2    in frame page-2 loc_bgr-db-num                     . else do: enable   b-gop-2    with frame page-2 . display loc_bgr-db-num                   with frame page-2 . end.
if loc_gop-id-for-calc-turnover  = 0  then hide b-gop-calc in frame page-2 loc_gop-db-num-for-calc-turnover   . else do: enable   b-gop-calc with frame page-2 . display loc_gop-db-num-for-calc-turnover with frame page-2 . end.
if loc_tog-id                    = 0  then hide b-qnty-tog in frame page-2 loc_tog-db-num                     . else do: enable   b-qnty-tog with frame page-2 . display loc_tog-db-num                   with frame page-2 . end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME