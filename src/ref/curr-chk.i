/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверки человеков

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/04/07
Author: Bakhtadze Natalya
Creation date: 08/04/07


*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop seq {&sequence}
  define variable v-ref-rec{&seq}   as recid no-undo .


&if "{2}" = "button" &then
  find buf_curr-chk where buf_curr-chk.curr-code = input frame {&frame-name} {3}.{1}
                  no-lock no-error.
  assign v-ref-rec{&seq} = ( if available buf_curr-chk then recid( buf_curr-chk ) else ? ).
  release buf_curr-chk.
&else /*else &if "{2}" = "button" &then*/
  find buf_curr-chk where buf_curr-chk.curr-code = input frame {&frame-name} {3}.{1}
                 no-lock no-error.
&endif /*&if "{2}" = "button" &then*/
&if "{2}" = "on" &then
if not available buf_curr-chk then do:
  display {3}.{1} with frame {&frame-name}.
  find buf_curr-chk no-lock where buf_curr-chk.curr-code = input frame {&frame-name} {3}.{1}
                          no-error.
end.
&endif /*&if "{2}" = "on" &then*/

&if "{2}" <> "on" and "{2}" <> "leave" &then
  if not available buf_curr-chk  then do:
    &if "{2}" <> "button" &then
    if input frame {&frame-name} {3}.{1} <> ""
       and input frame {&frame-name} {3}.{1} <> ? then
      message "Из справочника валют Вы должны выбрать валюту.".
    &endif /*&if "{2}" <> "button" &then*/
    run ref/currency.w (
                    input parparentproc
                  , input "b-sel"
                  , input-output v-ref-rec{&seq}) no-error .

    find buf_curr-chk where recid (buf_curr-chk) = v-ref-rec{&seq}  no-lock no-error.
    if not available buf_curr-chk then
      find first buf_curr-chk where
          buf_curr-chk.curr-code = input frame {&frame-name} {3}.{1}
      no-lock no-error.
  end.
  &if "{2}" = "button" or "{2}" = "ret-mouse" &then
  if available buf_curr-chk then do:
    display buf_curr-chk.curr-code @ {3}.{1}
            buf_curr-chk.curr-abbr @ {1}-name with frame {&frame-name}.
    assign frame {&frame-name} {3}.{1}.
  end.
  else display ? @ {3}.{1}
               ? @ {1}-name with frame {&frame-name}.

  apply "entry" to b-exit &endif in frame {&frame-name}.
  return no-apply.
&else /*&if "{2}" = "button" or "{2}" = "ret-mouse" &then*/
if available buf_curr-chk then do:
    display
    buf_curr-chk.curr-code @ {3}.{1}
    buf_curr-chk.curr-abbr @ {1}-name with frame {&frame-name}.
    &if  "{2}" = "leave" &then
        assign frame {&frame-name} {3}.{1}.
    &endif
end.
else display ? @ {3}.{1} ? @ {1}-name with frame {&frame-name}.
&endif /*&if "{2}" = "button" or "{2}" = "ret-mouse" &then*/

/* $Workfile$ */