block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: infrmact.p $
$Archive: gbl/infrmact.p $

Программа обработки событий в информационном диалоге

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 10/30/00

Используется для запуска Procedure editor, так как он не может быть запущен

*/

define input parameter h_focus-widget      as handle    no-undo .
define input parameter h_current-procedure as handle    no-undo .
define input parameter p-action            as character no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: infrmact.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/infrmact.p $":U .
def var vss-description as character no-undo init "Программа обработки событий в информационном диалоге".
{ cmp/vssrevis.i }

define variable v-proc-name as character no-undo .


do
on error undo, return error return-value
:
  case entry(1, p-action) :
    when "":u then do:
      /* do-nothing */
    end.
    when "run":U then do:
      if num-entries(p-action) = 2
      then do:
        assign
          v-proc-name = entry(2, p-action)
        .

        if lookup(h_current-procedure :file-name
                  ,'gbl/mainmenu.w'
                  ) > 0 then do:
          run value(v-proc-name) .
        end.
        else do:
          message
            "Программа может быть запущена только из главного окна модуля." skip
            "Вы пытаетесь запустить его из программы" h_current-procedure :file-name skip
            "Закройте все окна и поробуйте еще раз" skip
            view-as alert-box information .
        end.
      end.
      else do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестное событие" skip
          "p-action" p-action skip
          view-as alert-box error .
      end.
    end.
    when "runpersistent":u then do:
      if num-entries(p-action) = 2
      then do:
        assign
          v-proc-name = entry(2, p-action)
        .

        if lookup(h_current-procedure :file-name
                  ,'gbl/mainmenu.w'
                  ) > 0 then do:
          run value(v-proc-name) persistent.
        end.
        else do:
          message
            "Программа может быть запущена только из главного окна модуля." skip
            "Вы пытаетесь запустить его из программы" h_current-procedure :file-name skip
            "Закройте все окна и поробуйте еще раз" skip
            view-as alert-box information .
        end.
      end.
      else do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестное событие" skip
          "p-action" p-action skip
          view-as alert-box error .
      end.
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестное событие" skip
        "p-action" p-action skip
        view-as alert-box error .
    end.
  end.
end.