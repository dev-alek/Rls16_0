/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Опеределения для приема скидок товара на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/30/03
Author: Bakhtadze Natalya
Creation date: 06/30/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if not available tb-dis-gds-rule then do:
  find first buf_dis-gds-rule where
            buf_dis-gds-rule.obj-type = wt-dis-gds-rule.obj-type
        and buf_dis-gds-rule.obj-code = wt-dis-gds-rule.obj-code
        and buf_dis-gds-rule.discnt-role = wt-dis-gds-rule.discnt-role
        and buf_dis-gds-rule.pos-type = wt-dis-gds-rule.pos-type
        and buf_dis-gds-rule.gds-code = wt-dis-gds-rule.gds-code no-error.
  if available buf_dis-gds-rule then do:
    /*убиваем ту которая с nonunique = ''*/
    if (wt-dis-gds-rule.nonunique = ''
    and buf_dis-gds-rule.nonunique <> '') then do:
      v-to-del = yes.
    end.
    if (wt-dis-gds-rule.nonunique <> ''
    and buf_dis-gds-rule.nonunique = '') then do:
      delete buf_dis-gds-rule.
    end.
  end.
  create tb-dis-gds-rule.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-dis-gds-rule TO wt-dis-gds-rule case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-dis-gds-rule TO tb-dis-gds-rule.
  if lookup(wt-dis-gds-rule.pos-type, {&cd-type-codes-real}) > 0 then do:
      run fill-g-list in p-imp-handle ( input wt-dis-gds-rule.gds-code
                                      ,input wt-dis-gds-rule.obj-type
                                      ,input wt-dis-gds-rule.obj-code
                                      ).
  end.
  if v-to-del then do:
    delete tb-dis-gds-rule.
  end.
end.

/* $Workfile$ e n d */