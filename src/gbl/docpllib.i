/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с таблицей резервирования партий по местам хранения.

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-doc-pl no-undo
  field pl-code          like ub.doc-pl.pl-code
  field cli-qnty         like ub.doc-pl.cli-qnty
  field cli-doc-qnty     like ub.doc-pl.cli-doc-qnty
  field cli-fact-qnty    like ub.doc-pl.cli-fact-qnty
  field doc-qnty         like ub.doc-pl.doc-qnty
  field fact-qnty        like ub.doc-pl.fact-qnty
  field db-cli-qnty      like ub.doc-pl.cli-qnty
  field db-cli-doc-qnty  like ub.doc-pl.cli-doc-qnty
  field db-cli-fact-qnty like ub.doc-pl.cli-fact-qnty
  field db-doc-qnty      like ub.doc-pl.doc-qnty
  field db-fact-qnty     like ub.doc-pl.fact-qnty

  index xpk is primary pl-code
.

procedure temp-doc-pl-clear :

  define buffer buf_temp-doc-pl for temp-doc-pl .

  do
  on error undo, return error return-value
  :
    for each buf_temp-doc-pl
    on error undo, return error return-value
    :
      delete buf_temp-doc-pl .
    end.
  end.
end procedure. /* temp-doc-pl-clear */

procedure temp-doc-pl-init :
  define input parameter p-out-code like ub.doc-pl.out-code no-undo .
  define input parameter p-gds-code like ub.doc-pl.gds-code no-undo .

  define buffer buf_doc-pl for ub.doc-pl .
  define buffer buf_temp-doc-pl for temp-doc-pl .

  do
  on error undo, return error return-value
  :
    for each buf_doc-pl share-lock
      where buf_doc-pl.out-code = p-out-code
        and buf_doc-pl.gds-code = p-gds-code
    on error undo, return error return-value
    :
      create buf_temp-doc-pl .
      assign
        buf_temp-doc-pl.pl-code          = buf_doc-pl.pl-code
        buf_temp-doc-pl.db-cli-qnty      = buf_doc-pl.cli-qnty
        buf_temp-doc-pl.db-cli-doc-qnty  = buf_doc-pl.cli-doc-qnty
        buf_temp-doc-pl.db-cli-fact-qnty = buf_doc-pl.cli-fact-qnty
        buf_temp-doc-pl.db-doc-qnty      = buf_doc-pl.doc-qnty
        buf_temp-doc-pl.db-fact-qnty     = buf_doc-pl.fact-qnty
      .
    end.
  end.
end procedure. /* temp-doc-pl-init */

procedure temp-doc-pl-accum :

  define input parameter p-pl-code       like ub.doc-pl.pl-code      no-undo .
  define input parameter p-cli-qnty      like ub.doc-pl.cli-qnty     no-undo .
  define input parameter p-doc-qnty      like ub.doc-pl.doc-qnty     no-undo .
  define input parameter p-fact-qnty     like ub.doc-pl.fact-qnty    no-undo .
  define input parameter p-cli-base-rate like ub.parts.cli-base-rate no-undo .

  define buffer buf_temp-doc-pl for temp-doc-pl .

  do
  on error undo, return error return-value
  :
    find first buf_temp-doc-pl
      where buf_temp-doc-pl.pl-code = p-pl-code
      no-error .
    if not available buf_temp-doc-pl then do:
      create buf_temp-doc-pl .
      assign
        buf_temp-doc-pl.pl-code = p-pl-code
      .
    end.

    assign
      buf_temp-doc-pl.cli-qnty      = buf_temp-doc-pl.cli-qnty      + p-cli-qnty
      buf_temp-doc-pl.cli-doc-qnty  = buf_temp-doc-pl.cli-doc-qnty  + p-doc-qnty  / p-cli-base-rate
      buf_temp-doc-pl.cli-fact-qnty = buf_temp-doc-pl.cli-fact-qnty + p-fact-qnty / p-cli-base-rate
      buf_temp-doc-pl.doc-qnty      = buf_temp-doc-pl.doc-qnty      + p-doc-qnty
      buf_temp-doc-pl.fact-qnty     = buf_temp-doc-pl.fact-qnty     + p-fact-qnty
    .
  end.
end procedure. /* temp-doc-pl-accum */

/* $Workfile$ e n d */