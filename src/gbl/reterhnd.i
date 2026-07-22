/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка ошибок которые в return-value содержат имя widget? на которые надо установитьс

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/19/03
Author: Bakhtadze Natalya
Creation date: 11/19/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{4}" <> "":U &then
&scop rv-value {4}
&else
&scop rv-value return-value
&endif

define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, {&rv-value} , {&delim-par}).
if rv <> "":U then do:
  assign
  fh = frame {&frame-name}:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
     &if "{3}" <> "no-undo" &then
      undo {2},
      &endif
      return {1}.
    end.
    hh = hh:next-sibling.
  end. /*do while*/
end. /*if return-value*/


/* $Workfile$ e n d */