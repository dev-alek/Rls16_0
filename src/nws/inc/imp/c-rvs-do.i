/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

прием истории изменения документов сверки

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/19/07
Author: Dmitry Ukhanov
Creation date: 10/19/07

Автор1: Суслов Алексей Юрьевич
Дата создания1: 04/04/06

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
    when "c-rvs-line" then do:
      create locb-c-rvs-line.
      { nws/impl-nws.i "c-rvs-line" "locb-" }
    end.
    when "c-rvs-line-pump" then do:
      create locb-c-rvs-line-pump.
      { nws/impl-nws.i "c-rvs-line-pump" "locb-" }
    end.
    when "c-doc-attr" then do:
      create locbr-c-doc-attr.
      { nws/impl-nws.i "c-doc-attr" "locbr-" }
    end.
/*    when "c-rvs-line-attr" then do:*/
/*      create locbr-c-rvs-line-attr.*/
/*      { nws/impl-nws.i "c-rvs-line-attr" "locbr-" }*/
/*    end.*/

    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе производства."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

for each buf_c-rvs-line where buf_c-rvs-line.rvs-code = wt-c-rvs-doc.rvs-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-rvs-line.
end.
for each locb-c-rvs-line where locb-c-rvs-line.rvs-code = wt-c-rvs-doc.rvs-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-rvs-line.
  buffer-copy locb-c-rvs-line to buf_c-rvs-line.
end.

for each buf_c-rvs-line-pump where buf_c-rvs-line-pump.rvs-code = wt-c-rvs-doc.rvs-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-rvs-line-pump.
end.
for each locb-c-rvs-line-pump where locb-c-rvs-line-pump.rvs-code = wt-c-rvs-doc.rvs-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-rvs-line-pump.
  buffer-copy locb-c-rvs-line-pump to buf_c-rvs-line-pump.
end.
for each buf_c-doc-attr where buf_c-doc-attr.doc-code = wt-c-rvs-doc.rvs-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-doc-attr.
end.
for each locbr-c-doc-attr where locbr-c-doc-attr.doc-code = wt-c-rvs-doc.rvs-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-doc-attr.
  buffer-copy locbr-c-doc-attr to buf_c-doc-attr.
end.
/*for each buf_c-rvs-line-attr where buf_c-rvs-line-attr.rvs-code = wt-c-rvs-doc.rvs-code*/
/*on error  undo, return error*/
/*on stop   undo, return error*/
/*on endkey undo, return error :*/
/*  delete buf_c-rvs-line-attr.*/
/*end.*/
/*for each locbr-c-rvs-line-attr where locbr-c-rvs-line-attr.rvs-code = wt-c-rvs-doc.rvs-code*/
/*                       no-lock*/
/*on error  undo, return error*/
/*on stop   undo, return error*/
/*on endkey undo, return error :*/
/*  create buf_c-rvs-line-attr.*/
/*  buffer-copy locbr-c-rvs-line-attr to buf_c-rvs-line-attr.*/
/*end.*/

if not available tb-c-rvs-doc then do:
  create tb-c-rvs-doc.
end.
buffer-copy wt-c-rvs-doc to tb-c-rvs-doc.

/* -------------------- почистим за собой ------------------------ */
for each locb-c-rvs-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-rvs-line.
end.
for each locb-c-rvs-line-pump
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-rvs-line-pump.
end.
for each locbr-c-doc-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbr-c-doc-attr.
end.
/*for each locbr-c-rvs-line-attr*/
/*on error  undo, return error*/
/*on stop   undo, return error*/
/*on endkey undo, return error :*/
/*  delete locbr-c-rvs-line-attr.*/
/*end.*/

/* $Workfile$   E n d */