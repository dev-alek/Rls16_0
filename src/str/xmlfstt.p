block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: xmlfstt.p $
$Archive: str/xmlfstt.p $

Выгрузка банковской выписки в формате xml

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/23/04
Author: Bakhtadze Natalya
Creation date: 04/23/04

*/

define input parameter p-host-code       like ub.fin-statement.host-code no-undo .
define input parameter p-sttm-code    like ub.fin-statement.sttm-code no-undo.
define input-output parameter paroutput-file    as   character           no-undo.
define input parameter p-first-document  as logical no-undo .
define input parameter p-last-document   as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: xmlfstt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/xmlfstt.p $":U .
define variable vss-description as character no-undo init "Выгрузка банковской выписки в формате xml".
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
{ str/xmlfstm0.i "def" "ONE" }

define stream fin-sttm-out.
if paroutput-file = ?  or
   paroutput-file = ""
   then do:
   output stream fin-sttm-out to value ("./" + "fs":U + string(p-sttm-code) + ".tmp").
   run write-string in this-procedure
     (input '<?xml version="1.0" encoding="windows-1251"?>':u + {&new-line} + '<root>':u + {&new-line}
     ).
end.
else do:
  if p-first-document then do:
    output stream fin-sttm-out to value (paroutput-file).
    run write-string in this-procedure
      (input '<?xml version="1.0" encoding="windows-1251"?>':u + {&new-line} + '<root>':u + {&new-line}
      ).
  end.
  else do:
    output stream fin-sttm-out to value(paroutput-file) append.
  end.
end.
 find first buf_fin-statement no-lock where
           buf_fin-statement.host-code = p-host-code
       AND buf_fin-statement.sttm-code = p-sttm-code no-error .
if not available buf_fin-statement then do:
  return error substitute ("Не найдена выписка: фирма &1 вн номер &2", p-host-code, p-sttm-code).
end.
{ str/xmlfstm0.i run "ONE" }

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
output stream fin-sttm-out close.
if paroutput-file = ?  or
   paroutput-file = "" then do:
  if search ("./" + "fs":U + string(p-sttm-code) + ".xml") <> ? then do:
     os-delete value ("./" + "fs":U + string(p-sttm-code) + ".xml").
  end.
  os-copy value ("./" + "fs":U + string(p-sttm-code) + ".tmp") value ("./" + "fs":U + string(p-sttm-code) + ".xml").
  os-delete value ("./" + "fs":U +  string(p-sttm-code) + ".tmp").
  run gbl/filename.p (
                  input "./" + "fs":U + string(p-sttm-code) + ".xml"
                  ,output paroutput-file
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .
end.
procedure write-string :
 define input parameter parstring as character no-undo.
 put stream fin-sttm-out unformatted parstring.
end.