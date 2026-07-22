block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: krrhold.p $
$Archive: utl/krrhold.p $

сделать из МФ простой

Автор: Чернова Светлана Александровна
Дата создания: 03/06/09
Author: Svetlana Chernova
Creation date: 03/06/09

*/
define input  parameter  p-doc-code as character no-undo .
on write of ub.trn-doc         override do: end.

find first ub.trn-doc exclusive-lock
     where ub.trn-doc.doc-code = p-doc-code no-error .
     if error-status :error then do:
         message
           error-status :get-message(1) skip
           return-value skip
           ""
           view-as alert-box error
         .
         return .
     end.

  assign
    ub.trn-doc.hold-doc-code-child = "no-hold"
    ub.trn-doc.hold-doc-code-parent = "no-hold"
  .

 message 'все' view-as alert-box information .
