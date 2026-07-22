/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Формирование данных по оборотам для товара на объекте.

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич


Данные формируется в виде временной таблицы.

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&if "{1}" = "def" &then
  define temp-table tt-stk-{3}line{2} no-undo like ub.stk-{3}line.
&else
define temp-table start-stk-{3}line no-undo like ub.stk-{3}line.
define temp-table end-stk-{3}line   no-undo like ub.stk-{3}line.
procedure stk-{3}lnrv:
&SCOP find-stk-line for each ~{&prep-date}-stk-line:                                                                ~
                        delete ~{&prep-date}-stk-line.                                                              ~
                    end.                                                                                            ~
                    find last ub.stk-line where ub.stk-line.obj-type    = parobj-type                  and                ~
                                             ub.stk-line.obj-code    = parobj-code                  and                ~
                                             ub.stk-line.artic       = parartic                     and                ~
                                             ub.stk-line.prod-type   = parprod-type                 and                ~
                                             ub.stk-line.prod-code   = parprod-code                 and                ~
                                             ub.stk-line.fact-order <= parfact-order-~{&prep-date}  and                ~
                                             ub.stk-line.sum-type    = varsum-type                  and                ~
                                             ub.stk-line.cat-id      = parcat-id                    and                ~
                                             ~{&shift-or-day}                                                       ~
                                             use-index category no-lock no-error .                                   ~
                    if available ub.stk-line then do:                                                                  ~
                       create ~{&prep-date}-stk-line.                                                               ~
                       buffer-copy ub.stk-line to ~{&prep-date}-stk-line.                                              ~
                    end.
&SCOP find-stk-supp-line for each ~{&prep-date}-stk-{3}line:                                                           ~
                        delete ~{&prep-date}-stk-{3}line.                                                              ~
                    end.                                                                                               ~
                    find last ub.stk-{3}line where ub.stk-{3}line.obj-type    = parobj-type                 and              ~
                                             ub.stk-{3}line.obj-code    = parobj-code                 and                 ~
                                             ub.stk-{3}line.cli-type    = parcli-type                 and                 ~
                                             ub.stk-{3}line.cli-code    = parcli-code                 and                 ~
                                             ub.stk-{3}line.artic       = parartic                    and                 ~
                                             ub.stk-{3}line.prod-type   = parprod-type                and                 ~
                                             ub.stk-{3}line.prod-code   = parprod-code                and                 ~
                                             ub.stk-{3}line.fact-order <= parfact-order-~{&prep-date} and                 ~
                                             ub.stk-{3}line.sum-type    = varsum-type                 and                 ~
                                             ub.stk-{3}line.cat-id      = parcat-id                   and                 ~
                                             ~{&shift-or-day}                                                          ~
                                             use-index category no-lock no-error .                                      ~
                    if available ub.stk-{3}line then do:                                                                  ~
                       create ~{&prep-date}-stk-{3}line.                                                               ~
                       buffer-copy ub.stk-{3}line to ~{&prep-date}-stk-{3}line.                                           ~
                    end.

define input  parameter parobj-type         like ub.clients.obj-type       no-undo.
define input  parameter parobj-code         like ub.clients.obj-code       no-undo.
&if "{3}" = "supp-" &then
define input  parameter parcli-type         like ub.clients.obj-type       no-undo.
define input  parameter parcli-code         like ub.clients.obj-code       no-undo.
&endif
define input  parameter parartic            like ub.goods.artic            no-undo.
define input  parameter parprod-type        like ub.goods.prod-type        no-undo.
define input  parameter parprod-code        like ub.goods.prod-code        no-undo.
define input  parameter parfact-order-start like ub.stk-{3}line.fact-order no-undo.
define input  parameter parfact-order-end   like ub.stk-{3}line.fact-order no-undo.
define input  parameter parsum-type         like ub.stk-{3}line.sum-type   no-undo.
define input  parameter parcat-id           like ub.stk-{3}line.cat-id     no-undo.
define input  parameter paris-shift         as   logical                no-undo.
define output parameter table for tt-stk-{3}line{2}.

define variable i                as integer no-undo.
define variable varqnty-doc-type as integer no-undo.
define variable varsum-type like ub.stk-{3}line.sum-type no-undo.
do on error undo, return error return-value :
assign varqnty-doc-type = num-entries({&TDEDT_List}).
do i = 1 to varqnty-doc-type:
   assign varsum-type = parsum-type + ENTRY(i, {&TDEDT_LIST}).
&scop prep-date start
&if "{3}" = "supp-" &then
if paris-shift then do:
  &scop shift-or-day ub.stk-{3}line.shift-date <> ?

  {&find-stk-supp-line}
end.
else do:
  &scop shift-or-day ub.stk-{3}line.shift-date = ?

  {&find-stk-supp-line}
end.
&else
if paris-shift then do:
  &scop shift-or-day ub.stk-{3}line.shift-date <> ?

  {&find-stk-line}
end.
else do:
  &scop shift-or-day ub.stk-{3}line.shift-date = ?

  {&find-stk-line}
end.
&endif
&scop prep-date end
&if "{3}" = "supp-" &then
if paris-shift then do:
  &scop shift-or-day ub.stk-{3}line.shift-date <> ?

  {&find-stk-supp-line}
end.
else do:
  &scop shift-or-day ub.stk-{3}line.shift-date = ?

  {&find-stk-supp-line}
end.
&else
if paris-shift then do:
  &scop shift-or-day ub.stk-{3}line.shift-date <> ?

  {&find-stk-line}
end.
else do:
  &scop shift-or-day ub.stk-{3}line.shift-date = ?

  {&find-stk-line}
end.
&endif
if /*есть остатки*/
   available end-stk-{3}line   and
   /*и они разные*/
   (not available start-stk-{3}line or
   start-stk-{3}line.fact-order <> end-stk-{3}line.fact-order) then do:
      create tt-stk-{3}line{2}.
      assign
      tt-stk-{3}line{2}.obj-type       = parobj-type
      tt-stk-{3}line{2}.obj-code       = parobj-code
&if "{3}" = "supp-" &then
      tt-stk-{3}line{2}.cli-type       = parcli-type
      tt-stk-{3}line{2}.cli-code       = parcli-code
&endif
      tt-stk-{3}line{2}.artic          = parartic
      tt-stk-{3}line{2}.prod-type      = parprod-type
      tt-stk-{3}line{2}.prod-code      = parprod-code
      tt-stk-{3}line{2}.sum-type       = varsum-type
      tt-stk-{3}line{2}.cat-id         = parcat-id
      tt-stk-{3}line{2}.fact-qnty      = (if available end-stk-{3}line then (end-stk-{3}line.fact-qnty      - (if available start-stk-{3}line then start-stk-{3}line.fact-qnty      else 0)) else 0)
      tt-stk-{3}line{2}.sum-base       = (if available end-stk-{3}line then (end-stk-{3}line.sum-base       - (if available start-stk-{3}line then start-stk-{3}line.sum-base       else 0)) else 0)
      tt-stk-{3}line{2}.sum-rubl       = (if available end-stk-{3}line then (end-stk-{3}line.sum-rubl       - (if available start-stk-{3}line then start-stk-{3}line.sum-rubl       else 0)) else 0)
      tt-stk-{3}line{2}.SLT-base       = (if available end-stk-{3}line then (end-stk-{3}line.SLT-base       - (if available start-stk-{3}line then start-stk-{3}line.SLT-base       else 0)) else 0)
      tt-stk-{3}line{2}.SLT-rubl       = (if available end-stk-{3}line then (end-stk-{3}line.SLT-rubl       - (if available start-stk-{3}line then start-stk-{3}line.SLT-rubl       else 0)) else 0)
      tt-stk-{3}line{2}.VAT-base       = (if available end-stk-{3}line then (end-stk-{3}line.VAT-base       - (if available start-stk-{3}line then start-stk-{3}line.VAT-base       else 0)) else 0)
      tt-stk-{3}line{2}.VAT-rubl       = (if available end-stk-{3}line then (end-stk-{3}line.VAT-rubl       - (if available start-stk-{3}line then start-stk-{3}line.VAT-rubl       else 0)) else 0)
      tt-stk-{3}line{2}.excise-base    = (if available end-stk-{3}line then (end-stk-{3}line.excise-base    - (if available start-stk-{3}line then start-stk-{3}line.excise-base    else 0)) else 0)
      tt-stk-{3}line{2}.excise-rubl    = (if available end-stk-{3}line then (end-stk-{3}line.excise-rubl    - (if available start-stk-{3}line then start-stk-{3}line.excise-rubl    else 0)) else 0)
      tt-stk-{3}line{2}.other-base     = (if available end-stk-{3}line then (end-stk-{3}line.other-base     - (if available start-stk-{3}line then start-stk-{3}line.other-base     else 0)) else 0)
      tt-stk-{3}line{2}.other-rubl     = (if available end-stk-{3}line then (end-stk-{3}line.other-rubl     - (if available start-stk-{3}line then start-stk-{3}line.other-rubl     else 0)) else 0)
      tt-stk-{3}line{2}.road-tax-base  = (if available end-stk-{3}line then (end-stk-{3}line.road-tax-base  - (if available start-stk-{3}line then start-stk-{3}line.road-tax-base  else 0)) else 0)
      tt-stk-{3}line{2}.road-tax-rubl  = (if available end-stk-{3}line then (end-stk-{3}line.road-tax-rubl  - (if available start-stk-{3}line then start-stk-{3}line.road-tax-rubl  else 0)) else 0)
      tt-stk-{3}line{2}.transport-base = (if available end-stk-{3}line then (end-stk-{3}line.transport-base - (if available start-stk-{3}line then start-stk-{3}line.transport-base else 0)) else 0)
      tt-stk-{3}line{2}.transport-rubl = (if available end-stk-{3}line then (end-stk-{3}line.transport-rubl - (if available start-stk-{3}line then start-stk-{3}line.transport-rubl else 0)) else 0).
   end.
end.
end. /*do*/
end procedure.
&endif
/* $Workfile$ e n d */