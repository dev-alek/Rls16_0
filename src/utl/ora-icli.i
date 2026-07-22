/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура определения по номеру клиента его типа

Автор: Чернова Светлана Александровна
Дата создания: 02/10/09
Author: Svetlana Chernova
Creation date: 02/10/09

*/

define variable  ora-icli_ver-stts-client as logical   no-undo  init true .

procedure who-cli-ora :
define input  parameter p-cli-code-ora as integer   no-undo .
define output parameter p-cli-type as character no-undo .
define output parameter p-cli-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
  if length (string(p-cli-code-ora))  <> 9 then do:
     return error substitute ("Не верный формат кода КОНТРАГЕНТА: &1" , p-cli-code-ora ) .
  end.
  if string(p-cli-code-ora) begins "1" or
     string(p-cli-code-ora) begins "2" or
     string(p-cli-code-ora) begins "4" then do:
      p-cli-type = {&cmp} .
      p-cli-code = p-cli-code-ora /* - integer(substring(string(p-cli-code-ora),1,1)) * 100000000 */ .
  end.
  else do:
    if string(p-cli-code-ora) begins "3" then do:
      p-cli-type = {&prs} .
      p-cli-code = p-cli-code-ora /*- integer(substring(string(p-cli-code-ora),1,1)) * 100000000 */ .
    end.
    else do:
       return error substitute ("Не верный формат кода КОНТРАГЕНТА: &1 ( первый код )" , p-cli-code-ora ) .
    end.
  end.

  define buffer buf_clients for ub.clients  .

  find first buf_clients no-lock where
             buf_clients.obj-type = p-cli-type and
             buf_clients.obj-code = p-cli-code
             no-error .
      if error-status :error then do:
          return error substitute
          ( "Нет такого контрагента: &1 ( &2 &3 )" ,
              p-cli-code-ora ,
              p-cli-type ,
              p-cli-code ) .
      end.

      if ora-icli_ver-stts-client then do:
          if buf_clients.stts > 0 then do:
              return error substitute
              ( "Контрагент: &1 ( &2 &3 ) СТАТУС неактивный !!!" ,
                  p-cli-code-ora ,
                  p-cli-type ,
                  p-cli-code ) .
          end.
      end.
  end.

end procedure. /* who-cli-ora */


procedure ora-ver-goods :
define input  parameter p-gds-code as integer   no-undo .
define buffer buf_goods for ub.goods  .
define variable my-message as character no-undo .
  do
  on error undo, return error return-value
  :
        find first buf_goods no-lock where
                   buf_goods.gds-code = p-gds-code no-error .
            if error-status :error then do:
                my-message = substitute("Нет товара с кодом &1" ,  p-gds-code) .
                undo, return error my-message.
            end.

          if buf_goods.stts > 0 then do:
            assign
              my-message =  substitute(" Товара &1 УДАЛЕН" , buf_goods.gds-code  ) .
              undo, return error my-message.
          end.
  end.

end procedure. /* ora-ver-goods */