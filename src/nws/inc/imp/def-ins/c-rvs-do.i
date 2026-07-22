/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения buffer-ов для приема истории изменения сверов

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/19/07
Author: Dmitry Ukhanov
Creation date: 10/19/07

Автор1: Суслов Алексей Юрьевич
Дата создания1: 04/04/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_c-rvs-line      for ub.c-rvs-line.
define buffer buf_c-rvs-line-pump for ub.c-rvs-line-pump.
define buffer buf_c-doc-attr      for ub.c-doc-attr.
/*define buffer buf_c-rvs-line-attr for ub.c-rvs-line-attr.*/

define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.

for each locb-c-rvs-line
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  delete locb-c-rvs-line.
end.
for each locb-c-rvs-line-pump
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  delete locb-c-rvs-line-pump.
end.
for each locbr-c-doc-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  delete locbr-c-doc-attr.
end.
/*for each locbr-c-rvs-line-attr*/
/*on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )*/
/*on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )*/
/*on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )*/
/*:*/
/*  delete locbr-c-rvs-line-attr.*/
/*end.*/