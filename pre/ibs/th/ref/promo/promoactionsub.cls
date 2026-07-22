using Progress.Lang.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
USING ibs.th.ref.promo.*.
block-level on error undo, throw.
class ibs.th.ref.promo.PromoActionSub implements ithsub:
  define variable vss-revision    as character no-undo initial "$Revision: e455fc319afd, 3602, rls $":U .
  define variable vss-author      as character no-undo initial "$Author: ARostovtsev $":U .
  define variable vss-date        as character no-undo initial "$Date: 2023/12/28 12:56:37 $":U .
  define variable vss-workfile    as character no-undo initial "$Workfile: promoactionsub.cls $":U .
  define variable vss-archive     as character no-undo initial "$Archive: ibs/th/ref/promo/promoactionsub.cls $":U .
  define variable vss-description as character no-undo initial "Объект акция.".
  define variable vpromotype as class promotype no-undo.
  define property Msg as character no-undo
    get.
    set.
  define property StatusErr as logical no-undo
    get:
      def var err as log no-undo.
      err = StatusErr.
      StatusErr = false.
      return err.
    end.
    private set.
  define property ID as int64  no-undo
    get.
    set (ID-arg as int64):
      ID = ID-arg.
    end.
  define property db-num as integer no-undo init ?
    get.
    set(arg as integer):
      if arg <> db-num
        then
      do:
        db-num = arg.
        setFlagChange (true).
      end.
    END.
  define property objCode as integer no-undo
    get.
    set.
  define property beg-date as Date no-undo
    get():
      return if beg-date eq ? then today else beg-date.
    end.
    SET (arg as Date):
      if arg <> beg-date
        then
      do:
        beg-date = arg.
        setFlagChange (true).
      end.
    END.
  define property end-date as Date no-undo
    get():
      return if end-date eq ? then today else end-date.
    end.
    set(arg as Date):
      if arg <> end-date
        then
      do:
        end-date = arg.
        setFlagChange (true).
      end.
    END.
  define property NameAction as char no-undo
    get.
    set(arg as char):
      if arg <> NameAction
        then
      do:
        NameAction = arg.
        setFlagChange (true).
      end.
    END.
  define property promosched-id as integer no-undo
    get.
    set.
  define property TypeDiscont as integer no-undo
    get.
    set(arg as integer):
      if arg <> TypeDiscont
      then do:
        TypeDiscont = arg.
        setFlagChange (true).
      end.
    end.
    define property TypeDiscontlbl as character  no-undo
    get():
         if valid-object(vpromotype)
         then
         return  vpromotype:typeLbl ("TypeDiscont", TypeDiscont).
         else
         return "".
    end.
    set(arg as character):
        TypeDiscont =  vpromotype:typeint("TypeDiscont",arg).
    end.
    define property TypeDiscontenum as ibs.th.ref.promo.enum-type-discount no-undo
    get():
        define variable vTypeDiscontenum as ibs.th.ref.promo.enum-type-discount no-undo.
        vTypeDiscontenum = ibs.th.ref.promo.enum-type-discount:GetEnum(TypeDiscont) no-error.
        return   vTypeDiscontenum.
    end.
    set(arg as ibs.th.ref.promo.enum-type-discount):
        TypeDiscont =  arg:GetValue(). .
    end.
  define property methodCalc as integer no-undo
    get.
    set(arg as integer):
      if arg <> methodCalc
      then do:
        methodCalc = arg.
        setFlagChange (true).
      end.
    end.
    define property methodCalclbl as character  no-undo
    get():
         if valid-object(vpromotype)
         then
         return  vpromotype:typeLbl ("methodCalc", methodCalc).
         else
         return "".
    end.
    set(arg as character):
        methodCalc =  vpromotype:typeint("methodCalc",arg).
    end.
  define property typecond as integer no-undo
    get.
    set(arg as integer):
      if arg <> typecond
      then do:
        typecond = arg.
        setFlagChange (true).
      end.
    end.
    define property typecondlbl as character  no-undo
    get():
         if valid-object(vpromotype)
         then
         return  vpromotype:typeLbl ("typecond", typecond).
         else
         return "".
    end.
    set(arg as character):
        typecond =  vpromotype:typeint("typecond",arg).
    end.
  define property status_ as integer no-undo
    get.
    set(arg as integer):
      if arg <> status_
      then do:
        status_ = arg.
        setFlagChange (true).
      end.
    end.
    define property status_lbl as character  no-undo
    get():
         if valid-object(vpromotype)
         then
         return  vpromotype:typeLbl ("status_", status_).
         else
         return "".
    end.
    set(arg as character):
        status_ =  vpromotype:typeint("status_",arg).
    end.
    define property status_enum as ibs.th.ref.promo.enum-promo-status no-undo
    get():
        define variable vstatus_enum as ibs.th.ref.promo.enum-promo-status no-undo.
        vstatus_enum = ibs.th.ref.promo.enum-promo-status:GetEnum(status_) no-error.
        return   vstatus_enum.
    end.
    set(arg as ibs.th.ref.promo.enum-promo-status):
        status_ =  arg:GetValue(). .
    end.
  define property priority as int no-undo
    get.
    SET (arg as int):
      if arg <> priority
        then
      do:
        priority = arg.
        setFlagChange (true).
      end.
    END.
  define property comment as char no-undo
    get.
    SET (arg as char):
      if arg <> comment
        then
      do:
        comment = arg.
        setFlagChange (true).
      end.
    END.
  define property description as char no-undo
    get.
    set (arg as char):
      if arg <> description
        then
      do:
        description = arg.
        setFlagChange (true).
      end.
    end.
  define property paymenttype as char no-undo
    get.
    set (arg as char):
      if arg <> paymenttype
        then
      do:
        paymenttype = arg.
        setFlagChange (true).
      end.
    end.
  define property ext-code as char no-undo
    get.
    set (arg as char):
      if arg <> ext-code
        then
      do:
        ext-code = arg.
        setFlagChange (true).
      end.
    end.
  define property changeDate as date no-undo
    get.
    set (arg as date):
      if arg <> changeDate
        then
      do:
        changeDate = arg.
        setFlagChange (true).
      end.
    end.
  define property Mode as char no-undo init 'и':U
    get.
  set.
  define property GoodsCrits as CLASS promogoodssubs no-undo
    get():
       DEFINE VARIABLE vStorageOBj AS CLASS promoGoodsStorage.
       IF     this-object:refreshObj
          and not valid-object (GoodsCrits)
       THEN DO :
          vStorageOBj = NEW promoGoodsStorage().
          GoodsCrits = vStorageOBj:getpromoGoodssubs(id,ibs.th.ref.promo.enum-promo-goods-type:criterion,db-num,objCode).
          delete OBJECT vStorageOBj no-error.
       END.
       RETURN GoodsCrits.
    END.
    set(arg as CLASS promogoodssubs):
        GoodsCrits = arg.
        setFlagChange (true).
    END.
  define property CritgoodsFl as logical no-undo init ?
    get():
      return if CritgoodsFl eq ?
        then if valid-object (this-object:GoodsCrits)
        then GoodsCrits:iCounter ne 0
        else no
        else no.
    end.
    set.
  define property GoodsAppl as CLASS promogoodssubs no-undo
    get():
       DEFINE VARIABLE vStorageOBj AS CLASS promoGoodsStorage.
       IF     this-object:refreshObj
          and not valid-object (GoodsAppl)
       THEN DO :
          vStorageOBj = NEW promoGoodsStorage().
          GoodsAppl = vStorageOBj:getpromoGoodssubs(id,ibs.th.ref.promo.enum-promo-goods-type:appl,db-num,objCode).
          delete OBJECT vStorageOBj no-error.
       END.
       RETURN GoodsAppl.
    END.
    set(arg as CLASS promogoodssubs):
        GoodsAppl = arg.
        setFlagChange (true).
    END.
  define property PromoSet as CLASS promogoodssubs no-undo
    get():
       DEFINE VARIABLE vStorageOBj AS CLASS promoGoodsStorage.
       IF     this-object:refreshObj
          and not valid-object (PromoSet)
       THEN DO :
          vStorageOBj = NEW promoGoodsStorage().
          PromoSet = vStorageOBj:getpromoGoodssubs(id,ibs.th.ref.promo.enum-promo-goods-type:promoSet,db-num,objCode).
          delete OBJECT vStorageOBj no-error.
       END.
       RETURN PromoSet.
    END.
    set(arg as CLASS promogoodssubs):
        PromoSet = arg.
        setFlagChange (true).
    END.
  define property CardsBin as CLASS promogoodssubs no-undo
    get():
       DEFINE VARIABLE vStorageOBj AS CLASS promoGoodsStorage.
       IF     this-object:refreshObj
          and not valid-object (CardsBin)
       THEN DO :
          vStorageOBj = NEW promoGoodsStorage().
          CardsBin = vStorageOBj:getpromoGoodssubs(id,ibs.th.ref.promo.enum-promo-goods-type:bin,db-num,objCode).
          delete OBJECT vStorageOBj no-error.
       END.
       RETURN CardsBin.
    END.
    set(arg as CLASS promogoodssubs):
        CardsBin = arg.
        setFlagChange (true).
    END.
  define property BarCode as CLASS promogoodssubs no-undo
    get():
       DEFINE VARIABLE vStorageOBj AS CLASS promoGoodsStorage.
       IF     this-object:refreshObj
          and not valid-object (BarCode)
       THEN DO :
          vStorageOBj = NEW promoGoodsStorage().
          BarCode = vStorageOBj:getpromoGoodssubs(id,ibs.th.ref.promo.enum-promo-goods-type:barcode,db-num,objCode).
          delete OBJECT vStorageOBj no-error.
       END.
       RETURN BarCode.
    END.
    set(arg as CLASS promogoodssubs):
        BarCode = arg.
        setFlagChange (true).
    END.
  define property Criterion as CLASS promoCriterionsubs no-undo
    get():
       DEFINE VARIABLE vStorageOBj AS CLASS promoCriterionStorage.
       IF     this-object:refreshObj
          and not valid-object (Criterion)
       THEN DO :
          vStorageOBj = NEW promoCriterionStorage().
          Criterion = vStorageOBj:getpromoCriterionSubs(id,db-num).
          delete OBJECT vStorageOBj no-error.
       END.
       RETURN Criterion.
    END.
    set(arg as CLASS promoCriterionsubs):
        Criterion = arg.
        setFlagChange (true).
    END.
  define property Gifts as CLASS promoGiftsubs no-undo
    get():
       DEFINE VARIABLE vStorageOBj AS CLASS promoGiftStorage.
       IF     this-object:refreshObj
          and not valid-object (Gifts)
       THEN DO :
          vStorageOBj = NEW promoGiftStorage().
          Gifts = vStorageOBj:getpromoGiftSubs(id,0,db-num,objCode).
          delete OBJECT vStorageOBj no-error.
       END.
       RETURN Gifts.
    END.
    set(arg as CLASS promoGiftsubs):
        Gifts = arg.
        setFlagChange (true).
    END.
  define property Objects as CLASS promoObjectSubs no-undo
    get():
       DEFINE VARIABLE vStorageOBj AS CLASS promoObjectStorage.
       IF     this-object:refreshObj
          and not valid-object (Objects)
       THEN DO :
          vStorageOBj = NEW promoObjectStorage().
          Objects = vStorageOBj:getpromoObjectSubs(id,db-num).
          delete OBJECT vStorageOBj no-error.
       END.
       RETURN Objects.
    END.
    set(arg as CLASS promoObjectSubs):
        Objects = arg.
        setFlagChange (true).
    END.
  define property Schedule as CLASS promoSchedsub no-undo
    get():
       DEFINE VARIABLE vStorageOBj AS CLASS promoSchedStorage.
       IF     this-object:refreshObj
          and not valid-object (Schedule)
       THEN DO :
          vStorageOBj = NEW promoSchedStorage().
          Schedule = vStorageOBj:getpromoSchedSub(promosched-id).
          delete OBJECT vStorageOBj no-error.
       END.
       RETURN Schedule.
    END.
    set(arg as CLASS promoSchedsub):
        Schedule = arg.
        setFlagChange (true).
    END.
  define property ScheduleWeek as CLASS promoSchedwsubs no-undo
    get():
       DEFINE VARIABLE vStorageOBj AS CLASS promoSchedwStorage.
       IF     this-object:refreshObj
          and not valid-object (ScheduleWeek)
       THEN DO :
          vStorageOBj = NEW promoSchedwStorage().
          ScheduleWeek = vStorageOBj:getpromoSchedwSubs(promosched-id).
          delete OBJECT vStorageOBj no-error.
       END.
       RETURN ScheduleWeek.
    END.
    set(arg as CLASS promoSchedwsubs):
        ScheduleWeek = arg.
        setFlagChange (true).
    END.
  define property Changed as logical no-undo
    get.
    set.
  constructor public promoactionsub (  ):
    this-object(?).
  end constructor.
  constructor public promoactionsub ( objCode as integer ):
    vpromotype = new promotype().
    this-object:objCode = objCode.
  end constructor.
  method public void setMsg( arg as character ):
    Msg = arg.
  end.
  method public void setStatusErr( arg as logical ):
    StatusErr = arg.
  end.
  method public void setFlagChange( arg as logical ):
    Changed = arg.
  end.
  define private property refreshObj as logical no-undo
    get.
    set.
  method public void Clean():
    if valid-object(THIS-OBJECT:Criterion)    then delete object THIS-OBJECT:Criterion    no-error.
    if valid-object(THIS-OBJECT:Gifts)        then delete object THIS-OBJECT:Gifts        no-error.
    if valid-object(THIS-OBJECT:GoodsAppl)    then delete object THIS-OBJECT:GoodsAppl    no-error.
    if valid-object(THIS-OBJECT:GoodsCrits)   then delete object THIS-OBJECT:GoodsCrits   no-error.
    if valid-object(this-object:Objects)      then delete object this-object:Objects      no-error.
    if valid-object(THIS-OBJECT:Schedule)     then delete object THIS-OBJECT:Schedule     no-error.
    if valid-object(THIS-OBJECT:ScheduleWeek) then delete object THIS-OBJECT:ScheduleWeek no-error.
    if valid-object(THIS-OBJECT:CardsBin)     then delete object THIS-OBJECT:CardsBin     no-error.
  end.
  method public void refreshChildObj():
    Clean().
    this-object:refreshObj = yes.
     // --- start ---
    THIS-OBJECT:Criterion no-error.
    THIS-OBJECT:Gifts no-error.
    THIS-OBJECT:GoodsAppl no-error.
    THIS-OBJECT:CardsBin no-error.
    THIS-OBJECT:Promoset no-error.
    THIS-OBJECT:GoodsCrits no-error.
    this-object:Objects no-error.
    THIS-OBJECT:Schedule no-error.
    THIS-OBJECT:ScheduleWeek no-error.
     // --- end ---
    this-object:refreshObj = no.
  end method.
  destructor public promoactionsub ( ):
    Clean().
    delete object vpromotype no-error.
  end destructor.
end class.
