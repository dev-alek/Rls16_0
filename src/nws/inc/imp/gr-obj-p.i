/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

группы объектов

Автор: Чернова Светлана Александровна
Дата создания: 06/08/06
Author: Svetlana Chernova
Creation date: 06/08/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :

  { nws/imps-nws.i rec-full }

  assign
    rec-name = entry( 1, rec-full, {&delim-nws} )
    .

  {&test-count}

  CASE rec-name :
    when "db-grp-obj-price" then do:
      create locb-db-grp-obj-price.
      { nws/impl-nws.i "db-grp-obj-price" "locb-" }
    end.

    when "host-grp-obj-price" then do:
      create locb-host-grp-obj-price.
      { nws/impl-nws.i "host-grp-obj-price" "locb-" }
    end.

    when "obj-grp-obj-price" then do:
      create locb-obj-grp-obj-price.
      { nws/impl-nws.i "obj-grp-obj-price" "locb-" }
    end.

    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.


/* ------------------------------- host-grp-obj-price ---------------------------------------------- */
for each buf_host-grp-obj-price where buf_host-grp-obj-price.gop-id = wt-grp-obj-price.gop-id
                            and buf_host-grp-obj-price.gop-db-num = wt-grp-obj-price.gop-db-num
on error  undo, return error
:
  delete buf_host-grp-obj-price.
end.

for each locb-host-grp-obj-price where locb-host-grp-obj-price.gop-id     = wt-grp-obj-price.gop-id
                             and locb-host-grp-obj-price.gop-db-num = wt-grp-obj-price.gop-db-num
  no-lock
on error  undo, return error
:
  create buf_host-grp-obj-price.
  buffer-copy  locb-host-grp-obj-price to buf_host-grp-obj-price.
end.


/* ------------------------------- obj-grp-obj-price ---------------------------------------------- */
for each buf_obj-grp-obj-price where buf_obj-grp-obj-price.gop-id     = wt-grp-obj-price.gop-id
                                  and buf_obj-grp-obj-price.gop-db-num = wt-grp-obj-price.gop-db-num
on error  undo, return error
:
  delete buf_obj-grp-obj-price.
end.

for each locb-obj-grp-obj-price where locb-obj-grp-obj-price.gop-id     = wt-grp-obj-price.gop-id
                                    and locb-obj-grp-obj-price.gop-db-num = wt-grp-obj-price.gop-db-num
no-lock
on error  undo, return error
:
  create buf_obj-grp-obj-price.
  buffer-copy locb-obj-grp-obj-price to buf_obj-grp-obj-price.
end.
/* ------------------------------- db-grp-obj-price ---------------------------------------------- */
for each buf_db-grp-obj-price where buf_db-grp-obj-price.gop-id     = wt-grp-obj-price.gop-id
                                and buf_db-grp-obj-price.gop-db-num = wt-grp-obj-price.gop-db-num
on error  undo, return error
:
  delete buf_db-grp-obj-price.
end.

for each locb-db-grp-obj-price where locb-db-grp-obj-price.gop-id = wt-grp-obj-price.gop-id
                                    and locb-db-grp-obj-price.gop-db-num = wt-grp-obj-price.gop-db-num
no-lock
on error  undo, return error
:
  create buf_db-grp-obj-price.
  buffer-copy locb-db-grp-obj-price to buf_db-grp-obj-price.
end.

/* ------------------------------- grp-obj-price ---------------------------------------------- */
if not available tb-grp-obj-price then do:
  create tb-grp-obj-price.
end.
buffer-copy wt-grp-obj-price to tb-grp-obj-price.

/*------------------------- почиcтим за cобой ----------------------------------------------- */
for each locb-db-grp-obj-price
on error  undo, return error
:
  delete locb-db-grp-obj-price.
end.


for each locb-host-grp-obj-price
on error  undo, return error
:
  delete locb-host-grp-obj-price.
end.

for each locb-obj-grp-obj-price
on error  undo, return error
:
  delete locb-obj-grp-obj-price.
end.


/* $Workfile$ e n d */