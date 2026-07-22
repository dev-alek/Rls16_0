/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура проверки транспортных условий договора

Автор: Чернова Светлана Александровна
Дата создания: 04/23/07
Author: Svetlana Chernova
Creation date: 04/23/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
{ cmp/str-glbl.i  }

procedure validate-transport-contract :
define input  parameter p-host-code             as integer   no-undo .   /* основной контракт */
define input  parameter p-cli-type              as character no-undo .
define input  parameter p-cli-code              as integer   no-undo .
define input  parameter p-contract-code         as integer   no-undo .
define input  parameter p-transport-cli-type    as character no-undo . /* транспортный контракт */
define input  parameter p-transport-cli-code    as integer   no-undo .
define input  parameter p-transport-host-code   as integer   no-undo .
define input  parameter p-transport-contract    as integer   no-undo .
define input  parameter p-mess                  as logical   no-undo .
define output parameter p-ok                    as logical   no-undo .
define output parameter p-err                   as character no-undo .
  do
  on error undo, return error return-value
  :

define buffer buf_main_contract for ub.contract  .
define buffer buf_main_clients  for ub.clients  .
define buffer buf_transport_contract for ub.contract  .
define buffer buf_transport_clients  for ub.clients  .

p-err = "" .
p-ok = true .
    if p-contract-code <> 0 then do:
        if not ( p-cli-type = {&cmp} or p-cli-type = {&prs} ) then do:
          p-err = substitute("Конрагент договора может быть &1 или &2" , {&cmp} , {&prs}) .
          p-ok = false  .
          if p-mess then message p-err  view-as alert-box error.
          return  p-err .
        end.
        find first buf_main_clients no-lock where
                  buf_main_clients.obj-type = p-cli-type and
                  buf_main_clients.obj-code = p-cli-code no-error .
      if not available buf_main_clients then do:
          p-err = substitute("Не верно задан Конрагент  тип &1   код &2" ,  p-cli-type , p-cli-code) .
          p-ok = false  .
          if p-mess then message p-err  view-as alert-box error.
          return  p-err .
      end.
      find first buf_main_contract no-lock where
                  buf_main_contract.host-code = p-host-code and
                  buf_main_contract.contract-code = p-contract-code no-error .
      if not available buf_main_contract then do:
          p-err = substitute("Не найден договор фирма &1  вн.код &2" ,  p-host-code , p-contract-code) .
          p-ok = false  .
          if p-mess then message p-err  view-as alert-box error.
          return  p-err .
      end.
      if not ( buf_main_contract.cli-type = p-cli-type and
                buf_main_contract.cli-code = p-cli-code) then do:
          p-ok = false  .
          p-err = substitute("Договор принадлежит контрагенту &1 &2 , а не &3 &4 " ,
                              buf_main_contract.cli-type ,
                              buf_main_contract.cli-code ,
                              p-cli-type,
                              p-cli-code ) .
          if p-mess then message p-err  view-as alert-box error.
          return  p-err .
      end.
    end.
    if p-transport-cli-code <> 0 then do:
        if not ( p-transport-cli-type = {&cmp} or p-transport-cli-type = {&prs} ) then do:
          p-ok = false  .
          p-err = substitute("Конрагент договора может быть &1 или &2" , {&cmp} , {&prs}) .
          if p-mess then message p-err  view-as alert-box error.
          return  p-err .
        end.
        find first buf_transport_clients no-lock where
                  buf_transport_clients.obj-type = p-transport-cli-type and
                  buf_transport_clients.obj-code = p-transport-cli-code no-error .
      if not available buf_transport_clients then do:
          p-ok = false  .
          p-err = substitute("Не верно задан тр.Конрагент  тип &1   код &2" ,  p-transport-cli-type , p-transport-cli-code) .
          if p-mess then message p-err  view-as alert-box error.
          return  p-err .
      end.
      find first buf_transport_contract no-lock where
                  buf_transport_contract.host-code     = p-transport-host-code and
                  buf_transport_contract.contract-code = p-transport-contract no-error .
      if not available buf_transport_contract then do:
          p-ok = false  .
          p-err = substitute("Не найден транспортный договор фирма &1  вн.код &2" ,  p-transport-host-code , p-transport-contract) .
          if p-mess then message p-err  view-as alert-box error.
          return  p-err .
      end.
      if not ( buf_transport_contract.cli-type = p-transport-cli-type and
                buf_transport_contract.cli-code = p-transport-cli-code) then do:
          p-ok = false  .
          p-err = substitute("Договор принадлежит контрагенту &1 &2 , а не &3 &4 " ,
                              buf_transport_contract.cli-type ,
                              buf_transport_contract.cli-code ,
                              p-transport-cli-type,
                              p-transport-cli-code ) .
          if p-mess then message p-err  view-as alert-box error.
          return  p-err .
      end.
    end.
  end.

end procedure. /* validate-transport-contract */