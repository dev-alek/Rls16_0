block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-z1zvit.p $
$Archive: rep/r-z1zvit.p $

сменный отчет АЗС (Украина): 1-я страница

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/30/09
Author: Dmitry Ukhanov
Creation date: 01/30/09

Автор1: Булгаков Андрей Николаевич
Дата создания1: 01/10/06

*/

&scop f-l Int2Char,addl-list

define  input parameter p-parent-proc         as   widget-handle           no-undo .
define  input parameter pobj-code             like ub.clients.obj-code     no-undo .
define  input parameter pobj-type             like ub.clients.obj-type     no-undo .
define  input parameter p-base-type           like ub.currency.curr-abbr   no-undo .
define  input parameter p-base-code           like ub.currency.curr-code   no-undo .
define  input parameter p-can-print           as   logical                 no-undo .
define  input parameter p-sort-type           as   character               no-undo .
define  input parameter pshift-date           like ub.shift-obj.shift-date no-undo .
define  input parameter pshift-num            like ub.shift-obj.shift-num  no-undo .
define  input parameter p-previous-shift-date as   date                    no-undo .
define output parameter p-total-cash          as   decimal                 no-undo .
define output parameter p-total-all           as   decimal                 no-undo .

define variable pshift-date1           like ub.shift-obj.shift-date no-undo.
define variable pshift-num1            like ub.shift-obj.shift-num  no-undo.
assign
  pshift-date1 = pshift-date
  pshift-num1  = pshift-num
.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-z1zvit.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-z1zvit.p $":U .
define variable vss-description as character no-undo initial "сменный отчет АЗС (Украина)":U .

{ cmp/vssrevis.i                }
{ cmp/str-glbl.i                }
{ ref/cp-attr.i                 }
{ cmp/library.i                 }
{ str/lib-trn.i                 }
{ rep/real-2df.i shared treal-2 }
{ rep/real-3df.i shared treal-3 }
{ rep/icm-2df.i  shared         }
{ rep/icm-3df.i  shared         }
{ arc/stk-lnrv.i def            }
{ arc/ot-lnrv.i  def            }
{ trg/factord.i                 }
{ gbl/clntattr.i                }
{ arc/stk-lnrv.i def " " supp-  }
{ cmp/r-page1.i                 }
{ cmp/r-pril.i                  }
{ rep/r-sym.i                   }
{ rep/r-gl.i                    }
{ gbl/std-func.i {&f-l}         }
{ str/clcprtsl.i                }
{ rep/real-2cr.i treal-2        }
{ arc/stk-lnrv.i calc           }
{ arc/ot-lnrv.i  calc           }
{ gbl/prn-lib.i  shared         }

define variable found-in-previous as   logical                  no-undo .
define variable mc                like ub.bar-code.b-code       no-undo .
define variable vdoc-num          like ub.price-list.doc-num    no-undo .
define variable vprice-sale       like ub.price-list.price-sale no-undo .
define variable vroad-tax         as   decimal                  no-undo .
define variable vexcise           as   decimal                  no-undo .
define variable jj                as   integer                  no-undo initial 1 .
define variable loc-ii            as   integer                  no-undo initial 1 .
define variable for-supp-name     as   character                no-undo .
define variable acc-other-qnty1   as   decimal                  no-undo .
define variable acc-other-qnty2   as   decimal                  no-undo .
define variable acc-other-netto   as   decimal                  no-undo .
define variable acc-other-found   as   logical                  no-undo .
define variable acc-cli-qnty1     as   decimal                  no-undo .
define variable acc-cli-qnty2     as   decimal                  no-undo .
define variable acc-cli-netto     as   decimal                  no-undo .
define variable acc-cli-found     as   logical                  no-undo .
define variable v-attr-value      as   character                no-undo .
define variable v-attr-type       as   character                no-undo .
define variable v-sum-base        like ub.ot-line.sum-base      no-undo .
define variable total-petrol      as   decimal                  no-undo .
define variable total-cash-petrol as   decimal                  no-undo .
define variable total-card-petrol as   decimal                  no-undo .
define variable total-total       as   decimal                  no-undo .
define variable total-cash-total  as   decimal                  no-undo .
define variable total-card-total  as   decimal                  no-undo .
define variable total-other       as   decimal                  no-undo .
define variable total-cash-other  as   decimal                  no-undo .
define variable total-card-other  as   decimal                  no-undo .
define variable p-host-code       like ub.sysconf.host-code     no-undo .
define variable d-fact-qnty-kg    as   decimal                  no-undo .
define variable v-out-pay-name    as   character                no-undo .
define variable j-out-pay-code    as   integer                  no-undo .
define variable total-inkas-base  as   decimal                  no-undo .
define variable d-factor          as   decimal                  no-undo .
define variable j_Excel-line      as   integer                  no-undo .
define variable v_shift-name      as   character                no-undo .
define variable v_shift-name-num  as   character                no-undo .
define variable d-state-mh-cnt    as   decimal                  no-undo .
define variable group-was-found   as   logical                  no-undo initial ? .
define variable cashpay-was-found as   logical                  no-undo .

define buffer bf_rvs-doc        for ub.rvs-doc .
define buffer bf_rvs-line       for ub.rvs-line .
define buffer bf_rvs-line-pump  for ub.rvs-line-pump .
define buffer current_rvs-doc   for ub.rvs-doc .
define buffer current_rvs-line  for ub.rvs-line .
define buffer previous_rvs-doc  for ub.rvs-doc .
define buffer previous_rvs-line for ub.rvs-line .
define buffer bf_goods          for ub.goods .
define buffer bf_trn-doc        for ub.trn-doc .
define buffer bf_doc-line       for ub.doc-line .
define buffer bf_inv-line       for ub.inv-line .
define buffer bf_clients        for ub.clients .
define buffer bf_inkas          for ub.inkas .
define buffer bf_inkas-pay      for ub.inkas-pay .

define variable pol1  as character no-undo .
define variable pol2  as decimal   no-undo .
define variable pol3  as decimal   no-undo .
define variable pol4  as decimal   no-undo .
define variable pol5  as decimal   no-undo .
define variable pol6  as decimal   no-undo .
define variable pol7  as decimal   no-undo .
define variable pol8  as decimal   no-undo .
define variable pol9  as decimal   no-undo .
define variable pol10 as decimal   no-undo .
define variable pol11 as decimal   no-undo .
define variable pol12 as decimal   no-undo .
define variable pol13 as decimal   no-undo .
define variable pol14 as decimal   no-undo .
define variable pol15 as decimal   no-undo .

define frame FRAME-1
                              space( 0 ) sym1  format "x(1)":U space( 0 )
  pol1  format "x(8)":U       space( 0 ) sym2  format "x(1)":U space( 0 )
  pol2  format ">>9.99":U     space( 0 ) sym3  format "x(1)":U space( 0 )
  pol3  format ">>>>>>9.99":U space( 0 ) sym4  format "x(1)":U space( 0 )
  pol4  format ">>>>>>9.99":U space( 0 ) sym5  format "x(1)":U space( 0 )
  pol5  format "->>>>>9.99":U space( 0 ) sym6  format "x(1)":U space( 0 )
  pol6  format ">>>>>>9.99":U space( 0 ) sym7  format "x(1)":U space( 0 )
  pol7  format ">>>>>>9.99":U space( 0 ) sym8  format "x(1)":U space( 0 )
  pol8  format ">>>>9.99":U   space( 0 ) sym9  format "x(1)":U space( 0 )
  pol9  format ">9.99":U      space( 0 ) sym10 format "x(1)":U space( 0 )
  pol10 format ">9.99":U      space( 0 ) sym11 format "x(1)":U space( 0 )
  pol11 format ">9.99":U      space( 0 ) sym12 format "x(1)":U space( 0 )
  pol12 format ">>>>>9.99":U  space( 0 ) sym13 format "x(1)":U space( 0 )
  pol13 format ">>>>9.99":U   space( 0 ) sym14 format "x(1)":U space( 0 )
  pol14 format ">>>>9.99":U   space( 0 ) sym15 format "x(1)":U space( 0 )
  pol15 format ">>>>9.99":U   space( 0 ) sym16 format "x(1)":U space( 0 )
with width {&DOS_CW_2} down stream-io use-text no-labels no-box .

form header
  skip( 4 )
  { rep/r-z1zvit.i }
with frame TopFrame width {&DOS_CW_2} page-top no-labels no-box .

if p-can-print = yes
then do:
  view stream PrnLibStream frame TopFrame .
end.

/* находим fact-order */
{ rep/r-shftfo.i attr-arh-detail-date }
{ rep/r-zmzvit.i " " 1 }

{ gbl/hostcode.i
    pobj-type
    pobj-code
    p-host-code
    no-error
}
{ str/shiftnam.i
    pobj-type
    pobj-code
    pshift-date
    pshift-num
    v_shift-name
    v_shift-name-num
    no-error
}

find first bf_rvs-doc no-lock where
           bf_rvs-doc.obj-type   = pobj-type    and
           bf_rvs-doc.obj-code   = pobj-code    and
           bf_rvs-doc.shift-date = pshift-date  and
           bf_rvs-doc.shift-num  = pshift-num   and
           bf_rvs-doc.status_    = {&fact}      and
           bf_rvs-doc.rvs-type   = {&rvs-shift} no-error .
if not available bf_rvs-doc
then do:
  message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
          "Не найдена сверка типа" '"' + {&rvs-shift} + '"' skip( 0 )
          "Объект:" pobj-type   pobj-code        skip( 0 )
          "Смена"   pshift-date v_shift-name-num skip( 1 )
  view-as alert-box error.
  return error.
end.

if available previous-shift-obj
then do:
  find first previous_rvs-doc no-lock where
             previous_rvs-doc.obj-type   = pobj-type                     and
             previous_rvs-doc.obj-code   = pobj-code                     and
             previous_rvs-doc.shift-date = previous-shift-obj.shift-date and
             previous_rvs-doc.shift-num  = previous-shift-obj.shift-num  and
             previous_rvs-doc.status_    = {&fact}                       and
             previous_rvs-doc.rvs-type   = {&rvs-shift}                  no-error .
end.

for each bf_rvs-line no-lock where
         bf_rvs-line.rvs-code = bf_rvs-doc.rvs-code and
         bf_rvs-line.obj-type = bf_rvs-doc.obj-type and
         bf_rvs-line.obj-code = bf_rvs-doc.obj-code
break by bf_rvs-line.gds-code
:
  find first t-2 where
             t-2.gds-code = bf_rvs-line.gds-code no-error .
  if not available t-2
  then do:
    find first bf_goods no-lock where
               bf_goods.gds-code = bf_rvs-line.gds-code no-error .
    if available bf_goods
    then do:
      { gbl/bcodeprc.i
          pobj-type
          pobj-code
          bf_rvs-line.gds-code
          0
          fo
          vdoc-num
          vprice-sale
          vroad-tax
          vexcise
          no-error
      }
      assign
        mc = bf_goods.gds-code
      .
      { gbl/gdsbcode.i
          bf_goods.gds-code
          ?
          mc
      }
      create t-2.
      assign
             t-2.gds-code   = bf_goods.gds-code
             t-2.main-code  = mc
             t-2.gds-name   = bf_goods.gds-name
             t-2.artic      = bf_goods.artic
             t-2.prod-type  = bf_goods.prod-type
             t-2.prod-code  = bf_goods.prod-code
             t-2.last-price = vprice-sale
      .
    end. /* if available ub.goods */
  end. /* if not available t-2 */

  if available t-2
  then do:
    assign
      t-2.qnty1-after   = t-2.qnty1-after + bf_rvs-line.system-qnty
      t-2.qnty2-after   = t-2.qnty2-after + bf_rvs-line.system-cli-qnty
      found-in-previous = no
    .
    if available previous_rvs-doc
    then do:
      for each previous_rvs-line no-lock where
               previous_rvs-line.rvs-code = previous_rvs-doc.rvs-code and
               previous_rvs-line.pl-code  = bf_rvs-line.pl-code       and
               previous_rvs-line.gds-code = t-2.gds-code
      :
        assign
          t-2.qnty1-before  = t-2.qnty1-before + previous_rvs-line.system-qnty
          t-2.qnty2-before  = t-2.qnty2-before + previous_rvs-line.system-cli-qnty
          found-in-previous = yes
        .
      end. /* for each previous-rvs-line */
    end. /* if available previous-rvs-doc */

    if found-in-previous = no
    then do:
      for each current_rvs-doc  where
               current_rvs-doc.obj-type   =  pobj-type    and
               current_rvs-doc.obj-code   =  pobj-code    and
               current_rvs-doc.shift-date =  pshift-date  and
               current_rvs-doc.shift-num  =  pshift-num   and
               current_rvs-doc.status_    =  {&fact}      and
               current_rvs-doc.rvs-type   <> {&rvs-shift}
        , each current_rvs-line where
               current_rvs-line.rvs-code  =  current_rvs-doc.rvs-code and
               current_rvs-line.obj-type  =  current_rvs-doc.obj-type and
               current_rvs-line.obj-code  =  current_rvs-doc.obj-code and
               current_rvs-line.gds-code  =  t-2.gds-code
            by current_rvs-doc.fact-order
      :
        assign
          t-2.qnty1-before = t-2.qnty1-before + current_rvs-line.system-qnty
          t-2.qnty2-before = t-2.qnty2-before + current_rvs-line.system-cli-qnty
        .
        leave .
      end. /* for each current_rvs-doc */
    end. /* if not found-in-previous */
  end. /* if available t-2 */
end. /* for each bf_rvs-line */

/* out-name = "Списание"             cpay-code = -5 ii = ? is-pay = no */
/* out-name = "Инвентаризации"       cpay-code = -4 ii = ? is-pay = no */
/* out-name = "Отпуск без ККМ"       cpay-code = -3 ii = ? is-pay = no */
/* out-name = "Технолог.проливы"     cpay-code = -2 ii = ? is-pay = no */
/* out-name = "Прочий докум.расход"  cpay-code = -1 ii = ? is-pay = no */

if moving = yes
then do:
  for each  bf_trn-doc  no-lock where
            bf_trn-doc.obj-type   = pobj-type   and
            bf_trn-doc.obj-code   = pobj-code   and
            bf_trn-doc.shift-date = pshift-date and
            bf_trn-doc.shift-num  = pshift-num  and
            bf_trn-doc.internal   = no          and
            bf_trn-doc.status_    = {&fact}     and
            bf_trn-doc.doc-type   = {&income}
    , each  bf_doc-line no-lock where
            bf_doc-line.doc-code = bf_trn-doc.doc-code
    , first t-2                 where
            t-2.artic     = bf_doc-line.artic     and
            t-2.prod-type = bf_doc-line.prod-type and
            t-2.prod-code = bf_doc-line.prod-code
   break by bf_doc-line.artic
         by bf_doc-line.prod-type
         by bf_doc-line.prod-code
  :
    if first-of( bf_doc-line.prod-code )
    then do:
      assign
        loc-ii = 1
      .
    end.
    find first bf_clients no-lock where
               bf_clients.obj-type = bf_trn-doc.cli-type and
               bf_clients.obj-code = bf_trn-doc.cli-code no-error .
    assign
      for-supp-name = ( if available bf_clients then bf_clients.obj-name else "":U )
    .
    find first bf_inv-line no-lock where
               bf_inv-line.doc-code  = bf_doc-line.doc-code  and
               bf_inv-line.artic     = bf_doc-line.artic     and
               bf_inv-line.prod-type = bf_doc-line.prod-type and
               bf_inv-line.prod-code = bf_doc-line.prod-code no-error .
    create tincome-2.
    assign
      tincome-2.gds-code    = t-2.gds-code
      tincome-2.supp-name   = for-supp-name
      tincome-2.supp-type   = bf_trn-doc.cli-type
      tincome-2.supp-code   = bf_trn-doc.cli-code
      tincome-2.doc-code    = bf_trn-doc.doc-code
      tincome-2.qnty1       = bf_doc-line.fact-qnty
      tincome-2.qnty2       = ( if available bf_inv-line then bf_inv-line.wast-cli-qnty else 0 )
      tincome-2.temperature = bf_doc-line.temperature
      tincome-2.density     = ( if tincome-2.qnty2 / tincome-2.qnty1 = ? then 0
                                                                         else ( tincome-2.qnty2 / tincome-2.qnty1 ) )
      tincome-2.is-fact     = yes
      tincome-2.ii          = loc-ii
      loc-ii                = loc-ii + 1
    .
  end. /* for each bf_trn-doc */

  for each tt-stk-line :
    delete tt-stk-line .
  end.
  for each tt-stk-supp-line :
    delete tt-stk-supp-line .
  end.

  for each t-2 no-lock :
    assign
      acc-other-found = no
      acc-other-qnty1 = 0
      acc-other-qnty2 = 0
      acc-other-netto = 0
    .
    for each ub.clients-attr where
             ub.clients-attr.attr-code  = {&attr-shftrep2} and
             ub.clients-attr.attr-value = "yes":U
    :
      find first bf_clients no-lock where
                 bf_clients.obj-type = ub.clients-attr.obj-type and
                 bf_clients.obj-code = ub.clients-attr.obj-code no-error .
      if available bf_clients
      then do:
        run ot-lnrv in this-procedure
          (  input       pobj-type
          ,  input       pobj-code
          ,  input       ub.clients-attr.obj-type
          ,  input       ub.clients-attr.obj-code
          ,  input       t-2.artic
          ,  input       t-2.prod-type
          ,  input       t-2.prod-code
          ,  input       prev-fo
          ,  input       fo
          ,  input       {&arh-sale}
          ,  input       ?
          , output table tt-ot-line
          ) no-error .
        if not error-status :error
        then do:
          assign
            acc-cli-qnty1 = 0
            acc-cli-qnty2 = 0
            acc-cli-netto = 0
            acc-cli-found = no
          .
          for each tt-ot-line no-lock where
                   tt-ot-line.cli-type  = ub.clients-attr.obj-type and
                   tt-ot-line.cli-code  = ub.clients-attr.obj-code and
                   tt-ot-line.artic     = t-2.artic                and
                   tt-ot-line.prod-type = t-2.prod-type            and
                   tt-ot-line.prod-code = t-2.prod-code
          :
            if tt-ot-line.ext-doc-type <> {&TDEDT_Pri_Vnesh}
            then do:
              assign
                acc-cli-found = yes
                acc-cli-qnty1 = acc-cli-qnty1 + tt-ot-line.fact-qnty
                acc-cli-netto = acc-cli-netto + tt-ot-line.sum-base
              .
              for each  bf_doc-line no-lock where
                        bf_doc-line.obj-type      = tt-ot-line.obj-type     and
                        bf_doc-line.obj-code      = tt-ot-line.obj-code     and
                        bf_doc-line.prod-type     = tt-ot-line.prod-type    and
                        bf_doc-line.prod-code     = tt-ot-line.prod-code    and
                        bf_doc-line.artic         = tt-ot-line.artic        and
                        bf_doc-line.ext-doc-type  = tt-ot-line.ext-doc-type and
                        bf_doc-line.status_       = {&fact}                 and
                        bf_doc-line.fact-order   >= prev-fo                 and
                        bf_doc-line.fact-order   <= fo
                , first bf_trn-doc  no-lock where
                        bf_trn-doc.doc-code = bf_doc-line.doc-code and
                        bf_trn-doc.cli-type = tt-ot-line.cli-type  and
                        bf_trn-doc.cli-code = tt-ot-line.cli-code
              :
                find first bf_inv-line no-lock where
                           bf_inv-line.doc-code  = bf_doc-line.doc-code  and
                           bf_inv-line.artic     = bf_doc-line.artic     and
                           bf_inv-line.prod-type = bf_doc-line.prod-type and
                           bf_inv-line.prod-code = bf_doc-line.prod-code no-error .
                if tt-ot-line.ext-doc-type = {&TDEDT_Inv}      or
                   tt-ot-line.ext-doc-type = {&TDEDT_Peresort} then do:
                  assign
                    acc-cli-qnty2 = acc-cli-qnty2 + ( if bf_doc-line.cli-qnty = ? then 0 else bf_doc-line.cli-qnty )
                  .
                end.
                else do:
                  assign
                    acc-cli-qnty2 = acc-cli-qnty2 +
                         ( if available bf_inv-line then
                         ( if bf_inv-line.wast-cli-qnty = ? then 0
                                                            else ( - bf_inv-line.wast-cli-qnty ) )
                                                    else 0 )
                  .
                end.
              end. /* for each bf_doc-line */
            end. /* if tt-ot-line.ext-doc-type <> {&TDEDT_Pri_Vnesh} */
          end. /* for each tt-ot-line */

          if acc-cli-found = yes
          then do:
            run create-treal-2 in this-procedure
              ( input t-2.gds-code
              , input -2
              , input p-base-code
              , input - acc-cli-qnty1
              , input - acc-cli-qnty2
              , input - acc-cli-netto
              , input bf_clients.obj-name
              , input no
              , input ?
              ) no-error .
          end.
        end. /* if not error-status :error */
      end. /* if available bf_clients */
    end. /* for each ub.clients-attr */

    run stk-lnrv in this-procedure
      (  input       pobj-type
      ,  input       pobj-code
      ,  input       t-2.artic
      ,  input       t-2.prod-type
      ,  input       t-2.prod-code
      ,  input       prev-fo
      ,  input       fo
      ,  input       {&arh-sadt}
      ,  input       {&root-cat-id}
      ,  input       yes
      , output table tt-stk-line
      ) no-error .
    for each  bf_trn-doc no-lock where
              bf_trn-doc.obj-type     = pobj-type          and
              bf_trn-doc.obj-code     = pobj-code          and
              bf_trn-doc.shift-date   = pshift-date        and
              bf_trn-doc.shift-num    = pshift-num         and
              bf_trn-doc.internal     = no                 and
              bf_trn-doc.status_      = {&fact}            and
              bf_trn-doc.ext-doc-type = {&TDEDT_Inv}       or
              bf_trn-doc.obj-type     = pobj-type          and
              bf_trn-doc.obj-code     = pobj-code          and
              bf_trn-doc.shift-date   = pshift-date        and
              bf_trn-doc.shift-num    = pshift-num         and
              bf_trn-doc.internal     = no                 and
              bf_trn-doc.status_      = {&fact}            and
              bf_trn-doc.ext-doc-type = {&TDEDT_Peresort}

      , first bf_doc-line no-lock where
              bf_doc-line.doc-code  = bf_trn-doc.doc-code and
              bf_doc-line.artic     = t-2.artic           and
              bf_doc-line.prod-type = t-2.prod-type       and
              bf_doc-line.prod-code = t-2.prod-code
    :
      run clntattr-value in this-procedure
        (  input bf_trn-doc.cli-type
        ,  input bf_trn-doc.cli-code
        ,  input {&attr-shftrep2}
        , output v-attr-value
        , output v-attr-type
        ) .
      run clcprtsl_calc-line in this-procedure ( input recid( bf_doc-line ) ) .
      find first tt-allsum-line no-lock where
                 tt-allsum-line.sum-type = {&sum-general} no-error .
      assign
        v-sum-base = ( if available tt-allsum-line then tt-allsum-line.sum-dsc-base-doc else 0.0 )
      .
      if v-attr-value = "no":U
      then do:
        run create-treal-2 in this-procedure
          ( input t-2.gds-code
          , input -4
          , input 0
          , input - bf_doc-line.fact-qnty
          , input - bf_doc-line.cli-qnty
          , input - v-sum-base
          , input "Инвентаризация"
          , input no
          , input ?
          ) no-error .
      end. /* v-attr-value = "no":U */
    end. /* for each bf_trn-doc */

    for each  bf_trn-doc no-lock where
              bf_trn-doc.obj-type     = pobj-type          and
              bf_trn-doc.obj-code     = pobj-code          and
              bf_trn-doc.shift-date   = pshift-date        and
              bf_trn-doc.shift-num    = pshift-num         and
              bf_trn-doc.internal     = no                 and
              bf_trn-doc.status_      = {&fact}            and
              bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
      , first bf_doc-line no-lock where
              bf_doc-line.doc-code  = bf_trn-doc.doc-code and
              bf_doc-line.artic     = t-2.artic           and
              bf_doc-line.prod-type = t-2.prod-type       and
              bf_doc-line.prod-code = t-2.prod-code
    :
      run clntattr-value in this-procedure
        (  input bf_trn-doc.cli-type
        ,  input bf_trn-doc.cli-code
        ,  input {&attr-shftrep2}
        , output v-attr-value
        , output v-attr-type
        ) .
      run clcprtsl_calc-line in this-procedure ( input recid( bf_doc-line ) ) .
      find first tt-allsum-line no-lock where
                 tt-allsum-line.sum-type = {&sum-general} no-error .
      assign
        v-sum-base = ( if available tt-allsum-line then tt-allsum-line.sum-dsc-base-doc else 0.0 )
      .
      find first bf_inv-line no-lock where
                 bf_inv-line.doc-code  = bf_doc-line.doc-code  and
                 bf_inv-line.artic     = bf_doc-line.artic     and
                 bf_inv-line.prod-type = bf_doc-line.prod-type and
                 bf_inv-line.prod-code = bf_doc-line.prod-code no-error .
      if v-attr-value = "no":U
      then do:
        assign
          v-out-pay-name = "Отпуск без ККМ"
          j-out-pay-code = -3
        .
        find first ub.pay-type no-lock where
                   ub.pay-type.obj-code = bf_trn-doc.pay-code no-error .
        if available ub.pay-type
        then do:
          find first ub.cash-pay no-lock where
                     ub.cash-pay.pay-code = bf_trn-doc.pay-code no-error .
          if available ub.cash-pay
          then do:
            assign
              v-out-pay-name = ub.cash-pay.obj-name
              j-out-pay-code = ub.cash-pay.cdpay-code
            .
          end. /* if available ub.cash-pay */
        end. /* if available ub.pay-type */
        run create-treal-2 in this-procedure
          ( input t-2.gds-code
          , input j-out-pay-code
          , input ( if available ub.cash-pay then ub.cash-pay.curr-code     else 0 )
          , input bf_doc-line.fact-qnty
          , input ( if available bf_inv-line then bf_inv-line.wast-cli-qnty else 0 )
          , input v-sum-base
          , input v-out-pay-name
          , input no
          , input ?
          ) no-error .
      end. /* v-attr-value = "no":U */
    end. /* for each bf_trn-doc */

    for each  bf_trn-doc no-lock where
              bf_trn-doc.obj-type     = pobj-type                   and
              bf_trn-doc.obj-code     = pobj-code                   and
              bf_trn-doc.shift-date   = pshift-date                 and
              bf_trn-doc.shift-num    = pshift-num                  and
              bf_trn-doc.internal     = no                          and
              bf_trn-doc.status_      = {&fact}                     and
            ( bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}     or
              bf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} )
      , first bf_doc-line no-lock where
              bf_doc-line.doc-code  = bf_trn-doc.doc-code and
              bf_doc-line.artic     = t-2.artic           and
              bf_doc-line.prod-type = t-2.prod-type       and
              bf_doc-line.prod-code = t-2.prod-code
    :
      run clntattr-value in this-procedure
        (  input bf_trn-doc.cli-type
        ,  input bf_trn-doc.cli-code
        ,  input {&attr-shftrep2}
        , output v-attr-value
        , output v-attr-type
        ) .
      if v-attr-value <> "no":U
      then do:
        next .
      end.
      run clcprtsl_calc-line in this-procedure ( input recid( bf_doc-line ) ) .
      find first tt-allsum-line no-lock where
                 tt-allsum-line.sum-type = {&sum-general} no-error .
      assign
        v-sum-base = ( if available tt-allsum-line then tt-allsum-line.sum-dsc-base-doc else 0.0 )
      .
      find first bf_inv-line no-lock where
                 bf_inv-line.doc-code  = bf_doc-line.doc-code  and
                 bf_inv-line.artic     = bf_doc-line.artic     and
                 bf_inv-line.prod-type = bf_doc-line.prod-type and
                 bf_inv-line.prod-code = bf_doc-line.prod-code no-error .
      if bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
      then do:
        find first bf_inkas no-lock where
                   bf_inkas.inkas-code = bf_trn-doc.doc-code no-error .
      end.
      else do:
        find first bf_inkas no-lock where
                   bf_inkas.inkas-code = bf_trn-doc.out-code no-error .
      end.
      if not available bf_inkas
      then do:
        next .
      end.

      assign
        total-inkas-base = 0
      .
      for each bf_inkas-pay no-lock where
               bf_inkas-pay.inkas-code = bf_inkas.inkas-code
      :
        assign
          total-inkas-base = total-inkas-base + bf_inkas-pay.tot-base
        .
      end. /* for each bf_inkas-pay */

      assign
        d-fact-qnty-kg = ( if available bf_inv-line then bf_inv-line.wast-cli-qnty else 0.0 )
      .
      for each bf_inkas-pay no-lock where
               bf_inkas-pay.inkas-code = bf_inkas.inkas-code
      :
        assign
          d-factor = bf_inkas-pay.tot-base / total-inkas-base
        .
        find first ub.cash-pay no-lock where
                   ub.cash-pay.cdpay-code = bf_inkas-pay.pay-code  and
                   ub.cash-pay.curr-code  = bf_inkas-pay.curr-code no-error .
        assign
          v-out-pay-name = ( if available ub.cash-pay then ub.cash-pay.obj-name else "Отпуск через ККМ" )
        .
        run create-treal-2 in this-procedure
          ( input t-2.gds-code
          , input bf_inkas-pay.pay-code
          , input bf_inkas-pay.curr-code
          , input ( bf_doc-line.fact-qnty * d-factor )
          , input ( d-fact-qnty-kg * d-factor )
          , input ( v-sum-base * d-factor )
          , input v-out-pay-name
          , input yes
          , input ?
          ) no-error .
      end. /* for each bf_inkas-pay */
    end. /* for each bf_trn-doc */

    for each  bf_trn-doc no-lock where
              bf_trn-doc.obj-type     = pobj-type          and
              bf_trn-doc.obj-code     = pobj-code          and
              bf_trn-doc.shift-date   = pshift-date        and
              bf_trn-doc.shift-num    = pshift-num         and
              bf_trn-doc.internal     = no                 and
              bf_trn-doc.status_      = {&fact}            and
              bf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh}
      , first bf_doc-line no-lock where
              bf_doc-line.doc-code  = bf_trn-doc.doc-code and
              bf_doc-line.artic     = t-2.artic           and
              bf_doc-line.prod-type = t-2.prod-type       and
              bf_doc-line.prod-code = t-2.prod-code
    :
      run clntattr-value in this-procedure
        (  input bf_trn-doc.cli-type
        ,  input bf_trn-doc.cli-code
        ,  input {&attr-shftrep2}
        , output v-attr-value
        , output v-attr-type
        ) .
      if v-attr-value = "yes"
      then do:
        next .
      end.

      find first bf_inv-line no-lock where
                 bf_inv-line.doc-code  = bf_doc-line.doc-code  and
                 bf_inv-line.artic     = bf_doc-line.artic     and
                 bf_inv-line.prod-type = bf_doc-line.prod-type and
                 bf_inv-line.prod-code = bf_doc-line.prod-code no-error .
      run clcprtsl_calc-line in this-procedure ( input recid( bf_doc-line ) ) .
      find first tt-allsum-line no-lock where
                 tt-allsum-line.sum-type = {&sum-general} no-error .
      assign
        v-sum-base      = ( if available tt-allsum-line then tt-allsum-line.sum-dsc-base-doc else 0.0 )
        acc-other-qnty1 = acc-other-qnty1 + ( if bf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
                                              then ( - bf_doc-line.fact-qnty )
                                              else     bf_doc-line.fact-qnty )
        acc-other-netto = acc-other-netto + v-sum-base
        acc-other-found = yes
      .
          if available bf_inv-line
          then do:
      assign
        acc-other-qnty2 = acc-other-qnty2 + ( if bf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
                                              then ( - bf_inv-line.wast-cli-qnty )
                                              else     bf_inv-line.wast-cli-qnty )
      .
          end.
      if v-attr-value = "no":U
      then do:
        run create-treal-2 in this-procedure
          ( input t-2.gds-code
          , input -5
          , input 0
          , input acc-other-qnty1
          , input acc-other-qnty2
          , input v-sum-base
          , input "Списание"
          , input no
          , input ?
          ) no-error .
      end. /* v-attr-value = "no":U */
    end. /* for each bf_trn-doc */

    for each  bf_trn-doc no-lock where
              bf_trn-doc.obj-type     = pobj-type              and
              bf_trn-doc.obj-code     = pobj-code              and
              bf_trn-doc.shift-date   = pshift-date            and
              bf_trn-doc.shift-num    = pshift-num             and
              bf_trn-doc.internal     = no                     and
              bf_trn-doc.status_      = {&fact}                and
           (  bf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} or
              bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}  )
      , first bf_doc-line no-lock where
              bf_doc-line.doc-code  = bf_trn-doc.doc-code and
              bf_doc-line.artic     = t-2.artic           and
              bf_doc-line.prod-type = t-2.prod-type       and
              bf_doc-line.prod-code = t-2.prod-code
    :
      find first bf_inv-line no-lock where
                 bf_inv-line.doc-code  = bf_doc-line.doc-code  and
                 bf_inv-line.artic     = bf_doc-line.artic     and
                 bf_inv-line.prod-type = bf_doc-line.prod-type and
                 bf_inv-line.prod-code = bf_doc-line.prod-code no-error .
      run clcprtsl_calc-line in this-procedure ( input recid( bf_doc-line ) ) .
      find first tt-allsum-line no-lock where
                 tt-allsum-line.sum-type = {&sum-general} no-error .
      assign
        v-sum-base      = ( if available tt-allsum-line then tt-allsum-line.sum-dsc-base-doc else 0.0 )
        acc-other-qnty1 = acc-other-qnty1 + ( if bf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
                                              then ( - bf_doc-line.fact-qnty )
                                              else     bf_doc-line.fact-qnty )
        acc-other-netto = acc-other-netto + v-sum-base
        acc-other-found = yes
      .
          if available bf_inv-line
          then do:
      assign
        acc-other-qnty2 = acc-other-qnty2 + ( if bf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
                                              then ( - bf_inv-line.wast-cli-qnty )
                                              else     bf_inv-line.wast-cli-qnty )
      .
          end.
    end. /* for each bf_trn-doc */

    if acc-other-found = yes
    then do:
      run create-treal-2 in this-procedure
        ( input t-2.gds-code
        , input -1
        , input 0
        , input acc-other-qnty1
        , input acc-other-qnty2
        , input v-sum-base
        , input "Проч докум.расход"
        , input no
        , input ?
        ) no-error .
    end. /* acc-other-found */
  end. /* for each t-2 */
end. /* if moving = yes */

assign
  jj = 1
.
for each t-2 no-lock
:
  find first tt-zz1 where
             tt-zz1.gds-code = t-2.gds-code no-error .
  if not available tt-zz1
  then do:
    create tt-zz1.
    assign
           tt-zz1.gds-code    = t-2.gds-code
           tt-zz1.b-code      = t-2.main-code
           tt-zz1.gds-name    = t-2.gds-name
           tt-zz1.artic       = t-2.artic
           tt-zz1.prod-type   = t-2.prod-type
           tt-zz1.prod-code   = t-2.prod-code
           tt-zz1.qnty-before = t-2.qnty1-before
           tt-zz1.qnty-after  = t-2.qnty1-after
           tt-zz1.last-price  = t-2.last-price
           tt-zz1.order       = jj
           jj                 = jj + 1
    .
  end.

  assign
    d-state-mh-cnt = 0.00
  .
  for each bf_rvs-line-pump no-lock where
           bf_rvs-line-pump.rvs-code = bf_rvs-doc.rvs-code and
           bf_rvs-line-pump.obj-type = bf_rvs-doc.obj-type and
           bf_rvs-line-pump.obj-code = bf_rvs-doc.obj-code and
           bf_rvs-line-pump.gds-code = t-2.gds-code
  :
    assign
      d-state-mh-cnt = d-state-mh-cnt + bf_rvs-line-pump.state-mh-cnt
    .
  end. /* for each bf_rvs-line-pump */

  if available previous_rvs-doc
  then do:
    for each bf_rvs-line-pump no-lock where
             bf_rvs-line-pump.rvs-code = previous_rvs-doc.rvs-code and
             bf_rvs-line-pump.obj-type = previous_rvs-doc.obj-type and
             bf_rvs-line-pump.obj-code = previous_rvs-doc.obj-code and
             bf_rvs-line-pump.gds-code = t-2.gds-code
    :
    assign
      d-state-mh-cnt = d-state-mh-cnt - bf_rvs-line-pump.state-mh-cnt
    .
    end. /* for each bf_rvs-line-pump */
  end. /* if available previous_rvs-doc */

  assign
    /* tt-zz1.qnty-05 + treal-2.qnty1 */
    tt-zz1.qnty-05 = d-state-mh-cnt
  .

  for each tincome-2 no-lock where
           tincome-2.gds-code = t-2.gds-code
  :
    assign
      tt-zz1.qnty-04 = tt-zz1.qnty-04 + tincome-2.qnty1
    .
  end. /* for each tincome-2 */

  /* out-name = "Списание"             cpay-code = -5 ii = ? is-pay = no */
  /* out-name = "Инвентаризации"       cpay-code = -4 ii = ? is-pay = no */
  /* out-name = "Отпуск без ККМ"       cpay-code = -3 ii = ? is-pay = no */
  /* out-name = "Технолог.проливы"     cpay-code = -2 ii = ? is-pay = no */
  /* out-name = "Прочий докум.расход"  cpay-code = -1 ii = ? is-pay = no */

  for each treal-2 no-lock where
           treal-2.gds-code = t-2.gds-code
  break by treal-2.gds-code
  :

/*
define stream Err_Out .
define shared variable g#report-num as integer no-undo.
output stream Err_Out to value( "c:\work14_1\report" + string( g#report-num ) + "_r-z1zvit.txt" ) append .
put stream Err_Out unformatted
  string( if treal-2.gds-code  = ? then "?" else string( treal-2.gds-code,  ">>>>>>>>>9":U  ), "x(10)":U ) + " ":U +
  string( if treal-2.cpay-code = ? then "?" else string( treal-2.cpay-code, "->9":U         ), "x(3)":U  ) + " ":U +
  string( if treal-2.curr-code = ? then "?" else string( treal-2.curr-code, ">>9":U         ), "x(3)":U  ) + " ":U +
  string( if treal-2.qnty1     = ? then "?" else string( treal-2.qnty1,     "->>>>>>9.99":U ), "x(11)":U ) + " ":U +
  string( if treal-2.qnty2     = ? then "?" else string( treal-2.qnty2,     "->>>>>>9.99":U ), "x(11)":U ) + " ":U +
  string( if treal-2.netto     = ? then "?" else string( treal-2.netto,     "->>>>>>9.99":U ), "x(11)":U ) + " ":U +
  string( if treal-2.out-name  = ? then "?" else string( treal-2.out-name,  "x(12)":U       ), "x(12)":U ) + " ":U +
  string( if treal-2.is-pay    = ? then "?" else string( treal-2.is-pay,    "yes/no":U      ), "x(3)":U  ) + " ":U +
  string( if treal-2.ii        = ? then "?" else string( treal-2.ii,        "->9":U         ), "x(3)":U  ) + " ":U
.
*/
    if treal-2.ii = ?
    then do:
/*
put stream Err_Out unformatted "***" skip .
output stream Err_Out to close .
*/
      next .
    end.
/*
put stream Err_Out unformatted skip .
output stream Err_Out to close .
*/

    if first-of( treal-2.gds-code )
    then do:
      assign
        group-was-found = ( if group-was-found <> no then ? else no )
      .
    end. /* if first-of( treal-2.gds-code ) */

    case treal-2.cpay-code :
      when -5 then do:
        assign
          tt-zz1.qnty-11 = tt-zz1.qnty-11 + treal-2.qnty1
        .
      end. /* -5 */

      when -4 then do:

      end. /* -4 */

      when -3 then do:
        /* assign */
        /*   tt-zz1.qnty-05 = tt-zz1.qnty-05 + treal-2.qnty1 */
        /* . */
      end. /* -3 */

      when -2 then do:

      end. /* -2 */

      when -1 then do:

      end. /* -1 */

      otherwise do:
        if treal-2.ii <> ?
        then do:
          /* assign */
          /*  tt-zz1.qnty-05 = tt-zz1.qnty-05 + treal-2.qnty1 */
          /* . */
          find first ub.cash-pay no-lock where
                     ub.cash-pay.cdpay-code = treal-2.cpay-code and
                     ub.cash-pay.curr-code  = treal-2.curr-code no-error .
          if available ub.cash-pay
          then do:
            assign
              cashpay-was-found = yes
            .
            find first ub.cash-pay-attr no-lock where
                       ub.cash-pay-attr.cdpay-code = ub.cash-pay.cdpay-code and
                       ub.cash-pay-attr.curr-code  = ub.cash-pay.curr-code  and
                       ub.cash-pay-attr.host-code  = 0                      and
                       ub.cash-pay-attr.obj-type   = "":U                   and
                       ub.cash-pay-attr.obj-code   = 0                      and
                       ub.cash-pay-attr.attr-code  = {&cp-attr-grp-code}    no-error .
            if not available ub.cash-pay-attr
            then do:
              find first ub.cash-pay-attr no-lock where
                         ub.cash-pay-attr.cdpay-code = ub.cash-pay.cdpay-code and
                         ub.cash-pay-attr.curr-code  = ub.cash-pay.curr-code  and
                         ub.cash-pay-attr.attr-code  = {&cp-attr-grp-code}    no-error .
            end. /* if not available ub.cash-pay-attr */
            if available ub.cash-pay-attr
            then do:
              case entry( 1, ub.cash-pay-attr.attr-value, {&delim-par} ) :
                when "готівка" then do:
                  assign
                    tt-zz1.qnty-06   = tt-zz1.qnty-06   + treal-2.qnty1
                    tt-zz1.sum-cash  = tt-zz1.sum-cash  + treal-2.netto
                    group-was-found  = ( group-was-found <> no )
                  .
                end. /* "готівка" */
                when "від/тал" then do:
                  assign
                    tt-zz1.qnty-07   = tt-zz1.qnty-07   + treal-2.qnty1
                    tt-zz1.sum-other = tt-zz1.sum-other + treal-2.netto
                    group-was-found  = ( group-was-found <> no )
                  .
                end. /* "від/тал" */
                when "ел.к."   then do:
                  assign
                    tt-zz1.qnty-08   = tt-zz1.qnty-08   + treal-2.qnty1
                    tt-zz1.sum-other = tt-zz1.sum-other + treal-2.netto
                    group-was-found  = ( group-was-found <> no )
                  .
                end. /* "ел.к." */
              end case. /* ub.cash-pay-attr.attr-value */
            end. /* if available ub.cash-pay-attr */
          end. /* if available ub.cash-pay */
          else do: /* if not available ub.cash-pay */
            /* assign */
            /*   tt-zz1.qnty-07   = tt-zz1.qnty-07   + treal-2.qnty1 */
            /*   tt-zz1.sum-other = tt-zz1.sum-other + treal-2.netto */
            /* . */
          end. /* if not available ub.cash-pay */

          assign
            group-was-found = ( group-was-found = yes )
          .
        end. /* if treal-2.ii <> ? */
      end. /* otherwise */
    end case. /* treal-2.cpay-code */
  end. /* for each treal-2 */
end. /* for each t-2 */

if cashpay-was-found = yes and
   group-was-found   = no
then do:
  message "С кассы были получены платежи, которые не попали в гуппы:" skip( 0 )
          {&tabulation} '"' + "за готівку" + '"' skip( 0 )
          {&tabulation} '"' + "за від/тал" + '"' skip( 0 )
          {&tabulation} '"' + "за ел.к."   + '"' skip( 1 )
          "Суммы этих платежей НЕ ВКЛЮЧЕНЫ в отчет."
  view-as alert-box information.
end.

assign
  group-was-found   = ?
  cashpay-was-found = no
.
for each treal-3 no-lock
:
  find first ub.cash-pay no-lock where
             ub.cash-pay.cdpay-code = treal-3.cpay-code and
             ub.cash-pay.curr-code  = treal-3.curr-code no-error .
  if available ub.cash-pay
  then do:
    assign
      cashpay-was-found = yes
    .
    find first ub.cash-pay-attr no-lock where
               ub.cash-pay-attr.cdpay-code = ub.cash-pay.cdpay-code and
               ub.cash-pay-attr.curr-code  = ub.cash-pay.curr-code  and
               ub.cash-pay-attr.host-code  = 0                      and
               ub.cash-pay-attr.obj-type   = "":U                   and
               ub.cash-pay-attr.obj-code   = 0                      and
               ub.cash-pay-attr.attr-code  = {&cp-attr-grp-code}    no-error .
    if not available ub.cash-pay-attr
    then do:
      find first ub.cash-pay-attr no-lock where
                 ub.cash-pay-attr.cdpay-code = ub.cash-pay.cdpay-code and
                 ub.cash-pay-attr.curr-code  = ub.cash-pay.curr-code  and
                 ub.cash-pay-attr.attr-code  = {&cp-attr-grp-code}    no-error .
    end. /* if not available ub.cash-pay-attr */
    if available ub.cash-pay-attr
    then do:
      case entry( 1, ub.cash-pay-attr.attr-value, {&delim-par} ) :
        when "готівка" then do:
          assign
            total-cash-other = total-cash-other + treal-3.netto
            group-was-found  = ( group-was-found <> no )
          .
        end. /* "готівка" */
        when "від/тал" then do:
          assign
            total-card-other = total-card-other + treal-3.netto
            group-was-found  = ( group-was-found <> no )
          .
        end. /* "від/тал" */
        when "ел.к."   then do:
          assign
            total-card-other = total-card-other + treal-3.netto
            group-was-found  = ( group-was-found <> no )
          .
        end. /* "ел.к." */
      end case. /* ub.cash-pay-attr.attr-value */
    end. /* if available ub.cash-pay-attr */
  end. /* if available ub.cash-pay */
end. /* for each treal-3 */

assign
  total-other = total-cash-other + total-card-other
.

if cashpay-was-found = yes and
   group-was-found   = no
then do:
  message "За сопутствующие товары были получены платежи, которые не попали в итоги:" skip( 0 )
          {&tabulation} '"' + "готівкою"              + '"' skip( 0 )
          {&tabulation} '"' + "за від./тал./ел.карт." + '"' skip( 1 )
          "Суммы этих платежей НЕ ВКЛЮЧЕНЫ в отчет."
  view-as alert-box information.
end.

if cashpay-was-found = yes and
   group-was-found   = no
then do:
  message "За сопутствующие товары были получены платежи, которые не попали в итоги:" skip( 0 )
          {&tabulation} '"' + "готівкою"              + '"' skip( 0 )
          {&tabulation} '"' + "за від./тал./ел.карт." + '"' skip( 1 )
          "Суммы этих платежей НЕ ВКЛЮЧЕНЫ в отчет."
  view-as alert-box information.
end.

for each tt-zz1 no-lock
break by tt-zz1.gds-code
:
  assign
    pol1  = tt-zz1.gds-name
    pol2  = tt-zz1.last-price
    pol3  = tt-zz1.qnty-before
    pol4  = tt-zz1.qnty-04
    pol5  = tt-zz1.qnty-05
    pol6  = tt-zz1.qnty-06
    pol7  = tt-zz1.qnty-07
    pol8  = tt-zz1.qnty-08
    pol9  = ?
    pol10 = ?
    pol11 = tt-zz1.qnty-11
    pol12 = tt-zz1.qnty-after
    pol13 = tt-zz1.sum-cash
    pol14 = tt-zz1.sum-other
    pol15 = pol13 + pol14
  .
  assign
    total-cash-petrol = total-cash-petrol + tt-zz1.sum-cash
    total-card-petrol = total-card-petrol + tt-zz1.sum-other
  .

  if p-can-print = yes
  then do:
    display stream PrnLibStream pol1                  sym1
                                pol2  when pol2  <> ? sym2
                                pol3                  sym3
                                pol4                  sym4
                                pol5                  sym5
                                pol6                  sym6
                                pol7                  sym7
                                pol8                  sym8
                                pol9  when pol9  <> ? sym9
                                pol10 when pol10 <> ? sym10
                                pol11                 sym11
                                pol12                 sym12
                                pol13                 sym13
                                pol14                 sym14
                                pol15                 sym15 sym16
    with frame FRAME-1 .
    /* down stream PrnLibStream */
    /*   1 */
    /* with frame FRAME-1 . */

    {&PutExcel} pol1  {&tabulation}
    .
      if pol2 = ?
      then do:
    {&PutExcel}       {&tabulation}
    .
      end.
      else do:
    {&PutExcel} pol2  {&tabulation}
    .
      end.
    {&PutExcel} pol3  {&tabulation}
                pol4  {&tabulation}
                pol5  {&tabulation}
                pol6  {&tabulation}
                pol7  {&tabulation}
                pol8  {&tabulation}
    /*          pol9                */
                      {&tabulation}
    /*          pol10               */
                      {&tabulation}
                pol11 {&tabulation}
                pol12 {&tabulation}
                pol13 {&tabulation}
                pol14 {&tabulation}
                pol15 skip
    .
    assign
      j_Excel-line = j_Excel-line + 1
    .
    /* {&PutExcel} fill( {&tabulation}, 14 ) skip */
    /* . */
    /* assign */
    /*   j_Excel-line = j_Excel-line + 1 */
    /* . */
  end. /* if p-can-print */

  if last( tt-zz1.gds-code )
  then do:
    if p-can-print = yes
    then do:
      underline stream PrnLibStream pol1  sym1
                                    pol2  sym2
                                    pol3  sym3
                                    pol4  sym4
                                    pol5  sym5
                                    pol6  sym6
                                    pol7  sym7
                                    pol8  sym8
                                    pol9  sym9
                                    pol10 sym10
                                    pol11 sym11
                                    pol12 sym12
                                    pol13 sym13
                                    pol14 sym14
                                    pol15 sym15 sym16
      with frame FRAME-1 .
    end. /* if p-can-print */
  end. /* last( tt-zz1.gds-code ) */
end. /* for each tt-zz1 */

assign
  total-petrol = total-cash-petrol + total-card-petrol
.
assign
  total-cash-total = total-cash-petrol + total-cash-other
  total-card-total = total-card-petrol + total-card-other
.

/*
for each bf_inkas no-lock where
         bf_inkas.host-code  = p-host-code and
         bf_inkas.obj-type   = pobj-type   and
         bf_inkas.obj-code   = pobj-code   and
         bf_inkas.shift-date = pshift-date and
         bf_inkas.shift-num  = pshift-num  and
         bf_inkas.status_    = {&fact}     use-index shift
:
  for each bf_inkas-pay no-lock where
           bf_inkas-pay.inkas-code = bf_inkas.inkas-code
  :
    find first ub.cash-pay no-lock where
               ub.cash-pay.cdpay-code = bf_inkas-pay.pay-code  and
               ub.cash-pay.curr-code  = bf_inkas-pay.curr-code no-error .
    if available ub.cash-pay
    then do:
      if ub.cash-pay.is-cash = yes
      then do:
        assign
          total-cash-total = total-cash-total + bf_inkas-pay.tot-rubl
        .
      end.
      else do:
        assign
          total-card-total = total-card-total + bf_inkas-pay.tot-rubl
        .
      end.
    end.
  end. /* for each bf_inkas-pay */
end. /* for each bf_inkas */
*/

assign
  total-total = total-total + total-cash-total + total-card-total
.

if p-can-print = yes
then do:
  put stream PrnLibStream unformatted
    space( 91 ) "         Разом :  " string( string( total-cash-petrol, ">>>>9.99":U ), "x(8)":U ) " ":U
                                     string( string( total-card-petrol, ">>>>9.99":U ), "x(8)":U ) " ":U
                                     string( string( total-petrol,      ">>>>9.99":U ), "x(8)":U ) skip
    space( 91 ) "Супутні товари :  " string( string( total-cash-other,  ">>>>9.99":U ), "x(8)":U ) " ":U
                                     string( string( total-card-other,  ">>>>9.99":U ), "x(8)":U ) " ":U
                                     string( string( total-other,       ">>>>9.99":U ), "x(8)":U ) skip
    space( 91 ) "        Усього :  " string( string( total-cash-total,  ">>>>9.99":U ), "x(8)":U ) " ":U
                                     string( string( total-card-total,  ">>>>9.99":U ), "x(8)":U ) " ":U
                                     string( string( total-total,       ">>>>9.99":U ), "x(8)":U ) skip
  .

  assign
    j_Excel-line = j_Excel-line + 12
  .
  /* {&PutExcel} substitute( 'select("r&1c&2:r&3c&4 ")' */
  /*                       , j_Excel-line */
  /*                       , 91 */
  /*                       , j_Excel-line + 3 */
  /*                       , 134 )                            {&new-line} */
  /*             'border( 1, 1, 1, 1, 1, , 0, 0, 0, 0, 0 )':U {&new-line} */
  /*             'alignment( 7, yes, 2, 4 )':U                {&new-line} */
  /* . */
  {&PutExcel} skip
  .
  {&PutExcel} fill( " ":U, 92 )    +
              "         Разом :  " + string( total-cash-petrol, ">>>>9.99":U ) + " ":U +
                                     string( total-card-petrol, ">>>>9.99":U ) + " ":U +
                                     string( total-petrol,      ">>>>9.99":U )   skip
              fill( " ":U, 92 )    +
              "Супутні товари :  " + string( total-cash-other,  ">>>>9.99":U ) + " ":U +
                                     string( total-card-other,  ">>>>9.99":U ) + " ":U +
                                     string( total-other,       ">>>>9.99":U )   skip
              fill( " ":U, 92 )    +
              "        Усього :  " + string( total-cash-total,  ">>>>9.99":U ) + " ":U +
                                     string( total-card-total,  ">>>>9.99":U ) + " ":U +
                                     string( total-total,       ">>>>9.99":U )   skip
  .
end. /* if p-can-print */

assign
  p-total-cash = total-cash-total
  p-total-all  = total-total
.