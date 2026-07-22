/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/18/03
Author: Bakhtadze Natalya
Creation date: 11/18/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure write-fin-doc-history :
define parameter buffer buf_fin-doc for ub.fin-doc.
define variable v-date as date no-undo .
define variable v-time as integer no-undo .

define buffer buf_c-fin-doc for ub.c-fin-doc.
define buffer buf_c-fin-doc-tax for ub.c-fin-doc-tax.
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.


  do
  on error undo, return error
  :

    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-fin-doc.
    buffer-copy buf_fin-doc to buf_c-fin-doc
    assign
    buf_c-fin-doc.chip-num           = next-value (s-corr-chip, {&db-name_schema})
    buf_c-fin-doc.corr-time          = v-time
    buf_c-fin-doc.corr-user-db-num   = g#db-num
    buf_c-fin-doc.corr-user-name     = g#userid
    buf_c-fin-doc.corr-date          = v-date
    buf_c-fin-doc.corr-doc-code      = "":U /*todo*/
    .
    for each ub.fin-doc-tax where
             ub.fin-doc-tax.host-code = buf_fin-doc.host-code
         AND ub.fin-doc-tax.fin-doc-code = buf_fin-doc.fin-doc-code:
      create buf_c-fin-doc-tax.
      buffer-copy ub.fin-doc-tax to buf_c-fin-doc-tax
      assign
      buf_c-fin-doc-tax.chip-num           = buf_c-fin-doc.chip-num
      buf_c-fin-doc-tax.corr-user-db-num   = buf_c-fin-doc.corr-user-db-num
      .
    end.
    for each ub.fin-doc-attr where
             ub.fin-doc-attr.host-code = buf_fin-doc.host-code
         AND ub.fin-doc-attr.fin-doc-code = buf_fin-doc.fin-doc-code:
      create buf_c-fin-doc-attr.
      buffer-copy ub.fin-doc-attr to buf_c-fin-doc-attr
      assign
      buf_c-fin-doc-attr.chip-num           = buf_c-fin-doc.chip-num
      buf_c-fin-doc-attr.corr-user-db-num   = buf_c-fin-doc.corr-user-db-num
      buf_c-fin-doc-attr.attr-value         = buf_c-fin-doc-attr.attr-value
      .
    end.
    release buf_c-fin-doc.
    /*чтобы отработал триггер на запись buf_c-trn-doc раньше чем отработает триггер на удаление fin-doc*/
  end. /*doe*/

end procedure. /* write-fin-doc-history */

/* $Workfile$ e n d */