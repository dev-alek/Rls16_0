/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

получение путей из INi и т.д. для касс NCR

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/23/03
Author: Bakhtadze Natalya
Creation date: 06/23/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

run str/get-inis.p (
                input {&shop}
              , input {&cd-buffer}.obj-code
              , input {&cd-buffer}.pos-type
              , input cash-desk.remote
              , input "send":U /*некий параметр который говорит для чего нам настройки*/
              , output out
              , output out2
              , output in_
              , output spl
              , output sav
              , output v-remote
              )  no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                          , {&cd-buffer}.pos-type
                          , {&cd-buffer}.obj-code
                          , {&new-line}
                          , error-status:get-message(1)
                          , return-value )).
  assign
  v-view-log = yes.
  return error.
end.

&if "{&subject}" = "good" or "{&subject}" = "gds-obj-attr" &then

/*соответствие процента скидки и кода скидки*/
_do26:
do vdr-26 = 1 to 3:
  CASE vdr-26:
    when 1 then do:
      assign
      vc-obj-code = ub.shop.obj-code
      vc-obj-type = {&shop}
      vc-host-code = ub.shop.host-code
      vc-region    = substitute("&1&2", vc-obj-type, vc-obj-code)
      .
    end.
    when 2 then do:
      assign
      vc-obj-code = 0
      vc-obj-type = '':U
      vc-host-code = ub.shop.host-code
      vc-region    = substitute("Фирма &1&2", vc-host-code)
      .
    end.
    when 3 then do:
      assign
      vc-obj-code = 0
      vc-obj-type = '':U
      vc-host-code = 0
      vc-region    = "Глобально"
      .
    end.
  END CASE.
  find ub.dis-rule no-lock where
                ub.dis-rule.upper-rule-num = 26 /*disrules.i todo*/
            and ub.dis-rule.host-code = vc-host-code
            AND ub.dis-rule.obj-type = vc-obj-type
            AND ub.dis-rule.obj-code = vc-obj-code no-error .
  if available ub.dis-rule then LEAVE _do26.
end.
/*соответствия кодов и значения для стандартных скидок для кассы NCR*/
if available ub.dis-rule then do:
  for each buf_dis-rule no-lock where
          buf_dis-rule.upper-rule-num = ub.dis-rule.rule-num :
    assign
    ncrgmdsc = ncrgmdsc + (if ncrgmdsc = "":U then "":U else ";") +
                string(buf_dis-rule.dis-kat) + "=":U +
                string(buf_dis-rule.discnt-value).
  end.
end.
/*приоритеты скидок на товар*/
run adm/shattri.p (
        input "get":U
        ,input  {&shop}
        ,input  {&cd-buffer}.obj-code
        ,input  (if {&cd-buffer}.pos-type = {&cd-type-ncr-gm} then {&attr-cd-type-ncr-gm} else {&attr-cd-type-ncr-as-r})
        ,input  (if {&cd-buffer}.pos-type = {&cd-type-ncr-gm}
                then {&attr-cd-type-ncr-gm_ncrdrank}
                else {&attr-cd-type-ncr-as-r_ncrdrank})
                    /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
IF not error-status:error then do:
  ncrdrank = v-value-character.
end.
delete object v-tth.

run adm/shattri.p (
        input "get":U
        ,input  {&shop}
        ,input  {&cd-buffer}.obj-code
        ,input  (if {&cd-buffer}.pos-type = {&cd-type-ncr-gm} then {&attr-cd-type-ncr-gm} else {&attr-cd-type-ncr-as-r})
        ,input  (if {&cd-buffer}.pos-type = {&cd-type-ncr-gm}
                then {&attr-cd-type-ncr-gm_ncrscpfx}
                else {&attr-cd-type-ncr-as-r_ncrscpfx})
                    /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
IF not error-status:error then
ncrsc-pfx = string(v-value-integer).
delete object v-tth.

run adm/shattri.p (
        input "get":U
        ,input  {&shop}
        ,input  {&cd-buffer}.obj-code
        ,input  (if {&cd-buffer}.pos-type = {&cd-type-ncr-gm} then {&attr-cd-type-ncr-gm} else {&attr-cd-type-ncr-as-r})
        ,input  (if {&cd-buffer}.pos-type = {&cd-type-ncr-gm}
                then {&attr-cd-type-ncr-gm_ncrpgpfx}
                else {&attr-cd-type-ncr-as-r_ncrpgpfx})
                    /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
IF not error-status:error then
ncrpg-pfx = string(v-value-integer).
delete object v-tth.

&endif

/*места хранения неприкосновенных копий файлов настроек*/
&if "{&subject}" = "good" or "{&subject}" = "gds-obj-attr" or  "{&subject}" = "tot-discnt" or  "{&subject}" = "sum-grp" or "{&subject}" = "parameters" &then
&if "{&subject}" = "parameters" &then
  if true then do:
&else
  if {&cd-buffer}.pos-type = {&cd-type-ncr-as-r} then do:
&endif
run adm/shattri.p (
        input "get":U
        ,input  {&shop}
        ,input  {&cd-buffer}.obj-code
        ,input  (if {&cd-buffer}.pos-type = {&cd-type-ncr-gm} then {&attr-cd-type-ncr-gm} else {&attr-cd-type-ncr-as-r})
        ,input  (if {&cd-buffer}.pos-type = {&cd-type-ncr-gm}
                then {&attr-cd-type-ncr-gm_save-param}
                else {&attr-cd-type-ncr-as-r_save-param})
                    /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .

  IF not error-status:error then
  ncr-save-param = v-value-character.
  delete object v-tth.
end.
&endif

/* $Workfile$ e n d */