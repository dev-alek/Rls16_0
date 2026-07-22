block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: plgdssel.p $
$Archive: str/plgdssel.p $

выбор складского места

Автор: Уханов Дмитрий Юрьевич
Дата создания: 04/13/06
Author: Dmitry Ukhanov
Creation date: 04/13/06

*/

define  input parameter p-parent-proc as   widget-handle      no-undo .
define  input parameter p-obj-type    like ub.pl-gds.obj-type no-undo .
define  input parameter p-obj-code    like ub.pl-gds.obj-code no-undo .
define  input parameter p-gds-code    like ub.pl-gds.gds-code no-undo .
define output parameter p-pl-code     like ub.pl-gds.pl-code  no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: plgdssel.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/plgdssel.p $":U .
define variable vss-description as character no-undo initial "выбор складского места":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/lib-trn.i  }

define variable v_rid-list as character no-undo .
define variable is-petrol  as logical   no-undo .
define variable is-pieces  as logical   no-undo .

define buffer bf_goods  for ub.goods .
define buffer bf_pl-gds for ub.pl-gds .

assign
  p-pl-code = 0
.

find first bf_goods no-lock where
           bf_goods.gds-code = p-gds-code no-error .
if not available bf_goods
then do:
  message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
          "Не найден товар" skip( 0 )
          "Первичный бар-код" p-gds-code "." skip( 1 )
  view-as alert-box error .
  undo, return error .
end.
{ str/is-petrl.i
    bf_goods.artic
    bf_goods.prod-type
    bf_goods.prod-code
    is-petrol
    is-pieces
    no-error
}
if error-status :error
then do:
  message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
          "Ошибка при вызове программы lib-trn_is-petrl" skip( 0 )
          error-status :get-message( 1 ) skip( 0 )
          return-value skip( 1 )
  view-as alert-box error .
  undo, return error .
end.

run ref/pl-gdss.w
  (  input p-parent-proc
  ,  input "{&Btn_Select}"
  ,  input p-obj-type
  ,  input p-obj-code
  ,  input ( if is-petrol = yes and is-pieces = no then {&petrolium} else {&goods} )
  ,  input recid( bf_goods )
  ,  input ?
  , output v_rid-list
  ) no-error .
if error-status :error
then do:
  message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
          "Ошибка при вызове программы pl-gdss.w" skip( 0 )
          error-status :get-message( 1 ) skip( 0 )
          return-value skip( 1 )
  view-as alert-box error .
  undo, return error .
end.

if v_rid-list <> ?    and
   v_rid-list <> "":U
then do:
  find first bf_pl-gds no-lock where
      recid( bf_pl-gds ) = integer( entry( 1, v_rid-list ) ) no-error .
  if available bf_pl-gds
  then do:
    assign
      p-pl-code = bf_pl-gds.pl-code
    .
  end.
end.

