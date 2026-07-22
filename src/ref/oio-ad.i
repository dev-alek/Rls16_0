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
PROCEDURE oio-ADD :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-ttg-summa    as decimal   no-undo .
define input  parameter p-use-discnt           as logical   no-undo .
define input  parameter p-discnt-pc            as decimal   no-undo .
define input  parameter p-discnt-method-round  as character no-undo .
define input  parameter p-stts         as integer   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .
define output parameter p-recid as recid no-undo .

  do
  on error undo, return error return-value
  :

find first ub.tnv-in-turnover-group exclusive-lock where
        ub.tnv-in-turnover-group.tog-db-num   = p-db-num  and
        ub.tnv-in-turnover-group.tog-id       = p-id      and
        ub.tnv-in-turnover-group.ttg-summa    = p-ttg-summa
        no-error .
      if not available ub.tnv-in-turnover-group then do:
          create ub.tnv-in-turnover-group.
            assign
                ub.tnv-in-turnover-group.tog-db-num          = p-db-num
                ub.tnv-in-turnover-group.tog-id              = p-id
                ub.tnv-in-turnover-group.ttg-summa           = p-ttg-summa
                ub.tnv-in-turnover-group.use-discnt          = p-use-discnt
                ub.tnv-in-turnover-group.discnt-pc           = p-discnt-pc
                ub.tnv-in-turnover-group.discnt-method-round = p-discnt-method-round
            .
      end.
      assign
        ub.tnv-in-turnover-group.db-num-chg    = p-db-num-usr
        ub.tnv-in-turnover-group.stts          = p-stts
        ub.tnv-in-turnover-group.sys-date      = today
        ub.tnv-in-turnover-group.sys-time      = time
        ub.tnv-in-turnover-group.sys-time-chr  = string ( ub.tnv-in-turnover-group.sys-time,"hh:mm" )
        ub.tnv-in-turnover-group.who           = p-userid
        p-recid = recid ( ub.tnv-in-turnover-group )
      .
  end.

end procedure. /* oio-add */

PROCEDURE oio-DEL :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-ttg-summa     as decimal   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .

  do
  on error undo, return error return-value
  :

find first ub.tnv-in-turnover-group exclusive-lock where
        ub.tnv-in-turnover-group.tog-db-num   = p-db-num  and
        ub.tnv-in-turnover-group.tog-id       = p-id      and
        ub.tnv-in-turnover-group.ttg-summa = p-ttg-summa
        no-error .

 if not available ub.tnv-in-turnover-group then  return error .
      assign
        ub.tnv-in-turnover-group.db-num-chg    = p-db-num-usr
        ub.tnv-in-turnover-group.stts          = 1
        ub.tnv-in-turnover-group.sys-date      = today
        ub.tnv-in-turnover-group.sys-time      = time
        ub.tnv-in-turnover-group.sys-time-chr  = string(ub.tnv-in-turnover-group.sys-time,"hh:mm")
        ub.tnv-in-turnover-group.who           = p-userid
      .

  end.

end procedure. /* oio-del */

PROCEDURE oio-update :
define input  parameter p-recid       as recid no-undo .
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-ttg-summa    as decimal   no-undo .
define input  parameter p-use-discnt           as logical   no-undo .
define input  parameter p-discnt-pc            as decimal   no-undo .
define input  parameter p-discnt-method-round  as character no-undo .
define input  parameter p-stts         as integer   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .

  do
  on error undo, return error return-value
  :

find first ub.tnv-in-turnover-group exclusive-lock where
        recid(ub.tnv-in-turnover-group) = p-recid
        no-error .
      if not available ub.tnv-in-turnover-group then do:
          create ub.tnv-in-turnover-group.
            assign
                ub.tnv-in-turnover-group.tog-db-num          = p-db-num
                ub.tnv-in-turnover-group.tog-id              = p-id
                ub.tnv-in-turnover-group.ttg-summa           = p-ttg-summa
                ub.tnv-in-turnover-group.use-discnt          = p-use-discnt
                ub.tnv-in-turnover-group.discnt-pc           = p-discnt-pc
                ub.tnv-in-turnover-group.discnt-method-round = p-discnt-method-round
            .
      end.
      assign
        ub.tnv-in-turnover-group.tog-db-num          = p-db-num
        ub.tnv-in-turnover-group.tog-id              = p-id
        ub.tnv-in-turnover-group.ttg-summa           = p-ttg-summa
        ub.tnv-in-turnover-group.use-discnt          = p-use-discnt
        ub.tnv-in-turnover-group.discnt-pc           = p-discnt-pc
        ub.tnv-in-turnover-group.discnt-method-round = p-discnt-method-round
        ub.tnv-in-turnover-group.db-num-chg    = p-db-num-usr
        ub.tnv-in-turnover-group.stts          = p-stts
        ub.tnv-in-turnover-group.sys-date      = today
        ub.tnv-in-turnover-group.sys-time      = time
        ub.tnv-in-turnover-group.sys-time-chr  = string ( ub.tnv-in-turnover-group.sys-time,"hh:mm" )
        ub.tnv-in-turnover-group.who           = p-userid
      .
  end.

end procedure. /* oio-add */