/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инклюд по настройкам пользователя для экрана остатков

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

*/
define temp-table tt-usrstko no-undo
field user-name     as   character
field obj-type      like ub.clients.obj-type
field obj-code      like ub.clients.obj-code
field obj-name      like ub.clients.obj-name
field main-obj-type like ub.clients.obj-type
field main-obj-code like ub.clients.obj-code
field main-obj-name like ub.clients.obj-name
field level         as   integer
field host-code     like ub.clients.obj-code
field host-name     like ub.clients.obj-name
field db-num        like ub.db.db-num
index pi is unique primary user-name obj-type obj-code
index level is unique user-name level.

PROCEDURE loadusr-tt :
define input parameter paruser-name as character no-undo.
define buffer bf_clients      for ub.clients.
define buffer bf_main-clients for ub.clients.
define buffer bf_usr-flt      for ubflt.usr-flt.
define buffer bf_shop         for ub.shop.
define buffer bf_store        for ub.store.
define buffer bf_host-clients for ub.clients.
define buffer bf_db           for ub.db.
for each tt-usrstko:
  delete tt-usrstko.
end.
for each bf_usr-flt where bf_usr-flt.user-name  = paruser-name     and
                          bf_usr-flt.call-point begins "stockscr"   :

  create tt-usrstko.
  assign
    tt-usrstko.user-name    = paruser-name
    tt-usrstko.obj-type      = substring(bf_usr-flt.call-point, 9, 3)
    tt-usrstko.obj-code      = integer(substring(bf_usr-flt.call-point, 12))
    tt-usrstko.level         = integer(entry(1, bf_usr-flt.naim))
    tt-usrstko.main-obj-type = substring(bf_usr-flt.list_, 1, 3)
    tt-usrstko.main-obj-code = integer(substring(bf_usr-flt.list_, 4)).


  if tt-usrstko.main-obj-code <> ? then do:
    find first bf_main-clients where bf_main-clients.obj-type = tt-usrstko.main-obj-type and
                                     bf_main-clients.obj-code = tt-usrstko.main-obj-code no-lock.
    assign
      tt-usrstko.main-obj-name = bf_main-clients.obj-name.
  end.
  if tt-usrstko.obj-type = {&shop} then do:
    find first bf_shop where bf_shop.obj-code = tt-usrstko.obj-code no-lock.
    find first bf_host-clients where bf_host-clients.obj-type = {&cmp} and
                                     bf_host-clients.obj-code =  bf_shop.host-code no-lock.
  end.
  else do:
    find first bf_store where bf_store.obj-code = tt-usrstko.obj-code no-lock.
    find first bf_host-clients where bf_host-clients.obj-type = {&cmp}             and
                                     bf_host-clients.obj-code = bf_store.host-code no-lock.
  end.
  assign
    tt-usrstko.host-code = bf_host-clients.obj-code
    tt-usrstko.host-name = bf_host-clients.obj-name.
  find first bf_clients where bf_clients.obj-type = tt-usrstko.obj-type and
                              bf_clients.obj-code = tt-usrstko.obj-code no-lock.
  find first bf_db where bf_db.db-num = bf_clients.db-num no-lock.
  assign
    tt-usrstko.obj-name = bf_clients.obj-name
    tt-usrstko.db-num   = bf_db.db-num.
end.
END PROCEDURE.