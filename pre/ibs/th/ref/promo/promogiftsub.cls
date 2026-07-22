using Progress.Lang.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
block-level on error undo, throw.
class ibs.th.ref.promo.PromoGiftSub implements ithsub:
define variable vss-revision    as character no-undo initial "$Revision: e455fc319afd, 3602, rls $":U .
define variable vss-author      as character no-undo initial "$Author: ARostovtsev $":U .
define variable vss-date        as character no-undo initial "$Date: 2023/12/28 12:56:37 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: promogiftsub.cls $":U .
define variable vss-archive     as character no-undo initial "$Archive: ibs/th/ref/promo/promogiftsub.cls $":U .
define variable vss-description as character no-undo initial "Объект подаркок акции.".
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
method private void getAttrLib ():
   define variable g#attr-lib  as handle no-undo .
   run gbl/getgattrlib.p (output g#attr-lib).
end.
method public void gdsoattr-name (
  input p-code            as character,
  output p-type           as character,
  output p-format         as character,
  output p-label          as character,
  output p-user-can-edit  as logical,
  output p-output-display as logical,
  output p-other          as character
  ):
  do:
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gdsoattr-name in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
method public void gdsoattr-tooltip (
  input  p-code    as character,
  output p-tooltip as character,
  output p-label   as character
  ):
  do:
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gdsoattr-tooltip in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
method public character gdsoattr-value (
  input  p-code     like ub.gds-obj-attr.attr-code,
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  output p-type     as   character
  ):
  define variable p-value like ub.gds-obj-attr.attr-value no-undo .
  do:
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gdsoattr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
  return p-value.
end.
method public integer gdsoattr-gds-code (
  input p-code     like ub.gds-obj-attr.attr-code,
  input p-value    like ub.gds-obj-attr.attr-value,
  input p-obj-type like ub.gds-obj-attr.obj-type,
  input p-obj-code like ub.gds-obj-attr.obj-code
  ):
  do:
  define variable p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gdsoattr-gds-code in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
  return p-gds-code.
end.
method public void gdsoattr-write (
  input p-gds-code like ub.gds-obj-attr.gds-code,
  input p-obj-type like ub.gds-obj-attr.obj-type,
  input p-obj-code like ub.gds-obj-attr.obj-code,
  input p-code     like ub.gds-obj-attr.attr-code,
  input p-value    like ub.gds-obj-attr.attr-value
  ):
  do:
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gdsoattr-write in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
method public logical gdsoattr-exist (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  input  p-code     like ub.gds-obj-attr.attr-code
  ):
  do:
  define variable p-exist    as logical no-undo .
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gdsoattr-exist in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
  return p-exist.
end.
method public logical gdsoattr-delete (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  input  p-code     like ub.gds-obj-attr.attr-code
  ):
  do:
  define variable p-deleted    as logical no-undo .
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gdsoattr-delete in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
  return p-deleted.
end.
method public logical gds-obj-doc-tickets (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  input-output p-value as character
  ):
  do:
  define variable p-setted    as logical no-undo .
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-obj-doc-tickets in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
  return p-setted.
end.
method public logical gds-obj-dop-alt-name (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  input-output p-value as character
  ):
  do:
  define variable p-setted    as logical no-undo .
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-obj-dop-alt-name in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
  return p-setted.
end.
method public logical gds-obj-gds-margins (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  input-output p-value as character
  ):
  do:
  define variable p-setted    as logical no-undo .
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-obj-gds-margins in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
  return p-setted.
end.
method public logical gds-obj-normal-wastage (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  input-output p-value as character
  ):
  do:
  define variable p-setted    as logical no-undo .
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-obj-normal-wastage in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
  return p-setted.
end.
method public void gds-attr-margin-value (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  output p-min-value        as decimal,
  output p-max-value        as decimal,
  output p-increase-pc      as decimal,
  output p-rmethod          as character,
  output p-base             as decimal,
  output p-range-margin     as integer,
  output p-exists-margin    as logical,
  output p-range-increase   as integer,
  output p-exists-increase  as logical,
  output p-range-rmethod    as integer,
  output p-exists-rmethod   as logical
  ):
  do:
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-attr-margin-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
method public class ibs.th.ref.normwastsub gds-o-normal-wastage-value (
  input objNormWast as class ibs.th.ref.normwastsub
  ):
  do:
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-o-normal-wastage-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
  return objNormWast.
end.
method public logical gdsoattr-copy (
  input p-code as character
  ):
  define variable p-copy as logical no-undo .
  do:
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gdsoattr-copy in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
  return p-copy.
end.
method public integer gds-attr_check-code-dt-seasons (
  input  p-code     like ub.goods.gds-code,
  input  p-obj-type like ub.clients.obj-type,
  input  p-obj-code like ub.clients.obj-code,
  output p-gds-code like ub.goods.gds-code
  ):
  define variable p-dt-code as integer no-undo .
  do:
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-attr_check-code-dt-seasons in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
  return p-dt-code.
end.
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
  define property idCrit as int64 no-undo
    get.
    SET (arg as int64):
      if arg <> idCrit
      then do:
        idCrit = arg.
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
  define property db-num as integer  no-undo
    get.
    set(arg as integer ):
      if arg <> db-num
      then do:
        db-num = arg.
        setFlagChange (true).
      end.
    end.
  define property GdsCode as integer no-undo
    get.
    set(arg as integer):
      if arg <> GdsCode
      then do:
        GdsCode = arg.
        setFlagChange (true).
      end.
    END.
  define property objCode as integer no-undo
    get.
    set.
    define buffer bf_gds for ub.goods.
    define property GdsName as character no-undo
    get:
      if available (bf_gds)
      then do:
        return bf_gds.gds-name.
      end.
      else do:
        find first bf_gds no-lock
          where bf_gds.gds-code = GdsCode no-error.
        if available (bf_gds)
        then do:
          return bf_gds.gds-name.
        end.
        else return "".
      end.
    end.
    define property dtSeason as character no-undo
    get:
      define variable typeAttr as character no-undo.
      if not available (bf_gds) then
      do:
        find first bf_gds no-lock
          where bf_gds.gds-code = GdsCode no-error.
      end.
      if available (bf_gds) then
      do:
          return
            gdsoattr-value(
              'dt-seasons':U,
              gdsCode,
              'маг':U,
              objCode,
              output typeAttr
            ).
      end.
      else return "".
    end.
    define property qnty as dec no-undo
    get.
    set(arg as dec):
      if arg <> qnty
      then do:
        qnty = arg.
        setFlagChange (true).
      end.
    END.
    define property mess as char no-undo
    get.
    set(arg as char):
      if arg <> mess
      then do:
        mess = arg.
        setFlagChange (true).
      end.
    END.
    define property mess-gks as char no-undo
    get.
    set(arg as char):
      if arg <> mess-gks
      then do:
        mess-gks = arg.
        setFlagChange (true).
      end.
    END.
    define property Mode as char no-undo init 'и':U
    get.
    set.
    define property Changed as logical no-undo
    get.
    set.
  constructor public promogiftsub (  ):
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
