/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура расчета количества за период

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 06/02/03 3:58

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure ob-line  :
define input  parameter x-store-code     like ub.clients.obj-code     no-undo.
define input  parameter x-store-type     like ub.clients.obj-type     no-undo.
define input  parameter x-artic          like ub.ot-line.artic        no-undo.
define input  parameter x-prod-code      like ub.ot-line.prod-code    no-undo.
define input  parameter x-prod-type      like ub.ot-line.prod-type    no-undo.
define input  parameter x-fact-order-1   like ub.ot-line.fact-order   no-undo.
define input  parameter x-fact-order-2   like ub.ot-line.fact-order   no-undo.
define input  parameter x-sum-type       like ub.ot-line.sum-type     no-undo.
define input  parameter x-cat-id         like ub.ot-line.cat-id       no-undo.
define input  parameter x-ext-doc-type   like ub.ot-line.ext-doc-type no-undo.
define input  parameter xtog-obj         as   logical no-undo.
define input  parameter xtog-prn         as   logical no-undo.
define output parameter p-prih  as decimal no-undo .
define output parameter p-rash  as decimal no-undo .
define output parameter p-kassa as decimal no-undo .

define buffer p-doc-line for ub.doc-line.
define buffer p-gds-dtl  for ub.gds-dtl.
define variable p-doc-type as character no-undo .
define variable str-doc-type as character no-undo .
str-doc-type =
{&tdedt_pri_vnesh}      + "," +
{&tdedt_pri_prvo  }     + "," +
{&tdedt_spi_vnesh}      + "," +
{&tdedt_spi_prvo}       + "," +
{&tdedt_ras_prvo}       + "," +
{&tdedt_ras_perem}      + "," +
{&tdedt_vozvrat_perem}  + "," +
{&tdedt_ras_vnesh}      + "," +
{&tdedt_vozvrat_vnesh}  + "," +
{&tdedt_ras_vnesh_kass} + "," +
{&tdedt_vozvrat_vnesh_kass} .

assign
  p-prih  = 0
  p-rash  = 0
  p-kassa = 0
.
define variable i as integer no-undo .
define variable v-nn as integer   no-undo .
v-nn = num-entries( str-doc-type ) .
  repeat i = 1 to v-nn :
    p-doc-type = entry( i, str-doc-type) .
       for each p-doc-line where
                p-doc-line.obj-type    = x-store-type
            and p-doc-line.obj-code    = x-store-code
            and p-doc-line.artic       = x-artic
            and p-doc-line.prod-type   = x-prod-type
            and p-doc-line.prod-code   = x-prod-code
            and p-doc-line.ext-doc-type = p-doc-type
            and p-doc-line.status_     = {&fact}
            and p-doc-line.fact-order >= x-fact-order-1
            and p-doc-line.fact-order <= x-fact-order-2 no-lock :
        case p-doc-line.ext-doc-type:
        /*разбивка по типам документов */
        /* приход */
             when   {&tdedt_pri_vnesh}  or
             when   {&tdedt_pri_prvo  }     then
               do:
               assign p-prih   = p-prih  +  p-doc-line.fact-qnty.
               end.

        /* расход */
              when  {&tdedt_spi_vnesh}      then if  p-t-sp      then assign p-rash = p-rash   +  p-doc-line.fact-qnty.
              when  {&tdedt_spi_prvo}       then if  p-t-sppv    then assign p-rash = p-rash   +  p-doc-line.fact-qnty.
              when  {&tdedt_ras_prvo}       then if  p-t-sppv-2  then assign p-rash = p-rash   +  p-doc-line.fact-qnty.
              when  {&tdedt_ras_perem}      then if  p-t-sppv-3  then assign p-rash = p-rash   +  p-doc-line.fact-qnty.
              when  {&tdedt_vozvrat_perem}  then if  p-t-sppv-4  then assign p-rash = p-rash   -  p-doc-line.fact-qnty.
              when  {&tdedt_ras_vnesh}      then if  p-t-rv      then assign p-rash = p-rash   +  p-doc-line.fact-qnty.
              when  {&tdedt_vozvrat_vnesh}  then if  p-t-rvz     then assign p-rash = p-rash   -  p-doc-line.fact-qnty.
       /* касса */
              when  {&tdedt_ras_vnesh_kass}     then if p-t-rvc  then assign p-kassa  = p-kassa  +  p-doc-line.fact-qnty.
              when  {&tdedt_vozvrat_vnesh_kass} then if p-t-rvzc then assign p-kassa  = p-kassa  -  p-doc-line.fact-qnty.
          end case.
          if xtog-prn then      /*   Детализация по признакам   */
          for each p-gds-dtl where p-gds-dtl.doc-code  = p-doc-line.doc-code  and
                                   p-gds-dtl.artic     = p-doc-line.artic     and
                                   p-gds-dtl.prod-type = p-doc-line.prod-type and
                                   p-gds-dtl.prod-code = p-doc-line.prod-code no-lock  :
              find first tmp#zakaz-prn where tmp#zakaz-prn.artic     = p-gds-dtl.artic     and
                                             tmp#zakaz-prn.prod-type = p-gds-dtl.prod-type and
                                             tmp#zakaz-prn.prod-code = p-gds-dtl.prod-code and
                                             tmp#zakaz-prn.obj-type  = p-gds-dtl.obj-type  and
                                             tmp#zakaz-prn.obj-code  = p-gds-dtl.obj-code  and
                                             tmp#zakaz-prn.prt-code  = p-gds-dtl.prt-code  no-lock no-error .
              if not available tmp#zakaz-prn then do :
                create tmp#zakaz-prn.
                assign
                   tmp#zakaz-prn.artic     = p-gds-dtl.artic
                   tmp#zakaz-prn.prod-type = p-gds-dtl.prod-type
                   tmp#zakaz-prn.prod-code = p-gds-dtl.prod-code
                   tmp#zakaz-prn.obj-type  = p-gds-dtl.obj-type
                   tmp#zakaz-prn.obj-code  = p-gds-dtl.obj-code
                   tmp#zakaz-prn.prt-code  = p-gds-dtl.prt-code
                .
    end.
              case p-doc-line.ext-doc-type:
                    when  {&tdedt_spi_vnesh}      then if  p-t-sp      then assign tmp#zakaz-prn.qnty-sale = tmp#zakaz-prn.qnty-sale   +  p-gds-dtl.fact-qnty.
                    when  {&tdedt_spi_prvo}       then if  p-t-sppv    then assign tmp#zakaz-prn.qnty-sale = tmp#zakaz-prn.qnty-sale   +  p-gds-dtl.fact-qnty.
                    when  {&tdedt_ras_prvo}       then if  p-t-sppv-2  then assign tmp#zakaz-prn.qnty-sale = tmp#zakaz-prn.qnty-sale   +  p-gds-dtl.fact-qnty.
                    when  {&tdedt_ras_perem}      then if  p-t-sppv-3  then assign tmp#zakaz-prn.qnty-sale = tmp#zakaz-prn.qnty-sale   +  p-gds-dtl.fact-qnty.
                    when  {&tdedt_vozvrat_perem}  then if  p-t-sppv-4  then assign tmp#zakaz-prn.qnty-sale = tmp#zakaz-prn.qnty-sale   -  p-gds-dtl.fact-qnty.
                    when  {&tdedt_ras_vnesh}      then if  p-t-rv      then assign tmp#zakaz-prn.qnty-sale = tmp#zakaz-prn.qnty-sale   +  p-gds-dtl.fact-qnty.
                    when  {&tdedt_vozvrat_vnesh}  then if  p-t-rvz     then assign tmp#zakaz-prn.qnty-sale = tmp#zakaz-prn.qnty-sale   -  p-gds-dtl.fact-qnty.
                    when  {&tdedt_ras_vnesh_kass}     then if p-t-rvc  then assign tmp#zakaz-prn.qnty-sale = tmp#zakaz-prn.qnty-sale   +  p-gds-dtl.fact-qnty.
                    when  {&tdedt_vozvrat_vnesh_kass} then if p-t-rvzc then assign tmp#zakaz-prn.qnty-sale = tmp#zakaz-prn.qnty-sale   -  p-gds-dtl.fact-qnty.
                end case.
             /*   message substitute("был в obqntypr.i, for each gds-dtl, &1, &2, &3", p-doc-line.artic, tmp#zakaz-prn.prt-code, tmp#zakaz-prn.qnty-sale) view-as alert-box.    */
          end.    /*   for each p-gds-dtl  */

    end.  /*   for each p-doc-line  */
  end.
assign
  p-rash  = p-rash
  p-kassa = p-kassa
.

end procedure.
/* $Workfile$ e n d */