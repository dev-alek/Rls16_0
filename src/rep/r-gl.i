/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Для Отчета Оборотная Ведомость

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 01/09/02 12:48

*/
/* по оборотке */
define variable div# as char no-undo.
define variable fr as logical no-undo .
define variable fr0 as logical no-undo .
define variable tmp#stroka as character no-undo .
define variable tmp#stroka0 as character no-undo .
define variable v-bar-code    like ub.bar-code.b-code no-undo  .
define variable s-bar-code   as character format "x(9)" no-undo .
&glob frame-d  DOWN stream   OutStream 1 with FRAME ZAPAS
&glob frame2-d  DOWN stream   OutStream2 1 with FRAME ZAPAS2
&glob WFz with FRAME ZAPAS
&glob put-u1 PUT stream  OutStream  UNFORMATTED
&glob put-u2 PUT stream  OutStream2  UNFORMATTED
&glob All-sym sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
&glob All-sym11 sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11
&glob All-sym9 sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9

/* создание временной таблицы с деревом */
define temp-table tmp-gds no-undo
  field id as integer
  field name      as character  format "x(256)"
  field f-name    as character  format "x(256)"
  field node-code as integer
  field lvl       as integer
 index pi id
.

define variable NEW-vat        like ub.doc-line.vat-pc    no-undo.
define variable LAST-vat       like ub.doc-line.vat-pc    no-undo.
define variable  var-vat-pc    like ub.doc-line.vat-pc    no-undo.

&glob break-vat  (func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))
&glob break-vat2 (func-vat(goods.gds-code,ot-line.obj-type,ot-line.obj-code))
&glob break-vat3 (func-vat(gds-zap-b-code,v-cntxt-obj-type,v-cntxt-obj-code))

define variable g-ll as integer no-undo . /*номер уровня по*/
define variable id as integer no-undo .
&if '{1}' = 'tree'  &then
&glob break-lavel (n-lavel(goods.grp-name,tmp-gds.lvl))
&glob break-lavel-gds-list (n-lavel(gds-list.grp-name,tmp-gds.lvl))
&else
&glob break-lavel (n-lavel(goods.grp-name,xlavel))
&glob break-lavel-gds-list (n-lavel(gds-list.grp-name,xlavel))
&endif

define temp-table temp-gds-list no-undo
  field gds-code  like ub.goods.gds-code
  field prod-code like ub.goods.prod-code
  field grp-name  like ub.goods.grp-name
  field gds-name  like ub.goods.gds-name
  field artic     like ub.goods.artic
  field vat-pc    as decimal
   index pi is primary unique gds-code ascending
   index i1 artic     ascending
   index i2 prod-code ascending
   index i3 grp-name  ascending
   index i33 gds-name  ascending
   index i4 vat-pc    ascending
   index i5 prod-code grp-name   ascending
   index i6 grp-name  prod-code   ascending
   .
define variable sum_1     as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable sum_2     as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b1-sum_1  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b1-sum_2  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b2-sum_1  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b2-sum_2  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bi-sum_1  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bi-sum_2  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bo-sum_1  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bo-sum_2  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
/* $Workfile$ e n d */