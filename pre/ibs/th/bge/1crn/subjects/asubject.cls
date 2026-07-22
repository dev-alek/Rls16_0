using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.subjects from propath.
using ibs.th.bge.1crn.subjects.isubject from propath.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.asubject abstract inherits ibs.th.gbl.sys.objth implements ibs.th.bge.1crn.subjects.isubject:
  define public property Msg as character
    get.
    set.
  define public property IsInitSubForWrite as logical
    get.
    protected set.
  define abstract property InitTag as character no-undo
    get.
  define override public property vss-description as character no-undo get():
       return "Объект сообщения " + InitTag.
   end.
  define public property InitListTag as character no-undo init ""
    get.
    set.
  method public void SetProp (inTag as char, inValue as char).
    if inTag = InitTag then do:
      InitSub().
      return.
    end.
    if not IsInitSubForWrite
      then undo, throw new Progress.Lang.AppError( substitute ( "Сущность &1 не инициализирована для записи", InitTag )).
    SetPropProtected (inTag, inValue).
  end.
  method public void InitProp ().
    IsInitSubForWrite = not IsInitSubForWrite .
  end.
  method public void SetProp (inTag as char, inValue as longchar).
    if inTag = InitTag then do:
      InitSub().
      return.
    end.
    if not IsInitSubForWrite
      then undo, throw new Progress.Lang.AppError( substitute ( "Сущность &1 не инициализирована для записи", InitTag )).
    SetPropProtected (inTag, inValue).
  end.
  method public void SetProp (inSubObj as isubject).
    SetPropProtected (inSubObj).
  end.
  method protected void SetPropProtected (inSubObj as isubject):
  end.
  method public void SetProp (inSubsObj as subjects).
    if not IsInitSubForWrite
      then undo, throw new Progress.Lang.AppError( substitute ( "Сущность &1 не инициализирована для записи", InitTag )).
    if lookup (inSubsObj:InitTag, InitListTag) = 0 or InitListTag = "" then do:
          undo, throw new Progress.Lang.AppError( substitute ("Поддержка подсущности &1 для сущности &2 не реализована", inSubsObj:InitTag, InitTag)).
    end.
    SetPropProtected (inSubsObj).
  end.
  method abstract protected void SetPropProtected (inTag as char, inValue as char).
  method protected void SetPropProtected (inSubsObj as subjects):
    undo, throw new Progress.Lang.AppError( substitute ("Поддержка подсущности &1 для сущности &2 не реализована", inSubsObj:InitTag, InitTag)).
  end.
  method protected void InitSub ():
    if not IsInitSubForWrite
    then do:
      ClearSub().
      IsInitSubForWrite = true.
    end.
    else do:
      CheckData().
      IsInitSubForWrite = false.
    end.
  end.
  method protected void SetPropProtected (inTag as char, inValue as longchar):
  end.
  destructor public asubject ( ):
      ClearSub().
  end.
  method abstract protected void ClearSub ().
  method abstract protected void CheckData ().
end class.
