/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггера для работы со справочником  dis-ruls

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/14/07
Author: Bakhtadze Natalya
Creation date: 03/14/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


define variable v-ref-rec{&vssseq}   as recid no-undo .
define variable v-rid-list{&vssseq}   as character no-undo .
define variable v-sts{&vssseq}   as integer no-undo .

&if "{2}" = "button" &then
  find dr-chk_dis-rule where
       dr-chk_dis-rule.rule-num = input frame {&frame-name} {3}.{1}
   and dr-chk_dis-rule.upper-rule-num > 0
     no-lock no-error.
  assign
  v-ref-rec{&vssseq} = ( if available dr-chk_dis-rule then recid( dr-chk_dis-rule) else ? ).
  release dr-chk_dis-rule.
&else
  find first dr-chk_dis-rule where
            dr-chk_dis-rule.rule-num = input frame {&frame-name} {3}.{1}
        and dr-chk_dis-rule.upper-rule-num > 0
    no-lock no-error.
&endif /*&if "{2}" = "button" &then*/
&if "{2}" = "on" &then
if not available dr-chk_dis-rule then do:
  &if "{2}" <> "button" &then
  if input frame {&frame-name} {3}.{1} <> 0
      and input frame {&frame-name} {3}.{1} <> ? then
    message "Из справочника правил кидко Вы должны выбрать правило скидки.".
  &endif /*&if "{2}" <> "button" &then*/
  display {3}.{1} with frame {&frame-name}.
  find first dr-chk_dis-rule no-lock where
            dr-chk_dis-rule.rule-num = input frame {&frame-name} {3}.{1}
        and dr-chk_dis-rule.upper-rule-num > 0
   no-error.
end.
&endif /*&if "{2}" = "on" &then*/
&if "{2}" <> "on" and ("{2}" <> "leave" and "{2}" <> "leave-message") &then
  if not available dr-chk_dis-rule then do:
    v-rid-list{&vssseq} = string(v-ref-rec{&vssseq}).
    run ref/dis-ruls.w (   input  parparentproc
                          ,input {&dr-chk-host-code}
                          ,input {&dr-chk-obj-type} /*p-curr-obj-type*/
                          ,input {&dr-chk-obj-code} /*p-curr-obj-code*/
                          ,input "b-sel,b-add"
                          ,input (if {&dr-chk-obj-type} = {&shop}
                                  or {&dr-chk-obj-type} = {&stock}
                                  then "upper-rule-num-object"
                                  else "upper-rule-num")
                          ,input {4} /*p-templ-rl-root*/
                          ,input ? /*p-time-templ-rl-root*/
                          ,input 0 /*p-b-code*/
                          ,input-output v-sts{&vssseq} /*p-sts*/
                          ,input-OUTPUT v-rid-list{&vssseq}) NO-ERROR.
    assign v-ref-rec{&vssseq} = integer( v-rid-list{&vssseq} ).
    find first dr-chk_dis-rule where
            recid (dr-chk_dis-rule) = v-ref-rec{&vssseq}  no-lock no-error.
    if not available dr-chk_dis-rule then do:
      find first dr-chk_dis-rule where
                dr-chk_dis-rule.rule-num = input frame {&frame-name} {3}.{1}
            and dr-chk_dis-rule.upper-rule-num > 0
      no-lock no-error.
    end.
&if "{4}" <> "" &then
    if available dr-chk_dis-rule
    and {4} <> 0
    and dr-chk_dis-rule.templ-rl-root <> {4} then do:
      message
      substitute("Правило скидки должно быть типа &1", {4})
      view-as alert-box error .
      find first dr-chk_dis-rule where
               dr-chk_dis-rule.rule-num = input frame {&frame-name} {3}.{1}
           and dr-chk_dis-rule.upper-rule-num > 0
      no-lock no-error.
    end.
&endif /*&if "{4}" <> "" &then*/
  end.
  &if "{2}" = "button" or "{2}" = "ret-mouse" &then
  if available dr-chk_dis-rule then do:
    display
    dr-chk_dis-rule.rule-num @ {3}.{1}
    dr-chk_dis-rule.des @ {1}-name
    with frame {&frame-name}.
    assign frame {&frame-name} {3}.{1}.
  end.
  else display ? @ {3}.{1}
               ? @ {1}-name with frame {&frame-name}.

  apply "entry" to  b-exit  in frame {&frame-name}.
  return no-apply.
  &endif /*  &if "{2}" = "button" or "{2}" = "ret-mouse" &then*/
&else /*&else if "{2}" <> "on" and ("{2}" <> "leave" and "{2}" <> "leave-message") &then*/
if available dr-chk_dis-rule then do:
    display
    dr-chk_dis-rule.rule-num @ {3}.{1}
    dr-chk_dis-rule.des @ {1}-name
    with frame {&frame-name}.
    &if  "{2}" = "leave"  or "{2}" = "leave-message" &then
        assign frame {&frame-name} {3}.{1}.
    &endif /*&if  "{2}" = "leave"  or "{2}" = "leave-message" &then*/
end.
else do:
  display
  ? @ {3}.{1}
  ? @ {1}-name
  with frame {&frame-name}.
  &if "{2}" = "Leave-message" and "{5}" <> "" &then
     message {5} view-as alert-box error.
  &endif /*&if "{2}" = "Leave-message" and "{5}" <> "" &then*/
end.
&endif /*&else if "{2}" <> "on" and ("{2}" <> "leave" and "{2}" <> "leave-message") &then*/

/* $Workfile$ */