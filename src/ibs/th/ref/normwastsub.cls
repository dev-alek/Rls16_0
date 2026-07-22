 
/*------------------------------------------------------------------------
   File        : normwastsub
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : asmorozov
   Created     : Wed Oct 10 18:13:11 MSK 2018
   Notes       : 
 ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.ref.*.
using ibs.th.gbl.storage.* from propath.
block-level on error undo, throw.


class ibs.th.ref.normwastsub: 
  { gbl/attr-lib.i class}
  
  define property ParGdsOAttr as class ibs.th.ref.pargdsoattr no-undo get. set.

  define property NormalWastageWinter as decimal no-undo init 0 get. set. /*ест. убыль зимой*/
  define property NormalWastageSummer as decimal no-undo init 0 get. set. /*ест. убыль летом*/
  define property NormalWastageTransWinter as decimal no-undo init 0 get. set. /*ест. убыль зимой*/
  define property NormalWastageTransSummer as decimal no-undo init 0 get. set. /*ест. убыль летом*/
  define property NormalWastageDate as decimal no-undo init 0 get. set. /*ест. убыль на указанную дату если p-date не ?*/
  define property NormalWastageTransDate as decimal no-undo init 0 get. set. /*ест. убыль на указанную дату если p-date не ?*/
  
  define property BeginWinter as date no-undo get. set. /*дата начала зимнего периода*/
  define property BeginSummer as date no-undo get. set. /*дата начала летнего периода*/

  define property IsDecommissioned as logical no-undo get. set. 

  define property NormWastS as decimal init 0.0 no-undo
    get.
    set.

  define property NormWastW as decimal init 0.0 no-undo
    get.
    set.  

  define property NormWastDays as decimal init 0.0 no-undo
    get.
    private set.

  define property NormalWastageHdnler as class ibs.th.gbl.storage.normwast no-undo
    get.
    private set.

  /*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    
  constructor public normwastsub (  ):
    
    ParGdsOAttr = new pargdsoattr ().
    NormalWastageHdnler =  new normwast ().
    
  end constructor.
  
  method public void FillNormWast ():
    
    def var objNormWastSub as class normwastsub no-undo.
    objNormWastSub = this-object.
    &scop proc-name gds-o-normal-wastage-value
    {&run_proc_attr-lib}
      (input-output objNormWastSub
      ) .
    
    NormalWastageHdnler:RegDocPeriod(objNormWastSub:ParGdsOAttr:FromInvDate, objNormWastSub:ParGdsOAttr:ToInvDate, objNormWastSub:ParGdsOAttr:FromInvFQKg).

  end.
  
  method public void CalcWastNorm ():

    NormWastS = 0.
    NormWastW = 0.
    
    NormalWastageHdnler:CalcWastNorm (this-object).
    NormWastDays = NormWastS + NormWastW.
    
  end.

end class.