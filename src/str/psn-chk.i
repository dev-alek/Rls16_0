/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверки человеков

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич
{4} переменная бывшая ref-rec


*/


&scop seq {&sequence}
  define variable v-ref-rec{&seq}   as recid no-undo .


&if "{2}" = "button" &then
  find cli-buf where cli-buf.obj-code = input frame {&frame-name} {3}.{1}
                 and cli-buf.obj-type = {&prs} no-lock no-error.
  assign v-ref-rec{&seq} = ( if available cli-buf then recid( cli-buf ) else ? ).
  &if "{4}" <> "" &then  {4} = ( if available cli-buf then recid( cli-buf ) else ? ).  &endif
  release cli-buf.
&else
  find cli-buf where cli-buf.obj-code = input frame {&frame-name} {3}.{1}
                 and cli-buf.obj-type = {&prs} no-lock no-error.
&endif
&if "{2}" = "on" &then
if not available cli-buf then do:
  display {3}.{1} with frame {&frame-name}.
  find cli-buf no-lock where cli-buf.obj-code = input frame {&frame-name} {3}.{1}
                         and cli-buf.obj-type = {&prs} no-error.
end.
&endif

&if "{2}" <> "on" and "{2}" <> "leave" &then
  if not available cli-buf or ( NOT can-do( {&prs}, cli-buf.obj-type ) ) then do:
    &if "{2}" <> "button" &then
    if input frame {&frame-name} {3}.{1} <> ""
       and input frame {&frame-name} {3}.{1} <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    &endif
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input {&prs}
                  ,  input ?
                  ,  input ?
                  ,  input &if "{4}" = "" &then v-ref-rec{&seq} &else  {4} &endif
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec{&seq} = integer( ref-list ).
    &if "{4}" <> "" &then  {4} = integer( ref-list ) . &endif

    find cli-buf where recid (cli-buf) =
       &if "{4}" = "" &then v-ref-rec{&seq} &else  {4} &endif
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( {&prs}, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame {&frame-name} {3}.{1}
                           and cli-buf.obj-type = {&prs} no-lock no-error.
  end.
  &if "{2}" = "button" or "{2}" = "ret-mouse" &then
  if available cli-buf and can-do( {&prs}, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ {3}.{1}
            cli-buf.obj-name @ {1}-name with frame {&frame-name}.
    assign frame {&frame-name} {3}.{1}.
  end.
  else display ? @ {3}.{1}
               ? @ {1}-name with frame {&frame-name}.

  apply "entry" to &if "{1}" = "wrkr" &then {3}.agnt &elseif "{1}" = "agnt" &then {3}.boss
                            &else b-exit &endif in frame {&frame-name}.
  /*return no-apply.*/
  &endif
&endif


if available cli-buf then do:
      display cli-buf.obj-code @ {3}.{1} cli-buf.obj-name @ {1}-name with frame {&frame-name}.
      &if  "{2}" = "leave" &then
          assign frame {&frame-name} {3}.{1}.
      &endif
  end.
  else display ? @ {3}.{1} ? @ {1}-name with frame {&frame-name}.

  &if "{2}" = "button" or "{2}" = "ret-mouse" &then
      return no-apply.
  &endif
/* $Workfile$ */