/*

$Revision: 18f7b619da54, 1481, rls $
$Author: DARuban $
$Date: Thu Aug 30 10:41:44 2018 +0300 $
$Workfile: promocriterionsubs.cls $
$Archive: ibs/th/ref/promo/promocriterionsubs.cls $
 
Коллекция объектов критериев акции.

Автор: Рубан Дмитрий Андреевич
Дата создания: 11/07/18
Author: 
Creation date: 11/07/18

*/

using Progress.Lang.*.
using ibs.th.gbl.collection.*.
using ibs.th.ref.promo.*.
block-level on error undo, throw.

class ibs.th.ref.promo.promoCriterionSubs inherits asubjects: 
define variable vss-revision    as character no-undo initial "$Revision: 18f7b619da54, 1481, rls $":U .
define variable vss-author      as character no-undo initial "$Author: DARuban $":U .
define variable vss-date        as character no-undo initial "$Date: Thu Aug 30 10:41:44 2018 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: promocriterionsubs.cls $":U .
define variable vss-archive     as character no-undo initial "$Archive: ibs/th/ref/promo/promocriterionsubs.cls $":U .
define variable vss-description as character no-undo initial "Коллекция объектов критериев акции.". 
   
  define property promoCriterionObjCurr as class promoCriterionSub
    get:
      return cast (SubjectObjCurr, promoCriterionSub). 
    end.

end class.
