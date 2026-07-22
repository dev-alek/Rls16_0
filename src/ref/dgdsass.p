block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dgdsass.p $
$Archive: ref/dgdsass.p $

Быстрое удаление ИЖТ и АССортиментных матриц по товару.

Автор: Чернова Светлана Александровна
Дата создания: 05/04/09
Author: Svetlana Chernova
Creation date: 05/04/09

*/

define input  parameter p-gds-code as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dgdsass.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dgdsass.p $":U .
define variable vss-description as character no-undo init "Быстрое удаление ИЖТ и АССортиментных матриц по товару.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }
{ ref/gds-matl.i }


define buffer buf_gds-obj-prop for ub.gds-obj-prop  .
define buffer buf_assortment-matrix for ub.assortment-matrix  .
define buffer buf_assortment-matrix-gds for ub.assortment-matrix-goods  .

define variable v-stt as integer   no-undo .

run waitfram-show in this-procedure ("Снятие ИЖТ товара ") .
  for each buf_gds-obj-prop exclusive-lock where
           buf_gds-obj-prop.gds-code = p-gds-code :
      buf_gds-obj-prop.gdop-igt  = {&ass-izd-empty} .
  end.

run waitfram-show in this-procedure ("Удаление товара по Ассортиментным матрицам") .
  for each buf_assortment-matrix no-lock  where buf_assortment-matrix.asmt-status = 0 :
      for each buf_assortment-matrix-gds exclusive-lock
      where buf_assortment-matrix-gds.asmt-id = buf_assortment-matrix.asmt-id and
            buf_assortment-matrix-gds.db-num  = buf_assortment-matrix.db-num  and
            buf_assortment-matrix-gds.gds-code  = p-gds-code  and
            buf_assortment-matrix-gds.asmg-status = 0 :
            v-stt = 1.
          { ref/gds-mat2.i
            this-procedure
            recid(buf_assortment-matrix-gds)
            v-stt
            false
            no-error }
            if error-status:error then do:
            message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              ""
              view-as alert-box error
            .
             undo, return error  substitute("Ошибка при удалении товара из АссМатр &1 &2 объект: &3&4" , return-value, error-status :get-message(1) , buf_assortment-matrix.obj-type ,buf_assortment-matrix.obj-code) .
             end.
      end.
  end.
run waitfram-hide in this-procedure  .