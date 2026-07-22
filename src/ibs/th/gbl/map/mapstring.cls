/*

$Revision: 05c544fec1e9, 3625, test $
$Author: DRuban $
$Date: 2024/01/12 08:26:16 $
$Workfile: mapstring.cls $
$Archive: ibs/th/gbl/map/mapstring.cls $

карта по строковому ключу. содержит коллекцию объектов и предоставляет объекты по строковому ключу.

Автор: Александр Морозов
Дата создания: 26/09/17
Author: Morozov Alexandr
Creation date: 26/09/17

*/

using Progress.Lang.*.
using ibs.th.gbl.collection.*.
using ibs.th.gbl.sys.objth.
using ibs.th.gbl.map.mapstringgbl.
block-level on error undo, throw.

class ibs.th.gbl.map.mapstring inherits ibs.th.gbl.sys.objth:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Класс для коллекций" get.
 
  
  define property iCounter as integer no-undo
    get.
    private set.

  define property SubjectObjCurr as class Progress.Lang.Object no-undo
    get.
    set.
  
  define property UncnowObj as class Progress.Lang.Object no-undo
    get.
    private set.
  
  define property IsDelChildObj as logical init true no-undo
    get.
    set.    
  
  define property isSort as logical init false no-undo
    get.
    private set.    
  
 
  /*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
  define variable vObjNum as integer no-undo.
  define variable MapStringGbl as MapStringGbl no-undo.
  constructor public mapstring ( isDelChild as log ):
    
    IsDelChildObj = isDelChild.
    MapStringGbl = objSrv:SystemAux:MapStringGbl.
    vObjNum = MapStringGbl:GetNextObjNum().
  end constructor.
  
    
  constructor public mapstring ( isDelChild as log, iobj as Progress.Lang.Object ):
    this-object(isDelChild).
    UncnowObj = iobj.
    
  end constructor.
  
  method public void AddItem (subObj as Progress.Lang.Object, keyStr as character):
     AddItem (subObj, ?, keyStr).
  end.
  
  method public void AddItem (subObj as Progress.Lang.Object, keyInt as integer , keyStr as character):
     AddItem (subObj, keyInt, keyStr, ? ).
  end.
  
  method public void AddItem (subObj as Progress.Lang.Object, keyInt as integer, keyStr as character, LabStr as character):
    MapStringGbl:AddItem(vObjNum, subObj, keyInt, keyStr, LabStr) no-error.
    if not error-status:error
    then
       iCounter = iCounter + 1.
    isSort = no.
    SubjectObjCurr = subObj.
  end. 

  method public void DeleteItem (iNum as int):
    MapStringGbl:DeleteItem(vObjNum, iNum).
    isSort = no.
    iCounter = iCounter - 1.
  end.
  
  method public void DeleteItem (keyStr as character):
    MapStringGbl:DeleteItem(vObjNum, keyStr).
    isSort = no.
    iCounter = iCounter - 1.
  end.
  
  method public void SortTab ():
     if not isSort
     then do: 
        MapStringGbl:SortTab(vObjNum).
        isSort = yes.
     end.
  end.

  method public integer GetItem (iNum as int):
    SubjectObjCurr = MapStringGbl:GetItem(vObjNum, iNum).
    if SubjectObjCurr eq MapStringGbl:UncnowObj
    then
       SubjectObjCurr = UncnowObj.
    return iCounter.
  end.
  
  method public integer GetItemByInt (iNum as int):
    SortTab().
    SubjectObjCurr = MapStringGbl:GetItemByInt(vObjNum, iNum).
    if SubjectObjCurr eq MapStringGbl:UncnowObj
    then
       SubjectObjCurr = UncnowObj.
    return iCounter.
  end.

  method public integer GetItemByStr (iNum as int):
    SortTab().
    SubjectObjCurr = MapStringGbl:GetItemByStr(vObjNum, iNum).
    if SubjectObjCurr eq MapStringGbl:UncnowObj
    then
       SubjectObjCurr = UncnowObj.
    return iCounter.
  end.
  
  method public integer GetItemByLab (iNum as int):
    SortTab().
    SubjectObjCurr = MapStringGbl:GetItemByLab(vObjNum, iNum).
    if SubjectObjCurr eq MapStringGbl:UncnowObj
    then
       SubjectObjCurr = UncnowObj.
    return iCounter.
  end.
  
  method public class Progress.Lang.Object GetItemKeyStr (keyStr as character):
    SubjectObjCurr = MapStringGbl:GetItemKeyStr(vObjNum, keyStr).
    if SubjectObjCurr eq MapStringGbl:UncnowObj
    then
       SubjectObjCurr = UncnowObj.
    return SubjectObjCurr.
  end.

  method public class Progress.Lang.Object GetItemKeyInt (keyInt as integer):
    SubjectObjCurr = MapStringGbl:GetItemKeyInt(vObjNum, keyInt).
    if SubjectObjCurr eq MapStringGbl:UncnowObj
    then
       SubjectObjCurr = UncnowObj.
    return SubjectObjCurr.
  end.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  destructor public mapstring ( ):
    
    if IsDelChildObj 
    then 
       MapStringGbl:DeleteItems(vObjNum).
    
  end destructor.
  
end class.