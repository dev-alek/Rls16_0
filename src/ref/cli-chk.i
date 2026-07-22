/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверки орг

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/13/08
Author: Bakhtadze Natalya
Creation date: 09/13/08


*/


&scop seq {&sequence}
  define variable v-ref-rec{&seq}   as recid no-undo .
  define variable ref-list{&seq} as character no-undo .


&if "{3}" = "button" &then
  find buf_cli_{1} where buf_cli_{1}.obj-code = input frame {&frame-name} {4}.{1}
                 and buf_cli_{1}.obj-type = input frame {&frame-name} {4}.{2} no-lock no-error.
  assign v-ref-rec{&seq} = ( if available buf_cli_{1} then recid( buf_cli_{1} ) else ? ).
  &if "{5}" <> "" &then  {5} = ( if available buf_cli_{1} then recid( buf_cli_{1} ) else ? ).  &endif
  release buf_cli_{1}.
&else /*&if "{3}" = "button" &then*/
  find buf_cli_{1} where buf_cli_{1}.obj-code = input frame {&frame-name} {4}.{1}
                 and buf_cli_{1}.obj-type = input frame {&frame-name} {4}.{2} no-lock no-error.
&endif /*/*&if "{3}" = "button" &then*/*/
&if "{3}" = "on" &then
if not available buf_cli_{1} then do:
  display {4}.{1} with frame {&frame-name}.
  find buf_cli_{1} no-lock where buf_cli_{1}.obj-code = input frame {&frame-name} {4}.{1}
                         and buf_cli_{1}.obj-type = input frame {&frame-name} {4}.{2} no-error.
end.
&endif /*&if "{3}" = "on" &then*/

&if "{3}" <> "on" and "{3}" <> "leave" &then
  if not available buf_cli_{1} or lookup(buf_cli_{1}.obj-type, {6} ) = 0 then do:
    &if "{3}" <> "button" &then
    if input frame {&frame-name} {4}.{1} <> ""
       and input frame {&frame-name} {4}.{1} <> ? then
      message substitute("Из справочника клиентов Вы должны выбрать &1.", {6}).
    &endif /*    &if "{3}" <> "button" &then*/
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input ?
                  ,  input ?
                  ,  input ?
                  ,  input &if "{5}" = "" &then v-ref-rec{&seq} &else  {5} &endif
                  ,  input ",,,,,,NO"
                  ,  input ""
                  , output ref-list{&seq} ) .
    assign v-ref-rec{&seq} = integer( ref-list{&seq} ).
    &if "{5}" <> "" &then  {5} = integer( ref-list{&seq} ) . &endif

    find buf_cli_{1} where recid (buf_cli_{1}) =
       &if "{5}" = "" &then v-ref-rec{&seq} &else  {5} &endif
       no-lock no-error.
    if not available buf_cli_{1} or lookup(buf_cli_{1}.obj-type, {6} ) = 0 then
      find buf_cli_{1} where buf_cli_{1}.obj-code = input frame {&frame-name} {4}.{1}
                       and buf_cli_{1}.obj-type = input frame {&frame-name} {4}.{2} no-lock no-error.
  end.
  &if "{3}" = "button" or "{3}" = "ret-mouse" &then
  if available buf_cli_{1} and lookup(buf_cli_{1}.obj-type, {6} ) > 0 then do:
    display buf_cli_{1}.obj-code @ {4}.{1}
            buf_cli_{1}.obj-type @ {4}.{2}
            buf_cli_{1}.obj-name @ {1}-name with frame {&frame-name}.
    assign frame {&frame-name} {4}.{1}.
  end.
  else do:
     display
     ? @ {4}.{1}
     ? @ {1}-name with frame {&frame-name}.
  end.
  apply "entry" to {7} in frame {&frame-name}.
  return no-apply.
&endif
&else /*&if "{3}" = "button" or "{3}" = "ret-mouse" &then*/
if available buf_cli_{1} then do:
    display
    buf_cli_{1}.obj-code @ {4}.{1}
    buf_cli_{1}.obj-type @ {4}.{2}
    buf_cli_{1}.obj-name @ {1}-name
    with frame {&frame-name}.
    &if  "{3}" = "leave" &then
        assign frame {&frame-name} {4}.{1}  {4}.{2}.
    &endif /*&if  "{3}" = "leave" &then*/
end.
else do:
  display
  ? @ {4}.{1}
  ? @ {1}-name with frame {&frame-name}.
end.
&endif /*&if "{3}" = "button" or "{3}" = "ret-mouse" &then*/


/* $Workfile$ */