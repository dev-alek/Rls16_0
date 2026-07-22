/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обороты по покупателю

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
    when "turnover-buyer" then do:
      create locb-turnover-buyer.
      { nws/impl-nws.i "turnover-buyer" "locb-" }
    end.

    when "turnover-buyer-gds" then do:
      create locb-turnover-buyer-gds.
      { nws/impl-nws.i "turnover-buyer-gds" "locb-" }
    end.

    when "turnover-buyer-gds-attr" then do:
      create locb-turnover-buyer-gds-attr.
      { nws/impl-nws.i "turnover-buyer-gds-attr" "locb-" }
    end.

    when "turnover-buyer-attr" then do:
      create locb-turnover-buyer-attr.
      { nws/impl-nws.i "turnover-buyer-attr" "locb-" }
    end.

    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.


/* ------------------------------- turnover-buyer-gds ---------------------------------------------- */
for each buf_turnover-buyer-gds where buf_turnover-buyer-gds.cli-code = wt-turnover-buyer-main.cli-code
                            and buf_turnover-buyer-gds.cli-type = wt-turnover-buyer-main.cli-type
                            and buf_turnover-buyer-gds.obj-type = wt-turnover-buyer-main.obj-type
                            and buf_turnover-buyer-gds.obj-code = wt-turnover-buyer-main.obj-code
on error  undo, return error
:
  delete buf_turnover-buyer-gds.
end.

for each locb-turnover-buyer-gds where locb-turnover-buyer-gds.cli-code     = wt-turnover-buyer-main.cli-code
                             and locb-turnover-buyer-gds.cli-type = wt-turnover-buyer-main.cli-type
                             and locb-turnover-buyer-gds.obj-type = wt-turnover-buyer-main.obj-type
                             and locb-turnover-buyer-gds.obj-code = wt-turnover-buyer-main.obj-code
  no-lock
on error  undo, return error
:
  create buf_turnover-buyer-gds.
  buffer-copy  locb-turnover-buyer-gds to buf_turnover-buyer-gds.
end.

/* ------------------------------- turnover-buyer-gds-attr ---------------------------------------------- */
for each buf_turnover-buyer-gds-attr where buf_turnover-buyer-gds-attr.cli-code = wt-turnover-buyer-main.cli-code
                            and buf_turnover-buyer-gds-attr.cli-type = wt-turnover-buyer-main.cli-type
                            and buf_turnover-buyer-gds-attr.obj-type = wt-turnover-buyer-main.obj-type
                            and buf_turnover-buyer-gds-attr.obj-code = wt-turnover-buyer-main.obj-code

on error  undo, return error
:
  delete buf_turnover-buyer-gds-attr.
end.

for each locb-turnover-buyer-gds-attr where locb-turnover-buyer-gds-attr.cli-code     = wt-turnover-buyer-main.cli-code
                             and locb-turnover-buyer-gds-attr.cli-type = wt-turnover-buyer-main.cli-type
                             and locb-turnover-buyer-gds-attr.obj-type = wt-turnover-buyer-main.obj-type
                             and locb-turnover-buyer-gds-attr.obj-code = wt-turnover-buyer-main.obj-code

  no-lock
on error  undo, return error
:
  create buf_turnover-buyer-gds-attr.
  buffer-copy  locb-turnover-buyer-gds-attr to buf_turnover-buyer-gds-attr.
end.


/* ------------------------------- turnover-buyer-attr ---------------------------------------------- */
for each buf_turnover-buyer-attr where buf_turnover-buyer-attr.cli-code     = wt-turnover-buyer-main.cli-code
                                  and buf_turnover-buyer-attr.cli-type = wt-turnover-buyer-main.cli-type
                                  and buf_turnover-buyer-attr.obj-type = wt-turnover-buyer-main.obj-type
                                  and buf_turnover-buyer-attr.obj-code = wt-turnover-buyer-main.obj-code

on error  undo, return error
:
  delete buf_turnover-buyer-attr.
end.

for each locb-turnover-buyer-attr where locb-turnover-buyer-attr.cli-code     = wt-turnover-buyer-main.cli-code
                                    and locb-turnover-buyer-attr.cli-type = wt-turnover-buyer-main.cli-type
                                    and locb-turnover-buyer-attr.obj-type = wt-turnover-buyer-main.obj-type
                                    and locb-turnover-buyer-attr.obj-code = wt-turnover-buyer-main.obj-code

no-lock
on error  undo, return error
:
  create buf_turnover-buyer-attr.
  buffer-copy locb-turnover-buyer-attr to buf_turnover-buyer-attr.
end.
/* ------------------------------- turnover-buyer ---------------------------------------------- */
for each buf_turnover-buyer where buf_turnover-buyer.cli-code = wt-turnover-buyer-main.cli-code
                              and buf_turnover-buyer.cli-type = wt-turnover-buyer-main.cli-type
                              and buf_turnover-buyer.obj-type = wt-turnover-buyer-main.obj-type
                              and buf_turnover-buyer.obj-code = wt-turnover-buyer-main.obj-code

on error  undo, return error
:
  delete buf_turnover-buyer.
end.

for each locb-turnover-buyer where locb-turnover-buyer.cli-code = wt-turnover-buyer-main.cli-code
                                    and locb-turnover-buyer.cli-type = wt-turnover-buyer-main.cli-type
                                    and locb-turnover-buyer.obj-type = wt-turnover-buyer-main.obj-type
                                    and locb-turnover-buyer.obj-code = wt-turnover-buyer-main.obj-code

no-lock
on error  undo, return error
:
  create buf_turnover-buyer.
  buffer-copy locb-turnover-buyer to buf_turnover-buyer.
end.

/* ------------------------------- turnover-buyer-main ---------------------------------------------- */
if not available tb-turnover-buyer-main then do:
  create tb-turnover-buyer-main.
end.
buffer-copy wt-turnover-buyer-main to tb-turnover-buyer-main.

/*------------------------- почиcтим за cобой ----------------------------------------------- */
for each locb-turnover-buyer
on error  undo, return error
:
  delete locb-turnover-buyer.
end.


for each locb-turnover-buyer-gds
on error  undo, return error
:
  delete locb-turnover-buyer-gds.
end.

for each locb-turnover-buyer-gds-attr
on error  undo, return error
:
  delete locb-turnover-buyer-gds-attr.
end.

for each locb-turnover-buyer-attr
on error  undo, return error
:
  delete locb-turnover-buyer-attr.
end.

/* $Workfile$ e n d */