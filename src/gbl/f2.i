/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

просмотр карточки товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

Параметры 1 вариант:

1 - имя 1-го (единственного) browse - обязательный
  - требуется, чтобы в 1-м browse буфер назывался goods
2 - имя 2-го browse                 - необязательный
3 - имя буфера goods 2-го browse    - обязательный, если задан 2-й параметр

Параметры 2 вариант:

1 - имя 1-го (единственного) browse - обязательный
2 - goods-recid                     - зарезервированное слово
3 - имя внутренней процедуры, инициирующей gds-rec

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{4}" = "" &then
  &scop mainmenu-handle parparentproc
&else
  &scop mainmenu-handle ~{4~}
&endif

&if "{6}" = "" &then
  &scop tph ?
&else
  &scop tph {6}
&endif


&if "{2}" = "goods-recid" &then


on F9 of frame {&frame-name} anywhere do:

  run {3}.
  if gds-rec = ? then
    return no-apply.

  run ref/gds-form.w ( input {&mainmenu-handle}
                      ,input {&lookup}
                      ,input ?
                      ,input ?
                      ,input {&tph}
                      ,input-output gds-rec).

  apply "entry" to {1} in frame {&frame-name}.
  return no-apply.
end.


&else
&if "{5}" <> "" &then
  &scop goods-buffer {5}
&else
  &scop goods-buffer ub.goods
&endif

on F9 of frame {&frame-name} anywhere do:

  if not available {&goods-buffer} then
    return no-apply.
  gds-rec = recid ({&goods-buffer}).

  run ref/gds-form.w ( input {&mainmenu-handle}
                      ,input {&lookup}
                      ,input ?
                      ,input ?
                      ,input {&tph}
                      ,input-output gds-rec).

  apply "entry" to {1} in frame {&frame-name}.
  return no-apply.
end.

&if "{2}" <> "" &then

on SHIFT-F9 of frame {&frame-name} anywhere do:

  if not available {3} then
    return no-apply.
  gds-rec = recid ({3}).
  run ref/gds-form.w ( input {&mainmenu-handle}
                      ,input {&lookup}
                      ,input ?
                      ,input ?
                      ,input {&tph}
                      ,input-output gds-rec).

  apply "entry" to {2} in frame {&frame-name}.
  return no-apply.
end.

&endif


&endif

/* $Workfile$ e n d */