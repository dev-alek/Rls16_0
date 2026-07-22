/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

вызов процедуры печати

Автор: Чернова Светлана Александровна
Дата создания: 03/02/01
Author: Svetlana Chernova
Creation date: 03/02/01

*/

&if {1} = 1  &then
   (input v-cntxt-obj-code ,
    input v-cntxt-obj-type ,
    input base-type        ,
    input base-code        ,
    input Classify         ,
    input SortType         ,
    input SumsOnly         ,
    input ShowZero         ,
    input ShowZero-2       ,
    input tog-obj          ,
    input ShowCost         ,
    input ShowCostNDS      ,
    input ShowSale         ,
    input ShowSaleNDS      ,
    input ShowSale-2       ,
    input ShowSaleNDS-2    ,
    input tog-lavel        ,
    input var-lavel        ,
    input rserv            ,
    input print-o          ,
    input ShowMediator     ,
    input ShowSaleSLT      ,
    input ShowCost-2       ,
    input long-name        ,
    input tog-wt           ,
    input tog-ms           ,
    input is-petrl
   ) .
&Endif
&if {1} = 2  &then
   (input v-cntxt-obj-code ,
    input v-cntxt-obj-type ,
    input base-type        ,
    input base-code        ,
    input Classify         ,
    input SortType         ,
    input SumsOnly         ,
    input ShowZero         ,
    input ShowZero-2       ,
    input tog-obj          ,
    input ShowCost         ,
    input ShowCostNDS      ,
    input ShowSale         ,
    input ShowSaleNDS      ,
    input ShowSale-2       ,
    input ShowSaleNDS-2    ,
    input tog-lavel        ,
    input var-lavel        ,
    input rserv            ,
    input ShowMediator     ,
    input ShowSaleSLT      ,
    input ShowCost-2       ,
    input long-name        ,
    input tog-wt           ,
    input tog-ms           ,
    input is-petrl         ,
    input tog-dens
    ) .
&Endif
/* $Workfile$ e n d */