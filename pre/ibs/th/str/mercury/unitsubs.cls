using Progress.Lang.*.
using ibs.th.gbl.collection.*.
using ibs.th.str.mercury.*.
block-level on error undo, throw.
class ibs.th.str.mercury.unitsubs inherits asubjects:
  define property UnitObjCurr as class unitsub no-undo
    get:
      return cast (SubjectObjCurr, unitsub).
    end.
end class.
