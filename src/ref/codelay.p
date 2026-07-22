/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 31 июля 2019 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 31 июля 2019 г.

*/
{ cmp/str-glbl.i }
{ ref/codepar.i }

define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ utl/search.i }
find first code where code.parent eq iparent
                  and code.code   eq icode
                  no-lock no-error.
if     available code
   and code.procview ne ""
   and code.procview ne ?
   and SearchPFile(code.procview)  ne ?
then do:
   run value( code.procview) (Parparentproc, imode, code.parent , code.code,Code.CodeName).
end.
else do on error undo, leave:                  
   define variable mCodeTrg as class ibs.th.ref.code.code_trg no-undo.

   mCodeTrg = new ibs.th.ref.code.code_trg(imode).
   mCodeTrg:codeProcViewSet(iparent, icode).
   mCodeTrg:parent = left-trim(iparent + {&delim-par} + icode,{&delim-par}).
   mCodeTrg:startlevel = num-entries(mCodeTrg:parent,{&delim-par}).
   mCodeTrg:parparentproc = Parparentproc.
   if ititle ne "" and ititle ne ?
   then mCodeTrg:title = entry(1,ititle,{&delim-par}).
   else if available code
   then mCodeTrg:title = code.codename.
   if num-entries(ititle,{&delim-par}) > 1 then
     mCodeTrg:filter = entry(2,ititle,{&delim-par}).
   mCodeTrg:brwcode().
   finally:
       delete object mCodeTrg.
   end finally. 
end.
