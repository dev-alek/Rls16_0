/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Справочник "Кассовых параметров"

Автор: Рубан Дмитрий Андреевич
Дата создания: 01.05.2023

*/
{ cmp/str-glbl.i }
{ ref/codepar.i }
{ cmp/trg-def.i }

{ gbl/getcntxt.i def }
 { gbl/getcntxt.i get }
{cmp/gds-list.i gds-list def }


define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
define variable mCodeTrg as class ibs.th.ref.code.code_trg no-undo.
    
mCodeTrg = new ibs.th.ref.code.code_trg(
 {&add-def}
/*                                         imode*/
                                        ).

mCodeTrg:formLable(1, 1, "Код товара").
mCodeTrg:formLable(1, 2, "Наименование").
mCodeTrg:formLable(1, 3, "Кол-во").
mCodeTrg:formLable(1, 4, ?).
/*mCodeTrg:Mode = .*/
mCodeTrg:parparentproc = Parparentproc.
mCodeTrg:chek-erpRN = no.
/*mCodeTrg:MaxLevel = mCodeTrg:startlevel.*/
mCodeTrg:menuHandle = this-procedure.
mCodeTrg:addMenu(1, "Печать", "").

mCodeTrg:addMenu(2, "Меню", "Очистить список,Очистить список удаленных").
mCodeTrg:parent = left-trim(iparent + {&delim-par} + icode,{&delim-par}).
mCodeTrg:startlevel = num-entries(mCodeTrg:parent,{&delim-par}).
/*find first code where code.parent eq iparent*/
/*                  and code.code   eq icode  */
/*                  no-lock no-error.         */
/*if available code                           */
/*then mCodeTrg:title = code.codename.        */
mCodeTrg:MaxLevel = 1.
mCodeTrg:title = "Печать ценников".
mCodeTrg:brwcode().

finally:
   delete object mCodeTrg.
end finally. 

procedure menuitem_1: 
   define input  parameter iBuff as handle no-undo.
   empty temp-table gds-list.
   for each code where code.parent eq icode
                   and code.status_ eq {&bef-current-status-int} 
   no-lock:
      find first goods no-lock where
                 goods.gds-code = int(code.code) no-error .
      if available goods
      then do:
      
         create gds-list.
         buffer-copy goods to gds-list.
      end.
   end.
   if avail gds-list
   then
      run ibs/th/rep/tick-lst.p (input parparentproc, 
                                 input v-cntxt-obj-type, 
                                 input v-cntxt-obj-code, 
                                 input table gds-list).
                
end.

procedure menuitem_2_1: 
   define input  parameter iBuff as handle no-undo.
   for each code where code.parent eq icode 
   exclusive-lock:
      delete code.
   end.
      
end.

procedure menuitem_2_2: 
   define input  parameter iBuff as handle no-undo.
   for each code where code.parent eq icode
                   and code.status_ ne {&bef-current-status-int} 
   exclusive-lock:
      delete code.
   end.
      
end.

