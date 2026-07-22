using Progress.Lang.*.
using ibs.th.gbl.collection.*.
using ibs.th.ref.promo.*.
block-level on error undo, throw.
class ibs.th.ref.promo.promoGoodsSubs inherits asubjects:
define variable vss-revision    as character no-undo initial "$Revision: 18f7b619da54, 1481, rls $":U .
define variable vss-author      as character no-undo initial "$Author: DARuban $":U .
define variable vss-date        as character no-undo initial "$Date: Thu Aug 30 10:41:44 2018 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: promogoodssubs.cls $":U .
define variable vss-archive     as character no-undo initial "$Archive: ibs/th/ref/promo/promogoodssubs.cls $":U .
define variable vss-description as character no-undo initial "Коллекция товаров акции.".
  define property IDAction as int64 init ?  no-undo
    get.
    set.
    define property db-num as integer init ?  no-undo
    get.
    set.
    define property idSet as int64 no-undo
    get.
    set.
    define property type as int no-undo
    get.
    set.
  define property promoGoodsObjCurr as class promoGoodsSub
    get:
      return cast (SubjectObjCurr, promoGoodsSub).
    end.
end class.
