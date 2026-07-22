&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
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

Редактирование рецепта.

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc    as handle           no-undo.
define input parameter p-mode               as character        no-undo.
define input parameter p-goods-recid        as recid            no-undo.
define input parameter p-recipe-type        as character        no-undo.
define input parameter p-in-recipe-code     as character        no-undo.
define input parameter p-host-code          as integer          no-undo.
define input parameter p-store-type         as character        no-undo.
define input parameter p-store-code         as integer          no-undo.
define input parameter p-work-in-office     as logical          no-undo.
define input parameter p-can-set-global     as logical          no-undo.
define output parameter p-out-recipe-code   as character        no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование рецепта.".
{ cmp/vssrevis.i   }
{ cmp/trg-def.i    }
{ cmp/r-pril.i new }
define variable lns-cnt    as integer      no-undo.
define variable line-rec   as recid        no-undo.
{ cmp/gds-list.i scn-list def "new shared" }
{ gbl/cur-time.i   }
{ str/fbrcode.i    }
{ trg/partslib.i   }
{ str/fbrlib.i     }
{ cmp/showinf.i    }
{ gbl/getcntxt.i def }
{ ref/gds-attr.i   }
{ ref/gdsoattr.i   }
{ gbl/ggoattr.i  }
{ gbl/nutro.i      }
{ gbl/fbrnutro.i   }
{ str/checkGroupAttr.i }
define stream ListStream.
{ gbl/objsrv.i }
   
define variable v-init-gds-unit-is-pieces   as logical        no-undo.
define variable v-init-gds-code             as integer        no-undo.
define variable v-have-rights-to-global     as logical        no-undo.

define variable v-obj-date as date no-undo.

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
define variable gds-rec         as recid        no-undo.
define variable v-ban-recipes   as logical      no-undo .
define variable v-ban-altr      as logical      no-undo .
define variable v-value as character no-undo .
define variable v-type  as character no-undo .
      
define buffer buf_init_recipe   for recipe.
define buffer buf_init_goods    for goods.
define buffer buf_init_units    for units.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-table

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.recipe-gds

/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table ~
get-browse-field( input 1, input recipe-gds.artic, input recipe-gds.prod-type, input recipe-gds.prod-code ) ~
ub.recipe-gds.is-waste ub.recipe-gds.artic ~
get-browse-field( input 5, input recipe-gds.artic, input recipe-gds.prod-type, input recipe-gds.prod-code ) ~
ub.recipe-gds.qnty ub.recipe-gds.brutto-qnty ub.recipe-gds.coeff-waste ~
get-browse-field( input 3, input recipe-gds.artic, input recipe-gds.prod-type, input recipe-gds.prod-code ) ~
get-browse-field( input 2, input recipe-gds.artic, input recipe-gds.prod-type, input recipe-gds.prod-code ) ~
recipe-gds.prod-type + " ":U + string(recipe-gds.prod-code) ~
get-browse-field( input 4, input recipe-gds.artic, input recipe-gds.prod-type, input recipe-gds.prod-code ) ~
get-season-procent (buffer recipe-gds) ~
get-brutto-qnty-season (buffer recipe-gds) ~
fbrnutro_get-gds-recipe-nutrition-by-code (recipe-gds.recipe-code,recipe-gds.artic, recipe-gds.prod-type, recipe-gds.prod-code, {&attr-calories} ) ~
fbrnutro_get-gds-recipe-nutrition-by-code (recipe-gds.recipe-code,recipe-gds.artic, recipe-gds.prod-type, recipe-gds.prod-code, {&attr-protein} ) ~
fbrnutro_get-gds-recipe-nutrition-by-code (recipe-gds.recipe-code,recipe-gds.artic, recipe-gds.prod-type, recipe-gds.prod-code, {&attr-fat} ) ~
fbrnutro_get-gds-recipe-nutrition-by-code (recipe-gds.recipe-code,recipe-gds.artic, recipe-gds.prod-type, recipe-gds.prod-code, {&attr-carbohydrate} )
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table
&Scoped-define QUERY-STRING-br-table FOR EACH ub.recipe-gds ~
      WHERE recipe-gds.recipe-code = buf_init_recipe.recipe-code NO-LOCK ~
    BY ub.recipe-gds.proc-number
&Scoped-define OPEN-QUERY-br-table OPEN QUERY br-table FOR EACH ub.recipe-gds ~
      WHERE recipe-gds.recipe-code = buf_init_recipe.recipe-code NO-LOCK ~
    BY ub.recipe-gds.proc-number.
&Scoped-define TABLES-IN-QUERY-br-table ub.recipe-gds
&Scoped-define FIRST-TABLE-IN-QUERY-br-table ub.recipe-gds


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-table}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-close b-cancel b-gds b-hst b-rcp ~
b-additional b-recipe-develop b-print b-help fi-recipe-name fi-recipe-qnty ~
fi-recipe-ref-num fi-portion-qnty fi-portion-weight ed-recipe-technique ~
b-change b-up b-down br-table v-fat v-protein v-calories v-carbohydrate
&Scoped-Define DISPLAYED-OBJECTS fi-recipe-name tb-global fi-recipe-qnty ~
fi-init-units fi-recipe-ref-num fi-portion-qnty fi-recipe-technique-label ~
fi-portion-weight ed-recipe-technique br-table-label v-fat v-protein ~
v-calories v-carbohydrate

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-browse-field Dialog-Frame
FUNCTION get-browse-field RETURNS CHARACTER
  ( input p-parameter-number as integer, input p-artic as character, input p-prod-type as character, input p-prod-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-brutto-qnty Dialog-Frame
FUNCTION get-brutto-qnty RETURNS DECIMAL
  ( buffer buf_recipe-gds for ub.recipe-gds )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-brutto-qnty-season Dialog-Frame
FUNCTION get-brutto-qnty-season RETURNS DECIMAL
  ( buffer buf_recipe-gds for ub.recipe-gds )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-season-procent Dialog-Frame
FUNCTION get-season-procent RETURNS DECIMAL
( buffer buf_recipe-gds for ub.recipe-gds )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-b-print
       MENU-ITEM m_m-recipe     LABEL "Рецепт"
       MENU-ITEM m_tk           LABEL "Технологическая карта"
       MENU-ITEM m_tk2          LABEL "Технологическая карта-2"
       MENU-ITEM m_tk3          LABEL "Технологическая карта-3 (HTML)"
       MENU-ITEM m_ap           LABEL "Акт проработки"
       MENU-ITEM m_op1          LABEL "Калькуляция (оценочно)".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-additional
     LABEL "&Доп.инфо"
     SIZE 10 BY 1.

DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.

DEFINE BUTTON b-change
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-close
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-down
     LABEL "Вни&з"
     SIZE 10 BY 1.

DEFINE BUTTON b-gds
     LABEL "&Товары"
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-hst
     LABEL "&История"
     SIZE 10 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 10 BY 1.

DEFINE BUTTON b-rcp
     LABEL "&Рецепт"
     SIZE 10 BY 1.

DEFINE BUTTON b-recipe-develop
     LABEL "АктыПро"
     SIZE 10 BY 1.

DEFINE BUTTON b-up
     LABEL "Ввер&х"
     SIZE 10 BY 1.

DEFINE VARIABLE ed-recipe-technique AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 96.63 BY 2.29 NO-UNDO.

DEFINE VARIABLE br-table-label AS CHARACTER FORMAT "X(256)":U INITIAL "Ингредиенты рецепта"
     VIEW-AS FILL-IN
     SIZE 43 BY 1 NO-UNDO.

DEFINE VARIABLE fi-init-units AS CHARACTER FORMAT "X(3)":U
     LABEL "Ед.изм"
     VIEW-AS FILL-IN
     SIZE 4.13 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-portion-qnty AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
     LABEL "Порций"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE fi-portion-weight AS DECIMAL FORMAT ">>>>9.999":U INITIAL 0
     LABEL "Вес порции (кг)"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE fi-recipe-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Наименование"
     VIEW-AS FILL-IN
     SIZE 67 BY 1 NO-UNDO.

DEFINE VARIABLE fi-recipe-qnty AS DECIMAL FORMAT ">>>>9.<<<":U INITIAL 0
     LABEL "Нетто"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE fi-recipe-ref-num AS CHARACTER FORMAT "X(14)":U
     LABEL "Номер по справ. рецептур"
     VIEW-AS FILL-IN
     SIZE 14.13 BY 1 NO-UNDO.

DEFINE VARIABLE fi-recipe-technique-label AS CHARACTER FORMAT "X(256)":U INITIAL "Описание технологии приготовления"
     VIEW-AS FILL-IN
     SIZE 43 BY 1 NO-UNDO.

DEFINE VARIABLE v-calories AS DECIMAL FORMAT ">>>>9.9":U INITIAL 0
     LABEL "Калории"
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-carbohydrate AS DECIMAL FORMAT ">>9.9":U INITIAL 0
     LABEL "Углеводы"
      VIEW-AS TEXT
     SIZE 6.75 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-fat AS DECIMAL FORMAT ">>9.9":U INITIAL 0
     LABEL "Жиры"
      VIEW-AS TEXT
     SIZE 7.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-protein AS DECIMAL FORMAT ">>9.9":U INITIAL 0
     LABEL "Белки"
      VIEW-AS TEXT
     SIZE 6.75 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE tb-global AS LOGICAL INITIAL no
     LABEL "Глобальный"
     VIEW-AS TOGGLE-BOX
     SIZE 13.88 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-table FOR
      ub.recipe-gds SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table Dialog-Frame _STRUCTURED
  QUERY br-table NO-LOCK DISPLAY
      get-browse-field( input 1, input recipe-gds.artic, input recipe-gds.prod-type, input recipe-gds.prod-code ) COLUMN-LABEL "У" FORMAT "X(1)":U
      ub.recipe-gds.is-waste COLUMN-LABEL "Отх" FORMAT "+/-":U
      ub.recipe-gds.artic FORMAT "X(16)":U
      get-browse-field( input 5, input recipe-gds.artic, input recipe-gds.prod-type, input recipe-gds.prod-code ) COLUMN-LABEL "Р" FORMAT "X(1)":U
      ub.recipe-gds.qnty COLUMN-LABEL "Нетто" FORMAT "->>,>>>,>>9.<<<":U
      ub.recipe-gds.brutto-qnty FORMAT "->>,>>>,>>9.<<<":U
      ub.recipe-gds.coeff-waste COLUMN-LABEL "%Потерь" FORMAT "->,>>9.<<<":U
      get-browse-field( input 3, input recipe-gds.artic, input recipe-gds.prod-type, input recipe-gds.prod-code ) COLUMN-LABEL "ЕИ" FORMAT "X(3)":U
      get-browse-field( input 2, input recipe-gds.artic, input recipe-gds.prod-type, input recipe-gds.prod-code ) COLUMN-LABEL "Название товара" FORMAT "X(40)":U
      recipe-gds.prod-type + " ":U + string(recipe-gds.prod-code) COLUMN-LABEL "Пр-ль" FORMAT "X(10)":U
      get-browse-field( input 4, input recipe-gds.artic, input recipe-gds.prod-type, input recipe-gds.prod-code ) COLUMN-LABEL "Наименование пр-ля" FORMAT "X(40)":U
      get-season-procent (buffer recipe-gds) COLUMN-LABEL "%Сезонн" FORMAT "->,>>9.<<<":U
      get-brutto-qnty-season (buffer recipe-gds) COLUMN-LABEL "Брутто сез" FORMAT "->>,>>>,>>9.<<<":U
            WIDTH 12
      fbrnutro_get-gds-recipe-nutrition-by-code (recipe-gds.recipe-code,recipe-gds.artic, recipe-gds.prod-type, recipe-gds.prod-code, {&attr-calories} ) COLUMN-LABEL "Калории" FORMAT ">>>,>>9.9":U
      fbrnutro_get-gds-recipe-nutrition-by-code (recipe-gds.recipe-code,recipe-gds.artic, recipe-gds.prod-type, recipe-gds.prod-code, {&attr-protein} ) COLUMN-LABEL "Белки" FORMAT ">>>,>>9.9":U
      fbrnutro_get-gds-recipe-nutrition-by-code (recipe-gds.recipe-code,recipe-gds.artic, recipe-gds.prod-type, recipe-gds.prod-code, {&attr-fat} ) COLUMN-LABEL "Жиры" FORMAT ">>>,>>9.9":U
      fbrnutro_get-gds-recipe-nutrition-by-code (recipe-gds.recipe-code,recipe-gds.artic, recipe-gds.prod-type, recipe-gds.prod-code, {&attr-carbohydrate} ) COLUMN-LABEL "Углеводы" FORMAT ">>>,>>9.9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.88 BY 12.5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-close AT ROW 1.21 COL 1.63
     b-cancel AT ROW 1.21 COL 11.63
     b-gds AT ROW 1.21 COL 21.63
     b-hst AT ROW 1.21 COL 31.63
     b-rcp AT ROW 1.21 COL 41.63
     b-additional AT ROW 1.21 COL 51.63
     b-recipe-develop AT ROW 1.21 COL 61.63
     b-print AT ROW 1.21 COL 78.63
     b-help AT ROW 1.21 COL 88.63
     fi-recipe-name AT ROW 2.58 COL 14.63 COLON-ALIGNED
     tb-global AT ROW 2.58 COL 85
     fi-recipe-qnty AT ROW 3.67 COL 14.63 COLON-ALIGNED
     fi-init-units AT ROW 3.67 COL 38 COLON-ALIGNED
     fi-recipe-ref-num AT ROW 3.67 COL 82.5 COLON-ALIGNED
     fi-portion-qnty AT ROW 4.79 COL 14.63 COLON-ALIGNED
     fi-recipe-technique-label AT ROW 6.04 COL 2 NO-LABEL
     fi-portion-weight AT ROW 6.08 COL 61.5 COLON-ALIGNED
     ed-recipe-technique AT ROW 7.21 COL 2 NO-LABEL
     br-table-label AT ROW 9.67 COL 2 NO-LABEL
     b-change AT ROW 9.71 COL 46.63
     b-up AT ROW 9.71 COL 77.88
     b-down AT ROW 9.71 COL 88.63
     br-table AT ROW 10.88 COL 1.75
     v-fat AT ROW 5.04 COL 40.75 COLON-ALIGNED WIDGET-ID 4
     v-protein AT ROW 5.04 COL 55.25 COLON-ALIGNED WIDGET-ID 6
     v-calories AT ROW 5.04 COL 88.5 COLON-ALIGNED WIDGET-ID 2
     v-carbohydrate AT ROW 5.08 COL 72.75 COLON-ALIGNED WIDGET-ID 8
     SPACE(17.47) SKIP(17.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Рецепт"
         CANCEL-BUTTON b-cancel.


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
/* BROWSE-TAB br-table b-down Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-b-print:HANDLE.

/* SETTINGS FOR FILL-IN br-table-label IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-init-units IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-recipe-technique-label IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR TOGGLE-BOX tb-global IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       v-calories:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       v-carbohydrate:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       v-fat:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       v-protein:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table
/* Query rebuild information for BROWSE br-table
     _TblList          = "ub.recipe-gds"
     _Options          = "NO-LOCK"
     _OrdList          = "ub.recipe-gds.proc-number|yes"
     _Where[1]         = "recipe-gds.recipe-code = buf_init_recipe.recipe-code"
     _FldNameList[1]   > "_<CALC>"
"get-browse-field( input 1, input recipe-gds.artic, input recipe-gds.prod-type, input recipe-gds.prod-code )" "У" "X(1)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > ub.recipe-gds.is-waste
"is-waste" "Отх" "+/-" "logical" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   = ub.recipe-gds.artic
     _FldNameList[4]   > "_<CALC>"
"get-browse-field( input 5, input recipe-gds.artic, input recipe-gds.prod-type, input recipe-gds.prod-code )" "Р" "X(1)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > ub.recipe-gds.qnty
"qnty" "Нетто" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   = ub.recipe-gds.brutto-qnty
     _FldNameList[7]   > ub.recipe-gds.coeff-waste
"coeff-waste" "%Потерь" "->,>>9.<<<" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > "_<CALC>"
"get-browse-field( input 3, input recipe-gds.artic, input recipe-gds.prod-type, input recipe-gds.prod-code )" "ЕИ" "X(3)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[9]   > "_<CALC>"
"get-browse-field( input 2, input recipe-gds.artic, input recipe-gds.prod-type, input recipe-gds.prod-code )" "Название товара" "X(40)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[10]   > "_<CALC>"
"recipe-gds.prod-type + "" "":U + string(recipe-gds.prod-code)" "Пр-ль" "X(10)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[11]   > "_<CALC>"
"get-browse-field( input 4, input recipe-gds.artic, input recipe-gds.prod-type, input recipe-gds.prod-code )" "Наименование пр-ля" "X(40)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[12]   > "_<CALC>"
"get-season-procent (buffer recipe-gds)" "%Сезонн" "->,>>9.<<<" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[13]   > "_<CALC>"
"get-brutto-qnty-season (buffer recipe-gds)" "Брутто сез" "->>,>>>,>>9.<<<" ? ? ? ? ? ? ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[14]   > "_<CALC>"
"fbrnutro_get-gds-recipe-nutrition-by-code (recipe-gds.recipe-code,recipe-gds.artic, recipe-gds.prod-type, recipe-gds.prod-code, {&attr-calories} )" "Калории" ">>>,>>9.9" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[15]   > "_<CALC>"
"fbrnutro_get-gds-recipe-nutrition-by-code (recipe-gds.recipe-code,recipe-gds.artic, recipe-gds.prod-type, recipe-gds.prod-code, {&attr-protein} )" "Белки" ">>>,>>9.9" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[16]   > "_<CALC>"
"fbrnutro_get-gds-recipe-nutrition-by-code (recipe-gds.recipe-code,recipe-gds.artic, recipe-gds.prod-type, recipe-gds.prod-code, {&attr-fat} )" "Жиры" ">>>,>>9.9" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[17]   > "_<CALC>"
"fbrnutro_get-gds-recipe-nutrition-by-code (recipe-gds.recipe-code,recipe-gds.artic, recipe-gds.prod-type, recipe-gds.prod-code, {&attr-carbohydrate} )" "Углеводы" ">>>,>>9.9" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-table */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Рецепт */
DO:
    APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-additional
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-additional Dialog-Frame
ON CHOOSE OF b-additional IN FRAME Dialog-Frame /* Доп.инфо */
DO:
{ gbl/stdbtn.i }

    define variable v-cancel    as logical        no-undo.
    define variable v-quality   as character      no-undo.
    define variable v-design    as character      no-undo.
    define variable v-mode      as character      no-undo.

    if p-mode = {&add-def}
    or p-mode = {&update}
    then do:
        assign
            v-mode = {&update}
        .
    end.
    else do:
        assign
            v-mode = p-mode
        .
    end.
    run ref/recipd.w (
          input v-mode
        , input buf_init_recipe.recipe-code
        , input p-store-type
        , input p-store-code
        , input buf_init_recipe.recipe-quality
        , input buf_init_recipe.recipe-design
        , output v-quality
        , output v-design
    ) no-error.
    if error-status :error
    then do:
        message
            "Не удалось присвоить значения дополнительным параметрам рецепта."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply.
    end.
    if buf_init_recipe.recipe-quality <> v-quality
    then do:
        assign
            buf_init_recipe.recipe-quality = v-quality
        .
    end.
    if buf_init_recipe.recipe-design  <> v-design
    then do:
        assign
            buf_init_recipe.recipe-design  = v-design
        .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* Отмена */
DO:
{ gbl/stdbtn.i }
    if p-mode = {&add-def}
    then do:
        assign
            p-out-recipe-code = ""
        .
        if available buf_init_recipe
        then do:
            do transaction
            :
                delete buf_init_recipe.
            end.        /* do transaction */
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-change
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-change Dialog-Frame
ON CHOOSE OF b-change IN FRAME Dialog-Frame /* Изменить */
DO:
    define variable v-new-qnty          as decimal        no-undo.
    define variable v-new-coeff-waste   as decimal        no-undo.
    define variable v-new-brutto-qnty   as decimal        no-undo.
    define variable v-new-calc-method   as integer      no-undo.
    define variable v-is-waste          as logical        no-undo.
    define variable v-success           as logical        no-undo.
    define variable v-goods-name        as character      no-undo.
    define variable v-units             as character      no-undo.
    define variable v-gds-code          as integer        no-undo.
    define variable v-comp-gds-code     as integer        no-undo.
    define variable v-date-on-object    as date           no-undo.


    define buffer buf_units         for units.
    define buffer buf_goods         for goods.
    define buffer buf_comp_goods    for goods.

    if available recipe-gds
    then do:
/*        { gbl/gds-code.i*/
/*            recipe.artic*/
/*            recipe.prod-type*/
/*            recipe.prod-code*/
/*            v-comp-gds-code*/
/*        }*/
/*        { gbl/objdtget.i*/
/*            p-store-type*/
/*            p-store-code*/
/*            v-date-on-object*/
/*        }*/
        { gbl/gds-arnm.i
            recipe-gds.artic
            recipe-gds.prod-type
            recipe-gds.prod-code
            v-goods-name
        }
        { gbl/gds-code.i
            recipe-gds.artic
            recipe-gds.prod-type
            recipe-gds.prod-code
            v-gds-code
        }
        { gbl/unitbase.i
            v-gds-code
            v-units
        }
        find first buf_units no-lock
             where buf_units.unit-name = v-units
        .
/*        run fbrlib-s-coeff-value in this-procedure (*/
/*              input v-comp-gds-code*/
/*            , input v-date-on-object*/
/*            , input p-store-type*/
/*            , input p-store-code*/
/*            , output v-coeff-value*/
/*        ).*/
        run ref/recipln.w (
              input {&recipe-reference}
            , input p-recipe-type
            , input recipe-gds.recipe-code + " " + fi-recipe-name
            , input recipe-gds.artic + " " + v-goods-name
            , input lookup( {&pieces}, buf_units.type ) > 0
            , input recipe-gds.is-waste
            , input recipe-gds.qnty
            , input get-season-procent ( buffer recipe-gds )
            , input recipe-gds.coeff-waste
            , input recipe-gds.brutto-qnty
            , input recipe-gds.calc-method
            , output v-is-waste
            , output v-new-qnty
            , output v-new-coeff-waste
            , output v-new-brutto-qnty
            , output v-new-calc-method
            , output v-success
        ).
        if v-success = yes
        then do:
            do transaction
            on error undo, return no-apply
            :
                find current recipe-gds exclusive-lock .
                assign
                    recipe-gds.qnty         = v-new-qnty
                    recipe-gds.is-waste     = v-is-waste
                    recipe-gds.coeff-waste  = v-new-coeff-waste
                    recipe-gds.brutto-qnty  = v-new-brutto-qnty
                    recipe-gds.calc-method  = v-new-calc-method
                    recipe-gds.nws-self     = yes
                .
            end.        /* do transaction */
            br-table :refresh().
            run calc-and-display-nutrition-info in this-procedure .
        end.
    end.        /* if available recipe-gds */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-close
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-close Dialog-Frame
ON CHOOSE OF b-close IN FRAME Dialog-Frame /* Выход */
DO:
{ gbl/stdbtn.i }

    define variable v-bad-data      as logical        no-undo.
    define variable v-error-text    as character      no-undo.
    define variable v-allow-global  as logical        no-undo.

    if p-mode <> {&update}
    and p-mode <> {&add-def}
    then do:
        apply "go" to frame {&frame-name} .
        return.
    end.
    if input frame {&frame-name} tb-global = yes
    and not( buf_init_recipe.host-code = 0
            and buf_init_recipe.obj-type  = ""
            and buf_init_recipe.obj-code  = 0 )
    then do:
        message
            "После изменений рецепт станет глобальным."
            skip "Сделать рецепт локальным будет невозможно."
            skip "Редактировать или удалить его можно будет"
            skip "только в главной базе данных."
            skip(1)
            skip "Внести изменения в рецепт?"
        view-as alert-box question
        buttons yes-no
        title "Изменение рецепта"
        update v-allow-global.
        if v-allow-global = yes
        then do:
            assign
                buf_init_recipe.host-code = 0
                buf_init_recipe.obj-type  = ""
                buf_init_recipe.obj-code  = 0
            .
        end.
        else do:
            undo, return no-apply.
        end.
    end.        /* if input frame {&frame-name} tb-global = yes */
    assign
        tb-global
        fi-recipe-name
        fi-recipe-qnty
        fi-portion-qnty
        fi-portion-weight
        fi-recipe-ref-num
        ed-recipe-technique
        v-fat
        v-carbohydrate
        v-calories
        v-protein
    .
    RUN attr-save IN THIS-PROCEDURE.

    run check-recipe in this-procedure (
            input buf_init_recipe.recipe-code
          , input fi-recipe-name
          , input fi-recipe-qnty
          , input fi-portion-qnty
          , input fi-portion-weight
          , input fi-recipe-ref-num
          , input ed-recipe-technique
          , output v-bad-data
          , output v-error-text
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка при проверке рецепта."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-bad-data = yes
    then do:
        message
            "Ошибка введенных данных рецепта."
            skip v-error-text
            skip(1)
            "Исправьте данные или отмените ввод рецепта."
        view-as alert-box error.
        undo, return no-apply .
    end.
    assign
        p-out-recipe-code                   = buf_init_recipe.recipe-code
        buf_init_recipe.recipe-name         = fi-recipe-name
        buf_init_recipe.qnty                = fi-recipe-qnty
        buf_init_recipe.portion-qnty        = fi-portion-qnty
        buf_init_recipe.portion-weight      = fi-portion-weight
        buf_init_recipe.recipe-ref-num      = fi-recipe-ref-num
        buf_init_recipe.recipe-technique    = ed-recipe-technique
    .
    apply "GO" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-down
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-down Dialog-Frame
ON CHOOSE OF b-down IN FRAME Dialog-Frame /* Вниз */
DO:     /* перемещение текущей строки рецепта вниз */
{ gbl/stdbtn.i }
    define variable v-cur-line          as recid          no-undo.
    define variable v-proc-number       as integer        no-undo.
    define variable v-old-proc-number   as integer        no-undo.
    define variable v-focused-row       as integer        no-undo.

    if not available recipe-gds
    then do:
        return no-apply.
    end.
    apply "entry" to br-table .
    assign
        v-focused-row   = br-table :focused-row in frame {&FRAME-NAME}
        v-cur-line      = recid( recipe-gds )
        v-proc-number   = recipe-gds.proc-number
    .
    get next br-table.
    if not available recipe-gds
    then do:
        apply "entry" to br-table.
        return no-apply.
    end.
    { gbl/working.i }
    swap-down:
    do transaction
    on error undo swap-down, return no-apply
    :
        find current recipe-gds exclusive-lock .
        assign
            v-old-proc-number       = recipe-gds.proc-number
            recipe-gds.proc-number  = v-proc-number
            recipe-gds.nws-self     = yes
        .
        find first recipe-gds exclusive-lock
             where recid( recipe-gds ) = v-cur-line
        .
        assign
            v-focused-row           = v-focused-row + 1
            recipe-gds.proc-number  = v-old-proc-number
            recipe-gds.nws-self     = yes
        .
    end.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
    br-table :set-repositioned-row( v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
    reposition br-table to recid v-cur-line .
    apply "entry" to browse br-table.
    { gbl/stopwork.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-gds Dialog-Frame
ON CHOOSE OF b-gds IN FRAME Dialog-Frame /* Товары */
DO:
{ gbl/stdbtn.i }
    define variable v-recipe-name    as character    no-undo.
    define variable v-recipe-qnty    as decimal      no-undo.

    assign
        v-recipe-name  = input frame {&frame-name} fi-recipe-name
        v-recipe-qnty  = input frame {&frame-name} fi-recipe-qnty
        tb-global = input frame {&frame-name}  tb-global
    .
    run change-goods-list in this-procedure (
          input buf_init_recipe.recipe-code
        , input buf_init_recipe.recipe-type
    ) no-error.
    if error-status :error
    then do:
        message
                vss-workfile vss-revision vss-description
            skip "Ошибка изменения списка товаров рецепта."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    assign
        fi-portion-weight
        fi-portion-qnty
    .
    RUN enable_UI.
    run ui-on in this-procedure.
    assign
        fi-recipe-name = v-recipe-name
        fi-recipe-qnty = v-recipe-qnty
    .
    display
        fi-recipe-name
        fi-recipe-qnty
    with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hst
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hst Dialog-Frame
ON CHOOSE OF b-hst IN FRAME Dialog-Frame /* История */
DO:
{ gbl/stdbtn.i }
    if available buf_init_recipe
    then do:
        run str/crecip.w (
              input 1
            , input buf_init_recipe.recipe-code
            , input "":U
            , input ?
            , input ?
            , input 0
        ).
    end.
    apply "entry" to br-table.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
  { gbl/stdbtn.i }
  RUN attr-save IN THIS-PROCEDURE.
  run gbl/pop-up.p (self:handle, no) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-rcp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-rcp Dialog-Frame
ON CHOOSE OF b-rcp IN FRAME Dialog-Frame /* Рецепт */
DO:
{ gbl/stdbtn.i }
    if not available recipe-gds
    then do:
        message "Неправильно выбрана строка рецепта.".
        return no-apply.
    end.
    else do:
        run add-recipe in this-procedure (
              input recipe-gds.artic
            , input recipe-gds.prod-type
            , input recipe-gds.prod-code
        ).
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-recipe-develop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-recipe-develop Dialog-Frame
ON CHOOSE OF b-recipe-develop IN FRAME Dialog-Frame /* АктыПро */
DO:
    run ref/rcpakt.w (
         input parparentproc
        ,input p-in-recipe-code
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-up
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-up Dialog-Frame
ON CHOOSE OF b-up IN FRAME Dialog-Frame /* Вверх */
DO:     /* перемещение текущей строки рецепта вверх */
{ gbl/stdbtn.i }
    define variable v-cur-line          as recid                    no-undo.
    define variable v-proc-number       as integer                  no-undo.
    define variable v-old-proc-number   as integer        no-undo.
    define variable v-focused-row       as integer        no-undo.

    if not available recipe-gds
    then do:
        return no-apply.
    end.
    apply "entry" to br-table .
    assign
        v-focused-row   = br-table :focused-row in frame {&FRAME-NAME}
        v-cur-line      = recid( recipe-gds )
        v-proc-number   = recipe-gds.proc-number
    .
    get prev br-table.
    if not available recipe-gds
    then do:
        apply "entry" to br-table.
        return no-apply.
    end.
    { gbl/working.i }
    swap-up:
    do transaction
    on error undo swap-up, return no-apply
    :
        find current recipe-gds exclusive-lock .
        assign
            v-old-proc-number       = recipe-gds.proc-number
            recipe-gds.proc-number  = v-proc-number
            recipe-gds.nws-self     = yes
        .
        find first recipe-gds exclusive-lock
             where recid( recipe-gds ) = v-cur-line
        .
        assign
            recipe-gds.proc-number  = v-old-proc-number
            v-focused-row           = v-focused-row - 1
            recipe-gds.nws-self     = yes
        .
    end.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
    br-table :set-repositioned-row( v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
    reposition br-table to recid v-cur-line .
    apply "entry" to browse br-table.
    { gbl/stopwork.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed-recipe-technique
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed-recipe-technique Dialog-Frame
ON LEAVE OF ed-recipe-technique IN FRAME Dialog-Frame
DO:
  run proc-leave-ed-recipe-technique in this-procedure no-error .
  if error-status :error = yes
  then do:
    return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-portion-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-portion-qnty Dialog-Frame
ON LEAVE OF fi-portion-qnty IN FRAME Dialog-Frame /* Порций */
DO:
    if buf_init_recipe.recipe-type = {&manufacturing}
    and lookup( {&pieces}, buf_init_units.type ) = 0
    then do:
        assign
          fi-recipe-qnty
          fi-portion-qnty
        .
        assign
            fi-portion-weight = fi-recipe-qnty / fi-portion-qnty
        .
        display
            fi-portion-weight
        with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-recipe-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-recipe-qnty Dialog-Frame
ON LEAVE OF fi-recipe-qnty IN FRAME Dialog-Frame /* Нетто */
DO:
    define variable v-yesno    as logical        no-undo.

    if lookup( {&pieces}, buf_init_units.type ) > 0
    then do:
        assign
            fi-portion-qnty :screen-value = fi-recipe-qnty :screen-value
        .
        assign
            fi-recipe-qnty
            fi-portion-qnty
        .
    end.
    else do:
        assign
            fi-recipe-qnty
            fi-portion-qnty
        .
        assign
            fi-portion-weight = fi-recipe-qnty / fi-portion-qnty
        .
        if buf_init_recipe.recipe-type = {&manufacturing}
        then do:
            display
                fi-portion-weight
            with frame {&frame-name}.
        end.
    end.
    run calc-and-display-nutrition-info in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_ap
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_ap Dialog-Frame
ON CHOOSE OF MENU-ITEM m_ap /* Акт проработки */
DO:
  run attr-save in this-procedure .
  run rep/r-ap.p (
         input parparentproc
       , input recid(buf_init_recipe)
  ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_m-recipe
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_m-recipe Dialog-Frame
ON CHOOSE OF MENU-ITEM m_m-recipe /* Рецепт */
DO:
  run attr-save in this-procedure .
  run print-recipe.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_op1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_op1 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_op1 /* Калькуляция (оценочно) */
DO:
  run attr-save in this-procedure .
  run ref/op-1s.p ( input parparentproc
                  , input buf_init_recipe.recipe-code
                  , input p-store-type
                  , input p-store-code
                  ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_tk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_tk Dialog-Frame
ON CHOOSE OF MENU-ITEM m_tk /* Технологическая карта */
DO:
  run attr-save in this-procedure .
  run rep/r-tk.p ( input parparentproc, input recid( buf_init_recipe ), input "recipe":U ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_tk2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_tk2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_tk2 /* Технологическая карта-2 */
DO:
  run attr-save in this-procedure .
  run rep/r-tk1.p ( input parparentproc, input recid( buf_init_recipe ), input "recipe":U ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_tk3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_tk3 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_tk3 /* Технологическая карта-3 (HTML) */
DO:
  run attr-save in this-procedure .
  run rep/r-tk3.p ( input parparentproc, input recid( buf_init_recipe ), input "recipe":U ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-table
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


{ gbl/app_help.i }

{ gbl/hot-key.i b-close }
{ gbl/hot-key.i b-print }
  b-print:menu-mouse = 1.
/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/f2.i br-table goods-recid get-goods-recid parparentproc }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    { gbl/getcntxt.i get }
    run get-report-num in parparentproc (
        output g#report-num
    ).
    run get-quest-print in parparentproc (
        output g#quest-print
    ).
    
   if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsBanRecipes then v-ban-recipes = true . 
   if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsBanAltr then v-ban-altr = true .
    find first buf_init_goods no-lock
         where recid( buf_init_goods ) = p-goods-recid
    no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Неверно выбран товар."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    { gbl/gds-code.i
        buf_init_goods.artic
        buf_init_goods.prod-type
        buf_init_goods.prod-code
        v-init-gds-code
    }
    { gbl/unitbase.i
        v-init-gds-code
        fi-init-units
    }
    find first buf_init_units no-lock
         where buf_init_units.unit-name = fi-init-units
    .
    case p-mode:
        when {&add-def}
        then do:
            run fbrlib-create-or-update-recipe in this-procedure (
                  input {&add-def}
                , input p-store-type
                , input p-store-code
                , input ""
                , input p-recipe-type
                , input buf_init_goods.gds-code
                , input ""
                , input ""
                , input 0
                , input ""
                , input ""
                , input ""
                , input ""
                , input 1.0
                , input 0
                , input 0.0
                , output p-in-recipe-code
            ).
            assign
                p-out-recipe-code  = p-in-recipe-code
            .
            find first buf_init_recipe exclusive-lock
                 where buf_init_recipe.recipe-code = p-in-recipe-code
            .
        end.
        when {&update}
        then do:
            find first buf_init_recipe exclusive-lock
                 where buf_init_recipe.recipe-code = p-in-recipe-code
            no-error.
            if not available buf_init_recipe
            then do:
                message
                        vss-workfile vss-revision vss-description
                    skip "Неверно выбран рецепт."
                    skip return-value
                    skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
        end.
        when {&lookup}
        then do:
            find first buf_init_recipe no-lock
                 where buf_init_recipe.recipe-code = p-in-recipe-code
            no-error.
            if not available buf_init_recipe
            then do:
                message
                        vss-workfile vss-revision vss-description
                    skip "Неверно выбран рецепт."
                    skip return-value
                    skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
        end.
    end case.
    FRAME {&FRAME-NAME} :title = (                        buf_init_recipe.recipe-type
                                    + " № "             + buf_init_recipe.recipe-code
                                    + "    артикул : "  + buf_init_recipe.artic
                                    + "     "           + buf_init_goods.gds-name
                                    + "        "        + p-mode )
    .
    run init-fields in this-procedure .
    RUN enable_UI.
    run ui-on in this-procedure.
    apply "entry" to br-table.

    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-recipe Dialog-Frame
PROCEDURE add-recipe :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-artic      as character    no-undo.
define input parameter p-prod-type  as character    no-undo.
define input parameter p-prod-code  as integer      no-undo.

    define variable v-ref-list as character no-undo.

    define buffer buf_goods     for goods.
    define buffer buf_recipe    for ub.recipe .

    find first buf_goods no-lock
         where buf_goods.artic     = p-artic
           AND buf_goods.prod-type = p-prod-type
           AND buf_goods.prod-code = p-prod-code
    .
    run ref/rcp-all.w (
          input parparentproc
        , input ( if p-mode = {&lookup} then "" else "b-add" )
        , input {&all}
        , input recid( buf_goods )
        , input p-store-type
        , input p-store-code
        , output v-ref-list
    ).
end.
END PROCEDURE. /* add-recipe */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE attr-save Dialog-Frame 
PROCEDURE attr-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define buffer buf_goods    for ub.goods .

  define variable v-attr-value   as character    no-undo.
  define variable v-attr-type    as character    no-undo.

  if p-mode = {&lookup}
  then do:
    return . /* --->>>--- */
  end.

  find first buf_goods no-lock
    where buf_goods.artic     = buf_init_recipe.artic
      and buf_goods.prod-type = buf_init_recipe.prod-type
      and buf_goods.prod-code = buf_init_recipe.prod-code
  no-error .
  if not available buf_goods
  then do:
    message
      substitute( "Не найден товар с артикулом &1 производитель &2 &3"
                , buf_init_recipe.artic
                , buf_init_recipe.prod-type
                , buf_init_recipe.prod-code
                )
    view-as alert-box error.
    return . /* --->>>--- */
  end.
  run gds-attr-value in this-procedure  ( input  buf_goods.gds-code
                                        , input  {&attr-calc-cal-rec}
                                        , output v-attr-value
                                        , output v-attr-type
                                        ) no-error .
  if error-status :error
  then do:
    message
      "Не определен атрибут расчета калорийности"
      skip
    view-as alert-box information.
    return.
  END.
  if logical(v-attr-value) = false
  then do:
    return. /* --->>>--- */
  end.

  if v-calories     = ?
  or v-protein      = ?
  or v-fat          = ?
  or v-carbohydrate = ?
  then do:
    message
      "Не рассчитана пищевая и энергетическая ценность!"
      skip
    view-as alert-box information.

    run str/diallog.w ( input parparentproc
                      , input this-procedure
                      , input ( 'get-incorrect-nutrition-goods':U + {&delim-par} +
                                "1" + {&delim-par} +
                                "0" + {&delim-par} +
                                "1" + {&delim-par} +
                                "1" + {&delim-par} +
                                "yes"
                              )
                      , input ''
                      , input no /*p-auto-go*/
                      , input 'Закрыть'
                      , input 'Список товаров с неполностью определенными атрибутами пищевой и энергетической ценности'
                      ) no-error .
    if error-status :error = yes
    then do:
      message
        'Ошибка постороения списка товаров с неполностью определенными атрибутами пищевой и энергетической ценности' skip
        error-status :get-message(1) skip
        error-status :get-message(2)
      view-as alert-box information.
    end.
    run fbrnutro_proc-save-nutrition in this-procedure ( input buf_init_recipe.recipe-code
                                                       , input buf_init_recipe.artic
                                                       , input buf_init_recipe.prod-type
                                                       , input buf_init_recipe.prod-code
                                                       , input ?
                                                       , input ?
                                                       , input ?
                                                       , input ?
                                                       ) no-error .
    if error-status :error = yes
    then do:
      message
        "Ошибка при сохранении атрибутов пищевой и энергетической ценности":U skip
        return-value skip
        error-status :get-message(1) skip
        error-status :get-message(2)
      view-as alert-box error.
      return . /* --->>>--- */
    end.
    return. /* --->>>--- */
  end.

  run fbrnutro_proc-save-nutrition in this-procedure ( input buf_init_recipe.recipe-code
                                                     , input buf_init_recipe.artic
                                                     , input buf_init_recipe.prod-type
                                                     , input buf_init_recipe.prod-code
                                                     , input v-calories
                                                     , input v-protein
                                                     , input v-carbohydrate
                                                     , input v-fat
                                                     ) no-error .
  if error-status :error = yes
  then do:
    message
      "Ошибка при сохранении атрибутов пищевой и энергетической ценности":U skip
      return-value skip
      error-status :get-message(1) skip
      error-status :get-message(2)
    view-as alert-box error.
    return . /* --->>>--- */
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-and-display-nutrition-info Dialog-Frame
PROCEDURE calc-and-display-nutrition-info :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error return-value
:
  assign
    v-calories      = fbrnutro_get-recipe-nutrition-by-code ( buf_init_recipe.recipe-code, buf_init_recipe.artic, buf_init_recipe.prod-type, buf_init_recipe.prod-code, {&attr-calories}    ,fi-recipe-qnty)
    v-protein       = fbrnutro_get-recipe-nutrition-by-code ( buf_init_recipe.recipe-code, buf_init_recipe.artic, buf_init_recipe.prod-type, buf_init_recipe.prod-code, {&attr-protein}     ,fi-recipe-qnty)
    v-fat           = fbrnutro_get-recipe-nutrition-by-code ( buf_init_recipe.recipe-code, buf_init_recipe.artic, buf_init_recipe.prod-type, buf_init_recipe.prod-code, {&attr-fat}         ,fi-recipe-qnty)
    v-carbohydrate  = fbrnutro_get-recipe-nutrition-by-code ( buf_init_recipe.recipe-code, buf_init_recipe.artic, buf_init_recipe.prod-type, buf_init_recipe.prod-code, {&attr-carbohydrate},fi-recipe-qnty)
  .
  display
    v-calories
    v-protein
    v-fat
    v-carbohydrate
  with frame {&frame-name} .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE change-goods-list Dialog-Frame
PROCEDURE change-goods-list :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-recipe-code as character        no-undo.
define input parameter p-recipe-type as character        no-undo.

    define variable v-line-counter      as integer      no-undo.                   /* порядковый номер строки */
    define variable v-ok                as logical      no-undo.
    define buffer buf_recipe-gds    for recipe-gds.
    define buffer buf_goods         for goods.
   define variable v-attr-value   as character no-undo.
   define variable v-attr-type    as character no-undo.
   define buffer buf_recipe     for recipe.
   define variable ii as integer no-undo .
   define variable type_mark as character no-undo .
   define variable v-attr-value-rec as character no-undo .
do
for buf_recipe-gds
  , buf_goods
on error undo, return error
:
    { gbl/working.i }
    assign
        v-line-counter = 0
    .
    for each buf_recipe-gds
       where buf_recipe-gds.recipe-code = p-recipe-code
      , each goods no-lock
       where goods.artic     = buf_recipe-gds.artic
         and goods.prod-type = buf_recipe-gds.prod-type
         and goods.prod-code = buf_recipe-gds.prod-code
    :


        { cmp/gds-list.i scn-list assign }
        assign
            scn-list.qnty = buf_recipe-gds.brutto-qnty
        .
        if buf_recipe-gds.proc-number > v-line-counter
        then do:        /* вычисляем максимум, нумерация мб не сквозная */
            assign
                v-line-counter = buf_recipe-gds.proc-number
            .
        end.
    end.
    /* уничтожение лишних записей */
    for each scn-list
       where scn-list.to-del = yes
    :
        delete scn-list.
    end.
    { gbl/stopwork.i }
    run str/scn-list.w (
          input parparentproc
        , input v-cntxt-host-code-obj
        , input v-cntxt-obj-type
        , input v-cntxt-obj-code
    ).
    { gbl/working.i }
    if p-recipe-type <> {&alternative}
    then do:        /* всегда перенумеровываем заново */
        assign
            v-line-counter = 0
        .
    end.
    new-list-of-goods:
    for each scn-list
    :
        assign      /* пометка - потенциально лишняя запись */
            scn-list.to-del = yes
        .
        find first buf_goods no-lock
             where buf_goods.prod-type = scn-list.prod-type
               and buf_goods.prod-code = scn-list.prod-code
               and buf_goods.artic     = scn-list.artic
        .
        if buf_goods.gds-type = {&gds-office}
        and p-recipe-type <> {&manufacturing}
        and p-recipe-type <> {&petrolium-manufacturing}
        then do:
            next new-list-of-goods.
        end.
       /*проверка на маркировку для рецептов производства*/
       if p-recipe-type = {&manufacturing} and v-ban-recipes then 
       do:
          run gds-attr-value in this-procedure  ( input buf_goods.gds-code
             , input  {&attr-mark-type}
             , output v-attr-value
             , output v-attr-type
             ) no-error .
          if v-attr-value <> "" and v-attr-value <> "not-type" then  
          do:
             message "Товар " + buf_goods.gds-name + " имеет тип маркировки: " + v-attr-value + " и не может быть добавлен в рецепт производства"
                view-as alert-box.
             next new-list-of-goods.
          end.                                       
       end.   


       if p-recipe-type = {&alternative} and v-ban-altr then 
       do:
          ii = 0 .
          /*проверка на рецепт комплектация для рецептов альтернатива*/
          FIND FIRST ub.recipe NO-LOCK WHERE
             ub.recipe.prod-type = buf_goods.prod-type
             AND ub.recipe.prod-code = buf_goods.prod-code
             AND ub.recipe.artic     = buf_goods.artic 
             and ub.recipe.obj-code = v-cntxt-obj-code
             and ub.recipe.obj-type = v-cntxt-obj-type no-error .
          if available (ub.recipe) then 
          do:
             message "Товар является рецептом: " + ub.recipe.recipe-code + " " + ub.recipe.recipe-name + {&new-line} + " и не может быть добавлен в рецепт альтернатива"
                view-as alert-box.                
             next new-list-of-goods.
          end.   
          /*одинаковый тип маркировки*/
          if ii > 0 then 
          do:
             run gds-attr-value in this-procedure  ( input  buf_goods.gds-code
                , input  {&attr-mark-type}
                , output v-attr-value
                , output v-attr-type
                ) no-error .
             if type_mark <> v-attr-value and v-attr-value <> "" and v-attr-value <> "not-type" then 
             do:
                message "Товар " + buf_goods.gds-name + " имеет тип маркировки: " + v-attr-value + {&new-line} + " и не может быть добавлен в рецепт альтернатива," + {&new-line} + " т.к. уже есть маркированные товары с другим типом"
                   view-as alert-box.                
                next new-list-of-goods.
             end.                                          
          end.
          else 
          do:
             run gds-attr-value in this-procedure  ( input  buf_goods.gds-code
                , input  {&attr-mark-type}
                , output v-attr-value
                , output v-attr-type
                ) no-error .
             if v-attr-value <> "" and v-attr-value <> "not-type" then 
             do:
                type_mark = v-attr-value .     
                ii = 1 .              
             end.
          end.      
       end.   

       if p-recipe-type = {&gathering} and v-ban-recipes then 
       do:
          run gds-attr-value in this-procedure  ( input  buf_goods.gds-code
             , input  {&attr-mark-type}
             , output v-attr-value
             , output v-attr-type
             ) no-error .
          if v-attr-value <> "" and v-attr-value <> "not-type" then 
          do:
             for first buf_recipe no-lock where buf_recipe.recipe-code = p-recipe-code:
                run gds-attr-value in this-procedure  ( input  buf_recipe.gds-code
                   , input  {&attr-mark-type}
                   , output v-attr-value-rec
                   , output v-attr-type
                   ) no-error .         
                if v-attr-value-rec = "" or v-attr-value-rec = "not-type" then
                do:
                   message "Рецепт комплектации " + buf_recipe.recipe-code + " " + buf_recipe.recipe-name + " не маркирован"
                      view-as alert-box.
                   return.
                end.         
             end.
             if v-attr-value <> "milk" then 
             do:
                message "Товар " + buf_goods.gds-name + " не является молочным продуктом"
                   view-as alert-box. 
                next new-list-of-goods.
             end.

          end.                                          
       end.   
 
        assign
            v-line-counter = v-line-counter + 1
            ii = ii + 1
        .
        find first buf_recipe-gds no-lock
             where buf_recipe-gds.recipe-code = p-recipe-code
               and buf_recipe-gds.prod-type   = scn-list.prod-type
               and buf_recipe-gds.prod-code   = scn-list.prod-code
               and buf_recipe-gds.artic       = scn-list.artic
        no-error.
        if not available buf_recipe-gds
        or buf_recipe-gds.brutto-qnty <> scn-list.qnty
        then do:
            run fbrlib-create-or-update-recipe-gds in this-procedure (
                  input p-recipe-code
                , input buf_goods.gds-code
                , input no
                , input scn-list.qnty
                , input v-line-counter
                , input yes
            ).
        end.
    end.
    /* уничтожение лишних записей */
    for each buf_recipe-gds exclusive-lock
       where buf_recipe-gds.recipe-code = p-recipe-code
    :
        if not can-find( scn-list where scn-list.artic      = buf_recipe-gds.artic
                                    and scn-list.prod-type  = buf_recipe-gds.prod-type
                                    and scn-list.prod-code  = buf_recipe-gds.prod-code )
        then do:
            assign
                buf_recipe-gds.nws-self    = yes
            .
            delete buf_recipe-gds.
        end.
    end.
    { gbl/stopwork.i }
end.
END PROCEDURE. /* change-goods-list */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-recipe Dialog-Frame
PROCEDURE check-recipe :
/*------------------------------------------------------------------------------
  Purpose:     проверка корректности строки или шапки
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-recipe-code        as character    no-undo.
define input parameter p-recipe-name        as character    no-undo.
define input parameter p-recipe-qnty        as decimal      no-undo.
define input parameter p-portion-qnty       as decimal      no-undo.
define input parameter p-portion-weight     as decimal      no-undo.
define input parameter p-recipe-ref-num     as character    no-undo.
define input parameter p-recipe-technique   as character    no-undo.
define output parameter p-bad-data          as logical      no-undo.
define output parameter p-error-text        as character    no-undo.

   define variable v-gds-code            as integer   no-undo.
   define variable v-unit-base           as character no-undo.
   define variable v-is-goods            as logical   no-undo.
   define variable v-empty-scale         as logical   no-undo.
   define variable v-ingr-count          as integer   no-undo.
   define variable v-waste-count         as integer   no-undo.
   define variable v-sum-gds-qnty        as decimal   no-undo.
   define variable v-sum-gds-brutto-qnty as decimal   no-undo.
   define variable v-attr-value          as character no-undo.
   define variable v-attr-value-rec      as character no-undo.
   define variable v-attr-type           as character no-undo.
   define variable v-ok                  as logical   no-undo .
   define buffer buf_units            for units.
   define buffer buf_recipe           for recipe.
   define buffer buf_recipe-gds       for recipe-gds.
   define buffer buf_other_recipe-gds for recipe-gds.
   define buffer buf_goods            for ub.goods.

    find first buf_recipe no-lock
         where buf_recipe.recipe-code = p-recipe-code
    .
    { gbl/gdsat.i
        buf_recipe.artic
        buf_recipe.prod-type
        buf_recipe.prod-code
        'empty-scale=request':u
        v-empty-scale
    }
    { gbl/gds-code.i
        buf_recipe.artic
        buf_recipe.prod-type
        buf_recipe.prod-code
        v-gds-code
    }
    { gbl/unitbase.i
        v-gds-code
        v-unit-base
    }
    find first buf_units no-lock
         where buf_units.unit-name = v-unit-base
    .
    if p-portion-qnty < 1
    and buf_recipe.recipe-type = {&manufacturing}
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "Количество порций не может быть меньше 1."
        .
        undo, return.
    end.
    if lookup( {&pieces}, buf_units.type ) > 0
    and buf_recipe.recipe-type = {&manufacturing}
    then do:
        if p-portion-qnty <> p-recipe-qnty
        then do:
            assign
                p-bad-data   = yes
                p-error-text = "Для штучного товара количество порций "
                               + {&new-line} + "должно быть равно количеству товара рецепта."
            .
            undo, return.
        end.
    end.
    if p-recipe-name = ?
    or p-recipe-name = ""
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "Название рецепта не может быть пустым."
        .
        undo, return.
    end.
    if v-empty-scale = no
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "В рецепте могут быть только товары без шкал."
        .
        undo, return.
    end.
    if ( buf_recipe.recipe-type = {&manufacturing}
      or buf_recipe.recipe-type = {&gathering}
      or buf_recipe.recipe-type = {&alternative} )
    and ( p-recipe-qnty <= 0
       or p-recipe-qnty = ? )
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "Количество составного товара рецепта должно быть больше 0."
        .
        undo, return.
    end.
    if lookup( {&pieces}, buf_units.type ) > 0
    and ( truncate( p-recipe-qnty, 0 ) - p-recipe-qnty ) <> 0
    and buf_recipe.recipe-type <> {&alternative}
    then do:        /* при производстве может быть рецепт для вываливания из разных банок, когда эти количества имеют другой смысл - это вес содержимого банки */
        assign
            p-bad-data   = yes
            p-error-text = "Товар рецепта штучный, его количество не может быть дробным."
        .
        undo, return.
    end.
    { gbl/gdsat.i
        buf_recipe.artic
        buf_recipe.prod-type
        buf_recipe.prod-code
        'gds-goods=request':u
        v-is-goods
    }
    if buf_recipe.recipe-type = {&gathering}
    and lookup( {&pieces}, buf_units.type ) = 0
    and v-is-goods = yes
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "Рецепт на комплектацию может быть составлен только для штучного товара."
        .
        undo, return.
    end.
    if buf_recipe.recipe-type = {&dressing}
    and lookup( {&weight}, buf_units.type ) = 0
    and v-is-goods = yes
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "Рецепт на разделку может быть составлен только для весового товара."
        .
        undo, return.
    end.
    if lookup( {&serial}, buf_units.type ) > 0
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "Для серийного товара не может быть составлен рецепт."
        .
        undo, return.
    end.
    assign
        v-ingr-count = 0
    .
    for each buf_recipe-gds
       where buf_recipe-gds.recipe-code = buf_recipe.recipe-code
    :
        if buf_recipe-gds.qnty = 0
        and buf_init_recipe.recipe-type <> {&dressing}
        then do:
            assign
                p-bad-data   = yes
                p-error-text = "Нулевое количество товара в строке рецепта."
                                + {&new-line} + "Артикул товара:" + buf_recipe-gds.artic
            .
            undo, return.
        end.
        if  buf_recipe-gds.artic     = buf_recipe.artic
        and buf_recipe-gds.prod-type = buf_recipe.prod-type
        and buf_recipe-gds.prod-code = buf_recipe.prod-code
        then do:
            assign
                p-bad-data   = yes
                p-error-text = "Строка рецепта не может содержать тот же товар, что и сам рецепт."
            .
            undo, return.
        end.
        { gbl/gds-code.i
            buf_recipe-gds.artic
            buf_recipe-gds.prod-type
            buf_recipe-gds.prod-code
            v-gds-code
        }
        { gbl/unitbase.i
            v-gds-code
            v-unit-base
        }
        find first buf_units no-lock
             where buf_units.unit-name = v-unit-base
        .
        if lookup( {&pieces}, buf_units.type ) > 0
        and ( truncate( buf_recipe-gds.qnty, 0 ) - buf_recipe-gds.qnty ) <> 0
        and buf_recipe.recipe-type <> {&alternative}
        then do:        /* при производстве может быть рецепт для вываливания из разных банок, когда эти количества имеют другой смысл - это вес содержимого банки */
            assign
                p-bad-data   = yes
                p-error-text = "Товар-ингредиент штучный, его количество не может быть дробным."
            .
            undo, return.
        end.
        { gbl/gdsat.i
            buf_recipe-gds.artic
            buf_recipe-gds.prod-type
            buf_recipe-gds.prod-code
            'gds-goods=request':u
            v-is-goods
        }
        if buf_recipe.recipe-type = {&gathering}
        and lookup( {&pieces}, buf_units.type ) = 0
        and v-is-goods = yes
        then do:
            assign
                p-bad-data   = yes
                p-error-text = "В рецепте на комплектацию должен быть только штучный товар."
            .
            undo, return.
        end.
        if buf_recipe.recipe-type = {&dressing}
        and lookup( {&weight}, buf_units.type ) = 0
        and v-is-goods = yes
        then do:
            assign
                p-bad-data   = yes
                p-error-text = "В рецепте на разделку должен быть только весовой товар."
            .
            undo, return.
        end.
        if lookup( {&serial}, buf_units.type ) > 0
        then do:
            assign
                p-bad-data   = yes
                p-error-text = "В рецепте не может быть серийного товара."
            .
            undo, return.
        end.
        if lookup( {&petrolium}, buf_units.type ) > 0
        then do:
            find first buf_other_recipe-gds
                 where buf_other_recipe-gds.artic        = buf_recipe-gds.artic
                   and buf_other_recipe-gds.prod-type    = buf_recipe-gds.prod-type
                   and buf_other_recipe-gds.prod-code    = buf_recipe-gds.prod-code
                   and buf_other_recipe-gds.recipe-code  <> buf_recipe-gds.recipe-code
            no-error.
            if available buf_other_recipe-gds
            then do:
                assign
                    p-bad-data   = yes
                    p-error-text = "Сервисный элемент может входить только в один рецепт."
                .
                undo, return.
            end.
        end.
        if ( buf_recipe.recipe-type <> {&petrolium-manufacturing}
            and lookup( {&petrolium}, buf_units.type ) > 0 )
        or ( buf_recipe.recipe-type = {&petrolium-manufacturing}
            and lookup( {&petrolium}, buf_units.type ) = 0 )
        then do:
            assign
                p-bad-data   = yes
                p-error-text = "Топливный товар (услуга) может входить только в топливный рецепт."
            .
            undo, return.
        end.
        assign
            v-ingr-count = v-ingr-count + 1
        .
        if buf_recipe-gds.is-waste = yes
        then do:
            assign
                v-waste-count = v-waste-count + 1
            .
        end.
        assign
            v-sum-gds-qnty          = v-sum-gds-qnty        + buf_recipe-gds.qnty
        .
    end.        /* for each buf_recipe-gds */
    if buf_recipe.recipe-type = {&dressing}
    and v-sum-gds-qnty <> ?
    and v-sum-gds-qnty <> decimal( fi-recipe-qnty :screen-value in frame {&frame-name} )
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "В рецепте разделки сумма количеств ингредиентов"
                        + {&new-line} + "не равна количеству составного товара."
        .
        undo, return.
    end.
    if v-ingr-count = 0
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "В рецепте нет ни одной строки."
        .
        undo, return.
    end.
    if buf_recipe.recipe-type = {&petrolium-manufacturing}
    and v-ingr-count <> 1
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "В топливном рецепте должна быть ровно 1 строка."
        .
        undo, return.
    end.
    if buf_recipe.recipe-type = {&dressing}
    and v-ingr-count = 1
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "В рецепте разделки не может быть только 1 строка."
        .
        undo, return.
    end.
    if v-ingr-count = v-waste-count
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "Рецепт не может состоять из одних отходов."
        .
        undo, return.
    end.

   /*проверка на маркировку для рецептов производства*/
   if p-recipe-type = {&manufacturing} and v-ban-recipes then 
   do:
      for each ub.recipe-gds no-lock where ub.recipe-gds.recipe-code = buf_recipe.recipe-code:
      run gds-attr-value in this-procedure  ( input  ub.recipe-gds.gds-code
         , input  {&attr-mark-type}
         , output v-attr-value
         , output v-attr-type
         ) no-error .
      if v-attr-value <> "" and v-attr-value <> "not-type" then  
      do:
         for first ub.goods no-lock where ub.goods.gds-code = ub.recipe-gds.gds-code:
         message "Товар " + ub.goods.gds-name + " имеет тип маркировки: " + v-attr-value + " и не может быть добавлен в рецепт производства"
            view-as alert-box.
         end.   
         return error .
      end.   
      end.                                    
   end.   

   if buf_recipe.recipe-type = {&alternative} and v-ban-altr then
   do:
      if not check-ban-sales-via-cd(buf_recipe.gds-code) then do:
               message "Товар " + buf_recipe.recipe-name + " входит в группу, у которой не установлен запрет передачи на кассу."
                  view-as alert-box.
               return error .
      end.
   end.

   if buf_recipe.recipe-type = {&gathering} and v-ban-recipes then
   do:
      
      for each ub.recipe-gds no-lock where ub.recipe-gds.recipe-code = buf_recipe.recipe-code:
         run gds-attr-value in this-procedure  ( input  ub.recipe-gds.gds-code
            , input  {&attr-mark-type}
            , output v-attr-value
            , output v-attr-type
            ) no-error .
         if v-attr-value <> "" and v-attr-value <> "not-type" then
         do:
            if v-attr-value <> "milk" then 
            do:
               for first ub.goods no-lock where ub.goods.gds-code = ub.recipe-gds.gds-code:
                  message "Товар " + ub.goods.gds-name + " не является молочным продуктом"
                     view-as alert-box.
               end.   
               return error .
            end.
            run gds-attr-value in this-procedure  ( input  buf_recipe.gds-code
               , input  {&attr-mark-type}
               , output v-attr-value-rec
               , output v-attr-type
               ) no-error .
            if v-attr-value-rec = "" or v-attr-value-rec = "not-type" then
            do:
               message "Рецепт комплектации" + buf_recipe.recipe-code + " " + buf_recipe.recipe-name + " не маркирован"
                  view-as alert-box.
                 return error.
            end.
            else do:
               if v-attr-value <> v-attr-value-rec then do:
               message "Рецепт комплектации" + buf_recipe.recipe-code + " " + buf_recipe.recipe-name + " маркирован типом " + v-attr-value-rec 
                  view-as alert-box.
                 return error.                  
               end.   
            end.    
         end.      
                  
      end.
   end.

      end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-new-recipe Dialog-Frame
PROCEDURE create-new-recipe :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-gds-name   as character    no-undo.
define input parameter p-gds-code   as integer      no-undo.
define input parameter p-artic      as character    no-undo.
define input parameter p-prod-type  as character    no-undo.
define input parameter p-prod-code  as integer      no-undo.

define buffer buf_recipe        for recipe.

    create buf_recipe .
    assign
        buf_recipe.recipe-type         = p-recipe-type
        buf_recipe.recipe-name         = p-gds-name
        buf_recipe.qnty                = 1.0
        buf_recipe.portion-qnty        = 1
        buf_recipe.gds-code            = p-gds-code
        buf_recipe.artic               = p-artic
        buf_recipe.prod-type           = p-prod-type
        buf_recipe.prod-code           = p-prod-code
        buf_recipe.host-code           = p-host-code
        buf_recipe.obj-type            = p-store-type
        buf_recipe.obj-code            = p-store-code
        buf_recipe.recipe-design       = ""
        buf_recipe.recipe-order        = 0
        buf_recipe.recipe-quality      = ""
        buf_recipe.recipe-ref-num      = ""
        buf_recipe.recipe-technique    = ""
        buf_recipe.recipe-template     = ""
    .
    run fbrcode-gen-recipe-code in this-procedure (
          input p-store-type
        , input p-store-code
        , output buf_recipe.recipe-code
    ).
    assign
        p-out-recipe-code                   = buf_recipe.recipe-code
        p-in-recipe-code                    = buf_recipe.recipe-code
    .
    run fbrlib-recipe-set-default in this-procedure (
        input buf_recipe.recipe-code
    ).

end.
END PROCEDURE. /* create-new-recipe */

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
  DISPLAY fi-recipe-name tb-global fi-recipe-qnty fi-init-units
          fi-recipe-ref-num fi-portion-qnty fi-recipe-technique-label
          fi-portion-weight ed-recipe-technique br-table-label v-fat v-protein
          v-calories v-carbohydrate
      WITH FRAME Dialog-Frame.
  ENABLE b-close b-cancel b-gds b-hst b-rcp b-additional b-recipe-develop
         b-print b-help fi-recipe-name fi-recipe-qnty fi-recipe-ref-num
         fi-portion-qnty fi-portion-weight ed-recipe-technique b-change b-up
         b-down br-table v-fat v-protein v-calories v-carbohydrate
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-goods-recid Dialog-Frame
PROCEDURE get-goods-recid :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define buffer buf_goods     for goods.
do
on error undo, return error
:
    assign
        gds-rec = ?
    .
    if available recipe-gds
    then do:
        find first buf_goods no-lock
             where buf_goods.artic      = recipe-gds.artic
               and buf_goods.prod-type  = recipe-gds.prod-type
               and buf_goods.prod-code  = recipe-gds.prod-code
        no-error.
        if available buf_goods
        then do:
            assign
                gds-rec = recid( buf_goods )
            .
        end.
    end.
end.
END PROCEDURE. /* get-goods-recid */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-have-recipe Dialog-Frame
PROCEDURE get-have-recipe :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-artic          as character  no-undo.
define input parameter p-prod-type      as character  no-undo.
define input parameter p-prod-code      as integer    no-undo.
define output parameter p-have-recipe   as logical    no-undo.

    define buffer buf_recipe        for recipe.
do
on error undo, return error
:

    find first buf_recipe no-lock
         where buf_recipe.obj-type  = ""
           and buf_recipe.obj-code  = 0
           and buf_recipe.artic     = p-artic
           and buf_recipe.prod-type = p-prod-type
           and buf_recipe.prod-code = p-prod-code
    no-error.
    if available buf_recipe
    then do:
        assign
            p-have-recipe = yes
        .
    end.
    else do:
        find first buf_recipe no-lock
             where buf_recipe.obj-type  = p-store-type
               and buf_recipe.obj-code  = p-store-code
               and buf_recipe.artic     = p-artic
               and buf_recipe.prod-type = p-prod-type
               and buf_recipe.prod-code = p-prod-code
        no-error.
        if available buf_recipe
        then do:
            assign
                p-have-recipe = yes
            .
        end.
        else do:
            assign
                p-have-recipe = no
            .
        end.
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-incorrect-nutrition-goods Dialog-Frame
PROCEDURE get-incorrect-nutrition-goods :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input  parameter p-mainmenu-handle   as widget-handle  no-undo .
  define input  parameter p-parent-handle     as widget-handle  no-undo .
  define input  parameter p-log-handle        as handle         no-undo .
  define input  parameter p-parameter-string  as character      no-undo .

  define buffer buf_goods       for ub.goods.
  define buffer buf_recipe-gds  for ub.recipe-gds.

  define variable v-calories      as decimal   no-undo .
  define variable v-protein       as decimal   no-undo .
  define variable v-carbohydrate  as decimal   no-undo .
  define variable v-fat           as decimal   no-undo .


do
on error undo, return error return-value
:

  run write-log in p-log-handle ( input 0
                                , input 'Поиск товаров с неполными данными пищевой и энергетической ценности...':U + {&new-line}
                                ).

  for each buf_recipe-gds no-lock
    where buf_recipe-gds.recipe-code = buf_init_recipe.recipe-code
  , first buf_goods no-lock
      where buf_goods.gds-code = buf_recipe-gds.gds-code
  :
    run nutro_get-nutrition-info in this-procedure ( input  buf_recipe-gds.artic
                                                   , input  buf_recipe-gds.prod-type
                                                   , input  buf_recipe-gds.prod-code
                                                   , input  v-cntxt-obj-type
                                                   , input  v-cntxt-obj-code
                                                   , output v-calories
                                                   , output v-protein
                                                   , output v-carbohydrate
                                                   , output v-fat
                                                   ).
    if  v-calories      = ? or
        v-protein       = ? or
        v-carbohydrate  = ? or
        v-fat           = ?
    then do:
        run write-log in p-log-handle ( input 0
                                      , input substitute("&1 &2 &3 - &4"
                                                        , buf_goods.artic
                                                        , buf_goods.prod-type
                                                        , buf_goods.prod-code
                                                        , buf_goods.gds-name
                                                        )
                                      ).
    end.
  end. /* for each buf_recipe-gds no-lock */
  run write-log in p-log-handle ( input 0
                                , input {&new-line} + 'Поиск товаров завершен.':U
                                ).

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-obj-name Dialog-Frame
PROCEDURE get-obj-name :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-obj-type as character no-undo.
define input parameter p-obj-code as integer no-undo.
define output parameter p-obj-name as character no-undo.

    define buffer buf_clients for clients.

    find first buf_clients no-lock
         where buf_clients.obj-type = p-obj-type
           and buf_clients.obj-code = p-obj-code
    no-error.
    if available buf_clients
    then do:
        assign
            p-obj-name = buf_clients.obj-name
        .
    end.
    else do:
        assign
            p-obj-name = ""
        .
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-fields Dialog-Frame
PROCEDURE init-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    assign
        fi-recipe-name          = buf_init_recipe.recipe-name
        fi-recipe-qnty          = buf_init_recipe.qnty
        fi-portion-qnty         = buf_init_recipe.portion-qnty
        fi-portion-weight       = buf_init_recipe.portion-weight
        fi-recipe-ref-num       = buf_init_recipe.recipe-ref-num
        ed-recipe-technique     = buf_init_recipe.recipe-technique
    .
    if  buf_init_recipe.host-code = 0
    and buf_init_recipe.obj-type = ""
    and buf_init_recipe.obj-code = 0
    then do:
        assign
            tb-global = yes
        .
    end.
    else do:
        assign
            tb-global = no
        .
    end.
    { gbl/curobjdt.i
        v-cntxt-obj-type
        v-cntxt-obj-code
        v-obj-date
        no-error
     }
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-recipe Dialog-Frame
PROCEDURE print-recipe :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :

    define variable sym1          as character init ":"   no-undo.
    define variable sym2          as character init ":"   no-undo.
    define variable sym3          as character init ":"   no-undo.
    define variable sym4          as character init ":"   no-undo.
    define variable sym5          as character init ":"   no-undo.
    define variable sym6          as character init ":"   no-undo.
    define variable sym7          as character init ":"   no-undo.
    define variable sym8          as character init ":"   no-undo.
    define variable Line          as character            no-undo.
    define variable prod-attr     as character            no-undo.
    define variable ii            as integer              no-undo.
    define variable StartRecid    as recid                no-undo.

    DEFINE FRAME List
        sym1 column-label ":" format "x(1)" space(0)
        recipe-gds.artic column-label "Артикул" format "X(16)" space(0)
        sym2 column-label ":" format "x(1)" space(0)
        goods.gds-name COLUMN-LABEL "Название товара" FORMAT "X(40)" space(0)
        sym3 column-label ":" format "x(1)" space(0)
        recipe-gds.qnty column-label "Количество     " format "->>,>>>,>>9.<<<" space(0)
        sym4 column-label ":" format "x(1)" space(0)
        goods.unit-base column-label "Ед.Изм." format "X(7)" space(0)
        sym5 column-label ":" format "x(1)" space(0)
        recipe-gds.is-waste COLUMN-LABEL "Отходы" FORMAT "+/" space(0)
        sym6 column-label ":" format "x(1)" space(0)
        prod-attr COLUMN-LABEL "Производитель" format "x(13)" space(0)
        sym7 column-label ":" format "x(1)" space(0)
        clients.obj-name COLUMN-LABEL "Наименование производителя" FORMAT "X(30)" space(0)
        sym8 column-label ":" format "x(1)" space(0)
        HEADER
            cur-time-print() AT 5 format "X(35)"
                string( "Страница " + string( PAGE-NUMBER( ListStream ) , ">>9") )
                    AT 116 format "X(15)" SKIP
            Line format "x(135)" AT 1
        with width {&A4_CW} down use-text stream-io no-box .

    if num-results( "br-table" ) = 0 then
        do:
            message "Список  П У С Т !" skip view-as alert-box information .
            return no-apply .
        end.

    { gbl/working.i }
    Line = fill( "-" , 150 ) .
    /* Это из-за того, что в QUERY br-table используется index reposition и,
        как следствие, не работает GET first br-table  ( ошибка 3157 ) */
    StartRecid = recid( recipe-gds ) .
    DO WHILE available recipe-gds :
        GET prev br-table NO-LOCK .
    END.
    GET next br-table NO-LOCK .
    ii = 1 .

    { cmp/open-out.i stream ListStream }

    FORM HEADER
                Line format "X(135)" SKIP
                "Продолжение - на следующей странице" AT 30 SKIP
                with FRAME CliBottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS no-box.
    VIEW stream ListStream FRAME CliBottomFrame .
    FIND first goods NO-LOCK
         WHERE goods.prod-type = buf_init_recipe.prod-type
           AND goods.prod-code = buf_init_recipe.prod-code
           AND goods.artic     = buf_init_recipe.artic
    .
    PUT stream ListStream
        space(10) string( "Р Е Ц Е П Т: "  + trim( buf_init_recipe.recipe-name) + " (артикул: " + trim(buf_init_recipe.artic) + ")" ) format "X(100)" skip
        space(10) string( "Д Л Я   Т О В А Р А: " + trim(goods.gds-name) ) format "X(100)" skip(1)
        space(30) string( "Количество : " + string( buf_init_recipe.qnty ) ) format "X(80)" SKIP(1) .
    FORM with frame List .
    DO WHILE available recipe-gds :
        FIND goods WHERE goods.prod-type = recipe-gds.prod-type AND
                         goods.prod-code = recipe-gds.prod-code AND
                         goods.artic = recipe-gds.artic NO-LOCK .
        FIND clients WHERE clients.obj-type = recipe-gds.prod-type AND
                           clients.obj-code = recipe-gds.prod-code NO-LOCK .
        DISPLAY stream ListStream
                        sym1 recipe-gds.artic
                        sym2 goods.gds-name
                        sym3 recipe-gds.qnty
                        sym4 goods.unit-base
                        sym5 recipe-gds.is-waste
                        sym6 recipe-gds.prod-type + " " + STRING (recipe-gds.prod-code) @ prod-attr
                        sym7 clients.obj-name
                        sym8    with frame List .
        DOWN stream ListStream 1 with frame List .
        ii =  ii + 1 .
        GET next br-table .
    END.
    PUT stream ListStream Line format "X(135)" SKIP.
    HIDE stream ListStream FRAME CliBottomFrame .
    output stream ListStream close .
    { gbl/stopwork.i }

    define variable v-user-action           as character            no-undo.
    define variable v-printed               as logical              no-undo.
    run gbl/prnfilen.w (
          input "":U
        , input 0
        , input string( session :temp-directory ) + {&DF_Name} + string( g#report-num )
        , input 7
        , output v-user-action
        , output v-printed
    ) .

    reposition br-table to recid StartRecid .


  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-leave-ed-recipe-technique Dialog-Frame
PROCEDURE proc-leave-ed-recipe-technique :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error return-value
:
  do with frame {&frame-name}:
    assign
      ed-recipe-technique
    .
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ui-on Dialog-Frame
PROCEDURE ui-on :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    run calc-and-display-nutrition-info in this-procedure .
    case p-mode
    :
        when {&lookup}
        then do:
            disable
                fi-recipe-name
                fi-recipe-qnty
                fi-portion-qnty
                fi-portion-weight
                fi-recipe-ref-num
                b-cancel
                b-gds
                b-hst
/*                b-rcp*/
                b-up
                b-down
                tb-global
                b-change
            with frame {&frame-name} .
            assign
                fi-recipe-name         :fgcolor = 4
                fi-recipe-qnty         :fgcolor = 4
                fi-portion-qnty        :fgcolor = 4
                fi-portion-weight      :fgcolor = 4
                fi-recipe-ref-num      :fgcolor = 4
                ed-recipe-technique    :fgcolor = 4
                ed-recipe-technique    :read-only in frame {&frame-name} = yes
            .
        end.        /* when {&lookup} */
        otherwise do:
            if tb-global = no
            and p-can-set-global = yes
            then do:
                define variable v-par-value     as character      no-undo.
                define variable v-par-type      as character      no-undo.
                { gbl/chk-actg.i
                    v-cntxt-db-num
                    v-cntxt-userid
                    {&action-head-code-main}
                    'actn_recipe-reference_conjoint':U
                    {&cntxt-global}
                    0
                    '':U
                    0
                    0
                    0
                    0
                    yes
                    p-can-set-global
                }
               define variable v-value-character as character  no-undo .
               define variable v-value-date      as date       no-undo .
               define variable v-value-decimal   as decimal    no-undo .
               define variable v-value-integer   as integer    no-undo .
               define variable v-value-logical   as logical    no-undo .
               define variable v-tth             as handle     no-undo .
               define variable v-param-type            as character no-undo .

               run adm/shattri.p ( input "get":U
                                 , input  '':u
                                 , input  0
                                 , input  {&attr-fbrattr}
                                 , input  {&attr-fbrattr_fbrrcpgb}
                                 , output v-value-character
                                 , output v-value-date
                                 , output v-value-decimal
                                 , output v-value-integer
                                 , output v-value-logical
                                 , output v-param-type
                                 , input-output table-handle v-tth
                                 ) no-error .
               if error-status :error then do:
                  /* параметр может быть не задан */
                  assign
                     v-value-logical = FALSE
                  .
               end.


                if error-status :error
                or not v-value-logical
                then do:
                    assign
                        p-can-set-global = no
                    .
                end.
                if p-can-set-global = yes
                then do:
                    enable
                        tb-global
                    with frame {&frame-name} .
                end.
            end.        /* if tb-global = no */
        end.        /* otherwise */
    end case.       /* case p-mode */
    if buf_init_recipe.recipe-type = {&manufacturing}
    then do:
        if lookup( {&pieces}, buf_init_units.type ) > 0
        then do:        /* Для штучного товара количество порций = количеству составного товара */
            assign
                fi-portion-qnty = fi-recipe-qnty
            .
            disable
                fi-portion-qnty
            with frame {&frame-name} .
            if p-mode <> {&lookup}
            then do:
                enable
                    fi-portion-weight
                with frame {&frame-name} .
            end.
        end.
        else do:
            assign
                fi-portion-weight = fi-recipe-qnty / fi-portion-qnty
            .
            if p-mode <> {&lookup}
            then do:
                enable
                    fi-portion-qnty
                with frame {&frame-name} .
            end.
            disable
                fi-portion-weight
            with frame {&frame-name} .
        end.
        display
            fi-portion-qnty
            fi-portion-weight
        with frame {&frame-name} .
    end.
    else do:
        assign
            fi-portion-qnty = 1
        .
        hide
            fi-portion-qnty
            fi-portion-weight
        in frame {&frame-name} .
    end.
end.
END PROCEDURE. /* ui-on */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-browse-field Dialog-Frame
FUNCTION get-browse-field RETURNS CHARACTER
  ( input p-parameter-number as integer, input p-artic as character, input p-prod-type as character, input p-prod-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
    define variable v-is-goods      as logical no-undo.
    define variable v-output-string as character no-undo.
    define variable v-gds-code      as integer no-undo.
    define variable v-have-recipe   as logical    no-undo.

    if p-parameter-number = 1
    then do:
        { gbl/gdsat.i
            p-artic
            p-prod-type
            p-prod-code
            'gds-goods=request':u
            v-is-goods
        }
        assign
            v-output-string = ( if v-is-goods = yes then "-":U else "+":U )
        .
    end.
    if p-parameter-number = 2
    then do:
        { gbl/gds-arnm.i
            p-artic
            p-prod-type
            p-prod-code
            v-output-string
        }
    end.
    if p-parameter-number = 3
    then do:
        { gbl/gds-code.i
            p-artic
            p-prod-type
            p-prod-code
            v-gds-code
        }
        { gbl/unitbase.i
            v-gds-code
            v-output-string
        }
    end.
    if p-parameter-number = 4
    then do:
        run get-obj-name in this-procedure (
              input p-prod-type
            , input p-prod-code
            , output v-output-string
        ).
    end.

    if p-parameter-number = 5
    then do:
        assign
            v-have-recipe = no
        .
        { gbl/gdsat.i
            p-artic
            p-prod-type
            p-prod-code
            'gds-goods=request':u
            v-is-goods
        }
        if v-is-goods = yes
        then do:
            run get-have-recipe in this-procedure (
                  input p-artic
                , input p-prod-type
                , input p-prod-code
                , output v-have-recipe
            ).
        end.
        assign
            v-output-string = ( if v-have-recipe = yes then "+":U else "-":U )
        .
    end.

    RETURN v-output-string.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-brutto-qnty Dialog-Frame
FUNCTION get-brutto-qnty RETURNS DECIMAL
  ( buffer buf_recipe-gds for ub.recipe-gds ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  RETURN buf_recipe-gds.qnty * ( 1 + buf_recipe-gds.coeff-waste ) .   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-brutto-qnty-season Dialog-Frame
FUNCTION get-brutto-qnty-season RETURNS DECIMAL
  ( buffer buf_recipe-gds for ub.recipe-gds ) :

    define variable v-void-decimal      as decimal      no-undo.
    define variable v-season-procent    as decimal      no-undo.
    define variable v-void-integer      as integer      no-undo.
    define variable v-brutto            as decimal      no-undo.

    define buffer buf_goods for ub.goods.

    find first buf_goods
         where buf_goods.artic = buf_recipe-gds.artic
           and buf_goods.prod-type = buf_recipe-gds.prod-type
           and buf_goods.prod-code = buf_recipe-gds.prod-code
    no-lock.
    run fbrlib-s-coeff-value in this-procedure (
          input buf_goods.gds-code
        , input v-obj-date
        , input v-cntxt-obj-type
        , input v-cntxt-obj-code
        , output v-season-procent
    ).
    run fbrlib-calc-brutto in this-procedure (
          input p-recipe-type
        , input buf_recipe-gds.qnty
        , input v-season-procent
        , input buf_recipe-gds.coeff-waste
        , input 0.0
        , input 3
        , output v-void-decimal
        , output v-void-decimal
        , output v-brutto
        , output v-void-integer
    ).
    RETURN
        v-brutto
    .   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-season-procent Dialog-Frame
FUNCTION get-season-procent RETURNS DECIMAL
( buffer buf_recipe-gds for ub.recipe-gds ) :
    define variable v-coeff as decimal no-undo.

    define buffer buf_goods for ub.goods.

    find first buf_goods
         where buf_goods.artic      = buf_recipe-gds.artic
           and buf_goods.prod-type  = buf_recipe-gds.prod-type
           and buf_goods.prod-code  = buf_recipe-gds.prod-code
    no-lock.
    run fbrlib-s-coeff-value in this-procedure (
          input buf_goods.gds-code
        , input v-obj-date
        , input v-cntxt-obj-type
        , input v-cntxt-obj-code
        , output v-coeff
    ).
    RETURN v-coeff.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME