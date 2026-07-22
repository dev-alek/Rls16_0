block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: bef-inn.p $
$Archive: utl/bef-inn.p $

Проверка И Н Н перед включением inn-uniq = 2

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/23/06
Author: Bakhtadze Natalya
Creation date: 03/23/06

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bef-inn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/bef-inn.p $":U .
define variable vss-description as character no-undo init "Проверка И Н Н перед включением inn-uniq = 2".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }


define variable v-correct as logical no-undo .
define variable ii as integer no-undo .
define variable v-firm-code as integer no-undo .
define variable v-psn-code as integer no-undo .
define buffer buf_firm for ub.firm.
define buffer buf_person for ub.person.
define buffer buf_clients for ub.clients.

define temp-table temp-inn no-undo
field inn as character
field cli-list as character
field num-rec as integer
field inn-ok-prs as logical
field inn-ok-cmp as logical
index pi is unique primary
inn
.

define stream PrnLibStream.
output stream PRnLibStream to no-inn.txt .
output stream PRnLibStream close .
output stream PRnLibStream to no-uniq.txt.
output stream PRnLibStream close .
output stream PRnLibStream to no-corr-prs.txt append.
output stream PRnLibStream close .
output stream PRnLibStream to no-corr-cmp.txt append.
output stream PRnLibStream close .


_person:
for each buf_person no-lock:
  ii = ii + 1.
  if ii modulo 20 = 0 then do:
    run waitfram-show in this-procedure ( substitute("Чтение из БД - записей &1 ...", ii )).
  end.
  if buf_person.inn = '':u then do:
    find first buf_clients no-lock where
              buf_clients.obj-type = {&prs}
          and buf_clients.obj-code = buf_person.psn-code .
    if not (buf_clients.sup-gds
            or
            buf_clients.sup-cons
            or
            buf_clients.sup-serv) then next _person.
    output stream PRnLibStream to no-inn.txt append.
    put stream PRnLibStream unformatted
    {&prs} {&space-char} buf_person.psn-code {&space-char} buf_clients.obj-name skip.
    output stream PRnLibStream close.
    next  _person.
  end.
  find first temp-inn where
            temp-inn.inn = buf_person.inn no-error.
  if not available temp-inn then do:
    create temp-inn.
    assign
    temp-inn.inn = buf_person.inn
    temp-inn.cli-list = temp-inn.cli-list + (if temp-inn.cli-list = '':u then '':U else  {&space-char}) + {&prs} + string(buf_person.psn-code)
    temp-inn.num-rec = temp-inn.num-rec + 1
    .
  end.
  else do:
    assign
    temp-inn.cli-list = temp-inn.cli-list + (if temp-inn.cli-list = '':u then '':U else {&space-char}) + {&prs} + string(buf_person.psn-code)
    temp-inn.num-rec = temp-inn.num-rec + 1
    .
  end.
  release temp-inn.
end.
_firm:
for each buf_firm no-lock:
  ii = ii + 1.
  if ii modulo 20 = 0 then do:
    run waitfram-show in this-procedure ( substitute("Чтение из БД - записей &1 ...", ii )).
  end.
  if buf_firm.inn = '':u then do:
    find first buf_clients no-lock where
              buf_clients.obj-type = {&cmp}
          and buf_clients.obj-code = buf_firm.firm-code .
    if not (buf_clients.sup-gds
            or
            buf_clients.sup-cons
            or
            buf_clients.sup-serv) then next _firm.
    output stream PRnLibStream to no-inn.txt append.
    put stream PRnLibStream unformatted
    {&cmp} {&space-char} buf_firm.firm-code {&space-char} buf_clients.obj-name skip.
    output stream PRnLibStream close.
    next  _firm.
  end.
  find first temp-inn where
            temp-inn.inn = buf_firm.inn no-error.
  if not available temp-inn then do:
    create temp-inn.
    assign
    temp-inn.inn = buf_firm.inn
    temp-inn.cli-list = temp-inn.cli-list + (if temp-inn.cli-list = '':u then '':U else {&space-char}) + {&cmp} + string(buf_firm.firm-code)
    temp-inn.num-rec = temp-inn.num-rec + 1
    .
  end.
  else do:
    assign
    temp-inn.cli-list = temp-inn.cli-list + (if temp-inn.cli-list = '':u then '':U else {&space-char}) + {&cmp} + string(buf_firm.firm-code)
    temp-inn.num-rec = temp-inn.num-rec + 1
    .
  end.
  release temp-inn.
end.
ii = 0.
for each temp-inn:
  ii = ii + 1.
  if ii modulo 20 = 0 then do:
    run waitfram-show in this-procedure ( substitute("Проверка - записей &1...", ii )).
  end.
  if temp-inn.num-rec > 1 then do:
    output stream PRnLibStream to no-uniq.txt append.
    put stream PRnLibStream unformatted
    temp-inn.inn skip
    temp-inn.cli-list skip(2).
    output stream PRnLibStream close.
  end.
  if temp-inn.num-rec = 1 then do:
    if index(temp-inn.cli-list, {&cmp}) > 0 then do:
      assign
      v-firm-code = integer(replace(temp-inn.cli-list, {&cmp}, '':U)).
      find first buf_firm no-lock where buf_firm.firm-code = v-firm-code.
      temp-inn.inn-ok-prs = yes.
      run gbl/keyinn.p (
                    input  temp-inn.inn
                    ,input  {&cmp}
                    ,input  buf_firm.firm-code
                    ,input  buf_firm.is-pboul
                    ,output v-correct ) no-error.
      if error-status:error
      or not v-correct then do:
        temp-inn.inn-ok-cmp = v-correct.
      end.
    end.
    if index(temp-inn.cli-list, {&prs}) > 0 then do:
      assign
      v-psn-code = integer(replace(temp-inn.cli-list, {&prs}, '':U)).
      find first buf_person no-lock where buf_person.psn-code = v-psn-code.
      temp-inn.inn-ok-cmp = yes.
      run gbl/keyinn.p (
                    input  temp-inn.inn
                    ,input  {&prs}
                    ,input  buf_person.psn-code
                    ,input  buf_person.is-pboul
                    ,output v-correct ) no-error.
      if error-status:error
      or not v-correct then do:
        temp-inn.inn-ok-prs = v-correct.
      end.
    end.
    if not temp-inn.inn-ok-prs then do:
      output stream PRnLibStream to no-corr-prs.txt append.
      put stream PRnLibStream unformatted
      temp-inn.inn skip
      temp-inn.cli-list skip(2).
      output stream PRnLibStream close.
    end.
    if not temp-inn.inn-ok-cmp then do:
      output stream PRnLibStream to no-corr-cmp.txt append.
      put stream PRnLibStream unformatted
      temp-inn.inn skip
      temp-inn.cli-list skip(2).
      output stream PRnLibStream  close.
    end.
  end.
end.
message
"Результаты ищите в файлах" skip(0)
"no-inn.txt - клиенты-поставщики без {&abbr_inn_allshift}" skip(0)
"no-uniq.txt - клиенты с нарушением уникальности {&abbr_inn_allshift}" skip(0)
"no-corr-prs.txt - физлица с неверным {&abbr_inn_allshift}" skip(0)
"no-corr-cmp.txt - организации с неверным {&abbr_inn_allshift}" skip(0)
view-as alert-box .

