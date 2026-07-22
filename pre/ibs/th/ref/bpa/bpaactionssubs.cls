using Progress.Lang.*.
using ibs.th.gbl.collection.*.
USING ibs.th.ref.bpa.*.
block-level on error undo, throw.
class ibs.th.ref.bpa.BpaActionsSubs inherits asubjects:
define variable vss-revision    as character no-undo initial "$Revision: c16e05d4b612, 2089, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Wed Dec 25 15:23:51 2019 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: BpaActionsSubs.cls $":U .
define variable vss-archive     as character no-undo initial "$Archive: ibs/th/ref/bpa/BpaActionsSubs.cls $":U .
define variable vss-description as character no-undo initial "Объект платежных агентов/операторов.".
define property bpaActionObjCurr as class bpaActionSub
get:
  return cast (SubjectObjCurr, bpaActionSub) .
end.
end class.
