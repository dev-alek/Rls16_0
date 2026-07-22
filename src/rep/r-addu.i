/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Кусок печати ДопРасхода

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

creation date: 01/21/02 3:07

*/
&scop sort-pole  if sort-gr then  ub.goods.grp-name else ub.goods.artic

for each ub.add-line where ub.add-line.doc-code = ub.add-doc.doc-code no-lock ,
        first ub.goods where ub.goods.gds-code = ub.add-line.gds-code no-lock break by ({&sort-pole}) by ub.goods.artic :


     run lineattr-value-add-line-cli (
          input  ub.add-line.doc-code      ,
          input  ub.add-line.gds-code      ,
          input  ub.add-line.cli-type      ,
          input  ub.add-line.cli-code      ,
          input  ub.add-line.contract-code ,
          input  ub.add-line.host-code     ,
          output v-exch-code    ,
          output v-exch-rate    ,
          output v-exch-scale   ,
          output v-sum-cli      ,
          output v-sum-vat      )
          no-error .
          if error-status :error then  v-exch-code = 0 .
   find first  ub.currency NO-LOCK WHERE ub.currency.curr-code = v-exch-code no-error .
   assign
    b-contr          = if ub.add-line.contract-code = 0 then "" else  string ( ub.add-line.contract-code )
    b-val            = ub.currency.curr-abbr
    b-val-rate       = v-exch-rate
    lines_counter    = lines_counter + 1
    b-sum-cli        = v-sum-cli
    b-sum-rubl       = ub.add-line.sum-rubl
    b-sum-base       = ub.add-line.sum-base
    .

   find first buf_clients no-lock where
              buf_clients.obj-type = ub.add-line.cli-type and
              buf_clients.obj-code = ub.add-line.cli-code
              no-error .

    b-cli-name = buf_clients.obj-type + string ( buf_clients.obj-code ) + "(" + buf_clients.obj-name + ")".
    find first ub.gds-add-charges no-lock where
               ub.gds-add-charges.gds-code = ub.add-line.gds-code
               no-error .
               if available   ub.gds-add-charges then do:
    B-method = alg-name( buffer ub.gds-add-charges) .
    end.
    else do:
    B-method = "" .
    end.
    accumulate
     ( ub.add-line.sum-rubl ) ( total )
     ( ub.add-line.sum-base ) ( total )
       ub.goods.artic ( count )
   .

    display stream outstream
      sym1
      lines_counter
      sym2
      ub.goods.artic
      sym3
      ub.goods.gds-name
      sym4
      b-val
      sym5
      b-val-rate
      sym6
      b-contr
      sym7
      b-cli-name
      sym8
      b-sum-cli
      sym9
      b-sum-rubl
      sym10
      b-sum-base
      sym11
      b-method
      sym12
      with frame {2}.

      down stream outstream 1 with frame {2} .

    if ( ( ( accum count ub.goods.artic ) modulo 10 ) = 0 ) and
         ( ( accum count ub.goods.artic ) >= 10 ) then
        run waitfram-show in this-procedure ( "Обработано строк : " + string( accum count ub.goods.artic ) ) .
end.        /* for each ... */
assign
b-sum-base1 = accum total ( ub.add-line.sum-base)
b-sum-rubl1 = accum total ( ub.add-line.sum-rubl)
.

/* Итоговые суммы */
    display stream outstream
      "Итого " @ b-sum-cli
      b-sum-rubl1  @ b-sum-rubl
      b-sum-base1  @ b-sum-base
      sym9  sym10  sym7 sym12
      with frame {2}.
   down stream outstream 1 with frame {2} .