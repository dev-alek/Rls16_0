block-level on error undo, throw.
/*

$Revision: f29df1d5f130, 3104, rls $
$Author: DRuban $
$Date: Вт авг 09 09:15:01 2022 +0300 $
$Workfile: free-mark.p $
$Archive: utl/free-mark.p $

Выравнивание статусов марок в свободной зоне

Автор: Шкляр Елена
Дата создания: 07/23/08
Author: Shklyar Elena
Creation date: 07/23/08



*/
using ibs.th.str.marking.sts.*.

define variable vss-revision as character no-undo init "$Revision: f29df1d5f130, 3104, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Вт авг 09 09:15:01 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: free-mark.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/free-mark.p $":U .
define variable vss-description as character no-undo init "Выравнивание статусов марок в свободной зоне".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ utl/gtin.i }
define buffer buf_marking-lines for ub.marking-lines .
define buffer bf_marking-lines for ub.marking-lines .
define buffer buf_marking       for ub.marking .
define variable ungroup as logical   no-undo .
define variable v-marking as character no-undo .
define var      v-mark  as character no-undo .
def var Marking as class mark no-undo .
{ gbl/objsrv.i }
Marking = ObjSrv:Env:Marking:Sts:Mark .

run gbl/d-prompt.w (
  'title=':u + "Ввод марок" + '\':u
  + 'text1=':u + "Введите марку:" + '\':u
  + 'format=' + "X(50)" + '\':u
  + 'type=' + {&type-char} + '\':u
  + 'fillin_row=3\':u
  + 'fillin_col=6\':u
  + 'fillin_width=50\':u
  + 'fillin_height=1\':u
  + 'max-chars=50\':u     /*- максимальное количество символов для редактора*/
  + 'readonly=no\':u
  , input-output v-mark
  ).
if v-mark = "" then 
do:
  message "По всем маркам запустить утилиту?"
    view-as alert-box question buttons yes-no update ungroup.
  if not ungroup then 
  do:
  return .
  end.
end.

if v-mark <> "" then do:
v-marking = GetCodeIdent(v-mark) .
end.
    for each buf_marking-lines exclusive-lock where buf_marking-lines.mark begins v-marking and buf_marking-lines.out-code = {&free-code}:
          for first buf_marking exclusive-lock where buf_marking.mark begins buf_marking-lines.mark:
            buf_marking.sts = Marking:FreeZone:KeyIntDB .
          end.   
    end. 
    message "Утилита отработала"
      view-as alert-box.
  
