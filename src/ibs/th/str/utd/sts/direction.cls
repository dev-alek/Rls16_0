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
using ibs.th.gbl.TypeMap.
using ibs.th.gbl.propmap.
using ibs.th.gbl.map.mapstring.
using ibs.th.gbl.sys.objth.
block-level on error undo, throw.

class ibs.th.str.utd.sts.direction inherits TypeMap:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Направление документов ЭДО" get.

  define public property Inbound as class propmap no-undo get. 
    protected set.
  define public property Outbound as class propmap no-undo get. 
    protected set.
  define public property Internal as class propmap no-undo get. 
    protected set.
    
  define public property DirectionMap as class mapstring no-undo get. 
    protected set.
    
  define public property CurrDirectionMapProp as class propmap no-undo 
  get:
    def var currP as class propmap no-undo. 
    currP = cast (DirectionMap:SubjectObjCurr, propmap) no-error.
    if currP = ? or error-status:error
    then do:
      "Залогируем".
      return ?.
    end.
    else return currP.
  end. 
 
  constructor public direction ():
    {utl\objreg.i DirectionMap mapstring true}
  
    Inbound  = crProp("Inbound", "входящий документ").
    Outbound = crProp("Outbound", "исходящий документ").
    Internal = crProp("Internal", "внутренний документ").
    
  end.

  

end class.
