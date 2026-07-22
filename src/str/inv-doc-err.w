/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Документ инвентаризации

Автор: Чернова Светлана Александровна
Дата создания: 10/05/06
Author: Svetlana Chernova
Creation date: 10/05/06

Create: Суслов Алексей Юрьевич


*/

/* ************************************************************************************************************* *\
______________________________________________________________________________________________________________
|                                                  |                              |                          |
|    Было                                          |    Стало                     |    Разница               |
|__________________________________________________|______________________________|__________________________|
|                                                  |                              |                          |
|    doc-line.doc-qnty - doc-line.fact-qnty        |    doc-line.doc-qnty         |    doc-line.fact-qnty    |
|__________________________________________________|______________________________|__________________________|
|                                                  |                              |                          |
|    gds-dtl.fact-qnty - gds-dtl.doc-qnty          |    gds-dtl.fact-qnty         |    gds-dtl.doc-qnty      |
|__________________________________________________|______________________________|__________________________|
|                                                  |                              |                          |
|    inv-line.wast-cli-qnty - doc-line.cli-qnty    |    inv-line.wast-cli-qnty    |    doc-line.cli-qnty     | кг
|  = inv-line.before-cli-qnty                      |  = inv-line.after-cli-qnty   |                          |
|__________________________________________________|______________________________|__________________________|
|                                                  |    doc-line.doc-density      |                          | плотность
|                                                  |  = doc-line.fact-density     |                          |
|__________________________________________________|______________________________|__________________________|

\* ************************************************************************************************************* */

using ibs.th.str.utd.handlers.introduce.

define input        parameter parparentproc   as   handle                  no-undo.
define input-output parameter pardoc-rec      as   recid                   no-undo.
define input        parameter pardoc-mode     as   character               no-undo.
define input        parameter partype         as   character               no-undo.
define input        parameter parinternal     as   logical                 no-undo. /* при добавлении документа */
define input-output parameter parnext-prev    as   logical                 no-undo.
define input        parameter parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define input        parameter paris-holding   as   logical                 no-undo.
define input-output parameter line-rec        as   recid                   no-undo.
define input        parameter br-handle       as   handle                  no-undo.
define input        parameter bf-handle       as   handle                  no-undo.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Документ инвентаризации":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/color.i    }
{ gbl/waitfram.i noprocess }
{ str/trdcalib.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ trg/partslib.i }
{ str/libbcrcn.i }
{ str/doc-code.i }
{ str/clcprtsl.i }
{ str/lib-rwds.i }
{ cmp/gds-list.i gds-list def "new shared" }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/getctxtp.i def }
{ str/getctxtp.i get }
{ gbl/thbjattr.i }
{ ref/gds-attr.i }
{ str/temp_upd.i }

define temp-table tt-gds-list no-undo like ub.goods
field nn as integer
index by-nn nn
index by_gds-code gds-code
.

define temp-table tt-goods no-undo
field artic as character 
field gds-name as character
.

&global-define store-type v-cntxt-obj-type
&global-define store-code v-cntxt-obj-code

&SCOP upd-md ASSIGN line-mode = ( IF t-doc.status_ = {&permitted} AND pardoc-mode = {&update} THEN {&update} ELSE {&lookup} ).
&SCOP FRAME-NAME         d-inv-doc
&SCOP BROWSE-NAME        br-list
&SCOP open-query-br-list open query {&BROWSE-NAME} for ~
each  ub.doc-line no-lock where ~
      ub.doc-line.doc-code = t-doc.doc-code ~{&dif-cond}, ~
first tt-goods no-lock where ~
      tt-goods.artic     = ub.doc-line.artic     

&SCOP label-clmn_1-br-list  'К'
&SCOP clmn_1-br-list        fncgele( buffer ub.doc-line )
&SCOP label-clmn_2-br-list  'Ш'
&SCOP clmn_2-br-list        if ub.doc-line.prt-OK then '*' else ''
&SCOP label-clmn_3-br-list  'Артикул'
&SCOP clmn_3-br-list        ub.doc-line.artic
&SCOP label-clmn_4-br-list  'Имя '
&SCOP clmn_4-br-list        tt-goods.gds-name
&SCOP label-clmn_5-br-list  'Стало'
&SCOP clmn_5-br-list        ub.doc-line.doc-qnty

&SCOP NUM-LOCKED-COLUMNS-br-list 3
&SCOP disp-list ~
 {&clmn_1-br-list}   @ inv-mark              column-label {&label-clmn_1-br-list} format "x(1)":U ~
 {&clmn_2-br-list}   @ prt-mark              column-label {&label-clmn_2-br-list} format "x(1)":U ~
 {&clmn_3-br-list}                           column-label {&label-clmn_3-br-list}  format "x(38)":U ~
 {&clmn_4-br-list}                           column-label {&label-clmn_4-br-list} format "x(150)":U ~
 {&clmn_5-br-list}                           column-label {&label-clmn_5-br-list} ~


/* ***************************  Definitions  ************************** */
define buffer t-doc      for ub.trn-doc.
define buffer cli-buf    for ub.clients.  /* для gds-list.i */
define buffer l-doc-line for ub.doc-line.
define buffer bf_sysconf for ub.sysconf.

define rectangle rect-trn-doc size 68.5 by 2.5 EDGE-PIXELS 2 GRAPHIC-EDGE bgcolor 8.
define rectangle rect-inv-doc size 47.0 by 4.2 EDGE-PIXELS 2 GRAPHIC-EDGE bgcolor 8.
define rectangle rect-tog     size 21.5 by 4.2 EDGE-PIXELS 2 GRAPHIC-EDGE bgcolor 8.
define variable v-inv-prsr                          as character no-undo .

define variable v-long-char as longchar no-undo .

define variable ref-list                            as   character                     no-undo.
define variable unrv-qnty                           as   decimal                       no-undo.
define variable partsvalue                          as   character         initial ?   no-undo.
define variable is-cdinv                            as   character                     no-undo .
define variable vartot-docold                       like ub.trn-doc.tot-doc            no-undo.
define variable vartot-rublold                      like ub.trn-doc.tot-rubl           no-undo.
define variable i-total-doc-line_tot-ovold          like ub.trn-doc.tot-ov             no-undo.
define variable i-total-doc-line_fact-rublold       like ub.trn-doc.fact-rubl          no-undo.
define variable i-total-doc-line_fact-baseold       like ub.trn-doc.fact-base          no-undo.
define variable i-total-doc-line_fact-qntyold       like ub.trn-doc.fact-qnty          no-undo.
define variable i-total-doc-line_doc-qntyold        like ub.trn-doc.doc-qnty           no-undo.
define variable i-total-doc-line_cli-qntyold        like ub.trn-doc.cli-qnty           no-undo.
define variable i-total-parts_fact-baseold          as   decimal                       no-undo.
define variable i-total-parts_fact-rublold          as   decimal                       no-undo.
define variable i-total-parts_fact-qntyold          as   decimal                       no-undo.
define variable varinvclcwtol                       as   logical label "Естественная убыль"
                                                    view-as toggle-box size 20.5 by .77 fgcolor 4 no-undo.
define variable varinvclcasol                       as   logical label "Основные суммы"
                                                    view-as toggle-box size 20.5 by .77 fgcolor 4 no-undo.
define variable varinvclcwt                         as   logical                       no-undo.
define variable varinvclcas                         as   logical                       no-undo.
define variable varinvclcex                         as   logical                       no-undo.
define variable varinvclcms                         as   logical                       no-undo.
define variable varinvclcbef                        as   logical                       no-undo.
define variable varbefore-qnty                      like ub.doc-line.fact-qnty        no-undo.
define variable varwas-qnty-kg                      like ub.doc-line.fact-qnty        no-undo.
define variable varare-qnty-kg                      like ub.doc-line.fact-qnty        no-undo.
define variable vardiff-qnty-kg                     like ub.doc-line.fact-qnty        no-undo.
define variable varextra-qnty                       like ub.doc-line.fact-qnty        no-undo.
define variable varmiss-qnty                        like ub.doc-line.fact-qnty        no-undo.
define variable varbefore-base                      like ub.doc-line.fact-qnty        no-undo.
define variable varbefore-rubl                      like ub.doc-line.fact-qnty        no-undo.
define variable varafter-base                       like ub.doc-line.fact-qnty        no-undo.
define variable varafter-rubl                       like ub.doc-line.fact-qnty        no-undo.
define variable varextra-base                       like ub.doc-line.fact-qnty        no-undo.
define variable varextra-rubl                       like ub.doc-line.fact-qnty        no-undo.
define variable varmiss-base                        like ub.doc-line.fact-qnty        no-undo.
define variable varmiss-rubl                        like ub.doc-line.fact-qnty        no-undo.
define variable varbefore-rb                        like ub.doc-line.fact-qnty        no-undo.
define variable varafter-rb                         like ub.doc-line.fact-qnty        no-undo.
define variable varextra-rb                         like ub.doc-line.fact-qnty        no-undo.
define variable varmiss-rb                          like ub.doc-line.fact-qnty        no-undo.
define variable varwast-rb                          like ub.doc-line.price-base       no-undo.
define variable varunus-wast-rb                     like ub.doc-line.price-base       no-undo.
define variable varr-b                              as   character                     no-undo.
define variable varmiss-without-wast                like ub.doc-line.price-base       no-undo.
define variable varwastage                          like ub.doc-line.price-base       no-undo.
define variable vardocextra-qnty                    like ub.trn-doc.fact-qnty          no-undo.
define variable vardocextra-base                    like ub.trn-doc.tot-rubl           no-undo.
define variable vardocextra-rubl                    like ub.trn-doc.tot-rubl           no-undo.
define variable vardocextra-rb                      like ub.trn-doc.tot-rubl           no-undo.
define variable vardocmiss-qnty                     like ub.trn-doc.fact-qnty          no-undo.
define variable vardocmiss-base                     like ub.trn-doc.tot-rubl           no-undo.
define variable vardocmiss-rubl                     like ub.trn-doc.tot-rubl           no-undo.
define variable vardocmiss-rb                       like ub.trn-doc.tot-rubl           no-undo.
define variable vardocwast-rb                       like ub.trn-doc.tot-rubl           no-undo.
define variable var-qnty-mark                       as   integer                       no-undo.
define variable var-qnty-mark-chk                   as   integer                       no-undo.
define variable var-qnty-mark-tech                  as   integer                       no-undo.
define variable varinvclcspvalue                    as   character                     no-undo.
define variable varinvclcsptype                     as   character                     no-undo.
define variable prtvalue                            as   character                     no-undo.
define variable varcount                            as   integer                       no-undo.
define variable vartime                             as   integer                       no-undo.
define variable prt-rec                             as   recid                         no-undo.
define variable ref-rec                             as   recid                         no-undo.
define variable varlog                              as   logical                       no-undo.
define variable lns-cnt                             as   integer                       no-undo.
define variable line-mode                           as   character                     no-undo.
define variable varvalue                            as   character                     no-undo.
define variable gds-rec                             as   recid                         no-undo.
define variable v-is-ptrl                           as   character                     no-undo.
define variable v-data-type                         as   character                     no-undo.
define variable parext-doc-mode                     as   character                     no-undo.
define variable chk-doc-option                      as   character                     no-undo.
define variable v-handl-tt                          as   handle                        no-undo.
define variable v-marking-type                      as   character                     no-undo.
define variable v-type                              as   character                     no-undo.
define variable v-is-marking                        as   logical                       no-undo init false.
define variable v-is-introduce                      as   logical                       no-undo init false.
define variable bcol                                as   handle                        extent no-undo.
define variable hBrowse                             as   handle                        no-undo.
define variable ii                                  as   integer                       no-undo.

{ gbl/objsrv.i }



/*----------------------------FUNCTIONS---------------------------------*/
function fncgele returns character ( buffer local-doc-line for ub.doc-line ) :
  if local-doc-line.prt-OK = ? then do:
    return ''.
  end.
  else do:
    if local-doc-line.fact-qnty < 0 then do:
      return '<'.
    end.
    else do:
      if local-doc-line.fact-qnty = 0 then do:
        return '='.
      end.
      else do:
        return '>'.
      end.
    end.
  end.
end function.

function fncextra-qnty returns decimal ( buffer local-doc-line for ub.doc-line ) :
  if local-doc-line.fact-qnty > 0 then do:
    return local-doc-line.fact-qnty.
  end.
  else do:
    return 0.00.
  end.
end function.

function fncmiss-qnty returns decimal ( buffer local-doc-line for ub.doc-line ) :
  if local-doc-line.fact-qnty < 0 then do:
    return - local-doc-line.fact-qnty.
  end.
  else do:
    return 0.00.
  end.
end function.

function fncbefore-base returns decimal ( buffer local-doc-line for ub.doc-line,
                                          buffer local-goods for ub.goods ) :
  define variable varreturn as decimal no-undo.

  define buffer bf_doc-line-sum for ub.doc-line-sum.

  if varinvclcbef = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = {&sum-before-doc}.
    assign
      varreturn = bf_doc-line-sum.cost-sum-base
    .
  end.
  else do:
    assign
      varreturn = ?
    .
  end.
  return varreturn.
end function.

function fncbefore-rubl returns decimal ( buffer local-doc-line for ub.doc-line,
                                          buffer local-goods for ub.goods ) :
  define variable varreturn as decimal no-undo.

  define buffer bf_doc-line-sum for ub.doc-line-sum.

  if varinvclcbef = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = {&sum-before-doc}.
    assign
      varreturn = bf_doc-line-sum.cost-sum-rubl
    .
  end.
  else do:
    assign
      varreturn = ?
    .
  end.
  return varreturn.
end function.

function fncafter-base returns decimal ( buffer local-doc-line for ub.doc-line,
                                         buffer local-goods for ub.goods ) :
  define buffer bf_doc-line-sum for ub.doc-line-sum.

  if varinvclcas = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = {&sum-after-doc}.
    return bf_doc-line-sum.cost-sum-base.
  end.
  else do:
    return ?.
  end.
end function.

function fncafter-rubl returns decimal ( buffer local-doc-line for ub.doc-line,
                                         buffer local-goods for ub.goods ) :
  define buffer bf_doc-line-sum for ub.doc-line-sum.

  if varinvclcas = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = {&sum-after-doc}.
    return bf_doc-line-sum.cost-sum-rubl.
  end.
  else do:
    return ?.
  end.
end function.

function fncextra-base returns decimal ( buffer local-doc-line for ub.doc-line,
                                         buffer local-goods for ub.goods ) :
  define buffer bf_doc-line-sum for ub.doc-line-sum.

  if varinvclcas = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = {&sum-general-doc}.
    if bf_doc-line-sum.cost-sum-base > 0 then do:
      return bf_doc-line-sum.cost-sum-base.
    end.
    else do:
      return 0.00.
    end.
  end.
  else do:
    return ?.
  end.
end function.

function fncextra-rubl returns decimal ( buffer local-doc-line for ub.doc-line,
                                         buffer local-goods for ub.goods ) :
  define buffer bf_doc-line-sum for ub.doc-line-sum.

  if varinvclcas = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = {&sum-general-doc}.
    if bf_doc-line-sum.cost-sum-rubl > 0 then do:
      return bf_doc-line-sum.cost-sum-rubl.
    end.
    else do:
      return 0.00.
    end.
  end.
  else do:
    return ?.
  end.
end function.

function fncmiss-base returns decimal ( buffer local-doc-line for ub.doc-line,
                                        buffer local-goods for ub.goods ) :
  define buffer bf_doc-line-sum for ub.doc-line-sum.

  if varinvclcas = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = {&sum-general-doc}.
    if bf_doc-line-sum.cost-sum-base < 0 then do:
      return - bf_doc-line-sum.cost-sum-base.
    end.
    else do:
      return 0.00.
    end.
  end.
  else do:
    return ?.
  end.
end function.

function fncmiss-rubl returns decimal ( buffer local-doc-line for ub.doc-line,
                                        buffer local-goods for ub.goods ) :
  define buffer bf_doc-line-sum for ub.doc-line-sum.

  if varinvclcas = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = {&sum-general-doc}.
    if bf_doc-line-sum.cost-sum-rubl < 0 then do:
      return - bf_doc-line-sum.cost-sum-rubl.
    end.
    else do:
      return 0.00.
    end.
  end.
  else do:
    return ?.
  end.
end function.

function fncbefore-rb returns decimal ( buffer local-doc-line for ub.doc-line,
                                        buffer local-goods for ub.goods ) :
  define buffer bf_doc-line-sum for ub.doc-line-sum.

  if varinvclcbef = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = {&sum-before-doc}         no-error.
    if varr-b = "base":U then do:
      return bf_doc-line-sum.crsa-sum-base.
    end.
    else do:
      return bf_doc-line-sum.crsa-sum-rubl.
    end.
  end.
  else do:
    return ?.
  end.
end function.

function fncafter-rb returns decimal ( buffer local-doc-line for ub.doc-line,
                                       buffer local-goods for ub.goods ) :
  define buffer bf-aft_doc-line-sum for ub.doc-line-sum.
  define buffer bf-bef_doc-line-sum for ub.doc-line-sum.
  define buffer bf-gen_doc-line-sum for ub.doc-line-sum.
  define buffer bf_trn-doc          for ub.trn-doc.

  if varinvclcas = yes then do:
    find first bf_trn-doc no-lock where bf_trn-doc.doc-code = local-doc-line.doc-code.
    if bf_trn-doc.status_ = {&fact} then do:
      find first bf-aft_doc-line-sum no-lock where
                 bf-aft_doc-line-sum.doc-code = local-doc-line.doc-code and
                 bf-aft_doc-line-sum.gds-code = local-goods.gds-code and
                 bf-aft_doc-line-sum.sum-type = {&sum-after-doc}.
      if varr-b = "base" then do:
        return bf-aft_doc-line-sum.crsa-sum-base.
      end.
      else do:
        return bf-aft_doc-line-sum.crsa-sum-rubl.
      end.
    end.
    else do:
      find first bf-bef_doc-line-sum no-lock where
                 bf-bef_doc-line-sum.doc-code = local-doc-line.doc-code and
                 bf-bef_doc-line-sum.gds-code = local-goods.gds-code and
                 bf-bef_doc-line-sum.sum-type = {&sum-before-doc}.
      find first bf-gen_doc-line-sum no-lock where
                 bf-gen_doc-line-sum.doc-code = local-doc-line.doc-code and
                 bf-gen_doc-line-sum.gds-code = local-goods.gds-code and
                 bf-gen_doc-line-sum.sum-type = {&sum-general-doc}.
      if varr-b = "base" then do:
        return bf-bef_doc-line-sum.crsa-sum-base + bf-gen_doc-line-sum.sale-sum-base.
      end.
      else do:
        return bf-bef_doc-line-sum.crsa-sum-rubl + bf-gen_doc-line-sum.sale-sum-rubl.
      end.
    end.
  end.
  else do:
    return ?.
  end.
end function. /* fncafter-rb */

function fncextra-rb returns decimal ( buffer local-doc-line for ub.doc-line,
                                       buffer local-goods for ub.goods ) :
  define buffer bf_doc-line-sum for ub.doc-line-sum.

  if varinvclcas = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = {&sum-general-doc}.
    if varr-b = "base" then do:
      if bf_doc-line-sum.sale-sum-base > 0 then do:
        return bf_doc-line-sum.sale-sum-base.
      end.
      else do:
        return 0.00.
      end.
    end.
    else do:
      if bf_doc-line-sum.sale-sum-rubl > 0 then do:
        return bf_doc-line-sum.sale-sum-rubl.
      end.
      else do:
        return 0.00.
      end.
    end.
  end.
  else do:
    return ?.
  end.
end function.

function fncmiss-rb returns decimal ( buffer local-doc-line for ub.doc-line,
                                      buffer local-goods for ub.goods ) :
  define buffer bf_doc-line-sum for ub.doc-line-sum.

  if varinvclcas = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = {&sum-general-doc}.
    if varr-b = "base" then do:
      if bf_doc-line-sum.sale-sum-base < 0 then do:
        return - bf_doc-line-sum.sale-sum-base.
      end.
      else do:
        return 0.00.
      end.
    end.
    else do:
      if bf_doc-line-sum.sale-sum-rubl < 0 then do:
        return - bf_doc-line-sum.sale-sum-rubl.
      end.
      else do:
        return 0.00.
      end.
    end.
  end.
  else do:
    return ?.
  end.
end function.

function fncmiss-without-wastage returns decimal ( buffer local-doc-line for ub.doc-line,
                                                   buffer local-goods for ub.goods ) :
  define buffer bf-gen_doc-line-sum  for ub.doc-line-sum.
  define buffer bf-wst_doc-line-sum  for ub.doc-line-sum.

  if varinvclcwt = yes and
     varinvclcas = yes then do:
    find first bf-gen_doc-line-sum no-lock where
               bf-gen_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf-gen_doc-line-sum.gds-code = local-goods.gds-code and
               bf-gen_doc-line-sum.sum-type = {&sum-general-doc}.
    find first bf-wst_doc-line-sum no-lock where
               bf-wst_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf-wst_doc-line-sum.gds-code = local-goods.gds-code and
               bf-wst_doc-line-sum.sum-type = {&sum-wastage-doc}.
    if varr-b = "base" then do:
      if bf-gen_doc-line-sum.sale-sum-base < 0 then do:
        if bf-wst_doc-line-sum.sale-sum-base >= - bf-gen_doc-line-sum.sale-sum-base then do:
          return 0.00.
        end.
        else do:
          return ( - ( bf-gen_doc-line-sum.sale-sum-base + bf-wst_doc-line-sum.sale-sum-base ) ).
        end.
      end.
      else do:
        return 0.00.
      end.
    end.
    else do:
      if bf-gen_doc-line-sum.sale-sum-rubl < 0 then do:
        if bf-wst_doc-line-sum.sale-sum-rubl >= - bf-gen_doc-line-sum.sale-sum-rubl then do:
          return 0.00.
        end.
        else do:
          return ( - ( bf-gen_doc-line-sum.sale-sum-rubl + bf-wst_doc-line-sum.sale-sum-rubl ) ).
        end.
      end.
      else do:
        return 0.00.
      end.
    end.
  end.
  else do:
    return ?.
  end.
end function. /* fncmiss-without-wastage */

function fncwastage returns decimal ( buffer local-doc-line for ub.doc-line,
                                      buffer local-goods for ub.goods ) :
  define buffer bf_doc-line-sum      for ub.doc-line-sum.
  define buffer bf-wst_doc-line-sum  for ub.doc-line-sum.

  if varinvclcas = yes and
     varinvclcwt = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = {&sum-general-doc}.
    find first bf-wst_doc-line-sum no-lock where
               bf-wst_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf-wst_doc-line-sum.gds-code = local-goods.gds-code and
               bf-wst_doc-line-sum.sum-type = {&sum-wastage-doc}.
    if bf_doc-line-sum.sale-sum-base < 0 then do:
      if varr-b = "base" then do:
        if bf-wst_doc-line-sum.sale-sum-base > - bf_doc-line-sum.sale-sum-base then do:
          return - bf_doc-line-sum.sale-sum-base.
        end.
        else do:
          return bf-wst_doc-line-sum.sale-sum-base.
        end.
      end.
      else do:
        if bf-wst_doc-line-sum.sale-sum-rubl > - bf_doc-line-sum.sale-sum-rubl then do:
          return - bf_doc-line-sum.sale-sum-rubl.
        end.
        else do:
          return bf-wst_doc-line-sum.sale-sum-rubl.
        end.
      end.
    end.
    else do:
      return 0.00.
    end.
  end.
end function. /* fncwastage */

function fncnode-name returns character ( buffer local-doc-line for ub.doc-line ) :
  return  '-' .
end function.

function fncwast-rb returns decimal ( buffer local-doc-line for ub.doc-line,
                                      buffer local-goods for ub.goods ) :
  define buffer bf-wst_doc-line-sum for ub.doc-line-sum.

  if varinvclcwt = yes then do:
    find first bf-wst_doc-line-sum no-lock where
               bf-wst_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf-wst_doc-line-sum.gds-code = local-goods.gds-code and
               bf-wst_doc-line-sum.sum-type = {&sum-wastage-doc}.
    if varr-b = "base" then do:
      return bf-wst_doc-line-sum.sale-sum-base.
    end.
    else do:
      return bf-wst_doc-line-sum.sale-sum-rubl.
    end.
  end.
  else do:
    return ?.
  end.
end function.

function fncunus-wast-rb returns decimal ( buffer local-doc-line for ub.doc-line,
                                           buffer local-goods for ub.goods ) :
  define buffer bf_doc-line-sum     for ub.doc-line-sum.
  define buffer bf-wst_doc-line-sum for ub.doc-line-sum.

  if varinvclcas = yes and
     varinvclcwt = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = {&sum-general-doc}.
    find first bf-wst_doc-line-sum no-lock where
               bf-wst_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf-wst_doc-line-sum.gds-code = local-goods.gds-code and
               bf-wst_doc-line-sum.sum-type = {&sum-wastage-doc}.
    if varr-b = "base" then do:
      if bf_doc-line-sum.sale-sum-base < 0 then do:
          if bf-wst_doc-line-sum.sale-sum-base < abs(bf_doc-line-sum.sale-sum-base) then do:
            return 0.00.
          end.
          else do:
            return bf-wst_doc-line-sum.sale-sum-base - abs(bf_doc-line-sum.sale-sum-base).
          end.
      end.
      else do:
          return bf-wst_doc-line-sum.sale-sum-base.
      end.
    end.
    else do:
      if bf_doc-line-sum.sale-sum-rubl < 0 then do:
          if bf-wst_doc-line-sum.sale-sum-rubl < abs(bf_doc-line-sum.sale-sum-rubl) then do:
            return 0.00.
          end.
          else do:
            return bf-wst_doc-line-sum.sale-sum-rubl - abs(bf_doc-line-sum.sale-sum-rubl).
          end.
      end.
      else do:
          return bf-wst_doc-line-sum.sale-sum-rubl.
      end.
    end.
  end.
  else do:
    return ?.
  end.
end function. /* fncunus-wast-rb */

function fncwasqntykg returns decimal ( buffer local-doc-line for ub.doc-line ) :
  define variable d_out-qnty-kg as decimal no-undo.

  run inv-line_qnty in this-procedure ( input recid( local-doc-line ), input "was",  output d_out-qnty-kg ) no-error.
  return ( if error-status :error then ? else d_out-qnty-kg ).
end function.

function fncareqntykg returns decimal ( buffer local-doc-line for ub.doc-line ) :
  define variable d_out-qnty-kg as decimal no-undo.

  run inv-line_qnty in this-procedure ( input recid( local-doc-line ), input "are",  output d_out-qnty-kg ) no-error.
  return ( if error-status :error then ? else d_out-qnty-kg ).
end function.

function fncdiffqntykg returns decimal ( buffer local-doc-line for ub.doc-line ) :
  define variable d_out-qnty-kg as decimal no-undo.

  run inv-line_qnty in this-procedure ( input recid( local-doc-line ), input "diff", output d_out-qnty-kg ) no-error.
  return ( if error-status :error then ? else d_out-qnty-kg ).
end function.

function markqnty returns integer ( buffer local-doc-line for ub.doc-line ) :
  define variable ii as integer no-undo.
  define buffer buf_marking-lines for ub.marking-lines.
  define buffer buf_marking for ub.marking.
  define buffer buf_gds for ub.goods.
  if v-is-marking = false
    then return 0.
  
  find first buf_gds no-lock where buf_gds.artic = local-doc-line.artic
    and buf_gds.prod-type = local-doc-line.prod-type
    and buf_gds.prod-code = local-doc-line.prod-code.
  
  for each buf_marking-lines where buf_marking-lines.obj-type = local-doc-line.obj-type and buf_marking-lines.obj-code = local-doc-line.obj-code
    and buf_marking-lines.gds-code = buf_gds.gds-code and buf_marking-lines.out-code = {&free-code} and not buf_marking-lines.mark begins {&tech-mark-prefix}
    :
    if not can-find (first ub.marking where ub.marking.mark = buf_marking-lines.mark and ub.marking.unit-ext = "UNIT")
    then next.
      
    ii = ii + 1.
  end.
  return ii.
  
end function.

function markqntytech returns integer ( buffer local-doc-line for ub.doc-line ) :
  define variable ii as integer no-undo.
  define buffer buf_marking-lines for ub.marking-lines.
  define buffer buf_marking for ub.marking.
  define buffer buf_gds for ub.goods.
  if v-is-marking = false
    then return 0.
  
  find first buf_gds no-lock where buf_gds.artic = local-doc-line.artic
    and buf_gds.prod-type = local-doc-line.prod-type
    and buf_gds.prod-code = local-doc-line.prod-code.
  
  for each buf_marking-lines where buf_marking-lines.obj-type = local-doc-line.obj-type and buf_marking-lines.obj-code = local-doc-line.obj-code
    and buf_marking-lines.gds-code = buf_gds.gds-code and buf_marking-lines.out-code = {&free-code} and buf_marking-lines.mark begins {&tech-mark-prefix}
    :
    if not can-find (first ub.marking where ub.marking.mark = buf_marking-lines.mark and ub.marking.unit-ext = "UNIT")
    then next.
      
    ii = ii + 1.
  end.
  return ii.

end function.

function markqntycheckinv returns integer ( buffer local-doc-line for ub.doc-line ) :
  define variable ii as integer no-undo.  
  run procmarkqntycheckinv (buffer local-doc-line, output ii).
  return ii.
end function.

procedure procmarkqntycheckinv:

  define parameter buffer local-doc-line for ub.doc-line.
  define output parameter ii as integer no-undo.
  define buffer buf_marking-lines for ub.marking-lines.
  define buffer buf_marking for ub.marking.
  define buffer buf_gds for ub.goods.
  define buffer buf_utd-marking-lines for ub.utd-marking-lines.
  
  if v-is-marking = false
    then ii = 0.
  find first buf_gds no-lock where buf_gds.artic = local-doc-line.artic
    and buf_gds.prod-type = local-doc-line.prod-type
    and buf_gds.prod-code = local-doc-line.prod-code.
  
  for each ub.marking-attr no-lock where (    ub.marking-attr.attr-code = "inv-doc" 
                                          and ub.marking-attr.attr-value = ub.doc-line.doc-code)
                                     or  (    ub.marking-attr.attr-code = "inv-doc-scan"  
                                          and ub.marking-attr.attr-value = ub.doc-line.doc-code ):
    if not can-find (first ub.marking no-lock where ub.marking.mark = ub.marking-attr.mark and ub.marking.unit-ext = "UNIT" and ub.marking.gds-code = buf_gds.gds-code) 
      then next.
    ii = ii + 1.
  end.
  for each ub.utd no-lock where ub.utd.doc-code = local-doc-line.doc-code:
    for each ub.utd-marking-lines no-lock where (    ub.utd-marking-lines.doc-id = ub.utd.doc-id 
                                                 and ub.utd-marking-lines.db-num = ub.utd.db-num 
                                                 and ub.utd-marking-lines.gds-code = buf_gds.gds-code
                                                 and ub.utd-marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:PendingVerification:KeyIntDB )
                                             or (    ub.utd-marking-lines.doc-id = ub.utd.doc-id 
                                                 and ub.utd-marking-lines.db-num = ub.utd.db-num 
                                                 and ub.utd-marking-lines.gds-code = buf_gds.gds-code
                                                 and ub.utd-marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB):
      for each ub.marking no-lock where ub.marking.mark = ub.utd-marking-lines.mark.
        if can-find (buf_utd-marking-lines where 
              buf_utd-marking-lines.doc-id = ub.utd.doc-id and buf_utd-marking-lines.db-num = ub.utd.db-num and buf_utd-marking-lines.mark = ub.marking.mark-parent
            )
          then next.
        ii = ii + ub.marking.box-qnty.
      end.
    end.
  end.

end.

/* ***********************  Control Definitions  ********************** */
define button b-inv-prsrt
     label "ИПерср":l
     tooltip "Итоги по колонке пересортице"
     size 9 by 1.

define button b-notes
     label "При&м":l
     size 9 by 1.

define button b-add
     label "&Добав":l
     size 9 by 1.

define button b-arch
     label "Уч&ет"
     size 9 by 1.

define button b-cnt
     label "&ДогП":l
     size 9 by 1.

define button b-clr
     label "С&брос":l
     size 9 by 1.

define button b-st
     label "&Восст":l
     size 9 by 1.

define button b-parts-
     label "&Партии-":l
     size 9 by 1.

define button b-updprt-
     label "&РедПарт-":l
     size 9 by 1.

define button b-del
     label "&Удал":l
     size 9 by 1.

define button b-exit auto-go
     label "&Выход ":l
     size 9 by 1.

define button b-help
     label "Помо&щь":l
     size 9 by 1.

define button b-chg
     label "&Измен":l
     size 9 by 1.

define button b-parts
     label "Па&ртии":l
     size 9 by 1.

define button b-chk-doc
     label "&Чеки":l
     size 9 by 1.

define button b-list
     label "&Список":l
     size 9 by 1.

define button b-lkp
     label "&Просм":l
     size 9 by 1.

define button b-sum-doc
     label "&СумДок":l
     size 9 by 1.

define button b-sum-goods
     label "&СумТов":l
     size 9 by 1.

define button b-history
     label "Ис&тор":l
     size 9 by 1.

define button b-unscn
     label "Файлы":l
     size 9 by 1.

define button b-next auto-go
     label "&>>":l
     size 4.5 by 1
     bgcolor 8 .

define button b-prev auto-go
     label "&<<":l
     size 4.5 by 1
     bgcolor 8 .

define button b-marks
     label "Марки":l
     size 9 by 1.

define button r-agnt
     image-up          file "btn-down-arrow"
     image-down        file "btn-down-arrow"
     image-insensitive file "btn-down-arrow"
     size 3 by .88.

define button r-sht
     image-up          file "btn-down-arrow":u
     image-down        file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     size 3 by .88.

define button r-boss like r-agnt.
define button r-wrkr like r-agnt.
define button r-reas like r-agnt.

define menu m-clr
    menu-item m-clr-1   label "Текущей строки"          accelerator "alt-1"
    menu-item m-clr-2   label "Всех строк"              accelerator "alt-2"
    menu-item m-clr-3   label "Нередактированных строк" accelerator "alt-3".

define menu m-parts-
    menu-item m-parts-1 label "Текущей строки"          accelerator "alt-1"
    menu-item m-parts-2 label "Всех строк"              accelerator "alt-2".

define menu m-st
    menu-item m-st-1    label "Текущей строки"          accelerator "alt-1"
    menu-item m-st-2    label "Всех строк"              accelerator "alt-2"
    menu-item m-st-3    label "Нулевых строк"           accelerator "alt-3".

DEFINE MENU m-chk-doc
      MENU-ITEM m-chk-docs        LABEL "Список чеков по документу"     ACCELERATOR "ALT-1"
      MENU-ITEM m-chk-doc-add     LABEL "Добавить из чеков"  ACCELERATOR "ALT-2"
      MENU-ITEM m-chk-gds         LABEL "Строки"  ACCELERATOR "ALT-3"
      .

define menu m-marks 
  menu-item m_add-marks           label "Добавить"      
  menu-item m_introduce-marks     label "Установить флаг первоначального ввода".
  menu-item m_lookup              label "Просмотр".

define variable agnt-name as character format "x(256)":U
      view-as text
     size 10 by 1 no-undo.

define variable boss-name as character format "x(256)":U
      view-as text
     size 10 by 1 no-undo.

define variable wrkr-name as character format "x(256)":U
      view-as text
     size 10 by 1 no-undo.

define variable rsn-name as character no-undo format "x(256)":U view-as fill-in size 60.5 by .88 fgcolor 4.

define variable loc-art  as character format "x(16)" view-as fill-in size 20 by 1 fgcolor 12 no-undo.
define variable loc-name as character view-as fill-in size 20 by 1 fgcolor 12 no-undo.
define variable loc-code as character view-as fill-in size 20 by 1 fgcolor 12 no-undo.

define variable a-n-c as character view-as radio-set horizontal radio-buttons
"&А","art",
"&Н","name",
"&К","code"
size 12 by 1 no-undo.

define variable dif-only as character view-as radio-set vertical radio-buttons
"Все&.", "all":u,
"И&зл", "surplus":u,
"Нед&", "shortage":u,
"Со&в", "coincidence":u,
"Ма&р", "markseqdocqnty":u
size 7 by 4 no-undo.

define variable prt-mark as   character            no-undo. /* символ в колонке Ш */
define variable inv-mark as   character            no-undo. /* символ в колонке К */
define variable scl-name like ub.gds-prt.node-name no-undo. /* название шкалы в browse */

/* При запросе без join возможно indexed-reposition. Но progress оптимизирует запрос по полям,
   что делает невозможным использование функций в display запроса. При определении query нужно
   сказать - использовать все поля. EXCEPT <ничего> эквивалентно FIELDS <все поля> */
define query {&BROWSE-NAME} for ub.doc-line except ,tt-goods except
/* FIELDS() */
.
define browse {&BROWSE-NAME} query {&BROWSE-NAME} no-lock display
    {&disp-list}
    with size 97 by 10.5 separators.

/* ************************  Frame Definitions  *********************** */

define variable fi-val-header as character format "x(5)":U initial " ВАЛ "
     view-as fill-in
     size 5.9 by 0.60
     bgcolor cyan_color fgcolor white_color .

DEFINE VARIABLE invTSD AS LOGICAL INITIAL no 
     LABEL "ИНУ" 
     VIEW-AS TOGGLE-BOX
     SIZE 13.4 BY .81 NO-UNDO.
     
define variable fi-rub-header as character format "x(5)":U initial " {&abbr_rub_allshift} "
     view-as fill-in
     size 5.9 by 0.60
     bgcolor cyan_color fgcolor white_color .

define variable fi-izlishki-header as character format "x(9)":U initial " ИЗЛИШКИ "
     view-as fill-in
     size 9.9 by 0.60
     bgcolor cyan_color fgcolor white_color .

define variable fi-nedostacha-header as character format "x(11)":U initial " НЕДОСТАЧА "
     view-as fill-in
     size 11.9 by 0.60
     bgcolor cyan_color fgcolor white_color .

define variable fi-raschet-header as character format "x(20)":U initial "РАСЧЁТ ПРИ ИЗМЕНЕНИИ"
     view-as fill-in
     size 20.9 by 0.60
     bgcolor cyan_color fgcolor white_color .


define frame {&FRAME-NAME}
  b-exit                       at row 1   col 1
  b-prev                       at row 1   col 10
  b-next                       at row 1   col 14.5
  b-add                        at row 1   col 19
  b-lkp                        at row 1   col 28
  b-chg                        at row 1   col 37
  b-clr                        at row 1   col 46
  b-st                         at row 1   col 55
  b-del                        at row 1   col 64
  b-cnt                        at row 1   col 73
  b-chk-doc                    at row 1   col 82
  b-help                       at row 1   col 91
  b-sum-doc                    at row 2   col 1
  b-sum-goods                  at row 2   col 10
  b-arch                       at row 2   col 19
  b-list                       at row 2   col 28
  b-unscn                      at row 2   col 37
  b-notes                      at row 2   col 46
  b-parts-                     at row 2   col 64
  b-updprt-                    at row 2   col 73
  b-parts                      at row 2   col 82
  b-history                    at row 2   col 91
  t-doc.doc-date AT ROW 3 COL 7 COLON-ALIGNED
    VIEW-AS FILL-IN
    SIZE 9 BY .88
    FGCOLOR 4
  t-doc.fact-date AT ROW 3 COL 22.25 COLON-ALIGNED
    VIEW-AS FILL-IN
    SIZE 9 BY .88
    FGCOLOR 4
  t-doc.shift-date AT ROW 3 COL 38.25 COLON-ALIGNED
    LABEL "&Смена"
    VIEW-AS FILL-IN
    SIZE 9 BY .88
    FGCOLOR 4
  t-doc.shift-name AT ROW 3 COL 50.38 COLON-ALIGNED
    LABEL "&№"
    VIEW-AS FILL-IN
    SIZE 3 BY .88 TOOLTIP "Номер смены"
    FGCOLOR 4
  t-doc.shift-num AT ROW 3 COL 56.5 COLON-ALIGNED
    LABEL "П"
    VIEW-AS FILL-IN
    SIZE 3 BY .88 TOOLTIP "Порядок смен"
    FGCOLOR 4
  r-sht AT ROW 3 COL 61.5
  rect-trn-doc                 at row 4.2 col 1
  rect-inv-doc                 at row 6.7 col 1
  rect-tog                     at row 6.7 col 48
  fi-val-header                at row 4   col 15                 no-label
  invTSD                       AT ROW 3.14 COL 70                WIDGET-ID 2
  fi-rub-header                at row 4   col 33                 no-label
  t-doc.tot-doc                at row 4.6 col 7    colon-aligned    label "Прод."                 view-as fill-in    size 17 by 1.00 fgcolor 4
  t-doc.tot-rubl               at row 4.6 col 24   colon-aligned no-label                         view-as fill-in    size 17 by 1.00 fgcolor 4
  t-doc.fact-base              at row 5.5 col 7    colon-aligned    label "Учет."                 view-as fill-in    size 17 by 1.00 fgcolor 4
  t-doc.fact-rubl              at row 5.5 col 24   colon-aligned no-label                         view-as fill-in    size 17 by 1.00 fgcolor 4
  t-doc.doc-qnty               at row 4.6 col 48   colon-aligned    label "Было "                 view-as fill-in    size 15 by 1.00 fgcolor 4
  t-doc.fact-qnty              at row 5.5 col 48   colon-aligned    label "Разн."                 view-as fill-in    size 15 by 1.00 fgcolor 4
  fi-izlishki-header           at row 6.4 col 19                 no-label
  vardocextra-qnty             at row 7   col 14   colon-aligned    label "Количество  "          view-as fill-in    size 15 by 1.00 fgcolor 4
  vardocextra-base             at row 8.8 col 14   colon-aligned    label "Учетные(вал)"          view-as fill-in    size 15 by 1.00 fgcolor 4
  vardocextra-rubl             at row 7.9 col 14   colon-aligned    label "Учетные({&abbr_rub})"  view-as fill-in    size 15 by 1.00 fgcolor 4
  vardocextra-rb               at row 9.7 col 14   colon-aligned    label "Продажные   "          view-as fill-in    size 15 by 1.00 fgcolor 4
  fi-nedostacha-header         at row 6.4 col 34                 no-label
  vardocmiss-qnty              at row 7   col 30   colon-aligned no-label                         view-as fill-in    size 15 by 1.00 fgcolor 4
  vardocmiss-base              at row 8.8 col 30   colon-aligned no-label                         view-as fill-in    size 15 by 1.00 fgcolor 4
  vardocmiss-rubl              at row 7.9 col 30   colon-aligned no-label                         view-as fill-in    size 15 by 1.00 fgcolor 4
  vardocmiss-rb                at row 9.7 col 30   colon-aligned no-label                         view-as fill-in    size 15 by 1.00 fgcolor 4
  vardocwast-rb                at row 8.5 col 80   colon-aligned    label "Фонд е.у."             view-as fill-in    size 15 by 1.00 fgcolor 4
  t-doc.re-grading-parts-minus at row 9.5 col 68   colon-aligned    label "Пересорт.отриц.партий" view-as toggle-box size 24 by 0.77 fgcolor 4

  fi-raschet-header            at row 6.4 col 48.3               no-label
  varinvclcwtol                at row 8.2 col 46.5 colon-aligned
  varinvclcasol                at row 9.4 col 46.5 colon-aligned
  t-doc.wrkr                   at row 4   col 75   colon-aligned no-label                         view-as fill-in    size 10 by 1.00 format "999999999":U
  wrkr-name                    at row 4   col 85.5 colon-aligned no-label                                                            fgcolor 4
  r-wrkr                       at row 4   col 96                 no-label
  t-doc.agnt                   at row 5   col 75   colon-aligned no-label                         view-as fill-in    size 10 by 1.00 format "999999999":U
  agnt-name                    at row 5   col 85.5 colon-aligned no-label                                                            fgcolor 4
  r-agnt                       at row 5   col 96                 no-label
  t-doc.boss                   at row 6   col 75   colon-aligned no-label                         view-as fill-in    size 10 by 1.00 format "999999999":U
  boss-name                    at row 6   col 85.5 colon-aligned no-label                                                            fgcolor 4
  r-boss                       at row 6   col 96                 no-label
  t-doc.reason-code            at row 11  col 8   colon-aligned    label "Осн.д."   view-as fill-in    size 3 by  .88 format ">>9":U
  r-reas                       at row 11  col 14
  b-marks                      at row 2   col 55 
  rsn-name                     at row 11  col 18                 no-label
  {&BROWSE-NAME}               at row 12  col 1.5
  dif-only                     at row 4   col 68   colon-aligned no-label
  a-n-c                        at row 10.2  col 80                 no-label
  loc-art                      at row 11  col 76   colon-aligned    label "Начало артикула"
  loc-name                     at row 11  col 76   colon-aligned    label "Начало названия"                                          format "x(40)":U
  loc-code                     at row 11  col 76   colon-aligned    label "Бар-код (весь)"                                           format "x(13)":U
  b-inv-prsrt                  at row 2   col 91
  space( 0 ) skip( 0 )
with view-as dialog-box keep-tab-order
     side-labels no-underline three-d scrollable
     default-button b-exit.

/* ***************  runtime attributes and uib settings  ************** */

assign 
  b-marks:popup-menu in frame {&frame-name} = menu m-marks:handle.
assign 
  b-marks:menu-mouse = 1.

assign
  frame {&FRAME-NAME} :scrollable                    = false
  {&BROWSE-NAME} :num-locked-columns in frame {&FRAME-NAME} = {&num-locked-columns-br-list}
  b-clr    :popup-menu in frame {&FRAME-NAME}    = menu m-clr :handle
  b-clr    :menu-mouse                           = 1
  b-st     :popup-menu in frame {&FRAME-NAME}    = menu m-st :handle
  b-st     :menu-mouse                           = 1
  b-parts- :popup-menu in frame {&FRAME-NAME}    = menu m-parts- :handle
  b-parts- :menu-mouse                           = 1.

assign
  r-reas            :tooltip in frame {&FRAME-NAME} = "Основание (причина) создания документа. Вызов справочника"
  t-doc.reason-code :tooltip in frame {&FRAME-NAME} = "Основание (причина) создания документа. Ввод кода"
  rsn-name          :tooltip in frame {&FRAME-NAME} = "Основание (причина) создания документа"
.

/* ************************  Control Triggers  ************************ */

assign
  parext-doc-mode =
    ( if num-entries( pardoc-mode, '{&delim-flt}':U ) > 1 then entry( 2, pardoc-mode, '{&delim-flt}':U ) else '':U )
  pardoc-mode     = entry( 1, pardoc-mode, '{&delim-flt}':U )
.

{ gbl/conf-rd.i  "'is-ptrl'" "''" "''" 0 "''" "''" "''" no v-is-ptrl v-data-type no-error }
if error-status :error or v-data-type <> "L" or lookup( v-is-ptrl, "yes,no" ) = 0 then do:
  assign
    v-is-ptrl = "no"
  .
end.

{ gbl/conf-rd.i  "'inv-prsr'" "''" "''" 0 "''" "''" "''" no v-inv-prsr v-data-type no-error }
if error-status :error then v-inv-prsr = "no" .


{ gbl/srt-clmn.i
    &BROWSE-NAME          = {&BROWSE-NAME}
    &FRAME-NAME           = {&FRAME-NAME}
    &table-name           = "ub.doc-line"
    &ext-col              = 5
    &start-column         = "{&num-locked-columns-br-list} + 1"
    &label-clmn_1         = "{&label-clmn_1-br-list}"
    &sort-clmn_1          = "{&clmn_1-br-list}"
    &label-clmn_2         = "{&label-clmn_2-br-list}"
    &sort-clmn_2          = "{&clmn_2-br-list}"
    &label-clmn_3         = "{&label-clmn_3-br-list}"
    &sort-clmn_3          = "{&clmn_3-br-list}"
    &label-clmn_4         = "{&label-clmn_4-br-list}"
    &sort-clmn_4          = "{&clmn_4-br-list}"
    &label-clmn_7         = "{&label-clmn_5-br-list}"
    &sort-clmn_7          = "{&clmn_5-br-list} DESCENDING"
    &before-sort          = "ASSIGN dif-only = ""all"". DISPLAY dif-only WITH FRAME {&FRAME-NAME}."
    &open-query           = "{&OPEN-QUERY-br-list}."
    &open-query-otherwise = "{&OPEN-QUERY-br-list} BY ub.doc-line.line-num."
    &re-move-clmn         = "yes"
    &mv-brw-default       = "yes"
}

/* общие триггеры и процедуры для РН, ПН и ДИ */
{ str/trn-tr.i inv no }

&Scoped-define SELF-NAME m_add-marks
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_add-maks {&FRAME-NAME}
ON CHOOSE OF MENU-ITEM m_add-marks /* Добавить марки */
DO:
  def var v-mode as char no-undo.
  if not can-find(first ub.doc-line no-lock where ub.doc-line.doc-code = t-doc.doc-code)
  then do:
    message "В документе нет строк." view-as alert-box information.
    return no-apply.
  end. 
  if not v-is-introduce and not v-is-marking
  then do:
    message "Не включен помарочный учет либо первоначальный ввод." view-as alert-box information.
    return no-apply.
  end.  
  if v-is-introduce
    then v-mode = "introduce".
  run str/chs-marks.w (parparentproc, t-doc.doc-code, v-mode, this-procedure).
  run UI-on in this-procedure ( input "":U ).  

END.

&Scoped-define SELF-NAME m_lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_lookup {&FRAME-NAME}
ON CHOOSE OF MENU-ITEM m_lookup /* Просмотр */
DO:
  define buffer buf_utd-marking-lines for ub.utd-marking-lines.
  define buffer buf_marking for ub.marking.

  if available (t-doc) then do:
      
      for each ub.marking-attr no-lock where
            ub.marking-attr.attr-value = t-doc.doc-code
        and (ub.marking-attr.attr-code = "inv-doc" or ub.marking-attr.attr-code = "inv-doc-scan"):

      for each ub.marking-lines no-lock where
        ub.marking-lines.obj-type = t-doc.obj-type
        and ub.marking-lines.obj-code = t-doc.obj-code
        and ub.marking-lines.out-code = {&free-code}
        and ub.marking-lines.mark = ub.marking-attr.mark
        :

        find first ub.marking no-lock where ub.marking.mark = ub.marking-lines.mark and ub.marking.sts <> ObjSrv:Env:Marking:Sts:Mark:UnknowSts:KeyIntDB no-error.
        if available (ub.marking)
          then 
        do:
          create tt-marking-lines.
          buffer-copy ub.marking-lines to tt-marking-lines.
          tt-marking-lines.sts = ub.marking.sts.
          tt-marking-lines.stts = objSrv:Env:Marking:Sts:Mark:GetLabel(ub.marking.sts).
          tt-marking-lines.sts-utd = ub.marking-lines.sts.
          tt-marking-lines.stts-utd = objSrv:Env:Marking:Sts:Mark:Checked_:Label_.
          tt-marking-lines.box-qnty = ub.marking.box-qnty .
          tt-marking-lines.unit = ub.marking.unit .
          tt-marking-lines.unit-ext = ub.marking.unit-ext .
          if ub.marking-attr.attr-code = "inv-doc-scan"
            then tt-marking-lines.doc-level = 1.
            else tt-marking-lines.doc-level = 2.
          
          tt-marking-lines.mark-parent = ub.marking.mark-parent.
          tt-marking-lines.out-code = t-doc.doc-code.
        end.

      end.
    end.
  
    for each ub.utd no-lock where
            ub.utd.doc-code = t-doc.doc-code
        :
      for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = ub.utd.db-num and buf_utd-marking-lines.doc-id = ub.utd.doc-id and buf_utd-marking-lines.mark <> "",
        each buf_marking no-lock where buf_marking.mark begins buf_utd-marking-lines.mark:
        find first ub.goods where buf_marking.gds-code = ub.goods.gds-code.
        create tt-marking-lines .
        assign
          tt-marking-lines.gds-name    = ub.goods.gds-name
          tt-marking-lines.stts-utd    = objSrv:Env:Marking:Sts:Mark:GetLabel(buf_utd-marking-lines.sts)
          tt-marking-lines.stts        = objSrv:Env:Marking:Sts:Mark:GetLabel(buf_marking.sts)
          tt-marking-lines.mark        = buf_marking.mark
          tt-marking-lines.mark-parent = buf_marking.mark-parent
          tt-marking-lines.gds-code    = buf_utd-marking-lines.gds-code
          tt-marking-lines.sts         = buf_marking.sts
          tt-marking-lines.sts-utd     = buf_utd-marking-lines.sts
          tt-marking-lines.unit        = buf_marking.unit
          tt-marking-lines.unit-ext    = buf_marking.unit-ext
          tt-marking-lines.box-qnty    = buf_marking.box-qnty
          tt-marking-lines.LineNum     = buf_utd-marking-lines.LineNum
          tt-marking-lines.db-num      = buf_utd-marking-lines.db-num
          tt-marking-lines.doc-id      = buf_utd-marking-lines.doc-id
          tt-marking-lines.doc-level   = buf_utd-marking-lines.doc-level
          . 
      end.
    end.


    
    if can-find (first tt-marking-lines no-lock) then
    do:
      run str/mark_browse.w (input parparentproc,
        input-output table tt-marking-lines by-reference,
        input {&lookup},
        input "Марки по документу: " + t-doc.doc-code,
        input "0",
        input "" /*тип продукции*/
        )  .

      for each tt-marking-lines:
        delete tt-marking-lines.
      end.

    end.
    else do:
      message "Марки не найдены." view-as alert-box information title "Информация".
    end.
  end.

END.

&Scoped-define SELF-NAME m_introduce-marks
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_introduce-marks {&FRAME-NAME}
ON CHOOSE OF MENU-ITEM m_introduce-marks /* Добавить марки */
DO:

  if v-is-introduce then do:
    message "Флаг уже установлен." view-as alert-box information.
    return no-apply.
  end.

  find first ub.doc-line no-lock where ub.doc-line.doc-code = t-doc.doc-code no-error.
  if available (ub.doc-line)
  then do:
/*    find first ub.goods no-lock where                                                                                         */
/*          ub.goods.artic     = ub.doc-line.artic     and                                                                      */
/*          ub.goods.prod-type = ub.doc-line.prod-type and                                                                      */
/*          ub.goods.prod-code = ub.doc-line.prod-code.                                                                         */
/*    run gds-attr-value (                                                                                                      */
/*                          input ub.goods.gds-code,                                                                            */
/*                          input {&attr-mark-type},                                                                            */
/*                          output v-marking-type,                                                                              */
/*                          output v-type                                                                                       */
/*                          ).                                                                                                  */
/*    if not v-marking-type = "tabak"                                                                                           */
/*    then do:                                                                                                                  */
/*      message "Невозможно установить флаг так как присутсвуют товары не подлижащие маркировки." view-as alert-box information.*/
/*      return.                                                                                                                 */
/*    end.                                                                                                                      */
    message "В инвентаризации присутсвуют товары. Невозможно установить флаг." view-as alert-box information.
    return no-apply.
  end.
  

/*  if can-find(first ub.marking-attr where ub.marking-attr.attr-code begins "inv-doc" and ub.marking-attr.attr-value = t-doc.doc-code)       */
/*  then do:                                                                                                                                  */
/*    message "Было сканирование в режиме инвентаризации. Флаг первоночального ввода не может быть установлен." view-as alert-box information.*/
/*    return.                                                                                                                                 */
/*  end.                                                                                                                                      */
  { str/tdat-wrt.i
      t-doc.doc-code
      {&trdcattr-inv-introduce}
      "yes"
      no-error
  }
  if error-status:error
  then do:
    message "Ошибка установки флага. " + return-value view-as alert-box error.
    return no-apply.
  end.
  def var introdUtd as class introduce no-undo.
  introdUtd = new introduce() no-error.
  if not valid-object (introdUtd)
  then do:
    message "Ошибка создания объекта introdUtd. " + return-value view-as alert-box error.
    return no-apply.    
  end.
  v-is-introduce = true.
  def var v-utd-num as character no-undo.
  v-utd-num = introdUtd:CrUTDIntroduce(t-doc.doc-code).
  delete object introdUtd.
  run ui-on in this-procedure ( input "all" ).
  message "Флаг установлен. Создан документ первоначального ввода № " + v-utd-num view-as alert-box information.
  
END.

on choose of b-inv-prsrt in frame {&FRAME-NAME}
do:
define buffer buf_doc-line for ub.doc-line  .
define variable v-gds-code  as integer   no-undo .
define variable v-sum1 as decimal   no-undo .
define variable v-sum2 as decimal   no-undo .
define variable v-sum3 as decimal   no-undo .
v-sum1 = 0 .
v-sum2 = 0 .
v-sum3 = 0 .

  for each buf_doc-line no-lock where
           buf_doc-line.doc-code = t-doc.doc-code
           :
         if buf_doc-line.inv-peresort > 0 then v-sum1 = v-sum1 + buf_doc-line.inv-peresort .
         if buf_doc-line.inv-peresort < 0 then v-sum2 = v-sum2 + abs(buf_doc-line.inv-peresort) .
  end.
  message
  'По пересортице + :'   v-sum1 skip
  'По пересортице  - : ' v-sum2 skip
  'Не распределено  : ' v-sum2 - v-sum1  skip
  view-as alert-box information .
end.

ON value-changed OF dif-only IN FRAME {&FRAME-NAME} DO:
  assign dif-only = input frame {&FRAME-NAME} dif-only
         line-rec = ?.
  run UI-on in this-procedure ( input "":U ).
END.

on value-changed of varinvclcwtol in frame {&FRAME-NAME} do:
  if input frame {&FRAME-NAME} varinvclcwtol <> varinvclcwtol then do:
    run local-chg-wtol in this-procedure.
  end.
end.

on value-changed of varinvclcasol in frame {&FRAME-NAME} do:
  if input frame {&FRAME-NAME} varinvclcasol <> varinvclcasol then do:
    run local-chg-asol in this-procedure no-error.
    if error-status :error then do:
      return no-apply.
    end.
  end.
  run ui-on in this-procedure ( input "":U ).
end.

on choose of b-unscn do:
  run str/scn-inv.w
     ( input parparentproc,
       input ( if pardoc-mode <> {&lookup} then recid(t-doc) else ? )
       ).
      if t-doc.status_ = {&permitted} and pardoc-mode = {&update} then do:
        run full-recalc in this-procedure.
      end.
    run UI-on in this-procedure ( input "":U ).
end.

on choose of b-add in frame {&FRAME-NAME} /* Добав */
do:
  run local-add in this-procedure
    no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при добавлении строки инвентаризации") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return no-apply .
  end.
end.

on choose of b-arch in frame {&FRAME-NAME} /* Учет */
do:
  run str/docsuppn.w
    (input  parparentproc
    ,input  recid( t-doc )
    ).
end.

on choose of b-cnt in frame {&FRAME-NAME} /* Просмотр разбивки по дог. пост. */
do:
  run str/inv-cnt.p ( input parparentproc, input t-doc.doc-code ).
end.

on choose of menu-item m-clr-1 do:
  run m-clr-1 in this-procedure.
end.

on choose of menu-item m-clr-2 do:
  run m-clr-2 in this-procedure.
end.

on choose of menu-item m-clr-3 do:
  run m-clr-3 in this-procedure.
end.

on choose of menu-item m-st-1 do:
  run m-st-1 in this-procedure.
  run ui-on  in this-procedure ( input "":U ).
end.

on choose of menu-item m-st-2 do:
  run m-st-2 in this-procedure.
  run ui-on  in this-procedure ( input "":U ).
end.

on choose of menu-item m-st-3 do:
  run m-st-3 in this-procedure.
  run ui-on  in this-procedure ( input "":U ).
end.

on choose of menu-item m-parts-1  /* Перетасовка отрицательных партий*/
do:
  apply "row-leave":U to browse {&BROWSE-NAME}.
  run m-parts-1 in this-procedure.
end.

on choose of menu-item m-parts-2  /* Перетасовка отрицательных партий*/
do:
  apply "row-leave":U to browse {&BROWSE-NAME}.
  run m-parts-2 in this-procedure.
end.

ON choose OF MENU-ITEM m-chk-doc-add in menu m-chk-doc DO:
  assign
  chk-doc-option = {&add-def}.
  apply "choose" to b-chk-doc in frame {&frame-name} .
END.

ON choose OF MENU-ITEM m-chk-docs in menu m-chk-doc DO:
  assign
  chk-doc-option = {&lookup}.
  apply "choose" to b-chk-doc in frame {&frame-name} .
END.

ON choose OF MENU-ITEM m-chk-gds in menu m-chk-doc DO:
  assign
  chk-doc-option = "chk-gds".
  apply "choose" to b-chk-doc in frame {&frame-name} .
END.

on choose of b-del in frame {&FRAME-NAME} /* Удал */
do:
  run local-delete in this-procedure
    no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при удалении строки инвентаризации") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return no-apply .
  end.
end.

on choose of b-chg in frame {&FRAME-NAME} /* Измен */
do:
  run local-chg in this-procedure
    no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при изменении строки инвентаризации") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return no-apply .
  end.
end.

on choose of b-lkp in frame {&FRAME-NAME} /* Просм */
do:
  if not available ub.doc-line then do:
    message "Неправильный выбор строки." view-as alert-box.
    return no-apply .
  end.
  run str/inv-lkp.p
    ( input parparentproc
    , input ub.doc-line.doc-code
    , input ub.doc-line.artic
    , input ub.doc-line.prod-type
    , input ub.doc-line.prod-code
    ) .
  apply "entry":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
end.

on choose of b-updprt- in frame {&FRAME-NAME}
do:
  run local-updprt- in this-procedure.
end.

on choose of b-parts in frame {&FRAME-NAME} /* Партии */
do:
  run local-parts in this-procedure.
end.

on value-changed of invTSD in frame {&FRAME-NAME} /* ИНУ */
  do:
    define buffer buf_inv-doc-attr for ub.inv-doc-attr .
    assign invTSD .
    find first buf_inv-doc-attr exclusive-lock where buf_inv-doc-attr.doc-code = t-doc.doc-code and
      buf_inv-doc-attr.attr-code = 'invMultDevice' no-error . 
    if invTSD then 
    do:
      if available (buf_inv-doc-attr) then buf_inv-doc-attr.attr-value = string(invTSD) .
      else 
      do:
        create buf_inv-doc-attr .
        assign
          buf_inv-doc-attr.doc-code   = t-doc.doc-code
          buf_inv-doc-attr.attr-code  = 'invMultDevice'
          buf_inv-doc-attr.attr-value = string(invTSD)
          .
      end.
    end.
    else 
    do:
      if available (buf_inv-doc-attr) then delete buf_inv-doc-attr .
    end.
  end.

on choose of b-chk-doc in frame {&FRAME-NAME} /* Чеки */
do:
define variable loc-chk-doc-option as character no-undo .
  if chk-doc-option = '':U then do:
    run gbl/pop-up.p ( input b-chk-doc:handle, input no) no-error.
  end.
  if chk-doc-option = '':U then return no-apply.
  assign
  loc-chk-doc-option = chk-doc-option
  chk-doc-option = '':U
  .
  run local-chk-doc in this-procedure ( input loc-chk-doc-option) no-error.
  if error-status:error then return no-apply.
end.

on choose of b-list in frame {&FRAME-NAME} /* Список */
do:
  run local-list in this-procedure.
end.

on return, mouse-select-dblclick of {&BROWSE-NAME} in frame {&FRAME-NAME}
do:
  if b-chg :sensitive = yes then do:
    apply "choose":U to b-chg in frame {&FRAME-NAME}.
  end.
  else do:
    apply "choose":U to b-lkp in frame {&FRAME-NAME}.
  end.
END.

on choose of b-sum-doc in frame {&FRAME-NAME} do:
  run str/vsumtype.w ( input yes, input t-doc.doc-code, input ? ).
end.

on choose of b-sum-goods in frame {&FRAME-NAME} do:
  if available ub.goods then do:
    run str/vsumtype.w ( input no, input t-doc.doc-code, input ub.goods.gds-code ).
  end.
end.

on leave of t-doc.reason-code in frame {&frame-name} do:
  run check-reason in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.

on return of t-doc.reason-code in frame {&frame-name} do:
  run check-reason in this-procedure no-error .
  if error-status :error then do: return no-apply. end.
end.

on choose of r-reas in frame {&frame-name} do:
  run select-reason in this-procedure.
end.

&Scoped-define SELF-NAME t-doc.fact-date
on leave of t-doc.fact-date in frame {&frame-name}  /* Факт */
do:
  run chk-upd-date in this-procedure ( input self :name ).
end.

on return of t-doc.fact-date in frame {&frame-name}  /* Факт */
do:
  if t-doc.fact-date:sensitive in frame {&frame-name} then do:
    apply "entry" to t-doc.shift-date in frame {&frame-name}.
  end.
  else do:
    apply "entry" to b-add in frame {&frame-name}.
  end.
  return no-apply.
end.
&Scoped-define SELF-NAME t-doc.shift-date
ON LEAVE OF t-doc.shift-date IN FRAME {&frame-name}  /* Смена */
do: /* Секция триггеров обработки смены */
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
  run proc-shift-num no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.

on leave of t-doc.shift-name in frame {&frame-name} do:
  run proc-shift-name no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL {&BROWSE-NAME} {&frame-name}
ON row-display OF {&BROWSE-NAME} IN FRAME {&frame-name}
DO:
  
do ii = 1 to 5:
  if tt-goods.gds-name = "" then do:
   bcol[ii]:fgcolor = RED_COLOR.
   end.
end.                                                                                                 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***************************  Main Block  *************************** */

if valid-handle( active-window ) and frame {&FRAME-NAME} :parent eq ?
then frame {&FRAME-NAME} :parent = active-window.

on window-close of frame {&FRAME-NAME} do:
  apply "end-error":U to self.
end.
{ gbl/ed_date.i t-doc.fact-date  }
{ gbl/ed_date.i t-doc.shift-date }

{ gbl/app_help.i }

{&check_trdcalib}

assign
  fi-rub-header = " {&abbr_rub_allshift} "
.

/* зацикливание формы */
assign
  parnext-prev = yes
.
n-p:
do while parnext-prev :
  main-block:
  do on error   undo main-block, leave main-block
     on end-key undo main-block, leave main-block :

    assign 
       {&browse-name}:column-resizable in frame {&frame-name} = true.

    if pardoc-mode = {&add-def} then do:
      { str/adinvdoc.i
        v-cntxt-obj-type
        v-cntxt-obj-code
        v-cntxt-userid
        pardoc-rec
        no-error
      }
      if error-status :error then do:
        assign
          parnext-prev = no.
        return error.
      end.
      find first t-doc where recid( t-doc ) = pardoc-rec.
    end. /* pardoc-mode = {&add-def} */
    else do: /* pardoc-mode <> {&add-def} */
      if pardoc-mode = {&lookup} then  find first t-doc NO-LOCK where recid( t-doc ) = pardoc-rec no-error.
      else find first t-doc where recid( t-doc ) = pardoc-rec no-error.
      if available t-doc then do:
        for each ub.doc-line no-lock where ub.doc-line.doc-code = t-doc.doc-code:
          create tt-goods .
          tt-goods.artic = ub.doc-line.artic .
          find first ub.goods no-lock where ub.goods.artic = ub.doc-line.artic and
          ub.goods.prod-code = ub.doc-line.prod-code and
          ub.goods.prod-type = ub.doc-line.prod-type no-error .
          if available (ub.goods) then tt-goods.gds-name = ub.goods.gds-name .
          else tt-goods.gds-name = "".
        end.
        if pardoc-mode = {&update} then do:
          case t-doc.status_ :
            when {&wayb} then do:
              if t-doc.flag_ then do:
                message "Опись инвентаризации закрыта." skip (2)
                        "Редактирование невозможно."
                        view-as alert-box error.
                assign
                  parnext-prev = no.
                return error.
              end.
            end.
            when {&permitted} then do:
              if v-cntxt-db-num-obj <> 0 and  v-cntxt-db-num-obj <> v-cntxt-db-num then do:
                message "Документ  №" t-doc.doc-code skip (2)
                        "Редактирование возможно только на активной стороне."
                        view-as alert-box error.
                assign
                  parnext-prev = no.
                return error.
              end.
            end.
            otherwise do:
              assign
                parnext-prev = no.
              return error.
            end.
          end case. /* t-doc.status_ */
        run ver-price .
        end. /* pardoc-mode = {&update} */
      end. /* if available t-doc */
      else do: /* if not available t-doc */
        assign
          parnext-prev = no.
        return error "Неправильный выбор документа.".
      end. /* if not available t-doc */
    end. /* pardoc-mode <> {&add-def} */
    assign
      varinvclcspvalue = "no"
    .

    def var v-attr-value as character no-undo.
    def var v-attr-type as character no-undo. 
    { str/tdat-val.i
      t-doc.doc-code
      {&trdcattr-inv-introduce}
      v-attr-value
      v-attr-type
      no-error
    }
    if not error-status:error and v-attr-value = "yes" then do:
      v-is-introduce = true.
    end.
    
    run str/invdcfrd.p (  input t-doc.doc-code,
                     output varinvclcspvalue,
                     output prtvalue,
                     //output partsvalue,
                     output varr-b ,
                     output is-cdinv
                     ) no-error.
    if error-status :error then do:
      assign
        parnext-prev = no.
      return error.
    end.

    if pardoc-mode <> {&lookup} then do: /* указатель на ту строку, на которую надо встать */
      assign
        line-rec = ?
      .
    end.
    assign
      dif-only = "all":U
    .
    tt-goods.gds-name:width     in browse {&browse-name}   = 40.
    
    
/*    { gbl/mv-clmn.i                                        */
/*        &ext-col      = 29                                 */
/*        &frame-name   = "{&frame-name}"                    */
/*        &browse-name  = "{&browse-name}"                   */
/*        &table-name   = "ub.doc-line"                      */
/*        &start-column = "{&num-locked-columns-br-list} + 1"*/
/*    }                                                      */
    find first bf_sysconf where bf_sysconf.host-code = t-doc.host-code no-lock.
    run UI-on in this-procedure ( input "":U ) no-error.
    if error-status :error then do:
      assign
        parnext-prev = no.
      return error.
    end.
    run fill-mol.
    WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS {&BROWSE-NAME}.
  end. /* main-block */
end. /* do while */
hide frame {&FRAME-NAME} no-pause.


/* **********************  Internal Procedures  *********************** */

procedure ui-on :
define input parameter parmode as character no-undo .

define variable varadd-back-date        as   logical               no-undo.
define buffer bf-ext_trn-doc-sum for ub.trn-doc-sum.
define buffer bf-mis_trn-doc-sum for ub.trn-doc-sum.
define buffer bf-wt_trn-doc-sum  for ub.trn-doc-sum.
define buffer bf-uwt_trn-doc-sum for ub.trn-doc-sum.
define buffer bf_trn-reason      for ub.trn-reason.

define variable p-value as character no-undo.
define variable p-type  as character no-undo.


  /* включение пользовательского интерфейса */
  disable all with frame {&FRAME-NAME}.

  display
    fi-val-header
    fi-rub-header
    fi-izlishki-header
    fi-nedostacha-header
    fi-raschet-header
    invTSD
    with frame {&FRAME-NAME} .

  hide loc-art in frame {&FRAME-NAME} loc-name loc-code in frame {&FRAME-NAME}.
  assign
    loc-art = "":U
  .
  assign
  B-chk-doc:POPUP-MENU IN FRAME {&frame-name} = MENU m-chk-doc:HANDLE
  b-chk-doc:menu-mouse = 1.
  assign
  menu-item m-chk-doc-add:sensitive in menu m-chk-doc = (pardoc-mode <> {&lookup}).
  enable
    b-exit b-history b-arch b-sum-doc b-sum-goods b-help b-marks {&BROWSE-NAME} b-lkp a-n-c b-notes b-unscn b-cnt 
    b-chk-doc when is-cdinv = "yes" and t-doc.obj-type = {&shop}
    with frame {&FRAME-NAME}.

  if v-inv-prsr = "yes"
     then enable b-inv-prsrt with frame {&FRAME-NAME}.
     else hide b-inv-prsrt in frame {&FRAME-NAME}.

  IF partsvalue = "yes" then do:
    enable b-parts with frame {&FRAME-NAME}.
  end.
  enable dif-only with frame {&FRAME-NAME}.
  if pardoc-mode = {&lookup} then do:
    if parext-doc-mode = "reason-code" then do:
      enable r-reas t-doc.reason-code with frame {&FRAME-NAME}.
    end.
    else do:
      enable b-list when ( t-doc.status_ <> {&wayb} or t-doc.flag_ = yes )
             b-next b-prev
      with frame {&FRAME-NAME}.
      if br-handle = ? then hide b-prev b-next in frame {&frame-name} .
    end.
  end.
  else do:
    enable t-doc.wrkr t-doc.agnt t-doc.boss r-wrkr r-agnt r-boss r-reas t-doc.reason-code
           with frame {&FRAME-NAME}.
    if t-doc.status_ = {&permitted} then do:
      if t-doc.flag_ = no then do:
        enable b-add b-del with frame {&FRAME-NAME}.
      end.
      enable b-chg with frame {&FRAME-NAME}.
      enable varinvclcwtol varinvclcasol with frame {&FRAME-NAME}.
      if t-doc.flag_ then do:
        b-list :label = "&Сканер".
        enable b-clr b-list with frame {&FRAME-NAME}.
      end.
      enable b-parts- b-updprt- b-st with frame {&FRAME-NAME}.
    end.
    else do:
      enable b-add b-del b-list with frame {&FRAME-NAME}.
    end.
  end.
  if t-doc.status_ =  {&permitted} and
     t-doc.flag_   <> yes          then do:
    display ? @ t-doc.doc-qnty with frame {&FRAME-NAME}.
  end.
  else do:
    display t-doc.doc-qnty with frame {&FRAME-NAME}.
  end.
  if pardoc-mode = {&add-def} then
  enable invTSD with frame {&FRAME-NAME}.
  else do:
    find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
    ub.inv-doc-attr.attr-code = 'invMultDevice' no-error .
    if available (ub.inv-doc-attr) then invTSD = logical(ub.inv-doc-attr.attr-value) .
  display invTSD with frame {&FRAME-NAME}.
  end.
  /* Читаем атрибуты on-line-ового расчета */
  { str/tdat-val.i t-doc.doc-code
               {&trdcattr-clcasol}
               p-value
               p-type              }
  assign
    varinvclcasol = ( if p-value = "yes" then yes else no )
  .
  display
    varinvclcasol with frame {&FRAME-NAME}.
  { str/tdat-val.i t-doc.doc-code
               {&trdcattr-clcaswt}
               p-value
               p-type              }
  assign
    varinvclcwtol = ( if p-value = "yes" then yes else no )
  .
  display
    varinvclcwtol with frame {&FRAME-NAME}.
  { str/tdat-val.i t-doc.doc-code
               {&trdcattr-addsum}
               p-value
               p-type             }
  assign
    varinvclcbef = no
    varinvclcas  = no
    varinvclcex  = no
    varinvclcms  = no
    varinvclcwt  = no
  .
  if lookup( {&sum-before-doc}, p-value ) <> 0 then do:
    assign
      varinvclcbef = yes
    .
  end.
  if lookup( {&sum-general-doc}, p-value ) <> 0 then do:
    assign
      varinvclcas = yes
    .
  end.
  if lookup( {&sum-extra-doc}, p-value ) <> 0 then do:
    assign
      varinvclcex = yes
    .
  end.
  if lookup( {&sum-miss-doc}, p-value ) <> 0 then do:
    assign
      varinvclcms = yes
    .
  end.
  if lookup( {&sum-wastage-doc}, p-value ) <> 0 then do:
    assign
      varinvclcwt = yes
    .
  end.
  if varinvclcex = yes and
     varinvclcms = yes then do:
    find first bf-ext_trn-doc-sum no-lock where
               bf-ext_trn-doc-sum.doc-code = t-doc.doc-code   and
               bf-ext_trn-doc-sum.sum-type = {&sum-extra-doc}.
    find first bf-mis_trn-doc-sum no-lock where
               bf-mis_trn-doc-sum.doc-code = t-doc.doc-code  and
               bf-mis_trn-doc-sum.sum-type = {&sum-miss-doc}.

    assign
      vardocextra-qnty = bf-ext_trn-doc-sum.fact-qnty
      vardocextra-base = bf-ext_trn-doc-sum.cost-sum-base
      vardocextra-rubl = bf-ext_trn-doc-sum.cost-sum-rubl
      vardocmiss-qnty  = bf-mis_trn-doc-sum.fact-qnty
      vardocmiss-base  = bf-mis_trn-doc-sum.cost-sum-base
      vardocmiss-rubl  = bf-mis_trn-doc-sum.cost-sum-rubl
    .
    if varr-b = "base" then do:
      assign
        vardocextra-rb = bf-ext_trn-doc-sum.sale-sum-base
        vardocmiss-rb  = bf-mis_trn-doc-sum.sale-sum-base
      .
    end.
    else do:
      assign
        vardocextra-rb = bf-ext_trn-doc-sum.sale-sum-rubl
        vardocmiss-rb  = bf-mis_trn-doc-sum.sale-sum-rubl
      .
    end.
  end.
  else do:
    assign
      vardocextra-qnty = ?
      vardocextra-base = ?
      vardocextra-rubl = ?
      vardocextra-rb   = ?
      vardocmiss-qnty  = ?
      vardocmiss-base  = ?
      vardocmiss-rubl  = ?
      vardocmiss-rb    = ?
    .
  end.
  if varinvclcwt = yes then do:
    find first bf-wt_trn-doc-sum where bf-wt_trn-doc-sum.doc-code = t-doc.doc-code     and
                                       bf-wt_trn-doc-sum.sum-type = {&sum-wastage-doc} no-lock.
    if varr-b = "base" then do:
      assign
        vardocwast-rb      = bf-wt_trn-doc-sum.sale-sum-base
      .
    end.
    else do:
      assign
        vardocwast-rb      = bf-wt_trn-doc-sum.sale-sum-rubl
      .
    end.
  end.
  else do:
    assign
      vardocwast-rb      = ?
    .
  end.

  find bf_trn-reason no-lock where
       bf_trn-reason.reason-code = t-doc.reason-code no-error.
  assign
    rsn-name = ( if available bf_trn-reason then bf_trn-reason.reason-name else "":U )
  .

  display t-doc.tot-doc t-doc.tot-rubl t-doc.fact-base
          t-doc.fact-rubl t-doc.fact-qnty dif-only varinvclcwtol varinvclcasol
          vardocextra-qnty vardocextra-base vardocextra-rubl vardocextra-rb
          vardocmiss-qnty  vardocmiss-base  vardocmiss-rubl  vardocmiss-rb
          vardocwast-rb
          t-doc.wrkr t-doc.agnt t-doc.boss
          t-doc.re-grading-parts-minus
          t-doc.reason-code rsn-name
          t-doc.doc-date
          t-doc.fact-date
  with frame {&FRAME-NAME}.

  { str/psn-chk.i wrkr on t-doc ref-rec}
  { str/psn-chk.i agnt on t-doc ref-rec}
  { str/psn-chk.i boss on t-doc ref-rec}

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_inventory_add-back-date':U
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
   hide t-doc.fact-date
        t-doc.shift-date
        t-doc.shift-num
        t-doc.fact-qnty
        t-doc.shift-name
        r-sht
        in frame {&frame-name}.
end.
else do:
 if (t-doc.status_ = {&wayb} and not t-doc.flag_) then do:
   display t-doc.fact-date with frame {&frame-name}.
   if t-doc.status_ = {&wayb} and
      t-doc.flag_   = no     and
      pardoc-mode <> {&lookup}   and
      varadd-back-date = yes then do:
      /* SV заднее число */
     enable t-doc.fact-date  t-doc.doc-date with frame {&frame-name}.
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
        pardoc-mode <> {&lookup}    and
        varadd-back-date = yes  then do:
       /* enable t-doc.shift-date t-doc.shift-num t-doc.shift-name r-sht with frame {&frame-name}. */
     end.
   end.
   else do:
      hide t-doc.shift-date t-doc.shift-num t-doc.shift-name r-sht in frame {&frame-name}.
   end.
 end.
 else do:
   display t-doc.fact-date t-doc.fact-qnty t-doc.shift-date t-doc.shift-num t-doc.shift-name r-sht with frame {&frame-name}.
 end.
end.


  if t-doc.status_ = {&wayb} and not t-doc.flag_ and not pardoc-mode = {&lookup}
    then do:
      MENU-ITEM m_add-marks:SENSITIVE IN MENU m-marks = TRUE.
/*      if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(t-doc.obj-type, t-doc.obj-code):IsMarking*/
/*        then                                                                                  */
        MENU-ITEM m_introduce-marks:SENSITIVE IN MENU m-marks = FALSE.
/*        else MENU-ITEM m_introduce-marks:SENSITIVE IN MENU m-marks = TRUE.*/
      MENU-ITEM m_lookup:SENSITIVE IN MENU m-marks = TRUE.
/*      b-marks:visible = true.*/
    end.
    else do:
      MENU-ITEM m_add-marks:SENSITIVE IN MENU m-marks = FALSE.
      MENU-ITEM m_introduce-marks:SENSITIVE IN MENU m-marks = FALSE.
      MENU-ITEM m_lookup:SENSITIVE IN MENU m-marks = TRUE.
/*      b-marks:visible = false.*/
    end.

  find first ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code no-error.
  if available (ub.doc-line)
  then do:
  end.                                                                                                                                              
  extent (bcol) = ?.
  hbrowse = browse {&BROWSE-NAME}:handle.

  extent (bcol) = hbrowse:num-columns.
  bcol[1] = hbrowse:first-column.
  do ii = 1 to extent (bcol).  
    bcol[ii] = hbrowse:get-browse-column (ii).
    if ii = 5 then leave .
  end.

if t-doc.fact-date <> ? and t-doc.fact-date < t-doc.doc-date then hide  b-st b-clr b-parts-  in frame {&frame-name} .

  assign
    frame {&FRAME-NAME} :title = t-doc.obj-type + " ":U + string( t-doc.obj-code, ">>>>9":U ) + "  : " + "ИНВЕНТАРИЗАЦИЯ " + t-doc.status_ +
                                                " ":U + string( t-doc.flag_, "+/-":U ) + "     № " + t-doc.doc-code + (if v-is-introduce then ". ПЕРВОНАЧАЛЬНЫЙ ВВОД" else "") +
                                                "                - ":U.
  assign frame {&frame-name} :title = frame {&frame-name} :title +
    ( if parext-doc-mode = "":U          then pardoc-mode       else ( caps( '{&bef-fact-edit}':U ) +
    ( if parext-doc-mode = "reason-code" then " кода основания" else "":U ) ) ).
  if parmode <> "no-query":U THEN DO:
    case dif-only:
      when "all" then do:
        &scop dif-cond
        {&OPEN-QUERY-br-list} by ub.doc-line.line-num.
      end.
      when "shortage" then do:
        &scop dif-cond and ub.doc-line.fact-qnty < 0
        {&OPEN-QUERY-br-list} by ub.doc-line.line-num.
      end.
      when "surplus" then do:
        &scop dif-cond and ub.doc-line.fact-qnty > 0
        {&OPEN-QUERY-br-list}.
      end.
      when "coincidence" then do:
        &scop dif-cond and ub.doc-line.fact-qnty = 0
        {&OPEN-QUERY-br-list} by ub.doc-line.line-num.
      end.
      when "markseqdocqnty" then do:
        def var v-qnty as integer no-undo.
        def var v-rec-list as character no-undo.
        for each ub.doc-line no-lock where ub.doc-line.doc-code = t-doc.doc-code:
          run procmarkqntycheckinv (buffer ub.doc-line, output v-qnty). 
          if ub.doc-line.doc-qnty - ub.doc-line.fact-qnty ne v-qnty
            then v-rec-list = string (recid(ub.doc-line)) + "," + v-rec-list.
        end.
        &scop dif-cond and lookup (string (recid (ub.doc-line)), v-rec-list) > 0 
        {&OPEN-QUERY-br-list} by ub.doc-line.line-num.
      end.
    end case.
    if line-rec <> ? then do:
      reposition {&BROWSE-NAME} to recid line-rec no-error.
    end.
  END.
  
  apply "entry":U to {&BROWSE-NAME}.
end procedure. /* UI-On */

procedure loc-cr-gds-dtl :
  define variable n-c like ub.gds-prt.node-code          no-undo.
  find first ub.gds-dtl where
             ub.gds-dtl.doc-code  = ub.doc-line.doc-code  and
             ub.gds-dtl.artic     = ub.doc-line.artic     and
             ub.gds-dtl.prod-code = ub.doc-line.prod-code and
             ub.gds-dtl.prod-type = ub.doc-line.prod-type no-error.
  if not available ub.gds-dtl then do:
    { gbl/termnode.i ub.goods.prt-root n-c }
    { str/crgdsdtl.i
        ub.doc-line.obj-code
        ub.doc-line.obj-type
        t-doc.doc-code
        ub.doc-line.artic
        ub.doc-line.prod-code
        ub.doc-line.prod-type
        n-c
        yes
    }
    find first ub.gds-dtl where
               ub.gds-dtl.doc-code  = ub.doc-line.doc-code  and
               ub.gds-dtl.artic     = ub.doc-line.artic     and
               ub.gds-dtl.prod-code = ub.doc-line.prod-code and
               ub.gds-dtl.prod-type = ub.doc-line.prod-type and
               ub.gds-dtl.prt-code  = n-c.
    assign
      ub.gds-dtl.fact-qnty = ub.doc-line.doc-qnty
      ub.gds-dtl.doc-qnty  = 0
    .
  end. /* if not available ub.gds-dtl */
end procedure. /* loc-cr-gds-dtl */

procedure set-cource :
  define variable v-today as date no-undo.
  define variable varbase-code as integer no-undo.
  { gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code v-today }
  { gbl/basecode.i t-doc.host-code varbase-code }
  find last ub.curr-accnt no-lock where
            ub.curr-accnt.curr-code  = varbase-code and
            ub.curr-accnt.exch-date <= v-today      use-index pi no-error.
  if not available ub.curr-accnt then do:
    message "На дату" v-today "неизвестен курс базовой валюты." SKIP
            "Сумма по документу в валюте будет рассчитана при закрытии на факт"
    view-as alert-box.
  end.
  else do:
    assign
      t-doc.base-rate  = ub.curr-accnt.exch-rate
      t-doc.base-scale = ub.curr-accnt.exch-scale
    .
  end.
end procedure. /* set-cource */

procedure local-add :
  define variable varartic   like ub.doc-line.artic no-undo initial " ":U.
  define variable varmessage as character no-undo.
  define variable varnotes   as character no-undo.
  define variable vismsg     as logical   no-undo init true.
  define buffer bf_doc-line for ub.doc-line.
  define buffer buf_marking-lines for ub.marking-lines.
  do
  on error undo, return error return-value
  :
    /*run str/chs-gds.w
     ( input        parparentproc
      ,input        t-doc.obj-type
      ,input        t-doc.obj-code
      ,input        '':U
      ,input        '':U
      ,input        "Строка накладной № " + t-doc.doc-code
      ,input        ?
      ,input        ?
      ,input        ?
      ,input        ?
      ,input        t-doc.ext-doc-type
      ,input-output varartic
      ,output       varnotes
      ).
      */
    run str/chsgdsls.w (
          input parParentProc ,
          input "inv" ,
          input "Строка инвентаризации № " + t-doc.doc-code + " " + t-doc.status_  ,
          input ? ,
          input ? ,
          input t-doc.host-code,
          input-output varartic,
          output ref-list,
          output table tt-gds-list,
          input false )
          no-error.

    assign
      vartime = time
      lns-cnt = 0
    .
    tr:
    for each tt-gds-list
      break by tt-gds-list.nn
    on error undo tr, next tr
    :
      find ub.goods no-lock
        where  ub.goods.gds-code = tt-gds-list.gds-code .

      assign
        lns-cnt = lns-cnt + 1
      .

      run gds-attr-value (
                            input ub.goods.gds-code,
                            input {&attr-mark-type},
                            output v-marking-type,
                            output v-type
                            ).
      if not v-marking-type = "tabak" and v-is-introduce
      then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute("Ошибка при добавлении строки инвентаризации. Запрещено добавлять товары, неподлежащие обязательной маркировки. Включен флаг первоначального ввода.") skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo tr, next tr.
      end.
      if v-is-introduce then do:
        def var introdUtd as class introduce no-undo.
        def var jj as integer no-undo.
        find first ub.utd no-lock where ub.utd.doc-code = t-doc.doc-code no-error.
        if not available (ub.utd)
        then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute("Ошибка при добавлении строки в инвентаризацию первоначального ввода. Привязанный документ первоначального ввода не найден.")
            view-as alert-box error .
          undo tr, next tr.
        end.
        introdUtd = new introduce() no-error.
        introdUtd:AddLineUTD(input ub.goods.gds-code, input ub.utd.doc-id, input ub.utd.db-num, output jj).
        if error-status:error
        then do:
          delete object introdUtd no-error.
          message
            vss-workfile vss-revision vss-description skip
            substitute("Ошибка при добавлении строки первоначального ввода.") skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo tr, next tr.
        end.
        delete object introdUtd no-error.
      end.
      if v-marking-type = "tabak" and vismsg and can-find (first buf_marking-lines no-lock 
                                                  where buf_marking-lines.gds-code = ub.goods.gds-code and buf_marking-lines.out-code = {&free-code} and buf_marking-lines.mark begins {&tech-mark-prefix})
      then do:
        vismsg = false.
        message
          substitute("Есть товары с техническими марками") skip
          view-as alert-box warning title "Информация".
      end.
      
      if can-find (first ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code)
      then do:
        if not v-is-introduce and v-marking-type <> "" and v-marking-type <> "not-type" and
        ((not ObjSrv:Env:ParametrsOfSection:GetSectionEDO(t-doc.obj-type, t-doc.obj-code):GetIsMarkingForType(v-marking-type) and (v-is-marking = true))
        or (ObjSrv:Env:ParametrsOfSection:GetSectionEDO(t-doc.obj-type, t-doc.obj-code):GetIsMarkingForType(v-marking-type) and v-is-marking = false))
        then do:
          message
            substitute("Ошибка при добавлении строки инвентаризации. Совместное добавление товаров, подлежащих маркировке и не подлежащих маркировке, запрещено.") skip
            view-as alert-box error .
          undo tr, next tr.
        end.
      end.
      else do: 
        if v-marking-type <> "" and v-marking-type <> "not-type" then do:
        if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(t-doc.obj-type, t-doc.obj-code):GetIsMarkingForType(v-marking-type)
          then v-is-marking = true.
        end.  
      end. 
      
      find first bf_doc-line where
                 bf_doc-line.doc-code  = t-doc.doc-code         and
                 bf_doc-line.artic     = ub.goods.artic     and
                 bf_doc-line.prod-type = ub.goods.prod-type and
                 bf_doc-line.prod-code = ub.goods.prod-code no-error.
      if available bf_doc-line then do:
        undo tr, next tr.
      end.
      run waitfram-join in this-procedure (  input "Добавление товаров в документ инвентаризации.",
                                             input substitute( " Добавлено &1.", lns-cnt - 1 ),
                                             input substitute( " Время &1.", string( time - vartime, "hh:mm:ss":U ) ),
                                            output varmessage ).
      run waitfram-show in this-procedure (  input varmessage ).
      { str/adinvlin.i
          parparentproc
          t-doc.doc-code
          ub.goods.artic
          ub.goods.prod-type
          ub.goods.prod-code
          line-rec
          no-error
      }
      if error-status :error then do:
        run waitfram-hide in this-procedure.
        message
          vss-workfile vss-revision vss-description skip
          substitute("Ошибка при добавлении строки инвентаризации") skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo tr, next tr.
      end.
      find first ub.doc-line where recid( ub.doc-line ) = line-rec.
      assign
        ub.doc-line.prt-OK = ?
      .
      if t-doc.status_ = {&permitted} and
         t-doc.flag_   = no           then do:
        { str/filinvln.i
            ub.doc-line.doc-code
            ub.doc-line.artic
            ub.doc-line.prod-type
            ub.doc-line.prod-code
            this-procedure:handle
            no-error
        }
        if error-status :error then do:
          run waitfram-hide in this-procedure.
          message "Ошибка при заполнении сумм по строке товара: "
                  ub.doc-line.artic " " ub.doc-line.prod-type " " ub.doc-line.prod-code skip
                  return-value skip
          view-as alert-box error.
          undo tr, next tr .
        end.
      end.
    end. /* transaction */
    run waitfram-hide in this-procedure.
    run UI-on         in this-procedure ( input "":U ).
  end. /* on error */
end procedure. /* local-add */

procedure m-clr-1 :
  if not available ub.doc-line then do:
    message "Неправильно выбрана строка."
    view-as alert-box error buttons ok.
    return error.
  end.
  else do:
    assign
      line-rec = recid( ub.doc-line )
    .
  end.
  find ub.doc-line where recid( ub.doc-line ) = line-rec.
  /* Текущей строки */
  apply "row-leave":U to browse {&BROWSE-NAME}.
  do transaction on error undo, return error return-value :
    /* Запомним старые значения суммы по документу */
    run local-reclcinv in this-procedure ( input "old":U ).
    message "Списать в ноль строку " ub.doc-line.artic " ?"
                    view-as alert-box question buttons ok-cancel update varlog.
    if varlog <> yes then do:
      return.
    end.
    { str/clr-line.i
      parparentproc
      ub.doc-line.doc-code
      ub.doc-line.artic
      ub.doc-line.prod-type
      ub.doc-line.prod-code
      "'ноль':u"
    }
    if ub.doc-line.doc-qnty <> 0 then do:
      message "Не удается обнулить строку." skip
              "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
         view-as alert-box error .
      undo, return error.
    end.
    run local-reclcinv in this-procedure ( input "update":U ).
  end. /* transaction */
  run ui-on in this-procedure ( input "":U ).
end procedure. /* m-clr-1 */

procedure m-clr-2 :
  apply "row-leave":U to browse {&BROWSE-NAME}.
  /* Всех строк */
  do transaction on error undo, return error return-value :
    assign
      vartime  = time
      varcount = 0
      varlog    = no
    .
    message "Списать в ноль все строки?"
           view-as alert-box question buttons OK-Cancel update varlog.
    if varlog <> yes then do:
      return.
    end.
    for each ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code on error undo, return error return-value :
      assign
        varcount = varcount + 1
      .
      run waitfram-show in this-procedure ( waitfram-join-function(
                                                                    "Списание в ноль всех строк.",
                                                                    substitute( " Обработано строк: &1.", varcount ),
                                                                    substitute( " Время &1.",
                                                                                string( time - vartime, "hh:mm:ss":U ) )
                                                                  )
                                          ) no-error.
      { str/clr-line.i
          parparentproc
          ub.doc-line.doc-code
          ub.doc-line.artic
          ub.doc-line.prod-type
          ub.doc-line.prod-code
          "'ноль':u"
          no-error
      }
      if error-status :error then do:
        run waitfram-hide in this-procedure no-error.
        undo, return error return-value.
      end.
    end. /* for each ub.doc-line */
    run full-recalc in this-procedure.
  end. /* transaction */
  run waitfram-hide in this-procedure no-error.
  message "Обработано строк :" varcount
  view-as alert-box.
  run UI-on in this-procedure ( input "":U ).
end procedure. /* m-clr-2 */

procedure m-clr-3 :
  /* Нередактированных строк */
  APPLY "row-leave":U to BROWSE {&BROWSE-NAME}.
  assign
    varlog    = no
    vartime  = time
    varcount = 0
  .
  do transaction on error undo, return error return-value :
    message "Списать в ноль все строки, которые не изменялись ?"
                  view-as alert-box question buttons OK-Cancel update varlog.
    if varlog <> yes then do:
      return no-apply.
    end.
    run waitfram-show in this-procedure ( input "Списание в ноль всех неизмененных строк. ЖДИТЕ..." ).
    for each ub.doc-line where
             ub.doc-line.doc-code = t-doc.doc-code and
             ub.doc-line.prt-ok   = ?              on error undo, return error return-value :
      assign
        varcount = varcount + 1
      .
      run waitfram-show in this-procedure ( waitfram-join-function (
                                                                     "Списание в ноль всех неизмененных строк.",
                                                                     substitute( " Обработано строк: &1.", varcount ),
                                                                     substitute( " Время &1.",
                                                                                 string( time - vartime, "hh:mm:ss":U ) )
                                                                   )
                                          ) no-error.
      { str/clr-line.i
          parparentproc
          ub.doc-line.doc-code
          ub.doc-line.artic
          ub.doc-line.prod-type
          ub.doc-line.prod-code
          "'ноль':u"
      }
      accumulate ub.doc-line.doc-code ( count ).
    end. /* for each ub.doc-line */
    if can-find( first ub.doc-line where
                       ub.doc-line.doc-code =  t-doc.doc-code and
                       ub.doc-line.prt-ok   =  ?              and
                       ub.doc-line.doc-qnty <> 0 )            then do:
      message "Во время сброса в некоторые товары не удалось обнулить." skip
              view-as alert-box error .
    end.
    run full-recalc in this-procedure.
  end. /* transaction */
  run waitfram-hide in this-procedure no-error.
  message "Обработано строк :" ( accum count ub.doc-line.doc-code )
          view-as alert-box.
  run UI-on in this-procedure ( input "":U ).
end procedure. /* m-clr-3 */

procedure m-st-1 :
  apply "row-leave":U to browse {&BROWSE-NAME}.
  if not available ub.doc-line then do:
    message "Неправильно выбрана строка."
    view-as alert-box error buttons ok.
    return error.
  end.
  else do:
    assign
      line-rec = recid( ub.doc-line )
    .
  end.
  find ub.doc-line where recid( ub.doc-line ) = line-rec.
  /* Текущей строки */
  do transaction on error undo, return error return-value :
    /* Запомним старые значения суммы по документу */
    run local-reclcinv in this-procedure ( input "old":U ).
    message "Восстановить строку " ub.doc-line.artic " ?"
                      view-as alert-box question buttons OK-Cancel update varlog.
    if varlog <> yes then do:
      return no-apply.
    end.
    RUN loc-cr-gds-dtl in this-procedure.
    { str/clr-line.i
        parparentproc
        ub.doc-line.doc-code
        ub.doc-line.artic
        ub.doc-line.prod-type
        ub.doc-line.prod-code
        "'исх':u"
    }
    run local-reclcinv in this-procedure ( input "update":U ).
  END. /* transaction */
  run waitfram-hide in this-procedure no-error.
end procedure. /* m-st-1 */

procedure m-parts-1 :
  if available ub.doc-line then
  do transaction on error undo, return error return-value:
    /* перечитаем с локировкой */
    assign
      line-rec = RECID( ub.doc-line )
    .
    find ub.doc-line where recid( ub.doc-line ) = line-rec.
    run local-reclcinv in this-procedure ( input "old":u ).
    run loc-cr-gds-dtl in this-procedure.
    assign
      unrv-qnty = 1
    .
    run trg/rsrv-dtl.p ( input        parparentproc,
                     input        {&rsrv-dtl_action_reserv-sozdanie},
                     buffer       ub.gds-dtl,
                     input-output unrv-qnty,
                     input-output ub.doc-line.price-base,
                     input-output ub.doc-line.price-rubl,
                     input        -1,
                     input "" ).
    find first ub.doc-line no-lock where recid( ub.doc-line ) = line-rec no-error.
    if available ub.doc-line then do:
      run local-reclcinv in this-procedure ( input "update":U ).
      display {&disp-list} with browse {&BROWSE-NAME}.
    end.
    run ui-on in this-procedure ( input "no-query" ).
    message "Была произведена пересортица по отрицательным партиям на кол-во: " unrv-qnty
        view-as alert-box info buttons ok.
    assign
      t-doc.re-grading-parts-minus = yes
    .
    display t-doc.re-grading-parts-minus with frame {&FRAME-NAME}.
  end. /* transaction */
end procedure. /* m-parts-1 */

procedure m-st-2 :
  APPLY "row-leave":U to BROWSE {&BROWSE-NAME}.
  assign
    varcount = 0
    varlog = no
  .
  do transaction on error undo, return error return-value :
    message "Восстановить исходное состояние для всех строк ?"
                    view-as alert-box question buttons OK-Cancel update varlog.
    if varlog <> yes then do:
      return.
    end.
    run waitfram-show in this-procedure ( input "Восстановление всех строк ЖДИТЕ..." ).
    for each ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code on error undo, return error return-value :
      run loc-cr-gds-dtl in this-procedure no-error.
      if error-status :error then do:
        run waitfram-hide in this-procedure no-error.
        undo, return error return-value.
      end.
      { str/clr-line.i
          parparentproc
          ub.doc-line.doc-code
          ub.doc-line.artic
          ub.doc-line.prod-type
          ub.doc-line.prod-code
          "'исх':u"
      }
      assign
       varcount = varcount + 1.
    end. /* for each ub.doc-line */
    run full-recalc in this-procedure.

  end. /* transaction */
  run waitfram-hide in this-procedure no-error.
  message "Обработано строк :" ( varcount )
          view-as alert-box.
end procedure. /* m-st-2 */

procedure m-st-3 :
  APPLY "row-leave":U to BROWSE {&BROWSE-NAME}.
  assign
    varcount = 0
    varlog = no
  .
  do transaction on error undo, return error return-value :
    message "Восстановить исходное состояние для всех сброшенных в ноль строк ?"
                    view-as alert-box question buttons OK-Cancel update varlog.
    if varlog <> yes then do:
      return.
    end.
    run waitfram-show in this-procedure ( input "Восстановление списанных в ноль строк. ЖДИТЕ..." ).
    for each ub.doc-line where
             ub.doc-line.doc-code = t-doc.doc-code and
             ub.doc-line.doc-qnty = 0              on error undo, return error return-value :
      RUN loc-cr-gds-dtl in this-procedure.
      { str/clr-line.i
          parparentproc
          ub.doc-line.doc-code
          ub.doc-line.artic
          ub.doc-line.prod-type
          ub.doc-line.prod-code
          "'исх':u"
      }
      assign
        varcount = varcount + 1.
    end.
    run full-recalc in this-procedure.
  END. /* transaction */
  run waitfram-hide in this-procedure no-error.
  message "Обработано строк :" ( varcount )
          view-as alert-box.
end procedure. /* m-st-3 */

procedure m-parts-2 :
  define variable ind        as integer   no-undo.
  define variable varmessage as character no-undo.

  assign
    varlog = no
  .
  do transaction on error undo, return error return-value :
    message "Произвести пересортицу по всем товарам данной инвентаризации, не имеющих резервы?"
    view-as alert-box question buttons OK-Cancel update varlog.
    if varlog <> yes then do:
      return error.
    end.
    for each gds-list :
      delete gds-list .
    end.
    for each  ub.doc-line where ub.doc-line.doc-code  = t-doc.doc-code,
        first ub.goods where ub.goods.artic     = ub.doc-line.artic     and
                                 ub.goods.prod-type = ub.doc-line.prod-type and
                                 ub.goods.prod-code = ub.doc-line.prod-code no-lock
    on error undo, return error return-value
    :
      assign
        ind = ind + 1
      .
      run waitfram-join in this-procedure (  input "Перетасовка отрицательных партий. Строка " + string( ind ),
                                             input substitute( "Товар &1 &2 &3.",
                                                               ub.doc-line.artic,
                                                               ub.doc-line.prod-type,
                                                               ub.doc-line.prod-code ),
                                             input "",
                                            output varmessage ).
      run waitfram-show in this-procedure
        ( input varmessage
        ) no-error.
      assign
        line-rec = RECID( ub.doc-line )
      .
      run loc-cr-gds-dtl in this-procedure.
      assign
        unrv-qnty = 1
      .
      run trg/rsrv-dtl.p ( input        parparentproc,
                       input        {&rsrv-dtl_action_reserv-sozdanie},
                       buffer       ub.gds-dtl,
                       input-output unrv-qnty,
                       input-output ub.doc-line.price-base,
                       input-output ub.doc-line.price-rubl,
                       input        -1,
                       input "" ) NO-ERROR.
      if error-status :error then do:
        { cmp/gds-list.i gds-list assign }
        run waitfram-hide in this-procedure no-error.
        undo, next.
      end.
    end.
    run full-recalc in this-procedure.
    assign
      t-doc.re-grading-parts-minus = yes
    .
    display t-doc.re-grading-parts-minus with frame {&FRAME-NAME}.
  end. /* transaction */
  run waitfram-hide in this-procedure no-error.
  run UI-on         in this-procedure ( input "":U ).
  if can-find( first gds-list ) then do:
    assign
      varlog = no
    .
    message "По некоторым товарам не удалось уничтожить отрицательные партии." SKIP
            "Будете просматривать список этих товаров?"
      view-as alert-box buttons yes-no update varlog.
    if varlog = yes then do:
      run str/gds-list.w (input parparentproc, t-doc.host-code, t-doc.obj-type, t-doc.obj-code).
    end.
  end. /* can-find */
end procedure. /* m-parts-2 */

procedure local-delete :
  define variable rep-rec as recid no-undo.
  do on error undo, return error return-value :
    if not available ub.doc-line then do:
      message "Неправильно выбрана строка."
              view-as alert-box.
      return error.
    end.
    assign
      line-rec = recid( ub.doc-line )
      varlog    = no
    .
    message "Удалить строку документа" ub.doc-line.artic ub.goods.gds-name "?   Вы уверены ?"
                    view-as alert-box question buttons OK-Cancel update varlog.
    if varlog <> yes then do:
      return no-apply.
    end.
    get next {&BROWSE-NAME}.
    if available ub.doc-line then do:
      assign
        rep-rec = recid( ub.doc-line )
      .
    end.
    else do:
      reposition {&BROWSE-NAME} to recid line-rec no-error.
      get prev {&BROWSE-NAME}.
      if available ub.doc-line then do:
        assign
          rep-rec = recid( ub.doc-line )
        .
      end.
    end.
    reposition {&BROWSE-NAME} to recid line-rec no-error.
    find ub.doc-line where recid( ub.doc-line ) = line-rec.
    do transaction on error undo, return error return-value :
      find first ub.goods where ub.goods.artic     = ub.doc-line.artic     and
                               ub.goods.prod-type = ub.doc-line.prod-type and
                               ub.goods.prod-code = ub.doc-line.prod-code no-lock.
      for each ub.marking-attr exclusive-lock where (ub.marking-attr.attr-code = "inv-doc" or ub.marking-attr.attr-code = "inv-doc-scan")
        and can-find (first ub.marking where ub.marking.mark = ub.marking-attr.mark and ub.marking.gds-code = ub.goods.gds-code):
        delete ub.marking-attr.
      end.
      for each ub.utd no-lock where ub.utd.doc-code = ub.doc-line.doc-code:
        for each ub.utd-lines exclusive-lock where ub.utd-lines.db-num = ub.utd.db-num
          and ub.utd-lines.doc-id =  ub.utd.doc-id and ub.utd-lines.gds-code = ub.goods.gds-code:
          for each ub.utd-lines-attr exclusive-lock where ub.utd-lines-attr.db-num = ub.utd-lines.db-num
            and ub.utd-lines-attr.doc-id = ub.utd-lines.doc-id
            and ub.utd-lines-attr.LineNum = ub.utd-lines.LineNum:
            delete ub.utd-lines-attr.
          end.
          for each ub.utd-marking-lines exclusive-lock where ub.utd-marking-lines.db-num = ub.utd-lines.db-num
            and ub.utd-marking-lines.doc-id = ub.utd-lines.doc-id
            and ub.utd-marking-lines.LineNum = ub.utd-lines.LineNum:
            delete ub.utd-marking-lines.
          end.
          delete ub.utd-lines.
        end.
      end.
      run local-reclcinv in this-procedure ( input "old":U    ).
      run local-reclcinv in this-procedure ( input "delete":U ).
      run str/dellninv.p ( buffer ub.doc-line ).
    end.
    assign
      line-rec = ?
    .
    reposition {&BROWSE-NAME} to recid rep-rec no-error.
    run UI-on in this-procedure ( input "":U ).
  end. /* on error */
end procedure. /* local-delete */

procedure local-chg :
  do on error undo, return error return-value :
    if not available ub.doc-line then do:
      message "Неправильный выбор строки."
              view-as alert-box.
      return error.
    end.
    
    if v-is-marking and not v-is-introduce
    then do:
      message "Запрещено менять кол-во вручную для продукции подлежащей обязательной маркировке."
              view-as alert-box.
      return.      
    end.
    
    assign
      line-rec = recid( ub.doc-line )
    .
    find first ub.units   no-lock where ub.units.unit-name    = ub.goods.unit-base.
    find       ub.gds-prt no-lock where ub.gds-prt.upper-code = ub.goods.prt-root.
    assign
      prt-rec = recid( ub.gds-prt   )
    .
    /* Запомним старые значения суммы по документу */
    run local-reclcinv in this-procedure ( input "old":U ).
    {&upd-md}
    do transaction on error undo, return error return-value :
      /* В случае двух единиц измерения работаем через партии */
      if lookup( {&twounit}, ub.units.type ) > 0 then do:
         run str/parts-l.w
           (  input parparentproc
           ,  input t-doc.obj-type            /* v-obj-type   */
           ,  input t-doc.obj-code            /* v-obj-code   */
           ,  input ub.goods.gds-code         /* p-gds-code   */
           ,  input ub.doc-line.doc-code      /* p-doc-code   */
           ,  input line-mode                 /* p-edit-mode  */
           ,  input {&parts-l_parts-document} /* p-r-parts    */
           ,  input {&parts-l_object-current} /* p-one-all    */
           ,  input {&parts-l_call-document}  /* p-call-point */
           , output prt-rec                   /* part-recid   */
           ) .
      end.
      else do:
        if v-cntxp-doc-prt <> yes or ub.gds-prt.node-name = {&empty-scale} then do:
          run str/inv-prt.w (
          input parparentproc,
          input pardoc-rec,
          input line-rec,
          input recid(ub.goods),
          input {&inv-def},
          input recid (ub.gds-prt),
          input {&g#root} ).
          run ui-on in this-procedure ( input "no-query" ).
        end.
        else do:
          run str/inv-p.p
          ( parparentproc
           , recid(t-doc)
           ,line-rec
           ,recid(ub.goods)
           ,{&prt-def}    ).
        end.
      end.
      find first ub.doc-line where recid( ub.doc-line ) = line-rec.
      /* Нанесем инкремент на строку */
      run local-reclcinv in this-procedure ( input "update":U ).
    end. /* transaction */
    find first ub.doc-line no-lock where recid( ub.doc-line ) = line-rec no-error.
    if available ub.doc-line then do:
      display {&disp-list} with browse {&BROWSE-NAME}.
    end.
    run ui-on in this-procedure ( input "no-query" ).
  end. /* on error */
end procedure. /* local-chg */

procedure local-parts :
  if not available ub.doc-line then do:
    message "Неправильный выбор строки - партии недоступны."
            view-as alert-box.
    return error.
  end.
  assign
    line-rec = recid( ub.doc-line )
  .
  do transaction on error undo, return error return-value :
    if pardoc-mode <> {&lookup} then do:
      run local-reclcinv in this-procedure ( input "old":U ).
    end.
    {&upd-md}
    if pardoc-mode = {&update} then do:
      find t-doc        exclusive-lock where recid( t-doc) = pardoc-rec.
      find ub.doc-line  exclusive-lock where recid( ub.doc-line) = line-rec.
    end.
    run str/parts-l.w
      ( input parparentproc
      , input t-doc.obj-type            /* v-obj-type   */
      , input t-doc.obj-code            /* v-obj-code   */
      , input ub.goods.gds-code         /* p-gds-code   */
      , input ub.doc-line.doc-code      /* p-doc-code   */
      , input line-mode                 /* p-edit-mode  */
      , input {&parts-l_parts-document} /* p-r-parts    */
      , input {&parts-l_object-current} /* p-one-all    */
      , input {&parts-l_call-document}  /* p-call-point */
      , output prt-rec                  /* part-recid   */
      ) .
    if pardoc-mode <> {&lookup} then do:
      run local-reclcinv in this-procedure ( input "update":U ).
    end.
  end. /* transaction */
  find first ub.doc-line no-lock where recid( ub.doc-line ) = line-rec no-error.
  if available ub.doc-line then do:
    display {&disp-list} with browse {&BROWSE-NAME}.
  end.
  run ui-on in this-procedure ( input "no-query" ).
end procedure. /* local-parts */

procedure local-chk-doc :
define input parameter p-chk-doc-option as character no-undo .
DEFINE VARIABLE varrid-list as character no-undo .
define variable v-bttns as character no-undo .
define variable v-mode as character no-undo .
define variable old-type     as character no-undo.
define variable old-stat     as character no-undo.
define variable old-flag     as logical   no-undo.
define variable old-internal as logical   no-undo.
define variable loc-ref-list as character no-undo.

define buffer t-clients for clients.

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
define variable glog as logical no-undo .
define variable v-line-rec as recid no-undo .
  CASE p-chk-doc-option:
    when "chk-gds" then do:
      run str/invcdlin.w ( input parparentproc
                      ,input (if t-doc.status_ = {&permitted} then "b-calc,b-mark":U else '':U) /*bttns*/
                      ,input '':U /*p-mode*/
                      ,input t-doc.doc-code
                      ,input-output varrid-list) no-error.
      if error-status:error then do:
         message
         error-status:get-message(1)  skip
         return-value
         view-as alert-box error .
         .
      end.
      else do:
        if t-doc.status_ = {&permitted} then do:
          run UI-on         in this-procedure ( input "":U ).
        end.
      end.
    end.
    when {&lookup} then do:
      { str/snd-chkp.i t-doc.obj-code t-doc.obj-type t-clients v-cntxt-db-num db  glog YES}
      if NOT glog then return no-apply.
      assign
      v-bttns = (if t-doc.status_ = {&permitted}
                and pardoc-mode = {&update}
                then 'b-sel,b-mark':U
                else (if t-doc.status_ = {&wayb}
                     and t-doc.flag_ <> yes
                     and pardoc-mode = {&update}
                     then 'b-del':U
                     else '':U)
                )
      v-mode =  {&TDEDT_Inv}
      varrid-list = '':U
      .
      run str/chk-docs.w (
                     input parparentproc
                    ,input v-bttns
                    ,input v-mode
                    ,input ?
                    ,input t-doc.obj-type
                    ,input t-doc.obj-code
                    ,input t-doc.doc-code
                    ,input '':U
                    ,input ?
                    ,input ?
                    ,output varrid-list) no-error.
      if t-doc.status_ = {&permitted}
      and varrid-list <> "":U then do:
        message
        "Хотите посчитать количества по выделенным чекам инвентаризации?"
        view-as alert-box question buttons yes-no update glog.
        if glog then do:
          run str/inc-invd.w (
                           input parparentproc
                          ,input {&update}
                          ,input varrid-list
                          ,input ? /*p-chk-gds-recid*/
                          ,input t-doc.obj-type
                          ,input t-doc.obj-code
                          ,buffer t-doc
                          ) no-error .
          /*refresh*/
          if t-doc.status_ = {&permitted} and pardoc-mode = {&update} then do:
            run set-cource in this-procedure.
            run gbl/calc-trn.p ( input parparentproc, input recid( t-doc ) ).
            run str/clcsumga.p ( input t-doc.doc-code ).
          end.
          run UI-on         in this-procedure ( input "":U ).
        end.
      end.
    end. /*lookup*/
    when {&add-def} then do:
      run str/inc-invd.w (
                       input parparentproc
                      ,input {&add-def}
                      ,input varrid-list
                      ,input ?  /*p-chk-gds-recid*/
                      ,input t-doc.obj-type
                      ,input t-doc.obj-code
                      ,buffer t-doc
                      ) no-error .

        /*refresh*/
      if t-doc.status_ = {&permitted} and pardoc-mode = {&update} then do:
        run set-cource in this-procedure.
        run gbl/calc-trn.p ( input parparentproc, input recid( t-doc ) ).
        run str/clcsumga.p ( input t-doc.doc-code ).
      end.
      run UI-on         in this-procedure ( input "":U ).
    end.
  END CASE.
end.

end procedure. /* local-chk-doc */


procedure local-list :
define variable old-handle   as handle    no-undo.
define variable old-type     as character no-undo.
define variable old-stat     as character no-undo.
define variable old-flag     as logical   no-undo.
define variable old-internal as logical   no-undo.
define variable loc-ref-list as character no-undo.
define variable v-tmp-recid as recid no-undo .

define buffer old-doc for ub.trn-doc.

  do on error undo, return error return-value :
    assign
      old-handle   = br-handle
    .
    if t-doc.status_ =  {&wayb} and
       t-doc.flag_   <> yes     then do:
      /* добавление списком работает только в Накл -, в Разрешен - - кнопка добавить
         тем более что здесь используется doc-line.prt-ok, которое в Разрешен - имеет другой смысл */
      run str/use-list.p (input parparentproc, input-output line-rec, input recid(t-doc) , input yes , input ? ).
    end.
    else do:
      if t-doc.status_ = {&permitted} and pardoc-mode = {&update} then do:
        /* Мобильный сканер */
        run str/scan.p ( parparentproc, input no , input recid(t-doc) ,input ? ). /* добавление товаров запрещено, признаков - разрешено */
      end.
      else do:
        assign
          varlog = no
        .
        if t-doc.status_ = {&wayb} or t-doc.status_ = {&permitted} and t-doc.flag_ <> yes then do:
          assign
            varlog = yes
          .
          if can-find( first old-doc no-lock where old-doc.inv-num = t-doc.doc-code ) then do:
            assign
              varlog = no
            .
            message "Сформировать заново список документов, мешающих включению инвентаризации ?"
                            view-as alert-box question buttons Yes-No update varlog.
          end. /* can-find */
        end.
        if varlog then do:
          run str/inv-lst.p ( input parparentproc
                        , input t-doc.host-code
                        , input t-doc.obj-type
                        , input t-doc.obj-code
                        , input t-doc.doc-code ).
        end.

        v-tmp-recid = recid(t-doc).
        run str/all-docs.w ( input parparentproc,
                             input ?,
                             input ?,
                             input ?,
                             input {&confuse},
                             input ?,
                             input ?,
                             input ?,
                             input ?,
                             input "b-sel":U,
                             input ?,
                             input ?,
                             input recid(t-doc) ,
                             output loc-ref-list ).
   /* буфер t-doc почему-то ломается при повторном открытии new shared query br-docs */
        find t-doc no-lock where recid( t-doc ) = v-tmp-recid.
        apply "entry":U to b-exit in frame {&FRAME-NAME}.
      end.
      assign
        br-handle  = old-handle
      .
      if t-doc.status_ = {&permitted} and pardoc-mode = {&update} then do:
        run full-recalc in this-procedure.
      end.
    end.
    run UI-on in this-procedure ( input "":U ).
  end. /* on error */
end procedure. /* local-list */

procedure minus-string :
  define input-output parameter parstring as character no-undo.
  define input        parameter parvalue  as character no-undo.

  define variable loc-varvalue as character no-undo .
  define variable i        as integer   no-undo.
    do on error undo, return error return-value :

    do i = 1 to num-entries( parstring ) :
      if entry( i, parstring ) <> parvalue then do:
        assign
          loc-varvalue = loc-varvalue + min( loc-varvalue, "," ) + entry( i, parstring )
        .
      end.
    end.
    if parstring = loc-varvalue then do:
      return error substitute( "В строке &1 не найден элемент &2.", parstring, parvalue ).
    end.
    assign
      parstring = loc-varvalue
    .
  end. /* on error */
end procedure. /* minus-string */

procedure local-chg-wtol :
  define variable vartype  as character no-undo.

  do transaction on error undo, return error return-value :
    assign frame {&FRAME-NAME}
      varinvclcwtol
    .
    if varinvclcwtol = yes then do:
      message "Вы хотите рассчитать суммы естественной убыли?"
              "В дальнейшем суммы будут пересчитываться при каждом изменении в документе."
      view-as alert-box question buttons yes-no update varlog.
      if varlog = yes then do:
        { str/rcallfct.i t-doc.doc-code
                     yes
                     no
                     "this-procedure :handle"
                     tt-wast-line
                     tt-allsum-line
                     tt-doc-line-sum
                     tt-clcparts
                     temp-parts               no-error }
        { str/tdat-wrt.i t-doc.doc-code
                     {&trdcattr-clcaswt}
                     "yes"               }
      end. /* рассчитать суммы */
    end. /* varinvclcwtol = yes */
    else do: /* varinvclcwtol = no */
      message "Вы хотите не рассчитывать суммы естественной убыли при каждом изменении документа и пересчитать их на факт?"
      view-as alert-box question buttons yes-no update varlog.
      if varlog = yes then do:
        { str/tdat-val.i
              t-doc.doc-code
              {&trdcattr-addsum}
              varvalue
              vartype
              }
        run minus-string in this-procedure ( input-output varvalue, input {&sum-wastage-doc} ).
        if varinvclcspvalue = "yes" then do:
          run minus-string in this-procedure ( input-output varvalue, input {&sum-wastage-cli-doc} ).
        end.
        { str/tdat-wrt.i
              t-doc.doc-code
              {&trdcattr-addsum}
              varvalue
              }
        { str/tdat-wrt.i
              t-doc.doc-code
              {&trdcattr-clcaswt}
              "no"
              }
      end. /* не рассчитывать суммы */
    end. /* varinvclcwtol = no */
    run ui-on in this-procedure ( input "":U ).
  end. /* transaction */
end procedure. /* local-chg-wtol */

procedure local-chg-asol :
  define variable vartype     as character no-undo.

  do transaction on error undo, return error return-value :
    assign frame {&FRAME-NAME}
      varinvclcasol
    .
    if varinvclcasol = yes then do:
      message "Вы хотите рассчитать суммы по документу?" skip
              "В дальнейшем суммы будут пересчитываться при каждом изменении в документе."
      view-as alert-box question buttons yes-no update varlog.
      if varlog = yes then do:
        { str/rcallfct.i t-doc.doc-code
                     no
                     yes
                     "this-procedure :handle"
                     tt-wast-line
                     tt-allsum-line
                     tt-doc-line-sum
                     tt-clcparts
                     temp-parts               no-error }
        { str/tdat-wrt.i t-doc.doc-code
                     {&trdcattr-clcasol}
                     "yes"               }
      end. /* рассчитать суммы */
    end. /* varinvclcasol = yes */
    else do: /* varinvclcasol = no */
      message "Вы хотите не рассчитывать суммы по документу при каждом изменении документа и пересчитать их на факт?"
      view-as alert-box question buttons yes-no update varlog.
      if varlog = yes then do:
        { str/tdat-val.i t-doc.doc-code
                     {&trdcattr-addsum}
                     varvalue
                     vartype            }
        run minus-string in this-procedure ( input-output varvalue, input {&sum-general-doc} ) .
        run minus-string in this-procedure ( input-output varvalue, input {&sum-extra-doc}   ) .
        run minus-string in this-procedure ( input-output varvalue, input {&sum-miss-doc}    ) .
        run minus-string in this-procedure ( input-output varvalue, input {&sum-after-doc}   ) .
        if varinvclcspvalue = "yes" then do:
          run minus-string in this-procedure ( input-output varvalue, input {&sum-general-cli-doc} ) .
          run minus-string in this-procedure ( input-output varvalue, input {&sum-extra-cli-doc}   ) .
          run minus-string in this-procedure ( input-output varvalue, input {&sum-miss-cli-doc}    ) .
          run minus-string in this-procedure ( input-output varvalue, input {&sum-after-cli-doc}   ) .
        end.
        { str/tdat-wrt.i
            t-doc.doc-code
            {&trdcattr-addsum}
            varvalue
        }
        { str/tdat-wrt.i
             t-doc.doc-code
             {&trdcattr-clcasol}
             "no"
         }
      end. /* не рассчитывать */
    end. /* varinvclcasol = no */
  end. /* transaction */
end procedure. /* local-chg-asol */

procedure fnd-goods :
  if available  ub.doc-line then do:
     find first ub.goods no-lock where
                ub.goods.artic     = ub.doc-line.artic     and
                ub.goods.prod-type = ub.doc-line.prod-type and
                ub.goods.prod-code = ub.doc-line.prod-code.
     assign
       gds-rec = recid( ub.goods )
     .
  end.
  else do:
  assign
    gds-rec = ?
  .
  end.
end procedure. /* fnd-goods */

procedure local-reclcinv :
  define input parameter parmode as character no-undo.

  do on error undo, return error return-value :
    { str/reclcinv.i
        parmode
        recid(ub.doc-line)
        t-doc.doc-code
        vartot-docold
        vartot-rublold
        i-total-doc-line_tot-ovold
        i-total-doc-line_fact-rublold
        i-total-doc-line_fact-baseold
        i-total-doc-line_fact-qntyold
        i-total-doc-line_doc-qntyold
        i-total-doc-line_cli-qntyold
        i-total-parts_fact-baseold
        i-total-parts_fact-rublold
        i-total-parts_fact-qntyold
    }
  end. /* on error */
end procedure. /* local-reclcinv */

procedure local-updprt- :
  if not available ub.doc-line then do:
    message "Неправильный выбор строки - партии недоступны."
            view-as alert-box.
    return error.
  end.
  assign
    line-rec = RECID( ub.doc-line )
  .
  do transaction on error undo, return error return-value :
    run local-reclcinv in this-procedure ( input "old":U ).
    {&upd-md}
    if pardoc-mode = {&update} then do:
      find t-doc       exclusive-lock where recid( t-doc       ) = pardoc-rec.
      find ub.doc-line exclusive-lock where recid( ub.doc-line ) = line-rec.
    end.

    define variable v-parts-recid as recid no-undo .
    run str/partsneg.w
      (input  parparentproc
      ,input  ub.doc-line.doc-code
      ,input  {&update}
      ,input-output v-parts-recid
      ).
    run local-reclcinv in this-procedure ( input "update":U ) .
  end. /* transaction */
end procedure. /* local-updprt- */

procedure full-recalc:
  run set-cource in this-procedure.
  run gbl/calc-trn.p ( input parparentproc, input recid( t-doc ) ).
  run str/clcsumga.p ( input t-doc.doc-code ).
end procedure.

/* ****************************************************************************************************************** *\
_____________________________________________________________________________________________________________
|                          |                           |                                                    |
| Было                     | Стало                     | Разница                                            |
|__________________________|___________________________|____________________________________________________|
|                          |                           |                                                    |
| inv-line.before-cli-qnty |   inv-line.after-cli-qnty | inv-line.after-cli-qnty - inv-line.before-cli-qnty |
|                          | = inv-line.wast-cli-qnty  | = doc-line.cli-qnty                                |
|__________________________|___________________________|____________________________________________________|

\* ****************************************************************************************************************** */
procedure inv-line_qnty :
  define  input parameter p-doc-line-rec as recid     no-undo.
  define  input parameter p-mode         as character no-undo.
  define output parameter p-qnty-kg      as decimal   no-undo.

  define buffer buf_doc-line for ub.doc-line.
  define buffer buf_inv-line for ub.inv-line.

  do on error undo, return error return-value :
    find first buf_doc-line no-lock where
        recid( buf_doc-line ) = p-doc-line-rec no-error.
    if not available buf_doc-line then do:
      assign
        p-qnty-kg = ?
      .
      return.
    end.

    find first buf_inv-line no-lock where
               buf_inv-line.doc-code  = buf_doc-line.doc-code  and
               buf_inv-line.artic     = buf_doc-line.artic     and
               buf_inv-line.prod-type = buf_doc-line.prod-type and
               buf_inv-line.prod-code = buf_doc-line.prod-code no-error.
    if not available buf_inv-line then do:
      assign
        p-qnty-kg = ?
      .
      return.
    end.

    case p-mode :
      when "was"  then do:
        assign
          p-qnty-kg = buf_inv-line.before-cli-qnty
        .
      end.
      when "are"  then do:
        assign
          p-qnty-kg = buf_inv-line.wast-cli-qnty
        .
      end.
      when "diff" then do:
        assign
          p-qnty-kg = buf_doc-line.cli-qnty
        .
      end.
    end case. /* p-mode */
  end. /* on error */
end procedure. /* inv-line_qnty */

procedure check-reason :
  define variable j_rsn-code like ub.trn-reason.reason-code no-undo.

  define buffer bf_trn-reason for ub.trn-reason.

  do on error undo, return error return-value :
    assign j_rsn-code = ( input frame {&FRAME-NAME} t-doc.reason-code ).
    find first bf_trn-reason no-lock where
               bf_trn-reason.reason-code = j_rsn-code no-error.
    if not available bf_trn-reason then do:
      if j_rsn-code <> ? and j_rsn-code <> 0 then do:
        message "Неверно указано основание (причина) создания документа." view-as alert-box error.
      end.
      assign
        rsn-name = "":U
      .
      display rsn-name with frame {&FRAME-NAME}.
      if j_rsn-code = ? or j_rsn-code = 0 then do:
        assign
          t-doc.reason-code = 0
        .
        return.
      end.
      else do:
        undo, return error.
      end.
    end.
    assign
      rsn-name = bf_trn-reason.reason-name
    .
    display rsn-name with frame {&FRAME-NAME}.
    assign
      frame {&FRAME-NAME} t-doc.reason-code
    .
  end. /* on error */
end procedure. /* check-reason */

procedure select-reason :
  define variable j-rsn-code like ub.trn-reason.reason-code no-undo.

  define buffer bf_trn-reason for ub.trn-reason.

  do on error undo, return error return-value :
    assign
      j-rsn-code = ( input frame {&FRAME-NAME} t-doc.reason-code )
    .
    run str/trn-reas.w ( input ParParentProc, input {&choose}, input-output j-rsn-code ).
    find first bf_trn-reason no-lock where
               bf_trn-reason.reason-code = j-rsn-code no-error.
    if available bf_trn-reason then do:
      assign
        rsn-name          = bf_trn-reason.reason-name
        t-doc.reason-code = bf_trn-reason.reason-code
      .
      display t-doc.reason-code
              rsn-name
      with frame {&FRAME-NAME}.
    end.
  end. /* on error */
end procedure. /* select-reason */

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

define variable v-value-character as character no-undo .
define variable v-value-date      as date no-undo .
define variable v-value-decimal   as decimal no-undo .
define variable v-value-integer   as integer no-undo .
define variable v-value-logical   as logical no-undo .
define variable v-tth             as handle no-undo .
define variable v-back-date as logical   no-undo .
define variable v-back-date-type as character no-undo .

 if t-doc.fact-date < v-today then do:
      delete object v-tth no-error.
      run adm/shattri.p (
           input "get":U
          ,input v-cntxt-obj-type
          ,input v-cntxt-obj-code
          ,input {&attr-nakl_par}
          ,input  "back-date"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-back-date
          ,output v-back-date-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
          if error-status :error  then v-back-date = false .
          delete object v-tth no-error.
    if v-back-date <> true then do:
      message "Запрещено работать задним числом !" view-as alert-box information .
      display t-doc.fact-date with frame {&frame-name}.
      return error.
    end.
 end.

  assign varlog = no.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_inventory_add-back-date':U
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
  assign
    t-doc.fact-time = (24 * 60 * 60)
    .

end.

END PROCEDURE.
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
          assign
            t-doc.fact-date = t-doc.shift-date
            t-doc.fact-time = (24 * 60 * 60).
          display t-doc.fact-date with frame {&frame-name}.
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
        if t-doc.fact-date = ? then do: assign t-doc.fact-date = t-doc.shift-date t-doc.fact-time = (24 * 60 * 60). display t-doc.fact-date with frame {&frame-name}. end.
      end.
    end.
  end.
end procedure.
PROCEDURE proc-sht :
define buffer bf_shift-obj   for ub.shift-obj.
  define variable varrid-list as character no-undo.
  define variable varrecid    as recid     no-undo.
  assign
    varrid-list = "".
  run str/sht-all.w (parparentproc, t-doc.obj-type, t-doc.obj-code, 'b-sel', 'obj', t-doc.obj-type, t-doc.obj-code,'':u, input-output varrid-list) no-error.
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
        assign
          t-doc.fact-date = t-doc.shift-date
          t-doc.fact-time = (24 * 60 * 60).
        display t-doc.fact-date with frame {&frame-name}.
      end.
    end.
  end.

END PROCEDURE.


procedure ver-price :

define buffer buf_gds-dtl for ub.gds-dtl  .
  do
  on error undo, return error return-value
  :
    if pardoc-mode <> {&update} then return .
    if t-doc.status_ <> {&permitted} then return .
    run  waitfram-show in this-procedure  ("Проверка цены ...") .
    for each buf_gds-dtl where buf_gds-dtl.doc-code = t-doc.doc-code :
        if buf_gds-dtl.price-rubl = 0 or buf_gds-dtl.price-rubl = ? then do:
           { str/set-pr.i recid(buf_gds-dtl) no ? no-error }
            if buf_gds-dtl.price-rubl = 0 or buf_gds-dtl.price-rubl = ? then do:
               v-long-char = v-long-char + substitute(" Сделайте переоценку по товару : &1;&2;&3 " ,
               buf_gds-dtl.artic, buf_gds-dtl.prod-type, buf_gds-dtl.prod-code )  + {&new-line} .
            end.
        end.
    end.

    define buffer buf_doc-line for ub.doc-line  .
    define buffer buf_gds-obj for ub.gds-obj  .
    for each buf_doc-line no-lock where
             buf_doc-line.doc-code = t-doc.doc-code :
        find first buf_gds-obj no-lock where
                   buf_gds-obj.artic = buf_doc-line.artic and
                   buf_gds-obj.prod-type = buf_doc-line.prod-type and
                   buf_gds-obj.prod-code = buf_doc-line.prod-code and
                   buf_gds-obj.obj-type = t-doc.obj-type and
                   buf_gds-obj.obj-code = t-doc.obj-code no-error .
        if not available buf_gds-obj or buf_gds-obj.price-sale = 0 then do:
           find first buf_gds-dtl no-lock where
                   buf_gds-dtl.doc-code = buf_doc-line.doc-code and
                   buf_gds-dtl.artic = buf_doc-line.artic and
                   buf_gds-dtl.prod-type = buf_doc-line.prod-type and
                   buf_gds-dtl.prod-code = buf_doc-line.prod-code no-error .
                 if not available buf_gds-dtl then do:
                    v-long-char = v-long-char + substitute(" Нет переоценки по товару : &1;&2;&3 " ,
                    buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code )  + {&new-line} .
                 end.

        end.


    end.

  run waitfram-hide in this-procedure .
  if v-long-char <> "" then do:
  define variable v-ok as logical   no-undo .
  run gbl/d-longchar.w (
        ?,
        'Editor_row=2\':u
      + 'title=Мешает инвентаризации (Если количество не будет = 0 ):\':u
      + 'Editor_col=1\':u
      + 'Editor_width=96\':u
      + 'Editor_height=21\':u
      + 'readonly=yes\':u
    ,input-output v-long-char
    ,output v-ok ) no-error .

    end.
  end.

end procedure. /* ver-price */

procedure go-line :
  
  define input parameter rec as recid no-undo.

  run UI-on in this-procedure ( input "":U ).
  if rec ne ?
    then reposition {&BROWSE-NAME} to recid rec .
  
end procedure.
