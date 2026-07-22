/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обертка для вызова прогресс-бара из d-report.w

Автор: Хныкин Павел Андреевич
Дата создания: 03/03/08
Author: Pavel Khnykin
Creation date: 03/03/08

Использует cmp/r-page1.i для получения v-d-report-handle

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" <> "def"     and
    "{1}" <> "run"
&then
  &message prg-bar.i: Неправильное значение первого аргумента: {1} .
&endif
&if "{1}" = "def" &then
  define variable v-prg-bar_progress-bar  as class ProgressBar  no-undo .

  /* =========================================================================== */
  procedure prg-bar_new-progress-bar :
    define input  parameter p-min as int64   no-undo .
    define input  parameter p-max as int64   no-undo .
  do
  on error undo, return error return-value
  :
    if v-prg-bar_progress-bar <> ?
    then do:
      run prg-bar_delete-progress-bar in this-procedure .
    end.
    v-prg-bar_progress-bar = new progressbar( p-min , p-max ).
  end.
  end procedure.

  /* =========================================================================== */
  procedure prg-bar_delete-progress-bar :
  do
  on error undo, return error return-value
  :
    if v-prg-bar_progress-bar <> ?
    then do:
      delete object v-prg-bar_progress-bar.
      assign
        v-prg-bar_progress-bar = ?
      .
    end.
  end.
  end procedure.

  /* =========================================================================== */
  procedure prg-bar_show-progress-bar :
  do
  on error undo, return error return-value
  :
    if v-prg-bar_progress-bar <> ?
    then do:
      v-prg-bar_progress-bar :show-bar() .
    end.
  end.
  end procedure.

  /* =========================================================================== */
  procedure prg-bar_increment-progress-bar :
  do
  on error undo, return error return-value
  :
    if v-prg-bar_progress-bar <> ?
    then do:
      v-prg-bar_progress-bar :increment() .
    end.
  end.

  end procedure.

  /* =========================================================================== */
  procedure prg-bar_title-progress-bar :
    define input  parameter p-str as character no-undo .
  do
  on error undo, return error return-value
  :
    if v-prg-bar_progress-bar <> ?
    then do:
      assign
        v-prg-bar_progress-bar :frame-title = p-str
      .
    end.
  end.
  end procedure.

  /* =========================================================================== */
  procedure prg-bar_stepto-progress-bar :
    define input  parameter p-val as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if v-prg-bar_progress-bar <> ?
    then do:
        v-prg-bar_progress-bar :stepto( p-val ) .
    end.

  end.

  end procedure.
&endif
&if "{1}" = "run" &then

  define variable v-prg-bar_cb-handle     as handle             no-undo .

  /* =========================================================================== */
  procedure prg-bar_init-cb-handle :
    define input  parameter p-cb-handle as handle    no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle( p-cb-handle )
    then do:
      assign
        v-prg-bar_cb-handle = p-cb-handle
      .
    end.
    else do:
      assign
        v-prg-bar_cb-handle = ?
      .
    end.

  end.
  end procedure. /* prg-bar_init-cb-handle */

  /* =========================================================================== */
  procedure prg-bar_new :
    define input  parameter p-min as int64   no-undo .
    define input  parameter p-max as int64   no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle(v-prg-bar_cb-handle)
    then do:
      run prg-bar_new-progress-bar in v-prg-bar_cb-handle ( input p-min , input p-max ).
    end.
  end.
  end procedure.

  /* =========================================================================== */
  procedure prg-bar_delete :
  do
  on error undo, return error return-value
  :
    if valid-handle(v-prg-bar_cb-handle)
    then do:
      run prg-bar_delete-progress-bar in v-prg-bar_cb-handle .
    end.
  end.
  end procedure.

  /* =========================================================================== */
  procedure prg-bar_show :
  do
  on error undo, return error return-value
  :
    if valid-handle(v-prg-bar_cb-handle)
    then do:
      run prg-bar_show-progress-bar in v-prg-bar_cb-handle .
    end.
  end.
  end procedure.

  /* =========================================================================== */
  procedure prg-bar_increment :
  do
  on error undo, return error return-value
  :
    if valid-handle(v-prg-bar_cb-handle)
    then do:
      run prg-bar_increment-progress-bar in v-prg-bar_cb-handle.
    end.
  end.

  end procedure.

  /* =========================================================================== */
  procedure prg-bar_title :
    define input  parameter p-str as character no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle(v-prg-bar_cb-handle)
    then do:
      run prg-bar_title-progress-bar in v-prg-bar_cb-handle ( input p-str ) .
    end.
  end.
  end procedure.

  /* =========================================================================== */
  procedure prg-bar_stepto :
    define input  parameter p-val as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle(v-prg-bar_cb-handle)
    then do:
      run prg-bar_stepto-progress-bar in v-prg-bar_cb-handle ( input p-val ) .
    end.
  end.
  end procedure.

&endif
/* $Workfile$ e n d */