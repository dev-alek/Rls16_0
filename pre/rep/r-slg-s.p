block-level on error undo, throw.
define input parameter x-date-start1   as date      no-undo .
define input parameter x-date-end1     as date      no-undo .
define input parameter x-itog          as logical   no-undo .
define input parameter x-lavel         as integer   no-undo .
define input parameter x-return        as logical   no-undo .
define input parameter x-SumObj        as logical   no-undo .
define input parameter x-ShowNull      as logical   no-undo .
define input parameter x-RADIO-sel     as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-slg-s.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-slg-s.p $":U .
define variable vss-description as character no-undo init "Анализ продаж".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_grplib_grp no-undo
    field sel           as character
    field nabor         as character
    field full-name     as character
    field print-code    as character
    field sort-name     as character
    field node-code     as integer
    field upper-code    as integer
    field calc-method   as character
    field round-method  as character
    field increase-pc   as decimal
    field min-marg      as character
    field max-marg      as character
    field cli-type      as character
    field cli-code      as integer
    field notcorr      as character
    field name          as character
    field level         as integer
    field mark          as character
    index pi is primary unique sort-name
    index fn full-name
    index nc is unique node-code
    index sl sel
    index uc upper-code
.
define temp-table temp_grplib_found-grp no-undo
    field full-name   as character
    field sort-name   as character
    field node-code   as integer
    field level       as integer
    field is-terminal as logical
    index pi is primary unique sort-name
    index fn full-name
    index lv level
    index it is-terminal
.
define temp-table temp_found-result-nodelist no-undo
    field node-code     as recid
    field processed     as logical
    field sort-name     as character
    field full-name     as character
    index pi is primary unique node-code
    index ps processed
.
define variable v-grplib-not-fill-extra-info        as logical      no-undo.
define variable v-grplib-no-warning-grp-amount      as logical      no-undo.
define variable v-grplib-grp-amount-for-load        as integer      no-undo.
procedure grplib-get-parameters :
define input parameter p-store-type     as character        no-undo.
define input parameter p-store-code     as integer          no-undo.
do
on error undo, return error
:
    assign
        v-grplib-not-fill-extra-info = no
    .
end.
end procedure.
procedure grplib-get-sort-name :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define output parameter p-sort-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-sort-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-sort-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-sort-name: Ошибка составления полного имени группы"
    :
        assign
            p-sort-name  = buf_gds-grp.node-name
                         + (if p-sort-name <> "" then chr(2) else "")
                         + p-sort-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-sort-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
end.
end procedure.
define variable vss-include-info11 as character format "X(65)" no-undo
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
procedure grplib-get-root-code :
do
on error undo, return error
:
define output parameter p-root-code as integer      no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = 0
    no-error .
    if not available buf_gds-grp
    then do:
        undo, return error .
    end.
    else do:
        assign
            p-root-code = buf_gds-grp.node-code
        .
    end.
end.
end procedure.
procedure grplib-find-grp-by-full-name :
do
on error undo, return error
:
define input parameter p-search-name  as character    no-undo.
define input parameter p-fill-path    as logical      no-undo.
define output parameter p-found       as logical      no-undo.
    define variable v-upper-code    as integer          no-undo.
    define variable v-counter       as integer           no-undo.
    define variable v-level         as integer           no-undo.
    define variable v-full-name     as character         no-undo.
    define variable v-sort-name     as character         no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    assign
        p-search-name = replace( p-search-name, chr(47), chr(2) )
    .
    run grplib-get-root-code ( output v-upper-code ) no-error .
    if error-status :error
    then do:
        undo, return error "grplib-expand-name: Ошибка при поиске корневого узла".
    end.
    assign
        v-full-name  = ""
        v-level      = num-entries( p-search-name, chr(2) )
    .
    for each temp_grplib_found-grp
    :
        delete temp_grplib_found-grp.
    end.
    start-name-analyze:
    do v-counter = 1 to v-level
    :
        if v-counter < v-level
        then do:
            find first buf_gds-grp no-lock
                 where buf_gds-grp.upper-code = v-upper-code
                   and buf_gds-grp.node-name  = entry( v-counter, p-search-name, chr(2) )
            no-error .
            if not available buf_gds-grp
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                return error "grplib-expand-name: не найдена группа " + entry( v-level, p-search-name, chr(2) ).
            end.
            else do:
                assign
                    v-full-name = v-full-name + ( if v-full-name = "" then "" else chr(47) )        + buf_gds-grp.node-name
                    v-sort-name = v-sort-name + ( if v-sort-name = "" then "" else chr(2) ) + buf_gds-grp.node-name
                    v-upper-code = buf_gds-grp.node-code
                .
                if p-fill-path = yes
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name = v-full-name + chr(47)
                        temp_grplib_found-grp.sort-name = v-sort-name
                        temp_grplib_found-grp.node-code = v-upper-code
                        temp_grplib_found-grp.level     = v-counter
                    .
                end.
            end.
        end.
        else do:
            for each buf_gds-grp no-lock
               where buf_gds-grp.upper-code = v-upper-code
                 and buf_gds-grp.node-name begins entry( v-counter, p-search-name, chr(2) )
            :
                assign
                    p-found = yes
                .
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name = v-full-name
                                                        + (if v-full-name = "" then "" else chr(47) )
                                                        + buf_gds-grp.node-name + chr(47)
                    temp_grplib_found-grp.sort-name = v-sort-name
                                                        + ( if v-sort-name = "" then "" else chr(2) )
                                                        + buf_gds-grp.node-name
                    temp_grplib_found-grp.node-code = buf_gds-grp.node-code
                    temp_grplib_found-grp.level     = v-level
                .
            end.
            if p-found = no
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                for each temp_grplib_found-grp
                :
                    delete temp_grplib_found-grp.
                end.
                assign
                    p-found = no
                .
            end.
        end.
    end.
end.
end procedure.
procedure grplib-find-all-subgroup :
do
on error undo, return error
:
define input parameter p-start-node-code    as integer      no-undo.
define input parameter p-terminal-only      as logical      no-undo.
    define variable v-start-full-name   as character     no-undo.
    define variable v-start-sort-name   as character     no-undo.
    define variable v-not-found         as logical       no-undo.
    define variable v-is-terminal       as logical       no-undo.
    define buffer buf_gds-grp           for ub.gds-grp.
    create temp_found-result-nodelist.
    assign
        temp_found-result-nodelist.node-code = p-start-node-code
        temp_found-result-nodelist.processed = no
    .
    run grplib-get-full-name in this-procedure (
          input p-start-node-code
        , output v-start-full-name
    ).
    run grplib-get-full-name in this-procedure (
          input p-start-node-code
        , output v-start-sort-name
    ).
    process-nodes:
    do while yes
    :
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.node-code = p-start-node-code
        .
        assign
            temp_found-result-nodelist.processed = yes
        .
        for each buf_gds-grp no-lock
           where buf_gds-grp.upper-code = p-start-node-code
        on error undo, return error
        :
            run grplib-is-terminal in this-procedure (
                  input buf_gds-grp.node-code
                , output v-is-terminal
            ).
            if v-is-terminal = yes
            then do:
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                        chr(47) + buf_gds-grp.node-name + chr(47)
                    temp_grplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                        chr(2) + buf_gds-grp.node-name + chr(2)
                    temp_grplib_found-grp.node-code   = buf_gds-grp.node-code
                    temp_grplib_found-grp.is-terminal = yes
                .
            end.
            else do:
                create temp_found-result-nodelist.
                assign
                    temp_found-result-nodelist.node-code = buf_gds-grp.node-code
                    temp_found-result-nodelist.full-name = right-trim(v-start-full-name, chr(47)) +
                                                           chr(47) + buf_gds-grp.node-name + chr(47)
                    temp_found-result-nodelist.sort-name = right-trim(v-start-sort-name, chr(2)) +
                                                           chr(2) + buf_gds-grp.node-name + chr(2)
                    temp_found-result-nodelist.processed = no
                .
                if p-terminal-only = no
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                            chr(47) + buf_gds-grp.node-name + chr(47)
                        temp_grplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                            chr(2) + buf_gds-grp.node-name + chr(2)
                        temp_grplib_found-grp.node-code   = buf_gds-grp.node-code
                        temp_grplib_found-grp.is-terminal = no
                    .
                end.
            end.
        end.
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.processed = no
        no-error.
        if not available temp_found-result-nodelist
        then do:
            leave process-nodes.
        end.
        else do:
            assign
                p-start-node-code = temp_found-result-nodelist.node-code
                v-start-full-name = temp_found-result-nodelist.full-name
                v-start-sort-name = temp_found-result-nodelist.sort-name
            .
        end.
    end.
end.
end procedure.
procedure grplib-expand-name :
define input parameter p-start-name as character        no-undo.
define output parameter p-end-name  as character        no-undo.
    define variable v-is-terminal   as logical      no-undo.
    define variable v-found         as character    no-undo.
    define buffer buf_temp_grplib_found-grp     for temp_grplib_found-grp.
do
for buf_temp_grplib_found-grp
on error undo, return error
:
    run grplib-find-grp-by-full-name in this-procedure (
          input p-start-name
        , input no
        , output v-found
    ) no-error.
    run grplib-get-max-substring in this-procedure (
                input length( p-start-name )
              , output p-end-name
    ) no-error .
    if error-status :error
    then do:
        assign
            p-end-name = ""
        .
    end.
    else do:
        find first temp_grplib_found-grp
            where temp_grplib_found-grp.full-name = p-end-name
        no-error.
        if available temp_grplib_found-grp
        then do:
            find first buf_temp_grplib_found-grp
                where buf_temp_grplib_found-grp.full-name begins p-end-name
                and recid( buf_temp_grplib_found-grp ) <> recid( temp_grplib_found-grp )
            no-error.
            if not available buf_temp_grplib_found-grp
            then do:
                run grplib-is-terminal in this-procedure (
                    input temp_grplib_found-grp.node-code
                    , output v-is-terminal
                ).
            end.
        end.
    end.
end.
end procedure.
procedure grplib-get-max-substring :
do
on error undo, return error
:
define input parameter p-min-substring-length   as integer      no-undo.
define output parameter p-substring             as character    no-undo.
        define variable v-char-counter  as integer           no-undo.
        define variable v-current-char  as character         no-undo.
        define variable v-names-counter  as integer           no-undo.
        define variable v-base-string   as character         no-undo.
        assign
            v-char-counter  = p-min-substring-length
        .
        find first temp_grplib_found-grp no-error.
        if not available temp_grplib_found-grp
        then do:
            undo, return error "grplib-get-max-substring: Нет строк для вычисления общей подстроки".
        end.
        else do:
            assign
                v-base-string  = temp_grplib_found-grp.full-name
                v-char-counter = 0
            .
            counter-block:
            do while yes
            on error undo, return error "grplib-get-max-substring: Ошибка вычисления продолжения имени группы."
            :
                assign
                    v-char-counter  = v-char-counter + 1
                    v-current-char  = substring( v-base-string, v-char-counter, 1 )
                    v-names-counter = 0
                .
                compare-block:
                for each temp_grplib_found-grp
                :
                    assign
                        v-names-counter = v-names-counter + 1
                    .
                    if v-names-counter = 1
                    then do:
                        next compare-block.
                    end.
                    if substring( temp_grplib_found-grp.full-name, v-char-counter, 1 ) <> v-current-char
                    then do:
                        leave counter-block.
                    end.
                end.
                if v-names-counter = 1
                then do:
                    assign
                        p-substring = v-base-string
                    .
                    return.
                end.
            end.
            assign
                p-substring = substring( v-base-string, 1, v-char-counter - 1 )
            .
        end.
end.
end procedure.
procedure grplib-is-terminal :
do
on error undo, return error "Ошибка процедуры grplib-is-terminal"
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-is-terminal   as logical      no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = p-node-code
    no-error .
    if not available buf_gds-grp
    then do:
        assign
            p-is-terminal = yes
        .
    end.
    else do:
        assign
            p-is-terminal = no
        .
    end.
end.
end procedure.
procedure grplib-have-goods :
do
on error undo, return error
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-have-goods   as logical      no-undo.
    define buffer buf_goods         for ub.goods.
    find first buf_goods no-lock
         where buf_goods.grp-code = p-node-code
    no-error .
    if available buf_goods
    then do:
        assign
            p-have-goods = yes
        .
    end.
    else do:
        assign
            p-have-goods = no
        .
    end.
end.
end procedure.
procedure grplib-find-by-substring :
do
on error undo, return error
:
define input parameter p-start-code         as integer      no-undo.
define input parameter p-full-search-string as character    no-undo.
define output parameter p-found-code        as integer      no-undo.
define output parameter p-full-name         as character    no-undo.
    define variable v-start-code     as integer           no-undo.
    define variable v-found          as logical  init no  no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    search-grp:
    for each buf_gds-grp no-lock
        where buf_gds-grp.node-code > p-start-code
    :
        if index( buf_gds-grp.node-name, p-full-search-string ) <> 0
        then do:
            assign
                p-found-code = buf_gds-grp.node-code
                v-found      = yes
            .
            run grplib-get-full-name in this-procedure (
                  input p-found-code
                , output p-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "grplib-find-by-substring: Ошибка вычисления полного имени группы." + chr(10) + return-value.
            end.
            leave search-grp.
        end.
    end.
    if v-found = yes
    then do:
    end.
    else do:
        assign
            p-full-name  = ""
            p-found-code = 0
        .
    end.
end.
end procedure.
procedure grplib-analyze-grp-name :
do
on error undo, return error
:
define input parameter p-grp-name       as character            no-undo.
define input parameter p-upper-code     as integer              no-undo.
define output parameter p-error-message as character init ""    no-undo.
    define variable v-char-list     as character    no-undo.
    define variable v-char-counter  as integer      no-undo.
    define variable v-full-name     as character    no-undo.
    if p-grp-name = "" then do:
        assign
            p-error-message = "Название группы не может быть пустым.".
        .
    end.
    else do:
        assign
            v-char-list = "47,92,58,63,34,60,62,171,187,183"
        .
        do v-char-counter = 1 to num-entries( v-char-list )
        :
            if index( p-grp-name, chr( integer( entry( v-char-counter, v-char-list ) ) ) ) <> 0
            then do:
                assign
                    p-error-message = 'Название группы не может содержать символы /\:*?"<>|«»·'
                .
                return.
            end.
        end.
        if p-upper-code > 0
        then do:
            run grplib-get-full-name in this-procedure (
                  input p-upper-code
                , output v-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "grplib-analyze-grp-name: Не удалось вычислить полное имя группы." + chr(10) + return-value.
            end.
            if length( v-full-name ) + 1 + length( p-grp-name ) > 350
            then do:
                assign
                    p-error-message = 'Полное название группы не может содержать более 350 символов.'
                .
            end.
        end.
    end.
end.
end procedure.
procedure grplib-get-lvl-num :
define input parameter p-node-code  as integer      no-undo.
define output parameter p-lvl-num   as integer      no-undo.
    define variable v-full-name    as character    no-undo.
do
on error undo, return error
:
    run grplib-get-full-name in this-procedure (
          input p-node-code
        , output v-full-name
    ).
    assign
        p-lvl-num = num-entries( v-full-name, chr(47) ) - 1
    .
    if p-lvl-num = -1
    then do:
        assign
            p-lvl-num = 0
        .
    end.
end.
end procedure.
define variable vss-include-info12 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
def var vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure r-cost :
  define input  parameter v-doc-code       like ub.doc-line.doc-code          no-undo .
  define input  parameter v-artic          like ub.doc-line.artic             no-undo .
  define input  parameter v-prod-type      like ub.doc-line.prod-type         no-undo .
  define input  parameter v-prod-code      like ub.doc-line.prod-code         no-undo .
  define output parameter v-fact-qnty      like ub.ot-line.fact-qnty       no-undo .
  define output parameter v-vat-pc         like ub.doc-line.vat-pc         no-undo .
  define output parameter v-slt-pc         like ub.doc-line.slt-pc         no-undo .
  define output parameter v-sum-base       like ub.ot-line.sum-base        no-undo .
  define output parameter v-sum-rubl       like ub.ot-line.sum-rubl        no-undo .
  define output parameter v-vat-base       like ub.ot-line.vat-base        no-undo .
  define output parameter v-vat-rubl       like ub.ot-line.vat-rubl        no-undo .
  define output parameter v-slt-base       like ub.ot-line.slt-base        no-undo .
  define output parameter v-slt-rubl       like ub.ot-line.slt-rubl        no-undo .
  define output parameter v-road-tax-base  like ub.ot-line.road-tax-base   no-undo .
  define output parameter v-road-tax-rubl  like ub.ot-line.road-tax-rubl   no-undo .
  define output parameter v-transport-base like ub.ot-line.transport-base  no-undo .
  define output parameter v-transport-rubl like ub.ot-line.transport-rubl  no-undo .
  define output parameter v-other-base     like ub.ot-line.other-base      no-undo .
  define output parameter v-other-rubl     like ub.ot-line.other-rubl      no-undo .
  define output parameter v-excise-base    like ub.ot-line.excise-base     no-undo .
  define output parameter v-excise-rubl    like ub.ot-line.excise-rubl     no-undo .
  do
  on error undo, return error
  :
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
    def var v-parts-fact-qnty as decimal   no-undo .
    define buffer buf_parts    for ub.parts    .
    define buffer buf_goods    for ub.goods    .
    define buffer buf_trn-doc  for ub.trn-doc  .
    define buffer buf_doc-line for ub.doc-line .
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = v-doc-code
        and buf_doc-line.artic     = v-artic
        and buf_doc-line.prod-type = v-prod-type
        and buf_doc-line.prod-code = v-prod-code
      no-error .
    if not available buf_doc-line then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info13 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа"  skip
        "Документ" v-doc-code skip
        "Артикул" v-artic v-prod-type v-prod-code skip
        view-as alert-box error .
      return error .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = v-doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info13 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" v-doc-code skip
        "Артикул" v-artic v-prod-type v-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
      no-error .
    if not available buf_goods then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info13 skip
        "Ошибка задания входных параметров" skip
        "Не найден товар" skip
        "Документ" v-doc-code skip
        "Артикул" v-artic v-prod-type v-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_goods.gds-type = 'т':U then do:
          for each buf_parts no-lock
            where buf_parts.out-code  = buf_trn-doc.doc-code
              and buf_parts.obj-type  = buf_trn-doc.obj-type
              and buf_parts.obj-code  = buf_trn-doc.obj-code
              and buf_parts.artic     = buf_doc-line.artic
              and buf_parts.prod-type = buf_doc-line.prod-type
              and buf_parts.prod-code = buf_doc-line.prod-code
          on error undo, return error
          :
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_parts.out-code = 'free-zone':U     or
     buf_parts.out-code = 'out-zone':U   or
     buf_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = buf_parts.price-cli
   cli-base-rate          = buf_parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_parts.road-tax-base  = ? then 0 else buf_parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_parts.road-tax-rubl  = ? then 0 else buf_parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_parts.transport-base = ? then 0 else buf_parts.transport-base)
          transport-rubl-loc = (if buf_parts.transport-rubl = ? then 0 else buf_parts.transport-rubl)
          other-base-loc     = (if buf_parts.other-base     = ? then 0 else buf_parts.other-base)
          other-rubl-loc     = (if buf_parts.other-rubl     = ? then 0 else buf_parts.other-rubl)
          vat-pc-loc         = (if buf_parts.vat-pc         = ? then 0 else buf_parts.vat-pc)
          slt-pc-loc         = (if buf_parts.slt-pc         = ? then 0 else buf_parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
            assign
              v-parts-fact-qnty  = (if buf_trn-doc.doc-type = 'при':U
                                    or buf_trn-doc.doc-type = 'возврат':U
                                    or buf_trn-doc.doc-type = 'инв':U
                                    then buf_parts.fact-qnty
                                    else - buf_parts.fact-qnty
                                   )
            .
            assign
              v-fact-qnty           = v-fact-qnty      + v-parts-fact-qnty
              v-sum-base            = v-sum-base       +  ( price-base-with-tax-loc * v-parts-fact-qnty )
              v-sum-rubl            = v-sum-rubl       +  ( price-rubl-with-tax-loc * v-parts-fact-qnty )
              v-vat-base            = v-vat-base       +  ( vat-base-loc            * v-parts-fact-qnty )
              v-vat-rubl            = v-vat-rubl       +  ( vat-rubl-loc            * v-parts-fact-qnty )
              v-slt-base            = v-slt-base       +  ( slt-base-loc            * v-parts-fact-qnty )
              v-slt-rubl            = v-slt-rubl       +  ( slt-rubl-loc            * v-parts-fact-qnty )
              v-road-tax-base       = v-road-tax-base  +  ( road-tax-base-loc       * v-parts-fact-qnty )
              v-road-tax-rubl       = v-road-tax-rubl  +  ( road-tax-rubl-loc       * v-parts-fact-qnty )
              v-excise-base         =   0
              v-excise-rubl         =   0
              v-transport-base      = v-transport-base +   (transport-base-loc      * v-parts-fact-qnty )
              v-transport-rubl      = v-transport-rubl +   (transport-rubl-loc      * v-parts-fact-qnty )
              v-other-base          = v-other-base     +   (other-base-loc          * v-parts-fact-qnty )
              v-other-rubl          = v-other-rubl     +   (other-rubl-loc          * v-parts-fact-qnty )
            .
        end.
assign
  price-rubl-with-tax-loc = buf_doc-line.price-rubl
  price-base-with-tax-loc = buf_doc-line.price-base
.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
      and in-vatp_doc-attr.attr-code = 'envd':U
    no-error .
    if available in-vatp_doc-attr
       then do:
       assign
         in-vatp-have-vat-slt = no.
   end.
   else do:
     assign
       in-vatp-have-vat-slt = yes.
   end.
   find first in-vatp-goods where in-vatp-goods.artic     = buf_doc-line.artic     and
                                     in-vatp-goods.prod-type = buf_doc-line.prod-type and
                                     in-vatp-goods.prod-code = buf_doc-line.prod-code no-lock.
   if (not buf_trn-doc.internal and
           buf_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = buf_doc-line.road-tax
          road-tax-rubl-loc = buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = buf_doc-line.road-tax
          road-tax-base-loc = buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if buf_doc-line.transport-base = ? then 0 else buf_doc-line.transport-base)
        transport-rubl-loc = (if buf_doc-line.transport-rubl = ? then 0 else buf_doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if buf_doc-line.other-base     = ? then 0 else buf_doc-line.other-base)
        other-rubl-loc     = (if buf_doc-line.other-rubl     = ? then 0 else buf_doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if buf_doc-line.vat-pc         = ? then 0 else buf_doc-line.vat-pc)
        slt-pc-loc         = (if buf_doc-line.slt-pc         = ? then 0 else buf_doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = buf_doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = buf_doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = buf_doc-line.obj-code  and
                                      in-vatp-parts.artic     = buf_doc-line.artic     and
                                      in-vatp-parts.prod-type = buf_doc-line.prod-type and
                                      in-vatp-parts.prod-code = buf_doc-line.prod-code
                         use-index out-code no-lock:
          accumulate  in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-base * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-base     * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty (total)
                                                                                                              (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                                            (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                      .
      end.
      ASSIGN
        road-tax-base-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-base-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-rubl-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-base-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-rubl-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
                                        vat-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
                vat-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
        vat-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc)))
        slt-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))).
      if road-tax-base-loc  = ? then road-tax-base-loc  = 0.
      if road-tax-rubl-loc  = ? then road-tax-rubl-loc  = 0.
      if transport-base-loc = ? then transport-base-loc = 0.
      if transport-rubl-loc = ? then transport-rubl-loc = 0.
      if other-base-loc     = ? then other-base-loc     = 0.
      if other-rubl-loc     = ? then other-rubl-loc     = 0.
      assign
        transport-cli-loc      = 0
        other-cli-loc          = 0
        road-tax-cli-loc       = ?
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
        assign
            v-vat-pc              = vat-pc-loc
            v-slt-pc              = slt-pc-loc
        .
    end.
    else do:
          assign
            v-parts-fact-qnty           = (if buf_trn-doc.doc-type = 'при':U
                                      or buf_trn-doc.doc-type = 'возврат':U
                                      or buf_trn-doc.doc-type = 'инв':U
                                      then buf_doc-line.fact-qnty
                                      else - buf_doc-line.fact-qnty
                                    )
          .
assign
  price-rubl-with-tax-loc = buf_doc-line.price-rubl
  price-base-with-tax-loc = buf_doc-line.price-base
.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
      and in-vatp_doc-attr.attr-code = 'envd':U
    no-error .
    if available in-vatp_doc-attr
       then do:
       assign
         in-vatp-have-vat-slt = no.
   end.
   else do:
     assign
       in-vatp-have-vat-slt = yes.
   end.
   find first in-vatp-goods where in-vatp-goods.artic     = buf_doc-line.artic     and
                                     in-vatp-goods.prod-type = buf_doc-line.prod-type and
                                     in-vatp-goods.prod-code = buf_doc-line.prod-code no-lock.
   if (not buf_trn-doc.internal and
           buf_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = buf_doc-line.road-tax
          road-tax-rubl-loc = buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = buf_doc-line.road-tax
          road-tax-base-loc = buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if buf_doc-line.transport-base = ? then 0 else buf_doc-line.transport-base)
        transport-rubl-loc = (if buf_doc-line.transport-rubl = ? then 0 else buf_doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if buf_doc-line.other-base     = ? then 0 else buf_doc-line.other-base)
        other-rubl-loc     = (if buf_doc-line.other-rubl     = ? then 0 else buf_doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if buf_doc-line.vat-pc         = ? then 0 else buf_doc-line.vat-pc)
        slt-pc-loc         = (if buf_doc-line.slt-pc         = ? then 0 else buf_doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = buf_doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = buf_doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = buf_doc-line.obj-code  and
                                      in-vatp-parts.artic     = buf_doc-line.artic     and
                                      in-vatp-parts.prod-type = buf_doc-line.prod-type and
                                      in-vatp-parts.prod-code = buf_doc-line.prod-code
                         use-index out-code no-lock:
          accumulate  in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-base * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-base     * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty (total)
                                                                                                              (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                                            (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                      .
      end.
      ASSIGN
        road-tax-base-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-base-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-rubl-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-base-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-rubl-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
                                        vat-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
                vat-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
        vat-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc)))
        slt-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))).
      if road-tax-base-loc  = ? then road-tax-base-loc  = 0.
      if road-tax-rubl-loc  = ? then road-tax-rubl-loc  = 0.
      if transport-base-loc = ? then transport-base-loc = 0.
      if transport-rubl-loc = ? then transport-rubl-loc = 0.
      if other-base-loc     = ? then other-base-loc     = 0.
      if other-rubl-loc     = ? then other-rubl-loc     = 0.
      assign
        transport-cli-loc      = 0
        other-cli-loc          = 0
        road-tax-cli-loc       = ?
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
          assign
            v-fact-qnty           = v-fact-qnty      + v-parts-fact-qnty
            v-vat-pc              = vat-pc-loc
            v-slt-pc              = slt-pc-loc
            v-sum-base            = v-sum-base       + (price-base-with-tax-loc * v-parts-fact-qnty)
            v-sum-rubl            = v-sum-rubl       + (price-rubl-with-tax-loc * v-parts-fact-qnty)
            v-vat-base            = v-vat-base       + (vat-base-loc            * v-parts-fact-qnty)
            v-vat-rubl            = v-vat-rubl       + (vat-rubl-loc            * v-parts-fact-qnty)
            v-slt-base            = v-slt-base       + (slt-base-loc            * v-parts-fact-qnty)
            v-slt-rubl            = v-slt-rubl       + (slt-rubl-loc            * v-parts-fact-qnty)
            v-road-tax-base       =  0
            v-road-tax-rubl       =  0
            v-excise-base         =  0
            v-excise-rubl         =  0
            v-transport-base      =  0
            v-transport-rubl      =  0
            v-other-base          =  0
            v-other-rubl          =  0
          .
    end.
  end.
end procedure.
define variable vss-include-info17 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure r-sale :
  define input parameter  p-doc-code          like ub.doc-line.doc-code          no-undo .
  define input parameter  p-artic             like ub.doc-line.artic             no-undo .
  define input parameter  p-prod-type         like ub.doc-line.prod-type         no-undo .
  define input parameter  p-prod-code         like ub.doc-line.prod-code         no-undo .
  define output parameter p-fact-qnty         like ub.ot-line.fact-qnty       no-undo .
  define output parameter p-vat-pc            like ub.doc-line.vat-pc         no-undo .
  define output parameter p-slt-pc            like ub.doc-line.slt-pc         no-undo .
  define output parameter p-sum-base          like ub.ot-line.sum-base        no-undo .
  define output parameter p-sum-rubl          like ub.ot-line.sum-rubl        no-undo .
  define output parameter p-vat-base          like ub.ot-line.vat-base        no-undo .
  define output parameter p-vat-rubl          like ub.ot-line.vat-rubl        no-undo .
  define output parameter p-slt-base          like ub.ot-line.slt-base        no-undo .
  define output parameter p-slt-rubl          like ub.ot-line.slt-rubl        no-undo .
  define output parameter p-road-tax-base     like ub.ot-line.road-tax-base   no-undo .
  define output parameter p-road-tax-rubl     like ub.ot-line.road-tax-rubl   no-undo .
  define output parameter p-transport-base    like ub.ot-line.transport-base  no-undo .
  define output parameter p-transport-rubl    like ub.ot-line.transport-rubl  no-undo .
  define output parameter p-other-base        like ub.ot-line.other-base      no-undo .
  define output parameter p-other-rubl        like ub.ot-line.other-rubl      no-undo .
  define output parameter p-excise-base       like ub.ot-line.excise-base     no-undo .
  define output parameter p-excise-rubl       like ub.ot-line.excise-rubl     no-undo .
  define variable vss-description as character no-undo initial "r-sale-01: обработка продажных цен товара".
  do
  on error undo, return error
  :
    define  variable price-rubl-with-tax-sale    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-sale    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-sale like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-sale like ub.doc-line.price-base no-undo.
    define  variable vat-base-sale               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyer              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyer              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-sale               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-sale          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-sale          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-sale            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-sale            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-sale            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-sale            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtl for ub.gds-dtl.
    define buffer out-vatp_parts       for ub.parts.
    define buffer out-vatp_sysconf     for ub.sysconf.
    define buffer out-vatp_doc-line    for ub.doc-line.
    define buffer out-vatp_goods       for ub.goods.
    define buffer out-vatp_trn-doc     for ub.trn-doc.
    define buffer out-vatp_doc-attr    for ub.doc-attr.
    define variable varprice-base-cons      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-cons      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-type         as   character                           no-undo.
    define variable varfrm-cnsv              as   character                           no-undo.
    define variable varroot-node             as   integer                             no-undo.
    define variable varempty-scale           as   logical                             no-undo.
    define variable varis-cons-parts-have    as   logical                             no-undo.
    define variable varsum-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtl        as   logical                             no-undo.
    define variable varcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprb               as   character                           no-undo.
    define variable out-vatp-have-vat-slt    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-doco  for ub.trn-doc .
    define buffer   in-vatp-partso    for ub.parts   .
    define buffer   in-vatp-doco      for ub.trn-doc .
    define buffer   in-vatp-goodso    for ub.goods   .
    define buffer   in-vatp-sysconfo  for ub.sysconf .
    define buffer   in-vatp_doc-attro for ub.doc-attr.
    define variable in-vatp-have-vat-slto       as   logical initial yes    no-undo.
    define variable vat-pc-loco                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbo                  as   character              no-undo.
    define variable slt-pc-loco                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateo              as   decimal                no-undo.
    define variable price-rubl-with-tax-loco    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loco    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loco     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loco like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loco like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loco  like ub.doc-line.price-base no-undo.
    define variable vat-base-loco               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loco               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loco           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loco         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loco         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loco          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loco             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loco             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loco              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loco          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdo             as   character              no-undo.
    define variable varinvatp-typeo             as   character              no-undo.
    define variable v-gds-dtl-fact-qnty as decimal no-undo .
    define buffer buf_gds-dtl  for ub.gds-dtl .
    define buffer buf_goods    for ub.goods .
    define buffer buf_trn-doc  for ub.trn-doc .
    define buffer buf_doc-line for ub.doc-line .
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info18 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-line.doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info18 skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
        and buf_gds-dtl.artic     = buf_doc-line.artic
        and buf_gds-dtl.prod-type = buf_doc-line.prod-type
        and buf_gds-dtl.prod-code = buf_doc-line.prod-code
    on error undo, return error
    :
        if buf_trn-doc.doc-type <> 'инв':U
        then do:
            if buf_trn-doc.doc-type = 'при':U
            or buf_trn-doc.doc-type = 'возврат':U
            then do:
                assign
                    v-gds-dtl-fact-qnty = buf_gds-dtl.fact-qnty
                .
            end.
            else do:
                assign
                    v-gds-dtl-fact-qnty = - buf_gds-dtl.fact-qnty
                .
            end.
        end.
        else do:
            assign
                v-gds-dtl-fact-qnty = buf_gds-dtl.doc-qnty
            .
        end.
        if v-gds-dtl-fact-qnty <> 0
        then do:
if buf_trn-doc.ext-doc-type = 'ot':U or
   buf_trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
      and out-vatp_doc-attr.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attr then do:
    assign
      out-vatp-have-vat-slt = yes.
  end.
  else do:
     out-vatp-have-vat-slt = no.
  end.
end.
find first out-vatp_goods where out-vatp_goods.artic     = buf_doc-line.artic     and
                                   out-vatp_goods.prod-type = buf_doc-line.prod-type and
                                   out-vatp_goods.prod-code = buf_doc-line.prod-code no-lock.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-node
  ,input  'empty-scale=request'
  ,output varempty-scale
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * buf_trn-doc.base-rate / buf_trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = buf_trn-doc.doc-code
       and out-vatp_doc-line.artic      = buf_doc-line.artic
       and out-vatp_doc-line.prod-type  = buf_doc-line.prod-type
       and out-vatp_doc-line.prod-code  = buf_doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = buf_trn-doc.doc-code
                               and out-vatp_parts.obj-type   = buf_trn-doc.obj-type
                               and out-vatp_parts.obj-code   = buf_trn-doc.obj-code
                               and out-vatp_parts.artic      = buf_doc-line.artic
                               and out-vatp_parts.prod-type  = buf_doc-line.prod-type
                               and out-vatp_parts.prod-code  = buf_doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbo
  )  .
  if out-vatp_parts.out-code = 'free-zone':U     or
     out-vatp_parts.out-code = 'out-zone':U   or
     out-vatp_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slto = yes.
  end.
  else do:
    find first in-vatp_doc-attro no-lock
      where in-vatp_doc-attro.doc-code  = out-vatp_parts.out-code
        and in-vatp_doc-attro.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attro then do:
      assign
        in-vatp-have-vat-slto = yes.
    end.
    else do:
         in-vatp-have-vat-slto = no.
    end.
  end.
  assign
   price-cli-with-tax-loco = out-vatp_parts.price-cli
   cli-base-rateo          = out-vatp_parts.cli-base-rate.
  ASSIGN   road-tax-base-loco  = (if out-vatp_parts.road-tax-base  = ? then 0 else out-vatp_parts.road-tax-base)
           road-tax-rubl-loco  = (if out-vatp_parts.road-tax-rubl  = ? then 0 else out-vatp_parts.road-tax-rubl).
  ASSIGN  transport-base-loco = (if out-vatp_parts.transport-base = ? then 0 else out-vatp_parts.transport-base)
          transport-rubl-loco = (if out-vatp_parts.transport-rubl = ? then 0 else out-vatp_parts.transport-rubl)
          other-base-loco     = (if out-vatp_parts.other-base     = ? then 0 else out-vatp_parts.other-base)
          other-rubl-loco     = (if out-vatp_parts.other-rubl     = ? then 0 else out-vatp_parts.other-rubl)
          vat-pc-loco         = (if out-vatp_parts.vat-pc         = ? then 0 else out-vatp_parts.vat-pc)
          slt-pc-loco         = (if out-vatp_parts.slt-pc         = ? then 0 else out-vatp_parts.slt-pc).
          ASSIGN   slt-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
    ASSIGN   slt-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
  assign
    exch-rate-cli-loco = (out-vatp_parts.price-rubl - transport-rubl-loco - other-rubl-loco - road-tax-rubl-loco - (if out-vatp_parts.vat-type <> 'в т. ч.':U then vat-rubl-loco else 0) - (if out-vatp_parts.slt-type <> 'в т. ч.':U then slt-rubl-loco else 0)) / out-vatp_parts.price-cli .
  assign
    slt-cli-loco        = slt-rubl-loco       / exch-rate-cli-loco
    vat-cli-loco        = vat-rubl-loco       / exch-rate-cli-loco
    road-tax-cli-loco   = road-tax-rubl-loco  / exch-rate-cli-loco
    transport-cli-loco  = 0
    other-cli-loco      = 0
  .
ASSIGN
          price-base-without-tax-loco = price-base-with-tax-loco - vat-base-loco - slt-base-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))
    price-rubl-without-tax-loco = price-rubl-with-tax-loco - vat-rubl-loco - slt-rubl-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))
.
      assign
        varprice-base-cons = varprice-base-cons + (price-base-with-tax-loco - (if road-tax-base-loco = ? then 0 else road-tax-base-loco))* out-vatp_parts.fact-qnty
        varprice-rubl-cons = varprice-rubl-cons + (price-rubl-with-tax-loco - (if road-tax-rubl-loco = ? then 0 else road-tax-rubl-loco))* out-vatp_parts.fact-qnty.
      assign
        varis-cons-parts-have = yes
        varcons-qnty          = varcons-qnty + out-vatp_parts.fact-qnty.
    end.
    assign
      varfact-qnty = varfact-qnty + out-vatp_parts.fact-qnty.
  end.
end.
assign
  varprice-base-cons = varprice-base-cons / varcons-qnty
  varprice-rubl-cons = varprice-rubl-cons / varcons-qnty.
if varprice-base-cons = ? then do:
  assign
    varprice-base-cons = 0.
end.
if varprice-rubl-cons = ? then do:
  assign
    varprice-rubl-cons = 0.
end.
assign
    slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-base-sale            = buf_gds-dtl.discnt-base
  price-base-with-tax-sale    = (buf_gds-dtl.price-base - buf_gds-dtl.discnt-base)
    slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-rubl-sale            = buf_gds-dtl.discnt-rubl
  price-rubl-with-tax-sale    = (buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl)
  .
if buf_trn-doc.doc-type = 'инв':U then do:
  assign
    varfact-qnty = buf_gds-dtl.doc-qnty.
end.
else do:
  assign
    varfact-qnty = buf_gds-dtl.fact-qnty.
end.
if varis-cons-parts-have = no then do:
  assign
        vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
        vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc).
end.
else do:
  if buf_trn-doc.doc-type = 'инв':U then do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
  else do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-base-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-rubl-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
end.
assign
price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
            ASSIGN
                p-fact-qnty           = p-fact-qnty     + v-gds-dtl-fact-qnty
                p-sum-base            = p-sum-base      + price-base-with-tax-sale  * v-gds-dtl-fact-qnty
                p-sum-rubl            = p-sum-rubl      + price-rubl-with-tax-sale  * v-gds-dtl-fact-qnty
                p-vat-base            = p-vat-base      + vat-base-sale             * v-gds-dtl-fact-qnty
                p-vat-rubl            = p-vat-rubl      + vat-rubl-sale             * v-gds-dtl-fact-qnty
                p-slt-base            = p-slt-base      + slt-base-sale             * v-gds-dtl-fact-qnty
                p-slt-rubl            = p-slt-rubl      + slt-rubl-sale             * v-gds-dtl-fact-qnty
                p-road-tax-base       = p-road-tax-base + road-tax-base-sale        * v-gds-dtl-fact-qnty
                p-road-tax-rubl       = p-road-tax-rubl + road-tax-rubl-sale        * v-gds-dtl-fact-qnty
                p-excise-base         = p-excise-base   + excise-base-sale          * v-gds-dtl-fact-qnty
                p-excise-rubl         = p-excise-rubl   + excise-rubl-sale          * v-gds-dtl-fact-qnty
                p-other-base          = p-other-base    + discnt-base-sale          * v-gds-dtl-fact-qnty
                p-other-rubl          = p-other-rubl    + discnt-rubl-sale          * v-gds-dtl-fact-qnty
            .
        end.
    end.
    assign
        p-transport-base      = 0
        p-transport-rubl      = 0
        p-vat-pc              = buf_doc-line.vat-pc
        p-slt-pc              = buf_doc-line.slt-pc
    .
  end.
  if p-fact-qnty      = ?
  or p-vat-pc         = ?
  or p-slt-pc         = ?
  or p-sum-base       = ?
  or p-sum-rubl       = ?
  or p-vat-base       = ?
  or p-vat-rubl       = ?
  or p-slt-base       = ?
  or p-slt-rubl       = ?
  or p-road-tax-base  = ?
  or p-road-tax-rubl  = ?
  or p-transport-base = ?
  or p-transport-rubl = ?
  or p-other-base     = ?
  or p-other-rubl     = ?
  or p-excise-base    = ?
  or p-excise-rubl    = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      vss-include-info18 skip
      "Получены неопределенные значения" skip
      "Документ" p-doc-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "fact-qnty     " p-fact-qnty      skip
      "vat-pc        " p-vat-pc         skip
      "slt-pc        " p-slt-pc         skip
      "sum-base      " p-sum-base       skip
      "sum-rubl      " p-sum-rubl       skip
      "vat-base      " p-vat-base       skip
      "vat-rubl      " p-vat-rubl       skip
      "slt-base      " p-slt-base       skip
      "slt-rubl      " p-slt-rubl       skip
      "road-tax-base " p-road-tax-base  skip
      "road-tax-rubl " p-road-tax-rubl  skip
      "transport-base" p-transport-base skip
      "transport-rubl" p-transport-rubl skip
      "other-base    " p-other-base     skip
      "other-rubl    " p-other-rubl     skip
      "excise-base   " p-excise-base    skip
      "excise-rubl   " p-excise-rubl    skip
      view-as alert-box error .
    undo, return error .
  end.
end procedure.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable sym1  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym2  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym3  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym4  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym5  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym6  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym7  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym8  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym9  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym10 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym11 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym12 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym13 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym14 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym15 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym16 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym17 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym18 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym19 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym20 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym21 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym22 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym23 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym24 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym25 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym26 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym27 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable temp1 as integer   no-undo.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in my-handle
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable base-type as character no-undo .
define variable base-code as integer   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#gds-engl as logical   no-undo .
define variable vv-exch-rate  as decimal   no-undo .
define variable vv-exch-scale as decimal   no-undo .
define variable v-cntxt-host-name-obj as character no-undo .
if v-cntxt-level = 'object':U then do:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-cntxt-host-code-obj
  ,output v-cntxt-host-name-obj
  )  .
end.
if v-cntxt-level = 'firm':U then do:
  find first ub.clients no-lock where
             ub.clients.obj-type = 'орг':U and
             ub.clients.obj-code = v-cntxt-host-code-obj no-error .
if error-status :error then v-cntxt-host-name-obj = ? .
   else v-cntxt-host-name-obj = ub.clients.obj-name.
end.
if v-cntxt-level = 'object':U
or v-cntxt-level = 'firm':U
then do:
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  base-code
  ,input  today
  ,output vv-exch-rate
  ,output vv-exch-scale
  ,output base-type
  )  .
end.
run get-report-num in my-handle ( output g#report-num ).
run get-gds-engl in my-handle ( output g#gds-engl ) .
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
def var vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info30 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
 define stream macr_excel .
 define variable v-file-name as character no-undo .
procedure macr_excel_char :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .
      put  stream macr_excel unformatted
        substitute('formula(&3,"r&1c&2")', p-row , p-col , format-excel-text-macr ( p-val) ) skip  .
 end.
end procedure.
procedure macr_excel_sum :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as decimal   no-undo .
 define input parameter  p-row as integer   no-undo .
 define input parameter  p-col as integer   no-undo .
 define input parameter  p-typ as integer   no-undo .
 if p-val = ? then assign p-val = 0 .
 define variable ss as character no-undo .
 assign
   ss = string( Round( p-val, p-typ) )
 .
 put  stream macr_excel unformatted
      substitute('formula(&3,"r&1c&2")', p-row , p-col , ss ) skip  .
 end.
END procedure.
procedure macr_excel_date :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .
    put stream macr_excel unformatted
          substitute('select("r&1c&2")', p-row , p-col ) + chr(10) .
    put stream macr_excel unformatted 'format.number("dd/mm/yy")' + chr(10) .
    put stream macr_excel unformatted
          substitute('formula(&3,"r&1c&2")', p-row , p-col ,  p-val ) + chr(10)  .
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
   substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) skip .
  if p-color <> ? then do:
     put  stream macr_excel unformatted
       substitute('patterns(1,,&1,true)', p-color )  skip  .
  end.
  put  stream macr_excel unformatted
       substitute('format.font(,&1,&2,&3)' , p-size,
                                        string ( p-bold  , "true/false" ) ,
                                        string ( p-italic , "true/false" )
                                        ) skip .
 end.
end procedure.
procedure macr_cell_bordur :
 do
 on error undo, return error return-value
 :
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .
  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  put  stream macr_excel unformatted
   substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) skip .
  put  stream macr_excel unformatted
       'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  skip
       'ALIGNMENT(3 , , 4 , 4 ,)'   skip
       .
 end.
end procedure.
procedure macr_cell_merge :
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .
 do
 on error undo, return error return-value
 :
  if p-row-2 = ?
  then do:
    assign
      p-row-2 = p-row
    .
  end.
  if p-col-2 = ?
  then do:
    assign
      p-col-2 = p-col
    .
  end.
  put stream macr_excel unformatted
    substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) chr(10)
    'border(1,1,1,1,1,,0,0,0,0,0)':u chr(10)
    'alignment(7,true,2,4)':u chr(10)
    .
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
define Stream OutStream.
do
on error undo, return error
:
define buffer buf_goods    for goods.
define buffer buf_clients  for clients.
define buffer buf_gds-obj  for gds-obj.
define buffer buf_gds-grp  for gds-grp.
define buffer buf_trn-doc  for trn-doc.
define buffer buf_doc-line for doc-line.
define buffer buf_stk-line for stk-line.
DEFINE temp-table temp-DiscSales no-undo
    field   qnty             as decimal
    field   ostat            as decimal
    field   sum-sale         as decimal
    field   sum-cost         as decimal
    field   ostat1           as decimal
    field   qnty1            as decimal
    field   sum-sale1        as decimal
    field   sum-cost1        as decimal
    field   obj-type         as  char
    field   obj-code         as  integer
    field   prod-type        as  char
    field   prod-code        as  integer
    field   artic            as  char
    field   gds-name         as  char
    field   grp-name         as  char
    field   unit-base        as  char
    field   b-code           as  integer
    field   grp-code         as  integer
    field   full-grp-name    as  char
    INDEX pi  IS PRIMARY   obj-type obj-code artic  prod-type prod-code
    INDEX pi1              b-code
    INDEX pi2              full-grp-name
  .
  DEFINE temp-table temp-grp-sum no-undo
    field  qnty             as decimal
    field  ostat            as decimal
    field  sum-sale         as decimal
    field  sum-cost         as decimal
    field  qnty1            as decimal
    field  ostat1           as decimal
    field  sum-sale1        as decimal
    field  sum-cost1        as decimal
    field  grp              as character
    field  full_grp         as character
    field  num              as integer
    INDEX pi  IS PRIMARY unique num
    INDEX pi1 is unique full_grp
  .
  define variable  v-fact-order-start     as decimal   no-undo .
  define variable  v-fact-order-end       as decimal   no-undo .
  define variable  v-fact-order-start1    as decimal   no-undo .
  define variable  v-fact-order-end1      as decimal   no-undo .
  define variable p-fact-qnty     as decimal   no-undo .
  define variable p-cost-rubl     as decimal   no-undo .
  define variable p-sale-rubl     as decimal   no-undo .
  define variable t-dec           as decimal   no-undo .
  define variable v-row       as integer   no-undo .
  define variable v-col       as integer   no-undo .
  define variable v-ind       as integer   no-undo initial 1 .
  define variable titul           as logical   no-undo .
  define variable v-level         as integer   no-undo .
  define variable v-old-level as integer initial 0  no-undo .
  define variable ind             as integer   no-undo .
  define variable ret as logical   no-undo .
  define variable ii as integer initial 0  no-undo .
  define variable Counter1               as integer   no-undo .
  define variable CurrGrpName            as character no-undo .
  define variable Line                   as character no-undo .
  define variable sfind as character no-undo .
  define variable jj as integer   no-undo .
  define variable udel as decimal   no-undo .
  define variable v-NameString  as character no-undo .
  define variable v-qnty        as decimal   no-undo .
  define variable v-ostat       as decimal   no-undo .
  define variable v-sum-sale    as decimal   no-undo .
  define variable v-sum-cost    as decimal   no-undo .
  define variable v-qnty1       as decimal   no-undo .
  define variable v-ostat1      as decimal   no-undo .
  define variable v-sum-sale1   as decimal   no-undo .
  define variable v-sum-cost1   as decimal   no-undo .
  define variable  cur-qnty             as decimal initial 0  no-undo .
  define variable  cur-ostat            as decimal initial 0  no-undo .
  define variable  cur-sum-sale         as decimal initial 0  no-undo .
  define variable  cur-sum-cost         as decimal initial 0  no-undo .
  define variable  cur-qnty1            as decimal initial 0  no-undo .
  define variable  cur-ostat1           as decimal initial 0  no-undo .
  define variable  cur-sum-sale1        as decimal initial 0  no-undo .
  define variable  cur-sum-cost1        as decimal initial 0  no-undo .
  define variable  all-qnty             as decimal initial 0  no-undo .
  define variable  all-ostat            as decimal initial 0  no-undo .
  define variable  all-sum-sale         as decimal initial 0  no-undo .
  define variable  all-sum-cost         as decimal initial 0  no-undo .
  define variable  all-qnty1            as decimal initial 0  no-undo .
  define variable  all-ostat1           as decimal initial 0  no-undo .
  define variable  all-sum-sale1        as decimal initial 0  no-undo .
  define variable  all-sum-cost1        as decimal initial 0  no-undo .
  define variable  all1-qnty             as decimal initial 0  no-undo .
  define variable  all1-ostat            as decimal initial 0  no-undo .
  define variable  all1-sum-sale         as decimal initial 0  no-undo .
  define variable  all1-sum-cost         as decimal initial 0  no-undo .
  define variable  all1-qnty1            as decimal initial 0  no-undo .
  define variable  all1-ostat1           as decimal initial 0  no-undo .
  define variable  all1-sum-sale1        as decimal initial 0  no-undo .
  define variable  all1-sum-cost1        as decimal initial 0  no-undo .
  define variable  v-all-sum             as decimal initial 0  no-undo .
  define variable  v-all-qnty            as decimal initial 0  no-undo .
  run day-begin-fact-order in this-procedure ( input x-date-start,        output v-fact-order-start ).
  run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),  output v-fact-order-end ).
  run day-begin-fact-order in this-procedure ( input x-date-start1,       output v-fact-order-start1 ).
  run day-begin-fact-order in this-procedure ( input ( x-date-end1 + 1 ), output v-fact-order-end1 ).
  assign
    Counter1 = 0 .
  .
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
assign v-account = ( if integer( 25 ) = 0 then 100 else integer( 25 ) ).
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
  for each temp-DiscSales :
    delete temp-DiscSales .
  end.
  for each obj-list :
    case x-SelectGood :
      when 1 then do:
        for each buf_gds-obj no-lock
          where buf_gds-obj.obj-type  = obj-list.obj-type
            and buf_gds-obj.obj-code  = obj-list.obj-code
        :
          find first buf_goods no-lock  where buf_goods.gds-code = buf_gds-obj.gds-code  .
define variable vss-include-info31 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  if buf_gds-obj.last-doc = ? then next .
  if buf_gds-obj.last-doc < x-date-start and buf_gds-obj.fact-qnty = 0 and buf_gds-obj.avrg-qnty = 0 and buf_gds-obj.fact-sale =0 and buf_gds-obj.fact-base = 0 then next .
  assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
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
  assign
    v-qnty      = 0
    v-ostat     = 0
    v-sum-sale  = 0
    v-sum-cost  = 0
    v-qnty1     = 0
    v-ostat1    = 0
    v-sum-sale1 = 0
    v-sum-cost1 = 0
    p-sale-rubl = 0
    p-cost-rubl = 0
    p-fact-qnty = 0
  .
  if x-SET_PAY_TYPE = 1 then assign sfind = 'crsa':U .
  else                       assign sfind = 'cost':U .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = sfind
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order  < v-fact-order-end
    use-index category no-error .
  if available buf_stk-line then  assign v-ostat  = buf_stk-line.sum-rubl .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = sfind
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order  < v-fact-order-end1
    use-index category no-error .
  if available buf_stk-line then  assign v-ostat1  = buf_stk-line.sum-rubl .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'csdt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order < v-fact-order-end
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      v-sum-cost  = - buf_stk-line.sum-rubl
      v-qnty      = - buf_stk-line.fact-qnty
    .
  end.
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'sadt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order < v-fact-order-end
    use-index category no-error .
  if available buf_stk-line then  assign  v-sum-sale  = - buf_stk-line.sum-rubl  .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'csdt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order <= v-fact-order-start
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      v-sum-cost  = v-sum-cost + buf_stk-line.sum-rubl
      v-qnty      = v-qnty     + buf_stk-line.fact-qnty
    .
  end.
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'sadt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order <= v-fact-order-start
    use-index category no-error .
  if available buf_stk-line then  assign  v-sum-sale  = v-sum-sale + buf_stk-line.sum-rubl  .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'csdt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order < v-fact-order-end1
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      v-sum-cost1  = - buf_stk-line.sum-rubl
      v-qnty1      = - buf_stk-line.fact-qnty
    .
  end.
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'sadt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order < v-fact-order-end1
    use-index category no-error .
  if available buf_stk-line then assign  v-sum-sale1  = - buf_stk-line.sum-rubl  .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'csdt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order <= v-fact-order-start1
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      v-sum-cost1  = v-sum-cost1 + buf_stk-line.sum-rubl
      v-qnty1      = v-qnty1     + buf_stk-line.fact-qnty
    .
  end.
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'sadt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order <= v-fact-order-start1
    use-index category no-error .
  if available buf_stk-line then assign  v-sum-sale1  = v-sum-sale1 + buf_stk-line.sum-rubl  .
  if x-return = yes then do:
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'csdt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order < v-fact-order-end
      use-index category no-error .
    if available buf_stk-line then do:
      assign
        v-sum-cost  = v-sum-cost - buf_stk-line.sum-rubl
        v-qnty      = v-qnty - buf_stk-line.fact-qnty
      .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'sadt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order < v-fact-order-end
      use-index category no-error .
    if available buf_stk-line then  assign  v-sum-sale  = v-sum-sale - buf_stk-line.sum-rubl  .
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'csdt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .
    if available buf_stk-line then do:
      assign
        v-sum-cost  = v-sum-cost + buf_stk-line.sum-rubl
        v-qnty      = v-qnty     + buf_stk-line.fact-qnty
      .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'sadt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .
    if available buf_stk-line then  assign  v-sum-sale  = v-sum-sale + buf_stk-line.sum-rubl  .
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'csdt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order < v-fact-order-end1
      use-index category no-error .
    if available buf_stk-line then do:
      assign
        v-sum-cost1  = v-sum-cost1 - buf_stk-line.sum-rubl
        v-qnty1      = v-qnty1     - buf_stk-line.fact-qnty
      .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'sadt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order < v-fact-order-end1
      use-index category no-error .
    if available buf_stk-line then assign  v-sum-sale1  = v-sum-sale1 - buf_stk-line.sum-rubl  .
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'csdt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start1
      use-index category no-error .
    if available buf_stk-line then do:
      assign
        v-sum-cost1  = v-sum-cost1 + buf_stk-line.sum-rubl
        v-qnty1      = v-qnty1     + buf_stk-line.fact-qnty
      .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'sadt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start1
      use-index category no-error .
    if available buf_stk-line then assign  v-sum-sale1  = v-sum-sale1 + buf_stk-line.sum-rubl  .
 end.
  if  ( x-ShowNull = yes ) or (v-sum-sale <> 0 or v-sum-cost <> 0 or v-sum-sale1 <> 0 or v-sum-cost1 <> 0 or v-qnty <> 0 or v-qnty1 <> 0 or v-ostat <> 0) then do:
    if x-SumObj = yes then do:
      find first temp-DiscSales
        where temp-DiscSales.obj-type     = buf_gds-obj.obj-type
          and temp-DiscSales.obj-code     = buf_gds-obj.obj-code
          and temp-DiscSales.artic        = buf_goods.artic
          and temp-DiscSales.prod-type    = buf_goods.prod-type
          and temp-DiscSales.prod-code    = buf_goods.prod-code
      no-error .
    end.
    else do:
      find first temp-DiscSales
        where temp-DiscSales.artic        = buf_goods.artic
          and temp-DiscSales.prod-type    = buf_goods.prod-type
          and temp-DiscSales.prod-code    = buf_goods.prod-code
      no-error .
    end.
    assign
      v-all-sum  = v-all-sum + ( if x-SET_PAY_TYPE = 1 then v-sum-sale else v-sum-cost )
      v-all-qnty = v-all-qnty     + v-qnty
    .
    if available temp-DiscSales then do:
      assign
        temp-DiscSales.qnty      = temp-DiscSales.qnty      + v-qnty
        temp-DiscSales.ostat     = temp-DiscSales.ostat     + v-ostat
        temp-DiscSales.sum-cost  = temp-DiscSales.sum-cost  + v-sum-cost
        temp-DiscSales.sum-sale  = temp-DiscSales.sum-sale  + v-sum-sale
        temp-DiscSales.qnty1     = temp-DiscSales.qnty1     + v-qnty1
        temp-DiscSales.ostat1    = temp-DiscSales.ostat1    + v-ostat1
        temp-DiscSales.sum-cost1 = temp-DiscSales.sum-cost1 + v-sum-cost1
        temp-DiscSales.sum-sale1 = temp-DiscSales.sum-sale1 + v-sum-sale1
      .
    end.
    else do:
      create temp-DiscSales .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output temp-DiscSales.b-code
  ) no-error .
      assign
        temp-DiscSales.obj-type  = buf_gds-obj.obj-type
        temp-DiscSales.obj-code  = buf_gds-obj.obj-code
        temp-DiscSales.artic     = buf_goods.artic
        temp-DiscSales.prod-type = buf_goods.prod-type
        temp-DiscSales.prod-code = buf_goods.prod-code
        temp-DiscSales.full-grp-name = trim( buf_goods.grp-name )
        temp-DiscSales.grp-name  = entry ( num-entries( buf_goods.grp-name, chr(47) ) - 1, buf_goods.grp-name, chr(47) )
        temp-DiscSales.unit-base = buf_goods.unit-base
        temp-DiscSales.grp-code  = buf_goods.grp-code
        temp-DiscSales.qnty      = v-qnty
        temp-DiscSales.ostat     = v-ostat
        temp-DiscSales.sum-cost  = v-sum-cost
        temp-DiscSales.sum-sale  = v-sum-sale
        temp-DiscSales.qnty1     = v-qnty1
        temp-DiscSales.ostat1    = v-ostat1
        temp-DiscSales.sum-cost1 = v-sum-cost1
        temp-DiscSales.sum-sale1 = v-sum-sale1
      .
      if g#gds-engl then assign temp-DiscSales.gds-name = buf_goods.engl-name.
      else               assign temp-DiscSales.gds-name = buf_goods.gds-name.
    end.
  end.
        end.
      end.
      when 3 then do:
        for each G#cli ,
            each buf_gds-obj  no-lock
          where buf_gds-obj.obj-type  = obj-list.obj-type
            and buf_gds-obj.obj-code  = obj-list.obj-code
            and buf_gds-obj.prod-type = G#cli.obj-type
            and buf_gds-obj.prod-code = G#cli.obj-code
           use-index pi  :
          find first buf_goods no-lock
            where buf_goods.gds-code = buf_gds-obj.gds-code
          .
define variable vss-include-info32 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  if buf_gds-obj.last-doc = ? then next .
  if buf_gds-obj.last-doc < x-date-start and buf_gds-obj.fact-qnty = 0 and buf_gds-obj.avrg-qnty = 0 and buf_gds-obj.fact-sale =0 and buf_gds-obj.fact-base = 0 then next .
  assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
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
  assign
    v-qnty      = 0
    v-ostat     = 0
    v-sum-sale  = 0
    v-sum-cost  = 0
    v-qnty1     = 0
    v-ostat1    = 0
    v-sum-sale1 = 0
    v-sum-cost1 = 0
    p-sale-rubl = 0
    p-cost-rubl = 0
    p-fact-qnty = 0
  .
  if x-SET_PAY_TYPE = 1 then assign sfind = 'crsa':U .
  else                       assign sfind = 'cost':U .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = sfind
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order  < v-fact-order-end
    use-index category no-error .
  if available buf_stk-line then  assign v-ostat  = buf_stk-line.sum-rubl .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = sfind
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order  < v-fact-order-end1
    use-index category no-error .
  if available buf_stk-line then  assign v-ostat1  = buf_stk-line.sum-rubl .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'csdt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order < v-fact-order-end
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      v-sum-cost  = - buf_stk-line.sum-rubl
      v-qnty      = - buf_stk-line.fact-qnty
    .
  end.
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'sadt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order < v-fact-order-end
    use-index category no-error .
  if available buf_stk-line then  assign  v-sum-sale  = - buf_stk-line.sum-rubl  .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'csdt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order <= v-fact-order-start
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      v-sum-cost  = v-sum-cost + buf_stk-line.sum-rubl
      v-qnty      = v-qnty     + buf_stk-line.fact-qnty
    .
  end.
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'sadt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order <= v-fact-order-start
    use-index category no-error .
  if available buf_stk-line then  assign  v-sum-sale  = v-sum-sale + buf_stk-line.sum-rubl  .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'csdt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order < v-fact-order-end1
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      v-sum-cost1  = - buf_stk-line.sum-rubl
      v-qnty1      = - buf_stk-line.fact-qnty
    .
  end.
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'sadt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order < v-fact-order-end1
    use-index category no-error .
  if available buf_stk-line then assign  v-sum-sale1  = - buf_stk-line.sum-rubl  .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'csdt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order <= v-fact-order-start1
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      v-sum-cost1  = v-sum-cost1 + buf_stk-line.sum-rubl
      v-qnty1      = v-qnty1     + buf_stk-line.fact-qnty
    .
  end.
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'sadt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order <= v-fact-order-start1
    use-index category no-error .
  if available buf_stk-line then assign  v-sum-sale1  = v-sum-sale1 + buf_stk-line.sum-rubl  .
  if x-return = yes then do:
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'csdt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order < v-fact-order-end
      use-index category no-error .
    if available buf_stk-line then do:
      assign
        v-sum-cost  = v-sum-cost - buf_stk-line.sum-rubl
        v-qnty      = v-qnty - buf_stk-line.fact-qnty
      .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'sadt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order < v-fact-order-end
      use-index category no-error .
    if available buf_stk-line then  assign  v-sum-sale  = v-sum-sale - buf_stk-line.sum-rubl  .
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'csdt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .
    if available buf_stk-line then do:
      assign
        v-sum-cost  = v-sum-cost + buf_stk-line.sum-rubl
        v-qnty      = v-qnty     + buf_stk-line.fact-qnty
      .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'sadt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .
    if available buf_stk-line then  assign  v-sum-sale  = v-sum-sale + buf_stk-line.sum-rubl  .
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'csdt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order < v-fact-order-end1
      use-index category no-error .
    if available buf_stk-line then do:
      assign
        v-sum-cost1  = v-sum-cost1 - buf_stk-line.sum-rubl
        v-qnty1      = v-qnty1     - buf_stk-line.fact-qnty
      .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'sadt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order < v-fact-order-end1
      use-index category no-error .
    if available buf_stk-line then assign  v-sum-sale1  = v-sum-sale1 - buf_stk-line.sum-rubl  .
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'csdt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start1
      use-index category no-error .
    if available buf_stk-line then do:
      assign
        v-sum-cost1  = v-sum-cost1 + buf_stk-line.sum-rubl
        v-qnty1      = v-qnty1     + buf_stk-line.fact-qnty
      .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'sadt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start1
      use-index category no-error .
    if available buf_stk-line then assign  v-sum-sale1  = v-sum-sale1 + buf_stk-line.sum-rubl  .
 end.
  if  ( x-ShowNull = yes ) or (v-sum-sale <> 0 or v-sum-cost <> 0 or v-sum-sale1 <> 0 or v-sum-cost1 <> 0 or v-qnty <> 0 or v-qnty1 <> 0 or v-ostat <> 0) then do:
    if x-SumObj = yes then do:
      find first temp-DiscSales
        where temp-DiscSales.obj-type     = buf_gds-obj.obj-type
          and temp-DiscSales.obj-code     = buf_gds-obj.obj-code
          and temp-DiscSales.artic        = buf_goods.artic
          and temp-DiscSales.prod-type    = buf_goods.prod-type
          and temp-DiscSales.prod-code    = buf_goods.prod-code
      no-error .
    end.
    else do:
      find first temp-DiscSales
        where temp-DiscSales.artic        = buf_goods.artic
          and temp-DiscSales.prod-type    = buf_goods.prod-type
          and temp-DiscSales.prod-code    = buf_goods.prod-code
      no-error .
    end.
    assign
      v-all-sum  = v-all-sum + ( if x-SET_PAY_TYPE = 1 then v-sum-sale else v-sum-cost )
      v-all-qnty = v-all-qnty     + v-qnty
    .
    if available temp-DiscSales then do:
      assign
        temp-DiscSales.qnty      = temp-DiscSales.qnty      + v-qnty
        temp-DiscSales.ostat     = temp-DiscSales.ostat     + v-ostat
        temp-DiscSales.sum-cost  = temp-DiscSales.sum-cost  + v-sum-cost
        temp-DiscSales.sum-sale  = temp-DiscSales.sum-sale  + v-sum-sale
        temp-DiscSales.qnty1     = temp-DiscSales.qnty1     + v-qnty1
        temp-DiscSales.ostat1    = temp-DiscSales.ostat1    + v-ostat1
        temp-DiscSales.sum-cost1 = temp-DiscSales.sum-cost1 + v-sum-cost1
        temp-DiscSales.sum-sale1 = temp-DiscSales.sum-sale1 + v-sum-sale1
      .
    end.
    else do:
      create temp-DiscSales .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output temp-DiscSales.b-code
  ) no-error .
      assign
        temp-DiscSales.obj-type  = buf_gds-obj.obj-type
        temp-DiscSales.obj-code  = buf_gds-obj.obj-code
        temp-DiscSales.artic     = buf_goods.artic
        temp-DiscSales.prod-type = buf_goods.prod-type
        temp-DiscSales.prod-code = buf_goods.prod-code
        temp-DiscSales.full-grp-name = trim( buf_goods.grp-name )
        temp-DiscSales.grp-name  = entry ( num-entries( buf_goods.grp-name, chr(47) ) - 1, buf_goods.grp-name, chr(47) )
        temp-DiscSales.unit-base = buf_goods.unit-base
        temp-DiscSales.grp-code  = buf_goods.grp-code
        temp-DiscSales.qnty      = v-qnty
        temp-DiscSales.ostat     = v-ostat
        temp-DiscSales.sum-cost  = v-sum-cost
        temp-DiscSales.sum-sale  = v-sum-sale
        temp-DiscSales.qnty1     = v-qnty1
        temp-DiscSales.ostat1    = v-ostat1
        temp-DiscSales.sum-cost1 = v-sum-cost1
        temp-DiscSales.sum-sale1 = v-sum-sale1
      .
      if g#gds-engl then assign temp-DiscSales.gds-name = buf_goods.engl-name.
      else               assign temp-DiscSales.gds-name = buf_goods.gds-name.
    end.
  end.
        end.
      end .
      when 2 then do:
        for each tmp#grp :
          find first buf_gds-grp no-lock
            where buf_gds-grp.node-code = tmp#grp.node-code
          .
          run grplib-get-full-name in this-procedure( input buf_gds-grp.node-code, output CurrGrpName ) .
          for each buf_gds-obj no-lock
            where buf_gds-obj.obj-type  = obj-list.obj-type
              and buf_gds-obj.obj-code  = obj-list.obj-code
              and buf_gds-obj.grp-name begins CurrGrpName
            use-index obj-grp :
            find first buf_goods no-lock
              where buf_goods.gds-code = buf_gds-obj.gds-code
            .
define variable vss-include-info33 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  if buf_gds-obj.last-doc = ? then next .
  if buf_gds-obj.last-doc < x-date-start and buf_gds-obj.fact-qnty = 0 and buf_gds-obj.avrg-qnty = 0 and buf_gds-obj.fact-sale =0 and buf_gds-obj.fact-base = 0 then next .
  assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
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
  assign
    v-qnty      = 0
    v-ostat     = 0
    v-sum-sale  = 0
    v-sum-cost  = 0
    v-qnty1     = 0
    v-ostat1    = 0
    v-sum-sale1 = 0
    v-sum-cost1 = 0
    p-sale-rubl = 0
    p-cost-rubl = 0
    p-fact-qnty = 0
  .
  if x-SET_PAY_TYPE = 1 then assign sfind = 'crsa':U .
  else                       assign sfind = 'cost':U .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = sfind
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order  < v-fact-order-end
    use-index category no-error .
  if available buf_stk-line then  assign v-ostat  = buf_stk-line.sum-rubl .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = sfind
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order  < v-fact-order-end1
    use-index category no-error .
  if available buf_stk-line then  assign v-ostat1  = buf_stk-line.sum-rubl .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'csdt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order < v-fact-order-end
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      v-sum-cost  = - buf_stk-line.sum-rubl
      v-qnty      = - buf_stk-line.fact-qnty
    .
  end.
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'sadt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order < v-fact-order-end
    use-index category no-error .
  if available buf_stk-line then  assign  v-sum-sale  = - buf_stk-line.sum-rubl  .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'csdt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order <= v-fact-order-start
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      v-sum-cost  = v-sum-cost + buf_stk-line.sum-rubl
      v-qnty      = v-qnty     + buf_stk-line.fact-qnty
    .
  end.
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'sadt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order <= v-fact-order-start
    use-index category no-error .
  if available buf_stk-line then  assign  v-sum-sale  = v-sum-sale + buf_stk-line.sum-rubl  .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'csdt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order < v-fact-order-end1
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      v-sum-cost1  = - buf_stk-line.sum-rubl
      v-qnty1      = - buf_stk-line.fact-qnty
    .
  end.
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'sadt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order < v-fact-order-end1
    use-index category no-error .
  if available buf_stk-line then assign  v-sum-sale1  = - buf_stk-line.sum-rubl  .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'csdt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order <= v-fact-order-start1
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      v-sum-cost1  = v-sum-cost1 + buf_stk-line.sum-rubl
      v-qnty1      = v-qnty1     + buf_stk-line.fact-qnty
    .
  end.
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'sadt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order <= v-fact-order-start1
    use-index category no-error .
  if available buf_stk-line then assign  v-sum-sale1  = v-sum-sale1 + buf_stk-line.sum-rubl  .
  if x-return = yes then do:
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'csdt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order < v-fact-order-end
      use-index category no-error .
    if available buf_stk-line then do:
      assign
        v-sum-cost  = v-sum-cost - buf_stk-line.sum-rubl
        v-qnty      = v-qnty - buf_stk-line.fact-qnty
      .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'sadt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order < v-fact-order-end
      use-index category no-error .
    if available buf_stk-line then  assign  v-sum-sale  = v-sum-sale - buf_stk-line.sum-rubl  .
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'csdt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .
    if available buf_stk-line then do:
      assign
        v-sum-cost  = v-sum-cost + buf_stk-line.sum-rubl
        v-qnty      = v-qnty     + buf_stk-line.fact-qnty
      .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'sadt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .
    if available buf_stk-line then  assign  v-sum-sale  = v-sum-sale + buf_stk-line.sum-rubl  .
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'csdt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order < v-fact-order-end1
      use-index category no-error .
    if available buf_stk-line then do:
      assign
        v-sum-cost1  = v-sum-cost1 - buf_stk-line.sum-rubl
        v-qnty1      = v-qnty1     - buf_stk-line.fact-qnty
      .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'sadt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order < v-fact-order-end1
      use-index category no-error .
    if available buf_stk-line then assign  v-sum-sale1  = v-sum-sale1 - buf_stk-line.sum-rubl  .
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'csdt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start1
      use-index category no-error .
    if available buf_stk-line then do:
      assign
        v-sum-cost1  = v-sum-cost1 + buf_stk-line.sum-rubl
        v-qnty1      = v-qnty1     + buf_stk-line.fact-qnty
      .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'sadt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start1
      use-index category no-error .
    if available buf_stk-line then assign  v-sum-sale1  = v-sum-sale1 + buf_stk-line.sum-rubl  .
 end.
  if  ( x-ShowNull = yes ) or (v-sum-sale <> 0 or v-sum-cost <> 0 or v-sum-sale1 <> 0 or v-sum-cost1 <> 0 or v-qnty <> 0 or v-qnty1 <> 0 or v-ostat <> 0) then do:
    if x-SumObj = yes then do:
      find first temp-DiscSales
        where temp-DiscSales.obj-type     = buf_gds-obj.obj-type
          and temp-DiscSales.obj-code     = buf_gds-obj.obj-code
          and temp-DiscSales.artic        = buf_goods.artic
          and temp-DiscSales.prod-type    = buf_goods.prod-type
          and temp-DiscSales.prod-code    = buf_goods.prod-code
      no-error .
    end.
    else do:
      find first temp-DiscSales
        where temp-DiscSales.artic        = buf_goods.artic
          and temp-DiscSales.prod-type    = buf_goods.prod-type
          and temp-DiscSales.prod-code    = buf_goods.prod-code
      no-error .
    end.
    assign
      v-all-sum  = v-all-sum + ( if x-SET_PAY_TYPE = 1 then v-sum-sale else v-sum-cost )
      v-all-qnty = v-all-qnty     + v-qnty
    .
    if available temp-DiscSales then do:
      assign
        temp-DiscSales.qnty      = temp-DiscSales.qnty      + v-qnty
        temp-DiscSales.ostat     = temp-DiscSales.ostat     + v-ostat
        temp-DiscSales.sum-cost  = temp-DiscSales.sum-cost  + v-sum-cost
        temp-DiscSales.sum-sale  = temp-DiscSales.sum-sale  + v-sum-sale
        temp-DiscSales.qnty1     = temp-DiscSales.qnty1     + v-qnty1
        temp-DiscSales.ostat1    = temp-DiscSales.ostat1    + v-ostat1
        temp-DiscSales.sum-cost1 = temp-DiscSales.sum-cost1 + v-sum-cost1
        temp-DiscSales.sum-sale1 = temp-DiscSales.sum-sale1 + v-sum-sale1
      .
    end.
    else do:
      create temp-DiscSales .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output temp-DiscSales.b-code
  ) no-error .
      assign
        temp-DiscSales.obj-type  = buf_gds-obj.obj-type
        temp-DiscSales.obj-code  = buf_gds-obj.obj-code
        temp-DiscSales.artic     = buf_goods.artic
        temp-DiscSales.prod-type = buf_goods.prod-type
        temp-DiscSales.prod-code = buf_goods.prod-code
        temp-DiscSales.full-grp-name = trim( buf_goods.grp-name )
        temp-DiscSales.grp-name  = entry ( num-entries( buf_goods.grp-name, chr(47) ) - 1, buf_goods.grp-name, chr(47) )
        temp-DiscSales.unit-base = buf_goods.unit-base
        temp-DiscSales.grp-code  = buf_goods.grp-code
        temp-DiscSales.qnty      = v-qnty
        temp-DiscSales.ostat     = v-ostat
        temp-DiscSales.sum-cost  = v-sum-cost
        temp-DiscSales.sum-sale  = v-sum-sale
        temp-DiscSales.qnty1     = v-qnty1
        temp-DiscSales.ostat1    = v-ostat1
        temp-DiscSales.sum-cost1 = v-sum-cost1
        temp-DiscSales.sum-sale1 = v-sum-sale1
      .
      if g#gds-engl then assign temp-DiscSales.gds-name = buf_goods.engl-name.
      else               assign temp-DiscSales.gds-name = buf_goods.gds-name.
    end.
  end.
          end .
        end.
      end.
      otherwise do:
        for each gds-list ,
            each buf_gds-obj no-lock
          where buf_gds-obj.obj-type  = obj-list.obj-type
            and buf_gds-obj.obj-code  = obj-list.obj-code
            and buf_gds-obj.artic     = gds-list.artic
            and buf_gds-obj.prod-type = gds-list.prod-type
            and buf_gds-obj.prod-code = gds-list.prod-code
          :
          find first buf_goods no-lock
            where buf_goods.gds-code = buf_gds-obj.gds-code
          .
define variable vss-include-info34 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  if buf_gds-obj.last-doc = ? then next .
  if buf_gds-obj.last-doc < x-date-start and buf_gds-obj.fact-qnty = 0 and buf_gds-obj.avrg-qnty = 0 and buf_gds-obj.fact-sale =0 and buf_gds-obj.fact-base = 0 then next .
  assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
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
  assign
    v-qnty      = 0
    v-ostat     = 0
    v-sum-sale  = 0
    v-sum-cost  = 0
    v-qnty1     = 0
    v-ostat1    = 0
    v-sum-sale1 = 0
    v-sum-cost1 = 0
    p-sale-rubl = 0
    p-cost-rubl = 0
    p-fact-qnty = 0
  .
  if x-SET_PAY_TYPE = 1 then assign sfind = 'crsa':U .
  else                       assign sfind = 'cost':U .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = sfind
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order  < v-fact-order-end
    use-index category no-error .
  if available buf_stk-line then  assign v-ostat  = buf_stk-line.sum-rubl .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = sfind
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order  < v-fact-order-end1
    use-index category no-error .
  if available buf_stk-line then  assign v-ostat1  = buf_stk-line.sum-rubl .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'csdt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order < v-fact-order-end
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      v-sum-cost  = - buf_stk-line.sum-rubl
      v-qnty      = - buf_stk-line.fact-qnty
    .
  end.
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'sadt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order < v-fact-order-end
    use-index category no-error .
  if available buf_stk-line then  assign  v-sum-sale  = - buf_stk-line.sum-rubl  .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'csdt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order <= v-fact-order-start
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      v-sum-cost  = v-sum-cost + buf_stk-line.sum-rubl
      v-qnty      = v-qnty     + buf_stk-line.fact-qnty
    .
  end.
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'sadt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order <= v-fact-order-start
    use-index category no-error .
  if available buf_stk-line then  assign  v-sum-sale  = v-sum-sale + buf_stk-line.sum-rubl  .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'csdt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order < v-fact-order-end1
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      v-sum-cost1  = - buf_stk-line.sum-rubl
      v-qnty1      = - buf_stk-line.fact-qnty
    .
  end.
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'sadt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order < v-fact-order-end1
    use-index category no-error .
  if available buf_stk-line then assign  v-sum-sale1  = - buf_stk-line.sum-rubl  .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'csdt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order <= v-fact-order-start1
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      v-sum-cost1  = v-sum-cost1 + buf_stk-line.sum-rubl
      v-qnty1      = v-qnty1     + buf_stk-line.fact-qnty
    .
  end.
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'sadt':U + 'es':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order <= v-fact-order-start1
    use-index category no-error .
  if available buf_stk-line then assign  v-sum-sale1  = v-sum-sale1 + buf_stk-line.sum-rubl  .
  if x-return = yes then do:
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'csdt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order < v-fact-order-end
      use-index category no-error .
    if available buf_stk-line then do:
      assign
        v-sum-cost  = v-sum-cost - buf_stk-line.sum-rubl
        v-qnty      = v-qnty - buf_stk-line.fact-qnty
      .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'sadt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order < v-fact-order-end
      use-index category no-error .
    if available buf_stk-line then  assign  v-sum-sale  = v-sum-sale - buf_stk-line.sum-rubl  .
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'csdt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .
    if available buf_stk-line then do:
      assign
        v-sum-cost  = v-sum-cost + buf_stk-line.sum-rubl
        v-qnty      = v-qnty     + buf_stk-line.fact-qnty
      .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'sadt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .
    if available buf_stk-line then  assign  v-sum-sale  = v-sum-sale + buf_stk-line.sum-rubl  .
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'csdt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order < v-fact-order-end1
      use-index category no-error .
    if available buf_stk-line then do:
      assign
        v-sum-cost1  = v-sum-cost1 - buf_stk-line.sum-rubl
        v-qnty1      = v-qnty1     - buf_stk-line.fact-qnty
      .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'sadt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order < v-fact-order-end1
      use-index category no-error .
    if available buf_stk-line then assign  v-sum-sale1  = v-sum-sale1 - buf_stk-line.sum-rubl  .
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'csdt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start1
      use-index category no-error .
    if available buf_stk-line then do:
      assign
        v-sum-cost1  = v-sum-cost1 + buf_stk-line.sum-rubl
        v-qnty1      = v-qnty1     + buf_stk-line.fact-qnty
      .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'sadt':U + 'rs':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start1
      use-index category no-error .
    if available buf_stk-line then assign  v-sum-sale1  = v-sum-sale1 + buf_stk-line.sum-rubl  .
 end.
  if  ( x-ShowNull = yes ) or (v-sum-sale <> 0 or v-sum-cost <> 0 or v-sum-sale1 <> 0 or v-sum-cost1 <> 0 or v-qnty <> 0 or v-qnty1 <> 0 or v-ostat <> 0) then do:
    if x-SumObj = yes then do:
      find first temp-DiscSales
        where temp-DiscSales.obj-type     = buf_gds-obj.obj-type
          and temp-DiscSales.obj-code     = buf_gds-obj.obj-code
          and temp-DiscSales.artic        = buf_goods.artic
          and temp-DiscSales.prod-type    = buf_goods.prod-type
          and temp-DiscSales.prod-code    = buf_goods.prod-code
      no-error .
    end.
    else do:
      find first temp-DiscSales
        where temp-DiscSales.artic        = buf_goods.artic
          and temp-DiscSales.prod-type    = buf_goods.prod-type
          and temp-DiscSales.prod-code    = buf_goods.prod-code
      no-error .
    end.
    assign
      v-all-sum  = v-all-sum + ( if x-SET_PAY_TYPE = 1 then v-sum-sale else v-sum-cost )
      v-all-qnty = v-all-qnty     + v-qnty
    .
    if available temp-DiscSales then do:
      assign
        temp-DiscSales.qnty      = temp-DiscSales.qnty      + v-qnty
        temp-DiscSales.ostat     = temp-DiscSales.ostat     + v-ostat
        temp-DiscSales.sum-cost  = temp-DiscSales.sum-cost  + v-sum-cost
        temp-DiscSales.sum-sale  = temp-DiscSales.sum-sale  + v-sum-sale
        temp-DiscSales.qnty1     = temp-DiscSales.qnty1     + v-qnty1
        temp-DiscSales.ostat1    = temp-DiscSales.ostat1    + v-ostat1
        temp-DiscSales.sum-cost1 = temp-DiscSales.sum-cost1 + v-sum-cost1
        temp-DiscSales.sum-sale1 = temp-DiscSales.sum-sale1 + v-sum-sale1
      .
    end.
    else do:
      create temp-DiscSales .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output temp-DiscSales.b-code
  ) no-error .
      assign
        temp-DiscSales.obj-type  = buf_gds-obj.obj-type
        temp-DiscSales.obj-code  = buf_gds-obj.obj-code
        temp-DiscSales.artic     = buf_goods.artic
        temp-DiscSales.prod-type = buf_goods.prod-type
        temp-DiscSales.prod-code = buf_goods.prod-code
        temp-DiscSales.full-grp-name = trim( buf_goods.grp-name )
        temp-DiscSales.grp-name  = entry ( num-entries( buf_goods.grp-name, chr(47) ) - 1, buf_goods.grp-name, chr(47) )
        temp-DiscSales.unit-base = buf_goods.unit-base
        temp-DiscSales.grp-code  = buf_goods.grp-code
        temp-DiscSales.qnty      = v-qnty
        temp-DiscSales.ostat     = v-ostat
        temp-DiscSales.sum-cost  = v-sum-cost
        temp-DiscSales.sum-sale  = v-sum-sale
        temp-DiscSales.qnty1     = v-qnty1
        temp-DiscSales.ostat1    = v-ostat1
        temp-DiscSales.sum-cost1 = v-sum-cost1
        temp-DiscSales.sum-sale1 = v-sum-sale1
      .
      if g#gds-engl then assign temp-DiscSales.gds-name = buf_goods.engl-name.
      else               assign temp-DiscSales.gds-name = buf_goods.gds-name.
    end.
  end.
        end.
      end.
    end case.
  end.
  assign
    make-excel = yes
    v-file-name = string(session :temp-directory) + "rpt" + string( g#report-num ) + ".txt"
  .
  output stream macr_excel to value(v-file-name) .
  assign v-ind = v-ind + 1 .
if session :set-wait-state( "compiler" ) then.
  Line = fill("-", 250).
output stream OutStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(ReportPageHeight) .
  run PutColumnTitulExcel in this-procedure .
  FORM HEADER
      Line format "X(193)" AT 1 SKIP  "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width 235 PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream OutStream FRAME BottomFrame .
  PUT stream OutStream SPACE(30) "Анализ продаж с: " x-date-start format "99/99/9999" "г. по: " x-date-end format "99/99/9999" "г." SKIP .
  PUT stream OutStream str1 format "X(100)" SKIP .
  PUT stream OutStream str2 format "X(100)" SKIP .
  PUT stream OutStream str3 format "X(100)" SKIP .
  assign  v-NameString = "Выбор объекта: " .
  PUT stream OutStream v-NameString format "X(100)" SKIP .
  for each obj-list no-lock:
    Assign  v-NameString = obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code)  + "), " .
    PUT stream OutStream SPACE(5) v-NameString format "X(100)" SKIP .
  end.
  assign  v-NameString = "Выбор товара: " .
  case x-SelectGood :
    when 1        then assign v-NameString = v-NameString + "по всем товарам"  .
    when 2        then assign v-NameString = v-NameString + "по группам"  .
    when 3       then assign v-NameString = v-NameString + "по производителям"  .
    when 4     then assign v-NameString = v-NameString + "выборочно"  .
    when 5        then assign v-NameString = v-NameString + "выборочно"  .
    when 6       then assign v-NameString = v-NameString + "хранимый список"  .
    when 7   then assign v-NameString = v-NameString + "по группам и по производителям"  .
  end case .
  PUT stream OutStream v-NameString format "X(100)" SKIP .
  run PrintTitul in this-procedure .
  if x-SumObj = yes then do:
    for each obj-list no-lock :
      assign
        ind = 0
        titul = yes
        v-old-level = 0
        v-level = 0
      .
      for each temp-DiscSales
        where temp-DiscSales.obj-type = obj-list.obj-type
          and temp-DiscSales.obj-code = obj-list.obj-code
        break by temp-DiscSales.full-grp-name
              by temp-DiscSales.b-code :
        if titul = yes then do:
          assign
            titul = no
            all-qnty      = 0
            all-ostat     = 0
            all-sum-sale  = 0
            all-sum-cost  = 0
            all-qnty1     = 0
            all-ostat1    = 0
            all-sum-sale1 = 0
            all-sum-cost1 = 0
            v-NameString = "Объект: " + obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code) + ")"
          .
          run PrintGroup in this-procedure .
        end.
        if  ( v-row ) >= 63000 then do:
          Output stream Macr_Excel  close .
          run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name ) .
          run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
          output stream  Macr_Excel to value(v-file-name) .
          v-ind = v-ind + 1 .
          run PutColumnTitulExcel in this-procedure .
        end.
        if line-counter( Outstream ) > page-size( Outstream ) then do:
          page stream OutStream .
          run PrintTitul in this-procedure .
        end.
        if first-of(temp-DiscSales.full-grp-name) then do:
          run GrpSumTree in this-procedure .
        End.
        run CalculSum in this-procedure (0) .
        if x-itog = no then run PrintString in this-procedure .
        if last-of(temp-DiscSales.full-grp-name) then do:
          do ii = 1 to v-level :
            run CalculSum in this-procedure (ii) .
          end.
          assign
            all-qnty      = all-qnty      + cur-qnty
            all-ostat     = all-ostat     + cur-ostat
            all-sum-sale  = all-sum-sale  + cur-sum-sale
            all-sum-cost  = all-sum-cost  + cur-sum-cost
            all-qnty1     = all-qnty1     + cur-qnty1
            all-ostat1    = all-ostat1    + cur-ostat1
            all-sum-sale1 = all-sum-sale1 + cur-sum-sale1
            all-sum-cost1 = all-sum-cost1 + cur-sum-cost1
            all1-qnty      = all1-qnty      + cur-qnty
            all1-ostat     = all1-ostat     + cur-ostat
            all1-sum-sale  = all1-sum-sale  + cur-sum-sale
            all1-sum-cost  = all1-sum-cost  + cur-sum-cost
            all1-qnty1     = all1-qnty1     + cur-qnty1
            all1-ostat1    = all1-ostat1    + cur-ostat1
            all1-sum-sale1 = all1-sum-sale1 + cur-sum-sale1
            all1-sum-cost1 = all1-sum-cost1 + cur-sum-cost1
          .
        End.
      End.
      do ii = v-old-level to ( ind - 1 ) by -1 :
        find first temp-grp-sum
          where temp-grp-sum.num = ii no-error .
        if available temp-grp-sum then do:
          if x-itog = no then do:
            assign  v-NameString = "Итого по группе " + temp-grp-sum.grp + ":"  .
            run PrintItog in this-procedure (temp-grp-sum.ostat,temp-grp-sum.ostat1,temp-grp-sum.sum-cost,temp-grp-sum.sum-cost1,temp-grp-sum.sum-sale,temp-grp-sum.sum-sale1,temp-grp-sum.qnty,temp-grp-sum.qnty1) .
          end.
          else do:
            assign v-NameString = temp-grp-sum.full_grp .
            if x-lavel = -1 or ii <= x-lavel then
              run PrintItog in this-procedure (temp-grp-sum.ostat,temp-grp-sum.ostat1,temp-grp-sum.sum-cost,temp-grp-sum.sum-cost1,temp-grp-sum.sum-sale,temp-grp-sum.sum-sale1,temp-grp-sum.qnty,temp-grp-sum.qnty1) .
          end.
        end.
      end.
      for each temp-grp-sum :
        delete temp-grp-sum .
      end.
      if titul = no then do:
        assign v-NameString = "Итого по объекту " + obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code) + ") :" .
        run PrintItog in this-procedure (all-ostat,all-ostat1,all-sum-cost,all-sum-cost1,all-sum-sale,all-sum-sale1,all-qnty,all-qnty1) .
        put stream outstream  "|"   Line format "X(191)"   "|"    skip .
      end.
    End.
  end.
  else do:
    assign
      ind = 0
      titul = yes
      v-old-level = 0
      v-level = 0
      all-qnty      = 0
      all-ostat     = 0
      all-sum-sale  = 0
      all-sum-cost  = 0
      all-qnty1     = 0
      all-ostat1    = 0
      all-sum-sale1 = 0
      all-sum-cost1 = 0
    .
    for each temp-DiscSales
      break by temp-DiscSales.full-grp-name
            by temp-DiscSales.b-code :
      if  ( v-row ) >= 63000 then do:
        Output stream Macr_Excel  close .
        run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name ) .
        run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
        output stream  Macr_Excel to value(v-file-name) .
        v-ind = v-ind + 1 .
        run PutColumnTitulExcel in this-procedure .
      end.
      if line-counter( Outstream ) > page-size( Outstream ) then do:
        page stream OutStream .
        run PrintTitul in this-procedure .
      end.
      if first-of(temp-DiscSales.full-grp-name) then do:
        run GrpSumTree in this-procedure .
      End.
      run CalculSum in this-procedure (0) .
      if x-itog = no then run PrintString in this-procedure .
      if last-of(temp-DiscSales.full-grp-name) then do:
        do ii = 1 to v-level :
          run CalculSum in this-procedure (ii) .
        end.
        assign
          all-qnty      = all-qnty      + cur-qnty
          all-ostat     = all-ostat     + cur-ostat
          all-sum-sale  = all-sum-sale  + cur-sum-sale
          all-sum-cost  = all-sum-cost  + cur-sum-cost
          all-qnty1     = all-qnty1     + cur-qnty1
          all-ostat1    = all-ostat1    + cur-ostat1
          all-sum-sale1 = all-sum-sale1 + cur-sum-sale1
          all-sum-cost1 = all-sum-cost1 + cur-sum-cost1
          all1-qnty      = all1-qnty      + cur-qnty
          all1-ostat     = all1-ostat     + cur-ostat
          all1-sum-sale  = all1-sum-sale  + cur-sum-sale
          all1-sum-cost  = all1-sum-cost  + cur-sum-cost
          all1-qnty1     = all1-qnty1     + cur-qnty1
          all1-ostat1    = all1-ostat1    + cur-ostat1
          all1-sum-sale1 = all1-sum-sale1 + cur-sum-sale1
          all1-sum-cost1 = all1-sum-cost1 + cur-sum-cost1
        .
      End.
    End.
    do ii = v-old-level to (ind - 1) by -1 :
      find first temp-grp-sum
        where temp-grp-sum.num = ii no-error .
      if available temp-grp-sum then do:
        if x-itog = no then do:
          assign  v-NameString = "Итого по группе " + temp-grp-sum.grp + ":"  .
          run PrintItog in this-procedure (temp-grp-sum.ostat,temp-grp-sum.ostat1,temp-grp-sum.sum-cost,temp-grp-sum.sum-cost1,temp-grp-sum.sum-sale,temp-grp-sum.sum-sale1,temp-grp-sum.qnty,temp-grp-sum.qnty1) .
        end.
        else do:
          assign v-NameString = temp-grp-sum.full_grp .
          if x-lavel = -1 or ii <= x-lavel then
            run PrintItog in this-procedure (temp-grp-sum.ostat,temp-grp-sum.ostat1,temp-grp-sum.sum-cost,temp-grp-sum.sum-cost1,temp-grp-sum.sum-sale,temp-grp-sum.sum-sale1,temp-grp-sum.qnty,temp-grp-sum.qnty1) .
        end.
      end.
    end.
    for each temp-grp-sum :
      delete temp-grp-sum .
    end.
  end.
  assign v-NameString = "В С Е Г О :" .
      run PrintItog in this-procedure (all1-ostat,all1-ostat1,all1-sum-cost,all1-sum-cost1,all1-sum-sale,all1-sum-sale1,all1-qnty,all-qnty1) .
      put stream outstream  "|"   Line format "X(191)"   "|"    skip .
  HIDE stream OutStream FRAME BottomFrame .
  OUTPUT stream OutStream CLOSE.
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
if session :set-wait-state( "" ) then.
  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .
  run end-proc .
  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  define variable v-orient-page as character no-undo .
  define variable DisabledOptions as integer   no-undo .
  run How-name in this-procedure (
      input ReportPageHeight,
      input ReportPageWidth,
      output v-orient-page )
      .
  if v-orient-page = "A4-lans":U then DisabledOptions = 8 .
                                 else DisabledOptions = 0 .
  run gbl/prnfilen.w
    (input  ""
    ,input  DisabledOptions
    ,input  string(session :temp-directory) + "rpt" + string( g#report-num )
    ,input  ReportFontNum
    ,output v-user-action
    ,output v-printed
    ) .
end.
procedure GrpSumTree :
  v-level = num-entries( right-trim(temp-DiscSales.full-grp-name, chr(47)), chr(47) ) .
  assign CurrGrpName = "" .
  do ind = 1 to v-level :
    if ind = 1 then assign CurrGrpName = entry ( ind, temp-DiscSales.full-grp-name, chr(47) ) .
    else assign CurrGrpName = CurrGrpName + chr(47)  + entry ( ind, temp-DiscSales.full-grp-name, chr(47) ) + chr(47).
    find first temp-grp-sum
      where temp-grp-sum.full_grp = CurrGrpName
    no-error .
    if not available temp-grp-sum then LEAVE.
  end.
  do ii = v-old-level to ind by -1 :
    find first temp-grp-sum  where temp-grp-sum.num = ii no-error .
    IF available temp-grp-sum THEN DO:
      if x-itog = no then do:
        assign  v-NameString = "Итого по группе " + temp-grp-sum.grp + ":"  .
        run PrintItog in this-procedure (temp-grp-sum.ostat,temp-grp-sum.ostat1,temp-grp-sum.sum-cost,temp-grp-sum.sum-cost1,temp-grp-sum.sum-sale,temp-grp-sum.sum-sale1,temp-grp-sum.qnty,temp-grp-sum.qnty1) .
      end.
      else do:
        assign v-NameString = temp-grp-sum.full_grp .
        if x-lavel = -1 or ii <= x-lavel then
          run PrintItog in this-procedure (temp-grp-sum.ostat,temp-grp-sum.ostat1,temp-grp-sum.sum-cost,temp-grp-sum.sum-cost1,temp-grp-sum.sum-sale,temp-grp-sum.sum-sale1,temp-grp-sum.qnty,temp-grp-sum.qnty1) .
      end.
      delete temp-grp-sum .
    end.
  end.
  assign
     v-old-level = v-level
  .
  do ii = ind to v-level :
    create temp-grp-sum .
    if ii > ind then do:
      assign CurrGrpName = CurrGrpName + chr(47) + entry ( ii, temp-DiscSales.full-grp-name, chr(47) )  + chr(47).
    end.
    assign
      temp-grp-sum.num = ii
      temp-grp-sum.full_grp = CurrGrpName
      temp-grp-sum.grp = entry ( ii, temp-DiscSales.full-grp-name, chr(47) )
      v-NameString = "Группа " + temp-grp-sum.grp
      temp-grp-sum.qnty           = 0
      temp-grp-sum.ostat          = 0
      temp-grp-sum.sum-sale       = 0
      temp-grp-sum.sum-cost       = 0
      temp-grp-sum.qnty1          = 0
      temp-grp-sum.ostat1         = 0
      temp-grp-sum.sum-sale1      = 0
      temp-grp-sum.sum-cost1      = 0
    .
    if x-itog = no then run PrintGroup in this-procedure .
  end.
  assign
    v-NameString = "Группа " + temp-DiscSales.grp-name
    cur-qnty      = 0
    cur-ostat     = 0
    cur-sum-sale  = 0
    cur-sum-cost  = 0
    cur-qnty1     = 0
    cur-ostat1    = 0
    cur-sum-sale1 = 0
    cur-sum-cost1 = 0
  .
end procedure.
procedure CalculSum :
  define input  parameter p-num as integer   no-undo .
  define buffer buf_temp-grp-sum for temp-grp-sum .
  if p-num = 0 then do:
    assign
      cur-qnty      = cur-qnty      + temp-DiscSales.qnty
      cur-ostat     = cur-ostat     + temp-DiscSales.ostat
      cur-sum-sale  = cur-sum-sale  + temp-DiscSales.sum-sale
      cur-sum-cost  = cur-sum-cost  + temp-DiscSales.sum-cost
      cur-qnty1     = cur-qnty1     + temp-DiscSales.qnty1
      cur-ostat1    = cur-ostat1    + temp-DiscSales.ostat1
      cur-sum-sale1 = cur-sum-sale1 + temp-DiscSales.sum-sale1
      cur-sum-cost1 = cur-sum-cost1 + temp-DiscSales.sum-cost1
    .
  end.
  else do:
    find first buf_temp-grp-sum where buf_temp-grp-sum.num = p-num no-error .
    if available buf_temp-grp-sum then
    assign
      buf_temp-grp-sum.qnty      = buf_temp-grp-sum.qnty      + cur-qnty
      buf_temp-grp-sum.ostat     = buf_temp-grp-sum.ostat     + cur-ostat
      buf_temp-grp-sum.sum-sale  = buf_temp-grp-sum.sum-sale  + cur-sum-sale
      buf_temp-grp-sum.sum-cost  = buf_temp-grp-sum.sum-cost  + cur-sum-cost
      buf_temp-grp-sum.qnty1     = buf_temp-grp-sum.qnty1     + cur-qnty1
      buf_temp-grp-sum.ostat1    = buf_temp-grp-sum.ostat1    + cur-ostat1
      buf_temp-grp-sum.sum-sale1 = buf_temp-grp-sum.sum-sale1 + cur-sum-sale1
      buf_temp-grp-sum.sum-cost1 = buf_temp-grp-sum.sum-cost1 + cur-sum-cost1
    .
  end.
end procedure.
procedure PrintTitul :
  do
  on error undo, return error return-value
  :
  put stream outstream
    skip
    Line format "X(193)"
    skip
        "| "                         "Код"                     format "X(11)"
        "| "     at 15        "Наименование товара"     format "X(20)"
        "| "     at 57        "Наценка"                 format "X(10)"
        "|"      at 97        (if x-RADIO-sel = 1 then "Сумма" else "Кол-во") format "X(6)"
        "|"      at 137       "Остатки"                 format "X(10)"
        "|"      at 151       "Остатки в днях"          format "X(16)"
        "|"      at 184       "Удел."                   format "X(6)"
        "|"      at 193
    skip
        "|"  "|" at 15   "|" at 57   Line format "X(79)"
        "|"  at 137      "|" at 151  Line format "X(32)"
        "|"  at 184      "вес"                   format "X(6)"
        "|"  at 193
    skip
        "|"
        "| "  at 15
        "| "  at 57        "Сравнит."               format "X(8)"
        "| "  at 71        "Рабочий"                format "X(8)"
        "| "  at 85        "% изм."                 format "X(8)"
        "| "  at 97        "Сравнит."               format "X(8)"
        "| "  at 111       "Рабочий"                format "X(8)"
        "| "  at 125       "% изм."                 format "X(8)"
        "| "  at 137
        "| "  at 151       "Сравнит."               format "X(8)"
        "| "  at 162       "Рабочий"                format "X(8)"
        "| "  at 173       "% изм."                 format "X(8)"
        "|"   at 184
        "|"   at 193
    skip
        "|"  Line format "X(191)"   "|"
    skip
  .
  end.
end procedure.
procedure PrintGroup :
  do
  on error undo, return error return-value
  :
  put stream outstream
        "| "    v-NameString   format "X(50)"
        "| "   at 57        "| "   at 71        "| "   at 85        "| "   at 97
        "| "   at 111       "| "   at 125       "| "   at 137       "| "   at 151
        "| "   at 162       "| "   at 173       "| "   at 184       "|"    at 193
    skip
  .
  run macr_excel_char( v-NameString ,  v-row, 2) .
  assign v-row = v-row + 1 .
  end.
end procedure.
procedure PrintString :
  do
  on error undo, return error return-value
  :
  define variable prnaz  as decimal initial 0  no-undo .
  define variable naz    as decimal   no-undo .
  define variable naz1   as decimal   no-undo .
  define variable prod    as decimal   no-undo .
  define variable prod1   as decimal   no-undo .
  define variable ostd   as decimal   no-undo .
  define variable ostd1  as decimal   no-undo .
  define variable prostd as decimal initial 0  no-undo .
  define variable prprod as decimal initial 0  no-undo .
  assign
    naz   = temp-DiscSales.sum-sale - temp-DiscSales.sum-cost
    naz1  = temp-DiscSales.sum-sale1 - temp-DiscSales.sum-cost1
  .
  if temp-DiscSales.sum-cost  <> 0 then naz   = naz * 100 / temp-DiscSales.sum-cost .
  if temp-DiscSales.sum-cost1 <> 0 then naz1  = naz1 * 100 / temp-DiscSales.sum-cost1 .
  if naz1  <> 0    then prnaz  = ((naz - naz1) * 100 / naz1) .
  else if naz <> 0 then prnaz = 100 .
  if x-SET_PAY_TYPE = 1 then assign   prod1 = temp-DiscSales.sum-sale1    prod  = temp-DiscSales.sum-sale  .
  else                       assign   prod1 = temp-DiscSales.sum-cost1    prod  = temp-DiscSales.sum-cost  .
  assign
    ostd1 = temp-DiscSales.ostat1 * (x-date-end1 - x-date-start1 + 1) / prod1
    ostd  = temp-DiscSales.ostat  * (x-date-end - x-date-start + 1)   / prod
  .
  if prod1 <> 0     then prprod  = ((prod - prod1) * 100 / prod1) .
  else if prod <> 0 then prprod = 100 .
  if ostd1 <> 0     then prostd = ((ostd - ostd1) * 100 / ostd1) .
  else if ostd <> 0 then prostd = 100 .
  if x-RADIO-sel = 2 then assign udel = temp-DiscSales.qnty * 100 / v-all-qnty .
  else                    assign udel = prod * 100 / v-all-sum .
  put stream outstream
        "|"                            temp-DiscSales.b-code                          format ">>>>>>>>>>>>9"
        "| "      at 15         temp-DiscSales.gds-name                        format "X(40)"
        "|"       at 57         naz1                                           format "->,>>>,>>9.99"
        "|"       at 71         naz                                            format "->,>>>,>>9.99"
        "|"       at 85         prnaz                                          format "->>>,>>9.99"
        "|"       at 97        (if x-RADIO-sel = 1 then prod1 else temp-DiscSales.qnty1)   format "->,>>>,>>9.99"
        "|"       at 111       (if x-RADIO-sel = 1 then prod  else temp-DiscSales.qnty)    format "->,>>>,>>9.99"
        "|"       at 125        prprod                                         format "->>>,>>9.99"
        "|"       at 137        temp-DiscSales.ostat                           format "->,>>>,>>9.99"
        "|"       at 151        ostd1                                          format "->>>>>>9"
        "|"       at 162        ostd                                           format "->>>>>>9"
        "|"       at 173        prostd                                         format "->>>>>>9"
        "|"       at 184        udel                                           format ">>9.<<"
        "|"       at 193
    skip
  .
  assign v-col = 1 .
  run macr_excel_char( string(temp-DiscSales.b-code,">>>>>>>>>>>>9"),  v-row, v-col) .       assign v-col = v-col + 1 .
  run macr_excel_char( temp-DiscSales.gds-name            ,  v-row, v-col) .       assign v-col = v-col + 1 .
  run macr_excel_sum ( naz1                               ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( naz                                ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( prnaz                              ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( (if x-RADIO-sel = 1 then prod1 else temp-DiscSales.qnty1) ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( (if x-RADIO-sel = 1 then prod  else temp-DiscSales.qnty)  ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( prprod                             ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( temp-DiscSales.ostat               ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( ostd1                              ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( ostd                               ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( prostd                             ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( udel                               ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  assign v-row = v-row + 1 .
  end.
end procedure.
procedure PrintItog :
  do
  on error undo, return error return-value
  :
  define input  parameter p-ostat     as decimal   no-undo .
  define input  parameter p-ostat1    as decimal   no-undo .
  define input  parameter p-sum-cost  as decimal   no-undo .
  define input  parameter p-sum-cost1 as decimal   no-undo .
  define input  parameter p-sum-sale  as decimal   no-undo .
  define input  parameter p-sum-sale1 as decimal   no-undo .
  define input  parameter p-qnty      as decimal   no-undo .
  define input  parameter p-qnty1     as decimal   no-undo .
  define variable prnaz  as decimal initial 0  no-undo .
  define variable naz    as decimal   no-undo .
  define variable naz1   as decimal   no-undo .
  define variable prod    as decimal   no-undo .
  define variable prod1   as decimal   no-undo .
  define variable ostd   as decimal   no-undo .
  define variable ostd1  as decimal   no-undo .
  define variable prostd as decimal initial 0  no-undo .
  define variable prprod as decimal initial 0  no-undo .
  assign
    naz   = p-sum-sale  - p-sum-cost
    naz1  = p-sum-sale1 - p-sum-cost1
  .
  if p-sum-cost  <> 0  then naz   = naz * 100 / p-sum-cost .
  if p-sum-cost1  <> 0 then naz1  = naz1 * 100 / p-sum-cost1 .
  if naz1  <> 0    then prnaz  = ((naz - naz1) * 100 / naz1) .
  else if naz <> 0 then prnaz = 100 .
  if x-SET_PAY_TYPE = 1 then assign   prod1 = p-sum-sale1    prod  = p-sum-sale  .
  else                       assign   prod1 = p-sum-cost1    prod  = p-sum-cost  .
  assign
    ostd1 = p-ostat1 * (x-date-end1 - x-date-start1 + 1) / prod1
    ostd  = p-ostat  * (x-date-end  - x-date-start + 1)  / prod
  .
  if prod1 <> 0     then prprod  = ((prod - prod1) * 100 / prod1) .
  else if prod <> 0 then prprod = 100 .
  if ostd1 <> 0     then prostd = ((ostd - ostd1) * 100 / ostd1) .
  else if ostd <> 0 then prostd = 100 .
  if x-RADIO-sel = 2 then assign udel = p-qnty * 100 / v-all-qnty .
  else                    assign udel = prod * 100 / v-all-sum .
  put stream outstream
        "| "                         v-NameString                            format "X(52)"
        "|"      at 57        naz1                                    format "->,>>>,>>9.99"
        "|"      at 71        naz                                     format "->,>>>,>>9.99"
        "|"      at 85        prnaz                                   format "->>>,>>9.99"
        "|"      at 97        (if x-RADIO-sel = 1 then prod1 else p-qnty1)   format "->,>>>,>>9.99"
        "|"      at 111       (if x-RADIO-sel = 1 then prod  else p-qnty)    format "->,>>>,>>9.99"
        "|"      at 125       prprod                                  format "->>>,>>9.99"
        "|"      at 137       p-ostat                               format "->,>>>,>>9.99"
        "|"      at 151       ostd1                                   format "->>>>>>9"
        "|"      at 162       ostd                                    format "->>>>>>9"
        "|"      at 173       prostd                                  format "->>>>>>9"
        "|"      at 184       udel                                    format ">>9.<<"
        "|"      at 193
    skip
  .
  assign v-col = 1 .
  assign v-col = v-col + 1 .
  run macr_excel_char( v-NameString                       ,  v-row, v-col) .       assign v-col = v-col + 1 .
  run macr_excel_sum ( naz1                               ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( naz                                ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( prnaz                              ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( (if x-RADIO-sel = 1 then prod1 else p-qnty1) ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( (if x-RADIO-sel = 1 then prod  else p-qnty)  ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( prprod                             ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( p-ostat                            ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( ostd1                              ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( ostd                               ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( prostd                             ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( udel                               ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  assign v-row = v-row + 1 .
  end.
end procedure.
procedure PutColumnTitulExcel :
  do
  on error undo, return error return-value
  :
  assign
    v-row = 5
    v-col = 1
  .
  run macr_excel_char (String( "Анализ продаж  с " + String(x-Date-Start,"99.99.9999") + " по " + String(x-Date-End,"99.99.9999") ) , 1, 4) .
  run macr_cell_format( 11, yes, no, ?, 1, 4, 1, 4) .
  run macr_excel_char (Str1 , 2, 1) .
  run macr_excel_char (Str2 , 3, 1) .
  run macr_excel_char (Str3 , 4, 1) .
  run macr_excel_char ("Выбор объекта: " , v-row, v-col) .    assign v-col = v-col + 1 .
  for each obj-list no-lock:
    run macr_excel_char ( string( obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code)  + "), ") , v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  assign
    v-col = 1
    v-row = v-row + 1
  .
  case x-SelectGood :
    when 1       then run macr_excel_char ("Выбор товара: по всем товарам" , v-row, v-col) .
    when 2       then run macr_excel_char ("Выбор товара: по группам" , v-row, v-col) .
    when 3      then run macr_excel_char ("Выбор товара: по производителям" , v-row, v-col) .
    when 4    then run macr_excel_char ("Выбор товара: выборочно" , v-row, v-col) .
    when 5       then run macr_excel_char ("Выбор товара: выборочно" , v-row, v-col) .
    when 6      then run macr_excel_char ("Выбор товара: по хранимому списку" , v-row, v-col) .
    when 7  then run macr_excel_char ("Выбор товара: по группам и по производителям" , v-row, v-col) .
  end case .
  run macr_excel_char("Код", v-row, v-col) .
  run macr_cell_size (10,?, v-row, v-col,?,?).       assign v-col = v-col + 1 .
  run macr_excel_char("Наименование товара", v-row, v-col) .
  run macr_cell_size (30,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Наценка сравнит.", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Наценка рабочий", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Наценка % изм.", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char((if x-RADIO-sel = 1 then "Сумма сравнит." else "Кол-во сравнит."), v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).       assign v-col = v-col + 1 .
  run macr_excel_char((if x-RADIO-sel = 1 then "Сумма рабочий" else "Кол-во рабочий"), v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).       assign v-col = v-col + 1 .
  run macr_excel_char((if x-RADIO-sel = 1 then "Сумма % изм." else "Кол-во % изм."), v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).       assign v-col = v-col + 1 .
  run macr_excel_char("Остатки", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Остатки в днях сравнит.", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Остатки в днях рабочий", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Остатки в днях % изм.", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Удел. вес", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_cell_bordur ( v-row , 1, v-row, 13) .
  run macr_cell_format ( 10, yes, no, 35, v-row , 1, v-row, 13) .
  assign
    v-row = v-row + 1
    v-col = 1
  .
  end.
end procedure.
