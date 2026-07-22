using Progress.Lang.*.
using ibs.th.gbl.collection.asubjects.
using ibs.th.str.ptrl.*.
using ibs.th.gbl.storage.*.
block-level on error undo, throw.
class ibs.th.str.ptrl.rvsinvsubs inherits asubjects:
  define property RvsInvSubCurr as class rvsinvsub
    get:
      return cast (SubjectObjCurr, rvsinvsub).
    end.
  define property RvsCode as character no-undo
    get.
    set.
  define property IsRvsInvAlg3 as logical no-undo
    get.
    set.
  define property ObjType as character no-undo
    get.
    set.
  define property ObjCode as integer no-undo
    get.
    set.
  define property MeteringErrWastSum as decimal no-undo
    get.
    set.
  define property NaturWastageSum as decimal no-undo
    get.
    set.
  define property TPWastSum as decimal no-undo
    get.
    set.
  define property DiffSum as decimal no-undo
    get.
    set.
  define property DeficitOverSum as decimal no-undo
    get:
      return (absolut (DiffSum) - TPWastSum - NaturWastageSum - MeteringErrWastSum).
    end.
  define property RvsInvStrObj as class rvsinvstr no-undo
    get:
      if not valid-object ( RvsInvStrObj )
        then return new rvsinvstr ().
        else return RvsInvStrObj.
    end.
    set.
  method public void CalcSum ():
    RvsInvStrObj:CalcSum(this-object).
  end method.
end class.
