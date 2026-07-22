block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на изменение таблицы ub.marking

Автор: 
Дата создания: 
Author: 
Creation date: 

*/
&Glob main-tbl marking

TRIGGER PROCEDURE FOR WRITE OF ub.marking
   new buffer new-{&main-tbl}
   old buffer old-{&main-tbl}
   .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на изменение таблицы abc-analysis-doc-attr".

define buffer marking-attr  for ub.marking-attr.
define buffer marking-lines for ub.marking-lines.
define buffer marking-chk   for ub.marking-chk.
define buffer parentMarking for ub.marking.
define buffer c-Marking     for ub.c-marking.


{ trg/trghistnws.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

{ gbl/objsrv.i }
if new-{&main-tbl}.gds-code eq 0
then 
   new-{&main-tbl}.gds-code = ?.

/*run gbl/inidebug.p.*/
if not new(new-{&main-tbl}) then do:
   if    (old-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB
      or old-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
      or old-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB
      or old-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB
      or old-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:SaleWaitLock:KeyIntDB
      or old-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:ReturnLock:KeyIntDB
      or old-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:ReturnWaitLock:KeyIntDB
      or old-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB
      or old-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB)
   and
      not  (new-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB
         or new-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
         or new-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB
         or new-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB
         or new-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:SaleWaitLock:KeyIntDB
         or new-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:ReturnLock:KeyIntDB
         or new-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:ReturnWaitLock:KeyIntDB
         or new-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB
         or new-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
         or new-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
         or new-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:UsedInProduction:KeyIntDB
         or new-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:WrittenOff:KeyIntDB
         or new-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:Moved:KeyIntDB
         or new-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:DeliveryControl:KeyIntDB
         or new-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:Returned:KeyIntDB
         or new-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:OutOfInventory:KeyIntDB)
   then do:
/*  new-{&main-tbl}.sts = old-{&main-tbl}.sts.*/
      if old-{&main-tbl}.loc-key <> "" then
         new-{&main-tbl}.loc-key = old-{&main-tbl}.loc-key.
   end.
   if new-{&main-tbl}.sts <> old-{&main-tbl}.sts then do:
      new-{&main-tbl}.last-change = now.
   end .
   if new-{&main-tbl}.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB then do:
      new-{&main-tbl}.loc-key = "".
   end .

   if new-{&main-tbl}.mark <> old-{&main-tbl}.mark then do:
      for each marking-attr exclusive-lock 
         where marking-attr.mark = old-{&main-tbl}.mark:
               marking-attr.mark = new-{&main-tbl}.mark.
      end.
      for each marking-lines exclusive-lock 
         where marking-lines.mark = old-{&main-tbl}.mark:
               marking-lines.mark = new-{&main-tbl}.mark.
      end.
      for each marking-chk exclusive-lock 
         where marking-chk.mark = old-{&main-tbl}.mark:
               marking-chk.mark = new-{&main-tbl}.mark.
      end.
      for each c-marking where c-marking.mark eq old-{&main-tbl}.mark exclusive-lock:
               c-marking.mark = new-{&main-tbl}.mark.
      end.
      for each c-marking-attr where c-marking-attr.mark eq old-{&main-tbl}.mark exclusive-lock:
               c-marking.mark = new-{&main-tbl}.mark.
      end.
   end .  
end. 
else
   new-{&main-tbl}.last-change = now.
     
if new(new-{&main-tbl}) and new-{&main-tbl}.mark-parent <> "" then 
do:   /* при создании новой дочерней марки меняем статус марки как у родителя, если родитель продан или возвращен на кассу */
  for first parentMarking where
            parentMarking.mark = new-{&main-tbl}.mark-parent 
      no-lock:
    if can-do(objSrv:Env:Marking:Sts:Mark:Sale_Return_Wait,string(parentMarking.sts)) then
     new-{&main-tbl}.sts = parentMarking.sts.
  end.
end.


end. /* main-block */
{ trg/trghistnws.i 
  &hist = yes 
  &seqnamehist = "s-c-mark-chip-num"
}
if g#db-num <> 0 then 
do:
  { trg/trghistnws.i 
    &nws  = yes
    &notSendDel = yes
  }
end.

