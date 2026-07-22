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

if not available tb-gds-obj-attr then do:
  create tb-gds-obj-attr.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-gds-obj-attr TO wt-gds-obj-attr case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-gds-obj-attr TO tb-gds-obj-attr.
  /*выясним касается ли это кассы - если да то сохраним во временных таблицах*/
    run gdsoattr-name in p-imp-handle
      ( input  tb-gds-obj-attr.attr-code
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
      run fill-g-list in p-imp-handle ( input tb-gds-obj-attr.gds-code
                                      ,input tb-gds-obj-attr.obj-type
                                      ,input tb-gds-obj-attr.obj-code
                                      ).

      LEAVE _do.
    end.
  end.
end.

/* $Workfile$ e n d */