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

Редактирование рецепта в документе производства.

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
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-mode               as character        no-undo.
define input parameter p-doc-code           as character        no-undo.
define input parameter p-goods-recid        as recid            no-undo.
define input parameter p-recipe-type        as character        no-undo.
define input parameter p-in-recipe-code     as character        no-undo.
define output parameter p-cancel            as logical          no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование рецепта в документе производства.".
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
{ gbl/fbrnutro.i   }


define stream ListStream.


define variable v-init-gds-unit-is-pieces   as logical        no-undo.
define variable v-init-gds-code             as integer        no-undo.
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

define buffer buf_init_recipe   for fbr-recipe.
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
&Scoped-define INTERNAL-TABLES ub.fbr-recipe-gds

/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table ~
get-browse-field( input 1, input fbr-recipe-gds.artic, input fbr-recipe-gds.prod-type, input fbr-recipe-gds.prod-code ) ~
ub.fbr-recipe-gds.is-waste ub.fbr-recipe-gds.artic ub.fbr-recipe-gds.qnty ~
ub.fbr-recipe-gds.brutto-qnty ub.fbr-recipe-gds.coeff-waste ~
ub.fbr-recipe-gds.coeff-value ~
get-browse-field( input 2, input fbr-recipe-gds.artic, input fbr-recipe-gds.prod-type, input fbr-recipe-gds.prod-code ) ~
get-browse-field( input 3, input fbr-recipe-gds.artic, input fbr-recipe-gds.prod-type, input fbr-recipe-gds.prod-code ) ~
fbr-recipe-gds.prod-type + " ":U + string(fbr-recipe-gds.prod-code) ~
get-browse-field( input 4, input fbr-recipe-gds.artic, input fbr-recipe-gds.prod-type, input fbr-recipe-gds.prod-code ) ~
fbrnutro_get-gds-recipe-nutrition-by-code (fbr-recipe-gds.recipe-code,fbr-recipe-gds.artic, fbr-recipe-gds.prod-type, fbr-recipe-gds.prod-code, {&attr-calories} ) ~
fbrnutro_get-gds-recipe-nutrition-by-code (fbr-recipe-gds.recipe-code, fbr-recipe-gds.artic, fbr-recipe-gds.prod-type, fbr-recipe-gds.prod-code, {&attr-protein} ) ~
fbrnutro_get-gds-recipe-nutrition-by-code (fbr-recipe-gds.recipe-code, fbr-recipe-gds.artic, fbr-recipe-gds.prod-type, fbr-recipe-gds.prod-code, {&attr-fat}) ~
fbrnutro_get-gds-recipe-nutrition-by-code (fbr-recipe-gds.recipe-code, fbr-recipe-gds.artic, fbr-recipe-gds.prod-type, fbr-recipe-gds.prod-code, {&attr-carbohydrate}) 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table 
&Scoped-define QUERY-STRING-br-table FOR EACH ub.fbr-recipe-gds ~
      WHERE fbr-recipe-gds.recipe-code = buf_init_recipe.recipe-code ~
 AND fbr-recipe-gds.doc-code = p-doc-code NO-LOCK ~
    BY ub.fbr-recipe-gds.proc-number
&Scoped-define OPEN-QUERY-br-table OPEN QUERY br-table FOR EACH ub.fbr-recipe-gds ~
      WHERE fbr-recipe-gds.recipe-code = buf_init_recipe.recipe-code ~
 AND fbr-recipe-gds.doc-code = p-doc-code NO-LOCK ~
    BY ub.fbr-recipe-gds.proc-number.
&Scoped-define TABLES-IN-QUERY-br-table ub.fbr-recipe-gds
&Scoped-define FIRST-TABLE-IN-QUERY-br-table ub.fbr-recipe-gds


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-table}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-close b-cancel b-gds b-hst b-rcp ~
b-additional b-print b-help fi-recipe-name fi-recipe-qnty fi-recipe-ref-num ~
fi-portion-qnty ed-recipe-technique b-change b-up b-down br-table v-fat ~
v-protein v-carbohydrate v-calories 
&Scoped-Define DISPLAYED-OBJECTS fi-recipe-name fi-recipe-qnty ~
fi-recipe-ref-num fi-portion-qnty fi-init-units fi-recipe-technique-label ~
ed-recipe-technique br-table-label v-fat v-protein v-carbohydrate ~
v-calories 

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


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-additional 
     LABEL "&Доп.инфо" 
     SIZE 10 BY 1.

DEFINE BUTTON b-cancel 
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

DEFINE BUTTON b-up 
     LABEL "Ввер&х" 
     SIZE 10 BY 1.

DEFINE VARIABLE ed-recipe-technique AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 96.63 BY 2.29 NO-UNDO.

DEFINE VARIABLE br-table-label AS CHARACTER FORMAT "X(256)":U INITIAL "Ингредиенты рецепта" 
     VIEW-AS FILL-IN 
     SIZE 43 BY 1 NO-UNDO.

DEFINE VARIABLE fi-brutto-qnty AS DECIMAL FORMAT ">>>>9.<<<":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE fi-init-units AS CHARACTER FORMAT "X(3)":U 
     LABEL "Ед.изм" 
     VIEW-AS FILL-IN 
     SIZE 4.13 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-portion-qnty AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0 
     LABEL "Порций" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE fi-recipe-name AS CHARACTER FORMAT "X(256)":U 
     LABEL "Наименование" 
     VIEW-AS FILL-IN 
     SIZE 82 BY 1 NO-UNDO.

DEFINE VARIABLE fi-recipe-qnty AS DECIMAL FORMAT ">>>>9.<<<":U INITIAL 0 
     LABEL "Количество" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE fi-recipe-ref-num AS CHARACTER FORMAT "X(14)":U 
     LABEL "Номер по справ. рецептур" 
     VIEW-AS FILL-IN 
     SIZE 14.13 BY 1 NO-UNDO.

DEFINE VARIABLE fi-recipe-portion-weight AS decimal FORMAT ">>>9.999":U 
     LABEL "Вес порции (кг)" 
     VIEW-AS FILL-IN 
     SIZE 14.13 BY 1 NO-UNDO.

DEFINE VARIABLE fi-recipe-technique-label AS CHARACTER FORMAT "X(256)":U INITIAL "Описание технологии приготовления" 
     VIEW-AS FILL-IN 
     SIZE 35 BY 1 NO-UNDO.

DEFINE VARIABLE v-calories AS DECIMAL FORMAT ">>>>9.9":U INITIAL 0 
     LABEL "Калории" 
      VIEW-AS TEXT 
     SIZE 9.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-carbohydrate AS DECIMAL FORMAT ">9.9":U INITIAL 0 
     LABEL "Углеводы" 
      VIEW-AS TEXT 
     SIZE 6.13 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-fat AS DECIMAL FORMAT ">>9.9":U INITIAL 0 
     LABEL "Жиры" 
      VIEW-AS TEXT 
     SIZE 6.13 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-protein AS DECIMAL FORMAT ">>9.9":U INITIAL 0 
     LABEL "Белки" 
      VIEW-AS TEXT 
     SIZE 6.13 BY .67
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-table FOR 
      ub.fbr-recipe-gds SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table Dialog-Frame _STRUCTURED
  QUERY br-table NO-LOCK DISPLAY
      get-browse-field( input 1, input fbr-recipe-gds.artic, input fbr-recipe-gds.prod-type, input fbr-recipe-gds.prod-code ) COLUMN-LABEL "У" FORMAT "X(1)":U
      ub.fbr-recipe-gds.is-waste COLUMN-LABEL "Отх" FORMAT "+/-":U
      ub.fbr-recipe-gds.artic FORMAT "X(16)":U
      ub.fbr-recipe-gds.qnty COLUMN-LABEL "Нетто" FORMAT "->>,>>>,>>9.<<<":U
      ub.fbr-recipe-gds.brutto-qnty FORMAT "->>,>>>,>>9.<<<":U
      ub.fbr-recipe-gds.coeff-waste COLUMN-LABEL "%потерь" FORMAT "->,>>9.<<<":U
            WIDTH 10
      ub.fbr-recipe-gds.coeff-value COLUMN-LABEL "%сезонн" FORMAT "->,>>9.<<<":U
      get-browse-field( input 2, input fbr-recipe-gds.artic, input fbr-recipe-gds.prod-type, input fbr-recipe-gds.prod-code ) COLUMN-LABEL "Название товара" FORMAT "X(40)":U
      get-browse-field( input 3, input fbr-recipe-gds.artic, input fbr-recipe-gds.prod-type, input fbr-recipe-gds.prod-code ) COLUMN-LABEL "ЕИ" FORMAT "X(3)":U
      fbr-recipe-gds.prod-type + " ":U + string(fbr-recipe-gds.prod-code) COLUMN-LABEL "Произв-ль" FORMAT "X(10)":U
      get-browse-field( input 4, input fbr-recipe-gds.artic, input fbr-recipe-gds.prod-type, input fbr-recipe-gds.prod-code ) COLUMN-LABEL "Наименование производителя" FORMAT "X(40)":U
      fbrnutro_get-gds-recipe-nutrition-by-code (fbr-recipe-gds.recipe-code,fbr-recipe-gds.artic, fbr-recipe-gds.prod-type, fbr-recipe-gds.prod-code, {&attr-calories} ) COLUMN-LABEL "Калории" FORMAT ">>>,>>9.<":U
      fbrnutro_get-gds-recipe-nutrition-by-code (fbr-recipe-gds.recipe-code, fbr-recipe-gds.artic, fbr-recipe-gds.prod-type, fbr-recipe-gds.prod-code, {&attr-protein} ) COLUMN-LABEL "Белки" FORMAT ">>>,>>9.<":U
      fbrnutro_get-gds-recipe-nutrition-by-code (fbr-recipe-gds.recipe-code, fbr-recipe-gds.artic, fbr-recipe-gds.prod-type, fbr-recipe-gds.prod-code, {&attr-fat}) COLUMN-LABEL "Жиры" FORMAT ">>>,>>9.<":U
      fbrnutro_get-gds-recipe-nutrition-by-code (fbr-recipe-gds.recipe-code, fbr-recipe-gds.artic, fbr-recipe-gds.prod-type, fbr-recipe-gds.prod-code, {&attr-carbohydrate}) COLUMN-LABEL "Углеводы" FORMAT ">>>,>>9.<":U
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
     b-print AT ROW 1.21 COL 78.63
     b-help AT ROW 1.21 COL 88.63
     fi-recipe-name AT ROW 2.58 COL 14.63 COLON-ALIGNED
     fi-recipe-qnty AT ROW 3.67 COL 14.63 COLON-ALIGNED
     fi-brutto-qnty AT ROW 3.67 COL 38 COLON-ALIGNED NO-LABEL
     fi-recipe-ref-num AT ROW 3.67 COL 82.5 COLON-ALIGNED
     fi-recipe-portion-weight AT ROW 4.79 COL 82.5 COLON-ALIGNED
     fi-portion-qnty AT ROW 4.79 COL 14.63 COLON-ALIGNED
     fi-init-units AT ROW 4.79 COL 38 COLON-ALIGNED
     fi-recipe-technique-label AT ROW 6.04 COL 2 NO-LABEL
     ed-recipe-technique AT ROW 7.21 COL 2 NO-LABEL
     br-table-label AT ROW 9.67 COL 2 NO-LABEL
     b-change AT ROW 9.71 COL 46.63
     b-up AT ROW 9.71 COL 77.88
     b-down AT ROW 9.71 COL 88.63
     br-table AT ROW 10.88 COL 1.75
     v-fat AT ROW 6.21 COL 41.38 COLON-ALIGNED WIDGET-ID 4
     v-protein AT ROW 6.21 COL 54.5 COLON-ALIGNED WIDGET-ID 6
     v-carbohydrate AT ROW 6.21 COL 70.88 COLON-ALIGNED WIDGET-ID 8
     v-calories AT ROW 6.21 COL 87.25 COLON-ALIGNED WIDGET-ID 2
     SPACE(0.47) SKIP(16.65)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Рецепт документа производства".


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

/* SETTINGS FOR FILL-IN br-table-label IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-brutto-qnty IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN fi-init-units IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-recipe-technique-label IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
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
     _TblList          = "ub.fbr-recipe-gds"
     _Options          = "NO-LOCK"
     _OrdList          = "ub.fbr-recipe-gds.proc-number|yes"
     _Where[1]         = "fbr-recipe-gds.recipe-code = buf_init_recipe.recipe-code
 AND fbr-recipe-gds.doc-code = p-doc-code"
     _FldNameList[1]   > "_<CALC>"
"get-browse-field( input 1, input fbr-recipe-gds.artic, input fbr-recipe-gds.prod-type, input fbr-recipe-gds.prod-code )" "У" "X(1)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > ub.fbr-recipe-gds.is-waste
"is-waste" "Отх" "+/-" "logical" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   = ub.fbr-recipe-gds.artic
     _FldNameList[4]   > ub.fbr-recipe-gds.qnty
"qnty" "Нетто" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   = ub.fbr-recipe-gds.brutto-qnty
     _FldNameList[6]   > ub.fbr-recipe-gds.coeff-waste
"coeff-waste" "%потерь" "->,>>9.<<<" "decimal" ? ? ? ? ? ? no ? no no "10" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > ub.fbr-recipe-gds.coeff-value
"coeff-value" "%сезонн" "->,>>9.<<<" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > "_<CALC>"
"get-browse-field( input 2, input fbr-recipe-gds.artic, input fbr-recipe-gds.prod-type, input fbr-recipe-gds.prod-code )" "Название товара" "X(40)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[9]   > "_<CALC>"
"get-browse-field( input 3, input fbr-recipe-gds.artic, input fbr-recipe-gds.prod-type, input fbr-recipe-gds.prod-code )" "ЕИ" "X(3)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[10]   > "_<CALC>"
"fbr-recipe-gds.prod-type + "" "":U + string(fbr-recipe-gds.prod-code)" "Произв-ль" "X(10)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[11]   > "_<CALC>"
"get-browse-field( input 4, input fbr-recipe-gds.artic, input fbr-recipe-gds.prod-type, input fbr-recipe-gds.prod-code )" "Наименование производителя" "X(40)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[12]   > "_<CALC>"
"fbrnutro_get-gds-recipe-nutrition-by-code (fbr-recipe-gds.recipe-code,fbr-recipe-gds.artic, fbr-recipe-gds.prod-type, fbr-recipe-gds.prod-code, {&attr-calories} )" "Калории" ">>>,>>9.<" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[13]   > "_<CALC>"
"fbrnutro_get-gds-recipe-nutrition-by-code (fbr-recipe-gds.recipe-code, fbr-recipe-gds.artic, fbr-recipe-gds.prod-type, fbr-recipe-gds.prod-code, {&attr-protein} )" "Белки" ">>>,>>9.<" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[14]   > "_<CALC>"
"fbrnutro_get-gds-recipe-nutrition-by-code (fbr-recipe-gds.recipe-code, fbr-recipe-gds.artic, fbr-recipe-gds.prod-type, fbr-recipe-gds.prod-code, {&attr-fat})" "Жиры" ">>>,>>9.<" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[15]   > "_<CALC>"
"fbrnutro_get-gds-recipe-nutrition-by-code (fbr-recipe-gds.recipe-code, fbr-recipe-gds.artic, fbr-recipe-gds.prod-type, fbr-recipe-gds.prod-code, {&attr-carbohydrate})" "Углеводы" ">>>,>>9.<" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-table */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Рецепт документа производства */
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

    define buffer buf_fbr-doc for fbr-doc.

    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = p-doc-code
    .
    run ref/recipd.w (
          input p-mode
        , input buf_init_recipe.recipe-code
        , input buf_fbr-doc.obj-type
        , input buf_fbr-doc.obj-code
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
    assign
        p-cancel = yes
    .
    apply "WINDOW-CLOSE" TO FRAME {&FRAME-NAME} .
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

    define buffer buf_units     for units.
    define buffer buf_goods     for goods.

    if available fbr-recipe-gds
    then do:
        { gbl/gds-arnm.i
            fbr-recipe-gds.artic
            fbr-recipe-gds.prod-type
            fbr-recipe-gds.prod-code
            v-goods-name
        }
        { gbl/gds-code.i
            fbr-recipe-gds.artic
            fbr-recipe-gds.prod-type
            fbr-recipe-gds.prod-code
            v-gds-code
        }
        { gbl/unitbase.i
            v-gds-code
            v-units
        }
        find first buf_units no-lock
             where buf_units.unit-name = v-units
        .
        run ref/recipln.w (
              input {&h-recipe}
            , input p-recipe-type
            , input fbr-recipe-gds.recipe-code + " " + fi-recipe-name
            , input fbr-recipe-gds.artic + " " + v-goods-name
            , input lookup( {&pieces}, buf_units.type ) > 0
            , input fbr-recipe-gds.is-waste
            , input fbr-recipe-gds.qnty
            , input fbr-recipe-gds.coeff-value
            , input fbr-recipe-gds.coeff-waste
            , input fbr-recipe-gds.brutto-qnty
            , input fbr-recipe-gds.calc-method
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
/*            on error undo, return error*/
            :
                find current fbr-recipe-gds exclusive-lock .
                assign
                    fbr-recipe-gds.is-waste    = v-is-waste
                    fbr-recipe-gds.qnty        = v-new-qnty
                    fbr-recipe-gds.coeff-waste = v-new-coeff-waste
                    fbr-recipe-gds.brutto-qnty = v-new-brutto-qnty
                    fbr-recipe-gds.calc-method = v-new-calc-method
                .
            end.        /* do transaction */
            br-table :refresh().
            run calc-and-display-nutrition-info in this-procedure .
        end.
    end.        /* if available fbr-recipe-gds */
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
        apply "window-close" to frame {&frame-name} .
    end.
    assign
        fi-recipe-name
        fi-recipe-qnty
        fi-brutto-qnty
        fi-portion-qnty
        fi-recipe-ref-num
        fi-recipe-portion-weight
        ed-recipe-technique
    .
    run check-recipe in this-procedure (
            input buf_init_recipe.recipe-code
          , input fi-recipe-name
          , input fi-recipe-qnty
          , input fi-brutto-qnty
          , input fi-portion-qnty
          , input fi-recipe-ref-num
          , input fi-recipe-portion-weight
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
        buf_init_recipe.recipe-name         = fi-recipe-name
        buf_init_recipe.qnty                = fi-recipe-qnty
        buf_init_recipe.brutto-qnty         = fi-brutto-qnty
        buf_init_recipe.portion-qnty        = fi-portion-qnty
        buf_init_recipe.recipe-ref-num      = fi-recipe-ref-num
        buf_init_recipe.portion-weight      = fi-recipe-portion-weight
        buf_init_recipe.recipe-technique    = ed-recipe-technique
    .
    assign
        p-cancel = no
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

    if not available fbr-recipe-gds
    then do:
        return no-apply.
    end.
    apply "entry" to br-table .
    assign
        v-focused-row   = br-table :focused-row in frame {&FRAME-NAME}
        v-cur-line      = recid( fbr-recipe-gds )
        v-proc-number   = fbr-recipe-gds.proc-number
    .
    get next br-table.
    if not available fbr-recipe-gds
    then do:
        apply "entry" to br-table.
        return no-apply.
    end.
    { gbl/working.i }
    swap-down:
    do
    on error undo swap-down, return no-apply
    :
        find current fbr-recipe-gds exclusive-lock .
        assign
            v-old-proc-number       = fbr-recipe-gds.proc-number
            fbr-recipe-gds.proc-number  = v-proc-number
        .
        find first fbr-recipe-gds
             where recid( fbr-recipe-gds ) = v-cur-line
        .
        assign
            v-focused-row          = v-focused-row + 1
            fbr-recipe-gds.proc-number = v-old-proc-number
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
define variable scr-qnty    like fbr-recipe.qnty no-undo.             /* количество на экране для временного хранения */
define variable scr-name    like fbr-recipe.recipe-name no-undo.      /* название на экране для временного хранения */
define variable line-order  as integer no-undo.                   /* порядковый номер строки */
define buffer buf_fbr-doc for ub.fbr-doc.
    assign
        scr-qnty = input frame {&frame-name} fi-recipe-qnty
        scr-name = input frame {&frame-name} fi-recipe-name
    .
    { gbl/working.i }
    assign
        line-order = 0
    .
    for each fbr-recipe-gds
       where fbr-recipe-gds.doc-code    = p-doc-code
         and fbr-recipe-gds.recipe-code = buf_init_recipe.recipe-code
      , each goods no-lock
       where goods.artic     = fbr-recipe-gds.artic
         and goods.prod-type = fbr-recipe-gds.prod-type
         and goods.prod-code = fbr-recipe-gds.prod-code
    :
        { cmp/gds-list.i scn-list assign }
        assign
            scn-list.qnty = fbr-recipe-gds.qnty
        .
        if fbr-recipe-gds.proc-number > line-order
        then do:        /* вычисляем максимум, нумерация мб не сквозная */
            assign
                line-order = fbr-recipe-gds.proc-number
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
          input p-mainmenu-handle
        , input v-cntxt-host-code-obj
        , input v-cntxt-obj-type
        , input v-cntxt-obj-code
    ).
    { gbl/working.i }
    if buf_init_recipe.recipe-type <> {&alternative}
    then do:        /* всегда перенумеровываем заново */
        assign
            line-order = 0
        .
    end.
    for each scn-list
      , each goods no-lock
       where goods.prod-type = scn-list.prod-type
         and goods.prod-code = scn-list.prod-code
         and goods.artic     = scn-list.artic
    by scn-list.artic
    :
        assign      /* пометка - потенциально лишняя запись */
            scn-list.to-del = yes
        .
        if goods.gds-type = {&gds-office}
        and buf_init_recipe.recipe-type = {&alternative}
        then do:
            next.
        end.
        find first fbr-recipe-gds
             where fbr-recipe-gds.doc-code    = p-doc-code
               and fbr-recipe-gds.recipe-code = buf_init_recipe.recipe-code
               and fbr-recipe-gds.prod-type   = scn-list.prod-type
               and fbr-recipe-gds.prod-code   = scn-list.prod-code
               and fbr-recipe-gds.artic       = scn-list.artic
        no-error.
        if not available fbr-recipe-gds
        then do:
            find first buf_fbr-doc no-lock
                 where buf_fbr-doc.doc-code = p-doc-code
            no-error.
            if error-status:error
            then do:
                message substitute ("Не найден документ производства с номером &1", p-doc-code) view-as alert-box error.
                undo, return no-apply.
            end.
            run fbrlib_create-fbr-recipe-gds in this-procedure (
                  input p-doc-code
                , input buf_init_recipe.recipe-code
                , input scn-list.prod-type
                , input scn-list.prod-code
                , input scn-list.artic
                , input scn-list.gds-code
                , input no
                , input 0
                , input buf_fbr-doc.doc-date
                , input buf_fbr-doc.obj-type
                , input buf_fbr-doc.obj-code
                , input 1
                , input 0
                , input 0
                , input 0
            ) no-error.
            if error-status:error
            then do:
                message substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) view-as alert-box error.
                undo, return no-apply.
            end.
            find first fbr-recipe-gds exclusive-lock
                 where fbr-recipe-gds.doc-code    = p-doc-code
                   and fbr-recipe-gds.recipe-code = buf_init_recipe.recipe-code
                   and fbr-recipe-gds.prod-type   = scn-list.prod-type
                   and fbr-recipe-gds.prod-code   = scn-list.prod-code
                   and fbr-recipe-gds.artic       = scn-list.artic
            .
        end.
        assign
            fbr-recipe-gds.qnty         = scn-list.qnty
            fbr-recipe-gds.brutto-qnty  = fbr-recipe-gds.qnty
        .
        case buf_init_recipe.recipe-type
        :
            when {&dressing}
            then do:
                assign
                    line-order                  = line-order + 1
                    fbr-recipe-gds.proc-number  = line-order
                .
            end.
            when {&gathering}
            then do:
                if fbr-recipe-gds.qnty = ?
                then do:
                    assign
                        fbr-recipe-gds.qnty         = 1
                        fbr-recipe-gds.brutto-qnty  = fbr-recipe-gds.qnty
                    .
                end.
                assign
                    line-order              = line-order + 1
                    fbr-recipe-gds.proc-number  = line-order
                .
            end.
            when {&manufacturing}
            then do:
                if fbr-recipe-gds.qnty = ?
                then do:
                    assign
                        fbr-recipe-gds.qnty         = 0
                        fbr-recipe-gds.brutto-qnty  = fbr-recipe-gds.qnty
                    .
                end.
                assign
                    line-order              = line-order + 1
                    fbr-recipe-gds.proc-number  = line-order
                .
            end.
            when {&alternative}
            then do:
                if fbr-recipe-gds.qnty = ?
                then do:
                    assign
                        fbr-recipe-gds.qnty         = 0
                        fbr-recipe-gds.brutto-qnty  = fbr-recipe-gds.qnty
                    .
                end.
                if fbr-recipe-gds.proc-number = 0
                then do:
                    assign
                        line-order              = line-order + 1
                        fbr-recipe-gds.proc-number  = line-order
                    .
                end.
            end.
        end case.
    end.
    /* уничтожение лишних записей */
    for each fbr-recipe-gds
       where fbr-recipe-gds.doc-code    = p-doc-code
         and fbr-recipe-gds.recipe-code = buf_init_recipe.recipe-code
    :
        if not can-find( scn-list where scn-list.artic = fbr-recipe-gds.artic
                                    and scn-list.prod-type = fbr-recipe-gds.prod-type
                                    and scn-list.prod-code = fbr-recipe-gds.prod-code )
        then do:
            delete fbr-recipe-gds.
        end.
    end.
    { gbl/stopwork.i }
    run enable_UI.
    assign
        fi-recipe-name = scr-name
        fi-recipe-qnty = scr-qnty
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
    apply "entry" to br-table.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
{ gbl/stdbtn.i }

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
        fbr-recipe-gds.artic column-label "Артикул" format "X(16)" space(0)
        sym2 column-label ":" format "x(1)" space(0)
        goods.gds-name COLUMN-LABEL "Название товара" FORMAT "X(40)" space(0)
        sym3 column-label ":" format "x(1)" space(0)
        fbr-recipe-gds.qnty column-label "Количество     " format "->>,>>>,>>9.<<<" space(0)
        sym4 column-label ":" format "x(1)" space(0)
        goods.unit-base column-label "Ед.Изм." format "X(7)" space(0)
        sym5 column-label ":" format "x(1)" space(0)
        fbr-recipe-gds.is-waste COLUMN-LABEL "Отходы" FORMAT "+/" space(0)
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
    StartRecid = recid( fbr-recipe-gds ) .
    DO WHILE available fbr-recipe-gds :
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
    DO WHILE available fbr-recipe-gds :
        FIND goods WHERE goods.prod-type = fbr-recipe-gds.prod-type AND
                         goods.prod-code = fbr-recipe-gds.prod-code AND
                         goods.artic = fbr-recipe-gds.artic NO-LOCK .
        FIND clients WHERE clients.obj-type = fbr-recipe-gds.prod-type AND
                           clients.obj-code = fbr-recipe-gds.prod-code NO-LOCK .
        DISPLAY stream ListStream
                        sym1 fbr-recipe-gds.artic
                        sym2 goods.gds-name
                        sym3 fbr-recipe-gds.qnty
                        sym4 goods.unit-base
                        sym5 fbr-recipe-gds.is-waste
                        sym6 fbr-recipe-gds.prod-type + " " + STRING (fbr-recipe-gds.prod-code) @ prod-attr
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
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-rcp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-rcp Dialog-Frame
ON CHOOSE OF b-rcp IN FRAME Dialog-Frame /* Рецепт */
DO:
{ gbl/stdbtn.i }
    if not available fbr-recipe-gds
    then do:
        message "Неправильно выбрана строка рецепта.".
        return no-apply.
    end.
    else do:
        run add-recipe in this-procedure (
              input fbr-recipe-gds.artic
            , input fbr-recipe-gds.prod-type
            , input fbr-recipe-gds.prod-code
        ).
    end.
    run enable_UI.
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

    if not available fbr-recipe-gds
    then do:
        return no-apply.
    end.
    apply "entry" to br-table .
    assign
        v-focused-row   = br-table :focused-row in frame {&FRAME-NAME}
        v-cur-line      = recid( fbr-recipe-gds )
        v-proc-number   = fbr-recipe-gds.proc-number
    .
    get prev br-table.
    if not available fbr-recipe-gds
    then do:
        apply "entry" to br-table.
        return no-apply.
    end.
    { gbl/working.i }
    swap-up:
    do
    on error undo swap-up, return no-apply
    :
        find current fbr-recipe-gds exclusive-lock .
        assign
            v-old-proc-number       = fbr-recipe-gds.proc-number
            fbr-recipe-gds.proc-number  = v-proc-number
        .
        find first fbr-recipe-gds exclusive-lock
             where recid( fbr-recipe-gds ) = v-cur-line
        .
        assign
            fbr-recipe-gds.proc-number = v-old-proc-number
            v-focused-row          = v-focused-row - 1
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


&Scoped-define SELF-NAME fi-brutto-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-brutto-qnty Dialog-Frame
ON LEAVE OF fi-brutto-qnty IN FRAME Dialog-Frame
DO:
/*
    define variable v-yesno    as logical        no-undo.
    if decimal( fi-brutto-qnty :screen-value ) < decimal( fi-recipe-qnty :screen-value )
    then do:
        message
            skip "Введенное значение Брутто меньше Нетто."
            skip "Вы можете изменить вес Нетто"
            skip "или отменить изменение Брутто."
            skip(1)
            skip "Изменить Нетто?"
        view-as alert-box question
        buttons ok-cancel
        title "Изменение веса Нетто"
        update v-yesno.
        if v-yesno = yes
        then do:
            assign
                fi-brutto-qnty
                fi-recipe-qnty = fi-brutto-qnty
            .
            display
                fi-recipe-qnty
            with frame {&frame-name}.
        end.
        else do:
            undo, return no-apply.
        end.
    end.
    else do:
        assign
            fi-brutto-qnty
        .
    end.
*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-recipe-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-recipe-qnty Dialog-Frame
ON LEAVE OF fi-recipe-qnty IN FRAME Dialog-Frame /* Количество */
DO:
    define variable v-yesno    as logical        no-undo.

    assign
        fi-recipe-qnty
    .
    run calc-and-display-nutrition-info in this-procedure .
/*
    if decimal( fi-brutto-qnty :screen-value ) = fi-recipe-qnty
    then do:
        assign
            fi-recipe-qnty
            fi-brutto-qnty = fi-recipe-qnty
        .
        display
            fi-brutto-qnty
        with frame {&frame-name}.
    end.
    else do:
        if decimal( fi-brutto-qnty :screen-value ) < decimal( fi-recipe-qnty :screen-value )
        then do:
            message
                skip "Введенное значение Нетто больше Брутто."
                skip "Вы можете изменить вес Брутто"
                skip "или отменить изменение Нетто."
                skip(1)
                skip "Изменить Брутто?"
            view-as alert-box question
            buttons ok-cancel
            title "Изменение веса Брутто"
            update v-yesno.
            if v-yesno = yes
            then do:
                assign
                    fi-recipe-qnty
                    fi-brutto-qnty = fi-recipe-qnty
                .
                display
                    fi-brutto-qnty
                with frame {&frame-name}.
            end.
            else do:
                undo, return no-apply.
            end.
        end.
        else do:
            assign
                fi-recipe-qnty
            .
        end.
    end.
*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-table
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


{ gbl/app_help.i }

{ gbl/hot-key.i b-close }
{ gbl/hot-key.i b-print }

/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    { gbl/getcntxt.i get " " p-mainmenu-handle }
    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).
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
    if lookup( {&pieces}, buf_init_units.type ) > 0
    then do:
        assign
            fi-brutto-qnty = fi-recipe-qnty
        .
    end.
    case p-mode:
        when {&update}
        then do:
            find first buf_init_recipe exclusive-lock
                 where buf_init_recipe.doc-code    = p-doc-code
                   and buf_init_recipe.recipe-code = p-in-recipe-code
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
                 where buf_init_recipe.doc-code    = p-doc-code
                   and buf_init_recipe.recipe-code = p-in-recipe-code
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
    run calc-and-display-nutrition-info in this-procedure .
    case p-mode
    :
        when {&lookup}
        then do:
            disable
                fi-recipe-name
                fi-recipe-qnty
                fi-brutto-qnty
                fi-portion-qnty
                fi-recipe-ref-num
                fi-recipe-portion-weight
                b-cancel
                b-gds
                b-hst
                b-rcp
                b-up
                b-down
                b-change
            with frame {&frame-name} .
            assign
                fi-recipe-name         :fgcolor = 4
                fi-recipe-qnty         :fgcolor = 4
                fi-brutto-qnty         :fgcolor = 4
                fi-portion-qnty        :fgcolor = 4
                fi-recipe-ref-num      :fgcolor = 4
                fi-recipe-portion-weight       :fgcolor = 4
                ed-recipe-technique    :fgcolor = 4
                ed-recipe-technique    :read-only in frame {&frame-name} = yes
            .
        end.        /* when {&lookup} */
        otherwise do:
        end.        /* otherwise */
    end case.       /* case p-mode */
    if lookup( {&pieces}, buf_init_units.type ) > 0
    then do:
        disable
            fi-brutto-qnty
        with frame {&frame-name} .
        assign
            fi-brutto-qnty         :fgcolor = 4
        .
    end.
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
    define buffer buf_fbr-doc   for fbr-doc.

    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = p-doc-code
    .
    find first buf_goods no-lock
         where buf_goods.artic     = p-artic
           AND buf_goods.prod-type = p-prod-type
           AND buf_goods.prod-code = p-prod-code
    .
    run ref/rcp-all.w (
          input p-mainmenu-handle
        , input ( if p-mode = {&lookup} then "" else "b-add" )
        , input {&all}
        , input recid( buf_goods )
        , input buf_fbr-doc.obj-type
        , input buf_fbr-doc.obj-code
        , output v-ref-list
    ).
end.
END PROCEDURE. /* add-recipe */

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
define input parameter p-brutto-qnty        as decimal      no-undo.
define input parameter p-portion-qnty       as decimal      no-undo.
define input parameter p-recipe-ref-num     as character    no-undo.
define input parameter p-recipe-portion-weight as char      no-undo.
define input parameter p-recipe-technique   as character    no-undo.
define output parameter p-bad-data          as logical      no-undo.
define output parameter p-error-text        as character    no-undo.

    define variable v-gds-code          as integer        no-undo.
    define variable v-unit-base         as character      no-undo.
    define variable v-is-goods          as logical        no-undo.
    define variable v-empty-scale       as logical        no-undo.
    define variable v-ingr-count        as integer        no-undo.
    define variable v-waste-count       as integer        no-undo.

    define buffer buf_units             for units.
    define buffer buf_recipe            for fbr-recipe.
    define buffer buf_recipe-gds        for fbr-recipe-gds.
    define buffer buf_other_recipe-gds  for fbr-recipe-gds.

    if p-portion-qnty < 1
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "Количество порций не может быть меньше 1."
        .
        undo, return.
    end.
    if lookup( {&pieces}, buf_init_units.type ) > 0
    then do:
        if p-portion-qnty > p-recipe-qnty
        then do:
            assign
                p-bad-data   = yes
                p-error-text = "Для штучного товара количество порций не может быть больше количества товара рецепта."
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
    find first buf_recipe no-lock
         where buf_recipe.doc-code    = p-doc-code
           and buf_recipe.recipe-code = p-recipe-code
    .
    { gbl/gdsat.i
        buf_recipe.artic
        buf_recipe.prod-type
        buf_recipe.prod-code
        'empty-scale=request':u
        v-empty-scale
    }
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
       where buf_recipe-gds.doc-code    = p-doc-code
         and buf_recipe-gds.recipe-code = buf_recipe.recipe-code
    :
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
                p-error-text =  "Товар-ингредиент штучный, его количество не может быть дробным."
                                + {&new-line} + substitute( "Артикул: &1", buf_recipe-gds.artic )
            .
            undo, return.
        end.
        if buf_recipe-gds.brutto-qnty < buf_recipe-gds.qnty
        then do:
            assign
                p-bad-data   = yes
                p-error-text = "Брутто товара не может быть меньше нетто."
                                + {&new-line} + substitute( "Артикул: &1", buf_recipe-gds.artic )
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
/*    if buf_recipe.recipe-type = {&dressing} */
/*    then do:*/

/*    end.*/
    if v-ingr-count = v-waste-count
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "Рецепт не может состоять из одних отходов."
        .
        undo, return.
    end.
end.
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
  DISPLAY fi-recipe-name fi-recipe-qnty fi-recipe-ref-num fi-recipe-portion-weight fi-portion-qnty 
          fi-init-units fi-recipe-technique-label ed-recipe-technique 
          br-table-label v-fat v-protein v-carbohydrate v-calories 
      WITH FRAME Dialog-Frame.
  ENABLE b-close b-cancel b-gds b-hst b-rcp b-additional b-print b-help 
         fi-recipe-name fi-recipe-qnty fi-recipe-ref-num fi-recipe-portion-weight fi-portion-qnty 
         ed-recipe-technique b-change b-up b-down br-table v-fat v-protein 
         v-carbohydrate v-calories 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
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
        fi-brutto-qnty          = buf_init_recipe.brutto-qnty
        fi-portion-qnty         = buf_init_recipe.portion-qnty
        fi-recipe-ref-num       = buf_init_recipe.recipe-ref-num
        fi-recipe-portion-weight        = buf_init_recipe.portion-weight
        ed-recipe-technique     = buf_init_recipe.recipe-technique
    .
end.
END PROCEDURE.

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
    define variable v-is-goods  as logical no-undo.
    define variable v-output-string as character no-undo.
    define variable v-gds-code as integer no-undo.

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

    RETURN v-output-string.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

