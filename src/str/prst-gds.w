&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
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

Добавление/изменение строки в документе пересортица

Автор: Чернова Светлана Александровна
Дата создания: 09/12/06
Author: Svetlana Chernova
Creation date: 09/12/06

Автор1: Суслов Алексей Юрьевич

*/
/*----------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/peresort.i }
{ cmp/gds-list.i gds-list def "new shared" }
{ str/get-pr.i def }
{ ref/gds-attr.i }
/* Parameters Definitions ---                                           */
define input  parameter parparentproc       as   handle              no-undo.
define input  parameter pardoc-code         like ub.trn-doc.doc-code no-undo.
define input  parameter parmode             as   character           no-undo.
define input  parameter parobj-type         as   character           no-undo.
define input  parameter parobj-code         as   integer             no-undo.
define input  parameter pargds-code         like ub.goods.gds-code   no-undo.
define input  parameter pargds-code-plus    like ub.goods.gds-code   no-undo.
define input  parameter parqnty             as   decimal             no-undo.
define input  parameter parqnty-kg          as   decimal             no-undo.
define input  parameter parqnty-plus        as   decimal             no-undo.
define input  parameter parqnty-kg-plus     as   decimal             no-undo.
define input  parameter parpstunqtn-log     as   logical             no-undo.
define input  parameter parpstunit          as   logical             no-undo.
define input  parameter parmxpcicp-dec      as   decimal             no-undo.
define input  parameter parmxpcdcp-dec      as   decimal             no-undo.
define input  parameter parmxsmicp-dec      as   decimal             no-undo.
define input  parameter parmxsmdcp-dec      as   decimal             no-undo.
define output parameter paroutgds-code      like ub.goods.gds-code initial ?  no-undo.
define output parameter paroutgds-code-plus like ub.goods.gds-code initial ?  no-undo.
define output parameter table for tt-gds-dtl.
define output parameter table for tt-pl-qty.
define output parameter paroutqnty          as   decimal           initial ?  no-undo.
define output parameter paroutqnty-plus     as   decimal           initial ?  no-undo.
define output parameter paroutqnty-kg       as   decimal           initial ?  no-undo.
define output parameter paroutqnty-kg-plus  as   decimal           initial ?  no-undo.
define output parameter table for tt-gds-dtl-plus.
define output parameter table for tt-pl-qty-plus.
define output parameter parset              as   logical           initial no no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Экран определения строки пересортицы":U .
{ cmp/vssrevis.i }

DEFINE BUFFER bf_goods        FOR ub.goods.
DEFINE BUFFER bf_goods-plus   FOR ub.goods.
DEFINE BUFFER bf_units        FOR ub.units.
DEFINE BUFFER bf_units-plus   FOR ub.units.
DEFINE BUFFER bf_clients      FOR ub.clients.
DEFINE BUFFER bf_clients-plus FOR ub.clients.
define buffer bf_clients-host for ub.clients.

{ ref/grp-attr.i }
define new shared temp-table tt-gds-prt no-undo
field prt-code like ub.gds-dtl.prt-code
field prt-name as character
field write-off-before-qnty as decimal format ">,>>>,>>>,>>9.9999"
field income-before-qnty    as decimal format ">,>>>,>>>,>>9.9999"
field write-off-qnty        as decimal format ">,>>>,>>>,>>9.9999"
field income-qnty           as decimal format ">,>>>,>>>,>>9.9999"
field fact-qnty             as decimal format ">,>>>,>>>,>>9.9999"
index pi is unique primary prt-code.

define new shared temp-table tt-place no-undo
field pl-code             like ub.place.pl-code
field loc1                like ub.place.loc1
field pl-name             like ub.place.pl-name
field before-l            as   decimal format ">,>>>,>>>,>>9.9999"
field before-kg           as   decimal format ">,>>>,>>>,>>9.9999"
field write-off-l         as   decimal format ">,>>>,>>>,>>9.9999"
field income-l            as   decimal format ">,>>>,>>>,>>9.9999"
field write-off-kg        as   decimal format ">,>>>,>>>,>>9.9999"
field income-kg           as   decimal format ">,>>>,>>>,>>9.9999"
field write-off-doc-l     as   decimal format ">,>>>,>>>,>>9.9999"
field income-doc-l        as   decimal format ">,>>>,>>>,>>9.9999"
field write-off-doc-kg    as   decimal format ">,>>>,>>>,>>9.9999"
field income-doc-kg       as   decimal format ">,>>>,>>>,>>9.9999"
index pi is unique primary pl-code.
define variable is-petrol      as logical no-undo.
define variable is-pieces      as logical no-undo.
define variable is-petrol-plus as logical no-undo.
define variable is-pieces-plus as logical no-undo.

define variable vargds-dtl-qnty          as decimal no-undo.
define variable varmem-gds-dtl-qnty      as decimal no-undo.
define variable vargds-dtl-qnty-plus     as decimal no-undo.
define variable varmem-gds-dtl-qnty-plus as decimal no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-cancel b-help RECT-1 RECT-2
&Scoped-Define DISPLAYED-OBJECTS varqnty-kg varartic vargds-name ~
varprod-code varprod-type varqnty varunit-name varartic-plus ~
vargds-name-plus varprod-code-plus varprod-type-plus varqnty-plus ~
varunit-name-plus varqnty-kg-plus

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-prt-in
     LABEL "Шкала оп."
     SIZE 10 BY 1.

DEFINE BUTTON b-prt-wr
     LABEL "Шкала сп."
     SIZE 10 BY 1.

DEFINE BUTTON b-save AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON r-goods
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE BUTTON r-goods-plus
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE BUTTON r-list
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE BUTTON r-list-plus
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE VARIABLE varartic AS CHARACTER FORMAT "X(256)":U
     LABEL "Артикул"
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varartic-plus AS CHARACTER FORMAT "X(256)":U
     LABEL "Артикул"
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varfull-scale-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Шкала"
     VIEW-AS FILL-IN
     SIZE 57 BY 1 NO-UNDO.

DEFINE VARIABLE varfull-scale-name-plus AS CHARACTER FORMAT "X(256)":U
     LABEL "Шкала"
     VIEW-AS FILL-IN
     SIZE 57.5 BY 1 NO-UNDO.

DEFINE VARIABLE vargds-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 57 BY 1 NO-UNDO.

DEFINE VARIABLE vargds-name-plus AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 57.5 BY 1 NO-UNDO.

DEFINE VARIABLE varprod-code AS INTEGER FORMAT ">>>>>>>>>9":U INITIAL 0
     LABEL "Производитель"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE varprod-code-plus AS INTEGER FORMAT ">>>>>>>>>9":U INITIAL 0
     LABEL "Производитель"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE varprod-type AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE varprod-type-plus AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE varqnty AS DECIMAL FORMAT ">>>,>>>,>>9.999":U INITIAL 0
     LABEL "Списываемое количество"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE varqnty-kg AS DECIMAL FORMAT ">>>,>>>,>>9.999":U INITIAL 0
     LABEL "Кг"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE varqnty-kg-plus AS DECIMAL FORMAT ">>>,>>>,>>9.999":U INITIAL 0
     LABEL "Кг"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE varqnty-plus AS DECIMAL FORMAT ">>>,>>>,>>9.999":U INITIAL 0
     LABEL "Приходуемое количество"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE varunit-name AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE varunit-name-plus AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 97.5 BY .08.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 97.5 BY .08.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-prt-wr AT ROW 1 COL 21
     varqnty-kg AT ROW 5.5 COL 45 COLON-ALIGNED
     varartic AT ROW 3 COL 14 COLON-ALIGNED
     b-help AT ROW 1 COL 88.5
     r-goods AT ROW 3 COL 33.5
     r-list AT ROW 3 COL 37
     vargds-name AT ROW 3 COL 39.5 COLON-ALIGNED NO-LABEL
     varprod-code AT ROW 4.25 COL 14 COLON-ALIGNED
     varprod-type AT ROW 4.25 COL 28 COLON-ALIGNED NO-LABEL
     varfull-scale-name AT ROW 4.25 COL 34.5
     varqnty AT ROW 5.5 COL 23 COLON-ALIGNED
     varunit-name AT ROW 5.5 COL 36.5 COLON-ALIGNED NO-LABEL
     varartic-plus AT ROW 7.5 COL 14.5 COLON-ALIGNED
     r-goods-plus AT ROW 7.5 COL 34
     r-list-plus AT ROW 7.5 COL 37
     vargds-name-plus AT ROW 7.5 COL 39 COLON-ALIGNED NO-LABEL
     varprod-code-plus AT ROW 8.75 COL 14.5 COLON-ALIGNED
     varprod-type-plus AT ROW 8.75 COL 28 COLON-ALIGNED NO-LABEL
     varfull-scale-name-plus AT ROW 8.75 COL 34
     varqnty-plus AT ROW 10 COL 23.5 COLON-ALIGNED
     varunit-name-plus AT ROW 10 COL 36.5 COLON-ALIGNED NO-LABEL
     varqnty-kg-plus AT ROW 10 COL 45 COLON-ALIGNED
     b-prt-in AT ROW 1 COL 31
     RECT-1 AT ROW 6.75 COL 1
     RECT-2 AT ROW 2.5 COL 1
     SPACE(0.00) SKIP(8.66)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Обработка связок товаров в документе пересортицы"
         CANCEL-BUTTON b-cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   Custom                                                               */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-prt-in IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-prt-wr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-save IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON r-goods IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON r-goods-plus IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON r-list IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON r-list-plus IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varartic IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varartic-plus IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varfull-scale-name IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN
       varfull-scale-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varfull-scale-name-plus IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN
       varfull-scale-name-plus:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN vargds-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN vargds-name-plus IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varprod-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varprod-code-plus IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varprod-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varprod-type-plus IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varqnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varqnty-kg IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       varqnty-kg:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varqnty-kg-plus IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       varqnty-kg-plus:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varqnty-plus IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varunit-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varunit-name-plus IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Обработка связок товаров в документе пересортицы */
DO:
  define buffer bf_goods      for ub.goods.
  define buffer bf_goods-plus for ub.goods.
  define buffer bf_gds-prt    for ub.gds-prt.
  define variable varprice-goods      as decimal no-undo.
  define variable varprice-goods-plus as decimal no-undo.
  if parmode <> {&lookup} then do:
    find first bf_goods where bf_goods.artic     = varartic     and
                              bf_goods.prod-type = varprod-type and
                              bf_goods.prod-code = varprod-code no-lock no-error.
    if not available bf_goods then do:
      message "Не найден товар " varartic " " varprod-type " " varprod-code
      view-as alert-box.
      apply "entry" to varartic in frame {&frame-name}.
      return no-apply.
    end.
    find first bf_goods-plus where bf_goods-plus.artic     = varartic-plus     and
                                   bf_goods-plus.prod-type = varprod-type-plus and
                                   bf_goods-plus.prod-code = varprod-code-plus no-lock no-error.
    if not available bf_goods-plus then do:
      message "Не найден товар " varartic-plus " " varprod-type-plus " " varprod-code-plus
      view-as alert-box.
      apply "entry" to varartic-plus in frame {&frame-name}.
      return no-apply.
    end.
    if recid(bf_goods) = recid(bf_goods-plus) then do:
      message "Вы выбрали один и тот же товар для списания и оприходования." view-as alert-box error.
      apply "entry" to varartic-plus in frame {&frame-name}.
      return no-apply.
    end.
    if bf_goods.unit-base <> bf_goods-plus.unit-base
    and parpstunit 
    then do:
      message "У выбранных товаров разные единицы измерения!" skip
              "Пересорт товаров с разными единицами измерения является недопустимым (параметр pstunit)."
      view-as alert-box error.
      return no-apply.
    end.
    if bf_goods.unit-base =  bf_goods-plus.unit-base and
       varqnty            <> varqnty-plus       and
       parpstunqtn-log    <> yes                then do:
      message "У товаров одна и та же единица измерения но разные количества." skip
              "Это недопустимо (параметр pstunqtn)."
       view-as alert-box error.
       apply "entry" to varqnty-plus in frame {&frame-name}.
       return no-apply.
    end.
    if can-find(first ub.units where ub.units.unit-name = bf_goods-plus.unit-base
                                and lookup({&pieces}, ub.units.type) > 0 )  and
       trunc(varqnty-plus, 0) <>   varqnty-plus then do:

      message "У товара " bf_goods-plus.gds-name " штучная единица измерения." skip
              "Количество должно быть целым."
       view-as alert-box error.
       apply "entry" to varqnty-plus in frame {&frame-name}.
       return no-apply.
    end.
    if can-find(first ub.units where ub.units.unit-name = bf_goods.unit-base
                                and lookup({&pieces}, ub.units.type) > 0 )  and
       trunc(varqnty, 0) <>   varqnty then do:

      message "У товара " bf_goods.gds-name " штучная единица измерения." skip
              "Количество должно быть целым."
       view-as alert-box error.
       apply "entry" to varqnty in frame {&frame-name}.
       return no-apply.
    end.

    if parmxpcicp-dec <> ? or
       parmxpcdcp-dec <> ? or
       parmxsmicp-dec <> ? or
       parmxsmdcp-dec <> ? then do:
      { str/get-pr.i calc parobj-type parobj-code bf_goods.gds-code ? "return no-apply." }
      if error-status:error then do:
        message "Ошибка при поиске цены для товара: " bf_goods.artic bf_goods.prod-type bf_goods.prod-code bf_goods.gds-name " ." skip
                return-value
        view-as alert-box error.
        apply "entry" to varartic.
        return no-apply.
      end.
      if gp-price-sale = ? then do:
        message "Есть конфигурационные ограничения на цену товара в пересортице." skip
                "Для товара: " bf_goods.artic bf_goods.prod-type bf_goods.prod-code bf_goods.gds-name " цена не установлена."
        view-as alert-box error.
        apply "entry" to varartic.
        return no-apply.
      end.
      assign
        varprice-goods = gp-price-sale.
      { str/get-pr.i calc parobj-type parobj-code bf_goods-plus.gds-code ? "return no-apply." }
      if error-status:error then do:
        message "Ошибка при поиске цены для товара: " bf_goods-plus.artic bf_goods-plus.prod-type bf_goods-plus.prod-code bf_goods-plus.gds-name " ." skip
                return-value
        view-as alert-box error.
        apply "entry" to varartic-plus.
        return no-apply.
      end.
      if gp-price-sale = ? then do:
        message "Есть конфигурационные ограничения на цену товара в пересортице." skip
                "Для товара: " bf_goods-plus.artic bf_goods-plus.prod-type bf_goods-plus.prod-code bf_goods-plus.gds-name " цена не установлена."
        view-as alert-box error.
        apply "entry" to varartic-plus.
        return no-apply.
      end.
      assign
        varprice-goods-plus = gp-price-sale * varqnty-plus / varqnty.
      if parmxpcicp-dec <> ? then do:
        if (varprice-goods-plus - varprice-goods) / varprice-goods * 100 > parmxpcicp-dec then do:
          message "Максимальное процентное отклонение увеличения цены в документе пересортица: " parmxpcicp-dec skip
                  "Приведенная цена приходуемого товара: " varprice-goods-plus skip
                  "Увеличение цены: " (varprice-goods-plus - varprice-goods) / varprice-goods * 100 "%"
          view-as alert-box error.
          apply "entry" to varqnty-plus in frame {&frame-name}.
          return no-apply.
        end.
      end.
      if parmxpcdcp-dec <> ? then do:
        if (varprice-goods - varprice-goods-plus) / varprice-goods * 100 > parmxpcdcp-dec then do:
          message "Максимальное процентное отклонение уменьшения цены в документе пересортица: "parmxpcdcp-dec skip
                  "Приведенная цена приходуемого товара: " varprice-goods-plus skip
                  "Уменьшение цены: " (varprice-goods - varprice-goods-plus) / varprice-goods * 100 "%"
          view-as alert-box error.
          apply "entry" to varqnty-plus in frame {&frame-name}.
          return no-apply.
        end.
      end.
      if parmxsmicp-dec <> ? then do:
        if varprice-goods-plus - varprice-goods > parmxsmicp-dec then do:
          message "Максимальное абсолютное отклонение увеличения цены в документе пересортица: " parmxsmicp-dec skip
                  "Приведенная цена приходуемого товара: " varprice-goods-plus skip
                  "Увеличение цены: " varprice-goods-plus - varprice-goods
          view-as alert-box error.
          apply "entry" to varqnty-plus in frame {&frame-name}.
          return no-apply.
        end.
      end.
      if parmxsmdcp-dec <> ? then do:
        if varprice-goods - varprice-goods-plus > parmxsmdcp-dec then do:
          message "Максимальное абсолютное отклонение уменьшения цены в документе пересортица: " parmxsmdcp-dec skip
                  "Приведенная цена приходуемого товара: " varprice-goods-plus skip
                  "Уменьшение цены: " varprice-goods - varprice-goods-plus
          view-as alert-box error.
          apply "entry" to varqnty-plus in frame {&frame-name}.
          return no-apply.
        end.
      end.
    end.
    assign
      paroutgds-code      = bf_goods.gds-code
      paroutgds-code-plus = bf_goods-plus.gds-code
      paroutqnty          = varqnty
      paroutqnty-plus     = varqnty-plus
      paroutqnty-kg       = varqnty-kg
      paroutqnty-kg-plus  = varqnty-kg-plus
      parset              = YES
     .
    /*заполняем признаки по товарам без шкалы*/
    find first bf_gds-prt where bf_gds-prt.upper-code = bf_goods.prt-root no-lock.
    if bf_gds-prt.node-name = {&empty-scale} then do:
      for each tt-gds-dtl :
        delete tt-gds-dtl.
      end.
      create tt-gds-dtl.
      assign
        tt-gds-dtl.gds-code = bf_goods.gds-code
        tt-gds-dtl.prt-code = bf_gds-prt.node-code
        tt-gds-dtl.qnty     = (if parmode = {&add-def} then varqnty else vargds-dtl-qnty + (varqnty - varmem-gds-dtl-qnty)).
    end.
    find first bf_gds-prt where bf_gds-prt.upper-code = bf_goods-plus.prt-root no-lock.
    if bf_gds-prt.node-name = {&empty-scale} then do:
      for each tt-gds-dtl-plus :
        delete tt-gds-dtl-plus.
      end.
      create tt-gds-dtl-plus.
      assign
        tt-gds-dtl-plus.gds-code = bf_goods-plus.gds-code
        tt-gds-dtl-plus.prt-code = bf_gds-prt.node-code
        tt-gds-dtl-plus.qnty     = (if parmode = {&add-def} then varqnty-plus else vargds-dtl-qnty-plus + (varqnty-plus - varmem-gds-dtl-qnty-plus)).
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Обработка связок товаров в документе пересортицы */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prt-in
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prt-in Dialog-Frame
ON CHOOSE OF b-prt-in IN FRAME Dialog-Frame /* Шкала оп. */
DO:

  DEFINE BUFFER bf_goods FOR ub.goods.
  define buffer bf-another_goods for ub.goods.
  DEFINE VARIABLE varis-petrol AS LOGICAL NO-UNDO.
  DEFINE VARIABLE varis-pieces AS LOGICAL NO-UNDO.
  DEFINE VARIABLE varstate     AS LOGICAL NO-UNDO.
  FIND FIRST bf_goods WHERE bf_goods.artic     = INPUT FRAME {&FRAME-NAME} varartic-plus     AND
                            bf_goods.prod-type = INPUT FRAME {&FRAME-NAME} varprod-type-plus AND
                            bf_goods.prod-code = INPUT FRAME {&FRAME-NAME} varprod-code-plus NO-LOCK NO-ERROR.
  IF NOT AVAILABLE bf_goods THEN DO:
    MESSAGE "Не найден товар: " INPUT FRAME {&FRAME-NAME} varartic-plus " " INPUT FRAME {&FRAME-NAME} varprod-type-plus " " INPUT FRAME {&FRAME-NAME} varprod-code-plus
    VIEW-AS ALERT-BOX.
    RETURN NO-APPLY.
  END.
  if parmode <> {&add-def} then do:
    FIND FIRST bf-another_goods WHERE bf-another_goods.artic     = INPUT FRAME {&FRAME-NAME} varartic     AND
                                      bf-another_goods.prod-type = INPUT FRAME {&FRAME-NAME} varprod-type AND
                                      bf-another_goods.prod-code = INPUT FRAME {&FRAME-NAME} varprod-code no-lock.

  end.
  { str/is-petrl.i
    bf_goods.artic
    bf_goods.prod-type
    bf_goods.prod-code
    varis-petrol
    varis-pieces
  }
  IF varis-petrol     AND
     NOT varis-pieces THEN DO:
    run str/prstptrl.w (BUFFER bf_goods,
                    (if parmode = {&add-def} then ? else bf-another_goods.gds-code),
                    INPUT  pardoc-code,
                    INPUT  parobj-type,
                    INPUT  parobj-code,
                    INPUT  NO,
                    INPUT  parmode,
                    OUTPUT varstate)   no-error.
  END.
  ELSE DO:
    for each tt-gds-prt :
      delete tt-gds-prt.
    end.
    run str/prt-prst.w (buffer bf_goods,
                    input  pardoc-code,
                    input  parobj-type,
                    input  parobj-code,
                    input  no,
                    INPUT  parmode,
                    output varstate) no-error.
    if not(error-status:error or varstate <> yes) then do:
      for each tt-gds-dtl-plus :
        delete tt-gds-dtl-plus.
      end.
      assign
        varqnty-plus = 0.00.
      for each tt-gds-prt where tt-gds-prt.income-qnty > 0 :
        create tt-gds-dtl-plus.
        assign
          tt-gds-dtl-plus.gds-code = bf_goods.gds-code
          tt-gds-dtl-plus.prt-code = tt-gds-prt.prt-code
          tt-gds-dtl-plus.qnty     = tt-gds-prt.income-qnty.
        assign
          varqnty-plus = varqnty-plus + tt-gds-dtl-plus.qnty.
        display varqnty-plus with frame {&frame-name}.
      end.
    end.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prt-wr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prt-wr Dialog-Frame
ON CHOOSE OF b-prt-wr IN FRAME Dialog-Frame /* Шкала сп. */
DO:
  DEFINE BUFFER bf_goods FOR ub.goods.
  define buffer bf-another_goods for ub.goods.
  DEFINE VARIABLE varis-petrol AS LOGICAL NO-UNDO.
  DEFINE VARIABLE varis-pieces AS LOGICAL NO-UNDO.
  DEFINE VARIABLE varstate     AS LOGICAL NO-UNDO.
  FIND FIRST bf_goods WHERE bf_goods.artic     = INPUT FRAME {&FRAME-NAME} varartic     AND
                            bf_goods.prod-type = INPUT FRAME {&FRAME-NAME} varprod-type AND
                            bf_goods.prod-code = INPUT FRAME {&FRAME-NAME} varprod-code NO-LOCK NO-ERROR.
  IF NOT AVAILABLE bf_goods THEN DO:
    MESSAGE "Не найден товар: " INPUT FRAME {&FRAME-NAME} varartic " " INPUT FRAME {&FRAME-NAME} varprod-type " " INPUT FRAME {&FRAME-NAME} varprod-code
    VIEW-AS ALERT-BOX.
    RETURN NO-APPLY.
  END.
  if parmode <> {&add-def} then do:
    FIND FIRST bf-another_goods WHERE bf-another_goods.artic     = INPUT FRAME {&FRAME-NAME} varartic-plus     AND
                                      bf-another_goods.prod-type = INPUT FRAME {&FRAME-NAME} varprod-type-plus AND
                                      bf-another_goods.prod-code = INPUT FRAME {&FRAME-NAME} varprod-code-plus no-lock.

  end.
  { str/is-petrl.i
    bf_goods.artic
    bf_goods.prod-type
    bf_goods.prod-code
    varis-petrol
    varis-pieces
  }
  IF varis-petrol     AND
     NOT varis-pieces THEN DO:
    run str/prstptrl.w (BUFFER bf_goods,
                    input  (if parmode = {&add-def} then ? else bf-another_goods.gds-code),
                    INPUT  pardoc-code,
                    INPUT  parobj-type,
                    INPUT  parobj-code,
                    INPUT  yes,
                    INPUT  parmode,
                    OUTPUT varstate)   no-error.
  END.
  ELSE DO:
    for each tt-gds-prt :
      delete tt-gds-prt.
    end.
    run str/prt-prst.w (buffer bf_goods,
                    input  pardoc-code,
                    input  parobj-type,
                    input  parobj-code,
                    input  yes,
                    INPUT  parmode,
                    output varstate) no-error.
    if error-status:error or varstate <> yes then do:
    end.
    else do:
      for each tt-gds-dtl :
        delete tt-gds-dtl.
      end.
      assign
        varqnty = 0.00.
      for each tt-gds-prt where tt-gds-prt.write-off-qnty > 0 :
        create tt-gds-dtl.
        assign
          tt-gds-dtl.gds-code = bf_goods.gds-code
          tt-gds-dtl.prt-code = tt-gds-prt.prt-code
          tt-gds-dtl.qnty     = tt-gds-prt.write-off-qnty.
        assign
          varqnty = varqnty + tt-gds-dtl.qnty.
        display varqnty with frame {&frame-name}.
      end.
    end.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* Сохранить */
DO:
  { gbl/stdbtn.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-goods Dialog-Frame
ON CHOOSE OF r-goods IN FRAME Dialog-Frame
DO:
  RUN run-ref IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-goods-plus
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-goods-plus Dialog-Frame
ON CHOOSE OF r-goods-plus IN FRAME Dialog-Frame
DO:
  RUN run-ref-plus IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-list Dialog-Frame
ON CHOOSE OF r-list IN FRAME Dialog-Frame
DO:
  RUN ref-list IN THIS-PROCEDURE no-error.
  IF ERROR-STATUS:ERROR THEN DO:
    RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-list-plus
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-list-plus Dialog-Frame
ON CHOOSE OF r-list-plus IN FRAME Dialog-Frame
DO:
  RUN ref-list-plus IN THIS-PROCEDURE no-error.
  IF ERROR-STATUS:ERROR THEN DO:
    RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varartic
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varartic Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF varartic IN FRAME Dialog-Frame /* Артикул */
DO:
if keyfunction(lastkey) <> "end-error" and
     not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) and
     not (last-event:event-type = "progress":u and last-event:widget-enter = r-goods:handle)  and
     not (last-event:event-type = "progress":u and last-event:widget-enter = r-list:handle)
     then do:
  RUN set-goods IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref in this-procedure.
  end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varartic Dialog-Frame
ON return OF varartic IN FRAME Dialog-Frame /* Артикул */
DO:
if keyfunction(lastkey) <> "end-error" and
     not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) and
     not (last-event:event-type = "progress":u and last-event:widget-enter = r-goods:handle)  and
     not (last-event:event-type = "progress":u and last-event:widget-enter = r-list:handle)   then do:
  RUN set-goods IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref in this-procedure.
  end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varartic-plus
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varartic-plus Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF varartic-plus IN FRAME Dialog-Frame /* Артикул */
DO:
if keyfunction(lastkey) <> "end-error" and
  not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle)     and
  not (last-event:event-type = "progress":u and last-event:widget-enter = r-goods-plus:handle) and
  not (last-event:event-type = "progress":u and last-event:widget-enter = r-list-plus:handle)
then do:
  RUN set-goods-plus IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref-plus in this-procedure.
  end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varartic-plus Dialog-Frame
ON return OF varartic-plus IN FRAME Dialog-Frame /* Артикул */
DO:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle)     and
   not (last-event:event-type = "progress":u and last-event:widget-enter = r-goods-plus:handle) and
   not (last-event:event-type = "progress":u and last-event:widget-enter = r-list-plus:handle)
then do:
  RUN set-goods-plus IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref-plus in this-procedure.
  end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varprod-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprod-code Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF varprod-code IN FRAME Dialog-Frame /* Производитель */
DO:
if keyfunction(lastkey) <> "end-error" and
  not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) and
  not (last-event:event-type = "progress":u and last-event:widget-enter = r-goods:handle)  and
  not (last-event:event-type = "progress":u and last-event:widget-enter = r-list:handle)
then do:
  RUN set-goods IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref in this-procedure.
  end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprod-code Dialog-Frame
ON return OF varprod-code IN FRAME Dialog-Frame /* Производитель */
DO:
if keyfunction(lastkey) <> "end-error" and
  not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) and
  not (last-event:event-type = "progress":u and last-event:widget-enter = r-goods:handle)  and
  not (last-event:event-type = "progress":u and last-event:widget-enter = r-list:handle)
then do:
  RUN set-goods IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref in this-procedure.
  end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varprod-code-plus
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprod-code-plus Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF varprod-code-plus IN FRAME Dialog-Frame /* Производитель */
DO:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) then do:
  RUN set-goods-plus IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref-plus in this-procedure.
  end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprod-code-plus Dialog-Frame
ON return OF varprod-code-plus IN FRAME Dialog-Frame /* Производитель */
DO:
if keyfunction(lastkey) <> "end-error" and
  not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) then do:
  RUN set-goods-plus IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref-plus in this-procedure.
  end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varprod-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprod-type Dialog-Frame
ON LEAVE OF varprod-type IN FRAME Dialog-Frame
DO:
if keyfunction(lastkey) <> "end-error" and
  not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) then do:
  RUN set-goods IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref in this-procedure.
  end.
  RETURN NO-APPLY.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprod-type Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF varprod-type IN FRAME Dialog-Frame
DO:
if keyfunction(lastkey) <> "end-error" and
     not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) then do:
  RUN set-goods IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref in this-procedure.
  end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprod-type Dialog-Frame
ON return OF varprod-type IN FRAME Dialog-Frame
DO:
if keyfunction(lastkey) <> "end-error" and
  not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) then do:
  RUN set-goods IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref in this-procedure.
  end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varprod-type-plus
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprod-type-plus Dialog-Frame
ON LEAVE OF varprod-type-plus IN FRAME Dialog-Frame
DO:
if keyfunction(lastkey) <> "end-error" and
  not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) then do:
  RUN set-goods-plus IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref-plus in this-procedure.
  end.
  RETURN NO-APPLY.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprod-type-plus Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF varprod-type-plus IN FRAME Dialog-Frame
DO:
if keyfunction(lastkey) <> "end-error" and
  not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) then do:
  RUN set-goods-plus IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref-plus in this-procedure.
  end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprod-type-plus Dialog-Frame
ON return OF varprod-type-plus IN FRAME Dialog-Frame
DO:
if keyfunction(lastkey) <> "end-error" and
     not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) then do:
  RUN set-goods-plus IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref-plus in this-procedure.
  end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varqnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varqnty Dialog-Frame
ON LEAVE OF varqnty IN FRAME Dialog-Frame /* Списываемое количество */
DO:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) then do:
  run set-qnty in this-procedure no-error.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varqnty Dialog-Frame
ON return OF varqnty IN FRAME Dialog-Frame /* Списываемое количество */
DO:
if keyfunction(lastkey) <> "end-error" and
  not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) then do:
  run set-qnty in this-procedure no-error.
  apply "entry" to varartic-plus in frame {&frame-name}.
  return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varqnty-plus
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varqnty-plus Dialog-Frame
ON LEAVE OF varqnty-plus IN FRAME Dialog-Frame /* Приходуемое количество */
DO:
if keyfunction(lastkey) <> "end-error" and
  not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) then do:
  run set-qnty-plus in this-procedure no-error.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varqnty-plus Dialog-Frame
ON return OF varqnty-plus IN FRAME Dialog-Frame /* Приходуемое количество */
DO:
if keyfunction(lastkey) <> "end-error" and
  not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) then do:
  run set-qnty-plus in this-procedure no-error.
  apply "entry" to b-save in frame {&frame-name}.
  return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
{ gbl/app_help.i }
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 frame {&frame-name} :title = frame {&frame-name} :title + " " + pardoc-code.
  RUN enable_UI in this-procedure.
  run mode-on   in this-procedure.
  run ui-on     in this-procedure.
  find first bf_clients-host where bf_clients-host.obj-type = parobj-type and
                                   bf_clients-host.obj-code = parobj-code no-lock.
  wait-for go of frame {&frame-name}.
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
  DISPLAY varqnty-kg varartic vargds-name varprod-code varprod-type varqnty
          varunit-name varartic-plus vargds-name-plus varprod-code-plus
          varprod-type-plus varqnty-plus varunit-name-plus varqnty-kg-plus
      WITH FRAME Dialog-Frame.
  ENABLE b-cancel b-help RECT-1 RECT-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mode-on Dialog-Frame
PROCEDURE mode-on :
DEFINE BUFFER bf_goods        FOR ub.goods.
DEFINE BUFFER bf_goods-plus   FOR ub.goods.
DEFINE BUFFER bf_gds-prt      FOR ub.gds-prt.
DEFINE BUFFER bf_gds-prt-plus FOR ub.gds-prt.
define buffer bf-w_gds-dtl for ub.gds-dtl.
define buffer bf-i_gds-dtl for ub.gds-dtl.
DEFINE VARIABLE varis-petrol      AS LOGICAL NO-UNDO.
DEFINE VARIABLE varis-pieces      AS LOGICAL NO-UNDO.
DEFINE VARIABLE varis-petrol-plus AS LOGICAL NO-UNDO.
DEFINE VARIABLE varis-pieces-plus AS LOGICAL NO-UNDO.
do on error undo, return error RETURN-VALUE :
if parmode = {&UPDATE} or
   parmode = {&lookup} then do:
  FIND FIRST bf_goods WHERE bf_goods.gds-code = pargds-code NO-LOCK NO-ERROR.
  IF NOT AVAILABLE bf_goods THEN DO:
    MESSAGE "Не найден товар с внутренним кодом: " pargds-code " ." VIEW-AS ALERT-BOX ERROR.
    RETURN ERROR.
  END.
  FIND FIRST bf_gds-prt WHERE bf_gds-prt.upper-code = bf_goods.prt-root no-lock.
  FIND FIRST bf_goods-plus WHERE bf_goods-plus.gds-code = pargds-code-plus NO-LOCK NO-ERROR.
  IF NOT AVAILABLE bf_goods-plus THEN DO:
    MESSAGE "Не найден товар с внутренним кодом: " pargds-code-plus " ." VIEW-AS ALERT-BOX ERROR.
    RETURN ERROR.
  END.

  FIND FIRST bf_gds-prt-plus WHERE bf_gds-prt-plus.upper-code = bf_goods-plus.prt-root no-lock.
  ASSIGN
    varartic                = bf_goods.artic
    varprod-type            = bf_goods.prod-type
    varprod-code            = bf_goods.prod-code
    vargds-name             = bf_goods.gds-name

    varfull-scale-name      = (IF bf_gds-prt.node-name = {&empty-scale} THEN "":u ELSE bf_gds-prt.f-name)
    varartic-plus           = bf_goods-plus.artic
    varprod-type-plus       = bf_goods-plus.prod-type
    varprod-code-plus       = bf_goods-plus.prod-code
    vargds-name-plus        = bf_goods-plus.gds-name
    varfull-scale-name-plus = (IF bf_gds-prt-plus.node-name = {&empty-scale} THEN "":u ELSE bf_gds-prt-plus.f-name)
  .
  DISPLAY varartic      varprod-type      varprod-code      vargds-name
          varartic-plus varprod-type-plus varprod-code-plus vargds-name-plus WITH FRAME {&FRAME-NAME}.
  assign
    varqnty                  = parqnty
    varmem-gds-dtl-qnty      = parqnty
    varqnty-kg               = parqnty-kg
    varqnty-plus             = parqnty-plus
    varmem-gds-dtl-qnty-plus = parqnty-plus
    varqnty-kg-plus          = parqnty-kg-plus.

  { str/is-petrl.i
    varartic
    varprod-type
    varprod-code
    varis-petrol
    varis-pieces
  }
  { str/is-petrl.i
    varartic-plus
    varprod-type-plus
    varprod-code-plus
    varis-petrol-plus
    varis-pieces-plus
  }
  if parmode = {&update} or
     parmode = {&lookup} then do:
    display varqnty varqnty-plus with frame {&frame-name}.
    if varis-petrol     and
       not varis-pieces then do:
      display varqnty-kg with frame {&frame-name}.
    end.
    if varis-petrol-plus     and
       not varis-pieces-plus then do:
      display varqnty-kg-plus with frame {&frame-name}.
    end.

  end.
  if parmode = {&update} then do:
    for each bf-w_gds-dtl where bf-w_gds-dtl.doc-code  = pardoc-code            and
                                bf-w_gds-dtl.artic     = bf_goods.artic     and
                                bf-w_gds-dtl.prod-type = bf_goods.prod-type and
                                bf-w_gds-dtl.prod-code = bf_goods.prod-code on error undo, return error return-value :
      create tt-gds-dtl.
      assign
        tt-gds-dtl.gds-code =   bf_goods.gds-code
        tt-gds-dtl.prt-code =   bf-w_gds-dtl.prt-code
        tt-gds-dtl.qnty     = - bf-w_gds-dtl.doc-qnty.
      IF bf_gds-prt.node-name = {&empty-scale} THEN DO:
        assign
          vargds-dtl-qnty = - bf-w_gds-dtl.doc-qnty.
      end.
    end.
    for each bf-i_gds-dtl where bf-i_gds-dtl.doc-code  = pardoc-code             and
                                bf-i_gds-dtl.artic     = bf_goods-plus.artic     and
                                bf-i_gds-dtl.prod-type = bf_goods-plus.prod-type and
                                bf-i_gds-dtl.prod-code = bf_goods-plus.prod-code on error undo, return error return-value :
      create tt-gds-dtl-plus.
      assign
        tt-gds-dtl-plus.gds-code = bf_goods-plus.gds-code
        tt-gds-dtl-plus.prt-code = bf-i_gds-dtl.prt-code
        tt-gds-dtl-plus.qnty     = bf-i_gds-dtl.doc-qnty.
      IF bf_gds-prt-plus.node-name = {&empty-scale} THEN DO:
        assign
          vargds-dtl-qnty-plus = bf-i_gds-dtl.doc-qnty.
      end.
    end.
  end.
  IF bf_gds-prt.node-name <> {&empty-scale} THEN DO:
   DISPLAY varfull-scale-name WITH FRAME {&FRAME-NAME}.
   ASSIGN b-prt-wr:LABEL = "Шкала сп.".
   if parmode = {&update} or parmode = {&lookup} then do:
     ENABLE b-prt-wr WITH FRAME {&FRAME-NAME}.
   end.
  END.
  ELSE DO:
    IF varis-petrol AND
       NOT varis-pieces THEN DO:
      ASSIGN b-prt-wr:LABEL = "Рез-р сп.".
      if parmode = {&update} or parmode = {&lookup} then do:
        ENABLE b-prt-wr WITH FRAME {&FRAME-NAME}.
      end.
    END.
    ELSE DO:
      HIDE b-prt-wr IN FRAME {&FRAME-NAME}.
      if parmode = {&update} then do:
        enable varqnty with frame {&frame-name}.
      end.
    END.
  END.
  IF bf_gds-prt-plus.node-name <> {&empty-scale} THEN DO:
    DISPLAY varfull-scale-name-plus WITH FRAME {&FRAME-NAME}.
    ASSIGN b-prt-in:LABEL = "Шкала оп.".
    if parmode = {&update} or parmode = {&lookup} then do:
      ENABLE b-prt-in WITH FRAME {&FRAME-NAME}.
    end.
  END.
  ELSE DO:
    IF varis-petrol-plus     AND
       NOT varis-pieces-plus THEN DO:
      ASSIGN b-prt-in:LABEL = "Рез-р оп.".
      if parmode = {&update} or parmode = {&lookup} then do:
        ENABLE b-prt-in WITH FRAME {&FRAME-NAME}.
      end.
    END.
    ELSE DO:
      HIDE b-prt-in IN FRAME {&FRAME-NAME}.
      if parmode = {&update} then do:
        enable varqnty-plus with frame {&frame-name}.
      end.
    END.
  END.
  if not(is-petrol and not is-pieces) then do:
      HIDE varqnty-kg IN FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
      VIEW varqnty-kg IN FRAME {&FRAME-NAME}.
  END.
  if not(is-petrol-plus and not is-pieces-plus) then do:
    HIDE varqnty-kg-plus IN FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
    VIEW varqnty-kg-plus IN FRAME {&FRAME-NAME}.
  END.
end.
IF parmode = {&add-def} THEN DO:
  HIDE b-prt-wr b-prt-in varqnty-kg varqnty-kg-plus IN FRAME {&FRAME-NAME}.
END.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ref-list Dialog-Frame
PROCEDURE ref-list :
DEFINE BUFFER bf_goods FOR ub.goods.
DEFINE BUFFER bf_units FOR ub.units.
run str/gds-list.w (input parparentproc, input bf_clients-host.host-code, input parobj-type, input parobj-code).
FIND FIRST gds-list NO-ERROR.
IF AVAILABLE gds-list THEN DO:
  FIND FIRST bf_goods WHERE bf_goods.artic     = gds-list.artic     AND
                            bf_goods.prod-type = gds-list.prod-type AND
                            bf_goods.prod-code = gds-list.prod-code NO-LOCK.
  ASSIGN
    varartic     = bf_goods.artic
    varprod-type = bf_goods.prod-type
    varprod-code = bf_goods.prod-code
    varunit-name = bf_goods.unit-base.
  DISPLAY varartic varprod-type varprod-code varunit-name WITH FRAME {&FRAME-NAME}.
  RUN set-goods IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    RETURN ERROR.
  END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ref-list-plus Dialog-Frame
PROCEDURE ref-list-plus :
DEFINE BUFFER bf_goods FOR ub.goods.
run str/gds-list.w (input parparentproc, input bf_clients-host.host-code, input parobj-type, input parobj-code).
FIND FIRST gds-list NO-ERROR.
IF AVAILABLE gds-list THEN DO:
  FIND FIRST bf_goods WHERE bf_goods.artic     = gds-list.artic     AND
                            bf_goods.prod-type = gds-list.prod-type AND
                            bf_goods.prod-code =
 gds-list.prod-code NO-LOCK.
  ASSIGN
    varartic-plus     = bf_goods.artic
    varprod-type-plus = bf_goods.prod-type
    varprod-code-plus = bf_goods.prod-code
    varunit-name      = bf_goods.unit-base.
  DISPLAY varartic-plus varprod-type-plus varprod-code-plus varunit-name WITH FRAME {&FRAME-NAME}.
  RUN set-goods-plus IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    RETURN ERROR.
  END.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE run-ref Dialog-Frame
PROCEDURE run-ref :
define variable v-stat as character no-undo init ?.
define variable v-list as character no-undo init ?.
define variable v-prod-type like ub.clients.obj-type no-undo .
define variable v-prod-code like ub.clients.obj-code no-undo .
define variable ref-list     as character no-undo init "" .
define variable new-ref-list as character no-undo init "" .
DEFINE VARIABLE v-erase AS LOGICAL NO-UNDO.
DEFINE BUFFER bf_clients FOR ub.clients.
DEFINE BUFFER bf_goods   FOR ub.goods.
find FIRST bf_clients where bf_clients.obj-type = input frame {&frame-name} varprod-type
                        and bf_clients.obj-code = input frame {&frame-name} varprod-code NO-LOCK NO-ERROR.
IF AVAILABLE bf_clients then do:
  /* товар не найден, но производитель задан правильно - вызываем справочник по производителю */
  ASSIGN
    v-list = "производитель".
end.
ELSE DO:
  ASSIGN
    v-list = {&all}.
END.
ASSIGN
  v-stat = {&current}.
run ref/gds-ref.p
  ( parparentproc
  , "b-sel,b-add"
  , v-stat
  , v-list
  , ?
  , ?
  , ?
  , (if available bf_clients then bf_clients.obj-type else ?)
  , (if available bf_clients then bf_clients.obj-code else ?)
  , parobj-type
  , parobj-code
  , ?
  , output ref-list)
  NO-ERROR.
IF ref-list <> "":u THEN DO:
  find first bf_goods where recid (bf_goods) = integer (entry(1, ref-list)) no-lock  .
  run ver-gds in this-procedure (bf_goods.gds-code, output v-erase) no-error  .
  if error-status:error
  then do:
     message return-value VIEW-AS ALERT-BOX.
     return  error.
  end.
  if v-erase = TRUE then do:
    MESSAGE "Вы выбрали нетоварную позицию." VIEW-AS ALERT-BOX.
    RETURN ERROR.
  end.
  IF bf_goods.gds-type = {&gds-office} THEN DO:
    MESSAGE "Вы выбрали услугу." VIEW-AS ALERT-BOX.
    RETURN ERROR.
  END.

  ASSIGN
    varartic     = bf_goods.artic
    varprod-type = bf_goods.prod-type
    varprod-code = bf_goods.prod-code
    VARunit-name = bf_goods.unit-base.
  DISPLAY varartic varprod-type varprod-code varunit-name WITH FRAME {&FRAME-NAME}.
  RUN set-goods IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    RETURN ERROR.
  END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE run-ref-plus Dialog-Frame
PROCEDURE run-ref-plus :
define variable v-stat as character no-undo init ?.
define variable v-list as character no-undo init ?.
define variable v-prod-type like ub.clients.obj-type no-undo .
define variable v-prod-code like ub.clients.obj-code no-undo .
define variable ref-list     as character no-undo init "" .
define variable new-ref-list as character no-undo init "" .
DEFINE VARIABLE v-erase AS LOGICAL NO-UNDO.
DEFINE BUFFER bf_clients FOR ub.clients.
DEFINE BUFFER bf_goods   FOR ub.goods.
find FIRST bf_clients where bf_clients.obj-type = input frame {&frame-name} varprod-type-plus
                        and bf_clients.obj-code = input frame {&frame-name} varprod-code-plus NO-LOCK NO-ERROR.
IF AVAILABLE bf_clients then do:
  /* товар не найден, но производитель задан правильно - вызываем справочник по производителю */
  ASSIGN
    v-list = "производитель".
end.
ELSE DO:
  ASSIGN
    v-list = {&all}.
END.
ASSIGN
  v-stat = {&current}.
run ref/gds-ref.p
  ( parparentproc
  , "b-sel,b-add"
  , v-stat
  , v-list
  , ?
  , ?
  , ?
  , (if available bf_clients then bf_clients.obj-type else ?)
  , (if available bf_clients then bf_clients.obj-code else ?)
  , parobj-type
  , parobj-code
  , ?
  , output ref-list)
  NO-ERROR.
IF ref-list <> "":u THEN DO:
  find first bf_goods where recid (bf_goods) = integer (entry(1, ref-list)) no-lock  .
  run ver-gds (bf_goods.gds-code, output v-erase) no-error  .
  if error-status:error
  then do:
     message return-value VIEW-AS ALERT-BOX.
     return  error.
  end.
  if v-erase = TRUE  then do:
    MESSAGE "Вы выбрали нетоварную позицию." VIEW-AS ALERT-BOX.
    RETURN ERROR.
  end.
  IF bf_goods.gds-type = {&gds-office} THEN DO:
    MESSAGE "Вы выбрали услугу." VIEW-AS ALERT-BOX.
    RETURN ERROR.
  END.
  ASSIGN
    varartic-plus     = bf_goods.artic
    varprod-type-plus = bf_goods.prod-type
    varprod-code-plus = bf_goods.prod-code
    varunit-name-plus = bf_goods.unit-base.
  DISPLAY varartic-plus varprod-type-plus varprod-code-plus varunit-name-plus WITH FRAME {&FRAME-NAME}.
  RUN set-goods-plus IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    RETURN ERROR.
  END.
END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-goods Dialog-Frame
PROCEDURE set-goods :
define buffer bf-chk_goods     for ub.goods.
define buffer bf-chk-two_goods for ub.goods.
define buffer bf_gds-prt       for ub.gds-prt.
define buffer bf_clients       for ub.clients.
define variable varnabor as logical no-undo.
define variable varstate as logical no-undo.
if input frame {&frame-name} varartic = '' then return error.
find first bf-chk_goods where bf-chk_goods.artic  = input frame {&frame-name} varartic no-lock no-error.
if not available bf-chk_goods then do:
  message "Неправильный Артикул - такого товара нет.".
  apply "entry" to varartic in frame {&frame-name}.
  return.
end.
else do:
  find first bf-chk-two_goods where bf-chk-two_goods.artic    = input frame {&frame-name} varartic
                                and recid (bf-chk-two_goods) <> recid (bf-chk_goods)
                                and bf-chk-two_goods.stts     = 0 no-lock no-error.
  if input frame {&frame-name} varprod-code <> 0 then do:
    find first bf-chk_goods where bf-chk_goods.prod-code  = input frame {&frame-name} varprod-code
                              and bf-chk_goods.artic      = input frame {&frame-name} varartic no-lock no-error.
    if not available bf-chk_goods then do:
      message "Неправильный Код производителя - такого товара нет.".
      apply "entry" to varprod-code in frame {&frame-name}.
      return. /* без error - не будет вызова справочника */
    end.
    find first bf-chk-two_goods where bf-chk-two_goods.artic     = input frame {&frame-name} varartic
                                  and bf-chk-two_goods.prod-code = input frame {&frame-name} varprod-code
                                  and recid (bf-chk-two_goods)  <> recid (bf-chk_goods)
                                  and bf-chk-two_goods.stts      = 0 no-lock no-error.
  end.
  else do:
    if available bf-chk-two_goods then do:
      message "С артикулом :" input frame {&frame-name} varartic
              "несколько товаров." skip (2)
               "Укажите Производителя или выберите товар из справочника.".
      apply "entry" to varprod-code in frame {&frame-name}.
      return.        /* без error - не будет вызова справочника */
    end.
  end.
  if input frame {&frame-name} varprod-code <> 0  and
     input frame {&frame-name} varprod-type <> "" then do:
     find bf-chk_goods where bf-chk_goods.prod-type = input frame {&frame-name} varprod-type and
                             bf-chk_goods.prod-code = input frame {&frame-name} varprod-code and
                             bf-chk_goods.artic     = input frame {&frame-name} varartic no-lock no-error.
     if not available bf-chk_goods then do:
      message "Неправильный Тип производителя - такого товара нет.".
      apply "entry" to varprod-type in frame {&frame-name}.
      return.        /* без error - не будет вызова справочника */
     end.
  end.
  else do:
    if available bf-chk-two_goods then do:
        message "С артикулом :" input frame {&frame-name} varartic
                        "несколько товаров." skip (2)
                        "Укажите Производителя или выберите товар из справочника.".
        apply "entry" to varprod-type in frame {&frame-name}.
        return.        /* без error - не будет вызова справочника */
    end.
  end.

  run ver-gds in this-procedure (bf-chk_goods.gds-code, output varnabor) no-error .
  if error-status:error
  then do:
     message return-value VIEW-AS ALERT-BOX.
     return  error.
  end.
  if varnabor = true then do:
    message "Это не товарная позиция - имеет атрибут НАБОР !!!".
    apply "entry" to varartic in frame {&frame-name}.
    return.
  end.
  { str/is-petrl.i
    bf-chk_goods.artic
    bf-chk_goods.prod-type
    bf-chk_goods.prod-code
    is-petrol
    is-pieces
    no-error
  }
  find first bf_units where bf_units.unit-name = bf-chk_goods.unit-base no-lock.
  if lookup({&twounit}, bf_units.type) <> 0 then do:
    message substitute ("В документе пересортица недопускается товар с двумя единицами измерения. Товар: &1 &2 &3", bf-chk_goods.artic, bf-chk_goods.prod-type, bf-chk_goods.prod-code) view-as alert-box error.
    apply "entry" to varartic in frame {&frame-name}.
    assign
      varartic     = ""
      varprod-type = ""
      varprod-code = 0.
    display varartic varprod-type varprod-code with frame {&frame-name}.
    return error.
  end.
  if lookup( bf-chk_goods.gds-type, {&gds-office} ) > 0 then do:
    message "В документе пересортица недопустимы услуги." view-as alert-box error.
    apply "entry" to varartic in frame {&frame-name}.
    assign
      varartic     = ""
      varprod-type = ""
      varprod-code = 0.
    display varartic varprod-type varprod-code with frame {&frame-name}.
    return error.
  end.
  find first bf_gds-prt where bf_gds-prt.upper-code = bf-chk_goods.prt-root no-lock no-error.
  find first bf_clients where bf_clients.obj-type = bf-chk_goods.prod-type and
                              bf_clients.obj-code = bf-chk_goods.prod-code no-lock.
  assign
    varartic           = bf-chk_goods.artic
    varprod-type       = bf-chk_goods.prod-type
    varprod-code       = bf-chk_goods.prod-code
    vargds-name        = bf-chk_goods.gds-name
    varunit-name       = bf-chk_goods.unit-base
    varfull-scale-name = (if bf_gds-prt.node-name = {&empty-scale} then "":u else bf_gds-prt.f-name)
  .
  display varartic varprod-type varprod-code vargds-name varunit-name with frame {&frame-name}.
  if varfull-scale-name <> "":u then do:
    display varfull-scale-name with frame {&frame-name}.
  end.
  else do:
    hide varfull-scale-name in frame {&frame-name}.
  end.
  if not(is-petrol and not is-pieces) then do:
    HIDE varqnty-kg IN FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
    VIEW varqnty-kg IN FRAME {&FRAME-NAME}.
  END.

  if bf_gds-prt.node-name = {&empty-scale} then do:
    if is-petrol and not is-pieces then do:
      for each tt-pl-qty :
        delete tt-pl-qty.
      end.
      assign
        varqnty    = 0.00
        varqnty-kg = 0.00.
      run str/prstptrl.w (BUFFER bf-chk_goods,
                      input  ?,
                      INPUT  pardoc-code,
                      INPUT  parobj-type,
                      INPUT  parobj-code,
                      INPUT  yes,
                      INPUT  {&add-def},
                      OUTPUT varstate)   no-error.
      if error-status:error or varstate <> yes then do:
        assign
          varartic             = "":u
          varprod-type         = "":u
          varprod-code         = ?
          vargds-name          = "":u
          varunit-name         = "":u
          varfull-scale-name   = "":u
        .
        display varartic varprod-type varprod-code vargds-name varunit-name with frame {&frame-name}.
        if varfull-scale-name:visible in frame {&frame-name} then do:
          display varfull-scale-name with frame {&frame-name}.
        end.
        apply "entry" to varartic in frame {&frame-name}.
        return error.
      end.
      else do:
        for each tt-place :
          if tt-place.write-off-doc-l <> 0 then do:
            create tt-pl-qty.
            assign
              tt-pl-qty.pl-code = tt-place.pl-code
              tt-pl-qty.qnty-l  = tt-place.write-off-l
              tt-pl-qty.qnty-kg = tt-place.write-off-kg
            .
            assign
              varqnty    = varqnty    + tt-pl-qty.qnty-l
              varqnty-kg = varqnty-kg + tt-pl-qty.qnty-kg.
          end.
        end.
        display varqnty varqnty-kg with frame {&frame-name}.
      end.
      /*
      ASSIGN b-prt-wr:LABEL = "Рез-р сп.".
      ENABLE b-prt-wr WITH FRAME {&FRAME-NAME}.
      */
    end.
    else do:
      HIDE b-prt-wr IN FRAME {&FRAME-NAME}.
      enable varqnty with frame {&frame-name}.
      assign
        parmode = "first-goods":u.
      run ui-on in this-procedure.
    end.
  end.
  else do:
   /*
   ASSIGN b-prt-wr:LABEL = "Шкала сп.".
   ENABLE b-prt-wr WITH FRAME {&FRAME-NAME}.
   */
    hide varqnty in frame {&frame-name}.
    for each tt-gds-prt on error undo, return error return-value :
      delete tt-gds-prt.
    end.
    run str/prt-prst.w (buffer bf-chk_goods,
                    input  pardoc-code,
                    input  parobj-type,
                    input  parobj-code,
                    input  yes,
                    INPUT  parmode,
                    output varstate) no-error.
    if error-status:error or varstate <> yes then do:
      assign
        varartic             = "":u
        varprod-type         = "":u
        varprod-code         = ?
        vargds-name          = "":u
        varunit-name         = "":u
        varfull-scale-name   = "":u
      .
      display varartic varprod-type varprod-code vargds-name varunit-name with frame {&frame-name}.
      if varfull-scale-name:visible in frame {&frame-name} then do:
        display varfull-scale-name with frame {&frame-name}.
      end.
      apply "entry" to varartic in frame {&frame-name}.
      return error.
    end.
    else do:
      for each tt-gds-dtl on error undo, return error return-value :
        delete tt-gds-dtl.
      end.
      assign
        varqnty = 0.00.
      for each tt-gds-prt where tt-gds-prt.write-off-qnty > 0 on error undo, return error return-value :
        create tt-gds-dtl.
        assign
          tt-gds-dtl.gds-code = bf-chk_goods.gds-code
          tt-gds-dtl.prt-code = tt-gds-prt.prt-code
          tt-gds-dtl.qnty     = tt-gds-prt.write-off-qnty.
        assign
          varqnty = varqnty + tt-gds-dtl.qnty.
        display varqnty with frame {&frame-name}.
      end.
      apply "entry" to varartic-plus in frame {&frame-name}.
    end.
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-goods-plus Dialog-Frame
PROCEDURE set-goods-plus :
define buffer bf-chk_goods     for ub.goods.
define buffer bf-chk-two_goods for ub.goods.
define buffer bf_gds-prt       for ub.gds-prt.
define buffer bf_clients       for ub.clients.
define variable varnabor  as logical no-undo.
define variable varstate  as logical no-undo.
if input frame {&frame-name} varartic-plus = '' then do:
  return error.
end.
find first bf-chk_goods where bf-chk_goods.artic  = input frame {&frame-name} varartic-plus no-lock no-error.
if not available bf-chk_goods then do:
  message "Неправильный Артикул - такого товара нет.".
  apply "entry" to varartic-plus in frame {&frame-name}.
  return error.
end.
else do:
  find first bf-chk-two_goods where bf-chk-two_goods.artic    = input frame {&frame-name} varartic-plus
                                and recid (bf-chk-two_goods) <> recid (bf-chk_goods)
                                and bf-chk-two_goods.stts     = 0 no-lock no-error.
  if input frame {&frame-name} varprod-code-plus <> 0 then do:
    find first bf-chk_goods where bf-chk_goods.prod-code  = input frame {&frame-name} varprod-code-plus
                              and bf-chk_goods.artic      = input frame {&frame-name} varartic-plus     no-lock no-error.
    if not available bf-chk_goods then do:
      message "Неправильный Код производителя - такого товара нет.".
      apply "entry" to varprod-code-plus in frame {&frame-name}.
      return. /* без error - не будет вызова справочника */
    end.
    find first bf-chk-two_goods where bf-chk-two_goods.artic     = input frame {&frame-name} varartic-plus
                                  and bf-chk-two_goods.prod-code = input frame {&frame-name} varprod-code-plus
                                  and recid (bf-chk-two_goods)  <> recid (bf-chk_goods)
                                  and bf-chk-two_goods.stts      = 0 no-lock no-error.
  end.
  else do:
    if available bf-chk-two_goods then do:
      message "С артикулом :" input frame {&frame-name} varartic-plus
              "несколько товаров." skip (2)
               "Укажите Производителя или выберите товар из справочника.".
      apply "entry" to varprod-code in frame {&frame-name}.
      return.        /* без error - не будет вызова справочника */
    end.
  end.
  if input frame {&frame-name} varprod-code-plus <> 0  and
     input frame {&frame-name} varprod-type-plus <> "" then do:
     find bf-chk_goods where bf-chk_goods.prod-type = input frame {&frame-name} varprod-type-plus and
                             bf-chk_goods.prod-code = input frame {&frame-name} varprod-code-plus and
                             bf-chk_goods.artic     = input frame {&frame-name} varartic-plus     no-lock no-error.
     if not available bf-chk_goods then do:
      message "Неправильный Тип производителя - такого товара нет.".
      apply "entry" to varprod-type-plus in frame {&frame-name}.
      return.        /* без error - не будет вызова справочника */
     end.
  end.
  else do:
    if available bf-chk-two_goods then do:
        message "С артикулом :" input frame {&frame-name} varartic-plus
                        "несколько товаров." skip (2)
                        "Укажите Производителя или выберите товар из справочника.".
        apply "entry" to varprod-type-plus in frame {&frame-name}.
        return.        /* без error - не будет вызова справочника */
    end.
  end.
  if bf-chk_goods.artic     = input frame {&frame-name} varartic     and
     bf-chk_goods.prod-type = input frame {&frame-name} varprod-type and
     bf-chk_goods.prod-code = input frame {&frame-name} varprod-code then do:
    message "Для списания и приходывания вы выбрали один и тот же товар." view-as alert-box error.
    apply "entry" to varartic-plus in frame {&frame-name}.
    assign
      varartic-plus     = ""
      varprod-type-plus = ""
      varprod-code-plus = 0.
    display varartic-plus varprod-type-plus varprod-code-plus with frame {&frame-name}.
    return error.
  end.
  run ver-gds IN THIS-PROCEDURE (bf-chk_goods.gds-code, output varnabor) no-error .
  if error-status:error
  then do:
     message return-value VIEW-AS ALERT-BOX.
     return  error.
  end.
  if varnabor = true then do:
    message "Это не товарная позиция - имеет атрибут НАБОР !!!".
    apply "entry" to varartic-plus in frame {&frame-name}.
    return.
  end.
  { str/is-petrl.i
    bf-chk_goods.artic
    bf-chk_goods.prod-type
    bf-chk_goods.prod-code
    is-petrol-plus
    is-pieces-plus
    no-error
  }
  find first bf_units where bf_units.unit-name = bf-chk_goods.unit-base no-lock.
  if lookup({&twounit}, bf_units.type) <> 0 then do:
    MESSAGE substitute ("В документе пересортица недопускается товар с двумя единицами измерения. Товар: &1 &2 &3", bf-chk_goods.artic, bf-chk_goods.prod-type, bf-chk_goods.prod-code) VIEW-AS ALERT-BOX ERROR.
    apply "entry" to varartic-plus in frame {&frame-name}.
    assign
      varartic-plus     = ""
      varprod-type-plus = ""
      varprod-code-plus = 0.
    display varartic-plus varprod-type-plus varprod-code-plus with frame {&frame-name}.
    return error.
  end.
  FIND FIRST bf_gds-prt WHERE bf_gds-prt.upper-code = bf-chk_goods.prt-root NO-LOCK NO-ERROR.
  IF lookup( bf-chk_goods.gds-type, {&gds-office} ) > 0 THEN DO:
    MESSAGE "В документе пересортица недопустимы услуги." VIEW-AS ALERT-BOX ERROR.
    apply "entry" to varartic-plus in frame {&frame-name}.
    assign
      varartic-plus     = "":u
      varprod-type-plus = "":u
      varprod-code-plus = 0.
    display varartic-plus varprod-type-plus varprod-code-plus with frame {&frame-name}.
    return error.
  end.
  find first bf_clients where bf_clients.obj-type = bf-chk_goods.prod-type and
                              bf_clients.obj-code = bf-chk_goods.prod-code no-lock.
  assign
    varartic-plus           = bf-chk_goods.artic
    varprod-type-plus       = bf-chk_goods.prod-type
    varprod-code-plus       = bf-chk_goods.prod-code
    vargds-name-plus        = bf-chk_goods.gds-name
    varunit-name-plus       = bf-chk_goods.unit-base
    varfull-scale-name-plus = (if bf_gds-prt.node-name = {&empty-scale} then "":u else bf_gds-prt.f-name)
  .
  display varartic-plus varprod-type-plus varprod-code-plus vargds-name-plus varunit-name-plus with frame {&frame-name}.
  if varfull-scale-name-plus <> "":u then do:
    display varfull-scale-name-plus with frame {&frame-name}.
  end.
  else do:
    hide varfull-scale-name-plus in frame {&frame-name}.
  end.
  if not(is-petrol-plus and not is-pieces-plus) then do:
    HIDE varqnty-kg-plus IN FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
    VIEW varqnty-kg-plus IN FRAME {&FRAME-NAME}.
  END.
  if bf_gds-prt.node-name = {&empty-scale} then do:
    if is-petrol-plus and not is-pieces-plus then do:
      for each tt-pl-qty-plus :
        delete tt-pl-qty-plus.
      end.
      assign
        varqnty-plus    = 0.00
        varqnty-kg-plus = 0.00.
      run str/prstptrl.w (BUFFER bf-chk_goods,
                      input  ?,
                      INPUT  pardoc-code,
                      INPUT  parobj-type,
                      INPUT  parobj-code,
                      INPUT  no,
                      INPUT  {&add-def},
                      OUTPUT varstate)   no-error.
      if error-status:error or varstate <> yes then do:
        assign
          varartic-plus             = "":u
          varprod-type-plus         = "":u
          varprod-code-plus         = ?
          vargds-name-plus          = "":u
          varunit-name-plus         = "":u
          varfull-scale-name-plus   = "":u
        .
        display varartic-plus varprod-type-plus varprod-code-plus vargds-name-plus varunit-name with frame {&frame-name}.
        if varfull-scale-name-plus:visible in frame {&frame-name} then do:
          display varfull-scale-name-plus with frame {&frame-name}.
        end.
        apply "entry" to varartic-plus in frame {&frame-name}.
        return error.
      end.
      else do:
        for each tt-place :
          if tt-place.write-off-doc-l <> 0 then do:
            create tt-pl-qty-plus.
            assign
              tt-pl-qty-plus.pl-code = tt-place.pl-code
              tt-pl-qty-plus.qnty-l  = tt-place.income-l
              tt-pl-qty-plus.qnty-kg = tt-place.income-kg
            .
            assign
              varqnty-plus    = varqnty-plus    + tt-pl-qty-plus.qnty-l
              varqnty-kg-plus = varqnty-kg-plus + tt-pl-qty-plus.qnty-kg.
          end.
        end.
        display varqnty-plus varqnty-kg-plus with frame {&frame-name}.
      end.
      /*
      ASSIGN b-prt-in:LABEL = "Рез-р оп.".
      ENABLE b-prt-in WITH FRAME {&FRAME-NAME}.
      */
    end.
    else do:
      HIDE b-prt-in IN FRAME {&FRAME-NAME}.
      assign
        parmode = "second-goods":u.
      enable varqnty-plus with frame {&frame-name}.
      run ui-on in this-procedure.
    end.
  end.
  else do:
   /*
   ASSIGN b-prt-in:LABEL = "Шкала оп.".
   ENABLE b-prt-in WITH FRAME {&FRAME-NAME}.
   */
    hide varqnty-plus in frame {&frame-name}.
    for each tt-gds-prt on error undo, return error return-value :
      delete tt-gds-prt.
    end.
    run str/prt-prst.w (buffer bf-chk_goods,
                    input  pardoc-code,
                    input  parobj-type,
                    input  parobj-code,
                    input  no,
                    INPUT  parmode,
                    output varstate) no-error.
    if error-status:error or varstate <> yes then do:
      assign
        varartic-plus           = "":u
        varprod-type-plus       = "":u
        varprod-code-plus       = ?
        vargds-name-plus        = "":u
        varunit-name-plus       = "":u
        varfull-scale-name-plus = "":u
      .
      display varartic-plus varprod-type-plus varprod-code-plus vargds-name-plus varunit-name-plus with frame {&frame-name}.
      if varfull-scale-name-plus:visible in frame {&frame-name} then do:
        display varfull-scale-name-plus with frame {&frame-name}.
      end.
      apply "entry" to varartic-plus in frame {&frame-name}.
      return error.
    end.
    else do:
      for each tt-gds-dtl-plus on error undo, return error return-value :
        delete tt-gds-dtl-plus.
      end.
      assign
        varqnty-plus = 0.00.
      for each tt-gds-prt where tt-gds-prt.income-qnty > 0 on error undo, return error return-value :
        create tt-gds-dtl-plus.
        assign
          tt-gds-dtl-plus.gds-code = bf-chk_goods.gds-code
          tt-gds-dtl-plus.prt-code = tt-gds-prt.prt-code
          tt-gds-dtl-plus.qnty     = tt-gds-prt.income-qnty.
        assign
          varqnty-plus = varqnty-plus + tt-gds-dtl-plus.qnty.
        display varqnty-plus with frame {&frame-name}.
      end.
      apply "entry" to b-save in frame {&frame-name}.
    end.
  end.
END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-qnty Dialog-Frame
PROCEDURE set-qnty :
IF INPUT FRAME {&FRAME-NAME} varqnty = ?    OR
     INPUT FRAME {&FRAME-NAME} varqnty = 0.00 THEN DO:
    MESSAGE "Вы не установили количество." VIEW-AS ALERT-BOX.
    return error.
  END.
ASSIGN FRAME {&FRAME-NAME}
   varqnty.
RUN ui-on IN THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-qnty-plus Dialog-Frame
PROCEDURE set-qnty-plus :
IF INPUT FRAME {&FRAME-NAME} varqnty-plus = ?    OR
   INPUT FRAME {&FRAME-NAME} varqnty-plus = 0.00 THEN DO:
    MESSAGE "Вы не установили количество." VIEW-AS ALERT-BOX.
    return error.
END.
ASSIGN FRAME {&FRAME-NAME}
   varqnty-plus.
RUN ui-on IN THIS-PROCEDURE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ui-on Dialog-Frame
PROCEDURE ui-on :
DO ON ERROR UNDO, RETURN ERROR RETURN-VALUE:
  IF parmode = {&add-def} THEN DO:
    ENABLE b-save varartic varprod-type varprod-code r-goods r-list
           varartic-plus varprod-type-plus varprod-code-plus r-goods-plus r-list-plus WITH FRAME {&FRAME-NAME}.
  END.
  if parmode = {&update} then do:
    ENABLE b-save WITH FRAME {&FRAME-NAME}.
  end.
  CASE parmode:
    WHEN {&LOOKUP} THEN DO:
    END.
    WHEN {&add-def} THEN DO:
      APPLY "entry" TO varartic IN FRAME {&FRAME-NAME}.
    END.
    WHEN "first-goods":u THEN DO:
        APPLY "entry" TO varqnty IN FRAME {&FRAME-NAME}.
    END.
    WHEN "second-goods":u THEN DO:
      APPLY "entry" TO varqnty-plus.
    END.
  END CASE.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ver-gds Dialog-Frame
PROCEDURE ver-gds :
define input  parameter p-gds-code as integer   no-undo .
define output parameter  v-nabor   as logical   no-undo .

define variable varvalue        as character no-undo .
define variable vartype         as character no-undo .
{ gbl/objsrv.i }
define variable EDOParSec       as class     ibs.th.gbl.env.prmtrs.edo .
  
define buffer buf_goods-attr for goods-attr.
 do
 on error undo, return error return-value
 :
   
  EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(parobj-type, parobj-code).
  
  RUN gds-attr-value (
          INPUT p-gds-code,
          INPUT {&attr-mark-type},
          OUTPUT varvalue,
          OUTPUT vartype
          ).
  if varvalue > ""
  and EDOParSec:GetIsMarkingForType(varvalue)
  then
    return error substitute("Товар &1 с маркировкой нельзя добавлять.",p-gds-code). 
  v-nabor = false .
  run ver-gds-grp-nabor in this-procedure ( input p-gds-code, output v-nabor) .
 END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME