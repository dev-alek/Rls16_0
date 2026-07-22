block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: tckbslst.p $
$Archive: rep/tckbslst.p $

Печать ценников (этикеток) по списку scnblist

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/12/05
Author: Bakhtadze Natalya
Creation date: 09/12/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: tckbslst.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/tckbslst.p $":U .
define variable vss-description as character no-undo init "Печать ценников (этикеток) по списку scnblist".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ rep/new-prn.i new }

define variable ACTION  as character no-undo initial "LIST":U.
define variable prn-prt as logical   no-undo .

define variable v-user-id as character no-undo .
run get-userid in parparentproc
  ( output v-user-id
  ).

def NEW SHARED STREAM OutStream.

{ str/get-pr.i def }
{ rep/tick-beg.i "'bb-list'" }
{ cmp/bb-list.i scnblist def shared }

define variable how-pcnt-kat as character no-undo .
define variable dflt-cd as character no-undo .
{ str/howpcntk.i p-obj-type p-obj-code how-pcnt-kat dflt-cd no-error }
tickons = yes.

/*теперь подменим action - нам это надо чтобы печатать из списка количество нгапрямую а не пересчитывая через кратность*/
action = "list-bb".

CASE List-sort:
  when "artic":U then do:
    run scnb-list-artic in this-procedure .
  end.
  when "b-code":U then do:
    run scnb-list-b-code in this-procedure .
  end.
  when "order-num":U then do:
    run scnb-list-order-num in this-procedure .
  end.
  when "gds-name":U then do:
    run scnb-list-gds-name in this-procedure .
  end.

END CASE.

procedure scnb-list-gds-name :

  do
  on error undo, return error
  :
     { rep/tckb-lst.i scnblist gds-name }
  end.

end procedure. /* scnb-list-gds-name */

procedure scnb-list-artic :

  do
  on error undo, return error
  :
     { rep/tckb-lst.i scnblist artic }
  end.

end procedure. /* scnb-list-artic */


procedure scnb-list-b-code :

  do
  on error undo, return error
  :

  { rep/tckb-lst.i scnblist b-code }

  end.

end procedure. /* scnb-list-b-code */


procedure scnb-list-order-num :

  do
  on error undo, return error
  :

  { rep/tckb-lst.i scnblist order-num }

  end.

end procedure. /* scnb-list-order-num */