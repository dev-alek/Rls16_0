/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура проверки резервированных количеств

Автор: Чернова Светлана Александровна
Дата создания: 02/14/07
Author: Svetlana Chernova
Creation date: 02/14/07

create: Перваков Михаил Сергеевич
Дата создания: 04/11/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure rsrgdsck :
  define input  parameter p-doc-code               like ub.doc-line.doc-code  no-undo .
  define input  parameter p-doc-type               like ub.trn-doc.doc-type   no-undo .
  define input  parameter p-obj-type               like ub.doc-line.obj-type  no-undo .
  define input  parameter p-obj-code               like ub.doc-line.obj-code  no-undo .
  define input  parameter p-artic                  like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type              like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code              like ub.doc-line.prod-code no-undo .
  define output parameter p-free-parts-qnty        like ub.parts.qnty         no-undo .
  define output parameter p-free-parts-fact-qnty   like ub.parts.fact-qnty    no-undo .
  define output parameter p-free-parts-cli-qnty    like ub.parts.cli-qnty     no-undo .
  define output parameter p-free-parts-price-base  as decimal                 no-undo .
  define output parameter p-free-parts-price-rubl  as decimal                 no-undo .
  define output parameter p-out-parts-qnty         like ub.parts.qnty         no-undo .
  define output parameter p-out-parts-fact-qnty    like ub.parts.fact-qnty    no-undo .
  define output parameter p-out-parts-cli-qnty     like ub.parts.cli-qnty     no-undo .
  define output parameter p-out-parts-price-base   as decimal                 no-undo .
  define output parameter p-out-parts-price-rubl   as decimal                 no-undo .


  define buffer buf_parts    for ub.parts.


  assign
    p-free-parts-qnty       = 0
    p-free-parts-fact-qnty  = 0
    p-free-parts-cli-qnty   = 0
    p-free-parts-price-base = 0
    p-free-parts-price-rubl = 0

    p-out-parts-qnty        = 0
    p-out-parts-fact-qnty   = 0
    p-out-parts-cli-qnty    = 0
    p-out-parts-price-base  = 0
    p-out-parts-price-rubl  = 0
  .

  for each buf_parts no-lock
    where buf_parts.out-code  = p-doc-code
      and buf_parts.obj-type  = p-obj-type
      and buf_parts.obj-code  = p-obj-code
      and buf_parts.artic     = p-artic
      and buf_parts.prod-type = p-prod-type
      and buf_parts.prod-code = p-prod-code
  on error undo, return error
  :

    if can-do({&income_expense_write-off}, p-doc-type)
    or (p-doc-type = {&inventory}
        and buf_parts.fact-qnty < 0)
    then do:
      assign
        p-free-parts-qnty       = p-free-parts-qnty
                                + abs(buf_parts.qnty)
        p-free-parts-fact-qnty  = p-free-parts-fact-qnty
                                + abs(buf_parts.fact-qnty)
        p-free-parts-cli-qnty   = p-free-parts-cli-qnty
                                + abs(buf_parts.cli-qnty)
        p-free-parts-price-base = p-free-parts-price-base
                                + abs(buf_parts.fact-qnty) * buf_parts.price-base
        p-free-parts-price-rubl = p-free-parts-price-rubl
                                + abs(buf_parts.fact-qnty) * buf_parts.price-rubl
      .
    end.
    else do:
      assign
        p-out-parts-qnty        = p-out-parts-qnty
                                + buf_parts.qnty
        p-out-parts-fact-qnty   = p-out-parts-fact-qnty
                                + buf_parts.fact-qnty
        p-out-parts-cli-qnty    = p-out-parts-cli-qnty
                                + buf_parts.cli-qnty
        p-out-parts-price-base  = p-out-parts-price-base
                                + buf_parts.fact-qnty * buf_parts.price-base
        p-out-parts-price-rubl  = p-out-parts-price-rubl
                                + buf_parts.fact-qnty * buf_parts.price-rubl
      .
    end.
  end.

end procedure. /* rsrgdsck */
/* $Workfile$ e n d */