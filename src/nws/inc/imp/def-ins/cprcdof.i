/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История ДНЦ

Автор: Чернова Светлана Александровна
Дата создания: 06/08/06
Author: Svetlana Chernova
Creation date: 06/08/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_c-price-doc-forming                   for ub.c-price-doc-forming          .
define buffer buf_c-price-doc-forming-attr              for ub.c-price-doc-forming-attr     .
define buffer buf_c-price-doc-forming-gds               for ub.c-price-doc-forming-gds      .
define buffer buf_c-price-doc-forming-gds-qnty          for ub.c-price-doc-forming-gds-qnty .
define buffer buf_c-price-doc-forming-gds-sum           for ub.c-price-doc-forming-gds-sum  .
define buffer buf_c-price-doc-forming-gds-tnv           for ub.c-price-doc-forming-gds-tnv  .


define variable counter  as   integer   no-undo.
define variable rec-full as   character no-undo.
define variable rec-name as   character no-undo.

for each locb-c-price-doc-forming
on error  undo, return error
:
  delete locb-c-price-doc-forming.
end.

for each locb-c-price-doc-forming-gds
on error  undo, return error
:
  delete locb-c-price-doc-forming-gds.
end.

for each lb-c-price-doc-forming-gds-qnty
on error  undo, return error
:
  delete lb-c-price-doc-forming-gds-qnty.
end.

for each locb-c-price-doc-forming-gds-sum
on error  undo, return error
:
  delete locb-c-price-doc-forming-gds-sum.
end.

for each locb-c-price-doc-forming-attr
on error  undo, return error
:
  delete locb-c-price-doc-forming-attr.
 end.

for each locb-c-price-doc-forming-gds-tnv
on error  undo, return error
:
  delete locb-c-price-doc-forming-gds-tnv.
end.