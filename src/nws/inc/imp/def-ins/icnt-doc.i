/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения переменных для приема icnt-doc

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/23/07
Author: Dmitry Ukhanov
Creation date: 10/23/07

Автор1: Суслов Алексей Юрьевич
Дата создания1: 04/04/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_icnt-line      for ub.icnt-line.
define buffer buf_doc-attr       for ub.doc-attr.

define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.

for each locb-icnt-line
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  delete locb-icnt-line.
end.
for each locbi-doc-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  delete locbi-doc-attr.
end.

/* $Workfile$ e n d */