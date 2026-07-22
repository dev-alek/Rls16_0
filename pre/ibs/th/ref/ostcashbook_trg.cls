using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.ref.ostcashbook_trg:
      define temp-table tt-cashBookOst no-undo
field chang      as logical
field cashbookid as int64
field cashbookname as character
field ost        as decimal
field ostrasch   as decimal
field osnpko     as decimal
field osnrko     as decimal
index pi cashbookid.
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
