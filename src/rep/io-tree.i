/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

вызов процедуры

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 10/30/01 11:56

*/
run ost-line in this-procedure
    (input   x-store-code  ,
    input   x-store-type  ,
    input   gds-zap-artic     ,
    input   gds-zap-prod-code ,
    input   gds-zap-prod-type ,
    input   x-tog-shift       ,
    input   {1}               ,
    input   {&{2}}            ,
    input   {&root-cat-id}    ,
    input   xtog-obj    ,
    output  quantity    ,
    output  coast_r     ,
    output  coast_v     ,
    output  vat_r       ,
    output  vat_v       ,
    output  slt_r       ,
    output  slt_v       ).

assign
 &if "{3}" = "3" &then
  ostatok-{4} [4]        = round(ostatok-{4} [1] *  p-price-med , 2)
 &else
  ostatok-{4} [1 + {3}]   = quantity
 &endif

 ostatok-{4} [2 + {3}]   = if tprintrubl then coast_r else coast_v
 ostatok-{4} [3 + {3}]   = if tprintrubl then vat_r   else vat_v

 &if "{3}" = "6" &then
 ostatok-{4} [10]        = if tprintrubl then slt_r   else slt_v
 &endif
 .

  /* $Workfile$ e n d */