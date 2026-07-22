block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: xmlfdoc.p $
$Archive: str/xmlfdoc.p $

Выгрузка платежа в формате xml

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/23/04
Author: Bakhtadze Natalya
Creation date: 04/23/04

*/

define input parameter p-host-code       like ub.fin-doc.host-code no-undo .
define input parameter p-fin-doc-code    like ub.fin-doc.fin-doc-code no-undo.
define input-output parameter paroutput-file    as   character           no-undo.
define input parameter p-first-document  as logical no-undo .
define input parameter p-last-document   as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: xmlfdoc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/xmlfdoc.p $":U .
define variable vss-description as character no-undo init "Выгрузка платежа в формате xml".
define variable varr-b  as character no-undo.
define variable vartype as character no-undo.

define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .


{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ str/xml-def.i  }
{ str/xmlfdoc0.i "def" "ONE" }

define stream fin-doc-out.
if paroutput-file = ?  or
   paroutput-file = ""
   then do:
   output stream fin-doc-out to value ("./" + "f":U + string(p-fin-doc-code) + ".tmp").
   run write-string in this-procedure
     (input '<?xml version="1.0" encoding="windows-1251"?>':u + {&new-line} + '<root>':u + {&new-line}
     ).
end.
else do:
  if p-first-document then do:
    output stream fin-doc-out to value (paroutput-file).
    run write-string in this-procedure
      (input '<?xml version="1.0" encoding="windows-1251"?>':u + {&new-line} + '<root>':u + {&new-line}
      ).
  end.
  else do:
    output stream fin-doc-out to value(paroutput-file) append.
  end.
end.
 find first buf_fin-doc no-lock where
           buf_fin-doc.host-code = p-host-code
       AND buf_fin-doc.fin-doc-code = p-fin-doc-code no-error .
if not available buf_fin-doc then do:
  return error substitute ("Не найден финансовый документ: фирма &1 вн номер &2", p-host-code, p-fin-doc-code).
end.
{ str/xmlfdoc0.i run "ONE" }

if paroutput-file = ?  or
   paroutput-file = "" then do:
   run write-string in this-procedure
     (input '</root>':u + {&new-line}).
end.
else do:
  if p-last-document then do:
    run write-string in this-procedure
      (input '</root>':u + {&new-line}).
  end.
end.
output stream fin-doc-out close.
if paroutput-file = ?  or
   paroutput-file = "" then do:
  if search ("./" + "f":U + string(p-fin-doc-code) + ".xml") <> ? then do:
     os-delete value ("./" + "f":U + string(p-fin-doc-code) + ".xml").
  end.
  os-copy value ("./" + "f":U + string(p-fin-doc-code) + ".tmp") value ("./" + "f":U + string(p-fin-doc-code) + ".xml").
  os-delete value ("./" + "f":U +  string(p-fin-doc-code) + ".tmp").
  run gbl/filename.p (
                  input "./" + "f":U + string(p-fin-doc-code) + ".xml"
                  ,output paroutput-file
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .
end.
procedure write-string :
 define input parameter parstring as character no-undo.
 put stream fin-doc-out unformatted parstring.
end.