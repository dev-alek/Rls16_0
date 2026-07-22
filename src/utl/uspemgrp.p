block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: uspemgrp.p $
$Archive: utl/uspemgrp.p $

Пересчет По группам товара + Спецификации

Автор: Чернова Светлана Александровна
Дата создания: 10/10/08
Author: Svetlana Chernova
Creation date: 10/10/08

*/
define input  parameter p-contract-num     as integer   no-undo .
define input  parameter p-host-code as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: uspemgrp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/uspemgrp.p $":U .
define variable vss-description as character no-undo init "Пересчет По группам товара + Спецификации".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }
{ ref/grplib.i   }

run waitfram-show in this-procedure (substitute("Ждите. Идет пересчет ассортимента по группам в Спецификации &1" , p-contract-num)).

define buffer buf_gds-grp for ub.gds-grp  .
define buffer buf_contract-specif for ub.contract-specif  .
define buffer buf_goods for ub.goods  .
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .

define variable kk as integer   no-undo .
define variable v-full-name as character no-undo .

for each buf_gds-grp no-lock :
      kk = 0 .
      if buf_gds-grp.lvl-num = 0 then do:  /* всего в Спецификации */
        for each buf_contract-specif no-lock where
                 buf_contract-specif.host-code = p-host-code and
                 buf_contract-specif.contract-num = p-contract-num :
                 kk = kk + 1 .
        end.
      end.
      else do:
          run grplib-get-full-name ( input buf_gds-grp.node-code , output v-full-name).
          run waitfram-show in this-procedure (substitute("Ждите. Идет пересчет ассортимента по группам в Спецификации &1" , v-full-name)).
          for each buf_contract-specif no-lock where
                   buf_contract-specif.host-code = p-host-code and
                   buf_contract-specif.contract-num = p-contract-num ,
             first buf_goods no-lock where
                   buf_goods.gds-code = buf_contract-specif.gds-code and
                 ( buf_goods.grp-name begins v-full-name )
                  :
                  kk = kk + 1 .
          end.
      end.

      /* Запись количества */
      find first buf_gds-grp-obj-attr exclusive-lock where
                  buf_gds-grp-obj-attr.attr-code = {&ggoattr-QntySpecGr} and
                  buf_gds-grp-obj-attr.obj-type  = string(p-contract-num) and
                  buf_gds-grp-obj-attr.obj-code  = p-host-code and
                  buf_gds-grp-obj-attr.host-code = 0 and
                  buf_gds-grp-obj-attr.node-code = buf_gds-grp.node-code no-error .
      if not available buf_gds-grp-obj-attr then do:
          create buf_gds-grp-obj-attr.
               assign
                  buf_gds-grp-obj-attr.attr-code = {&ggoattr-QntySpecGr}
                  buf_gds-grp-obj-attr.obj-type  = string(p-contract-num)
                  buf_gds-grp-obj-attr.obj-code  = p-host-code
                  buf_gds-grp-obj-attr.host-code = 0
                  buf_gds-grp-obj-attr.node-code = buf_gds-grp.node-code
                  buf_gds-grp-obj-attr.attr-value = string(kk)
          .
      end.
      else do:
          if int(buf_gds-grp-obj-attr.attr-value) <> kk then buf_gds-grp-obj-attr.attr-value = string(kk) .
      end.
end.
run waitfram-hide in this-procedure .