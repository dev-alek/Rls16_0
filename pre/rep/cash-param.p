block-level on error undo, throw.
define variable vss-revision as character no-undo init "$Revision: 2d76561e6a10, 3381, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2023/05/31 09:28:12 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cash-param.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/cash-param.p $":U .
define variable vss-description as character no-undo init "Отчет по анализу параметров АРМ Кассира".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
 define shared temp-table tmprecid
    field Frecid as recid init ?
    field fnum as character
    field fTable as character
 index num  fnum Frecid
 index itable is primary unique fTable Frecid
 .
define variable fSelect as logical no-undo format "*/" column-label "".
function isSelect return logical
    (iBuffer as handle  ):
    define buffer tmprecid for tmprecid.
    if iBuffer:available
    then
       find first tmprecid where tmprecid.fTable = iBuffer:TABLE
                             and tmprecid.Frecid = iBuffer:recid
       no-lock no-error.
    return available tmprecid.
 end.
function setSelect return logical
    (iBuffer as handle  ):
    define buffer tmprecid for tmprecid.
    if iBuffer:available
    then do:
       find first tmprecid where tmprecid.fTable = iBuffer:TABLE
                             and tmprecid.Frecid = iBuffer:recid
       no-lock no-error.
       if available tmprecid
       then
          delete tmprecid.
       else do:
          create tmprecid.
          assign
             tmprecid.fTable = iBuffer:TABLE
             tmprecid.Frecid = iBuffer:recid
          .
       end.
    end.
    return available tmprecid.
 end.
 procedure rid-keep :
     run gbl/rid-keep.p (input table tmprecid) no-error.
 end.
 procedure rid-rest :
      run gbl/rid-rest.p (output table tmprecid) no-error.
 end.
 define  temp-table cash-list like ub.cash-desk
 field deviceCode as character
 .
FUNCTION BinaryXOR RETURNS INT64(INPUT intOperand1 AS INT64,
                                 INPUT intOperand2 AS INT64)
                                 forward .
FUNCTION ShiftRight RETURNS INT64(INPUT in_Operand_A AS INT64,
                                  INPUT in_Operand_B AS INTEGER)
                                  forward .
FUNCTION BinaryAND RETURNS INTEGER (INPUT in_Operand_A AS INT64,
                                    INPUT in_Operand_B AS INT64)
                                    forward .
FUNCTION intToHex RETURNS CHARACTER (i_iint AS INT64) forward .
FUNCTION crc32Table RETURNS INT64 EXTENT 256  () forward .
FUNCTION CRC32 RETURNS INT64 (INPUT mpData AS MEMPTR) forward .
FUNCTION BinaryXOR RETURNS INT64
(INPUT intOperand1 AS INT64,
 INPUT intOperand2 AS INT64):
    DEFINE VARIABLE iByteLoop  AS INTEGER NO-UNDO.
    DEFINE VARIABLE iXOResult  AS INT64 NO-UNDO.
    DEFINE VARIABLE lFirstBit  AS LOGICAL NO-UNDO.
    DEFINE VARIABLE lSecondBit AS LOGICAL NO-UNDO.
    iXOResult = 0.
    DO iByteLoop = 1 TO 64:
        ASSIGN
        lFirstBit  = LOGICAL(GET-BITS(intOperand1,iByteLoop  ,1))
        lSecondBit = LOGICAL(GET-BITS(intOperand2,iByteLoop , 1)).
        IF (lFirstBit  AND NOT lSecondBit) OR
           (lSecondBit AND NOT lFirstBit) THEN
            iXOResult = iXOResult + EXP(2, iByteLoop - 1).
    END.
    RETURN iXOResult.
END .
FUNCTION ShiftRight RETURNS INT64
(INPUT in_Operand_A AS INT64,
 INPUT in_Operand_B AS INTEGER):
   RETURN INT64( TRUNCATE( in_Operand_A / EXP(2,in_Operand_B), 0 ) ).
END .
FUNCTION BinaryAND RETURNS INTEGER
(INPUT in_Operand_A AS INT64,
 INPUT in_Operand_B AS INT64):
   DEFINE VARIABLE in_cbit     AS INTEGER     NO-UNDO.
   DEFINE VARIABLE in_result   AS INT64     NO-UNDO.
   DO in_cbit = 1 TO 64:
      IF LOGICAL( GET-BITS( in_Operand_A, in_cbit, 1 ) ) AND
         LOGICAL( GET-BITS( in_Operand_B, in_cbit, 1 ) )
      THEN
         PUT-BITS( in_result, in_cbit, 1 ) = 1.
  END.
  RETURN in_result.
END .
FUNCTION intToHex RETURNS CHARACTER
(i_iint AS INT64):
   DEF VAR chex  AS CHAR NO-UNDO.
   DEF VAR rbyte AS RAW  NO-UNDO.
   DO WHILE i_iint > 0:
      PUT-BYTE( rbyte, 1 ) = i_iint MODULO 256.
      chex = STRING( HEX-ENCODE( rbyte ) ) + chex.
      i_iint = TRUNCATE( i_iint / 256, 0 ).
   END.
   RETURN chex.
END .
FUNCTION crc32Table RETURNS INT64 EXTENT 256
():
    DEFINE VARIABLE crc32_tab       AS INT64     NO-UNDO EXTENT 256 INITIAL
        [0x00000000, 0x77073096, 0xEE0E612C, 0x990951BA, 0x076DC419, 0x706AF48F,
        0xE963A535, 0x9E6495A3, 0x0EDB8832, 0x79DCB8A4, 0xE0D5E91E, 0x97D2D988,
        0x09B64C2B, 0x7EB17CBD, 0xE7B82D07, 0x90BF1D91, 0x1DB71064, 0x6AB020F2,
        0xF3B97148, 0x84BE41DE, 0x1ADAD47D, 0x6DDDE4EB, 0xF4D4B551, 0x83D385C7,
        0x136C9856, 0x646BA8C0, 0xFD62F97A, 0x8A65C9EC, 0x14015C4F, 0x63066CD9,
        0xFA0F3D63, 0x8D080DF5, 0x3B6E20C8, 0x4C69105E, 0xD56041E4, 0xA2677172,
        0x3C03E4D1, 0x4B04D447, 0xD20D85FD, 0xA50AB56B, 0x35B5A8FA, 0x42B2986C,
        0xDBBBC9D6, 0xACBCF940, 0x32D86CE3, 0x45DF5C75, 0xDCD60DCF, 0xABD13D59,
        0x26D930AC, 0x51DE003A, 0xC8D75180, 0xBFD06116, 0x21B4F4B5, 0x56B3C423,
        0xCFBA9599, 0xB8BDA50F, 0x2802B89E, 0x5F058808, 0xC60CD9B2, 0xB10BE924,
        0x2F6F7C87, 0x58684C11, 0xC1611DAB, 0xB6662D3D, 0x76DC4190, 0x01DB7106,
        0x98D220BC, 0xEFD5102A, 0x71B18589, 0x06B6B51F, 0x9FBFE4A5, 0xE8B8D433,
        0x7807C9A2, 0x0F00F934, 0x9609A88E, 0xE10E9818, 0x7F6A0DBB, 0x086D3D2D,
        0x91646C97, 0xE6635C01, 0x6B6B51F4, 0x1C6C6162, 0x856530D8, 0xF262004E,
        0x6C0695ED, 0x1B01A57B, 0x8208F4C1, 0xF50FC457, 0x65B0D9C6, 0x12B7E950,
        0x8BBEB8EA, 0xFCB9887C, 0x62DD1DDF, 0x15DA2D49, 0x8CD37CF3, 0xFBD44C65,
        0x4DB26158, 0x3AB551CE, 0xA3BC0074, 0xD4BB30E2, 0x4ADFA541, 0x3DD895D7,
        0xA4D1C46D, 0xD3D6F4FB, 0x4369E96A, 0x346ED9FC, 0xAD678846, 0xDA60B8D0,
        0x44042D73, 0x33031DE5, 0xAA0A4C5F, 0xDD0D7CC9, 0x5005713C, 0x270241AA,
        0xBE0B1010, 0xC90C2086, 0x5768B525, 0x206F85B3, 0xB966D409, 0xCE61E49F,
        0x5EDEF90E, 0x29D9C998, 0xB0D09822, 0xC7D7A8B4, 0x59B33D17, 0x2EB40D81,
        0xB7BD5C3B, 0xC0BA6CAD, 0xEDB88320, 0x9ABFB3B6, 0x03B6E20C, 0x74B1D29A,
        0xEAD54739, 0x9DD277AF, 0x04DB2615, 0x73DC1683, 0xE3630B12, 0x94643B84,
        0x0D6D6A3E, 0x7A6A5AA8, 0xE40ECF0B, 0x9309FF9D, 0x0A00AE27, 0x7D079EB1,
        0xF00F9344, 0x8708A3D2, 0x1E01F268, 0x6906C2FE, 0xF762575D, 0x806567CB,
        0x196C3671, 0x6E6B06E7, 0xFED41B76, 0x89D32BE0, 0x10DA7A5A, 0x67DD4ACC,
        0xF9B9DF6F, 0x8EBEEFF9, 0x17B7BE43, 0x60B08ED5, 0xD6D6A3E8, 0xA1D1937E,
        0x38D8C2C4, 0x4FDFF252, 0xD1BB67F1, 0xA6BC5767, 0x3FB506DD, 0x48B2364B,
        0xD80D2BDA, 0xAF0A1B4C, 0x36034AF6, 0x41047A60, 0xDF60EFC3, 0xA867DF55,
        0x316E8EEF, 0x4669BE79, 0xCB61B38C, 0xBC66831A, 0x256FD2A0, 0x5268E236,
        0xCC0C7795, 0xBB0B4703, 0x220216B9, 0x5505262F, 0xC5BA3BBE, 0xB2BD0B28,
        0x2BB45A92, 0x5CB36A04, 0xC2D7FFA7, 0xB5D0CF31, 0x2CD99E8B, 0x5BDEAE1D,
        0x9B64C2B0, 0xEC63F226, 0x756AA39C, 0x026D930A, 0x9C0906A9, 0xEB0E363F,
        0x72076785, 0x05005713, 0x95BF4A82, 0xE2B87A14, 0x7BB12BAE, 0x0CB61B38,
        0x92D28E9B, 0xE5D5BE0D, 0x7CDCEFB7, 0x0BDBDF21, 0x86D3D2D4, 0xF1D4E242,
        0x68DDB3F8, 0x1FDA836E, 0x81BE16CD, 0xF6B9265B, 0x6FB077E1, 0x18B74777,
        0x88085AE6, 0xFF0F6A70, 0x66063BCA, 0x11010B5C, 0x8F659EFF, 0xF862AE69,
        0x616BFFD3, 0x166CCF45, 0xA00AE278, 0xD70DD2EE, 0x4E048354, 0x3903B3C2,
        0xA7672661, 0xD06016F7, 0x4969474D, 0x3E6E77DB, 0xAED16A4A, 0xD9D65ADC,
        0x40DF0B66, 0x37D83BF0, 0xA9BCAE53, 0xDEBB9EC5, 0x47B2CF7F, 0x30B5FFE9,
        0xBDBDF21C, 0xCABAC28A, 0x53B39330, 0x24B4A3A6, 0xBAD03605, 0xCDD70693,
        0x54DE5729, 0x23D967BF, 0xB3667A2E, 0xC4614AB8, 0x5D681B02, 0x2A6F2B94,
        0xB40BBE37, 0xC30C8EA1, 0x5A05DF1B, 0x2D02EF8D].
    RETURN crc32_tab.
END .
FUNCTION CRC32 RETURNS INT64
(INPUT mpData AS MEMPTR):
    DEFINE VARIABLE IN_BYtes_Size   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE in_byte         AS INTEGER   NO-UNDO.
    DEFINE VARIABLE crc_value       AS INT64     NO-UNDO.
    DEFINE VARIABLE tmp             AS INT64     NO-UNDO.
    DEFINE VARIABLE crc32_tab       AS INT64     NO-UNDO EXTENT 256.
    DEFINE VARIABLE in_loop         AS INTEGER     NO-UNDO.
    crc32_tab = crc32Table().
    crc_value = 0xffffffff.
    In_Bytes_Size = GET-SIZE(mpData).
    DO in_loop = 1 TO In_Bytes_Size:
        tmp = BinaryXOR(crc_value, GET-BYTE(mpData,in_loop )).
        crc_value = BinaryXOR( ShiftRight(crc_value, 8), crc32_tab[BinaryAND(tmp,0x00ff) + 1 ] ).
    END.
    crc_value = BinaryXOR(crc_value, 0xffffffff).
    RETURN crc_value.
END .
define temp-table tt-code like code.
function getCashparamHash returns character ():
    define variable exp as ibs.th.bge.xmlimpexp no-undo.
    define variable hQuery   as handle  no-undo .
    define buffer Buf_code for tt-code.
    define buffer     code for    code.
    FOR EACH code where code.parent begins 'cash-param'
                    and num-entries(code.parent,chr(4)) eq 4
    no-lock:
       create Buf_code.
       buffer-copy code except export_ nwsgbd procview procedit to Buf_code.
    end.
    create query hQuery.
    hQuery:set-buffers(buffer Buf_code :HANDLE).
    hQuery:query-prepare("FOR EACH Buf_code").
    hQuery:query-open ().
    exp = new ibs.th.bge.xmlimpexp ().
    exp:updatetableforxml(hQuery).
    delete object hQuery.
    FOR EACH buf_code:
       delete buf_code.
    end.
    define variable vxmlCode as character  no-undo.
    define variable v-md5-signature as character no-undo.
    exp:xmldom-save  ( "cashparammd5.xml" ).
    vxmlCode = search("cashparammd5.xml").
    run gbl/md5.p (
          input  vxmlCode
         ,output v-md5-signature
         ) .
    os-delete value (vxmlCode).
    delete object exp.
    return encode(v-md5-signature + "sysadm" ) + string(index(encode(string(v-md5-signature)), "k"))
  .
end.
function getCashParamHashDb returns character (idb as int):
   define buffer code for ub.code.
   find first code where code.parent eq "CashParamHash"
                     and code.code   eq  string(idb)
   no-lock no-error.
   return if available code then Code.CodeValue else ?.
end.
procedure saveCashParHash:
   define input  parameter iDb as integer no-undo.
   define buffer code for ub.code.
   find first code where code.parent eq ""
                     and code.code   eq "CashParamHash"
   no-lock no-error.
   if not available code
   then do:
      create code.
      assign
         Code.parent   = ""
         Code.code     = "CashParamHash"
         Code.CodeName = "Конрольная сумма Эталонных параметров для кассы"
      .
   end.
   find first code where code.parent eq "CashParamHash"
                     and code.code   eq  string(idb)
   exclusive-lock no-error.
   if not available code
   then do:
      create Code.
      assign
         code.parent = "CashParamHash"
         code.code   =  string(idb)
         Code.nwsubd = yes
      .
   end.
   Code.CodeName  = string(now).
   Code.CodeValue = getCashparamHash().
end.
FUNCTION getColor RETURNS CHARACTER
  ( isflag as char, istatus as int, isdiff as logical  )  FORWARD.
FUNCTION getColorKey RETURNS CHARACTER
  ( isflag as char, istatus as int, isdiff as logical  )  FORWARD.
FUNCTION getColorText RETURNS CHARACTER
  ( iscolor as char  )  FORWARD.
            define temp-table tt-param
              field CashNum         as integer
              field ParamGroup      as character case-sensitive
              field ParamName       as character case-sensitive
              field KeyboardNameDop as character
              field Device          as character
              field DeviceName      as character
              field DateTime        as decimal
              field ParamSection    as character
              field SectionName     as character
              field EtalonValue     as character
              field CurrentValue    as character
              field KeyboardName    as character
              field obj-code        as integer
              field obj-type        as character
              field obj-name        as character
              field flag            as character
              field diff            as logical
              field status_         as integer
              index pi is primary unique obj-code obj-type ParamGroup Device ParamSection CashNum ParamName KeyboardNameDop
              .
            define temp-table tt-choose-code
              field ParamName as character
              field section   as character
              field device    as character
              field group_    as character
              .
            define stream OutStr-html.
            define input  parameter parparentproc as handle no-undo.
            define input parameter parDesk as character no-undo .
            define input parameter parParam as character no-undo .
            define input parameter parSource as character no-undo .
            define input parameter table for tmprecid .
            define input parameter table for cash-list .
            define buffer buf_param for tt-param .
            define buffer buf_code  for ub.Code .
            define variable v-report-name-html-list as character no-undo .
            define variable v-sort                  as character no-undo .
            v-report-name-html-list = "CashPar_" + string(today,"99999999") + "_" + replace (string(time,"HH:MM"),":","") + ".html".
function fConvetDateTime returns character
  (input iTStamp as dec):
  define variable vDateTime as datetime no-undo.
  define variable vDate     as date     no-undo.
  define variable vDays     as int64    no-undo.
  define variable vSec      as integer  no-undo.
  vDays = truncate(int64(iTStamp) / 3600 / 24, 0).
  vDate = date("01/01/1970") + vDays.
  vSec = (int64(iTStamp) - vDays * 3600 * 24).
  return string(vDate,"99/99/9999") + " " + string(vSec, "HH:MM:SS").
end function.
            output stream OutStr-html to value(v-report-name-html-list) convert target 'UTF-8' .
            put stream OutStr-html unformatted
"<!DOCTYPE HTML>" skip
' <html>' skip
'  <head>' skip
'   <meta charset="utf-8">' skip
'    <style type="text/css">' skip
'      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
'      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
'      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black;' + chr(125) skip
'   </style>' skip
'  </head>' skip
              '<body>' skip
              '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
              '<thead>' skip
              ' <tr class="set_columns">' skip
              ' <td style="width:80px"></td>' skip
              ' <td style="width:100px"></td>' skip
              ' <td style="width:80px"></td>' skip
              ' <td style="width:80px"></td>' skip
              ' <td style="width:80px"></td>' skip
              ' <td style="width:150px"></td>' skip
              ' <td style="width:100px"></td>' skip
              ' <td style="width:100px"></td>' skip
              ' <td style="width:100px"></td>' skip
              ' <td style="width:100px"></td>' skip
              ' <td style="width:150px"></td>' skip
              '</tr>' skip .
            define buffer code-section        for ub.code.
            define buffer code-group          for ub.code.
            define buffer code-device         for ub.code.
            define buffer code-param          for ub.code.
            define buffer buf_cash-param-hist for ub.cash-param-hist.
            define buffer clients             for ub.clients.
            define buffer buf_choose-code     for tt-choose-code .
            define variable v-attr-value   as character no-undo.
            define variable v-attr-type    as character no-undo.
            define variable vDeviceKind    as character no-undo.
            define variable cb-device-kind as integer   no-undo.
            define variable mdevice        as class     ibs.th.str.cash.CashDevice
              no-undo.
            define variable msection       as class     ibs.th.str.cash.CashSection
              no-undo.
            mdevice = new ibs.th.str.cash.CashDevice().
            msection = new ibs.th.str.cash.CashSection().
            if parParam = "choose" then
            do:
              for each tmprecid no-lock where tmprecid.fTable = "code":
                for first ub.Code no-lock where recid(ub.Code) = tmprecid.Frecid:
                  create tt-choose-code.
                  tt-choose-code.device = entry(2,ub.Code.parent,chr(4)) .
                  tt-choose-code.section = entry(3,ub.Code.parent,chr(4)) .
                  tt-choose-code.group_ = entry(4,ub.Code.parent,chr(4)) no-error.
                  if tt-choose-code.group_ = "" then tt-choose-code.group_ = ub.Code.code .
                  else tt-choose-code.ParamName = ub.Code.code .
                end.
              end.
            end.
            for each obj-list:
              for each cash-list no-lock where cash-list.obj-code = obj-list.obj-code:
                for each buf_cash-param-hist where buf_cash-param-hist.obj-code = obj-list.obj-code and
                  buf_cash-param-hist.obj-type = obj-list.obj-type and
                  buf_cash-param-hist.cash-num = cash-list.cash-num and
                  buf_cash-param-hist.device = integer(cash-list.deviceCode):
                  if parDesk <> "-1" then
                    if lookup(string(buf_cash-param-hist.device), parDesk, ",") = 0 then next .
                  if parParam = "choose" then
                  do:
                    find first tt-choose-code where tt-choose-code.section = buf_cash-param-hist.param_section and
                      tt-choose-code.device = string(buf_cash-param-hist.device) and
                      tt-choose-code.group_ = string(buf_cash-param-hist.param_group) no-error .
                    if available tt-choose-code then
                    do:
                      if tt-choose-code.ParamName <> "" then
                      do:
                        find first buf_choose-code where buf_choose-code.section = buf_cash-param-hist.param_section and
                          buf_choose-code.device = string(buf_cash-param-hist.device) and
                          buf_choose-code.group_ = string(buf_cash-param-hist.param_group) and
                          buf_choose-code.ParamName = string(buf_cash-param-hist.param_name) no-error .
                        if not available (buf_choose-code) then next .
                      end.
                    end.
                    else next .
                  end.
                  create tt-param .
                  assign
                    tt-param.obj-code        = buf_cash-param-hist.obj-code
                    tt-param.obj-type        = buf_cash-param-hist.obj-type
                    tt-param.CashNum         = buf_cash-param-hist.cash-num
                    tt-param.ParamGroup      = buf_cash-param-hist.param_group
                    tt-param.ParamName       = buf_cash-param-hist.param_name
                    tt-param.CurrentValue    = buf_cash-param-hist.param_value
                    tt-param.Device          = string(buf_cash-param-hist.device)
                    tt-param.ParamSection    = buf_cash-param-hist.param_section
                    tt-param.KeyboardName    = buf_cash-param-hist.param_value_dop
                    tt-param.flag            = "current"
                    tt-param.DateTime        = buf_cash-param-hist.tstamp
                    tt-param.KeyBoardNameDop = buf_cash-param-hist.param_name
                    .
                  tt-param.DeviceName   = mdevice:GetLabel(buf_cash-param-hist.device).
                  tt-param.SectionName   = msection:GetLabel(int(buf_cash-param-hist.param_section)).
                  find first clients no-lock where clients.obj-code = tt-param.obj-code and
                    clients.obj-type = tt-param.obj-type no-error .
                  if available (clients) then tt-param.obj-name = clients.obj-name .
                end.
              end.
            end.
            for each code-device where code-device.parent = "cash-param" no-lock:
              if parDesk <> "-1" then
                if lookup(string(code-device.code), parDesk, ",") = 0 then next .
              for each code-section where code-section.parent = code-device.parent + chr(4) + code-device.code no-lock:
                for each code-group where code-group.parent = code-section.parent + chr(4) + code-section.code no-lock:
                  for each code-param where code-param.parent = code-group.parent + chr(4) + code-group.code no-lock:
                    if parParam = "choose" then
                    do:
                      find first tt-choose-code where tt-choose-code.section = code-section.code and
                        tt-choose-code.device = code-device.code and
                        tt-choose-code.group_ = code-group.code no-error .
                      if available tt-choose-code then
                      do:
                        if tt-choose-code.ParamName <> "" then
                        do:
                          find first buf_choose-code where buf_choose-code.section = code-section.code and
                            buf_choose-code.device = code-device.code and
                            buf_choose-code.group_ = code-group.code and
                            buf_choose-code.ParamName = code-param.code no-error .
                          if not available (buf_choose-code) then next .
                        end.
                      end.
                      else next .
                    end.
                    for each obj-list:
                      for each cash-list where cash-list.obj-code = obj-list.obj-code and cash-list.deviceCode = code-device.code:
                        if code-section.code = "1" then
                        do:
                          find first tt-param exclusive-lock where tt-param.ParamGroup = code-group.code and
                            tt-param.obj-code = obj-list.obj-code and
                            tt-param.obj-type = obj-list.obj-type and
                            tt-param.ParamName = code-param.code and
                            tt-param.ParamSection = code-section.code and
                            tt-param.CashNum = cash-list.cash-num and
                            tt-param.Device = cash-list.deviceCode no-error .
                          if not available (tt-param) then
                          do:
                            create tt-param .
                            assign
                              tt-param.obj-code     = obj-list.obj-code
                              tt-param.obj-type     = obj-list.obj-type
                              tt-param.ParamGroup   = code-group.code
                              tt-param.Device       = code-device.code
                              tt-param.ParamSection = code-section.code
                              tt-param.ParamName    = code-param.code
                              tt-param.flag         = "etalon"
                              tt-param.diff         = true
                              tt-param.CashNum      = cash-list.cash-num
                              .
                            tt-param.DeviceName   = mdevice:GetLabel(int(code-device.code)) .
                            tt-param.SectionName  =  msection:GetLabel(int(code-section.code)).
                          end.
                          else tt-param.flag = "" .
                          assign
                            tt-param.EtalonValue = code-param.CodeValue
                            tt-param.status_     = code-param.status_
                            .
                        end.
                        else
                        do:
                          find first tt-param exclusive-lock where tt-param.ParamGroup = code-group.code and
                            tt-param.obj-code = obj-list.obj-code and
                            tt-param.obj-type = obj-list.obj-type and
                            tt-param.ParamSection = code-section.code and
                            tt-param.KeyBoardNameDop = code-param.code and
                            tt-param.CashNum = cash-list.cash-num and
                            tt-param.Device = cash-list.deviceCode no-error .
                          if not available (tt-param) then
                          do:
                            create tt-param .
                            assign
                              tt-param.obj-code        = obj-list.obj-code
                              tt-param.obj-type        = obj-list.obj-type
                              tt-param.ParamGroup      = code-group.code
                              tt-param.Device          = code-device.code
                              tt-param.ParamSection    = code-section.code
                              tt-param.KeyBoardNameDop = code-param.code
                              tt-param.flag            = "etalon"
                              tt-param.diff            = true
                              tt-param.CashNum         = cash-list.cash-num
                              .
                            tt-param.DeviceName   = mdevice:GetLabel(int(code-device.code)) .
                            tt-param.SectionName  =  msection:GetLabel(int(code-section.code)).
                          end.
                          else tt-param.flag = "" .
                          assign
                            tt-param.EtalonValue = code-param.CodeValue
                            tt-param.status_     = code-param.status_
                            .
                        end.
                        if tt-param.CurrentValue <> tt-param.EtalonValue and tt-param.flag = "" then tt-param.diff = true .
                        find first clients no-lock where clients.obj-code = tt-param.obj-code and
                          clients.obj-type = tt-param.obj-type no-error .
                        if available (clients) then tt-param.obj-name = clients.obj-name .
                      end.
                    end.
                  end.
                end.
              end.
            end.
            case parParam:
              when "mandatory" then
                do:
                  for each tt-param exclusive-lock where tt-param.flag = "current" or (tt-param.status_ = 1 and tt-param.flag <> "current"):
                    delete tt-param .
                  end.
                end.
              when "optional" then
                do:
                  for each tt-param exclusive-lock where tt-param.flag = "current" or (tt-param.status_ = 0 and tt-param.flag <> "current"):
                    delete tt-param .
                  end.
                end.
              when "diff" then
                do:
                  for each tt-param exclusive-lock where not tt-param.diff and tt-param.flag = "":
                    delete tt-param .
                  end.
                end.
            end.
            define variable cashQntyCheck       as integer no-undo .
            define variable diffCashParam       as integer no-undo .
            define variable diffCashKeyBoard    as integer no-undo .
            define variable withoutCashParam    as integer no-undo .
            define variable withoutCashKeyBoard as integer no-undo .
            for each obj-list no-lock where obj-list.obj-type = 'маг':U:
              for each cash-list no-lock where cash-list.obj-code = obj-list.obj-code:
                cashQntyCheck = cashQntyCheck + 1 .
                if can-find (first buf_param no-lock where buf_param.CashNum = cash-list.cash-num and
                  buf_param.obj-code = cash-list.obj-code and
                  buf_param.SectionName = "Параметры" and
                  (buf_param.diff or buf_param.flag <> "")) then diffCashParam = diffCashParam + 1 .
                else withoutCashParam = withoutCashParam + 1 .
                if can-find (first buf_param no-lock where buf_param.CashNum = cash-list.cash-num and
                  buf_param.obj-code = cash-list.obj-code and
                  buf_param.SectionName <> "Параметры" and
                  (buf_param.diff or buf_param.flag <> "")) then
                  diffCashKeyBoard = diffCashKeyBoard + 1 .
                else withoutCashKeyBoard = withoutCashKeyBoard + 1 .
              end.
            end.
            put stream OutStr-html unformatted
              '<tr><!-- шапка таблицы -->' skip
              '<td colspan="11" style="text-align: right;"></td>' skip
              '</tr>' skip
              '<tr>' skip
              '<td colspan="11" style="text-align: right;">Дата формирования ' + string(today,"99.99.9999") + " " + string(time,"HH:MM:SS") + '</td>'
              '</tr>' skip
              '<tr>' skip
              '<td colspan="11" style="font-weight: bold; text-align: center;">Отчет по анализу параметров АРМ Кассира</td>' skip
              '</tr>' skip
              '<tr>' skip
              '<td colspan="11" style="text-align: left;">Кол-во проверенных касс: ' + string(cashQntyCheck) + '</td>'
              '</tr>' skip
              .
            if parSource <> "keyboard" then
            do:
              put stream OutStr-html unformatted
                '<tr>' skip
                '<td colspan="11" style="text-align: left;">     с замечаниями по параметрам: ' + string(diffCashParam) + '</td>'
                '</tr>' skip .
            end.
            if parSource <> "param" then
            do:
              put stream OutStr-html unformatted
                '<tr>' skip
                '<td colspan="11" style="text-align: left;">     с замечаниями по клавиатуре: ' + string(diffCashKeyBoard) + '</td>'
                '</tr>' skip
                .
            end.
            if parSource <> "keyboard" then
            do:
              put stream OutStr-html unformatted
                '<tr>' skip
                '<td colspan="11" style="text-align: left;">     без замечаний по параметрам: ' + string(withoutCashParam) + '</td>'
                '</tr>' skip
                .
            end.
            if parSource <> "param" then
            do:
              put stream OutStr-html unformatted
                '<tr>' skip
                '<td colspan="11" style="text-align: left;">     без замечаний по клавиатуре: ' + string(withoutCashKeyBoard) + '</td>'
                '</tr>' skip
                .
            end.
            put stream OutStr-html unformatted
              '</thead>' skip
              '<tr>' skip
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Название АЗК/АЗС</td>' skip
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Признак исполнения кассы</td>' skip
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Номер кассы</td>' skip
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Дата и время актуальной сверки</td>' skip
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Наименование источника</td>' skip
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Раздел/Наименование функции клавиши</td>' skip
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Наименование параметра/Дополнительное значение</td>' skip
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Тип клавиатуры</td>' skip
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Значение параметра/Степень защиты эталон</td>' skip
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Значение параметра/Степень защиты текущее</td>' skip
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Результат сравнения</td>' skip
              '</tr>' skip
              '<tbody>'
              .
            define variable v-first as logical   no-undo .
            define variable v-color as character no-undo .
            if parSource <> "keyboard" then
            do:
              for each tt-param no-lock where tt-param.SectionName = "Параметры" by tt-param.obj-code by tt-param.obj-type by tt-param.CashNum by tt-param.ParamGroup by tt-param.KeyBoardName:
                if not v-first then
                do:
                  put stream OutStr-html unformatted
                    '<tr>' skip
                    '<td colspan="11" text_wrap="true" style="">' tt-param.SectionName '</td>' skip
                    '</tr>' skip
                    .
                end.
                v-first = true .
                v-color = getColor(tt-param.flag, tt-param.status_, tt-param.diff) .
                put stream OutStr-html unformatted
                  '<tr>' skip
                  '<td text_wrap="true">' tt-param.obj-name  '</td>' skip
                  '<td text_wrap="true">' tt-param.DeviceName '</td>' skip
                  '<td text_wrap="true">' tt-param.CashNum '</td>' skip
                  '<td text_wrap="true">' if tt-param.DateTime = 0 then "" else fConvetDateTime(tt-param.DateTime) '</td>' skip
                  '<td text_wrap="true">' tt-param.SectionName '</td>' skip
                  '<td text_wrap="true">' tt-param.ParamGroup '</td>' skip
                  '<td text_wrap="true">' tt-param.ParamName '</td>' skip
                  '<td text_wrap="true">' tt-param.KeyBoardName '</td>' skip
                  '<td text_wrap="true">' tt-param.EtalonValue '</td>' skip
                  '<td text_wrap="true">' tt-param.CurrentValue '</td>' skip
                  '<td text_wrap="true" style="background-color: ' + v-color + ';">' getColorText(v-color) '</td>' skip
                  '</tr>' skip
                  .
              end.
            end.
            v-first = false .
            if parSource <> "param" then
            do:
              for each tt-param no-lock where tt-param.SectionName <> "Параметры" by tt-param.obj-code by tt-param.obj-type by tt-param.CashNum by tt-param.ParamGroup by tt-param.KeyBoardName by tt-param.KeyBoardNameDop:
                for first buf_code exclusive-lock where buf_code.code = tt-param.ParamGroup and buf_code.parent = "cashFunKey":
                  tt-param.ParamGroup = buf_code.code + " " + buf_code.misc1 + " " + buf_code.CodeName .
                end.
                if not v-first then
                do:
                  put stream OutStr-html unformatted
                    '<tr>' skip
                    '<td colspan="11" text_wrap="true" style="">' tt-param.SectionName '</td>' skip
                    '</tr>' skip
                    .
                end.
                v-first = true .
                v-color = getColorKey(tt-param.flag, tt-param.status_, tt-param.diff) .
                put stream OutStr-html unformatted
                  '<tr>' skip
                  '<td text_wrap="true">' tt-param.obj-name  '</td>' skip
                  '<td text_wrap="true">' tt-param.DeviceName '</td>' skip
                  '<td text_wrap="true">' tt-param.CashNum '</td>' skip
                  '<td text_wrap="true">' if tt-param.DateTime = 0 then "" else fConvetDateTime(tt-param.DateTime) '</td>' skip
                  '<td text_wrap="true">' tt-param.SectionName '</td>' skip
                  '<td text_wrap="true">' tt-param.ParamGroup '</td>' skip
                  '<td text_wrap="true">' tt-param.KeyBoardNameDop '</td>' skip
                  '<td text_wrap="true">' tt-param.KeyBoardName '</td>' skip
                  '<td text_wrap="true">' tt-param.EtalonValue '</td>' skip
                  '<td text_wrap="true">' tt-param.CurrentValue '</td>' skip
                  '<td text_wrap="true" style="background-color: ' + v-color + ';">' getColorText(v-color) '</td>' skip
                  '</tr>' skip
                  .
              end.
            end.
            if g#db-num = 0 then
            do:
              put stream OutStr-html unformatted
                '<tr>' skip
                '<td text_wrap="true" colspan = "11" style="background-color:#D8EEC0; text-align: center;">Контрольные суммы справочника ЭЗ</td>' skip
                '</tr>' skip
                '<tr>' skip
                '<td colspan = "3" text_wrap="true" style="background-color:#D8EEC0; text-align: center;">Название АЗК/АЗС</td>' skip
                '<td colspan = "4" text_wrap="true" style="background-color:#D8EEC0; text-align: center;">Контрольная сумма совпадает</td>' skip
                '<td colspan = "4" text_wrap="true" style="background-color:#D8EEC0; text-align: center;">Контрольная сумма не совпадает</td>' skip
                '</tr>' skip
                .
              define variable trueControlSum  as character no-undo .
              define variable falseControlSum as character no-undo .
              define variable vhashcode       as character no-undo.
              vhashcode = getCashparamHash().
              for each obj-list where obj-list.obj-type = 'маг':U:
                trueControlSum = "" .
                falseControlSum = "" .
                if vhashcode <> getCashParamHashDb(obj-list.db) then
                do:
                  falseControlSum = "Да" .
                  v-color = "#FFB3B3" .
                end.
                else
                do:
                  trueControlSum = "Да" .
                  v-color = "white" .
                end.
                put stream OutStr-html unformatted
                  '<tr>' skip
                  '<td colspan = "3" text_wrap="true" style="background-color:' + v-color + '; text-align: left;">' + obj-list.obj-name + '</td>' skip
                  '<td colspan = "4" text_wrap="true" style="background-color:' + v-color + '; text-align: right;">' + trueControlSum + '</td>' skip
                  '<td colspan = "4" text_wrap="true" style="background-color:' + v-color + '; text-align: right;">' + falseControlSum + '</td>' skip
                  '</tr>' skip
                  .
              end.
            end.
            put stream OutStr-html unformatted
              '<tbody>' skip
              '</table>'
              .
            output stream OutStr-html close.
            run prn-lib-reportviewer in this-procedure (
              input parparentproc
              ,input v-report-name-html-list
              ,input ""
              ) no-error.
            if error-status:error then
            do:
              message return-value view-as alert-box.
              return .
            end.
FUNCTION getColor RETURNS CHARACTER
  ( isflag as char, istatus as int, isdiff as logical ):
  case istatus:
    when 0 or
    when 2 then
      do:
        if isflag = "etalon" then return "#FFDD71" .
        else if isflag = "current" then return "#ffffe0"  .
          else if isdiff then return "#FFB3B3"  .
            else return "#D8EEC0"  .
      end.
    when 1 or
    when 1 then
      do:
        return "#D5EAFF" .
      end.
    otherwise
    do:
      if isflag = "current" then return "#ffffe0"  .
    end.
  end case.
end.
FUNCTION getColorKey RETURNS CHARACTER
  ( isflag as char, istatus as int, isdiff as logical ):
  case istatus:
    when 0 or
    when 2 then
      do:
        if isflag = "etalon" then return "#FFDD71" .
        else if isflag = "current" then return "#ffffe0"  .
          else if isdiff then return "#FFB3B3"  .
            else return "#D8EEC0"  .
      end.
    when 1 or
    when 1 then
      do:
        if isflag = "current" then return "#ffffe0"  .
        else return "#D5EAFF" .
      end.
    otherwise
    do:
      if isflag = "current" then return "#ffffe0"  .
    end.
  end case.
end.
FUNCTION getColorText RETURNS CHARACTER
  ( iscolor as char ):
  case iscolor:
    when "#FFDD71" then
      do:
        return "Не настроен на кассе" .
      end.
    when "#FFB3B3" then
      do:
        return "Не соответствует эталону (РПД/ИА)" .
      end.
    when "#D8EEC0" then
      do:
        return "Соответствует эталону (РПД/ИА)" .
      end.
    when "#D5EAFF" then
      do:
        return "Необязательный параметр (SiteSpecific)" .
      end.
    when "#ffffe0" then
      do:
        return "Отсутствует в эталоне, но есть на кассе" .
      end.
    otherwise
    do:
      return "" .
    end.
  end case.
end.
