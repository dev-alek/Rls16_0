block-level on error undo, throw.
define input parameter pHostCode                as integer no-undo .
define input parameter custom-par               as character     no-undo .
define input parameter pBorder                  as logical no-undo .
define input parameter pRas                     as logical no-undo .
define input parameter pPrint                   as logical no-undo .
define output parameter v-file-name-rep-htm     as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Чек-лист по закрытию смены в ТН".
define variable parparentproc        as widget-handle no-undo .
parparentproc = this-procedure .
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
function fnc-convert-dot-to-colon returns character
    (input p-data as decimal, input p-accur as character, input p-num as integer) forward.
function fnc-convert-dot-to-colon returns character
(input p-data as decimal, input p-accur as character, input p-num as integer):
    define variable result as character no-undo.
    define variable v-str-result as character no-undo.
    if p-data = ? then p-data = 0 .
    p-data = round(p-data, p-num).
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).
    return v-str-result.
END FUNCTION.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  stream PrnLibStream.
procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .
  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
    if NOT v-exist then
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.
    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .
  define variable v-report-name as character no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
    if p-is-stream then
    do:
      if p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then
    do:
      if p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.
end procedure.
procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .
  define variable glog as logical no-undo .
  do
    on error undo, return error
    :
    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then
    do:
      if p-is-append then
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else
    do:
      if p-is-append then
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
  run adm/shattri.p (
    input "get":U
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function breakstr returns character ( input        for-name    as character,
                                      input        line-length as integer,
                                      input-output line1       as character,
                                      input-output line2       as character ) :
  define variable ii as integer no-undo.
  if length( for-name ) > line-length then do:
    assign ii    = 1
           line1 = "":u
           line2 = "":u.
    if length( entry( ii, for-name , " ":u ) ) > line-length then do:
      assign line1 =       substring( for-name, 1, line-length     )
             line2 = trim( substring( for-name,    line-length + 1 ) ).
    end.                                                     else do:
      do while length( line1 + entry( ii, for-name, " ":u ) ) < ( line-length + 1 ) :
        assign line1 = line1 + entry( ii, for-name, " ":u ) + " ":u
               ii    = ii    + 1.
        if length( entry( ii, for-name, " ":u ) ) > line-length then do:
          assign line1 = line1 + substring( for-name, length( line1 ), line-length - length( line1 ) + 1 ).
        end.
      end.
      assign line2 = trim( substring( for-name, length( line1 ) ) ).
    end.
  end.                                else do:
    assign line1 = for-name
           line2 = "":u.
  end.
  return ( line1 ).
end function.
define buffer buf_shiftParam    for ub.shift-param .
define buffer buf_shop          for ub.shop .
define buffer buf_clients       for ub.clients .
define buffer bf_shift-obj     for ub.shift-obj .
define buffer buf_goods         for ub.goods .
define buffer buf_usser-account for ub.user-account .
define buffer buf_rvs-line      for ub.rvs-line .
define buffer buf_rvs-doc       for ub.rvs-doc .
define buffer buf_susp-chk      for ub.susp-chk .
define variable p-report-id          as character no-undo .
define variable v-nn3                as integer   no-undo .
define variable Jv                   as integer   no-undo .
define variable userName             as character no-undo .
define variable rep-shift-for-mng    as character no-undo format "X(30)":U .
define variable rep-shift-for-mng1   as character no-undo format "X(30)":U .
define variable rep-shift-for-mng2   as character no-undo format "X(30)":U .
define variable rep-shift-for-opers  as character no-undo.
define variable rep-shift-for-opers1 as character no-undo format "X(44)":U .
define variable rep-shift-for-opers2 as character no-undo format "X(44)":U .
define variable v-nameHost           as character no-undo .
define variable dev-paid-trans       as decimal   no-undo .
define variable prc-dev-mass         as decimal   no-undo .
define variable X-OBJ-CODE as integer no-undo .
define variable X-OBJ-TYPE as character no-undo .
define stream Out-Stream.
define stream OutStr-html.
FUNCTION get-pay RETURNS CHARACTER
    ( input parpay-code as integer,  input parcurr-code as integer, output parcurr-name as character)  FORWARD.
function pr-objname returns character
    (input p-obj-code as integer ) forward.
function Str-chk-type returns character
    (input p-chk-type as character) forward .
v-nn3 = NUM-ENTRIES(custom-par).
REPEAT Jv = 1 to v-nn3:
    if CAPS(trim(Entry(Jv,custom-par))) begins "X-DATE-START"      then  X-DATE-START  = date(Entry(2,Entry(Jv,custom-par ),"="))  .
    if CAPS(trim(Entry(Jv,custom-par))) begins "X-OBJ-CODE"        then  X-OBJ-CODE    = int(Entry(2,Entry(Jv,custom-par ),"=")) .
    if CAPS(trim(Entry(Jv,custom-par))) begins "X-SHIFT-START"     then  X-Shift-Start = int(Entry(2,Entry(Jv,custom-par ),"=")) .
    if CAPS(trim(Entry(Jv,custom-par))) begins "X-OBJ-TYPE"        then  X-OBJ-TYPE    = (Entry(2,Entry(Jv,custom-par ),"=")) .
End.
X-OBJ-TYPE = trim (X-OBJ-TYPE," ") .
define variable ii                  as integer   no-undo .
run get-report-num (output p-report-id).
v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".
output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
put stream OutStr-html unformatted
    "<!DOCTYPE HTML>" skip
    ' <html>' skip
    '  <head>' skip
    '   <meta charset="utf-8">' skip
    '    <style type="text/css">' skip
    '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
    '   </style>' skip
    '  </head>' skip
    .
.
find first ub.clients no-lock where ub.clients.obj-code = pHostCode and ub.clients.obj-type = 'орг':U no-error .
if available (ub.clients) then v-nameHost = ub.clients.obj-name .
put stream OutStr-html unformatted
    '<body>' skip
    '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
    .
put stream OutStr-html unformatted
    '<tr class="set_columns">' skip
    '<td style="width: 200px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 350px;"></td>' skip
    '</tr>' skip
    .
find first bf_shift-obj no-lock where bf_shift-obj.obj-code = X-OBJ-CODE and
bf_shift-obj.obj-type = X-OBJ-TYPE and
bf_shift-obj.shift-date = date(X-Date-Start) and
bf_shift-obj.Shift-num = X-Shift-Start no-error .
if not available (bf_shift-obj) then return error.
find first buf_usser-account no-lock where buf_usser-account.user-id = bf_shift-obj.close-id no-error .
if available (buf_usser-account) then
do:
    userName = "АЗК №" + string(bf_shift-obj.obj-code) + chr(10) + "Документ подписан ID - " + entry(2,buf_usser-account.user-id,"-") + chr(10) + chr(10) +
        buf_usser-account.last-name + chr(10) + buf_usser-account.first-name + chr(10) + buf_usser-account.second-name .
end.
put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="8" style="text-align: left;">АЗК №' + string(bf_shift-obj.obj-code) + ' </td>' skip
    '</tr>' skip
    .
put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="7" style="text-align: center; font-weight: bold;">Чек-лист по закрытию смены Trade House</td>' skip
    .
if pBorder then
    put stream OutStr-html unformatted
        '<td style="text-align: center; color:#7030a0; border-top: thick double #7030a0; border-left: thick double #7030a0; border-right: thick double #7030a0;">АЗК №' + string(bf_shift-obj.obj-code) + '</td>' skip
        '</tr>' skip
        .
else
    put stream OutStr-html unformatted
        '<td>АЗК №' + string(bf_shift-obj.obj-code) + '</td>' skip
        '</tr>' skip
        .
if pRas then do:
put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="7" style="text-align: center; font-weight: bold;">смена закрыта с расхождениями</td>' skip
    .
end.
else do:
put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="7" style="text-align: center; font-weight: bold;">смена закрыта без расхождений</td>' skip
    .
end.
if pBorder then
    put stream OutStr-html unformatted
        '<td style="text-align: center; color:#7030a0; border-left: thick double #7030a0; border-right: thick double #7030a0;">Документ подписан ID - ' + entry(2,buf_usser-account.user-id,"-") + '</td>' skip
        '</tr>' skip
        .
else
    put stream OutStr-html unformatted
        '<td>Документ подписан ID - ' + entry(2,buf_usser-account.user-id,"-") + '</td>' skip
        '</tr>' skip
        .
put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="7" style="text-align: left;">Смена: ' + string(bf_shift-obj.shift-num) + ' от ' + string(bf_shift-obj.open-date,"99.99.9999") + " " + string(bf_shift-obj.open-time,"hh:mm") + '</td>' skip
    .
if pBorder then
    put stream OutStr-html unformatted
        '<td style="text-align: center; color:#7030a0; border-left: thick double #7030a0; border-right: thick double #7030a0;"></td>'
        '</tr>' skip
        .
else
    put stream OutStr-html unformatted
        '<td></td>' skip
        '</tr>' skip
        .
put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="7" style="text-align: left;">Закрыта: ' + string(bf_shift-obj.close-date,"99.99.9999") + " " + string(bf_shift-obj.close-time,"hh:mm") + '</td>' skip
    .
if pBorder then
    put stream OutStr-html unformatted
        '<td style="text-align: center; border-right: thick double #7030a0; border-left: thick double #7030a0; color:#7030a0;">' + buf_usser-account.last-name + '</td>'
        '</tr>' skip
        .
else
    put stream OutStr-html unformatted
        '<td>' + buf_usser-account.last-name + '</td>' skip
        '</tr>' skip
        .
FOR EACH ub.shift-staff No-LOCK WHERE
    ub.shift-staff.obj-type = bf_shift-obj.obj-type AND
    ub.shift-staff.obj-code = bf_shift-obj.obj-code AND
    ub.shift-staff.shift-date = bf_shift-obj.shift-date AND
    ub.shift-staff.shift-num  = bf_shift-obj.shift-num AND
    ub.shift-staff.next-shift = no AND
    ub.shift-staff.staff-role = yes and
    ub.shift-staff.psn-num    >= 0 :
    if lookup( chr(32) + ub.shift-staff.name, rep-shift-for-mng ) = 0 then
    do:
        assign
            rep-shift-for-mng = rep-shift-for-mng + (if rep-shift-for-mng > '' then chr(44) else "")  + ub.shift-staff.name
            .
    end.
end.
if rep-shift-for-mng > '' then
    assign
        rep-shift-for-mng1 = entry (1, rep-shift-for-mng, chr(44))
              no-error.
put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="7" style="text-align: left;">Старший смены: ' + rep-shift-for-mng1 + '</td>' skip
    .
if pBorder then
    put stream OutStr-html unformatted
        '<td style="text-align: center; border-right: thick double #7030a0; border-left: thick double #7030a0; color:#7030a0;">' + buf_usser-account.first-name + '</td>'
        '</tr>' skip
        .
else
    put stream OutStr-html unformatted
        '<td>' + buf_usser-account.first-name + '</td>' skip
        '</tr>' skip
        .
FOR EACH ub.shift-staff No-LOCK WHERE
    ub.shift-staff.obj-type   = bf_shift-obj.obj-type AND
    ub.shift-staff.obj-code   = bf_shift-obj.obj-code AND
    ub.shift-staff.shift-date = bf_shift-obj.shift-date AND
    ub.shift-staff.shift-num  = bf_shift-obj.shift-num AND
    ub.shift-staff.next-shift = no AND
    ub.shift-staff.staff-role = no and
    ub.shift-staff.psn-num    >= 0 :
    if lookup( chr(32) + ub.shift-staff.name, rep-shift-for-opers ) = 0 then
    do:
        assign
            rep-shift-for-opers = rep-shift-for-opers + (if rep-shift-for-opers > '' then chr(44) else "")  + ub.shift-staff.name
            .
    end.
end.
if rep-shift-for-opers > '' then
    assign
        rep-shift-for-opers1 = entry (1, rep-shift-for-opers, chr(44))
              no-error.
if num-entries (rep-shift-for-opers, chr(44)) >= 2 then
    assign
        rep-shift-for-opers2 = entry (2, rep-shift-for-opers, chr(44))
              no-error.
rep-shift-for-opers =  breakstr(rep-shift-for-opers, 44, input-output rep-shift-for-opers1, input-output rep-shift-for-opers2).
put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="7" style="text-align: left;">Операторы: ' + rep-shift-for-opers + '</td>' skip
    .
if pBorder then
    put stream OutStr-html unformatted
        '<td style="text-align: center; border-bottom: thick double #7030a0; border-right: thick double #7030a0; border-left: thick double #7030a0; color:#7030a0;">' + buf_usser-account.second-name + '</td>'
        '</tr>' skip
        .
else
    put stream OutStr-html unformatted
        '<td>' + buf_usser-account.second-name + '</td>' skip
        '</tr>' skip
        .
put stream OutStr-html unformatted
    '<tr style="height:25px;">' skip
    '<td colspan="8" style="text-align: left;"></td>' skip
    '</tr>' skip
    .
put stream OutStr-html unformatted
    '</thead>' skip .
put stream OutStr-html unformatted
    '<tbody>' skip
    '<TR style="height:55px;">' skip
    '<TD text_wrap="true" colspan="8" style="text-align: center; font-weight:bold;">Проверка отклонений по 1 части сменного отчета. Отклонение между расчетной и фактической массой топлива на конец смены.</TD>' skip
    '</tr>' skip
    '<tr>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Наименование</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">№ резервуара</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Расч. остаток на конец смены, кг</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Факт. остаток на конец смены, кг</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Допустимое отклонение, кг</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Факт. отклонение по остаткам, кг</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Превышение допустимого отклонения на, кг</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Причина расхождения/номер заявки в ЦДС</TD>' skip
    '</TR>'skip
    .
define variable v-error as decimal no-undo .
for each buf_shiftParam no-lock
    where buf_shiftParam.obj-code = bf_shift-obj.obj-code
    and buf_shiftParam.obj-type = bf_shift-obj.obj-type
    and buf_shiftParam.shift-date = bf_shift-obj.shift-date
    and buf_shiftParam.shift-num = bf_shift-obj.shift-num:
    find first buf_goods no-lock where buf_goods.gds-code = buf_shiftParam.gds-code no-error .
    if not available (buf_goods) then next .
    v-error = absolute(buf_shiftParam.dev-mass - buf_shiftParam.diff-stock-end).
    if buf_shiftParam.diff-stock-end <= v-error then v-error = 0 .
    put stream OutStr-html unformatted
        '<TR>' skip
        '<TD text_wrap="true">' + buf_goods.gds-name + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_shiftParam.loc1) + '</TD>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.system-cli-qnty,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.system-cli-qnty <> ? then fnc-convert-dot-to-colon(buf_shiftParam.system-cli-qnty,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.fact-stock-end,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.fact-stock-end <> ? then fnc-convert-dot-to-colon(buf_shiftParam.fact-stock-end,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.dev-mass,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.dev-mass <> ? then fnc-convert-dot-to-colon(buf_shiftParam.dev-mass,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.diff-stock-end,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.diff-stock-end <> ? then fnc-convert-dot-to-colon(buf_shiftParam.diff-stock-end,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(v-error,">>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if v-error <> ? then fnc-convert-dot-to-colon(v-error,">>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_shiftParam.disc-diffMass) + '</TD>' skip
        '</tr>' skip
        .
end.
v-error  = 0 .
find first buf_shiftParam no-lock where buf_shiftParam.obj-code = bf_shift-obj.obj-code and
    buf_shiftParam.obj-type = bf_shift-obj.obj-type and
    buf_shiftParam.shift-date = bf_shift-obj.shift-date and
    buf_shiftParam.shift-num = bf_shift-obj.shift-num and
    buf_shiftParam.gds-code = 0 and
    buf_shiftParam.pl-code = 0 no-error .
if available (buf_shiftParam) then
    assign
        dev-paid-trans = buf_shiftParam.dev-paid-trans
        prc-dev-mass   = buf_shiftParam.prc-dev-mass
        .
put stream OutStr-html unformatted
    '<thead>' skip
    '<TR  style="height:25px;">' skip
    '<TD text_wrap="true" colspan="8" style="text-align: left;">* Процент допустимого отклонения массы топлива = ' + string(prc-dev-mass,"9.99") + '%</TD>' skip
    '</tr>' skip
    '<TR  style="height:25px;">' skip
    '<TD text_wrap="true" colspan="8" style="text-align: left;"></TD>' skip
    '</tr>' skip
    '<TR  style="height:25px;">' skip
    '<TD text_wrap="true" colspan="8" style="text-align: left;"></TD>' skip
    '</tr>' skip
    '</thead>' skip
    .
put stream OutStr-html unformatted
    '<TR style="height:55px;">' skip
    '<TD text_wrap="true" height:25px; colspan="8" style="text-align: center; font-weight:bold;">Проверка отклонений по 9 части сменного отчета. Отклонения между объемом продаж топлива на кассе и объемом по счетчикам ТРК.</TD>' skip
    '</tr>' skip
    '<tr>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Наименование</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">№ резервуара</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Объем продаж на кассе, л</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Объем продаж по счетчикам ТРК, л</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Техпролив, л</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Разница по кассе и ТРК, л</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Превышение допустимого отклонения на, л</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Причина расхождения/номер заявки в ЦДС</TD>' skip
    '</TR>'skip
    .
for each buf_shiftParam no-lock
    where buf_shiftParam.obj-code = bf_shift-obj.obj-code
    and buf_shiftParam.obj-type = bf_shift-obj.obj-type
    and buf_shiftParam.shift-date = bf_shift-obj.shift-date
    and buf_shiftParam.shift-num = bf_shift-obj.shift-num
    :
    find first buf_goods no-lock where buf_goods.gds-code = buf_shiftParam.gds-code no-error .
    if not available (buf_goods) then next .
    v-error = absolute(buf_shiftParam.dev-paid-trans - buf_shiftParam.diff-cash-trk) .
    if dev-paid-trans >= v-error then v-error = 0 .
    put stream OutStr-html unformatted
        '<TR>' skip
        '<TD text_wrap="true">' + buf_goods.gds-name + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_shiftParam.loc1) + '</TD>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.cash-qnty,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.cash-qnty <> ? then fnc-convert-dot-to-colon(buf_shiftParam.cash-qnty,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.meas-qnty,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.meas-qnty <> ? then fnc-convert-dot-to-colon(buf_shiftParam.meas-qnty,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.tech-refuell,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.tech-refuell <> ? then fnc-convert-dot-to-colon(buf_shiftParam.tech-refuell,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.diff-cash-trk,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.diff-cash-trk <> ? then fnc-convert-dot-to-colon(buf_shiftParam.diff-cash-trk,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(v-error,">>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if v-error <> ? then fnc-convert-dot-to-colon(v-error,">>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_shiftParam.disc-diffTRK) + '</TD>' skip
        '</tr>' skip
        .
end.
put stream OutStr-html unformatted
    '<thead>' skip
    '<TR style="height:25px;">' skip
    '<TD text_wrap="true" colspan="8" style="text-align: left;">*Допустимое отклонение между объемом продаж топлива на кассе и объемом по счетчикам ТРК = ' + string(dev-paid-trans,"9.99") + 'л</TD>' skip
    '</tr>' skip
    '<TR style="height:25px;">' skip
    '<TD text_wrap="true" colspan="8" style="text-align: left;"></TD>' skip
    '</tr>' skip
    '<TR style="height:25px;">' skip
    '<TD text_wrap="true" colspan="8" style="text-align: left;"></TD>' skip
    '</tr>' skip
    '</thead>' skip
    .
put stream OutStr-html unformatted
    '<TR style="height:55px;">' skip
    '<TD text_wrap="true" colspan="8" style="text-align: center; font-weight:bold;">"Подозрительные" чеки.</TD>' skip
    '</tr>' skip
    '<tr>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Признак</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">№ чека в ТН</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Тип чека</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">№ чека на кассе</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">№ кассы</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Дата/время</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Причина возникновения чека</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Ссылка на "корректный" чек</TD>' skip
    '</TR>' skip
    .
for each buf_susp-chk no-lock
    where buf_susp-chk.obj-code = bf_shift-obj.obj-code
    and buf_susp-chk.obj-type = bf_shift-obj.obj-type
    and buf_susp-chk.shift-date = bf_shift-obj.shift-date
    and buf_susp-chk.shift-num = bf_shift-obj.shift-num:
    put stream OutStr-html unformatted
        '<TR>' skip
        '<TD text_wrap="true" style="text-align: center;">' + buf_susp-chk.office + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_susp-chk.doc-code) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + Str-chk-type(string(buf_susp-chk.chk-type)) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_susp-chk.chk-num) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_susp-chk.pay-desk) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_susp-chk.chk-date,"99.99.9999") + '/' + string(buf_susp-chk.chk-time,"hh:mm") + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_susp-chk.reason-name) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_susp-chk.link-chk) + '</TD>' skip
        '</tr>' skip
        .
end.
put stream OutStr-html unformatted
    '</tbody>' skip .
procedure pr-foot:
    put stream OutStr-html unformatted
        '</table>' skip
        '</body>' skip
        '</html>' skip
        .
end.
output stream OutStr-html close.
if pPrint then
do:
    run prn-lib-reportviewer in this-procedure (
        input this-procedure
        ,input v-file-name-rep-htm
        ,input ""
        ) no-error.
    if error-status:error then
    do:
        message return-value view-as alert-box.
        return .
    end.
end.
PROCEDURE get-report-num :
    define output parameter p-report-num as integer no-undo .
    do
        on error undo, return error return-value
        :
        run gbl/getrpnum.p (output p-report-num).
    end.
END PROCEDURE.
FUNCTION get-pay RETURNS CHARACTER
    ( input parpay-code as integer,  input parcurr-code as integer, output parcurr-name as character) :
    define variable varpay-name like ub.cash-pay.obj-name no-undo.
    run get-pay-proc in this-procedure (
        input  parpay-code
        ,input  parcurr-code
        ,output parcurr-name
        ,output varpay-name ).
    return varpay-name.
END FUNCTION.
FUNCTION pr-objname RETURNS character
    ( INPUT p-obj-code AS integer) :
    define variable v-obj-name as character no-undo .
    find first ub.clients no-lock where ub.clients.obj-code = p-obj-code and ub.clients.obj-type = 'маг':U no-error .
    if AVAILABLE (ub.clients) then v-obj-name = ub.clients.obj-name .
    RETURN v-obj-name.
END FUNCTION.
function Str-chk-type returns character
    (input p-chk-type as character):
    define variable v-num-element   as integer   no-undo.
    define variable p-name-chk-type as character no-undo .
    v-num-element = lookup(p-chk-type, '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,43,44':U).
    p-name-chk-type = entry(v-num-element, 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Приход_Корр,Расход_Корр':U).
    if p-chk-type <> "" and v-num-element = 0 then
    do:
        message "Ошибка 115." view-as alert-box.
    end.
    else return p-name-chk-type .
end function.
