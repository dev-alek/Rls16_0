/*

$Revision: 0425b3e124f6, 2861, rls $
$Author: Ostroukhov $
$Date: Пн ноя 22 19:49:08 2021 +0300 $
$Workfile: sr-izm.i $
$Archive: ref/sr-izm.i $

Справочник средств измерений

Автор: Шальнев Иван Сергеевич
Дата создания: 28/12/11
Author: Shalnev Ivan
Creation date: 28/12/11

*/

{ gbl/color.i }

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: sr-izm.i $ $Revision: 0425b3e124f6, 2861, rls $".

&if "{2}" <> "proc" &then

define temp-table {1} no-undo


field sr-model as character column-label "Модель"
format "X(35)" label "Модель"
view-as fill-in size 35 by 1

field sr-type-id as integer column-label "Тип"
format ">9" label "Тип"
view-as combo-box list-item-pairs "Ареометр, отградуирован при 15°С",1,
                                  "Ареометр, отградуирован при 20°С",2,
                                  "Поточный плотномер",3,
                                  "Погружной плотномер",4,
                                  "Канал измерения плотности (с поточным плотномером)",5,
                                  "Канал измерения плотности (без поточного плотномера)",6   inner-lines 5 drop-down-list size-chars 55 by 1

field sr-level as logical column-label "Уровень"
field sr-Density as logical column-label "Плотность"
field sr-Temperature as logical column-label "Температура"
field sr-Weight as logical column-label "Масса"

field sr-type-level-measuring as decimal  column-label "Способ расчета предела абс. погрешности уровня"
format ">9" label "Способ расчета предела абс. погрешности уровня" init ?

field sr-temp-line as decimal column-label "Температурный коэффициент линейного! расширения материала средства! измерения уровня, 1/°С "
format "-9.9999999" label "Температурный коэффициент линейного расширения материала средства измерения уровня, 1/°С "


field sr-abs-err-neft-water as decimal column-label "Абсолютная погрешность!измерений уровня, мм"
format "9.99" initial ? label "Абс. погрешность измерений уровня"
view-as fill-in size 15  by 1

field sr-Relative-err-neft-water as decimal column-label "Относительная погрешность измерений уровня нефтепродукта и подтоварной воды, %"
format "9.999" initial ? label "Относительная погрешность измерений уровня нефтепродукта и подтоварной воды, %"
view-as fill-in size 15  by 1

field sr-abs-err-water as decimal column-label "Абсолютная погрешность измерений! уровня подтоварной воды, мм"
format "9.99" initial 0 label "Абсолютная погрешность измерений уровня подтоварной воды, мм"
view-as fill-in size 15  by 1

field sr-Relative-err-water as decimal column-label "Относительная погрешность измерений уровня подтоварной воды, %"
format "9.999" initial 0 label "Относительная погрешность измерений уровня подтоварной воды, %"
view-as fill-in size 15  by 1



field sr-abs-err-temp-vol as decimal column-label "Абсолютная погрешность измерений температуры нефтепродукта при измерении его объема, °С"
format "9.9999" initial 0 label "Абсолютная погрешность измерений температуры нефтепродукта при измерении его объема, °С"
view-as fill-in size 15  by 1


field sr-abs-err-temp-dens as decimal column-label "Абсолютная погрешность измерений температуры нефтепродукта при измерении его плотности, °С"
format "9.9999" initial 0 label "Абсолютная погрешность измерений температуры нефтепродукта при измерении его плотности, °С"
view-as fill-in size 15  by 1



field sr-type-density-measuring as integer column-label "Тип средства измерения плотности"
format "9" label "Тип средства измерения плотности"
view-as combo-box list-item-pairs "Ареометр, отградуирован при 15°С",1,
                                  "Ареометр, отградуирован при 20°С",2,
                                  "Поточный плотномер",3,
                                  "Погружной плотномер",4,
                                  "Канал измерения плотности (с поточным плотномером)",5,
                                  "ПКанал измерения плотности (без поточного плотномера).",6
                                  inner-lines 3 drop-down-list size-chars 55 by 1

field sr-abs-err-dens as decimal column-label "Абсолютная погрешность измерений плотности нефтепродукта, кг/м3"
format "9.9999" initial 0 label "Абсолютная погрешность измерений плотности нефтепродукта, кг/м3"
view-as fill-in size 15  by 1

field sr-Relative-err-dens as decimal column-label " Относительная погрешность измерений плотности нефтепродукт, %"
format "9.999" initial 0 label " Относительная погрешность измерений плотности нефтепродукт, %"
view-as fill-in size 15  by 1

field sr-abs-err-dens-lgas-liquid as decimal column-label "Абсолютная погрешность измерений плотности ЖФ продукта, кг/м3"
format "9.9999" initial 0 label "Абсолютная погрешность измерений плотности ЖФ продукта, кг/м3"
view-as fill-in size 15  by 1

field sr-relative-err-dens-lgas-liquid as decimal column-label "Относительная погрешность измерений плотности ЖФ продукта, %"
format "9.999" label "Относительная погрешность измерений плотности ЖФ продукта, %"
view-as fill-in size 15  by 1

field sr-abs-err-dens-lgas-vapor as decimal column-label " Абсолютная погрешность измерений плотности ПГФ продукта, кг/м3"
format "9.999" initial 0 label "Абсолютная погрешность измерений плотности ПГФ продукта, кг/м3"
view-as fill-in size 15  by 1

field sr-otnos as decimal column-label "относительная погрешность измерения массы, %"
format "9.999999" initial 0 label "относительная погрешность измерения массы, %"
view-as fill-in size 15  by 1


field node-code as integer  column-label "Код"
format ">>>9" label "Код"
fgcolor RED_COLOR

index pi is unique primary
node-code
.
&if "{2}" = "ds" &then

define dataset sr-izmerenia-ds for {1}.

&endif
&endif

&if "{2}" = "proc" &then

procedure sr-izmerenia_fill-sr-izm :
/* заполним таблицу из clob */
define input parameter p-mode as character no-undo .
define parameter buffer buf_clob-bind for ub.clob-bind.
define buffer buf_clob-data for ub.clob-data.
define variable v-longchar as longchar no-undo .
define variable glog as logical no-undo .
case p-mode:
  when  {&update} then do:
   find first buf_clob-bind exclusive-lock where
            buf_clob-bind.resource-type = {&lob-res-ref}
       and buf_clob-bind.uniq-key-rec = "sr-izmerenia.xml"
       and buf_clob-bind.field-name = "" no-error.

  end.
  otherwise do:
    find first buf_clob-bind no-lock where
            buf_clob-bind.resource-type = {&lob-res-ref}
       and buf_clob-bind.uniq-key-rec = "sr-izmerenia.xml"
       and buf_clob-bind.field-name = "" no-error.
  end.
end case.
if available buf_clob-bind then do:
  find first buf_clob-data no-lock where
            buf_clob-data.db-num = buf_clob-bind.db-num
        and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
  if available buf_clob-data then do:
    v-longchar = buf_clob-data.cdata.
    glog = DATASET sr-izmerenia-ds:HANDLE:read-XML("LONGCHAR"
                                                  , v-longchar
                                                  , "EMPTY" /*read-mode*/
                                                  , ? /*schema-location*/
                                                  , ? /*override-default-mapping*/
                                                  , ? /*field-type-mapping*/
                                                  , "loose" /*verify-schema-mode*/  )  no-error .
    if error-status:error
    or not glog then do:
      MESSAGE
      "НЕ удается прочитать справочник из БД " skip
      ERROR-STATUS:GET-MESSAGE(1) SKIP
      RETURN-VALUE
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
    end.
  end.
end.
end procedure. /* fill-msf */

&endif