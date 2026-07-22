using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.bge.egais.EGAISImpl:
  define property IsSent as logical no-undo
    get:
      return GetIsSent ().
    end.
    protected set.
  define property ReplyId as character no-undo
    get.
    protected set.
  define property Msg as character no-undo
    get.
    protected set.
  define property DbNum as integer no-undo init ?
    get.
    set.
  define property User_Id as char no-undo init ?
    get.
    set.
  define property StatusErr as logical no-undo init false
    get.
    protected set.
  method public handle GetHndlTable ():
  end.
  method public handle GetHndlTable (inArg as int, inArg1 as char):
  end.
  method public logical SendRequestUTM ():
  end.
  method public void SaveWB (inArg as char):
  end.
  method public void RejectWB (inArg as char):
  end.
  method public void ConnWB (inArg as char, inArg1 as char):
  end.
  method protected logical GetIsSent ():
  end.
end class.
