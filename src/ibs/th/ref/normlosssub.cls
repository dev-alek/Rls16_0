/*

$Revision: 41853a5ca5bc, 1585, rls $
$Author: ASMorozov $
$Date: Tue Nov 06 04:41:36 2018 +0300 $
$Workfile: normlosssub.cls $
$Archive: ibs/th/ref/normlosssub.cls $

Сущность TH normloss


Автор: Морозов Александр Сергеевич
Дата создания: 04/23/18
Author: Morozov Alexandr
Creation date: 04/23/18


*/

using Progress.Lang.*.
using ibs.th.gbl.storage.*.
block-level on error undo, throw.

class ibs.th.ref.normlosssub implements ithsub: 
  
  define buffer bf_norm-loss for ub.norm-loss.

  define property Msg as character no-undo
    get.
    private set.

  define property ID as integer init ?  no-undo
    get.
    set.
    
  define property Type_ as integer no-undo
    get.
    set.  

  define property ClimGrp as character no-undo
    get.
    set.

  define property Position_ as character no-undo
    get.
    set.
    
  define property SecVol as character no-undo
    get.
    set.
    
  define property OilGrp as character no-undo
    get.
    set.

  define property Season as integer no-undo
    get.
    set.

  define property ValueLoss as decimal no-undo
    get.
    set.

  method public void setMsg( arg as character ):
    
    Msg = arg.
    
  end.


end class.