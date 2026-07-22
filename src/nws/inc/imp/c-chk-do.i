/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием истории по чекам через новости

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

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
    when "c-chk-gds" then do:
      create locb2-c-chk-gds.
      { nws/impl-nws.i "c-chk-gds" "locb2-" }
    end.
    when "c-chk-pay" then do:
      create locb2-c-chk-pay.
      { nws/impl-nws.i "c-chk-pay" "locb2-" }
    end.
    when "c-chk-discnt" then do:
      create locb2-c-chk-discnt.
      { nws/impl-nws.i "c-chk-discnt" "locb2-" }
    end.
    when "c-chk-doc-attr" then do:
      create locb2-c-chk-doc-attr.
      { nws/impl-nws.i "c-chk-doc-attr" "locb2-" }
    end.

    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе истории чека"
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.


if not available tb-c-chk-doc then do:
  create tb-c-chk-doc.
end.


/* обновляем историю чека */
buffer-copy wt-c-chk-doc to tb-c-chk-doc.

/* ------------------------------- c-chk-doc-attr --------------------------------------------- */
for each buf_c-chk-doc-attr where
        buf_c-chk-doc-attr.doc-code = wt-c-chk-doc.doc-code
   AND  buf_c-chk-doc-attr.chip-num = wt-c-chk-doc.chip-num
on error  undo, return error
:
  delete buf_c-chk-doc-attr.
end.
for each locb2-c-chk-doc-attr where
        locb2-c-chk-doc-attr.doc-code = wt-c-chk-doc.doc-code
   AND  locb2-c-chk-doc-attr.chip-num = wt-c-chk-doc.chip-num   no-lock
on error  undo, return error
:
  create buf_c-chk-doc-attr.
  buffer-copy locb2-c-chk-doc-attr to buf_c-chk-doc-attr.
end.

/* ------------------------------- c-chk-gds --------------------------------------------- */
for each buf_c-chk-gds where
        buf_c-chk-gds.doc-code = wt-c-chk-doc.doc-code
   AND  buf_c-chk-gds.chip-num = wt-c-chk-doc.chip-num
on error  undo, return error
:
  delete buf_c-chk-gds.
end.
for each locb2-c-chk-gds where
        locb2-c-chk-gds.doc-code = wt-c-chk-doc.doc-code
   AND  locb2-c-chk-gds.chip-num = wt-c-chk-doc.chip-num    no-lock
on error  undo, return error
:
  create buf_c-chk-gds.
  buffer-copy locb2-c-chk-gds to buf_c-chk-gds.
end.
/* ------------------------------- c-chk-pay ---------------------------------------------- */
for each buf_c-chk-pay where
        buf_c-chk-pay.doc-code = wt-c-chk-doc.doc-code
    AND buf_c-chk-pay.chip-num = wt-c-chk-doc.chip-num
on error  undo, return error
:
  delete buf_c-chk-pay.
end.
for each locb2-c-chk-pay where
        locb2-c-chk-pay.doc-code = wt-c-chk-doc.doc-code
    AND locb2-c-chk-pay.chip-num = wt-c-chk-doc.chip-num   no-lock
on error  undo, return error
:
  create buf_c-chk-pay.
  buffer-copy locb2-c-chk-pay to buf_c-chk-pay.
end.
/* ------------------------------- c-chk-discnt --------------------------------------------- */
for each buf_c-chk-discnt where
       buf_c-chk-discnt.doc-code = wt-c-chk-doc.doc-code
   AND buf_c-chk-discnt.chip-num = wt-c-chk-doc.chip-num
on error  undo, return error
:
  delete buf_c-chk-discnt.
end.
for each locb2-c-chk-discnt where
        locb2-c-chk-discnt.doc-code = wt-c-chk-doc.doc-code
    AND locb2-c-chk-discnt.chip-num = wt-c-chk-doc.chip-num  no-lock
on error  undo, return error
:
  create buf_c-chk-discnt.
  buffer-copy locb2-c-chk-discnt to buf_c-chk-discnt.
end.


/* ------------------------ почистим за собой ---------------------------------------------- */

for each locb2-c-chk-gds
on error  undo, return error
:
  delete locb2-c-chk-gds.
end.
for each locb2-c-chk-pay
on error  undo, return error
:
  delete locb2-c-chk-pay.
end.
for each locb2-c-chk-discnt
on error  undo, return error
:
  delete locb2-c-chk-discnt.
end.
for each locb2-c-chk-doc-attr
on error  undo, return error
:
  delete locb2-c-chk-doc-attr.
end.


/* $Workfile$ e n d */