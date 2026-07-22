/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Кусок ТОРГ 26 для поставок

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

creation date: 01/21/02 3:07

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop sort-pole  if sort-gr then  ub.goods.grp-name else ub.goods.artic

for each ub.ord-line-rcv where
         ub.ord-line-rcv.rcv-code = ub.ord-doc-rcv.rcv-code and
         ub.ord-line-rcv.doc-code = ub.ord-doc-rcv.doc-code
         no-lock ,
      first ub.goods where ub.goods.prod-type = ub.ord-line-rcv.prod-type and
                        ub.goods.prod-code = ub.ord-line-rcv.prod-code and
                        ub.goods.artic = ub.ord-line-rcv.artic no-lock break by ({&sort-pole}) by ub.goods.artic
                        :

    find first ub.units where ub.units.unit-name = ub.ord-line-rcv.unit-cli no-lock no-error .
    assign
        lines_counter = lines_counter + 1  .

    accumulate  (ub.ord-line-rcv.cli-qnty * ub.ord-line-rcv.price-cli) ( total )
                 ub.ord-line-rcv.cli-qnty ( total )
                 ub.goods.artic ( count ).

    if sort-gr = true  and first-of ({&sort-pole}) then do:
      down stream outstream 1 with frame {2} .
      put stream outstream unformatted
           string("_______________Группа : " + trim(caps(ub.goods.grp-name)) + undline)  format "{1}"
           skip .
           end.
            b-price = if ub.ord-line-rcv.price-cli = ? then "" else string(ub.ord-line-rcv.price-cli) .
            b-qnty  = ub.ord-line-rcv.cli-qnty .
            b-stoim =  if b-price = "" then "" else string(decimal(b-price) * b-qnty) .
            b-service = ub.ord-doc-rcv.sum-service.
            b-ship    = ub.ord-doc-rcv.sum-ship   .

    display stream outstream
      sym1
      lines_counter
      sym2
      ub.goods.artic
      sym3
      ub.goods.gds-name
      sym4
      trim( string( ub.goods.gds-code )) @ tb-code
      sym5
      ub.units.okei
      sym6
      ub.units.unit-name
      sym7
      ub.goods.sort
      sym9
      b-price
      sym10
      b-qnty
      sym11
      b-stoim
      sym12   with frame {2}.
      down stream outstream 1 with frame {2} .
      if print-graft = false  then  put stream outstream linebuf format "{1}" skip.

    if ( ( ( accum count ub.goods.artic ) modulo 10 ) = 0 ) and
         ( ( accum count ub.goods.artic ) >= 10 ) then
        run waitfram-show in this-procedure ( "Обработано строк : " + string( accum count ub.goods.artic ) ) .
end.        /* for each ... */
assign
b-sum1 = accum total (ub.ord-line-rcv.cli-qnty * ub.ord-line-rcv.price-cli)
b-sum-qnty = accum total (ub.ord-line-rcv.cli-qnty)
b-sum = b-service + b-ship   + b-sum1.

/* Итоговые суммы */
  if b-sum1 = ? then do:
    display stream outstream
      "Итого " @ ub.units.unit-name
      b-sum-qnty  @ b-qnty
      sym9  sym10  sym7 sym12
      with frame {2}.
   end.
  else do:
    display stream outstream
      "Итого " @ ub.units.unit-name
      b-sum-qnty  @ b-qnty
      b-sum1  @ b-stoim
      sym9  sym10  sym7 sym12
      with frame {2}.
  end.
   down stream outstream 1 with frame {2} .
    if print-graft = false then put stream outstream linebuf format "{1}" skip.
    put stream outstream
      "Стоимость обслуживания:" + string( b-service , "->>>,>>>,>>9.99" ) + sym12 at 98 format "x(38)"  skip
      "    Стоимость доставки:" + string( b-ship    , "->>>,>>>,>>9.99" ) + sym12 at 98 format "x(38)"  skip
      if b-sum = ? then "" else
      "                 Всего:" + string( b-sum     , "->>>,>>>,>>9.99" ) + sym12 at 98 format "x(38)"  skip.

      down stream outstream 1 with frame {2} .
    if print-graft = false then put stream outstream linebuf at 101 format "x(40)" skip.
/* $workfile: torg-26.i $ e n d */