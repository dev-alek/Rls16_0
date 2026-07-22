/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функция, возвращающая символьное указание области действия чего-либо - глобально - по фирме по объекту

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/04
Author: Bakhtadze Natalya
Creation date: 09/07/04

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION gtregion RETURNS CHARACTER
  ( input parhost-code as integer
  , input parobj-type as character
  , input parobj-code as integer
&if "{1}" = "template" &then
  , input p-templ-rl-root as integer
  , input p-template as logical
&endif
  , input p-tab as logical
  ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  def var par-region as character no-undo.
  &if "{1}" = "template" &then
  define variable v-g as character no-undo .
  define variable v-h as character no-undo .
  define variable v-o as character no-undo .
  define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
    if p-template then do:
      find first buf_dis-cfg-rule no-lock where
                buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root no-error.
      assign
      v-g = (if available buf_dis-cfg-rule
            and buf_dis-cfg-rule.has-global = 1
            then "Глоб"
            else '')
      par-region = v-g + {&comma-char}
      v-h =  (if available buf_dis-cfg-rule
              and buf_dis-cfg-rule.has-host = 1
              then "Фирма"
              else '')
      par-region = trim(par-region + v-h, {&comma-char}) + {&comma-char}
      v-o = (if available buf_dis-cfg-rule
             and buf_dis-cfg-rule.has-obj = 1
             then "Объ."
             else '')
      par-region = trim(par-region + v-o, {&comma-char})
      .
      return par-region.
    end.
  &endif
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = "" and
       parobj-code = 0 then do:
       par-region = if p-tab then fill({&space-char}, 2) else "":U +
                    "Фирма" + {&space-char} + string(parhost-code).
       return par-region.
    end.
    par-region = if p-tab then fill({&space-char}, 4) else "":U +
                 parobj-type + {&space-char} + string(parobj-code).
    return par-region.
END FUNCTION.

/* $Workfile$ e n d */