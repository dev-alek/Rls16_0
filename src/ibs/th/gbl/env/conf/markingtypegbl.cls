/*
  $Revision:$
  $Author:$
  $Date:$
  $Workfile:$
  $Archive:$
  
  Автор: Рубан Дмитрий Андреевич 
  Дата создания: 9 янв. 2023 г.
  Author:  Ruban Dmitriy Andreevich
  Creation date: 9 янв. 2023 г.
  
  */

using Progress.Lang.*.
using ibs.th.gbl.sys.objth.

class ibs.th.gbl.env.conf.markingtypegbl inherits objth. 
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Настрока для хранения списков" get.
   
  
  define temp-table tt-conf no-undo
    field objNum  as integer 
    field ConfStr as character
    index objNum objNum
  .


  define variable vObjNum as integer no-undo.
  method public int GetNextObjNum ():
     vObjNum= vObjNum + 1.
     return vObjNum.
  end.  
  
  constructor public markingtypeGBl ():
    super().
  end constructor.

  
  method public logical AvialItem(iNumObj as integer, arg as char):
    define buffer tt-conf for tt-conf.
    find first tt-conf where tt-conf.objNum  eq iNumObj
                         and tt-conf.ConfStr eq arg
    no-error.
    return available tt-conf.

  end method.
    
  method public void AddItem(iNumObj as integer, arg as char):
    define buffer tt-conf for tt-conf.
    find first tt-conf where tt-conf.objNum  eq iNumObj
                         and tt-conf.ConfStr eq arg
    no-error.
    if not available tt-conf
    then do:
       create tt-conf.
       assign 
          tt-conf.objNum  = iNumObj
          tt-conf.ConfStr = arg
       .
    end.
  end method.  
  
  method public void delItem(iNumObj as integer, arg as char):
    define buffer tt-conf for tt-conf.
    find first tt-conf where tt-conf.objNum  eq iNumObj
                         and tt-conf.ConfStr eq arg
    no-error.
    if available tt-conf
    then do:
       delete tt-conf.
    end.
  end method.  
  
  method public void delItems(iNumObj as integer):

    define buffer tt-conf for tt-conf.
    
    repeat preselect each tt-conf where tt-conf.ObjNum eq iNumObj:
       find next tt-conf.
         delete tt-conf.
    end.
  end method.  
  
end class.