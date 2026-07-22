block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: crassmxa.p $
$Archive: utl/crassmxa.p $

Создание ассортиментной матрицы на основе таблицы gds-obj за вычетом атрибута attr-no-income-goods

Автор: Чернова Светлана Александровна
Дата создания: 06/07/07
Author: Svetlana Chernova
Creation date: 06/07/07

Автор1: Суслов Алексей Юрьевич
Дата создания: 04/18/06

*/
define input parameter parparentproc as handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: crassmxa.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/crassmxa.p $":U .
define variable vss-description as character no-undo init "Создание ассортиментной матрицы на основе таблицы gds-obj за вычетом атрибута attr-no-income-goods".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ ref/gdsoattr.i }
{ gbl/getcntxt.i def }
{ cmp/library.i  }
{ gbl/getcntxt.i get }
{ gbl/waitfram.i }

define buffer bf_assortment-matrix       for ub.assortment-matrix.
define buffer bf_assortment-matrix-goods for ub.assortment-matrix-goods.
define buffer bf_gds-obj           for ub.gds-obj.
define variable varvalue-no-income as character no-undo.
define variable vartype-no-income  as character no-undo.
  define variable loc#log as logical no-undo.
/* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_assort-matr_add-def':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    loc#log
  }
  if loc#log <> yes then do: return error. end.

do on error undo, return error return-value :
run waitfram-show  in this-procedure (substitute("Создание ассортиментной матрицы по товарам на объекте &1 &2" , v-cntxt-obj-type, v-cntxt-obj-code)).
find first bf_assortment-matrix where bf_assortment-matrix.obj-type = v-cntxt-obj-type and
                                      bf_assortment-matrix.asmt-status  = 0 and
                                      bf_assortment-matrix.obj-code = v-cntxt-obj-code no-lock no-error.
if available bf_assortment-matrix then do:
  message "На объекте " v-cntxt-obj-type " " v-cntxt-obj-code " уже определены ассортиментные матрицы."
          "Название: " bf_assortment-matrix.asmt-name skip
          bf_assortment-matrix.asmt-id
          view-as alert-box.
end.
else do:
  create bf_assortment-matrix.
  assign
    bf_assortment-matrix.asmt-date-create     = today
    bf_assortment-matrix.asmt-date-update     = today
    bf_assortment-matrix.asmt-db-num-create   = v-cntxt-db-num
    bf_assortment-matrix.asmt-db-num-update   = v-cntxt-db-num
    bf_assortment-matrix.asmt-des             = "Ассортиментная матрица создана утилитой на основе gds-obj и атрибута запрета прихода, действующего в версии 14."
    bf_assortment-matrix.asmt-id              = next-value(s-asmt, {&db-name_schema})
    bf_assortment-matrix.asmt-name            = "Ассортиментная матрица создана утилитой на основе gds-obj и атрибута запрета прихода, действующего в версии 14."
    bf_assortment-matrix.asmt-status          = 0
    bf_assortment-matrix.asmt-time-create     = time
    bf_assortment-matrix.asmt-time-update     = time
    bf_assortment-matrix.asmt-type            = {&type-assmatr-obj}
    bf_assortment-matrix.asmt-who-create      = v-cntxt-userid
    bf_assortment-matrix.asmt-who-update      = v-cntxt-userid
    bf_assortment-matrix.db-num               = v-cntxt-db-num
    bf_assortment-matrix.obj-code             = v-cntxt-obj-code
    bf_assortment-matrix.obj-type             = v-cntxt-obj-type
    bf_assortment-matrix.asmt-status          = 0
  .
  for each bf_gds-obj where bf_gds-obj.obj-type = v-cntxt-obj-type and
                            bf_gds-obj.obj-code = v-cntxt-obj-code no-lock :
     run gdsoattr-value in this-procedure (
         {&attr-no-income-goods},
         bf_gds-obj.gds-code,
         v-cntxt-obj-type,
         v-cntxt-obj-code,
         output varvalue-no-income,
         output vartype-no-income  ) no-error.
     if varvalue-no-income = "yes":u then do:
       next.
     end.
     create bf_assortment-matrix-goods.
     assign
       bf_assortment-matrix-goods.asmg-date-create    = bf_assortment-matrix.asmt-date-create
       bf_assortment-matrix-goods.asmg-date-update    = bf_assortment-matrix.asmt-date-update
       bf_assortment-matrix-goods.asmg-db-num-create  = bf_assortment-matrix.asmt-db-num-create
       bf_assortment-matrix-goods.asmg-db-num-update  = bf_assortment-matrix.asmt-db-num-update
       bf_assortment-matrix-goods.asmg-des            = bf_assortment-matrix.asmt-des
       bf_assortment-matrix-goods.asmg-status         = bf_assortment-matrix.asmt-status
       bf_assortment-matrix-goods.asmg-time-create    = bf_assortment-matrix.asmt-time-create
       bf_assortment-matrix-goods.asmg-time-update    = bf_assortment-matrix.asmt-time-update
       bf_assortment-matrix-goods.asmg-who-create     = bf_assortment-matrix.asmt-who-create
       bf_assortment-matrix-goods.asmg-who-update     = bf_assortment-matrix.asmt-who-update
       bf_assortment-matrix-goods.asmt-id             = bf_assortment-matrix.asmt-id
       bf_assortment-matrix-goods.db-num              = bf_assortment-matrix.db-num
       bf_assortment-matrix-goods.gds-code            = bf_gds-obj.gds-code
       bf_assortment-matrix-goods.obj-code            = bf_assortment-matrix.obj-code
       bf_assortment-matrix-goods.obj-type            = bf_assortment-matrix.obj-type
     .
  end.
end.
run waitfram-hide  in this-procedure .
end.