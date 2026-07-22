using Progress.Lang.*.
using ibs.th.ref.*.
using ibs.th.gbl.storage.* from propath.
block-level on error undo, throw.
class ibs.th.ref.normwastsub:
method private void getAttrLib ():
   define variable g#attr-lib  as handle no-undo .
   run gbl/getgattrlib.p (output g#attr-lib).
end.
  define property ParGdsOAttr as class ibs.th.ref.pargdsoattr no-undo get. set.
  define property NormalWastageWinter as decimal no-undo init 0 get. set.
  define property NormalWastageSummer as decimal no-undo init 0 get. set.
  define property NormalWastageTransWinter as decimal no-undo init 0 get. set.
  define property NormalWastageTransSummer as decimal no-undo init 0 get. set.
  define property NormalWastageDate as decimal no-undo init 0 get. set.
  define property NormalWastageTransDate as decimal no-undo init 0 get. set.
  define property BeginWinter as date no-undo get. set.
  define property BeginSummer as date no-undo get. set.
  define property IsDecommissioned as logical no-undo get. set.
  define property NormWastS as decimal init 0.0 no-undo
    get.
    set.
  define property NormWastW as decimal init 0.0 no-undo
    get.
    set.
  define property NormWastDays as decimal init 0.0 no-undo
    get.
    private set.
  define property NormalWastageHdnler as class ibs.th.gbl.storage.normwast no-undo
    get.
    private set.
  constructor public normwastsub (  ):
    ParGdsOAttr = new pargdsoattr ().
    NormalWastageHdnler =  new normwast ().
  end constructor.
  method public void FillNormWast ():
    def var objNormWastSub as class normwastsub no-undo.
    objNormWastSub = this-object.
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-o-normal-wastage-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input-output objNormWastSub
      ) .
    NormalWastageHdnler:RegDocPeriod(objNormWastSub:ParGdsOAttr:FromInvDate, objNormWastSub:ParGdsOAttr:ToInvDate, objNormWastSub:ParGdsOAttr:FromInvFQKg).
  end.
  method public void CalcWastNorm ():
    NormWastS = 0.
    NormWastW = 0.
    NormalWastageHdnler:CalcWastNorm (this-object).
    NormWastDays = NormWastS + NormWastW.
  end.
end class.
