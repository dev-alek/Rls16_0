/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/14/07
Author: Bakhtadze Natalya
Creation date: 03/14/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


define variable v-ref-rec{&vssseq}   as recid no-undo .

&if "{2}" = "button" &then
  find cli-buf where
       cli-buf.obj-code = input frame {&frame-name} {3}.{1}
    and cli-buf.obj-type = {&shop} no-lock no-error.
  if available cli-buf then do:
    find first shop-buf where
            shop-buf.obj-code = cli-buf.obj-code  no-error .
  end.
  assign
  v-ref-rec{&vssseq} = ( if available shop-buf then recid( shop-buf ) else ? ).
  release cli-buf.
  release shop-buf.
&else
  find first cli-buf where
       cli-buf.obj-code = input frame {&frame-name} {3}.{1}
   and cli-buf.obj-type = {&shop}  no-lock no-error.
&endif
&if "{2}" = "on" &then
if not available cli-buf then do:
  &if "{2}" <> "button" &then
  if input frame {&frame-name} {3}.{1} <> ""
      and input frame {&frame-name} {3}.{1} <> ? then
    message "Из справочника магазинов Вы должны выбрать магазин.".
  &endif
  display {3}.{1} with frame {&frame-name}.
  find first cli-buf no-lock where
            cli-buf.obj-code = input frame {&frame-name} {3}.{1}
       and cli-buf.obj-type = {&shop} no-error.
end.
&endif
&if "{2}" <> "on" and ("{2}" <> "leave" and "{2}" <> "leave-message") &then
  if not available cli-buf  then do:
    ref-list = string(v-ref-rec{&vssseq}).
    run adm/shops.w (
               input parparentproc
             , input "b-sel"
             , input-output ref-list
             , no).
    assign v-ref-rec{&vssseq} = integer( ref-list ).
    find first shop-buf where
            recid (shop-buf) = v-ref-rec{&vssseq}  no-lock no-error.
    if available shop-buf then do:
      find first cli-buf no-lock where
                cli-buf.obj-type = {&shop}
            and cli-buf.obj-code = shop-buf.obj-code .
    end.
    else do:
      release cli-buf.
    end.
    if not available shop-buf then do:
      find first cli-buf where
                cli-buf.obj-code = input frame {&frame-name} {3}.{1}
            and cli-buf.obj-type = {&shop}
      no-lock no-error.
    end.
&if "{4}" <> "" &then
    if available cli-buf
    and {4} <> 0
    and cli-buf.host-code <> {4} then do:
      message
      substitute("Магазин должен принадлежать фирме с кодом &1", {4})
      view-as alert-box error .
      find first cli-buf where
                cli-buf.obj-code = input frame {&frame-name} {3}.{1}
            and cli-buf.obj-type = {&shop}
      no-lock no-error.
    end.
&endif
/*&if "{4}" <> "" &then*/
  end.
  &if "{2}" = "button" or "{2}" = "ret-mouse" &then
  if available cli-buf then do:
    display
    cli-buf.obj-code @ {3}.{1}
    cli-buf.obj-name @ {1}-name
    with frame {&frame-name}.
    assign frame {&frame-name} {3}.{1}.
  end.
  else display ? @ {3}.{1}
               ? @ {1}-name with frame {&frame-name}.

  apply "entry" to  b-exit  in frame {&frame-name}.
  return no-apply.
  &endif
  /*&if "{2}" = "button" or "{2}" = "ret-mouse" &then*/
&else
/*&else &if "{2}" <> "on" and ("{2}" <> "leave" and "{2}" <> "leave-message") &then*/
if available cli-buf then do:
    display
    cli-buf.obj-code @ {3}.{1}
    cli-buf.obj-name @ {1}-name
    with frame {&frame-name}.
    &if  "{2}" = "leave"  or "{2}" = "leave-message" &then
        assign frame {&frame-name} {3}.{1}.
    &endif
end.
else do:
  display
  ? @ {3}.{1}
  ? @ {1}-name
  with frame {&frame-name}.
  &if "{2}" = "Leave-message" and "{5}" <> "" &then
     message {5} view-as alert-box error.
  &endif
end.
&endif
/*&if "{2}" <> "on" and ("{2}" <> "leave" and "{2}" <> "leave-message") &then*/
/* $Workfile$ */