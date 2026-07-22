/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

тригера интерфейса в заказах OO

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 06/21/04 4:45

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

ON CHOOSE OF r-{1} IN FRAME Dialog-Frame /* r-button */
DO:
   run proc-r-{1} in this-procedure .
END.

ON LEAVE OF scr-{1} IN FRAME Dialog-Frame /* Код */
DO:
run leave-proc-{1} in this-procedure .
END.

ON  RETURN OF scr-{1} IN FRAME Dialog-Frame /* Код */
DO:
  run next-focus in this-procedure  (input  scr-{1}:handle ) .
  return no-apply .
END.

ON MOUSE-SELECT-DBLCLICK OF scr-{1} IN FRAME {&frame-name}
DO:
  apply "choose" to r-{1} in frame {&frame-name}.
  return no-apply .
end.

Procedure proc-r-{1} :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
 define variable rid-list    as  char no-undo . /* список recid'ов выбранных клиентов */
 define variable v-recid as recid no-undo .
 define variable old-types as character no-undo .
 define buffer {1}#clients for ub.clients.



    run ref/cli-all.w
    ( input parParentProc, input "b-sel", {&prs}, ?, ?, ?, ?, ?, output  rid-list).


    Assign
      v-recid = integer(rid-list)
      .

    find first {1}#clients no-lock WHERE recid({1}#clients) = v-recid  No-ERROR.
    if avail {1}#clients then
        Assign
            scr-{1} = {1}#clients.obj-code
            scr-{1}-name = {1}#clients.obj-name
            .
    else
       Assign
          scr-{1}-name = ""
          scr-{1} = ?
          .


    Display scr-{1} scr-{1}-name with frame {&frame-name} .

end.
end procedure.

procedure leave-proc-{1} :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
  def buffer buf_clients for ub.clients.

  Assign frame {&frame-name} scr-{1} .

  if scr-{1} <> ? and scr-{1} <> 0 then do:
      find first buf_clients no-lock where
                buf_clients.obj-type = {&prs}  and
                buf_clients.obj-code  = scr-{1} no-error.

          if error-status :error or not available buf_clients then do:
              Message "Неправильно задан "  scr-{1}:label in frame {&frame-name}.
                Assign
                scr-{1}-name = ""
                scr-{1} = ?
                .
              Display  scr-{1} scr-{1}-name with frame {&frame-name}.
              apply "CHOOSE" to r-{1} in frame {&frame-name} .
          end.

          if available buf_clients Then DO:
                scr-{1}      = buf_clients.obj-code .
                scr-{1}-name = buf_clients.obj-name .

          End.
 End.
 else do:
      Assign
        scr-{1}-name = ""
        scr-{1} = ?
        .
  end.
 Display  scr-{1} scr-{1}-name with frame {&frame-name}.
 end. /* do */
end procedure. /* leave-proc-{1} */

/* $Workfile$ e n d */