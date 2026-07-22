/*
RubanDa

15.03.2025
ibs/th/ref/code/objcash.p

Справочник касс

Автор: Рубан Дмитрий Андреевич
Дата создания: 01.05.2023

*/
{ cmp/str-glbl.i }
{ ref/codepar.i }
{ cmp/trg-def.i }

{ gbl/getcntxt.i def }
 { gbl/getcntxt.i get }



define variable vss-revision    as character no-undo init "Нету вроде как":U .
define variable vss-author      as character no-undo init "RubanDA":U .
define variable vss-date        as character no-undo init "15.03.2025":U .
define variable vss-workfile    as character no-undo init "ibs/th/ref/code/objcash.p":U .
define variable vss-archive     as character no-undo init "objcash.p":U .
define variable vss-description as character no-undo init "Кассы по регионам".
{ cmp/vssrevis.i }
define variable mCodeTrg as class ibs.th.ref.code.code_trg no-undo.
    
mCodeTrg = new ibs.th.ref.code.code_trg( /*if    g#db-num eq 0
                                        then {&update}
                                        else*/ {&lookup}).

mCodeTrg:formLable(1, 1, "Регион").
mCodeTrg:formLable(1, 2, "Наименование").
mCodeTrg:formLable(1, 3, ?).

mCodeTrg:formLable(1, 1, "Регион").
mCodeTrg:formLable(1, 2, "Наименование").
mCodeTrg:formLable(1, 3, ?).

mCodeTrg:formLable(2, 1, "Номер магазина").
mCodeTrg:formLable(2, 2, "Наименование").

mCodeTrg:formLable(3, 1, "Номер кассы").

mCodeTrg:parparentproc = Parparentproc.


mCodeTrg:menuHandle = this-procedure.

mCodeTrg:addMenu(1, "Экспорт и импорт", "Экспорт в xml,Экспорт дерева,Импорт из xml").

mCodeTrg:parent = left-trim(iparent + {&delim-par} + icode,{&delim-par}).
mCodeTrg:startlevel = num-entries(mCodeTrg:parent,{&delim-par}).

mCodeTrg:title = "Справочник касс".
mCodeTrg:MaxLevel = 3.
mCodeTrg:brwcode().

finally:
   delete object mCodeTrg.
end finally. 

procedure menuitem_1_1: 
   define input  parameter iBuff as handle no-undo.
   run bge/cashobjexp.p no-error.
   if error-status:error
   then
      message return-value skip
              error-status:get-message (1)
      view-as alert-box.
end.
procedure menuitem_1_2: 
   define input  parameter iBuff as handle no-undo.
   run bge/cashobjtreeexp.p no-error.
   if error-status:error
   then
      message return-value skip
              error-status:get-message (1)
      view-as alert-box.
end.

procedure menuitem_1_3: 
   define input  parameter iBuff as handle no-undo.
   define variable VError as character no-undo.
   run bge/codeimp.p no-error.
   if error-status:error
   then
      message return-value skip
              error-status:get-message (1)
      view-as alert-box.
end.
