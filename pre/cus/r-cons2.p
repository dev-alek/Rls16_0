block-level on error undo, throw.
define input parameter parParentProc  as widget-handle no-undo.
define input parameter c-rc as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-cons2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-cons2.p $":U .
define variable vss-description as character no-undo init " Совокупная заявка по товарам развернута  EXCEL   ".
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
define new shared variable gdsgrp_recids      as character no-undo.
define new shared variable fin-schet-recid    as character no-undo.
define new shared variable v-d-report-handle  as handle    no-undo .
define new shared temp-table g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define new shared temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define new shared temp-table tmp#grp no-undo
    field node-code like ub.gds-grp.node-code
    field grp-name like ub.gds-grp.node-name
    field lvl-num  like ub.gds-grp.lvl-num
    field is-term  like ub.gds-grp.is-term
    index pi is unique primary grp-name node-code
    index i-node-code    node-code
    index level-num   lvl-num  grp-name
    index is-term is-term  grp-name
    .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
new shared
temp-table  obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.
procedure create_obj-list :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_obj-list for obj-list .
      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list
      then
         p-var = buf_obj-list.obj-id + 1.
      else
         p-var = 1.
      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.
      if available cli-obj
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end.
end.
define new shared temp-table X-init_obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary obj-type obj-code.
define variable p1 like ub.gds-obj.prod-type no-undo.
define variable p2 like ub.gds-obj.prod-code no-undo.
define variable p3 like ub.gds-obj.artic     no-undo.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable var-report-r-b as character no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define NEW shared variable RepPathName        as character no-undo .
define NEW shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-account as integer init 0 no-undo .
define variable v-account-lavel as character no-undo .
define variable v-button-stop as logical no-undo .
define variable v-kol-spice as integer no-undo .
define variable v-kol-spice2 as integer no-undo .
define variable v-kol-spice3 as integer no-undo .
DEFINE VARIABLE StopProcessing AS LOGICAL NO-UNDO.
DEFINE BUTTON StopBtn AUTO-END-KEY
     LABEL "Стоп"
     SIZE 10 BY 1.
DEFINE VARIABLE RecordsDone AS INTEGER FORMAT ">,>>>,>>>,>>9":U INITIAL 0
     LABEL "Обработано записей"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE RecordsString AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString2 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString3 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 55.13 BY 4.46.
DEFINE FRAME InfoFrame
     StopBtn AT ROW 4.25 COL 21.75
     RecordsString AT ROW 1.21 COL 2 NO-LABEL
     RecordsString2 AT ROW 1.96 COL 2 NO-LABEL
     RecordsString3 AT ROW 2.58 COL 2 NO-LABEL
     RecordsDone AT ROW 3.42 COL 24.88 COLON-ALIGNED
     RECT-1 AT ROW 1 COL 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Процесс"
         DEFAULT-BUTTON StopBtn CANCEL-BUTTON StopBtn.
define variable mFrameView      as logical   no-undo init yes.
  define variable mFramHandle as handle no-undo.
  mFramHandle = frame InfoFrame:handle.
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramHandle:visible), "frameRepError").
  end.
  mFrameView = not session:batch-mode and mFramHandle:visible.
  if mFrameView
  then do:
    ASSIGN
       FRAME InfoFrame:HIDDEN                           = TRUE
       StopBtn:sensitive IN FRAME InfoFrame             = TRUE.
  end.
ON CHOOSE OF StopBtn IN FRAME InfoFrame
DO:
  IF not StopProcessing THEN
    Message "Вы действительно хотите прервать" SKIP
            "процесс проверки?" view-as alert-box QUESTION BUTTONS yes-no
              UPDATE StopProcessing.
  IF StopProcessing THEN do:
     if mFrameView
     then do:
        HIDE FRAME InfoFrame.
     end.
  End.
END.
function excel-format-dec-to-char returns char (input p-dec as decimal ).
  if num-entries(string(p-dec), '.') = 2
    then return( entry(1, string(p-dec), '.') + v-delim + entry(2, string(p-dec), '.')) .
    else return( string(p-dec)) .
end function.
function format-point-to-comma returns char (input orig as char ) .
define variable rtext as character no-undo .
define variable strt as integer no-undo .
define variable leng as integer no-undo .
assign rtext = orig .
repeat:
  strt =  index(rtext,'.').
  if strt = 0 then leave.
  leng = 1.
  substring(rtext,strt,leng,"character") = v-delim .
end.
return rtext.
end function.
function format-excel-text returns char ( input start-text as char ) :
def var  i    as int no-undo.
def var  ch   as char no-undo.
def var  n    as int no-undo.
def var  ipos as int no-undo.
  n = num-entries(trim(start-text), chr(10)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(10)).
    if ipos > 0 then
      substr( start-text, ipos, 1 ) = ' '.
  end.
  n = num-entries(trim(start-text), chr(13)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(13)).
    if ipos > 0 then
      substr( start-text, ipos, 1 ) = ' '.
  end.
  if index( start-text, '"' ) = 0 then
    start-text =  '="'   + trim( start-text) + '"'   .
    else do:
      n = num-entries(trim(start-text), '"') - 1.
      do i = 1 to n :
        ch = ch + entry(i,trim(start-text), '"' ) + '""'.
      end.
      ch = ch + entry(num-entries(trim(start-text), '"'),trim(start-text), '"' ).
      start-text = '="'  + ch  + '"' .
    end.
  return start-text.
end.
function excel-sum returns char (input p-dec as decimal ).
  return(format-excel-text(excel-format-dec-to-char(round(p-dec,2)))) .
end function.
function excel-qnty returns char (input p-dec as decimal ).
  return(format-excel-text(excel-format-dec-to-char(round(p-dec,3)))) .
end function.
function format-excel-text-macr returns char ( input start-text as char ) :
def var  i    as int no-undo.
def var  ch   as char no-undo.
def var  n    as int no-undo.
def var  ipos as int no-undo.
  n = num-entries(trim(start-text), chr(10)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(10)).
    if ipos > 0 then
      substring( start-text, ipos , 1 ) = ' '.
  end.
  n = num-entries(trim(start-text), chr(13)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(13)).
    if ipos > 0 then
      substring( start-text, ipos, 1 ) = ' '.
  end.
  if index( start-text, '"' ) = 0 then
    start-text =  '"'   + trim( start-text) + '"'   .
    else do:
      n = num-entries(trim(start-text), '"') - 1.
      do i = 1 to n :
        ch = ch + entry(i,trim(start-text), '"' ) + '""'.
      end.
      ch = ch + entry(num-entries(trim(start-text), '"'),trim(start-text), '"' ).
      start-text = '"'  + ch  + '"' .
    end.
  n = num-entries(trim(start-text), chr(10)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(10)).
    if ipos > 0 then
      substring( start-text, ipos , 1 ) = ' '.
  end.
    if num-entries(trim(start-text), chr(10)) > 1 then  message num-entries(trim(start-text), chr(10)) start-text.
  return start-text.
end.
def var vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-param no-undo   field param-code     as character   field param-sub-code as character   field param-value    as character   index xpk is primary unique param-code param-sub-code   .
procedure paramls-clear :
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    for each buf_temp-param
    on error undo, return error
    :
      delete buf_temp-param .
    end.
  end.
end procedure.
procedure paramls-write :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
      .
    end.
    assign
      buf_temp-param.param-value = p-value
    .
  end.
end procedure.
procedure paramls-read :
  define input  parameter p-code          as character no-undo .
  define input  parameter p-sub-code      as character no-undo .
  define input  parameter p-default-value as character no-undo .
  define output parameter p-value         as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if available buf_temp-param then do:
      assign
        p-value = buf_temp-param.param-value
      .
    end.
    else do:
      assign
        p-value = p-default-value
      .
    end.
  end.
end procedure.
procedure paramls-append :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
         where buf_temp-param.param-code     = p-code
           and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
        buf_temp-param.param-value    = p-value
      .
    end.
    else do:
        assign
            buf_temp-param.param-value = buf_temp-param.param-value + ",":U + p-value
        .
    end.
  end.
end procedure.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable g#report-num as integer   no-undo .
run get-report-num  in parParentProc  ( output g#report-num ).
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable v-cntxt-host-name-obj as character no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-cntxt-host-code-obj
  ,output v-cntxt-host-name-obj
  )  .
define variable v-today as date      no-undo .
define variable v-time  as integer   no-undo .
define buffer bf_ord-cons for ub.ord-cons .
define buffer bf_ord-cons-gds for ub.ord-gds-cons .
define buffer bf_ord-doc for ub.ord-doc .
define buffer loc_ord-doc for ub.ord-doc.
define buffer loc_ord-line for ub.ord-line.
define buffer b-goods for ub.goods.
define buffer b_clients for ub.clients.
define buffer loc_ord-doc-rcv for ub.ord-doc-rcv.
define buffer loc_ord-line-rcv for ub.ord-line-rcv.
define buffer z_ord-doc for ub.ord-doc.
define buffer z_ord-line for ub.ord-line.
define variable l-ord-code as character no-undo .
define variable l-rcv-code as character no-undo .
define variable l-qnty-of   like ub.place.max-qnty no-undo .
define variable l-time-of   as integer no-undo .
define variable g-qnty-fp   like ub.place.max-qnty no-undo .
define variable l-qnty-fp   like ub.place.max-qnty no-undo .
define variable l-qnty-rcv  like ub.place.max-qnty no-undo .
define variable l-time-fp   as integer no-undo .
define variable l-time-rcv  as integer no-undo .
define variable l-cli-code  as character no-undo .
define variable l-cli-name  as character no-undo .
define variable ii      as integer no-undo .
define variable l-nn    as integer no-undo .
define variable kk      as integer no-undo .
define variable max-str as integer no-undo .
define variable old-l-ord-code as character no-undo .
define variable  s-qnty-of      as decimal no-undo .
define variable  s-qnty-fp      as decimal no-undo .
define variable  s-qnty-rcv     as decimal no-undo .
define temp-table temp-tt no-undo
field obj-type    like ub.clients.obj-type
field obj-name    like ub.clients.obj-name
field gds-code    like ub.goods.gds-code
field qnty-of     like ub.ord-line.qnty
field time-of     as char
field ord-code    as character
field qnty-fp     like ub.ord-line.qnty
field cli-cod     as character
field cli-name    as character
field rcv-code    as character
field time-rcv    as char
field qnty-rcv    like ub.ord-line.qnty
field nnn as integer
INDEX pi IS UNIQUE PRIMARY
  obj-type
  nnn
  gds-code
  ord-code
  rcv-code
      .
define temp-table temp-tt-host no-undo  like temp-tt .
define stream  instream  .
define stream  outstream  .
define stream  outstream2  .
make-excel-com = false .
make-excel     = true  .
define stream  macr_excel .
define variable v-file-name as character no-undo .
define variable p-file-name as character no-undo .
define variable v-ind       as integer   no-undo .
define variable C-c    as integer no-undo .
define variable C-str  as character no-undo .
define variable str--1 as character Format "x (60)" no-undo.
define variable str--2 as integer no-undo .
define variable C-i    as integer no-undo .
define variable p-var  as integer no-undo .
define variable num#col# as integer no-undo .
define variable var-1 as integer no-undo .
define variable var-2 as integer no-undo .
define variable var-3 as integer no-undo .
define variable is-l as integer no-undo .
FUNCTION excel-qnty-null RETURNS char  (INPUT p-dec as decimal ).
if p-dec = 0 then Return  ("").
   else RETURN (format-excel-text (excel-format-dec-to-char (Round (p-dec,3)))) .
END FUNCTION.
main-block :
do on error undo main-block, return error
:
find first  bf_ord-cons where recid (bf_ord-cons) = c-rc no-lock no-error .
for each  bf_ord-cons-gds no-lock  where bf_ord-cons-gds.cons-code = bf_ord-cons.cons-code :
 ii = ii + 1.
 if ii > 31 then leave.
end.
if ii > 31 then do:
    message "Отчет не может быть выполнен на такое количество товаров !  "
    skip
    "Воспользуйтесь отчетом 'Совокупная заявка по товарам ' "
    view-as alert-box error.
    return error.
end.
    p-file-name =  string ( session:temp-directory +
                                  "rpt" + string ( g#report-num ) + ".txt" ) .
    output stream outstream to value ( string ( session:temp-directory +
                                  "rpt" + string ( g#report-num ) ) )      .
    output stream outstream2 to value (p-file-name).
run gbl/_tmpfile.p  ( "wb", ".txt", output v-file-name) .
output stream macr_excel to value (v-file-name)   .
v-ind = 1    .
num#str# = 1 .
num#col# = 1 .
assign v-account = ( if integer( 50 ) = 0 then 100 else integer( 50 ) ).
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("ON mFrameView=" + string(mFrameView), "frameRepError").
  end.
  if not session:batch-mode then
  do:
    VIEW FRAME InfoFrame.
    mFrameView = true.
  end.
   v-button-stop = false .
      if mFrameView
      then do:
      if v-button-stop then view STOPBTN in frame InfoFrame.
                       else Hide STOPBTN in frame InfoFrame.
      end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output to-day
  )  .
Make-Excel = true .
reportname =  "Совокупная заявка по товарам по фирме № " +
              bf_ord-cons.cons-code + " от " +
              string (bf_ord-cons.doc-date,"99/99/9999") +
              " (развернутый формат)"
              .
reportheader =   cur-time-print () .
      run macr_excel_char_with_format  ( reportname , num#str# , num#col#  ).
      run macr_cell_format
           ( 12    ,
            true  ,
            false ,
            ?     ,
            num#str# ,
            num#col# ,
            ? ,
            ?         ) .
define variable l-ii  as integer no-undo .
define variable l-jj  as integer no-undo .
define variable l-len as integer no-undo .
define variable l-m   as integer no-undo .
define variable v-nn as integer   no-undo .
v-nn = num-entries ( reportheader , "chr(10)"  )  .   do l-ii = 1 to v-nn  :        l-len = length  (entry ( l-ii , reportheader  , "chr(10)")) .                       l-m = integer ( l-len / 220 ) + 1 .                                                      do l-jj = 1 to  l-m  :                                                                      num#str# = num#str# + 1 .                                                               run macr_excel_char_with_format  (                                                                        substring (entry ( l-ii , reportheader  , "chr(10)") ,  ( ( 220 * l-jj ) - 219 )  , 220 )  , num#str# , num#col# ) .      end.                                                                                                         end.
Sheetf.Excel-Column-Lable = "Код объекта ,Наименование объекта  ,".
Sheetf.Sizes = "8,20,".
for each  bf_ord-cons-gds no-lock  where bf_ord-cons-gds.cons-code = bf_ord-cons.cons-code,    first ub.goods where bf_ord-cons-gds.artic = ub.goods.artic                                               and bf_ord-cons-gds.prod-type = ub.goods.prod-type                                   and bf_ord-cons-gds.prod-code = ub.goods.prod-code no-lock :
     Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable + " Арт " + ub.goods.artic + "," + string (ub.goods.gds-name) + ",,,,,,," .
     Sheetf.Sizes = Sheetf.Sizes + Fill ("12,", 3) .
     Sheetf.Sizes = Sheetf.Sizes +  ("8,") .
     Sheetf.Sizes = Sheetf.Sizes +  ("20,") .
     Sheetf.Sizes = Sheetf.Sizes +  ("8,") .
     Sheetf.Sizes = Sheetf.Sizes +  ("12,") .
     Sheetf.Sizes = Sheetf.Sizes +  ("21,") .
End.
     Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable  + chr(10) +  ",".
for each  bf_ord-cons-gds no-lock  where bf_ord-cons-gds.cons-code = bf_ord-cons.cons-code,    first ub.goods where bf_ord-cons-gds.artic = ub.goods.artic                                               and bf_ord-cons-gds.prod-type = ub.goods.prod-type                                   and bf_ord-cons-gds.prod-code = ub.goods.prod-code no-lock :
     Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable
    + ",Заявленное количество"
    + ",Предполагаемое время завоза"
    + ",Заказанное у поставщика кол-во от фирмы в целом"
    + ",Код поставщика"
    + ",Наименование поставщика "
    + ",Согласованное время завоза  (поставок)"
    + ",Количество в поставке"
    + ",№ поставки"
      .
End.
sheetf.make-correct =  "".
run proc-print-header-my .
run make-tt .
run make-tt-in .
 num#str# = num#str# + 1.
for each  bf_ord-doc no-lock  where bf_ord-doc.cons-code = bf_ord-cons.cons-code and
                                    bf_ord-doc.doc-type = 'ОФ':U      ,
     first ub.clients  where ub.clients.obj-code =  bf_ord-doc.obj-code
                     and  ub.clients.obj-type =  bf_ord-doc.obj-type no-lock
                break by ub.clients.obj-type by ub.clients.obj-code :
     if last-of (ub.clients.obj-code) then do:
       num#str# = num#str# + 1.
       old-l-ord-code = "".
       run max-col  (input ub.clients.obj-code, input  ub.clients.obj-type ,output  max-str) .
       do kk = 1 to max-str :
            if kk = 1 then do:
                num#col# = 1.
                run macr_excel_char_with_format  (  (ub.clients.obj-type + " " + string (ub.clients.obj-code))  , num#str# , num#col# ) .
                num#col# = num#col# + 1 .
                run macr_excel_char_with_format  (  (ub.clients.obj-name)  , num#str# , num#col#)            .
            end.
            else do:
                num#col# = 2.
            end.
         for each  bf_ord-cons-gds no-lock  where bf_ord-cons-gds.cons-code = bf_ord-cons.cons-code,    first ub.goods where bf_ord-cons-gds.artic = ub.goods.artic                                               and bf_ord-cons-gds.prod-type = ub.goods.prod-type                                   and bf_ord-cons-gds.prod-code = ub.goods.prod-code no-lock :
            find first   temp-tt where temp-tt.obj-type = ub.clients.obj-type + " " + string (ub.clients.obj-code) and
                                    temp-tt.gds-code = ub.goods.gds-code and
                                    temp-tt.nnn = kk no-error .
                    is-l = 0.
                    if avail temp-tt then do:
                      num#col# = num#col# + 1.  if temp-tt.qnty-of  > 0 then do:                  run macr_excel_dec  (temp-tt.qnty-of, num#str# , num#col#  )   .  end.   else do: run macr_excel_char ( " ", num#str# , num#col#  )     .  end.
                      num#col# = num#col# + 1.  if temp-tt.qnty-of  > 0 then do:                  run macr_excel_char (temp-tt.time-of, num#str# , num#col#  )     .  end. else do: run macr_excel_char ( " ", num#str# , num#col#  )     .  end.
                      num#col# = num#col# + 1.  if temp-tt.qnty-rcv > 0 then do: is-l = is-l + 1. run macr_excel_dec  (temp-tt.qnty-fp, num#str# , num#col#    )   .  end. else do: run macr_excel_char ( " ", num#str# , num#col#  )     .  end.
                                                if temp-tt.ord-code = "in":U then  do: is-l = is-l + 1. run macr_excel_char  ("внутр.перем.", num#str# , num#col#    )   .  end.
                      num#col# = num#col# + 1.  if temp-tt.qnty-rcv > 0 then do: is-l = is-l + 1. run macr_excel_char (temp-tt.cli-cod, num#str# , num#col#  )      . end. else do: run macr_excel_char ( " ", num#str# , num#col#  )     .  end.
                      num#col# = num#col# + 1.  if temp-tt.qnty-rcv > 0 then do: is-l = is-l + 1. run macr_excel_char_with_format (temp-tt.cli-name, num#str# , num#col#  )  . end. else do: run macr_excel_char ( " ", num#str# , num#col#  )     .  end.
                      num#col# = num#col# + 1.  if temp-tt.qnty-rcv > 0 then do: is-l = is-l + 1. run macr_excel_char (temp-tt.time-rcv, num#str# , num#col#  )     . end. else do: run macr_excel_char ( " ", num#str# , num#col#  )     .  end.
                      num#col# = num#col# + 1.  if temp-tt.qnty-rcv > 0 then do: is-l = is-l + 1. run macr_excel_dec  (temp-tt.qnty-rcv, num#str# , num#col#  )    . end.  else do: run macr_excel_char ( " ", num#str# , num#col#  )     .  end.
                      num#col# = num#col# + 1.  if temp-tt.qnty-rcv > 0 then do: is-l = is-l + 1.
                                                   if temp-tt.ord-code = "in":U then
                                                      run macr_excel_char (temp-tt.rcv-code  , num#str# , num#col#  ).
                                                   else
                                                      run macr_excel_char (temp-tt.rcv-code + " заказ№ " + temp-tt.ord-code , num#str# , num#col#  ).
                                                   end.
                                                   else do: run macr_excel_char ( " ", num#str# , num#col#  )     .
                                                   end.
                    end.
                    else do:
                      num#col# = num#col# + 8.
                    end.
         end.
            num#str# = num#str# + 1.
       end.
     end.
end.
if is-l = 0 then num#str# = num#str# + 1.
num#col# =  1.
run macr_excel_char ( "Итого по объектам" , num#str# , num#col# ) .
num#col# = 2.
 for each  bf_ord-cons-gds no-lock  where bf_ord-cons-gds.cons-code = bf_ord-cons.cons-code,    first ub.goods where bf_ord-cons-gds.artic = ub.goods.artic                                               and bf_ord-cons-gds.prod-type = ub.goods.prod-type                                   and bf_ord-cons-gds.prod-code = ub.goods.prod-code no-lock :
    assign
        s-qnty-of     = 0
        s-qnty-fp     = 0
        s-qnty-rcv    = 0
        .
      for each   temp-tt where temp-tt.gds-code = ub.goods.gds-code :
      assign
        s-qnty-of     = s-qnty-of     + temp-tt.qnty-of
        s-qnty-fp     = g-qnty-fp
        s-qnty-rcv    = s-qnty-rcv    + temp-tt.qnty-rcv
        .
      end.
          num#col# = num#col# + 1.  run macr_excel_dec  ( s-qnty-of , num#str# , num#col#  )    .
          num#col# = num#col# + 1.
          num#col# = num#col# + 1.   .
          num#col# = num#col# + 1.
          num#col# = num#col# + 1.
          num#col# = num#col# + 1.
          num#col# = num#col# + 1.  run macr_excel_dec  ( s-qnty-rcv, num#str# , num#col#  )    .
          num#col# = num#col# + 1.
  .
 end.
  run macr_cell_format
       ( 10    ,
        true  ,
        false ,
        ?     ,
        num#str# ,
        1        ,
        num#str# ,
        num#col#
        ) .
run make-tt-host .
     for each ub.clients  where ub.clients.obj-code =  v-cntxt-host-code-obj
                        and  ub.clients.obj-type =  'орг':U no-lock
                    break by ub.clients.obj-type by ub.clients.obj-code :
     if last-of (ub.clients.obj-code) then do:
       old-l-ord-code = "".
       run max-col-host  (input ub.clients.obj-code, input  ub.clients.obj-type ,output  max-str) .
       do kk = 1 to max-str :
            if kk = 1 then do:
                num#str# = num#str# + 1.
                num#col# = 1.
                run macr_excel_char_with_format  (  (ub.clients.obj-type + " " + string (ub.clients.obj-code))  , num#str# , num#col# ) .
                num#col# = num#col# + 1 .
                run macr_excel_char_with_format  (  (ub.clients.obj-name)  , num#str# , num#col#)            .
            end.
            else do:
                num#col# = 2.
            end.
         for each  bf_ord-cons-gds no-lock  where bf_ord-cons-gds.cons-code = bf_ord-cons.cons-code,    first ub.goods where bf_ord-cons-gds.artic = ub.goods.artic                                               and bf_ord-cons-gds.prod-type = ub.goods.prod-type                                   and bf_ord-cons-gds.prod-code = ub.goods.prod-code no-lock :
            find first   temp-tt-host where temp-tt-host.obj-type = ub.clients.obj-type + " " + string (ub.clients.obj-code) and
                                    temp-tt-host.gds-code = ub.goods.gds-code and
                                    temp-tt-host.nnn = kk no-error .
                    if avail temp-tt-host then do:
                     num#col# = num#col# + 1.
                     num#col# = num#col# + 1.  run macr_excel_char (temp-tt-host.time-of, num#str# , num#col#  )     .
                     num#col# = num#col# + 1.  run macr_excel_dec  (temp-tt-host.qnty-fp, num#str# , num#col#    )   .
                     num#col# = num#col# + 1.  run macr_excel_char (temp-tt-host.cli-cod, num#str# , num#col#  )      .
                     num#col# = num#col# + 1.  run macr_excel_char_with_format (temp-tt-host.cli-name, num#str# , num#col#  )     .
                     num#col# = num#col# + 1.  run macr_excel_char (temp-tt-host.time-rcv, num#str# , num#col#  )     .
                     num#col# = num#col# + 1.  run macr_excel_dec  (temp-tt-host.qnty-rcv, num#str# , num#col#  )    .
                     num#col# = num#col# + 1.  run macr_excel_char (temp-tt-host.rcv-code, num#str# , num#col#  )    .
                    end.
                    else do:
                      num#col# = num#col# + 8.
                    end.
         end.
            num#str# = num#str# + 1.
       end.
     end.
end.
num#col# =  1.
run macr_excel_char ( "Итого по заказам ФП по фирме" , num#str# , num#col# ) .
num#col# = 2.
 for each  bf_ord-cons-gds no-lock  where bf_ord-cons-gds.cons-code = bf_ord-cons.cons-code,    first ub.goods where bf_ord-cons-gds.artic = ub.goods.artic                                               and bf_ord-cons-gds.prod-type = ub.goods.prod-type                                   and bf_ord-cons-gds.prod-code = ub.goods.prod-code no-lock :
    assign
        s-qnty-of     = 0
        s-qnty-fp     = 0
        s-qnty-rcv    = 0
        .
      for each   temp-tt-host where temp-tt-host.gds-code = ub.goods.gds-code :
      assign
        s-qnty-of     = temp-tt-host.qnty-of
        s-qnty-fp     = s-qnty-fp     + temp-tt-host.qnty-fp
        s-qnty-rcv    = s-qnty-rcv    + temp-tt-host.qnty-rcv
        .
      end.
          num#col# = num#col# + 1.  run macr_excel_dec  ( s-qnty-of , num#str# , num#col#  )    .
          num#col# = num#col# + 1.
          num#col# = num#col# + 1.  run macr_excel_dec  ( s-qnty-fp , num#str# , num#col#  )    .
          num#col# = num#col# + 1.
          num#col# = num#col# + 1.
          num#col# = num#col# + 1.
          num#col# = num#col# + 1.  run macr_excel_dec  ( s-qnty-rcv, num#str# , num#col#  )    .
          num#col# = num#col# + 1.
  .
 end.
  run macr_cell_format
       ( 10    ,
        true  ,
        false ,
        ?     ,
        num#str# ,
        1        ,
        num#str# ,
        num#col#
        ) .
run cur-time in this-procedure  ( output v-today, output v-time ).
    num#str# = num#str# + 1.
    num#col# =  1.
run macr_excel_char (  " Печать закончена : " + string (v-time,"HH:MM:SS"), num#str# , num#col#     )   .
  Output stream OutStream   close .
  Output stream Macr_Excel  close .
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
    run paramls-write in this-procedure
       (input "file"
      ,input string (v-ind)
      ,input v-file-name
      ) .
    run paramls-write in this-procedure
         (input "charcol"
        ,input ""
        ,input "1,2"
        ) .
  run end-proc .
  run rep/runexcel.p  (string ( session:temp-directory) + "rpt" + string ( g#report-num ) + ".txt").
 end.
procedure make-tt :
define variable tt-line  as logical no-undo .
define variable ttt-line as logical no-undo .
for each  bf_ord-doc no-lock  where bf_ord-doc.cons-code = bf_ord-cons.cons-code
                                and bf_ord-doc.doc-type = 'ОФ':U  ,
  first ub.clients  where ub.clients.obj-code =  bf_ord-doc.obj-code
                  and  ub.clients.obj-type =  bf_ord-doc.obj-type no-lock
                  break by ub.clients.obj-type by ub.clients.obj-code:
  if first-of (ub.clients.obj-code) then do:
     ii = 0 .
    for each  bf_ord-cons-gds no-lock  where bf_ord-cons-gds.cons-code = bf_ord-cons.cons-code,
      first ub.goods where bf_ord-cons-gds.artic = ub.goods.artic
            and bf_ord-cons-gds.prod-type = ub.goods.prod-type
            and bf_ord-cons-gds.prod-code = ub.goods.prod-code no-lock :
            assign
              l-nn = 0
              l-qnty-of = 0
              l-time-of = 0
            .
        for each  z_ord-doc no-lock  where z_ord-doc.cons-code = bf_ord-cons.cons-code
                                            and z_ord-doc.doc-type = 'ОФ':U
                                            and ub.clients.obj-code =  z_ord-doc.obj-code
                                            and ub.clients.obj-type =  z_ord-doc.obj-type
                                           ,
                each z_ord-line no-lock where z_ord-doc.doc-code   = z_ord-line.doc-code and
                                                z_ord-line.artic     = bf_ord-cons-gds.artic      and
                                                z_ord-line.prod-type = bf_ord-cons-gds.prod-type  and
                                                z_ord-line.prod-code = bf_ord-cons-gds.prod-code :
                  l-qnty-of = l-qnty-of + z_ord-line.qnty.
                  l-time-of =  z_ord-doc.ship-time.
        end.
        assign
        l-cli-code  = ""
        l-cli-name  = ""
        l-ord-code  = ""
        ttt-line = false
        l-qnty-fp = 0
        g-qnty-fp = 0
        .
        for each loc_ord-doc no-lock  where loc_ord-doc.cons-code =  bf_ord-cons.cons-code
                                        and loc_ord-doc.doc-type = 'ФП':U
                                  ,
        first b_clients  where b_clients.obj-code =  loc_ord-doc.cli-code
                          and  b_clients.obj-type =  loc_ord-doc.cli-type no-lock ,
        each loc_ord-line no-lock where loc_ord-doc.doc-code   = loc_ord-line.doc-code and
                                        loc_ord-line.artic     = bf_ord-cons-gds.artic      and
                                        loc_ord-line.prod-type = bf_ord-cons-gds.prod-type  and
                                        loc_ord-line.prod-code = bf_ord-cons-gds.prod-code
                      break by  loc_ord-doc.doc-code   :
            l-qnty-fp = l-qnty-fp + loc_ord-line.qnty.
            g-qnty-fp = g-qnty-fp + loc_ord-line.qnty.
            if first-of  ( loc_ord-doc.doc-code ) then do:
            l-cli-code  =  b_clients.obj-type + " "  + string ( b_clients.obj-code).
            l-cli-name  =  b_clients.obj-name.
            l-ord-code  = loc_ord-line.doc-code.
                tt-line = false  .
                for each loc_ord-doc-rcv no-lock  where loc_ord-doc-rcv.cons-code =  bf_ord-cons.cons-code
                                                    and loc_ord-doc-rcv.doc-code   = loc_ord-line.doc-code
                                                    and loc_ord-doc-rcv.obj-code   = ub.clients.obj-code
                                                    and loc_ord-doc-rcv.obj-type   = ub.clients.obj-type   ,
                      each loc_ord-line-rcv no-lock where loc_ord-doc-rcv.doc-code   = loc_ord-line.doc-code and
                            loc_ord-doc-rcv.rcv-code   = loc_ord-line-rcv.rcv-code and
                            loc_ord-line-rcv.artic     = bf_ord-cons-gds.artic      and
                            loc_ord-line-rcv.prod-type = bf_ord-cons-gds.prod-type  and
                            loc_ord-line-rcv.prod-code = bf_ord-cons-gds.prod-code  :
                            l-rcv-code  = loc_ord-line-rcv.rcv-code.
                            l-time-rcv  = loc_ord-doc-rcv.ship-time.
                            l-qnty-rcv =  loc_ord-line-rcv.qnty.
                        run create-tt-line .
                        assign
                          tt-line = true
                          l-rcv-code = ""
                          l-time-rcv = 0
                          l-qnty-rcv = 0
                        .
                end.
              if tt-line = false then run create-tt-line .
            end.
          ttt-line = true .
          if last-of  ( loc_ord-doc.doc-code ) then l-qnty-fp = 0.
        end.
          if ttt-line = false then  run create-tt-line .
    end.
  end.
end.
end procedure .
procedure make-tt-in :
define variable tt-line  as logical no-undo .
define variable ttt-line as logical no-undo .
define buffer l_clients for ub.clients .
for each  bf_ord-doc no-lock  where bf_ord-doc.cons-code = bf_ord-cons.cons-code
                                and bf_ord-doc.doc-type = 'ОФ':U  ,
  first ub.clients  where ub.clients.obj-code =  bf_ord-doc.obj-code
                  and  ub.clients.obj-type =  bf_ord-doc.obj-type no-lock
                  break by ub.clients.obj-type by ub.clients.obj-code:
  if first-of (ub.clients.obj-code) then do:
     ii = 0 .
    for each  bf_ord-cons-gds no-lock  where bf_ord-cons-gds.cons-code = bf_ord-cons.cons-code,
      first ub.goods where bf_ord-cons-gds.artic = ub.goods.artic
            and bf_ord-cons-gds.prod-type = ub.goods.prod-type
            and bf_ord-cons-gds.prod-code = ub.goods.prod-code no-lock :
            assign
              l-nn = 0
              l-qnty-of = 0
              l-time-of = 0
            .
        assign
        l-cli-code  = ""
        l-cli-name  = ""
        l-ord-code  = ""
        ttt-line = false
        l-qnty-fp = 0
        g-qnty-fp = 0
        .
                tt-line = false  .
                for each loc_ord-doc-rcv no-lock  where loc_ord-doc-rcv.cons-code =  bf_ord-cons.cons-code
                                                    and loc_ord-doc-rcv.doc-type   = "in":U
                                                    and loc_ord-doc-rcv.obj-code   = ub.clients.obj-code
                                                    and loc_ord-doc-rcv.obj-type   = ub.clients.obj-type   ,
                      each loc_ord-line-rcv no-lock where
                            loc_ord-doc-rcv.doc-code   = loc_ord-line-rcv.doc-code and
                            loc_ord-doc-rcv.rcv-code   = loc_ord-line-rcv.rcv-code and
                            loc_ord-line-rcv.artic     = bf_ord-cons-gds.artic      and
                            loc_ord-line-rcv.prod-type = bf_ord-cons-gds.prod-type  and
                            loc_ord-line-rcv.prod-code = bf_ord-cons-gds.prod-code  :
                            find first l_clients  where l_clients.obj-code =  loc_ord-doc-rcv.cli-code
                                                   and  l_clients.obj-type =  loc_ord-doc-rcv.cli-type no-lock no-error .
                            l-ord-code = "in":U .
                            l-rcv-code = loc_ord-line-rcv.rcv-code .
                            l-time-rcv = loc_ord-doc-rcv.ship-time.
                            l-qnty-rcv = loc_ord-line-rcv.qnty.
                            l-cli-code = l_clients.obj-type + " " + string (l_clients.obj-code).
                            l-cli-name = l_clients.obj-name.
                            l-nn = l-nn + 1.
                            run create-tt-line .
                        assign
                          tt-line = true
                          l-rcv-code = ""
                          l-time-rcv = 0
                          l-qnty-rcv = 0
                        .
                end.
                tt-line = false  .
                for each loc_ord-doc-rcv no-lock  where loc_ord-doc-rcv.cons-code  =  bf_ord-cons.cons-code
                                                    and loc_ord-doc-rcv.doc-type   = "in":U
                                                    and loc_ord-doc-rcv.cli-code   = ub.clients.obj-code
                                                    and loc_ord-doc-rcv.cli-type   = ub.clients.obj-type ,
                      each loc_ord-line-rcv no-lock where
                            loc_ord-doc-rcv.doc-code   = loc_ord-line-rcv.doc-code and
                            loc_ord-doc-rcv.rcv-code   = loc_ord-line-rcv.rcv-code and
                            loc_ord-line-rcv.artic     = bf_ord-cons-gds.artic      and
                            loc_ord-line-rcv.prod-type = bf_ord-cons-gds.prod-type  and
                            loc_ord-line-rcv.prod-code = bf_ord-cons-gds.prod-code  :
                            find first l_clients  where l_clients.obj-code =  loc_ord-doc-rcv.obj-code
                                                   and  l_clients.obj-type =  loc_ord-doc-rcv.obj-type no-lock no-error .
                            l-ord-code = "in":U .
                            l-rcv-code = loc_ord-line-rcv.rcv-code .
                            l-time-rcv = loc_ord-doc-rcv.ship-time.
                            l-qnty-rcv =  ( - 1 ) * loc_ord-line-rcv.qnty.
                            l-cli-code = l_clients.obj-type + " " + string (l_clients.obj-code).
                            l-cli-name = l_clients.obj-name.
                            l-nn = l-nn + 1.
                        run create-tt-line .
                        assign
                          tt-line = true
                          l-rcv-code = ""
                          l-time-rcv = 0
                          l-qnty-rcv = 0
                        .
                end.
    end.
  end.
end.
end procedure .
procedure create-tt-line :
ii = ii + 1.
IF ( ii modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(reportname)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(reportname)
    .
 Assign
    v-kol-spice = (50 - LENGTH(ub.clients.obj-name)) / 2
    RecordsString2 = fill(' ',v-kol-spice) + string(ub.clients.obj-name)
    .
 Assign
    v-kol-spice = (50 - LENGTH(ub.goods.gds-name)) / 2
    RecordsString3 = fill(' ',v-kol-spice) + string(ub.goods.gds-name)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              ii @ RecordsDone
              RecordsString   @ RecordsString
              RecordsString2  @ RecordsString2
              RecordsString3  @ RecordsString3
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
 l-nn = l-nn + 1 .
create temp-tt .
assign
 temp-tt.nnn         = l-nn
 temp-tt.obj-type    = ub.clients.obj-type + " " + string (ub.clients.obj-code)
 temp-tt.obj-name    = ub.clients.obj-name
 temp-tt.gds-code    = ub.goods.gds-code
 .
 If l-nn = 1 then Do:
      assign
          temp-tt.qnty-of     = l-qnty-of
          temp-tt.time-of     =  (if l-time-of  = 0 then " " else string (l-time-of,"HH:MM"))
          .
       end.
 else
      assign
          temp-tt.qnty-of     = 0
          temp-tt.time-of     = " "
          .
    assign
        temp-tt.qnty-fp     = l-qnty-fp
        temp-tt.cli-cod     = l-cli-code
        temp-tt.cli-name    = l-cli-name
        .
 assign
    temp-tt.ord-code    = l-ord-code
    old-l-ord-code      = l-ord-code
    temp-tt.rcv-code    = l-rcv-code
    temp-tt.time-rcv    =  (if l-time-rcv  = 0 then  " " else string (l-time-rcv,"HH:MM"))
    temp-tt.qnty-rcv    = l-qnty-rcv
.
end procedure .
procedure max-col :
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define output parameter p-max as integer no-undo .
     p-max = 0 .
     for each temp-tt where temp-tt.obj-type = p-obj-type  + " " + string (p-obj-code)
       break by temp-tt.nnn DESCENDING :
       p-max = temp-tt.nnn.
       leave.
     end.
end procedure .
procedure max-col-host :
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define output parameter p-max as integer no-undo .
     p-max = 0 .
     for each temp-tt-host where temp-tt-host.obj-type = p-obj-type  + " " + string (p-obj-code)
       break by temp-tt-host.nnn DESCENDING :
       p-max = temp-tt-host.nnn.
       leave.
     end.
end procedure .
procedure new-tmp-page :
 do
 on error undo, return error return-value
 :
    if   num#str#  >= 63000 then do:
        Output stream Macr_Excel  close .
        run paramls-write in this-procedure
           (input "file"
          ,input string (v-ind)
          ,input v-file-name
          ) .
        run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
        output stream  Macr_Excel to value (v-file-name) .
        v-ind = v-ind + 1 .
        num#str# = 0 .
        run proc-print-header-my in this-procedure .
    end.
 end.
end procedure.
procedure proc-print-header-my :
 do
 on error undo, return error return-value
 :
   find first sheetf .
     sheetf.excel-row-heder =  num-entries ( c-str ,chr(10)) + 1.
     sheetf.excel-row-title =  num-entries ( sheetf.excel-column-lable , chr(10) ).
     var-1 =  num#str# .
     repeat c-c = 1 to sheetf.excel-row-title :
     num#str# = num#str# + 1 .
     p-var = num-entries ( entry  (c-c, sheetf.excel-column-lable, chr(10)) , chr(44) ) .
     do c-i = 1 to p-var :
        str--1 = entry ( c-i, entry  (c-c,sheetf.excel-column-lable, chr(10)) , chr(44)) .
        str--2 = integer (entry ( c-i, sheetf.sizes )) .
        num#col# = c-i .
        run macr_excel_char ( str--1  , num#str# , num#col#  ) .
        run macr_cell_size  ( str--2 , ? , num#str# , num#col# , ?, ? ) .
     end.
    c-i = 0.
    end.
    run macr_cell_format  (
        10       ,
        true     ,
        false    ,
        35       ,
        var-1 + 1,
        1        ,
        num#str# ,
        num#col# )
        .
     define variable t-var as integer no-undo .
     t-var = 2 .
     do c-i = 1 to p-var :
        str--1 = entry ( c-i, entry  (1 , sheetf.excel-column-lable, chr(10)) , chr(44)) no-error   .
        if  str--1   begins " Арт "  then do:
            t-var = t-var + 1.
            if    ( t-var modulo 2 )  <> 0 then do:
                put  stream macr_excel unformatted
                      substitute ('select ("r&1c&2:r&3c&4 ")' ,   num#str# - 1 , c-i , num#str# - 1, c-i + 7 ) + chr(10)  +
                      substitute ('patterns (1,,&1,true)', 50 ) + chr(10)  .
            end.
        end.
     end.
  put  stream macr_excel unformatted
       substitute ('select ("r&1c&2:r&3c&4 ")' , var-1 + 1 , 1 , num#str# ,  num#col# ) + chr(10)  +
        'BORDER ( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + chr(10) +
        'ALIGNMENT (3 , , 4 , 4 ,)'                  + chr(10)
       .
  var-3 = 4 .
  do while var-3 < p-var  :
        put  stream macr_excel unformatted
             substitute ('select ("r&1c&2:r&3c&4 ")' ,   var-1 + 1,  var-3 , var-1 + 1 , var-3 + 5 ) + chr(10)  +
             'ALIGNMENT (7 , , 4 , 4 ,)'              + chr(10)
        .
        var-3 = var-3 + 5 .
   end.
 end.
end procedure.
procedure make-tt-host :
ii = 0 .
l-nn = 0 .
  for   each  bf_ord-cons-gds no-lock  where bf_ord-cons-gds.cons-code = bf_ord-cons.cons-code,
      first ub.goods where bf_ord-cons-gds.artic = ub.goods.artic
            and bf_ord-cons-gds.prod-type = ub.goods.prod-type
            and bf_ord-cons-gds.prod-code = ub.goods.prod-code no-lock :
            assign
              l-nn = 0
              l-qnty-of = 0
              l-time-of = 0
            .
        for each  z_ord-doc no-lock  where z_ord-doc.cons-code = bf_ord-cons.cons-code
                                            and z_ord-doc.doc-type = 'ОФ':U
                                           ,
                each z_ord-line no-lock where z_ord-doc.doc-code   = z_ord-line.doc-code and
                                                z_ord-line.artic     = bf_ord-cons-gds.artic      and
                                                z_ord-line.prod-type = bf_ord-cons-gds.prod-type  and
                                                z_ord-line.prod-code = bf_ord-cons-gds.prod-code :
                  l-qnty-of = l-qnty-of + z_ord-line.qnty.
        end.
        assign
        l-cli-code  = ""
        l-cli-name  = ""
        l-ord-code  = ""
        l-qnty-fp = 0
        g-qnty-fp = 0
        .
        for each loc_ord-doc no-lock  where loc_ord-doc.cons-code =  bf_ord-cons.cons-code
                                        and loc_ord-doc.doc-type = 'ФП':U
                                  ,
                    first b_clients  where b_clients.obj-code =  loc_ord-doc.cli-code
                                      and  b_clients.obj-type =  loc_ord-doc.cli-type no-lock ,
                    each loc_ord-line no-lock where loc_ord-doc.doc-code   = loc_ord-line.doc-code and
                                        loc_ord-line.artic     = bf_ord-cons-gds.artic      and
                                        loc_ord-line.prod-type = bf_ord-cons-gds.prod-type  and
                                        loc_ord-line.prod-code = bf_ord-cons-gds.prod-code
                      break by  b_clients.obj-type by  b_clients.obj-code  :
            l-qnty-fp = l-qnty-fp + loc_ord-line.qnty.
            if first-of  ( b_clients.obj-code ) then do:
            l-cli-code  =  b_clients.obj-type + " "  + string ( b_clients.obj-code).
            l-cli-name  =  b_clients.obj-name.
            l-qnty-rcv = 0 .
                for each loc_ord-doc-rcv no-lock  where loc_ord-doc-rcv.cons-code =  bf_ord-cons.cons-code
                                                    and loc_ord-doc-rcv.doc-code   = loc_ord-line.doc-code
                                                    and loc_ord-doc-rcv.cli-code   = b_clients.obj-code
                                                    and loc_ord-doc-rcv.cli-type   = b_clients.obj-type   ,
                      each loc_ord-line-rcv no-lock where loc_ord-doc-rcv.doc-code   = loc_ord-line.doc-code and
                            loc_ord-doc-rcv.rcv-code   = loc_ord-line-rcv.rcv-code and
                            loc_ord-line-rcv.artic     = bf_ord-cons-gds.artic      and
                            loc_ord-line-rcv.prod-type = bf_ord-cons-gds.prod-type  and
                            loc_ord-line-rcv.prod-code = bf_ord-cons-gds.prod-code  :
                            l-qnty-rcv = l-qnty-rcv  +  loc_ord-line-rcv.qnty.
                end.
            run create-tt-line-host .
            assign
              l-rcv-code = ""
              l-time-rcv = 0
              l-qnty-rcv = 0
              l-qnty-fp = 0
            .
            end.
        end.
    end.
end procedure .
procedure create-tt-line-host :
ii = ii + 1.
IF ( ii modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(reportname)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(reportname)
    .
 Assign
    v-kol-spice = (50 - LENGTH(ub.clients.obj-name)) / 2
    RecordsString2 = fill(' ',v-kol-spice) + string(ub.clients.obj-name)
    .
 Assign
    v-kol-spice = (50 - LENGTH(ub.goods.gds-name)) / 2
    RecordsString3 = fill(' ',v-kol-spice) + string(ub.goods.gds-name)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              ii @ RecordsDone
              RecordsString   @ RecordsString
              RecordsString2  @ RecordsString2
              RecordsString3  @ RecordsString3
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
 l-nn = l-nn + 1 .
create temp-tt-host .
assign
    temp-tt-host.nnn         = l-nn
    temp-tt-host.obj-type    = 'орг':U + " " + string ( v-cntxt-host-code-obj )
    temp-tt-host.obj-name    = v-cntxt-host-name-obj
    temp-tt-host.gds-code    = ub.goods.gds-code
    temp-tt-host.qnty-of     = l-qnty-of
    temp-tt-host.qnty-fp     = l-qnty-fp
    temp-tt-host.cli-cod     = l-cli-code
    temp-tt-host.cli-name    = l-cli-name
    temp-tt-host.ord-code    = l-ord-code
    temp-tt-host.rcv-code    = l-rcv-code
    temp-tt-host.qnty-rcv    = l-qnty-rcv
    .
end procedure .
def var vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure macr_excel_char :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .
 if p-val = ? then p-val = "" .
    put stream macr_excel unformatted
          substitute('formula(&3,"r&1c&2")', p-row , p-col , format-excel-text-macr ( p-val) ) + chr(10)  .
 end.
end procedure.
procedure macr_excel_char_with_format :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .
 if p-val = ? then p-val = "" .
    put stream macr_excel unformatted
          substitute('select("r&1c&2")', p-row , p-col ) + chr(10) .
    put stream macr_excel unformatted 'format.number("@")' + chr(10) .
    put stream macr_excel unformatted
          substitute('formula(&3,"r&1c&2")', p-row , p-col , format-excel-text-macr ( p-val) ) + chr(10)  .
 end.
end procedure.
procedure macr_excel_cell_format :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val    as character no-undo .
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-format as character no-undo .
 if p-val = ? then p-val = "" .
    put stream macr_excel unformatted
          substitute('select("r&1c&2")', p-row , p-col ) + chr(10) .
    put stream macr_excel unformatted substitute('format.number("&1")', p-format) + chr(10) .
    put stream macr_excel unformatted
          substitute('formula(&3,"r&1c&2")', p-row , p-col , format-excel-text-macr ( p-val) ) + chr(10)  .
 end.
end procedure.
procedure macr_excel_sum :
 do
 on error undo, return error return-value
 :
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .
 define input parameter  p-row1 as integer no-undo .
 define input parameter  p-col1 as integer no-undo .
 define input parameter  p-row2 as integer no-undo .
 define input parameter  p-col2 as integer no-undo .
    put stream macr_excel unformatted
          substitute('formula("=sum(r&3c&4:r&5c&6)","r&1c&2")', p-row , p-col , p-row1 , p-col1 ,p-row2 , p-col2 ) + chr(10)  .
 end.
end procedure.
procedure macr_excel_dec :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer   no-undo .
 define input parameter  p-col as integer   no-undo .
  if p-val = ? then p-val =  "" .
   put  stream macr_excel unformatted
        substitute('formula(&3,"r&1c&2")', p-row , p-col ,  p-val )  + chr(10) .
 end.
end procedure.
procedure macr_cell_format :
 do
 on error undo, return error return-value
 :
 define input parameter  p-size   as integer   no-undo .
 define input parameter  p-bold   as logical   no-undo .
 define input parameter  p-italic as logical   no-undo .
 define input parameter  p-color  as integer   no-undo .
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .
  if p-size = ? then p-size = 10 .
  if p-bold = ? then p-bold = false .
  if p-italic = ? then p-italic = false .
  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  put  stream macr_excel unformatted
   substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) + chr(10) .
  if p-color <> ? then do:
     put  stream macr_excel unformatted
       substitute('patterns(1,,&1,true)', p-color ) + chr(10)  .
  end.
  put  stream macr_excel unformatted
       substitute('format.font(,&1,&2,&3)' , p-size,
                                        string ( p-bold  , "true/false" ) ,
                                        string ( p-italic , "true/false" )
                                        ) + chr(10) .
 end.
end procedure.
procedure macr_cell_size :
 do
 on error undo, return error return-value
 :
 define input parameter  p-w   as integer   no-undo .
 define input parameter  p-l   as integer   no-undo .
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .
  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  if p-w = ? then    p-w = 0 .
  if p-l = ? then    p-l = 0 .
 define variable s-w as character no-undo .
 define variable s-l as character no-undo .
 if p-w = 0 then s-w = "" .
            else s-w = string(p-w)  .
 if p-l = 0 then s-l = "" .
            else s-l = string(p-l)  .
put  stream macr_excel unformatted
     substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 )  skip .
put  stream macr_excel unformatted
     substitute('COLUMN.WIDTH(&1,,,,)' , s-w  )  skip.
put  stream macr_excel unformatted
     'FORMAT.TEXT(2,2,0,,,,,)'  skip.
 end.
end procedure.
procedure proc-print-header :
 do
 on error undo, return error return-value
 :
   find first sheetf .
     sheetf.excel-row-heder =  num-entries( c-str ,chr(10)) + 1.
     sheetf.excel-row-title =  num-entries( sheetf.excel-column-lable , chr(10) ).
     var-1 =  num#str# .
     repeat c-c = 1 to sheetf.excel-row-title :
     num#str# = num#str# + 1 .
     p-var = num-entries( entry (c-c, sheetf.excel-column-lable, chr(10)) , chr(44) ) .
     do c-i = 1 to p-var :
        str--1 = entry( c-i, entry (c-c,sheetf.excel-column-lable, chr(10)) , chr(44)) .
        str--2 = integer(entry( c-i, sheetf.sizes )) .
        num#col# = c-i .
        run macr_excel_char_with_format ( str--1  , num#str# , num#col#  ) .
        run macr_cell_size ( str--2 , ? , num#str# , num#col# , ?, ? ) .
     end.
    c-i = 0.
    end.
    run macr_cell_format (
        10       ,
        true     ,
        false    ,
        35       ,
        var-1 + 1,
        1        ,
        num#str# ,
        num#col# )
        .
  put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , var-1 + 1 , 1 , num#str# ,  num#col# ) + chr(10)  +
       'ALIGNMENT(3 , , 4 , 4 ,)'  + chr(10)
       .
 end.
end procedure.
procedure end-proc :
 do
 on error undo, return error return-value
 :
  v-file-name = ( string( session:temp-directory + "rpt" + string( g#report-num ) ) + ".t-t").
  OUTPUT to VALUE (v-file-name) .
  for each temp-param :
    export  temp-param  .
  end.
 end.
end procedure.
