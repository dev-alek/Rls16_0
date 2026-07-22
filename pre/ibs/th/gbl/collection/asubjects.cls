using Progress.Lang.*.
using ibs.th.gbl.collection.*.
block-level on error undo, throw.
class ibs.th.gbl.collection.asubjects implements isubjects:
  define property iCounter as integer no-undo
    get.
    private set.
  define property SubjectObjCurr as class Progress.Lang.Object no-undo
    get.
    set.
  define property IsDelChildObj as logical init true no-undo
    get.
    set.
  define private temp-table ttListObj no-undo
    field iNum   as integer
    field SubObj as class   Progress.Lang.Object
    index pi is primary unique iNum .
  constructor public asubjects ( arg as log ):
    IsDelChildObj = arg.
  end constructor.
  constructor public asubjects (  ):
  end constructor.
  method public void AddItem (subObj as Progress.Lang.Object):
    assign
      iCounter = iCounter + 1.
    create ttListObj.
    assign
      ttListObj.iNum   = iCounter
      ttListObj.SubObj = subObj
      .
    SubjectObjCurr = subObj.
  end.
  method public void DeleteItem (iNum as int):
    find first ttListObj where ttListObj.iNum = iNum.
    delete ttListObj.
    iNum = 0.
    for each ttListObj use-index pi:
      assign
        iNum           = iNum + 1
        ttListObj.iNum = iNum.
    end.
    iCounter = iCounter - 1.
  end.
  method public integer GetItem (iNum as int):
    for first ttListObj where ttListObj.iNum = iNum:
      SubjectObjCurr = ttListObj.SubObj.
    end.
    return iCounter.
  end.
  method public void Add (subObj as Progress.Lang.Object):
    assign
      iCounter = iCounter + 1.
    create ttListObj.
    assign
      ttListObj.iNum   = iCounter
      ttListObj.SubObj = subObj
      .
    SubjectObjCurr = subObj.
  end.
  method public void Delete (iNum as int):
    find first ttListObj where ttListObj.iNum = iNum.
    delete ttListObj.
    iNum = 0.
    for each ttListObj use-index pi:
      assign
        iNum           = iNum + 1
        ttListObj.iNum = iNum.
    end.
    iCounter = iCounter - 1.
  end.
  method public integer Get (iNum as int):
    for first ttListObj where ttListObj.iNum = iNum:
      SubjectObjCurr = ttListObj.SubObj.
    end.
    return iCounter.
  end.
  destructor public asubjects ( ):
    if IsDelChildObj
    then
      for each ttListObj:
        SubjectObjCurr = ttListObj.SubObj.
        delete object SubjectObjCurr no-error.
      end.
  end destructor.
end class.
