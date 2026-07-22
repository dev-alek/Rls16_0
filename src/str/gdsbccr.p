block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gdsbccr.p $
$Archive: str/gdsbccr.p $

Программа создания бар-кодов для всех партий свободной зоны товара

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/12/06

*/

define input parameter p-obj-type   like ub.gds-obj.obj-type  no-undo .
define input parameter p-obj-code   like ub.gds-obj.obj-code  no-undo .
define input parameter p-artic      like ub.gds-obj.artic     no-undo .
define input parameter p-prod-type  like ub.gds-obj.prod-type no-undo .
define input parameter p-prod-code  like ub.gds-obj.prod-code no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: gdsbccr.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/gdsbccr.p $":U .
def var vss-description as character no-undo init "Программа создания бар-кодов для всех партий свободной зоны товара".
{ cmp/vssrevis.i }
{ cmp/library.i  }
{ cmp/str-glbl.i }

define buffer buf_goods    for ub.goods .
define buffer buf_parts    for ub.parts .
define buffer buf_bar-code for ub.bar-code .

main-block:
do
on error undo, return error
:

  def var v-root-node    as integer no-undo .
  def var v-is-new       as logical no-undo .

  find first buf_goods no-lock
    where buf_goods.artic     = p-artic
      and buf_goods.prod-type = p-prod-type
      and buf_goods.prod-code = p-prod-code
    .

  { gbl/rootnode.i
    p-artic
    p-prod-type
    p-prod-code
    v-root-node
  }

  for each buf_parts no-lock
    where buf_parts.obj-type  = p-obj-type
      and buf_parts.obj-code  = p-obj-code
      and buf_parts.artic     = p-artic
      and buf_parts.prod-type = p-prod-type
      and buf_parts.prod-code = p-prod-code
      and buf_parts.out-code  = {&free-code}
  on error undo main-block, return error
  :
    { gbl/barcodcr.i
      buf_goods.gds-code
      v-root-node
      buf_parts.part-code
      buf_parts.in-code
      buf_goods.unit-base
      ?
      v-is-new
      buf_bar-code
    }
  end.
end.