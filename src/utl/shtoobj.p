block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: shtoobj.p $
$Archive: utl/shtoobj.p $

Транслирование всего шаблона в связанные матрицы-объекты

Автор: Чернова Светлана Александровна
Дата создания: 07/15/09
Author: Svetlana Chernova
Creation date: 07/15/09

*/
define input  parameter parParentProc as handle no-undo .
define variable  p-install     as logical no-undo init no .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: shtoobj.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/shtoobj.p $":U .
define variable vss-description as character no-undo init "Транслирование всего шаблона в связанные матрицы-объекты".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/waitfram.i }
{ ref/gds-matl.i }
{ ref/gds-ind1.i }
{ str/asstroth.i }
{ str/ascorrm.i  }
{ gbl/cur-time.i }
define variable v-rid-list as character no-undo .
define buffer buf_assort-matrix for ub.assortment-matrix  .
define buffer buf_assort-matrix-goods for ub.assortment-matrix-goods  .
v-rid-list  = "".
  v-longchar-asstro = "" .
  { ref/clearlm.i }

    run ref/assmatr.w (
        input parParentProc   ,
        input "b-sel"         ,
        input v-cntxt-obj-type ,
        input v-cntxt-obj-code ,
        input {&type-assmatr-shablon}  ,
        input 0               ,
        input-output v-rid-list ) .

  if num-entries(v-rid-list) <> 1 then return.

  find first buf_assort-matrix exclusive-lock where  recid(buf_assort-matrix) = int(v-rid-list) no-error .
  for each  buf_assort-matrix-goods no-lock where
            buf_assort-matrix-goods.asmt-id = buf_assort-matrix.asmt-id and
            buf_assort-matrix-goods.db-num  = buf_assort-matrix.db-num :
            create temp-goods.
            assign
              temp-goods.gds-code = buf_assort-matrix-goods.gds-code
              temp-goods.status_  = buf_assort-matrix-goods.asmg-status
            .
  end.

    run translate-to-other ( buf_assort-matrix.asmt-id, buf_assort-matrix.db-num ).
    if v-longchar-asstro <> ""  then do:
    define variable v-ok as logical   no-undo .
    run gbl/d-longchar.w (
            ?,
            'Editor_row=2\':u
          + 'title=При транслировании в Ассортиментные матрицы\':u
          + 'Editor_col=1\':u
          + 'Editor_width=96\':u
          + 'Editor_height=21\':u
          + 'readonly=yes\':u
        ,input-output v-longchar-asstro
        ,output v-ok ) no-error .
        v-longchar-asstro = "" .
        { ref/clearlm.i }

    end.