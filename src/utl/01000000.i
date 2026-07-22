/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Условный перенос истории по таблице {1}

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/24/03
Author: Bakhtadze Natalya
Creation date: 07/24/03

{2} {3} {4} {5} {6} {7} {8} {9}
элементы первичного ключа

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer old-{1}         for src.{1}.
define buffer new-{1}         for dst.{1}.

assign
var-rid-2 = ?
var-new-name = "":U
var-new-name-2 = "":U
.
find first old-{1} no-lock where
          recid(old-{1}) = old-history.tbl-rid no-error .
if not avail old-{1} then next _old-history.
find first new-{1} no-lock where
          new-{1}.{2} = old-{1}.{2}

&if "{3}" <> "" &then
             AND new-{1}.{3}   = old-{1}.{3}
&endif
&if "{4}" <> "" &then
             AND new-{1}.{4}   = old-{1}.{4}
&endif
&if "{5}" <> "" &then
             AND new-{1}.{5}   = old-{1}.{5}
&endif
&if "{6}" <> "" &then
             AND new-{1}.{6}   = old-{1}.{6}
&endif
&if "{7}" <> "" &then
             AND new-{1}.{7}   = old-{1}.{7}
&endif
&if "{8}" <> "" &then
             AND new-{1}.{8}   = old-{1}.{8}
&endif

        no-error .
if not avail new-{1} then next _old-history.
assign
var-rid = recid(new-{1})
.

/* $Workfile$ e n d */