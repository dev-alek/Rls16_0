block-level on error undo, throw.
/*

$Revision: f29df1d5f130, 3104, rls $
$Author: DRuban $
$Date: Вт авг 09 09:15:01 2022 +0300 $
$Workfile: gray-zone.p $
$Archive: utl/gray-zone.p $

Утилита для создания Серой зоны
Автор: Шкляр Елена
Дата создания: 07/23/08
Author: Shklyar Elena
Creation date: 07/23/08



*/
using ibs.th.str.marking.sts.*.

define variable vss-revision as character no-undo init "$Revision: f29df1d5f130, 3104, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Вт авг 09 09:15:01 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gray-zone.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/gray-zone.p $":U .
define variable vss-description as character no-undo init "Утилита для создания Серой зоны".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ utl/gtin.i }
define buffer buf_utd for ub.utd .
define buffer buf_marking-lines for ub.marking-lines .
define buffer buf_utd-marking-lines for ub.utd-marking-lines .
define buffer bf_utd-marking-lines for ub.utd-marking-lines .
define buffer buf_marking       for ub.marking .
define variable ungroup as logical   no-undo .
define variable ii as integer no-undo .
define variable v-marking as character no-undo .
define var      v-DocumentNumber  as character no-undo .
define variable v-leave as logical no-undo .
def var Marking as class mark no-undo .
{ gbl/objsrv.i }
def var v-message as character no-undo .
Marking = ObjSrv:Env:Marking:Sts:Mark .

run gbl/d-prompt.w (
  'title=':u + "Создание серой зоны" + '\':u
  + 'text1=':u + "Введите внутр. номер УПД:" + '\':u
  + 'format=' + "X(20)" + '\':u
  + 'type=' + {&type-char} + '\':u
  + 'fillin_row=3\':u
  + 'fillin_col=6\':u
  + 'fillin_width=20\':u
  + 'fillin_height=1\':u
  + 'max-chars=50\':u     /*- максимальное количество символов для редактора*/
  + 'readonly=no\':u
  , input-output v-DocumentNumber
  ).


/*find first buf_utd no-lock where buf_utd.doc-id = v-DocumentNumber                                      */
/*                            and (buf_utd.EdocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB                */
/*                            or buf_utd.EdocType = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB) no-error .*/
/*if not available (buf_utd) then next .                                                                  */
    for first buf_utd-marking-lines no-lock where buf_utd-marking-lines.doc-id = integer(v-DocumentNumber) 
                                              and buf_utd-marking-lines.doc-level = 1:
          for each buf_marking no-lock where buf_marking.mark-parent = buf_utd-marking-lines.mark:
              find first bf_utd-marking-lines exclusive-lock where bf_utd-marking-lines.doc-id = buf_utd-marking-lines.doc-id 
              and bf_utd-marking-lines.db-num = buf_utd-marking-lines.db-num and bf_utd-marking-lines.mark = buf_marking.mark no-error .
              if available (bf_utd-marking-lines) then do:
                delete bf_utd-marking-lines.
                ii = ii + 1 .
                if ii > 3 then leave .
              end.
              end .  
          find first buf_marking exclusive-lock where buf_marking.mark = buf_utd-marking-lines.mark no-error .
          if available (buf_marking) then do:
            buf_marking.sts = Marking:GrayZone:KeyIntDB .
          end.   
    end. 
    message "Утилита отработала"
      view-as alert-box.
  
