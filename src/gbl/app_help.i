/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Интерактивная помощь

Автор: Чернова Светлана Александровна
Дата создания: 02/27/07
Author: Svetlana Chernova
Creation date: 02/27/07

create: Перваков Михаил Сергеевич
Дата создания: 04/05/06

Для того, чтобы реализовать помощь, необходимо создать стандартную кнопку b-help ),
а затем включить в Main-Block программы вызов файла
   { gbl/app_help.i }

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&if "{&proc_detail}" = "" &then
  &scop proc_detail ''
&endif

&IF "{&proc_frame}" = "" &THEN
  &SCOP proc_frame {&FRAME-NAME}
&ENDIF


on help of frame {&proc_frame}
do:
  run gbl/app_help.p
    (input this-procedure :file-name /* p-procedure */
    ,input {&proc_detail}            /* p-detail    */
    ,input ?                         /* l-help-edit */
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.


&if "{&disable-button}" = "" &then

run minbtn-set in this-procedure .
/*frame {&proc_frame}:font = 10 .*/
on choose of b-help in frame {&proc_frame}
do:
  apply "help":u to frame {&proc_frame} .
end.

{ gbl/minbtn.i }
&endif

&if defined(browse-name) > 0 and defined(disable_diasize) = 0 &then
  { gbl/diasize.i
    &browse-name="{&browse-name}"
    &frame-name="{&frame-name}"
  }
  &if defined(disable_diasize_init) = 0 &then
    run diasize_init in this-procedure .
  &endif
&endif

/* $Workfile$   E n d */