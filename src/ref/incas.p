block-level on error undo, throw.
{ ibs\th\ref\cashbookost.i } 
define input-output  parameter table for tt-cashBookOst bind.
define input  parameter iSummMax as decimal no-undo.
define output parameter OSumm as decimal no-undo.
define output parameter oBag as character no-undo.
define output parameter oMoney  as character no-undo.
define output parameter oOk     as logical no-undo.


define variable mincas as class ibs.th.ref.incas no-undo.
do trans:    
mincas = new ibs.th.ref.incas().
mincas:settt(input table tt-cashBookOst).
wait-for  mincas:ShowDialog() .
end.
if mincas:DialogResult = System.Windows.Forms.DialogResult:Ok
   then 
do:
   mincas:gettt(output table tt-cashBookOst).
   OSumm = mincas:mSumm.
   oBag = mincas:mosnbag.
   oMoney  = mincas:mMoney.
   oOk = yes.
end.
finally:
   delete object mincas.
end finally.