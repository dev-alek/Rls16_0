block-level on error undo, throw.
define input parameter p-schet as character no-undo .
define input parameter p-bik as character no-undo .
define input parameter p-curr-code like ub.currency.curr-code no-undo .
define input parameter p-is-credit as logical no-undo .
define output parameter p-correct as logical no-undo .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: keyschet.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/keyschet.p $":U .
def var vss-description as character no-undo init "Проверка валидности номера лицевого счета".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define variable v-key as character no-undo .
define variable v-key-check as character no-undo .
define variable kc as integer no-undo .
define variable kc-check as integer no-undo .
define variable v-int as integer no-undo .
define variable v-dop as character no-undo .
define variable v-dopi as integer no-undo .
define buffer buf_currency for ub.currency.
function sum-ml-razr returns integer(INPUT p-key as character):
define variable v-sum-ml-razr as integer no-undo .
define variable v-ves-coeff as integer no-undo .
define variable ii as integer no-undo .
define variable v-razr-value as integer no-undo extent 23.
do ii = 1 to length(p-key):
  CASE  ii modulo 3:
    when 1 then assign
    v-ves-coeff = 7.
    when 2 then assign
    v-ves-coeff = 1.
    when 0 then assign
    v-ves-coeff = 3.
  END CASE.
  assign
  v-razr-value[ii] = integer(substr(p-key, ii, 1)) * v-ves-coeff
  no-error
  .
  if error-status:error then return ?.
  assign
  v-sum-ml-razr = v-sum-ml-razr + (v-razr-value[ii] modulo 10)
  .
end.
return v-sum-ml-razr.
END FUNCTION.
if length(p-schet) <> 20 then do:
  return substitute("Неверная длина номера счета &1 (должна быть 20)", length(p-schet)).
end.
find first buf_currency no-lock where
        buf_currency.curr-code = p-curr-code no-error.
if available buf_currency
and buf_currency.okv-code <> 0 then do:
  assign
  v-dopi = integer(substring(p-schet, 6, 3))
  no-error .
  if error-status:error  or (v-dopi <> buf_currency.okv-code and not (v-dopi = 810 and buf_currency.okv-code = 643)  ) then do:
    return substitute("Несоответствие счета коду валюты по ОКВ: код валюты: &1, код валюты по ОКВ &2, соответствующие символы в счете -(позиции 6-8): &3"
                     , p-curr-code
                     , buf_currency.okv-code
                     , substring(p-schet, 6, 3)).
  end.
end.
assign
v-key = (if p-is-credit
        then  substr(p-bik, 7, 3)
        else ("0":U + substr(p-bik, 5, 2))
        ) +
        p-schet
v-dop = v-key
.
assign
v-key = substring(v-dop, 1, 11) + "0":U
v-key = v-key + substring(v-dop, 13)
v-dop = v-key
.
if length(p-bik) <> 9 then do:
  return substitute("Неверная длина БИК &1 (должна быть 9)", length(p-bik)).
end.
assign
KC = ((sum-ml-razr(v-key) modulo 10) * 3) modulo 10
no-error
.
if error-status:error  then do:
  return "Неверные символы в номере счета".
end.
assign
v-key-check = substring(v-dop, 1, 11) + string(KC) + substring(v-dop, 13)
.
assign
KC-check = (sum-ml-razr(v-key-check) modulo 10)
no-error .
if error-status:error  then do:
  return  "Неверные символы в номере счета".
end.
assign
p-correct = (kc-check = 0) AND (string(KC) = substring(p-schet, 9, 1))
.
if not p-correct then do:
  return  "Неверное значение номера счета".
end.
