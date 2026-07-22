block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: trdcat-v.p $
$Archive: gbl/trdcat-v.p $

Считать значение атрибута документа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/10/05
Author: Bakhtadze Natalya
Creation date: 10/10/05

*/

define input  parameter p-doc-code like ub.doc-attr.doc-code   no-undo .
define input  parameter p-code     like ub.doc-attr.attr-code  no-undo .
define output parameter p-value    like ub.doc-attr.attr-value no-undo .
define output parameter p-type     as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: trdcat-v.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/trdcat-v.p $":U .
define variable vss-description as character no-undo init "Считать значение атрибута документа".
{ cmp/vssrevis.i "substitute('&1|&2|&3',p-doc-code,p-code)" }
{ cmp/trg-def.i  }
{ str/trdcalib.i }

do
on error undo, return error return-value
:
  { str/tdat-val.i
    p-doc-code
    p-code
    p-value
    p-type
    no-error
  }
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'dat-val':u skip
        "Документ" p-doc-code skip
        "Атрибут" p-code skip
        "Значение" p-value skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    undo, return error return-value .
  end.

end.
