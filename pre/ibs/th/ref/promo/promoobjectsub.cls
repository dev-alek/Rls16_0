using Progress.Lang.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
USING ibs.th.ref.promo.*.
block-level on error undo, throw.
class ibs.th.ref.promo.PromoObjectSub implements ithsub:
define variable vss-revision    as character no-undo initial "$Revision: 709fd28fa30d, 1490, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo initial "$Date: Thu Aug 30 10:41:46 2018 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: promoobjectsub.cls $":U .
define variable vss-archive     as character no-undo initial "$Archive: ibs/th/ref/promo/promoobjectsub.cls $":U .
define variable vss-description as character no-undo initial "Объект объекта акции.".
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
  define property ID as int64 init ?  no-undo
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
  define buffer bf_clients for ub.clients.
  define property obj-type as char no-undo
    get.
    SET (arg as char):
      if arg <> obj-type
      then do:
        obj-type = arg.
        release bf_clients.
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
  define property obj-code as int no-undo
    get.
    set(arg as int):
      if arg <> obj-code
      then do:
        obj-code = arg.
        release bf_clients.
        setFlagChange (true).
      end.
    END.
  define property end-date as date no-undo
    get.
    set(arg as date):
      if arg <> end-date
      then do:
        end-date = arg.
        setFlagChange (true).
      end.
    END.
    define property FirmCode as integer no-undo
    get:
        define  variable v-host-code as integer   no-undo.
        define  variable v-host-name as character no-undo.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run hostname in ibs.th.gbl.gbl-hndllib:g#library
  (input  obj-type
  ,input  obj-code
  ,output v-host-code
  ,output v-host-name
  )  .
        return  v-host-code.
    end.
    define property FirmName as char no-undo
    get:
        define  variable v-host-code as integer no-undo.
        define  variable v-host-name as character no-undo.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run hostname in ibs.th.gbl.gbl-hndllib:g#library
  (input  obj-type
  ,input  obj-code
  ,output v-host-code
  ,output v-host-name
  )  .
        return  v-host-name.
    end.
    define property objName as character no-undo
    get:
      if available (bf_clients)
      then do:
        return bf_clients.obj-name.
      end.
      else do:
        find first bf_clients no-lock
             where bf_clients.obj-type = obj-type
               and bf_clients.obj-code = obj-code
        no-error.
        if available (bf_clients)
        then do:
          return bf_clients.obj-name.
        end.
        else return "".
      end.
    end.
    define property objDbNum as Integer no-undo
    get:
      if available (bf_clients)
      then do:
        return bf_clients.db-num.
      end.
      else do:
        find first bf_clients no-lock
             where bf_clients.obj-type = obj-type
               and bf_clients.obj-code = obj-code
        no-error.
        if available (bf_clients)
        then do:
          return bf_clients.db-num.
        end.
        else return 0.
      end.
    end.
    define property Mode as char no-undo init 'и':U
    get.
    set.
    define property Changed as logical no-undo
    get.
    set.
  constructor public promoobjectsub (  ):
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
  destructor public promoobjectsub ( ):
   //  Clean().
  end destructor.
end class.
