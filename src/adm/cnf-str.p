block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cnf-str.p $
$Archive: adm/cnf-str.p $

Просмотр и корректировка схемы конфигурации

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/00
Author: Dmitry Ukhanov
Creation date: 03/22/00

*/

/* ***************************  definitions  ************************** */
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
def var vss-author      as character no-undo init "$Author: expertek $":u.
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u.
def var vss-workfile    as character no-undo init "$Workfile: cnf-str.p $":u.
def var vss-archive     as character no-undo init "$Archive: adm/cnf-str.p $":u.
def var vss-description as character no-undo init "Просмотр и корректировка схемы конфигурации".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }

{ adm/cnf-inc.i  }
{ gbl/cur-time.i }
{ adm/cfg-pr.i   }

def stream txt-file.                     /* файл для импорта и экспорта конфигураций */

def var log-on    as logical   no-undo.  /* протоколировать работу в файл */
def var mes-on    as logical   no-undo.  /* сообщения об ошибках выводятся пользователю */
def stream log-file.                     /* файл для протоколирования */
/* ----------------------------------------------------------------------------------------------------------------------------
    Подготовка к работе с новой конфигурацией
--------------------------------------------------------------------------------------------------------------------------------- */
procedure init.

define input parameter par-logname as character no-undo. /* для протоколирования работы в файл
                                                           если задано пустое значение или файл не открывается,
                                                           то протоколирование ведется во временную таблицу*/
define input parameter par-meson   as logical   no-undo. /* выводить сообщения об ошибках на экран */
define input parameter par-appon   as logical   no-undo. /* протокол ошибок пишется в конец существующего */

assign mes-on    = par-meson
       log-on    = false.
if par-logname <> "" then do:
   if par-appon then
      output stream log-file to value (par-logname) append.
   else
      output stream log-file to value (par-logname).
   /* печатаем дату и время работы, заодно проверяя возможность вывода */
   do on error undo, retry:
     if retry then do:
        return "2".                                     /* не смогли написать в файл */
     end.
     put stream log-file unformatted "====" + cur-time-string() + "====" skip.
     assign log-on = true.
   end.
end.
return.
end procedure.

/* ----------------------------------------------------------------------------------------------------------------------------
    Переключение режима вывода ошибок на экран
--------------------------------------------------------------------------------------------------------------------------------- */
procedure toggle-mes.

define input parameter par-meson   as logical   no-undo. /* выводить сообщения об ошибках на экран */

assign mes-on    = par-meson.
return.

end procedure.

/* ----------------------------------------------------------------------------------------------------------------------------
    Завершение работы со схемой конфигурации
--------------------------------------------------------------------------------------------------------------------------------- */
procedure kill.
    output stream log-file close.
    delete procedure this-procedure.
    return.
end procedure.

procedure kill1.
    delete procedure this-procedure.
    return.
end procedure.
/* ----------------------------------------------------------------------------------------------------------------------------
    Протоколирование работы и установка уровня ошибки
--------------------------------------------------------------------------------------------------------------------------------- */
procedure log-error.

define input parameter par-message as character.
define input parameter par-level   as integer.

case par-level :
  when 1 then do:
    assign
      par-message = substitute( "Замечание: &1", par-message ).
    .
  end.
  when 2 then do:
    assign
      par-message = substitute( "$Критическая ОШИБКА: &1", par-message ).
    .
  end.
end case. .

if log-on then do:
   put stream log-file unformatted par-message skip.
end.
else do:
   create log-table.
   log-table.stroka = par-message.
end.

if par-level > 0 and mes-on then message par-message.
err-level = (max(par-level, err-level)).
end procedure. /* log-error */


/* Преобразование типа параметра настройки в тип параметра конфигурации
   значение возвращется в return-value*/

procedure cnv-param-type.
  define input parameter cfg-param-type as character no-undo.

  if lookup ("list":U, cfg-param-type) > 0 then /*все списки только character */
    return "C":U.
  else if cfg-param-type = "date":U then
    return "T":U.
  else
    return upper(substr(cfg-param-type, 1, 1)).
end procedure.

/* Вывод в протокол списка системных ошибок */

procedure log-sys-error.

  define input parameter par-message as character no-undo.
  define variable k as integer no-undo.

  if par-message <> "" then do:
    run log-error in this-procedure
      ( input par-message
      ,input 2
      ).
  end.

  do k = 1 to Error-Status:Num-messages:
    run log-error in this-procedure
      ( input Error-Status:Get-message(k)
        ,input 2
      ).
  end.
end procedure.