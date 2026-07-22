&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
define shared temp-table tt-sug-struct no-undo
  field ii as integer
  field key_ as character
  field val_ as decimal format ">>>>9.<<<<"
  index pi 
    as primary unique
    ii
.
/* Parameters Definitions ---                                           */
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer no-undo .
define input  parameter p-pl-code as integer no-undo .
define input  parameter p-gds-code as integer no-undo .
define input  parameter p-rvs-code as character no-undo .
define input  parameter p-temp    as decimal no-undo .
define input  parameter p-press   as decimal no-undo .
define output parameter p-dens    as decimal no-undo .
define output parameter p-dens-pf as decimal no-undo .
define output parameter p-ok      as logical no-undo .
/* Local Variable Definitions ---                                       */
{ gbl/cur-time.i }
{ str/pokmi-dyn.i }

define stream outstream.

define variable error-string as character no-undo .
define variable enter-error as logical no-undo .

define buffer buf_place for ub.place .
define buffer buf_goods for ub.goods .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-cancel b-save f-dens15 f-atm-pressure ~
r-struct-type f-mmass-pseudo f-dens-pseudo cb-p_type
&Scoped-Define DISPLAYED-OBJECTS f-dens15 f-atm-pressure r-struct-type ~
f-mmass-pseudo f-dens-pseudo cb-p_type

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY 
     LABEL "Выход" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

DEFINE BUTTON b-save AUTO-GO 
     LABEL "Сохранить" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

DEFINE VARIABLE f-atm-pressure AS DECIMAL FORMAT ">>>>>9.999999":U INITIAL 0 
     LABEL "Атмосферное давление, МПа" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-dens-pseudo AS DECIMAL FORMAT ">>>>>9.9999":U INITIAL 0 
     LABEL "Плотность, кг/м3" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-dens15 AS DECIMAL FORMAT "9.9999":U INITIAL 0 
     LABEL "Плотность ЖФ при 15°C, г/см3" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-mmass-pseudo AS DECIMAL FORMAT ">>>>>9.9999":U INITIAL 0 
     LABEL "Молярная масса, кг/кмоль" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE r-struct-type AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Молярные доли", 1,
"Массовые доли", 2
     SIZE 43 BY .86 NO-UNDO.
     
define variable cb-p_type as integer init 0
   LABEL "Измеряемое давление" 
   VIEW-AS COMBO-BOX INNER-LINES 2
   LIST-ITEM-PAIRS "избыточное",0,
   "абсолютное",1
   DROP-DOWN-LIST
   SIZE 14 BY 1 NO-UNDO.

define query br-sug-struct for tt-sug-struct .
define browse br-sug-struct query br-sug-struct exclusive-lock
  display
    tt-sug-struct.ii           label "ID " format ">>9"
    tt-sug-struct.key_         label "Компонент" format "X(20)"
    tt-sug-struct.val_         label "Доля" width 15
  enable
    tt-sug-struct.val_
  with size 45 by 16 separators
.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-cancel AT ROW 1.24 COL 2
     b-save AT ROW 1.24 COL 17
     cb-p_type AT ROW 3 COL 33 COLON-ALIGNED WIDGET-ID 16
     f-dens15 AT ROW 4 COL 33 COLON-ALIGNED WIDGET-ID 2
     f-atm-pressure AT ROW 5 COL 33 COLON-ALIGNED WIDGET-ID 4
     r-struct-type AT ROW 6 COL 2 NO-LABEL WIDGET-ID 6
     br-sug-struct AT ROW 7 COL 2
     f-mmass-pseudo AT ROW 24 COL 29.2 COLON-ALIGNED WIDGET-ID 12
     f-dens-pseudo AT ROW 25 COL 29.2 COLON-ALIGNED WIDGET-ID 10
     "Псевдокомпонент:" VIEW-AS TEXT
          SIZE 23.4 BY .75 AT ROW 23.2 COL 8 WIDGET-ID 14
          FONT 6
     SPACE(1) SKIP(1)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Параметры для расчета плотности СУГ по РВД"
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-cancel WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры для расчета плотности СУГ по РВД */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

on choose of b-save in frame Dialog-Frame
do :
  define buffer buf_sug-struct for tt-sug-struct .
  define variable val-sum   as decimal no-undo .
  define variable v-msg     as character no-undo .
  define variable v-max-val as decimal no-undo .
  define variable v-mm55 as component-handle no-undo .
  define variable v-mm56 as component-handle no-undo .
  define variable mmM    as character no-undo .
  define variable v-sug-struct-val as character no-undo .
  define variable v-proc as character no-undo .
  
  define variable M as decimal extent 16 .
  
  define variable R as decimal no-undo .
  define variable CTL as decimal no-undo .
  define variable P_vapor as decimal no-undo .
  
  define variable vErr as character no-undo .
  define variable vWrn as character no-undo .
  define variable vDllVersion as character no-undo .
  
  assign
    r-struct-type
    f-dens15
    f-atm-pressure
    f-dens-pseudo
    f-mmass-pseudo
    cb-p_type
  .
  
  if f-dens15 = ?
  or f-dens15 = 0
  then do :
    message "Не указано значение для плотности ЖФ при 15°С. Сохранение невозможно." view-as alert-box .
    return no-apply .
  end .
  
  if f-dens15 < 0.5
  or f-dens15 > 0.8
  then do :
    message "Внесённое значение плотности ЖФ при 15°С выходит за рамки допустимого диапазона (0,500 - 0,800). Сохранение невозможно. Проверьте внесённое значение плотности ЖФ при 15°С." view-as alert-box .
    return no-apply .
  end .
  
  if f-atm-pressure = ?
  or f-atm-pressure = 0
  then do :
    message "Не указано значение для атмосферного давления. Сохранение невозможно." view-as alert-box .
    return no-apply .
  end .
  
  if r-struct-type = 1
  then
    v-max-val = 1
  .
  else
  if r-struct-type = 2
  then
    v-max-val = 100
  .
  
  for each buf_sug-struct no-lock :
    val-sum = val-sum + buf_sug-struct.val_ .
  end .
  if val-sum <> v-max-val
  then do :
    if r-struct-type = 1
    then
      v-msg = substitute('Сумма значений полей "Доля" должно быть равна 1. Текущее значение - &1. Проверьте введенные значения.', string(val-sum) )
    .
    else
    if r-struct-type = 2
    then
      v-msg = substitute('Сумма значений полей "Доля" должно быть равна 100. Текущее значение - &1. Проверьте введенные значения.', string(val-sum) )
    .
    message v-msg view-as alert-box .
    return no-apply .
  end .
  
  for first buf_sug-struct no-lock where buf_sug-struct.ii = 15 :
    if buf_sug-struct.val_ > 0
    then do :
      if f-dens-pseudo = ?
      or f-dens-pseudo = 0
      then do :
        message "Не указано значение для плотности псевдокомпонента. Сохранение невозможно." view-as alert-box .
        return no-apply .
      end .
      if f-mmass-pseudo = ?
      or f-mmass-pseudo = 0
      then do :
        message "Не указано значение для малярной массы псевдокомпонента. Сохранение невозможно." view-as alert-box .
        return no-apply .
      end .
    end .
  end .
  
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = p-obj-code
         and rvs-line-attr.obj-type  = p-obj-type
         and rvs-line-attr.gds-code  = p-gds-code
         and rvs-line-attr.pl-code   = p-pl-code
         and rvs-line-attr.rvs-code  = p-rvs-code
         and rvs-line-attr.attr-code = "atm-pressure" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = p-obj-code
      rvs-line-attr.obj-type  = p-obj-type
      rvs-line-attr.gds-code  = p-gds-code
      rvs-line-attr.pl-code   = p-pl-code
      rvs-line-attr.rvs-code  = p-rvs-code
      rvs-line-attr.attr-code = "atm-pressure"
    .
  end.
  rvs-line-attr.attr-value = string(f-atm-pressure, ">>>>>9.99999") .
  
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = p-obj-code
         and rvs-line-attr.obj-type  = p-obj-type
         and rvs-line-attr.gds-code  = p-gds-code
         and rvs-line-attr.pl-code   = p-pl-code
         and rvs-line-attr.rvs-code  = p-rvs-code
         and rvs-line-attr.attr-code = "dens-pseudo" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = p-obj-code
      rvs-line-attr.obj-type  = p-obj-type
      rvs-line-attr.gds-code  = p-gds-code
      rvs-line-attr.pl-code   = p-pl-code
      rvs-line-attr.rvs-code  = p-rvs-code
      rvs-line-attr.attr-code = "dens-pseudo"
    .
  end.
  rvs-line-attr.attr-value = string(f-dens-pseudo, ">>>>>9.9999") .
  
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = p-obj-code
         and rvs-line-attr.obj-type  = p-obj-type
         and rvs-line-attr.gds-code  = p-gds-code
         and rvs-line-attr.pl-code   = p-pl-code
         and rvs-line-attr.rvs-code  = p-rvs-code
         and rvs-line-attr.attr-code = "dens15" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = p-obj-code
      rvs-line-attr.obj-type  = p-obj-type
      rvs-line-attr.gds-code  = p-gds-code
      rvs-line-attr.pl-code   = p-pl-code
      rvs-line-attr.rvs-code  = p-rvs-code
      rvs-line-attr.attr-code = "dens15"
    .
  end.
  rvs-line-attr.attr-value = string(f-dens15, "9.9999") .
  
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = p-obj-code
         and rvs-line-attr.obj-type  = p-obj-type
         and rvs-line-attr.gds-code  = p-gds-code
         and rvs-line-attr.pl-code   = p-pl-code
         and rvs-line-attr.rvs-code  = p-rvs-code
         and rvs-line-attr.attr-code = "mmass-pseudo" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = p-obj-code
      rvs-line-attr.obj-type  = p-obj-type
      rvs-line-attr.gds-code  = p-gds-code
      rvs-line-attr.pl-code   = p-pl-code
      rvs-line-attr.rvs-code  = p-rvs-code
      rvs-line-attr.attr-code = "mmass-pseudo"
    .
  end.
  rvs-line-attr.attr-value = string(f-mmass-pseudo, ">>>>>9.9999") .
  
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = p-obj-code
         and rvs-line-attr.obj-type  = p-obj-type
         and rvs-line-attr.gds-code  = p-gds-code
         and rvs-line-attr.pl-code   = p-pl-code
         and rvs-line-attr.rvs-code  = p-rvs-code
         and rvs-line-attr.attr-code = "struct-type" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = p-obj-code
      rvs-line-attr.obj-type  = p-obj-type
      rvs-line-attr.gds-code  = p-gds-code
      rvs-line-attr.pl-code   = p-pl-code
      rvs-line-attr.rvs-code  = p-rvs-code
      rvs-line-attr.attr-code = "struct-type"
    .
  end.
  rvs-line-attr.attr-value = string(r-struct-type) .
  
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = p-obj-code
         and rvs-line-attr.obj-type  = p-obj-type
         and rvs-line-attr.gds-code  = p-gds-code
         and rvs-line-attr.pl-code   = p-pl-code
         and rvs-line-attr.rvs-code  = p-rvs-code
         and rvs-line-attr.attr-code = "p_type" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = p-obj-code
      rvs-line-attr.obj-type  = p-obj-type
      rvs-line-attr.gds-code  = p-gds-code
      rvs-line-attr.pl-code   = p-pl-code
      rvs-line-attr.rvs-code  = p-rvs-code
      rvs-line-attr.attr-code = "p_type"
    .
  end.
  rvs-line-attr.attr-value = string(cb-p_type) .
  
  v-sug-struct-val = "" .                              
  for each tt-sug-struct no-lock by tt-sug-struct.ii :
    v-sug-struct-val = v-sug-struct-val + string(tt-sug-struct.val, ">>9.9999") + "," . 
  end .       
  v-sug-struct-val = trim(v-sug-struct-val, ",") .                     
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = p-obj-code
         and rvs-line-attr.obj-type  = p-obj-type
         and rvs-line-attr.gds-code  = p-gds-code
         and rvs-line-attr.pl-code   = p-pl-code
         and rvs-line-attr.rvs-code  = p-rvs-code
         and rvs-line-attr.attr-code = "sug-struct" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = p-obj-code
      rvs-line-attr.obj-type  = p-obj-type
      rvs-line-attr.gds-code  = p-gds-code
      rvs-line-attr.pl-code   = p-pl-code
      rvs-line-attr.rvs-code  = p-rvs-code
      rvs-line-attr.attr-code = "sug-struct"
      rvs-line-attr.attr-value = v-sug-struct-val
    .
  end.
  else do :
    rvs-line-attr.attr-value = v-sug-struct-val .
  end.
  
  release rvs-line-attr no-error .
  
  v-proc = "CMethodOfMetering55" .
  
  MM55
    (
    input f-dens15 * 1000,
    input p-temp,
    input 2, /* Round_R */
    input 2, /* Round_T */
    
    output R,
    output CTL,
    
    output vErr,
    output vWrn,
    output vDllVersion
    )
  .

  OUTPUT stream outstream to value ("pomi.log") append.
  PUT STREAM outstream unformatted
      "    " SKIP
      "    " SKIP
      cur-time-string()           FORMAT "x(16)"    SKIP
      'Процедура             '    v-proc   SKIP
      'CODE_PL                = ' p-pl-code                           SKIP
      'R15                    = ' f-dens15 * 1000                 SKIP
      'T                      = ' p-temp                                  SKIP
      'Round_R                = ' 2                                   SKIP
      'Round_T                = ' 2                                   SKIP
          SKIP SKIP 
  .
  output stream outstream close.
  
  if trim(vErr) > "" then do :
    error-string = vErr .
    output stream outstream to value ("pomi.log")  append.
    put stream outstream error-string format "X(1024)" skip.
    output stream outstream close.
    message substitute('Ошибка работы библиотеки ПОкМИ &1',error-string) view-as alert-box .
    return .
  end.
  else do :
    p-dens = round(R / 1000, 4) .
    OUTPUT stream outstream to value ("pomi.log")  append.
    PUT STREAM outstream unformatted
        "R   = " R  SKIP
        "CTL = " CTL  SKIP
        "Warnings = " vWrn SKIP
        'Версия dll: '   vDllVersion  SKIP
    .
    OUTPUT stream outstream close.
  end .
  
  if p-dens = ?
  or p-dens <= 0
  then do :
    message substitute( "Ошибка расчета. Метод 55 ПОкМИ вернул отрицательное значение (&1) плотности ЖФ при рабочих условиях!", trim(string(p-dens, "->>>>>>9.99<<<<<"))) view-as alert-box .
    return .
  end .
  
  
  v-proc = "CMethodOfMetering56" .
  
  for each buf_sug-struct no-lock by buf_sug-struct.ii :
    M[buf_sug-struct.ii + 1] = buf_sug-struct.val_ .
    mmM = mmM + ";" + string(buf_sug-struct.val_, ">>>>9.99<<") .
  end . 
  mmM = trim(mmM, ";") .
  
  MM56
    (
    input if r-struct-type = 1 then 0 else 1,
    input M,
    input p-temp, /* T */
    input cb-p_type, /* P_type 0 - избыточное, 1 - абсолютное */
    input p-press, /* P_extra */
    input f-atm-pressure, /* P_atmosphere */
    input f-mmass-pseudo, /* M_pseudo */
    input f-dens-pseudo, /* R_pseudo */
    input 2, /* Round_T */
    input 2, /* Round_R */
    
    output R,
    output P_vapor,
    
    output vErr,
    output vWrn,
    output vDllVersion
    )
  .
  
  OUTPUT stream outstream to value ("pomi.log") append.
  PUT STREAM outstream unformatted
              "    " SKIP
              "    " SKIP
              cur-time-string()           FORMAT "x(16)"    SKIP
              'Процедура             '    v-proc   SKIP
              'CODE_PL                = ' p-pl-code                           SKIP
              'M_type                 = ' if r-struct-type = 1 then 0 else 1                  SKIP
              'M                      = ' mmM                  SKIP
              'T                      = ' p-temp                       SKIP
              'P_type                 = ' cb-p_type                       SKIP
              'P_extra                = ' p-press                       SKIP
              'P_atmosphere           = ' f-atm-pressure                       SKIP
              'M_pseudo               = ' f-mmass-pseudo                      SKIP
              'R_pseudo               = ' f-dens-pseudo                      SKIP
              'Round_T                = ' 2                                   SKIP
              'Round_R                = ' 2                                   SKIP
                  SKIP SKIP 
  .
  output stream outstream close.
  
  if trim(vErr) > "" then do :
    error-string = vErr .
    output stream outstream to value ("pomi.log")  append.
    put stream outstream error-string format "X(1024)" skip.
    output stream outstream close.
    message substitute('Ошибка работы библиотеки ПОкМИ &1',error-string) view-as alert-box .
    return .
  end.
  else do :
    p-dens-pf = round(R / 1000, 4) .
    OUTPUT stream outstream to value ("pomi.log")  append.
    PUT STREAM outstream unformatted
        "R   = " R  SKIP
        "P_Vapor = " P_Vapor  SKIP
        "Warnings = " vWrn SKIP
        'Версия dll: '              vDllVersion  SKIP
    .
    OUTPUT stream outstream close.
    if p-dens-pf < 0
    then do :
      find first buf_place no-lock where buf_place.obj-type = p-obj-type
                                     and buf_place.obj-code = p-obj-code
                                     and buf_place.pl-code = p-pl-code
                                     no-error .
      find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
      if available buf_place
      and available buf_goods
      then do :
        message
          "Ошибка при заполнении данных!" skip
          "Для резервуара " string(buf_place.pl-code) " (" buf_place.loc1 "  " buf_goods.gds-name ") не определено значение плотности ПГФ. Сохранение результатов расчёта невозможно." skip
          "Проверьте внесённый компонентный состав СУГ."
        view-as alert-box .
        return .
      end .
      else do :
        message "Ошибка при заполнении данных! Проверьте внесённый компонентный состав СУГ." view-as alert-box .
        return .
      end .                               
    end .
  end .
  
  p-ok = true .
end .

on value-changed of cb-p_type in frame dialog-frame 
do:
  assign cb-p_type .
  if cb-p_type = 0
  then do :
    assign f-atm-pressure = 0.101325 .
    display f-atm-pressure with frame dialog-frame .
    disable f-atm-pressure with frame dialog-frame .
  end .
  else do :
    assign f-atm-pressure = 0.0 .
    display f-atm-pressure with frame dialog-frame .
    enable f-atm-pressure with frame dialog-frame .
  end .
end .

on value-changed of r-struct-type in frame dialog-frame 
do:
  define variable vOk as logical no-undo .
  define variable v-old-val as integer no-undo .
  define buffer buf_tt-sug-struct for tt-sug-struct .
  
  v-old-val = r-struct-type .
  
  if enter-error
  then do :
    r-struct-type:screen-value in frame dialog-frame = string(v-old-val) .
    display r-struct-type with frame dialog-frame .
    enter-error = false .
    return .
  end .
  for first buf_tt-sug-struct no-lock where buf_tt-sug-struct.val_ > 0 :
    message "Изменения типа приведет к сбросу введенных данных." skip "Продолжить?"
    view-as alert-box question buttons yes-no update vOk .
    if not vOk
    then do :
      r-struct-type:screen-value in frame dialog-frame = string(v-old-val) .
      display r-struct-type with frame dialog-frame .
      return no-apply .
    end .
  end .
  
  assign r-struct-type.
  for each tt-sug-struct :
    tt-sug-struct.val_ = 0.0 .
  end .
  
  br-sug-struct:refresh() .
  if r-struct-type = 1
  then do :
    br-sug-struct:SELECT-ROW (1).
    do while available tt-sug-struct :
      tt-sug-struct.val_:format in browse br-sug-struct = "9.9999" .
      if tt-sug-struct.ii = 15 then leave .
      br-sug-struct:SELECT-NEXT-ROW ( ).
    end .
  end .
  else
  if r-struct-type = 2
  then do :
    br-sug-struct:SELECT-ROW (1).
    do while available tt-sug-struct :
      tt-sug-struct.val_:format in browse br-sug-struct = ">>9.99" .
      if tt-sug-struct.ii = 15 then leave .
      br-sug-struct:SELECT-NEXT-ROW ( ).
    end .
  end .
  
end.

on return of tt-sug-struct.val_ in browse br-sug-struct
do :
  apply "leave" to self .
end .

on leave of tt-sug-struct.val_ in browse br-sug-struct
do :
  define buffer buf_sug-struct for tt-sug-struct .
  define variable val-sum   as decimal no-undo .
  define variable v-msg     as character no-undo .
  define variable v-max-val as decimal no-undo .

  enter-error = false .

  if r-struct-type = 1
  then
    v-max-val = 1
  .
  else
  if r-struct-type = 2
  then
    v-max-val = 100
  .
  if decimal(tt-sug-struct.val_:screen-value in browse br-sug-struct) > v-max-val
  then do :
    enter-error = true .
    message "Неверное значение!" view-as alert-box .
    tt-sug-struct.val_ = 0 .
    display tt-sug-struct.val_ with browse br-sug-struct .
    return .
  end .
  
  for each buf_sug-struct no-lock where buf_sug-struct.ii <> tt-sug-struct.ii :
    val-sum = val-sum + buf_sug-struct.val_ .
  end .
  val-sum = val-sum + decimal(tt-sug-struct.val_:screen-value in browse br-sug-struct) .
  if val-sum > v-max-val
  then do :
    if r-struct-type = 1
    then
      v-msg = substitute('Сумма значений полей "молярная доля" не должно превышать 1. Текущее значение - &1. Исправьте введенное значение.', string(val-sum) )
    .
    else
    if r-struct-type = 2
    then
      v-msg = substitute('Сумма значений полей "массовая доля" не должно превышать 100%. Текущее значение - &1. Исправьте введенное значение.', string(val-sum) )
    .
    message v-msg view-as alert-box .
    return no-apply .
  end .
  
end .

&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  p-ok = false .
  for first rvs-line-attr no-lock
       where rvs-line-attr.obj-code  = p-obj-code
         and rvs-line-attr.obj-type  = p-obj-type
         and rvs-line-attr.gds-code  = p-gds-code
         and rvs-line-attr.pl-code   = p-pl-code
         and rvs-line-attr.rvs-code  = p-rvs-code
         and rvs-line-attr.attr-code = "atm-pressure"
         :
    f-atm-pressure = decimal(rvs-line-attr.attr-value) .     
  end .
  for first rvs-line-attr no-lock
       where rvs-line-attr.obj-code  = p-obj-code
         and rvs-line-attr.obj-type  = p-obj-type
         and rvs-line-attr.gds-code  = p-gds-code
         and rvs-line-attr.pl-code   = p-pl-code
         and rvs-line-attr.rvs-code  = p-rvs-code
         and rvs-line-attr.attr-code = "dens-pseudo"
         :
    f-dens-pseudo = decimal(rvs-line-attr.attr-value) .     
  end .
  for first rvs-line-attr no-lock
       where rvs-line-attr.obj-code  = p-obj-code
         and rvs-line-attr.obj-type  = p-obj-type
         and rvs-line-attr.gds-code  = p-gds-code
         and rvs-line-attr.pl-code   = p-pl-code
         and rvs-line-attr.rvs-code  = p-rvs-code
         and rvs-line-attr.attr-code = "dens15"
         :
    f-dens15 = decimal(rvs-line-attr.attr-value) .     
  end .
  for first rvs-line-attr no-lock
       where rvs-line-attr.obj-code  = p-obj-code
         and rvs-line-attr.obj-type  = p-obj-type
         and rvs-line-attr.gds-code  = p-gds-code
         and rvs-line-attr.pl-code   = p-pl-code
         and rvs-line-attr.rvs-code  = p-rvs-code
         and rvs-line-attr.attr-code = "mmass-pseudo"
         :
    f-mmass-pseudo = decimal(rvs-line-attr.attr-value) .     
  end .
  for first rvs-line-attr no-lock
       where rvs-line-attr.obj-code  = p-obj-code
         and rvs-line-attr.obj-type  = p-obj-type
         and rvs-line-attr.gds-code  = p-gds-code
         and rvs-line-attr.pl-code   = p-pl-code
         and rvs-line-attr.rvs-code  = p-rvs-code
         and rvs-line-attr.attr-code = "struct-type"
         :
    r-struct-type = integer(rvs-line-attr.attr-value) .     
  end .
  for first rvs-line-attr no-lock
       where rvs-line-attr.obj-code  = p-obj-code
         and rvs-line-attr.obj-type  = p-obj-type
         and rvs-line-attr.gds-code  = p-gds-code
         and rvs-line-attr.pl-code   = p-pl-code
         and rvs-line-attr.rvs-code  = p-rvs-code
         and rvs-line-attr.attr-code = "p_type"
         :
    cb-p_type = integer(rvs-line-attr.attr-value) .     
  end .
  
  run fill-tt .
  RUN enable_UI.
  if cb-p_type = 0
  then do :
    assign f-atm-pressure = 0.101325 .
    display f-atm-pressure with frame dialog-frame .
    disable f-atm-pressure with frame dialog-frame .
  end .
  
  assign r-struct-type .
  if r-struct-type = 1
  then do :
    br-sug-struct:SELECT-ROW (1).
    do while available tt-sug-struct :
      tt-sug-struct.val_:format in browse br-sug-struct = "9.9999" .
      if tt-sug-struct.ii = 15 then leave .
      br-sug-struct:SELECT-NEXT-ROW ( ).
    end .
  end .
  else
  if r-struct-type = 2
  then do :
    br-sug-struct:SELECT-ROW (1).
    do while available tt-sug-struct :
      tt-sug-struct.val_:format in browse br-sug-struct = ">>9.99" .
      if tt-sug-struct.ii = 15 then leave .
      br-sug-struct:SELECT-NEXT-ROW ( ).
    end .
  end .
  get first br-sug-struct .
  
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

procedure fill-tt :
  find first tt-sug-struct no-error .
  if available tt-sug-struct
  then return .
  
  create tt-sug-struct .
  assign
    tt-sug-struct.ii      = 0
    tt-sug-struct.key_    = "метан"
  .
  create tt-sug-struct .
  assign
    tt-sug-struct.ii      = 1
    tt-sug-struct.key_    = "этан"
  .
  create tt-sug-struct .
  assign
    tt-sug-struct.ii      = 2
    tt-sug-struct.key_    = "пропан"
  .
  create tt-sug-struct .
  assign
    tt-sug-struct.ii      = 3
    tt-sug-struct.key_    = "н-бутан"
  .
  create tt-sug-struct .
  assign
    tt-sug-struct.ii      = 4
    tt-sug-struct.key_    = "и-бутан"
  .
  create tt-sug-struct .
  assign
    tt-sug-struct.ii      = 5
    tt-sug-struct.key_    = "н-пентан"
  .
  create tt-sug-struct .
  assign
    tt-sug-struct.ii      = 6
    tt-sug-struct.key_    = "и-пентан"
  .
  create tt-sug-struct .
  assign
    tt-sug-struct.ii      = 7
    tt-sug-struct.key_    = "н-гексан"
  .
  create tt-sug-struct .
  assign
    tt-sug-struct.ii      = 8
    tt-sug-struct.key_    = "н-гептан"
  .
  create tt-sug-struct .
  assign
    tt-sug-struct.ii      = 9
    tt-sug-struct.key_    = "н-октан"
  .
  create tt-sug-struct .
  assign
    tt-sug-struct.ii      = 10
    tt-sug-struct.key_    = "н-нонан"
  .
  create tt-sug-struct .
  assign
    tt-sug-struct.ii      = 11
    tt-sug-struct.key_    = "н-декан"
  .
  create tt-sug-struct .
  assign
    tt-sug-struct.ii      = 12
    tt-sug-struct.key_    = "азот"
  .
  create tt-sug-struct .
  assign
    tt-sug-struct.ii      = 13
    tt-sug-struct.key_    = "диоксид углерода"
  .
  create tt-sug-struct .
  assign
    tt-sug-struct.ii      = 14
    tt-sug-struct.key_    = "Сероводород"
  .
  create tt-sug-struct .
  assign
    tt-sug-struct.ii      = 15
    tt-sug-struct.key_    = "Псевдокомпонент"
  .
  
end procedure .

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other 
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY f-dens15 f-atm-pressure r-struct-type f-mmass-pseudo f-dens-pseudo cb-p_type
      WITH FRAME Dialog-Frame.
  ENABLE b-cancel b-save f-dens15 f-atm-pressure r-struct-type f-mmass-pseudo cb-p_type
         f-dens-pseudo br-sug-struct
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  open query br-sug-struct for each tt-sug-struct .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

