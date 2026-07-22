/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

создание записи во временной таблице  при закачке / создании чеков  МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if crwth > 0 then
find first t-wth WHERE
            t-wth.pay-code = {2}.pay-code and
            t-wth.curr-code = {2}.curr-code and
            t-wth.drc = recid({1})
            NO-ERROR.
if not avail t-wth or crwth = 0 then  do:
  FIND FIRST t-wth where t-wth.crf = crwth + 1 use-index crfi No-ERROR.
  if not avail t-wth then
  create t-wth.
  assign
  t-wth.crf = crwth + 1
  crwth = crwth + 1
  t-wth.pay-code = {2}.pay-code
  t-wth.curr-code = {2}.curr-code
  t-wth.drc = recid({1})
  t-wth.tot-sum = 0
  t-wth.num-lines = 0
  t-wth.byval = ''
  .
end.
assign
t-wth.tot-sum = t-wth.tot-sum + {2}.tot-sum
t-wth.num-lines = t-wth.num-lines + 1
t-wth.sum-r-b = t-wth.sum-r-b + {2}.tot-sum / {2}.cash-rate
t-wth.byval = (if t-wth.byval = ''
               then (if {2}.src-val = 0
                     then 'nbyval'
                     else 'byval'
                     )
               else (if (t-wth.byval = 'byval'
                     and {2}.src-val = 0)
                     or (t-wth.byval = 'nbyval'
                     and {2}.src-val <> 0)
                     then 'error'
                     else t-wth.byval)
               )
.

/* $Workfile$ e n d */