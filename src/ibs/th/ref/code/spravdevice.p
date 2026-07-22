/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Шкляр Елена
Дата создания: 31 июля 2019 г.
Author:  Shklyar Elena
Creation date: 31 июля 2019 г.

*/
block-level on error undo, throw.
{cmp/str-glbl.i }
{ ibs\th\ref\code\codepar.i }

define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
define variable mCodeTrg as class ibs.th.ref.code.code_trg no-undo.
    
mCodeTrg = new ibs.th.ref.code.code_trg().

mCodeTrg:formLable(1, 1, "Код").
mCodeTrg:formLable(1, 2, "Наименование").
mCodeTrg:formLable(1, 4, "IP").
/*mCodeTrg:formLable(1, 5, "Дата").*/
mCodeTrg:MaxLevel = 1.

mCodeTrg:parent = left-trim(iparent + {&delim-par} + icode,{&delim-par}).
mCodeTrg:startlevel = num-entries(mCodeTrg:parent,{&delim-par}).
find first code where code.parent eq iparent
                  and code.code   eq icode
                  no-lock no-error.
if available code
then mCodeTrg:title = code.codename.
/*mCodeTrg:chek-erpRN = no.*/
mCodeTrg:brwcode().


finally:
   delete object mCodeTrg.
end finally. 