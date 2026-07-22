/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функция определяет что пошлется на кассу как дополнительное название товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/28/04
Author: Bakhtadze Natalya
Creation date: 09/28/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION name-2cdf returns character
                   (  input p-name-2cd as character
                    , input p-mode as logical /*yes для конкретного товара no - возвращает описание поля*/
                    , input p-cod-pcod as logical
                    , input p-b-code  as integer
                    , input p-gds-code as integer
                    , input p-artic   as character
                    , input p-engl-name  as character
                    , input p-in-code as character
                    , input p-part-code as character
                    , input p-obj-type as character
                    , input p-obj-code as integer
                    , input p-alpha1 as character
                    , output p-gtd as character
                    ) :
define variable v-name-2cd as character no-undo .
define variable v-dop-alt-name as character no-undo.
define variable v-type as character no-undo.
define buffer buf_parts for ub.parts.
define buffer buf_code for ub.code.
if not p-mode and p-name-2cd = "PLU":U then do:
  return "PLU кассы":U.
end.
if not p-mode then do:
  if p-name-2cd <> "GTD":U
  and  p-name-2cd <> "alpha1|gtd":U
  then do:
  assign
  p-name-2cd = p-name-2cd + "-":U + "GTD":U.
end.
end.
if p-part-code = "":U or p-cod-pcod = no then do:
  run gdsoattr-value in this-procedure (
    {&attr-dt-seasons},
    p-gds-code,
    p-obj-type,
    p-obj-code,
    output v-dop-alt-name,
    output v-type
  ) no-error.
  if v-dop-alt-name <> "" then do:
    find first buf_code where
               buf_code.parent = "DTSeasons"
           and buf_code.code   = v-dop-alt-name
         no-lock no-error.
    if available buf_code then
      assign
        p-engl-name = ""
        v-dop-alt-name =  buf_code.misc1
      .
  end.
  else do:
    run gdsoattr-value in this-procedure
                        ( input  {&attr-dop-alt-name-o}
                         ,input  p-gds-code
                         ,input  p-obj-type
                         ,input  p-obj-code
                         ,output v-dop-alt-name
                         ,output v-type
                        ) no-error .
  end.

  CASE p-name-2cd:
    when "name" then do:
      if p-mode then return p-engl-name + v-dop-alt-name.
      return "Англ. название".
    end.
    when "code":U then do:
      if p-mode then  return string( p-b-code, ">>>>>>>>>>>>>>>9" )  .
      return "Лок. код товара"  .
    end.
    when "GTD":U
    or
    when "name-GTD":U
    or
    when "code-GTD":U
    or
    when "alpha1|gtd":U
    or
    when "name-alpha1|gtd":U
    or
    when "code-alpha1|gtd":U
    then do:
      /*первый в списке свободной зоны ГТД на товар*/
      if p-mode then do:
        run gdcstcod_cst-code  in this-procedure (
                                                    input  p-obj-type
                                                    ,input  p-obj-code
                                                    ,input  p-gds-code
                                                    ,input  p-in-code
                                                    ,input  p-part-code
                                                    ,output p-gtd
                                                    ) no-error .
      end.
      if p-name-2cd = "name-gtd":U then do:
        if p-mode then return p-engl-name  + v-dop-alt-name.
        return "Англ. название".
      end.
      if p-name-2cd = "name-alpha1|gtd":U then do:
        if p-mode then return p-engl-name  + v-dop-alt-name.
        return "Англ. название".
      end.
      if p-name-2cd = "code-GTD":U then do:
        if p-mode then  return string( p-b-code, ">>>>>>>>>>>>>>>9" )  .
        return "Лок. код товара"  .
      end.
      if p-name-2cd = "code-alpha1|gtd":U then do:
        if p-mode then  return string( p-b-code, ">>>>>>>>>>>>>>>9" )  .
        return "Лок. код товара"  .
      end.
      if p-mode then do:
        if p-name-2cd = "GTD" then  return p-gtd.
        if p-name-2cd = "alpha1|gtd" then  return (p-alpha1 + "|" + p-gtd).
      end.
      if p-name-2cd = "GTD" then  return "Код ГТД".
      if p-name-2cd = "alpha1|gtd" then  return "Страна|Код ГТД".
    end.
  END CASE.
end.
else do:
  if p-name-2cd = "name-gtd":U
  or p-name-2cd = "code-GTD":U
  or p-name-2cd = "name-alpha1|GTD":U
  or p-name-2cd = "code-alpha1|GTD":U
  or p-name-2cd = "alpha1|GTD":U
  then do:
    if p-mode then do:
      run gdcstcod_cst-code  in this-procedure (
                                                   input  p-obj-type
                                                  ,input  p-obj-code
                                                  ,input  p-gds-code
                                                  ,input  p-in-code
                                                  ,input  p-part-code
                                                  ,output p-gtd
                                                  ) no-error .
    end.
    else do:
      if p-name-2cd = "gtd":U then
      p-gtd = "Код ГТД".
      if p-name-2cd = "alpha1|Gtd":U then
      p-gtd = "Страна|Код ГТД".
    end.
  end.
  if p-mode then  return p-part-code.
  return "Код партии".
end.
END FUNCTION.


function chk-name_ibm_maria_ibm-xml_infokiosk_ibs-th returns character ( input p-pos-type as character
                                         ,input p-nam-2str as logical
                                         ,input p-nam-artc as logical
                                         ,input p-unit-cli-type as character
                                         ,input p-unit-base as character
                                         ,input p-unit-cli as character
                                         ,input p-cli-base-rate as decimal
                                         ,input p-artic as character
                                         ,input p-f-name as character
                                         ,input p-gds-name as character
                                         ,input p-gds-name1 as character
                                         ,output p-second-name as character):
define variable v-length as integer no-undo .
define variable nam-2str-shift as integer no-undo .
define variable chk_name as character no-undo .
assign
v-length = (if p-pos-type = {&cd-type-ibm} then 25 else 40 )
v-length = (if p-pos-type = {&cd-type-maria} then 24 else v-length)
v-length = (if p-pos-type = {&cd-type-maria} and lookup({&petrolium}, p-unit-cli-type) > 0
            then 5
            else v-length)
v-length = (if p-pos-type = {&cd-type-ibm-xml} then 128 else v-length )
nam-2str-shift = (if p-nam-2str then v-length else 0)
.
if p-nam-artc then do:
  assign
  chk_name = substitute("&1 &2", p-artic, p-f-name)
    .
end.
else  do:
  assign
  chk_name = replace(p-gds-name, {&double-quote}, "":U) + p-f-name
  .
end.
if p-unit-base <> p-unit-cli then do:
  if length (chk_name) > 109 then chk_name = substring (chk_name,1,109) .
  assign
  chk_name = string(substr(chk_name
                            ,1
                            ,max(14, v-length + nam-2str-shift - 1 - length(trim(string(p-cli-base-rate), {&space-char}))) +  nam-2str-shift ) +
                    "*":U +
                    trim(string(p-cli-base-rate), {&space-char}), "x(":U + string(v-length + nam-2str-shift) + ")":U ).
end.
else do:
  chk_name = string(chk_name, "X(":U + string(v-length + nam-2str-shift) + ")":U).
end.
if p-nam-2str then do:
  assign
  p-second-name = {&double-quote} + trim(substr(chk_name, v-length)," ") + {&double-quote}
  chk_name = substr(chk_name, 1, v-length)
  .
end.
else do:
  assign
  p-second-name = replace(p-gds-name1, {&single-quote}, "":U)
  p-second-name =   ({&double-quote} +
                    TRIM(string( replace(p-second-name, {&double-quote}, "":U), "X(":U + string(v-length) + ")":U )) /* англ назв или лок код или номер партии*/
                    + {&double-quote} )
  .
end.
return chk_name.
end function.
/* $Workfile$ e n d */