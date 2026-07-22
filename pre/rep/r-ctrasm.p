block-level on error undo, throw.
define input  parameter parparentproc           as handle    no-undo .
define input  parameter p-call-handle           as handle    no-undo .
define input  parameter p-is-schedule           as logical   no-undo .
define input  parameter p-date-start            as date      no-undo .
define input  parameter p-date-finish           as date      no-undo .
define input  parameter p-gds-by-am             as logical   no-undo .
define input  parameter p-group-by-order        as logical   no-undo .
define input  parameter p-group-by-post         as logical   no-undo .
define input  parameter p-critical-qnty-balance as decimal   no-undo .
define input  parameter p-critical-qnty-sale    as decimal   no-undo .
define input  parameter p-critical-qnty-order   as decimal   no-undo .
define input  parameter p-days-wt-goods         as integer   no-undo .
define input  parameter p-dir-name              as character no-undo .
define input  parameter p-rep-code              as character no-undo .
define input  parameter p-igt-all               as logical   no-undo .
define input  parameter p-igt-new               as logical   no-undo .
define input  parameter p-igt-com               as logical   no-undo .
define input  parameter p-igt-spec              as logical   no-undo .
define input  parameter p-igt-del               as logical   no-undo .
define input  parameter p-igt-empty             as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision: 1e08ec0ad8b4, 962, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Thu Feb 16 15:20:31 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ctrasm.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-ctrasm.p $":U .
define variable vss-description as character no-undo init "Отчет Контроль АМ".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable var-report-r-b as character no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure ost-line :
  define input  parameter x-store-code like ub.clients.obj-code    no-undo .
  define input  parameter x-store-type like ub.clients.obj-type    no-undo .
  define input  parameter x-artic      like ub.stk-line.artic      no-undo .
  define input  parameter x-prod-code  like ub.stk-line.prod-code  no-undo .
  define input  parameter x-prod-type  like ub.stk-line.prod-type  no-undo .
  define input  parameter x-tog-shift  as logical no-undo .
  define input  parameter x-fact-order like ub.stk-line.fact-order no-undo .
  define input  parameter x-sum-type   like ub.stk-line.sum-type   no-undo .
  define input  parameter x-cat-id     like ub.stk-line.cat-id     no-undo .
  define input  parameter xtog-obj     as logical no-undo .
  define output parameter quantity     like ub.stk-line.fact-qnty  no-undo .
  define output parameter coast_r      like ub.stk-line.sum-rubl   no-undo .
  define output parameter coast_v      like ub.stk-line.sum-rubl   no-undo .
  define output parameter vat_r        like ub.stk-line.sum-rubl   no-undo .
  define output parameter vat_v        like ub.stk-line.sum-rubl   no-undo .
  define output parameter slt_r        like ub.stk-line.sum-rubl   no-undo .
  define output parameter slt_v        like ub.stk-line.sum-rubl   no-undo .
  define buffer buff-obj-list  for obj-list .
  define buffer buff-stk-line  for ub.stk-line .
  assign
    Quantity = 0
    Coast_R  = 0
    Coast_V  = 0
    VAT_R    = 0
    VAT_V    = 0
    SLT_R    = 0
    SLT_V    = 0
  .
  if  x-tog-shift = false then do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
      find last buff-stk-line no-lock
        where buff-stk-line.obj-type   = buff-obj-list.obj-type
          and buff-stk-line.obj-code   = buff-obj-list.obj-code
          and buff-stk-line.artic      = x-artic
          and buff-stk-line.prod-type  = x-prod-type
          and buff-stk-line.prod-code  = x-prod-code
          and buff-stk-line.sum-type   = x-sum-type
          and buff-stk-line.cat-id     = '##,##':U
          and buff-stk-line.fact-order <= x-fact-order
          and buff-stk-line.shift-num  = 0
        use-index category
        no-error .
      if available buff-stk-line then do:
        assign
          Quantity = Quantity +  buff-stk-line.fact-qnty
          Coast_R  = Coast_R  +  buff-stk-line.sum-rubl
          Coast_V  = Coast_V  +  buff-stk-line.sum-base
          VAT_R    = VAT_R    +  buff-stk-line.VAT-rubl
          VAT_V    = VAT_V    +  buff-stk-line.VAT-base
          SLT_R    = SLT_R    +  buff-stk-line.SLT-rubl
          SLT_V    = SLT_V    +  buff-stk-line.SLT-base
        .
      end.
    end.
  end.
  else do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
      find last buff-stk-line no-lock
        where buff-stk-line.obj-type   = buff-obj-list.obj-type
          and buff-stk-line.obj-code   = buff-obj-list.obj-code
          and buff-stk-line.artic      = x-artic
          and buff-stk-line.prod-type  = x-prod-type
          and buff-stk-line.prod-code  = x-prod-code
          and buff-stk-line.sum-type   = x-sum-type
          and buff-stk-line.cat-id     = '##,##':U
          and buff-stk-line.fact-order <= x-fact-order
          and buff-stk-line.shift-num  > 0
        use-index category
        no-error .
      if available buff-stk-line then do:
        assign
          Quantity = Quantity +  buff-stk-line.fact-qnty
          Coast_R  = Coast_R  +  buff-stk-line.sum-rubl
          Coast_V  = Coast_V  +  buff-stk-line.sum-base
          VAT_R    = VAT_R    +  buff-stk-line.VAT-rubl
          VAT_V    = VAT_V    +  buff-stk-line.VAT-base
          SLT_R    = SLT_R    +  buff-stk-line.SLT-rubl
          SLT_V    = SLT_V    +  buff-stk-line.SLT-base
        .
      end.
    end.
  end.
end procedure.
procedure ost-lineother-tax :
  define input  parameter x-store-code like ub.clients.obj-code      no-undo.
  define input  parameter x-store-type like ub.clients.obj-type      no-undo.
  define input  parameter x-artic      like ub.stk-line.artic        no-undo.
  define input  parameter x-prod-code  like ub.stk-line.prod-code    no-undo.
  define input  parameter x-prod-type  like ub.stk-line.prod-type    no-undo.
  define input  parameter x-tog-shift  as logical no-undo .
  define input  parameter x-fact-order like ub.stk-line.fact-order   no-undo.
  define input  parameter x-sum-type   like ub.stk-line.sum-type     no-undo.
  define input  parameter x-type-id    like ub.stk-line.cat-id       no-undo.
  define input  parameter xTog-obj     as logical no-undo .
  define output parameter Quantity     like ub.stk-line.fact-qnty   no-undo.
  define output parameter Coast_R      like ub.stk-line.sum-rubl    no-undo.
  define output parameter Coast_V      like ub.stk-line.sum-rubl    no-undo.
  define output parameter VAT_R        like ub.stk-line.sum-rubl    no-undo.
  define output parameter VAT_V        like ub.stk-line.sum-rubl    no-undo.
  define output parameter SLT_R        like ub.stk-line.sum-rubl    no-undo.
  define output parameter SLT_V        like ub.stk-line.sum-rubl    no-undo.
  define output parameter other_R      like ub.stk-line.sum-rubl    no-undo.
  define output parameter other_V      like ub.stk-line.sum-rubl    no-undo.
  define buffer buff-obj-list  for obj-list .
  define buffer buff-stk-line  for ub.stk-line .
  assign
    Quantity = 0
    Coast_R  = 0
    Coast_V  = 0
    VAT_R    = 0
    VAT_V    = 0
    SLT_R    = 0
    SLT_V    = 0
    other_R  = 0
    other_V  = 0
  .
  if  x-tog-shift = false then do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
      find last buff-stk-line no-lock
        where buff-stk-line.obj-type   = buff-obj-list.obj-type
          and buff-stk-line.obj-code   = buff-obj-list.obj-code
          and buff-stk-line.artic      = x-artic
          and buff-stk-line.prod-type  = x-prod-type
          and buff-stk-line.prod-code  = x-prod-code
          and buff-stk-line.sum-type   = x-sum-type
          and buff-stk-line.cat-id     = '##,##':U
          and buff-stk-line.fact-order <= x-fact-order
          and buff-stk-line.shift-num  = 0
        use-index category
        no-error .
      if available buff-stk-line then do:
        assign
          Quantity = Quantity +  buff-stk-line.fact-qnty
          Coast_R  = Coast_R  +  buff-stk-line.sum-rubl
          Coast_V  = Coast_V  +  buff-stk-line.sum-base
          VAT_R    = VAT_R    +  buff-stk-line.VAT-rubl
          VAT_V    = VAT_V    +  buff-stk-line.VAT-base
          SLT_R    = SLT_R    +  buff-stk-line.SLT-rubl
          SLT_V    = SLT_V    +  buff-stk-line.SLT-base
          other_R  = other_R  +  buff-stk-line.other-rubl
          other_V  = other_V  +  buff-stk-line.other-base
        .
      end.
    end.
  end.
  else do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
      find last buff-stk-line no-lock
        where buff-stk-line.obj-type   = buff-obj-list.obj-type
          and buff-stk-line.obj-code   = buff-obj-list.obj-code
          and buff-stk-line.artic      = x-artic
          and buff-stk-line.prod-type  = x-prod-type
          and buff-stk-line.prod-code  = x-prod-code
          and buff-stk-line.sum-type   = x-sum-type
          and buff-stk-line.cat-id     = '##,##':U
          and buff-stk-line.fact-order <= x-fact-order
          and buff-stk-line.shift-num  > 0
        use-index category
        no-error .
      if available buff-stk-line then do:
        assign
          Quantity = Quantity +  buff-stk-line.fact-qnty
          Coast_R  = Coast_R  +  buff-stk-line.sum-rubl
          Coast_V  = Coast_V  +  buff-stk-line.sum-base
          VAT_R    = VAT_R    +  buff-stk-line.VAT-rubl
          VAT_V    = VAT_V    +  buff-stk-line.VAT-base
          SLT_R    = SLT_R    +  buff-stk-line.SLT-rubl
          SLT_V    = SLT_V    +  buff-stk-line.SLT-base
          other_R = other_R   +  buff-stk-line.other-rubl
          other_V = other_V   +  buff-stk-line.other-base
        .
      end.
    end.
  end.
end procedure.
procedure ost-line-kg :
  define  input parameter p-obj-code    like ub.stk-line.obj-code   no-undo .
  define  input parameter p-obj-type    like ub.stk-line.obj-type   no-undo .
  define  input parameter p-artic       like ub.stk-line.artic      no-undo .
  define  input parameter p-prod-code   like ub.stk-line.prod-code  no-undo .
  define  input parameter p-prod-type   like ub.stk-line.prod-type  no-undo .
  define  input parameter p-fact-order  like ub.stk-line.fact-order no-undo .
  define output parameter p-quantity-kg like ub.stk-line.fact-qnty  no-undo initial 0.00 .
  define buffer buff-obj-list  for obj-list .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_inv-line for ub.inv-line .
  do
  on error undo, return error
  :
    for each buf_doc-line no-lock where
             buf_doc-line.obj-type    = p-obj-type   and
             buf_doc-line.obj-code    = p-obj-code   and
             buf_doc-line.prod-type   = p-prod-type  and
             buf_doc-line.prod-code   = p-prod-code  and
             buf_doc-line.artic       = p-artic      and
             buf_doc-line.status_     = 'факт':U      and
             buf_doc-line.fact-order <= p-fact-order
          by buf_doc-line.fact-order    descending
    :
      find first buf_inv-line no-lock where
                 buf_inv-line.doc-code  = buf_doc-line.doc-code  and
                 buf_inv-line.artic     = buf_doc-line.artic     and
                 buf_inv-line.prod-type = buf_doc-line.prod-type and
                 buf_inv-line.prod-code = buf_doc-line.prod-code no-error .
      if available buf_inv-line
      then do:
        if buf_inv-line.after-cli-qnty <> ?
        then do:
          assign
            p-quantity-kg = buf_inv-line.after-cli-qnty
          .
          leave .
        end.
      end.
    end.
    if p-quantity-kg = ?
    then do:
      assign
        p-quantity-kg = 0
      .
    end.
  end.
end procedure.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define temp-table temp-font no-undo
  field fontnum  as integer
  field fontname as character
  field fontsize as character
  field fonttype as character
  field font-h   as integer
  field font-w   as integer
  field v-row    as integer
  field v-col    as integer
  field v-row-lans as integer
  field v-col-lans as integer
index pi fontnum
.
procedure get-font-ini :
  do
  on error undo, return error return-value
  :
define variable ii as integer   no-undo .
define variable v-font7 as character no-undo .
define variable v-font as character no-undo .
define variable loc-name as character no-undo .
define variable loc-size as character no-undo .
define variable loc-type as character no-undo .
define variable old_H as integer   no-undo .
define variable old_w as integer   no-undo .
define variable old-row  as integer   no-undo .
define variable old-col  as integer   no-undo .
define variable old-row-lans  as integer   no-undo .
define variable old-col-lans  as integer   no-undo .
define variable vv as integer   no-undo .
empty temp-table temp-font.
  GET-KEY-VALUE SECTION "fonts" KEY "font7" VALUE v-font7 .
    case num-entries (v-font7) :
      when 4 then do:
          assign
            loc-name = entry ( 1 , v-font7 )
            loc-size = entry ( 2 , v-font7 )
            loc-type = entry ( 3 , v-font7 ) + "," +  entry ( 4 , v-font7 )
          .
      end.
      when 3 then do:
          assign
            loc-name = entry ( 1 , v-font7 )
            loc-size = entry ( 2 , v-font7 )
            loc-type = entry ( 3 , v-font7 )
          .
      end.
      when 2 then  do:
          assign
            loc-name = entry ( 1 , v-font7 )
            loc-size = entry ( 2 , v-font7 )
            loc-type = ""
          .
      end.
      when 1 then do:
          assign
            loc-name = trim(entry ( 1 , v-font7 ))
            loc-size = ""
            loc-type = ""
          .
      end.
    end case.
  create temp-font.
  assign
    temp-font.fontnum  = 7
    temp-font.fontname = trim(loc-name)
    temp-font.fontsize = trim(loc-size)
    temp-font.fonttype = trim(loc-type)
    temp-font.v-row    = 62
    temp-font.v-col    = 136
    temp-font.v-row-lans = 43
    temp-font.v-col-lans = 198
  .
  repeat ii = 16 to 100 :
    get-key-value section 'fonts' key 'font' + string(ii)   value v-font  .
    if v-font = "" or v-font = ? then leave.
    case num-entries (v-font) :
      when 4 then do:
          assign
            loc-name = entry ( 1 , v-font )
            loc-size = entry ( 2 , v-font )
            loc-type = entry ( 3 , v-font ) + "," +  entry ( 4 , v-font )
          .
      end.
      when 3 then do:
          assign
            loc-name = entry ( 1 , v-font )
            loc-size = entry ( 2 , v-font )
            loc-type = entry ( 3 , v-font )
          .
      end.
      when 2 then do:
          assign
            loc-name = entry ( 1 , v-font )
            loc-size = entry ( 2 , v-font )
            loc-type = ""
          .
      end.
      when 1 then do:
          assign
            loc-name = trim(entry ( 1 , v-font ))
            loc-size = ""
            loc-type = ""
          .
      end.
    end case.
  create temp-font.
  assign
    temp-font.fontnum  = ii
    temp-font.fontname = trim(loc-name)
    temp-font.fontsize = trim(loc-size)
    temp-font.fonttype = trim(loc-type)
  .
  end.
    for each temp-font :
       vv = integer(entry(2,temp-font.fontsize, "=" )) no-error .
       if  vv = ? then vv =  0 .
        run rep/exfont.p (
          input   temp-font.fontname ,
          input   vv ,
          input   temp-font.fonttype ,
          output  temp-font.font-h   ,
          output  temp-font.font-w   )
        .
    end.
find first temp-font where  temp-font.fontnum  = 7  .
old_H = temp-font.font-H .
old_w = temp-font.font-W .
old-row = temp-font.v-row .
old-col = temp-font.v-col .
old-row-lans = temp-font.v-row-lans .
old-col-lans = temp-font.v-col-lans .
    for each temp-font where
             temp-font.fontnum  <> 7 :
        assign
            temp-font.v-row    = old_H * old-row / temp-font.font-h
            temp-font.v-col    = old_W * old-col / temp-font.font-W
            temp-font.v-row-lans    = old_H * old-row-lans / temp-font.font-h
            temp-font.v-col-lans    = old_W * old-col-lans / temp-font.font-W
        .
    end.
  end.
end procedure.
PROCEDURE How-name :
define input  parameter h as integer no-undo .
define input  parameter w as integer no-undo .
define output parameter n as character  no-undo .
define variable A4port-H as integer   no-undo init 63.
define variable A4port-W as integer   no-undo init 136.
define variable A4lans-H as integer   no-undo init 43.
define variable A4lans-W as integer   no-undo init 198.
define variable Strim-W  as integer   no-undo init 278.
run define-a4-size (
     input ReportFontNum
    ,output A4port-H
    ,output A4port-W
    ,output A4lans-H
    ,output A4lans-W ).
If w >= 1 and w <= A4port-W Then DO:
  If h >= 1  and h <= A4lans-H Then n = "A4-lans":U.
  If h > A4lans-H  and h <= A4port-H Then n = "A4-port":U.
  If h > A4port-H              Then n = "to-file":U.
End.
If w > A4port-W and w <= A4lans-W Then DO:
  If h >= 1  and h <= A4lans-H Then n = "A4-lans":U.
  If h > A4lans-H  and h <= A4port-H Then n = "A3-lans":U.
  If h > A4port-H              Then n = "to-file":U.
End.
If w > A4lans-W and w <= Strim-W Then DO:
  If h >= 1  and h <= A4lans-H Then n = "to-file":U.
  If h > A4lans-H  and h <= A4port-H Then n = "A3-lans":U.
  If h > A4port-H              Then n = "to-file":U.
End.
If w > Strim-W Then DO:
   n = "to-file":U.
End.
END PROCEDURE.
PROCEDURE define-a4-size :
define input  parameter p-ReportFontNum as integer   no-undo .
define output parameter A4port-H as integer   no-undo .
define output parameter A4port-W as integer   no-undo .
define output parameter A4lans-H as integer   no-undo .
define output parameter A4lans-W as integer   no-undo .
if not can-find (first temp-font ) then do:
   run get-font-ini .
end.
find first temp-font where temp-font.fontnum = p-ReportFontNum no-error .
if available temp-font then do:
assign
  A4port-H = temp-font.v-row
  A4port-W = temp-font.v-col
  A4lans-H = temp-font.v-row-lans
  A4lans-W = temp-font.v-col-lans
.
end.
else do:
assign
  A4port-H = 63
  A4port-W = 136
  A4lans-H = 43
  A4lans-W = 198
.
end.
END PROCEDURE.
define variable vss-include-info15 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
def var vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable g#report-num  as integer   no-undo .
procedure OpenForExcel :
   define variable v-ch#ExcelApplication as com-handle no-undo .
   define variable v-ch#Workbook         as com-handle no-undo .
   define variable v-ch#Worksheet        as com-handle no-undo .
   os-delete value( string( session:temp-directory ) +
                              "rpt" + string( g#report-num ) + ".txt":U ) .
   os-delete value( string( session:temp-directory ) +
                              "rpt" + string( g#report-num ) + ".frm":U ) .
   os-delete value( string( session:temp-directory ) +
                              "rpt" + string( g#report-num ) + ".txl":U ) .
   if Make-Excel
   then do:
      output stream ForExcel to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) + ".txt":U ) ) .
      assign
         v-excel-file = string( session:temp-directory + "rpt" + string( g#report-num ) )
         number-list = 1
      .
      if make-excel-com
      then do:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#WorkSheet) then
RELEASE OBJECT ch#WorkSheet no-error.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Workbook) then
RELEASE OBJECT ch#Workbook no-error.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#ExcelApplication) then
RELEASE OBJECT ch#ExcelApplication no-error.
         create "Excel.Application" ch#excelApplication connect no-error.
         if error-status:error
         then do :
        create "Excel.Application" ch#excelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
         end.
         assign
            num#str#  = 0.
            v-ch#excelApplication  = ch#excelApplication.
            v-ch#excelApplication:Interactive = false.
            v-ch#excelApplication:ScreenUpdating = false.
            v-ch#excelApplication:Visible = false.
            ch#Workbook  = v-ch#excelApplication:Workbooks:add ().
            ch#WorkSheet = v-ch#excelApplication:Sheets:Item (1).
            v-ch#Worksheet = ch#WorkSheet.
            v-ch#Worksheet:Range ("A1"):Font:Bold = true.
            v-ch#Worksheet:Range ("A1"):Font:Size = 14.
            v-ch#Worksheet:Range ("A1"):HorizontalAlignment = -4131.
            v-ch#Worksheet:Range ("A1"):VerticalAlignment   = -4160
         no-error .
         if error-status:error
         then do:
            Make-Excel-com = false .
            Make-Excel = false .
            output Stream  ForExcel close.
            os-delete value( string( session:temp-directory ) +
                           "rpt" + string( g#report-num ) + ".txt":U ) .
            os-delete value( string( session:temp-directory ) +
                           "rpt" + string( g#report-num ) + ".frm":U ) .
            return.
         end.
      end.
   end.
end.
procedure CloseForExcel :
   define variable ii as integer no-undo .
   define variable vsheet-num as integer no-undo.
   if Make-Excel
   then  do:
      output Stream  ForExcel close.
      os-delete value( string( session:temp-directory ) +
                             "rpt" + string( g#report-num ) + ".txt":U ) .
      os-delete value( string( session:temp-directory ) +
                             "rpt" + string( g#report-num ) + ".frm":U ) .
      define buffer buf_sheetf for sheetf.
      find last buf_sheetf no-error .
      if available buf_sheetf
      then
         vsheet-num = buf_sheetf.sheet-num.
      if vsheet-num > 1
      then do:
         do ii = 2 to vsheet-num:
            os-delete value( string( session:temp-directory ) +
                                  "rpt" + string( g#report-num ) + ".":U  + string(ii)) .
         end.
      end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#WorkSheet) then
RELEASE OBJECT ch#WorkSheet no-error.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Workbook) then
RELEASE OBJECT ch#Workbook no-error.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#ExcelApplication) then
RELEASE OBJECT ch#ExcelApplication no-error.
   end.
end.
define temp-table tt-obj-list no-undo like ub.clients
  field is-have-assortment-matrix as logical
index pi is primary unique
  obj-type
  obj-code
index am
  is-have-assortment-matrix
.
define temp-table tt-goods no-undo like ub.goods
  field obj-type  as character
  field obj-code  as integer
index pi
  obj-type
  obj-code
  gds-code
index grp
  obj-type
  obj-code
  grp-code
.
define temp-table tt-suppliers no-undo
  field obj-type  as character
  field obj-code  as integer
  field gds-code  as integer
  field supp-type as character
  field supp-code as integer
index pi is primary unique
  obj-type
  obj-code
  gds-code
  supp-type
  supp-code
.
define temp-table tt-filtred-gds no-undo
  field obj-type  as character
  field obj-code  as integer
  field gds-code  as integer
  field supp-type as character
  field supp-code as integer
index pi is primary unique
  obj-type
  obj-code
  gds-code
  supp-type
  supp-code
.
define temp-table tt-report no-undo
  field obj-type  as character
  field obj-code  as integer
  field r-date    as date
  field gds-code  as integer
  field artic     as character
  field prod-type as character
  field prod-code as integer
  field grp-code  as integer
  field supp-type as character
  field supp-code as integer
  field cli-name  as character
  field balance   as decimal
  field sale      as decimal
  field order     as decimal
index pi is primary unique
  obj-type
  obj-code
  r-date
  gds-code
  supp-type
  supp-code
index supp
  supp-type
  supp-code
  grp-code
index rep-date
  r-date
  obj-type
  obj-code
index art
  artic
  prod-type
  prod-code
index obj-grp
  obj-type
  obj-code
  grp-code
  r-date
index flt
  obj-type
  obj-code
  gds-code
  supp-type
  supp-code
.
define stream sout.
define variable v-date-start  as date      no-undo .
define variable v-date-finish as date      no-undo .
define variable v-file-name   as character no-undo .
define variable v-date-from   as date      no-undo .
define variable v-date-to     as date      no-undo .
define variable v-archive-ok  as logical   no-undo .
define variable v-comment     as character no-undo .
define variable v-can-print   as logical   no-undo .
define stream Out-Stream.
define stream OutStr-html.
define VARIABLE p-report-id              as character               no-undo .
define variable v-file-name-rep-htm as character no-undo .
do
on error undo, return error return-value
:
  run get-report-num in parparentproc (output p-report-id).
output stream sout to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(62) .
 v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".
 if p-is-schedule = yes
  then do:
    assign
      my-handle   = parparentproc
      ReportName  = "Контроль ассортиментной матрицы":U
    .
  end.
  assign
    v-date-start  = p-Date-Start
    v-date-finish = p-Date-finish
    v-file-name   = string(session :temp-directory) + "rpt" + string( g#report-num ) + '.txt'
    v-date-from   = v-date-start
    v-date-to     = v-date-finish
  .
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
    put stream OutStr-html unformatted
        '<body>' skip
        '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
        '<thead>' skip
        .
    put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="11" STYLE="font-size: 14px;">' + string(ReportNAme) + '</TD>' skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="11" STYLE="font-size: 14px;">За период с' + string(v-date-start,"99.99.9999") + ' по ' + string(v-date-finish,"99.99.9999") + '</TD>' skip
        '</TR>'skip
    .
  run empty-tt in this-procedure .
  run fill-tt in this-procedure .
  run print-report in this-procedure .
  run empty-tt in this-procedure .
  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  define variable v-orient-page as character no-undo .
   put stream OutStr-html unformatted
                                '</tbody>' skip
                                '</table>' skip
                                '</body>' skip
                                '</html>' skip
                                .
  run prn-lib-reportviewer-report-name in this-procedure (
                                                          input parParentProc
                                                          ,input v-file-name-rep-htm
                                                          ).
end.
procedure empty-tt :
  define buffer buf_tt-obj-list     for tt-obj-list.
  define buffer buf_tt-goods        for tt-goods.
  define buffer buf_tt-report       for tt-report.
  define buffer buf_tt-filtred-gds  for tt-filtred-gds.
  define buffer buf_tt-suppliers    for tt-suppliers.
do
on error undo, return error return-value
:
  empty temp-table buf_tt-obj-list    .
  empty temp-table buf_tt-goods       .
  empty temp-table buf_tt-report      .
  empty temp-table buf_tt-filtred-gds .
  empty temp-table buf_tt-suppliers   .
end.
end procedure.
procedure fill-tt :
do
on error undo, return error return-value
:
  run fill-tt-obj in this-procedure .
  run fill-tt-gds in this-procedure .
  run fill-tt-report in this-procedure .
end.
end procedure.
procedure fill-tt-obj :
  define buffer buf_clients           for ub.clients.
  define buffer buf_tt-obj-list       for tt-obj-list.
  define buffer buf_assortment-matrix for ub.assortment-matrix.
do
on error undo, return error return-value
:
  empty temp-table buf_tt-obj-list.
  if valid-handle(p-call-handle)
  and lookup( "cb_get-objects", p-call-handle:internal-entries ) > 0
  then do:
    run cb_get-objects in p-call-handle ( input this-procedure:handle).
  end.
  for each obj-list
  :
    if p-is-schedule = yes
    then do:
      run rep/chk-ahz.p (
            input        obj-list.obj-type
          , input        obj-list.obj-code
          , input        yes
          , input        yes
          , input        yes
          , input        no
          , input        no
          , input        0
          , input        "":U
          , input-output v-date-from
          , input-output v-date-to
          , output       v-archive-ok
          , output       v-comment
          , output       v-can-print
      ) no-error .
      if error-status :error
      then do:
          undo, return error substitute( "Ошибка при вызове программы rep/chk-ahz.p. &1. &2. &3"
              , return-value
              , trim(error-status :get-message(1))
              , trim(error-status :get-message(2))
          ) .
      end.
      if v-date-from <> v-date-start
      or v-date-to   <> v-date-finish
      or v-archive-ok = no
      then do:
        assign
          v-comment    = substitute( "Выгрузка не может быть произведена. &1", v-comment )
        .
        undo, return .
      end.
    end.
    find first buf_clients no-lock
      where buf_clients.obj-type = obj-list.obj-type
        and buf_clients.obj-code = obj-list.obj-code
    no-error .
    if available buf_clients
    then do:
      find first buf_tt-obj-list
        where buf_tt-obj-list.obj-type = obj-list.obj-type
          and buf_tt-obj-list.obj-code = obj-list.obj-code
      no-error .
      if not available buf_tt-obj-list
      then do:
        find first buf_assortment-matrix no-lock
          where buf_assortment-matrix.obj-type    = obj-list.obj-type
            and buf_assortment-matrix.obj-code    = obj-list.obj-code
            and buf_assortment-matrix.asmt-status = integer ('0':U)
        no-error .
        create buf_tt-obj-list.
        buffer-copy buf_clients to buf_tt-obj-list
        assign
          buf_tt-obj-list.is-have-assortment-matrix = available buf_assortment-matrix
        .
      end.
    end.
  end.
end.
end procedure.
procedure fill-tt-gds :
  define buffer buf_goods                   for ub.goods.
  define buffer buf_assortment-matrix       for ub.assortment-matrix.
  define buffer buf_assortment-matrix-goods for ub.assortment-matrix-goods.
  define buffer buf_gds-obj                 for ub.gds-obj.
  define buffer buf_gds-obj-prop            for ub.gds-obj-prop.
  define buffer buf_tt-obj-list for tt-obj-list.
  define buffer buf_tt-goods    for tt-goods.
  define variable v-curr-grp-name               as character no-undo .
  define variable v-return-AssMin               as logical   no-undo .
  define variable v-return-igt                  as character no-undo .
  define variable v-gdop-min-stock              as decimal   no-undo .
  define variable v-grop-max-stock              as decimal   no-undo .
  define variable v-grop-level-always-presence  as decimal   no-undo .
  define variable v-grop-min-order              as decimal   no-undo .
do
on error undo, return error return-value
:
  empty temp-table buf_tt-goods.
  if p-gds-by-am = yes
  then do:
    for each buf_tt-obj-list
      where buf_tt-obj-list.is-have-assortment-matrix = yes
    :
      run waitfram-show in this-procedure ( input substitute( "Построение списка товаров по объекту &1 &2"
                                                            , buf_tt-obj-list.obj-type
                                                            , buf_tt-obj-list.obj-code
                                                            )
                                          ) .
      find first buf_assortment-matrix no-lock
        where buf_assortment-matrix.obj-type    = buf_tt-obj-list.obj-type
          and buf_assortment-matrix.obj-code    = buf_tt-obj-list.obj-code
          and buf_assortment-matrix.asmt-status = integer ('0':U)
      no-error .
      if available buf_assortment-matrix
      then do:
        for each buf_assortment-matrix-goods no-lock
          where buf_assortment-matrix-goods.asmt-id     = buf_assortment-matrix.asmt-id
            and buf_assortment-matrix-goods.db-num      = buf_assortment-matrix.db-num
            and buf_assortment-matrix-goods.asmg-status = integer ('0':U)
        :
          find first buf_gds-obj-prop
               where buf_gds-obj-prop.gds-code = buf_assortment-matrix-goods.gds-code
                 and buf_gds-obj-prop.obj-type = buf_tt-obj-list.obj-type
                 and buf_gds-obj-prop.obj-code = buf_tt-obj-list.obj-code
                 no-error.
          if available buf_gds-obj-prop then do :
              if p-igt-all   = yes or
                 p-igt-new   = yes and (buf_gds-obj-prop.gdop-igt = 'Новинка':U)   or
                 p-igt-com   = yes and (buf_gds-obj-prop.gdop-igt = 'Основная группа':U)   or
                 p-igt-spec  = yes and (buf_gds-obj-prop.gdop-igt = 'Нештатный':U)  or
                 p-igt-del   = yes and (buf_gds-obj-prop.gdop-igt = 'На вывод из ассортимента':U)   or
                 p-igt-empty = yes and (buf_gds-obj-prop.gdop-igt = 'Пусто':U)
              then do:
                  find first buf_goods no-lock
                    where buf_goods.gds-code = buf_assortment-matrix-goods.gds-code
                  no-error .
                  if available buf_goods
                  then do:
                    find first buf_tt-goods
                      where buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
                        and buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
                        and buf_tt-goods.gds-code = buf_goods.gds-code
                    no-error .
                    if not available buf_tt-goods
                    then do:
                      create buf_tt-goods.
                      buffer-copy buf_goods to buf_tt-goods
                      assign
                        buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
                        buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
                      .
                    end.
                  end.
              end.
          end.
        end.
      end.
      else do:
        for each buf_gds-obj no-lock
          where buf_gds-obj.obj-type = buf_tt-obj-list.obj-type
            and buf_gds-obj.obj-code = buf_tt-obj-list.obj-code
        , first buf_goods no-lock
            where buf_goods.artic     = buf_gds-obj.artic
              and buf_goods.prod-type = buf_gds-obj.prod-type
              and buf_goods.prod-code = buf_gds-obj.prod-code
        :
          find first buf_tt-goods
            where buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
              and buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
              and buf_tt-goods.gds-code = buf_goods.gds-code
          no-error .
          if not available buf_tt-goods
          then do:
            create buf_tt-goods.
            buffer-copy buf_goods to buf_tt-goods
            assign
              buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
              buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
            .
          end.
        end.
      end.
    end.
    find first buf_tt-obj-list
      where buf_tt-obj-list.is-have-assortment-matrix = no
    no-error .
    if available buf_tt-obj-list
    then do:
      run waitfram-show in this-procedure ( input "Построение списка товаров по объектам не имеющим АМ...":U ) .
      for each buf_gds-obj no-lock
        where buf_gds-obj.obj-type = buf_tt-obj-list.obj-type
          and buf_gds-obj.obj-code = buf_tt-obj-list.obj-code
      , first buf_goods no-lock
          where buf_goods.artic     = buf_gds-obj.artic
            and buf_goods.prod-type = buf_gds-obj.prod-type
            and buf_goods.prod-code = buf_gds-obj.prod-code
      :
        for each buf_tt-obj-list
            where buf_tt-obj-list.is-have-assortment-matrix = no
        :
          find first buf_tt-goods
            where buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
              and buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
              and buf_tt-goods.gds-code = buf_goods.gds-code
          no-error .
          if not available buf_tt-goods
          then do:
            create buf_tt-goods.
            buffer-copy buf_goods to buf_tt-goods
            assign
              buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
              buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
            .
          end.
        end.
      end.
    end.
  end.
  else do:
    run waitfram-show in this-procedure ( input "Построение списков товаров по объектам...":u ) .
    case x-SelectGood
    :
      when 1
      then do:
        for each buf_tt-obj-list
        , each buf_gds-obj no-lock
            where buf_gds-obj.obj-type  = buf_tt-obj-list.obj-type
              and buf_gds-obj.obj-code  = buf_tt-obj-list.obj-code
        , first buf_goods no-lock
            where buf_goods.gds-code = buf_gds-obj.gds-code
        :
          find first buf_tt-goods
            where buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
              and buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
              and buf_tt-goods.gds-code = buf_goods.gds-code
          no-error .
          if not available buf_tt-goods
          then do:
            create buf_tt-goods.
            buffer-copy buf_goods to buf_tt-goods
            assign
              buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
              buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
            .
          end.
        end.
      end.
      when 2
      then do:
        for each tmp#grp no-lock
        :
          run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output v-curr-grp-name ) .
          for each buf_goods no-lock
            where buf_goods.grp-name begins v-curr-grp-name
          :
            for each buf_tt-obj-list
            , first buf_gds-obj no-lock
                where buf_gds-obj.obj-type  = buf_tt-obj-list.obj-type
                  and buf_gds-obj.obj-code  = buf_tt-obj-list.obj-code
                  and buf_gds-obj.artic     = buf_goods.artic
                  and buf_gds-obj.prod-type = buf_goods.prod-type
                  and buf_gds-obj.prod-code = buf_goods.prod-code
            :
              find first buf_tt-goods
                where buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
                  and buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
                  and buf_tt-goods.gds-code = buf_goods.gds-code
              no-error .
              if not available buf_tt-goods
              then do:
                create buf_tt-goods.
                buffer-copy buf_goods to buf_tt-goods
                assign
                  buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
                  buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
                .
              end.
            end.
          end.
        end.
      end.
      when 3
      then do:
        for each g#cli
        :
          for each buf_goods no-lock
            where buf_goods.prod-type = g#cli.obj-type
              and buf_goods.prod-code = g#cli.obj-code
          :
            for each buf_tt-obj-list
            , first buf_gds-obj no-lock
                where buf_gds-obj.obj-type  = buf_tt-obj-list.obj-type
                  and buf_gds-obj.obj-code  = buf_tt-obj-list.obj-code
                  and buf_gds-obj.artic     = buf_goods.artic
                  and buf_gds-obj.prod-type = buf_goods.prod-type
                  and buf_gds-obj.prod-code = buf_goods.prod-code
            :
              find first buf_tt-goods
                where buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
                  and buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
                  and buf_tt-goods.gds-code = buf_goods.gds-code
              no-error .
              if not available buf_tt-goods
              then do:
                create buf_tt-goods.
                buffer-copy buf_goods to buf_tt-goods
                assign
                  buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
                  buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
                .
              end.
            end.
          end.
        end.
      end.
      when 4 or
      when 5 or
      when 7
      then do:
        for each gds-list
        :
          for each buf_tt-obj-list
          , first buf_gds-obj no-lock
              where buf_gds-obj.obj-type  = buf_tt-obj-list.obj-type
                and buf_gds-obj.obj-code  = buf_tt-obj-list.obj-code
                and buf_gds-obj.artic     = gds-list.artic
                and buf_gds-obj.prod-type = gds-list.prod-type
                and buf_gds-obj.prod-code = gds-list.prod-code
          , first buf_goods no-lock
              where buf_goods.gds-code = buf_gds-obj.gds-code
          :
            find first buf_tt-goods
              where buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
                and buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
                and buf_tt-goods.gds-code = buf_goods.gds-code
            no-error .
            if not available buf_tt-goods
            then do:
              create buf_tt-goods.
              buffer-copy buf_goods to buf_tt-goods
              assign
                buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
                buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
              .
            end.
          end.
        end.
      end.
    end case.
  end.
  run waitfram-hide in this-procedure .
  for each buf_tt-obj-list
  :
    find first buf_tt-goods
      where buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
        and buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
    no-error .
    if not available buf_tt-goods
    then do:
      run proc-message in this-procedure ( input substitute( "Список товаров по объекту &1 &2 пуст. Объект исключен."
                                                           , buf_tt-obj-list.obj-type
                                                           , buf_tt-obj-list.obj-code
                                                           )
                                         ) .
      delete buf_tt-obj-list.
    end.
  end.
  find first buf_tt-goods no-error .
  if not available buf_tt-goods
  then do:
    run proc-message in this-procedure ( input "Список товаров по объектам пуст. Отчет не может быть составлен." ) .
    return .
  end.
end.
end procedure.
procedure fill-tt-report-no-supp :
  define buffer buf_ot-line     for ub.ot-line.
  define buffer buf_ord-doc     for ub.ord-doc.
  define buffer buf_ord-line    for ub.ord-line.
  define buffer buf_tt-obj-list for tt-obj-list.
  define buffer buf_tt-goods    for tt-goods.
  define buffer buf_tt-report   for tt-report.
  define variable v-day-begin-factord as decimal   no-undo .
  define variable v-day-end-factord   as decimal   no-undo .
  define variable v-quantity          as decimal   no-undo .
  define variable v-coast_r           as decimal   no-undo .
  define variable v-coast_v           as decimal   no-undo .
  define variable v-vat_r             as decimal   no-undo .
  define variable v-vat_v             as decimal   no-undo .
  define variable v-slt_r             as decimal   no-undo .
  define variable v-slt_v             as decimal   no-undo .
  define variable v-sale              as decimal   no-undo .
  define variable v-order             as decimal   no-undo .
  define variable v-tmp-date          as date      no-undo .
do
on error undo, return error return-value
:
  for each buf_tt-report
    break by buf_tt-report.r-date
          by buf_tt-report.obj-type
          by buf_tt-report.obj-code
  :
    if first-of(buf_tt-report.r-date)
    then do:
      run day-begin-fact-order  in this-procedure ( input buf_tt-report.r-date
                                                  , output v-day-begin-factord
                                                  ) .
      run factord-end-day in this-procedure ( input buf_tt-report.r-date
                                            , output v-day-end-factord
                                            ) .
    end.
    if first-of(buf_tt-report.r-date) or first-of(buf_tt-report.obj-type) or first-of(buf_tt-report.obj-code)
    then do:
      run waitfram-show in this-procedure ( input substitute( "Расчет остатков и продаж на дату &1 для &2 &3..."
                                                            , string(buf_tt-report.r-date ,  "99/99/9999")
                                                            , buf_tt-report.obj-type
                                                            , buf_tt-report.obj-code
                                                            )
                                          ) .
    end.
    run ost-line in this-procedure ( input  buf_tt-report.obj-code
                                   , input  buf_tt-report.obj-type
                                   , input  buf_tt-report.artic
                                   , input  buf_tt-report.prod-code
                                   , input  buf_tt-report.prod-type
                                   , input  no
                                   , input  v-day-end-factord
                                   , input  'cost':U
                                   , input  '##,##':U
                                   , input  yes
                                   , output v-quantity
                                   , output v-coast_r
                                   , output v-coast_v
                                   , output v-vat_r
                                   , output v-vat_v
                                   , output v-slt_r
                                   , output v-slt_v
                                   ) .
    _ot-line:
    for each buf_ot-line no-lock
        where buf_ot-line.obj-type     = buf_tt-report.obj-type
          and buf_ot-line.obj-code     = buf_tt-report.obj-code
          and buf_ot-line.artic        = buf_tt-report.artic
          and buf_ot-line.prod-type    = buf_tt-report.prod-type
          and buf_ot-line.prod-code    = buf_tt-report.prod-code
          and buf_ot-line.fact-order  >= v-day-begin-factord
          and buf_ot-line.fact-order  <= v-day-end-factord
          and buf_ot-line.sum-type     = 'cost':U
    :
      if buf_ot-line.ext-doc-type = 'es':U
      then do:
        assign
          v-sale = v-sale + abs(buf_ot-line.fact-qnty)
        .
      end.
    end.
    assign
      buf_tt-report.balance = v-quantity
      buf_tt-report.sale    = v-sale
      v-sale                = 0
    .
  end.
  for each buf_tt-obj-list
  :
    assign
      v-tmp-date = p-date-start
    .
    do while v-tmp-date <= p-date-finish
    :
      run waitfram-show in this-procedure ( input substitute( "Расчет заказов на дату &1 для &2 &3..."
                                                            , string(v-tmp-date ,  "99/99/9999")
                                                            , buf_tt-obj-list.obj-type
                                                            , buf_tt-obj-list.obj-code
                                                            )
                                          ) .
      for each buf_ord-doc no-lock
        where buf_ord-doc.obj-type = buf_tt-obj-list.obj-type
          and buf_ord-doc.obj-code = buf_tt-obj-list.obj-code
          and buf_ord-doc.doc-date = v-tmp-date
      :
        if buf_ord-doc.status_ = 'поставка':U or
           buf_ord-doc.status_ = 'факт':U
        then do:
          for each buf_ord-line no-lock
            where buf_ord-line.doc-code   = buf_ord-doc.doc-code
          , first buf_tt-goods
              where buf_tt-goods.obj-type   = buf_tt-obj-list.obj-type
                and buf_tt-goods.obj-code   = buf_tt-obj-list.obj-code
                and buf_tt-goods.artic      = buf_ord-line.artic
                and buf_tt-goods.prod-type  = buf_ord-line.prod-type
                and buf_tt-goods.prod-code  = buf_ord-line.prod-code
          :
            find first buf_tt-report no-lock
              where buf_tt-report.obj-type  = buf_tt-obj-list.obj-type
                and buf_tt-report.obj-code  = buf_tt-obj-list.obj-code
                and buf_tt-report.r-date    = v-tmp-date
                and buf_tt-report.gds-code  = buf_tt-goods.gds-code
            no-error .
            if available buf_tt-report
            then do:
              assign
                buf_tt-report.order = buf_tt-report.order + buf_ord-line.qnty
              .
            end.
          end.
        end.
      end.
      assign
        v-tmp-date = v-tmp-date + 1
      .
    end.
  end.
  run waitfram-hide in this-procedure .
end.
end procedure.
procedure fill-tt-report-supp :
  define buffer buf_tt-obj-list   for tt-obj-list.
  define buffer buf_tt-goods      for tt-goods.
  define buffer buf_tt-report     for tt-report.
  define buffer buf_tt-suppliers  for tt-suppliers.
  define buffer buf_goods         for ub.goods.
  define buffer buf_parts         for ub.parts.
  define buffer buf_ot-supp-line  for ub.ot-supp-line.
  define buffer buf_stk-supp-line for ub.stk-supp-line.
  define buffer buf_trn-doc       for ub.trn-doc.
  define buffer buf_doc-line      for ub.doc-line.
  define buffer buf_ord-doc       for ub.ord-doc.
  define buffer buf_ord-line      for ub.ord-line.
  define buffer buf_cli-gds       for ub.cli-gds.
  define variable v-day-begin-factord as decimal   no-undo .
  define variable v-day-end-factord   as decimal   no-undo .
  define variable v-begin-factord     as decimal   no-undo .
  define variable v-end-factord       as decimal   no-undo .
  define variable v-tmp-date          as date      no-undo .
  define variable v-qnty              as decimal   no-undo .
  define variable v-sale              as decimal   no-undo .
  define variable v-host-code         as integer   no-undo .
  define variable v-supp-type         as character no-undo .
  define variable v-supp-code         as integer   no-undo .
do
on error undo, return error return-value
:
  empty temp-table buf_tt-suppliers.
  run day-begin-fact-order  in this-procedure ( input p-date-start
                                              , output v-begin-factord
                                              ) .
  run factord-end-day in this-procedure ( input p-date-finish
                                        , output v-end-factord
                                        ) .
  run waitfram-show in this-procedure ( input "Сбор данных по поставщикам...":u ) .
  for each buf_tt-obj-list
  :
    for each buf_tt-goods
      where buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
        and buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
    :
      for each buf_stk-supp-line no-lock
        where buf_stk-supp-line.prod-type   = buf_tt-goods.prod-type
          and buf_stk-supp-line.prod-code   = buf_tt-goods.prod-code
          and buf_stk-supp-line.artic       = buf_tt-goods.artic
          and buf_stk-supp-line.obj-type    = buf_tt-goods.obj-type
          and buf_stk-supp-line.obj-code    = buf_tt-goods.obj-code
          and buf_stk-supp-line.fact-order >= v-begin-factord
          and buf_stk-supp-line.fact-order <= v-end-factord
          and buf_stk-supp-line.sum-type    = 'cost':U
          and buf_stk-supp-line.cat-id      = '##':U
      :
        find first buf_tt-suppliers
          where buf_tt-suppliers.obj-type  = buf_stk-supp-line.obj-type
            and buf_tt-suppliers.obj-code  = buf_stk-supp-line.obj-code
            and buf_tt-suppliers.gds-code  = buf_tt-goods.gds-code
            and buf_tt-suppliers.supp-type = buf_stk-supp-line.cli-type
            and buf_tt-suppliers.supp-code = buf_stk-supp-line.cli-code
        no-error .
        if not available buf_tt-suppliers
        then do:
          create buf_tt-suppliers.
          assign
            buf_tt-suppliers.obj-type  = buf_stk-supp-line.obj-type
            buf_tt-suppliers.obj-code  = buf_stk-supp-line.obj-code
            buf_tt-suppliers.gds-code  = buf_tt-goods.gds-code
            buf_tt-suppliers.supp-type = buf_stk-supp-line.cli-type
            buf_tt-suppliers.supp-code = buf_stk-supp-line.cli-code
          .
        end.
      end.
    end.
    for each buf_trn-doc no-lock
      where buf_trn-doc.obj-type    = buf_tt-goods.obj-type
        and buf_trn-doc.obj-code    = buf_tt-goods.obj-code
        and buf_trn-doc.status_     = 'факт':U
        and buf_trn-doc.fact-order >= v-begin-factord
        and buf_trn-doc.fact-order <= v-end-factord
    :
      if buf_trn-doc.ext-doc-type = 'es':U
      then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code   = buf_trn-doc.doc-code
        , first buf_tt-goods
            where buf_tt-goods.obj-type   = buf_tt-obj-list.obj-type
              and buf_tt-goods.obj-code   = buf_tt-obj-list.obj-code
              and buf_tt-goods.artic      = buf_doc-line.artic
              and buf_tt-goods.prod-type  = buf_doc-line.prod-type
              and buf_tt-goods.prod-code  = buf_doc-line.prod-code
        :
          find first buf_tt-suppliers
            where buf_tt-suppliers.obj-type  = buf_tt-goods.obj-type
              and buf_tt-suppliers.obj-code  = buf_tt-goods.obj-code
              and buf_tt-suppliers.gds-code  = buf_tt-goods.gds-code
              and buf_tt-suppliers.supp-type = buf_trn-doc.cli-type
              and buf_tt-suppliers.supp-code = buf_trn-doc.cli-code
          no-error .
          if not available buf_tt-suppliers
          then do:
            create buf_tt-suppliers.
            assign
              buf_tt-suppliers.obj-type  = buf_tt-goods.obj-type
              buf_tt-suppliers.obj-code  = buf_tt-goods.obj-code
              buf_tt-suppliers.gds-code  = buf_tt-goods.gds-code
              buf_tt-suppliers.supp-type = buf_trn-doc.cli-type
              buf_tt-suppliers.supp-code = buf_trn-doc.cli-code
            .
          end.
        end.
      end.
    end.
    assign
      v-tmp-date = p-date-start
    .
    do while v-tmp-date <= p-date-finish
    :
      for each buf_ord-doc no-lock
        where buf_ord-doc.obj-type = buf_tt-obj-list.obj-type
          and buf_ord-doc.obj-code = buf_tt-obj-list.obj-code
          and buf_ord-doc.doc-date = v-tmp-date
      :
        if buf_ord-doc.status_ = 'поставка':U or
           buf_ord-doc.status_ = 'факт':U
        then do:
          for each buf_ord-line no-lock
            where buf_ord-line.doc-code   = buf_ord-doc.doc-code
          , first buf_tt-goods
              where buf_tt-goods.obj-type   = buf_tt-obj-list.obj-type
                and buf_tt-goods.obj-code   = buf_tt-obj-list.obj-code
                and buf_tt-goods.artic      = buf_ord-line.artic
                and buf_tt-goods.prod-type  = buf_ord-line.prod-type
                and buf_tt-goods.prod-code  = buf_ord-line.prod-code
          :
            find first buf_tt-suppliers
              where buf_tt-suppliers.obj-type  = buf_tt-goods.obj-type
                and buf_tt-suppliers.obj-code  = buf_tt-goods.obj-code
                and buf_tt-suppliers.gds-code  = buf_tt-goods.gds-code
                and buf_tt-suppliers.supp-type = buf_ord-doc.cli-type
                and buf_tt-suppliers.supp-code = buf_ord-doc.cli-code
            no-error .
            if not available buf_tt-suppliers
            then do:
              create buf_tt-suppliers.
              assign
                buf_tt-suppliers.obj-type  = buf_tt-goods.obj-type
                buf_tt-suppliers.obj-code  = buf_tt-goods.obj-code
                buf_tt-suppliers.gds-code  = buf_tt-goods.gds-code
                buf_tt-suppliers.supp-type = buf_ord-doc.cli-type
                buf_tt-suppliers.supp-code = buf_ord-doc.cli-code
              .
            end.
          end.
        end.
      end.
      assign
        v-tmp-date = v-tmp-date + 1
      .
    end.
  end.
  empty temp-table buf_tt-report.
  run waitfram-show in this-procedure ( input "Инициализация...":u ) .
  for each buf_tt-suppliers
  , first buf_tt-goods
      where buf_tt-goods.obj-type = buf_tt-suppliers.obj-type
        and buf_tt-goods.obj-code = buf_tt-suppliers.obj-code
        and buf_tt-goods.gds-code = buf_tt-suppliers.gds-code
  :
    assign
      v-tmp-date = p-date-start
    .
    do while v-tmp-date <= p-date-finish
    :
      create buf_tt-report.
      assign
        buf_tt-report.obj-type  = buf_tt-suppliers.obj-type
        buf_tt-report.obj-code  = buf_tt-suppliers.obj-code
        buf_tt-report.gds-code  = buf_tt-suppliers.gds-code
        buf_tt-report.artic     = buf_tt-goods.artic
        buf_tt-report.prod-type = buf_tt-goods.prod-type
        buf_tt-report.prod-code = buf_tt-goods.prod-code
        buf_tt-report.grp-code  = buf_tt-goods.grp-code
        buf_tt-report.r-date    = v-tmp-date
        buf_tt-report.supp-type = buf_tt-suppliers.supp-type
        buf_tt-report.supp-code = buf_tt-suppliers.supp-code
        v-tmp-date              = v-tmp-date + 1
      .
    end.
  end.
  for each buf_tt-goods
  :
    find first buf_tt-suppliers
      where buf_tt-suppliers.obj-type = buf_tt-goods.obj-type
        and buf_tt-suppliers.obj-code = buf_tt-goods.obj-code
        and buf_tt-suppliers.gds-code = buf_tt-goods.gds-code
    no-error .
    if not available buf_tt-suppliers
    then do:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_tt-goods.obj-type
  ,input  buf_tt-goods.obj-code
  ,output v-host-code
  )  .
      find first buf_cli-gds no-lock
        where buf_cli-gds.host-code = v-host-code
          and buf_cli-gds.artic     = buf_tt-goods.artic
          and buf_cli-gds.prod-type = buf_tt-goods.prod-type
          and buf_cli-gds.prod-code = buf_tt-goods.prod-code
      no-error .
      if available buf_cli-gds
      then do:
        assign
          v-supp-type = buf_cli-gds.cli-type
          v-supp-code = buf_cli-gds.cli-code
        .
      end.
      else do:
        assign
          v-supp-type = ""
          v-supp-code = 0
        .
      end.
      assign
        v-tmp-date = p-date-start
      .
      do while v-tmp-date <= p-date-finish
      :
        create buf_tt-report.
        assign
          buf_tt-report.obj-type  = buf_tt-goods.obj-type
          buf_tt-report.obj-code  = buf_tt-goods.obj-code
          buf_tt-report.gds-code  = buf_tt-goods.gds-code
          buf_tt-report.artic     = buf_tt-goods.artic
          buf_tt-report.prod-type = buf_tt-goods.prod-type
          buf_tt-report.prod-code = buf_tt-goods.prod-code
          buf_tt-report.grp-code  = buf_tt-goods.grp-code
          buf_tt-report.r-date    = v-tmp-date
          buf_tt-report.supp-type = v-supp-type
          buf_tt-report.supp-code = v-supp-code
          v-tmp-date              = v-tmp-date + 1
        .
      end.
    end.
  end.
  for each buf_tt-report
    break by buf_tt-report.r-date
          by buf_tt-report.obj-type
          by buf_tt-report.obj-code
          by buf_tt-report.gds-code
  :
    if first-of(buf_tt-report.r-date)
    then do:
      run day-begin-fact-order  in this-procedure ( input buf_tt-report.r-date
                                                  , output v-day-begin-factord
                                                  ) .
      run factord-end-day in this-procedure ( input buf_tt-report.r-date
                                            , output v-day-end-factord
                                            ) .
    end.
    if first-of(buf_tt-report.r-date) or first-of(buf_tt-report.obj-type) or first-of(buf_tt-report.obj-code)
    then do:
      run waitfram-show in this-procedure ( input substitute( "Расчет остатков и продаж на дату &1 для &2 &3..."
                                                            , string(buf_tt-report.r-date ,  "99/99/9999")
                                                            , buf_tt-report.obj-type
                                                            , buf_tt-report.obj-code
                                                            )
                                          ) .
    end.
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type    = buf_tt-report.obj-type
        and buf_stk-supp-line.obj-code    = buf_tt-report.obj-code
        and buf_stk-supp-line.cli-type    = buf_tt-report.supp-type
        and buf_stk-supp-line.cli-code    = buf_tt-report.supp-code
        and buf_stk-supp-line.artic       = buf_tt-report.artic
        and buf_stk-supp-line.prod-type   = buf_tt-report.prod-type
        and buf_stk-supp-line.prod-code   = buf_tt-report.prod-code
        and buf_stk-supp-line.fact-order <= v-day-end-factord
        and buf_stk-supp-line.sum-type    = 'cost':U
        and buf_stk-supp-line.cat-id      = '##':U
    use-index category
    no-error .
    assign
      buf_tt-report.balance = if available buf_stk-supp-line then buf_stk-supp-line.fact-qnty else 0
      v-sale                = 0
    .
    for each buf_ot-supp-line
      where buf_ot-supp-line.obj-type     = buf_tt-report.obj-type
        and buf_ot-supp-line.obj-code     = buf_tt-report.obj-code
        and buf_ot-supp-line.cli-type     = buf_tt-report.supp-type
        and buf_ot-supp-line.cli-code     = buf_tt-report.supp-code
        and buf_ot-supp-line.artic        = buf_tt-report.artic
        and buf_ot-supp-line.prod-type    = buf_tt-report.prod-type
        and buf_ot-supp-line.prod-code    = buf_tt-report.prod-code
        and buf_ot-supp-line.fact-order  >= v-day-begin-factord
        and buf_ot-supp-line.fact-order  <= v-day-end-factord
        and buf_ot-supp-line.sum-type     = 'cost':U
        and buf_ot-supp-line.cat-id       = '##':U
    :
      if buf_ot-supp-line.ext-doc-type = 'es':U
      then do:
        assign
          v-sale = v-sale + abs(buf_ot-supp-line.fact-qnty)
        .
      end.
    end.
    assign
      buf_tt-report.sale = v-sale
    .
  end.
  for each buf_tt-obj-list
  :
    assign
      v-tmp-date = p-date-start
    .
    do while v-tmp-date <= p-date-finish
    :
      run waitfram-show in this-procedure ( input substitute( "Расчет заказов на дату &1 для &2 &3..."
                                                            , string(v-tmp-date ,  "99/99/9999")
                                                            , buf_tt-obj-list.obj-type
                                                            , buf_tt-obj-list.obj-code
                                                            )
                                          ) .
      for each buf_ord-doc no-lock
        where buf_ord-doc.obj-type = buf_tt-obj-list.obj-type
          and buf_ord-doc.obj-code = buf_tt-obj-list.obj-code
          and buf_ord-doc.doc-date = v-tmp-date
      :
        if buf_ord-doc.status_ = 'поставка':U or
           buf_ord-doc.status_ = 'факт':U
        then do:
          for each buf_ord-line no-lock
            where buf_ord-line.doc-code   = buf_ord-doc.doc-code
          , first buf_tt-goods
              where buf_tt-goods.obj-type   = buf_tt-obj-list.obj-type
                and buf_tt-goods.obj-code   = buf_tt-obj-list.obj-code
                and buf_tt-goods.artic      = buf_ord-line.artic
                and buf_tt-goods.prod-type  = buf_ord-line.prod-type
                and buf_tt-goods.prod-code  = buf_ord-line.prod-code
          :
            find first buf_tt-report
              where buf_tt-report.obj-type  = buf_tt-obj-list.obj-type
                and buf_tt-report.obj-code  = buf_tt-obj-list.obj-code
                and buf_tt-report.r-date    = v-tmp-date
                and buf_tt-report.gds-code  = buf_tt-goods.gds-code
                and buf_tt-report.supp-type = buf_ord-doc.cli-type
                and buf_tt-report.supp-code = buf_ord-doc.cli-code
            no-error .
            if available buf_tt-report
            then do:
              assign
                buf_tt-report.order = buf_tt-report.order + buf_ord-line.qnty
              .
            end.
          end.
        end.
      end.
      assign
        v-tmp-date = v-tmp-date + 1
      .
    end.
  end.
  run waitfram-hide in this-procedure .
end.
end procedure.
procedure fill-tt-report :
do
on error undo, return error return-value
:
  run initialize-tt-report in this-procedure .
  if p-group-by-post = yes
  then do:
    run fill-tt-report-supp in this-procedure .
  end.
  else do:
    run fill-tt-report-no-supp in this-procedure .
  end.
end.
end procedure.
procedure initialize-tt-report :
  define buffer buf_tt-report   for tt-report.
  define buffer buf_tt-obj-list for tt-obj-list.
  define buffer buf_tt-goods    for tt-goods.
  define buffer buf_clients     for ub.clients.
  define variable v-tmp-date  as date      no-undo .
  define variable v-i         as integer   no-undo .
do
on error undo, return error return-value
:
  empty temp-table buf_tt-report.
  if p-group-by-post = yes
  then do:
    return .
  end.
  else do:
    run waitfram-show in this-procedure ( input "Инициализация...":u ) .
    for each buf_tt-goods
    :
      assign
        v-tmp-date = p-date-start
        v-i        = v-i + 1
      .
      do while v-tmp-date <= p-date-finish
      :
        create buf_tt-report.
        assign
          buf_tt-report.obj-type  = buf_tt-goods.obj-type
          buf_tt-report.obj-code  = buf_tt-goods.obj-code
          buf_tt-report.gds-code  = buf_tt-goods.gds-code
          buf_tt-report.artic     = buf_tt-goods.artic
          buf_tt-report.prod-type = buf_tt-goods.prod-type
          buf_tt-report.prod-code = buf_tt-goods.prod-code
          buf_tt-report.grp-code  = buf_tt-goods.grp-code
          buf_tt-report.r-date    = v-tmp-date
          v-tmp-date              = v-tmp-date + 1
        .
      end.
    end.
  end.
  run waitfram-hide in this-procedure .
end.
end procedure.
procedure filter-tt-report :
  define buffer buf_tt-obj-list     for tt-obj-list.
  define buffer buf_tt-report       for tt-report.
  define buffer buf_tt-goods        for tt-goods.
  define buffer buf_tt-filtred-gds  for tt-filtred-gds.
  define variable v-days-wt-goods as integer   no-undo .
do
on error undo, return error return-value
:
  if p-days-wt-goods = 0
  then do:
    return .
  end.
  for each buf_tt-obj-list
  :
    run waitfram-show in this-procedure ( input substitute( "Фильтрация результатов по &1 &2...":u
                                                          , buf_tt-obj-list.obj-type
                                                          , buf_tt-obj-list.obj-code
                                                          )
                                        ) .
    for each buf_tt-report
      where buf_tt-report.obj-type = buf_tt-obj-list.obj-type
        and buf_tt-report.obj-code = buf_tt-obj-list.obj-code
    break by buf_tt-report.gds-code
    :
      if buf_tt-report.balance <= p-critical-qnty-balance
      then do:
        assign
          v-days-wt-goods = v-days-wt-goods + 1
        .
      end.
      if last-of( buf_tt-report.gds-code )
      then do:
        if v-days-wt-goods < p-days-wt-goods
        then do:
          create buf_tt-filtred-gds.
          assign
            buf_tt-filtred-gds.obj-type   = buf_tt-report.obj-type
            buf_tt-filtred-gds.obj-code   = buf_tt-report.obj-code
            buf_tt-filtred-gds.gds-code   = buf_tt-report.gds-code
            buf_tt-filtred-gds.supp-type  = buf_tt-report.supp-type
            buf_tt-filtred-gds.supp-code  = buf_tt-report.supp-code
          .
        end.
        assign
          v-days-wt-goods = 0
        .
      end.
    end.
  end.
  run waitfram-show in this-procedure ( input substitute( "Исключение отфильтрованых товаров...":u ) ) .
  for each buf_tt-filtred-gds
  :
    find first buf_tt-goods
      where buf_tt-goods.obj-type  = buf_tt-filtred-gds.obj-type
        and buf_tt-goods.obj-code  = buf_tt-filtred-gds.obj-code
        and buf_tt-goods.gds-code  = buf_tt-filtred-gds.gds-code
    no-error.
    if available buf_tt-goods
    then do:
      delete buf_tt-goods.
    end.
    for each buf_tt-report
      where buf_tt-report.obj-type  = buf_tt-filtred-gds.obj-type
        and buf_tt-report.obj-code  = buf_tt-filtred-gds.obj-code
        and buf_tt-report.gds-code  = buf_tt-filtred-gds.gds-code
        and buf_tt-report.supp-type = buf_tt-filtred-gds.supp-type
        and buf_tt-report.supp-code = buf_tt-filtred-gds.supp-code
    :
      delete buf_tt-report.
    end.
  end.
  empty temp-table buf_tt-filtred-gds.
  run waitfram-hide in this-procedure .
end.
end procedure.
procedure print-report :
do
on error undo, return error return-value
:
  run filter-tt-report in this-procedure .
  run print-no-schedule in this-procedure .
end.
end procedure.
procedure print-no-schedule :
do
on error undo, return error return-value
:
  if p-group-by-post = yes
  then do:
    run print-no-schedule-supp in this-procedure .
  end.
  else do:
    run print-no-schedule-no-supp in this-procedure .
  end.
end.
end procedure.
procedure print-no-schedule-no-supp :
  define buffer buf_tt-obj-list   for tt-obj-list.
  define buffer buf_tt-report     for tt-report.
  define buffer buf_tt-report-day for tt-report.
  define buffer buf_tt-goods      for tt-goods.
  define variable v-i               as integer   no-undo .
  define variable ii                as integer   no-undo .
  define variable v-line-1          as character no-undo .
  define variable v-clmn-label-1    as character no-undo .
  define variable v-clmn-label-2    as character no-undo .
  define variable v-clmn-format     as character no-undo .
  define variable v-clmn-sizes      as character no-undo .
  define variable v-tmp-date        as date      no-undo .
  define variable v-days-count      as integer   no-undo .
  define variable v-list-num        as integer   no-undo .
  define variable v-grp-tot-balance as decimal   no-undo .
  define variable v-grp-tot-sale    as decimal   no-undo .
  define variable v-grp-tot-order   as decimal   no-undo .
  define variable v-grp-balance     as decimal   no-undo .
  define variable v-grp-sale        as decimal   no-undo .
  define variable v-grp-order       as decimal   no-undo .
  define variable v-grp-prc-balance as decimal   no-undo .
  define variable v-grp-prc-sale    as decimal   no-undo .
  define variable v-grp-prc-order   as decimal   no-undo .
  define variable v-gds-prc-balance as decimal   no-undo .
  define variable v-gds-prc-sale    as decimal   no-undo .
  define variable v-gds-prc-order   as decimal   no-undo .
  define variable v-num-days-wo-balance     as decimal   no-undo .
  define variable v-num-days-wo-sale        as decimal   no-undo .
  define variable v-num-days-wo-order       as decimal   no-undo .
  define variable v-gds-grp-count           as decimal   no-undo .
  define variable v-gds-grp-tot-count       as decimal   no-undo .
  define variable v-gds-tot-count           as decimal   no-undo .
  define variable v-gds-asm-count           as decimal   no-undo .
  define variable v-balance                 as decimal   no-undo .
  define variable v-balance-last            as decimal   no-undo .
  define variable v-sum-sale                as decimal   no-undo .
  define variable v-gds-asm-tot-count       as decimal   no-undo .
  define variable v-tot-num-days-wo-balance as decimal   no-undo .
  define variable v-tot-num-days-wo-sale    as decimal   no-undo .
  define variable v-tot-num-days-wo-order   as decimal   no-undo .
  define variable v-tot-asm-gds-count       as decimal   no-undo .
  define variable v-tot-balance             as decimal   no-undo .
  define variable v-tot-sale                as decimal   no-undo .
  define variable v-tot-order               as decimal   no-undo .
  define variable v-tot-asm-balance         as decimal   no-undo .
  define variable v-tot-asm-sale            as decimal   no-undo .
  define variable v-tot-asm-order           as decimal   no-undo .
  define variable v-grp-start-line          as integer   no-undo .
  define variable v-grp-end-line            as integer   no-undo .
  define variable v-grp-list                as character no-undo .
  define variable jj                        as integer   no-undo .
  define VARIABLE v-jj                      as integer   no-undo .
  DEFINE VARIABLE v-first                   as LOGICAL   NO-UNDO .
  DEFINE VARIABLE v-last                    as LOGICAL   NO-UNDO .
do
on error undo, return error return-value
:
  assign
    v-days-count = p-date-finish - p-date-start + 1
  .
  for each buf_tt-obj-list
  :
    run waitfram-show in this-procedure ( input substitute( "Расчет итогов по объекту &1 &2...":U
                                                          , buf_tt-obj-list.obj-type
                                                          , buf_tt-obj-list.obj-code
                                                          )
                                        ) .
    assign
      v-tmp-date      = p-date-start
      v-i             = 3
      v-list-num      = v-list-num + 1
      v-clmn-label-1  = '':u
      v-clmn-label-2  = '':u
      v-clmn-format   = '':u
      v-clmn-sizes    = '':u
      v-line-1        = '':u
    .
    if p-gds-by-am = yes
    then do:
      assign
        v-gds-tot-count = 0
        v-i             = 0
      .
      for each buf_tt-goods
        where buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
          and buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
      :
        assign
          v-i = v-i + 1
        .
      end.
      put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="11" STYLE="font-size: 14px;">' + string(substitute("По АМ на &1 товаров":U , v-i )) + '</TD>' skip
        '</TR>'skip
    .
    end.
    if p-group-by-post = yes
    then do:
      put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="11" STYLE="font-size: 14px;">Группировка по поставщику</TD>' skip
        '</TR>'skip
    .
    end.
   put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="11" STYLE="font-size: 14px;">' + string(substitute( "Критический остаток: &1" , p-critical-qnty-balance )) + '</TD>' skip
        '</TR>'skip
    .
     put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="11" STYLE="font-size: 14px;">' + string(substitute( "Критическая продажа: &1" , p-critical-qnty-sale    )) + '</TD>' skip
        '</TR>'skip
    .
     put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="11" STYLE="font-size: 14px;">' + string(substitute( "Критический заказ: &1"   , p-critical-qnty-order   )) + '</TD>' skip
        '</TR>'skip
    .
     put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="11" STYLE="font-size: 14px;">' + string(substitute( "Фильтры:"                                          )) + '</TD>' skip
        '</TR>'skip
    .
     put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="11" STYLE="font-size: 14px;">' + string(substitute( "Дней без товара: &1"     , p-days-wt-goods         )) + '</TD>' skip
        '</TR>'skip
    .
      put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="11" STYLE="font-size: 14px;">Показывать товары с ИЖТ:' + string(( if p-igt-all   = yes then 'все':U else
      ( if p-igt-new   = yes then 'Новинка':U   + "," else "" ) +
      ( if p-igt-com   = yes then 'Основная группа':U   + "," else "" ) +
      ( if p-igt-spec  = yes then 'Нештатный':U  + "," else "" ) +
      ( if p-igt-del   = yes then 'На вывод из ассортимента':U   + "," else "" ) +
      ( if p-igt-empty = yes then 'Пусто':U       else "" ) )) + '</TD>' skip
        '</TR>'skip
        '</thead>'skip
    .
       put stream OutStr-html unformatted
        '<tbody>'
        '<TR>'skip
            '<TH rowspan="2" style="text-align: center; width: 40px;">Артикул</TH>'skip
            '<TH rowspan="2" style="text-align: center; width: 60px;">Название</TH>'skip
        .
        if p-group-by-order then do:
            v-jj = 3 .
        end.
        else do:
            v-jj = 2 .
        end.
    do while v-tmp-date <= p-date-finish
    :
        put stream OutStr-html unformatted
            '<TH colspan ="' + string(v-jj) + '" style="text-align: center;">' + string(v-tmp-date,"99.99.9999") + '</TH>'skip
        .
        v-tmp-date     = v-tmp-date + 1.
        ii = ii + 1.
    end.
       put stream OutStr-html unformatted
            '<TH colspan="' + string(v-jj) + '" style="text-align: center;">Итого %</TH>'skip
       .
       put stream OutStr-html unformatted
            '<TH rowspan="2" style="text-align: center; width: 60px;">Средний товарный запас</TH>'skip
            '<TH rowspan="2" style="text-align: center; width: 60px;">Об. дн.</TH>'skip
            '<TH rowspan="2" style="text-align: center; width: 60px;">Об раз</TH>'skip
        .
       put stream OutStr-html unformatted
        '</TR>'skip
        '<TR>'skip
        .
    v-tmp-date      = p-date-start.
    do while v-tmp-date <= p-date-finish
    :
        put stream OutStr-html unformatted
            '<TH colstyle="text-align: center; width: 20px;">О</TH>'skip
            '<TH colstyle="text-align: center; width: 20px;">П</TH>'skip
        .
        if p-group-by-order = yes then do:
        put stream OutStr-html UNFORMATTED
            '<TH colstyle="text-align: center; width: 20px;">З</TH>'skip
        .
        end.
        v-tmp-date     = v-tmp-date + 1.
    end.
    if p-group-by-order = yes then do:
       put stream OutStr-html unformatted
            '<TH colstyle="text-align: center; width: 20px;">% прис</TH>'skip
            '<TH colstyle="text-align: center; width: 20px;">% прод</TH>'skip
            '<TH colstyle="text-align: center; width: 20px;">% зак</TH>'skip
        '</TR>'skip
        .
    end.
    else do:
       put stream OutStr-html unformatted
            '<TH colstyle="text-align: center; width: 20px;">% прис</TH>'skip
            '<TH colstyle="text-align: center; width: 20px;">% прод</TH>'skip
        '</TR>'skip
        .
    end.
    for each buf_tt-report
      where buf_tt-report.obj-type = buf_tt-obj-list.obj-type
        and buf_tt-report.obj-code = buf_tt-obj-list.obj-code
    break by buf_tt-report.grp-code
          by buf_tt-report.gds-code
          by buf_tt-report.r-date
    :
      v-first = no .
      v-last = no .
      if first-of(buf_tt-report.gds-code)
      then do:
        find first buf_tt-goods
          where buf_tt-goods.obj-type = buf_tt-report.obj-type
            and buf_tt-goods.obj-code = buf_tt-report.obj-code
            and buf_tt-goods.gds-code = buf_tt-report.gds-code
        no-error .
        if available buf_tt-goods
        then do:
            assign
                v-balance = 0
                v-balance-last = 0
                v-sum-sale = 0
            .
            v-first = yes .
        put stream OutStr-html unformatted
        '<TR>'skip
            '<TD style="text-align: center;">' + buf_tt-goods.artic + '</TD>'skip
            '<TD style="text-align: center;">' + buf_tt-goods.gds-name + '</TD>'skip
        .
        end.
      end.
      if last-of(buf_tt-report.gds-code)
      then do:
        find first buf_tt-goods
          where buf_tt-goods.obj-type = buf_tt-report.obj-type
            and buf_tt-goods.obj-code = buf_tt-report.obj-code
            and buf_tt-goods.gds-code = buf_tt-report.gds-code
        no-error .
        if available buf_tt-goods
        then do:
           v-last = yes .
           v-balance-last = buf_tt-report.balance / 2.
        end.
      end.
        put stream OutStr-html unformatted
            '<TD num="0.000" val="' + fnc-convert-dot-to-colon(buf_tt-report.balance,"->>>>>>>>>>>9.999",3) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(buf_tt-report.balance,"->>>>>>>>>>>9.999",3) + '</TD>'skip
            '<TD num="0.000" val="' + fnc-convert-dot-to-colon(buf_tt-report.sale,"->>>>>>>>>>>9.999",3) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(buf_tt-report.sale,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
    if p-group-by-order then do:
        put stream OutStr-html unformatted
            '<TD num="0.000" val="' + fnc-convert-dot-to-colon(buf_tt-report.order,"->>>>>>>>>>>9.999",3) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(buf_tt-report.order,"->>>>>>>>>>>9.999",3) +  '</TD>'skip
        .
    end.
      if v-first = yes then do:
          v-balance = buf_tt-report.balance / 2 .
      end.
      else do:
          if v-last = yes then do:
              v-balance = v-balance + v-balance-last.
          end.
          else do:
              v-balance = v-balance + buf_tt-report.balance.
          end.
      end.
      v-sum-sale = v-sum-sale + buf_tt-report.sale .
      if buf_tt-report.balance <= p-critical-qnty-balance
      then do:
        assign
          v-num-days-wo-balance = v-num-days-wo-balance + 1
        .
      end.
      if buf_tt-report.sale <= p-critical-qnty-sale
      then do:
        assign
          v-num-days-wo-sale  = v-num-days-wo-sale + 1
        .
      end.
      if buf_tt-report.order <= p-critical-qnty-order
      then do:
        assign
          v-num-days-wo-order = v-num-days-wo-order + 1
        .
      end.
      if last-of(buf_tt-report.gds-code)
      then do:
        assign
          v-gds-prc-balance = ( ( v-days-count - v-num-days-wo-balance ) / v-days-count ) * 100
          v-gds-prc-sale    = ( ( v-days-count - v-num-days-wo-sale    ) / v-days-count ) * 100
          v-gds-prc-order   = ( ( v-days-count - v-num-days-wo-order   ) / v-days-count ) * 100
          v-grp-end-line    = v-grp-end-line + 1
        .
        put stream OutStr-html unformatted
                '<TD num="0.000" val="' + fnc-convert-dot-to-colon(v-gds-prc-balance,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon(v-gds-prc-balance,"->>>>>>>>>>>9.999",3) + '</TD>'skip
                '<TD num="0.000" val="' + fnc-convert-dot-to-colon(v-gds-prc-sale,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon(v-gds-prc-sale,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
        if p-group-by-order then do:
        put stream OutStr-html unformatted
            '<TD num="0.000" val="' + fnc-convert-dot-to-colon(v-gds-prc-order,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon(v-gds-prc-order,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
        end.
        put stream OutStr-html unformatted
            '<TD num="0.000" val="' + fnc-convert-dot-to-colon((v-balance / (ii - 1)),"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon((v-balance / (ii - 1)),"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
        if v-sum-sale <> 0 then do:
        put stream OutStr-html unformatted
            '<TD num="0.000" val="' + fnc-convert-dot-to-colon((((v-balance / (ii - 1)) * ii ) / v-sum-sale  ),"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon((((v-balance / (ii - 1)) * ii ) / v-sum-sale  ),"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
        end.
        else do:
            put stream OutStr-html unformatted
            '<TD num="0.000" val="' + fnc-convert-dot-to-colon(0.000,"->>>>>>>>>>>9.999",3) + '"style="text-align:right;">' + fnc-convert-dot-to-colon(0.000,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
        end.
        if v-balance <> 0 then do:
        put stream OutStr-html unformatted
            '<TD num="0.000" val="' + fnc-convert-dot-to-colon(v-sum-sale /(v-balance / (ii - 1)),"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon(v-sum-sale /(v-balance / (ii - 1)),"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
        end.
        else do:
            put stream OutStr-html unformatted
            '<TD num="0.000" val="' + fnc-convert-dot-to-colon(0.000,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon(0.000,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
        end.
       put stream OutStr-html unformatted
        '</TR>'skip
        .
        assign
          v-tot-num-days-wo-balance = v-tot-num-days-wo-balance + v-num-days-wo-balance
          v-tot-num-days-wo-sale    = v-tot-num-days-wo-sale    + v-num-days-wo-sale
          v-tot-num-days-wo-order   = v-tot-num-days-wo-order   + v-num-days-wo-order
          v-num-days-wo-balance     = 0
          v-num-days-wo-sale        = 0
          v-num-days-wo-order       = 0
        .
      end.
      if last-of(buf_tt-report.grp-code)
      then do:
        assign
          v-gds-grp-count   = 0
          v-grp-list        = v-grp-list + substitute("&1&2&3" , v-grp-start-line , chr(1), v-grp-end-line ) + chr(4)
          v-grp-start-line  = v-grp-end-line + 2
          v-grp-end-line    = v-grp-start-line - 1
        .
        for each buf_tt-goods
          where buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
            and buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
            and buf_tt-goods.grp-code = buf_tt-report.grp-code
        :
          assign
            v-gds-grp-count = v-gds-grp-count + 1
          .
        end.
        find first buf_tt-goods
          where buf_tt-goods.obj-type = buf_tt-report.obj-type
            and buf_tt-goods.obj-code = buf_tt-report.obj-code
            and buf_tt-goods.gds-code = buf_tt-report.gds-code
        no-error .
        if available buf_tt-goods
        then do:
        put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan = "2" style="text-align: center;">Итого % группы' + buf_tt-goods.grp-name + '</TD>'skip
        .
        end.
        for each buf_tt-report-day
          where buf_tt-report-day.obj-type = buf_tt-obj-list.obj-type
            and buf_tt-report-day.obj-code = buf_tt-obj-list.obj-code
            and buf_tt-report-day.grp-code = buf_tt-report.grp-code
        break by buf_tt-report-day.r-date
        :
          if buf_tt-report-day.balance <= p-critical-qnty-balance
          then do:
            assign
              v-grp-balance = v-grp-balance + 1
            .
          end.
          if buf_tt-report-day.sale <= p-critical-qnty-sale
          then do:
            assign
              v-grp-sale  = v-grp-sale + 1
            .
          end.
          if buf_tt-report-day.order <= p-critical-qnty-order
          then do:
            assign
              v-grp-order = v-grp-order + 1
            .
          end.
          if last-of(buf_tt-report-day.r-date)
          then do:
        put stream OutStr-html unformatted
            '<TD num="0.000" val="' + fnc-convert-dot-to-colon(((v-gds-grp-count - v-grp-balance) / v-gds-grp-count) * 100,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon(((v-gds-grp-count - v-grp-balance) / v-gds-grp-count) * 100,"->>>>>>>>>>>9.999",3) + '</TD>'skip
            '<TD num="0.000" val="' + fnc-convert-dot-to-colon( ((v-gds-grp-count - v-grp-sale   ) / v-gds-grp-count) * 100 ,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon( ((v-gds-grp-count - v-grp-sale   ) / v-gds-grp-count) * 100 ,"->>>>>>>>>>>9.999",3) + '</TD>'skip
         .
        if p-group-by-order then do:
        put stream OutStr-html unformatted
            '<TD num="0.000" val="' + fnc-convert-dot-to-colon(((v-gds-grp-count - v-grp-order  ) / v-gds-grp-count) * 100 ,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon(((v-gds-grp-count - v-grp-order  ) / v-gds-grp-count) * 100 ,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
        end.
            assign
              v-grp-tot-balance = v-grp-tot-balance + v-grp-balance
              v-grp-tot-sale    = v-grp-tot-sale    + v-grp-sale
              v-grp-tot-order   = v-grp-tot-order   + v-grp-order
              v-grp-balance     = 0
              v-grp-sale        = 0
              v-grp-order       = 0
            .
          end.
        end.
        assign
          v-gds-grp-tot-count = v-gds-grp-count * v-days-count
        .
        put stream OutStr-html unformatted
        '<TD num="0.000" val="' + fnc-convert-dot-to-colon((v-gds-grp-tot-count - v-grp-tot-balance) / ( v-gds-grp-tot-count ) * 100,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon((v-gds-grp-tot-count - v-grp-tot-balance) / ( v-gds-grp-tot-count ) * 100,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        '<TD num="0.000" val="' + fnc-convert-dot-to-colon((v-gds-grp-tot-count - v-grp-tot-sale   ) / ( v-gds-grp-tot-count ) * 100,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon((v-gds-grp-tot-count - v-grp-tot-sale   ) / ( v-gds-grp-tot-count ) * 100,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
        if p-group-by-order then do:
        put stream OutStr-html unformatted
        '<TD num="0.000" val="' + fnc-convert-dot-to-colon((v-gds-grp-tot-count - v-grp-tot-order  ) / ( v-gds-grp-tot-count ) * 100 ,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon((v-gds-grp-tot-count - v-grp-tot-order  ) / ( v-gds-grp-tot-count ) * 100 ,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
        end.
        put stream OutStr-html unformatted
            '<TD style="text-align: center;"></TD>'skip
            '<TD style="text-align: center;"></TD>'skip
            '<TD style="text-align: center;"></TD>'skip
        .
        put stream OutStr-html unformatted
        '</TR>'skip
        .
        assign
          v-grp-tot-balance = 0
          v-grp-tot-sale    = 0
          v-grp-tot-order   = 0
          v-gds-tot-count   = v-gds-tot-count + v-gds-grp-count
        .
      end.
    end.
            put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan = "2" style="text-align: center;">Итого по матрице</TD>'skip
        .
    for each buf_tt-report-day
      where buf_tt-report-day.obj-type = buf_tt-obj-list.obj-type
        and buf_tt-report-day.obj-code = buf_tt-obj-list.obj-code
    break by buf_tt-report-day.r-date
    :
      if buf_tt-report-day.balance <= p-critical-qnty-balance
      then do:
        assign
          v-tot-balance = v-tot-balance + 1
        .
      end.
      if buf_tt-report-day.sale <= p-critical-qnty-sale
      then do:
        assign
          v-tot-sale  = v-tot-sale + 1
        .
      end.
      if buf_tt-report-day.order <= p-critical-qnty-order
      then do:
        assign
          v-tot-order = v-tot-order + 1
        .
      end.
      if last-of(buf_tt-report-day.r-date)
      then do:
        put stream OutStr-html unformatted
        '<TD num="0.000" val="' + fnc-convert-dot-to-colon((v-gds-tot-count - v-tot-balance  ) / v-gds-tot-count * 100 ,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon((v-gds-tot-count - v-tot-balance  ) / v-gds-tot-count * 100,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        '<TD num="0.000" val="' + fnc-convert-dot-to-colon((v-gds-tot-count - v-tot-sale     ) / v-gds-tot-count * 100 ,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon((v-gds-tot-count - v-tot-sale     ) / v-gds-tot-count * 100 ,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
        if p-group-by-order then do:
        put stream OutStr-html unformatted
        '<TD num="0.000" val="' + fnc-convert-dot-to-colon((v-gds-tot-count - v-tot-order    ) / v-gds-tot-count * 100 ,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon((v-gds-tot-count - v-tot-order    ) / v-gds-tot-count * 100 ,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
        end.
        assign
          v-tot-asm-balance = v-tot-asm-balance + v-tot-balance
          v-tot-asm-sale    = v-tot-asm-sale    + v-tot-sale
          v-tot-asm-order   = v-tot-asm-order   + v-tot-order
          v-tot-balance     = 0
          v-tot-sale        = 0
          v-tot-order       = 0
        .
      end.
    end.
    assign
      v-tot-asm-gds-count = v-gds-tot-count * v-days-count
    .
        put stream OutStr-html unformatted
        '<TD num="0.000" val="' + fnc-convert-dot-to-colon((v-tot-asm-gds-count - v-tot-asm-balance ) / v-tot-asm-gds-count * 100 ,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon((v-tot-asm-gds-count - v-tot-asm-balance ) / v-tot-asm-gds-count * 100,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        '<TD num="0.000" val="' + fnc-convert-dot-to-colon((v-tot-asm-gds-count - v-tot-asm-sale    ) / v-tot-asm-gds-count * 100 ,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon((v-tot-asm-gds-count - v-tot-asm-sale    ) / v-tot-asm-gds-count * 100 ,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
        if p-group-by-order then do:
        put stream OutStr-html unformatted
        '<TD num="0.000" val="' + fnc-convert-dot-to-colon((v-tot-asm-gds-count - v-tot-asm-order   ) / v-tot-asm-gds-count * 100 ,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon((v-tot-asm-gds-count - v-tot-asm-order   ) / v-tot-asm-gds-count * 100 ,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
        end.
        put stream OutStr-html unformatted
            '<TD style="text-align: center;"></TD>'skip
            '<TD style="text-align: center;"></TD>'skip
            '<TD style="text-align: center;"></TD>'skip
        .
        put stream OutStr-html unformatted
        '</TR>'skip
        .
    assign
      v-tot-asm-gds-count = 0
      v-tot-asm-balance   = 0
      v-tot-asm-sale      = 0
      v-tot-asm-order     = 0
      v-gds-tot-count     = 0
    .
  end.
  run waitfram-hide in this-procedure .
end.
end procedure.
procedure print-no-schedule-supp :
  define buffer buf_tt-obj-list   for tt-obj-list.
  define buffer buf_tt-report     for tt-report.
  define buffer buf_tt-report-day for tt-report.
  define buffer buf_tt-goods      for tt-goods.
  define buffer buf_clients       for ub.clients.
  define variable v-i               as integer   no-undo .
  define variable v-line-1          as character no-undo .
  define variable v-clmn-label-1    as character no-undo .
  define variable v-clmn-label-2    as character no-undo .
  define variable v-clmn-format     as character no-undo .
  define variable v-clmn-sizes      as character no-undo .
  define variable v-tmp-date        as date      no-undo .
  define variable v-days-count      as integer   no-undo .
  define variable v-list-num        as integer   no-undo .
  define variable v-grp-start-line  as integer   no-undo .
  define variable v-grp-end-line    as integer   no-undo .
  define variable v-supp-start-line as integer   no-undo .
  define variable v-supp-end-line   as integer   no-undo .
  define variable v-grp-list        as character no-undo .
  define variable v-gds-tot-count     as decimal   no-undo .
  define variable v-gds-grp-count     as decimal   no-undo .
  define variable v-gds-grp-tot-count as decimal   no-undo .
  define variable v-gds-sup-count     as decimal   no-undo .
  define variable v-gds-sup-tot-count as decimal   no-undo .
  define variable v-gds-asm-count     as decimal   no-undo .
  define variable v-gds-asm-tot-count as decimal   no-undo .
  define variable v-gds-balance     as decimal   no-undo .
  define variable v-gds-sale        as decimal   no-undo .
  define variable v-gds-order       as decimal   no-undo .
  define variable v-gds-tot-balance as decimal   no-undo .
  define variable v-gds-tot-sale    as decimal   no-undo .
  define variable v-gds-tot-order   as decimal   no-undo .
  define variable v-grp-balance     as decimal   no-undo .
  define variable v-grp-sale        as decimal   no-undo .
  define variable v-grp-order       as decimal   no-undo .
  define variable v-grp-tot-balance as decimal   no-undo .
  define variable v-grp-tot-sale    as decimal   no-undo .
  define variable v-grp-tot-order   as decimal   no-undo .
  define variable v-sup-balance     as decimal   no-undo .
  define variable v-sup-sale        as decimal   no-undo .
  define variable v-sup-order       as decimal   no-undo .
  define variable v-sup-tot-balance as decimal   no-undo .
  define variable v-sup-tot-sale    as decimal   no-undo .
  define variable v-sup-tot-order   as decimal   no-undo .
  define variable v-asm-balance     as decimal   no-undo .
  define variable v-asm-sale        as decimal   no-undo .
  define variable v-asm-order       as decimal   no-undo .
  define variable v-asm-tot-balance as decimal   no-undo .
  define variable v-asm-tot-sale    as decimal   no-undo .
  define variable v-asm-tot-order   as decimal   no-undo .
  define variable v-gds-prc-balance as decimal   no-undo .
  define variable v-gds-prc-sale    as decimal   no-undo .
  define variable v-gds-prc-order   as decimal   no-undo .
  define variable v-grp-prc-balance as decimal   no-undo .
  define variable v-grp-prc-sale    as decimal   no-undo .
  define variable v-grp-prc-order   as decimal   no-undo .
  define variable v-sup-prc-balance as decimal   no-undo .
  define variable v-sup-prc-sale    as decimal   no-undo .
  define variable v-sup-prc-order   as decimal   no-undo .
  define variable v-asm-prc-balance as decimal   no-undo .
  define variable v-asm-prc-sale    as decimal   no-undo .
  define variable v-asm-prc-order   as decimal   no-undo .
do
on error undo, return error return-value
:
  assign
    v-days-count = p-date-finish - p-date-start + 1
  .
  for each buf_tt-obj-list
  :
    run waitfram-show in this-procedure ( input substitute( "Расчет итогов по объекту &1 &2...":U
                                                          , buf_tt-obj-list.obj-type
                                                          , buf_tt-obj-list.obj-code
                                                          )
                                        ) .
   if p-gds-by-am = yes
    then do:
      put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="8" STYLE="font-size: 14px;">' + string(substitute("По АМ на &1 товаров":U , v-gds-tot-count )) + '</TD>' skip
        '</TR>'skip
    .
    end.
    if p-group-by-post = yes
    then do:
      put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="8" STYLE="font-size: 14px;">Группировка по поставщику</TD>' skip
        '</TR>'skip
    .
    end.
   put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="8" STYLE="font-size: 14px;">' + string(substitute( "Критический остаток: &1" , p-critical-qnty-balance )) + '</TD>' skip
        '</TR>'skip
    .
     put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="8" STYLE="font-size: 14px;">' + string(substitute( "Критическая продажа: &1" , p-critical-qnty-sale    )) + '</TD>' skip
        '</TR>'skip
    .
     put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="8" STYLE="font-size: 14px;">' + string(substitute( "Критический заказ: &1"   , p-critical-qnty-order   )) + '</TD>' skip
        '</TR>'skip
    .
     put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="8" STYLE="font-size: 14px;">' + string(substitute( "Фильтры:"                                          )) + '</TD>' skip
        '</TR>'skip
    .
     put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="8" STYLE="font-size: 14px;">' + string(substitute( "Дней без товара: &1"     , p-days-wt-goods         )) + '</TD>' skip
        '</TR>'skip
    .
      put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="8" STYLE="font-size: 14px;">Показывать товары с ИЖТ:' + string(( if p-igt-all   = yes then 'все':U else
      ( if p-igt-new   = yes then 'Новинка':U   + "," else "" ) +
      ( if p-igt-com   = yes then 'Основная группа':U   + "," else "" ) +
      ( if p-igt-spec  = yes then 'Нештатный':U  + "," else "" ) +
      ( if p-igt-del   = yes then 'На вывод из ассортимента':U   + "," else "" ) +
      ( if p-igt-empty = yes then 'Пусто':U       else "" ) )) + '</TD>' skip
        '</TR>'skip
        '</thead>'skip
    .
    assign
      v-tmp-date      = p-date-start
      v-i             = 3
      v-list-num      = v-list-num + 1
      v-clmn-label-1  = '':u
      v-clmn-label-2  = '':u
      v-clmn-format   = '':u
      v-clmn-sizes    = '':u
      v-line-1        = '':u
    .
   put stream OutStr-html unformatted
        '<tbody>'
        '<TR>'skip
            '<TH rowspan="2" style="text-align: center;">Артикул</TH>'skip
            '<TH rowspan="2" style="text-align: center;">Название</TH>'skip
        .
    define VARIABLE v-jj as integer no-undo .
        if p-group-by-order then do:
            v-jj = 3 .
        end.
        else do:
            v-jj = 2 .
        end.
    do while v-tmp-date <= p-date-finish
    :
    put stream OutStr-html unformatted
            '<TH colspan ="' + string(v-jj) + '" style="text-align: center;">' + string(v-tmp-date,"99.99.9999") + '</TH>'skip
        .
        v-tmp-date     = v-tmp-date + 1.
    end.
       put stream OutStr-html unformatted
            '<TH colspan="' + string(v-jj) + '" style="text-align: center;">Итого %</TH>'skip
        '</TR>'skip
        .
    v-tmp-date      = p-date-start.
    do while v-tmp-date <= p-date-finish
    :
        put stream OutStr-html unformatted
            '<TH colstyle="text-align: center;">О</TH>'skip
            '<TH colstyle="text-align: center;">П</TH>'skip
        .
        if p-group-by-order then do:
        put stream OutStr-html unformatted
            '<TH colstyle="text-align: center;">З</TH>'skip
        .
        end.
        v-tmp-date     = v-tmp-date + 1.
    end.
        if p-group-by-order then do:
       put stream OutStr-html unformatted
            '<TH colstyle="text-align: center;">% прис</TH>'skip
            '<TH colstyle="text-align: center;">% прод</TH>'skip
            '<TH colstyle="text-align: center;">% зак</TH>'skip
        '</TR>'skip
        .
        end.
        else do:
       put stream OutStr-html unformatted
            '<TH colstyle="text-align: center;">% прис</TH>'skip
            '<TH colstyle="text-align: center;">% прод</TH>'skip
        '</TR>'skip
        .
        end.
    for each buf_tt-goods
      where buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
        and buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
    :
      assign
        v-gds-tot-count = v-gds-tot-count + 1
      .
    end.
    for each buf_tt-report
      where buf_tt-report.obj-type = buf_tt-obj-list.obj-type
        and buf_tt-report.obj-code = buf_tt-obj-list.obj-code
    break by buf_tt-report.supp-type
          by buf_tt-report.supp-code
          by buf_tt-report.grp-code
          by buf_tt-report.gds-code
          by buf_tt-report.r-date
    :
      if first-of(buf_tt-report.gds-code)
      then do:
        find first buf_tt-goods
          where buf_tt-goods.obj-type = buf_tt-report.obj-type
            and buf_tt-goods.obj-code = buf_tt-report.obj-code
            and buf_tt-goods.gds-code = buf_tt-report.gds-code
        no-error .
        if available buf_tt-goods
        then do:
        put stream OutStr-html unformatted
        '<TR>'skip
            '<TH style="text-align: center;">' + buf_tt-goods.artic + '</TH>'skip
            '<TH style="text-align: center;">' + buf_tt-goods.gds-name + '</TH>'skip
        .
        end.
      end.
        put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string(buf_tt-report.balance) + '</TH>'skip
            '<TH style="text-align: center;">' + string(buf_tt-report.sale) + '</TH>'skip
        .
        if p-group-by-order then do:
        put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string(buf_tt-report.order) + '</TH>'skip
        .
        end.
      if buf_tt-report.balance <= p-critical-qnty-balance
      then do:
        assign
          v-gds-balance = v-gds-balance + 1
        .
      end.
      if buf_tt-report.sale <= p-critical-qnty-sale
      then do:
        assign
          v-gds-sale = v-gds-sale + 1
        .
      end.
      if buf_tt-report.order <= p-critical-qnty-order
      then do:
        assign
          v-gds-order = v-gds-order + 1
        .
      end.
      if last-of(buf_tt-report.gds-code)
      then do:
        assign
          v-gds-prc-balance = ( ( v-days-count - v-gds-balance ) / v-days-count ) * 100
          v-gds-prc-sale    = ( ( v-days-count - v-gds-sale    ) / v-days-count ) * 100
          v-gds-prc-order   = ( ( v-days-count - v-gds-order   ) / v-days-count ) * 100
          v-grp-end-line    = v-grp-end-line + 1
        .
        if p-group-by-order then do:
        put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-gds-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-gds-prc-sale    , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-gds-prc-order   , ">>9.999" ) + '</TH>'skip
        '</TR>'skip
        .
        end.
        else do:
       put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-gds-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-gds-prc-sale    , ">>9.999" ) + '</TH>'skip
        '</TR>'skip
        .
        end.
        assign
          v-gds-balance = 0
          v-gds-sale    = 0
          v-gds-order   = 0
        .
      end.
      if last-of(buf_tt-report.grp-code)
      then do:
        find first buf_tt-goods
          where buf_tt-goods.obj-type = buf_tt-report.obj-type
            and buf_tt-goods.obj-code = buf_tt-report.obj-code
            and buf_tt-goods.gds-code = buf_tt-report.gds-code
        no-error .
        if available buf_tt-goods
        then do:
           put stream OutStr-html unformatted
            '<TR>'skip
                '<TH colspan = "2" style="text-align: center;">Итого % группы' + buf_tt-goods.grp-name + '</TH>'skip
            .
        end.
        assign
          v-gds-grp-count   = 0
          v-grp-list        = v-grp-list + substitute("&1&2&3" , v-grp-start-line , chr(1), v-grp-end-line ) + chr(4)
          v-grp-start-line  = v-grp-end-line + 2
          v-grp-end-line    = v-grp-start-line - 1
        .
        for each buf_tt-report-day
          where buf_tt-report-day.obj-type  = buf_tt-report.obj-type
            and buf_tt-report-day.obj-code  = buf_tt-report.obj-code
            and buf_tt-report-day.grp-code  = buf_tt-report.grp-code
            and buf_tt-report-day.supp-type = buf_tt-report.supp-type
            and buf_tt-report-day.supp-code = buf_tt-report.supp-code
            and buf_tt-report-day.r-date    = p-date-start
        :
          assign
            v-gds-grp-count = v-gds-grp-count + 1
          .
        end.
        for each buf_tt-report-day
          where buf_tt-report-day.obj-type = buf_tt-obj-list.obj-type
            and buf_tt-report-day.obj-code = buf_tt-obj-list.obj-code
            and buf_tt-report-day.grp-code = buf_tt-report.grp-code
            and buf_tt-report-day.supp-type = buf_tt-report.supp-type
            and buf_tt-report-day.supp-code = buf_tt-report.supp-code
        break by buf_tt-report-day.r-date
        :
          if buf_tt-report-day.balance <= p-critical-qnty-balance
          then do:
            assign
              v-grp-balance = v-grp-balance + 1
            .
          end.
          if buf_tt-report-day.sale <= p-critical-qnty-sale
          then do:
            assign
              v-grp-sale  = v-grp-sale + 1
            .
          end.
          if buf_tt-report-day.order <= p-critical-qnty-order
          then do:
            assign
              v-grp-order = v-grp-order + 1
            .
          end.
          if last-of(buf_tt-report-day.r-date)
          then do:
            assign
              v-grp-prc-balance = ((v-gds-grp-count - v-grp-balance) / v-gds-grp-count) * 100
              v-grp-prc-sale    = ((v-gds-grp-count - v-grp-sale   ) / v-gds-grp-count) * 100
              v-grp-prc-order   = ((v-gds-grp-count - v-grp-order  ) / v-gds-grp-count) * 100
            .
         if p-group-by-order then do:
         put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-grp-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-grp-prc-sale    , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-grp-prc-order   , ">>9.999" ) + '</TH>'skip
            '</TR>'skip
        .
         end.
         else do:
         put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-grp-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-grp-prc-sale    , ">>9.999" ) + '</TH>'skip
           '</TR>'skip
        .
         end.
            assign
              v-grp-tot-balance = v-grp-tot-balance + v-grp-balance
              v-grp-tot-sale    = v-grp-tot-sale    + v-grp-sale
              v-grp-tot-order   = v-grp-tot-order   + v-grp-order
              v-grp-balance     = 0
              v-grp-sale        = 0
              v-grp-order       = 0
            .
          end.
        end.
        assign
          v-gds-grp-tot-count = v-gds-grp-count * v-days-count
          v-grp-prc-balance   = ((v-gds-grp-tot-count - v-grp-tot-balance) / v-gds-grp-tot-count) * 100
          v-grp-prc-sale      = ((v-gds-grp-tot-count - v-grp-tot-sale   ) / v-gds-grp-tot-count) * 100
          v-grp-prc-order     = ((v-gds-grp-tot-count - v-grp-tot-order  ) / v-gds-grp-tot-count) * 100
          v-grp-tot-balance   = 0
          v-grp-tot-sale      = 0
          v-grp-tot-order     = 0
          v-gds-sup-count     = v-gds-sup-count + v-gds-grp-count
          v-gds-grp-count     = 0
        .
        if p-group-by-order then do:
        put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-grp-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-grp-prc-sale    , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-grp-prc-order   , ">>9.999" ) + '</TH>'skip
            '</TR>'skip
        .
        end.
        else do:
        put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-grp-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-grp-prc-sale    , ">>9.999" ) + '</TH>'skip
            '</TR>'skip
        .
        end.
      end.
      if last-of(buf_tt-report.supp-type) or
         last-of(buf_tt-report.supp-code)
      then do:
        if buf_tt-report.supp-type = "" and
           buf_tt-report.supp-code = 0
        then do:
        put stream OutStr-html unformatted
            '<TR>'skip
            '<TH colspan="2" style="text-align: center;">Итого по поставщику Неизвестный поставщик</TH>'skip
        .
        end.
        else do:
          find first buf_clients no-lock
            where buf_clients.obj-type = buf_tt-report.supp-type
              and buf_clients.obj-code = buf_tt-report.supp-code
          no-error .
          if available buf_clients
          then do:
          end.
        end.
        for each buf_tt-report-day
          where buf_tt-report-day.obj-type = buf_tt-obj-list.obj-type
            and buf_tt-report-day.obj-code = buf_tt-obj-list.obj-code
            and buf_tt-report-day.supp-type = buf_tt-report.supp-type
            and buf_tt-report-day.supp-code = buf_tt-report.supp-code
        break by buf_tt-report-day.r-date
        :
          if buf_tt-report-day.balance <= p-critical-qnty-balance
          then do:
            assign
              v-sup-balance = v-sup-balance + 1
            .
          end.
          if buf_tt-report-day.sale <= p-critical-qnty-sale
          then do:
            assign
              v-sup-sale  = v-sup-sale + 1
            .
          end.
          if buf_tt-report-day.order <= p-critical-qnty-order
          then do:
            assign
              v-sup-order = v-sup-order + 1
            .
          end.
          if last-of(buf_tt-report-day.r-date)
          then do:
            assign
              v-sup-prc-balance = ((v-gds-sup-count - v-sup-balance) / v-gds-sup-count) * 100
              v-sup-prc-sale    = ((v-gds-sup-count - v-sup-sale   ) / v-gds-sup-count) * 100
              v-sup-prc-order   = ((v-gds-sup-count - v-sup-order  ) / v-gds-sup-count) * 100
            .
        if p-group-by-order then do:
        put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-grp-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-grp-prc-sale    , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-grp-prc-order   , ">>9.999" ) + '</TH>'skip
            '</TR>'skip
        .
        end.
        else do:
        put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-grp-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-grp-prc-sale    , ">>9.999" ) + '</TH>'skip
            '</TR>'skip
        .
        end.
            assign
              v-sup-tot-balance = v-sup-tot-balance + v-sup-balance
              v-sup-tot-sale    = v-sup-tot-sale    + v-sup-sale
              v-sup-tot-order   = v-sup-tot-order   + v-sup-order
              v-sup-balance     = 0
              v-sup-sale        = 0
              v-sup-order       = 0
            .
          end.
        end.
        assign
          v-gds-sup-tot-count = v-gds-sup-count * v-days-count
          v-sup-prc-balance   = ((v-gds-sup-tot-count - v-sup-tot-balance) / v-gds-sup-tot-count) * 100
          v-sup-prc-sale      = ((v-gds-sup-tot-count - v-sup-tot-sale   ) / v-gds-sup-tot-count) * 100
          v-sup-prc-order     = ((v-gds-sup-tot-count - v-sup-tot-order  ) / v-gds-sup-tot-count) * 100
          v-sup-tot-balance   = 0
          v-sup-tot-sale      = 0
          v-sup-tot-order     = 0
          v-gds-asm-count     = v-gds-asm-count + v-gds-sup-count
          v-supp-end-line     = v-grp-start-line - 1
          v-grp-list          = v-grp-list + substitute("&1&2&3" , v-supp-start-line , chr(1), v-supp-end-line ) + chr(4)
          v-grp-start-line    = v-grp-start-line + 1
          v-grp-end-line      = v-grp-end-line + 1
          v-supp-start-line   = v-grp-start-line
          v-gds-sup-count     = 0
          v-gds-sup-tot-count = 0
        .
        if p-group-by-order then do:
       put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-grp-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-grp-prc-sale    , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-grp-prc-order   , ">>9.999" ) + '</TH>'skip
            '</TR>'skip
        .
        end.
        else do:
       put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-grp-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-grp-prc-sale    , ">>9.999" ) + '</TH>'skip
            '</TR>'skip
        .
        end.
      end.
    end.
           put stream OutStr-html unformatted
            '<TR>'skip
                '<TH colspan = "2" style="text-align: center;">Итого по матрице</TH>'skip
            .
    define variable v-asm-flag-balance  as logical   no-undo .
    define variable v-asm-flag-sale     as logical   no-undo .
    define variable v-asm-flag-order    as logical   no-undo .
    define variable v-gds as integer   no-undo .
    for each buf_tt-report-day
      where buf_tt-report-day.obj-type = buf_tt-obj-list.obj-type
        and buf_tt-report-day.obj-code = buf_tt-obj-list.obj-code
    break by buf_tt-report-day.r-date
          by buf_tt-report-day.gds-code
    :
      if buf_tt-report-day.balance <= p-critical-qnty-balance
      then do:
        assign
          v-asm-flag-balance = yes
        .
      end.
      if buf_tt-report-day.sale <= p-critical-qnty-sale
      then do:
        assign
          v-asm-flag-sale = yes
        .
      end.
      if buf_tt-report-day.order <= p-critical-qnty-order
      then do:
        assign
          v-asm-flag-order = yes
        .
      end.
      if last-of (buf_tt-report-day.gds-code)
      then do:
        assign
          v-gds = v-gds + 1
        .
        if v-asm-flag-balance = yes
        then do:
          assign
            v-asm-balance = v-asm-balance + 1
          .
        end.
        if v-asm-flag-sale = yes
        then do:
          assign
            v-asm-sale  = v-asm-sale + 1
          .
        end.
        if v-asm-flag-order = yes
        then do:
          assign
            v-asm-order = v-asm-order + 1
          .
        end.
        assign
          v-asm-flag-balance  = no
          v-asm-flag-sale     = no
          v-asm-flag-order    = no
        .
      end.
      if last-of(buf_tt-report-day.r-date)
      then do:
        assign
          v-asm-prc-balance = ((v-gds-tot-count - v-asm-balance) / v-gds-tot-count) * 100
          v-asm-prc-sale    = ((v-gds-tot-count - v-asm-sale   ) / v-gds-tot-count) * 100
          v-asm-prc-order   = ((v-gds-tot-count - v-asm-order  ) / v-gds-tot-count) * 100
        .
        if p-group-by-order then do:
                put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-asm-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-asm-prc-sale    , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-asm-prc-order   , ">>9.999" ) + '</TH>'skip
            '</TR>'skip
        .
        end.
        else do:
                put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-asm-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-asm-prc-sale    , ">>9.999" ) + '</TH>'skip
            '</TR>'skip
        .
        end.
        assign
          v-asm-tot-balance = v-asm-tot-balance + v-asm-balance
          v-asm-tot-sale    = v-asm-tot-sale    + v-asm-sale
          v-asm-tot-order   = v-asm-tot-order   + v-asm-order
          v-asm-balance     = 0
          v-asm-sale        = 0
          v-asm-order       = 0
        .
      end.
    end.
    assign
      v-gds-asm-tot-count = v-gds-tot-count * v-days-count
      v-asm-prc-balance   = (v-gds-asm-tot-count - v-asm-tot-balance) / v-gds-asm-tot-count * 100
      v-asm-prc-sale      = (v-gds-asm-tot-count - v-asm-tot-sale   ) / v-gds-asm-tot-count * 100
      v-asm-prc-order     = (v-gds-asm-tot-count - v-asm-tot-order  ) / v-gds-asm-tot-count * 100
    .
    if p-group-by-order then do:
            put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-asm-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-asm-prc-sale    , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-asm-prc-order   , ">>9.999" ) + '</TH>'skip
            '</TR>'skip
        .
     end.
     else do:
            put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-asm-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-asm-prc-sale    , ">>9.999" ) + '</TH>'skip
            '</TR>'skip
        .
     end.
    assign
      v-asm-tot-balance     = 0
      v-asm-tot-sale        = 0
      v-asm-tot-order       = 0
      v-gds-asm-count       = 0
      v-gds-asm-tot-count   = 0
    .
  end.
  run waitfram-hide in this-procedure .
end.
end procedure.
procedure print-schedule :
do
on error undo, return error return-value
:
end.
end procedure.
procedure write-log :
  define input  parameter p-str as character no-undo .
do
on error undo, return error return-value
:
  if p-str = ''
  then do:
    return .
  end.
  if p-is-schedule = yes
  then do:
    if parparentproc :get-signature("write-to-log") <> "":u
    then do:
      run write-to-log in parparentproc ( input p-str ) .
    end.
    assign
      p-str = substitute("&1 &2&3", cur-time-string-sec() , p-str, chr(10))
      p-str = replace(p-str, (chr(10) + chr(13)), chr(10) )
      p-str = replace(p-str, (chr(13) + chr(10)), chr(10) )
      p-str = replace(p-str, chr(10), (chr(13) + chr(10)) )
    .
    run gbl/fileapnd.p
      ( input "r-ctrasm.log"
       ,input p-str
       ,input 10
      ) no-error .
    if error-status:error then do:
      return error return-value .
    end.
  end.
end.
end procedure.
procedure proc-message :
  define input  parameter p-message as character no-undo .
do
on error undo, return error return-value
:
  if p-is-schedule = yes
  then do:
    run write-log in this-procedure ( input p-message ) .
  end.
  else do:
    message
      p-message
    view-as alert-box information.
  end.
end.
end procedure.
procedure cb_set-objects :
define input parameter p-obj-type-code as character no-undo .
define buffer buf_clients for ub.clients.
do
on error undo, return error
:
  find first buf_clients no-lock where
            buf_clients.obj-type = substring(p-obj-type-code, 1, 3)
        and buf_clients.obj-code = integer(substring(p-obj-type-code, 4)) no-error.
  if available buf_clients then do:
    run create_obj-list in this-procedure ( input buf_clients.obj-type
                                          , input buf_clients.obj-code
                                          ) .
  end.
end.
end procedure.
