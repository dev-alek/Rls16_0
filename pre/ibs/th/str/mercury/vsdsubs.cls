using Progress.Lang.*.
using ibs.th.gbl.collection.*.
using ibs.th.str.mercury.*.
block-level on error undo, throw.
class ibs.th.str.mercury.vsdsubs inherits asubjects:
  define property VsdObjCurr as class vsdsub no-undo
    get:
      return cast (SubjectObjCurr, vsdsub).
    end.
end class.
