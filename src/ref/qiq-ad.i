/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры довавления и удаления поставщика в группы

Автор: Чернова Светлана Александровна
Дата создания: 11/10/05
Author: Svetlana Chernova
Creation date: 11/10/05

*/
define variable v-sec as integer   no-undo .
PROCEDURE qIq-ADD :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-ggr-qnty    as decimal   no-undo .
define input  parameter p-use-discnt           as logical   no-undo .
define input  parameter p-discnt-pc            as decimal   no-undo .
define input  parameter p-method-round  as character no-undo .
define input  parameter p-stts         as integer   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .
define output parameter p-recid as recid no-undo .

  do
  on error undo, return error return-value
  :

if v-cntxt-db-num <> 0 then do :
   if p-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , корректировать ее в текущей БД нельзя !" , p-db-num ) .
      return error substitute(" Группа создана в другой БД (&1) , корректировать ее нельзя !" , p-db-num).
   end.
end.

find first ub.qnty-in-qnty-group exclusive-lock where
        ub.qnty-in-qnty-group.qgr-db-num   = p-db-num  and
        ub.qnty-in-qnty-group.qgr-id       = p-id      and
        ub.qnty-in-qnty-group.ggr-qnty    = p-ggr-qnty
        no-error .
      if not available ub.qnty-in-qnty-group then do:
          create ub.qnty-in-qnty-group.
            assign
                ub.qnty-in-qnty-group.qgr-db-num          = p-db-num
                ub.qnty-in-qnty-group.qgr-id              = p-id
                ub.qnty-in-qnty-group.ggr-qnty            = p-ggr-qnty
            .
      end.
      assign
        ub.qnty-in-qnty-group.use-discnt          = p-use-discnt
        ub.qnty-in-qnty-group.discnt-pc           = p-discnt-pc
        ub.qnty-in-qnty-group.method-round        = p-method-round
        ub.qnty-in-qnty-group.db-num-chg    = p-db-num-usr
        ub.qnty-in-qnty-group.stts          = p-stts
        ub.qnty-in-qnty-group.sys-date      = today
        ub.qnty-in-qnty-group.sys-time      = time
        ub.qnty-in-qnty-group.sys-time-chr  = string ( ub.qnty-in-qnty-group.sys-time,"hh:mm" )
        ub.qnty-in-qnty-group.who           = p-userid
        p-recid = recid ( ub.qnty-in-qnty-group )
      .
        run ref/h-grqu.p (buffer ub.qnty-in-qnty-group , input-output v-sec )  .
  end.

end procedure. /* SIS-add */

PROCEDURE qIq-DEL :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-ggr-qnty     as decimal   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .

  do
  on error undo, return error return-value
  :
if v-cntxt-db-num <> 0 then do :
   if p-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , удалять ее в текущей БД нельзя !" , p-db-num ) .
      return error substitute(" Группа создана в другой БД (&1) , удалять ее нельзя !" , p-db-num).
   end.
end.

find first ub.qnty-in-qnty-group exclusive-lock where
        ub.qnty-in-qnty-group.qgr-db-num   = p-db-num  and
        ub.qnty-in-qnty-group.qgr-id       = p-id      and
        ub.qnty-in-qnty-group.ggr-qnty = p-ggr-qnty
        no-error .

 if not available ub.qnty-in-qnty-group then  return error .
      assign
        ub.qnty-in-qnty-group.db-num-chg    = p-db-num-usr
        ub.qnty-in-qnty-group.stts          = 1
        ub.qnty-in-qnty-group.sys-date      = today
        ub.qnty-in-qnty-group.sys-time      = time
        ub.qnty-in-qnty-group.sys-time-chr  = string(ub.qnty-in-qnty-group.sys-time,"hh:mm")
        ub.qnty-in-qnty-group.who           = p-userid
      .
      run ref/h-grqu.p (buffer ub.qnty-in-qnty-group , input-output v-sec )  .

  end.

end procedure. /* SIS-del */

PROCEDURE qIq-update :
define input  parameter p-recid as recid no-undo .
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-ggr-qnty    as decimal   no-undo .
define input  parameter p-use-discnt           as logical   no-undo .
define input  parameter p-discnt-pc            as decimal   no-undo .
define input  parameter p-method-round  as character no-undo .
define input  parameter p-stts         as integer   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .


  do
  on error undo, return error return-value
  :
if v-cntxt-db-num <> 0 then do :
   if p-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , корректировать ее в текущей БД нельзя !" , p-db-num ) .
      return error substitute(" Группа создана в другой БД (&1) , корректировать ее нельзя !" , p-db-num).
   end.
end.

find first ub.qnty-in-qnty-group exclusive-lock where
     recid(ub.qnty-in-qnty-group )  = p-recid
        no-error .
      if not available ub.qnty-in-qnty-group then do:
          create ub.qnty-in-qnty-group.
            assign
                ub.qnty-in-qnty-group.qgr-db-num          = p-db-num
                ub.qnty-in-qnty-group.qgr-id              = p-id
                ub.qnty-in-qnty-group.ggr-qnty            = p-ggr-qnty
            .
      end.
      assign
        ub.qnty-in-qnty-group.use-discnt    = p-use-discnt
        ub.qnty-in-qnty-group.discnt-pc     = p-discnt-pc
        ub.qnty-in-qnty-group.method-round  = p-method-round
        ub.qnty-in-qnty-group.db-num-chg    = p-db-num-usr
        ub.qnty-in-qnty-group.stts          = p-stts
        ub.qnty-in-qnty-group.sys-date      = today
        ub.qnty-in-qnty-group.sys-time      = time
        ub.qnty-in-qnty-group.sys-time-chr  = string ( ub.qnty-in-qnty-group.sys-time,"hh:mm" )
        ub.qnty-in-qnty-group.who           = p-userid
        p-recid = recid ( ub.qnty-in-qnty-group )
      .
        run ref/h-grqu.p (buffer ub.qnty-in-qnty-group , input-output v-sec )  .
  end.

end procedure. /* SIS-add */