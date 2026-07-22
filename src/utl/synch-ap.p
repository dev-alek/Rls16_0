block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: synch-ap.p $
$Archive: utl/synch-ap.p $

Синхронизация Ассортиментной политики ГБД и УБД

Автор: Чернова Светлана Александровна
Дата создания: 05/26/08
Author: Svetlana Chernova
Creation date: 05/26/08

*/
define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-install     as logical no-undo init no .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: synch-ap.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/synch-ap.p $":U .
define variable vss-description as character no-undo init "Синхронизация Ассортиментной политики ГБД и УБД".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/waitfram.i }

if g#db-num <> 0 then do:
   message "Утилита для ГБД !!!"  view-as alert-box information .
   return .
end.

for each ub.assortment-matrix no-lock :
run waitfram-show (substitute("Шапка Ассортиментной матрицы  &1 &2" , ub.assortment-matrix.obj-type, ub.assortment-matrix.obj-code ) ).
    run str/callnews.p
      (input "assortment-matrix"
      ,input (buffer ub.assortment-matrix:handle)
      ) no-error .
end.
for each ub.assortment-matrix-goods no-lock :
run waitfram-show (substitute("Ассортиментная матрица  &1 &2 код товара &3"  , ub.assortment-matrix-goods.obj-type, ub.assortment-matrix-goods.obj-code, ub.assortment-matrix-goods.gds-code ) ).
    run str/callnews.p
      (input "assortment-matrix-goods"
      ,input (buffer ub.assortment-matrix-goods:handle)
      ) no-error .
end.

for each ub.gds-obj-prop no-lock :
run waitfram-show (substitute("ИЖТ  &1 &2 код товара &3"  , ub.gds-obj-prop.obj-type, ub.gds-obj-prop.obj-code, ub.gds-obj-prop.gds-code ) ).
    run str/callnews.p
      (input "gds-obj-prop"
      ,input (buffer ub.gds-obj-prop:handle)
      ) no-error .
end.

message "Все" view-as alert-box information .