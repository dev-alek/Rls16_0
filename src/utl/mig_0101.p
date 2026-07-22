block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mig_0101.p $
$Archive: utl/mig_0101.p $

Модификация таблиц блока Ассортиментной политики

Автор: Чернова Светлана Александровна
Дата создания: 12/08/08
Author: Svetlana Chernova
Creation date: 12/08/08

*/
using Ibs.Th.Gbl.ProgressBar.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mig_0101.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/mig_0101.p $":U .
define variable vss-description as character no-undo init "Модификация таблиц блока Ассортиментной политики".
{ cmp/vssrevis.i }
{ utl/mig_0001.i }
{ rep/prg-bar.i def }
{ rep/prg-bar.i run  }

define variable v-progress-bar as class ProgressBar no-undo .
run prg-bar_init-cb-handle in this-procedure ( this-procedure ) .
define variable v-tot-rec as int64   no-undo .


run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute ("Ассортиментная политика") ).

on delete of ub.assortment-matrix               override do: end .
on delete of ub.assortment-matrix-attr          override do: end .
on delete of ub.assortment-matrix-goods         override do: end .
on delete of ub.assortment-matrix-goods-attr    override do: end .
on delete of ub.c-assortment-matrix             override do: end .
on delete of ub.c-assortment-matrix-goods       override do: end .

  do
  on error undo, return error return-value
  :

  v-tot-rec = 0 .
    for each ub.assortment-matrix no-lock where
             ub.assortment-matrix.asmt-type = {&type-assmatr-obj} :

    v-tot-rec = v-tot-rec + 1.
  end.

  run prg-bar_new in this-procedure ( 1, v-tot-rec).
  run prg-bar_title in this-procedure ( input "Удаление чужих ассортиментных матриц...":U).
  run prg-bar_show in this-procedure .

    for each ub.assortment-matrix exclusive-lock where
             ub.assortment-matrix.asmt-type = {&type-assmatr-obj} :
             run prg-bar_increment in this-procedure .
        find first ub.clients no-lock where
                   ub.clients.obj-code = ub.assortment-matrix.obj-code and
                   ub.clients.obj-type = ub.assortment-matrix.obj-type no-error .
       if not available ub.clients then do:

            for each  ub.assortment-matrix-goods exclusive-lock where
                      ub.assortment-matrix-goods.asmt-id = ub.assortment-matrix.asmt-id and
                      ub.assortment-matrix-goods.db-num  = ub.assortment-matrix.db-num :
                delete ub.assortment-matrix-goods.
            end.

            for each  ub.c-assortment-matrix-goods exclusive-lock where
                      ub.c-assortment-matrix-goods.asmt-id = ub.assortment-matrix.asmt-id and
                      ub.c-assortment-matrix-goods.db-num  = ub.assortment-matrix.db-num :
                delete ub.c-assortment-matrix-goods.
            end.

            for each  ub.c-assortment-matrix exclusive-lock where
                      ub.c-assortment-matrix.asmt-id = ub.assortment-matrix.asmt-id and
                      ub.c-assortment-matrix.db-num  = ub.assortment-matrix.db-num :
                delete ub.c-assortment-matrix.
            end.

            delete ub.assortment-matrix .
       end.

    end.

  run prg-bar_delete-progress-bar in this-procedure .
  end.
