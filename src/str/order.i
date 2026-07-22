{ cmp/str-glbl.i {1}}

define variable mySeqOrder as int64 no-undo init ?.

procedure MySeqForOrder:
   define input  parameter iTable      as character no-undo.
   define input  parameter iSeqNameHist as character no-undo.
   define input  parameter iDbName     as character no-undo.
   define output parameter oSeq        as int64 no-undo.
   if iTable begins "order-"
   then do:
      if mySeqOrder eq ?
      then 
         mySeqOrder = dynamic-next-value(iSeqNameHist,iDbName).
      oSeq = mySeqOrder.
   end.
   else
      oSeq = ?. 
   return.
end.