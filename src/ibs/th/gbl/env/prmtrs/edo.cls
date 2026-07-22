/*
  $Revision:$
  $Author:$
  $Date:$
  $Workfile:$
  $Archive:$
  
  Автор: Рубан Дмитрий Андреевич 
  Дата создания: 9 янв. 2023 г.
  Author:  Ruban Dmitriy Andreevich
  Creation date: 9 янв. 2023 г.
  
  */

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
  

{ cmp/str-glbl.i class}
{ gbl/thbj-def.i }

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

/*  define public property IsMarking as logical initial false no-undo*/
/*    get:                                                           */
/*       return MarkingTypeobj:IsMarking.                            */
/*    end.                                                           */
/*                                                                   */
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
      ,input {&attr-marking}
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
      {utl\objreg.i MarkingTypeobj markingtype MarkingType}
    end.
    
    run adm/shattri.p (
      input "get":U
      ,input pObjType
      ,input pObjCode
      ,input {&attr-marking}
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
       {utl\objreg.i MarkingTypeEDOobj markingtype v-value-character}
    end.
        
    run adm/shattri.p (
      input "get":U
      ,input pObjType
      ,input pObjCode
      ,input {&attr-marking}
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
      ,input {&attr-marking}
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
      ,input {&attr-marking}
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
      ,input {&attr-marking}
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
      ,input {&attr-marking}
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
      ,input {&attr-marking}
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
      ,input {&attr-marking}
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
       {utl\objreg.i MarkingTypeArticObj markingtype v-value-character}
    end.    
    
    run adm/shattri.p (
      input "get":U
      ,input pObjType
      ,input pObjCode
      ,input {&attr-marking}
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
       {utl\objreg.i MarkingTypeTransitionalObj markingtype v-value-character}
    end.
    
    run adm/shattri.p (
      input "get":U
      ,input pObjType
      ,input pObjCode
      ,input {&attr-marking}
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
       {utl\objreg.i MarkingTypeBlockCashUnMarkObj markingtype v-value-character}
    end.
    
    run adm/shattri.p (
      input "get":U
      ,input pObjType
      ,input pObjCode
      ,input {&attr-marking}
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
       {utl\objreg.i MarkingTypeSaleReturnObj markingtype v-value-character}
    end.
    
    run adm/shattri.p (
      input "get":U
      ,input pObjType
      ,input pObjCode
      ,input {&attr-marking}
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
       {utl\objreg.i MarkingTypeSaleUPDObj markingtype v-value-character}
    end.
    
    run adm/shattri.p (
      input "get":U
      ,input pObjType
      ,input pObjCode
      ,input {&attr-marking}
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
       {utl\objreg.i MarkingTypeOnlySaleObj markingtype v-value-character}  
    end.                  
  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

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