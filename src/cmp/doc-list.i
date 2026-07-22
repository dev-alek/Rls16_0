/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение временной таблицы списка документов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/03/06
Author: Bakhtadze Natalya
Creation date: 01/03/06

*/
/*

Параметры:

  {1} - имя таблицы.

  {2} -

        def      - если необходимо определение таблицы
        assign-trn   - поиск и присвоение полей таблицы - документы
        assign-price-doc   - поиск и присвоение полей таблицы - переоценки

  {3} - необязательный параметр если второй параметр- def
        параметры определения.
        если второй параметр assign... тогда
        имя таблицы источника

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{2}" = "def" &then

define {3} temp-table {1} no-undo
field doc-date   like ub.trn-doc.doc-date
field doc-code   like ub.trn-doc.doc-code
field obj-type   like ub.trn-doc.obj-type
field obj-code   like ub.trn-doc.obj-code
field fact-num   like ub.trn-doc.fact-num
field fact-date  like ub.trn-doc.fact-date
field shift-date like ub.trn-doc.shift-date
field shift-num  like ub.trn-doc.shift-num
field shift-name like ub.trn-doc.shift-name
field fact-order as decimal
field is-trn-doc as logical
field is-del as logical
field doc-type   like ub.trn-doc.doc-type
field ext-doc-type   like ub.trn-doc.ext-doc-type
field sel-order  as integer
field znak       as integer
field to-del     as logical
field is-archive-exist as logical
index xpk is primary unique doc-code doc-type
index xfact fact-num
index xfact-date fact-date
index sel-order sel-order
index znak-order znak sel-order
index isdel is-del
.

define buffer inkas_trn-doc for ub.trn-doc .
define buffer c-inkas_trn-doc for ub.c-trn-doc .

/* история заполнения списка */
&if "{5}" <> "no-hist" &then
  &if "{3}" <> ' ' &then
  { cmp/listhist.i {1} "{3}" {5} }
  &else
  { cmp/listhist.i {1} {5} }
  &endif
&endif


&endif

&if "{2}" = "assign-trn" &then

find {1}
  where {1}.doc-code = {3}.doc-code
    and {1}.doc-type = {3}.doc-type
  no-error .
if available {1} then do:
  assign
    {1}.to-del = no /* ставим отметку, что запись нужна */
  .
end.
else do:
&if "{5}" = "one-host" &then
  if {3}.host-code <> p-curr-host-code then return.
&endif
  create {1} .
  assign
  {1}.doc-code   = {3}.doc-code
  {1}.obj-type   = {3}.obj-type
  {1}.obj-code   = {3}.obj-code
  {1}.fact-num   = {3}.fact-num
  {1}.doc-date   = {3}.doc-date
  {1}.fact-date  = {3}.fact-date
  {1}.shift-date = {3}.shift-date
  {1}.shift-num  = {3}.shift-num
  {1}.fact-order = {3}.fact-order
  {1}.is-trn-doc = yes
  {1}.is-del     = no
  {1}.doc-type   = {3}.doc-type
  {1}.ext-doc-type   = {3}.ext-doc-type
&if "{4}" <> "" &then
  {1}.sel-order  = {4}
&endif
  {1}.znak       = if can-do ({&expense_write-off}, {1}.doc-type) then -1 else 1
  {1}.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid ({1})
  .
end.

&endif


&if "{2}" = "assign-c-trn" &then

find {1}
  where {1}.doc-code = {3}.doc-code
    and {1}.doc-type = "-" + {3}.doc-type
  no-error .
if available {1} then do:
  assign
    {1}.to-del = no /* ставим отметку, что запись нужна */
  .
end.
else do:
&if "{5}" = "one-host" &then
  if {3}.host-code <> p-curr-host-code then return.
&endif
  create {1} .
  assign
  {1}.doc-code   = {3}.doc-code
  {1}.obj-type   = {3}.obj-type
  {1}.obj-code   = {3}.obj-code
  {1}.fact-num   = {3}.fact-num
  {1}.doc-date   = {3}.doc-date
  {1}.fact-date  = {3}.fact-date
  {1}.shift-date = {3}.shift-date
  {1}.shift-num  = {3}.shift-num
  {1}.fact-order = {3}.fact-order
  {1}.is-trn-doc = yes
  {1}.doc-type   = "-" + {3}.doc-type
  {1}.ext-doc-type   = {3}.ext-doc-type
  {1}.is-del     = yes
&if "{4}" <> "" &then
  {1}.sel-order  = {4}
&endif
  {1}.znak       = if can-do ({&expense_write-off}, {1}.doc-type) then -1 else 1
  {1}.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid ({1})
  .
end.

&endif


&if "{2}" = "assign-price-doc" &then

find {1}
  where {1}.doc-code = {3}.doc-num
    and {1}.doc-type = {&overvalue}
  no-error .
if available {1} then do:
  assign
    {1}.to-del = no /* ставим отметку, что запись нужна */
  .
end.
else do:
&if "{5}" = "one-host" &then
  if {3}.host-code <> p-curr-host-code then return.
&endif
  create {1} .
  assign
  {1}.doc-code   = {3}.doc-num
  {1}.obj-type   = {3}.obj-type
  {1}.obj-code   = {3}.obj-code
  {1}.fact-num   = {3}.fact-num
  {1}.fact-date  = {3}.fact-date
  {1}.shift-date = {3}.shift-date
  {1}.shift-num  = {3}.shift-num
  {1}.fact-order = {3}.fact-order
  {1}.is-trn-doc = no
  {1}.is-del     = no
  {1}.doc-type   = {&overvalue}
  {1}.ext-doc-type   = {&TDEDT_Overturn}
&if "{4}" <> "" &then
  {1}.sel-order  = {4}
&endif
  {1}.znak       = 1
  {1}.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid ({1})
  .
end.

&endif

&if "{2}" = "assign-inkas" &then

find {1}
  where {1}.doc-code = {3}.inkas-code
  and {1}.doc-type = {&cash-desk}
  no-error .
find first inkas_trn-doc where
           inkas_trn-doc.doc-code = {3}.inkas-code no-error .
if available {1} then do:
  assign
    {1}.to-del = no /* ставим отметку, что запись нужна */
  .
end.
else do:
&if "{5}" = "one-host" &then
  if {3}.host-code <> p-curr-host-code then return.
&endif
  create {1} .
  assign
  {1}.doc-code   = {3}.inkas-code
  {1}.obj-type   = {3}.obj-type
  {1}.obj-code   = {3}.obj-code
  {1}.fact-num   = inkas_trn-doc.fact-num
  {1}.fact-date  = {3}.fact-date
  {1}.shift-date = {3}.shift-date
  {1}.shift-num  = {3}.shift-num
  {1}.fact-order = inkas_trn-doc.fact-order
  {1}.is-trn-doc = no
  {1}.is-del     = no
  {1}.doc-type   = {&cash-desk}
  {1}.ext-doc-type   = {&cash-desk}
&if "{4}" <> "" &then
  {1}.sel-order  = {4}
&endif
  {1}.znak       = 1
  {1}.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid ({1})
  .
end.


&endif

&if "{2}" = "assign-c-inkas" &then

find {1}
  where {1}.doc-code = {3}.inkas-code
  and {1}.doc-type = "-" + {&cash-desk}
  no-error .
find first c-inkas_trn-doc where
           c-inkas_trn-doc.doc-code = {3}.inkas-code
     and  c-inkas_trn-doc.is-del = yes  no-error .
if available {1} then do:
  assign
    {1}.to-del = no /* ставим отметку, что запись нужна */
  .
end.
else do:
&if "{5}" = "one-host" &then
  if {3}.host-code <> p-curr-host-code then return.
&endif
  create {1} .
  assign
  {1}.doc-code   = {3}.inkas-code
  {1}.obj-type   = {3}.obj-type
  {1}.obj-code   = {3}.obj-code
  {1}.fact-num   = (if available c-inkas_trn-doc then c-inkas_trn-doc.fact-num else 0)
  {1}.fact-date  = {3}.fact-date
  {1}.shift-date = {3}.shift-date
  {1}.shift-num  = {3}.shift-num
  {1}.fact-order = (if available c-inkas_trn-doc then c-inkas_trn-doc.fact-order else ?)
  {1}.is-trn-doc = no
  {1}.is-del     = yes
  {1}.doc-type   =   "-" + {&cash-desk}
  {1}.ext-doc-type = {&cash-desk}
&if "{4}" <> "" &then
  {1}.sel-order  = {4}
&endif
  {1}.znak       = 1
  {1}.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid ({1})
  .
end.


&endif


&if "{2}" = "assign-fbr-doc" &then

find {1}
  where {1}.doc-code = {3}.doc-code
    and {1}.doc-type = {&manufacturing}
  no-error .
if available {1} then do:
  assign
    {1}.to-del = no /* ставим отметку, что запись нужна */
  .
end.
else do:
&if "{5}" = "one-host" &then
  if {3}.host-code <> p-curr-host-code then return.
&endif
  create {1} .
  assign
  {1}.doc-code   = {3}.doc-code
  {1}.obj-type   = {3}.obj-type
  {1}.obj-code   = {3}.obj-code
  {1}.fact-num   = 0
  {1}.fact-date  = {3}.fact-date
  {1}.shift-date = {3}.shift-date
  {1}.shift-num  = {3}.shift-num
  {1}.fact-order = 0
  {1}.is-trn-doc = no
  {1}.doc-type   = {&manufacturing}
  {1}.ext-doc-type   = {&manufacturing}
&if "{4}" <> "" &then
  {1}.sel-order  = {4}
&endif
  {1}.znak       = 1
  {1}.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid ({1})
  .
end.

&endif


&if "{2}" = "assign-ord-doc" &then

find {1}
  where {1}.doc-code = {3}.doc-code
  and {1}.doc-type = {3}.doc-type no-error.
if available {1} then do:
  assign
    {1}.to-del = no /* ставим отметку, что запись нужна */
  .
end.
else do:
&if "{5}" = "one-host" &then
  if {3}.host-code <> p-curr-host-code then return.
&endif
  create {1} .
  assign
  {1}.doc-code   = {3}.doc-code
  {1}.obj-type   = {3}.obj-type
  {1}.obj-code   = {3}.obj-code
  {1}.fact-num   = {3}.fact-num
  {1}.fact-date  = {3}.fact-date
  {1}.shift-date = {3}.shift-date
  {1}.shift-num  = {3}.shift-num
  {1}.fact-order = {3}.fact-order
  {1}.is-trn-doc = no
  {1}.is-del     = no
  {1}.doc-type   = {3}.doc-type
  {1}.ext-doc-type   = {3}.doc-type
&if "{4}" <> "" &then
  {1}.sel-order  = {4}
&endif
  {1}.znak       = 1
  {1}.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid ({1})
  .
end.


&endif


/* $Workfile$ */