/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ДНЦ

Автор: Чернова Светлана Александровна
Дата создания: 06/08/06
Author: Svetlana Chernova
Creation date: 06/08/06

*/
define temp-table locb-utd no-undo like  ub.utd.
define temp-table locb-utd-attr no-undo like  ub.utd-attr.
define temp-table locb-utd-lines no-undo like  ub.utd-lines.
define temp-table locb-utd-lines-attr no-undo like  ub.utd-lines-attr.
define temp-table locb-utd-marking-lines no-undo like  ub.utd-marking-lines.
define temp-table locb-utd-marking-lines-attr no-undo like  ub.utd-marking-lines-attr.
define temp-table locb-utd-err no-undo like  ub.utd-err.
define temp-table locb-utd-err-attr no-undo like  ub.utd-err-attr.
define temp-table locb-marking no-undo like  ub.marking.
define temp-table locb-marking-attr no-undo like  ub.marking-attr.
define variable gtin as character no-undo.
{ gbl/tmprecid.i}
{ utlcomp/pikey.i }
{ utl/gtin.i }
define variable mySeqUtd as int64 no-undo init ?.
procedure MySeqForUtd:
   define input  parameter iTable       as character no-undo.
   define input  parameter iseqnamehist as character no-undo.
   define input  parameter idb-name     as character no-undo.
   define output parameter Oseq         as int64 no-undo.
   if iTable begins "utd"
   then do:
      if myseqUtd eq ?
      then 
         myseqUtd = dynamic-next-value(iseqnamehist,idb-name).
      Oseq = myseqUtd.
   end.
   else
      Oseq = ?. 
   return.
end.

