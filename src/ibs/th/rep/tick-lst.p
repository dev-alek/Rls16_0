block-level on error undo, throw.
/*

$Revision: 38e7c64866ed, 3182, rls $
$Author: EShklyar $
$Date: 2022/12/27 12:54:25 $
$Workfile: tick-lst.p $
$Archive: ibs/th/rep/tick-lst.p $

Печать ценников (этикеток) по списку

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/98
Author: Dmitry Ukhanov
Creation date: 03/22/98

*/
{ cmp/gds-list.i gds-list def }
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter table for gds-list .

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ rep/new-prn.i new }

define variable action  as character no-undo initial "ALL":U.
define variable prn-prt as logical   no-undo .

define variable v-user-id as character no-undo .
run get-userid in parparentproc
  ( output v-user-id
  ).

define new shared stream outstream.

{ str/get-pr.i def }
{ rep/tick-beg.i }


define variable how-pcnt-kat as character no-undo .
define variable dflt-cd as character no-undo .
{ str/howpcntk.i p-obj-type p-obj-code how-pcnt-kat dflt-cd no-error }


CASE List-sort:
  when "artic":U then do:
    run gds-list-artic in this-procedure .
  end.
  when "b-code":U then do:
    run gds-list-b-code in this-procedure .
  end.
    when "gds-name":U then do:
    run gds-list-gds-name in this-procedure .
  end.
  when "order-num":U then do:
    run gds-list-order-num in this-procedure .
  end.
END CASE.


procedure gds-list-artic :

  do
  on error undo, return error
  :

    { rep/tick-lst.i gds-list artic }

  end.

end procedure. /* gds-list-artic */


procedure gds-list-b-code :

  do
  on error undo, return error
  :

    { rep/tick-lst.i gds-list b-code }

  end.

end procedure. /* gds-list-b-code */
procedure gds-list-gds-name :

  do
  on error undo, return error
  :

    { rep/tick-lst.i gds-list gds-name }

  end.

end procedure. /* gds-list-gds-name */

procedure gds-list-order-num :

  do
  on error undo, return error
  :

   { rep/tick-lst.i gds-list order-num }

  end.

end procedure. /* gds-list-order-num */