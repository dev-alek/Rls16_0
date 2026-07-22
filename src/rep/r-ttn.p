block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-ttn.p $
$Archive: rep/r-ttn.p $

заказная программа - суммарное кол-во товаров по списку док-ов

Автор: Демин Алексей Сергеевич
Дата создания: 05/10/07
Author: Alexey Demin
Creation date: 05/10/07

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ttn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-ttn.p $":U .
define variable vss-description as character no-undo init "заказная программа - суммарное кол-во товаров по списку док-ов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define input  parameter p-doc-list as character no-undo .

define variable v-list-index as integer   no-undo .
define variable v-qnty as decimal   no-undo .
define variable is-torg12 as logical   no-undo .
define variable is-torg13 as logical   no-undo .

define buffer buf_trn-doc for trn-doc.
define buffer buf_doc-line for trn-doc.

define  stream str-export12.
define  stream str-export13.

  if p-doc-list = "" then do:
    message "Нет выбранных документов!"  view-as alert-box.
    return.
  end.

  do v-list-index = 1 to num-entries( p-doc-list ):
    find first buf_trn-doc no-lock where recid(buf_trn-doc) = int(entry( v-list-index, p-doc-list)) no-error .
    if not available buf_trn-doc then next.
    if buf_trn-doc.status_ <> {&fact} then do:
      message "Документ " buf_trn-doc.doc-code " не в статусе " {&fact} " . Пропускаем."  view-as alert-box.
      next.
    end.

    if buf_trn-doc.internal = yes then do: /* внутренний */
      if is-torg13 = no then do:
        OUTPUT STREAM str-export13 TO  VALUE("ТОРГ-13.txt").
        assign is-torg13 = yes .
      end.
    end.
    else do:
      if is-torg12 = no then do:
        OUTPUT STREAM str-export12 TO  VALUE("ТОРГ-12.txt").
        assign is-torg12 = yes .
      end.
    end.

    assign v-qnty = 0 .
    for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code :
      assign v-qnty = v-qnty + buf_doc-line.fact-qnty .
    end.
    if buf_trn-doc.internal = yes then EXPORT STREAM str-export13 buf_trn-doc.doc-code v-qnty /*string(v-qnty,">>>>>>>>>>>>9")*/ .
    else                               EXPORT STREAM str-export12 buf_trn-doc.doc-code v-qnty /*string(v-qnty,">>>>>>>>>>>>9")*/ .
  end.

  if is-torg13 = yes then OUTPUT STREAM str-export13 CLOSE.
  if is-torg12 = yes then OUTPUT STREAM str-export12 CLOSE.

  if is-torg12 = yes or is-torg13 = yes then do:
    if search ("TTH.exe") <> ? then do:
      os-command silent value(search ("TTH.exe")) .
  /*  os-command silent value(search ("TTH.exe") + " " + t-doc.doc-code + ".xml" + " " + v-sys-key).*/
    end.
    else do:
      if search ("ТТН.exe") <> ? then do:
        os-command silent value(search ("ТТН.exe")) .
/*  os-command silent value(search ("TTH.exe") + " " + t-doc.doc-code + ".xml" + " " + v-sys-key).*/
      end.
      else message "Файл TTH.exe не найден!" view-as alert-box.
    end.
  end.
  message
        "Экспорт выбранных документов в файлы ТОРГ-12.txt и/или ТОРГ-13.txt закончен"
view-as alert-box.