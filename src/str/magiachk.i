/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица для соответствия чеов МАГИЯ и IBS TH

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


define temp-table temp-ivs-ibs{1} no-undo
&if "{1}" = "-line" &then
field line-num as integer
&ENDIF
field chtype as character  /*тип чека в спуле МАГИИ*/
field cstype as character  /*тип строки в спуле МАГИИ*/
field cancelcode as character /*код отмены строки*/
field modificator as LOGICAL /*модификатор*/
field modificator-np as LOGICAL /*модификатор с нулевой ценой */
field positive-num-chk as logical /*номерч чека положительный*/
field rcpt-type-1 as character  /*тип чека IBS*/
field wro-code as character {2} /*код списания строки IBS*/
field create-return-write-off as logical /*флаг создания чека-оригинала*/
field return-line as logical /*флаг создания строки с обратным знаком*/
field qnty-sign as integer {2} /*множитель для количества по строке*/
field step_ as integer {2} /*множитель для количества по строке*/
field positive-netto-sum as logical  /*положительная сумма нетто в чеке*/
field main-record as logical  /*запись которую используем для  получения типа ШАПКИ ЧЕКА*/
field rcpt-type-2 as character  /*тип чека IBS*/
index pi is primary
chtype
cstype
cancelcode
modificator
rcpt-type-1
rcpt-type-2
index chk-doc
chtype
positive-num-chk
positive-netto-sum
main-record
&if "{1}" = "line" &then
line-num
index iline
line-num
&endif
.

&if "{1}" = "proc" &then
procedure create-temp-ivs-ibs-line :
define input parameter ret-item as character no-undo .
define input parameter wro-item as character no-undo .
define input parameter ret-chk as character no-undo .
define input parameter wro-chk as character no-undo .
define input parameter ret-ord as character no-undo .
define input parameter wro-ord as character no-undo .

define variable ii as integer no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .

define buffer buf_temp-ivs-ibs for temp-ivs-ibs.
define buffer buf2_temp-ivs-ibs for temp-ivs-ibs.



  do
  on error undo, return error return-value
  :

run gbl/filename.p (
                input 'cmp/ivs-ibs.d'
               ,output v-full-path
               ,output v-path
               ,output v-file-name
               ,output v-file-name-no-ext
               ,output v-file-name-ext
               ) no-error .

    input from value(v-full-path).
    repeat:
      create buf_temp-ivs-ibs.
      import buf_temp-ivs-ibs.
    END.
    input close.
    _n:
    for each buf_temp-ivs-ibs:
      if buf_temp-ivs-ibs.chtype = '':U then do:
        delete buf_temp-ivs-ibs.
        next _n.
      end.
      assign
      buf_temp-ivs-ibs.rcpt-type-1 = replace(buf_temp-ivs-ibs.rcpt-type-1, 'rcpt-sale', {&rcpt-sale})
      buf_temp-ivs-ibs.rcpt-type-2 = replace(buf_temp-ivs-ibs.rcpt-type-2, 'rcpt-sale', {&rcpt-sale})
      buf_temp-ivs-ibs.rcpt-type-1 = replace(buf_temp-ivs-ibs.rcpt-type-1, 'rcpt-return-write-off', {&rcpt-return-write-off})
      buf_temp-ivs-ibs.rcpt-type-2 = replace(buf_temp-ivs-ibs.rcpt-type-2, 'rcpt-return-write-off', {&rcpt-return-write-off})
      buf_temp-ivs-ibs.rcpt-type-1 = replace(buf_temp-ivs-ibs.rcpt-type-1, 'rcpt-return', {&rcpt-return})
      buf_temp-ivs-ibs.rcpt-type-2 = replace(buf_temp-ivs-ibs.rcpt-type-2, 'rcpt-return', {&rcpt-return})
      buf_temp-ivs-ibs.rcpt-type-1 = replace(buf_temp-ivs-ibs.rcpt-type-1, 'rcpt-write-off', {&rcpt-write-off})
      buf_temp-ivs-ibs.rcpt-type-2 = replace(buf_temp-ivs-ibs.rcpt-type-2, 'rcpt-write-off', {&rcpt-write-off})
      buf_temp-ivs-ibs.rcpt-type-1 = replace(buf_temp-ivs-ibs.rcpt-type-1, 'rcpt-annu', {&rcpt-annu})
      buf_temp-ivs-ibs.rcpt-type-2 = replace(buf_temp-ivs-ibs.rcpt-type-2, 'rcpt-annu', {&rcpt-annu})
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-without-payment', {&wro-without-payment})
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-without-payment', {&wro-without-payment})
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-r-modificator-wp', {&wro-r-modificator-wp})
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-r-modificator-wp', {&wro-r-modificator-wp})
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-r-modificator', {&wro-r-modificator})
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-r-modificator', {&wro-r-modificator})
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-cancell-item', {&wro-cancell-item})
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-cancell-item', {&wro-cancell-item})
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-cancell-all', {&wro-cancell-all})
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-cancell-all', {&wro-cancell-all})
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-v-modificator-ci', {&wro-v-modificator-ci})
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-v-modificator-ci', {&wro-v-modificator-ci})
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-v-modificator-ca', {&wro-v-modificator-ca})
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-v-modificator-ca', {&wro-v-modificator-ca})
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-v-modificator', {&wro-v-modificator})
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-v-modificator', {&wro-v-modificator})
      .
      if buf_temp-ivs-ibs.cancelcode = 'ret-item':U then do:
        do ii = 1 to num-entries(ret-item, ';'):
          create
          buf2_temp-ivs-ibs.
          buffer-copy buf_temp-ivs-ibs to
          buf2_temp-ivs-ibs
          assign
          buf2_temp-ivs-ibs.cancelcode = entry(1, entry(ii, ret-item, ';':U)).
        end.
         delete buf_temp-ivs-ibs.
         next _n.
      end.
      if buf_temp-ivs-ibs.cancelcode = 'wro-item':U then do:
        do ii = 1 to num-entries(wro-item, ';'):
          create
          buf2_temp-ivs-ibs.
          buffer-copy buf_temp-ivs-ibs to
          buf2_temp-ivs-ibs
          assign
          buf2_temp-ivs-ibs.cancelcode = entry(1, entry(ii, wro-item, ';':U)).
        end.
        delete buf_temp-ivs-ibs.
        next _n.
      end.
      if buf_temp-ivs-ibs.cancelcode = 'ret-chk':U then do:
        do ii = 1 to num-entries(ret-chk, ';'):
          create
          buf2_temp-ivs-ibs.
          buffer-copy buf_temp-ivs-ibs to
          buf2_temp-ivs-ibs
          assign
          buf2_temp-ivs-ibs.cancelcode = entry(1, entry(ii, ret-chk, ';':U)).
        end.
        delete buf_temp-ivs-ibs.
        next _n.
      end.
      if buf_temp-ivs-ibs.cancelcode = 'wro-chk':U then do:
        do ii = 1 to num-entries(wro-chk, ';'):
          create
          buf2_temp-ivs-ibs.
          buffer-copy buf_temp-ivs-ibs to
          buf2_temp-ivs-ibs
          assign
          buf2_temp-ivs-ibs.cancelcode = entry(1, entry(ii, wro-chk, ';':U)).
        end.
        delete buf_temp-ivs-ibs.
        next _n.
      end.
      if buf_temp-ivs-ibs.cancelcode = 'ret-ord':U then do:
        do ii = 1 to num-entries(ret-ord, ';'):
          create
          buf2_temp-ivs-ibs.
          buffer-copy buf_temp-ivs-ibs to
          buf2_temp-ivs-ibs
          assign
          buf2_temp-ivs-ibs.cancelcode = entry(1, entry(ii, ret-ord, ';':U)).
        end.
        delete buf_temp-ivs-ibs.
        next _n.
      end.
      if buf_temp-ivs-ibs.cancelcode = 'wro-ord':U then do:
        do ii = 1 to num-entries(wro-ord, ';'):
          create
          buf2_temp-ivs-ibs.
          buffer-copy buf_temp-ivs-ibs to
          buf2_temp-ivs-ibs
          assign
          buf2_temp-ivs-ibs.cancelcode = entry(1, entry(ii, wro-ord, ';':U)).
        end.
         delete buf_temp-ivs-ibs.
         next _n.
      end.
      end.
    end.

end procedure. /* create-temp-ivs-ibs-line */

&endif

/* $Workfile$ e n d */