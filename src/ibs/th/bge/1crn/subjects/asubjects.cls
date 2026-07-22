/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

абстрактный класс на основе коллекций для ERPRN

Автор: Александр Морозов
Дата создания: 26/09/17
Author: Morozov Alexandr
Creation date: 26/09/17

*/

using Progress.Lang.*.
using ibs.th.gbl.collection.isubjects from propath.

block-level on error undo, throw.

class ibs.th.bge.1crn.subjects.asubjects implements isubjects abstract:
  
  define property iCounter as integer no-undo
    get.
    private set.

  define property SubjectObjCurr as class Progress.Lang.Object no-undo
    get.
    set.
    
  
  define private temp-table ttListObj no-undo
    field iNum as integer
    field SubObj as class Progress.Lang.Object
    index pi is primary unique iNum .
  
  
  method public void Add (subObj as Progress.Lang.Object):
     assign 
      iCounter = iCounter + 1.
    create ttListObj.
    assign
      ttListObj.iNum = iCounter
      ttListObj.SubObj = subObj
    .
    SubjectObjCurr = subObj.
    
  end. 

  method public void Delete (iNum as int):
    find first ttListObj where ttListObj.iNum = iNum.
    SubjectObjCurr = ttListObj.SubObj.
    delete object SubjectObjCurr no-error.
    delete ttListObj.
    iNum = 0.
    for each ttListObj use-index pi:
      assign
        iNum = iNum + 1
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
    
      for each ttListObj:
        SubjectObjCurr = ttListObj.SubObj.
        delete object SubjectObjCurr no-error.
      end.
    
  end destructor.

end class.