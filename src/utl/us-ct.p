block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: us-ct.p $
$Archive: utl/us-ct.p $

Пересчет накладной(для юзеров)

Автор: Суслов Алексей Юрьевич
Дата создания: 03/27/06
Author: Alexey Suslov
Creation date: 11/25/99

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter pardoc-code like trn-doc.doc-code.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: us-ct.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/us-ct.p $":U .
define variable vss-description as character no-undo init "Пересчет накладной(для юзеров)".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i  }
{ cmp/library.i  }
{ str/lib-trn.i  }

define variable v-clcdoc-vat-pc                     like doc-line.vat-pc           no-undo.
define variable v-clcdoc-slt-pc                     like doc-line.slt-pc           no-undo.

find first trn-doc where trn-doc.doc-code = pardoc-code no-error.
if not available trn-doc then do:
   message "Документ не найден!!!"
    view-as alert-box error buttons ok.
   return error.
end.
do transaction:
   run gbl/calc-trn.p (input parparentproc,input  recid(trn-doc)) no-error.
   if error-status:error then do:
      message "Ошибка при расчете документа!!!"
        view-as alert-box error buttons ok.
      undo, return error.
   end.
end.