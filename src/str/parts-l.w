&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DECLARATIONS Dialog-Frame 
using ibs.th.str.mercury.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
using ibs.th.str.marking.sts.*.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр и редактирование партий

Автор: Чернова Светлана Александровна
Дата создания: 02/14/07
Author: Svetlana Chernova
Creation date: 02/14/07

create1: Перваков Михаил Сергеевич
Дата создания: 12/16/99

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc  as widget-handle no-undo.
define input  parameter v-obj-type   as character no-undo .
define input  parameter v-obj-code   as integer   no-undo .
define input  parameter p-gds-code   as integer   no-undo .
define input  parameter p-doc-code   as character no-undo .
define input  parameter p-edit-mode  as character no-undo .
define input  parameter p-r-parts    as character no-undo .  /* все, свободно, остатки, документ */
define input  parameter p-one-all    as character no-undo .  /* текущий, все */ /* объект */
define input  parameter p-call-point as character no-undo .  /* справочник, выбор, документ */
define output parameter part-recid   as recid     no-undo .

define variable v-prt-rec as recid no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр/Редактирование партий".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8':u,v-obj-type,v-obj-code,p-gds-code,p-doc-code,p-edit-mode,p-r-parts,p-one-all,p-call-point)"}
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ str/plgdsfnd.i }
{ gbl/color.i    }
{ cmp/operlist.i }
{ trg/rsrgdsck.i }
{ trg/trndocrs.i }
{ trg/partsfnc.i }
{ gbl/tax-name.i }
{ gbl/waitfram.i }
{ gbl/alc-lib.i  }
{ str/lib-trn.i  }
{ gbl/getcntxt.i def }
{ gbl/fltopend.i defproc }
{ cmp/mrk-strf.i }
{ gbl/clntattr.i }
{ ref/gds-attr.i }
{ str/temp_upd.i }
{ utl/gtin.i }
/* параметры резервирования, передаются в закодированном значении через p-r-parts */
define variable v-need-reserv          as logical   no-undo .
define variable v-need-check-diff-qnty as logical   no-undo .
define variable v-chg-qnty             as decimal   no-undo .

define variable mark                    as character                no-undo column-label "*"                format "x(1)"  .
define variable parts-part-code         as character                no-undo column-label "Партия"           format "x(40)" .
define variable parts-out-code          as character                no-undo column-label "Статус"           format "x(18)" .
define variable parts-object            as character                no-undo column-label "Объект"           format "x(10)" .
define variable parts-b-code            as integer                  no-undo column-label "Бар-код"          format "9999999999" .
define variable parts-purch-code        as character                no-undo column-label "Тип приобретения" format "x(20)" .
define variable parts-contract-prn-code as character                no-undo column-label "Договор"          format "x(16)" .
define variable in-code-date as character no-undo .
define variable vprice-prod1 as decimal   no-undo .
define variable vprice-prod2 as decimal   no-undo .
define variable vsdsubsObj as class vsdsubs no-undo.
define variable vsdsubObj  as class vsdsub no-undo.
define variable vsdStorageObj as class vsdtostorage no-undo.
define variable vsdSts as class vsdstatustype no-undo.
define variable v-vozvr-perem-no-fact as logical no-undo.
define variable v-marking as logical no-undo .
define variable v-marking-value as character no-undo .
define variable v-marking-type as character no-undo .
define variable varvalue as character no-undo .
define variable vartype as character no-undo .
define variable v-ext-mode as character no-undo .
define variable v-sum-parts-qnty as decimal no-undo .
define variable v-is-return as logical init no .

{ gbl/objsrv.i }
define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .

define new shared buffer  parts for ub.parts  .
define buffer  buf_trn for ub.trn-doc  .

FUNCTION get-in-code-date RETURNS CHARACTER
  ( input p-recid as recid ) :
define buffer buf_parts for ub.parts  .
define buffer buf_parts-attr for ub.parts-attr  .
define buffer buf_goods      for ub.goods       .

find first  buf_parts no-lock where recid(buf_parts) = p-recid no-error .
find first buf_goods no-lock where
            buf_goods.artic =  buf_parts.artic and
            buf_goods.prod-code =  buf_parts.prod-code and
            buf_goods.prod-type =  buf_parts.prod-type no-error .

find first buf_parts-attr no-lock
     where buf_parts-attr.part-code = buf_parts.part-code and
           buf_parts-attr.in-code   = buf_parts.in-code   and
           buf_parts-attr.gds-code  = buf_goods.gds-code  no-error .
           if available buf_parts-attr then return string ( buf_parts-attr.fact-date, "99/99/9999" ) .
           else return "" .

END FUNCTION.

FUNCTION get-price-prod1 RETURNS DECIMAL
  ( input p-recid as recid ) :
define buffer buf_parts for ub.parts  .
define variable       p-price as decimal   no-undo .
define variable       p-priceWithVat as decimal   no-undo .
define variable       p-vat-pc as decimal   no-undo .

find first  buf_parts no-lock where recid(buf_parts) = p-recid no-error .
    { gbl/partppric.i
      buf_parts
      p-price
      p-priceWithVat
      p-vat-pc
      no-error }
return p-price .

END FUNCTION.

FUNCTION get-price-prod2 RETURNS DECIMAL
  ( input p-recid as recid ) :
define buffer buf_parts for ub.parts  .
define variable       p-price as decimal   no-undo .
define variable       p-priceWithVat as decimal   no-undo .
define variable       p-vat-pc as decimal   no-undo .

find first  buf_parts no-lock where recid(buf_parts) = p-recid no-error .
    { gbl/partppric.i
      buf_parts
      p-price
      p-priceWithVat
      p-vat-pc
      no-error }
return p-priceWithVat .

END FUNCTION.
def var Marking as class mark no-undo .

FUNCTION StatusTHName RETURNS CHARACTER
  (input p-stsTH as integer)  .
  Return Marking:GetLabel(p-stsTH) .
END FUNCTION .


FUNCTION get-b-code RETURNS integer
  ( BUFFER buf_parts FOR parts ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  define variable v-b-code like ub.bar-code.b-code no-undo .

  { gbl/partbcod.i
    parts
    v-b-code
    no-error
  }
  if error-status :error
  then do:
    return 0 .
  end.
  else do:
    return v-b-code .
  end.

END FUNCTION.


FUNCTION get-price-sale RETURNS DECIMAL
  ( input p-recid as recid ) :
define buffer buf_parts for ub.parts  .
define variable v-price as decimal   no-undo .
define variable v-cur-dn as character no-undo .
define variable v-cur-rt as decimal   no-undo .
define variable v-cur-ex as decimal   no-undo .
define variable v-b-code as integer   no-undo .

v-price = 0.
find first  buf_parts no-lock where recid(buf_parts) = p-recid no-error .
v-b-code = get-b-code(buffer buf_parts) .
if v-b-code = 0 then return .0 .
{ gbl/bcodeprc.i
    buf_parts.obj-type
    buf_parts.obj-code
    v-b-code
    0
    0
    v-cur-dn
    v-price
    v-cur-rt
    v-cur-ex
    no-error }
   if error-status :error then do:
     v-price = ? .
   end.

   return  v-price .

END FUNCTION.
FUNCTION get-price-doc RETURNS character
  ( input p-recid as recid ) :
define buffer buf_parts for ub.parts  .
define variable v-price as decimal   no-undo .
define variable v-cur-dn as character no-undo .
define variable v-cur-rt as decimal   no-undo .
define variable v-cur-ex as decimal   no-undo .
define variable v-b-code as integer   no-undo .

v-cur-dn = "".
find first  buf_parts no-lock where recid(buf_parts) = p-recid no-error .
v-b-code = get-b-code(buffer buf_parts) .
if v-b-code = 0 then return "".
{ gbl/bcodeprc.i
    buf_parts.obj-type
    buf_parts.obj-code
    v-b-code
    0
    0
    v-cur-dn
    v-price
    v-cur-rt
    v-cur-ex
    no-error }
   if error-status :error then do:
     v-cur-dn = ? .
   end.

   return substitute("&1 №&2" , v-price ,v-cur-dn) .

END FUNCTION.


FUNCTION get-in-code-dateS RETURNS date
  ( input p-recid as recid ) :
define buffer buf_parts for ub.parts  .
define buffer buf_parts-attr for ub.parts-attr  .
define buffer buf_goods      for ub.goods       .

find first  buf_parts no-lock where recid(buf_parts) = p-recid no-error .
find first buf_goods no-lock where
            buf_goods.artic =  buf_parts.artic and
            buf_goods.prod-code =  buf_parts.prod-code and
            buf_goods.prod-type =  buf_parts.prod-type no-error .

find first buf_parts-attr no-lock
     where buf_parts-attr.part-code = buf_parts.part-code and
           buf_parts-attr.in-code   = buf_parts.in-code   and
           buf_parts-attr.gds-code  = buf_goods.gds-code  no-error .
           if available buf_parts-attr then return  buf_parts-attr.fact-date .
           else return date("") .
END FUNCTION.


/* требуется редактирование партий */
define variable v-edit-parts as logical   no-undo init false .
/* можно создавать и удалять партии */
define variable v-add-parts as logical   no-undo init false .
/* условие того, что при редактировании партий */
/* а значит нам необходимо проверять изменение резервов */
define variable v-need-rsrv-gds as logical no-undo init false .
define variable v-is-petrol     as logical no-undo init false .
define variable v-is-pieces     as logical no-undo init false .
define variable v-data-changed  as logical no-undo init false .

define variable v-reserv-pl-code            as logical   no-undo init ? .
define variable v-pl-code                   as integer   no-undo init 0 .
define variable v-goods-twounit             as logical   no-undo .
define variable v-goods-alcohol-prod        as logical   no-undo .
define variable v-free-parts-qnty           as decimal   no-undo .
define variable v-free-parts-fact-qnty      as decimal   no-undo .
define variable v-free-parts-cli-qnty       as decimal   no-undo .
define variable v-free-parts-price-base     as decimal   no-undo .
define variable v-free-parts-price-rubl     as decimal   no-undo .
define variable v-out-parts-qnty            as decimal   no-undo .
define variable v-out-parts-fact-qnty       as decimal   no-undo .
define variable v-out-parts-cli-qnty        as decimal   no-undo .
define variable v-out-parts-price-base      as decimal   no-undo .
define variable v-out-parts-price-rubl      as decimal   no-undo .
define variable v-new-free-parts-qnty       as decimal   no-undo .
define variable v-new-free-parts-fact-qnty  as decimal   no-undo .
define variable v-new-free-parts-cli-qnty   as decimal   no-undo .
define variable v-new-free-parts-price-base as decimal   no-undo .
define variable v-new-free-parts-price-rubl as decimal   no-undo .
define variable v-new-out-parts-qnty        as decimal   no-undo .
define variable v-new-out-parts-fact-qnty   as decimal   no-undo .
define variable v-new-out-parts-cli-qnty    as decimal   no-undo .
define variable v-new-out-parts-price-base  as decimal   no-undo .
define variable v-new-out-parts-price-rubl  as decimal   no-undo .
define variable rid                         as recid     no-undo .
define variable conf-par                    as character no-undo .    /* для чтения параметра конфигурации */
define variable par-type                    as character no-undo .    /* тип параметра конфигурации */
define variable old-mode                    as character no-undo .
define variable old-handle                  as handle    no-undo .
define variable old-type                    as character no-undo .
define variable old-stat                    as character no-undo .
define variable old-flag                    as logical   no-undo .
define variable old-internal                as logical   no-undo .
define variable del-list                    as character no-undo.
define variable filter-point                as character no-undo init "parts-l" .
define variable sort-column-name            as character no-undo .
define variable v-mode-name                 as character no-undo .

&SCOP NEW NEW

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-parts

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES parts

/* Definitions for BROWSE br-parts                                      */
&Scoped-define FIELDS-IN-QUERY-br-parts get-mark(buffer parts) @ mark get-parts-part-code(buffer parts, v-goods-alcohol-prod) @ parts-part-code get-parts-out-code(buffer parts) @ parts-out-code parts.qnty parts.fact-qnty parts.price-base parts.price-rubl parts.cli-qnty parts.cli-base-rate parts.transport-base parts.transport-rubl parts.road-tax-base parts.road-tax-rubl parts.other-base parts.other-rubl (parts.obj-type + " " + STRING (parts.obj-code)) @ parts-object parts.is-supp parts.cst-code parts.last-date parts.hold-date parts.pl-code get-b-code(buffer parts) @ parts-b-code get-purch-code(buffer parts) @ parts-purch-code get-contract-prn-code(recid(parts)) @ parts-contract-prn-code parts.part-code parts.in-code (get-in-code-date(recid(parts))) (get-price-sale(recid(parts)))  (get-price-prod1(recid(parts))) (get-price-prod2(recid(parts))) parts.in-code parts.out-code parts.part-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-parts parts.qnty ~
parts.fact-qnty
&Scoped-define ENABLED-TABLES-IN-QUERY-br-parts parts
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-parts parts
&Scoped-define SELF-NAME br-parts
&Scoped-define OPEN-QUERY-br-parts /* OPEN QUERY {&SELF-NAME} FOR EACH parts NO-LOCK. */ run reopen-query in this-procedure .
&Scoped-define TABLES-IN-QUERY-br-parts parts
&Scoped-define FIRST-TABLE-IN-QUERY-br-parts parts


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-parts}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-mark b-sel b-lkp b-add b-chg ~
b-del b-sch b-print b-help RECT-4 RECT-7 b-doc b-b-alt b-pl rs-parts ~
rs-one-all R-find s-code br-parts b-income-in-code b-in b-contract ~
FI_price-doc
&Scoped-Define DISPLAYED-OBJECTS rs-parts rs-one-all R-find s-code ~
FI_doc-line_doc-qnty fi-label-filter-status FI_doc-line_fact-qnty ~
FI_unit-base fi-label-filter-object fi-free-qnty fi-free-rsrv-qnty ~
FI_orig-purch-code fi-income-qnty fi-income-qnty-fact fi-out-qnty ~
fi-out-rsrv-qnty FI_last-date FI_price-doc FI_parts_cli-qnty ~
FI_parts_cli-base-rate FI_parts_SLT-type FI_parts_SLT-pc FI_country-name ~
FI_purch-code FI_contract-prn-code

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-contract-prn-code Dialog-Frame
FUNCTION get-contract-prn-code RETURNS CHARACTER
  ( input p-recid as recid  )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-country-name Dialog-Frame
FUNCTION get-country-name RETURNS CHARACTER
  ( BUFFER buf_parts FOR parts )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-mark Dialog-Frame
FUNCTION get-mark RETURNS CHARACTER
  ( BUFFER buf_parts FOR parts )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-purch-code Dialog-Frame
FUNCTION get-purch-code RETURNS CHARACTER
  ( BUFFER buf_parts FOR parts )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-alc-attr
     LABEL "АлкАт&р"
     SIZE 10 BY 1 TOOLTIP "Атрибуты алкогольной продукции".

DEFINE BUTTON b-vsd
     LABEL "ВС&Д"
     SIZE 10 BY 1 TOOLTIP "Ветеренарная справка".

DEFINE BUTTON b-b-alt
     LABEL "&Коды"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-contract
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL "b-contract"
     SIZE 3 BY 1 TOOLTIP "Посмотреть До&говор".

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-doc
     LABEL "Д&окумент"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-in
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL "П&Н"
     SIZE 3 BY 1 TOOLTIP "Документ, создавший партию или изменивший её параметры".

DEFINE BUTTON b-income-in-code
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL "Вне&ш.ПН"
     SIZE 3 BY 1 TOOLTIP "Внешний приходный документ, создавший партию".

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-marking 
     LABEL "&Марки" 
     SIZE 10 BY 1 TOOLTIP "Марки".

DEFINE BUTTON b-pl 
     LABEL "&Место"
     SIZE 10 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор "
     SIZE 10 BY 1.

DEFINE VARIABLE ed-notes AS CHARACTER
     VIEW-AS EDITOR
     SIZE 25.5 BY 1.75
     BGCOLOR 8 FGCOLOR 4 FONT 2 NO-UNDO.

DEFINE VARIABLE fi-b-code AS INTEGER FORMAT ">>>>>>>>>>>>9":U INITIAL 0
     LABEL "Бар-код"
      VIEW-AS TEXT
     SIZE 14 BY .79 TOOLTIP "Бар-код"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-free-qnty AS DECIMAL FORMAT "->>>,>>>,>>9.999":U INITIAL 0
     LABEL "Свободно"
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-free-rsrv-qnty AS DECIMAL FORMAT "->>>,>>>,>>9.999":U INITIAL 0
     LABEL "Резерв Свободно"
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-income-qnty AS DECIMAL FORMAT "->>>,>>>,>>9.999":U INITIAL 0
     LABEL "Приход док"
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-income-qnty-fact AS DECIMAL FORMAT "->>>,>>>,>>9.999":U INITIAL 0
     LABEL "Приход факт"
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-label-filter-object AS CHARACTER FORMAT "X(256)":U INITIAL "Объекты:"
      VIEW-AS TEXT
     SIZE 8 BY .88 NO-UNDO.

DEFINE VARIABLE fi-label-filter-status AS CHARACTER FORMAT "X(256)":U INITIAL "Статус:"
      VIEW-AS TEXT
     SIZE 7 BY .67 NO-UNDO.

DEFINE VARIABLE fi-out-qnty AS DECIMAL FORMAT "->>>,>>>,>>9.999":U INITIAL 0
     LABEL "Расход"
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-out-rsrv-qnty AS DECIMAL FORMAT "->>>,>>>,>>9.999":U INITIAL 0
     LABEL "Резерв Расход"
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FI_contract-prn-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Договор"
      VIEW-AS TEXT
     SIZE 36.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FI_country-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Страна"
      VIEW-AS TEXT
     SIZE 21.13 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FI_currency_curr-abbr AS CHARACTER FORMAT "X(3)"
      VIEW-AS TEXT
     SIZE 10 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE FI_doc-line_doc-qnty AS DECIMAL FORMAT "->>,>>9.99" INITIAL ?
     LABEL "По док-ту"
      VIEW-AS TEXT
     SIZE 13 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE FI_doc-line_fact-qnty AS DECIMAL FORMAT "->>,>>9.99" INITIAL 0
     LABEL "Факт"
      VIEW-AS TEXT
     SIZE 13 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE FI_last-date AS CHARACTER FORMAT "X(10)":U
     LABEL "Годен до"
      VIEW-AS TEXT
     SIZE 11.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FI_obj-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0
      VIEW-AS TEXT
     SIZE 11.5 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE FI_obj-name AS CHARACTER FORMAT "X(40)"
     LABEL "Пост-к"
      VIEW-AS TEXT
     SIZE 29.5 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE FI_obj-type AS CHARACTER FORMAT "X(3)"
      VIEW-AS TEXT
     SIZE 6 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE FI_orig-purch-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип приобретения"
      VIEW-AS TEXT
     SIZE 25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FI_parts_cli-base-rate AS DECIMAL FORMAT "->>,>>9.99" INITIAL 0
     LABEL "Коэфф. пост."
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE FI_parts_cli-qnty AS DECIMAL FORMAT "->>,>>9.99" INITIAL 0
     LABEL "Кол. пост."
      VIEW-AS TEXT
     SIZE 17 BY .67 TOOLTIP "Документарное"
     FGCOLOR 4 .

DEFINE VARIABLE FI_parts_fact-date AS DATE FORMAT "99/99/9999"
     LABEL "Дата"
      VIEW-AS TEXT
     SIZE 12 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE FI_parts_in-code AS CHARACTER FORMAT "X(14)"
     LABEL "ПН"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE FI_parts_orig-fact-date AS DATE FORMAT "99/99/9999"
     LABEL "Дата"
      VIEW-AS TEXT
     SIZE 12 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE FI_parts_orig-in-code AS CHARACTER FORMAT "X(14)"
     LABEL "Внеш.ПН"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE FI_parts_price-cli AS DECIMAL FORMAT "->>,>>>,>>9.99" INITIAL 0
     LABEL "Цена пост."
      VIEW-AS TEXT
     SIZE 22.75 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE FI_parts_SLT-pc AS DECIMAL FORMAT "->>,>>9.99" INITIAL 0
     LABEL "%"
      VIEW-AS TEXT
     SIZE 6 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE FI_parts_SLT-type AS CHARACTER FORMAT "X(8)"
     LABEL "НП"
      VIEW-AS TEXT
     SIZE 9 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE FI_parts_VAT-pc AS DECIMAL FORMAT "->>,>>9.99" INITIAL 0
     LABEL "%"
      VIEW-AS TEXT
     SIZE 7 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE FI_parts_VAT-type AS CHARACTER FORMAT "X(8)"
     LABEL "НДС"
      VIEW-AS TEXT
     SIZE 9 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE FI_pay-name AS CHARACTER FORMAT "X(40)"
     LABEL "Оплата"
      VIEW-AS TEXT
     SIZE 28 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE FI_price-doc AS CHARACTER FORMAT "X(256)":U
     LABEL "Продажная цена"
      VIEW-AS TEXT
     SIZE 25.5 BY .67 TOOLTIP "Текущая продажная цена баркода и № переоценки"
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE FI_purch-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип приобретения"
      VIEW-AS TEXT
     SIZE 22.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FI_unit-base AS CHARACTER FORMAT "X(3)"
      VIEW-AS TEXT
     SIZE 4 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE FI_unit_cli-abbr AS CHARACTER FORMAT "X(3)"
      VIEW-AS TEXT
     SIZE 4.5 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE s-code AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 11.5 BY .88 TOOLTIP "Поиск по" NO-UNDO.

DEFINE VARIABLE R-find AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "№ партии", 1,
"Бар-код", 2
     SIZE 20.38 BY .88 TOOLTIP "Поиск" NO-UNDO.

DEFINE VARIABLE rs-one-all AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Текущий объект", "текущий",
"Все объекты", "все"
     SIZE 29.5 BY .88 TOOLTIP "Выбор объекта"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-parts AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", "все",
"Факт остатки", "остатки",
"Свободно", "свободно",
"Документ", "документ"
     SIZE 46.5 BY .67 TOOLTIP "Выбор статуса"
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 37.25 BY 5.13.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 58.13 BY 2.17.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE new shared QUERY br-parts FOR
      parts SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-parts Dialog-Frame _FREEFORM
  QUERY br-parts DISPLAY
      get-mark(buffer parts) @ mark
      get-parts-part-code(buffer parts, v-goods-alcohol-prod) @ parts-part-code
      get-parts-out-code(buffer parts) @ parts-out-code
      parts.qnty COLUMN-LABEL "По док./ Свобод."
      parts.fact-qnty COLUMN-LABEL "Факт / Остаток"
      parts.price-base format "->>,>>>,>>9.99"
      parts.price-rubl
      parts.cli-qnty column-label "Кол. пост."
      parts.cli-base-rate column-label "Коэфф. пост."
      parts.transport-base column-label "Трансп. (вал)"
      parts.transport-rubl column-label "Трансп. (abbr_rub)"
      parts.road-tax-base column-label "Дор.налог (вал)"
      parts.road-tax-rubl column-label "Дор.налог (abbr_rub)"
      parts.other-base column-label "Другое (вал)"
      parts.other-rubl column-label "Другое (abbr_rub)"
      (parts.obj-type + " " + STRING (parts.obj-code)) @ parts-object
      parts.is-supp format "+/-" column-label "П"
      parts.cst-code FORMAT "X(31)"
      parts.last-date format '99/99/9999':u column-label "Годен до"
      parts.hold-date format '99/99/9999':u column-label "Дата МФ"
      parts.pl-code column-label "Место" FORMAT "99999999999":U
      get-b-code(buffer parts) @ parts-b-code
      get-purch-code(buffer parts) @ parts-purch-code
      get-contract-prn-code(recid(parts)) @ parts-contract-prn-code column-label "Договор" format "x(20)"
      parts.part-code column-label "Код партии в БД" format "x(20)"
      parts.in-code column-label "Источник" format "x(20)"
      (get-in-code-date(recid(parts))) column-label "Дата ист."  format "x(10)"
      (get-price-sale(recid(parts)))  column-label "Тек.прод.цена"  format ">>>>>>>>>9.99"
      (get-price-prod1(recid(parts)))  @  vprice-prod1 column-label "Цена Произв."  format ">>>>>>>>>9.99"
      (get-price-prod2(recid(parts)))  @  vprice-prod2 column-label "Цена Прзв_с_НДС"  format ">>>>>>>>>>>9.99"
    if parts.defect  =  logical({&FiB}) then "+"  else "" column-label "Ф" format "x(1)"
      /*parts.in-code   column-label "in-code"
      parts.out-code  column-label "out-code"
      parts.part-code  column-label "part-code"
      */
  ENABLE
      parts.qnty
      parts.fact-qnty
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96 BY 8.42
         BGCOLOR 15  ROW-HEIGHT-CHARS .67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-mark AT ROW 1 COL 21
     b-sel AT ROW 1 COL 24
     b-lkp AT ROW 1 COL 34
     b-add AT ROW 1 COL 44
     b-chg AT ROW 1 COL 54
     b-del AT ROW 1 COL 64
     b-vsd AT ROW 1 COL 74
     b-sch AT ROW 1 COL 88
     b-print AT ROW 1 COL 91
     b-help AT ROW 1 COL 94
     b-doc AT ROW 2 COL 24
     b-b-alt AT ROW 2 COL 34
     b-pl AT ROW 2 COL 44
     b-alc-attr AT ROW 2 COL 54
     b-marking AT ROW 2 COL 54 
     rs-parts AT ROW 3.13 COL 10 NO-LABEL
     rs-one-all AT ROW 3.92 COL 10 NO-LABEL
     R-find AT ROW 3.92 COL 65.5 NO-LABEL WIDGET-ID 6
     s-code AT ROW 3.92 COL 84 COLON-ALIGNED HELP
          "Поиск по бар-коду" NO-LABEL
     br-parts AT ROW 5.08 COL 1
     b-income-in-code AT ROW 13.79 COL 46.5
     b-in AT ROW 16.75 COL 46.5
     ed-notes AT ROW 20 COL 71.5 NO-LABEL
     b-contract AT ROW 22.54 COL 91.38
     FI_doc-line_doc-qnty AT ROW 2.21 COL 79.5 COLON-ALIGNED
     fi-label-filter-status AT ROW 3.04 COL 2.63 NO-LABEL
     FI_doc-line_fact-qnty AT ROW 3.13 COL 79.5 COLON-ALIGNED
     FI_unit-base AT ROW 3.17 COL 91.63 COLON-ALIGNED NO-LABEL
     fi-label-filter-object AT ROW 3.92 COL 1.63 NO-LABEL
     fi-b-code AT ROW 4 COL 48.88 COLON-ALIGNED
     fi-free-qnty AT ROW 13.83 COL 77 COLON-ALIGNED
     FI_parts_orig-in-code AT ROW 13.92 COL 10 COLON-ALIGNED
     FI_parts_orig-fact-date AT ROW 13.92 COL 32 COLON-ALIGNED
     fi-free-rsrv-qnty AT ROW 14.63 COL 77 COLON-ALIGNED
     FI_orig-purch-code AT ROW 14.79 COL 19 COLON-ALIGNED
     fi-income-qnty AT ROW 15.42 COL 77 COLON-ALIGNED
     fi-income-qnty-fact AT ROW 16.21 COL 77 COLON-ALIGNED WIDGET-ID 2
     FI_parts_in-code AT ROW 17 COL 7.5 COLON-ALIGNED
     FI_parts_fact-date AT ROW 17 COL 32 COLON-ALIGNED
     fi-out-qnty AT ROW 17.13 COL 77 COLON-ALIGNED
     FI_obj-name AT ROW 17.79 COL 7.5 COLON-ALIGNED
     FI_obj-type AT ROW 17.79 COL 39 COLON-ALIGNED NO-LABEL
     FI_obj-code AT ROW 17.79 COL 46 COLON-ALIGNED NO-LABEL
     fi-out-rsrv-qnty AT ROW 17.96 COL 77 COLON-ALIGNED
     FI_pay-name AT ROW 18.58 COL 7.5 COLON-ALIGNED
     FI_last-date AT ROW 18.67 COL 46 COLON-ALIGNED
     FI_price-doc AT ROW 19.25 COL 69.5 COLON-ALIGNED WIDGET-ID 4
     FI_parts_price-cli AT ROW 19.67 COL 11.5 COLON-ALIGNED
     FI_currency_curr-abbr AT ROW 19.67 COL 36.5 COLON-ALIGNED NO-LABEL
     FI_parts_cli-qnty AT ROW 20.46 COL 11.5 COLON-ALIGNED
     FI_unit_cli-abbr AT ROW 20.46 COL 31 COLON-ALIGNED NO-LABEL
     FI_parts_cli-base-rate AT ROW 20.46 COL 51.5 COLON-ALIGNED
     FI_parts_VAT-type AT ROW 21.54 COL 4.5 COLON-ALIGNED
     FI_parts_VAT-pc AT ROW 21.54 COL 18 COLON-ALIGNED
     FI_parts_SLT-type AT ROW 21.54 COL 37.5 COLON-ALIGNED
     FI_parts_SLT-pc AT ROW 21.54 COL 51.5 COLON-ALIGNED
     FI_country-name AT ROW 21.92 COL 73 COLON-ALIGNED
     FI_purch-code AT ROW 22.83 COL 18 COLON-ALIGNED
     FI_contract-prn-code AT ROW 22.83 COL 51.5 COLON-ALIGNED
     RECT-4 AT ROW 13.63 COL 60
     RECT-7 AT ROW 13.58 COL 1.5
     SPACE(38.36) SKIP(7.87)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Партии"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


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
/* BROWSE-TAB br-parts s-code Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE.

/* SETTINGS FOR BUTTON b-alc-attr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       b-alc-attr:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON b-marking IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       b-marking:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN 
       b-vsd:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       br-parts:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 3.

/* SETTINGS FOR EDITOR ed-notes IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN fi-b-code IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN fi-free-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-free-rsrv-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-income-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-income-qnty-fact IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-label-filter-object IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-label-filter-status IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-out-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-out-rsrv-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN FI_contract-prn-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN FI_country-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN FI_currency_curr-abbr IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FI_doc-line_doc-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN FI_doc-line_fact-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN FI_last-date IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN FI_obj-code IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FI_obj-name IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FI_obj-type IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FI_orig-purch-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN FI_parts_cli-base-rate IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN FI_parts_cli-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN FI_parts_fact-date IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FI_parts_in-code IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FI_parts_orig-fact-date IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FI_parts_orig-in-code IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FI_parts_price-cli IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FI_parts_SLT-pc IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN FI_parts_SLT-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN FI_parts_VAT-pc IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FI_parts_VAT-type IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FI_pay-name IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FI_purch-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN FI_unit-base IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN FI_unit_cli-abbr IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-parts
/* Query rebuild information for BROWSE br-parts
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH parts NO-LOCK. */
run reopen-query in this-procedure .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-parts */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Партии */
DO:
  run save-changes in this-procedure no-error .
  if error-status :error
  then do:
    undo, return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Партии */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  { gbl/stdbtn.i }

  do
  on error undo, return no-apply
  on stop  undo, return no-apply
  :
    if p-doc-code = ""
    then do:
      message
        "Добавление партий возможно только в интерфейсе документа"
        view-as alert-box .
      return no-apply .
    end.
    if v-reserv-pl-code = ?
    then do:
      message
        "Неизвестно место складирования товара. Добавление партий невозможно."
        view-as alert-box .
      return no-apply .
    end.
    assign
      v-prt-rec = ?
    .
    run str/parts-f.w
      (input        parparentproc  /* parparentproc    */
      ,input        this-procedure /* h-call-prog      */
      ,input        {&add-def}     /* p-mode           */
      ,input        p-doc-code     /* p-doc-code       */
      ,input        p-gds-code     /* p-gds-code       */
      ,input        v-pl-code      /* p-pl-code        */
      ,input-output v-prt-rec      /* p-parts-recid    */
      ).

    run reopen-query .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-alc-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-alc-attr Dialog-Frame
ON CHOOSE OF b-alc-attr IN FRAME Dialog-Frame /* АлкАтр */
DO:
  { gbl/stdbtn.i }

  define variable v-parts-ps  as character no-undo .
  define variable v-gds-code  as integer   no-undo .
  define variable v-save-flag as logical   no-undo .
define variable p-mode as char no-undo.

p-mode = {&lookup}.


if not available parts then do: 
    message 
    "Нет партий по товару"
    view-as alert-box.
    return no-apply.
    end.

if p-edit-mode = 'update-alc-attr' then do: 
    p-mode = {&update}.

  if v-goods-alcohol-prod <> true then do:
    return no-apply.
  end.

/*  if not available parts then do: */
/*    message                       */
/*      "Неправильно выбрана строка"*/
/*      view-as alert-box .         */
/*    return no-apply.              */
/*  end.                            */

  if p-doc-code = "" then do:
    message
      "Редактирование атрибутов партий возможно только в интерфейсе документа"
      view-as alert-box .
    return no-apply .
  end.

  /* Проверяем принадлежность партии к документу */
  if p-doc-code <> parts.out-code then do:
    message
      "Редактирование атрибутов возможно только для партий, " +
      "относящихся к данному документу"
      view-as alert-box .
    return no-apply .
  end.
end.
  { gbl/gds-code.i
    parts.artic
    parts.prod-type
    parts.prod-code
    v-gds-code
    no-error
  }

  do
  on error undo, return no-apply
  :
    define variable v-alc-mark-db-num          as integer   no-undo .
    define variable v-alc-mark-code            as integer   no-undo .
    define variable v-alc-bottling-date        as date      no-undo .
    define variable v-alc-ref-ab-path          as character no-undo .
    define variable v-alc-quality-certif-path  as character no-undo .
    define variable v-alc-certif-path          as character no-undo .
    define variable v-alc-imp-type             as character no-undo .
    define variable v-alc-imp-code             as integer   no-undo .
    define variable v-mode-alc                 as character no-undo .

    assign
      v-alc-mark-db-num         = parts.mark-db-num
      v-alc-mark-code           = parts.mark-code
      v-alc-bottling-date       = parts.alc-bottling-date
      v-alc-ref-ab-path         = parts.alc-ref-ab-path
      v-alc-quality-certif-path = parts.alc-quality-certif-path
      v-alc-certif-path         = parts.alc-certif-path
      v-alc-imp-type            = parts.alc-imp-type
      v-alc-imp-code            = parts.alc-imp-code
    .


    if p-mode = {&lookup} and ub.parts.out-code = {&free-code}
    then do:
      v-mode-alc = {&update}. 
    end.
    else do:
      v-mode-alc = p-mode.
    end.
    
    run str/in-alc.w
      (input        parparentproc
      ,input       v-mode-alc
      ,input p-gds-code
      ,buffer ub.parts
      ,input-output v-alc-mark-db-num
      ,input-output v-alc-mark-code
      ,input-output v-alc-bottling-date
      ,input-output v-alc-ref-ab-path
      ,input-output v-alc-quality-certif-path
      ,input-output v-alc-certif-path
      ,input-output v-alc-imp-type
      ,input-output v-alc-imp-code
      ,output       v-save-flag
      ) no-error
      .
    if error-status :error
    then do:
      if error-status :get-message(1) <> '':u
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры in-alc.w" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return no-apply .
    end.

    /* Сохраняем измененное значение в самой партии и в порожденных из нее партиях,
       отсылаем команду по новостям на изменение этого значения в других базах */
    if v-save-flag then do:
      run waitfram-show ("Сохранение новых значений и отправка их по новостям ...").
      run trg/partps.p ( input v-gds-code
                       , input parts.in-code
                       , input if ub.parts.doc-type = {&expense} or ub.parts.out-code = {&free-code} then ub.parts.out-code else ?
                       , input parts.part-code
                       , input v-alc-mark-db-num
                       , input v-alc-mark-code
                       , input v-alc-bottling-date
                       , input v-alc-ref-ab-path
                       , input v-alc-quality-certif-path
                       , input v-alc-certif-path
                       , input v-alc-imp-type
                       , input v-alc-imp-code
                       ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры partps.p" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        run waitfram-hide.
        undo, return no-apply .
      end.
      run waitfram-hide.

      find current parts no-lock.
      br-parts:refresh() in frame {&frame-name}.
      run display-parts-info in this-procedure .
      apply "entry":u to br-parts.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-vsd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-vsd Dialog-Frame
ON CHOOSE OF b-vsd IN FRAME Dialog-Frame /* АлкАтр */
  DO:
    { gbl/stdbtn.i }
    define variable ii as integer no-undo.
    define variable isSave as logical no-undo.
    define variable keyrecObj as class keyrec no-undo.
    define variable keypart as character no-undo.
    if not available parts then 
    do: 
      message 
        "Нет партий по товару"
        view-as alert-box.
      return no-apply.
    end.
    vsdStorageObj = new vsdtostorage ().
    vsdSts = new vsdstatustype ().
    keyrecObj = new keyrec ().
    keyrecObj:GenKeyRec({&table_parts}, buffer parts:handle, output keypart).
    vsdsubsObj = vsdStorageObj:getVSDsubs(input "part-key", input keypart).
    
    if vsdsubsObj:iCounter = 0
    then do:
      if p-edit-mode = {&lookup}
      and not (v-vozvr-perem-no-fact and p-doc-code = ub.parts.out-code)
      and not (v-ext-mode = "vsd_corr-parts" or v-ext-mode = "vsd")
      then do:
        message "К партии отсутсвуют ВСД" view-as alert-box.
        return.
      end.
      vsdsubObj = new vsdsub ().
      vsdsubsObj:AddItem(vsdsubObj).
      vsdsubObj = vsdsubsObj:VsdObjCurr.
      vsdsubObj:VSDType = vsdSts:VSDIn.
      vsdsubObj:PartKey = keypart.
      vsdsubObj:GdsCode = p-gds-code.
      vsdsubObj:ObjType = v-obj-type.
      vsdsubObj:ObjCode = v-obj-code.
      find first buf_trn no-lock where buf_trn.doc-code = p-doc-code.
      if available (buf_trn)
      then do:
        vsdsubObj:CliCode = buf_trn.cli-code.
        vsdsubObj:CliType = buf_trn.cli-type.
      end.
    end.
    run str/vsd.w (input parparentproc, input {&update}, input vsdsubsObj, output isSave).
    if isSave then do:
      do ii = 1 to vsdsubsObj:GetItem(ii):
        vsdsubObj = vsdsubsObj:VsdObjCurr.
        if vsdsubObj:Changed
        then do: 
          case true:
            when vsdsubObj:ID > 0 then do:
              vsdStorageObj:updateDB(vsdsubObj).
            end.
            otherwise do:
              vsdStorageObj:insertDB(vsdsubObj).
            end.
          end.
        end.
      end.
    end.
    delete object keyrecObj no-error.
    delete object vsdsubsObj no-error.
    find current parts no-lock.
    br-parts:refresh() in frame {&frame-name}.
    run display-parts-info in this-procedure .
    apply "entry":u to br-parts.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-b-alt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-b-alt Dialog-Frame
ON CHOOSE OF b-b-alt IN FRAME Dialog-Frame /* Коды */
DO:
  { gbl/stdbtn.i }

  if available parts
  then do:
    define variable v-b-code like ub.bar-code.b-code no-undo .
    { gbl/partbcod.i
      parts
      v-b-code
    }
    run ref/alt-bc.w
      (
       input parparentproc
      ,input v-obj-type
      ,input v-obj-code
      ,input v-b-code
      ).
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  { gbl/stdbtn.i }
  do
  on error undo, return no-apply
  on stop  undo, return no-apply
  :

    if available parts
    then do:
      if p-doc-code = ""
      then do:
        message
          "Редактирование партий возможно только в интерфейсе документа"
          view-as alert-box .
        return no-apply .
      end.
      if v-reserv-pl-code = ?
      then do:
        message
          "Неизвестно место складирования товара. Редактирование партий невозможно."
          view-as alert-box .
        return no-apply .
      end.
      assign
        v-prt-rec = recid(parts)
      .
      run str/parts-f.w
        (input        parparentproc  /* parparentproc    */
        ,input        this-procedure /* h-call-prog      */
        ,input        {&update}      /* p-mode           */
        ,input        p-doc-code     /* p-doc-code       */
        ,input        p-gds-code     /* p-gds-code       */
        ,input        v-pl-code      /* p-pl-code        */
        ,input-output v-prt-rec      /* p-parts-recid    */
        ).
    end.
    else do:
      message
        "Неправильно выбрана строка"
        view-as alert-box .
      return no-apply.
    end.
  end.

  run reopen-query .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-contract Dialog-Frame
ON CHOOSE OF b-contract IN FRAME Dialog-Frame /* b-contract */
DO:
  { gbl/stdbtn.i }
  run show-contract-code in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  { gbl/stdbtn.i }

  define variable lok as logical no-undo .

  do
  on stop undo, return no-apply
  :
    if del-list = ""
    then do:
      /* удаление 1 строки */
      if not available parts
      then do:
        message
          "Неправильный выбор партии."
          view-as alert-box .
        return no-apply.
      end.
      if parts.in-code = parts.out-code
        and v-is-petrol = yes
        and v-is-pieces = no
      then do:
        message
          "Во внешнем приходе топливо нельзя редактировать через партии" skip
        view-as alert-box information .
        return no-apply .
      end.

      lok = no.
      message
        "Удалить партию?" SKIP
        "Вы уверены?"
        view-as alert-box question
        buttons OK-Cancel
        update lok.
      if lok <> true
      then do:
        return no-apply.
      end.
      assign
        v-prt-rec = recid(parts)
        del-list  = string(recid(parts))
      .
      /* ищем партию, на которую можно будет спозиционироваться после удаления */
      /* сначала пробуем встать на следующую */
      get next br-parts.
      if available parts
      then do:
        assign
          v-prt-rec = recid (parts)
        .
      end.
      else do:
        /* если это последняя партия, то встаем на предыдущую */
        reposition br-parts to recid v-prt-rec no-error.
        get prev br-parts.
        assign
          v-prt-rec = recid(parts)
        .
      end.
    end.
    else do:
      /* удаление отмеченных строк */
      lok = no.
      message
        "УДАЛИТЬ ВСЕ ОТМЕЧЕННЫЕ партии?" skip
        "Вы уверены?"
        view-as alert-box question
        buttons OK-Cancel
        update lok.
      if lok <> true
      then do:
        return no-apply.
      end.
      assign
        v-prt-rec = ?
      .
    end.

    define variable lns-cnt as integer no-undo .

    do lns-cnt = 1 to num-entries (del-list):
      run delete-parts in this-procedure
        (input integer (entry (lns-cnt, del-list))
        ) no-error .
    end.

    run reopen-query .

    if b-add:sensitive
    then do:
      apply "entry":u to b-add.
    end.
    else do:
      apply "entry":u to br-parts.
    end.
  end. /* on stop */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-doc Dialog-Frame
ON CHOOSE OF b-doc IN FRAME Dialog-Frame /* Документ */
DO:
  { gbl/stdbtn.i }
  if p-call-point = {&parts-l_call-document}
  then do:
    message
      "Для просмотра документа, к которому относится партия, нажмите Выход."
      view-as alert-box .
  end.
  else do:
    if available parts
    then do:
      if parts.out-code = {&free-code}
      then do:
        message
          "Партии свободной зоны не привязаны к документам"
          view-as alert-box .
        return .
      end.
      if parts.out-code = {&output-code}
      then do:
        message
          "Партии расходной зоны не привязаны к документам"
          view-as alert-box .
        return .
      end.

      /* Показать складской документ или документ переоценки */
      run str/showdoc.p
        (input parparentproc      /* parparentproc */
        ,input ub.parts.out-code  /* p-doc-code    */
        ,input ub.parts.artic     /* p-artic       */
        ,input ub.parts.prod-type /* p-prod-type   */
        ,input ub.parts.prod-code /* p-prod-code   */
        ,input ?                  /* p-doc-type    */
        ).
    end.
  end.
  apply "entry":u to br-parts in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  { gbl/stdbtn.i }
  if v-ext-mode = "vsd_corr-parts"
  or v-ext-mode = "corr-parts"
  then do :
    define buffer buf_doc-line for ub.doc-line .
    define buffer buf_trn-doc for ub.trn-doc .
    define buffer buf_goods for ub.goods .
    define buffer doc_parts for ub.parts .
    find first buf_goods no-lock where buf_goods.gds-code = p-gds-code .
    find first buf_trn-doc no-lock where buf_trn-doc.doc-code = p-doc-code .
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = buf_goods.artic
        and buf_doc-line.prod-type = buf_goods.prod-type
        and buf_doc-line.prod-code = buf_goods.prod-code
    .
    v-sum-parts-qnty = 0 .
    for each doc_parts no-lock where doc_parts.out-code = buf_trn-doc.doc-code
                                 and doc_parts.obj-type = v-cntxt-obj-type
                                 and doc_parts.obj-code = v-cntxt-obj-code
                                 and doc_parts.artic = buf_goods.artic
                                 and doc_parts.prod-type = buf_goods.prod-type
                                 and doc_parts.prod-code = buf_goods.prod-code
    :
      v-sum-parts-qnty = v-sum-parts-qnty + doc_parts.fact-qnty .
    end .
    if buf_doc-line.fact-qnty <> v-sum-parts-qnty
    then do :
      message substitute("Сумма количеств по партиям документа &1 не равна фактическому количеству по строке &2 .", v-sum-parts-qnty, buf_doc-line.fact-qnty) skip
              "Скорректируйте количество по партиям."
      view-as alert-box .
      return no-apply .
    end .
  end .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-in
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-in Dialog-Frame
ON CHOOSE OF b-in IN FRAME Dialog-Frame /* ПН */
DO:
  { gbl/stdbtn.i }
  run show-in-code in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-income-in-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-income-in-code Dialog-Frame
ON CHOOSE OF b-income-in-code IN FRAME Dialog-Frame /* Внеш.ПН */
DO:
  { gbl/stdbtn.i }
  run show-income-in-code in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  if available parts
  then do:
    do
    on error undo, return no-apply
    on stop undo, return no-apply
    :
      assign
        v-prt-rec = recid(parts)
      .
      if p-doc-code <> ""
      then do:
        if v-reserv-pl-code = ?
        then do:
          message
            "Неизвестно место складирования товара. Просмотр партий невозможен."
            view-as alert-box .
          return no-apply .
        end.
        run str/parts-f.w
          (input        parparentproc  /* parparentproc    */
          ,input        this-procedure /* h-call-prog      */
          ,input        {&lookup}      /* p-mode           */
          ,input        p-doc-code     /* p-doc-code       */
          ,input        p-gds-code     /* p-gds-code       */
          ,input        v-pl-code      /* p-pl-code        */
          ,input-output v-prt-rec      /* p-parts-recid    */
          ).
      end.
      else do:
        /* позволяем просматривать партии документов */
        define buffer buf_trn-doc for ub.trn-doc .
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = parts.out-code
          no-error .
        if available buf_trn-doc
        then do:
          run str/parts-f.w
            (input        parparentproc  /* parparentproc    */
            ,input        this-procedure /* h-call-prog      */
            ,input        {&lookup}      /* p-mode           */
            ,input        buf_trn-doc.doc-code /* p-doc-code       */
            ,input        p-gds-code     /* p-gds-code       */
            ,input        v-pl-code      /* p-pl-code        */
            ,input-output v-prt-rec      /* p-parts-recid    */
            ).
        end.
        else do:
          message
            "Можно просматривать только архивные партии и" skip
            "партии, зарезервированные за документами" skip
            view-as alert-box information .
        end.
      end.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
  { gbl/stdbtn.i }
  if not available parts
  then do:
    message
      "Неправильный выбор партии."
      view-as alert-box .
    return no-apply.
  end.

  define variable v-parts-recid as character no-undo .
  assign
    v-parts-recid = string (recid (parts))
  .

  if lookup( v-parts-recid, del-list ) > 0
  then do:
    assign
      del-list = diff-list(del-list, v-parts-recid, "" )
    .
    disp "" @ mark with browse br-parts.
  end.
  else do:
    assign
      del-list = add-list(del-list, v-parts-recid, "" )
    .
    disp "*" @ mark with browse br-parts.
  end.

  define variable lok as logical no-undo .
  lok = br-parts:select-next-row ().
  apply "entry":u to br-parts in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-marking
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-marking Dialog-Frame
ON CHOOSE OF b-marking IN FRAME Dialog-Frame /* Марки */
DO:
  { gbl/stdbtn.i }

define variable p-mode as char no-undo.
define variable vGtin       as character no-undo.
define variable vGtinQnty   as integer   no-undo.

p-mode = {&lookup}.

if not available parts then do: 
    message 
    "Нет партий по товару"
    view-as alert-box.
    return no-apply.
end.
define buffer buf_goods for ub.goods .
define buffer buf_marking-lines for ub.marking-lines .
define buffer buf_marking-lines-parent for ub.marking-lines .
define buffer buf_marking for ub.marking .
 
find first buf_goods no-lock where buf_goods.artic = parts.artic and buf_goods.prod-code = parts.prod-code and buf_goods.prod-type = parts.prod-type no-error .
if available (buf_goods) then do:
    for each buf_marking-lines no-lock where buf_marking-lines.gds-code = buf_goods.gds-code and 
                                             buf_marking-lines.in-code = parts.in-code and 
                                             buf_marking-lines.out-code = parts.out-code and
                                             buf_marking-lines.prt-code = parts.prt-code and 
                                             buf_marking-lines.part-code = parts.part-code and
                                             buf_marking-lines.obj-code = parts.obj-code and
                                             buf_marking-lines.obj-type = parts.obj-type:
      find first buf_marking no-lock where buf_marking.mark = buf_marking-lines.mark no-error .
      if available buf_marking
      then do :
        if buf_marking.box-qnty = 0 then
        do:
          vGtin     = getGtinByDM(buf_marking.mark) .
          vGtinQnty = getQntyCodeByGtin(vGtin).
        end.
        else
          vGtinQnty = buf_marking.box-qnty.
      
        create tt-marking-lines .
        assign
          tt-marking-lines.stts        = StatusTHName(buf_marking.sts)
          tt-marking-lines.gds-name    = buf_goods.gds-name
          tt-marking-lines.mark        = buf_marking.mark
          tt-marking-lines.mark-parent = buf_marking.mark-parent
          tt-marking-lines.gds-code    = buf_marking-lines.gds-code
          tt-marking-lines.sts         = buf_marking.sts 
          tt-marking-lines.unit        = buf_marking.unit
          tt-marking-lines.unit-ext    = buf_marking.unit-ext
          tt-marking-lines.box-qnty    = vGtinQnty
          tt-marking-lines.doc-level   = buf_marking-lines.doc-level
          tt-marking-lines.in-code     = parts.in-code
          tt-marking-lines.out-code    = parts.out-code
          tt-marking-lines.obj-code    = parts.obj-code
          tt-marking-lines.obj-type    = parts.obj-type
          tt-marking-lines.prt-code    = parts.prt-code
        .
        if buf_marking.sts = 10
        then do:
          if buf_marking.mark-parent <> ""
          then do :
            find first buf_marking-lines-parent no-lock where buf_marking-lines-parent.mark = buf_marking.mark-parent
                                                          and buf_marking-lines-parent.gds-code = buf_marking-lines.gds-code
                                                          and buf_marking-lines-parent.obj-type = buf_marking-lines.obj-type
                                                          and buf_marking-lines-parent.obj-code = buf_marking-lines.obj-code
                                                          and buf_marking-lines-parent.in-code  = buf_marking-lines.in-code
                                                          and buf_marking-lines-parent.out-code = buf_marking-lines.out-code
                                                          and buf_marking-lines-parent.part-code = buf_marking-lines.part-code
                                                          and buf_marking-lines-parent.prt-code = buf_marking-lines.prt-code 
                                                          and buf_marking-lines-parent.doc-level > 0
                                                          no-error .
            if available buf_marking-lines-parent
            then do :
              tt-marking-lines.doc-level = 2 .
            end .
            else do :
              tt-marking-lines.doc-level = 1 .
            end .
          end .
          else tt-marking-lines.doc-level = 1 .  
        end.
      end.
      else do :
        create tt-marking-lines .
        assign
          tt-marking-lines.gds-name    = buf_goods.gds-name
          tt-marking-lines.mark        = buf_marking-lines.mark
          tt-marking-lines.gds-code    = buf_marking-lines.gds-code
          tt-marking-lines.doc-level   = buf_marking-lines.doc-level
          tt-marking-lines.box-qnty    = 1
          tt-marking-lines.in-code     = parts.in-code
          tt-marking-lines.out-code    = parts.out-code
          tt-marking-lines.obj-code    = parts.obj-code
          tt-marking-lines.obj-type    = parts.obj-type
          tt-marking-lines.sts         = 13
          tt-marking-lines.prt-code    = parts.prt-code
        .
        tt-marking-lines.stts        = StatusTHName(tt-marking-lines.sts) .
      end .
    end.
end.
      run str/mark_browse.w (input parparentproc,
        input-output table tt-marking-lines,
        input "",
        input "Марки по: " + "По партии №" + string (parts.part-code) + " по товару - " + string(buf_goods.gds-code) + " " + string (buf_goods.gds-name),
        input 0,
        input ""
        ) no-error .
        empty temp-table tt-marking-lines .
        
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-pl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-pl Dialog-Frame
ON CHOOSE OF b-pl IN FRAME Dialog-Frame /* Место */
DO:
  { gbl/stdbtn.i }
  if available parts
  then do:
    run str/pl-lkp.w
      (
       input parparentproc
      ,input recid(parts)
      ) .
    display parts.pl-code with browse {&browse-name} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
  do
  on error undo, return no-apply
  on stop undo,  return no-apply
  :
    apply "home":u to browse {&browse-name} .

    run partsxls.
/*      (input this-procedure :handle /* p-handle-callback */*/
/*      ) .                                                  */
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
  { gbl/stdbtn.i }

  define variable v-ok as logical no-undo .
  assign
    v-ok = false
  .
  if v-data-changed = true
  then do:
    message
      "Данные были изменены" skip
      "Вы действительно хотите отказаться от ВСЕХ изменений" skip
      "с момента последнего открытия окна партий?" skip
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok <> true
    then do:
      return no-apply .
    end.
  end.

  if  v-need-check-diff-qnty = true
  and v-chg-qnty <> 0
  then do:
    message
      "Необходимо создать партии с общим количеством" v-chg-qnty skip
      "Отказ от редактирования партий приведет к тому," skip
      "что не будет зарезервировано необходимое количество товара" skip
      "Вы действительно хотите отказаться от редактирования партий?"
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok <> true
    then do:
      return no-apply .
    end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  { gbl/stdbtn.i }

/* Список полей не включенных в фильтр в настоящее время, которые возможно
   можно включить в дальнейшем
  SLT-pc
  SLT-type
  VAT-pc
  VAT-type

  artic
  prod-code
  prod-type

  cli-base-rate
  cli-qnty
  fact-num
  host-code
  rsrv-free
  PS
*/

  do on stop undo, leave:
    run init-flt in this-procedure .
    run gbl/filter.w (INPUT parparentproc, filter-point, tbl, join-tbl, fld, lab, spr, dim).
    run reopen-query .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор  */
DO:
  { gbl/stdbtn.i }

  if available parts
  then do:
    assign
      part-recid = recid( parts )
    .
  end.
  else do:
    assign
      part-recid = ?
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-parts
&Scoped-define SELF-NAME br-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-parts Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-parts IN FRAME Dialog-Frame
DO:
  if b-chg:sensitive then apply "choose" to b-chg in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-parts Dialog-Frame
ON RETURN OF br-parts IN FRAME Dialog-Frame
DO:
  if b-chg:sensitive then apply "choose" to b-chg in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-parts Dialog-Frame
ON ROW-DISPLAY OF br-parts IN FRAME Dialog-Frame
DO:
  if parts.defect = logical({&FiB}) then do:
     parts-part-code:bgcolor in browse {&browse-name} = 12.
  end.
  else do:
     parts-part-code:bgcolor in browse {&browse-name} = ? .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-parts Dialog-Frame
ON VALUE-CHANGED OF br-parts IN FRAME Dialog-Frame
DO:
  run display-parts-info .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed-notes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed-notes Dialog-Frame
ON ENTRY OF ed-notes IN FRAME Dialog-Frame
DO:
  if not available parts
  then do:
    message
      "Неправильный выбор партии."
      view-as alert-box .
    return no-apply.
  end.
  assign
    v-prt-rec = recid (parts)
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed-notes Dialog-Frame
ON LEAVE OF ed-notes IN FRAME Dialog-Frame
DO:
  define buffer buf_parts for ub.parts .
  do on stop undo, return no-apply:
    find buf_parts where recid (buf_parts) = v-prt-rec exclusive-lock.
    buf_parts.PS = input frame {&frame-name} ed-notes.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed-notes Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF ed-notes IN FRAME Dialog-Frame
DO:
  apply "entry":u to br-parts in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed-notes Dialog-Frame
ON RETURN OF ed-notes IN FRAME Dialog-Frame
DO:
  apply "entry":u to br-parts in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-find
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-find Dialog-Frame
ON VALUE-CHANGED OF R-find IN FRAME Dialog-Frame
DO:
  ASSIGN r-find .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-one-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-one-all Dialog-Frame
ON VALUE-CHANGED OF rs-one-all IN FRAME Dialog-Frame
DO:
  if available parts
  then do:
    assign
      v-prt-rec = recid(parts)
    .
  end.
  assign rs-one-all .
  run reopen-query .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-parts Dialog-Frame
ON VALUE-CHANGED OF rs-parts IN FRAME Dialog-Frame
DO:
  if available parts
  then do:
    assign
      v-prt-rec = recid(parts)
    .
  end.
  if input frame {&frame-name} rs-parts = {&parts-l_parts-document}
  and p-call-point = {&reference}
  then do:
    message
      "Нет документа"
      view-as alert-box .
    display
      rs-parts
      with frame {&frame-name}.
    return no-apply.
  end.

  assign
    rs-parts
  .
  run reopen-query .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME s-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL s-code Dialog-Frame
ON RETURN OF s-code IN FRAME Dialog-Frame
DO:
  define variable v-find-next as logical   no-undo .

  if s-code <> input frame {&frame-name} s-code
  then do:
    assign
      v-find-next = false
    .
  end.
  else do:
    assign
      v-find-next = true
    .
  end.

  do with frame {&frame-name}:
    assign
      s-code
    .
  end. /* do with frame */

  define buffer buf_bar-code for ub.bar-code .
  define buffer buf_goods    for ub.goods    .
  define buffer buf_parts    for ub.parts    .
  if  r-find = 2 then do:
      find first buf_bar-code no-lock
        where buf_bar-code.b-code = int( s-code)
        no-error .
      if available buf_bar-code
      then do:
        find first buf_goods no-lock
          where buf_goods.gds-code = buf_bar-code.gds-code
          .
        if buf_bar-code.gds-code <> p-gds-code
        then do:
          message
            "Бар-код" buf_bar-code.b-code skip
            "Вы задали бар-код партии для другого товара" skip
            "Вы просматриваете партии товара с кодом" p-gds-code skip
            "Вы задали бар-код товара с кодом" buf_bar-code.gds-code skip
            "и артикулом" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
            view-as alert-box .
          return no-apply .
        end.

        run UI-on in this-procedure
          (input false /* p-open-query */
          ,input v-find-next  /* p-find-next  */
          ,input substitute("and parts.in-code = '&1' and parts.part-code = '&2'"
          , buf_bar-code.in-code
          , buf_bar-code.part-code)
          ).
        apply "entry":u to self .
        return no-apply .
      end.

      message
        "Бар-код не найден !"
        view-as alert-box .

   end.
   else do:
           run UI-on in this-procedure
          (input false /* p-open-query */
          ,input v-find-next  /* p-find-next  */
          ,input substitute("and parts.part-code = '&1'"
          , s-code )
          ).
        apply "entry":u to self .
   end.
   return no-apply .
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
Marking = new mark() .
on f9 of frame {&frame-name} anywhere
do:
  run str/showgds.p
    (input parparentproc
    ,input this-procedure
    ,input p-gds-code /* p-gds-code */
    ,input {&lookup}  /* p-mode     */
    ) .
  return no-apply .
end.

{ gbl/hot-key.i b-add  }
{ gbl/hot-key.i b-chg  }
{ gbl/hot-key.i b-del  }
{ gbl/hot-key.i b-mark }

{ gbl/brwrepos.i
  &line-num=6
}
{ gbl/brwrefre.i }

{ gbl/getcntxt.i get }

{ gbl/setfltnm.i }

run check-input-parameters in this-procedure
  no-error .
if error-status :error
then do:
  if error-status :get-message(1) <> ""
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке входных параметров" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
  end.
  undo, return error return-value .
end.
define variable v-pharm  as logical   no-undo .
define variable v-attr-value as character no-undo .
define variable v-attr-type as character no-undo .

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
          { str/opharm.i v-cntxt-obj-type v-cntxt-obj-code v-attr-value }
       end.
      assign
        v-pharm = lookup(v-attr-value, "true,yes") > 0
      .
    end.


assign
  parts.qnty      :read-only in browse {&BROWSE-NAME} = true
  parts.fact-qnty :read-only in browse {&BROWSE-NAME} = true
  vprice-prod1 :visible   in browse {&BROWSE-NAME} = v-pharm
  vprice-prod2 :visible   in browse {&BROWSE-NAME} = v-pharm

.


ON alt-shift-F6 anywhere
do:
  if available parts
  then do:
    define variable v-parts-gds-code as integer   no-undo .
    { gbl/pargocod.i
      recid(parts)
      v-parts-gds-code
    }
    define buffer buf_parts-attr for ub.parts-attr .
    find first buf_parts-attr no-lock
      where buf_parts-attr.in-code   = parts.in-code
        and buf_parts-attr.gds-code  = v-parts-gds-code
        and buf_parts-attr.part-code = parts.part-code
      no-error .
    if available buf_parts-attr
    then do:
      run str/paratrsh.p
        (input recid(buf_parts-attr)
        ) .
    end.
  end.
end.

{ gbl/mv-clmn.i
  &frame-name = "{&frame-name}"
  &browse-name = "{&browse-name}"
  &table-name = "{&first-table-in-query-{&browse-name}}"
  &start-column = 4
  &ext-col = 22
}

&scop lll substitute('dynamic-function(&1get-in-code-dates&1,(recid(parts)))',~{&double-quote~})
&scop ll20 substitute('dynamic-function(&1get-price-sale&1,(recid(parts)))',~{&double-quote~})
&scop ll2 substitute('dynamic-function(&1get-contract-prn-code&1,(recid(parts)))',~{&double-quote~})
&scop ll21 substitute('dynamic-function(&1get-price-prod1&1,(recid(parts)))',~{&double-quote~})
&scop ll22 substitute('dynamic-function(&1get-price-prod2&1,(recid(parts)))',~{&double-quote~})


{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "parts-out-code"
  &sort-clmn_2    = "parts.qnty"
  &sort-clmn_3    = "parts.fact-qnty"
  &sort-clmn_4    = "parts.price-base"
  &sort-clmn_5    = "parts.price-rubl"
  &sort-clmn_6    = "parts.transport-base"
  &sort-clmn_7    = "parts.transport-rubl"
  &sort-clmn_8    = "parts.road-tax-base"
  &sort-clmn_9    = "parts.road-tax-rubl"
  &sort-clmn_10   = "parts.other-base"
  &sort-clmn_11   = "parts.other-rubl"
  &sort-clmn_12   = "parts.cst-code"
  &sort-clmn_13   = "parts.pl-code"
  &sort-clmn_14   = "parts-object"
  &sort-clmn_15   = "parts-part-code"
  &sort-clmn_17   = "parts.in-code"
  &label-clmn_18  = "'Дата ист.'"
  &sort-clmn_18   = get-in-code-dates(recid(parts))
  &dyn_sort-clmn_18   = "{&lll}"
  &label-clmn_19  = "'Договор'"
  &sort-clmn_19   = get-contract-prn-code(recid(parts))
  &dyn_sort-clmn_19   = "{&ll2}"
  &label-clmn_20 = "'Тек.прод.цена'"
  &sort-clmn_20   = get-price-sale(recid(parts))
  &dyn_sort-clmn_20   = "{&ll20}"
  &label-clmn_21 = "'Цена Произв.'"
  &sort-clmn_21   = get-price-prod1(recid(parts))
  &dyn_sort-clmn_21   = "{&ll21}"
  &label-clmn_22 = "'Цена Прзв_с_НДС'"
  &sort-clmn_22   = get-price-prod2(recid(parts))
  &dyn_sort-clmn_22   = "{&ll22}"
  &open-query     = "run reopen-query."
  &open-query-otherwise = "run reopen-query."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "no"
}


if p-edit-mode = "vsd_corr-parts"
or p-edit-mode = "vsd"
or p-edit-mode = "corr-parts"
then do :
  v-ext-mode = p-edit-mode .
  p-edit-mode = {&lookup} .
end .

if num-entries(p-call-point, {&delim-par}) = 2
then do :
  if entry(2, p-call-point, {&delim-par}) = "return"
  then do :
    v-is-return = yes .
  end .
  p-call-point = entry(1, p-call-point, {&delim-par}) .
end .
/* Название режима работы, отображаемое в заголовке */
assign
  v-mode-name = (if p-edit-mode = 'update-alc-attr':u
                 then "Корректировка алкогольных атрибутов"
                 else p-edit-mode
                )
.

if retry then do:
  message
    "Возникла ошибка при работе программы" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error return-value .
end.

{ gbl/gdscdat.i
  p-gds-code
  "'twounit=request':u"
  v-goods-twounit
  no-error
}
if error-status :error
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута товара gdscdat.i" skip
    "Атрибут товара" 'twounit=request':u skip
    "Код товара" p-gds-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error return-value .
end.
        
        
  RUN gds-attr-value (
                        INPUT p-gds-code,
                        INPUT {&attr-mark-type},
                        OUTPUT v-marking-value,
                        OUTPUT v-marking-type
                        ).

if not error-status:error and v-marking-value <> "" then 
  v-marking = true .
                    
    define variable v-alcohol-value as character no-undo .
    define variable v-alcohol-type  as character no-undo .
define variable v-alcohol-prod as logical.
    { gbl/conf-rd.i
      "'alcohol':u"
      "0"
      "''"
      0
      "''"
      "''"
      "''"
      no
      v-alcohol-value
      v-alcohol-type
      no-error
    }
    if  not error-status :error
    and lookup(v-alcohol-value, 'true,yes':u) > 0
    then do:
      { gbl/gdscdat.i
        p-gds-code
        "'alcohol-prod=request':u"
        v-alcohol-prod
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута товара" skip
          "Код товара" p-gds-code skip
          'alcohol-prod=request':u skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    else do:
      assign
        v-alcohol-prod = false
      .
    end.

    define variable v-mercury-value as character no-undo .
    define variable v-mercury-type  as character no-undo .
    define variable v-mercury-prod  as logical no-undo init false.
    define variable v-expense-return as logical no-undo init false .
    define buffer buf_trn-doc for ub.trn-doc .
    define buffer buf_doc-attr for ub.doc-attr .
    
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code no-error
      .
    for first buf_doc-attr no-lock where buf_doc-attr.doc-code = buf_trn-doc.doc-code
                                     and buf_doc-attr.attr-code = {&trdcattr-is-return}
    :
      if logical(buf_doc-attr.attr-value) then v-expense-return = yes .
    end .
    v-vozvr-perem-no-fact = false.
    if p-doc-code = ?
    or p-doc-code = ""
    or v-expense-return
    or (buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} or  buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem}  or  buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem})
    then do:
      { gbl/conf-rd.i
        "'mercuri':u"
        "'':u"
        "'':u"
        0
        "'':u"
        "'':u"
        "'':u"
        no
        v-mercury-value
        v-mercury-type
        no-error
      }
      if  not error-status :error
      and lookup(v-mercury-value, 'no':u) = 0
      then do:
        { gbl/gdscdat.i
          p-gds-code
          "'mercur_FGIS=request':u"
          v-mercury-prod
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении атрибута товара" skip
            "Код товара" p-gds-code skip
            'mercur_FGIS=request':u skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        if available (buf_trn-doc) and buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem} and buf_trn-doc.status_ <> {&fact}
        then  
          v-vozvr-perem-no-fact = true.
      end.
      else do:
        assign
          v-mercury-prod = false
        .
      end.
    

    
    end.


if  p-call-point = {&parts-l_call-document}
and (p-edit-mode = {&update}
     or p-edit-mode = {&add-def}
     or v-ext-mode = "vsd_corr-parts"
     or v-ext-mode = "corr-parts"
    )
then do:
  assign
    v-edit-parts = true
  .
  define variable v-rsrv-type as character no-undo .
  { gbl/rsrvtype.i
    p-doc-code
    v-rsrv-type
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении типа резервирования документа" skip
      "Документ" p-doc-code skip
      "Режим интерфейса" p-edit-mode skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    v-add-parts = false
  .
  case v-rsrv-type :
    when {&rsrvtype_pri-doc} or
    when {&rsrvtype_pri-fact}
    then do:
      assign
        v-add-parts = true
      .
    end.
    when {&rsrvtype_doc}
    then do:
      assign
        v-add-parts = true
      .
      if v-goods-twounit = true
      then do:
        /* партии на товары с двумя единицами измерения */
        /* нельзя создавать в обычных документах */
        assign
          v-add-parts = false
        .
      end.
    end.
  end.

  /* здесь имеется одно исключение при редактировании партий */
  /* для документа коррекции учетной цены нельзя добавлять и удалять партии */
  /* партии, которые были добавлены ранее нельзя изменять */
/*  define buffer buf_trn-doc for ub.trn-doc .        */
/*  find first buf_trn-doc no-lock                    */
/*    where buf_trn-doc.doc-code = p-doc-code no-error*/
/*    .                                               */
  if buf_trn-doc.ext-doc-type = {&TDEDT_Corr_Acc_Price}
  then do:
    assign
      v-add-parts = false
    .
  end.
end.
else do:
  assign
    v-edit-parts = false
  .
end.

if v-edit-parts = true
then do:
  /* режим редактирования - открываем транзакцию */
  TRANSACTION-MAIN-BLOCK:
  DO TRANSACTION
  ON ERROR   UNDO TRANSACTION-MAIN-BLOCK, LEAVE TRANSACTION-MAIN-BLOCK
  ON END-KEY UNDO TRANSACTION-MAIN-BLOCK, LEAVE TRANSACTION-MAIN-BLOCK
  :
    run main-block-procedure no-error .
    if error-status :error
    then do:
      if v-need-rsrv-gds
      then do:
        undo transaction-main-block, leave transaction-main-block .
      end.

           else do:
        undo, return error .
      end.
    end.
  END.
end.
else do:
  /* в режиме просмотра - не открываем транзакцию */
  MAIN-BLOCK:
  DO
  ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  :
    run main-block-procedure no-error .
    if error-status :error
    then do:
      undo MAIN-BLOCK, LEAVE MAIN-BLOCK .
    end.
  END.
end.

RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-input-parameters Dialog-Frame
PROCEDURE check-input-parameters :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  /* проверка входных параметров */

  define buffer buf_clients for ub.clients .
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_goods for ub.goods .

  do
  on error undo, return error
  :
    find first buf_clients no-lock
      where buf_clients.obj-type = v-obj-type
        and buf_clients.obj-code = v-obj-code
      no-error .
    if (not available buf_clients)
    or (lookup(v-obj-type, {&stock} + {&comma-char} + {&shop}) = 0)
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Ошибка задания объекта" skip
        "Объект" v-obj-type v-obj-code skip
        "Документ" p-doc-code skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if p-doc-code <> ""
    then do:
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = p-doc-code
        no-error .
      if not available buf_trn-doc
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не найден документ" skip
          "Объект" v-obj-type v-obj-code skip
          "Документ" p-doc-code skip
          "Код товара" p-gds-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.

    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден товар" skip
        "Объект" v-obj-type v-obj-code skip
        "Документ" p-doc-code skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    define variable ind                     as integer no-undo .
    define variable v-num-entries-p-r-parts as integer no-undo .

    if p-r-parts = ""
    or p-r-parts = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании параметров вызова резервирования" skip
        "Не задан параметр вызова p-r-parts." skip
        view-as alert-box error .
      undo, return error .
    end.

    assign
      v-need-reserv          = true
      v-need-check-diff-qnty = true
      v-chg-qnty             = 0
    .

    assign
      v-num-entries-p-r-parts = num-entries(p-r-parts)
    .

    do ind = 2 to v-num-entries-p-r-parts
    :
      define variable v-option       as character no-undo .
      define variable v-option-key   as character no-undo .
      define variable v-option-value as character no-undo .

      assign
        v-option = entry(ind, p-r-parts)
      .
      if v-option = ""
      or v-option = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при задании параметров вызова" skip
          "В качестве параметров резервирования задана пустая или неопределенная опция" skip
          "v-option" v-option skip
          "p-r-parts" p-r-parts skip
          view-as alert-box error .
        undo, return error .
      end.

      assign
        v-option-key = entry(1, v-option, "=" )
      .

      case v-option-key :
        when {&parts-l_parts-no-reserv}
        then do:
          assign
            v-need-reserv = false
          .
        end.
        when {&parts-l_parts-no-diff-check}
        then do:
          assign
            v-need-check-diff-qnty = false
          .
        end.
        when {&parts-l_parts-chg-qnty}
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания количества по резервированию необходимо указать строку" skip
              "" {&parts-l_parts-chg-qnty} + "=<plcode>" skip
              "v-option" v-option skip
              "p-r-parts" p-r-parts skip
              view-as alert-box error .
            undo, return error .
          end.
          assign
            v-chg-qnty = decimal(entry(2, v-option, "=" ))
          .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при задании параметров вызова резервирования" skip
            "Неизвестная опция." v-option skip
            "p-r-parts" p-r-parts skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.

    assign
      p-r-parts = entry(1, p-r-parts)
    .

    if lookup(p-r-parts
              , {&parts-l_parts-all}
              + {&comma-char} + {&parts-l_parts-rest}
              + {&comma-char} + {&parts-l_parts-free}
              + {&comma-char} + {&parts-l_parts-document}
             ) = 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании параметров вызова" skip
        "Недопустимый параметр вызова p-r-parts" skip
        "Значение p-r-parts:"  p-r-parts skip
        "Допустимые значения параметра"
              {&parts-l_parts-all} + {&comma-char} + {&parts-l_parts-rest}
              + {&comma-char} + {&parts-l_parts-free}
              + {&comma-char} + {&parts-l_parts-document} skip
        view-as alert-box error .
      undo, return error .
    end.

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE contract-code-to-str Dialog-Frame
PROCEDURE contract-code-to-str :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-contract-code     as integer   no-undo .
  define input  parameter p-obj-type          as character no-undo .
  define input  parameter p-obj-code          as integer   no-undo .
  define output parameter p-contract-code-str as character no-undo .

  define buffer buf_contract for ub.contract .

  define variable v-host-code as integer   no-undo .

  { gbl/hostcode.i
    p-obj-type
    p-obj-code
    v-host-code
  }

  find first buf_contract no-lock
    where buf_contract.host-code     = v-host-code
      and buf_contract.contract-code = p-contract-code
    no-error .
  if available buf_contract
  then do:
    assign
      p-contract-code-str = substitute('&1 &2 Вн.н. &3':u
                              ,buf_contract.contract-prn-code
                              ,string(buf_contract.contract-date, '99/99/9999':u)
                              ,buf_contract.contract-code
                              )
    .
  end.
  else do:
    if p-contract-code = 0
    then do:
      assign
        p-contract-code-str = ""
      .
    end.
    else do:
      assign
        p-contract-code-str = "?"
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-bar-code-parts Dialog-Frame
PROCEDURE create-bar-code-parts :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter   p-gds-code   as integer   no-undo .
define input  parameter   p-part-code  as character no-undo .
define input  parameter   p-in-code    as character no-undo .
define input  parameter   p-unit-base  as character no-undo .

define variable v-bar-code-is-new as logical   no-undo .
define variable v-root-node as integer   no-undo .
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_goods for ub.goods  .

find first buf_goods no-lock where  buf_goods.gds-code = p-gds-code no-error .
    { gbl/rootnode.i
      buf_goods.artic
      buf_goods.prod-type
      buf_goods.prod-code
      v-root-node
      no-error
    }

  { gbl/barcodcr.i
    p-gds-code
    v-root-node
    p-part-code
    p-in-code
    p-unit-base
    ?
    v-bar-code-is-new
    buf_bar-code
    no-error
  }


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE data-changed Dialog-Frame
PROCEDURE data-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  /* вызывается из программы parts-f.w */

  assign
    v-data-changed = true
  .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-parts Dialog-Frame
PROCEDURE delete-parts :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  /* вызывается из программы parts-f.w */

  define input parameter p-parts-recid as recid no-undo .

  run trg/partdel.p
    (input p-doc-code
    ,input p-parts-recid
    ) .

  run data-changed in this-procedure .

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-doc-line-info Dialog-Frame
PROCEDURE display-doc-line-info :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  /* показывает информацию, связанную с изменением строки накладной */
  /* TODO уточнить, какую информацию здесь необходимо показывать */
  /* она должна согласовываться с информацией, которая заводится при */
  /* редактировании партии */

  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_goods   for ub.goods .
  define buffer buf_doc-line for ub.doc-line .

  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
    .
  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error .
  find first buf_doc-line no-lock
    where buf_doc-line.doc-code  = buf_trn-doc.doc-code
      and buf_doc-line.artic     = buf_goods.artic
      and buf_doc-line.prod-type = buf_goods.prod-type
      and buf_doc-line.prod-code = buf_goods.prod-code
    no-error .
  if  available buf_trn-doc
  and available buf_doc-line
  then do:
    if buf_trn-doc.status_ = {&wayb}
    and buf_trn-doc.flag_ = no
    then do:
      display
        (buf_doc-line.doc-qnty + v-chg-qnty) @ FI_doc-line_doc-qnty
        with frame {&frame-name}.
    end.
    else do:
      display
        buf_doc-line.doc-qnty  @ FI_doc-line_doc-qnty
        buf_doc-line.fact-qnty @ FI_doc-line_fact-qnty
        with frame {&frame-name}.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-parts-info Dialog-Frame
PROCEDURE display-parts-info :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_goods    for ub.goods .
  define buffer buf_clients  for ub.clients .
  define buffer buf_pay-type for ub.pay-type .
  define buffer buf_currency for ub.currency .
  define buffer buf_parts    for ub.parts .

  do with frame {&frame-name}:
    if available parts
    then do:
      find first buf_goods no-lock
        where buf_goods.artic     = parts.artic
          and buf_goods.prod-type = parts.prod-type
          and buf_goods.prod-code = parts.prod-code
        .

      find buf_clients no-lock
        where buf_clients.obj-type = parts.supp-type
          and buf_clients.obj-code = parts.supp-code
        no-error.
      if available buf_clients
      then do:
        display
          buf_clients.obj-name @ FI_obj-name
          buf_clients.obj-type @ FI_obj-type
          buf_clients.obj-code @ FI_obj-code
          with frame {&frame-name}.
      end.
      else do:
        display
          "?" @ FI_obj-name
          ""  @ FI_obj-type
          ""  @ FI_obj-code
          with frame {&frame-name}.
      end.

      display
        get-b-code(buffer parts) @ fi-b-code
        with frame {&frame-name} .

      find buf_pay-type no-lock
        where buf_pay-type.obj-code = parts.pay-code
        no-error.
      if available buf_pay-type
      then do:
        assign
          FI_pay-name :screen-value = buf_pay-type.obj-name
        .
      end.
      else do:
        assign
          FI_pay-name :screen-value = ""
        .
      end.

      find buf_currency no-lock
        where buf_currency.curr-code = parts.exch-code
        no-error.
      if available buf_currency
      then do:
        assign
          FI_currency_curr-abbr :screen-value = buf_currency.curr-abbr
        .
      end.
      else do:
        assign
          FI_currency_curr-abbr :screen-value = ""
        .
      end.

      define variable v-free-qnty      as decimal no-undo .
      define variable v-free-rsrv-qnty as decimal no-undo .
      define variable v-out-qnty       as decimal no-undo .
      define variable v-out-rsrv-qnty  as decimal no-undo .
      define variable v-income-qnty    as decimal no-undo .
      define variable v-income-qnty-fact    as decimal no-undo .

      assign
        v-free-qnty      = 0
        v-free-rsrv-qnty = 0
        v-out-qnty       = 0
        v-out-rsrv-qnty  = 0
        v-income-qnty    = 0
        v-income-qnty-fact    = 0
      .

      for each buf_parts no-lock
        where buf_parts.obj-type  = parts.obj-type
          and buf_parts.obj-code  = parts.obj-code
          and buf_parts.artic     = parts.artic
          and buf_parts.prod-type = parts.prod-type
          and buf_parts.prod-code = parts.prod-code
          and buf_parts.in-code   = parts.in-code
          and buf_parts.part-code = parts.part-code
          and buf_parts.status_   = no
          and buf_parts.rsrv-free = yes
      :
        if buf_parts.out-code = {&free-code}
        then do:
          assign
            v-free-qnty      = v-free-qnty + buf_parts.qnty
          .
        end.
        else do:
          assign
            v-free-rsrv-qnty = v-free-rsrv-qnty  + abs(buf_parts.qnty)
          .
        end.
      end.

      for each buf_parts no-lock
        where buf_parts.obj-type  = parts.obj-type
          and buf_parts.obj-code  = parts.obj-code
          and buf_parts.artic     = parts.artic
          and buf_parts.prod-type = parts.prod-type
          and buf_parts.prod-code = parts.prod-code
          and buf_parts.in-code   = parts.in-code
          and buf_parts.part-code = parts.part-code
          and buf_parts.status_   = no
          and buf_parts.rsrv-free = no
      :
        if buf_parts.out-code = {&output-code}
        then do:
          assign
            v-out-qnty      = v-out-qnty + buf_parts.qnty
          .
        end.
        else do:
          assign
            v-out-rsrv-qnty = v-out-rsrv-qnty + buf_parts.qnty
          .
        end.
      end.

      for each buf_parts no-lock
        where buf_parts.obj-type  = parts.obj-type
          and buf_parts.obj-code  = parts.obj-code
          and buf_parts.artic     = parts.artic
          and buf_parts.prod-type = parts.prod-type
          and buf_parts.prod-code = parts.prod-code
          and buf_parts.in-code   = parts.in-code
          and buf_parts.part-code = parts.part-code
          and buf_parts.out-code  = parts.in-code
          and buf_parts.doc-type  = {&income}
      :
        assign
          v-income-qnty    = v-income-qnty + buf_parts.qnty
          v-income-qnty-fact    = v-income-qnty-fact + buf_parts.fact-qnty
        .
      end.


      assign
        ed-notes          = parts.PS
        fi-free-qnty      = v-free-qnty
        fi-free-rsrv-qnty = v-free-rsrv-qnty
        fi-out-qnty       = v-out-qnty
        fi-out-rsrv-qnty  = v-out-rsrv-qnty
        fi-income-qnty    = v-income-qnty
        fi-income-qnty-fact = v-income-qnty-fact
      .

      define variable v-in-code-fact-date as date      no-undo .
      define buffer buf_trn-doc for ub.trn-doc .
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = ub.parts.in-code
        no-error .
      if available buf_trn-doc
      then do:
        /* дата закрытия приходного документа имеет приоритет */
        assign
          v-in-code-fact-date = buf_trn-doc.fact-date
        .
      end.
      else do:
        /* показываем дату фактического закрытия партии */
        assign
          v-in-code-fact-date = ub.parts.fact-date
        .
      end.

      define variable v-last-fact-date as character no-undo .

      if parts.last-date <> ?
      then do:
        assign
          v-last-fact-date = string(parts.last-date, '99/99/9999':u)
        .
      end.
      else do:
        assign
          v-last-fact-date = ""
        .
      end.

      assign
        FI_parts_orig-in-code   = ""
        FI_parts_orig-fact-date = ?
        FI_orig-purch-code      = ""
      .
      define variable v-gds-code       as integer   no-undo .

      { gbl/pargocod.i
        recid(parts)
        v-gds-code
      }

      define buffer buf_parts-attr for ub.parts-attr .
      find first buf_parts-attr no-lock
        where buf_parts-attr.in-code   = parts.in-code
          and buf_parts-attr.gds-code  = v-gds-code
          and buf_parts-attr.part-code = parts.part-code
        no-error .
      if available buf_parts-attr
      then do:
        assign
          FI_parts_orig-in-code   = buf_parts-attr.income-in-code
        .
        define buffer buf_income_parts-attr for ub.parts-attr .
        find first buf_income_parts-attr no-lock
          where buf_income_parts-attr.in-code   = buf_parts-attr.income-in-code
            and buf_income_parts-attr.gds-code  = buf_parts-attr.income-gds-code
            and buf_income_parts-attr.part-code = buf_parts-attr.income-part-code
          no-error .
        if available buf_income_parts-attr
        then do:
          assign
            FI_parts_orig-fact-date = buf_income_parts-attr.fact-date
          .
          run purch-code-to-str in this-procedure
            (input  buf_income_parts-attr.purch-code
            ,output FI_orig-purch-code
            ) .
        end.

        assign
          fi_unit_cli-abbr = buf_parts-attr.unit-cli
        .
      end.
      else do:
        assign
          FI_parts_orig-in-code   = '':u
          FI_parts_orig-fact-date = ?
          FI_orig-purch-code      = '':u
          fi_unit_cli-abbr        = buf_goods.unit-cli
        .
        if parts.in-code = parts.out-code
        then do:
          define buffer buf_doc-line for ub.doc-line .
          find first buf_doc-line no-lock
            where buf_doc-line.doc-code  = parts.out-code
              and buf_doc-line.artic     = parts.artic
              and buf_doc-line.prod-type = parts.prod-type
              and buf_doc-line.prod-code = parts.prod-code
            no-error .
          if available buf_doc-line
          then do:
            assign
              fi_unit_cli-abbr = buf_doc-line.unit-cli
            .
          end.
        end.
      end.

      display
        FI_parts_orig-in-code
        FI_parts_orig-fact-date
        FI_orig-purch-code
        fi_unit_cli-abbr
        parts.VAT-pc    @ FI_parts_VAT-pc
        parts.VAT-type  @ FI_parts_VAT-type
        parts.SLT-pc    @ FI_parts_SLT-pc
        parts.SLT-type  @ FI_parts_SLT-type
        parts.price-cli @ FI_parts_price-cli
        parts.cli-qnty  @ FI_parts_cli-qnty
        parts.cli-base-rate @ FI_parts_cli-base-rate
        get-purch-code(buffer parts) @ FI_purch-code
        get-contract-prn-code(recid(parts)) @ FI_contract-prn-code
        get-country-name(buffer parts) @ FI_country-name
        parts.in-code   @ FI_parts_in-code
        v-in-code-fact-date @ FI_parts_fact-date
        v-last-fact-date @ fi_last-date
        ed-notes
        fi-free-qnty
        fi-free-rsrv-qnty
        fi-out-qnty
        fi-out-rsrv-qnty
        fi-income-qnty
        fi-income-qnty-fact
        get-price-doc (recid(parts)) @ FI_price-doc
        with frame {&frame-name}.
        
      if v-expense-return
      then do :
        if parts.out-code = {&free-code}
        then do :
          disable b-vsd with frame {&frame-name}.
        end .
        else do :
          enable b-vsd with frame {&frame-name}.
        end .
      end .
    end.

  end. /* do with frame */

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
  DISPLAY rs-parts rs-one-all R-find s-code FI_doc-line_doc-qnty
          fi-label-filter-status FI_doc-line_fact-qnty FI_unit-base
          fi-label-filter-object fi-free-qnty fi-free-rsrv-qnty
          FI_orig-purch-code fi-income-qnty fi-income-qnty-fact fi-out-qnty
          fi-out-rsrv-qnty FI_last-date FI_price-doc FI_parts_cli-qnty
          FI_parts_cli-base-rate FI_parts_SLT-type FI_parts_SLT-pc
          FI_country-name FI_purch-code FI_contract-prn-code
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-mark b-sel b-lkp b-add b-chg b-del b-sch b-print
         b-help RECT-4 RECT-7 b-doc b-b-alt b-pl rs-parts rs-one-all R-find
         s-code br-parts b-income-in-code b-in b-contract FI_price-doc
      WITH FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-attr-chg-qnty Dialog-Frame
PROCEDURE get-attr-chg-qnty :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  /* позволяет запросить количество, запрошенное для резервирование */
  /* вызывается из процедуры parts-f.w */


  define output parameter p-chg-qnty as decimal   no-undo .

  assign
    p-chg-qnty = v-chg-qnty
  .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-sort-column-phrase Dialog-Frame
PROCEDURE get-sort-column-phrase :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-sort-column-name   as character no-undo .
  define output parameter p-sort-column-phrase as character no-undo .

  case p-sort-column-name :
    when ""
    then do:
      assign
        p-sort-column-phrase = ""
      .
    end.
    when "parts-out-code"
    then do:
      assign
        p-sort-column-phrase = "by parts.out-code"
      .
    end.
    when "parts-object"
    then do:
      assign
        p-sort-column-phrase = "by parts.obj-type by parts.obj-code"
      .
    end.
    when "parts-part-code"
    then do:
      assign
        p-sort-column-phrase = "by parts.part-code"
      .
    end.
    otherwise do:
      assign
        p-sort-column-phrase = "by " + p-sort-column-name
      .
    end.
  end case.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-flt Dialog-Frame
PROCEDURE init-flt :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/


  assign
    tbl = "parts"
    join-tbl = ""
  .

  run fltfield-clear in this-procedure(
  output fld, output lab, output spr, output dim)  no-error.

  run fltfield-add in this-procedure('in-code', 'Номер ПН', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('out-code', 'Статус', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('supp-type{&delim-flt}supp-code', 'Поставщик', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('part-code', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('status_', 'Закр', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('qnty', 'Кол.док.', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-qnty', 'Факт.кол.', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-date', 'Дата', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('pay-code', 'Код Оплаты', 'pay',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('doc-type', 'Тип Докум.', 'trn-type',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('price-base', 'Цена (вал)', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('price-rubl', 'Цена ({&abbr_rub})', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('price-cli', 'Цена пост. (вал)', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('exch-code', 'Валюта пост.', 'curr',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('is-supp', 'Поставка', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cst-code', 'ГТД', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('pl-code', 'Место', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE is-button-enabled Dialog-Frame
PROCEDURE is-button-enabled :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  /* вызывается из программы parts-f.w */


  define input parameter  p-button-name as character no-undo .
  define output parameter p-enable      as logical no-undo .

  do with frame {&frame-name}:
    case p-button-name :
      when "b-add":U
      then do:
        assign
          p-enable = b-add :sensitive
        .
      end.

      when "b-del":U
      then do:
        assign
          p-enable = b-del :sensitive
        .
      end.

    end case . /* p-button-name */
  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE main-block-procedure Dialog-Frame
PROCEDURE main-block-procedure :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error   undo , return error
  on end-key undo , return error
  :

    define variable v-road-tax-name as character no-undo .
    run tax-name in this-procedure
      (input  {&road-tax}
      ,output v-road-tax-name
      ) .
    assign
      parts.road-tax-base :label in browse {&browse-name} = v-road-tax-name + " (вал)"
      parts.road-tax-rubl :label in browse {&browse-name} = v-road-tax-name + " ({&abbr_rub})"
      parts.price-rubl :label in browse {&browse-name} = "Цена ({&abbr_rub})"
    .

    define buffer buf_goods for ub.goods .
    find buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден товар" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error .
    end.

    /* партии могут быть только у товаров */
    if buf_goods.gds-type <> {&gds-goods}
    then do:
      message
        "Просмотр партий возможен только для товаров"
        view-as alert-box information .
      undo, return error .
    end.

    { gbl/gdscdat.i
      buf_goods.gds-code
      "'alcohol-prod=request':u"
      v-goods-alcohol-prod
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно запросить признак товара" skip
        'alcohol-prod=request':U skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    { str/is-petrl.i
      buf_goods.artic
      buf_goods.prod-type
      buf_goods.prod-code
      v-is-petrol
      v-is-pieces
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно запросить признаки товара" skip
        'is-petrol и/или is-pieces':U skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    do with frame {&frame-name}
    :
      define variable v-part-part-code-width as integer   no-undo .

      if v-goods-alcohol-prod = true
      then do:
        assign
          v-part-part-code-width = 25
        .
      end.
      else do:
        assign
          v-part-part-code-width = 14
        .
      end.

      assign
        parts-part-code :resizable in browse {&browse-name} = true
        parts-part-code :width     in browse {&browse-name} = v-part-part-code-width
      .
    end.

    do with frame {&frame-name}
    :
      assign
        rs-one-all :radio-buttons = "Текущий объект" + {&comma-char} + {&parts-l_object-current}
            + {&comma-char} + "Все объекты" + {&comma-char} + {&parts-l_parts-all}
      .
      assign
        rs-parts :radio-buttons = "Все"  + {&comma-char} + {&parts-l_parts-all}
            + {&comma-char} + "Факт остатки"  + {&comma-char} + {&parts-l_parts-rest}
            + {&comma-char} + "Свободно"  + {&comma-char} + {&parts-l_parts-free}
            + (if p-doc-code <> ""
              then {&comma-char} + "Документ" + {&comma-char} + {&parts-l_parts-document}
              else ""
              )
      .
    end. /* do with frame */

    assign
      rs-parts   = p-r-parts
      rs-one-all = p-one-all
    .

    display
      rs-parts
      rs-one-all
      with frame {&frame-name}.

    if p-r-parts = {&parts-l_parts-document}
    then do:
      define buffer buf_trn-doc  for ub.trn-doc .
      define buffer buf_doc-line for ub.doc-line .

      find buf_trn-doc
        where buf_trn-doc.doc-code = p-doc-code
        no-error.
      find buf_doc-line
        where buf_doc-line.doc-code  = p-doc-code
          and buf_doc-line.artic     = buf_goods.artic
          and buf_doc-line.prod-type = buf_goods.prod-type
          and buf_doc-line.prod-code = buf_goods.prod-code
        no-error.
      if  available buf_trn-doc
      and available buf_doc-line
      then do:
        if  buf_trn-doc.doc-type = {&income}
        and buf_trn-doc.internal = false
        then do:
          assign
            v-reserv-pl-code = false
            v-pl-code        = 0
          .
        end.

        if v-edit-parts = true
        then do:
          define variable v-can-edit-inv-on as character no-undo .
          { gbl/trnat.i
            buf_trn-doc.doc-type
            buf_trn-doc.internal
            buf_trn-doc.discnt-type
            buf_trn-doc.status_
            buf_trn-doc.flag_
            buf_trn-doc.ext-doc-type
            "'can-edit-inv-on=request':u"
            v-can-edit-inv-on
            no-error
          }
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Невозможно запросить признак складского документа" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.

          if v-can-edit-inv-on <> "true":u
          then do:
            define variable v-inv-on as logical no-undo .

            /* проверяем, что можно создавать резервы для товара */
            /* это возможно, если отсутствуют документы инвентаризации */
            { gbl/gdsobjat.i
              buf_doc-line.obj-type
              buf_doc-line.obj-code
              buf_doc-line.artic
              buf_doc-line.prod-type
              buf_doc-line.prod-code
              "'inv-on=request':u"
              v-inv-on
              no-error
            }
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Невозможно запросить признаки товара на объекте" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            if v-inv-on = true
            then do:
              message
                "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
                "сейчас находится в инвентаризации" skip
                "Редактирование резервов невозможно" skip
                view-as alert-box .
              undo, return error .
            end.
          end.

          if v-reserv-pl-code = ?
          then do:
            run plgdsfnd in this-procedure
              (input  true                  /* p-chk-and-chs    */
              ,input  buf_doc-line.obj-type /* p-obj-type       */
              ,input  buf_doc-line.obj-code /* p-obj-code       */
              ,input  p-gds-code            /* p-gds-code       */
              ,output v-reserv-pl-code      /* p-reserv-pl-code */
              ,output v-pl-code             /* p-pl-code        */
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Невозможно определить место хранения для товара" skip
                "Объект"  buf_doc-line.obj-type buf_doc-line.obj-code skip
                "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
          end.
        end.
        else do:
          if v-reserv-pl-code = ?
          then do:
            { gbl/gdsobjat.i
              buf_doc-line.obj-type
              buf_doc-line.obj-code
              buf_doc-line.artic
              buf_doc-line.prod-type
              buf_doc-line.prod-code
              "'place-rsrv=request'"
              v-reserv-pl-code
              no-error
            }
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при определении атрибута товара на объекте" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
          end.

          if v-reserv-pl-code = true
          then do:
            assign
              v-reserv-pl-code = ?
            .
          end.
        end.

        if  p-call-point <> {&reference}
        and buf_trn-doc.status_ <> {&inquiry}
        and buf_trn-doc.ext-doc-type <> {&TDEDT_Spi_Prvo}
        and v-need-reserv = true
        and v-edit-parts = true
        then do:
          assign
            v-need-rsrv-gds = true
          .
        end.

        if v-reserv-pl-code = true
        then do:
          run trndocrs-pl-gds-request in this-procedure
            (input  buf_doc-line.doc-code  /* p-doc-code    */
            ,input  buf_trn-doc.doc-type   /* p-doc-type    */
            ,input  buf_doc-line.obj-type  /* p-obj-type    */
            ,input  buf_doc-line.obj-code  /* p-obj-code    */
            ,input  buf_doc-line.artic     /* p-artic       */
            ,input  buf_doc-line.prod-type /* p-prod-type   */
            ,input  buf_doc-line.prod-code /* p-prod-code   */
            ,input  "before":u             /* p-field-accum */
            ) .
        end.
        run rsrgdsck in this-procedure
          (input  buf_doc-line.doc-code     /* p-doc-code              */
          ,input  buf_trn-doc.doc-type      /* p-doc-type              */
          ,input  buf_doc-line.obj-type     /* p-obj-type              */
          ,input  buf_doc-line.obj-code     /* p-obj-code              */
          ,input  buf_doc-line.artic        /* p-artic                 */
          ,input  buf_doc-line.prod-type    /* p-prod-type             */
          ,input  buf_doc-line.prod-code    /* p-prod-code             */
          ,output v-free-parts-qnty         /* p-free-parts-qnty       */
          ,output v-free-parts-fact-qnty    /* p-free-parts-fact-qnty  */
          ,output v-free-parts-cli-qnty     /* p-free-parts-cli-qnty   */
          ,output v-free-parts-price-base   /* p-free-parts-price-base */
          ,output v-free-parts-price-rubl   /* p-free-parts-price-rubl */
          ,output v-out-parts-qnty          /* p-out-parts-qnty        */
          ,output v-out-parts-fact-qnty     /* p-out-parts-fact-qnty   */
          ,output v-out-parts-cli-qnty      /* p-out-parts-cli-qnty    */
          ,output v-out-parts-price-base    /* p-out-parts-price-base  */
          ,output v-out-parts-price-rubl    /* p-out-parts-price-rubl  */
          ) .

        if v-need-rsrv-gds
        then do:
          /* проверяем целостность товара */
          { gbl/gdscheck.i
            buf_doc-line.obj-type
            buf_doc-line.obj-code
            buf_doc-line.artic
            buf_doc-line.prod-type
            buf_doc-line.prod-code
            ?
            "''"
            no-error
          }
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при проверке целостности товара" skip
              "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
              "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box .
            undo, return error .
          end.
        end.

        if  buf_trn-doc.status_ = {&wayb}
        and buf_trn-doc.flag_ = no
        then do:
          display
            buf_doc-line.doc-qnty @ FI_doc-line_doc-qnty
            buf_goods.unit-base   @ FI_unit-base
            with frame {&frame-name}.
          hide
            FI_doc-line_fact-qnty
            in frame {&frame-name}.
        end.
        else do:
          display
            buf_doc-line.doc-qnty  @ FI_doc-line_doc-qnty
            buf_doc-line.fact-qnty @ FI_doc-line_fact-qnty
            buf_goods.unit-base    @ FI_unit-base
            with frame {&frame-name}.
        end.

        if buf_trn-doc.doc-type = {&inventory}
        then do:
          assign
            FI_doc-line_doc-qnty  :label = "Стало"
            FI_doc-line_fact-qnty :label = "Разница"
          .
        end.
      end.
    end.
    else do:
      hide
        FI_doc-line_doc-qnty
        FI_doc-line_fact-qnty
        in frame {&frame-name}.
    end.

    if v-edit-parts <> true
    then do:
      assign
        b-exit :label in frame {&frame-name} = "&Выход"
      .
    end.
    assign
    parts.transport-rubl:label in browse br-parts = "Трансп. ({&abbr_rub)}"
    parts.road-tax-rubl:label in browse br-parts = "Дор.налог ({&abbr_rub})"
    parts.other-rubl:label in browse br-parts = "Другое ({&abbr_rub})"
    .

    display
      fi-label-filter-status
      fi-label-filter-object
      with frame {&frame-name} .

    ENABLE
      b-exit
      b-quit when v-edit-parts = true
      b-lkp
      b-mark
      b-income-in-code b-b-alt
      b-pl
      b-print
      b-help
      r-find
      s-code
      br-parts
      b-in b-contract
      b-doc
      b-sch
      rs-parts when not v-is-return
      b-sel when (p-call-point = {&choose} or v-is-return)
      ed-notes
      rs-one-all
      b-alc-attr when v-alcohol-prod = yes
      b-vsd when v-mercury-prod = yes
      b-marking when v-marking = yes
      WITH FRAME {&frame-name}.

    assign
      v-prt-rec = ?
    .
    run reopen-query .

    VIEW FRAME Dialog-Frame.


    WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-parts .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE parts-show-income-in-code Dialog-Frame
PROCEDURE parts-show-income-in-code :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-parts-recid as recid     no-undo .

  define buffer buf_parts for ub.parts .
  define buffer buf_goods for ub.goods .

  define variable v-gds-code as integer   no-undo .

  define variable v-income-in-code   as character no-undo .
  define variable v-income-gds-code  as integer   no-undo .
  define variable v-income-part-code as character no-undo .
  define variable v-income-artic     as character no-undo .
  define variable v-income-prod-type as character no-undo .
  define variable v-income-prod-code as integer   no-undo .

  do
  on error undo, return error return-value
  :
    find first buf_parts no-lock
      where recid(buf_parts) = p-parts-recid
      no-error .
    if not available buf_parts
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильное задание входных параметров" skip
        "Не найдена партия" skip
        "Код партии" p-parts-recid skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    { gbl/pargocod.i
      p-parts-recid
      v-gds-code
    }
    define buffer buf_parts-attr for ub.parts-attr .
    find first buf_parts-attr no-lock
      where buf_parts-attr.in-code   = buf_parts.in-code
        and buf_parts-attr.gds-code  = v-gds-code
        and buf_parts-attr.part-code = buf_parts.part-code
      no-error .
    if available buf_parts-attr
    then do:
      assign
        v-income-in-code   = buf_parts-attr.income-in-code
        v-income-gds-code  = buf_parts-attr.income-gds-code
        v-income-part-code = buf_parts-attr.income-part-code
      .
      find first buf_goods no-lock
        where buf_goods.gds-code = v-income-gds-code
        no-error .
      if available buf_goods
      then do:
        assign
          v-income-artic     = buf_goods.artic
          v-income-prod-type = buf_goods.prod-type
          v-income-prod-code = buf_goods.prod-code
        .
      end.
      else do:
        assign
          v-income-artic     = ""
          v-income-prod-type = ""
          v-income-prod-code = 0
        .
      end.

      /* показать исходный документ, породивший партию */
      run str/showdoc.p
        (input parparentproc      /* parparentproc */
        ,input v-income-in-code   /* p-doc-code    */
        ,input v-income-artic     /* p-artic       */
        ,input v-income-prod-type /* p-prod-type   */
        ,input v-income-prod-code /* p-prod-code   */
        ,input true               /* p-doc-type    */
        ) .
    end.
    else do:
      message
        "Информация о внешней приходной накладной, создавшей данную партию, недоступна" skip
        view-as alert-box information .
    end.
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-get-country-name Dialog-Frame
PROCEDURE proc-get-country-name :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define parameter buffer buf_parts      for ub.parts .
  define output parameter p-country-name as character no-undo .

  define buffer buf_parts-attr for ub.parts-attr .
  define buffer buf_country    for ub.country .

  do
  on error undo, return error return-value
  :
    if available buf_parts
    then do:
      find first buf_parts-attr no-lock
        where buf_parts-attr.in-code   = buf_parts.in-code
          and buf_parts-attr.gds-code  = p-gds-code
          and buf_parts-attr.part-code = buf_parts.part-code
        no-error .
      if available buf_parts-attr
      then do:
        find first buf_country no-lock
          where buf_country.num-code = buf_parts-attr.country-code
          no-error .
        if not available buf_country
        then do:
          assign
            p-country-name = "XX Неизвестна"
          .
        end.
        else do:
          assign
            p-country-name = buf_country.alpha1 + " " + buf_country.short-name
          .
        end.
      end.
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE purch-code-to-str Dialog-Frame
PROCEDURE purch-code-to-str :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-purch-code     as integer   no-undo .
  define output parameter p-purch-code-str as character no-undo .

  { gbl/purchnam.i
    p-purch-code
    p-purch-code-str
  }

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reopen-query Dialog-Frame
PROCEDURE reopen-query :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  /* вызывается из программы parts-f.w */

  run UI-on in this-procedure
    (input true /* p-open-query     */
    ,input true /* p-find-next */
    ,input ""   /* p-find-condition */
    ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-parts Dialog-Frame
PROCEDURE reposition-parts :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  /* вызывается из программы parts-f.w */

  define input  parameter p-direction   as character no-undo .
  define output parameter p-parts-recid as recid no-undo .

  /* перемещение на первую, последнюю, предыдущую, следующую
     или на определенную запись по recid
   */
  if p-doc-code = ""
  then do:
    /* перемещение по партиям доступно только из интерфейса документа */
    message
      "Перемещение по партиям доступно только из интерфейса документа"
      view-as alert-box information .
    return .
  end.

  case p-direction :
    when "first":U
    then do:
      get first br-parts.
    end.
    when "last":U
    then do:
      get last br-parts.
    end.
    when "prev":U
    then do:
      get prev br-parts.
    end.
    when "next":U
    then do:
      get next br-parts.
    end.
    otherwise do:
      reposition br-parts to recid integer(p-direction) no-error .
    end.
  end case . /* p-direction */

  assign
    p-parts-recid = recid(parts)
  .
  run reposition-query in this-procedure
    (input p-parts-recid
    ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-query Dialog-Frame
PROCEDURE reposition-query :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define input parameter p-recid as recid no-undo .

  if p-recid <> ?
  then do:
    reposition br-parts to recid p-recid no-error.
  end.

  do with frame {&frame-name}:
    apply "entry":u to browse {&browse-name} .
  end. /* do with frame */

  run display-parts-info .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-changes Dialog-Frame
PROCEDURE save-changes :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-need-rsrv      as logical   no-undo .
  define variable v-doc-qnty-cli   as decimal   no-undo .
  define variable v-doc-qnty-base  as decimal   no-undo .
  define variable v-fact-qnty-cli  as decimal   no-undo .
  define variable v-fact-qnty-base as decimal   no-undo .
  define variable v-doc-density    as decimal   no-undo .
  define variable v-fact-density   as decimal   no-undo .
  define variable v-inv-rec        as recid     no-undo .

  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_goods    for ub.goods .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_parts    for ub.parts .
  define buffer buf_doc-pl   for ub.doc-pl .

  if v-edit-parts = true
  then do:
    do transaction
    on error undo, return error
    :
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = p-doc-code
        no-error .
      if not available buf_trn-doc
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не найден документ" skip
          "Документ" p-doc-code skip
          "Код товара" p-gds-code skip
          view-as alert-box error .
        undo, return error .
      end.

      find first buf_goods no-lock
        where buf_goods.gds-code = p-gds-code
        no-error .
      if not available buf_trn-doc
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не найден товар" skip
          "Документ" p-doc-code skip
          "Код товара" p-gds-code skip
          view-as alert-box error .
        undo, return error .
      end.

      find first buf_doc-line no-lock
        where buf_doc-line.doc-code  = buf_trn-doc.doc-code
          and buf_doc-line.artic     = buf_goods.artic
          and buf_doc-line.prod-type = buf_goods.prod-type
          and buf_doc-line.prod-code = buf_goods.prod-code
        no-error .
      if not available buf_doc-line
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найдена строка документа" skip
          "Документ" p-doc-code skip
          "Код товара" p-gds-code skip
          "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
          view-as alert-box error .
        undo, return error .
      end.

     /* Для ПН */
        for each buf_parts no-lock
          where buf_parts.out-code  = buf_trn-doc.doc-code
            and buf_parts.obj-type  = buf_doc-line.obj-type
            and buf_parts.obj-code  = buf_doc-line.obj-code
            and buf_parts.artic     = buf_doc-line.artic
            and buf_parts.prod-type = buf_doc-line.prod-type
            and buf_parts.prod-code = buf_doc-line.prod-code
        on error undo, return error return-value
        :
          if buf_parts.in-code = buf_parts.out-code then do:
             run create-bar-code-parts (
                  buf_goods.gds-code  ,
                  buf_parts.part-code ,
                  buf_parts.in-code   ,
                  buf_goods.unit-base ) no-error .
          end.
      end.

      if v-reserv-pl-code = true then do:
        run trndocrs-pl-gds-request in this-procedure
          (input  buf_doc-line.doc-code         /* p-doc-code    */
          ,input  buf_trn-doc.doc-type      /* p-doc-type    */
          ,input  buf_doc-line.obj-type         /* p-obj-type    */
          ,input  buf_doc-line.obj-code         /* p-obj-code    */
          ,input  buf_doc-line.artic            /* p-artic       */
          ,input  buf_doc-line.prod-type        /* p-prod-type   */
          ,input  buf_doc-line.prod-code        /* p-prod-code   */
          ,input  "after":u                /* p-field-accum */
          ) .
        run trndocrs-pl-gds-calc-rsrv in this-procedure .

        assign
          v-doc-density  = buf_doc-line.doc-density
          v-fact-density = buf_doc-line.fact-density
        .

        for each buf_doc-pl exclusive-lock
          where buf_doc-pl.out-code = buf_trn-doc.doc-code
            and buf_doc-pl.gds-code = buf_goods.gds-code
            and buf_doc-pl.obj-type = buf_doc-line.obj-type
            and buf_doc-pl.obj-code = buf_doc-line.obj-code
        on error undo, return error return-value
        :
          run trndocrs-pl-gds-accum in this-procedure
            (input buf_doc-pl.pl-code                                                     /* p-pl-code       */
            ,input 0.0                                                                    /* p-rsrv-qnty     */
            ,input ( if v-need-rsrv-gds = true then - buf_doc-pl.cli-doc-qnty else 0.0 )  /* p-cli-rsrv-qnty */
            ,input 0.0                                                                    /* p-fact-qnty     */
            ,input - buf_doc-pl.cli-fact-qnty                                             /* p-cli-fact-qnty */
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при изменении разрезервированных количеств trndocrs-pl-gds-accum" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          delete buf_doc-pl .
        end.
        for each buf_parts no-lock
          where buf_parts.out-code  = buf_trn-doc.doc-code
            and buf_parts.obj-type  = buf_doc-line.obj-type
            and buf_parts.obj-code  = buf_doc-line.obj-code
            and buf_parts.artic     = buf_doc-line.artic
            and buf_parts.prod-type = buf_doc-line.prod-type
            and buf_parts.prod-code = buf_doc-line.prod-code
        on error undo, return error return-value
        :
          if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
            and buf_trn-doc.status_ <> {&inquiry}
          then do:
            assign
              v-doc-density  = 1.0 / buf_parts.cli-base-rate
              v-fact-density = v-doc-density
            .
          end.

          find first buf_doc-pl exclusive-lock
            where buf_doc-pl.obj-type = buf_doc-line.obj-type
              and buf_doc-pl.obj-code = buf_doc-line.obj-code
              and buf_doc-pl.pl-code  = buf_parts.pl-code
              and buf_doc-pl.out-code = buf_trn-doc.doc-code
              and buf_doc-pl.gds-code = buf_goods.gds-code
            no-error .
          if not available buf_doc-pl then do:
            create buf_doc-pl.
            assign
              buf_doc-pl.obj-type     = buf_doc-line.obj-type
              buf_doc-pl.obj-code     = buf_doc-line.obj-code
              buf_doc-pl.pl-code      = buf_parts.pl-code
              buf_doc-pl.out-code     = buf_trn-doc.doc-code
              buf_doc-pl.gds-code     = buf_goods.gds-code
              buf_doc-pl.cli-qnty      = 0.0
              buf_doc-pl.doc-qnty      = 0.0
              buf_doc-pl.cli-doc-qnty  = 0.0
              buf_doc-pl.fact-qnty     = 0.0
              buf_doc-pl.cli-fact-qnty = 0.0
            .
          end.
          assign
            buf_doc-pl.cli-qnty      = buf_doc-pl.cli-qnty      + buf_parts.qnty / buf_parts.cli-base-rate
            buf_doc-pl.doc-qnty      = buf_doc-pl.doc-qnty      + buf_parts.qnty
            buf_doc-pl.cli-doc-qnty  = buf_doc-pl.cli-doc-qnty  + buf_parts.qnty * v-doc-density
            buf_doc-pl.fact-qnty     = buf_doc-pl.fact-qnty     + buf_parts.fact-qnty
            buf_doc-pl.cli-fact-qnty = buf_doc-pl.cli-fact-qnty + buf_parts.fact-qnty * v-fact-density

          .
        end. /* for each buf_parts */
        assign
          v-doc-qnty-cli   = 0.0
          v-doc-qnty-base  = 0.0
          v-fact-qnty-cli  = 0.0
          v-fact-qnty-base = 0.0
        .
        for each buf_doc-pl share-lock
          where buf_doc-pl.obj-type = buf_doc-line.obj-type
            and buf_doc-pl.obj-code = buf_doc-line.obj-code
            and buf_doc-pl.out-code = buf_trn-doc.doc-code
            and buf_doc-pl.gds-code = buf_goods.gds-code
        on error undo, return error return-value
        :
          assign
            v-doc-qnty-base  = v-doc-qnty-base  + buf_doc-pl.doc-qnty
            v-doc-qnty-cli   = v-doc-qnty-cli   + buf_doc-pl.cli-doc-qnty
            v-fact-qnty-base = v-fact-qnty-base + buf_doc-pl.fact-qnty
            v-fact-qnty-cli  = v-fact-qnty-cli  + buf_doc-pl.cli-fact-qnty
          .
          run trndocrs-pl-gds-accum in this-procedure
            (input buf_doc-pl.pl-code                                                   /* p-pl-code       */
            ,input 0.0                                                                  /* p-rsrv-qnty     */
            ,input ( if v-need-rsrv-gds = true then buf_doc-pl.cli-doc-qnty else 0.0 )  /* p-cli-rsrv-qnty */
            ,input 0.0                                                                  /* p-fact-qnty     */
            ,input buf_doc-pl.cli-fact-qnty                                             /* p-cli-fact-qnty */
            ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при изменении зарезервированных количеств trndocrs-pl-gds-accum" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.

        if v-is-petrol = true
          and v-is-pieces = false
        then do:
          assign
            buf_doc-line.cli-qnty     = v-doc-qnty-cli
            buf_doc-line.doc-density  = v-doc-qnty-cli  / v-doc-qnty-base
            buf_doc-line.fact-density = v-fact-qnty-cli / v-fact-qnty-base
          .
        end. /* petrol */
      end.
      run rsrgdsck in this-procedure
        (input  buf_doc-line.doc-code         /* p-doc-code              */
        ,input  buf_trn-doc.doc-type          /* p-doc-type              */
        ,input  buf_doc-line.obj-type         /* p-obj-type              */
        ,input  buf_doc-line.obj-code         /* p-obj-code              */
        ,input  buf_doc-line.artic            /* p-artic                 */
        ,input  buf_doc-line.prod-type        /* p-prod-type             */
        ,input  buf_doc-line.prod-code        /* p-prod-code             */
        ,output v-new-free-parts-qnty         /* p-free-parts-qnty       */
        ,output v-new-free-parts-fact-qnty    /* p-free-parts-fact-qnty  */
        ,output v-new-free-parts-cli-qnty     /* p-free-parts-cli-qnty   */
        ,output v-new-free-parts-price-base   /* p-free-parts-price-base */
        ,output v-new-free-parts-price-rubl   /* p-free-parts-price-rubl */
        ,output v-new-out-parts-qnty          /* p-out-parts-qnty        */
        ,output v-new-out-parts-fact-qnty     /* p-out-parts-fact-qnty   */
        ,output v-new-out-parts-cli-qnty      /* p-out-parts-cli-qnty    */
        ,output v-new-out-parts-price-base    /* p-out-parts-price-base  */
        ,output v-new-out-parts-price-rubl    /* p-out-parts-price-rubl  */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при просмотре зарезервированных партий" skip
          "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          error-status :get-message(1)
          return-value skip
          view-as alert-box .
        undo, return error .
      end.

      define variable v-chg-free-qnty as decimal no-undo .
      define variable v-chg-out-qnty  as decimal no-undo .

      assign
        v-chg-free-qnty = v-new-free-parts-fact-qnty - v-free-parts-fact-qnty
        v-chg-out-qnty  = v-new-out-parts-fact-qnty  - v-out-parts-fact-qnty
      .

      if v-need-rsrv-gds
      then do:
        run trg/rsrv-gds.p
          (input parparentproc
          ,buffer buf_doc-line    /* doc-line        */
          ,input  v-chg-free-qnty /* v-chg-free-qnty */
          ,input  v-chg-out-qnty  /* v-chg-out-qnty  */
          ,input table temp-trndocrs-gds-dtl-rsrv
          ,input table temp-trndocrs-pl-gds-rsrv
          ) no-error.
        if error-status :error
        then do:
          if error-status :get-message(1) <> ""
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Невозможно зарезервировать товар по признакам" skip
              "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
              "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box .
          end.
          undo, return error .
        end.

        /* проверяем целостность товара */
        { gbl/gdscheck.i
          buf_doc-line.obj-type
          buf_doc-line.obj-code
          buf_doc-line.artic
          buf_doc-line.prod-type
          buf_doc-line.prod-code
          ?
          "''"
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при проверке целостности товара" skip
            "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
            "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.

        define variable v-check-cli-qnty as logical no-undo .

        assign
          v-check-cli-qnty = (buf_trn-doc.doc-type = {&income}
                              and buf_trn-doc.internal = no
                              )
        .

        run trg/doclnchk.p
          (input buf_doc-line.doc-code
          ,input buf_doc-line.artic
          ,input buf_doc-line.prod-type
          ,input buf_doc-line.prod-code
          ,input v-check-cli-qnty
          ) no-error .
        if error-status :error
        then do:
          message
            /* vss-workfile vss-revision vss-description skip */
            "Проверка строки документа" skip
            "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
            "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box .
          undo, return error .
        end.
      end.
      else do:
        if v-need-check-diff-qnty = true
        then do:
          define variable v-diff-qnty as decimal   no-undo .
          assign
            v-diff-qnty = v-chg-qnty - (v-chg-free-qnty + v-chg-out-qnty)
          .
          if v-diff-qnty <> 0
          then do:
            message
              "Нужно создать партии с общим количеством" v-chg-qnty skip
              "Недостающее количество" v-diff-qnty skip
              view-as alert-box information .
            undo, return error .
          end.
        end.
      end.
      if v-reserv-pl-code = true
        and v-is-petrol = true
        and v-is-pieces = false
      then do:
        { str/corinvln.i
          buf_doc-line.doc-code
          buf_doc-line.artic
          buf_doc-line.prod-type
          buf_doc-line.prod-code
          0
          0
          "buf_doc-line.price-rubl / buf_doc-line.fact-density"
          "buf_doc-line.price-base / buf_doc-line.fact-density"
          v-fact-qnty-cli
          buf_doc-line.fact-density
          v-inv-rec
          no-error
        }
        if error-status :error
          or v-inv-rec = ?
        then do:
          undo, return error return-value .
        end.
     end. /* petrol */
     end. /* transaction */
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-contract-code Dialog-Frame
PROCEDURE show-contract-code :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define buffer buf_contract for ub.contract .
  define variable v-host-code as integer   no-undo .

  if available parts
  then do:
    if parts.contract-code = 0
    then do:
      message
        "У партии не задан договор" skip
        view-as alert-box information .
    end.
    else do:
      define variable v-recid as recid no-undo .

      { gbl/hostcode.i
        parts.obj-type
        parts.obj-code
        v-host-code
      }

      /* показать контракт */
      find first buf_contract no-lock
        where buf_contract.host-code     = v-host-code
          and buf_contract.contract-code = parts.contract-code
        no-error .
      if available buf_contract
      then do:
        assign
          v-recid = recid( buf_contract )
        .
        run str/sh-contr.p
          (input  parParentProc
          ,input v-recid
          ) .
      end.
      else do:
        message
          "Договор не найден" skip
          "Код фирмы" v-host-code skip
          "Код договора" parts.contract-code skip
          "Объект" parts.obj-type parts.obj-code skip
          "Артикул" parts.artic parts.prod-type parts.prod-code skip
          "Партия" parts.in-code parts.part-code skip
          "Резерв" parts.out-code skip
          view-as alert-box error .
      end.
    end.
  end.
  apply "entry":u to br-parts in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-in-code Dialog-Frame
PROCEDURE show-in-code :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  if available parts
  then do:
    /* показать складской документ */
    run str/showdoc.p
      (input parparentproc      /* parparentproc */
      ,input ub.parts.in-code   /* p-doc-code    */
      ,input ub.parts.artic     /* p-artic       */
      ,input ub.parts.prod-type /* p-prod-type   */
      ,input ub.parts.prod-code /* p-prod-code   */
      ,input true               /* p-doc-type    */
      ).
  end.
  apply "entry":u to br-parts in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-income-in-code Dialog-Frame
PROCEDURE show-income-in-code :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  if available parts
  then do:
    run parts-show-income-in-code in this-procedure
      (input recid(parts)
      ) .
    apply "entry":u to br-parts in frame {&frame-name}.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UI-on Dialog-Frame
PROCEDURE UI-on :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

define buffer buf_trn-doc for ub.trn-doc .

find first buf_trn-doc no-lock
  where buf_trn-doc.doc-code = p-doc-code
  no-error .

 define buffer buf_goods for ub.goods .
 find first buf_goods no-lock
   where buf_goods.gds-code = p-gds-code
   .

define variable v-query-was-opened as logical no-undo .

assign
  v-query-was-opened = false
.

define variable sort-column-phrase as character no-undo .

run get-sort-column-phrase in this-procedure
  (input  sort-column-name
  ,output sort-column-phrase
  ) .

assign
  del-list = ""
.
disable b-add b-chg b-del b-mark with frame {&frame-name}.


&scop flt-open-open-query open query br-parts for each parts no-lock

&scop flt-open-dyn_open-query  FOR EACH parts

&scop flt-open-query-handle query br-parts:handle

&scop flt-open-find-buffer-name parts


&scop flt-open-query-was-opened  v-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-debug-file

&scop flt-open-query p-open-query

&scop flt-open-table-name parts

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-prt-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-waitfram true

define variable v-open-query as logical   no-undo .

if rs-one-all = {&parts-l_object-all}
then do:
  define variable lok as logical no-undo .

  define variable v-host-code as integer   no-undo .
  { gbl/hostcode.i
    v-obj-type
    v-obj-code
    v-host-code
  }

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_parts_all':U
    {&cntxt-firm}
    v-host-code
    '':U
    0
    0
    0
    0
    true
    lok
  }
  if not lok
  then do:
    assign
      rs-one-all = {&parts-l_object-current}
      rs-one-all :screen-value = rs-one-all
    .
    MESSAGE "Нет права просмотра партий для всех объектов"
    VIEW-AS ALERT-BOX.
  end.
end.

case rs-one-all :
  when {&parts-l_object-all}
  then do:
    run ui-on-01 in this-procedure
      (input  p-open-query
      ,input  p-find-next
      ,input  p-find-condition
      ,input  sort-column-phrase
      ,input-output v-query-was-opened
      ,buffer buf_goods
      ,buffer buf_trn-doc
      ) .
  end.

  when {&parts-l_object-current}
  then do:
    run ui-on-02 in this-procedure
      (input  p-open-query
      ,input  p-find-next
      ,input  p-find-condition
      ,input  sort-column-phrase
      ,input-output v-query-was-opened
      ,buffer buf_goods
      ,buffer buf_trn-doc
      ) .
  end.
end. /* case rs-one-all */

/* если query не была переоткрыта -
   то выполняем открытие query так, чтобы не была доступна ни одна запись */
if v-query-was-opened = false
then do:
  assign
    frame {&frame-name}:title
      = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
      + "   НЕДОПУСТИМОЕ СОЧЕТАНИЕ ПАРАМЕТОВ ОТБОРА ПАРТИЙ "
  .
  run UI-on-empty in this-procedure
    (input  p-open-query
    ,input  p-find-next
    ,input  p-find-condition
    ) .
end.

run display-doc-line-info .

run reposition-query in this-procedure
  (input v-prt-rec
  ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ui-on-01 Dialog-Frame
PROCEDURE ui-on-01 :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  define input  parameter sort-column-phrase as character no-undo .
  define input-output parameter v-query-was-opened as logical no-undo .
  define parameter buffer buf_goods for ub.goods .
  define parameter buffer buf_trn-doc for ub.trn-doc .

  do
  on error undo, return error return-value
  :
    case rs-parts :
      when {&parts-l_parts-all}
      then do:
        assign
          frame {&frame-name}:title
            = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
            + "   ВСЕ ПАРТИИ"
        .
        { gbl/fltopend.i
          &where-cond = "parts.artic = buf_goods.artic ~
              and parts.prod-type = buf_goods.prod-type ~
              and parts.prod-code = buf_goods.prod-code ~
              and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) ) ~
             "
          &dyn_where-cond = " ~
              substitute ( ~
              ' parts.artic = &1&2&1  ~
              and parts.prod-type = &1&3&1 ~
              and parts.prod-code = &4 ~
              and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) ) ~
             ', ~{&double-quote~} , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code ) ~
              "
          &use-ind = "use-index artic"
          &by = "by parts.status_ by parts.rsrv-free desc"
        }
      end.

      when {&parts-l_parts-rest}
      then do:
        assign
          frame {&frame-name}:title
            = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
            + "   ФАКТ ОСТАТКИ"
        .
        { gbl/fltopend.i
          &where-cond="parts.artic = buf_goods.artic ~
            and parts.prod-type = buf_goods.prod-type ~
            and parts.prod-code = buf_goods.prod-code ~
            and parts.rsrv-free = yes ~
            and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) ) ~
            "
          &dyn_where-cond = " ~
              substitute ( ~
              ' parts.artic = &1&2&1  ~
              and parts.prod-type = &1&3&1 ~
              and parts.prod-code = &4 ~
              and parts.rsrv-free = yes ~
              and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) ) ~
             ', ~{&double-quote~} , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code ) ~
              "

          &use-ind=" "
          &by=" "
        }
      end.

      when {&parts-l_parts-free}
      then do:
        assign
          frame {&frame-name}:title
            = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
            + "   СВОБОДНО"
        .
        { gbl/fltopend.i
          &where-cond="parts.artic = buf_goods.artic ~
            and parts.prod-type = buf_goods.prod-type ~
            and parts.prod-code = buf_goods.prod-code ~
            and parts.out-code = {&free-code} ~
            and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) ) ~
            "
          &dyn_where-cond = " ~
              substitute ( ~
              ' parts.artic = &1&2&1  ~
              and parts.prod-type = &1&3&1 ~
              and parts.prod-code = &4 ~
              and parts.out-code = &1&7&1  ~
              and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) ) ~
             ' ~
             , ~{&double-quote~} , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , ~{&free-code~}) ~
              "

          &use-ind=" "
          &by=" "
        }
      end.

      when {&parts-l_parts-document}
      then do:
        if available buf_trn-doc
        then do:
          assign
            frame {&frame-name}:title
              = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
              + "   Партии по док-ту № : " + buf_trn-doc.doc-code
          .
          { gbl/fltopend.i
            &where-cond="parts.artic = buf_goods.artic ~
              and parts.prod-type = buf_goods.prod-type ~
              and parts.prod-code = buf_goods.prod-code ~
              and parts.out-code = buf_trn-doc.doc-code ~
              and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) ) ~
              "
          &dyn_where-cond = " ~
              substitute ( ~
              ' parts.artic = &1&2&1  ~
              and parts.prod-type = &1&3&1 ~
              and parts.prod-code = &4 ~
              and parts.out-code  = &1&7&1 ~
              and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) ) ~
             ', ~{&double-quote~} , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , buf_trn-doc.doc-code ) ~
              "

            &use-ind=" "
            &by=" "
          }
        end.
        else do:
          message
            "Документ не доступен"
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ui-on-02 Dialog-Frame
PROCEDURE ui-on-02 :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  define input  parameter sort-column-phrase as character no-undo .
  define input-output parameter v-query-was-opened as logical no-undo .
  define parameter buffer buf_goods for ub.goods .
  define parameter buffer buf_trn-doc for ub.trn-doc .

  do
  on error undo, return error return-value
  :
    case rs-parts :
      when {&parts-l_parts-all}
      then do:
        assign
          frame {&frame-name}:title = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
                                    + "   Объект : " + v-obj-type + " " + string (v-obj-code)
                                    + "   ВСЕ ПАРТИИ"
        .
        { gbl/fltopend.i
          &where-cond="parts.artic = buf_goods.artic ~
            and parts.prod-type = buf_goods.prod-type ~
            and parts.prod-code = buf_goods.prod-code ~
            and parts.obj-type = v-obj-type ~
            and parts.obj-code = v-obj-code ~
            and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) ) ~
            "
          &dyn_where-cond = " ~
              substitute ( ~
              ' parts.artic = &1&2&1  ~
              and parts.prod-type = &1&3&1 ~
              and parts.prod-code = &4 ~
              and parts.obj-type  = &1&7&1 ~
              and parts.obj-code  = &8 ~
              and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) ) ~
             ', ~{&double-quote~} , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code ) ~
              "

          &use-ind="use-index fifo"
          &by=" "
        }
      end.

      when {&parts-l_parts-rest}
      then do:
        assign
          frame {&frame-name}:title = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
                                    + "   Объект : " + v-obj-type + " " + string (v-obj-code)
                                    + "   ФАКТ ОСТАТКИ"
        .
        { gbl/fltopend.i
          &where-cond="parts.artic = buf_goods.artic ~
            and parts.prod-type = buf_goods.prod-type ~
            and parts.prod-code = buf_goods.prod-code ~
            and parts.obj-type = v-obj-type ~
            and parts.obj-code = v-obj-code ~
            and parts.rsrv-free = yes ~
            and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) ) ~
            "
          &dyn_where-cond = " ~
              substitute ( ~
              ' parts.artic = &1&2&1  ~
              and parts.prod-type = &1&3&1 ~
              and parts.prod-code = &4 ~
              and parts.obj-type  = &1&7&1 ~
              and parts.obj-code  = &8 ~
              and parts.rsrv-free = yes ~
              and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) ) ~
             ', ~{&double-quote~} , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code ) ~
              "

          &use-ind=" "
          &by=" "
        }
      end.

      when {&parts-l_parts-free}
      then do:
        assign
          frame {&frame-name}:title = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
                                    + "   Объект : " + v-obj-type + " " + string (v-obj-code)
                                    + "   СВОБОДНО"
        .
        { gbl/fltopend.i
          &where-cond="parts.artic = buf_goods.artic ~
            and parts.prod-type = buf_goods.prod-type ~
            and parts.prod-code = buf_goods.prod-code ~
            and parts.obj-type = v-obj-type ~
            and parts.obj-code = v-obj-code ~
            and parts.out-code = {&free-code} ~
            and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) ) ~
            "
          &dyn_where-cond = " ~
              substitute ( ~
              ' parts.artic = &1&2&1  ~
              and parts.prod-type = &1&3&1 ~
              and parts.prod-code = &4 ~
              and parts.obj-type  = &1&7&1 ~
              and parts.obj-code  = &8 ~
              and parts.out-code = &1&9&1   ~
              and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) ) ~
             ', ~{&double-quote~} , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code , ~{&free-code~}) ~
              "

          &use-ind=" "
          &by=" "
        }
      end.

      when {&parts-l_parts-document}
      then do:
        run ui-on-03 in this-procedure
          (input  p-open-query
          ,input  p-find-next
          ,input  p-find-condition
          ,input  sort-column-phrase
          ,input-output v-query-was-opened
          ,buffer buf_goods
          ,buffer buf_trn-doc
          ) .
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ui-on-03 Dialog-Frame
PROCEDURE ui-on-03 :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  define input  parameter sort-column-phrase as character no-undo .
  define input-output parameter v-query-was-opened as logical no-undo .
  define parameter buffer buf_goods for ub.goods .
  define parameter buffer buf_trn-doc for ub.trn-doc .

  do
  on error undo, return error return-value
  :
    if available buf_trn-doc
    then do:
      case buf_trn-doc.doc-type :
        when {&income}
        then do:
          assign
            frame {&frame-name}:title
              = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
              + "   Партии по ПН № : " + buf_trn-doc.doc-code + "   -  " + v-mode-name
          .
          if buf_trn-doc.status_ <> {&inquiry}
          then do:
            if v-edit-parts = true
            then do:
              enable
                b-add when v-add-parts = true
                b-del when v-add-parts = true
                b-chg
                b-b-alt
                b-pl
                b-mark
                with frame {&frame-name}.
            end.
          end.

          { gbl/fltopend.i
            &where-cond ="parts.artic = buf_goods.artic ~
              and parts.prod-type = buf_goods.prod-type ~
              and parts.prod-code = buf_goods.prod-code ~
              and parts.obj-type = v-obj-type ~
              and parts.obj-code = v-obj-code ~
              and parts.out-code = buf_trn-doc.doc-code ~
              and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) ) ~
              "
          &dyn_where-cond = " ~
              substitute ( ~
              ' parts.artic = &1&2&1  ~
              and parts.prod-type = &1&3&1 ~
              and parts.prod-code = &4 ~
              and parts.obj-type  = &1&7&1 ~
              and parts.obj-code  = &8 ~
              and parts.out-code =  &1&9&1
              and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) ) ~
             ', ~{&double-quote~} , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code ,buf_trn-doc.doc-code ) ~
              "

            &use-ind=" "
            &by=" "
          }
        end.

        when {&inventory}
        then do:
          assign
            frame {&frame-name}:title
              = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
              + "   Партии по док-ту № : " + buf_trn-doc.doc-code
              + "  и  СВОБОДНО/РАСХОД" + "   -  " + v-mode-name
          .
          if v-edit-parts = true
          then do:
            enable
              b-add when v-add-parts = true
              b-del when v-add-parts = true
              b-chg
              b-b-alt
              b-pl
              b-mark
              with frame {&frame-name}.
          end.
          if buf_trn-doc.ext-doc-type = {&TDEDT_Inv}      or
             buf_trn-doc.ext-doc-type = {&TDEDT_Peresort}
          then do:
            /* для документа инвентаризации показываем */
            /* свободную зону, расходную зону */
            /* и зарезервированные партии */
            { gbl/fltopend.i
              &where-cond="parts.artic = buf_goods.artic ~
                and parts.prod-type = buf_goods.prod-type ~
                and parts.prod-code = buf_goods.prod-code ~
                and parts.obj-type = v-obj-type ~
                and parts.obj-code = v-obj-code ~
                and ( parts.out-code = {&free-code} ~
                      or parts.out-code = {&output-code} ~
                      or parts.out-code = buf_trn-doc.doc-code ~
                    ) ~
                and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) ) ~
                "
          &dyn_where-cond = " ~
              substitute ( ~
              ' parts.artic = &1&2&1  ~
              and parts.prod-type = &1&3&1 ~
              and parts.prod-code = &4 ~
              and parts.obj-type  = &1&7&1 ~
              and parts.obj-code  = &8 ~
              and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) ) ~
             ', ~{&double-quote~} , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code  ) + ~
              substitute ( ' ~
                and ( parts.out-code = &1&2&1 ~
                      or parts.out-code = &1&3&1 ~
                      or parts.out-code = &1&4&1 ) ~
             ', ~{&double-quote~} , ~{&free-code~} , ~{&output-code~} , buf_trn-doc.doc-code ) ~
               "

              &use-ind="use-index pi"
              &by=" "
            }
          end.
          else do:
            /* для документов преобразования партий показываем */
            /* только свободную зону и зарезервированные партии */
            if buf_trn-doc.ext-doc-type = {&TDEDT_Corr_Acc_Price}
            then do:
              /* показываем только партии свободной зоны от контрагента */
              /* и все партии документа */
              /* с кодом договора равным коду договора документа */
              { gbl/fltopend.i
                &where-cond="parts.artic = buf_goods.artic ~
                  and parts.prod-type = buf_goods.prod-type ~
                  and parts.prod-code = buf_goods.prod-code ~
                  and parts.obj-type = v-obj-type ~
                  and parts.obj-code = v-obj-code ~
                  and ( ( parts.out-code = {&free-code} ~
                          and (( parts.supp-type = buf_trn-doc.cli-type and parts.supp-code = buf_trn-doc.cli-code) ) ~
                        )
                        or parts.out-code = buf_trn-doc.doc-code ~
                      ) ~
                  and parts.contract-code = buf_trn-doc.contract-code ~
                  and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) ) ~
                  "
          &dyn_where-cond = " ~
              substitute ( ~
              ' parts.artic = &1&2&1  ~
              and parts.prod-type = &1&3&1 ~
              and parts.prod-code = &4 ~
              and parts.obj-type  = &1&7&1 ~
              and parts.obj-code  = &8 ~
              and parts.contract-code =  &9 ~
              and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) ) ~
             ' , ~{&double-quote~} , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code ,buf_trn-doc.contract-code  ) + ~
              substitute ( ' ~
                  and ( ( parts.out-code = &1&5&1 ~
                          and ( parts.supp-type = &1&2&1 and parts.supp-code = &3 ) ~
                        ) ~
                        or parts.out-code = &1&4&1 ~
                      ) ~
              ', ~{&double-quote~} , buf_trn-doc.cli-type , buf_trn-doc.cli-code , buf_trn-doc.doc-code , ~{&free-code~} ) "

                &use-ind="use-index pi"
                &by=" "
              }
            end.
            else do:
              /* для всех остальных документов показываем партии */
              /* без ограничения по поставщику */
              { gbl/fltopend.i
                &where-cond="parts.artic = buf_goods.artic ~
                  and parts.prod-type = buf_goods.prod-type ~
                  and parts.prod-code = buf_goods.prod-code ~
                  and parts.obj-type = v-obj-type ~
                  and parts.obj-code = v-obj-code ~
                  and ( parts.out-code = {&free-code} ~
                        or parts.out-code = buf_trn-doc.doc-code ~
                      ) ~
                  and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) ) ~
                  "
          &dyn_where-cond = " ~
              substitute ( ' ~
                  parts.prod-type = &1&3&1 ~
              and parts.prod-code = &4 ~
              and parts.obj-type  = &1&7&1 ~
              and parts.obj-code  = &8 ~
              and  ( parts.out-code = &1&2&1  ~
                    or parts.out-code = &1&9&1 ~
                  ) ~
              and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) ) ~
             ', ~{&double-quote~} ,  ~{&free-code~}  , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code ,buf_trn-doc.doc-code   )  + ~
              substitute ( ~
              ' and parts.artic = &1&2&1 ', ~{&double-quote~} , buf_goods.artic ) ~
              "

                &use-ind="use-index pi"
                &by=" "
              }
            end.
          end.
        end. /* when {&inventory} */

        when {&expense} or
        when {&write-off}
        then do:
          if v-edit-parts = true
          then do:
            enable
              b-add when v-add-parts = true
              b-del when v-add-parts = true
              b-chg
              b-b-alt
              b-pl
              b-mark
              with frame {&frame-name}.
          end.
          define buffer buf_clients for ub.clients .
          find buf_clients no-lock
            where buf_clients.obj-type = buf_trn-doc.cli-type
              and buf_clients.obj-code = buf_trn-doc.cli-code
              .
          if buf_trn-doc.status_ <> {&permitted}
          then do:
            if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
            then do:
              if buf_trn-doc.contract-code <> ? and buf_trn-doc.contract-code <> 0
              then do :
                assign
                  frame {&frame-name}:title
                    = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
                    + "   Партии по док-ту № : " + buf_trn-doc.doc-code
                    + "  и  Поставщик : " + buf_clients.obj-name + "   -  " + v-mode-name
                .

                /* Парожденные партии свободной зоны на нашу фирму это производство - его не показываем */

                { gbl/fltopend.i
                  &where-cond="parts.artic = buf_goods.artic ~
                    and parts.prod-type = buf_goods.prod-type ~
                    and parts.prod-code = buf_goods.prod-code ~
                    and parts.obj-type = v-obj-type ~
                    and parts.obj-code = v-obj-code ~
                    and (parts.out-code = {&free-code} or parts.out-code = buf_trn-doc.doc-code) ~
                    and (( parts.supp-type = buf_trn-doc.cli-type and parts.supp-code = buf_trn-doc.cli-code) or ~
                        (parts.is-supp = no and not ( parts.supp-type = {&cmp} and parts.supp-code = buf_trn-doc.host-code))) ~
                    and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) ) ~
                    and parts.contract-code = buf_trn-doc.contract-code ~
                    "
            &dyn_where-cond = " ~
                substitute ( ~
                ' parts.artic = &1&2&1  ~
                and parts.prod-code = &4 ~
                and parts.obj-type  = &1&7&1 ~
                and parts.obj-code  = &8 ~
                and ( parts.out-code = &1&3&1 or parts.out-code = &1&9&1 ) ~
                and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) ) ~
              ', ~{&double-quote~} , buf_goods.artic , ~{&free-code~} , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code , buf_trn-doc.doc-code ) + ~
                substitute ( ' ~
                    and parts.prod-type = &1&5&1 ~
                    and (( parts.supp-type = &1&2&1 and parts.supp-code = &3 ) or ~
                          (parts.is-supp = no and not ( parts.supp-type = &1&6&1  and parts.supp-code = &4 ))) ~
                    and parts.contract-code = &7 ~
                        ', ~{&double-quote~} , buf_trn-doc.cli-type , buf_trn-doc.cli-code , buf_trn-doc.host-code , buf_goods.prod-type , ~{&cmp~} , buf_trn-doc.contract-code ) ~
                "
                  &use-ind=" "
                  &by=" "
                }
              end.
              else do :
                assign
                  frame {&frame-name}:title
                    = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
                    + "   Партии по док-ту № : " + buf_trn-doc.doc-code
                    + "  и  Поставщик : " + buf_clients.obj-name + "   -  " + v-mode-name
                .

                /* Парожденные партии свободной зоны на нашу фирму это производство - его не показываем */

                { gbl/fltopend.i
                  &where-cond="parts.artic = buf_goods.artic ~
                    and parts.prod-type = buf_goods.prod-type ~
                    and parts.prod-code = buf_goods.prod-code ~
                    and parts.obj-type = v-obj-type ~
                    and parts.obj-code = v-obj-code ~
                    and (parts.out-code = {&free-code} or parts.out-code = buf_trn-doc.doc-code) ~
                    and (( parts.supp-type = buf_trn-doc.cli-type and parts.supp-code = buf_trn-doc.cli-code) or ~
                        (parts.is-supp = no and not ( parts.supp-type = {&cmp} and parts.supp-code = buf_trn-doc.host-code))) ~
                    and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) ) ~
                    "
            &dyn_where-cond = " ~
                substitute ( ~
                ' parts.artic = &1&2&1  ~
                and parts.prod-code = &4 ~
                and parts.obj-type  = &1&7&1 ~
                and parts.obj-code  = &8 ~
                and ( parts.out-code = &1&3&1 or parts.out-code = &1&9&1 ) ~
                and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) ) ~
              ', ~{&double-quote~} , buf_goods.artic , ~{&free-code~} , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code , buf_trn-doc.doc-code ) + ~
                substitute ( ' ~
                    and parts.prod-type = &1&5&1 ~
                    and (( parts.supp-type = &1&2&1 and parts.supp-code = &3 ) or ~
                          (parts.is-supp = no and not ( parts.supp-type = &1&6&1  and parts.supp-code = &4 ))) ~
                        ', ~{&double-quote~} , buf_trn-doc.cli-type , buf_trn-doc.cli-code , buf_trn-doc.host-code , buf_goods.prod-type , ~{&cmp~} ) ~
                "
                  &use-ind=" "
                  &by=" "
                }
              end.
            end.
            else do:
              assign
                frame {&frame-name}:title = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
                                          + "   Партии по док-ту № : " + buf_trn-doc.doc-code
                                          + "  и  СВОБОДНО" + "   -  " + v-mode-name
              .
              { gbl/fltopend.i
                &where-cond="parts.artic = buf_goods.artic ~
                  and parts.prod-type = buf_goods.prod-type ~
                  and parts.prod-code = buf_goods.prod-code ~
                  and parts.obj-type = v-obj-type ~
                  and parts.obj-code = v-obj-code ~
                  and (parts.out-code = {&free-code} or parts.out-code = buf_trn-doc.doc-code) ~
                  and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) ) ~
                  "
          &dyn_where-cond = " ~
              substitute ( ~
              '  parts.prod-type = &1&3&1 ~
              and parts.prod-code = &4 ~
              and parts.obj-type  = &1&7&1 ~
              and parts.obj-code  = &8 ~
              and ( parts.out-code = &1&2&1 or parts.out-code = &1&9&1 ) ~
              and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) ) ~
             ', ~{&double-quote~} , ~{&free-code~}  , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code ,buf_trn-doc.doc-code ) + ~
              substitute ( ~
              ' and parts.artic = &1&2&1 ', ~{&double-quote~} , buf_goods.artic ) ~
              "

                &use-ind=" "
                &by=" "
              }
            end.
          end. /* buf_trn-doc.status_ <> {&permitted} */
          else do: /* buf_trn-doc.status_ = {&permitted} */
            if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
            then do:
              if buf_trn-doc.contract-code <> ? and buf_trn-doc.contract-code <> 0
              then do :
                assign
                  frame {&frame-name}:title
                    = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
                    + "   Партии по док-ту № : " + buf_trn-doc.doc-code
                    + "  и  Поставщик : " + buf_clients.obj-name + "   -  " + v-mode-name
                .
                { gbl/fltopend.i
                  &where-cond="parts.artic = buf_goods.artic ~
                    and parts.prod-type = buf_goods.prod-type ~
                    and parts.prod-code = buf_goods.prod-code ~
                    and parts.obj-type = v-obj-type ~
                    and parts.obj-code = v-obj-code ~
                    and parts.out-code = buf_trn-doc.doc-code ~
                    and (( parts.supp-type = buf_trn-doc.cli-type and parts.supp-code = buf_trn-doc.cli-code) or parts.is-supp = no) ~
                    and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) ) ~
                    and parts.contract-code = buf_trn-doc.contract-code ~
                    "
            &dyn_where-cond = " ~
                substitute ( ~
                ' parts.artic = &1&2&1  ~
                and parts.prod-type = &1&3&1 ~
                and parts.prod-code = &4 ~
                and parts.obj-type  = &1&7&1 ~
                and parts.obj-code  = &8 ~
                and  parts.out-code = &1&9&1 ~
                and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) ) ~
              ', ~{&double-quote~} , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code ,buf_trn-doc.doc-code ) + ~
                substitute ( ' ~
                    and (( parts.supp-type = &1&2&1 and parts.supp-code = &3 ) or parts.is-supp = no ) ~
                    and parts.contract-code = &4 ~
                        ', ~{&double-quote~} , buf_trn-doc.cli-type , buf_trn-doc.cli-code , buf_trn-doc.contract-code ) ~
                "

                  &use-ind=" "
                  &by=" "
                }
              end.
              else do :
                assign
                  frame {&frame-name}:title
                    = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
                    + "   Партии по док-ту № : " + buf_trn-doc.doc-code
                    + "  и  Поставщик : " + buf_clients.obj-name + "   -  " + v-mode-name
                .
                { gbl/fltopend.i
                  &where-cond="parts.artic = buf_goods.artic ~
                    and parts.prod-type = buf_goods.prod-type ~
                    and parts.prod-code = buf_goods.prod-code ~
                    and parts.obj-type = v-obj-type ~
                    and parts.obj-code = v-obj-code ~
                    and parts.out-code = buf_trn-doc.doc-code ~
                    and (( parts.supp-type = buf_trn-doc.cli-type and parts.supp-code = buf_trn-doc.cli-code) or parts.is-supp = no) ~
                    and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) ) ~
                    "
            &dyn_where-cond = " ~
                substitute ( ~
                ' parts.artic = &1&2&1  ~
                and parts.prod-type = &1&3&1 ~
                and parts.prod-code = &4 ~
                and parts.obj-type  = &1&7&1 ~
                and parts.obj-code  = &8 ~
                and  parts.out-code = &1&9&1 ~
                and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) ) ~
              ', ~{&double-quote~} , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code ,buf_trn-doc.doc-code ) + ~
                substitute ( ' ~
                    and (( parts.supp-type = &1&2&1 and parts.supp-code = &3 ) or parts.is-supp = no ) ~
                        ', ~{&double-quote~} , buf_trn-doc.cli-type , buf_trn-doc.cli-code  ) ~
                "

                  &use-ind=" "
                  &by=" "
                }
              end.
            end.
            else do:
              assign
                frame {&frame-name}:title
                  = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
                  + "   Партии по док-ту № : " + buf_trn-doc.doc-code
              .
              { gbl/fltopend.i
                &where-cond="parts.artic = buf_goods.artic ~
                  and parts.prod-type = buf_goods.prod-type ~
                  and parts.prod-code = buf_goods.prod-code ~
                  and parts.obj-type = v-obj-type ~
                  and parts.obj-code = v-obj-code ~
                  and parts.out-code = buf_trn-doc.doc-code ~
                  and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) ) ~
                  "
          &dyn_where-cond = " ~
              substitute ( ~
              ' parts.artic = &1&2&1  ~
              and parts.prod-type = &1&3&1 ~
              and parts.prod-code = &4 ~
              and parts.obj-type  = &1&7&1 ~
              and parts.obj-code  = &8 ~
              and  parts.out-code = &1&9&1 ~
              and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) ) ~
             ', ~{&double-quote~} , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code ,buf_trn-doc.doc-code )  ~
              "

                &use-ind=" "
                &by=" "
              }
            end.
          end. /* buf_trn-doc.status_ = {&permitted} */
        end. /* when {&expense} or when {&write-off} */

        when {&return}
        then do:
          assign
            frame {&frame-name}:title
              = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
              + "   Партии по док-ту № : " + buf_trn-doc.doc-code
              + "  и  РАСХОД" + "   -  " + v-mode-name
          .
          if v-edit-parts = true
          then do:
            enable
              b-add when v-add-parts = true
              b-del when v-add-parts = true
              b-chg
              b-b-alt
              b-pl
              b-mark
              with frame {&frame-name}.
          end.
          if buf_trn-doc.status_ <> {&permitted}
          then do:
            { gbl/fltopend.i
              &where-cond="parts.artic = buf_goods.artic ~
                and parts.prod-type = buf_goods.prod-type ~
                and parts.prod-code = buf_goods.prod-code ~
                and parts.obj-type = v-obj-type ~
                and parts.obj-code = v-obj-code ~
                and (parts.out-code = {&output-code} or parts.out-code = buf_trn-doc.doc-code) ~
                and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) ) ~
                "
          &dyn_where-cond = " ~
              substitute ( ~
              ' parts.artic = &1&2&1 ', ~{&double-quote~} , buf_goods.artic  ) +  ~
              substitute ( ~
              ' and parts.prod-type = &1&3&1 ~
              and parts.prod-code = &4 ~
              and parts.obj-type  = &1&7&1 ~
              and parts.obj-code  = &8 ~
              and (parts.out-code =  &1&2&1 or  parts.out-code = &1&9&1 ) ~
              and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) ) ~
             ', ~{&double-quote~} , ~{&output-code~} , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code ,buf_trn-doc.doc-code )  ~
              "

              &use-ind=" "
              &by=" "
            }
          end.
          else do:
            { gbl/fltopend.i
              &where-cond="parts.artic = buf_goods.artic ~
                and parts.prod-type = buf_goods.prod-type ~
                and parts.prod-code = buf_goods.prod-code ~
                and parts.obj-type = v-obj-type ~
                and parts.obj-code = v-obj-code ~
                and parts.out-code = buf_trn-doc.doc-code ~
                and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) ) ~
                "
          &dyn_where-cond = " ~
              substitute ( ~
              ' parts.artic = &1&2&1  ~
              and parts.prod-type = &1&3&1 ~
              and parts.prod-code = &4 ~
              and parts.obj-type  = &1&7&1 ~
              and parts.obj-code  = &8 ~
              and parts.out-code = &1&9&1  ~
              and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) ) ~
             ', ~{&double-quote~} , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code ,buf_trn-doc.doc-code )  ~
              "

              &use-ind=" "
              &by=" "
            }
          end.
        end. /* when {&return} */
      end case. /* case buf_trn-doc.doc-type */
    end. /* if available buf_trn-doc */
    else do:
      message
        "Документ не доступен"
        view-as alert-box error .
      undo, return error .
    end. /* not available buf_trn-doc */
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

procedure partsxls:
DEFINE VARIABLE chExcelApplication      AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorkbook              AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorksheet             AS COM-HANDLE no-undo .

def var v-ind   as integer   no-undo .
def var cRow as character no-undo .
def var cRange  as character no-undo .
/*def var v-report-name as character no-undo .*/

/* create a new Excel Application object */
CREATE "Excel.Application" chExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
assign
  /* launch Excel so it is visible to the user */
  chExcelApplication:Visible = false
  /* create a new Workbook */
  chWorkbook = chExcelApplication:Workbooks:Add ()
.

assign
  /* get the active Worksheet */
  chWorkSheet = chExcelApplication:Sheets:Item (1)
  /* чтоб нельзя было уронить EXCEL при заполнении и не мигало и не тратило время на перерисовку */
  chExcelApplication:Interactive = false
  chExcelApplication:ScreenUpdating = false
  /* название на WorkSheet */
  chWorkSheet:Name = "Партии"
  /* set the column names for the Worksheet */
  chWorkSheet:Range ("A1"):Value           = "№ п/п"
  chWorkSheet:Columns ("A":U):ColumnWidth  = 7
  chWorkSheet:Columns ("A":U):NumberFormat = fill ("#", 5) + "0"
  chWorkSheet:Range ("B1"):Value           = "Тип объекта"
  chWorkSheet:Columns ("B":U):ColumnWidth  = 5
  chWorkSheet:Columns ("B":U):NumberFormat = "@"
  chWorkSheet:Range ("C1"):Value           = "Код объекта"
  chWorkSheet:Columns ("C":U):ColumnWidth  = 10
  chWorkSheet:Columns ("C":U):NumberFormat = fill ("0", 9)
  chWorkSheet:Range ("D1"):Value           = "Артикул"
  chWorkSheet:Columns ("D":U):ColumnWidth  = 20
  chWorkSheet:Columns ("D":U):NumberFormat = "@"
  chWorkSheet:Range ("E1"):Value           = "Тип производителя"
  chWorkSheet:Columns ("E":U):ColumnWidth  = 5
  chWorkSheet:Columns ("E":U):NumberFormat = "@"
  chWorkSheet:Range ("F1"):Value           = "Код производителя"
  chWorkSheet:Columns ("F":U):ColumnWidth  = 10
  chWorkSheet:Columns ("F":U):NumberFormat = fill ("0", 9)
  chWorkSheet:Range ("G1"):Value           = "Номер ПН"
  chWorkSheet:Columns ("G":U):ColumnWidth  = 10
  chWorkSheet:Columns ("G":U):NumberFormat = "@"
  chWorkSheet:Range ("H1"):Value           = "Документ"
  chWorkSheet:Columns ("H":U):ColumnWidth  = 10
  chWorkSheet:Columns ("H":U):NumberFormat = "@"
  chWorkSheet:Range ("I1"):Value           = "Код партии"
  chWorkSheet:Columns ("I":U):ColumnWidth  = 5
  chWorkSheet:Columns ("I":U):NumberFormat = "@"
  chWorkSheet:Range ("J1"):Value           = "По док."
  chWorkSheet:Columns ("J":U):ColumnWidth  = 10
  chWorkSheet:Range ("K1"):Value           = "Факт"
  chWorkSheet:Columns ("K":U):ColumnWidth  = 10
  chWorkSheet:Range ("L1"):Value           = "Цена (Б.В.)"
  chWorkSheet:Columns ("L":U):ColumnWidth  = 12
  chWorkSheet:Range ("M1"):Value           = "Цена ({&abbr_rub}.)"
  chWorkSheet:Columns ("M":U):ColumnWidth  = 12
  chWorkSheet:Range ("N1"):Value           = "Поставка"
  chWorkSheet:Columns ("N":U):ColumnWidth  = 5
  chWorkSheet:Columns ("N":U):NumberFormat = "@"
  chWorkSheet:Range ("O1"):Value           = "Тип поставщика"
  chWorkSheet:Columns ("O":U):ColumnWidth  = 5
  chWorkSheet:Columns ("O":U):NumberFormat = "@"
  chWorkSheet:Range ("P1"):Value           = "Код поставщика"
  chWorkSheet:Columns ("P":U):ColumnWidth  = 10
  chWorkSheet:Columns ("P":U):NumberFormat = fill ("0", 9)
  chWorkSheet:Range ("Q1"):Value           = "ГТД"
  chWorkSheet:Columns ("Q":U):ColumnWidth  = 10
  chWorkSheet:Columns ("Q":U):NumberFormat = "@"
  chWorkSheet:Range ("R1"):Value           = "Тип приобретения"
  chWorkSheet:Columns ("R":U):ColumnWidth  = 20
  chWorkSheet:Columns ("R":U):NumberFormat = "@"
  chWorkSheet:Range ("S1"):Value           = "Договор"
  chWorkSheet:Columns ("S":U):ColumnWidth  = 20
  chWorkSheet:Columns ("S":U):NumberFormat = "@"
  chWorkSheet:Range ("T1"):Value           = "Годен до"
  chWorkSheet:Columns ("T":U):ColumnWidth  = 20
  chWorkSheet:Columns ("T":U):NumberFormat = "@"
  chWorkSheet:Range ("U1"):Value           = "Складское место"
  chWorkSheet:Columns ("U":U):ColumnWidth  = 20
  chWorkSheet:Columns ("U":U):NumberFormat = "@"
  chWorkSheet:Range ("V1"):Value           = "НДС"
  chWorkSheet:Columns ("V":U):ColumnWidth  = 10
  chWorkSheet:Columns ("V":U):NumberFormat = "@"


  chWorkSheet:Range ("A1:V1"):Font:Bold = TRUE
  chWorkSheet:Range ("A1:V1"):Interior:ColorIndex = 35
  .

run waitfram-show
  (input "Экспорт в EXCEL. Ждите ..."
  ).

def var v-rid as recid no-undo .

assign
  v-rid = recid(parts)
  v-ind = 0
.

reposition br-parts to row 1.

do while available parts
:
  assign
    v-ind = v-ind + 1
  .

  if (v-ind modulo 10) = 0 then do:
    run waitfram-show
      (input "Экспортировано в EXCEL строк : " + string (v-ind)
      ).
  end.

  assign
    cRow = string (v-ind + 1)
    cRange = "A":U + cRow
    chWorkSheet:Range (cRange):Value = v-ind
    cRange = "B":U + cRow
    chWorkSheet:Range (cRange):Value = parts.obj-type
    cRange = "C":U + cRow
    chWorkSheet:Range (cRange):Value = parts.obj-code
    cRange = "D":U + cRow
    chWorkSheet:Range (cRange):Value = parts.artic
    cRange = "E":U + cRow
    chWorkSheet:Range (cRange):Value = parts.prod-type
    cRange = "F":U + cRow
    chWorkSheet:Range (cRange):Value = parts.prod-code
    cRange = "G":U + cRow
    chWorkSheet:Range (cRange):Value = parts.in-code
    cRange = "H":U + cRow
    chWorkSheet:Range (cRange):Value = parts.out-code
    cRange = "I":U + cRow
    chWorkSheet:Range (cRange):Value = parts.part-code
    cRange = "J":U + cRow
    chWorkSheet:Range (cRange):Value = parts.qnty
    cRange = "K":U + cRow
    chWorkSheet:Range (cRange):Value = parts.fact-qnty
    cRange = "L":U + cRow
    chWorkSheet:Range (cRange):Value = parts.price-base
    cRange = "M":U + cRow
    chWorkSheet:Range (cRange):Value = parts.price-rubl
    cRange = "N":U + cRow
    chWorkSheet:Range (cRange):Value = string(parts.is-supp, "да/нет")
    cRange = "O":U + cRow
    chWorkSheet:Range (cRange):Value = parts.supp-type
    cRange = "P":U + cRow
    chWorkSheet:Range (cRange):Value = parts.supp-code
    cRange = "Q":U + cRow
    chWorkSheet:Range (cRange):Value = parts.cst-code
    cRange = "U":U + cRow
    chWorkSheet:Range (cRange):Value = parts.pl-code
    cRange = "V":U + cRow
    chWorkSheet:Range (cRange):Value = parts.vat-pc
  .

  define variable v-purch-str as character no-undo .

/*  if valid-handle(p-handle-callback)                                */
/*  and p-handle-callback :get-signature("purch-code-to-str") <> ""   */
/*  then do:                                                          */
/*    run purch-code-to-str in p-handle-callback                      */
/*      (input  parts.purch-code                                      */
/*      ,output v-purch-str                                           */
/*      ) .                                                           */
/*    assign                                                          */
/*      cRange = "R":U + cRow                                         */
/*      chWorkSheet:Range (cRange):Value = v-purch-str                */
/*    .                                                               */
/*  end.                                                              */
/*                                                                    */
/*  if valid-handle(p-handle-callback)                                */
/*  and p-handle-callback :get-signature("contract-code-to-str") <> ""*/
/*  then do:                                                          */
/*    define variable v-contract-prn-code-str as character no-undo .  */
/*    run contract-code-to-str in p-handle-callback                   */
/*       (input  parts.contract-code                                  */
/*       ,input  parts.obj-type                                       */
/*       ,input  parts.obj-code                                       */
/*       ,output v-contract-prn-code-str                              */
/*      ) .                                                           */
/*                                                                    */
/*    assign                                                          */
/*      cRange = "S":U + cRow                                         */
/*      chWorkSheet:Range (cRange):Value = v-contract-prn-code-str    */
/*    .                                                               */
/*  end.                                                              */

  if parts.last-date <> ?
  then do:
    assign
      cRange = "T":U + cRow
      chWorkSheet:Range (cRange):Value = string(parts.last-date, '99/99/9999':U)
    .
  end.

  get next br-parts .
end.

run waitfram-hide in this-procedure .

/* make Excel visible and enable input in it */
assign
  chExcelApplication:Interactive = true
  chExcelApplication:ScreenUpdating = true
  chExcelApplication:Visible = true
.


/*assign*/
/*  v-report-name  = chWorkbook:FullName*/
/*.*/
/*chWorkBook:Close.*/
/*chExcelApplication:Workbooks:Open(v-report-name).*/
/*assign*/
/*  chExcelApplication:ActiveWorkbook:Saved = YES*/
/*.*/

/* release com-handles */
RELEASE OBJECT chWorksheet NO-ERROR.
RELEASE OBJECT chWorkbook NO-ERROR.
chExcelApplication :QUIT().
RELEASE OBJECT  chExcelApplication  NO-ERROR.

if v-rid <> ? then do:
  reposition br-parts to recid v-rid .
end.

end procedure .    
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UI-on-empty Dialog-Frame 
PROCEDURE UI-on-empty :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .

  define variable sort-column-phrase as character no-undo .
  define variable v-query-was-opened as logical no-undo .

  define buffer buf_goods for ub.goods .

  { gbl/fltopend.i
    &where-cond = "parts.artic = '' ~
                    and parts.prod-type = '' ~
                    and parts.prod-code = 0 ~
                    and parts.obj-type = '' ~
                    and parts.obj-code = 0"
          &dyn_where-cond = " ~
              substitute ( ~
              ' parts.artic = &1&&1  ~
              and parts.prod-type = &1&&1 ~
              and parts.prod-code = 0 ~
              and parts.obj-type  = &1&&1 ~
              and parts.obj-code  = 0 ~
             ', ~{&double-quote~}  )  ~
              "

    &use-ind=" "
    &by=" "
  }

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-contract-prn-code Dialog-Frame
FUNCTION get-contract-prn-code RETURNS CHARACTER
  ( input p-recid as recid  ) :
  define buffer buf_parts for ub.parts  .
  find first buf_parts no-lock where recid(buf_parts) = p-recid no-error .
  if error-status :error then return "".

  define variable v-contract-prn-code-str as character no-undo .
  run contract-code-to-str in this-procedure
    (input  buf_parts.contract-code
    ,input  buf_parts.obj-type
    ,input  buf_parts.obj-code
    ,output v-contract-prn-code-str
    ) .
  return v-contract-prn-code-str .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-country-name Dialog-Frame
FUNCTION get-country-name RETURNS CHARACTER
  ( BUFFER buf_parts FOR parts ) :

  define variable v-country-name as character no-undo .

  run proc-get-country-name in this-procedure
    (buffer buf_parts
    ,output v-country-name
    ) .

  return v-country-name .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-mark Dialog-Frame
FUNCTION get-mark RETURNS CHARACTER
  ( BUFFER buf_parts FOR parts ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  if lookup(string (recid (buf_parts)), del-list) > 0
  then do:
    return "*".
  end.

  return "".

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-purch-code Dialog-Frame
FUNCTION get-purch-code RETURNS CHARACTER
  ( BUFFER buf_parts FOR parts ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  define variable v-purch-code-str as character no-undo .
  run purch-code-to-str in this-procedure
    (input  buf_parts.purch-code
    ,output v-purch-code-str
    ) .
  return v-purch-code-str .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME