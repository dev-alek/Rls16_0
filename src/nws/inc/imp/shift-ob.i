/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$


Автор: Суслов Алексей Юрьевич
Дата создания: 04/11/06
Author: Alexey Suslov
Creation date: 04/11/06

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
    when "shift-staff" then do:
      create locb-shift-staff.
      { nws/impl-nws.i "shift-staff" "locb-" }
    end.
    when "shift-cash" then do:
      create locb-shift-cash.
      { nws/impl-nws.i "shift-cash" "locb-" }
    end.
    when "c-shift-staff" then do:
      create locb-c-shift-staff.
      { nws/impl-nws.i "c-shift-staff" "locb-" }
    end.
    when "c-sht-hist" then do:
      create locb-c-sht-hist.
      { nws/impl-nws.i "c-sht-hist" "locb-" }
    end.
    when "c-shift-obj" then do:
      create locb-c-shift-obj.
      { nws/impl-nws.i "c-shift-obj" "locb-" }
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе смен на объекте."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/* ------------------------------- shift-staff ---------------------------------------------- */
&glob head-tbl shift-obj
&glob main-tbl shift-staff
{gbl/mergetable.i
   &bufSource = "locb-{&main-tbl}"
   &bufTarget = "buf_{&main-tbl}"
   &tableKeyMerge = "{&{&main-tbl}_primary_key}"
   &tableHeadKeyMerge = "{&{&head-tbl}_primary_key}"
   &bufHead = "wt-{&head-tbl}"
}

/* ------------------------------- shift-cash ---------------------------------------------- */
&glob main-tbl shift-cash
{gbl/mergetable.i
   &bufSource = "locb-{&main-tbl}"
   &bufTarget = "buf_{&main-tbl}"
   &tableKeyMerge = "{&{&main-tbl}_primary_key}"
   &tableHeadKeyMerge = "{&{&head-tbl}_primary_key}"
   &bufHead = "wt-{&head-tbl}"
}

/* ------------------------------- c-shift-staff ---------------------------------------------- */
&glob main-tbl c-shift-staff
{gbl/mergetable.i
   &bufSource = "locb-{&main-tbl}"
   &bufTarget = "buf_{&main-tbl}"
   &tableKeyMerge = "{&{&main-tbl}_primary_key}"
   &tableHeadKeyMerge = "{&{&head-tbl}_primary_key}"
   &bufHead = "wt-{&head-tbl}"
}

/* ------------------------------- c-sht-hist ---------------------------------------------- */
&glob main-tbl c-sht-hist
{gbl/mergetable.i
   &bufSource = "locb-{&main-tbl}"
   &bufTarget = "buf_{&main-tbl}"
   &tableKeyMerge = "{&{&main-tbl}_primary_key}"
   &addWhereMainTbl = " and buf_{&main-tbl}.corr-user-db-num = g#news-source-db"
   &tableHeadKeyMerge = "{&{&head-tbl}_primary_key}"
   &bufHead = "wt-{&head-tbl}"
}

/* ------------------------------- c-shift-obj ---------------------------------------------- */
&glob main-tbl c-shift-obj
{gbl/mergetable.i
   &bufSource = "locb-{&main-tbl}"
   &bufTarget = "buf_{&main-tbl}"
   &tableKeyMerge = "{&{&main-tbl}_primary_key}"
   &addWhereMainTbl = " and buf_{&main-tbl}.corr-user-db-num = g#news-source-db"
   &tableHeadKeyMerge = "{&{&head-tbl}_primary_key}"
   &bufHead = "wt-{&head-tbl}"
}

if not available tb-shift-obj then do:
  create tb-shift-obj.
end.
buffer-copy wt-shift-obj to tb-shift-obj.

/* -------------------- почистим за собой ------------------------ */
for each locb-shift-staff
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-shift-staff.
end.

for each locb-shift-cash
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-shift-cash.
end.

for each locb-c-shift-staff
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-shift-staff.
end.

for each locb-c-sht-hist
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-sht-hist.
end.

for each locb-c-shift-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-shift-obj.
end.
/* $Workfile$ e n d */