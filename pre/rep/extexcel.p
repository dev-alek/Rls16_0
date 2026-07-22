block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: extexcel.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/extexcel.p $":U .
define variable vss-description as character no-undo init "Вывод в Excel".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define new shared variable str1   as character  no-undo.
define new shared variable str2   as character  no-undo.
define new shared variable str3   as character  no-undo.
define new shared variable str4   as character  no-undo.
define new shared variable ReportNAme   as character  no-undo.
define new shared variable ReportProc   as character  no-undo.
define new shared variable ReportHeader as character  no-undo.
define new shared variable ReportPageWidth  as integer no-undo.
define new shared variable ReportPageHeight as integer no-undo.
define new shared variable ReportFontNum    as integer no-undo.
define new shared variable my-request as logical  init false no-undo.
define new shared variable v-delim as character no-undo .
define new shared variable v-sdate as character no-undo initial "/":U.
define new shared variable v-shortdate as character no-undo initial "dd/mm/yyyy":U .
define new shared variable my-handle  as handle no-undo .
define new shared variable parent-handle  as handle no-undo .
define new shared variable v-show-all-goods as logical  no-undo .
define new shared variable params-only      as logical   no-undo .
define new shared variable params-only-mode as character no-undo .
define new shared variable place-call       as character no-undo .
define new shared variable x-Goods-Editor   as character  no-undo .
define new shared variable x-Date-Alone     as date format "99/99/9999":u   no-undo .
define new shared variable x-Date-End       as date format "99/99/9999":u   no-undo .
define new shared variable x-Date-Start     as date format "99/99/9999":u   no-undo .
define new shared variable x-Shift-Alone    as integer format ">9":u         no-undo .
define new shared variable x-Shift-End      as integer format ">9":u         no-undo .
define new shared variable x-Shift-Start    as integer format ">9":u         no-undo .
define new shared variable x-SelectGood     as integer                      no-undo .
define new shared variable x-SelectObject   as character                          no-undo .
define new shared variable x-SET_PAY_TYPE   as integer  no-undo .
define new shared variable x-SET_val_TYPE   as integer  no-undo .
define new shared variable x-TOG-Shift      as logical  no-undo .
define new shared variable x-Radio-Task     as integer  no-undo .
define new shared variable x-TOG-Excel      as logical  no-undo .
define new shared variable x-TOG-list-hist  as logical  no-undo .
define new shared variable x-text-1 as character  no-undo .
define new shared variable x-text-2 as character  no-undo .
define new shared variable x-text-3 as character  no-undo .
define new shared variable x-text-4 as character  no-undo .
define new shared variable init-date-start  like x-date-start  no-undo .
define new shared variable init-date-end    like x-date-end    no-undo .
define new shared variable init-date-alone  like x-date-alone  no-undo .
define new shared variable init-shift-alone like x-shift-alone no-undo .
define new shared variable init-shift-start like x-shift-start no-undo .
define new shared variable init-shift-end   like x-shift-end   no-undo .
define new shared variable init-set_pay_type like x-set_pay_type   no-undo .
define new shared variable init-set_val_type like x-set_val_type   no-undo .
define new shared variable ref_date-start    as character   no-undo .
define new shared variable ref_date-end      as character   no-undo .
define new shared variable ref_date-alone    as character   no-undo .
define new shared work-table TDEDT  no-undo
  field id as char
  field name as character  format "x(40)"
  field n as character
  .
define variable tempstr as character  no-undo.
define variable b1-name as character  no-undo.
define variable b2-name as character  no-undo.
define variable source-str   as character no-undo .
define variable I#           as integer    no-undo.
define variable p-price-med  as decimal init 0 no-undo .
define new shared variable str-obj-type as character  no-undo.
define new shared variable str-obj-code as character  no-undo.
define new shared variable str-obj-name as character  no-undo.
define new shared variable str-obj      as character  no-undo.
define new shared variable link#        as logical  no-undo init false.
define new shared variable  Verify-Arc-ot      as logical  no-undo init false.
define new shared variable  Verify-Arc-stk     as logical  no-undo init false.
define new shared variable  Verify-Arc-supp    as logical  no-undo init false.
define new shared variable  Verify-Arc-hold    as logical  no-undo init false.
define new shared variable  Verify-Arc-aht     as logical  no-undo init false.
define new shared variable  Verify-send-check  as logical  no-undo init false.
define new shared variable  Verify-Arc-fin     as logical  no-undo init false.
define new shared variable  Verify-Arc-strong  as logical  no-undo init false.
define new shared variable  Show-Crsa         as logical  no-undo init false.
define new shared variable  Show-Cost         as logical  no-undo init false.
define new shared variable  Show-Sale         as logical  no-undo init false.
define new shared variable  Name-Sale-price   as character no-undo .
define new shared variable  Format-Folder     as logical no-undo .
define new shared variable  Print-List-Hist   as logical no-undo init false.
define new shared variable Make-Excel     as logical  no-undo init false.
define new shared variable Make-Excel-com as logical  no-undo init false.
define new shared stream ForExcel.
define new shared variable Use-column   as logical extent 256 no-undo .
define new shared variable right-column as logical extent 256 no-undo .
define new shared temp-table Sheetf no-undo
field Excel-Column-Lable as character
field Excel-Row-Heder    as integer
field Excel-Row-Title    as integer
field Sizes              as character
field Make-correct       as character
field Rights-column      as character
field MergeCellsH        as character
field MergeCellsV        as character
field sheet-num          as integer
field ColFormat          as character
field Bas-FIle           as character
field Bas-Params         as character
field Bas-Param-Add      as logical
field File-name          as character
field Silent-save        as logical
index pi as primary unique
      sheet-num
.
  create Sheetf.
  assign
  sheetf.sheet-num = 1.
define variable l-stroka as character no-undo .
define new shared  variable ch#ExcelApplication as com-handle no-undo .
define new shared  variable ch#Workbook         as com-handle no-undo .
define new shared  variable ch#Worksheet        as com-handle no-undo .
define new shared  variable Num#Str#            as integer no-undo.
define new shared  variable Number-List         as integer no-undo init 1.
define new shared  variable v-excel-file        as character no-undo .
define variable Col-name as character  extent 256.
define variable Col-format as character  extent 256.
define variable Col-Post-format as character  extent 256.
run proc-page0-assign in this-procedure .
define variable v-del-1 as character no-undo .
if  v-delim = " " or v-delim = ? or v-delim = ""  then do:
    run gbl/getlocal.p ( output v-delim  , output v-del-1, output v-sdate, output v-shortdate ) no-error .
    if error-status :error then do:
      message error-status :error error-status :get-message(1)
              v-delim v-del-1.
        v-delim = ','  .
    end.
end.
procedure proc-page0-assign :
 do
 on error undo, return error return-value
 :
Assign
  Col-name[1] = 'A':U
  Col-name[2] = 'B':U
  Col-name[3] = 'C':U
  Col-name[4] = 'D':U
  Col-name[5] = 'E':U
  Col-name[6] = 'F':U
  Col-name[7] = 'G':U
  Col-name[8] = 'H':U
  Col-name[9] = 'I':U
  Col-name[10]= 'J':U
  Col-name[11]= 'K':U
  Col-name[12]= 'L':U
  Col-name[13]= 'M':U
  Col-name[14]= 'N':U
  Col-name[15]= 'O':U
  Col-name[16]= 'P':U
  Col-name[17]= 'Q':U
  Col-name[18]= 'R':U
  Col-name[19]= 'S':U
  Col-name[20]= 'T':U
  Col-name[21]= 'U':U
  Col-name[22]= 'V':U
  Col-name[23]= 'W':U
  Col-name[24]= 'X':U
  Col-name[25]= 'Y':U
  Col-name[26]= 'Z':U
  Col-name[27]= 'AA':U
  Col-name[28]= 'AB':U
  Col-name[29]= 'AC':U
  Col-name[30]= 'AD':U
  Col-name[31]= 'AE':U
  Col-name[32]= 'AF':U
  Col-name[33]= 'AG':U
  Col-name[34]= 'AH':U
  Col-name[35]= 'AI':U
  Col-name[36]= 'AJ':U
  Col-name[37]= 'AK':U
  Col-name[38]= 'AL':U
  Col-name[39]= 'AM':U
  Col-name[40]= 'AN':U
  Col-name[41]= 'AO':U
  Col-name[42]= 'AP':U
  Col-name[43]= 'AQ':U
  Col-name[44]= 'AR':U
  Col-name[45]= 'AS':U
  Col-name[46]= 'AT':U
  Col-name[47]= 'AU':U
  Col-name[48]= 'AV':U
  Col-name[49]= 'AW':U
  Col-name[50]= 'AX':U
  Col-name[51]= 'AY':U
  Col-name[52]= 'AZ':U
  Col-name[53]= 'BA':U
  Col-name[54]= 'BB':U
  Col-name[55]= 'BC':U
  Col-name[56]= 'BD':U
  Col-name[57]= 'BE':U
  Col-name[58]= 'BF':U
  Col-name[59]= 'BG':U
  Col-name[60]= 'BH':U
  Col-name[61]= 'BI':U
  Col-name[62]= 'BJ':U
  Col-name[63]= 'BK':U
  Col-name[64]= 'BL':U
  Col-name[65]= 'BM':U
  Col-name[66]= 'BN':U
  Col-name[67]= 'BO':U
  Col-name[68]= 'BP':U
  Col-name[69]= 'BQ':U
  Col-name[70]= 'BR':U
  Col-name[71]= 'BS':U
  Col-name[72]= 'BT':U
  Col-name[73]= 'BU':U
  Col-name[74]= 'BV':U
  Col-name[75]= 'BW':U
  Col-name[76]= 'BX':U
  Col-name[77]= 'BY':U
  Col-name[78]= 'BZ':U
  Col-name[79]= 'CA':U
  Col-name[80]= 'CB':U
  Col-name[81]= 'CC':U
  Col-name[82]= 'CD':U
  Col-name[83]= 'CE':U
  Col-name[84]= 'CF':U
  Col-name[85]= 'CG':U
  Col-name[86]= 'CH':U
  Col-name[87]= 'CI':U
  Col-name[88]= 'CJ':U
  Col-name[89]= 'CK':U
  Col-name[90]= 'CL':U
  Col-name[91]= 'CM':U
  Col-name[92]= 'CN':U
  Col-name[93]= 'CO':U
  Col-name[94]= 'CP':U
  Col-name[95]= 'CQ':U
  Col-name[96]= 'CR':U
  Col-name[97]= 'CS':U
  Col-name[98]= 'CT':U
  Col-name[99]= 'CU':U
  Col-name[100]= 'CV':U
Col-name[101]= 'CW':U
Col-name[102]= 'CX':U
Col-name[103]= 'CY':U
Col-name[104]= 'CZ':U
Col-name[105]= 'DA':U
Col-name[106]= 'DB':U
Col-name[107]= 'DC':U
Col-name[108]= 'DD':U
Col-name[109]= 'DE':U
Col-name[110]= 'DF':U
Col-name[111]= 'DG':U
Col-name[112]= 'DH':U
Col-name[113]= 'DI':U
Col-name[114]= 'DJ':U
Col-name[115]= 'DK':U
Col-name[116]= 'DL':U
Col-name[117]= 'DM':U
Col-name[118]= 'DN':U
Col-name[119]= 'DO':U
Col-name[120]= 'DP':U
Col-name[121]= 'DQ':U
Col-name[122]= 'DR':U
Col-name[123]= 'DS':U
Col-name[124]= 'DT':U
Col-name[125]= 'DU':U
Col-name[126]= 'DV':U
Col-name[127]= 'DW':U
Col-name[128]= 'DX':U
Col-name[129]= 'DY':U
Col-name[130]= 'DZ':U
Col-name[131]= 'EA':U
Col-name[132]= 'EB':U
Col-name[133]= 'EC':U
Col-name[134]= 'ED':U
Col-name[135]= 'EE':U
Col-name[136]= 'EF':U
Col-name[137]= 'EG':U
Col-name[138]= 'EH':U
Col-name[139]= 'EI':U
Col-name[140]= 'EJ':U
Col-name[141]= 'EK':U
Col-name[142]= 'EL':U
Col-name[143]= 'EM':U
Col-name[144]= 'EN':U
Col-name[145]= 'EO':U
Col-name[146]= 'EP':U
Col-name[147]= 'EQ':U
Col-name[148]= 'ER':U
Col-name[149]= 'ES':U
Col-name[150]= 'ET':U
Col-name[151]= 'EU':U
Col-name[152]= 'EV':U
Col-name[153]= 'EW':U
Col-name[154]= 'EX':U
Col-name[155]= 'EY':U
Col-name[156]= 'EZ':U
Col-name[157]= 'FA':U
.
assign
  Col-name[158]= 'FB':U
  Col-name[159]= 'FC':U
  Col-name[160]= 'FD':U
  Col-name[161]= 'FE':U
  Col-name[162]= 'FF':U
  Col-name[163]= 'FG':U
  Col-name[164]= 'FH':U
  Col-name[165]= 'FI':U
  Col-name[166]= 'FJ':U
  Col-name[167]= 'FK':U
  Col-name[168]= 'FL':U
  Col-name[169]= 'FM':U
  Col-name[170]= 'FN':U
  Col-name[171]= 'FO':U
  Col-name[172]= 'FP':U
  Col-name[173]= 'FQ':U
  Col-name[174]= 'FR':U
  Col-name[175]= 'FS':U
  Col-name[176]= 'FT':U
  Col-name[177]= 'FU':U
  Col-name[178]= 'FV':U
  Col-name[179]= 'FW':U
  Col-name[180]= 'FX':U
  Col-name[181]= 'FY':U
  Col-name[182]= 'FZ':U
  Col-name[183]= 'GA':U
  Col-name[184]= 'GB':U
  Col-name[185]= 'GC':U
  Col-name[186]= 'GD':U
  Col-name[187]= 'GE':U
  Col-name[188]= 'GF':U
  Col-name[189]= 'GG':U
  Col-name[190]= 'GH':U
  Col-name[191]= 'GI':U
  Col-name[192]= 'GJ':U
  Col-name[193]= 'GK':U
  Col-name[194]= 'GL':U
  Col-name[195]= 'GM':U
  Col-name[196]= 'GN':U
  Col-name[197]= 'GO':U
  Col-name[198]= 'GP':U
  Col-name[199]= 'GQ':U
  Col-name[200]=   'GR':U
  Col-name[201]=   'GS':U
  Col-name[202]=   'GT':U
  Col-name[203]=   'GU':U
  Col-name[204]=   'GV':U
  Col-name[205]=   'GW':U
  Col-name[206]=   'GX':U
  Col-name[207]=   'GY':U
  Col-name[208]=   'GZ':U
  Col-name[209]=   'HA':U
  Col-name[210]=   'HB':U
  Col-name[211]=   'HC':U
  Col-name[212]=   'HD':U
  Col-name[213]=   'HE':U
  Col-name[214]=   'HF':U
  Col-name[215]=   'HG':U
  Col-name[216]=   'HH':U
  Col-name[217]=   'HI':U
  Col-name[218]=   'HJ':U
  Col-name[219]=   'HK':U
  Col-name[220]=   'HL':U
  Col-name[221]=   'HM':U
  Col-name[222]=   'HN':U
  Col-name[223]=   'HO':U
  Col-name[224]=   'HP':U
  Col-name[225]=   'HQ':U
  Col-name[226]=   'HR':U
  Col-name[227]=   'HS':U
  Col-name[228]=   'HT':U
  Col-name[229]=   'HU':U
  Col-name[230]=   'HV':U
  Col-name[231]=   'HW':U
  Col-name[232]=   'HX':U
  Col-name[233]=   'HY':U
  Col-name[234]=   'HZ':U
  Col-name[235]=   'IA':U
  Col-name[236]=   'IB':U
  Col-name[237]=   'IC':U
  Col-name[238]=   'ID':U
  Col-name[239]=   'IE':U
  Col-name[240]=   'IF':U
  Col-name[241]=   'IG':U
  Col-name[242]=   'IH':U
  Col-name[243]=   'II':U
  Col-name[244]=   'IJ':U
  Col-name[245]=   'IK':U
  Col-name[246]=   'IL':U
  Col-name[247]=   'IM':U
  Col-name[248]=   'IN':U
  Col-name[249]=   'IO':U
  Col-name[250]=   'IP':U
  Col-name[251]=   'IQ':U
  Col-name[252]=   'IR':U
  Col-name[253]=   'IS':U
  Col-name[254]=   'IT':U
  Col-name[255]=   'IU':U
  Col-name[256]=   'IV':U
  .
 end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable mm               as integer   no-undo .
define variable ll               as integer   no-undo .
define variable icolumn          as integer   no-undo .
define variable ccolumn          as character no-undo .
define variable crange           as character no-undo .
define variable crange2          as character no-undo .
define variable allcol           as integer   no-undo .
define variable colrule          as character no-undo .
define variable linerule         as character no-undo .
define variable ii               as integer   no-undo .
define variable kk               as integer   no-undo .
define variable lastsheet        as integer   no-undo .
define variable num-sheets       as integer   no-undo .
define variable real-num-sheets  as integer   no-undo .
define variable for-name         as character no-undo .
define variable cell-value       as character no-undo .
define variable ch#com-handle    as com-handle no-undo .
define variable ch#range         as com-handle no-undo .
define variable ch#columns       as com-handle no-undo .
define variable ch#sheets        as com-handle no-undo .
define variable ch#firstsheet    as com-handle no-undo .
define variable ch#zeroworkbook as com-handle no-undo .
define variable first-step       as logical   no-undo .
define variable current-address  as character no-undo .
define variable old-address      as character no-undo .
define variable current-row      as integer   no-undo .
define variable my-address       as character no-undo .
define variable my-address1      as character no-undo .
define variable found-next-sheet as logical   no-undo .
define variable tempfile-xls     as character no-undo .
define variable tempfile-frm     as character no-undo .
define variable tempfile-full    as character no-undo .
define variable my-excel         as logical   no-undo .
define variable is-open          as logical   no-undo .
define variable for-dir          as character no-undo .
define variable loc#log          as logical   no-undo .
define variable res              as character no-undo .
define variable p-param          as character no-undo .
define variable tempfile         as character no-undo .
define variable tempfile-n       as character no-undo .
define variable err-file         as character no-undo .
DEFINE VARIABLE v-ii             as integer no-undo .
DEFINE VARIABLE v-col-num        as integer no-undo .
DEFINE VARIABLE v-dec-separ      as character no-undo .
DEFINE VARIABLE v-th-separ       as character no-undo .
DEFINE VARIABLE v-module-lines   as integer   no-undo .
DEFINE VARIABLE v-ins-PostFormat as logical no-undo   .
DEFINE VARIABLE v-stroka         as character no-undo .
DEFINE VARIABLE v-call-bas       as logical no-undo .
DEFINE VARIABLE v-main-macro-lines as integer no-undo .
define variable v-excel-general-format as character no-undo .
define variable v-excel-short-date as character no-undo .
define variable v-excel-dec-separ as character no-undo .
define variable v-excel-th-separ as character no-undo .
define variable v-excel-date-separ as character no-undo .
define variable v-is-data-format as logical no-undo .
define variable v-col-format as character no-undo .
define variable v-zero-count as integer no-undo .
define variable v-workbook-name as character no-undo .
define variable v-worksheet-name as character no-undo .
define variable v-count as integer no-undo .
define variable v-version as character no-undo .
define variable v-version-dec as decimal no-undo .
define variable v-found-reg-entry as logical no-undo .
define variable v-trusted as character no-undo .
define variable v-bas-param-addition as character no-undo .
define variable v-silent-mode as logical   no-undo .
define stream forformat .
define stream BasStream.
function fieldinfo-datef returns character (input p-format  as character) FORWARD.
function compare-data-format returns logical (input p-format  as character, input p-ex-fi as character, output p-is-data as logical) FORWARD.
define buffer buf_sheetf for sheetf .
do
on error undo, return error return-value
:
  assign
    p-param = session :parameter
  .
  if num-entries(p-param) <> 5 then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный вызов процедуры форматирования EXCEL в дополнительной сессии PROGRESS" skip
      "Неверное количество параметров" num-entries(p-param) skip
      "Параметры" p-param skip
      view-as alert-box error.
    run write-err in this-procedure (input yes) .
    quit .
  end.
  assign
    tempfile       = entry(1, p-param)
    err-file       = entry(2, p-param)
    make-excel     = lookup(entry(3, p-param), "yes,true":U) > 0
    make-excel-com = lookup(entry(4, p-param), "yes,true":U) > 0
    tempfile-frm   = entry(5, p-param)
  .
  if make-excel <> true then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неверное значение параметра" "make-excel" skip
      "tempfile"        tempfile skip
      "err-file"        err-file skip
      "make-excel"      make-excel skip
      "make-excel-com"  make-excel-com skip
      "tempfile-frm"    tempfile-frm skip
      view-as alert-box error .
    run Write-err in this-procedure (input yes) .
    quit.
  end.
  if make-excel-com <> false then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неверное значение параметра" "make-excel-com" skip
      "tempfile"        tempfile skip
      "err-file"        err-file skip
      "make-excel"      make-excel skip
      "make-excel-com"  make-excel-com skip
      "tempfile-frm"    tempfile-frm skip
      view-as alert-box error .
    run Write-err in this-procedure (input yes) .
    quit.
  end.
  run make-sheetf in this-procedure no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при чтении параметров форматирования из файла" skip
      "Файл параметров форматирования" tempfile-frm skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    run Write-err in this-procedure (input yes) .
    quit.
  end.
  input stream forformat close.
  if make-excel = true then do:
    if make-excel-com = false then do:
      define variable v-full-path        as character no-undo .
      define variable v-path             as character no-undo .
      define variable v-file-name        as character no-undo .
      define variable v-file-name-no-ext as character no-undo .
      define variable v-file-name-ext    as character no-undo .
      run gbl/filename.p
        (input  tempfile
        ,output v-full-path
        ,output v-path
        ,output v-file-name
        ,output v-file-name-no-ext
        ,output v-file-name-ext
        ) .
      assign
        tempfile-xls   = v-file-name-no-ext + '.':u + 'xls':u
        for-dir        = ""
      .
      find first buf_sheetf
        where buf_sheetf.sheet-num = 1
      no-error .
      if available buf_sheetf
      then do:
        if buf_sheetf.silent-save = yes
        then do:
          assign
            tempfile-xls  = buf_sheetf.file-name
            loc#log       = yes
            v-silent-mode = yes
          .
        end.
        else do:
          run gbl/d-file.p
            (input-output tempfile-xls
            ,input-output for-dir
            ,input  (" Все файлы EXCEL (*.xls) ")
            ,input  ("*.xls":U)
            ,input  chr(44)
            ,input  (".xls":U)
            ,input  no
            ,input  yes
            ,input  yes
            ,input  "Введите имя файла"
            ,output loc#log
            ) .
        end.
      end.
      else do:
        run gbl/d-file.p
          (input-output tempfile-xls
          ,input-output for-dir
          ,input  (" Все файлы EXCEL (*.xls) ")
          ,input  ("*.xls":U)
          ,input  chr(44)
          ,input  (".xls":U)
          ,input  no
          ,input  yes
          ,input  yes
          ,input  "Введите имя файла"
          ,output loc#log
          ) .
      end.
      if not loc#log then do:
        run write-err in this-procedure (input no) .
        quit.
      end.
      run waitfram-show in this-procedure ("Ждите! Идет форматирование файла...").
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#ExcelApplication) then
RELEASE OBJECT ch#ExcelApplication no-error.
      CREATE "Excel.Application" ch#ExcelApplication no-error.
      my-excel = yes.
      if error-status:error then DO:
        run clearexcel in this-procedure .
        run write-err in this-procedure (input yes) .
        run write-err in this-procedure (input yes) .
        quit.
      End.
      assign
      ch#ExcelApplication:Interactive = no
      ch#ExcelApplication:ScreenUpdating = no
      ch#ExcelApplication:Visible = no
      v-version = ch#ExcelApplication:version
      no-error
      .
      assign
      v-version-dec = decimal(v-version)
      no-error .
      if error-status:error then do:
        message
        "Не удалось определить версию Excel"
        view-as alert-box error .
        run clearexcel in this-procedure .
        run write-err in this-procedure (input yes) .
        run write-err in this-procedure (input yes) .
        quit.
      end.
      if v-version-dec > 9 then do:
        run gbl/getregvl.p
                        ( "HKEY_CURRENT_USER":U
                        , "SOFTWARE":U
                        , "Microsoft\Office\" + string(v-version-dec, ">9.9":U) + "\Excel\Security":U
                        , "AccessVBOM":U
                        , output v-found-reg-entry
                        , OUTPUT v-trusted) no-error .
        if error-status:error then do:
          message
          "Не удалось определить политику безопасности для данной версии Excel"
          view-as alert-box error .
          run clearexcel in this-procedure .
          run write-err in this-procedure (input yes) .
          run write-err in this-procedure (input yes) .
          quit.
        end.
        if not v-found-reg-entry
        or trim(v-trusted) = "0":U then do:
          message
          "На Вашей машине запрещен программный доступ к VisualBasicProject" skip
          "В связи с этим вывод в EXCEL невозможен" skip
          "возможное решение проблемы:" skip
          "открыть в EXCEL диалог <Сервис\Макрос\Безопасность> (<Tools\Macro\Security>)" skip
          "выбрать закладку <Надежные источники> (<Trusted Sources>)  и включить галочку" skip
          "<Доверять доступ Visual Basic Project> (<Trust access to Visual Basic Project>)" skip
          "Затем закрыть Excel"
          view-as alert-box ERROR.
          run clearexcel in this-procedure .
          run write-err in this-procedure (input yes) .
          run write-err in this-procedure (input yes) .
          quit.
        end.
      end.
      assign
      v-excel-general-format =  ch#ExcelApplication:International(26  )
      v-excel-short-date =  ch#ExcelApplication:International(32  )
      v-excel-dec-separ = ch#ExcelApplication:International(3  )
      v-excel-th-separ = ch#ExcelApplication:International(4  )
      v-excel-date-separ = ch#ExcelApplication:International(17  )
      no-error
      .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Workbook) then
RELEASE OBJECT ch#Workbook no-error.
      case SESSION:NUMERIC-FORMAT:
        when "American":U then do:
          assign
          v-dec-separ = ".":U
          v-th-separ = "":U
          .
        end.
        when "European":U then do:
          assign
          v-dec-separ = ",":U
          v-th-separ = "":U
          .
        end.
      END CASE.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Workbook) then
RELEASE OBJECT ch#Workbook no-error.
      ch#Workbook  = ch#ExcelApplication:Workbooks:add.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#zeroworkbook) then
RELEASE OBJECT ch#zeroworkbook no-error.
      assign
      v-zero-count = ch#ExcelApplication:Workbooks:Count()
      ch#zeroworkbook  = ch#ExcelApplication:Workbooks:Item(v-zero-count)
      .
      assign
      num-sheets = 0
      .
      _sheets:
      DO WHILE num-sheets < 257:
        assign
        num-sheets = num-sheets + 1
        .
        FIND FIRST  sheetf no-lock where
                    sheetf.sheet-num = num-sheets no-error.
        if num-sheets = 1 and not available sheetf then do:
          FIND FIRST  sheetf no-lock where
                      sheetf.sheet-num = 0 no-error.
        end.
        if not available sheetf then NEXT _sheets.
        if num-sheets > 1 then do:
          assign
          tempfile-n = right-trim(tempfile, "txt":U)
          tempfile-n = right-trim(tempfile-n, ".")
          tempfile-n = tempfile-n + ".":U + string(num-sheets)
          .
        end.
        else do:
          assign
          tempfile-n = tempfile
          .
        end.
        assign
        v-stroka = entry(1, sheetf.ColFOrmat, chr(4))
        .
        v-stroka = trim(v-stroka, ";":U) .
        do v-ii = 1 to num-entries(v-stroka, ";":U):
          assign
          v-col-num = integer(entry(1, entry(v-ii, v-stroka, ";":U), "=":U))
          Col-Format[v-col-num] = entry(2, entry(v-ii, v-stroka, ";":U), "=":U)
          .
        end.
        if search(tempfile-n) = ?
        or (avail sheetf and sheetf.Sizes = "":U)
        then NEXT _sheets.
        assign
        real-num-sheets = real-num-sheets + 1
        .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#zeroworkbook) then
RELEASE OBJECT ch#zeroworkbook no-error.
        assign
        ch#zeroworkbook = ch#ExcelApplication:Workbooks:Item(v-zero-count)
        .
        ch#zeroworkbook:activate().
        run OpenFileFromtMacro in this-procedure ( input tempfile-n
                                                  ,input v-dec-separ) no-error .
        if error-status:error then do:
          run clearexcel in this-procedure .
          run write-err in this-procedure (input yes) .
          run write-err in this-procedure (input yes) .
          quit.
        end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Workbook) then
RELEASE OBJECT ch#Workbook no-error.
        assign
        ch#Workbook  = ch#ExcelApplication:Workbooks:Item(v-zero-count + 1)
        .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Sheets) then
RELEASE OBJECT ch#Sheets no-error.
        ch#sheets = ch#ExcelApplication:Sheets.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#WorkSheet) then
RELEASE OBJECT ch#WorkSheet no-error.
        ch#WorkSheet = ch#SHeets:Item (1) no-error .
        for-name = ch#Sheets:Item(1):Name.
        ch#Sheets:Item(1):Name= string(num-sheets).
        lastsheet = ch#Sheets:Count().
        run InsertMacroExcel .
        my-address = col-name[1] + string(1).
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Range) then
RELEASE OBJECT ch#Range no-error.
        assign
        ch#Range = ch#WorkSheet:Range (my-address)
        cell-value  = ch#Range:value.
        if not avail sheetf and NOT
        (cell-value = "&&&":U OR
        cell-value = ? OR cell-value = "")
        then do:
          message vss-workfile vss-revision vss-description skip
                  "Отсутствуют параметры форматирования для листа " num-sheets "книги Excel" cell-value
          view-as alert-box ERROR.
          run ClearExcel in this-procedure .
          run Write-err in this-procedure (input yes) .
          quit.
        end.
        if num-entries(sheetf.COlFOrmat, chr(4)) > 1 then do:
          assign
          v-stroka = entry(2, sheetf.ColFOrmat, chr(4))
          .
          if not v-ins-PostFormat then do:
            run InsertPostFormatting in this-procedure (output v-module-lines) no-error .
            if not error-status:error then
            assign
            v-ins-PostFormat = yes
            .
          end.
          do v-ii = 1 to num-entries(v-stroka, ";":U):
            assign
            v-col-num = integer(entry(1, entry(v-ii, v-stroka, ";":U), "=":U))
            Col-Post-Format[v-col-num] = entry(2, entry(v-ii, v-stroka, ";":U), "=":U)
            .
          end.
        end.
        AllCol = NUM-ENTRIES(sheetf.Sizes) - 1 no-error.
        ch#WorkSheet:Cells:SpecialCells(11 ):Activate().
        iF  AllCol > 0 THEN DO:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Range) then
RELEASE OBJECT ch#Range no-error.
          assign
          ch#range = ch#WorkSheet:Range ("A1")
          ch#Range:Font:Bold = TRUE .
          ch#Range:Font:Size = 14   .
          ch#Range:HorizontalAlignment = -4131 .
          ch#Range:VerticalAlignment   = -4160  .
          do ll = 1 TO  NUM-ENTRIES(Sheetf.Sizes) :
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#COlumns) then
RELEASE OBJECT ch#COlumns no-error.
            if Col-Format[ll] = ?
            OR Col-Format[ll] = "":U then do:
              assign
              v-col-format = v-excel-general-format
              .
            end.
            else do:
              if compare-data-format(COl-format[ll], input v-excel-short-date, output v-is-data-format)
              OR not v-is-data-format then do:
                assign
                v-col-format = Col-Format[ll]
                .
                if v-col-format begins "0.0" then do:
                  v-col-format = replace(v-col-format, ".", v-excel-dec-separ).
                end.
              end.
              else do:
                assign
                v-col-format = ?
                .
              end.
            end.
            Assign
            ch#COlumns = ch#WorkSheet:Columns (Col-name[LL])
            ch#Columns:ColumnWidth  = min(120, Integer(Entry(LL,Sheetf.Sizes)))
            .
            if v-col-format <> ? then
            assign
            ch#Columns:NumberFormat = v-col-format
            no-error.
            if Integer(Entry(LL,Sheetf.Sizes)) > 50 then do:
              assign
              ch#Columns:WrapText = true
              no-error.
            end.
            if Col-Post-Format[ll] <> ?
            AND Col-Post-Format[ll] <> "":U
            then do:
              if v-ins-PostFormat then do:
                assign
                ch#zeroworkbook  = ch#ExcelApplication:Workbooks:Item(v-zero-count)
                .
                v-count = ch#ExcelApplication:Workbooks:Count.
                v-worksheet-name = ch#WorkSheet:Name.
                v-workbook-name = ?.
                assign
                v-workbook-name = ch#ExcelApplication:Workbooks:Item(v-count):Name
                no-error
                .
                if v-workbook-name <> ? then do:
                  ch#zeroWorkbook:PostF(v-workbook-name, v-worksheet-name, Sheetf.Excel-Row-Heder, ll, chr(4), COl-Post-Format[ll]) .
                end.
              end.
            end.
            assign
            col-format[ll] = ?
            col-Post-Format[ll] = ?
            .
          End.
          if Sheetf.Bas-Param-Add = yes
          then do:
            assign
              v-count              = ch#ExcelApplication:Workbooks:Count
              v-bas-param-addition = chr(4) + ch#ExcelApplication:Workbooks:Item(v-count):Name
            .
          end.
          else do:
            assign
              v-count              = ch#ExcelApplication:Workbooks:Count
              v-bas-param-addition = "":U
            .
          end.
          do LL = 1 TO Sheetf.Excel-Row-Heder - 1 :
            cRange = "A" + String(LL) + chr(58) + Col-name[AllCol + 1] + string(LL) no-error.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Range) then
RELEASE OBJECT ch#Range no-error.
            assign
            ch#Range = ch#WorkSheet:Range (cRange)
            ch#Range:Numberformat = ch#ExcelApplication:International(26)
            ch#range:MergeCells = True no-error.
            if LL > 1 Then DO:
              ch#Range:Font:Bold = false no-error.
              ch#Range:Font:Size = 10    no-error.
              ch#Range:HorizontalAlignment = -4131  no-error.
              ch#Range:VerticalAlignment = -4160     no-error.
            End.
          End.
          if sheetf.MergeCellsH = "" AND sheetf.mergecellsV = "" then do:
            do MM = Sheetf.Excel-Row-Heder TO Sheetf.Excel-Row-Heder + Sheetf.Excel-Row-Title - 2 :
              do ll = 2 TO ALLCOL :
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Range) then
RELEASE OBJECT ch#Range no-error.
                assign
                ch#range = ch#WorkSheet:Range (Col-name[LL] + STRING(MM)).
                IF  ch#range:value = "" THEN DO:
                  ch#Range :value = ? .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Range) then
RELEASE OBJECT ch#Range no-error.
                  assign
                  ch#range = ch#WorkSheet:Range (Col-name[LL - 1] + STRING(MM) + chr(58) + Col-name[LL] + STRING(MM))
                  ch#range:MergeCells = True no-error.
                End.
              END.
            End.
            If Sheetf.Excel-Row-Title > 1 Then DO:
              do MM = Sheetf.Excel-Row-Heder + 1 TO Sheetf.Excel-Row-Heder + Sheetf.Excel-Row-Title - 1 :
                do ll = 1 TO ALLCOL :
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Range) then
RELEASE OBJECT ch#Range no-error.
                  assign
                  ch#range = ch#WorkSheet:Range (Col-name[LL] + STRING(MM)).
                  IF  ch#range:value = ""
                      OR ch#Range:value = ?  THEN DO :
                    ch#Range:value =  ?  no-error.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Range) then
RELEASE OBJECT ch#Range no-error.
                    assign
                    ch#range = ch#WorkSheet:Range (Col-name[LL] + STRING(MM) + chr(58) + Col-name[LL] + STRING(MM - 1))
                    ch#range:MergeCells = True no-error.
                  End.
                End.
              End.
            End.
          END.
          ELSE DO:
            do MM = 1 TO Num-entries(Sheetf.MergeCellsH, chr(47)) :
              linerule = ENTRY(MM, sheetf.MergeCellsH, chr(47)).
              do LL = 1 to NUM-entries(linerule):
                colrule = ENTRY(ll, linerule).
                do ii = 1 to int(ENTRY(2, colrule, chr(58))) - int(ENTRY(1, colrule, chr(58))):
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Range) then
RELEASE OBJECT ch#Range no-error.
                  assign
                  ch#range = ch#WorkSheet:Range (Col-name[int(entry(1, colrule, chr(58))) + ii] + STRING(MM + Sheetf.EXCEL-ROw-HEDER - 1) )
                  ch#range:value =  ?  no-error.
                end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Range) then
RELEASE OBJECT ch#Range no-error.
                assign
                ch#range =
                ch#WorkSheet:Range
                (COL-name[int(ENTRY(1, colrule, chr(58)))] + STRING(MM + Sheetf.EXCEL-ROw-HEDER - 1) +
                chr(58) +
                col-name[int(ENTRY(2, colrule, chr(58)))] + STRING(MM + Sheetf.EXCEL-ROw-HEDER - 1)
                )
                ch#range:MergeCells = True no-error
                .
              end.
            end.
            do ii = 1 to num-entries(Sheetf.MergeCellsV, chr(47)):
              assign
              colrule = entry(ii, Sheetf.MergecellsV, chr(47))
              LL = int(entry(1, colrule, "=":U))
              colrule = entry(2, colrule, "=":U)
              .
              do MM = 1 to int(entry(2,colrule, chr(58))) - int(entry(1,colrule, chr(58))):
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Range) then
RELEASE OBJECT ch#Range no-error.
                assign
                ch#range = ch#WorkSheet:Range (Col-name[ll] + STRING(int(entry(1,colrule, chr(58))) + MM + Sheetf.EXCEL-ROw-HEDER - 1) )
                ch#range:value =  ?  no-error.
              END.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Range) then
RELEASE OBJECT ch#Range no-error.
              assign
              ch#range =
              ch#WorkSheet:Range
              (COL-name[LL] + STRING(Sheetf.EXCEL-ROw-HEDER + int(entry(2,colrule, chr(58))) - 1) +
              chr(58) +
              col-name[LL] + STRING(Sheetf.EXCEL-ROw-HEDER + int(entry(1,colrule, chr(58))) - 1)
              )
              ch#range:MergeCells = True no-error.
            END.
          END.
          ASSIGN
          cRange = "A" + STRING(Sheetf.Excel-Row-Heder) + chr(58) + Col-name[AllCol + 1] + STRING(SHeetf.Excel-Row-Heder + SHeetf.Excel-Row-Title - 1).
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Range) then
RELEASE OBJECT ch#Range no-error.
          assign
          ch#range = ch#WorkSheet:Range (cRange)
          ch#range:Font:Bold = TRUE
          ch#Range:Interior:ColorIndex = 35
          ch#Range:HorizontalAlignment = -4108
          ch#Range:VerticalAlignment   = -4160
          ch#Range:WrapText = true
          ch#Range:Orientation = 0
          no-error.
          Assign
          ch#range:Borders(5):LineStyle = -4142
          ch#range:Borders(6):LineStyle   = -4142
          ch#range:Borders(7):LineStyle  = 1
          ch#range:Borders(7):Weight     = 2
          ch#range:Borders(7):ColorIndex = -4105
          ch#range:Borders(8):LineStyle  = 1
          ch#range:Borders(8):Weight     = 2
          ch#range:Borders(8):ColorIndex = -4105
          ch#range:Borders(9):LineStyle  = 1
          ch#range:Borders(9):Weight     = 2
          ch#range:Borders(9):ColorIndex = -4105
          ch#range:Borders(10):LineStyle  = 1
          ch#range:Borders(10):Weight     = 2
          ch#range:Borders(10):ColorIndex = -4105
          ch#range:Borders(11):LineStyle  = 1
          ch#range:Borders(11):Weight     = 2
          ch#range:Borders(11):ColorIndex = -4105 no-error.
          IF SHeetf.Excel-Row-Title > 1 THEN
          Assign
          ch#range:Borders(12):LineStyle  = 1
          ch#range:Borders(12):Weight     = 2
          ch#range:Borders(12):ColorIndex = -4105
          ch#WorkSheet:PageSetup:PrintTitleRows = cRange
          no-error
          .
        end.
        my-address = col-name[1] + chr(58) + col-name[2].
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#COlumns) then
RELEASE OBJECT ch#COlumns no-error.
        ch#Columns = ch#Sheets:Item (1):COLUMNS(my-address).
        ch#COLUMNS:Select().
        assign
        first-step =  yes
        current-address = ""
        old-address = ""
        MM = Sheetf.Excel-Row-Heder +  Sheetf.Excel-Row-Title
        MM = if MM = 0 then 1 else MM
        .
        do while true
        :
          if first-step then do:
            my-address1 = col-name[1] + string(MM).
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Range) then
RELEASE OBJECT ch#Range no-error.
            ch#range = ch#Sheets:Item(1):Range(my-address1).
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#COlumns) then
RELEASE OBJECT ch#COlumns no-error.
            ch#columns = ch#Sheets:Item (1):COLUMNS(my-address).
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#com-handle) then
RELEASE OBJECT ch#com-handle no-error.
            ch#com-handle =
            ch#columns:FIND(
            "ИТОГО",
            ch#range,
            - 4163,
            2,
            2,
            1
            ).
          end.
          else do:
            my-address1 = replace(current-address, "$":U, "").
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Range) then
RELEASE OBJECT ch#Range no-error.
            ch#range = ch#Sheets:Item(1):range(my-address1).
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#COlumns) then
RELEASE OBJECT ch#COlumns no-error.
            ch#columns = ch#Sheets:Item (1):COLUMNS(my-address).
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#com-handle) then
RELEASE OBJECT ch#com-handle no-error.
            ch#com-handle = 0.
            ch#com-handle =
            ch#columns:FIND(
            "ИТОГО",
            ch#range,
            - 4163,
            2,
            2,
            1
            ).
          end.
          if not valid-handle(ch#com-handle) then leave.
          assign
          current-address = ch#com-handle:address(yes, yes, 1).
          if current-address = old-address then LEAVE.
          if first-step then
          assign
          first-step = no
          old-address = current-address.
          current-row = integer(ENtry(3, current-address, "$":U)).
          ch#Sheets:Item (1):ROWS(current-row):Font:Bold = true.
        END.
        if num-entries(Sheetf.colformat, chr(4)) >= 3 then do:
          ch#Sheets:Item(1):name = entry(3, Sheetf.colformat, chr(4)).
        end.
        if Sheetf.Bas-FIle <> "":U then do:
          run RunMainMacros in this-procedure (Sheetf.Bas-file, Sheetf.Bas-Params) no-error .
        end.
        assign
        my-address = col-name[1] + chr(58) + col-name[1]
        my-address1 = col-name[1] + string(1)
        .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Range) then
RELEASE OBJECT ch#Range no-error.
        ch#range = ch#Sheets:Item(1):Range(my-address1).
        ch#range:select().
        if real-num-sheets = 1 then do:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#firstsheet) then
RELEASE OBJECT ch#firstsheet no-error.
          ch#firstsheet =  ch#Sheets:Item(1).
        end.
        else do:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#firstsheet) then
RELEASE OBJECT ch#firstsheet no-error.
          assign
          ch#firstsheet = ch#ExcelApplication:Workbooks:Item(v-zero-count + 1):sheets:item(1)
          .
          ch#Sheets:Item(1):Move( ,ch#firstsheet) no-error.
        end.
      END.
      ch#firstsheet:activate() no-error.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#zeroworkbook) then
RELEASE OBJECT ch#zeroworkbook no-error.
      assign
      ch#zeroworkbook  = ch#ExcelApplication:Workbooks:Item(v-zero-count).
      ch#zeroworkbook:Saved = yes.
      ch#zeroworkbook:close.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#zeroworkbook) then
RELEASE OBJECT ch#zeroworkbook no-error.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#firstsheet) then
RELEASE OBJECT ch#firstsheet no-error.
      num-sheets = ch#workbook:Sheets:Count().
      if v-ins-PostFormat then do:
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#zeroworkbook) then
RELEASE OBJECT ch#zeroworkbook no-error.
        assign
        ch#zeroworkbook  = ch#ExcelApplication:Workbooks:Item(v-zero-count)
        .
        ch#zeroWorkbook :VBProject :VBComponents :Item(1) :CodeModule:DeleteLines(1, v-module-lines) no-error.
      end.
      ch#ExcelApplication:DisplayAlerts = False.
      res = ch#Workbook:SaveAs( tempfile-xls, -4143 , , , , , ) NO-ERROR.
      ch#ExcelApplication:DisplayAlerts = True.
      if error-status:error then do:
        run ClearExcel in this-procedure .
        run Write-err in this-procedure (input yes) .
        quit.
      end.
      tempfile-full = ch#Workbook:FullName.
      if tempfile = tempfile-full or res = ? then do:
        message
          "Не удалось сохранить файл вывода " tempfile " в формате .XLS" skip
          "Возможно файл с именем " tempfile-xls " уже открыт ?" skip
          view-as alert-box error .
        ch#ExcelApplication:ActiveWorkbook:Saved = YES.
        ch#Workbook:Close.
        run ClearExcel in this-procedure .
        run Write-err in this-procedure (input yes) .
        quit.
      end.
      ch#ExcelApplication:Quit() no-error.
      run ClearExcel in this-procedure .
      PROCESS EVENTS.
      run waitfram-hide in this-procedure .
      run rep/killspac.p (input-output tempfile-full).
      if v-silent-mode = no
      then do:
        run gbl/open_url.p (tempfile-full) no-error .
      end.
    end.
  end.
  run write-err in this-procedure (input no) .
  quit.
  procedure ClearExcel :
    do
    on error undo, return error
    :
      run waitfram-hide in this-procedure .
      output Stream  ForExcel close.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#COlumns) then
RELEASE OBJECT ch#COlumns no-error.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Sheets) then
RELEASE OBJECT ch#Sheets no-error.
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Range) then
RELEASE OBJECT ch#Range no-error.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#com-handle) then
RELEASE OBJECT ch#com-handle no-error.
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#WorkSheet) then
RELEASE OBJECT ch#WorkSheet no-error.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Workbook) then
RELEASE OBJECT ch#Workbook no-error.
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#firstsheet) then
RELEASE OBJECT ch#firstsheet no-error.
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#zeroworkbook) then
RELEASE OBJECT ch#zeroworkbook no-error.
      if not my-excel or is-open then do:
        assign
        ch#ExcelApplication:Interactive    = true
        ch#ExcelApplication:ScreenUpdating = true
        ch#ExcelApplication:Visible        = true.
      end.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#ExcelApplication) then
RELEASE OBJECT ch#ExcelApplication no-error.
      PROCESS EVENTS.
    end.
  end procedure.
  procedure write-err :
    do
    on error undo, return error
    :
      define input parameter p-is-err as logical no-undo .
      run gbl/bat-err.p
        (input err-file
        ,input (if p-is-err then 1 else 0)
        ).
    end.
  end.
end.
procedure make-sheetf :
  do
  on error undo, return error return-value
  :
    define buffer buf_sheetf for sheetf .
    for each buf_sheetf
    on error undo, return error
    :
      delete buf_sheetf .
    end.
    input stream forformat from value( tempfile-frm ) .
    repeat
    :
      create buf_sheetf .
      import stream forformat buf_sheetf .
    end.
  end.
end procedure.
procedure InsertMacroExcel :
  do
  on error undo, return error
  :
  define variable chCodeModule as com-handle no-undo .
  define variable num-of-lines as integer no-undo .
  assign
    chCodeModule = ch#Workbook :VBProject :VBComponents :Item(1) :CodeModule
  .
  define variable v-ind     as integer no-undo .
  assign v-ind = 1 .
  assign
  num-of-lines = chCodeModule :CountOfLines.
  chCodeModule:DeleteLines(1, num-of-lines).
  chCodeModule :InsertLines(v-ind, 'Sub convdec(rowStart As long, colStart As Integer)                      ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '  dgChar = "0123456789-+' + v-delim + '"                                ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '  With ActiveSheet.Cells.SpecialCells(xlLastCell)  ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '    MaxRow = .Row                                  ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '    MaxCol = .Column                               ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '  End With                                         ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '  For Each curcell In Worksheets(1).Range(Worksheets(1).Cells(rowStart, colStart), Worksheets(1).Cells(MaxRow, MaxCol))  ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '      If Mid(curCell.Formula, 1, 1) = "=" Then                           ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '        If Mid(curCell.Formula, 2, 1) = """" And Mid(curCell.Formula, Len(curCell.Formula), 1) = """" Then       ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '          dg = Mid(curCell.Formula, 3, Len(curCell.Formula) - 3)         ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '          numPoint = 0                                                   ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '          numMinus = 0                                                   ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '          numPlus = 0                                                    ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '          For i = 1 To Len(dg)                                           ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '            flagExists = False                                           ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '            For j = 1 To Len(dgChar)                                     ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '              If Mid(dg, i, 1) = Mid(dgChar, j, 1) Then                  ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                If Mid(dg, i, 1) = "' + v-delim + '" Then                  ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                  If numPoint > 0 Then Exit For                          ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                  numPoint = 1                                           ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                End If                                                   ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                If Mid(dg, i, 1) = "-" Then                              ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                  If i > 1 Then Exit For                                 ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                  If numMinus > 0 Then Exit For                          ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                  numMinus = 1                                           ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                End If                                                   ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                If Mid(dg, i, 1) = "+" Then                              ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                  If i > 1 Then Exit For                                 ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                  If numPlus > 0 Then Exit For                           ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                  numPlus = 1                                            ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                End If                                                   ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                flagExists = True                                        ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                Exit For                                                 ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '              End If                                                     ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '            Next                                                         ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '            If Not flagExists Then Exit For                              ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '          Next                                                           ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '          If flagExists Then curCell.Value = dg + 0                      ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '        End If                                                           ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '      End If                                                             ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '  Next curCell                                                           ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, "'                                                                        " )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, 'End Sub                                                                  ' )  .
  ch#Workbook :convdec( 1, 2) .
  chCodeModule :DeleteLines(1, v-ind) .
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chCodeModule) then
RELEASE OBJECT chCodeModule no-error.
  end.
end procedure.
procedure OpenFileFromtMacro :
define input parameter p-filename as character no-undo .
define input parameter p-dec-separ as character no-undo .
  do
  on error undo, return error
  :
    DEFINE VARIABLE v-ii as integer no-undo .
    define variable chCodeModule as com-handle no-undo .
    define variable v-ind     as integer no-undo .
    DEFINE VARIABLE v-max-column-num as integer no-undo .
    define variable num-of-lines as integer no-undo .
      assign
      v-max-column-num = max(v-max-column-num, NUM-ENTRIES(sheetf.Sizes))
      .
    assign
    chCodeModule = ch#zeroWorkbook :VBProject :VBComponents :Item(1) :CodeModule
    no-error .
    if error-status:error then return error.
    assign v-ind = 1 .
    assign
    num-of-lines = chCodeModule :CountOfLines.
    chCodeModule:DeleteLines(1, num-of-lines).
    chCodeModule :InsertLines(v-ind, 'Sub MyOpen2(vfilename As String)                      ' )  .
    assign v-ind = v-ind + 1 .
    chCodeModule :InsertLines(v-ind, 'Workbooks.OpenText Filename:=vfilename, Origin:=xlWindows, ' +
                                    'StartRow:=1, DataType:=xlDelimited, TextQualifier:=xlDoubleQuote, ' +
                                    'ConsecutiveDelimiter:=False, Tab:=True, Semicolon:=False, Comma:=False, ' +
                                    'Space:=False, Other:=False, DecimalSeparator:=' + chr(34) + p-dec-separ +
                                      chr(34)  ).
    assign v-ind = v-ind + 1 .
    chCodeModule :InsertLines(v-ind, 'End Sub' )  .
    assign v-ind = v-ind + 1 .
    chCodeModule :InsertLines(v-ind, 'Sub MyOpen1(vfilename As String)                      ' )  .
    if v-max-column-num > 0 then do:
      assign v-ind = v-ind + 1 .
      chCodeModule :InsertLines(v-ind, 'Dim varray(1 To ' + string(v-max-column-num) + ') As Variant ').
      do v-ii = 1 to v-max-column-num:
        assign v-ind = v-ind + 1 .
        chCodeModule :InsertLines(v-ind, 'varray(':U +
                                          string(v-ii) +
                                          ') = Array(' +
                                          string(v-ii) +
                                          ', ' +
                                          fieldinfo-datef(Col-Format[v-ii]) +
                                          ')'
                                  ).
      end.
      assign v-ind = v-ind + 1 .
      chCodeModule :InsertLines(v-ind, 'Workbooks.OpenText Filename:=vfilename, Origin:=xlWindows, ' +
                                      'StartRow:=1, DataType:=xlDelimited, TextQualifier:=xlDoubleQuote, ' +
                                      'ConsecutiveDelimiter:=False, Tab:=True, Semicolon:=False, Comma:=False, ' +
                                      'Space:=False, Other:=False, FieldInfo:=varray, DecimalSeparator:=' + chr(34) + p-dec-separ +
                                       chr(34)  ).
    end.
    else do:
      assign v-ind = v-ind + 1 .
      chCodeModule :InsertLines(v-ind, 'Call MyOpen2(vfilename) ' )  .
    end.
    assign v-ind = v-ind + 1 .
    chCodeModule :InsertLines(v-ind, 'End Sub' )  .
    assign v-ind = v-ind + 1 .
    chCodeModule :InsertLines(v-ind, 'Sub MyOpen(vfilename As String)                      ' )  .
    assign v-ind = v-ind + 1 .
    chCodeModule :InsertLines(v-ind, 'If CInt(Mid(Application.Version, 1, InStr(Application.Version, ".") - 1)) < 9 Then').
    assign v-ind = v-ind + 1 .
    chCodeModule :InsertLines(v-ind, 'Call MyOpen2(vfilename) ' )  .
    assign v-ind = v-ind + 1 .
    chCodeModule :InsertLines(v-ind, 'Else: Call MyOpen1(vfilename) ').
    assign v-ind = v-ind + 1 .
    chCodeModule :InsertLines(v-ind, 'End If ').
    assign v-ind = v-ind + 1 .
    chCodeModule :InsertLines(v-ind, 'End  Sub ').
    ch#zeroWorkbook :MyOpen( p-filename) .
    chCodeModule :DeleteLines(1, v-ind) .
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chCodeModule) then
RELEASE OBJECT chCodeModule no-error.
  end.
end procedure.
procedure InsertPostFormatting :
define output parameter p-lines as integer no-undo .
  do
  on error undo, return error
  :
  define variable chCodeModule as com-handle no-undo .
  define variable v-ind     as integer no-undo .
  define variable num-of-lines as integer no-undo .
  assign
  ch#zeroworkbook  = ch#ExcelApplication:Workbooks:Item(v-zero-count)
  chCodeModule = ch#ZeroWorkbook :VBProject :VBComponents :Item(1) :CodeModule
  no-error .
  if error-status:error then return error.
  assign v-ind = 1 .
  assign
  num-of-lines = chCodeModule :CountOfLines.
  chCodeModule:DeleteLines(1, num-of-lines).
  chCodeModule :InsertLines(v-ind, 'Sub PostF(vWorkbookName, vSheetname, vStartRow As Integer, vColumnNumber As Integer, vCutSymbol As String, vColumnFormat As String) ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, 'For ii = vStartRow To Workbooks(vWorkbookname).Sheets(vSheetname).Cells.SpecialCells(xlLastCell).Row ')  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, 'If Mid(Workbooks(vWorkbookname).Sheets(vSheetname).Cells(ii, vColumnNumber).Value, 1, 1) = vCutSymbol Then ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, 'Workbooks(vWorkbookname).Sheets(vSheetname).Cells(ii, vColumnNumber).NumberFormat = vColumnFormat ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, 'Workbooks(vWorkbookname).Sheets(vSheetname).Cells(ii, vColumnNumber).Value = Mid(Workbooks(vWorkbookname).Sheets(vSheetname).Cells(ii, vColumnNumber).Value, 2)' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, 'End If ')  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, 'Next ii ')  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, 'End Sub' )  .
  assign
  p-lines = v-ind
  .
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chCodeModule) then
RELEASE OBJECT chCodeModule no-error.
  end.
end procedure.
procedure RunMainMacros :
define input parameter p-bas-file as character no-undo .
define input parameter p-parameters as character no-undo .
define variable chCodeModule as com-handle no-undo .
define variable v-ind     as integer no-undo .
DEFINE VARIABLE v-str as character no-undo .
  do
  on error undo, return error
  :
  assign v-ind = 1 .
  assign
  p-bas-file = search(p-bas-file)
  .
  if p-bas-file = ? then do:
    return.
  end.
  input stream BasStream from value(p-bas-file) .
  assign
  chCodeModule = ch#Workbook :VBProject :VBComponents :Item(1) :CodeModule
  .
  assign v-ind = 1 .
  REPEAT:
    import stream BasStream unformatted
    v-str.
    chCodeModule :InsertLines(v-ind, v-str )  .
    assign v-ind = v-ind + 1 .
  END.
  input stream BasStream close.
  if Sheetf.Bas-Param-Add = yes
  then do:
    assign
      p-parameters = p-parameters + v-bas-param-addition
    .
  end.
  ch#Workbook:Main_Macros( p-parameters, chr(4) ).
  chCodeModule:DeleteLines(1, v-ind - 1) .
  if index(".b8s":U, p-bas-file)  > 0 then do:
  run gbl/fileattr.p
  (input p-bas-file
  ,input "readonly-clear"
  ) no-error .
  OS-delete value(p-bas-file).
  end.
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chCodeModule) then
RELEASE OBJECT chCodeModule no-error.
  end.
end procedure.
function fieldinfo-datef returns character(input p-format  as character):
define variable v-format as character no-undo init "1":U.
if p-format = "@" then do:
  return string(2).
end.
  assign
  v-format = replace(p-format, "/", "":U)
  v-format = replace(v-format, ".", "":U)
  v-format = replace(v-format, "dd", "d":U)
  v-format = replace(v-format, "mm", "m":U)
  v-format = replace(v-format, "yy", "y":U)
  v-format = replace(v-format, "yy", "y":U)
  .
  CASE v-format:
    when "MDY":U then return string(3).
    when "DMY":U then return string(4).
    when "YMD":U then return string(5).
    when "MYD":U then return string(6).
    when "DYM":U then return string(7).
    when "YDM":U then return string(8).
    otherwise return string(1).
  END CASE.
END FUNCTION.
function compare-data-format returns logical(input p-format as character
                                           ,  input p-excel-fi as character
                                           ,  output p-is-data as logical):
define variable v-ex-format-list as character no-undo init "MDY,DMY,YMD":U.
define variable v-ex-format as character no-undo .
define variable v-format as character no-undo.
define variable v-is-data-str as character no-undo .
assign
v-ex-format = entry(integer(p-excel-fi) + 1, v-ex-format-list)
.
assign
v-format = replace(p-format, "/", "":U)
v-format = replace(v-format, ".", "":U)
v-format = replace(v-format, "dd", "d":U)
v-format = replace(v-format, "mm", "m":U)
v-format = replace(v-format, "yy", "y":U)
v-format = replace(v-format, "yy", "y":U)
v-is-data-str = replace(v-format, "y", "":U)
v-is-data-str = replace(v-format, "m", "":U)
v-is-data-str = replace(v-format, "d", "":U)
p-is-data = (trim(v-is-data-str) = "":U)
.
return (v-format = v-ex-format).
END FUNCTION.
