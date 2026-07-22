/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверки видов оплаты

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/13/08
Author: Bakhtadze Natalya
Creation date: 09/13/08

для стандартизации интерфейса

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop seq {&sequence}
  define variable v-rid-list{&seq}   as character no-undo .


&if "{2}" = "button" &then
  find buf_pt_{1} where buf_pt_{1}.obj-code = input frame {&frame-name} {3}.{1}
                  no-lock no-error.
  assign v-rid-list{&seq} = ( if available buf_pt_{1} then string(recid( buf_pt_{1} )) else ? ).
  release buf_pt_{1}.
&else
  find buf_pt_{1} where buf_pt_{1}.obj-code = input frame {&frame-name} {3}.{1}
                 no-lock no-error.
&endif
&if "{2}" = "on" &then
if not available buf_pt_{1} then do:
  display {3}.{1} with frame {&frame-name}.
  find buf_pt_{1} no-lock where buf_pt_{1}.obj-code = input frame {&frame-name} {3}.{1}
                          no-error.
end.
&endif

&if "{2}" <> "on" and "{2}" <> "leave" &then
  if not available buf_pt_{1}  then do:
    &if "{2}" <> "button" &then
    if input frame {&frame-name} {3}.{1} <> ""
       and input frame {&frame-name} {3}.{1} <> ? then
      message "Из справочника видов оплаты Вы должны выбрать вид оплаты.".
    &endif
   run ref/paytype.w (
                       input parparentproc
                      ,input "b-sel"
                      ,output v-rid-list{&seq}
                      ) no-error.

    find buf_pt_{1} where recid (buf_pt_{1}) = integer(v-rid-list{&seq})  no-lock no-error.
    if not available buf_pt_{1} then
      find first buf_pt_{1} where
          buf_pt_{1}.obj-code = input frame {&frame-name} {3}.{1}
      no-lock no-error.
  end.
  &if "{2}" = "button" or "{2}" = "ret-mouse" &then
  if available buf_pt_{1} then do:
    display buf_pt_{1}.obj-code @ {3}.{1}
            buf_pt_{1}.obj-name @ {1}-name with frame {&frame-name}.
    assign frame {&frame-name} {3}.{1}.
  end.
  else display ? @ {3}.{1}
               ? @ {1}-name with frame {&frame-name}.

  apply "entry" to b-exit &endif in frame {&frame-name}.
  return no-apply.
&else
if available buf_pt_{1} then do:
    display
    buf_pt_{1}.obj-code @ {3}.{1}
    buf_pt_{1}.obj-name @ {1}-name with frame {&frame-name}.
    &if  "{2}" = "leave" &then
        assign frame {&frame-name} {3}.{1}.
    &endif
end.
else display ? @ {3}.{1} ? @ {1}-name with frame {&frame-name}.
&endif

/* $Workfile$ */