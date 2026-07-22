define shared temp-table tt-sug-struct no-undo
  field ii as integer
  field key_ as character
  field val_ as decimal format ">>>>9.<<<<"
  index pi
    as primary unique
    ii
.
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
function MM6 returns logical
  (
  input H as decimal,
  input H_water as decimal,
  input CalibrationTable as character,
  input CalibrationBelt as character,
  input P0 as decimal,
  input Tv as decimal,
  input Tr as decimal,
  input R as decimal,
  input Tcy as decimal,
  input ToolType as integer,
  input DeltaOtn_K as decimal,
  input DeadZone_Reservoir as decimal,
  input A_Reservoir as decimal,
  input A_LevelMeasurementTool as decimal,
  input ToolAutomationLevel_H as integer,
  input ToolAutomationLevel_H_Water as integer,
  input ToolAutomationLevel_R as integer,
  input ToolAutomationLevel_Tv as integer,
  input ToolAutomationLevel_Tr as integer,
  input DeltaAbs_H_CalcType as integer,
  input DeltaAbs_H_Water_CalcType as integer,
  input DeltaAbs_H as decimal,
  input DeltaAbs_H_Water as decimal,
  input DeltaAbs_R as decimal,
  input DeltaAbs_Tv as decimal,
  input DeltaAbs_Tr as decimal,
  input DeltaOtn_N as decimal,
  input Round_M as integer,
  input Round_T as integer,
  input Round_R as integer,
  output V_total as decimal,
  output V_water as decimal,
  output DeltaV as decimal,
  output V_product as decimal,
  output Vcy as decimal,
  output Rcy as decimal,
  output V as decimal,
  output CTL_base_alt as decimal,
  output CPL_base_alt as decimal,
  output CTPL_base_alt as decimal,
  output Fp_base_alt as decimal,
  output CTL_obs_base as decimal,
  output CPL_obs_base as decimal,
  output CTPL_obs_base as decimal,
  output Fp_obs_base as decimal,
  output Rv as decimal,
  output DeltaOtn_Vcy as decimal,
  output DeltaOtn_Vm as decimal,
  output M as decimal,
  output DeltaOtn_M as decimal,
  output VolumetricExpansion as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt6"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 56
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", H).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", H_water).
  hCall:SET-PARAMETER(6, "CHARACTER", "INPUT", CalibrationTable).
  hCall:SET-PARAMETER(7, "CHARACTER", "INPUT", CalibrationBelt).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", P0).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", Tv).
  hCall:SET-PARAMETER(10, "DOUBLE", "INPUT", Tr).
  hCall:SET-PARAMETER(11, "DOUBLE", "INPUT", R).
  hCall:SET-PARAMETER(12, "DOUBLE", "INPUT", Tcy).
  hCall:SET-PARAMETER(13, "LONG", "INPUT", ToolType).
  hCall:SET-PARAMETER(14, "DOUBLE", "INPUT", DeltaOtn_K).
  hCall:SET-PARAMETER(15, "DOUBLE", "INPUT", DeadZone_Reservoir).
  hCall:SET-PARAMETER(16, "DOUBLE", "INPUT", A_Reservoir).
  hCall:SET-PARAMETER(17, "DOUBLE", "INPUT", A_LevelMeasurementTool).
  hCall:SET-PARAMETER(18, "LONG", "INPUT", ToolAutomationLevel_H).
  hCall:SET-PARAMETER(19, "LONG", "INPUT", ToolAutomationLevel_H_Water).
  hCall:SET-PARAMETER(20, "LONG", "INPUT", ToolAutomationLevel_R).
  hCall:SET-PARAMETER(21, "LONG", "INPUT", ToolAutomationLevel_Tv).
  hCall:SET-PARAMETER(22, "LONG", "INPUT", ToolAutomationLevel_Tr).
  hCall:SET-PARAMETER(23, "LONG", "INPUT", DeltaAbs_H_CalcType).
  hCall:SET-PARAMETER(24, "LONG", "INPUT", DeltaAbs_H_Water_CalcType).
  hCall:SET-PARAMETER(25, "DOUBLE", "INPUT", DeltaAbs_H).
  hCall:SET-PARAMETER(26, "DOUBLE", "INPUT", DeltaAbs_H_Water).
  hCall:SET-PARAMETER(27, "DOUBLE", "INPUT", DeltaAbs_R).
  hCall:SET-PARAMETER(28, "DOUBLE", "INPUT", DeltaAbs_Tv).
  hCall:SET-PARAMETER(29, "DOUBLE", "INPUT", DeltaAbs_Tr).
  hCall:SET-PARAMETER(30, "DOUBLE", "INPUT", DeltaOtn_N).
  hCall:SET-PARAMETER(31, "LONG", "INPUT", Round_M).
  hCall:SET-PARAMETER(32, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(33, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(34, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(35, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(36, "DOUBLE", "OUTPUT", V_total).
  hCall:SET-PARAMETER(37, "DOUBLE", "OUTPUT", V_water).
  hCall:SET-PARAMETER(38, "DOUBLE", "OUTPUT", DeltaV).
  hCall:SET-PARAMETER(39, "DOUBLE", "OUTPUT", V_product).
  hCall:SET-PARAMETER(40, "DOUBLE", "OUTPUT", Vcy).
  hCall:SET-PARAMETER(41, "DOUBLE", "OUTPUT", Rcy).
  hCall:SET-PARAMETER(42, "DOUBLE", "OUTPUT", V).
  hCall:SET-PARAMETER(43, "DOUBLE", "OUTPUT", CTL_base_alt).
  hCall:SET-PARAMETER(44, "DOUBLE", "OUTPUT", CPL_base_alt).
  hCall:SET-PARAMETER(45, "DOUBLE", "OUTPUT", CTPL_base_alt).
  hCall:SET-PARAMETER(46, "DOUBLE", "OUTPUT", Fp_base_alt).
  hCall:SET-PARAMETER(47, "DOUBLE", "OUTPUT", CTL_obs_base).
  hCall:SET-PARAMETER(48, "DOUBLE", "OUTPUT", CPL_obs_base).
  hCall:SET-PARAMETER(49, "DOUBLE", "OUTPUT", CTPL_obs_base).
  hCall:SET-PARAMETER(50, "DOUBLE", "OUTPUT", Fp_obs_base).
  hCall:SET-PARAMETER(51, "DOUBLE", "OUTPUT", Rv).
  hCall:SET-PARAMETER(52, "DOUBLE", "OUTPUT", DeltaOtn_Vcy).
  hCall:SET-PARAMETER(53, "DOUBLE", "OUTPUT", DeltaOtn_Vm).
  hCall:SET-PARAMETER(54, "DOUBLE", "OUTPUT", M).
  hCall:SET-PARAMETER(55, "DOUBLE", "OUTPUT", DeltaOtn_M).
  hCall:SET-PARAMETER(56, "DOUBLE", "OUTPUT", VolumetricExpansion).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM7 returns logical
  (
  input M1 as decimal,
  input M2 as decimal,
  input H1 as decimal,
  input H2 as decimal,
  input H1_water as decimal,
  input H2_water as decimal,
  input CalibrationTable as character,
  input CalibrationBelt as character,
  input Tv1 as decimal,
  input Tv2 as decimal,
  input Tr1 as decimal,
  input Tr2 as decimal,
  input R1 as decimal,
  input R2 as decimal,
  input ToolType1 as integer,
  input ToolType2 as integer,
  input DeltaOtn_K as decimal,
  input OperDirection as integer,
  input ToolAutomationLevel_H1 as integer,
  input ToolAutomationLevel_H2 as integer,
  input ToolAutomationLevel_H_Water1 as integer,
  input ToolAutomationLevel_H_Water2 as integer,
  input ToolAutomationLevel_R1 as integer,
  input ToolAutomationLevel_R2 as integer,
  input ToolAutomationLevel_Tv1 as integer,
  input ToolAutomationLevel_Tv2 as integer,
  input ToolAutomationLevel_Tr1 as integer,
  input ToolAutomationLevel_Tr2 as integer,
  input DeltaAbs_H_CalcType1 as integer,
  input DeltaAbs_H_CalcType2 as integer,
  input DeltaAbs_H_Water_CalcType1 as integer,
  input DeltaAbs_H_Water_CalcType2 as integer,
  input DeltaAbs_H1 as decimal,
  input DeltaAbs_H2 as decimal,
  input DeltaAbs_H_Water1 as decimal,
  input DeltaAbs_H_Water2 as decimal,
  input DeltaAbs_R1 as decimal,
  input DeltaAbs_R2 as decimal,
  input DeltaAbs_Tv1 as decimal,
  input DeltaAbs_Tv2 as decimal,
  input DeltaAbs_Tr1 as decimal,
  input DeltaAbs_Tr2 as decimal,
  input DeltaOtn_N as decimal,
  input Round_M as integer,
  input Round_T as integer,
  input Round_R as integer,
  output V_total1 as decimal,
  output V_total2 as decimal,
  output V_water1 as decimal,
  output V_water2 as decimal,
  output Delta_V1 as decimal,
  output Delta_V2 as decimal,
  output M as decimal,
  output DeltaOtn_M as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt7"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 59
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", M1).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", M2).
  hCall:SET-PARAMETER(6, "DOUBLE", "INPUT", H1).
  hCall:SET-PARAMETER(7, "DOUBLE", "INPUT", H2).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", H1_water).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", H2_water).
  hCall:SET-PARAMETER(10, "CHARACTER", "INPUT", CalibrationTable).
  hCall:SET-PARAMETER(11, "CHARACTER", "INPUT", CalibrationBelt).
  hCall:SET-PARAMETER(12, "DOUBLE", "INPUT", Tv1).
  hCall:SET-PARAMETER(13, "DOUBLE", "INPUT", Tv2).
  hCall:SET-PARAMETER(14, "DOUBLE", "INPUT", Tr1).
  hCall:SET-PARAMETER(15, "DOUBLE", "INPUT", Tr2).
  hCall:SET-PARAMETER(16, "DOUBLE", "INPUT", R1).
  hCall:SET-PARAMETER(17, "DOUBLE", "INPUT", R2).
  hCall:SET-PARAMETER(18, "LONG", "INPUT", ToolType1).
  hCall:SET-PARAMETER(19, "LONG", "INPUT", ToolType2).
  hCall:SET-PARAMETER(20, "DOUBLE", "INPUT", DeltaOtn_K).
  hCall:SET-PARAMETER(21, "LONG", "INPUT", OperDirection).
  hCall:SET-PARAMETER(22, "LONG", "INPUT", ToolAutomationLevel_H1).
  hCall:SET-PARAMETER(23, "LONG", "INPUT", ToolAutomationLevel_H2).
  hCall:SET-PARAMETER(24, "LONG", "INPUT", ToolAutomationLevel_H_Water1).
  hCall:SET-PARAMETER(25, "LONG", "INPUT", ToolAutomationLevel_H_Water2).
  hCall:SET-PARAMETER(26, "LONG", "INPUT", ToolAutomationLevel_R1).
  hCall:SET-PARAMETER(27, "LONG", "INPUT", ToolAutomationLevel_R2).
  hCall:SET-PARAMETER(28, "LONG", "INPUT", ToolAutomationLevel_Tv1).
  hCall:SET-PARAMETER(29, "LONG", "INPUT", ToolAutomationLevel_Tv2).
  hCall:SET-PARAMETER(30, "LONG", "INPUT", ToolAutomationLevel_Tr1).
  hCall:SET-PARAMETER(31, "LONG", "INPUT", ToolAutomationLevel_Tr2).
  hCall:SET-PARAMETER(32, "LONG", "INPUT", DeltaAbs_H_CalcType1).
  hCall:SET-PARAMETER(33, "LONG", "INPUT", DeltaAbs_H_CalcType2).
  hCall:SET-PARAMETER(34, "LONG", "INPUT", DeltaAbs_H_Water_CalcType1).
  hCall:SET-PARAMETER(35, "LONG", "INPUT", DeltaAbs_H_Water_CalcType2).
  hCall:SET-PARAMETER(36, "DOUBLE", "INPUT", DeltaAbs_H1).
  hCall:SET-PARAMETER(37, "DOUBLE", "INPUT", DeltaAbs_H2).
  hCall:SET-PARAMETER(38, "DOUBLE", "INPUT", DeltaAbs_H_Water1).
  hCall:SET-PARAMETER(39, "DOUBLE", "INPUT", DeltaAbs_H_Water2).
  hCall:SET-PARAMETER(40, "DOUBLE", "INPUT", DeltaAbs_R1).
  hCall:SET-PARAMETER(41, "DOUBLE", "INPUT", DeltaAbs_R2).
  hCall:SET-PARAMETER(42, "DOUBLE", "INPUT", DeltaAbs_Tv1).
  hCall:SET-PARAMETER(43, "DOUBLE", "INPUT", DeltaAbs_Tv2).
  hCall:SET-PARAMETER(44, "DOUBLE", "INPUT", DeltaAbs_Tr1).
  hCall:SET-PARAMETER(45, "DOUBLE", "INPUT", DeltaAbs_Tr2).
  hCall:SET-PARAMETER(46, "DOUBLE", "INPUT", DeltaOtn_N).
  hCall:SET-PARAMETER(47, "LONG", "INPUT", Round_M).
  hCall:SET-PARAMETER(48, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(49, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(50, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(51, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(52, "DOUBLE", "OUTPUT", V_total1).
  hCall:SET-PARAMETER(53, "DOUBLE", "OUTPUT", V_total2).
  hCall:SET-PARAMETER(54, "DOUBLE", "OUTPUT", V_water1).
  hCall:SET-PARAMETER(55, "DOUBLE", "OUTPUT", V_water2).
  hCall:SET-PARAMETER(56, "DOUBLE", "OUTPUT", Delta_V1).
  hCall:SET-PARAMETER(57, "DOUBLE", "OUTPUT", Delta_V2).
  hCall:SET-PARAMETER(58, "DOUBLE", "OUTPUT", M).
  hCall:SET-PARAMETER(59, "DOUBLE", "OUTPUT", DeltaOtn_M).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM13 returns logical
 (
  input Mpokr as decimal,
  input Rprov as decimal,
  input Vdisp as decimal,
  input CoverFloatingHeight as decimal,
  input H as decimal,
  input H_water as decimal,
  input CalibrationTable as character,
  input CalibrationBelt as character,
  input P0 as decimal,
  input Pv as decimal,
  input Tv as decimal,
  input Tr as decimal,
  input R as decimal,
  input Tcy as decimal,
  input ToolType as integer,
  input DeltaOtn_K as decimal,
  input DeadZone_Reservoir as decimal,
  input A_Reservoir as decimal,
  input A_LevelMeasurementTool as decimal,
  input ToolAutomationLevel_H as integer,
  input ToolAutomationLevel_H_Water as integer,
  input ToolAutomationLevel_R as integer,
  input ToolAutomationLevel_Tv as integer,
  input ToolAutomationLevel_Tr as integer,
  input DeltaAbs_H_CalcType as integer,
  input DeltaAbs_H_Water_CalcType as integer,
  input DeltaAbs_H as decimal,
  input DeltaAbs_H_Water as decimal,
  input DeltaAbs_R as decimal,
  input DeltaAbs_Tv as decimal,
  input DeltaAbs_Tr as decimal,
  input DeltaOtn_N as decimal,
  input Round_M as integer,
  input Round_T as integer,
  input Round_R as integer,
  output V_total as decimal,
  output V_water as decimal,
  output DeltaV as decimal,
  output V_product as decimal,
  output Vcy as decimal,
  output Rcy as decimal,
  output V as decimal,
  output CTL_base_alt as decimal,
  output CPL_base_alt as decimal,
  output CTPL_base_alt as decimal,
  output Fp_base_alt as decimal,
  output CTL_obs_base as decimal,
  output CPL_obs_base as decimal,
  output CTPL_obs_base as decimal,
  output Fp_obs_base as decimal,
  output Rv as decimal,
  output DeltaOtn_Vcy as decimal,
  output DeltaOtn_Vm as decimal,
  output M as decimal,
  output DeltaOtn_M as decimal,
  output VolumetricExpansion as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt13"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 61
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", Mpokr).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", Rprov).
  hCall:SET-PARAMETER(6, "DOUBLE", "INPUT", Vdisp).
  hCall:SET-PARAMETER(7, "DOUBLE", "INPUT", CoverFloatingHeight).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", H).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", H_water).
  hCall:SET-PARAMETER(10, "CHARACTER", "INPUT", CalibrationTable).
  hCall:SET-PARAMETER(11, "CHARACTER", "INPUT", CalibrationBelt).
  hCall:SET-PARAMETER(12, "DOUBLE", "INPUT", P0).
  hCall:SET-PARAMETER(13, "DOUBLE", "INPUT", Pv).
  hCall:SET-PARAMETER(14, "DOUBLE", "INPUT", Tv).
  hCall:SET-PARAMETER(15, "DOUBLE", "INPUT", Tr).
  hCall:SET-PARAMETER(16, "DOUBLE", "INPUT", R).
  hCall:SET-PARAMETER(17, "DOUBLE", "INPUT", Tcy).
  hCall:SET-PARAMETER(18, "LONG", "INPUT", ToolType).
  hCall:SET-PARAMETER(19, "DOUBLE", "INPUT", DeltaOtn_K).
  hCall:SET-PARAMETER(20, "DOUBLE", "INPUT", DeadZone_Reservoir).
  hCall:SET-PARAMETER(21, "DOUBLE", "INPUT", A_Reservoir).
  hCall:SET-PARAMETER(22, "DOUBLE", "INPUT", A_LevelMeasurementTool).
  hCall:SET-PARAMETER(23, "LONG", "INPUT", ToolAutomationLevel_H).
  hCall:SET-PARAMETER(24, "LONG", "INPUT", ToolAutomationLevel_H_Water).
  hCall:SET-PARAMETER(25, "LONG", "INPUT", ToolAutomationLevel_R).
  hCall:SET-PARAMETER(26, "LONG", "INPUT", ToolAutomationLevel_Tv).
  hCall:SET-PARAMETER(27, "LONG", "INPUT", ToolAutomationLevel_Tr).
  hCall:SET-PARAMETER(28, "LONG", "INPUT", DeltaAbs_H_CalcType).
  hCall:SET-PARAMETER(29, "LONG", "INPUT", DeltaAbs_H_Water_CalcType).
  hCall:SET-PARAMETER(30, "DOUBLE", "INPUT", DeltaAbs_H).
  hCall:SET-PARAMETER(31, "DOUBLE", "INPUT", DeltaAbs_H_Water).
  hCall:SET-PARAMETER(32, "DOUBLE", "INPUT", DeltaAbs_R).
  hCall:SET-PARAMETER(33, "DOUBLE", "INPUT", DeltaAbs_Tv).
  hCall:SET-PARAMETER(34, "DOUBLE", "INPUT", DeltaAbs_Tr).
  hCall:SET-PARAMETER(35, "DOUBLE", "INPUT", DeltaOtn_N).
  hCall:SET-PARAMETER(36, "LONG", "INPUT", Round_M).
  hCall:SET-PARAMETER(37, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(38, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(39, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(40, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(41, "DOUBLE", "OUTPUT", V_total).
  hCall:SET-PARAMETER(42, "DOUBLE", "OUTPUT", V_water).
  hCall:SET-PARAMETER(43, "DOUBLE", "OUTPUT", DeltaV).
  hCall:SET-PARAMETER(44, "DOUBLE", "OUTPUT", V_product).
  hCall:SET-PARAMETER(45, "DOUBLE", "OUTPUT", Vcy).
  hCall:SET-PARAMETER(46, "DOUBLE", "OUTPUT", Rcy).
  hCall:SET-PARAMETER(47, "DOUBLE", "OUTPUT", V).
  hCall:SET-PARAMETER(48, "DOUBLE", "OUTPUT", CTL_base_alt).
  hCall:SET-PARAMETER(49, "DOUBLE", "OUTPUT", CPL_base_alt).
  hCall:SET-PARAMETER(50, "DOUBLE", "OUTPUT", CTPL_base_alt).
  hCall:SET-PARAMETER(51, "DOUBLE", "OUTPUT", Fp_base_alt).
  hCall:SET-PARAMETER(52, "DOUBLE", "OUTPUT", CTL_obs_base).
  hCall:SET-PARAMETER(53, "DOUBLE", "OUTPUT", CPL_obs_base).
  hCall:SET-PARAMETER(54, "DOUBLE", "OUTPUT", CTPL_obs_base).
  hCall:SET-PARAMETER(55, "DOUBLE", "OUTPUT", Fp_obs_base).
  hCall:SET-PARAMETER(56, "DOUBLE", "OUTPUT", Rv).
  hCall:SET-PARAMETER(57, "DOUBLE", "OUTPUT", DeltaOtn_Vcy).
  hCall:SET-PARAMETER(58, "DOUBLE", "OUTPUT", DeltaOtn_Vm).
  hCall:SET-PARAMETER(59, "DOUBLE", "OUTPUT", M).
  hCall:SET-PARAMETER(60, "DOUBLE", "OUTPUT", DeltaOtn_M).
  hCall:SET-PARAMETER(61, "DOUBLE", "OUTPUT", VolumetricExpansion).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM14 returns logical
  (
  input M1 as decimal,
  input M2 as decimal,
  input H1 as decimal,
  input H2 as decimal,
  input H1_water as decimal,
  input H2_water as decimal,
  input CalibrationTable as character,
  input CalibrationBelt as character,
  input Tv1 as decimal,
  input Tv2 as decimal,
  input Tr1 as decimal,
  input Tr2 as decimal,
  input R1 as decimal,
  input R2 as decimal,
  input ToolType1 as integer,
  input ToolType2 as integer,
  input DeltaOtn_K as decimal,
  input OperDirection as integer,
  input ToolAutomationLevel_H1 as integer,
  input ToolAutomationLevel_H2 as integer,
  input ToolAutomationLevel_H_Water1 as integer,
  input ToolAutomationLevel_H_Water2 as integer,
  input ToolAutomationLevel_R1 as integer,
  input ToolAutomationLevel_R2 as integer,
  input ToolAutomationLevel_Tv1 as integer,
  input ToolAutomationLevel_Tv2 as integer,
  input ToolAutomationLevel_Tr1 as integer,
  input ToolAutomationLevel_Tr2 as integer,
  input DeltaAbs_H_CalcType1 as integer,
  input DeltaAbs_H_CalcType2 as integer,
  input DeltaAbs_H_Water_CalcType1 as integer,
  input DeltaAbs_H_Water_CalcType2 as integer,
  input DeltaAbs_H1 as decimal,
  input DeltaAbs_H2 as decimal,
  input DeltaAbs_H_Water1 as decimal,
  input DeltaAbs_H_Water2 as decimal,
  input DeltaAbs_R1 as decimal,
  input DeltaAbs_R2 as decimal,
  input DeltaAbs_Tv1 as decimal,
  input DeltaAbs_Tv2 as decimal,
  input DeltaAbs_Tr1 as decimal,
  input DeltaAbs_Tr2 as decimal,
  input DeltaOtn_N as decimal,
  input Round_M as integer,
  input Round_T as integer,
  input Round_R as integer,
  output V_total1 as decimal,
  output V_total2 as decimal,
  output V_water1 as decimal,
  output V_water2 as decimal,
  output Delta_V1 as decimal,
  output Delta_V2 as decimal,
  output M as decimal,
  output DeltaOtn_M as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt14"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 59
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", M1).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", M2).
  hCall:SET-PARAMETER(6, "DOUBLE", "INPUT", H1).
  hCall:SET-PARAMETER(7, "DOUBLE", "INPUT", H2).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", H1_water).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", H2_water).
  hCall:SET-PARAMETER(10, "CHARACTER", "INPUT", CalibrationTable).
  hCall:SET-PARAMETER(11, "CHARACTER", "INPUT", CalibrationBelt).
  hCall:SET-PARAMETER(12, "DOUBLE", "INPUT", Tv1).
  hCall:SET-PARAMETER(13, "DOUBLE", "INPUT", Tv2).
  hCall:SET-PARAMETER(14, "DOUBLE", "INPUT", Tr1).
  hCall:SET-PARAMETER(15, "DOUBLE", "INPUT", Tr2).
  hCall:SET-PARAMETER(16, "DOUBLE", "INPUT", R1).
  hCall:SET-PARAMETER(17, "DOUBLE", "INPUT", R2).
  hCall:SET-PARAMETER(18, "LONG", "INPUT", ToolType1).
  hCall:SET-PARAMETER(19, "LONG", "INPUT", ToolType2).
  hCall:SET-PARAMETER(20, "DOUBLE", "INPUT", DeltaOtn_K).
  hCall:SET-PARAMETER(21, "LONG", "INPUT", OperDirection).
  hCall:SET-PARAMETER(22, "LONG", "INPUT", ToolAutomationLevel_H1).
  hCall:SET-PARAMETER(23, "LONG", "INPUT", ToolAutomationLevel_H2).
  hCall:SET-PARAMETER(24, "LONG", "INPUT", ToolAutomationLevel_H_Water1).
  hCall:SET-PARAMETER(25, "LONG", "INPUT", ToolAutomationLevel_H_Water2).
  hCall:SET-PARAMETER(26, "LONG", "INPUT", ToolAutomationLevel_R1).
  hCall:SET-PARAMETER(27, "LONG", "INPUT", ToolAutomationLevel_R2).
  hCall:SET-PARAMETER(28, "LONG", "INPUT", ToolAutomationLevel_Tv1).
  hCall:SET-PARAMETER(29, "LONG", "INPUT", ToolAutomationLevel_Tv2).
  hCall:SET-PARAMETER(30, "LONG", "INPUT", ToolAutomationLevel_Tr1).
  hCall:SET-PARAMETER(31, "LONG", "INPUT", ToolAutomationLevel_Tr2).
  hCall:SET-PARAMETER(32, "LONG", "INPUT", DeltaAbs_H_CalcType1).
  hCall:SET-PARAMETER(33, "LONG", "INPUT", DeltaAbs_H_CalcType2).
  hCall:SET-PARAMETER(34, "LONG", "INPUT", DeltaAbs_H_Water_CalcType1).
  hCall:SET-PARAMETER(35, "LONG", "INPUT", DeltaAbs_H_Water_CalcType2).
  hCall:SET-PARAMETER(36, "DOUBLE", "INPUT", DeltaAbs_H1).
  hCall:SET-PARAMETER(37, "DOUBLE", "INPUT", DeltaAbs_H2).
  hCall:SET-PARAMETER(38, "DOUBLE", "INPUT", DeltaAbs_H_Water1).
  hCall:SET-PARAMETER(39, "DOUBLE", "INPUT", DeltaAbs_H_Water2).
  hCall:SET-PARAMETER(40, "DOUBLE", "INPUT", DeltaAbs_R1).
  hCall:SET-PARAMETER(41, "DOUBLE", "INPUT", DeltaAbs_R2).
  hCall:SET-PARAMETER(42, "DOUBLE", "INPUT", DeltaAbs_Tv1).
  hCall:SET-PARAMETER(43, "DOUBLE", "INPUT", DeltaAbs_Tv2).
  hCall:SET-PARAMETER(44, "DOUBLE", "INPUT", DeltaAbs_Tr1).
  hCall:SET-PARAMETER(45, "DOUBLE", "INPUT", DeltaAbs_Tr2).
  hCall:SET-PARAMETER(46, "DOUBLE", "INPUT", DeltaOtn_N).
  hCall:SET-PARAMETER(47, "LONG", "INPUT", Round_M).
  hCall:SET-PARAMETER(48, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(49, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(50, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(51, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(52, "DOUBLE", "OUTPUT", V_total1).
  hCall:SET-PARAMETER(53, "DOUBLE", "OUTPUT", V_total2).
  hCall:SET-PARAMETER(54, "DOUBLE", "OUTPUT", V_water1).
  hCall:SET-PARAMETER(55, "DOUBLE", "OUTPUT", V_water2).
  hCall:SET-PARAMETER(56, "DOUBLE", "OUTPUT", Delta_V1).
  hCall:SET-PARAMETER(57, "DOUBLE", "OUTPUT", Delta_V2).
  hCall:SET-PARAMETER(58, "DOUBLE", "OUTPUT", M).
  hCall:SET-PARAMETER(59, "DOUBLE", "OUTPUT", DeltaOtn_M).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM26A returns logical
  (
  input Type as integer,
  input Diameter as decimal,
  input Length as decimal,
  input Width as decimal,
  input Circumference as decimal,
  input Wall as decimal,
  output Area as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt26A"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 12
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "LONG", "INPUT", Type).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", Diameter).
  hCall:SET-PARAMETER(6, "DOUBLE", "INPUT", Length).
  hCall:SET-PARAMETER(7, "DOUBLE", "INPUT", Width).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", Circumference).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", Wall).
  hCall:SET-PARAMETER(10, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(11, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(12, "DOUBLE", "OUTPUT", Area).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM31N returns logical
  (
  input V_real as decimal,
  input DeltaCorrectionType as integer,
  input CalibrationTable as character,
  input DeltaH as decimal,
  input NeckArea as decimal,
  input Tv as decimal,
  input Tr as decimal,
  input R as decimal,
  input Tcy as decimal,
  input Pr as decimal,
  input Pv as decimal,
  input ToolType as integer,
  input A_Reservoir as decimal,
  input DeltaOtn_V as decimal,
  input ToolAutomationLevel_R as integer,
  input ToolAutomationLevel_Tv as integer,
  input ToolAutomationLevel_Tr as integer,
  input DeltaAbs_R as decimal,
  input DeltaOtn_R as decimal,
  input DeltaAbs_Tv as decimal,
  input DeltaAbs_Tr as decimal,
  input DeltaOtn_N as decimal,
  input Round_M as integer,
  input Round_T as integer,
  input Round_R as integer,
  output DeltaV_GT as decimal,
  output DeltaV as decimal,
  output Vcy as decimal,
  output Rcy as decimal,
  output Rcy20 as decimal,
  output V as decimal,
  output CTL_base_alt as decimal,
  output CPL_base_alt as decimal,
  output CTPL_base_alt as decimal,
  output Fp_base_alt as decimal,
  output CTL_obs_base as decimal,
  output CPL_obs_base as decimal,
  output CTPL_obs_base as decimal,
  output Fp_obs_base as decimal,
  output VolumetricExpansion as decimal,
  output Rv as decimal,
  output DeltaOtn_Vcy as decimal,
  output M as decimal,
  output DeltaOtn_M as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt31N"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 49
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", V_real).
  hCall:SET-PARAMETER(5, "LONG", "INPUT", DeltaCorrectionType).
  hCall:SET-PARAMETER(6, "CHARACTER", "INPUT", CalibrationTable).
  hCall:SET-PARAMETER(7, "DOUBLE", "INPUT", DeltaH).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", NeckArea).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", Tv).
  hCall:SET-PARAMETER(10, "DOUBLE", "INPUT", Tr).
  hCall:SET-PARAMETER(11, "DOUBLE", "INPUT", R).
  hCall:SET-PARAMETER(12, "DOUBLE", "INPUT", Tcy).
  hCall:SET-PARAMETER(13, "DOUBLE", "INPUT", Pr).
  hCall:SET-PARAMETER(14, "DOUBLE", "INPUT", Pv).
  hCall:SET-PARAMETER(15, "LONG", "INPUT", ToolType).
  hCall:SET-PARAMETER(16, "DOUBLE", "INPUT", A_Reservoir).
  hCall:SET-PARAMETER(17, "DOUBLE", "INPUT", DeltaOtn_V).
  hCall:SET-PARAMETER(18, "LONG", "INPUT", ToolAutomationLevel_R).
  hCall:SET-PARAMETER(19, "LONG", "INPUT", ToolAutomationLevel_Tv).
  hCall:SET-PARAMETER(20, "LONG", "INPUT", ToolAutomationLevel_Tr).
  hCall:SET-PARAMETER(21, "DOUBLE", "INPUT", DeltaAbs_R).
  hCall:SET-PARAMETER(22, "DOUBLE", "INPUT", DeltaOtn_R).
  hCall:SET-PARAMETER(23, "DOUBLE", "INPUT", DeltaAbs_Tv).
  hCall:SET-PARAMETER(24, "DOUBLE", "INPUT", DeltaAbs_Tr).
  hCall:SET-PARAMETER(25, "DOUBLE", "INPUT", DeltaOtn_N).
  hCall:SET-PARAMETER(26, "LONG", "INPUT", Round_M).
  hCall:SET-PARAMETER(27, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(28, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(29, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(30, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(31, "DOUBLE", "OUTPUT", DeltaV_GT).
  hCall:SET-PARAMETER(32, "DOUBLE", "OUTPUT", DeltaV).
  hCall:SET-PARAMETER(33, "DOUBLE", "OUTPUT", Vcy).
  hCall:SET-PARAMETER(34, "DOUBLE", "OUTPUT", Rcy).
  hCall:SET-PARAMETER(35, "DOUBLE", "OUTPUT", Rcy20).
  hCall:SET-PARAMETER(36, "DOUBLE", "OUTPUT", V).
  hCall:SET-PARAMETER(37, "DOUBLE", "OUTPUT", CTL_base_alt).
  hCall:SET-PARAMETER(38, "DOUBLE", "OUTPUT", CPL_base_alt).
  hCall:SET-PARAMETER(39, "DOUBLE", "OUTPUT", CTPL_base_alt).
  hCall:SET-PARAMETER(40, "DOUBLE", "OUTPUT", Fp_base_alt).
  hCall:SET-PARAMETER(41, "DOUBLE", "OUTPUT", CTL_obs_base).
  hCall:SET-PARAMETER(42, "DOUBLE", "OUTPUT", CPL_obs_base).
  hCall:SET-PARAMETER(43, "DOUBLE", "OUTPUT", CTPL_obs_base).
  hCall:SET-PARAMETER(44, "DOUBLE", "OUTPUT", Fp_obs_base).
  hCall:SET-PARAMETER(45, "DOUBLE", "OUTPUT", VolumetricExpansion).
  hCall:SET-PARAMETER(46, "DOUBLE", "OUTPUT", Rv).
  hCall:SET-PARAMETER(47, "DOUBLE", "OUTPUT", DeltaOtn_Vcy).
  hCall:SET-PARAMETER(48, "DOUBLE", "OUTPUT", M).
  hCall:SET-PARAMETER(49, "DOUBLE", "OUTPUT", DeltaOtn_M).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM53 returns logical
  (
  input H as decimal,
  input CalibrationTable as character,
  input T as decimal,
  input R_liquid as decimal,
  input R_gas as decimal,
  input A_Reservoir as decimal,
  input DeltaOtn_K as decimal,
  input DeltaOtn_K_full as decimal,
  input DeltaAbs_H as decimal,
  input DeltaAbs_R_liquid as decimal,
  input DeltaAbs_R_gas as decimal,
  input Use_DeltaOtn_R_liquid_IN as integer,
  input DeltaOtn_R_liquid_IN as decimal,
  input DeltaOtn_N as decimal,
  input Round_M as integer,
  input Round_T as integer,
  input Round_R as integer,
  output C_HN as decimal,
  output C_HN_delta as decimal,
  output C_full as decimal,
  output V_liquid as decimal,
  output V_gas as decimal,
  output M_liquid as decimal,
  output M_gas as decimal,
  output M as decimal,
  output Kf as decimal,
  output DeltaOtn_H as decimal,
  output DeltaOtn_R_liquid as decimal,
  output DeltaOtn_R_gas as decimal,
  output DeltaOtn_M_liquid as decimal,
  output DeltaOtn_M_gas as decimal,
  output DeltaOtn_M as decimal,
  output H_min_liquid as decimal,
  output H_min as decimal,
  output A as decimal,
  output B as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt53"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 41
  .
  if DeltaOtn_R_liquid_IN = 0.42
  then
    DeltaOtn_R_liquid_IN = DeltaOtn_R_liquid_IN - 0.0000000001
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", H).
  hCall:SET-PARAMETER(5, "CHARACTER", "INPUT", CalibrationTable).
  hCall:SET-PARAMETER(6, "DOUBLE", "INPUT", T).
  hCall:SET-PARAMETER(7, "DOUBLE", "INPUT", R_liquid).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", R_gas).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", A_Reservoir).
  hCall:SET-PARAMETER(10, "DOUBLE", "INPUT", DeltaOtn_K).
  hCall:SET-PARAMETER(11, "DOUBLE", "INPUT", DeltaOtn_K_full).
  hCall:SET-PARAMETER(12, "DOUBLE", "INPUT", DeltaAbs_H).
  hCall:SET-PARAMETER(13, "DOUBLE", "INPUT", DeltaAbs_R_liquid).
  hCall:SET-PARAMETER(14, "DOUBLE", "INPUT", DeltaAbs_R_gas).
  hCall:SET-PARAMETER(15, "SHORT", "INPUT", Use_DeltaOtn_R_liquid_IN).
  hCall:SET-PARAMETER(16, "DOUBLE", "INPUT", DeltaOtn_R_liquid_IN).
  hCall:SET-PARAMETER(17, "DOUBLE", "INPUT", DeltaOtn_N).
  hCall:SET-PARAMETER(18, "LONG", "INPUT", Round_M).
  hCall:SET-PARAMETER(19, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(20, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(21, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(22, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(23, "DOUBLE", "OUTPUT", C_HN).
  hCall:SET-PARAMETER(24, "DOUBLE", "OUTPUT", C_HN_delta).
  hCall:SET-PARAMETER(25, "DOUBLE", "OUTPUT", C_full).
  hCall:SET-PARAMETER(26, "DOUBLE", "OUTPUT", V_liquid).
  hCall:SET-PARAMETER(27, "DOUBLE", "OUTPUT", V_gas).
  hCall:SET-PARAMETER(28, "DOUBLE", "OUTPUT", M_liquid).
  hCall:SET-PARAMETER(29, "DOUBLE", "OUTPUT", M_gas).
  hCall:SET-PARAMETER(30, "DOUBLE", "OUTPUT", M).
  hCall:SET-PARAMETER(31, "DOUBLE", "OUTPUT", Kf).
  hCall:SET-PARAMETER(32, "DOUBLE", "OUTPUT", DeltaOtn_H).
  hCall:SET-PARAMETER(33, "DOUBLE", "OUTPUT", DeltaOtn_R_liquid).
  hCall:SET-PARAMETER(34, "DOUBLE", "OUTPUT", DeltaOtn_R_gas).
  hCall:SET-PARAMETER(35, "DOUBLE", "OUTPUT", DeltaOtn_M_liquid).
  hCall:SET-PARAMETER(36, "DOUBLE", "OUTPUT", DeltaOtn_M_gas).
  hCall:SET-PARAMETER(37, "DOUBLE", "OUTPUT", DeltaOtn_M).
  hCall:SET-PARAMETER(38, "DOUBLE", "OUTPUT", H_min_liquid).
  hCall:SET-PARAMETER(39, "DOUBLE", "OUTPUT", H_min).
  hCall:SET-PARAMETER(40, "DOUBLE", "OUTPUT", A).
  hCall:SET-PARAMETER(41, "DOUBLE", "OUTPUT", B).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM55 returns logical
  (
  input R15 as decimal,
  input T as decimal,
  input Round_R as integer,
  input Round_T as integer,
  output R as decimal,
  output CTL as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt55"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 11
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", R15).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", T).
  hCall:SET-PARAMETER(6, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(7, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(8, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(9, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(10, "DOUBLE", "OUTPUT", R).
  hCall:SET-PARAMETER(11, "DOUBLE", "OUTPUT", CTL).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM56 returns logical
  (
  input M_type as integer,
  input M as decimal extent 16,
  input T as decimal,
  input P_type as integer,
  input P_extra as decimal,
  input P_atmosphere as decimal,
  input M_pseudo as decimal,
  input R_pseudo as decimal,
  input Round_T as integer,
  input Round_R as integer,
  output R as decimal,
  output P_vapor as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt56"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 17
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "LONG", "INPUT", M_type).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", M).
  hCall:SET-PARAMETER(6, "DOUBLE", "INPUT", T).
  hCall:SET-PARAMETER(7, "LONG", "INPUT", P_type).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", P_extra).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", P_atmosphere).
  hCall:SET-PARAMETER(10, "DOUBLE", "INPUT", M_pseudo).
  hCall:SET-PARAMETER(11, "DOUBLE", "INPUT", R_pseudo).
  hCall:SET-PARAMETER(12, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(13, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(14, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(15, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(16, "DOUBLE", "OUTPUT", R).
  hCall:SET-PARAMETER(17, "DOUBLE", "OUTPUT", P_vapor).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM57 returns logical
  (
  input H as decimal,
  input ToolType as integer,
  output DeltaAbs_H as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt57"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 8
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", H).
  hCall:SET-PARAMETER(5, "LONG", "INPUT", ToolType).
  hCall:SET-PARAMETER(6, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(7, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(8, "DOUBLE", "OUTPUT", DeltaAbs_H).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
define stream outstream.
define variable error-string as character no-undo .
define variable enter-error as logical no-undo .
define buffer buf_place for ub.place .
define buffer buf_goods for ub.goods .
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
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
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
    input 2,
    input 2,
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
    input p-temp,
    input cb-p_type,
    input p-press,
    input f-atm-pressure,
    input f-mmass-pseudo,
    input f-dens-pseudo,
    input 2,
    input 2,
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
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
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
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
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-dens15 f-atm-pressure r-struct-type f-mmass-pseudo f-dens-pseudo cb-p_type
      WITH FRAME Dialog-Frame.
  ENABLE b-cancel b-save f-dens15 f-atm-pressure r-struct-type f-mmass-pseudo cb-p_type
         f-dens-pseudo br-sug-struct
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  open query br-sug-struct for each tt-sug-struct .
END PROCEDURE.
