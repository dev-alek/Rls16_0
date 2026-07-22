block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: tickslst.p $
$Archive: rep/tickslst.p $

Печать ценников (этикеток) по списку

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/99
Author: Dmitry Ukhanov
Creation date: 03/22/99

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .


{ cmp/str-glbl.i }
{ cmp/library.i  }
{ rep/new-prn.i new }

define variable ACTION  as character no-undo initial "LIST":U.
define variable prn-prt as logical   no-undo .

define variable v-user-id as character no-undo .
run get-userid in parparentproc
  ( output v-user-id
  ).

def NEW SHARED STREAM OutStream.

{ str/get-pr.i def }
{ rep/tick-beg.i }
{ cmp/gds-list.i scn-list def shared }

define variable how-pcnt-kat as character no-undo .
define variable dflt-cd as character no-undo .
{ str/howpcntk.i p-obj-type p-obj-code how-pcnt-kat dflt-cd no-error }


CASE List-sort:
  when "artic":U then do:
    run scn-list-artic in this-procedure .
  end.
  when "b-code":U then do:
    run scn-list-b-code in this-procedure .
  end.
  when "order-num":U then do:
    run scn-list-order-num in this-procedure .
  end.
  when "gds-name":U then do:
    run scn-list-gds-name in this-procedure .
  end.
END CASE.

procedure scn-list-gds-name :

  do
  on error undo, return error
  :
     { rep/tick-lst.i scn-list gds-name }
  end.

end procedure. /* scn-list-gds-name */

procedure scn-list-artic :

  do
  on error undo, return error
  :
     { rep/tick-lst.i scn-list artic }
  end.

end procedure. /* scn-list-artic */


procedure scn-list-b-code :

  do
  on error undo, return error
  :

  { rep/tick-lst.i scn-list b-code }

  end.

end procedure. /* scn-list-b-code */


procedure scn-list-order-num :

  do
  on error undo, return error
  :

  { rep/tick-lst.i scn-list order-num }

  end.

end procedure. /* scn-list-order-num */