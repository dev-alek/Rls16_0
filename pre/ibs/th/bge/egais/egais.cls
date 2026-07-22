using Progress.Lang.*.
using ibs.th.bge.egais.*.
block-level on error undo, throw.
class ibs.th.bge.egais.EGAIS:
  define variable oldEGAISImpl as class EGAISImpl no-undo.
  define property DbNum as integer no-undo init ?
    get.
    private set.
  define property User_Id as char no-undo init ?
    get.
    private set.
  define public property EGAISImpl as class EGAISImpl
    get.
    set (arg as class EGAISImpl):
      if valid-object (oldEGAISImpl)
        then delete object oldEGAISImpl.
      EGAISImpl = arg.
      EGAISImpl:DbNum = DbNum.
      EGAISImpl:User_Id = User_Id.
      oldEGAISImpl = arg.
    end.
  define property IsSent as logical no-undo
    get:
      return EGAISImpl:IsSent.
    end.
    protected set.
  define property ReplyId as character no-undo
    get.
    protected set.
  define property Msg as character no-undo
    get.
    protected set.
  define property StatusErr as logical no-undo init false
    get.
    protected set.
  constructor public EGAIS (inDbNum as int, inUserId as char):
    assign
      DbNum   = inDbNum
      User_Id = inUserId
      .
  end constructor.
  method public logical SendRequestUTM ():
    define variable glog as logical no-undo.
    assign
      StatusErr = false
      Msg       = "".
    assign
      glog      = EGAISImpl:SendRequestUTM ()
      Msg       = EGAISImpl:Msg
      StatusErr = EGAISImpl:StatusErr
      ReplyId   = EGAISImpl:ReplyId
      .
    return glog.
  end.
  method public handle GetHndlTable ():
    define variable tth as handle no-undo.
    assign
      StatusErr = false
      Msg       = "".
    assign
      tth       = EGAISImpl:GetHndlTable()
      Msg       = EGAISImpl:Msg
      StatusErr = EGAISImpl:StatusErr
      .
    return tth.
  end.
  method public handle GetHndlTable (inArg as int, inArg1 as char):
    define variable tth as handle no-undo.
    assign
      StatusErr = false
      Msg       = "".
    assign
      tth       = EGAISImpl:GetHndlTable(inArg, inArg1)
      Msg       = EGAISImpl:Msg
      StatusErr = EGAISImpl:StatusErr
      .
    return tth.
  end.
  method public void SaveWB (inArg as char):
    define variable tth as handle no-undo.
    assign
      StatusErr = false
      Msg       = "".
    EGAISImpl:SaveWB(inArg).
    assign
      Msg       = EGAISImpl:Msg
      StatusErr = EGAISImpl:StatusErr
      .
  end.
  method public void RejectWB (inArg as char):
    define variable tth as handle no-undo.
    assign
      StatusErr = false
      Msg       = "".
    EGAISImpl:RejectWB(inArg).
    assign
      Msg       = EGAISImpl:Msg
      StatusErr = EGAISImpl:StatusErr
      .
  end.
  method public void ConnWB (inArg as char, inArg1 as char):
    define variable tth as handle no-undo.
    assign
      StatusErr = false
      Msg       = "".
    EGAISImpl:ConnWB(inArg, inArg1).
    assign
      Msg       = EGAISImpl:Msg
      StatusErr = EGAISImpl:StatusErr
      .
  end.
end class.
