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
PROCEDURE obji-add :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-dgo-db-num   as integer   no-undo .
define input  parameter p-stts         as integer   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .
define output parameter p-recid as recid no-undo .

  do
  on error undo, return error return-value
  :

find first ub.grp-obj-price exclusive-lock where
        ub.grp-obj-price.gop-db-num   = p-db-num  and
        ub.grp-obj-price.gop-id       = p-id
        no-error .
  if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        ""
        view-as alert-box error
      .
      return error .
  end.

find first ub.db-grp-obj-price exclusive-lock where
        ub.db-grp-obj-price.gop-db-num   = p-db-num  and
        ub.db-grp-obj-price.gop-id       = p-id      and
        ub.db-grp-obj-price.dgo-db-num   = p-dgo-db-num
        no-error .
      if not available ub.db-grp-obj-price then do:
          create ub.db-grp-obj-price.
            assign
                ub.db-grp-obj-price.gop-db-num = p-db-num
                ub.db-grp-obj-price.gop-id     = p-id
                ub.db-grp-obj-price.dgo-db-num = p-dgo-db-num
            .
      end.
      assign
        ub.db-grp-obj-price.num-chg    = p-db-num-usr
        ub.db-grp-obj-price.stts          = p-stts
        ub.db-grp-obj-price.sys-date      = today
        ub.db-grp-obj-price.sys-time      = time
        ub.db-grp-obj-price.sys-time-chr  = string ( ub.db-grp-obj-price.sys-time,"hh:mm" )
        ub.db-grp-obj-price.who           = p-userid
        p-recid = recid ( ub.db-grp-obj-price )
      .
      ub.grp-obj-price.sys-time = time .
      run ref/h-grpo.p (buffer ub.db-grp-obj-price , input-output v-sec )  .

  end.

end procedure. /* obji-add */

PROCEDURE obji-del :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-dgo-db-num   as integer   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .

  do
  on error undo, return error return-value
  :

find first ub.grp-obj-price exclusive-lock where
        ub.grp-obj-price.gop-db-num   = p-db-num  and
        ub.grp-obj-price.gop-id       = p-id
        .

find first ub.db-grp-obj-price exclusive-lock where
        ub.db-grp-obj-price.gop-db-num   = p-db-num  and
        ub.db-grp-obj-price.gop-id       = p-id      and
        ub.db-grp-obj-price.dgo-db-num = p-dgo-db-num
        no-error .

 if not available ub.db-grp-obj-price then  return error .
      assign
        ub.db-grp-obj-price.num-chg    = p-db-num-usr
        ub.db-grp-obj-price.stts          = 1
        ub.db-grp-obj-price.sys-date      = today
        ub.db-grp-obj-price.sys-time      = time
        ub.db-grp-obj-price.sys-time-chr  = string(ub.db-grp-obj-price.sys-time,"hh:mm")
        ub.db-grp-obj-price.who           = p-userid
      .
      run ref/h-grpo.p (buffer ub.db-grp-obj-price , input-output v-sec )  .
      ub.grp-obj-price.sys-time = time .
  end.

end procedure. /* obji-del */

PROCEDURE objf-add :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-host-code    as integer   no-undo .
define input  parameter p-stts         as integer   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .
define output parameter p-recid as recid no-undo .

  do
  on error undo, return error return-value
  :
find first ub.sysconf no-lock where recid(ub.sysconf) = p-host-code .
if available ub.sysconf then do:
   p-host-code = ub.sysconf.host-code .
end.

find first ub.grp-obj-price exclusive-lock where
        ub.grp-obj-price.gop-db-num   = p-db-num  and
        ub.grp-obj-price.gop-id       = p-id
        .

find first ub.host-grp-obj-price exclusive-lock where
        ub.host-grp-obj-price.gop-db-num   = p-db-num  and
        ub.host-grp-obj-price.gop-id       = p-id      and
        ub.host-grp-obj-price.host-code    = p-host-code
        no-error .
      if not available ub.host-grp-obj-price then do:
          create ub.host-grp-obj-price.
            assign
                ub.host-grp-obj-price.gop-db-num   = p-db-num
                ub.host-grp-obj-price.gop-id       = p-id
                ub.host-grp-obj-price.host-code    = p-host-code
            .
      end.
      assign
        ub.host-grp-obj-price.db-num-chg    = p-db-num-usr
        ub.host-grp-obj-price.stts          = p-stts
        ub.host-grp-obj-price.sys-date      = today
        ub.host-grp-obj-price.sys-time      = time
        ub.host-grp-obj-price.sys-time-chr  = string ( ub.host-grp-obj-price.sys-time,"hh:mm" )
        ub.host-grp-obj-price.who           = p-userid
        p-recid = recid ( ub.host-grp-obj-price )
      .
      ub.grp-obj-price.sys-time = time .
      run ref/h-grph.p (buffer ub.host-grp-obj-price , input-output v-sec )  .
  end.

end procedure. /* obji-add */

PROCEDURE objf-del :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-host-code   as integer   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .

  do
  on error undo, return error return-value
  :

find first ub.grp-obj-price exclusive-lock where
        ub.grp-obj-price.gop-db-num   = p-db-num  and
        ub.grp-obj-price.gop-id       = p-id
        .

find first ub.host-grp-obj-price exclusive-lock where
        ub.host-grp-obj-price.gop-db-num   = p-db-num  and
        ub.host-grp-obj-price.gop-id       = p-id      and
        ub.host-grp-obj-price.host-code    = p-host-code
        no-error .

 if not available ub.host-grp-obj-price then  return error .
      assign
        ub.host-grp-obj-price.db-num-chg    = p-db-num-usr
        ub.host-grp-obj-price.stts          = 1
        ub.host-grp-obj-price.sys-date      = today
        ub.host-grp-obj-price.sys-time      = time
        ub.host-grp-obj-price.sys-time-chr  = string(ub.host-grp-obj-price.sys-time,"hh:mm")
        ub.host-grp-obj-price.who           = p-userid
      .
       ub.grp-obj-price.sys-time = time .
       run ref/h-grph.p (buffer ub.host-grp-obj-price , input-output v-sec )  .
  end.

end procedure. /* obji-del */

PROCEDURE objo-add :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-obj-type     as character no-undo .
define input  parameter p-obj-code     as integer   no-undo .
define input  parameter p-stts         as integer   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .
define output parameter p-recid as recid no-undo .

  do
  on error undo, return error return-value
  :

find first ub.grp-obj-price exclusive-lock where
        ub.grp-obj-price.gop-db-num   = p-db-num  and
        ub.grp-obj-price.gop-id       = p-id
        .

find first ub.obj-grp-obj-price exclusive-lock where
        ub.obj-grp-obj-price.gop-db-num   = p-db-num  and
        ub.obj-grp-obj-price.gop-id       = p-id      and
        ub.obj-grp-obj-price.obj-type    = p-obj-type and
        ub.obj-grp-obj-price.obj-code    = p-obj-code
        no-error .
      if not available ub.obj-grp-obj-price then do:
          create ub.obj-grp-obj-price.
            assign
                ub.obj-grp-obj-price.gop-db-num   = p-db-num
                ub.obj-grp-obj-price.gop-id       = p-id
                ub.obj-grp-obj-price.obj-type    = p-obj-type
                ub.obj-grp-obj-price.obj-code    = p-obj-code
            .
      end.
      assign
        ub.obj-grp-obj-price.db-num-chg    = p-db-num-usr
        ub.obj-grp-obj-price.stts          = p-stts
        ub.obj-grp-obj-price.sys-date      = today
        ub.obj-grp-obj-price.sys-time      = time
        ub.obj-grp-obj-price.sys-time-chr  = string ( ub.obj-grp-obj-price.sys-time,"hh:mm" )
        ub.obj-grp-obj-price.who           = p-userid
        p-recid = recid ( ub.obj-grp-obj-price )
      .
      ub.grp-obj-price.sys-time = time .
      run ref/h-grpi.p (buffer ub.obj-grp-obj-price , input-output v-sec )  .
  end.

end procedure. /* obji-add */

PROCEDURE objo-del :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .

  do
  on error undo, return error return-value
  :

find first ub.grp-obj-price exclusive-lock where
        ub.grp-obj-price.gop-db-num   = p-db-num  and
        ub.grp-obj-price.gop-id       = p-id
        .

find first ub.obj-grp-obj-price exclusive-lock where
        ub.obj-grp-obj-price.gop-db-num   = p-db-num  and
        ub.obj-grp-obj-price.gop-id       = p-id      and
        ub.obj-grp-obj-price.obj-type    = p-obj-type and
        ub.obj-grp-obj-price.obj-code    = p-obj-code
        no-error .

 if not available ub.obj-grp-obj-price then  return error .
      assign
        ub.obj-grp-obj-price.db-num-chg    = p-db-num-usr
        ub.obj-grp-obj-price.stts          = 1
        ub.obj-grp-obj-price.sys-date      = today
        ub.obj-grp-obj-price.sys-time      = time
        ub.obj-grp-obj-price.sys-time-chr  = string(ub.obj-grp-obj-price.sys-time,"hh:mm")
        ub.obj-grp-obj-price.who           = p-userid
      .
     ub.grp-obj-price.sys-time = time .
     run ref/h-grpi.p (buffer ub.obj-grp-obj-price , input-output v-sec )  .
  end.

end procedure. /* obji-del */