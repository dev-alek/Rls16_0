block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Ростовцев Александр 
Дата создания: 04.09.2024
Author:  Rostovtsev Aleksandr
Creation date: 04.09.2024

Утилита устанавливает версию (дату/время) справочника MarkType для текущей УБД
*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ utl/runpro.i }
{ cmp/trg-def.i  } 
/*{ cmp/library.i  }*/
/*{ cmp/str-glbl.i }*/

&glob main-tbl code
define variable mParent    as character no-undo.
define variable mCodeValue as character no-undo.
define buffer   buf_code for ub.code.
define buffer   buf_code_parent for ub.code.

   mParent = substitute("Versions&1&2",{&delim-par},0).
   find first buf_code where
              buf_code.parent = mParent
          and buf_code.code = "MarkType"
        no-lock no-error.
   if avail buf_code then
   do:
      mCodeValue = buf_code.codevalue.
      find first buf_code where
                 buf_code.parent = "Versions"
             and buf_code.code = string(g#db-num)
           no-error.
      if not avail buf_code then
      do:
         create buf_code.
         assign
            buf_code.parent    = "Versions"
            buf_code.code      = string(g#db-num)
            buf_code.CodeName  = substitute("Версии справочников на БД &1",g#db-num)
            buf_code.export_   = yes
            buf_code.status_   = 0
            buf_code.nwsubd    = yes
         . 
         validate buf_code no-error.
         if error-status:error 
           then return error error-status :get-message(1). 
         run nws/cr-route.p (
            input {&send-tbl},
            input {&table_{&main-tbl}},
            input (buffer buf_code:handle),
            input "0" ) no-error.
         if error-status :error 
           then return error error-status :get-message(1). 
      end.

      mParent = substitute("Versions&1&2",{&delim-par},g#db-num).
      find first buf_code where
                 buf_code.parent = mParent
             and buf_code.code = "MarkType"
           no-error.
      if not avail buf_code then
      do:
         find first buf_code_parent where
                    buf_code_parent.parent = ""
                and buf_code_parent.code = "MarkType"
              no-error.
         create buf_code.
         assign
            buf_code.parent    = mParent
            buf_code.code      = "MarkType"
            buf_code.CodeName  = buf_code_parent.codename
            buf_code.export_   = yes
            buf_code.status_   = 0
            buf_code.nwsubd    = yes
         .    
      end.
      if buf_code.codevalue <> mCodeValue then
      do:
         buf_code.codevalue = mCodeValue.
         validate buf_code no-error.
         if error-status:error 
           then return error error-status :get-message(1). 
           
         run nws/cr-route.p (
            input {&send-tbl},
            input {&table_{&main-tbl}},
            input (buffer buf_code:handle),
            input "0" ) no-error.
         if error-status :error 
           then return error error-status :get-message(1). 
      end.   
   end. 
   
message "Успешно!" view-as alert-box. 
