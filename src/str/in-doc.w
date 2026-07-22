&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-in-doc


/* Temp-Table and Buffer definitions                                    */
using ibs.th.gbl.storage.*.
using ibs.th.str.*.
DEFINE BUFFER t-doc FOR ub.trn-doc.
DEFINE BUFFER src-doc FOR ub.trn-doc.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-in-doc
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка приходной накладной (заведение, редактирование)

Автор: Чернова Светлана Александровна
Дата создания: 10/05/06
Author: Svetlana Chernova
Creation date: 10/05/06

create Суслов

ub.t-doc  == t-doc

*/
define input        parameter parparentproc   as   handle                  no-undo.
define input-output parameter pardoc-rec      as   recid                   no-undo.
define input        parameter pardoc-mode     as   character               no-undo.
define input        parameter partype         as   character               no-undo.
define input        parameter parinternal     as   logical                 no-undo. /* при добавлении документа */
define input-output parameter parnext-prev    as   logical                 no-undo.
define input        parameter parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define input        parameter paris-hold      as   logical                 no-undo.
define input-output parameter line-rec        as   recid                   no-undo.
define input        parameter br-handle       as   handle                  no-undo.
define input        parameter bf-handle       as   handle                  no-undo.
define input        parameter parstat         as   character               no-undo.
/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Обработка приходной накладной (заведение, редактирование)":U .

define temp-table old-doc-line no-undo like ub.doc-line.
define buffer doc-line for ub.doc-line  .
{ cmp/vssrevis.i "substitute('&1|&2':u,parext-doc-type,paris-hold)" }

&global-define is-fuel 1
&global-define is-lgas 2
&global-define is-lgas-corr 3
&global-define is-gds 4
define variable trn-type as integer no-undo init 0.

{ cmp/str-glbl.i              }
{ cmp/library.i               }
{ cmp/showinf.i               }
{ str/libbcrcn.i              }
{ str/plgdsfnd.i              }
{ cmp/r-pril.i  new           }
{ rep/v-suppl.i new new       }
{ gbl/tax-name.i              }
{ str/lib-trn.i               }
{ gbl/cur-time.i              }
{ str/tax-val.i               }
{ str/lib-def.i               }
{ str/doc-code.i              }
{ str/lib-calc.i              }
{ str/prescan.i               }
/*{ str/cpprclig.i              }*/
{ str/renum.i                 }
{ gbl/waitfram.i              }
{ str/trdcalib.i              }
{ str/scr-neb.i               }
{ gbl/clntattr.i              }
{ str/attrlist.i              }
{ gbl/getcntxt.i def          }
{ gbl/getcntxt.i get          }
{ str/getctxtp.i def          }
{ str/getctxtp.i get          }
{ str/lib-rvs.i               }
{ trg/factord.i               }
{ str/in-ptrl.i  def all-line }
{ gbl/getsect.i  def          }
{ gbl/lineattr.i              }
{ str/prslnew.i "proc"        }
{ ref/gdsoattr.i              }
{ str/cont-ms.i}
{ref/imagelist.i}
{ gbl/color.i }
{ str/temp_upd.i }
{ibs/th/bge/egais/ab-egais.i 1 new shared}
{ str/marks.i         }
{ gbl/objsrv.i }
{ utl/gtin.i }


&global-define store-type v-cntxt-obj-type
&global-define store-code v-cntxt-obj-code
&SCOP term-b-c           not can-find (first ub.gds-prt where ub.gds-prt.upper-code = bar-code.node-code)
&SCOP term-b-c-no-empty  ub.gds-prt.node-name <> {&empty-scale} and not can-find (first ub.gds-prt where ub.gds-prt.upper-code = bar-code.node-code)
&Scop BROWSE-NAME br-dtl
&Scop OPEN-QUERY-br-dtl OPEN QUERY {&browse-name}    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK, ~
      EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK, ~
      first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK, ~
      EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK

&SCOP open-query-br-dtl-another sort-default = no.  {&open-query-br-dtl}
&scop open-query-br-dtl-default sort-default = yes. {&open-query-br-dtl} BY  ub.doc-line.line-num.

define variable varprice-cli                like ub.doc-line.price-rubl        no-undo.
define variable varprice-cli-unit-base      like ub.doc-line.price-rubl        no-undo.
define variable varprice-road-tax           like ub.doc-line.price-rubl        no-undo.
define variable varprice-other-exp          like ub.doc-line.price-rubl        no-undo.
define variable varprice-transport-exp      like ub.doc-line.price-rubl        no-undo.
define variable varprice-without-abs        like ub.doc-line.price-rubl        no-undo.
define variable varprice-slt                like ub.doc-line.price-rubl        no-undo.
define variable varprice-no-slt             like ub.doc-line.price-rubl        no-undo.
define variable varprice-vat                like ub.doc-line.price-rubl        no-undo.
define variable varprice-no-vat-slt         like ub.doc-line.price-rubl        no-undo.
define variable varprice-rubl               like ub.doc-line.price-rubl        no-undo.
define variable varprice-road-tax-rubl      like ub.doc-line.price-rubl        no-undo.
define variable varprice-other-exp-rubl     like ub.doc-line.price-rubl        no-undo.
define variable varprice-transport-exp-rubl like ub.doc-line.price-rubl        no-undo.
define variable varprice-without-abs-rubl   like ub.doc-line.price-rubl        no-undo.
define variable varprice-slt-rubl           like ub.doc-line.price-rubl        no-undo.
define variable varprice-no-slt-rubl        like ub.doc-line.price-rubl        no-undo.
define variable varprice-vat-rubl           like ub.doc-line.price-rubl        no-undo.
define variable varprice-no-vat-slt-rubl    like ub.doc-line.price-rubl        no-undo.
define variable varprice-base               like ub.doc-line.price-base        no-undo.
define variable varprice-road-tax-base      like ub.doc-line.price-base        no-undo.
define variable varprice-other-exp-base     like ub.doc-line.price-base        no-undo.
define variable varprice-transport-exp-base like ub.doc-line.price-base        no-undo.
define variable varprice-without-abs-base   like ub.doc-line.price-base        no-undo.
define variable varprice-slt-base           like ub.doc-line.price-base        no-undo.
define variable varprice-no-slt-base        like ub.doc-line.price-base        no-undo.
define variable varprice-vat-base           like ub.doc-line.price-base        no-undo.
define variable varprice-no-vat-slt-base    like ub.doc-line.price-base        no-undo.
define variable varprice-cli-temp           like ub.doc-line.price-cli         no-undo.
define variable varprice-base-temp          like ub.doc-line.price-base        no-undo.
define variable varprice-rubl-temp          like ub.doc-line.price-rubl        no-undo.
define variable ref-list                    as   character                     no-undo.
define variable conf-par                    as   character                     no-undo. /* для чтения параметра конфигурации */
define variable custvalue                   as   character initial ?           no-undo.
define variable custtype                    as   character initial ?           no-undo.
define variable prtvalue                    as   character initial ?           no-undo.
define variable prttype                     as   character initial ?           no-undo.
define variable curclivalue                 as   character initial ?           no-undo.
define variable curclitype                  as   character initial ?           no-undo.
define variable inv-shipvalue               as   logical   initial ?           no-undo.
define variable bcvalue                     as   character initial ?           no-undo.
define variable bctype                      as   character initial ?           no-undo.
define variable multdtypvalue               as   character initial ?           no-undo.
define variable multdtyptype                as   character initial ?           no-undo.
define variable is-ovvalue                  as   character initial ?           no-undo.
define variable is-ovtype                   as   character initial ?           no-undo.
define variable rdtaxcdvalue                as   character initial ?           no-undo.
define variable vattaxcdvalue               as   character initial ?           no-undo.
define variable exctaxcdvalue               as   character initial ?           no-undo.
define variable varhold                     as   character initial ?           no-undo.
define variable varhold-type                as   character initial ?           no-undo.
define variable convimpvalue                as   character initial ?           no-undo.
define variable convimptype                 as   character initial ?           no-undo.
define variable temp-sale                   like ub.price-list.price-sale      no-undo.
define variable add-sens                    as   logical                       no-undo. /* активна ли кнопка добавить в документе : yes / no - вызов из документа*/
define variable ret-mode                    as   character                     no-undo. /*режим обработки бар-кода*/
define variable add-scan                    as   logical initial no            no-undo.
define variable bar-str                     like ub.prod-bc.b-str              no-undo. /* строка для чтения бар-кода из файла       */
define variable rdtaxname                   as   character                     no-undo.
define variable varvat-pc                   like ub.doc-line.vat-pc            no-undo.
define variable varslt-pc                   like ub.doc-line.slt-pc            no-undo.
define variable varcli-base-rate            like ub.doc-line.cli-base-rate     no-undo.
define variable vardoc-qnty                 like ub.doc-line.doc-qnty          no-undo.
define variable varfact-qnty                like ub.doc-line.doc-qnty          no-undo.
define variable varroad-tax                 like ub.doc-line.road-tax          no-undo.
define variable varexcise                   like ub.doc-line.excise            no-undo.
define variable varother-base               like ub.doc-line.other-base        no-undo.
define variable varother-rubl               like ub.doc-line.other-base        no-undo.
define variable vartransport-rubl           like ub.doc-line.transport-base    no-undo.
define variable vartransport-base           like ub.doc-line.transport-base    no-undo.
define variable varartic                    like ub.doc-line.artic             no-undo.
define variable varprod-type                like ub.doc-line.prod-type         no-undo.
define variable varprod-code                like ub.doc-line.prod-code         no-undo.
define variable v-other                     as   character                     no-undo.
define variable m-outs-5                    as   widget-handle                 no-undo.
define variable varr-b                      as   character                     no-undo.
define variable varvat-type-int             as   integer   initial ?           no-undo.
define variable varvat-type-type            as   character initial ?           no-undo.
define variable varvat-type-def             as   character                     no-undo.
define variable varslt-type-int             as   integer   initial ?           no-undo.
define variable varslt-type-type            as   character initial ?           no-undo.
define variable varslt-type-def             as   character                     no-undo.
define variable varvalue                    as   character                     no-undo.
define variable vartype                     as   character                     no-undo.
define variable vartpsi                     as   character                     no-undo.
define variable vartpsi-type                as   character                     no-undo.
define variable v-is-tsd                    as   character                     no-undo.
define variable v-is-tsd-type               as   character                     no-undo.
define variable v-is-pharm                  as   character                     no-undo.
define variable v-is-pharm-type             as   character                     no-undo.
define variable varlog                      as   logical                       no-undo.
define variable gds-rec                     as   recid                         no-undo.
define variable ref-rec                     as   recid                         no-undo.
define variable base-type                   as   character                     no-undo.
define variable varlns-cnt                  as   integer                       no-undo.
define variable prt-rec                     as   recid                         no-undo.
define variable varnotes                    as   character                     no-undo.
define variable parext-doc-mode             as   character                     no-undo.
define variable varst-qnty-pl               as   logical                       no-undo.
define variable v-is-ptrl                   as   character                     no-undo.
define variable v-data-type                 as   character                     no-undo.
define variable is-doc-hold                 as   logical                       no-undo.
define variable d-reason                    as   character                     no-undo.
define variable ch-vsd as character no-undo .
/*define variable is-fuel as logical no-undo initial no.*/
/*define variable is-lgas as logical no-undo initial no.*/
define variable choice as integer no-undo.
define variable isEgais  as logical   no-undo .
define variable v-mercury-value as character no-undo .
define variable v-mercury-type  as character no-undo .
define variable v-is-mercury-value as logical no-undo .
define variable vsdstrObj as class vsdtostorage no-undo.
define variable bcol as handle extent no-undo.
define variable hBrowse as handle no-undo.
define variable ii as integer no-undo.
define variable is-copy as logical no-undo.
define variable docrec-src as recid no-undo.
define variable varattr as character no-undo.
define variable v-modeetc as character no-undo.

define variable d-kg-after-qnty like ub.doc-line.fact-qnty  no-undo.
define variable d-kg-price-rubl like ub.doc-line.price-rubl no-undo.
define variable d-kg-price-base like ub.doc-line.price-base no-undo.
define variable d-kg-fact-qnty  like ub.doc-line.fact-qnty  no-undo.
define buffer oldoc-line for ub.doc-line.
define buffer cli-buf    for ub.clients. /* чтоб не поломать покупателя */
define buffer t-d-b      for ub.trn-doc.
define buffer d-l-b      for ub.doc-line.
define buffer bf-trn-doc for ub.trn-doc.
define buffer bf_parts for ub.parts.
define buffer l-doc-line for ub.doc-line. /* для поиска  */
define buffer bf_sysconf for ub.sysconf.
define buffer buf_marking for ub.marking.
define buffer buf_marking-lines for ub.marking-lines.

define variable sort-default       as logical   no-undo .
define variable del-list           as character no-undo .
define variable base-abbr          as character format "x(3)":u view-as TEXT size 4 by 1 no-undo.
define variable is-add-doc         as logical   no-undo .
define variable v-is-gtd-part      as character no-undo .
define variable v-is-gtd-part-type as character no-undo .
define variable d-gtd-add          as character no-undo .
define variable var-inp_sum        as logical   no-undo .

define variable v-tth             as handle no-undo .
define variable v-back-date as logical   no-undo .
define variable v-not-ord   as logical   no-undo .
define variable v-edit-fact-wayb as logical   no-undo .
define variable v-fact-qnty as character no-undo.

define variable v-can-edit as logical init yes .
define variable v-trnscanqr as logical no-undo .
define variable v-by-utd as logical no-undo .

define new shared variable PrintScale   as logical init true no-undo.
define new shared variable CostPrice    as logical no-undo.
define new shared variable sort-name    as logical no-undo.
define new shared variable sort-gr      as logical no-undo.
define new shared variable print-graft  as logical no-undo.
define new shared variable PrintParts   as logical no-undo .

function get-name returns character
(buffer buf_doc-line for ub.doc-line,
 buffer buf_goods    for ub.goods,
 buffer buf_gds-prt    for ub.gds-prt) :
define buffer buf_gds-dtl for ub.gds-dtl.

if buf_gds-prt.node-name = {&empty-scale} then return '-' .
else do:
  if can-find (first buf_gds-dtl where
        buf_gds-dtl.artic     = buf_goods.artic
    and buf_gds-dtl.prod-type = buf_goods.prod-type
    and buf_gds-dtl.prod-code = buf_goods.prod-code
    and buf_gds-dtl.prt-code  = buf_gds-prt.node-code
    and buf_gds-dtl.doc-code  = buf_doc-line.doc-code no-lock)
        then return '--------------------'.
        else buf_gds-prt.node-name .
end.
end function.

assign
  parext-doc-mode =
    ( if num-entries( pardoc-mode, '{&delim-flt}':U ) > 1 then entry( 2, pardoc-mode, '{&delim-flt}':U ) else '':U )
  pardoc-mode     = entry( 1, pardoc-mode, '{&delim-flt}':U )
.
run cr-tt-upd in this-procedure no-error.
if error-status :error then do: return error. end.

{ cmp/titlmode.i }

&scop stdbtn ~
if lookup( self :type in frame {&frame-name}, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do: ~
  apply "ENTRY":U to self in frame {&frame-name} . ~
  if focus :handle <> self :handle in frame {&frame-name} then do: ~
    return no-apply . ~
  end. ~
end.

&scop label-clmn_1-br-dtl  '*'
&scop sort-clmn_1-br-dtl    get-mark  (BUFFER  ub.doc-line)
&scop label-clmn_2-br-dtl   'П/П'
&scop sort-clmn_2-br-dtl     ub.doc-line.line-num
&scop label-clmn_3-br-dtl   'Ш'
&scop sort-clmn_3-br-dtl     ub.doc-line.prt-OK
&scop label-clmn_4-br-dtl   'Артикул'
&scop sort-clmn_4-br-dtl     ub.doc-line.artic
&scop label-clmn_5-br-dtl   'Название'
&scop sort-clmn_5-br-dtl    ub.goods.gds-name
&scop label-clmn_6-br-dtl   'По ТТН'
&scop sort-clmn_6-br-dtl     ub.doc-line.cli-qnty
&scop label-clmn_7-br-dtl   'Изм'
&scop sort-clmn_7-br-dtl     ub.doc-line.unit-cli
&scop label-clmn_8-br-dtl   'Цена пост.'
&scop sort-clmn_8-br-dtl     ub.doc-line.price-cli
&scop label-clmn_9-br-dtl   'Сумма пост.'
&scop sort-clmn_9-br-dtl    ( ub.doc-line.cli-qnty *  ub.doc-line.price-cli)
&scop label-clmn_10-br-dtl  'По док-ту'
&scop sort-clmn_10-br-dtl    ub.doc-line.doc-qnty
&scop label-clmn_11-br-dtl  'Факт'
&scop sort-clmn_11-br-dtl    ub.doc-line.fact-qnty
&scop label-clmn_12-br-dtl  'Изм.'
&scop sort-clmn_12-br-dtl   ub.goods.unit-base
&scop label-clmn_13-br-dtl  'Цена учет(прод.)'
&scop sort-clmn_13-br-dtl   (if varr-b = 'rubl':u then  ub.doc-line.price-rubl else  ub.doc-line.price-base)
&scop label-clmn_14-br-dtl  'Цена продажи'
&scop sort-clmn_14-br-dtl   ub.gds-obj.price-sale
&scop label-clmn_15-br-dtl  '%'
&scop sort-clmn_15-br-dtl   (if varr-b = 'rubl':u then ((ub.gds-obj.price-sale -  ub.doc-line.price-rubl) /  ub.doc-line.price-rubl * 100) else ((ub.gds-obj.price-sale -  ub.doc-line.price-base) /  ub.doc-line.price-base * 100))
&scop label-clmn_16-br-dtl  'Шкала'
&scop sort-clmn_16-br-dtl   get-name (BUFFER  ub.doc-line, buffer ub.goods, buffer ub.gds-prt)
&scop label-clmn_17-br-dtl  'НДС'
&scop sort-clmn_17-br-dtl    ub.doc-line.VAT-pc
&scop label-clmn_18-br-dtl  'Название англ.'
&scop sort-clmn_18-br-dtl   ub.goods.engl-name
&scop label-clmn_19-br-dtl  'Кол-во мест'
&scop sort-clmn_19-br-dtl    ub.doc-line.num-place
&scop label-clmn_20-br-dtl  'Вес брутто'
&scop sort-clmn_20-br-dtl    ub.doc-line.wt-brutto
&scop label-clmn_21-br-dtl  'Кол в там. ед.'
&scop sort-clmn_21-br-dtl    ub.doc-line.fact-qnty * ub.goods.cst-base-rate
&scop label-clmn_22-br-dtl  'Прих. цена'
&scop sort-clmn_22-br-dtl   last-price (buffer  ub.doc-line)
&scop label-clmn_23-br-dtl  '% откл прих. цены'
&scop sort-clmn_23-br-dtl   deviation-price (buffer  ub.doc-line)
&scop label-clmn_24-br-dtl  'Факт, кг'
&scop sort-clmn_24-br-dtl   get-kg-fact-qnty(  buffer  ub.doc-line )
&scop label-clmn_25-br-dtl  'Цена за кг (вал.)'
&scop sort-clmn_25-br-dtl   get-kg-sale-base(  buffer  ub.doc-line )
&scop label-clmn_26-br-dtl  'Цена за кг ({&abbr_rub}.)'
&scop sort-clmn_26-br-dtl   get-kg-sale-rubl(  buffer  ub.doc-line )
&scop label-clmn_27-br-dtl  'Итого, кг'
&scop sort-clmn_27-br-dtl   get-kg-after-qnty( buffer  ub.doc-line )
&scop label-clmn_28-br-dtl  'Доп. к ГТД'
&scop sort-clmn_28-br-dtl   get-add-gtd( buffer ub.doc-line )
&scop label-clmn_29-br-dtl  'Причина отклонения по РТ'
&scop sort-clmn_29-br-dtl   lineattr-get-reason( buffer ub.doc-line )
&scop label-clmn_30-br-dtl  'ВСД'
&scop sort-clmn_30-br-dtl   get-vsdsts( buffer ub.doc-line )
&scop label-clmn_31-br-dtl  'Сумма НДС'
&scop sort-clmn_31-br-dtl   get-vat-sum( buffer ub.doc-line )

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-in-doc
&Scoped-define BROWSE-NAME br-dtl

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES  ub.doc-line ub.goods ub.gds-prt ub.gds-obj

/* Definitions for BROWSE br-dtl                                        */
&Scoped-define FIELDS-IN-QUERY-br-dtl {&sort-clmn_1-br-dtl} {&sort-clmn_2-br-dtl} {&sort-clmn_3-br-dtl} {&sort-clmn_4-br-dtl} {&sort-clmn_5-br-dtl} {&sort-clmn_6-br-dtl} {&sort-clmn_7-br-dtl} {&sort-clmn_8-br-dtl} {&sort-clmn_9-br-dtl} {&sort-clmn_10-br-dtl} {&sort-clmn_11-br-dtl} {&sort-clmn_12-br-dtl} {&sort-clmn_13-br-dtl} {&sort-clmn_14-br-dtl} {&sort-clmn_15-br-dtl} {&sort-clmn_16-br-dtl} {&sort-clmn_17-br-dtl} {&sort-clmn_18-br-dtl} {&sort-clmn_19-br-dtl} {&sort-clmn_20-br-dtl} {&sort-clmn_21-br-dtl} {&sort-clmn_22-br-dtl} {&sort-clmn_23-br-dtl} {&sort-clmn_24-br-dtl} @ d-kg-fact-qnty {&sort-clmn_25-br-dtl} @ d-kg-price-base {&sort-clmn_26-br-dtl} @ d-kg-price-rubl {&sort-clmn_27-br-dtl} @ d-kg-after-qnty {&sort-clmn_28-br-dtl} @ d-gtd-add {&sort-clmn_29-br-dtl} @ d-reason {&sort-clmn_30-br-dtl} @ ch-vsd {&sort-clmn_31-br-dtl} @ ch-vsd
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-dtl {&sort-clmn_6-br-dtl} {&sort-clmn_11-br-dtl} {&sort-clmn_19-br-dtl} {&sort-clmn_20-br-dtl}
&Scoped-define SELF-NAME br-dtl
&Scoped-define QUERY-STRING-br-dtl FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK, ~
                  EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK, ~
                  first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK, ~
                  EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK
&Scoped-define OPEN-QUERY-br-dtl OPEN QUERY {&browse-name}    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK, ~
                  EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK, ~
                  first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK, ~
                  EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-dtl  ub.doc-line ub.goods ub.gds-prt ub.gds-obj
&Scoped-define FIRST-TABLE-IN-QUERY-br-dtl  ub.doc-line
&Scoped-define SECOND-TABLE-IN-QUERY-br-dtl ub.goods
&Scoped-define THIRD-TABLE-IN-QUERY-br-dtl ub.gds-prt
&Scoped-define FOURTH-TABLE-IN-QUERY-br-dtl ub.gds-obj


/* Definitions for DIALOG-BOX d-in-doc                                  */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS t-doc.cli-code t-doc.cli-type ~
clients.obj-name t-doc.exch-code t-doc.exch-date t-doc.discnt-pc ~
t-doc.cst-code t-doc.exch-rate t-doc.exch-scale t-doc.tot-cli ~
t-doc.base-rate t-doc.base-scale t-doc.out-code t-doc.pay-code t-doc.wrkr ~
t-doc.ord-num t-doc.agnt t-doc.boss t-doc.doc-date t-doc.fact-date ~
t-doc.shift-date t-doc.shift-name t-doc.shift-num t-doc.SLT-type ~
t-doc.VAT-type t-doc.tot-transp t-doc.tot-other t-doc.ship-num ~
t-doc.ship-date ub.currency.curr-abbr t-doc.tot-calc t-doc.road-tax ~
pay-type.obj-name t-doc.tot-sale t-doc.tot-fact t-doc.VAT-rubl ~
t-doc.VAT-base t-doc.cli-qnty t-doc.doc-qnty t-doc.fact-qnty ~
t-doc.reason-code
&Scoped-define ENABLED-TABLES t-doc ub.clients ub.currency ub.pay-type
&Scoped-define FIRST-ENABLED-TABLE t-doc
&Scoped-define SECOND-ENABLED-TABLE ub.clients
&Scoped-define THIRD-ENABLED-TABLE ub.currency
&Scoped-define FOURTH-ENABLED-TABLE ub.pay-type
&Scoped-Define ENABLED-OBJECTS b-exit b-prev b-next b-revis b-arch ~
b-add-doc b-cnt b-attr b-in-attr-fuel b-notes b-history b-print b-help ~
varcontract-prn-code b-contr-lkp r-clients r-currency r-acc r-outs r-pay ~
varpurch-code-name r-wrkr r-agnt r-boss r-sht ov-pc b-add-doc-yes m-inc ~
r-reas a-n-c loc-art loc-name loc-code b-mark b-add b-prt b-parts ~
b-lkp b-chg b-del b-live b-renum b-marks varinplnsum br-dtl wrkr-name agnt-name ~
boss-name rsn-name b-calc-tp
&Scoped-Define DISPLAYED-FIELDS t-doc.cli-code t-doc.cli-type ~
clients.obj-name t-doc.exch-code t-doc.exch-date t-doc.discnt-pc ~
t-doc.cst-code t-doc.exch-rate t-doc.exch-scale t-doc.tot-cli ~
t-doc.base-rate t-doc.base-scale t-doc.out-code t-doc.pay-code t-doc.wrkr ~
t-doc.ord-num t-doc.agnt t-doc.boss t-doc.doc-date t-doc.fact-date ~
t-doc.shift-date t-doc.shift-name t-doc.shift-num t-doc.SLT-type ~
t-doc.VAT-type t-doc.tot-transp t-doc.tot-other t-doc.ship-num ~
t-doc.ship-date ub.currency.curr-abbr t-doc.tot-calc t-doc.road-tax ~
pay-type.obj-name t-doc.tot-sale t-doc.tot-fact t-doc.VAT-rubl ~
t-doc.VAT-base t-doc.cli-qnty t-doc.doc-qnty t-doc.fact-qnty ~
t-doc.reason-code
&Scoped-define DISPLAYED-TABLES t-doc ub.clients ub.currency ub.pay-type
&Scoped-define FIRST-DISPLAYED-TABLE t-doc
&Scoped-define SECOND-DISPLAYED-TABLE ub.clients
&Scoped-define THIRD-DISPLAYED-TABLE ub.currency
&Scoped-define FOURTH-DISPLAYED-TABLE ub.pay-type
&Scoped-Define DISPLAYED-OBJECTS varcontract-prn-code varpurch-code-name ~
ov-pc m-inc a-n-c loc-art loc-name loc-code varinplnsum wrkr-name agnt-name ~
boss-name rsn-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD deviation-price d-in-doc
FUNCTION deviation-price RETURNS DECIMAL
(buffer local-doc-line for ub.doc-line)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-kg-after-qnty d-in-doc
FUNCTION get-kg-after-qnty RETURNS DECIMAL
( buffer local-doc-line for ub.doc-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-kg-fact-qnty d-in-doc
FUNCTION get-kg-fact-qnty RETURNS DECIMAL
( buffer local-doc-line for ub.doc-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-kg-sale-base d-in-doc
FUNCTION get-kg-sale-base RETURNS DECIMAL
( buffer local-doc-line for ub.doc-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-kg-sale-rubl d-in-doc
FUNCTION get-kg-sale-rubl returns decimal
( buffer local-doc-line for ub.doc-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-mark d-in-doc
FUNCTION get-mark RETURNS CHARACTER
(buffer local-doc-line for ub.doc-line ) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD last-price d-in-doc
FUNCTION last-price RETURNS DECIMAL
(buffer local-doc-line for ub.doc-line)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-add-gtd d-in-doc
FUNCTION get-add-gtd RETURNS character
(buffer local-doc-line for ub.doc-line)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-mark d-in-doc 
FUNCTION get-vsdsts RETURNS CHARACTER
(buffer local-doc-line for doc-line ) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-mark d-in-doc 
FUNCTION get-vat-sum RETURNS decimal
(buffer local-doc-line for doc-line ) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добав":L
     SIZE 6 BY 1.

DEFINE BUTTON b-add-doc
     LABEL "  ДопРасх":L
     SIZE 12 BY 1 TOOLTIP "Документ дополнительных расходов".

DEFINE BUTTON b-add-doc-yes
     IMAGE-UP FILE "cmp/check.bmp":U
     IMAGE-DOWN FILE "cmp/check.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/check.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 2 BY 0.9 TOOLTIP "Есть документ дополнительных расходов".

DEFINE BUTTON b-arch
     LABEL "Уч&етЦены":L
     SIZE 10 BY 1 TOOLTIP "Просмотр в учетных ценах".

DEFINE BUTTON b-attr
     LABEL "А&трибуты"
     SIZE 10 BY 1.

DEFINE BUTTON b-in-attr-fuel
     LABEL "Доп. инфо"
     SIZE 10 BY 1 TOOLTIP "Дополнительные атрибуты по документы при приемке топлива".

DEFINE BUTTON b-bc
     LABEL "&БКод":L
     SIZE 5 BY 1 TOOLTIP "Добавить по бар-коду".

DEFINE BUTTON b-chg
     LABEL "&Изм":L
     SIZE 6 BY 1.

DEFINE BUTTON b-cnt
     LABEL "&Договоры":L
     SIZE 10 BY 1 TOOLTIP "Разбивка по договорам поставщика".

DEFINE BUTTON b-contr-lkp
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Посмотреть договор".

DEFINE BUTTON b-del
     LABEL "&Удал":L
     SIZE 6 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход":L
     SIZE 6 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 2.75 BY 1.

DEFINE BUTTON b-history
     LABEL "&История"
     SIZE 3.5 BY 1.

DEFINE BUTTON b-live
     LABEL "С&удьба":L
     SIZE 7 BY 1 TOOLTIP "Жизненный путь пришедших партий".

DEFINE BUTTON b-lkp
     LABEL "&Просм":L
     SIZE 6 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 3 BY 1.

DEFINE BUTTON b-next AUTO-GO
     LABEL "&>>":L
     SIZE 3 BY 1.

DEFINE BUTTON b-notes
     LABEL "Примечание":L
     SIZE 11.5 BY 1.

DEFINE BUTTON b-calc-tp
     LABEL "ТП поставки" 
     SIZE 12 BY 1.

DEFINE BUTTON b-parts
     LABEL "Па&рт":L
     SIZE 6 BY 1.

DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<":L
     SIZE 3 BY 1.

DEFINE BUTTON b-print
     IMAGE-UP FILE "cmp/b-print.bmp":U
     LABEL "&Печать":L
     SIZE 3 BY 1.

DEFINE BUTTON b-prt
     LABEL "&Шкала":L
     SIZE 6 BY 1.

DEFINE BUTTON b-renum
     LABEL "&№п/п"
     SIZE 6 BY 1.

DEFINE BUTTON b-revis
     LABEL "С&верки"
     SIZE 8 BY 1.
     
DEFINE BUTTON b-marks 
     LABEL "&Марки" 
     SIZE 6 BY 1.     

DEFINE BUTTON r-acc
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .88.

DEFINE BUTTON r-agnt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .88.

DEFINE BUTTON r-boss
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .88.

DEFINE BUTTON r-clients
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .88.

DEFINE BUTTON r-currency
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .88.

DEFINE BUTTON r-outs
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 2.63 BY .88.

DEFINE BUTTON r-pay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .88.

DEFINE BUTTON r-reas
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .88.

DEFINE BUTTON r-sht
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .88.

DEFINE BUTTON r-wrkr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .88.

DEFINE VARIABLE m-inc AS CHARACTER FORMAT "X(256)":U INITIAL "1"
     LABEL "Включить пропорционально"
     VIEW-AS COMBO-BOX INNER-LINES 4
     LIST-ITEM-PAIRS "сумме приходных цен","1",
                     "количеству(в баз. ед.изм.)","2",
                     "количеству(в пост. ед.изм.)","3",
                     "весу","4"
     DROP-DOWN-LIST
     SIZE 27.5 BY 1 TOOLTIP "Включать трансп. и пр.расходы в учет.цену пропорционально -" NO-UNDO.

DEFINE VARIABLE varpurch-code-name AS CHARACTER FORMAT "x(22)":U
     VIEW-AS COMBO-BOX
     LIST-ITEMS "выкуп","консигнация","ответственное хранение","старая консигнация"
     DROP-DOWN-LIST
     SIZE 24.5 BY 1 TOOLTIP "Тип приобретения" NO-UNDO.

DEFINE VARIABLE agnt-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 12 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE boss-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 12 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc-art AS CHARACTER FORMAT "x(16)" 
     VIEW-AS FILL-IN 
     SIZE 14.5 BY 1 TOOLTIP "Начало артикула"
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE loc-code AS CHARACTER FORMAT "x(13)":U 
     VIEW-AS FILL-IN 
     SIZE 14.5 BY 1 TOOLTIP "Бар-код (весь)"
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE loc-name AS CHARACTER FORMAT "x(40)":U 
     VIEW-AS FILL-IN 
     SIZE 14.5 BY 1 TOOLTIP "Начало названия"
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE ov-pc AS DECIMAL FORMAT "->>9.9999999999":U INITIAL 0
     LABEL "&%"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 TOOLTIP "Изменение цены поставщика: наценка, скидка" NO-UNDO.

DEFINE VARIABLE rsn-name AS CHARACTER FORMAT "x(256)":U 
      VIEW-AS TEXT 
     SIZE 37.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varcontract-prn-code AS CHARACTER FORMAT "X(48)" 
     LABEL "До&говор" 
     VIEW-AS FILL-IN 
     SIZE 29 BY 1
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE wrkr-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 12 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE IMAGE g-image
     STRETCH-TO-FIT RETAIN-SHAPE
     SIZE 14.5 BY 3.25.

DEFINE VARIABLE a-n-c AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&А", "art",
"&Н", "name",
"&К", "code"
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE varinplnsum AS LOGICAL INITIAL no
     LABEL "&Cум"
     VIEW-AS TOGGLE-BOX
     SIZE 6 BY .75
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-dtl FOR
      ub.doc-line,
      ub.goods,
      ub.gds-prt,
      ub.gds-obj SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-dtl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-dtl d-in-doc _FREEFORM
  QUERY br-dtl DISPLAY
      {&sort-clmn_1-br-dtl}                    column-label {&label-clmn_1-br-dtl}  format "x(1)":U
      {&sort-clmn_2-br-dtl}                    column-label {&label-clmn_2-br-dtl}  format ">>>>9":U
      {&sort-clmn_3-br-dtl}                    column-label {&label-clmn_3-br-dtl}  format "+/-":U
      {&sort-clmn_4-br-dtl}                    column-label {&label-clmn_4-br-dtl}
      {&sort-clmn_5-br-dtl}                    column-label {&label-clmn_5-br-dtl}  format "x(150)"
      {&sort-clmn_6-br-dtl}                    column-label {&label-clmn_6-br-dtl}
      {&sort-clmn_7-br-dtl}                    column-label {&label-clmn_7-br-dtl}  format "x(3)":U
      {&sort-clmn_8-br-dtl}                    column-label {&label-clmn_8-br-dtl}
      {&sort-clmn_9-br-dtl}                    column-label {&label-clmn_9-br-dtl}  format ">>,>>>,>>>,>>>,>>9.99":U
      {&sort-clmn_10-br-dtl}                   column-label {&label-clmn_10-br-dtl} format ">,>>>,>>>,>>>,>>9.999":U
      {&sort-clmn_11-br-dtl}                   column-label {&label-clmn_11-br-dtl} format ">,>>>,>>>,>>>,>>9.999":U
      {&sort-clmn_12-br-dtl}                   column-label {&label-clmn_12-br-dtl} format "x(3)":U
      {&sort-clmn_13-br-dtl}                   column-label {&label-clmn_13-br-dtl}
      {&sort-clmn_14-br-dtl}                   column-label {&label-clmn_14-br-dtl}
      {&sort-clmn_15-br-dtl}                   column-label {&label-clmn_15-br-dtl} format "->>>,>>9.<<":U
      {&sort-clmn_16-br-dtl}                   column-label {&label-clmn_16-br-dtl} format "x(10)":U
      {&sort-clmn_17-br-dtl}                   column-label {&label-clmn_17-br-dtl} format ">9.9%":U
      {&sort-clmn_31-br-dtl} @ vat-sum         column-label {&label-clmn_31-br-dtl} format ">>,>>>,>>>,>>>,>>9.99"
      {&sort-clmn_18-br-dtl}                   column-label {&label-clmn_18-br-dtl}
      {&sort-clmn_19-br-dtl}                   column-label {&label-clmn_19-br-dtl}
      {&sort-clmn_20-br-dtl}                   column-label {&label-clmn_20-br-dtl}
      {&sort-clmn_21-br-dtl}                   column-label {&label-clmn_21-br-dtl}
      {&sort-clmn_22-br-dtl}                   column-label {&label-clmn_22-br-dtl} format ">,>>>,>>>,>>>,>>9.999":U
      {&sort-clmn_23-br-dtl}                   column-label {&label-clmn_23-br-dtl}
      {&sort-clmn_24-br-dtl} @ d-kg-fact-qnty  column-label {&label-clmn_24-br-dtl} format ">>>,>>>,>>9.999":U
      {&sort-clmn_25-br-dtl} @ d-kg-price-base column-label {&label-clmn_25-br-dtl} format "->>,>>>,>>>,>>9.999":U
      {&sort-clmn_26-br-dtl} @ d-kg-price-rubl column-label {&label-clmn_26-br-dtl} format "->,>>>,>>>,>>>,>>9.999":U
      {&sort-clmn_27-br-dtl} @ d-kg-after-qnty column-label {&label-clmn_27-br-dtl} format "->,>>>,>>>,>>>,>>9.999":U
      {&sort-clmn_28-br-dtl} @ d-gtd-add       column-label {&label-clmn_28-br-dtl} format "x(15)"
      {&sort-clmn_29-br-dtl} @ d-reason        column-label {&label-clmn_29-br-dtl} format "x(25)"
      {&sort-clmn_30-br-dtl} @ ch-vsd          column-label {&label-clmn_30-br-dtl} format "x(3)"
      enable {&sort-clmn_6-br-dtl} {&sort-clmn_11-br-dtl} {&sort-clmn_19-br-dtl} {&sort-clmn_20-br-dtl}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 107.5 BY 10.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-in-doc
     b-exit AT ROW 1 COL 1
     b-prev AT ROW 1 COL 7
     b-next AT ROW 1 COL 10
     b-revis AT ROW 1 COL 13
     b-arch AT ROW 1 COL 21
     b-add-doc AT ROW 1 COL 31 WIDGET-ID 2
     b-cnt AT ROW 1 COL 43.13
     b-attr AT ROW 1 COL 53.13
     b-in-attr-fuel AT ROW 1 COL 63.25
     b-notes AT ROW 1 COL 73.25
     b-calc-tp AT ROW 1 COL 84.8
     b-history AT ROW 1 COL 89.5
     b-print AT ROW 1 COL 93
     b-help AT ROW 1 COL 96
     t-doc.cli-code AT ROW 2 COL 11 COLON-ALIGNED
          LABEL "П&оставщик"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     t-doc.cli-type AT ROW 2 COL 20 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     ub.clients.obj-name AT ROW 2 COL 26.63 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 37 BY 1
          FGCOLOR 4
     varcontract-prn-code AT ROW 2 COL 74 COLON-ALIGNED
     b-contr-lkp AT ROW 2 COL 104.75
     r-clients AT ROW 2.04 COL 26
     r-currency AT ROW 3 COL 18.25
     t-doc.exch-code AT ROW 3.04 COL 7.13 COLON-ALIGNED
          LABEL "Ва&люта"
          VIEW-AS FILL-IN
          SIZE 4 BY .92
          FGCOLOR 4
     t-doc.exch-date AT ROW 3.04 COL 29.38 COLON-ALIGNED
          LABEL "ГТД"
          VIEW-AS FILL-IN
          SIZE 9 BY .92 TOOLTIP "Дата таможни"
          FGCOLOR 4
     t-doc.discnt-pc AT ROW 3.04 COL 52.13 COLON-ALIGNED
          LABEL "На&ценка ГТД"
          VIEW-AS FILL-IN
          SIZE 6 BY .92
          FGCOLOR 4
     t-doc.cst-code AT ROW 3.04 COL 65 COLON-ALIGNED
          LABEL "&ГТД№"
          Format "x(31)"
          VIEW-AS FILL-IN
          SIZE 32 BY .92
          FGCOLOR 4
     t-doc.exch-rate AT ROW 4 COL 10 COLON-ALIGNED
          LABEL "Курс п&-ка"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
          FGCOLOR 4
     t-doc.exch-scale AT ROW 4 COL 19 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 5 BY 1
          FGCOLOR 4
     r-acc AT ROW 4 COL 26
     t-doc.tot-cli AT ROW 4 COL 87.88 COLON-ALIGNED
          LABEL "Сумма для проверки"
          VIEW-AS FILL-IN
          SIZE 18 BY .92
          FGCOLOR 4
     t-doc.base-rate AT ROW 5 COL 10 COLON-ALIGNED
          LABEL "Курс &б.в."
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     t-doc.base-scale AT ROW 5 COL 19 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 5 BY 1
     t-doc.out-code AT ROW 5 COL 29.5 COLON-ALIGNED
          LABEL "Ис&т"
          VIEW-AS FILL-IN 
          SIZE 28 BY 1 TOOLTIP "Источник"
     r-outs AT ROW 5 COL 59.5
     t-doc.pay-code AT ROW 6 COL 7 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 7.5 BY 1
     r-pay AT ROW 6 COL 28.63
     varpurch-code-name AT ROW 6 COL 29.5 COLON-ALIGNED NO-LABEL
     t-doc.wrkr AT ROW 7 COL 5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 9.75 BY 1
     r-wrkr AT ROW 7 COL 28.63
     t-doc.ord-num AT ROW 7 COL 43.5 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
          FGCOLOR 4
     t-doc.agnt AT ROW 8 COL 5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 9.75 BY 1
     r-agnt AT ROW 8 COL 28.5
     t-doc.boss AT ROW 9 COL 5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 9.75 BY 1
     r-boss AT ROW 9 COL 28.5
     t-doc.doc-date AT ROW 10 COL 5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 9.75 BY 1
          FGCOLOR 4
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE .

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME d-in-doc
     t-doc.fact-date AT ROW 10 COL 23 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 9.75 BY 1
          FGCOLOR 4
     t-doc.shift-date AT ROW 10 COL 39.5 COLON-ALIGNED
          LABEL "&Смена"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
          FGCOLOR 4 
     t-doc.shift-name AT ROW 10 COL 53.25 COLON-ALIGNED
          LABEL "&№"
          VIEW-AS FILL-IN
          SIZE 3 BY 1 TOOLTIP "Номер смены"
          FGCOLOR 4 
     t-doc.shift-num AT ROW 10 COL 59.38 COLON-ALIGNED
          LABEL "П"
          VIEW-AS FILL-IN
          SIZE 3 BY 1 TOOLTIP "Порядок смен"
          FGCOLOR 4 
     r-sht AT ROW 10 COL 64.38
     t-doc.SLT-type AT ROW 11 COL 5 COLON-ALIGNED
          VIEW-AS COMBO-BOX INNER-LINES 3
          LIST-ITEMS "без","нет","в т. ч."
          DROP-DOWN-LIST
          SIZE 9.75 BY 1
     t-doc.VAT-type AT ROW 11 COL 21.5 COLON-ALIGNED
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 9.75 BY 1
     ov-pc AT ROW 11 COL 38.75 COLON-ALIGNED
     b-add-doc-yes AT ROW 1 COL 31 WIDGET-ID 4

     t-doc.tot-transp AT ROW 11.33 COL 62.88 COLON-ALIGNED
          LABEL "Тр"
          VIEW-AS FILL-IN 
          SIZE 15 BY .71 TOOLTIP "Транспортные расходы"
          FGCOLOR 4 
     t-doc.tot-other AT ROW 11.25 COL 88.5 COLON-ALIGNED
          LABEL "Пр"
          VIEW-AS FILL-IN 
          SIZE 15 BY .71 TOOLTIP "Прочие расходы"
          FGCOLOR 4 
     m-inc AT ROW 12.25 COL 27 COLON-ALIGNED
     t-doc.ship-num AT ROW 13.5 COL 10 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 10.5 BY 1 TOOLTIP "№ отгрузки"
          FGCOLOR 4 
     t-doc.ship-date AT ROW 13.5 COL 21 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 9.5 BY 1 TOOLTIP "Дата отгрузки"
          FGCOLOR 4 
     r-reas AT ROW 13.5 COL 49.5
     a-n-c AT ROW 14.5 COL 72 NO-LABEL
     loc-name AT ROW 14.5 COL 82.5 COLON-ALIGNED NO-LABEL
     loc-art AT ROW 14.5 COL 82.63 COLON-ALIGNED NO-LABEL
     loc-code AT ROW 14.5 COL 82.75 COLON-ALIGNED NO-LABEL
     b-mark AT ROW 14.63 COL 1
     b-add AT ROW 14.63 COL 4
     b-bc AT ROW 14.63 COL 10
     b-prt AT ROW 14.63 COL 15
     b-parts AT ROW 14.63 COL 21
     b-lkp AT ROW 14.63 COL 27
     b-chg AT ROW 14.63 COL 33
     b-del AT ROW 14.63 COL 39
     b-live AT ROW 14.63 COL 45.13
     b-renum AT ROW 14.63 COL 52.25
     b-marks at row 14.63 col 58
     varinplnsum AT ROW 14.71 COL 65.38
     br-dtl AT ROW 15.75 COL 1
     ub.currency.curr-abbr AT ROW 3 COL 11.88 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT 
          SIZE 4 BY 1
          FGCOLOR 4 
     t-doc.tot-calc AT ROW 4.92 COL 87.88 COLON-ALIGNED
          LABEL "По строкам док-та"
           VIEW-AS TEXT
          SIZE 18 BY .67
          FGCOLOR 4 
     t-doc.road-tax AT ROW 5.63 COL 87.88 COLON-ALIGNED
           VIEW-AS TEXT 
          SIZE 18 BY .67
          FGCOLOR 4
     ub.pay-type.obj-name AT ROW 6 COL 15 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 11.75 BY 1
          FGCOLOR 4
     t-doc.tot-sale AT ROW 6.33 COL 87.88 COLON-ALIGNED
          LABEL "Сумма rubl факт"
           VIEW-AS TEXT
          SIZE 18 BY .67
          FGCOLOR 4
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE .

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME d-in-doc
     wrkr-name AT ROW 7 COL 15 COLON-ALIGNED NO-LABEL
     t-doc.tot-fact AT ROW 7 COL 87.88 COLON-ALIGNED
          LABEL "Сумма валюта факт"
           VIEW-AS TEXT
          SIZE 18 BY .67
          FGCOLOR 4
     t-doc.VAT-rubl AT ROW 7.71 COL 87.88 COLON-ALIGNED
          LABEL "НДС по УЧЕТ ценам(rub)"
           VIEW-AS TEXT
          SIZE 18 BY .71
          BGCOLOR 3 FGCOLOR 15
     agnt-name AT ROW 8 COL 15 COLON-ALIGNED NO-LABEL
     t-doc.VAT-base AT ROW 8.42 COL 87.88 COLON-ALIGNED
          LABEL "НДС по УЧЕТ ценам(вал)"
           VIEW-AS TEXT
          SIZE 18 BY .71
          BGCOLOR 3 FGCOLOR 15
     boss-name AT ROW 9 COL 15 COLON-ALIGNED NO-LABEL
     t-doc.cli-qnty AT ROW 9.17 COL 88.5 COLON-ALIGNED
          LABEL "КолТТН"
           VIEW-AS TEXT
          SIZE 12.5 BY .67
          FGCOLOR 4
     t-doc.doc-qnty AT ROW 9.92 COL 88.5 COLON-ALIGNED
          LABEL "Док.кол-во"
           VIEW-AS TEXT
          SIZE 12.5 BY .67
          FGCOLOR 4
     t-doc.fact-qnty AT ROW 10.58 COL 88.5 COLON-ALIGNED
          LABEL "Факт.кол-во"
           VIEW-AS TEXT
          SIZE 12.5 BY .67
          FGCOLOR 4 
     t-doc.reason-code AT ROW 13.5 COL 43.5 COLON-ALIGNED
          LABEL "Основание" FORMAT ">>>>"
           VIEW-AS TEXT
          SIZE 4 BY .67 TOOLTIP "Основание заведения документа"
     rsn-name AT ROW 13.5 COL 51 COLON-ALIGNED NO-LABEL
     g-image AT ROW 12.25 COL 94 WIDGET-ID 6
     SPACE(0.49) SKIP(10.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "<insert dialog title>".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: t-doc B "?" ? ub ub.trn-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-in-doc
   FRAME-NAME                                                           */
/* BROWSE-TAB br-dtl varinplnsum d-in-doc */
ASSIGN
       FRAME d-in-doc:SCROLLABLE       = FALSE
       FRAME d-in-doc:HIDDEN           = TRUE
       FRAME d-in-doc:SENSITIVE        = FALSE.

/* SETTINGS FOR FILL-IN t-doc.base-rate IN FRAME d-in-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.cli-code IN FRAME d-in-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.cli-qnty IN FRAME d-in-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.cst-code IN FRAME d-in-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.discnt-pc IN FRAME d-in-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.doc-qnty IN FRAME d-in-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.exch-code IN FRAME d-in-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.exch-date IN FRAME d-in-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.exch-rate IN FRAME d-in-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.fact-qnty IN FRAME d-in-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.out-code IN FRAME d-in-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.reason-code IN FRAME d-in-doc
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN t-doc.shift-date IN FRAME d-in-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.shift-name IN FRAME d-in-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.shift-num IN FRAME d-in-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.tot-calc IN FRAME d-in-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.tot-cli IN FRAME d-in-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.tot-fact IN FRAME d-in-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.tot-other IN FRAME d-in-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.tot-sale IN FRAME d-in-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.tot-transp IN FRAME d-in-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.VAT-base IN FRAME d-in-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.VAT-rubl IN FRAME d-in-doc
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-dtl
/* Query rebuild information for BROWSE br-dtl
     _START_FREEFORM
OPEN QUERY {&browse-name}
   FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,
           EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic
                                      AND ub.goods.prod-code =  ub.doc-line.prod-code
                                      AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,
           first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,
           EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic
                          AND ub.gds-obj.prod-code =  ub.doc-line.prod-code
                          AND ub.gds-obj.prod-type =  ub.doc-line.prod-type
                          AND ub.gds-obj.obj-type  = t-doc.obj-type
                          AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY br-dtl FOR
       ub.doc-line,
      ub.goods,
      ub.gds-prt,
      ub.gds-obj SCROLLING.
     _END_FREEFORM_DEFINE
     _Query            is NOT OPENED
*/  /* BROWSE br-dtl */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-in-doc
/* Query rebuild information for DIALOG-BOX d-in-doc
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-in-doc */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-in-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-in-doc d-in-doc
ON END-ERROR OF FRAME d-in-doc /* <insert dialog title> */
or endkey    of frame {&frame-name} anywhere
do:
  return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-in-doc d-in-doc
ON WINDOW-CLOSE OF FRAME d-in-doc /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-in-doc
ON CHOOSE OF b-add IN FRAME d-in-doc /* Добав */
DO:
 {&stdbtn}
 run add-doc-line-local in this-procedure.
 apply "entry" to b-add in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add-doc d-in-doc
ON CHOOSE OF b-add-doc IN FRAME d-in-doc /* ДопРасходы */
DO:
/*
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_archive_cost':U
    {&cntxt-object}
    t-doc.host-code
    t-doc.obj-type
    t-doc.obj-code
    0
    0
    0
    true
    varlog
  }

  if not varlog then do: return no-apply. end.
  */

  run local-add-doc in this-procedure. /**/

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-arch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-arch d-in-doc
ON CHOOSE OF b-arch IN FRAME d-in-doc /* УчетЦены */
DO:
  {&stdbtn}

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_archive_cost':U
    {&cntxt-object}
    t-doc.host-code
    t-doc.obj-type
    t-doc.obj-code
    0
    0
    0
    true
    varlog
  }


  if not varlog then do: return no-apply. end.
  run local-arh in this-procedure. /* Просмотр в учетных ценах */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-attr d-in-doc
ON CHOOSE OF b-attr IN FRAME d-in-doc /* Атрибуты */
DO:
 {&stdbtn}
  run init-attr-general in this-procedure .

  if v-can-edit
  and not v-by-utd
  then do :
    if t-doc.status_ <> {&fact} then do:
      run str/doc-attr.w (input ParParentproc, input "b-lkp,b-chg,b-add,b-del", input t-doc.doc-code, input table tt-upd-attr) no-error.
    end.
    else do:
      run str/doc-attr.w (input ParParentproc, input "b-lkp,b-chg,b-add", input t-doc.doc-code, input table tt-upd-attr) no-error.
    end.
  end .
  else do :
    run str/doc-attr.w (input ParParentproc, input "b-lkp", input t-doc.doc-code, input table tt-upd-attr) no-error.
  end .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-in-attr-fuel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-in-attr-fuel d-in-doc
ON CHOOSE OF b-in-attr-fuel IN FRAME d-in-doc /* Атр для накладных с топливом */
DO:
    run init-attr-general in this-procedure .
    if t-doc.status_ <> {&fact} then do:

    
    /*for each tt-upd-attr-fuel :
    message
      tt-upd-attr-fuel.code             ' =code            ' skip
      tt-upd-attr-fuel.type-attr        ' =type-attr       ' skip
      tt-upd-attr-fuel.format-attr      ' =format-attr     ' skip
      tt-upd-attr-fuel.fillin_width     ' =fillin_width    ' skip
      tt-upd-attr-fuel.fillin_height    ' =fillin_height   ' skip
      tt-upd-attr-fuel.label-attr       ' =label-attr      ' skip
      tt-upd-attr-fuel.user-can-edit    ' =user-can-edit   ' skip
      tt-upd-attr-fuel.output-display   ' =output-display  ' skip
      tt-upd-attr-fuel.hot-key          ' =hot-key         ' skip
      tt-upd-attr-fuel.can-select       ' =can-select      ' skip
      tt-upd-attr-fuel.other            ' =other           '  skip
      tt-upd-attr-fuel.proc-attr        ' =proc-attr       '  skip
      tt-upd-attr-fuel.proc-win         ' =proc-win        '  skip
      tt-upd-attr-fuel.proc-func        ' =proc-func       '  skip
      tt-upd-attr-fuel.full-screen-val  ' =full-screen-val '   .
    end.
    */
      run str/in-laddtrn.w (input ParParentproc, input (if not v-can-edit then {&lookup} else pardoc-mode), input t-doc.doc-code, input table tt-upd-attr-fuel) no-error.
    end.
    else do:
      run str/in-laddtrn.w (input ParParentproc, input (if not v-can-edit then {&lookup} else pardoc-mode), input t-doc.doc-code, input table tt-upd-attr-fuel) no-error.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-calc-tp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-calc-tp d-in-doc
ON CHOOSE OF b-calc-tp IN FRAME d-in-doc /* ТП поставки */
DO:
  run str/in-laddsugtp.w (
    input ParParentproc, 
    input if t-doc.reason-code <> 99 then {&lookup} else pardoc-mode, 
    input t-doc.doc-code, 
    input table tt-upd-attr-fuel) 
  no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-bc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-bc d-in-doc
ON CHOOSE OF b-bc IN FRAME d-in-doc /* БКод */
DO:
    {&stdbtn}
  run local-bc in this-procedure.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg d-in-doc
ON CHOOSE OF b-chg IN FRAME d-in-doc /* Изм */
DO:
    {&stdbtn}
  run chg-line in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cnt d-in-doc
ON CHOOSE OF b-cnt IN FRAME d-in-doc /* ДогП */
DO:
    {&stdbtn}
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_archive_cost':U
    {&cntxt-object}
    t-doc.host-code
    t-doc.obj-type
    t-doc.obj-code
    0
    0
    0
    true
    varlog
  }
  if not varlog then do: return no-apply. end.
  run str/scntdoc.w ( input t-doc.doc-code, input v-cntxt-db-num = bf_sysconf.firm-db-num ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-contr-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-contr-lkp d-in-doc
ON CHOOSE OF b-contr-lkp IN FRAME d-in-doc
DO:
 define buffer buf_contract for ub.contract  .
 if t-doc.contract-code <> 0 then do:
 find first buf_contract no-lock where
            buf_contract.host-code     = t-doc.host-code  and
            buf_contract.contract-code = t-doc.contract-code no-error .
      if available buf_contract then do:
          run str/sh-contr.p
              ( input parParentProc ,
                input recid(buf_contract)
              ).
      end.
  end.
if pardoc-mode <> {&lookup} then do:
    define variable varrid-list as character no-undo.
    define variable varrecid    as recid     no-undo.
    find first buf_contract where buf_contract.host-code = t-doc.host-code no-lock no-error .
    if available buf_contract then do:
            run str/cont-all.w (input parParentProc,
                      input t-doc.host-code,
                      input "b-sel",
                      input "firm-curr" ,
                      input t-doc.cli-type,
                      input t-doc.cli-code,
                      input ?,
                      input ?,
                      input "current":u,
                      input "all":u,
                      input-output varrid-list ) no-error.
      if error-status:error then do:
        message "Ошибка при вызове справочника договоров." skip
                return-value                skip
                error-status:get-message(1) skip
                error-status:get-message(2)
        view-as alert-box error.
        return no-apply.
      end.
      assign
        varrecid = integer(entry(1, varrid-list)).
    find first buf_contract where recid(buf_contract) = varrecid no-lock no-error.
    if available buf_contract then do:
       assign
    t-doc.contract-code = buf_contract.contract-code.
    end.
    for each bf_parts where bf_parts.out-code = t-doc.doc-code and bf_parts.contract-code <> t-doc.contract-code EXCLUSIVE-LOCK :
              bf_parts.contract-code = t-doc.contract-code .
     end. 
    end.
    end.
    else do:  
    if t-doc.status_ <> {&wayb} or t-doc.flag_ then return.
    define variable varis-fin        as   character                       no-undo.
    define variable varis-finby      as   character                       no-undo.
    define buffer bf_contract      for ub.contract.
    define buffer bf_currency      for ub.currency.
    define buffer bf-f_contract-specif    for ub.contract-specif.
    define variable v-value-character like ub.thbj-attr.property-value-character no-undo .
    define variable v-value-date      like ub.thbj-attr.property-value-date    no-undo .
    define variable v-value-decimal   like ub.thbj-attr.property-value-decimal no-undo .
    define variable v-value-logical   like ub.thbj-attr.property-value-logical no-undo .
    define variable v-value-integer   like ub.thbj-attr.property-value-integer no-undo .
    define variable varcontract-type as   character                       no-undo.
    define variable varcontract      as   character                       no-undo.
    define variable varcontract-code as   integer                         no-undo.
    define variable v-tth1           as   handle                          no-undo.
    define variable varexch-rate      like ub.trn-doc.exch-rate           no-undo.
    define variable varexch-scale     like ub.trn-doc.exch-scale          no-undo.
    define variable varcurr-abbr     as   character                       no-undo.
    define variable v-master as character no-undo.

    if trn-type = {&is-gds} then do:
    run adm/shattri.p (
      input "get":U
      ,input t-doc.obj-type
      ,input t-doc.obj-code
      ,input {&attr-contr-in}
      ,input ( if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}  then  "contr-in-expense" else "contr-in-income" )
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output varcontract-type
      ,INPUT-OUTPUT TABLE-handle v-tth1
      ) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "adm/shattri.p"
        view-as alert-box error
      .
      end.
      else do:
    run adm/shattri.p (
      input "get":U
      ,input t-doc.obj-type
      ,input t-doc.obj-code
      ,input {&attr-contr-in}
      ,input ( if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}  then  "contr-in-expense-NP" else "contr-in-income-NP" )
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output varcontract-type
      ,INPUT-OUTPUT TABLE-handle v-tth1
      ) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "adm/shattri.p"
        view-as alert-box error
      .         
      end.   
      delete object v-tth1.
      if v-value-logical = true then varcontract = "yes" .
                                else varcontract = "no" .
    
    { gbl/conf-rd.i  "'is-fin'"   0               "''"           0              "''" "''" "''" no varis-fin       vartype          no-error }
    { gbl/conf-rd.i  "'is-finby'" 0               "''"           0              "''" "''" "''" no varis-finby     vartype          no-error }
    if ( varis-fin = "yes":u
     and ( t-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} or
           t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} or
         ( t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}     and paris-hold = true   ) or
         ( t-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} and paris-hold = true   )))
      or ( varis-finby = "yes":u
      and ( t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}      or
            t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} or
            t-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}  or
          ( t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}  and paris-hold = true )))
      then do:
        find first bf_contract where bf_contract.host-code = t-doc.host-code                          and
                                     bf_contract.cli-type  = input frame {&frame-name} t-doc.cli-type and
                                     bf_contract.cli-code  = input frame {&frame-name} t-doc.cli-code no-lock no-error.
        if not available bf_contract then do:
  
  
        end.
        else do:
          run check-contract-code in this-procedure (input  substitute("&1,&2=&3", "choose":u, "doc-type", t-doc.ext-doc-type),
                                                      input  t-doc.host-code,
                                                      input  input frame {&frame-name} t-doc.cli-type,
                                                      input  input frame {&frame-name} t-doc.cli-code,
                                                      input  ?,
                                                      input  parparentproc,
                                                      input  t-doc.doc-date,
                                                      input  (if ( t-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} or t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} ) then {&income} else {&expense}) ,
                                                      output varcontract-code) no-error.
          if error-status :error    or
             varcontract-code = ?  or
             varcontract-code = 0  then do:
  
          end.
          else do:
            find first bf_contract where bf_contract.host-code     = t-doc.host-code  and
                                         bf_contract.contract-code = varcontract-code no-lock.
            find first bf_currency where bf_currency.curr-code = bf_contract.curr-code no-lock no-error.
            if not available bf_currency then do:
              message "В договоре указана валюта " bf_contract.curr-code "." skip
                      "Но этой валюты нет в справочнике валют."
              view-as alert-box error.
              apply "entry" to t-doc.cli-code in frame {&frame-name}.
              return no-apply.
            end.
            { gbl/exchrate.i
              bf_currency.curr-code
              t-doc.exch-date
              varexch-rate
              varexch-scale
              varcurr-abbr
              no-error
            }
            if error-status :error then do:
              message "Ошибка при поиске курса валюты поставки по договору." skip
                      return-value skip
                      error-status :get-message( 1 ) skip
                      error-status :get-message( 2 )
              view-as alert-box error.
              return no-apply.
            end.
            assign
              t-doc.contract-code = varcontract-code
              t-doc.exch-code     = bf_contract.curr-code
              t-doc.exch-rate     = varexch-rate
              t-doc.exch-scale    = varexch-scale
            .
            v-master = Is-Master-Slave-Contract( buffer bf_contract) .
            if v-master  = "+" or v-master  = ""  then do :
              find first bf-f_contract-specif no-lock where bf-f_contract-specif.contract-num = bf_contract.contract-code
                                                        and bf-f_contract-specif.host-code = bf_contract.host-code no-error.
            end.
            else do :
              find first bf-f_contract-specif no-lock where bf-f_contract-specif.contract-num =integer(v-master)
                                                        and bf-f_contract-specif.host-code = bf_contract.host-code no-error.
            end.
            if available bf-f_contract-specif then do:
              t-doc.vat-type = bf-f_contract-specif.vat-type .
            end.
            for each bf_parts where bf_parts.out-code = t-doc.doc-code and bf_parts.contract-code <> t-doc.contract-code EXCLUSIVE-LOCK :
              bf_parts.contract-code = t-doc.contract-code .
            end.              
            run chg-purch-contract in this-procedure.
          end.
        end.
      end.
      else do:
        assign
          t-doc.contract-code  = 0.
      end.
  end.

run UI-on in this-procedure ( input "enable" ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del d-in-doc
ON CHOOSE OF b-del IN FRAME d-in-doc /* Удал */
DO:
    {&stdbtn}
  run del-doc-line in this-procedure no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-live
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-live d-in-doc
ON CHOOSE OF b-live IN FRAME d-in-doc /* Судьба */
DO:
  {&stdbtn}

  run live-loc in this-procedure no-error . /* Жизненный путь пришедших партий */
  if error-status :error then
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp d-in-doc
ON CHOOSE OF b-lkp IN FRAME d-in-doc /* Просм */
DO:
    {&stdbtn}
  run local-lockup in this-procedure.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark d-in-doc
ON CHOOSE OF b-mark IN FRAME d-in-doc /* * */
DO:
  {&stdbtn}
  run proc-b-mark in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-parts d-in-doc
ON CHOOSE OF b-parts IN FRAME d-in-doc /* Парт */
DO:
  {&stdbtn}
  run choose-b-parts in this-procedure no-error.
  run ui-on in this-procedure ( input "line" ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prt d-in-doc
ON CHOOSE OF b-prt IN FRAME d-in-doc /* Шкала */
DO:
  {&stdbtn}
  run choose-b-prt in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
  run ui-on in this-procedure ( input "line" ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-marks
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-marks d-in-doc
ON CHOOSE OF b-marks IN FRAME d-in-doc /* Шкала */
DO:
    define buffer buf_gen-attr for ub.gen-attr .
    define variable v-parts-uniq-key-rec    as character    no-undo .
    define buffer buf_tt-marks  for tt-marks .
    define variable v-alcohol-prod   as logical no-undo .
        
  {&stdbtn}
  if not available (ub.goods)
    then return no-apply.

  for each buf_tt-marks:
    delete buf_tt-marks .
  end.    

  /* Является ли товар алкогольной продукцией */
  { gbl/gdscdat.i
    ub.goods.gds-code
    "'alcohol-prod=request':u"
    v-alcohol-prod
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении атрибута товара" skip
      "Код товара" ub.goods.gds-code skip
      'mercur_FGIS=request':u skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return no-apply .
  end.
  case true:
    when v-alcohol-prod then do:
/*  run str/add-marks.w (input parparentproc, input t-doc.doc-code, input pardoc-mode)  no-error.*/ /*интерфейс с марками*/
      message "Вывести марки по всем линиям?"
        view-as alert-box question buttons YES-NO title "Вопрос" update varlog.
      
      for each bf_parts where bf_parts.out-code = t-doc.doc-code and 
      (varlog or (bf_parts.artic = goods.artic and bf_parts.prod-code = goods.prod-code and bf_parts.prod-type = goods.prod-type)):
      run gen-key-rec IN THIS-PROCEDURE (  input {&table_parts}
        ,input (buffer bf_parts:handle)
        ,output v-parts-uniq-key-rec).
    
        for each buf_gen-attr no-lock where buf_gen-attr.table-name = {&excise-mark} and buf_gen-attr.p-key = v-parts-uniq-key-rec:
            find first buf_tt-marks where buf_tt-marks.mark = buf_gen-attr.attr-code no-error .
            if not AVAILABLE buf_tt-marks then 
            do:                                       
                create buf_tt-marks .
                ASSIGN
                    buf_tt-marks.mark               = buf_gen-attr.attr-code
                    buf_tt-marks.parts              = buf_gen-attr.p-key
                    buf_tt-marks.reserv             = buf_gen-attr.whole-send-news
                    buf_tt-marks.num                = ""
                    buf_tt-marks.gds-part-position_ = ?
                    buf_tt-marks.gds-code           =  goods.gds-code
                    .
            end.
          end.
        end.
        run ref/egais-marks_exp.w (
            input parparentproc, 
            input t-doc.doc-code, 
            input {&income}  ,
            input-output table tt-marks) no-error.
      if error-status :error then do: return no-apply. end.
    end.
    when true then do:
      for each bf_parts no-lock where bf_parts.out-code = t-doc.doc-code and 
      bf_parts.artic = goods.artic and bf_parts.prod-code = goods.prod-code and bf_parts.prod-type = goods.prod-type:
        for each ub.marking-lines no-lock where 
              ub.marking-lines.obj-type = bf_parts.obj-type
          and ub.marking-lines.obj-code = bf_parts.obj-code
          and ub.marking-lines.in-code = bf_parts.in-code
          and ub.marking-lines.out-code = bf_parts.out-code
          and ub.marking-lines.gds-code = ub.goods.gds-code
          and ub.marking-lines.part-code = bf_parts.part-code
          and ub.marking-lines.prt-code = bf_parts.prt-code:
          create tt-marking-lines.
          buffer-copy ub.marking-lines to tt-marking-lines.
          find first ub.marking no-lock where ub.marking.mark = tt-marking-lines.mark no-error.
          if available (ub.marking)
          then do:
            tt-marking-lines.sts = ub.marking.sts.
            tt-marking-lines.stts = objSrv:Env:Marking:Sts:Mark:GetLabel(ub.marking.sts).
            tt-marking-lines.box-qnty = ub.marking.box-qnty .
            tt-marking-lines.unit = ub.marking.unit .
            tt-marking-lines.unit-ext = ub.marking.unit-ext .
            tt-marking-lines.doc-level = ub.marking-lines.doc-level.
            tt-marking-lines.gds-name = ub.goods.gds-name.
            tt-marking-lines.mark-parent = ub.marking.mark-parent.

            if tt-marking-lines.doc-level = 2
            then do:
              find first buf_marking-lines no-lock where ub.marking.mark-parent <> "" 
                and buf_marking-lines.mark = ub.marking.mark-parent 
                and buf_marking-lines.obj-type = bf_parts.obj-type
                and buf_marking-lines.obj-code = bf_parts.obj-code
                and buf_marking-lines.in-code = bf_parts.in-code
                and buf_marking-lines.out-code = bf_parts.out-code
                and buf_marking-lines.gds-code = ub.goods.gds-code
                and buf_marking-lines.part-code = bf_parts.part-code
                and buf_marking-lines.prt-code = bf_parts.prt-code no-error.

              if not available (buf_marking-lines)
              then do:
                
                find first tt-marking-lines no-lock where tt-marking-lines.mark = ub.marking.mark-parent 
                  no-error.
                if not available (tt-marking-lines )
                then do:
                  find first buf_marking no-lock where buf_marking.mark = ub.marking.mark-parent.
                  create tt-marking-lines.
                  buffer-copy ub.marking-lines except ub.marking-lines.mark ub.marking-lines.sts to tt-marking-lines.
                  tt-marking-lines.mark = buf_marking.mark.
                  tt-marking-lines.sts = buf_marking.sts.
                  tt-marking-lines.box-qnty = buf_marking.box-qnty .
                  tt-marking-lines.unit = buf_marking.unit .
                  tt-marking-lines.unit-ext = buf_marking.unit-ext .
                  tt-marking-lines.doc-level = 1.
                  tt-marking-lines.gds-name = ub.goods.gds-name.
                  tt-marking-lines.mark-parent = buf_marking.mark-parent.
                  tt-marking-lines.stts = objSrv:Env:Marking:Sts:Mark:GetLabel(buf_marking.sts).
                end.
              end.
            end.

          end.
          else do:
            if isMark(tt-marking-lines.mark) then
              message "Марка отсутсвует в справочнике марок - " + tt-marking-lines.mark view-as alert-box error.
          end.
        end.
      end. 
      run str/mark_browse.w (input parparentproc, input-output table tt-marking-lines, input {&lookup}, input "", input "", input "") .
      for each tt-marking-lines:
        delete tt-marking-lines.
      end.
    end.
    otherwise do:
      if not v-alcohol-prod
      then do:
        message "Товар не подлежит маркировке." view-as alert-box information title "Информация".
        undo, return no-apply .
      end.
    end.
  end case.

  run ui-on in this-procedure ( input "line" ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-renum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-renum d-in-doc
ON CHOOSE OF b-renum IN FRAME d-in-doc /* №п/п */
DO:
  {&stdbtn}
  assign
    line-rec = ( if available ub.doc-line then recid( ub.doc-line ) else ? )
  .
  run renum in this-procedure ( input t-doc.doc-code ).
  {&open-query-br-dtl-default}
  reposition {&browse-name} to recid line-rec no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-dtl
&Scoped-define SELF-NAME br-dtl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-dtl d-in-doc
ON ROW-LEAVE OF br-dtl IN FRAME d-in-doc
DO:
  run local-row-leave in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define BROWSE-NAME br-dtl
&Scoped-define SELF-NAME br-dtl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-dtl d-in-doc
ON row-display OF br-dtl IN FRAME d-in-doc
DO:

  run rowdisp .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-doc.cst-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-doc.cst-code d-in-doc
ON LEAVE OF t-doc.cst-code IN FRAME d-in-doc /* ГТД№ */
DO:
  if not available t-doc then return .
  if input frame {&frame-name} t-doc.cst-code <> t-doc.cst-code then do:
    run wr-cst-code in this-procedure.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-doc.exch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-doc.exch-code d-in-doc
ON LEAVE OF t-doc.exch-code IN FRAME d-in-doc /* Вал */
or return of t-doc.exch-code in frame {&frame-name}
do:
  if not available t-doc then return .
  if input frame {&frame-name} t-doc.exch-code <> t-doc.exch-code then do:
    run choice-currency in this-procedure no-error.
    if error-status :error then do: return no-apply. end.
    run update-rate-doc in this-procedure no-error.
  end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-doc.exch-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-doc.exch-date d-in-doc
ON LEAVE OF t-doc.exch-date IN FRAME d-in-doc /* ГТД */
or return of t-doc.exch-date  in frame {&frame-name}
do:
  if not available t-doc then return .
  if input frame {&frame-name} t-doc.exch-date <> t-doc.exch-date then do:
    assign
      frame {&frame-name} t-doc.exch-date
    .
  end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-doc.exch-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-doc.exch-rate d-in-doc
ON LEAVE OF t-doc.exch-rate IN FRAME d-in-doc /* Курс п-ка */
or return of t-doc.exch-rate in frame {&frame-name}
or leave, return of t-doc.exch-scale in frame {&frame-name}
or leave, return of t-doc.base-rate  in frame {&frame-name}
or leave, return of t-doc.base-scale in frame {&frame-name}
do:
if not available t-doc then return .
  run update-rate-doc in this-procedure no-error.
  if error-status :error then do:
    run disp-exch in this-procedure.
    return no-apply.
  end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-doc.fact-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-doc.fact-date d-in-doc
ON LEAVE OF t-doc.fact-date IN FRAME d-in-doc /* Факт */
DO:
if not available t-doc then return .
  run chk-upd-date in this-procedure ( input self :name ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-doc.fact-date d-in-doc
ON RETURN OF t-doc.fact-date IN FRAME d-in-doc /* Факт */
DO:
  if t-doc.fact-date:sensitive in frame {&frame-name} then do:
    apply "entry" to t-doc.shift-date in frame {&frame-name}.
  end.
  else do:
    apply "entry" to b-add in frame {&frame-name}.
  end.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME g-image
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL g-image d-in-doc
ON MOUSE-SELECT-DBLCLICK OF g-image IN FRAME d-in-doc
DO:
  RUN ref/imagelist.w (PARPARENTPROC, "":U, ub.goods.gds-code,{&lookup}).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-inc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-inc d-in-doc
ON VALUE-CHANGED OF m-inc IN FRAME d-in-doc /* Включить пропорционально */
DO:
  run local-upd-m-inc in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-doc.out-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-doc.out-code d-in-doc
ON MOUSE-SELECT-DBLCLICK OF t-doc.out-code IN FRAME d-in-doc /* Ист */
OR return of t-doc.out-code in frame {&frame-name}
do:
  run out-doc-rec in this-procedure no-error .
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "Ошибка !"
    view-as alert-box error
  .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ov-pc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ov-pc d-in-doc
ON LEAVE OF ov-pc IN FRAME d-in-doc /* % */
OR return of ov-pc in frame {&frame-name}
do:
  {&stdbtn}
  if input frame {&frame-name} ov-pc <> ov-pc then do:
    run ov-pc in this-procedure.
  end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-currency
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-currency d-in-doc
ON CHOOSE OF r-currency IN FRAME d-in-doc /* r-acc */
DO:
  {&stdbtn}
  run r-proc-currency in this-procedure.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-outs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-outs d-in-doc
ON CHOOSE OF r-outs IN FRAME d-in-doc /* r-acc */
DO:
  {&stdbtn}
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-reas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-reas d-in-doc
ON CHOOSE OF r-reas IN FRAME d-in-doc /* r-acc */
DO:
    run select-reason in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-doc.shift-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-doc.shift-date d-in-doc
ON LEAVE OF t-doc.shift-date IN FRAME d-in-doc /* Смена */
do: /* Секция триггеров обработки смены */
  if not available t-doc then return .
  if input frame {&frame-name} t-doc.shift-date <> t-doc.shift-date then do:
    assign
      t-doc.shift-name = ""
      t-doc.shift-num  = 0.
    display t-doc.shift-name t-doc.shift-num with frame {&frame-name}.
    apply "entry" to t-doc.shift-name in frame {&frame-name}.
    return no-apply.
  end.
end.

on return of t-doc.shift-date in frame {&frame-name} do:
  apply "entry" to t-doc.shift-name in frame {&frame-name}.
  return no-apply.
end.

on return of t-doc.shift-name in frame {&frame-name} do:
  apply "entry" to b-add in frame {&frame-name}.
  return no-apply.
end.

on return of t-doc.shift-num in frame {&frame-name} do:
  apply "entry" to b-add in frame {&frame-name}.
  return no-apply.
end.

on choose of r-sht in frame {&frame-name} do:
  run proc-sht.
end.

on leave of t-doc.shift-num  in frame {&frame-name} do:
  if not available t-doc then return .
  run proc-shift-num no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.

on leave of t-doc.shift-name in frame {&frame-name} do:
if not available t-doc then return .
  run proc-shift-name no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-doc.ship-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-doc.ship-num d-in-doc
ON return OF t-doc.ship-num IN FRAME d-in-doc /* Отгрузка */
or return of t-doc.ship-date in frame {&frame-name}
or return of t-doc.exch-date in frame {&frame-name}
or return of t-doc.tot-cli   in frame {&frame-name} do:
   run apply-entry-next-field in this-procedure ( input self :name ) no-error.
   return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-doc.SLT-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-doc.SLT-type d-in-doc
ON VALUE-CHANGED OF t-doc.SLT-type IN FRAME d-in-doc /* НП */
DO:
run val-ch-type in this-procedure ( self:name ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-doc.tot-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-doc.tot-cli d-in-doc
ON LEAVE OF t-doc.tot-cli IN FRAME d-in-doc /* Сумма для проверки */
or leave of t-doc.tot-transp in frame {&frame-name}
or leave of t-doc.tot-other  in frame {&frame-name}
or leave of t-doc.ord-num    in frame {&frame-name}
or leave of t-doc.ship-num   in frame {&frame-name}
or leave of t-doc.ship-date  in frame {&frame-name} do:
  if not available t-doc then return .
  run ass-frame-light in this-procedure ( input self :name ).
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varinplnsum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varinplnsum d-in-doc
ON VALUE-CHANGED OF varinplnsum IN FRAME d-in-doc /* Cум */
DO:
  run local-upd-inplnsum in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varpurch-code-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varpurch-code-name d-in-doc
ON VALUE-CHANGED OF varpurch-code-name IN FRAME d-in-doc
DO:
  run vc-purch-code in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-doc.VAT-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-doc.VAT-type d-in-doc
ON VALUE-CHANGED OF t-doc.VAT-type IN FRAME d-in-doc /* НДС */
DO:
  run val-ch-type in this-procedure ( self:name ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-in-doc


define menu m-print
    menu-item m-print-1   label "&Ценник"
    menu-item m-print-3   label "&Список кодов"
    menu-item m-print-2   label "&Торг-12"
    .
define menu m-ptrl
    menu-item m-ptrl-1   label "Создать документы сверки и зафиксировать  книжное кол-во"  accelerator "alt-1"
    menu-item m-ptrl-2   label "Удалить документы сверки и расфиксировать книжное кол-во"  accelerator "alt-2".
define menu m-outs
    menu-item m-outs-1 label "Документы по объекту"              accelerator "alt-1"
    menu-item m-outs-2 label "Мобильный сканер"                  accelerator "alt-2"
    menu-item m-outs-3 label "Импорт"                            accelerator "alt-3"
    menu-item m-outs-4 label "Импорт из файла"                   accelerator "alt-4"
    menu-item m-outs-6 label "Импорт артикул поставщик"          accelerator "alt-6"
    menu-item m-outs-7 label "Импорт акцизных марок"             accelerator "alt-7"
    .

ON choose OF MENU-ITEM m-outs-1 IN menu m-outs do:
  run proc-m-outs-1 in this-procedure no-error.
  if error-status :error then do:
    message
    "Ошибка при копировании из документа." skip
    error-status :get-message(1) skip
    return-value
    view-as alert-box.
 end.
 end.

on choose of menu-item m-outs-2 in menu m-outs do:
  {&stdbtn}
  run proc-m-outs-2 in this-procedure.
end.

on choose of menu-item m-outs-3 in menu m-outs do:
  {&stdbtn}
  if (t-doc.status_ = {&wayb} or t-doc.status_ = {&inquiry}) and
     not t-doc.flag_ then do:
    run disp-import in this-procedure ( input "import" ).
  end.
  else do:
    run err-status in this-procedure.
    return no-apply.
  end.
end.

on choose of menu-item m-outs-4 in menu m-outs do:
  {&stdbtn}
  if (t-doc.status_ = {&wayb} or t-doc.status_ = {&inquiry}) and
     not t-doc.flag_ then do:
    run proc-m-outs-4 in this-procedure no-error.
  end.
  else do:
    run err-status in this-procedure.
    return no-apply.
  end.
end.

on choose of menu-item m-outs-6 in menu m-outs do:
  {&stdbtn}
  if (t-doc.status_ = {&wayb} or t-doc.status_ = {&inquiry}) and
     not t-doc.flag_ then do:
    run proc-m-outs-6 in this-procedure no-error.
  end.
  else do:
    run err-status in this-procedure.
    return no-apply.
  end.
end.

on choose of menu-item m-outs-7 in menu m-outs do:
  {&stdbtn}
  if (t-doc.status_ = {&wayb} or t-doc.status_ = {&inquiry})
  then do:
    run proc-m-outs-7 in this-procedure no-error.
  end.
  else do:
    run err-status in this-procedure.
    return no-apply.
  end.
end.

on choose of menu-item m-print-1 in menu m-print do:
  {&stdbtn}
  if not available t-doc then return .
  define variable v-user-action       as character    no-undo.
  define variable v-printed           as logical      no-undo.
  run rep/tick-doc.p (parparentproc , recid(t-doc), 'trn' , 1 , no, no ) .
end.

on choose of menu-item m-print-3 in menu m-print do:
  {&stdbtn}
  if not available t-doc then return .
  define variable v-user-action       as character    no-undo.
  define variable v-printed           as logical      no-undo.
  run rep/mbb-doc.p (parparentproc , recid(t-doc), 'trn'  ) no-error .
  if error-status :error then message
    error-status :get-message(1) skip
    return-value skip
    "Вывод в список кодов"
    view-as alert-box error
  .
end.



on choose of menu-item m-print-2 in menu m-print do:
  {&stdbtn}
define variable v-user-action       as character    no-undo.
define variable v-printed           as logical      no-undo.
define variable g#report-num        as integer   no-undo .

if not available t-doc then return .
run get-report-num in parparentproc ( output g#report-num ).
run rep/torg-12.p (parparentproc , recid(t-doc), no,'all','no-round', no, no ) .
run gbl/prnfilen.w (
    input "":U
  , input 8
  , input string(
      session :temp-directory)
    + {&DF_Name}
    + string( g#report-num )
    + ( "":U  )
  , input 7
  , output v-user-action
  , output v-printed
) .
end.

on choose of menu-item m-ptrl-1 in menu m-ptrl do:
  {&stdbtn}

  apply "row-leave" to browse {&browse-name}.

  run cr-rvs-doc in this-procedure
    ( input parparentproc
     ,input t-doc.doc-code
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при создании документов сверок.") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
  end.

  run UI-on in this-procedure ( input "line" ).

end.

on choose of menu-item m-ptrl-2 in menu m-ptrl do:
  {&stdbtn}
  define variable v-Param-Type as character no-undo.
  define variable list-pl as character no-undo.
  apply "row-leave" to browse {&browse-name}.

  run del-rvs-doc in this-procedure
    ( input parparentproc
     ,input t-doc.doc-code
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при удалении документов сверок.") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
  end.
  else do:
    run adm/shattri.p (
       input "get":U
       ,input  v-cntxt-obj-type
       ,input  v-cntxt-obj-code
       ,input  {&attr-petrol}
       ,input  {&attr-petrol_block-nozzle} /*p-param-code*/
       ,output v-value-character
       ,output v-value-date
       ,output v-value-decimal
       ,output v-value-integer
       ,output v-value-logical
       ,output v-param-type
       ,INPUT-OUTPUT table-handle v-tth
       ) no-error .

    if v-value-logical then 
    do:
      list-pl = "" .
      for each ub.doc-pl where
               ub.doc-pl.obj-type = t-doc.obj-type
           and ub.doc-pl.obj-code = t-doc.obj-code
           and ub.doc-pl.out-code = t-doc.doc-code
          no-lock,
          each ub.pl-gds-pump where ub.pl-gds-pump.gds-code = ub.doc-pl.gds-code and
         ub.pl-gds-pump.obj-code = ub.doc-pl.obj-code and
         ub.pl-gds-pump.obj-type = ub.doc-pl.obj-type and
         ub.pl-gds-pump.pl-code = ub.doc-pl.pl-code no-lock,
         each ub.pl-pump-nozzle where ub.pl-pump-nozzle.obj-code = ub.pl-gds-pump.obj-code and
         ub.pl-pump-nozzle.obj-type = ub.pl-gds-pump.obj-type and
         ub.pl-pump-nozzle.pl-code = ub.pl-gds-pump.pl-code and
         ub.pl-pump-nozzle.pump-code = ub.pl-gds-pump.pump-code no-lock:
        list-pl = substitute("&1&2&3:&4:&5", list-pl, 
                   if list-pl = "" then "" else ";",
                   ub.pl-pump-nozzle.nozzle-code,
                   ub.pl-pump-nozzle.pump-code,
                   ub.pl-pump-nozzle.pl-code).
      end.

      run unblock-nozzle( parparentproc, v-cntxt-obj-type, v-cntxt-obj-code, list-pl ).
    end.
  end.

  run UI-on in this-procedure ( input "line" ).

end.

on end-error of  ub.doc-line.cli-qnty in browse {&browse-name} do:
   display  ub.doc-line.cli-qnty with browse {&browse-name}.
   return no-apply.
END.

on end-error of  ub.doc-line.fact-qnty in browse {&browse-name} do:
   display  ub.doc-line.fact-qnty with browse {&browse-name}.
   return no-apply.
END.
{ gbl/ed_date.i t-doc.ship-date  }
{ gbl/ed_date.i t-doc.exch-date  }
{ gbl/ed_date.i t-doc.fact-date  }
{ gbl/ed_date.i t-doc.shift-date }
{ gbl/hot-key.i b-mark }
assign
  frame {&frame-name}:scrollable                           = false
  {&browse-name}:num-locked-columns in frame {&frame-name} = 5
  r-outs:popup-menu in frame {&frame-name}                 = menu m-outs:handle
  r-outs:menu-mouse                                        = 1
  b-revis:popup-menu in frame {&frame-name}                = menu m-ptrl:handle
  b-revis:menu-mouse                                       = 1
  rsn-name:tooltip in frame {&FRAME-NAME} = "Основание (причина) создания документа"
.
 t-doc.SLT-type:LIST-ITEMS =  {&without-slt} + "," + {&no-slt} + "," + {&inc-slt} .

 t-doc.VAT-type:LIST-ITEMS =  {&no-vat} + "," + {&inc-vat} + "," + {&without-vat} .

run tax-name in this-procedure ( input {&road-tax}, output rdtaxname ).
assign
  t-doc.road-tax :label in frame {&frame-name} = rdtaxname
.

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
if v-mercury-value ne "no" and v-mercury-value ne "" and v-mercury-value ne ?
then do: 
  v-is-mercury-value = true.
  vsdstrObj = new vsdtostorage ().
end.
hbrowse = browse br-dtl:handle.
extent (bcol) = hbrowse:num-columns.
bcol[1] = hbrowse:first-column.
do ii = 1 to extent (bcol).  
  bcol[ii] = hbrowse:get-browse-column (ii).
end.



{ gbl/conf-rd.i  "'is-ptrl'" "''" "''" 0 "''" "''" "''" no v-is-ptrl v-data-type no-error }
if error-status :error or v-data-type <> "L" or lookup( v-is-ptrl, "yes,no" ) = 0 then do:
  assign
    v-is-ptrl = "no"
  .
end.
assign
  d-kg-after-qnty :visible in browse {&browse-name} = ( v-is-ptrl = "yes" )
  d-kg-fact-qnty  :visible in browse {&browse-name} = ( v-is-ptrl = "yes" )
  d-kg-price-base :visible in browse {&browse-name} = ( v-is-ptrl = "yes" )
  d-kg-price-rubl :visible in browse {&browse-name} = ( v-is-ptrl = "yes" )
.
{ gbl/conf-rd.i  "'gtd-part'"  0             "''"         0         "''"  "''"  "''"  no  v-is-gtd-part    v-is-gtd-part-type no-error }
assign
  d-gtd-add :visible in browse {&browse-name} = ( v-is-gtd-part = "yes" )
.
&scop OPEN-QUERY-{&browse-name} OPEN QUERY {&browse-name} ~
   FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK, ~
           EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic ~
                                      AND ub.goods.prod-code =  ub.doc-line.prod-code ~
                                      AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK, ~
           first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK, ~
           EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic ~
                          AND ub.gds-obj.prod-code =  ub.doc-line.prod-code ~
                          AND ub.gds-obj.prod-type =  ub.doc-line.prod-type ~
                          AND ub.gds-obj.obj-type  = t-doc.obj-type ~
                          AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK

&SCOP open-query-{&browse-name}-another sort-default = no. {&open-query-{&browse-name}}
&scop open-query-{&browse-name}-default sort-default = yes. {&open-query-{&browse-name}} BY  ub.doc-line.line-num.


{ gbl/srt-clmn.i
    &ext-col              = 28
    &frame-name           = {&frame-name}
    &browse-name          = {&browse-name}
    &table-name           = "doc-line"
    &start-column         = 5
    &label-clmn_1         = "{&label-clmn_1-br-dtl}"
    &sort-clmn_1          = "{&sort-clmn_1-br-dtl}"
    &label-clmn_2         = "{&label-clmn_2-br-dtl}"
    &sort-clmn_2          = "{&sort-clmn_2-br-dtl}"
    &label-clmn_3         = "{&label-clmn_3-br-dtl}"
    &sort-clmn_3          = "{&sort-clmn_3-br-dtl}"
    &label-clmn_4         = "{&label-clmn_4-br-dtl}"
    &sort-clmn_4          = "{&sort-clmn_4-br-dtl}"
    &label-clmn_5         = "{&label-clmn_5-br-dtl}"
    &sort-clmn_5          = "{&sort-clmn_5-br-dtl}"
    &label-clmn_6         = "{&label-clmn_6-br-dtl}"
    &sort-clmn_6          = "{&sort-clmn_6-br-dtl}"
    &label-clmn_7         = "{&label-clmn_7-br-dtl}"
    &sort-clmn_7          = "{&sort-clmn_7-br-dtl}"
    &label-clmn_8         = "{&label-clmn_8-br-dtl}"
    &sort-clmn_8          = "{&sort-clmn_8-br-dtl}"
    &label-clmn_9         = "{&label-clmn_9-br-dtl}"
    &sort-clmn_9          = "{&sort-clmn_9-br-dtl}"
    &label-clmn_10        = "{&label-clmn_10-br-dtl}"
    &sort-clmn_10         = "{&sort-clmn_10-br-dtl}"
    &label-clmn_11        = "{&label-clmn_11-br-dtl}"
    &sort-clmn_11         = "{&sort-clmn_11-br-dtl}"
    &label-clmn_12        = "{&label-clmn_12-br-dtl}"
    &sort-clmn_12         = "{&sort-clmn_12-br-dtl}"
    &label-clmn_13        = "{&label-clmn_13-br-dtl}"
    &sort-clmn_13         = "{&sort-clmn_13-br-dtl}"
    &label-clmn_14        = "{&label-clmn_14-br-dtl}"
    &sort-clmn_14         = "{&sort-clmn_14-br-dtl}"
    &label-clmn_15        = "{&label-clmn_15-br-dtl}"
    &sort-clmn_15         = "{&sort-clmn_15-br-dtl}"
    &label-clmn_16        = "{&label-clmn_16-br-dtl}"
    &sort-clmn_16         = "{&sort-clmn_16-br-dtl}"
    &label-clmn_17        = "{&label-clmn_17-br-dtl}"
    &sort-clmn_17         = "{&sort-clmn_17-br-dtl}"
    &label-clmn_18        = "{&label-clmn_18-br-dtl}"
    &sort-clmn_18         = "{&sort-clmn_18-br-dtl}"
    &label-clmn_19        = "{&label-clmn_19-br-dtl}"
    &sort-clmn_19         = "{&sort-clmn_19-br-dtl}"
    &label-clmn_20        = "{&label-clmn_20-br-dtl}"
    &sort-clmn_20         = "{&sort-clmn_20-br-dtl}"
    &label-clmn_21        = "{&label-clmn_21-br-dtl}"
    &sort-clmn_21         = "{&sort-clmn_21-br-dtl}"
    &label-clmn_22        = "{&label-clmn_22-br-dtl}"
    &sort-clmn_22         = "{&sort-clmn_22-br-dtl}"
    &label-clmn_23        = "{&label-clmn_23-br-dtl}"
    &sort-clmn_23         = "{&sort-clmn_23-br-dtl}"
    &label-clmn_24        = "{&label-clmn_24-br-dtl}"
    &sort-clmn_24         = "{&sort-clmn_24-br-dtl}"
    &label-clmn_25        = "{&label-clmn_25-br-dtl}"
    &sort-clmn_25         = "{&sort-clmn_25-br-dtl}"
    &label-clmn_26        = "{&label-clmn_26-br-dtl}"
    &sort-clmn_26         = "{&sort-clmn_26-br-dtl}"
    &label-clmn_27        = "{&label-clmn_27-br-dtl}"
    &sort-clmn_27         = "{&sort-clmn_27-br-dtl}"
    &label-clmn_28        = "{&label-clmn_28-br-dtl}"
    &sort-clmn_28         = "{&sort-clmn_28-br-dtl}"
    &label-clmn_29        = "{&label-clmn_29-br-dtl}"
    &sort-clmn_29         = "{&sort-clmn_29-br-dtl}"
    &open-query           = "{&open-query-{&browse-name}-another} by ~{&sort-clmn_~{&clmn_num~}~} ."
    &open-query-otherwise = "{&open-query-{&browse-name}-default} ."
    &re-move-clmn         = "yes"
    &mv-brw-default       = "yes"
}

{ gbl/ch-num.i
    &table-name  =  doc-line
    &browse-name = br-dtl
    &open-query  = "{&open-query-{&browse-name}-default}"
}
/* ************************  Control Triggers  ************************ */
{ gbl/mv-clmn.i
    &ext-col      = 29
    &frame-name   = {&frame-name}
    &browse-name  = {&browse-name}
    &table-name   = "doc-line"
    &start-column = 5
}

{ gbl/f2.i {&browse-name} " " " " parparentproc  }

on F12 of frame {&frame-name} anywhere do:
  if v-is-gtd-part = "yes" then run gtd-line in this-procedure .
  return no-apply.
END.

/* общие триггеры и процедуры для РН и ПН */
{ str/trn-tr.i in trn-type}
{ str/sch-line.i doc-line {&browse-name} }
IF mImagePh THEN
DO:
    DEFINE VARIABLE vImageList AS LONGCHAR    NO-UNDO.
    DEFINE VARIABLE vCh        AS CHARACTER   NO-UNDO.
if AVAILABLE goods then do:
    RUN gds-attr-value ( goods.gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
    RUN imagelist_decode IN THIS-PROCEDURE (INPUT vImageList, goods.gds-code, OUTPUT vImageList).
    vCh = ENTRY (1, vImageList, {&ImageDelimiter}).
    g-image:LOAD-IMAGE (ENTRY (1, vCh)) NO-ERROR.
    ASSIGN
        g-image:HIDDEN     = NO
        g-image:VISIBLE    = YES
        g-image:SENSITIVE  = YES
        .
end.        
END.
ELSE
    ASSIGN
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .

end.

/* ***************************  Main Block  *************************** */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

{ gbl/app_help.i }
{ gbl/brwrepos.i
  &line-num=5
}

frame {&frame-name}:visible = true .
hide t-doc.discnt-pc in frame {&frame-name} .

run chk-is-addcharges in parparentproc ( output is-add-doc ) .
if not is-add-doc then hide b-add-doc in frame {&frame-name} .

t-doc.tot-sale:label in frame {&frame-name} = "Сумма {&abbr_rubli} факт" .
t-doc.VAT-rubl:label in frame {&frame-name} = "НДС по УЧЕТ ценам({&abbr_rub})"   .
b-print:popup-menu in frame {&frame-name}   = menu m-print:handle .
b-print:menu-mouse                          = 1 .

/* зацикливание формы */
assign
  parnext-prev = yes
.
n-p:
do while parnext-prev :
main-block:
do on error undo main-block, leave main-block :

   assign 
       {&browse-name}:column-resizable in frame {&frame-name} = true.
   if pardoc-mode = {&add-copy}
    then
    assign
      is-copy = true
      pardoc-mode = {&add-def}
      docrec-src = pardoc-rec
      pardoc-rec = ?
      .
  
   { gbl/curr-r-b.i varr-b no-error }
   if error-status :error then do:
     assign
       parnext-prev = no.
     return error.
   end.
   run local-conf-rd in this-procedure no-error.
   if error-status :error then do:
     assign
       parnext-prev = no.
     return error.
   end.
   run mode-on in this-procedure no-error.
   if error-status :error then do:
     assign
       parnext-prev = no.
     return error.
   end.

   { gbl/hold-doc.i
       t-doc.doc-code
       is-doc-hold
       no-error
   }
   if error-status :error or is-doc-hold = ? then do:
     assign
       is-doc-hold = no
     .
   end.
   { str/tdat-val.i
     t-doc.doc-code
     {&trdcattr-indoclnsum}
     varvalue
     vartype
     no-error
   }
   if varvalue = "yes" then do:
     assign
       varinplnsum = yes.
   end.
   else do:
     assign
       varinplnsum = no.
   end.

   { str/tdat-val.i
     t-doc.doc-code
     {&trdcattr-m-inc}
     varvalue
     vartype
     no-error
   }
   if int(varvalue) > 0 then do:
     assign
       m-inc = varvalue.
   end.
   else do:
     assign
       m-inc = "1".
   end.
   { str/tdat-val.i
     t-doc.doc-code
     {&trdcattr-negais}
     varvalue
     vartype
     no-error
   }
   if varvalue <> "" and varvalue <> ? then do:
     assign
       isEgais = yes.
   end.

   { str/tdat-val.i
     t-doc.doc-code
     {&trdcattr-is-fuel}
     varvalue
     vartype
     no-error
   }
   
   if varvalue = "yes" then do:
     assign
       trn-type = {&is-fuel}.
   end.

   
   { str/tdat-val.i
     t-doc.doc-code
     {&trdcattr-is-lgas}
     varvalue
     vartype
     no-error
   }
   
   if varvalue = "yes" then do:
     assign
       trn-type = {&is-lgas}.
   end.
   
   { str/tdat-val.i
     t-doc.doc-code
     {&trdcattr-is-lgas-corr}
     varvalue
     vartype
     no-error
   }
   
   if varvalue = "yes" then do:
     assign
       trn-type = {&is-lgas-corr}.
   end.
   
   { str/tdat-val.i
     t-doc.doc-code
     {&trdcattr-trn-is-gds}
     varvalue
     vartype
     no-error
   }
   
   if varvalue = "yes" then do:
     assign
       trn-type = {&is-gds}.
   end.



   display varinplnsum m-inc with frame {&frame-name}.
   if pardoc-mode <> {&lookup} then line-rec = ?. /* указатель на ту строку, на которую надо встать */

   if v-is-tsd = "no" then do: menu-item m-outs-2:sensitive in menu m-outs = no. end.
   if pardoc-mode = {&add-def} then do:
     find first bf_sysconf where bf_sysconf.host-code = v-cntxt-host-code-obj no-lock no-error .
   end.
   else do:
     find first bf_sysconf where bf_sysconf.host-code = t-doc.host-code no-lock no-error .
   end.

  if t-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} and not t-doc.flag_ and t-doc.status_ = {&wayb}
  then do: 
    
    run adm/shattri.p (
        input "get":U
        ,input t-doc.obj-type
        ,input t-doc.obj-code
        ,input {&attr-nakl_par}
        ,input  "edit-fact-wayb"
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output par-type
        ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
    ) no-error .
    if error-status :error then.
    else v-edit-fact-wayb = v-value-logical.
    
    v-by-utd = false .
    define buffer buf_utd for ub.utd .
    if can-find(buf_utd no-lock where buf_utd.doc-code = t-doc.doc-code)
    and parext-doc-mode = ""
    then do :
      v-by-utd = true .
    end .
  end.

  if is-copy
  then do:
    for first src-doc where recid (src-doc) = docrec-src no-lock:
      { str/tdat-val.i                                    
         src-doc.doc-code
         {&trdcattr-is-fuel}
         varattr 
         vartype 
         no-error}
      if  varattr = "yes"
        then trn-type = {&is-fuel}.
    end.
  end.
/*run gbl/inidebug.p.*/
   run UI-on in this-procedure ( input "enable" ) no-error.

   if error-status :error then do:
     assign
       parnext-prev = no.
     return error.
   end.
   if not is-copy and can-find (FIRST ub.clients-attr no-lock where (ub.clients-attr.attr-code = {&attr-supp-np} or ub.clients-attr.attr-code = {&attr-supp-lgas})
                                                and ub.clients-attr.attr-value = "yes") and pardoc-mode = {&add-def}
   then do :
    run gbl/d-askw.w (
                 input "Выбор типа приходного документа"
                ,input "Выберите тип товаров в приходной накладной"
                ,input "|"
                ,input "Топливо|Приход СУГ|Корр. СУГ|ТНП|Отмена"
                ,input "Приход топлива|Приход СУГ|Корректировка массы СУГ|Приход ТНП|Отказ от создания приходной накладной"
                ,input 4
                ,input 5
                ,output choice).
    case choice:
      when 1 
      then do:
        trn-type = {&is-fuel}.
        { str/tdat-wrt.i                                    
           t-doc.doc-code
           {&trdcattr-is-fuel}
           "yes" 
        no-error}
        
        run adm/shattri.p (
            input "get":U
            ,input t-doc.obj-type
            ,input t-doc.obj-code
            ,input {&attr-petrol}
            ,input  "trnscanqr"
            ,output v-value-character
            ,output v-value-date
            ,output v-value-decimal
            ,output v-value-integer
            ,output v-value-logical
            ,output par-type
            ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
            ) no-error .
        if error-status :error
        then v-trnscanqr = false .
        else v-trnscanqr = v-value-logical .
        
        if v-trnscanqr
        then do :
          varlog = no.
          message "Читать QR код ПН?"
            view-as alert-box question buttons YES-NO update varlog.
          if varlog
          then do:
            run str/trnscanqr.w (parparentproc, t-doc.doc-code, "", this-procedure).
          end. 
        end .
      end.
      when 2 
      then do:
        trn-type = {&is-lgas}.
        { str/tdat-wrt.i                                    
           t-doc.doc-code
           {&trdcattr-is-lgas}
           "yes" 
        no-error} 
      end.
      when 3 
      then do:
        { str/tdat-wrt.i                                    
           t-doc.doc-code
           {&trdcattr-is-lgas-corr}
           "yes" 
        no-error}
        trn-type = {&is-lgas-corr}.
        run add-lgas-corr no-error.
        if error-status :error then do:
          run proc-exit.
          return.
        end.
        run UI-on     in this-procedure ( input "line" ).
      end.
      when 4
      then do:
        { str/tdat-wrt.i                                    
           t-doc.doc-code
           {&trdcattr-trn-is-gds}
           "yes" 
        no-error} 
        trn-type = {&is-gds}.
      end.
      when 5 then do:
        run proc-exit.
        return.
      end.
    end.
   end.
/*                                                      */
/*                                                      */
/*   if trn-type = {&is-lgas-corr} then do:             */
/*     menu-item m-outs-2:sensitive in menu m-outs = no.*/
/*     menu-item m-outs-3:sensitive in menu m-outs = no.*/
/*     menu-item m-outs-4:sensitive in menu m-outs = no.*/
/*     menu-item m-outs-6:sensitive in menu m-outs = no.*/
/*     menu-item m-outs-7:sensitive in menu m-outs = no.*/
/*   end.                                               */
/*                                                      */
   /*if is-fuel or can-find (FIRST ub.clients-attr no-lock where ub.clients-attr.obj-type = ub.clients.obj-type  
                                                and ub.clients-attr.obj-code = ub.clients.obj-code
                                                and ub.clients-attr.attr-code = {&attr-supp-np}
                                                and ub.clients-attr.attr-value = "yes")
   then do:*/
   b-in-attr-fuel:sensitive = true.
   ub.goods.gds-name:width     in browse {&browse-name}   = 40.
  /*end.*/
   
  if not (trn-type = {&is-lgas} or trn-type = {&is-lgas-corr} or trn-type = {&is-fuel}) 
  then do:
    hide b-in-attr-fuel in frame {&frame-name}.
  end.
  else do :
    t-doc.cli-qnty:label = "КолТТН(кг)" .
    t-doc.doc-qnty:label = "Док.кол-во(л)" .
    t-doc.fact-qnty:label = "Факт.кол-во(л)" .
  end .
  if trn-type = {&is-lgas} then
  do:
    view b-calc-tp in frame d-in-doc .
    enable b-calc-tp with frame d-in-doc .
  end.
  else do:
    hide b-calc-tp in frame d-in-doc .
  end.
  
  IF mImagePh THEN
  DO:
    DEFINE VARIABLE vImageList AS LONGCHAR    NO-UNDO.
    DEFINE VARIABLE vCh        AS CHARACTER   NO-UNDO.
    if AVAILABLE goods then do:
      RUN gds-attr-value ( goods.gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
      RUN imagelist_decode IN THIS-PROCEDURE (INPUT vImageList, goods.gds-code, OUTPUT vImageList).
      vCh = ENTRY (1, vImageList, {&ImageDelimiter}).
      g-image:LOAD-IMAGE (ENTRY (1, vCh)) NO-ERROR.
      ASSIGN
        g-image:HIDDEN     = NO
        g-image:VISIBLE    = YES
        g-image:SENSITIVE  = YES
        .
    end.        
  END.
  ELSE
    ASSIGN
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .
  if is-copy
  then do:
    for first src-doc where recid (src-doc) = docrec-src no-lock:
      t-doc.cli-code = src-doc.cli-code.
      t-doc.cli-type = src-doc.cli-type.
      t-doc.cli-code:screen-value in frame {&frame-name} = string (src-doc.cli-code).
      t-doc.cli-type:screen-value  in frame {&frame-name} = src-doc.cli-type.
      find first ub.clients where ub.clients.obj-type = src-doc.cli-type and ub.clients.obj-code = src-doc.cli-code no-lock.
      disp ub.clients.obj-code @ t-doc.cli-code
              ub.clients.obj-name with frame {&frame-name}.
      disp ub.clients.obj-type @ t-doc.cli-type with frame {&frame-name}.
      run check-cli no-error.
      if error-status :error then return no-apply.
      { str/tdat-val.i                                    
         src-doc.doc-code
         {&trdcattr-ptbobj}
         varattr 
         vartype
         no-error } 
      { str/tdat-wrt.i                                    
         t-doc.doc-code
         {&trdcattr-ptbobj}
         varattr
         no-error 
      } 
      { str/tdat-val.i                                    
         src-doc.doc-code
         {&trdcattr-autoent}
         varattr 
         vartype 
         no-error} 
      { str/tdat-wrt.i                                    
         t-doc.doc-code
         {&trdcattr-autoent}
         varattr
         no-error 
      } 
      
      assign
        t-doc.contract-code = src-doc.contract-code
        t-doc.exch-code     = src-doc.exch-code
        t-doc.exch-rate     = src-doc.exch-rate
        t-doc.exch-scale    = src-doc.exch-scale
      .
      
      run fill-mol.
      
      
    end.

  end.
   if pardoc-mode = {&add-def} then do:
     wait-for go of frame {&frame-name} focus t-doc.cli-code.
   end.
   else do:
     browse {&browse-name}:SENSITIVE = true .
     menu-item m-outs-1:SENSITIVE = true .
     r-outs:SENSITIVE = true .
     wait-for go of frame {&frame-name} focus {&browse-name}  .
   end.
end.
end. /* do while */
run disable_ui in this-procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-bc d-in-doc
PROCEDURE add-bc :
run corr-t-doc in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
  run choose-bc  in this-procedure no-error.
  find t-doc where recid( t-doc ) = pardoc-rec.
  run UI-on in this-procedure ( input "line" ).
end procedure.

procedure proc-b-mark :
  run local-mark in this-procedure.
  assign varlog = {&browse-name} :select-next-row( ) in frame {&frame-name}.
  apply "ENTRY":U to {&browse-name} in frame {&frame-name}.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-doc-line-local d-in-doc
PROCEDURE add-doc-line-local :
define buffer bf_contract-specif for ub.contract-specif.
define buffer bf-hv_doc-line     for ub.doc-line.
define buffer bf_goods           for ub.goods.
define buffer buf_assortment-matrix for ub.assortment-matrix  .

define variable v-type-mode-spr as character no-undo .
define variable varschartic like doc-line.artic initial " " no-undo.
define variable v-choice    as   integer                    no-undo.
define variable v-rid       as   integer                    no-undo.
define variable v-rid-list  as   char                       no-undo.
define variable i           as   integer                    no-undo.
define variable v-stat as character no-undo init ?.
define variable v-list as character no-undo init ?.

do on stop undo, return error return-value :
  run corr-t-doc in this-procedure no-error.
  if error-status:error then do:
    return error return-value.
  end.
  
  if trn-type = {&is-lgas} or trn-type = {&is-lgas-corr} or trn-type = {&is-fuel}
  then do:
    if trn-type = {&is-lgas} or trn-type = {&is-lgas-corr}
    then do:
      run ref/gds-ref.p
      ( 
         input parparentproc
        ,input "b-sel"
        ,input {&all}             /*p-stat */
        ,input "lgas"             /*p-list  */
        ,input {&all}             /*p-cond  */
        ,input ?             /*p-rec   */
        ,input ?            /*p-grp   */
        ,input t-doc.cli-type             /*p-cli-type */
        ,input t-doc.cli-code             /*p-cli-code  */
        ,input v-cntxt-obj-type    /*p-obj-type  */
        ,input v-cntxt-obj-code    /*p-obj-code  */
        ,input ?             /*p-other     */
        ,output varnotes).
    end.
    else do:
      run ref/gds-ref.p
      ( 
         input parparentproc
        ,input "b-sel"
        ,input {&all} /*p-stat */
        ,input "ptrl" /*p-list  */
        ,input {&all}      /*p-cond  */
        ,input ?             /*p-rec   */
        ,input ?             /*p-grp   */
        ,input t-doc.cli-type             /*p-cli-type */
        ,input t-doc.cli-code             /*p-cli-code  */
        ,input v-cntxt-obj-type    /*p-obj-type  */
        ,input v-cntxt-obj-code    /*p-obj-code  */
        ,input ?             /*p-other     */
        ,output varnotes).
    end.
  end.
  else do:

    v-choice = 0.
    if t-doc.contract-code <> 0 then do:
  /*
       find first bf_contract-specif where
                  bf_contract-specif.host-code    = t-doc.host-code
              and bf_contract-specif.contract-num = t-doc.contract-code
            no-lock no-error.
  */
       {str/cont-slave-inc.i
            &FIND_FIRST = YES
            &BUFFER_SPECIF   = bf_contract-specif
            &P_HOST_CODE     = t-doc.host-code
            &P_CONTRACT_NUM  = t-doc.contract-code
            &NO_LOCK=YES
            &NO_ERROR=YES
       }
  
      if available bf_contract-specif then do:
        run gbl/d-askw.w
          (input "Добавление товаров"
          ,input "Выберите один из пунктов для добавления в накладную" + {&new-line}
               + "товаров по спецификации к договору" + {&new-line}
          ,input "|"
          ,input "Все|Выборочно|По справочнику|Отказ"
          ,input "Все недобавленные товары по спецификации|"
               + "Выборочно товары по спецификации|"
               + "Выбор товаров из справочника|"
               + "Отказ от выполнения операции"
          ,input 1 /* значение возвращаемое при нажатии enter */
          ,input 4 /* значение возвращаемое при нажатии escape */
          ,output v-choice
          ).
        if v-choice = 4 then do:
          run UI-on in this-procedure ( input "line" ).
          return.
        end.
      end.
    end.
    if v-choice = 0 then
      v-choice = 3. /* Выбор из справочника */
  
    assign
      /*line-mode = {&add-def}*/
      varnotes = '':u
      varlns-cnt = 1.
  
    case v-choice:
      when 1 then do: /* Все товары по спецификации */
  
  /*
        for each bf_contract-specif where
                 bf_contract-specif.host-code    = t-doc.host-code
             AND bf_contract-specif.contract-num = t-doc.contract-code
             no-lock
  */
        {str/cont-slave-inc.i
             &FOR_ = YES
             &EACH_ = YES
             &BUFFER_SPECIF   =  bf_contract-specif
             &P_HOST_CODE     =  t-doc.host-code
             &P_CONTRACT_NUM  =  t-doc.contract-code
             &NO_LOCK=YES
             &NO_END=YES
        }
  
            on error undo, return error return-value :
          find first bf_goods where bf_goods.gds-code = bf_contract-specif.gds-code no-lock.
          find first bf-hv_doc-line where bf-hv_doc-line.doc-code  = t-doc.doc-code     and
                                          bf-hv_doc-line.artic     = bf_goods.artic     and
                                          bf-hv_doc-line.prod-type = bf_goods.prod-type and
                                          bf-hv_doc-line.prod-code = bf_goods.prod-code no-lock no-error.
          if not available bf-hv_doc-line then do:
            assign
              varnotes = varnotes + (if varnotes = '':u then '':u else ',':u) + string(recid(bf_goods)).
          end.
        end.
        if varnotes = '':u then do:
          message "Вы добавили уже все товары по спецификации."
          view-as alert-box.
        end.
      end.
  
      when 2 then do: /* Выборочно товары по спецификации */
        run str/contspec.w (input parparentproc,
                        input "b-sel,b-mark",
                        input {&lookup},
                        input t-doc.host-code,
                        input t-doc.contract-code,
                        output v-rid-list) .
        if v-rid-list = '':u then do:
          message "Нет выбранных товаров по спецификации."
            view-as alert-box.
        end.
        /* Формируем список recid'ов товаров по выбранным строкам спецификации */
        do i = 1 to num-entries(v-rid-list):
          v-rid = integer(entry(i, v-rid-list)).
          find bf_contract-specif where recid(bf_contract-specif) = v-rid no-lock no-error.
          if available bf_contract-specif then do:
            find first bf_goods where bf_goods.gds-code = bf_contract-specif.gds-code no-lock.
            assign
              varnotes = varnotes + (if varnotes = '':u then '':u else ',':u) + string(recid(bf_goods)).
          end.
        end.
      end.
  
      when 3 then do: /* из справочника */
        find first buf_assortment-matrix no-lock where
                   buf_assortment-matrix.obj-code = v-cntxt-obj-code and
                   buf_assortment-matrix.obj-type = v-cntxt-obj-type and
                   buf_assortment-matrix.asmt-status = integer ({&current-status-int}) no-error .
                    if available buf_assortment-matrix then do:
                        v-type-mode-spr = {&g___object} .
                    end.
                    else do:
                        v-type-mode-spr = {&all} .
                    end.
        run str/chs-gds.w ( input parparentproc
                      , input v-cntxt-obj-type
                      , input v-cntxt-obj-code
                      , input "":u
                      , input t-doc.status_
                      , input "Строка ПН № " + t-doc.doc-code + " " + t-doc.status_ + " " + string (t-doc.flag_, "+/-")
                      , input v-type-mode-spr  /*режим вызова справочника товаров*/
                      , input t-doc.cli-type
                      , input t-doc.cli-code
                      , input t-doc.host-code
                      , input t-doc.ext-doc-type
                      , input-output varschartic
                      , output varnotes) no-error.
      end.

    end case.
  end.
  run cycle-add in this-procedure.
  run UI-on     in this-procedure ( input "line" ).
end. /* on stop */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE after_qnty d-in-doc
PROCEDURE after_qnty :
define  input parameter p-doc-line-rec as   recid                 no-undo.
  define output parameter p-out-qnty-kg  like ub.doc-line.fact-qnty no-undo initial 0.0.

  define variable p-inv-line-rec as recid   no-undo.
  define variable is-petrol      as logical no-undo.
  define variable is-pieces      as logical no-undo.

  define buffer buf_inv-line for ub.inv-line.
  define buffer buf_doc-line for ub.doc-line.

  do on error undo, return error return-value :
    find buf_doc-line       no-lock where recid( buf_doc-line ) = p-doc-line-rec no-error.
    if not available buf_doc-line then do:
      assign p-out-qnty-kg = ?.
      undo, return error "after_qnty: не найдена строка накладной".
    end.
    { str/is-petrl.i
        buf_doc-line.artic
        buf_doc-line.prod-type
        buf_doc-line.prod-code
        is-petrol
        is-pieces
        no-error
    }
    if error-status :error or v-is-ptrl <> "yes" or is-petrol <> yes or is-pieces <> no then do:
      undo, return error substitute( 'inv-line_price: &1 (произв. &2 &3) не топливный товар',
                                     buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code ).
    end.

    find buf_inv-line          no-lock where
         buf_inv-line.doc-code  = buf_doc-line.doc-code  and
         buf_inv-line.artic     = buf_doc-line.artic     and
         buf_inv-line.prod-code = buf_doc-line.prod-code and
         buf_inv-line.prod-type = buf_doc-line.prod-type no-error.
    if available buf_inv-line then do:
      assign
        p-inv-line-rec = recid( buf_inv-line )
      .
      find buf_doc-line exclusive-lock where recid( buf_doc-line ) = p-doc-line-rec.
      find buf_inv-line exclusive-lock where recid( buf_inv-line ) = p-inv-line-rec.
      assign
        p-out-qnty-kg = buf_inv-line.after-cli-qnty
      .
      find buf_inv-line        no-lock where recid( buf_inv-line ) = p-inv-line-rec.
      find buf_doc-line        no-lock where recid( buf_doc-line ) = p-doc-line-rec.

      release buf_inv-line.
      release buf_doc-line.
    end. /* if available buf_inv-line */
  end. /* on error */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE apply-entry-next-field d-in-doc
PROCEDURE apply-entry-next-field :
define input parameter parself-name as character no-undo.
  case parself-name:
  when "ship-num" then
       if t-doc.ship-date:sensitive in frame {&frame-name} then apply "entry" to t-doc.ship-date in frame {&frame-name}.
  when "ship-date" then
       if t-doc.tot-cli:sensitive in frame {&frame-name} then apply "entry" to t-doc.tot-cli in frame {&frame-name}.
  when "exch-date" then
       if t-doc.exch-code:sensitive in frame {&frame-name} then apply "entry" to t-doc.exch-code in frame {&frame-name}.
  when "tot-cli" then do:
       if b-add:sensitive  in frame {&frame-name} then apply "entry" to b-add in frame {&frame-name}.
  end.
  end case.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ask-copy d-in-doc
PROCEDURE ask-copy :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable v-num as integer initial 1 no-undo.
run gbl/d-askw.w
  (  input "Вопрос"
  ,  input "По каким количествам будем производить копирование?"
          + {&new-line} + (if t-d-b.status_ <> {&inquiry} then "Внимание ! Если копировать из документарных количеств, то становится невозможным копирование с сохранением свойств партий документа источника." else "":U)
  ,  input "|^"
  ,  input "Фактическим|"
         + "Документарным|"
         + "Отмена"
  ,  input "Исходя из фактических количеств в признаках.|"
         + "Исходя из документарных количеств в признаках.|"
         + "Отменить копирование."
  ,  input 1
  ,  input 3
  , output v-num
  ).
  if v-num = 3 then do:
    return no-apply.
  end.
{ str/copy-in.i
  parparentproc
  recid(t-doc)
  lib-trn_ret-doc
  lib-trn_ret-line
  lib-trn_ret-line-attr
  lib-trn_ret-dtl
  lib-trn_ret-parts
  yes
  yes
  no
  "(if v-num = 1 then yes else no)"
  this-procedure
  no-error
}
if error-status:error then do:
assign
  pardoc-mode = {&update}.
  run UI-on in this-procedure ( input "line" ) no-error .
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .
  return error return-value.
end.
assign
  pardoc-mode = {&update}.
  run UI-on in this-procedure ( input "line" ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ass-frame-light d-in-doc
PROCEDURE ass-frame-light :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter parself-name as character no-undo.
case parself-name:
  when "tot-cli"    then do: if input frame {&frame-name} t-doc.tot-cli    <> t-doc.tot-cli    then assign frame {&frame-name} t-doc.tot-cli    . end.
  when "tot-transp" then do: if input frame {&frame-name} t-doc.tot-transp <> t-doc.tot-transp then assign frame {&frame-name} t-doc.tot-transp . end.
  when "tot-other"  then do: if input frame {&frame-name} t-doc.tot-other  <> t-doc.tot-other  then assign frame {&frame-name} t-doc.tot-other  . end.
  when "ord-num"    then do: if input frame {&frame-name} t-doc.ord-num    <> t-doc.ord-num    then assign frame {&frame-name} t-doc.ord-num    . end.
  when "ship-num"   then do: if input frame {&frame-name} t-doc.ship-num   <> t-doc.ship-num   then assign frame {&frame-name} t-doc.ship-num   . end.
  when "ship-date"  then do: if input frame {&frame-name} t-doc.ship-date  <> t-doc.ship-date  then assign frame {&frame-name} t-doc.ship-date  . end.
end case.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-exch d-in-doc
PROCEDURE check-exch :
/* -----------------------------------------------------------
    Purpose:     проверка правильности даты таможни и валюты поставщика
  -------------------------------------------------------------*/
  if input frame {&frame-name} t-doc.exch-date = ? then do:
    message "Не задана дата растаможивания.".
    apply "entry" to t-doc.exch-date in frame {&frame-name}.
    return error.
  end.
  find ub.currency where ub.currency.curr-code = input t-doc.exch-code no-lock no-error.
  if not available ub.currency then do:
    message "Неправильная валюта поставщика - такой валюты нет.".
    apply "entry" to t-doc.exch-code in frame {&frame-name}.
    return error.
  end.
  if t-doc.exch-code <> ub.currency.curr-code then do:
    if ub.currency.curr-code = 0 then do:
      /*Если курс был задан и отличался от 1*/
      if (t-doc.exch-rate <> ? and t-doc.exch-scale <> ? and
          (t-doc.exch-rate <> 1 or t-doc.exch-scale <> 1)) then do:
        varlog = no.
        message "Пересчитать цены поставщика в {&abbr_rubli} по курсу поставщика ?"
                        view-as alert-box question buttons YES-NO update varlog.
        if varlog then do:
          run waitfram-show in this-procedure ( input "Пересчет цен поставщика в {&abbr_rubli}. Ждите..." ).
          for each  ub.doc-line where  ub.doc-line.doc-code = t-doc.doc-code:
             ub.doc-line.price-cli =  ub.doc-line.price-cli * t-doc.exch-rate / t-doc.exch-scale.
          end.
          run waitfram-hide in this-procedure .
        end.
      end.
      t-doc.print-rubl = yes.
      assign
        t-doc.exch-rate = 1
        t-doc.exch-scale = 1.
      disable t-doc.exch-rate t-doc.exch-scale r-acc with frame {&frame-name}.
    end.
    else do:
      find last ub.curr-accnt where ub.curr-accnt.curr-code = ub.currency.curr-code
                             and ub.curr-accnt.exch-date <= input t-doc.exch-date use-index pi no-lock no-error.
      if available ub.curr-accnt then do:
        assign
          t-doc.exch-rate = ub.curr-accnt.exch-rate
          t-doc.exch-scale = ub.curr-accnt.exch-scale.
      end.
      else do:
        assign
          t-doc.exch-rate = ?
          t-doc.exch-scale = ?.
      end.
      if t-doc.exch-code = 0 and
        /*Если курс задается и отличается от 1*/
        (t-doc.exch-rate  <> ? and
         t-doc.exch-scale <> ? and
         (t-doc.exch-rate <> 1 or t-doc.exch-scale <> 1)
        ) then do:
        varlog = no.
        message "Пересчитать цены поставщика в валюту ГТД по курсу ММВБ (справочника) ?"
                        view-as alert-box question buttons YES-NO update varlog.
        if varlog then do:
          run waitfram-show in this-procedure ( input "Пересчет цен поставщика в валюту ГТД. Ждите..." ).
            for each  ub.doc-line where  ub.doc-line.doc-code = t-doc.doc-code:
             ub.doc-line.price-cli =  ub.doc-line.price-cli / t-doc.exch-rate * t-doc.exch-scale.
          end.
          run waitfram-hide in this-procedure  .
        end.
      end.
      t-doc.print-rubl = no.
      enable t-doc.exch-rate t-doc.exch-scale r-acc with frame {&frame-name}.
    end.
    assign
      t-doc.exch-code = ub.currency.curr-code.
    display t-doc.exch-code ub.currency.curr-abbr
            t-doc.exch-rate t-doc.exch-scale with frame {&frame-name}.
  end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-reason d-in-doc
PROCEDURE check-reason :
define variable j_rsn-code like ub.trn-reason.reason-code no-undo.

  assign j_rsn-code = ( input frame {&FRAME-NAME} t-doc.reason-code ).
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = j_rsn-code no-error.
  if not available ub.trn-reason then do:
    if j_rsn-code <> ? and j_rsn-code <> 0 then do:
      message "Неверно указано основание (причина) создания документа." view-as alert-box error.
    end.
    assign  rsn-name = "".
    display rsn-name with frame {&FRAME-NAME}.
    if j_rsn-code = ? or j_rsn-code = 0 then do:
      assign t-doc.reason-code = 0.
      return.
    end.
    else do:
      return error.
    end.
  end.
  assign  rsn-name = ub.trn-reason.reason-name.
  display rsn-name with frame {&FRAME-NAME}.
  assign frame {&FRAME-NAME} t-doc.reason-code.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-update d-in-doc
PROCEDURE check-update :
define buffer ch-doc-line for  ub.doc-line.
  define buffer ch-goods    for ub.goods.
  define variable p-same-price as logical   no-undo.
  define variable v-insalepr   as logical   no-undo .
  for each ch-doc-line where ch-doc-line.doc-code = t-doc.doc-code:
      find first ch-goods where ch-goods.artic     = ch-doc-line.artic     and
                                ch-goods.prod-type = ch-doc-line.prod-type and
                                ch-goods.prod-code = ch-doc-line.prod-code no-lock.
      { gbl/gdsobjat.i
        ch-doc-line.obj-type
        ch-doc-line.obj-code
        ch-doc-line.artic
        ch-doc-line.prod-type
        ch-doc-line.prod-code
        "'insalepr=request'":U
        v-insalepr
      }
      if v-insalepr = true then do:
         message "Товар " ch-goods.artic " " ch-goods.prod-type " " ch-goods.prod-code
                 " принимается по продажной цене. Смена цен в накладной недопустима."
                 view-as alert-box error.
         return error.
      end.

      run trg/doclnupd.p ( input  ch-doc-line.doc-code,
                       input  t-doc.obj-type,
                       input  t-doc.obj-code,
                       input  ch-doc-line.artic,
                       input  ch-doc-line.prod-type,
                       input  ch-doc-line.prod-code,
                       output p-same-price) no-error.
      if error-status :error then do:
         message "Ошибка при просмотре учетных цен в партиях." view-as alert-box error.
         return error.
      end.
      if p-same-price = false then do:
         message "Нельзя изменять цены в строках, т.к. имеются разные учетные цены в партиях." SKIP
                 "Товар " ch-doc-line.artic SKIP
                          ch-doc-line.prod-type SKIP
                          ch-doc-line.prod-code
         view-as alert-box error.
         return error.
     end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chg-line d-in-doc
PROCEDURE chg-line :
define variable line-doc     as recid   no-undo.
define variable varext-cycle as logical no-undo.
define buffer chg-goods for ub.goods.
if not available  ub.doc-line then do:
  message "Неправильный выбор строки.".
  return error.
end.

do on error undo, return error return-value :
find chg-goods where chg-goods.prod-code =  ub.doc-line.prod-code  and
                     chg-goods.prod-type =  ub.doc-line.prod-type  and
                     chg-goods.artic     =  ub.doc-line.artic    no-lock.
/*line-mode = {&update}.*/
line-rec  = recid(ub.doc-line).
line-doc  = RECID(t-doc).
gds-rec   = RECID(chg-goods).
varlns-cnt = 1.
run str/in-line.w ( input  parparentproc,
                    input  {&update},
                    input  pardoc-rec,
                    input-output line-rec,
                    input  gds-rec,
                    input  varlns-cnt,
                    output varext-cycle,
                    input  0,
                    input  ?,
                    input varinplnsum ) no-error.
FIND t-doc WHERE RECID(t-doc) = line-doc.
run UI-on in this-procedure ( input "line" ).
end. /* on stop */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chg-purch-code d-in-doc
PROCEDURE chg-purch-code :
define buffer bf_doc-line for ub.doc-line.
define buffer bf_goods    for ub.goods.
define buffer bf_pl-gds   for ub.pl-gds.
define input parameter parpurch-int-code like ub.trn-doc.purch-code no-undo.
do transaction on error undo, return error return-value :
if parpurch-int-code = {&bef-responsible-storage-code} then do:
  for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code on error undo, return error return-value :
    find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                              bf_goods.prod-type = bf_doc-line.prod-type and
                              bf_goods.prod-code = bf_doc-line.prod-code no-lock.
    find first bf_pl-gds where bf_pl-gds.gds-code = bf_goods.gds-code and
                               bf_pl-gds.obj-type = t-doc.obj-type    and
                               bf_pl-gds.obj-code = t-doc.obj-code    no-lock no-error.
    if available bf_pl-gds then do:
      message "Товар:" bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " резервируется по складским местам." skip
              "Его нельзя приходывать на ответственное хранение."
      view-as alert-box error.
      return error.
    end.
  end.
end.

assign
  t-doc.purch-code = parpurch-int-code.
for each ub.parts where ub.parts.out-code = t-doc.doc-code on error undo, return error return-value :
  assign ub.parts.purch-code = t-doc.purch-code.
end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-upd-date d-in-doc
PROCEDURE chk-upd-date :
define input parameter parself-name as character no-undo.
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
if input frame {&frame-name} t-doc.fact-date  <> t-doc.fact-date  or
   input frame {&frame-name} t-doc.shift-date <> t-doc.shift-date or
   input frame {&frame-name} t-doc.shift-num  <> t-doc.shift-num then do:
if parself-name = "fact-date" then do:
  { gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code v-today }
  if input frame {&frame-name} t-doc.fact-date > v-today then do:
     message "Дата больше сегодняшней даты на объекте." view-as alert-box error.
     display t-doc.fact-date with frame {&frame-name}.
     return error.
  end.

if input frame {&frame-name} t-doc.fact-date < v-today then do:
define variable v-value-character as character no-undo .
define variable v-value-date      as date no-undo .
define variable v-value-decimal   as decimal no-undo .
define variable v-value-integer   as integer no-undo .
define variable v-value-logical   as logical no-undo .
define variable v-tth             as handle no-undo .

    if v-back-date <> true then do:
      message "Запрещено работать задним числом !" view-as alert-box information .
      display t-doc.fact-date with frame {&frame-name}.
      return error.
    end.
end.

  if input frame {&frame-name} t-doc.fact-date < v-today - 7 then do:

     varlog = yes.
     message "Заведенная факт дата отличается более чем на 7 дней от сегодняшней даты на объекте."
             "Отказаться от заведения даты?" view-as alert-box question
             buttons yes-no update varlog.
     if varlog then do:
        display t-doc.fact-date with frame {&frame-name}.
        return error.
     end.
  end.
  assign varlog = no.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_income_add-back-date':U
    {&cntxt-object}
    t-doc.host-code
    t-doc.obj-type
    t-doc.obj-code
    0
    0
    0
    true
    varlog
  }
  if varlog = no then do:
     display t-doc.fact-date with frame {&frame-name}.
     return error.
  end.
  assign varlog = no.
  message "Вы хотите изменить фактическую дату?" skip
          "Если дату задать как '?' она при закрытии на факт проставится днем закрытия."
  view-as alert-box question buttons yes-no update varlog.
  if not varlog then do:
     display t-doc.fact-date with frame {&frame-name}.
     return error.
  end.
end.
assign frame {&frame-name}
  t-doc.fact-date
  t-doc.shift-date
  t-doc.shift-num
  t-doc.shift-name.
if t-doc.fact-date <> today
then
  t-doc.fact-time = if (time < (12 * 60 * 60)) then time else (12 * 60 * 60) .
if t-doc.fact-date = ? then t-doc.fact-time = ? .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choice-currency d-in-doc
PROCEDURE choice-currency :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
find ub.currency where ub.currency.curr-code = input frame {&frame-name} t-doc.exch-code no-error.
if not available ub.currency then do:
  run ref/currency.w ( input parparentproc, input "b-sel", input-output ref-rec ).
  if ref-rec = ? then do: return error. end.
  find ub.currency where recid ( ub.currency ) = ref-rec.
end.
RUN exch-rate in this-procedure.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-b-parts d-in-doc
PROCEDURE choose-b-parts :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable varline-mode      as character no-undo .

if not available  ub.doc-line then do:
  message "Неправильный выбор строки - партии недоступны.".
  return error.
end.

line-rec = recid ( ub.doc-line).
find ub.goods where ub.goods.prod-code =  ub.doc-line.prod-code
             and ub.goods.prod-type =  ub.doc-line.prod-type
             and ub.goods.artic     =  ub.doc-line.artic no-lock.
gds-rec = recid (ub.goods).
do transaction on error   undo, return error return-value :
   if pardoc-mode = {&update} then do:
     find t-doc where recid (t-doc) = pardoc-rec exclusive.
     find  ub.doc-line where recid ( ub.doc-line) = line-rec exclusive.
     varline-mode = {&update}.
     FOR EACH old-doc-line: DELETE old-doc-line. END.
     CREATE old-doc-line.
     BUFFER-COPY  ub.doc-line to old-doc-line.
   end.
   else varline-mode = {&lookup}.
   
   if v-by-utd
   then do :
     parext-doc-mode = "vsd_corr-parts" .
   end .
   
   if parext-doc-mode = "vsd_corr-parts"
   or parext-doc-mode = "vsd"
   or  parext-doc-mode = "corr-parts"
   then do :
     find t-doc where recid (t-doc) = pardoc-rec exclusive.
     find doc-line where recid (doc-line) = line-rec exclusive.
     varline-mode = parext-doc-mode.
   end .
   run str/parts-l.w
     (  input parparentproc
     ,  input t-doc.obj-type            /* v-obj-type   */
     ,  input t-doc.obj-code            /* v-obj-code   */
     ,  input ub.goods.gds-code         /* p-gds-code   */
     ,  input t-doc.doc-code            /* p-doc-code   */
     ,  input varline-mode              /* p-edit-mode  */
     ,  input {&parts-l_parts-document} /* p-r-parts    */
     ,  input {&parts-l_object-current} /* p-one-all    */
     ,  input {&parts-l_call-document}  /* p-call-point */
     , output prt-rec                   /* part-recid   */
     ) .
   run str/chk-prt.p ( input line-rec, input no, buffer t-doc ).
   { str/chkwhole.i
     ub.doc-line.doc-code
     ub.doc-line.artic
     ub.doc-line.prod-type
     ub.doc-line.prod-code
     ub.doc-line.cli-qnty
     ub.doc-line.doc-qnty
     ub.doc-line.fact-qnty
    yes
    no-error
    }
   if error-status :error then do: undo, return error return-value. end.
   if pardoc-mode = {&update} then DO:
      /* Пересчитываем накладную */
      { str/clcintrn.i
         parparentproc
         recid(ub.doc-line)
         ub.doc-line.doc-code
         ub.doc-line.artic
         ub.doc-line.prod-type
         ub.doc-line.prod-code
         old-doc-line.price-cli
         old-doc-line.price-rubl
         old-doc-line.price-base
         old-doc-line.cli-qnty
         old-doc-line.cli-base-rate
         old-doc-line.fact-qnty
         old-doc-line.doc-qnty
         old-doc-line.vat-pc
         old-doc-line.slt-pc
         old-doc-line.road-tax
         old-doc-line.excise
         old-doc-line.transport-rubl
         old-doc-line.other-rubl
         "'update'"
         "''"
         no-error
        }

      if error-status :error then do: undo, return error return-value. end.
      run full-recount in this-procedure no-error.
      if error-status :error then do: undo, return error return-value. end.
   END.
end. /* transaction */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-b-prt d-in-doc
PROCEDURE choose-b-prt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define variable j_pl-code         as integer no-undo .
  define variable is_reserv-pl-code as logical no-undo .
  define variable is-petrol         as logical no-undo .
  define variable is-pieces         as logical no-undo .

if not available  ub.doc-line then do:
  message "Неправильный выбор строки.".
  return error.
end.
define variable prt-mode as character no-undo.
line-rec = recid ( ub.doc-line).
find ub.goods where ub.goods.prod-code =  ub.doc-line.prod-code
             and ub.goods.prod-type =  ub.doc-line.prod-type
             and ub.goods.artic     =  ub.doc-line.artic no-lock.
gds-rec = recid (ub.goods).
find ub.gds-prt where ub.gds-prt.upper-code = ub.goods.prt-root no-lock.
if ub.gds-prt.node-name = {&empty-scale} then do:
  message "Товар :" ub.goods.artic ub.goods.gds-name
                  "не делится на признаки - шкала недоступна.".
  return error.
end.
do transaction on error undo, return error:
   if pardoc-mode = {&update} then do:
     find t-doc    where recid (t-doc)    = pardoc-rec exclusive no-error.
     if not available t-doc then do:
       message "Документ не найден. Возможно удален." view-as alert-box error.
       return error.
     end.
     find  ub.doc-line where recid ( ub.doc-line) = line-rec exclusive .
     assign
       prt-mode = {&prt-def}.
     for each old-doc-line:
       delete old-doc-line.
     end.
     create old-doc-line.
     buffer-copy  ub.doc-line to old-doc-line.
   end.
   else do:
     find t-doc    where recid (t-doc) = pardoc-rec no-lock no-error.
     if not available t-doc then do:
       message "Документ не найден. Возможно удален." view-as alert-box error.
       return error.
     end.

     prt-mode = {&lookup}.
   end.
   prt-rec = ?.
   if (t-doc.status_ = {&wayb} and t-doc.flag_ = no) or t-doc.status_ = {&inquiry} then do:
     run str/doc-p.p
       ( input parparentproc
       , input pardoc-rec
       , input line-rec
       , input gds-rec
       , input prt-mode )
       .
   end.
   else do:
     run str/fac-p.p
       ( input parparentproc
       , input pardoc-rec
       , input line-rec
       , input gds-rec
       , input prt-mode     )
       .
   end.
   if line-rec <> ? then do:
      run str/chk-prt.p ( input line-rec, input no, buffer t-doc ).
   end.
   if pardoc-mode = {&update} then do:
      if line-rec <> ? then do:
        find first ub.goods no-lock
          where ub.goods.artic     =  ub.doc-line.artic
            and ub.goods.prod-type =  ub.doc-line.prod-type
            and ub.goods.prod-code =  ub.doc-line.prod-code
          .
        { str/is-petrl.i
            ub.goods.artic
            ub.goods.prod-type
            ub.goods.prod-code
            is-petrol
            is-pieces
            no-error
        }
        if not error-status :error
          and v-is-ptrl = "yes"
          and is-petrol = true
          and is-pieces = false
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Топливный товар не разбивается по шкалам!!!!!" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        run plgdsfnd in this-procedure
          (  input no
          ,  input t-doc.obj-type
          ,  input t-doc.obj-code
          ,  input ub.goods.gds-code
          , output is_reserv-pl-code
          , output j_pl-code
          ) no-error .
        if error-status :error then do:
          message
            "Ошибка при выборе складского места." skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        if is_reserv-pl-code = yes then do:
/* ?????????????????????????????????????????????????????? */
/*          run str/dcpldtls.w*/
/*            (  input parparentproc*/
/*            ,  input {&reference}*/
/*            ,  input pardoc-mode*/
/*            ,  input  ub.doc-line.obj-type*/
/*            ,  input  ub.doc-line.obj-code*/
/*            ,  input  ub.doc-line.doc-code*/
/*            ,  input ub.goods.gds-code*/
/*            ,  input  ub.doc-line.doc-qnty*/
/*            ,  input  ub.doc-line.fact-qnty*/
/*            ,  input  ub.doc-line.cli-qnty*/
/*            ,  input  ub.doc-line.cli-qnty*/
/*            ,  input get-kg-fact-qnty( buffer  ub.doc-line )*/
/*            ,  input  ub.doc-line.doc-density*/
/*            ,  input  ub.doc-line.fact-density*/
/*            , output j_pl-code*/
/*            , output varst-qnty-pl*/
/*            ) no-error.*/
/*          if error-status:error then do:*/
/*            undo, return error return-value .*/
/*          end.*/
/*          if varst-qnty-pl <> yes then do:*/
/*            message "Не были установлены количества по складским местам." view-as alert-box.*/
/*            return error.*/
/*          end.*/

/*          { str/chkdcplg.i*/
/*              recid(ub.doc-line)*/
/*              no-error*/
/*          }*/
/*          if error-status :error*/
/*          then do:*/
/*            undo, return error return-value .*/
/*          end.*/
/* ?????????????????????????????????????????????????????? */
        end.
      end.
      /* Пересчитываем накладную */
      { str/clcintrn.i
        parparentproc
        recid(ub.doc-line)
         ub.doc-line.doc-code
         ub.doc-line.artic
         ub.doc-line.prod-type
         ub.doc-line.prod-code
        old-doc-line.price-cli
        old-doc-line.price-rubl
        old-doc-line.price-base
        old-doc-line.cli-qnty
        old-doc-line.cli-base-rate
        old-doc-line.fact-qnty
        old-doc-line.doc-qnty
        old-doc-line.vat-pc
        old-doc-line.slt-pc
        old-doc-line.road-tax
        old-doc-line.excise
        old-doc-line.transport-rubl
        old-doc-line.other-rubl
        "'update'"
        "''"
        no-error
      }
      if error-status :error then do: undo, return error. end.
      run full-recount in this-procedure no-error.
      if error-status :error then do: undo, return error return-value. end.
   end.
end. /*transaction*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-bc d-in-doc
PROCEDURE choose-bc :
{ str/in-doctr.i }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE corr-t-doc d-in-doc
PROCEDURE corr-t-doc :
find t-doc where recid (t-doc) = pardoc-rec exclusive.
run check-exch in this-procedure.
run check-rate in this-procedure.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cr-tt-upd d-in-doc
PROCEDURE cr-tt-upd :
do on error undo, return error return-value :

for each tt-upd-attr: delete tt-upd-attr. end.
for each tt-upd-attr-fuel: delete tt-upd-attr-fuel. end.

&scop create-record create tt-upd-attr. ~
 assign~
  tt-upd-attr.code =  ~{&~{&attr-code~}~}  . ~
                                        ~
~{ str/tdat-cod.i                   ~
     tt-upd-attr.code           ~
     tt-upd-attr.type-attr      ~
     tt-upd-attr.format-attr    ~
     tt-upd-attr.fillin_width   ~
     tt-upd-attr.fillin_height  ~
     tt-upd-attr.label-attr     ~
     tt-upd-attr.user-can-edit  ~
     tt-upd-attr.output-display ~
     v-other                    ~
     tt-upd-attr.proc-attr       ~
     tt-upd-attr.full-screen-val ~
     tt-upd-attr.sort_  ~
     no-error         ~
~}                    ~
 if error-status :error then do:    ~
   message "Ошибка при установке атрибутов документа." skip ~
           error-status :get-message(1) skip return-value ~
   view-as alert-box. ~
   return error. ~
 end.
 
 
 &scop create-record-fuel create tt-upd-attr-fuel. ~
 assign~
  tt-upd-attr-fuel.code =  ~{&~{&attr-code~}~}  . ~
                                        ~
~{ str/tdat-cod.i                ~
     tt-upd-attr-fuel.code           ~
     tt-upd-attr-fuel.type-attr      ~
     tt-upd-attr-fuel.format-attr    ~
     tt-upd-attr-fuel.fillin_width   ~
     tt-upd-attr-fuel.fillin_height  ~
     tt-upd-attr-fuel.label-attr     ~
     tt-upd-attr-fuel.user-can-edit  ~
     tt-upd-attr-fuel.output-display ~
     v-other                    ~
     tt-upd-attr-fuel.proc-attr       ~
     tt-upd-attr-fuel.full-screen-val ~
     tt-upd-attr-fuel.sort_  ~
     no-error         ~
~}                    ~
 if error-status :error then do:    ~
   message "Ошибка при установке атрибутов документа." skip ~
           error-status :get-message(1) skip return-value ~
   view-as alert-box. ~
   return error. ~
 end.

define variable vvv as character no-undo init "".
define buffer x-doc for ub.trn-doc  .
find first x-doc no-lock where recid(x-doc) = pardoc-rec no-error .
if available x-doc then do:
   vvv = x-doc.rcv-code .
end.

 if vvv <> "not_delete" then do:
    &scop attr-code trdcattr-nids
    {&create-record}
 end.

&scop attr-code trdcattr-dids
{&create-record}
&scop attr-code trdcattr-nsf
{&create-record}
&scop attr-code trdcattr-dsf
{&create-record}
&scop attr-code trdcattr-expense_own
{&create-record}
&scop attr-code trdcattr-ndog
{&create-record}
&scop attr-code trdcattr-ddog
{&create-record}
&scop attr-code trdcattr-ndov
{&create-record}
&scop attr-code trdcattr-ddov
{&create-record}
&scop attr-code trdcattr-print-num
{&create-record}
&scop attr-code trdcattr-idCountryContr
{&create-record}
&scop attr-code trdcattr-car-time
{&create-record}
&scop attr-code trdcattr-t_pass-fname
{&create-record}
&scop attr-code trdcattr-t_pass-position
{&create-record}
&scop attr-code trdcattr-t_accept-fname
{&create-record}
&scop attr-code trdcattr-t_accept-position
{&create-record}
&scop attr-code trdcattr-ndovwho
{&create-record}
&scop attr-code trdcattr-nosn
{&create-record}
&scop attr-code trdcattr-shipper
{&create-record}
&scop attr-code trdcattr-othermoves
{&create-record}

if v-is-pharm = "yes":U then do:
  &scop attr-code trdcattr-ser_on_pack
  {&create-record}
end.


&scop attr-code trdcattr-ptbobj
{&create-record-fuel}
&scop attr-code trdcattr-ptb-item-pour
{&create-record-fuel}
&scop attr-code trdcattr-autoent
{&create-record-fuel}
&scop attr-code trdcattr-car-num
{&create-record-fuel}
&scop attr-code trdcattr-fio-driver
{&create-record-fuel}
&scop attr-code trdcattr-time-income
{&create-record-fuel}
&scop attr-code trdcattr-inspection-cert
{&create-record-fuel}
&scop attr-code trdcattr-date-cert
{&create-record-fuel}
&scop attr-code trdcattr-condition
{&create-record-fuel}
&scop attr-code trdcattr-seals-condition
{&create-record-fuel}
&scop attr-code trdcattr-date-pour
{&create-record-fuel}
&scop attr-code trdcattr-time-pour
{&create-record-fuel}
&scop attr-code trdcattr-acc-ship
{&create-record-fuel}
&scop attr-code trdcattr-doc-not
{&create-record-fuel}
&scop attr-code trdcattr-spisok-not-doc
{&create-record-fuel}
&scop attr-code trdcattr-time-start
{&create-record-fuel}
&scop attr-code trdcattr-time-end
{&create-record-fuel}
&scop attr-code trdcattr-date-start
{&create-record-fuel}
&scop attr-code trdcattr-date-end
{&create-record-fuel}
&scop attr-code trdcattr-clear-ac
{&create-record-fuel}
&scop attr-code sugtpattr-massa-sug
{&create-record-fuel}
&scop attr-code sugtpattr-teh-loss
{&create-record-fuel}
&scop attr-code sugtpattr-err-allow
{&create-record-fuel}
&scop attr-code trdcattr-date-income
{&create-record-fuel}
&scop attr-code trdcattr-date-pasport
{&create-record-fuel}
&scop attr-code trdcattr-num-pasport
{&create-record-fuel}

end.
end procedure.


procedure err-status :
   message "Данное действие недопустимо в статусе: "
           t-doc.status_ string( t-doc.flag_, "+/-":U ) "."
   view-as alert-box error.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-record d-in-doc
PROCEDURE create-record :
define  input parameter p-doc-code   like ub.trn-doc.doc-code    no-undo.
  define  input parameter p-attr-code  like ub.doc-attr.attr-code  no-undo.
  define  input parameter p-attr-value like ub.doc-attr.attr-value no-undo.
  define output parameter p-exist      as   logical                no-undo.

  { str/tdat-xst.i
      p-doc-code
      p-attr-code
      p-exist }
  if p-exist = no then do:
    { str/tdat-wrt.i
        p-doc-code
        p-attr-code
        p-attr-value
        no-error     }
    if error-status :error then do:
      message error-status :error error-status :get-message( 1 ) '"' + p-attr-code + '"'
      view-as alert-box error.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-cli-cust d-in-doc
procedure set-cli-cust :
  def input parameter p-clitype as char no-undo.
  def input parameter p-clicode as int  no-undo.
  define variable v-tmp-char like ub.thbj-attr.property-value-character no-undo .
  define variable v-tmp-date      like ub.thbj-attr.property-value-date    no-undo .
  define variable v-tmp-decimal   like ub.thbj-attr.property-value-decimal no-undo .
  define variable v-tmp-integer   like ub.thbj-attr.property-value-integer no-undo .
  define variable v-rvd-own-nb as logical no-undo .
  define variable v-rvd-own-nb-type as   character no-undo .
  
  find first clients where clients.obj-type = p-clitype and clients.obj-code = p-clicode no-lock no-error.
  if not available (clients)
  then do:
    return error "Не найден клиент - " + p-clitype + string(p-clicode).
  end.
  disp clients.obj-code @ t-doc.cli-code
          clients.obj-name with frame {&frame-name}.
  disp clients.obj-type @ t-doc.cli-type with frame {&frame-name}.
  
  run adm/shattri.p (
      input "get":U
      ,input t-doc.obj-type
      ,input t-doc.obj-code
      ,input {&attr-petrol}
      ,input  "rvd-own-nb"
      ,output v-tmp-char
      ,output v-tmp-date
      ,output v-tmp-decimal
      ,output v-tmp-integer
      ,output v-rvd-own-nb
      ,output v-rvd-own-nb-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
  if error-status :error then v-rvd-own-nb = false .
  if v-rvd-own-nb = false
  and t-doc.cli-code > 0
  then do :
    find first ub.clients-attr no-lock where ub.clients-attr.obj-type = t-doc.cli-type
                                         and ub.clients-attr.obj-code = t-doc.cli-code
                                         and ub.clients-attr.attr-code = {&attr-owner-code}
                                         no-error .
    if available ub.clients-attr
    and ub.clients-attr.attr-value > ""
    then do :
      if ub.clients-attr.attr-value = "орг" + string(t-doc.host-code)
      then do :     
        v-can-edit = no .                       
        disable b-add b-del with frame {&frame-name}.
      end .
    end .
  end .
  
      run check-cli no-error.
      if error-status :error then return no-apply.
  run fill-mol in this-procedure no-error .
end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cycle-add-cust d-in-doc
procedure cycle-add-cust :
  
  def input parameter p-recgds-list as character no-undo.
  v-modeetc = ",autotrnqr2d".
  varnotes = p-recgds-list.
  run cycle-add in this-procedure.
  run ui-on in this-procedure ( input "line" ).
  
end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cycle-add d-in-doc
PROCEDURE cycle-add :
define buffer bf_goods  for ub.goods.
define buffer bf_pl-gds for ub.pl-gds.
define variable varis-petrolium as logical no-undo.
define variable varis-pieces    as logical no-undo.
define variable varext-cycle    as logical no-undo.
define variable v-is-petrol     as logical no-undo.
define variable v-is-pieces     as logical no-undo.
define variable v-log           as logical no-undo.
define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .

assign
  varlns-cnt = 1.
cycle:
do while varlns-cnt <= num-entries (varnotes):
  
  def var varvalue as character no-undo.
  def var vartype as character no-undo.
  
  assign  gds-rec = integer (entry (varlns-cnt, varnotes)).
  if t-doc.purch-code = {&bef-responsible-storage-code} then do:
    find first bf_goods where recid(bf_goods) = gds-rec no-lock.
    find first bf_pl-gds where bf_pl-gds.gds-code = bf_goods.gds-code and
                               bf_pl-gds.obj-type = t-doc.obj-type    and
                               bf_pl-gds.obj-code = t-doc.obj-code    no-lock no-error.
    if available bf_pl-gds then do:
      message "Товар:" bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " резервируется по складским местам." skip
              "Его нельзя приходовать на ответственное хранение."
      view-as alert-box error.
      assign varlns-cnt = varlns-cnt + 1.
      next.
    end.
  end.
  if vartpsi = "yes":u then do:
    find first bf_goods where recid(bf_goods) = gds-rec no-lock.
    { str/igdstpsi.i
      bf_goods.gds-code
      t-doc.obj-type
      t-doc.obj-code
      no-error
    }
    if error-status :error then do:
      message return-value
      view-as alert-box.
      ASSIGN varlns-cnt = varlns-cnt + 1.
      next.
    end.
  end.
  varvalue = "" .
  find first bf_goods where recid(bf_goods) = gds-rec no-lock.
  run gds-attr-value in this-procedure
    (  input bf_goods.gds-code
    ,  input {&attr-fuel-type}
    , output varvalue
    , output vartype
    ) no-error .
  
  if varvalue = "metan"
  then do:
    message "Товар:" bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " " skip
            "нельзя приходовать в ручном режиме."
    view-as alert-box error.
    assign varlns-cnt = varlns-cnt + 1.
    next.
  end.
  
  if trn-type = {&is-gds}
  then do:
    run gds-attr-value in this-procedure
      (  input bf_goods.gds-code
        ,input {&attr-fuel-type}
        ,output varvalue
        ,output vartype
       ) .
    if varvalue = "lgas" and not (trn-type = {&is-lgas} or trn-type = {&is-lgas-corr})then 
    do:
      message "Товар СУГ:" bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " " skip
              'нельзя приходовать в накладной типа "ТНП" или "Топливо".'
      view-as alert-box error.
      assign varlns-cnt = varlns-cnt + 1.
      next.
    end.
    if varvalue = "petrol" and not (trn-type = {&is-fuel})then 
    do:
      message "Топливный товар:" bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " " skip
              'нельзя приходовать в накладной типа "ТНП" или "СУГ".'
      view-as alert-box error.
      assign varlns-cnt = varlns-cnt + 1.
      next.
    end.

  end.
  
  varvalue = "" .
  EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(t-doc.obj-type, t-doc.obj-code).
 
  RUN gds-attr-value (
                      INPUT bf_goods.gds-code,
                      INPUT {&attr-mark-type},
                      OUTPUT varvalue,
                      OUTPUT vartype
                      ).
  if varvalue > "" then do:
   if EDOParSec:GetIsMarkingForType(varvalue) 
  then do :
      if  t-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then 
      do:
          message "Товар:" bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " " skip
              "нельзя добавлять в ручном режиме, так как он подлежит маркировке."
              view-as alert-box error.
          assign 
              varlns-cnt = varlns-cnt + 1.
          next.          
      end.
      else 
      do:     
          message "Товар:" bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " " skip
              "нельзя добавлять в ручном режиме, так как он подлежит маркировке и должен добавляться помарочно."
              view-as alert-box error.
          assign 
              varlns-cnt = varlns-cnt + 1.
          next.
      end.
  end .
   if  EDOParSec:IsEdo
   and (EDOParSec:GetIsArticForType(varvalue) or EDOParSec:GetIsEdoForType(varvalue))
  then do :
      if  t-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then 
      do:
          message "Товар:" bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " " skip
              "нельзя добавлять в ручном режиме, так как он подлежит маркировке."
              view-as alert-box error.
          assign 
              varlns-cnt = varlns-cnt + 1.
          next.          
      end.
  end .  
/*   if EDOParSec:GetIsMarkingForTypeEDO(varvalue) and EDOParSec:IsEdo                                                  */
/*  then do :                                                                                                           */
/*      if  t-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then                                                                */
/*      do:                                                                                                             */
/*          message "Товар:" bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " " skip*/
/*              "нельзя добавлять, так как он подлежит маркировке."                                                     */
/*              view-as alert-box error.                                                                                */
/*          assign                                                                                                      */
/*              varlns-cnt = varlns-cnt + 1.                                                                            */
/*          next.                                                                                                       */
/*      end.                                                                                                            */
/*  end .                                                                                                               */
  end.
  
  
  if can-find (FIRST ub.clients-attr no-lock where (ub.clients-attr.attr-code = {&attr-supp-np} or ub.clients-attr.attr-code = {&attr-supp-lgas})
                                               and ub.clients-attr.attr-value = "yes")
  then do :
/*    find first bf_goods where recid(bf_goods) = gds-rec no-lock.*/
    { str/is-petrl.i bf_goods.artic bf_goods.prod-type bf_goods.prod-code v-is-petrol v-is-pieces no-error }
    if v-is-petrol then do :
      if not can-find (FIRST ub.clients-attr no-lock where ub.clients-attr.obj-type   = t-doc.cli-type
                                                        and ub.clients-attr.obj-code   = t-doc.cli-code
                                                        and 
                                                          (ub.clients-attr.attr-code  = {&attr-supp-np}
                                                          or ub.clients-attr.attr-code  = {&attr-supp-lgas}
                                                          )
                                                        and ub.clients-attr.attr-value = "yes")
      then do :
        message
        "Контрагент документа не является поставщиком НП или СУГ." skip
        "Продолжить ввод товара?"
        view-as alert-box question buttons yes-no update v-log.
        if not v-log then leave cycle.
      end.
    end.
  end.
  assign
    pardoc-rec = recid(t-doc).
  run str/in-line.w (input  parparentproc,
                     input  ((if varlns-cnt > 1 then "ЦИКЛ":U else {&add-def}) + v-modeetc),
                     input  pardoc-rec,
                     input-output line-rec,
                     input  gds-rec,
                     input  varlns-cnt,
                     output varext-cycle,
                     0,
                     ?,
                     varinplnsum) no-error.
  if varext-cycle = yes then do:
    leave cycle.
  end.
  find t-doc where recid(t-doc) = pardoc-rec.
  ASSIGN varlns-cnt = varlns-cnt + 1.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE del-doc-line d-in-doc 
PROCEDURE del-doc-line :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable rep-rec as recid no-undo.
do transaction on error undo, return error return-value :
if del-list = "" then do:
  /* удаление 1 строки */
  if not available  ub.doc-line then do:
    message "Неправильный выбор строки.".
    return error.
  end.
  varlog = no.
  message "Удалить строку накладной ?   Вы уверены ?"
                view-as alert-box question buttons OK-Cancel update varlog.
  if NOT varlog then return error.
  line-rec = recid ( ub.doc-line).
  del-list = string (recid ( ub.doc-line)).
  get next {&browse-name}.
  if available  ub.doc-line then rep-rec = recid ( ub.doc-line).
  else do:
    reposition {&browse-name} to recid line-rec no-error.
    get prev {&browse-name}.
    rep-rec = recid ( ub.doc-line).
  end.
end.
else do:
  /* удаление отмеченных строк */
  varlog = ?.
  message "УДАЛЕНИЕ  ПО  ОТМЕТКАМ  строк накладной ?" skip (2)
          "YES - удалить все отмеченные строки" skip
          "NO - оставить только отмеченные строки и удалить все остальные" skip (2)
          "CANCEL - ничего не удалять"
  view-as alert-box question buttons yes-no-cancel update varlog.
  if varlog = ? then return error.
  rep-rec = ?.
end.
if varlog then do:
  /* удалить отмеченные */
  assign
    varlns-cnt = 1.
  do while varlns-cnt <= num-entries (del-list):
    assign
      line-rec   = integer (entry (varlns-cnt, del-list))
      varlns-cnt = varlns-cnt + 1.
    find  ub.doc-line where recid ( ub.doc-line) = line-rec exclusive. /*Об'явит транзакцию*/
    if  ub.doc-line.doc-code <> t-doc.doc-code then undo, return error. /* на всякий случай */
    if t-doc.flag_ and  ub.doc-line.doc-qnty <> 0 then do:
      message "Нельзя удалить строку, которая была добавлена в открытый документ.  Артикул:"  ub.doc-line.artic.
      next.
    end.
    { str/clcintrn.i
      parparentproc
      ?
       ub.doc-line.doc-code
       ub.doc-line.artic
       ub.doc-line.prod-type
       ub.doc-line.prod-code
       ub.doc-line.price-cli
       ub.doc-line.price-rubl
       ub.doc-line.price-base
       ub.doc-line.cli-qnty
       ub.doc-line.cli-base-rate
       ub.doc-line.fact-qnty
       ub.doc-line.doc-qnty
       ub.doc-line.vat-pc
       ub.doc-line.slt-pc
       ub.doc-line.road-tax
       ub.doc-line.excise
       ub.doc-line.transport-rubl
       ub.doc-line.other-rubl
      "'delete'"
      "''"
      no-error
    }
    if error-status :error then do:
      undo, return error return-value.
    end.
    delete  ub.doc-line.
  end.
end.
else do:
  /* оставить отмеченные */
  for each  ub.doc-line where  ub.doc-line.doc-code = t-doc.doc-code:
    if can-do (del-list, string (recid ( ub.doc-line))) then next.
    if t-doc.flag_ and  ub.doc-line.doc-qnty <> 0 then do:
      message "Нельзя удалить строку, которая была добавлена в открытый документ.  Артикул:"  ub.doc-line.artic.
      next.
    end.
    { str/clcintrn.i
      parparentproc
      ?
       ub.doc-line.doc-code
       ub.doc-line.artic
       ub.doc-line.prod-type
       ub.doc-line.prod-code
       ub.doc-line.price-cli
       ub.doc-line.price-rubl
       ub.doc-line.price-base
       ub.doc-line.cli-qnty
       ub.doc-line.cli-base-rate
       ub.doc-line.fact-qnty
       ub.doc-line.doc-qnty
       ub.doc-line.vat-pc
       ub.doc-line.slt-pc
       ub.doc-line.road-tax
       ub.doc-line.excise
       ub.doc-line.transport-rubl
       ub.doc-line.other-rubl
      "'delete'"
      "''"
      no-error
    }

    if error-status :error then do:
      undo, return error return-value.
    end.
    delete  ub.doc-line.
  end.
end.
assign
  line-rec = rep-rec.
if available t-doc
then do:
  run gbl/calc-trn.p
    ( input parparentproc
    , input recid( t-doc )
    ) no-error .
  if error-status :error
  then do:
    message return-value skip
            error-status :get-message( 1 )
    view-as alert-box error .
    undo, return error .
  end.
end. /* if available t-doc */
run ui-on in this-procedure ( input "line" ).
end. /* transaction */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-in-doc  _DEFAULT-DISABLE
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
  HIDE FRAME d-in-doc.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disp-exch d-in-doc
PROCEDURE disp-exch :
display
 t-doc.exch-rate
 t-doc.exch-scale
 t-doc.base-rate
 t-doc.base-scale
 with frame {&frame-name}.
end procedure.

procedure fnd-an-doc :
find t-d-b where t-d-b.doc-code = input frame {&frame-name} t-doc.out-code no-lock no-error.
if not available t-d-b then return error.
end procedure.

procedure disp-import :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
APPLY "row-leave" to BROWSE {&browse-name}.
DISPLAY pardoc-code @ t-doc.out-code WITH FRAME {&frame-name}.
APPLY "RETURN" to t-doc.out-code IN FRAME {&frame-name}.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-in-doc  _DEFAULT-ENABLE
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
  DISPLAY varcontract-prn-code varpurch-code-name ov-pc m-inc a-n-c loc-art
          loc-name loc-code varinplnsum wrkr-name agnt-name boss-name rsn-name
      WITH FRAME d-in-doc.
  IF AVAILABLE ub.clients THEN
    DISPLAY ub.clients.obj-name
      WITH FRAME d-in-doc.
  IF AVAILABLE ub.currency THEN
    DISPLAY ub.currency.curr-abbr
      WITH FRAME d-in-doc.
  IF AVAILABLE ub.pay-type THEN
    DISPLAY ub.pay-type.obj-name
      WITH FRAME d-in-doc.
  IF AVAILABLE t-doc THEN
    DISPLAY t-doc.cli-code t-doc.cli-type t-doc.exch-code t-doc.exch-date
          t-doc.discnt-pc t-doc.cst-code t-doc.exch-rate t-doc.exch-scale
          t-doc.tot-cli t-doc.base-rate t-doc.base-scale t-doc.out-code
          t-doc.pay-code t-doc.wrkr t-doc.ord-num t-doc.agnt t-doc.boss
          t-doc.doc-date t-doc.fact-date t-doc.shift-date t-doc.shift-name
          t-doc.shift-num t-doc.SLT-type t-doc.VAT-type t-doc.tot-transp
          t-doc.tot-other t-doc.ship-num t-doc.ship-date t-doc.tot-calc
          t-doc.road-tax t-doc.tot-sale t-doc.tot-fact t-doc.VAT-rubl
          t-doc.VAT-base t-doc.cli-qnty t-doc.doc-qnty t-doc.fact-qnty
          t-doc.reason-code
      WITH FRAME d-in-doc.
  ENABLE b-exit b-prev b-next b-revis b-arch b-add-doc b-cnt b-attr b-in-attr-fuel b-notes
         b-history b-print b-help t-doc.cli-code t-doc.cli-type
         ub.clients.obj-name varcontract-prn-code b-contr-lkp r-clients r-currency
         t-doc.exch-code t-doc.exch-date t-doc.discnt-pc t-doc.cst-code
         t-doc.exch-rate t-doc.exch-scale r-acc t-doc.tot-cli t-doc.base-rate
         t-doc.base-scale t-doc.out-code r-outs t-doc.pay-code r-pay
         varpurch-code-name t-doc.wrkr r-wrkr t-doc.ord-num t-doc.agnt r-agnt
         t-doc.boss r-boss t-doc.doc-date t-doc.fact-date t-doc.shift-date
         t-doc.shift-name t-doc.shift-num r-sht t-doc.SLT-type t-doc.VAT-type
         ov-pc b-add-doc-yes t-doc.tot-transp t-doc.tot-other m-inc
         t-doc.ship-num t-doc.ship-date r-reas a-n-c loc-art loc-name loc-code
         b-mark b-add b-prt b-parts b-lkp b-chg b-del b-live b-renum b-marks
         varinplnsum br-dtl ub.currency.curr-abbr t-doc.tot-calc t-doc.road-tax
         ub.pay-type.obj-name t-doc.tot-sale wrkr-name t-doc.tot-fact
         t-doc.VAT-rubl agnt-name t-doc.VAT-base boss-name t-doc.cli-qnty
         t-doc.doc-qnty t-doc.fact-qnty t-doc.reason-code rsn-name b-calc-tp
      WITH FRAME d-in-doc.
  VIEW FRAME d-in-doc.
  {&OPEN-BROWSERS-IN-QUERY-d-in-doc}
  FRAME d-in-doc:SENSITIVE = NO.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE exch-rate d-in-doc
PROCEDURE exch-rate :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
display ub.currency.curr-code @ t-doc.exch-code with frame {&frame-name}.
do transaction on error   undo, return error :
   run check-exch   in this-procedure.
   run check-rate   in this-procedure.
   run full-recount in this-procedure.
end.
run UI-on in this-procedure ( input "line" ).
apply "entry" to t-doc.tot-cli.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tt d-in-doc
PROCEDURE fill-tt private :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer bf_trn-doc       for ub.trn-doc.
define buffer bf_doc-line      for ub.doc-line.
define buffer bf_doc-line-attr for ub.doc-line-attr.
define buffer bf_gds-dtl       for ub.gds-dtl.
define buffer bf_parts         for ub.parts.
do on error undo, return error return-value :
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock.
for each lib-trn_ret-doc:
  delete lib-trn_ret-doc.
end.
create lib-trn_ret-doc.
buffer-copy bf_trn-doc to lib-trn_ret-doc.
for each lib-trn_ret-line:
  delete lib-trn_ret-line.
end.
for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code no-lock :
  create lib-trn_ret-line.
  buffer-copy bf_doc-line except road-tax to lib-trn_ret-line .
  assign
    lib-trn_ret-line.cst-code = bf_trn-doc.cst-code.
end.
for each lib-trn_ret-line-attr:
  delete lib-trn_ret-line-attr.
end.
for each bf_doc-line-attr where bf_doc-line-attr.doc-code = bf_trn-doc.doc-code
                            and bf_doc-line-attr.attr-code <> 'old_other-ras' 
no-lock :
  create lib-trn_ret-line-attr.
  buffer-copy bf_doc-line-attr to lib-trn_ret-line-attr.
end.
for each lib-trn_ret-dtl :
  delete lib-trn_ret-dtl.
end.
for each bf_gds-dtl where bf_gds-dtl.doc-code = bf_trn-doc.doc-code :
  create lib-trn_ret-dtl.
  buffer-copy bf_gds-dtl to lib-trn_ret-dtl.
end.
for each lib-trn_ret-parts :
  delete lib-trn_ret-parts.
end.
for each bf_parts where bf_parts.out-code = bf_trn-doc.doc-code :
  create lib-trn_ret-parts.
  buffer-copy bf_parts to lib-trn_ret-parts.
end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE full-recount d-in-doc
PROCEDURE full-recount :
for each  ub.doc-line where  ub.doc-line.doc-code = t-doc.doc-code:
   { str/in-vat.i
    t-doc.doc-code
    t-doc.base-rate
    t-doc.base-scale
    t-doc.exch-rate
    t-doc.exch-scale
    t-doc.vat-type
    t-doc.slt-type
     ub.doc-line.artic
     ub.doc-line.prod-type
     ub.doc-line.prod-code
     ub.doc-line.price-cli
     ub.doc-line.cli-base-rate
     ub.doc-line.price-rubl
     ub.doc-line.vat-pc
     ub.doc-line.slt-pc
     ub.doc-line.road-tax
     ub.doc-line.transport-rubl
     ub.doc-line.other-rubl
    varprice-cli
    varprice-cli-unit-base
    varprice-road-tax
    varprice-other-exp
    varprice-transport-exp
    varprice-without-abs
    varprice-slt
    varprice-no-slt
    varprice-vat
    varprice-no-vat-slt
    varprice-rubl
    varprice-road-tax-rubl
    varprice-other-exp-rubl
    varprice-transport-exp-rubl
    varprice-without-abs-rubl
    varprice-slt-rubl
    varprice-no-slt-rubl
    varprice-vat-rubl
    varprice-no-vat-slt-rubl
    varprice-base
    varprice-road-tax-base
    varprice-other-exp-base
    varprice-transport-exp-base
    varprice-without-abs-base
    varprice-slt-base
    varprice-no-slt-base
    varprice-vat-base
    varprice-no-vat-slt-base
    no-error
    }
  if error-status :error then do:
    return error "Ошибка при пересчете линии документа".
  end.

  assign  ub.doc-line.price-cli  = varprice-cli
          ub.doc-line.price-rubl = varprice-rubl
          ub.doc-line.price-base = varprice-base
         .
   /* Пересчитаем прод.цену */

    { str/prslnew.i
      "run"
      ?
      ?
       ub.doc-line.doc-code
       ub.doc-line.artic
       ub.doc-line.prod-type
       ub.doc-line.prod-code
       ub.doc-line.price-rubl
       ub.doc-line.price-base
      varprice-no-vat-slt-rubl
      varprice-no-vat-slt-base
       ub.doc-line.new-price-sale
      no-error }
      if error-status :error then message
        error-status :get-message(1) skip
        return-value skip
        "Нельзя рассчитать новую цену продажи"
        view-as alert-box error
      .
end.

run gbl/calc-trn.p ( input parparentproc, input recid( t-doc ) ) no-error.
if error-status :error then do:
  return error return-value.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-alc-part d-in-doc
PROCEDURE get-alc-part :
define input  parameter p-doc-line-recid as recid no-undo.
  define output parameter op-part-code as character no-undo.

  define variable v-gds-code       as integer no-undo.
  define variable v-alcohol-prod   as logical no-undo .

  define buffer bf_doc-line for ub.doc-line.
  define buffer bf_parts    for ub.parts.

  assign
    op-part-code = ?
  .
  do on error undo, return error return-value :
    { gbl/doclicod.i
      p-doc-line-recid
      v-gds-code
    }

    /* Является ли товар алкогольной продукцией */
    { gbl/gdscdat.i
      v-gds-code
      "'alcohol-prod=request':u"
      v-alcohol-prod
    }
    if v-alcohol-prod then do:
      find bf_doc-line no-lock where recid(bf_doc-line) = p-doc-line-recid.

      /* ищем первую попавшуюся партию из строки приходной накладной и берем ее код
         как код партии по умолчанию */
      find first bf_parts no-lock
        where bf_parts.obj-type  = bf_doc-line.obj-type  and
              bf_parts.obj-code  = bf_doc-line.obj-code  and
              bf_parts.prod-type = bf_doc-line.prod-type and
              bf_parts.prod-code = bf_doc-line.prod-code and
              bf_parts.artic     = bf_doc-line.artic     and
              bf_parts.out-code  = bf_doc-line.doc-code
        no-error.
      if available bf_parts then do:
        assign
          op-part-code = bf_parts.part-code
        .
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-attr-general d-in-doc
PROCEDURE init-attr-general :
/* Атрибуты расходного документа */
do on error undo, return error return-value :
run cr-tt-upd .
define variable varexist                  as logical   no-undo.
  &scop create-record run create-record in this-procedure (  input t-doc.doc-code ~
                                                        ,  input ~{&~{&attr-code~}~} ~
                                                        ,  input  ~{&attr-val~} ~
                                                        , output varexist ) no-error.
&scop attr-val  ""
&scop attr-code trdcattr-nids
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-dids
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-nsf
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-dsf
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-expense_own
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-ndog
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-ddog
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-ndov
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-ddov
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-print-num
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-idCountryContr
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-car-time
{&create-record}
&scop attr-code trdcattr-t_pass-fname
{&create-record}
&scop attr-code trdcattr-t_pass-position
{&create-record}
&scop attr-code trdcattr-t_accept-fname
{&create-record}
&scop attr-code trdcattr-t_accept-position
{&create-record}
&scop attr-code trdcattr-ndovwho
{&create-record}
&scop attr-code trdcattr-nosn
{&create-record}
&scop attr-code trdcattr-shipper
{&create-record}
&scop attr-code trdcattr-othermoves
{&create-record}
if v-is-pharm = "yes":U then do:
  &scop attr-code trdcattr-ser_on_pack
  {&create-record}
end.


end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE inv-line_price d-in-doc
PROCEDURE inv-line_price :
define  input parameter p-doc-line-rec as   recid                  no-undo.
  define  input parameter p-print-rubl   as   logical                no-undo.
  define output parameter p-out-price-kg like ub.doc-line.price-rubl no-undo initial 0.0.

  define variable p-inv-line-rec as recid   no-undo.
  define variable is-petrol      as logical no-undo.
  define variable is-pieces      as logical no-undo.

  define buffer buf_inv-line for ub.inv-line.
  define buffer buf_doc-line for ub.doc-line.

  do on error undo, return error return-value :
    find buf_doc-line       no-lock where recid( buf_doc-line ) = p-doc-line-rec no-error.
    if not available buf_doc-line then do:
      assign p-out-price-kg = ?.
      undo, return error "inv-line_price: не найдена строка накладной".
    end.
    { str/is-petrl.i
        buf_doc-line.artic
        buf_doc-line.prod-type
        buf_doc-line.prod-code
        is-petrol
        is-pieces
        no-error
    }
    if error-status :error or v-is-ptrl <> "yes" or is-petrol <> yes or is-pieces <> no then do:
      undo, return error substitute( 'inv-line_price: &1 (произв. &2 &3) не топливный товар',
                                     buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code ).
    end.

    find buf_inv-line no-lock where
         buf_inv-line.doc-code  = buf_doc-line.doc-code  and
         buf_inv-line.artic     = buf_doc-line.artic     and
         buf_inv-line.prod-code = buf_doc-line.prod-code and
         buf_inv-line.prod-type = buf_doc-line.prod-type no-error.
    if available buf_inv-line then do:
      assign
        p-inv-line-rec = recid( buf_inv-line )
      .
      find buf_doc-line exclusive-lock where recid( buf_doc-line ) = p-doc-line-rec.
      find buf_inv-line exclusive-lock where recid( buf_inv-line ) = p-inv-line-rec.
      assign
        p-out-price-kg = ( if p-print-rubl = yes then buf_inv-line.wast-rubl else buf_inv-line.wast-base )
      .
      find buf_inv-line        no-lock where recid( buf_inv-line ) = p-inv-line-rec.
      find buf_doc-line        no-lock where recid( buf_doc-line ) = p-doc-line-rec.

      release buf_inv-line.
      release buf_doc-line.
    end. /* if available buf_inv-line */
  end. /* on error */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE inv-line_qnty d-in-doc
PROCEDURE inv-line_qnty :
define  input parameter p-doc-line-rec as   recid                 no-undo.
  define output parameter p-out-qnty-kg  like ub.doc-line.fact-qnty no-undo initial 0.0.

  define variable is-petrol as logical no-undo.
  define variable is-pieces as logical no-undo.

  define buffer buf_inv-line for ub.inv-line.
  define buffer buf_doc-line for ub.doc-line.

  do on error undo, return error return-value :
    find buf_doc-line no-lock where recid( buf_doc-line ) = p-doc-line-rec no-error.
    if not available buf_doc-line then do:
      assign p-out-qnty-kg = ?.
      undo, return error "inv-line_qnty: не найдена строка накладной".
    end.
    { str/is-petrl.i buf_doc-line.artic
                 buf_doc-line.prod-type
                 buf_doc-line.prod-code
                 is-petrol
                 is-pieces              no-error }
    if error-status :error or v-is-ptrl <> "yes" or is-petrol <> yes or is-pieces <> no then do:
      undo, return error substitute( 'inv-line_qnty: &1 (произв. &2 &3) не топливный товар',
                                     buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code ).
    end.
    find buf_inv-line no-lock where
         buf_inv-line.doc-code  = buf_doc-line.doc-code  and
         buf_inv-line.artic     = buf_doc-line.artic     and
         buf_inv-line.prod-code = buf_doc-line.prod-code and
         buf_inv-line.prod-type = buf_doc-line.prod-type no-error.
    if available buf_inv-line then do: assign p-out-qnty-kg = buf_inv-line.wast-cli-qnty. end.
  end. /* on error */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE live-loc d-in-doc
PROCEDURE live-loc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable to-date as date no-undo.
  { gbl/objdtget.i t-doc.obj-type t-doc.obj-code to-date no-error}
  if error-status :error then do:
    assign to-date = today.
  end.
  find first supplier no-lock where
             supplier.obj-code = t-doc.cli-code and
             supplier.obj-type = t-doc.cli-type no-error .

  run rep/vs-part1.w (
      input parparentproc,
      input v-cntxt-obj-type,
      input v-cntxt-obj-code,
      input t-doc.doc-date,
      input to-date,
      input {&all},
      input t-doc.doc-code)
      .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-add-doc d-in-doc
PROCEDURE local-add-doc :
/*------------------------------------------------------------------------------
  Purpose:     Документ дополнительных расходов
  Parameters:  <none>
  Notes: 8888
------------------------------------------------------------------------------*/
define buffer buf_add-doc for ub.add-doc .
define buffer buf_add-trn for ub.add-trn .

define variable v-recid as recid no-undo .
define variable v-mode as character no-undo .
define variable v-doc-code-add as character no-undo .
define variable v-today as date  no-undo .
define variable v-m as character no-undo .
define variable v-new as logical   no-undo .
v-m =  {&lookup} .
v-new = false  .
if pardoc-mode = {&lookup} then v-mode = pardoc-mode .
                           else v-mode = {&update} .

find first buf_add-trn no-lock where buf_add-trn.trn-doc-code =  t-doc.doc-code no-error .

if not available buf_add-trn then do:
   if v-mode = {&lookup} then return .

    define variable obj-db-num as integer   no-undo .
       { gbl/objdbnum.i
         v-cntxt-obj-type
         v-cntxt-obj-code
         obj-db-num
         }
         if obj-db-num <> v-cntxt-db-num then do:
            message 'Создание ДопРасхода  только на активной стороне' view-as alert-box information .
            return .
         end.

   message 'Создавать новый документ дополнительных расходов ?'
            view-as alert-box question
            buttons yes-no
            update v-ok as logical
            .
   if v-ok = false then return .
   { gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code v-today }
   v-new = true .
   run doc-code in this-procedure
     ( input "main":U
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input ?
      ,output v-doc-code-add
     ) no-error.
  if error-status :error then do:
    message
      "Ошибка при генерации номера документа."
      view-as alert-box error.
    return error.
  end.
   create ub.add-doc.
   assign
     ub.add-doc.doc-code   = v-doc-code-add
     ub.add-doc.base-rate  = t-doc.base-rate
     ub.add-doc.base-scale = t-doc.base-scale
     ub.add-doc.cr-db-num  = v-cntxt-db-num
     ub.add-doc.doc-date   = v-today
     ub.add-doc.exch-code  = if t-doc.exch-code = ?  then 0 else t-doc.exch-code
     ub.add-doc.exch-date  = v-today
     ub.add-doc.exch-rate  = if t-doc.exch-rate = ? or t-doc.exch-rate = 0 then 1 else t-doc.exch-rate
     ub.add-doc.exch-scale = if t-doc.exch-scale = ? or t-doc.exch-scale = 0 then 1 else t-doc.exch-scale
     ub.add-doc.host-code  = v-cntxt-host-code-obj
     ub.add-doc.obj-code   = v-cntxt-obj-code
     ub.add-doc.obj-type   = v-cntxt-obj-type
     ub.add-doc.status_    = {&g___new}
     ub.add-doc.VAT-type   = t-doc.VAT-type
   .
   create buf_add-trn .
   assign
     buf_add-trn.doc-code = v-doc-code-add
     buf_add-trn.trn-doc-code = t-doc.doc-code
   .
end.
else do:
   v-doc-code-add = buf_add-trn.doc-code .
end.

find first buf_add-doc exclusive-lock where
           buf_add-doc.doc-code = v-doc-code-add
           no-error .
if available buf_add-doc then do:
    v-recid = recid (buf_add-doc) .
    v-m = if buf_add-doc.status_ <> {&g___new} then {&lookup} else ( if pardoc-mode = {&add-def} then {&update} else pardoc-mode )  .

    run str/add-docu.w
      ( input parparentproc ,
        input-output  v-recid ,
        input v-m ,
        input t-doc.doc-code
        ).
  if v-new = true and v-recid = ? then do:
      find first buf_add-doc exclusive-lock where
                buf_add-doc.doc-code = v-doc-code-add no-error .
     delete buf_add-doc .
  end.
end.
release buf_add-doc .
if can-find (first ub.add-trn no-lock where
                      ub.add-trn.doc-code      = v-doc-code-add  and
                      ub.add-trn.trn-doc-code  = t-doc.doc-code )
                      then do:
    enable b-add-doc-yes with frame {&frame-name} .
    display b-add-doc-yes with frame {&frame-name} .
end.
else hide b-add-doc-yes in frame {&frame-name} .

/* Предлагаю закрыть документ ДопРасхода */

if v-m = {&lookup} then return .

find first buf_add-doc no-lock where
           buf_add-doc.doc-code = v-doc-code-add no-error .
if not available buf_add-doc then return .

if buf_add-doc.status_  = {&g___new}
then do:
   if can-find (first ub.add-line no-lock where
                      ub.add-line.doc-code  = buf_add-doc.doc-code ) and
      can-find (first ub.add-trn no-lock where
                      ub.add-trn.doc-code      = buf_add-doc.doc-code  and
                      ub.add-trn.trn-doc-code  = t-doc.doc-code )
                      then do:
     message
      substitute("Закрыть  ДопРасх № &1 до статуса ЗАКРЫТО ? " ,buf_add-doc.doc-code  )
      view-as alert-box question
      buttons yes-no
      update vok as log
     .
     if vok = false then return .

        run str/addclos.p
            ( input Parparentproc,
              recid(buf_add-doc)
            ) .
         end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-arh d-in-doc
PROCEDURE local-arh :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  run str/docsuppn.w
    (input  parparentproc
    ,input  recid(t-doc)
    ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-bc d-in-doc
PROCEDURE local-bc :
if t-doc.status_ = {&wayb} and
    t-doc.flag_   = no      then do:
    run add-bc in this-procedure no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if t-doc.status_ = {&wayb} and
    t-doc.flag_   = yes     then do:
    run fact-bc in this-procedure ( input t-doc.doc-code ) no-error.
    if error-status :error then do: return no-apply. end.
    {&OPEN-QUERY-{&browse-name}-default}
    display t-doc.fact-qnty with frame {&frame-name}.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-conf-rd d-in-doc
PROCEDURE local-conf-rd :
do on error undo, return error return-value :
{ gbl/conf-rd.i  "'is-custm'"  0  "''"  0 "''" "''" "''"                              no  custvalue        custtype}
{ gbl/conf-rd.i  "'is-prt'"    0  "''"  0 "''" "''" "''"                              yes prtvalue         prttype}
{ gbl/conf-rd.i  "'holding'"   0  "''"  0 "''" "''" "''"                              no  varhold          varhold-type}
{ gbl/conf-rd.i  "'tpsi'"      0             "''"         0         "''"  "''"  "''"  no  vartpsi       vartpsi-type }
{ gbl/conf-rd.i  "'is-tsd'"    0             "''"         0         "''"  "''"  "''"  no  v-is-tsd     v-is-tsd-type }
{ gbl/conf-rd.i  "'is-pharm'" v-cntxt-host-code-obj v-cntxt-obj-type v-cntxt-obj-code "''" "''" "''"  no  v-is-pharm       v-is-pharm-type no-error}.

if v-is-pharm <> "yes" then v-is-pharm = "no" .
else do:
    { str/opharm.i v-cntxt-obj-type v-cntxt-obj-code v-is-pharm }
end.

{ gbl/getsect.i run v-cntxt-obj-type v-cntxt-obj-code {&attr-nakl_par} }
varvat-type-int = 1 .
varslt-type-int = 3 .
v-not-ord = false .
v-back-date = false .
var-inp_sum  = false .

for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'type-vat' then varvat-type-int = thbjattr_thbj-attr.property-value-integer .
    if thbjattr_thbj-attr.prop-code = 'type-slt' then varslt-type-int = thbjattr_thbj-attr.property-value-integer .
    if thbjattr_thbj-attr.prop-code = 'inp_sum'  then var-inp_sum     = thbjattr_thbj-attr.property-value-logical .
    if thbjattr_thbj-attr.prop-code = 'not-ord'  then v-not-ord       = thbjattr_thbj-attr.property-value-logical .
    if thbjattr_thbj-attr.prop-code = 'back-date' then v-back-date    = thbjattr_thbj-attr.property-value-logical .
    if thbjattr_thbj-attr.prop-code = 'inv-ship' then  inv-shipvalue  = thbjattr_thbj-attr.property-value-logical .
end.
{ gbl/getsect.i run "''" 0 {&attr-nakl-glob} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'convimp'  then convimpvalue  = string (thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'is-ov'    then is-ovvalue    = string (thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'is-bcdoc' then bcvalue       = string (thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'multdtyp' then multdtypvalue = string (thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'curcli'   then curclivalue   = string (thbjattr_thbj-attr.property-value-logical) .
end.

empty temp-table thbjattr_thbj-attr.

if pardoc-mode = {&add-def} then do:
    if v-not-ord = true then do:
      message "Запрещено заводить ПН вручную !" view-as alert-box information .
      return error.
    end.
end.

case varvat-type-int:
when 1 or when ? then do:
  assign
    varvat-type-def = {&inc-vat}.
end.
when 2 then do:
  assign
    varvat-type-def = {&no-vat}.
end.
when 3 then do:
  assign
    varvat-type-def = {&without-vat}.
end.
otherwise do:
  message "Не верно задан атрибут 'Тип заведения НДС' (type-vat)."
          "Задано значение: " varvat-type-int
          "Допустимые значения: 1,2,3."
  view-as alert-box error.
  return error.
end.
end case.
case varslt-type-int:
when 1 then do:
  assign
    varslt-type-def = {&inc-slt}.
end.
when 2 then do:
  assign
    varslt-type-def = {&no-slt}.
end.
when 3 or when ? then do:
  assign
    varslt-type-def = {&without-slt}.
end.
otherwise do:
  message "Не верно задан атрибут 'Тип заведения НП' (type-slt)."
          "Задано значение: " varslt-type-int
          "Допустимые значения: 1,2,3."
  view-as alert-box error.
  return error.
end.
end case.
assign
  rdtaxcdvalue  = {&road-tax-code}
  vattaxcdvalue = {&vat-tax-code}
  exctaxcdvalue = {&excise-tax-code}.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-lockup d-in-doc
PROCEDURE local-lockup :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable varext-cycle as logical no-undo.
if not available  ub.doc-line then do:
  message "Неправильно выбрана строка.".
  return error.
end.

find ub.goods where ub.goods.artic     =  ub.doc-line.artic and
                 ub.goods.prod-type =  ub.doc-line.prod-type and
                 ub.goods.prod-code =  ub.doc-line.prod-code no-lock.
gds-rec = RECID(ub.goods).
pardoc-rec = RECID(t-doc).
assign
  line-rec = recid ( ub.doc-line)
  varlns-cnt = 1.
run str/in-line.w ( input  parparentproc,
                    input  {&lookup},
                    input  pardoc-rec,
                    input-output  line-rec,
                    input  gds-rec,
                    input  varlns-cnt,
                    output varext-cycle,
                    input 0,
                    input ?, input varinplnsum ) no-error.
FIND t-doc WHERE RECID(t-doc) = pardoc-rec.
apply "entry" to {&browse-name} in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-m-outs-5 d-in-doc
PROCEDURE local-m-outs-5 :
define buffer   bf_trn-doc for ub.trn-doc.

  define variable vardoc-code like ub.trn-doc.doc-code no-undo.

  if (t-doc.status_ = {&wayb} or t-doc.status_ = {&inquiry}) and
      not t-doc.flag_
  then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_income_import':U
      {&cntxt-object}
      t-doc.host-code
      t-doc.obj-type
      t-doc.obj-code
      0
      0
      0
      true
      varlog
    }
    assign vardoc-code = "import-" + t-doc.doc-code.
    run utl/imp-allc.p ( input parparentproc,
                     input 2,
                     input ?,
                     input ?,
                     input t-doc.exch-code,
                     input vardoc-code,
                     input t-doc.cli-type,
                     input t-doc.cli-code,
                     input t-doc.host-code  ) no-error.
    if error-status :error then do:
      message "Ошибка при конвертации и формировании файла import." view-as alert-box error.
      return error.
    end.
    run disp-import in this-procedure ( input vardoc-code ) no-error.
    find first bf_trn-doc where bf_trn-doc.doc-code = vardoc-code.
    delete bf_trn-doc.
  end.
  else do:
    message "Данное действие недопустимо в статусе: "
            t-doc.status_ string( t-doc.flag_, "+/-":U ) "."
    view-as alert-box error.
    return error.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-mark d-in-doc
PROCEDURE local-mark :
if not available  ub.doc-line then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
  { gbl/markstrn.i  ub.doc-line del-list }
  {&browse-name}:refresh() in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-row-leave d-in-doc
PROCEDURE local-row-leave :
define variable var_is-petrol as logical no-undo .
  define variable var_is-pieces as logical no-undo .

if available  ub.doc-line then do:
  { str/is-petrl.i
       ub.doc-line.artic
       ub.doc-line.prod-type
       ub.doc-line.prod-code
      var_is-petrol
      var_is-pieces
      no-error
  }
  if error-status :error
  then do:
    return .
  end.
  if var_is-petrol = yes and
     var_is-pieces = no
  then do:
    if decimal(  ub.doc-line.cli-qnty :screen-value in browse {&browse-name} ) <>  ub.doc-line.cli-qnty
    then do:
      display  ub.doc-line.cli-qnty with browse {&browse-name} .
      message substitute( 'В жидком топливе нельзя редактировать количество.&1'
                        , ( if b-chg :sensitive in frame {&frame-name}
                            then substitute( '&1Воспользуйтесь кнопкой "&2".'
                                           , {&new-line}
                                           , replace( b-chg :label in frame {&frame-name}, "&", "":U )
                                           )
                            else '':U )
                        )
      view-as alert-box error .
    end.
    else
    if decimal(  ub.doc-line.fact-qnty :screen-value in browse {&browse-name} ) <>  ub.doc-line.fact-qnty
    then do:
      display  ub.doc-line.fact-qnty with browse {&browse-name} .
      message substitute( 'В жидком топливе нельзя редактировать фактическое количество.&1'
                        , ( if b-chg :sensitive in frame {&frame-name}
                            then substitute( '&1Воспользуйтесь кнопкой "&2".'
                                           , {&new-line}
                                           , replace( b-chg :label in frame {&frame-name}, "&", "":U )
                                           )
                            else '':U )
                        )
      view-as alert-box error .
    end.
    return .
  end.

  define variable v-gds-code as integer   no-undo .
  define variable v-update-ok   as logical   no-undo .
  define variable v-err-message as character no-undo .
  { gbl/doclicod.i
    recid(ub.doc-line)
    v-gds-code
  }
  v-fact-qnty = ub.doc-line.fact-qnty:screen-value in browse {&browse-name}.
  if dec ( ub.doc-line.cli-qnty:screen-value in browse {&browse-name}) <>  ub.doc-line.cli-qnty then do:
    if v-edit-fact-wayb and not t-doc.flag_ and dec (ub.doc-line.cli-qnty:screen-value in browse {&browse-name}) <> ub.doc-line.cli-qnty
    then do:
      if v-edit-fact-wayb and not t-doc.flag_
      then do:
        ub.doc-line.fact-qnty:screen-value in browse {&browse-name} = string (ub.doc-line.cli-base-rate * ub.doc-line.cli-qnty).
        t-doc.flag_ = true.
        run str/doclinfq.p
          (input  parparentproc
          ,buffer t-doc
          ,buffer  ub.doc-line
          ,input  decimal( ub.doc-line.fact-qnty:screen-value in browse {&browse-name})
          ,output v-update-ok
          ,output v-err-message
          ) no-error .
        if error-status :error
        or v-update-ok = false
        then do:
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры doclinfq.p" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
          end.
          else do:
            message
              v-err-message
              view-as alert-box information .
          end.
          display
             ub.doc-line.fact-qnty
            with browse {&browse-name} .
          t-doc.flag_ = false.
          return.
        end.
        t-doc.flag_ = false.
         
      end.
    end.
    run upd-cli-qnty in this-procedure no-error.
    if error-status :error then 
    do:
      display  ub.doc-line.cli-qnty with browse {&browse-name}.
      return.
    end.
  end.
  if dec ( v-fact-qnty ) <>  ub.doc-line.fact-qnty then do:
    run str/doclinfq.p
      (input  parparentproc
      ,buffer t-doc
      ,buffer  ub.doc-line
      ,input  decimal( ub.doc-line.fact-qnty:screen-value in browse {&browse-name})
      ,output v-update-ok
      ,output v-err-message
      ) no-error .
    if error-status :error
    or v-update-ok = false
    then do:
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры doclinfq.p" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      else do:
        message
          v-err-message
          view-as alert-box information .
      end.
      display
         ub.doc-line.fact-qnty
        with browse {&browse-name} .
      return.
    end.
    if v-edit-fact-wayb and not t-doc.flag_
    then do:
      t-doc.flag_ = true.
      ub.doc-line.fact-qnty:screen-value in browse {&browse-name} = v-fact-qnty.
      run str/doclinfq.p
        (input  parparentproc
        ,buffer t-doc
        ,buffer  ub.doc-line
        ,input  decimal( ub.doc-line.fact-qnty:screen-value in browse {&browse-name})
        ,output v-update-ok
        ,output v-err-message
        ) no-error .
      if error-status :error
      or v-update-ok = false
      then do:
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры doclinfq.p" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
        else do:
          message
            v-err-message
            view-as alert-box information .
        end.
        display
           ub.doc-line.fact-qnty
          with browse {&browse-name} .
        t-doc.flag_ = false.
        return.
      end.
      t-doc.flag_ = false.
    end.
    
    do
    on error undo, return error return-value
    :
      define buffer buf_doc-line for ub.doc-line .

      find first buf_doc-line exclusive-lock where
          recid( buf_doc-line ) = recid(  ub.doc-line ) .
      assign
        buf_doc-line.fact-qnty = decimal(  ub.doc-line.fact-qnty :screen-value in browse {&browse-name} )
      .
      find first buf_doc-line        no-lock where
          recid( buf_doc-line ) = recid(  ub.doc-line ) .
    end. /* transaction */
    run ui-on in this-procedure
      ( input "line"
      ) .
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-upd-inplnsum d-in-doc
PROCEDURE local-upd-inplnsum :
do on error undo, return error return-value :
if input frame {&frame-name} varinplnsum <> varinplnsum then do:
  if input frame {&frame-name} varinplnsum = yes then do:
    { str/tdat-wrt.i
        t-doc.doc-code
        {&trdcattr-indoclnsum}
        "'yes'"
        no-error
    }
    if error-status :error then do:
      message "Ошибка при изменении атрибута " {&trdcattr-indoclnsum} " в документе " t-doc.doc-code " ." skip
              error-status:get-message(1) skip
              return-value
      view-as alert-box error.
      undo, return error.
    end.
  end.
  else do:
    { str/tdat-wrt.i
        t-doc.doc-code
        {&trdcattr-indoclnsum}
        "'no'"
        no-error
    }
    if error-status :error then do:
      message "Ошибка при изменении атрибута " {&trdcattr-indoclnsum} " в документе " t-doc.doc-code " ." skip
              error-status:get-message(1) skip
              return-value
      view-as alert-box error.
      undo, return error.
    end.
  end.
  assign frame {&frame-name}
    varinplnsum.
end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-upd-m-inc d-in-doc
PROCEDURE local-upd-m-inc :
do on error undo, return error return-value :
    if input frame {&frame-name} m-inc <> m-inc then do:
      define variable v-temp as character no-undo .

      assign v-temp = input frame {&frame-name} m-inc .
      { str/tdat-wrt.i
          t-doc.doc-code
          {&trdcattr-m-inc}
          v-temp
          no-error
      }
      if error-status :error then do:
        message "Ошибка при изменении атрибута " {&trdcattr-m-inc} " в документе " t-doc.doc-code " ." skip
                error-status :get-message( 1 ) skip
                return-value
        view-as alert-box error.
        undo, return error.
      end.
      assign frame {&frame-name}
        m-inc.
    end.

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE out-doc-rec d-in-doc
PROCEDURE out-doc-rec :

  run fnd-an-doc in this-procedure no-error.
  if error-status :error then do:
     run proc-m-outs-1 in this-procedure.
  end.
  else do:
      run fill-tt in this-procedure ( input t-d-b.doc-code ) no-error.
      if error-status :error then  return error return-value.
      run ask-copy in this-procedure no-error .
      if error-status :error then return error return-value .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ov-pc d-in-doc
PROCEDURE ov-pc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer d-l-b for  ub.doc-line.
define buffer ov-goods for ub.goods.
define buffer ov-units for ub.units.

define variable v-ov-pc as decimal no-undo .

if input frame {&frame-name} ov-pc <> 0 then do:
   run check-update in this-procedure no-error.
   if error-status :error then do: return error. end.
 end.
assign
  v-ov-pc = input frame {&frame-name} ov-pc.
if v-ov-pc <> 0  then do:
  if v-ov-pc <= -100 then do:
    message
      "Вы ввели недопустимый процент скидки" v-ov-pc skip
      "Он не может быть меньше чем -100%" skip
      view-as alert-box error .
    return error .
  end.

  def var v-num             as integer no-undo .
  def var l-selection-exist as logical no-undo .
  assign
   l-selection-exist = (del-list <> "")
  .

  run gbl/d-askw.w
    (input "Вопрос"
    ,input "Пересчитать накладную по наценке/скидке на цену поставщика?" + {&new-line}
        + (if v-ov-pc > 0
           then "Наценка: "
           else "Скидка: ")
        + string(abs(v-ov-pc)) + {&new-line}
      + (if l-selection-exist then "Выбрано строк: " + string(num-entries(del-list)) + {&new-line} else "" )
      + "Расчет производится по формуле:" + {&new-line}
      + (if v-ov-pc > 0
         then "Новая цена = Старая цена * (1 + Наценка/ 100)" + {&new-line}
         else "Новая цена = Старая цена * (1 - Скидка/ 100)" + {&new-line}
        )
    ,input "|^"
    ,input "Все|"
         + "Выбранные" + (if l-selection-exist then "" else "^disable") + "|"
         + "Не выбранные" + (if l-selection-exist then "" else "^disable") + "|"
         + "Отмена"
    ,input "Все строки документа.|"
        + "Все отмеченные строки. Кнопка доступна при наличии выбранных строк.|"
        + "Все неотмеченные строки. Кнопка доступна при наличии выбранных строк.|"
        + "Ничего не пересчитывать."
    ,input 1
    ,input 4
    ,output v-num
    ).

  if v-num = 4 then do:
    return . /* --->>>--- */
  end.

  tr:
  do transaction
  on error   undo tr, return error return-value
  :
    run waitfram-show in this-procedure ( input "Расчет новых цен. Ждите..." ).
    for each d-l-b
      where d-l-b.doc-code = t-doc.doc-code
    on error undo tr, return error
    :
      if (v-num = 1) /* все строки */
      or (v-num = 2  /* все выбранные строки */
          and     can-do(del-list, string(recid(d-l-b)))
         )
      or (v-num = 3  /* все кроме выбранных строк */
          and not can-do(del-list, string(recid(d-l-b)))
         )
      then do:
        find first ov-goods where ov-goods.artic     = d-l-b.artic     and
                                  ov-goods.prod-type = d-l-b.prod-type and
                                  ov-goods.prod-code = d-l-b.prod-code no-lock.
        find ov-units where ov-units.unit-name    = ov-goods.unit-base no-lock.
        if lookup({&twounit}, ov-units.type) = 0 then
        assign
          d-l-b.price-cli = d-l-b.price-cli * (1 + v-ov-pc / 100) no-error.
        else
        assign
          d-l-b.price-rubl = d-l-b.price-rubl * (1 + v-ov-pc / 100) no-error.

        if error-status :error then do:
          run waitfram-hide in this-procedure .
          undo tr, return error .
        end.
        { str/in-vat.i
          t-doc.doc-code
          t-doc.base-rate
          t-doc.base-scale
          t-doc.exch-rate
          t-doc.exch-scale
          t-doc.vat-type
          t-doc.slt-type
          d-l-b.artic
          d-l-b.prod-type
          d-l-b.prod-code
          d-l-b.price-cli
          d-l-b.cli-base-rate
          d-l-b.price-rubl
          d-l-b.vat-pc
          d-l-b.slt-pc
          d-l-b.road-tax
          d-l-b.transport-rubl
          d-l-b.other-rubl
          varprice-cli
          varprice-cli-unit-base
          varprice-road-tax
          varprice-other-exp
          varprice-transport-exp
          varprice-without-abs
          varprice-slt
          varprice-no-slt
          varprice-vat
          varprice-no-vat-slt
          varprice-rubl
          varprice-road-tax-rubl
          varprice-other-exp-rubl
          varprice-transport-exp-rubl
          varprice-without-abs-rubl
          varprice-slt-rubl
          varprice-no-slt-rubl
          varprice-vat-rubl
          varprice-no-vat-slt-rubl
          varprice-base
          varprice-road-tax-base
          varprice-other-exp-base
          varprice-transport-exp-base
          varprice-without-abs-base
          varprice-slt-base
          varprice-no-slt-base
          varprice-vat-base
          varprice-no-vat-slt-base
          no-error
        }
        if error-status :error then do:
          return error "Ошибка при пересчете линии документа".
        end.
        assign d-l-b.price-cli  = varprice-cli
               d-l-b.price-rubl = varprice-rubl
               d-l-b.price-base = varprice-base.
      end.
    end.
    run waitfram-show in this-procedure ( input "Проверка документа. Ждите..." ).
    run check-rate in this-procedure no-error .
    if error-status :error then do:
      run waitfram-hide in this-procedure .
      undo tr, return error .
    end.
    run waitfram-show in this-procedure ( input "Перерасчет документа в соответствии с новыми ценами. Ждите..." ).
    run gbl/calc-trn.p (input parparentproc, input recid( t-doc ) ) no-error.
    if error-status :error then do:
      message "Ошибка при пересчете документа." view-as alert-box error.
      run waitfram-hide in this-procedure .
      undo tr, return error .
    end.
  end.
  run waitfram-hide in this-procedure .
  run UI-on in this-procedure ( input "line" ).
  return .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE prev-cor-line d-in-doc
PROCEDURE prev-cor-line :
define input  parameter parunits-type like ub.units.type no-undo.
define input  parameter p-obj-type    like ub.clients.obj-type no-undo .
define input  parameter p-obj-code    like ub.clients.obj-code no-undo .
define input  parameter p-artic       like ub.goods.artic no-undo .
define input  parameter p-prod-type   like ub.goods.prod-type no-undo .
define input  parameter p-prod-code   like ub.goods.prod-code no-undo .

define variable v-insalepr as logical   no-undo .
/*При заведении товара, через две единицы измерения или через продажную цену,
      кол-во по ТТН влияет на цену по ТТН, поэтому пока не обрабатываем*/
{ gbl/gdsobjat.i
  p-obj-type
  p-obj-code
  p-artic
  p-prod-type
  p-prod-code
  "'insalepr=request'":U
  v-insalepr
}
if v-insalepr = true then
   return error "Товар принимается по продажной цене. Изменение кол-ва допустимо лишь по кнопке <<Изм>>.".
if lookup({&twounit}, parunits-type) > 0  then
   return error "Товар c двумя единицами измерения. Изменение кол-ва допустимо лишь по кнопке <<Изм>>.".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-m-outs-1 d-in-doc
PROCEDURE proc-m-outs-1 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable loc-ref-list as character no-undo .
/*Не убирать. Иначе не обновляются поля в updateble browse*/
apply "row-leave" to browse {&browse-name}.
do on error undo, return error return-value :
if not ((t-doc.status_ = {&wayb} or t-doc.status_ = {&inquiry}) and not t-doc.flag_) then do:
  return error "Данное действие недопустимо в этом статусе.".
end.
if not b-add:sensitive in frame {&frame-name} then do:
  message "Добавление строк из другого документа при этом статусе невозможно.".
  return error.
end.
/* Список документов по объекту */
run str/all-docs.w
  (  input parparentproc,
      input t-doc.host-code ,
      input t-doc.obj-type ,
      input t-doc.obj-code ,
      input {&choose},
      input ?,
      input ?,
      input ?,
      input ?,
      input "b-sel":U,
      input ?,
      input ?,
      input ?,
      output loc-ref-list ).
find t-d-b where recid (t-d-b) = integer (loc-ref-list) no-lock no-error.
if not available t-d-b then do:
  display ? @ t-doc.out-code with frame {&frame-name}.
  apply "entry" to b-add in frame {&frame-name}.
  return error.
end.
display t-d-b.doc-code @ t-doc.out-code with frame {&frame-name}.
run fill-tt in this-procedure ( input t-d-b.doc-code ) no-error.
   if error-status :error then  return error return-value.
run ask-copy in this-procedure no-error .
   if error-status :error then  return error return-value.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-m-outs-2 d-in-doc
PROCEDURE proc-m-outs-2 :
/*Не убирать. Иначе не обновляются поля в updateble browse*/
APPLY "row-leave" to BROWSE {&browse-name}.
do transaction on error   undo, return error:
/* Мобильный сканер */
if b-add:sensitive in frame {&frame-name} then do:
  run check-exch in this-procedure.
  if not can-find (first  ub.doc-line where  ub.doc-line.doc-code = t-doc.doc-code no-lock) then do:
    run check-rate in this-procedure.
   end.
end.
if pardoc-mode = {&update} then do:
  run prescan in this-procedure ( input recid( t-doc ) ) no-error.
  if error-status :error then do:
    message "Ошибка при установке фактического количества перед сканированием." skip
            return-value
    view-as alert-box error.
    undo, return error.
  end.
end.
run str/scan.p ( parParentproc, input b-add :sensitive , input recid(t-doc) , input ? ).
/* Приходится пересчитывать все так как могут быть обнулены fact-qnty в накл+ */
run gbl/calc-trn.p ( input parparentproc, input recid( t-doc ) ) no-error.
if error-status :error then do:
  return error return-value.
end.
run UI-on in this-procedure ( input "line" ).
end. /* transaction */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-m-outs-4 d-in-doc
PROCEDURE proc-m-outs-4 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer bf_trn-doc for ub.trn-doc.

define variable vardoc-code like ub.trn-doc.doc-code no-undo.

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_income_import':U
  {&cntxt-object}
  t-doc.host-code
  t-doc.obj-type
  t-doc.obj-code
  0
  0
  0
  true
  varlog
}

assign vardoc-code = "import-" + t-doc.doc-code.
do transaction:
run utl/imp-all.p (parparentproc, 2, ?, ?, t-doc.exch-code, vardoc-code, t-doc.cli-type, t-doc.cli-code, t-doc.host-code) no-error .
if error-status :error then do:
   message "Ошибка при формировании файла import." view-as alert-box error.
   return error.
end.
run disp-import in this-procedure ( input vardoc-code ) no-error.
find first bf_trn-doc where bf_trn-doc.doc-code = vardoc-code.

/* Вставить удаление ДОКУМЕНТА !!!! */
if available bf_trn-doc then do:
   for each ub.parts exclusive-lock where
    ub.parts.out-code = bf_trn-doc.doc-code:
    delete ub.parts.
   end.
  delete bf_trn-doc.
end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-m-outs-6 d-in-doc
PROCEDURE proc-m-outs-6 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer bf_trn-doc for ub.trn-doc.
define variable vardoc-code like ub.trn-doc.doc-code no-undo.

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_income_import':U
  {&cntxt-object}
  t-doc.host-code
  t-doc.obj-type
  t-doc.obj-code
  0
  0
  0
  true
  varlog
}
assign vardoc-code = "import-" + t-doc.doc-code.
do transaction:
run str/imp-art.p (parparentproc, 2, ?, ?, t-doc.exch-code, vardoc-code, t-doc.cli-type, t-doc.cli-code, t-doc.host-code) no-error .
if error-status :error then do:
   message "Ошибка при формировании файла import." view-as alert-box error.
   return error.
end.
run disp-import in this-procedure (input vardoc-code) no-error.
find first bf_trn-doc where bf_trn-doc.doc-code = vardoc-code.
delete bf_trn-doc.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-m-outs-7 d-in-doc 
PROCEDURE proc-m-outs-7 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer bf_trn-doc for ub.trn-doc.
define buffer bf_doc-line for ub.doc-line .
define buffer bf_goods for ub.goods .
define variable vardoc-code like ub.trn-doc.doc-code no-undo.
define variable par-alcohol as character no-undo .
define variable par-mark as character no-undo .
define variable par-type as character no-undo .
define variable v-is-alc as logical no-undo .
define variable v-mark-alchol     as logical no-undo .
define variable v-type as character no-undo .

delete object v-tth no-error.
run adm/shattri.p (
   input "get":U
  ,input t-doc.obj-type
  ,input t-doc.obj-code
  ,input {&attr-nakl_par}
  ,input  "mark-alchol"
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-mark-alchol
  ,output v-type
  ,INPUT-OUTPUT table-handle v-tth
  ) no-error .
  delete object v-tth no-error.
if error-status:error then do:
  message "Ошибка при получение параметра mark-alchol"
  view-as alert-box.
  return error.
end.
if not v-mark-alchol
then do :
    message "В системе не включен помарочный учёт. Импорт акцизных марок невозможен." view-as alert-box .
    return.
end.

v-is-alc = false .
for each bf_doc-line no-lock where bf_doc-line.doc-code = t-doc.doc-code :
    find first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic
                                  and bf_goods.prod-type = bf_doc-line.prod-type
                                  and bf_goods.prod-code = bf_doc-line.prod-code
                                  no-error .
                                      
    run gds-attr-value(
      bf_goods.gds-code,
      {&attr-alcohol-prod},
      output par-alcohol,
      output par-type
    ).
    if par-alcohol = "" or par-alcohol = "no" then next .
    run gds-attr-value(
      bf_goods.gds-code,
      {&attr-mark},
      output par-mark,
      output par-type
    ).
    if par-mark = "" or par-mark = "no" then next .
    v-is-alc = true .
end.

if not v-is-alc
then do :
    message "В накладной нет ни одного товара, подлежащего маркировке. Импорт акцизных марок не возможен" view-as alert-box.
    return .
end.

do transaction:
    run str/imp-marks.p (parparentproc, t-doc.doc-code, "in") .    
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-shift-num d-in-doc 
PROCEDURE proc-shift-num :
define buffer bf_shift-obj   for ub.shift-obj.
  if input frame {&frame-name} t-doc.shift-num <> t-doc.shift-num then do:
    if input frame {&frame-name} t-doc.shift-date <> ? then do:
      find first bf_shift-obj where bf_shift-obj.obj-type   = t-doc.obj-type                             and
                                    bf_shift-obj.obj-code   = t-doc.obj-code                             and
                                    bf_shift-obj.shift-date = input frame {&frame-name} t-doc.shift-date and
                                    bf_shift-obj.shift-num  = input frame {&frame-name} t-doc.shift-num  no-lock no-error.
      if not available bf_shift-obj then do:
        message "Не найдена смена: " t-doc.obj-type " " t-doc.obj-code
                " Дата " input frame {&frame-name} t-doc.shift-date " Порядок смены " input frame {&frame-name} t-doc.shift-num " ."
        view-as alert-box error.
        display t-doc.shift-num with frame {&frame-name}.
        run proc-sht no-error.
        if error-status:error then do:
          return error.
        end.
      end.
      else do:
        assign
          t-doc.shift-date = bf_shift-obj.shift-date
          t-doc.shift-num  = bf_shift-obj.shift-num
          t-doc.shift-name = bf_shift-obj.shift-name.
        display t-doc.shift-date t-doc.shift-num t-doc.shift-name with frame {&frame-name}.
        if t-doc.fact-date = ? then do:
          t-doc.fact-time = ? .
          if bf_shift-obj.status_ = {&sht-closed}
          then do :
            assign
              t-doc.fact-date = t-doc.shift-date
            .
            if t-doc.fact-date <> today
            then
              t-doc.fact-time = if (time < (12 * 60 * 60)) then time else (12 * 60 * 60) .
            display t-doc.fact-date with frame {&frame-name}.
          end.
        end.
      end.
    end.
  end.
end procedure.

procedure proc-shift-name :
  define buffer bf_shift-obj   for ub.shift-obj.
  define variable varfind-shift as integer initial 0.
  define variable varshift-date like ub.shift-obj.shift-date no-undo.
  define variable varshift-num  like ub.shift-obj.shift-num  no-undo.

  if input frame {&frame-name} t-doc.shift-name <> t-doc.shift-name then do:
    if input frame {&frame-name} t-doc.shift-date <> ? then do:

      for each  bf_shift-obj where bf_shift-obj.obj-type   = t-doc.obj-type                             and
                                   bf_shift-obj.obj-code   = t-doc.obj-code                             and
                                   bf_shift-obj.shift-date = input frame {&frame-name} t-doc.shift-date and
                                   bf_shift-obj.shift-name = input frame {&frame-name} t-doc.shift-name no-lock on error undo, return error return-value :
        assign
          varfind-shift = varfind-shift + 1
          varshift-date = bf_shift-obj.shift-date
          varshift-num  = bf_shift-obj.shift-num.
      end.

      if varfind-shift = 0 or varfind-shift > 1 then do:
        if varfind-shift = 0 then do:
          message "Не найдена смена: " t-doc.obj-type " " t-doc.obj-code
                  " Дата " input frame {&frame-name} t-doc.shift-date " Номер смены " input frame {&frame-name} t-doc.shift-name " ."
          view-as alert-box error.
        end.
        else do:
          message "Найдено более одной смены с одним номером в сменном дне. Объект: " t-doc.obj-type " " t-doc.obj-code
                  " Дата " input frame {&frame-name} t-doc.shift-date " Номер смены " input frame {&frame-name} t-doc.shift-name " ."
          view-as alert-box error.
        end.
        display t-doc.shift-name with frame {&frame-name}.
        run proc-sht no-error.
        if error-status:error then do: return error. end.
      end.
      else do:
        assign frame {&frame-name}
          t-doc.shift-name.
        assign
          t-doc.shift-date = varshift-date
          t-doc.shift-num  = varshift-num.
        display t-doc.shift-date t-doc.shift-num t-doc.shift-name with frame {&frame-name}.
        if t-doc.fact-date = ? then do:
          t-doc.fact-time = ? .
          if bf_shift-obj.status_ = {&sht-closed}
          then do :
            assign
              t-doc.fact-date = t-doc.shift-date
            .
            if t-doc.fact-date <> today
            then
              t-doc.fact-time = if (time < (12 * 60 * 60)) then time else (12 * 60 * 60) .
            display t-doc.fact-date with frame {&frame-name}.
          end.
        end.
      end.
    end.
  end.
end procedure.

{ str/fact-bc.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-sht d-in-doc
PROCEDURE proc-sht :
define buffer bf_shift-obj   for ub.shift-obj.
  define variable varrid-list as character no-undo.
  define variable varrecid    as recid     no-undo.
  assign
    varrid-list = "".
  run str/sht-all.w (parparentproc, v-cntxt-obj-type, v-cntxt-obj-code, 'b-sel', 'obj', t-doc.obj-type, t-doc.obj-code ,'':u, input-output varrid-list) no-error .
  if error-status:error or varrid-list = "":u then do:
    return error.
  end.
  else do:
    assign
      varrecid = integer (entry(1, varrid-list)).
    find first bf_shift-obj where recid(bf_shift-obj) = varrecid no-lock no-error.
    if available bf_shift-obj then do:
      assign
        t-doc.shift-date = bf_shift-obj.shift-date
        t-doc.shift-num  = bf_shift-obj.shift-num
        t-doc.shift-name = bf_shift-obj.shift-name.
      display t-doc.shift-date t-doc.shift-num t-doc.shift-name with frame {&frame-name}.
      if t-doc.fact-date = ? then do:
        t-doc.fact-time = ? .
        if bf_shift-obj.status_ = {&sht-closed}
        then do :
          assign
            t-doc.fact-date = t-doc.shift-date
          .
          if t-doc.fact-date <> today
          then
            t-doc.fact-time = if (time < (12 * 60 * 60)) then time else (12 * 60 * 60) .
          display t-doc.fact-date with frame {&frame-name}.
        end.
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE r-proc-currency d-in-doc
PROCEDURE r-proc-currency :
run ref/currency.w ( input parparentproc, input "b-sel", input-output ref-rec ).
  if ref-rec = ? then do: return no-apply. end.
  find ub.currency no-lock where recid( ub.currency ) = ref-rec no-error.
  if not available ub.currency then do: return no-apply. end.
  if ub.currency.curr-code <> t-doc.exch-code then do:
    run check-update in this-procedure no-error.
    if error-status :error then do: return no-apply. end.
  end.
  RUN exch-rate    in this-procedure.
  RUN full-recount in this-procedure.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-reason d-in-doc
PROCEDURE select-reason :
define variable j-rsn-code like ub.trn-reason.reason-code no-undo.
define variable vDeleted as logical no-undo.

  assign j-rsn-code = ( input frame {&FRAME-NAME} t-doc.reason-code ).
  run str/trn-reas.w ( input ParParentProc, input {&choose}, input-output j-rsn-code ).
  find first ub.trn-reason no-lock where ub.trn-reason.reason-code = j-rsn-code no-error.
  if available ub.trn-reason then do:
    assign  rsn-name          = ub.trn-reason.reason-name
            t-doc.reason-code = ub.trn-reason.reason-code.
    display t-doc.reason-code rsn-name with frame {&FRAME-NAME}.

    if trn-type = {&is-lgas} and t-doc.reason-code <> 99 then
    do:       
      /* для СУГ, если основание не "Финальный слив СУГ" чистим данные ТП */
      { str/tdat-del.i
        t-doc.doc-code
        {&sugtpattr-massa-sug}
        vDeleted
        no-error
      } 
      { str/tdat-del.i
        t-doc.doc-code
        {&sugtpattr-teh-loss}
        vDeleted
        no-error
      } 
      { str/tdat-del.i
        t-doc.doc-code
        {&sugtpattr-err-allow}
        vDeleted
        no-error
      }
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ui-on d-in-doc
PROCEDURE ui-on :
define input parameter fnc as character no-undo.
/* ----------------------------------------------------------------------------------------------------------------------------
  Purpose:     включение пользовательского интерфейса в нужном режиме
--------------------------------------------------------------------------------------------------------------------------------- */
define buffer d-l-b for  ub.doc-line.

define variable v-vat-pc        like  ub.doc-line.vat-pc    no-undo.
define variable v-slt-pc        like  ub.doc-line.slt-pc    no-undo.
define variable v-have-slt-pc   as logical              no-undo.
define variable v-host-code     like ub.sysconf.host-code  no-undo.
define variable varadd-back-date        as   logical               no-undo.

define buffer bf_contract for ub.contract.

assign
  del-list = ""
  loc-art  = ""
.
if lookup( fnc, "enable" ) > 0 then do:

  assign
    frame {&frame-name}:title = t-doc.obj-type + " " + string (t-doc.obj-code, ">>>>9") +
    " :   ПРИХОД - " + t-doc.status_ + " № " + t-doc.doc-code + "      - ".
  assign frame {&frame-name} :title = frame {&frame-name} :title +
    ( if parext-doc-mode = ""            then title-mode( pardoc-mode ) else ( caps( '{&bef-fact-edit}':U ) +
    ( if parext-doc-mode = "reason-code" then " кода основания"         else "":U ) ) ).
  disable all with frame {&frame-name}.

  if not is-add-doc then hide b-add-doc in frame d-in-doc .
  else enable b-add-doc with frame d-in-doc .

  find first ub.add-trn no-lock where ub.add-trn.trn-doc-code =  t-doc.doc-code no-error .

  if available ub.add-trn then do:
    enable b-add-doc-yes with frame {&frame-name} .
    display b-add-doc-yes with frame {&frame-name} .
  end.
  else do:
     hide b-add-doc-yes in frame {&frame-name} .
  end.

  enable b-print b-exit b-help b-lkp {&browse-name} b-history a-n-c b-notes b-attr b-arch b-live b-cnt b-contr-lkp with frame {&frame-name}.
  hide loc-art in frame {&frame-name} loc-name loc-code in frame {&frame-name}.

  assign ub.goods.gds-name:resizable in browse {&browse-name} = yes
         ub.goods.gds-name:width-chars in browse {&browse-name} = 30  .

          if t-doc.status_ <> {&wayb} then do:
            assign
               ub.doc-line.cli-qnty  :read-only in browse {&browse-name} = yes
               ub.doc-line.fact-qnty :read-only in browse {&browse-name} = yes
               ub.doc-line.wt-brutto :read-only in browse {&browse-name} = yes
               ub.doc-line.num-place :read-only in browse {&browse-name} = yes
            .
          end.
          else do:
            if t-doc.flag_ = yes then do: assign  ub.doc-line.cli-qnty  :read-only in browse {&browse-name} = yes. end.
                                  else do: assign  ub.doc-line.fact-qnty :read-only in browse {&browse-name} = yes. end.
            if v-edit-fact-wayb
              then assign doc-line.fact-qnty :read-only in browse {&browse-name} = no.
          end.
          if isEgais
            then doc-line.cli-qnty  :read-only in browse {&browse-name} = yes.

  case pardoc-mode :
    when {&add-def} then do:
         enable t-doc.cli-code t-doc.cli-type r-clients with frame {&frame-name}.
         enable b-marks with frame {&frame-name}.
    end.
    when {&lookup} then do:
      if parext-doc-mode = "":U then do:
            if br-handle = ? then hide b-prev b-next in frame {&frame-name} .
                             else enable b-prev b-next with frame {&frame-name}.
      end.
      if  parext-doc-mode = "reason-code" then do:
          enable r-reas t-doc.reason-code with frame {&frame-name}.
      end.
      if prtvalue   = "yes" and v-cntxp-doc-prt = yes then do:
         enable b-prt   with frame {&frame-name}.
      end.
      enable b-parts with frame {&frame-name}.
	  enable b-marks with frame {&frame-name}.
      assign
         ub.doc-line.cli-qnty  :read-only in browse {&BROWSE-NAME} = yes
         ub.doc-line.fact-qnty :read-only in browse {&BROWSE-NAME} = yes
         ub.doc-line.wt-brutto :read-only in browse {&BROWSE-NAME} = yes
         ub.doc-line.num-place :read-only in browse {&BROWSE-NAME} = yes
      .
      if parext-doc-mode = "vsd_corr-parts"
      or parext-doc-mode = "vsd"
      or parext-doc-mode = "corr-parts"
      then do :
        enable t-doc.cst-code with frame {&frame-name}.
      end .
    end.
    when {&update} then do:
      /* Пересчитаем документ, потому что например НДС может быть приведен к НДС
        из справочника. */
      if not v-cntxp-inout-price and
         not t-doc.flag_ then do:
        do transaction on error   undo, return error return-value :
           for each old-doc-line:
               delete old-doc-line.
           end.
           for each d-l-b where d-l-b.doc-code = t-doc.doc-code on error undo, return error return-value :
               /* обновление  ub.doc-line.vat-pc - могло измениться за время работы */
               create old-doc-line.
               buffer-copy d-l-b to old-doc-line.
               find ub.goods where ub.goods.artic     = d-l-b.artic     and
                                ub.goods.prod-type = d-l-b.prod-type and
                                ub.goods.prod-code = d-l-b.prod-code no-lock.
               { gbl/hostcode.i t-doc.obj-type t-doc.obj-code t-doc.host-code }
               { gbl/pftxvalg.i ub.goods.gds-code {&vat-tax-code} ? t-doc.host-code t-doc.obj-type t-doc.obj-code v-vat-pc no-error }
               { str/st-sltpc.i
                 recid(ub.goods)
                 recid(t-doc)
                 bf_sysconf.cash-pay
                 v-slt-pc
               }
                  if  d-l-b.vat-pc <> v-vat-pc
                    or d-l-b.slt-pc <> v-slt-pc
                  then do:
                      assign
                            d-l-b.vat-pc = v-vat-pc
                            d-l-b.slt-pc = v-slt-pc
                      .
                      { str/in-vat.i
                        t-doc.doc-code
                        t-doc.base-rate
                        t-doc.base-scale
                        t-doc.exch-rate
                        t-doc.exch-scale
                        t-doc.vat-type
                        t-doc.slt-type
                        d-l-b.artic
                        d-l-b.prod-type
                        d-l-b.prod-code
                        d-l-b.price-cli
                        d-l-b.cli-base-rate
                        d-l-b.price-rubl
                        d-l-b.vat-pc
                        d-l-b.slt-pc
                        d-l-b.road-tax
                        d-l-b.transport-rubl
                        d-l-b.other-rubl
                        varprice-cli
                        varprice-cli-unit-base
                        varprice-road-tax
                        varprice-other-exp
                        varprice-transport-exp
                        varprice-without-abs
                        varprice-slt
                        varprice-no-slt
                        varprice-vat
                        varprice-no-vat-slt
                        varprice-rubl
                        varprice-road-tax-rubl
                        varprice-other-exp-rubl
                        varprice-transport-exp-rubl
                        varprice-without-abs-rubl
                        varprice-slt-rubl
                        varprice-no-slt-rubl
                        varprice-vat-rubl
                        varprice-no-vat-slt-rubl
                        varprice-base
                        varprice-road-tax-base
                        varprice-other-exp-base
                        varprice-transport-exp-base
                        varprice-without-abs-base
                        varprice-slt-base
                        varprice-no-slt-base
                        varprice-vat-base
                        varprice-no-vat-slt-base
                        no-error
                      }
                        if error-status :error then do:
                          message
                            error-status :get-message(1) skip
                            return-value skip
                            "Ошибка при пересчете линии документа"
                            view-as alert-box error
                          .
                          return error "Ошибка при пересчете линии документа".
                        end.
                      assign
                        d-l-b.price-cli  = varprice-cli
                        d-l-b.price-rubl = varprice-rubl
                        d-l-b.price-base = varprice-base
                      .
                      { str/clcintrn.i
                        parparentproc
                        recid(d-l-b)
                        d-l-b.doc-code
                        d-l-b.artic
                        d-l-b.prod-type
                        d-l-b.prod-code
                        old-doc-line.price-cli
                        old-doc-line.price-rubl
                        old-doc-line.price-base
                        old-doc-line.cli-qnty
                        old-doc-line.cli-base-rate
                        old-doc-line.fact-qnty
                        old-doc-line.doc-qnty
                        old-doc-line.vat-pc
                        old-doc-line.slt-pc
                        old-doc-line.road-tax
                        old-doc-line.excise
                        old-doc-line.transport-rubl
                        old-doc-line.other-rubl
                        "'update'"
                        "''"
                        no-error
                      }
                        if error-status :error then do: undo, return no-apply. end.
                        delete old-doc-line.
                  end. /* */
           end. /* each d-l-b */
        end. /* transaction */
      end.

      if prtvalue   = "yes" and v-cntxp-doc-prt then enable b-prt with frame {&frame-name}.
      enable b-parts with frame {&frame-name}.
      if convimpvalue = "yes" then do:
       if not valid-handle(m-outs-5) then do:
          create menu-item m-outs-5
          assign
            label  = "Импорт из файла с конвертацией"
          .
          on choose of m-outs-5 persistent
             run local-m-outs-5 in this-procedure.
          assign
            m-outs-5:parent = menu m-outs:handle
          .
       end.
      end.

      enable b-chg b-renum r-outs
             t-doc.wrkr t-doc.agnt t-doc.boss r-wrkr r-agnt r-boss r-outs m-inc
             with frame {&frame-name}.
/*      if bcvalue    <> "no" then enable b-bc with frame {&frame-name}.*/
      if not t-doc.flag_ then do:
        /*ИНВОЙС*/
        if inv-shipvalue = true then do:
           enable t-doc.ship-num t-doc.ship-date with frame {&frame-name}.
        end.
        else do:
          hide t-doc.ship-num t-doc.ship-date  in frame {&frame-name}.
        end.
        /*Использовние валюты клиента*/
        if curclivalue <> "no" then do:
           if NOT t-doc.flag_ and
                  t-doc.exch-code <> 0 then do:
             enable r-acc t-doc.exch-rate t-doc.exch-scale with frame {&frame-name}.
           end.
           if t-doc.contract-code = 0 then do:
             enable t-doc.exch-date t-doc.exch-code r-currency with frame {&frame-name}.
           end.
        end.
        else do:
          hide r-acc r-currency in frame {&frame-name}.
        end.

        enable t-doc.cst-code t-doc.ord-num with frame {&frame-name}.
        
        enable b-marks with frame {&frame-name}.

        if pardoc-mode <> {&lookup} then do:
           enable r-reas t-doc.reason-code with frame {&frame-name}.
        end.

        enable t-doc.pay-code r-pay t-doc.doc-date
               varpurch-code-name when t-doc.contract-code = 0
               varinplnsum   when var-inp_sum = false
               b-mark t-doc.tot-cli
               t-doc.out-code m-inc
               with frame {&frame-name}.
        if isEgais
          then disable b-add b-del with frame {&frame-name}.
          else enable b-add b-del with frame {&frame-name}.

        enable t-doc.base-rate t-doc.base-scale with frame {&frame-name}.
        if is-ovvalue <> "no" then enable ov-pc with frame {&frame-name}.
                              else hide   ov-pc in   frame {&frame-name}.
        enable t-doc.tot-other t-doc.tot-transp with frame {&frame-name}.

        if multdtypvalue <> "no" then enable t-doc.VAT-type t-doc.slt-type with frame {&frame-name}.
                                 else disable t-doc.VAT-type t-doc.slt-type with frame {&frame-name}.
      end.
      else do:
         define variable varhold-doc as logical no-undo.
         { gbl/hold-doc.i t-doc.doc-code varhold-doc }
         if varhold-doc then do:
           enable t-doc.cst-code with frame {&frame-name}.
         end.
         enable b-revis t-doc.ord-num with frame {&frame-name}.
      end.
      
      if v-by-utd
      then do :
        disable
          b-add b-del b-chg
          t-doc.pay-code r-pay t-doc.doc-date t-doc.fact-date
          varpurch-code-name varinplnsum
          t-doc.out-code m-inc r-outs
          t-doc.tot-cli
          t-doc.base-rate t-doc.base-scale
          t-doc.shift-date t-doc.shift-num r-sht
          t-doc.tot-transp t-doc.tot-other
          t-doc.SLT-type t-doc.VAT-type ov-pc
        with frame {&frame-name}.
        assign
          doc-line.cli-qnty  :read-only in browse {&BROWSE-NAME} = yes
          doc-line.fact-qnty :read-only in browse {&BROWSE-NAME} = yes
          doc-line.wt-brutto :read-only in browse {&BROWSE-NAME} = yes
          doc-line.num-place :read-only in browse {&BROWSE-NAME} = yes
        .
      end .
      
      define variable v-tmp-char like ub.thbj-attr.property-value-character no-undo .
      define variable v-tmp-date      like ub.thbj-attr.property-value-date    no-undo .
      define variable v-tmp-decimal   like ub.thbj-attr.property-value-decimal no-undo .
      define variable v-tmp-integer   like ub.thbj-attr.property-value-integer no-undo .
      define variable v-rvd-own-nb as logical no-undo .
      define variable v-rvd-own-nb-type as   character no-undo .
      
      run adm/shattri.p (
          input "get":U
          ,input t-doc.obj-type
          ,input t-doc.obj-code
          ,input {&attr-petrol}
          ,input  "rvd-own-nb"
          ,output v-tmp-char
          ,output v-tmp-date
          ,output v-tmp-decimal
          ,output v-tmp-integer
          ,output v-rvd-own-nb
          ,output v-rvd-own-nb-type
          ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
          ) no-error .
      if error-status :error then v-rvd-own-nb = false .
      if v-rvd-own-nb = false
      and t-doc.cli-code > 0
      then do :
        find first ub.clients-attr no-lock where ub.clients-attr.obj-type = t-doc.cli-type
                                             and ub.clients-attr.obj-code = t-doc.cli-code
                                             and ub.clients-attr.attr-code = {&attr-owner-code}
                                             no-error .
        if available ub.clients-attr
        and ub.clients-attr.attr-value > ""
        then do :
          if ub.clients-attr.attr-value = "орг" + string(t-doc.host-code)
          then do :      
            v-can-edit = no .                      
            disable b-add b-del with frame {&frame-name}.
          end .
        end .
      end .
    end. /* when {&update} */
  end case.
end.

find ub.clients where ub.clients.obj-type = t-doc.cli-type and ub.clients.obj-code = t-doc.cli-code no-lock no-error.
if available ub.clients then display ub.clients.obj-name with frame {&frame-name}.
   else display ? @ ub.clients.obj-name with frame {&frame-name}.


find ub.currency where ub.currency.curr-code = bf_sysconf.base-code NO-LOCK.
assign
  base-type = ub.currency.curr-abbr
  base-abbr = base-type.

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_income_add-back-date':U
  {&cntxt-object}
  t-doc.host-code
  t-doc.obj-type
  t-doc.obj-code
  0
  0
  0
  false
  varadd-back-date
}

if t-doc.status_ = {&inquiry} then do:
   hide t-doc.fact-date t-doc.fact-qnty in frame {&frame-name}.
end.
else do:
 if (t-doc.status_ = {&wayb} and not t-doc.flag_) then do:
   display t-doc.fact-date with frame {&frame-name}.
   if t-doc.status_ = {&wayb} and
       t-doc.flag_   = no     and
       pardoc-mode = {&update}   and
       varadd-back-date = yes and 
       not v-by-utd
   then do:
     enable t-doc.fact-date with frame {&frame-name}.
   end.
   { gbl/objat.i
     t-doc.obj-type
     t-doc.obj-code
     "'shift-on=request'"
     varlog
     no-error
   }
   if error-status :error then do:
     message
       vss-workfile vss-revision vss-description skip
       "Ошибка при запуске процедуры objat" skip
       error-status :get-message(1) skip
       return-value skip
       view-as alert-box error .
     return error.
   end.
   if varlog then do:
     display t-doc.shift-date t-doc.shift-num t-doc.shift-name r-sht with frame {&frame-name}.
     if t-doc.status_ = {&wayb} and
        t-doc.flag_   = no      and
        pardoc-mode = {&update} and
        varadd-back-date = yes  and
        not v-by-utd
     then do:
       enable t-doc.shift-date t-doc.shift-num t-doc.shift-name r-sht with frame {&frame-name}.
     end.
   end.
 end.
 else do:
   display t-doc.fact-date t-doc.fact-qnty t-doc.shift-date t-doc.shift-num t-doc.shift-name r-sht with frame {&frame-name}.
 end.
end.
&scop purchase-code string(t-doc.purch-code)
assign
  varpurch-code-name = {&purchase-codes-name}.
display t-doc.tot-calc
     t-doc.tot-sale
     t-doc.tot-fact
     t-doc.road-tax
     t-doc.tot-cli
     t-doc.doc-date
     t-doc.fact-date
     t-doc.doc-qnty
     t-doc.cli-qnty
     t-doc.ord-num
     t-doc.cli-code
     t-doc.cli-type
     t-doc.pay-code
     t-doc.VAT-base
     t-doc.VAT-rubl
     t-doc.exch-date
     t-doc.exch-code
     t-doc.exch-rate
     t-doc.exch-scale
     t-doc.base-rate
     t-doc.base-scale
     t-doc.tot-transp
     t-doc.tot-other
     varpurch-code-name
     varinplnsum
     with frame {&frame-name}.
display t-doc.ship-num   when inv-shipvalue  = true
     t-doc.ship-date  when inv-shipvalue  = true
     ov-pc            when is-ovvalue     <> "no"
     t-doc.VAT-type
     t-doc.slt-type
     t-doc.cst-code
     t-doc.wrkr
     t-doc.agnt
     t-doc.boss
     with frame {&frame-name}.
find first bf_contract where bf_contract.host-code     = t-doc.host-code and
                             bf_contract.contract-code = t-doc.contract-code no-lock no-error.
if available bf_contract then do:
  assign
    varcontract-prn-code = bf_contract.contract-prn-code.
end.
else do:
  assign
    varcontract-prn-code = "БЕЗ ДОГОВОРА".
end.
display varcontract-prn-code with frame {&frame-name}.
/* подвинем батончик */
/*b-contr-lkp:column =  varcontract-prn-code:column + length(trim(varcontract-prn-code)) + 1 .*/

{ str/psn-chk.i wrkr on t-doc ref-rec }
{ str/psn-chk.i agnt on t-doc ref-rec }
{ str/psn-chk.i boss on t-doc ref-rec }

find ub.pay-type where ub.pay-type.obj-code = input frame {&frame-name} t-doc.pay-code no-lock no-error.
if available ub.pay-type then display ub.pay-type.obj-name with frame {&frame-name}.
                      else display ? @ ub.pay-type.obj-name with frame {&frame-name}.
if curclivalue <> "no" then do:
   find ub.currency where ub.currency.curr-code = t-doc.exch-code no-lock no-error.
   if available ub.currency then display ub.currency.curr-abbr with frame {&frame-name}.
                         else display ? @ ub.currency.curr-abbr with frame {&frame-name}.
end.
else hide ub.currency.curr-abbr in frame {&frame-name}.

if t-doc.out-code <> ? or t-doc.out-code:sensitive then display t-doc.out-code with frame {&frame-name}.
                                                   else hide t-doc.out-code in frame {&frame-name}.

  find ub.trn-reason no-lock where
       ub.trn-reason.reason-code = t-doc.reason-code no-error.
  assign
    rsn-name = ( if available ub.trn-reason then ub.trn-reason.reason-name else "":U )
  .
  display t-doc.reason-code rsn-name with frame {&FRAME-NAME}.

{&OPEN-QUERY-{&browse-name}-default}
if pardoc-mode = {&lookup} then do:
  if line-rec <> ? then reposition {&browse-name} to recid line-rec no-error.
  apply "entry" to {&browse-name} in frame {&frame-name}.
end.
if pardoc-mode = {&update} then do:
  if not can-find (first  ub.doc-line where  ub.doc-line.doc-code = t-doc.doc-code no-lock) then
    apply "entry" to t-doc.tot-cli in frame {&frame-name}.
  else do:
    if line-rec <> ? then reposition {&browse-name} to recid line-rec no-error.
    apply "entry" to {&browse-name} in frame {&frame-name}.
    if t-doc.flag_ = no then do:
       apply "entry" to  ub.doc-line.cli-qnty in browse {&browse-name}.
    end.
    else do:
       apply "entry" to  ub.doc-line.fact-qnty in browse {&browse-name}.
    end.
  end.
end.
/*if is-fuel or can-find (FIRST ub.clients-attr no-lock where ub.clients-attr.obj-type = ub.clients.obj-type  
  and ub.clients-attr.obj-code = ub.clients.obj-code
  and ub.clients-attr.attr-code = {&attr-supp-np}
  and ub.clients-attr.attr-value = "yes")
  then 
do:*/
b-in-attr-fuel:sensitive = true.
b-calc-tp:sensitive = true.
/*end.*/
if num-results('{&browse-name}') > 0 then do:
   if {&browse-name}:refresh() then.
end.
IF mImagePh THEN
DO:
    DEFINE VARIABLE vImageList AS LONGCHAR    NO-UNDO.
    DEFINE VARIABLE vCh        AS CHARACTER   NO-UNDO.
if AVAILABLE goods then do:
    RUN gds-attr-value ( goods.gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
    RUN imagelist_decode IN THIS-PROCEDURE (INPUT vImageList, goods.gds-code, OUTPUT vImageList).
    vCh = ENTRY (1, vImageList, {&ImageDelimiter}).
    g-image:LOAD-IMAGE (ENTRY (1, vCh)) NO-ERROR.
    ASSIGN
        g-image:HIDDEN     = NO
        g-image:VISIBLE    = YES
        g-image:SENSITIVE  = YES
        .
end.
else
      ASSIGN
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .   
END.
ELSE
    ASSIGN
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE upd-cli-qnty d-in-doc
PROCEDURE upd-cli-qnty :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-part-code  as character no-undo.
if available  ub.doc-line then do:
  if dec( ub.doc-line.cli-qnty:screen-value in browse {&browse-name}) <>  ub.doc-line.cli-qnty then do:
    if (dec( ub.doc-line.cli-qnty:screen-value in browse {&browse-name}) = 0.00 or
        dec( ub.doc-line.cli-qnty:screen-value in browse {&browse-name}) = ?) and not t-doc.flag_ then do:
      message "Не указано количество в единицах поставщика.".
      display  ub.doc-line.cli-qnty with browse {&browse-name}.
      return error.
    end.
    find ub.units where ub.units.unit-name = ub.goods.unit-base no-lock.
    if t-doc.flag_ and not v-edit-fact-wayb then do:
       message "В данном статусе нельзя редактировать количество по ТТН".
       display  ub.doc-line.cli-qnty with browse {&browse-name}.
       return error.
    end.
    if lookup({&serial}, ub.units.type) > 0  then do:
       message "В серийном товаре нельзя редактировать количество по ТТН".
       display  ub.doc-line.cli-qnty with browse {&browse-name}.
       return error.
    end.
    run prev-cor-line in this-procedure
      ( input ub.units.type
      , input ub.doc-line.obj-type
      , input ub.doc-line.obj-code
      , input ub.doc-line.artic
      , input ub.doc-line.prod-type
      , input ub.doc-line.prod-code
      ) no-error.
    if error-status :error then do:
       message return-value view-as alert-box error.
       display  ub.doc-line.cli-qnty with browse {&browse-name}.
       return error.
    end.
    /* Код партии для алкогольной продукции */
    run get-alc-part in this-procedure
      (input recid(ub.doc-line),
       output v-part-code
      ).
    do transaction on error undo, return error return-value :
       assign line-rec = recid(ub.doc-line).
       run str/cor-line.p
         (input parparentproc
         ,input-output line-rec                                                                       /* par-rec-doc-line    */
         ,input  ub.doc-line.doc-code                                                                     /* pardoc-code         */
         ,input  ub.doc-line.prod-type                                                                    /* parprod-type        */
         ,input  ub.doc-line.prod-code                                                                    /* parprod-code        */
         ,input  ub.doc-line.artic                                                                        /* parartic            */
         ,input dec( ub.doc-line.cli-qnty:screen-value in browse {&browse-name})                          /* parcli-qnty         */
         ,input  ub.doc-line.cli-base-rate                                                                /* parcli-base-rate    */
         ,input  ub.doc-line.fact-qnty                                                                    /* parfact-qnty        */
         ,input  ub.doc-line.cli-base-rate * dec( ub.doc-line.cli-qnty:screen-value in browse {&browse-name}) /* pardoc-qnty         */
         ,input  ub.doc-line.unit-cli                                                                     /* parunit-cli         */
         ,input  ub.doc-line.vat-pc                                                                       /* parvat-pc           */
         ,input  ub.doc-line.slt-pc                                                                       /* parslt-pc           */
         ,input  ub.doc-line.price-cli                                                                    /* parprice-cli        */
         ,input  ub.doc-line.price-base                                                                   /* parprice-base       */
         ,input  ub.doc-line.price-rubl                                                                   /* parprice-rubl       */
         ,input  ub.doc-line.new-price-sale                                                               /* parprice-rubl       */
         ,input  ub.doc-line.num-place                                                                    /* parnum-place        */
         ,input  ub.doc-line.wt-brutto                                                                    /* parwt-brutto        */
         ,input  ub.doc-line.road-tax                                                                     /* parroad-tax         */
         ,input  ub.doc-line.excise                                                                       /* parexcise           */
         ,input  ub.doc-line.doc-density                                                                  /* pardoc-density      */
         ,input  ub.doc-line.temperature                                                                  /* partemperature      */
         ,input ?                                                                                     /* parcontract-code    */
         ,input ?                                                                                     /* parlast-date        */
         ,input dec( ub.doc-line.cli-qnty:screen-value in browse {&browse-name})                          /* parfact-qnty-kg     */
         ,input  ub.doc-line.fact-density                                                                 /* parfact-density     */
         ,input ?                                                                                     /* parcst-code         */
         ,input no                     /* paralc-update              */
         ,input v-part-code            /* paralc-part-code           */
         ,input ?                      /* paralc-mark-db-num         */
         ,input ?                      /* paralc-mark-code           */
         ,input ?                      /* paralc-bottling-date       */
         ,input ?                      /* paralc-ref-ab-path         */
         ,input ?                      /* paralc-quality-certif-path */
         ,input ?                      /* paralc-imp-type            */
         ,input ?                      /* paralc-imp-code            */
         ,input ?                      /* paralc-certif-path         */
         ) no-error.
       if error-status :error
       then do:
         if error-status :get-message(1) <> ""
         then do:
           message
             vss-workfile vss-revision vss-description skip
             "Ошибка при вызове процедуры cor-line.p" skip
             "Точка вызова 1" skip
             error-status :get-message(1) skip
             return-value skip
             view-as alert-box error .
         end.
         undo, return error.
       end.
       find first ub.doc-line-attr where ub.doc-line-attr.doc-code  = t-doc.doc-code and
                                         ub.doc-line-attr.gds-code  = ub.goods.gds-code and
                                         ub.doc-line-attr.attr-code = "tot-cli"      no-error.
       if not available ub.doc-line-attr then do:
         create ub.doc-line-attr.
         assign
         ub.doc-line-attr.doc-code  = t-doc.doc-code
         ub.doc-line-attr.gds-code  = ub.goods.gds-code
         ub.doc-line-attr.attr-code = "tot-cli"        .
       end.
       assign ub.doc-line-attr.attr-value = string( ub.doc-line.cli-qnty *  ub.doc-line.price-cli).
       assign line-rec = recid ( ub.doc-line ).
       run str/chk-prt.p ( input line-rec, input no, buffer t-doc).
       /* Вызов разбивки по шкале */
       do
       on error undo, return error return-value
       :
         define buffer buf_doc-line for ub.doc-line .
         define buffer buf_inv-line for ub.inv-line .

         find first buf_doc-line exclusive-lock where
             recid( buf_doc-line ) = recid(  ub.doc-line ) .
         if decimal(  ub.doc-line.cli-qnty :screen-value in browse {&browse-name} ) <>  ub.doc-line.cli-qnty
         then do:
           assign
             buf_doc-line.cli-qnty = decimal(  ub.doc-line.cli-qnty :screen-value in browse {&browse-name} )
           .
         end.
/* жидкое топливо не редактируется здесь */
/*         find first buf_inv-line no-lock where*/
/*                    buf_inv-line.doc-code  = buf_doc-line.doc-code  and*/
/*                    buf_inv-line.artic     = buf_doc-line.artic     and*/
/*                    buf_inv-line.prod-type = buf_doc-line.prod-type and*/
/*                    buf_inv-line.prod-code = buf_doc-line.prod-code no-error .*/
/*         if available buf_inv-line*/
/*         then do:*/
/*           { str/coracqkg.i*/
/*               "recid( buf_inv-line )"*/
/*               buf_doc-line.cli-qnty*/
/*               no-error*/
/*           }*/
/*           assign*/
/*             buf_doc-line.doc-qnty = buf_doc-line.cli-qnty / buf_doc-line.density*/
/*           .*/
/*         end.*/
         find first buf_doc-line        no-lock where
             recid( buf_doc-line ) = recid(  ub.doc-line ) .
       end. /* on error */
       run ui-on in this-procedure
         ( input "line"
         ) .
    end.
  end. /* screen-value ne base value */
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-rate-doc d-in-doc
PROCEDURE update-rate-doc :
if input frame {&frame-name} t-doc.exch-rate  <> t-doc.exch-rate  or
   input frame {&frame-name} t-doc.exch-scale <> t-doc.exch-scale or
   input frame {&frame-name} t-doc.base-rate  <> t-doc.base-rate  or
   input frame {&frame-name} t-doc.base-scale <> t-doc.base-scale then
   do transaction on error undo, return error return-value :
     run check-exch   in this-procedure no-error.
     if error-status :error then do: return error return-value. end.
     run check-update in this-procedure no-error.
     if error-status :error then do: return error return-value. end.
     run check-rate   in this-procedure no-error.
     if error-status :error then do: return error return-value. end.
    end.
    run UI-on in this-procedure ( input "line" ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE val-ch-slt-type d-in-doc
PROCEDURE val-ch-slt-type :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer d-l-b for  ub.doc-line.
define buffer bf-goods for ub.goods.

define variable old-slt         like ub.trn-doc.slt-type .
define variable v-slt-pc        like ub.doc-line.slt-pc    no-undo.
define variable v-host-code     like ub.sysconf.host-code  no-undo.

do transaction on error undo, return error return-value :
  run check-update in this-procedure no-error.
  if error-status :error then do: return error. end.
  { gbl/hostcode.i t-doc.obj-type t-doc.obj-code v-host-code }
  assign old-slt = t-doc.slt-type.
  assign frame {&frame-name} t-doc.SLT-type.
  find first d-l-b where d-l-b.doc-code = t-doc.doc-code no-lock no-error.
  if available d-l-b then do:
     if t-doc.slt-type = {&without-slt} and
        old-slt <> {&without-slt} then do:
        message "Налог с продаж в строках устанавливаем в 0" view-as alert-box information.
        for each d-l-b where d-l-b.doc-code = t-doc.doc-code:
            assign d-l-b.slt-pc = 0.
        end.
     end.
     else if t-doc.slt-type <> {&without-slt} and
             old-slt = {&without-slt} then do:
        message "Налог с продаж в строках устанавливаем из товара" view-as alert-box information.
        for each d-l-b where d-l-b.doc-code = t-doc.doc-code,
                 first bf-goods where bf-goods.artic     = d-l-b.artic and
                                      bf-goods.prod-type = d-l-b.prod-type and
                                      bf-goods.prod-code = d-l-b.prod-code:
            { gbl/pftxvalg.i bf-goods.gds-code {&slt-tax-code} ? v-host-code t-doc.obj-type t-doc.obj-code v-slt-pc no-error }
            assign d-l-b.slt-pc = v-slt-pc.
        end.

     end.
     run check-rate   in this-procedure no-error.
     if error-status :error then do: undo, return error. end.
     run full-recount in this-procedure no-error.
     if error-status :error then do: undo, return error. end.
  end.
end.
run UI-on in this-procedure ( input "line" ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE val-ch-type d-in-doc
PROCEDURE val-ch-type :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter parself-name as character no-undo.
if parself-name = "slt-type" then do: run val-ch-slt-type in this-procedure no-error. end.
else do:
   if parself-name = "vat-type" then do: run val-ch-vat-type in this-procedure no-error. end.
                                else do:
                                   message "Неверный self:name " parself-name
                                           " при передаче в процедуру val-ch-type."
                                   view-as alert-box error.
                                   return error.
                                end.
end.
if error-status :error then do:
      display t-doc.vat-type with frame {&frame-name}.
      display t-doc.slt-type with frame {&frame-name}.
      return no-apply.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE val-ch-vat-type d-in-doc
PROCEDURE val-ch-vat-type :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer d-l-b for  ub.doc-line.

define variable old-vat as character no-undo.
define variable vd-price-cli   like ub.doc-line.price-cli  no-undo.
define variable vd-price-base  like ub.doc-line.price-base no-undo.
define variable vd-price-rubl  like ub.doc-line.price-rubl no-undo.
define variable vd-vat-pc      like ub.doc-line.vat-pc     no-undo.
define variable vd-slt-pc      like ub.doc-line.slt-pc     no-undo.
define variable vd-road-tax    like ub.doc-line.road-tax   no-undo.
define variable vd-excise      like ub.doc-line.excise     no-undo.

define buffer bf-goods for ub.goods.

run check-update in this-procedure no-error.
 if error-status :error then do: return error. end.
do transaction on error   undo, return error
               on end-key undo, return error
               on stop    undo, return error :
  assign
    old-vat = t-doc.vat-type.
  ASSIGN frame {&frame-name} t-doc.VAT-type.
  if t-doc.vat-type  = {&without-vat} and
     old-vat        <> {&without-vat} then do:
      message "НДС в строках устанавливаем в 0" view-as alert-box information.
      for each d-l-b where d-l-b.doc-code = t-doc.doc-code:
          assign d-l-b.vat-pc = 0.
      end.
  end.
  else do:
    if t-doc.vat-type <> {&without-vat} and
           old-vat = {&without-vat} then do:
      message "НДС в строках устанавливаем из последней поставки поставщика по данному товару. Если таковой не имеется, то из карточки товара." view-as alert-box information.
      for each d-l-b where d-l-b.doc-code = t-doc.doc-code,
               first bf-goods where bf-goods.artic     = d-l-b.artic and
                                    bf-goods.prod-type = d-l-b.prod-type and
                                    bf-goods.prod-code = d-l-b.prod-code:
        assign
          vd-vat-pc = ?.
        run cpprclig in this-procedure   (
          input        t-doc.doc-code             ,
          input        t-doc.cli-code             ,
          input        t-doc.cli-type             ,
          input        t-doc.host-code            ,
          input        t-doc.base-rate            ,
          input        t-doc.base-scale           ,
          input        t-doc.exch-rate            ,
          input        t-doc.exch-scale           ,
          input        t-doc.vat-type             ,
          input        t-doc.slt-type             ,
          input        d-l-b.artic                ,
          input        d-l-b.prod-type            ,
          input        d-l-b.prod-code            ,
          input        yes                        ,
          input        d-l-b.cli-base-rate        ,
          input        d-l-b.transport-rubl       ,
          input        d-l-b.other-rubl           ,
          output       vd-price-cli               ,
          output       vd-price-base              ,
          output       vd-price-rubl              ,
          input-output vd-vat-pc                  ,
          input-output vd-slt-pc                  ,
          input-output vd-road-tax                ,
          input-output vd-excise                  ) no-error.
          if vd-vat-pc = ? then do:
            { gbl/pftxvalg.i bf-goods.gds-code {&vat-tax-code} ? t-doc.host-code t-doc.obj-type t-doc.obj-code vd-vat-pc no-error }
            if vd-vat-pc = ? then do:
              message "Нет НДС в карточке товара по товару: " d-l-b.artic " " d-l-b.prod-type " " d-l-b.prod-code "." skip
                      "НДС остается равным 0." view-as alert-box.
            end.
          end.
          assign d-l-b.vat-pc = vd-vat-pc.
      end.
    end.
  end.
  run check-rate in this-procedure no-error.
  if error-status :error then do: undo, return error. end.
  run full-recount in this-procedure no-error.
  if error-status :error then do: undo, return error. end.
end.
run UI-on in this-procedure ( input "line" ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE vc-purch-code d-in-doc
PROCEDURE vc-purch-code :
define variable varpurch-int-code like ub.trn-doc.purch-code no-undo.

  assign
    varpurch-int-code = lookup( input frame {&frame-name} varpurch-code-name, {&purchase-codes-full} ).
  if t-doc.purch-code <> varpurch-int-code then do:
    run chg-purch-code in this-procedure ( input varpurch-int-code ) no-error.
    if error-status :error then do:
      message "Ошибка при смене кода приобретения." skip
              return-value skip
              error-status :get-message( 1 )
              error-status :get-message( 2 )
      view-as alert-box error.
      display varpurch-code-name with frame {&frame-name}.
    end.
    &scop purchase-code string(t-doc.purch-code)
    assign
      varpurch-code-name = {&purchase-codes-name}.
    display varpurch-code-name with frame {&frame-name}.
  end.

END PROCEDURE.

procedure chg-purch-contract :
  define buffer bf_contract for ub.contract.

  do on error undo, return error return-value :
    define variable v-purch-code as character no-undo .

    { str/purchcon.i
        t-doc.host-code
        t-doc.contract-code
        v-purch-code
        varpurch-code-name
    }
    display varpurch-code-name with frame {&frame-name}.
    run vc-purch-code in this-procedure no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE wr-cst-code d-in-doc
PROCEDURE wr-cst-code :
define variable v-num as integer no-undo.
define buffer cst-parts for ub.parts.
define buffer buf_doc-line for  ub.doc-line.

do on error undo, return error return-value :
&SCOP parts-cst-code cst-parts where cst-parts.obj-type = t-doc.obj-type and~
                                     cst-parts.obj-code = t-doc.obj-code and~
                                     cst-parts.out-code = t-doc.doc-code and~
                                     cst-parts.cst-code = t-doc.cst-code
&scop parts-doc      cst-parts where cst-parts.obj-type = t-doc.obj-type and~
                                     cst-parts.obj-code = t-doc.obj-code and~
                                     cst-parts.out-code = t-doc.doc-code
&SCOP parts-cst-code1 cst-parts where cst-parts.obj-type = t-doc.obj-type and~
                                     cst-parts.obj-code = t-doc.obj-code and~
                                     cst-parts.out-code = t-doc.doc-code and~
                                     cst-parts.cst-code begins t-doc.cst-code

  if can-find(first cst-parts where cst-parts.out-code = t-doc.doc-code no-lock) then do:
    run gbl/d-askw.w ("Замена номера ГТД в партиях документа",
                  "Изменить номера ГТД в партиях документа?",
                  "|^",
                  "Все партии|Тот же № ГТД|Отмена",
                  "Проходим по всем партиям документа и заменяем номер ГТД|Идем по партиям, где номер был "
                  + "'" + t-doc.cst-code + "'" + "|Ничего не делаем",
                  2,
                  3,
                  output v-num
                 ).
    case v-num:
    when 3 then do:
      display t-doc.cst-code with frame {&frame-name}.
      return.
    end.
    when 2 then do:
      if v-is-gtd-part = "yes" then do:
        for each {&parts-cst-code1}:
          if LENGTH( input frame {&frame-name} t-doc.cst-code ) > 0 then do:
            if SUBSTRING( cst-parts.cst-code, LENGTH( t-doc.cst-code ) + 1 ,1 ) = '/' or cst-parts.cst-code = t-doc.cst-code then
              assign cst-parts.cst-code = input frame {&frame-name} t-doc.cst-code + SUBSTRING( cst-parts.cst-code, LENGTH( t-doc.cst-code ) + 1 )  .
          end.
          else assign cst-parts.cst-code = "" .
        end.
      end.
      else do:
        for each {&parts-cst-code}:
          assign cst-parts.cst-code = input frame {&frame-name} t-doc.cst-code.
        end.
      end.
    end.
    when 1 then do:
      for each {&parts-doc}:
         assign cst-parts.cst-code = input frame {&frame-name} t-doc.cst-code.
      end.
    end.
    end case.
  end.
  assign t-doc.cst-code = input frame {&frame-name} t-doc.cst-code.
end.
  if v-is-gtd-part = "yes" then run UI-on in this-procedure ( input "line" ) .
END PROCEDURE.
{ str/cntrcode.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gtd-line d-in-doc
procedure gtd-line :
  do on error undo, return error return-value :
    if pardoc-mode <> {&add-def} and pardoc-mode <> {&update} then return.
    if not available  ub.doc-line then  return.
    define variable v-res as logical   no-undo .
    define buffer buf_doc-line for  ub.doc-line.
    define buffer buf_parts for ub.parts.
    find first buf_parts no-lock
      where buf_parts.obj-type  =  ub.doc-line.obj-type
        and buf_parts.obj-code  =  ub.doc-line.obj-code
        and buf_parts.artic     =  ub.doc-line.artic
        and buf_parts.prod-type =  ub.doc-line.prod-type
        and buf_parts.prod-code =  ub.doc-line.prod-code
        and buf_parts.out-code  =  ub.doc-line.doc-code
    no-error .
    if available buf_parts then do:
      if buf_parts.cst-code  BEGINS t-doc.cst-code and (SUBSTRING( buf_parts.cst-code, LENGTH( t-doc.cst-code ) + 1 ,1 ) = '/' or buf_parts.cst-code = t-doc.cst-code) then do:
        if LENGTH( t-doc.cst-code ) > 0 then assign d-gtd-add = SUBSTRING( buf_parts.cst-code, LENGTH( t-doc.cst-code ) + 2 ) .
        else do:
          message "ГТД документа не заполнен! Ввод дополнения невозможен."  view-as alert-box.
          return.
        end.
      end.
      else do:
        message "Префикс ГТД строки не совпадает с ГТД документа! Ввод дополнения невозможен."  view-as alert-box.
        return.
      end.
    end.
    run str/gtd-add.w (input ub.goods.artic, input (ub.goods.prod-type + string(ub.goods.prod-code)),goods.gds-name, input t-doc.cst-code, input-output d-gtd-add, output v-res) .
    if v-res then do:
      for each buf_parts
        where buf_parts.obj-type  = t-doc.obj-type
          and buf_parts.obj-code  = t-doc.obj-code
          and buf_parts.artic     =  ub.doc-line.artic
          and buf_parts.prod-type =  ub.doc-line.prod-type
          and buf_parts.prod-code =  ub.doc-line.prod-code
          and buf_parts.out-code  = t-doc.doc-code
        :
        if d-gtd-add = "" then assign buf_parts.cst-code = t-doc.cst-code .
        else assign buf_parts.cst-code = t-doc.cst-code + "/" + d-gtd-add .
      end.
      display d-gtd-add with browse {&browse-name} .
    end.
  end.
end procedure. /* gtd-line */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION deviation-price d-in-doc
FUNCTION deviation-price RETURNS DECIMAL
(buffer local-doc-line for ub.doc-line) :
define buffer bf_doc-line for ub.doc-line.
define buffer bf_trn-doc  for ub.trn-doc.

if local-doc-line.fact-order = 0 then do:
  find last bf_doc-line where bf_doc-line.obj-type     = t-doc.obj-type           and
                              bf_doc-line.obj-code     = t-doc.obj-code           and
                              bf_doc-line.prod-type    = local-doc-line.prod-type and
                              bf_doc-line.prod-code    = local-doc-line.prod-code and
                              bf_doc-line.artic        = local-doc-line.artic     and
                              bf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh}       and
                              bf_doc-line.status_      = {&fact}                  and
                              bf_doc-line.fact-order   > 0                        and
                              can-find(first bf_trn-doc where
                                             bf_trn-doc.doc-code = bf_doc-line.doc-code
                                         and bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh})
                              use-index dt-fo no-lock no-error.
  if available bf_doc-line then do:
    return (local-doc-line.price-rubl - bf_doc-line.price-rubl) / bf_doc-line.price-rubl * 100.
  end.
  else do:
    return ?.
  end.
end.
else do:
  find last bf_doc-line where bf_doc-line.obj-type     = t-doc.obj-type            and
                              bf_doc-line.obj-code     = t-doc.obj-code            and
                              bf_doc-line.prod-type    = local-doc-line.prod-type  and
                              bf_doc-line.prod-code    = local-doc-line.prod-code  and
                              bf_doc-line.artic        = local-doc-line.artic      and
                              bf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh}        and
                              bf_doc-line.status_      = {&fact}                   and
                              bf_doc-line.fact-order   < local-doc-line.fact-order and
                              can-find(first bf_trn-doc where
                                             bf_trn-doc.doc-code = bf_doc-line.doc-code
                                         and bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh})
                              use-index dt-fo no-lock no-error.
  if available bf_doc-line then do:
    return (local-doc-line.price-rubl - bf_doc-line.price-rubl) / bf_doc-line.price-rubl * 100.
  end.
  else do:
    return ?.
  end.
end.
end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-kg-after-qnty d-in-doc
FUNCTION get-kg-after-qnty RETURNS DECIMAL
( buffer local-doc-line for ub.doc-line ) :
  define variable d_out-qnty-kg like ub.doc-line.fact-qnty no-undo.
  run after_qnty in this-procedure    ( input recid( local-doc-line ),
                                        output d_out-qnty-kg        )
                                        no-error.
  return ( if error-status :error then ? else d_out-qnty-kg ).
end function. /* get-kg-after-qnty */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-kg-fact-qnty d-in-doc
FUNCTION get-kg-fact-qnty RETURNS DECIMAL
( buffer local-doc-line for ub.doc-line ) :
  define variable d_out-qnty-kg like ub.doc-line.fact-qnty no-undo.

  run inv-line_qnty in this-procedure ( input recid( local-doc-line ),             output d_out-qnty-kg       ) no-error.
  return ( if error-status :error then ? else d_out-qnty-kg ).
end function. /* get-kg-fact-qnty */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-kg-sale-base d-in-doc
FUNCTION get-kg-sale-base RETURNS DECIMAL
( buffer local-doc-line for ub.doc-line ) :
  define variable d_out-kg-sale-price like ub.doc-line.price-rubl no-undo.

  run inv-line_price in this-procedure ( input recid( local-doc-line ), input  no, output d_out-kg-sale-price ) no-error.
  return ( if error-status :error then ? else d_out-kg-sale-price ).
end function. /* get-kg-sale-base */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-kg-sale-rubl d-in-doc
FUNCTION get-kg-sale-rubl returns decimal
( buffer local-doc-line for ub.doc-line ) :
define variable d_out-kg-sale-price like ub.doc-line.price-rubl no-undo.
run inv-line_price in this-procedure ( input recid( local-doc-line ), input yes, output d_out-kg-sale-price ) no-error.
return ( if error-status :error then ? else d_out-kg-sale-price ).
end function. /* get-kg-sale-rubl */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-mark d-in-doc
FUNCTION get-mark RETURNS CHARACTER
(buffer local-doc-line for  ub.doc-line ):
if lookup (string (recid (local-doc-line)), del-list) > 0  then return "*".
                                                           else return "".
end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION last-price d-in-doc
FUNCTION last-price RETURNS DECIMAL
(buffer local-doc-line for ub.doc-line) :
define buffer bf_doc-line for ub.doc-line.
define buffer bf_trn-doc for ub.trn-doc.

if local-doc-line.fact-order = 0 then do:
  find last bf_doc-line where bf_doc-line.obj-type     = t-doc.obj-type           and
                              bf_doc-line.obj-code     = t-doc.obj-code           and
                              bf_doc-line.prod-type    = local-doc-line.prod-type and
                              bf_doc-line.prod-code    = local-doc-line.prod-code and
                              bf_doc-line.artic        = local-doc-line.artic     and
                              bf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh}       and
                              bf_doc-line.status_      = {&fact}                  and
                              bf_doc-line.fact-order   > 0                        and
                              can-find(first bf_trn-doc where
                                             bf_trn-doc.doc-code = bf_doc-line.doc-code
                                         and bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh})
                              use-index dt-fo no-lock no-error.
  if available bf_doc-line then do:
    return bf_doc-line.price-rubl.
  end.
  else do:
    return ?.
  end.
end.
else do:
  find last bf_doc-line where bf_doc-line.obj-type     = t-doc.obj-type            and
                              bf_doc-line.obj-code     = t-doc.obj-code            and
                              bf_doc-line.prod-type    = local-doc-line.prod-type  and
                              bf_doc-line.prod-code    = local-doc-line.prod-code  and
                              bf_doc-line.artic        = local-doc-line.artic      and
                              bf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh}        and
                              bf_doc-line.status_      = {&fact}                   and
                              bf_doc-line.fact-order   < local-doc-line.fact-order and
                              can-find(first bf_trn-doc where
                                             bf_trn-doc.doc-code = bf_doc-line.doc-code
                                         and bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh})
                              use-index dt-fo no-lock no-error.
  if available bf_doc-line then do:
    return bf_doc-line.price-rubl.
  end.
  else do:
    return ?.
  end.
end.
end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION last-price get-add-gtd
function get-add-gtd returns character ( buffer local-doc-line for ub.doc-line ) :
  define variable d_out-gtd as character no-undo .
  define buffer buf_parts for ub.parts.
  if v-is-gtd-part = "yes" then do:
    find first buf_parts no-lock
      where buf_parts.obj-type  = local-doc-line.obj-type
        and buf_parts.obj-code  = local-doc-line.obj-code
        and buf_parts.artic     = local-doc-line.artic
        and buf_parts.prod-type = local-doc-line.prod-type
        and buf_parts.prod-code = local-doc-line.prod-code
        and buf_parts.out-code  = local-doc-line.doc-code
    no-error .
    if available buf_parts then do:
      if length(t-doc.cst-code) > 0 and (buf_parts.cst-code  BEGINS t-doc.cst-code) then do:
        if SUBSTRING( buf_parts.cst-code, LENGTH( t-doc.cst-code ) + 1 ,1 ) = '/' then
          assign d_out-gtd = SUBSTRING( buf_parts.cst-code, LENGTH( t-doc.cst-code ) + 2 ) .
      end.
    end.
  end.
  return d_out-gtd .
end function. /* get-add-gtd */
&ANALYZE-RESUME
/* _UIB-CODE-BLOCK-END */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-vsdsts d-in-doc 
FUNCTION get-vsdsts RETURNS CHARACTER
(buffer local-doc-line for doc-line ):
  
  def var v-mercury-prod as logical no-undo.
 
  if v-is-mercury-value
  then do:
    def buffer bf_gds for ub.goods.
    
    find first bf_gds where 
          local-doc-line.artic = bf_gds.artic
      and local-doc-line.prod-type = bf_gds.prod-type
      and local-doc-line.prod-code = bf_gds.prod-code.
    { gbl/gdscdat.i
      bf_gds.gds-code
      "'mercur_FGIS=request':u"
      v-mercury-prod
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Код товара" bf_gds.gds-code skip
        'mercur_FGIS=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if v-mercury-prod
    then do:
      if vsdstrObj:exsistvsd( buffer local-doc-line )
      then do:
        return "+".
      end.
      else do with frame {&FRAME-NAME}:
        return "-".
      end.
    end.
  end.

  return "".
  
end function.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-vat-sum d-in-doc 
FUNCTION get-vat-sum RETURNS decimal
(buffer local-doc-line for doc-line ):
  
  def var v-vat-sum as decimal no-undo.
  v-vat-sum = (ub.doc-line.cli-qnty *  ub.doc-line.price-cli * doc-line.VAT-pc) / (100 + doc-line.VAT-pc) .
  return v-vat-sum.
  
end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE rowdisp d-in-doc 
procedure rowdisp :
  
  def var v-vsdsts-fail as logical no-undo. 
  assign
    v-vsdsts-fail = (get-vsdsts(buffer ub.doc-line) = "-").
  
  if v-vsdsts-fail
  then do ii = 1 to extent (bcol):  
    if valid-handle (bcol[ii]) 
    then do:
      assign
        bcol[ii]:bgcolor = RED_COLOR.
    end.
  end.
  
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE rowdisp d-in-doc 
procedure add-lgas-corr :

  def var loc-ref-list as character no-undo.
  def var v-gds-code as integer no-undo.

  run str/all-docs.w
    (  input parparentproc,
        input t-doc.host-code ,
        input t-doc.obj-type ,
        input t-doc.obj-code ,
        input {&status},
        input {&fact},
        input {&income},
        input ?,
        input no,
        input "b-sel,":U + {&trdcattr-is-lgas-corr},
        input {&TDEDT_Pri_Vnesh},
        input false,
        input ?,
        output loc-ref-list ).
    find t-d-b where recid (t-d-b) = integer (loc-ref-list) no-lock no-error.
    if not available t-d-b then do:
      message "Не выбран документ-источник для корр. СУГ." view-as alert-box.
      return error.
    end.
    if not t-d-b.status_ = {&fact}
    then do:
      message "Неверный выбор документа-источника для корр. СУГ."
        skip "Документ не закрыт на факт." view-as alert-box.
      return error.
    end.
    
    find clients where clients.obj-type = t-d-b.cli-type and clients.obj-code = t-d-b.cli-code no-lock.
    disp clients.obj-code @ t-doc.cli-code
            clients.obj-name with frame {&frame-name}.
    disp clients.obj-type @ t-doc.cli-type with frame {&frame-name}.
        run check-cli no-error.
        if error-status :error then return no-apply.
 
 
   { str/tdat-val.i
     t-d-b.doc-code
     {&trdcattr-is-lgas}
     varvalue
     vartype
     no-error
   }
 
     
     if not varvalue = "yes" then do:
      message "Неверный выбор документа-источника для корр. СУГ."
        skip "Документ не является приходной накладной СУГ." view-as alert-box.
      return error.
   end.

  { str/tdat-wrt.i
    t-doc.doc-code
    {&trdcattr-trn-lgas-corr}
    t-d-b.doc-code
    no-error
  }
  
  find first ub.doc-line no-lock where ub.doc-line.doc-code = t-d-b.doc-code no-error.
  if available (ub.doc-line)
  then do:
    { gbl/doclicod.i
      recid(ub.doc-line)
      v-gds-code
    }
    
    find first ub.goods no-lock where ub.goods.gds-code = v-gds-code no-error.
    if available (ub.goods)
    then do:
      varnotes = string (recid (ub.goods)).
      run cycle-add in this-procedure.
    end.
  end.
  
  def buffer buf_doc-attr for ub.doc-attr.
  for each tt-upd-attr-fuel :
    find first ub.doc-attr where ub.doc-attr.doc-code = t-d-b.doc-code and ub.doc-attr.attr-code = tt-upd-attr-fuel.code no-lock no-error.
    if available (ub.doc-attr)
    then do:
      find first buf_doc-attr 
        where buf_doc-attr.doc-code = t-doc.doc-code 
          and buf_doc-attr.attr-code = tt-upd-attr-fuel.code no-error.
      if not available (buf_doc-attr)
      then do:
        create buf_doc-attr.
        buf_doc-attr.doc-code = t-doc.doc-code.
      end.
      buffer-copy ub.doc-attr except ub.doc-attr.doc-code
      to buf_doc-attr.
    end.
  end.
  find first ub.doc-attr where ub.doc-attr.doc-code = t-d-b.doc-code and ub.doc-attr.attr-code = {&trdcattr-nids} no-lock no-error.
  if available (ub.doc-attr)
  then do:
    find first buf_doc-attr 
      where buf_doc-attr.doc-code = t-doc.doc-code 
        and buf_doc-attr.attr-code = tt-upd-attr-fuel.code no-error.
    if not available (buf_doc-attr)
    then do:
      create buf_doc-attr.
      buf_doc-attr.doc-code = t-doc.doc-code.
    end.
    buffer-copy ub.doc-attr except ub.doc-attr.doc-code
    to buf_doc-attr.
  end.
  find first ub.doc-attr where ub.doc-attr.doc-code = t-d-b.doc-code and ub.doc-attr.attr-code = {&trdcattr-dids} no-lock no-error.
  if available (ub.doc-attr)
  then do:
    find first buf_doc-attr 
      where buf_doc-attr.doc-code = t-doc.doc-code 
        and buf_doc-attr.attr-code = tt-upd-attr-fuel.code no-error.
    if not available (buf_doc-attr)
    then do:
      create buf_doc-attr.
      buf_doc-attr.doc-code = t-doc.doc-code.
    end.
    buffer-copy ub.doc-attr except ub.doc-attr.doc-code
    to buf_doc-attr.
  end.
end procedure.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME