/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения buffer-ов для приема сверок

Автор: Уханов Дмитрий Юрьевич
Дата создания: 02/15/07
Author: Dmitry Ukhanov
Creation date: 02/15/07

Автор1: Суслов Алексей Юрьевич
Дата создания1: 04/04/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_rvs-line      for ub.rvs-line.
define buffer buf_rvs-line-pump for ub.rvs-line-pump.
define buffer buf_doc-attr      for ub.doc-attr.
define buffer buf_doc-line-attr for ub.doc-line-attr.
define buffer buf_rvs-line-attr for ub.rvs-line-attr.
define buffer buf_rvs-pump      for ub.rvs-pump.

define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.

for each locb-rvs-line
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  delete locb-rvs-line.
end.
for each locb-rvs-line-pump
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  delete locb-rvs-line-pump.
end.
for each locbr-rvs-pump
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  delete locbr-rvs-pump.
end.
for each locbr-doc-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  delete locbr-doc-attr.
end.
for each locbr-doc-line-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  delete locbr-doc-line-attr.
end.
for each locbr-rvs-line-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  delete locbr-rvs-line-attr.
end.