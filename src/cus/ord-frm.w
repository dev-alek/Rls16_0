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

Форма корректировки строки заказа

Автор: Чернова Светлана Александровна
Дата создания: 02/13/02
Author: Svetlana Chernova
Creation date: 02/13/02

*/

define input  parameter parparentproc   as widget-handle no-undo.
define input  parameter r-tmp           as recid     no-undo.
define input  parameter line-mode       as character no-undo .
define output parameter stp-cycle       as logical   no-undo.
define output parameter stp-exit        as logical   no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма корректировки строки заказа" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/getsect.i  def }
{ gbl/clntattr.i }
{ gbl/ggoattr.i  }
{ cus/str-edi.i  }

define variable g#host-name       as character no-undo .
define variable g#host-code       as integer   no-undo .
define variable store-type        as character no-undo .
define variable store-code        as integer   no-undo .
define variable base-code         as integer   no-undo .
define variable g#report-num      as integer   no-undo .
define variable g#mainmenu-handle as handle    no-undo .
define variable g#log             as logical   no-undo .
define variable g#type            as character no-undo .
define variable loc-cli-base-rate as decimal   no-undo .
define variable is-edoc-nn        as logical   no-undo .
define variable is-edi            as logical   no-undo .
define variable par-is-edoc-nn    as character no-undo .
define variable par-is-edi        as character no-undo .
define variable is-edoc-nn-doc    as logical   no-undo .
define variable is-edi-doc        as logical   no-undo .
define variable v-dm-edi          as integer   no-undo .

{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
{ gbl/hostname.i store-type store-code  g#host-code g#host-name }
run get-report-num  in parParentProc ( output g#report-num ).
g#mainmenu-handle = PARPARENTPROC .
{ gbl/basecode.i g#host-code base-code }
{ cus/df-zakaz.i     }
{ gbl/tax-name.i     }
{ str/lib-trn.i      }
{ cus/ord-lib.i def  }
{ cmp/obj-list.i new  }

  assign
  is-edoc-nn-doc = status-is-edoc-nn ( input is-edoc-nn
                                      , input loc-cli-type
                                      , input loc-cli-code
                                      , input loc-store-type
                                      , input loc-store-code
                                      ) .
  assign
  is-edi-doc = status-is-edi ( input is-edi
                              , input loc-cli-type
                              , input loc-cli-code
                              , input loc-store-type
                              , input loc-store-code
                              , output v-dm-edi
                              ) .

function rvs-qnty returns decimal
( input p-gds-code as integer    ,
  input p-pl-code as integer  ) .
   for each ub.rvs-line no-lock  WHERE
            ub.rvs-line.gds-code = p-gds-code and
            ub.rvs-line.pl-code = ub.place.pl-code ,
      first ub.rvs-doc no-lock where
            ub.rvs-doc.rvs-code = ub.rvs-line.rvs-code and
            ub.rvs-doc.status_ = {&fact}
            break
            by ub.rvs-doc.fact-order desc :
         return ub.rvs-line.state-measure-qnty .
    end.
    return 0 .
end function.

define variable   t-action    as      char no-undo.
define buffer     b-ord-line  for     tmp#zakaz .
define buffer     i-ord-doc   for     ub.ord-doc   .
define variable   kk          like    ub.ord-line.cli-base-rate no-undo .
define temp-table tt-ord-line no-undo like tmp#zakaz .
define buffer buf_gds-obj for ub.gds-obj  .

define variable var-report-r-b as character no-undo .
{ gbl/curr-r-b.i  var-report-r-b }
define variable v-fact-cli-qnty as character format "x(15)" no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-PETROL

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.place ub.rvs-line tmp#zakaz ub.goods ub.gds-prt ~
clients

/* Definitions for BROWSE BR-PETROL                                     */
&Scoped-define FIELDS-IN-QUERY-BR-PETROL ub.place.pl-code ub.place.pl-name ~
place.max-qnty ub.rvs-line.state-measure-qnty
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-PETROL
&Scoped-define FIELD-PAIRS-IN-QUERY-BR-PETROL
&Scoped-define OPEN-QUERY-BR-PETROL OPEN QUERY BR-PETROL ~
for each obj-list , ~
       EACH ub.place NO-LOCK ~
       WHERE  ub.place.obj-code = obj-list.obj-code ~
          AND ub.place.obj-type = obj-list.obj-type , ~
      FIRST ub.pl-gds no-lock  ~
       WHERE  ub.pl-gds.obj-code = ub.place.obj-code ~
          AND ub.pl-gds.obj-type = ub.place.obj-type ~
          AND ub.pl-gds.pl-code  = ub.place.pl-code ~
          AND ub.pl-gds.gds-code = ub.goods.gds-code .

&Scoped-define TABLES-IN-QUERY-BR-PETROL ub.place ub.pl-gds ub.rvs-line ub.rvs-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BR-PETROL ub.place


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tmp#zakaz.cli-art ~
tmp#zakaz.VAT-pc tmp#zakaz.v-vat tmp#zakaz.sum-VAT tmp#zakaz.cli-qnty ~
tmp#zakaz.unit-cli tmp#zakaz.SLT-pc tmp#zakaz.cli-base-rate tmp#zakaz.qnty ~
tmp#zakaz.price-cli tmp#zakaz.price-base tmp#zakaz.price-rubl ~
tmp#zakaz.line-num tmp#zakaz.cancel-date tmp#zakaz.road-tax tmp#zakaz.excise ~
tmp#zakaz.transport-base tmp#zakaz.other-base tmp#zakaz.transport-rubl ~
tmp#zakaz.other-rubl tmp#zakaz.artic ub.goods.gds-name tmp#zakaz.prod-type ~
clients.obj-name tmp#zakaz.prod-code ub.goods.qnty-cart ub.goods.wt-cart ~
tmp#zakaz.sum-SLT ub.goods.unit-base tmp#zakaz.sum-cli tmp#zakaz.sum-base ~
tmp#zakaz.sum-rubl ub.gds-prt.node-name tmp#zakaz.sum-road-tax ~
tmp#zakaz.sum-excise tmp#zakaz.sum-transport-base tmp#zakaz.sum-other-base ~
tmp#zakaz.sum-transport-rubl tmp#zakaz.sum-other-rubl
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tmp#zakaz.cli-art ~
tmp#zakaz.VAT-pc tmp#zakaz.v-vat tmp#zakaz.sum-VAT tmp#zakaz.cli-qnty ~
tmp#zakaz.unit-cli tmp#zakaz.SLT-pc tmp#zakaz.cli-base-rate tmp#zakaz.qnty ~
tmp#zakaz.price-cli tmp#zakaz.price-base tmp#zakaz.price-rubl ~
tmp#zakaz.line-num tmp#zakaz.cancel-date tmp#zakaz.road-tax tmp#zakaz.excise ~
tmp#zakaz.transport-base tmp#zakaz.other-base tmp#zakaz.transport-rubl ~
tmp#zakaz.other-rubl tmp#zakaz.artic ub.goods.gds-name tmp#zakaz.prod-type ~
clients.obj-name tmp#zakaz.prod-code ub.goods.qnty-cart ub.goods.wt-cart ~
tmp#zakaz.sum-SLT ub.goods.unit-base tmp#zakaz.sum-cli tmp#zakaz.sum-base ~
tmp#zakaz.sum-rubl ub.gds-prt.node-name tmp#zakaz.sum-road-tax ~
tmp#zakaz.sum-excise tmp#zakaz.sum-transport-base tmp#zakaz.sum-other-base ~
tmp#zakaz.sum-transport-rubl tmp#zakaz.sum-other-rubl
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tmp#zakaz ub.goods ub.clients ~
gds-prt
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tmp#zakaz
&Scoped-define SECOND-ENABLED-TABLE-IN-QUERY-Dialog-Frame ub.goods
&Scoped-define THIRD-ENABLED-TABLE-IN-QUERY-Dialog-Frame ub.clients

&Scoped-define FIELD-PAIRS-IN-QUERY-Dialog-Frame~
 ~{&FP1}cli-art ~{&FP2}cli-art ~{&FP3}~
 ~{&FP1}VAT-pc ~{&FP2}VAT-pc ~{&FP3}~
 ~{&FP1}sum-VAT ~{&FP2}sum-VAT ~{&FP3}~
 ~{&FP1}cli-qnty ~{&FP2}cli-qnty ~{&FP3}~
 ~{&FP1}unit-cli ~{&FP2}unit-cli ~{&FP3}~
 ~{&FP1}SLT-pc ~{&FP2}SLT-pc ~{&FP3}~
 ~{&FP1}cli-base-rate ~{&FP2}cli-base-rate ~{&FP3}~
 ~{&FP1}qnty ~{&FP2}qnty ~{&FP3}~
 ~{&FP1}price-cli ~{&FP2}price-cli ~{&FP3}~
 ~{&FP1}price-base ~{&FP2}price-base ~{&FP3}~
 ~{&FP1}price-rubl ~{&FP2}price-rubl ~{&FP3}~
 ~{&FP1}line-num ~{&FP2}line-num ~{&FP3}~
 ~{&FP1}cancel-date ~{&FP2}cancel-date ~{&FP3}~
 ~{&FP1}road-tax ~{&FP2}road-tax ~{&FP3}~
 ~{&FP1}excise ~{&FP2}excise ~{&FP3}~
 ~{&FP1}transport-base ~{&FP2}transport-base ~{&FP3}~
 ~{&FP1}other-base ~{&FP2}other-base ~{&FP3}~
 ~{&FP1}transport-rubl ~{&FP2}transport-rubl ~{&FP3}~
 ~{&FP1}other-rubl ~{&FP2}other-rubl ~{&FP3}~
 ~{&FP1}artic ~{&FP2}artic ~{&FP3}~
 ~{&FP1}gds-name ~{&FP2}gds-name ~{&FP3}~
 ~{&FP1}prod-type ~{&FP2}prod-type ~{&FP3}~
 ~{&FP1}obj-name ~{&FP2}obj-name ~{&FP3}~
 ~{&FP1}prod-code ~{&FP2}prod-code ~{&FP3}~
 ~{&FP1}qnty-cart ~{&FP2}qnty-cart ~{&FP3}~
 ~{&FP1}wt-cart ~{&FP2}wt-cart ~{&FP3}~
 ~{&FP1}sum-SLT ~{&FP2}sum-SLT ~{&FP3}~
 ~{&FP1}unit-base ~{&FP2}unit-base ~{&FP3}~
 ~{&FP1}sum-cli ~{&FP2}sum-cli ~{&FP3}~
 ~{&FP1}sum-base ~{&FP2}sum-base ~{&FP3}~
 ~{&FP1}sum-rubl ~{&FP2}sum-rubl ~{&FP3}~
 ~{&FP1}node-name ~{&FP2}node-name ~{&FP3}~
 ~{&FP1}sum-road-tax ~{&FP2}sum-road-tax ~{&FP3}~
 ~{&FP1}sum-excise ~{&FP2}sum-excise ~{&FP3}~
 ~{&FP1}sum-transport-base ~{&FP2}sum-transport-base ~{&FP3}~
 ~{&FP1}sum-other-base ~{&FP2}sum-other-base ~{&FP3}~
 ~{&FP1}sum-transport-rubl ~{&FP2}sum-transport-rubl ~{&FP3}~
 ~{&FP1}sum-other-rubl ~{&FP2}sum-other-rubl ~{&FP3}
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tmp#zakaz ~
      WHERE r-tmp = recid ( tmp#zakaz   ) NO-LOCK, ~
      EACH ub.goods WHERE ub.goods.artic = tmp#zakaz.artic ~
  AND ub.goods.prod-code = tmp#zakaz.prod-code ~
  AND ub.goods.prod-type = tmp#zakaz.prod-type NO-LOCK, ~
      EACH ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK, ~
      EACH ub.clients WHERE ub.clients.obj-code = tmp#zakaz.prod-code ~
  AND ub.clients.obj-type = tmp#zakaz.prod-type NO-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tmp#zakaz ub.goods ub.gds-prt ub.clients
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tmp#zakaz


/* Definitions for FRAME FRAME-petrol                                   */
&Scoped-define OPEN-BROWSERS-IN-QUERY-FRAME-petrol ~
    ~{&OPEN-QUERY-BR-PETROL}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tmp#zakaz.cli-art tmp#zakaz.VAT-pc ~
tmp#zakaz.v-vat tmp#zakaz.sum-VAT tmp#zakaz.cli-qnty tmp#zakaz.unit-cli ~
tmp#zakaz.SLT-pc tmp#zakaz.cli-base-rate tmp#zakaz.qnty tmp#zakaz.price-cli ~
tmp#zakaz.price-base tmp#zakaz.price-rubl tmp#zakaz.line-num ~
tmp#zakaz.cancel-date tmp#zakaz.road-tax tmp#zakaz.excise ~
tmp#zakaz.transport-base tmp#zakaz.other-base tmp#zakaz.transport-rubl ~
tmp#zakaz.other-rubl tmp#zakaz.artic ub.goods.gds-name tmp#zakaz.prod-type ~
clients.obj-name tmp#zakaz.prod-code ub.goods.qnty-cart ub.goods.wt-cart ~
tmp#zakaz.sum-SLT ub.goods.unit-base tmp#zakaz.sum-cli tmp#zakaz.sum-base ~
tmp#zakaz.sum-rubl ub.gds-prt.node-name tmp#zakaz.sum-road-tax ~
tmp#zakaz.sum-excise tmp#zakaz.sum-transport-base tmp#zakaz.sum-other-base ~
tmp#zakaz.sum-transport-rubl tmp#zakaz.sum-other-rubl
&Scoped-define FIELD-PAIRS~
 ~{&FP1}cli-art ~{&FP2}cli-art ~{&FP3}~
 ~{&FP1}VAT-pc ~{&FP2}VAT-pc ~{&FP3}~
 ~{&FP1}sum-VAT ~{&FP2}sum-VAT ~{&FP3}~
 ~{&FP1}cli-qnty ~{&FP2}cli-qnty ~{&FP3}~
 ~{&FP1}unit-cli ~{&FP2}unit-cli ~{&FP3}~
 ~{&FP1}SLT-pc ~{&FP2}SLT-pc ~{&FP3}~
 ~{&FP1}cli-base-rate ~{&FP2}cli-base-rate ~{&FP3}~
 ~{&FP1}qnty ~{&FP2}qnty ~{&FP3}~
 ~{&FP1}price-cli ~{&FP2}price-cli ~{&FP3}~
 ~{&FP1}price-base ~{&FP2}price-base ~{&FP3}~
 ~{&FP1}price-rubl ~{&FP2}price-rubl ~{&FP3}~
 ~{&FP1}line-num ~{&FP2}line-num ~{&FP3}~
 ~{&FP1}cancel-date ~{&FP2}cancel-date ~{&FP3}~
 ~{&FP1}road-tax ~{&FP2}road-tax ~{&FP3}~
 ~{&FP1}excise ~{&FP2}excise ~{&FP3}~
 ~{&FP1}transport-base ~{&FP2}transport-base ~{&FP3}~
 ~{&FP1}other-base ~{&FP2}other-base ~{&FP3}~
 ~{&FP1}transport-rubl ~{&FP2}transport-rubl ~{&FP3}~
 ~{&FP1}other-rubl ~{&FP2}other-rubl ~{&FP3}~
 ~{&FP1}artic ~{&FP2}artic ~{&FP3}~
 ~{&FP1}gds-name ~{&FP2}gds-name ~{&FP3}~
 ~{&FP1}prod-type ~{&FP2}prod-type ~{&FP3}~
 ~{&FP1}obj-name ~{&FP2}obj-name ~{&FP3}~
 ~{&FP1}prod-code ~{&FP2}prod-code ~{&FP3}~
 ~{&FP1}qnty-cart ~{&FP2}qnty-cart ~{&FP3}~
 ~{&FP1}wt-cart ~{&FP2}wt-cart ~{&FP3}~
 ~{&FP1}sum-SLT ~{&FP2}sum-SLT ~{&FP3}~
 ~{&FP1}unit-base ~{&FP2}unit-base ~{&FP3}~
 ~{&FP1}sum-cli ~{&FP2}sum-cli ~{&FP3}~
 ~{&FP1}sum-base ~{&FP2}sum-base ~{&FP3}~
 ~{&FP1}sum-rubl ~{&FP2}sum-rubl ~{&FP3}~
 ~{&FP1}node-name ~{&FP2}node-name ~{&FP3}~
 ~{&FP1}sum-road-tax ~{&FP2}sum-road-tax ~{&FP3}~
 ~{&FP1}sum-excise ~{&FP2}sum-excise ~{&FP3}~
 ~{&FP1}sum-transport-base ~{&FP2}sum-transport-base ~{&FP3}~
 ~{&FP1}sum-other-base ~{&FP2}sum-other-base ~{&FP3}~
 ~{&FP1}sum-transport-rubl ~{&FP2}sum-transport-rubl ~{&FP3}~
 ~{&FP1}sum-other-rubl ~{&FP2}sum-other-rubl ~{&FP3}
&Scoped-define ENABLED-TABLES tmp#zakaz ub.goods ub.clients ub.gds-prt
&Scoped-define FIRST-ENABLED-TABLE tmp#zakaz
&Scoped-define SECOND-ENABLED-TABLE ub.goods
&Scoped-define THIRD-ENABLED-TABLE ub.clients
&Scoped-Define ENABLED-OBJECTS B-OK B-Cancel b-exit-cycl B-qnty B-prt B-help ~
r-units abbr-cli abbr-base abbr-rubl
&Scoped-Define DISPLAYED-FIELDS tmp#zakaz.cli-art tmp#zakaz.VAT-pc ~
tmp#zakaz.v-vat tmp#zakaz.sum-VAT tmp#zakaz.cli-qnty tmp#zakaz.unit-cli ~
tmp#zakaz.SLT-pc tmp#zakaz.cli-base-rate tmp#zakaz.qnty tmp#zakaz.price-cli ~
tmp#zakaz.price-base tmp#zakaz.price-rubl tmp#zakaz.line-num ~
tmp#zakaz.cancel-date tmp#zakaz.road-tax tmp#zakaz.excise ~
tmp#zakaz.transport-base tmp#zakaz.other-base tmp#zakaz.transport-rubl ~
tmp#zakaz.other-rubl tmp#zakaz.artic ub.goods.gds-name tmp#zakaz.prod-type ~
clients.obj-name tmp#zakaz.prod-code ub.goods.qnty-cart ub.goods.wt-cart ~
tmp#zakaz.sum-SLT ub.goods.unit-base tmp#zakaz.sum-cli tmp#zakaz.sum-base ~
tmp#zakaz.sum-rubl ub.gds-prt.node-name tmp#zakaz.sum-road-tax ~
tmp#zakaz.sum-excise tmp#zakaz.sum-transport-base tmp#zakaz.sum-other-base ~
tmp#zakaz.sum-transport-rubl tmp#zakaz.sum-other-rubl
&Scoped-Define DISPLAYED-OBJECTS abbr-cli abbr-base abbr-rubl

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,ass-f                             */
&Scoped-define ass-f tmp#zakaz.cli-art tmp#zakaz.VAT-pc ~
tmp#zakaz.cli-qnty tmp#zakaz.SLT-pc tmp#zakaz.qnty tmp#zakaz.price-cli ~
tmp#zakaz.line-num ~
tmp#zakaz.cancel-date tmp#zakaz.road-tax tmp#zakaz.excise ~
tmp#zakaz.transport-base tmp#zakaz.other-base tmp#zakaz.transport-rubl ~
tmp#zakaz.other-rubl tmp#zakaz.artic tmp#zakaz.prod-type tmp#zakaz.prod-code ~
tmp#zakaz.sum-SLT tmp#zakaz.sum-cli tmp#zakaz.sum-base tmp#zakaz.sum-rubl ~
tmp#zakaz.sum-road-tax tmp#zakaz.sum-excise tmp#zakaz.sum-transport-base ~
tmp#zakaz.sum-other-base tmp#zakaz.sum-transport-rubl tmp#zakaz.sum-other-rubl

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 12 BY 1 TOOLTIP "Выход без сохранения"
     BGCOLOR 8 .

DEFINE BUTTON b-exit-cycl AUTO-GO
     LABEL "Стоп&Цикл"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "&Помощь"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-OK AUTO-GO
     LABEL "&Ввод"
     SIZE 12 BY 1 TOOLTIP "Выход с сохранением исправлений"
     BGCOLOR 8 .

DEFINE BUTTON B-prt
     LABEL "&Шкала"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-qnty
     LABEL "Про&чее"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON r-units
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-units"
     SIZE 3 BY .88 TOOLTIP "Выбор единицы измерения".

DEFINE VARIABLE abbr-base AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 9.75 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE abbr-cli AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 9.75 BY 1
     BGCOLOR 4 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE abbr-rubl AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 9.75 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE tot-base AS DECIMAL FORMAT "->>>>>>>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE tot-cli AS DECIMAL FORMAT "->>>>>>>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE tot-rubl AS DECIMAL FORMAT "->>>>>>>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.


DEFINE VARIABLE N-1 AS decimal FORMAT  "->>>>>>>>9.999":U INITIAL 0
      LABEL "Макс.кол!(баз.ед.изм)"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE N-2 AS  decimal FORMAT  "->>>>>>>>9.999":U INITIAL 0
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-PETROL FOR
      obj-list,
      ub.place,
      ub.pl-gds SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      tmp#zakaz,
      ub.goods,
      ub.gds-prt,
      ub.clients SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-PETROL
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-PETROL Dialog-Frame _STRUCTURED
  QUERY BR-PETROL NO-LOCK DISPLAY
      ub.place.pl-code COLUMN-LABEL "Код места!хранения"
      ub.place.pl-name FORMAT "X(20)"
      ub.place.max-qnty format "->>>>>>>>>>9.999":U  column-LABEL "Макс.кол!(баз.ед.изм)"
      rvs-qnty ( ub.goods.gds-code , ub.place.pl-code) format "->>>>>>>>>>9.999":U   column-LABEL "Факт остаток по!последней сверке"
      ub.place.obj-type + " " + string( ub.place.obj-code) COLUMN-LABEL "Объект"     FORMAT "X(10)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 77 BY 6
         BGCOLOR 15 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-OK AT ROW 1 COL 1.25
     B-Cancel AT ROW 1 COL 13.25
     b-exit-cycl AT ROW 1 COL 25.25
     B-qnty AT ROW 1 COL 56.25
     B-prt AT ROW 1 COL 68.25
     B-Help AT ROW 1 COL 80.25
     tmp#zakaz.cli-art AT ROW 3.75 COL 21.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY 1
          format "x(16)"
     r-units AT ROW 6.08 COL 38.75
     tmp#zakaz.cli-qnty AT ROW 6.13 COL 11.25 COLON-ALIGNED
          LABEL "По пост."
          VIEW-AS FILL-IN
          SIZE 17.75 BY 1 TOOLTIP "Количество в ед.изм. поставщика"
          format ">,>>>,>>>,>>9.<<<"
     tmp#zakaz.unit-cli AT ROW 6.13 COL 29.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 6.75 BY 1
     tmp#zakaz.cli-base-rate AT ROW 7.08 COL 39.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 12.25 BY 1
     tmp#zakaz.qnty AT ROW 7.08 COL 11.25 COLON-ALIGNED
          format ">,>>>,>>>,>>9.<<<"
          LABEL "По док-ту"
          VIEW-AS FILL-IN
          SIZE 17.75 BY 1 TOOLTIP "Количество в базовых ед.изм."
     tot-cli AT ROW 9.25 COL 68 COLON-ALIGNED NO-LABEL
     tmp#zakaz.price-cli AT ROW 9.54 COL 11.25 COLON-ALIGNED
          LABEL "По пост."
          VIEW-AS FILL-IN
          SIZE 18.25 BY 1
     tmp#zakaz.order-cli-qnty AT ROW 6.13 COL 41.75
          LABEL "Было запрошено"
          VIEW-AS TEXT
          SIZE 6.5 BY 0.7
      tmp#zakaz.ord-dec1      AT ROW 9.54 COL 70
          LABEL "Запрошена цена"
          VIEW-AS TEXT
          SIZE 15 BY 0.7
     tmp#zakaz.VAT-pc AT ROW 10.54 COL 74 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 6.5 BY 1 TOOLTIP "Процент НДС"
     tmp#zakaz.v-vat AT ROW 10.54 COL 83
          VIEW-AS TOGGLE-BOX
          SIZE 2 BY 1 TOOLTIP "Направление расчета НДС"
     tmp#zakaz.sum-VAT AT ROW 10.54 COL 83 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 12 BY 1 TOOLTIP "Сумма НДС"
     tmp#zakaz.SLT-pc AT ROW 11.54 COL 74 COLON-ALIGNED
          LABEL "НсП"
          VIEW-AS FILL-IN
          SIZE 6.5 BY 1 TOOLTIP "Процент НсП"
     tmp#zakaz.sum-SLT AT ROW 11.54 COL 83 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 12 BY 1 TOOLTIP "Сумма НсП"


     tot-rubl AT ROW 10.38 COL 68 COLON-ALIGNED NO-LABEL
     tmp#zakaz.price-base AT ROW 10.54 COL 11.25 COLON-ALIGNED
          format ">>>>>>>>>9.99<<<<<"
          LABEL "Учет."
          VIEW-AS FILL-IN
          SIZE 20 BY 1
     tot-base AT ROW 11.5 COL 68 COLON-ALIGNED NO-LABEL
     tmp#zakaz.price-rubl AT ROW 11.54 COL 11.25 COLON-ALIGNED
          format ">>>>>>>>>9.99<<<<<"
          LABEL "Учет."
          VIEW-AS FILL-IN
          SIZE 18.25 BY 1
     tmp#zakaz.line-num AT ROW 13.75 COL 47 COLON-ALIGNED
          LABEL "N п/п"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tmp#zakaz.cancel-date AT ROW 13.75 COL 79 COLON-ALIGNED FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1 TOOLTIP "Дата прекращения поставок товара"
     tmp#zakaz.road-tax AT ROW 14.71 COL 16.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     tmp#zakaz.excise AT ROW 16.88 COL 16.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     tmp#zakaz.transport-base AT ROW 19.17 COL 27.38 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 14 BY 1
     tmp#zakaz.other-base AT ROW 19.17 COL 66.63 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 14 BY 1
     tmp#zakaz.transport-rubl AT ROW 20.17 COL 27.38 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 14 BY 1
     tmp#zakaz.other-rubl AT ROW 20.17 COL 66.63 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 14 BY 1
     tmp#zakaz.artic AT ROW 2.17 COL 21.25 COLON-ALIGNED
          LABEL "Артикул"
           VIEW-AS TEXT
          SIZE 17 BY .67
     ub.goods.gds-name AT ROW 2.17 COL 40 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 51.25 BY .67
          FGCOLOR 4
.
/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     tmp#zakaz.prod-type AT ROW 2.92 COL 31.63 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 9 BY .67
     ub.clients.obj-name AT ROW 2.92 COL 40 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 49.75 BY .67
          FGCOLOR 4
     tmp#zakaz.prod-code AT ROW 2.96 COL 21.25 COLON-ALIGNED
          LABEL "Производитель"
           VIEW-AS TEXT
          SIZE 10 BY .67
     ub.goods.qnty-cart AT ROW 3.83 COL 78 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 11 BY .67
     ub.goods.wt-cart AT ROW 4.58 COL 78 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 12 BY .67
     ub.goods.unit-base AT ROW 7.13 COL 30 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 6.25 BY 1
     abbr-cli AT ROW 9.5 COL 57.75 COLON-ALIGNED NO-LABEL
     tmp#zakaz.sum-cli AT ROW 9.54 COL 30.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 26.38 BY 1
     abbr-base AT ROW 10.5 COL 57.75 COLON-ALIGNED NO-LABEL
     tmp#zakaz.sum-base AT ROW 10.54 COL 30.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 26.38 BY 1
     abbr-rubl AT ROW 11.5 COL 57.75 COLON-ALIGNED NO-LABEL
     tmp#zakaz.sum-rubl AT ROW 11.54 COL 30.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 26.38 BY 1
     ub.gds-prt.node-name AT ROW 13 COL 70 COLON-ALIGNED NO-LABEL FORMAT "x(20)"
           VIEW-AS TEXT
          SIZE 20 BY .67
          FGCOLOR 1
     buf_gds-obj.fact-qnty AT ROW 15 COL 72 COLON-ALIGNED LABEL "Факт.кол-во(остатки)"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     v-fact-cli-qnty AT ROW 16 COL 72 COLON-ALIGNED LABEL "Факт.кол-во(ед.пост.)"
          VIEW-AS FILL-IN
          SIZE 20 BY 1
     buf_gds-obj.free-qnty AT ROW 17 COL 72 COLON-ALIGNED LABEL "Свободно"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     buf_gds-obj.avrg-qnty AT ROW 18 COL 72 COLON-ALIGNED LABEL "Положительные партии"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     tmp#zakaz.sub-par AT ROW 18 COL 2 LABEL "Примечание"
          view-as editor scrollbar-vertical
          size 38 by 3
     tmp#zakaz.sum-road-tax AT ROW 15.71 COL 16.75 COLON-ALIGNED
          LABEL "Сумма 3 налога"
           VIEW-AS TEXT
          SIZE 22 BY 0.7
          tooltip "Третья компонента налога"
     tmp#zakaz.sum-excise AT ROW 17 COL 16.75 COLON-ALIGNED
          LABEL "Сумма акциза"
           VIEW-AS TEXT
          SIZE 22 BY 0.7
     tmp#zakaz.sum-transport-base AT ROW 21.17 COL 27.38 COLON-ALIGNED
          LABEL "Сумма тр.налога (баз)"
           VIEW-AS TEXT
          SIZE 18.38 BY 0.7
     tmp#zakaz.sum-other-base AT ROW 21.17 COL 66.63 COLON-ALIGNED
          LABEL "Сумма др.налогов (баз)"
           VIEW-AS TEXT
          SIZE 22 BY 0.7
     tmp#zakaz.sum-transport-rubl AT ROW 22.17 COL 27.38 COLON-ALIGNED
          LABEL "Сумма тр.налога ({&abbr_rub})"
           VIEW-AS TEXT
          SIZE 18.25 BY 0.7
     tmp#zakaz.sum-other-rubl AT ROW 22.17 COL 66.63 COLON-ALIGNED
          LABEL "Сумма др.налогов ({&abbr_rub})"
           VIEW-AS TEXT
          SIZE 22 BY 0.7
     "Количество        Ед. изм.  Коэффициент" VIEW-AS TEXT
          SIZE 40.75 BY 1 AT ROW 4.92 COL 13.25
          BGCOLOR 3 FGCOLOR 15
     "Цена               Сумма                       Вал." VIEW-AS TEXT
          SIZE 56.13 BY 1 AT ROW 8.42 COL 13.38
          BGCOLOR 3 FGCOLOR 15
     SPACE(23.73) SKIP(13.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Изменение строки заказа"
         DEFAULT-BUTTON B-OK CANCEL-BUTTON B-Cancel.

DEFINE FRAME FRAME-petrol
     BR-PETROL AT ROW 1 COL 1
     N-1 AT ROW 7 COL 30 COLON-ALIGNED no-label
     N-2 AT ROW 7 COL 47 COLON-ALIGNED NO-LABEL
     "Итого:" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 7 COL 1
          FGCOLOR 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 14.75
         SIZE 92 BY 8.5
         TITLE "Бензин".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* REPARENT FRAME */
ASSIGN FRAME FRAME-petrol:FRAME = FRAME Dialog-Frame:HANDLE.

/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tmp#zakaz.artic IN FRAME Dialog-Frame
   6 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN tmp#zakaz.cancel-date IN FRAME Dialog-Frame
   6 EXP-FORMAT                                                         */
/* SETTINGS FOR FILL-IN tmp#zakaz.cli-art IN FRAME Dialog-Frame
   6                                                                    */
/* SETTINGS FOR FILL-IN tmp#zakaz.cli-qnty IN FRAME Dialog-Frame
   6 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN tmp#zakaz.excise IN FRAME Dialog-Frame
   6                                                                    */
/* SETTINGS FOR FILL-IN tmp#zakaz.line-num IN FRAME Dialog-Frame
   6 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN ub.gds-prt.node-name IN FRAME Dialog-Frame
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN tmp#zakaz.other-base IN FRAME Dialog-Frame
   6                                                                    */
/* SETTINGS FOR FILL-IN tmp#zakaz.other-rubl IN FRAME Dialog-Frame
   6                                                                    */
/* SETTINGS FOR FILL-IN tmp#zakaz.price-base IN FRAME Dialog-Frame
   6 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN tmp#zakaz.price-cli IN FRAME Dialog-Frame
   6 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN tmp#zakaz.price-rubl IN FRAME Dialog-Frame
   6 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN tmp#zakaz.prod-code IN FRAME Dialog-Frame
   6 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN tmp#zakaz.prod-type IN FRAME Dialog-Frame
   6                                                                    */
/* SETTINGS FOR FILL-IN tmp#zakaz.qnty IN FRAME Dialog-Frame
   6 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN tmp#zakaz.road-tax IN FRAME Dialog-Frame
   6                                                                    */
/* SETTINGS FOR FILL-IN tmp#zakaz.SLT-pc IN FRAME Dialog-Frame
   6                                                                    */
/* SETTINGS FOR FILL-IN tmp#zakaz.sum-base IN FRAME Dialog-Frame
   6                                                                    */
/* SETTINGS FOR FILL-IN tmp#zakaz.sum-cli IN FRAME Dialog-Frame
   6                                                                    */
/* SETTINGS FOR FILL-IN tmp#zakaz.sum-excise IN FRAME Dialog-Frame
   6 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN tmp#zakaz.sum-other-base IN FRAME Dialog-Frame
   6 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN tmp#zakaz.sum-other-rubl IN FRAME Dialog-Frame
   6 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN tmp#zakaz.sum-road-tax IN FRAME Dialog-Frame
   6 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN tmp#zakaz.sum-rubl IN FRAME Dialog-Frame
   6                                                                    */
/* SETTINGS FOR FILL-IN tmp#zakaz.sum-SLT IN FRAME Dialog-Frame
   6                                                                    */
/* SETTINGS FOR FILL-IN tmp#zakaz.sum-transport-base IN FRAME Dialog-Frame
   6 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN tmp#zakaz.sum-transport-rubl IN FRAME Dialog-Frame
   6 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN tmp#zakaz.sum-VAT IN FRAME Dialog-Frame
   6                                                                    */
/* SETTINGS FOR FILL-IN tot-base IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       tot-base:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tot-cli IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       tot-cli:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tot-rubl IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       tot-rubl:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tmp#zakaz.transport-base IN FRAME Dialog-Frame
   6                                                                    */
/* SETTINGS FOR FILL-IN tmp#zakaz.transport-rubl IN FRAME Dialog-Frame
   6                                                                    */
/* SETTINGS FOR FILL-IN tmp#zakaz.unit-cli IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tmp#zakaz.VAT-pc IN FRAME Dialog-Frame
   6                                                                    */
/* SETTINGS FOR FRAME FRAME-petrol
                                                                        */
/* BROWSE-TAB BR-PETROL 1 FRAME-petrol */
ASSIGN
       FRAME FRAME-petrol:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-PETROL
/* Query rebuild information for BROWSE BR-PETROL
     _TblList          = "ub.place,ub.rvs-line WHERE ub.place ..."
     _Options          = "NO-LOCK"
     _TblOptList       = ", LAST OUTER"
     _Where[1]         = "place.obj-code = loc-store-code
 AND ub.place.obj-type = loc-store-type
"
     _JoinCode[2]      = "rvs-line.gds-code = ub.goods.gds-code and
 ub.rvs-line.pl-code = ub.place.pl-code
 "
     _FldNameList[1]   > ub.place.pl-code
"place.pl-code" "код" ? "integer" ? ? ? ? ? ? no ?
     _FldNameList[2]   > ub.place.pl-name
"place.pl-name" ? "X(20)" "character" ? ? ? ? ? ? no ?
     _FldNameList[3]   = ub.place.max-qnty
     _FldNameList[4]   = ub.rvs-line.state-measure-qnty
     _Query            is OPENED
*/  /* BROWSE BR-PETROL */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.tmp#zakaz,ub.goods WHERE ub.tmp#zakaz ...,ub.gds-prt WHERE ub.goods ...,ub.clients WHERE ub.tmp#zakaz ..."
     _Options          = "no-LOCK"
     _TblOptList       = ",,,"
     _Where[1]         = "r-tmp = recid ( tmp#zakaz   )"
     _JoinCode[2]      = "ub.goods.artic = ub.tmp#zakaz.artic
  AND ub.goods.prod-code = ub.tmp#zakaz.prod-code
  AND ub.goods.prod-type = ub.tmp#zakaz.prod-type"
     _JoinCode[3]      = "ub.gds-prt.upper-code = ub.goods.prt-root"
     _JoinCode[4]      = "ub.clients.obj-code = ub.tmp#zakaz.prod-code
  AND ub.clients.obj-type = ub.tmp#zakaz.prod-type"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Изменение строки заказа */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-OK Dialog-Frame
ON CHOOSE OF B-OK IN FRAME Dialog-Frame /* Сохр. */
DO:

  stp-cycle  =  false.
  stp-exit  =  false.
  run ver-value in this-procedure no-error.
  if error-status:error then do:
     return no-apply.
  end.
  if  tmp#zakaz.order-cli-qnty = tmp#zakaz.cli-qnty and tmp#zakaz.cli-qnty <> 0
  then do:
      message "Нельзя отправлять заказ на коррекцию с тем же количеством, которое было запрошено первоначально!" view-as alert-box .
      return no-apply.
  end.
  buffer-copy b-ord-line to shar_ord-line
     assign shar_ord-line.doc-code = loc-ord-num
     no-error .

  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "BC"
    view-as alert-box error
  .

END.

ON CHOOSE OF b-cancel IN FRAME {&frame-name}  /*  */
DO:
if line-mode = {&lookup} then do:
    stp-cycle  =  false.
    stp-exit  =  true .
    return.
end.

define variable compare-log as logical no-undo .

if line-mode <> "ЦИКЛ":u   then do:
    BUFFER-COMPARE  tt-ord-line to tmp#zakaz save result in compare-log no-error.
    if compare-log = false then do:
        message "Вы действительно хотите выйти без сохранения изменений ?" view-as alert-box question
                buttons yes-no   update jjj as logical .
                if jjj = true then do:
                     BUFFER-COPY tt-ord-line to  tmp#zakaz .
                end.
                else do:
                  return no-apply .
                end.
    end.
end.
  stp-cycle  =  false.
  stp-exit  =  true .
  return "error".
END.


ON CHOOSE OF b-exit-cycl IN FRAME {&frame-name}  /* СтопЦикл */
DO:
  assign
     stp-cycle  =  true
     stp-exit   =  false.
     .

END.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-prt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-prt Dialog-Frame
ON CHOOSE OF B-prt IN FRAME Dialog-Frame /* Шкала */
DO:
  { cus/ord-lib.i btn-dtl }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-qnty Dialog-Frame
ON CHOOSE OF B-qnty IN FRAME Dialog-Frame /* Прочее */
DO:
  MESSAGE "Режим отключен" VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-units
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-units Dialog-Frame
ON CHOOSE OF r-units IN FRAME Dialog-Frame /* r-units */
DO:
define variable ref-rec as recid no-undo.
  define buffer bf-r-units for ub.units.
  run ref/units.w ( parparentproc, yes, output ref-rec).
  if ref-rec = ? then return no-apply.
  find bf-r-units where recid (bf-r-units) = ref-rec no-lock.
  ASSIGN tmp#zakaz.unit-cli  = bf-r-units.unit-name.
  release bf-r-units.
  display tmp#zakaz.unit-cli with frame {&frame-name}.
  apply "entry" to tmp#zakaz.cli-base-rate.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-PETROL
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

assign
  tmp#zakaz.sum-transport-rubl :label = "Сумма тр.налога ({&abbr_rub})"
  tmp#zakaz.sum-other-rubl     :label = "Сумма др.налогов ({&abbr_rub})"
.

/* Проверка на EDOC-nn */
{ gbl/conf-rd.i "'edoc-nn'" "''" "''" 0 "''" "''" "''" no par-is-edoc-nn par-type no-error }
if error-status :error then is-edoc-nn = false .
assign
  is-edoc-nn = lookup(par-is-edoc-nn, "true,yes":U) > 0
.
{ gbl/conf-rd.i "'is-edi'" "''" "''" 0 "''" "''" "''" no par-is-edi par-type no-error }
if error-status :error then is-edi = false .
assign
  is-edi = lookup(par-is-edi, "true,yes":U) > 0
.

run edoc-nn-proc in this-procedure .

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

{ cus/ord-lib.i   leave-qnty tmp#zakaz }
{ gbl/app_help.i  &disable_diasize_init=false     &browse-name="BR-PETROL"}

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop    UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  g#type = loc-doc-type .
  find first i-ord-doc where i-ord-doc.doc-code = loc-ord-num no-lock no-error .
  if available i-ord-doc then do:
      loc-store-code  = i-ord-doc.obj-code .
      loc-store-type  = i-ord-doc.obj-type .
  end.
  if loc-doc-type = {&f-p} then do:
        for each ub.shop no-lock where ub.shop.host-code   = g#host-code:
            { cmp/cr-objls.i "{&shop}"  ub.shop.obj-code no-error }
        end.
        for each ub.store no-lock  where ub.store.host-code  = g#host-code:
            { cmp/cr-objls.i "{&stock}"  ub.store.obj-code no-error }
        end.
    end.
    else do:
        { cmp/cr-objls.i  loc-store-type  loc-store-code  }
    end.

  find first tmp#zakaz  where  recid ( tmp#zakaz )  = r-tmp  no-error .
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "tmp#zakaz"
    view-as alert-box error
  .

  find first b-ord-line where  recid ( b-ord-line ) = r-tmp  no-error .
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "b-ord-line"
    view-as alert-box error
  .


  if line-mode = {&update} or line-mode = {&add-def} or line-mode = "ЦИКЛ":u  then do:
  find first shar_ord-line  exclusive-lock  where
      shar_ord-line.doc-code  = loc-ord-num          and
      shar_ord-line.artic     = b-ord-line.artic     and
      shar_ord-line.prod-type = b-ord-line.prod-type and
      shar_ord-line.prod-code = b-ord-line.prod-code  no-error .
      if error-status :error then do:
         message vss-workfile vss-revision vss-description skip
                 error-status :get-message(1)
                 "Ошибка поиска строки заказа"
                 "№ :" loc-ord-num    skip
                 "артикул :"
                  b-ord-line.artic
                  b-ord-line.prod-type
                  b-ord-line.prod-code
                  view-as alert-box error .
         return error.
         end.
  end.
  else do:
  find first shar_ord-line  no-lock   where
      shar_ord-line.doc-code  = loc-ord-num          and
      shar_ord-line.artic     = b-ord-line.artic     and
      shar_ord-line.prod-type = b-ord-line.prod-type and
      shar_ord-line.prod-code = b-ord-line.prod-code  no-error .
   end.

  /* сохраним первоначальное значение строки заказа во временную таблицу */
  create tt-ord-line.
  BUFFER-COPY tmp#zakaz to tt-ord-line.


  find first   ub.currency where ub.currency.curr-code = LOC-EXCH-CODE no-lock no-error.
  if available ub.currency then   abbr-cli  = ub.currency.curr-abbr .

  find first   ub.currency where ub.currency.curr-code = base-CODE no-lock no-error.
  if available ub.currency then   abbr-base = ub.currency.curr-abbr .
  abbr-rubl = "{&abbr_rub_allshift}"  .

    { gbl/getsect.i run "''" 0 {&attr-nakl-glob} }
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'vat-ext'   then  dops        = thbjattr_thbj-attr.property-value-character .
        if thbjattr_thbj-attr.prop-code = 'slt-ext'   then  dop-slt     = thbjattr_thbj-attr.property-value-character .
        if thbjattr_thbj-attr.prop-code = 'vat-sum'   then  vat-sumvalue= string(thbjattr_thbj-attr.property-value-logical, "yes/no") .
    end.
    empty temp-table thbjattr_thbj-attr.
   assign
   rdtaxcdvalue  = {&road-tax-code}
   exctaxcdvalue = {&excise-tax-code}
   vattaxcdvalue = {&vat-tax-code}
   .
 run enable_ui.

 if  g#type <> {&f-p} then do:
      find first buf_gds-obj no-lock where
        buf_gds-obj.artic     = ub.goods.artic        and
        buf_gds-obj.prod-type = ub.goods.prod-type    and
        buf_gds-obj.prod-code = ub.goods.prod-code    and
        buf_gds-obj.obj-type = loc-store-type     and
        buf_gds-obj.obj-code = loc-store-code     no-error .
      if available buf_gds-obj then
      display
          buf_gds-obj.fact-qnty @ buf_gds-obj.fact-qnty
          string (round (buf_gds-obj.fact-qnty / ub.goods.cli-base-rate , 3 )) + " " + ub.goods.unit-cli @ v-fact-cli-qnty
          buf_gds-obj.free-qnty
          buf_gds-obj.avrg-qnty
          with frame {&frame-name} .
          if not available buf_gds-obj then
      display
          "-Новый товар-" @ buf_gds-obj.fact-qnty
          with frame {&frame-name} .
 end.
 else do:
   hide
    buf_gds-obj.fact-qnty
    v-fact-cli-qnty
    buf_gds-obj.free-qnty
    buf_gds-obj.avrg-qnty
    in frame {&frame-name} .
 end.
 if b-ord-line.cli-base-rate = 0 or b-ord-line.cli-base-rate = ? then
    kk = ub.goods.cli-base-rate.
    else KK = b-ord-line.cli-base-rate.
   b-ord-line.cli-base-rate  = kk.
   run ui-on no-error .
   if error-status :error then message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     ""
     view-as alert-box error
   .
 if  g#type <> {&f-p} then do:
      find first buf_gds-obj no-lock where
        buf_gds-obj.artic     = ub.goods.artic        and
        buf_gds-obj.prod-type = ub.goods.prod-type    and
        buf_gds-obj.prod-code = ub.goods.prod-code    and
        buf_gds-obj.obj-type = loc-store-type     and
        buf_gds-obj.obj-code = loc-store-code     no-error .
      if available buf_gds-obj then
      display
          buf_gds-obj.fact-qnty @ buf_gds-obj.fact-qnty
          buf_gds-obj.free-qnty
          buf_gds-obj.avrg-qnty
          with frame {&frame-name} .
          if not available buf_gds-obj then
      display
          "-Новый товар-" @ buf_gds-obj.fact-qnty
          with frame {&frame-name} .
 end.

  tmp#zakaz.sum-road-tax:label  =  "Сумма по " + substring( tmp#zakaz.road-tax:label ,1 , 5) +  "." .
  if (i-ord-doc.whole-send-news = integer({&doc-dm-edoc-nn})
      and
      (i-ord-doc.ord-int1 = integer({&edoc-rpl}) or i-ord-doc.ord-int1 = integer({&edoc-rpl-ok}))
      )
  or (i-ord-doc.whole-send-news = integer({&doc-dm-edi})
      and
      (i-ord-doc.ord-int1 = integer({&edi-ordrsp-sts})
       or
       i-ord-doc.ord-int1 = integer({&edi-ordrsp-yes})
       or
       i-ord-doc.ord-int1 = integer({&edi-ordrsp-no})
      ))
  then do:
     disable all with frame {&frame-name} .
     enable B-OK with frame {&frame-name} .
  end.


  if tmp#zakaz.cli-qnty:sensitive in frame {&FRAME-NAME} then do:
      WAIT-FOR GO OF FRAME {&FRAME-NAME} focus  tmp#zakaz.cli-qnty .
  end.
  else do:
      WAIT-FOR GO OF FRAME {&FRAME-NAME} focus  tmp#zakaz.qnty .
  end.
END.
run disable_ui.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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
  HIDE FRAME FRAME-petrol.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  DISPLAY abbr-cli abbr-base abbr-rubl
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.clients THEN
    DISPLAY ub.clients.obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.gds-prt THEN
    DISPLAY ub.gds-prt.node-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.goods THEN
    DISPLAY ub.goods.gds-name ub.goods.qnty-cart ub.goods.wt-cart ub.goods.unit-base
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tmp#zakaz THEN
    DISPLAY tmp#zakaz.cli-art tmp#zakaz.VAT-pc tmp#zakaz.v-vat tmp#zakaz.sum-VAT
          tmp#zakaz.cli-qnty tmp#zakaz.unit-cli tmp#zakaz.SLT-pc
          tmp#zakaz.cli-base-rate tmp#zakaz.qnty tmp#zakaz.price-cli
          tmp#zakaz.price-base tmp#zakaz.price-rubl tmp#zakaz.line-num
          tmp#zakaz.cancel-date tmp#zakaz.road-tax tmp#zakaz.excise
          tmp#zakaz.transport-base tmp#zakaz.other-base tmp#zakaz.transport-rubl
          tmp#zakaz.other-rubl tmp#zakaz.artic tmp#zakaz.prod-type
          tmp#zakaz.prod-code tmp#zakaz.sum-SLT tmp#zakaz.sum-cli tmp#zakaz.sum-base
          tmp#zakaz.sum-rubl tmp#zakaz.sum-road-tax tmp#zakaz.sum-excise
          tmp#zakaz.sum-transport-base tmp#zakaz.sum-other-base
          tmp#zakaz.sum-transport-rubl tmp#zakaz.sum-other-rubl
      WITH FRAME Dialog-Frame.
  ENABLE B-OK B-Cancel b-exit-cycl B-qnty B-prt B-help
         tmp#zakaz.VAT-pc tmp#zakaz.v-vat tmp#zakaz.sum-VAT r-units
         tmp#zakaz.cli-qnty tmp#zakaz.unit-cli tmp#zakaz.SLT-pc
         tmp#zakaz.cli-base-rate tmp#zakaz.qnty tmp#zakaz.price-cli
         tmp#zakaz.price-base tmp#zakaz.price-rubl tmp#zakaz.line-num
         tmp#zakaz.cancel-date tmp#zakaz.road-tax tmp#zakaz.excise
         tmp#zakaz.transport-base tmp#zakaz.other-base tmp#zakaz.transport-rubl
         tmp#zakaz.other-rubl tmp#zakaz.artic ub.goods.gds-name tmp#zakaz.prod-type
         ub.clients.obj-name tmp#zakaz.prod-code ub.goods.qnty-cart ub.goods.wt-cart
         tmp#zakaz.sum-SLT ub.goods.unit-base abbr-cli tmp#zakaz.sum-cli abbr-base
         tmp#zakaz.sum-base abbr-rubl tmp#zakaz.sum-rubl ub.gds-prt.node-name
         tmp#zakaz.sum-road-tax tmp#zakaz.sum-excise tmp#zakaz.sum-transport-base
         tmp#zakaz.sum-other-base tmp#zakaz.sum-transport-rubl
         tmp#zakaz.sum-other-rubl
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.

  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  /*
  */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE 11 W-Win
PROCEDURE UI-on :
 do
 on error undo, return error return-value
 :

define variable gds-rec as recid no-undo .
define variable sss as character no-undo .
find current ub.goods no-lock no-error .
gds-rec = recid( ub.goods ) .
{ str/is-petrl.i
  ub.goods.artic
  ub.goods.prod-type
  ub.goods.prod-code
  is-petrolium
  is-pieces
  no-error }
if error-status :error then
message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "is-petrl.i"
  view-as alert-box error
.
is-petrolium = false .

if is-petrolium = true then  run run-petrol in this-procedure no-error .
if error-status :error then message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "run-petrol"
  view-as alert-box error
.
run ass-var in this-procedure no-error .
if error-status :error then
 message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "из программы ass-var"
  view-as alert-box error
.

  assign
    tmp#zakaz.sum-rubl   =  tmp#zakaz.price-rubl * tmp#zakaz.qnty
    tmp#zakaz.sum-base   =  tmp#zakaz.price-base * tmp#zakaz.qnty
    tmp#zakaz.sum-cli    =  tmp#zakaz.price-cli  * tmp#zakaz.cli-qnty
  .

if g#type <> {&o-f}  then do:
    display
    tmp#zakaz.sum-rubl
    tmp#zakaz.sum-base
    tmp#zakaz.sum-cli
    with frame {&frame-name} .
end.

sss = (if g#type = {&o-f}  then "Заявка № " else "Заказ № ") + loc-ord-num + line-mode.
 assign frame {&frame-name}:title  = sss  .
   if slt_type = {&without-slt} and g#type <> {&o-f} then do:
      disable tmp#zakaz.SLT-pc  tmp#zakaz.sum-SLT      with frame {&frame-name} .
      display tmp#zakaz.SLT-pc  tmp#zakaz.sum-SLT      with frame {&frame-name} .
   end.
   if vat_type = {&without-vat} and g#type <> {&o-f} then do:
      disable tmp#zakaz.vat-pc  tmp#zakaz.sum-vat      with frame {&frame-name} .
      display tmp#zakaz.vat-pc  tmp#zakaz.sum-vat      with frame {&frame-name} .
   end.

   if  g#type = {&o-f} or line-mode = {&lookup} then do:
      disable tmp#zakaz.SLT-pc  tmp#zakaz.sum-SLT  tmp#zakaz.vat-pc  tmp#zakaz.sum-vat tmp#zakaz.v-vat with frame {&frame-name} .
      display tmp#zakaz.SLT-pc  tmp#zakaz.sum-SLT  tmp#zakaz.vat-pc  tmp#zakaz.sum-vat tmp#zakaz.v-vat with frame {&frame-name} .
   end.
   disable tmp#zakaz.sum-vat tmp#zakaz.v-vat with frame {&frame-name} .

   if line-mode = {&lookup} then do:
     disable all with frame {&frame-name} .
     enable B-Cancel with frame {&frame-name} .
   end.

  if  line-mode = "ЦИКЛ":U then do:
     enable  b-exit-cycl with frame {&FRAME-NAME}.
     display b-exit-cycl  with frame {&FRAME-NAME}.
  end.

  if  line-mode = {&update} then do:
     disable  b-exit-cycl  with frame {&FRAME-NAME}.
  end.
  if  line-mode = {&lookup} then do:
     disable  b-exit-cycl   with frame {&FRAME-NAME}.
  end.
  /* непоказывать пока всегда */
  hide tmp#zakaz.excise             tmp#zakaz.sum-excise
       tmp#zakaz.transport-base     tmp#zakaz.transport-rubl
       tmp#zakaz.sum-transport-base tmp#zakaz.sum-transport-rubl
       tmp#zakaz.other-base         tmp#zakaz.other-rubl
       tmp#zakaz.sum-other-base     tmp#zakaz.sum-other-rubl
       B-qnty B-prt        tmp#zakaz.line-num
      in frame {&frame-name} .
  if  g#type = {&o-f}  then do:
  /* непоказывать для заявок */
    hide
     tmp#zakaz.VAT-pc
     tmp#zakaz.v-vat
     tmp#zakaz.sum-VAT
     tmp#zakaz.SLT-pc
     tot-cli
     tmp#zakaz.price-cli
     tot-rubl
     tmp#zakaz.price-base
     tot-base
     tmp#zakaz.price-rubl
     tmp#zakaz.line-num
     tmp#zakaz.cancel-date
     tmp#zakaz.road-tax
     tmp#zakaz.excise
     tmp#zakaz.transport-base
     tmp#zakaz.other-base
     tmp#zakaz.transport-rubl
     tmp#zakaz.other-rubl
     tmp#zakaz.sum-SLT
     tmp#zakaz.sum-cli
     abbr-base
     tmp#zakaz.sum-base
     abbr-rubl
     tmp#zakaz.sum-rubl
     tmp#zakaz.sum-road-tax
     tmp#zakaz.sum-excise
     tmp#zakaz.sum-transport-base
     tmp#zakaz.sum-other-base
     tmp#zakaz.sum-transport-rubl
     tmp#zakaz.sum-other-rubl
     in frame {&frame-name} .
  end.
end.
END PROCEDURE.

procedure run-petrol :
  do
  on error undo, return error
  :

 assign
   N-1 = 0  N-2 = 0
 .
 for each obj-list ,
    EACH ub.place no-lock
      WHERE  ub.place.obj-code = obj-list.obj-code
         AND ub.place.obj-type = obj-list.obj-type ,
         first ub.pl-gds no-lock where
                    ub.pl-gds.gds-code = ub.goods.gds-code  and
                    ub.pl-gds.pl-code = ub.place.pl-code    and
                    ub.pl-gds.obj-code = ub.place.obj-code  and
                    ub.pl-gds.obj-type = ub.place.obj-type  :

         N-1 = N-1 + ub.place.max-qnty.
         find LAST ub.rvs-line no-lock  WHERE
                    ub.rvs-line.gds-code = ub.goods.gds-code and
                    ub.rvs-line.pl-code = ub.place.pl-code
                    no-error .
                    if avail  ub.rvs-line then do:
                       find first ub.rvs-doc no-lock where ub.rvs-doc.rvs-code = ub.rvs-line.rvs-code and
                                           ub.rvs-doc.status_ = {&fact} no-error .
                       if available ub.rvs-doc then do:
                          N-2  =  N-2 + ub.rvs-line.state-measure-qnty .
                       end.
                    end.
 end.

 N-2 = N-1 - N-2.
  DISPLAY N-1 N-2
      WITH FRAME FRAME-petrol.
  ENABLE BR-PETROL N-1 N-2
      WITH FRAME FRAME-petrol.
  VIEW FRAME FRAME-petrol.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-petrol}

end.
end procedure. /* run-petrol */


procedure ver-value :
 do
 on error undo, return error return-value
 :

define buffer bf-units-cli for ub.units.
/*-----------------------------------------------------*/
/* Проверка того, что отработали все триггера на leave */
/*-----------------------------------------------------*/

&scop ver-trg if ~
  ~{&v-pole}:sensitive in frame ~{&frame-name} and input frame ~{&frame-name} ~{&v-pole}  <> ~{&v-pole}  then apply "leave" to ~{&v-pole}  in frame ~{&frame-name}.

&scop v-pole tmp#zakaz.cli-art
 {&ver-trg}
&scop v-pole tmp#zakaz.vat-pc
 {&ver-trg}
&scop v-pole tmp#zakaz.sum-vat
 {&ver-trg}
&scop v-pole tmp#zakaz.cli-qnty
 {&ver-trg}
&scop v-pole tmp#zakaz.slt-pc
 {&ver-trg}
&scop v-pole tmp#zakaz.sum-slt
 {&ver-trg}
&scop v-pole tmp#zakaz.qnty
 {&ver-trg}
&scop v-pole tmp#zakaz.price-cli
 {&ver-trg}
&scop v-pole tmp#zakaz.price-base
 {&ver-trg}
&scop v-pole tmp#zakaz.price-rubl
 {&ver-trg}
&scop v-pole tmp#zakaz.cli-base-rate
 {&ver-trg}
&scop v-pole tmp#zakaz.road-tax
 {&ver-trg}
&scop v-pole tmp#zakaz.line-num
 {&ver-trg}
&scop v-pole tmp#zakaz.sum-road-tax
 {&ver-trg}
&scop v-pole tmp#zakaz.cancel-date
 {&ver-trg}
&scop v-pole tmp#zakaz.excise
 {&ver-trg}
&scop v-pole tmp#zakaz.sum-excise
 {&ver-trg}
&scop v-pole tmp#zakaz.transport-base
 {&ver-trg}
&scop v-pole tmp#zakaz.other-base
 {&ver-trg}
&scop v-pole tmp#zakaz.transport-rubl
 {&ver-trg}
&scop v-pole tmp#zakaz.other-rubl
 {&ver-trg}
&scop v-pole tmp#zakaz.sum-transport-base
 {&ver-trg}
&scop v-pole tmp#zakaz.sum-other-base
 {&ver-trg}
&scop v-pole tmp#zakaz.sum-transport-rubl
 {&ver-trg}
&scop v-pole tmp#zakaz.sum-other-rubl
 {&ver-trg}
&scop v-pole tmp#zakaz.sum-cli
 {&ver-trg}
&scop v-pole tmp#zakaz.sum-base
 {&ver-trg}
&scop v-pole tmp#zakaz.sum-rubl
 {&ver-trg}
  assign frame {&frame-name} {&ass-f} .
  if tmp#zakaz.cli-qnty:sensitive in frame {&frame-name} and  (tmp#zakaz.cli-qnty = 0 or tmp#zakaz.cli-qnty = ?) /* and loc-status <> {&g___new} */ then do:
    message "Не указано количество в единицах поставщика." view-as alert-box error.
    if tmp#zakaz.cli-qnty:sensitive in frame {&frame-name} then apply "entry" to tmp#zakaz.cli-qnty in frame {&frame-name}.
                                                           else apply "entry" to b-cancel           in frame {&frame-name}.
    return error.
  end.
  if tmp#zakaz.qnty:sensitive in frame {&frame-name} and  (tmp#zakaz.qnty = 0 or tmp#zakaz.qnty = ?) /* and loc-status <> {&g___new} */ then do:
    message "Не указано количество  в учетных единицах." view-as alert-box error.
    return error.
  end.
  if  tmp#zakaz.qnty:sensitive in frame {&frame-name} and
     lookup ( {&pieces}, tmp#zakaz.unit-type) > 0      and
     trunc ( tmp#zakaz.qnty, 0) <> tmp#zakaz.qnty then do:
      message "Базовая единица товара " tmp#zakaz.unit-base " - штучная." skip
              "Кол-во должно быть целым."
      view-as alert-box error buttons ok.
      return error.
  end.

  find bf-units-cli where bf-units-cli.unit-name = tmp#zakaz.unit-cli no-lock no-error.
  if not available bf-units-cli then do:
    message "Неправильная единица измерения." view-as alert-box error.
    return error.
  end.
  /*Если единица поставщика штучная, то кол-во от поставщика должно указываться целым*/
  if  tmp#zakaz.cli-qnty:sensitive in frame {&frame-name} and
      lookup({&pieces}, bf-units-cli.type) > 0  and
      trunc (tmp#zakaz.cli-qnty, 0) <> tmp#zakaz.cli-qnty then do:
      message "Единица поставщика " tmp#zakaz.unit-cli " - штучная." skip
              "Должно быть указано целое количество в единицах поставщика."
      view-as alert-box error buttons ok.
      return error.
  end.
  release bf-units-cli.

  if tmp#zakaz.cli-base-rate:sensitive in frame {&frame-name} and (tmp#zakaz.cli-base-rate = 0 or tmp#zakaz.cli-base-rate = ?) then do:
    message "Не указан коэффициент пересчета единиц измерения." view-as alert-box error.
    return error.
  end.
  if tmp#zakaz.unit-cli = tmp#zakaz.unit-base and tmp#zakaz.cli-base-rate <> 1 then do:
    message "Коэффициент пересчета единиц измерения должен быть 1, т.к. единицы совпадают." view-as alert-box error.
    return error.
  end.

  if  loc-status <> "" /* {&g___new} */ then do:
    if tmp#zakaz.price-cli:sensitive in frame {&frame-name} and ( tmp#zakaz.price-cli = 0 or tmp#zakaz.price-cli = ?) then do:
      message "Не указана цена в валюте поставщика." view-as alert-box error.
      return error.
    end.
    if tmp#zakaz.price-cli < 0  then do:
      message "Нельзя указывать отрицательные цены в валюте поставщика." view-as alert-box error.
      return error.
    end.
    if tmp#zakaz.price-base:sensitive in frame {&frame-name} and (tmp#zakaz.price-base = 0 or tmp#zakaz.price-base = ?) then do:
      message "Не указана цена в базовой валюте." view-as alert-box error.
      return error.
    end.
    if tmp#zakaz.price-base < 0  then do:
      message "Отрицательная цена в базовой валюте."  view-as alert-box error.
      return error.
    end.
    /*!!!*/
    if tmp#zakaz.price-base > 5000 and base-code = 1 then
      message "Внимание !!!" skip (2)
              "ВАЛЮТНАЯ цена превышает 5,000 !" skip (2)
              "Вы не ошиблись ?"  view-as alert-box question.

    if tmp#zakaz.price-rubl:sensitive in frame {&frame-name} and (tmp#zakaz.price-rubl = 0 or tmp#zakaz.price-rubl = ?) then do:
      message "Не указана цена в {&abbr_rublyah}." view-as alert-box error.
      return error.
    end.
    if tmp#zakaz.price-rubl < 0 then do:
      message "Отрицательная цена в {&abbr_rublyah}."  view-as alert-box error.
      return error.
    end.
  end.

  if is-petrolium = true then do:
   if n-1 < tmp#zakaz.qnty then do:
   message "Внимание !!! Заказано  больше, чем общий объем мест хранения! "  view-as alert-box error  .
    /* return error. */  /* так и быть пропускаем дальше */
   end.
  end.

/* для жесткости все пересчитаем */
  assign
    tmp#zakaz.price-base =  tmp#zakaz.price-rubl  / loc-base-rate * loc-base-scale
    tmp#zakaz.qnty       =  tmp#zakaz.cli-qnty   * tmp#zakaz.cli-base-rate
    tmp#zakaz.sum-rubl   =  tmp#zakaz.price-rubl * tmp#zakaz.qnty
    tmp#zakaz.sum-base   =  tmp#zakaz.price-base * tmp#zakaz.qnty
    tmp#zakaz.sum-cli    =  tmp#zakaz.price-cli  * tmp#zakaz.cli-qnty
  .
if ( is-edoc-nn-doc = false and shar_ord-doc.ord-int1 = int({&edoc-empty}) )
  or ( is-edi-doc     = false and shar_ord-doc.ord-int1 = int({&edi-empty})  )
  then do:

    /* Проверка возможности корректирования количества по Объекту, Поставщику и группе Товаров, если был авторасчет */
    define variable v-not-corr-op as character no-undo .
    define variable p-type as character no-undo .
    if (tmp#zakaz.qnty <> tmp#zakaz.initial-qnty and e-method <> "") then do: /*заказ рассчитан, кол-во изменено*/
      v-not-corr-op  = 'no' .
      run clntattr-value (
            input   loc-store-type
          , input   loc-store-code
          , input   {&attr-not-corr-op}
          , output  v-not-corr-op
          , output  p-type
      ) no-error .
      if error-status :error then v-not-corr-op  = 'no' .
      if v-not-corr-op  = 'yes' then do: /*на объекте обязателен авторасчет, проверяем клиента и товар*/
        v-not-corr-op  = 'no' .
        run clntattr-value (
              input   loc-cli-type
            , input   loc-cli-code
            , input   {&attr-not-corr-op}
            , output  v-not-corr-op
            , output  p-type
        ) no-error .
        if error-status :error then v-not-corr-op  = 'no' .
        if v-not-corr-op  = 'yes' then do:
          message substitute ( "Был произведен автоматический расчет заказа, количество должно быть &1&4Запрещено менять рассчитанные количества  по Поставщику &2&3 " ,
                  tmp#zakaz.initial-qnty ,
                  loc-cli-type ,
                  loc-cli-code ,
                  {&new-line} )
          view-as alert-box information .
          return error.
        end.

        define buffer buf_goods for ub.goods  .
        find first  buf_goods no-lock where
                    buf_goods.artic = tmp#zakaz.artic and
                    buf_goods.prod-type = tmp#zakaz.prod-type and
                    buf_goods.prod-code = tmp#zakaz.prod-code no-error .
        assign
          tmp#zakaz.gds-code = buf_goods.gds-code
          v-not-corr-op  = 'no'
        .
        run ggoattr-value (
          input   buf_goods.grp-code
          ,input   v-cntxt-host-code-obj
          ,input   v-cntxt-obj-type
          ,input   v-cntxt-obj-code
          ,input   {&ggoattr-NotCorrOP}
          ,output  v-not-corr-op
          ,output  p-type ) no-error .

        if error-status :error then v-not-corr-op  = 'no' .
        if v-not-corr-op  = 'yes' then do:
          message substitute("Был произведен автоматический расчет заказа, количество должно быть &1&4Запрещено менять расcчитанные количества  по Группе товаров (&2) &3 " ,
                  tmp#zakaz.initial-qnty ,
                  buf_goods.grp-code ,
                  buf_goods.grp-name ,
                  {&new-line})
          view-as alert-box information .
          return error.
        end.
      end.
    end.
  end.
end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE edoc-nn-proc W-Win
PROCEDURE edoc-nn-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

if  (is-edoc-nn
and shar_ord-doc.whole-send-news = integer({&doc-dm-edoc-nn})
and
    ( shar_ord-doc.ord-int1 = int ({&edoc-rpl-ok}) or
      shar_ord-doc.ord-int1 = int ({&edoc-rpl})  or
      ( shar_ord-doc.ord-int1 = int ({&edoc-empty})  and
        shar_ord-doc.ord-int2 = int ({&edoc-return}))
      ) and
    ( shar_ord-doc.doc-type = {&O-P} ) and
      shar_ord-doc.status_ = {&g___new}
      )
or  (is-edi
and shar_ord-doc.whole-send-news = integer({&doc-dm-edi})
and shar_ord-doc.ord-int1 = int ({&edi-ordrsp})
and shar_ord-doc.ord-int2 = int ({&edoc-return})
and shar_ord-doc.doc-type = {&O-P}
and shar_ord-doc.status_ = {&g___new}
)
 then do:
    display
      tmp#zakaz.order-cli-qnty
      tmp#zakaz.ord-dec1
      tmp#zakaz.sub-par
      with frame {&frame-name} .

      if tmp#zakaz.order-cli-qnty <> tmp#zakaz.cli-qnty then tmp#zakaz.order-cli-qnty:bgcolor = 12 /* red */ .
         else tmp#zakaz.order-cli-qnty:bgcolor = 15 /* white*/ .

      if tmp#zakaz.ord-dec1 <> tmp#zakaz.price-cli then     tmp#zakaz.ord-dec1:bgcolor = 12 .
      else tmp#zakaz.ord-dec1:bgcolor = 15.
      .
  if shar_ord-doc.whole-send-news = integer({&doc-dm-edi}) then do:
    disable
    tmp#zakaz.cli-art
    with frame {&frame-name} .
  end.
end.
else do:
      hide
        tmp#zakaz.order-cli-qnty
        tmp#zakaz.ord-dec1
        tmp#zakaz.sub-par
        in frame {&frame-name} .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME