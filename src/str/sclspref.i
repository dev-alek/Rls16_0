/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/14/08
Author: Bakhtadze Natalya
Creation date: 11/14/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "" &then
&scop varscales-pref varscales-pref
define variable {&varscales-pref} as character no-undo .
&else
&scop varscales-pref {1}

&endif
&if "{2}" = "" &then
&scop varpgscales-pref varpgscales-pref
define variable {&varpgscales-pref} as character no-undo .
&else
&scop varpgscales-pref {2}
&endif


define variable varscales-pref-type{&vssseq} as character no-undo.
{&varscales-pref}  = ?.
{ gbl/conf-rd.i
  "'sclspref':u"
  "'':u"
  "'':u"
  0
  "'':u"
  "'':u"
  "'':u"
  no
  ~{&varscales-pref~}
  varscales-pref-type~{&vssseq~}
  no-error
}
if {&varscales-pref} = ? then do:
  assign
  {&varscales-pref} = {&scales-pref}.
end.
define variable varpgscales-pref-type{&vssseq} as character no-undo.
{&varpgscales-pref}  = ?.
{ gbl/conf-rd.i
  "'scpgpref':u"
  "'':u"
  "'':u"
  0
  "'':u"
  "'':u"
  "'':u"
  no
  ~{&varpgscales-pref~}
  varpgscales-pref-type~{&vssseq~}
  no-error
}
if {&varpgscales-pref} = ? then do:
  assign
  {&varpgscales-pref} = {&pgscales-pref}.
end.


/* $Workfile$ e n d */