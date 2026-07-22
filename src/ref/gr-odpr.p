block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gr-odpr.p $
$Archive: ref/gr-odpr.p $

Удаление группы объектов для ценообразовани

Автор: Чернова Светлана Александровна
Дата создания: 11/10/05
Author: Svetlana Chernova
Creation date: 11/10/05

*/
define input  parameter parparentproc  as handle no-undo .
define input  parameter p-db-num  like ub.sum-group.sgr-db-num no-undo .
define input  parameter p-id      like ub.sum-group.sgr-id     no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gr-odpr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gr-odpr.p $":U .
define variable vss-description as character no-undo init "Удаление группы объектов для ценообразования".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i      }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/waitfram.i }
{ ref/obji-ad.i   }
find first ub.grp-obj-price no-lock where
           ub.grp-obj-price.gop-db-num = p-db-num    and
           ub.grp-obj-price.gop-id     = p-id
           no-error .

find first ub.price-list-type no-lock where
           ub.price-list-type.stts = integer({&pdf-new}) and
           ub.price-list-type.gop-db-num = p-db-num    and
           ub.price-list-type.gop-id     = p-id no-error .
          if available ub.price-list-type then do:
          message "По этой группе объектов есть ТПЛ (Справочник типов прайс-листов) . Удалять нельзя !" skip
                  "ТПЛ " ub.price-list-type.plt-id skip
                  "БД"   ub.price-list-type.plt-db-num
                  view-as alert-box information  .
          return .
          end.
find first ub.price-list-type no-lock where
           ub.price-list-type.stts = integer({&pdf-new}) and
           ub.price-list-type.gop-db-num-for-calc-turnover = p-db-num    and
           ub.price-list-type.gop-id-for-calc-turnover     = p-id no-error .
          if available ub.price-list-type then do:
          message "На эту группу ссылается ТПЛ (Справочник типов прайс-листов) . Удалять нельзя !" skip
                  "ТПЛ " ub.price-list-type.plt-id skip
                  "БД"   ub.price-list-type.plt-db-num
                  view-as alert-box information  .
          return .
          end.




find first ub.grp-obj-price exclusive-lock where
           ub.grp-obj-price.gop-db-num = p-db-num    and
           ub.grp-obj-price.gop-id     = p-id
           no-error .
/*
find first ub.price-list-type no-lock where
          (ub.price-list-type.gop-db-num = p-db-num    and
           ub.price-list-type.gop-id     = p-id ) or
          (ub.price-list-type.gop-db-num-for-calc-turnover = p-db-num    and
           ub.price-list-type.gop-id-for-calc-turnover     = p-id )
           no-error .
          if not available ub.price-list-type then do:
             message "Группа ни где не используется , удалить совсем ? "
                view-as alert-box question
                buttons yes-no
                update v-ok as log.
             if v-ok = true then  do:
                delete ub.grp-obj-price.
                return.
             end.
          end.
*/
run waitfram-show ("Ждите...") .

  ub.grp-obj-price.stts = 1.
  for each  ub.db-grp-obj-price exclusive-lock where
            ub.db-grp-obj-price.gop-db-num = p-db-num    and
            ub.db-grp-obj-price.gop-id     = p-id
            :
        run obji-del(
           input   ub.db-grp-obj-price.gop-db-num
          ,input   ub.db-grp-obj-price.gop-id
          ,input   ub.db-grp-obj-price.dgo-db-num
          ,input   v-cntxt-db-num
          ,input   v-cntxt-userid ) .

  end.

  for each  ub.host-grp-obj-price exclusive-lock where
            ub.host-grp-obj-price.gop-db-num = p-db-num    and
            ub.host-grp-obj-price.gop-id     = p-id
            :
        run objf-del(
           input   ub.host-grp-obj-price.gop-db-num
          ,input   ub.host-grp-obj-price.gop-id
          ,input   ub.host-grp-obj-price.host-code
          ,input   v-cntxt-db-num
          ,input   v-cntxt-userid ) .

  end.

  for each  ub.obj-grp-obj-price exclusive-lock where
            ub.obj-grp-obj-price.gop-db-num = p-db-num    and
            ub.obj-grp-obj-price.gop-id     = p-id
            :
        run objo-del(
           input   ub.obj-grp-obj-price.gop-db-num
          ,input   ub.obj-grp-obj-price.gop-id
          ,input   ub.obj-grp-obj-price.obj-type
          ,input   ub.obj-grp-obj-price.obj-code
          ,input   v-cntxt-db-num
          ,input   v-cntxt-userid ) .

  end.

run waitfram-hide .