block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: z-tot5.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/z-tot5.p $":U .
define variable vss-description as character no-undo init " Вывод расчета заказа в EXCEL ".
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
define shared temp-table tmp#zakaz1 no-undo like ub.ord-line field sum       as decimal   field all-day   as integer   field qnty-sale as decimal   field negative-rest as logical    field gds-name  as character field unit-base as character field unit-type as character field unit-cli-type as character field min-order     as decimal   field service-order as decimal field local-mark    as character field max-stock     as decimal   field season-coef   as decimal   field min-stock-old as decimal   field gds-way       as decimal   index pi is unique primary artic prod-type prod-code  ascending index idx-ln line-num.
define shared temp-table tmp#zakaz-prn1 no-undo field artic         like ub.goods.artic      field prod-type     like ub.goods.prod-type  field prod-code     like ub.goods.prod-code  field obj-type      like ub.clients.obj-type field obj-code      like ub.clients.obj-code field prt-code      as   integer    field qnty-sale     as   decimal    field qnty-ord      as   decimal    index pi is unique primary artic prod-type prod-code obj-type obj-code prt-code  ascending.
define shared temp-table tmp#zakaz-dtl1 no-undo like ub.ord-dtl field prt-name as character index bi is unique primary artic prod-type prod-code node-code  ascending.
define  shared buffer clients-doc for ub.clients   .
define  buffer clients-doc1 for ub.clients   .
define  buffer clients-doc2 for ub.clients   .
define  shared buffer buf-goods   for ub.goods     .
define  shared buffer sb-cli-gds  for ub.cli-gds   .
define  shared buffer sb-gds-obj  for ub.gds-obj   .
define  shared buffer tmp#zakaz     for tmp#zakaz1.
define  shared buffer tmp#zakaz-prn     for tmp#zakaz-prn1.
define  shared buffer tmp#zakaz-dtl for tmp#zakaz-dtl1.
define buffer buf_contract for ub.contract .
define  shared  buffer shar_ord-doc  for ub.ord-doc .
define  shared  buffer shar_ord-line for ub.ord-line.
define  shared  buffer shar_ord-dtl  for ub.ord-dtl .
define  shared variable chexcelapplication      as com-handle no-undo .
define  shared variable chworkbook              as com-handle no-undo .
define  shared variable chworksheet             as com-handle no-undo .
define  shared variable chrange                 as com-handle no-undo .
define  shared variable chworksheet2            as com-handle no-undo .
define  shared variable chworksheet3            as com-handle no-undo .
define  shared variable accum-zakaz             as decimal no-undo .
define  shared variable accum-sum-zakaz         as decimal no-undo .
define  shared variable accum-count             as integer no-undo .
define  shared buffer buf-cli for ub.clients.
define  shared variable loc-obj-name as character format "x(256)":u
     view-as text
     size 39.25 by 1 tooltip "Поставщик"
     fgcolor 4  no-undo.
define  shared variable agnt as integer format ">>>>>>>>>" initial ?
     label "И&сп"
     view-as fill-in tooltip "Код исполнителя"
     size 9.75 by 1 no-undo.
define  shared  variable boss as integer format ">>>>>>>>>" initial ?
     label "&М-р"
     view-as fill-in    tooltip "Код менеджера"
     size 9.75 by 1 no-undo.
define    shared  variable date-1 as date format "99/99/9999":u
     label "Период с"
     view-as fill-in   tooltip "Период, для которого рассчитан темп продаж"
     size 11 by 1 fgcolor 1 no-undo.
define    shared  variable date-2 as date format "99/99/9999":u
     label "по"
     view-as fill-in  tooltip "Период, для которого рассчитан темп продаж"
     size 11 by 1 fgcolor 1 no-undo.
define    shared  variable date-sale-1 as date format "99/99/9999":u
     label "Для продажи с"
     view-as fill-in   tooltip "Период продаж товара"
     size 11 by 1  no-undo.
define    shared  variable date-sale-2 as date format "99/99/9999":u
     label "по"
     view-as fill-in  tooltip "Период продаж товара"
     size 11 by 1  no-undo.
define    shared  variable loc-cli-code as integer format ">>>>>>>>>" initial ?
     view-as fill-in
     size 9.75 by 1 tooltip "Код Поставщика" no-undo.
define    shared  variable loc-cli-type as character format "x(3)":u initial "орг"
     label "Код"
     view-as fill-in
     size 5.13 by 1 tooltip "Тип Поставщика" no-undo.
define    shared  variable loc-date-ship as date format "99/99/9999":u
     label "&Заказ на"
     view-as fill-in
     size 11 by 1 tooltip "Дата, на которую формируется заказ"
     fgcolor 4
     no-undo.
define    shared  variable loc-ord-num as character format "x(256)":u
     label "№"
     view-as text
     size 14 by 1
     fgcolor 4
     no-undo.
define    shared  variable wrkr as integer format ">>>>>>>>>" initial ?
     label "К&л-к"
     view-as fill-in
     size 9.75 by 1 tooltip "Код кладовщика"
     no-undo.
define    shared  variable loc-service as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Ст-ть обслу&живания"
     view-as fill-in
     size 14 by 1 tooltip "Стоимость обслуживания" no-undo.
define    shared  variable paytype as integer format "99999" initial ?
     label "Опл"
     view-as fill-in
     size 7.75 by 1 tooltip "Код типа оплаты"
     no-undo.
define   shared  variable loc-time-ship as character
      view-as fill-in
      size 7 by 1 tooltip "Время доставки" no-undo.
define   shared  variable loc-hour as integer format "99":u initial 0
     view-as fill-in
     size 3.5 by 1 no-undo.
define   shared  variable loc-min as integer format "99":u initial 0
     view-as fill-in
     size 3.5 by 1 no-undo.
define   shared  variable cycle-day as integer format ">>>":u initial 0
     label "через"
     view-as fill-in
     size 4.75 by 1
     fgcolor 4
     no-undo.
define  shared  variable pay-day as integer format ">>9":u initial 1
     label "На дней продаж"
     view-as fill-in
     size 7.13 by 1
     fgcolor 4
     no-undo.
define    shared  variable tog-type as int initial 0
     label "цкл"
     view-as radio-set horizontal radio-buttons
     "П",0,
     "Ц",1,
     "О",4
     size 11 by 1 tooltip "Тип заказа : простой,цикличный,объединенный цикличный" no-undo.
define  shared variable loc-status  as character  no-undo.
define  shared variable loc-base-rate as decimal format "->,>>>,>>>,>>>,>>9.9999":u initial 0
     label "Кур&с б.в."
     view-as fill-in
     size 9.4 by 1 no-undo.
define  shared variable loc-base-scale as integer format ">,>>>,>>9":u initial 0
     label "М&-б"
     view-as fill-in
     size 3.5 by 1 no-undo.
define  shared variable loc-cli-qnty as decimal format "->,>>>,>>>,>>>,>>9.999":u initial 0
     label "Кол.п-ка"
     view-as text
     size 14 by 0.67
     tooltip "Количество в ед.из. поставщика"
     fgcolor 4
     no-undo.
define  shared variable loc-exch-code as integer format "->,>>>,>>9":u initial 0
     label "Вал&."
     view-as fill-in
     size 7 by 1
     no-undo.
define  shared variable loc-exch-rate as decimal format "->,>>>,>>>,>>>,>>9.9999":u initial 0
     label "Курс п&-ка"
     view-as fill-in
     size 9.4 by 1
     no-undo.
define  shared variable loc-exch-scale as integer format ">,>>>,>>9":u initial 0
     label "М&-б"
     view-as fill-in
     size 3.5 by 1
     no-undo.
define  shared variable loc-out-code as character format "x(256)":u
     label "№ Поставки"
     view-as fill-in
     size 9.38 by 1 tooltip "Номер документа поставки по данному заказу"
     no-undo.
define  shared variable loc-cli-out-doc  as character format "x(256)":u
     label "№ Заказа по пост"
     view-as fill-in
     size 14 by 1 tooltip "Номер заказа в системе учета поставщика"
     no-undo.
define  shared variable loc-qnty as decimal format "->,>>>,>>>,>>>,>>9.999":u initial 0
     label "Кол-во"
     view-as text
     size 14 by 0.67 tooltip "Количество по заказу в баз.ед."
     fgcolor 4
     no-undo.
define  shared variable loc-sum-base as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(б.в.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа(б.в.)"
     fgcolor 4
     no-undo.
define  shared variable loc-sum-cli as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(в.п.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа в вал. поставщика"
     fgcolor 4
     no-undo.
define  shared variable loc-sum-rubl as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(руб.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа(руб)"
     fgcolor 4
     no-undo.
define  shared variable loc-tot-lines as integer format "->,>>>,>>9":u initial 0
     label "Строк"
     view-as text
     size 7.38 by .67 tooltip "Контрольное количество строк в заказе"
     fgcolor 4
     no-undo.
define  shared variable doc-date as date format "99/99/99":u
     label "&Дата"
     view-as text
     size 9 by .67 tooltip "Дата документа"
     no-undo.
define  shared variable fact-date as date format "99/99/99":u
     label "&Факт"
     view-as text
     size 9 by .67 tooltip "Дата документа фактическая"
     fgcolor 4
     no-undo.
define  shared var loc-print-rubl as logical no-undo .
define  shared variable slt_type as character format "x(256)":u
     label "НсП"
     view-as combo-box inner-lines 3
     list-items
        'без':U,
        'нет':U,
        'в т. ч.':U
     size 9.75 by 1
     no-undo.
define  shared  variable vat_type as character format "x(256)":u
     label "НДС"
     view-as combo-box inner-lines 3
     list-items
        'без':U,
        'нет':U,
        'в т. ч.':U
     size 9.75 by 1
     no-undo.
define  shared  variable e-method as character
     view-as editor scrollbar-vertical
     size 30 by 3.42 tooltip "Метод расчета темпа продаж и количества заказа/заявки"
     bgcolor 8
     no-undo.
define    shared  variable loc-contract as integer
     label "Вн.№ дог-ра"
     view-as fill-in
     size 10 by 1 tooltip "Номер договора"
     format ">>>>>>>>>"
     fgcolor 1
     no-undo.
define  shared  variable loc-store-code like ub.ord-doc.obj-code no-undo .
define  shared  variable loc-store-type like ub.ord-doc.obj-type no-undo .
define  shared  variable loc-doc-type   like ub.ord-doc.doc-type no-undo .
define  shared  variable temp-e-method  as character no-undo .
define  shared  variable x-tog-artic as logical   no-undo .
define  shared  variable x-tog-grp    as logical   no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table export-ras no-undo like ub.ord-line field sum       as decimal   field all-day   as integer   field qnty-sale as decimal   field negative-rest as logical    field gds-name  as character field unit-base as character field unit-type as character field unit-cli-type as character field min-order     as decimal   field service-order as decimal field max-stock     as decimal   field local-mark    as character field ostatok-today as decimal    field gds-way-all as decimal index pi1 is unique primary       artic                       prod-type                   prod-code                   obj-type                    obj-code                    ascending             .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION determined RETURNS DECIMAL (INPUT parundefine-var AS DECIMAL):
   IF parundefine-var = ? THEN RETURN 0.00.
                          ELSE RETURN parundefine-var.
END FUNCTION.
FUNCTION dtm-char RETURNS CHARACTER (INPUT p-undef-char AS CHARACTER):
   IF p-undef-char = ? THEN do:
     RETURN "?".
   end.
   ELSE do:
     RETURN p-undef-char .
   end.
END FUNCTION.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxp-doc-prt         like ub.store.doc-prt         no-undo.
  define variable v-cntxp-price-calc      like ub.store.price-calc      no-undo.
  define variable v-cntxp-inout-price     like ub.store.inout-price     no-undo.
  define variable v-cntxp-unit-cli-perm   like ub.store.unit-cli-perm   no-undo.
  define variable v-cntxp-out-rate        like ub.store.out-rate        no-undo.
  define variable v-cntxp-out-line-discnt like ub.store.out-line-discnt no-undo.
  define variable v-cntxp-in-ov           like ub.store.in-ov           no-undo.
  define variable v-cntxp-in-perm         like ub.store.in-perm         no-undo.
  define variable v-cntxp-no-eq           like ub.store.no-eq           no-undo.
  define variable v-cntxp-rsrv-time       like ub.store.rsrv-time       no-undo.
  define variable v-cntxp-load-time       like ub.store.load-time       no-undo.
  define variable v-cntxp-holidays        like ub.store.holidays        no-undo.
  define variable v-cntxp-in-pay          like ub.store.in-pay          no-undo.
  define variable v-cntxp-out-pay         like ub.store.out-pay         no-undo.
  define variable v-cntxp-ret-pay         like ub.store.ret-pay         no-undo.
  define variable v-cntxp-ret-sup-pay     like ub.store.ret-sup-pay     no-undo.
  define variable v-cntxp-down-pay        like ub.store.down-pay        no-undo.
  define variable v-cntxp-inv-pay         like ub.store.inv-pay         no-undo.
  define variable v-cntxp-chk-pay         like ub.store.chk-pay         no-undo.
  define variable v-cntxp-retail          like ub.sysconf.ord-prt       no-undo.
  define variable v-cntxp-osn-base        like ub.sysconf.osn-base      no-undo.
  define variable v-cntxp-conf-par        as   character                no-undo.
  define variable v-cntxp-par-type        as   character                no-undo.
  define variable v-cntxp-curr-host-code  like ub.store.host-code       no-undo.
  define variable v-cntxp-obj-type        like ub.clients.obj-type      no-undo.
  define variable v-cntxp-obj-code        like ub.clients.obj-code      no-undo.
  define variable v-cntxp-db-num          as integer   no-undo .
  define variable v-cntxp-userid          as character no-undo .
  define variable v-cntxp-level           as character no-undo .
  define variable v-cntxp-db-num-obj      as integer   no-undo .
  define variable v-cntxp-is-admin        as logical   no-undo .
  define buffer bf-cntxp_store for ub.store.
  define buffer bf-cntxp_shop  for ub.shop.
  define buffer bf-cntxp_sysconf for ub.sysconf.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info15, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info15, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
define input parameter parParentProc  as widget-handle no-undo .
define input parameter TABLE FOR export-ras .
define input parameter p-ord-doc as character no-undo .
define input parameter p-e-method as character no-undo .
define input parameter p-prt-all as logical   no-undo .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxp-db-num
    ,output v-cntxp-userid
    ,output v-cntxp-level
    ,output v-cntxp-curr-host-code
    ,output v-cntxp-obj-type
    ,output v-cntxp-obj-code
    ,output v-cntxp-db-num-obj
    ,output v-cntxp-is-admin
    ) .
  if (v-cntxp-obj-type = 'маг':U or v-cntxp-obj-type = 'скл':U) and
     v-cntxp-obj-code <> 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output v-cntxp-conf-par
  ,output v-cntxp-par-type
  ) no-error .
    case v-cntxp-obj-type :
      when 'скл':U then do:
        find first bf-cntxp_store where bf-cntxp_store.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_store.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_store.doc-prt
          v-cntxp-price-calc      = bf-cntxp_store.price-calc
          v-cntxp-inout-price     = bf-cntxp_store.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_store.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_store.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_store.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_store.in-ov
          v-cntxp-in-perm         = bf-cntxp_store.in-perm
          v-cntxp-no-eq           = bf-cntxp_store.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_store.rsrv-time
          v-cntxp-load-time       = bf-cntxp_store.load-time
          v-cntxp-holidays        = bf-cntxp_store.holidays
          v-cntxp-in-pay          = bf-cntxp_store.in-pay
          v-cntxp-out-pay         = bf-cntxp_store.out-pay
          v-cntxp-ret-pay         = bf-cntxp_store.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_store.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_store.down-pay
          v-cntxp-inv-pay         = bf-cntxp_store.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_store.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
      when 'маг':U then do:
        find first bf-cntxp_shop where bf-cntxp_shop.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_shop.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_shop.doc-prt
          v-cntxp-price-calc      = bf-cntxp_shop.price-calc
          v-cntxp-inout-price     = bf-cntxp_shop.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_shop.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_shop.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_shop.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_shop.in-ov
          v-cntxp-in-perm         = bf-cntxp_shop.in-perm
          v-cntxp-no-eq           = bf-cntxp_shop.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_shop.rsrv-time
          v-cntxp-load-time       = bf-cntxp_shop.load-time
          v-cntxp-holidays        = bf-cntxp_shop.holidays
          v-cntxp-in-pay          = bf-cntxp_shop.in-pay
          v-cntxp-out-pay         = bf-cntxp_shop.out-pay
          v-cntxp-ret-pay         = bf-cntxp_shop.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_shop.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_shop.down-pay
          v-cntxp-inv-pay         = bf-cntxp_shop.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_shop.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
    end case.
  end.
define variable base-type as character no-undo .
define variable base-code as integer   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#gds-engl as logical   no-undo .
define variable g#log as logical   no-undo .
define variable par-ord-min-ost as logical   no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable p-type as character no-undo .
define variable v-param-value as character no-undo .
for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
par-ord-min-ost = false .
define variable v-cntxt-host-name-obj as character no-undo .
define buffer buf_rep_currency for ub.currency.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-cntxt-host-code-obj
  ,output v-cntxt-host-name-obj
  )  .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
find first buf_rep_currency no-lock
  where buf_rep_currency.curr-code = base-code
  no-error .
  if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
               else base-type = "б.в." .
run get-report-num in parParentProc ( output g#report-num ).
define buffer buf_ord-doc  for ub.ord-doc.
define buffer buf_ord-line for ub.ord-line.
define buffer buf_cli-gds  for ub.cli-gds.
define variable max-col as integer no-undo .
max-col = 32.
define variable v-today as date      no-undo .
define variable v-time  as integer   no-undo .
define variable kol-obj as integer no-undo .
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
define variable str--1 as character Format "x(60)" no-undo.
define variable str--2 as integer no-undo .
define variable C-i    as integer no-undo .
define variable p-var  as integer no-undo .
define variable num#col# as integer no-undo .
define variable var-1 as integer no-undo .
define variable var-2 as integer no-undo .
define variable var-3 as integer no-undo .
define variable  p-obj-type like ub.ord-doc.obj-type no-undo .
define variable  p-obj-code like ub.ord-doc.obj-code no-undo .
define variable  p-cli-type like ub.ord-doc.cli-type no-undo .
define variable  p-cli-code like ub.ord-doc.cli-code no-undo .
define variable  p-doc-type as character no-undo .
define variable  p-doc-date as date no-undo .
define variable  p-ship-date like ub.ord-doc.ship-date no-undo .
define variable  p-ship-time like ub.ord-doc.ship-time no-undo .
define variable  p-host-code like ub.ord-doc.host-code no-undo .
define variable is-l as integer no-undo .
FUNCTION excel-qnty-null RETURNS char (INPUT p-dec as decimal ).
if p-dec = 0 then Return ("").
   else RETURN(format-excel-text(excel-format-dec-to-char(Round(p-dec,3)))) .
END FUNCTION.
main-block :
do on error undo main-block, return error
:
run adm/shattri.p (
  input "get":U
  ,input ""
  ,input 0
  ,input 'ord-global':U
  ,input 'ord-min-ost-day':U
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output par-ord-min-ost
  ,output p-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  if error-status :error then par-ord-min-ost = false .
p-file-name =  string( session:temp-directory + "rpt" + string( g#report-num ) + ".txt" ) .
output stream outstream to value( string( session:temp-directory + "rpt" + string( g#report-num ) ) )      .
output stream outstream2 to value(p-file-name).
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
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output to-day
  )  .
find first buf_ord-doc no-lock where  buf_ord-doc.doc-code = p-ord-doc no-error .
if error-status :error then do:
  assign
    p-obj-type  = loc-store-type
    p-obj-code  = loc-store-code
    p-cli-type  = loc-cli-type
    p-cli-code  = loc-cli-code
    p-doc-type  = loc-doc-type
    p-doc-date  = doc-date
    p-ship-date = loc-date-ship
    p-host-code = v-cntxt-host-code-obj
    .
end.
else do:
  assign
    p-obj-type = buf_ord-doc.obj-type
    p-obj-code = buf_ord-doc.obj-code
    p-cli-type = buf_ord-doc.cli-type
    p-cli-code = buf_ord-doc.cli-code
    p-doc-type = buf_ord-doc.doc-type
    p-doc-date = buf_ord-doc.doc-date
    p-ship-date = buf_ord-doc.ship-date
    p-ship-date = loc-date-ship
    p-ship-time = buf_ord-doc.ship-time
    p-host-code = buf_ord-doc.host-code
    .
    if p-cli-type = ? or p-cli-code = ? then do:
        assign
        p-cli-type  =  loc-cli-type
        p-cli-code  =  loc-cli-code
        p-obj-type  =  loc-store-type
        p-obj-code  =  loc-store-code
        .
    end.
end.
find first ubflt.usr-flt  no-lock where
         ubflt.usr-flt.user-name = loc-ord-num and
         ubflt.usr-flt.call-point   = "ord-m":U  + "export":U   no-error .
         if not avail ubflt.usr-flt  then do:
          find first ubflt.usr-flt  no-lock where
                  ubflt.usr-flt.user-name = loc-ord-num and
                  ubflt.usr-flt.call-point   = "ord-m":U  no-error .
         end.
define variable i          as integer no-undo .
define variable R-algoritm as integer no-undo .
define variable R-min-rest as integer no-undo .
define variable v-nn as integer   no-undo .
v-nn = num-entries(ubflt.usr-flt.list_) .
  do i = 1 to v-nn :
     case  entry(1,(entry(i,ubflt.usr-flt.list_)), "=" ) :
        when string( "R-algoritm" )             then R-algoritm = integer(entry(2,(entry(i,ubflt.usr-flt.list_)), "=" )).
        when string( "date-p-1" ) then  date-1 = date(entry(2,(entry(i,ubflt.usr-flt.list_)), "=" )).
        when string( "date-p-2" ) then  date-2 = date(entry(2,(entry(i,ubflt.usr-flt.list_)), "=" )).
        when string( "R-min-rest" )             then R-min-rest = integer(entry(2,(entry(i,ubflt.usr-flt.list_)), "=" )).
        otherwise do:
        end.
     end case.
  end.
  kol-obj = num-entries( entry(2,ubflt.usr-flt.list_,"&" ) , ",") - 1 .
     if kol-obj  = ? then kol-obj  = 0 .
define variable p-name as character no-undo .
define buffer post-clients for ub.clients.
define buffer sh-clients for ub.clients.
find first sh-clients no-lock where
           sh-clients.obj-type =   p-obj-type and
           sh-clients.obj-code =   p-obj-code no-error  .
           if error-status :error then next.
find first post-clients no-lock where
           post-clients.obj-type =   p-cli-type and
           post-clients.obj-code =   p-cli-code no-error  .
           if error-status :error then next.
reportname =  ( if p-doc-type = 'ОФ':U then "Заявка " else  "Заказ " )
                + p-ord-doc +
               " от " +
               string( p-doc-date,"99/99/9999")
              .
 run mf in this-procedure .
 num#str#  = 0 .
 num#col# = 1 .
 num#str# = num#str# + 1 .
 run macr_excel_char_with_format in this-procedure ( reportname , num#str# , num#col#  ).
 run macr_cell_format in this-procedure
          ( 12    ,
            true  ,
            false ,
            ?     ,
            num#str# ,
            num#col# ,
            ? ,
            ?         ) .
    run make-str-1 in this-procedure .
    Output stream Macr_Excel  close .
    run paramls-write in this-procedure
      (input "file"
      ,input "Результат"
      ,input v-file-name
      ) .
    run mf in this-procedure .
    run make-str-3 in this-procedure .
    Output stream Macr_Excel  close .
    run paramls-write in this-procedure
      (input "file"
      ,input "Экспорт данных расчета заказа"
      ,input v-file-name
      ) .
 Output stream OutStream   close .
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
  run paramls-write in this-procedure
  (input "command"
  ,input ""
  ,input 'workbook.select("Экспорт данных расчета заказа","Экспорт данных расчета заказа")'
  ) .
  run paramls-write in this-procedure
        (input "charcol"
        ,input ""
        ,input "1,2,4,5,6,7"
        ) .
 run end-proc in this-procedure .
 run rep/runexcel.p ( string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txt").
 end.
def var vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure make-str-1 :
 do
 on error undo, return error return-value
 :
num#col# =  0.
num#str# = num#str# + 1 .
num#col# = num#col# + 1 .
p-name = "Артикул" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
num#col# = num#col# + 1 .
p-name = "Тип производителя " .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
num#col# = num#col# + 1 .
p-name = "Код производителя " .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
num#col# = num#col# + 1 .
p-name = "Название товара" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
num#col# = num#col# + 1 .
p-name = "Артикул поставщика" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
num#col# = num#col# + 1 .
p-name = "Цена в валюте поставщика в баз.ед.изм" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
num#col# = num#col# + 1 .
p-name = "Количество в баз.ед.изм" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
for each  buf_ord-line no-lock where  buf_ord-line.doc-code = p-ord-doc  ,
    first ub.goods no-lock where
          ub.goods.artic     = buf_ord-line.artic      and
          ub.goods.prod-type = buf_ord-line.prod-type  and
          ub.goods.prod-code = buf_ord-line.prod-code  break by ub.goods.gds-code :
    find first ub.clients no-lock where
          ub.goods.prod-type = ub.clients.obj-type and
          ub.goods.prod-code = ub.clients.obj-code no-error .
          if error-status :error then next.
    num#col# = 1 .
    num#str# = num#str# + 1 .
    run macr_excel_char_with_format in this-procedure ( buf_ord-line.artic , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_char_with_format in this-procedure ( buf_ord-line.prod-type , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_char_with_format in this-procedure ( buf_ord-line.prod-code , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_char_with_format in this-procedure ( ub.goods.gds-name , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_char_with_format in this-procedure ( (if buf_ord-line.cli-art <> ? then buf_ord-line.cli-art  else "") , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure ( determined ( buf_ord-line.price-cli / buf_ord-line.cli-base-rate ), num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure ( buf_ord-line.qnty       , num#str# , num#col#  ). num#col# = num#col# + 1 .
end.
 end.
end procedure.
procedure make-str-3 :
 do
 on error undo, return error return-value
 :
define variable loc-sum-min1 as character no-undo .
define variable loc-sum-min2 as character no-undo .
define variable loc-sum-min3 as character no-undo .
define variable t-type       as character no-undo .
define variable lp-in-qnty     as decimal no-undo .
define variable lp-out-qnty    as decimal no-undo .
define variable lp-out-sum     as decimal no-undo .
define variable lp-Temp-rash   as decimal no-undo .
define variable lp-min-stock   as decimal no-undo .
define variable lp-qnty-sale   as decimal no-undo .
define variable lp-zero-day    as decimal no-undo .
define variable lp-in-out-qnty as decimal no-undo .
define variable lp-supp-qnty   as decimal no-undo .
define variable lp-qnty-kassa  as decimal no-undo .
define variable lp-qnty-stk   as decimal no-undo .
define variable lp-qnty-prih  as decimal no-undo .
define variable lp-qnty-rash  as decimal no-undo .
 num#str# = 0 .
 num#col# = 1 .
 num#str# = num#str# + 1 .
 run macr_excel_char_with_format in this-procedure ( reportname , num#str# , num#col#  ).
 run macr_cell_format in this-procedure
          ( 12    ,
            true  ,
            false ,
            ?     ,
            num#str# ,
            num#col# ,
            ? ,
            ?         ) .
reportheader =   cur-time-print() .
num#str# = num#str# + 1 .
num#col# = 1 .
p-name = "Покупатель: " .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
num#col# =  4 .
run macr_excel_char_with_format in this-procedure ( sh-clients.obj-name , num#str# , num#col#  ).
num#str# = num#str# + 1 .
num#col# =  1 .
p-name = "Поставщик: " .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
num#col# =  4 .
run macr_excel_char_with_format in this-procedure ( post-clients.obj-name , num#str# , num#col#  ).
num#str# = num#str# + 1 .
num#col# = 1 .
p-name = "Дата печати: " .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
num#col# = 4 .
run macr_excel_char_with_format in this-procedure ( string( today ,"99/99/9999") , num#str# , num#col#  ).
num#str# = num#str# + 1 .
num#col# = 1 .
p-name = "Планируемая дата доставки: " .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
num#col# = 4 .
run macr_excel_char_with_format in this-procedure ( string( p-ship-date,"99/99/9999") , num#str# , num#col#  ).
num#col# = 5 .
run macr_excel_char_with_format in this-procedure ( "Время : " + string( p-ship-time,"hh:mm") , num#str# , num#col#  ).
 run macr_cell_format in this-procedure  (
        10       ,
        true     ,
        false    ,
        34       ,
        6        ,
        1        ,
        6        ,
        max-col )
        .
num#col# =  0 .
num#str# = num#str# + 1 .
num#col# = num#col# + 1 .
define variable p-fi as character no-undo .
define variable name-tt as character no-undo .
if loc-doc-type = 'ФП':U then do:
    p-fi  = " по фирме " .
end.
else do:
   p-fi  = " по объекту " .
end.
case R-algoritm :
  when 2 then do:
      name-tt =  "Темп продаж из списка" .
  end.
  when 4 then do:
      name-tt =  "Максимальная продажа" .
  end.
  otherwise do:
      name-tt =  "Темп продаж с " + String(date-1) + " по " + String(date-2) .
  end.
end case.
 run macr_excel_char_with_format in this-procedure ("Артикул"                                                         , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Название товара"                                                 , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 put  stream macr_excel unformatted  'COLUMN.WIDTH(30,,,,)'  skip.
 run macr_excel_char_with_format in this-procedure ("Ед.изм."                                                         , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Код производителя ", num#str# , num#col#  ).                                                num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Название производителя ", num#str# , num#col#  ).                                           num#col# = num#col# + 1 .
 put  stream macr_excel unformatted  'COLUMN.WIDTH(30,,,,)'  skip.
 run macr_excel_char_with_format in this-procedure ("Артикул контрагента"                                             , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Ед.изм. контрагента"                                             , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Кол-во приход по контрагенту"                                    , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Кол-во расход по контрагенту"                                    , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Продаж.цены(вал.продаж) расход"                                  , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Последн.цена контрагента на баз.ед.изм."                         , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Кол-во остатки по контрагенту"                                   , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Приход / Расход"                                                 , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Срок хранения"                                                   , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Коэффициент пересчета ед.изм."                                   , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Количество в упаковке"                                                  , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ( name-tt      , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("ЗАКАЗ кол-во"                                                    , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("ЗАКАЗ сумма"                                                     , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ( if R-algoritm = 2 then "Расход (не рассчитывается)" else "Расход с " + String(date-1) + " по " + String(date-2)            , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Дней без продаж и остатков"                                      , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Остаток на " + String(to-day)                              , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Приход "                                                   , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Внешний расход "                                           , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Касса "                                                    , num#str# , num#col#  ) . num#col# = num#col# + 1 .
define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
if R-min-rest = 1 then dO:
    run macr_excel_char_with_format in this-procedure ( "Минимальный остаток" , num#str# , num#col# ).    num#col# = num#col# + 1 .
    run macr_excel_char_with_format in this-procedure ( "Уровень постоянного присутствия", num#str# , num#col# ).    num#col# = num#col# + 1 .
    run macr_excel_char_with_format in this-procedure ( "Минимальный заказ" , num#str# , num#col# ).                 num#col# = num#col# + 1 .
end.
if R-min-rest = 2 then dO:
    run macr_excel_char_with_format in this-procedure ( "Минимальный остаток на фирме" , num#str# , num#col# ).    num#col# = num#col# + 1 .
    run macr_excel_char_with_format in this-procedure ( "Уровень постоянного присутствия на фирме", num#str# , num#col# ).    num#col# = num#col# + 1 .
    run macr_excel_char_with_format in this-procedure ( "Минимальный заказ на фирме" , num#str# , num#col# ).                 num#col# = num#col# + 1 .
end.
run macr_excel_char_with_format in this-procedure ("Код объекта ", num#str# , num#col#  ).       num#col# = num#col# + 1 .
run macr_excel_char_with_format in this-procedure ("Разрешены отриц.остатки ", num#str# , num#col#  ).       num#col# = num#col# + 1 .
run macr_excel_char_with_format in this-procedure ("В пути ", num#str# , num#col#  ).       num#col# = num#col# + 1 .
run macr_excel_char_with_format in this-procedure ("Дней в продаже ", num#str# , num#col#  ).       num#col# = num#col# + 1 .
  put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , 6  , 1 , num#str# ,  max-col ) + chr(10)  +
        'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + chr(10) +
       'ALIGNMENT(3 , , 4 , 4 ,)'  + chr(10)
       .
num#col# =  0.
define variable l-all-day as integer no-undo .
define variable s-in-qnty   as decimal no-undo .
define variable s-out-qnty  as decimal no-undo .
define variable s-out-sum   as decimal no-undo .
define variable s-supp-qnty as decimal no-undo .
define variable ss-in-qnty  as decimal no-undo .
define variable ss-out-qnty as decimal no-undo .
define variable ss-out-sum  as decimal no-undo .
define variable ss-supp-qnty as decimal no-undo .
define variable s-qnty       as decimal no-undo .
define variable s-sum-rubl   as decimal no-undo .
define variable s-qnty-rashkassa  as decimal no-undo .
define variable s-zero-day        as decimal no-undo .
define variable s-qnty-stk        as decimal no-undo .
define variable s-qnty-prih       as decimal no-undo .
define variable s-qnty-rash       as decimal no-undo .
define variable s-qnty-kassa      as decimal no-undo .
define variable s-min-stock       as decimal no-undo .
define variable s-service-order   as decimal no-undo .
define variable s-min-order       as decimal no-undo .
define variable s-gds-way-all     as decimal no-undo .
define variable s-l-all-day       as decimal no-undo .
define variable ss-qnty       as decimal no-undo .
define variable ss-sum-rubl   as decimal no-undo .
define variable ss-qnty-rashkassa  as decimal no-undo .
define variable ss-zero-day        as decimal no-undo .
define variable ss-qnty-stk        as decimal no-undo .
define variable ss-qnty-prih       as decimal no-undo .
define variable ss-qnty-rash       as decimal no-undo .
define variable ss-qnty-kassa      as decimal no-undo .
define variable ss-min-stock       as decimal no-undo .
define variable ss-service-order   as decimal no-undo .
define variable ss-min-order       as decimal no-undo .
define variable ss-gds-way-all     as decimal no-undo .
define variable ss-l-all-day       as decimal no-undo .
for each  export-ras where  break by export-ras.gds-code :
    find first ub.goods no-lock where
          ub.goods.artic     = export-ras.artic     and
          ub.goods.prod-type = export-ras.prod-type and
          ub.goods.prod-code = export-ras.prod-code no-error .
          if error-status :error then next.
    find first ub.clients no-lock where
          ub.goods.prod-type = ub.clients.obj-type and
          ub.goods.prod-code = ub.clients.obj-code no-error .
          if error-status :error then next.
    num#col# = 1 .
    num#str# = num#str# + 1 .
    if first-of(export-ras.gds-code) then do:
       assign
          s-in-qnty    = 0
          s-out-qnty   = 0
          s-out-sum    = 0
          s-supp-qnty  = 0
          s-qnty                 = 0
          s-sum-rubl             = 0
          s-qnty-rashkassa       = 0
          s-zero-day             = 0
          s-qnty-stk             = 0
          s-qnty-prih            = 0
          s-qnty-rash            = 0
          s-qnty-kassa           = 0
          s-min-stock            = 0
          s-service-order        = 0
          s-min-order            = 0
          s-gds-way-all          = 0
          s-l-all-day           = 0
        .
        run macr_excel_char_with_format in this-procedure ( export-ras.artic , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_char_with_format in this-procedure ( ub.goods.gds-name   , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_char_with_format in this-procedure ( ub.goods.unit-base  , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_char_with_format in this-procedure ( export-ras.prod-type + " " + string(export-ras.prod-code) , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_char_with_format in this-procedure ( ub.clients.obj-name      , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_char_with_format in this-procedure ( export-ras.cli-art    , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_char_with_format in this-procedure ( export-ras.unit-cli   , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_dec in this-procedure (  export-ras.in-qnty     , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_dec in this-procedure (  export-ras.out-qnty    , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_dec in this-procedure (  export-ras.out-sum     , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_dec in this-procedure (  determined ( export-ras.price-cli / export-ras.cli-base-rate )  , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_dec in this-procedure (  export-ras.supp-qnty   , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_dec in this-procedure (  determined (  export-ras.in-qnty / export-ras.out-qnty )    , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_dec in this-procedure (  ub.goods.deadline         , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_dec in this-procedure (  export-ras.cli-base-rate         , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_dec in this-procedure (  ub.goods.qnty-cart          , num#str# , num#col#  ). num#col# = num#col# + 1 .
       assign
          s-in-qnty    = s-in-qnty   +  export-ras.in-qnty
          s-out-qnty   = s-out-qnty  +  export-ras.out-qnty
          s-out-sum    = s-out-sum   +  export-ras.out-sum
          s-supp-qnty  = s-supp-qnty +  export-ras.supp-qnty
          ss-in-qnty   = ss-in-qnty   +  export-ras.in-qnty
          ss-out-qnty  = ss-out-qnty  +  export-ras.out-qnty
          ss-out-sum   = ss-out-sum   +  export-ras.out-sum
          ss-supp-qnty = ss-supp-qnty +  export-ras.supp-qnty
       .
    end.
    else do:
      num#col# = num#col# + 16 .
    end.
   if (p-doc-type = 'ФП':U and R-min-rest = 2 and first-of ( export-ras.gds-code )) or
      (p-doc-type = 'ФП':U and R-min-rest = 1 ) or
       p-doc-type <> 'ФП':U
    then do :
    run macr_excel_dec in this-procedure (  export-ras.Temp-rash           , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure (  export-ras.qnty      , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure (  export-ras.sum-rubl  , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure (  (export-ras.qnty-rash + export-ras.qnty-kassa)           , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure (  export-ras.zero-day            , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure (  export-ras.qnty-stk            , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure (  export-ras.qnty-prih           , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure (  export-ras.qnty-rash           , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure (  export-ras.qnty-kassa          , num#str# , num#col#  ). num#col# = num#col# + 1 .
    if par-ord-min-ost = true then do:
       run macr_excel_dec in this-procedure
          ((export-ras.min-stock * export-ras.Temp-rash)   ,
            num#str# ,
            num#col#
            ) .
       num#col# = num#col# + 1 .
    end.
    else do:
       run macr_excel_dec in this-procedure
       ( export-ras.min-stock ,
         num#str# ,
         num#col#
         ).
       num#col# = num#col# + 1 .
    end.
    run macr_excel_dec in this-procedure (  export-ras.service-order , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure (  export-ras.min-order   , num#str# , num#col#  ).   num#col# = num#col# + 1 .
        if ( p-doc-type = 'ФП':U and R-min-rest = 2 ) then do:
       run macr_excel_char_with_format in this-procedure  ( "список" , num#str# , num#col#  ) .
    end.
    else do:
       run macr_excel_char_with_format in this-procedure ( export-ras.obj-type + " " + string(export-ras.obj-code) , num#str# , num#col#  ) .
    end.
    if p-prt-all then do:
       run macr_excel_char_with_format in this-procedure ( export-ras.artic , num#str# , 1  ) .
    end.
    num#col# = num#col# + 1 .
    run macr_excel_char_with_format in this-procedure ( export-ras.negative-rest  , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure ( export-ras.gds-way-all  , num#str# , num#col#  ). num#col# = num#col# + 1 .
         l-all-day =  export-ras.all-day  .   if l-all-day = ? then l-all-day = 0 .
    run macr_excel_dec in this-procedure ( l-all-day  , num#str# , num#col#  ). num#col# = num#col# + 1 .
    assign
     s-qnty                =  s-qnty        +  export-ras.qnty
     s-sum-rubl            =  s-sum-rubl    +  export-ras.sum-rubl
     s-qnty-rashkassa      =  s-qnty-rashkassa +   (export-ras.qnty-rash + export-ras.qnty-kassa)
     s-zero-day            =  s-zero-day    +  export-ras.zero-day
     s-qnty-stk            =  s-qnty-stk    +  export-ras.qnty-stk
     s-qnty-prih           =  s-qnty-prih   +  export-ras.qnty-prih
     s-qnty-rash           =  s-qnty-rash   +  export-ras.qnty-rash
     s-qnty-kassa          =  s-qnty-kassa  +  export-ras.qnty-kassa
     s-min-stock           =  s-min-stock   +  export-ras.min-stock
     s-service-order       =  s-service-order + export-ras.service-order
     s-min-order           =  s-min-order     + export-ras.min-order
     s-gds-way-all         =  s-gds-way-all   + export-ras.gds-way-all
     s-l-all-day           =  s-l-all-day     +           l-all-day
     ss-qnty                =  ss-qnty        +  export-ras.qnty
     ss-sum-rubl            =  ss-sum-rubl    +  export-ras.sum-rubl
     ss-qnty-rashkassa      =  ss-qnty-rashkassa +   (export-ras.qnty-rash + export-ras.qnty-kassa)
     ss-zero-day            =  ss-zero-day    +  export-ras.zero-day
     ss-qnty-stk            =  ss-qnty-stk    +  export-ras.qnty-stk
     ss-qnty-prih           =  ss-qnty-prih   +  export-ras.qnty-prih
     ss-qnty-rash           =  ss-qnty-rash   +  export-ras.qnty-rash
     ss-qnty-kassa          =  ss-qnty-kassa  +  export-ras.qnty-kassa
     ss-min-stock           =  ss-min-stock   +  export-ras.min-stock
     ss-service-order       =  ss-service-order + export-ras.service-order
     ss-min-order           =  ss-min-order     + export-ras.min-order
     ss-gds-way-all         =  ss-gds-way-all   + export-ras.gds-way-all
     ss-l-all-day           =  ss-l-all-day     +           l-all-day
    .
    end.
    if last-of(export-ras.gds-code) and  loc-doc-type = 'ФП':U and kol-obj > 1  then do:
            num#str# = num#str# + 1 .
            num#col# =  1.
            run macr_excel_char in this-procedure (  " Итого по товару", num#str# , num#col#     ) .
            define variable iii as integer no-undo .
            num#col# =  8.
            run macr_excel_dec in this-procedure (s-in-qnty    , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (s-out-qnty   , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (s-out-sum    , num#str# , num#col#  ). num#col# = num#col# + 1 .
            num#col# =  12.
            run macr_excel_dec in this-procedure (s-supp-qnty  , num#str# , num#col#  ). num#col# = num#col# + 1 .
            num#col# =  18.
            run macr_excel_dec in this-procedure (s-qnty       , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (s-sum-rubl   , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (s-qnty-rashkassa , num#str# , num#col#  ). num#col# = num#col# + 1 .
             num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (s-qnty-stk       , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (s-qnty-prih      , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (s-qnty-rash      , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (s-qnty-kassa     , num#str# , num#col#  ). num#col# = num#col# + 1 .
            num#col# =  31.
            run macr_excel_dec in this-procedure (s-gds-way-all    , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (s-l-all-day      , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_cell_format in this-procedure
                      ( 10    ,
                        true  ,
                        false ,
                        ?     ,
                        num#str# ,
                        1 ,
                        ? ,
                        num#col#         ) .
                num#col# =  1.
    end.
end.
    num#str# = num#str# + 1.
    num#col# =  1.
 if loc-doc-type <> 'ФП':U or loc-doc-type = 'ФП':U   then do:
    run macr_excel_char in this-procedure (  " Итого по Заказу", num#str# , num#col#     ) .
            num#col# =  8.
            run macr_excel_dec in this-procedure (ss-in-qnty    , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (ss-out-qnty   , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (ss-out-sum    , num#str# , num#col#  ). num#col# = num#col# + 1 .
            num#col# =  12.
            run macr_excel_dec in this-procedure (ss-supp-qnty  , num#str# , num#col#  ). num#col# = num#col# + 1 .
            num#col# =  18.
            run macr_excel_dec in this-procedure (ss-qnty       , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (ss-sum-rubl   , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (ss-qnty-rashkassa , num#str# , num#col#  ). num#col# = num#col# + 1 .
             num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (ss-qnty-stk       , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (ss-qnty-prih      , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (ss-qnty-rash      , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (ss-qnty-kassa     , num#str# , num#col#  ). num#col# = num#col# + 1 .
            num#col# =  31.
            run macr_excel_dec in this-procedure (ss-gds-way-all    , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (ss-l-all-day      , num#str# , num#col#  ). num#col# = num#col# + 1 .
      run macr_cell_format
                ( 10    ,
                  true  ,
                  false ,
                  ?     ,
                  num#str# ,
                  1 ,
                  ? ,
                  num#col#         ) .
          num#str# = num#str# + 1.
          num#col# =  1.
end.
run macr_excel_char in this-procedure (  " Категорийный менеджер", num#str# , num#col#     )   .
num#col# =  5.
run macr_excel_char in this-procedure ( "ФИО Категорийного менеджера" , num#str# , num#col#     )   .
 run macr_cell_format in this-procedure
          ( 10    ,
            true  ,
            false ,
            ?     ,
            num#str# ,
            1 ,
            ? ,
            num#col#         ) .
num#str# = num#str# + 3.
num#col# =  1.
run macr_excel_char in this-procedure (  "Параметры расчета заказа", num#str# , num#col#     )   .
 run macr_cell_format  in this-procedure
          ( 12    ,
            true  ,
            false ,
            15     ,
            num#str# ,
            1 ,
            ? ,
            3       ) .
    define variable jjj as integer no-undo .
    define variable pp-str as character no-undo .
    define variable pp-str2 as character no-undo .
    num#col# =  1.
    iii= 0.
define variable l-jj  as integer no-undo .
define variable l-len as integer no-undo .
define variable l-m   as integer no-undo .
define variable v-nn as integer   no-undo .
define variable v-nn2 as integer   no-undo .
v-nn = num-entries( p-e-method ,"chr(10)") .
v-nn2 = num-entries( pp-str ,";") .
    repeat iii = 1 to v-nn  :
        pp-str = entry (iii, p-e-method , "chr(10)").
        v-nn2 = num-entries( pp-str ,";") .
          repeat jjj = 1 to v-nn2 :
            pp-str2 = entry (jjj, pp-str , ";").
            if pp-str2 <> "" and pp-str2 <> ? and  pp-str2 <> " " then do:
                    l-len = length (pp-str2  ) .
                    l-m = integer( l-len / 220 ) + 1 .
                    do l-jj = 1 to  l-m  :
                        num#str# = num#str# + 1 .
                        run macr_excel_char in this-procedure (
                            substring( pp-str2, (( 220 * l-jj ) - 219 )  , 220 )  , num#str# , num#col# ) .
                    end.                                                                                                       ~
            end.
          end.
    end.
end.
end procedure.
procedure mf :
 do
 on error undo, return error return-value
 :
    run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name) .
    output stream  Macr_Excel to value(v-file-name) .
    v-ind = v-ind + 1 .
    num#str# = 0 .
 end.
end procedure.
