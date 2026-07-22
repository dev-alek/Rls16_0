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



define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
define variable mCodeTrg as class ibs.th.ref.code.code_trg no-undo.
    
mCodeTrg = new ibs.th.ref.code.code_trg(if    g#db-num eq 0 
                                           or imode    ne {&update} 
                                        then imode 
                                        else {&lookup}).

mCodeTrg:formLable(1, 1, "Код").
mCodeTrg:formLable(1, 2, "Наименование").
mCodeTrg:formLable(1, 3, ?).
/*mCodeTrg:Mode = .*/
mCodeTrg:parparentproc = Parparentproc.
mCodeTrg:chek-erpRN = yes.
/*mCodeTrg:MaxLevel = mCodeTrg:startlevel.*/
mCodeTrg:menuHandle = this-procedure.
if v-cntxt-db-num ne 0 or mCodeTrg:get1CERP()
then
   mCodeTrg:addMenu(1, "Экспорт и импорт", ",Экспорт в Excel,").
else
   mCodeTrg:addMenu(1, "Экспорт и импорт", "Запросить настройки с касс,Экспорт в Excel,Импорт из Excel").
mCodeTrg:parent = left-trim(iparent + {&delim-par} + icode,{&delim-par}).
mCodeTrg:startlevel = num-entries(mCodeTrg:parent,{&delim-par}).
/*find first code where code.parent eq iparent*/
/*                  and code.code   eq icode  */
/*                  no-lock no-error.         */
/*if available code                           */
/*then mCodeTrg:title = code.codename.        */
mCodeTrg:title = "Устройства".
mCodeTrg:brwcode().

finally:
   delete object mCodeTrg.
end finally. 

procedure menuitem_1_1: 
   define input  parameter iBuff as handle no-undo.
   define variable vList as character no-undo init "cashp1i,cashp2i".
   if vList ne ""
   then 
      run str/diallog.w (
            input parparentproc
          , input this-procedure
          , input "str/send-all.p":U
          , input ( v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + 'U':U + {&delim-par} + vList + {&delim-par} + 'Получение параметров кассы':U)
          , input ? /*p-auto-go*/
          , input "":U
          , input substitute("Получение параметров кассы")
        ) no-error.
end.

procedure menuitem_1_2: 
   define input  parameter iBuff as handle no-undo.
   run bge/cashparexp.p no-error.
   if error-status:error
   then
      message return-value skip
              error-status:get-message (1)
      view-as alert-box.
end.

procedure menuitem_1_3: 
   define input  parameter iBuff as handle no-undo.
   run bge/cashparImp.p no-error.
   if error-status:error
   then
      message return-value skip
              error-status:get-message (1)
      view-as alert-box.
end.
