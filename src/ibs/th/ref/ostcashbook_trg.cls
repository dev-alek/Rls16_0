 
 /*------------------------------------------------------------------------
    File        : ostcashbook_trg
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : druban
    Created     : Fri Nov 22 13:55:30 MSK 2019
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class ibs.th.ref.ostcashbook_trg: 
   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
      { ibs\th\ref\cashbookost.i }
   define variable mQuery   as handle  no-undo .
   define public property  ChekSumm as logical no-undo
   get():
     define buffer tt-cashBookOst for tt-cashBookOst.
     find first tt-cashBookOst where tt-cashBookOst.cashbookid eq 0 no-error.
     return not available tt-cashBookOst or not tt-cashBookOst.chang.
   end. 
   define public variable Summ as decimal no-undo.
     
   constructor public ostcashbook_trg (  ):
      super ().
      
   end constructor.
   
   method public void settt (input table tt-cashBookOst):
     
   end.
   method public void gettt (output table tt-cashBookOst):
     
   end.
   method public handle getQuery ():
      delete object mQuery no-error. // может быть еще не создана
      create query mQuery. 
      mQuery:set-buffers(buffer tt-cashBookOst:HANDLE). 
      mQuery:query-prepare("FOR EACH tt-cashBookOst").
      mQuery:query-open.
      return mQuery.
      
   end.
   method public decimal  cangCashbook ():
     if available tt-cashBookOst and tt-cashBookOst.ostrasch > 0
     then
        tt-cashBookOst.chang = not tt-cashBookOst.chang.
     return  getsumost().
   end.
   
   method public decimal  cangCashbookall (input IFLAG as logical):
     define buffer tt-cashBookOst for tt-cashBookOst.
     for each tt-cashBookOst where tt-cashBookOst.ostrasch > 0:
        tt-cashBookOst.chang = IFLAG.
     end.
     return  getsumost().
   end.
   
   method public decimal  getsumost ():
     define buffer tt-cashBookOst for tt-cashBookOst.
     define variable oSum as decimal no-undo.
     for each tt-cashBookOst where tt-cashBookOst.chang :
        oSum = oSum + tt-cashBookOst.ostrasch.
     end.
     Summ = osum.
     return oSum.
      
   end.
   
   destructor public ostcashbook_trg ( ):

   end destructor.

end class.