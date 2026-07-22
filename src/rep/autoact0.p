block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: autoact0.p $
$Archive: rep/autoact0.p $

Печать акта автоматической переоценки (весовой учет топлива)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/30/09
Author: Dmitry Ukhanov
Creation date: 01/30/09

Автор1: Булгаков Андрей Николаевич
Дата создания1: 05/16/05

*/

define input parameter parparentproc as widget-handle no-undo.
define input parameter rec_id        as recid         no-undo.
define input parameter p-mode        as character     no-undo.

&scop def       def sale-price,cli-qnty
&scop comm-pars ub.gds-dtl.doc-code ub.goods.artic ub.goods.prod-type ub.goods.prod-code
&scop f-l       Word-Sum,Total-Word,RedLine,Roubles,Copecks

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U.
define variable vss-author      as character no-undo initial "$Author: expertek $":U.
define variable vss-date        as character no-undo initial "$date: 12.09.03 15:57 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: autoact0.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: rep/autoact0.p $":U.
define variable vss-description as character no-undo initial "Печать акта автоматической переоценки (весовой учет топлива)".

{ cmp/vssrevis.i        }
{ cmp/str-glbl.i        }
{ cmp/library.i         }
{ gbl/cur-time.i        }
{ cmp/r-pril.i          }
{ str/trdcalib.i        }
{ str/lib-trn.i         }
{ gbl/std-func.i {&f-l} }
{ str/invlnsum.i {&def} }
{ gbl/getcntxt.i def    }
{ gbl/getcntxt.i get    }
{ str/getctxtp.i def    }
{ str/getctxtp.i get    }
{ gbl/getsect.i  def    }
define variable g#report-num  as integer   no-undo.
define variable g#quest-print as logical   no-undo.
define variable g#log         as logical   no-undo.
define variable base-code     as integer   no-undo.
define variable base-type     as character no-undo.
define variable base-part     as character no-undo.
define variable v-cntxt-host-name-obj as character no-undo .

define buffer buf_rep_currency for ub.currency.
{ gbl/hostname.i v-cntxt-obj-type v-cntxt-obj-code v-cntxt-host-code-obj v-cntxt-host-name-obj }
{ gbl/basecode.i v-cntxt-host-code-obj base-code }

find first buf_rep_currency no-lock where
           buf_rep_currency.curr-code = base-code
           no-error .
  if available buf_rep_currency
    then do:
      assign
        base-type = buf_rep_currency.curr-abbr
        base-part = buf_rep_currency.part-abbr
      .
    end.
    else do:
      assign
        base-type = "б.в."
        base-part = ""
      .
    end.
run get-report-num  in parparentproc ( output g#report-num ).
run get-quest-print in parparentproc ( output g#quest-print ) .

define variable price-doc        as decimal   no-undo.
define variable doc-sum          as decimal   no-undo.
define variable obj-sum          as decimal   no-undo.
define variable propis           as character no-undo.
define variable abbr             as character no-undo.
define variable Delt             as character no-undo.
define variable v-single-line    as character no-undo.
define variable sym1             as character no-undo initial ":".
define variable sym2             as character no-undo initial ":".
define variable tb-code          as character no-undo.
define variable tdoc-date        as date      no-undo.
define variable tdoc-code        as character no-undo.
define variable v-nids           as character no-undo.
define variable v-parameter-type as character no-undo.
define variable v-rb-is-base     as logical   no-undo.
define variable is-petrol        as logical   no-undo.
define variable is-pieces        as logical   no-undo.
define variable d_qnty-kg        as decimal   no-undo.
define variable d_sale-price     as decimal   no-undo.
define variable d_sale-sum       as decimal   no-undo.
define variable d_obj-price      as decimal   no-undo.
define variable d_obj-sum        as decimal   no-undo.
define variable d_delta          as decimal   no-undo.
define variable d_cli-rate       as decimal   no-undo.
define variable total_qnty-kg    as decimal   no-undo.
define variable total_sale-sum   as decimal   no-undo.
define variable total_obj-sum    as decimal   no-undo.
define variable total_delta      as decimal   no-undo.
define variable total_percent    as decimal   no-undo.
define variable j_total          as integer   no-undo.
define variable print_rubl       as logical   no-undo.

define buffer t-doc    for ub.trn-doc.
define buffer Our_Host for ub.clients.

define stream s-out.

define frame PrintFrame_Act-base
  sym1                 column-label ":!:"                       format "x(1)":U space( 0 )
  tb-code              column-label "Код! "                     format "x({&BarCode_Length})":U
  ub.gds-dtl.artic     column-label "Артикул! "                 format "x(16)":U
  ub.goods.gds-name    column-label "Название товара! "         format "x(30)":U
  ub.gds-dtl.fact-qnty column-label "Количество  ! "            format "->>>>>>9.<<<":U
  price-doc            column-label "Цена по!докум.(вал)"       format ">>>>>>9.99":U
  doc-sum              column-label "Сумма по!докум.(вал)"      format "->>>>>>>>9.99":U
  ub.gds-dtl.cur-base  column-label "Цена по!объекту(вал)"      format ">>>>>>9.99":U
  obj-sum              column-label "Сумма цен по!объекту(вал)" format "->>>>>>>>9.99":U
  Delt                 column-label "Процент!разницы"           format "x(8)":U
  sym2                 column-label ":!:"                       format "x(1)":U space( 0 )
header
  cur-time-print( )                                      at   5 format "x(35)":U
  string( "Акт автоматической переоценки по документу N " + tdoc-code + " от " +
  string( tdoc-date,"99/99/9999":U ) )                   at  40 format "x(80)":U
  string( "Страница " + string( page-number( s-out ) ) ) at 120 format "x(15)":U  skip
  v-single-line                                          at   1 format "x(136)":U
with width {&DOS_CW} down stream-io.

define frame PrintFrame_Act-rubl
  sym1                 column-label ":!:"                               format "x(1)":U space( 0 )
  tb-code              column-label "Код! "                             format "x({&BarCode_Length})":U
  ub.gds-dtl.artic     column-label "Артикул! "                         format "x(16)":U
  ub.goods.gds-name    column-label "Название товара! "                 format "x(30)":U
  ub.gds-dtl.fact-qnty column-label "Количество  ! "                    format "->>>>>>9.<<<":U
  price-doc            column-label "Цена по!докум.({&abbr_rub})"       format ">>>>>>9.99":U
  doc-sum              column-label "Сумма по!докум.({&abbr_rub})"      format "->>>>>>>>9.99":U
  ub.gds-dtl.cur-base  column-label "Цена по!объекту({&abbr_rub})"      format ">>>>>>9.99":U
  obj-sum              column-label "Сумма цен по!объекту({&abbr_rub})" format "->>>>>>>>9.99":U
  Delt                 column-label "Процент!разницы"                   format "x(8)":U
  sym2                 column-label ":!:"                               format "x(1)":U space( 0 )
header
  cur-time-print( )                                      at   5 format "x(35)":U
  string( "Акт автоматической переоценки по документу N " + tdoc-code + " от " +
  string( tdoc-date,"99/99/9999":U ) )                   at  40 format "x(80)":U
  string( "Страница " + string( page-number( s-out ) ) ) at 120 format "x(15)":U  skip
  v-single-line                                          at   1 format "x(136)":U
with width {&DOS_CW} down stream-io.

{ gbl/rbisbase.i v-rb-is-base }
assign v-single-line = fill( "-", 200 )
       print_rubl    = ( v-rb-is-base <> yes ).
find first t-doc no-lock where recid( t-doc ) = rec_id.

define variable FullGdsName as logical   no-undo .
define variable tmp-var  as character no-undo .

{ gbl/getsect.i run t-doc.obj-type t-doc.obj-code {&attr-prt-obj} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'FGdsNinD' then tmp-var =  string(thbjattr_thbj-attr.property-value-logical) .
end.
FullGdsName = (tmp-var = "yes") .

assign tdoc-date = t-doc.doc-date
       tdoc-code = t-doc.doc-code.
find first Our_Host no-lock where
           Our_Host.obj-type = {&cmp} and
           Our_Host.obj-code = t-doc.host-code.

{ cmp/open-out.i stream s-out " " {&LS_PS_A4} }

put stream s-out space( 90 ) Our_Host.obj-name format "x(40)":U skip( 2 )
                 space( 20 ) "А К Т   П Е Р Е О Ц Е Н К И   ( автоматической ) по документу  N " format "x(80)":U
                 t-doc.doc-code format "x(10)":U "  от  " t-doc.doc-date format "99.99.9999":U skip( 1 ).
if lookup( "ParCom":U, p-mode ) <> 0 then do:
  if t-doc.doc-type = {&income} and t-doc.internal <> yes then do:
    put stream s-out substitute( "Основание: накладная поставщика N &1 от &2", t-doc.ord-num,
                     string( t-doc.ship-date, "99.99.9999":U ) ) format "x(110)":U skip( 1 ).
  end.
end.
else do:
  if t-doc.doc-type = {&income} and t-doc.internal <> yes then do:
    { str/tdat-val.i t-doc.doc-code
                 {&trdcattr-nids}
                 v-nids
                 v-parameter-type }
    if v-nids <> "":U and v-nids <> ? then do:
      put stream s-out space( 20 ) "Основание: накладная поставщика N: " v-nids format "x(110)":U skip( 1 ).
    end.
  end.
end.

if t-doc.doc-type = {&income}
  or t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
then do:
  put stream s-out space( 20 ) string( "ПОСТАВЩИК : " + t-doc.cli-name ) format "x(90)":U skip( 1 ).
end.

form header
  v-single-line format "x(136)":U       at  1 skip
  "Продолжение - на следующей странице" at 30 skip
with frame Bottomframe width {&DOS_CW} page-bottom no-labels no-box.
view stream s-out frame Bottomframe.

if v-rb-is-base = yes then do: form with frame PrintFrame_Act-base. end.
                      else do: form with frame PrintFrame_Act-rubl. end.
for each ub.doc-line no-lock where ub.doc-line.doc-code = t-doc.doc-code
  , each ub.gds-dtl  no-lock where
         ub.gds-dtl.doc-code  = ub.doc-line.doc-code  and
         ub.gds-dtl.artic     = ub.doc-line.artic     and
         ub.gds-dtl.prod-type = ub.doc-line.prod-type and
         ub.gds-dtl.prod-code = ub.doc-line.prod-code and
         ub.gds-dtl.ov        = yes
  , each ub.goods    no-lock where
         ub.goods.prod-type = ub.gds-dtl.prod-type and
         ub.goods.prod-code = ub.gds-dtl.prod-code and
         ub.goods.artic     = ub.gds-dtl.artic
break by ub.gds-dtl.artic
      by ub.gds-dtl.prt-code
:
  { str/is-petrl.i ub.goods.artic
               ub.goods.prod-type
               ub.goods.prod-code
               is-petrol
               is-pieces          no-error }
  if error-status :error or is-petrol <> yes or is-pieces <> no then do: next. end.
  find first ub.bar-code no-lock where
             ub.bar-code.gds-code  = ub.goods.gds-code   and
             ub.bar-code.unit-cli  = ub.goods.unit-base  and
             ub.bar-code.node-code = ub.gds-dtl.prt-code and
             ub.bar-code.part-code = "":U                and
             ub.bar-code.in-code   = "":U                no-error.
  assign j_total          =   j_total                      + 1
         d_qnty-kg        = { str/invlnsum.i exe cli-qnty   {&comm-pars} }
         d_cli-rate       =   ub.gds-dtl.fact-qnty         / d_qnty-kg
         d_obj-price      =   ub.gds-dtl.cur-base          * d_cli-rate
         d_obj-sum        =   d_obj-price                  * d_qnty-kg
         d_sale-price     = { str/invlnsum.i exe sale-price {&comm-pars} print_rubl }
         d_sale-sum       =   d_sale-price                 * d_qnty-kg
         d_delta          = ( d_obj-price - d_sale-price ) / d_sale-price * 100
         total_qnty-kg    = total_qnty-kg                  + d_qnty-kg
         total_sale-sum   = total_sale-sum                 + d_sale-sum
         total_obj-sum    = total_obj-sum                  + d_obj-sum
         total_delta      = total_delta                    + d_obj-sum    - d_sale-sum.
  if v-rb-is-base = yes then do:
    display stream s-out sym1   trim( string( ub.bar-code.b-code ) )         @ tb-code
                                              ub.gds-dtl.artic
                                              ub.goods.gds-name
                                              d_qnty-kg                      @ ub.gds-dtl.fact-qnty
                                              d_sale-price                   @ price-doc
                                              d_sale-sum                     @ doc-sum
                                              d_obj-price                    @ ub.gds-dtl.cur-base
                                              d_obj-sum                      @ obj-sum
                              string( string( d_delta, "->>>9.9":U ) + "%" ) @ Delt sym2
    with frame PrintFrame_Act-base.
    down stream s-out 1 with frame PrintFrame_Act-base.
    IF LENGTH(ub.goods.gds-name, "CHARACTER") > 30 and FullGdsName THEN  do:
      assign propis = SUBSTRING(ub.goods.gds-name,31) .
      DISPLAY stream s-out sym1 propis @ ub.goods.gds-name  sym2   with frame PrintFrame_Act-base .
      down stream s-out 1 with frame PrintFrame_Act-base .
    end.
  end. /* if v-rb-is-base = yes */
  else do:
    display stream s-out sym1   trim( string( ub.bar-code.b-code ) )         @ tb-code
                                              ub.gds-dtl.artic
                                              ub.goods.gds-name
                                              d_qnty-kg                      @ ub.gds-dtl.fact-qnty
                                              d_sale-price                   @ price-doc
                                              d_sale-sum                     @ doc-sum
                                              d_obj-price                    @ ub.gds-dtl.cur-base
                                              d_obj-sum                      @ obj-sum
                              string( string( d_delta, "->>>9.9":U ) + "%" ) @ Delt sym2
    with frame PrintFrame_Act-rubl.
    down stream s-out 1 with frame PrintFrame_Act-rubl.
    IF LENGTH(ub.goods.gds-name, "CHARACTER") > 30 and FullGdsName THEN  do:
      assign propis = SUBSTRING(ub.goods.gds-name,31) .
      DISPLAY stream s-out sym1 propis @ ub.goods.gds-name  sym2   with frame PrintFrame_Act-rubl .
      down stream s-out 1 with frame PrintFrame_Act-rubl .
    end.
  end. /* if v-rb-is-base <> yes */
  if last( ub.gds-dtl.artic ) then do:
    assign total_percent = total_delta / total_sale-sum * 100.
    if v-rb-is-base = yes then do:
      /* down stream s-out 1 with frame PrintFrame_Act-base. */
      put     stream s-out v-single-line format "x(136)":U skip.
      display stream s-out "  ИТОГО"                                            @ ub.goods.gds-name
                                           total_qnty-kg                        @ ub.gds-dtl.fact-qnty
                                           total_sale-sum                       @ doc-sum
                                           total_obj-sum                        @ obj-sum
                           string( string( total_percent, "->>>9.9":U ) + "%" ) @ Delt
      with frame PrintFrame_Act-base.
      underline stream s-out ub.goods.gds-name
                             ub.gds-dtl.fact-qnty
                             doc-sum
                             obj-sum
                             Delt
      with frame PrintFrame_Act-base.
      down stream s-out 2 with frame PrintFrame_Act-base.
    end. /* if v-rb-is-base = yes */
    else do:
      /* down stream s-out 1 with frame PrintFrame_Act-rubl. */
      put     stream s-out v-single-line format "x(136)":U skip.
      display stream s-out "  ИТОГО"                                            @ ub.goods.gds-name
                                           total_qnty-kg                        @ ub.gds-dtl.fact-qnty
                                           total_sale-sum                       @ doc-sum
                                           total_obj-sum                        @ obj-sum
                           string( string( total_percent, "->>>9.9":U ) + "%" ) @ Delt
      with frame PrintFrame_Act-rubl.
      underline stream s-out ub.goods.gds-name
                             ub.gds-dtl.fact-qnty
                             doc-sum
                             obj-sum
                             Delt
      with frame PrintFrame_Act-rubl.
      down stream s-out 2 with frame PrintFrame_Act-rubl.
    end. /* if v-rb-is-base <> yes */
  end. /* if last( ub.gds-dtl.artic ) */
end. /* for each ... */
hide stream s-out frame Bottomframe.

if v-rb-is-base = yes then do:
  assign propis = Total-Word(          absolute( total_delta ), base-type, base-part )
         abbr   = base-type.
end.                  else do:
  assign propis = Total-Word(          absolute( total_delta ),
                              Roubles( absolute( total_delta ) ),
                              Copecks( absolute( total_delta ) ) )
         abbr   = " {&abbr_rub}.".
end.
put stream s-out space( 10 ) "Всего  " j_total                format ">>>>9":U
                             " наименований."                 format "x(15)":U skip( 1 )
                 space( 10 ) "Разница в суммах составила :  " format "x(35)":U
                             total_delta                      format "->,>>>,>>>,>>9.99":U
                 space(  2 ) trim( abbr )                     format "x(3)":U  skip( 1 ).
if line-counter( s-out ) + 4 > page-size( s-out ) then do: page stream s-out. end.

put stream s-out space( 10 ) ( if trim( propis ) begins trim( abbr ) then "0 " else "":U ) + propis format "x(120)":U skip( 2 ).
put stream s-out space( 20 ) "Зав. складом/Зав. секцией : " format "x(30)":U skip.
output stream s-out close.

{ rep/q-print.i 8 }