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
PROCEDURE SIS-ADD :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-ssg-summa    as decimal   no-undo .
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

find first ub.sum-in-sum-group exclusive-lock where
        ub.sum-in-sum-group.sgr-db-num   = p-db-num  and
        ub.sum-in-sum-group.sgr-id       = p-id      and
        ub.sum-in-sum-group.ssg-summa    = p-ssg-summa
        no-error .
      if not available ub.sum-in-sum-group then do:
          create ub.sum-in-sum-group.
            assign
                ub.sum-in-sum-group.sgr-db-num          = p-db-num
                ub.sum-in-sum-group.sgr-id              = p-id
                ub.sum-in-sum-group.ssg-summa           = p-ssg-summa
                ub.sum-in-sum-group.use-discnt          = p-use-discnt
                ub.sum-in-sum-group.discnt-pc           = p-discnt-pc
                ub.sum-in-sum-group.discnt-method-round = p-discnt-method-round
            .
      end.
      assign
        ub.sum-in-sum-group.db-num-chg    = p-db-num-usr
        ub.sum-in-sum-group.stts          = p-stts
        ub.sum-in-sum-group.sys-date      = today
        ub.sum-in-sum-group.sys-time      = time
        ub.sum-in-sum-group.sys-time-chr  = string ( ub.sum-in-sum-group.sys-time,"hh:mm" )
        ub.sum-in-sum-group.who           = p-userid
        ub.sum-in-sum-group.use-discnt          = p-use-discnt
        ub.sum-in-sum-group.discnt-pc           = p-discnt-pc
        ub.sum-in-sum-group.discnt-method-round = p-discnt-method-round

        p-recid = recid ( ub.sum-in-sum-group )
      .
      run ref/h-grsu.p (buffer ub.sum-in-sum-group , input-output v-sec )  .
  end.

end procedure. /* SIS-add */

PROCEDURE SIS-DEL :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-ssg-summa    as decimal   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .

  do
  on error undo, return error return-value
  :

find first ub.sum-in-sum-group exclusive-lock where
        ub.sum-in-sum-group.sgr-db-num   = p-db-num  and
        ub.sum-in-sum-group.sgr-id       = p-id      and
        ub.sum-in-sum-group.ssg-summa = p-ssg-summa
        no-error .

 if not available ub.sum-in-sum-group then  return error .
      assign
        ub.sum-in-sum-group.db-num-chg    = p-db-num-usr
        ub.sum-in-sum-group.stts          = 1
        ub.sum-in-sum-group.sys-date      = today
        ub.sum-in-sum-group.sys-time      = time
        ub.sum-in-sum-group.sys-time-chr  = string(ub.sum-in-sum-group.sys-time,"hh:mm")
        ub.sum-in-sum-group.who           = p-userid
      .
      run ref/h-grsu.p (buffer ub.sum-in-sum-group , input-output v-sec )  .

  end.

end procedure. /* SIS-del */

PROCEDURE SIS-UPDATE :
define input  parameter p-recid as recid no-undo .
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-ssg-summa    as decimal   no-undo .
define input  parameter p-use-discnt           as logical   no-undo .
define input  parameter p-discnt-pc            as decimal   no-undo .
define input  parameter p-discnt-method-round  as character no-undo .
define input  parameter p-stts         as integer   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .


  do
  on error undo, return error return-value
  :

find first ub.sum-in-sum-group exclusive-lock where
           recid(ub.sum-in-sum-group) = p-recid
           no-error .

      if not available ub.sum-in-sum-group then do:
          create ub.sum-in-sum-group.
            assign
                ub.sum-in-sum-group.sgr-db-num          = p-db-num
                ub.sum-in-sum-group.sgr-id              = p-id
                ub.sum-in-sum-group.ssg-summa           = p-ssg-summa
                ub.sum-in-sum-group.use-discnt          = p-use-discnt
                ub.sum-in-sum-group.discnt-pc           = p-discnt-pc
                ub.sum-in-sum-group.discnt-method-round = p-discnt-method-round
            .
      end.
      assign
        ub.sum-in-sum-group.sgr-db-num          = p-db-num
        ub.sum-in-sum-group.sgr-id              = p-id
        ub.sum-in-sum-group.ssg-summa           = p-ssg-summa
        ub.sum-in-sum-group.db-num-chg          = p-db-num-usr
        ub.sum-in-sum-group.stts                = p-stts
        ub.sum-in-sum-group.sys-date            = today
        ub.sum-in-sum-group.sys-time            = time
        ub.sum-in-sum-group.sys-time-chr        = string ( ub.sum-in-sum-group.sys-time , "hh:mm" )
        ub.sum-in-sum-group.who                 = p-userid
        ub.sum-in-sum-group.use-discnt          = p-use-discnt
        ub.sum-in-sum-group.discnt-pc           = p-discnt-pc
        ub.sum-in-sum-group.discnt-method-round = p-discnt-method-round
      .
      run ref/h-grsu.p (buffer ub.sum-in-sum-group , input-output v-sec )  .
  end.

end procedure. /* SIS-add */