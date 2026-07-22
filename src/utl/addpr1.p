block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: addpr1.p $
$Archive: utl/addpr1.p $



Автор: Чернова Светлана Александровна
Дата создания: 12/25/09
Author: Svetlana Chernova
Creation date: 12/25/09

*/



define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: addpr1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/addpr1.p $":U .
define variable vss-description as character no-undo init "Пересчет документов по продажным ценам по партиям".

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }

define variable p-gds-code as character no-undo .
define variable p-doc-code as character no-undo .
define variable v-vat-pc as decimal   no-undo .


  run gbl/d-prompt.w
    ( 'title=Введите Основной код товара\'
    + 'format=>>>>>>>>>>9\'
    + 'type=integer\'
    ,input-output p-gds-code
    ).
  if return-value = 'false':u
  then do:
    return .
  end.

  run gbl/d-prompt.w
    ( 'title=Введите Номер переоценки обрезания\'
    + 'format=x(20)\'
    + 'type=char\'
    ,input-output p-doc-code
    ).
  if return-value = 'false':u
  then do:
    return .
  end.


find first ub.goods no-lock where
           ub.goods.gds-code = integer(p-gds-code) no-error .
if error-status :error then do:
  message 'Не верно ввведен код, товар не найден' view-as alert-box information .
  return .
end.


find first ub.price-doc no-lock where
           ub.price-doc.doc-num = p-doc-code no-error .
if error-status :error then do:
  message 'Не верно ввведен номер переоценки' view-as alert-box information .
  return .
end.


find first  ub.gds-obj no-lock where
            ub.gds-obj.gds-code = ub.goods.gds-code  and
            ub.gds-obj.obj-code =  ub.price-doc.obj-code  and
            ub.gds-obj.obj-type =  ub.price-doc.obj-type  no-error .
if not available ub.gds-obj then do:
  message 'Нет товара на объекте' view-as alert-box information .
  return .
end.

find first ub.price-list no-lock where
           ub.price-list.doc-num = ub.price-doc.doc-num and
           ub.price-list.price-type = ""   and
           ub.price-list.b-code  = ub.goods.gds-code    no-error .
if not available ub.price-list then do:

v-vat-pc = 0 .
    { gbl/pftxvalg.i
      ub.goods.gds-code
      {&vat-tax-code}
      ?
      ub.price-doc.host-code
      ub.price-doc.obj-type
      ub.price-doc.obj-code
      v-vat-pc
      no-error
      }

    create  ub.price-list.
    assign
      ub.price-list.doc-num = ub.price-doc.doc-num
      ub.price-list.price-type = ""
      ub.price-list.artic = ub.goods.artic
      ub.price-list.b-code  = ub.goods.gds-code
      ub.price-list.doc-qnty = 0
      ub.price-list.fact-order = ub.price-doc.fact-order
      ub.price-list.line-num   = 1
      ub.price-list.main-price = yes
      ub.price-list.obj-code   = ub.price-doc.obj-code
      ub.price-list.obj-type   = ub.price-doc.obj-type
      ub.price-list.price-sale = ub.gds-obj.price-sale
      ub.price-list.prod-code   = ub.goods.prod-code
      ub.price-list.prod-type   = ub.goods.prod-type
      ub.price-list.SLT-pc      = 0
      ub.price-list.VAT-pc      = v-vat-pc
    .
end.


  message "Все" view-as alert-box information .
