/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ДНЦ

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
    when "utd-attr" then do:
      create locb-utd-attr.
      { nws/impl-nws.i "utd-attr" "locb-" }
    end.
    when "utd-lines" then do:
      create locb-utd-lines.
      { nws/impl-nws.i "utd-lines" "locb-" }
    end.
    when "utd-lines-attr" then do:
      create locb-utd-lines-attr.
      { nws/impl-nws.i "utd-lines-attr" "locb-" }
    end.
    when "utd-err" then do:
      create locb-utd-err.
      { nws/impl-nws.i "utd-err" "locb-" }
    end.
    when "utd-err-attr" then do:
      create locb-utd-err-attr.
      { nws/impl-nws.i "utd-err-attr" "locb-" }
    end.
    when "marking" then do:
      create locb-marking.
      { nws/impl-nws.i "marking" "locb-" }
    end.
    when "marking-attr" then do:
      create locb-marking-attr.
      { nws/impl-nws.i "marking-attr" "locb-" }
    end.
    when "utd-marking-lines" then do:
      create locb-utd-marking-lines.
      { nws/impl-nws.i "utd-marking-lines" "locb-" }
    end.
    when "utd-marking-lines-attr" then do:
      create locb-utd-marking-lines-attr.
      { nws/impl-nws.i "utd-marking-lines-attr" "locb-" }
    end.
    when "utd-lines" then do:
      create locb-utd-lines.
      { nws/impl-nws.i "utd-lines" "locb-" }
    end.
    when "utd-lines-attr" then do:
      create locb-utd-lines-attr.
      { nws/impl-nws.i "utd-lines-attr" "locb-" }
    end.
    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
MySeqUtd = ?.
/* ------------------------------- utd-attr ---------------------------------------------- */
&glob main-tbl utd-attr
{gbl/mergetable.i
   &bufSource = "locb-{&main-tbl}"
   &bufTarget = "buf_{&main-tbl}"
   &tableKeyMerge = "{&{&main-tbl}_primary_key}"
   &tableHeadKeyMerge = "doc-id db-num"
   &bufHead = "wt-utd"
}
/* ------------------------------- utd-lines ---------------------------------------------- */
&glob main-tbl utd-lines
{gbl/mergetable.i
   &bufSource = "locb-{&main-tbl}"
   &bufTarget = "buf_{&main-tbl}"
   &tableKeyMerge = "{&{&main-tbl}_primary_key}"
   &tableHeadKeyMerge = "doc-id db-num"
   &bufHead = "wt-utd"
}
/* ------------------------------- utd-lines-attr ---------------------------------------------- */
&glob main-tbl utd-lines-attr
{gbl/mergetable.i
   &bufSource = "locb-{&main-tbl}"
   &bufTarget = "buf_{&main-tbl}"
   &tableKeyMerge = "{&{&main-tbl}_primary_key}"
   &tableHeadKeyMerge = "doc-id db-num"
   &bufHead = "wt-utd"
}
/* ------------------------------- utd-err ---------------------------------------------- */
&glob main-tbl utd-err
{gbl/mergetable.i
   &bufSource = "locb-{&main-tbl}"
   &bufTarget = "buf_{&main-tbl}"
   &tableKeyMerge = "{&{&main-tbl}_primary_key}"
   &tableHeadKeyMerge = "doc-id db-num"
   &bufHead = "wt-utd"
}
/* ------------------------------- utd-err-attr ---------------------------------------------- */
&glob main-tbl utd-err-attr
{gbl/mergetable.i
   &bufSource = "locb-{&main-tbl}"
   &bufTarget = "buf_{&main-tbl}"
   &tableKeyMerge = "{&{&main-tbl}_primary_key}"
   &tableHeadKeyMerge = "doc-id db-num"
   &bufHead = "wt-utd"
}

/* ------------------------------------- marking -------------------------------------------------- */
&glob main-tbl marking
&glob addwhere or buf_{&main-tbl}.mark begins gtin
{gbl/mergetable.i
   &bufSource = "locb-{&main-tbl}"
   &bufTarget = "buf_{&main-tbl}"
   &tableKeyMerge = "{&{&main-tbl}_primary_key}"
   &beforefind = "gtin = GetCodeIdent(locb-{&main-tbl}.mark)."
}
&glob addwhere

&glob main-tbl marking-attr
{gbl/mergetable.i
   &bufSource = "locb-{&main-tbl}"
   &bufTarget = "buf_{&main-tbl}"
   &tableKeyMerge = "{&{&main-tbl}_primary_key}"
}

/* ------------------------------- utd-marking-lines ---------------------------------------------- */
&glob main-tbl utd-marking-lines
{gbl/mergetable.i
   &bufSource = "locb-{&main-tbl}"
   &bufTarget = "buf_{&main-tbl}"
   &tableKeyMerge = "{&{&main-tbl}_primary_key}"
   &tableHeadKeyMerge = "doc-id db-num"
   &bufHead = "wt-utd"
}

/* ------------------------------- utd-marking-lines-attr ---------------------------------------------- */
&glob main-tbl utd-marking-lines-attr
{gbl/mergetable.i
   &bufSource = "locb-{&main-tbl}"
   &bufTarget = "buf_{&main-tbl}"
   &tableKeyMerge = "{&{&main-tbl}_primary_key}"
   &tableHeadKeyMerge = "doc-id db-num"
   &bufHead = "wt-utd"
}
/* ------------------------------- utd ---------------------------------------------- */
if not available tb-utd then do:
  create tb-utd.
end.

buffer-copy wt-utd to tb-utd.
validate tb-utd no-error.
  if error-status:error
  then
     return error return-value.
unsubscribe "getNextseq".

/*------------------------- почиcтим за cобой ----------------------------------------------- */

for each locb-utd-lines
on error  undo, return error
:
  delete locb-utd-lines.
end.

for each locb-utd-err
on error  undo, return error
:
  delete locb-utd-err.
end.

for each locb-marking
on error  undo, return error
:
  delete locb-marking.
end.

for each locb-utd-marking-lines
on error  undo, return error
:
  delete locb-utd-marking-lines.
end.
release tb-utd.

for each locb-utd-lines-attr
on error  undo, return error
:
  delete locb-utd-lines-attr.
end.

for each locb-utd-err-attr
on error  undo, return error
:
  delete locb-utd-err-attr.
end.

for each locb-marking-attr
on error  undo, return error
:
  delete locb-marking-attr.
end.

for each locb-utd-marking-lines-attr
on error  undo, return error
:
  delete locb-utd-marking-lines-attr.
end.

for each locb-utd-attr
on error  undo, return error
:
  delete locb-utd-attr.
end.


/* $Workfile$ e n d */