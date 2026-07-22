block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mig_0100.p $
$Archive: utl/mig_0100.p $

Модификация таблиц о МПЛ

Автор: Чернова Светлана Александровна
Дата создания: 12/08/08
Author: Svetlana Chernova
Creation date: 12/08/08

*/
using Ibs.Th.Gbl.ProgressBar.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mig_0100.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/mig_0100.p $":U .
define variable vss-description as character no-undo init "Модификация таблиц о МПЛ".
{ cmp/vssrevis.i }
{ utl/mig_0001.i }
{ ref/xobjgrp.i  }
{ rep/prg-bar.i def }
{ rep/prg-bar.i run  }

define variable v-progress-bar as class ProgressBar no-undo .

run prg-bar_init-cb-handle in this-procedure ( this-procedure ) .

define variable v-tot-rec as int64   no-undo .




run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Множественные прайс-листы") ).

on write  of ub.price-list-type   override do: end .
on write  of ub.grp-obj-price     override do: end .

on delete of ub.price-list-type-attr override do: end .
on delete of ub.price-list-type-cash-pay override do: end .
on delete of ub.price-list-type-cassa override do: end .
on delete of ub.price-list-type-gds-grp override do: end .
on delete of ub.price-list-type-pay-type override do: end .
on delete of ub.price-doc-forming-attr   override do: end .
on delete of ub.price-doc-forming-gds    override do: end .
on delete of ub.price-all                override do: end .
on delete of ub.price-doc-forming        override do: end .
on delete of ub.price-list-type override do: end .
on delete of ub.grp-obj-price override do: end .

  do
  on error undo, return error return-value
  :
  v-tot-rec = 0 .
  for each ub.grp-obj-price no-lock  :
    v-tot-rec = v-tot-rec + 1.
  end.

  run prg-bar_new in this-procedure ( 1, v-tot-rec).
  run prg-bar_title in this-procedure ( input "Удаление чужих множественных прайс листов...":U).
  run prg-bar_show in this-procedure .

  for each ub.grp-obj-price exclusive-lock :
      run prg-bar_increment in this-procedure .
      run metod-gop-obj (
          0 ,
          ub.grp-obj-price.gop-id ,
          ub.grp-obj-price.gop-db-num  ) .
      if not can-find(first x_obj-group)  then do:
         for each ub.price-list-type exclusive-lock where
                  ( ub.price-list-type.gop-id     = ub.grp-obj-price.gop-id and
                    ub.price-list-type.gop-db-num = ub.grp-obj-price.gop-db-num ) or
                  ( ub.price-list-type.gop-id-for-calc-turnover     = ub.grp-obj-price.gop-id and
                    ub.price-list-type.gop-db-num-for-calc-turnover = ub.grp-obj-price.gop-db-num ) :

            for each  ub.price-list-type-attr exclusive-lock where
                      ub.price-list-type-attr.plt-db-num = ub.price-list-type.plt-db-num    and
                      ub.price-list-type-attr.plt-id     = ub.price-list-type.plt-id
                      :
                      delete ub.price-list-type-attr.
            end.
            for each  ub.price-list-type-cash-pay exclusive-lock where
                      ub.price-list-type-cash-pay.plt-db-num = ub.price-list-type.plt-db-num    and
                      ub.price-list-type-cash-pay.plt-id     = ub.price-list-type.plt-id
                      :
                      delete ub.price-list-type-cash-pay.
            end.
            for each  ub.price-list-type-cassa exclusive-lock where
                      ub.price-list-type-cassa.plt-db-num = ub.price-list-type.plt-db-num    and
                      ub.price-list-type-cassa.plt-id     = ub.price-list-type.plt-id
                      :
                      delete ub.price-list-type-cassa.
            end.

            for each  ub.price-list-type-gds-grp exclusive-lock where
                      ub.price-list-type-gds-grp.plt-db-num = ub.price-list-type.plt-db-num    and
                      ub.price-list-type-gds-grp.plt-id     = ub.price-list-type.plt-id
                      :
                      delete ub.price-list-type-gds-grp.
            end.

            for each  ub.price-list-type-pay-type exclusive-lock where
                      ub.price-list-type-pay-type.plt-db-num = ub.price-list-type.plt-db-num    and
                      ub.price-list-type-pay-type.plt-id     = ub.price-list-type.plt-id
                      :
                      delete ub.price-list-type-pay-type.
            end.

            for each ub.price-doc-forming exclusive-lock where
                      ub.price-doc-forming.plt-db-num = ub.price-list-type.plt-db-num    and
                      ub.price-doc-forming.plt-id     = ub.price-list-type.plt-id
                      :
            for each ub.price-doc-forming-attr exclusive-lock where
                    ub.price-doc-forming-attr.pdf-db        = ub.price-doc-forming.pdf-db      and
                    ub.price-doc-forming-attr.pdf-id        = ub.price-doc-forming.pdf-id      and
                    ub.price-doc-forming-attr.plt-db-num    = ub.price-doc-forming.plt-db-num  and
                    ub.price-doc-forming-attr.plt-id        = ub.price-doc-forming.plt-id
                    :
                    delete ub.price-doc-forming-attr.
            end.

            for each ub.price-doc-forming-gds exclusive-lock where
                     ub.price-doc-forming-gds.plt-db-num    = ub.price-doc-forming.plt-db-num  and
                     ub.price-doc-forming-gds.plt-id        = ub.price-doc-forming.plt-id      and
                     ub.price-doc-forming-gds.pdf-db        = ub.price-doc-forming.pdf-db      and
                     ub.price-doc-forming-gds.pdf-id        = ub.price-doc-forming.pdf-id

                    :
                    delete ub.price-doc-forming-gds.
            end.

            for each ub.price-all exclusive-lock where
                    ub.price-all.pdf-db        = ub.price-doc-forming.pdf-db      and
                    ub.price-all.pdf-id        = ub.price-doc-forming.pdf-id      and
                    ub.price-all.plt-db-num    = ub.price-doc-forming.plt-db-num  and
                    ub.price-all.plt-id        = ub.price-doc-forming.plt-id
                    :
                    delete ub.price-all.
            end.
               delete ub.price-doc-forming.
            end.
            delete ub.price-list-type.
         end.
         for each ub.host-grp-obj-price  exclusive-lock where
                  ub.host-grp-obj-price.gop-id     = ub.grp-obj-price.gop-id and
                  ub.host-grp-obj-price.gop-db-num = ub.grp-obj-price.gop-db-num :
              delete ub.host-grp-obj-price.
         end.
         for each ub.db-grp-obj-price  exclusive-lock where
                  ub.db-grp-obj-price.gop-id     = ub.grp-obj-price.gop-id and
                  ub.db-grp-obj-price.gop-db-num = ub.grp-obj-price.gop-db-num :
              delete ub.db-grp-obj-price.
         end.
         for each ub.obj-grp-obj-price  exclusive-lock where
                  ub.obj-grp-obj-price.gop-id     = ub.grp-obj-price.gop-id and
                  ub.obj-grp-obj-price.gop-db-num = ub.grp-obj-price.gop-db-num :
              delete ub.obj-grp-obj-price.
         end.


         delete ub.grp-obj-price.
      end.
  end.
  run prg-bar_delete-progress-bar in this-procedure .
  end.



