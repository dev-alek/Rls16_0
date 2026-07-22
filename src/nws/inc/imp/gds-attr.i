/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Опеределения для приема атрибутов товара на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/30/03
Author: Bakhtadze Natalya
Creation date: 06/30/03

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-type           as character no-undo .
define variable v-format         as character no-undo .
define variable v-label          as character no-undo .
define variable v-user-can-edit  as logical   no-undo .
define variable v-output-display as logical   no-undo .
define variable v-other          as character no-undo .
define variable jj as integer no-undo .
define variable v-dop1 as character no-undo .

if not available tb-goods-attr then do:
  create tb-goods-attr.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-goods-attr TO wt-goods-attr case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-goods-attr TO tb-goods-attr.
  /*выясним касается ли это кассы - если да то сохраним во временных таблицах*/
     &scop proc-name gds-attr-name
    {&run_proc_attr-lib}
        ( input  tb-goods-attr.attr-code
        ,output v-type
        ,output v-format
        ,output v-label
        ,output v-user-can-edit
        ,output v-output-display
        ,output v-other
      ) .
  _do:
  do jj = 1 to num-entries(v-other, {&slash-char}):
    assign
    v-dop1 = entry(1, entry(jj, v-other, {&slash-char}), '=':U)
    .
    if v-dop1 = "cd":U then do:
      run fill-g-list in p-imp-handle ( input tb-goods-attr.gds-code
                                       ,input ""
                                       ,input 0
                                      ).

      LEAVE _do.
    end.
  end.
end.

/* $Workfile$ e n d */