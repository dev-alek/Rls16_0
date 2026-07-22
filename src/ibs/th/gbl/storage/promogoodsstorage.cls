/*

$Revision: e455fc319afd, 3602, rls $
$Author: ARostovtsev $
$Date: 2023/12/28 12:56:37 $
$Workfile: promogoodsstorage.cls $
$Archive: ibs/th/gbl/storage/promogoodsstorage.cls $
 
Storage Goods Action

Автор: Рубан Дмитрий Андреевич
Дата создания: 11/07/18
Author: Ruban Dmitriy
Creation date: 11/07/18

*/
 

using Progress.Lang.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
using ibs.th.ref.promo.*.
block-level on error undo, throw.
class ibs.th.gbl.storage.promogoodsstorage: 
  define variable vss-revision    as character no-undo initial "$Revision: e455fc319afd, 3602, rls $":U .
  define variable vss-author      as character no-undo initial "$Author: ARostovtsev $":U .
  define variable vss-date        as character no-undo initial "$Date: 2023/12/28 12:56:37 $":U .
  define variable vss-workfile    as character no-undo initial "$Workfile: promogoodsstorage.cls $":U .
  define variable vss-archive     as character no-undo initial "$Archive: ibs/th/gbl/storage/promogoodsstorage.cls $":U . 
  define variable vss-description as character no-undo initial "Storage Goods Action". 
  
  { cmp/str-glbl.i class }
  
  define property Msg as character
    get.
    private set.
  
  
  
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method private void exception( arg as handle, inPromoGoodsObj as class promoGoodssub, t-h as handle ):
     
    inpromoGoodsObj:setMsg(arg:get-message (1)).
    inpromoGoodsObj:setStatusErr(arg:error).
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
  method public void updateDBAll( input promoGoodssubsObj as promoGoodssubs ):
    updateDBAll (promoGoodssubsObj,?,?,?).
  end.
  method public void updateDBAll( input promoGoodssubsObj as promoGoodssubs ,input iIdAction as int64, input idb-num as integer  ):
    updateDBAll (promoGoodssubsObj,iIdAction,?,idb-num).
  end.     
  method public void updateDBAll( input promoGoodssubsObj as promoGoodssubs ,input iIdAction as int64,input iIdSet as int64, input idb-num as integer  ):
    define variable v-sub as promoGoodssub no-undo .
    define variable vi    as int           no-undo.
    do vi =  1 to promoGoodssubsObj:GetItem(vi):
      v-sub = promoGoodssubsObj:promoGoodsObjCurr .
      assign
        v-sub:idAction = promoGoodssubsObj:IdAction 
        when promoGoodssubsObj:IdAction > 0
        v-sub:idSet    = promoGoodssubsObj:IdSet    
        when promoGoodssubsObj:IdSet    > 0
        v-sub:db-num   = promoGoodssubsObj:db-num   
        when promoGoodssubsObj:db-num   ne ?
        v-sub:type     = promoGoodssubsObj:type     
        when promoGoodssubsObj:type     > 0
        v-sub:idAction = iIdAction                  
        when iIdAction > 0
        v-sub:idSet    = iIdSet                     
        when iIdSet    > 0
        v-sub:db-num   = idb-num                    
        when idb-num   ne ?
        .
      case v-sub:Mode :
        when {&h-create} then
          insertDB(v-sub).
        when {&h-update} then     
          updateDB(v-sub).
        when {&h-delete} then     
          deleteDB(v-sub).
        otherwise .
      end case .
      if valid-object(v-sub:promoSetGoods)
        then    
        updateDBAll(v-sub:promoSetGoods,iIdAction,v-sub:ID,idb-num).   
    end.    
  end.
  
  method public void insertDB( input promoGoodssubObj as promoGoodssub  ):
    define buffer buf_promogoods for ub.promogoods.
    define buffer buf_promoAttr  for ub.PromoAttr .
 
    if promoGoodssubObj:db-num eq ? then
      undo, throw new Progress.Lang.AppError(
        substitute("отсутствует db-num в классе с кодом товара &1", promoGoodssubObj:GdsCode)
        ) .
    create buf_promoGoods.
    assign
      buf_promoGoods.id     = next-value (s-promoGoods-id, ub)
      buf_promoGoods.db-num = promoGoodssubObj:db-num
      promoGoodssubObj:ID   = buf_promoGoods.id   
    no-error.
    if error-status:error
      then 
    do:
      exception(error-status, promoGoodssubObj, buffer buf_promoGoods:handle).
      return.
    end.
    
    setDataStorage(input promoGoodssubObj, buffer buf_promoGoods).
    for each buf_promoAttr exclusive-lock where buf_promoAttr.attr-code = "bc-code" and
      buf_promoAttr.tablename = "PromoGoods" and
      promoGoodssubObj:idAction = int64(entry(1,buf_PromoAttr.p-key,{&delim-key})) and 
      promoGoodssubObj:db-num = integer(entry(2,buf_PromoAttr.p-key,{&delim-key})) and
      promoGoodssubObj:GdsCode = integer(entry(3,buf_PromoAttr.p-key,{&delim-key})):
      delete buf_promoAttr .
    end. 
        if promoGoodssubObj:promotion-code <> ? then 
    dO:
      create buf_promoAttr .
      assign
        buf_promoAttr.tablename = "PromoGoods"
        buf_promoAttr.attr-code = "bc-code"
        buf_promoAttr.p-key     = string(promoGoodssubObj:idAction) + {&delim-key} + 
                          string(promoGoodssubObj:db-num) + {&delim-key} +
                          string(promoGoodssubObj:GdsCode)
        .
      buf_promoAttr.attr-value = promoGoodssubObj:promotion-code .
    end.
    return.

  end method.
  
  method public void updateDB( input promoGoodssubObj as promoGoodssub  ):
    define buffer buf_promogoods for ub.promogoods.
    define buffer buf_promoAttr  for ub.PromoAttr .
    
    find first buf_promoGoods where
      buf_promoGoods.id     = promoGoodssubObj:ID 
      no-error.

    if not available (buf_promoGoods)
      then 
    do:
      exception(error-status, promoGoodssubObj, buffer buf_promoGoods:handle).
      return.
    end.
    setDataStorage(input promoGoodssubObj, buffer buf_promoGoods).
    
    for each buf_promoAttr exclusive-lock where buf_promoAttr.attr-code = "bc-code" and
      buf_promoAttr.tablename = "PromoGoods" and
      promoGoodssubObj:idAction = int64(entry(1,buf_PromoAttr.p-key,{&delim-key})) and 
      promoGoodssubObj:db-num = integer(entry(2,buf_PromoAttr.p-key,{&delim-key})) and
      promoGoodssubObj:GdsCode = integer(entry(3,buf_PromoAttr.p-key,{&delim-key})):
      delete buf_promoAttr .
    end. 
    if promoGoodssubObj:promotion-code <> ? then 
    do:
      create buf_promoAttr .
      assign
        buf_promoAttr.tablename = "PromoGoods"
        buf_promoAttr.attr-code = "bc-code"
        buf_promoAttr.p-key     = string(promoGoodssubObj:idAction) + {&delim-key} + 
                          string(promoGoodssubObj:db-num) + {&delim-key} +
                          string(promoGoodssubObj:GdsCode)
        .
      buf_promoAttr.attr-value = promoGoodssubObj:promotion-code .
    end.
    return.

  end method.
  
  method public void deleteDB( input promoGoodssubObj as promoGoodssub  ):
    define buffer buf_promogoods for ub.promogoods.
    define buffer buf_promoAttr  for ub.PromoAttr . 
    find first buf_promoGoods where
      buf_promoGoods.id     = promoGoodssubObj:ID
      no-error.

    if not available (buf_promoGoods)
      then 
    do:
      exception(error-status, promoGoodssubObj, buffer buf_promoGoods:handle).
      return.
    end.
    
    delete buf_promoGoods.
    for first buf_promoAttr exclusive-lock where buf_promoAttr.attr-code = "bc-code" and
      buf_promoAttr.tablename = "PromoGoods" and
      promoGoodssubObj:idAction = int64(entry(1,buf_PromoAttr.p-key,{&delim-key})) and 
      promoGoodssubObj:db-num = integer(entry(2,buf_PromoAttr.p-key,{&delim-key})) and
      promoGoodssubObj:GdsCode = integer(entry(3,buf_PromoAttr.p-key,{&delim-key})):
      delete buf_promoAttr .
    end.    
    return.

  end method.

  method public class promoGoodssubs getpromoGoodssubs (input idaction as int64,
    input iTYPE as ibs.th.ref.promo.enum-promo-goods-type,
    input idb-num as integer ):

    return getpromoGoodssubs(idaction, iTYPE, idb-num, ?).
  end method.
  
  method public class promoGoodssubs getpromoGoodssubs (input idaction as int64,
    input iTYPE as ibs.th.ref.promo.enum-promo-goods-type,
    input idb-num as integer,
    input iobj-code as integer ):
    define buffer buf_promogoods for ub.promogoods.                                                        
    define variable promoGoodssubsObj as class   promoGoodssubs.
    define variable vType             as integer no-undo.
    vType = iTYPE:getvalue().
    promoGoodssubsObj = new promoGoodssubs ().
    assign
      promoGoodssubsObj:idaction = idaction
      promoGoodssubsObj:type     = vtype
      promoGoodssubsObj:db-num   = idb-num
      .
    if idaction > 0
      then
      for each buf_promoGoods   where buf_promoGoods.idaction eq idaction
        and buf_promoGoods.idSet    eq 0
        and buf_promoGoods.type     eq vType
        and buf_promoGoods.db-num   eq idb-num
        no-lock:
    
        promoGoodssubsObj:AddItem(getDataStorage (buffer buf_promoGoods, iobj-code)).
    
      end.      
    
    return promoGoodssubsObj.
  end method.
  
  method public class promoGoodssubs getpromoGoodssubs (input idaction as int64,
    input iIdSet    as int64,
    input iTYPE    as ibs.th.ref.promo.enum-promo-goods-type,
    input idb-num  as integer,
    input iobj-code as integer ):
    define buffer buf_promogoods for ub.promogoods.                                                        
    define variable promoGoodssubsObj as class   promoGoodssubs.
    define variable vType             as integer no-undo.
    vType = iTYPE:getvalue().
    
    promoGoodssubsObj = new promoGoodssubs ().
    assign
      promoGoodssubsObj:idaction = idaction
      promoGoodssubsObj:type     = vtype
      promoGoodssubsObj:db-num   = idb-num
      promoGoodssubsObj:IdSet    = iIdSet
      . 
    if     idaction > 0
      and iIdSet   > 0
      then
      for each buf_promoGoods   where buf_promoGoods.idaction eq idaction
        and buf_promoGoods.idSet     eq iIdSet
        and buf_promoGoods.type     eq vtype
        and buf_promoGoods.db-num  eq idb-num
        no-lock:
        promoGoodssubsObj:AddItem(getDataStorage (buffer buf_promoGoods, iobj-code)).
      end.      
    return promoGoodssubsObj.
  end method.
    
  method private void setDataStorage (input inpromoGoodsObj as class promoGoodssub, buffer inbf_promoGoods for ub.promoGoods ):
    assign
      inbf_promoGoods.type     = inpromoGoodsObj:type
      inbf_promoGoods.idAction = inpromoGoodsObj:idAction
      inbf_promoGoods.Gds-Code = inpromoGoodsObj:GdsCode
      inbf_promoGoods.db-num   = inpromoGoodsObj:db-num
      inbf_promoGoods.idSet    = inpromoGoodsObj:idSet
      inbf_promoGoods.price    = inpromoGoodsObj:price
      inbf_promoGoods.qnty     = inpromoGoodsObj:qnty
      inbf_promoGoods.NameSet  = inpromoGoodsObj:NameSet
      .
    validate inbf_promoGoods.
  end.
  
  method private class promoGoodssub getDataStorage ( buffer inbf_promoGoods for ub.promoGoods):
    
    return getDataStorage(buffer inbf_promoGoods, ?).
  end.


  method private class promoGoodssub getDataStorage ( buffer inbf_promoGoods for ub.promoGoods, objCode as integer ):
    
    define variable promoGoodssubObj as class promoGoodssub.
    promoGoodssubObj = new promoGoodssub ().
    return getDataStorage(promoGoodssubObj,buffer inbf_promoGoods, objCode).
  end.

  method private class promoGoodssub getDataStorage (inpromoGoodsSubObj as class promoGoodssub, buffer inbf_promoGoods for ub.promoGoods):  

    return getDataStorage (inpromoGoodsSubObj, buffer inbf_promoGoods, ?).
  end.
  
  method private class promoGoodssub getDataStorage (inpromoGoodsSubObj as class promoGoodssub, buffer inbf_promoGoods for ub.promoGoods, objCode as integer ):  
    assign
      inpromoGoodsSubObj:ID       = inbf_promoGoods.id
      inpromoGoodsSubObj:type     = inbf_promoGoods.type
      inpromoGoodsSubObj:idAction = inbf_promoGoods.idAction             
      inpromoGoodsSubObj:GdsCode  = inbf_promoGoods.Gds-Code
      inpromoGoodsSubObj:db-num   = inbf_promoGoods.db-num         
      inpromoGoodsSubObj:idSet    = inbf_promoGoods.idSet          
      inpromoGoodsSubObj:price    = inbf_promoGoods.price          
      inpromoGoodsSubObj:qnty     = inbf_promoGoods.qnty           
      inpromoGoodsSubObj:NameSet  = inbf_promoGoods.NameSet            
      inpromoGoodsSubObj:objCode  = objCode         
      .  
       
    return inpromoGoodsSubObj.
    
  end.
  
  method public void refreshObj (inpromoGoodsSubObj as class promoGoodssub):
    define buffer buf_promoGoods for ub.promoGoods.
    if not valid-object (inpromoGoodsSubObj)
      then 
    do:
      Msg = "Объект типа promoGoodssub не существует".
      return.
    end.
    
    find first buf_promoGoods no-lock where buf_promoGoods.ID = inpromoGoodsSubObj:ID no-error.
    if not available (buf_promoGoods)
      then 
    do:
      Msg = "Не найден Товар - " + string (inpromoGoodsSubObj:ID).
      return.
    end.
    getDataStorage (inpromoGoodsSubObj,buffer buf_promoGoods).
  end.

end class.
