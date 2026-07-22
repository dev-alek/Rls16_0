block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gdsunitt.p $
$Archive: str/gdsunitt.p $

Дополняет в список товары c указанным типом единицы измерения.

Автор: Перваков Михаил Сергеевич
Дата создания: 04/12/06
Author: Mikhail Pervakov
Creation date: 04/12/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-unit-type-list as character no-undo .
define input parameter p-gds-type-list  as character no-undo .
define output parameter p-lns-cnt as integer no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: gdsunitt.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/gdsunitt.p $":U .
def var vss-description as character no-undo init "Дополняет в список товары c указанным типом единицы измерения.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/gds-list.i gds-list def shared }

define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
def var ind as integer no-undo .

do ind = 1 to num-entries(p-unit-type-list) :
  def var v-unit-type as character no-undo .
  assign
    v-unit-type = entry(ind, p-unit-type-list)
  .

  if not can-do( {&unit-type-list}, v-unit-type) then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный тип единицы измерения v-unit-type" skip
      "v-unit-type" v-unit-type skip
      "p-unit-type-list" p-unit-type-list skip
      "unit-types" {&unit-types} skip
      view-as alert-box error .
    undo, return error .
  end.

  for each ub.units no-lock
    where can-do( ub.units.type, v-unit-type )
  , each ub.goods no-lock
    where ub.goods.unit-base = ub.units.unit-name
      and can-do(p-gds-type-list, ub.goods.gds-type)
  :
    { cmp/gds-list.i gds-list }
    p-lns-cnt = lns-cnt.
  end.
end.