/*

$Revision: 05c544fec1e9, 3625, test $
$Author: DRuban $
$Date: 2024/01/12 08:26:16 $
$Workfile: mapstringgbl.cls $
$Archive: ibs/th/gbl/map/mapstringgbl.cls $

карта по строковому ключу. содержит коллекцию объектов и предоставляет объекты по строковому ключу.

Автор: Александр Морозов
Дата создания: 26/09/17
Author: Morozov Alexandr
Creation date: 26/09/17

*/

using Progress.Lang.*.
using ibs.th.gbl.collection.*.
using ibs.th.gbl.sys.objth.
block-level on error undo, throw.


class ibs.th.gbl.map.mapstringgbl inherits ibs.th.gbl.sys.objth:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Класс для хранеиня всех коллекций" get.
 
  
  define variable iCounter as integer no-undo.

  define property UncnowObj as class Progress.Lang.Object no-undo
    get.
    private set.
  
  define private temp-table ttListObj no-undo
    field ObjNum as integer
    field iNum as integer
    field keyStr as character
    field ByKeyStr as int
    field keyInt as integer
    field ByKeyInt as integer 
    field LabStr as character
    field ByLabStr as int
    field SubObj as class Progress.Lang.Object
    index pi is primary unique ObjNum iNum 
    index keyStr is unique ObjNum keyStr
    index keyInt is unique ObjNum keyInt
    index ByKeyStr ObjNum ByKeyStr
    index ByKeyInt ObjNum ByKeyInt
    index obj is unique SubObj.
    
  define variable vObjNum as integer no-undo.
  method public int GetNextObjNum ():
     vObjNum= vObjNum + 1.
     return vObjNum.
  end.  
  define variable vLasObjNum as integer no-undo.
/*  method public void AddItem (iNumObj as integer, subObj as Progress.Lang.Object, keyStr as character):                   */
/*     AddItem (iNumObj, subObj, ?, keyStr).                                                                                */
/*  end.                                                                                                                    */
/*                                                                                                                          */
/*  method public void AddItem (iNumObj as integer,subObj as Progress.Lang.Object, keyInt as integer , keyStr as character):*/
/*     AddItem (iNumObj, subObj, keyInt, keyStr, ? ).                                                                       */
/*  end.                                                                                                                    */
/*                                                                                                                          */
  method public void AddItem (iNumObj as integer, subObj as Progress.Lang.Object, keyInt as integer, keyStr as character, LabStr as character):
    define buffer ttListObj for ttListObj.
    find first ttListObj where ttListObj.ObjNum eq iNumObj
                           and ttListObj.SubObj eq subObj
    no-error.
    if not available ttListObj
    then do:
       if vLasObjNum ne iNumObj
       then do:
          find Last ttListObj where ttListObj.ObjNum eq iNumObj no-error.
          if available ttListObj 
          then
             iCounter =  ttListObj.ObjNum.
          else 
             iCounter = 0.
          vLasObjNum = iNumObj.
       end.
       iCounter = iCounter + 1.
       create ttListObj.
       assign
         ttListObj.ObjNum = iNumObj
         ttListObj.iNum   = iCounter
         ttListObj.SubObj = subObj
      .
   end.
   assign
      ttListObj.keyStr = keyStr
      ttListObj.keyInt = if keyInt eq ? then iCounter         else keyInt
      ttListObj.LabStr = if LabStr eq ? then ttListObj.keyStr else LabStr
   
   no-error.
   if error-status:error
   then do:
      /*ругаться*/
   end.
  end. 

  method public void DeleteItem (iNumObj as integer, iNum as int):
    define buffer ttListObj for ttListObj.
    find first ttListObj where ttListObj.ObjNum eq iNumObj
                           and ttListObj.iNum   eq iNum.
    delete ttListObj.
    for each ttListObj where ttListObj.ObjNum eq iNumObj
                         and ttListObj.iNum   > iNum use-index pi :
      assign
        ttListObj.iNum = ttListObj.iNum - 1.
    end.
    if vLasObjNum eq iNumObj
    then do:
       iCounter = iCounter - 1.
    end.
  end.
  
  method public void DeleteItem (iNumObj as integer, keyStr as character):
    define buffer ttListObj for ttListObj.
    
    def var iNum as integer no-undo.
    find first ttListObj where ttListObj.ObjNum eq iNumObj
                           and ttListObj.keyStr eq keyStr.
    iNum = ttListObj.iNum.
    delete ttListObj.
    for each ttListObj where ttListObj.ObjNum eq iNumObj
                         and ttListObj.iNum > iNum use-index pi :
      assign
        ttListObj.iNum = ttListObj.iNum - 1.
    end.
    if vLasObjNum ne iNumObj
    then do:
       iCounter = iCounter - 1.
    end.
    
  end.
  
  method public void DeleteItems (iNumObj as integer):
    define buffer ttListObj for ttListObj.
    
    repeat preselect each ttListObj where ttListObj.ObjNum eq iNumObj:
       find next ttListObj.
         delete ttListObj.
    end.
    if vLasObjNum eq iNumObj
    then do:
       iCounter = 0.
    end.
    
  end.
  
  method public void SortTab (iNumObj as integer):
     define buffer ttListObj for ttListObj.
     define variable vi as integer no-undo.
     vi = 0.
     for each ttListObj where ttListObj.ObjNum eq iNumObj
                          and ttListObj.KeyInt ne ? 
     by ttListObj.keyStr:
        vi = vi + 1.
        ttListObj.ByKeyStr = vi. 
     end.
        
     vi = 0.
     for each ttListObj where ttListObj.ObjNum eq iNumObj
                          and ttListObj.KeyInt ne ? 
     by ttListObj.keyInt:
        vi = vi + 1.
        ttListObj.ByKeyInt = vi. 
     end.
        
     vi = 0.
     for each ttListObj where ttListObj.ObjNum eq iNumObj
                          and ttListObj.KeyInt ne ?  
     by ttListObj.LabStr:
        vi = vi + 1.
        ttListObj.ByLabStr = vi. 
     end.
        
  end.

  method public Progress.Lang.Object GetItem (iNumObj as integer, iNum as int):
    define variable SubjectObjCurr as class Progress.Lang.Object no-undo.
    define buffer ttListObj for ttListObj.
    SubjectObjCurr = UncnowObj.
    for first ttListObj where ttListObj.ObjNum eq iNumObj
                          and ttListObj.iNum   eq iNum:
      SubjectObjCurr = ttListObj.SubObj.
    end.
    return SubjectObjCurr.
  end.
  
  method public Progress.Lang.Object GetItemByInt (iNumObj as integer, iNum as int):
    define variable SubjectObjCurr as class Progress.Lang.Object no-undo.
    SubjectObjCurr = UncnowObj.
    for first ttListObj where ttListObj.ObjNum eq iNumObj
                          and ttListObj.ByKeyInt = iNum:
      SubjectObjCurr = ttListObj.SubObj.
    end.
    return SubjectObjCurr.
  end.

  method public Progress.Lang.Object GetItemByStr (iNumObj as integer, iNum as int):
    define variable SubjectObjCurr as class Progress.Lang.Object no-undo.
    SubjectObjCurr = UncnowObj.
    for first ttListObj where ttListObj.ObjNum eq iNumObj
                          and ttListObj.ByKeyStr = iNum:
      SubjectObjCurr = ttListObj.SubObj.
    end.
    return SubjectObjCurr.
  end.
  
  method public Progress.Lang.Object GetItemByLab (iNumObj as integer,iNum as int):
    define variable SubjectObjCurr as class Progress.Lang.Object no-undo.
    SubjectObjCurr = UncnowObj.
    for first ttListObj where ttListObj.ObjNum eq iNumObj
                          and ttListObj.ByLabStr = iNum:
      SubjectObjCurr = ttListObj.SubObj.
    end.
    return SubjectObjCurr.
  end.
  
  method public class Progress.Lang.Object GetItemKeyStr (iNumObj as integer,keyStr as character):
    define variable SubjectObjCurr as class Progress.Lang.Object no-undo.
    SubjectObjCurr = UncnowObj.
    for first ttListObj where ttListObj.ObjNum eq iNumObj
                          and ttListObj.keyStr = keyStr:
      SubjectObjCurr = ttListObj.SubObj.
    end.
    return SubjectObjCurr.
  end.

  method public class Progress.Lang.Object GetItemKeyInt (iNumObj as integer,keyInt as integer):
    define variable SubjectObjCurr as class Progress.Lang.Object no-undo.
    SubjectObjCurr = UncnowObj.
    for first ttListObj where ttListObj.ObjNum eq iNumObj
                          and ttListObj.keyInt = keyint:
      SubjectObjCurr = ttListObj.SubObj.
    end.
    return SubjectObjCurr.
  end.
end class.