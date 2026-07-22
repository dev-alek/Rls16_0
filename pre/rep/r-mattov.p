block-level on error undo, throw.
define input parameter  p-Rad-Inter    as integer   no-undo .
define input parameter  p-date1        as date      no-undo .
define input parameter  p-date2        as date      no-undo .
define input parameter  p-time         as integer   no-undo .
define input parameter  p-cli-code1    as integer   no-undo .
define input parameter  p-cli-type1    as character no-undo .
define input parameter  p-cli-code2    as integer   no-undo .
define input parameter  p-cli-type2    as character no-undo .
define input parameter  p-ShowGoods    as logical   no-undo .
define input parameter  p-Rad-Goods    as integer   no-undo .
define input parameter  xClassify      as character no-undo.
define input parameter  xSortType      as character no-undo.
define input parameter  xtog-lavel     as logical   no-undo.
define input parameter  xvar-lavel     as integer   no-undo.
define input parameter  xtog-lavel-2   as logical   no-undo.
define input parameter  xvar-lavel-2   as integer   no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-mattov.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-mattov.p $":U .
define variable vss-description as character no-undo init "Представленность матрицы товаров на объекте".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-parts no-undo   like ub.parts   field free-qnty as decimal   field free-cli-qnty as decimal .
procedure partslib-clear-temp-parts :
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error
  :
    for each buf_temp-parts
    on error undo, return error
    :
      delete buf_temp-parts .
    end.
  end.
end procedure.
procedure partslib-create-temp-parts :
  define parameter buffer buf_parts       for ub.parts .
  define parameter buffer buf_temp-parts  for temp-parts .
  define input  parameter p-goods-twounit as logical   no-undo .
  define variable v-base-part-code as character no-undo .
  do
  on error undo, return error
  :
    if p-goods-twounit = true
    then do:
      assign
        v-base-part-code = entry(1, buf_parts.part-code, '#':U)
      .
    end.
    else do:
      assign
        v-base-part-code = buf_parts.part-code
      .
    end.
    find first buf_temp-parts exclusive-lock
      where buf_temp-parts.obj-type  = buf_parts.obj-type
        and buf_temp-parts.obj-code  = buf_parts.obj-code
        and buf_temp-parts.artic     = buf_parts.artic
        and buf_temp-parts.prod-type = buf_parts.prod-type
        and buf_temp-parts.prod-code = buf_parts.prod-code
        and buf_temp-parts.in-code   = buf_parts.in-code
        and buf_temp-parts.out-code  = 'free-zone':U
        and buf_temp-parts.part-code = v-base-part-code
      no-error.
    if not available buf_temp-parts
    then do:
      create buf_temp-parts .
      buffer-copy buf_parts to buf_temp-parts
      assign
        buf_temp-parts.out-code  = 'free-zone':U
        buf_temp-parts.part-code = v-base-part-code
        buf_temp-parts.rsrv-free = yes
        buf_temp-parts.status_   = no
        buf_temp-parts.qnty      = 0
        buf_temp-parts.fact-qnty = 0
        buf_temp-parts.real-qnty = 0
        buf_temp-parts.cli-qnty  = 0
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info11 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run partslib-clear-temp-parts in this-procedure .
    for each buf_parts
      where buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
        and buf_parts.rsrv-free = yes
        and buf_parts.status_   = no
        and buf_parts.in-code   <> buf_parts.out-code
    on error undo, return error
    :
      run partslib-create-temp-parts in this-procedure
        (buffer buf_parts
        ,buffer buf_temp-parts
        ,input  v-goods-twounit
        ) .
      define variable v-parts-qnty          as decimal   no-undo .
      define variable v-parts-cli-qnty      as decimal   no-undo .
      define variable v-parts-free-qnty     as decimal   no-undo .
      define variable v-parts-free-cli-qnty as decimal   no-undo .
      if buf_parts.out-code = 'free-zone':U
      then do:
        assign
          v-parts-qnty          = buf_parts.qnty
          v-parts-cli-qnty      = buf_parts.cli-qnty
          v-parts-free-qnty     = buf_parts.qnty
          v-parts-free-cli-qnty = buf_parts.cli-qnty
        .
      end.
      else do:
        assign
          v-parts-qnty          = abs(buf_parts.qnty)
          v-parts-cli-qnty      = abs(buf_parts.cli-qnty)
          v-parts-free-qnty     = 0
          v-parts-free-cli-qnty = 0
        .
      end.
      assign
        buf_temp-parts.qnty          = buf_temp-parts.qnty          + v-parts-qnty
        buf_temp-parts.fact-qnty     = buf_temp-parts.fact-qnty     + v-parts-qnty
        buf_temp-parts.real-qnty     = 0
        buf_temp-parts.cli-qnty      = buf_temp-parts.cli-qnty      + v-parts-cli-qnty
        buf_temp-parts.free-qnty     = buf_temp-parts.free-qnty     + v-parts-free-qnty
        buf_temp-parts.free-cli-qnty = buf_temp-parts.free-cli-qnty + v-parts-free-cli-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  do
  on error undo, return error
  :
    do transaction
    on error undo, return error
    :
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info11 skip
          "Невозможно найти товар на объекте" skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    run partslib-init-temp-parts in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info11 skip
        "Ошибка при инициализации текущего остатка по партиям свободной зоны" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-include-fact-order = true
    then do:
      assign
        p-fact-order = p-fact-order - 0.0000000001
      .
    end.
    define variable v-max-fact-order as character no-undo .
    run factord-max-fact-order in this-procedure
      (output v-max-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info11 skip
        "Ошибка при вызове процедуры factord-max-fact-order" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-update-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input p-fact-order
      ,input v-max-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info11 skip
        "Ошибка при вызове процедуры partslib-update-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        "v-max-fact-order" v-max-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-update-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-start-fact-order   as decimal   no-undo .
  define input parameter p-end-fact-order     as decimal   no-undo .
  define input parameter p-lock-gds-obj       as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  define buffer buf_doc-line for ub.doc-line .
  define variable v-total-parts-qnty as decimal   no-undo .
  define variable v-goods-gds-goods  as logical   no-undo .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
    if p-start-fact-order > p-end-fact-order
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info11 skip
        "Ошибка задания входных параметров" skip
        "Начало интервала превышает конец интервала" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-start-fact-order" p-start-fact-order skip
        "p-end-fact-order"   p-end-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-lock-gds-obj = true
    then do:
      do transaction
      on error undo, return error
      :
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info11 skip
            "Невозможно найти gds-obj" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        find current buf_gds-obj exclusive-lock .
      end.
    end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'gds-goods=request':u
  ,output v-goods-gds-goods
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info11 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "gds-goods=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info11 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order > p-start-fact-order
        and buf_doc-line.fact-order <= p-end-fact-order
    on error undo, return error
    :
      run partslib-process-document in this-procedure
        (input  buf_doc-line.doc-code
        ,input  p-obj-type
        ,input  p-obj-code
        ,input  p-artic
        ,input  p-prod-type
        ,input  p-prod-code
        ,input  v-goods-gds-goods
        ,input  v-goods-twounit
        ,output v-total-parts-qnty
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info11 skip
          "Ошибка при вызове процедуры partslib-process-document" skip
          "Документ" buf_doc-line.doc-code skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "p-start-fact-order" p-start-fact-order skip
          "p-end-fact-order" p-end-fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure partslib-process-document :
  define input  parameter p-doc-code         as character no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-artic            as character no-undo .
  define input  parameter p-prod-type        as character no-undo .
  define input  parameter p-prod-code        as integer   no-undo .
  define input  parameter p-goods-gds-goods  as logical   no-undo .
  define input  parameter p-goods-twounit    as logical   no-undo .
  define output parameter p-total-parts-qnty as decimal   no-undo .
  define variable v-parts-sign as integer   no-undo .
  define buffer buf_trn-doc    for ub.trn-doc .
  define buffer buf_doc-line   for ub.doc-line .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      undo, return error substitute("Ошибка при поиске документа. Документ &1"
                                   ,p-doc-code
                                   ) .
    end.
    case buf_trn-doc.doc-type
    :
      when 'при':U or
      when 'возврат':U or
      when 'инв':U
      then do:
        assign
          v-parts-sign = -1
        .
      end.
      when 'рас':U or
      when 'спи':U
      then do:
        assign
          v-parts-sign = 1
        .
      end.
      otherwise do:
        undo, return error substitute("Неизвестный тип документа &1"
                                    ,buf_trn-doc.doc-type
                                    ) .
      end.
    end.
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line
    then do:
      undo, return error substitute("Ошибка при поиске строки документа. Документ &1. Артикул &2 &3 &4"
                                   ,p-doc-code
                                   ,artic
                                   ,prod-type
                                   ,prod-code
                                   ) .
    end.
    assign
      p-total-parts-qnty = 0
    .
    if p-goods-gds-goods = true
    then do:
      for each buf_parts no-lock
        where buf_parts.out-code  = p-doc-code
          and buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
      on error undo, return error
      :
        run partslib-create-temp-parts in this-procedure
          (buffer buf_parts
          ,buffer buf_temp-parts
          ,input  p-goods-twounit
          ) .
        assign
          p-total-parts-qnty        = p-total-parts-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.qnty       = buf_temp-parts.qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.fact-qnty  = buf_temp-parts.fact-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.cli-qnty   = buf_temp-parts.cli-qnty
                                    + v-parts-sign * buf_parts.cli-qnty
        .
        if buf_temp-parts.qnty = 0
        then do:
          delete buf_temp-parts .
        end.
      end.
    end.
    else do:
      assign
        p-total-parts-qnty = p-total-parts-qnty
                           + v-parts-sign * buf_doc-line.fact-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-date :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define input parameter p-fact-date       as date      no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-date: определение партий свободной зоны на любую дату".
  do
  on error undo, return error
  :
    define variable v-fact-order                as decimal   no-undo .
    define variable v-shift-end-fact-order      as decimal   no-undo .
    define variable v-day-end-fact-order        as decimal   no-undo .
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  ?
      ,input  0
      ,input  false
      ,output v-fact-order
      ,output v-shift-end-fact-order
      ,output v-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info11 skip
        "Ошибка при определении момента времени, на который требуется остаток" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-init-temp-parts-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input v-day-end-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info11 skip
        "Ошибка при вызове метода partslib-init-temp-parts-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-calc-cost :
  define output parameter p-fact-qnty      as decimal   no-undo .
  define output parameter p-vat-pc         as decimal   no-undo .
  define output parameter p-slt-pc         as decimal   no-undo .
  define output parameter p-sum-base       as decimal   no-undo .
  define output parameter p-sum-rubl       as decimal   no-undo .
  define output parameter p-vat-base       as decimal   no-undo .
  define output parameter p-vat-rubl       as decimal   no-undo .
  define output parameter p-slt-base       as decimal   no-undo .
  define output parameter p-slt-rubl       as decimal   no-undo .
  define output parameter p-road-tax-base  as decimal   no-undo .
  define output parameter p-road-tax-rubl  as decimal   no-undo .
  define output parameter p-transport-base as decimal   no-undo .
  define output parameter p-transport-rubl as decimal   no-undo .
  define output parameter p-other-base     as decimal   no-undo .
  define output parameter p-other-rubl     as decimal   no-undo .
  define output parameter p-excise-base    as decimal   no-undo .
  define output parameter p-excise-rubl    as decimal   no-undo .
  define variable vss-description as character no-undo init "partslib-calc-cost: расчет сумм в учетных ценах".
  do
  on error undo, return error return-value
  :
    define buffer buf_temp-parts for temp-parts .
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
    for each buf_temp-parts
    on error undo, return error
    :
assign
  price-rubl-with-tax-loc = buf_temp-parts.price-rubl
  price-base-with-tax-loc = buf_temp-parts.price-base
.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_temp-parts.out-code = 'free-zone':U     or
     buf_temp-parts.out-code = 'out-zone':U   or
     buf_temp-parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_temp-parts.out-code
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
   price-cli-with-tax-loc = buf_temp-parts.price-cli
   cli-base-rate          = buf_temp-parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_temp-parts.road-tax-base  = ? then 0 else buf_temp-parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_temp-parts.road-tax-rubl  = ? then 0 else buf_temp-parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_temp-parts.transport-base = ? then 0 else buf_temp-parts.transport-base)
          transport-rubl-loc = (if buf_temp-parts.transport-rubl = ? then 0 else buf_temp-parts.transport-rubl)
          other-base-loc     = (if buf_temp-parts.other-base     = ? then 0 else buf_temp-parts.other-base)
          other-rubl-loc     = (if buf_temp-parts.other-rubl     = ? then 0 else buf_temp-parts.other-rubl)
          vat-pc-loc         = (if buf_temp-parts.vat-pc         = ? then 0 else buf_temp-parts.vat-pc)
          slt-pc-loc         = (if buf_temp-parts.slt-pc         = ? then 0 else buf_temp-parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_temp-parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_temp-parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_temp-parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_temp-parts.price-cli .
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
        p-fact-qnty      = p-fact-qnty      + buf_temp-parts.fact-qnty
        p-vat-pc         = p-vat-pc         + vat-pc-loc
        p-slt-pc         = p-slt-pc         + slt-pc-loc
        p-sum-base       = p-sum-base       + price-base-with-tax-loc * buf_temp-parts.fact-qnty
        p-sum-rubl       = p-sum-rubl       + price-rubl-with-tax-loc * buf_temp-parts.fact-qnty
        p-vat-base       = p-vat-base       + vat-base-loc            * buf_temp-parts.fact-qnty
        p-vat-rubl       = p-vat-rubl       + vat-rubl-loc            * buf_temp-parts.fact-qnty
        p-slt-base       = p-slt-base       + slt-base-loc            * buf_temp-parts.fact-qnty
        p-slt-rubl       = p-slt-rubl       + slt-rubl-loc            * buf_temp-parts.fact-qnty
        p-road-tax-base  = p-road-tax-base  + road-tax-base-loc       * buf_temp-parts.fact-qnty
        p-road-tax-rubl  = p-road-tax-rubl  + road-tax-rubl-loc       * buf_temp-parts.fact-qnty
        p-transport-base = p-transport-base + transport-base-loc      * buf_temp-parts.fact-qnty
        p-transport-rubl = p-transport-rubl + transport-rubl-loc      * buf_temp-parts.fact-qnty
        p-other-base     = p-other-base     + other-base-loc          * buf_temp-parts.fact-qnty
        p-other-rubl     = p-other-rubl     + other-rubl-loc          * buf_temp-parts.fact-qnty
        p-excise-base    = p-excise-base    + 0
        p-excise-rubl    = p-excise-rubl    + 0
      .
    end.
    if p-fact-qnty      = ?
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
        vss-include-info11 skip
        "Программа in-vatp.i вернула неопределенные значения" skip
        "p-fact-qnty"      p-fact-qnty      skip
        "p-sum-base"       p-sum-base       skip
        "p-sum-rubl"       p-sum-rubl       skip
        "p-vat-base"       p-vat-base       skip
        "p-vat-rubl"       p-vat-rubl       skip
        "p-slt-base"       p-slt-base       skip
        "p-slt-rubl"       p-slt-rubl       skip
        "p-road-tax-base"  p-road-tax-base  skip
        "p-road-tax-rubl"  p-road-tax-rubl  skip
        "p-transport-base" p-transport-base skip
        "p-transport-rubl" p-transport-rubl skip
        "p-other-base"     p-other-base     skip
        "p-other-rubl"     p-other-rubl     skip
        "p-excise-base"    p-excise-base    skip
        "p-excise-rubl"    p-excise-rubl    skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
define variable vss-include-info18 as character format "X(65)" no-undo
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
define variable vss-include-info19 as character format "X(65)" no-undo
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
define variable vss-include-info20 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_cgrplib_grp no-undo
    field sel           as character
    field full-name     as character
    field sort-name     as character
    field node-code     as integer
    field upper-code    as integer
    field d-pcnt        as decimal
    field name          as character
    field level         as integer
    field mark          as character
    index pi is primary unique sort-name
    index fn full-name
    index nc is unique node-code
    index sl sel
    index uc upper-code
.
define temp-table temp_cgrplib_found-grp no-undo
    field full-name   as character
    field sort-name   as character
    field node-code   as integer
    field level       as integer
    field is-terminal as logical
    field d-pcnt      as decimal
    index pi is primary unique sort-name
    index fn full-name
    index lv level
    index it is-terminal
.
define temp-table temp_cfound-result-nodelist no-undo
    field node-code     as recid
    field processed     as logical
    field full-name     as character
    field sort-name     as character
    index pi is primary unique node-code
    index ps processed
.
procedure cli-grplib-get-sort-name :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define output parameter p-sort-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    define buffer buf_upper_cli-grp for ub.cli-grp.
    find first buf_cli-grp no-lock
         where buf_cli-grp.node-code = p-node-code
    no-error.
    if not available buf_cli-grp
    then do:
        undo, return error "cli-grplib-get-sort-name: Не найдена группа клиентов с кодом " + string( p-node-code ).
    end.
    assign
        p-sort-name  = ""
        v-upper-code = 1
    .
    do while buf_cli-grp.upper-code <> 0
    on error undo, return error "cli-grplib-get-sort-name: Ошибка составления полного имени группы"
    :
        assign
            p-sort-name  = buf_cli-grp.node-name
                         + (if p-sort-name <> "" then chr(2) else "")
                         + p-sort-name
            v-upper-code = buf_cli-grp.upper-code
        .
        find first buf_cli-grp no-lock
             where buf_cli-grp.node-code = v-upper-code
        no-error.
        if not available buf_cli-grp
        then do:
            undo, return error "cli-grplib-get-sort-name: Не найдена группа клиентов с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
end.
end procedure.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cli-grplib-get-full-name :
   define input parameter  p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    define buffer buf_upper_cli-grp for ub.cli-grp.
    find first buf_cli-grp no-lock
         where buf_cli-grp.node-code = p-node-code
    no-error.
    if not available buf_cli-grp
    then do:
        undo, return error "cli-grplib-get-full-name: Не найдена группа клиентов с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_cli-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_cli-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_cli-grp.upper-code
        .
        find first buf_cli-grp no-lock
             where buf_cli-grp.node-code = v-upper-code
        no-error.
        if not available buf_cli-grp
        then do:
            undo, return error "cli-grplib-get-full-name: Не найдена группа клиентов с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure cgrplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_cli-grp       for ub.cli-grp.
do
on error undo, return error
:
  find first buf_cli-grp no-lock
      where buf_cli-grp.upper-code = 0
  no-error .
  if not available buf_cli-grp
  then do:
      undo, return error substitute("Не найдена корневая группа клиентов (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_cli-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_cli-grp no-lock where
              buf_cli-grp.node-name = v-entry
          and buf_cli-grp.upper-code = v-upper-code
          no-error.
    if not available buf_cli-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_cli-grp.node-code.
      v-upper-code = buf_cli-grp.node-code.
    end.
  end.
end.
end .
procedure cgrplib-get-root-code :
do
on error undo, return error
:
define output parameter p-root-code as integer      no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    find first buf_cli-grp no-lock
        where buf_cli-grp.upper-code = 0
    no-error .
    if not available buf_cli-grp
    then do:
        undo, return error .
    end.
    else do:
        assign
            p-root-code = buf_cli-grp.node-code
        .
    end.
end.
end procedure.
procedure cgrplib-find-grp-by-full-name :
do
on error undo, return error
:
define input parameter p-search-name  as character    no-undo.
define input parameter p-fill-path    as logical      no-undo.
    define variable v-upper-code    as integer          no-undo.
    define variable v-not-found     as logical init yes no-undo.
    define variable v-counter       as integer           no-undo.
    define variable v-level         as integer           no-undo.
    define variable v-full-name     as character         no-undo.
    define variable v-sort-name     as character         no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    assign
        p-search-name = replace( p-search-name, chr(47), chr(2) )
    .
    run cgrplib-get-root-code ( output v-upper-code ) no-error .
    if error-status :error
    then do:
        undo, return error "cgrplib-expand-name: Ошибка при поиске корневого узла".
    end.
    assign
        v-full-name  = ""
        v-level      = num-entries( p-search-name, chr(2) )
    .
    for each temp_cgrplib_found-grp
    :
        delete temp_cgrplib_found-grp.
    end.
    start-name-analyze:
    do v-counter = 1 to v-level
    :
        if v-counter < v-level
        then do:
            find first buf_cli-grp no-lock
                 where buf_cli-grp.upper-code = v-upper-code
                   and buf_cli-grp.node-name  = entry( v-counter, p-search-name, chr(2) )
            no-error .
            if not available buf_cli-grp
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                return error "cgrplib-expand-name: не найдена группа " + entry( v-level, p-search-name, chr(2) ).
            end.
            else do:
                assign
                    v-full-name = v-full-name + (if v-full-name = "" then "" else chr(47) )         + buf_cli-grp.node-name
                    v-sort-name = v-sort-name + ( if v-sort-name = "" then "" else chr(2) ) + buf_cli-grp.node-name
                    v-upper-code = buf_cli-grp.node-code
                .
                if p-fill-path = yes
                then do:
                    create temp_cgrplib_found-grp.
                    assign
                        temp_cgrplib_found-grp.full-name = v-full-name + chr(47)
                        temp_cgrplib_found-grp.sort-name = v-sort-name
                        temp_cgrplib_found-grp.node-code = v-upper-code
                        temp_cgrplib_found-grp.level     = v-counter
                    .
                end.
            end.
        end.
        else do:
            for each buf_cli-grp no-lock
               where buf_cli-grp.upper-code = v-upper-code
                 and buf_cli-grp.node-name begins entry( v-counter, p-search-name, chr(2) )
            :
                assign
                    v-not-found = no
                .
                create temp_cgrplib_found-grp.
                assign
                    temp_cgrplib_found-grp.full-name = v-full-name
                                                        + ( if v-full-name = "" then "" else chr(47) )
                                                        + buf_cli-grp.node-name + chr(47)
                    temp_cgrplib_found-grp.sort-name = v-sort-name
                                                        + ( if v-sort-name = "" then "" else chr(2) )
                                                        + buf_cli-grp.node-name
                    temp_cgrplib_found-grp.node-code = buf_cli-grp.node-code
                    temp_cgrplib_found-grp.level     = v-level
                .
            end.
            if v-not-found = yes
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                for each temp_cgrplib_found-grp
                :
                    delete temp_cgrplib_found-grp.
                end.
                return error "cgrplib-expand-name: не найдена группа " + entry( v-level, p-search-name, chr(2) ).
            end.
        end.
    end.
end.
end procedure.
procedure cgrplib-find-all-subgroup :
do
on error undo, return error
:
define input parameter p-start-node-code    as integer      no-undo.
define input parameter p-terminal-only      as logical      no-undo.
    define variable v-start-full-name   as character     no-undo.
    define variable v-start-sort-name   as character     no-undo.
    define variable v-not-found         as logical       no-undo.
    define variable v-is-terminal       as logical       no-undo.
    define variable v-d-pcnt            as decimal       no-undo.
    define buffer buf_cli-grp           for ub.cli-grp.
    create temp_cfound-result-nodelist.
    assign
        temp_cfound-result-nodelist.node-code = p-start-node-code
        temp_cfound-result-nodelist.processed = no
    .
    run cli-grplib-get-full-name in this-procedure (
          input p-start-node-code
        , output v-start-full-name
    ).
    run cli-grplib-get-sort-name in this-procedure (
          input p-start-node-code
        , output v-start-sort-name
    ).
    process-nodes:
    do while yes
    :
        find first temp_cfound-result-nodelist
             where temp_cfound-result-nodelist.node-code = p-start-node-code
        .
        assign
            temp_cfound-result-nodelist.processed = yes
        .
        for each buf_cli-grp no-lock
           where buf_cli-grp.upper-code = p-start-node-code
        on error undo, return error
        :
            run cgrplib-is-terminal in this-procedure (
                  input buf_cli-grp.node-code
                , output v-is-terminal
            ).
            if v-is-terminal = yes
            then do:
                create temp_cgrplib_found-grp.
                assign
                    temp_cgrplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                        chr(47) + buf_cli-grp.node-name + chr(47)
                    temp_cgrplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                        chr(2) + buf_cli-grp.node-name + chr(2)
                    temp_cgrplib_found-grp.node-code   = buf_cli-grp.node-code
                    temp_cgrplib_found-grp.is-terminal = yes
                .
               run cgrplib-get-pcnt-value in this-procedure ( input temp_cgrplib_found-grp.node-code , output v-d-pcnt) no-error .
               if not error-status:error then do:
                 temp_cgrplib_found-grp.d-pcnt = v-d-pcnt.
               end.
               else do:
                 temp_cgrplib_found-grp.d-pcnt = ?.
               end.
            end.
            else do:
                create temp_cfound-result-nodelist.
                assign
                    temp_cfound-result-nodelist.node-code = buf_cli-grp.node-code
                    temp_cfound-result-nodelist.full-name = right-trim(v-start-full-name, chr(47)) +
                                                           chr(47) + buf_cli-grp.node-name + chr(47)
                    temp_cfound-result-nodelist.sort-name = right-trim(v-start-sort-name, chr(2)) +
                                                           chr(2) + buf_cli-grp.node-name + chr(2)
                    temp_cfound-result-nodelist.processed = no
                .
                if p-terminal-only = no
                then do:
                    create temp_cgrplib_found-grp.
                    assign
                        temp_cgrplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                            chr(47) + buf_cli-grp.node-name + chr(47)
                        temp_cgrplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                            chr(2) + buf_cli-grp.node-name + chr(2)
                        temp_cgrplib_found-grp.node-code   = buf_cli-grp.node-code
                        temp_cgrplib_found-grp.is-terminal = no
                    .
                end.
            end.
        end.
        find first temp_cfound-result-nodelist
             where temp_cfound-result-nodelist.processed = no
        no-error.
        if not available temp_cfound-result-nodelist
        then do:
            leave process-nodes.
        end.
        else do:
            assign
                p-start-node-code = temp_cfound-result-nodelist.node-code
                v-start-full-name = temp_cfound-result-nodelist.full-name
                v-start-sort-name = temp_cfound-result-nodelist.sort-name
            .
        end.
    end.
end.
end procedure.
procedure cgrplib-expand-name :
do
on error undo, return error
:
define input parameter p-start-name as character        no-undo.
define output parameter p-end-name  as character        no-undo.
    define variable v-is-terminal     as logical           no-undo.
    define buffer buf_temp_cgrplib_found-grp     for temp_cgrplib_found-grp.
    run cgrplib-find-grp-by-full-name in this-procedure (
          input p-start-name
        , input no
    ) no-error.
    run cgrplib-get-max-substring in this-procedure (
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
        find first temp_cgrplib_found-grp
            where temp_cgrplib_found-grp.full-name = p-end-name
        no-error.
        if available temp_cgrplib_found-grp
        then do:
            find first buf_temp_cgrplib_found-grp
                where buf_temp_cgrplib_found-grp.full-name begins p-end-name
                and recid( buf_temp_cgrplib_found-grp ) <> recid( temp_cgrplib_found-grp )
            no-error.
            if not available buf_temp_cgrplib_found-grp
            then do:
                run cgrplib-is-terminal in this-procedure (
                    input temp_cgrplib_found-grp.node-code
                    , output v-is-terminal
                ).
            end.
        end.
    end.
end.
end procedure.
procedure cgrplib-get-max-substring :
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
        find first temp_cgrplib_found-grp no-error.
        if not available temp_cgrplib_found-grp
        then do:
            undo, return error "cgrplib-get-max-substring: Нет строк для вычисления общей подстроки".
        end.
        else do:
            assign
                v-base-string = temp_cgrplib_found-grp.full-name
            .
            counter-block:
            do while yes
            on error undo, return error "cgrplib-get-max-substring: Ошибка вычисления продолжения имени группы."
            :
                assign
                    v-char-counter  = v-char-counter + 1
                    v-current-char  = substring( v-base-string, v-char-counter, 1 )
                    v-names-counter = 0
                .
                compare-block:
                for each temp_cgrplib_found-grp
                :
                    assign
                        v-names-counter = v-names-counter + 1
                    .
                    if v-names-counter = 1
                    then do:
                        next compare-block.
                    end.
                    if substring( temp_cgrplib_found-grp.full-name, v-char-counter, 1 ) <> v-current-char
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
procedure cgrplib-is-terminal :
do
on error undo, return error "Ошибка процедуры cgrplib-is-terminal"
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-is-terminal   as logical      no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    find first buf_cli-grp no-lock
        where buf_cli-grp.upper-code = p-node-code
    no-error .
    if not available buf_cli-grp
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
procedure cgrplib-have-clients :
do
on error undo, return error
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-have-clients   as logical      no-undo.
    define buffer buf_clients         for ub.clients.
    find first buf_clients no-lock
         where buf_clients.grp-code = p-node-code
    no-error .
    if available buf_clients
    then do:
        assign
            p-have-clients = yes
        .
    end.
    else do:
        assign
            p-have-clients = no
        .
    end.
end.
end procedure.
procedure cgrplib-find-by-substring :
do
on error undo, return error
:
define input parameter p-start-code         as integer      no-undo.
define input parameter p-full-search-string as character    no-undo.
define output parameter p-found-code        as integer      no-undo.
define output parameter p-full-name         as character    no-undo.
    define variable v-start-code     as integer           no-undo.
    define variable v-found          as logical  init no  no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    search-grp:
    for each buf_cli-grp no-lock
        where buf_cli-grp.node-code > p-start-code
    :
        if index( buf_cli-grp.node-name, p-full-search-string ) <> 0
        then do:
            assign
                p-found-code = buf_cli-grp.node-code
                v-found      = yes
            .
            run cli-grplib-get-full-name in this-procedure (
                  input p-found-code
                , output p-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "cgrplib-find-by-substring: Ошибка вычисления полного имени группы." + chr(10) + return-value.
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
procedure cgrplib-analyze-grp-name :
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
        run cli-grplib-get-full-name in this-procedure (
              input p-upper-code
            , output v-full-name
        ) no-error .
        if error-status :error
        then do:
            undo, return error "cgrplib-analyze-grp-name: Не удалось вычислить полное имя группы." + chr(10) + return-value.
        end.
        if length( v-full-name ) + 1 + length( p-grp-name ) > 120
        then do:
            assign
                p-error-message = 'Полное название группы не может содержать более 120 символов.'
            .
        end.
    end.
end.
end procedure.
procedure cgrplib-get-lvl-num :
define input parameter p-node-code  as integer      no-undo.
define output parameter p-lvl-num   as integer      no-undo.
    define variable v-full-name    as character    no-undo.
do
on error undo, return error
:
    run cli-grplib-get-full-name in this-procedure (
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
PROCEDURE cgrplib-get-pcnt-value :
DEFINE INPUT PARAMETER p-node-code AS INTEGER NO-UNDO.
DEFINE output PARAMETER p-pcnt-value AS DECIMAL NO-UNDO.
define buffer buf_dis-grp-rule for ub.dis-grp-rule.
define buffer buf_dis-rule for ub.dis-rule.
find first buf_dis-grp-rule no-lock where
          buf_dis-grp-rule.classif-type = 'cli-grp':U
      and buf_dis-grp-rule.node-code = p-node-code
      and buf_dis-grp-rule.host-code = 0
      and buf_dis-grp-rule.obj-type = '':U
      and buf_dis-grp-rule.obj-code = 0
      and buf_dis-grp-rule.pos-type = '-':U
      and buf_dis-grp-rule.discnt-role = 'cli-grp-pcnt':U no-error.
if available buf_dis-grp-rule then do:
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = buf_dis-grp-rule.rule-num no-error.
  if available buf_dis-rule then do:
    assign
    p-pcnt-value        = buf_dis-rule.discnt-value.
    .
  end.
end.
END PROCEDURE.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
  ASSIGN parParentProc =  my-handle .
  define variable g#report-num as integer no-undo .
  run get-report-num  in parparentproc (output  g#report-num).
def var vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info25 as character format "X(65)" no-undo
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
do
on error undo, return error
:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable num-line        as integer   no-undo .
  define variable i               as integer   no-undo .
  define variable ii              as integer   no-undo .
  define variable ij              as integer   no-undo .
  define variable jj              as integer   no-undo .
  define variable ind             as integer   no-undo .
  define variable lvel            as integer   no-undo .
  define variable old-lvel        as integer   no-undo .
  define variable Counter1        as integer   no-undo .
  define variable Line            as character no-undo .
  define variable CurrGrpName     as character no-undo .
  define variable ItogStr         as character no-undo .
  define variable fo              as decimal   no-undo .
  define variable v-grp-name      as character no-undo .
  define variable v-cgrp-name     as character no-undo .
  define variable v-row       as integer   no-undo .
  define variable v-col       as integer   no-undo .
  define variable v-ind       as integer   no-undo initial 1 .
  assign
    v-row = 1
    v-col = 1
  .
  assign Line = fill("-", 140).
  define buffer buf_gds-obj  for gds-obj.
  define buffer buf_clients  for clients .
  define buffer buf_goods    for goods.
  define buffer buf_stk-line for stk-line .
  define buffer buf_stk-supp-line for stk-supp-line .
  define buffer buf_gds-obj-prop for gds-obj-prop .
  DEFINE temp-table temp-gds no-undo
    field   qnty1            as  decimal
    field   qnty2            as  decimal
    field   min-qnty         as  decimal
    field   artic            as  char
    field   prod-type        as  char
    field   prod-code        as  integer
    field   gds-code         as  integer
    field   gds-name         as  char
    field   unit-base        as  char
    field   grp-code         as  integer
    field   grp-name         as  char
    field   cgrp-code        as  integer
    field   cgrp-name        as  char
    INDEX pi  IS PRIMARY   artic  prod-type prod-code
    INDEX pi1              gds-name
    INDEX pi2              grp-code
    INDEX pi3              grp-name
    INDEX pi5              cgrp-code
    INDEX pi6              cgrp-name
  .
  DEFINE temp-table temp-gds-time   like temp-gds
    field   dt               as  date
    field   tm               as  integer
    field   fo               as  decimal
    INDEX pi4   dt tm
  .
  DEFINE temp-table temp-gds-post  like temp-gds
    field   post-type        as  char
    field   post-code        as  integer
    INDEX pi4   post-type post-code
  .
  DEFINE temp-table temp-gds-time-post like temp-gds
    field   dt               as  date
    field   tm               as  integer
    field   fo               as  decimal
    field   post-type        as  char
    field   post-code        as  integer
    INDEX pi4      dt tm   post-type post-code
  .
DEFINE temp-table temp-sum no-undo
  field  num          as integer
  field  qnty1        as decimal
  field  qnty2        as decimal
  field  qnty3        as decimal
  INDEX pi  IS PRIMARY unique num
.
DEFINE temp-table tt-grp-tree no-undo
  field  num          as  integer
  field  full         as character
  field  name         as character
  field  qnty1        as decimal
  field  qnty2        as decimal
  field  qnty3        as decimal
  INDEX pi  IS PRIMARY unique full
  INDEX pi1 num
.
  define variable v-min-qnty  as decimal   no-undo .
  define variable v-attr-type   as character no-undo .
  define variable v-table as integer   no-undo .
  define variable frmt as character no-undo .
  assign frmt = "X(123)" .
  define variable frmt1 as character no-undo .
  assign frmt1 = "X(121)" .
  assign  Counter1 = 0 .
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
assign v-account = ( if integer( 100 ) = 0 then 100 else integer( 100 ) ).
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
  case x-SelectGood :
    when 1 then do:
      for each buf_goods no-lock :
define variable vss-include-info28 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
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
  find first buf_gds-obj-prop no-lock
    where buf_gds-obj-prop.obj-type = p-cli-type1
      and buf_gds-obj-prop.obj-code = p-cli-code1
      and buf_gds-obj-prop.gds-code = buf_goods.gds-code
  no-error .
  if available buf_gds-obj-prop then assign   v-min-qnty = buf_gds-obj-prop.gdop-min-stock  .
  else  assign v-min-qnty = 0 .
  if v-min-qnty = 0 or v-min-qnty = ? then next .
  create temp-gds .
  assign
    temp-gds.prod-type = buf_goods.prod-type
    temp-gds.prod-code = buf_goods.prod-code
    temp-gds.artic     = buf_goods.artic
    temp-gds.unit-base = buf_goods.unit-base
    temp-gds.gds-code  = buf_goods.gds-code
    temp-gds.gds-name  = buf_goods.gds-name
    temp-gds.grp-code  = buf_goods.grp-code
    temp-gds.grp-name  = trim( buf_goods.grp-name )
    temp-gds.min-qnty  = v-min-qnty
  .
      end.
    end.
    when 3 then do:
      for each G#cli :
        for each buf_goods  no-lock
          where buf_goods.prod-type = G#cli.obj-type
            and buf_goods.prod-code = G#cli.obj-code
          :
define variable vss-include-info29 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
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
  find first buf_gds-obj-prop no-lock
    where buf_gds-obj-prop.obj-type = p-cli-type1
      and buf_gds-obj-prop.obj-code = p-cli-code1
      and buf_gds-obj-prop.gds-code = buf_goods.gds-code
  no-error .
  if available buf_gds-obj-prop then assign   v-min-qnty = buf_gds-obj-prop.gdop-min-stock  .
  else  assign v-min-qnty = 0 .
  if v-min-qnty = 0 or v-min-qnty = ? then next .
  create temp-gds .
  assign
    temp-gds.prod-type = buf_goods.prod-type
    temp-gds.prod-code = buf_goods.prod-code
    temp-gds.artic     = buf_goods.artic
    temp-gds.unit-base = buf_goods.unit-base
    temp-gds.gds-code  = buf_goods.gds-code
    temp-gds.gds-name  = buf_goods.gds-name
    temp-gds.grp-code  = buf_goods.grp-code
    temp-gds.grp-name  = trim( buf_goods.grp-name )
    temp-gds.min-qnty  = v-min-qnty
  .
        end .
      end.
    end .
    when 2 then do:
      for each tmp#grp :
        run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output CurrGrpName ) .
        for each buf_goods no-lock where buf_goods.grp-name begins CurrGrpName :
define variable vss-include-info30 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
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
  find first buf_gds-obj-prop no-lock
    where buf_gds-obj-prop.obj-type = p-cli-type1
      and buf_gds-obj-prop.obj-code = p-cli-code1
      and buf_gds-obj-prop.gds-code = buf_goods.gds-code
  no-error .
  if available buf_gds-obj-prop then assign   v-min-qnty = buf_gds-obj-prop.gdop-min-stock  .
  else  assign v-min-qnty = 0 .
  if v-min-qnty = 0 or v-min-qnty = ? then next .
  create temp-gds .
  assign
    temp-gds.prod-type = buf_goods.prod-type
    temp-gds.prod-code = buf_goods.prod-code
    temp-gds.artic     = buf_goods.artic
    temp-gds.unit-base = buf_goods.unit-base
    temp-gds.gds-code  = buf_goods.gds-code
    temp-gds.gds-name  = buf_goods.gds-name
    temp-gds.grp-code  = buf_goods.grp-code
    temp-gds.grp-name  = trim( buf_goods.grp-name )
    temp-gds.min-qnty  = v-min-qnty
  .
        end .
      end.
    end.
    otherwise do:
      for each gds-list ,
          each buf_goods no-lock
        where buf_goods.artic     = gds-list.artic
          and buf_goods.prod-type = gds-list.prod-type
          and buf_goods.prod-code = gds-list.prod-code
        :
define variable vss-include-info31 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
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
  find first buf_gds-obj-prop no-lock
    where buf_gds-obj-prop.obj-type = p-cli-type1
      and buf_gds-obj-prop.obj-code = p-cli-code1
      and buf_gds-obj-prop.gds-code = buf_goods.gds-code
  no-error .
  if available buf_gds-obj-prop then assign   v-min-qnty = buf_gds-obj-prop.gdop-min-stock  .
  else  assign v-min-qnty = 0 .
  if v-min-qnty = 0 or v-min-qnty = ? then next .
  create temp-gds .
  assign
    temp-gds.prod-type = buf_goods.prod-type
    temp-gds.prod-code = buf_goods.prod-code
    temp-gds.artic     = buf_goods.artic
    temp-gds.unit-base = buf_goods.unit-base
    temp-gds.gds-code  = buf_goods.gds-code
    temp-gds.gds-name  = buf_goods.gds-name
    temp-gds.grp-code  = buf_goods.grp-code
    temp-gds.grp-name  = trim( buf_goods.grp-name )
    temp-gds.min-qnty  = v-min-qnty
  .
      end.
    end.
  end case.
  if p-Rad-Inter = 1 then do:
    do ii = 0 to p-date2 - p-date1 :
      do jj = 0 to 23 :
        run Find-fo in this-procedure ( p-date1 + ii, jj * 3600, output fo) .
        for each temp-gds :
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
          if xClassify = "post":U or xClassify = "post/grp-goods":U or xClassify = "grp-goods/post":U then do:
            run partslib-init-temp-parts-by-factord in this-procedure( input p-cli-type1, input p-cli-code1, input temp-gds.artic, input temp-gds.prod-type, input temp-gds.prod-code, input fo, input false ) .
            for each temp-parts :
              find first temp-gds-time-post
                where temp-gds-time-post.prod-type = temp-gds.prod-type
                  and temp-gds-time-post.prod-code = temp-gds.prod-code
                  and temp-gds-time-post.artic     = temp-gds.artic
                  and temp-gds-time-post.post-type = temp-parts.supp-type
                  and temp-gds-time-post.post-code = temp-parts.supp-code
                  and temp-gds-time-post.dt        = p-date1 + ii
                  and temp-gds-time-post.tm        = jj
              no-error .
              if not available temp-gds-time-post then do:
                create temp-gds-time-post .
                BUFFER-COPY temp-gds to temp-gds-time-post .
                assign
                  temp-gds-time-post.dt = p-date1 + ii
                  temp-gds-time-post.tm = jj
                  temp-gds-time-post.fo = fo
                  temp-gds-time-post.post-type = temp-parts.supp-type
                  temp-gds-time-post.post-code = temp-parts.supp-code
                .
                find first buf_clients no-lock where buf_clients.obj-type = temp-parts.supp-type and buf_clients.obj-code = temp-parts.supp-code no-error .
                if available buf_clients then do:
                  assign
                    temp-gds-time-post.cgrp-code  = buf_clients.grp-code
                    temp-gds-time-post.cgrp-name  = trim( buf_clients.grp-name )
                  .
                end.
              end.
              assign temp-gds-time-post.qnty1 = temp-gds-time-post.qnty1 + temp-parts.fact-qnty .
            end.
            run partslib-init-temp-parts-by-factord in this-procedure( input p-cli-type2, input p-cli-code2, input temp-gds.artic, input temp-gds.prod-type, input temp-gds.prod-code, input fo, input false ) .
            for each temp-parts :
              find first temp-gds-time-post
                where temp-gds-time-post.prod-type = temp-gds.prod-type
                  and temp-gds-time-post.prod-code = temp-gds.prod-code
                  and temp-gds-time-post.artic     = temp-gds.artic
                  and temp-gds-time-post.post-type = temp-parts.supp-type
                  and temp-gds-time-post.post-code = temp-parts.supp-code
                  and temp-gds-time-post.dt        = p-date1 + ii
                  and temp-gds-time-post.tm        = jj
              no-error .
              if available temp-gds-time-post then assign temp-gds-time-post.qnty1 = temp-gds-time-post.qnty1 + temp-parts.fact-qnty .
            end.
          end.
          else do:
            create temp-gds-time .
            BUFFER-COPY temp-gds to temp-gds-time .
            assign
              temp-gds-time.dt = p-date1 + ii
              temp-gds-time.tm = jj
              temp-gds-time.fo = fo
            .
            run partslib-init-temp-parts-by-factord in this-procedure( input p-cli-type1, input p-cli-code1, input temp-gds.artic, input temp-gds.prod-type, input temp-gds.prod-code, input fo, input false ) .
            for each temp-parts :
              assign temp-gds-time.qnty1 = temp-gds-time.qnty1 + temp-parts.fact-qnty .
            end.
            run partslib-init-temp-parts-by-factord in this-procedure( input p-cli-type2, input p-cli-code2, input temp-gds.artic, input temp-gds.prod-type, input temp-gds.prod-code, input fo, input false ) .
            for each temp-parts :
              assign temp-gds-time.qnty2 = temp-gds-time.qnty2 + temp-parts.fact-qnty .
            end.
          end.
        end.
      end.
    end.
  end.
  else do:
    run Find-fo in this-procedure ( p-date1, p-time * 3600, output fo) .
    if xClassify = "post":U or xClassify = "post/grp-goods":U or xClassify = "grp-goods/post":U then do:
      for each temp-gds :
        run partslib-init-temp-parts-by-factord in this-procedure( input p-cli-type1, input p-cli-code1, input temp-gds.artic, input temp-gds.prod-type, input temp-gds.prod-code, input fo, input false ) .
        for each temp-parts :
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
          find first temp-gds-post
            where temp-gds-post.prod-type = temp-gds.prod-type
              and temp-gds-post.prod-code = temp-gds.prod-code
              and temp-gds-post.artic     = temp-gds.artic
              and temp-gds-post.post-type = temp-parts.supp-type
              and temp-gds-post.post-code = temp-parts.supp-code
          no-error .
          if not available temp-gds-post then do:
            create temp-gds-post .
            BUFFER-COPY temp-gds to temp-gds-post .
            assign
              temp-gds-post.post-type = temp-parts.supp-type
              temp-gds-post.post-code = temp-parts.supp-code
            .
            find first buf_clients no-lock where buf_clients.obj-type = temp-parts.supp-type and buf_clients.obj-code = temp-parts.supp-code no-error .
            if available buf_clients then do:
              assign
                temp-gds-post.cgrp-code  = buf_clients.grp-code
                temp-gds-post.cgrp-name  = trim( buf_clients.grp-name )
              .
            end.
          end.
          assign temp-gds-post.qnty1 = temp-gds-post.qnty1 + temp-parts.fact-qnty .
        end.
        run partslib-init-temp-parts-by-factord in this-procedure( input p-cli-type2, input p-cli-code2, input temp-gds.artic, input temp-gds.prod-type, input temp-gds.prod-code, input fo, input false ) .
        for each temp-parts :
          find first temp-gds-post
            where temp-gds-post.prod-type = temp-gds.prod-type
              and temp-gds-post.prod-code = temp-gds.prod-code
              and temp-gds-post.artic     = temp-gds.artic
              and temp-gds-post.post-type = temp-parts.supp-type
              and temp-gds-post.post-code = temp-parts.supp-code
          no-error .
          if available temp-gds-post then assign temp-gds-post.qnty2 = temp-gds-post.qnty2 + temp-parts.fact-qnty .
        end.
      end.
    end.
    else do:
      for each temp-gds :
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
        run partslib-init-temp-parts-by-factord in this-procedure( input p-cli-type1, input p-cli-code1, input temp-gds.artic, input temp-gds.prod-type, input temp-gds.prod-code, input fo, input false ) .
        for each temp-parts :
          assign temp-gds.qnty1 = temp-gds.qnty1 + temp-parts.fact-qnty .
        end.
        run partslib-init-temp-parts-by-factord in this-procedure( input p-cli-type2, input p-cli-code2, input temp-gds.artic, input temp-gds.prod-type, input temp-gds.prod-code, input fo, input false ) .
        for each temp-parts :
          assign temp-gds.qnty2 = temp-gds.qnty2 + temp-parts.fact-qnty .
        end.
      end.
    end.
  end.
  run prn-lib-open-stream  in this-procedure ( input parParentProc, input 63, input yes, input no ).
  assign
    make-excel = yes
    v-file-name = string(session :temp-directory) + "rpt" + string( g#report-num ) + ".txt"
  .
  output stream macr_excel to value(v-file-name) .
  assign v-ind = v-ind + 1 .
  PUT stream PrnLibStream  space(20) ReportNAme  format "X(100)" skip .
  PUT stream PrnLibStream  ReportHeader format "X(130)" skip .
  assign
    v-table = 1
  .
  run ColumnTitle in this-procedure .
  run PutColumnTitulExcel in this-procedure .
  CASE xClassify :
    when "no-classify":U  then       Run Run0 .
    when "grp-goods":U then DO:
      if  xtog-lavel then do:   Run Run11 .    end.
      else do:                  Run Run1 .     end.
    END.
    when "post":U then DO:
      if xtog-lavel-2 then do:  Run Run55 .     end.
      else do:                  Run Run5 .      end.
    End.
    when "post/grp-goods":U then     Run run6 .
    when "grp-goods/post":U then     Run Run7 .
  End case.
  HIDE stream PrnLibStream FRAME BottomFrame .
  if  p-Rad-Inter = 1  then  put stream PrnLibStream   Line format frmt skip .
  else do:
    Run PrintItog (" ИТОГО: ", 0).
    put stream PrnLibStream   Line format "X(107)" skip .
  end.
  if p-ShowGoods then do:
    assign
      v-table = 2
      old-lvel = 0
    .
    run ColumnTitle in this-procedure .
    run PutColumnTitulExcel in this-procedure .
    CASE xClassify :
      when "no-classify":U  then       Run Run0 .
      when "grp-goods":U then DO:
        if  xtog-lavel then do:   Run Run11 .    end.
        else do:                  Run Run1 .     end.
      END.
      when "post":U then DO:
        if xtog-lavel-2 then do:  Run Run55 .     end.
        else do:                  Run Run5 .      end.
      End.
      when "post/grp-goods":U then     Run run6 .
      when "grp-goods/post":U then     Run Run7 .
    End case.
    HIDE stream PrnLibStream FRAME BottomFrame .
    if  p-Rad-Inter = 1  then  put stream PrnLibStream   Line format "X(132)" skip .
    else                       put stream PrnLibStream   Line format "X(117)" skip .
  end.
  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .
  run end-proc .
  HIDE STREAM   PrnLibStream   FRAME ZAPAS .
  Output stream PrnLibStream   close .
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
  run prn-lib-prn-file in this-procedure ( input parParentProc, input 0 ).
end.
define variable vss-include-info32 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure Run0 :
  do on error undo, return error return-value :
    if  p-Rad-Inter = 1  then do:
      for each temp-gds-time
        break by temp-gds-time.dt by temp-gds-time.tm by if xSortType = "sort-article" then  temp-gds-time.artic      Else  temp-gds-time.gds-name :
        if first-of(temp-gds-time.tm) then run PrintTime ( string(temp-gds-time.dt,"99/99/99") + " " + string(temp-gds-time.tm,"99") + ".00" ) .
        run PrintLine  in this-procedure ( temp-gds-time.qnty1, temp-gds-time.qnty2, temp-gds-time.min-qnty, temp-gds-time.artic, temp-gds-time.gds-name, temp-gds-time.unit-base) .
        if last-of(temp-gds-time.tm)  then Run PrintItog ("Всего ", 1).
      end.
    end.
    else do:
      for each temp-gds break by if xSortType = "sort-article" then  temp-gds.artic           Else  temp-gds.gds-name :
        run PrintLine  in this-procedure ( temp-gds.qnty1, temp-gds.qnty2, temp-gds.min-qnty, temp-gds.artic, temp-gds.gds-name, temp-gds.unit-base) .
      end.
    end.
  end.
end procedure.
procedure Run1 :
  do on error undo, return error return-value :
    if  p-Rad-Inter = 1  then do:
      for each temp-gds-time  break by temp-gds-time.dt by temp-gds-time.tm  by temp-gds-time.grp-name  by if xSortType = "sort-article" then  temp-gds-time.artic      Else  temp-gds-time.gds-name :
        if first-of(temp-gds-time.tm) then  run PrintTime ( string(temp-gds-time.dt,"99/99/99") + " " + string(temp-gds-time.tm,"99") + ".00" ) .
        if first-of(temp-gds-time.grp-name)  then run PrintName ( "  Группа " + temp-gds-time.grp-name ) .
        run PrintLine  in this-procedure ( temp-gds-time.qnty1, temp-gds-time.qnty2, temp-gds-time.min-qnty, temp-gds-time.artic, temp-gds-time.gds-name, temp-gds-time.unit-base) .
        if last-of(temp-gds-time.grp-name)   then Run PrintItog ("  Всего по группе " + temp-gds-time.grp-name, 1).
        if last-of(temp-gds-time.tm)  then Run PrintItog ("Всего ", 2).
      end.
    end.
    else do:
      for each temp-gds break by temp-gds.grp-name by if xSortType = "sort-article" then  temp-gds.artic           Else  temp-gds.gds-name :
        if first-of(temp-gds.grp-name)  then run PrintName ( "Группа " + temp-gds.grp-name ) .
        run PrintLine  in this-procedure ( temp-gds.qnty1, temp-gds.qnty2, temp-gds.min-qnty, temp-gds.artic, temp-gds.gds-name, temp-gds.unit-base) .
        if last-of(temp-gds.grp-name)   then Run PrintItog ("Всего по группе " + temp-gds.grp-name, 1).
      end.
    end.
  end.
end procedure.
procedure Run11 :
  do on error undo, return error return-value :
    if  p-Rad-Inter = 1  then do:
      for each temp-gds-time
        break by temp-gds-time.dt
              by temp-gds-time.tm
              by temp-gds-time.grp-name
              by if xSortType = "sort-article" then  temp-gds-time.artic      Else  temp-gds-time.gds-name :
        if first-of(temp-gds-time.tm) then  run PrintTime ( string(temp-gds-time.dt,"99/99/99") + " " + string(temp-gds-time.tm,"99") + ".00" ) .
        if first-of(temp-gds-time.grp-name) then do:
          assign
            lvel = num-entries( right-trim(temp-gds-time.grp-name, chr(47)), chr(47) )
            v-grp-name = temp-gds-time.grp-name
          .
define variable vss-include-info33 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  assign CurrGrpName = "" .
  do ind = 1 to lvel :
    assign CurrGrpName = CurrGrpName + entry ( ind, v-grp-name, chr(47) )  + chr(47) .
    find first tt-grp-tree where tt-grp-tree.full = CurrGrpName no-error .
    if not available tt-grp-tree then LEAVE.
  end.
  do ij = old-lvel to ind by -1 :
    find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
    if ij <= xvar-lavel then do:
      assign ItogStr = "" .
      do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
      assign ItogStr = ItogStr + "Всего по группе " + tt-grp-tree.name .
      run PrintItogGroup in this-procedure ( ItogStr, tt-grp-tree.qnty1, tt-grp-tree.qnty2, tt-grp-tree.qnty3 ) .
    end.
    delete tt-grp-tree .
  end.
  assign old-lvel = lvel .
  run is-page .
  do ij = ind to lvel :
    create tt-grp-tree .
    if ij > ind then do:
      assign CurrGrpName = CurrGrpName + entry ( ij, v-grp-name, chr(47) )  + chr(47) .
    end.
    assign
      tt-grp-tree.num  = ij + 3
      tt-grp-tree.full = CurrGrpName
      tt-grp-tree.name = entry ( ij, v-grp-name, chr(47) )
      tt-grp-tree.qnty1 = 0
      tt-grp-tree.qnty2 = 0
      tt-grp-tree.qnty3 = 0
    .
    if ij <= xvar-lavel then do:
      assign ItogStr = "" .
      do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
      run PrintName ( ItogStr + "Группа " + tt-grp-tree.name ) .
    end.
  end.
        end.
        run PrintLine  in this-procedure ( temp-gds-time.qnty1, temp-gds-time.qnty2, temp-gds-time.min-qnty, temp-gds-time.artic, temp-gds-time.gds-name, temp-gds-time.unit-base) .
        if last-of(temp-gds-time.tm) then do:
          do ij = old-lvel to 1 by -1 :
            find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
            if ij <= xvar-lavel then do:
              assign ItogStr = "" .
              do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
              assign ItogStr = ItogStr + "Всего по группе " + tt-grp-tree.name .
              run PrintItogGroup in this-procedure ( ItogStr, tt-grp-tree.qnty1, tt-grp-tree.qnty2, tt-grp-tree.qnty3 ) .
            end.
            delete tt-grp-tree .
          end.
          assign old-lvel = 0 .
          Run PrintItog ("Всего ", 1).
        end.
      end.
    end.
    else do:
      for each temp-gds  break by temp-gds.grp-name by if xSortType = "sort-article" then  temp-gds.artic           Else  temp-gds.gds-name :
        if first-of(temp-gds.grp-name) then do:
          assign
            lvel = num-entries( right-trim(temp-gds.grp-name, chr(47)), chr(47) )
            v-grp-name = temp-gds.grp-name
          .
define variable vss-include-info34 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  assign CurrGrpName = "" .
  do ind = 1 to lvel :
    assign CurrGrpName = CurrGrpName + entry ( ind, v-grp-name, chr(47) )  + chr(47) .
    find first tt-grp-tree where tt-grp-tree.full = CurrGrpName no-error .
    if not available tt-grp-tree then LEAVE.
  end.
  do ij = old-lvel to ind by -1 :
    find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
    if ij <= xvar-lavel then do:
      assign ItogStr = "" .
      do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
      assign ItogStr = ItogStr + "Всего по группе " + tt-grp-tree.name .
      run PrintItogGroup in this-procedure ( ItogStr, tt-grp-tree.qnty1, tt-grp-tree.qnty2, tt-grp-tree.qnty3 ) .
    end.
    delete tt-grp-tree .
  end.
  assign old-lvel = lvel .
  run is-page .
  do ij = ind to lvel :
    create tt-grp-tree .
    if ij > ind then do:
      assign CurrGrpName = CurrGrpName + entry ( ij, v-grp-name, chr(47) )  + chr(47) .
    end.
    assign
      tt-grp-tree.num  = ij + 3
      tt-grp-tree.full = CurrGrpName
      tt-grp-tree.name = entry ( ij, v-grp-name, chr(47) )
      tt-grp-tree.qnty1 = 0
      tt-grp-tree.qnty2 = 0
      tt-grp-tree.qnty3 = 0
    .
    if ij <= xvar-lavel then do:
      assign ItogStr = "" .
      do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
      run PrintName ( ItogStr + "Группа " + tt-grp-tree.name ) .
    end.
  end.
        end.
        run PrintLine  in this-procedure ( temp-gds.qnty1, temp-gds.qnty2, temp-gds.min-qnty, temp-gds.artic, temp-gds.gds-name, temp-gds.unit-base) .
      end.
      do ij = old-lvel to 1 by -1 :
        find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
        if ij <= xvar-lavel then do:
          assign ItogStr = "" .
          do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
          assign ItogStr = ItogStr + "Всего по группе " + tt-grp-tree.name .
          run PrintItogGroup in this-procedure ( ItogStr, tt-grp-tree.qnty1, tt-grp-tree.qnty2, tt-grp-tree.qnty3 ) .
        end.
        delete tt-grp-tree .
      end.
    end.
  end.
end procedure.
procedure Run5 :
  do on error undo, return error return-value :
    if  p-Rad-Inter = 1  then do:
      for each temp-gds-time-post
        break by temp-gds-time-post.dt
              by temp-gds-time-post.tm
              by temp-gds-time-post.cgrp-name
              by temp-gds-time-post.post-type
              by temp-gds-time-post.post-code
              by if xSortType = "sort-article" then  temp-gds-time-post.artic Else  temp-gds-time-post.gds-name :
        if first-of(temp-gds-time-post.tm) then  run PrintTime ( string(temp-gds-time-post.dt,"99/99/99") + " " + string(temp-gds-time-post.tm,"99") + ".00" ) .
        if first-of(temp-gds-time-post.cgrp-name) then run PrintName ( "  Гр. пост. " + temp-gds-time-post.cgrp-name ) .
        if first-of(temp-gds-time-post.post-code) then do:
          find first buf_clients no-lock where buf_clients.obj-type = temp-gds-time-post.post-type and buf_clients.obj-code = temp-gds-time-post.post-code no-error .
          run PrintName ( "    Поставщик " + buf_clients.obj-name ) .
        end.
        run PrintLine  in this-procedure ( temp-gds-time-post.qnty1, temp-gds-time-post.qnty2, temp-gds-time-post.min-qnty, temp-gds-time-post.artic, temp-gds-time-post.gds-name, temp-gds-time-post.unit-base) .
        if last-of(temp-gds-time-post.post-code)  then Run PrintItog ("    Всего по поставщику " + buf_clients.obj-name, 1).
        if last-of(temp-gds-time-post.cgrp-name)  then Run PrintItog ("  Всего по гр. пост. " + temp-gds-time-post.cgrp-name, 2).
        if last-of(temp-gds-time-post.tm)  then Run PrintItog ("Всего ", 3).
      end.
    end.
    else do:
      for each temp-gds-post
        break by temp-gds-post.cgrp-name
              by temp-gds-post.post-type
              by temp-gds-post.post-code
              by if xSortType = "sort-article" then  temp-gds-post.artic      Else  temp-gds-post.gds-name :
        if first-of(temp-gds-post.cgrp-name) then run PrintName ( "Гр. пост. " + temp-gds-post.cgrp-name ) .
        if first-of(temp-gds-post.post-code) then do:
          find first buf_clients no-lock where buf_clients.obj-type = temp-gds-post.post-type and buf_clients.obj-code = temp-gds-post.post-code no-error .
          run PrintName ( "  Поставщик " + buf_clients.obj-name ) .
        end.
        run PrintLine  in this-procedure ( temp-gds-post.qnty1, temp-gds-post.qnty2, temp-gds-post.min-qnty, temp-gds-post.artic, temp-gds-post.gds-name, temp-gds-post.unit-base) .
        if last-of(temp-gds-post.post-code)  then Run PrintItog ("  Всего по поставщику " + buf_clients.obj-name, 1).
        if last-of(temp-gds-post.cgrp-name)  then Run PrintItog ("Всего по гр. пост. " + temp-gds-post.cgrp-name, 2).
      end.
    end.
  end.
end procedure.
procedure Run55 :
  do on error undo, return error return-value :
    if  p-Rad-Inter = 1  then do:
      for each temp-gds-time-post
        break by temp-gds-time-post.dt
              by temp-gds-time-post.tm
              by temp-gds-time-post.cgrp-name
              by temp-gds-time-post.post-type
              by temp-gds-time-post.post-code
              by if xSortType = "sort-article" then  temp-gds-time-post.artic Else  temp-gds-time-post.gds-name :
        if first-of(temp-gds-time-post.tm) then run PrintTime ( string(temp-gds-time-post.dt,"99/99/99") + " " + string(temp-gds-time-post.tm,"99") + ".00" ) .
        if first-of(temp-gds-time-post.cgrp-name) then do:
          assign
            lvel = num-entries( right-trim(temp-gds-time-post.cgrp-name, chr(47)), chr(47) )
            v-cgrp-name = temp-gds-time-post.cgrp-name
          .
define variable vss-include-info35 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  assign CurrGrpName = "" .
  do ind = 1 to lvel :
    assign CurrGrpName = CurrGrpName + entry ( ind, v-cgrp-name, chr(47) )  + chr(47) .
    find first tt-grp-tree where tt-grp-tree.full = CurrGrpName no-error .
    if not available tt-grp-tree then LEAVE.
  end.
  do ij = old-lvel to ind by -1 :
    find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
    if ij <= xvar-lavel-2 then do:
      assign ItogStr = "" .
      do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
      assign ItogStr = ItogStr + "Всего по гр. пост. " + tt-grp-tree.name .
      run PrintItogGroup in this-procedure ( ItogStr, tt-grp-tree.qnty1, tt-grp-tree.qnty2, tt-grp-tree.qnty3 ) .
    end.
    delete tt-grp-tree .
  end.
  assign old-lvel = lvel .
  run is-page .
  do ij = ind to lvel :
    create tt-grp-tree .
    if ij > ind then do:
      assign CurrGrpName = CurrGrpName + entry ( ij, v-cgrp-name, chr(47) )  + chr(47) .
    end.
    assign
      tt-grp-tree.num  = ij + 3
      tt-grp-tree.full = CurrGrpName
      tt-grp-tree.name = entry ( ij, v-cgrp-name, chr(47) )
      tt-grp-tree.qnty1 = 0
      tt-grp-tree.qnty2 = 0
      tt-grp-tree.qnty3 = 0
    .
    if ij <= xvar-lavel-2 then do:
      assign ItogStr = "" .
      do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
      run PrintName ( ItogStr + "Гр. пост. " + tt-grp-tree.name ) .
    end.
  end.
        end.
        run PrintLine  in this-procedure ( temp-gds-time-post.qnty1, temp-gds-time-post.qnty2, temp-gds-time-post.min-qnty, temp-gds-time-post.artic, temp-gds-time-post.gds-name, temp-gds-time-post.unit-base) .
        if last-of(temp-gds-time-post.tm) then do:
          do ij = old-lvel to 1 by -1 :
            find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
            if ij <= xvar-lavel-2 then do:
              assign ItogStr = "" .
              do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
              assign ItogStr = ItogStr + "Всего по гр. пост. " + tt-grp-tree.name .
              run PrintItogGroup in this-procedure ( ItogStr, tt-grp-tree.qnty1, tt-grp-tree.qnty2, tt-grp-tree.qnty3 ) .
            end.
            delete tt-grp-tree .
          end.
          assign old-lvel = 0 .
          if last-of(temp-gds-time-post.tm)  then Run PrintItog ("Всего ", 1).
        end.
      end.
    end.
    else do:
      for each temp-gds-post
        break by temp-gds-post.cgrp-name
              by temp-gds-post.post-type
              by temp-gds-post.post-code
              by if xSortType = "sort-article" then  temp-gds-post.artic      Else  temp-gds-post.gds-name :
        if first-of(temp-gds-post.cgrp-name) then do:
          assign
            lvel = num-entries( right-trim(temp-gds-post.cgrp-name, chr(47)), chr(47) )
            v-cgrp-name = temp-gds-post.cgrp-name
          .
define variable vss-include-info36 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  assign CurrGrpName = "" .
  do ind = 1 to lvel :
    assign CurrGrpName = CurrGrpName + entry ( ind, v-cgrp-name, chr(47) )  + chr(47) .
    find first tt-grp-tree where tt-grp-tree.full = CurrGrpName no-error .
    if not available tt-grp-tree then LEAVE.
  end.
  do ij = old-lvel to ind by -1 :
    find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
    if ij <= xvar-lavel-2 then do:
      assign ItogStr = "" .
      do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
      assign ItogStr = ItogStr + "Всего по гр. пост. " + tt-grp-tree.name .
      run PrintItogGroup in this-procedure ( ItogStr, tt-grp-tree.qnty1, tt-grp-tree.qnty2, tt-grp-tree.qnty3 ) .
    end.
    delete tt-grp-tree .
  end.
  assign old-lvel = lvel .
  run is-page .
  do ij = ind to lvel :
    create tt-grp-tree .
    if ij > ind then do:
      assign CurrGrpName = CurrGrpName + entry ( ij, v-cgrp-name, chr(47) )  + chr(47) .
    end.
    assign
      tt-grp-tree.num  = ij + 3
      tt-grp-tree.full = CurrGrpName
      tt-grp-tree.name = entry ( ij, v-cgrp-name, chr(47) )
      tt-grp-tree.qnty1 = 0
      tt-grp-tree.qnty2 = 0
      tt-grp-tree.qnty3 = 0
    .
    if ij <= xvar-lavel-2 then do:
      assign ItogStr = "" .
      do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
      run PrintName ( ItogStr + "Гр. пост. " + tt-grp-tree.name ) .
    end.
  end.
        end.
        run PrintLine  in this-procedure ( temp-gds-post.qnty1, temp-gds-post.qnty2, temp-gds-post.min-qnty, temp-gds-post.artic, temp-gds-post.gds-name, temp-gds-post.unit-base) .
      end.
      do ij = old-lvel to 1 by -1 :
        find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
        if ij <= xvar-lavel-2 then do:
          assign ItogStr = "" .
          do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
          assign ItogStr = ItogStr + "Всего по гр. пост. " + tt-grp-tree.name .
          run PrintItogGroup in this-procedure ( ItogStr, tt-grp-tree.qnty1, tt-grp-tree.qnty2, tt-grp-tree.qnty3 ) .
        end.
        delete tt-grp-tree .
      end.
    end.
  end.
end procedure.
procedure Run6 :
  do on error undo, return error return-value :
    if  p-Rad-Inter = 1  then do:
      for each temp-gds-time-post
        break by temp-gds-time-post.dt
              by temp-gds-time-post.tm
              by temp-gds-time-post.cgrp-name
              by temp-gds-time-post.grp-name
              by temp-gds-time-post.post-type
              by temp-gds-time-post.post-code
              by if xSortType = "sort-article" then  temp-gds-time-post.artic Else  temp-gds-time-post.gds-name :
        if first-of(temp-gds-time-post.tm)        then run PrintTime ( string(temp-gds-time-post.dt,"99/99/99") + " " + string(temp-gds-time-post.tm,"99") + ".00" ) .
        if first-of(temp-gds-time-post.cgrp-name) then run PrintName ( "  Гр. пост. " + temp-gds-time-post.cgrp-name ) .
        if first-of(temp-gds-time-post.grp-name)  then run PrintName ( "    Группа " + temp-gds-time-post.grp-name ) .
        if first-of(temp-gds-time-post.post-code) then do:
          find first buf_clients no-lock where buf_clients.obj-type = temp-gds-time-post.post-type and buf_clients.obj-code = temp-gds-time-post.post-code no-error .
          run PrintName ( "      Поставщик " + buf_clients.obj-name ) .
        end.
        run PrintLine  in this-procedure ( temp-gds-time-post.qnty1, temp-gds-time-post.qnty2, temp-gds-time-post.min-qnty, temp-gds-time-post.artic, temp-gds-time-post.gds-name, temp-gds-time-post.unit-base) .
        if last-of(temp-gds-time-post.post-code)  then Run PrintItog ("      Всего по поставщику " + buf_clients.obj-name, 1).
        if last-of(temp-gds-time-post.grp-name)   then Run PrintItog ("    Всего по группе " + temp-gds-time-post.grp-name, 2).
        if last-of(temp-gds-time-post.cgrp-name)  then Run PrintItog ("  Всего по гр. пост. " + temp-gds-time-post.cgrp-name, 3).
        if last-of(temp-gds-time-post.tm)    then Run PrintItog ("Всего ", 4).
      end.
    end.
    else do:
      for each temp-gds-post
        break by temp-gds-post.cgrp-name
              by temp-gds-post.grp-name
              by temp-gds-post.post-type
              by temp-gds-post.post-code
              by if xSortType = "sort-article" then  temp-gds-post.artic      Else  temp-gds-post.gds-name :
        if first-of(temp-gds-post.cgrp-name) then run PrintName ( "Гр. пост. " + temp-gds-post.cgrp-name ) .
        if first-of(temp-gds-post.grp-name)  then run PrintName ( "  Группа " + temp-gds-post.grp-name ) .
        if first-of(temp-gds-post.post-code) then do:
          find first buf_clients no-lock where buf_clients.obj-type = temp-gds-post.post-type and buf_clients.obj-code = temp-gds-post.post-code no-error .
          run PrintName ( "    Поставщик " + buf_clients.obj-name ) .
        end.
        run PrintLine  in this-procedure ( temp-gds-post.qnty1, temp-gds-post.qnty2, temp-gds-post.min-qnty, temp-gds-post.artic, temp-gds-post.gds-name, temp-gds-post.unit-base) .
        if last-of(temp-gds-post.post-code)  then Run PrintItog ("    Всего по поставщику " + buf_clients.obj-name, 1).
        if last-of(temp-gds-post.grp-name)   then Run PrintItog ("  Всего по группе " + temp-gds-post.grp-name, 2).
        if last-of(temp-gds-post.cgrp-name)  then Run PrintItog ("Всего по гр. пост. " + temp-gds-post.cgrp-name, 3).
      end.
    end.
  end.
end procedure.
procedure Run7 :
  do on error undo, return error return-value :
    if  p-Rad-Inter = 1  then do:
      for each temp-gds-time-post
        break by temp-gds-time-post.dt
              by temp-gds-time-post.tm
              by temp-gds-time-post.grp-name
              by temp-gds-time-post.cgrp-name
              by temp-gds-time-post.post-type
              by temp-gds-time-post.post-code
              by if xSortType = "sort-article" then  temp-gds-time-post.artic Else  temp-gds-time-post.gds-name :
        if first-of(temp-gds-time-post.tm)        then run PrintTime ( string(temp-gds-time-post.dt,"99/99/99") + " " + string(temp-gds-time-post.tm,"99") + ".00" ) .
        if first-of(temp-gds-time-post.grp-name)  then run PrintName ( "  Группа " + temp-gds-time-post.grp-name ) .
        if first-of(temp-gds-time-post.cgrp-name) then run PrintName ( "    Гр. пост. " + temp-gds-time-post.cgrp-name ) .
        if first-of(temp-gds-time-post.post-code) then do:
          find first buf_clients no-lock where buf_clients.obj-type = temp-gds-time-post.post-type and buf_clients.obj-code = temp-gds-time-post.post-code no-error .
          run PrintName ( "      Поставщик " + buf_clients.obj-name ) .
        end.
        run PrintLine  in this-procedure ( temp-gds-time-post.qnty1, temp-gds-time-post.qnty2, temp-gds-time-post.min-qnty, temp-gds-time-post.artic, temp-gds-time-post.gds-name, temp-gds-time-post.unit-base) .
        if last-of(temp-gds-time-post.post-code)  then Run PrintItog ("      Всего по поставщику " + buf_clients.obj-name, 1).
        if last-of(temp-gds-time-post.cgrp-name)  then Run PrintItog ("    Всего по гр. пост. " + temp-gds-time-post.cgrp-name, 2).
        if last-of(temp-gds-time-post.grp-name)   then Run PrintItog ("  Всего по группе " + temp-gds-time-post.grp-name, 3).
        if last-of(temp-gds-time-post.tm)  then Run PrintItog ("Всего ", 4).
      end.
    end.
    else do:
      for each temp-gds-post
        break by temp-gds-post.grp-name
              by temp-gds-post.cgrp-name
              by temp-gds-post.post-type
              by temp-gds-post.post-code
              by if xSortType = "sort-article" then  temp-gds-post.artic      Else  temp-gds-post.gds-name :
        if first-of(temp-gds-post.grp-name) then  run PrintName ( "Группа " + temp-gds-post.grp-name ) .
        if first-of(temp-gds-post.cgrp-name) then run PrintName ( "  Гр. пост. " + temp-gds-post.cgrp-name ) .
        if first-of(temp-gds-post.post-code) then do:
          find first buf_clients no-lock where buf_clients.obj-type = temp-gds-post.post-type and buf_clients.obj-code = temp-gds-post.post-code no-error .
          run PrintName ( "    Поставщик " + buf_clients.obj-name ) .
        end.
        run PrintLine  in this-procedure ( temp-gds-post.qnty1, temp-gds-post.qnty2, temp-gds-post.min-qnty, temp-gds-post.artic, temp-gds-post.gds-name, temp-gds-post.unit-base) .
        if last-of(temp-gds-post.post-code)  then Run PrintItog ("    Всего по поставщику " + buf_clients.obj-name, 1).
        if last-of(temp-gds-post.cgrp-name)  then Run PrintItog ("  Всего по гр. пост. " + temp-gds-post.cgrp-name, 2).
        if last-of(temp-gds-post.grp-name)   then Run PrintItog ("Всего по группе " + temp-gds-post.grp-name, 3).
      end.
    end.
  end.
end procedure.
procedure ColumnTitle :
  do on error undo, return error return-value :
    if v-table = 1 then do:
      if  p-Rad-Inter = 1  then do:
        put stream PrnLibStream   Line format frmt skip .
        PUT stream PrnLibStream  "|"  "Час"                format "X(15)"  .
      end.
      else put stream PrnLibStream   Line format "X(107)" skip .
      PUT stream PrnLibStream
        "|"  " Всего товаров"     format "X(15)"
        "|"  " С не 0 остатком"   format "X(17)"
        "|"  " Разница"           format "X(15)"
        "|"  "   %"               format "X(10)"
        "|"  " С не 0 остатком"   format "X(17)"
        "|"  " Разница"           format "X(15)"
        "|"  "   %"               format "X(10)"
       "|"   skip .
      if  p-Rad-Inter = 1  then do:
        PUT stream PrnLibStream  "|"  " "  format "X(15)"  .
      end.
      PUT stream PrnLibStream
        "|"  ""                   format "X(15)"
        "|"  string("на " + p-cli-type1 + string( p-cli-code1 ))                  format "X(17)"
        "|"  ""                   format "X(15)"
        "|"  ""                   format "X(10)"
        "|"  string("на " + p-cli-type1 + string( p-cli-code1 ) + "+" + p-cli-type2 + string( p-cli-code2 ))         format "X(17)"
        "|"  ""                   format "X(15)"
        "|"  ""                   format "X(10)"
        "|"   skip .
      if  p-Rad-Inter = 1  then  put stream PrnLibStream   Line format frmt skip .
      else put stream PrnLibStream   Line format "X(107)" skip .
    end.
    else do:
      if  p-Rad-Inter = 1  then do:
        put stream PrnLibStream   Line format "X(132)" skip .
        PUT stream PrnLibStream
          "|"  "  №"                  format "X(5)"
          "|"  " Час"                 format "X(14)"
        .
      end.
      else do:
        put stream PrnLibStream   Line format "X(117)" skip
          "|"  "  №"                  format "X(5)"
        .
      end.
      PUT stream PrnLibStream
        "|"  " Артикул"             format "X(16)"
        "|"  " Наименование товара" format "X(40)"
        "|"  "Ед."                  format "X(3)"
        "|"  " мин. остаток"        format "X(15)"
        "|"  " остаток на "         format "X(15)"
        "|"  " остаток на "         format "X(15)"
        "|"   skip .
      if  p-Rad-Inter = 1  then do:
        PUT stream PrnLibStream  "|"  " "  format "X(5)"  "|"  " "  format "X(14)"  .
      end.
      else PUT stream PrnLibStream  "|"  " "  format "X(5)"  .
      PUT stream PrnLibStream
        "|"  ""                   format "X(16)"
        "|"  ""                   format "X(40)"
        "|"  "изм"                format "X(3)"
        "|"  string("на " + p-cli-type1 + string( p-cli-code1 ))    format "X(15)"
        "|"  string( p-cli-type1 + string( p-cli-code1 ))           format "X(15)"
        "|"  string( p-cli-type2 + string( p-cli-code2 ))           format "X(15)"
        "|"   skip .
      if  p-Rad-Inter = 1  then  put stream PrnLibStream   Line format "X(132)" skip .
      else put stream PrnLibStream   Line format "X(117)" skip .
    end.
  end.
end procedure.
procedure is-page :
  do on error undo, return error return-value :
    if line-counter( PrnLibStream ) + 2 > page-size( PrnLibStream ) then do:
      put stream PrnLibStream  skip Line format frmt skip "продолжение - на следующей странице" AT 30 SKIP .
      page stream PrnLibStream .
      run ColumnTitle .
    end.
  end.
end procedure.
procedure PrintLine :
  do on error undo, return error return-value :
    define input  parameter p-qnty1     as decimal   no-undo .
    define input  parameter p-qnty2     as decimal   no-undo .
    define input  parameter p-min-qnty  as decimal   no-undo .
    define input  parameter p-artic     as character no-undo .
    define input  parameter p-gds-name  as character no-undo .
    define input  parameter p-unit-base as character no-undo .
    if v-table = 1 then do:
      find first temp-sum where temp-sum.num = 0 no-error .
      if not available temp-sum then do:
        create temp-sum .
        assign temp-sum.num = 0 .
      end.
      assign temp-sum.qnty1 = temp-sum.qnty1 + 1 .
      if p-qnty1 > 0 then assign temp-sum.qnty2 = temp-sum.qnty2 + 1 .
      if p-qnty1 + p-qnty2 > 0 then assign temp-sum.qnty3 = temp-sum.qnty3 + 1 .
      if  xtog-lavel or xtog-lavel-2 then do:
        for each tt-grp-tree :
          assign
            tt-grp-tree.qnty1 = tt-grp-tree.qnty1 + 1
            tt-grp-tree.qnty2 = tt-grp-tree.qnty2 + if p-qnty1 > 0 then 1 else 0
            tt-grp-tree.qnty3 = tt-grp-tree.qnty3 + if p-qnty1 + p-qnty2 > 0 then 1 else 0
          .
        end.
      end.
    end.
    else do:
      if  xtog-lavel or xtog-lavel-2 then do:
        for each tt-grp-tree :
          assign
            tt-grp-tree.qnty1 = tt-grp-tree.qnty1 + p-min-qnty
            tt-grp-tree.qnty2 = tt-grp-tree.qnty2 + p-qnty1
            tt-grp-tree.qnty3 = tt-grp-tree.qnty3 + p-qnty2
          .
        end.
      end.
      find first temp-sum where temp-sum.num = 0 no-error .
      if not available temp-sum then do:
        create temp-sum .
        assign temp-sum.num = 0 .
      end.
      assign
        temp-sum.qnty1 = temp-sum.qnty1 + p-min-qnty
        temp-sum.qnty2 = temp-sum.qnty2 + p-qnty1
        temp-sum.qnty3 = temp-sum.qnty3 + p-qnty2
      .
      if p-Rad-Goods = 1 or (p-Rad-Goods = 2 and p-qnty1 = 0)  then do:
        assign num-line = num-line + 1 .
        run is-page .
        PUT stream PrnLibStream  "|"   num-line   format ">>>>9" .
        if  p-Rad-Inter = 1  then   PUT stream PrnLibStream  "|"  " "  format "X(14)"  .
        PUT stream PrnLibStream  "|"   p-artic       format "X(16)"
                              "|"   p-gds-name    format "X(40)"
                              "|"   p-unit-base   format "X(3)"
                              "|"   p-min-qnty    format "->>>>>>>>>9.999"
                              "|"   p-qnty1       format "->>>>>>>>>9.999"
                              "|"   p-qnty2       format "->>>>>>>>>9.999"
        "|" skip .
        assign  v-col = 1 .
        run macr_excel_char(string(num-line), v-row, v-col) .    assign  v-col = v-col + 1 .
        if  p-Rad-Inter = 1  then  assign  v-col = v-col + 1 .
        run macr_excel_char (p-artic, v-row, v-col) .        assign  v-col = v-col + 1 .
        run macr_excel_char (p-gds-name, v-row, v-col) .     assign  v-col = v-col + 1 .
        run macr_excel_char (p-unit-base, v-row, v-col) .    assign  v-col = v-col + 1 .
        run macr_excel_sum (p-min-qnty, v-row, v-col, 3) .   assign  v-col = v-col + 1 .
        run macr_excel_sum (p-qnty1, v-row, v-col, 3) .      assign  v-col = v-col + 1 .
        run macr_excel_sum (p-qnty2, v-row, v-col, 3) .
        assign  v-row = v-row + 1 .
      end.
    end.
  end.
end procedure.
procedure PrintName :
  do on error undo, return error return-value :
    define input  parameter str           as character no-undo .
    run is-page .
    if v-table = 1 then do:
      if  p-Rad-Inter = 1  then do:
        PUT stream PrnLibStream  "|" "|" at 17 str format "X(90)" "|" at 123 skip .
        run macr_excel_char(str, v-row, 2) .
      end.
      else do:
        PUT stream PrnLibStream  "|"  str format "X(100)" "|" at 107 skip .
        run macr_excel_char(str, v-row, 1) .
      end.
    end.
    else do:
      if  p-Rad-Inter = 1  then do:
        PUT stream PrnLibStream  "|" "|" at 7 "|" at 22 str format "X(100)" "|" at 132 skip .
        run macr_excel_char(str, v-row, 3) .
      end.
      else do:
        PUT stream PrnLibStream  "|" "|" at 7  str format "X(100)" "|" at 117 skip .
        run macr_excel_char(str, v-row, 2) .
      end.
    end.
    assign v-row = v-row + 1 .
  end.
end procedure.
procedure PrintItog :
  do on error undo, return error return-value :
    define input  parameter str          as character no-undo .
    define input  parameter level        as integer   no-undo .
    define variable sum1 as decimal   no-undo .
    define variable sum2 as decimal   no-undo .
    define variable sum3 as decimal   no-undo .
    if level = 0 then  find last  temp-sum use-index pi no-error  .
    else               find first temp-sum where temp-sum.num = ( level - 1 ) no-error .
    if available temp-sum then do:
      assign
        sum1 = temp-sum.qnty1
        sum2 = temp-sum.qnty2
        sum3 = temp-sum.qnty3
        temp-sum.qnty1 = 0
        temp-sum.qnty2 = 0
        temp-sum.qnty3 = 0
      .
    end.
    run is-page .
    if v-table = 1 then do:
      if  p-Rad-Inter = 1  then do:
        if str = "Всего " then PUT stream PrnLibStream  "|"  str  format "X(15)"  .
        else do:
          if level <> 1 then PUT stream PrnLibStream  "|" "|"  at 17 str  format "X(100)" "|" at 123 skip  "|" " "  format "X(15)"  .
          else               PUT stream PrnLibStream  "|" " "  format "X(15)"  .
        end.
      end.
      else do:
       if xClassify <> "no-classify":U  and level <> 1 then put stream PrnLibStream  "|" str format "X(100)" "|" at 107 skip .
      end.
      PUT stream PrnLibStream
        "|"  sum1                 format "->>>>>>>>>>>>>9"
        "|"  sum2                 format "->>>>>>>>>>>>>>>9"
        "|"  sum1 - sum2          format "->>>>>>>>>>>>>9"
        "|"  sum2 * 100 / sum1    format "->>>>>9.99"
        "|"  sum3                 format "->>>>>>>>>>>>>>>9"
        "|"  sum1 - sum3          format "->>>>>>>>>>>>>9"
        "|"  sum3 * 100 / sum1    format "->>>>>9.99"
        "|"   skip .
        assign  v-col = 1 .
        if  p-Rad-Inter = 1  and str = "Всего " then do:
          run macr_excel_char (str, v-row, v-col) .
          assign  v-col = v-col + 1 .
        end.
        else do:
          run macr_excel_char (str, v-row, v-col) .
          assign
            v-row = v-row + 1
            v-col = 1
          .
          if  p-Rad-Inter = 1 then assign  v-col = v-col + 1 .
        end.
        run macr_excel_sum (sum1, v-row, v-col, 0) .              assign  v-col = v-col + 1 .
        run macr_excel_sum (sum2, v-row, v-col, 0) .              assign  v-col = v-col + 1 .
        run macr_excel_sum ( sum1 - sum2, v-row, v-col, 0) .      assign  v-col = v-col + 1 .
        run macr_excel_sum (sum2 * 100 / sum1, v-row, v-col, 2) . assign  v-col = v-col + 1 .
        run macr_excel_sum (sum3, v-row, v-col, 0) .              assign  v-col = v-col + 1 .
        run macr_excel_sum ( sum1 - sum3, v-row, v-col, 0) .      assign  v-col = v-col + 1 .
        run macr_excel_sum (sum3 * 100 / sum1, v-row, v-col, 2) . assign  v-col = v-col + 1 .
        assign  v-row = v-row + 1 .
    end.
    else do:
      if  p-Rad-Inter = 1  then do:
        if str = "Всего " then PUT stream PrnLibStream  "|" "|" at 7  str  format "X(14)" "|"  " " format "X(77)" .
        else                   PUT stream PrnLibStream  "|" "|" at 7 "|"  at 22 str  format "X(77)"  .
      end.
      else  put stream PrnLibStream  "|" "|" at 7 str format "X(77)" .
      PUT stream PrnLibStream
        "|"  sum2   format "->>>>>>>>>9.999"
        "|"  sum3   format "->>>>>>>>>9.999"
        "|"   skip .
        assign  v-col = 2 .
        if p-Rad-Inter = 2 or str = "Всего " then do:
          run macr_excel_char (str, v-row, v-col) .       assign  v-col = v-col + 4 .
        end.
             assign  v-col = v-col + 1 .
        run macr_excel_sum (sum2, v-row, v-col, 3) .      assign  v-col = v-col + 1 .
        run macr_excel_sum (sum3, v-row, v-col, 3) .
        assign  v-row = v-row + 1 .
    end.
    if level > 0  then do:
      run is-page .
      if  p-Rad-Inter = 2 or str <> "Всего " then do:
        find first temp-sum where temp-sum.num = level no-error .
        if not available temp-sum then do:
          create temp-sum .
          assign temp-sum.num = level .
        end.
        assign
          temp-sum.qnty1 = temp-sum.qnty1 + sum1
          temp-sum.qnty2 = temp-sum.qnty2 + sum2
          temp-sum.qnty3 = temp-sum.qnty3 + sum3
        .
      end.
    end.
  end.
end procedure.
procedure PrintItogGroup :
  do on error undo, return error return-value :
    define input  parameter str       as character no-undo .
    define input  parameter sum1 as decimal   no-undo .
    define input  parameter sum2 as decimal   no-undo .
    define input  parameter sum3 as decimal   no-undo .
    run is-page .
    if v-table = 1 then do:
      if  p-Rad-Inter = 1  then  PUT stream PrnLibStream  "|" "|"  at 17 str  format "X(100)" "|" at 123 skip  "|" " "  format "X(15)"  .
      else                       put stream PrnLibStream  "|" str format "X(100)" "|" at 107 skip .
      PUT stream PrnLibStream
        "|"  sum1     format "->>>>>>>>>>>>>9"
        "|"  sum2     format "->>>>>>>>>>>>>>>9"
        "|"  sum1 - sum2  format "->>>>>>>>>>>>>9"
        "|"  sum2 * 100 / sum1    format "->>>>>9.99"
        "|"  sum3     format "->>>>>>>>>>>>>>>9"
        "|"  sum1 - sum3  format "->>>>>>>>>>>>>9"
        "|"  sum3 * 100 / sum1    format "->>>>>9.99"
        "|"   skip .
        if p-Rad-Inter = 1 then assign  v-col = 2 .
        else                    assign  v-col = 1 .
        run macr_excel_char (str, v-row, v-col) .
        assign v-row = v-row + 1  .
        if p-Rad-Inter = 1 then assign  v-col = 2 .
        else                    assign  v-col = 1 .
        run macr_excel_sum (sum1, v-row, v-col, 0) .              assign  v-col = v-col + 1 .
        run macr_excel_sum (sum2, v-row, v-col, 0) .              assign  v-col = v-col + 1 .
        run macr_excel_sum ( sum1 - sum2, v-row, v-col, 0) .      assign  v-col = v-col + 1 .
        run macr_excel_sum (sum2 * 100 / sum1, v-row, v-col, 2) . assign  v-col = v-col + 1 .
        run macr_excel_sum (sum3, v-row, v-col, 0) .              assign  v-col = v-col + 1 .
        run macr_excel_sum ( sum1 - sum3, v-row, v-col, 0) .      assign  v-col = v-col + 1 .
        run macr_excel_sum (sum3 * 100 / sum1, v-row, v-col, 2) . assign  v-col = v-col + 1 .
        assign  v-row = v-row + 1 .
    end.
    else do:
      if  p-Rad-Inter = 1  then  PUT stream PrnLibStream  "|" "|" at 7 "|"  at 22 str  format "X(77)"  .
      else                       put stream PrnLibStream  "|" "|" at 7 str format "X(77)" .
      PUT stream PrnLibStream
        "|"  sum2   format "->>>>>>>>>9.999"
        "|"  sum3   format "->>>>>>>>>9.999"
        "|"   skip .
      if p-Rad-Inter = 1 then assign  v-col = 3 .
      else                    assign  v-col = 2 .
      run macr_excel_char (str, v-row, v-col) .       assign  v-col = v-col + 3 .
          assign  v-col = v-col + 1 .
      run macr_excel_sum (sum2, v-row, v-col, 3) .    assign  v-col = v-col + 1 .
      run macr_excel_sum (sum3, v-row, v-col, 3) .
      assign  v-row = v-row + 1 .
    end.
  end.
end procedure.
procedure Find-fo :
  do on error undo, return error return-value :
    define input  parameter p-dt as date      no-undo .
    define input  parameter p-tm as integer   no-undo .
    define output parameter p-fo as decimal   no-undo .
    define buffer buf_trn-doc for trn-doc.
    find last buf_trn-doc no-lock
      where buf_trn-doc.obj-type = p-cli-type1
        and buf_trn-doc.obj-code = p-cli-code1
        and buf_trn-doc.status_ = 'факт':U
        and buf_trn-doc.fact-date < p-dt
    USE-INDEX stat-fact  no-error .
    if available buf_trn-doc then assign p-fo = buf_trn-doc.fact-order.
    find last buf_trn-doc no-lock
      where buf_trn-doc.obj-type = p-cli-type2
        and buf_trn-doc.obj-code = p-cli-code2
        and buf_trn-doc.status_ = 'факт':U
        and buf_trn-doc.fact-date < p-dt
    USE-INDEX stat-fact  no-error .
    if available buf_trn-doc and buf_trn-doc.fact-order > p-fo then assign p-fo = buf_trn-doc.fact-order.
    for each  buf_trn-doc no-lock
      where buf_trn-doc.obj-type  = p-cli-type1
        and buf_trn-doc.obj-code  = p-cli-code1
        and buf_trn-doc.status_   = 'факт':U
        and buf_trn-doc.fact-date = p-dt
    :
      if buf_trn-doc.fact-time <= p-tm and buf_trn-doc.fact-order > p-fo then assign p-fo = buf_trn-doc.fact-order .
    end.
    for each  buf_trn-doc no-lock
      where buf_trn-doc.obj-type  = p-cli-type2
        and buf_trn-doc.obj-code  = p-cli-code2
        and buf_trn-doc.status_   = 'факт':U
        and buf_trn-doc.fact-date = p-dt
    :
      if buf_trn-doc.fact-time <= p-tm and buf_trn-doc.fact-order > p-fo then assign p-fo = buf_trn-doc.fact-order .
    end.
  end.
end procedure.
procedure PutColumnTitulExcel :
  do on error undo, return error return-value :
    if v-table = 1 then do:
      run macr_excel_char (ReportNAme, v-row, 3) .
      run macr_cell_format ( 11, yes, no, ?, v-row, 3, v-row, 3) .
      assign v-row = v-row + 1 .
      run macr_excel_char (ReportHeader, v-row, 1) .
      assign
        v-row = v-row + 1
        v-col = 1
      .
      if  p-Rad-Inter = 1  then do:
        run macr_excel_char("Час", v-row, v-col) .
        assign v-col = v-col + 1 .
      end.
      run macr_excel_char("Всего товаров", v-row, v-col) .
      assign v-col = v-col + 1 .
      run macr_excel_char("С не 0 остатком на " + p-cli-type1 + string( p-cli-code1 ), v-row, v-col) .
      assign v-col = v-col + 1 .
      run macr_excel_char("Разница", v-row, v-col) .
      assign v-col = v-col + 1 .
      run macr_excel_char("%", v-row, v-col) .
      assign v-col = v-col + 1 .
      run macr_excel_char("С не 0 остатком на " + p-cli-type1 + string( p-cli-code1 )  + "+" + p-cli-type2 + string( p-cli-code2 ), v-row, v-col) .
      assign v-col = v-col + 1 .
      run macr_excel_char("Разница", v-row, v-col) .
      assign v-col = v-col + 1 .
      run macr_excel_char("%", v-row, v-col) .
    end.
    else do:
      assign
        v-row = v-row + 2
        v-col = 1
      .
      run macr_excel_char("№", v-row, v-col) .
      assign v-col = v-col + 1 .
      if  p-Rad-Inter = 1  then do:
        run macr_excel_char("Час", v-row, v-col) .
        assign v-col = v-col + 1 .
      end.
      run macr_excel_char("Артикул", v-row, v-col) .
      assign v-col = v-col + 1 .
      run macr_excel_char("Наименование товара", v-row, v-col) .
      assign v-col = v-col + 1 .
      run macr_excel_char("Ед. изм.", v-row, v-col) .
      assign v-col = v-col + 1 .
      run macr_excel_char("Мин. остаток на " + p-cli-type1 + string( p-cli-code1 ), v-row, v-col) .
      assign v-col = v-col + 1 .
      run macr_excel_char("Остаток на " + p-cli-type1 + string( p-cli-code1 ), v-row, v-col) .
      assign v-col = v-col + 1 .
      run macr_excel_char("Остаток на " + p-cli-type2 + string( p-cli-code2 ), v-row, v-col) .
    end.
    run macr_cell_bordur ( v-row, 1, v-row , v-col) .
    run macr_cell_format ( 10, yes, no, 35, v-row, 1, v-row, v-col) .
    assign v-row = v-row + 1 .
  end.
end procedure.
procedure PrintTime :
  do on error undo, return error return-value :
    define input  parameter p-str as character no-undo .
    if v-table = 1 then do:
      PUT stream PrnLibStream  "|" p-str format "X(15)" "|" at 17  "|" at 123 skip .
      run macr_excel_char (p-str, v-row, 1) .
      assign v-row = v-row + 1 .
    end.
    else do:
      PUT stream PrnLibStream  "|" "|" at 7 p-str format "X(14)" "|" at 22  "|" at 132 skip .
      run macr_excel_char (p-str, v-row, 2) .
      assign v-row = v-row + 1 .
    end.
  end.
end procedure.
