block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: xmlcontr.p $
$Archive: str/xmlcontr.p $

Выгрузка договора в формате xml

Автор: Кочетков Михаил Юрьевич
Дата создания: 09/14/05
Author: Michael Kochetkov
Creation date: 09/14/05

*/

define input parameter p-host-code       like ub.contract.host-code no-undo .
define input parameter p-contract-code    like ub.contract.contract-code no-undo.
define input-output parameter paroutput-file    as   character           no-undo.
define input parameter p-first-document  as logical no-undo .
define input parameter p-last-document   as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: xmlcontr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/xmlcontr.p $":U .
define variable vss-description as character no-undo init "Выгрузка договора в формате xml".
define variable varr-b  as character no-undo.
define variable vartype as character no-undo.

define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .


{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/xml-def.i  }
{ str/xmlcont0.i "def" }

  define stream contr-out.
  if paroutput-file = ?  or paroutput-file = "" then do:
    output stream contr-out to value ("./" + "f":U + string(p-contract-code) + ".tmp").
    run write-string in this-procedure (input '<?xml version="1.0" encoding="windows-1251"?>':u + {&new-line} + '<root>':u + {&new-line} ).
  end.
  else do:
    if p-first-document then do:
      output stream contr-out to value (paroutput-file).
      run write-string in this-procedure (input '<?xml version="1.0" encoding="windows-1251"?>':u + {&new-line} + '<root>':u + {&new-line} ).
    end.
    else do:
      output stream contr-out to value(paroutput-file) append.
    end.
  end.
  find first buf_contract no-lock
    where buf_contract.host-code = p-host-code
      AND buf_contract.contract-code = p-contract-code
  no-error .
  if not available buf_contract then do:
    return error substitute ("Не найден договор: фирма &1 вн номер &2", p-host-code, p-contract-code).
  end.
  { str/xmlcont0.i run "ONE" }

  if paroutput-file = ?  or paroutput-file = "" then do:
    run write-string in this-procedure (input '</root>':u + {&new-line}).
  end.
  else do:
    if p-last-document then  run write-string in this-procedure (input '</root>':u + {&new-line}).
  end.
  output stream contr-out close.

  if paroutput-file = ?  or paroutput-file = "" then do:
    if search ("./" + "f":U + string(p-contract-code) + ".xml") <> ? then do:
      os-delete value ("./" + "f":U + string(p-contract-code) + ".xml").
    end.
    os-copy value ("./" + "f":U + string(p-contract-code) + ".tmp") value ("./" + "f":U + string(p-contract-code) + ".xml").
    os-delete value ("./" + "f":U +  string(p-contract-code) + ".tmp").
    run gbl/filename.p (
                  input "./" + "f":U + string(p-contract-code) + ".xml"
                  ,output paroutput-file
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .
  end.

  procedure write-string :
    define input parameter parstring as character no-undo.
    put stream contr-out unformatted parstring.
  end.