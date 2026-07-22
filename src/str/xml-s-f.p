block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: xml-s-f.p $
$Archive: str/xml-s-f.p $

Выгрузка счета-фактуры в формате xml

Автор: Кочетков Михаил Юрьевич
Дата создания: 11/18/05
Author: Michael Kochetkov
Creation date: 11/18/05

*/

DEFINE INPUT  PARAMETER parparentproc        AS WIDGET-HANDLE        NO-UNDO.
define input parameter p-host-code   like ub.schet-fact-doc.host-code no-undo .
define input parameter p-doc-code    like ub.schet-fact-doc.doc-code no-undo.
define input-output parameter paroutput-file    as   character           no-undo.
define input parameter p-first-document  as logical no-undo .
define input parameter p-last-document   as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: xml-s-f.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/xml-s-f.p $":U .
define variable vss-description as character no-undo init "Выгрузка счета-фактуры в формате xml".
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
{ str/xml-s-f0.i "def" }

  define variable g#db-num as integer   no-undo .
  run get-db-num  in parParentProc ( output g#db-num ).

  define stream contr-out.
  if paroutput-file = ?  or paroutput-file = "" then do:
    output stream contr-out to value ("./" + "f":U + string(p-doc-code) + ".tmp").
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
  find first buf_schet-fact-doc no-lock
    where buf_schet-fact-doc.host-code = p-host-code
      AND buf_schet-fact-doc.doc-code  = p-doc-code
  no-error .
  if not available buf_schet-fact-doc then do:
    return error substitute ("Не найден счет-фактура: фирма &1 номер &2", p-host-code, p-doc-code).
  end.
  { str/xml-s-f0.i run "ONE" }

  if paroutput-file = ?  or paroutput-file = "" then do:
    run write-string in this-procedure (input '</root>':u + {&new-line}).
  end.
  else do:
    if p-last-document then  run write-string in this-procedure (input '</root>':u + {&new-line}).
  end.
  output stream contr-out close.

  if paroutput-file = ?  or paroutput-file = "" then do:
    if search ("./" + "f":U + string(p-doc-code) + ".xml") <> ? then do:
      os-delete value ("./" + "f":U + string(p-doc-code) + ".xml").
    end.
    os-copy value ("./" + "f":U + string(p-doc-code) + ".tmp") value ("./" + "f":U + string(p-doc-code) + ".xml").
    os-delete value ("./" + "f":U +  string(p-doc-code) + ".tmp").
    run gbl/filename.p (
                  input "./" + "f":U + string(p-doc-code) + ".xml"
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