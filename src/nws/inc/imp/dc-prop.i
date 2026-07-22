/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием одиночной записи dis-card-property

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/16/07
Author: Bakhtadze Natalya
Creation date: 08/16/07

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if not available tb-dis-card-property then do:
  create tb-dis-card-property.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-dis-card-property TO wt-dis-card-property case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-dis-card-property TO tb-dis-card-property.
  v-nws-to-cd = integer({&hn-is-on}).
  find first buf_dis-card no-lock where
            buf_dis-card.d-card = tb-dis-card-property.d-card no-error.
  if available buf_dis-card then do:
    { gbl/get-hn.i
    g#db-num
    {&table_dis-card-property}
    0
    '':U
    0
    buf_Dis-card.type
    '':U
    '':U
    buf_Dis-card.emitent-host-code
    tb-dis-card-property.dtm-code
    0
    {&nws-to-cd}
    v-nws-to-cd
    no-error
    }
    if v-nws-to-cd >= 0 then do:
      run fill-dc-list in p-imp-handle ( buffer buf_Dis-card) .
    end.
  end.
end.

/* $Workfile$ e n d */