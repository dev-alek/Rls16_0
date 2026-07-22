using Progress.Lang.*.
using ibs.th.gbl.sys.objth.
using ibs.th.gbl.env.conf.markingtype.
class ibs.th.gbl.env.prmtrs.edo inherits objth.
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Параметры работы с ЭДО" get.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
  define public property MarkingType as character initial "" no-undo
    get.
    private set.
  define public property MarkingTypeobj as class markingtype no-undo
    get.
    private set.
  define public property MarkingTypeEDOobj as class markingtype no-undo
    get.
    private set.
  define public property MarkingTypeArticObj as class markingtype no-undo
    get.
    private set.
  define public property MarkingTypeTransitionalObj as class markingtype no-undo
    get.
    private set.
  define public property MarkingTypeBlockCashUnMarkObj as class markingtype no-undo
    get.
    private set.
  define public property MarkingTypeSaleReturnObj as class markingtype no-undo
    get.
    private set.
  define public property MarkingTypeSaleUPDObj as class markingtype no-undo
    get.
    private set.
  define public property MarkingTypeOnlySaleObj as class markingtype no-undo
    get.
    private set.
  define public property IsEdo as logical initial false no-undo
    get.
    private set.
  define public property IsEdoNotMark as logical initial false no-undo
    get.
    private set.
  define public property IsManual as logical initial false no-undo
    get.
    private set.
  define public property IsBanRecipes as logical initial false no-undo
    get.
    private set.
  define public property IsBanAltr as logical initial false no-undo
    get.
    private set.
  define public property IsBarCode as logical initial false no-undo
    get.
    private set.
  define public property ObjType as character no-undo
    get.
    private set.
  define public property ObjCode as integer no-undo
    get.
    private set.
  constructor public edo ( pObjType as char, pObjCode as int ):
     assign
      ObjType = pObjType
      ObjCode = pObjCode
    .
  end.
  method override public logical RefrashObject():
     if     ObjType ne ""
        and ObjType ne ?
        and ObjCode ne ?
        and ObjCode ne 0
     then
        RefrashObject(ObjType,ObjCode).
  end method.
  method public logical RefrashObject(pObjType as char, pObjCode as int):
    define variable v-value-character     as character     no-undo .
    define variable v-value-decimal       as decimal       no-undo .
    define variable v-value-integer       as integer       no-undo .
    define variable v-value-logical       as logical       no-undo .
    define variable v-value-type          as character     no-undo .
    define variable v-value-date          as date          no-undo .
    assign
      ObjType = pObjType
      ObjCode = pObjCode
    .
    run adm/shattri.p (
      input "get":U
      ,input pObjType
      ,input pObjCode
      ,input 'marking':U
      ,input "marking-type"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,input-output TABLE thbjattr_thbj-attr
      ) no-error .
    MarkingType = v-value-character.
    if valid-object(MarkingTypeobj)
    then do:
       MarkingTypeobj:reLoadItems(v-value-character).
    end.
    else do:
MarkingTypeobj = new markingtype (MarkingType).
ObjSrv:Regobj(this-object,MarkingTypeobj,
"MarkingTypeobj"
) .
    end.
    run adm/shattri.p (
      input "get":U
      ,input pObjType
      ,input pObjCode
      ,input 'marking':U
      ,input "marking-type-edo"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,input-output TABLE thbjattr_thbj-attr
      ) no-error .
    if valid-object(MarkingTypeEDOobj)
    then do:
       MarkingTypeEDOobj:reLoadItems(v-value-character).
    end.
    else do:
MarkingTypeEDOobj = new markingtype (v-value-character).
ObjSrv:Regobj(this-object,MarkingTypeEDOobj,
"MarkingTypeEDOobj"
) .
    end.
    run adm/shattri.p (
      input "get":U
      ,input pObjType
      ,input pObjCode
      ,input 'marking':U
      ,input "marking-EDO"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,input-output TABLE thbjattr_thbj-attr
      ) no-error .
    if v-value-logical = true
      then IsEDO = true.
      else IsEDO = false.
    run adm/shattri.p (
      input "get":U
      ,input pObjType
      ,input pObjCode
      ,input 'marking':U
      ,input "marking-EDO-NotMark"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,input-output TABLE thbjattr_thbj-attr
      ) no-error .
    if v-value-logical = true
      then IsEdonotMark = true.
      else IsEdonotMark = false.
    run adm/shattri.p (
      input "get":U
      ,input pObjType
      ,input pObjCode
      ,input 'marking':U
      ,input "marking-manual"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,input-output TABLE thbjattr_thbj-attr
      ) no-error .
    if v-value-logical = true
      then IsManual = true.
      else IsManual = false.
    run adm/shattri.p (
      input "get":U
      ,input pObjType
      ,input pObjCode
      ,input 'marking':U
      ,input "ban-recipes"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,input-output TABLE thbjattr_thbj-attr
      ) no-error .
    if v-value-logical = true
      then IsBanRecipes = true.
      else IsBanRecipes = false.
    run adm/shattri.p (
      input "get":U
      ,input pObjType
      ,input pObjCode
      ,input 'marking':U
      ,input "ban-altr"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,input-output TABLE thbjattr_thbj-attr
      ) no-error .
    if v-value-logical = true
      then IsBanAltr = true.
      else IsBanAltr = false.
    run adm/shattri.p (
      input "get":U
      ,input pObjType
      ,input pObjCode
      ,input 'marking':U
      ,input "bar-code"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,input-output TABLE thbjattr_thbj-attr
      ) no-error .
    if v-value-logical = true
      then IsBarCode = true.
      else IsBarCode = false.
    run adm/shattri.p (
      input "get":U
      ,input pObjType
      ,input pObjCode
      ,input 'marking':U
      ,input "marking-type-artic"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,input-output TABLE thbjattr_thbj-attr
      ) no-error .
    if valid-object(MarkingTypeArticObj)
    then do:
       MarkingTypeArticObj:reLoadItems(v-value-character).
    end.
    else do:
MarkingTypeArticObj = new markingtype (v-value-character).
ObjSrv:Regobj(this-object,MarkingTypeArticObj,
"MarkingTypeArticObj"
) .
    end.
    run adm/shattri.p (
      input "get":U
      ,input pObjType
      ,input pObjCode
      ,input 'marking':U
      ,input "marking-type-transitional"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,input-output TABLE thbjattr_thbj-attr
      ) no-error .
    if valid-object(MarkingTypeTransitionalObj)
    then do:
       MarkingTypeTransitionalObj:reLoadItems(v-value-character).
    end.
    else do:
MarkingTypeTransitionalObj = new markingtype (v-value-character).
ObjSrv:Regobj(this-object,MarkingTypeTransitionalObj,
"MarkingTypeTransitionalObj"
) .
    end.
    run adm/shattri.p (
      input "get":U
      ,input pObjType
      ,input pObjCode
      ,input 'marking':U
      ,input "marking-type-blockCashUnMark"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,input-output TABLE thbjattr_thbj-attr
      ) no-error .
    if valid-object(MarkingTypeBlockCashUnMarkObj)
    then do:
       MarkingTypeBlockCashUnMarkObj:reLoadItems(v-value-character).
    end.
    else do:
MarkingTypeBlockCashUnMarkObj = new markingtype (v-value-character).
ObjSrv:Regobj(this-object,MarkingTypeBlockCashUnMarkObj,
"MarkingTypeBlockCashUnMarkObj"
) .
    end.
    run adm/shattri.p (
      input "get":U
      ,input pObjType
      ,input pObjCode
      ,input 'marking':U
      ,input "marking-type-saleReturn"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,input-output TABLE thbjattr_thbj-attr
      ) no-error .
    if valid-object(MarkingTypeSaleReturnObj)
    then do:
       MarkingTypeSaleReturnObj:reLoadItems(v-value-character).
    end.
    else do:
MarkingTypeSaleReturnObj = new markingtype (v-value-character).
ObjSrv:Regobj(this-object,MarkingTypeSaleReturnObj,
"MarkingTypeSaleReturnObj"
) .
    end.
    run adm/shattri.p (
      input "get":U
      ,input pObjType
      ,input pObjCode
      ,input 'marking':U
      ,input "marking-type-saleUPD"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,input-output TABLE thbjattr_thbj-attr
      ) no-error .
    if valid-object(MarkingTypeSaleUPDObj)
    then do:
       MarkingTypeSaleUPDObj:reLoadItems(v-value-character).
    end.
    else do:
MarkingTypeSaleUPDObj = new markingtype (v-value-character).
ObjSrv:Regobj(this-object,MarkingTypeSaleUPDObj,
"MarkingTypeSaleUPDObj"
) .
    end.
    run adm/shattri.p (
      input "get":U
      ,input pObjType
      ,input pObjCode
      ,input 'marking':U
      ,input "marking-type-onlySale"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,input-output TABLE thbjattr_thbj-attr
      ) no-error .
    if valid-object(MarkingTypeOnlySaleObj)
    then do:
       MarkingTypeOnlySaleObj:reLoadItems(v-value-character).
    end.
    else do:
MarkingTypeOnlySaleObj = new markingtype (v-value-character).
ObjSrv:Regobj(this-object,MarkingTypeOnlySaleObj,
"MarkingTypeOnlySaleObj"
) .
    end.
  end method.
  method public logical GetIsMarkingForType(pType as char):
    return MarkingTypeobj:GetValForType(pType).
  end method.
  method public logical GetIsEDOForType(pType as char):
    return MarkingTypeEDOobj:GetValForType(pType).
  end method.
  method public logical GetIsArticForType(pType as char):
    return MarkingTypeArticObj:GetValForType(pType).
  end method.
  method public logical GetIsTransitionalForType(pType as char):
    return MarkingTypeTransitionalObj:GetValForType(pType).
  end method.
  method public logical GetIsBlockCashUnMarkForType(pType as char):
    return MarkingTypeBlockCashUnMarkObj:GetValForType(pType).
  end method.
  method public logical GetIsSaleReturnForType(pType as char):
    return MarkingTypeSaleReturnObj:GetValForType(pType).
  end method.
  method public logical GetIsSaleUPDForType(pType as char):
    return MarkingTypeSaleUPDObj:GetValForType(pType).
  end method.
  method public logical GetIsOnlySaleForType(pType as char):
    return MarkingTypeOnlySaleObj:GetValForType(pType).
  end method.
end class.
