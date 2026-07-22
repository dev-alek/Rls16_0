using Progress.Lang.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
using ibs.th.ref.promo.*.
block-level on error undo, throw.
class ibs.th.gbl.storage.promoGiftstorage:
  define variable vss-revision    as character no-undo initial "$Revision: e455fc319afd, 3602, rls $":U .
  define variable vss-author      as character no-undo initial "$Author: ARostovtsev $":U .
  define variable vss-date        as character no-undo initial "$Date: 2023/12/28 12:56:37 $":U .
  define variable vss-workfile    as character no-undo initial "$Workfile: promogiftstorage.cls $":U .
  define variable vss-archive     as character no-undo initial "$Archive: ibs/th/gbl/storage/promogiftstorage.cls $":U .
  define variable vss-description as character no-undo initial "Storage Gift Action".
  define property Msg as character
    get.
    private set.
  method private void exception( arg as handle, inPromoGiftObj as class promoGiftsub, t-h as handle ):
    inpromoGiftObj:setMsg(arg:get-message (1)).
    inpromoGiftObj:setStatusErr(arg:error).
    t-h:buffer-delete () no-error.
    return.
  end method.
  method private void exception( arg as char ):
    Msg = arg.
    return.
  end method.
  method public void updateDBAll( input promoGiftsubsObj as promoGiftsubs  ):
      updateDBAll (promoGiftsubsObj,?,?,?).
  end.
  method public void updateDBAll( input promoGiftsubsObj as promoGiftsubs ,input pIdAction as int64):
    updateDBAll (promoGiftsubsObj,pIdAction,?,?).
  end.
  method public void updateDBAll( input promoGiftsubsObj as promoGiftsubs ,input pIdAction as int64, input pIdCrit as int64,input pdb-num as integer  ):
      define variable vi as int no-undo.
      do vi =  1 to promoGiftsubsObj:GetItem(vi):
         if pIdAction ne ?
         then
            promoGiftsubsObj:promoGiftObjCurr:idAction = pIdAction.
         if pIdCrit ne ?
         then
            promoGiftsubsObj:promoGiftObjCurr:idCrit = pIdCrit.
         if pdb-num ne ?
         then
            promoGiftsubsObj:promoGiftObjCurr:db-num = pdb-num.
         if      promoGiftsubsObj:promoGiftObjCurr:Mode eq 'с':U
         then
            insertDB(promoGiftsubsObj:promoGiftObjCurr).
         else if promoGiftsubsObj:promoGiftObjCurr:Mode eq 'и':U
         then
            updateDB(promoGiftsubsObj:promoGiftObjCurr).
         else if promoGiftsubsObj:promoGiftObjCurr:Mode eq 'у':U
         then
            deleteDB(promoGiftsubsObj:promoGiftObjCurr).
      end.
  end.
  method public void insertDB( input promoGiftsubObj as promoGiftsub  ):
    define buffer buf_promoCriterion for ub.promoCriterion.
      if promoGiftsubObj:db-num eq ? then
       undo, throw new Progress.Lang.AppError(
         substitute("отсутствует db-num в классе подарков/сообщений с кодом товара &1&2", string(promoGiftsubObj:GdsCode),promoGiftsubObj:mess)
       ) .
    define buffer buf_promoGift for ub.promoGift.
    create buf_promoGift.
    assign
      buf_promoGift.id     = next-value (s-promoGift-id, ub)
      buf_promoGift.db-num = promoGiftsubObj:db-num
    no-error.
    if error-status:error
    then do:
      exception(error-status, promoGiftsubObj, buffer buf_promoGift:handle).
      return.
    end.
    setDataStorage(input promoGiftsubObj, buffer buf_promoGift).
  end method.
  method public void updateDB( input promoGiftsubObj as promoGiftsub  ):
    define buffer buf_promoGift for ub.promoGift.
    find first buf_promoGift where
          buf_promoGift.id     = promoGiftsubObj:ID
    no-error.
    if not available (buf_promoGift)
    then do:
      exception(error-status, promoGiftsubObj, buffer buf_promoGift:handle).
      return.
    end.
    setDataStorage(input promoGiftsubObj, buffer buf_promoGift).
    return.
  end method.
  method public void deleteDB( input promoGiftsubObj as promoGiftsub  ):
    define buffer buf_promoGift for ub.promoGift.
    find first buf_promoGift where
      buf_promoGift.id     = promoGiftsubObj:ID
      no-error.
    if not available (buf_promoGift)
    then do:
      exception(error-status, promoGiftsubObj, buffer buf_promoGift:handle).
      return.
    end.
    delete buf_promoGift.
    return.
  end method.
  method public class promoGiftsubs getpromoGiftsubs (input idaction as int64,input idcrit as int64,input idb-num as integer ):
    return getpromoGiftsubs (idaction, idcrit, idb-num, ?).
  end method.
  method public class promoGiftsubs getpromoGiftsubs (input idaction as int64,input idcrit as int64,input idb-num as integer, input iobj-code as integer ):
    define variable promoGiftsubsObj as class promoGiftsubs.
    define buffer buf_promoGift for ub.promoGift.
    promoGiftsubsObj = new promoGiftsubs ().
    for each buf_promoGift   where buf_promoGift.idaction eq idaction
                                and buf_promoGift.idcrit  eq idcrit
                                and buf_promoGift.db-num  eq idb-num
    no-lock:
        promoGiftsubsObj:AddItem(getDataStorage (buffer buf_promoGift, iobj-code)).
    end.
    return promoGiftsubsObj.
  end method.
  method private void setDataStorage (input inpromoGiftObj as class promoGiftsub, buffer inbf_promoGift for ub.PromoGift):
    assign
        inbf_promoGift.idCrit        = inpromoGiftObj:idCrit
        inbf_promoGift.idAction      = inpromoGiftObj:idAction
        inbf_promoGift.Gds-Code      = inpromoGiftObj:GdsCode
        inbf_promoGift.qnty          = inpromoGiftObj:qnty
        inbf_promoGift.mess          = inpromoGiftObj:mess
       // inbf_promoGift.db-num        = inpromoGiftObj:db-num
        .
      for first ub.PromoAction no-lock where ub.PromoAction.id = inpromoGiftObj:idaction:
      find first ub.PromoAttr exclusive-lock where ub.PromoAttr.attr-code = "mess-gks" and
      ub.PromoAttr.p-key = string(ub.PromoAction.id) + chr(3) + string(ub.PromoAction.db-num) and
      ub.PromoAttr.tablename = "PromoGift" no-error .
      if not available (ub.PromoAttr) then do:
          create ub.PromoAttr .
          assign
          ub.PromoAttr.attr-code = "mess-gks"
          ub.PromoAttr.p-key = string(ub.PromoAction.id) + chr(3) + string(ub.PromoAction.db-num)
          ub.PromoAttr.tablename = "PromoGift"
          .
      end.
      ub.PromoAttr.attr-value = inpromoGiftObj:mess-gks .
      end.
      validate inbf_promoGift.
    end.
  method private class promoGiftsub getDataStorage ( buffer inbf_promoGift for ub.promoGift ):
    return getDataStorage(buffer inbf_promoGift, ?).
  end.
  method private class promoGiftsub getDataStorage ( buffer inbf_promoGift for ub.promoGift, objCode as integer ):
    define variable promoGiftsubObj  as class promoGiftsub.
    promoGiftsubObj = new promoGiftsub ().
    return getDataStorage(promoGiftsubObj,buffer inbf_promoGift, objCode).
  end.
  method private class promoGiftsub getDataStorage (inpromoGiftSubObj as class promoGiftsub, buffer inbf_promoGift for ub.promoGift ):
    return getDataStorage(inpromoGiftSubObj,buffer inbf_promoGift, ?).
  end.
  method private class promoGiftsub getDataStorage (inpromoGiftSubObj as class promoGiftsub, buffer inbf_promoGift for ub.promoGift, obj-code as integer ):
    assign
      inpromoGiftSubObj:ID        = inbf_promoGift.id
      inpromoGiftSubObj:idCrit    = inbf_promoGift.idCrit
      inpromoGiftSubObj:idAction  = inbf_promoGift.idAction
      inpromoGiftSubObj:GdsCode   = inbf_promoGift.Gds-Code
      inpromoGiftSubObj:qnty      = inbf_promoGift.qnty
      inpromoGiftSubObj:mess      = inbf_promoGift.mess
      inpromoGiftSubObj:db-num    = inbf_promoGift.db-num
      inpromoGiftSubObj:objCode   = obj-code
    .
      for first ub.PromoAction no-lock where ub.PromoAction.id = inbf_promoGift.idaction:
      find first ub.PromoAttr no-lock where ub.PromoAttr.attr-code = "mess-gks" and
      ub.PromoAttr.p-key = string(ub.PromoAction.id) + chr(3) + string(ub.PromoAction.db-num) and
      ub.PromoAttr.tablename = "PromoGift" no-error .
      if available (ub.PromoAttr) then do:
        inpromoGiftSubObj:mess-gks = ub.PromoAttr.attr-value .
      end.
      end.
    return inpromoGiftSubObj.
  end.
  method public void refreshObj (inpromoGiftSubObj as class promoGiftsub):
    define buffer buf_promoGift for ub.promoGift.
    if not valid-object (inpromoGiftSubObj)
    then do:
      Msg = "Объект типа promoGiftsub не существует".
      return.
    end.
    find first buf_promoGift no-lock where buf_promoGift.ID = inpromoGiftSubObj:ID no-error.
    if not available (buf_promoGift)
    then do:
      Msg = "Не найден Товар - " + string (inpromoGiftSubObj:ID).
      return.
    end.
    getDataStorage (inpromoGiftSubObj, buffer buf_promoGift).
  end.
end class.
