using Progress.Lang.*.
using ibs.th.gbl.collection.*.
using ibs.th.ref.promo.*.
block-level on error undo, throw.
class ibs.th.ref.promo.promoActionSubs inherits asubjects:
define variable vss-revision    as character no-undo initial "$Revision: 18f7b619da54, 1481, rls $":U .
define variable vss-author      as character no-undo initial "$Author: DARuban $":U .
define variable vss-date        as character no-undo initial "$Date: Thu Aug 30 10:41:44 2018 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: promoactionsubs.cls $":U .
define variable vss-archive     as character no-undo initial "$Archive: ibs/th/ref/promo/promoactionsubs.cls $":U .
define variable vss-description as character no-undo initial "Коллекция объектов акций.".
  define property promoActionObjCurr as class promoActionSub
    get:
      return cast (SubjectObjCurr, promoActionSub).
    end.
end class.
