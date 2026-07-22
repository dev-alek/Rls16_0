 
 /*------------------------------------------------------------------------
    File        : promoObject
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : druban
    Created     : Mon Jul 09 15:04:12 MSK 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.ref.promo.*.

block-level on error undo, throw.

class ibs.th.gbl.storage.promoObjectStorage: 
  define variable vss-revision    as character no-undo initial "$Revision: 2131ac572a79, 4114, test $":U .
  define variable vss-author      as character no-undo initial "$Author: VSpiridonov $":U .
  define variable vss-date        as character no-undo initial "$Date: 2025/02/28 14:26:23 $":U .
  define variable vss-workfile    as character no-undo initial "$Workfile: promoObjectStorage.cls $":U .
  define variable vss-archive     as character no-undo initial "$Archive: ibs/th/gbl/storage/promoObjectStorage.cls $":U . 
  define variable vss-description as character no-undo initial "Storage Object Action". 

{ cmp/str-glbl.i class }
  
  define property Msg as character
    get.
    private set.
  
  
  
  /*------------------------------------------------------------------------------
   Purpose:
   Notes: 
  ------------------------------------------------------------------------------*/

  method private void exception( arg as handle, inpromoObjectObj as class promoObjectsub, t-h as handle ):
    
    inpromoObjectObj:setMsg(arg:get-message (1)).
    inpromoObjectObj:setStatusErr(arg:error).
    t-h:buffer-delete () no-error.
    return.

  end method.

  method private void exception( arg as char ):
    
    Msg = arg.
    return.

  end method.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  method public void updateDBAll( input promoObjectsubsObj as promoObjectsubs ):
      updateDBAll (PromoObjectsubsObj,?,?). 
  end.     
  method public void updateDBAll( input PromoObjectsubsObj as PromoObjectsubs ,input pIdParent as int64,input pdb-num as integer  ):
      define variable vi as int no-undo.
      define variable vSub as Class PromoObjectsub no-undo.
      do vi =  1 to PromoObjectsubsObj:GetItem(vi):
         vSub = PromoObjectsubsObj:PromoObjectObjCurr.
         if pIdParent ne ?
         then 
            vSub:idAction = pIdParent.
         
         if pdb-num ne ?
         then 
            vSub:db-num = pdb-num.
          if      vSub:Mode eq {&h-create}
         then
            insertDB(vSub).
         else if vSub:Mode eq {&h-update}
         then     
            updateDB(vSub).
         else if vSub:Mode eq {&h-delete}
         then     
            deleteDB(vSub). 
            
      end.    
  end.
  
  method public void insertDB( input PromoObjectsubObj as PromoObjectsub  ):
    define buffer buf_promoObject for ub.promoObject.  
    define variable vId as integer no-undo.
    if PromoObjectsubObj:db-num eq ? then
       undo, throw new Progress.Lang.AppError(
         substitute("отсутствует db-num в классе объектов &1 &2", PromoObjectsubObj:obj-type,PromoObjectsubObj:obj-code)
       ) .
    create buf_PromoObject.
    assign
      VId                       = next-value (s-PromoObject-id, ub)
      buf_PromoObject.id        = vId
      buf_PromoObject.db-num    = PromoObjectsubObj:db-num
    no-error.
    if error-status:error 
    then do:
      exception(error-status, PromoObjectsubObj, buffer buf_PromoObject:handle).
      return.
    end.
    
    setDataStorage(input PromoObjectsubObj, buffer buf_PromoObject).
    
    return.
  end method.
  
  method public void updateDB( input PromoObjectsubObj as PromoObjectsub  ):
    define buffer buf_promoObject for ub.promoObject.
    find first buf_PromoObject where
          buf_PromoObject.id     = PromoObjectsubObj:ID 
    no-error.

    if not available (buf_PromoObject)
    then do:
      exception(error-status, PromoObjectsubObj, buffer buf_PromoObject:handle).
      return.
    end.
    setDataStorage(input PromoObjectsubObj, buffer buf_PromoObject).
    return.
    
  end method.
  
  method public void deleteDB( input PromoObjectsubObj as PromoObjectsub  ):
    define buffer buf_promoObject for ub.promoObject. 
    find first buf_PromoObject where
      buf_PromoObject.id     = PromoObjectsubObj:ID
      no-error.

    if not available (buf_PromoObject)
    then do:
      exception(error-status, PromoObjectsubObj, buffer buf_PromoObject:handle).
      return.
    end.
    
    delete buf_PromoObject.
    return.

  end method.
  
  method public class PromoObjectsubs getPromoObjectsubs (input pId as int64,input idb-num as int ):
    define buffer buf_promoObject for ub.promoObject.
    define variable PromoObjectsubsObj as class PromoObjectsubs.
    PromoObjectsubsObj = new PromoObjectsubs ().
   
    for each buf_PromoObject  where buf_PromoObject.idAction = pId
                                   and buf_PromoObject.db-num = idb-num
    no-lock: 
        PromoObjectsubsObj:AddItem(getDataStorage (buffer buf_PromoObject)).
    end.      
    return PromoObjectsubsObj.
  end method.
  
    
  method private void setDataStorage (input inPromoObjectObj as class PromoObjectsub, buffer inbf_PromoObject for ub.PromoObject ):
    
    assign
        inbf_PromoObject.obj-type        = inPromoObjectObj:obj-type
        inbf_PromoObject.obj-code        = inPromoObjectObj:obj-code
        inbf_PromoObject.end-date        = inPromoObjectObj:end-date
        inbf_PromoObject.idAction        = inPromoObjectObj:idAction
      //  inbf_PromoObject.db-num          = inPromoObjectObj:db-num 
        
    .
    release inbf_PromoObject.
    end.
  
  method private class PromoObjectsub getDataStorage ( buffer inbf_PromoObject for ub.PromoObject ):
    
    define variable PromoObjectsubObj  as class PromoObjectsub.
    PromoObjectsubObj = new PromoObjectsub ().
    return getDataStorage(PromoObjectsubObj,buffer inbf_PromoObject ).
  end.
  
  method private class PromoObjectsub getDataStorage (inPromoObjectSubObj as class PromoObjectsub, buffer inbf_PromoObject for ub.PromoObject ):
    assign 
      inPromoObjectSubObj:ID            = inbf_PromoObject.id
      inPromoObjectSubObj:obj-type      = inbf_PromoObject.obj-type
      inPromoObjectSubObj:obj-code      = inbf_PromoObject.obj-code
      inPromoObjectSubObj:end-date      = inbf_PromoObject.end-date             
      inPromoObjectSubObj:idAction      = inbf_PromoObject.idAction     
      inPromoObjectSubObj:db-num        = inbf_PromoObject.db-num        
    .  
       
    return inPromoObjectSubObj.
    
  end.
  
  method public void refreshObj (inPromoObjectSubObj as class PromoObjectsub):
    define buffer buf_promoObject for ub.promoObject.
    if not valid-object (inPromoObjectSubObj)
    then do:
      Msg = "Объект типа PromoObjectsub не существует".
      return.
    end.
    
    find first buf_PromoObject no-lock where buf_PromoObject.ID = inPromoObjectSubObj:ID no-error.
    if not available (buf_PromoObject)
    then do:
      Msg = "Не найден Критерий - " + string (inPromoObjectSubObj:ID) .
      return.
    end.
    getDataStorage (inPromoObjectSubObj, buffer buf_PromoObject).
    
  end.

end class.