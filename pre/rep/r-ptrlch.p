block-level on error undo, throw.
define input parameter ParParentProc as logical no-undo.
define input parameter p-param-list as character no-undo.
define input parameter p-rs-grp-tech-refuell as integer no-undo.
define variable vss-revision    as character no-undo init "$Revision: f30204f76123, 1351, rls $":U .
define variable vss-author      as character no-undo init "$Author: PGridchina $":U .
define variable vss-date        as character no-undo init "$Date: Fri May 18 13:28:20 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ptrlch.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-ptrlch.p $":U .
define variable vss-description as character no-undo init "Технологический отчет по АЗК - сбор данных и печать".
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
define  shared variable gdsgrp_recids      as character no-undo.
define  shared variable fin-schet-recid    as character no-undo.
define  shared variable v-d-report-handle  as handle    no-undo .
define  shared temp-table g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define  shared temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define  shared temp-table tmp#grp no-undo
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
define  shared temp-table gds-list no-undo like ub.goods
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
define   shared  temp-table gds-list-hist no-undo
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
 shared
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
define  shared temp-table X-init_obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary obj-type obj-code.
define variable p1 like ub.gds-obj.prod-type no-undo.
define variable p2 like ub.gds-obj.prod-code no-undo.
define variable p3 like ub.gds-obj.artic     no-undo.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define   shared variable str1   as character  no-undo.
define   shared variable str2   as character  no-undo.
define   shared variable str3   as character  no-undo.
define   shared variable str4   as character  no-undo.
define   shared variable ReportNAme   as character  no-undo.
define   shared variable ReportProc   as character  no-undo.
define   shared variable ReportHeader as character  no-undo.
define   shared variable ReportPageWidth  as integer no-undo.
define   shared variable ReportPageHeight as integer no-undo.
define   shared variable ReportFontNum    as integer no-undo.
define   shared variable my-request as logical  init false no-undo.
define   shared variable v-delim as character no-undo .
define   shared variable v-sdate as character no-undo initial "/":U.
define   shared variable v-shortdate as character no-undo initial "dd/mm/yyyy":U .
define   shared variable my-handle  as handle no-undo .
define   shared variable parent-handle  as handle no-undo .
define   shared variable v-show-all-goods as logical  no-undo .
define   shared variable params-only      as logical   no-undo .
define   shared variable params-only-mode as character no-undo .
define   shared variable place-call       as character no-undo .
define   shared variable x-Goods-Editor   as character  no-undo .
define   shared variable x-Date-Alone     as date format "99/99/9999":u   no-undo .
define   shared variable x-Date-End       as date format "99/99/9999":u   no-undo .
define   shared variable x-Date-Start     as date format "99/99/9999":u   no-undo .
define   shared variable x-Shift-Alone    as integer format ">9":u         no-undo .
define   shared variable x-Shift-End      as integer format ">9":u         no-undo .
define   shared variable x-Shift-Start    as integer format ">9":u         no-undo .
define   shared variable x-SelectGood     as integer                      no-undo .
define   shared variable x-SelectObject   as character                          no-undo .
define   shared variable x-SET_PAY_TYPE   as integer  no-undo .
define   shared variable x-SET_val_TYPE   as integer  no-undo .
define   shared variable x-TOG-Shift      as logical  no-undo .
define   shared variable x-Radio-Task     as integer  no-undo .
define   shared variable x-TOG-Excel      as logical  no-undo .
define   shared variable x-TOG-list-hist  as logical  no-undo .
define   shared variable x-text-1 as character  no-undo .
define   shared variable x-text-2 as character  no-undo .
define   shared variable x-text-3 as character  no-undo .
define   shared variable x-text-4 as character  no-undo .
define   shared variable init-date-start  like x-date-start  no-undo .
define   shared variable init-date-end    like x-date-end    no-undo .
define   shared variable init-date-alone  like x-date-alone  no-undo .
define   shared variable init-shift-alone like x-shift-alone no-undo .
define   shared variable init-shift-start like x-shift-start no-undo .
define   shared variable init-shift-end   like x-shift-end   no-undo .
define   shared variable init-set_pay_type like x-set_pay_type   no-undo .
define   shared variable init-set_val_type like x-set_val_type   no-undo .
define   shared variable ref_date-start    as character   no-undo .
define   shared variable ref_date-end      as character   no-undo .
define   shared variable ref_date-alone    as character   no-undo .
define   shared work-table TDEDT  no-undo
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
define   shared variable str-obj-type as character  no-undo.
define   shared variable str-obj-code as character  no-undo.
define   shared variable str-obj-name as character  no-undo.
define   shared variable str-obj      as character  no-undo.
define   shared variable link#        as logical  no-undo init false.
define   shared variable  Verify-Arc-ot      as logical  no-undo init false.
define   shared variable  Verify-Arc-stk     as logical  no-undo init false.
define   shared variable  Verify-Arc-supp    as logical  no-undo init false.
define   shared variable  Verify-Arc-hold    as logical  no-undo init false.
define   shared variable  Verify-Arc-aht     as logical  no-undo init false.
define   shared variable  Verify-send-check  as logical  no-undo init false.
define   shared variable  Verify-Arc-fin     as logical  no-undo init false.
define   shared variable  Verify-Arc-strong  as logical  no-undo init false.
define   shared variable  Show-Crsa         as logical  no-undo init false.
define   shared variable  Show-Cost         as logical  no-undo init false.
define   shared variable  Show-Sale         as logical  no-undo init false.
define   shared variable  Name-Sale-price   as character no-undo .
define   shared variable  Format-Folder     as logical no-undo .
define   shared variable  Print-List-Hist   as logical no-undo init false.
define   shared variable Make-Excel     as logical  no-undo init false.
define   shared variable Make-Excel-com as logical  no-undo init false.
define   shared stream ForExcel.
define   shared variable Use-column   as logical extent 256 no-undo .
define   shared variable right-column as logical extent 256 no-undo .
define shared  temp-table Sheetf no-undo
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
find first sheetf where sheet-num = 1 no-error.
define variable l-stroka as character no-undo .
define   shared  variable ch#ExcelApplication as com-handle no-undo .
define   shared  variable ch#Workbook         as com-handle no-undo .
define   shared  variable ch#Worksheet        as com-handle no-undo .
define   shared  variable Num#Str#            as integer no-undo.
define   shared  variable Number-List         as integer no-undo init 1.
define   shared  variable v-excel-file        as character no-undo .
define variable Col-name as character  extent 256.
define variable Col-format as character  extent 256.
define variable Col-Post-format as character  extent 256.
run proc-page0-assign in this-procedure .
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable Line as character no-undo.
define variable date_string as character no-undo.
define variable multi-obj as logical no-undo.
define variable obj-count as integer no-undo.
define variable jj as integer no-undo.
define variable v-chk-type like ub.chk-doc.chk-type no-undo.
define variable v-type-num as integer no-undo.
define variable accum-pay-desk-doc-qnty as decimal no-undo.
define variable accum-pay-desk-sum-base as decimal no-undo.
define variable accum-pay-desk-trans-number as integer no-undo.
  define variable accum-pay-desk-doc-qnty-ns as decimal no-undo.
  define variable accum-pay-desk-sum-base-ns as decimal no-undo.
  define variable accum-pay-desk-trans-number-ns as integer no-undo.
    define variable accum-doc-qnty-dest as decimal no-undo.
    define variable accum-sum-base-dest as decimal no-undo.
    define variable accum-trans-number-dest as integer no-undo.
define variable accum-gds-code-doc-qnty as decimal no-undo.
define variable accum-gds-code-sum-base as decimal no-undo.
define variable accum-gds-code-trans-number as integer no-undo.
  define variable accum-gds-code-doc-qnty-ns as decimal no-undo.
  define variable accum-gds-code-sum-base-ns as decimal no-undo.
  define variable accum-gds-code-trans-number-ns as integer no-undo.
define variable accum-doc-qnty as decimal no-undo.
define variable accum-sum-base as decimal no-undo.
define variable accum-trans-number as integer no-undo.
  define variable accum-doc-qnty-ns as decimal no-undo.
  define variable accum-sum-base-ns as decimal no-undo.
  define variable accum-trans-number-ns as integer no-undo.
define buffer buf_chk-doc for ub.chk-doc.
define temp-table temp-petrol-chk no-undo
field obj-type like ub.chk-doc.obj-type init '':U
field obj-code like ub.chk-doc.obj-code init 0
field chk-type like ub.chk-doc.chk-type init 0
field pay-desk like ub.chk-doc.pay-desk init 0
field gds-code like ub.goods.gds-code
field pump like ub.chk-gds.pump         init 0
field pump-2 like ub.chk-gds.pump       init 0
field doc-qnty like ub.chk-gds.doc-qnty init 0
field doc-qnty-ns like ub.chk-gds.doc-qnty init 0
field sum-base like ub.chk-gds.sum-base init 0
field sum-base-ns like ub.chk-gds.sum-base init 0
field write-off-code like ub.chk-gds.write-off-code
field trans-number as integer
field trans-number-ns as integer
field pay-code like ub.chk-pay.pay-code
field pay-name as character
field prim as logical
index pi is unique primary
obj-type obj-code
chk-type
pay-desk
gds-code
pump
pump-2
pay-code
index ip
prim
.
define buffer buf_temp-petrol-chk for temp-petrol-chk.
define buffer buf_temp2-petrol-chk for temp-petrol-chk.
define temp-table temp-goods no-undo
field gds-code like ub.goods.gds-code
field gds-name like ub.goods.gds-name
index pi is unique primary
gds-code.
define buffer buf_temp-goods for temp-goods.
define buffer buf2_temp-goods for temp-goods.
define stream ScreenStream.
FOR EACH temp-petrol-chk:
  delete temp-petrol-chk.
END.
run waitfram-show in this-procedure ("Ждите...").
for each obj-list No-LOCK:
  obj-count = obj-count + 1.
end.
if obj-count > 1 then do:
  multi-obj = yes.
end.
procedure fill-temp-table:
define input parameter p-doc-code like ub.chk-doc.doc-code no-undo.
define input parameter p-chk-type like ub.chk-doc.chk-type no-undo.
define variable v-write-off-code like ub.chk-doc.chk-type no-undo.
define variable v-pump as integer no-undo.
define variable v-pump-2 as integer no-undo.
define variable ii as integer no-undo.
define variable v-qnty like ub.chk-gds.doc-qnty no-undo init 0.
define variable v-sum like ub.chk-gds.sum-base no-undo init 0.
define variable v-pay-code as integer no-undo.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_temp-petrol-chk for temp-petrol-chk.
  do
  on error undo, return error return-value
  :
    for each buf_chk-gds no-lock where
         buf_chk-gds.doc-code = buf_chk-doc.doc-code
      ,
      first buf_bar-code no-lock where buf_bar-code.b-code = buf_chk-gds.b-code
    :
      ii = ii + 1.
      if p-chk-type = integer('16':U) then
      do:
        if buf_chk-gds.doc-qnty < 0 then
        assign
          v-write-off-code = buf_chk-gds.write-off-code
          v-pump = buf_chk-gds.pump
          v-qnty = abs(buf_chk-gds.doc-qnty)
          v-sum  = abs(buf_chk-gds.sum-base)
        .
        if buf_chk-gds.doc-qnty > 0 then
        assign
          v-write-off-code = buf_chk-gds.write-off-code
          v-pump-2 = buf_chk-gds.pump
          v-qnty = abs(buf_chk-gds.doc-qnty)
          v-sum  = abs(buf_chk-gds.sum-base)
        .
      end.
      else
      do:
        assign
          v-write-off-code = buf_chk-gds.write-off-code
          v-pump = buf_chk-gds.pump
          v-pump-2 = 0
          v-qnty = buf_chk-gds.doc-qnty
          v-sum  = (if buf_chk-gds.doc-qnty = 0 then 0 else buf_chk-gds.sum-base)
        .
      end.
        if p-chk-type = integer('17':U) then
        do:
          find first buf_chk-pay where
            buf_chk-pay.doc-code = buf_chk-doc.doc-code
          no-error.
          if available buf_chk-pay then
          do:
            v-pay-code = buf_chk-pay.pay-code.
          end.
          else
          do:
            v-pay-code = -1.
          end.
          find first buf_temp-petrol-chk where
                buf_temp-petrol-chk.chk-type = buf_chk-doc.chk-type
            AND buf_temp-petrol-chk.obj-type = buf_chk-doc.obj-type
            AND buf_temp-petrol-chk.obj-code = buf_chk-doc.obj-code
            AND buf_temp-petrol-chk.pay-desk = buf_chk-doc.pay-desk
            AND buf_temp-petrol-chk.pay-code = v-pay-code
            AND buf_temp-petrol-chk.gds-code = buf_bar-code.gds-code
            AND buf_temp-petrol-chk.pump     = v-pump
            AND buf_temp-petrol-chk.pump-2   = v-pump-2 no-error.
          if not available buf_temp-petrol-chk then
          do:
            create buf_temp-petrol-chk.
            assign
              buf_temp-petrol-chk.chk-type = buf_chk-doc.chk-type
              buf_temp-petrol-chk.obj-type = buf_chk-doc.obj-type
              buf_temp-petrol-chk.obj-code = buf_chk-doc.obj-code
              buf_temp-petrol-chk.pay-desk = buf_chk-doc.pay-desk
              buf_temp-petrol-chk.write-off-code = v-write-off-code
              buf_temp-petrol-chk.gds-code = buf_bar-code.gds-code
              buf_temp-petrol-chk.pay-code = v-pay-code
              buf_temp-petrol-chk.pump     = v-pump
              buf_temp-petrol-chk.pump-2   = v-pump-2
              buf_temp-petrol-chk.prim     = yes
           .
            for first buf_cash-pay where
              buf_cash-pay.cdpay-code = v-pay-code
            no-lock:
              assign
                buf_temp-petrol-chk.pay-name = buf_cash-pay.obj-name
              .
            end.
          end.
          do:
            assign
              buf_temp-petrol-chk.doc-qnty = buf_temp-petrol-chk.doc-qnty + v-qnty
              buf_temp-petrol-chk.sum-base = buf_temp-petrol-chk.sum-base + v-sum
              buf_temp-petrol-chk.trans-number = buf_temp-petrol-chk.trans-number + 1
            .
          end.
        end.
        else
        do:
          if p-chk-type <> integer('16':U)
          or ii = 2 then
          do:
            find first buf_temp-petrol-chk where
                  buf_temp-petrol-chk.chk-type = buf_chk-doc.chk-type
              AND buf_temp-petrol-chk.obj-type = buf_chk-doc.obj-type
              AND buf_temp-petrol-chk.obj-code = buf_chk-doc.obj-code
              AND buf_temp-petrol-chk.pay-desk = buf_chk-doc.pay-desk
              AND buf_temp-petrol-chk.gds-code = buf_bar-code.gds-code
              AND buf_temp-petrol-chk.pump     = v-pump
              AND buf_temp-petrol-chk.pump-2   = v-pump-2 no-error.
            if not available buf_temp-petrol-chk then
            do:
              create buf_temp-petrol-chk.
              assign
                buf_temp-petrol-chk.chk-type = buf_chk-doc.chk-type
                buf_temp-petrol-chk.obj-type = buf_chk-doc.obj-type
                buf_temp-petrol-chk.obj-code = buf_chk-doc.obj-code
                buf_temp-petrol-chk.pay-desk = buf_chk-doc.pay-desk
                buf_temp-petrol-chk.write-off-code = v-write-off-code
                buf_temp-petrol-chk.gds-code = buf_bar-code.gds-code
                buf_temp-petrol-chk.pump     = v-pump
                buf_temp-petrol-chk.pump-2   = v-pump-2
                buf_temp-petrol-chk.prim     = yes
             .
            end.
            if (p-chk-type = integer('14':U) or p-chk-type = integer('36':U))
            and v-write-off-code = 0
             then
            do:
              assign
                buf_temp-petrol-chk.doc-qnty-ns = buf_temp-petrol-chk.doc-qnty-ns + v-qnty
                buf_temp-petrol-chk.sum-base-ns = buf_temp-petrol-chk.sum-base-ns + v-sum
                buf_temp-petrol-chk.trans-number-ns = buf_temp-petrol-chk.trans-number-ns + 1
              .
            end.
            else
            do:
              assign
                buf_temp-petrol-chk.doc-qnty = buf_temp-petrol-chk.doc-qnty + v-qnty
                buf_temp-petrol-chk.sum-base = buf_temp-petrol-chk.sum-base + v-sum
                buf_temp-petrol-chk.trans-number = buf_temp-petrol-chk.trans-number + 1
              .
            end.
          end.
       end.
    end.
  end.
end procedure.
procedure fill-sub-totals :
define variable v-write-off-code2 like ub.chk-doc.chk-type no-undo.
define buffer buf_temp-petrol-chk for temp-petrol-chk.
define buffer gds-obj_temp-petrol-chk for temp-petrol-chk.
define buffer pay-desk_temp-petrol-chk for temp-petrol-chk.
define buffer gds_temp-petrol-chk for temp-petrol-chk.
define buffer gds-obj0_temp-petrol-chk for temp-petrol-chk.
define buffer gds0_temp-petrol-chk for temp-petrol-chk.
define buffer dest_temp-petrol-chk for temp-petrol-chk.
define buffer pay-desk2_temp-petrol-chk for temp-petrol-chk.
define buffer pay-desk3_temp-petrol-chk for temp-petrol-chk.
define buffer gds2_temp-petrol-chk for temp-petrol-chk.
define buffer buf_goods for ub.goods.
define buffer buf_temp-goods for temp-goods.
  do
  on error undo, return error return-value
  :
    for each buf_temp-petrol-chk where buf_temp-petrol-chk.prim = yes:
      find first pay-desk_temp-petrol-chk where
              pay-desk_temp-petrol-chk.chk-type = 0
          AND pay-desk_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
          AND pay-desk_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
          AND pay-desk_temp-petrol-chk.pay-desk = buf_temp-petrol-chk.pay-desk
          AND pay-desk_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
          AND pay-desk_temp-petrol-chk.pump     = buf_temp-petrol-chk.pump
          AND pay-desk_temp-petrol-chk.pump-2   = 0
           and pay-desk_temp-petrol-chk.pay-code = 0
          no-error.
      if not available pay-desk_temp-petrol-chk then
      do:
        create pay-desk_temp-petrol-chk.
        assign
          pay-desk_temp-petrol-chk.chk-type = 0
          pay-desk_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
          pay-desk_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
          pay-desk_temp-petrol-chk.pay-desk = buf_temp-petrol-chk.pay-desk
          pay-desk_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
          pay-desk_temp-petrol-chk.pay-code = 0
          pay-desk_temp-petrol-chk.pump     = buf_temp-petrol-chk.pump
          pay-desk_temp-petrol-chk.pump-2   = 0
        .
      end.
      assign
        pay-desk_temp-petrol-chk.doc-qnty        = pay-desk_temp-petrol-chk.doc-qnty        + buf_temp-petrol-chk.doc-qnty      + buf_temp-petrol-chk.doc-qnty-ns
        pay-desk_temp-petrol-chk.sum-base        = pay-desk_temp-petrol-chk.sum-base        + buf_temp-petrol-chk.sum-base      + buf_temp-petrol-chk.sum-base-ns
        pay-desk_temp-petrol-chk.trans-number    = pay-desk_temp-petrol-chk.trans-number    + buf_temp-petrol-chk.trans-number  + buf_temp-petrol-chk.trans-number-ns
      .
      find first gds-obj_temp-petrol-chk where
              gds-obj_temp-petrol-chk.chk-type = buf_temp-petrol-chk.chk-type
          AND gds-obj_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
          AND gds-obj_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
          AND gds-obj_temp-petrol-chk.pay-desk = 0
          AND gds-obj_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
          AND gds-obj_temp-petrol-chk.pump     = 0
          and gds-obj_temp-petrol-chk.pay-code = 0
          AND gds-obj_temp-petrol-chk.pump-2   = 0 no-error.
      if not available gds-obj_temp-petrol-chk then
      do:
        create gds-obj_temp-petrol-chk.
        assign
          gds-obj_temp-petrol-chk.chk-type = buf_temp-petrol-chk.chk-type
          gds-obj_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
          gds-obj_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
          gds-obj_temp-petrol-chk.pay-desk = 0
          gds-obj_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
          gds-obj_temp-petrol-chk.write-off-code = buf_temp-petrol-chk.write-off-code
          gds-obj_temp-petrol-chk.pump     = 0
          gds-obj_temp-petrol-chk.pump-2   = 0
           gds-obj_temp-petrol-chk.pay-code = 0
        .
      end.
        do:
          assign
            gds-obj_temp-petrol-chk.doc-qnty        = gds-obj_temp-petrol-chk.doc-qnty        + buf_temp-petrol-chk.doc-qnty
            gds-obj_temp-petrol-chk.sum-base        = gds-obj_temp-petrol-chk.sum-base        + buf_temp-petrol-chk.sum-base
            gds-obj_temp-petrol-chk.trans-number    = gds-obj_temp-petrol-chk.trans-number    + buf_temp-petrol-chk.trans-number
            gds-obj_temp-petrol-chk.doc-qnty-ns     = gds-obj_temp-petrol-chk.doc-qnty-ns     + buf_temp-petrol-chk.doc-qnty-ns
            gds-obj_temp-petrol-chk.sum-base-ns     = gds-obj_temp-petrol-chk.sum-base-ns     + buf_temp-petrol-chk.sum-base-ns
            gds-obj_temp-petrol-chk.trans-number-ns = gds-obj_temp-petrol-chk.trans-number-ns + buf_temp-petrol-chk.trans-number-ns
          .
        end.
      if buf_temp-petrol-chk.chk-type = integer('17':U) then
      do:
          find first dest_temp-petrol-chk where
                  dest_temp-petrol-chk.chk-type = buf_temp-petrol-chk.chk-type
              AND dest_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
              AND dest_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
              AND dest_temp-petrol-chk.pay-desk = 0
              AND dest_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
              AND dest_temp-petrol-chk.pump     = 0
              AND dest_temp-petrol-chk.pump-2   = 0
              AND dest_temp-petrol-chk.pay-code = buf_temp-petrol-chk.pay-code
              no-error.
          if not available dest_temp-petrol-chk then
          do:
            create dest_temp-petrol-chk.
            assign
              dest_temp-petrol-chk.chk-type = buf_temp-petrol-chk.chk-type
              dest_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
              dest_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
              dest_temp-petrol-chk.pay-desk = 0
              dest_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
              dest_temp-petrol-chk.pump     = 0
              dest_temp-petrol-chk.pump-2   = 0
              dest_temp-petrol-chk.pay-code = buf_temp-petrol-chk.pay-code
              dest_temp-petrol-chk.pay-name = buf_temp-petrol-chk.pay-name
            .
          end.
            do:
              assign
                dest_temp-petrol-chk.doc-qnty        = dest_temp-petrol-chk.doc-qnty        + buf_temp-petrol-chk.doc-qnty
                dest_temp-petrol-chk.sum-base        = dest_temp-petrol-chk.sum-base        + buf_temp-petrol-chk.sum-base
                dest_temp-petrol-chk.trans-number    = dest_temp-petrol-chk.trans-number    + buf_temp-petrol-chk.trans-number
              .
            end.
      end.
      if buf_temp-petrol-chk.chk-type = integer('17':U) then
      do:
          find first pay-desk2_temp-petrol-chk where
                  pay-desk2_temp-petrol-chk.chk-type = buf_temp-petrol-chk.chk-type
              AND pay-desk2_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
              AND pay-desk2_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
              AND pay-desk2_temp-petrol-chk.pay-desk = buf_temp-petrol-chk.pay-desk
              AND pay-desk2_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
              AND pay-desk2_temp-petrol-chk.pump     = 0
              AND pay-desk2_temp-petrol-chk.pump-2   = 0
              AND pay-desk2_temp-petrol-chk.pay-code = buf_temp-petrol-chk.pay-code
              no-error.
          if not available pay-desk2_temp-petrol-chk then
          do:
            create pay-desk2_temp-petrol-chk.
            assign
              pay-desk2_temp-petrol-chk.chk-type = buf_temp-petrol-chk.chk-type
              pay-desk2_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
              pay-desk2_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
              pay-desk2_temp-petrol-chk.pay-desk = buf_temp-petrol-chk.pay-desk
              pay-desk2_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
              pay-desk2_temp-petrol-chk.pump     = 0
              pay-desk2_temp-petrol-chk.pump-2   = 0
              pay-desk2_temp-petrol-chk.pay-code = buf_temp-petrol-chk.pay-code
                pay-desk2_temp-petrol-chk.pay-name = buf_temp-petrol-chk.pay-name
            .
          end.
            do:
              assign
                pay-desk2_temp-petrol-chk.doc-qnty        = pay-desk2_temp-petrol-chk.doc-qnty        + buf_temp-petrol-chk.doc-qnty
                pay-desk2_temp-petrol-chk.sum-base        = pay-desk2_temp-petrol-chk.sum-base        + buf_temp-petrol-chk.sum-base
                pay-desk2_temp-petrol-chk.trans-number    = pay-desk2_temp-petrol-chk.trans-number    + buf_temp-petrol-chk.trans-number
              .
            end.
      end.
      if buf_temp-petrol-chk.chk-type = integer('17':U) then
      do:
          find first pay-desk3_temp-petrol-chk where
                  pay-desk3_temp-petrol-chk.chk-type = buf_temp-petrol-chk.chk-type
              AND pay-desk3_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
              AND pay-desk3_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
              AND pay-desk3_temp-petrol-chk.pay-desk = buf_temp-petrol-chk.pay-desk
              AND pay-desk3_temp-petrol-chk.gds-code = 0
              AND pay-desk3_temp-petrol-chk.pump     = 0
              AND pay-desk3_temp-petrol-chk.pump-2   = 0
              AND pay-desk3_temp-petrol-chk.pay-code = buf_temp-petrol-chk.pay-code
              no-error.
          if not available pay-desk3_temp-petrol-chk then
          do:
            create pay-desk3_temp-petrol-chk.
            assign
              pay-desk3_temp-petrol-chk.chk-type = buf_temp-petrol-chk.chk-type
              pay-desk3_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
              pay-desk3_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
              pay-desk3_temp-petrol-chk.pay-desk = buf_temp-petrol-chk.pay-desk
              pay-desk3_temp-petrol-chk.gds-code = 0
              pay-desk3_temp-petrol-chk.pump     = 0
              pay-desk3_temp-petrol-chk.pump-2   = 0
              pay-desk3_temp-petrol-chk.pay-code = buf_temp-petrol-chk.pay-code
              pay-desk3_temp-petrol-chk.pay-name = buf_temp-petrol-chk.pay-name
            .
          end.
            do:
              assign
                pay-desk3_temp-petrol-chk.doc-qnty        = pay-desk3_temp-petrol-chk.doc-qnty        + buf_temp-petrol-chk.doc-qnty
                pay-desk3_temp-petrol-chk.sum-base        = pay-desk3_temp-petrol-chk.sum-base        + buf_temp-petrol-chk.sum-base
                pay-desk3_temp-petrol-chk.trans-number    = pay-desk3_temp-petrol-chk.trans-number    + buf_temp-petrol-chk.trans-number
              .
            end.
      end.
      if buf_temp-petrol-chk.chk-type = integer('17':U) then
      do:
          find first gds2_temp-petrol-chk where
                  gds2_temp-petrol-chk.chk-type = buf_temp-petrol-chk.chk-type
              AND gds2_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
              AND gds2_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
              AND gds2_temp-petrol-chk.pay-desk = 0
              AND gds2_temp-petrol-chk.gds-code = 0
              AND gds2_temp-petrol-chk.pump     = 0
              AND gds2_temp-petrol-chk.pump-2   = 0
              AND gds2_temp-petrol-chk.pay-code = buf_temp-petrol-chk.pay-code
              no-error.
          if not available gds2_temp-petrol-chk then
          do:
            create gds2_temp-petrol-chk.
            assign
              gds2_temp-petrol-chk.chk-type = buf_temp-petrol-chk.chk-type
              gds2_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
              gds2_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
              gds2_temp-petrol-chk.pay-desk = 0
              gds2_temp-petrol-chk.gds-code = 0
              gds2_temp-petrol-chk.pump     = 0
              gds2_temp-petrol-chk.pump-2   = 0
              gds2_temp-petrol-chk.pay-code = buf_temp-petrol-chk.pay-code
              gds2_temp-petrol-chk.pay-name = buf_temp-petrol-chk.pay-name
            .
          end.
            do:
              assign
                gds2_temp-petrol-chk.doc-qnty        = gds2_temp-petrol-chk.doc-qnty        + buf_temp-petrol-chk.doc-qnty
                gds2_temp-petrol-chk.sum-base        = gds2_temp-petrol-chk.sum-base        + buf_temp-petrol-chk.sum-base
                gds2_temp-petrol-chk.trans-number    = gds2_temp-petrol-chk.trans-number    + buf_temp-petrol-chk.trans-number
              .
            end.
      end.
      find first gds-obj0_temp-petrol-chk where
              gds-obj0_temp-petrol-chk.chk-type = 0
          AND gds-obj0_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
          AND gds-obj0_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
          AND gds-obj0_temp-petrol-chk.pay-desk = 0
          AND gds-obj0_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
          AND gds-obj0_temp-petrol-chk.pump     = 0
          AND gds-obj0_temp-petrol-chk.pump-2   = 0 no-error.
      if not available gds-obj0_temp-petrol-chk then
      do:
        find first buf_goods no-lock where
                  buf_goods.gds-code = buf_temp-petrol-chk.gds-code no-error.
        find first buf_temp-goods no-lock where
                buf_temp-goods.gds-code = buf_temp-petrol-chk.gds-code no-error.
        if not available buf_temp-goods then
        do:
          create buf_temp-goods.
          assign
          buf_temp-goods.gds-code = buf_temp-petrol-chk.gds-code
          buf_temp-goods.gds-name = (if available buf_goods
                                     then buf_goods.gds-name
                                     else substitute("Товар с кодом &1", buf_temp-petrol-chk.gds-code))
          .
        end.
        create gds-obj0_temp-petrol-chk.
        assign
          gds-obj0_temp-petrol-chk.chk-type = 0
          gds-obj0_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
          gds-obj0_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
          gds-obj0_temp-petrol-chk.pay-desk = 0
          gds-obj0_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
          gds-obj0_temp-petrol-chk.pump     = 0
          gds-obj0_temp-petrol-chk.pump-2   = 0
        .
      end.
      do:
        assign
          gds-obj0_temp-petrol-chk.doc-qnty     = gds-obj0_temp-petrol-chk.doc-qnty     + buf_temp-petrol-chk.doc-qnty      + buf_temp-petrol-chk.doc-qnty-ns
          gds-obj0_temp-petrol-chk.sum-base     = gds-obj0_temp-petrol-chk.sum-base     + buf_temp-petrol-chk.sum-base      + buf_temp-petrol-chk.sum-base-ns
          gds-obj0_temp-petrol-chk.trans-number = gds-obj0_temp-petrol-chk.trans-number + buf_temp-petrol-chk.trans-number  + buf_temp-petrol-chk.trans-number-ns
        .
      end.
    end.
    if multi-obj then
    do:
      for each buf_temp-petrol-chk where
              buf_temp-petrol-chk.prim = no:
        if buf_temp-petrol-chk.pay-desk <> 0 then NEXT.
        if buf_temp-petrol-chk.gds-code = 0 then NEXT.
        if buf_temp-petrol-chk.obj-code = 0 then NEXT.
        if buf_temp-petrol-chk.pay-code <> 0 then next.
        find first gds_temp-petrol-chk where
                gds_temp-petrol-chk.chk-type = buf_temp-petrol-chk.chk-type
            AND gds_temp-petrol-chk.obj-type = '':U
            AND gds_temp-petrol-chk.obj-code = 0
            AND gds_temp-petrol-chk.pay-desk = 0
            AND gds_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
            AND gds_temp-petrol-chk.pump     = 0
            AND gds_temp-petrol-chk.pump-2   = 0 no-error.
        if not available gds_temp-petrol-chk then
        do:
          create gds_temp-petrol-chk.
          assign
            gds_temp-petrol-chk.chk-type = buf_temp-petrol-chk.chk-type
            gds_temp-petrol-chk.obj-type = '':U
            gds_temp-petrol-chk.obj-code = 0
            gds_temp-petrol-chk.pay-desk = 0
            gds_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
            gds_temp-petrol-chk.pump     = 0
            gds_temp-petrol-chk.pump-2   = 0
            v-write-off-code2 = buf_temp-petrol-chk.write-off-code
          .
        end.
          assign
            gds_temp-petrol-chk.doc-qnty     = gds_temp-petrol-chk.doc-qnty     + buf_temp-petrol-chk.doc-qnty
            gds_temp-petrol-chk.sum-base     = gds_temp-petrol-chk.sum-base     + buf_temp-petrol-chk.sum-base
            gds_temp-petrol-chk.trans-number = gds_temp-petrol-chk.trans-number + buf_temp-petrol-chk.trans-number
            gds_temp-petrol-chk.doc-qnty-ns     = gds_temp-petrol-chk.doc-qnty-ns     + buf_temp-petrol-chk.doc-qnty-ns
            gds_temp-petrol-chk.sum-base-ns     = gds_temp-petrol-chk.sum-base-ns     + buf_temp-petrol-chk.sum-base-ns
            gds_temp-petrol-chk.trans-number-ns = gds_temp-petrol-chk.trans-number-ns + buf_temp-petrol-chk.trans-number-ns
          .
      end.
    end.
  end.
end procedure.
for each obj-list no-lock:
  if x-TOG-Shift = yes then
  do:
    _shift-chk:
    for each buf_chk-doc no-lock where
             buf_chk-doc.obj-type = obj-list.obj-type
         and buf_chk-doc.obj-code = obj-list.obj-code
         and (buf_chk-doc.shift-date >= X-date-start and buf_chk-doc.shift-date <= X-date-end)
         and ((buf_chk-doc.shift-date = X-date-start and buf_chk-doc.shift-num >= X-shift-Start) or
              (buf_chk-doc.shift-date = X-date-end and buf_chk-doc.shift-num <= X-shift-End))
    :
      if lookup(string(buf_chk-doc.chk-type), '14,15,16,17,36':U) = 0 or
        buf_chk-doc.office <> 'т':U then next _shift-chk.
      jj = jj + 1.
      if jj modulo 10 = 0 then
      do:
        run waitfram-show in this-procedure (substitute("Ждите... Обработано &1 технологических чеков по топливу", jj)).
      end.
      run fill-temp-table in this-procedure (input buf_chk-doc.doc-code, input buf_chk-doc.chk-type).
    end.
  end.
  else
  do:
    _no-shift-chk:
    for each buf_chk-doc no-lock where
             buf_chk-doc.obj-type = obj-list.obj-type
         and buf_chk-doc.obj-code = obj-list.obj-code
         and buf_chk-doc.chk-date >= X-date-start
         and buf_chk-doc.chk-date <= X-date-end
    :
      if lookup(string(buf_chk-doc.chk-type), '14,15,16,17,36':U) = 0 or
        buf_chk-doc.office <> 'т':U then next _no-shift-chk.
      jj = jj + 1.
      if jj modulo 10 = 0 then
      do:
        run waitfram-show in this-procedure (substitute("Ждите... Обработано &1 технологических чеков по топливу", jj)).
      end.
      run fill-temp-table in this-procedure (input buf_chk-doc.doc-code, input buf_chk-doc.chk-type).
    end.
  end.
end.
run fill-sub-totals in this-procedure.
run waitfram-hide in this-procedure.
date_string = cur-time-print().
run waitfram-show in this-procedure ("Ждите...").
run prn-lib-open-stream  in this-procedure (
                                            input my-handle
                                            ,input 62
                                            ,input yes
                                            ,input no
                                            ).
    PUT stream PrnLibStream unformatted
      'Отчёт доступен только в Excel':U
      skip
    .
  output stream PrnLibStream close.
do:
end.
define variable v-ii as integer no-undo.
define variable v-count-sheets as integer no-undo.
v-count-sheets = num-entries(p-param-list, chr(44)).
do v-ii = 1 to v-count-sheets:
  v-chk-type = integer(entry(v-ii, p-param-list, chr(44))).
  run print-one-chk-type in this-procedure (input v-ii, input v-chk-type).
  if v-ii < v-count-sheets then
  do:
    if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
  end.
end.
assign
  p-param-list = '':U
  v-count-sheets = ?.
  v-chk-type = ?
.
if Make-Excel then output stream ForExcel close.
run waitfram-hide in this-procedure.
run prn-lib-prn-file in this-procedure (
                                          input my-handle
                                          ,input 0
                                          ).
procedure print-one-chk-type :
define input parameter p-type-num as integer no-undo.
define input parameter p-chk-type like ub.chk-doc.chk-type no-undo.
define variable loc-obj-count as integer no-undo.
define buffer bufo_temp-petrol-chk for temp-petrol-chk.
define buffer bufo2_temp-petrol-chk for temp-petrol-chk.
define buffer bufo3_temp-petrol-chk for temp-petrol-chk.
define buffer bufo_temp-goods for temp-goods.
define buffer bufo2_temp-goods for temp-goods.
define variable v-first-good as logical no-undo init yes.
  do
  on error undo, return error return-value
  :
  if p-type-num > 1 then
  do:
    FInd first Sheetf where
      Sheetf.sheet-num = p-type-num no-error.
    if not avail sheetf then
    do:
      create sheetf.
      Sheetf.sheet-num = p-type-num.
    end.
  end.
  assign
    Sheetf.ColFOrmat =
                       (if p-chk-type = integer('14':U) then "4=0.00;5=0.00;7=0.00;8=0.00" else
                          if p-chk-type = integer('15':U) or
                          p-chk-type = 0 or
                          p-chk-type = integer('36':U)
                          then "4=0.00;5=0.00" else
                            if p-chk-type = integer('17':U) or
                            p-chk-type = integer('16':U)
                            then "5=0.00;6=0.00" else '':U
                       )
                       + chr(4)
                       + '':U
                       + chr(4) +
                       (if p-chk-type = 0 then "Все виды чеков" else entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))
  .
  assign
  sheetf.Excel-Column-Lable =
  "Касса" + chr(44)
  +
  "Топливо" + chr(44)
  +
  (if p-chk-type = integer('16':U)
      then "Откуда: № ТРК" + chr(44)
           +
           "Куда: № ТРК" + chr(44)
      else (if p-chk-type = integer('17':U) and p-rs-grp-tech-refuell = 2 then "Назначение" + chr(44) else "№ ТРК" + chr(44)))
  +
  (if p-chk-type = integer('14':U) then
    "Пролито Кол-во в л" + chr(44)
    +
    "Пролито Сумма в руб." + chr(44)
    +
    "Пролито Кол-во чеков" + chr(44)
    +
    "Не пролито Кол-во в л" + chr(44)
    +
    "Не пролито Сумма в руб." + chr(44)
    +
    "Не пролито Кол-во чеков"
   else
     (if p-chk-type = integer('36':U) then
      "Предоплата Кол-во в л" + chr(44)
      +
      "Предоплата Сумма в руб." + chr(44)
      +
      "Предоплата Кол-во чеков" + chr(44)
      +
      "Постоплата Кол-во в л" + chr(44)
      +
      "Постоплата Сумма в руб." + chr(44)
      +
      "Постоплата Кол-во чеков" else
     (if p-chk-type = integer('17':U) and p-rs-grp-tech-refuell = 1 then "Назначение" + chr(44)
      else (if p-chk-type = integer('17':U) and p-rs-grp-tech-refuell = 2 then "№ ТРК" + chr(44) else '':U))
      +
      "Кол-во в л" + chr(44)
      +
      "Сумма в руб." + chr(44)
      +
      "Кол-во чеков"))
  sheetf.sizes =
      "5" + chr(44)
      +
      "25" + chr(44)
      +
      (if p-chk-type = integer('16':U) then
        "8" + chr(44)
        +
        "8" + chr(44)
      else
        (if p-chk-type = integer('17':U) and p-rs-grp-tech-refuell = 2 then "11" + chr(44) else "8" + chr(44)))
      +
      (if p-chk-type = integer('14':U) or p-chk-type = integer('36':U) then
        "10" + chr(44)
        +
        "10" + chr(44)
        +
        "10" + chr(44)
        +
        "10" + chr(44)
        +
        "10" + chr(44)
        +
        "10"
       else
         (if p-chk-type = integer('17':U) then
         (if p-chk-type = integer('17':U) and p-rs-grp-tech-refuell = 2 then "8" + chr(44) else "11" + chr(44))
         else '':U)
        +
        "18" + chr(44)
        +
        "18" + chr(44)
        +
        "10")
  str2 =
                     (if p-chk-type = 0
                     then "Все виды чеков"
                     else entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))
  .
  run rep/extitle.p (p-type-num).
  for each obj-list no-lock:
    loc-obj-count = loc-obj-count + 1.
    if loc-obj-count > 1 then
    do:
      if Make-Excel then  put   stream ForExcel unformatted skip.
    end.
    if Make-Excel then  put   stream ForExcel unformatted
    substitute("Объект: &1", obj-list.obj-name) skip.
      for each buf_temp-petrol-chk where
            buf_temp-petrol-chk.obj-type = obj-list.obj-type
        and buf_temp-petrol-chk.obj-code = obj-list.obj-code
        and buf_temp-petrol-chk.chk-type = p-chk-type
        and (buf_temp-petrol-chk.prim    = yes or p-chk-type = 0)
        ,
          first buf_temp-goods where
                buf_temp-goods.gds-code = buf_temp-petrol-chk.gds-code
      break
      by buf_temp-petrol-chk.pay-desk
      by buf_temp-petrol-chk.gds-code
      by buf_temp-petrol-chk.pump
      :
        if buf_temp-petrol-chk.pay-desk = 0
        or buf_temp-petrol-chk.pump = 0
        then NEXT.
        if first-of(buf_temp-petrol-chk.pay-desk) then
        do:
          assign
            accum-pay-desk-doc-qnty = 0
            accum-pay-desk-sum-base = 0
            accum-pay-desk-trans-number = 0
            accum-pay-desk-doc-qnty-ns = 0
            accum-pay-desk-sum-base-ns = 0
            accum-pay-desk-trans-number-ns = 0
          .
        end.
        if first-of(buf_temp-petrol-chk.gds-code) then
        do:
          assign
            accum-gds-code-doc-qnty = 0
            accum-gds-code-sum-base = 0
            accum-gds-code-trans-number = 0
            accum-gds-code-doc-qnty-ns = 0
            accum-gds-code-sum-base-ns = 0
            accum-gds-code-trans-number-ns = 0
          .
        end.
        if first-of(buf_temp-petrol-chk.gds-code) then
        do:
          assign
            accum-doc-qnty-dest = 0
            accum-sum-base-dest = 0
            accum-trans-number-dest = 0
          .
        end.
        assign
          accum-pay-desk-doc-qnty        = accum-pay-desk-doc-qnty        + buf_temp-petrol-chk.doc-qnty
          accum-pay-desk-sum-base        = accum-pay-desk-sum-base        + buf_temp-petrol-chk.sum-base
          accum-pay-desk-trans-number    = accum-pay-desk-trans-number    + buf_temp-petrol-chk.trans-number
          accum-pay-desk-doc-qnty-ns     = accum-pay-desk-doc-qnty-ns     + buf_temp-petrol-chk.doc-qnty-ns
          accum-pay-desk-sum-base-ns     = accum-pay-desk-sum-base-ns     + buf_temp-petrol-chk.sum-base-ns
          accum-pay-desk-trans-number-ns = accum-pay-desk-trans-number-ns + buf_temp-petrol-chk.trans-number-ns
          accum-gds-code-doc-qnty        = accum-gds-code-doc-qnty        + buf_temp-petrol-chk.doc-qnty
          accum-gds-code-sum-base        = accum-gds-code-sum-base        + buf_temp-petrol-chk.sum-base
          accum-gds-code-trans-number    = accum-gds-code-trans-number    + buf_temp-petrol-chk.trans-number
          accum-gds-code-doc-qnty-ns     = accum-gds-code-doc-qnty-ns     + buf_temp-petrol-chk.doc-qnty-ns
          accum-gds-code-sum-base-ns     = accum-gds-code-sum-base-ns     + buf_temp-petrol-chk.sum-base-ns
          accum-gds-code-trans-number-ns = accum-gds-code-trans-number-ns + buf_temp-petrol-chk.trans-number-ns
          accum-doc-qnty-dest            = accum-doc-qnty-dest            + buf_temp-petrol-chk.doc-qnty
          accum-sum-base-dest            = accum-sum-base-dest            + buf_temp-petrol-chk.sum-base
          accum-trans-number-dest        = accum-trans-number-dest        + buf_temp-petrol-chk.trans-number
        .
        if first-of(buf_temp-petrol-chk.pay-desk)
        or first-of(buf_temp-petrol-chk.gds-code)
        then
        if Make-Excel then  put   stream ForExcel unformatted
          buf_temp-petrol-chk.pay-desk                      CHR(9)
        .
        else
        if Make-Excel then  put   stream ForExcel unformatted
                                                            CHR(9)
        .
        if first-of(buf_temp-petrol-chk.gds-code)
        then
        do:
          if Make-Excel then  put   stream ForExcel unformatted
            buf_temp-goods.gds-name CHR(9)
          .
        end.
        else
        do:
          if Make-Excel then  put   stream ForExcel unformatted
                                                            CHR(9) +
                                                            CHR(9)
          .
        end.
        if Make-Excel then  put   stream ForExcel unformatted
          (if p-chk-type = integer('17':U) and p-rs-grp-tech-refuell = 2 then buf_temp-petrol-chk.pay-name
                                                                                       else string(buf_temp-petrol-chk.pump)) CHR(9)
        .
        if p-chk-type = integer('16':U)
        then
          if Make-Excel then  put   stream ForExcel unformatted
            buf_temp-petrol-chk.pump-2                      CHR(9)
          .
        if p-chk-type = integer('17':U) and p-rs-grp-tech-refuell = 1 then
        do:
          if Make-Excel then  put   stream ForExcel unformatted
            buf_temp-petrol-chk.pay-name                    CHR(9)
          .
        end.
        else
        do:
          if p-chk-type = integer('17':U) and p-rs-grp-tech-refuell = 2 then
          do:
            if Make-Excel then  put   stream ForExcel unformatted
              buf_temp-petrol-chk.pump                      CHR(9)
            .
          end.
        end.
        if Make-Excel then  put   stream ForExcel unformatted
          buf_temp-petrol-chk.doc-qnty                      CHR(9)
        .
        if p-chk-type <> integer('14':U) and p-chk-type <> integer('36':U) then
        do:
          if Make-Excel then  put   stream ForExcel unformatted
            buf_temp-petrol-chk.sum-base                    CHR(9)
            buf_temp-petrol-chk.trans-number
            skip.
        end.
        else
        do:
          if Make-Excel then  put   stream ForExcel unformatted
            buf_temp-petrol-chk.sum-base                     CHR(9)
            buf_temp-petrol-chk.trans-number                 CHR(9)
            buf_temp-petrol-chk.doc-qnty-ns                  CHR(9)
            buf_temp-petrol-chk.sum-base-ns                  CHR(9)
            buf_temp-petrol-chk.trans-number-ns
            skip.
        end.
        define buffer buf2_temp-petrol-chk for temp-petrol-chk.
        define buffer dest2_temp-petrol-chk for temp-petrol-chk.
        if p-chk-type = integer('17':U)
        and last-of(buf_temp-petrol-chk.gds-code) then
        do:
          for each buf2_temp-petrol-chk where
                   buf2_temp-petrol-chk.obj-type = buf_temp-petrol-chk.obj-type
               and buf2_temp-petrol-chk.obj-code = buf_temp-petrol-chk.obj-code
               and buf2_temp-petrol-chk.pay-desk = buf_temp-petrol-chk.pay-desk
               and buf2_temp-petrol-chk.gds-code = buf_temp-petrol-chk.gds-code
               and buf2_temp-petrol-chk.pump = 0
               and buf2_temp-petrol-chk.pay-code <> 0
          no-lock
          :
            if Make-Excel then  put   stream ForExcel unformatted
                                                                 CHR(9)
              substitute("Итого по &1", buf_temp-goods.gds-name) CHR(9)
              (if p-chk-type = integer('17':U) and p-rs-grp-tech-refuell = 2
              then buf2_temp-petrol-chk.pay-name +               CHR(9) +
                                                                 CHR(9)
              else
                                                                 CHR(9) +
              buf2_temp-petrol-chk.pay-name +                    CHR(9))
              buf2_temp-petrol-chk.doc-qnty                      CHR(9)
              buf2_temp-petrol-chk.sum-base                      CHR(9)
              buf2_temp-petrol-chk.trans-number
              skip
            .
          end.
        end.
        if last-of(buf_temp-petrol-chk.gds-code) then
        do:
          case p-chk-type:
            when integer('14':U) or when integer('36':U)  then
            do:
              if Make-Excel then  put   stream ForExcel unformatted
                                                                   CHR(9)
                substitute("Итого по &1", buf_temp-goods.gds-name) CHR(9)
                                                                   CHR(9)
                accum-gds-code-doc-qnty                            CHR(9)
                accum-gds-code-sum-base                            CHR(9)
                accum-gds-code-trans-number                        CHR(9)
                accum-gds-code-doc-qnty-ns                         CHR(9)
                accum-gds-code-sum-base-ns                         CHR(9)
                accum-gds-code-trans-number-ns
                skip
              .
            end.
            when integer('17':U) then
            do:
              if Make-Excel then  put   stream ForExcel unformatted
                                                                   CHR(9)
                substitute("Итого по &1 по всем назначениям", buf_temp-goods.gds-name) CHR(9)
                                                                   CHR(9)
                                                                   CHR(9)
                accum-gds-code-doc-qnty                            CHR(9)
                accum-gds-code-sum-base                            CHR(9)
                accum-gds-code-trans-number
                skip
              .
            end.
            otherwise
            do:
              if Make-Excel then  put   stream ForExcel unformatted
                                                                   CHR(9)
                substitute("Итого по &1", buf_temp-goods.gds-name) CHR(9)
                                                                   CHR(9)
                (if p-chk-type = integer('16':U) then CHR(9)
                 else                                              '':U)
                accum-gds-code-doc-qnty                            CHR(9)
                accum-gds-code-sum-base                            CHR(9)
                accum-gds-code-trans-number
                skip
              .
            end.
          end case.
        end.
        if last-of(buf_temp-petrol-chk.pay-desk) then
        do:
          if p-chk-type <> integer('14':U) and p-chk-type <> integer('36':U) then
          do:
            if p-chk-type = integer('17':U) then
            do:
              for each bufo3_temp-petrol-chk where
                       bufo3_temp-petrol-chk.chk-type = p-chk-type
                   and bufo3_temp-petrol-chk.obj-type = obj-list.obj-type
                   and bufo3_temp-petrol-chk.obj-code = obj-list.obj-code
                   and bufo3_temp-petrol-chk.gds-code = 0
                   and bufo3_temp-petrol-chk.pay-desk = buf_temp-petrol-chk.pay-desk
                   and bufo3_temp-petrol-chk.pump = 0
                   and bufo3_temp-petrol-chk.pump-2 = 0
                   and bufo3_temp-petrol-chk.pay-code <> 0
              no-lock:
                do:
                  if Make-Excel then  put   stream ForExcel unformatted
                                                                   CHR(9)
                    substitute("Итого по кассе &1", buf_temp-petrol-chk.pay-desk) CHR(9)
                    (if p-chk-type = integer('17':U) and p-rs-grp-tech-refuell = 2
                    then bufo3_temp-petrol-chk.pay-name +          CHR(9) +
                                                                   CHR(9)
                    else
                                                                   CHR(9) +
                    bufo3_temp-petrol-chk.pay-name +               CHR(9))
                    bufo3_temp-petrol-chk.doc-qnty                 CHR(9)
                    bufo3_temp-petrol-chk.sum-base                 CHR(9)
                    bufo3_temp-petrol-chk.trans-number
                    skip
                  .
                end.
              end.
            end.
            do:
              if Make-Excel then  put   stream ForExcel unformatted
                                                                      CHR(9)
                substitute((if p-chk-type = integer('17':U)
                            then "Итого по кассе &1 по всем назначениям:"
                            else "Итого по кассе &1: "), buf_temp-petrol-chk.pay-desk) CHR(9)
                (if p-chk-type = integer('17':U) then   CHR(9)
                 else                                                         '':U)
                (if p-chk-type = integer('16':U) then CHR(9)
                 else                                                         '':U)
                                                                      CHR(9)
                accum-pay-desk-doc-qnty                               CHR(9)
                accum-pay-desk-sum-base                               CHR(9)
                accum-pay-desk-trans-number
                skip
              .
            end.
          end.
          if p-chk-type = integer('14':U) or p-chk-type = integer('36':U) then
          do:
            if Make-Excel then  put   stream ForExcel unformatted
                                                CHR(9)
              substitute("Итого по кассе &1", buf_temp-petrol-chk.pay-desk) CHR(9)
                                                CHR(9)
              accum-pay-desk-doc-qnty           CHR(9)
              accum-pay-desk-sum-base           CHR(9)
              accum-pay-desk-trans-number       CHR(9)
              accum-pay-desk-doc-qnty-ns        CHR(9)
              accum-pay-desk-sum-base-ns        CHR(9)
              accum-pay-desk-trans-number-ns
              skip
            .
          end.
        end.
        if last-of(buf_temp-petrol-chk.pay-desk)
          and last(buf_temp-petrol-chk.pay-desk)
        then
        do:
          if Make-Excel then  put   stream ForExcel unformatted
          "Итоги по видам топлива:"
          skip.
          assign
            accum-doc-qnty = 0
            accum-sum-base = 0
            accum-trans-number = 0
            accum-doc-qnty-ns = 0
            accum-sum-base-ns = 0
            accum-trans-number-ns = 0
          .
          v-first-good = yes.
          for each bufo_temp-petrol-chk where
                   bufo_temp-petrol-chk.chk-type = p-chk-type
               and bufo_temp-petrol-chk.obj-type = obj-list.obj-type
               and bufo_temp-petrol-chk.obj-code = obj-list.obj-code
               and bufo_temp-petrol-chk.pay-desk = 0
               and bufo_temp-petrol-chk.pump = 0
               and bufo_temp-petrol-chk.pay-code = 0
          ,
             first bufo_temp-goods where
                   bufo_temp-goods.gds-code = bufo_temp-petrol-chk.gds-code
          :
            assign
              accum-doc-qnty        = accum-doc-qnty        + bufo_temp-petrol-chk.doc-qnty
              accum-sum-base        = accum-sum-base        + bufo_temp-petrol-chk.sum-base
              accum-trans-number    = accum-trans-number    + bufo_temp-petrol-chk.trans-number
              accum-doc-qnty-ns     = accum-doc-qnty-ns     + bufo_temp-petrol-chk.doc-qnty-ns
              accum-sum-base-ns     = accum-sum-base-ns     + bufo_temp-petrol-chk.sum-base-ns
              accum-trans-number-ns = accum-trans-number-ns + bufo_temp-petrol-chk.trans-number-ns
            .
            if p-chk-type = integer('17':U) then
            do:
              for each bufo2_temp-petrol-chk where
                       bufo2_temp-petrol-chk.chk-type = p-chk-type
                   and bufo2_temp-petrol-chk.obj-type = obj-list.obj-type
                   and bufo2_temp-petrol-chk.obj-code = obj-list.obj-code
                   and bufo2_temp-petrol-chk.gds-code = bufo_temp-petrol-chk.gds-code
                   and bufo2_temp-petrol-chk.pay-desk = 0
                   and bufo2_temp-petrol-chk.pump = 0
                   and bufo2_temp-petrol-chk.pay-code <> 0
              ,
                 first bufo2_temp-goods where
                       bufo2_temp-goods.gds-code = bufo2_temp-petrol-chk.gds-code
              :
       do:
                  if Make-Excel then  put   stream ForExcel unformatted
                                                                     CHR(9)
                    substitute("ИТОГО &1", bufo_temp-goods.gds-name) CHR(9)
                    (if p-chk-type = integer('17':U) and p-rs-grp-tech-refuell = 2
                    then bufo2_temp-petrol-chk.pay-name +            CHR(9) +
                                                                     CHR(9)
                    else
                                                                     CHR(9) +
                    bufo2_temp-petrol-chk.pay-name +                 CHR(9))
                    bufo2_temp-petrol-chk.doc-qnty                   CHR(9)
                    bufo2_temp-petrol-chk.sum-base                   CHR(9)
                    bufo2_temp-petrol-chk.trans-number
                    skip
                  .
                end.
              end.
            end.
            if p-chk-type <> integer('14':U) and p-chk-type <> integer('36':U) then
            do:
              if Make-Excel then  put   stream ForExcel unformatted
                                                                  CHR(9)
                substitute((if p-chk-type = integer('17':U) then "ИТОГО &1 по всем назначениям:"
                                                                          else "ИТОГО по &1")
                                                                          ,
                                                                          bufo_temp-goods.gds-name)
                                                                  CHR(9)
                                                                  CHR(9)
                (if p-chk-type = integer('16':U) then CHR(9)
                 else                                             '':U)
                (if p-chk-type = integer('17':U) then
                                                               (if p-rs-grp-tech-refuell = 1 then bufo_temp-petrol-chk.pay-name + CHR(9)
                                                                                             else CHR(9) + bufo_temp-petrol-chk.pay-name)
                 else                                             '':U)
                bufo_temp-petrol-chk.doc-qnty                     CHR(9)
                bufo_temp-petrol-chk.sum-base                     CHR(9)
                bufo_temp-petrol-chk.trans-number
                skip
              .
              v-first-good = no.
            end.
            else
            do:
              if Make-Excel then  put   stream ForExcel unformatted
                                                                    CHR(9)
                substitute("ИТОГО по &1", bufo_temp-goods.gds-name) CHR(9)
                                                                    CHR(9)
                bufo_temp-petrol-chk.doc-qnty                       CHR(9)
                bufo_temp-petrol-chk.sum-base                       CHR(9)
                bufo_temp-petrol-chk.trans-number                   CHR(9)
                bufo_temp-petrol-chk.doc-qnty-ns                    CHR(9)
                bufo_temp-petrol-chk.sum-base-ns                    CHR(9)
                bufo_temp-petrol-chk.trans-number-ns
                skip
              .
              v-first-good = no.
            end.
          end.
          if p-chk-type <> integer('14':U) and p-chk-type <> integer('36':U) then
          do:
            if p-chk-type = integer('17':U) then
            do:
              for each bufo3_temp-petrol-chk where
                       bufo3_temp-petrol-chk.chk-type = p-chk-type
                   and bufo3_temp-petrol-chk.obj-type = obj-list.obj-type
                   and bufo3_temp-petrol-chk.obj-code = obj-list.obj-code
                   and bufo3_temp-petrol-chk.gds-code = 0
                   and bufo3_temp-petrol-chk.pay-desk = 0
                   and bufo3_temp-petrol-chk.pump = 0
                   and bufo3_temp-petrol-chk.pump-2 = 0
                   and bufo3_temp-petrol-chk.pay-code <> 0
              no-lock:
                do:
                  if Make-Excel then  put   stream ForExcel unformatted
                                                                     CHR(9)
                    substitute("ИТОГО по &1", entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))       CHR(9)
                    (if p-chk-type = integer('17':U) and p-rs-grp-tech-refuell = 2
                    then bufo3_temp-petrol-chk.pay-name +            CHR(9) +
                                                                     CHR(9)
                    else
                                                                     CHR(9) +
                    bufo3_temp-petrol-chk.pay-name +                 CHR(9))
                    bufo3_temp-petrol-chk.doc-qnty                   CHR(9)
                    bufo3_temp-petrol-chk.sum-base                   CHR(9)
                    bufo3_temp-petrol-chk.trans-number
                    skip
                  .
                end.
              end.
            end.
            if Make-Excel then  put   stream ForExcel unformatted
              skip(0)
                                                                  CHR(9)
              substitute((if p-chk-type = integer('17':U) then "ИТОГ &1 по всем назначениям" else "ИТОГ &1"), caps((if p-chk-type = 0 then
              "всем типам чеков" else entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))))
                                                                  CHR(9)
                                                                  CHR(9)
              (if p-chk-type = integer('16':U) or
              p-chk-type = integer('17':U) then     CHR(9)
               else                                               '':U)
              accum-doc-qnty                                      CHR(9)
              accum-sum-base                                      CHR(9)
              accum-trans-number
              skip
            .
          end.
          else
          do:
            if Make-Excel then  put   stream ForExcel unformatted
            skip(0)
                                                                  CHR(9)
            substitute("ИТОГ по &1", caps((if p-chk-type = 0 then "всем типам чеков" else entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))))
                                                                  CHR(9)
                                                                  CHR(9)
            accum-doc-qnty                                        CHR(9)
            accum-sum-base                                        CHR(9)
            accum-trans-number                                    CHR(9)
            accum-doc-qnty-ns                                     CHR(9)
            accum-sum-base-ns                                     CHR(9)
            accum-trans-number-ns
            skip.
          end.
   end.
          end.
          if multi-obj
          and loc-obj-count = obj-count
          then
          do:
            if Make-Excel then  put   stream ForExcel unformatted
              substitute("ПО ВСЕМ ВЫБРАННЫМ ОБЪЕКТАМ")
              skip
            .
            assign
              accum-doc-qnty = 0
              accum-sum-base = 0
              accum-trans-number = 0
               accum-doc-qnty-ns = 0
               accum-sum-base-ns = 0
                  accum-trans-number-ns = 0
            .
            for each bufo_temp-petrol-chk where
                     bufo_temp-petrol-chk.obj-type = '':U
                 and bufo_temp-petrol-chk.obj-code = 0
                 and bufo_temp-petrol-chk.chk-type = p-chk-type
                 and bufo_temp-petrol-chk.pump = 0
                 and bufo_temp-petrol-chk.pay-desk = 0
                 and bufo_temp-petrol-chk.pay-code = 0
            ,
               first bufo_temp-goods where
                    bufo_temp-goods.gds-code = bufo_temp-petrol-chk.gds-code
            break
            by bufo_temp-petrol-chk.gds-code
            :
              assign
                accum-doc-qnty     = accum-doc-qnty      + bufo_temp-petrol-chk.doc-qnty
                accum-sum-base     = accum-sum-base      + bufo_temp-petrol-chk.sum-base
                accum-trans-number = accum-trans-number  + bufo_temp-petrol-chk.trans-number
                 accum-doc-qnty-ns     = accum-doc-qnty-ns     + bufo_temp-petrol-chk.doc-qnty-ns
              accum-sum-base-ns     = accum-sum-base-ns     + bufo_temp-petrol-chk.sum-base-ns
              accum-trans-number-ns = accum-trans-number-ns + bufo_temp-petrol-chk.trans-number-ns
              .
                        if p-chk-type <> integer('14':U) and p-chk-type <> integer('36':U) then
                          do:
                              if Make-Excel then  put   stream ForExcel unformatted
                                      CHR(9)
                                      bufo_temp-goods.gds-name                        CHR(9)
                                      CHR(9)
                                      (if p-chk-type = integer('16':U) or p-chk-type = integer('17':U) then CHR(9)
                                      else                                           '':u)
                                      bufo_temp-petrol-chk.doc-qnty                       CHR(9)
                                      bufo_temp-petrol-chk.sum-base                       CHR(9)
                                      bufo_temp-petrol-chk.trans-number
                                      skip
                                      .
                          end.
                      else
                          do:
                              if Make-Excel then  put   stream ForExcel unformatted
                                      CHR(9)
                                      bufo_temp-goods.gds-name                        CHR(9)
                                      CHR(9)
                                      (if p-chk-type = integer('16':U) or p-chk-type = integer('17':U) then CHR(9)
                                      else                                           '':u)
                                      bufo_temp-petrol-chk.doc-qnty                       CHR(9)
                                      bufo_temp-petrol-chk.sum-base                       CHR(9)
                                      bufo_temp-petrol-chk.trans-number                   CHR(9)
                                      bufo_temp-petrol-chk.doc-qnty-ns                    CHR(9)
                                      bufo_temp-petrol-chk.sum-base-ns                    CHR(9)
                                      bufo_temp-petrol-chk.trans-number-ns
                                      skip
                                      .
                          end.
                      end.
                     if p-chk-type <> integer('14':U) and p-chk-type <> integer('36':U) then
                      do:
                          if Make-Excel then  put   stream ForExcel unformatted
                                  skip(1)
                                  CHR(9)
                                  substitute("ИТОГ по &1", caps(if p-chk-type = 0 then "всем типам чеков" else entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)))
                                  CHR(9)
                                  CHR(9)
                                  (if p-chk-type = integer('16':U) or p-chk-type = integer('17':U) then CHR(9)
                                  else                                           '':u)
                                  accum-doc-qnty                   CHR(9)
                                  accum-sum-base                   CHR(9)
                                  accum-trans-number
                                  skip
                                  .
                      end.
                     else
                      do:
                          if Make-Excel then  put   stream ForExcel unformatted
                                  skip(1)
                                  CHR(9)
                                  substitute("ИТОГ по &1", caps(if p-chk-type = 0 then "всем типам чеков" else entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)))
                                  CHR(9)
                                  CHR(9)
                                  (if p-chk-type = integer('16':U) or p-chk-type = integer('17':U) then CHR(9)
                                  else                                           '':u)
                                  accum-doc-qnty                    CHR(9)
                                  accum-sum-base                    CHR(9)
                                  accum-trans-number                CHR(9)
                                  accum-doc-qnty-ns                 CHR(9)
                                  accum-sum-base-ns                 CHR(9)
                                  accum-trans-number-ns
                                  skip
                                  .
                      end.
                  end.
      end.
  end.
end procedure.
