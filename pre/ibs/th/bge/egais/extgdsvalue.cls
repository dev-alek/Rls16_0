using Progress.Lang.*.
using ibs.th.bge.egais.*.
block-level on error undo, throw.
class ibs.th.bge.egais.ExtGdsValue:
  define property CliRegIdProd as character no-undo
    get.
    set.
  define property CliEgaisTypeProd as character no-undo
    get.
    set.
  define property INNProd as character no-undo
    get.
    set.
  define property KPPProd as character no-undo
    get.
    set.
  define property FullNameProd as character no-undo
    get.
    set.
  define property CountryProd as character no-undo
    get.
    set.
  define property RegionProd as character no-undo
    get.
    set.
  define property DescrProd as character no-undo
    get.
    set.
  define property CliRegIdImpor as character no-undo
    get.
    set.
  define property CliEgaisTypeImpor as character no-undo
    get.
    set.
  define property INNImpor as character no-undo
    get.
    set.
  define property KPPImpor as character no-undo
    get.
    set.
  define property FullNameImpor as character no-undo
    get.
    set.
  define property CountryImpor as character no-undo
    get.
    set.
  define property RegionImpor as character no-undo
    get.
    set.
  define property DescrImpor as character no-undo
    get.
    set.
  define property FullNameGds as character no-undo
    get.
    set.
  define property Capacity as decimal no-undo
    get.
    set.
  define property GdsCode as integer no-undo init 0
    get.
    set.
  define property AlcCode as character no-undo
    get.
    set.
  define property extFormF1Obj as class ExtFormF1 no-undo
    get.
    private set.
  constructor public extgdsvalue ( ):
    extFormF1Obj = new ExtFormF1 (true).
  end constructor.
  destructor public extgdsvalue ( ):
    if valid-object (extFormF1Obj)
      then delete object extFormF1Obj.
  end destructor.
end class.
