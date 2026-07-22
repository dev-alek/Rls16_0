/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием клиентов по СПН

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

  if not can-find(buf_cli-grp where buf_cli-grp.node-code = wt-clients.grp-code)
      and g#db-num = 0 then do:

    run write-to-log in this-procedure (input " В БД нет группы для клиента " + wt-clients.obj-name + " ("
                      + wt-clients.obj-type + " " + string( wt-clients.obj-code ) + ") "
                    ).
    return error.
  end.
  if can-find(buf_cli-grp where buf_cli-grp.upper-code = wt-clients.grp-code)
      and g#db-num = 0 then do:
    run write-to-log in this-procedure (input " В ГБД есть подгруппа в группе клиента " + wt-clients.obj-name + " ("
                      + wt-clients.obj-type + " " + string( wt-clients.obj-code ) + ")."
                    ).
    return error.
  end.
if not available tb-clients then do:
  create tb-clients.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-clients TO wt-clients case-sensitive save result in compare-log no-error.
  buffer-compare tb-clients using obj-name TO wt-clients case-sensitive save result in v-l no-error.
end.
if not compare-log then do:
  buffer-copy wt-clients TO tb-clients .
  if
  not (tb-clients.obj-type = {&shop} or tb-clients.obj-type = {&stock})
  and not v-l then do:
    for each buf_dis-card where
             buf_dis-card.cli-type = tb-clients.obj-type
         AND buf_dis-card.cli-code = tb-clients.obj-code:
      run fill-dc-list in p-imp-handle ( buffer buf_Dis-card) .
    end. /*for each*/
  end.
end.

/* $Workfile$ e n d */