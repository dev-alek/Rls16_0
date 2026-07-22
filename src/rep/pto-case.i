/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Для печати топливной оборотки

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/29/05
Author: Dmitry Ukhanov
Creation date: 03/29/05

*/

&if '{1}' = 'TDEDT_Inv' &then
  &scop sign-factor 1
  &scop warp-factor ( bf_gds-dtl.doc-qnty  / bf_doc-line.fact-qnty ) * {&sign-factor}
&else
  &scop sign-factor ( abs( d_Val-Qty ) / d_Val-Qty )
  &scop warp-factor ( bf_gds-dtl.fact-qnty / bf_doc-line.fact-qnty ) * {&sign-factor}
&endif

when {&{1}}
then do:
    &if '{1}' = 'TDEDT_Inv' &then
  assign
    d_Val-Qty = bf_gds-dtl.doc-qnty
  .
    &else
  assign
    d_Val-Qty = bf_gds-dtl.fact-qnty
  .
  run lib-trn3_correct-quantity in g#lib-trn3
    ( input        bf_trn-doc.doc-type
    , input-output d_Val-Qty
    ) .
    &endif
  assign
    sum-lt = d_Val-Qty * ( ( if p-PrintRubl = yes then bf_gds-dtl.price-rubl  else bf_gds-dtl.price-base  )
                         - ( if p-PrintRubl = yes then bf_gds-dtl.discnt-rubl else bf_gds-dtl.discnt-base ) )
  .
  if available tt-allsum-line
  then do:
    assign
      sumVAT-lt = ( if p-PrintRubl = yes then tt-allsum-line.VAT-rubl-doc else tt-allsum-line.VAT-base-doc )
      sumSLT-lt = ( if p-PrintRubl = yes then tt-allsum-line.SLT-rubl-doc else tt-allsum-line.SLT-base-doc )
    .
  end. /* if available tt-allsum-line */
  else do: /* if not available tt-allsum-line */
    assign
      sumVAT-lt = 0
      sumSLT-lt = 0
    .
  end. /* if not available tt-allsum-line */
  assign
    oborot-{&bef-{1}}[ tt# +  1 ] = oborot-{&bef-{1}}[ tt# +  1 ] + d_Val-Qty
    oborot-{&bef-{1}}[ tt# +  2 ] = oborot-{&bef-{1}}[ tt# +  2 ] + sum-lt
    oborot-{&bef-{1}}[ tt# +  3 ] = oborot-{&bef-{1}}[ tt# +  3 ] + sumVAT-lt * {&sign-factor}
    oborot-{&bef-{1}}[ tt# + 12 ] = oborot-{&bef-{1}}[ tt# + 12 ] + sum-lt
    oborot-{&bef-{1}}[ tt# + 13 ] = oborot-{&bef-{1}}[ tt# + 13 ] + sumVAT-lt * {&sign-factor}
  .
&if '{1}' = 'TDEDT_Inv' &then
  assign
    oborot-{&bef-{1}}[ tt# + 11 ] = oborot-{&bef-{1}}[ tt# + 11 ] + bf_doc-line.cli-qnty      *
                                    ( if ( {&warp-factor} ) = ? then 1 else ( {&warp-factor} ) )
  .
&else
    if available bf_inv-line
    then do:
  assign
    oborot-{&bef-{1}}[ tt# + 11 ] = oborot-{&bef-{1}}[ tt# + 11 ] + bf_inv-line.wast-cli-qnty *
                                    ( if ( {&warp-factor} ) = ? then 1 else ( {&warp-factor} ) )
  .
    end. /* if available bf_inv-line */
&endif
  if tt# = 6 then do:
    assign
      oborot-{&bef-{1}} [ 10 ] = oborot-{&bef-{1}} [ 10 ] + sumSLT-lt * {&sign-factor}
      oborot-{&bef-{1}} [ 20 ] = oborot-{&bef-{1}} [ 20 ] + sumSLT-lt * {&sign-factor}
      oborot-{&bef-disc}[  1 ] = oborot-{&bef-disc}[  1 ] +
        ( if p-PrintRubl = yes then bf_gds-dtl.discnt-rubl else bf_gds-dtl.discnt-base ) * d_Val-Qty
      oborot-{&bef-disc}[ 11 ] = oborot-{&bef-disc}[ 11 ] +
        ( if p-PrintRubl = yes then bf_gds-dtl.discnt-rubl else bf_gds-dtl.discnt-base ) * d_Val-Qty
    .
  end.
end. /* when {&{1}} */

/* $Workfile$   E n d */

