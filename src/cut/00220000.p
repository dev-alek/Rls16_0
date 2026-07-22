block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00220000.p $
$Archive: cut/00220000.p $

Файл пирога обрезания. Относится к категории 8.

Автор: Чернова Светлана Александровна
Дата создания: 05/22/09
Author: Svetlana Chernova
Creation date: 05/22/09

Обработка таблиц:

price-list-type
c-price-list-type
price-list-type-attr
c-price-list-type-attr

price-list-type-cash-pay
c-price-list-type-cash-pay
price-list-type-pay-type
c-price-list-type-pay-type
price-list-type-cassa
c-price-list-type-cassa
price-list-type-cassa-attr
price-list-type-gds-grp
c-price-list-type-gds-grp
price-list-type-gds-grp-attr

global-state
c-global-state
global-state-attr
c-global-state-attr

grp-obj-price
c-grp-obj-price
db-grp-obj-price
c-db-grp-obj-price
host-grp-obj-price
c-host-grp-obj-price
obj-grp-obj-price
c-obj-grp-obj-price
grp-obj-price-attr
db-grp-obj-price-attr
host-grp-obj-price-attr
obj-grp-obj-price-attr


qnty-group
c-qnty-group
qnty-in-qnty-group
c-qnty-in-qnty-group
qnty-group-attr
qnty-in-qnty-group-attr

sum-group
c-sum-group
sum-in-sum-group
c-sum-in-sum-group
sum-group-attr
sum-in-sum-group-attr

tnv-in-turnover-group
c-tnv-in-turnover-group
turnover-group
c-turnover-group
tnv-in-turnover-group-attr
turnover-group-attr


turnover-buyer
turnover-buyer-attr
turnover-buyer-gds
turnover-buyer-gds-attr
turnover-buyer-main
turnover-buyer-main-attr

buyer-group
c-buyer-group
buyer-group-attr
buyer-in-buyer-group
c-buyer-in-buyer-group
buyer-in-buyer-group-attr

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00220000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00220000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 8.".
{ cmp/str-glbl.i }

define buffer old-price-list-type          for src.price-list-type.
define buffer new-price-list-type          for dst.price-list-type.
define buffer old-c-price-list-type        for src.c-price-list-type.
define buffer new-c-price-list-type        for dst.c-price-list-type.

define buffer old-price-list-type-attr     for src.price-list-type-attr.
define buffer new-price-list-type-attr     for dst.price-list-type-attr.
define buffer old-c-price-list-type-attr   for src.c-price-list-type-attr.
define buffer new-c-price-list-type-attr   for dst.c-price-list-type-attr.

define buffer old-price-list-type-cash-pay        for src.price-list-type-cash-pay                 .
define buffer old-c-price-list-type-cash-pay      for src.c-price-list-type-cash-pay               .
define buffer old-price-list-type-pay-type        for src.price-list-type-pay-type                 .
define buffer old-c-price-list-type-pay-type      for src.c-price-list-type-pay-type               .
define buffer old-price-list-type-cassa           for src.price-list-type-cassa                    .
define buffer old-c-price-list-type-cassa         for src.c-price-list-type-cassa                  .
define buffer old-price-list-type-cassa-attr      for src.price-list-type-cassa-attr               .
define buffer old-price-list-type-gds-grp         for src.price-list-type-gds-grp                  .
define buffer old-c-price-list-type-gds-grp       for src.c-price-list-type-gds-grp                .
define buffer old-price-list-type-gds-grp-attr    for src.price-list-type-gds-grp-attr             .

define buffer old-global-state                    for src.global-state                             .
define buffer old-global-state-attr               for src.global-state-attr                        .
define buffer old-c-global-state                  for src.c-global-state                           .
define buffer old-c-global-state-attr             for src.c-global-state-attr                      .

define buffer old-grp-obj-price                   for src.grp-obj-price                            .
define buffer old-c-grp-obj-price                 for src.c-grp-obj-price                          .
define buffer old-db-grp-obj-price                for src.db-grp-obj-price                         .
define buffer old-c-db-grp-obj-price              for src.c-db-grp-obj-price                       .
define buffer old-host-grp-obj-price              for src.host-grp-obj-price                       .
define buffer old-c-host-grp-obj-price            for src.c-host-grp-obj-price                     .
define buffer old-obj-grp-obj-price               for src.obj-grp-obj-price                        .
define buffer old-c-obj-grp-obj-price             for src.c-obj-grp-obj-price                      .
define buffer old-grp-obj-price-attr              for src.grp-obj-price-attr                       .
define buffer old-db-grp-obj-price-attr           for src.db-grp-obj-price-attr                    .
define buffer old-host-grp-obj-price-attr         for src.host-grp-obj-price-attr                  .
define buffer old-obj-grp-obj-price-attr          for src.obj-grp-obj-price-attr                   .

define buffer old-qnty-group                      for src.qnty-group                                .
define buffer old-c-qnty-group                    for src.c-qnty-group                              .
define buffer old-qnty-in-qnty-group              for src.qnty-in-qnty-group                        .
define buffer old-c-qnty-in-qnty-group            for src.c-qnty-in-qnty-group                      .
define buffer old-qnty-group-attr                 for src.qnty-group-attr                           .
define buffer old-qnty-in-qnty-group-attr         for src.qnty-in-qnty-group-attr                   .

define buffer old-sum-group                       for src.sum-group                                 .
define buffer old-c-sum-group                     for src.c-sum-group                               .
define buffer old-sum-in-sum-group                for src.sum-in-sum-group                          .
define buffer old-c-sum-in-sum-group              for src.c-sum-in-sum-group                        .
define buffer old-sum-group-attr                  for src.sum-group-attr                            .
define buffer old-sum-in-sum-group-attr           for src.sum-in-sum-group-attr                     .

define buffer old-tnv-in-turnover-group           for src.tnv-in-turnover-group                      .
define buffer old-c-tnv-in-turnover-group         for src.c-tnv-in-turnover-group                    .
define buffer old-turnover-group                  for src.turnover-group                             .
define buffer old-c-turnover-group                for src.c-turnover-group                           .
define buffer old-tnv-in-turnover-group-attr      for src.tnv-in-turnover-group-attr                 .
define buffer old-turnover-group-attr             for src.turnover-group-attr                        .

define buffer new-price-list-type-cash-pay          for dst.price-list-type-cash-pay                  .
define buffer new-c-price-list-type-cash-pay        for dst.c-price-list-type-cash-pay                .
define buffer new-price-list-type-pay-type          for dst.price-list-type-pay-type                  .
define buffer new-c-price-list-type-pay-type        for dst.c-price-list-type-pay-type                .
define buffer new-price-list-type-cassa             for dst.price-list-type-cassa                     .
define buffer new-c-price-list-type-cassa           for dst.c-price-list-type-cassa                   .
define buffer new-price-list-type-cassa-attr        for dst.price-list-type-cassa-attr                .
define buffer new-price-list-type-gds-grp           for dst.price-list-type-gds-grp                   .
define buffer new-c-price-list-type-gds-grp         for dst.c-price-list-type-gds-grp                 .
define buffer new-price-list-type-gds-grp-attr      for dst.price-list-type-gds-grp-attr              .

define buffer new-global-state                      for dst.global-state                               .
define buffer new-global-state-attr                 for dst.global-state-attr                          .
define buffer new-c-global-state                    for dst.c-global-state                             .
define buffer new-c-global-state-attr               for dst.c-global-state-attr                        .


define buffer new-grp-obj-price                     for dst.grp-obj-price                              .
define buffer new-c-grp-obj-price                   for dst.c-grp-obj-price                            .
define buffer new-db-grp-obj-price                  for dst.db-grp-obj-price                           .
define buffer new-c-db-grp-obj-price                for dst.c-db-grp-obj-price                         .
define buffer new-host-grp-obj-price                for dst.host-grp-obj-price                         .
define buffer new-c-host-grp-obj-price              for dst.c-host-grp-obj-price                       .
define buffer new-obj-grp-obj-price                 for dst.obj-grp-obj-price                          .
define buffer new-c-obj-grp-obj-price               for dst.c-obj-grp-obj-price                        .
define buffer new-grp-obj-price-attr                for dst.grp-obj-price-attr                         .
define buffer new-db-grp-obj-price-attr             for dst.db-grp-obj-price-attr                      .
define buffer new-host-grp-obj-price-attr           for dst.host-grp-obj-price-attr                    .
define buffer new-obj-grp-obj-price-attr            for dst.obj-grp-obj-price-attr                     .

define buffer new-qnty-group                        for dst.qnty-group                                 .
define buffer new-c-qnty-group                      for dst.c-qnty-group                               .
define buffer new-qnty-in-qnty-group                for dst.qnty-in-qnty-group                         .
define buffer new-c-qnty-in-qnty-group              for dst.c-qnty-in-qnty-group                       .
define buffer new-qnty-group-attr                   for dst.qnty-group-attr                            .
define buffer new-qnty-in-qnty-group-attr           for dst.qnty-in-qnty-group-attr                    .

define buffer new-sum-group                         for dst.sum-group                                   .
define buffer new-c-sum-group                       for dst.c-sum-group                                 .
define buffer new-sum-in-sum-group                  for dst.sum-in-sum-group                            .
define buffer new-c-sum-in-sum-group                for dst.c-sum-in-sum-group                           .
define buffer new-sum-group-attr                    for dst.sum-group-attr                              .
define buffer new-sum-in-sum-group-attr             for dst.sum-in-sum-group-attr                       .

define buffer new-tnv-in-turnover-group             for dst.tnv-in-turnover-group                        .
define buffer new-c-tnv-in-turnover-group           for dst.c-tnv-in-turnover-group                      .
define buffer new-turnover-group                    for dst.turnover-group                               .
define buffer new-c-turnover-group                  for dst.c-turnover-group                             .
define buffer new-tnv-in-turnover-group-attr        for dst.tnv-in-turnover-group-attr                   .
define buffer new-turnover-group-attr               for dst.turnover-group-attr                          .

define buffer new-turnover-buyer            for dst.turnover-buyer            .
define buffer new-turnover-buyer-attr       for dst.turnover-buyer-attr       .
define buffer new-turnover-buyer-gds        for dst.turnover-buyer-gds        .
define buffer new-turnover-buyer-gds-attr   for dst.turnover-buyer-gds-attr   .
define buffer new-turnover-buyer-main       for dst.turnover-buyer-main       .
define buffer new-turnover-buyer-main-attr  for dst.turnover-buyer-main-attr  .

define buffer old-turnover-buyer            for src.turnover-buyer             .
define buffer old-turnover-buyer-attr       for src.turnover-buyer-attr        .
define buffer old-turnover-buyer-gds        for src.turnover-buyer-gds         .
define buffer old-turnover-buyer-gds-attr   for src.turnover-buyer-gds-attr    .
define buffer old-turnover-buyer-main       for src.turnover-buyer-main        .
define buffer old-turnover-buyer-main-attr  for src.turnover-buyer-main-attr   .

define buffer old-buyer-group               for src.buyer-group                .
define buffer old-c-buyer-group             for src.c-buyer-group              .
define buffer old-buyer-group-attr          for src.buyer-group-attr           .
define buffer old-buyer-in-buyer-group      for src.buyer-in-buyer-group       .
define buffer old-c-buyer-in-buyer-group    for src.c-buyer-in-buyer-group     .
define buffer old-buyer-in-buyer-group-attr for src.buyer-in-buyer-group-attr  .

define buffer new-buyer-group               for dst.buyer-group                .
define buffer new-c-buyer-group             for dst.c-buyer-group              .
define buffer new-buyer-group-attr          for dst.buyer-group-attr           .
define buffer new-buyer-in-buyer-group      for dst.buyer-in-buyer-group       .
define buffer new-c-buyer-in-buyer-group    for dst.c-buyer-in-buyer-group     .
define buffer new-buyer-in-buyer-group-attr for dst.buyer-in-buyer-group-attr  .


define buffer new-goods                     for dst.goods                      .


do
on error undo, return error
:
  { utl/00000001.i }
  on WRITE of dst.price-list-type               override do: end.
  on WRITE of dst.c-price-list-type             override do: end.
  on WRITE of dst.price-list-type-attr          override do: end.
  on WRITE of dst.c-price-list-type-attr        override do: end.
  on WRITE of dst.price-list-type-cash-pay      override do: end.
  on WRITE of dst.c-price-list-type-cash-pay    override do: end.
  on WRITE of dst.price-list-type-pay-type      override do: end.
  on WRITE of dst.c-price-list-type-pay-type    override do: end.
  on WRITE of dst.price-list-type-cassa         override do: end.
  on WRITE of dst.c-price-list-type-cassa       override do: end.
  on WRITE of dst.price-list-type-cassa-attr    override do: end.
  on WRITE of dst.price-list-type-gds-grp       override do: end.
  on WRITE of dst.c-price-list-type-gds-grp     override do: end.
  on WRITE of dst.price-list-type-gds-grp-attr  override do: end.
  on WRITE of dst.global-state                  override do: end.
  on WRITE of dst.global-state-attr             override do: end.
  on WRITE of dst.c-global-state                override do: end.
  on WRITE of dst.c-global-state-attr           override do: end.
  on WRITE of dst.grp-obj-price                 override do: end.
  on WRITE of dst.c-grp-obj-price               override do: end.
  on WRITE of dst.db-grp-obj-price              override do: end.
  on WRITE of dst.c-db-grp-obj-price            override do: end.
  on WRITE of dst.host-grp-obj-price            override do: end.
  on WRITE of dst.c-host-grp-obj-price          override do: end.
  on WRITE of dst.obj-grp-obj-price             override do: end.
  on WRITE of dst.c-obj-grp-obj-price           override do: end.
  on WRITE of dst.grp-obj-price-attr            override do: end.
  on WRITE of dst.db-grp-obj-price-attr         override do: end.
  on WRITE of dst.host-grp-obj-price-attr       override do: end.
  on WRITE of dst.obj-grp-obj-price-attr        override do: end.
  on WRITE of dst.qnty-group                    override do: end.
  on WRITE of dst.c-qnty-group                  override do: end.
  on WRITE of dst.qnty-in-qnty-group            override do: end.
  on WRITE of dst.c-qnty-in-qnty-group          override do: end.
  on WRITE of dst.qnty-group-attr               override do: end.
  on WRITE of dst.qnty-in-qnty-group-attr       override do: end.
  on WRITE of dst.sum-group                     override do: end.
  on WRITE of dst.c-sum-group                   override do: end.
  on WRITE of dst.sum-in-sum-group              override do: end.
  on WRITE of dst.c-sum-in-sum-group            override do: end.
  on WRITE of dst.sum-group-attr                override do: end.
  on WRITE of dst.sum-in-sum-group-attr         override do: end.
  on WRITE of dst.tnv-in-turnover-group         override do: end.
  on WRITE of dst.c-tnv-in-turnover-group       override do: end.
  on WRITE of dst.turnover-group                override do: end.
  on WRITE of dst.c-turnover-group              override do: end.
  on WRITE of dst.tnv-in-turnover-group-attr    override do: end.
  on WRITE of dst.turnover-group-attr           override do: end.

 on WRITE of dst.turnover-buyer             override do: end.
 on WRITE of dst.turnover-buyer-attr        override do: end.
 on WRITE of dst.turnover-buyer-gds         override do: end.
 on WRITE of dst.turnover-buyer-gds-attr    override do: end.
 on WRITE of dst.turnover-buyer-main        override do: end.
 on WRITE of dst.turnover-buyer-main-attr   override do: end.

 on WRITE of dst.buyer-group                override do: end.
 on WRITE of dst.c-buyer-group              override do: end.
 on WRITE of dst.buyer-group-attr           override do: end.
 on WRITE of dst.buyer-in-buyer-group       override do: end.
 on WRITE of dst.c-buyer-in-buyer-group     override do: end.
 on WRITE of dst.buyer-in-buyer-group-attr  override do: end.



  { utl/00000002.i price-list-type              }
  if varstay-history then do:
    { utl/00000002.i c-price-list-type              }
  end.
  { utl/00000002.i price-list-type-attr         }
  if varstay-history then do:
    { utl/00000002.i c-price-list-type-attr         }
  end.
  { utl/00000002.i price-list-type-cash-pay     }
  if varstay-history then do:
    { utl/00000002.i c-price-list-type-cash-pay     }
  end.
  { utl/00000002.i price-list-type-pay-type     }
  if varstay-history then do:
    { utl/00000002.i c-price-list-type-pay-type     }
  end.
  { utl/00000002.i price-list-type-cassa        }
  if varstay-history then do:
    { utl/00000002.i c-price-list-type-cassa        }
  end.
  { utl/00000002.i price-list-type-cassa-attr   }
  { utl/00000002.i price-list-type-gds-grp      }
  if varstay-history then do:
    { utl/00000002.i c-price-list-type-gds-grp      }
  end.
  { utl/00000002.i price-list-type-gds-grp-attr }
  { utl/00000002.i global-state               }
  { utl/00000002.i global-state-attr          }
  if varstay-history then do:
    { utl/00000002.i c-global-state               }
    { utl/00000002.i c-global-state-attr          }
  end.
  { utl/00000002.i grp-obj-price              }
  if varstay-history then do:
    { utl/00000002.i c-grp-obj-price              }
  end.
  { utl/00000002.i grp-obj-price-attr         }
  { utl/00000002.i db-grp-obj-price   "  where  old-db-grp-obj-price.stts = 0    " }
  if varstay-history then do:
    { utl/00000002.i c-db-grp-obj-price   " ,  first new-db-grp-obj-price where     ~
                                               new-db-grp-obj-price.gop-id = old-c-db-grp-obj-price.gop-id ~
                                           and new-db-grp-obj-price.gop-db-num = old-c-db-grp-obj-price.gop-db-num ~
                                           and new-db-grp-obj-price.dgo-db-num = old-c-db-grp-obj-price.dgo-db-num " }
  end.
  { utl/00000002.i db-grp-obj-price-attr   ", first new-db-grp-obj-price where ~
                                                 new-db-grp-obj-price.gop-id = old-db-grp-obj-price-attr.gop-id ~
                                            and new-db-grp-obj-price.gop-db-num = old-db-grp-obj-price-attr.gop-db-num ~
                                            and new-db-grp-obj-price.dgo-db-num = old-db-grp-obj-price-attr.dgo-db-num " }

  { utl/00000002.i host-grp-obj-price "  where  old-host-grp-obj-price.stts = 0  " }
  if varstay-history then do:
    { utl/00000002.i c-host-grp-obj-price "  , first new-host-grp-obj-price where ~
                                               new-host-grp-obj-price.gop-id = old-c-host-grp-obj-price.gop-id ~
                                           and new-host-grp-obj-price.gop-db-num = old-c-host-grp-obj-price.gop-db-num ~
                                           and new-host-grp-obj-price.host-code = old-c-host-grp-obj-price.host-code " }
  end.
  { utl/00000002.i host-grp-obj-price-attr    "  , first new-host-grp-obj-price where ~
                                               new-host-grp-obj-price.gop-id = old-host-grp-obj-price-attr.gop-id ~
                                           and new-host-grp-obj-price.gop-db-num = old-host-grp-obj-price-attr.gop-db-num ~
                                           and new-host-grp-obj-price.host-code = old-host-grp-obj-price-attr.host-code " }

  { utl/00000002.i obj-grp-obj-price  "  where  old-obj-grp-obj-price.stts = 0   "  }
  if varstay-history then do:
    { utl/00000002.i c-obj-grp-obj-price  "  , first new-obj-grp-obj-price where ~
                                                new-obj-grp-obj-price.gop-id = old-c-obj-grp-obj-price.gop-id ~
                                            and new-obj-grp-obj-price.gop-db-num = old-c-obj-grp-obj-price.gop-db-num ~
                                            and new-obj-grp-obj-price.obj-type = old-c-obj-grp-obj-price.obj-type ~
                                            and new-obj-grp-obj-price.obj-code = old-c-obj-grp-obj-price.obj-code "
                                            }
  end.

  { utl/00000002.i obj-grp-obj-price-attr   ", first new-obj-grp-obj-price where ~
                                                     new-obj-grp-obj-price.gop-id = old-obj-grp-obj-price-attr.gop-id ~
                                                 and new-obj-grp-obj-price.gop-db-num = old-obj-grp-obj-price-attr.gop-db-num ~
                                                 and new-obj-grp-obj-price.obj-type = old-obj-grp-obj-price-attr.obj-type ~
                                                 and new-obj-grp-obj-price.obj-code = old-obj-grp-obj-price-attr.obj-code " }
  { utl/00000002.i qnty-group                 }
  if varstay-history then do:
    { utl/00000002.i c-qnty-group                 }
  end.
  { utl/00000002.i qnty-group-attr    }
  { utl/00000002.i qnty-in-qnty-group     " where old-qnty-in-qnty-group.stts = 0 "    }
  if varstay-history then do:
    { utl/00000002.i c-qnty-in-qnty-group     " , first new-qnty-in-qnty-group where ~
                                                     new-qnty-in-qnty-group.qgr-id = old-c-qnty-in-qnty-group.qgr-id ~
                                                 and new-qnty-in-qnty-group.qgr-db-num = old-c-qnty-in-qnty-group.qgr-db-num ~
                                                 and new-qnty-in-qnty-group.ggr-qnty = old-c-qnty-in-qnty-group.ggr-qnty " }
  end.
  { utl/00000002.i qnty-in-qnty-group-attr                " , first new-qnty-in-qnty-group where ~
                                                     new-qnty-in-qnty-group.qgr-id = old-qnty-in-qnty-group-attr.qgr-id ~
                                                 and new-qnty-in-qnty-group.qgr-db-num = old-qnty-in-qnty-group-attr.qgr-db-num ~
                                                 and new-qnty-in-qnty-group.ggr-qnty = old-qnty-in-qnty-group-attr.ggr-qnty " }

  { utl/00000002.i sum-group                  }
  if varstay-history then do:
    { utl/00000002.i c-sum-group                  }
  end.
  { utl/00000002.i sum-group-attr             }
  { utl/00000002.i sum-in-sum-group " where old-sum-in-sum-group.stts = 0 " }
  if varstay-history then do:
    { utl/00000002.i c-sum-in-sum-group ", first new-sum-in-sum-group where ~
                                                new-sum-in-sum-group.sgr-id = old-c-sum-in-sum-group.sgr-id ~
                                            and new-sum-in-sum-group.sgr-db-num = old-c-sum-in-sum-group.sgr-db-num ~
                                            and new-sum-in-sum-group.ssg-summa = old-c-sum-in-sum-group.ssg-summa ~
                                                " }
  end.

  { utl/00000002.i sum-in-sum-group-attr      ", first new-sum-in-sum-group where ~
                                                new-sum-in-sum-group.sgr-id = old-sum-in-sum-group-attr.sgr-id ~
                                            and new-sum-in-sum-group.sgr-db-num = old-sum-in-sum-group-attr.sgr-db-num ~
                                            and new-sum-in-sum-group.ssg-summa = old-sum-in-sum-group-attr.ssg-summa ~
    }

  { utl/00000002.i tnv-in-turnover-group  " where old-tnv-in-turnover-group.stts = 0  "    }
  if varstay-history then do:
    { utl/00000002.i c-tnv-in-turnover-group  " , first new-tnv-in-turnover-group where ~
                                                        new-tnv-in-turnover-group.tog-id = old-c-tnv-in-turnover-group.tog-id ~
                                                    and new-tnv-in-turnover-group.tog-db-num = old-c-tnv-in-turnover-group.tog-db-num ~
                                                    and new-tnv-in-turnover-group.ttg-summa = old-c-tnv-in-turnover-group.ttg-summa " }
  end.
  { utl/00000002.i tnv-in-turnover-group-attr " , first new-tnv-in-turnover-group where ~
                                                        new-tnv-in-turnover-group.tog-id = old-tnv-in-turnover-group-attr.tog-id ~
                                                    and new-tnv-in-turnover-group.tog-db-num = old-tnv-in-turnover-group-attr.tog-db-num ~
                                                    and new-tnv-in-turnover-group.ttg-summa = old-tnv-in-turnover-group-attr.ttg-summa " }

  { utl/00000002.i turnover-group             }
  if varstay-history then do:
    { utl/00000002.i c-turnover-group             }
  end.

  { utl/00000002.i turnover-group-attr        }

  { utl/00000002.i turnover-buyer           }
  { utl/00000002.i turnover-buyer-attr      }
  { utl/00000002.i turnover-buyer-gds     " , first new-goods where new-goods.gds-code = old-turnover-buyer-gds.gds-code "  }
  { utl/00000002.i turnover-buyer-gds-attr " , first new-goods where new-goods.gds-code = old-turnover-buyer-gds-attr.gds-code "   }
  { utl/00000002.i turnover-buyer-main      }
  { utl/00000002.i turnover-buyer-main-attr }
  { utl/00000002.i buyer-group               }
  if varstay-history then do:
    { utl/00000002.i c-buyer-group               }
  end.
  { utl/00000002.i buyer-group-attr          }
  { utl/00000002.i buyer-in-buyer-group      }
  if varstay-history then do:
    { utl/00000002.i c-buyer-in-buyer-group      }
  end.
  { utl/00000002.i buyer-in-buyer-group-attr }

output stream str-gen close.
  return "Произведен экспорт таблиц:
  price-list-type ~
  c-price-list-type ~
  price-list-type-attr  ~
  c-price-list-type-attr  ~
  price-list-type-cash-pay ~
  c-price-list-type-cash-pay ~
  price-list-type-cassa ~
  c-price-list-type-cassa ~
  price-list-type-gds-grp ~
  c-price-list-type-gds-grp ~
  price-list-type-pay-type ~
  c-price-list-type-pay-type ~
  global-state ~
  c-global-state ~
  global-state-attr ~
  c-global-state-attr ~
  qnty-group  ~
  c-qnty-group ~
  qnty-in-qnty-group  ~
  c-qnty-in-qnty-group ~
  turnover-buyer ~
  turnover-buyer-attr ~
  turnover-buyer-gds ~
  turnover-buyer-gds-attr ~
  turnover-buyer-main ~
  turnover-buyer-main-attr  ~
  tnv-in-turnover-group ~
  c-tnv-in-turnover-group ~
  turnover-group ~
  c-turnover-group ~
  tnv-in-turnover-group-attr ~
  turnover-group-attr ~
  buyer-group ~
  c-buyer-group  ~
  buyer-group-attr  ~
  buyer-in-buyer-group ~
  c-buyer-in-buyer-group ~
  buyer-in-buyer-group-attr ~
  grp-obj-price ~
  c-grp-obj-price ~
  db-grp-obj-price ~
  c-db-grp-obj-price ~
  host-grp-obj-price ~
  c-host-grp-obj-price ~
  obj-grp-obj-price  ~
  c-obj-grp-obj-price ~
  grp-obj-price-attr ~
  db-grp-obj-price-attr ~
  host-grp-obj-price-attr ~
  obj-grp-obj-price-attr  ~
  sum-group ~
  c-sum-group ~
  sum-in-sum-group ~
  c-sum-in-sum-group ~
  sum-group-attr   ~
  sum-in-sum-group-attr ~
  . " .
end.