using Progress.Lang.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
USING ibs.th.ref.promo.*.
block-level on error undo, throw.
class ibs.th.ref.promo.PromoCriterionSub implements ithsub:
define variable vss-revision    as character no-undo initial "$Revision: 971568bb50e0, 1502, rls $":U .
define variable vss-author      as character no-undo initial "$Author: obrezanova $":U .
define variable vss-date        as character no-undo initial "$Date: Thu Aug 30 10:41:48 2018 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: promocriterionsub.cls $":U .
define variable vss-archive     as character no-undo initial "$Archive: ibs/th/ref/promo/promocriterionsub.cls $":U .
define variable vss-description as character no-undo initial "Объект критерий акции.".
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
  define property ID as int64 no-undo
    get.
    set (ID-arg as int64):
      ID = ID-arg.
    end.
    define property db-num as integer  no-undo
    get.
    set(arg as integer ):
      if arg <> db-num
      then do:
        db-num = arg.
        setFlagChange (true).
      end.
    end.
  define property mincrit as dec no-undo
    get.
    SET (arg as dec):
      if arg <> mincrit
      then do:
        mincrit = arg.
        setFlagChange (true).
      end.
    END.
  define property maxcrit as dec no-undo
    get.
    SET (arg as dec):
      if arg <> maxcrit
      then do:
        maxcrit = arg.
        setFlagChange (true).
      end.
    END.
  define property idAction as int64 no-undo
    get.
    set(arg as int64):
      if arg <> idAction
      then do:
        idAction = arg.
        setFlagChange (true).
      end.
    END.
  define property discont as dec no-undo
    get.
    set(arg as dec):
      if arg <> discont
      then do:
        discont = arg.
        setFlagChange (true).
      end.
    END.
    define property Gifts as CLASS promoGiftsubs no-undo
    get():
       DEFINE VARIABLE vStorageOBj AS CLASS promoGiftStorage.
       IF     this-object:refreshObj
          and not valid-object (Gifts)
       THEN DO :
          vStorageOBj = NEW promoGiftStorage().
          Gifts = vStorageOBj:getpromoGiftSubs(idAction,id,db-num).
          delete OBJECT vStorageOBj no-error.
       END.
       RETURN Gifts.
    END.
    set(arg as CLASS promoGiftsubs):
        Gifts = arg.
        setFlagChange (true).
    END.
    define property Mode as char no-undo init 'и':U
    get.
    set.
    define property Changed as logical no-undo
    get.
    set.
  constructor public promoCriterionsub (  ):
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
     if valid-object(THIS-OBJECT:Gifts)      then delete object THIS-OBJECT:Gifts no-error.
  end.
  method public void refreshChildObj():
     Clean().
     this-object:refreshObj = yes.
     THIS-OBJECT:Gifts no-error.
     this-object:refreshObj = no.
  end.
  destructor public promocriterionsub ( ):
     Clean().
  end destructor.
end class.
