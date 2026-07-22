
/*------------------------------------------------------------------------
    File        : pokmi.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : SlivenkoSA
    Created     : Thu Jul 14 14:31:21 MSK 2025
    Notes       :
  ----------------------------------------------------------------------*/

procedure MethodCt6 external "exe/MM.dll" STDCALL :
  define output parameter Err as Memptr .
  define output parameter Wrn as Memptr .
  define output parameter DllVersion as Memptr .
  
  define input parameter H as DOUBLE .
  define input parameter H_water as DOUBLE .
  define input parameter CalibrationTable as CHARACTER .
  define input parameter CalibrationBelt as CHARACTER .
  define input parameter P0 as DOUBLE .
  define input parameter Tv as DOUBLE .
  define input parameter Tr as DOUBLE .
  define input parameter R as DOUBLE .
  define input parameter Tcy as DOUBLE .
  define input parameter ToolType as LONG .
  define input parameter DeltaOtn_K as DOUBLE .
  define input parameter DeadZone_Reservoir as DOUBLE .
  define input parameter A_Reservoir as DOUBLE .
  define input parameter A_LevelMeasurementTool as DOUBLE .
  define input parameter ToolAutomationLevel_H as LONG .
  define input parameter ToolAutomationLevel_H_Water as LONG .
  define input parameter ToolAutomationLevel_R as LONG .
  define input parameter ToolAutomationLevel_Tv as LONG .
  define input parameter ToolAutomationLevel_Tr as LONG .
  define input parameter DeltaAbs_H_CalcType as LONG .
  define input parameter DeltaAbs_H_Water_CalcType as LONG .
  define input parameter DeltaAbs_H as DOUBLE .
  define input parameter DeltaAbs_H_Water as DOUBLE .
  define input parameter DeltaAbs_R as DOUBLE .
  define input parameter DeltaAbs_Tv as DOUBLE .
  define input parameter DeltaAbs_Tr as DOUBLE .
  define input parameter DeltaOtn_N as DOUBLE .
  define input parameter Round_M as LONG .
  define input parameter Round_T as LONG .
  define input parameter Round_R as LONG .
    
  define input parameter NErr as LONG .
  define input parameter NWrn as LONG .
  
  define output parameter V_total as DOUBLE .
  define output parameter V_water as DOUBLE .
  define output parameter DeltaV as DOUBLE .
  define output parameter V_product as DOUBLE .
  define output parameter Vcy as DOUBLE .
  define output parameter Rcy as DOUBLE .
  define output parameter V as DOUBLE .
  define output parameter CTL_base_alt as DOUBLE .
  define output parameter CPL_base_alt as DOUBLE .
  define output parameter CTPL_base_alt as DOUBLE .
  define output parameter Fp_base_alt as DOUBLE .
  define output parameter CTL_obs_base as DOUBLE .
  define output parameter CPL_obs_base as DOUBLE .
  define output parameter CTPL_obs_base as DOUBLE .
  define output parameter Fp_obs_base as DOUBLE .
  define output parameter Rv as DOUBLE .
  define output parameter DeltaOtn_Vcy as DOUBLE .
  define output parameter DeltaOtn_Vm as DOUBLE .
  define output parameter M as DOUBLE .
  define output parameter DeltaOtn_M as DOUBLE .
  define output parameter VolumetricExpansion as DOUBLE .
end .

procedure MethodCt7 external "exe/MM.dll" STDCALL :
  define output parameter Err as Memptr .
  define output parameter Wrn as Memptr .
  define output parameter DllVersion as Memptr .
  
  define input parameter M1 as DOUBLE .
  define input parameter M2 as DOUBLE .
  define input parameter H1 as DOUBLE .
  define input parameter H2 as DOUBLE .
  define input parameter H1_water as DOUBLE .
  define input parameter H2_water as DOUBLE .
  define input parameter CalibrationTable as CHARACTER .
  define input parameter CalibrationBelt as CHARACTER .
  define input parameter Tv1 as DOUBLE .
  define input parameter Tv2 as DOUBLE .
  define input parameter Tr1 as DOUBLE .
  define input parameter Tr2 as DOUBLE .
  define input parameter R1 as DOUBLE .
  define input parameter R2 as DOUBLE .
  define input parameter ToolType1 as LONG .
  define input parameter ToolType2 as LONG .
  define input parameter DeltaOtn_K as DOUBLE .
  define input parameter OperDirection as LONG .
  define input parameter ToolAutomationLevel_H1 as LONG .
  define input parameter ToolAutomationLevel_H2 as LONG .
  define input parameter ToolAutomationLevel_H_Water1 as LONG .
  define input parameter ToolAutomationLevel_H_Water2 as LONG .
  define input parameter ToolAutomationLevel_R1 as LONG .
  define input parameter ToolAutomationLevel_R2 as LONG .
  define input parameter ToolAutomationLevel_Tv1 as LONG .
  define input parameter ToolAutomationLevel_Tv2 as LONG .
  define input parameter ToolAutomationLevel_Tr1 as LONG .
  define input parameter ToolAutomationLevel_Tr2 as LONG .
  define input parameter DeltaAbs_H_CalcType1 as LONG .
  define input parameter DeltaAbs_H_CalcType2 as LONG .
  define input parameter DeltaAbs_H_Water_CalcType1 as LONG .
  define input parameter DeltaAbs_H_Water_CalcType2 as LONG .
  define input parameter DeltaAbs_H1 as DOUBLE .
  define input parameter DeltaAbs_H2 as DOUBLE .
  define input parameter DeltaAbs_H_Water1 as DOUBLE .
  define input parameter DeltaAbs_H_Water2 as DOUBLE .
  define input parameter DeltaAbs_R1 as DOUBLE .
  define input parameter DeltaAbs_R2 as DOUBLE .
  define input parameter DeltaAbs_Tv1 as DOUBLE .
  define input parameter DeltaAbs_Tv2 as DOUBLE .
  define input parameter DeltaAbs_Tr1 as DOUBLE .
  define input parameter DeltaAbs_Tr2 as DOUBLE .
  define input parameter DeltaOtn_N as DOUBLE .
  define input parameter Round_M as LONG .
  define input parameter Round_T as LONG .
  define input parameter Round_R as LONG .
    
  define input parameter NErr as LONG .
  define input parameter NWrn as LONG .
  
  define output parameter V_total1 as DOUBLE .
  define output parameter V_total2 as DOUBLE .
  define output parameter V_water1 as DOUBLE .
  define output parameter V_water2 as DOUBLE .
  define output parameter Delta_V1 as DOUBLE .
  define output parameter Delta_V2 as DOUBLE .
  define output parameter M as DOUBLE .
  define output parameter DeltaOtn_M as DOUBLE .
end .

procedure MethodCt13 external "exe/MM.dll" STDCALL :
  define output parameter Err as Memptr .
  define output parameter Wrn as Memptr .
  define output parameter DllVersion as Memptr .
  
  define input parameter Mpokr as DOUBLE .
  define input parameter Rprov as DOUBLE .
  define input parameter Vdisp as DOUBLE .
  define input parameter CoverFloatingHeight as DOUBLE .
  define input parameter H as DOUBLE .
  define input parameter H_water as DOUBLE .
  define input parameter CalibrationTable as CHARACTER .
  define input parameter CalibrationBelt as CHARACTER .
  define input parameter P0 as DOUBLE .
  define input parameter Pv as DOUBLE .
  define input parameter Tv as DOUBLE .
  define input parameter Tr as DOUBLE .
  define input parameter R as DOUBLE .
  define input parameter Tcy as DOUBLE .
  define input parameter ToolType as LONG .
  define input parameter DeltaOtn_K as DOUBLE .
  define input parameter DeadZone_Reservoir as DOUBLE .
  define input parameter A_Reservoir as DOUBLE .
  define input parameter A_LevelMeasurementTool as DOUBLE .
  define input parameter ToolAutomationLevel_H as LONG .
  define input parameter ToolAutomationLevel_H_Water as LONG .
  define input parameter ToolAutomationLevel_R as LONG .
  define input parameter ToolAutomationLevel_Tv as LONG .
  define input parameter ToolAutomationLevel_Tr as LONG .
  define input parameter DeltaAbs_H_CalcType as LONG .
  define input parameter DeltaAbs_H_Water_CalcType as LONG .
  define input parameter DeltaAbs_H as DOUBLE .
  define input parameter DeltaAbs_H_Water as DOUBLE .
  define input parameter DeltaAbs_R as DOUBLE .
  define input parameter DeltaAbs_Tv as DOUBLE .
  define input parameter DeltaAbs_Tr as DOUBLE .
  define input parameter DeltaOtn_N as DOUBLE .
  define input parameter Round_M as LONG .
  define input parameter Round_T as LONG .
  define input parameter Round_R as LONG .
    
  define input parameter NErr as LONG .
  define input parameter NWrn as LONG .
  
  define output parameter V_total as DOUBLE .
  define output parameter V_water as DOUBLE .
  define output parameter DeltaV as DOUBLE .
  define output parameter V_product as DOUBLE .
  define output parameter Vcy as DOUBLE .
  define output parameter Rcy as DOUBLE .
  define output parameter V as DOUBLE .
  define output parameter CTL_base_alt as DOUBLE .
  define output parameter CPL_base_alt as DOUBLE .
  define output parameter CTPL_base_alt as DOUBLE .
  define output parameter Fp_base_alt as DOUBLE .
  define output parameter CTL_obs_base as DOUBLE .
  define output parameter CPL_obs_base as DOUBLE .
  define output parameter CTPL_obs_base as DOUBLE .
  define output parameter Fp_obs_base as DOUBLE .
  define output parameter Rv as DOUBLE .
  define output parameter DeltaOtn_Vcy as DOUBLE .
  define output parameter DeltaOtn_Vm as DOUBLE .
  define output parameter M as DOUBLE .
  define output parameter DeltaOtn_M as DOUBLE .
  define output parameter VolumetricExpansion as DOUBLE .
end .

procedure MethodCt14 external "exe/MM.dll" STDCALL :
  define output parameter Err as Memptr .
  define output parameter Wrn as Memptr .
  define output parameter DllVersion as Memptr .
  
  define input parameter M1 as DOUBLE .
  define input parameter M2 as DOUBLE .
  define input parameter H1 as DOUBLE .
  define input parameter H2 as DOUBLE .
  define input parameter H1_water as DOUBLE .
  define input parameter H2_water as DOUBLE .
  define input parameter CalibrationTable as CHARACTER .
  define input parameter CalibrationBelt as CHARACTER .
  define input parameter Tv1 as DOUBLE .
  define input parameter Tv2 as DOUBLE .
  define input parameter Tr1 as DOUBLE .
  define input parameter Tr2 as DOUBLE .
  define input parameter R1 as DOUBLE .
  define input parameter R2 as DOUBLE .
  define input parameter ToolType1 as LONG .
  define input parameter ToolType2 as LONG .
  define input parameter DeltaOtn_K as DOUBLE .
  define input parameter OperDirection as LONG .
  define input parameter ToolAutomationLevel_H1 as LONG .
  define input parameter ToolAutomationLevel_H2 as LONG .
  define input parameter ToolAutomationLevel_H_Water1 as LONG .
  define input parameter ToolAutomationLevel_H_Water2 as LONG .
  define input parameter ToolAutomationLevel_R1 as LONG .
  define input parameter ToolAutomationLevel_R2 as LONG .
  define input parameter ToolAutomationLevel_Tv1 as LONG .
  define input parameter ToolAutomationLevel_Tv2 as LONG .
  define input parameter ToolAutomationLevel_Tr1 as LONG .
  define input parameter ToolAutomationLevel_Tr2 as LONG .
  define input parameter DeltaAbs_H_CalcType1 as LONG .
  define input parameter DeltaAbs_H_CalcType2 as LONG .
  define input parameter DeltaAbs_H_Water_CalcType1 as LONG .
  define input parameter DeltaAbs_H_Water_CalcType2 as LONG .
  define input parameter DeltaAbs_H1 as DOUBLE .
  define input parameter DeltaAbs_H2 as DOUBLE .
  define input parameter DeltaAbs_H_Water1 as DOUBLE .
  define input parameter DeltaAbs_H_Water2 as DOUBLE .
  define input parameter DeltaAbs_R1 as DOUBLE .
  define input parameter DeltaAbs_R2 as DOUBLE .
  define input parameter DeltaAbs_Tv1 as DOUBLE .
  define input parameter DeltaAbs_Tv2 as DOUBLE .
  define input parameter DeltaAbs_Tr1 as DOUBLE .
  define input parameter DeltaAbs_Tr2 as DOUBLE .
  define input parameter DeltaOtn_N as DOUBLE .
  define input parameter Round_M as LONG .
  define input parameter Round_T as LONG .
  define input parameter Round_R as LONG .
    
  define input parameter NErr as LONG .
  define input parameter NWrn as LONG .
  
  define output parameter V_total1 as DOUBLE .
  define output parameter V_total2 as DOUBLE .
  define output parameter V_water1 as DOUBLE .
  define output parameter V_water2 as DOUBLE .
  define output parameter Delta_V1 as DOUBLE .
  define output parameter Delta_V2 as DOUBLE .
  define output parameter M as DOUBLE .
  define output parameter DeltaOtn_M as DOUBLE .
end .

procedure MethodCt26A external "exe/MM.dll" STDCALL :
  define output parameter Err as Memptr .
  define output parameter Wrn as Memptr .
  define output parameter DllVersion as Memptr .
  
  define input parameter Type as LONG .
  define input parameter Diameter as DOUBLE .
  define input parameter Length as DOUBLE .
  define input parameter Width as DOUBLE .
  define input parameter Circumference as DOUBLE .
  define input parameter Wall as DOUBLE .
  
  define input parameter NErr as LONG .
  define input parameter NWrn as LONG .
  
  define output parameter Area as DOUBLE .
end .

procedure MethodCt31N external "exe/MM.dll" STDCALL :
  define output parameter Err as Memptr .
  define output parameter Wrn as Memptr .
  define output parameter DllVersion as Memptr .
  
  define input parameter V_real as DOUBLE .
  define input parameter DeltaCorrectionType as LONG .
  define input parameter CalibrationTable as CHARACTER .
  define input parameter DeltaH as DOUBLE .
  define input parameter NeckArea as DOUBLE .
  define input parameter Tv as DOUBLE .
  define input parameter Tr as DOUBLE .
  define input parameter R as DOUBLE .
  define input parameter Tcy as DOUBLE .
  define input parameter Pr as DOUBLE .
  define input parameter Pv as DOUBLE .
  define input parameter ToolType as LONG .
  define input parameter A_Reservoir as DOUBLE .
  define input parameter DeltaOtn_V as DOUBLE .
  define input parameter ToolAutomationLevel_R as LONG .
  define input parameter ToolAutomationLevel_Tv as LONG .
  define input parameter ToolAutomationLevel_Tr as LONG .
  define input parameter DeltaAbs_R as DOUBLE .
  define input parameter DeltaOtn_R as DOUBLE .
  define input parameter DeltaAbs_Tv as DOUBLE .
  define input parameter DeltaAbs_Tr as DOUBLE .
  define input parameter DeltaOtn_N as DOUBLE .
  define input parameter Round_M as LONG .
  define input parameter Round_T as LONG .
  define input parameter Round_R as LONG .
  
  define input parameter NErr as LONG .
  define input parameter NWrn as LONG .
  
  define output parameter DeltaV_GT as DOUBLE .
  define output parameter DeltaV as DOUBLE .
  define output parameter Vcy as DOUBLE .
  define output parameter Rcy as DOUBLE .
  define output parameter Rcy20 as DOUBLE .
  define output parameter V as DOUBLE .
  define output parameter CTL_base_alt as DOUBLE .
  define output parameter CPL_base_alt as DOUBLE .
  define output parameter CTPL_base_alt as DOUBLE .
  define output parameter Fp_base_alt as DOUBLE .
  define output parameter CTL_obs_base as DOUBLE .
  define output parameter CPL_obs_base as DOUBLE .
  define output parameter CTPL_obs_base as DOUBLE .
  define output parameter Fp_obs_base as DOUBLE .
  define output parameter VolumetricExpansion as DOUBLE .
  define output parameter Rv as DOUBLE .
  define output parameter DeltaOtn_Vcy as DOUBLE .
  define output parameter M as DOUBLE .
  define output parameter DeltaOtn_M as DOUBLE .
end .

procedure MethodCt53 external "exe/MM.dll" STDCALL :
  define output parameter Err as Memptr .
  define output parameter Wrn as Memptr .
  define output parameter DllVersion as Memptr .
  
  define input parameter H as DOUBLE .
  define input parameter CalibrationTable as CHARACTER .
  define input parameter T as DOUBLE .
  define input parameter R_liquid as DOUBLE .
  define input parameter R_gas as DOUBLE .
  define input parameter A_Reservoir as DOUBLE .
  define input parameter DeltaOtn_K as DOUBLE .
  define input parameter DeltaOtn_K_full as DOUBLE .
  define input parameter DeltaAbs_H as DOUBLE .
  define input parameter DeltaAbs_R_liquid as DOUBLE .
  define input parameter DeltaAbs_R_gas as DOUBLE .
  define input parameter Use_DeltaOtn_R_liquid_IN as SHORT .
  define input parameter DeltaOtn_R_liquid_IN as DOUBLE .
  define input parameter DeltaOtn_N as DOUBLE .
  define input parameter Round_M as LONG .
  define input parameter Round_T as LONG .
  define input parameter Round_R as LONG .
    
  define input parameter NErr as LONG .
  define input parameter NWrn as LONG .
  
  define output parameter C_HN as DOUBLE .
  define output parameter C_HN_delta as DOUBLE .
  define output parameter C_full as DOUBLE .
  define output parameter V_liquid as DOUBLE .
  define output parameter V_gas as DOUBLE .
  define output parameter M_liquid as DOUBLE .
  define output parameter M_gas as DOUBLE .
  define output parameter M as DOUBLE .
  define output parameter Kf as DOUBLE .
  define output parameter DeltaOtn_H as DOUBLE .
  define output parameter DeltaOtn_R_liquid as DOUBLE .
  define output parameter DeltaOtn_R_gas as DOUBLE .
  define output parameter DeltaOtn_M_liquid as DOUBLE .
  define output parameter DeltaOtn_M_gas as DOUBLE .
  define output parameter DeltaOtn_M as DOUBLE .
  define output parameter H_min_liquid as DOUBLE .
  define output parameter H_min as DOUBLE .
  define output parameter A as DOUBLE .
  define output parameter B as DOUBLE .
end .

procedure MethodCt55 external "exe/MM.dll" STDCALL :
  define output parameter Err as Memptr .
  define output parameter Wrn as Memptr .
  define output parameter DllVersion as Memptr .
  
  define input parameter R15 as DOUBLE .
  define input parameter T as DOUBLE .
  define input parameter Round_R as LONG .
  define input parameter Round_T as LONG .
  
  define input parameter NErr as LONG .
  define input parameter NWrn as LONG .
  
  define output parameter R as DOUBLE .
  define output parameter CTL as DOUBLE .
end .

procedure MethodCt56 external "exe/MM.dll" STDCALL :
  define output parameter Err as Memptr .
  define output parameter Wrn as Memptr .
  define output parameter DllVersion as Memptr .
  
  define input parameter M_type as LONG .
  define input parameter M as DOUBLE .
  define input parameter T as DOUBLE .
  define input parameter P_type as LONG .
  define input parameter P_extra as DOUBLE .
  define input parameter P_atmosphere as DOUBLE .
  define input parameter M_pseudo as DOUBLE .
  define input parameter R_pseudo as DOUBLE .
  define input parameter Round_T as LONG .
  define input parameter Round_R as LONG .
  
  define input parameter NErr as LONG .
  define input parameter NWrn as LONG .
  
  define output parameter R as DOUBLE .
  define output parameter P_vapor as DOUBLE .
end .

procedure MethodCt57 external "exe/MM.dll" STDCALL :
  define output parameter Err as Memptr .
  define output parameter Wrn as Memptr .
  define output parameter DllVersion as Memptr .
  
  define input parameter H as DOUBLE .
  define input parameter ToolType as LONG .
  
  define input parameter NErr as LONG .
  define input parameter NWrn as LONG .
  
  define output parameter DeltaAbs_H as DOUBLE .
end .
