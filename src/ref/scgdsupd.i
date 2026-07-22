/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Для всех весов находит заданный товар и отмечает, что он изменился в списке на весах и на самих весах

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/
/*
1 - bar-code
2 - тип объекта
3 - код объекта
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable v-attr-code{&vssseq} as character no-undo .
define buffer buf{&vssseq}_gds-prt for ub.gds-prt.
define buffer buf{&vssseq}_bar-code for ub.bar-code.
define buffer buf{&vssseq}_scales-gds for ub.scales-gds.
define buffer buf{&vssseq}_scales for ub.scales.

find buf{&vssseq}_gds-prt no-lock
  where buf{&vssseq}_gds-prt.upper-code = {1}.prt-root
  .
find first buf{&vssseq}_bar-code no-lock
  where buf{&vssseq}_bar-code.gds-code  = {1}.gds-code
    and buf{&vssseq}_bar-code.node-code = buf{&vssseq}_gds-prt.node-code
    and buf{&vssseq}_bar-code.part-code = ""
    and buf{&vssseq}_bar-code.in-code   = ""
    and buf{&vssseq}_bar-code.unit-cli  = {1}.unit-base
  no-error .
if available buf{&vssseq}_bar-code then do: /* а в новостях он еще не принят если товар новый! */
/* идем по всем привязкам к весам по товару, проверяем нужен ли состав для этих весов и из нашего ли атрибута должен браться состав для этих весов */
  for each buf{&vssseq}_scales-gds
    where buf{&vssseq}_scales-gds.db-num = g#db-num
      AND buf{&vssseq}_scales-gds.b-code = buf{&vssseq}_bar-code.b-code
&if not "{2}" = "" and not "{3}" = "" &then
          AND buf{&vssseq}_scales-gds.obj-type = {2}
          AND buf{&vssseq}_scales-gds.obj-code = {3}

&endif
  :

    find first buf{&vssseq}_scales
      where buf{&vssseq}_scales.scales-num = buf{&vssseq}_scales-gds.scales-num
       and buf{&vssseq}_scales.db-num = buf{&vssseq}_scales-gds.db-num
      .
    &if "{5}" <> "" &then
    &scop this-scales-type buf~{&vssseq~}_scales.scales-type
    assign
    v-attr-code{&vssseq} = {&struct-attr-code} no-error .
    if lookup(buf{&vssseq}_scales.scales-type, {&struct-scales-list}) > 0
    and ({5} = "struct" or v-attr-code{&vssseq} = {5})
    then do:
    &endif
    run ref/ves-pbc.p (
                    input ? /*parparentproc - неизвестен*/
                  , input {&update}
                    , input buf{&vssseq}_scales-gds.obj-type
                    , input buf{&vssseq}_scales-gds.obj-code
                    , input ? /*p-deadline*/
                    , input ?
                    , input ?
                    , input ? /*p-wt-cart*/
                    , buffer buf{&vssseq}_bar-code
                    , buffer buf{&vssseq}_scales) .
    &if "{5}" <> "" &then
      end.
    &endif
  end.
end.

/* $Workfile$ e n d */