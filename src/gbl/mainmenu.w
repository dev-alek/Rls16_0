&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Главное окно IBS Trade House

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/06/09
Author: Dmitry Ukhanov
Creation date: 10/06/09

Автор2: Белоусов Илья Александрович
Дата создания2: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/04/06

*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input  parameter p-process-pid as integer   no-undo .
define input  parameter p-user-id     as character no-undo .
define input  parameter p-password    as character no-undo .

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Главное окно IBS Trade House".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/color.i    }
{ str/libbcrcn.i }
{ gbl/cur-time.i }
{ cmp/t-tnved.i  new }
{ cmp/r-pril.i   }
{ gbl/waitfram.i noprocess  }
{ gbl/usrnickf.i }
{ gbl/thbj-def.i }
{ gbl/godendo.i  }
{ gbl/mainproc.i def }
{ gbl/db-attr.i  }
{ str/placelib.i }
{ str/is-gas.i }

&scoped-define open-mark   chr(187)
&scoped-define close-mark   chr(171)
&scoped-define terminal-mark chr(149)

define variable v-cntxt-developer              as logical   no-undo .
define variable v-cntxt-db-num                 as integer   no-undo .
define variable v-cntxt-user-id                as character no-undo .
define variable v-cntxt-process-id             as integer   no-undo .
define variable v-cntxt-password               as character no-undo .
define variable v-cntxt-level                  as character no-undo .
define variable v-cntxt-host-code-obj          as integer   no-undo .
define variable v-cntxt-obj-type               as character no-undo .
define variable v-cntxt-obj-code               as integer   no-undo .
define variable v-cntxt-db-num-obj             as integer   no-undo .
define variable v-cntxt-menu-code              as integer   no-undo .
define variable v-cntxt-menu-group-code        as integer   no-undo .
define variable v-cntxt-previous-menu-group-id as character no-undo .
define variable v-cntxt-report-num             as integer   no-undo .
define variable v-cntxt-quest-print            as logical   no-undo .
define variable v-cntxt-inp-jewel              as logical   no-undo .
define variable v-cntxt-gds-engl               as logical   no-undo .
define variable v-cntxt-bc-price               as logical   no-undo .
define variable v-cntxt-is-admin               as logical   no-undo .
define variable g#dm-menu-handle               as handle    no-undo .
define variable v-menu-control-number          as character no-undo.
define variable parparentproc                  as widget-handle       no-undo.
DEFINE VARIABLE fi-menu-group-name AS CHARACTER no-undo.
define variable v-show-display-name as character format "x(60)" label "Меню" .
define variable v-logo-image-visible    as logical      no-undo.
define variable v-db-attr-value         as character    no-undo .
define variable v-db-attr-type          as character    no-undo .
define variable v-mess-id               as integer      no-undo .

define temp-table temp-menu-item no-undo
  field num-level      as integer
  field show-child     as character format "x(1)"  label " "
  field display-name   as character format "x(45)" label "Меню"
  field full-name      as character
  field item-code      as integer                  label "Номер"
  field item-type      as character
  field item-name      as character
  field item-id        as character
  field item-procedure as character
  field parent-code    as integer
  field show-menu-item as logical

  index xpk is primary unique item-code
  index xie1 show-menu-item item-code
  index xie2 parent-code item-code
  index i-name IS WORD-INDEX item-name
  .

define temp-table temp-menu-item-open no-undo
  field item-code as integer
  index xpk is primary unique item-code
  .

define temp-table temp-image no-undo
  field image-code          as integer
  field image-handle        as widget-handle
  field image-visible       as logical
  field image-procedure     as character
  field image-file-name     as character
  field image-sel-file-name as character
  field image-name          as character

  index xpk is primary unique image-code
  .

define temp-table temp-check-image no-undo
  field check-image-index               as integer
  field check-image-name                as character
  field check-image-context             as character
  field check-image-menu-group-id-list  as character
  field check-image-procedure-list      as character
  field check-image-visible-procedure   as character
  field check-image-image-procedure     as character
  field check-image-image-file-name     as character
  field check-image-image-name          as character

  index xpk is primary unique check-image-index
  index xie1 check-image-name
  .

define variable o-code      as integer   no-undo . /* код объекта - для переключения          */
define variable rid#        as recid     no-undo . /* фиктивный параметр для вызовов процедур */
define variable ri-list     as character no-undo . /* фиктивный параметр для вызовов процедур */
define variable tnved-fn    as character no-undo . /* имя файла для справочника ТНВЭД         */
define variable v-work-file as character no-undo .

define variable conf-par    as character no-undo . /* для чтения параметра конфигурации */
define variable par-type    as character no-undo . /* тип параметра конфигурации        */
define variable wth-type    as character no-undo . /* для чтения параметра конфигурации */

define variable v-obj-date  as date      no-undo .


define variable v-connect-usr          as integer   no-undo .
define variable v-connect-device       as character no-undo .
define variable v-userio-id            as integer   no-undo .
define variable v-menu-user-call-rowid as rowid     no-undo .
define variable v-userio-ai-read       as decimal   no-undo .
define variable v-userio-ai-write      as decimal   no-undo .
define variable v-userio-bi-read       as decimal   no-undo .
define variable v-userio-bi-write      as decimal   no-undo .
define variable v-userio-db-access     as decimal   no-undo .
define variable v-userio-db-read       as decimal   no-undo .
define variable v-userio-db-write      as decimal   no-undo .

define variable par-is-cctv as character no-undo .
define variable is-cctv     as logical   no-undo .
define variable v-vid-ok    as logical   no-undo .
define variable v-vid-mes   as character no-undo .
define variable v-vid-param as longchar  no-undo .

/* переменные для меню */
define variable menu-bar-handle    as widget-handle no-undo. /* указатель на widget menu */
define variable v-menu-item-choose as logical   no-undo .

define stream sinp .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DEFAULT-FRAME
&Scoped-define BROWSE-NAME br-menu-item

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-menu-item

/* Definitions for BROWSE br-menu-item                                  */
&Scoped-define FIELDS-IN-QUERY-br-menu-item get-display-name(buffer temp-menu-item) @ v-show-display-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-menu-item
&Scoped-define SELF-NAME br-menu-item
&Scoped-define OPEN-QUERY-br-menu-item /* OPEN QUERY br-menu-item FOR EACH temp-menu-item. */ run mainmenu-menu-item-open in this-procedure (input 0) .
&Scoped-define TABLES-IN-QUERY-br-menu-item temp-menu-item
&Scoped-define FIRST-TABLE-IN-QUERY-br-menu-item temp-menu-item


/* Definitions for FRAME DEFAULT-FRAME                                  */
&Scoped-define OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME ~
    ~{&OPEN-QUERY-br-menu-item}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rect-db-user rect-host-obj rect-image ~
IMAGE-1 IMAGE-2 IMAGE-3 IMAGE-4 IMAGE-5 IMAGE-6 IMAGE-7 IMAGE-8 IMAGE-9 ~
IMAGE-10 IMAGE-11 IMAGE-12 IMAGE-13 IMAGE-14 IMAGE-15 IMAGE-16 IMAGE-17 IMAGE-18 ~
IMAGE-19 IMAGE-20 IMAGE-21 IMAGE-22 IMAGE-23 IMAGE-24 IMAGE-25 IMAGE-26 ~
IMAGE-27 IMAGE-28 IMAGE-29 IMAGE-30 IMAGE-31 IMAGE-32 IMAGE-33 IMAGE-34 ~
IMAGE-35 IMAGE-36 IMAGE-37 IMAGE-38 IMAGE-39 RECT-1 rect-host-obj-2 ~
b-select-context ed-menu-item-name b-copy br-menu-item b-show-date ~
b-search-bar-code fi-bar-code b-open-gds fi-nickname fi-user-login ~
fi-obj-date fi-close-date fi-shift-date fi-shift-name fi-shift-order fi-obj ~
fi-host fi-host-basecode-desc fi-gds-artic fi-gds-name fi-gds-qnty ~
fi-gds-price-sale
&Scoped-Define DISPLAYED-OBJECTS ed-menu-item-name fi-user-name ~
t-obj-active fi-obj-description fi-host-description fi-menu-group-name ~
fi-nickname fi-user-login fi-obj-date fi-close-date fi-shift-date ~
fi-shift-name fi-shift-order fi-obj fi-host fi-host-basecode-desc

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-display-name C-Win
FUNCTION get-display-name RETURNS CHARACTER
  ( buffer buf_temp-menu-item for temp-menu-item )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-copy
     IMAGE-UP FILE "cmp/btn-copy.bmp":U
     LABEL "b-copy"
     SIZE 3 BY 1 TOOLTIP "Скопировать название пункта меню".

DEFINE BUTTON b-open-gds
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "b-copy"
     SIZE 3 BY 1 TOOLTIP "Показать подробную информацию о штрих-коде".

DEFINE BUTTON b-search-bar-code 
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     LABEL "b-copy"
     SIZE 3 BY 1 TOOLTIP "Показать подробную информацию о штрих-коде".

DEFINE BUTTON b-show-date 
     IMAGE-UP FILE "cmp/calend.bmp":U
     IMAGE-DOWN FILE "cmp/calend.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/calend.bmp":U
     LABEL "b-copy" 
     SIZE 2.5 BY .67 TOOLTIP "Показать дату на объекте".

DEFINE VARIABLE ed-menu-item-name AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 57.25 BY 2.33 NO-UNDO.

DEFINE VARIABLE fi-bar-code AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 30.25 BY .67 TOOLTIP "Штрих код" NO-UNDO.

DEFINE VARIABLE fi-close-date AS DATE FORMAT "99/99/9999":U 
     LABEL "Период" 
      VIEW-AS TEXT 
     SIZE 10 BY .67 TOOLTIP "Дата закрытия периода на объекте"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-db-num AS CHARACTER FORMAT "X(256)":U
     LABEL "БД"
      VIEW-AS TEXT
     SIZE 20 BY .67 TOOLTIP "База данных"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-gds-artic AS CHARACTER FORMAT "X(256)":U 
     LABEL "Артикул" 
      VIEW-AS TEXT 
     SIZE 32.63 BY .67 TOOLTIP "Артикул"
     FGCOLOR 4 .

DEFINE VARIABLE fi-gds-name AS CHARACTER FORMAT "X(256)":U 
     LABEL "Товар" 
      VIEW-AS TEXT 
     SIZE 34.75 BY .67 TOOLTIP "Наименование товара"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-gds-price-sale AS CHARACTER FORMAT "X(256)":U 
     LABEL "Цена" 
      VIEW-AS TEXT 
     SIZE 10 BY .67 TOOLTIP "Цена товара"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-gds-qnty AS CHARACTER FORMAT "X(256)":U 
     LABEL "Кол-во" 
      VIEW-AS TEXT 
     SIZE 10 BY .67 TOOLTIP "Количество товара"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-host AS CHARACTER FORMAT "X(256)":U
     LABEL "Фирма"
      VIEW-AS TEXT
     SIZE 13 BY .67 TOOLTIP "Фирма"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-host-basecode-desc AS CHARACTER FORMAT "X(3)":U
     LABEL "Баз.вал"
      VIEW-AS TEXT
     SIZE 5 BY .67 TOOLTIP "Фирма"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-host-description AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 41.63 BY .67 TOOLTIP "Фирма"
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE fi-nickname AS CHARACTER FORMAT "X(35)":U 
     LABEL "Псевдоним" 
      VIEW-AS TEXT 
     SIZE 30.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-obj AS CHARACTER FORMAT "X(256)":U
     LABEL "Объект"
      VIEW-AS TEXT
     SIZE 20 BY .67 TOOLTIP "Объект"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-obj-date AS DATE FORMAT "99/99/9999":U
     LABEL "Сегодня"
      VIEW-AS TEXT
     SIZE 11.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-obj-description AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 41.63 BY .67 TOOLTIP "Фирма"
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE fi-shift-date AS CHARACTER FORMAT "X(256)":U 
     LABEL "Смена" 
      VIEW-AS TEXT 
     SIZE 10.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-shift-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Номер"
      VIEW-AS TEXT
     SIZE 2.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-shift-order AS CHARACTER FORMAT "X(256)":U
     LABEL "Порядок"
      VIEW-AS TEXT
     SIZE 2.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-user-login AS CHARACTER FORMAT "X(40)":U 
     LABEL "Логин" 
      VIEW-AS TEXT 
     SIZE 30.25 BY .67 TOOLTIP "Логин"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-user-name AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 41.63 BY .67 TOOLTIP "Имя"
     FGCOLOR 1  NO-UNDO.

DEFINE IMAGE b-select-context
     FILENAME "cmp/btn-search.bmp":U
     SIZE 7.5 BY 2.5 TOOLTIP "Выбрать фирму, объект, группу меню (Alt-F10)".

DEFINE IMAGE IMAGE-1
     FILENAME "cmp/btn-off.bmp":U
     SIZE 7.5 BY 2.5.

DEFINE IMAGE IMAGE-10
     FILENAME "cmp/blank.bmp":U
     SIZE 7.5 BY 2.5.

DEFINE IMAGE IMAGE-11
     FILENAME "cmp/blank.bmp":U
     SIZE 7.5 BY 2.5.

DEFINE IMAGE IMAGE-12
     FILENAME "cmp/blank.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE IMAGE-13
     FILENAME "cmp/blank.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE IMAGE-14
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-15
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-16
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-17
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-18
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-19
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-2
     FILENAME "cmp/btn-str.bmp":U
     SIZE 7.5 BY 2.5.

DEFINE IMAGE IMAGE-20
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-21
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-22
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-23
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-24
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-25
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-26
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-27
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-28
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-29
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-3
     FILENAME "cmp/btn-shp.bmp":U
     SIZE 7.5 BY 2.5.

DEFINE IMAGE IMAGE-30
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-31
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-32
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-33
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-34
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-35
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-36
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-37
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-38
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-39
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.

DEFINE IMAGE IMAGE-4
     FILENAME "cmp/btn-res.bmp":U
     SIZE 7.5 BY 2.5.

DEFINE IMAGE IMAGE-5
     FILENAME "cmp/btn-fin.bmp":U
     SIZE 7.5 BY 2.5.

DEFINE IMAGE IMAGE-54
     FILENAME "cmp/main.bmp":U TRANSPARENT
     SIZE 108.5 BY 24.13.

DEFINE IMAGE IMAGE-6
     FILENAME "cmp/btn-bge.bmp":U
     SIZE 7.5 BY 2.5.

DEFINE IMAGE IMAGE-7
     FILENAME "cmp/btn-adm.bmp":U
     SIZE 7.5 BY 2.5.

DEFINE IMAGE IMAGE-8
     FILENAME "cmp/blank.bmp":U
     SIZE 7.5 BY 2.5.

DEFINE IMAGE IMAGE-9
     FILENAME "cmp/blank.bmp":U
     SIZE 7.5 BY 2.5.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 46.5 BY 2.38.

DEFINE RECTANGLE rect-db-user
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 46.5 BY 3.42.

DEFINE RECTANGLE rect-host-obj
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 46.5 BY 4.42.

DEFINE RECTANGLE rect-host-obj-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 46.63 BY 4.42.

DEFINE RECTANGLE rect-image
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 46.5 BY 2.46.

DEFINE VARIABLE t-obj-active AS LOGICAL INITIAL no
     LABEL "Активный"
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-menu-item FOR
      temp-menu-item SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-menu-item
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-menu-item C-Win _FREEFORM
  QUERY br-menu-item DISPLAY
      get-display-name(buffer temp-menu-item) @ v-show-display-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-LABELS NO-ROW-MARKERS SIZE 60.38 BY 17.63
         BGCOLOR 8  ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DEFAULT-FRAME
     ed-menu-item-name AT ROW 5.04 COL 1.13 NO-LABEL
     b-copy AT ROW 6.29 COL 58.38
     br-menu-item AT ROW 7.5 COL 1
     fi-user-name AT ROW 10.04 COL 61.13 COLON-ALIGNED NO-LABEL
     b-show-date AT ROW 11.58 COL 85
     t-obj-active AT ROW 14.13 COL 93.38
     fi-obj-description AT ROW 15.17 COL 61.13 COLON-ALIGNED NO-LABEL
     fi-host-description AT ROW 17.21 COL 61.13 COLON-ALIGNED NO-LABEL
     b-search-bar-code AT ROW 18.58 COL 105.25
     fi-bar-code AT ROW 18.75 COL 72.38 COLON-ALIGNED NO-LABEL
     b-open-gds AT ROW 19.67 COL 105.25
     fi-nickname AT ROW 8 COL 72.38 COLON-ALIGNED WIDGET-ID 114
     fi-user-login AT ROW 9.04 COL 72.38 COLON-ALIGNED
     fi-obj-date AT ROW 11.58 COL 70 COLON-ALIGNED
     fi-close-date AT ROW 11.58 COL 95 COLON-ALIGNED WIDGET-ID 120
     fi-shift-date AT ROW 12.63 COL 68 COLON-ALIGNED
     fi-shift-name AT ROW 12.63 COL 89 COLON-ALIGNED
     fi-shift-order AT ROW 12.63 COL 102.5 COLON-ALIGNED
     fi-obj AT ROW 14.13 COL 69 COLON-ALIGNED
     fi-host AT ROW 16.17 COL 68.13 COLON-ALIGNED
     fi-host-basecode-desc AT ROW 16.17 COL 97.75 COLON-ALIGNED
     fi-db-num AT ROW 17.79 COL 71.5 COLON-ALIGNED
     fi-gds-artic AT ROW 19.75 COL 70 COLON-ALIGNED
     fi-gds-name AT ROW 20.75 COL 68 COLON-ALIGNED
     fi-gds-qnty AT ROW 21.79 COL 69 COLON-ALIGNED
     fi-gds-price-sale AT ROW 21.79 COL 92.63 COLON-ALIGNED
     "Штрих код:" VIEW-AS TEXT
          SIZE 10.5 BY .67 AT ROW 18.75 COL 63 WIDGET-ID 130
     rect-db-user AT ROW 7.67 COL 62
     rect-host-obj AT ROW 13.79 COL 62
     rect-image AT ROW 5.04 COL 62
     IMAGE-1 AT ROW 1.79 COL 1.5 WIDGET-ID 2
     IMAGE-2 AT ROW 1.79 COL 10 WIDGET-ID 4
     IMAGE-3 AT ROW 1.79 COL 18.5 WIDGET-ID 6
     IMAGE-4 AT ROW 1.79 COL 27 WIDGET-ID 8
     IMAGE-5 AT ROW 1.79 COL 35.5 WIDGET-ID 10
     IMAGE-6 AT ROW 1.79 COL 43.88 WIDGET-ID 12
     IMAGE-7 AT ROW 1.79 COL 52.38 WIDGET-ID 14
     IMAGE-8 AT ROW 1.79 COL 60.88 WIDGET-ID 16
     IMAGE-9 AT ROW 1.79 COL 69.38 WIDGET-ID 18
     IMAGE-10 AT ROW 1.79 COL 77.88 WIDGET-ID 20
     IMAGE-11 AT ROW 1.79 COL 86.25 WIDGET-ID 22
     IMAGE-12 AT ROW 5.04 COL 58.38 WIDGET-ID 24
     IMAGE-13 AT ROW 5.04 COL 58.38 WIDGET-ID 26
	 IMAGE-14 AT ROW 5.33 COL 63.5 WIDGET-ID 34
     IMAGE-15 AT ROW 5.33 COL 67 WIDGET-ID 44
     IMAGE-16 AT ROW 5.33 COL 70.5 WIDGET-ID 46
     IMAGE-17 AT ROW 5.33 COL 74 WIDGET-ID 48
     IMAGE-18 AT ROW 5.33 COL 77.5 WIDGET-ID 50
     IMAGE-19 AT ROW 5.33 COL 81 WIDGET-ID 52
     IMAGE-20 AT ROW 5.33 COL 84.5 WIDGET-ID 54
     IMAGE-21 AT ROW 5.33 COL 88 WIDGET-ID 56
     IMAGE-22 AT ROW 5.33 COL 91.5 WIDGET-ID 58
     IMAGE-23 AT ROW 5.33 COL 95 WIDGET-ID 36
     IMAGE-24 AT ROW 5.33 COL 98.5 WIDGET-ID 38
     IMAGE-25 AT ROW 5.33 COL 102 WIDGET-ID 40
     IMAGE-26 AT ROW 5.33 COL 105.5 WIDGET-ID 42
     IMAGE-27 AT ROW 6.42 COL 63.5 WIDGET-ID 60
     IMAGE-28 AT ROW 6.42 COL 67 WIDGET-ID 62
     IMAGE-29 AT ROW 6.42 COL 70.5 WIDGET-ID 64
     IMAGE-30 AT ROW 6.42 COL 74 WIDGET-ID 66
     IMAGE-31 AT ROW 6.42 COL 77.5 WIDGET-ID 68
     IMAGE-32 AT ROW 6.42 COL 81 WIDGET-ID 70
     IMAGE-33 AT ROW 6.42 COL 84.5 WIDGET-ID 72
     IMAGE-34 AT ROW 6.42 COL 88 WIDGET-ID 74
     IMAGE-35 AT ROW 6.42 COL 91.5 WIDGET-ID 76
     IMAGE-36 AT ROW 6.42 COL 95 WIDGET-ID 78
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 108.5 BY 24.13.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME DEFAULT-FRAME
     IMAGE-37 AT ROW 6.42 COL 98.5 WIDGET-ID 80
     IMAGE-38 AT ROW 6.42 COL 102 WIDGET-ID 82
     IMAGE-39 AT ROW 6.42 COL 105.38 WIDGET-ID 84
     RECT-1 AT ROW 11.25 COL 62 WIDGET-ID 116
     IMAGE-54 AT ROW 1 COL 1 WIDGET-ID 126
     rect-host-obj-2 AT ROW 18.38 COL 62 WIDGET-ID 128
     b-select-context AT ROW 1.79 COL 101 WIDGET-ID 132
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 108.5 BY 24.13.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "Trade House"
         HEIGHT             = 24.13
         WIDTH              = 108.25
         MAX-HEIGHT         = 42.42
         MAX-WIDTH          = 240
         VIRTUAL-HEIGHT     = 42.42
         VIRTUAL-WIDTH      = 240
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME DEFAULT-FRAME
   FRAME-NAME                                                           */
/* BROWSE-TAB br-menu-item b-copy DEFAULT-FRAME */
ASSIGN 
       ed-menu-item-name:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.

/* SETTINGS FOR FILL-IN fi-bar-code IN FRAME DEFAULT-FRAME
   NO-DISPLAY                                                           */
/* SETTINGS FOR FILL-IN fi-db-num IN FRAME DEFAULT-FRAME
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       fi-db-num:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

/* SETTINGS FOR FILL-IN fi-gds-artic IN FRAME DEFAULT-FRAME
   NO-DISPLAY                                                           */
/* SETTINGS FOR FILL-IN fi-gds-name IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-gds-price-sale IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-gds-qnty IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-host-description IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-obj-description IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-user-name IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
ASSIGN 
       IMAGE-1:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-10:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-11:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-12:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-14:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-15:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-16:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-17:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-18:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-19:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-2:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-20:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-21:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-22:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-23:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-24:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-25:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-26:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-27:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-28:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-29:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-3:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-30:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-31:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-32:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-33:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-34:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-35:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-36:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-37:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-38:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-39:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-4:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-5:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

/* SETTINGS FOR IMAGE IMAGE-54 IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
ASSIGN 
       IMAGE-6:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-7:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-8:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN 
       IMAGE-9:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

/* SETTINGS FOR TOGGLE-BOX t-obj-active IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-menu-item
/* Query rebuild information for BROWSE br-menu-item
     _START_FREEFORM
/* OPEN QUERY br-menu-item FOR EACH temp-menu-item. */
run mainmenu-menu-item-open in this-procedure (input 0) .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-menu-item */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* IBS Trade House */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* IBS Trade House */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-copy C-Win
ON CHOOSE OF b-copy IN FRAME DEFAULT-FRAME /* b-copy */
DO:
  run menu-item-copy-full-name in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-open-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-open-gds C-Win
ON CHOOSE OF b-open-gds IN FRAME DEFAULT-FRAME /* b-copy */
DO:
  assign
    fi-bar-code
  .
  run search-bar-code in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-search-bar-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-search-bar-code C-Win
ON CHOOSE OF b-search-bar-code IN FRAME DEFAULT-FRAME /* b-copy */
DO:
  /* открыть окно расширенной информации о штрих-коде */
  define variable v-bar-code as character no-undo .

  assign
    fi-bar-code
  .
  run search-bar-code in this-procedure .
  run str/bc-ab.p
    (input  this-procedure :handle
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  fi-bar-code
    ,output v-bar-code
    ) no-error .
  apply "entry" to fi-bar-code in frame {&frame-name}.
  run search-bar-code in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-show-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-show-date C-Win
ON CHOOSE OF b-show-date IN FRAME DEFAULT-FRAME /* b-copy */
DO:
  define variable v-disp-date as date      no-undo .
  define variable v-ok        as logical   no-undo .
  assign
    v-disp-date = date(fi-obj-date :screen-value)
  .
  run gbl/d-inpday.w
    (input ?                  /* h-callback    */
    ,input "Календарь"        /* p-title       */
    ,input ""                 /* p-description */
    ,input ""                 /* p-mode        */
    ,input-output v-disp-date /* p-date        */
    ,output v-ok              /* p-ok          */
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-menu-item
&Scoped-define SELF-NAME br-menu-item
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-menu-item C-Win
ON DEFAULT-ACTION OF br-menu-item IN FRAME DEFAULT-FRAME
DO:
  run menu-item-choose in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-menu-item C-Win
ON MOUSE-SELECT-CLICK OF br-menu-item IN FRAME DEFAULT-FRAME
DO:
  if available temp-menu-item
  then do:
    if  temp-menu-item.item-type  = 's-m':U
    then do:
      run menu-item-choose in this-procedure .
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-menu-item C-Win
ON ROW-DISPLAY OF br-menu-item IN FRAME DEFAULT-FRAME
DO:
  if available temp-menu-item then do:
      assign
        v-show-display-name :fgcolor in browse br-menu-item = black_color
        v-show-display-name :bgcolor in browse br-menu-item = gray_color
      .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-menu-item C-Win
ON VALUE-CHANGED OF br-menu-item IN FRAME DEFAULT-FRAME
DO:
    define buffer buf_menu-group for ub.menu-group .    
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code       = v-cntxt-menu-code
        and buf_menu-group.menu-group-code = v-cntxt-menu-group-code
      no-error .
    if available buf_menu-group
    then do:
      assign
        fi-menu-group-name = buf_menu-group.menu-group-name
      .
    end.  
  run menu-item-display-full-name in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-bar-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-bar-code C-Win
ON RETURN OF fi-bar-code IN FRAME DEFAULT-FRAME /* Штрих код */
DO:
  run search-bar-code in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME fi-bar-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-bar-code C-Win
ON ANY-KEY OF fi-bar-code IN FRAME DEFAULT-FRAME
DO:
  if lastkey = 308 then
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME}
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.
assign
   parparentproc = this-procedure
.

PROCEDURE SetCurrentDirectoryA EXTERNAL "kernel32.dll"
:
    DEFINE INPUT  PARAMETER chrCurDir AS CHARACTER.
    DEFINE RETURN PARAMETER intResult AS LONG.
END PROCEDURE.

PROCEDURE OpenFile EXTERNAL "kernel32.dll" :
    DEFINE INPUT PARAMETER lpszFileName as MEMPTR . /* address of filename */
    DEFINE INPUT-OUTPUT PARAMETER lpOpenBuff as MEMPTR . /* address of buffer for file information */
    DEFINE INPUT PARAMETER fuMode as SHORT. /* action and attributes */
    DEFINE RETURN PARAMETER RetValue as SHORT . /* HFILE */
END PROCEDURE .

on "ALT-F10":U of frame {&frame-name} anywhere
do:
  run trigger-select-context in this-procedure no-error .
  if error-status :error
  then do:
    return no-apply .
  end.
end.

on alt-shift-f5 anywhere do:
  run logo in this-procedure .
end.

/*on mouse-select-click, selection of rect-bar-code do:*/
/*  run logo in this-procedure .                       */
/*end.                                                 */
on mouse-select-click, selection of
b-select-context
do:
  run trigger-select-context in this-procedure no-error .
  if error-status :error
  then do:
    return no-apply .
  end.
end.

on mouse-select-click, selection of
IMAGE-1  ,
IMAGE-2  ,
IMAGE-3  ,
IMAGE-4  ,
IMAGE-5  ,
IMAGE-6  ,
IMAGE-7  ,
IMAGE-8  ,
IMAGE-9  ,
IMAGE-10 ,
IMAGE-11 ,
IMAGE-12 ,
IMAGE-13 ,
IMAGE-14 ,
IMAGE-15 ,
IMAGE-16 ,
IMAGE-17 ,
IMAGE-18 ,
IMAGE-19 ,
IMAGE-20 ,
IMAGE-21 ,
IMAGE-22 ,
IMAGE-23 ,
IMAGE-24 ,
IMAGE-25 ,
IMAGE-26 ,
IMAGE-27 ,
IMAGE-28 ,
IMAGE-29 ,
IMAGE-30 ,
IMAGE-31 ,
IMAGE-32 ,
IMAGE-33 ,
IMAGE-34 ,
IMAGE-35 ,
IMAGE-36 ,
IMAGE-37 ,
IMAGE-38 ,
IMAGE-39 
/*IMAGE-40 ,*/
/*IMAGE-41 ,*/
/*IMAGE-42 ,*/
/*IMAGE-43 ,*/
/*IMAGE-44 ,*/
/*IMAGE-45 ,*/
/*IMAGE-46 ,*/
/*IMAGE-47 ,*/
/*IMAGE-48 ,*/
/*IMAGE-49 ,*/
/*IMAGE-50 ,*/
/*IMAGE-51 ,*/
/*IMAGE-52  */
do:
  run choose-image in this-procedure
    (input self :private-data
    ) .
end.

{ gbl/app_help.i &disable-button=yes &disable_diasize=true }

{ gbl/brwrepos.i
  &browse-name=br-menu-item
  &line-num=4
}

{ gbl/diasize.i
  &diasize_resizable_object="br-menu-item"
  &diasize_window="{&window-name}"
}

on "CTRL-K":U anywhere do:
  /* Калькулятор */
  run gbl/hotkey.p
    (input "calc":U
    ,input focus
    ).
end.


ON +, CURSOR-RIGHT OF br-menu-item IN FRAME DEFAULT-FRAME
DO:
  run menu-item-expand in this-procedure .
  run mainmenu-menu-item-open in this-procedure
    (input  temp-menu-item.item-code
    ) .
  return no-apply.
END.

ON -, CURSOR-LEFT OF br-menu-item IN FRAME DEFAULT-FRAME
DO:
  define buffer buf_temp-menu-item for temp-menu-item .

  if  available temp-menu-item
  and ( temp-menu-item.item-type = 'm-i':U
        or
        (temp-menu-item.item-type = 's-m':U
         and
         temp-menu-item.show-child = '+':U
        )
      )
  then do:
    find first buf_temp-menu-item
      where buf_temp-menu-item.item-code = temp-menu-item.parent-code
      no-error .
    if available buf_temp-menu-item
    then do:
      reposition br-menu-item to rowid rowid(buf_temp-menu-item) .
    end.
  end.
  run menu-item-collapse in this-procedure .
  run mainmenu-menu-item-open in this-procedure
    (input  temp-menu-item.item-code
    ) .
  return no-apply.
END.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
on close of this-procedure
    do:
    { gbl/conf-rd.i "'is-cctv'"  "''" "''" 0 "''" "''" "''"  no par-is-cctv par-type      no-error}
        is-cctv = lookup(par-is-cctv, "true,yes":U) > 0 .
        if is-cctv then 
        do:

            v-vid-param = 
                "SHOP_NUM=" + string(v-cntxt-obj-code) + {&delim-par} +
                "Login=" + fi-user-login + {&delim-par} + 
                "THname=" + fi-nickname .
    run db-attr-value in this-procedure ( input v-cntxt-db-num
                                          , input {&attr-mess-id-video}
                                          , output v-db-attr-value
                                          , output v-db-attr-type
                                          ) no-error .
    assign
      v-mess-id = integer (v-db-attr-value) no-error.
    
    if v-mess-id = ?
      then v-mess-id = 0.

    v-vid-param = v-vid-param + {&delim-par} +
     "MESSAGE_ID=" + string (v-mess-id)
    .
    
    v-mess-id = v-mess-id + 1.
    run db-attr-write in this-procedure ( input v-cntxt-db-num
                                        , input {&attr-mess-id-video}
                                        , input string (v-mess-id)
                                        ) no-error .
                
/*            find first ub.db-attr exclusive-lock where ub.db-attr.db-num = v-cntxt-db-num and ub.db-attr.attr-code = "INum-video" no-error.*/
/*                                                                                                                                           */
/*            if available (ub.db-attr)                                                                                                      */
/*                then                                                                                                                       */
/*            do:                                                                                                                            */
/*                assign                                                                                                                     */
/*                    v-vid-param = v-vid-param + {&delim-par} +                                                                             */
/*                      "INum=" + ub.db-attr.attr-value                                                                                      */
/*                    .                                                                                                                      */
/*                assign                                                                                                                     */
/*                    ub.db-attr.attr-value = string (integer (ub.db-attr.attr-value) + 1).                                                  */
/*                                                                                                                                           */
/*            end.                                                                                                                           */
/*            else                                                                                                                           */
/*            do:                                                                                                                            */
/*                assign                                                                                                                     */
/*                    v-vid-param = v-vid-param + {&delim-par} +                                                                             */
/*                      "INum=" + string (1).                                                                                                */
/*                .                                                                                                                          */
/*                                                                                                                                           */
/*                create ub.db-attr.                                                                                                         */
/*                                                                                                                                           */
/*                assign                                                                                                                     */
/*                    ub.db-attr.db-num    = v-cntxt-db-num                                                                                  */
/*                    ub.db-attr.attr-code = "INum-video"                                                                                    */
/*                    .                                                                                                                      */
/*                assign                                                                                                                     */
/*                    ub.db-attr.attr-value = string (1).                                                                                    */
/*            end.                                                                                                                           */
            
            run trg/video-action.p (input 63,
                input v-vid-param,
                output v-vid-ok,
                output v-vid-mes) .
        end.    
        run disable_ui .
    end.

/*  чтобы нельзя было выйти по esc и alt-f4, а только через меню  */
on window-close of {&window-name}
do:
  /* разрешаем закрывать окно по нажатию на крестик */
  apply 'close':U to this-procedure .
end.

on endkey, end-error of {&window-name} anywhere
    do:
    { gbl/conf-rd.i "'is-cctv'"  "''" "''" 0 "''" "''" "''"  no par-is-cctv par-type      no-error}
        is-cctv = lookup(par-is-cctv, "true,yes":U) > 0 .
        if is-cctv then 
        do:

            v-vid-param = 
                "SHOP_NUM=" + string(v-cntxt-obj-code) + {&delim-par} +
                "Login=" + fi-user-login + {&delim-par} + 
                "THname=" + fi-nickname .
                
    run db-attr-value in this-procedure ( input v-cntxt-db-num
                                          , input {&attr-mess-id-video}
                                          , output v-db-attr-value
                                          , output v-db-attr-type
                                          ) no-error .
    assign
      v-mess-id = integer (v-db-attr-value) no-error.
    
    if v-mess-id = ?
      then v-mess-id = 0.

    v-vid-param = v-vid-param + {&delim-par} +
     "MESSAGE_ID=" + string (v-mess-id)
    .
    
    v-mess-id = v-mess-id + 1.
    run db-attr-write in this-procedure ( input v-cntxt-db-num
                                        , input {&attr-mess-id-video}
                                        , input string (v-mess-id)
                                        ) no-error .
                
/*            find first ub.db-attr exclusive-lock where ub.db-attr.db-num = v-cntxt-db-num and ub.db-attr.attr-code = "INum-video" no-error.*/
/*                                                                                                                                           */
/*            if available (ub.db-attr)                                                                                                      */
/*                then                                                                                                                       */
/*            do:                                                                                                                            */
/*                assign                                                                                                                     */
/*                    v-vid-param = v-vid-param + {&delim-par} +                                                                             */
/*                      "INum=" + ub.db-attr.attr-value                                                                                      */
/*                    .                                                                                                                      */
/*                assign                                                                                                                     */
/*                    ub.db-attr.attr-value = string (integer (ub.db-attr.attr-value) + 1).                                                  */
/*                                                                                                                                           */
/*            end.                                                                                                                           */
/*            else                                                                                                                           */
/*            do:                                                                                                                            */
/*                assign                                                                                                                     */
/*                    v-vid-param = v-vid-param + {&delim-par} +                                                                             */
/*                      "INum=" + string (1).                                                                                                */
/*                .                                                                                                                          */
/*                                                                                                                                           */
/*                create ub.db-attr.                                                                                                         */
/*                                                                                                                                           */
/*                assign                                                                                                                     */
/*                    ub.db-attr.db-num    = v-cntxt-db-num                                                                                  */
/*                    ub.db-attr.attr-code = "INum-video"                                                                                    */
/*                    .                                                                                                                      */
/*                assign                                                                                                                     */
/*                    ub.db-attr.attr-value = string (1).                                                                                    */
/*            end.                                                                                                                           */
            
            run trg/video-action.p (input 63,
                input v-vid-param,
                output v-vid-ok,
                output v-vid-mes) .
        end.    
        return no-apply .
    end.

/* Best default for GUI applications is...                              */
pause 0 before-hide.

assign
  SESSION :SYSTEM-ALERT-BOXES = yes
.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:


  define variable v-sys-key     as character no-undo .
  define variable v-param-value as character no-undo .
  define variable v-param-type  as character no-undo .
  assign
    v-cntxt-developer = false
  .
  { gbl/currsysk.i
    v-sys-key
    no-error
  }
  if v-sys-key = {&SuperSysKey}
  then do:
    assign
      v-cntxt-developer = true
    .
  end.

  run gbl/getconn.p
    (output v-connect-usr
    ,output v-connect-device
    ,output v-userio-id
    ) .

  RUN enable_UI.
    image-54:move-to-bottom().
  run fill-temp-image in this-procedure .

/*  if v-cntxt-developer = true  */
/*  then do:                     */
/*    do with frame {&frame-name}*/
/*    :                          */
/*                               */
/*    end.                       */
/*  end.                         */

  /* создание меню окна */
  CREATE MENU MENU-BAR-handle.
  {&WINDOW-NAME} :MENUBAR = MENU-BAR-handle.

  define variable v-user-select         as logical   no-undo .
  define variable v-cntxt-valid         as logical   no-undo .
  define variable v-cntxt-error-message as character no-undo .
  define variable v-cur-date-error-code as integer      no-undo.
  run gbl/actn-upd.p
      (input this-procedure /* parparentproc */
      ) no-error .
   if error-status :error
   then do:
      message
         vss-workfile vss-revision vss-description skip
         "Ошибка при обновлении прав" skip
         error-status :get-message(1) skip
         return-value skip
         view-as alert-box error .
      undo, return no-apply return-value .
   end.

   define buffer buf_cd-events      for ub.cd-events .
   define variable v-version    as integer      no-undo.

   FIND LAST buf_cd-events NO-LOCK NO-ERROR.
   IF AVAILABLE buf_cd-events
   THEN DO:
      ASSIGN
         v-version = buf_cd-events.version
      .
      RELEASE buf_cd-events.
   END.
   ELSE DO:
      ASSIGN
         v-version = 0
      .
   END.

   run utl/cdevload.p ( INPUT THIS-PROCEDURE
                      , INPUT-OUTPUT v-version
                      ) .

   define buffer buf_sys-ctrl      for ub.sys-ctrl.

   find first buf_sys-ctrl no-lock.

   run gbl/menu-upd.p
      (input  this-procedure
      ,input  ?
      ,input  {&menu-code-main}
      ,input  buf_sys-ctrl.db-num
      ) no-error .
   if error-status :error
   then do:
      message
         vss-workfile vss-revision vss-description skip
         "Ошибка при обновлении меню" skip
         error-status :get-message(1) skip
         return-value skip
         view-as alert-box error .
      undo, return no-apply return-value .
   end.
   release buf_sys-ctrl.
   

  run get-last-context in this-procedure
    (output v-cntxt-db-num
    ,output v-cntxt-user-id
    ,output v-cntxt-process-id
    ,output v-cntxt-password
    ,output v-cntxt-valid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-menu-code
    ,output v-cntxt-menu-group-code
    ,output v-cntxt-report-num
    ,output v-cntxt-quest-print
    ,output v-cntxt-inp-jewel
    ,output v-cntxt-gds-engl
    ,output v-cntxt-bc-price
    ,output v-cntxt-is-admin
    ) .
   if v-cntxt-valid = true
   then do:
      run gbl/cntxtchk.p
         (input  v-cntxt-db-num          /* p-cntxt-db-num          */
         ,input  v-cntxt-user-id         /* p-cntxt-user-id         */
         ,input  v-cntxt-menu-code       /* p-cntxt-menu-code       */
         ,input  v-cntxt-menu-group-code /* p-cntxt-menu-group-code */
         ,input  v-cntxt-level           /* p-cntxt-level           */
         ,input  v-cntxt-host-code-obj   /* p-cntxt-host-code-obj   */
         ,input  v-cntxt-obj-type        /* p-cntxt-obj-type        */
         ,input  v-cntxt-obj-code        /* p-cntxt-obj-code        */
         ,input  v-cntxt-db-num-obj      /* p-cntxt-db-num-obj      */
         ,output v-cntxt-valid           /* p-cntxt-valid           */
         ,output v-cntxt-error-message   /* p-cntxt-error-message   */
         ) .
   end.
   run gbl/code-upd.p(input  this-procedure)  no-error .
   if error-status :error
   then do:
      message
         vss-workfile vss-revision vss-description skip
         "Ошибка при обновлении справочников" skip
         error-status :get-message(1) skip
         return-value skip
         view-as alert-box error .
      undo, return no-apply return-value .
   end.
   run gbl/verinfo.p.
   run utl/chgpsw.p (yes) no-error.
   if error-status:error
   then do:
      message return-value view-as alert-box.
      return error return-value .
   end.
  /* проверяем значения контекста */

  user-number:
  DO
  ON ERROR   UNDO user-number, RETRY user-number
  ON END-KEY UNDO user-number, RETURN:
      IF RETRY
      OR v-cntxt-valid = false
      then do:
         run select-context in this-procedure
            (input  false
            ,output v-user-select
            ) .
         if v-user-select <> true
         then do:
            /* пользователь не стал выбирать фирму или объект */
            /* отказываемся от входа в систему */
            return . /* --->>>--- */
         end.
      end.
      /* для заказчиков со старой лицензионной политикой проверяем количество пользователей */
      /* работающих с группой меню */

      define buffer buf_menu-group for ub.menu-group .

      find first buf_menu-group no-lock
         where buf_menu-group.menu-code       = v-cntxt-menu-code
            and buf_menu-group.menu-group-code = v-cntxt-menu-group-code
         no-error .
      if not available buf_menu-group
      then do:
         message
            vss-workfile vss-revision vss-description skip
            "Ошибка при поиске группы пунктов меню" skip
            "Код группы пунктов меню" v-cntxt-menu-group-code skip
            view-as alert-box error .
         undo, return error return-value .
      end.

      define variable v-chk-usr-numa as logical   no-undo .
      define variable v-work-usr-num as integer   no-undo .

      run chk-usr-numa in this-procedure
         (output v-chk-usr-numa
         ) .

      if v-chk-usr-numa = true
      then do:
            { gbl/conf-rd.i
               "buf_menu-group.menu-group-licence-param"
               0
               "'':U"
               0
               "'':U"
               "'':U"
               "'':U"
               yes
               v-param-value
               v-param-type
               no-error
            }

            if error-status :error
            then do:
            message
               vss-workfile vss-revision vss-description skip
               "Ошибка чтения конфигурационного параметра" buf_menu-group.menu-group-licence-param skip
               error-status :get-message(1) skip
               return-value skip
               view-as alert-box error .
            undo, return error return-value .
            end.

            run adm/isanybdy.p
            (input  true                         /* p-check-menu-group */
            ,input  buf_menu-group.menu-code     /* p-menu-group-id    */
            ,input  buf_menu-group.menu-group-id /* p-menu-group-id    */
            ,output v-work-usr-num               /* p-total-user-num   */
            ).
            if v-work-usr-num >= integer(v-param-value)
            then do:
               message
               "Превышено максимальное количество пользователей, работающих в группе меню" buf_menu-group.menu-group-description skip
               "Количество лицензий" integer(v-param-value) skip
               "Работает пользователей" v-work-usr-num skip
               return-value skip
               view-as alert-box error .
               assign
                  v-cntxt-valid = false
               .
               UNDO user-number, retry user-number.
            end.
      END.
  END.

  run create-dm-menu in this-procedure
    no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при создании меню" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.


  run logo in this-procedure .

  run disp-static in this-procedure
    no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры disp-static" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  run mainmenu-disp-mutable in this-procedure (
    output v-cur-date-error-code
  )  no-error.
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры mainmenu-disp-mutable" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if transaction = true
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Активна транзакция" skip
      "В главном окне не должно быть активной транзакции" skip
      "Невозможно продолжить работу системы" skip
      view-as alert-box error .
    undo, return error return-value .
  end.


  run diasize_init in this-procedure .

  run load-tnved in this-procedure .

  run ver-movepar in this-procedure .

  /* 29/IX-2017 - отказались в v.16_0 в рамках интеграции с 1С,
                  т.к. оттуда вызывается str/saledc.p,
                  который может затронуть справочники, приходящие из 1С
  run gbl/update2.p ( input parparentproc) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при запуске выправляющих утилит" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return error.
  end.
  */


  if not this-procedure:persistent
  then do:
    wait-for close of this-procedure.
  end.

  os-delete value( string(v-cntxt-report-num) + ".srt" ) .
  os-delete value( string(v-cntxt-report-num) + ".whr" ) .
  os-delete value( "tmp_" + string(v-cntxt-report-num) + ".xml" ) .

  define variable v-out-dir as character no-undo .
  get-key-value section 'kassa-ibm':U key 'out':U value v-out-dir .
  if v-out-dir <> ? then do:
    if  substring(v-out-dir, length(v-out-dir), 1) <> '/':U
    and substring(v-out-dir, length(v-out-dir), 1) <> '\':U
    then do:
      assign
        v-out-dir = v-out-dir + '/':U
      .
    end.
    define buffer buf_scales for ub.scales .
    for each buf_scales no-lock
      where buf_scales.db-num = v-cntxt-db-num
    on error undo, next
    :
      os-delete value( v-out-dir + 'plu':U + string(v-cntxt-report-num) +
                      '.':U + string(buf_scales.scales-num, '999':U ) ) .
    end.
  end.

  define variable RetOpenFile     as integer   no-undo .
  define variable lp_filename     as memptr    no-undo .
  define variable lp_openbuff     as memptr    no-undo .
  define variable Mode            as integer   no-undo .

  assign
    Mode                    = 512 /* = 0x200 ( see winbase.h ---- OF_DELETE ) */
    set-size( lp_FileName ) = 128
    set-size( lp_OpenBuff ) = 288
  .

  if  get-size( lp_FileName ) <> 0
  and get-size( lp_OpenBuff ) <> 0
  then do:
    assign
      put-string( lp_FileName, 1 ) = string( session:temp-directory
                                          + {&DF_Name} + string( v-cntxt-report-num ) )
    .
    run openfile
      (input lp_filename
      ,input-output lp_openbuff
      ,input mode
      ,output retopenfile
      ) .

    assign
      put-string( lp_FileName, 1 ) = string( session:temp-directory
                                          + {&PLT_Name} + string( v-cntxt-report-num )
                                          )
    .
    run openfile
      (input lp_filename
      ,input-output lp_openbuff
      ,input mode
      ,output retopenfile
      ) .

    assign
      set-size( lp_OpenBuff ) = 0
      set-size( lp_FileName ) = 0
    .
  end.

  /* удаляем процедуру dm-menu в которой хранятся реакции на выбор пунктов меню */
  run delete-dm-menu in this-procedure
    no-error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE bc-brief C-Win
PROCEDURE bc-brief :
/* вывод информации о товаре в главном окне */

  define input parameter v-bar-code as integer   no-undo .

  define variable v-r-b-abbr   as character no-undo .
  define variable v-doc-num    as character no-undo .
  define variable v-price-sale as decimal   no-undo .
  define variable v-road-tax   as decimal   no-undo .
  define variable v-excise     as decimal   no-undo .
  define variable v-fact-qnty  as decimal   no-undo .
  define variable v-qnty-type  as character no-undo .
  define variable v-qnty-recid as recid     no-undo .

  define buffer buf_bar-code for ub.bar-code .
  define buffer buf_goods    for ub.goods .

  do
  on error undo, return error return-value
  :
    assign
      fi-gds-artic      = '':U
      fi-gds-name       = '':U
      fi-gds-qnty       = '':U
      fi-gds-price-sale = '':U
    .

    find buf_bar-code no-lock
      where buf_bar-code.b-code = v-bar-code
      no-error .
    if available buf_bar-code
    then do:
      /* ищем название */
      find buf_goods no-lock
        where buf_goods.gds-code = buf_bar-code.gds-code
        no-error .
      if available buf_goods
      then do:
        assign
          fi-gds-artic = substitute('&1 &2 &3':U
                                   ,buf_goods.artic
                                   ,buf_goods.prod-type
                                   ,buf_goods.prod-code
                                   )
          fi-gds-name  = buf_goods.gds-name
        .
      end.

      if v-cntxt-level = {&cntxt-object}
      then do:
        /* определить аббревиатуру продажной цены */
        { gbl/r-b-abbr.i
          v-cntxt-host-code-obj
          v-r-b-abbr
        }
        /* ищем цену */
        { gbl/bcodeprc.i
          v-cntxt-obj-type
          v-cntxt-obj-code
          buf_bar-code.b-code
          0
          0
          v-doc-num
          v-price-sale
          v-road-tax
          v-excise
        }
        /* ищем количество */
        { gbl/bcodeqnt.i
          v-cntxt-obj-type
          v-cntxt-obj-code
          buf_bar-code.b-code
          0
          v-fact-qnty
          v-qnty-type
          v-qnty-recid
        }

        assign
          fi-gds-price-sale = substitute('&1 &2'
                                        ,v-price-sale
                                        ,v-r-b-abbr
                                        )
          fi-gds-qnty       = substitute('&1 &2'
                                        ,v-fact-qnty
                                        ,buf_goods.unit-base
                                        )
        .
      end.
    end.
    do with frame {&frame-name}:
       assign
         fi-gds-artic     :screen-value = fi-gds-artic
         fi-gds-name      :screen-value = fi-gds-name
         fi-gds-qnty      :screen-value = fi-gds-qnty
         fi-gds-price-sale:screen-value = fi-gds-price-sale
         fi-gds-artic     :visible      = yes
         fi-gds-name      :visible      = yes  
         fi-gds-qnty      :visible      = yes 
         fi-gds-price-sale:visible      = yes 
         .
     end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-load-menu C-Win
PROCEDURE check-load-menu :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-locked as logical no-undo .
define output parameter p-new    as logical no-undo .

define buffer buf_menu-head for ub.menu-head .

do
on error undo, return error
:

    find first buf_menu-head
         where buf_menu-head.menu-code = {&menu-code-main}
         exclusive-lock
         no-error
         no-wait
         .
    if not available buf_menu-head
    AND locked buf_menu-head then do:
         assign
            p-locked = TRUE
         .
    end.
    ELSE do:
      IF v-menu-control-number <> buf_menu-head.control-number then do:
         assign
            p-new = TRUE
         .
      end.
    END.
end.
END PROCEDURE. /* check-load-menu */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-db-num-0 C-Win
PROCEDURE chk-db-num-0 :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define output parameter p-enable-item as logical   no-undo .

  define variable v-current-db-num as integer   no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/curdbnum.i
      v-current-db-num
    }
    if v-current-db-num = 0
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-firm-db-num C-Win
PROCEDURE chk-firm-db-num :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define output parameter p-enable-item as logical   no-undo .

  define variable v-current-db-num as integer   no-undo .
  define variable v-firm-db-num as integer   no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/curdbnum.i
      v-current-db-num
    }
    { gbl/frmdbnum.i
      v-cntxt-host-code-obj
      v-firm-db-num
    }
    if v-current-db-num = v-firm-db-num
    then do:

      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-holding C-Win
PROCEDURE chk-holding :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-enable-item as logical   no-undo .

  define variable v-holding as character no-undo .
  define variable par-type  as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'holding':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      no
      v-holding
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-log}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра holding" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if  v-holding = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-is-bge C-Win
PROCEDURE chk-is-bge :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-bge as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-bge':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      no
      v-is-bge
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-log}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-bge" skip
        view-as alert-box error .
      return error.
    end.

    if  v-is-bge = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

END PROCEDURE.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-is-mmr C-Win
PROCEDURE chk-is-mmr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-mmr as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
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
    if error-status :error
    or par-type <> {&type-log}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-mmr" skip
        view-as alert-box error .
      return error.
    end.

    if  v-is-mmr = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-is-dc C-Win
PROCEDURE chk-is-dc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-dc  as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-dc':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      no
      v-is-dc
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-log}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-dc" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if  v-is-dc = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-is-edi C-Win
PROCEDURE chk-is-edi :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-edi as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-edi':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      no
      v-is-edi
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-log}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-edi" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if  v-is-edi = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-is-ef C-Win
PROCEDURE chk-is-ef :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-ef  as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-ef':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      no
      v-is-ef
      par-type
      no-error
    }
    if error-status :error
    then do:
      assign
        p-enable-item = false
      .
    end.
    else do:
      if par-type <> {&type-log} then do:
        message
          vss-workfile vss-revision vss-description skip
          "Неправильный тип конфигурационного параметра is-ef" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if  v-is-ef = 'yes':U
      then do:
        assign
          p-enable-item = true
        .
      end.
      else do:
        assign
          p-enable-item = false
        .
      end.
    end.  /*else error-status*/
  end. /*doe*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-is-fbr C-Win
PROCEDURE chk-is-fbr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-fbr as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-fbr':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      no
      v-is-fbr
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-log}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-fbr" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if  v-is-fbr = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-is-fin C-Win
PROCEDURE chk-is-fin :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-fin as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-fin':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      no
      v-is-fin
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-log}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-fin" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if  v-is-fin = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-is-off C-Win
PROCEDURE chk-is-off :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-off as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-off':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      no
      v-is-off
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-log}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-off" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if  v-is-off = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-is-previous-menu-group C-Win
PROCEDURE chk-is-previous-menu-group :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-enable-item as logical   no-undo .

  do
  on error undo, return error return-value
  :
    assign
      p-enable-item = (v-cntxt-previous-menu-group-id <> '':U)
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-is-ptrl C-Win
PROCEDURE chk-is-ptrl :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-ptrl as character no-undo .
  define variable par-type  as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-ptrl':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      no
      v-is-ptrl
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-log}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-ptrl" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if  v-is-ptrl = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-is-res C-Win
PROCEDURE chk-is-res :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-res as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-res':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      no
      v-is-res
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-log}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-res" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if  v-is-res = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-is-shp C-Win
PROCEDURE chk-is-shp :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-shp as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-shp':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      no
      v-is-shp
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-log}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-shp" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if  v-is-shp = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-is-str C-Win
PROCEDURE chk-is-str :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-str as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-str':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      no
      v-is-str
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-log}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-str" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if  v-is-str = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-is-thpos C-Win
PROCEDURE chk-is-thpos :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-thpos  as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-thpos':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      no
      v-is-thpos
      par-type
      no-error
    }
    if error-status :error
    then do:
      assign
        p-enable-item = false
      .
    end.
    else do:
      if par-type <> {&type-log} then do:
        message
          vss-workfile vss-revision vss-description skip
          "Неправильный тип конфигурационного параметра is-thpos" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if  v-is-thpos = 'yes':U
      then do:
        assign
          p-enable-item = true
        .
      end.
      else do:
        assign
          p-enable-item = false
        .
      end.
    end.  /*else error-status*/
  end. /*doe*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-is-wth C-Win
PROCEDURE chk-is-wth :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-wth as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-wth':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      no
      v-is-wth
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-log}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-wth" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if  v-is-wth = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

END PROCEDURE.
procedure chk-is-addcharges :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-add as character no-undo .
  define variable par-type   as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-addch':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-is-add
      par-type
      no-error
    }

    if v-is-add = 'yes'
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-is-addcharges */


procedure chk-is-not-addcharges :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-add as character no-undo .
  define variable par-type   as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-addch':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-is-add
      par-type
      no-error
    }

    if v-is-add = 'yes'
    then do:
      assign
        p-enable-item = false
      .
    end.
    else do:
      assign
        p-enable-item = true
      .
    end.
  end.

end procedure. /* chk-is-addcharges */

procedure chk-obj-type-shop :

  define output parameter p-enable-item as logical   no-undo .

  do
  on error undo, return error return-value
  :

    if v-cntxt-obj-type = {&shop}
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-obj-type-shop */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-menu-group-valid C-Win
PROCEDURE chk-menu-group-valid :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-menu-group-id as character no-undo .
  define output parameter p-enable-item   as logical   no-undo .

  define buffer buf_menu-group for ub.menu-group .

  do
  on error undo, return error return-value
  :
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = v-cntxt-menu-code
        and buf_menu-group.menu-group-id = p-menu-group-id
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        "Код меню" v-cntxt-menu-code skip
        "Идентификатор группы" p-menu-group-id skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    { gbl/usmgrava.i
      v-cntxt-db-num
      {&action-head-code-main}
      v-cntxt-user-id
      buf_menu-group.menu-code
      buf_menu-group.menu-group-code
      v-cntxt-level
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      p-enable-item
    }
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-num-cd C-Win
PROCEDURE chk-num-cd :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-enable-item as logical   no-undo .

  define variable v-num-cd as character no-undo .
  define variable par-type as character no-undo .
  define variable v-num    as integer      no-undo.

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'num-cd':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      no
      v-num-cd
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-int}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра num-cd" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    assign
      v-num = integer(v-num-cd)
      no-error
    .
    IF error-status:error = TRUE THEN
    do:
       assign
         v-num = 0
       .
    end.

    if v-num > 0
    /* Пустой параметр:  (В описании параметра: не заданно – значит не ограничено) */
    or v-num-cd = "":U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-num-scls C-Win
PROCEDURE chk-num-scls :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-enable-item as logical   no-undo .

  define variable v-num-scls as character no-undo .
  define variable par-type   as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'num-scls':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      no
      v-num-scls
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-int}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра num-scls" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if integer(v-num-scls) > 0
    OR v-num-scls = ""
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-orders C-Win
PROCEDURE chk-orders :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-enable-item as logical   no-undo .

  define variable v-orders as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'orders':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      no
      v-orders
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-log}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра orders" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if  v-orders = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-rtexch C-Win
PROCEDURE chk-rtexch :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-enable-item as logical   no-undo .

  define variable v-rtexch as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'rtexch':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      no
      v-rtexch
      par-type
      no-error
    }
    if error-status :error
    then do:
      assign
        v-rtexch = 'no':U
      .
    end.

    if  v-rtexch = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-usr-numa C-Win
PROCEDURE chk-usr-numa :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-enable-item as logical   no-undo .

  define variable v-usr-numa as character no-undo .
  define variable par-type   as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'usr-numa':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      no
      v-usr-numa
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-log}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра usr-numa" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if v-usr-numa = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-usr-numa-no C-Win
PROCEDURE chk-usr-numa-no :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-enable-item as logical   no-undo .

  define variable v-usr-numa as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'usr-numa':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      no
      v-usr-numa
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-log}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра usr-numa" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if v-usr-numa = 'yes':U
    then do:
      /* возвращается отрицание значения */
      assign
        p-enable-item = false
      .
    end.
    else do:
      /* возвращается отрицание значения */
      assign
        p-enable-item = true
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-image C-Win
PROCEDURE choose-image :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-private-data as character no-undo .

  define buffer buf_temp-image for temp-image .

  do
  on error undo, return error return-value
  :
    find first buf_temp-image
      where buf_temp-image.image-code = integer(p-private-data)
      no-error .
    if not available buf_temp-image
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Не найдено описание изображения с кодом" p-private-data skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    case entry(1, buf_temp-image.image-procedure, {&comma-char})
    :
      when 'int':U
      then do:
        run run-procedure-int in g#dm-menu-handle
          (input entry(2, buf_temp-image.image-procedure, {&comma-char})
          ) .
      end.
    end case.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-menu-item C-Win
PROCEDURE choose-menu-item :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    if v-menu-item-choose = true
    then do:
      /* пользователь уже выбрал пункт меню */
      /* ничего не делаем */
      message
        "Вы уже выбрали пункт меню" skip
        view-as alert-box information .
      undo, return error .
    end.
    assign
      v-menu-item-choose = true
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-dm-menu C-Win
PROCEDURE create-dm-menu :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  if not valid-handle (g#dm-menu-handle)
  then do:
    run gbl/dm-menu.p persistent set g#dm-menu-handle
      ( input  this-procedure          /* parparentproc     */
      , input  menu-bar-handle         /* p-menu-handle     */
      , input  v-cntxt-menu-code       /* p-menu-code       */
      , input  v-cntxt-menu-group-code /* p-menu-group-code */
      , output v-menu-control-number
      ) no-error.
    if error-status :error
    then do:
      message
        "Ошибка вызова процедуры dm-menu.p" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      return error.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-dm-menu C-Win
PROCEDURE delete-dm-menu :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  if valid-handle (g#dm-menu-handle)
  then do:
    run clear-menu in g#dm-menu-handle no-error .
    if error-status :error
    then do:
      message
        "Ошибка при очистке меню" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      return error .
    end.
    delete procedure g#dm-menu-handle .
    assign
      g#dm-menu-handle = ?
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-menu-item C-Win
PROCEDURE delete-menu-item :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-item-code as integer   no-undo .

  define buffer buf_temp-menu-item for temp-menu-item .

  do
  on error undo, return error return-value
  :
    for each buf_temp-menu-item
      where buf_temp-menu-item.parent-code = p-item-code
    on error undo, return error return-value
    :
      if buf_temp-menu-item.item-type = 's-m':U
      then do:
        run delete-menu-item in this-procedure
          (input buf_temp-menu-item.item-code
          ) .
      end.

      delete buf_temp-menu-item .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE deselect-menu-item C-Win
PROCEDURE deselect-menu-item :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    assign
      v-menu-item-choose = false
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI C-Win  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Delete the WINDOW we created */
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
  THEN DELETE WIDGET C-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disp-static C-Win
PROCEDURE disp-static :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-host-name like ub.clients.obj-name no-undo .
  define variable v-curr-abbr like ub.currency.curr-abbr no-undo .
  define variable v-retail like ub.sysconf.ord-prt no-undo .

  define buffer buf_clients for ub.clients .
  define buffer buf_menu-group for ub.menu-group .

  do
  on error undo, return error return-value
  :
    /* показать общую информацию и обнулить подробную информацию */
    assign
      fi-db-num             = string(v-cntxt-db-num)
      fi-user-login         = '':U
      fi-user-name          = '':U
      fi-host               = '':U
      fi-host-basecode-desc = '':U
      fi-host-description   = '':U
      fi-obj                = '':U
      fi-obj-description    = '':U
      t-obj-active          = ?
      fi-menu-group-name    = '':U
    .

    define buffer buf_user-account for ub.user-account .
    define buffer buf_user-login   for ub.user-login .

    find first buf_user-account no-lock
      where buf_user-account.user-id = v-cntxt-user-id
      no-error .
    if available buf_user-account
    then do:
      assign
        fi-user-name = substitute('&1 &2 &3':U
                                ,buf_user-account.last-name
                                ,buf_user-account.first-name
                                ,buf_user-account.second-name
                                )
      .
    end.

    find first buf_user-login no-lock
      where buf_user-login.db-num  = v-cntxt-db-num
        and buf_user-login.user-id = v-cntxt-user-id
      no-error .
    if available buf_user-login
    then do:
      assign
        fi-user-login = buf_user-login.user-login
        fi-nickname   = usrnickf(buf_user-login.user-id)
      .
    end.

    find first buf_menu-group no-lock
      where buf_menu-group.menu-code       = v-cntxt-menu-code
        and buf_menu-group.menu-group-code = v-cntxt-menu-group-code
      no-error .
    if available buf_menu-group
    then do:
      assign
        fi-menu-group-name = buf_menu-group.menu-group-name
      .
      run menu-item-display-full-name in this-procedure .
    end.

    if v-cntxt-level = {&cntxt-firm}
    or v-cntxt-level = {&cntxt-object}
    then do:
      /* показать информацию о фирме */
      assign
        fi-host = substitute('&1 &2':U
                            ,{&cmp}
                            ,v-cntxt-host-code-obj
                            )
      .

      find buf_clients no-lock
        where buf_clients.obj-type = {&cmp}
          and buf_clients.obj-code = v-cntxt-host-code-obj
        no-error .
      if available buf_clients
      then do:
        assign
          fi-host-description = buf_clients.obj-name
        .
      end.

      define variable v-base-code as integer   no-undo .
      { gbl/basecode.i
        v-cntxt-host-code-obj
        v-base-code
      }

      define buffer buf_currency for ub.currency .
      find buf_currency no-lock
        where buf_currency.curr-code = v-base-code
        .
      assign
        fi-host-basecode-desc = buf_currency.curr-abbr
      .
    end.

    if v-cntxt-level = {&cntxt-object}
    then do:
      /* показать информацию об объекте */
      assign
        fi-obj  = substitute('&1 &2':U
                            ,v-cntxt-obj-type
                            ,v-cntxt-obj-code
                            )
      .

      find buf_clients no-lock
        where buf_clients.obj-type = v-cntxt-obj-type
          and buf_clients.obj-code = v-cntxt-obj-code
        no-error .
      if available buf_clients
      then do:
        assign
          fi-obj-description = buf_clients.obj-name
        .
      end.

      define variable v-obj-active as logical   no-undo .
      { gbl/objat.i
        v-cntxt-obj-type
        v-cntxt-obj-code
        "'active=request':U"
        v-obj-active
      }

      assign
        t-obj-active = v-obj-active
      .
    end.

    do with frame {&frame-name}
    :
      assign
        /*fi-menu-group-name*/
        /*fi-db-num*/
        fi-nickname:screen-value = fi-nickname
        fi-user-login:screen-value = fi-user-login
        fi-user-name:screen-value = fi-user-name
        fi-nickname:visible = yes
        fi-user-login:visible = yes
        fi-user-name:visible = yes
         .

      if v-cntxt-level = {&cntxt-global}
      then do:
        assign
          fi-host               :visible = no
          fi-host-basecode-desc :visible = no
          fi-obj                :visible = no
          fi-obj-description    :visible = no
          t-obj-active          :visible = no
          fi-host-description            = "Без фирмы объекта."
          fi-host-description   :screen-value = fi-host-description
          fi-host-description   :visible = yes
        .
/*        if v-logo-image-visible <> yes then do:*/
/*/*          run logo in this-procedure .*/     */
/*        end.                                   */
      end.

      if v-cntxt-level = {&cntxt-firm}
      then do:
        assign
          fi-host              :screen-value = fi-host
          fi-host-basecode-desc:screen-value = fi-host-basecode-desc
          fi-host-description  :screen-value = fi-host-description
          fi-host              :visible      = yes
          fi-host-basecode-desc:visible      = yes
          fi-host-description  :visible      = yes
          fi-obj               :visible      = no
          fi-obj-description   :visible      = no
          t-obj-active         :visible      = no
         .
/*        if v-logo-image-visible <> yes then do:*/
/*/*          run logo in this-procedure .*/     */
/*        end.                                   */
      end.

      if v-cntxt-level = {&cntxt-object}
      then do:
/*/*        if v-logo-image-visible = yes then do:*/*/
/*          hide                                    */
/*            fi-bar-code                           */
/*            fi-gds-artic                          */
/*            fi-gds-name                           */
/*            fi-gds-qnty                           */
/*            fi-gds-price-sale                     */
/*            b-open-gds                            */
/*            b-search-bar-code                     */
/*          in frame {&frame-name} .                */
/*/*        end.*/                                  */
        assign
          fi-host              :screen-value = fi-host
          fi-host-basecode-desc:screen-value = fi-host-basecode-desc
          fi-host-description  :screen-value = fi-host-description
          fi-obj               :screen-value = fi-obj
          fi-obj-description   :screen-value = fi-obj-description
          t-obj-active         :screen-value = string(t-obj-active)
          fi-host              :visible      = yes
          fi-host-basecode-desc:visible      = yes
          fi-host-description  :visible      = yes
          fi-obj               :visible      = yes
          fi-obj-description   :visible      = yes
          t-obj-active         :visible      = yes
           .
      end.
    end.

    define variable v-arm-title as character no-undo .

    run set-mainmenu-title in this-procedure
      no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при изменении заголовка окна" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      return error.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI C-Win  _DEFAULT-ENABLE
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
  DISPLAY ed-menu-item-name fi-user-name t-obj-active fi-obj-description 
          fi-host-description fi-nickname fi-user-login fi-obj-date 
          fi-close-date fi-shift-date fi-shift-name fi-shift-order fi-obj 
          fi-host fi-host-basecode-desc fi-gds-artic fi-gds-name fi-gds-qnty 
          fi-gds-price-sale 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  ENABLE rect-db-user rect-host-obj rect-image IMAGE-1 IMAGE-2 IMAGE-3 IMAGE-4 
         IMAGE-5 IMAGE-6 IMAGE-7 IMAGE-8 IMAGE-9 IMAGE-10 IMAGE-11 IMAGE-12 IMAGE-13
         IMAGE-14 IMAGE-15 IMAGE-16 IMAGE-17 IMAGE-18 IMAGE-19 IMAGE-20 
         IMAGE-21 IMAGE-22 IMAGE-23 IMAGE-24 IMAGE-25 IMAGE-26 IMAGE-27 
         IMAGE-28 IMAGE-29 IMAGE-30 IMAGE-31 IMAGE-32 IMAGE-33 IMAGE-34 
         IMAGE-35 IMAGE-36 IMAGE-37 IMAGE-38 IMAGE-39 RECT-1 rect-host-obj-2 
         b-select-context ed-menu-item-name b-copy br-menu-item b-show-date 
         b-search-bar-code fi-bar-code b-open-gds fi-nickname fi-user-login 
         fi-obj-date fi-close-date fi-shift-date fi-shift-name fi-shift-order 
         fi-obj fi-host fi-host-basecode-desc fi-gds-artic 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-temp-image C-Win
PROCEDURE fill-temp-image :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_temp-image for temp-image .

  do
  on error undo, return error return-value
  :
    for each buf_temp-image
    on error undo, return error return-value
    :
      delete buf_temp-image .
    end.

    do with frame {&frame-name}
    :
      create buf_temp-image . assign buf_temp-image.image-code = 1  buf_temp-image.image-handle = image-1  :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 2  buf_temp-image.image-handle = image-2  :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 3  buf_temp-image.image-handle = image-3  :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 4  buf_temp-image.image-handle = image-4  :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 5  buf_temp-image.image-handle = image-5  :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 6  buf_temp-image.image-handle = image-6  :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 7  buf_temp-image.image-handle = image-7  :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 8  buf_temp-image.image-handle = image-8  :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 9  buf_temp-image.image-handle = image-9  :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 10 buf_temp-image.image-handle = image-10 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 11 buf_temp-image.image-handle = image-11 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 12 buf_temp-image.image-handle = image-12 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 13 buf_temp-image.image-handle = image-13 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 14 buf_temp-image.image-handle = image-14 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 15 buf_temp-image.image-handle = image-15 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 16 buf_temp-image.image-handle = image-16 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 17 buf_temp-image.image-handle = image-17 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 18 buf_temp-image.image-handle = image-18 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 19 buf_temp-image.image-handle = image-19 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 20 buf_temp-image.image-handle = image-20 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 21 buf_temp-image.image-handle = image-21 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 22 buf_temp-image.image-handle = image-22 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 23 buf_temp-image.image-handle = image-23 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 24 buf_temp-image.image-handle = image-24 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 25 buf_temp-image.image-handle = image-25 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 26 buf_temp-image.image-handle = image-26 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 27 buf_temp-image.image-handle = image-27 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 28 buf_temp-image.image-handle = image-28 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 29 buf_temp-image.image-handle = image-29 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 30 buf_temp-image.image-handle = image-30 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 31 buf_temp-image.image-handle = image-31 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 32 buf_temp-image.image-handle = image-32 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 33 buf_temp-image.image-handle = image-33 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 34 buf_temp-image.image-handle = image-34 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 35 buf_temp-image.image-handle = image-35 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 36 buf_temp-image.image-handle = image-36 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 37 buf_temp-image.image-handle = image-37 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 38 buf_temp-image.image-handle = image-38 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 39 buf_temp-image.image-handle = image-39 :handle .
/*      create buf_temp-image . assign buf_temp-image.image-code = 40 buf_temp-image.image-handle = image-40 :handle .*/
/*      create buf_temp-image . assign buf_temp-image.image-code = 41 buf_temp-image.image-handle = image-41 :handle .*/
/*      create buf_temp-image . assign buf_temp-image.image-code = 42 buf_temp-image.image-handle = image-42 :handle .*/
/*      create buf_temp-image . assign buf_temp-image.image-code = 43 buf_temp-image.image-handle = image-43 :handle .*/
/*      create buf_temp-image . assign buf_temp-image.image-code = 44 buf_temp-image.image-handle = image-44 :handle .*/
/*      create buf_temp-image . assign buf_temp-image.image-code = 45 buf_temp-image.image-handle = image-45 :handle .*/
/*      create buf_temp-image . assign buf_temp-image.image-code = 46 buf_temp-image.image-handle = image-46 :handle .*/
/*      create buf_temp-image . assign buf_temp-image.image-code = 47 buf_temp-image.image-handle = image-47 :handle .*/
/*      create buf_temp-image . assign buf_temp-image.image-code = 48 buf_temp-image.image-handle = image-48 :handle .*/
/*      create buf_temp-image . assign buf_temp-image.image-code = 49 buf_temp-image.image-handle = image-49 :handle .*/
/*      create buf_temp-image . assign buf_temp-image.image-code = 50 buf_temp-image.image-handle = image-50 :handle .*/
/*      create buf_temp-image . assign buf_temp-image.image-code = 51 buf_temp-image.image-handle = image-51 :handle .*/
/*      create buf_temp-image . assign buf_temp-image.image-code = 52 buf_temp-image.image-handle = image-52 :handle .*/
    end.

    for each buf_temp-image
    :
      assign
        buf_temp-image.image-handle :private-data = string(buf_temp-image.image-code)
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-bc-price C-Win
PROCEDURE get-bc-price :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-bc-price as logical no-undo .

  do
  on error undo, return error
  :
    assign
      p-bc-price = v-cntxt-bc-price
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-db-num C-Win
PROCEDURE get-db-num :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-db-num like ub.sys-ctrl.db-num no-undo.

  define buffer buf_sys-ctrl for ub.sys-ctrl.
  find first buf_sys-ctrl no-lock.
  assign
    p-db-num = buf_sys-ctrl.db-num
  .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-gds-engl C-Win
PROCEDURE get-gds-engl :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-gds-engl as logical no-undo .

  do
  on error undo, return error
  :
    assign
      p-gds-engl = v-cntxt-gds-engl
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-inp-jewel C-Win
PROCEDURE get-inp-jewel :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-inp-jewel as logical no-undo .

  do
  on error undo, return error
  :
    assign
      p-inp-jewel = v-cntxt-inp-jewel
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-news C-Win
PROCEDURE get-news :
define output parameter p-news as logical no-undo .

  do
  on error undo, return error
  :
     p-news = no.
  end.

end procedure. /* get-news */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-esys C-Win
PROCEDURE get-esys :
define output parameter p-esys as logical no-undo .

  do
  on error undo, return error
  :
     p-esys = no.
  end.

end procedure. /* get-news */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-last-context C-Win
PROCEDURE get-last-context :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-cntxt-db-num                  as integer   no-undo .
  define output parameter p-cntxt-user-id                 as character no-undo .
  define output parameter p-cntxt-process-id              as integer   no-undo .
  define output parameter p-cntxt-password                as character no-undo .
  define output parameter p-cntxt-valid                   as logical   no-undo .
  define output parameter p-cntxt-level                   as character no-undo .
  define output parameter p-cntxt-host-code-obj           as integer   no-undo .
  define output parameter p-cntxt-obj-type                as character no-undo .
  define output parameter p-cntxt-obj-code                as integer   no-undo .
  define output parameter p-cntxt-db-num-obj              as integer   no-undo .
  define output parameter p-cntxt-menu-code               as integer   no-undo .
  define output parameter p-cntxt-menu-group-code         as integer   no-undo .
  define output parameter p-cntxt-report-num              as integer   no-undo .
  define output parameter p-cntxt-quest-print             as logical   no-undo .
  define output parameter p-cntxt-inp-jewel               as logical   no-undo .
  define output parameter p-cntxt-gds-engl                as logical   no-undo .
  define output parameter p-cntxt-bc-price                as logical   no-undo .
  define output parameter p-cntxt-is-admin                as logical   no-undo .

  define buffer buf_user-login for ub.user-login .

  do
  on error undo, return error return-value
  :
    assign
      p-cntxt-user-id  = p-user-id
      p-cntxt-password = p-password
    .

    run gbl/getprcid.p
      (output p-cntxt-process-id
      ) .

    define buffer buf_sys-ctrl for ub.sys-ctrl .
    find first buf_sys-ctrl no-lock .
    assign
      p-cntxt-db-num = buf_sys-ctrl.db-num
    .

    run gbl/cntxtget.p
      (input  p-cntxt-db-num           /* p-cntxt-db-num          */
      ,input  p-cntxt-user-id          /* p-cntxt-user-id         */
      ,output p-cntxt-valid            /* p-cntxt-valid           */
      ,output p-cntxt-menu-code        /* p-cntxt-menu-code       */
      ,output p-cntxt-menu-group-code  /* p-cntxt-menu-group-code */
      ,output p-cntxt-level            /* p-cntxt-level           */
      ,output p-cntxt-host-code-obj    /* p-cntxt-host-code-obj   */
      ,output p-cntxt-obj-type         /* p-cntxt-obj-type        */
      ,output p-cntxt-obj-code         /* p-cntxt-obj-code        */
      ) .
    if p-cntxt-level = {&cntxt-object}
    then do:
      { gbl/objdbnum.i
        p-cntxt-obj-type
        p-cntxt-obj-code
        p-cntxt-db-num-obj
        no-error
      }
    end.
    else do:
      assign
        p-cntxt-db-num-obj = ?
      .
    end.

    /* устанавливаем переменную необходимую для формирования имени файла отчетов */
    assign
      p-cntxt-report-num = ibs.th.gbl.gbl-inipar:cntxt-report-num .
    .

    /* считываем настройки пользователя по умолчанию */
    find first buf_user-login no-lock
      where buf_user-login.db-num  = p-cntxt-db-num
        and buf_user-login.user-id = p-cntxt-user-id
      no-error .
    if available buf_user-login
    then do:
      assign
            p-cntxt-quest-print = buf_user-login.quest-print
            p-cntxt-is-admin    = buf_user-login.user-administrator
      .
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-quest-print C-Win
PROCEDURE get-quest-print :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-quest-print as logical no-undo .

  do
  on error undo, return error
  :
    assign
      p-quest-print = v-cntxt-quest-print
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-report-num C-Win
PROCEDURE get-report-num :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-report-num as integer no-undo .

  do
  on error undo, return error
  :
    assign
      p-report-num = v-cntxt-report-num
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-user-password C-Win
PROCEDURE get-user-password :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-password as character no-undo .

  do
  on error undo, return error
  :
    assign
      p-password = v-cntxt-password
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-userid C-Win
PROCEDURE get-userid :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-user-id as character    no-undo .

  do
  on error undo, return error
  :
    assign
      p-user-id = v-cntxt-user-id
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE image-display-as-min C-Win
PROCEDURE image-display-as-min :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer x-gds-obj-prop for ub.gds-obj-prop.
define buffer x-gds-obj      for ub.gds-obj.
define variable l-exist-as-min as log no-undo .
  do
  on error undo, return error return-value
  :
   l-exist-as-min = false  .
   for  EACH x-gds-obj-prop no-lock WHERE
             x-gds-obj-prop.gdop-assort-min = true AND
             x-gds-obj-prop.obj-code = v-cntxt-obj-code  AND
             x-gds-obj-prop.obj-type = v-cntxt-obj-type  ,
                EACH x-gds-obj no-lock WHERE
                     x-gds-obj.gds-code = x-gds-obj-prop.gds-code AND
                     x-gds-obj.obj-code = x-gds-obj-prop.obj-code AND
                     x-gds-obj.obj-type = x-gds-obj-prop.obj-type and
                     x-gds-obj.fact-qnty < x-gds-obj-prop.gdop-min-stock
                     :
      l-exist-as-min = true .
      leave.
    end.

    run image-display-update-visible in this-procedure
      (input l-exist-as-min
      ,input 'as-min':U
      ) .

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/*
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE image-display-iztdel C-Win
PROCEDURE image-display-iztdel :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer x-gds-obj-prop       for ub.gds-obj-prop.
define buffer x-gds-obj-prop-attr  for ub.gds-obj-prop-attr.
define buffer buf_gds-obj for ub.gds-obj  .
define buffer buf_assortment-matrix for ub.assortment-matrix  .

define variable l-exist-iztdel as log no-undo .
define variable v-srok as integer   no-undo .
define variable v-date-corr as date no-undo .
define variable v-value-character  as character no-undo .
define variable v-value-decimal    as decimal   no-undo .
define variable v-value-integer    as integer   no-undo .
define variable v-value-logical    as logical   no-undo .
define variable v-value-type       as character no-undo .
define variable v-value-date       as date      no-undo .
define variable v-event-code       as character no-undo .
define variable v-izt-new          as logical   no-undo .
define variable v-izt-com          as logical   no-undo .
define variable v-izt-del          as logical   no-undo .
define variable v-izt-spec         as logical   no-undo .
define variable v-izt-empty        as logical   no-undo .
define variable v-Ok               as logical   no-undo .
define variable v-mess             as character no-undo .

  do
  on error undo, return error return-value
  :
  empty temp-table thbjattr_thbj-attr .
  run adm/shattri.p (
       input "get":U
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input {&attr-ass-obj}
      ,input {&attr-Ass-obj_ass-srokiztdel}
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-srok
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .

   l-exist-iztdel = false   .
   find first buf_assortment-matrix no-lock where
              buf_assortment-matrix.obj-type = v-cntxt-obj-type and
              buf_assortment-matrix.obj-code = v-cntxt-obj-code and
              buf_assortment-matrix.asmt-status = 0 no-error .
   if  available buf_assortment-matrix then do:


   if not ( v-srok = 0  or v-srok = ? ) then do:
        for each x-gds-obj-prop no-lock where
                  x-gds-obj-prop.gdop-igt = {&ass-izd-del} AND
                  x-gds-obj-prop.obj-code = v-cntxt-obj-code  AND
                  x-gds-obj-prop.obj-type = v-cntxt-obj-type  ,
                    FIRST x-gds-obj-prop-attr no-lock WHERE
                          x-gds-obj-prop-attr.gds-code = x-gds-obj-prop.gds-code AND
                          x-gds-obj-prop-attr.obj-code = x-gds-obj-prop.obj-code AND
                          x-gds-obj-prop-attr.obj-type = x-gds-obj-prop.obj-type and
                          x-gds-obj-prop-attr.attr-code = {&gopattr-CorrIztDel}
                          :
                        { gbl/goassmat.i
                          x-gds-obj-prop-attr.gds-code
                          x-gds-obj-prop-attr.obj-type
                          x-gds-obj-prop-attr.obj-code
                          false
                          v-Ok
                          v-mess }
                          if v-Ok = false then next.

                          v-date-corr = date(int(substring(x-gds-obj-prop-attr.attr-value,4,2)),
                                             int(substring(x-gds-obj-prop-attr.attr-value,1,2)),
                                             int(substring(x-gds-obj-prop-attr.attr-value,7,4))) no-error .

                          if v-date-corr = ? then v-date-corr = today .

                          if today - v-date-corr >= v-srok then do:
                              find first buf_gds-obj no-lock where
                                          buf_gds-obj.gds-code = x-gds-obj-prop.gds-code AND
                                          buf_gds-obj.obj-code = x-gds-obj-prop.obj-code AND
                                          buf_gds-obj.obj-type = x-gds-obj-prop.obj-type no-error .

                                      if available buf_gds-obj and buf_gds-obj.fact-qnty <> 0 then do:
                                          v-event-code = {&izt-event-delete-matr-rest} .
                                      end.
                                      else do:
                                          v-event-code = {&izt-event-delete-matr-norest} .
                                      end.
                                      if available buf_gds-obj then do:
                                          { gbl/iztrul.i
                                            v-event-code
                                            v-izt-new
                                            v-izt-com
                                            v-izt-del
                                            v-izt-spec
                                            v-izt-empty
                                            }
                                            if v-izt-del = true then do:
                                              l-exist-iztdel = true .
                                              leave.
                                            end.
                                        end.
                          end.
          end. /*for each*/
    end.
    end.
    run image-display-update-visible in this-procedure
      (input l-exist-iztdel
      ,input 'iztdel':U
      ) .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
*/
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE image-display-cd C-Win
PROCEDURE image-display-cd :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    def var l-exist-cd as log no-undo .
    define variable v-send as logical no-undo .
    define buffer buf_BatchProcess for ub.batchProcess .

    assign
    l-exist-cd =
        can-find (first  buf_BatchProcess no-lock
        where buf_BatchProcess.bp_type       = {&btpr-type-gds}
          and buf_BatchProcess.bp_status     = {&btpr-normal}
                )
        or
        can-find (first  buf_BatchProcess no-lock
        where buf_BatchProcess.bp_type       = {&btpr-type-goa}
          and buf_BatchProcess.bp_status     = {&btpr-normal}
                )
        or
        can-find (first  buf_BatchProcess no-lock
        where buf_BatchProcess.bp_type       = {&btpr-type-dcard}
          and buf_BatchProcess.bp_status     = {&btpr-normal}
                )
        or
        can-find (first  buf_BatchProcess no-lock
        where buf_BatchProcess.bp_type       = {&btpr-type-seller}
          and buf_BatchProcess.bp_status     = {&btpr-normal}
                )
        or
        can-find (first  buf_BatchProcess no-lock
        where buf_BatchProcess.bp_type       = {&btpr-type-cashier}
          and buf_BatchProcess.bp_status     = {&btpr-normal}
                )

    .
    run str/mrkt-ts.p
                (input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                ,input '':U
                ,output v-send) no-error .
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'str/mrkt-ts.p':U skip
        error-status:get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    assign
      l-exist-cd = l-exist-cd or v-send
    .

    run image-display-update-visible in this-procedure
      (input l-exist-cd
      ,input 'cd':U
      ) .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE image-display-curses C-Win
PROCEDURE image-display-curses :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  do
  on error undo, return error return-value
  :
    def var l-exist-curses as log no-undo .

    assign
      l-exist-curses =
          can-find (first ub.curr-shop where
                          ub.curr-shop.obj-type = v-cntxt-obj-type and
                          ub.curr-shop.obj-code = v-cntxt-obj-code and
                          year (ub.curr-shop.exch-date) = 9999 no-lock)
    .

    run image-display-update-visible in this-procedure
      (input l-exist-curses
      ,input 'curses':U
      ) .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE image-display-in-ov C-Win
PROCEDURE image-display-in-ov :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable l-exist-in-ov as logical   no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/objat.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      "'exist-in-ov=request'"
      l-exist-in-ov
      no-error
    }
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        error-status:get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    run image-display-update-visible in this-procedure
      (input l-exist-in-ov
      ,input 'in-ov':U
      ) .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE image-display-nwsc C-Win
PROCEDURE image-display-nwsc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    define variable l-exist-nwsc as log no-undo .
    define buffer buf_batchprocess for ub.batchprocess.

    find first buf_batchprocess no-lock where
              buf_batchprocess.bp_type = {&btpr-type-nws-coll}
          and buf_batchprocess.bp_status = {&btpr-normal} no-error .
    assign
      l-exist-nwsc = available buf_batchprocess
    .

    run image-display-update-visible in this-procedure
      (input l-exist-nwsc
      ,input 'nwsc':U
      ) .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE image-display-ord-do C-Win
PROCEDURE image-display-ord-do :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    define variable l-exist-ord-do as logical no-undo .
    assign
    l-exist-ord-do   = false .
 if   can-find (first ub.ord-doc no-lock  where ub.ord-doc.cycle-day > 0
        and ub.ord-doc.host-code = v-cntxt-host-code-obj
        and (integer(today - ub.ord-doc.doc-date) >= ub.ord-doc.cycle-day)
        and ub.ord-doc.order-type = 1
        and ub.ord-doc.status_ <> {&g___new}
        )
         or
       can-find ( first ub.ord-doc no-lock  where
           ub.ord-doc.host-code = v-cntxt-host-code-obj
        and ub.ord-doc.order-type = 4
        and ub.ord-doc.status_ <> {&g___new}
         )
        then do:
         l-exist-ord-do = true .
        end.

    assign
      l-exist-ord-do =   can-find (first ub.ord-doc where ub.ord-doc.cycle-day > 0
                          and ub.ord-doc.host-code = v-cntxt-host-code-obj
                          and (integer(today - ub.ord-doc.doc-date) >= ub.ord-doc.cycle-day)
                          and ub.ord-doc.order-type = 1
                          and ub.ord-doc.status_ <> {&g___new}
                          no-lock)
    .
    run image-display-update-visible in this-procedure
      (input l-exist-ord-do
      ,input 'ord-do':U
      ) .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE image-display-ovrval C-Win
PROCEDURE image-display-ovrval :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    define variable l-exist-ovrval as log no-undo init false .

    define buffer buf_price-doc for ub.price-doc.

    find first buf_price-doc no-lock
      where buf_price-doc.obj-type  = v-cntxt-obj-type
        and buf_price-doc.obj-code  = v-cntxt-obj-code
        and buf_price-doc.status_   = {&order}

    no-error .
    if available buf_price-doc then do:
      assign
        l-exist-ovrval = yes
      .
    end.

    run image-display-update-visible in this-procedure
      (input l-exist-ovrval
      ,input 'ovrval':U
      ) .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE image-display-priper C-Win
PROCEDURE image-display-priper :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    define variable l-exist-priper as log no-undo .

    define buffer buf_trn-doc for ub.trn-doc.
    define buffer buf_clients for ub.clients.

    find first buf_trn-doc no-lock
      where buf_trn-doc.obj-type      = v-cntxt-obj-type
        and buf_trn-doc.obj-code      = v-cntxt-obj-code
        and buf_trn-doc.internal      = yes
        and buf_trn-doc.doc-type      = {&income}
        and buf_trn-doc.ext-doc-type  = {&TDEDT_Pri_Perem}
        and buf_trn-doc.status_       = {&wayb}
        and buf_trn-doc.flag_         = yes no-error .


      if available buf_trn-doc then do:
          assign
            l-exist-priper = yes
          .
      end.

    run image-display-update-visible in this-procedure
      (input l-exist-priper
      ,input 'priper':U
      ) .

  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE image-display-sales C-Win
PROCEDURE image-display-sales :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    define variable v-notes as character no-undo .
    define variable  l-exist-ck-gds as logical no-undo .
    define variable  l-exist-fls-ck as logical no-undo .
    define variable  l-exist-gds-sl as logical no-undo .
    define variable not-all-saled-chk    as logical   no-undo .
    define variable not-all-normal-chk   as logical   no-undo .
    define variable not-all-inkas-closed as logical   no-undo .
    if v-cntxt-obj-type = {&shop}
    and v-cntxt-db-num-obj = v-cntxt-db-num then do:
      run str/chk-inf.p
        (input  this-procedure
        ,input  v-cntxt-host-code-obj
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
        ,input  no /*interface*/
        ,input  no  /*from-ink*/
        ,input  ?   /*p-doc-rec*/
        ,output v-notes
        ,output l-exist-ck-gds /* not-all-saled-chk*/
        ,output l-exist-fls-ck /*not-all-normal-chk*/
        ,output l-exist-gds-sl /* not-all-inkas-closed*/
        ) no-error.
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры" 'str/chk-inf.p':U skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
    end.
    run image-display-update-visible in this-procedure
      (input l-exist-ck-gds
      ,input 'ck-gds':U
      ) .
    run image-display-update-visible in this-procedure
      (input l-exist-fls-ck
      ,input 'fls-ck':U
      ) .
    run image-display-update-visible in this-procedure
      (input l-exist-gds-sl
      ,input 'gds-sl':U
      ) .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE image-display-scales C-Win
PROCEDURE image-display-scales :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    def var l-exist-scales as log no-undo .

    assign
      l-exist-scales =
          can-find (first ub.scales-gds where
                          ub.scales-gds.obj-type = v-cntxt-obj-type and
                          ub.scales-gds.obj-code = v-cntxt-obj-code and
                          ub.scales-gds.to-send = yes no-lock)
    .

    run image-display-update-visible in this-procedure
      (input l-exist-scales
      ,input 'scales':U
      ) .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE image-display-twotpl C-Win
PROCEDURE image-display-twotpl :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable l-exist-twotpl as logical   no-undo .
define buffer buf_BatchProcess for ub.BatchProcess  .
l-exist-twotpl =   can-find (first  buf_BatchProcess no-lock
        where buf_BatchProcess.bp_type       = {&btpr-type-twotpl}
          and buf_BatchProcess.bp_status     = {&btpr-normal}
                ) .

    run image-display-update-visible in this-procedure
      (input l-exist-twotpl
      ,input 'twotpl':U
      ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE image-display-update-visible C-Win
PROCEDURE image-display-update-visible :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define input  parameter p-image-visible as logical   no-undo .
  define input  parameter p-image-name    as character no-undo .

  define buffer buf_temp-check-image for temp-check-image .

  do
  on error undo, return error return-value
  :
    if p-image-visible <> true
    then do:
      find first buf_temp-check-image
        where buf_temp-check-image.check-image-name = p-image-name
        no-error .
      if available buf_temp-check-image
      then do:
        find first temp-image where
                   temp-image.image-file-name = buf_temp-check-image.check-image-image-file-name no-error .
         if available temp-image then do:
          assign
            temp-image.image-visible = false
            temp-image.image-handle :sensitive = false
            temp-image.image-handle :visible = false
          .
        end.
        delete buf_temp-check-image .
      end.
    end.
    else do:
      find first buf_temp-check-image
        where buf_temp-check-image.check-image-name = p-image-name
        no-error .
      if available buf_temp-check-image
      then do:
        find first temp-image where
                   temp-image.image-file-name = buf_temp-check-image.check-image-image-file-name no-error .
         if available temp-image then do:
          assign
           /*temp-image.image-visible = false*/
            temp-image.image-handle :sensitive = true
            /*temp-image.image-handle :visible = false*/
          .
        end.
        end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE image-display-vozper C-Win
PROCEDURE image-display-vozper :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :

    define variable l-exist-vozper as log no-undo .

    define buffer buf_trn-doc for ub.trn-doc.
    define buffer buf_clients for ub.clients.

    _trn-doc:
    for each buf_trn-doc no-lock
      where
        (   buf_trn-doc.obj-type      = v-cntxt-obj-type
        and buf_trn-doc.obj-code      = v-cntxt-obj-code
        and buf_trn-doc.internal      = yes
        and buf_trn-doc.doc-type      = {&return}
        and buf_trn-doc.ext-doc-type  = {&TDEDT_Vozvrat_Perem}
        and buf_trn-doc.status_       = {&wayb}
        )
        or
        (   buf_trn-doc.obj-type      = v-cntxt-obj-type
        and buf_trn-doc.obj-code      = v-cntxt-obj-code
        and buf_trn-doc.internal      = yes
        and buf_trn-doc.doc-type      = {&return}
        and buf_trn-doc.ext-doc-type  = {&TDEDT_Vozvrat_Perem}
        and buf_trn-doc.status_       = {&permitted}
        )
    :
          assign
            l-exist-vozper = yes
          .
          leave _trn-doc.
    end .
    run image-display-update-visible in this-procedure
      (input l-exist-vozper
      ,input 'vozper':U
      ) .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE image-display-wth C-Win
PROCEDURE image-display-wth :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    define variable v-notes as character no-undo .
    DEFINE VARIABLE  l-exist-all-ck-wth as logical no-undo .
    DEFINE VARIABLE  l-exist-err-ck-wth as logical no-undo .
    DEFINE VARIABLE  l-exist-awth   as logical no-undo .
    DEFINE VARIABLE  l-exist-ck-wth as logical no-undo .
    if v-cntxt-obj-type = {&shop}
    and v-cntxt-db-num = v-cntxt-db-num-obj then do:
      run str/chk-winf.p (
                      input THIS-PROCEDURE
                      ,input v-cntxt-host-code-obj
                      ,input v-cntxt-obj-type
                      ,input v-cntxt-obj-code
                      ,input no
                      ,input no
                      ,input ?
                      ,output v-notes
                      ,output l-exist-ck-wth
                      ,output l-exist-err-ck-wth
                      ,output l-exist-awth) no-error.
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры" 'str/chk-winf.p':U skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
    end.
    assign
      l-exist-ck-wth = l-exist-ck-wth or l-exist-err-ck-wth
    .

    run image-display-update-visible in this-procedure
      (input l-exist-ck-wth
      ,input 'ck-wth':U
      ) .
    run image-display-update-visible in this-procedure
      (input l-exist-awth
      ,input 'awth':U
      ) .

  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE load-tnved C-Win
PROCEDURE load-tnved :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    define variable custvalue   as character no-undo .
    define variable custtype    as character no-undo .
    { gbl/conf-rd.i
      "'is-custm':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      no
      custvalue
      custtype
      no-error
    }
    if custvalue = "yes"
    then do:
      if not can-find (first tt-tnved)
      then do:
        get-key-value section "custom" key "rep-tnved" value tnved-fn.
        /* todo - заменить временную таблицу ТНВЕД на таблицу базы данных
          tnved-head
          tnved-item
        */
        run ref/l-tnved.p
          (input search(tnved-fn)
          ).
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE logo C-Win
PROCEDURE logo :
/*----------------------------------------------------------
включить или выключить картинку с логотипом
----------------------------------------------------------*/
/* !!!
if not lookup (to-ARM, {&stock_acc-office_fixed-assets_shop_office_admin_ext-acc-office_fin_restaurant}) > 0 then
  return error.
*/

do with frame {&frame-name}:
  /* выключить картинку */
  if  v-logo-image-visible
  and v-cntxt-level = {&cntxt-object}
  then do:
    assign
/*      v-logo-image-visible = logo-image:load-image (?)*/
      v-logo-image-visible = false
    .
/*    logo-image:move-to-bottom().*/
/*    rect-bar-code:move-to-top().*/
  end.
  /* включить картинку */
/*  else do:                                                                */
/*    if not v-logo-image-visible then do:                                  */
/*      assign                                                              */
/*         v-logo-image-visible = logo-image :load-image("cmp/ith150.gif":U)*/
/*      .                                                                   */
/*    end.                                                                  */
/*/*    rect-bar-code:move-to-bottom().*/                                   */
/*    logo-image:move-to-top().                                             */
/*  end.                                                                    */
  /* спрятать то, что под картинкой */
/*  if v-logo-image-visible then do:           */
/*      assign                                 */
/*         fi-bar-code       :visible = FALSE  */
/*         fi-gds-artic      :visible = FALSE  */
/*         fi-gds-name       :visible = FALSE  */
/*         fi-gds-qnty       :visible = FALSE  */
/*         fi-gds-price-sale :visible = FALSE  */
/*         b-open-gds        :visible = FALSE  */
/*         b-search-bar-code :visible = FALSE  */
/*         fi-bar-code       :sensitive = FALSE*/
/*         b-open-gds        :sensitive = FALSE*/
/*         b-search-bar-code :sensitive = FALSE*/
/*      .                                      */
/*  end.                                       */
/*  /* включить то, что под картинкой */       */
/*  else do:                                   */
/*      assign                                 */
/*         fi-bar-code       :visible = true   */
/*         fi-gds-artic      :visible = true   */
/*         fi-gds-name       :visible = true   */
/*         fi-gds-qnty       :visible = true   */
/*         fi-gds-price-sale :visible = true   */
/*         b-open-gds        :visible = true   */
/*         b-search-bar-code :visible = true   */
/*         fi-bar-code       :sensitive = true */
/*         b-open-gds        :sensitive = true */
/*         b-search-bar-code :sensitive = true */
/*      .                                      */
/*    apply "entry" to fi-bar-code.            */
/*  end.                                       */
end.
END PROCEDURE. /* logo */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mainmenu-disp-mutable C-Win
PROCEDURE mainmenu-disp-mutable :
/* установка, проверка и вывод переменной информации */
define output parameter p-cur-date-error-code   as integer          no-undo.

  define variable v-obj-shift           as logical      no-undo .
  define variable v-shift-date          as date         no-undo .
  define variable v-shift-num           as integer      no-undo .
  define variable v-shift-name          as character    no-undo .
  define variable v-result              as integer      no-undo .
  define variable v-time                as integer      no-undo .

/*  message*/
/*    'mainmenu-disp-mutable':U*/
/*    view-as alert-box error .*/

  do
  on error undo, return error return-value
  :
    /* проверка текущей директории */
    assign
      file-info :file-name = '.'
    .

    if v-work-file = ""
    then do:
      assign
        v-work-file = file-info :full-pathname
      .
    end.
    else do:
      if v-work-file <> file-info :full-pathname
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Рабочая директория изменилась" skip
          "Новая рабочая директория" file-info :full-pathname skip
          "Старая рабочая директория" v-work-file skip
          view-as alert-box error .

        run SetCurrentDirectoryA
          (input  v-work-file
          ,output v-result
          ).

        assign
          file-info :file-name = '.'
        .
        if v-work-file = file-info :full-pathname
        then do:
          message
            "Рабочая директория восстановлена" skip
            "Текущая рабочая директория" file-info :full-pathname skip
            view-as alert-box information .
        end.
        else do:
          message
            "Рабочая директория не восстановлена" skip
            "Текущая рабочая директория" file-info :full-pathname skip
            "Пожалуйста завершите работу программы" skip
            view-as alert-box error .
        end.
      end.
    end.

    do with frame {&frame-name}
    :
      assign
        fi-obj-date           = ?
        fi-close-date         = ?
        fi-shift-date         = ?
        fi-shift-name         = '':U
        fi-shift-order        = '':U
      .

        if v-cntxt-level = {&cntxt-global}
        or v-cntxt-level = {&cntxt-firm}
        then do:
            
            run cur-time in this-procedure (
                output fi-obj-date
              , output v-time ) .
            assign
                fi-shift-date :visible      = no
                fi-shift-name :visible      = no
                fi-shift-order:visible      = no
                b-show-date   :visible      = no
                fi-obj-date   :screen-value = string(fi-obj-date,"99/99/9999":U)
                fi-obj-date   :visible      = yes
            .
        end.
        if v-cntxt-level = {&cntxt-object}
        then do:
            run adm/cur-date.w (
                  input this-procedure
                , input v-cntxt-obj-type
                , input v-cntxt-obj-code
                , input '':u
                , output p-cur-date-error-code
            ) no-error .
            if error-status :error
            then do:
                message
                "Ошибка установки текущей даты на объекте!"
                view-as alert-box error.
                undo, return error. /* нештатный выход из cur-date.w */
            end.
            { gbl/curobjdt.i
                v-cntxt-obj-type
                v-cntxt-obj-code
                fi-obj-date
                no-error
            }
            if error-status :error
            then do:
                message
                "Текущая дата не установлена!"
                view-as alert-box error.
                undo, return error. /* нештатный выход из cur-date.w */
            end.
            /* проверяем, включены ли смены на объекте */
            { gbl/objat.i
                v-cntxt-obj-type
                v-cntxt-obj-code
                "'shift-on=request'"
                v-obj-shift
                no-error
            }
            if error-status :error
            then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при запуске процедуры objat" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            return.
            end.
            if v-obj-shift = true
            then do:
                { gbl/curshift.i
                    v-cntxt-obj-type
                    v-cntxt-obj-code
                    v-shift-date
                    v-shift-num
                    v-shift-name
                    no-error
                }
                if error-status :error
                then do:
                    assign
                        fi-shift-date         = ?
                        fi-shift-name         = '':U
                        fi-shift-order        = '':U
                    .
                end.
                else do:
                    assign
                        fi-shift-date         = string(v-shift-date, '99/99/9999':U)
                        fi-shift-name         = v-shift-name
                        fi-shift-order        = string(v-shift-num)
                    .
                end.
                assign
                    fi-shift-date:screen-value  = fi-shift-date 
                    fi-shift-name:screen-value  = fi-shift-name
                    fi-shift-order:screen-value = fi-shift-order
                    fi-shift-date:visible       = yes
                    fi-shift-name:visible       = yes
                    fi-shift-order:visible      = yes
                .
            end.
            else do:
               assign
                  fi-shift-date :visible       = no
                  fi-shift-name :visible       = no
                  fi-shift-order:visible       = no
               .
            end.
            assign
                fi-obj-date:screen-value = string(fi-obj-date, '99/99/9999':U)
               
                fi-obj-date:visible      = yes
                b-show-date:visible      = yes
            .
            
            run proc-check-RVD in this-procedure .
            
            run proc-check-place-imp in this-procedure .
        end.

        run proc-fi-close-date in this-procedure
            ( output fi-close-date  ) .
        if fi-close-date = ? then hide fi-close-date.
        else assign 
                fi-close-date :screen-value  = string(fi-close-date, '99/99/9999':U)
                fi-close-date :visible       = yes 
             .

    end.

    run update-image in this-procedure
      no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при обновлении картинок" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      return error.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mainmenu-menu-item-clear C-Win
PROCEDURE mainmenu-menu-item-clear :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define buffer buf_temp-menu-item for temp-menu-item .

  do
  on error undo, return error return-value
  :
    for each buf_temp-menu-item
    on error undo, return error return-value
    :
      delete buf_temp-menu-item .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mainmenu-menu-item-create C-Win
PROCEDURE mainmenu-menu-item-create :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-item-code      as integer   no-undo .
  define input  parameter p-item-type      as character no-undo .
  define input  parameter p-item-name      as character no-undo .
  define input  parameter p-item-id        as character no-undo .
  define input  parameter p-item-procedure as character no-undo .
  define input  parameter p-parent-code    as integer   no-undo .
  define input  parameter p-show-menu-item as logical   no-undo .

  define buffer buf_temp-menu-item for temp-menu-item .
  define buffer buf_parent_temp-menu-item for temp-menu-item .

  define variable v-parent-full-name as character no-undo .

  do
  on error undo, return error return-value
  :
    IF CAN-FIND ( FIRST buf_temp-menu-item
                  WHERE buf_temp-menu-item.item-code = p-item-code
                  NO-LOCK
                ) THEN RETURN.
    create buf_temp-menu-item .
    assign
      buf_temp-menu-item.item-code      = p-item-code
      buf_temp-menu-item.item-type      = p-item-type
      buf_temp-menu-item.item-name      = p-item-name
      buf_temp-menu-item.item-id        = p-item-id
      buf_temp-menu-item.item-procedure = p-item-procedure
      buf_temp-menu-item.parent-code    = p-parent-code
      buf_temp-menu-item.show-menu-item = p-show-menu-item
    .

    find first buf_parent_temp-menu-item
      where buf_parent_temp-menu-item.item-code = buf_temp-menu-item.parent-code
      no-error .
    if not available buf_parent_temp-menu-item
    then do:
      assign
        buf_temp-menu-item.num-level = 0
        v-parent-full-name           = ""
      .
    end.
    else do:
      assign
        buf_temp-menu-item.num-level = buf_parent_temp-menu-item.num-level + 1
        v-parent-full-name           = buf_parent_temp-menu-item.full-name
      .
      if buf_parent_temp-menu-item.show-menu-item = false
      then do:
        assign
          buf_temp-menu-item.show-menu-item = false
        .
      end.
    end.

    assign
      buf_temp-menu-item.show-child   = ""
      buf_temp-menu-item.display-name = replace(buf_temp-menu-item.item-name
                                               ,"&"
                                               ,""
                                               )
      buf_temp-menu-item.full-name    = v-parent-full-name
                                      + (if v-parent-full-name <> ""
                                         then '/':U
                                         else '':U
                                        )
                                      + replace(buf_temp-menu-item.item-name
                                               ,"&"
                                               ,""
                                               )
    .
    if buf_temp-menu-item.item-type = 's-m':U
    then do:
      assign
        buf_temp-menu-item.show-child = '+':U
      .
    end.

    define variable v-item-value     as logical   no-undo .
    define variable v-procedure-type as character no-undo .
    define variable v-item-procedure as character no-undo .

    if buf_temp-menu-item.item-type = 'm-t':U
    then do:
      assign
        v-procedure-type = entry(1, buf_temp-menu-item.item-procedure, {&comma-char})
        v-item-procedure = entry(2, buf_temp-menu-item.item-procedure, {&comma-char})
      .

      case v-procedure-type
      :
        when 'int':U
        then do:
          run value(v-item-procedure) in g#dm-menu-handle
            (input  'get':U
            ,input-output v-item-value
            ) .
        end.
        when 'ext':U
        then do:
          run value(v-item-procedure)
            (input  'get':U
            ,input-output v-item-value
            ) .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Внутренняя ошибка" skip
            "Код пункта меню" buf_temp-menu-item.item-code skip
            "Неизвестный тип процедуры" v-procedure-type skip
            "Процедура" v-item-procedure skip
            view-as alert-box error .
        end.
      end case .

      if v-item-value = true
      then do:
        assign
          buf_temp-menu-item.display-name = '*':U + ' ':U + buf_temp-menu-item.display-name
        .
      end.
      else do:
        assign
          buf_temp-menu-item.display-name = '_':U + ' ':U + buf_temp-menu-item.display-name
        .
      end.
    end.

    if buf_temp-menu-item.item-type = 'r-l':U
    then do:
      assign
        buf_temp-menu-item.display-name = fill(" ", buf_temp-menu-item.num-level * 2)
                                        + fill('-', 80)
        buf_temp-menu-item.full-name    = ""
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mainmenu-menu-item-create-parent C-Win
PROCEDURE mainmenu-menu-item-create-parent :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-parent-code as integer   no-undo .

  define buffer buf_temp-menu-item      for temp-menu-item .
  define buffer buf_menu-item           for ub.menu-item .
  define buffer buf_temp-menu-item-open for temp-menu-item-open .

  do
  on error undo, return error return-value
  :
    find first buf_temp-menu-item
      where buf_temp-menu-item.item-code = p-parent-code
      no-error .
    if not available buf_temp-menu-item
    then do:
      find first buf_menu-item no-lock
        where buf_menu-item.menu-code = v-cntxt-menu-code
          and buf_menu-item.item-code = p-parent-code
        no-error .
      if not available buf_menu-item
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Ошибка при поиске пункта меню" skip
          "menu-code" v-cntxt-menu-code skip
          "item-code" p-parent-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      run mainmenu-menu-item-create-parent in this-procedure
        (input  buf_menu-item.parent-code
        ) .
      find first buf_temp-menu-item
        where buf_temp-menu-item.item-code = buf_menu-item.parent-code
        .
      assign
        buf_temp-menu-item.show-child = '-':U
      .

      find first buf_temp-menu-item-open
        where buf_temp-menu-item-open.item-code = buf_temp-menu-item.item-code
        no-error .
      if not available buf_temp-menu-item-open
      then do:
        create buf_temp-menu-item-open .
        assign
          buf_temp-menu-item-open.item-code = buf_temp-menu-item.item-code
        .
      end.

      run proc-create-menu-item in g#dm-menu-handle
        (input  buf_menu-item.parent-code
        ,input  ?
        ,input  false
        ,input  true
        ) .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mainmenu-menu-item-open C-Win
PROCEDURE mainmenu-menu-item-open :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-item-code as integer   no-undo .

  define buffer buf_temp-menu-item for temp-menu-item .

  define variable v-item-id as character no-undo .

  do
  on error undo, return error return-value
  :
    open query br-menu-item
      for each temp-menu-item
        where temp-menu-item.show-menu-item = true
      by temp-menu-item.item-code .

    if p-item-code <> 0
    then do:
      find first buf_temp-menu-item
        where buf_temp-menu-item.item-code = p-item-code
        no-error .
      if  available buf_temp-menu-item
      and buf_temp-menu-item.show-menu-item = true
      then do:
        reposition br-menu-item to rowid rowid(buf_temp-menu-item) .
      end.
    end.

    run menu-item-display-full-name in this-procedure .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mainmenu-set-menu-toggle C-Win
PROCEDURE mainmenu-set-menu-toggle :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-item-code  as integer   no-undo .
  define input  parameter p-item-value as logical   no-undo .

  define buffer buf_temp-menu-item for temp-menu-item .

  do
  on error undo, return error return-value
  :
    find first buf_temp-menu-item
      where buf_temp-menu-item.item-code = p-item-code
      no-error .
    if available buf_temp-menu-item
    then do:
      if p-item-value = true
      then do:
        assign
          substring(buf_temp-menu-item.display-name, 1, 1) = '*':U
        .
      end.
      else do:
        assign
          substring(buf_temp-menu-item.display-name, 1, 1) = '_':U
        .
      end.
    end.
    else do:
      message
        "Пункт меню не найден" skip
        p-item-code skip
        view-as alert-box error .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mainmenu-show-item C-Win
PROCEDURE mainmenu-show-item :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-item-code as integer   no-undo .

  do
  on error undo, return error return-value
  :
    run mainmenu-menu-item-create-parent in this-procedure
      (input  p-item-code
      ) .

    run mainmenu-menu-item-open in this-procedure
      (input p-item-code
      ) .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mainmenu-start-item C-Win
PROCEDURE mainmenu-start-item :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-item-code as integer   no-undo .

  define buffer buf_menu-user-call for ubflt.menu-user-call .
  define buffer buf_temp-menu-item for temp-menu-item .
  define buffer buf_menu-item      for ub.menu-item .

  do
  on error undo, return error return-value
  :
    assign
      v-menu-user-call-rowid = ?
    .

    run mainmenu-menu-item-create-parent in this-procedure
      (input  p-item-code
      ) .

    find first buf_temp-menu-item
      where buf_temp-menu-item.item-code = p-item-code
      no-error .
    if not available buf_temp-menu-item
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Не найден пункт меню с кодом" p-item-code skip
        view-as alert-box error .
      return . /* --->>>--- */
    end.
    define buffer buf_menu-group for ub.menu-group .    
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code       = v-cntxt-menu-code
        and buf_menu-group.menu-group-code = v-cntxt-menu-group-code
      no-error .
    if available buf_menu-group and buf_menu-group.menu-group-id eq "adm"
    then 
       run trg/userlog.p (
                input 'run-proc'
                , input ('Выбран пункт меню '   
                + buf_temp-menu-item.full-name +  '"' + {&delim-key} + buf_temp-menu-item.item-procedure )
                , input ?
                , input ?
                , input "") no-error.
    define variable v-sys-time-mjd as decimal   no-undo .
    define variable v-arm-title    as character no-undo .

    run gbl/getustat.p
      (input  v-userio-id
      ,output v-sys-time-mjd
      ,output v-userio-ai-read
      ,output v-userio-ai-write
      ,output v-userio-bi-read
      ,output v-userio-bi-write
      ,output v-userio-db-access
      ,output v-userio-db-read
      ,output v-userio-db-write
      ) .

    define variable v-menu-user-call-id as integer   no-undo .

    assign
      v-menu-user-call-id = dynamic-next-value( "s-menu-user-call":U, "ubflt":U)
    .

    find first buf_menu-user-call exclusive-lock
      where buf_menu-user-call.db-num                 = v-cntxt-db-num
        and buf_menu-user-call.user-id                = v-cntxt-user-id
        and buf_menu-user-call.stop-menu-user-call-id = 0
      no-error .
    if available buf_menu-user-call
    then do:
      assign
        buf_menu-user-call.stop-mjd               = v-sys-time-mjd
        buf_menu-user-call.stop-menu-user-call-id = v-menu-user-call-id
      .
      assign
        v-menu-user-call-id = dynamic-next-value( "s-menu-user-call":U, "ubflt":U)
      .
    end.

    create buf_menu-user-call .
    assign
      buf_menu-user-call.db-num                 = v-cntxt-db-num
      buf_menu-user-call.menu-user-call-id      = v-menu-user-call-id
      buf_menu-user-call.user-id                = v-cntxt-user-id
      buf_menu-user-call.menu-code              = v-cntxt-menu-code
      buf_menu-user-call.start-mjd              = v-sys-time-mjd
      buf_menu-user-call.stop-mjd               = 0
      buf_menu-user-call.stop-menu-user-call-id = 0
      buf_menu-user-call.menu-code              = v-cntxt-menu-code
      buf_menu-user-call.item-id                = buf_temp-menu-item.item-id
      buf_menu-user-call.cntxt-level            = v-cntxt-level
      buf_menu-user-call.cntxt-host-code        = v-cntxt-host-code-obj
      buf_menu-user-call.cntxt-obj-type         = v-cntxt-obj-type
      buf_menu-user-call.cntxt-obj-code         = v-cntxt-obj-code
      buf_menu-user-call.item-procedure         = buf_temp-menu-item.item-procedure
      buf_menu-user-call.full-name              = buf_temp-menu-item.full-name
      buf_menu-user-call.param-value            = ''
      buf_menu-user-call.userio-ai-read         = 0
      buf_menu-user-call.userio-ai-write        = 0
      buf_menu-user-call.userio-bi-read         = 0
      buf_menu-user-call.userio-bi-write        = 0
      buf_menu-user-call.userio-db-access       = 0
      buf_menu-user-call.userio-db-read         = 0
      buf_menu-user-call.userio-db-write        = 0
      buf_menu-user-call.connect-usr            = string(v-connect-usr)
      buf_menu-user-call.connect-device         = v-connect-device
    .

    assign
      v-menu-user-call-rowid = rowid(buf_menu-user-call)
    .
    
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mainmenu-stop-item C-Win
PROCEDURE mainmenu-stop-item :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define buffer buf_menu-user-call for ubflt.menu-user-call .

  define variable v-sys-time-mjd         as decimal   no-undo .
  define variable v-new-userio-ai-read   as decimal   no-undo .
  define variable v-new-userio-ai-write  as decimal   no-undo .
  define variable v-new-userio-bi-read   as decimal   no-undo .
  define variable v-new-userio-bi-write  as decimal   no-undo .
  define variable v-new-userio-db-access as decimal   no-undo .
  define variable v-new-userio-db-read   as decimal   no-undo .
  define variable v-new-userio-db-write  as decimal   no-undo .

  do
  on error undo, return error return-value
  :
    if v-menu-user-call-rowid = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Неопределенное значение указателя v-menu-user-call-rowid" skip
        "Работа программы будет продолжена" skip
        view-as alert-box error .
      return . /* --->>>--- */
    end.

    do transaction
    on error undo, return error return-value
    :

      find first buf_menu-user-call exclusive-lock
        where rowid(buf_menu-user-call) = v-menu-user-call-rowid
        no-error .
      if not available buf_menu-user-call
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Ошибка при поиске записи buf_menu-user-call" skip
          "Неверное значение указателя v-menu-user-call-rowid" skip
          "Работа программы будет продолжена" skip
          view-as alert-box error .
        return . /* --->>>--- */
      end.
   /*   define buffer buf_menu-group for ub.menu-group .    
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code       = v-cntxt-menu-code
        and buf_menu-group.menu-group-code = v-cntxt-menu-group-code
      no-error .
    if available buf_menu-group and buf_menu-group.menu-group-id eq "adm"
    then 
         run trg/userlog.p (
                  input 'run-proc'
                , input ('Завершено выполнение процедуры '  
                  + buf_menu-user-call.full-name +  '"' + {&delim-key} + buf_menu-user-call.item-procedure )
                , input ?
                , input ?
                , input "") no-error.*/
      run gbl/getustat.p
        (input  v-userio-id
        ,output v-sys-time-mjd
        ,output v-new-userio-ai-read
        ,output v-new-userio-ai-write
        ,output v-new-userio-bi-read
        ,output v-new-userio-bi-write
        ,output v-new-userio-db-access
        ,output v-new-userio-db-read
        ,output v-new-userio-db-write
        ) .

      define variable v-menu-user-call-id as integer   no-undo .
      assign
        v-menu-user-call-id = dynamic-next-value( "s-menu-user-call":U, "ubflt":U)
      .

      assign
        buf_menu-user-call.stop-mjd               = v-sys-time-mjd
        buf_menu-user-call.stop-menu-user-call-id = v-menu-user-call-id
        buf_menu-user-call.userio-ai-read         = v-new-userio-ai-read
                                                  - v-userio-ai-read
        buf_menu-user-call.userio-ai-write        = v-new-userio-ai-write
                                                  - v-userio-ai-write
        buf_menu-user-call.userio-bi-read         = v-new-userio-bi-read
                                                  - v-userio-bi-read
        buf_menu-user-call.userio-bi-write        = v-new-userio-bi-write
                                                  - v-userio-bi-write
        buf_menu-user-call.userio-db-access       = v-new-userio-db-access
                                                  - v-userio-db-access
        buf_menu-user-call.userio-db-read         = v-new-userio-db-read
                                                  - v-userio-db-read
        buf_menu-user-call.userio-db-write        = v-new-userio-db-write
                                                  - v-userio-db-write
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mainmenu_getcntxt C-Win
PROCEDURE mainmenu_getcntxt :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-cntxt-db-num        as integer   no-undo .
  define output parameter p-cntxt-user-id       as character no-undo .
  define output parameter p-cntxt-level         as character no-undo .
  define output parameter p-cntxt-host-code-obj as integer   no-undo .
  define output parameter p-cntxt-obj-type      as character no-undo .
  define output parameter p-cntxt-obj-code      as integer   no-undo .
  define output parameter p-cntxt-db-num-obj    as integer   no-undo .
  define output parameter p-cntxt-is-admin      as logical   no-undo .

  do
  on error undo, return error
  :
    assign
      p-cntxt-db-num        = v-cntxt-db-num
      p-cntxt-user-id       = v-cntxt-user-id
      p-cntxt-level         = v-cntxt-level
      p-cntxt-host-code-obj = v-cntxt-host-code-obj
      p-cntxt-obj-type      = v-cntxt-obj-type
      p-cntxt-obj-code      = v-cntxt-obj-code
      p-cntxt-db-num-obj    = v-cntxt-db-num-obj
      p-cntxt-is-admin      = v-cntxt-is-admin
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE menu-item-choose C-Win
PROCEDURE menu-item-choose :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
    define variable v-procedure-parameter as character no-undo .
    define variable v-load                as logical      no-undo.
    define variable v-new                 as logical      no-undo.
    define variable v-cur-date-error-code as integer      no-undo.

    define buffer buf_menu-head    for ub.menu-head.
do
on error undo, return error return-value
:
    run check-load-menu IN THIS-PROCEDURE
        ( OUTPUT v-load
        , output v-new
        ) .
    IF v-load = TRUE then do:
        message
            "Производится загрузка меню другим пользователем." SKIP
            "Для корректной работы системы необходимо подождать."
        view-as alert-box.

        run waitfram-show in this-procedure ( input "Происходит загрузка меню. Ждите..." ).
        REPEAT :
            find first buf_menu-head
            where buf_menu-head.menu-code = {&menu-code-main}
            exclusive-lock
            no-error
            no-wait
            .
            IF AVAILABLE buf_menu-head THEN DO:
            run waitfram-hide in this-procedure .
            release buf_menu-head.
            /* удаляем процедуру dm-menu в которой хранятся реакции на выбор пунктов меню */
            run delete-dm-menu in this-procedure
                no-error .
            run create-dm-menu in this-procedure
                no-error .
            if error-status :error
            then do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Ошибка при создании меню" skip
                    error-status :get-message(1) skip
                    return-value skip
                view-as alert-box error .
                undo, return error return-value .
            end.
            RETURN.
            END. /* exit condition */
            pause 10 no-message.
        END. /* REPEAT */
    end.
    IF v-new then do:
        message
            "Другой пользователь произвел перезагрузку меню." SKIP
            "Для корректной работы меню будет обновлено."
        view-as alert-box.
        run delete-dm-menu in this-procedure
            no-error .
        run create-dm-menu in this-procedure
            no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description skip
            "Ошибка при создании меню" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
            undo, return error return-value .
        end.
        RETURN.
    end.

    if available temp-menu-item
    then do:
        case temp-menu-item.item-type
        :
            when 'm-i':U or
            when 'm-t':U
            then do:
            if num-entries(temp-menu-item.item-procedure, {&comma-char}) > 2
            then do:
                assign
                v-procedure-parameter = entry(3, temp-menu-item.item-procedure, {&comma-char})
                .
            end.
            else do:
                assign
                v-procedure-parameter = '':U
                .
            end.

            run dm-menu-choose-item in g#dm-menu-handle
                (input  temp-menu-item.item-type
                ,input  temp-menu-item.item-code
                ,input  entry(1, temp-menu-item.item-procedure, {&comma-char})
                ,input  entry(2, temp-menu-item.item-procedure, {&comma-char})
                ,input  v-procedure-parameter
                ) .
            if temp-menu-item.item-type = 'm-t':U
            then do:
                display
                get-display-name(buffer temp-menu-item) @ v-show-display-name
                with browse br-menu-item .
            end.
            end.
            when 's-m':U
            then do:
            case temp-menu-item.show-child
            :
                when '+':U
                then do:
                run menu-item-expand in this-procedure .
                end.
                when '-':U
                then do:
                run menu-item-collapse in this-procedure .
                end.
                otherwise do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Внутренняя ошибка" skip
                    "Неизвестное значение поля show-child" skip
                    "temp-menu-item.show-child" temp-menu-item.show-child skip
                    view-as alert-box error .
                end.
            end case .

            run mainmenu-menu-item-open in this-procedure
                (input  temp-menu-item.item-code
                ) .
            end.
        end case .
/*        run mainmenu-disp-mutable in this-procedure (*/
/*            output v-cur-date-error-code             */
/*        ) no-error.                                  */
/*        if error-status :error                       */
/*        or v-cur-date-error-code > 0                 */
/*        then do:                                     */
/*            undo, return error .                     */
/*        end.                                         */
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE menu-item-collapse C-Win
PROCEDURE menu-item-collapse :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define buffer buf_temp-menu-item-open for temp-menu-item-open .

  do
  on error undo, return error return-value
  :
    if  available temp-menu-item
    and temp-menu-item.item-type = 's-m':U
    and temp-menu-item.show-child = '-':U
    then do:
      assign
        temp-menu-item.show-child = '+':U
      .

      find first buf_temp-menu-item-open
        where buf_temp-menu-item-open.item-code = temp-menu-item.item-code
        no-error .
      if available buf_temp-menu-item-open
      then do:
        delete buf_temp-menu-item-open .
      end.

      run delete-menu-item in this-procedure
        (input  temp-menu-item.item-code
        ) .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE menu-item-copy-full-name C-Win
PROCEDURE menu-item-copy-full-name :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-arm-title      as character no-undo .

  do
  on error undo, return error return-value
  :
    do with frame {&frame-name}
    :
      run gbl/clipbrd.p
        (input  temp-menu-item.full-name
        ) .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE menu-item-display-full-name C-Win
PROCEDURE menu-item-display-full-name :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
   
    if available temp-menu-item
    then do:
      do with frame {&frame-name}
      :
        assign
          ed-menu-item-name :screen-value = fi-menu-group-name + "/" + temp-menu-item.full-name
        .
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE menu-item-expand C-Win
PROCEDURE menu-item-expand :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define buffer buf_temp-menu-item-open for temp-menu-item-open .

  do
  on error undo, return error return-value
  :
    if  available temp-menu-item
    and temp-menu-item.item-type = 's-m':U
    and temp-menu-item.show-child = '+':U
    then do:
      assign
        temp-menu-item.show-child = '-':U
      .

      find first buf_temp-menu-item-open
        where buf_temp-menu-item-open.item-code = temp-menu-item.item-code
        no-error .
      if not available buf_temp-menu-item-open
      then do:
        create buf_temp-menu-item-open .
        assign
          buf_temp-menu-item-open.item-code = temp-menu-item.item-code
        .
      end.

      run proc-create-menu-item in g#dm-menu-handle
        (input  temp-menu-item.item-code
        ,input  ?
        ,input  false
        ,input  true
        ) .

      run menu-item-expand-open in this-procedure
        (input temp-menu-item.item-code
        ) .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE menu-item-expand-open C-Win
PROCEDURE menu-item-expand-open :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-item-code as integer   no-undo .

  define buffer buf_temp-menu-item for temp-menu-item .
  define buffer buf_temp-menu-item-open for temp-menu-item-open .

  do
  on error undo, return error return-value
  :
    for each buf_temp-menu-item
      where buf_temp-menu-item.parent-code = p-item-code
    on error undo, return error return-value
    :
      find first buf_temp-menu-item-open
        where buf_temp-menu-item-open.item-code = buf_temp-menu-item.item-code
        no-error .
      if  available buf_temp-menu-item-open
      and buf_temp-menu-item.show-child = '+':U
      then do:
        assign
          buf_temp-menu-item.show-child = '-':U
        .
        run proc-create-menu-item in g#dm-menu-handle
          (input  buf_temp-menu-item.item-code
          ,input  ?
          ,input  false
          ,input  true
          ) .
      end.

      run menu-item-expand-open in this-procedure
        (input buf_temp-menu-item.item-code
        ) .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE menu-item-open-in-multiedit C-Win
PROCEDURE menu-item-open-in-multiedit :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-ok          as logical   no-undo .

  define buffer buf_menu-item for ub.menu-item .

  do
  on error undo, return error return-value
  :
    if  available temp-menu-item
    and temp-menu-item.item-type <> 's-m':u
    then do:
      find first buf_menu-item no-lock
        where buf_menu-item.item-code = temp-menu-item.item-code
        no-error .
      if not available buf_menu-item
      then do:
        message
          "Не найден пункт меню с кодом" temp-menu-item.item-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      assign
        v-ok = true
      .
      message
        "Открыть файл в multiedit" skip
        "Код пункта меню" temp-menu-item.item-code skip
        "Идентификатор пункта меню" buf_menu-item.item-id skip
        "Процедура" temp-menu-item.item-procedure skip
        "Продолжить?"
        view-as alert-box question buttons yes-no update v-ok .
      if v-ok = true
      then do:
        run utl/meopen.p
          (input buf_menu-item.item-id
          ,input temp-menu-item.item-procedure
          ) .
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-check-place-imp C-Win
procedure proc-check-place-imp :
  define buffer buf_place for ub.place .
  define buffer buf_place-attr for ub.place-attr .
  define buffer buf_pl-gds for ub.pl-gds .
  define buffer buf_goods for ub.goods .
  
  define variable v-pending-message as character no-undo .
  define variable v-applied-message as character no-undo .
  define variable v-ok-pending as logical no-undo .
  define variable v-ok-applied as logical no-undo .
  define variable v-place-mess as character no-undo .
  
  assign
    v-ok-pending = no
    v-ok-applied = no
    v-pending-message = "Внимание! После закрытия смены будет осуществлен переход на новые градуировочные таблицы для резервуаров:"
    v-applied-message = "Внимание! Новые градуировочные таблицы применены для резервуаров:"
  .
  
  for each buf_place-attr no-lock where buf_place-attr.obj-type = v-cntxt-obj-type
                                    and buf_place-attr.obj-code = v-cntxt-obj-code
                                    and buf_place-attr.attr-code = {&message-table-version}
  :
    find first buf_place no-lock where buf_place.obj-type = buf_place-attr.obj-type
                                   and buf_place.obj-code = buf_place-attr.obj-code
                                   and buf_place.pl-code  = buf_place-attr.pl-code
                                   no-error .
    find first buf_pl-gds no-lock where buf_pl-gds.obj-type = buf_place-attr.obj-type
                                    and buf_pl-gds.obj-code = buf_place-attr.obj-code
                                    and buf_pl-gds.pl-code  = buf_place-attr.pl-code
                                    no-error .
    if available buf_pl-gds
    then do :
      find first buf_goods no-lock where buf_goods.gds-code = buf_pl-gds.gds-code no-error .
    end .
    if buf_place-attr.attr-value = "pending"
    then do :
      assign
        v-place-mess = "Резервуар " + (if available buf_place then buf_place.loc1 else "?") +
                       " код " + string(buf_place-attr.pl-code) +
                       " " + (if available buf_place then buf_place.pl-name else "") +
                       " c " + (if available buf_goods then buf_goods.gds-name else "?")
        v-ok-pending = yes
        v-pending-message = v-pending-message + {&new-line} + v-place-mess 
      .
    end .
    if buf_place-attr.attr-value = "applied"
    then do :
      assign
        v-place-mess = "Резервуар " + (if available buf_place then buf_place.loc1 else "?") +
                       " код " + string(buf_place-attr.pl-code) + 
                       " " + (if available buf_place then buf_place.pl-name else "") +
                       " c " + (if available buf_goods then buf_goods.gds-name else "?")
        v-ok-applied = yes
        v-applied-message = v-applied-message + {&new-line} + v-place-mess 
      .
    end .
  end .
  if v-ok-pending
  then do :
    run ref/message_place-imp.w (input v-pending-message) .
  end .
  if v-ok-applied
  then do :
    run ref/message_place-imp.w (input v-applied-message) .
  end .
  for each buf_place-attr exclusive-lock where buf_place-attr.obj-type = v-cntxt-obj-type
                                           and buf_place-attr.obj-code = v-cntxt-obj-code
                                           and buf_place-attr.attr-code = {&message-table-version}
  :
    delete buf_place-attr .
  end .
end procedure .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-check-RVD C-Win
procedure proc-check-RVD :
  define buffer buf_place for ub.place .
  define buffer buf_place-attr for ub.place-attr .
  define buffer buf_clients-attr for ub.clients-attr .
  define buffer buf_pl-gds for ub.pl-gds .
  define buffer buf_goods for ub.goods .
  define buffer buf_place-attr2 for ub.place-attr .
  
  define variable v-message as character no-undo .
  define variable v-attr-value as character no-undo .
  define variable v-attr-type as character no-undo .
  define variable v-ok as logical no-undo init no .
  
  if v-cntxt-db-num = 0 then return .
  
  find first buf_place-attr no-lock where buf_place-attr.obj-type = v-cntxt-obj-type
                                      and buf_place-attr.obj-code = v-cntxt-obj-code
                                      and buf_place-attr.attr-code = {&place-need-RVD-rvs}
                                      and logical(buf_place-attr.attr-value) = yes 
                                      no-error .
  if available buf_place-attr
  then do :
    v-message = "Установлено разрешение РВД. Необходимо выполнить ручные замеры параметров НП и внести их в документ сверки. Резервуары и параметры, требующие ручных замеров:" + {&new-line} .
    for each buf_place-attr no-lock where buf_place-attr.obj-type = v-cntxt-obj-type
                                      and buf_place-attr.obj-code = v-cntxt-obj-code
                                      and buf_place-attr.attr-code = {&place-need-RVD-rvs}
                                      and logical(buf_place-attr.attr-value) = yes,
    first buf_place no-lock where buf_place.obj-type = v-cntxt-obj-type
                              and buf_place.obj-code = v-cntxt-obj-code
                              and buf_place.pl-code = buf_place-attr.pl-code
                              and buf_place.status_ = "",
    first buf_pl-gds no-lock where buf_pl-gds.obj-type = v-cntxt-obj-type
                               and buf_pl-gds.obj-code = v-cntxt-obj-code
                               and buf_pl-gds.pl-code = buf_place.pl-code,
    first buf_goods no-lock where buf_goods.gds-code = buf_pl-gds.gds-code 
    :
      if is-gas(buf_goods.gds-code) then next .
      
      v-ok = yes .
      v-message = v-message + " Резервуар " + buf_place.loc1 + " код " + string(buf_place.pl-code) + " " + buf_place.pl-name + " с " + buf_goods.gds-name + {&new-line} .
      for first buf_place-attr2 no-lock where buf_place-attr2.obj-type = v-cntxt-obj-type
                                          and buf_place-attr2.obj-code = v-cntxt-obj-code
                                          and buf_place-attr2.pl-code  = buf_place.pl-code
                                          and buf_place-attr2.attr-code = {&place-rvd-dnsty}
                                          and logical(buf_place-attr2.attr-value) = yes 
                                          :
        v-message = v-message + "   - Плотность" + {&new-line} .
      end .
      for first buf_place-attr2 no-lock where buf_place-attr2.obj-type = v-cntxt-obj-type
                                          and buf_place-attr2.obj-code = v-cntxt-obj-code
                                          and buf_place-attr2.pl-code  = buf_place.pl-code
                                          and buf_place-attr2.attr-code = {&place-rvd-tmp}
                                          and logical(buf_place-attr2.attr-value) = yes 
                                          :
        v-message = v-message + "   - Температура" + {&new-line} .
      end .
      for first buf_place-attr2 no-lock where buf_place-attr2.obj-type = v-cntxt-obj-type
                                          and buf_place-attr2.obj-code = v-cntxt-obj-code
                                          and buf_place-attr2.pl-code  = buf_place.pl-code
                                          and buf_place-attr2.attr-code = {&place-rvd-lvl}
                                          and logical(buf_place-attr2.attr-value) = yes 
                                          :
        v-message = v-message + "   - Уровень" + {&new-line} .
      end .
    end .
    if v-ok
    then do :
      message v-message view-as alert-box title "Внимание!" . 
    end .                          
  end . 
  
end procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-fi-close-date C-Win
PROCEDURE proc-fi-close-date :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define output  parameter p-date as date      no-undo .
define variable v-value-character  as character no-undo .
define variable v-value-decimal    as decimal   no-undo .
define variable v-value-integer    as integer   no-undo .
define variable v-value-logical    as logical   no-undo .
define variable v-value-type       as character no-undo .

empty temp-table thbjattr_thbj-attr .

case v-cntxt-level :
when {&cntxt-object} then do:
  run adm/shattri.p (
       input "get":U
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input {&attr-nakl_par}
      ,input  "date-close-period"
      ,output v-value-character
      ,output p-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .

end.
when {&cntxt-firm} then do:
  run adm/shattri.p (
       input "get":U
      ,input {&cmp}
      ,input v-cntxt-host-code-obj
      ,input {&attr-nakl_par}
      ,input  "date-close-period"
      ,output v-value-character
      ,output p-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .

end.

when {&cntxt-global} then do:
  run adm/shattri.p (
       input "get":U
      ,input ""
      ,input 0
      ,input {&attr-nakl_par}
      ,input  "date-close-period"
      ,output v-value-character
      ,output p-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
end.

end case.
if error-status :error then message
  error-status :get-message(1) skip
  return-value skip
  "Ошибка"
  view-as alert-box error
.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE run-help C-Win
PROCEDURE run-help :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  APPLY "HELP":U TO FRAME {&FRAME-NAME}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE search-bar-code C-Win
PROCEDURE search-bar-code :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable varresult   as character                no-undo.
  define variable vartype-bc  as character                no-undo.
  define variable varweight   as decimal                  no-undo.

  define buffer buf_bar-code for ub.bar-code .
  define buffer buf_prod-bc  for ub.prod-bc .
  define buffer buf_place    for ub.place .
  do
  on error undo, return error return-value
  :

    { str/sclspref.i }
    do with frame {&frame-name}
    :
      assign
        fi-bar-code
      .
    end.

    if fi-bar-code = '':U
    or fi-bar-code = ?
    then do:
      run bc-brief in this-procedure
        (input ?
        ).
      message
        substitute("Не задан штрих-код для поиска товара") skip
        view-as alert-box information .
    end.
    else do:

      { str/bc-rcnz.i
        this-procedure
        fi-bar-code
        ?
        v-cntxt-obj-type
        v-cntxt-obj-code
        yes
        no
        varscales-pref
        varpgscales-pref
        varresult
        vartype-bc
        varweight
        buf_bar-code
        buf_prod-bc
        buf_place
        no-error
      }
      if available buf_bar-code
      then do:
        run bc-brief in this-procedure
          (input  buf_bar-code.b-code
          ).
      end.
      else do:
        run bc-brief in this-procedure
          (input  ?
          ).
        message
          substitute("Штрих-код &1 не найден"
                    ,fi-bar-code
                    ) skip
          view-as alert-box information .
      end.
    end.
    apply "entry" to fi-bar-code in frame {&frame-name}.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-context C-Win
PROCEDURE select-context :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-cntxt-valid as logical   no-undo .
  define output parameter p-user-select as logical   no-undo .

  define variable v-select-cntxt-menu-code       as integer   no-undo .
  define variable v-select-cntxt-menu-group-code as integer   no-undo .
  define variable v-select-cntxt-level           as character no-undo .
  define variable v-select-cntxt-host-code-obj   as integer   no-undo .
  define variable v-select-cntxt-obj-type        as character no-undo .
  define variable v-select-cntxt-obj-code        as integer   no-undo .
  define variable v-select-cntxt-db-num-obj      as integer   no-undo .
  define variable v-select-cntxt-valid           as logical   no-undo .

  do
  on error undo, return error return-value
  :
    assign
      p-user-select = false
    .

    if p-cntxt-valid = true
    then do:
      assign
        v-select-cntxt-menu-code       = v-cntxt-menu-code
        v-select-cntxt-menu-group-code = v-cntxt-menu-group-code
        v-select-cntxt-level           = v-cntxt-level
        v-select-cntxt-host-code-obj   = v-cntxt-host-code-obj
        v-select-cntxt-obj-type        = v-cntxt-obj-type
        v-select-cntxt-obj-code        = v-cntxt-obj-code
      .
    end.
    else do:
      assign
        v-select-cntxt-menu-code       = {&menu-code-main}
        v-select-cntxt-menu-group-code = 0
        v-select-cntxt-level           = {&cntxt-global}
        v-select-cntxt-host-code-obj   = 0
        v-select-cntxt-obj-type        = '':U
        v-select-cntxt-obj-code        = 0
      .
    end.

    assign
      v-select-cntxt-valid = false
    .

    /* цикл выбора контекста */
    _loop-select:
    do while v-select-cntxt-valid = false
    on error undo, return error return-value
    :
      /* если значения контекста неправильны */
      /* позволяем пользователю выбрать контекст */
      run gbl/cntxtsel.w
        (input  this-procedure :handle         /* parparentproc                  */
        ,input  v-cntxt-db-num                 /* p-cntxt-db-num                 */
        ,input  {&action-head-code-main}       /* p-action-head-code             */
        ,input  v-cntxt-user-id                /* p-cntxt-user-id                */
        ,input  v-select-cntxt-menu-code       /* p-cntxt-menu-code              */
        ,input  v-select-cntxt-menu-group-code /* p-cntxt-menu-group-code        */
        ,input  v-select-cntxt-level           /* p-cntxt-level                  */
        ,input  v-select-cntxt-host-code-obj   /* p-cntxt-host-code-obj          */
        ,input  v-select-cntxt-obj-type        /* p-cntxt-obj-type               */
        ,input  v-select-cntxt-obj-code        /* p-cntxt-obj-code               */
        ,output v-select-cntxt-menu-code       /* p-select-cntxt-menu-code       */
        ,output v-select-cntxt-menu-group-code /* p-select-cntxt-menu-group-code */
        ,output v-select-cntxt-level           /* p-select-cntxt-level           */
        ,output v-select-cntxt-host-code-obj   /* p-select-cntxt-host-code-obj   */
        ,output v-select-cntxt-obj-type        /* p-select-cntxt-obj-type        */
        ,output v-select-cntxt-obj-code        /* p-select-cntxt-obj-code        */
        ,output v-user-select                  /* p-user-select                  */
        ) .
      if v-user-select <> true
      then do:
        /* пользователь не стал выбирать фирму или объект */
        /* отказываемся от входа в систему */
        assign
          p-user-select = false
        .
        return . /* --->>>--- */
      end.

      define variable v-chk-usr-numa as logical   no-undo .
      define variable v-work-usr-num as integer   no-undo .
      define buffer bf_menu-group     for ub.menu-group .
      run chk-usr-numa in this-procedure
         (output v-chk-usr-numa
         ) .

      if v-chk-usr-numa = true
      then do:
         FIND FIRST bf_menu-group
            WHERE bf_menu-group.menu-code        = v-select-cntxt-menu-code
               AND bf_menu-group.menu-group-code  = v-select-cntxt-menu-group-code
            NO-LOCK
            no-error
            .
        if not available bf_menu-group
        then do:
        message
            vss-workfile vss-revision vss-description skip
            "Неизвестный код группы пунктов меню" skip
            "Код меню" v-select-cntxt-menu-code skip
            "Код группы пунктов меню" v-select-cntxt-menu-group-code skip
            view-as alert-box error .
            undo _loop-select, return error return-value .
        end.

         { gbl/conf-rd.i
            "bf_menu-group.menu-group-licence-param"
            0
            "'':U"
            0
            "'':U"
            "'':U"
            "'':U"
            yes
            v-param-value
            v-param-type
            no-error
         }

         if error-status :error
         then do:
         message
            vss-workfile vss-revision vss-description skip
            "Ошибка чтения конфигурационного параметра" bf_menu-group.menu-group-licence-param skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
         undo, return error return-value .
         end.

         run adm/isanybdy.p
               (input  true                         /* p-check-menu-group */
               ,input  bf_menu-group.menu-code     /* p-menu-group-id    */
               ,input  bf_menu-group.menu-group-id /* p-menu-group-id    */
               ,output v-work-usr-num               /* p-total-user-num   */
               ).

         if v-work-usr-num >= integer(v-param-value)
         then do:
               message
                  "Превышено максимальное количество пользователей, работающих в группе меню" bf_menu-group.menu-group-description skip
                  "Количество лицензий" integer(v-param-value) skip
                  "Работает пользователей" v-work-usr-num skip
                  return-value skip
               view-as alert-box error .
               UNDO _loop-select, RETRY _loop-select.
         end.
      END.

      if v-select-cntxt-level = {&cntxt-object}
      then do:
        { gbl/objdbnum.i
          v-select-cntxt-obj-type
          v-select-cntxt-obj-code
          v-select-cntxt-db-num-obj
        }
      end.
      else do:
        assign
          v-select-cntxt-db-num-obj = ?
        .
      end.

      run gbl/cntxtchk.p
        (input  v-cntxt-db-num                 /* p-cntxt-db-num          */
        ,input  v-cntxt-user-id                /* p-cntxt-user-id         */
        ,input  v-select-cntxt-menu-code       /* p-cntxt-menu-code       */
        ,input  v-select-cntxt-menu-group-code /* p-cntxt-menu-group-code */
        ,input  v-select-cntxt-level           /* p-cntxt-level           */
        ,input  v-select-cntxt-host-code-obj   /* p-cntxt-host-code-obj   */
        ,input  v-select-cntxt-obj-type        /* p-cntxt-obj-type        */
        ,input  v-select-cntxt-obj-code        /* p-cntxt-obj-code        */
        ,input  v-select-cntxt-db-num-obj      /* p-cntxt-db-num-obj      */
        ,output v-select-cntxt-valid           /* p-cntxt-valid           */
        ,output v-cntxt-error-message          /* p-cntxt-error-message   */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при проверке контекста" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if v-select-cntxt-valid = false
      then do:
        message
          v-cntxt-error-message skip
          "" skip
          "Необходимо выбрать текущую Группу меню, Фирму, Объект" skip
          view-as alert-box information .
      end.
    end.

    assign
      p-user-select = true
    .

    assign
      v-cntxt-menu-code       = v-select-cntxt-menu-code
      v-cntxt-menu-group-code = v-select-cntxt-menu-group-code
      v-cntxt-level           = v-select-cntxt-level
      v-cntxt-host-code-obj   = v-select-cntxt-host-code-obj
      v-cntxt-obj-type        = v-select-cntxt-obj-type
      v-cntxt-obj-code        = v-select-cntxt-obj-code
      v-cntxt-db-num-obj      = v-select-cntxt-db-num-obj
    .

    /* сохраняем выбранные значения, как значения по умолчанию */
    run gbl/cntxtstr.p
      (input  v-cntxt-db-num          /* p-cntxt-db-num          */
      ,input  v-cntxt-user-id         /* p-cntxt-user-id         */
      ,input  v-cntxt-menu-code       /* p-cntxt-menu-code       */
      ,input  v-cntxt-menu-group-code /* p-cntxt-menu-group-code */
      ,input  v-cntxt-level           /* p-cntxt-level           */
      ,input  v-cntxt-host-code-obj   /* p-cntxt-host-code-obj   */
      ,input  v-cntxt-obj-type        /* p-cntxt-obj-type        */
      ,input  v-cntxt-obj-code        /* p-cntxt-obj-code        */
      ) .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-menu-group C-Win
PROCEDURE select-menu-group :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-menu-group-code as integer   no-undo .

  define buffer buf_menu-group for ub.menu-group .

  define variable v-new-menu-group-id      as character no-undo .
  define variable v-previous-menu-group-id as character no-undo .
  define variable v-cur-date-error-code    as integer      no-undo.

  do
  on error undo, return error return-value
  :
    assign
        v-cur-date-error-code = 1
    .
    choose-item:
    do while v-cur-date-error-code = 1
    on error undo, return error
    :
        find first buf_menu-group no-lock
        where buf_menu-group.menu-code       = v-cntxt-menu-code
            and buf_menu-group.menu-group-code = p-menu-group-code
        no-error .
        if not available buf_menu-group
        then do:
        message
            vss-workfile vss-revision vss-description skip
            "Неизвестный код группы пунктов меню" skip
            "Код меню" v-cntxt-menu-code skip
            "Код группы пунктов меню" p-menu-group-code skip
            view-as alert-box error .
            undo choose-item, return error return-value .
        end.
        assign
        v-new-menu-group-id = buf_menu-group.menu-group-id
        .
        define variable v-chk-usr-numa as logical   no-undo .
        define variable v-work-usr-num as integer   no-undo .
        define buffer bf_menu-group     for ub.menu-group .
        run chk-usr-numa in this-procedure
           (output v-chk-usr-numa
           ) .

        if v-chk-usr-numa = true
        then do:
            { gbl/conf-rd.i
               "buf_menu-group.menu-group-licence-param"
               0
               "'':U"
               0
               "'':U"
               "'':U"
               "'':U"
               yes
               v-param-value
               v-param-type
               no-error
            }

            if error-status :error
            then do:
            message
               vss-workfile vss-revision vss-description skip
               "Ошибка чтения конфигурационного параметра" buf_menu-group.menu-group-licence-param skip
               error-status :get-message(1) skip
               return-value skip
               view-as alert-box error .
            undo, return error return-value .
            end.

            run adm/isanybdy.p
                  (input  true                         /* p-check-menu-group */
                  ,input  buf_menu-group.menu-code     /* p-menu-group-id    */
                  ,input  buf_menu-group.menu-group-id /* p-menu-group-id    */
                  ,output v-work-usr-num               /* p-total-user-num   */
                  ).
            if v-work-usr-num >= integer(v-param-value)
            then do:
                  message
                     "Превышено максимальное количество пользователей, работающих в группе меню" buf_menu-group.menu-group-description skip
                     "Количество лицензий" integer(v-param-value) skip
                     "Работает пользователей" v-work-usr-num skip
                     return-value skip
                  view-as alert-box error .
                  undo choose-item, return .
            end.
        END.

        find first buf_menu-group no-lock
        where buf_menu-group.menu-code       = v-cntxt-menu-code
            and buf_menu-group.menu-group-code = v-cntxt-menu-group-code
        no-error .
        if available buf_menu-group
        then do:
            assign
                v-cntxt-previous-menu-group-id = buf_menu-group.menu-group-id
            .
        end.
        else do:
            assign
                v-cntxt-previous-menu-group-id = '':U
            .
        end.

        /*
        run gbl/actn-upd.p
        (input this-procedure /* parparentproc */
        ) no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при обновлении прав" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo choose-item, return error return-value .
        end.

        run gbl/menu-upd.p
        (input  this-procedure
        ,input  ?
        ,input  {&menu-code-main}
        ,input  v-cntxt-db-num
        ) no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при обновлении меню" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo choose-item, return error return-value .
        end.
        */


        find first buf_menu-group no-lock
        where buf_menu-group.menu-code     = v-cntxt-menu-code
            and buf_menu-group.menu-group-id = v-new-menu-group-id
        no-error .
        if not available buf_menu-group
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Неизвестный код группы пунктов меню" skip
                "Код меню" v-cntxt-menu-code skip
                "Идентификатор группы пунктов меню" v-new-menu-group-id skip
            view-as alert-box error .
            undo choose-item, return error return-value .
        end.

        assign
            v-cntxt-menu-group-code = buf_menu-group.menu-group-code
        .

        run delete-dm-menu in this-procedure
        no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при удалении меню" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo choose-item, return error return-value .
        end.

        run create-dm-menu in this-procedure
        no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при создании меню" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo choose-item, return error return-value .
        end.

        do with frame {&frame-name}
        :
            assign
                fi-menu-group-name = buf_menu-group.menu-group-name
            .
/*            display
                fi-menu-group-name
            with frame {&frame-name} .*/
        end.
        APPLY "value-changed" TO br-menu-item.
        run disp-static in this-procedure
        no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры disp-static" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo choose-item, return error return-value . /* --->>>--- */
        end.

        run mainmenu-disp-mutable in this-procedure (
            output v-cur-date-error-code
        )  no-error.
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры mainmenu-disp-mutable" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo choose-item, return error . /* --->>>--- */
        end.
        /* сохраняем выбранные значения, как значения по умолчанию */
        run gbl/cntxtstr.p
         ( input  v-cntxt-db-num          /* p-cntxt-db-num          */
         , input  v-cntxt-user-id         /* p-cntxt-user-id         */
         , input  v-cntxt-menu-code       /* p-cntxt-menu-code       */
         , input  v-cntxt-menu-group-code /* p-cntxt-menu-group-code */
         , input  v-cntxt-level           /* p-cntxt-level           */
         , input  v-cntxt-host-code-obj   /* p-cntxt-host-code-obj   */
         , input  v-cntxt-obj-type        /* p-cntxt-obj-type        */
         , input  v-cntxt-obj-code        /* p-cntxt-obj-code        */
         ) .
    end.        /* do while v-cur-date-error-code = 1 */
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-previous-menu-group-id C-Win
PROCEDURE select-previous-menu-group-id :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_menu-group for ub.menu-group .

  do
  on error undo, return error return-value
  :
    if v-cntxt-previous-menu-group-id <> ""
    and v-cntxt-previous-menu-group-id <> ?
    THEN DO:
      find first buf_menu-group no-lock
         where buf_menu-group.menu-code = v-cntxt-menu-code
         and buf_menu-group.menu-group-id = v-cntxt-previous-menu-group-id
         no-error .
    END.
    else do:
      find first buf_menu-group no-lock
         where buf_menu-group.menu-code = v-cntxt-menu-code
         and buf_menu-group.menu-group-code = v-cntxt-menu-group-code
         no-error .
    end.
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run select-menu-group in this-procedure
      (input buf_menu-group.menu-group-code
      ) .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-bc-price C-Win
PROCEDURE set-bc-price :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter p-bc-price as logical no-undo .

  do
  on error undo, return error
  :
    assign
      v-cntxt-bc-price = p-bc-price
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-gds-engl C-Win
PROCEDURE set-gds-engl :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter p-gds-engl as logical no-undo .

  do
  on error undo, return error
  :
    assign
      v-cntxt-gds-engl = p-gds-engl
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-inp-jewel C-Win
PROCEDURE set-inp-jewel :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter p-inp-jewel as logical no-undo .

  do
  on error undo, return error
  :
    assign
      v-cntxt-inp-jewel = p-inp-jewel
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-mainmenu-title C-Win
PROCEDURE set-mainmenu-title :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define buffer buf_clients for ub.clients .

  define variable v-version-name     as character no-undo .
  define variable v-version-name-str as character no-undo .
  define variable v-host-str         as character no-undo .
  define variable v-obj-str          as character no-undo .
  define variable v-user-str         as character no-undo .
  define variable v-db-num-str       as character no-undo .
  define variable v-user-id-str      as character no-undo .
  define variable v-process-id-str   as character no-undo .

  do
  on error undo, return error return-value
  :

    assign
      v-host-str = '':U
      v-obj-str  = '':U
    .

    case v-cntxt-level
    :
      when {&cntxt-global}
      then do:
        /* нет фирмы, нет объекта */
      end.
      when {&cntxt-firm}
      then do:
        find first buf_clients no-lock
          where buf_clients.obj-type = {&cmp}
            and buf_clients.obj-code = v-cntxt-host-code-obj
          no-error .
        if available buf_clients
        then do:
          assign
            v-host-str = substitute("Фирма: &1 &2"
                                    ,buf_clients.obj-type
                                    ,buf_clients.obj-code
                                    )
          .
        end.
      end.
      when {&cntxt-object}
      then do:
        /* известны фирма и объект */
        find first buf_clients no-lock
          where buf_clients.obj-type = {&cmp}
            and buf_clients.obj-code = v-cntxt-host-code-obj
          no-error .
        if available buf_clients
        then do:
          assign
            v-host-str = substitute("Фирма: &1 &2"
                                    ,buf_clients.obj-type
                                    ,buf_clients.obj-code
                                    )
          .
        end.

        find first buf_clients no-lock
          where buf_clients.obj-type = v-cntxt-obj-type
            and buf_clients.obj-code = v-cntxt-obj-code
          no-error .
        if available buf_clients
        then do:
          assign
            v-obj-str = substitute("Объект: &1 &2"
                                  ,buf_clients.obj-type
                                  ,buf_clients.obj-code
                                  )
          .
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестное значение переменной уровень контекста" skip
          "Значение" v-cntxt-level skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .

    run gbl/getvers.p
      (output v-version-name
      ) .
    assign
      v-version-name-str = substitute("TH &1", v-version-name)
    .

    assign
      v-db-num-str = substitute("БД: &1", v-cntxt-db-num)
    .

    assign
      v-user-id-str = substitute("Пользователь: &1", fi-user-login)
    .

    assign
      v-process-id-str = substitute("PID: &1", v-cntxt-process-id)
    .
    { gbl/objsrv.i}
    define variable v-title as character no-undo .
    if objSrv:SystemSetting:DeveloperMode then
      v-title = substitute('&1, &2, &3&4&5, &6, PID &7 &8':U
                          ,fi-menu-group-name /* группа меню */
                          ,entry( 2,v-db-num-str,":") /* БД           */
                          ,(if v-host-str <> '':U /* Фирма        */
                              then entry( 2,v-host-str,":") + ', ':U
                              else '':U
                            )
                          , (if v-obj-str <> '':U /* Объект       */
                              then entry( 2,v-obj-str,":") + ', ':U
                              else '':U
                            )
                          ,entry( 2,v-user-id-str,":") /* Пользователь */
                          ,v-version-name-str /* Версия       */
                          ,v-cntxt-process-id
                          ,dbparam("ub")

                          )
    .
    else
    assign
      v-title = substitute('&1, &2, &3&4&5, &6, PID &7 &8':U
                          ,fi-menu-group-name /* группа меню */
                          ,v-db-num-str /* БД           */
                          ,(if v-host-str <> '':U /* Фирма        */
                              then v-host-str + ', ':U
                              else '':U
                            )
                          , (if v-obj-str <> '':U /* Объект       */
                              then v-obj-str + ', ':U
                              else '':U
                            )
                          ,v-user-id-str /* Пользователь */
                          ,v-version-name-str /* Версия       */
                          ,v-cntxt-process-id
                          ,""

                          )
    .
    
    assign
      {&window-name} :title = v-title
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-quest-print C-Win
PROCEDURE set-quest-print :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter p-quest-print as logical no-undo .

  define buffer buf_user-login for ub.user-login .

  do
  on error undo, return error
  :
    assign
      v-cntxt-quest-print = p-quest-print
    .

    find first buf_user-login exclusive-lock
      where buf_user-login.db-num  = v-cntxt-db-num
        and buf_user-login.user-id = v-cntxt-user-id
      no-error .
    if available buf_user-login then do:
      assign
        buf_user-login.quest-print = v-cntxt-quest-print
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE trigger-select-context C-Win
PROCEDURE trigger-select-context :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

    define variable v-cur-date-error-code   as integer      no-undo.
    define variable v-user-select           as logical      no-undo.
do
on error undo, return error return-value
:
    assign
        v-cur-date-error-code = 1
    .
    choose-item:
    do while v-cur-date-error-code = 1
    on error undo, return error
    :
        run select-context in this-procedure
        (input  true
        ,output v-user-select
        ) .
        if v-user-select <> true
        then do:
            /* пользователь не стал выбирать фирму или объект */
            UNDO, return ERROR. /* --->>>--- */
        end.

        run delete-dm-menu in this-procedure
        no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при удалении меню" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo choose-item, return error return-value . /* --->>>--- */
        end.

        run create-dm-menu in this-procedure
        no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при создании меню" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo choose-item, return error return-value . /* --->>>--- */
        end.

        run disp-static in this-procedure
        no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры disp-static" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo choose-item, return error return-value . /* --->>>--- */
        end.

        run mainmenu-disp-mutable in this-procedure (
            output v-cur-date-error-code
        )  no-error.
        if error-status :error
        then do:
            if v-cur-date-error-code <> 1
            then do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Ошибка при вызове процедуры mainmenu-disp-mutable" skip
                    error-status :get-message(1) skip
                    return-value skip
                view-as alert-box error .
                undo choose-item, return error . /* --->>>--- */
            end.
        end.
        run select-menu-group  IN THIS-PROCEDURE ( INPUT v-cntxt-menu-group-code) NO-ERROR.
        if error-status :error
        then do:
            undo, retry.
        END.
    end.        /* do while v-cur-date-error-code = 1 */
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-image C-Win
PROCEDURE update-image :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_temp-image for temp-image .
  define buffer buf_temp-check-image for temp-check-image .
  define buffer buf_menu-group for ub.menu-group .
  define buffer buf_user-menu-group for ub.user-menu-group .

  define variable v-enable-item                    as logical   no-undo .
  define variable v-image-code                     as integer   no-undo .
  define variable v-check-image-index              as integer   no-undo .
  define variable v-check-image-name               as character no-undo .
  define variable v-check-image-context            as character no-undo .
  define variable v-check-image-menu-group-id-list as character no-undo .
  define variable v-check-image-procedure-list     as character no-undo .
  define variable v-check-image-visible-procedure  as character no-undo .
  define variable v-check-image-image-procedure    as character no-undo .
  define variable v-check-image-image-file-name    as character no-undo .
  define variable v-check-image-image-name         as character no-undo .
  define variable v-sel-img-file-name              as character no-undo .

  do
  on error undo, return error return-value
  :
    for each buf_temp-image
    on error undo, return error return-value
    :
      assign
        buf_temp-image.image-visible   = false
        buf_temp-image.image-procedure = '':U
        buf_temp-image.image-file-name = '':U
      .
    end.

    assign
      v-image-code = 0
    .

    for each buf_menu-group no-lock
    on error undo, return error return-value
    :
      { gbl/usmgrava.i
        v-cntxt-db-num
        {&action-head-code-main}
        v-cntxt-user-id
        buf_menu-group.menu-code
        buf_menu-group.menu-group-code
        v-cntxt-level
        v-cntxt-host-code-obj
        v-cntxt-obj-type
        v-cntxt-obj-code
        v-enable-item
      }
      if  v-enable-item = true
      /*AND v-cntxt-menu-group-code <> buf_menu-group.menu-group-code*/
      then do:
        assign
          v-image-code = v-image-code + 1
        .
        /* хитрый хак чтобы всегда в верхнем правом углу были кнопки обновить и prev АРМ */
        if v-image-code = 12 then do:
          assign
            v-image-code = 14
          .
        end.
        find first buf_temp-image
          where buf_temp-image.image-code = v-image-code
          no-error .
        if  available buf_temp-image
        then do:
          assign
            v-sel-img-file-name = substring( buf_menu-group.button-image-name , 1 , index( buf_menu-group.button-image-name , '.') - 1)
                          + 's'
                          + substring( buf_menu-group.button-image-name , index( buf_menu-group.button-image-name , '.') )

            buf_temp-image.image-visible          = true
            buf_temp-image.image-handle :sensitive = true
            buf_temp-image.image-file-name        = buf_menu-group.button-image-name
            buf_temp-image.image-sel-file-name    = v-sel-img-file-name
            buf_temp-image.image-procedure        = buf_menu-group.menu-group-procedure
            buf_temp-image.image-handle :TOOLTIP  = buf_menu-group.menu-group-description
          .
        end.
        if v-cntxt-menu-group-code = buf_menu-group.menu-group-code then do:

            assign
              buf_temp-image.image-handle :sensitive = false
              v-sel-img-file-name                 = buf_temp-image.image-file-name
              buf_temp-image.image-file-name      = buf_temp-image.image-sel-file-name
              buf_temp-image.image-sel-file-name  = v-sel-img-file-name
            .
        end.
        else do :
          assign
            buf_temp-image.image-handle :sensitive = true
          .
         end.
      end.
    end.

    find first buf_temp-image
      where buf_temp-image.image-code = 12
      no-error .
    if available buf_temp-image then do:
      assign
        buf_temp-image.image-visible          = true
        buf_temp-image.image-file-name        = "cmp/btn-rfr.bmp":U
        buf_temp-image.image-procedure        = "int,m__rfr-exe"
        buf_temp-image.image-handle :TOOLTIP  = "Обновить экран"
      .
    end.

    if v-cntxt-previous-menu-group-id <> ""
    and v-cntxt-previous-menu-group-id <> ?
    THEN DO:
      find first buf_menu-group no-lock
         where buf_menu-group.menu-code = v-cntxt-menu-code
         and buf_menu-group.menu-group-id = v-cntxt-previous-menu-group-id
         no-error .
    END.
    else do:
      find first buf_menu-group no-lock
         where buf_menu-group.menu-code = v-cntxt-menu-code
         and buf_menu-group.menu-group-code = v-cntxt-menu-group-code
         no-error .
    end.
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find first buf_temp-image
      where buf_temp-image.image-code = 13
      no-error .
    if  available buf_temp-image
    then do:
      assign
        buf_temp-image.image-visible            = true
        buf_temp-image.image-procedure          = buf_menu-group.menu-group-procedure
        buf_temp-image.image-handle :TOOLTIP    = buf_menu-group.menu-group-description
      .
      if v-cntxt-menu-group-code = buf_menu-group.menu-group-code then do:
        assign
          buf_temp-image.image-handle :sensitive  = false
          buf_temp-image.image-file-name          = "cmp/btn-bck.bmp":U
        .

      end.
      else do:
        assign
          buf_temp-image.image-handle :sensitive  = true
          buf_temp-image.image-file-name          = buf_menu-group.button-image-name
        .
      end.
    end.




    assign
      v-check-image-index = 0
      v-image-code = INTEGER ( TRUNCATE ( ( v-image-code - 0.5  ) / 13 , 0 ) + 1 ) * 13
    .
    for each buf_temp-check-image
    on error undo, return error return-value
    :
      delete buf_temp-check-image .
    end.


    /* todo - хранить информацию об изображениях в базе данных */
    /* сразу осуществить фильтрацию по доступным группам меню и по конфигурационным параметрам */
define variable v-lamp-name as character no-undo .
    v-lamp-name = search("cmp/image.txt").
    input stream sinp from value(v-lamp-name) .

    repeat
    :
      assign
        v-check-image-name               = '':U
        v-check-image-context            = '':U
        v-check-image-menu-group-id-list = '':U
        v-check-image-procedure-list     = '':U
        v-check-image-visible-procedure  = '':U
        v-check-image-image-procedure    = '':U
        v-check-image-image-file-name    = '':U
        v-check-image-image-name         = '':U
      .

      import stream sinp
        v-check-image-name
        v-check-image-context
        v-check-image-menu-group-id-list
        v-check-image-procedure-list
        v-check-image-visible-procedure
        v-check-image-image-procedure
        v-check-image-image-file-name
        v-check-image-image-name
        .

      assign
        v-check-image-index = v-check-image-index + 1
      .
      create buf_temp-check-image .
      assign
        buf_temp-check-image.check-image-index              = v-check-image-index
        buf_temp-check-image.check-image-name               = v-check-image-name
        buf_temp-check-image.check-image-context            = v-check-image-context
        buf_temp-check-image.check-image-menu-group-id-list = v-check-image-menu-group-id-list
        buf_temp-check-image.check-image-procedure-list     = v-check-image-procedure-list
        buf_temp-check-image.check-image-visible-procedure  = v-check-image-visible-procedure
        buf_temp-check-image.check-image-image-procedure    = v-check-image-image-procedure
        buf_temp-check-image.check-image-image-file-name    = v-check-image-image-file-name
        buf_temp-check-image.check-image-image-name         = v-check-image-image-name
      .
    end.

    input stream sinp close .

    find first buf_menu-group no-lock
      where buf_menu-group.menu-code       = v-cntxt-menu-code
        and buf_menu-group.menu-group-code = v-cntxt-menu-group-code
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена текущая группа меню" skip
        "Код меню" v-cntxt-menu-code skip
        "Код группы меню" v-cntxt-menu-group-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    /* удаляем изображения, которые не видны для текущей группы меню */
    /* todo - если изображения будут загружены в базу, то здесь */
    /* будет необходимо только считать их из базы, отфильтровав по текущей группе меню */

    define variable v-need-show-image as logical   no-undo .

    for each buf_temp-check-image
    on error undo, return error return-value
    :
      assign
        v-need-show-image = true
      .
      if lookup(buf_menu-group.menu-group-id, buf_temp-check-image.check-image-menu-group-id-list) = 0
      then do:
        assign
          v-need-show-image = false
        .
      end.

      if v-need-show-image = true
      then do:
        if buf_temp-check-image.check-image-context = {&cntxt-global}
        or (buf_temp-check-image.check-image-context = {&cntxt-firm}
            and
            (v-cntxt-level = {&cntxt-firm}
              or
              v-cntxt-level = {&cntxt-object}
            )
           )
        or (buf_temp-check-image.check-image-context = {&cntxt-object}
            and
            v-cntxt-level = {&cntxt-object}
           )
        then do:
          /**/
        end.
        else do:
          assign
            v-need-show-image = false
          .
        end.
      end.

      if v-need-show-image = true
      then do:
        if buf_temp-check-image.check-image-procedure-list = ''
        then do:
          /* */
        end.
        else do:
          define variable v-check-index as integer   no-undo .
          define variable v-num-entries-procedure-list as integer   no-undo .

          assign
            v-num-entries-procedure-list = num-entries(buf_temp-check-image.check-image-procedure-list)
          .

          check_block :
          do v-check-index = 1 to v-num-entries-procedure-list
          :
            run value(entry(v-check-index, buf_temp-check-image.check-image-procedure-list)) in this-procedure
              (output v-need-show-image
              ) .
            if v-need-show-image <> true
            then do:
              leave check_block .
            end.
          end.
        end.
      end.

      if v-need-show-image <> true
      then do:
        delete buf_temp-check-image .
      end.
    end.

    /* составляем список процедур для проверки видимости кнопок */
    define variable v-check-image-visible-proc-list as character no-undo .

    assign
      v-check-image-visible-proc-list = '':U
    .

    for each buf_temp-check-image
    on error undo, return error return-value
    :
      if lookup(buf_temp-check-image.check-image-visible-procedure, v-check-image-visible-proc-list) = 0
      then do:
        assign
          v-check-image-visible-proc-list = v-check-image-visible-proc-list
                                          + (if v-check-image-visible-proc-list <> '':U then ',':U else '':U )
                                          + buf_temp-check-image.check-image-visible-procedure
        .
      end.
    end.

    /* удаляем невидимые кнопки */
    assign
      v-num-entries-procedure-list = num-entries(v-check-image-visible-proc-list)
    .
    do v-check-index = 1 to v-num-entries-procedure-list
    :
      run value(entry(v-check-index, v-check-image-visible-proc-list)) in this-procedure .
    end.

    /* переносим информацию о лампочках во времнную таблицу лампочек */
    for each buf_temp-check-image
    :
      assign
        v-image-code = v-image-code + 1
      .
      find first buf_temp-image
        where buf_temp-image.image-code = v-image-code
        no-error .
      if available buf_temp-image
      then do:
        assign
          buf_temp-image.image-visible   = true
          buf_temp-image.image-handle :sensitive = true
          buf_temp-image.image-file-name = buf_temp-check-image.check-image-image-file-name
          buf_temp-image.image-procedure = buf_temp-check-image.check-image-image-procedure
          buf_temp-image.image-handle :tooltip = buf_temp-check-image.check-image-image-name
        .
      end.
    end.

    for each buf_temp-image
    on error undo, return error return-value
    :
      if buf_temp-image.image-visible = true
      then do:
        assign
          buf_temp-image.image-handle :visible = true
        .
        if
            buf_temp-image.image-handle:image <> buf_temp-image.image-file-name
        then do:    
            buf_temp-image.image-handle:load-image(buf_temp-image.image-file-name) .
        end.
        if buf_temp-image.image-code > 8 then do:
            buf_temp-image.image-handle :width-chars  =  3 .
            buf_temp-image.image-handle :height-chars =  1 .
        end.

      end.
      else do:
          if buf_temp-image.image-handle:image <> "" then do:         
        buf_temp-image.image-handle :load-image(?) .
        assign
          buf_temp-image.image-handle :visible = false
        .
        end.
      end.
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ver-movepar C-Win
PROCEDURE ver-movepar :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :

  find first ub.config  no-lock where
             ub.config.param-code  = "type-vat"  and
             ub.config.db-num      = v-cntxt-db-num  no-error .
   /* if available ub.config then
       run utl/movegskl.p ( true ) . */


  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-display-name C-Win
FUNCTION get-display-name RETURNS CHARACTER
  ( buffer buf_temp-menu-item for temp-menu-item ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  if available buf_temp-menu-item
  then do:
    return fill(" ", buf_temp-menu-item.num-level * 2)
         + (if buf_temp-menu-item.item-type = 's-m':U
            then (if buf_temp-menu-item.show-child = '+':u
                  then {&open-mark} + ' ':U
                  else {&close-mark} + ' ':U
                 )
            else {&terminal-mark} + ' ':U
           )
         + buf_temp-menu-item.display-name
         .
  end.
  else do:
    return '':U .
  end.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE image-display-ovrorc W-Win
PROCEDURE image-display-ovrorc :
/* -----------------------------------------------------------
  Purpose: Пришла ли переоцека по заказам ОРЦ (по товарно не проверяет )
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    define variable l-exist-ovrorc as log no-undo init false .

    define buffer buf_price-doc for ub.price-doc.
    define buffer buf_trn-doc   for ub.trn-doc.
    define buffer buf_ord-doc   for ub.ord-doc.
    find first buf_ord-doc no-lock
      where buf_ord-doc.cli-type  = v-cntxt-obj-type
        and buf_ord-doc.cli-code  = v-cntxt-obj-code
        and buf_ord-doc.doc-type  = {&O-R}
        and buf_ord-doc.status_   = {&ord-req}
            no-error .
       if not available buf_ord-doc then do:
          assign
            l-exist-ovrorc = false
          .
        end.
    else do:
    find first buf_trn-doc no-lock
      where buf_trn-doc.obj-type  = v-cntxt-obj-type
        and buf_trn-doc.obj-code  = v-cntxt-obj-code
        and buf_trn-doc.ext-doc-type  = {&tdedt_Pri_Perem}
        and buf_trn-doc.status_   = {&inquiry}
        and buf_trn-doc.flag_     = true
        no-error .
    if not available buf_trn-doc then do:
       l-exist-ovrorc = false .
    end.
    else do:
        find first buf_price-doc no-lock
          where buf_price-doc.obj-type    = v-cntxt-obj-type
            and buf_price-doc.obj-code    = v-cntxt-obj-code
            and buf_price-doc.status_     = {&act-overvalue}
            and
            ( buf_price-doc.fact-date  >  buf_trn-doc.real-date-create or
            ( buf_price-doc.fact-date  =  buf_trn-doc.real-date-create and
              buf_price-doc.fact-time  >=  buf_trn-doc.real-time-create ))
            no-error .
        if available buf_price-doc then do:
          assign
            l-exist-ovrorc = yes
          .
        end.
    end.
    end.
    run image-display-update-visible in this-procedure
      (input l-exist-ovrorc
      ,input 'ovrorc':U
      ) .
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE image-display-qntorc W-Win
PROCEDURE image-display-qntorc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    define variable l-exist-qntorc as log no-undo init false .

    define buffer buf_gds-obj   for ub.gds-obj.
    define buffer buf_trn-doc   for ub.trn-doc.
    define buffer buf_doc-line  for ub.doc-line.
    define buffer buf_ord-doc   for ub.ord-doc.

    find first buf_ord-doc no-lock
      where buf_ord-doc.cli-type  = v-cntxt-obj-type
        and buf_ord-doc.cli-code  = v-cntxt-obj-code
        and buf_ord-doc.doc-type  = {&O-R}
        and buf_ord-doc.status_   = {&ord-req}
            no-error .
       if not available buf_ord-doc then do:
          assign
            l-exist-qntorc = false
          .
        end.
    else do:
    find first buf_trn-doc no-lock
      where buf_trn-doc.obj-type  = v-cntxt-obj-type
        and buf_trn-doc.obj-code  = v-cntxt-obj-code
        and buf_trn-doc.ext-doc-type  = {&tdedt_Pri_Perem}
        and buf_trn-doc.status_   = {&inquiry}
        and buf_trn-doc.flag_     = true
        no-error .
    if not available buf_trn-doc then do:
       l-exist-qntorc = false .
    end.
    else do:
       for each buf_doc-line no-lock where
                buf_doc-line.doc-code = buf_trn-doc.doc-code :
        find first buf_gds-obj no-lock
          where buf_gds-obj.obj-type    = v-cntxt-obj-type
            and buf_gds-obj.obj-code    = v-cntxt-obj-code
            and buf_gds-obj.artic       = buf_doc-line.artic
            and buf_gds-obj.prod-type   = buf_doc-line.prod-type
            and buf_gds-obj.prod-code   = buf_doc-line.prod-code no-error .
             if error-status :error then do:
                l-exist-qntorc = false .
                leave.
             end.
                l-exist-qntorc = true .
                if buf_gds-obj.fact-qnty < buf_doc-line.fact-qnty then do:
                    l-exist-qntorc = false .
                    leave.
                end.
        end.
    end.
    end.

    run image-display-update-visible in this-procedure
      (input l-exist-qntorc
      ,input 'qntorc':U
      ) .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE image-display-srgdn W-Win
PROCEDURE image-display-srgdn :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
define variable l-exist as log no-undo init false .
define variable v-srok as integer   no-undo .
define variable v-value-character  as character no-undo .
define variable v-value-decimal    as decimal   no-undo .
define variable v-value-integer    as integer   no-undo .
define variable v-value-logical    as logical   no-undo .
define variable v-value-type       as character no-undo .
define variable v-value-date       as date      no-undo .
define variable v-today as date      no-undo .
define variable v-time as integer   no-undo .
define variable v-godendo as date      no-undo .

  empty temp-table thbjattr_thbj-attr .
  run adm/shattri.p (
       input "get":U
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input {&attr-ass-obj}
      ,input {&attr-Ass-obj_crit-srokgod}
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-srok
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .

    if v-srok = 0 then do:
       l-exist = false  .
        run image-display-update-visible in this-procedure
          (input l-exist
          ,input 'srgdn':U
          ) .
       return . /*-------------------------*/
    end.
    else do:
      l-exist = true .
    end.

    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).

    run godendo-offset-to-date in this-procedure (
          input  v-today
        , input  v-srok
        , output v-godendo
    ).

    define buffer buf_parts for ub.parts  .
    find first buf_parts no-lock where
               buf_parts.obj-type = v-cntxt-obj-type and
               buf_parts.obj-code = v-cntxt-obj-code and
               buf_parts.last-date <= v-godendo and
               buf_parts.out-code = {&free-code} no-error .
    if available buf_parts then do:
       l-exist = true .
    end.
    else do:
      l-exist = false .
    end.

    run image-display-update-visible in this-procedure
      (input l-exist
      ,input 'srgdn':U
      ) .

  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE image-display-defec W-Win
PROCEDURE image-display-defec :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    define variable l-exist as log no-undo init false .

    assign
      l-exist = false
    .

    { gbl/conf-rd.i
      "'is-pharm':U"
      0
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      no
      v-param-value
      v-param-type
      no-error
    }
    if not error-status :error
      and v-param-value = 'yes':U
    then do:
      define buffer buf_parts for ub.parts  .

      find first buf_parts no-lock where
                 buf_parts.obj-type = v-cntxt-obj-type and
                 buf_parts.obj-code = v-cntxt-obj-code and
                 buf_parts.defect = logical({&FiB}) and
                 buf_parts.out-code = {&free-code} no-error .
      if available buf_parts then do:
         l-exist = true .
      end.
    end.

    run image-display-update-visible in this-procedure
      (input l-exist
      ,input 'defec':U
      ) .

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE image-display-pharm W-Win
PROCEDURE image-display-pharm :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable v-pharm      as logical   no-undo .
define variable v-attr-value as character no-undo .
define variable v-attr-type  as character no-undo .

    { gbl/conf-rd.i
      "'is-pharm'"
      "''"
      "''"
      0
      "''"
      "''"
      "''"
      no
      v-attr-value
      v-attr-type
      no-error
    }

    if error-status :error
    then do:
      v-pharm = false .
    end.
    else do:
       if lookup(v-attr-value, "true,yes") > 0 then do:
          { str/opharm.i v-cntxt-obj-type v-cntxt-obj-code v-attr-value no-error }
       end.
      assign
        v-pharm = lookup(v-attr-value, "true,yes") > 0
      .
    end.
    run image-display-update-visible in this-procedure
      (input v-pharm
      ,input 'pharm':U
      ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE image-display-petrol W-Win
PROCEDURE image-display-petrol :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable v-attr-value as character no-undo .
define variable v-attr-type  as character no-undo .
define variable v-shift-on   as logical   no-undo .
define variable l-exist      as logical   no-undo .
define buffer bf_goods   for ub.goods    .
define buffer bf_units   for ub.units    .
define buffer bf_gds-obj for ub.gds-obj  .

    { gbl/conf-rd.i
      "'is-ptrl'"
      "''"
      "''"
      0
      "''"
      "''"
      "''"
      no
      v-attr-value
      v-attr-type
      no-error
    }

    if error-status :error
      or v-attr-value = 'no'
      or v-attr-value = 'false'
    then do:
      l-exist = false .
    end.
    else do:
        { gbl/objat.i
          v-cntxt-obj-type
          v-cntxt-obj-code
          "'shift-on=request'"
          v-shift-on
          no-error
        }
      if v-shift-on = false then do:
          l-exist = false .
       end.
       else do:
        for each bf_units no-lock
          where lookup( {&petrolium}, bf_units.type) > 0
          ,each bf_goods no-lock
          where bf_goods.unit-base = bf_units.unit-name
          ,first bf_gds-obj no-lock
          where bf_gds-obj.obj-type  = v-cntxt-obj-type
            and bf_gds-obj.obj-code  = v-cntxt-obj-code
            and bf_gds-obj.artic     = bf_goods.artic
            and bf_gds-obj.prod-type = bf_goods.prod-type
            and bf_gds-obj.prod-code = bf_goods.prod-code
        :
          l-exist = true .
          leave .
        end.

/*           for each bf_gds-obj  no-lock where*/
/*                    bf_gds-obj.obj-type = v-cntxt-obj-type and*/
/*                    bf_gds-obj.obj-code = v-cntxt-obj-code ,*/
/*              first bf_goods no-lock where*/
/*                    bf_goods.gds-code  = bf_gds-obj.gds-code ,*/
/*              first bf_units no-lock where*/
/*                    bf_units.unit-name = bf_goods.unit-base  and*/
/*                    lookup( {&petrolium}, bf_units.type) > 0*/
/*                    :*/
/*                    l-exist = true .*/
/*                    leave .*/
/*           end.*/
      end.
    end.

    run image-display-update-visible in this-procedure
      (input l-exist
      ,input 'petrol':U
      ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE image-display-pr-fin W-Win
PROCEDURE image-display-pr-fin :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  Пиктограмма наличия просроченных фин.обязательств
  Notes:
-------------------------------------------------------------*/
define variable v-attr-value as character no-undo.
define variable v-attr-type  as character no-undo.
define variable l-is-fin     as logical no-undo.
define buffer   buf_fin-ob   for ub.fin-ob.

    { gbl/conf-rd.i
      "'is-fin':U"
      "''"
      "''"
      0
      "''"
      "''"
      "''"
      no
      v-attr-value
      v-attr-type
      no-error
    }

    if error-status :error 
       or v-attr-value = 'no'
       or v-attr-value = 'false'
    then do:
      l-is-fin = false.
    end.

    else do:
      if can-find(first buf_fin-ob where (buf_fin-ob.host-code = v-cntxt-host-code-obj and buf_fin-ob.sum-rubl > buf_fin-ob.con-sum-rubl) /* Проверка наличия долга */
                             and buf_fin-ob.pay-date < (today - 1)) 
      then l-is-fin = true.
    end.

    run image-display-update-visible in this-procedure
      (input l-is-fin
      ,input 'pr-fin':U
      ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME