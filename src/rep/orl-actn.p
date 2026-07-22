block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: orl-actn.p $
$Archive: rep/orl-actn.p $

Печать акта приемки-передачи топливных товаров (весовой учет)

Автор: Булгаков Андрей Николаевич
Дата создания: 05/17/05
Author: Andrew Bulgakoff
Creation date: 05/17/05

*/

define input parameter parparentproc as widget-handle no-undo.
define input parameter rec_id        as recid         no-undo.
define input parameter prod-price    as logical       no-undo.

&scop def       def sale-price,cli-qnty
&scop comm-pars ub.gds-dtl.doc-code ub.goods.artic ub.goods.prod-type ub.goods.prod-code
&scop f-l       Word-Sum,Total-Word,RedLine,Roubles,Copecks

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U.
define variable vss-author      as character no-undo initial "$Author: expertek $":U.
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: orl-actn.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: rep/orl-actn.p $":U.
define variable vss-description as character no-undo initial "Печать акта приемки-передачи топливных товаров (весовой учет)":U.

{ cmp/vssrevis.i        }
{ cmp/str-glbl.i        }
{ cmp/library.i         }
{ gbl/cur-time.i        }
{ str/get-pr.i     def  }
{ cmp/r-pril.i          }
{ str/in-vatp.i    def  }
{ str/out-vatp.i   def  }
{ str/trdcalib.i        }
{ str/lib-trn.i         }
{ gbl/std-func.i {&f-l} }
{ str/invlnsum.i {&def} }
{ str/valddnst.i   def  }
{ gbl/getcntxt.i def    }
{ gbl/getcntxt.i get    }
{ str/getctxtp.i def    }
{ str/getctxtp.i get    }

define variable base-type as character no-undo .
define variable base-code as integer   no-undo .
define variable g#report-num as integer   no-undo .
define variable v-cntxt-host-name-obj as character no-undo .
define variable g#quest-print as logical   no-undo.
define variable g#log         as logical   no-undo.
define variable base-part     as character no-undo.

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




&scop rate-calc-rubl-base * 1
&scop temp-road-tax       {&road-tax-cur} / v-density
&glob SLT-calc-ov         ( price-lst - ~{&road-tax-cur} / v-density ) * t-doc-line.SLT-pc / ( 100 + t-doc-line.SLT-pc )
&scop slt-temp            {&slt-calc} / v-density

define variable sum-no-VAT              as   decimal                     no-undo.
define variable doc-sum                 as   decimal                     no-undo.
define variable obj-sum                 as   decimal                     no-undo.
define variable v-tax-sum               as   decimal                     no-undo. /* Третий налог (road-tax) */
define variable SLT-sum                 as   decimal                     no-undo.
define variable VAT-sum                 as   decimal                     no-undo.
define variable VAT-gds                 as   decimal                     no-undo.
define variable marg                    as   decimal                     no-undo.
define variable price-lst               as   decimal                     no-undo.
define variable v-dids                  like ub.doc-line-attr.attr-value no-undo.
define variable v-nids                  like ub.doc-line-attr.attr-value no-undo.
define variable v-attr-type             as   character                   no-undo.
define variable v-vat-pc                like ub.doc-line.vat-pc          no-undo.
define variable v-slt-pc                like ub.doc-line.slt-pc          no-undo.
define variable v-host-code             like ub.sysconf.host-code        no-undo.
define variable v-explname              as   character                   no-undo.
define variable v-storeman              as   character                   no-undo.
define variable v-main-boss             as   character                   no-undo.
define variable v-main-buh              as   character                   no-undo.
define variable propis                  as   character                   no-undo.
define variable abbr                    as   character                   no-undo.
define variable UpFact                  as   character                   no-undo.
define variable Delt                    as   character                   no-undo.
define variable Line                    as   character                   no-undo.
define variable v-rb-is-base            as   logical                     no-undo.
define variable v-price-rb              as   decimal                     no-undo.
define variable sym1                    as   character                   no-undo initial ":".
define variable sym2                    as   character                   no-undo initial ":".
define variable tb-code                 as   character                   no-undo.
define variable tdoc-date               like ub.trn-doc.doc-date         no-undo.
define variable tdoc-code               like ub.trn-doc.doc-code         no-undo.
define variable v-density               like ub.doc-line.doc-density         no-undo initial 0.0.
define variable v-fact-qnty-kg          as   decimal                     no-undo.
define variable is-petrol               as   logical                     no-undo.
define variable is-pieces               as   logical                     no-undo.
define variable doc-price               as   decimal                     no-undo.
define variable d_delta                 as   decimal                     no-undo.
define variable total_qnty-kg           as   decimal                     no-undo.
define variable total_SLT-sum           as   decimal                     no-undo.
define variable total_VAT-sum           as   decimal                     no-undo.
define variable total_no-VAT            as   decimal                     no-undo.
define variable total_obj-sum           as   decimal                     no-undo.
define variable total_doc-sum           as   decimal                     no-undo.
define variable total_delta             as   decimal                     no-undo.
define variable total_up-fact           as   decimal                     no-undo.
define variable j_total                 as   integer                     no-undo.
define variable print_rubl              as   logical                     no-undo.

define buffer t-doc            for ub.trn-doc.
define buffer buf_host_clients for ub.clients.

define temp-table t-doc-line no-undo like ub.doc-line.

define stream s-out.

define frame PrintFrame_ActTransceiving
  sym1                 column-label ":!:"                   format "x(1)":U                 space( 0 )
  tb-code              column-label "Код! "                 format "x({&BarCode_Length})":U
  ub.gds-dtl.artic     column-label "Артикул! "             format "x(16)":U
  ub.goods.gds-name    column-label "Название товара! "     format "x(22)":U
  ub.gds-dtl.fact-qnty column-label "Количество ! "         format ">>>>>>9.<<<":U
  doc-price            column-label "Цена без!НДС"          format ">>>>>>9.99":U
  sum-no-VAT           column-label "Сумма без!НДС"         format "->>>>>>>>9.99":U
  doc-sum              column-label "Сумма по!докум."       format "->>>>>>>>9.99":U
  price-lst            column-label "Цена по!объекту"       format ">>>>>>9.99":U
  obj-sum              column-label "Сумма по!объекту"      format "->>>>>>>>9.99":U
  SLT-sum              column-label "Налог с!прод."         format "->>>>>9.99":U
  UpFact               column-label "Торговая!наценка"      format "x(8)":U
  Delt                 column-label "Процент!разницы"       format "x(8)":U
  t-doc-line.vat-pc    column-label "Ставка!НДС"            format ">>9.<<%":U
  VAT-sum              column-label "Сумма НДС от!прод.цен" format "->>>>>>>>9.99":U        space( 0 )
  sym2                 column-label ":!:"                   format "x(1)":U                 space( 0 )
header
  cur-time-print( ) at 5                                                           format "x(35)":U
  "Акт приемки-передачи топливных товаров по документу N "
  string( tdoc-code + " от " + string( tdoc-date, "99/99/9999":U ) )               format "x(25)":U
  string( ( if prod-price = yes then "(Прод. цены на момент печати)" else "":U ) ) format "x(31)":U
  string( "Страница " + string( page-number( s-out ) ) )                           format "x(15)":U  skip
  Line              at 1                                                           format "x(178)":U
with width {&DOS_CW} stream-io.

form header
  Line format "x(178)":U                at  1 skip
  "Продолжение - на следующей странице" at 30 skip
with frame BottomFrame width {&DOS_CW} page-bottom no-labels no-box.

do on error undo, return error :
  { gbl/rbisbase.i v-rb-is-base }
  assign Line       = fill( "-", 200 )
         print_rubl = ( v-rb-is-base <> yes ).
  find first t-doc no-lock where recid( t-doc ) = rec_id.
  assign tdoc-date = t-doc.doc-date
         tdoc-code = t-doc.doc-code.
  find first buf_host_clients no-lock where
             buf_host_clients.obj-type = {&cmp} and
             buf_host_clients.obj-code = t-doc.host-code.
  run get-expl-store in this-procedure ( input t-doc.obj-type, input t-doc.obj-code, output v-explname, output v-storeman ).
  { str/tdat-val.i t-doc.doc-code {&trdcattr-dids} v-dids v-attr-type }
  { str/tdat-val.i t-doc.doc-code {&trdcattr-nids} v-nids v-attr-type }

  { cmp/open-out.i stream s-out " " {&LS_PS_A4} }

  put stream s-out
    space( 90 ) buf_host_clients.obj-name format "x(40)":U skip( 2 )
    space( 20 ) "А К Т приемки-передачи топливных товаров по документу N " format "x(80)":U
    t-doc.doc-code format "x(10)":U "  от  " t-doc.doc-date format "99.99.9999":U skip( 1 )
    space( 20 ) "Основание: накладная поставщика" string( "N " + v-nids + " от " + v-dids ) format "x(40)":U at 55 skip( 1 )
    space( 20 ) "АГЕНТ : " v-explname format "x(40)":U.
  if t-doc.doc-type = {&income}  or
   ( t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} )   or
   ( t-doc.doc-type = {&expense} and ( t-doc.internal <> yes           ) ) then do:
    put stream s-out space( 20 ) string( "ПОСТАВЩИК : " + t-doc.cli-name ) format "x(90)":U skip( 1 ).
  end.

  view stream s-out frame BottomFrame.

  for each ub.doc-line no-lock where ub.doc-line.doc-code = t-doc.doc-code,
      each ub.gds-dtl  no-lock where
           ub.gds-dtl.doc-code  = ub.doc-line.doc-code  and
           ub.gds-dtl.artic     = ub.doc-line.artic     and
           ub.gds-dtl.prod-type = ub.doc-line.prod-type and
           ub.gds-dtl.prod-code = ub.doc-line.prod-code,
      each ub.goods    no-lock where
           ub.goods.artic     = ub.gds-dtl.artic     and
           ub.goods.prod-type = ub.gds-dtl.prod-type and
           ub.goods.prod-code = ub.gds-dtl.prod-code
  break by ub.gds-dtl.artic
        by ub.gds-dtl.prt-code with frame PrintFrame_ActTransceiving :
    for each t-doc-line :
      delete t-doc-line.
    end.
    { str/is-petrl.i ub.goods.artic
                 ub.goods.prod-type
                 ub.goods.prod-code
                 is-petrol
                 is-pieces          no-error }
    if error-status :error or is-petrol <> yes or is-pieces <> no then do: next. end.
    create t-doc-line.
    buffer-copy ub.doc-line to t-doc-line.
    assign
      v-density = ub.doc-line.doc-density
    .
    { gbl/hostcode.i ub.doc-line.obj-type ub.doc-line.obj-code v-host-code }
    { gbl/pftxvalg.i ub.goods.gds-code {&vat-tax-code} ? v-host-code ub.doc-line.obj-type ub.doc-line.obj-code v-vat-pc no-error }
    { gbl/pftxvalg.i ub.goods.gds-code {&slt-tax-code} ? v-host-code ub.doc-line.obj-type ub.doc-line.obj-code v-slt-pc no-error }
    assign t-doc-line.vat-pc = v-vat-pc
           t-doc-line.slt-pc = v-slt-pc.
    find first ub.bar-code no-lock where
               ub.bar-code.gds-code  = ub.goods.gds-code   and
               ub.bar-code.unit-cli  = ub.goods.unit-base  and
               ub.bar-code.node-code = ub.gds-dtl.prt-code and
               ub.bar-code.part-code = "":U                and
               ub.bar-code.in-code   = "":U                no-error.
    if prod-price = yes then do:
      { str/get-pr.i calc t-doc.obj-type t-doc.obj-code ub.goods.gds-code ub.bar-code.node-code }
      assign price-lst = gp-price-sale / v-density.
    end.
    else do:
      assign price-lst = ub.gds-dtl.cur-base / v-density.
    end.

    if t-doc.doc-type = {&income} then do:
      { str/in-vatp.i calc ub.doc-line. t-doc. g }
      if road-tax-rubl-loc = ? then assign road-tax-rubl-loc = 0.
      if road-tax-base-loc = ? then assign road-tax-base-loc = 0.
      assign doc-price = ( if v-rb-is-base = yes then ( price-base-with-tax-loc - vat-base-loc )
                                                 else ( price-rubl-with-tax-loc - vat-rubl-loc ) ) / v-density
             v-tax-sum = ( if v-rb-is-base = yes then road-tax-base-loc else road-tax-rubl-loc )   / v-density.
    end.
    else do:
      { str/out-vatp.i calc-gds-dtl ub.doc-line. t-doc. ub.gds-dtl. }
      assign doc-price = ( if v-rb-is-base = yes then ( price-base-with-tax-sale - vat-rubl-sale )
                                                 else ( price-rubl-with-tax-sale - vat-rubl-sale ) ) / v-density.
    end.
    assign VAT-gds = ( price-lst - {&SLT-calc-ov} - v-tax-sum ) * t-doc-line.vat-pc / ( 100 + t-doc-line.vat-pc )
           marg    =   price-lst -   doc-price    - VAT-gds     - {&SLT-calc-ov}.
    assign v-price-rb     = ( if print_rubl = yes then ub.gds-dtl.price-rubl else ub.gds-dtl.price-base ) / v-density
           j_total        =   j_total       + 1
           v-fact-qnty-kg = { str/invlnsum.i exe cli-qnty {&comm-pars} }
           sum-no-VAT     =   v-fact-qnty-kg *   doc-price
           doc-sum        =   v-fact-qnty-kg *   v-price-rb
           obj-sum        =   v-fact-qnty-kg *   price-lst
           SLT-sum        =   v-fact-qnty-kg * {&SLT-calc-ov}
           VAT-sum        =   v-fact-qnty-kg *   VAT-gds
           d_delta        =   obj-sum        -   doc-sum.
    assign total_qnty-kg  =   total_qnty-kg + v-fact-qnty-kg
           total_SLT-sum  =   total_SLT-sum + SLT-sum
           total_VAT-sum  =   total_VAT-sum + VAT-sum
           total_no-VAT   =   total_no-VAT  + sum-no-VAT
           total_obj-sum  =   total_obj-sum + obj-sum
           total_doc-sum  =   total_doc-sum + doc-sum
           total_delta    =   total_delta   + d_delta
           total_up-fact  =   total_up-fact + v-fact-qnty-kg * marg.

    display stream s-out
      sym1 trim( string( ub.bar-code.b-code ) )                             @ tb-code
                         ub.gds-dtl.artic
                         ub.goods.gds-name
                         v-fact-qnty-kg                                     @ ub.gds-dtl.fact-qnty
                         doc-price
                         sum-no-VAT
                         doc-sum
                         price-lst
                         obj-sum
                         SLT-sum
                         t-doc-line.vat-pc
                         VAT-sum
           string( string( marg    / doc-price * 100, "->>>9.9":U ) + "%" ) @ UpFact
           string( string( d_delta / doc-sum   * 100, "->>>9.9":U ) + "%" ) @ Delt   sym2.
    if last( ub.gds-dtl.artic ) then do:
      down stream s-out 1.
      put  stream s-out Line format "x(178)":U skip.
      display stream s-out
                        "  ИТОГО"                                                  @ ub.goods.gds-name
                        total_qnty-kg                                              @ ub.gds-dtl.fact-qnty
                        total_no-VAT                                               @ sum-no-VAT
                        total_doc-sum                                              @ doc-sum
                        total_obj-sum                                              @ obj-sum
                        total_SLT-sum                                              @ SLT-sum
                        total_VAT-sum                                              @ VAT-sum
        string( string( total_up-fact / total_no-VAT  * 100, "->>>9.9":U ) + "%" ) @ UpFact
        string( string( total_delta   / total_doc-sum * 100, "->>>9.9":U ) + "%" ) @ Delt.
      underline stream s-out ub.goods.gds-name ub.gds-dtl.fact-qnty sum-no-VAT doc-sum obj-sum SLT-sum UpFact Delt VAT-sum.
      down stream s-out 2.
    end. /* if last( ub.gds-dtl.artic ) */
  end. /* for each ... */
  hide stream s-out frame BottomFrame.

  if v-rb-is-base = yes then do:
    assign propis = Total-Word( total_obj-sum, base-type, base-part )
           abbr   = base-type.
  end.                  else do:
    assign propis = Total-Word( total_obj-sum, Roubles( total_obj-sum ), Copecks( total_obj-sum ) )
           abbr   = " {&abbr_rub}.".
  end.

  put stream s-out
      space( 10 ) "Всего  " j_total format ">>>>9":U " наименований." format "x(15)":U skip( 1 )
      space( 10 ) string( "Сумма цен по объекту составила : " +
                    trim( string( total_obj-sum, "->>>,>>>,>>>,>>>,>>9.99":U ) ) + " ":U + trim( abbr ) +
                          ", в том числе налог с продаж : "   +
                    trim( string( total_SLT-sum, "->>>,>>>,>>>,>>>,>>9.99":U ) ) + " ":U + trim( abbr ) +
                          ", НДС : "                          +
                    trim( string( total_VAT-sum, "->>>,>>>,>>>,>>>,>>9.99":U ) ) + " ":U + trim( abbr ) ) format "x(126)":U skip( 1 )
      space( 10 ) "Разница между суммой в продажных ценах по объекту и суммой в ценах документа без НДС составила: "
                  + trim( string( total_obj-sum - total_no-VAT, "->>>,>>>,>>>,>>>,>>9.99":U ) )
                  + " ":U + trim( abbr ) format "x(126)":U skip( 1 ).
  if line-counter( s-out ) + 4 > page-size( s-out ) then do: page stream s-out. end.

  put stream s-out
    space( 10 ) string( "ИТОГО по акту передано товаров на сумму  " +
    ( if trim( propis ) begins trim( abbr ) then "0 " else "":U ) + caps( propis ) ) format "x(126)":U skip( 1 ).
  run get-boss-and-buh in this-procedure ( input t-doc.obj-type, input t-doc.obj-code, output v-main-boss, output v-main-buh ).
  put stream s-out space( 20 ) "От владельца : "
                               "От эксплуататора : " at 80
                               v-storeman                    format "x(20)":U skip( 1 )
                   space( 20 ) "Руководитель предприятия:                                             / "
                               string( v-main-boss  + " /" ) format "x(40)":U skip( 1 )
                   space( 20 ) "Главный бухгалтер:                                                    / "
                               string( v-main-buh  + " /" )  format "x(40)":U.

  output stream s-out close.
  { rep/q-print.i 8 }
end. /* on error */

procedure get-boss-and-buh :
  define  input parameter p-obj-type  as character no-undo.
  define  input parameter p-obj-code  as integer   no-undo.
  define output parameter p-main-boss as character no-undo.
  define output parameter p-main-buh  as character no-undo.

  define variable j_host-code as integer no-undo.

  define buffer buf_clients for ub.clients.
  define buffer buf_firm    for ub.firm.
  define buffer buf_sysconf for ub.sysconf.

  do on error undo, return error :
    { gbl/hostcode.i p-obj-type p-obj-code j_host-code }
    find first buf_clients no-lock where
               buf_clients.obj-type = {&cmp} and
               buf_clients.obj-code = j_host-code.
    find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code.
    assign p-main-boss = buf_firm.director.
    find first buf_sysconf no-lock where buf_sysconf.host-code = buf_firm.firm-code.
    assign p-main-buh  = buf_sysconf.snr-accnt.
  end. /* on error */
end procedure. /* get-boss-and-buh */

procedure get-expl-store :
  define  input parameter p-obj-type like ub.trn-doc.obj-type no-undo.
  define  input parameter p-obj-code like ub.trn-doc.obj-code no-undo.
  define output parameter p-explname as   character           no-undo initial ?.
  define output parameter p-storeman as   character           no-undo initial ?.

  define buffer buf_clients for ub.clients.
  define buffer buf_shop    for ub.shop.
  define buffer buf_store   for ub.store.

  do on error undo, return error :
    find first buf_clients no-lock where
               buf_clients.obj-type = p-obj-type and
               buf_clients.obj-code = p-obj-code.
    case buf_clients.obj-type :
      when {&shop}  then do:
        find first buf_shop no-lock where buf_shop.obj-code = buf_clients.obj-code.
        assign p-explname = buf_shop.director
               p-storeman = buf_shop.store-man.
      end.
      when {&stock} then do:
        find first buf_store no-lock where buf_store.obj-code = buf_clients.obj-code.
        assign p-explname = buf_store.store-boss
               p-storeman = buf_store.store-man.
      end.
    end case. /* buf_clients.obj-type */
  end. /* on error */
end procedure. /* get-expl-store */