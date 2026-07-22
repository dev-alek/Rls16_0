using Progress.Lang.*.
using ibs.th.gbl.collection.*.
using ibs.th.str.mercury.*.
block-level on error undo, throw.
class ibs.th.str.mercury.gdsmercsubs inherits asubjects:
  define property GdsMercsubsCurr as class gdsmercsub no-undo
    get:
      return cast (SubjectObjCurr, gdsmercsub).
    end.
end class.
