define input  parameter iMode as character  no-undo.
define input  parameter inode-code as integer no-undo.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 15 BY 1.13.
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Ввод"
     SIZE 15 BY 1.13.
DEFINE VARIABLE abs-err-dens-lgas-liquid-text AS CHARACTER FORMAT "x(5)" INITIAL "кг/м3"
      VIEW-AS TEXT
     SIZE 8.6 BY .62.
DEFINE VARIABLE abs-err-dens-lgas-vapor-text AS CHARACTER FORMAT "x(5)" INITIAL "кг/м3"
      VIEW-AS TEXT
     SIZE 8.6 BY .62.
DEFINE VARIABLE abs-err-dens-text AS CHARACTER FORMAT "x(5)" INITIAL "кг/м3"
      VIEW-AS TEXT
     SIZE 8.6 BY .62.
DEFINE VARIABLE abs-err-neft-water-text AS CHARACTER FORMAT "x(2)" INITIAL "мм"
      VIEW-AS TEXT
     SIZE 4.4 BY .62.
DEFINE VARIABLE abs-err-temp-dens-text AS CHARACTER FORMAT "x(2)" INITIAL "°С"
      VIEW-AS TEXT
     SIZE 4.4 BY .62.
DEFINE VARIABLE abs-err-temp-vol-text AS CHARACTER FORMAT "x(2)" INITIAL "°С"
      VIEW-AS TEXT
     SIZE 4.4 BY .62.
DEFINE VARIABLE abs-err-water-text AS CHARACTER FORMAT "x(2)" INITIAL "мм"
      VIEW-AS TEXT
     SIZE 4.4 BY .62.
DEFINE VARIABLE otnos-text AS CHARACTER FORMAT "x(1)" INITIAL "%"
      VIEW-AS TEXT
     SIZE 2.2 BY .62.
DEFINE VARIABLE relative-err-dens-lgas-liquid-t AS CHARACTER FORMAT "x(1)" INITIAL "%"
      VIEW-AS TEXT
     SIZE 2.2 BY .62.
DEFINE VARIABLE relative-err-dens-text AS CHARACTER FORMAT "x(1)" INITIAL "%"
      VIEW-AS TEXT
     SIZE 2.2 BY .62.
DEFINE VARIABLE relative-err-neft-water-text AS CHARACTER FORMAT "x(1)" INITIAL "%"
      VIEW-AS TEXT
     SIZE 2.2 BY .62.
DEFINE VARIABLE relative-err-water-text AS CHARACTER FORMAT "x(1)" INITIAL "%"
      VIEW-AS TEXT
     SIZE 2.2 BY .62.
DEFINE VARIABLE temp-line-text AS CHARACTER FORMAT "x(4)" INITIAL "1/°С"
      VIEW-AS TEXT
     SIZE 7.6 BY .62.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 99 BY 9.1.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 99 BY 5.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 99 BY 8.81.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 99 BY 2.86.
DEFINE QUERY Dialog-Frame FOR
      sr-izmerenia SCROLLING.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.76 COL 6.2 WIDGET-ID 64
     Btn_Cancel AT ROW 1.76 COL 22.6 WIDGET-ID 62
     sr-izmerenia.sr-not-used AT ROW 1.91 COL 40 WIDGET-ID 116
          VIEW-AS TOGGLE-BOX
          SIZE 40 BY .81
     sr-izmerenia.node-code AT ROW 2 COL 85.6 COLON-ALIGNED WIDGET-ID 66
          VIEW-AS FILL-IN
          SIZE 14 BY 1
     sr-izmerenia.sr-model AT ROW 3.19 COL 29.6 COLON-ALIGNED WIDGET-ID 94
          VIEW-AS FILL-IN
          SIZE 70 BY 1
     sr-izmerenia.sr-type-izm AT ROW 4.62 COL 29.6 COLON-ALIGNED WIDGET-ID 110
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "Измерительная система",2,
                     "Автоматизированное СИ",0,
                     "Неавтоматизированное СИ",1
          DROP-DOWN-LIST
          SIZE 70 BY 1
     sr-izmerenia.sr-level AT ROW 6.95 COL 5.6 WIDGET-ID 92
          VIEW-AS TOGGLE-BOX
          SIZE 13.4 BY .81
     sr-izmerenia.sr-type-level-measuring AT ROW 7.91 COL 39.6 COLON-ALIGNED WIDGET-ID 112
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "Расчет по ГОСТ 7502 (рулетка 2 класса точности)",1,
                     "Расчет по формуле (плотномер-уровнемер ПЛОТ-3Б-1РУ)",2,
                     "Ввод погрешности вручную",0
          DROP-DOWN-LIST
          SIZE 56 BY 1
     sr-izmerenia.sr-temp-line AT ROW 9.14 COL 61.6 COLON-ALIGNED WIDGET-ID 104
          VIEW-AS FILL-IN
          SIZE 26 BY 1
     sr-izmerenia.sr-abs-err-neft-water AT ROW 10.33 COL 61.6 COLON-ALIGNED WIDGET-ID 82
          VIEW-AS FILL-IN
          SIZE 26 BY 1
     sr-izmerenia.sr-relative-err-neft-water AT ROW 11.48 COL 61.6 COLON-ALIGNED WIDGET-ID 100
          VIEW-AS FILL-IN
          SIZE 26 BY 1
     sr-izmerenia.sr-abs-err-water AT ROW 12.71 COL 61.6 COLON-ALIGNED WIDGET-ID 88
          VIEW-AS FILL-IN
          SIZE 26 BY 1
     sr-izmerenia.sr-relative-err-water AT ROW 13.91 COL 61.6 COLON-ALIGNED WIDGET-ID 102
          VIEW-AS FILL-IN
          SIZE 26 BY 1
     sr-izmerenia.sr-temperature AT ROW 16.05 COL 5.6 WIDGET-ID 106
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY .81
     sr-izmerenia.sr-abs-err-temp-vol AT ROW 17.19 COL 61.6 COLON-ALIGNED WIDGET-ID 86
          VIEW-AS FILL-IN
          SIZE 26 BY 1
     sr-izmerenia.sr-abs-err-temp-dens AT ROW 18.43 COL 61.6 COLON-ALIGNED WIDGET-ID 84
          VIEW-AS FILL-IN
          SIZE 26 BY 1
     sr-izmerenia.sr-density AT ROW 21.05 COL 4.6 WIDGET-ID 90
          VIEW-AS TOGGLE-BOX
          SIZE 17 BY .81
     sr-izmerenia.sr-type-id AT ROW 21.95 COL 40.6 COLON-ALIGNED WIDGET-ID 108
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "Ареометр, отградуирован при 15°С",1,
                     "Ареометр, отградуирован при 20°С",2,
                     "Поточный плотномер",3,
                     "Погружной плотномер",4,
                     "Канал измерения плотности (с поточным плотномером)",5,
                     "Канал измерения плотности (без поточного плотномера)",6
          DROP-DOWN-LIST
          SIZE 56 BY 1
     sr-izmerenia.sr-abs-err-dens AT ROW 23.43 COL 60.6 COLON-ALIGNED WIDGET-ID 76
          VIEW-AS FILL-IN
          SIZE 26 BY 1
     sr-izmerenia.sr-relative-err-dens AT ROW 24.62 COL 60.6 COLON-ALIGNED WIDGET-ID 98
          VIEW-AS FILL-IN
          SIZE 26 BY 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE  WIDGET-ID 100.
DEFINE FRAME Dialog-Frame
     sr-izmerenia.sr-abs-err-dens-lgas-liquid AT ROW 25.76 COL 60.6 COLON-ALIGNED WIDGET-ID 78
          VIEW-AS FILL-IN
          SIZE 26 BY 1
     sr-izmerenia.sr-abs-err-dens-lgas-vapor AT ROW 26.95 COL 60.6 COLON-ALIGNED WIDGET-ID 80
          VIEW-AS FILL-IN
          SIZE 26 BY 1
     sr-izmerenia.sr-relative-err-dens-lgas-liquid AT ROW 28.19 COL 60.6 COLON-ALIGNED WIDGET-ID 118
          VIEW-AS FILL-IN
          SIZE 26 BY 1
     sr-izmerenia.sr-Weight AT ROW 30.19 COL 4.6 WIDGET-ID 114
          VIEW-AS TOGGLE-BOX
          SIZE 13.4 BY .81
     sr-izmerenia.sr-otnos AT ROW 31.33 COL 61.6 COLON-ALIGNED WIDGET-ID 96
          VIEW-AS FILL-IN
          SIZE 25 BY 1
     temp-line-text AT ROW 9.29 COL 93 COLON-ALIGNED NO-LABEL
     abs-err-neft-water-text AT ROW 10.52 COL 93 COLON-ALIGNED NO-LABEL
     relative-err-neft-water-text AT ROW 11.62 COL 93 COLON-ALIGNED NO-LABEL
     abs-err-water-text AT ROW 12.86 COL 93 COLON-ALIGNED NO-LABEL
     relative-err-water-text AT ROW 14.05 COL 93 COLON-ALIGNED NO-LABEL
     abs-err-temp-vol-text AT ROW 17.33 COL 93 COLON-ALIGNED NO-LABEL
     abs-err-temp-dens-text AT ROW 18.57 COL 93 COLON-ALIGNED NO-LABEL
     abs-err-dens-text AT ROW 23.62 COL 93 COLON-ALIGNED NO-LABEL
     relative-err-dens-text AT ROW 24.81 COL 93 COLON-ALIGNED NO-LABEL
     abs-err-dens-lgas-liquid-text AT ROW 25.91 COL 93 COLON-ALIGNED NO-LABEL
     abs-err-dens-lgas-vapor-text AT ROW 27.1 COL 93 COLON-ALIGNED NO-LABEL
     relative-err-dens-lgas-liquid-t AT ROW 28.38 COL 93 COLON-ALIGNED NO-LABEL WIDGET-ID 120
     otnos-text AT ROW 31.48 COL 93 COLON-ALIGNED NO-LABEL
     RECT-1 AT ROW 6.24 COL 2.6 WIDGET-ID 68
     RECT-2 AT ROW 15.52 COL 2.6 WIDGET-ID 70
     RECT-3 AT ROW 20.76 COL 2.6 WIDGET-ID 72
     RECT-4 AT ROW 29.91 COL 2.6 WIDGET-ID 74
     SPACE(2.00) SKIP(0.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Средства измерения" WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       sr-izmerenia.node-code:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON window-close OF FRAME Dialog-Frame
do:
  apply "END-ERROR":U to self.
end.
ON choose OF Btn_OK IN FRAME Dialog-Frame
do:
  def var vMess as char no-undo.
  run check-sr-type-id no-error.
  if error-status:error
  then return no-apply .
  run check-neft-water no-error.
  if error-status:error
  then return no-apply .
  run check-err-water no-error.
  if error-status:error
  then return no-apply .
  run Check-err-dens no-error.
  if error-status:error
  then return no-apply .
  run check-sr-otnos no-error.
  if error-status:error
  then return no-apply .
  run Check-sr-abs-err-temp-vol no-error.
  if error-status:error then
     return no-apply.
  run Check-sr-abs-err-temp-dens no-error.
  if error-status:error then
     return no-apply.
  assign
     sr-izmerenia.sr-not-used
     sr-izmerenia.sr-model
     sr-izmerenia.sr-type-izm
     sr-izmerenia.sr-level
     sr-izmerenia.sr-type-level-measuring
     sr-izmerenia.sr-temp-line
     sr-izmerenia.sr-abs-err-neft-water
     sr-izmerenia.sr-relative-err-neft-water
     sr-izmerenia.sr-abs-err-water
     sr-izmerenia.sr-relative-err-water
     sr-izmerenia.sr-temperature
     sr-izmerenia.sr-abs-err-temp-vol
     sr-izmerenia.sr-abs-err-temp-dens
     sr-izmerenia.sr-density
     sr-izmerenia.sr-abs-err-dens
     sr-izmerenia.sr-relative-err-dens
     sr-izmerenia.sr-abs-err-dens-lgas-liquid
     sr-izmerenia.sr-abs-err-dens-lgas-vapor
     sr-izmerenia.sr-relative-err-dens-lgas-liquid
     sr-izmerenia.sr-Weight
     sr-izmerenia.sr-otnos
  .
  if not(    sr-izmerenia.sr-level
          or sr-izmerenia.sr-density
          or sr-izmerenia.sr-temperature
          or sr-izmerenia.sr-Weight)
  then do:
     message "Не выбран ни уровень, ни температура, ни плотность, ни масса"
        view-as alert-box.
     return no-apply.
  end.
  vMess = "".
  if       sr-izmerenia.sr-level
     and   sr-izmerenia.sr-temp-line               = ?
     and   sr-izmerenia.sr-relative-err-neft-water = ?
     and   sr-izmerenia.sr-relative-err-water      = ?
  then
     vMess = "Не указаны характеристики средства измерения уровня" .
  if     sr-izmerenia.sr-temperature
     and sr-izmerenia.sr-abs-err-temp-vol  = ?
     and sr-izmerenia.sr-abs-err-temp-dens = ?
  then
     vMess = vMess
           + (if vMess eq "" then "" else chr(10) )
           + "Не указаны характеристики средства измерения температуры.".
   if    sr-izmerenia.sr-density
     and sr-izmerenia.sr-abs-err-dens             = ?
     and sr-izmerenia.sr-relative-err-dens        = ?
     and sr-izmerenia.sr-abs-err-dens-lgas-liquid = ?
     and sr-izmerenia.sr-abs-err-dens-lgas-vapor  = ?
     and sr-izmerenia.sr-relative-err-dens-lgas-liquid = ?
   then
      vMess = vMess
            + (if vMess eq "" then "" else chr(10))
            + "Не указаны характеристики средства измерения плотности.".
  if vMess ne ""
  then do:
     define variable vOk as logical no-undo.
      message vMess skip
        "Вы уверены, что хотите закончить настройку средства измерения?"
      view-as alert-box question buttons OK-Cancel update vOk.
     if not vOk
     then
        return no-apply.
  end.
  define variable v-msg2  as character no-undo .
  define variable v-delta as decimal decimals 2 no-undo .
  define variable v-delta-min as decimal decimals 2 no-undo .
  if sr-izmerenia.sr-model > "" then .
  else do:
    message "Пожалуйста заполните наименование модели средства измерения"
    view-as alert-box.
    apply "entry" to sr-izmerenia.sr-model in frame Dialog-Frame .
    return no-apply .
  end .
  assign
    v-msg2 = "выходит за границы допустимого диапазона"
    v-delta-min = 0
  .
  if sr-izmerenia.sr-level then
  do:
      case sr-izmerenia.sr-type-izm:
         when 2 then assign v-delta-min = 0 v-delta = 3.
         when 0 then assign v-delta-min = 0 v-delta = 3.
         when 1 then assign v-delta-min = 0 v-delta = ?.
      end case.
      if abs(sr-izmerenia.sr-abs-err-neft-water) < v-delta-min or
         sr-izmerenia.sr-abs-err-neft-water > v-delta or sr-izmerenia.sr-abs-err-neft-water < (-1) * v-delta then do :
        message substitute("&1 &2&3(+/-)&4...&5 мм",
                     sr-izmerenia.sr-abs-err-neft-water:label in frame Dialog-Frame, v-msg2, chr(10),
                     if v-delta-min < 1 then right-trim(string(v-delta-min,"9.99"),"0") else string(v-delta-min),
                     string(v-delta, "9") )
        view-as alert-box.
        apply "entry" to sr-izmerenia.sr-abs-err-neft-water in frame Dialog-Frame .
        return no-apply .
      end.
      v-delta-min = 0.
      if sr-izmerenia.sr-abs-err-water > v-delta or sr-izmerenia.sr-abs-err-water < (-1) * v-delta then do :
        message substitute("&1 &2&3(+/-)&4 мм",
                     sr-izmerenia.sr-abs-err-water:label in frame Dialog-Frame, v-msg2, chr(10), string(v-delta, "9") )
        view-as alert-box.
        apply "entry" to sr-izmerenia.sr-abs-err-water in frame Dialog-Frame .
        return no-apply .
      end.
  end.
  if sr-izmerenia.sr-temperature then
  do:
      case sr-izmerenia.sr-type-izm:
         when 2 then v-delta = 0.5.
         when 0 then v-delta = 0.5.
         when 1 then v-delta = 0.2.
      end case.
      if sr-izmerenia.sr-abs-err-temp-vol > v-delta or sr-izmerenia.sr-abs-err-temp-vol < (-1) * v-delta then do :
        message substitute("&1 &2&3(+/-)&4 °С",
                     sr-izmerenia.sr-abs-err-temp-vol:label in frame Dialog-Frame, v-msg2, chr(10), string(v-delta, "9.9") )
        view-as alert-box.
        apply "entry" to sr-izmerenia.sr-abs-err-temp-vol in frame Dialog-Frame .
        return no-apply .
      end.
      if sr-izmerenia.sr-abs-err-temp-dens > v-delta or sr-izmerenia.sr-abs-err-temp-dens < (-1) * v-delta then do :
        message substitute("&1 &2&3(+/-)&4 °С",
                     sr-izmerenia.sr-abs-err-temp-dens:label in frame Dialog-Frame, v-msg2, chr(10), string(v-delta, "9.9") )
        view-as alert-box.
        apply "entry" to sr-izmerenia.sr-abs-err-temp-dens in frame Dialog-Frame .
        return no-apply .
      end.
  end.
  if sr-izmerenia.sr-density then
  do:
      case sr-izmerenia.sr-type-izm:
         when 2 then v-delta = 1.
         when 0 then v-delta = 0.5.
         when 1 then v-delta = 0.5.
      end case.
      if sr-izmerenia.sr-abs-err-dens > v-delta or sr-izmerenia.sr-abs-err-dens < (-1) * v-delta then do :
        message substitute("&1 &2&3(+/-)&4 кг/м3",
                     sr-izmerenia.sr-abs-err-dens:label in frame Dialog-Frame, v-msg2, chr(10), string(v-delta, "9.9") )
        view-as alert-box.
        apply "entry" to sr-izmerenia.sr-abs-err-dens in frame Dialog-Frame .
        return no-apply .
      end.
      v-delta = 1.5 .
      if sr-izmerenia.sr-abs-err-dens-lgas-liquid > v-delta or sr-izmerenia.sr-abs-err-dens-lgas-liquid < (-1) * v-delta then do :
        message substitute("&1 &2&3(+/-)&4 %",
                     sr-izmerenia.sr-abs-err-dens-lgas-liquid:label in frame Dialog-Frame, v-msg2, chr(10), string(v-delta, "9.99") )
        view-as alert-box.
        apply "entry" to sr-izmerenia.sr-abs-err-dens-lgas-liquid in frame Dialog-Frame .
        return no-apply .
      end.
      if sr-izmerenia.sr-abs-err-dens-lgas-vapor > v-delta or sr-izmerenia.sr-abs-err-dens-lgas-vapor < (-1) * v-delta then do :
        message substitute("&1 &2&3(+/-)&4 %",
                     sr-izmerenia.sr-abs-err-dens-lgas-vapor:label in frame Dialog-Frame, v-msg2, chr(10), string(v-delta, "9.99") )
        view-as alert-box.
        apply "entry" to sr-izmerenia.sr-abs-err-dens-lgas-vapor in frame Dialog-Frame .
        return no-apply .
      end.
      v-delta = 0.42 .
      if sr-izmerenia.sr-relative-err-dens-lgas-liquid > v-delta or sr-izmerenia.sr-relative-err-dens-lgas-liquid < (-1) * v-delta then do :
        message substitute("&1 &2&3(+/-)&4 %",
                     sr-izmerenia.sr-relative-err-dens-lgas-liquid:label in frame Dialog-Frame, v-msg2, chr(10), string(v-delta, "9.99") )
        view-as alert-box.
        apply "entry" to sr-izmerenia.sr-relative-err-dens-lgas-liquid in frame Dialog-Frame .
        return no-apply .
      end.
      case sr-izmerenia.sr-type-izm:
         when 2 then v-delta = 1.
         when 0 then v-delta = 0.5.
         when 1 then v-delta = 0.5.
      end case.
      if sr-izmerenia.sr-abs-err-dens > v-delta or sr-izmerenia.sr-abs-err-dens < (-1) * v-delta then do :
        message substitute("&1 &2&3(+/-)&4 кг/м3",
                     sr-izmerenia.sr-abs-err-dens:label in frame Dialog-Frame, v-msg2, chr(10), string(v-delta, "9.9") )
        view-as alert-box.
        apply "entry" to sr-izmerenia.sr-abs-err-dens in frame Dialog-Frame .
        return no-apply .
      end.
  end.
  if sr-izmerenia.sr-Weight then
  do:
      v-delta = 0.65 .
      if sr-izmerenia.sr-otnos > v-delta or sr-izmerenia.sr-otnos < (-1) * v-delta then do :
        message substitute("&1 &2&3(+/-)&4 %",
                     sr-izmerenia.sr-otnos:label in frame Dialog-Frame, v-msg2, chr(10), string(v-delta, "9.99") )
        view-as alert-box.
        apply "entry" to sr-izmerenia.sr-otnos in frame Dialog-Frame .
        return no-apply .
      end.
  end.
  if not sr-izmerenia.sr-density
  then
     assign
        sr-izmerenia.sr-type-id                  = ?
        sr-izmerenia.sr-abs-err-dens             = ?
        sr-izmerenia.sr-relative-err-dens        = ?
        sr-izmerenia.sr-abs-err-dens-lgas-liquid = ?
        sr-izmerenia.sr-abs-err-dens-lgas-vapor  = ?
        sr-izmerenia.sr-relative-err-water       = ?
        sr-izmerenia.sr-relative-err-dens-lgas-liquid = ?
     .
  if not sr-izmerenia.sr-level
  then
     assign
        sr-izmerenia.sr-type-level-measuring    = 0
        sr-izmerenia.sr-temp-line               = ?
        sr-izmerenia.sr-abs-err-neft-water      = ?
        sr-izmerenia.sr-relative-err-neft-water = ?
        sr-izmerenia.sr-abs-err-water           = ?
        sr-izmerenia.sr-relative-err-water      = ?
     .
  if not sr-izmerenia.sr-Weight
  then
     assign
        sr-izmerenia.sr-otnos                  = ?
             .
  if not sr-izmerenia.sr-temperature
  then
     assign
        sr-izmerenia.sr-abs-err-temp-vol  = ?
        sr-izmerenia.sr-abs-err-temp-dens = ?
     .
end.
ON value-changed OF sr-izmerenia.sr-density IN FRAME Dialog-Frame
do:
  assign
     sr-izmerenia.sr-density
  .
  assign
        sr-izmerenia.sr-type-id                  :visible = sr-izmerenia.sr-density
        sr-izmerenia.sr-abs-err-dens             :visible = sr-izmerenia.sr-density
        sr-izmerenia.sr-relative-err-dens        :visible = sr-izmerenia.sr-density
        sr-izmerenia.sr-abs-err-dens-lgas-liquid :visible = sr-izmerenia.sr-density
        sr-izmerenia.sr-abs-err-dens-lgas-vapor  :visible = sr-izmerenia.sr-density
        sr-izmerenia.sr-relative-err-dens-lgas-liquid :visible = sr-izmerenia.sr-density
        abs-err-dens-text             :visible = sr-izmerenia.sr-density
        relative-err-dens-text        :visible = sr-izmerenia.sr-density
        abs-err-dens-lgas-liquid-text :visible = sr-izmerenia.sr-density
        abs-err-dens-lgas-vapor-text  :visible = sr-izmerenia.sr-density
        relative-err-dens-lgas-liquid-t :visible = sr-izmerenia.sr-density
     .
end.
ON value-changed OF sr-izmerenia.sr-level IN FRAME Dialog-Frame
do:
  assign
     sr-izmerenia.sr-level
  .
  assign
        sr-izmerenia.sr-type-level-measuring   :visible = sr-izmerenia.sr-level
        sr-izmerenia.sr-temp-line              :visible = sr-izmerenia.sr-level
        sr-izmerenia.sr-abs-err-neft-water     :visible = sr-izmerenia.sr-level
        sr-izmerenia.sr-relative-err-neft-water:visible = sr-izmerenia.sr-level
        sr-izmerenia.sr-abs-err-water          :visible = sr-izmerenia.sr-level
        sr-izmerenia.sr-relative-err-water     :visible = sr-izmerenia.sr-level
        temp-line-text              :visible = sr-izmerenia.sr-level
        abs-err-neft-water-text     :visible = sr-izmerenia.sr-level
        relative-err-neft-water-text:visible = sr-izmerenia.sr-level
        abs-err-water-text          :visible = sr-izmerenia.sr-level
        relative-err-water-text     :visible = sr-izmerenia.sr-level
     .
end.
ON leave OF sr-izmerenia.sr-otnos IN FRAME Dialog-Frame
do:
  run check-sr-otnos no-error.
  if error-status:error
  then return no-apply .
end.
ON value-changed OF sr-izmerenia.sr-temperature IN FRAME Dialog-Frame
do:
  assign
     sr-izmerenia.sr-temperature
  .
  assign
        sr-izmerenia.sr-abs-err-temp-vol  :visible = sr-izmerenia.sr-temperature
        sr-izmerenia.sr-abs-err-temp-dens :visible = sr-izmerenia.sr-temperature
        abs-err-temp-vol-text  :visible = sr-izmerenia.sr-temperature
        abs-err-temp-dens-text :visible = sr-izmerenia.sr-temperature
     .
end.
ON value-changed OF sr-izmerenia.sr-type-id IN FRAME Dialog-Frame
do:
   run check-sr-type-id no-error.
   if error-status:error
   then return no-apply .
end.
ON value-changed OF sr-izmerenia.sr-type-izm IN FRAME Dialog-Frame
do:
   assign
       sr-izmerenia.sr-type-izm.
   if sr-izmerenia.sr-type-izm ne 2
   then do:
      sr-izmerenia.sr-Weight = no.
      sr-izmerenia.sr-Weight:checked = no.
      sr-izmerenia.sr-Weight:visible = no.
      RECT-4:visible = no.
   end.
   else do:
      sr-izmerenia.sr-Weight:visible = yes.
      RECT-4:visible = yes.
   end.
   apply "VALUE-CHANGED" to sr-izmerenia.sr-Weight.
end.
ON value-changed OF sr-izmerenia.sr-Weight IN FRAME Dialog-Frame
do:
  assign
     sr-izmerenia.sr-Weight
  .
  assign
        sr-izmerenia.sr-otnos                  :visible = sr-izmerenia.sr-Weight
        otnos-text                  :visible = sr-izmerenia.sr-Weight
          .
end.
if valid-handle(active-window) and frame Dialog-Frame:PARENT eq ?
then frame Dialog-Frame:PARENT = active-window.
MAIN-BLOCK:
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
   on end-key undo MAIN-BLOCK, leave MAIN-BLOCK:
   find first sr-izmerenia where sr-izmerenia.node-code eq inode-code no-error.
   if not avail sr-izmerenia
   then do:
      create sr-izmerenia.
      assign
         sr-izmerenia.sr-type-level-measuring = 0.
   end.
  display sr-izmerenia.sr-level with frame Dialog-Frame.
  run enable_UI.
  apply "VALUE-CHANGED" to sr-izmerenia.sr-type-izm .
  apply "VALUE-CHANGED" to sr-izmerenia.sr-level.
  apply "VALUE-CHANGED" to sr-izmerenia.sr-temperature.
  apply "VALUE-CHANGED" to sr-izmerenia.sr-density.
  apply "VALUE-CHANGED" to sr-izmerenia.sr-Weight.
  wait-for go of frame Dialog-Frame.
end.
run disable_UI.
PROCEDURE Check-err-dens :
   do with frame Dialog-Frame:
      assign
         sr-izmerenia.sr-density
         sr-izmerenia.sr-abs-err-dens
         sr-izmerenia.sr-relative-err-dens
         sr-izmerenia.sr-abs-err-dens-lgas-liquid
         sr-izmerenia.sr-abs-err-dens-lgas-vapor
         sr-izmerenia.sr-relative-err-dens-lgas-liquid
         .
      if sr-izmerenia.sr-density then do:
            if sr-izmerenia.sr-abs-err-dens = ? and sr-izmerenia.sr-relative-err-dens = ? then do:
               message
                  "Для сохранения должно быть заполнено хотя бы одно из полей:" skip
                   " " quoter("Абсолютная погрешность измерений плотности нефтепродукта") skip
                   " " quoter("Относительная погрешность измерений плотности нефтепродукта")
               view-as alert-box.
               return error.
            end.
            if (sr-izmerenia.sr-abs-err-dens      = 0.0 or sr-izmerenia.sr-abs-err-dens      = ?) and
               (sr-izmerenia.sr-relative-err-dens = 0.0 or sr-izmerenia.sr-relative-err-dens = ?) then do:
               message
                  "Для сохранения хотя бы одно из полей должно быть ненулевым:" skip
                   " " quoter("Абсолютная погрешность измерений плотности нефтепродукта") skip
                   " " quoter("Относительная погрешность измерений плотности нефтепродукта")
               view-as alert-box.
               return error.
            end.
            if sr-izmerenia.sr-abs-err-dens <> 0.0 and sr-izmerenia.sr-abs-err-dens <> ? and
               sr-izmerenia.sr-relative-err-dens = 0.0 then do:
               message
                   "Поле" skip
                   " " quoter("Относительная погрешность измерений плотности нефтепродукта")
                   "не должно быть нулевым"
               view-as alert-box.
               apply "entry" to sr-izmerenia.sr-relative-err-dens in frame Dialog-Frame .
               return error.
            end.
            if sr-izmerenia.sr-relative-err-dens <> 0.0 and sr-izmerenia.sr-relative-err-dens <> ? and
               sr-izmerenia.sr-abs-err-dens = 0.0 then do:
               message
                   "Поле" skip
                   " " quoter("Абсолютная погрешность измерений плотности нефтепродукта")
                   "не должно быть нулевым"
               view-as alert-box.
               apply "entry" to sr-izmerenia.sr-abs-err-dens in frame Dialog-Frame .
               return error.
            end.
            if (sr-izmerenia.sr-abs-err-dens-lgas-liquid = 0.0 or sr-izmerenia.sr-abs-err-dens-lgas-liquid = ?) and
               (sr-izmerenia.sr-relative-err-dens-lgas-liquid = 0.0 or sr-izmerenia.sr-relative-err-dens-lgas-liquid = ?) then do:
               message
                  "Для сохранения хотя бы одно из полей должно быть не нулевым:" skip
                   " " quoter("Абсолютная погрешность измерений плотности ЖФ") skip
                   " " quoter("Относительная погрешность измерений плотности ЖФ")
               view-as alert-box.
               apply "entry" to sr-izmerenia.sr-abs-err-dens-lgas-liquid in frame Dialog-Frame .
               return error.
            end.
      end.
   end.
end procedure.
PROCEDURE Check-err-Water :
   do with frame Dialog-Frame:
      assign
         sr-izmerenia.sr-level
         sr-izmerenia.sr-abs-err-water
         sr-izmerenia.sr-relative-err-water
         .
      if sr-izmerenia.sr-level   then do:
         if sr-izmerenia.sr-abs-err-water = ? then do:
            message
                "Поле" skip
                " " quoter("Абсолютная погрешность измерений уровня подтоварной воды")
                "должно быть заполнено"
            view-as alert-box.
            apply "entry" to sr-izmerenia.sr-abs-err-water in frame Dialog-Frame .
            return error.
         end.
      end.
   end.
end procedure.
PROCEDURE Check-neft-Water :
   do with frame Dialog-Frame:
      assign
         sr-izmerenia.sr-level
         sr-izmerenia.sr-type-id
         sr-izmerenia.sr-abs-err-neft-water
         sr-izmerenia.sr-relative-err-neft-water
         .
      if sr-izmerenia.sr-level then do:
         if sr-izmerenia.sr-abs-err-neft-water = ? and sr-izmerenia.sr-type-izm <> 3 then do:
            message
               "Поле" quoter("Абсолютная погрешность измерений уровня нефтепродукта и подтоварной воды")
               "должно быть заполнено"
            view-as alert-box.
            apply "entry" to sr-izmerenia.sr-abs-err-neft-water in frame Dialog-Frame .
            return error.
         end.
      end.
   end.
end procedure.
PROCEDURE Check-sr-abs-err-temp-dens :
   do with frame Dialog-Frame:
      assign
         sr-izmerenia.sr-abs-err-temp-dens
         sr-izmerenia.sr-temperature
         .
      if sr-izmerenia.sr-temperature and sr-izmerenia.sr-abs-err-temp-dens = 0.0
      then do:
         message
            "Поле"
            quoter(sr-izmerenia.sr-abs-err-temp-dens:label in frame Dialog-Frame)
            "должно быть заполнено ненулевым значением"
         view-as alert-box.
         apply "entry" to sr-izmerenia.sr-abs-err-temp-dens in frame Dialog-Frame .
         return error.
      end.
   end.
end procedure.
PROCEDURE Check-sr-abs-err-temp-vol :
   do with frame Dialog-Frame:
      assign
         sr-izmerenia.sr-abs-err-temp-vol
         sr-izmerenia.sr-temperature
         .
      if sr-izmerenia.sr-temperature and sr-izmerenia.sr-abs-err-temp-vol = 0.0
      then do:
         message
            "Поле"
            quoter(sr-izmerenia.sr-abs-err-temp-vol:label in frame Dialog-Frame)
            "должно быть заполнено ненулевым значением"
         view-as alert-box.
         apply "entry" to sr-izmerenia.sr-abs-err-temp-vol in frame Dialog-Frame .
         return error.
      end.
   end.
end procedure.
PROCEDURE Check-sr-otnos :
   do with frame Dialog-Frame:
      assign
          sr-izmerenia.sr-Weight
          sr-izmerenia.sr-otnos
       .
       if sr-izmerenia.sr-Weight then do:
          if sr-izmerenia.sr-otnos = ? then do:
              message
                 "Поле"
                 quoter(sr-izmerenia.sr-otnos:label in frame Dialog-Frame)
                 "обязательно для заполнения"
              view-as alert-box.
              apply "entry" to sr-izmerenia.sr-otnos in frame Dialog-Frame .
              return error.
          end.
          if sr-izmerenia.sr-otnos = 0.0 then do:
              message
                 "Поле"
                 quoter(sr-izmerenia.sr-otnos:label in frame Dialog-Frame)
                 "должно быть заполнено ненулевым значением"
              view-as alert-box.
              apply "entry" to sr-izmerenia.sr-otnos in frame Dialog-Frame .
              return error.
          end.
       end.
   end.
end procedure.
PROCEDURE Check-sr-temp-line :
   do with frame Dialog-Frame:
      assign
         sr-izmerenia.sr-temp-line
         sr-izmerenia.sr-level
         .
      if sr-izmerenia.sr-level then do:
         if sr-izmerenia.sr-temp-line = ? and sr-izmerenia.sr-type-izm <> 3 then do:
            message
               "Поле"
               quoter(sr-izmerenia.sr-temp-line:label in frame Dialog-Frame)
               "обязательно для заполнения"
            view-as alert-box.
            apply "entry" to sr-izmerenia.sr-temp-line in frame Dialog-Frame .
            return error.
         end.
         if sr-izmerenia.sr-temp-line = 0.0 then do:
            message
               "Поле"
               quoter(sr-izmerenia.sr-temp-line:label in frame Dialog-Frame)
               "не может быть нулевым"
            view-as alert-box.
            apply "entry" to sr-izmerenia.sr-temp-line in frame Dialog-Frame .
            return error.
         end.
      end.
   end.
end procedure.
PROCEDURE Check-sr-type-id :
 do with frame Dialog-Frame:
assign
     sr-izmerenia.sr-density
     sr-izmerenia.sr-type-id
  .
  if     sr-izmerenia.sr-density
     and (   sr-izmerenia.sr-type-id eq ?
          or sr-izmerenia.sr-type-id eq 0)
  then do:
     message sr-izmerenia.sr-type-id:label in frame Dialog-Frame " обязателен для заполнения"
     view-as alert-box.
     apply "entry" to sr-izmerenia.sr-type-id in frame Dialog-Frame .
     return error.
  end.  end.
end procedure.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH sr-izmerenia SHARE-LOCK.
  if available sr-izmerenia then
    display sr-izmerenia.node-code sr-izmerenia.sr-model sr-izmerenia.sr-type-izm
          sr-izmerenia.sr-level sr-izmerenia.sr-type-level-measuring
          sr-izmerenia.sr-temp-line sr-izmerenia.sr-abs-err-neft-water
          sr-izmerenia.sr-relative-err-neft-water sr-izmerenia.sr-abs-err-water
          sr-izmerenia.sr-relative-err-water sr-izmerenia.sr-temperature
          sr-izmerenia.sr-abs-err-temp-vol sr-izmerenia.sr-abs-err-temp-dens
          sr-izmerenia.sr-density sr-izmerenia.sr-type-id
          sr-izmerenia.sr-abs-err-dens sr-izmerenia.sr-relative-err-dens
          sr-izmerenia.sr-abs-err-dens-lgas-liquid
          sr-izmerenia.sr-abs-err-dens-lgas-vapor
          sr-izmerenia.sr-relative-err-dens-lgas-liquid sr-izmerenia.sr-Weight
          sr-izmerenia.sr-otnos sr-izmerenia.sr-not-used
          temp-line-text abs-err-neft-water-text relative-err-neft-water-text
          abs-err-water-text relative-err-water-text abs-err-temp-vol-text
          abs-err-temp-dens-text abs-err-dens-text relative-err-dens-text
          abs-err-dens-lgas-liquid-text abs-err-dens-lgas-vapor-text
          otnos-text relative-err-dens-lgas-liquid-t
      with frame Dialog-Frame.
  enable RECT-1 RECT-2 RECT-3 RECT-4  Btn_Cancel with frame Dialog-Frame.
  if iMode ne 'ПРОСМОТР':U
  then
  enable Btn_OK
         sr-izmerenia.sr-model
         sr-izmerenia.sr-type-izm sr-izmerenia.sr-level
         sr-izmerenia.sr-abs-err-neft-water
         sr-izmerenia.sr-relative-err-neft-water sr-izmerenia.sr-abs-err-water
         sr-izmerenia.sr-relative-err-water sr-izmerenia.sr-temperature
         sr-izmerenia.sr-abs-err-temp-vol sr-izmerenia.sr-abs-err-temp-dens
         sr-izmerenia.sr-density sr-izmerenia.sr-type-id
         sr-izmerenia.sr-abs-err-dens sr-izmerenia.sr-relative-err-dens
         sr-izmerenia.sr-abs-err-dens-lgas-liquid
         sr-izmerenia.sr-abs-err-dens-lgas-vapor
         sr-izmerenia.sr-relative-err-dens-lgas-liquid sr-izmerenia.sr-Weight
         sr-izmerenia.sr-otnos sr-izmerenia.sr-type-level-measuring
         sr-izmerenia.sr-temp-line sr-izmerenia.sr-not-used
         sr-izmerenia.sr-relative-err-dens-lgas-liquid
      with frame Dialog-Frame.
  view frame Dialog-Frame.
END PROCEDURE.
