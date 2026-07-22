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

*/
quantity = 0 .
for each kg-obj-list no-lock
   where xtog-obj = false
      or (kg-obj-list.obj-type = x-store-type and kg-obj-list.obj-code = x-store-code )
      :

    run ost-line-kg in this-procedure
     (input   kg-obj-list.obj-code  ,
      input   kg-obj-list.obj-type  ,
      input   gds-zap-artic     ,
      input   gds-zap-prod-code ,
      input   gds-zap-prod-type ,
      input   {1}               ,
      output  quantity    ) .

assign
  ostatok-{4} [11]   = ostatok-{4} [11] +  quantity
/* подсчет итогов */
 b1-ostatok-{4} [11] =  b1-ostatok-{4} [11] + quantity
 b2-ostatok-{4} [11] =  b2-ostatok-{4} [11] + quantity
 bo-ostatok-{4} [11] =  bo-ostatok-{4} [11] + quantity
 .

 &if '{5}' = 'tree' &then
 /* Если дерево то суммировать только верхний уровень */
 if tmp-gds.lvl <= 1 then
 &endif
 assign
  bi-ostatok-{4} [11] =  bi-ostatok-{4} [11] + quantity
 .
end.

 /* $Workfile$ e n d */