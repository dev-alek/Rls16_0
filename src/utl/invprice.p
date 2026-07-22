block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: invprice.p $
$Archive: utl/invprice.p $

Инициализация нулевой цены в документах если нет переоценки

Автор: Чернова Светлана Александровна
Дата создания: 05/22/08
Author: Svetlana Chernova
Creation date: 05/22/08

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: invprice.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/invprice.p $":U .
define variable vss-description as character no-undo init "Инициализация цены в документах".

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }

define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-install     as logical no-undo init no .

define variable p-doc-code as character no-undo .
define variable v-r-b as character no-undo .
{ gbl/curr-r-b.i v-r-b }
  run gbl/d-prompt.w
    ( 'title=Введите Номер документа\'
    + 'format=x(15)\'
    + 'type=char\'
    ,input-output p-doc-code
    ).
  if return-value = 'false':u
  then do:
    return .
  end.


find first ub.trn-doc exclusive-lock where
           ub.trn-doc.doc-code = p-doc-code no-error .
if ub.trn-doc.status_ = {&fact} then do:
   message "Только для открытых документов!"  view-as alert-box error .
   return .
end.

for each ub.gds-dtl exclusive-lock where
         ub.gds-dtl.doc-code = ub.trn-doc.doc-code and
        ( gds-dtl.price-rubl   = 0  or
          gds-dtl.price-base   = 0  or
          gds-dtl.price-rubl   = ?  or
          gds-dtl.price-base   = ?  )
         :
    find first ub.gds-obj no-lock where
               ub.gds-obj.obj-type  = ub.trn-doc.obj-type and
               ub.gds-obj.obj-code  = ub.trn-doc.obj-code and
               ub.gds-obj.artic     = ub.gds-dtl.artic      and
               ub.gds-obj.prod-type = ub.gds-dtl.prod-type and
               ub.gds-obj.prod-code = ub.gds-dtl.prod-code no-error .
   if not available  ub.gds-obj then do:
      message "На объекте нет такого товара (признака)! "
                ub.trn-doc.obj-type  skip
                ub.trn-doc.obj-code  skip
                ub.gds-dtl.artic     skip
                ub.gds-dtl.prod-type skip
                ub.gds-dtl.prod-code
                view-as alert-box error .
      next .
   end.

   if v-r-b = {&r-b-rubl} then do:
   assign
      gds-dtl.price-rubl   = ub.gds-obj.price-sale
      gds-dtl.price-base   = ub.gds-obj.price-sale / ub.trn-doc.base-rate * ub.trn-doc.base-scale
   .
   end.
   else do:
   assign
      gds-dtl.price-base   = ub.gds-obj.price-sale
      gds-dtl.price-rubl   = ub.gds-obj.price-sale * ub.trn-doc.base-rate / ub.trn-doc.base-scale
   .

   end.

end.

message 'все' .