
/*------------------------------------------------------------------------
    File        : pokmi.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : SlivenkoSA
    Created     : Thu Jul 14 14:31:21 MSK 2025
    Notes       :
  ----------------------------------------------------------------------*/

&if "{1}" = "class"
&then
method public void MM6
&else
function MM6 returns logical
&endif 
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

&if "{1}" = "class"
&then
method public void MM7
&else
function MM7 returns logical
&endif 
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

&if "{1}" = "class"
&then
method public void MM13
&else
function MM13 returns logical
&endif 
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

&if "{1}" = "class"
&then
method public void MM14
&else
function MM14 returns logical
&endif 
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

&if "{1}" = "class"
&then
method public void MM26A
&else
function MM26A returns logical
&endif 
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

&if "{1}" = "class"
&then
method public void MM31N
&else
function MM31N returns logical
&endif 
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

&if "{1}" = "class"
&then
method public void MM53
&else
function MM53 returns logical
&endif 
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

&if "{1}" = "class"
&then
method public void MM55
&else
function MM55 returns logical
&endif 
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

&if "{1}" = "class"
&then
method public void MM56
&else
function MM56 returns logical
&endif 
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

&if "{1}" = "class"
&then
method public void MM57
&else
function MM57 returns logical
&endif 
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
