block-level on error undo, throw.
DEFINE INPUT PARAMETER DcardMode as char no-undo.
DEFINE INPUT PARAMETER FixDCard as char no-undo.
DEFINE INPUT PARAMETER ProdMode as integer no-undo.
DEFINE INPUT PARAMETER FixProdAttr as char no-undo.
DEFINE INPUT PARAMETER TotalOnly as logical no-undo.
DEFINE INPUT PARAMETER StartPoint as date no-undo.
DEFINE INPUT PARAMETER EndPoint as date no-undo.
DEFINE INPUT PARAMETER T-time as logical no-undo.
define input parameter T-zeros as logical no-undo .
define input parameter t-legacy  as logical no-undo .
define input parameter t-subsid  as logical no-undo .
define input parameter p-prodmode2 as character no-undo .
define input parameter t-imp as logical no-undo.
define variable vss-revision    as character no-undo init "$Revision: 4c147e0df675, 235, rls $":U .
define variable vss-author      as character no-undo init "$Author: PGridchina $":U .
define variable vss-date        as character no-undo init "$Date: Tue Jul 28 13:40:01 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: e-xldcd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/e-xldcd.p $":U .
define variable vss-description as character no-undo init "Заполнение полей временной таблицы для отчета по постоянным клиентам".
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
define   shared variable gdsgrp_recids      as character no-undo.
define   shared variable fin-schet-recid    as character no-undo.
define   shared variable v-d-report-handle  as handle    no-undo .
define   shared temp-table g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define   shared temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define   shared temp-table tmp#grp no-undo
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
define   shared temp-table gds-list no-undo like ub.goods
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
define    shared  temp-table gds-list-hist no-undo
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
define   shared temp-table X-init_obj-list no-undo
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared  temp-table dc-list no-undo like ub.dis-card
  field to-del as logical
  field order-num as integer
  field fdec as decimal
  field fint as integer
  field flog as logical
  field fchar as character
  index pi  is primary unique d-card
  index cn      card-num
  index cli cli-type cli-code
  index host-dscnt  emitent-host-code status_ d-pcnt
  index host-type  emitent-host-code type d-pcnt
  index oi order-num
  .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared   temp-table dc-list-hist no-undo
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
define variable vss-include-info9 as character format "X(65)" no-undo
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
define variable new-doc  as logical no-undo.
define variable Prodtype as character no-undo.
define variable prodCode as integer no-undo.
define variable v-grp-code like ub.gds-grp.node-code no-undo .
define variable v-gds-code like ub.goods.gds-code no-undo .
define variable v-grp-name like ub.goods.grp-name no-undo .
define variable v-card-num-chr as character no-undo .
define variable ii-grp as integer no-undo .
define variable v-found as logical no-undo .
define variable v-count as integer   no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define SHARED temp-table dcards  no-undo
field date_         like ub.chk-doc.chk-date
field d-card        like ub.dis-card.d-card
field card-num-chr  as character
field card-num      like ub.dis-card.card-num
field sourced-card  like ub.dis-card.sourced-card
field main-card     like ub.dis-card.main-card
field first-card    like ub.dis-card.first-card
field first-main-card like ub.dis-card.first-main-card
field artic         like ub.goods.artic
field b-code        like ub.bar-code.b-code
field node-code     like ub.gds-prt.node-code
field prod-type     like ub.clients.obj-type
field prod-code     like ub.clients.obj-code
field sale-price    like ub.price-list.price-sale
field qnty          like ub.chk-gds.doc-qnty
field sum           as  decimal
field discount      as  decimal
field counter       as integer
field cli-type-code as character
INDEX pi            IS PRIMARY date_ d-card b-code ASCENDING
INDEX p1                       d-card date_ ASCENDING
index p3            cli-type-code card-num-chr d-card date_
index p4            first-card
index p5            main-card
index p6            first-main-card
.
DEFINE SHARED TEMP-TABLE times NO-UNDO
    FIELD time1 as integer
    FIELD time2 as integer
    FIELD times as char
    INDEX pi IS PRIMARY UNIQUE time1 time2
    INDEX ps times.
define temp-table obj-host no-undo
FIELd host-code like ub.sysconf.host-code
index pi is primary unique host-code.
define buffer buf_shop for ub.shop.
define buffer buf_store for ub.store.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_dcards for dcards.
define buffer X_dis-card for ub.dis-card.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_CHK-GDS for ub.chk-gds.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_payment for ub.payment.
define buffer buf_payment-attr for ub.payment-attr.
define stream MyWatch-strm.
if p-prodmode2 = "ONE" then do:
  if prodmode = 3 then do:
    assign
    ProdType = Substr(FixProdAttr, 1, 3)
    ProdCode = integer(substr(FixProdAttr, 4))
    .
  end.
  if prodmode = 2 then do:
    assign
    v-grp-code = integer(FixProdAttr)
    .
    run grplib-get-full-name  in this-procedure (
                                                input v-grp-code
                                                ,output v-grp-name).
  end.
  if prodmode = 5 then do:
    assign
    v-gds-code = integer(FixProdAttr)
    .
  end.
end.
for each obj-host:
  DELETE obj-host.
end.
create obj-host.
assign
obj-host.host-code = 0
.
FOR EACH obj-list :
  if obj-list.obj-type = 'маг':U then do:
    find first buf_shop no-lock where
              buf_shop.obj-code = obj-list.obj-code.
    find first obj-host no-lock where
                obj-host.host-code = buf_shop.host-code no-error .
    if not available obj-host then do:
      create
      obj-host.
      assign
      obj-host.host-code = buf_shop.host-code
      .
    end.
  end.
  else do:
    find first buf_store no-lock where
               buf_store.obj-code = obj-list.obj-code.
    find first obj-host no-lock where
               obj-host.host-code = buf_store.host-code no-error .
    if not available obj-host then do:
      create
      obj-host.
      assign
      obj-host.host-code = buf_store.host-code
      .
    end.
  end.
  if can-find( FIRST chk-doc WHERE
                      chk-doc.obj-type = obj-list.obj-type AND
                      chk-doc.obj-code = obj-list.obj-code AND
                      chk-doc.chk-date >= StartPoint AND
                      chk-doc.chk-date <= EndPoint AND
                      chk-doc.d-card <> "" AND
                      chk-doc.out-code <> ? ) then DO:
    _chk-doc:
    FOR EACH buf_chk-doc NO-LOCK WHERE
            buf_chk-doc.obj-type = obj-list.obj-type
        AND buf_chk-doc.obj-code = obj-list.obj-code
        AND buf_chk-doc.chk-date >= StartPoint
        AND buf_chk-doc.chk-date <= EndPoint
        AND buf_chk-doc.out-code <> ?
        and buf_chk-doc.d-card > '':U:
      if LOOKUP(string(buf_chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,69,101,106,108,169,196,114,115,116,117,111,112,136,113,101,106,108,208,2,3,4,5,7,43,44':U) > 0 then next _CHk-doc.
        if (dcardmode = "ONE" or dcardmode = "LIST") then
        do:
          if dcardmode = "ONE" then
          do:
            if not  buf_chk-doc.d-card = FixDCard then next _chk-doc.
          end.
          if dcardmode = "list" then
          do:
            find first dc-list WHERE
                       dc-list.d-card = buf_chk-doc.d-card no-error.
            if not available dc-list then next _chk-doc.
          end.
        end.
        PROCESS EVENTS .
        v-count = v-count + 1.
        if ( v-count  modulo 10 ) = 0
        AND  v-count >= 10 then
        do:
          run waitfram-show in this-procedure ( input substitute("&1&2 обработано чеков &3"
                                                                ,obj-list.obj-type
                                                                ,obj-list.obj-code
                                                                ,v-count)
                                              ).
        end.
        new-doc = yes.
        IF T-time and NOT can-find(FIRST times where
                                            times.time1  <= buf_chk-doc.chk-time AND
                                            times.time2 >= buf_chk-doc.chk-time) then do:
          NEXT _chk-doc.
        end.
        IF TotalOnly
        AND PRODMODE = 1 then do:
          FIND FIRST dcards WHERE dcards.d-card = buf_chk-doc.d-card NO-ERROR .
          if NOT available dcards then  do:
            CREATE dcards .
            assign
            dcards.date_  = buf_chk-doc.chk-date
            dcards.d-card = buf_chk-doc.d-card
            dcards.artic = ""
            dcards.b-code =  0
            dcards.prod-type = ""
            dcards.prod-code = 0
            dcards.qnty = 0
            dcards.node-code = 0
            .
            if t-legacy or t-subsid then do:
              find first buf_dis-card no-lock where
                          buf_dis-card.d-card = buf_chk-doc.d-card no-error .
              if available buf_dis-card then do:
                assign
                v-card-num-chr = (if t-legacy and t-subsid
                                  then buf_dis-card.first-main-card
                                  else (if t-legacy and not t-subsid
                                        then  buf_dis-card.first-card
                                        else  buf_dis-card.main-card
                                        )
                                  ).
                assign
                dcards.cli-type-code   = buf_dis-card.cli-type + string(buf_dis-card.cli-code)
                dcards.card-num        = buf_dis-card.card-num
                dcards.d-card          = buf_dis-card.d-card
                dcards.card-num-chr    = v-card-num-chr
                dcards.main-card       = buf_dis-card.main-card
                dcards.first-card      = buf_dis-card.first-card
                dcards.first-main-card = buf_dis-card.first-main-card
                .
              end.
            end.
            else do:
              if buf_chk-doc.cli-type = ?
              or buf_chk-doc.cli-code = ?
              or buf_chk-doc.cli-type = '':U
              or buf_chk-doc.cli-code = 0 then do:
                find first buf_dis-card no-lock where
                          buf_dis-card.d-card = buf_chk-doc.d-card no-error .
                if available buf_dis-card then do:
                  assign
                  dcards.cli-type-code = buf_dis-card.cli-type + string(buf_dis-card.cli-code)
                  .
                end.
              end.
              else do:
                assign
                dcards.cli-type-code = buf_chk-doc.cli-type + string(buf_chk-doc.cli-code)
                .
              end.
            end.
          end.
          assign
          dcards.qnty = 0
          dcards.sale-price = 0
          dcards.discount = dcards.discount + buf_chk-doc.discnt
          dcards.sum = dcards.sum + buf_chk-doc.tot-doc
          dcards.counter = (if new-doc then dcards.counter + 1 else dcards.counter ) .
          new-doc = no.
        end.
        else do:
          _chk:
          FOR EACH buf_chk-gds WHERE buf_chk-gds.doc-code = buf_chk-doc.doc-code,
              FIRST buf_bar-code No-LOCK WHERE
                    buf_bar-code.b-code = buf_chk-gds.b-code,
              FIRST buf_goods No-LOCK WHERE
                      buf_goods.gds-code = buf_bar-code.gds-code:
            if p-prodmode2 = "ONE" then do:
              case prodmode:
                when 3 then do:
                  if not ( buf_goods.prod-type = ProdType
                        AND buf_goods.prod-code = ProdCode) then next _chk.
                end.
                when 1 then do:
                end.
                when 2 then do:
                  if not buf_goods.grp-name begins v-grp-name then next _chk.
                end.
                when 5 then do:
                  if not buf_goods.gds-code = v-gds-code then next _chk.
                end.
              end case.
            end.
            if buf_chk-gds.write-off-code <> ?
            and buf_chk-gds.write-off-code > 0 then NEXT _CHk.
            if p-prodmode2 = "LIST" then do:
              if prodmode = 3 then do:
                IF NOT can-find(first g#cli No-LOCK where
                                      g#cli.obj-type = buf_goods.prod-type AND
                                      g#cli.obj-code = buf_goods.prod-code) then NEXT _chk.
              end.
              if prodmode = 2 then do:
                assign
                v-grp-name = ""
                v-found = no
                .
                _ii-grp:
                do ii-grp = 1 to num-entries(buf_goods.grp-name, chr(47)) - 1:
                  assign
                  v-grp-name = v-grp-name + entry(ii-grp, buf_goods.grp-name, chr(47)) + chr(47).
                  IF can-find(first tmp#grp No-LOCK where
                                    tmp#grp.grp-name = v-grp-name) then do:
                    assign
                    v-found = yes
                    .
                    leave _ii-grp.
                  end.
                end.
                if not v-found then do:
                  next _chk.
                end.
              end.
              if prodmode = 4 then do:
                IF NOT can-find(first gds-list No-LOCK where
                                    gds-list.gds-code = buf_goods.gds-code) then NEXT _chk.
                end.
              end.
              FIND FIRST dcards WHERE
                        dcards.date_ = buf_chk-doc.chk-date
                    AND dcards.d-card = buf_chk-doc.d-card
                    AND dcards.b-code = buf_bar-code.b-code
                    AND dcards.sale-price = buf_chk-gds.price-base  NO-ERROR .
              if NOT available dcards then do:
                CREATE dcards .
                assign
                dcards.date_  = buf_chk-doc.chk-date
                dcards.d-card = buf_chk-doc.d-card
                dcards.artic = buf_goods.artic
                dcards.b-code = buf_bar-code.b-code
                dcards.prod-type = buf_goods.prod-type
                dcards.prod-code = buf_goods.prod-code
                dcards.qnty = 0
                dcards.node-code = buf_bar-code.node-code
                .
                if t-legacy or t-subsid then do:
                  find first buf_dis-card no-lock where
                              buf_dis-card.d-card = buf_chk-doc.d-card no-error .
                  assign
                  v-card-num-chr = (if t-legacy and t-subsid
                                    then buf_dis-card.first-main-card
                                    else (if t-legacy and not t-subsid
                                          then  buf_dis-card.first-card
                                          else  buf_dis-card.main-card
                                          )
                                    ).
                  assign
                  dcards.d-card          = buf_dis-card.d-card
                  dcards.card-num-chr    = v-card-num-chr
                  dcards.first-card      = buf_dis-card.first-card
                  dcards.main-card       = buf_dis-card.main-card
                  dcards.first-main-card = buf_dis-card.first-main-card
                  dcards.cli-type-code   = buf_dis-card.cli-type + string(buf_dis-card.cli-code)
                  dcards.card-num        = buf_dis-card.card-num
                  .
                end.
                else do:
                  if buf_chk-doc.cli-type = ?
                  or buf_chk-doc.cli-code = ?
                  or buf_chk-doc.cli-type = '':U
                  or buf_chk-doc.cli-code = 0 then do:
                    find first buf_dis-card no-lock where
                              buf_dis-card.d-card = buf_chk-doc.d-card no-error .
                    if available buf_dis-card then do:
                      assign
                      dcards.cli-type-code = buf_dis-card.cli-type + string(buf_dis-card.cli-code)
                      .
                    end.
                  end.
                  else do:
                    assign
                    dcards.cli-type-code = buf_chk-doc.cli-type + string(buf_chk-doc.cli-code)
                    .
                  end.
                end.
              end.
              assign
              dcards.qnty = dcards.qnty + buf_chk-gds.doc-qnty
              dcards.sale-price = buf_chk-gds.price-base
              dcards.discount = dcards.discount + ( buf_chk-gds.doc-qnty *
                      ( buf_chk-gds.discnt + ( dcards.sale-price - buf_chk-gds.price-base ) ) )
              dcards.sum = dcards.sum + ( buf_chk-gds.doc-qnty * dcards.sale-price )
              dcards.counter = (if new-doc then dcards.counter + 1 else dcards.counter ) .
              new-doc = no.
          end.
        END.
      END.
   END.
END.
if T-zeros then do:
  CASE dcardmode :
    when "LIST":U then do:
      FOR EACH dc-list no-LOCK:
        if not can-find(first dcards no-lock where
                              dcards.d-card = dc-list.d-card) then do:
          CREATE dcards .
          assign
          dcards.date_  = 01/01/1990
          dcards.d-card = dc-list.d-card
          dcards.artic = "":U
          dcards.b-code = 0
          dcards.prod-type = "":U
          dcards.prod-code = 0
          dcards.qnty = 0
          dcards.node-code = 0
          dcards.cli-type-code = dc-list.cli-type + string(dc-list.cli-code)
          dcards.card-num  = dc-list.card-num
          .
          if t-legacy or t-subsid then do:
            assign
            v-card-num-chr = (if t-legacy and t-subsid
                              then dc-list.first-main-card
                              else (if t-legacy and not t-subsid
                                    then  dc-list.first-card
                                    else  dc-list.main-card
                                    )
                              ).
            assign
            dcards.d-card        = dc-list.d-card
            dcards.card-num-chr  = v-card-num-chr
            dcards.first-card    = dc-list.first-card
            dcards.main-card     = dc-list.main-card
            dcards.first-main-card = dc-list.first-main-card
            dcards.cli-type-code = dc-list.cli-type + string(dc-list.cli-code)
            .
          end.
        end.
      END.
    end.
    when "ALL":U then do:
      for each X_dis-card no-lock,
          first obj-host no-lock where
                obj-host.host-code = X_dis-card.emitent-host-code:
        if not can-find(first dcards no-lock where
                              dcards.d-card = X_dis-card.d-card) then do:
          CREATE dcards .
          assign
          dcards.date_  = 01/01/1990
          dcards.d-card = X_dis-card.d-card
          dcards.artic = "":U
          dcards.b-code = 0
          dcards.prod-type = "":U
          dcards.prod-code = 0
          dcards.qnty = 0
          dcards.node-code = 0
          dcards.cli-type-code = X_dis-card.cli-type + string(X_dis-card.cli-code)
          dcards.card-num  = X_dis-card.card-num
          .
          if t-legacy then do:
            assign
            v-card-num-chr = (if t-legacy and t-subsid
                              then X_dis-card.first-main-card
                              else (if t-legacy and not t-subsid
                                    then  X_dis-card.first-card
                                    else  X_dis-card.main-card
                                    )
                              ).
            assign
            dcards.d-card          = X_dis-card.d-card
            dcards.card-num-chr    = v-card-num-chr
            dcards.first-card      = X_dis-card.first-card
            dcards.main-card       = X_dis-card.main-card
            dcards.first-main-card = X_dis-card.first-main-card
            dcards.cli-type-code = X_dis-card.cli-type + string(X_dis-card.cli-code)
            .
          end.
        end.
        else do:
        end.
      end.
    end.
    when "ONE":U then do:
      if not can-find (first dcards no-lock where
                              dcards.d-card = FIXdcard) then do:
          CREATE dcards .
          assign
          dcards.date_  = 01/01/1990
          dcards.d-card = X_dis-card.d-card
          dcards.artic = "":U
          dcards.b-code = 0
          dcards.prod-type = "":U
          dcards.prod-code = 0
          dcards.qnty = 0
          dcards.node-code = 0
          dcards.cli-type-code = X_dis-card.cli-type + string(X_dis-card.cli-code)
          dcards.card-num  = X_dis-card.card-num
          .
        if t-legacy then do:
          assign
          v-card-num-chr = (if t-legacy and t-subsid
                            then X_dis-card.first-main-card
                            else (if t-legacy and not t-subsid
                                  then  X_dis-card.first-card
                                  else  X_dis-card.main-card
                                  )).
          assign
          dcards.d-card          = X_dis-card.d-card
          dcards.card-num-chr    = v-card-num-chr
          dcards.main-card       = X_dis-card.main-card
          dcards.first-main-card = X_dis-card.first-main-card
          dcards.first-card      = X_dis-card.first-card
          dcards.cli-type-code   = X_dis-card.cli-type + string(X_dis-card.cli-code)
          .
        end.
      end.
    end.
  END CASE.
end.
if t-imp then
FOR EACH obj-host
  WHERE obj-host.host-code > 0
:
  _chk-payment:
  FOR EACH buf_payment no-lock
    where buf_payment.host-code = obj-host.host-code
      AND buf_payment.fact-date >= StartPoint
      AND buf_payment.fact-date <= EndPoint
      AND buf_payment.d-card > ""
      and buf_payment.status_ = 'факт':U
      AND buf_payment.source-type = 'касс':U + chr(44) + 'import':U
  :
    do:
      if dcardmode = "list" then do:
        find first dc-list WHERE
                    dc-list.d-card = buf_payment.d-card no-error.
        if not available dc-list then next _chk-payment.
      end.
    end.
    for each buf_payment-attr no-lock
      where buf_payment-attr.pmnt-code = buf_payment.pmnt-code
        and buf_payment-attr.attr-code = "obj"
    :
      if num-entries( buf_payment-attr.attr-value ) < 2 then
        leave.
      if not can-find( first obj-list no-lock
        where obj-list.obj-type = entry( 1, buf_payment-attr.attr-value )
          and obj-list.obj-code = int( entry( 2, buf_payment-attr.attr-value ) )
                     )
      then next _chk-payment.
    end.
    PROCESS EVENTS .
    v-count = v-count + 1.
    if ( v-count  modulo 10 ) = 0
    AND  v-count >= 10 then do:
      run waitfram-show in this-procedure  ( input substitute("&1 обработано чеков &2"
                                                            ,obj-host.host-code
                                                            ,v-count)
                                          ).
    end.
    new-doc = yes.
    find first buf_dis-card no-lock where
      buf_dis-card.d-card = buf_payment.d-card no-error .
    if t-legacy or t-subsid then do:
      if available buf_dis-card then do:
        assign
        v-card-num-chr = (if t-legacy and t-subsid
                          then buf_dis-card.first-main-card
                          else (if t-legacy and not t-subsid
                                then  buf_dis-card.first-card
                                else  buf_dis-card.main-card
                                )
                          ).
      end.
    end.
    IF TotalOnly
    then do:
      FIND FIRST dcards WHERE dcards.d-card = buf_payment.d-card NO-ERROR .
      if NOT available dcards then  do:
        CREATE dcards .
        assign
          dcards.date_  = buf_payment.fact-date
          dcards.d-card = buf_payment.d-card
          dcards.artic = "Импорт из ВС"
          dcards.b-code =  0
          dcards.prod-type = ""
          dcards.prod-code = 0
          dcards.qnty = 0
          dcards.node-code = 0
        .
        if t-legacy or t-subsid then do:
          if available buf_dis-card then do:
            assign
              dcards.cli-type-code   = buf_dis-card.cli-type + string(buf_dis-card.cli-code)
              dcards.card-num        = buf_dis-card.card-num
              dcards.d-card          = buf_dis-card.d-card
              dcards.card-num-chr    = v-card-num-chr
              dcards.main-card       = buf_dis-card.main-card
              dcards.first-card      = buf_dis-card.first-card
              dcards.first-main-card = buf_dis-card.first-main-card
            .
          end.
        end.
        else do:
          if available buf_dis-card then do:
            assign
              dcards.cli-type-code = buf_dis-card.cli-type + string(buf_dis-card.cli-code)
            .
          end.
          else do:
            assign
              dcards.cli-type-code = buf_payment.cli-type + string(buf_payment.cli-code)
            .
          end.
        end.
      end.
      assign
        dcards.qnty = 0
        dcards.sale-price = 0
        dcards.sum = dcards.sum + buf_payment.tot-cli
        dcards.counter = (if new-doc then dcards.counter + 1 else dcards.counter )
      .
      new-doc = no.
    end.
    else do:
      FIND FIRST dcards
        WHERE dcards.date_ = buf_payment.fact-date
          AND dcards.d-card = buf_payment.d-card
          AND dcards.b-code = 0
          AND dcards.sale-price = 0
        NO-ERROR .
      if NOT available dcards then do:
        CREATE dcards .
        assign
          dcards.date_  = buf_payment.fact-date
          dcards.d-card = buf_payment.d-card
          dcards.artic = "Импорт из ВС"
          dcards.b-code = 0
          dcards.qnty = 0
        .
        if t-legacy or t-subsid then do:
          assign
            dcards.d-card          = buf_dis-card.d-card
            dcards.card-num-chr    = v-card-num-chr
            dcards.first-card      = buf_dis-card.first-card
            dcards.main-card       = buf_dis-card.main-card
            dcards.first-main-card = buf_dis-card.first-main-card
            dcards.cli-type-code   = buf_dis-card.cli-type + string(buf_dis-card.cli-code)
            dcards.card-num        = buf_dis-card.card-num
          .
        end.
        else do:
          if available buf_dis-card then do:
            assign
              dcards.cli-type-code = buf_dis-card.cli-type + string(buf_dis-card.cli-code)
            .
          end.
          else do:
            assign
              dcards.cli-type-code = buf_payment.cli-type + string(buf_payment.cli-code)
            .
          end.
        end.
      end.
      assign
        dcards.qnty = 0
        dcards.sale-price = 0
        dcards.sum = dcards.sum + buf_payment.tot-cli
        dcards.counter = (if new-doc then dcards.counter + 1 else dcards.counter )
      .
      new-doc = no.
    end.
  END.
END.
run waitfram-hide in this-procedure .
procedure my-watch-table:
    define variable v-full-file-name as character no-undo.
    define variable v-message as character no-undo.
    define variable v-table-handle as handle no-undo.
    define variable v-cnt-field as integer no-undo.
    define variable v-list-field-name as character no-undo.
    define variable v-list-field-label as character no-undo.
    define variable v-list-field-type as character no-undo.
    define variable v-ii as integer no-undo.
    define buffer dc-list for dc-list.
    v-table-handle = buffer dc-list:handle.
    v-cnt-field = v-table-handle:num-fields.
    do v-ii = 1 to v-cnt-field:
        v-list-field-name =
            (if v-list-field-name <> "" then
               v-list-field-name + "$" + v-table-handle:buffer-field(v-ii):name
            else
                v-table-handle:buffer-field(v-ii):name).
        v-list-field-label =
            (if v-list-field-label <> "" then
               v-list-field-label + "$" + v-table-handle:buffer-field(v-ii):label
            else
                v-table-handle:buffer-field(v-ii):label).
        v-list-field-type =
            (if v-list-field-type <> "" then
               v-list-field-type + "$" + v-table-handle:buffer-field(v-ii):data-type
            else
                v-table-handle:buffer-field(v-ii):data-type).
    end.
    v-full-file-name = "C:\work15_0\my-watch_dc-list.txt".
    if search(v-full-file-name) = ? then
        do:
            message "Не найден файл отчёта: " v-full-file-name view-as alert-box error.
        end.
    output stream MyWatch-strm to value(v-full-file-name)   convert target "utf-8".
        put stream MyWatch-strm unformatted
            today format "99.99.9999" " " string(time, "HH:MM") " " "Исследуемая таблица: " "dc-list" "." skip
            v-list-field-label skip
            v-list-field-name skip
            v-list-field-type skip
        .
        if not can-find(first dc-list) then
        do:
            v-message = "Исследуемая таблица dc-list пуста!".
            put stream MyWatch-strm unformatted
                v-message
            .
            message "My-watch-table: " v-message view-as alert-box information.
        end.
            for each  dc-list no-lock:
                export stream MyWatch-strm delimiter "$"  dc-list.
            end.
    output stream MyWatch-strm close.
end procedure.
