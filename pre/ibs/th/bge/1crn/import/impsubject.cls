using Progress.Lang.*.
using ibs.th.bge.1crn.import.*.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impsubject:
  define variable eventReceivedSubjectObj as class parsesub.
  define property Msg as character
    get.
    private set.
  define property ErrStatus as logical
    get.
    private set.
  constructor public impsubject ( input EventReceivedSubject as class parsesub ):
    EventReceivedSubjectObj = EventReceivedSubject.
    EventReceivedSubjectObj:ReceivedSubject:Subscribe (ReceivedSubjecEventHndlr ).
  end constructor.
  method private void ReceivedSubjecEventHndlr ( input subjectObj as class ibs.th.bge.1crn.subjects.isubject, input eventHndlrImpSubObj as class ibs.th.bge.1crn.import.iimpsubject):
    ErrStatus = not eventHndlrImpSubObj:Excute(subjectObj).
    if ErrStatus
    then do:
      Msg = eventHndlrImpSubObj:Msg.
      return error.
    end.
  end method.
end class.
