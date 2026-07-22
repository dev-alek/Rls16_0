logFile = "si_pokmi.log".

define variable v-param     as decimal no-undo.
define variable v-delta-min as decimal   no-undo.
define variable v-delta     as decimal   no-undo.

define buffer sr-izmerenia for ub.sr-izmerenia.

&scoped-define out-v-delta if v-delta = ? then "-" else right-trim(right-trim(string(v-delta,"9.999"),"0"),".")
&scoped-define out-v-delta-min right-trim(right-trim(string(v-delta-min,"9.99"),"0"),".")
&scoped-define out-v-param right-trim(right-trim(string(v-param,"9.999"),"0"),".")
&scoped-define out-msg выходит за границы допустимого диапазона  &2...&3

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
        substitute("  Значение ~"Абс. погрешность измерений ур. нефтепродукта и подтоварной воды~" &1 {&out-msg}",
                   {&out-v-param},
                   {&out-v-delta-min},
                   {&out-v-delta})
        skip
      .  
    v-delta-min = 0.
    v-param = sr-izmerenia.sr-abs-err-water.
    if v-param > v-delta or v-param < (-1) * v-delta then
      put stream logOutput unformatted
        substitute("  Значение ~"Абс. погрешность измерений ур. подтоварной воды~" &1 {&out-msg}",
                   {&out-v-param},
                   {&out-v-delta-min},
                   {&out-v-delta})
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
        substitute("  Значение ~"Абс. погрешность из. температуры (объем)~" &1 {&out-msg}",
                   {&out-v-param},
                   {&out-v-delta-min},
                   {&out-v-delta})
        skip
      .   
    v-param = sr-izmerenia.sr-abs-err-temp-dens.
    if v-param > v-delta or v-param < (-1) * v-delta then
      put stream logOutput unformatted
        substitute("  Значение ~"Абс. погрешность из. температуры (плотность)~" &1 {&out-msg}",
                   {&out-v-param},
                   {&out-v-delta-min},
                   {&out-v-delta})
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
        substitute("  Значение ~"Абсолютная погрешность измерений плотности~" &1 {&out-msg}",
                   {&out-v-param},
                   {&out-v-delta-min},
                   {&out-v-delta})
        skip
      .  
    v-delta = 1.5.
    v-param = sr-izmerenia.sr-abs-err-dens-lgas-liquid.
    if v-param > v-delta or v-param < (-1) * v-delta then
      put stream logOutput unformatted
        substitute("  Значение ~"Абсолютная погрешность измерений плотности ЖФ~" &1 {&out-msg}",
                   {&out-v-param},
                   {&out-v-delta-min},
                   {&out-v-delta})
        skip
      .   
    v-param = sr-izmerenia.sr-abs-err-dens-lgas-vapor.
    if v-param > v-delta or v-param < (-1) * v-delta then
      put stream logOutput unformatted
        substitute("  Значение ~"Абсолютная погрешность измерений плотности ПГФ~" &1 {&out-msg}",
                   {&out-v-param},
                   {&out-v-delta-min},
                   {&out-v-delta})
        skip
      .   
  end.    
  
  if last(sr-izmerenia.node-code) then
    output stream logOutput close.    
end.

