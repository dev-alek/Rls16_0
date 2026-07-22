/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение общих данных

Автор: Булгаков Андрей Николаевич
Дата создания: 01/13/06
Author: Andrew Bulgakoff
Creation date: 01/13/06

*/

&scop temp-table_prefix tt-zz

&if "{2}" = "" or "{2}" = "*" or lookup( "1", "{2}" ) > 0 &then
  &if "{3}" = "" &then
    &scop temp-table-name {&temp-table_prefix}1
  &else
    &scop temp-table-name {3}
  &endif

  define {1} temp-table {&temp-table-name} no-undo
    field gds-code     like ub.goods.gds-code
    field b-code       like ub.bar-code.b-code
    field artic        like ub.goods.artic
    field prod-type    like ub.goods.prod-type
    field prod-code    like ub.goods.prod-code
    field qnty-before  as   decimal            format "->>>>>9.99":U  decimals 10
    field qnty-after   as   decimal            format "->>>>>9.99":U  decimals 10
    field qnty-04      as   decimal            format "->>>>>9.99":U  decimals 10
    field qnty-05      as   decimal            format "->>>>>9.99":U  decimals 10
    field qnty-06      as   decimal            format "->>>>>9.99":U  decimals 10
    field qnty-07      as   decimal            format "->>>>>9.99":U  decimals 10
    field qnty-08      as   decimal            format "->>>>>9.99":U  decimals 10
    field qnty-09      as   decimal            format "->>>>>9.99":U  decimals 10
    field qnty-10      as   decimal            format "->>>>>9.99":U  decimals 10
    field qnty-11      as   decimal            format "->>>>>9.99":U  decimals 10
    field last-price   as   decimal            format ">>9.99":U      decimals 10
    field gds-name     like ub.goods.gds-name  format "x(8)":U
    field sum-cash     as   decimal            format ">>>>9.99":U    decimals 10
    field sum-other    as   decimal            format ">>>>9.99":U    decimals 10
    field order        as   integer            format "->>>>>>>>>9":U
    index gds-code     is   unique primary gds-code
    index artic        is   unique         artic    prod-type prod-code
    index b-code       is   unique         b-code.
&endif

&if "{2}" = "" or "{2}" = "*" or lookup( "2", "{2}" ) > 0 &then
  &if "{3}" = "" &then
    &scop temp-table-name {&temp-table_prefix}2
  &else
    &scop temp-table-name {3}
  &endif

  define {1} temp-table {&temp-table-name} no-undo
    field gds-code    like ub.goods.gds-code
    field b-code      like ub.bar-code.b-code
    field artic       like ub.goods.artic
    field prod-type   like ub.goods.prod-type
    field prod-code   like ub.goods.prod-code
    field gds-name    like ub.goods.gds-name          format "x(8)":U                  /*  1    */
    field reservoir   like ub.place.loc1              format "x(2)":U                  /*  2    */
    field level-total as   decimal                    format ">>>>9":U     decimals 10 /*  3    */
    field level-water as   decimal                    format ">>9":U       decimals 10 /*  4    */
    field pipe-line   as   decimal                    format ">>>9.99":U   decimals 10 /*  5    */
    field shift-qnty  as   decimal                    format ">>>>>9.99":U decimals 10 /*  6    */
    field differ-qnty as   decimal                    format "->>>>9.99":U decimals 10 /*  7, 8 */
    field pump-code   like ub.rvs-line-pump.pump-code                                  /*  9    */
    field shift-stop  as   decimal                    format ">>>>>9.99":U decimals 10 /* 10    */
    field shift-start as   decimal                    format ">>>>>9.99":U decimals 10 /* 11    */
    field mh-real     as   decimal                    format ">>9.99":U    decimals 10 /* 12    */
    field mh-total    as   decimal                    format ">>9.99":U    decimals 10 /* 13    */
    field delta-prc   as   decimal                    format "->>>>9.99":U decimals 10 /* 14    */
    field delta-qnty  as   decimal                    format "->>>>9.99":U decimals 10 /* 15    */
    field pl-code     like ub.rvs-line.pl-code
    field order       as   integer                    format "->>>>>>>>>9":U
    index gds-code    is   unique primary gds-code                     pl-code pump-code
    index artic       is   unique         artic    prod-type prod-code pl-code pump-code
    index gds-order   is   unique         gds-code                             order
    index pl-order    is   unique         gds-code                     pl-code order.
&endif

/* $Workfile$   E n d */

