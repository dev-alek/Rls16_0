using Progress.Lang.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
block-level on error undo, throw.
class ibs.th.ref.promo.PromoSchedSub implements ithsub:
define variable vss-revision    as character no-undo initial "$Revision: 709fd28fa30d, 1490, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo initial "$Date: Thu Aug 30 10:41:46 2018 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: promoschedsub.cls $":U .
define variable vss-archive     as character no-undo initial "$Archive: ibs/th/ref/promo/promoschedsub.cls $":U .
define variable vss-description as character no-undo initial "Сущность Заголовок расписания промоакций.".
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
  define property ID as integer no-undo
    get.
    set.
  define property dispname as char no-undo
    get.
    set(arg as char):
      if arg <> dispname
      then do:
        dispname = arg.
        setFlagChange (true).
      end.
    END.
  define property schedType as integer no-undo
    get.
    set(arg as integer):
      if arg <> schedType
      then do:
        schedType = arg.
        setFlagChange (true).
      end.
    END.
  define property status_ as ibs.th.ref.promo.enum-sched-status no-undo
    get.
    set(arg as ibs.th.ref.promo.enum-sched-status):
      if arg <> status_
      then do:
        status_ = arg.
        setFlagChange (true).
      end.
    END.
  define property extCodeSched as char no-undo
    get.
    set(arg as char):
      if arg <> extCodeSched
      then do:
        extCodeSched = arg.
        setFlagChange (true).
      end.
    END.
  define property db-num as integer no-undo
    get.
    set(arg as integer):
      if arg <> db-num
      then do:
        db-num = arg.
        setFlagChange (true).
      end.
    END.
    define property Mode as char init 'и':U no-undo
    get.
    set.
    define property Changed as logical no-undo
    get.
    set.
  constructor public promoschedsub (  ):
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
end class.
