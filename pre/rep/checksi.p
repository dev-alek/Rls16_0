block-level on error undo, throw.
define input  parameter iKey     as integer no-undo.
define output parameter oChekSum as character no-undo.
if userid("ub") eq ""
then do:
   oChekSum = encode(string(iKey * 13)) + string(index(encode(string(iKey)), "k"))
 .
   return.
end.
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
define variable v-curr-r-b as character no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable logFile  as character no-undo.
define buffer buf_clob-bind for ub.clob-bind.
define stream logOutput.
logFile = "si_pokmi.log".
define variable v-param     as decimal no-undo.
define variable v-delta-min as decimal   no-undo.
define variable v-delta     as decimal   no-undo.
define buffer sr-izmerenia for ub.sr-izmerenia.
for each sr-izmerenia no-lock break by sr-izmerenia.node-code:
  if first(sr-izmerenia.node-code) then
    output stream logOutput to value(logFile).
  put stream logOutput unformatted
    substitute("Код СИ: &1; Модель: &2",
             sr-izmerenia.node-code,
             sr-izmerenia.sr-model)
    skip
  .
  v-delta-min = 0.
  if sr-izmerenia.sr-level then
  do:
    case sr-izmerenia.sr-type-izm:
      when 1 then assign v-delta-min = 0.01 v-delta = 3.
      when 2 then assign v-delta-min = 0.01 v-delta = 3.
      when 3 then assign v-delta-min = 0.01 v-delta = ?.
    end case.
    v-param = sr-izmerenia.sr-abs-err-neft-water.
    if abs(v-param) < v-delta-min or v-param > v-delta or v-param < (-1) * v-delta then
      put stream logOutput unformatted
        substitute("  Значение ~"Абс. погрешность измерений ур. нефтепродукта и подтоварной воды~" &1 выходит за границы допустимого диапазона  &2...&3",
                   right-trim(right-trim(string(v-param,"9.999"),"0"),"."),
                   right-trim(right-trim(string(v-delta-min,"9.99"),"0"),"."),
                   if v-delta = ? then "-" else right-trim(right-trim(string(v-delta,"9.999"),"0"),"."))
        skip
      .
    v-delta-min = 0.
    v-param = sr-izmerenia.sr-abs-err-water.
    if v-param > v-delta or v-param < (-1) * v-delta then
      put stream logOutput unformatted
        substitute("  Значение ~"Абс. погрешность измерений ур. подтоварной воды~" &1 выходит за границы допустимого диапазона  &2...&3",
                   right-trim(right-trim(string(v-param,"9.999"),"0"),"."),
                   right-trim(right-trim(string(v-delta-min,"9.99"),"0"),"."),
                   if v-delta = ? then "-" else right-trim(right-trim(string(v-delta,"9.999"),"0"),"."))
        skip
      .
  end.
  if sr-izmerenia.sr-temperature then
  do:
    case sr-izmerenia.sr-type-izm:
      when 1 then v-delta = 0.5.
      when 2 then v-delta = 0.5.
      when 3 then v-delta = 0.2.
    end case.
    v-param = sr-izmerenia.sr-abs-err-temp-vol.
    if v-param > v-delta or v-param < (-1) * v-delta then
      put stream logOutput unformatted
        substitute("  Значение ~"Абс. погрешность из. температуры (объем)~" &1 выходит за границы допустимого диапазона  &2...&3",
                   right-trim(right-trim(string(v-param,"9.999"),"0"),"."),
                   right-trim(right-trim(string(v-delta-min,"9.99"),"0"),"."),
                   if v-delta = ? then "-" else right-trim(right-trim(string(v-delta,"9.999"),"0"),"."))
        skip
      .
    v-param = sr-izmerenia.sr-abs-err-temp-dens.
    if v-param > v-delta or v-param < (-1) * v-delta then
      put stream logOutput unformatted
        substitute("  Значение ~"Абс. погрешность из. температуры (плотность)~" &1 выходит за границы допустимого диапазона  &2...&3",
                   right-trim(right-trim(string(v-param,"9.999"),"0"),"."),
                   right-trim(right-trim(string(v-delta-min,"9.99"),"0"),"."),
                   if v-delta = ? then "-" else right-trim(right-trim(string(v-delta,"9.999"),"0"),"."))
        skip
      .
  end.
  if sr-izmerenia.sr-density then
  do:
    case sr-izmerenia.sr-type-izm:
      when 1 then v-delta = 1.
      when 2 then v-delta = 0.5.
      when 3 then v-delta = 0.5.
    end case.
    v-param = sr-izmerenia.sr-abs-err-dens.
    if v-param > v-delta or v-param < (-1) * v-delta then
      put stream logOutput unformatted
        substitute("  Значение ~"Абсолютная погрешность измерений плотности~" &1 выходит за границы допустимого диапазона  &2...&3",
                   right-trim(right-trim(string(v-param,"9.999"),"0"),"."),
                   right-trim(right-trim(string(v-delta-min,"9.99"),"0"),"."),
                   if v-delta = ? then "-" else right-trim(right-trim(string(v-delta,"9.999"),"0"),"."))
        skip
      .
    v-delta = 1.5.
    v-param = sr-izmerenia.sr-abs-err-dens-lgas-liquid.
    if v-param > v-delta or v-param < (-1) * v-delta then
      put stream logOutput unformatted
        substitute("  Значение ~"Абсолютная погрешность измерений плотности ЖФ~" &1 выходит за границы допустимого диапазона  &2...&3",
                   right-trim(right-trim(string(v-param,"9.999"),"0"),"."),
                   right-trim(right-trim(string(v-delta-min,"9.99"),"0"),"."),
                   if v-delta = ? then "-" else right-trim(right-trim(string(v-delta,"9.999"),"0"),"."))
        skip
      .
    v-param = sr-izmerenia.sr-abs-err-dens-lgas-vapor.
    if v-param > v-delta or v-param < (-1) * v-delta then
      put stream logOutput unformatted
        substitute("  Значение ~"Абсолютная погрешность измерений плотности ПГФ~" &1 выходит за границы допустимого диапазона  &2...&3",
                   right-trim(right-trim(string(v-param,"9.999"),"0"),"."),
                   right-trim(right-trim(string(v-delta-min,"9.99"),"0"),"."),
                   if v-delta = ? then "-" else right-trim(right-trim(string(v-delta,"9.999"),"0"),"."))
        skip
      .
  end.
  if last(sr-izmerenia.node-code) then
    output stream logOutput close.
end.
message "Отчет сформирован в" search(logFile) "."
   view-as alert-box.
