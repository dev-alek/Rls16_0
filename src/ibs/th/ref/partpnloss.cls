 
 /*------------------------------------------------------------------------
    File        : parplnloss
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : asmorozov
    Created     : Fri Oct 12 21:49:06 MSK 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
block-level on error undo, throw.


class ibs.th.ref.partpnloss:

  define property PlCode as integer no-undo
    get.
    set.
 
 define property AutoNum as character no-undo
    get.
    set.
 
 define property SecNum as character no-undo
    get.
    set.
 
  define property GdsCode as integer no-undo
    get.
    set.

  define property ObjType as character no-undo
    get.
    set.

  define property ObjCode as integer no-undo
    get.
    set.

  define property OnDate as date init ? no-undo
    get.
    set.

  define property PLNormLoss as decimal init 0 no-undo
    get.
    set.

  define property AutoNormLoss as decimal init 0 no-undo
    get.
    set.
    
  define property GroupNP as character no-undo
    get.
    set.

end class.