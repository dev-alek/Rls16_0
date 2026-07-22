define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список печатных форм план-меню".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable var-report-r-b as character no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define variable vss-include-info9 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    define temp-table Tmp#List no-undo like ub.ord-blank
        field id                        as integer
        field proc-name                 as character
        field proc-param                as character
        field print-options             as character
        field orient                    as character
        field orient-orientation        as character
        field orient-font-num           as integer
        field font-num                  as character
        field filtr                     as character
        field view_                     as integer  init 1
        field sys-key                   as character
        field sys-key-black             as character
        field type-parts                as character
        field type-parts-enabled        as logical
        field type-price                as character
        field type-price-enabled        as logical
        field type-scale                as character
        field type-scale-enabled        as logical
        field type-val                  as character
        field type-val-enabled          as logical
        field sort-name                 as character
        field sort-name-enabled         as logical
        field sort-gr                   as character
        field sort-gr-enabled           as logical
        field print-graft               as character
        field print-graft-enabled       as logical
        field no-vat                    as character
        field no-vat-enabled            as logical
        index pi is primary unique id
        index in-name
           blank-name
        index lu
            last-use
    .
    define temp-table temp_form-list no-undo
        field doc-code  as character
        field id        as integer
        field doc-type  as character
        field status_   as character
        field internal  as character
        field flag      as character
        index pi is primary unique
            doc-code
            id
        index idx
            id
    .
    define temp-table temp_menu-doc_disabled-doc-list no-undo
        field doc-code      as character
        field blank-name    as character
        field reason        as character
        index pi is primary unique
                doc-code
                blank-name
    .
    define variable v-menu-doc-sys-key              as character    no-undo.
    define variable v-menu-doc-doc-code             as character    no-undo.
    define variable v-menu-doc-doc-type             as character    no-undo.
    define variable v-menu-doc-ext-doc-type         as character    no-undo.
    define variable v-menu-doc-status_              as character    no-undo.
    define variable v-menu-doc-internal             as character    no-undo.
    define variable v-menu-doc-flag                 as character    no-undo.
    define variable v-menu-doc-item-counter         as integer      no-undo.
    define variable v-menu-doc-item-disabled        as logical      no-undo.
define variable vss-include-info10 as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
function check-entry-with-mask returns logical ( input p-element as character, input p-list as character, input p-delimiter as character ) :
  define variable p-entry   as logical   no-undo .
  define variable v-ind as integer   no-undo .
  if p-delimiter = "*":U then do:
    message
      vss-workfile "(check-entry-with-mask)" vss-revision vss-description skip
      substitute('Разделитель не может быть равный "&1"', p-delimiter ) skip
      view-as alert-box error .
    return ? .
  end.
  assign
    p-entry = true
  .
  if lookup( p-element, p-list, p-delimiter ) = 0 then do:
    assign
      p-entry = false
    .
    if num-entries( p-list, "*":U ) > 1 then do:
      block_check-list:
      do v-ind = 1 to num-entries( p-list, p-delimiter )
      :
        if p-element matches entry( v-ind, p-list, p-delimiter ) then do:
          assign
            p-entry = true
          .
          leave block_check-list .
        end.
      end.
    end.
  end.
  return p-entry .
end function .
    procedure menu-doc-create-menu-item
    :
    define input parameter p-type   as   character no-undo.
    define input parameter p-stat   as   character no-undo.
    define input parameter p-intr   as   character no-undo.
    define input parameter p-flag   as   character no-undo.
    define input parameter param-1  as   character no-undo.
    define input parameter param-2  as   character no-undo.
    define input parameter param-3  as   character no-undo.
    define input parameter param-4  as   character no-undo.
    define input parameter param-5  as   character no-undo.
    define input parameter param-6  as   character no-undo.
    define input parameter param-7  as   character no-undo.
    define input parameter param-8  as   character no-undo.
    define input parameter param-9  as   character no-undo.
    define input parameter param-10 as   character no-undo.
    define input parameter param-11 as   character no-undo.
    define input parameter param-12 as   character no-undo.
    do
    on error undo, return error
    :
        assign
            v-menu-doc-item-disabled = yes
        .
        if v-menu-doc-sys-key <> 'ExpertekIBS':U
        and ( ( param-10 <> "":U
                and check-entry-with-mask( v-menu-doc-sys-key, param-10, chr(44) ) = false
              )
              or ( param-12 <> "":U
                   and check-entry-with-mask( v-menu-doc-sys-key, param-12, chr(44) ) = true )
                 )
        then do:
            undo, return .
        end.
        if param-7 = "":U
        then do:
            undo, return .
        end.
        if param-1 = '*':U
        or lookup( p-type, param-1 ) > 0
        then do:
            if param-2 = '*':U
            or lookup( p-stat, param-2 ) > 0
            then do:
                if param-3 = '*':U
                or lookup( p-intr, param-3 ) > 0
                then do:
                    if param-4 = '*':U
                    or lookup( p-flag, param-4 ) > 0
                    then do:
                        assign
                            v-menu-doc-item-disabled = no
                        .
                        find first tmp#list
                             where tmp#list.blank-name     = param-5
                               and tmp#list.filtr          = param-6
                               and tmp#list.proc-name      = param-7
                               and tmp#list.proc-param     = param-8
                               and tmp#list.print-options  = param-9
                               and tmp#list.sys-key        = param-10
                               and tmp#list.orient         = param-11
                               and tmp#list.sys-key-black  = param-12
                        no-error.
                        if not available tmp#list
                        then do:
                            assign
                                v-menu-doc-item-counter = v-menu-doc-item-counter + 1
                            .
                            create tmp#list.
                            assign
                                tmp#list.id             = v-menu-doc-item-counter
                                tmp#list.cli-code       = v-menu-doc-item-counter
                                tmp#list.blank-name     = param-5
                                tmp#list.filtr          = param-6
                                tmp#list.proc-name      = param-7
                                tmp#list.proc-param     = param-8
                                tmp#list.print-options  = param-9
                                tmp#list.sys-key        = param-10
                                tmp#list.orient         = param-11
                                tmp#list.sys-key-black  = param-12
                            .
                            assign
                                tmp#list.orient-orientation     = entry( 1, tmp#list.orient )
                                tmp#list.orient-font-num        = 7
                            .
                            assign
                                tmp#list.orient-font-num      = ( if num-entries( tmp#list.orient ) > 1
                                                                  then integer( entry( 2, tmp#list.orient ) )
                                                                  else 7 )
                            no-error.
                            if error-status :error
                            then do:
                                assign
                                    tmp#list.orient-font-num = 7
                                .
                            end.
                            run menu-doc-set-visible-options in this-procedure (
                                  input tmp#list.print-options
                                , output tmp#list.type-parts-enabled
                                , output tmp#list.type-price-enabled
                                , output tmp#list.type-scale-enabled
                                , output tmp#list.type-val-enabled
                                , output tmp#list.sort-name-enabled
                                , output tmp#list.sort-gr-enabled
                                , output tmp#list.print-graft-enabled
                                , output tmp#list.no-vat-enabled
                            ).
                        end.
                    end.
                end.
            end.
        end.
        if v-menu-doc-item-disabled = yes
        then do:
            find first tmp#list
                 where tmp#list.blank-name     = param-5
                   and tmp#list.filtr          = param-6
                   and tmp#list.proc-name      = param-7
                   and tmp#list.proc-param     = param-8
                   and tmp#list.print-options  = param-9
                   and tmp#list.sys-key        = param-10
                   and tmp#list.orient         = param-11
                   and tmp#list.sys-key-black  = param-12
            no-error.
            if available tmp#list
            then do:
                find first temp_menu-doc_disabled-doc-list
                     where temp_menu-doc_disabled-doc-list.doc-code     = v-menu-doc-doc-code
                       and temp_menu-doc_disabled-doc-list.blank-name   = param-5
                no-error.
                if not available temp_menu-doc_disabled-doc-list
                then do:
                    create temp_menu-doc_disabled-doc-list.
                    assign
                        temp_menu-doc_disabled-doc-list.doc-code    = v-menu-doc-doc-code
                        temp_menu-doc_disabled-doc-list.blank-name  = param-5
                    .
                end.
                if param-1 <> '*':U
                and lookup( p-type, param-1 ) > 0
                then do:
                    assign
                        temp_menu-doc_disabled-doc-list.reason   = "type":U
                    .
                end.
                assign
                    temp_menu-doc_disabled-doc-list.reason = temp_menu-doc_disabled-doc-list.reason + ",":U
                .
                if param-2 <> '*':U
                and lookup( p-stat, param-2 ) > 0
                then do:
                    assign
                        temp_menu-doc_disabled-doc-list.reason = temp_menu-doc_disabled-doc-list.reason + "stat":U
                    .
                end.
                assign
                    temp_menu-doc_disabled-doc-list.reason = temp_menu-doc_disabled-doc-list.reason + ",":U
                .
                if param-3 <> '*':U
                and lookup( p-intr, param-3 ) > 0
                then do:
                    assign
                        temp_menu-doc_disabled-doc-list.reason = temp_menu-doc_disabled-doc-list.reason + "intr":U
                    .
                end.
                assign
                    temp_menu-doc_disabled-doc-list.reason = temp_menu-doc_disabled-doc-list.reason + ",":U
                .
                if param-4 <> '*':U
                and lookup( p-flag, param-4 ) > 0
                then do:
                    assign
                        temp_menu-doc_disabled-doc-list.reason = temp_menu-doc_disabled-doc-list.reason + "flag":U
                    .
                end.
                if v-menu-doc-sys-key = 'ExpertekIBS':U
                then do:
                    run menu-doc-extend-blank-name-for-IBS in this-procedure (
                          input tmp#list.blank-name
                        , input tmp#list.sys-key
                        , input Tmp#List.sys-key-black
                        , output tmp#list.blank-name
                    ).
                end.
            end.
            else do:
                assign
                    v-menu-doc-item-disabled = no
                .
            end.
        end.
        if v-menu-doc-item-disabled = no
        then do:
            find first tmp#list
                 where tmp#list.blank-name     = param-5
                   and tmp#list.filtr          = param-6
                   and tmp#list.proc-name      = param-7
                   and tmp#list.proc-param     = param-8
                   and tmp#list.print-options  = param-9
                   and tmp#list.sys-key        = param-10
                   and tmp#list.orient         = param-11
                   and tmp#list.sys-key-black  = param-12
            no-error.
            if available tmp#list
            then do:
                find first temp_form-list
                     where temp_form-list.doc-code  = v-menu-doc-doc-code
                       and temp_form-list.id        = tmp#list.id
                no-error.
                if not available temp_form-list
                then do:
                    create temp_form-list.
                    assign
                        temp_form-list.doc-code  = v-menu-doc-doc-code
                        temp_form-list.id        = tmp#list.id
                        temp_form-list.doc-type  = v-menu-doc-doc-type
                        temp_form-list.status_   = v-menu-doc-status_
                        temp_form-list.internal  = v-menu-doc-internal
                        temp_form-list.flag      = v-menu-doc-flag
                    .
                end.
                if v-menu-doc-sys-key = 'ExpertekIBS':U
                then do:
                    run menu-doc-extend-blank-name-for-IBS in this-procedure (
                          input tmp#list.blank-name
                        , input tmp#list.sys-key
                        , input Tmp#List.sys-key-black
                        , output tmp#list.blank-name
                    ).
                end.
            end.
        end.
    end.
    end procedure.
    procedure menu-doc-set-visible-options :
    define input parameter p-print-options          as character        no-undo.
    define output parameter p-type-parts-enabled    as logical          no-undo.
    define output parameter p-type-price-enabled    as logical          no-undo.
    define output parameter p-type-scale-enabled    as logical          no-undo.
    define output parameter p-type-val-enabled      as logical          no-undo.
    define output parameter p-sort-name-enabled     as logical          no-undo.
    define output parameter p-sort-gr-enabled       as logical          no-undo.
    define output parameter p-print-graft-enabled   as logical          no-undo.
    define output parameter p-no-vat-enabled        as logical          no-undo.
    do
    on error undo, return error
    :
        assign
            p-type-parts-enabled    = ( if substring( p-print-options, 1, 1 ) = "+" then yes else no )
            p-type-price-enabled    = ( if substring( p-print-options, 2, 1 ) = "+" then yes else no )
            p-type-scale-enabled    = ( if substring( p-print-options, 3, 1 ) = "+" then yes else no )
            p-type-val-enabled      = ( if substring( p-print-options, 4, 1 ) = "+" then yes else no )
            p-sort-name-enabled     = ( if substring( p-print-options, 5, 1 ) = "+" then yes else no )
            p-sort-gr-enabled       = ( if substring( p-print-options, 6, 1 ) = "+" then yes else no )
            p-print-graft-enabled   = ( if substring( p-print-options, 7, 1 ) = "+" then yes else no )
            p-no-vat-enabled        = ( if substring( p-print-options, 8, 1 ) = "+" then yes else no )
        .
    end.
    end procedure.
    procedure menu-doc-create-options-string :
    define input parameter p-tmp-list-id        as integer          no-undo.
    define output parameter p-options-string    as character        no-undo.
        define buffer buf_tmp#list      for tmp#list.
    do
    for buf_tmp#list
    on error undo, return error
    :
        find first buf_tmp#list
             where buf_tmp#list.id = p-tmp-list-id
        .
        assign
            p-options-string =  ( if trim( buf_tmp#list.type-parts  ) = "+":U then "+":U else "-":U )
                              + ( if trim( buf_tmp#list.type-price  ) = "+":U then "+":U else "-":U )
                              + ( if trim( buf_tmp#list.type-scale  ) = "+":U then "+":U else "-":U )
                              + ( if trim( buf_tmp#list.type-val    ) = "+":U then "+":U else "-":U )
                              + ( if trim( buf_tmp#list.sort-name   ) = "+":U then "+":U else "-":U )
                              + ( if trim( buf_tmp#list.sort-gr     ) = "+":U then "+":U else "-":U )
                              + ( if trim( buf_tmp#list.print-graft ) = "+":U then "+":U else "-":U )
                              + ( if trim( buf_tmp#list.no-vat      ) = "+":U then "+":U else "-":U )
        .
    end.
    end procedure.
    procedure menu-doc-set-options-string :
    define input parameter p-tmp-list-id            as integer          no-undo.
    define input parameter p-options-string         as character        no-undo.
        define buffer buf_tmp#list      for tmp#list.
    do
    for buf_tmp#list
    on error undo, return error
    :
        find first buf_tmp#list
             where buf_tmp#list.id = p-tmp-list-id
        .
        assign
            buf_tmp#list.type-parts  = ( if buf_tmp#list.type-parts-enabled     = yes then substitute( "  &1", substring( p-options-string, 1, 1 ) ) else " ":U )
            buf_tmp#list.type-price  = ( if buf_tmp#list.type-price-enabled     = yes then substitute( "  &1", substring( p-options-string, 2, 1 ) ) else " ":U )
            buf_tmp#list.type-scale  = ( if buf_tmp#list.type-scale-enabled     = yes then substitute( "  &1", substring( p-options-string, 3, 1 ) ) else " ":U )
            buf_tmp#list.type-val    = ( if buf_tmp#list.type-val-enabled       = yes then substitute( "  &1", substring( p-options-string, 4, 1 ) ) else " ":U )
            buf_tmp#list.sort-name   = ( if buf_tmp#list.sort-name-enabled      = yes then substitute( "  &1", substring( p-options-string, 5, 1 ) ) else " ":U )
            buf_tmp#list.sort-gr     = ( if buf_tmp#list.sort-gr-enabled        = yes then substitute( "  &1", substring( p-options-string, 6, 1 ) ) else " ":U )
            buf_tmp#list.print-graft = ( if buf_tmp#list.print-graft-enabled    = yes then substitute( "  &1", substring( p-options-string, 7, 1 ) ) else " ":U )
            buf_tmp#list.no-vat      = ( if buf_tmp#list.no-vat-enabled         = yes then substitute( "  &1", substring( p-options-string, 8, 1 ) ) else " ":U )
        .
    end.
    end procedure.
    procedure menu-doc-create-options-enabled-string :
    define input parameter p-tmp-list-id                as integer          no-undo.
    define output parameter p-options-enabled-string    as character        no-undo.
        define buffer buf_tmp#list      for tmp#list.
    do
    for buf_tmp#list
    on error undo, return error
    :
        find first buf_tmp#list
             where buf_tmp#list.id = p-tmp-list-id
        .
        assign
            p-options-enabled-string =  ( if buf_tmp#list.type-parts-enabled  = yes then "+":U else "-":U )
                                      + ( if buf_tmp#list.type-price-enabled  = yes then "+":U else "-":U )
                                      + ( if buf_tmp#list.type-scale-enabled  = yes then "+":U else "-":U )
                                      + ( if buf_tmp#list.type-val-enabled    = yes then "+":U else "-":U )
                                      + ( if buf_tmp#list.sort-name-enabled   = yes then "+":U else "-":U )
                                      + ( if buf_tmp#list.sort-gr-enabled     = yes then "+":U else "-":U )
                                      + ( if buf_tmp#list.print-graft-enabled = yes then "+":U else "-":U )
                                      + ( if buf_tmp#list.no-vat-enabled      = yes then "+":U else "-":U )
        .
    end.
    end procedure.
    procedure menu-doc-extend-blank-name-for-IBS :
    define input parameter p-in-blank-name      as character        no-undo.
    define input parameter p-sys-key            as character        no-undo.
    define input parameter p-sys-key-black      as character        no-undo.
    define output parameter p-out-blank-name    as character        no-undo.
    do
    on error undo, return error
    :
        assign
            p-out-blank-name = p-in-blank-name
        .
        if p-sys-key <> "":U
        then do:
            assign
                p-out-blank-name = substring( p-in-blank-name + " '" + p-sys-key + "'" , 1, 120 )
            .
        end.
        if p-sys-key-black <> ""
        then do:
            assign
                p-out-blank-name = substring( p-in-blank-name + " no-'" + p-sys-key-black + "'", 1, 120 )
            .
        end.
    end.
    end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable ii as int no-undo .
define variable Nesoot_Flag  as logical  no-undo .
define variable stat                 as logical  no-undo .
define variable in-docprvalue as character no-undo.
define variable in-docprtype  as character no-undo.
define variable List_  as character no-undo.
define variable sys-key as char no-undo.
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
define buffer buf_init_fbr-pln       for ub.fbr-pln.
DEFINE BUTTON b-erase
     LABEL "&Снять все *":L
     size 13.13 by 1 TOOLTIP "Снять все отметки"
     BGCOLOR 8 .
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход ":L
     size 10 by 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "&Помощь":L
     size 10 by 1
     BGCOLOR 8 .
DEFINE BUTTON b-mark
     LABEL "&*":L
     size 3.63 by 1
     BGCOLOR 8 .
DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     size 10 by 1
     BGCOLOR 8 .
DEFINE VARIABLE v-printer-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Текущий принтер"
      VIEW-AS TEXT
     SIZE 46.13 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY BROWSE-2 FOR
      Tmp#List SCROLLING.
DEFINE BROWSE BROWSE-2
  QUERY BROWSE-2 DISPLAY
      Tmp#List.last-use COLUMN-LABEL "*" FORMAT "*/"
      Tmp#List.blank-name COLUMN-LABEL "Название документа":C59 FORMAT "X(59)"
  ENABLE
      Tmp#List.last-use
    WITH NO-BOX NO-ROW-MARKERS SEPARATORS SIZE 63.88 BY 19.21.
DEFINE FRAME Dialog-Frame
     b-exit at row 1.04 col 2.13
     b-mark at row 1.04 col 12.13
     b-erase at row 1.04 col 15.88
     b-print at row 1.04 col 44.88
     b-help at row 1.04 col 55
     BROWSE-2 AT ROW 2.25 COL 1.38
     v-printer-name AT ROW 22 COL 17 COLON-ALIGNED
     SPACE(1.11) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       BROWSE-2:MAX-DATA-GUESS IN FRAME Dialog-Frame     = 200.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON ROW-DISPLAY OF BROWSE-2 IN FRAME Dialog-Frame
DO:
if Tmp#List.orient = 'A4port' OR
   Tmp#List.orient = 'A3port'
     then DO:
      Tmp#List.last-use          :fgcolor in browse BROWSE-2 = blue_color.
      Tmp#List.blank-name        :fgcolor in browse BROWSE-2 = blue_color.
  End.
  Else DO:
      if Tmp#List.orient = 'EXCEL' OR
        Tmp#List.orient = 'self'
          then DO:
              Tmp#List.last-use   :fgcolor in browse BROWSE-2 = CYAN_COLOR.
              Tmp#List.blank-name :fgcolor in browse BROWSE-2 = CYAN_COLOR.
          end.
          Else DO:
              Tmp#List.last-use   :fgcolor in browse BROWSE-2 = black_color.
              Tmp#List.blank-name :fgcolor in browse BROWSE-2 = black_color.
          End.
  End.
END.
ON CHOOSE OF b-erase IN FRAME Dialog-Frame
DO:
  For each Tmp#List share-lock :
      Tmp#List.last-use=false.
  End.
    OPEN QUERY BROWSE-2 FOR EACH Tmp#List NO-LOCK where     Tmp#List.view_ <> 0     BY Tmp#List.cli-code.
END.
ON CHOOSE OF b-mark IN FRAME Dialog-Frame
OR MOUSE-SELECT-DBLCLICK OF BROWSE-2 IN FRAME Dialog-Frame
DO:
    if not available tmp#list
    then do:
        message "Неправильный выбор строки.".
        return no-apply.
    end.
    BROWSE-2 :refresh ().
    if Tmp#List.last-use = true
    then do:
        assign
            Tmp#List.last-use = false
        .
        display
            "" @ Tmp#List.last-use
        with browse BROWSE-2.
    end.
    else do:
        assign
            Tmp#List.last-use = true
        .
        display
            "*" @ Tmp#List.last-use
        with browse BROWSE-2.
    end.
    apply "VALUE-CHANGED" to BROWSE-2 in frame Dialog-Frame.
    assign
        g#log = BROWSE-2:select-next-row ()
    .
END.
ON CHOOSE OF b-print IN FRAME Dialog-Frame
DO:
    define variable lok as logical no-undo .
    define variable         PrintDoc              as      logical no-undo .
    define variable         PrintSet              as      logical no-undo .
    define variable         Print-Round           AS      LOGICAL INITIAL yes no-undo .
    define variable l-recid as recid no-undo .
    Assign
        List_ = ''
        ii = 0
        l-recid = recid(Tmp#List)
    .
    For each Tmp#List
    :
        if Tmp#List.last-use <> false
        then Assign
            ii = ii + 1
            List_ = List_ + ',' + string(tmp#list.id)
        .
    End.
    if ii = 0
    then do:
        Message
            "Отметьте формы документа для печати!"
        view-as alert-box information
        title "Внимание !".
        find first Tmp#List no-lock
             where l-recid = recid(Tmp#List)
        .
        return no-apply.
    end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input v-cntxt-obj-type
  ,input v-cntxt-obj-code
  ,input 'prt-obj':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'in-docpr' then in-docprvalue =  thbjattr_thbj-attr.property-value-character .
end.
 find first ubflt.usr-flt exclusive-lock
      where ubflt.usr-flt.user-name = v-cntxt-userid
        and ubflt.usr-flt.call-point  = String( buf_init_fbr-pln.doc-type)
                                  + ",no,"
                                  + String(  buf_init_fbr-pln.status_ ) + ",no"
 no-error .
if g#quest-print = true  THEN DO:
   output  to value( string( session:temp-directory + "$" + string( g#report-num ) ) ) .
   OUTPUT CLOSE.
End.
    for each Tmp#List no-lock
        where Tmp#List.last-use = true
    :
        case num-entries(tmp#list.proc-param)
        :
            when 0
            then do:
                run value (tmp#list.proc-name)  (
                      input p-mainmenu-handle
                    , input rec_id
                ).
            end.
            when 1
            then do:
                run value (tmp#list.proc-name)  (
                      input p-mainmenu-handle
                    , input rec_id
                    , input tmp#list.proc-param
                ).
            end.
            when 2
            then do:
                run value (tmp#list.proc-name)  (
                      input p-mainmenu-handle
                    , input rec_id
                    , input entry(1,tmp#list.proc-param)
                    , input entry(2,tmp#list.proc-param)
                ).
            end.
            when 3
            then do:
                run value (tmp#list.proc-name)  (
                      input p-mainmenu-handle
                    , input rec_id
                    , input entry(1,tmp#list.proc-param)
                    , input entry(2,tmp#list.proc-param)
                    , input entry(3,tmp#list.proc-param)
                ).
            end.
            when 4
            then do:
                message
                    "Для документа производства число параметров не может быть больше 3"
                view-as alert-box.
                undo, return no-apply .
            end.
        end case.
    end.
if session :set-wait-state( "" ) then.
    if g#quest-print = true
    then do:
        OS-DELETE
           value( string( session:temp-directory) + "rpt" + string( g#report-num )  )    .
        OS-RENAME
           value(  string( session:temp-directory) + "$" + string( g#report-num )     )
           value(  string( session:temp-directory) + "rpt" + string( g#report-num )) .
        IF ii = 1 and
            ((can-find (first tmp#list where CAPS(Tmp#list.proc-name) = "rep/xl-prtcl.p":U and Tmp#List.last-use = true) = true  ) OR
             (can-find (first tmp#list where CAPS(Tmp#list.proc-name) = "rep/tick-doc.p":U and Tmp#List.last-use = true) = true  ))
             THEN do:
if session :set-wait-state( "" ) then.
             end.
             ELSE DO :
              find first tmp#list where  Tmp#List.last-use = true no-lock no-error .
                define variable v-user-action           as character            no-undo.
                define variable v-printed               as logical              no-undo.
              case Tmp#list.orient :
                  when 'A4port' then do:
                        run gbl/prnfilen.w (
                              input "":U
                            , input 4
                            , input string( session :temp-directory ) + "rpt" + string( g#report-num )
                            , 7
                            , output v-user-action
                            , output v-printed
                        ) .
                  end.
                  when 'A4lans' or when "" then do:
                        run gbl/prnfilen.w (
                              input "":U
                            , input 8
                            , input string( session :temp-directory ) + "rpt" + string( g#report-num )
                            , 7
                            , output v-user-action
                            , output v-printed
                        ) .
                  end.
              End case.
             End.
    end.
    Else do:
        message
            "Задание распечатано"
        view-as alert-box information.
    end.
END.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse BROWSE-2 :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in p-mainmenu-handle
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).
    find first buf_init_fbr-pln no-lock
        where recid(buf_init_fbr-pln) = rec_id
    .
    if valid-handle(active-window)
    and frame Dialog-Frame:parent eq ?
    then do:
        assign
            FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW
        .
    end.
    assign
        v-printer-name = session:printer-name
    .
    run load-menu in this-procedure (
          input buf_init_fbr-pln.doc-code
        , input buf_init_fbr-pln.doc-type
        , input buf_init_fbr-pln.status_
        , input "'*'"
        , input "'*'"
    ).
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    RUN enable_UI.
    Tmp#List.last-use      :read-only in browse BROWSE-2 =  true .
        ASSIGN frame Dialog-Frame:TITLE =  "Печать документа  "
    + " Тип: " + buf_init_fbr-pln.doc-type
    + " Статус: " + buf_init_fbr-pln.status_
    + "  № "  + buf_init_fbr-pln.doc-code.
    WAIT-FOR GO OF FRAME Dialog-Frame focus BROWSE-2.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-printer-name
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-mark b-erase b-print b-help BROWSE-2 v-printer-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-2 FOR EACH Tmp#List NO-LOCK where     Tmp#List.view_ <> 0     BY Tmp#List.cli-code.
END PROCEDURE.
PROCEDURE Load-menu :
define input parameter p-doc-code   as character        no-undo.
define input parameter xtype        as character        no-undo.
define input parameter xstatus      as character        no-undo.
define input parameter xInternal    as character        no-undo.
define input parameter xflag        as character        no-undo.
    define buffer buf_usr-flt for ubflt.usr-flt .
do
for buf_usr-flt
on error undo, return error
:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile:currsysk.i $ $Revision: $".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run currsysk in g#library
  (output v-menu-doc-sys-key
  ) no-error .
    assign
        v-menu-doc-doc-code = p-doc-code
        v-menu-doc-doc-type = xtype
        v-menu-doc-status_  = xstatus
        v-menu-doc-internal = xInternal
        v-menu-doc-flag     = xflag
        sys-key             = v-menu-doc-sys-key
    .
define variable vss-include-info20 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info21 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'план-меню':U
           , input 'факт,разрешен':U
           , input '*'
           , input '*'
           , input 'Требование в кладовую'
           , input 'cost,sale,rubl,base'
           , input 'rep/op-3.p'
           , input ''
           , input '------'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info22 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'план-меню':U
           , input '*'
           , input '*'
           , input '*'
           , input 'План-меню'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-respln.p'
           , input ''
           , input '------'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info23 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'план-меню':U
           , input 'факт':U
           , input '*'
           , input '*'
           , input 'МЕНЮ'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-resmn.p'
           , input ''
           , input '------'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info24 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'план-меню':U
           , input 'факт':U
           , input '*'
           , input '*'
           , input 'Калькуляционные карточки по план-меню'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-res2.p'
           , input ''
           , input '------'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info25 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'план-меню':U
           , input 'факт,разрешен':U
           , input '*'
           , input '*'
           , input 'Технологические карты по план-меню'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-restk.p'
           , input ''
           , input '------'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info26 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'план-меню':U
           , input 'разрешен':U
           , input '*'
           , input '*'
           , input 'Нехватка продуктов'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-res3.p'
           , input ''
           , input '------'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info27 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'счет-заказ':U
           , input 'факт':U
           , input '*'
           , input '*'
           , input 'Калькуляционные карточки по счет-заказу'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-res2.p'
           , input ''
           , input '------'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info28 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'счет-заказ':U
           , input 'разрешен':U
           , input '*'
           , input '*'
           , input 'Нехватка продуктов'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-res3.p'
           , input ''
           , input '------'
           , input ''
           , input 'A4port'
           , input ''
        ).
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name  = v-cntxt-userid
           and buf_usr-flt.call-point = string(buf_init_fbr-pln.doc-type) + ",no,"
                                    + string(buf_init_fbr-pln.status_ ) + ",no"
    no-error.
    if available buf_usr-flt
    then do:
        assign
            list_        = buf_usr-flt.list_
        .
    end.
    else do:
        create buf_usr-flt.
        assign
            buf_usr-flt.user-name    = v-cntxt-userid
            buf_usr-flt.call-point   = string( buf_init_fbr-pln.doc-type) + ",no," +
                                string(  buf_init_fbr-pln.status_ ) + ",no"
        .
    end.
end.
END PROCEDURE.
