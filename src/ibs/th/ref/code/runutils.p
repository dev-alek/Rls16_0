/*
29.10.2025
ibs/th/ref/code/objcash.p

Справочник запуска утилит

Автор: Ростовцев Александр
Дата создания: 29.10.2025

*/
{ cmp/str-glbl.i }
{ ref/codepar.i }
{ cmp/trg-def.i }

{ gbl/getcntxt.i def }
 { gbl/getcntxt.i get }



define variable vss-revision    as character no-undo init "":U .
define variable vss-author      as character no-undo init "Sibintek-Soft":U .
define variable vss-date        as character no-undo init "29.10.2025":U .
define variable vss-workfile    as character no-undo init "ibs/th/ref/code/runutils.p":U .
define variable vss-archive     as character no-undo init "runutils.p":U .
define variable vss-description as character no-undo init "Справочник ~"Запуск утилит~"".
{ cmp/vssrevis.i }
define variable mCodeTrg as class ibs.th.ref.code.code_trg no-undo.
    
mCodeTrg = new ibs.th.ref.code.code_trg({&lookup}).

mCodeTrg:formLable(1, 1, "БД").
mCodeTrg:formLable(1, 2, "Наименование").
mCodeTrg:formLable(1, 3, ?).

mCodeTrg:formLable(2, 1, "Утилита").
mCodeTrg:formLable(2, 2, "Наименование").
mCodeTrg:formLable(2, 3, "Выполнение").

mCodeTrg:parparentproc = Parparentproc.


mCodeTrg:menuHandle = this-procedure.

mCodeTrg:parent = left-trim(iparent + {&delim-par} + icode,{&delim-par}).
mCodeTrg:startlevel = num-entries(mCodeTrg:parent,{&delim-par}).

mCodeTrg:title = "Справочник запуска утилит".
mCodeTrg:MaxLevel = 2.
mCodeTrg:brwcode().

finally:
   delete object mCodeTrg.
end finally. 
