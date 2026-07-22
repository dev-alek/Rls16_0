block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: xmladd.p $
$Archive: bge/xmladd.p $

Выгрузка Доп.расходов в формате xml

Автор: Хныкин Павел Андреевич
Дата создания: 01/14/08
Author: Pavel Khnykin
Creation date: 01/14/08

*/

define input parameter p-host-code       like ub.add-doc.host-code no-undo .
define input parameter p-doc-code        like ub.add-doc.doc-code no-undo.
define input-output parameter paroutput-file    as   character           no-undo.
define input parameter p-first-document  as logical no-undo .
define input parameter p-last-document   as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: xmladd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/xmladd.p $":U .
define variable vss-description as character no-undo init "Выгрузка ФО в формате xml".

define variable varr-b  as character no-undo.
define variable vartype as character no-undo.

define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .


{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ str/xml-def.i  }
{ bge/xmlad0.i "def" "ONE" }

define stream add-doc-out.
if paroutput-file = ?  or
   paroutput-file = ""
   then do:
   output stream add-doc-out to value ("./" + "ad":U + string(p-doc-code) + ".tmp").
   run write-string in this-procedure
     (input '<?xml version="1.0" encoding="windows-1251"?>':u + {&new-line} + '<root>':u + {&new-line}
     ).
end.
else do:
  if p-first-document then do:
    output stream add-doc-out to value (paroutput-file).
    run write-string in this-procedure
      (input '<?xml version="1.0" encoding="windows-1251"?>':u + {&new-line} + '<root>':u + {&new-line}
      ).
  end.
  else do:
    output stream add-doc-out to value(paroutput-file) append.
  end.
end.
 find first buf_add-doc no-lock where
            buf_add-doc.doc-code = p-doc-code no-error .
if not available buf_add-doc then do:
  return error substitute ("Не найден документ ДопРасхода: фирма &1 вн номер &2", p-host-code, p-doc-code).
end.
{ bge/xmlad0.i run "ONE" }

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
output stream add-doc-out close.
if paroutput-file = ?  or
   paroutput-file = "" then do:
  if search ("./" + "ad":U + string(p-doc-code) + ".xml") <> ? then do:
     os-delete value ("./" + "ad":U + string(p-doc-code) + ".xml").
  end.
  os-copy value ("./" + "ad":U + string(p-doc-code) + ".tmp") value ("./" + "ad":U + string(p-doc-code) + ".xml").
  os-delete value ("./" + "ad":U +  string(p-doc-code) + ".tmp").
  run gbl/filename.p
   (              input "./" + "ad":U + string(p-doc-code) + ".xml"
                  ,output paroutput-file
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .
end.
procedure write-string :
 define input parameter parstring as character no-undo.
 put stream add-doc-out unformatted parstring.
end.