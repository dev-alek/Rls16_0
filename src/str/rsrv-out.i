/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Резервирование через o u t - p r t . w

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 09/20/05


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

assign
  chg-qnty = {2} - ub.gds-dtl.{1}-qnty
.
&if "{3}":U <> "not-rsrv":U and "{3}":U <> "is-marks":U &then
  run trg/rsrv-dtl.p
    ( input        ParParentProc
    , input        {&rsrv-dtl_action_reserv}
    , buffer       ub.gds-dtl
    , input-output chg-qnty
    , input-output ub.doc-line.price-base
    , input-output ub.doc-line.price-rubl
    , input        -1
    , input         "" ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "rsrv-dtl.p {1}"
      view-as alert-box error
.
    undo, return error return-value .
  end.
&endif
&if "{3}":U = "is-marks":U &then
  run trg/rsrv-dtl.p
    ( input        ParParentProc
    , input        {&rsrv-dtl_action_reserv}
    , buffer       ub.gds-dtl
    , input-output chg-qnty
    , input-output ub.doc-line.price-base
    , input-output ub.doc-line.price-rubl
    , input        -1
    , input         {4}) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "rsrv-dtl.p {1}"
      view-as alert-box error
    .
    undo, return error return-value .
  end.
&endif
&if "{1}":U = "doc":U &then
  if lookup( t-doc.doc-type, {&expense_write-off_return} ) > 0 or
     ( t-doc.doc-type = {&income} and
       t-doc.internal = yes )
  then do:
    assign
      ub.doc-line.doc-qnty  = ub.doc-line.doc-qnty + chg-qnty
      ub.doc-line.fact-qnty = ub.doc-line.doc-qnty
    .
    if ub.doc-line.doc-density <> ? and ub.doc-line.doc-density <> 0 then do:
      assign
        ub.doc-line.cli-qnty = ub.doc-line.doc-qnty * ub.doc-line.doc-density
      .
    end.
    else do:
      assign
        ub.doc-line.cli-qnty = ub.doc-line.doc-qnty / ub.doc-line.cli-base-rate
      .
    end.
  end.
  assign
    ub.gds-dtl.doc-qnty  = ub.gds-dtl.doc-qnty + chg-qnty
    ub.gds-dtl.fact-qnty = ub.gds-dtl.doc-qnty
  .
&else /* fact */
  if lookup( t-doc.doc-type, {&expense_write-off_return} ) > 0 or
     ( t-doc.doc-type = {&income} and
       t-doc.internal = yes )
  then do:
    assign
      ub.doc-line.fact-qnty = ub.doc-line.fact-qnty + chg-qnty
    .
  end.
  assign
    ub.gds-dtl.fact-qnty = ub.gds-dtl.fact-qnty + chg-qnty
  .
&endif

/* e n d  o f   r s r v - o u t . i */