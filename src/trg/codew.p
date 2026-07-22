block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

*/

&Glob main-tbl code
trigger procedure for write of ub.{&main-tbl}
   new buffer new-{&main-tbl}
   old buffer old-{&main-tbl}
   .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo init "Тригер изменение {&main-tbl}". 
{ trg/trghistnws.i 
  &hist = yes 
  &seqnamehist = "s-c-code"
}

define buffer buf_code for code.
define buffer buf_code_parent for code.
define variable mparent as character no-undo.
define variable mcode   as character no-undo.
define variable mCodeValue as character no-undo.
define variable vErrorMsg  as character no-undo.
define stream   vErrorLog.

if new-{&main-tbl}.parent  ne ""
then do:
   if num-entries (new-{&main-tbl}.parent,{&delim-par}) > 1
   then do:
      mcode = entry(num-entries (new-{&main-tbl}.parent,{&delim-par}),
                    new-{&main-tbl}.parent,
                    {&delim-par}).
      mparent = substring (new-{&main-tbl}.parent,1 ,length (new-{&main-tbl}.parent) - length ({&delim-par} + mcode)).
   end.
   else
      mcode = new-{&main-tbl}.parent.
   find first buf_code where buf_code.parent eq mparent
                         and buf_code.code   eq mcode
   no-lock no-error.
   if not available buf_code
   then do:
      create buf_code.
      assign
         buf_code.code     = mcode
         buf_code.parent   = mparent
         buf_code.CodeName = mcode
         buf_code.nwsgbd   = new-{&main-tbl}.nwsgbd
         buf_code.nwsubd   = new-{&main-tbl}.nwsubd
         buf_Code.export_  = new-{&main-tbl}.export_
      .
   end. 
end.


if     new-{&main-tbl}.nwsgbd ne old-{&main-tbl}.nwsgbd
   and new-{&main-tbl}.nwsubd ne old-{&main-tbl}.nwsubd
   then 
do:
   for each buf_code where buf_code.parent begins new-{&main-tbl}.code
      exclusive-lock:
      buf_code.nwsgbd = new-{&main-tbl}.nwsgbd.
      buf_code.nwsubd = new-{&main-tbl}.nwsubd.
   end.
end.

if old-{&main-tbl}.code ne new-{&main-tbl}.code
then do:
   for each buf_code where buf_code.parent eq old-{&main-tbl}.parent + {&delim-par} + old-{&main-tbl}.code  
      exclusive-lock:
      buf_code.parent = new-{&main-tbl}.parent + {&delim-par} + new-{&main-tbl}.code.
   end.
end.
if new-{&main-tbl}.parent begins "MarkType" then
do:
    vErrorMsg = "".
    if new-{&main-tbl}.code      = "" or
       new-{&main-tbl}.codevalue = "" or
       new-{&main-tbl}.codename  = "" or
       new-{&main-tbl}.misc1     = "" or
       new-{&main-tbl}.misc2     = "" or
       new-{&main-tbl}.misc3     = "" or
       new-{&main-tbl}.misc4     = "" then
    do:
       vErrorMsg = substitute("Не все обязательные поля заполнены. Запись: 
             код «&1» значение «&2» наименование «&3» родитель «&4»" ,
	     new-{&main-tbl}.code,
	     new-{&main-tbl}.codevalue,
	     new-{&main-tbl}.codename,
	     new-{&main-tbl}.parent  ).
	    end.
    if vErrorMsg = "" and not new(new-{&main-tbl}) and 
       new-{&main-tbl}.codevalue <> old-{&main-tbl}.codevalue then
    do:
       vErrorMsg = substitute(
         "Обнаружено совпадение по коду типа марки 
	  Запись: код «&1», значение «&2», наименование «&3», родитель «&4»." ,
	     old-{&main-tbl}.code,
	     old-{&main-tbl}.codevalue,
	     old-{&main-tbl}.codename,
	     old-{&main-tbl}.parent
	     ). 
    end.
    if vErrorMsg = ""  then
    do:
       find first buf_code where 
                  buf_code.parent    =  new-{&main-tbl}.parent
              and buf_code.code      <> new-{&main-tbl}.code
              and buf_code.codevalue =  new-{&main-tbl}.codevalue
            no-lock no-error.
         if avail buf_code then     
           vErrorMsg = substitute(
            "Обнаружено совпадение по значению типа марки.
            В БД уже существует тип марки: «&2», «&1», «&3», «&4». 
            Вы пытаетесь загрузить:        «&5», «&6», «&7», «&8». ",
	    buf_code.codevalue,     
	    buf_code.code,          
	    buf_code.codename,        
	    buf_code.parent,          
	    new-{&main-tbl}.code,     
	    new-{&main-tbl}.codevalue,
	    new-{&main-tbl}.codename, 
	    new-{&main-tbl}.parent   ).    
         end.
    
    if vErrorMsg <> "" then
    do:
       output stream vErrorLog to log_marktype.txt.
       put stream vErrorLog unformatted
         vErrorMsg skip
       .
       output stream vErrorLog close.
       return error vErrorMsg.
    end.
    else 
    do:
      if not new(new-{&main-tbl}) then
        assign
          new-{&main-tbl}.codevalue = old-{&main-tbl}.codevalue    
          new-{&main-tbl}.misc1 = old-{&main-tbl}.misc1    
        .
    end.
    { gbl/objserref.i }
end.

if g#db-num <> 0 and 
   new-{&main-tbl}.parent <> "" and
   not new-{&main-tbl}.parent begins "Versions" then
do:  /* создадим запись версии справочника  */
   def var vi    as int no-undo.
   mParent = substitute("Versions&1&2",{&delim-par},0).
   mcode = new-{&main-tbl}.parent.
   find first buf_code where
              buf_code.parent = mParent
          and buf_code.code = new-{&main-tbl}.parent
        no-lock no-error.
   if not avail buf_code then
   do:
     vi = num-entries(new-{&main-tbl}.parent,{&delim-par}).
     do while vi > 1 and not avail buf_code :
        vi = vi - 1.
        if r-index(mcode,{&delim-par}) > 0
        then   
           mcode = substring(mcode,1,r-index(mcode,{&delim-par}) - 1).
        find first buf_code where
              buf_code.parent = mParent
          and buf_code.code = mcode
        no-lock no-error.
      end.
   end.
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
             and buf_code.code   = mcode
           no-error.
      if not avail buf_code then
      do:
         find first buf_code_parent where
                    buf_code_parent.parent = ""
                and buf_code_parent.code = mcode
              no-error.
         create buf_code.
         assign
            buf_code.parent    = mParent
            buf_code.code      = mcode
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
end.

if    (    g#db-num eq 0 
   and new-{&main-tbl}.nwsgbd )
   or (    g#db-num ne 0 
   and new-{&main-tbl}.nwsubd )
   then 
do:
{ trg/trghistnws.i 
     &nws  = yes
   }
end.
