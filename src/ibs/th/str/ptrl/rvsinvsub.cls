 
 /*------------------------------------------------------------------------
    File        : rvsinvsub
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : asmorozov
    Created     : Tue Oct 16 23:46:26 MSK 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.gbl.storage.*.
block-level on error undo, throw.

class ibs.th.str.ptrl.rvsinvsub: 
  
  define property RvsCode as character no-undo
    get.
    set.

  define property ObjType as character no-undo
    get.
    set.

  define property ObjCode as integer no-undo
    get.
    set.

  define property PlCode as integer no-undo
    get.
    set.

  define property GdsCode as integer no-undo
    get.
    set.
  
  define property Diff as decimal no-undo
    get.
    set.
  
  define property MeteringErr as decimal no-undo
    get.
    set.

  define property NormalWastage as decimal no-undo
    get.
    set.

  define property TPNormalAuto as decimal no-undo
    get.
    set.

  define property TPNormalPl as decimal no-undo
    get.
    set.

  define property TPNormal as decimal no-undo
    get:
      return TPNormalAuto + TPNormalPl.
    end.

  define property MeterErrWast as decimal no-undo
    get.
    set.

  define property TPWast as decimal no-undo
    get.
    set.

  define property NaturWast as decimal no-undo
    get.
    set.
    
  define property RvsInvStrObj as class rvsinvstr no-undo
    get:
      if not valid-object ( RvsInvStrObj )
        then return new rvsinvstr ().
        else return RvsInvStrObj.
    end.
    set.
    
  define property DeficitOver as decimal no-undo
    get:
      return (absolute (Diff) - TPWast - NaturWast -  MeterErrWast) .
    end.

end class.