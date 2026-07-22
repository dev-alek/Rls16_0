/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 16 мая 2022 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 16 мая 2022 г.

*/

using Progress.Lang.*.
using ibs.th.gbl.propmap.
using ibs.th.gbl.map.mapstring.
using ibs.th.gbl.sys.objth.
block-level on error undo, throw.


class Ibs.Th.Gbl.TypeMap inherits objth abstract:
   
   
  define public property mapType as class mapstring no-undo get. 
    protected set.

  define public property CurrProp as class propmap no-undo 
  get:
    def var currP as class propmap no-undo. 
    currP = cast (mapType:SubjectObjCurr, propmap) no-error.
    if currP = ? or error-status:error
    then do:
     "Залогируем".
      return ?.
    end.
    else return currP.
  end. 
 
  define public property  Unknow as class propmap no-undo get.  protected set.
  define public property  startElem as integer no-undo init 1 get. set.
  constructor protected TypeMap ():
    super().
    getobjserv().
    if valid-object (ObjSrv)
    then 
       ObjSrv:Regobj(this-object).
    {utl\objreg.i Unknow propmap ? '"Unknow"' '"Неизвестный Type."' }
    {utl\objreg.i mapType mapstring true Unknow}
    
/*    Unknow  = crProp(-1,"Unknow","Неизвестный Type.").*/
 
  end.
  

  method public char GetLabel(inKey as int):
    def var prop as class propmap no-undo.
    if valid-object (mapType:GetItemKeyInt(inKey))
      then return cast (mapType:SubjectObjCurr, ibs.th.gbl.propmap):Label_. 
      else return ?.
  end method. 

  method public char GetLabel(inKeyStr as char):
    def var prop as class propmap no-undo.    
    if valid-object (mapType:GetItemKeyStr(inKeyStr))
      then return cast (mapType:SubjectObjCurr, ibs.th.gbl.propmap):Label_. 
      else return inKeyStr. /* для неизвестного типа статуса в лейбл возвращается значения ключа (грубо говоря того, что лежит в базе*/
  end method. 

  method public char GetNameProp(inKey as int):
    def var prop as class propmap no-undo.
    if valid-object (mapType:GetItemKeyInt(inKey))
      then return cast (mapType:SubjectObjCurr, ibs.th.gbl.propmap):NameProp. 
      else return ?.
  end method. 
 
  method public char GetNameProp(inKeyStr as char):
    def var prop as class propmap no-undo.
    if valid-object (mapType:GetItemKeyStr(inKeyStr))
      then return cast (mapType:SubjectObjCurr, ibs.th.gbl.propmap):NameProp. 
      else return ?.
  end method. 

  method public int GetKeyIntDB(inKeyStr as char):
    def var prop as class propmap no-undo.
    if valid-object (mapType:GetItemKeyStr(inKeyStr))
      then return cast (mapType:SubjectObjCurr, ibs.th.gbl.propmap):KeyIntDB. 
      else return ?.
  end method.
  
  method public class propmap GetProp(inKey as int):
    def var prop as class propmap no-undo.
    if valid-object (mapType:GetItemKeyInt(inKey))
    then return cast(mapType:SubjectObjCurr, propmap). 
    else return Unknow.
  end method. 

  method public class propmap GetProp(inKeyStr as char):
    def var prop as class propmap no-undo.
    if valid-object (mapType:GetItemKeyStr(inKeyStr))
    then return cast(mapType:SubjectObjCurr, propmap). 
    else return Unknow.
  end method.
  
  method protected class propmap crProp(inNameProp as char, inLabel as char):
     crProp(startElem , inNameProp, inLabel).
     startElem = startElem + 1.
  end.
  
  method protected class propmap crProp(inKeyInt as int, inNameProp as char, inLabel as char):
    def var prop as class propmap no-undo.
    &Scop propNameReg inNameProp
    { utl/objreg.i prop propmap inKeyInt inNameProp inLabel}
    mapType:AddItem(prop, inKeyInt,inNameProp, inLabel).
    return prop.
  end method. 

end class.