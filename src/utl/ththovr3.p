block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ththovr3.p $
$Archive: utl/ththovr3.p $

Закрытие ДНЦ списком со сбрасывание конфигурационных параметров

Автор: Чернова Светлана Александровна
Дата создания: 01/25/10
Author: Svetlana Chernova
Creation date: 01/25/10

*/

define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-from-version   as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ththovr3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ththovr3.p $":U .
define variable vss-description as character no-undo init "Закрытие ДНЦ списком со сбрасывание конфигурационных параметров".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ ref/extclass.i }
{ gbl/key-rec.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/getsect.i  def}
{ cmp/obj-list.i new }
{ cmp/gds-list.i gds-list def }
{ ref/xobjgrp.i  }
{ str/hvrdtax.i  }
{ str/lib-trn.i  }
{ str/doc-code.i }
define buffer buf_price-doc-forming for ub.price-doc-forming  .
{ str/alt-calc.i "func"  }
{ str/alt-calc.i "proc" "''"  "''"  }
{ str/mpl-lib.i  }
{ str/mpl-lib3.i }
{ trg/check-bc.i }
{ str/lastincs.i }
{ ref/gdsoattr.i }
{ ref/obji-ad.i  }
{ ref/typl-ad.i  }
{ gbl/waitfram.i }
{ cmp/thth150.i }
{ cmp/thth14.i }
{ utl/ththsaco.i }

define variable v-classif-name as character no-undo .
define variable v-cli-classif-name as character no-undo .

on WRITE of ub.goods          override do: end.

define temp-table gds-list2 no-undo
field gds-code as integer
index pi gds-code
.

define buffer new_goods for ub.goods  .
empty temp-table gds-list2.


case p-from-version:
  when {&thth150-from-version} then do:
    assign
    v-classif-name = {&extclass_goods_th-th150}
    v-cli-classif-name = {&extclass_clients_th-th150}
    .
  end.
  when {&thth14-from-version} then do:
    assign
    v-classif-name = {&extclass_goods_th-th14}
    v-cli-classif-name = {&extclass_clients_th-th14}
    .
  end.
end case.

if connected ("src") then do:
  disconnect src.
end.
run save-conf-pari this-procedure .
for each new_goods exclusive-lock where
         new_goods.stts > 0 :
 find first gds-list2  where  gds-list2.gds-code = new_goods.gds-code no-error .
 if not available gds-list2 then do:
   create gds-list2 .
   assign
   gds-list2.gds-code = new_goods.gds-code
   .
 end.
 new_goods.stts = 0 .
end.

for each buf_price-doc-forming no-lock where
        buf_price-doc-forming.stts = 0
by buf_price-doc-forming.pdf-id :
  run str/diallog.w (
          input parparentproc
        , input this-procedure
        , input 'str/pdf-clos.p':U
        , ( string(recid( buf_price-doc-forming )) + {&delim-par} +
           'no' + {&delim-par} +
           'no' + {&delim-par} +
           '?' + {&delim-par} +
           '?' + {&delim-par} +
            {&fact} + {&delim-par} +
            '?' + {&delim-par} +
            string( false )  )
        , input yes /*p-auto-go*/
        , input '':U
        , input 'Закрытие ДНЦ') no-error .
end.

for each gds-list2 :
  find first ub.goods exclusive-lock where
            ub.goods.gds-code = gds-list2.gds-code no-error .
  if available ub.goods then do:
    ub.goods.stts  = 1 .
  end.
end.

run re-save-conf-par in this-procedure .